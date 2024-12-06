// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Testbench module for nonperiodiccounter

`timescale 1ps/1ps

module tb_new_usb_nonperiodiccounter #(
  /// Parameters
) (
  /// SoC clock and reset
  // input  logic soc_clk_i,
  // input  logic soc_rst_ni,
);

`include "common_cells/registers.svh"

logic clk_i;
logic rst_ni;

initial begin
    clk_i = 0;
    forever #100 clk_i = ~clk_i;
end

initial begin
    rst_ni = 1;
    #1000 
    rst_ni = 0;
    #20
    rst_ni = 1;
end

endmodule
