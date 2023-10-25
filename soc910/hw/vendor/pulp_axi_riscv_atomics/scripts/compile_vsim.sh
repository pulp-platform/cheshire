#!/usr/bin/env bash

# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

if [ "$#" -ne 1 ]; then
    echo "Please specify whether to use the user signal (1) or the id signal (0) for the reservation ID."
    echo 'Use: `'`basename "$0"`' 0` to use the `aw_id` signal as the reservation ID'
    echo 'Use: `'`basename "$0"`' 1` to use the `aw_user` signal as the reservation ID'
    exit 1
fi

bender script vsim -t test \
    -DDEF_USER_AS_ID=$1 \
    --vlog-arg="-svinputport=compat" \
    --vlog-arg="-override_timescale 1ns/1ps" \
    --vlog-arg="-suppress 2583" \
    > compile.tcl
echo "exit" >> compile.tcl

vsim -c -do compile.tcl
