module sd_bus_cmd_driver (
  input   logic sd_cmd_i,
  input   logic cmd_highz_i
  //TODO: Hook up to IO pins of FPGA/ASIC
  //High-Z when cmd_highz_i is active, else OD when cmd_od_i is active
  
endmodule