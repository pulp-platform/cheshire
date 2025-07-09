// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Max Wipfli <mwipfli@student.ethz.ch>

function automatic cheshire_pkg::cheshire_cfg_t gen_cheshire_cfg();
  cheshire_pkg::cheshire_cfg_t ret = cheshire_pkg::DefaultCfg;
  return ret;
endfunction

module cheshire_soc_wrapper # (
  parameter cheshire_pkg::cheshire_cfg_t DutCfg = gen_cheshire_cfg()
) (
  input logic clk_i,
  input logic rtc_i,
  input logic rst_ni,

  // JTAG
  input  logic jtag_tck_i,
  input  logic jtag_trst_ni,
  input  logic jtag_tms_i,
  input  logic jtag_tdi_i,
  output logic jtag_tdo_o,
  output logic jtag_tdo_oe_o,

  // UART
  output logic       uart_data_valid_o,
  output logic [7:0] uart_data_o,

  // Memory Interface (Serial Link)
  input  logic                             slink_mem_req_i,
  input  logic [DutCfg.AddrWidth-1:0]      slink_mem_addr_i,
  input  logic                             slink_mem_we_i,
  input  logic [DutCfg.AxiDataWidth-1:0]   slink_mem_wdata_i,
  input  logic [DutCfg.AxiDataWidth/8-1:0] slink_mem_be_i,
  output logic                             slink_mem_gnt_o,
  output logic                             slink_mem_rsp_valid_o,
  output logic [DutCfg.AxiDataWidth-1:0]   slink_mem_rsp_rdata_o
);

  import cheshire_pkg::*;

  `include "cheshire/typedef.svh"
  `CHESHIRE_TYPEDEF_ALL(, DutCfg)

  ///////////
  //  DUT  //
  ///////////

  logic       test_mode;
  logic [1:0] boot_mode;

  assign test_mode = 1'b0;
  assign boot_mode = 2'b00; // passive

  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

  logic uart_tx;
  logic uart_rx;

  logic i2c_sda_o;
  logic i2c_sda_i;
  logic i2c_sda_en;
  logic i2c_scl_o;
  logic i2c_scl_i;
  logic i2c_scl_en;
  assign i2c_sda_i = 1'b1;
  assign i2c_scl_i = 1'b1;

  logic                 spih_sck_o;
  logic                 spih_sck_en;
  logic [SpihNumCs-1:0] spih_csb_o;
  logic [SpihNumCs-1:0] spih_csb_en;
  logic [ 3:0]          spih_sd_o;
  logic [ 3:0]          spih_sd_i;
  logic [ 3:0]          spih_sd_en;
  assign spih_sd_i = 1'b0;

  logic [SlinkNumChan-1:0]                    slink_rcv_clk_i;
  logic [SlinkNumChan-1:0]                    slink_rcv_clk_o;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o;

  cheshire_soc #(
    .Cfg                ( DutCfg ),
    .ExtHartinfo        ( '0 ),
    .axi_ext_llc_req_t  ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t  ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t  ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t  ( axi_mst_rsp_t ),
    .axi_ext_slv_req_t  ( axi_slv_req_t ),
    .axi_ext_slv_rsp_t  ( axi_slv_rsp_t ),
    .reg_ext_req_t      ( reg_req_t ),
    .reg_ext_rsp_t      ( reg_rsp_t )
  ) i_dut (
    .clk_i              ( clk_i     ),
    .rst_ni             ( rst_ni    ),
    .test_mode_i        ( test_mode ),
    .boot_mode_i        ( boot_mode ),
    .rtc_i              ( rtc_i     ),
    .axi_llc_mst_req_o  ( axi_llc_mst_req ),
    .axi_llc_mst_rsp_i  ( axi_llc_mst_rsp ),
    .axi_ext_mst_req_i  ( '0 ),
    .axi_ext_mst_rsp_o  ( ),
    .axi_ext_slv_req_o  ( ),
    .axi_ext_slv_rsp_i  ( '0 ),
    .reg_ext_slv_req_o  ( ),
    .reg_ext_slv_rsp_i  ( '0 ),
    .intr_ext_i         ( '0 ),
    .intr_ext_o         ( ),
    .xeip_ext_o         ( ),
    .mtip_ext_o         ( ),
    .msip_ext_o         ( ),
    .dbg_active_o       ( ),
    .dbg_ext_req_o      ( ),
    .dbg_ext_unavail_i  ( '0 ),
    .jtag_tck_i         ( jtag_tck_i    ),
    .jtag_trst_ni       ( jtag_trst_ni  ),
    .jtag_tms_i         ( jtag_tms_i    ),
    .jtag_tdi_i         ( jtag_tdi_i    ),
    .jtag_tdo_o         ( jtag_tdo_o    ),
    .jtag_tdo_oe_o      ( jtag_tdo_oe_o ),
    .uart_tx_o          ( uart_tx ),
    .uart_rx_i          ( uart_rx ),
    .uart_rts_no        ( ),
    .uart_dtr_no        ( ),
    .uart_cts_ni        ( 1'b0 ),
    .uart_dsr_ni        ( 1'b0 ),
    .uart_dcd_ni        ( 1'b0 ),
    .uart_rin_ni        ( 1'b0 ),
    .i2c_sda_o          ( i2c_sda_o  ),
    .i2c_sda_i          ( i2c_sda_i  ),
    .i2c_sda_en_o       ( i2c_sda_en ),
    .i2c_scl_o          ( i2c_scl_o  ),
    .i2c_scl_i          ( i2c_scl_i  ),
    .i2c_scl_en_o       ( i2c_scl_en ),
    .spih_sck_o         ( spih_sck_o  ),
    .spih_sck_en_o      ( spih_sck_en ),
    .spih_csb_o         ( spih_csb_o  ),
    .spih_csb_en_o      ( spih_csb_en ),
    .spih_sd_o          ( spih_sd_o   ),
    .spih_sd_en_o       ( spih_sd_en  ),
    .spih_sd_i          ( spih_sd_i   ),
    .gpio_i             ( '0 ),
    .gpio_o             ( ),
    .gpio_en_o          ( ),
    .slink_rcv_clk_i    ( slink_rcv_clk_i ),
    .slink_rcv_clk_o    ( slink_rcv_clk_o ),
    .slink_i            ( slink_i ),
    .slink_o            ( slink_o ),
    .vga_hsync_o        ( ),
    .vga_vsync_o        ( ),
    .vga_red_o          ( ),
    .vga_green_o        ( ),
    .vga_blue_o         ( ),
    .usb_clk_i          ( 1'b0 ),
    .usb_rst_ni         ( 1'b1 ),
    .usb_dm_i           ( '0 ),
    .usb_dm_o           ( ),
    .usb_dm_oe_o        ( ),
    .usb_dp_i           ( '0 ),
    .usb_dp_o           ( ),
    .usb_dp_oe_o        ( )
  );

  ////////////
  //  DRAM  //
  ////////////

  // Emulate DRAM using an AXI-to-MEM adapter and a tc_sram

  // NOTE: This strategy ceases to work once we overflow 32-bit integers for NumDramWords, as
  // tc_sram was never designed for things like this.
  // This also assumes that the DRAM region is naturally aligned to a power of two.
  localparam int unsigned DramAddrWidth     = $clog2(DutCfg.LlcOutRegionEnd - DutCfg.LlcOutRegionStart);
  localparam int unsigned DramDataWidth     = DutCfg.AxiDataWidth;

  logic [1:0]                      dram_mem_req;
  logic [1:0][DramAddrWidth-1:0]   dram_mem_addr;
  logic [1:0][DramDataWidth-1:0]   dram_mem_wdata;
  logic [1:0][DramDataWidth/8-1:0] dram_mem_strb;
  logic [1:0]                      dram_mem_we;
  logic [1:0]                      dram_mem_rvalid;
  logic [1:0][DramDataWidth-1:0]   dram_mem_rdata;

  axi_to_mem_split #(
    .axi_req_t    ( axi_llc_req_t       ),
    .axi_resp_t   ( axi_llc_rsp_t       ),
    .AddrWidth    ( DramAddrWidth       ),
    .AxiDataWidth ( DramDataWidth       ),
    .IdWidth      ( $bits(axi_llc_id_t) ),
    .MemDataWidth ( DramDataWidth       ),
    .BufDepth     ( 1                   ),
    .HideStrb     ( 1'b1                ),
    .OutFifoDepth ( 1                   )
  ) i_dram_axi (
    .clk_i,
    .rst_ni,
    .test_i       ( 1'b0            ),
    .busy_o       (                 ),
    .axi_req_i    ( axi_llc_mst_req ),
    .axi_resp_o   ( axi_llc_mst_rsp ),
    .mem_req_o    ( dram_mem_req    ),
    .mem_gnt_i    ( 2'b11           ),
    .mem_addr_o   ( dram_mem_addr   ),
    .mem_wdata_o  ( dram_mem_wdata  ),
    .mem_strb_o   ( dram_mem_strb   ),
    .mem_atop_o   (                 ),
    .mem_we_o     ( dram_mem_we     ),
    .mem_rvalid_i ( dram_mem_rvalid ),
    .mem_rdata_i  ( dram_mem_rdata  )
  );

  localparam int unsigned DramWordAddrWidth = DramAddrWidth - $clog2(DramDataWidth / 8);
  localparam int unsigned NumDramWords      = 1 << DramWordAddrWidth;

  // Translate byte addresses (from axi_to_mem_split) to word addresses (for tc_sram)
  logic [1:0][DramWordAddrWidth-1:0] dram_mem_word_addr;
  assign dram_mem_word_addr = {
    dram_mem_addr[1][DramAddrWidth-1:DramAddrWidth-DramWordAddrWidth],
    dram_mem_addr[0][DramAddrWidth-1:DramAddrWidth-DramWordAddrWidth]
  };

  tc_sram #(
    .NumWords  ( NumDramWords  ),
    .DataWidth ( DramDataWidth ),
    .ByteWidth ( 8             ),
    .NumPorts  ( 2             ),
    .Latency   ( 1             )
  ) i_dram(
    .clk_i,
    .rst_ni,
    .req_i   ( dram_mem_req       ),
    .we_i    ( dram_mem_we        ),
    .addr_i  ( dram_mem_word_addr ),
    .wdata_i ( dram_mem_wdata     ),
    .be_i    ( dram_mem_strb      ),
    .rdata_o ( dram_mem_rdata     )
  );

  logic [1:0] dram_mem_req_q;
  `FF(dram_mem_req_q, dram_mem_req, 2'b0);
  assign dram_mem_rvalid = dram_mem_req_q;

  ////////////
  //  UART  //
  ////////////

  verilator_uart_rx #(
    .BaudPeriodCycles(1000 * 1000 * 1000 / 115200 / 5)  // 1 second / baud rate / clock period
  ) i_uart_rx (
    .clk_i,
    .rst_ni,
    .uart_rx_i    ( uart_tx           ),
    .data_valid_o ( uart_data_valid_o ),
    .data_o       ( uart_data_o       )
  );

  // no UART input into DUT
  assign uart_rx = 1'b0;

  ///////////////////
  //  Serial Link  //
  ///////////////////

  axi_mst_req_t slink_axi_mst_req;
  axi_mst_rsp_t slink_axi_mst_rsp;

  // Mirror instance of serial link, reflecting another chip
  serial_link #(
    .axi_req_t    ( axi_mst_req_t ),
    .axi_rsp_t    ( axi_mst_rsp_t ),
    .cfg_req_t    ( reg_req_t ),
    .cfg_rsp_t    ( reg_rsp_t ),
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
    .clk_i          ( clk_i  ),
    .rst_ni         ( rst_ni ),
    .clk_sl_i       ( clk_i  ),
    .rst_sl_ni      ( rst_ni ),
    .clk_reg_i      ( clk_i  ),
    .rst_reg_ni     ( rst_ni ),
    .testmode_i     ( test_mode ),
    .axi_in_req_i   ( slink_axi_mst_req ),
    .axi_in_rsp_o   ( slink_axi_mst_rsp ),
    .axi_out_req_o  (    ),
    .axi_out_rsp_i  ( '0 ),
    .cfg_req_i      ( '0 ),
    .cfg_rsp_o      (    ),
    .ddr_rcv_clk_i  ( slink_rcv_clk_o ),
    .ddr_rcv_clk_o  ( slink_rcv_clk_i ),
    .ddr_i          ( slink_o ),
    .ddr_o          ( slink_i ),
    .isolated_i     ( '0 ),
    .isolate_o      ( ),
    .clk_ena_o      ( ),
    .reset_no       ( )
  );

  // Adapter to memory interface for easier C++ handling
  axi_from_mem #(
    .MemAddrWidth ( DutCfg.AddrWidth    ),
    .AxiAddrWidth ( DutCfg.AddrWidth    ),
    .DataWidth    ( DutCfg.AxiDataWidth ),
    .MaxRequests  ( 64                  ),
    .AxiProt      ( 3'b000              ),
    .axi_req_t    ( axi_mst_req_t       ),
    .axi_rsp_t    ( axi_mst_rsp_t       )
  ) i_serial_link_mem (
    .clk_i,
    .rst_ni,
    .mem_req_i       ( slink_mem_req_i       ),
    .mem_addr_i      ( slink_mem_addr_i      ),
    .mem_we_i        ( slink_mem_we_i        ),
    .mem_wdata_i     ( slink_mem_wdata_i     ),
    .mem_be_i        ( slink_mem_be_i        ),
    .mem_gnt_o       ( slink_mem_gnt_o       ),
    .mem_rsp_valid_o ( slink_mem_rsp_valid_o ),
    .mem_rsp_rdata_o ( slink_mem_rsp_rdata_o ),
    .mem_rsp_error_o (                       ),
    .slv_aw_cache_i  ( 4'b0000               ),
    .slv_ar_cache_i  ( 4'b0000               ),
    .axi_req_o       ( slink_axi_mst_req     ),
    .axi_rsp_i       ( slink_axi_mst_rsp     )
  );

endmodule
