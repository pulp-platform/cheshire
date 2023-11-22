// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Yvan Tortorella <yvan.tortorella@unibo.it>

module cva6_wrap
import riscv::*;
import cheshire_pkg::*;
#(
  parameter ariane_pkg::ariane_cfg_t Cva6Cfg = ariane_pkg::ArianeDefaultConfig,
  parameter int unsigned NumHarts     = 1,
  parameter int unsigned AxiAddrWidth = ariane_axi::AddrWidth,
  parameter int unsigned AxiDataWidth = ariane_axi::DataWidth,
  parameter int unsigned AxiIdWidth   = ariane_axi::IdWidth,
  parameter int unsigned ClicNumIrqs  = $clog2(Cva6Cfg.CLICNumInterruptSrc),
  parameter type axi_ar_chan_t = ariane_axi::ar_chan_t,
  parameter type axi_aw_chan_t = ariane_axi::aw_chan_t,
  parameter type axi_w_chan_t  = ariane_axi::w_chan_t,
  parameter type axi_req_t = ariane_axi::req_t,
  parameter type axi_rsp_t = ariane_axi::resp_t
)(
  input  logic                                             clk_i,
  input  logic                                             rstn_i,
  input  doub_bt                                           bootaddress_i,
  input  doub_bt                                           hart_id_i,
  input  logic             [NumHarts-1:0][1:0]             irq_i,
  input  logic             [NumHarts-1:0]                  ipi_i,
  input  logic             [NumHarts-1:0]                  time_irq_i,
  input  logic             [NumHarts-1:0]                  debug_req_i,
  input  logic             [NumHarts-1:0]                  clic_irq_valid_i, // CLIC interrupt request
  input  logic             [NumHarts-1:0][ClicNumIrqs-1:0] clic_irq_id_i, // interrupt source ID
  input  logic             [NumHarts-1:0][7:0]             clic_irq_level_i, // interrupt level is 8-bit from CLIC spec
  input  riscv::priv_lvl_t [NumHarts-1:0]                  clic_irq_priv_i,  // CLIC interrupt privilege level
  input  logic             [NumHarts-1:0]                  clic_irq_v_i,     // CLIC interrupt virtualization bit
  input  logic             [NumHarts-1:0][5:0]             clic_irq_vsid_i,  // CLIC interrupt Virtual Supervisor ID
  input  logic             [NumHarts-1:0]                  clic_irq_shv_i,   // selective hardware vectoring bit
  output logic             [NumHarts-1:0]                  clic_irq_ready_o, // core side interrupt hanshake (ready)
  input  logic             [NumHarts-1:0]                  clic_kill_req_i,  // kill request
  output logic             [NumHarts-1:0]                  clic_kill_ack_o,  // kill acknowledge
  output axi_req_t         [NumHarts-1:0]                  axi_req_o,
  input  axi_rsp_t         [NumHarts-1:0]                  axi_rsp_i
);

for (genvar i = 0; i < NumHarts; i++) begin
  cva6 #(
    .ArianeCfg     ( Cva6Cfg       ),
    .AxiAddrWidth  ( AxiAddrWidth  ),
    .AxiDataWidth  ( AxiDataWidth  ),
    .AxiIdWidth    ( AxiIdWidth    ),
    .axi_ar_chan_t ( axi_ar_chan_t ),
    .axi_aw_chan_t ( axi_aw_chan_t ),
    .axi_w_chan_t  ( axi_w_chan_t  ),
    .axi_req_t     ( axi_req_t     ),
    .axi_rsp_t     ( axi_rsp_t     )
  ) i_core_cva6    (
    .clk_i            ( clk_i                  ),
    .rst_ni           ( rstn_i                 ),
    .boot_addr_i      ( bootaddress_i          ),
    .hart_id_i        ( hart_id_i + 64'(i)     ),
    .irq_i            ( irq_i[i]               ),
    .ipi_i            ( ipi_i[i]               ),
    .time_irq_i       ( time_irq_i[i]          ),
    .debug_req_i      ( debug_req_i[i]         ),
    .clic_irq_valid_i ( clic_irq_valid_i[i]    ),
    .clic_irq_id_i    ( clic_irq_id_i[i]       ),
    .clic_irq_level_i ( clic_irq_level_i[i]    ),
    .clic_irq_priv_i  ( clic_irq_priv_i[i]     ),
    .clic_irq_shv_i   ( clic_irq_shv_i[i]      ),
    .clic_irq_v_i     ( clic_irq_v_i[i]        ),
    .clic_irq_vsid_i  ( clic_irq_vsid_i[i]     ),
    .clic_irq_ready_o ( clic_irq_ready_o[i]    ),
    .clic_kill_req_i  ( clic_kill_req_i[i]     ),
    .clic_kill_ack_o  ( clic_kill_ack_o[i]     ),
    .rvfi_o           (                        ),
    .cvxif_req_o      (                        ),
    .cvxif_resp_i     ( '0                     ),
    .l15_req_o        (                        ),
    .l15_rtrn_i       ( '0                     ),
    .axi_req_o        ( axi_req_o[i]           ),
    .axi_resp_i       ( axi_rsp_i[i]           )
  );
end 

endmodule: cva6_wrap
