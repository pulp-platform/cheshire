// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Cyril Koenig <cykoenig@iis.ee.ethz.ch>
// Just a verilog wrapper to accomodate Vivado

module cheshire_xilinx_ip
(
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESET RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESET, POLARITY ACTIVE_HIGH" *)
  input  wire         cpu_reset          ,
(* X_INTERFACE_INFO = "xilinx.com:signal:clock_rtl:1.0 clock clk_10" *) (* X_INTERFACE_PARAMETER = "FREQ_HZ 10000000" *)
  input  wire         clk_10             ,
(* X_INTERFACE_INFO = "xilinx.com:signal:clock_rtl:1.0 clock clk_20" *) (* X_INTERFACE_PARAMETER = "FREQ_HZ 20000000" *)
  input  wire         clk_20             ,
(* X_INTERFACE_INFO = "xilinx.com:signal:clock_rtl:1.0 clock clk_50" *) (* X_INTERFACE_PARAMETER = "FREQ_HZ 50000000, ASSOCIATED_BUSIF periph_axi_s" *)
  input  wire         clk_50             ,
(* X_INTERFACE_INFO = "xilinx.com:signal:clock_rtl:1.0 clock clk_100" *) (* X_INTERFACE_PARAMETER = "FREQ_HZ 100000000" *)
  input  wire         clk_100            ,

  input  wire         testmode_i         ,
  input  wire [1:0]   boot_mode_i        ,

  input  wire [31:0]  gpio_i,

  input  wire         jtag_tck_i         ,
  input  wire         jtag_tms_i         ,
  input  wire         jtag_tdi_i         ,
  output wire         jtag_tdo_o         ,
  input  wire         jtag_trst_ni       ,
  output wire         jtag_vdd_o         ,
  output wire         jtag_gnd_o         ,

  output wire         uart_tx_o          ,
  input  wire         uart_rx_i          ,

  // MASTER AXI DRAM

(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARADDR" *) (* X_INTERFACE_PARAMETER = "FREQ_HZ 50000000" *)
  output wire [47:0] dram_axi_m_axi_araddr,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARBURST" *)
  output wire [1:0] dram_axi_m_axi_arburst,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARCACHE" *)
  output wire [3:0] dram_axi_m_axi_arcache,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARID" *)
  output wire [6:0]dram_axi_m_axi_arid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARLEN" *)
  output wire [7:0] dram_axi_m_axi_arlen,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARLOCK" *)
  output wire dram_axi_m_axi_arlock,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARPROT" *)
  output wire [2:0] dram_axi_m_axi_arprot,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARQOS" *)
  output wire [3:0] dram_axi_m_axi_arqos,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARREADY" *)
  input  wire dram_axi_m_axi_arready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARSIZE" *)
  output wire [2:0] dram_axi_m_axi_arsize,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi ARVALID" *)
  output wire dram_axi_m_axi_arvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWADDR" *)
  output wire [47:0] dram_axi_m_axi_awaddr,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWBURST" *)
  output wire [1:0] dram_axi_m_axi_awburst,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWCACHE" *)
  output wire [3:0] dram_axi_m_axi_awcache,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWID" *)
  output wire [6:0] dram_axi_m_axi_awid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWLEN" *)
  output wire [7:0] dram_axi_m_axi_awlen,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWLOCK" *)
  output wire dram_axi_m_axi_awlock,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWPROT" *)
  output wire [2:0] dram_axi_m_axi_awprot,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWQOS" *)
  output wire [3:0] dram_axi_m_axi_awqos,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWREADY" *)
  input  wire dram_axi_m_axi_awready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWSIZE" *)
  output wire [2:0] dram_axi_m_axi_awsize,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi AWVALID" *)
  output wire dram_axi_m_axi_awvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi BID" *)
  input  wire [6:0] dram_axi_m_axi_bid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi BREADY" *)
  output wire dram_axi_m_axi_bready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi BRESP" *)
  input  wire [1:0] dram_axi_m_axi_bresp,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi BVALID" *)
  input  wire dram_axi_m_axi_bvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi RDATA" *)
  input  wire [63:0] dram_axi_m_axi_rdata,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi RID" *)
  input  wire [6:0] dram_axi_m_axi_rid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi RLAST" *)
  input  wire dram_axi_m_axi_rlast,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi RREADY" *)
  output wire dram_axi_m_axi_rready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi RRESP" *)
  input  wire [1:0] dram_axi_m_axi_rresp,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi RVALID" *)
  input  wire dram_axi_m_axi_rvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi WDATA" *)
  output wire [63:0] dram_axi_m_axi_wdata,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi WLAST" *)
  output wire dram_axi_m_axi_wlast,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi WREADY" *)
  input  wire dram_axi_m_axi_wready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi WSTRB" *)
  output wire [7:0] dram_axi_m_axi_wstrb,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 dram_axi WVALID" *)
  output wire dram_axi_m_axi_wvalid,
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 dram_axi CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME dram_axi, ASSOCIATED_BUSIF dram_axi, FREQ_HZ 50000000" *)
  output wire dram_axi_m_aclk,
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aux_reset RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aux_reset, POLARITY ACTIVE_LOW" *)
  output wire dram_axi_m_aresetn,

// MASTER AXI PERIPHERAL

(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARADDR" *) (* X_INTERFACE_PARAMETER = "FREQ_HZ 50000000" *)
  output wire [47:0] periph_axi_m_axi_araddr,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARBURST" *)
  output wire [1:0] periph_axi_m_axi_arburst,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARCACHE" *)
  output wire [3:0] periph_axi_m_axi_arcache,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARID" *)
  output wire [1:0]periph_axi_m_axi_arid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARLEN" *)
  output wire [7:0] periph_axi_m_axi_arlen,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARLOCK" *)
  output wire periph_axi_m_axi_arlock,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARPROT" *)
  output wire [2:0] periph_axi_m_axi_arprot,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARQOS" *)
  output wire [3:0] periph_axi_m_axi_arqos,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARREADY" *)
  input  wire periph_axi_m_axi_arready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARSIZE" *)
  output wire [2:0] periph_axi_m_axi_arsize,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m ARVALID" *)
  output wire periph_axi_m_axi_arvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWADDR" *)
  output wire [47:0] periph_axi_m_axi_awaddr,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWBURST" *)
  output wire [1:0] periph_axi_m_axi_awburst,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWCACHE" *)
  output wire [3:0] periph_axi_m_axi_awcache,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWID" *)
  output wire [1:0] periph_axi_m_axi_awid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWLEN" *)
  output wire [7:0] periph_axi_m_axi_awlen,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWLOCK" *)
  output wire periph_axi_m_axi_awlock,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWPROT" *)
  output wire [2:0] periph_axi_m_axi_awprot,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWQOS" *)
  output wire [3:0] periph_axi_m_axi_awqos,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWREADY" *)
  input  wire periph_axi_m_axi_awready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWSIZE" *)
  output wire [2:0] periph_axi_m_axi_awsize,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m AWVALID" *)
  output wire periph_axi_m_axi_awvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m BID" *)
  input  wire [1:0] periph_axi_m_axi_bid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m BREADY" *)
  output wire periph_axi_m_axi_bready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m BRESP" *)
  input  wire [1:0] periph_axi_m_axi_bresp,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m BVALID" *)
  input  wire periph_axi_m_axi_bvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m RDATA" *)
  input  wire [63:0] periph_axi_m_axi_rdata,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m RID" *)
  input  wire [1:0] periph_axi_m_axi_rid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m RLAST" *)
  input  wire periph_axi_m_axi_rlast,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m RREADY" *)
  output wire periph_axi_m_axi_rready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m RRESP" *)
  input  wire [1:0] periph_axi_m_axi_rresp,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m RVALID" *)
  input  wire periph_axi_m_axi_rvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m WDATA" *)
  output wire [63:0] periph_axi_m_axi_wdata,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m WLAST" *)
  output wire periph_axi_m_axi_wlast,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m WREADY" *)
  input  wire periph_axi_m_axi_wready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m WSTRB" *)
  output wire [7:0] periph_axi_m_axi_wstrb,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_m WVALID" *)
  output wire periph_axi_m_axi_wvalid,
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 periph_axi_m CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME periph_axi_m, ASSOCIATED_BUSIF periph_axi_m, FREQ_HZ 500000000" *)
  output wire periph_axi_m_aclk,
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 periph_axi_m RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME periph_axi_m, POLARITY ACTIVE_LOW" *)
  output wire periph_axi_m_aresetn,

// SLAVE AXI PERIPHERAL

(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARADDR" *) (* X_INTERFACE_PARAMETER = "FREQ_HZ 50000000" *)
  input wire [47:0] periph_axi_s_axi_araddr,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARBURST" *)
  input wire [1:0] periph_axi_s_axi_arburst,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARCACHE" *)
  input wire [3:0] periph_axi_s_axi_arcache,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARID" *)
  input wire [1:0]periph_axi_s_axi_arid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARLEN" *)
  input wire [7:0] periph_axi_s_axi_arlen,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARLOCK" *)
  input wire periph_axi_s_axi_arlock,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARPROT" *)
  input wire [2:0] periph_axi_s_axi_arprot,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARQOS" *)
  input wire [3:0] periph_axi_s_axi_arqos,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARREADY" *)
  output  wire periph_axi_s_axi_arready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARSIZE" *)
  input wire [2:0] periph_axi_s_axi_arsize,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s ARVALID" *)
  input wire periph_axi_s_axi_arvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWADDR" *)
  input wire [47:0] periph_axi_s_axi_awaddr,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWBURST" *)
  input wire [1:0] periph_axi_s_axi_awburst,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWCACHE" *)
  input wire [3:0] periph_axi_s_axi_awcache,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWID" *)
  input wire [1:0] periph_axi_s_axi_awid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWLEN" *)
  input wire [7:0] periph_axi_s_axi_awlen,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWLOCK" *)
  input wire periph_axi_s_axi_awlock,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWPROT" *)
  input wire [2:0] periph_axi_s_axi_awprot,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWQOS" *)
  input wire [3:0] periph_axi_s_axi_awqos,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWREADY" *)
  output  wire periph_axi_s_axi_awready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWSIZE" *)
  input wire [2:0] periph_axi_s_axi_awsize,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s AWVALID" *)
  input wire periph_axi_s_axi_awvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s BID" *)
  output  wire [1:0] periph_axi_s_axi_bid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s BREADY" *)
  input wire periph_axi_s_axi_bready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s BRESP" *)
  output  wire [1:0] periph_axi_s_axi_bresp,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s BVALID" *)
  output  wire periph_axi_s_axi_bvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s RDATA" *)
  output  wire [63:0] periph_axi_s_axi_rdata,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s RID" *)
  output  wire [1:0] periph_axi_s_axi_rid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s RLAST" *)
  output  wire periph_axi_s_axi_rlast,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s RREADY" *)
  input wire periph_axi_s_axi_rready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s RRESP" *)
  output  wire [1:0] periph_axi_s_axi_rresp,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s RVALID" *)
  output  wire periph_axi_s_axi_rvalid,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s WDATA" *)
  input wire [63:0] periph_axi_s_axi_wdata,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s WLAST" *)
  input wire periph_axi_s_axi_wlast,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s WREADY" *)
  output  wire periph_axi_s_axi_wready,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s WSTRB" *)
  input wire [7:0] periph_axi_s_axi_wstrb,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 periph_axi_s WVALID" *)
  input wire periph_axi_s_axi_wvalid

);

  cheshire_top_xilinx #(
  ) i_cheshire_top_xilinx (
    .cpu_reset(cpu_reset),
    .clk_10(clk_10),
    .clk_20(clk_20),
    .clk_50(clk_50),
    .clk_100(clk_100),

    .testmode_i        (testmode_i        ) ,
    .boot_mode_i       (boot_mode_i       ) ,

    .gpio_i      (gpio_i),

    .jtag_tck_i  (jtag_tck_i   ),
    .jtag_tms_i  (jtag_tms_i   ),
    .jtag_tdi_i  (jtag_tdi_i   ),
    .jtag_tdo_o  (jtag_tdo_o   ),
    .jtag_trst_ni(jtag_trst_ni ),
    .jtag_vdd_o  (jtag_vdd_o   ),
    .jtag_gnd_o  (jtag_gnd_o   ),

    .uart_tx_o(uart_tx_o),
    .uart_rx_i(uart_rx_i),

    .dram_axi_m_aclk   (dram_axi_m_aclk   ),
    .dram_axi_m_aresetn(dram_axi_m_aresetn),
  
    // Dram axi

    .dram_axi_m_axi_awid   (dram_axi_m_axi_awid   ),
    .dram_axi_m_axi_awaddr (dram_axi_m_axi_awaddr ),
    .dram_axi_m_axi_awlen  (dram_axi_m_axi_awlen  ),
    .dram_axi_m_axi_awsize (dram_axi_m_axi_awsize ),
    .dram_axi_m_axi_awburst(dram_axi_m_axi_awburst),
    .dram_axi_m_axi_awlock (dram_axi_m_axi_awlock ),
    .dram_axi_m_axi_awcache(dram_axi_m_axi_awcache),
    .dram_axi_m_axi_awprot (dram_axi_m_axi_awprot ),
    .dram_axi_m_axi_awqos  (dram_axi_m_axi_awqos  ),
    .dram_axi_m_axi_awvalid(dram_axi_m_axi_awvalid),
    .dram_axi_m_axi_awready(dram_axi_m_axi_awready),

    .dram_axi_m_axi_wdata (dram_axi_m_axi_wdata ),
    .dram_axi_m_axi_wstrb (dram_axi_m_axi_wstrb ),
    .dram_axi_m_axi_wlast (dram_axi_m_axi_wlast ),
    .dram_axi_m_axi_wvalid(dram_axi_m_axi_wvalid),
    .dram_axi_m_axi_wready(dram_axi_m_axi_wready),

    .dram_axi_m_axi_bready(dram_axi_m_axi_bready),
    .dram_axi_m_axi_bid   (dram_axi_m_axi_bid   ),
    .dram_axi_m_axi_bresp (dram_axi_m_axi_bresp ),
    .dram_axi_m_axi_bvalid(dram_axi_m_axi_bvalid),

    .dram_axi_m_axi_arid   (dram_axi_m_axi_arid   ),
    .dram_axi_m_axi_araddr (dram_axi_m_axi_araddr ),
    .dram_axi_m_axi_arlen  (dram_axi_m_axi_arlen  ),
    .dram_axi_m_axi_arsize (dram_axi_m_axi_arsize ),
    .dram_axi_m_axi_arburst(dram_axi_m_axi_arburst),
    .dram_axi_m_axi_arlock (dram_axi_m_axi_arlock ),
    .dram_axi_m_axi_arcache(dram_axi_m_axi_arcache),
    .dram_axi_m_axi_arprot (dram_axi_m_axi_arprot ),
    .dram_axi_m_axi_arqos  (dram_axi_m_axi_arqos  ),
    .dram_axi_m_axi_arvalid(dram_axi_m_axi_arvalid),
    .dram_axi_m_axi_arready(dram_axi_m_axi_arready),

    .dram_axi_m_axi_rready(dram_axi_m_axi_rready),
    .dram_axi_m_axi_rid   (dram_axi_m_axi_rid   ),
    .dram_axi_m_axi_rdata (dram_axi_m_axi_rdata ),
    .dram_axi_m_axi_rresp (dram_axi_m_axi_rresp ),
    .dram_axi_m_axi_rlast (dram_axi_m_axi_rlast ),
    .dram_axi_m_axi_rvalid(dram_axi_m_axi_rvalid),

    // Peripheral axi

    .periph_axi_m_aclk   (periph_axi_m_aclk   ),
    .periph_axi_m_aresetn(periph_axi_m_aresetn),

    .periph_axi_m_axi_awid   (periph_axi_m_axi_awid   ),
    .periph_axi_m_axi_awaddr (periph_axi_m_axi_awaddr ),
    .periph_axi_m_axi_awlen  (periph_axi_m_axi_awlen  ),
    .periph_axi_m_axi_awsize (periph_axi_m_axi_awsize ),
    .periph_axi_m_axi_awburst(periph_axi_m_axi_awburst),
    .periph_axi_m_axi_awlock (periph_axi_m_axi_awlock ),
    .periph_axi_m_axi_awcache(periph_axi_m_axi_awcache),
    .periph_axi_m_axi_awprot (periph_axi_m_axi_awprot ),
    .periph_axi_m_axi_awqos  (periph_axi_m_axi_awqos  ),
    .periph_axi_m_axi_awvalid(periph_axi_m_axi_awvalid),
    .periph_axi_m_axi_awready(periph_axi_m_axi_awready),

    .periph_axi_m_axi_wdata (periph_axi_m_axi_wdata ),
    .periph_axi_m_axi_wstrb (periph_axi_m_axi_wstrb ),
    .periph_axi_m_axi_wlast (periph_axi_m_axi_wlast ),
    .periph_axi_m_axi_wvalid(periph_axi_m_axi_wvalid),
    .periph_axi_m_axi_wready(periph_axi_m_axi_wready),

    .periph_axi_m_axi_bready(periph_axi_m_axi_bready),
    .periph_axi_m_axi_bid   (periph_axi_m_axi_bid   ),
    .periph_axi_m_axi_bresp (periph_axi_m_axi_bresp ),
    .periph_axi_m_axi_bvalid(periph_axi_m_axi_bvalid),

    .periph_axi_m_axi_arid   (periph_axi_m_axi_arid   ),
    .periph_axi_m_axi_araddr (periph_axi_m_axi_araddr ),
    .periph_axi_m_axi_arlen  (periph_axi_m_axi_arlen  ),
    .periph_axi_m_axi_arsize (periph_axi_m_axi_arsize ),
    .periph_axi_m_axi_arburst(periph_axi_m_axi_arburst),
    .periph_axi_m_axi_arlock (periph_axi_m_axi_arlock ),
    .periph_axi_m_axi_arcache(periph_axi_m_axi_arcache),
    .periph_axi_m_axi_arprot (periph_axi_m_axi_arprot ),
    .periph_axi_m_axi_arqos  (periph_axi_m_axi_arqos  ),
    .periph_axi_m_axi_arvalid(periph_axi_m_axi_arvalid),
    .periph_axi_m_axi_arready(periph_axi_m_axi_arready),

    .periph_axi_m_axi_rready(periph_axi_m_axi_rready),
    .periph_axi_m_axi_rid   (periph_axi_m_axi_rid   ),
    .periph_axi_m_axi_rdata (periph_axi_m_axi_rdata ),
    .periph_axi_m_axi_rresp (periph_axi_m_axi_rresp ),
    .periph_axi_m_axi_rlast (periph_axi_m_axi_rlast ),
    .periph_axi_m_axi_rvalid(periph_axi_m_axi_rvalid),

    // Peripheral axi

    .periph_axi_s_axi_awid   (periph_axi_s_axi_awid   ),
    .periph_axi_s_axi_awaddr (periph_axi_s_axi_awaddr ),
    .periph_axi_s_axi_awlen  (periph_axi_s_axi_awlen  ),
    .periph_axi_s_axi_awsize (periph_axi_s_axi_awsize ),
    .periph_axi_s_axi_awburst(periph_axi_s_axi_awburst),
    .periph_axi_s_axi_awlock (periph_axi_s_axi_awlock ),
    .periph_axi_s_axi_awcache(periph_axi_s_axi_awcache),
    .periph_axi_s_axi_awprot (periph_axi_s_axi_awprot ),
    .periph_axi_s_axi_awqos  (periph_axi_s_axi_awqos  ),
    .periph_axi_s_axi_awvalid(periph_axi_s_axi_awvalid),
    .periph_axi_s_axi_awready(periph_axi_s_axi_awready),

    .periph_axi_s_axi_wdata (periph_axi_s_axi_wdata ),
    .periph_axi_s_axi_wstrb (periph_axi_s_axi_wstrb ),
    .periph_axi_s_axi_wlast (periph_axi_s_axi_wlast ),
    .periph_axi_s_axi_wvalid(periph_axi_s_axi_wvalid),
    .periph_axi_s_axi_wready(periph_axi_s_axi_wready),

    .periph_axi_s_axi_bready(periph_axi_s_axi_bready),
    .periph_axi_s_axi_bid   (periph_axi_s_axi_bid   ),
    .periph_axi_s_axi_bresp (periph_axi_s_axi_bresp ),
    .periph_axi_s_axi_bvalid(periph_axi_s_axi_bvalid),

    .periph_axi_s_axi_arid   (periph_axi_s_axi_arid   ),
    .periph_axi_s_axi_araddr (periph_axi_s_axi_araddr ),
    .periph_axi_s_axi_arlen  (periph_axi_s_axi_arlen  ),
    .periph_axi_s_axi_arsize (periph_axi_s_axi_arsize ),
    .periph_axi_s_axi_arburst(periph_axi_s_axi_arburst),
    .periph_axi_s_axi_arlock (periph_axi_s_axi_arlock ),
    .periph_axi_s_axi_arcache(periph_axi_s_axi_arcache),
    .periph_axi_s_axi_arprot (periph_axi_s_axi_arprot ),
    .periph_axi_s_axi_arqos  (periph_axi_s_axi_arqos  ),
    .periph_axi_s_axi_arvalid(periph_axi_s_axi_arvalid),
    .periph_axi_s_axi_arready(periph_axi_s_axi_arready),

    .periph_axi_s_axi_rready(periph_axi_s_axi_rready),
    .periph_axi_s_axi_rid   (periph_axi_s_axi_rid   ),
    .periph_axi_s_axi_rdata (periph_axi_s_axi_rdata ),
    .periph_axi_s_axi_rresp (periph_axi_s_axi_rresp ),
    .periph_axi_s_axi_rlast (periph_axi_s_axi_rlast ),
    .periph_axi_s_axi_rvalid(periph_axi_s_axi_rvalid)
  );

endmodule
