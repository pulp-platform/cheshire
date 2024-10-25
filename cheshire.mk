# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

BENDER ?= bender

VLOGAN_BIN ?= vlogan

# Caution: Questasim requires this to point to the *actual* compiler install path
CXX_PATH := $(shell which $(CXX))

VLOG_ARGS   ?= -suppress 2583 -suppress 13314 -timescale 1ns/1ps
VLOGAN_ARGS ?= -kdb -assert svaext +v2k -timescale=1ns/1ps

# Define used paths (prefixed to avoid name conflicts)
CHS_ROOT      ?= $(shell $(BENDER) path cheshire)
CHS_REG_DIR   := $(shell $(BENDER) path register_interface)
CHS_SLINK_DIR := $(shell $(BENDER) path serial_link)
CHS_LLC_DIR   := $(shell $(BENDER) path axi_llc)

# Define paths used in dependencies
OTPROOT           := $(shell $(BENDER) path opentitan_peripherals)
CLINTROOT         := $(shell $(BENDER) path clint)
AXIRTROOT         := $(shell $(BENDER) path axi_rt)
AXI_VGA_ROOT      := $(shell $(BENDER) path axi_vga)
IDMA_ROOT         := $(shell $(BENDER) path idma)
DRAM_RTL_SIM_ROOT := $(shell $(BENDER) path dram_rtl_sim)

REGTOOL ?= $(CHS_REG_DIR)/vendor/lowrisc_opentitan/util/regtool.py

################
# Dependencies #
################

BENDER_ROOT ?= $(CHS_ROOT)/.bender

# Ensure both Bender dependencies and (essential) submodules are checked out
$(BENDER_ROOT)/.chs_deps:
	$(BENDER) checkout
	cd $(CHS_ROOT) && git submodule update --init --recursive sw/deps/printf
	@touch $@

# Make sure dependencies are more up-to-date than any targets run
ifeq ($(shell test -f $(BENDER_ROOT)/.chs_deps && echo 1),)
-include $(BENDER_ROOT)/.chs_deps
endif

