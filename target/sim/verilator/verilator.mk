# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Max Wipfli <mwipfli@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

CHS_VERILATOR_DIR ?= $(CHS_ROOT)/target/sim/verilator
RISCV_DBG_DIR = $(shell bender path riscv-dbg)

VERILATOR = oseda verilator

VERILATOR_OPT     = -march=native -mtune=native -Wno-deprecated-experimental-coroutine
# Silly Verilator warnings: these are perfectly valid and should not be warnings
VERILATOR_WNO   = -Wno-fatal -Wno-style \
									-Wno-BLKANDNBLK -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-WIDTHCONCAT -Wno-ASCRANGE
VERILATOR_FIX   = --unroll-count 51 --unroll-stmts 1
VERILATOR_ARGS  ?= -j 0 -Wall --timing -timescale 1ns/1ns $(VERILATOR_WNO) $(VERILATOR_FIX) -O3 \
									 --trace-fst --trace-structs --trace-threads 1 --no-trace-top --trace-depth 5

VERILATOR_CXX_SRCS = $(CHS_VERILATOR_DIR)/sim/main.cpp \
										 $(RISCV_DBG_DIR)/tb/remote_bitbang/remote_bitbang.c \
										 $(RISCV_DBG_DIR)/tb/remote_bitbang/sim_jtag.c

$(CHS_VERILATOR_DIR)/cheshire_soc.flist: $(CHS_ROOT)/Bender.yml
	$(BENDER) script verilator $(CHS_BENDER_RTL_FLAGS) > $@
	# TODO: Add verilator target for these upstream to avoid patch-in
	echo '$(shell $(BENDER) path axi)/src/axi_sim_mem.sv' >> $@

$(CHS_ROOT)/target/sim/verilator/obj_dir/Vcheshire_soc_wrapper: $(CHS_ROOT)/target/sim/verilator/cheshire_soc.flist $(VERILATOR_CXX_SRCS)
	+cd $(CHS_VERILATOR_DIR) && $(VERILATOR) $(VERILATOR_ARGS) -DASSERTS_OFF -f $< $(VERILATOR_CXX_SRCS) \
		--cc --exe --build --top-module cheshire_soc_wrapper

$(CHS_ROOT)/target/sim/verilator/cheshire_soc.vlt: $(CHS_ROOT)/target/sim/verilator/obj_dir/Vcheshire_soc_wrapper
	@echo "#!/bin/sh" > $@
	@echo 'set -eu' >> $@
	@echo 'cd $$(dirname "$$0")' >> $@
	@echo 'oseda ./obj_dir/Vcheshire_soc_wrapper' >> $@
	@chmod +x $@

