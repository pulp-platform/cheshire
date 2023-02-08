# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

# Override this as needed
RISCV_GCC_BINROOT ?= $(dir $(shell which riscv64-unknown-elf-gcc))

BENDER        ?= bender
PYTHON3       ?= python3
DTC           ?= dtc
RISCV_AR      ?= $(RISCV_GCC_BINROOT)/riscv64-unknown-elf-ar
RISCV_CC      ?= $(RISCV_GCC_BINROOT)/riscv64-unknown-elf-gcc
RISCV_OBJCOPY ?= $(RISCV_GCC_BINROOT)/riscv64-unknown-elf-objcopy
RISCV_OBJDUMP ?= $(RISCV_GCC_BINROOT)/riscv64-unknown-elf-objdump
REGGEN        ?= $(PYTHON3) $(shell $(BENDER) path register_interface)/vendor/lowrisc_opentitan/util/regtool.py

RISCV_FLAGS      ?= -march=rv64gc_zifencei -mabi=lp64d -Os -Wall -static -ffunction-sections -fdata-sections -frandom-seed=cheshire -flto
RISCV_CCFLAGS    ?= $(RISCV_FLAGS) -ggdb -mcmodel=medany -mexplicit-relocs -fno-builtin -fverbose-asm -pipe
RISCV_LDFLAGS    ?= $(RISCV_FLAGS) -nostartfiles -Wl,--gc-sections -fuse-linker-plugin

TOP_DIR       ?= $(shell git rev-parse --show-toplevel)
SW_DIR        ?= $(TOP_DIR)/sw
LD_DIR    	  ?= $(SW_DIR)/link

sw-all: sw-libs sw-headers sw-tests

.PRECIOUS: %.elf %.dtb
.PHONY: sw-clean sw-all sw-libs sw-headers sw-tests

sw-clean:
	rm -f $(SW_DIR)/lib/*.{a,o}
	rm -f $(SW_DIR)/tests/*.{dump,elf,o}

################
# Dependencies #
################

DEPS_INCS  = -I$(shell $(BENDER) path axi_llc)/sw/include
DEPS_INCS += -I$(SW_DIR)/deps/opentitan
DEPS_INCS += -I$(SW_DIR)/deps/printf
DEPS_SRCS  = $(shell $(BENDER) path axi_llc)/sw/lib/axi_llc_reg32.c
DEPS_SRCS += $(SW_DIR)/deps/opentitan/sw/device/lib/base/bitfield.c
DEPS_SRCS += $(SW_DIR)/deps/opentitan/sw/device/lib/base/memory.c
DEPS_SRCS += $(SW_DIR)/deps/opentitan/sw/device/lib/base/mmio.c
DEPS_SRCS += $(SW_DIR)/deps/opentitan/sw/device/lib/dif/dif_i2c.c
DEPS_SRCS += $(SW_DIR)/deps/printf/printf.c

# Apply existing patches whenever deps (including patches) change
$(SW_DIR)/deps/.patched: $(wildcard $(SW_DIR)/deps/*.patch wildcard $(SW_DIR)/deps/*/.git)
	git submodule update --init --recursive $(SW_DIR)/deps/*
	-patch --forward $(SW_DIR)/deps/opentitan/sw/device/lib/dif/dif_i2c.c $(SW_DIR)/deps/dif_i2c.c.patch
	touch $@

#############
# Libraries #
#############

INCLUDES   ?= -I$(SW_DIR)/include $(DEPS_INCS)
LIB_SRCS_S  = $(wildcard $(SW_DIR)/lib/*.S)
LIB_SRCS_C  = $(wildcard $(SW_DIR)/lib/*.c)
LIB_SRCS_O  = $(DEPS_SRCS:.c=.o) $(LIB_SRCS_S:.S=.o) $(LIB_SRCS_C:.c=.o)

LIBS = $(SW_DIR)/lib/libcheshire.a

$(SW_DIR)/lib/libcheshire.a: $(LIB_SRCS_O)
	rm -f $@
	$(RISCV_AR) -rcsv $@ $^

sw-libs: $(LIBS)

#####################
# Header generation #
#####################

define hdr_gen_rule
.PRECIOUS: $$(SW_DIR)/include/$(1).h
GEN_HDRS += $$(SW_DIR)/include/$(1).h

$$(SW_DIR)/include/$(1).h: $(2)
	$$(REGGEN) --cdefines $$< > $$@
endef

OT_PERI_DIR = $(shell $(BENDER) path opentitan_peripherals)
SLINK_DIR =  $(shell bender path serial_link)
VGA_DIR = $(shell bender path axi_vga)
LLC_DIR = $(shell bender path axi_llc)

$(eval $(call hdr_gen_rule,i2c_regs,$(OT_PERI_DIR)/src/i2c/data/i2c.hjson $(OT_PERI_DIR)/.generated))
$(eval $(call hdr_gen_rule,spi_regs,$(OT_PERI_DIR)/src/spi_host/data/spi_host.hjson $(OT_PERI_DIR)/.generated))
$(eval $(call hdr_gen_rule,serial_link_regs,$(TOP_DIR)/hw/serial_link.hjson $(SLINK_DIR)/.generated))
$(eval $(call hdr_gen_rule,axi_vga_regs,$(VGA_DIR)/data/axi_vga.hjson $(VGA_DIR)/.generated))
$(eval $(call hdr_gen_rule,axi_llc_regs,$(LLC_DIR)/data/axi_llc_regs.hjson))
$(eval $(call hdr_gen_rule,cheshire_regs,$(TOP_DIR)/hw/regs/cheshire_regs.hjson))

sw-headers: $(GEN_HDRS)

###############
# Compilation #
###############

# All objects require up-to-date patches and headers
%.o: %.c $(SW_DIR)/deps/.patched $(GEN_HDRS)
	$(RISCV_CC) $(INCLUDES) $(RISCV_CCFLAGS) -c $< -o $@

%.o: %.S $(SW_DIR)/deps/.patched $(GEN_HDRS)
	$(RISCV_CC) $(INCLUDES) $(RISCV_CCFLAGS) -c $< -o $@

define ld_elf_rule
.PRECIOUS: %.$(1).elf

%.$(1).elf: $$(LD_DIR)/$(1).ld %.o $$(LIBS)
	$$(RISCV_CC) $$(INCLUDES) -T$$< $$(RISCV_LDFLAGS) -o $$@ $$*.o $$(LIBS)
endef

$(foreach link,$(patsubst $(LD_DIR)/%.ld,%,$(wildcard $(LD_DIR)/*.ld)),$(eval $(call ld_elf_rule,$(link))))

%.dump: %.elf
	$(RISCV_OBJDUMP) -d $< > $@

%.bin: %.elf
	$(RISCV_OBJCOPY) -O binary $< $@

%.dtb: %.dts
	@$(DTC) -I dts -O dtb -o $@ $<

#########
# Tests #
#########

TEST_SRCS_S     = $(wildcard $(SW_DIR)/tests/*.S)
TEST_SRCS_C     = $(wildcard $(SW_DIR)/tests/*.c)
TEST_DRAM_DUMP  = $(TEST_SRCS_S:.S=.dram.dump) $(TEST_SRCS_C:.c=.dram.dump)
TEST_SPM_DUMP   = $(TEST_SRCS_S:.S=.spm.dump)  $(TEST_SRCS_C:.c=.spm.dump)

sw-tests: $(TEST_DRAM_DUMP) $(TEST_SPM_DUMP)
