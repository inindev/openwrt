#!/usr/bin/env bash
# Build the Hubitat C7 image and every kernel module, then stage the apk
# feed at the same path base-files.mk writes into the image.
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname "$0")/../../.." && pwd)
cd "$ROOT"
umask 022

kernel_val() {
	make -s -C target/linux TOPDIR="$ROOT" "val.$1"
}

# package/Makefile only generates a signing key when these files are missing.
# Images trust this key, so every build must sign with the same one.
if [ -z "${APK_PRIVATE_KEY:-}" ] || [ -z "${APK_PUBLIC_KEY:-}" ]; then
	echo "APK_PRIVATE_KEY and APK_PUBLIC_KEY must be set" >&2
	exit 1
fi
(umask 077 && printf '%s\n' "$APK_PRIVATE_KEY" > private-key.pem)
printf '%s\n' "$APK_PUBLIC_KEY" > public-key.pem

cp target/linux/meson/hubitat-c7.diffconfig .config
cat >> .config << 'EOF'
CONFIG_ALL_KMODS=y
CONFIG_DEVEL=y
CONFIG_AUTOREMOVE=y
CONFIG_BUILD_LOG=y
EOF

./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
make prereq

grep -q '^CONFIG_ALL_KMODS=y' .config
grep -q '^CONFIG_USE_APK=y' .config
grep -q '^CONFIG_AUTOREMOVE=y' .config
grep -q '^CONFIG_SIGNED_PACKAGES=y' .config
if grep -q '^CONFIG_BUILDBOT=y' .config; then
	echo "CONFIG_BUILDBOT must stay unset so the image keeps the local apk key" >&2
	exit 1
fi

make -j"$(nproc)" download
if ! make -j"$(nproc)" IGNORE_ERRORS=m world; then
	echo "===== kernel build log (tail) ====="
	if [ -s logs/target/linux/compile.txt ]; then
		tail -n 200 logs/target/linux/compile.txt
	fi
	find logs -name error.txt -type f -print -exec cat {} \;

	# Kconfig stops at the first unlisted symbol. List all of them so they
	# can be added to target/linux/meson/config-6.12 in one pass.
	linux_dir=$(kernel_val LINUX_DIR)
	if [ -s "$linux_dir/.config" ]; then
		echo "===== kernel symbols missing from the target config ====="
		PATH="$(kernel_val TOOLCHAIN_DIR)/bin:$PATH" \
			make -s -C "$linux_dir" ARCH="$(kernel_val LINUX_KARCH)" \
			CROSS_COMPILE="$(kernel_val KERNEL_CROSS)" listnewconfig || true
	fi
	exit 1
fi

# A kmod can make a dependency a module, and Kconfig then quietly demotes
# a =y from the target config to =m or drops it. Fail on any that did not
# survive into the kernel config.
linux_dir=$(kernel_val LINUX_DIR)
demoted=$(sed -n 's/^\(CONFIG_[A-Za-z0-9_]*\)=y$/\1/p' target/linux/meson/config-6.12 |
	while read -r sym; do
		grep -qx "${sym}=y" "$linux_dir/.config" ||
			echo "$sym: $(grep -E "^(# )?${sym}[= ]" "$linux_dir/.config" || echo 'not in .config')"
	done)
if [ -n "$demoted" ]; then
	echo "target config symbols not built in:" >&2
	echo "$demoted" >&2
	exit 1
fi

if [ -s logs/package/error.txt ]; then
	echo "Packages that failed to build:"
	cat logs/package/error.txt
fi

linux_version=$(kernel_val LINUX_VERSION)
linux_release=$(kernel_val LINUX_RELEASE)
linux_vermagic=$(kernel_val LINUX_VERMAGIC)
if [ -z "$linux_version" ] || [ -z "$linux_release" ] || [ -z "$linux_vermagic" ] || [ "$linux_vermagic" = unknown ]; then
	echo "kernel version is incomplete: ${linux_version}-${linux_release}-${linux_vermagic}" >&2
	exit 1
fi

pkg_dir=bin/targets/meson/axg/packages
if [ ! -s "$pkg_dir/packages.adb" ]; then
	echo "missing $pkg_dir/packages.adb" >&2
	exit 1
fi
kernel_apk="$pkg_dir/kernel-${linux_version}~${linux_vermagic}-r${linux_release}.apk"
if [ ! -s "$kernel_apk" ]; then
	echo "missing $kernel_apk, the feed path would not match the image" >&2
	exit 1
fi
shopt -s nullglob
kmods=("$pkg_dir"/kmod-*.apk)
shopt -u nullglob
if [ "${#kmods[@]}" -eq 0 ]; then
	echo "no kmod packages were built" >&2
	exit 1
fi

bundle_name=openwrt-meson-axg-hubitat_elevation-c7
bundle_dir="firmware-bundle/${bundle_name}"
rm -rf firmware-bundle
mkdir -p "$bundle_dir"
bundle_file() {
	if [ ! -s "$1" ]; then
		echo "missing $1" >&2
		exit 1
	fi
	cp "$1" "$bundle_dir/$2"
}
img_dir=bin/targets/meson/axg
image_dir=$(kernel_val STAGING_DIR_IMAGE)
for img in initramfs-kernel.bin squashfs-emmc.img.gz squashfs-sysupgrade.bin; do
	shopt -s nullglob
	matches=("$img_dir"/*-hubitat_elevation-c7-"$img")
	shopt -u nullglob
	if [ "${#matches[@]}" -ne 1 ]; then
		echo "expected one *-hubitat_elevation-c7-${img} in $img_dir, found ${#matches[@]}" >&2
		exit 1
	fi
	bundle_file "${matches[0]}" "$(basename "${matches[0]}")"
done
bundle_file "$(kernel_val KERNEL_BUILD_DIR)/image-meson-axg-hubitat-c7.dtb" meson-axg-hubitat-c7.dtb
bundle_file "$image_dir/hubitat-c7-u-boot.bin.mmc.bin" u-boot.bin
bundle_file "$image_dir/hubitat-c7-u-boot.bin.usb.bl2" u-boot.bin.usb.bl2
bundle_file "$image_dir/hubitat-c7-u-boot.bin.usb.tpl" u-boot.bin.usb.tpl
(cd "$bundle_dir" && sha256sum -- * > sha256sums)
tar -C firmware-bundle -czf "firmware-bundle/${bundle_name}.tar.gz" "$bundle_name"
(cd firmware-bundle && sha256sum "${bundle_name}.tar.gz" > "${bundle_name}.tar.gz.sha256")

feed_rel="targets/meson/axg/kmods/${linux_version}-${linux_release}-${linux_vermagic}"
rm -rf pages-feed
mkdir -p "pages-feed/$feed_rel"
cp -a "$pkg_dir"/. "pages-feed/$feed_rel/"

feed_url="https://inindev.github.io/openwrt/${feed_rel}/packages.adb"
mkdir -p build-info
cat > build-info/release-notes.txt << EOF
Hubitat Elevation C7 firmware and matching kernel modules.

Kernel: ${linux_version}-${linux_release}-${linux_vermagic}
Feed: ${feed_url}

Install a module on a device flashed from this run with apk update and apk add.
EOF

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
	{
		echo "## Hubitat C7"
		echo
		echo "Feed: \`${feed_url}\`"
		echo
		echo "Kernel modules built: ${#kmods[@]}"
		if [ -s logs/package/error.txt ]; then
			echo
			echo "### Packages that failed to build"
			echo
			echo '```'
			cat logs/package/error.txt
			echo '```'
		fi
	} >> "$GITHUB_STEP_SUMMARY"
fi

echo "staged ${feed_url}"
