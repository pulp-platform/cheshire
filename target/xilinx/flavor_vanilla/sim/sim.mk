# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

CHS_XIL_SIM_DIR  ?= $(CHS_XIL_DIR)/flavor_vanilla/sim

XILINX_SIMLIB_PATH ?= /home/$(USER)/xlib_questa-2022.3_vivado-2022.1
SIMULATOR_PATH ?= /usr/pack/questa-2022.3-bt/questasim/bin
GCC_PATH ?= /usr/pack/questa-2022.3-bt/questasim/gcc-7.4.0-linux_x86_64/bin

# Compile script for each IP model
chs-ip-sim-scripts := $(addsuffix /questa/compile.do, $(addprefix $(CHS_XIL_SIM_DIR)/ips/, $(ips-names)))

# Getting the DDR model requires exporting the Vivado example project for the controller's IP
chs-ddr-example-project := $(filter xlnx_mig_,$(ips-names))_ex
chs-ddr-sim-script := $(CHS_XIL_SIM_DIR)/ips/$(chs-ddr-example-projects)/questa/compile.do

chs-vivado-env-sim := $(VIVADOENV) \
                       XILINX_SIMLIB_PATH=$(XILINX_SIMLIB_PATH) \
                       SIMULATOR_PATH=$(SIMULATOR_PATH) \
                       GCC_PATH=$(GCC_PATH) \
                       VIVADO_PROJECT=$(CHS_XIL_DIR)/flavor_vanilla/chesire.xpr
chs-xil-vlog-args := -suppress 2583 -suppress 13314

# First generate the generic Xilinx simulation libraries for questa
$(XILINX_SIMLIB_PATH)/modelsim.ini:
	cd $(CHS_XIL_SIM_DIR) && $(VIVADOENV_SIM) vitis-2022.1 vivado -nojournal -mode batch -source setup_simulation.tcl -tclargs "compile_simlib"

# Then generate the IP models for the project cheshire.xpr
$(CHS_XIL_SIM_DIR)/ips/%/questa/compile.do:
	mkdir -p $(CHS_XIL_SIM_DIR)/ips
	cd $(CHS_XIL_SIM_DIR) && $(VIVADOENV_SIM) $(VIVADO) -nojournal -mode batch -source setup_simulation.tcl -tclargs "export_simulation"

# Get the DRAM simulation models
$(CHS_XIL_SIM_DIR)/ips/%_ex/questa/compile.do:
	mkdir -p $(CHS_XIL_SIM_DIR)/ips
	# First create the example project
	cd $(CHS_XIL_SIM_DIR) && $(chs-vivado-env-sim) $(VIVADO) -nojournal -mode batch -source setup_simulation.tcl -tclargs "export_example"
	# Then export the simulation models
	cd $(CHS_XIL_SIM_DIR) && $(chs-vivado-env-sim) VIVADO_PROJECT=$(CHS_XIL_SIM_DIR)/ips/$*_ex/$*_ex.xpr $(VIVADO) -nojournal -mode batch -source setup_simulation.tcl -tclargs "export_example_simulation"
	# And replace the DUT by cheshire top
	patch $(CHS_XIL_SIM_DIR)/ips/$*_ex/imports/sim_tb_top.sv $(CHS_XIL_SIM_DIR)/sim_tb_top.diff

# Export the Cheshire questa compile script
$(CHS_XIL_SIM_DIR)/add_sources_vsim.tcl:
	$(BENDER) script vsim -t sim -t test $(xilinx_targs) --vlog-arg="$(chs-xil-vlog-args)" > $@

# Run all
chs-xil-sim: $(CHS_XIL_DIR)/flavor_vanilla/cheshire.xpr $(XILINX_SIMLIB_PATH)/modelsim.ini $(chs-ddr-sim-script) $(chs-ip-sim-scripts) $(CHS_XIL_SIM_DIR)/add_sources_vsim.tcl
	mkdir -p $(CHS_XIL_SIM_DIR)/questa_lib
	cp $(XILINX_SIMLIB_PATH)/modelsim.ini $(CHS_XIL_SIM_DIR)
	chmod +w $(CHS_XIL_SIM_DIR)/modelsim.ini
	cd $(CHS_XIL_SIM_DIR) && IPS="$(ips-names)" questa-2022.3 vsim -work work -do "run_simulation.tcl"

chs-xil-clean-sim:
	cd $(CHS_XIL_SIM_DIR) && rm -rf *.log questa_lib work transcript vsim.wlf vsim_cheshire.tcl .Xil modelsim.ini

.PHONY: clean-sim sim