# Running this target will reset dependencies (without updating the checked-in Bender.lock)
CHS_PHONY += chs-clean-deps
chs-clean-deps:
	rm -rf .bender
	cd $(CHS_ROOT) && rm -rf target/sim/models target/sim/dramsys
	cd $(CHS_ROOT) && git submodule deinit -f sw/deps/*

######################
# Nonfree components #
######################

CHS_NONFREE_REMOTE ?= git@iis-git.ee.ethz.ch:pulp-restricted/cheshire-nonfree.git
CHS_NONFREE_COMMIT ?= f731b17

CHS_PHONY += chs-nonfree-init
chs-nonfree-init:
	git clone $(CHS_NONFREE_REMOTE) $(CHS_ROOT)/nonfree
	cd $(CHS_ROOT)/nonfree && git checkout $(CHS_NONFREE_COMMIT)

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
	$(REGTOOL) -r $< --outdir $(dir $@)

# CLINT
CLINTCORES ?= 1
include $(CLINTROOT)/clint.mk
$(CLINTROOT)/.generated:
	flock -x $@ $(MAKE) clint && touch $@

# OpenTitan peripherals
include $(OTPROOT)/otp.mk
$(OTPROOT)/.generated: $(CHS_ROOT)/hw/rv_plic.cfg.hjson
	flock -x $@ sh -c "cp $< $(dir $@)/src/rv_plic/; $(MAKE) -j1 otp" && touch $@

# AXI RT
AXIRT_NUM_MGRS ?= 8
AXIRT_NUM_SUBS ?= 2
include $(AXIRTROOT)/axirt.mk
$(AXIRTROOT)/.generated:
	flock -x $@ $(MAKE) axirt_regs && touch $@

# AXI VGA
include $(AXI_VGA_ROOT)/axi_vga.mk
$(AXI_VGA_ROOT)/.generated:
	flock -x $@ $(MAKE) axi_vga && touch $@

# Custom serial link
$(CHS_SLINK_DIR)/.generated: $(CHS_ROOT)/hw/serial_link.hjson
	cp $< $(dir $@)/src/regs/serial_link_single_channel.hjson
	flock -x $@ $(MAKE) -C $(CHS_SLINK_DIR) update-regs BENDER="$(BENDER)" && touch $@

CHS_HW_ALL += $(CHS_ROOT)/hw/regs/cheshire_reg_pkg.sv $(CHS_ROOT)/hw/regs/cheshire_reg_top.sv
CHS_HW_ALL += $(CLINTROOT)/.generated
CHS_HW_ALL += $(OTPROOT)/.generated
CHS_HW_ALL += $(AXIRTROOT)/.generated
CHS_HW_ALL += $(AXI_VGA_ROOT)/.generated
CHS_HW_ALL += $(CHS_SLINK_DIR)/.generated

#####################
# Generate Boot ROM #
#####################

# This is *not* done as part of `all` as it is only reproducible with a specific compiler

# Boot ROM (needs SW stack)
CHS_BROM_SRCS = $(wildcard $(CHS_ROOT)/hw/bootrom/*.S $(CHS_ROOT)/hw/bootrom/*.c) $(CHS_SW_LIBS)
CHS_BROM_FLAGS = $(CHS_SW_LDFLAGS) -Os -fno-zero-initialized-in-bss -flto -fwhole-program

$(CHS_ROOT)/hw/bootrom/cheshire_bootrom.elf: $(CHS_ROOT)/hw/bootrom/cheshire_bootrom.ld $(CHS_BROM_SRCS)
	$(CHS_SW_CC) $(CHS_SW_INCLUDES) -T$< $(CHS_BROM_FLAGS) -o $@ $(CHS_BROM_SRCS)

$(CHS_ROOT)/hw/bootrom/cheshire_bootrom.sv: $(CHS_ROOT)/hw/bootrom/cheshire_bootrom.bin $(CHS_ROOT)/util/gen_bootrom.py
	$(CHS_ROOT)/util/gen_bootrom.py --sv-module cheshire_bootrom $< > $@

CHS_BOOTROM_ALL += $(CHS_ROOT)/hw/bootrom/cheshire_bootrom.sv $(CHS_ROOT)/hw/bootrom/cheshire_bootrom.dump

##############
# Simulation #
##############

$(CHS_ROOT)/target/sim/vsim/compile.cheshire_soc.tcl: $(CHS_ROOT)/Bender.yml
	$(BENDER) script vsim -t sim -t cv64a6_imafdcsclic_sv39 -t test -t cva6 -t rtl --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "$(realpath $(CHS_ROOT))/target/sim/src/elfloader.cpp" -ccflags "-std=c++11" -cpppath "$(CXX_PATH)"' >> $@

$(CHS_ROOT)/target/sim/vcs/compile.cheshire_soc.sh: $(CHS_ROOT)/Bender.yml
	$(BENDER) script vcs -t sim -t cv64a6_imafdcsclic_sv39 -t test -t cva6 -t rtl --vlog-arg="$(VLOGAN_ARGS)" --vlogan-bin="$(VLOGAN_BIN)" > $@
	chmod +x $@

.PRECIOUS: $(CHS_ROOT)/target/sim/models
$(CHS_ROOT)/target/sim/models:
	mkdir -p $@

# Download (partially non-free) simulation models from publically available sources;
# by running these targets or targets depending on them, you accept this (see README.md).
$(CHS_ROOT)/target/sim/models/s25fs512s.v: $(CHS_ROOT)/Bender.yml | $(CHS_ROOT)/target/sim/models
	wget --no-check-certificate https://freemodelfoundry.com/fmf_vlog_models/flash/s25fs512s.v -O $@
	touch $@

$(CHS_ROOT)/target/sim/models/24FC1025.v: $(CHS_ROOT)/Bender.yml | $(CHS_ROOT)/target/sim/models
	wget https://ww1.microchip.com/downloads/en/DeviceDoc/24xx1025_Verilog_Model.zip -o $@
	unzip -p 24xx1025_Verilog_Model.zip 24FC1025.v > $@
	rm 24xx1025_Verilog_Model.zip

CHS_SIM_ALL += $(CHS_ROOT)/target/sim/models/s25fs512s.v
CHS_SIM_ALL += $(CHS_ROOT)/target/sim/models/24FC1025.v
CHS_SIM_ALL += $(CHS_ROOT)/target/sim/vsim/compile.cheshire_soc.tcl

###########
# DRAMSys #
###########

DRAMSYS_ROOT ?= $(CHS_ROOT)/target/sim/dramsys
include $(DRAM_RTL_SIM_ROOT)/dram_rtl_sim.mk

CHS_DRAMSYS_ALL += $(DRAMSYS_ROOT)/build/lib/libsystemc.so

#############
# FPGA Flow #
#############

include $(CHS_ROOT)/target/xilinx/xilinx.mk

#################################
# Phonies (KEEP AT END OF FILE) #
#################################

CHS_ALL += $(CHS_SW_ALL) $(CHS_HW_ALL) $(CHS_SIM_ALL)

chs-all:         $(CHS_ALL)
chs-sw-all:      $(CHS_SW_ALL)
chs-hw-all:      $(CHS_HW_ALL)
chs-bootrom-all: $(CHS_BOOTROM_ALL)
chs-sim-all:     $(CHS_SIM_ALL)
chs-dramsys-all: $(CHS_DRAMSYS_ALL)
chs-xilinx-all:  $(CHS_XILINX_ALL)

CHS_PHONY += chs-all chs-sw-all chs-hw-all chs-bootrom-all chs-sim-all chs-dramsys-all chs-xilinx-all

.PHONY: $(CHS_PHONY)
