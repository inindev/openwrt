# SPDX-License-Identifier: GPL-2.0-only

define KernelPackage/i2c-meson
  TITLE:=Amlogic Meson I2C controller
  KCONFIG:=CONFIG_I2C_MESON
  DEPENDS:=@TARGET_meson +kmod-i2c-core
  SUBMENU:=$(I2C_MENU)
  FILES:=$(LINUX_DIR)/drivers/i2c/busses/i2c-meson.ko
  AUTOLOAD:=$(call AutoLoad,59,i2c-meson,1)
endef

define KernelPackage/i2c-meson/description
  Kernel module for the Amlogic Meson I2C controller.
endef

$(eval $(call KernelPackage,i2c-meson))


define KernelPackage/iio-meson-saradc
  TITLE:=Amlogic Meson SAR ADC
  KCONFIG:=CONFIG_MESON_SARADC
  FILES:=$(LINUX_DIR)/drivers/iio/adc/meson_saradc.ko
  AUTOLOAD:=$(call AutoProbe,meson_saradc)
  DEPENDS:=@TARGET_meson +kmod-regmap-mmio
  $(call AddDepends/iio)
endef

define KernelPackage/iio-meson-saradc/description
  Kernel module for the SAR ADC on Amlogic Meson SoCs.
endef

$(eval $(call KernelPackage,iio-meson-saradc))


define KernelPackage/spi-meson-spicc
  SUBMENU:=$(SPI_MENU)
  TITLE:=Amlogic Meson SPICC controller
  KCONFIG:= \
	CONFIG_SPI_MESON_SPICC \
	CONFIG_SPI=y \
	CONFIG_SPI_MASTER=y
  DEPENDS:=@TARGET_meson
  FILES:=$(LINUX_DIR)/drivers/spi/spi-meson-spicc.ko
  AUTOLOAD:=$(call AutoProbe,spi-meson-spicc)
endef

define KernelPackage/spi-meson-spicc/description
  Kernel module for the SPICC controller on Amlogic Meson SoCs.
endef

$(eval $(call KernelPackage,spi-meson-spicc))
