// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nils Wistoff <nwistoff@iis.ee.ethz.ch>

module soc910_vcu128 import soc910_pkg::*; (
  input  logic         sys_clk_p   ,
  input  logic         sys_clk_n   ,
  input  logic         cpu_resetn  ,
  // common part
  // input logic      trst_n      ,
  output logic        vdd          ,
  output logic        gnd          ,
  input  logic        tck          ,
  input  logic        tms          ,
  input  logic        tdi          ,
  output wire         tdo          ,
  input  logic        rx           ,
  output logic        tx
);
assign vdd = 1'b1;
assign gnd = 1'b0;

logic clk;
logic eth_clk;
logic spi_clk_i;
logic dram_clk;
logic sd_clk_sys;

logic ddr_sync_reset;
logic ddr_clock_out;

logic rst_n, rst;
logic ndmreset;
logic ndmreset_n;
// virtual reset
logic vrst_n;
logic rtc;

// we need to switch reset polarity
logic cpu_reset;
assign cpu_reset  = ~cpu_resetn;

logic pll_locked;

axi_slave_req_t  axi_soc910_cc_req;
axi_slave_resp_t axi_soc910_cc_resp;

axi_master_req_t  axi_soc910_debug_req;
axi_master_resp_t axi_soc910_debug_resp;

// ---------------
// SoC910
// ---------------
logic soc910_rst_n;
assign soc910_rst_n = ndmreset_n & vrst_n;

soc910 i_soc910 (
  .clk_i           ( clk                ),
  .rst_ni          ( soc910_rst_n       ),
  .axi_dram_req_o  ( axi_soc910_cc_req  ),
  .axi_dram_resp_i ( axi_soc910_cc_resp ),
  .axi_debug_req_i  ( axi_soc910_debug_req  ),
  .axi_debug_resp_o ( axi_soc910_debug_resp ),
  .tck             ( tck                ),
  .tms             ( tms                ),
  .tdi             ( tdi                ),
  .tdo             ( tdo                ),
  .tdo_en          ( tdo_en             ),
  .rx              ( rx                 ),
  .tx              ( tx                 )
);

// ---------------
// CLK & RST Gen
// ---------------
rstgen i_rstgen_main (
    .clk_i        ( clk        ),
    .rst_ni       ( pll_locked ),
    .test_mode_i  ( test_en    ),
    .rst_no       ( ndmreset_n ),
    .init_no      (            ) // keep open
);

xlnx_clk_gen i_xlnx_clk_gen (
  .clk_out1  ( clk           ), // 50 MHz
  .clk_out2  ( dram_clk      ), // 250 MHz
  .reset     ( cpu_reset     ),
  .locked    ( pll_locked    ),
  .clk_in1_p ( sys_clk_p     ),
  .clk_in1_n ( sys_clk_n     )
);

assign rst_n = ~ddr_sync_reset;
assign rst   = ddr_sync_reset;

logic pc_status;

xlnx_vio i_vrst_gen (
  .clk(clk),                // input wire clk
  .probe_out0(vrst_n)  // output wire [0 : 0] probe_out0
);

