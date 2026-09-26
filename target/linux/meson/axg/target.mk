# SPDX-License-Identifier: GPL-2.0-only

ARCH:=aarch64
SUBTARGET:=axg
BOARDNAME:=Meson AXG (A113X) boards
CPU_TYPE:=cortex-a53

define Target/Description
	Build firmware for Amlogic Meson AXG (A113X) devices.
endef
