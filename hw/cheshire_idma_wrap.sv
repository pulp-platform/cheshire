// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>
// Andreas Kuster <kustera@ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
// Chaoqun Liang <chaoqun.liang@unibo.it>

/// DMA core wrapper for the integration into Cheshire.
module cheshire_idma_wrap #(
  parameter int unsigned AxiAddrWidth     = 0,
  parameter int unsigned AxiDataWidth     = 0,
  parameter int unsigned AxiIdWidth       = 0,
  parameter int unsigned AxiUserWidth     = 0,
  parameter int unsigned AxiSlvIdWidth    = 0,
  parameter int unsigned NumAxInFlight    = 0,
  parameter int unsigned MemSysDepth      = 0,
  parameter int unsigned JobFifoDepth     = 0,
  parameter bit          RAWCouplingAvail = 0,
  parameter bit          IsTwoD           = 0,
  parameter type         axi_mst_req_t    = logic,
  parameter type         axi_mst_rsp_t    = logic,
  parameter type         axi_slv_req_t    = logic,
  parameter type         axi_slv_rsp_t    = logic
) (
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          testmode_i,
  output axi_mst_req_t  axi_mst_req_o,
  input  axi_mst_rsp_t  axi_mst_rsp_i,
  input  axi_slv_req_t  axi_slv_req_i,
  output axi_slv_rsp_t  axi_slv_rsp_o
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

  // iDMA request / response types
  `IDMA_TYPEDEF_FULL_REQ_T(idma_req_t, id_t, addr_t, tf_len_t)
  `IDMA_TYPEDEF_FULL_RSP_T(idma_rsp_t, addr_t)
  `IDMA_TYPEDEF_FULL_ND_REQ_T(idma_nd_req_t, idma_req_t, tf_len_t, tf_len_t)

  `REG_BUS_TYPEDEF_ALL(dma_regs, addr_t, data_t, strb_t)

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

  dma_regs_req_t dma_reg_req;
  dma_regs_rsp_t dma_reg_rsp;

  // 1D FE signals
  idma_req_t    burst_req_d;
  logic         be_valid_d;
  logic         be_ready_d;

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

  // BE signals
  idma_req_t    burst_req;
  logic         be_valid;
  logic         be_ready;
  idma_rsp_t    idma_rsp;
  logic         idma_rsp_valid;
  logic         idma_rsp_ready;

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

  axi_to_reg_v2 #(
    .AxiAddrWidth ( AxiAddrWidth  ),
    .AxiDataWidth ( AxiDataWidth  ),
    .AxiIdWidth   ( AxiSlvIdWidth ),
    .AxiUserWidth ( AxiUserWidth  ),
    .RegDataWidth ( 32 ),
    .CutMemReqs   ( 1 ),
    .axi_req_t    ( axi_slv_req_t ),
    .axi_rsp_t    ( axi_slv_rsp_t ),
    .reg_req_t    ( dma_regs_req_t ),
    .reg_rsp_t    ( dma_regs_rsp_t )
  ) i_axi_translate (
    .clk_i,
    .rst_ni,
    .axi_req_i  ( axi_slv_req_i ),
    .axi_rsp_o  ( axi_slv_rsp_o ),
    .reg_req_o  ( dma_reg_req ),
    .reg_rsp_i  ( dma_reg_rsp ),
    .busy_o     ( )
   );

  if (!IsTwoD) begin : gen_1d

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
      .busy_i         ( idma_busy ),
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
      .data_o     ( burst_req ),
      .valid_o    ( be_valid  ),
      .ready_i    ( be_ready  )
    );

    assign retire_id = idma_rsp_valid & idma_rsp_ready;
    assign issue_id  = be_valid_d & be_ready_d;
    assign idma_rsp_ready = 1'b1;

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

  end else begin : gen_2d
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
      .burst_req_o        ( burst_req ),
      .burst_req_valid_o  ( be_valid  ),
      .burst_req_ready_i  ( be_ready  ),
      .burst_rsp_i        ( idma_rsp       ),
      .burst_rsp_valid_i  ( idma_rsp_valid ),
      .burst_rsp_ready_o  ( idma_rsp_ready ),
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
    .idma_req_i       ( burst_req ),
    .req_valid_i      ( be_valid  ),
    .req_ready_o      ( be_ready  ),
    .idma_rsp_o       ( idma_rsp       ),
    .rsp_valid_o      ( idma_rsp_valid ),
    .rsp_ready_i      ( idma_rsp_ready ),
    .idma_eh_req_i    ( '0 ),
    .eh_req_valid_i   ( '0 ),
    .eh_req_ready_o   ( ),
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
   .mst_req_o         ( axi_mst_req_o ),
   .mst_resp_i        ( axi_mst_rsp_i )
  );

endmodule