// ---------------
// Debug AXI Master
// ---------------
xlnx_jtag_axi i_dbg_axi_master (
  .aclk(clk),                    // input wire aclk
  .aresetn(ndmreset_n),              // input wire aresetn
  .m_axi_awid(axi_soc910_debug_req.aw.id),        // output wire [3 : 0] m_axi_awid
  .m_axi_awaddr(axi_soc910_debug_req.aw.addr),    // output wire [63 : 0] m_axi_awaddr
  .m_axi_awlen(axi_soc910_debug_req.aw.len),      // output wire [7 : 0] m_axi_awlen
  .m_axi_awsize(axi_soc910_debug_req.aw.size),    // output wire [2 : 0] m_axi_awsize
  .m_axi_awburst(axi_soc910_debug_req.aw.burst),  // output wire [1 : 0] m_axi_awburst
  .m_axi_awlock(axi_soc910_debug_req.aw.lock),    // output wire m_axi_awlock
  .m_axi_awcache(axi_soc910_debug_req.aw.cache),  // output wire [3 : 0] m_axi_awcache
  .m_axi_awprot(axi_soc910_debug_req.aw.prot),    // output wire [2 : 0] m_axi_awprot
  .m_axi_awqos(axi_soc910_debug_req.aw.qos),      // output wire [3 : 0] m_axi_awqos
  .m_axi_awvalid(axi_soc910_debug_req.aw_valid),  // output wire m_axi_awvalid
  .m_axi_awready(axi_soc910_debug_resp.aw_ready),  // input wire m_axi_awready
  .m_axi_wdata(axi_soc910_debug_req.w.data),      // output wire [63 : 0] m_axi_wdata
  .m_axi_wstrb(axi_soc910_debug_req.w.strb),      // output wire [7 : 0] m_axi_wstrb
  .m_axi_wlast(axi_soc910_debug_req.w.last),      // output wire m_axi_wlast
  .m_axi_wvalid(axi_soc910_debug_req.w_valid),    // output wire m_axi_wvalid
  .m_axi_wready(axi_soc910_debug_resp.w_ready),    // input wire m_axi_wready
  .m_axi_bid(axi_soc910_debug_resp.b.id),          // input wire [3 : 0] m_axi_bid
  .m_axi_bresp(axi_soc910_debug_resp.b.resp),      // input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid(axi_soc910_debug_resp.b_valid),    // input wire m_axi_bvalid
  .m_axi_bready(axi_soc910_debug_req.b_ready),    // output wire m_axi_bready
  .m_axi_arid(axi_soc910_debug_req.ar.id),        // output wire [3 : 0] m_axi_arid
  .m_axi_araddr(axi_soc910_debug_req.ar.addr),    // output wire [63 : 0] m_axi_araddr
  .m_axi_arlen(axi_soc910_debug_req.ar.len),      // output wire [7 : 0] m_axi_arlen
  .m_axi_arsize(axi_soc910_debug_req.ar.size),    // output wire [2 : 0] m_axi_arsize
  .m_axi_arburst(axi_soc910_debug_req.ar.burst),  // output wire [1 : 0] m_axi_arburst
  .m_axi_arlock(axi_soc910_debug_req.ar.lock),    // output wire m_axi_arlock
  .m_axi_arcache(axi_soc910_debug_req.ar.cache),  // output wire [3 : 0] m_axi_arcache
  .m_axi_arprot(axi_soc910_debug_req.ar.prot),    // output wire [2 : 0] m_axi_arprot
  .m_axi_arqos(axi_soc910_debug_req.ar.qos),      // output wire [3 : 0] m_axi_arqos
  .m_axi_arvalid(axi_soc910_debug_req.ar_valid),  // output wire m_axi_arvalid
  .m_axi_arready(axi_soc910_debug_resp.ar_ready),  // input wire m_axi_arready
  .m_axi_rid(axi_soc910_debug_resp.r.id),          // input wire [3 : 0] m_axi_rid
  .m_axi_rdata(axi_soc910_debug_resp.r.data),      // input wire [63 : 0] m_axi_rdata
  .m_axi_rresp(axi_soc910_debug_resp.r.resp),      // input wire [1 : 0] m_axi_rresp
  .m_axi_rlast(axi_soc910_debug_resp.r.last),      // input wire m_axi_rlast
  .m_axi_rvalid(axi_soc910_debug_resp.r_valid),    // input wire m_axi_rvalid
  .m_axi_rready(axi_soc910_debug_req.r_ready)    // output wire m_axi_rready
);


// ---------------
// DDR
// ---------------
logic [AxiIdWidthSlaves-1:0] axi_dram_clk_awid;
logic [AxiAddrWidth-1:0]     axi_dram_clk_awaddr;
logic [7:0]                  axi_dram_clk_awlen;
logic [2:0]                  axi_dram_clk_awsize;
logic [1:0]                  axi_dram_clk_awburst;
logic [0:0]                  axi_dram_clk_awlock;
logic [3:0]                  axi_dram_clk_awcache;
logic [2:0]                  axi_dram_clk_awprot;
logic [3:0]                  axi_dram_clk_awregion;
logic [3:0]                  axi_dram_clk_awqos;
logic                        axi_dram_clk_awvalid;
logic                        axi_dram_clk_awready;
logic [AxiDataWidth-1:0]     axi_dram_clk_wdata;
logic [AxiDataWidth/8-1:0]   axi_dram_clk_wstrb;
logic                        axi_dram_clk_wlast;
logic                        axi_dram_clk_wvalid;
logic                        axi_dram_clk_wready;
logic [AxiIdWidthSlaves-1:0] axi_dram_clk_bid;
logic [1:0]                  axi_dram_clk_bresp;
logic                        axi_dram_clk_bvalid;
logic                        axi_dram_clk_bready;
logic [AxiIdWidthSlaves-1:0] axi_dram_clk_arid;
logic [AxiAddrWidth-1:0]     axi_dram_clk_araddr;
logic [7:0]                  axi_dram_clk_arlen;
logic [2:0]                  axi_dram_clk_arsize;
logic [1:0]                  axi_dram_clk_arburst;
logic [0:0]                  axi_dram_clk_arlock;
logic [3:0]                  axi_dram_clk_arcache;
logic [2:0]                  axi_dram_clk_arprot;
logic [3:0]                  axi_dram_clk_arregion;
logic [3:0]                  axi_dram_clk_arqos;
logic                        axi_dram_clk_arvalid;
logic                        axi_dram_clk_arready;
logic [AxiIdWidthSlaves-1:0] axi_dram_clk_rid;
logic [AxiDataWidth-1:0]     axi_dram_clk_rdata;
logic [1:0]                  axi_dram_clk_rresp;
logic                        axi_dram_clk_rlast;
logic                        axi_dram_clk_rvalid;
logic                        axi_dram_clk_rready;

