// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Hannah Pochert  <hpochert@ethz.ch>
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

`include "common_cells/registers.svh"

module obi_uart_tx #()
(
  input logic  clk_i,
  input logic  rst_ni,

  input logic  baud_rate_edge_i,
  input logic  double_rate_edge_i,

  output logic txd_o,

  input obi_uart_pkg::reg_read_t      reg_read_i,
  output obi_uart_pkg::tx_reg_write_t reg_write_o
);

  // Import the UART package for definitions and parameters
  import obi_uart_pkg::*;

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Instantiations //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  //--FIFO----------------------------------------------------------------------------------------
  logic fifo_clear;
  logic fifo_full;
  logic fifo_empty;
  logic [7:0] fifo_data_i;
  logic [7:0] fifo_data_o;
  logic fifo_push;
  logic fifo_pop;
  logic [3:0] fifo_usage;

  //--THR-Full------------------------------------------------------------------------------------
  logic thr_full_q, thr_full_d;

  //--Statemachine-Transition-Signals-------------------------------------------------------------
  state_type_tx state_q, state_d;

  logic [2:0] word_len_bits;
  logic [7:0] word_len_mask;

  //--Statemachine-TSR-Signals--------------------------------------------------------------------
  logic tsr_empty;
  logic tsr_finish;
  logic [7:0] tsr_q, tsr_d;
  logic [2:0] tsr_count_q, tsr_count_d;

  logic txd_q, txd_d;

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // FIFO Instantiation //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  fifo_v3 # (
    .FALL_THROUGH(1'b0),
    .DATA_WIDTH  (8), 
    .DEPTH       (16)
  ) i_fifo_v3 (
    .clk_i,
    .rst_ni,
    .flush_i   (fifo_clear),  // flush the queue
    .testmode_i(1'b0      ),       
    // status flags
    .full_o    (fifo_full),   // queue is full
    .empty_o   (fifo_empty),  // queue is empty
    .usage_o   (fifo_usage),  // fill pointer
    // as long as the queue is not full we can push new data
    .data_i    (fifo_data_i), // data to push into the queue
    .push_i    (fifo_push  ), // data is valid and can be pushed to the queue
    // as long as the queue is not empty we can pop new elements
    .data_o    (fifo_data_o), // output data
    .pop_i     (fifo_pop   )  // pop head from queue
  );
  
  ////////////////////////////////////////////////////////////////////////////////////////////////
  // General Logic //
  ////////////////////////////////////////////////////////////////////////////////////////////////
  always_comb begin
    //--------------------------------------------------------------------------------------------
    // Defaults
    //--------------------------------------------------------------------------------------------
    thr_full_d    = thr_full_q;
    word_len_mask = '0;

    //--FIFO Combinational------------------------------------------------------------------------
    fifo_clear  = 1'b0;
    fifo_push   = 1'b0;
    fifo_data_i = '0;

    //--Register Interface------------------------------------------------------------------------
    reg_write_o = '0;

    //--Statemachine Combinational----------------------------------------------------------------
    state_d       = state_q;     // Pass along state

    txd_o         = txd_q & ~reg_read_i.lcr.set_break; // UART Output Assignment
    txd_d         = txd_q;       // UART Output store for one bit time

    fifo_pop      = 1'b0;        // Read and Remove Byte From FIFO

    tsr_d         = tsr_q;       //TSR
    tsr_count_d   = tsr_count_q; //TSR
    tsr_finish    = 1'b0;        //TSR
    tsr_empty     = 1'b0;        //TSR

    //--------------------------------------------------------------------------------------------
    // Word Length 
    //--------------------------------------------------------------------------------------------
    case (reg_read_i.lcr.word_len)
      2'b00: word_len_bits = 3'b100; // 5 Bits (4th index in tsr)
      2'b01: word_len_bits = 3'b101; // 6 Bits (5th index in tsr)
      2'b10: word_len_bits = 3'b110; // 7 Bits (6th index in tsr)
      2'b11: word_len_bits = 3'b111; // 8 Bits (7th index in tsr)
      default: word_len_bits = 3'b111; 
    endcase

    for (int i = 0; i <= word_len_bits; i = i + 1) begin
      word_len_mask[i] = 1'b1;
    end

    //--------------------------------------------------------------------------------------------
    // THR Full Flag
    //--------------------------------------------------------------------------------------------
    if (reg_read_i.obi_write_thr) begin
      thr_full_d = 1'b1;
    end

    //--------------------------------------------------------------------------------------------
    // Reset LSR
    //--------------------------------------------------------------------------------------------
    if (reg_read_i.obi_write_thr) begin
      reg_write_o.thr_empty   = 1'b0;
      reg_write_o.tx_empty    = 1'b0;
      reg_write_o.thr_valid   = 1'b1;
      reg_write_o.empty_valid = 1'b1;
    end

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Statemachine Combinational //
  ////////////////////////////////////////////////////////////////////////////////////////////////

    //--------------------------------------------------------------------------------------------
    // TSR - Transmitter Shift Register (parallel to serial)
    //--------------------------------------------------------------------------------------------
    if (state_q == TXDATA & (tsr_count_q <= word_len_bits)) begin
      txd_d       = tsr_q[tsr_count_q]; 
      if (baud_rate_edge_i) begin
        tsr_count_d = tsr_count_q + 1;
        tsr_finish  = (tsr_count_q == word_len_bits)? 1'b1 : 1'b0;
      end
    end

    //--------------------------------------------------------------------------------------------
    // State Transition
    //--------------------------------------------------------------------------------------------
    case(state_q)
      TXIDLE: begin
        txd_d       = 1'b1; // Inactive High
        tsr_d       = '0;
        tsr_count_d = 1'b0;
        tsr_empty   = 1'b1;
        
        if (reg_read_i.fcr.fifo_en) begin
          if (~fifo_empty & baud_rate_edge_i) begin // Read FIFO into TSR
            tsr_d    = fifo_data_o;
            fifo_pop = 1'b1;
            state_d  = TXSTART;
          end
        end else begin
          if (thr_full_q & baud_rate_edge_i) begin // Read THR into TSR
            tsr_d      = reg_read_i.thr.char_tx & word_len_mask;
            thr_full_d = 1'b0;
            state_d    = TXSTART;
          end
        end
      end

      TXSTART: begin
        txd_d   = 1'b0; 
        if (baud_rate_edge_i) begin
          state_d = TXDATA;
        end
      end

      TXDATA: begin
        if (tsr_finish) begin
          if (reg_read_i.lcr.par_en) begin
            state_d = TXPAR;
          end else begin
            state_d = TXSTOP1;
          end
        end
      end

      TXPAR: begin
        case (reg_read_i.lcr[5:4])// Read Parity Configuration 
          2'b00: txd_d = ~(^tsr_q); // Odd Parity
          2'b01: txd_d = ^tsr_q;    // Even Parity
          2'b10: txd_d = 1'b1;      // Forced 1
          2'b11: txd_d = 1'b0;      // Forced 0
          default: txd_d = 1'b0;
        endcase
        if (baud_rate_edge_i) begin
          state_d = TXSTOP1;
        end
      end

      TXSTOP1: begin
        txd_d = 1'b1; 
        if (reg_read_i.lcr.stop_bits) begin
          // next transaction starts on next baud_rate_edge_i
          state_d = TXIDLE;
        end else if (baud_rate_edge_i) begin
            state_d = TXSTOP2;
        end  
      end

      TXSTOP2: begin
        txd_d = 1'b1;
        if (word_len_bits == 3'b100) begin
          // 1.5 stop bits
          if(double_rate_edge_i) begin
              state_d = TXIDLE;
              // TODO: Do we now have to change the active edge to the other double_rate edge if there is data to send?
          end
        end else begin
          state_d = TXIDLE;
        end
      end

      default: state_d = TXIDLE;
    endcase

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // FIFO Combinational //
  ////////////////////////////////////////////////////////////////////////////////////////////////

    if (reg_read_i.fcr.fifo_en) begin
      //--Reset-FIFO------------------------------------------------------------------------------
      fifo_clear = 1'b0;

      if (reg_read_i.fcr.tx_fifo_rst) begin
        fifo_clear = 1'b1;
        reg_write_o.fifo_rst       = 1'b0; 
        reg_write_o.fifo_rst_valid = 1'b1;
      end 

      //--Set-LSR---------------------------------------------------------------------------------
      if (fifo_empty) begin 
        reg_write_o.thr_empty = 1'b1;
        reg_write_o.thr_valid = 1'b1;
        if (tsr_empty) begin
          reg_write_o.tx_empty    = 1'b1;
          reg_write_o.empty_valid = 1'b1;
        end
      end

      //--Write-FIFO-from-THR---------------------------------------------------------------------
      if (thr_full_q & (~fifo_full)) begin
        fifo_push   = 1'b1;
        fifo_data_i = reg_read_i.thr.char_tx & word_len_mask;
        thr_full_d  = 1'b0;
      end
    end

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // THR Combinational //
  ////////////////////////////////////////////////////////////////////////////////////////////////

    if (~reg_read_i.fcr.fifo_en) begin
      //--Keep-FIFO-cleared-----------------------------------------------------------------------
      fifo_clear = 1'b1;
      //--Set-LSR---------------------------------------------------------------------------------
      if (~thr_full_q) begin
        reg_write_o.thr_empty = 1'b1;
        reg_write_o.thr_valid = 1'b1;
        if (tsr_empty) begin
          reg_write_o.tx_empty    = 1'b1;
          reg_write_o.empty_valid = 1'b1;
        end
      end
    end

  end

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Sequential //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  `FF(thr_full_q, thr_full_d, '0, clk_i, rst_ni)

  `FF(tsr_q, tsr_d, '0, clk_i, rst_ni)
  `FF(tsr_count_q, tsr_count_d, '0, clk_i, rst_ni)

  `FF(txd_q, txd_d, '1, clk_i, rst_ni)

  `FF(state_q, state_d, TXIDLE, clk_i, rst_ni)

endmodule
