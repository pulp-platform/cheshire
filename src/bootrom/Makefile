# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

BENDER 	      ?= bender

SRCS_C 		  = $(wildcard src/*.c src/**/*.c) $(wildcard $(shell $(BENDER) path axi_llc)/sw/lib/*.c)
OBJS_C 		  = $(SRCS_C:.c=.o)
INCLUDES 	  = -I./src -I../../sw/include -I$(shell $(BENDER) path axi_llc)/sw/include

BASE_FLAGS    ?= -march=rv64gc -mabi=lp64d -O2 -flto -fwhole-program -Wall
C_FLAGS 	  ?= $(BASE_FLAGS) -mcmodel=medany -mexplicit-relocs -fno-builtin
LD_FLAGS 	  ?= $(BASE_FLAGS) -static -nostartfiles -Wl,--gc-sections

RISCV_CC      ?= riscv64-unknown-elf-gcc
RISCV_OBJCOPY ?= riscv64-unknown-elf-objcopy
RISCV_OBJDUMP ?= riscv64-unknown-elf-objdump
RISCV_STRIP   ?= riscv64-unknown-elf-strip


all: bootrom.rcf bootrom.dump bootrom.sv

%.dtb: %.dts
	dtc -I dts -O dtb -o $@ $<

%.o: %.c
	@$(RISCV_CC) $(C_FLAGS) $(INCLUDES) -c $<  -o $@
	@echo "CC    <= $<"

%.dump: %.elf
	$(RISCV_OBJDUMP) -j .text -d $< >$@
	$(RISCV_OBJDUMP) -j .misc -s $< | tail -n +3 >>$@

%.bin: %.elf
	$(RISCV_OBJCOPY) -O binary $< $@

.PRECIOUS: %.pre.memh
%.pre.memh: %.elf
	$(RISCV_OBJCOPY) -O verilog $< $@

%.memh: %.pre.memh
	# Conform to model: reverse bytes, then replace spaces by newlines
	# Relocate all sections from SPM base (0x7...) to 0
	cat $< | tr " " "\n" | sed 's/@7/@0/g' > $@

%.rcf: %.bin
	../../util/gen_bootrom.py $< --arm-rom -p 65536 > $@

%.sv: %.bin
	../../util/gen_bootrom.py --sv-module $* -p 65536 $< > $@

# Do not remove the final .rcf; depends on the correctly change-tracked .elf
clean:
	rm -f *.bin *.dump *.rcf *.elf src/*.o src/**/*.o *.dtb *.o

bootrom.elf: bootrom.S bootrom.ld $(OBJS_C) $(DT_OBJ)
	$(RISCV_CC)  $(INCLUDES) -Tbootrom.ld  $(LD_FLAGS) $< $(OBJS_C) -o $@
