# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=amlogic-boot-fip
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/inindev/amlogic-boot-fip.git
PKG_SOURCE_DATE:=2026-09-27
PKG_SOURCE_VERSION:=15edc952381603283d306a4532eddf50f78433bc
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=John Clark <inindev@gmail.com>
PKG_LICENSE:=proprietary
PKG_LICENSE_FILES:=LICENSE

PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk

define Package/amlogic-boot-fip
  SECTION:=boot
  CATEGORY:=Boot Loaders
  TITLE:=Amlogic firmware image package (FIP)
  DEPENDS:=@TARGET_meson
  DEFAULT:=y if TARGET_meson
  HIDDEN:=1
endef

define Package/amlogic-boot-fip/description
  Signing blobs and build-fip.sh. Hubitat C7 (A113X) uses the hubitat-c7 set.
endef

define Build/Compile
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)/amlogic-boot-fip
	$(CP) $(PKG_BUILD_DIR)/. $(STAGING_DIR_IMAGE)/amlogic-boot-fip/
endef

define Package/amlogic-boot-fip/install
endef

$(eval $(call BuildPackage,amlogic-boot-fip))
