// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Cyril Koenig <cykoenig@iis.ee.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
// Yvan Tortorella <yvan.tortorella@gmail.com>
//
// Resize AXI AW, IW, and DW before connecting to a Xilinx DRAM controller.

`include "cheshire/typedef.svh"
`include "phy_definitions.svh"
`include "common_cells/registers.svh"

module dram_wrapper_xilinx #(
  parameter type axi_soc_aw_chan_t = logic,
  parameter type axi_soc_w_chan_t  = logic,
  parameter type axi_soc_b_chan_t  = logic,
  parameter type axi_soc_ar_chan_t = logic,
  parameter type axi_soc_r_chan_t  = logic,
  parameter type axi_soc_req_t     = logic,
  parameter type axi_soc_resp_t    = logic,
  parameter int unsigned Ddr4CsNWidth = 1,
  parameter int unsigned Ddr4DmDbiNWidth = 8,
  parameter int unsigned Ddr4DqWidth = 64,
  parameter int unsigned Ddr4DqsWidth = 8
) (
  // System reset
  input  logic  sys_rst_i,
  input  logic  dram_clk_i,
  // Controller reset
  input  logic  soc_resetn_i,
  input  logic  soc_clk_i,
  // PHY interfaces
`ifdef USE_DDR4
  `DDR4_INTF(Ddr4CsNWidth, Ddr4DmDbiNWidth, Ddr4DqWidth, Ddr4DqsWidth)
`endif
`ifdef USE_DDR3
  `DDR3_INTF
`endif
  // DRAM AXI interface
  input  axi_soc_req_t  soc_req_i,
  output axi_soc_resp_t soc_rsp_o
);

  //////////////////////////////////////
  //  Configurations and definitions  //
  //////////////////////////////////////

  typedef struct packed {
    bit     EnCdc;
    integer CdcLogDepth;
    integer IdWidth;
    integer AddrWidth;
    integer DataWidth;
    integer StrobeWidth;
    integer MaxUniqIds;
    integer MaxTxns;
  } dram_cfg_t;

`ifdef TARGET_VCU118
  localparam dram_cfg_t cfg = '{
    EnCdc         : 1,    // 333 MHz AXI (cf. CdcLogDepth)
    CdcLogDepth   : 5,
    IdWidth       : 8,
    AddrWidth     : 31,
    DataWidth     : 512,
    StrobeWidth   : 64,
    MaxUniqIds    : 8,    // TODO: suboptimal, but limited by CVA6/LLC
    MaxTxns       : 24    // TODO: suboptimal, but limited by CVA6/LLC
  };
`endif

`ifdef TARGET_VCU128
  localparam dram_cfg_t cfg = '{
    EnCdc         : 1,    // 333 MHz AXI (cf. CdcLogDepth)
    CdcLogDepth   : 5,
    IdWidth       : 8,
    AddrWidth     : 32,
    DataWidth     : 512,
    StrobeWidth   : 64,
    MaxUniqIds    : 8,    // TODO: suboptimal, but limited by CVA6/LLC
    MaxTxns       : 24    // TODO: suboptimal, but limited by CVA6/LLC
  };
`endif

`ifdef TARGET_GENESYS2
  localparam dram_cfg_t cfg = '{
    EnCdc         : 1,    // 200 MHz AXI (cf. CCdcLogDepth)
    CdcLogDepth   : 5,
    IdWidth       : 4,    // Fixed
    AddrWidth     : 30,
    DataWidth     : 64,
    StrobeWidth   : 8,
    MaxUniqIds    : 8,    // TODO: suboptimal, but limited by CVA6/LLC
    MaxTxns       : 24    // TODO: suboptimal, but limited by CVA6/LLC
  };
