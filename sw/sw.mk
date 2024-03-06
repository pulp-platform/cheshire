# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

# Override this as needed
CHS_SW_GCC_BINROOT ?= $(dir $(shell which riscv64-unknown-elf-gcc))
CHS_SW_DTC     ?= dtc

CHS_SW_AR      := $(CHS_SW_GCC_BINROOT)/riscv64-unknown-elf-ar
CHS_SW_CC      := $(CHS_SW_GCC_BINROOT)/riscv64-unknown-elf-gcc
CHS_SW_OBJCOPY := $(CHS_SW_GCC_BINROOT)/riscv64-unknown-elf-objcopy
CHS_SW_OBJDUMP := $(CHS_SW_GCC_BINROOT)/riscv64-unknown-elf-objdump
CHS_SW_LTOPLUG := $(shell find $(shell dirname $(CHS_SW_GCC_BINROOT))/libexec/gcc/riscv64-unknown-elf/**/liblto_plugin.so)

CHS_SW_DIR       ?= $(CHS_ROOT)/sw
CHS_SW_LD_DIR    ?= $(CHS_SW_DIR)/link
CHS_SW_ZSL_TGUID := 0269B26A-FD95-4CE4-98CF-941401412C62
CHS_SW_DTB_TGUID := BA442F61-2AEF-42DE-9233-E4D75D3ACB9D
CHS_SW_FW_TGUID  := 99EC86DA-3F5B-4B0D-8F4B-C4BACFA5F859
CHS_SW_DISK_SIZE ?= 16M

CHS_SW_FLAGS   ?= -DOT_PLATFORM_RV32 -march=rv64gc_zifencei -mabi=lp64d -mstrict-align -O2 -Wall -Wextra -static -ffunction-sections -fdata-sections -frandom-seed=cheshire -fuse-linker-plugin -flto -Wl,-flto
CHS_SW_CCFLAGS ?= $(CHS_SW_FLAGS) -ggdb -mcmodel=medany -mexplicit-relocs -fno-builtin -fverbose-asm -pipe
CHS_SW_LDFLAGS ?= $(CHS_SW_FLAGS) -nostartfiles -Wl,--gc-sections -Wl,-L$(CHS_SW_LD_DIR)
CHS_SW_ARFLAGS ?= --plugin=$(CHS_SW_LTOPLUG)

CHS_SW_ALL += $(CHS_SW_LIBS) $(CHS_SW_GEN_HDRS) $(CHS_SW_TESTS)

.PRECIOUS: %.elf %.dtb

################
# Dependencies #
################

CHS_SW_DEPS_INCS  = -I$(CHS_SW_DIR)/deps/printf
CHS_SW_DEPS_INCS += -I$(CHS_LLC_DIR)/sw/include
CHS_SW_DEPS_INCS += -I$(AXIRTROOT)/sw/lib
CHS_SW_DEPS_INCS += -I$(OTPROOT)
CHS_SW_DEPS_INCS += -I$(OTPROOT)/sw/include
CHS_SW_DEPS_SRCS  = $(CHS_SW_DIR)/deps/printf/printf.c
CHS_SW_DEPS_SRCS += $(CHS_LLC_DIR)/sw/lib/axi_llc_reg32.c
CHS_SW_DEPS_SRCS += $(AXIRTROOT)/sw/lib/axirt.c
CHS_SW_DEPS_SRCS += $(wildcard $(OTPROOT)/sw/device/lib/base/*.c)
CHS_SW_DEPS_SRCS += $(wildcard $(OTPROOT)/sw/device/lib/dif/*.c)
CHS_SW_DEPS_SRCS += $(wildcard $(OTPROOT)/sw/device/lib/dif/autogen/*.c)

#############
# Libraries #
#############

CHS_SW_INCLUDES   ?= -I$(CHS_SW_DIR)/include $(CHS_SW_DEPS_INCS)
CHS_SW_LIB_SRCS_S  = $(wildcard $(CHS_SW_DIR)/lib/*.S $(CHS_SW_DIR)/lib/**/*.S)
CHS_SW_LIB_SRCS_C  = $(wildcard $(CHS_SW_DIR)/lib/*.c $(CHS_SW_DIR)/lib/**/*.c)
CHS_SW_LIB_SRCS_O  = $(CHS_SW_DEPS_SRCS:.c=.o) $(CHS_SW_LIB_SRCS_S:.S=.o) $(CHS_SW_LIB_SRCS_C:.c=.o)

