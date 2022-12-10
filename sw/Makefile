# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

BENDER         ?= bender
DTC            ?= dtc

BASE_FLAGS      = -march=rv64gc -mabi=lp64d -O2 -Wall -static -ffunction-sections -fdata-sections #-flto -fwhole-program

RISCV_AR        = riscv64-unknown-elf-ar
RISCV_CC        = riscv64-unknown-elf-gcc
RISCV_OBJCOPY   = riscv64-unknown-elf-objcopy
RISCV_OBJDUMP   = riscv64-unknown-elf-objdump
RISCV_CCFLAGS   = $(BASE_FLAGS) -ggdb -mcmodel=medany -mexplicit-relocs -fno-builtin -fverbose-asm -pipe

BOOT_LD_FILE    = scripts/cheshire_bootrom.ld
SPM_LD_FILE     = scripts/cheshire_spmlink.ld 
DRAM_LD_FILE    = scripts/cheshire_dramlink.ld

# By default we link for the SPM
LD_FILE        ?= $(SPM_LD_FILE)
LD_FLAGS        = $(BASE_FLAGS) -nostartfiles -Wl,--gc-sections

SUBMODULE_INCS  = -I$(shell $(BENDER) path axi_llc)/sw/include
SUBMODULE_INCS += -Isubmodules/opentitan
SUBMODULE_INCS += -Isubmodules/printf
SUBMODULE_SRCS  = $(wildcard $(shell $(BENDER) path axi_llc)/sw/lib/*.c)
SUBMODULE_SRCS += submodules/opentitan/sw/device/lib/base/bitfield.c
SUBMODULE_SRCS += submodules/opentitan/sw/device/lib/base/memory.c
SUBMODULE_SRCS += submodules/opentitan/sw/device/lib/base/mmio.c
SUBMODULE_SRCS += submodules/opentitan/sw/device/lib/dif/dif_i2c.c
SUBMODULE_SRCS += $(wildcard submodules/printf/*.c)

INCLUDES        = -Iinclude $(SUBMODULE_INCS)

BOOT_SRCS_S     = $(wildcard bootrom/*.S)
BOOT_SRCS_C     = $(wildcard bootrom/*.c)
LIB_SRCS_S      = $(wildcard lib/*.S)
LIB_SRCS_C      = $(wildcard lib/*.c)
LIB_SRCS_O      = $(LIB_SRCS_S:.S=.o) $(LIB_SRCS_C:.c=.o)
TEST_SRCS_S     = $(wildcard tests/*.S)
TEST_SRCS_C     = $(wildcard tests/*.c)
TEST_SRCS_DUMP  = $(TEST_SRCS_S:.S=.dump) $(TEST_SRCS_C:.c=.dump)

LIBS            = lib/libcheshire.a

.PHONY: clean patches
.PRECIOUS: %.elf %.dtb

all: patches\
	 cheshire-lib\
	 bootrom\
	 tests\
	 device-tree

clean:
	rm -f lib/*.{a,o}
	rm -f tests/*.{dump,elf,o}
	rm -f bootrom/*.{dump,elf,o,sv}
	rm -f device-tree/*.dtb{,.elf}

tests:  $(TEST_SRCS_DUMP)

patches: .patched
.patched: $(wildcard patches/*.patch)
	@patch ./submodules/opentitan/sw/device/lib/dif/dif_i2c.c ./patches/dif_i2c.c.patch
	@touch .patched

cheshire-lib: lib/libcheshire.a
lib/libcheshire.a: $(LIB_SRCS_O)
	@$(RISCV_AR) -rcsv $@ $^
	@echo "AR   $@"

bootrom: bootrom/bootrom_asic.sv bootrom/bootrom_asic.dump\
		 bootrom/bootrom_fpga.sv bootrom/bootrom_fpga.dump
	@cp bootrom/bootrom_{asic,fpga}.sv ../src
	@echo "INSTALL bootrom_asic.sv"
	@echo "INSTALL bootrom_fpga.sv"

device-tree: device-tree/cheshire-fpga.dtb.elf

bootrom/bootrom_asic.elf: $(BOOT_SRCS_S) $(BOOT_SRCS_C) $(SUBMODULE_SRCS) $(LIBS)
	@$(RISCV_CC) $(INCLUDES) -T$(BOOT_LD_FILE) $(LD_FLAGS) -DBOOTROM_ASIC -o $@ $^
	@echo "CC/LD	$<"

bootrom/bootrom_fpga.elf: $(BOOT_SRCS_S) $(BOOT_SRCS_C) $(SUBMODULE_SRCS) $(LIBS)
	@$(RISCV_CC) $(INCLUDES) -T$(BOOT_LD_FILE) $(LD_FLAGS) -DBOOTROM_FPGA -o $@ $^
	@echo "CC/LD	$<"

%.o: %.c
	@$(RISCV_CC) $(INCLUDES) $(RISCV_CCFLAGS) -c $< -o $@
	@echo "CC   $<"

%.o: %.S
	@$(RISCV_CC) $(INCLUDES) $(RISCV_CCFLAGS) -c $< -o $@
	@echo "AS   $<"

%.elf: %.o  $(SUBMODULE_SRCS:.c=.o) $(LIBS)
	@$(RISCV_CC) $(INCLUDES) -T$(LD_FILE) $(LD_FLAGS) -o $@ $^
	@echo "LD   $<"

%.dump: %.elf
	@$(RISCV_OBJDUMP) -d $< > $@
	@echo "DUMP $<"

%.bin: %.elf
	@$(RISCV_OBJCOPY) -O binary $< $@
	@echo "OBJCOPY $< -> $@"

bootrom_%.sv: bootrom_%.bin
	@../util/gen_bootrom.py --sv-module bootrom -p 65536 $< > $@
	@echo "GEN_BOOTROM $<"

%.dtb: %.dts
	@$(DTC) -I dts -O dtb -o $@ $<
	@echo "DTC  $<"

%.dtb.elf: %.dtb
	@$(RISCV_OBJCOPY) -I binary -O elf64-littleriscv --change-section-address=.data=0x70000000 $< $@
	@echo "OBJCOPY $< -> $@"