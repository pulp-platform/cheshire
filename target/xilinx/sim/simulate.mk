# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

CHS_XIL_SIM_DIR  ?= $(CHS_XIL_DIR)/sim

XILINX_SIMLIB_PATH ?= ~/xlib_questa-2022.3_vivado-2022.1
SIMULATOR_PATH ?= /usr/pack/questa-2022.3-bt/questasim/bin
GCC_PATH ?= /usr/pack/questa-2022.3-bt/questasim/gcc-7.4.0-linux_x86_64/bin

ip-sim-scripts := $(addsuffix /questa/compile.do, $(addprefix $(CHS_XIL_SIM_DIR)/ips/, $(ips-names)))

# Pre-generated/modified example projects (contain the simulation top level)
ifneq ($(filter xlnx_mig_ddr4,$(ips-names)),)
	ip-example-projects := xlnx_mig_ddr4_ex
endif
ifneq ($(filter xlnx_mig_7_ddr3,$(ips-names)),)
	ip-example-projects := xlnx_mig_7_ddr3_ex
endif

ip-example-sim-scripts := $(addsuffix /questa/compile.do, $(addprefix $(CHS_XIL_SIM_DIR)/ips/, $(ip-example-projects)))

VIVADOENV_SIM := $(VIVADOENV) \
              XILINX_SIMLIB_PATH=$(XILINX_SIMLIB_PATH) \
              SIMULATOR_PATH=$(SIMULATOR_PATH) \
			  GCC_PATH=$(GCC_PATH) \
			  VIVADO_PROJECT=../${PROJECT}.xpr
VLOG_ARGS := -suppress 2583 -suppress 13314

# Fetch example projects at IIS (containing SRAM behavioral models)
$(CHS_XIL_SIM_DIR)/ips/%_ex/questa/compile.do:
	mkdir -p $(CHS_XIL_SIM_DIR)/ips
	tar -xvf /usr/scratch2/wuerzburg/cykoenig/export/$*_ex.tar -C $(CHS_XIL_SIM_DIR)/ips

# Generate simulation libraries
$(XILINX_SIMLIB_PATH)/modelsim.ini:
	cd $(CHS_XIL_SIM_DIR) && $(VIVADOENV_SIM) vitis-2022.1 vivado -nojournal -mode batch -source setup_simulation.tcl -tclargs "compile_simlib"

# 
$(CHS_XIL_SIM_DIR)/ips/%/questa/compile.do:
	mkdir -p $(CHS_XIL_SIM_DIR)/ips
	cd $(CHS_XIL_SIM_DIR) && $(VIVADOENV_SIM) $(VIVADO) -nojournal -mode batch -source setup_simulation.tcl -tclargs "export_simulation"

$(CHS_XIL_DIR)/scripts/add_sources_vsim.tcl:
	$(BENDER) script vsim -t sim -t test $(xilinx_targs) --vlog-arg="$(VLOG_ARGS)" > $@

chs-xil-sim: $(CHS_XIL_DIR)/${PROJECT}.xpr $(XILINX_SIMLIB_PATH)/modelsim.ini $(ip-example-sim-scripts) $(ip-sim-scripts) $(CHS_XIL_DIR)/scripts/add_sources_vsim.tcl
	mkdir -p $(CHS_XIL_SIM_DIR)/questa_lib
	cp $(XILINX_SIMLIB_PATH)/modelsim.ini $(CHS_XIL_SIM_DIR)
	chmod +w $(CHS_XIL_SIM_DIR)/modelsim.ini
	cd $(CHS_XIL_SIM_DIR) && IPS="$(ips-names)" questa-2022.3 vsim -work work -do "run_simulation.tcl"

chs-xil-clean-sim:
	cd $(CHS_XIL_DIR) && rm -rf sim/*.log sim/questa_lib sim/work sim/transcript sim/vsim.wlf scripts/vsim_cheshire.tcl sim/.Xil sim/modelsim.ini

.PHONY: clean-sim sim