xlnx_protocol_checker i_xlnx_protocol_checker (
  .pc_status       (                   ),
  .pc_asserted     ( pc_status         ),
  .aclk            ( clk               ),
  .aresetn         ( ndmreset_n        ),
  .pc_axi_awid     ( axi_soc910_cc_req.aw.id     ),
  .pc_axi_awaddr   ( axi_soc910_cc_req.aw.addr   ),
  .pc_axi_awlen    ( axi_soc910_cc_req.aw.len    ),
  .pc_axi_awsize   ( axi_soc910_cc_req.aw.size   ),
  .pc_axi_awburst  ( axi_soc910_cc_req.aw.burst  ),
  .pc_axi_awlock   ( axi_soc910_cc_req.aw.lock   ),
  .pc_axi_awcache  ( axi_soc910_cc_req.aw.cache  ),
  .pc_axi_awprot   ( axi_soc910_cc_req.aw.prot   ),
  .pc_axi_awqos    ( axi_soc910_cc_req.aw.qos    ),
  .pc_axi_awregion ( axi_soc910_cc_req.aw.region ),
  .pc_axi_awuser   ( axi_soc910_cc_req.aw.user   ),
  .pc_axi_awvalid  ( axi_soc910_cc_req.aw_valid  ),
  .pc_axi_awready  ( axi_soc910_cc_resp.aw_ready  ),
  .pc_axi_wlast    ( axi_soc910_cc_req.w.last    ),
  .pc_axi_wdata    ( axi_soc910_cc_req.w.data    ),
  .pc_axi_wstrb    ( axi_soc910_cc_req.w.strb    ),
  .pc_axi_wuser    ( axi_soc910_cc_req.w.user    ),
  .pc_axi_wvalid   ( axi_soc910_cc_req.w_valid   ),
  .pc_axi_wready   ( axi_soc910_cc_resp.w_ready   ),
  .pc_axi_bid      ( axi_soc910_cc_resp.b.id      ),
  .pc_axi_bresp    ( axi_soc910_cc_resp.b.resp    ),
  .pc_axi_buser    ( axi_soc910_cc_resp.b.user    ),
  .pc_axi_bvalid   ( axi_soc910_cc_resp.b_valid   ),
  .pc_axi_bready   ( axi_soc910_cc_req.b_ready   ),
  .pc_axi_arid     ( axi_soc910_cc_req.ar.id     ),
  .pc_axi_araddr   ( axi_soc910_cc_req.ar.addr   ),
  .pc_axi_arlen    ( axi_soc910_cc_req.ar.len    ),
  .pc_axi_arsize   ( axi_soc910_cc_req.ar.size   ),
  .pc_axi_arburst  ( axi_soc910_cc_req.ar.burst  ),
  .pc_axi_arlock   ( axi_soc910_cc_req.ar.lock   ),
  .pc_axi_arcache  ( axi_soc910_cc_req.ar.cache  ),
  .pc_axi_arprot   ( axi_soc910_cc_req.ar.prot   ),
  .pc_axi_arqos    ( axi_soc910_cc_req.ar.qos    ),
  .pc_axi_arregion ( axi_soc910_cc_req.ar.region ),
  .pc_axi_aruser   ( axi_soc910_cc_req.ar.user   ),
  .pc_axi_arvalid  ( axi_soc910_cc_req.ar_valid  ),
  .pc_axi_arready  ( axi_soc910_cc_resp.ar_ready  ),
  .pc_axi_rid      ( axi_soc910_cc_resp.r.id      ),
  .pc_axi_rlast    ( axi_soc910_cc_resp.r.last    ),
  .pc_axi_rdata    ( axi_soc910_cc_resp.r.data    ),
  .pc_axi_rresp    ( axi_soc910_cc_resp.r.resp    ),
  .pc_axi_ruser    ( axi_soc910_cc_resp.r.user    ),
  .pc_axi_rvalid   ( axi_soc910_cc_resp.r_valid   ),
  .pc_axi_rready   ( axi_soc910_cc_req.r_ready   )
);

