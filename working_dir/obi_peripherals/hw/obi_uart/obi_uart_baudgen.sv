// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Hannah Pochert  <hpochert@ethz.ch>
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

`include "common_cells/registers.svh"

/// Generates clock enable signals for the required baud multiples
module obi_uart_baudgen import obi_uart_pkg::*; #()
(
  input logic  clk_i,
  input logic  rst_ni,

  output logic oversample_rate_edge_o, // oversample clock enable signal
  output logic double_rate_edge_o,     // doubled baud clock enable signal
  output logic baud_rate_edge_o,       // baud clock enable signal

  input reg_read_t reg_read_i
);

  // Import the UART package for definitions and parameters

  //-- Configuration Signals ---------------------------------------------------------------------
  logic [15:0] divisor;
  logic        divisor_valid;

  //-- Oversample Signals ------------------------------------------------------------------------
  logic        oversample_is_divisor;
  logic        oversample_clear;
  logic [15:0] oversample_count;

  //-- Double Baud Signals -----------------------------------------------------------------------
  logic       clear_double_d, clear_double_q;
  logic       count_is_double;

  //-- Baud Signals ------------------------------------------------------------------------------
  logic       baud_clear;
  logic [3:0] baud_count;
  logic       baud_count_overflow;

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Clock Division //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  //----------------------------------------------------------------------------------------------
  // Oversample 16x
  //----------------------------------------------------------------------------------------------

  // Concatenate most significant byte and least significant byte of Divisor
  // -1 since we clear to zero when reaching divisor, takes one cycle
  assign divisor = {reg_read_i.dlm, reg_read_i.dll} - 16'd1;
  // divisor reset value is 0 and per the 16550A formula it has no meaning -> invalid
  assign divisor_valid = ~(divisor == 0);
  assign oversample_is_divisor = (oversample_count == divisor) & divisor_valid;
  // clear on reaching the divisor or when configuration changes
  assign oversample_clear = oversample_is_divisor | reg_read_i.obi_write_dllm;

  counter #(
    .WIDTH           (16),
    .STICKY_OVERFLOW (0)
  ) i_oversample_counter (
    .clk_i,
    .rst_ni,
    .clear_i   ( oversample_clear ), // Synchronous clear: Sets Counter 0 in the next cycle
    .en_i      ( divisor_valid    ), // Count only if configuration is high
    .load_i    ( 1'b0             ),
    .down_i    ( 1'b0             ), // Count upwards
    .d_i       ( '0               ),
    .q_o       ( oversample_count ),
    .overflow_o(                  )  // Set when counter overflows from '1 to '0
  );

  // high for one clock cycle
  assign oversample_rate_edge_o = (oversample_count == '0) & divisor_valid;

  //----------------------------------------------------------------------------------------------
  // Baudrate
  //----------------------------------------------------------------------------------------------
  // Counts when oversample hits target, counter has the new value in the next cycle
  // the same cycle when oversample_rate_edge_o goes high

  assign baud_clear = baud_count_overflow | reg_read_i.obi_write_dllm;

  counter #(
    .WIDTH          (4),
    .STICKY_OVERFLOW(0)
  ) i_baudrate_counter (
    .clk_i,
    .rst_ni,
    .clear_i   ( baud_clear            ), // Synchronous clear: Sets Counter 0 in the next cycle
    .en_i      ( oversample_is_divisor ), // Count every time oversample counter hits its target
    .load_i    ( 1'b0                  ),
    .down_i    ( 1'b0                  ), // Count upwards
    .d_i       ( '0                    ),
    .q_o       ( baud_count            ),
    .overflow_o( baud_count_overflow   )
  );

  // oversample hits target, counter overflows on the next clock cycle and then clears itself
  // therefore baud_rate_edge_o is high in the same cycle as oversample_rate_edge_o
  assign baud_rate_edge_o = baud_count_overflow;

  // Double baud rate directly generated from baudrate counter
  assign count_is_double    = (baud_count[2:0] == '0); // last three bits zero
  // clear_double turns the pulse off after one clock cycle
  assign clear_double_d     = count_is_double;
  assign double_rate_edge_o = count_is_double & ~clear_double_q;

  `FF(clear_double_q, clear_double_d, '0, clk_i, rst_ni)

endmodule
