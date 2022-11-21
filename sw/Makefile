# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

BENDER 	    	?= bender

RISCV_AR		= riscv64-unknown-elf-ar
RISCV_CC 		= riscv64-unknown-elf-gcc
RISCV_LD 	 	= riscv64-unknown-elf-ld
RISCV_OBJDUMP   = riscv64-unknown-elf-objdump
RISCV_CCFLAGS   = $(BASE_FLAGS) -ggdb -mcmodel=medany -mexplicit-relocs -fno-builtin -fverbose-asm -pipe

BASE_FLAGS 		= -march=rv64gc -mabi=lp64d -O2 -Wall -static #-flto -fwhole-program

SPM_LD_FILE 	= cheshire_spmlink.ld 
DRAM_LD_FILE    = cheshire_dramlink.ld
LD_FILE 		?= $(SPM_LD_FILE)
LD_FLAGS 		= $(BASE_FLAGS) -nostartfiles -Wl,--gc-sections
LD_LIBS			= lib/libcheshire.a

INCLUDES		= -Iinclude -I$(shell $(BENDER) path axi_llc)/sw/include
SRCS			= $(wildcard src/*.c)
LIB_SRCS_S      = $(wildcard lib/*.S)
LIB_SRCS_C      = $(wildcard lib/*.c) $(wildcard $(shell $(BENDER) path axi_llc)/sw/lib/*.c)
LIB_SRCS_O		= $(LIB_SRCS_S:.S=.o) $(LIB_SRCS_C:.c=.o)

.PHONY: clean tests

all: cheshire-lib\
     tests


tests:  tests/addressing_test.dump\
		tests/axi_llc_test.dump\
		tests/sd_fpga_test.dump\
		tests/sd_speed_bench.dump\
		tests/spi_test.dump\
		tests/vm_test.dump

clean:
	rm -f lib/*.{a,o}
	rm -f tests/*.{dump,elf,o}

tests/addressing_test.elf: tests/addressing_test.o cheshire-lib
	$(RISCV_CC) $(INCLUDES) -T$(LD_FILE) $(LD_FLAGS) -o $@ $< ${LD_LIBS}
	@echo "LD $<"

tests/axi_llc_test.elf: tests/axi_llc_test.o cheshire-lib
	$(RISCV_CC) $(INCLUDES) -T$(LD_FILE) $(LD_FLAGS) -o $@ $< ${LD_LIBS}
	@echo "LD $<"

tests/sd_fpga_test.elf: tests/sd_fpga_test.o cheshire-lib
	$(RISCV_CC) $(INCLUDES) -T$(LD_FILE) $(LD_FLAGS) -o $@ $< ${LD_LIBS}
	@echo "LD $<"

tests/sd_speed_bench.elf: tests/sd_speed_bench.o cheshire-lib
	$(RISCV_CC) $(INCLUDES) -T$(LD_FILE) $(LD_FLAGS) -o $@ $< ${LD_LIBS}
	@echo "LD $<"

tests/spi_test.elf: tests/spi_test.o cheshire-lib
	$(RISCV_CC) $(INCLUDES) -T$(LD_FILE) $(LD_FLAGS) -o $@ $< ${LD_LIBS}
	@echo "LD $<"

tests/vm_test.elf: tests/vm_test.o cheshire-lib
	$(RISCV_CC) $(INCLUDES) -T$(LD_FILE) $(LD_FLAGS) -o $@ $< ${LD_LIBS}
	@echo "LD $<"

cheshire-lib: lib/libcheshire.a
lib/libcheshire.a: ${LIB_SRCS_O}
	@$(RISCV_AR) -rcsv $@ $^
	@echo "AR $@"

%.o: %.c
	@$(RISCV_CC) $(INCLUDES) $(RISCV_CCFLAGS) -c $< -o $@
	@echo "CC $<"

%.o: %.S
	@$(RISCV_CC) $(INCLUDES) $(RISCV_CCFLAGS) -c $< -o $@
	@echo "AS $<"

%.dump: %.elf
	@$(RISCV_OBJDUMP) -d $< > $@
	@echo "DUMP $<"
