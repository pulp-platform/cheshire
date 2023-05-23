# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Jannis Schönleber, ETH Zurich

VERILATOR_ROOT = $(CHS_ROOT)/target/verilator/install/verilator
VERILATOR_SRC_PATH = $(CHS_ROOT)/target/verilator/src
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator

RISCV = /usr/pack/riscv-1.0-kgf/riscv64-gcc-11.2.0

C_INCLUDE_PATH=${RISCV}/include
CPLUS_INCLUDE_PATH=${RISCV}/include
export C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH

BENDER 		?= bender	# https://github.com/pulp-platform/bender
MORTY			?= morty	# https://github.com/pulp-platform/morty

include $(CHS_ROOT)/target/verilator/tools.mk

VERILATOR_FLAGS += --cc --no-timing
VERILATOR_FLAGS += --error-limit 4419 --unroll-count 256 -Wno-fatal
VERILATOR_FLAGS += -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-WIDTHCONCAT -Wno-PINMISSING -Wno-MODDUP -Wno-UNOPTFLAT -Wno-BLKANDNBLK -Wno-UNUSED -Wno-ASCRANGE
VERILATOR_EXE += --exe cheshire.cpp

VERILATOR_CFILES += $(VERILATOR_SRC_PATH)/cheshire.cpp
VERILATOR_FESVR = -LDFLAGS "-L$(RISCV)/lib -Wl,-rpath,$(RISCV)/lib -lfesvr"

VERILATOR_OUTPUT = --Mdir $(CHS_ROOT)/target/verilator/obj_dir

BENDER = bender
BENDER_FLIST = bender script flist -t sim -t cv64a6_imafdc_sv39 -t test -t verilator -t cva6 -D VERILATOR=1 > flist.txt
BENDER_SCRIPT = $(shell bender script verilator -t sim -t cv64a6_imafdc_sv39 -t verilator -t cva6 -D VERILATOR=1)

# VERILATOR_INPUT = $(VERILATOR_SRC_PATH)/cheshire_testharness.sv
VERILATOR_TOPMODULE = --top-module cheshire_testharness

# Project variables
TOP_DESIGN	= cheshire_testharness
PICKLE_FILE := $(CHS_ROOT)/target/verilator/build/$(TOP_DESIGN).pickle.sv


$(CHS_ROOT)/target/verilator/build/sources.json:
	@mkdir -p $(@D)
	$(BENDER) sources -f -t sim -t cv64a6_imafdc_sv39 -t cva6 -t verilator > $@

chs-verilate-pickle: $(CHS_ROOT)/target/verilator/build/sources.json
	@mkdir -p $(@D)
	sed "s| << riscv::XLEN-2| << (riscv::XLEN-2)|g" $(shell $(BENDER) path cva6)/core/include/ariane_pkg.sv > ariane_pkg.tmp
	mv ariane_pkg.tmp $(shell $(BENDER) path cva6)/core/include/ariane_pkg.sv
	$(MORTY) -f $< -q -o $(PICKLE_FILE) -D VERILATOR=1 --keep_defines --top $(TOP_DESIGN)
	# applying patches
	cat $(CHS_ROOT)/target/verilator/patches/reg_bus_interface_ugly_copy.sv >> $(PICKLE_FILE)  	# Todo: fix REGBUS copy in morty
	sed -i "s/\s*req_q <= (store_req_t'.*/      req_q <= (store_req_t'{mode: axi_llc_pkg::tag_mode_e'(2'b0), default: '0});/g" $(PICKLE_FILE)
	patch -u $(PICKLE_FILE) -i $(CHS_ROOT)/target/verilator/patches/permutations.patch

chs-verilate-command := \
	$(VERILATOR) \
	$(VERILATOR_FLAGS) \
	$(VERILATOR_FESVR) \
	$(PICKLE_FILE) \
	$(VERILATOR_INPUT) \
	$(VERILATOR_TOPMODULE) \
	$(VERILATOR_EXE) \
	$(VERILATOR_CFILES) \
	$(VERILATOR_OUTPUT)

chs-verilate: chs-verilate-pickle
	rm -rf $(CHS_ROOT)/target/verilator/obj_dir 
	$(chs-verilate-command)
	cd $(CHS_ROOT)/target/verilator/obj_dir && $(MAKE) -f Vcheshire_testharness.mk Vcheshire_testharness

chs-verilate-run: chs-verilate
	$(CHS_ROOT)/target/verilator/obj_dir/Vcheshire_testharness
