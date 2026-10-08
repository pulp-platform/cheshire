# Copyright 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Enrico Zelioli <ezelioli@iis.ee.ethz.ch>
#
# Based on prior work by Max Wipfli <mwipfli@student.ethz.ch>
# and Paul Scheffler <paulsc@iis.ee.ethz.ch>.

CHS_VLT_DIR := $(CHS_ROOT)/target/sim/verilator

# Optional command prefix to run Verilator and the built model, e.g. in a container
CHS_VLT_PREFIX    ?=
CHS_VLT_VERILATOR ?= verilator

# Selected configuration from `tb_cheshire_pkg`; each configuration is a separate model
CHS_VLT_SELCFG  ?= 0
# Number of simulation threads
CHS_VLT_THREADS ?= 1
# Set to 1 to build with waveform tracing support (enable at runtime with `+TRACE=<file>`)
CHS_VLT_TRACE     ?= 0
CHS_VLT_TRACE_FMT ?= fst

CHS_VLT_BUILD ?= $(CHS_VLT_DIR)/build/cfg$(CHS_VLT_SELCFG)$(if $(filter 1,$(CHS_VLT_TRACE)),-trace)
CHS_VLT_MODEL := $(CHS_VLT_BUILD)/Vcheshire_top_verilator

#############
# Arguments #
#############

# Additional user arguments to Verilator
CHS_VLT_ARGS ?=

CHS_VLT_FLAGS  = --cc --exe --build -j 0 --top-module cheshire_top_verilator
CHS_VLT_FLAGS += -GSelectedCfg=$(CHS_VLT_SELCFG) -timescale 1ns/1ps
CHS_VLT_FLAGS += -Wno-fatal -Wno-lint -Wno-style -Wno-MULTIDRIVEN -Wno-UNOPTFLAT
CHS_VLT_FLAGS += $(CHS_VLT_DIR)/config.vlt
# Build without assertions, including the common_cells assertion macros (`ASSERTS_OFF`)
CHS_VLT_FLAGS += --noassert -DASSERTS_OFF
# Leave out CVA6's built-in commit trace, which logs every instruction to a file
CHS_VLT_FLAGS += -DCVA6_NO_LEGACY_TRACE
# Deterministic initialization and X-assignment
CHS_VLT_FLAGS += --x-assign 0 --x-initial 0
CHS_VLT_FLAGS += -O3 --threads $(CHS_VLT_THREADS)
CHS_VLT_FLAGS += -CFLAGS "-std=c++17 -I$(CHS_ROOT)/target/sim/src"
ifeq ($(CHS_VLT_TRACE),1)
CHS_VLT_FLAGS += --trace-$(CHS_VLT_TRACE_FMT) --trace-structs
endif
CHS_VLT_FLAGS += $(CHS_VLT_ARGS)

###########
# Sources #
###########

CHS_VLT_FLIST    := $(CHS_VLT_DIR)/cheshire.flist
CHS_VLT_CXX_SRCS := $(CHS_VLT_DIR)/src/main.cpp $(CHS_ROOT)/target/sim/src/elfloader.cpp

# The model recipe always runs and leaves change detection to Verilator, which re-verilates only
# when its inputs or arguments change (`--skip-identical`, the default with `--cc`), and to its
# generated makefile, which recompiles only changed objects. Generated sources such as the boot ROM
# are thus built only by their own targets.
CHS_VLT_DEPS = $(CHS_VLT_FLIST) chs-vlt-force

.PHONY: chs-vlt-force

#########
# Build #
#########

$(CHS_VLT_FLIST): $(CHS_ROOT)/Bender.yml $(CHS_ROOT)/Bender.lock
	$(BENDER) script verilator $(CHS_BENDER_RTL_FLAGS) > $@

$(CHS_VLT_MODEL): $(CHS_VLT_DEPS)
	mkdir -p $(CHS_VLT_BUILD)
	$(CHS_VLT_PREFIX) $(CHS_VLT_VERILATOR) $(CHS_VLT_FLAGS) --Mdir $(CHS_VLT_BUILD) \
		-f $(CHS_VLT_FLIST) $(CHS_VLT_CXX_SRCS) -o $(notdir $@)

CHS_SIM_ALL += $(CHS_VLT_FLIST)
CHS_VLT_ALL += $(CHS_VLT_MODEL)

#######
# Run #
#######

# Runtime options as for the VCS and Questa flows; further plusargs in `CHS_VLT_RUN_ARGS`
CHS_VLT_RUN_ARGS ?=

CHS_VLT_PLUSARGS  = $(if $(BOOTMODE),+BOOTMODE=$(BOOTMODE))
CHS_VLT_PLUSARGS += $(if $(PRELMODE),+PRELMODE=$(PRELMODE))
CHS_VLT_PLUSARGS += $(if $(BINARY),+BINARY=$(abspath $(BINARY)))
CHS_VLT_PLUSARGS += $(if $(IMAGE),+IMAGE=$(abspath $(IMAGE)))
CHS_VLT_PLUSARGS += $(CHS_VLT_RUN_ARGS)

CHS_PHONY += chs-vlt-run
chs-vlt-run: $(CHS_VLT_MODEL)
	cd $(CHS_VLT_DIR) && $(CHS_VLT_PREFIX) $(CHS_VLT_MODEL) $(CHS_VLT_PLUSARGS)

CHS_PHONY += chs-vlt-clean
chs-vlt-clean:
	rm -rf $(CHS_VLT_DIR)/build $(CHS_VLT_FLIST)
