# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Max Wipfli <mwipfli@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

# TODO: Silly OSEDA container sets VERILATOR variable...
VERILATOR_PREFIX ?= oseda
VERILATOR        ?= /usr/scratch/kneiff/vlupd/verilator/install/bin/verilator

CHS_VLT_DIR      ?= $(CHS_ROOT)/target/verilator

CHS_VLT_THREADS  ?= 5

#############
# Arguments #
#############

CHS_VLT_ARGS  = -j 0 -timescale 1ns/1ps

# Make warnings nonfatal and ignore opinionated warnings
CHS_VLT_ARGS += -Wall -Wno-fatal -Wno-style
CHS_VLT_ARGS += -Wno-BLKANDNBLK -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-WIDTHCONCAT -Wno-ASCRANGE

# Disable common_cells assertions and tracing
CHS_VLT_ARGS += -DASSERTS_OFF -DCVA6_NO_TRACE

# Use Clang (faster simulation than GCC)
CHS_VLT_ARGS += --compiler clang -MAKEFLAGS "CC=clang" -MAKEFLAGS "CXX=clang++" -MAKEFLAGS "LINK=clang++"

# Optimization
CHS_VLT_ARGS += -O3 --x-assign 0 --x-initial 0 --noassert
CHS_VLT_ARGS += --threads $(CHS_VLT_THREADS)
CHS_VLT_ARGS += -CFLAGS "-O3" -CFLAGS "-march=native" -CFLAGS "-mtune=native"
CHS_VLT_ARGS += -CFLAGS "-flto" -LDFLAGS "-flto"

#CHS_VLT_ARGS += --debug --gdbbt

###############
# CXX Sources #
###############

CHS_VLT_CXX_INCS  = -CFLAGS "-I$(CHS_ROOT)/target/sim/src/"
CHS_VLT_CXX_INCS += -CFLAGS "-I$(CHS_VLT_DIR)/vendor/tcp_server/"

CHS_VLT_CXX_SRCS  = $(CHS_ROOT)/target/sim/src/elfloader.cpp
CHS_VLT_CXX_SRCS += $(CHS_VLT_DIR)/vendor/tcp_server/tcp_server.c
CHS_VLT_CXX_SRCS += $(CHS_VLT_DIR)/vendor/uart/uartdpi.c
CHS_VLT_CXX_SRCS += $(CHS_VLT_DIR)/vendor/jtag/jtagdpi.c
CHS_VLT_CXX_SRCS += $(CHS_VLT_DIR)/src/main.cpp

#########
# Build #
#########

$(CHS_VLT_DIR)/cheshire_soc.flist: $(CHS_ROOT)/Bender.yml
	$(BENDER) script verilator $(CHS_BENDER_RTL_FLAGS) > $@

$(CHS_VLT_DIR)/obj_dir/Vcheshire_top_verilator: $(CHS_VLT_DIR)/cheshire_soc.flist $(CHS_VLT_CXX_SRCS)
	cd $(CHS_VLT_DIR) && $(VERILATOR_PREFIX) $(VERILATOR) $(CHS_VLT_ARGS) $(CHS_VLT_CXX_INCS) \
		-f $< $(CHS_VLT_CXX_SRCS)  --cc --exe --build --top-module cheshire_top_verilator

$(CHS_VLT_DIR)/cheshire_soc.vlt: $(CHS_VLT_DIR)/obj_dir/Vcheshire_top_verilator
	@echo "#!/bin/sh" > $@
	@echo 'set -eu' >> $@
	@echo 'cd $$(dirname "$$0")' >> $@
	@echo 'taskset -c 0-$(shell expr $(CHS_VLT_THREADS) - 1) $(VERILATOR_PREFIX) "$<" "$$@"' >> $@
	@chmod +x $@

CHS_VLT_ALL = $(CHS_VLT_DIR)/cheshire_soc.vlt