CHS_SW_LIBS = $(CHS_SW_DIR)/lib/libcheshire.a

$(CHS_SW_DIR)/lib/libcheshire.a: $(CHS_SW_LIB_SRCS_O)
	rm -f $@
	$(CHS_SW_AR) $(CHS_SW_ARFLAGS) -rcsv $@ $^

#####################
# Header generation #
#####################

define chs_sw_gen_hdr_rule
.PRECIOUS: $$(CHS_SW_DIR)/include/regs/$(1).h
CHS_SW_GEN_HDRS += $$(CHS_SW_DIR)/include/regs/$(1).h

$$(CHS_SW_DIR)/include/regs/$(1).h: $(2)
	@mkdir -p $$(dir $$@)
	$$(REGTOOL) --cdefines $$< > $$@
endef

$(eval $(call chs_sw_gen_hdr_rule,clint,$(CLINTROOT)/src/clint.hjson $(CLINTROOT)/.generated))
$(eval $(call chs_sw_gen_hdr_rule,serial_link,$(CHS_ROOT)/hw/serial_link.hjson $(CHS_SLINK_DIR)/.generated))
$(eval $(call chs_sw_gen_hdr_rule,axi_vga,$(AXI_VGA_ROOT)/data/axi_vga.hjson $(AXI_VGA_ROOT)/.generated))
$(eval $(call chs_sw_gen_hdr_rule,idma,$(IDMA_ROOT)/src/frontends/register_64bit_2d/idma_reg64_2d_frontend.hjson))
$(eval $(call chs_sw_gen_hdr_rule,axi_llc,$(CHS_LLC_DIR)/data/axi_llc_regs.hjson))
$(eval $(call chs_sw_gen_hdr_rule,cheshire,$(CHS_ROOT)/hw/regs/cheshire_regs.hjson))
$(eval $(call chs_sw_gen_hdr_rule,axi_rt,$(AXIRTROOT)/src/regs/axi_rt.hjson $(AXIRTROOT)/.generated))

# Generate headers for OT peripherals in the bendered repo itself
CHS_SW_GEN_HDRS += $(OTPROOT)/.generated

###############
# Compilation #
###############

# TODO: track headers with gcc -MM!

# All objects require up-to-date patches and headers
%.o: %.c $(CHS_SW_GEN_HDRS)
	$(CHS_SW_CC) $(CHS_SW_INCLUDES) $(CHS_SW_CCFLAGS) -c $< -o $@

%.o: %.S $(CHS_SW_GEN_HDRS)
	$(CHS_SW_CC) $(CHS_SW_INCLUDES) $(CHS_SW_CCFLAGS) -c $< -o $@

define chs_sw_ld_elf_rule
.PRECIOUS: %.$(1).elf

%.$(1).elf: $$(CHS_SW_LD_DIR)/$(1).ld %.o $$(CHS_SW_LIBS)
	$$(CHS_SW_CC) $$(CHS_SW_INCLUDES) -T$$< $$(CHS_SW_LDFLAGS) -o $$@ $$*.o $$(CHS_SW_LIBS)
endef

