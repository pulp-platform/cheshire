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

#
# Makefile variables (user inputs are in capital letters)
#

CHS_XIL_DIR ?= $(CHS_ROOT)/target/xilinx

VIVADO ?= vitis-2020.2 vivado

XILINX_PROJECT ?= cheshire
# XILINX_FLAVOR in {vanilla}
XILINX_FLAVOR  ?= vanilla
# XILINX_BOARD in {vcu128, genesys2}
XILINX_BOARD   ?= vcu128

ifeq ($(XILINX_BOARD),vcu128)
	xilinx_part       := xcvu37p-fsvh2892-2L-e
	xilinx_board_long := xilinx.com:vcu128:part0:1.0
	XILINX_PORT       ?= 3232
	XILINX_FPGA_PATH  ?= xilinx_tcf/Xilinx/091847100638A
	XILINX_HOST       ?= bordcomputer
endif

ifeq ($(XILINX_BOARD),genesys2)
	xilinx_part       := xc7k325tffg900-2
	xilinx_board_long := digilentinc.com:genesys2:part0:1.1
	XILINX_PORT       ?= 3332
	XILINX_FPGA_PATH  ?= xilinx_tcf/Digilent/200300A8C60DB
	XILINX_HOST       ?= bordcomputer
endif

XILINX_USE_ARTIFACTS ?= 0
XILINX_ARTIFACTS_ROOT ?=
XILINX_ELABORATION_ONLY ?= 0
XILINX_CHECK_TIMING ?= 0

VIVADO_MODE  ?= batch
VIVADO_FLAGS ?= -nojournal -mode $(VIVADO_MODE)

xilinx_ip_dir := $(CHS_XIL_DIR)/xilinx_ips
xilinx_bit := $(CHS_XIL_DIR)/out/$(XILINX_PROJECT)_$(XILINX_FLAVOR)_$(XILINX_BOARD).bit

xilinx_targs_common := -t fpga -t xilinx -t cv64a6_imafdcsclic_sv39 -t cva6
xilinx_targs_common += $(addprefix -t ,$(XILINX_BOARD))

#
# Include other makefiles flavors
#

include $(CHS_XIL_DIR)/flavor_vanilla/flavor_vanilla.mk

#
# Flavor dependant variables
#

vivado_env := $(vivado_env_$(XILINX_FLAVOR))
xilinx_targs := $(xilinx_targs_$(XILINX_FLAVOR))
xilinx_defs := $(xilinx_defs_$(XILINX_FLAVOR))

#
# IPs compile rules
#

# Note: at the moment xilinx_ips uses vivado_env defined above,
# but it could re-define its own vivado_env and xilinx_targs
include $(CHS_XIL_DIR)/xilinx_ips/xilinx_ips.mk

#
# Top level compile rules
#

# Copy bitstream and probe file to final output location (/target/xilinx/out)
$(CHS_XIL_DIR)/out/%.bit: $(xilinx_bit_$(XILINX_FLAVOR))
	mkdir -p $(CHS_XIL_DIR)/out/
	if [ "$(XILINX_ELABORATION_ONLY)" -eq "0" ]; then \
		cp $< $@; \
		cp $(patsubst %.bit,%.ltx,$< $@); \
	fi

# Build bitstream
chs-xil-all: $(xilinx_bit)

# Program last bitstream
chs-xil-program:
	@echo "Programming board $(XILINX_BOARD) ($(xilinx_part))"
	$(vivado_env) $(VIVADO) $(VIVADO_FLAGS) -source $(CHS_XIL_DIR)/scripts/program.tcl

# Flash linux image
chs-xil-flash: $(CHS_SW_DIR)/boot/linux_cheshire_$(XILINX_BOARD)_$(XILINX_FLAVOR).gpt.bin
	$(vivado_env) FILE=$< OFFSET=0 $(VIVADO) $(VIVADO_FLAGS) -source $(CHS_XIL_DIR)/scripts/flash_spi.tcl
chs-xil-clean: chs-xil-clean-vanilla xilinx-ip-clean-all

.PHONY: chs-xil-program chs-xil-flash chs-xil-clean chs-xil-all
