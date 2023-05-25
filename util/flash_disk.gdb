# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cheshire disk flashing script for use with GDB.

target extended-remote localhost:3333

# Load flashing program
load sw/boot/flash.spm.elf

# Load disk image to DRAM
eval "restore %s binary 0x80000000", $img

# Write flash parameters to scratch regs
set *0x03000000=$target
set *0x03000004=0x80000000
set *0x03000008=$offs
set *0x0300000c=$len

# Launch payload and quit after return
continue
quit
