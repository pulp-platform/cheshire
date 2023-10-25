# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nils Wistoff <nwistoff@iis.ee.ethz.ch>

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR  := $(dir $(MKFILE_PATH))
ROOT        := ${MKFILE_DIR}../
INCLUDES = -I./ -I./src
SRCS_S = src/fencet.S
OBJS_S = $(SRCS_S:.S=.o)

.PHONY: all
all: out/fencet.elf out/fencet.dump

out:
	mkdir -p out

%.o: %.c
	riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imafd -mabi=lp64d -Wall -mcmodel=medany -mexplicit-relocs -fno-builtin $(INCLUDES) -c $<  -o $@
	@echo "CC    <= $<"

%.elf: $(SRCS_S) linker.ld out
	riscv64-unknown-elf-gcc -Tlinker.ld -mabi=lp64d -march=rv64imafd -static -nostartfiles $(INCLUDES) $< -o $@

%.bin: %.elf
	riscv64-unknown-elf-objcopy -O binary $< $@

%.dump: %.elf
	riscv64-unknown-elf-objdump -DxS $< > $@

clean:
	rm -rf out
