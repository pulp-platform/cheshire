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

RISCV_FLAGS   ?= -march=rv64gc_zifencei -mabi=lp64d -O2 -Wall -static -ffunction-sections -fdata-sections -frandom-seed=cheshire
RISCV_CCFLAGS ?= $(RISCV_FLAGS) -ggdb -mcmodel=medany -mexplicit-relocs -fno-builtin -fverbose-asm -pipe
RISCV_LDFLAGS ?= $(RISCV_FLAGS) -nostartfiles -Wl,--gc-sections

TOP_DIR       ?= $(shell git rev-parse --show-toplevel)
CHS_SW_DIR    ?= $(TOP_DIR)/$(CHS_ROOT)/sw
CHS_LD_DIR 	  ?= $(CHS_SW_DIR)/link

chs-sw-all: chs-sw-libs chs-sw-headers chs-sw-tests

.PRECIOUS: %.elf %.dtb
.PHONY: chs-sw-clean chs-sw-all chs-sw-libs chs-sw-headers chs-sw-tests

chs-sw-clean:
	rm -f $(CHS_SW_DIR)/lib/*.{a,o}
	rm -f $(CHS_SW_DIR)/tests/*.{dump,elf,o}

################
# Dependencies #
################

CHS_SW_DEPS_INCS  = -I$(shell $(BENDER) path axi_llc)/sw/include
CHS_SW_DEPS_INCS += -I$(CHS_SW_DIR)/deps/opentitan
CHS_SW_DEPS_INCS += -I$(CHS_SW_DIR)/deps/printf
CHS_SW_DEPS_SRCS  = $(wildcard $(shell $(BENDER) path axi_llc)/sw/lib/*.c)
CHS_SW_DEPS_SRCS += $(CHS_SW_DIR)/deps/opentitan/sw/device/lib/base/bitfield.c
CHS_SW_DEPS_SRCS += $(CHS_SW_DIR)/deps/opentitan/sw/device/lib/base/memory.c
CHS_SW_DEPS_SRCS += $(CHS_SW_DIR)/deps/opentitan/sw/device/lib/base/mmio.c
CHS_SW_DEPS_SRCS += $(CHS_SW_DIR)/deps/opentitan/sw/device/lib/dif/dif_i2c.c
CHS_SW_DEPS_SRCS += $(wildcard $(CHS_SW_DIR)/deps/printf/*.c)

ifeq ($(CHS_ROOT), .)
	git-update := git submodule update --init --recursive $(CHS_SW_DIR)/deps/*
else
	git-update :=
endif

# Apply existing patches whenever deps (including patches) change
$(CHS_SW_DIR)/deps/.patched: $(wildcard $(CHS_SW_DIR)/deps/*.patch wildcard $(CHS_SW_DIR)/deps/*/.git)
	$(git-update)
	-patch --forward $(CHS_SW_DIR)/deps/opentitan/sw/device/lib/dif/dif_i2c.c $(CHS_SW_DIR)/deps/dif_i2c.c.patch
	touch $@

#############
# Libraries #
#############

