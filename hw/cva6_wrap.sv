// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Yvan Tortorella <yvan.tortorella@unibo.it>

`include "axi/assign.svh"

module cva6_wrap #(
  parameter cheshire_pkg::cheshire_cfg_t Cfg = '0,
  parameter config_pkg::cva6_cfg_t Cva6Cfg = cva6_config_pkg::cva6_cfg,
  parameter int unsigned NumHarts = 1,
  parameter bit ExternalCaches = 1,
  parameter int unsigned ClicNumIrqs  = $clog2(Cva6Cfg.CLICNumInterruptSrc),
  parameter type reg_req_t = logic,
  parameter type reg_rsp_t = logic,
  parameter type axi_ar_chan_t = logic,
  parameter type axi_aw_chan_t = logic,
  parameter type axi_w_chan_t  = logic,
  parameter type b_chan_t = logic,
  parameter type r_chan_t = logic,
  parameter type axi_req_t = logic,
  parameter type axi_rsp_t = logic
)(
  input  logic                                             clk_i,
  input  logic                                             rst_ni,
  input  cheshire_pkg::doub_bt                             bootaddress_i,
  input  cheshire_pkg::doub_bt                             hart_id_i,
  input  logic             [31:0]                          harts_sync_req_i,
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

// RISC-V specifies 32 registers should be in the RF as a standard
// so the address width is calculated on top of that
localparam int unsigned RegFileAddrWidth = $clog2(32);
localparam int unsigned NumRfWrPorts = 1; // See CVA6ExtendCfg
localparam int unsigned NumIntRfRdPorts = 2; // See CVA6ExtendCfg
localparam int unsigned NumFpRfRdPorts = 3; // See CVA6ExtendCfg

typedef struct packed {
  logic we;
  logic [RegFileAddrWidth-1:0] waddr;
  logic [riscv::XLEN-1:0] wdata;
} regfile_write_t;

typedef struct packed {
  logic [RegFileAddrWidth-1:0] raddr;
  logic [riscv::XLEN-1:0] rdata;
} regfile_read_t;

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
  std_cache_pkg::cache_line_t [ariane_pkg::DCACHE_SET_ASSOC-1:0] dcache_rdata;
  logic [ariane_pkg::ICACHE_SET_ASSOC-1:0][ariane_pkg::ICACHE_TAG_WIDTH:0] icache_tag_rdata;
  logic [ariane_pkg::ICACHE_SET_ASSOC-1:0][ariane_pkg::ICACHE_USER_LINE_WIDTH-1:0] icache_data_ruser;
  logic [ariane_pkg::ICACHE_SET_ASSOC-1:0][ariane_pkg::ICACHE_LINE_WIDTH-1:0] icache_data_rdata;
  axi_rsp_t                axi_rsp;
} cva6_inputs_t;

typedef struct packed {
  logic debug_halted;
  logic clic_irq_ready;
  logic clic_kill_ack;
  logic [ariane_pkg::DCACHE_SET_ASSOC-1:0] dcache_req;
  logic [ariane_pkg::DCACHE_INDEX_WIDTH-1:0] dcache_addr;
  logic dcache_we;
  std_cache_pkg::cache_line_t dcache_wdata;
  std_cache_pkg::cl_be_t dcache_be;
  logic [ariane_pkg::ICACHE_SET_ASSOC-1:0] icache_tag_req;
  logic icache_tag_we;
  logic [wt_cache_pkg::ICACHE_CL_IDX_WIDTH-1:0] icache_tag_addr;
  logic [ariane_pkg::ICACHE_TAG_WIDTH-1:0] icache_tag_wdata;
  logic [ariane_pkg::ICACHE_SET_ASSOC-1:0] icache_tag_wdata_valid;
  logic [ariane_pkg::ICACHE_SET_ASSOC-1:0] icache_data_req;
  logic icache_data_we;
  logic [wt_cache_pkg::ICACHE_CL_IDX_WIDTH-1:0] icache_data_addr;
  wt_cache_pkg::icache_rtrn_t icache_data_wdata;
  regfile_read_t [NumIntRfRdPorts-1:0] int_regfile_read;
  regfile_read_t [NumFpRfRdPorts-1:0] fp_regfile_read;
  axi_req_t axi_req;
} cva6_outputs_t;

typedef struct packed {
  logic fake;
} csr_intf_t;

typedef struct packed {
  logic [riscv::XLEN-1:0] program_counter_if;
  logic [riscv::XLEN-1:0] program_counter;
  logic                   is_branch;
  logic [riscv::XLEN-1:0] branch_addr;
} pc_intf_t;

typedef struct packed {
  regfile_write_t [NumRfWrPorts-1:0] int_regfile_backup;
  regfile_write_t [NumRfWrPorts-1:0] fp_regfile_backup;
  csr_intf_t csr_backup;
  pc_intf_t pc_backup;
} core_backup_t;

typedef struct packed {
  logic instr_lock;
  logic pc_recovery_en;
  logic rf_recovery_en;
  logic debug_req;
  logic debug_resume;
  regfile_write_t [NumRfWrPorts-1:0] int_rf_recovery_wdata;
  regfile_write_t [NumRfWrPorts-1:0] fp_rf_recovery_wdata;
  logic [NumIntRfRdPorts-1:0][riscv::XLEN-1:0] int_rf_recovery_rdata;
  logic [NumFpRfRdPorts-1:0][riscv::XLEN-1:0] fp_rf_recovery_rdata;
  logic [2**RegFileAddrWidth-1:0][riscv::XLEN-1:0] int_rf_mem;
  logic [2**RegFileAddrWidth-1:0][riscv::XLEN-1:0] fp_rf_mem;
  csr_intf_t csr_recovery;
  pc_intf_t pc_recovery;
} rapid_recovery_t;

localparam rapid_recovery_pkg::rapid_recovery_cfg_t CheshireRrCfg = '{
  ReducedCsrsBackupEnable: 0,
  FullCsrsBackupEnable: 0,
  IntRegFileBackupEnable: 1,
  FpRegFileBackupEnable: 1,
  ProgramCounterBackupEnable: 1,
  default: '0
};

logic                         cores_sync;
logic          [NumHarts-1:0] core_setback;
cva6_inputs_t  [NumHarts-1:0] sys2hmr, hmr2core;
cva6_outputs_t [NumHarts-1:0] hmr2sys, core2hmr;
cheshire_pkg::doub_bt [NumHarts-1:0] core_bootaddress;

core_backup_t [NumHarts-1:0] backup_bus;
regfile_read_t [NumHarts-1:0][NumIntRfRdPorts-1:0] int_regfile_read;
regfile_read_t [NumHarts-1:0][NumFpRfRdPorts-1:0] fp_regfile_read;
regfile_write_t [NumHarts-1:0][NumRfWrPorts-1:0] int_regfile_backup, fp_regfile_backup;
rapid_recovery_t [NumHarts-1:0] recovery_bus;

for (genvar i = 0; i < NumHarts; i++) begin: gen_cva6_cores
  // Bind system inputs to HMR.
  // assign sys2hmr[i].bootaddress    = bootaddress_i; // TODO: differentiate?
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

  for (genvar j= 0; j < NumIntRfRdPorts; j++) begin
    assign core2hmr[i].int_regfile_read[j].raddr = int_regfile_read[i][j].raddr;
    assign core2hmr[i].int_regfile_read[j].rdata = int_regfile_read[i][j].rdata;
  end
  for (genvar j= 0; j < NumFpRfRdPorts; j++) begin
    assign core2hmr[i].fp_regfile_read[j].raddr = fp_regfile_read[i][j].raddr;
    assign core2hmr[i].fp_regfile_read[j].rdata = fp_regfile_read[i][j].rdata;
  end

  always_comb begin
    backup_bus[i].csr_backup = '0;
    backup_bus[i].pc_backup = '0;
    for (int j= 0; j < NumRfWrPorts; j++) begin
      backup_bus[i].int_regfile_backup[j] = int_regfile_backup[i][j];
      backup_bus[i].fp_regfile_backup[j] = fp_regfile_backup[i][j];
    end
  end

  cva6 #(
    .CVA6Cfg       ( Cva6Cfg        ),
    .ExternalSrams ( ExternalCaches ),
    .NumRfCommitPorts (NumRfWrPorts ),
    .NumIntRfRdPorts ( NumIntRfRdPorts ),
    .NumFpRfRdPorts ( NumFpRfRdPorts ),
    .axi_ar_chan_t ( axi_ar_chan_t  ),
    .axi_aw_chan_t ( axi_aw_chan_t  ),
    .axi_w_chan_t  ( axi_w_chan_t   ),
    .b_chan_t      ( b_chan_t       ),
    .r_chan_t      ( r_chan_t       ),
    .regfile_write_t (regfile_write_t),
    .regfile_read_t (regfile_read_t),
    .noc_req_t     ( axi_req_t      ),
    .noc_resp_t    ( axi_rsp_t      )
  ) i_core_cva6    (
    .clk_i            ( clk_i                         ),
    .rst_ni           ( rst_ni                        ),
    .clear_i          ( core_setback[i]               ),
    // .boot_addr_i      ( hmr2core[i].bootaddress       ),
    .boot_addr_i      ( core_bootaddress[i]           ),
    .hart_id_i        ( hmr2core[i].hart_id           ),
    .irq_i            ( hmr2core[i].irq               ),
    .ipi_i            ( hmr2core[i].ipi               ),
    .time_irq_i       ( hmr2core[i].time_irq          ),
    .debug_req_i      ( hmr2core[i].debug_req         ),
    .debug_resume_i   ( recovery_bus[i].debug_resume  ),
    .debug_mode_o     ( core2hmr[i].debug_halted      ),
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
    // Connection to external SRAMs
    .dcache_req_o     ( core2hmr[i].dcache_req        ),
    .dcache_addr_o    ( core2hmr[i].dcache_addr       ),
    .dcache_we_o      ( core2hmr[i].dcache_we         ),
    .dcache_wdata_o   ( core2hmr[i].dcache_wdata      ),
    .dcache_be_o      ( core2hmr[i].dcache_be         ),
    .dcache_rdata_i   ( hmr2core[i].dcache_rdata      ),
    .icache_tag_req_o   ( core2hmr[i].icache_tag_req  ),
    .icache_tag_we_o    ( core2hmr[i].icache_tag_we   ),
    .icache_tag_addr_o  ( core2hmr[i].icache_tag_addr ),
    .icache_tag_wdata_o ( core2hmr[i].icache_tag_wdata),
    .icache_tag_wdata_valid_o ( core2hmr[i].icache_tag_wdata_valid ),
    .icache_tag_rdata_i ( hmr2core[i].icache_tag_rdata),
    .icache_data_req_o  ( core2hmr[i].icache_data_req ),
    .icache_data_we_o   ( core2hmr[i].icache_data_we ),
    .icache_data_addr_o ( core2hmr[i].icache_data_addr ),
    .icache_data_wdata_o( core2hmr[i].icache_data_wdata ),
    .icache_data_ruser_i( hmr2core[i].icache_data_ruser ),
    .icache_data_rdata_i( hmr2core[i].icache_data_rdata ),
    .recovery_i         ( recovery_bus[i].rf_recovery_en ),
    // Integer Register File
    .int_regfile_check_o ( int_regfile_read[i] ),
    .int_regfile_backup_o ( int_regfile_backup[i] ),
    .int_regfile_recovery_i (recovery_bus[i].int_rf_mem),
    // Floatting Point Register File
    .fp_regfile_check_o ( fp_regfile_read[i] ),
    .fp_regfile_backup_o ( fp_regfile_backup[i] ),
    .fp_regfile_recovery_i (recovery_bus[i].fp_rf_mem),
    .noc_req_o        ( core2hmr[i].axi_req           ),
    .noc_resp_i       ( hmr2core[i].axi_rsp           )
  );

  if (ExternalCaches) begin: gen_external_srams
    cache_wrap i_cva6_srams (
      .clk_i (clk_i),
      .rst_ni (rst_ni),
      // D$ interface
      .dcache_req_i  (hmr2sys[i].dcache_req),
      .dcache_addr_i (hmr2sys[i].dcache_addr),
      .dcache_we_i   (hmr2sys[i].dcache_we),
      .dcache_wdata_i(hmr2sys[i].dcache_wdata),
      .dcache_be_i   (hmr2sys[i].dcache_be),
      .dcache_rdata_o(sys2hmr[i].dcache_rdata),
      .icache_tag_req_i   ( hmr2sys[i].icache_tag_req),
      .icache_tag_we_i    ( hmr2sys[i].icache_tag_we),
      .icache_tag_addr_i  ( hmr2sys[i].icache_tag_addr),
      .icache_tag_wdata_i ( hmr2sys[i].icache_tag_wdata),
      .icache_tag_wdata_valid_i ( hmr2sys[i].icache_tag_wdata_valid),
      .icache_tag_rdata_o ( sys2hmr[i].icache_tag_rdata),
      .icache_data_req_i  ( hmr2sys[i].icache_data_req),
      .icache_data_we_i   ( hmr2sys[i].icache_data_we),
      .icache_data_addr_i ( hmr2sys[i].icache_data_addr),
      .icache_data_wdata_i( hmr2sys[i].icache_data_wdata),
      .icache_data_ruser_o( sys2hmr[i].icache_data_ruser),
      .icache_data_rdata_o( sys2hmr[i].icache_data_rdata)
    );
  end else begin: gen_no_external_srams
    assign sys2hmr[i].dcache_rdata = '0;
    assign sys2hmr[i].icache_tag_rdata = '0;
    assign sys2hmr[i].icache_data_ruser = '0;
    assign sys2hmr[i].icache_data_rdata = '0;
  end
end

// typedef struct packed {} rapid_recovery_t;
assign cores_sync = (harts_sync_req_i[NumHarts-1:0] == '1) ? 1'b1 : 1'b0;

if (NumHarts > 1) begin: gen_multicore_hmr
  hmr_unit #(
    .NumCores          ( NumHarts          ),
    .DMRSupported      ( Cfg.Cva6DMR       ),
    .DMRFixed          ( Cfg.Cva6DMRFixed  ),
    .TMRSupported      ( 0                 ),
    .RapidRecovery     ( Cfg.RapidRecovery ),
    .SeparateData      ( 0                 ),
    .RapidRecoveryCfg  ( CheshireRrCfg     ),
    .RfAddrWidth       ( RegFileAddrWidth  ),
    .NumIntRfRdPorts   ( NumIntRfRdPorts   ),
    .NumIntRfWrPorts   ( NumRfWrPorts     ),
    .NumFpRfRdPorts    ( NumFpRfRdPorts   ),
    .NumFpRfWrPorts    ( NumRfWrPorts     ),
    .SysDataWidth      ( riscv::XLEN      ), // 64 bits since we have CVA6
    .all_inputs_t      ( cva6_inputs_t     ), // Inputs from the system to the HMR
    .nominal_outputs_t ( cva6_outputs_t    ),
    .core_backup_t     ( core_backup_t ),
    .reg_req_t         ( reg_req_t ),
    .reg_rsp_t         ( reg_rsp_t ),
    .rapid_recovery_t  ( rapid_recovery_t ),
    .regfile_write_t   ( regfile_write_t ),
    .csr_intf_t        ( csr_intf_t ),
    .pc_intf_t         ( pc_intf_t )
  ) i_cva6_hmr (
    .clk_i              ( clk_i         ),
    .rst_ni             ( rst_ni        ),
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

    // Rapid recovery buses
    .rapid_recovery_o ( recovery_bus ),
    .core_backup_i    ( backup_bus ),

    .sys_bootaddress_i     ( bootaddress_i ),
    .sys_inputs_i          ( sys2hmr       ),
    .sys_nominal_outputs_o ( hmr2sys       ),
    .sys_bus_outputs_o     (               ),
    // CVA6 boot does not rely on fetch enable.
    .sys_fetch_en_i        ( '1            ),
    .enable_bus_vote_i     ( '0            ), // TODO?

    .core_bootaddress_o     ( core_bootaddress ),
    .core_setback_o         ( core_setback     ),
    .core_inputs_o          ( hmr2core         ),
    .core_nominal_outputs_i ( core2hmr         ),
    .core_bus_outputs_i     ( '0               ) // TODO?
  );

  /* We temporarily hardcode this for permanent lockstep.*/
  // assign hmr2sys[NumHarts-1] = '0;
end else begin : gen_single_core_binding
  assign core_bootaddress = bootaddress_i;
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