assign axi_soc910_cc_resp.r.user = '0;
assign axi_soc910_cc_resp.b.user = '0;

xlnx_axi_clock_converter i_xlnx_axi_clock_converter_ddr (
  .s_axi_aclk     ( clk               ),
  .s_axi_aresetn  ( ndmreset_n        ),
  .s_axi_awid     ( axi_soc910_cc_req.aw.id     ),
  .s_axi_awaddr   ( axi_soc910_cc_req.aw.addr   ),
  .s_axi_awlen    ( axi_soc910_cc_req.aw.len    ),
  .s_axi_awsize   ( axi_soc910_cc_req.aw.size   ),
  .s_axi_awburst  ( axi_soc910_cc_req.aw.burst  ),
  .s_axi_awlock   ( axi_soc910_cc_req.aw.lock   ),
  .s_axi_awcache  ( axi_soc910_cc_req.aw.cache  ),
  .s_axi_awprot   ( axi_soc910_cc_req.aw.prot   ),
  .s_axi_awregion ( axi_soc910_cc_req.aw.region ),
  .s_axi_awqos    ( axi_soc910_cc_req.aw.qos    ),
  .s_axi_awvalid  ( axi_soc910_cc_req.aw_valid  ),
  .s_axi_awready  ( axi_soc910_cc_resp.aw_ready  ),
  .s_axi_wdata    ( axi_soc910_cc_req.w.data    ),
  .s_axi_wstrb    ( axi_soc910_cc_req.w.strb    ),
  .s_axi_wlast    ( axi_soc910_cc_req.w.last    ),
  .s_axi_wvalid   ( axi_soc910_cc_req.w_valid   ),
  .s_axi_wready   ( axi_soc910_cc_resp.w_ready   ),
  .s_axi_bid      ( axi_soc910_cc_resp.b.id      ),
  .s_axi_bresp    ( axi_soc910_cc_resp.b.resp    ),
  .s_axi_bvalid   ( axi_soc910_cc_resp.b_valid   ),
  .s_axi_bready   ( axi_soc910_cc_req.b_ready   ),
  .s_axi_arid     ( axi_soc910_cc_req.ar.id     ),
  .s_axi_araddr   ( axi_soc910_cc_req.ar.addr   ),
  .s_axi_arlen    ( axi_soc910_cc_req.ar.len    ),
  .s_axi_arsize   ( axi_soc910_cc_req.ar.size   ),
  .s_axi_arburst  ( axi_soc910_cc_req.ar.burst  ),
  .s_axi_arlock   ( axi_soc910_cc_req.ar.lock   ),
  .s_axi_arcache  ( axi_soc910_cc_req.ar.cache  ),
  .s_axi_arprot   ( axi_soc910_cc_req.ar.prot   ),
  .s_axi_arregion ( axi_soc910_cc_req.ar.region ),
  .s_axi_arqos    ( axi_soc910_cc_req.ar.qos    ),
  .s_axi_arvalid  ( axi_soc910_cc_req.ar_valid  ),
  .s_axi_arready  ( axi_soc910_cc_resp.ar_ready  ),
  .s_axi_rid      ( axi_soc910_cc_resp.r.id      ),
  .s_axi_rdata    ( axi_soc910_cc_resp.r.data    ),
  .s_axi_rresp    ( axi_soc910_cc_resp.r.resp    ),
  .s_axi_rlast    ( axi_soc910_cc_resp.r.last    ),
  .s_axi_rvalid   ( axi_soc910_cc_resp.r_valid   ),
  .s_axi_rready   ( axi_soc910_cc_req.r_ready   ),
  // to size converter
  .m_axi_aclk     ( dram_clk              ),
  .m_axi_aresetn  ( ndmreset_n            ),
  .m_axi_awid     ( axi_dram_clk_awid     ),
  .m_axi_awaddr   ( axi_dram_clk_awaddr   ),
  .m_axi_awlen    ( axi_dram_clk_awlen    ),
  .m_axi_awsize   ( axi_dram_clk_awsize   ),
  .m_axi_awburst  ( axi_dram_clk_awburst  ),
  .m_axi_awlock   ( axi_dram_clk_awlock   ),
  .m_axi_awcache  ( axi_dram_clk_awcache  ),
  .m_axi_awprot   ( axi_dram_clk_awprot   ),
  .m_axi_awregion ( axi_dram_clk_awregion ),
  .m_axi_awqos    ( axi_dram_clk_awqos    ),
  .m_axi_awvalid  ( axi_dram_clk_awvalid  ),
  .m_axi_awready  ( axi_dram_clk_awready  ),
  .m_axi_wdata    ( axi_dram_clk_wdata    ),
  .m_axi_wstrb    ( axi_dram_clk_wstrb    ),
  .m_axi_wlast    ( axi_dram_clk_wlast    ),
  .m_axi_wvalid   ( axi_dram_clk_wvalid   ),
  .m_axi_wready   ( axi_dram_clk_wready   ),
  .m_axi_bid      ( axi_dram_clk_bid      ),
  .m_axi_bresp    ( axi_dram_clk_bresp    ),
  .m_axi_bvalid   ( axi_dram_clk_bvalid   ),
  .m_axi_bready   ( axi_dram_clk_bready   ),
  .m_axi_arid     ( axi_dram_clk_arid     ),
  .m_axi_araddr   ( axi_dram_clk_araddr   ),
  .m_axi_arlen    ( axi_dram_clk_arlen    ),
  .m_axi_arsize   ( axi_dram_clk_arsize   ),
  .m_axi_arburst  ( axi_dram_clk_arburst  ),
  .m_axi_arlock   ( axi_dram_clk_arlock   ),
  .m_axi_arcache  ( axi_dram_clk_arcache  ),
  .m_axi_arprot   ( axi_dram_clk_arprot   ),
  .m_axi_arregion ( axi_dram_clk_arregion ),
  .m_axi_arqos    ( axi_dram_clk_arqos    ),
  .m_axi_arvalid  ( axi_dram_clk_arvalid  ),
  .m_axi_arready  ( axi_dram_clk_arready  ),
  .m_axi_rid      ( axi_dram_clk_rid      ),
  .m_axi_rdata    ( axi_dram_clk_rdata    ),
  .m_axi_rresp    ( axi_dram_clk_rresp    ),
  .m_axi_rlast    ( axi_dram_clk_rlast    ),
  .m_axi_rvalid   ( axi_dram_clk_rvalid   ),
  .m_axi_rready   ( axi_dram_clk_rready   )
);

