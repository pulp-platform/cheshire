# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Thomas Benz <tbenz@iis.ee.ethz.ch>

source compile.cheshire_soc.tcl
set BOOTMODE 0
set PRELMODE 0
set SELCFG 1
set BINARY ../../../sw/tests/2d_dma.spm.elf
set VOPTARGS "+acc"

source start.cheshire_soc.tcl

log -r /*
