# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

BENDER       ?= bender

PROJECT      ?= cheshire

# Board in      {vcu128, genesys2, zcu102}
BOARD        ?= zcu102
XILINX_PORT  ?= 3332
XILINX_HOST  ?= bordcomputer
FPGA_PATH    ?= xilinx_tcf/Digilent/200300A8C60DB
ip-dir       := xilinx

# Derive from board
bender-targets := -t $(BOARD) -t cv64a6_imafdcsclic_sv39 -t cva6

# Select board specific variables
ifeq ($(BOARD),vcu128)
    # The bordcomputer only has hw-server 2020.2 for now
	VIVADO         ?= vitis-2020.2 vivado
	XILINX_PART    ?= xcvu37p-fsvh2892-2L-e
	XILINX_BOARD   ?= xilinx.com:vcu128:part0:1.0
	ips-names      := xlnx_vio xlnx_mig_ddr4
	bender-targets := $(bender-targets) -t bscane
endif
ifeq ($(BOARD),genesys2)
	XILINX_PART  ?= xc7k325tffg900-2
	XILINX_BOARD ?= digilentinc.com:genesys2:part0:1.1
	ips-names    := xlnx_mig_7_ddr3
	FPGA_PATH    ?= xilinx_tcf/Digilent/200300A8C60DB
endif
ifeq ($(BOARD),zcu102)
	VIVADO ?= vitis-2020.2 vivado
	XILINX_PART    ?= xczu9eg-ffvb1156-2-e
	XILINX_BOARD   ?= xilinx.com:zcu102:part0:3.4
	ips-names      := xlnx_mig_ddr4
endif

# Derive from ips
ips := $(addsuffix .xci ,$(basename $(ips-names)))
bender-targets := $(bender-targets) $(addprefix -t ,$(basename $(ips)))

out := out
bit := $(out)/cheshire_top_xilinx.bit
mcs := $(out)/cheshire_top_xilinx.mcs
BIT ?= $(bit)

VIVADOENV ?=  PROJECT=$(PROJECT)            \
              BOARD=$(BOARD)                \
              XILINX_PART=$(XILINX_PART)    \
              XILINX_BOARD=$(XILINX_BOARD)  \
              PORT=$(XILINX_PORT)           \
              HOST=$(XILINX_HOST)           \
              FPGA_PATH=$(FPGA_PATH)        \
              BIT=$(BIT)

# select IIS-internal tool commands if we run on IIS machines
ifneq (,$(wildcard /etc/iis.version))
	VIVADO ?= vitis-2022.1 vivado
else
	VIVADO ?= vivado
endif

MODE        ?= batch
VIVADOFLAGS ?= -nojournal -mode $(MODE)

all: $(bit)

# Include Xilinx IPs simulation makefile
include sim/simulate.mk

# Generate mcs from bitstream
$(mcs): $(bit)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/write_cfgmem.tcl -tclargs $@ $^

$(bit): $(ips) scripts/add_sources.tcl
	echo $(ips)
	@mkdir -p $(out)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/prologue.tcl -source scripts/run.tcl
	cp $(PROJECT).runs/impl_1/$(PROJECT)* ./$(out)

%.xci:
	@echo "Generating IP $(basename $@)"
	cd $(ip-dir)/$(basename $@) && $(MAKE) clean && $(VIVADOENV) VIVADO="$(VIVADO)" $(MAKE)
	cp $(ip-dir)/$(basename $@)/$(basename $@).srcs/sources_1/ip/$(basename $@)/$@ $@

gui:
	@echo "Starting $(vivado) GUI"
	@$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr &

program:
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/program.tcl

clean:
	rm -rf *.log *.jou *.str *.mif *.xci *.xpr .Xil/ $(out) $(PROJECT).cache $(PROJECT).hw $(PROJECT).ioplanning $(PROJECT).ip_user_files $(PROJECT).runs $(PROJECT).sim

# Clean only top and copy back the IPs output here
rebuild_top:
	${MAKE} clean
	rm -f scripts/add_sources.tcl
	find xilinx -wholename "**/*.srcs/**/*.xci" | xargs -n 1 -I {} cp {} .
	${MAKE} $(bit)

# Bender
scripts/add_sources.tcl: ../../Bender.yml
	$(BENDER) script vivado -t fpga $(bender-targets) > $@

.PHONY: clean sim
