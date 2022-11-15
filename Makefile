# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>


BENDER 	    ?= bender
PYTHON      ?= python3

REGGEN_PATH  = $(shell $(BENDER) path register_interface)/vendor/lowrisc_opentitan/util/regtool.py
REGGEN	     = $(PYTHON) $(REGGEN_PATH) 

OT_PERI 	 = $(shell $(BENDER) path opentitan_peripherals)

# Alternative PLIC parameters
PLICOPT      = -s 20 -t 2 -p 7

VLOG_ARGS    ?= "" 

.PHONY: all 

all: 	cheshire_regs\
		otp\
		update_serial_link\
		update_i2c_regs \
		update_spi_regs \
		vsim/compile.tcl\
		vivado


##################################
# OpenTitan Peripherals Makefile #
##################################

include $(OT_PERI)/otp.mk

###############
# Generate HW #
###############

cheshire_regs: .cheshire_regs
.cheshire_regs:
	$(REGGEN) -r src/regs/cheshire_regs.hjson --outdir src/regs
	$(REGGEN) --cdefines --outfile sw/include/cheshire_regs.h src/regs/cheshire_regs.hjson
	cp sw/include/cheshire_regs.h vivado/bootrom/src/cheshire_regs.h
	$(MAKE) -C vivado/bootrom all
	@touch .cheshire_regs

#################
# Configure IPs #
#################

update_serial_link:
	cp serial_link_single_channel.hjson $(shell $(BENDER) path serial_link)/src/regs/serial_link_single_channel.hjson
	$(MAKE) -C $(shell $(BENDER) path serial_link) update-regs

####################
# Generate headers #
####################

update_i2c_regs: sw/include/i2c_regs.h
sw/include/i2c_regs.h: $(OT_PERI)/src/i2c/data/i2c.hjson
	$(REGGEN) --cdefines $< > $@

update_spi_regs: sw/include/spi_regs.h
sw/include/spi_regs.h: $(OT_PERI)/src/spi_host/data/spi_host.hjson
	$(REGGEN) --cdefines $< > $@


#########################
# Dependency Management #
#########################

bender: Bender.yml
	$(BENDER) update


##############
# Simulation #
##############

vsim/compile.tcl: bender
	$(BENDER) script vsim -t sim -t cv64a6_imafdc_sv39 -t test -t cva6 --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "../test/elfloader.cpp" -ccflags "-std=c++11"' >> $@

#############
# FPGA Flow #
#############
vivado: vivado/scripts/add_sources.tcl
vivado/scripts/add_sources.tcl: bender
	$(BENDER) script vivado -t fpga -t cv64a6_imafdc_sv39 -t cva6 > $@
