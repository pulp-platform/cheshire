# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

# Output bitstream
xilinx_bit_vanilla := $(CHS_XIL_DIR)/flavor_vanilla/out/cheshire_top_xilinx.bit

#
# IPs
#

# This flavor requires pre-compiled Xilinx IPs (which may depend on the board)
xilinx_ips_names_vanilla_vcu128    := xlnx_mig_ddr4 xlnx_clk_wiz xlnx_vio
xilinx_ips_names_vanilla_genesys2  := xlnx_clk_wiz xlnx_vio xlnx_mig_7_ddr3
xilinx_ips_names_vanilla           := $(xilinx_ips_names_vanilla_${XILINX_BOARD})
# Path to compiled ips
xilinx_ips_paths_vanilla           := $(foreach ip-name,$(xilinx_ips_names_vanilla),$(xilinx_ip_dir)/$(ip-name)/$(ip-name).srcs/sources_1/ip/$(ip-name)/$(ip-name).xci)

#
# Bender
#

# Flavor specific bender args
# (add the enabled ips in bender args, used by phy_definitions.svh)
xilinx_targs_vanilla := $(xilinx_targs_common) $(foreach ip-name,$(xilinx_ips_names_vanilla),$(addprefix -t ,$(ip-name)))
xilinx_targs_vanilla += -t flavor_vanilla

# Vivado variables
vivado_env_vanilla := \
    XILINX_PROJECT=$(XILINX_PROJECT) \
    XILINX_BOARD=$(XILINX_BOARD) \
    XILINX_PART=$(xilinx_part) \
    XILINX_BOARD_LONG=$(xilinx_board_long) \
    XILINX_PORT=$(XILINX_PORT) \
    XILINX_HOST=$(XILINX_HOST) \
    XILINX_FPGA_PATH=$(XILINX_FPGA_PATH) \
    XILINX_BIT=$(xilinx_bit) \
    XILINX_IP_PATHS="$(xilinx_ips_paths_vanilla)" \
    ROUTED_DCP=$(ROUTED_DCP) \
    XILINX_CHECK_TIMING=$(XILINX_CHECK_TIMING) \
    XILINX_ELABORATION_ONLY=$(XILINX_ELABORATION_ONLY)

#
# Rules
#

# Generate bender script
$(CHS_XIL_DIR)/flavor_vanilla/scripts/add_sources.tcl: Bender.yml
	$(BENDER) script vivado $(xilinx_targs_vanilla) > $@

# Compile bitstream
$(CHS_XIL_DIR)/flavor_vanilla/out/%.bit: $(xilinx_ips_paths_vanilla) $(CHS_XIL_DIR)/flavor_vanilla/scripts/add_sources.tcl
	@mkdir -p $(CHS_XIL_DIR)/flavor_vanilla/out
	cd $(CHS_XIL_DIR)/flavor_vanilla && $(vivado_env_vanilla) $(VIVADO) $(VIVADO_FLAGS) -source scripts/run.tcl
	find $(CHS_XIL_DIR)/flavor_vanilla -name "*.ltx" -o -name "*.bit" -o -name "*routed.rpt" | xargs -I {} cp {} $(CHS_XIL_DIR)/flavor_vanilla/out

chs-xil-clean-vanilla:
	cd $(CHS_XIL_DIR)/flavor_vanilla && rm -rf scripts/add_sources.tcl *.log *.jou cheshire.* .Xil/

.PHONY: chs-xil-clean-vanilla

# Add simulation rules to verify Xilinx IP integration

include $(CHS_XIL_DIR)/flavor_vanilla/sim/sim.mk
