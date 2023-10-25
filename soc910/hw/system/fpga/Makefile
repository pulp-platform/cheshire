# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Florian Zaruba <zarubaf@iis.ee.ethz.ch>
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Nils Wistoff <nwistoff@iis.ee.ethz.ch>


PROJECT      ?= soc910
BOARD        ?= vcu128
XILINX_PART  ?= xcvu37p-fsvh2892-2L-e
XILINX_BOARD ?= xilinx.com:vcu128:part0:1.0

out := out
bit := $(out)/soc910_xilinx.bit
mcs := $(out)/soc910_xilinx.mcs

VIVADOENV ?=  PROJECT=$(PROJECT)            \
              BOARD=$(BOARD)                \
              XILINX_PART=$(XILINX_PART)    \
              XILINX_BOARD=$(XILINX_BOARD)  \
              BIT=$(bit)

VIVADO      ?= vivado
VIVADOFLAGS ?= -nojournal -mode gui -source scripts/prologue.tcl

ip-dir := xilinx
ips    := xlnx_clk_gen.xci              \
          xlnx_axi_clock_converter.xci  \
          xlnx_protocol_checker.xci     \
          xlnx_axi_dwidth_converter.xci \
          xlnx_jtag_axi.xci             \
          xlnx_vio.xci                  \
          xlnx_hbm.xci

          # xlnx_mig_7_ddr3.xci           \

all: $(bit)

# Generate mcs from bitstream
$(mcs): $(bit)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/write_cfgmem.tcl -tclargs $@ $^

$(bit): $(ips)
	@mkdir -p $(out)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/run.tcl
	cp $(PROJECT).runs/impl_1/$(PROJECT)* ./$(out)

$(ips):
	@echo "Generating IP $(basename $@)"
	cd $(ip-dir)/$(basename $@) && $(MAKE) clean && $(VIVADOENV) VIVADO="$(VIVADO)" $(MAKE)
	cp $(ip-dir)/$(basename $@)/$(basename $@).srcs/sources_1/ip/$(basename $@)/$@ $@

gui:
	@echo "Starting $(vivado) GUI"
	@$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr &

program: $(bit)
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/program.tcl

clean:
	rm -rf *.log *.jou *.str *.mif *.xci *.xpr .Xil/ $(out) $(PROJECT).cache $(PROJECT).hw $(PROJECT).ioplanning $(PROJECT).ip_user_files $(PROJECT).runs $(PROJECT).sim

.PHONY:
	clean