$(foreach link,$(patsubst $(CHS_SW_LD_DIR)/%.ld,%,$(wildcard $(CHS_SW_LD_DIR)/*.ld)),$(eval $(call chs_sw_ld_elf_rule,$(link))))

%.dump: %.elf
	$(CHS_SW_OBJDUMP) -d -S $< > $@

%.bin: %.elf
	$(CHS_SW_OBJCOPY) -O binary $< $@

%.dtb: %.dts
	$(CHS_SW_DTC) -I dts -O dtb -o $@ $<

%.memh: %.elf
	$(CHS_SW_OBJCOPY) -O verilog $< $@

###################
# GPT test images #
###################

# Create a GPT disk image from a (firmware) ROM; we add dummy partitions to test our GPT boot code.
%.gpt.bin: %.rom.bin
	rm -f $@
	truncate -s $$(( ($$(stat --printf="%s" $<)/512 + 85)*512 )) $@
	sgdisk -Z --clear -g --set-alignment=1 --new=1:37:40 --new=2:42:-9 --typecode=2:$(CHS_SW_ZSL_TGUID) --new=3:-5:-2 $@ &> /dev/null
	dd if=$< of=$@ bs=512 seek=42 conv=notrunc

# Create hex file from .gpt image
%.gpt.memh: %.gpt.bin
	$(CHS_SW_OBJCOPY) -I binary -O verilog $< $@

# Images from CVA6 SDK (built externally)
CHS_CVA6_SDK_IMGS ?= $(addprefix $(CHS_SW_DIR)/deps/cva6-sdk/install64/,fw_payload.bin uImage)

# Create full Linux disk image
$(CHS_SW_DIR)/boot/linux.%.gpt.bin: $(CHS_SW_DIR)/boot/zsl.rom.bin $(CHS_SW_DIR)/boot/cheshire.%.dtb $(CHS_CVA6_SDK_IMGS)
	truncate -s $(CHS_SW_DISK_SIZE) $@
	sgdisk --clear -g --set-alignment=1 \
		--new=1:64:96 --typecode=1:$(CHS_SW_ZSL_TGUID) \
		--new=2:128:159 --typecode=2:$(CHS_SW_DTB_TGUID) \
		--new=3:2048:8191 --typecode=3:$(CHS_SW_FW_TGUID) \
		--new=4:8192:24575 --typecode=4:8300 \
		--new=5:24576:0 --typecode=5:8200 \
		$@
	dd if=$(word 1,$^) of=$@ bs=512 seek=64 conv=notrunc
	dd if=$(word 2,$^) of=$@ bs=512 seek=128 conv=notrunc
	dd if=$(word 3,$^) of=$@ bs=512 seek=2048 conv=notrunc
	dd if=$(word 4,$^) of=$@ bs=512 seek=8192 conv=notrunc

#########
# Tests #
#########

CHS_SW_TEST_SRCS_S  	= $(wildcard $(CHS_SW_DIR)/tests/*.S)
CHS_SW_TEST_SRCS_C     	= $(wildcard $(CHS_SW_DIR)/tests/*.c)
CHS_SW_TEST_DRAM_DUMP  	= $(CHS_SW_TEST_SRCS_S:.S=.dram.dump) $(CHS_SW_TEST_SRCS_C:.c=.dram.dump)
CHS_SW_TEST_SPM_DUMP   	= $(CHS_SW_TEST_SRCS_S:.S=.spm.dump)  $(CHS_SW_TEST_SRCS_C:.c=.spm.dump)
CHS_SW_TEST_SPM_ROMH   	= $(CHS_SW_TEST_SRCS_S:.S=.rom.memh)  $(CHS_SW_TEST_SRCS_C:.c=.rom.memh)
CHS_SW_TEST_SPM_GPTH   	= $(CHS_SW_TEST_SRCS_S:.S=.gpt.memh)  $(CHS_SW_TEST_SRCS_C:.c=.gpt.memh)

CHS_SW_TESTS = $(CHS_SW_TEST_DRAM_DUMP) $(CHS_SW_TEST_SPM_DUMP) $(CHS_SW_TEST_SPM_ROMH) $(CHS_SW_TEST_SPM_GPTH)
