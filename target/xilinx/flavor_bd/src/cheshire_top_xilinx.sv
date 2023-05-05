// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Cyril Koenig <cykoenig@iis.ee.ethz.ch>

`include "axi/typedef.svh"
`include "cheshire/typedef.svh"

module cheshire_top_xilinx
  import cheshire_pkg::*;
#(
) (
  input  logic         cpu_reset,

  input  logic         clk_10,
  input  logic         clk_20,
  input  logic         clk_50,
  input  logic         clk_100,

  input  logic         testmode_i,
  input  logic [1:0]   boot_mode_i,

  input  logic         jtag_tck_i,
  input  logic         jtag_tms_i,
  input  logic         jtag_tdi_i,
  output logic         jtag_tdo_o,
  input  logic         jtag_trst_ni,
  output logic         jtag_vdd_o,
  output logic         jtag_gnd_o,

  output logic         uart_tx_o,
  input  logic         uart_rx_i,

  // GPIOs will be used as interrupts,
  input  logic [31:0]  gpio_i,

  // Dram axi

  output wire dram_axi_m_aclk,
  output wire dram_axi_m_aresetn,

  output wire [6:0] dram_axi_m_axi_awid,
  output wire [47:0] dram_axi_m_axi_awaddr,
  output wire [7:0] dram_axi_m_axi_awlen,
  output wire [2:0] dram_axi_m_axi_awsize,
  output wire [1:0] dram_axi_m_axi_awburst,
  output wire dram_axi_m_axi_awlock,
  output wire [3:0] dram_axi_m_axi_awcache,
  output wire [2:0] dram_axi_m_axi_awprot,
  output wire [3:0] dram_axi_m_axi_awqos,
  output wire dram_axi_m_axi_awvalid,
  input  wire dram_axi_m_axi_awready,

  output wire [63:0] dram_axi_m_axi_wdata,
  output wire [7:0] dram_axi_m_axi_wstrb,
  output wire dram_axi_m_axi_wlast,
  output wire dram_axi_m_axi_wvalid,
  input  wire dram_axi_m_axi_wready,

  output wire dram_axi_m_axi_bready,
  input  wire [6:0] dram_axi_m_axi_bid,
  input  wire [1:0] dram_axi_m_axi_bresp,
  input  wire dram_axi_m_axi_bvalid,

  output wire [6:0]dram_axi_m_axi_arid,
  output wire [47:0] dram_axi_m_axi_araddr,
  output wire [7:0] dram_axi_m_axi_arlen,
  output wire [2:0] dram_axi_m_axi_arsize,
  output wire [1:0] dram_axi_m_axi_arburst,
  output wire dram_axi_m_axi_arlock,
  output wire [3:0] dram_axi_m_axi_arcache,
  output wire [2:0] dram_axi_m_axi_arprot,
  output wire [3:0] dram_axi_m_axi_arqos,
  output wire dram_axi_m_axi_arvalid,
  input  wire dram_axi_m_axi_arready,

  output wire dram_axi_m_axi_rready,
  input  wire [6:0] dram_axi_m_axi_rid,
  input  wire [63:0] dram_axi_m_axi_rdata,
  input  wire [1:0] dram_axi_m_axi_rresp,
  input  wire dram_axi_m_axi_rlast,
  input  wire dram_axi_m_axi_rvalid,

  // Periph axi out

  output wire periph_axi_m_aclk,
  output wire periph_axi_m_aresetn,

  output wire [1:0] periph_axi_m_axi_awid,
  output wire [47:0] periph_axi_m_axi_awaddr,
  output wire [7:0] periph_axi_m_axi_awlen,
  output wire [2:0] periph_axi_m_axi_awsize,
  output wire [1:0] periph_axi_m_axi_awburst,
  output wire periph_axi_m_axi_awlock,
  output wire [3:0] periph_axi_m_axi_awcache,
  output wire [2:0] periph_axi_m_axi_awprot,
  output wire [3:0] periph_axi_m_axi_awqos,
  output wire periph_axi_m_axi_awvalid,
  input  wire periph_axi_m_axi_awready,

  output wire [63:0] periph_axi_m_axi_wdata,
  output wire [7:0] periph_axi_m_axi_wstrb,
  output wire periph_axi_m_axi_wlast,
  output wire periph_axi_m_axi_wvalid,
  input  wire periph_axi_m_axi_wready,

  output wire periph_axi_m_axi_bready,
  input  wire [1:0] periph_axi_m_axi_bid,
  input  wire [1:0] periph_axi_m_axi_bresp,
  input  wire periph_axi_m_axi_bvalid,

  output wire [1:0]periph_axi_m_axi_arid,
  output wire [47:0] periph_axi_m_axi_araddr,
  output wire [7:0] periph_axi_m_axi_arlen,
  output wire [2:0] periph_axi_m_axi_arsize,
  output wire [1:0] periph_axi_m_axi_arburst,
  output wire periph_axi_m_axi_arlock,
  output wire [3:0] periph_axi_m_axi_arcache,
  output wire [2:0] periph_axi_m_axi_arprot,
  output wire [3:0] periph_axi_m_axi_arqos,
  output wire periph_axi_m_axi_arvalid,
  input  wire periph_axi_m_axi_arready,

  output wire periph_axi_m_axi_rready,
  input  wire [1:0] periph_axi_m_axi_rid,
  input  wire [63:0] periph_axi_m_axi_rdata,
  input  wire [1:0] periph_axi_m_axi_rresp,
  input  wire periph_axi_m_axi_rlast,
  input  wire periph_axi_m_axi_rvalid,

  // Periph axi in

  input wire [1:0] periph_axi_s_axi_awid,
  input wire [47:0] periph_axi_s_axi_awaddr,
  input wire [7:0] periph_axi_s_axi_awlen,
  input wire [2:0] periph_axi_s_axi_awsize,
  input wire [1:0] periph_axi_s_axi_awburst,
  input wire periph_axi_s_axi_awlock,
  input wire [3:0] periph_axi_s_axi_awcache,
  input wire [2:0] periph_axi_s_axi_awprot,
  input wire [3:0] periph_axi_s_axi_awqos,
  input wire periph_axi_s_axi_awvalid,
  output  wire periph_axi_s_axi_awready,

  input wire [63:0] periph_axi_s_axi_wdata,
  input wire [7:0] periph_axi_s_axi_wstrb,
  input wire periph_axi_s_axi_wlast,
  input wire periph_axi_s_axi_wvalid,
  output  wire periph_axi_s_axi_wready,

  input wire periph_axi_s_axi_bready,
  output  wire [1:0] periph_axi_s_axi_bid,
  output  wire [1:0] periph_axi_s_axi_bresp,
  output  wire periph_axi_s_axi_bvalid,

  input wire [1:0]periph_axi_s_axi_arid,
  input wire [47:0] periph_axi_s_axi_araddr,
  input wire [7:0] periph_axi_s_axi_arlen,
  input wire [2:0] periph_axi_s_axi_arsize,
  input wire [1:0] periph_axi_s_axi_arburst,
  input wire periph_axi_s_axi_arlock,
  input wire [3:0] periph_axi_s_axi_arcache,
  input wire [2:0] periph_axi_s_axi_arprot,
  input wire [3:0] periph_axi_s_axi_arqos,
  input wire periph_axi_s_axi_arvalid,
  output  wire periph_axi_s_axi_arready,

  input   wire periph_axi_s_axi_rready,
  output  wire [1:0] periph_axi_s_axi_rid,
  output  wire [63:0] periph_axi_s_axi_rdata,
  output  wire [1:0] periph_axi_s_axi_rresp,
  output  wire periph_axi_s_axi_rlast,
  output  wire periph_axi_s_axi_rvalid

);


  // Configure cheshire for FPGA mapping
  localparam cheshire_cfg_t FPGACfg = '{
    // CVA6 parameters
    Cva6RASDepth      : ariane_pkg::ArianeDefaultConfig.RASDepth,
    Cva6BTBEntries    : ariane_pkg::ArianeDefaultConfig.BTBEntries,
    Cva6BHTEntries    : ariane_pkg::ArianeDefaultConfig.BHTEntries,
    Cva6NrPMPEntries  : 0,
    Cva6ExtCieLength  : 'h2000_0000,
    // Harts
    NumCores          : 1,
    CoreMaxTxns       : 8,
    CoreMaxTxnsPerId  : 4,
    // Interrupts
    NumExtIntrSyncs   : 2,
    // Interconnect
    AddrWidth         : 48,
    AxiDataWidth      : 64,
    AxiUserWidth      : 2,  // Convention: bit 0 for core(s), bit 1 for serial link
    AxiMstIdWidth     : 2,
    AxiMaxMstTrans    : 8,
    AxiMaxSlvTrans    : 8,
    AxiUserAmoMsb     : 1,
    AxiUserAmoLsb     : 0,
    RegMaxReadTxns    : 8,
    RegMaxWriteTxns   : 8,
    RegAmoNumCuts     : 1,
    RegAmoPostCut     : 1,
    // RTC
    RtcFreq           : 1000000,
    // Features
    Bootrom           : 1,
    Uart              : 1,
    I2c               : 1,
    SpiHost           : 1,
    Gpio              : 1,
    Dma               : 1,
    SerialLink        : 0,
    Vga               : 1,
    // Debug
    DbgIdCode         : CheshireIdCode,
    DbgMaxReqs        : 4,
    DbgMaxReadTxns    : 4,
    DbgMaxWriteTxns   : 4,
    DbgAmoNumCuts     : 1,
    DbgAmoPostCut     : 1,
    // LLC: 128 KiB, up to 2 GiB DRAM
    LlcNotBypass      : 1,
    LlcSetAssoc       : 8,
    LlcNumLines       : 256,
    LlcNumBlocks      : 8,
    LlcMaxReadTxns    : 8,
    LlcMaxWriteTxns   : 8,
    LlcAmoNumCuts     : 1,
    LlcAmoPostCut     : 1,
    LlcOutConnect     : 1,
    LlcOutRegionStart : 'h8000_0000,
    LlcOutRegionEnd   : 'h1_0000_0000,
    // VGA: RGB332
    VgaRedWidth       : 5,
    VgaGreenWidth     : 6,
    VgaBlueWidth      : 5,
    VgaHCountWidth    : 24, // TODO: Default is 32; is this needed?
    VgaVCountWidth    : 24, // TODO: See above
    // Serial Link: map other chip's lower 32bit to 'h1_000_0000
    SlinkMaxTxnsPerId : 4,
    SlinkMaxUniqIds   : 4,
    SlinkMaxClkDiv    : 1024,
    SlinkRegionStart  : 'h1_0000_0000,
    SlinkRegionEnd    : 'h2_0000_0000,
    SlinkTxAddrMask   : 'hFFFF_FFFF,
    SlinkTxAddrDomain : 'h0000_0000,
    SlinkUserAmoBit   : 1,  // Upper atomics bit for serial link
    // DMA config
    DmaConfMaxReadTxns  : 4,
    DmaConfMaxWriteTxns : 4,
    DmaConfAmoNumCuts   : 1,
    DmaConfAmoPostCut   : 1,
    DmaConfEnableTwoD   : 1,
    DmaNumAxInFlight    : 16,
    DmaMemSysDepth      : 8,
    DmaJobFifoDepth     : 2,
    DmaRAWCouplingAvail : 1,
    // GPIOs
    GpioInputSyncs    : 1,
    // All non-set values should be zero
    default: '0
  };

  localparam cheshire_cfg_t CheshireFPGACfg = FPGACfg;
  `CHESHIRE_TYPEDEF_ALL(, CheshireFPGACfg)

  ///////////////////////////
  // Clk reset definitions //
  ///////////////////////////

  logic cpu_resetn;
  assign cpu_resetn = ~cpu_reset;
  logic sys_rst;

  wire soc_clk;
  wire rst_n;

  ///////////////////
  // GPIOs         // 
  ///////////////////

  // Give VDD and GND to JTAG
  assign jtag_vdd_o  = '1;
  assign jtag_gnd_o  = '0;

  //////////////////
  // Clock Wizard //
  //////////////////

  localparam rtc_clk_divider = 4;
  assign soc_clk = clk_50;

  /////////////////////
  // Reset Generator //
  /////////////////////

  rstgen i_rstgen_main (
    .clk_i        ( soc_clk                  ),
    .rst_ni       ( ~sys_rst                 ),
    .test_mode_i  ( testmode_i              ),
    .rst_no       ( rst_n                    ),
    .init_no      (                          ) // keep open
  );

  ///////////////////
  // VIOs          //
  ///////////////////

  logic [1:0] boot_mode;

  assign sys_rst = cpu_reset;
  assign boot_mode = boot_mode_i;

  /////////////////////////
  // "RTC" Clock Divider //
  /////////////////////////

  (* dont_touch = "yes" *) logic rtc_clk_d, rtc_clk_q;
  logic [4:0] counter_d, counter_q;

  // Divide clk_10 => 1 MHz RTC Clock
  always_comb begin
    counter_d = counter_q + 1;
    rtc_clk_d = rtc_clk_q;

    if(counter_q == rtc_clk_divider) begin
      counter_d = 5'b0;
      rtc_clk_d = ~rtc_clk_q;
    end
  end

  always_ff @(posedge clk_10, negedge rst_n) begin
    if(~rst_n) begin
      counter_q <= 5'b0;
      rtc_clk_q <= 0;
    end else begin
      counter_q <= counter_d;
      rtc_clk_q <= rtc_clk_d;
    end
  end

  ///////////////////
  // LLC interface //
  ///////////////////

  // Axi interface
  axi_llc_req_t llc_req;
  axi_llc_rsp_t llc_rsp;

  assign dram_axi_m_aclk             = soc_clk;
  assign dram_axi_m_aresetn          = rst_n;

  assign dram_axi_m_axi_awid         = llc_req.aw.id;
  assign dram_axi_m_axi_awaddr       = llc_req.aw.addr;
  assign dram_axi_m_axi_awlen        = llc_req.aw.len;
  assign dram_axi_m_axi_awsize       = llc_req.aw.size;
  assign dram_axi_m_axi_awburst      = llc_req.aw.burst;
  assign dram_axi_m_axi_awlock       = llc_req.aw.lock;
  assign dram_axi_m_axi_awcache      = llc_req.aw.cache;
  assign dram_axi_m_axi_awprot       = llc_req.aw.prot;
  assign dram_axi_m_axi_awqos        = llc_req.aw.qos;
  assign dram_axi_m_axi_awvalid      = llc_req.aw_valid;
  assign llc_rsp.aw_ready            = dram_axi_m_axi_awready;

  assign dram_axi_m_axi_wdata        = llc_req.w.data;
  assign dram_axi_m_axi_wstrb        = llc_req.w.strb;
  assign dram_axi_m_axi_wlast        = llc_req.w.last;
  assign dram_axi_m_axi_wvalid       = llc_req.w_valid;
  assign llc_rsp.w_ready             = dram_axi_m_axi_wready;

  assign dram_axi_m_axi_bready       = llc_req.b_ready;
  assign llc_rsp.b.id                = dram_axi_m_axi_bid;
  assign llc_rsp.b.resp              = dram_axi_m_axi_bresp;
  assign llc_rsp.b_valid             = dram_axi_m_axi_bvalid;

  assign dram_axi_m_axi_arid         = llc_req.ar.id;
  assign dram_axi_m_axi_araddr       = llc_req.ar.addr;
  assign dram_axi_m_axi_arlen        = llc_req.ar.len;
  assign dram_axi_m_axi_arsize       = llc_req.ar.size;
  assign dram_axi_m_axi_arburst      = llc_req.ar.burst;
  assign dram_axi_m_axi_arlock       = llc_req.ar.lock;
  assign dram_axi_m_axi_arcache      = llc_req.ar.cache;
  assign dram_axi_m_axi_arprot       = llc_req.ar.prot;
  assign dram_axi_m_axi_arqos        = llc_req.ar.qos;
  assign dram_axi_m_axi_arvalid      = llc_req.ar_valid;
  assign llc_rsp.ar_ready            = dram_axi_m_axi_arready;

  assign dram_axi_m_axi_rready       = llc_req.r_ready;
  assign llc_rsp.r.id                = dram_axi_m_axi_rid;
  assign llc_rsp.r.data              = dram_axi_m_axi_rdata;
  assign llc_rsp.r.resp              = dram_axi_m_axi_rresp;
  assign llc_rsp.r.last              = dram_axi_m_axi_rlast;
  assign llc_rsp.r_valid             = dram_axi_m_axi_rvalid;

  /////////////////////////////////
  // Serial Link to block design //
  /////////////////////////////////

  // Serial link interface
  logic [SlinkNumChan-1:0]                     slink_clk_soc_periph;
  logic [SlinkNumChan-1:0]                     slink_clk_periph_soc;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_soc_periph;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_periph_soc;

  axi_mst_req_t periph_soc_bd_req, periph_bd_soc_req;
  axi_mst_rsp_t periph_soc_bd_rsp, periph_bd_soc_rsp;

  serial_link #(
    .axi_req_t    ( axi_mst_req_t ),
    .axi_rsp_t    ( axi_mst_rsp_t ),
    .cfg_req_t    ( reg_req_t     ),
    .cfg_rsp_t    ( reg_rsp_t     ),
    .aw_chan_t    ( axi_mst_aw_chan_t ),
    .ar_chan_t    ( axi_mst_ar_chan_t ),
    .r_chan_t     ( axi_mst_r_chan_t  ),
    .w_chan_t     ( axi_mst_w_chan_t  ),
    .b_chan_t     ( axi_mst_b_chan_t  ),
    .hw2reg_t     ( serial_link_single_channel_reg_pkg::serial_link_single_channel_hw2reg_t ),
    .reg2hw_t     ( serial_link_single_channel_reg_pkg::serial_link_single_channel_reg2hw_t ),
    .NumChannels  ( SlinkNumChan   ),
    .NumLanes     ( SlinkNumLanes  ),
    .MaxClkDiv    ( SlinkMaxClkDiv )
  ) i_serial_link (
    .clk_i          ( host_clk   ),
    .rst_ni         ( rst_n      ),
    .clk_sl_i       ( host_clk   ),
    .rst_sl_ni      ( rst_n      ),
    .clk_reg_i      ( host_clk   ),
    .rst_reg_ni     ( rst_n      ),
    .testmode_i     ( testmode_i ),
    .axi_in_req_i   ( periph_bd_soc_req ),
    .axi_in_rsp_o   ( periph_bd_soc_rsp ),
    .axi_out_req_o  ( periph_soc_bd_req ),
    .axi_out_rsp_i  ( periph_soc_bd_rsp ),
    .cfg_req_i      ( '0 ),
    .cfg_rsp_o      (    ),
    .ddr_rcv_clk_i  ( slink_clk_soc_periph ),
    .ddr_rcv_clk_o  ( slink_clk_periph_soc ),
    .ddr_i          ( slink_soc_periph ),
    .ddr_o          ( slink_periph_soc ),
    .isolated_i     ( '0 ),
    .isolate_o      ( ),
    .clk_ena_o      ( ),
    .reset_no       ( )
  );

  // AXI periph soc to block design

  assign periph_axi_m_aclk           = soc_clk;
  assign periph_axi_m_aresetn        = rst_n;

  assign periph_axi_m_axi_awid         = periph_soc_bd_req.aw.id;
  assign periph_axi_m_axi_awaddr       = periph_soc_bd_req.aw.addr;
  assign periph_axi_m_axi_awlen        = periph_soc_bd_req.aw.len;
  assign periph_axi_m_axi_awsize       = periph_soc_bd_req.aw.size;
  assign periph_axi_m_axi_awburst      = periph_soc_bd_req.aw.burst;
  assign periph_axi_m_axi_awlock       = periph_soc_bd_req.aw.lock;
  assign periph_axi_m_axi_awcache      = periph_soc_bd_req.aw.cache;
  assign periph_axi_m_axi_awprot       = periph_soc_bd_req.aw.prot;
  assign periph_axi_m_axi_awqos        = periph_soc_bd_req.aw.qos;
  assign periph_axi_m_axi_awvalid      = periph_soc_bd_req.aw_valid;
  assign periph_soc_bd_rsp.aw_ready    = periph_axi_m_axi_awready;

  assign periph_axi_m_axi_wdata        = periph_soc_bd_req.w.data;
  assign periph_axi_m_axi_wstrb        = periph_soc_bd_req.w.strb;
  assign periph_axi_m_axi_wlast        = periph_soc_bd_req.w.last;
  assign periph_axi_m_axi_wvalid       = periph_soc_bd_req.w_valid;
  assign periph_soc_bd_rsp.w_ready     = periph_axi_m_axi_wready;

  assign periph_axi_m_axi_bready       = periph_soc_bd_req.b_ready;
  assign periph_soc_bd_rsp.b.id        = periph_axi_m_axi_bid;
  assign periph_soc_bd_rsp.b.resp      = periph_axi_m_axi_bresp;
  assign periph_soc_bd_rsp.b_valid     = periph_axi_m_axi_bvalid;

  assign periph_axi_m_axi_arid         = periph_soc_bd_req.ar.id;
  assign periph_axi_m_axi_araddr       = periph_soc_bd_req.ar.addr;
  assign periph_axi_m_axi_arlen        = periph_soc_bd_req.ar.len;
  assign periph_axi_m_axi_arsize       = periph_soc_bd_req.ar.size;
  assign periph_axi_m_axi_arburst      = periph_soc_bd_req.ar.burst;
  assign periph_axi_m_axi_arlock       = periph_soc_bd_req.ar.lock;
  assign periph_axi_m_axi_arcache      = periph_soc_bd_req.ar.cache;
  assign periph_axi_m_axi_arprot       = periph_soc_bd_req.ar.prot;
  assign periph_axi_m_axi_arqos        = periph_soc_bd_req.ar.qos;
  assign periph_axi_m_axi_arvalid      = periph_soc_bd_req.ar_valid;
  assign periph_soc_bd_rsp.ar_ready    = periph_axi_m_axi_arready;

  assign periph_axi_m_axi_rready       = periph_soc_bd_req.r_ready;
  assign periph_soc_bd_rsp.r.id        = periph_axi_m_axi_rid;
  assign periph_soc_bd_rsp.r.data      = periph_axi_m_axi_rdata;
  assign periph_soc_bd_rsp.r.resp      = periph_axi_m_axi_rresp;
  assign periph_soc_bd_rsp.r.last      = periph_axi_m_axi_rlast;
  assign periph_soc_bd_rsp.r_valid     = periph_axi_m_axi_rvalid;

  // AXI periph block design to soc

  // periph_axi_s_aclk     unused (assumed already synch with soc_clk)
  // periph_axi_s_aresetn  ubused (assumed already synch with reset)

  assign periph_bd_soc_req.aw.id      =  periph_axi_s_axi_awid    ;
  assign periph_bd_soc_req.aw.addr    =  periph_axi_s_axi_awaddr  ;
  assign periph_bd_soc_req.aw.len     =  periph_axi_s_axi_awlen   ;
  assign periph_bd_soc_req.aw.size    =  periph_axi_s_axi_awsize  ;

  assign periph_bd_soc_req.aw.burst   = periph_axi_s_axi_awburst  ;
  assign periph_bd_soc_req.aw.lock    = periph_axi_s_axi_awlock   ;
  assign periph_bd_soc_req.aw.cache   = periph_axi_s_axi_awcache  ;
  assign periph_bd_soc_req.aw.prot    = periph_axi_s_axi_awprot   ;
  assign periph_bd_soc_req.aw.qos     = periph_axi_s_axi_awqos    ;
  assign periph_bd_soc_req.aw_valid   = periph_axi_s_axi_awvalid  ;
  assign periph_axi_s_axi_awready     = periph_bd_soc_rsp.aw_ready;

  assign periph_bd_soc_req.w.data     = periph_axi_s_axi_wdata    ;
  assign periph_bd_soc_req.w.strb     = periph_axi_s_axi_wstrb    ;
  assign periph_bd_soc_req.w.last     = periph_axi_s_axi_wlast    ;
  assign periph_bd_soc_req.w_valid    = periph_axi_s_axi_wvalid   ;
  assign periph_axi_s_axi_wready      = periph_bd_soc_rsp.w_ready ;

  assign periph_bd_soc_req.b_ready    = periph_axi_s_axi_bready   ;
  assign periph_axi_s_axi_bid         = periph_bd_soc_rsp.b.id    ;
  assign periph_axi_s_axi_bresp       = periph_bd_soc_rsp.b.resp  ;
  assign periph_axi_s_axi_bvalid      = periph_bd_soc_rsp.b_valid ;

  assign periph_bd_soc_req.ar.id      = periph_axi_s_axi_arid      ;
  assign periph_bd_soc_req.ar.addr    = periph_axi_s_axi_araddr    ;
  assign periph_bd_soc_req.ar.len     = periph_axi_s_axi_arlen     ;
  assign periph_bd_soc_req.ar.size    = periph_axi_s_axi_arsize    ;
  assign periph_bd_soc_req.ar.burst   = periph_axi_s_axi_arburst   ;
  assign periph_bd_soc_req.ar.lock    = periph_axi_s_axi_arlock    ;
  assign periph_bd_soc_req.ar.cache   = periph_axi_s_axi_arcache   ;
  assign periph_bd_soc_req.ar.prot    = periph_axi_s_axi_arprot    ;
  assign periph_bd_soc_req.ar.qos     = periph_axi_s_axi_arqos     ;
  assign periph_bd_soc_req.ar_valid   = periph_axi_s_axi_arvalid   ;
  assign periph_axi_s_axi_arready     = periph_bd_soc_rsp.ar_ready ;

  assign periph_bd_soc_req.r_ready    = periph_axi_s_axi_rready    ;
  assign periph_axi_s_axi_rid         = periph_bd_soc_rsp.r.id     ;
  assign periph_axi_s_axi_rdata       = periph_bd_soc_rsp.r.data   ;
  assign periph_axi_s_axi_rresp       = periph_bd_soc_rsp.r.resp   ;
  assign periph_axi_s_axi_rlast       = periph_bd_soc_rsp.r.last   ;
  assign periph_axi_s_axi_rvalid      = periph_bd_soc_rsp.r_valid  ;

  //////////////////
  // SPI Adaption //
  //////////////////

  logic spi_sck_soc;
  logic [1:0] spi_cs_soc;
  logic [3:0] spi_sd_soc_out;
  logic [3:0] spi_sd_soc_in;

  logic spi_sck_en;
  logic [1:0] spi_cs_en;
  logic [3:0] spi_sd_en;

  //////////////////
  // QSPI         //
  //////////////////

  logic                 qspi_clk;
  logic                 qspi_clk_ts;
  logic [3:0]           qspi_dqi;
  logic [3:0]           qspi_dqo_ts;
  logic [3:0]           qspi_dqo;
  logic [SpihNumCs-1:0] qspi_cs_b;
  logic [SpihNumCs-1:0] qspi_cs_b_ts;

  assign qspi_clk      = spi_sck_soc;
  assign qspi_cs_b     = spi_cs_soc;
  assign qspi_dqo      = spi_sd_soc_out;
  assign spi_sd_soc_in = qspi_dqi;
  // Tristate - Enable
  assign qspi_clk_ts  = ~spi_sck_en;
  assign qspi_cs_b_ts = ~spi_cs_en;
  assign qspi_dqo_ts  = ~spi_sd_en;

  // On VCU128/ZCU102, SPI ports are not directly available
  STARTUPE3 #(
     .PROG_USR("FALSE"),
     .SIM_CCLK_FREQ(0.0)
  )
  STARTUPE3_inst (
     .CFGCLK    (),
     .CFGMCLK   (),
     .DI        (qspi_dqi),
     .EOS       (),
     .PREQ      (),
     .DO        (qspi_dqo),
     .DTS       (qspi_dqo_ts),
     .FCSBO     (qspi_cs_b[1]),
     .FCSBTS    (qspi_cs_b_ts[1]),
     .GSR       (1'b0),
     .GTS       (1'b0),
     .KEYCLEARB (1'b1),
     .PACK      (1'b0),
     .USRCCLKO  (qspi_clk),
     .USRCCLKTS (qspi_clk_ts),
     .USRDONEO  (1'b1),
     .USRDONETS (1'b1)
  );

  //////////////////
  // Cheshire SoC //
  //////////////////

  cheshire_soc #(
    .Cfg                ( FPGACfg         ),
    .ExtHartinfo        ( '0              ),
    .axi_ext_llc_req_t  ( axi_llc_req_t   ),
    .axi_ext_llc_rsp_t  ( axi_llc_rsp_t   ),
    .axi_ext_mst_req_t  ( axi_mst_req_t   ),
    .axi_ext_mst_rsp_t  ( axi_mst_rsp_t   ),
    .axi_ext_slv_req_t  ( axi_slv_req_t   ),
    .axi_ext_slv_rsp_t  ( axi_slv_rsp_t   ),
    .reg_ext_req_t      ( reg_req_t       ),
    .reg_ext_rsp_t      ( reg_req_t       )
  ) i_cheshire_soc (
    .clk_i              ( soc_clk         ),
    .rst_ni             ( rst_n           ),
    .test_mode_i        ( testmode_i      ),
    .boot_mode_i        ( boot_mode       ),
    .rtc_i              ( rtc_clk_q       ),
    .axi_llc_mst_req_o  ( llc_req         ),
    .axi_llc_mst_rsp_i  ( llc_rsp         ),
    .axi_ext_mst_req_i  ( '0              ),
    .axi_ext_mst_rsp_o  (                 ),
    .axi_ext_slv_req_o  (                 ),
    .axi_ext_slv_rsp_i  ( '0              ),
    .reg_ext_slv_req_o  (                 ),
    .reg_ext_slv_rsp_i  ( '0              ),
    .intr_ext_i         ( '0              ),
    .intr_ext_o         (                 ),
    .xeip_ext_o         (                 ),
    .mtip_ext_o         (                 ),
    .msip_ext_o         (                 ),
    .dbg_active_o       (                 ),
    .dbg_ext_req_o      (                 ),
    .dbg_ext_unavail_i  ( '0              ),
    .slink_i         ( slink_periph_soc     ),
    .slink_o         ( slink_soc_periph     ),
    .slink_rcv_clk_i     ( slink_clk_periph_soc ),
    .slink_rcv_clk_o     ( slink_clk_soc_periph ),
    .jtag_tck_i,
    .jtag_trst_ni,
    .jtag_tms_i,
    .jtag_tdi_i,
    .jtag_tdo_o,
    // TODO: connect to the tdo pad
    .jtag_tdo_oe_o      (                 ),
    .i2c_sda_o          (                 ),
    .i2c_sda_i          ( '0              ),
    .i2c_sda_en_o       (                 ),
    .i2c_scl_o          (                 ),
    .i2c_scl_i          ( '0              ),
    .i2c_scl_en_o       (                 ),
    .spih_sck_o         ( spi_sck_soc     ),
    .spih_sck_en_o      ( spi_sck_en      ),
    .spih_csb_o         ( spi_cs_soc      ),
    .spih_csb_en_o      ( spi_cs_en       ),
    .spih_sd_o          ( spi_sd_soc_out  ),
    .spih_sd_en_o       ( spi_sd_en       ),
    .spih_sd_i          ( spi_sd_soc_in   ),
    .vga_hsync_o        (                 ),
    .vga_vsync_o        (                 ),
    .vga_red_o          (                 ),
    .vga_green_o        (                 ),
    .vga_blue_o         (                 ),
    .uart_tx_o,
    .uart_rx_i
  );

endmodule
