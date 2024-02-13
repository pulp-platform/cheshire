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
# Makefile variables (user inputs are in capital letters)
#

CHS_XIL_DIR ?= $(CHS_ROOT)/target/xilinx

VIVADO                  ?= vitis-2020.2 vivado
XILINX_PORT             ?=
XILINX_FPGA_PATH        ?=
XILINX_HOST             ?=
XILINX_USE_ARTIFACTS    ?= 0
XILINX_ARTIFACTS_ROOT   ?= /tmp
XILINX_ELABORATION_ONLY ?= 0
XILINX_CHECK_TIMING     ?= 0
VIVADO_MODE             ?= batch
VIVADO_FLAGS            ?= -nojournal -mode $(VIVADO_MODE)

# Do not modify variables below this point

chs_xilinx_flavor  ?=
chs_xilinx_board   ?=

ifeq ($(chs_xilinx_board),genesys2)
	xilinx_part       := xc7k325tffg900-2
	xilinx_board_long := digilentinc.com:genesys2:part0:1.1
endif

chs_xilinx_targs_common := -t fpga -t xilinx -t cv64a6_imafdcsclic_sv39 -t cva6
chs_xilinx_targs_common += $(addprefix -t ,$(chs_xilinx_board))

CHS_XIL_IPS_DIR := $(CHS_XIL_DIR)/xilinx_ips

chs_xilinx_bit_vanilla_genesys2 := $(CHS_XIL_DIR)/flavor_vanilla/builds/cheshire_vanilla_genesys2/cheshire_vanilla_genesys2.runs/impl_1/cheshire_top_xilinx.bit
chs_xilinx_bit := $(chs_xilinx_bit_$(chs_xilinx_flavor)_$(chs_xilinx_board))

# Env used for auxiliary scripts (programming/flashing)
chs_vivado_env_common := \
    xilinx_board=$(chs_xilinx_board) \
    xilinx_board_long=$(xilinx_board_long) \
    xilinx_part=$(xilinx_part) \
    XILINX_PORT=$(XILINX_PORT) \
    XILINX_HOST=$(XILINX_HOST) \
    XILINX_FPGA_PATH=$(XILINX_FPGA_PATH)

#
# Include other makefiles flavors
#

include $(CHS_XIL_DIR)/flavor_vanilla/flavor_vanilla.mk

#
# Flavor dependant variables
#

chs_vivado_env   := $(chs_vivado_env_$(chs_xilinx_flavor))
chs_xilinx_targs := $(chs_xilinx_targs_$(chs_xilinx_flavor))
chs_xilinx_defs  := $(chs_xilinx_defs_$(chs_xilinx_flavor))

#
# IPs compile rules
#

# Note: at the moment xilinx_ips uses vivado_env defined above,
# but it could re-define its own vivado_env and xilinx_targs
include $(CHS_XIL_IPS_DIR)/xilinx_ips.mk

#
# Top level compile rules
#

$(CHS_XIL_DIR)/out/cheshire_vanilla_genesys2.bit:
	@mkdir -p $(CHS_XIL_DIR)/out
	${MAKE} chs_xilinx_flavor=vanilla chs_xilinx_board=genesys2 $(chs_xilinx_bit_vanilla_genesys2)
	if [ "$(XILINX_ELABORATION_ONLY)" -eq "0" ]; then \
		cp $(chs_xilinx_bit_vanilla_genesys2) $@; \
	fi

chs-xil-vanilla-genesys2: $(CHS_XIL_DIR)/out/cheshire_vanilla_genesys2.bit

# Program bitstream (XILINX_BOARD)
chs-xil-program:
	@echo "Programming board $(chs_xilinx_board) ($(xilinx_part))"
	$(chs_vivado_env) xilinx_bit=$(CHS_XIL_DIR)/out/cheshire_$(chs_xilinx_flavor)_$(chs_xilinx_board).bit $(VIVADO) $(VIVADO_FLAGS) -source $(CHS_XIL_DIR)/scripts/program.tcl

chs-xil-program-vanilla-genesys2: $(CHS_XIL_DIR)/out/cheshire_vanilla_genesys2.bit
	${MAKE} chs_xilinx_flavor=vanilla chs_xilinx_board=genesys2 chs-xil-program

chs-xil-clean: chs-xil-clean-vanilla xilinx-ip-clean-all
	rm -rf $(CHS_XIL_DIR)/out

.PHONY: chs-xil-vanilla-genesys2 chs-xil-program-vanilla-genesys2 chs-xil-program chs-xil-clean
