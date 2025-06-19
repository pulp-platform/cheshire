# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# OpenOCD script for Cheshire on Verilator (using remote_bitbang).

adapter_khz 8000

interface remote_bitbang
remote_bitbang_host localhost
remote_bitbang_port 3335

set irlen 5

source [file dirname [info script]]/openocd.common.tcl
