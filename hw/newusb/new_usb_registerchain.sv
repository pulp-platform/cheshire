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
  parameter int unsigned Total  = Width*Stages // don't overwrite
)(
  input  logic clk_i,
  input  logic rst_ni, // asynchronous, active low
  input  logic clear_i, // synchronous, active high
  input  logic en_i,
  input  logic [Width-1:0] data_i,
  output logic [Total-1:0] register_o
);

`include "common_cells/registers.svh"

  generate
    genvar i;
    for (i = 0; i < Total; i = i + Width) begin
      if(i == 0) `FFLARNC(register[Width-1:0],   data_i,                en, clear, '0, clk_i, rst_ni)
      else       `FFLARNC(register[Width+i-1:i], register[i-1:i-Width], en, clear, '0, clk_i, rst_ni) 
                 //`FFLARNC(__q, __d,  __load, __clear, __reset_value, __clk, __arst_n)
    end
  endgenerate
endmodule