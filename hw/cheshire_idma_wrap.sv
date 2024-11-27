// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>
// Andreas Kuster <kustera@ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
// Chaoqun Liang <chaoqun.liang@unibo.it>
// Raphael Roth <raroth@student.ethz.ch>

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
  output axi_mst_req_t  axi_ptw_req_o,
  input  axi_mst_rsp_t  axi_ptw_rsp_i,
  input  axi_slv_req_t  axi_slv_req_i,
  output axi_slv_rsp_t  axi_slv_rsp_o
);

  `include "axi/assign.svh"
  `include "axi/typedef.svh"
  `include "idma/typedef.svh"
  `include "register_interface/typedef.svh"
  `include "common_cells/registers.svh"
  `include "sMMU/typedef.svh"

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
  logic         burst_req_valid_d;
  logic         burst_req_ready_d;

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
  logic         burst_req_valid;
  logic         burst_req_ready;
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

  // sMMU Signal
  logic         smmu_f_bare;
  logic         smmu_f_exe;
  logic         smmu_f_user;
  logic         smmu_f_update_tlb;
  logic [63:0]  smmu_pt_root_adr;

  axi_to_reg #(
    .ADDR_WIDTH ( AxiAddrWidth  ),
    .DATA_WIDTH ( AxiDataWidth  ),
    .ID_WIDTH   ( AxiSlvIdWidth ),
    .USER_WIDTH ( AxiUserWidth  ),
    .axi_req_t  ( axi_slv_req_t ),
    .axi_rsp_t  ( axi_slv_rsp_t ),
    .reg_req_t  ( dma_regs_req_t ),
    .reg_rsp_t  ( dma_regs_rsp_t )
  ) i_axi_translate (
    .clk_i,
    .rst_ni,
    .testmode_i,
    .axi_req_i  ( axi_slv_req_i ),
    .axi_rsp_o  ( axi_slv_rsp_o ),
    .reg_req_o  ( dma_reg_req ),
    .reg_rsp_i  ( dma_reg_rsp )
   );

  if (!IsTwoD) begin : gen_1d

    idma_reg64_1d #(
      .NumRegs            ( 32'd1 ),
      .NumStreams         ( 32'd1 ),
      .IdCounterWidth     ( IdCounterWidth ),
      .reg_req_t          ( dma_regs_req_t ),
      .reg_rsp_t          ( dma_regs_rsp_t ),
      .dma_req_t          ( idma_req_t )
    ) i_dma_frontend_1d (
      .clk_i,
      .rst_ni,
      .dma_ctrl_req_i     ( dma_reg_req ),
      .dma_ctrl_rsp_o     ( dma_reg_rsp ),
      .dma_req_o          ( burst_req_d ),
      .req_valid_o        ( burst_req_valid_d  ),
      .req_ready_i        ( burst_req_ready_d  ),
      .next_id_i          ( next_id ),
      .stream_idx_o       ( ),
      .smmu_f_bare        ( smmu_f_bare ),
      .smmu_f_exe         ( smmu_f_exe ),
      .smmu_f_user        ( smmu_f_user ),
      .smmu_f_update_tlb  ( smmu_f_update_tlb ),
      .smmu_pt_root_adr   ( smmu_pt_root_adr ),
      .done_id_i          ( done_id ),
      .busy_i             ( idma_busy ),
      .midend_busy_i      ( 1'b0 )
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
      .valid_i    ( burst_req_valid_d  ),
      .ready_o    ( burst_req_ready_d  ),
      .data_o     ( burst_req ),
      .valid_o    ( burst_req_valid  ),
      .ready_i    ( burst_req_ready  )
    );

    assign retire_id = idma_rsp_valid & idma_rsp_ready;
    assign issue_id  = burst_req_valid_d & burst_req_ready_d;
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
      .burst_req_valid_o  ( burst_req_valid  ),
      .burst_req_ready_i  ( burst_req_ready  ),
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

  // Insert here the sMMU !


  // TODO:
  /*
  Questions:
    - How can i be 100% sure that the size of the src/dst adresses and length matches?
    - What should we do with the idma_rsp? No analysis is done in the sMMU!
    - Aufpassen mit den Längen wie viel datan man z.b. lopieren kann! Ich habe von Param:0 vector erstellt, thomas von Param-1:0
    - Error handler: First Error will be piped through with a fall-through-register. Otherwise the latest DMA Response will be feed trought
  */

  /* Local Parameter */



  // RV-Depending Parameter
  localparam int unsigned sMMU_VAWidth = AxiAddrWidth;
  localparam int unsigned sMMU_NRLevel = 4;
  localparam int unsigned sMMU_PAWidth = 56;
  localparam int unsigned sMMU_PTEByteSizeLog2 = 3; // --> RV32 = 2 (4 byte) else = 3 (8 byte)
  // !!!! Remember to change the Value in the Package too !!!!

  // Input Request Design Parameter
  localparam int unsigned sMMU_MaxByteTransferWidth = TfLenWidth;
  localparam int unsigned sMMU_PageSize = 12;
  localparam int unsigned sMMU_MaxPageTransferWidth = sMMU_MaxByteTransferWidth - sMMU_PageSize;
  // !!!! Remember to change the Value in the Package too !!!!

  // System Buffer Parameter
  localparam int unsigned sMMU_ReorderBufferSize = 9;
  localparam int unsigned sMMU_StreamIDSize = cf_math_pkg::idx_width(sMMU_ReorderBufferSize);
  localparam int unsigned sMMU_OverallStreamsSMMU = (10*sMMU_ReorderBufferSize);    // How many different streams can be concurrently in the forward !and! backward path of the sMMU?
  localparam int unsigned sMMU_DispatchBuffer = sMMU_ReorderBufferSize;   // How many different streams can be concurrently in the forward path of the sMMU? Worst Case: One fragment per Stream
  localparam int unsigned sMMU_TLBNumberEntries = 5;

  // System Policies Parameter
  localparam int unsigned sMMU_FillPolicyTLB = 1; //
  localparam int unsigned sMMU_ReplacementPolicyTLB = 1;

  `SMMU_TYPEDEF_GEN_SV57(va_t, pa_t, pte_t)
  `SMMU_TYPEDEF_GEN_DEFAULT(va_t, pa_t, options_t, sMMU_StreamIDSize, sMMU_MaxByteTransferWidth, sMMU_MaxPageTransferWidth, sMMU_PageSize)

  /* Variable */

  // Forward Data-Connection from the frontend to the sMMU
  input_front_end_t smmu_multi_page_req;
  logic smmu_multi_page_req_valid;
  logic smmu_multi_page_req_ready;

  // Forward Data-Connection from the sMMU to the backend (incl cast between idma & smmu typedef)
  output_back_end_t smmu_single_page_req;
  logic smmu_single_page_req_valid;
  logic smmu_single_page_req_ready;

  idma_req_t idma_single_page_req;
  logic idma_single_page_req_valid;
  logic idma_single_page_req_ready;

  // Backward Feedback Connection from backend to sMMU
  idma_rsp_t idma_single_page_resp;
  logic idma_single_page_resp_valid;
  logic idma_single_page_resp_ready;

  // Backward Feedback Connection from the sMMU to the frontend
  idma_rsp_t idma_multi_page_resp;
  logic idma_multi_page_resp_valid;
  logic idma_multi_page_resp_ready;

  // Signals to register an Backend Error Correctly
  idma_rsp_t idma_resp_register_d, idma_resp_register_q;

  // Assign the Connection between the Frontend and the sMMU
  assign smmu_multi_page_req = '{
    src: burst_req.src_addr,
    dst: burst_req.dst_addr,
    length: burst_req.length,
    f_exe: smmu_f_exe,
    f_user: smmu_f_user,
    f_bare: smmu_f_bare,
    f_update_tlb: smmu_f_update_tlb,
    add_infos: burst_req.opt
  };

  assign smmu_multi_page_req_valid = burst_req_valid;
  assign burst_req_ready = smmu_multi_page_req_ready;

  assign idma_rsp = idma_multi_page_resp;
  assign idma_rsp_valid = idma_multi_page_resp_valid;
  assign idma_multi_page_resp_ready = idma_rsp_ready;

  // Assign the Connection between the Backend and the sMMU
  assign idma_single_page_req = '{
    length: smmu_single_page_req.length,
    src_addr: smmu_single_page_req.src,
    dst_addr: smmu_single_page_req.dst,
    opt: smmu_single_page_req.add_infos
  };

  assign idma_single_page_req_valid = smmu_single_page_req_valid;
  assign smmu_single_page_req_ready = idma_single_page_req_ready;


  // Whacky Workaround which allows !!! only !!! the Error Response from the backend circumvent the sMMU!
  // This works primarily because the sMMU doesn't ack any handshake to the backendend unless the frontend had ack'ed the last request!
  // So no reordering of any response can happen
  always_comb begin : proc_response
    // Set default signals
    idma_resp_register_d = idma_resp_register_q;
    idma_multi_page_resp = '0;

    // We have a valid handshake @ the backend --> latch the response
    if((idma_single_page_resp_valid == 1'b1) && (idma_single_page_resp_ready == 1'b1) && (idma_resp_register_d.error == 1'b0)) begin
      idma_resp_register_d = idma_single_page_resp;
    end

    // Forward the information to the Frontend Signal
    idma_multi_page_resp = idma_resp_register_d;

    // We have a valid handshake @ the frontend --> clear the response
    if((idma_multi_page_resp_valid == 1'b1) && (idma_multi_page_resp_ready == 1'b1)) begin
      idma_resp_register_d.error = 1'b0;
    end
  end

  // Register all required signals
  `FF(idma_resp_register_q, idma_resp_register_d, '0, clk_i, rst_ni)

  // Instanciate the streamMMU
  sMMU #(
    .SizeDispatchBuffer                     (sMMU_DispatchBuffer),
    .SizeOverallStreamsSMMU                 (sMMU_OverallStreamsSMMU),
    .SizeReorderBuffer                      (sMMU_ReorderBufferSize),
    .SizeDoubleTabBuffer                    (0),
    .VaWidth                                (sMMU_VAWidth),
    .PaWidth                                (sMMU_PAWidth),
    .PageSizeWidth                          (sMMU_PageSize),
    .MaxByteTransferWidth                   (sMMU_MaxByteTransferWidth),
    .MaxPageTransferWidth                   (sMMU_MaxPageTransferWidth),
    .SizeTLB                                (sMMU_TLBNumberEntries),
    .PTEByteSizeLog2                        (sMMU_PTEByteSizeLog2),
    .NrLevel                                (sMMU_NRLevel),
    .CutOffTLBEntries                       (0),
    .ReplacementPolicyTLB                   (sMMU_ReplacementPolicyTLB),
    .FillPolicyTLB                          (sMMU_FillPolicyTLB),
    .BypassTranslation                      (0),
    // Take Typedef Name from the include File
    .va_dma_req_t                           (input_front_end_t),
    .va_frag_req_t                          (output_legalizer_t),
    .va_frag_req_id_app_t                   (input_translation_t),
    .pa_frag_req_id_app_t                   (input_reorder_buffer_t),
    .pa_dma_req_t                           (output_back_end_t),
    .meta_data_stream_t                     (meta_data_stream_t),
    .meta_data_fragment_t                   (meta_data_fragment_t),
    .sMMU_stream_id_t                       (sMMU_stream_id_t),
    .sMMU_frag_id_t                         (sMMU_frag_id_t),
    .pa_t                                   (pa_t),
    .va_t                                   (va_t),
    .pa_complete_adress_t                   (pa_complete_adress_t),
    .axi_req_t                              (axi_mst_req_t),
    .axi_resp_t                             (axi_mst_rsp_t),
    .pte_t                                  (pte_t),
    .error_t                                (error_sMMU_t)
  ) i_sMMU (
    .clk_i                                  (clk_i),
    .rst_ni                                 (rst_ni),
    .en_double_tab_i                        (1'b0),
    .dma_req_i                              (smmu_multi_page_req),
    .valid_i                                (smmu_multi_page_req_valid),
    .ready_o                                (smmu_multi_page_req_ready),
    .dma_req_o                              (smmu_single_page_req),
    .valid_o                                (smmu_single_page_req_valid),
    .ready_i                                (smmu_single_page_req_ready),
    .ret_valid_i                            (idma_single_page_resp_valid),
    .ret_ready_o                            (idma_single_page_resp_ready),
    .ret_valid_o                            (idma_multi_page_resp_valid),
    .ret_ready_i                            (idma_multi_page_resp_ready),
    .axi_resp_i                             ( axi_ptw_rsp_i ),
    .axi_req_o                              ( axi_ptw_req_o ),
    .pt_src_i                               (smmu_pt_root_adr[sMMU_PAWidth-1:sMMU_PageSize]), // Only slice the ppn from the pt root register (discard all bits above PASize & below page table)
    .fe_error_o                             (),
    .fe_error_valid_o                       (),
    .fe_error_ready_i                       (1'b0),
    .fe_error_extern_valid_i                (1'b0),
    .fe_error_extern_ready_o                (),
    .fe_flush_normal_valid_i                (1'b0),
    .fe_flush_normal_ready_o                (),
    .fe_flush_error_valid_i                 (1'b0),
    .fe_flush_error_ready_o                 (),
    .fe_flush_hard_valid_i                  (1'b0),
    .fe_flush_hard_ready_o                  ()
  );


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
    .idma_req_i       ( idma_single_page_req ),
    .req_valid_i      ( idma_single_page_req_valid  ),
    .req_ready_o      ( idma_single_page_req_ready  ),
    .idma_rsp_o       ( idma_single_page_resp ),
    .rsp_valid_o      ( idma_single_page_resp_valid ),
    .rsp_ready_i      ( idma_single_page_resp_ready ),
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
