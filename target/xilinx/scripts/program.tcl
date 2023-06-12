# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
# Description: Program Genesys II

open_hw_manager

connect_hw_server -url $::env(HOST):$::env(PORT)

if {$::env(BOARD) eq "genesys2"} {
  open_hw_target $::env(HOST):$::env(PORT)/$::env(FPGA_PATH)

  current_hw_device [get_hw_devices xc7k325t_0]
  set_property PROGRAM.FILE $::env(BIT) [get_hw_devices xc7k325t_0]
  program_hw_devices [get_hw_devices xc7k325t_0]
  refresh_hw_device [lindex [get_hw_devices xc7k325t_0] 0]
} elseif {$::env(BOARD) eq "vc707"} {
  open_hw_target {$::env(HOST):$::env(PORT)/$::env(FPGA_PATH)}

  current_hw_device [get_hw_devices xc7vx485t_0]
  set_property PROGRAM.FILE $::env(BIT) [get_hw_devices xc7vx485t_0]
  program_hw_devices [get_hw_devices xc7vx485t_0]
  refresh_hw_device [lindex [get_hw_devices xc7vx485t_0] 0]
} else {
      exit 1
}