localparam AxiDramDataWidth = 256;

logic [AxiAddrWidth-1:0]         axi_dram_size_awaddr;
logic [7:0]                      axi_dram_size_awlen;
logic [2:0]                      axi_dram_size_awsize;
logic [1:0]                      axi_dram_size_awburst;
logic [0:0]                      axi_dram_size_awlock;
logic [3:0]                      axi_dram_size_awcache;
logic [2:0]                      axi_dram_size_awprot;
logic [3:0]                      axi_dram_size_awregion;
logic [3:0]                      axi_dram_size_awqos;
logic                            axi_dram_size_awvalid;
logic                            axi_dram_size_awready;
logic [AxiDramDataWidth-1:0]     axi_dram_size_wdata;
logic [AxiDramDataWidth/8-1:0]   axi_dram_size_wstrb;
logic                            axi_dram_size_wlast;
logic                            axi_dram_size_wvalid;
logic                            axi_dram_size_wready;
logic [1:0]                      axi_dram_size_bresp;
logic                            axi_dram_size_bvalid;
logic                            axi_dram_size_bready;
logic [AxiAddrWidth-1:0]         axi_dram_size_araddr;
logic [7:0]                      axi_dram_size_arlen;
logic [2:0]                      axi_dram_size_arsize;
logic [1:0]                      axi_dram_size_arburst;
logic [0:0]                      axi_dram_size_arlock;
logic [3:0]                      axi_dram_size_arcache;
logic [2:0]                      axi_dram_size_arprot;
logic [3:0]                      axi_dram_size_arregion;
logic [3:0]                      axi_dram_size_arqos;
logic                            axi_dram_size_arvalid;
logic                            axi_dram_size_arready;
logic [AxiDramDataWidth-1:0]     axi_dram_size_rdata;
logic [1:0]                      axi_dram_size_rresp;
logic                            axi_dram_size_rlast;
logic                            axi_dram_size_rvalid;
logic                            axi_dram_size_rready;

