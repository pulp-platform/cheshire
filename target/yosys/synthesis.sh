#!/bin/bash
# Copyright (c) 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

SCRIPTDIR="$(realpath $(dirname "${BASH_SOURCE[0]}"))"
CHS_BENDER_RTL_FLAGS=${CHS_BENDER_RTL_FLAGS:--t rtl -t cva6 -t cv64a6_imafdcsclic_sv39}
BENDER_TARGETS="-t chs_synthesis -t asic $CHS_BENDER_RTL_FLAGS"
BENDER_DEFINES="-D SYNTHESIS -D COMMON_CELLS_ASSERTS_OFF"

cd $SCRIPTDIR
mkdir -p out
bender script flist-plus $BENDER_TARGETS $BENDER_DEFINES > out/cheshire.f

yosys -s yosys.ys
