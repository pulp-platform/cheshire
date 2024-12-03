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

  counter #(.WIDTH(2), .STICKY_OVERFLOW(1'b1)) i_counter (
    .clk_i,
    .rst_ni,
    .clear_i(1'b0),
    .en_i,
    .load_i(reload_cbsr), // only load CBSR as max value during restart_counter or reset
    .down_i(1'b1),
    .d_i(cbsr_i),
    .q_o(count),
    .overflow_o(counter_overflown_o)
  );
  
  assign counter_is_threshold_i = (count == 2'b00);

  // create enable, one pulse for one count
  logic served_control_td_prev;
  `FF(served_control_td_prev, served_control_td_i, 1'b0)
  assign en_i = served_control_td_i && ~served_control_td_prev;

  // create reload, one pulse for one reload
  logic served_bulk_td_prev;
  logic reloadcbsr;
  `FF(served_bulk_td_prev, served_bulk_td_i, 1'b0)
  restart_counter = served_bulk_td_i && ~served_bulk_td_prev;
  assign reload_cbsr = (restart_counter || !rst_ni);

endmodule