# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_VERSION:=2026.10
PKG_RELEASE:=1
PKG_HASH:=3f856da3cbbc93af51ff95fde18588a348b4a26723b01d9841e999d988481015

PKG_MAINTAINER:=John Clark <inindev@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=Licenses/README

UBOOT_USE_INTREE_DTC:=1

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

PKG_BUILD_DEPENDS:=amlogic-boot-fip

define U-Boot/Default
  BUILD_TARGET:=meson
  BUILD_SUBTARGET:=axg
  HIDDEN:=1
  UBOOT_IMAGE:=u-boot.bin
endef

define U-Boot/hubitat-c7
  NAME:=Hubitat Elevation C7
  BUILD_DEVICES:=hubitat_elevation-c7
  UBOOT_CONFIG:=hubitat-c7
  DEPENDS:=+amlogic-boot-fip
endef

UBOOT_TARGETS := hubitat-c7

UBOOT_CUSTOMIZE_CONFIG := \
	--disable TOOLS_MKEFICAPSULE

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE) $(PKG_BUILD_DIR)/fip-out
	cd $(STAGING_DIR_IMAGE)/amlogic-boot-fip && \
		./build-fip.sh hubitat-c7 \
			$(PKG_BUILD_DIR)/u-boot.bin \
			$(PKG_BUILD_DIR)/fip-out
	$(CP) $(PKG_BUILD_DIR)/fip-out/u-boot.bin \
		$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.bin.mmc.bin
	$(CP) $(PKG_BUILD_DIR)/fip-out/u-boot.bin.sd.bin \
		$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.bin.sd.bin
	$(CP) $(PKG_BUILD_DIR)/fip-out/u-boot.bin.usb.bl2 \
		$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.bin.usb.bl2
	$(CP) $(PKG_BUILD_DIR)/fip-out/u-boot.bin.usb.tpl \
		$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.bin.usb.tpl
endef

define Package/u-boot/install/default
endef

$(eval $(call BuildPackage/U-Boot))
