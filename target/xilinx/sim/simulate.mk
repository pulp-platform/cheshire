
ip-paths := $(addsuffix /questa/compile.do, $(addprefix sim/ips/, $(ips-names)))

XILINX_SIMLIB_PATH ?= ~/sim
SIMULATOR_PATH ?= /usr/pack/questa-2020.1-kgf/questasim/bin
GCC_PATH ?= /usr/pack/questa-2020.1-kgf/questasim/gcc-5.3.0-linux_x86_64/bin

VIVADOENV_SIM := $(VIVADOENV) \
              XILINX_SIMLIB_PATH=$(XILINX_SIMLIB_PATH) \
              SIMULATOR_PATH=$(SIMULATOR_PATH)
VLOG_ARGS := -suppress 2583 -suppress 13314

$(XILINX_SIMLIB_PATH)/modelsim.ini:
	cd sim && $(VIVADOENV_SIM) $(VIVADO) -nojournal -mode batch -source setup_simulation.tcl -tclargs "compile_simlib"

sim/ips/%/questa/compile.do:
	cd sim && $(VIVADOENV_SIM) $(VIVADO) -nojournal -mode batch -source setup_simulation.tcl -tclargs "export_simulation"

scripts/add_sources_vsim.tcl:
	$(BENDER) script vsim -t sim -t test -t cva6 $(bender-targets) --vlog-arg="$(VLOG_ARGS)" > $@

sim: cheshire.xpr $(XILINX_SIMLIB_PATH)/modelsim.ini $(ip-paths) scripts/add_sources_vsim.tcl
	mkdir -p sim/questa_lib
	cd sim && questa-2020.1 vsim -work work -modelsimini $(XILINX_SIMLIB_PATH)/modelsim.ini -do "run_simulation.tcl"

clean-sim:
	rm -rf sim/*.log sim/questa_lib sim/work sim/transcript sim/vsim.wlf scripts/vsim_cheshire.tcl sim/.Xil sim/modelsim.ini

.PHONY: clean-sim sim all
