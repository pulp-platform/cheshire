// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Max Wipfli <mwipfli@student.ethz.ch>

`include "common_cells/registers.svh"

module verilator_uart_rx #(
  parameter  int unsigned BaudPeriodCycles = 1736,
  localparam int unsigned DataBits         = 8
) (
  input logic clk_i,
  input logic rst_ni,
  input logic uart_rx_i,

  output logic                data_valid_o,
  output logic [DataBits-1:0] data_o
);

  localparam int unsigned CounterWidth = $clog2(BaudPeriodCycles) + 1;

  logic start;
  logic sample;

  //////////////////
  //  baud clock  //
  //////////////////


  logic [CounterWidth-1:0] baud_counter_q, baud_counter_d;
  `FF(baud_counter_q, baud_counter_d, '0);

  always_comb begin
    baud_counter_d = baud_counter_q + 1'b1;
    sample         = 1'b0;

    if (start) begin
      baud_counter_d = BaudPeriodCycles / 2;
    end else if (baud_counter_d == BaudPeriodCycles) begin
      baud_counter_d = '0;
      sample         = 1'b1;
    end
  end

  //////////////////////
  //  shift register  //
  //////////////////////

  logic [DataBits-1:0] data_sr_q, data_sr_d;
  `FF(data_sr_q, data_sr_d, '0);

  logic data_sr_push;

  always_comb begin
    data_sr_d = data_sr_q;
    if (data_sr_push) begin
      data_sr_d = {uart_rx_i, data_sr_q[DataBits-1:1]};
    end
  end

  assign data_o = data_sr_q;

  /////////////////////
  //  state machine  //
  /////////////////////

  typedef enum logic [1:0] {
    StIdle,
    StStartBit,
    StDataBit,
    StStopBit
  } state_e;

  state_e state_q, state_d;
  `FF(state_q, state_d, StIdle);

  logic [$clog2(DataBits):0] bit_counter_q, bit_counter_d;
  `FF(bit_counter_q, bit_counter_d, '0);

  always_comb begin
    state_d       = state_q;
    start         = 1'b0;
    data_sr_push  = 1'b0;
    bit_counter_d = bit_counter_q;
    data_valid_o  = 1'b0;

    unique case (state_q)
      StIdle: begin
        if (uart_rx_i == 1'b0) begin
          state_d       = StStartBit;
          start         = 1'b1;
          bit_counter_d = 1'b0;
        end
      end
      StStartBit: begin
        if (sample) begin
          state_d = StDataBit;
        end
      end
      StDataBit: begin
        if (sample) begin
          data_sr_push  = 1'b1;
          bit_counter_d = bit_counter_q + 1'b1;
          if (bit_counter_d == DataBits) begin
            state_d = StStopBit;
          end
        end
      end
      StStopBit: begin
        if (sample) begin
          state_d      = StIdle;
          data_valid_o = 1'b1;
        end
      end
      default: begin
        state_d = StIdle;
      end
    endcase
  end

endmodule
