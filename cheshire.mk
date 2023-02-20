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

VLOG_ARGS   ?= -suppress 2583 -suppress 13314
VSIM        ?= vsim

# Define used paths (prefixed to avoid name conflicts)
CHS_ROOT      ?= $(shell $(BENDER) path cheshire)
CHS_SW_DIR     = $(CHS_ROOT)/sw
CHS_HW_DIR     = $(CHS_ROOT)/sw
CHS_OTP_DIR    = $(shell $(BENDER) path opentitan_peripherals)
CHS_CLINT_DIR  = $(shell $(BENDER) path clint)
CHS_SLINK_DIR  = $(shell $(BENDER) path serial_link)
CHS_VGA_DIR    = $(shell $(BENDER) path axi_vga)
CHS_LLC_DIR    = $(shell $(BENDER) path axi_llc)

.PHONY: all nonfree-init chs-sw-all chs-hw-all chs-bootrom-all chs-sim-all chs-xilinx-all

all: chs-sw-all chs-hw-all chs-sim-all chs-xilinx-all

################
# Dependencies #
################

# Ensure both Bender dependencies and submodules are checked out
.deps:
	$(BENDER) checkout
	git submodule update --init --recursive
	@touch $@

# Make sure this is done before any makefrags are included
%.mk: .deps

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
include $(CHS_CLINT_DIR)/clint.mk
$(CHS_CLINT_DIR)/.generated: Bender.yml
	$(MAKE) clint
	@touch $@

# OpenTitan peripherals
include $(CHS_OTP_DIR)/otp.mk
$(CHS_OTP_DIR)/.generated: hw/rv_plic.cfg.hjson Bender.yml
	cp $< $(dir $@)/src/rv_plic/
	$(MAKE) otp
	@touch $@

# AXI VGA
include $(CHS_VGA_DIR)/axi_vga.mk
$(CHS_VGA_DIR)/.generated: Bender.yml
	$(MAKE) axi_vga
	@touch $@

# Custom serial link
$(CHS_SLINK_DIR)/.generated: hw/serial_link.hjson
	cp $< $(dir $@)/src/regs/serial_link_single_channel.hjson
	$(MAKE) -C $(CHS_SLINK_DIR) update-regs
	@touch $@

chs-hw-all: hw/regs/cheshire_reg_pkg.sv hw/regs/cheshire_reg_top.sv
chs-hw-all: $(CHS_CLINT_DIR)/.generated
chs-hw-all: $(CHS_OTP_DIR)/.generated
chs-hw-all: $(CHS_VGA_DIR)/.generated
chs-hw-all: $(CHS_SLINK_DIR)/.generated

#####################
# Generate Boot ROM #
#####################

# This is *not* done as part of `all` as it is only reproducible with a specific compiler

# Boot ROM (needs SW stack)
CHS_BROM_SRCS = $(wildcard hw/bootrom/*.S hw/bootrom/*.c) $(CHS_SW_LIBS)
CHS_BROM_FLAGS = $(RISCV_LDFLAGS) -Os -fno-zero-initialized-in-bss -flto -fwhole-program -s

hw/bootrom/cheshire_bootrom.elf: hw/bootrom/cheshire_bootrom.ld $(CHS_BROM_SRCS)
	$(RISCV_CC) $(CHS_SW_INCLUDES) -T$< $(CHS_BROM_FLAGS) -o $@ $(CHS_BROM_SRCS)

hw/bootrom/cheshire_bootrom.sv: hw/bootrom/cheshire_bootrom.bin util/gen_bootrom.py
	$(PYTHON3) util/gen_bootrom.py --sv-module cheshire_bootrom $< > $@

chs-bootrom-all: hw/bootrom/cheshire_bootrom.sv

##############
# Simulation #
##############

target/sim/vsim/compile.cheshire_soc.tcl: Bender.yml
	$(BENDER) script vsim -t sim -t cv64a6_imafdc_sv39 -t test -t cva6 --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "$(CURDIR)/target/sim/src/elfloader.cpp" -ccflags "-std=c++11"' >> $@

target/sim/models:
	mkdir -p $@

# Download (partially non-free) simulation models from publically available sources;
# by running these targets or targets depending on them, you accept this (see README.md).
target/sim/models/s25fs512s.sv: Bender.yml | target/sim/models
	wget --no-check-certificate https://freemodelfoundry.com/fmf_vlog_models/flash/s25fs512s.sv -O $@
	touch $@

target/sim/models/24FC1025.v: Bender.yml | target/sim/models
	wget https://ww1.microchip.com/downloads/en/DeviceDoc/24xx1025_Verilog_Model.zip -o $@
	unzip -p 24xx1025_Verilog_Model.zip 24FC1025.v > $@
	rm 24xx1025_Verilog_Model.zip

target/sim/models/uart_tb_rx.sv: Bender.yml | target/sim/models
	wget https://raw.githubusercontent.com/pulp-platform/pulp/v1.0/rtl/vip/uart_tb_rx.sv -O $@
	touch $@

chs-sim-all: target/sim/models/s25fs512s.sv
chs-sim-all: target/sim/models/24FC1025.v
chs-sim-all: target/sim/models/uart_tb_rx.sv
chs-sim-all: target/sim/vsim/compile.cheshire_soc.tcl

#############
# FPGA Flow #
#############

target/xilinx/scripts/add_sources.tcl: Bender.yml
	$(BENDER) script vivado -t fpga -t cv64a6_imafdc_sv39 -t cva6 > $@

chs-xilinx-all: target/xilinx/scripts/add_sources.tcl
