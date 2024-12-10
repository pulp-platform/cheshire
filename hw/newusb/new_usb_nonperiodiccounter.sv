// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// nonperiodic scheduling counter

module new_usb_nonperiodiccounter (
  
  input  logic clk_i,
  input  logic rst_ni,
  input  logic served_bulk_td_i, // successfully served bulk transfer descriptor
  input  logic served_control_td_i, // successfully served control transfer descriptor
  input  logic [1:0] cbsr_i,
  
  output logic counter_overflown_o, // enough control EDs served
  output logic counter_is_threshold_o // signals last control ED to send for listservice

);
  
  `include "common_cells/registers.svh"

  logic [1:0] count;
  logic restart_counter;
  logic en;
  logic served_control_td_prev;
  logic served_bulk_td_prev;
  logic reload_cbsr_early;
  logic reload_cbsr;

  counter #(.WIDTH(2), .STICKY_OVERFLOW(1'b1)) i_counter (
    .clk_i,
    .rst_ni,
    .clear_i(1'b0),
    .en_i(en),
    .load_i(reload_cbsr), // only load CBSR as max value during restart_counter or reset
    .down_i(1'b1),
    .d_i(cbsr_i),
    .q_o(count),
    .overflow_o(counter_overflown_o)
  );
  
  assign counter_is_threshold_o = (count == 2'b00); // Gets high mistakenly for one cycle (counter resets to 0) at reset or clear, no problem because it's only used one cycle later

  // create enable, one pulse for one count
  `FF(served_control_td_prev, served_control_td_i, 1'b0)
  assign en = served_control_td_i && ~served_control_td_prev;

  // create reload, one pulse for one reload
  `FF(served_bulk_td_prev, served_bulk_td_i, 1'b0)
  assign restart_counter = served_bulk_td_i && ~served_bulk_td_prev;
  `FFLARNC(reload_cbsr_early, 1'b0, 1'b1, restart_counter, 1'b1, clk_i, rst_ni) // permanent high enable
  //`FFLARNC(__q, __d,  __load, __clear, __reset_value, __clk, __arst_n)
  `FF(reload_cbsr, reload_cbsr_early, 1'b0)

endmodule