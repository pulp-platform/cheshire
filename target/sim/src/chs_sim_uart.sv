// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Simulation UART (not synthesizable). Leverages CVA6 Mock UART.

module chs_sim_uart #(
  parameter type reg_req_t,
  parameter type reg_rsp_t
)(
  input  logic clk_i,
  input  logic rst_ni,
  input  reg_req_t reg_req_i,
  output reg_rsp_t reg_rsp_o
);

  typedef struct packed {
    logic [31:0] paddr;
    logic [ 2:0] pprot;
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [31:0] pwdata;
    logic [3:0]  pstrb;
  } apb_req_t;

  typedef struct packed {
    logic pready;
    logic [31:0] prdata;
    logic pslverr;
  } apb_rsp_t;

  apb_req_t  apb_uart_req;
  apb_rsp_t apb_uart_rsp;

  reg_to_apb #(
    .reg_req_t (reg_req_t),
    .reg_rsp_t (reg_rsp_t),
    .apb_req_t (apb_req_t),
    .apb_rsp_t (apb_rsp_t)
  ) i_reg_to_apb (
    .clk_i,
    .rst_ni,
    .reg_req_i,
    .reg_rsp_o,
    .apb_req_o (apb_uart_req),
    .apb_rsp_i (apb_uart_rsp)
  );

  chs_mock_uart i_mock_uart (
    .clk_i,
    .rst_ni,
    .penable_i ( apb_uart_req.penable ),
    .pwrite_i  ( apb_uart_req.pwrite  ),
    .paddr_i   ( apb_uart_req.paddr   ),
    .psel_i    ( apb_uart_req.psel    ),
    .pwdata_i  ( apb_uart_req.pwdata  ),
    .prdata_o  ( apb_uart_rsp.prdata  ),
    .pready_o  ( apb_uart_rsp.pready  ),
    .pslverr_o ( apb_uart_rsp.pslverr )
  );

endmodule : chs_sim_uart

module chs_mock_uart (
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          penable_i,
  input  logic          pwrite_i,
  input  logic [31:0]   paddr_i,
  input  logic          psel_i,
  input  logic [31:0]   pwdata_i,
  output logic [31:0]   prdata_o,
  output logic          pready_o,
  output logic          pslverr_o
);
  localparam RBR = 0;
  localparam THR = 0;
  localparam IER = 1;
  localparam IIR = 2;
  localparam FCR = 2;
  localparam LCR = 3;
  localparam MCR = 4;
  localparam LSR = 5;
  localparam MSR = 6;
  localparam SCR = 7;
  localparam DLL = 0;
  localparam DLM = 1;

  localparam THRE = 5; // transmit holding register empty
  localparam TEMT = 6; // transmit holding register empty

  byte lcr;
  byte dlm;
  byte dll;
  byte mcr;
  byte lsr;
  byte ier;
  byte msr;
  byte scr;
  logic fifo_enabled;
  logic start;

  assign pready_o = 1'b1;
  assign pslverr_o = 1'b0;

  function void uart_tx(logic start, byte ch);
      if (start) $write("[UART] ");
      $write("%c", ch);
  endfunction : uart_tx

/* verilator lint_off WIDTHTRUNC */
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off WIDTHCONCAT */

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      lcr <= 0;
      dlm <= 0;
      dll <= 0;
      mcr <= 0;
      lsr <= 0;
      ier <= 0;
      msr <= 0;
      scr <= 0;
      fifo_enabled <= 1'b0;
      start <= 1'b1;
    end else begin
      if (psel_i & penable_i & pwrite_i) begin
        case ((paddr_i >> 'h2) & 'h7)
          THR: begin
            if (lcr & 'h80) dll <= byte'(pwdata_i[7:0]);
            else begin
              uart_tx(start, byte'(pwdata_i[7:0]));
              if (start) start <= 1'b0;
            end
          end
          IER: begin
            if (lcr & 'h80) dlm <= byte'(pwdata_i[7:0]);
            else ier <= byte'(pwdata_i[7:0] & 'hF);
          end
          FCR: begin
            if (pwdata_i[0]) fifo_enabled <= 1'b1;
            else fifo_enabled <= 1'b0;
          end
          LCR: lcr <= byte'(pwdata_i[7:0]);
          MCR: mcr <= byte'(pwdata_i[7:0] & 'h1F);
          LSR: lsr <= byte'(pwdata_i[7:0]);
          MSR: msr <= byte'(pwdata_i[7:0]);
          SCR: scr <= byte'(pwdata_i[7:0]);
          default:;
        endcase
      end
    end
  end

  always_comb begin
    prdata_o = '0;
    if (psel_i & penable_i & ~pwrite_i) begin
      case ((paddr_i >> 'h2) & 'h7)
        THR: begin
          if (lcr & 'h80) prdata_o = {24'b0, dll};
        end
        IER: begin
          if (lcr & 'h80) prdata_o = {24'b0, dlm};
          else prdata_o = {24'b0, ier};
        end
        IIR: begin
          if (fifo_enabled) prdata_o = {24'b0, 8'hc0};
          else prdata_o = {24'b0, 8'b0};
        end
        LCR: prdata_o = {24'b0, lcr};
        MCR: prdata_o = {24'b0, mcr};
        LSR: prdata_o = {24'b0, (lsr | (1 << THRE) | (1 << TEMT))};
        MSR: prdata_o = {24'b0, msr};
        SCR: prdata_o = {24'b0, scr};
        default:;
      endcase
    end
  end

/* verilator lint_on WIDTHTRUNC */
/* verilator lint_on WIDTHEXPAND */
/* verilator lint_on WIDTHCONCAT */

endmodule: chs_mock_uart
