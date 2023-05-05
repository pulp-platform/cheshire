# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

# Output bitstream
xilinx_bit_bd = $(CHS_XIL_DIR)/flavor_bd/out/design_1_wrapper.bit

# Vivado variables
vivado_env_bd := \
    XILINX_PROJECT=$(XILINX_PROJECT) \
    XILINX_BOARD=$(XILINX_BOARD) \
    XILINX_PART=$(xilinx_part) \
    XILINX_BOARD_LONG=$(xilinx_board_long) \
    XILINX_PORT=$(XILINX_PORT) \
    XILINX_HOST=$(XILINX_HOST) \
    XILINX_FPGA_PATH=$(XILINX_FPGA_PATH) \
    XILINX_BIT=$(xilinx_bit) \
    GEN_NO_HYPERBUS=$(GEN_NO_HYPERBUS) \
    GEN_EXT_JTAG=$(GEN_EXT_JTAG) \
    XILINX_ROUTED_DCP=$(XILINX_ROUTED_DCP) \
    XILINX_CHECK_TIMING=$(XILINX_CHECK_TIMING) \
    XILINX_ELABORATION_ONLY=$(XILINX_ELABORATION_ONLY)

# Flavor specific bender args
xilinx_targs_bd := -t xilinx_bd

# Add source files for ip
$(CHS_XIL_DIR)/flavor_bd/scripts/add_sources_cheshire_ip.tcl: Bender.yml
	$(BENDER) script vivado $(xilinx_targs) $(xilinx_targs_bd) > $@

# Build Cheshire IP
$(CHS_XIL_DIR)/flavor_bd/cheshire_ip/cheshire_ip.xpr: $(CHS_XIL_DIR)/flavor_bd/scripts/add_sources_cheshire_ip.tcl
	cd $(CHS_XIL_DIR)/flavor_bd && $(vivado_env) $(VIVADO) $(VIVADO_FLAGS) -source scripts/run_cheshire_ip.tcl

# Add includes files for block design
$(CHS_XIL_DIR)/flavor_bd/scripts/add_includes.tcl:
	$(BENDER) script vivado --only-defines --only-includes $(xilinx_targs) $(xilinx_targs_bd) > $@

# Build block design bitstream
$(CHS_XIL_DIR)/flavor_bd/out/%.bit: $(CHS_XIL_DIR)/flavor_bd/scripts/add_includes.tcl $(CHS_XIL_DIR)/flavor_bd/cheshire_ip/cheshire_ip.xpr
	mkdir -p $(CHS_XIL_DIR)/flavor_bd/out
	cd $(CHS_XIL_DIR)/flavor_bd && $(vivado_env_bd) $(VIVADO) $(VIVADO_FLAGS) -source scripts/run.tcl
	find $(CHS_XIL_DIR)/flavor_bd -name "*.ltx" -o -name "*.bit" -o -name "*routed.rpt" | xargs -I {} cp {} $(CHS_XIL_DIR)/flavor_bd/out

chs-xil-clean-bd:
	cd $(CHS_XIL_DIR)/flavor_bd && rm -rf scripts/add_sources* scripts/add_includes* *.log *.jou *.str *.mif cheshire* .Xil/

.PHONY: chs-xil-clean-bd
