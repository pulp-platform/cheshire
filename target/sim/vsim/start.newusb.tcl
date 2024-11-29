# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Fabian Hauser <fhauser@student.ethz.ch>

set TESTBENCH new_usb_tb

# tclint-disable-next-line command-args
eval "vsim -c ${TESTBENCH} -t 1ps"

set StdArithNoWarnings 1
set NumericStdNoWarnings 1
