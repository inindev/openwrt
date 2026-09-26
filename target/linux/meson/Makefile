# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

ARCH:=aarch64
BOARD:=meson
BOARDNAME:=Amlogic Meson
FEATURES:=usb usbgadget gpio fpu rootfs-part boot-part squashfs
SUBTARGETS:=axg

KERNEL_PATCHVER:=6.12

define Target/Description
	Build firmware for Amlogic Meson AXG (A113X) boards.
endef

include $(INCLUDE_DIR)/target.mk

KERNELNAME:=Image dtbs

DEFAULT_PACKAGES += partx-utils e2fsprogs mkf2fs

$(eval $(call BuildTarget))
