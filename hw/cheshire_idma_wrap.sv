// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>
// Andreas Kuster <kustera@ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
// Chaoqun Liang <chaoqun.liang@unibo.it>
// Kevin Schaerer <schkevin@ethz.ch>

/// iDMA core wrapper for Cheshire
/// This wrapper can instantiate multiple frontends
module cheshire_idma_wrap #(
  parameter int unsigned  AxiAddrWidth     = 0,
  parameter int unsigned  AxiDataWidth     = 0,
  parameter int unsigned  AxiIdWidth       = 0,
  parameter int unsigned  AxiUserWidth     = 0,
  parameter int unsigned  AxiSlvIdWidth    = 0,
  parameter int unsigned  AxiMaxReadTxns   = 0,
  parameter int unsigned  AxiMaxWriteTxns  = 0,
  parameter int unsigned  NumAxInFlight    = 0,
  parameter int unsigned  MemSysDepth      = 0,
  parameter int unsigned  JobFifoDepth     = 0,
  parameter bit           RAWCouplingAvail = 0,
  parameter type          axi_mst_req_t    = logic,
  parameter type          axi_mst_rsp_t    = logic,
  parameter type          axi_slv_req_t    = logic,
  parameter type          axi_slv_rsp_t    = logic,
  parameter type          reg_req_t        = logic,
  parameter type          reg_rsp_t        = logic,
  parameter type          idma_fe_cfg_t    = logic,
  parameter idma_fe_cfg_t FrontendCfg      = '0
) (
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          testmode_i,
  output axi_mst_req_t  axi_mst_fe_desc64_req_o,
  input  axi_mst_rsp_t  axi_mst_fe_desc64_rsp_i,
  output axi_mst_req_t  axi_mst_be_req_o,
  input  axi_mst_rsp_t  axi_mst_be_rsp_i,
  input  axi_slv_req_t [FrontendCfg.num-1:0] axi_slv_req_i,
  output axi_slv_rsp_t [FrontendCfg.num-1:0] axi_slv_rsp_o,
  output logic          irq_o
);

  `include "axi/assign.svh"
  `include "axi/typedef.svh"
  `include "idma/typedef.svh"
  `include "register_interface/typedef.svh"

  localparam int unsigned IdCounterWidth  = 32;
  localparam int unsigned NumDim          = 2;
  localparam int unsigned RepWidth        = 32;
  localparam int unsigned TfLenWidth      = 32;

  typedef logic [AxiDataWidth-1:0]     data_t;
  typedef logic [AxiDataWidth/8-1:0]   strb_t;
  typedef logic [AxiAddrWidth-1:0]     addr_t;
  typedef logic [AxiIdWidth-1:0]       id_t;
  typedef logic [AxiSlvIdWidth-1:0]    slv_id_t;
  typedef logic [AxiUserWidth-1:0]     user_t;
  typedef logic [TfLenWidth-1:0]       tf_len_t;
  typedef logic [IdCounterWidth-1:0]   tf_id_t;
  typedef logic [RepWidth-1:0]         reps_t;
  typedef logic [RepWidth-1:0]         strides_t;

  // AXI4+ATOP typedefs
  `AXI_TYPEDEF_AW_CHAN_T(axi_aw_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(axi_ar_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(axi_r_chan_t, data_t, id_t, user_t)

  // iDMA request / response types
  `IDMA_TYPEDEF_FULL_REQ_T(idma_req_t, id_t, addr_t, tf_len_t)
  `IDMA_TYPEDEF_FULL_RSP_T(idma_rsp_t, addr_t)
  `IDMA_TYPEDEF_FULL_ND_REQ_T(idma_nd_req_t, idma_req_t, tf_len_t, tf_len_t)

  `REG_BUS_TYPEDEF_ALL(dma_regs, addr_t, data_t, strb_t)
  
  `AXI_LITE_TYPEDEF_ALL(axi_lite, addr_t, data_t, strb_t)

  typedef struct packed {
    axi_ar_chan_t ar_chan;
  } axi_read_meta_channel_t;

  typedef struct packed {
    axi_read_meta_channel_t axi;
  } read_meta_channel_t;

  typedef struct packed {
    axi_aw_chan_t aw_chan;
  } axi_write_meta_channel_t;

  typedef struct packed {
    axi_write_meta_channel_t axi;
  } write_meta_channel_t;

  typedef bit [ 5:0] aw_bt;

  localparam int unsigned FrontendIdxWidth  = (FrontendCfg.num > 32'd1) ? unsigned'($clog2(FrontendCfg.num)) : 32'd1;

  // 1D FE signals
  idma_req_t    burst_req_d;
  logic         be_valid_d;
  logic         be_ready_d;

  // interface between frontend and backend  
  idma_req_t [FrontendCfg.num-1:0] idma_req_fe;
  logic [FrontendCfg.num-1:0] idma_req_fe_valid;
  logic [FrontendCfg.num-1:0] idma_req_fe_ready;
  idma_req_t   idma_req;
  logic        idma_req_valid;
  logic        idma_req_ready;

  idma_rsp_t [FrontendCfg.num-1:0] idma_rsp_fe;
  logic [FrontendCfg.num-1:0] idma_rsp_fe_valid;
  logic [FrontendCfg.num-1:0] idma_rsp_fe_ready;
  idma_rsp_t   idma_rsp;
  logic        idma_rsp_valid;
  logic        idma_rsp_ready;


  // ID signals
  logic              issue_id;
  logic              retire_id;
  logic [IdCounterWidth-1:0] done_id, next_id;

  // Status signals
  idma_pkg::idma_busy_t busy;
  logic me_busy;

  // Internal AXI channels
  axi_mst_req_t axi_read_req, axi_write_req;
  axi_mst_rsp_t axi_read_rsp, axi_write_rsp;

  logic [FrontendIdxWidth-1:0]  idma_fe_idx_d, idma_fe_idx_q;

  if (FrontendCfg.ConfFrontendDesc64) begin: gen_dma_fe_desc64
    localparam int unsigned DmaInputFifoDepth = 8;
    localparam int unsigned DmaPendingFifoDepth = 8;
    localparam int unsigned DmaNSpeculation = 4;
    localparam int unsigned DmaBufferDepth = 3;
    localparam int unsigned DmaBackendDepth = NumAxInFlight + DmaBufferDepth;

    // connections between axi and frontend registers
    axi_lite_req_t idma_axi_lite_req;
    axi_lite_resp_t idma_axi_lite_rsp;
    reg_req_t idma_reg_req;
    reg_rsp_t  idma_reg_rsp;

    idma_req_t idma_req;
    logic idma_req_valid;
    logic idma_req_ready;

    idma_rsp_t idma_rsp;
    logic idma_rsp_valid;
    logic idma_rsp_ready;

    axi_to_axi_lite #(
      .AxiAddrWidth   ( AxiAddrWidth    ),
      .AxiDataWidth   ( AxiDataWidth    ),
      .AxiIdWidth     ( AxiIdWidth      ),
      .AxiUserWidth   ( AxiUserWidth    ),
      .AxiMaxWriteTxns( AxiMaxWriteTxns ),
      .AxiMaxReadTxns ( AxiMaxReadTxns  ),
      .FullBW         ( 0    ),
      .FallThrough    ( 1'b1 ),
      .full_req_t     ( axi_slv_req_t   ),
      .full_resp_t    ( axi_slv_rsp_t   ),
      .lite_req_t     ( axi_lite_req_t  ),
      .lite_resp_t    ( axi_lite_resp_t )
    ) i_dma_axi_to_axi_lite (
      .clk_i,
      .rst_ni,
      .test_i         ( testmode_i        ),
      .slv_req_i      ( axi_slv_req_i[FrontendCfg.desc64] ),
      .slv_resp_o     ( axi_slv_rsp_o[FrontendCfg.desc64] ),
      .mst_req_o      ( idma_axi_lite_req ),
      .mst_resp_i     ( idma_axi_lite_rsp )
    );

    axi_lite_to_reg #(
      .ADDR_WIDTH     ( AxiAddrWidth      ),
      .DATA_WIDTH     ( AxiDataWidth      ),
      .BUFFER_DEPTH   ( 2                 ),
      .DECOUPLE_W     ( 1                 ),
      .axi_lite_req_t ( axi_lite_req_t    ),
      .axi_lite_rsp_t ( axi_lite_resp_t   ),
      .reg_req_t      ( reg_req_t         ),
      .reg_rsp_t      ( reg_rsp_t         )
    ) i_dma_axi_lite_to_reg (
      .clk_i,
      .rst_ni,
      .axi_lite_req_i ( idma_axi_lite_req ),
      .axi_lite_rsp_o ( idma_axi_lite_rsp ),
      .reg_req_o      ( idma_reg_req      ),
      .reg_rsp_i      ( idma_reg_rsp      )
    );

    idma_desc64_top #(
      .AddrWidth         ( 64                 ),
      .DataWidth         ( AxiDataWidth       ),
      .AxiIdWidth        ( AxiIdWidth         ),
      .idma_req_t        ( idma_req_t         ),
      .idma_rsp_t        ( idma_rsp_t         ),
      .reg_rsp_t         ( reg_rsp_t          ),
      .reg_req_t         ( reg_req_t          ),
      .axi_rsp_t         ( axi_mst_rsp_t      ),
      .axi_req_t         ( axi_mst_req_t      ),
      .axi_ar_chan_t     ( axi_ar_chan_t      ),
      .axi_r_chan_t      ( axi_r_chan_t       ),
      .InputFifoDepth    ( DmaInputFifoDepth  ),
      .PendingFifoDepth  ( DmaPendingFifoDepth),
      .BackendDepth      ( DmaBackendDepth    ),
      .NSpeculation      ( DmaNSpeculation    )
    ) i_dma_fe (
      .clk_i,
      .rst_ni,
      // axi interface for fetching descriptors
      .master_req_o     ( axi_mst_fe_desc64_req_o ),
      .master_rsp_i     ( axi_mst_fe_desc64_rsp_i ),
      .axi_ar_id_i      ( 2'b0 ),
      .axi_aw_id_i      ( 2'b0 ),
      // register interface for launching transfers
      .slave_req_i      ( idma_reg_req   ), 
      .slave_rsp_o      ( idma_reg_rsp   ),
      // backend interface
      .idma_req_o       ( idma_req       ),
      .idma_req_valid_o ( idma_req_valid ),
      .idma_req_ready_i ( idma_req_ready ),
      .idma_rsp_i       ( idma_rsp       ),
      .idma_rsp_valid_i ( idma_rsp_valid ),
      .idma_rsp_ready_o ( idma_rsp_ready ),
      .idma_busy_i      ( |busy ),
      // interrupt interface for completed transfers
      .irq_o            ( irq_o )
    );

    assign idma_req_fe[FrontendCfg.desc64] = idma_req;
    assign idma_req_fe_valid[FrontendCfg.desc64] = idma_req_valid;
    assign idma_req_ready = idma_req_fe_ready[FrontendCfg.desc64];

    assign idma_rsp = idma_rsp_fe[FrontendCfg.desc64];
    assign idma_rsp_valid = idma_rsp_fe_valid[FrontendCfg.desc64];
    assign idma_rsp_fe_ready[FrontendCfg.desc64] = idma_rsp_ready;
  end

  if (FrontendCfg.ConfFrontendReg64) begin: gen_dma_fe_reg64
    dma_regs_req_t dma_reg_req;
    dma_regs_rsp_t dma_reg_rsp;

    idma_req_t idma_req;
    logic idma_req_valid;
    logic idma_req_ready;

    idma_rsp_t idma_rsp;
    logic idma_rsp_valid;
    logic idma_rsp_ready;

    axi_to_reg #(
      .ADDR_WIDTH ( AxiAddrWidth  ),
      .DATA_WIDTH ( AxiDataWidth  ),
      .ID_WIDTH   ( AxiSlvIdWidth ),
      .USER_WIDTH ( AxiUserWidth  ),
      .axi_req_t  ( axi_slv_req_t ),
      .axi_rsp_t  ( axi_slv_rsp_t ),
      .reg_req_t  ( dma_regs_req_t),
      .reg_rsp_t  ( dma_regs_rsp_t)
    ) i_axi_translate (
      .clk_i,
      .rst_ni,
      .testmode_i,
      .axi_req_i  ( axi_slv_req_i[FrontendCfg.reg64] ),
      .axi_rsp_o  ( axi_slv_rsp_o[FrontendCfg.reg64] ),
      .reg_req_o  ( dma_reg_req ),
      .reg_rsp_i  ( dma_reg_rsp )
    );

    if (!FrontendCfg.ConfFrontendReg64TwoD) begin : gen_dma_fe_reg64_1d
      idma_reg64_1d #(
        .NumRegs        ( 32'd1 ),
        .NumStreams     ( 32'd1 ),
        .IdCounterWidth ( IdCounterWidth ),
        .reg_req_t      ( dma_regs_req_t ),
        .reg_rsp_t      ( dma_regs_rsp_t ),
        .dma_req_t      ( idma_req_t )
      ) i_dma_frontend_1d (
        .clk_i,
        .rst_ni,
        .dma_ctrl_req_i ( dma_reg_req ),
        .dma_ctrl_rsp_o ( dma_reg_rsp ),
        .dma_req_o      ( burst_req_d ),
        .req_valid_o    ( be_valid_d  ),
        .req_ready_i    ( be_ready_d  ),
        .next_id_i      ( next_id ),
        .stream_idx_o   ( ),
        .done_id_i      ( done_id ),
        .busy_i         ( busy ),
        .midend_busy_i  ( 1'b0 )
      );

      stream_fifo_optimal_wrap #(
        .Depth      ( JobFifoDepth ),
        .type_t     ( idma_req_t   ),
        .PrintInfo  ( 0 )
      ) i_stream_fifo_jobs_1d (
        .clk_i,
        .rst_ni,
        .testmode_i,
        .flush_i    ( 1'b0 ),
        .usage_o    ( ),
        .data_i     ( burst_req_d ),
        .valid_i    ( be_valid_d  ),
        .ready_o    ( be_ready_d  ),
        .data_o     ( idma_req      ),
        .valid_o    ( idma_req_valid),
        .ready_i    ( idma_req_ready)
      );

      assign retire_id = idma_rsp_valid & idma_rsp_ready;
      assign issue_id  = be_valid_d & be_ready_d;
      assign idma_rsp_fe_ready[FrontendCfg.reg64] = 1'b1;

      idma_transfer_id_gen #(
        .IdWidth ( IdCounterWidth )
      ) i_transfer_id_gen_1d (
        .clk_i,
        .rst_ni,
        .issue_i      ( issue_id  ),
        .retire_i     ( retire_id ),
        .next_o       ( next_id   ),
        .completed_o  ( done_id   )
      );

    end else begin : gen_dma_fe_reg64_2d
      // ND FE signals
      idma_nd_req_t idma_nd_req_d;
      logic         idma_nd_req_valid_d;
      logic         idma_nd_req_ready_d;

      // ND ME signals
      idma_nd_req_t idma_nd_req;
      logic         idma_nd_req_valid;
      logic         idma_nd_req_ready;
      logic         idma_nd_rsp_valid;
      logic         idma_nd_rsp_ready;

      idma_reg64_2d #(
        .NumRegs        ( 1 ),
        .NumStreams     ( 1 ),
        .IdCounterWidth ( IdCounterWidth ),
        .reg_req_t      ( dma_regs_req_t ),
        .reg_rsp_t      ( dma_regs_rsp_t ),
        .dma_req_t      ( idma_nd_req_t  )
      ) idma_frontend_2d (
        .clk_i,
        .rst_ni,
        .dma_ctrl_req_i ( dma_reg_req   ),
        .dma_ctrl_rsp_o ( dma_reg_rsp   ),
        .dma_req_o      ( idma_nd_req_d ),
        .req_valid_o    ( idma_nd_req_valid_d ),
        .req_ready_i    ( idma_nd_req_ready_d ),
        .next_id_i      ( next_id ),
        .stream_idx_o   (         ),
        .done_id_i      ( done_id ),
        .busy_i         ( busy    ),
        .midend_busy_i  ( me_busy )
      );

      stream_fifo_optimal_wrap #(
        .Depth      ( JobFifoDepth  ),
        .type_t     ( idma_nd_req_t ),
        .PrintInfo  ( 0 )
      ) i_stream_fifo_jobs_2d (
        .clk_i,
        .rst_ni,
        .testmode_i,
        .flush_i    ( 1'b0 ),
        .usage_o    ( ),
        .data_i     ( idma_nd_req_d       ),
        .valid_i    ( idma_nd_req_valid_d ),
        .ready_o    ( idma_nd_req_ready_d ),
        .data_o     ( idma_nd_req       ),
        .valid_o    ( idma_nd_req_valid ),
        .ready_i    ( idma_nd_req_ready )
      );

      idma_nd_midend #(
        .NumDim         ( NumDim ),
        .addr_t         ( addr_t ),
        .idma_req_t     ( idma_req_t ),
        .idma_rsp_t     ( idma_rsp_t ),
        .idma_nd_req_t  ( idma_nd_req_t ),
        .RepWidths      ( RepWidth )
      ) i_idma_midend (
        .clk_i,
        .rst_ni,
        .nd_req_i           ( idma_nd_req       ),
        .nd_req_valid_i     ( idma_nd_req_valid ),
        .nd_req_ready_o     ( idma_nd_req_ready ),
        .nd_rsp_o           ( ),
        .nd_rsp_valid_o     ( idma_nd_rsp_valid ),
        .nd_rsp_ready_i     ( idma_nd_rsp_ready ),
        .burst_req_o        ( idma_req          ),
        .burst_req_valid_o  ( idma_req_valid    ),
        .burst_req_ready_i  ( idma_req_ready    ),
        .burst_rsp_i        ( idma_rsp          ),
        .burst_rsp_valid_i  ( idma_rsp_valid    ),
        .burst_rsp_ready_o  ( idma_rsp_ready    ),
        .busy_o             ( me_busy )
      );

      assign retire_id = idma_nd_rsp_valid & idma_nd_rsp_ready;
      assign issue_id  = idma_nd_req_valid_d & idma_nd_req_ready_d;
      assign idma_nd_rsp_ready = 1'b1;

      idma_transfer_id_gen #(
        .IdWidth ( IdCounterWidth )
      ) i_transfer_id_gen_2d (
        .clk_i,
        .rst_ni,
        .issue_i      ( issue_id  ),
        .retire_i     ( retire_id ),
        .next_o       ( next_id   ),
        .completed_o  ( done_id   )
      );
    end

    assign idma_req_fe[FrontendCfg.reg64] = idma_req;
    assign idma_req_fe_valid[FrontendCfg.reg64] = idma_req_valid;
    assign idma_req_ready = idma_req_fe_ready[FrontendCfg.reg64];

    assign idma_rsp = idma_rsp_fe[FrontendCfg.reg64];
    assign idma_rsp_valid = idma_rsp_fe_valid[FrontendCfg.reg64];
    assign idma_rsp_fe_ready[FrontendCfg.reg64] = idma_rsp_ready;
  end

  /// Arbitrates requests from (multiple) frontend(s) to backend
  rr_arb_tree #(
    .NumIn     ( FrontendCfg.num ),
    .DataType  ( idma_req_t ),
    .ExtPrio   ( 0          ),
    .AxiVldRdy ( 1          ),
    .LockIn    ( 1          )
  ) i_rr_arb_tree (
    .clk_i,
    .rst_ni,
    .flush_i ( 1'b0             ),
    .rr_i    ( '0               ),
    .req_i   ( idma_req_fe_valid),
    .gnt_o   ( idma_req_fe_ready),
    .data_i  ( idma_req_fe      ),
    .gnt_i   ( idma_req_ready   ),
    .req_o   ( idma_req_valid   ),
    .data_o  ( idma_req         ),
    .idx_o   ( idma_fe_idx_d    )
  );

  always_comb begin
    idma_rsp_fe = '{default: '0};
    idma_rsp_fe_valid = '{default: '0};
    idma_rsp_fe[idma_fe_idx_q] = idma_rsp;
    idma_rsp_fe_valid[idma_fe_idx_q] = idma_rsp_valid;
    idma_rsp_ready = idma_rsp_fe_ready[idma_fe_idx_q];
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin : idma_fe_idx_reg
    if (!rst_ni) begin
      idma_fe_idx_q <= '0;
    end else begin
      idma_fe_idx_q <= '0;
      if (idma_req_valid) begin
        idma_fe_idx_q <= idma_fe_idx_d;
      end
    end
  end

  idma_backend_rw_axi #(
    .CombinedShifter      ( 1'b0 ),
    .DataWidth            ( AxiDataWidth ),
    .AddrWidth            ( AxiAddrWidth ),
    .AxiIdWidth           ( AxiIdWidth   ),
    .UserWidth            ( AxiUserWidth ),
    .TFLenWidth           ( TfLenWidth ),
    .MaskInvalidData      ( 1 ),
    .BufferDepth          ( 3 ),
    .RAWCouplingAvail     ( RAWCouplingAvail),
    .HardwareLegalizer    ( 1 ),
    .RejectZeroTransfers  ( 1 ),
    .ErrorCap             ( idma_pkg::NO_ERROR_HANDLING ),
    .PrintFifoInfo        ( 0 ),
    .NumAxInFlight        ( NumAxInFlight ),
    .MemSysDepth          ( MemSysDepth ),
    .idma_req_t           ( idma_req_t  ),
    .idma_rsp_t           ( idma_rsp_t  ),
    .idma_eh_req_t        ( idma_pkg::idma_eh_req_t ),
    .idma_busy_t          ( idma_pkg::idma_busy_t   ),
    .axi_req_t            ( axi_mst_req_t ),
    .axi_rsp_t            ( axi_mst_rsp_t ),
    .write_meta_channel_t ( write_meta_channel_t ),
    .read_meta_channel_t  ( read_meta_channel_t  )
  ) i_idma_backend  (
    .clk_i,
    .rst_ni,
    .testmode_i,
    .idma_req_i       ( idma_req        ),
    .req_valid_i      ( idma_req_valid  ),
    .req_ready_o      ( idma_req_ready  ),
    .idma_rsp_o       ( idma_rsp       ),
    .rsp_valid_o      ( idma_rsp_valid ),
    .rsp_ready_i      ( idma_rsp_ready ),
    .idma_eh_req_i    ( '0 ),
    .eh_req_valid_i   ( '0 ),
    .eh_req_ready_o   ( /* NOT CONNECTED */ ),
    .axi_read_req_o   ( axi_read_req ),
    .axi_read_rsp_i   ( axi_read_rsp ),
    .axi_write_req_o  ( axi_write_req ),
    .axi_write_rsp_i  ( axi_write_rsp ),
    .busy_o           ( busy )
  );

  axi_rw_join #(
   .axi_req_t   ( axi_mst_req_t ),
   .axi_resp_t  ( axi_mst_rsp_t )
  ) i_axi_rw_join (
   .clk_i,
   .rst_ni,
   .slv_read_req_i    ( axi_read_req  ),
   .slv_read_resp_o   ( axi_read_rsp  ),
   .slv_write_req_i   ( axi_write_req ),
   .slv_write_resp_o  ( axi_write_rsp ),
   .mst_req_o         ( axi_mst_be_req_o ),
   .mst_resp_i        ( axi_mst_be_rsp_i )
  );

endmodule
