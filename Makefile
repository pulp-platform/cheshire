# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

BENDER 	    ?= bender
PYTHON      ?= python3

REGGEN_PATH  = $(shell find -path "./.bender/git/checkouts/register_interface*/vendor/lowrisc_opentitan/util/regtool.py") 
REGGEN	     = $(PYTHON) $(REGGEN_PATH) 

VLOG_ARGS    = -timescale 1ns/1ps -suppress 8607

.PHONY: all 

all: 	cheshire_regs\
		vsim/compile.tcl\

###############
# Generate HW #
###############

cheshire_regs: .cheshire_regs
.cheshire_regs:
	$(REGGEN) -r src/regs/cheshire_regs.hjson --outdir src/regs
	$(REGGEN) --cdefines --outfile sw/include/cheshire_regs.h src/regs/cheshire_regs.hjson
	@touch .cheshire_regs


#########################
# Dependency Management #
#########################

bender: Bender.yml
	$(BENDER) update


##############
# Simulation #
##############

vsim/compile.tcl: bender
	$(BENDER) script vsim -t sim --vlog-arg="$(VLOG_ARGS)" > $@
