# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
# Description: Program Genesys II

open_hw

connect_hw_server -url localhost:3121

if {$::env(BOARD) eq "genesys2"} {
  open_hw_target {localhost:3121/xilinx_tcf/Digilent/200300A8CD43B}

  current_hw_device [get_hw_devices xc7k325t_0]
  set_property PROGRAM.FILE {$::env(BIT)} [get_hw_devices xc7k325t_0]
  program_hw_devices [get_hw_devices xc7k325t_0]
  refresh_hw_device [lindex [get_hw_devices xc7k325t_0] 0]
} elseif {$::env(BOARD) eq "vc707"} {
  open_hw_target {localhost:3121/xilinx_tcf/Digilent/210203A5FC70A}

  current_hw_device [get_hw_devices xc7vx485t_0]
  set_property PROGRAM.FILE {$::env(BIT)} [get_hw_devices xc7vx485t_0]
  program_hw_devices [get_hw_devices xc7vx485t_0]
  refresh_hw_device [lindex [get_hw_devices xc7vx485t_0] 0]
} else {
      exit 1
}
