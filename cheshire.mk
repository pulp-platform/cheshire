# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

BENDER        ?= bender
PYTHON3       ?= python3
REGGEN        ?= $(PYTHON3) $(shell $(BENDER) path register_interface)/vendor/lowrisc_opentitan/util/regtool.py

CHE_ROOT ?= $(shell $(BENDER) path cheshire)

PLICOPT        = -s 20 -t 2 -p 7
VLOG_ARGS     ?= -suppress 2583 -suppress 13314
VSIM          ?= vsim

.PHONY: all nonfree-init sw-all hw-all bootrom-all sim-all xilinx-all

all: sw-all hw-all sim-all xilinx-all

######################
# Nonfree components #
######################

NONFREE_REMOTE ?= git@iis-git.ee.ethz.ch:pulp-restricted/cheshire-nonfree.git
NONFREE_COMMIT ?= 9d0d14b94fb6ca7e2895809add461bd8a6ff35bb

nonfree-init:
	git clone $(NONFREE_REMOTE) $(CHE_ROOT)/nonfree
	cd $(CHE_ROOT)/nonfree && git checkout $(NONFREE_COMMIT)

-include $(CHE_ROOT)/nonfree/nonfree.mk

############
# Build SW #
############

include $(CHE_ROOT)/sw/sw.mk

###############
# Generate HW #
###############

# SoC registers
$(CHE_ROOT)/hw/regs/cheshire_reg_pkg.sv $(CHE_ROOT)/hw/regs/cheshire_reg_top.sv: $(CHE_ROOT)/hw/regs/cheshire_regs.hjson
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
$(shell $(BENDER) path serial_link)/.generated: $(CHE_ROOT)/hw/serial_link.hjson
	cp $< $(dir $@)/src/regs/serial_link_single_channel.hjson
	$(MAKE) -C $(shell $(BENDER) path serial_link) update-regs
	touch $@

hw-all: $(CHE_ROOT)/hw/regs/cheshire_reg_pkg.sv $(CHE_ROOT)/hw/regs/cheshire_reg_top.sv
hw-all: $(shell $(BENDER) path clint)/.generated
hw-all: $(shell $(BENDER) path opentitan_peripherals)/.generated
hw-all: $(shell $(BENDER) path axi_vga)/.generated
hw-all: $(shell $(BENDER) path serial_link)/.generated

#####################
# Generate Boot ROM #
#####################

# This is *not* done as part of `all` as it is only reproducible with a specific compiler

# Boot ROM (needs SW stack)
BROM_SRCS = $(wildcard $(CHE_ROOT)/hw/bootrom/*.S $(CHE_ROOT)/hw/bootrom/*.c) $(LIBS)

$(CHE_ROOT)/hw/bootrom/cheshire_bootrom.elf: $(CHE_ROOT)/hw/bootrom/cheshire_bootrom.ld $(BROM_SRCS)
	$(RISCV_CC) $(INCLUDES) -T$< $(RISCV_LDFLAGS) -o $@ $(BROM_SRCS)

$(CHE_ROOT)/hw/bootrom/cheshire_bootrom.sv: $(CHE_ROOT)/hw/bootrom/cheshire_bootrom.bin util/gen_bootrom.py
	$(PYTHON3) util/gen_bootrom.py --sv-module cheshire_bootrom $< > $@

bootrom-all: $(CHE_ROOT)/hw/bootrom/cheshire_bootrom.sv

##############
# Simulation #
##############

$(CHE_ROOT)/target/sim/vsim/compile.cheshire_soc.tcl: Bender.yml
	$(BENDER) script vsim -t sim -t cv64a6_imafdc_sv39 -t test -t cva6 --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "$(CHE_ROOT)/target/sim/src/elfloader.cpp" -ccflags "-std=c++11"' >> $@

$(CHE_ROOT)/target/sim/models:
	mkdir -p $@

# Download (partially non-free) simulation models from publically available sources;
# by running these targets or targets depending on them, you accept this (see README.md).
$(CHE_ROOT)/target/sim/models/s25fs512s.sv: Bender.yml | $(CHE_ROOT)/target/sim/models
	wget --no-check-certificate https://freemodelfoundry.com/fmf_vlog_models/flash/s25fs512s.sv -O $@
	touch $@

$(CHE_ROOT)/target/sim/models/24FC1025.v: Bender.yml | $(CHE_ROOT)/target/sim/models
	wget https://ww1.microchip.com/downloads/en/DeviceDoc/24xx1025_Verilog_Model.zip -o $@
	unzip -p 24xx1025_Verilog_Model.zip 24FC1025.v > $@
	rm 24xx1025_Verilog_Model.zip

$(CHE_ROOT)/target/sim/models/uart_tb_rx.sv: Bender.yml | $(CHE_ROOT)/target/sim/models
	wget https://raw.githubusercontent.com/pulp-platform/pulp/v1.0/rtl/vip/uart_tb_rx.sv -O $@
	touch $@

sim-all: $(CHE_ROOT)/target/sim/models/s25fs512s.sv
sim-all: $(CHE_ROOT)/target/sim/models/24FC1025.v
sim-all: $(CHE_ROOT)/target/sim/models/uart_tb_rx.sv
sim-all: $(CHE_ROOT)/target/sim/vsim/compile.cheshire_soc.tcl

#############
# FPGA Flow #
#############

$(CHE_ROOT)/target/xilinx/scripts/add_sources.tcl: Bender.yml
	$(BENDER) script vivado -t fpga -t cv64a6_imafdc_sv39 -t cva6 > $@

xilinx-all: $(CHE_ROOT)/target/xilinx/scripts/add_sources.tcl
