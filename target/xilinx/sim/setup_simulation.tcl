
set command ""

if { $argc == 1 } {
  set command [lindex $argv 0]
}

if { $command == "compile_simlib" } {
  compile_simlib -simulator questa -simulator_exec_path {$::env(SIMULATOR_PATH)} \
	-gcc_exec_path {$::env(GCC_PATH)} -family virtexuplus \
	-language verilog -dir {$::env(XILINX_SIMLIB_PATH)} -verbose

} elseif { $command == "export_simulation" } {
  open_project "../cheshire.xpr"
  export_simulation -simulator questa -directory "./ips" -lib_map_path "$::env(XILINX_SIMLIB_PATH)" \
    -absolute_path -force -of_objects [get_ips *]

} else {
  puts "[$argv0] Unknown command: $command"

}
