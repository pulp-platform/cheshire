# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

PROJECT ?= cheshire
BOARD ?= genesys2
XILINX_PART ?= xc7k325tffg900-2
XILINX_BOARD ?= digilentinc.com:genesys2:part0:1.1

out := out
bit := $(out)/cheshire.bit
mcs := $(out)/cheshire.mcs


VIVADOENV ?= 	PROJECT=$(PROJECT) 				\
				BOARD=$(BOARD) 					\
				XILINX_PART=$(XILINX_PART) 		\
				XILINX_BOARD=$(XILINX_BOARD) 	\
				BIT=$(bit)

VIVADO ?= vitis-2022.1
VIVADOFLAGS ?= -nojournal -mode batch -source scripts/prologue.tcl

ip-dir := xilinx
ips := xlnx_mig_7_ddr3.xci\
			 xlnx_protocol_checker.xci

#	   xlnx_ila.xci					\

all: $(mcs)

# Generate mcs from bitstream
$(mcs) : $(bit)
	$(VIVADOENV) $(VIVADO) vivado $(VIVADOFLAGS) -source scripts/write_cfgmem.tcl -tclargs $@ $^

$(bit) : $(ips)
	@mkdir -p $(out)
	$(VIVADOENV) $(VIVADO) vivado $(VIVADOFLAGS) -source scripts/run.tcl
	cp $(PROJECT).runs/impl_1/$(PROJECT)* ./$(out)
	
$(ips):
	@echo "Generating IP $(basename $@)"
	cd $(ip-dir)/$(basename $@) && $(MAKE) clean && $(VIVADOENV) VIVADO=$(VIVADO) $(MAKE)
	cp $(ip-dir)/$(basename $@)/$(basename $@).srcs/sources_1/ip/$(basename $@)/$@ $@

gui:
	@mkdir -p $(out)
	@echo "Starting $(vivado) GUI"
	@$(VIVADOENV) $(VIVADO) vivado -nojournal -mode gui $(PROJECT).xpr &

program: $(bit)
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO) vivado $(VIVADOFLAGS) -source scripts/program.tcl

clean:
	rm -rf *.log *.jou *.str *.mif *.xci *.xpr $(out) $(PROJECT).cache $(PROJECT).hw $(PROJECT).ip_user_files

.PHONY:
	clean