`endif

  localparam SocDataWidth = $bits(soc_req_i.w.data);
  localparam SocIdWidth   = $bits(soc_req_i.ar.id);
  localparam SocUserWidth = $bits(soc_req_i.ar.user);
  localparam SocAddrWidth = $bits(soc_req_i.ar.addr);

  // Define type after data width and address resizer
  `AXI_TYPEDEF_ALL(axi_dw, logic[SocAddrWidth-1:0], logic[SocIdWidth-1:0],
                   logic[cfg.DataWidth-1:0], logic[cfg.StrobeWidth-1:0],
                   logic[SocUserWidth-1:0])

  // Define type after data & id width resizers
  `AXI_TYPEDEF_ALL(axi_dw_iw, logic[SocAddrWidth-1:0], logic[cfg.IdWidth-1:0],
                   logic[cfg.DataWidth-1:0], logic[cfg.StrobeWidth-1:0],
                   logic[SocUserWidth-1:0])

  // Clock on which is clocked the DRAM AXI
  logic dram_axi_clk;
  logic dram_rst_o;

  // Signals before resizing
  axi_soc_req_t  soc_dresizer_req;
  axi_soc_resp_t soc_dresizer_rsp;

  // Signals after data width resizing
  axi_dw_req_t  dresizer_iresizer_req;
  axi_dw_resp_t dresizer_iresizer_rsp;

  // Signals after id width resizing
  axi_dw_iw_req_t  iresizer_cdc_req, cdc_dram_req;
  axi_dw_iw_resp_t iresizer_cdc_rsp, cdc_dram_rsp;

  // Entry signals
  assign soc_dresizer_req = soc_req_i;
  assign soc_rsp_o = soc_dresizer_rsp;

  ////////////////////
  //  DW converter  //
  ////////////////////

  axi_dw_converter #(
    .AxiMaxReads          ( cfg.MaxTxns   ),
    .AxiSlvPortDataWidth  ( SocDataWidth  ),
    .AxiMstPortDataWidth  ( cfg.DataWidth ),
    .AxiAddrWidth         ( SocAddrWidth  ),
    .AxiIdWidth           ( SocIdWidth    ),
    // Common AW, AR, B
    .aw_chan_t            ( axi_soc_aw_chan_t ),
    .b_chan_t             ( axi_soc_b_chan_t  ),
    .ar_chan_t            ( axi_soc_ar_chan_t ),
    // Manager W, R
    .mst_w_chan_t         ( axi_dw_w_chan_t ),
    .mst_r_chan_t         ( axi_dw_r_chan_t ),
    .axi_mst_req_t        ( axi_dw_req_t    ),
    .axi_mst_resp_t       ( axi_dw_resp_t   ),
    // Subordinate W, R
    .slv_w_chan_t         ( axi_soc_w_chan_t ),
    .slv_r_chan_t         ( axi_soc_r_chan_t ),
    .axi_slv_req_t        ( axi_soc_req_t  ),
    .axi_slv_resp_t       ( axi_soc_resp_t )
  ) i_axi_dw_converter (
    .clk_i      ( soc_clk_i    ),
    .rst_ni     ( soc_resetn_i ),
    .slv_req_i  ( soc_dresizer_req ),
    .slv_resp_o ( soc_dresizer_rsp ),
    .mst_req_o  ( dresizer_iresizer_req ),
    .mst_resp_i ( dresizer_iresizer_rsp )
  );

  //////////////////
  //  ID resizer  //
  //////////////////

  // TODO: Implement simpler solutions
  axi_iw_converter #(
    .AxiAddrWidth           ( SocAddrWidth  ),
    .AxiDataWidth           ( cfg.DataWidth ),
    .AxiUserWidth           ( SocUserWidth  ),
    .AxiSlvPortIdWidth      ( SocIdWidth    ),
    .AxiSlvPortMaxUniqIds   ( cfg.MaxUniqIds ),
    .AxiSlvPortMaxTxnsPerId ( cfg.MaxTxns    ),
    .AxiSlvPortMaxTxns      ( cfg.MaxTxns    ),
    .AxiMstPortIdWidth      ( cfg.IdWidth    ),
    .AxiMstPortMaxUniqIds   ( cfg.MaxUniqIds ),
    .AxiMstPortMaxTxnsPerId ( cfg.MaxTxns    ),
    .slv_req_t              ( axi_dw_req_t     ),
    .slv_resp_t             ( axi_dw_resp_t    ),
    .mst_req_t              ( axi_dw_iw_req_t  ),
    .mst_resp_t             ( axi_dw_iw_resp_t )
  ) i_axi_iw_converter (
    .clk_i      ( soc_clk_i    ),
    .rst_ni     ( soc_resetn_i ),
    .slv_req_i  ( dresizer_iresizer_req ),
    .slv_resp_o ( dresizer_iresizer_rsp ),
    .mst_req_o  ( iresizer_cdc_req ),
    .mst_resp_i ( iresizer_cdc_rsp )
  );

  ////////////////////////
  //  Instiantiate CDC  //
  ////////////////////////

  if (cfg.EnCdc) begin : gen_cdc
    axi_cdc #(
      .aw_chan_t  ( axi_dw_iw_aw_chan_t),
      .w_chan_t   ( axi_dw_iw_w_chan_t),
      .b_chan_t   ( axi_dw_iw_b_chan_t),
      .ar_chan_t  ( axi_dw_iw_ar_chan_t),
      .r_chan_t   ( axi_dw_iw_r_chan_t),
      .axi_req_t  ( axi_dw_iw_req_t),
      .axi_resp_t ( axi_dw_iw_resp_t),
      .LogDepth   ( cfg.CdcLogDepth )
    ) i_axi_cdc_mig (
      .src_clk_i  ( soc_clk_i    ),
      .src_rst_ni ( soc_resetn_i ),
      .src_req_i  ( iresizer_cdc_req ),
      .src_resp_o ( iresizer_cdc_rsp ),
      .dst_clk_i  ( dram_axi_clk ),
      .dst_rst_ni ( ~dram_rst_o  ),
      .dst_req_o  ( cdc_dram_req ),
      .dst_resp_i ( cdc_dram_rsp )
    );
  end else begin : gen_no_cdc
    assign cdc_dram_req     = iresizer_cdc_req;
    assign iresizer_cdc_rsp = cdc_dram_rsp;
  end

  ////////////////////////////////
  //  Map User, Resize Address  //
  ////////////////////////////////

  assign cdc_dram_rsp.b.user = '0;
  assign cdc_dram_rsp.r.user = '0;

  logic [cfg.AddrWidth-1:0] cdc_dram_req_aw_addr;
  logic [cfg.AddrWidth-1:0] cdc_dram_req_ar_addr;

  assign cdc_dram_req_aw_addr = cdc_dram_req.aw.addr[cfg.AddrWidth-1:0];
  assign cdc_dram_req_ar_addr = cdc_dram_req.ar.addr[cfg.AddrWidth-1:0];

  /////////////////////////
  //  Instiantiate DDR4  //
  /////////////////////////

`ifdef USE_DDR4
  ddr4 i_dram (
    // Reset
    .sys_rst                    ( sys_rst_i    ),  // Active high
    .c0_sys_clk_i               ( dram_clk_i   ),
    .c0_ddr4_aresetn            ( soc_resetn_i ),
    // Clock and reset out
    .c0_ddr4_ui_clk             ( dram_axi_clk ),
    .c0_ddr4_ui_clk_sync_rst    ( dram_rst_o   ),
    // AXI
    .c0_ddr4_s_axi_awid         ( cdc_dram_req.aw.id    ),
    .c0_ddr4_s_axi_awaddr       ( cdc_dram_req_aw_addr  ),
    .c0_ddr4_s_axi_awlen        ( cdc_dram_req.aw.len   ),
    .c0_ddr4_s_axi_awsize       ( cdc_dram_req.aw.size  ),
    .c0_ddr4_s_axi_awburst      ( cdc_dram_req.aw.burst ),
    .c0_ddr4_s_axi_awlock       ( cdc_dram_req.aw.lock  ),
    .c0_ddr4_s_axi_awcache      ( cdc_dram_req.aw.cache ),
    .c0_ddr4_s_axi_awprot       ( cdc_dram_req.aw.prot  ),
    .c0_ddr4_s_axi_awqos        ( cdc_dram_req.aw.qos   ),
    .c0_ddr4_s_axi_awvalid      ( cdc_dram_req.aw_valid ),
    .c0_ddr4_s_axi_awready      ( cdc_dram_rsp.aw_ready ),
    .c0_ddr4_s_axi_wdata        ( cdc_dram_req.w.data   ),
    .c0_ddr4_s_axi_wstrb        ( cdc_dram_req.w.strb   ),
    .c0_ddr4_s_axi_wlast        ( cdc_dram_req.w.last   ),
    .c0_ddr4_s_axi_wvalid       ( cdc_dram_req.w_valid  ),
    .c0_ddr4_s_axi_wready       ( cdc_dram_rsp.w_ready  ),
    .c0_ddr4_s_axi_bready       ( cdc_dram_req.b_ready  ),
    .c0_ddr4_s_axi_bid          ( cdc_dram_rsp.b.id     ),
    .c0_ddr4_s_axi_bresp        ( cdc_dram_rsp.b.resp   ),
    .c0_ddr4_s_axi_bvalid       ( cdc_dram_rsp.b_valid  ),
    .c0_ddr4_s_axi_arid         ( cdc_dram_req.ar.id    ),
    .c0_ddr4_s_axi_araddr       ( cdc_dram_req_ar_addr  ),
    .c0_ddr4_s_axi_arlen        ( cdc_dram_req.ar.len   ),
    .c0_ddr4_s_axi_arsize       ( cdc_dram_req.ar.size  ),
    .c0_ddr4_s_axi_arburst      ( cdc_dram_req.ar.burst ),
    .c0_ddr4_s_axi_arlock       ( cdc_dram_req.ar.lock  ),
    .c0_ddr4_s_axi_arcache      ( cdc_dram_req.ar.cache ),
    .c0_ddr4_s_axi_arprot       ( cdc_dram_req.ar.prot  ),
    .c0_ddr4_s_axi_arqos        ( cdc_dram_req.ar.qos   ),
    .c0_ddr4_s_axi_arvalid      ( cdc_dram_req.ar_valid ),
    .c0_ddr4_s_axi_arready      ( cdc_dram_rsp.ar_ready ),
    .c0_ddr4_s_axi_rready       ( cdc_dram_req.r_ready  ),
    .c0_ddr4_s_axi_rid          ( cdc_dram_rsp.r.id     ),
    .c0_ddr4_s_axi_rdata        ( cdc_dram_rsp.r.data   ),
    .c0_ddr4_s_axi_rresp        ( cdc_dram_rsp.r.resp   ),
    .c0_ddr4_s_axi_rlast        ( cdc_dram_rsp.r.last   ),
    .c0_ddr4_s_axi_rvalid       ( cdc_dram_rsp.r_valid  ),
    `ifdef TARGET_VCU128
      // TODO: Shouldn't we map this to an external reg port?
      // AXI control
      .c0_ddr4_s_axi_ctrl_awvalid ( '0 ),
      .c0_ddr4_s_axi_ctrl_awready ( ),
      .c0_ddr4_s_axi_ctrl_awaddr  ( '0 ),
      .c0_ddr4_s_axi_ctrl_wvalid  ( '0 ),
      .c0_ddr4_s_axi_ctrl_wready  ( ),
      .c0_ddr4_s_axi_ctrl_wdata   ( '0 ),
      .c0_ddr4_s_axi_ctrl_bvalid  ( ),
      .c0_ddr4_s_axi_ctrl_bready  ( '0 ),
      .c0_ddr4_s_axi_ctrl_bresp   ( ),
      .c0_ddr4_s_axi_ctrl_arvalid ( '0 ),
      .c0_ddr4_s_axi_ctrl_arready ( ),
      .c0_ddr4_s_axi_ctrl_araddr  ( '0 ),
      .c0_ddr4_s_axi_ctrl_rvalid  ( ),
      .c0_ddr4_s_axi_ctrl_rready  ( '0 ),
      .c0_ddr4_s_axi_ctrl_rdata   ( ),
      .c0_ddr4_s_axi_ctrl_rresp   ( ),
      .c0_ddr4_interrupt          ( ),
    `endif
    // Others
    .c0_init_calib_complete     ( ),
    .addn_ui_clkout1            ( dram_clk_o ),
    .dbg_clk                    ( ),
    .dbg_bus                    ( ),
    // PHY
    .*
  );
