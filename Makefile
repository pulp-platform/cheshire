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
VLOG_ARGS   ?= -suppress 2583 -suppress 13314
VSIM        ?= vsim

.PHONY: all nonfree-init sw-all hw-all bootrom-all sim-all xilinx-all

all: sw-all hw-all sim-all xilinx-all

######################
# Nonfree components #
######################

NONFREE_REMOTE ?= git@iis-git.ee.ethz.ch:pulp-restricted/cheshire-nonfree.git
NONFREE_COMMIT ?= 9d0d14b94fb6ca7e2895809add461bd8a6ff35bb

nonfree-init:
	git clone $(NONFREE_REMOTE) nonfree
	cd nonfree && git checkout $(NONFREE_COMMIT)

-include nonfree/nonfree.mk

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

# CLINT
include $(shell $(BENDER) path clint)/clint.mk
$(shell $(BENDER) path clint)/.generated: Bender.yml
	$(MAKE) clint
	touch $@

# OpenTitan peripherals
include $(shell $(BENDER) path opentitan_peripherals)/otp.mk
$(shell $(BENDER) path opentitan_peripherals)/.generated: Bender.yml
	$(MAKE) otp
	touch $@

# AXI VGA
include $(shell $(BENDER) path axi_vga)/axi_vga.mk
$(shell $(BENDER) path axi_vga)/.generated: Bender.yml
	$(MAKE) axi_vga
	touch $@

# Custom serial link
$(shell $(BENDER) path serial_link)/.generated: hw/serial_link.hjson
	cp $< $(dir $@)/src/regs/serial_link_single_channel.hjson
	$(MAKE) -C $(shell $(BENDER) path serial_link) update-regs
	touch $@

hw-all: hw/regs/cheshire_reg_pkg.sv hw/regs/cheshire_reg_top.sv
hw-all: $(shell $(BENDER) path clint)/.generated
hw-all: $(shell $(BENDER) path opentitan_peripherals)/.generated
hw-all: $(shell $(BENDER) path axi_vga)/.generated
hw-all: $(shell $(BENDER) path serial_link)/.generated

#####################
# Generate Boot ROM #
#####################

# This is *not* done as part of `all` as it is only reproducible with a specific compiler

# Boot ROM (needs SW stack)
BROM_SRCS = $(wildcard hw/bootrom/*.S hw/bootrom/*.c) $(LIBS)

hw/bootrom/cheshire_bootrom.elf: hw/bootrom/cheshire_bootrom.ld $(BROM_SRCS)
	$(RISCV_CC) $(INCLUDES) -T$< $(RISCV_LDFLAGS) -o $@ $(BROM_SRCS)

hw/bootrom/cheshire_bootrom.sv: hw/bootrom/cheshire_bootrom.bin util/gen_bootrom.py
	$(PYTHON3) util/gen_bootrom.py --sv-module cheshire_bootrom $< > $@

bootrom-all: hw/bootrom/cheshire_bootrom.sv

##############
# Simulation #
##############

target/sim/vsim/compile.cheshire_soc.tcl: Bender.yml
	$(BENDER) script vsim -t sim -t cv64a6_imafdc_sv39 -t test -t cva6 --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "$(CURDIR)/target/sim/src/elfloader.cpp" -ccflags "-std=c++11"' >> $@

sim-all: target/sim/vsim/compile.cheshire_soc.tcl

#############
# FPGA Flow #
#############

target/xilinx/scripts/add_sources.tcl: Bender.yml
	$(BENDER) script vivado -t fpga -t cv64a6_imafdc_sv39 -t cva6 > $@

xilinx-all: target/xilinx/scripts/add_sources.tcl
