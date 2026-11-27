# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICEN
# SPDX-License-Identifier: Apache-2.0
#
# OpenOCD script for Cheshire for Alveo u280 board through
# BSCANE2 tunnel (FPGA's native JTAG interface).

adapter driver ftdi
adapter speed 200
transport select jtag
 
# FTF232
ftdi_vid_pid 0x0403 0x6011
ftdi_layout_init 0x0008 0x05eb
 
set _CHIPNAME riscv
jtag newtap $_CHIPNAME cpu -irlen 18 -expected-id 0x14B79093
 
set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME riscv -chain-position $_TARGETNAME
 
riscv set_ir idcode 0x9249
riscv set_ir dtmcs 0x22924
riscv set_ir dmi 0x23924
 
telnet_port disabled
tcl_port disabled
gdb_port 3334