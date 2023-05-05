# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

#
# User input Makefile variables
#

CHS_XIL_DIR ?= $(CHS_ROOT)/target/xilinx

XILINX_PROJECT          ?= cheshire
XILINX_FLAVOR           ?= vanilla
XILINX_BOARD            ?= genesys2
XILINX_ELABORATION_ONLY ?= 0
XILINX_CHECK_TIMING     ?= 0
XILINX_USE_ARTIFACTS    ?= 0

ifneq (,$(wildcard /etc/iis.version))
	VIVADO ?= vitis-2020.2 vivado
else
	VIVADO ?= vivado
endif
VIVADO_MODE  ?= batch
VIVADO_FLAGS ?= -nojournal -mode $(VIVADO_MODE)

#
# Derived variables
#

ifeq ($(XILINX_BOARD),genesys2)
	xilinx_part       := xc7k325tffg900-2
	xilinx_board_long := digilentinc.com:genesys2:part0:1.1
	XILINX_PORT       ?= 3332
	XILINX_FPGA_PATH  ?= xilinx_tcf/Digilent/200300A8C60DB
	XILINX_HOST       ?= bordcomputer
endif

ifeq ($(XILINX_BOARD),vcu128)
	xilinx_part       := xcvu37p-fsvh2892-2L-e
	xilinx_board_long := xilinx.com:vcu128:part0:1.0
	XILINX_PORT       ?= 3232
	XILINX_FPGA_PATH  ?= xilinx_tcf/Xilinx/091847100638A
	XILINX_HOST       ?= bordcomputer
endif

xilinx_ip_dir  := $(CHS_XIL_DIR)/xilinx_ips
xilinx_ip_dirs := $(wildcard $(xilinx_ip_dir)/*)

xilinx_targs := -t cv64a6_imafdcsclic_sv39 -t cva6
xilinx_targs += -t fpga $(addprefix -t ,$(XILINX_BOARD))

#
# Include flavors
#

include $(CHS_XIL_DIR)/flavor_vanilla/flavor_vanilla.mk
include $(CHS_XIL_DIR)/flavor_bd/flavor_bd.mk

#
# Flavor dependant variables
#

xilinx_bit := $(CHS_XIL_DIR)/out/$(XILINX_PROJECT)_$(XILINX_FLAVOR)_$(XILINX_BOARD).bit
vivado_env := $(vivado_env_$(XILINX_FLAVOR))

#
# Targets
#

# Generate ips
%.xci:
	echo $@
	@echo "Generating IP $(basename $@)"
	IP_NAME=$(basename $(notdir $@)) ; cd $(xilinx_ip_dir)/$$IP_NAME && make clean && XILINX_USE_ARTIFACTS=$(XILINX_USE_ARTIFACTS) vivado_env="$(subst ",\",$(vivado_env))" VIVADO="$(VIVADO)" make

# Copy bitstream and probe file to final output location (/target/xilinx/out)
$(CHS_XIL_DIR)/out/%.bit: $(xilinx_bit_$(XILINX_FLAVOR))
	mkdir -p $(CHS_XIL_DIR)/out/
	if [ "$(XILINX_ELABORATION_ONLY)" -eq "0" ]; then \
		cp $< $@; \
		cp $(patsubst %.bit,%.ltx,$< $@); \
	fi

# Build a bitstream
chs-xil-all: chs-xil-clean-ips $(xilinx_bit)

# Program last bitstream
chs-xil-program:
	@echo "Programming board $(XILINX_BOARD) ($(xilinx_part))"
	$(vivado_env) $(VIVADO) $(VIVADO_FLAGS) -source $(CHS_XIL_DIR)/scripts/program.tcl

# Flash linux image
chs-xil-flash: $(CAR_SW_DIR)/boot/linux_carfield_$(XILINX_FLAVOR)_$(XILINX_BOARD).gpt.bin
	$(vivado_env) FILE=$< OFFSET=0 $(VIVADO) $(VIVADO_FLAGS) -source $(CHS_XIL_DIR)/scripts/flash_spi.tcl

# Clean a given IP folder
%-xlnx-ip-clean: %
	make -C $< clean
# Clean all IP folder using rule above
chs-xil-clean-ips: $(addsuffix -xlnx-ip-clean,$(shell find $(xilinx_ip_dir)/ -maxdepth 1 -mindepth 1 -type d))

chs-xil-clean: chs-xil-clean-ips chs-xil-clean-vanilla chs-xil-clean-bd

.PHONY: chs-xil-program chs-xil-flash chs-xil-clean chs-xil-all chs-xil-clean-ips
