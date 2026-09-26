# SPDX-License-Identifier: GPL-2.0-only

define Device/hubitat_elevation-c7
  DEVICE_VENDOR := Hubitat
  DEVICE_MODEL := Elevation C7
  DEVICE_DTS := meson-axg-hubitat-c7
  # USB host, DWC3, xHCI, and storage are built into config-6.12.
  DEVICE_PACKAGES := nano-plus openssh-sftp-server \
	ca-bundle zoneinfo-all \
	usbutils ethtool python3 xz \
	lsblk blkid losetup fdisk f2fsck fstrim \
	kmod-gpio-button-hotplug \
	-dnsmasq -firewall4 -nftables \
	-kmod-nft-offload -odhcpd-ipv6only \
	-ppp -ppp-mod-pppoe \
	-kmod-ppp -kmod-pppoe -kmod-pppox
  SUPPORTED_DEVICES += hubitat,elevation-c7
  UBOOT_IMAGE := hubitat-c7-u-boot.bin.mmc.bin
  # emmc.img.gz is the one-shot install (FIP + padded disk).
  # sysupgrade.bin is kernel, dtb, and rootfs for an in-place upgrade.
  IMAGES := emmc.img.gz sysupgrade.bin
  IMAGE/sysupgrade.bin := sysupgrade-tar dtb=$$(KDIR)/image-$$(DEVICE_DTS).dtb | append-metadata
endef
TARGET_DEVICES += hubitat_elevation-c7
