# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

#
# IPs
#

# This flavor requires pre-compiled Xilinx IPs (which may depend on the board)
chs_xilinx_ips_names_vanilla_genesys2  := xlnx_clk_wiz xlnx_vio xlnx_mig_7_ddr3
chs_xilinx_ips_names_vanilla           := $(chs_xilinx_ips_names_vanilla_${chs_xilinx_board})
# Path to compiled ips
chs_xilinx_ips_paths_vanilla           := $(foreach ip-name,$(chs_xilinx_ips_names_vanilla),$(CHS_XIL_IPS_DIR)/$(ip-name)/$(ip-name).srcs/sources_1/ip/$(ip-name)/$(ip-name).xci)

#
# Bender
#

# Flavor specific bender args
# (add the enabled ips in bender args, used by phy_definitions.svh)
chs_xilinx_targs_vanilla := $(chs_xilinx_targs_common) $(foreach ip-name,$(chs_xilinx_ips_names_vanilla),$(addprefix -t ,$(ip-name)))
chs_xilinx_targs_vanilla += -t flavor_vanilla

# Env used to build the vanilla bitsteasm
chs_vivado_env_vanilla := \
    $(chs_vivado_env_common) \
    ROUTED_DCP=$(ROUTED_DCP) \
    XILINX_CHECK_TIMING=$(XILINX_CHECK_TIMING) \
    XILINX_ELABORATION_ONLY=$(XILINX_ELABORATION_ONLY) \
    xilinx_ip_paths="$(chs_xilinx_ips_paths_vanilla)"

#
# Rules
#

# Generate bender script
$(CHS_XIL_DIR)/flavor_vanilla/scripts/add_sources_%.tcl: Bender.yml
	$(BENDER) script vivado $(chs_xilinx_targs_vanilla) > $@
.PRECIOUS: $(CHS_XIL_DIR)/flavor_vanilla/scripts/add_sources_%.tcl

# Compile bitstream
$(CHS_XIL_DIR)/flavor_vanilla/builds/cheshire_vanilla_genesys2/cheshire_vanilla_genesys2.runs/impl_1/cheshire_top_xilinx.bit: $(CHS_XIL_DIR)/flavor_vanilla/scripts/add_sources_genesys2.tcl $(chs_xilinx_ips_paths_vanilla)
	@mkdir -p $(CHS_XIL_DIR)/flavor_vanilla/builds/cheshire_vanilla_genesys2
	cd $(CHS_XIL_DIR)/flavor_vanilla/builds/cheshire_vanilla_genesys2 && $(chs_vivado_env_vanilla) $(VIVADO) $(VIVADO_FLAGS) -source $(CHS_XIL_DIR)/flavor_vanilla/scripts/run.tcl

.PHONY: chs-xil-clean-vanilla
chs-xil-clean-vanilla:
	cd $(CHS_XIL_DIR)/flavor_vanilla && rm -rf scripts/add_sources* *.log *.jou builds .Xil/
