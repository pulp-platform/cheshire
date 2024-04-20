# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Florian Zaruba <zarubaf@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

# Open hardware target
set xilinx_root [file dirname [file dirname [file dirname [file normalize [info script]]]]]
source -quiet ${xilinx_root}/scripts/common.tcl
open_target $xilinx_root $argc $argv program

# Additional argument provides bitstream
set bit [lindex $argv 3]

# Flash bitstream and refresh device
current_hw_device $hw_device
set_property PROGRAM.FILE $bit $hw_device
program_hw_devices $hw_device
refresh_hw_device $hw_device
