// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Yvan Tortorella <yvan.tortorella@unibo.it>

`include "ace/assign.svh"

module cva6_wrap #(
  parameter cheshire_pkg::cheshire_cfg_t Cfg = '0,
  parameter config_pkg::cva6_cfg_t Cva6Cfg = cva6_config_pkg::cva6_cfg,
  parameter int unsigned NumHarts     = 1,
  parameter int unsigned ClicNumIrqs  = $clog2(Cva6Cfg.CLICNumInterruptSrc),
  parameter type reg_req_t = logic,
  parameter type reg_rsp_t = logic,
  parameter type ar_chan_t = logic,
  parameter type aw_chan_t = logic,
  parameter type w_chan_t  = logic,
  parameter type b_chan_t = logic,
  parameter type r_chan_t = logic,
  parameter type core_req_t = logic,
  parameter type core_rsp_t = logic
)(
  input  logic                                             clk_i,
  input  logic                                             rstn_i,
  input  cheshire_pkg::doub_bt                             bootaddress_i,
  input  cheshire_pkg::doub_bt                             hart_id_i,
  input  logic             [31:0]                          harts_sync_req_i,
  output logic                                             redundancy_en_o,
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
  output core_req_t        [NumHarts-1:0]                  core_req_o,
  input  core_rsp_t        [NumHarts-1:0]                  core_rsp_i
);

typedef struct packed {
  // cheshire_pkg::doub_bt    bootaddress;
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
  core_rsp_t               core_rsp;
} cva6_inputs_t;

typedef struct packed {
  logic clic_irq_ready;
  logic clic_kill_ack;
} cva6_outputs_t;

logic                         cores_sync;
logic          [NumHarts-1:0] core_setback;
cva6_inputs_t  [NumHarts-1:0] sys2hmr, hmr2core;
cva6_outputs_t [NumHarts-1:0] hmr2sys, core2hmr;
core_req_t [NumHarts-1:0] core2hmr_core_req, hmr2sys_core_req;
cheshire_pkg::doub_bt [NumHarts-1:0] core_bootaddress;

for (genvar i = 0; i < NumHarts; i++) begin: gen_cva6_cores
  // Bind system inputs to HMR.
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
  assign sys2hmr[i].core_rsp = core_rsp_i[i];

  // Bind HMR outputs to system.
  assign clic_irq_ready_o[i] = hmr2sys[i].clic_irq_ready;
  assign clic_kill_ack_o[i]  = hmr2sys[i].clic_kill_ack;
  assign core_req_o[i] = hmr2sys_core_req[i];

  cva6 #(
    .CVA6Cfg       ( Cva6Cfg    ),
    .axi_ar_chan_t ( ar_chan_t  ),
    .axi_aw_chan_t ( aw_chan_t  ),
    .axi_w_chan_t  ( w_chan_t   ),
    .b_chan_t      ( b_chan_t   ),
    .r_chan_t      ( r_chan_t   ),
    .noc_req_t     ( core_req_t ),
    .noc_resp_t    ( core_rsp_t )
  ) i_core_cva6    (
    .clk_i            ( clk_i                         ),
    .rst_ni           ( rstn_i                        ),
    .clear_i          ( core_setback[i]               ),
    .boot_addr_i      ( core_bootaddress[i]           ),
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
    // Clic support changed in CVA6, probably not all the features
    // have already been merged
    // .clic_irq_v_i     ( hmr2core[i].clic_irq_v        ),
    // .clic_irq_vsid_i  ( hmr2core[i].clic_irq_vsid     ),
    .clic_irq_ready_o ( core2hmr[i].clic_irq_ready    ),
    .clic_kill_req_i  ( hmr2core[i].clic_kill_req     ),
    .clic_kill_ack_o  ( core2hmr[i].clic_kill_ack     ),
    .rvfi_probes_o    (                               ),
    .cvxif_req_o      (                               ),
    .cvxif_resp_i     ( '0                            ),
    .noc_req_o        ( core2hmr_core_req[i]          ),
    .noc_resp_i       ( hmr2core[i].core_rsp          )
  );
end

assign cores_sync = (harts_sync_req_i[NumHarts-1:0] == '1) ? 1'b1 : 1'b0;

if (NumHarts > 1) begin: gen_multicore_hmr
  hmr_unit #(
    .NumCores          ( NumHarts          ),
    .DMRSupported      ( Cfg.Cva6DMR       ),
    .DMRFixed          ( Cfg.Cva6DMRFixed  ), // TODO: make configurable
    .TMRSupported      ( 0                 ),
    // .InterleaveGrps    ( 0                 ),
    .RapidRecovery     ( Cfg.RapidRecovery ),
    .SeparateData      ( 0                 ),
    .SeparateAxiBus    ( 1                 ),
    .AxiHasAce         ( 1                 ),
    .RfAddrWidth       ( 5                 ),
    .SysDataWidth      ( 64                ),
    .all_inputs_t      ( cva6_inputs_t     ), // Inputs from the system to the HMR
    .nominal_outputs_t ( cva6_outputs_t    ),
    // .core_backup_t     ( '0 ), // TODO
    // .bus_outputs_t     ( '0 ), // TODO
    .axi_req_t         ( core_req_t ),
    .reg_req_t         ( reg_req_t ),
    .reg_rsp_t         ( reg_rsp_t )
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
    // In PULP cluster we connected this to the event unit
    // to receive information about cores' synchronization.
    // How should we handle it here? We could use Cheshire's
    // registers to write that a synchronization completed
    // succesfully (??)
    .dmr_cores_synch_i  ( cores_sync ),
    .redundancy_enable_o ( redundancy_en_o ),

    // Rapid recovery buses
    .rapid_recovery_o ( /* TODO */ ),
    .core_backup_i    (  '0        ), // TODO

    .sys_bootaddress_i     ( bootaddress_i ),
    .sys_inputs_i          ( sys2hmr       ),
    .sys_nominal_outputs_o ( hmr2sys       ),
    .sys_bus_outputs_o     (               ),
    .sys_axi_outputs_o     ( hmr2sys_core_req ),
    // CVA6 boot does not rely on fetch enable.
    .sys_fetch_en_i        ( '1            ),
    .enable_bus_vote_i     ( '0            ), // TODO?

    .core_bootaddress_o     ( core_bootaddress  ),
    .core_setback_o         ( core_setback      ),
    .core_inputs_o          ( hmr2core          ),
    .core_nominal_outputs_i ( core2hmr          ),
    .core_bus_outputs_i     ( '0                ), // TODO?
    .core_axi_outputs_i     ( core2hmr_core_req )
  );

  /* We temporarily hardcode this for permanent lockstep.*/
  // assign hmr2sys[NumHarts-1] = '0;
end else begin : gen_single_core_binding
  assign core_bootaddress = bootaddress_i;
  assign core_setback = '0;
  assign redundancy_en_o = '0;
  assign hmr2core = sys2hmr ;
  assign hmr2sys  = core2hmr;
  assign hmr2sys_core_req = core2hmr_core_req;

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
