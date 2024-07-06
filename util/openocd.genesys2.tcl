# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# OpenOCD script for Cheshire on Genesys2.

adapter_khz 8000
interface ftdi
ftdi_vid_pid 0x0403 0x6010
ftdi_layout_init 0x00e8 0x60eb
ftdi_channel 0
set irlen 5

source [file dirname [info script]]/openocd.common.tcl
