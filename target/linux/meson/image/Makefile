# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

# Find meson-axg.dtsi in the kernel tree when compiling our out-of-tree DTS.
DTS_CPPFLAGS += -I$(DTS_DIR)/amlogic

DEVICE_VARS += BOOT_CMDLINE UBOOT_IMAGE KERNEL_PARTSIZE ROOTFS_PARTSIZE

FAT32_BLOCK_SIZE=1024

define Build/extlinux-conf
	rm -rf $@.extlinux
	mkdir -p $@.extlinux
	sed \
		-e 's#@CMDLINE@#$(BOOT_CMDLINE)#g' \
		$(CURDIR)/hubitat.extlinux > $@.extlinux/extlinux.conf
endef

define Build/meson-emmc
	rm -f $@.bootfat
	mkfs.fat -n boot -C $@.bootfat \
		$(shell echo $$(($(KERNEL_PARTSIZE)*1024*1024/$(FAT32_BLOCK_SIZE))))
	mcopy -i $@.bootfat $(IMAGE_KERNEL) ::$(KERNEL_NAME)
	mcopy -i $@.bootfat $(KDIR)/image-$(firstword $(DEVICE_DTS)).dtb \
		::$(firstword $(DEVICE_DTS)).dtb
	mmd -i $@.bootfat ::extlinux
	mcopy -i $@.bootfat $@.extlinux/extlinux.conf ::extlinux/extlinux.conf
	$(CURDIR)/gen_meson_emmc_img.sh $@ \
		$@.bootfat \
		$(IMAGE_ROOTFS) \
		$(KERNEL_PARTSIZE) \
		$(ROOTFS_PARTSIZE) \
		$(if $(UBOOT_IMAGE),$(STAGING_DIR_IMAGE)/$(UBOOT_IMAGE))
	rm -rf $@.bootfat $@.extlinux
endef

define Device/Default
  PROFILES := Default
  KERNEL_NAME := Image
  KERNEL := kernel-bin
  DEVICE_DTS_DIR := ../dts
  IMAGES := emmc.img.gz
  IMAGE/emmc.img.gz := extlinux-conf | meson-emmc | gzip | append-metadata
  BOOT_CMDLINE := console=ttyAML0,115200n8 root=/dev/mmcblk0p2 rootwait
  KERNEL_PARTSIZE := 16
  ROOTFS_PARTSIZE := 7437
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))
