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


CHS_ROOT ?= $(shell $(BENDER) path cheshire)

PLICOPT        = -s 20 -t 2 -p 7
VLOG_ARGS     ?= -suppress 2583 -suppress 13314
VSIM          ?= vsim

.PHONY: chs-all chs-nonfree-init chs-sw-all chs-hw-all chs-bootrom-all chs-sim-all chs-xilinx-all

chs-all: chs-sw-all chs-hw-all chs-sim-all chs-xilinx-all

######################
# Nonfree components #
######################

NONFREE_REMOTE ?= git@iis-git.ee.ethz.ch:pulp-restricted/cheshire-nonfree.git
NONFREE_COMMIT ?= 96113a975f56b5ad1b61593ea48d125a2803dfcd

chs-nonfree-init:
	git clone $(NONFREE_REMOTE) $(CHS_ROOT)/nonfree
	cd $(CHS_ROOT)/nonfree && git checkout $(NONFREE_COMMIT)

-include $(CHS_ROOT)/nonfree/nonfree.mk

############
# Build SW #
############

include $(CHS_ROOT)/sw/sw.mk

###############
# Generate HW #
###############

# SoC registers

$(CHS_ROOT)/hw/regs/cheshire_reg_pkg.sv $(CHS_ROOT)/hw/regs/cheshire_reg_top.sv: $(CHS_ROOT)/hw/regs/cheshire_regs.hjson
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
$(shell $(BENDER) path serial_link)/.generated: $(CHS_ROOT)/hw/serial_link.hjson

	cp $< $(dir $@)/src/regs/serial_link_single_channel.hjson
	$(MAKE) -C $(shell $(BENDER) path serial_link) update-regs
	touch $@

chs-hw-all: $(CHS_ROOT)/hw/regs/cheshire_reg_pkg.sv $(CHS_ROOT)/hw/regs/cheshire_reg_top.sv
chs-hw-all: $(shell $(BENDER) path clint)/.generated
chs-hw-all: $(shell $(BENDER) path opentitan_peripherals)/.generated
chs-hw-all: $(shell $(BENDER) path axi_vga)/.generated
chs-hw-all: $(shell $(BENDER) path serial_link)/.generated

#####################
# Generate Boot ROM #
#####################

# This is *not* done as part of `all` as it is only reproducible with a specific compiler

# Boot ROM (needs SW stack)
BROM_SRCS = $(wildcard $(CHS_ROOT)/hw/bootrom/*.S $(CHS_ROOT)/hw/bootrom/*.c) $(CHS_SW_LIBS)

$(CHS_ROOT)/hw/bootrom/cheshire_bootrom.elf: $(CHS_ROOT)/hw/bootrom/cheshire_bootrom.ld $(BROM_SRCS)
	$(RISCV_CC) $(CHS_SW_INCLUDES) -T$< $(RISCV_LDFLAGS) -o $@ $(BROM_SRCS)

$(CHS_ROOT)/hw/bootrom/cheshire_bootrom.sv: $(CHS_ROOT)/hw/bootrom/cheshire_bootrom.bin $(CHS_ROOT)/util/gen_bootrom.py
	$(PYTHON3) $(CHS_ROOT)/util/gen_bootrom.py --sv-module cheshire_bootrom $< > $@

chs-bootrom-all: $(CHS_ROOT)/hw/bootrom/cheshire_bootrom.sv

##############
# Simulation #
##############


$(CHS_ROOT)/target/sim/vsim/compile.cheshire_soc.tcl: Bender.yml
	$(BENDER) script vsim -t sim -t cv64a6_imafdc_sv39 -t test -t cva6 --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "$(CURDIR)/$(CHS_ROOT)/target/sim/src/elfloader.cpp" -ccflags "-std=c++11"' >> $@

$(CHS_ROOT)/target/sim/models:
	mkdir -p $@

# Download (partially non-free) simulation models from publically available sources;
# by running these targets or targets depending on them, you accept this (see README.md).

$(CHS_ROOT)/target/sim/models/s25fs512s.sv: Bender.yml | $(CHS_ROOT)/target/sim/models
	wget --no-check-certificate https://freemodelfoundry.com/fmf_vlog_models/flash/s25fs512s.sv -O $@
	touch $@

$(CHS_ROOT)/target/sim/models/24FC1025.v: Bender.yml | $(CHS_ROOT)/target/sim/models
	wget https://ww1.microchip.com/downloads/en/DeviceDoc/24xx1025_Verilog_Model.zip -o $@
	unzip -p 24xx1025_Verilog_Model.zip 24FC1025.v > $@
	rm 24xx1025_Verilog_Model.zip

$(CHS_ROOT)/target/sim/models/uart_tb_rx.sv: Bender.yml | $(CHS_ROOT)/target/sim/models
	wget https://raw.githubusercontent.com/pulp-platform/pulp/v1.0/rtl/vip/uart_tb_rx.sv -O $@
	touch $@

chs-sim-all: $(CHS_ROOT)/target/sim/models/s25fs512s.sv
chs-sim-all: $(CHS_ROOT)/target/sim/models/24FC1025.v
chs-sim-all: $(CHS_ROOT)/target/sim/models/uart_tb_rx.sv
chs-sim-all: $(CHS_ROOT)/target/sim/vsim/compile.cheshire_soc.tcl


#############
# FPGA Flow #
#############

$(CHS_ROOT)/target/xilinx/scripts/add_sources.tcl: Bender.yml
	$(BENDER) script vivado -t fpga -t cv64a6_imafdc_sv39 -t cva6 > $@

chs-xilinx-all: $(CHS_ROOT)/target/xilinx/scripts/add_sources.tcl
