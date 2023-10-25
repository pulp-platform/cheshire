#!/usr/bin/env bash

# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

vsim -voptargs=+acc work.axi_riscv_atomics_tb -do "do ../test/axi_riscv_atomics_tb_wave.do; log -r /*; run -a"
