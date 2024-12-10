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

localparam int unsigned period = 2000; // 500 MHz
localparam int unsigned halfperiod = period/2;
localparam int unsigned input_delay = 100;
localparam int unsigned reset_active = 2*period + 50; // reset active time
localparam int unsigned reset_wait = 1100; // wait for initial reset
localparam int unsigned td_1c = 6*period; // First Control TD served takes very long after a complete reset until this happens
localparam int unsigned td_2c = 3*period;
localparam int unsigned td_3c = 6*period;
localparam int unsigned td_4c = 8*period;
localparam int unsigned td_b = 4*period;
localparam int unsigned td_high = 4*period; // How long served is high

logic clk_i;
logic rst_ni;
logic served_control_td;
logic served_bulk_td;
logic [1:0] cbsr;
logic overflow;
logic threshold;

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
end

initial begin
    @(posedge clk_i);
    #input_delay;
    served_control_td = 0;
    served_bulk_td = 0;
    cbsr = 0;
    @(posedge clk_i);
    #input_delay;
    #period;
    cbsr = 3;
    #td_1c;
    served_control_td = 1;
    @(posedge clk_i);
    #input_delay;
    #td_high;
    served_control_td = 0;
    @(posedge clk_i);
    #input_delay;
    #td_2c;
    served_control_td = 1;
    @(posedge clk_i);
    #input_delay;
    #td_high;
    served_control_td = 0;
    @(posedge clk_i);
    #input_delay;
    #td_3c;
    served_control_td = 1;
    @(posedge clk_i);
    #input_delay;
    cbsr = 1;
    #td_high;
    served_control_td = 0;
    @(posedge clk_i);
    #input_delay;
    #td_4c;
    served_control_td = 1;
    @(posedge clk_i);
    #input_delay;
    #td_high;
    served_control_td = 0;
    @(posedge clk_i);
    #input_delay;
    #td_b;
    served_bulk_td = 1;
    @(posedge clk_i);
    #input_delay;
    #td_high;
    served_bulk_td = 0;
end

new_usb_nonperiodiccounter i_nonperiodiccounter (
  .clk_i,
  .rst_ni,
  .served_bulk_td_i(served_bulk_td), // successfully served bulk transfer descriptor
  .served_control_td_i(served_control_td), // successfully served control transfer descriptor
  .cbsr_i(cbsr),
  .counter_overflown_o(overflow), // enough control EDs served
  .counter_is_threshold_o(threshold) // signals last control ED to send for listservice
);

endmodule
