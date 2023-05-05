# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

XILINX_SIMLIB_PATH ?= ~/xlib_questa-2022.3_vivado-2022.1
SIMULATOR_PATH ?= /usr/pack/questa-2022.3-bt/questasim/bin
GCC_PATH ?= /usr/pack/questa-2022.3-bt/questasim/gcc-7.4.0-linux_x86_64/bin

ip-sim-scripts := $(addsuffix /questa/compile.do, $(addprefix sim/ips/, $(ips-names)))

# Pre-generated/modified example projects (contain the simulation top level)
ifeq ($(BOARD),vcu128)
	ip-example-projects := xlnx_mig_ddr4_ex
endif
ifeq ($(BOARD),genesys2)
	ip-example-projects := xlnx_mig_7_ddr3_ex
endif

ip-example-sim-scripts := $(addsuffix /questa/compile.do, $(addprefix sim/ips/, $(ip-example-projects)))

VIVADOENV_SIM := $(VIVADOENV) \
              XILINX_SIMLIB_PATH=$(XILINX_SIMLIB_PATH) \
              SIMULATOR_PATH=$(SIMULATOR_PATH) \
			  GCC_PATH=$(GCC_PATH) \
			  VIVADO_PROJECT=../${PROJECT}.xpr
VLOG_ARGS := -suppress 2583 -suppress 13314

# Fetch example projects at IIS (containing SRAM behavioral models)
sim/ips/%_ex/questa/compile.do:
	tar -xvf /usr/scratch2/wuerzburg/cykoenig/export/$*_ex.tar -C sim/ips

# Generate simulation libraries
$(XILINX_SIMLIB_PATH)/modelsim.ini:
	cd sim && $(VIVADOENV_SIM) vitis-2022.1 vivado -nojournal -mode batch -source setup_simulation.tcl -tclargs "compile_simlib"

# 
sim/ips/%/questa/compile.do:
	cd sim && $(VIVADOENV_SIM) $(VIVADO) -nojournal -mode batch -source setup_simulation.tcl -tclargs "export_simulation"

scripts/add_sources_vsim.tcl:
	$(BENDER) script vsim -t sim -t test -t fpga -t cv64a6_imafdcsclic_sv39 -t cva6 $(bender-targets) --vlog-arg="$(VLOG_ARGS)" > $@

sim: ${PROJECT}.xpr $(XILINX_SIMLIB_PATH)/modelsim.ini $(ip-example-sim-scripts) $(ip-sim-scripts) scripts/add_sources_vsim.tcl
	mkdir -p sim/questa_lib
	cp $(XILINX_SIMLIB_PATH)/modelsim.ini sim
	chmod +w sim/modelsim.ini
	cd sim && questa-2022.3 vsim -work work -do "run_simulation.tcl"

clean-sim:
	rm -rf sim/*.log sim/questa_lib sim/work sim/transcript sim/vsim.wlf scripts/vsim_cheshire.tcl sim/.Xil sim/modelsim.ini

.PHONY: clean-sim sim
