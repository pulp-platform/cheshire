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

`include "axi/typedef.svh"
`include "common_cells/registers.svh"

initial begin
    
    
    #1000;
    $finish;
end


endmodule
