#! /usr/bin/env bash
#
# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cheshire disk flashing script invoking OpenOCD and GDB.
# Writes in sectors of 256 KiB.
#
# Arguments:
# $1: target board
# $2: target disk
# $3: (optional): disk image
# $4: (optional): copy length in 256KiB sectors (if more than one sector fits)
# $5: (optional): copy offset in 256KiB sectors (if more than one sector fits)

set -e

# Determine the image name and size
img=${3:-sw/boot/linux.${1}.gpt.bin}
# Ensure the image exists and determine rounded-up size
len=${4:-$(stat -c%s ${img})}
len=$((len/(256*1024)+1))

# Run OpenOCD and GDB
openocd -f util/openocd.${1}.tcl &
sleep 2
riscv64-unknown-elf-gdb --batch \
    -ex "set \$target = ${2:-1}" \
    -ex "set \$img = \"${img}\"" \
    -ex "set \$len = ${len}" \
    -ex "set \$offs = ${5:-0}" \
    -ex "source util/flash_disk.gdb"
wait
