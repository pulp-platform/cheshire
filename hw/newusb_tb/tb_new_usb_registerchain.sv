// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Testbench module for registerchain

`timescale 1ps/1ps

module tb_new_usb_registerchain #(
  /// Parameters
) (
  /// SoC clock and reset
  // input  logic soc_clk_i,
  // input  logic soc_rst_ni,
);

`include "axi/typedef.svh"
`include "common_cells/registers.svh"

localparam int unsigned Stages = 4;
localparam int unsigned Width = 32;

localparam int unsigned period = 2000; // 500 MHz
localparam int unsigned halfperiod = period/2;
localparam int unsigned input_delay = 100;
localparam int unsigned reset_active = 2*period + 50; // reset active time
localparam int unsigned reset_wait = 1100; // wait for initial reset
localparam int unsigned reset_wait2 = 50*period;
localparam int unsigned en_1 = 6*period;
localparam int unsigned en_2 = 3*period;
localparam int unsigned en_3 = 6*period;
localparam int unsigned en_4 = 8*period;
localparam int unsigned en_5 = 4*period;
localparam int unsigned en_high = 0; //@posedge already creates a one cycle delay

logic clk_i;
logic rst_ni;
logic en;
logic clear;
logic [Width-1:0] data;
// logic [Width*Stages-1:0] register;
logic [Width-1:0] dword0;
logic [Width-1:0] dword1;
logic [Width-1:0] dword2;
logic [Width-1:0] dword3;

initial begin
  clk_i = 1;
  forever #halfperiod clk_i = ~clk_i;
end

initial begin
  rst_ni = 1;
  #reset_wait;
  rst_ni = 0;
  #reset_active;
  rst_ni = 1;
  #reset_wait2;
  rst_ni = 0;
  #reset_active;
  rst_ni = 1;
end

initial begin
    @(posedge clk_i);
    #input_delay;
    en = 0;
    clear = 0;
    data = 32'hABBAABBA;
    @(posedge clk_i);
    #input_delay;
    #en_1;
    data = 32'hABCDEF01;
    en = 1;
    @(posedge clk_i);
    #input_delay;
    #en_high;
    en = 0;
    data = 32'hABBAABBA;
    @(posedge clk_i);
    #input_delay;
    #en_2;
    data = 32'hABCDEF02;
    en = 1;
    @(posedge clk_i);
    #input_delay;
    #en_high;
    en = 0;
    data = 32'hABBAABBA;
    @(posedge clk_i);
    #input_delay;
    #en_3;
    data = 32'hABCDEF03;
    en = 1;
    @(posedge clk_i);
    #input_delay;
    #en_high;
    en = 0;
    data = 32'hABBAABBA;
    @(posedge clk_i);
    #input_delay;
    #en_4;
    data = 32'hABCDEF04;
    en = 1;
    @(posedge clk_i);
    #input_delay;
    #en_high;
    en = 0;
    data = 32'hABBAABBA;
    @(posedge clk_i);
    #input_delay;
    #en_5;
    data = 32'hABCDEF05;
    en = 1;
    @(posedge clk_i);
    #input_delay;
    #en_high;
    en = 0;
    clear = 1;
end

new_usb_registerchain #(
  .Width(Width),
  .Stages(Stages)
) i_registerchain (
  .clk_i,
  .rst_ni, // asynchronous, active low
  .clear_i(clear), // synchronous, active high
  .en_i(en),
  .data_i(data),
  .register_o({dword0, dword1, dword2, dword3})
);

endmodule
