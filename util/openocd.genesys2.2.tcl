# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# OpenOCD script for Cheshire through Digilent HS2 adapter.

interface ftdi
ftdi_serial 200300B18C7A
gdb_port 3334

source [file dirname [info script]]/openocd.genesys2.tcl
