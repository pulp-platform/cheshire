# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

set command ""
set script_path [ file dirname [ file normalize [ info script ] ] ]

if { $argc == 1 } {
  set command [lindex $argv 0]
}

puts "Running with SIMULATOR_PATH=$::env(SIMULATOR_PATH) ; GCC_PATH=$::env(GCC_PATH) ; XILINX_SIMLIB_PATH=$::env(XILINX_SIMLIB_PATH) ; VIVADO_PROJECT=$::env(VIVADO_PROJECT)"

# Compile the vivado simlib to XILINX_SIMLIB_PATH
if { $command == "compile_simlib" } {
  set command "compile_simlib -simulator questa -simulator_exec_path {$::env(SIMULATOR_PATH)} \
  -gcc_exec_path {$::env(GCC_PATH)} -family all -language verilog -library all -dir {$::env(XILINX_SIMLIB_PATH)} -force"
  # For some reason this command does not work well when not eval from the string
  eval $command

# Export simulation scripts for each ip
} elseif { $command == "export_simulation" } {
  open_project $::env(VIVADO_PROJECT)
  export_simulation -simulator questa -directory "./ips" -lib_map_path "$::env(XILINX_SIMLIB_PATH)" \
    -absolute_path -force -of_objects [get_ips *]

# Export simulation scripts for each ip
} elseif { $command == "export_example" } {
  open_project $::env(VIVADO_PROJECT)
  open_example_project -dir "./ips" -force [get_ips xlnx_mig_*]

# Export simulation scripts for each ip
} elseif { $command == "export_example_simulation" } {
  open_project $::env(VIVADO_PROJECT)
  export_simulation -lib_map_path "$::env(XILINX_SIMLIB_PATH)" -directory "." -simulator questa \
    -ip_user_files_dir "./ips/$::env(DDR_EXAMPLE)/$::env(DDR_EXAMPLE).ip_user_files" \
    -ipstatic_source_dir "./ips/$::env(DDR_EXAMPLE)/$::env(DDR_EXAMPLE).ip_user_files/ipstatic" -use_ip_compiled_libs -directory "./ips/$::env(DDR_EXAMPLE)/" -absolute_path

# Unknown command
} else {
  puts "[$argv0] Unknown command: $command"
}
