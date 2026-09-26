# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_VERSION:=2026.07
PKG_RELEASE:=1
PKG_HASH:=78e8bfc382fe388f9b55aa1daf8c563522a037779b5d4c349d1415e381f1243e

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
endef

define Package/u-boot/install/default
endef

$(eval $(call BuildPackage/U-Boot))
