// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Hannah Pochert  <hpochert@ethz.ch>
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

`include "common_cells/registers.svh"

module obi_uart #(
  /// The OBI configuration connected to this peripheral.
  parameter obi_pkg::obi_cfg_t ObiCfg = obi_pkg::ObiDefaultConfig, // SbrObiCfg
  /// OBI request type
  parameter type obi_req_t = logic,
  /// OBI response type
  parameter type obi_rsp_t = logic
) (
  input logic      clk_i,  // Primary input clock
  input logic      rst_ni, // Asynchronous active-low reset

  // OBI request interface
  input  obi_req_t obi_req_i, // a.addr, a.we, a.be, a.wdata, a.aid, a.a_optional | rready, req
  // OBI response interface
  output obi_rsp_t obi_rsp_o, // r.rdata, r.rid, r.err, r.r_optional | gnt, rvalid

  output logic     irq_o,   // Interrupt line
  output logic     irq_no,  // Negated Interrupt line

  input  logic     rxd_i,  // Serial Input
  output logic     txd_o,  // Serial Output

  // Modem control pins are optional
  input  logic     cts_ni,  // Modem Inp Clear To Send
  input  logic     dsr_ni,  // Modem Inp Data Send Request
  input  logic     ri_ni,   // Modem Inp Ring Indicator
  input  logic     cd_ni,   // Modem Inp Carrier Detect
  output logic     rts_no,  // Modem Oup Ready To Send
  output logic     dtr_no,  // Modem Oup DaTa Ready
  output logic     out1_no, // Modem Oup DaTa Ready, optional outputs
  output logic     out2_no  // Modem Oup DaTa Ready, optional outputs
);
  // Import the UART package for definitions and parameters
  import obi_uart_pkg::*;

  //--Receiver-and-Transmitter-Interface----------------------------------------------------------
  logic rxd;
  logic txd;

  //--Receiver-Interrupt-Interface----------------------------------------------------------------
  logic rx_fifo_trigger;
  logic rx_timeout;

  //--Register-Interface-Signals------------------------------------------------------------------
  reg_read_t         reg_read;     // signals read from the registers
  reg_write_t        reg_write;    // new values being written to registers

  //--Baudenable-Interface-Signals----------------------------------------------------------------
  logic oversample_rate_edge;
  logic double_rate_edge;
  logic baud_rate_edge;

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // REGISTER INTERFACE //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  obi_uart_register #(
    .obi_req_t (obi_req_t),
    .obi_rsp_t (obi_rsp_t)
  ) i_uart_register (
    .clk_i,
    .rst_ni,

    .obi_req_i,
    .obi_rsp_o,

    .reg_read_o  (reg_read),
    .reg_write_i (reg_write)
  );

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // MODEM CONTROL //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  obi_uart_modem #(
  ) i_uart_modem (
    .clk_i,
    .rst_ni,

    .cts_ni,
    .dsr_ni,
    .ri_ni,
    .cd_ni,
    .rts_no,
    .dtr_no,
    .out1_no,
    .out2_no,

    .reg_read_i  (reg_read),
    .reg_write_o (reg_write.modem)
  );

  //--Loopback-Mode-------------------------------------------------------------------------------
  assign txd_o = (reg_read.mcr.loopback == 1'b1) ? 1'b1 : txd;
  assign rxd   = (reg_read.mcr.loopback == 1'b1) ? txd  : rxd_i;

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // BAUDRATE GENERATION //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  obi_uart_baudgen #(
  ) i_uart_baudgen (
    .clk_i,
    .rst_ni,

    .oversample_rate_edge_o(oversample_rate_edge),
    .double_rate_edge_o    (double_rate_edge),
    .baud_rate_edge_o      (baud_rate_edge),

    .reg_read_i (reg_read)
  );

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // RECEIVE //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  obi_uart_rx # (
  ) i_uart_rx (
    .clk_i,
    .rst_ni,

    .oversample_rate_edge_i (oversample_rate_edge),
    .baud_rate_edge_i       (baud_rate_edge),

    .rxd_i       (rxd),

    .trigger_o   (rx_fifo_trigger),
    .timeout_o   (rx_timeout),

    .reg_read_i  (reg_read),
    .reg_write_o (reg_write.rx)
  );

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // TRANSMIT //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  obi_uart_tx # (
  ) i_uart_tx (
    .clk_i,
    .rst_ni,

    .baud_rate_edge_i   (baud_rate_edge),
    .double_rate_edge_i (double_rate_edge),

    .txd_o       (txd),

    .reg_read_i  (reg_read),
    .reg_write_o (reg_write.tx)
  );

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // INTERRUPT CONTROL //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  obi_uart_interrupts #(
  ) i_uart_interrupts (
    .clk_i,
    .rst_ni,

    .rx_fifo_trigger,
    .rx_timeout,

    .irq_o,
    .irq_no,

    .reg_read_i  (reg_read),
    .reg_write_i (reg_write),
    .reg_isr_o (reg_write.isr)
  );

endmodule
