//Dummy, should be hooked up to physical pins of FPGA/ASIC

module sd_bus_cmd_receiver (
  output  logic cmd_o
);
  //hook up to CMD line
  assign cmd_o = 1'b0;
endmodule