`endif

  /////////////////////////
  //  Instiantiate DDR3  //
  /////////////////////////

`ifdef USE_DDR3
  mig7s i_dram (
    .sys_rst              ( sys_rst_i    ), // Active high
    .sys_clk_i            ( dram_clk_i   ),
    .ui_clk               ( dram_axi_clk ),
    .ui_clk_sync_rst      ( dram_rst_o ),
    .mmcm_locked          ( ),
    .app_sr_req           ( '0 ),
    .app_ref_req          ( '0 ),
    .app_zq_req           ( '0 ),
    .app_sr_active        ( ),
    .app_ref_ack          ( ),
    .app_zq_ack           ( ),
    .aresetn              ( soc_resetn_i ),
    .s_axi_awid           ( cdc_dram_req.aw.id    ),
    .s_axi_awaddr         ( cdc_dram_req_aw_addr  ),
    .s_axi_awlen          ( cdc_dram_req.aw.len   ),
    .s_axi_awsize         ( cdc_dram_req.aw.size  ),
    .s_axi_awburst        ( cdc_dram_req.aw.burst ),
    .s_axi_awlock         ( cdc_dram_req.aw.lock  ),
    .s_axi_awcache        ( cdc_dram_req.aw.cache ),
    .s_axi_awprot         ( cdc_dram_req.aw.prot  ),
    .s_axi_awqos          ( cdc_dram_req.aw.qos   ),
    .s_axi_awvalid        ( cdc_dram_req.aw_valid ),
    .s_axi_awready        ( cdc_dram_rsp.aw_ready ),
    .s_axi_wdata          ( cdc_dram_req.w.data   ),
    .s_axi_wstrb          ( cdc_dram_req.w.strb   ),
    .s_axi_wlast          ( cdc_dram_req.w.last   ),
    .s_axi_wvalid         ( cdc_dram_req.w_valid  ),
    .s_axi_wready         ( cdc_dram_rsp.w_ready  ),
    .s_axi_bready         ( cdc_dram_req.b_ready  ),
    .s_axi_bid            ( cdc_dram_rsp.b.id     ),
    .s_axi_bresp          ( cdc_dram_rsp.b.resp   ),
    .s_axi_bvalid         ( cdc_dram_rsp.b_valid  ),
    .s_axi_arid           ( cdc_dram_req.ar.id    ),
    .s_axi_araddr         ( cdc_dram_req_ar_addr  ),
    .s_axi_arlen          ( cdc_dram_req.ar.len   ),
    .s_axi_arsize         ( cdc_dram_req.ar.size  ),
    .s_axi_arburst        ( cdc_dram_req.ar.burst ),
    .s_axi_arlock         ( cdc_dram_req.ar.lock  ),
    .s_axi_arcache        ( cdc_dram_req.ar.cache ),
    .s_axi_arprot         ( cdc_dram_req.ar.prot  ),
    .s_axi_arqos          ( cdc_dram_req.ar.qos   ),
    .s_axi_arvalid        ( cdc_dram_req.ar_valid ),
    .s_axi_arready        ( cdc_dram_rsp.ar_ready ),
    .s_axi_rready         ( cdc_dram_req.r_ready  ),
    .s_axi_rid            ( cdc_dram_rsp.r.id     ),
    .s_axi_rdata          ( cdc_dram_rsp.r.data   ),
    .s_axi_rresp          ( cdc_dram_rsp.r.resp   ),
    .s_axi_rlast          ( cdc_dram_rsp.r.last   ),
    .s_axi_rvalid         ( cdc_dram_rsp.r_valid  ),
    .init_calib_complete  ( ),
    .device_temp          ( ),
    // PHY
    .*
  );
`endif  // USE_DDR3

endmodule