xlnx_axi_dwidth_converter i_xlnx_axi_dwidth_converter (
  .s_axi_aclk     ( dram_clk               ),          // input wire s_axi_aclk
  .s_axi_aresetn  ( ndmreset_n             ),    // input wire s_axi_aresetn
  .s_axi_awid     ( axi_dram_clk_awid      ),          // input wire [8 : 0] s_axi_awid
  .s_axi_awaddr   ( axi_dram_clk_awaddr    ),      // input wire [39 : 0] s_axi_awaddr
  .s_axi_awlen    ( axi_dram_clk_awlen     ),        // input wire [7 : 0] s_axi_awlen
  .s_axi_awsize   ( axi_dram_clk_awsize    ),      // input wire [2 : 0] s_axi_awsize
  .s_axi_awburst  ( axi_dram_clk_awburst   ),    // input wire [1 : 0] s_axi_awburst
  .s_axi_awlock   ( axi_dram_clk_awlock    ),      // input wire [0 : 0] s_axi_awlock
  .s_axi_awcache  ( axi_dram_clk_awcache   ),    // input wire [3 : 0] s_axi_awcache
  .s_axi_awprot   ( axi_dram_clk_awprot    ),      // input wire [2 : 0] s_axi_awprot
  .s_axi_awregion ( axi_dram_clk_awregion  ),  // input wire [3 : 0] s_axi_awregion
  .s_axi_awqos    ( axi_dram_clk_awqos     ),        // input wire [3 : 0] s_axi_awqos
  .s_axi_awvalid  ( axi_dram_clk_awvalid   ),    // input wire s_axi_awvalid
  .s_axi_awready  ( axi_dram_clk_awready   ),    // output wire s_axi_awready
  .s_axi_wdata    ( axi_dram_clk_wdata     ),        // input wire [127 : 0] s_axi_wdata
  .s_axi_wstrb    ( axi_dram_clk_wstrb     ),        // input wire [15 : 0] s_axi_wstrb
  .s_axi_wlast    ( axi_dram_clk_wlast     ),        // input wire s_axi_wlast
  .s_axi_wvalid   ( axi_dram_clk_wvalid    ),      // input wire s_axi_wvalid
  .s_axi_wready   ( axi_dram_clk_wready    ),      // output wire s_axi_wready
  .s_axi_bid      ( axi_dram_clk_bid       ),            // output wire [8 : 0] s_axi_bid
  .s_axi_bresp    ( axi_dram_clk_bresp     ),        // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid   ( axi_dram_clk_bvalid    ),      // output wire s_axi_bvalid
  .s_axi_bready   ( axi_dram_clk_bready    ),      // input wire s_axi_bready
  .s_axi_arid     ( axi_dram_clk_arid      ),          // input wire [8 : 0] s_axi_arid
  .s_axi_araddr   ( axi_dram_clk_araddr    ),      // input wire [39 : 0] s_axi_araddr
  .s_axi_arlen    ( axi_dram_clk_arlen     ),        // input wire [7 : 0] s_axi_arlen
  .s_axi_arsize   ( axi_dram_clk_arsize    ),      // input wire [2 : 0] s_axi_arsize
  .s_axi_arburst  ( axi_dram_clk_arburst   ),    // input wire [1 : 0] s_axi_arburst
  .s_axi_arlock   ( axi_dram_clk_arlock    ),      // input wire [0 : 0] s_axi_arlock
  .s_axi_arcache  ( axi_dram_clk_arcache   ),    // input wire [3 : 0] s_axi_arcache
  .s_axi_arprot   ( axi_dram_clk_arprot    ),      // input wire [2 : 0] s_axi_arprot
  .s_axi_arregion ( axi_dram_clk_arregion  ),  // input wire [3 : 0] s_axi_arregion
  .s_axi_arqos    ( axi_dram_clk_arqos     ),        // input wire [3 : 0] s_axi_arqos
  .s_axi_arvalid  ( axi_dram_clk_arvalid   ),    // input wire s_axi_arvalid
  .s_axi_arready  ( axi_dram_clk_arready   ),    // output wire s_axi_arready
  .s_axi_rid      ( axi_dram_clk_rid       ),            // output wire [8 : 0] s_axi_rid
  .s_axi_rdata    ( axi_dram_clk_rdata     ),        // output wire [127 : 0] s_axi_rdata
  .s_axi_rresp    ( axi_dram_clk_rresp     ),        // output wire [1 : 0] s_axi_rresp
  .s_axi_rlast    ( axi_dram_clk_rlast     ),        // output wire s_axi_rlast
  .s_axi_rvalid   ( axi_dram_clk_rvalid    ),      // output wire s_axi_rvalid
  .s_axi_rready   ( axi_dram_clk_rready    ),      // input wire s_axi_rready
  .m_axi_awaddr   ( axi_dram_size_awaddr   ),      // output wire [39 : 0] m_axi_awaddr
  .m_axi_awlen    ( axi_dram_size_awlen    ),        // output wire [7 : 0] m_axi_awlen
  .m_axi_awsize   ( axi_dram_size_awsize   ),      // output wire [2 : 0] m_axi_awsize
  .m_axi_awburst  ( axi_dram_size_awburst  ),    // output wire [1 : 0] m_axi_awburst
  .m_axi_awlock   ( axi_dram_size_awlock   ),      // output wire [0 : 0] m_axi_awlock
  .m_axi_awcache  ( axi_dram_size_awcache  ),    // output wire [3 : 0] m_axi_awcache
  .m_axi_awprot   ( axi_dram_size_awprot   ),      // output wire [2 : 0] m_axi_awprot
  .m_axi_awregion ( axi_dram_size_awregion ),  // output wire [3 : 0] m_axi_awregion
  .m_axi_awqos    ( axi_dram_size_awqos    ),        // output wire [3 : 0] m_axi_awqos
  .m_axi_awvalid  ( axi_dram_size_awvalid  ),    // output wire m_axi_awvalid
  .m_axi_awready  ( axi_dram_size_awready  ),    // input wire m_axi_awready
  .m_axi_wdata    ( axi_dram_size_wdata    ),        // output wire [255 : 0] m_axi_wdata
  .m_axi_wstrb    ( axi_dram_size_wstrb    ),        // output wire [31 : 0] m_axi_wstrb
  .m_axi_wlast    ( axi_dram_size_wlast    ),        // output wire m_axi_wlast
  .m_axi_wvalid   ( axi_dram_size_wvalid   ),      // output wire m_axi_wvalid
  .m_axi_wready   ( axi_dram_size_wready   ),      // input wire m_axi_wready
  .m_axi_bresp    ( axi_dram_size_bresp    ),        // input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid   ( axi_dram_size_bvalid   ),      // input wire m_axi_bvalid
  .m_axi_bready   ( axi_dram_size_bready   ),      // output wire m_axi_bready
  .m_axi_araddr   ( axi_dram_size_araddr   ),      // output wire [39 : 0] m_axi_araddr
  .m_axi_arlen    ( axi_dram_size_arlen    ),        // output wire [7 : 0] m_axi_arlen
  .m_axi_arsize   ( axi_dram_size_arsize   ),      // output wire [2 : 0] m_axi_arsize
  .m_axi_arburst  ( axi_dram_size_arburst  ),    // output wire [1 : 0] m_axi_arburst
  .m_axi_arlock   ( axi_dram_size_arlock   ),      // output wire [0 : 0] m_axi_arlock
  .m_axi_arcache  ( axi_dram_size_arcache  ),    // output wire [3 : 0] m_axi_arcache
  .m_axi_arprot   ( axi_dram_size_arprot   ),      // output wire [2 : 0] m_axi_arprot
  .m_axi_arregion ( axi_dram_size_arregion ),  // output wire [3 : 0] m_axi_arregion
  .m_axi_arqos    ( axi_dram_size_arqos    ),        // output wire [3 : 0] m_axi_arqos
  .m_axi_arvalid  ( axi_dram_size_arvalid  ),    // output wire m_axi_arvalid
  .m_axi_arready  ( axi_dram_size_arready  ),    // input wire m_axi_arready
  .m_axi_rdata    ( axi_dram_size_rdata    ),        // input wire [255 : 0] m_axi_rdata
  .m_axi_rresp    ( axi_dram_size_rresp    ),        // input wire [1 : 0] m_axi_rresp
  .m_axi_rlast    ( axi_dram_size_rlast    ),        // input wire m_axi_rlast
  .m_axi_rvalid   ( axi_dram_size_rvalid   ),      // input wire m_axi_rvalid
  .m_axi_rready   ( axi_dram_size_rready   )      // output wire m_axi_rready
);


