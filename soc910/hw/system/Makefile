# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nils Wistoff <nwistoff@iis.ee.ethz.ch>

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR  := $(dir $(MKFILE_PATH))
ROOT        := $(MKFILE_DIR)../..
VSIM_BUILDDIR := build-vsim

include $(ROOT)/util/Makefrag

FESVR ?= $(RISCV)
# By default assume spike resides at the RISCV prefix.
SPIKE_ROOT ?= $(RISCV)

QUESTA_64BIT	= -64
VSIM      		= vsim $(QUESTA_64BIT)
VLOG      		= vlog $(QUESTA_64BIT)

VSIM_FLAGS    += -t 1ps
VSIM_FLAGS    += -voptargs=+acc
VSIM_FLAGS    += -do "log -r /*; do wave.do; run -a"
# Downgraded from error as VSIM *wrongly* reports illegal enum assignments in riscv_dbg 4-phase CDCs
# TODO: Workaround; revise
VSIM_FLAGS    += -warning 8386

VLOG_FLAGS 	  += -svinputport=compat
VLOG_FLAGS 	  += -override_timescale 1ns/1ps
VLOG_FLAGS 	  += -suppress 2583
VLOG_FLAGS 	  += -suppress 13314
VLOG_FLAGS 	  += $(QUESTA_64BIT)

DPI_FLAGS := -I$(QUESTASIM_HOME)/include                      \
             -I$(VCS_HOME)/include                            \
             -I$(RISCV)/include                               \
             -I$(SPIKE_ROOT)/include                          \
             -std=c++11 -I../corev_apu/tb/dpi -O3
DPI_CXXFLAGS ?= $(CXXFLAGS) $(DPI_FLAGS) -D_GLIBCXX_USE_CXX11_ABI=0

DPI := $(MKFILE_DIR)/test/remote_bitbang.o $(MKFILE_DIR)/test/SimJTAG.o

$(VSIM_BUILDDIR):
	mkdir build-vsim

$(MKFILE_DIR)/test/%.o: $(MKFILE_DIR)/test/%.cc
	$(CXX) -shared -fPIC -std=c++0x -Bsymbolic $(DPI_CXXFLAGS) -c $< -o $@

$(VSIM_BUILDDIR)/soc910_dpi.so: $(DPI)
	# Compile C-code and generate .so file
	$(CXX) $(CXXFLAGS) -shared -m64 -o $@ $? -L$(RISCV)/lib -L$(SPIKE_ROOT)/lib -Wl,-rpath,$(RISCV)/lib -Wl,-rpath,$(SPIKE_ROOT)/lib -lfesvr

$(VSIM_BUILDDIR)/compile.vsim.tcl:
	vlib $(dir $@)
	$(BENDER) script vsim --target test $(VSIM_BENDER) --vlog-arg="$(VLOG_FLAGS) -work $(dir $@) " > $@
	echo 'vlog -work $(dir $@) "$(MKFILE_DIR)/test/elfloader.cpp" -ccflags "-std=c++11"' >> $@
	echo 'return 0' >> $@

# echo '$(VLOG) -work $(dir $@) $(TB_DIR)/rtl_lib.cc $(TB_DIR)/common_lib.cc test/bootdata.cc -ccflags "-std=c++14 -I$(MKFILE_DIR)/test -I$(FESVR)/include -I$(TB_DIR)"' >> $@
# echo '$(VLOG) -work $(dir $@) test/uartdpi/uartdpi.c -ccflags "-Itest/uartdpi"' >> $@

bin/c910.vsim: $(VSIM_BUILDDIR)/compile.vsim.tcl $(VSIM_BUILDDIR)/soc910_dpi.so
	$(call QUESTASIM,soc910_tb)

vsim: bin/c910.vsim

fpga/scripts/add_sources.tcl: Bender.yml
	$(BENDER) script vivado -t fpga > $@

xilinx-all: fpga/scripts/add_sources.tcl

clean:
	rm -rf build-vsim work bin
