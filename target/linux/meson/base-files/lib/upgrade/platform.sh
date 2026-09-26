REQUIRE_IMAGE_METADATA=1

# In-place upgrade of the FAT boot partition and the squashfs root.
# The FIP in front of partition 1 and the partition table are left alone.
# Config is written back after the new squashfs unless sysupgrade -n.

platform_check_image() {
	local board_dir

	board_dir=$(tar tf "$1" | grep -m 1 '^sysupgrade-.*/$')
	[ -n "$board_dir" ] || return 1
	tar tf "$1" "${board_dir}kernel" "${board_dir}root" "${board_dir}dtb" >/dev/null
}

platform_do_upgrade() {
	local diskdev bootpart rootpart board_dir blocks

	export_bootdevice && export_partdevice diskdev 0 || {
		v "Unable to determine upgrade device"
		return 1
	}
	export_partdevice bootpart 1 || {
		v "Unable to find boot partition"
		return 1
	}
	export_partdevice rootpart 2 || {
		v "Unable to find root partition"
		return 1
	}

	board_dir=$(tar tf "$1" | grep -m 1 '^sysupgrade-.*/$')
	board_dir=${board_dir%/}

	v "Updating kernel and dtb on /dev/$bootpart"
	mkdir -p /mnt
	mount -t vfat -o rw,noatime "/dev/$bootpart" /mnt || return 1
	tar xf "$1" "$board_dir/kernel" -O > /mnt/Image || {
		umount /mnt
		return 1
	}
	tar xf "$1" "$board_dir/dtb" -O > /mnt/meson-axg-hubitat-c7.dtb || {
		umount /mnt
		return 1
	}
	sync
	umount /mnt

	v "Updating rootfs on /dev/$rootpart"
	blocks=$(tar xf "$1" "$board_dir/root" -O | dd of="/dev/$rootpart" bs=512 conv=fsync 2>&1 | grep "records out" | cut -d' ' -f1)
	[ -n "$blocks" ] || return 1

	# 64KiB align, same as ROOTDEV_OVERLAY_ALIGN in fstools.
	MESON_ROOT_DEV="/dev/$rootpart"
	MESON_ROOTFS_BLOCKS=$(((blocks + 127) & ~127))

	if [ -z "$UPGRADE_BACKUP" ]; then
		dd if=/dev/zero of="$MESON_ROOT_DEV" bs=512 seek=$MESON_ROOTFS_BLOCKS count=8 conv=fsync
	fi
}

platform_copy_config() {
	dd if="$UPGRADE_BACKUP" of="$MESON_ROOT_DEV" bs=512 seek=$MESON_ROOTFS_BLOCKS conv=fsync
}