xlnx_hbm i_xlnx_hbm (
  .HBM_REF_CLK_0   (dram_clk),              // input wire HBM_REF_CLK_0
  .AXI_00_ACLK     (dram_clk),                  // input wire AXI_00_ACLK
  .AXI_00_ARESET_N (ndmreset_n),          // input wire AXI_00_ARESET_N
  .AXI_00_ARADDR   (axi_dram_size_araddr),              // input wire [32 : 0] AXI_00_ARADDR
  .AXI_00_ARBURST  (axi_dram_size_arburst),            // input wire [1 : 0] AXI_00_ARBURST
  .AXI_00_ARID     ('0),                  // input wire [5 : 0] AXI_00_ARID
  .AXI_00_ARLEN    (axi_dram_size_arlen),                // input wire [3 : 0] AXI_00_ARLEN
  .AXI_00_ARSIZE   (axi_dram_size_arsize),              // input wire [2 : 0] AXI_00_ARSIZE
  .AXI_00_ARVALID  (axi_dram_size_arvalid),            // input wire AXI_00_ARVALID
  .AXI_00_AWADDR   (axi_dram_size_awaddr),              // input wire [32 : 0] AXI_00_AWADDR
  .AXI_00_AWBURST  (axi_dram_size_awburst),            // input wire [1 : 0] AXI_00_AWBURST
  .AXI_00_AWID     ('0),                  // input wire [5 : 0] AXI_00_AWID
  .AXI_00_AWLEN(axi_dram_size_awlen),                // input wire [3 : 0] AXI_00_AWLEN
  .AXI_00_AWSIZE(axi_dram_size_awsize),              // input wire [2 : 0] AXI_00_AWSIZE
  .AXI_00_AWVALID(axi_dram_size_awvalid),            // input wire AXI_00_AWVALID
  .AXI_00_RREADY(axi_dram_size_rready),              // input wire AXI_00_RREADY
  .AXI_00_BREADY(axi_dram_size_bready),              // input wire AXI_00_BREADY
  .AXI_00_WDATA(axi_dram_size_wdata),                // input wire [255 : 0] AXI_00_WDATA
  .AXI_00_WLAST(axi_dram_size_wlast),                // input wire AXI_00_WLAST
  .AXI_00_WSTRB(axi_dram_size_wstrb),                // input wire [31 : 0] AXI_00_WSTRB
  .AXI_00_WDATA_PARITY('0),  // input wire [31 : 0] AXI_00_WDATA_PARITY
  .AXI_00_WVALID(axi_dram_size_wvalid),              // input wire AXI_00_WVALID
  .APB_0_PCLK( '0 ),                    // input wire APB_0_PCLK
  .APB_0_PRESET_N( '1 ),            // input wire APB_0_PRESET_N
  .AXI_00_ARREADY(axi_dram_size_arready),            // output wire AXI_00_ARREADY
  .AXI_00_AWREADY(axi_dram_size_awready),            // output wire AXI_00_AWREADY
  .AXI_00_RDATA_PARITY( ),  // output wire [31 : 0] AXI_00_RDATA_PARITY
  .AXI_00_RDATA(axi_dram_size_rdata),                // output wire [255 : 0] AXI_00_RDATA
  .AXI_00_RID( ),                    // output wire [5 : 0] AXI_00_RID
  .AXI_00_RLAST(axi_dram_size_rlast),                // output wire AXI_00_RLAST
  .AXI_00_RRESP(axi_dram_size_rresp),                // output wire [1 : 0] AXI_00_RRESP
  .AXI_00_RVALID(axi_dram_size_rvalid),              // output wire AXI_00_RVALID
  .AXI_00_WREADY(axi_dram_size_wready),              // output wire AXI_00_WREADY
  .AXI_00_BID( ),                    // output wire [5 : 0] AXI_00_BID
  .AXI_00_BRESP(axi_dram_size_bresp),                // output wire [1 : 0] AXI_00_BRESP
  .AXI_00_BVALID(axi_dram_size_bvalid),              // output wire AXI_00_BVALID
  .apb_complete_0 ( /* open */ ),            // output wire apb_complete_0
  .DRAM_0_STAT_CATTRIP( ),  // output wire DRAM_0_STAT_CATTRIP
  .DRAM_0_STAT_TEMP( )        // output wire [6 : 0] DRAM_0_STAT_TEMP
);

endmodule
