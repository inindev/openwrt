define Device/default-nand
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  SUBPAGESIZE := 512
  MKUBIFS_OPTS := -m $$(PAGESIZE) -e 126KiB -c 2048
endef

define Device/at91sam9263ek
  $(Device/evaluation-dtb)
  DEVICE_TITLE := Atmel AT91SAM9263-EK
endef
TARGET_DEVICES += at91sam9263ek

define Device/at91sam9g15ek
  $(Device/evaluation)
  DEVICE_TITLE := Atmel AT91SAM9G15-EK
endef
TARGET_DEVICES += at91sam9g15ek

define Device/at91sam9g20ek
  $(Device/evaluation-dtb)
  DEVICE_TITLE := Atmel AT91SAM9G20-EK
endef
TARGET_DEVICES += at91sam9g20ek

define Device/at91sam9g20ek_2mmc
  $(Device/evaluation-dtb)
  DEVICE_TITLE := Atmel AT91SAM9G20-EK 2MMC
endef
TARGET_DEVICES += at91sam9g20ek_2mmc

define Device/at91sam9g25ek
  $(Device/evaluation)
  DEVICE_TITLE := Atmel AT91SAM9G25-EK
endef
TARGET_DEVICES += at91sam9g25ek

define Device/at91sam9g35ek
  $(Device/evaluation)
  DEVICE_TITLE := Atmel AT91SAM9G35-EK
endef
TARGET_DEVICES += at91sam9g35ek

define Device/at91sam9m10g45ek
  $(Device/evaluation)
  DEVICE_TITLE := Atmel AT91SAM9M10G45-EK
endef
TARGET_DEVICES += at91sam9m10g45ek

define Device/at91sam9x25ek
  $(Device/evaluation)
  DEVICE_TITLE := Atmel AT91SAM9X25-EK
endef
TARGET_DEVICES += at91sam9x25ek

define Device/at91sam9x35ek
  $(Device/evaluation)
  DEVICE_TITLE := Atmel AT91SAM9X35-EK
endef
TARGET_DEVICES += at91sam9x35ek

define Device/lmu5000
  $(Device/production)
  DEVICE_TITLE := CalAmp LMU5000
  DEVICE_PACKAGES := kmod-rtc-pcf2123 kmod-usb-acm kmod-usb-serial \
    kmod-usb-serial-option kmod-usb-serial-sierrawireless kmod-gpio-mcp23s08
endef
TARGET_DEVICES += lmu5000

define Device/tny_a9260
  $(Device/production-dtb)
  DEVICE_TITLE := Calao TNYA9260
endef
TARGET_DEVICES += tny_a9260

define Device/tny_a9263
  $(Device/production-dtb)
  DEVICE_TITLE := Calao TNYA9263
endef
TARGET_DEVICES += tny_a9263

define Device/tny_a9g20
  $(Device/production-dtb)
  DEVICE_TITLE := Calao TNYA9G20
endef
TARGET_DEVICES += tny_a9g20

define Device/usb_a9260
  $(Device/production-dtb)
  DEVICE_TITLE := Calao USBA9260
endef
TARGET_DEVICES += usb_a9260

define Device/usb_a9263
  $(Device/production-dtb)
  DEVICE_TITLE := Calao USBA9263
endef
TARGET_DEVICES += usb_a9263

define Device/usb_a9g20
  $(Device/production-dtb)
  DEVICE_TITLE := Calao USBA9G20
endef
TARGET_DEVICES += usb_a9g20

define Device/ethernut5
  $(Device/evaluation)
  DEVICE_TITLE := Ethernut 5
  UBINIZE_OPTS := -E 5
endef
TARGET_DEVICES += ethernut5

define Device/at91-q5xr5
  $(Device/production-dtb)
  DEVICE_TITLE := Exegin Q5XR5
  KERNEL_SIZE := 2048k
endef
#TARGET_DEVICES += at91-q5xr5

define Device/wb45n
  $(Device/evaluation-fit)
  DEVICE_TITLE := Laird WB45N
  DEVICE_PACKAGES := \
	kmod-mmc-at91 kmod-ath6kl-sdio ath6k-firmware \
	kmod-usb-storage kmod-fs-vfat kmod-fs-msdos \
	kmod-leds-gpio
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  SUBPAGESIZE := 2048
  MKUBIFS_OPTS := -m $$(PAGESIZE) -e 124KiB -c 955
endef
TARGET_DEVICES += wb45n

define Build/rth9580wf01-firmware
  dd bs=64K count=256 if=/dev/zero | tr '\000' '\377' > $(1).new
  dd bs=64K seek=0  conv=notrunc of=$(1).new if=$(BIN_DIR)/at91bootstrap-$(DEVICE_NAME)_uboot/at91bootstrap.bin
  dd bs=64K seek=1  conv=notrunc of=$(1).new if=$(BIN_DIR)/u-boot-$(DEVICE_NAME)_spiflash/u-boot.bin
  dd bs=64K seek=12 conv=notrunc of=$(1).new if=$(BIN_DIR)/$(KERNEL_IMAGE)
  dd bs=64K seek=76 conv=notrunc of=$(1).new if=$(BIN_DIR)/$(IMAGE_PREFIX)-squashfs-rootfs.bin
  mv $(1).new $(1)
endef

define Device/rth9580wf01
  DEVICE_TITLE := Resideo RTH9580WF01
  BLOCKSIZE := 64k

  KERNEL := kernel-bin | lzma | uImage lzma
  KERNEL_INSTALL := 1
  KERNEL_SUFFIX := -uImage

  IMAGES := rootfs.bin firmware.bin
  IMAGE/rootfs.bin := append-rootfs
  IMAGE/firmware.bin := rth9580wf01-firmware $$(BIN_DIR)/$$(IMAGE_PREFIX)-firmware.bin
endef
TARGET_DEVICES += rth9580wf01
