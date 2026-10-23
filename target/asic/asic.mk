# Copyright 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Technology-agnostic part of the ASIC implementation flow. Technologies live
# in subdirectories of this target and only add what is specific to them.

CHS_ASIC_DIR    ?= $(CHS_ROOT)/target/asic
CHS_ASIC_BUILD  ?= $(CHS_ASIC_DIR)/build

# Python tools come from Cheshire's uv environment (`uv run make ...`)
CHS_ASIC_INVENTORY ?= $(CHS_ASIC_DIR)/scripts/inventory.py

# Technology: a subdirectory of this target
CHS_ASIC_TECH ?= gf22

# Implementation configuration: index into `AsicCfgs` in cheshire_asic_pkg.sv
CHS_ASIC_CFG ?= 0

# Synthesis knobs common to all technologies; the system clock period
# CHS_ASIC_CLK_PERIOD [ps] defaults per technology (see below)
CHS_ASIC_THREADS        ?= 8
# Constraint parameters to override, as NAME=value (see the defaults in
# constraints/cheshire_asic.sdc), e.g. CHS_ASIC_ONCHIP_EXT_FRAC=0.2
CHS_ASIC_SDC_PARAMS     ?=

# Bender flags selecting the ASIC source set
CHS_ASIC_BENDER_FLAGS ?= -t asic -t synthesis -t chs_asic $(CHS_BENDER_RTL_FLAGS)

# slang arguments emulating a synthesis frontend, which accepts implicit enum
# conversions (e.g. CVA6 privilege levels) and use before declaration
CHS_ASIC_SLANG_ARGS ?= --top cheshire_asic_top -D SYNTHESIS --timescale 1ns/1ps \
	--allow-use-before-declare --relax-enum-conversions \
	--translate-off-format pragma,translate_off,translate_on \
	--translate-off-format synopsys,translate_off,translate_on

#############
# Inventory #
#############

# List SRAM shapes, tech cells, and crossings of the selected configuration.
# Cheap enough to always rerun, as it depends on every RTL source. Generated
# hardware is required: e.g. the PLIC source count sizes the interrupt system.
#
# The generic tech cells stand in for those of a technology, so the inventory
# elaborates the exact ASIC source set without depending on any technology.
# Its file list holds absolute paths, which depend on where the tree is mounted
# (e.g. over NFS on another host): each run generates and uses its own, then
# keeps it as `inventory.flist` for reference.
CHS_PHONY += chs-asic-inventory
chs-asic-inventory: $(CHS_HW_ALL)
	mkdir -p $(CHS_ASIC_BUILD)
	flist=$(CHS_ASIC_BUILD)/inventory.flist.$$$$; \
	$(BENDER) script flist-plus $(CHS_ASIC_BENDER_FLAGS) \
		-t tech_cells_generic_include_tc_sram \
		-t tech_cells_generic_include_tc_clk \
		-t tech_cells_generic_include_tc_sync > $$flist && \
	$(CHS_ASIC_INVENTORY) \
		--json $(CHS_ASIC_BUILD)/inventory.cfg$(CHS_ASIC_CFG).json \
		-f $$flist -D CHS_ASIC_CFG=$(CHS_ASIC_CFG) $(CHS_ASIC_SLANG_ARGS); \
	rc=$$?; mv -f $$flist $(CHS_ASIC_BUILD)/inventory.flist; exit $$rc

# Shell command printing the number of SRAMs of the selected configuration,
# which technologies check their memory macros against
CHS_ASIC_NUM_SRAMS_CMD = python3 -c 'import json, sys; print(len(json.load(open(sys.argv[1]))["srams"]))' \
	$(CHS_ASIC_BUILD)/inventory.cfg$(CHS_ASIC_CFG).json

################
# Technologies #
################

include $(CHS_ASIC_DIR)/gf22/gf22.mk

# System clock period [ps] where the technology sets no default
CHS_ASIC_CLK_PERIOD ?= 1500

# Read, link, and constrain the design without synthesizing it
CHS_PHONY += chs-asic-elab
chs-asic-elab: chs-asic-$(CHS_ASIC_TECH)-elab

# Synthesize the design
CHS_PHONY += chs-asic-synth
chs-asic-synth: chs-asic-$(CHS_ASIC_TECH)-synth

# Place and route the synthesized design
CHS_PHONY += chs-asic-pnr
chs-asic-pnr: chs-asic-$(CHS_ASIC_TECH)-pnr