CHS_SW_INCLUDES   ?= -I$(CHS_SW_DIR)/include $(CHS_SW_DEPS_INCS)
CHS_SW_LIB_SRCS_S  = $(wildcard $(CHS_SW_DIR)/lib/*.S)
CHS_SW_LIB_SRCS_C  = $(wildcard $(CHS_SW_DIR)/lib/*.c)
CHS_SW_LIB_SRCS_O  = $(CHS_SW_DEPS_SRCS:.c=.o) $(CHS_SW_LIB_SRCS_S:.S=.o) $(CHS_SW_LIB_SRCS_C:.c=.o)

CHS_SW_LIBS = $(CHS_SW_DIR)/lib/libcheshire.a

$(CHS_SW_DIR)/lib/libcheshire.a: $(CHS_SW_LIB_SRCS_O)
	rm -f $@
	$(RISCV_AR) -rcsv $@ $^

chs-sw-libs: $(CHS_SW_LIBS)

#####################
# Header generation #
#####################

define chs_hdr_gen_rule
.PRECIOUS: $$(CHS_SW_DIR)/include/$(1).h
GEN_HDRS += $$(CHS_SW_DIR)/include/$(1).h

$$(CHS_SW_DIR)/include/$(1).h: $(2)
	$$(REGGEN) --cdefines $$< > $$@
endef

OT_PERI_DIR = $(shell $(BENDER) path opentitan_peripherals)
SLINK_DIR =  $(shell bender path serial_link)
VGA_DIR = $(shell bender path axi_vga)
LLC_DIR = $(shell bender path axi_llc)

$(eval $(call chs_hdr_gen_rule,i2c_regs,$(OT_PERI_DIR)/src/i2c/data/i2c.hjson $(OT_PERI_DIR)/.generated))
$(eval $(call chs_hdr_gen_rule,spi_regs,$(OT_PERI_DIR)/src/spi_host/data/spi_host.hjson $(OT_PERI_DIR)/.generated))
$(eval $(call chs_hdr_gen_rule,serial_link_regs,$(TOP_DIR)/$(CHS_ROOT)/hw/serial_link.hjson $(SLINK_DIR)/.generated))
$(eval $(call chs_hdr_gen_rule,axi_vga_regs,$(VGA_DIR)/data/axi_vga.hjson $(VGA_DIR)/.generated))
$(eval $(call chs_hdr_gen_rule,axi_llc_regs,$(LLC_DIR)/data/axi_llc_regs.hjson))
$(eval $(call chs_hdr_gen_rule,cheshire_regs,$(TOP_DIR)/$(CHS_ROOT)/hw/regs/cheshire_regs.hjson))

chs-sw-headers: $(GEN_HDRS)

###############
# Compilation #
###############

# All objects require up-to-date patches and headers
%.o: %.c $(CHS_SW_DIR)/deps/.patched $(GEN_HDRS)
	$(RISCV_CC) $(CHS_SW_INCLUDES) $(RISCV_CCFLAGS) -c $< -o $@

%.o: %.S $(CHS_SW_DIR)/deps/.patched $(GEN_HDRS)
	$(RISCV_CC) $(CHS_SW_INCLUDES) $(RISCV_CCFLAGS) -c $< -o $@

define chs_ld_elf_rule
.PRECIOUS: %.$(1).elf

%.$(1).elf: $$(CHS_LD_DIR)/$(1).ld %.o $$(CHS_SW_LIBS)
	$$(RISCV_CC) $$(CHS_SW_INCLUDES) -T$$< $$(RISCV_LDFLAGS) -o $$@ $$*.o $$(CHS_SW_LIBS)
endef

$(foreach link,$(patsubst $(CHS_LD_DIR)/%.ld,%,$(wildcard $(CHS_LD_DIR)/*.ld)),$(eval $(call chs_ld_elf_rule,$(link))))

%.dump: %.elf
	$(RISCV_OBJDUMP) -d $< > $@

%.bin: %.elf
	$(RISCV_OBJCOPY) -O binary $< $@

%.dtb: %.dts
	@$(DTC) -I dts -O dtb -o $@ $<

#########
# Tests #
#########

TEST_SRCS_S     = $(wildcard $(CHS_SW_DIR)/tests/*.S)
TEST_SRCS_C     = $(wildcard $(CHS_SW_DIR)/tests/*.c)
TEST_DRAM_DUMP  = $(TEST_SRCS_S:.S=.dram.dump) $(TEST_SRCS_C:.c=.dram.dump)
TEST_SPM_DUMP   = $(TEST_SRCS_S:.S=.spm.dump)  $(TEST_SRCS_C:.c=.spm.dump)

chs-sw-tests: $(TEST_DRAM_DUMP) $(TEST_SPM_DUMP)
