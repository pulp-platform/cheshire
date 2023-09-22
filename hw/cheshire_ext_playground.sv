// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>

`include "cheshire/typedef.svh"
`include "axi/typedef.svh"

module cheshire_ext_playground
  import cheshire_pkg::*;
  import cheshire_ext_playground_pkg::*;
#(
  // Cheshire config
  parameter cheshire_cfg_t Cfg = '0,
  // Interconnect types (must agree with Cheshire config)
  parameter type axi_ext_mst_req_t  = logic,
  parameter type axi_ext_mst_rsp_t  = logic,
  parameter type axi_ext_slv_req_t  = logic,
  parameter type axi_ext_slv_rsp_t  = logic,
  parameter type reg_ext_req_t      = logic,
  parameter type reg_ext_rsp_t      = logic
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        test_mode_i,
  input  logic        rtc_i,
  // External AXI crossbar ports
  output axi_ext_mst_req_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_req_o,
  input  axi_ext_mst_rsp_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_rsp_i,
  input  axi_ext_slv_req_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_req_i,
  output axi_ext_slv_rsp_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_rsp_o,
  // External reg demux slaves
  input  reg_ext_req_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_req_i,
  output reg_ext_rsp_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_rsp_o
);

  // General parameters and defines
  `CHESHIRE_TYPEDEF_ALL(chs_playgnd_, Cfg)

  // Generate indices and get maps for all ports
  localparam axi_in_t   AxiIn   = gen_axi_in(Cfg);
  localparam axi_out_t  AxiOut  = gen_axi_out(Cfg);

  localparam int unsigned ChsPlaygndAxiSlvIdWidth = Cfg.AxiMstIdWidth + $clog2(AxiIn.num_in);

  // tied-off
  assign axi_ext_slv_rsp_o[PeriphsSlvIdx] = '0;


  ///////////////////////////////////////
  // DSAs' traffic generators (dma(s)) //
  ///////////////////////////////////////

  chs_playgnd_axi_slv_req_t [ChsPlaygndNumDsaDma-1:0] dsa_dma_amo_req, dsa_dma_cut_req;
  chs_playgnd_axi_slv_rsp_t [ChsPlaygndNumDsaDma-1:0] dsa_dma_amo_rsp, dsa_dma_cut_rsp;

  if (ChsPlaygndNumSlvDevices != Cfg.AxiExtNumSlv)
    $fatal(1, "the number of slave devices must be equal to the number of slave AXI ports");

  if (ChsPlaygndNumMstDevices != Cfg.AxiExtNumMst)
    $fatal(1, "the number of master devices must be equal to the number of master AXI ports");

  for (genvar i=0; i<ChsPlaygndNumDsaDma; i++) begin : gen_dsa_dmas
    axi_riscv_atomics_structs #(
      .AxiAddrWidth    ( Cfg.AddrWidth    ),
      .AxiDataWidth    ( Cfg.AxiDataWidth ),
      .AxiIdWidth      ( ChsPlaygndAxiSlvIdWidth ),
      .AxiUserWidth    ( Cfg.AxiUserWidth ),
      .AxiMaxReadTxns  ( Cfg.DmaConfMaxReadTxns  ),
      .AxiMaxWriteTxns ( Cfg.DmaConfMaxWriteTxns ),
      .AxiUserAsId     ( 1 ),
      .AxiUserIdMsb    ( Cfg.AxiUserAmoMsb ),
      .AxiUserIdLsb    ( Cfg.AxiUserAmoLsb ),
      .RiscvWordWidth  ( 64 ),
      .NAxiCuts        ( Cfg.DmaConfAmoNumCuts ),
      .axi_req_t       ( chs_playgnd_axi_slv_req_t ),
      .axi_rsp_t       ( chs_playgnd_axi_slv_rsp_t )
    ) i_dsa_dma_conf_atomics (
      .clk_i,
      .rst_ni,
      .axi_slv_req_i ( axi_ext_slv_req_i[Dsa0SlvIdx + i] ),
      .axi_slv_rsp_o ( axi_ext_slv_rsp_o[Dsa0SlvIdx + i] ),
      .axi_mst_req_o ( dsa_dma_amo_req[i] ),
      .axi_mst_rsp_i ( dsa_dma_amo_rsp[i] )
    );

    axi_cut #(
      .Bypass     ( ~Cfg.DmaConfAmoPostCut ),
      .aw_chan_t  ( chs_playgnd_axi_slv_aw_chan_t ),
      .w_chan_t   ( chs_playgnd_axi_slv_w_chan_t  ),
      .b_chan_t   ( chs_playgnd_axi_slv_b_chan_t  ),
      .ar_chan_t  ( chs_playgnd_axi_slv_ar_chan_t ),
      .r_chan_t   ( chs_playgnd_axi_slv_r_chan_t  ),
      .axi_req_t  ( chs_playgnd_axi_slv_req_t ),
      .axi_resp_t ( chs_playgnd_axi_slv_rsp_t )
    ) i_dsa_dma_conf_atomics_cut (
      .clk_i,
      .rst_ni,
      .slv_req_i  ( dsa_dma_amo_req[i] ),
      .slv_resp_o ( dsa_dma_amo_rsp[i] ),
      .mst_req_o  ( dsa_dma_cut_req[i] ),
      .mst_resp_i ( dsa_dma_cut_rsp[i] )
    );

    chs_playgnd_axi_mst_req_t [ChsPlaygndNumDsaDma-1:0] axi_dsa_dma_req;

    always_comb begin
      axi_ext_mst_req_o[Dsa0MstIdx + i]         = axi_dsa_dma_req[i];
      axi_ext_mst_req_o[Dsa0MstIdx + i].aw.user = Cfg.AxiUserDefault;
      axi_ext_mst_req_o[Dsa0MstIdx + i].w.user  = Cfg.AxiUserDefault;
      axi_ext_mst_req_o[Dsa0MstIdx + i].ar.user = Cfg.AxiUserDefault;
    end

    dma_core_wrap #(
      .AxiAddrWidth     ( Cfg.AddrWidth           ),
      .AxiDataWidth     ( Cfg.AxiDataWidth        ),
      .AxiIdWidth       ( Cfg.AxiMstIdWidth       ),
      .AxiUserWidth     ( Cfg.AxiUserWidth        ),
      .AxiSlvIdWidth    ( ChsPlaygndAxiSlvIdWidth ),
      .NumAxInFlight    ( Cfg.DmaNumAxInFlight    ),
      .MemSysDepth      ( Cfg.DmaMemSysDepth      ),
      .JobFifoDepth     ( Cfg.DmaJobFifoDepth     ),
      .RAWCouplingAvail ( Cfg.DmaRAWCouplingAvail ),
      .IsTwoD           ( Cfg.DmaConfEnableTwoD   ),
      .axi_mst_req_t    ( chs_playgnd_axi_mst_req_t ),
      .axi_mst_rsp_t    ( chs_playgnd_axi_mst_rsp_t ),
      .axi_slv_req_t    ( chs_playgnd_axi_slv_req_t ),
      .axi_slv_rsp_t    ( chs_playgnd_axi_slv_rsp_t )
    ) i_dsa_dma (
      .clk_i,
      .rst_ni,
      .testmode_i     ( test_mode_i ),
      .axi_mst_req_o  ( axi_dsa_dma_req[i] ),
      .axi_mst_rsp_i  ( axi_ext_mst_rsp_i[Dsa0MstIdx + i] ),
      .axi_slv_req_i  ( dsa_dma_cut_req[i] ),
      .axi_slv_rsp_o  ( dsa_dma_cut_rsp[i] )
    );
  end

  // Memories
  localparam int unsigned ChsPlaygndNumAxiMems = 3;

  // axi interface
  chs_playgnd_axi_slv_req_t [ChsPlaygndNumAxiMems-1:0] chs_playgnd_axi_mem_req;
  chs_playgnd_axi_slv_rsp_t [ChsPlaygndNumAxiMems-1:0] chs_playgnd_axi_mem_rsp;

  // mem interface

  localparam int unsigned NumWords = 128*1024;
  localparam int unsigned MemAddrWidth = $clog2(NumWords);
  logic [ChsPlaygndNumAxiMems-1:0] mem_req, mem_gnt, mem_we, mem_rvalid, mem_rvalid_q;
  logic [ChsPlaygndNumAxiMems-1:0] [Cfg.AddrWidth-1:0]       mem_addr;
  logic [ChsPlaygndNumAxiMems-1:0] [Cfg.AxiDataWidth-1:0]    mem_wdata, mem_rdata;
  logic [ChsPlaygndNumAxiMems-1:0] [Cfg.AxiDataWidth/8-1:0]  mem_strb;

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_delay
    if(~rst_ni) begin
      mem_rvalid_q <= 0;
    end else begin
      mem_rvalid_q <= mem_rvalid;
    end
  end

  assign mem_gnt = '1; //mem_req;
  assign mem_rvalid = mem_req;

  for (genvar i=0; i<ChsPlaygndNumAxiMems; i++ ) begin : gen_axi_mems

    chs_playgnd_axi_slv_req_t axi_mem_req;
    chs_playgnd_axi_slv_rsp_t axi_mem_rsp;

    axi_fifo #(
      .Depth(3),
      .FallThrough (1'b0),
      .aw_chan_t (chs_playgnd_axi_slv_aw_chan_t),
      .w_chan_t  (chs_playgnd_axi_slv_w_chan_t),
      .b_chan_t  (chs_playgnd_axi_slv_b_chan_t),
      .ar_chan_t (chs_playgnd_axi_slv_ar_chan_t),
      .r_chan_t  (chs_playgnd_axi_slv_r_chan_t),
      .axi_req_t (chs_playgnd_axi_slv_req_t),
      .axi_resp_t(chs_playgnd_axi_slv_rsp_t)
    ) i_axi_fifo (
      .clk_i,
      .rst_ni,
      .test_i     ( 1'b0  ),
      .slv_req_i  ( axi_ext_slv_req_i[i+MemWriteSlvIdx] ),
      .slv_resp_o ( axi_ext_slv_rsp_o[i+MemWriteSlvIdx] ),
      .mst_req_o  ( axi_mem_req ),
      .mst_resp_i ( axi_mem_rsp )
    );

    axi_to_mem_interleaved #(
      .axi_req_t    (chs_playgnd_axi_slv_req_t),
      .axi_resp_t   (chs_playgnd_axi_slv_rsp_t),
      .AddrWidth    (Cfg.AddrWidth),
      .DataWidth    (Cfg.AxiDataWidth),
      .IdWidth      (ChsPlaygndAxiSlvIdWidth),
      .NumBanks     (1),
      .BufDepth     (128),
      .HideStrb     (0),
      .OutFifoDepth (128)
    ) chs_playgnd_i_axi_to_mem (
      .clk_i,
      .rst_ni,
      .busy_o       ( ),
      .axi_req_i    ( axi_mem_req),
      .axi_resp_o   ( axi_mem_rsp),
      .mem_req_o    ( mem_req[i]),
      .mem_gnt_i    ( mem_gnt[i]),
      .mem_addr_o   ( mem_addr[i]),
      .mem_wdata_o  ( mem_wdata[i]),
      .mem_strb_o   ( mem_strb[i]),
      .mem_atop_o   (  ),
      .mem_we_o     ( mem_we[i]),
      .mem_rvalid_i ( mem_rvalid_q[i]),
      .mem_rdata_i  ( mem_rdata[i])
    );

    tc_sram #(
      .NumWords  ( NumWords ), // Number of Words in data array
      .DataWidth ( Cfg.AxiDataWidth ), // Data signal width
      .ByteWidth ( 8 ), // Width of a data byte
      .NumPorts  ( 1 ), // Number of read and write ports
      .SimInit   ( "random" ),
      .Latency   ( 1 ) // Latency when the read data is available
    ) chs_playgnd_i_tc_sram (
      .clk_i,         // Clock
      .rst_ni,        // Asynchronous reset active low
      .req_i   ( mem_req[i]   ), // request
      .we_i    ( mem_we[i]    ), // write enable
      .addr_i  ( mem_addr[i][MemAddrWidth-1:0] ), // request address
      .wdata_i ( mem_wdata[i] ), // write data
      .be_i    ( mem_strb[i]  ), // write byte enable

      .rdata_o ( mem_rdata[i] )  // read data
    );
//  axi_sim_mem #(
//    .AddrWidth          ( Cfg.AddrWidth    ),
//    .DataWidth          ( Cfg.AxiDataWidth ),
//    .IdWidth            ( ChsPlaygndAxiSlvIdWidth ),
//    .UserWidth          ( Cfg.AxiUserWidth ),
//    .axi_req_t          ( chs_playgnd_axi_slv_req_t ),
//    .axi_rsp_t          ( chs_playgnd_axi_slv_rsp_t ),
//    .WarnUninitialized  ( 0 ),
//    .ClearErrOnAccess   ( 1 ),
//    .ApplDelay          ( 5ns * 0.1 ),
//    .AcqDelay           ( 5ns * 0.9 )
//  ) chs_playgnd_i_axi_sim_mem (
//    .clk_i,
//    .rst_ni,
//    .axi_req_i          ( axi_ext_slv_req_i[i+MemWriteSlvIdx] ),
//    .axi_rsp_o          ( axi_ext_slv_rsp_o[i+MemWriteSlvIdx] ),
//    .mon_w_valid_o      ( ),
//    .mon_w_addr_o       ( ),
//    .mon_w_data_o       ( ),
//    .mon_w_id_o         ( ),
//    .mon_w_user_o       ( ),
//    .mon_w_beat_count_o ( ),
//    .mon_w_last_o       ( ),
//    .mon_r_valid_o      ( ),
//    .mon_r_addr_o       ( ),
//    .mon_r_data_o       ( ),
//    .mon_r_id_o         ( ),
//    .mon_r_user_o       ( ),
//    .mon_r_beat_count_o ( ),
//    .mon_r_last_o       ( )
//  );
//
//  initial begin
//    for (int j=0; j<128*1024; j++) begin
//      chs_playgnd_i_axi_sim_mem.mem[MemWriteBase + 'h10000000*i + j] = {'d8{$urandom()}};
//    end
//  end
  end

endmodule
