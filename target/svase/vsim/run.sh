# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

questa-2022.3 vsim -c -do "set PRELMODE ${PM}; set BOOTMODE 0; set IMAGE ${IMG}; set BINARY ../../../sw/tests/helloworld.spm.elf; source compile.cheshire_soc.tcl; source start.cheshire_soc.tcl; run -all"