##############
# Simulation #
##############

# Simulation of cheshire_asic_top in Cheshire's VIP with Questa
# (sim/vsim/chs_asic_sim.tcl; testbench in sim/src): the RTL top, or a netlist
# of it (CHS_ASIC_SIM_NETLIST) with the technology's simulation models, compiled
# into the library `gate` by a script of its makefile
# (chs-asic-<tech>-sim-models writes $(CHS_ASIC_SIM_DIR)/models.tcl), without
# delays or with those of an SDF (CHS_ASIC_SIM_SDF). The clock runs at the
# implemented period, so that recorded activity has its toggle rates.
CHS_ASIC_VSIM         ?= vsim
CHS_ASIC_SIM_DIR      ?= $(CHS_ASIC_BUILD)/sim
CHS_ASIC_SIM_NETLIST  ?=
CHS_ASIC_SIM_BINARY   ?= $(CHS_ROOT)/sw/tests/helloworld.dram.elf
CHS_ASIC_SIM_BOOTMODE ?= 0
# memh: the program is written into the DRAM model directly, without simulated time
CHS_ASIC_SIM_PRELMODE ?= 3
# Time unit 1 ps: the VIP's clock generator takes its period in whole time
# units, so the implemented period (CHS_ASIC_CLK_PERIOD, in ps) is exact
CHS_ASIC_SIM_VLOG_ARGS ?= -suppress 2583 -suppress 13314 -timescale 1ps/1ps
# File of further vopt arguments for netlists, if the technology needs any (its
# makefile sets it; chs-asic-<tech>-sim-models writes the file)
CHS_ASIC_SIM_GATE_VOPT ?=
# 1: record the switching activity of each workload phase (SAIF), see sim/vsim
CHS_ASIC_SIM_SAIF ?= 0
# SDF of the netlist: the netlist then simulates with the cell and interconnect
# delays of the SDF's typical field
CHS_ASIC_SIM_SDF ?=

# Cheshire's RTL, VIP and testbench, with the generic technology cells
$(CHS_ASIC_SIM_DIR)/compile.tcl: $(CHS_ROOT)/Bender.yml $(CHS_ROOT)/Bender.lock
	mkdir -p $(@D)
	$(BENDER) script vsim -t sim -t test -t chs_asic $(CHS_BENDER_RTL_FLAGS) \
		-D CHS_ASIC_CFG=$(CHS_ASIC_CFG) --vlog-arg="$(CHS_ASIC_SIM_VLOG_ARGS)" > $@
	echo 'vlog "$(realpath $(CHS_ROOT))/target/sim/src/elfloader.cpp" -ccflags "-std=c++11" -cpppath "$(CXX_PATH)"' >> $@

CHS_PHONY += chs-asic-sim
chs-asic-sim: $(CHS_ASIC_SIM_DIR)/compile.tcl \
		$(if $(CHS_ASIC_SIM_NETLIST),chs-asic-$(CHS_ASIC_TECH)-sim-models)
	cd $(CHS_ASIC_SIM_DIR) && $(CHS_ASIC_VSIM) -c -do " \
		set CHS_SIM_COMPILE $(CHS_ASIC_SIM_DIR)/compile.tcl; \
		set CHS_SIM_NETLIST {$(CHS_ASIC_SIM_NETLIST)}; \
		set CHS_SIM_MODELS $(CHS_ASIC_SIM_DIR)/models.tcl; \
		set CHS_SIM_GATE_VOPT {$(CHS_ASIC_SIM_GATE_VOPT)}; \
		set CHS_SIM_BINARY $(CHS_ASIC_SIM_BINARY); \
		set CHS_SIM_BOOTMODE $(CHS_ASIC_SIM_BOOTMODE); \
		set CHS_SIM_PRELMODE $(CHS_ASIC_SIM_PRELMODE); \
		set CHS_SIM_CXX $(CXX_PATH); \
		set CHS_SIM_CLK_PERIOD $(CHS_ASIC_CLK_PERIOD); \
		set CHS_SIM_SAIF $(CHS_ASIC_SIM_SAIF); \
		set CHS_SIM_SDF {$(CHS_ASIC_SIM_SDF)}; \
		do $(CHS_ASIC_DIR)/sim/vsim/chs_asic_sim.tcl" 2>&1 | tee $(CHS_ASIC_SIM_DIR)/sim.log
