// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Register chain with variable width and stages 

module new_usb_registerchain #(
  parameter int unsigned Width  = 0,
  parameter int unsigned Stages = 0,
  parameter int unsigned Total  = Width*Stages
)(
  input  logic clk_i,
  input  logic rst_ni,
  input  logic en,
  input  logic [Width-1:0] data_i,
  output logic [Total-1:0] register
);
  generate
    genvar i;
    for (i = 0; i < Total; i = i + Width) begin
      if(i == 0) `FFL(register[Width-1:0],   data_i,                en, '0)
      else       `FFL(register[Width+i-1:i], register[i-1:i-Width], en, '0)
    end
  endgenerate
endmodule