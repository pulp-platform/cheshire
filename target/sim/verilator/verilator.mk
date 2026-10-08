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
# C++ compiler for the model (`clang` or `gcc`); Clang builds simulate significantly faster
CHS_VLT_COMPILER  ?= clang
CHS_VLT_PROFDATA  ?= llvm-profdata

# Selected configuration from `tb_cheshire_pkg`; each configuration is a separate model
CHS_VLT_SELCFG  ?= 0
# Number of simulation threads; for good performance, pin them to CPUs sharing a last-level cache
CHS_VLT_THREADS ?= 1
# CPU list to pin simulations to with `taskset` (e.g. `16-19`), empty for no pinning
CHS_VLT_CPUS    ?=
# Set to 1 to build with waveform tracing support (enable at runtime with `+TRACE=<file>`)
CHS_VLT_TRACE     ?= 0
CHS_VLT_TRACE_FMT ?= fst
# Set to 1 to optimize the model with profile-guided optimization (requires Clang and built SW)
CHS_VLT_PGO      ?= 0
CHS_VLT_PGO_BINS ?= $(CHS_ROOT)/sw/tests/helloworld.dram.elf $(CHS_ROOT)/sw/tests/dma_2d.spm.elf

# Build variants use separate directories as build flags are not tracked by the generated makefiles
CHS_VLT_VARIANT  = cfg$(CHS_VLT_SELCFG)$(if $(filter-out 1,$(CHS_VLT_THREADS)),-t$(CHS_VLT_THREADS))
CHS_VLT_VARIANT := $(CHS_VLT_VARIANT)$(if $(filter gcc,$(CHS_VLT_COMPILER)),-gcc)
CHS_VLT_VARIANT := $(CHS_VLT_VARIANT)$(if $(filter 1,$(CHS_VLT_PGO)),-pgo)
CHS_VLT_VARIANT := $(CHS_VLT_VARIANT)$(if $(filter 1,$(CHS_VLT_TRACE)),-trace)
CHS_VLT_BUILD   ?= $(CHS_VLT_DIR)/build/$(CHS_VLT_VARIANT)
CHS_VLT_MODEL   := $(CHS_VLT_BUILD)/Vcheshire_top_verilator

CHS_VLT_RUN_PREFIX = $(if $(CHS_VLT_CPUS),taskset -c $(CHS_VLT_CPUS)) $(CHS_VLT_PREFIX)

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
ifeq ($(CHS_VLT_COMPILER),clang)
CHS_VLT_FLAGS += --compiler clang -MAKEFLAGS CXX=clang++ -MAKEFLAGS LINK=clang++
else ifneq ($(CHS_VLT_COMPILER),gcc)
$(error CHS_VLT_COMPILER must be `clang` or `gcc`)
endif
CHS_VLT_FLAGS += -MAKEFLAGS OPT_FAST=-O3
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
# are thus built only by their own targets. A stamp tracks the build flags.
CHS_VLT_STAMP := $(CHS_VLT_BUILD)/flags.stamp
CHS_VLT_DEPS   = $(CHS_VLT_STAMP) $(CHS_VLT_FLIST) chs-vlt-force

.PHONY: chs-vlt-force

#########
# Build #
#########

$(CHS_VLT_FLIST): $(CHS_ROOT)/Bender.yml $(CHS_ROOT)/Bender.lock
	$(BENDER) script verilator $(CHS_BENDER_RTL_FLAGS) > $@

# Generated makefiles do not track flags, so drop compiled objects whenever the flags change.
CHS_VLT_STAMP_TXT = $(CHS_VLT_PREFIX) $(CHS_VLT_VERILATOR) $(CHS_VLT_FLAGS) PGO=$(CHS_VLT_PGO)

.PHONY: chs-vlt-flags-check
$(CHS_VLT_STAMP): chs-vlt-flags-check
	@mkdir -p $(dir $@)
	@echo '$(CHS_VLT_STAMP_TXT)' | cmp -s - $@ || { \
		rm -rf $(CHS_VLT_BUILD)/*.o $(CHS_VLT_BUILD)/*.a $(CHS_VLT_BUILD)/pgo; \
		echo '$(CHS_VLT_STAMP_TXT)' > $@; }

# Verilate and compile a model; arguments: model path, additional Verilator flags
define chs_vlt_build
	mkdir -p $(dir $(1))
	$(CHS_VLT_PREFIX) $(CHS_VLT_VERILATOR) $(CHS_VLT_FLAGS) $(2) --Mdir $(dir $(1)) \
		-f $(CHS_VLT_FLIST) $(CHS_VLT_CXX_SRCS) -o $(notdir $(1))
endef

ifeq ($(CHS_VLT_PGO),1)
ifneq ($(CHS_VLT_COMPILER),clang)
$(error CHS_VLT_PGO requires CHS_VLT_COMPILER=clang)
endif

# Build an instrumented model, run it on training binaries, and use the collected profile
CHS_VLT_PGO_DIR  := $(CHS_VLT_BUILD)/pgo
CHS_VLT_PGO_GEN  := $(CHS_VLT_PGO_DIR)/obj/Vcheshire_top_verilator
CHS_VLT_PGO_DATA := $(CHS_VLT_PGO_DIR)/merged.profdata

CHS_VLT_PGO_GEN_FLAGS  = -CFLAGS -fprofile-generate=$(CHS_VLT_PGO_DIR)/raw
CHS_VLT_PGO_GEN_FLAGS += -LDFLAGS -fprofile-generate=$(CHS_VLT_PGO_DIR)/raw
CHS_VLT_PGO_USE_FLAGS  = -CFLAGS -fprofile-use=$(CHS_VLT_PGO_DATA)
CHS_VLT_PGO_USE_FLAGS += -CFLAGS -Wno-profile-instr-unprofiled -CFLAGS -Wno-profile-instr-out-of-date

$(CHS_VLT_PGO_GEN): $(CHS_VLT_DEPS)
	$(call chs_vlt_build,$@,$(CHS_VLT_PGO_GEN_FLAGS))

$(CHS_VLT_PGO_DATA): $(CHS_VLT_PGO_GEN) $(CHS_VLT_PGO_BINS)
	rm -rf $(CHS_VLT_PGO_DIR)/raw
	$(foreach bin,$(CHS_VLT_PGO_BINS),cd $(CHS_VLT_PGO_DIR) && $(CHS_VLT_RUN_PREFIX) $< +PRELMODE=1 +BINARY=$(bin) > $(notdir $(bin)).log &&) true
	$(CHS_VLT_PREFIX) $(CHS_VLT_PROFDATA) merge -output=$@ $(CHS_VLT_PGO_DIR)/raw/*.profraw

$(CHS_VLT_MODEL): $(CHS_VLT_DEPS) $(CHS_VLT_PGO_DATA)
	$(call chs_vlt_build,$@,$(CHS_VLT_PGO_USE_FLAGS))
else
$(CHS_VLT_MODEL): $(CHS_VLT_DEPS)
	$(call chs_vlt_build,$@,)
endif

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
	cd $(CHS_VLT_DIR) && $(CHS_VLT_RUN_PREFIX) $(CHS_VLT_MODEL) $(CHS_VLT_PLUSARGS)

CHS_PHONY += chs-vlt-clean
chs-vlt-clean:
	rm -rf $(CHS_VLT_DIR)/build $(CHS_VLT_FLIST)
