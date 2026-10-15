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

# Synthesis knobs common to all technologies
CHS_ASIC_CLK_PERIOD     ?= 1500
CHS_ASIC_THREADS        ?= 8
CHS_ASIC_NO_AUTOUNGROUP ?= 0
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

# Read, link, and constrain the design without synthesizing it
CHS_PHONY += chs-asic-elab
chs-asic-elab: chs-asic-$(CHS_ASIC_TECH)-elab

# Synthesize the design
CHS_PHONY += chs-asic-synth
chs-asic-synth: chs-asic-$(CHS_ASIC_TECH)-synth

# Place and route the synthesized design
CHS_PHONY += chs-asic-pnr
chs-asic-pnr: chs-asic-$(CHS_ASIC_TECH)-pnr
