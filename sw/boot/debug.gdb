load boot/fw_payload.dtb.elf
symbol-file boot/fw_payload.dtb.elf
symbol-file boot/install64/u-boot
set $a0=0
set $a1=0x80800000
break _start
