# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

BENDER      ?= bender
PYTHON3     ?= python3
REGGEN      ?= $(PYTHON3) $(shell $(BENDER) path register_interface)/vendor/lowrisc_opentitan/util/regtool.py

PLICOPT      = -s 20 -t 2 -p 7
VLOG_ARGS   ?= ""

.PHONY: all sw-all hw-all sim-all xilinx-all

all: sw-all hw-all sim-all xilinx-all

############
# Build SW #
############

include sw/sw.mk

###############
# Generate HW #
###############

# SoC registers
hw/regs/cheshire_reg_pkg.sv hw/regs/cheshire_reg_top.sv: hw/regs/cheshire_regs.hjson
	$(REGGEN) -r $< --outdir $(dir $@)

# Custom serial link
$(shell $(BENDER) path serial_link)/src/regs/.generated: hw/serial_link.hjson
	cp $< $(dir $@)/serial_link_single_channel.hjson
	$(MAKE) -C $(shell $(BENDER) path serial_link) update-regs
	touch $@

# Boot ROM (needs SW stack)
BROM_SRCS = $(wildcard hw/bootrom/*.S hw/bootrom/*.c) $(LIBS)

hw/bootrom/cheshire_bootrom.elf: hw/bootrom/cheshire_bootrom.ld $(BROM_SRCS)
	$(RISCV_CC) $(INCLUDES) -T$< $(RISCV_LDFLAGS) -o $@ $(BROM_SRCS)

hw/bootrom/cheshire_bootrom.sv: hw/bootrom/cheshire_bootrom.bin util/gen_bootrom.py
	$(PYTHON3) util/gen_bootrom.py --sv-module cheshire_bootrom $< > $@

hw-all: hw/regs/cheshire_reg_pkg.sv hw/regs/cheshire_reg_top.sv
hw-all: $(shell $(BENDER) path serial_link)/src/regs/.generated
hw-all: hw/bootrom/cheshire_bootrom.sv

##############
# Simulation #
##############

target/sim/vsim/compile.cheshire_soc.tcl: Bender.yml
	$(BENDER) script vsim -t sim -t cv64a6_imafdc_sv39 -t test -t cva6 --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "../src/elfloader.cpp" -ccflags "-std=c++11"' >> $@

sim-all: target/sim/vsim/compile.cheshire_soc.tcl

#############
# FPGA Flow #
#############

target/xilinx/scripts/add_sources.tcl: Bender.yml
	$(BENDER) script vivado -t fpga -t cv64a6_imafdc_sv39 -t cva6 > $@

xilinx-all: target/xilinx/scripts/add_sources.tcl

####################
# License Checking #
####################

licence-check: ./util/licence-checker.hjson
	$(PYTHON) util/lowrisc_misc-linters/licence-checker/licence-checker.py -v --config $<
