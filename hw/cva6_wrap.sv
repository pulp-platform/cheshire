// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Yvan Tortorella <yvan.tortorella@unibo.it>

`include "axi/assign.svh"

module cva6_wrap #(
  parameter cheshire_pkg::cheshire_cfg_t Cfg = '0,
  parameter ariane_pkg::ariane_cfg_t Cva6Cfg = ariane_pkg::ArianeDefaultConfig,
  parameter int unsigned NumHarts     = 1,
  parameter int unsigned AxiAddrWidth = ariane_axi::AddrWidth,
  parameter int unsigned AxiDataWidth = ariane_axi::DataWidth,
  parameter int unsigned AxiIdWidth   = ariane_axi::IdWidth,
  parameter int unsigned ClicNumIrqs  = $clog2(Cva6Cfg.CLICNumInterruptSrc),
  parameter type reg_req_t = logic,
  parameter type reg_rsp_t = logic,
  parameter type axi_ar_chan_t = ariane_axi::ar_chan_t,
  parameter type axi_aw_chan_t = ariane_axi::aw_chan_t,
  parameter type axi_w_chan_t  = ariane_axi::w_chan_t,
  parameter type axi_req_t = ariane_axi::req_t,
  parameter type axi_rsp_t = ariane_axi::resp_t
)(
  input  logic                                             clk_i,
  input  logic                                             rstn_i,
  input  cheshire_pkg::doub_bt                             bootaddress_i,
  input  cheshire_pkg::doub_bt                             hart_id_i,
  input  logic             [NumHarts-1:0][1:0]             irq_i,
  input  logic             [NumHarts-1:0]                  ipi_i,
  input  logic             [NumHarts-1:0]                  time_irq_i,
  input  logic             [NumHarts-1:0]                  debug_req_i,
  input  logic             [NumHarts-1:0]                  clic_irq_valid_i,
  input  logic             [NumHarts-1:0][ClicNumIrqs-1:0] clic_irq_id_i,
  input  logic             [NumHarts-1:0][7:0]             clic_irq_level_i,
  input  riscv::priv_lvl_t [NumHarts-1:0]                  clic_irq_priv_i,
  input  logic             [NumHarts-1:0]                  clic_irq_v_i,
  input  logic             [NumHarts-1:0][5:0]             clic_irq_vsid_i,
  input  logic             [NumHarts-1:0]                  clic_irq_shv_i,
  output logic             [NumHarts-1:0]                  clic_irq_ready_o,
  input  logic             [NumHarts-1:0]                  clic_kill_req_i,
  output logic             [NumHarts-1:0]                  clic_kill_ack_o,
  input  reg_req_t                                         reg_req_i,
  output reg_rsp_t                                         reg_rsp_o,
  output axi_req_t         [NumHarts-1:0]                  axi_req_o,
  input  axi_rsp_t         [NumHarts-1:0]                  axi_rsp_i
);

typedef struct packed {
  cheshire_pkg::doub_bt    bootaddress;
  cheshire_pkg::doub_bt    hart_id;
  logic  [1:0]             irq;
  logic                    ipi;
  logic                    time_irq;
  logic                    debug_req;
  logic                    clic_irq_valid;
  logic  [ClicNumIrqs-1:0] clic_irq_id;
  logic  [7:0]             clic_irq_level;
  riscv::priv_lvl_t        clic_irq_priv;
  logic                    clic_irq_v;
  logic  [5:0]             clic_irq_vsid;
  logic                    clic_irq_shv;
  logic                    clic_kill_req;
  axi_rsp_t                axi_rsp;
} cva6_inputs_t;

typedef struct packed {
  logic clic_irq_ready;
  logic clic_kill_ack;
  axi_req_t axi_req;
} cva6_outputs_t;

logic          [NumHarts-1:0] core_setback;
cva6_inputs_t  [NumHarts-1:0] sys2hmr, hmr2core;
cva6_outputs_t [NumHarts-1:0] hmr2sys, core2hmr;

for (genvar i = 0; i < NumHarts; i++) begin: gen_cva6_cores
  // Bind system inputs to HMR.
  assign sys2hmr[i].bootaddress    = bootaddress_i; // TODO: differentiate?
  assign sys2hmr[i].hart_id        = hart_id_i + 64'(i);
  assign sys2hmr[i].irq            = irq_i[i];
  assign sys2hmr[i].ipi            = ipi_i[i];
  assign sys2hmr[i].time_irq       = time_irq_i[i];
  assign sys2hmr[i].debug_req      = debug_req_i[i];
  assign sys2hmr[i].clic_irq_valid = clic_irq_valid_i[i];
  assign sys2hmr[i].clic_irq_id    = clic_irq_id_i[i];
  assign sys2hmr[i].clic_irq_level = clic_irq_level_i[i];
  assign sys2hmr[i].clic_irq_priv  = clic_irq_priv_i[i];
  assign sys2hmr[i].clic_irq_v     = clic_irq_v_i[i];
  assign sys2hmr[i].clic_irq_vsid  = clic_irq_vsid_i[i];
  assign sys2hmr[i].clic_irq_shv   = clic_irq_shv_i[i];
  assign sys2hmr[i].clic_kill_req  = clic_kill_req_i[i];
  `AXI_ASSIGN_RESP_STRUCT(sys2hmr[i].axi_rsp, axi_rsp_i[i]);

  // Bind HMR outputs to system.
  assign clic_irq_ready_o[i] = hmr2sys[i].clic_irq_ready;
  assign clic_kill_ack_o[i]  = hmr2sys[i].clic_kill_ack;
  `AXI_ASSIGN_REQ_STRUCT(axi_req_o[i], hmr2sys[i].axi_req);

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
    .clk_i            ( clk_i                         ),
    .rst_ni           ( rstn_i                        ),
    .clear_i          ( core_setback[i]               ),
    .boot_addr_i      ( hmr2core[i].bootaddress       ),
    .hart_id_i        ( hmr2core[i].hart_id           ),
    .irq_i            ( hmr2core[i].irq               ),
    .ipi_i            ( hmr2core[i].ipi               ),
    .time_irq_i       ( hmr2core[i].time_irq          ),
    .debug_req_i      ( hmr2core[i].debug_req         ),
    .clic_irq_valid_i ( hmr2core[i].clic_irq_valid    ),
    .clic_irq_id_i    ( hmr2core[i].clic_irq_id       ),
    .clic_irq_level_i ( hmr2core[i].clic_irq_level    ),
    .clic_irq_priv_i  ( hmr2core[i].clic_irq_priv     ),
    .clic_irq_shv_i   ( hmr2core[i].clic_irq_shv      ),
    .clic_irq_v_i     ( hmr2core[i].clic_irq_v        ),
    .clic_irq_vsid_i  ( hmr2core[i].clic_irq_vsid     ),
    .clic_irq_ready_o ( core2hmr[i].clic_irq_ready    ),
    .clic_kill_req_i  ( hmr2core[i].clic_kill_req     ),
    .clic_kill_ack_o  ( core2hmr[i].clic_kill_ack     ),
    .rvfi_o           (                               ),
    .cvxif_req_o      (                               ),
    .cvxif_resp_i     ( '0                            ),
    .l15_req_o        (                               ),
    .l15_rtrn_i       ( '0                            ),
    .axi_req_o        ( core2hmr[i].axi_req           ),
    .axi_resp_i       ( hmr2core[i].axi_rsp           )
  );
end

if (NumHarts > 1) begin: gen_multicore_hmr
  hmr_unit #(
    .NumCores          ( NumHarts          ),
    .DMRSupported      ( Cfg.Cva6DMR       ),
    .DMRFixed          ( Cfg.Cva6DMRFixed  ), // TODO: make configurable
    .TMRSupported      ( 0                 ),
    .RapidRecovery     ( Cfg.RapidRecovery ),
    .SeparateData      ( 0                 ),
    .RfAddrWidth       ( 5                 ),
    .SysDataWidth      ( 64                ),
    .all_inputs_t      ( cva6_inputs_t     ), // Inputs from the system to the HMR
    .nominal_outputs_t ( cva6_outputs_t    ),
    // .core_backup_t     ( '0 ), // TODO
    // .bus_outputs_t     ( '0 ), // TODO
    .reg_req_t         ( reg_req_t ), // TODO
    .reg_rsp_t         ( reg_rsp_t ), // TODO
    .rapid_recovery_t  ( rapid_recovery_pkg::rapid_recovery_t ) // TODO
  ) i_cva6_hmr (
    .clk_i              ( clk_i         ),
    .rst_ni             ( rstn_i        ),
    .reg_request_i      ( reg_req_i     ),
    .reg_response_o     ( reg_rsp_o     ),
    .tmr_failure_o      ( /* Not used */),
    .tmr_error_o        ( /* Not used */), // Should this not be NumTMRCores? or NumCores?
    .tmr_resynch_req_o  ( /* Not used */),
    .tmr_sw_synch_req_o ( /* Not used */),
    .tmr_cores_synch_i  ( '0            ), // Not used

    // DMR signals
    .dmr_failure_o      ( /* TODO */ ),
    .dmr_error_o        ( /* TODO */ ), // Should this not be NumDMRCores? or NumCores?
    .dmr_resynch_req_o  ( /* TODO */ ),
    .dmr_sw_synch_req_o ( /* TODO */ ),
    .dmr_cores_synch_i  ( '0         ),

    // Rapid recovery buses
    .rapid_recovery_o ( /* TODO */ ),
    .core_backup_i    (  '0        ), // TODO

    .sys_inputs_i          ( sys2hmr ),
    .sys_nominal_outputs_o ( hmr2sys ),
    .sys_bus_outputs_o     (         ),
    .sys_fetch_en_i        ( '0      ), // TODO?
    .enable_bus_vote_i     ( '0      ), // TODO?

    .core_setback_o         ( core_setback ),
    .core_inputs_o          ( hmr2core     ),
    .core_nominal_outputs_i ( core2hmr     ),
    .core_bus_outputs_i     ( '0           ) // TODO?
  );

  /* We temporarily hardcode this for permanent lockstep.*/
  // assign hmr2sys[NumHarts-1] = '0;
end else begin : gen_single_core_binding
  assign core_setback = '0;
  assign hmr2core = sys2hmr ;
  assign hmr2sys  = core2hmr;

  // reg error slave when HMR not supported
  reg_err_slv #(
    .DW       ( 32 ),
    .ERR_VAL  ( 32'hBADCAB1E ),
    .req_t    ( reg_req_t ),
    .rsp_t    ( reg_rsp_t )
  ) i_cva6_hmr_err_slv (
    .req_i  ( reg_req_i ),
    .rsp_o  ( reg_rsp_o )
  );

end

endmodule: cva6_wrap
