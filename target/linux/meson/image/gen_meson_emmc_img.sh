#!/bin/sh
# MBR image: FAT boot + rootfs. First partition starts at 2 MiB so the
# signed FIP at eMMC sector 1 is not overwritten.
set -e

[ $# -eq 5 ] || [ $# -eq 6 ] || {
	echo "SYNTAX: $0 <output> <bootfs> <rootfs> <bootfs MiB> <rootfs MiB> [fip]" >&2
	exit 1
}

OUTPUT="$1"
BOOTFS="$2"
ROOTFS="$3"
BOOTFSSIZE="$4"
ROOTFSSIZE="$5"
FIP="${6:-}"

rm -f "$OUTPUT"

# -l 1024: 1 MiB alignment. @2M keeps p1 off the FIP at sector 1.
set -- $(ptgen -o "$OUTPUT" -h 4 -s 63 -l 1024 -t c -p "${BOOTFSSIZE}M@2M" -t 83 -p "${ROOTFSSIZE}M")
P1_START="$1"
P2_START="$3"
P2_SIZE="$4"

# ptgen writes a 512-byte MBR only. Grow to the end of p2 so gunzip|dd
# zeros leftover eMMC instead of leaving stock data in the overlay.
truncate -s $((P2_START + P2_SIZE)) "$OUTPUT"

BOOTOFFSET="$((P1_START / 512))"
ROOTFSOFFSET="$((P2_START / 512))"

dd if="$BOOTFS" of="$OUTPUT" bs=512 seek="$BOOTOFFSET" conv=notrunc
dd if="$ROOTFS" of="$OUTPUT" bs=512 seek="$ROOTFSOFFSET" conv=notrunc

if [ -n "$FIP" ]; then
	[ -f "$FIP" ] || {
		echo "FIP not found: $FIP" >&2
		exit 1
	}
	# Same placement as: dd if=u-boot.bin of=/dev/mmcblk0 bs=512 seek=1
	dd if="$FIP" of="$OUTPUT" bs=512 seek=1 conv=notrunc
fi
