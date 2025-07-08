# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Max Wipfli <mwipfli@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

CHS_VERILATOR_DIR ?= $(CHS_ROOT)/target/sim/verilator
RISCV_DBG_DIR = $(shell bender path riscv-dbg)

VERILATOR_PREFIX ?= oseda
VERILATOR        ?= verilator

# Silly Verilator warnings: these are perfectly valid and should not be warnings
VERILATOR_WNO   = -Wno-fatal -Wno-style \
	-Wno-BLKANDNBLK -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-WIDTHCONCAT -Wno-ASCRANGE
VERILATOR_ARGS  ?= -j 0 -Wall $(VERILATOR_WNO) -timescale 1ns/1ps
# Verilation optimizations
VERILATOR_ARGS += -O3 --x-assign fast --x-initial fast --noassert
# Disable common_cells assertions
VERILATOR_ARGS += -DASSERTS_OFF
# multithreading
VERILATOR_ARGS += --threads 8
# C++ Compiler Optimization
VERILATOR_ARGS += -CFLAGS "-O3" -CFLAGS "-march=native" -CFLAGS "-mtune=native"
# Use Clang (faster simulation than GCC)
VERILATOR_ARGS += --compiler clang -MAKEFLAGS "CC=clang" -MAKEFLAGS "CXX=clang++"

# Profiling
# generates `gmon.out` that can be processed by `gprof` and then `verilator_profcfunc`
# VERILATOR_ARGS += --prof-cfuncs --report-unoptflat

# Tracing
# enables VCD tracing of the topmost 5 layers
# VERILATOR_ARGS += --trace --trace-structs --no-trace-top --trace-depth 5

VERILATOR_CXX_SRCS = $(CHS_VERILATOR_DIR)/sim/main.cpp \
	$(CHS_ROOT)/target/sim/src/elfloader.cpp \
	$(RISCV_DBG_DIR)/tb/remote_bitbang/remote_bitbang.c \
	$(RISCV_DBG_DIR)/tb/remote_bitbang/sim_jtag.c

$(CHS_VERILATOR_DIR)/cheshire_soc.flist: $(CHS_ROOT)/Bender.yml
	$(BENDER) script verilator $(CHS_BENDER_RTL_FLAGS) > $@
	# TODO: Add verilator target for these upstream to avoid patch-in
	echo '$(shell $(BENDER) path axi)/src/axi_sim_mem.sv' >> $@

$(CHS_ROOT)/target/sim/verilator/obj_dir/Vcheshire_soc_wrapper: $(CHS_ROOT)/target/sim/verilator/cheshire_soc.flist $(VERILATOR_CXX_SRCS)
	+cd $(CHS_VERILATOR_DIR) && $(VERILATOR_PREFIX) $(VERILATOR) $(VERILATOR_ARGS) \
		-DASSERTS_OFF -f $< $(VERILATOR_CXX_SRCS) \
		--cc --exe --build --top-module cheshire_soc_wrapper

$(CHS_ROOT)/target/sim/verilator/cheshire_soc.vlt: $(CHS_ROOT)/target/sim/verilator/obj_dir/Vcheshire_soc_wrapper
	@echo "#!/bin/sh" > $@
	@echo 'set -eu' >> $@
	@echo 'cd $$(dirname "$$0")' >> $@
	@echo '$(VERILATOR_PREFIX) ./obj_dir/Vcheshire_soc_wrapper "$$@"' >> $@
	@chmod +x $@

