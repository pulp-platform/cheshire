// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Max Wipfli <mwipfli@student.ethz.ch>
// Paul Scheffler <paulsc@studet.ethz.ch>

package cheshire_top_verilator_pkg;

  // Modify default config for Verilator
  function automatic cheshire_pkg::cheshire_cfg_t gen_cheshire_cfg();
    cheshire_pkg::cheshire_cfg_t ret = cheshire_pkg::DefaultCfg;
    return ret;
  endfunction

  localparam cheshire_pkg::cheshire_cfg_t Cfg = gen_cheshire_cfg();

  // Define usual Cheshire types
  `CHESHIRE_TYPEDEF_ALL(, Cfg)

endpackage


module cheshire_top_verilator
  import cheshire_pkg::*;
  import cheshire_top_verilator_pkg::*;
#(
  parameter int unsigned  ClkFreqSys      = 200000000,
  parameter int unsigned  UartBaudRate    = 115200,
  parameter int unsigned  JtagListenPort  = 44853
) (
  // SoC signals
  input  logic  clk_i,
  input  logic  rst_ni,
  input  logic  rtc_i,
  // DPI activation signals
  input  bit    uart_dpi_active,
  input  bit    jtag_dpi_active,
  // Serial link memory interface
  input  logic      slink_req_i,
  input  addr_t     slink_addr_i,
  input  logic      slink_we_i,
  input  axi_data_t slink_wdata_i,
  input  axi_strb_t slink_be_i,
  output logic      slink_gnt_o,
  output logic      slink_rsp_valid_o,
  output logic      slink_rsp_rdata_o,
  output logic      slink_rsp_error_o
);

  /////////////
  //  Reset  //
  /////////////

  // Reset can come from JTAG (srst_n) or testbench
  logic rst_n;
  logic jtag_srst_n;

  assign rst_n = rst_ni & jtag_srst_n;

  ////////////////////
  //  Cheshire SoC  //
  ////////////////////

  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

  logic jtag_tck;
  logic jtag_trst_n;
  logic jtag_tms;
  logic jtag_tdi;
  logic jtag_tdo;

  logic uart_tx;
  logic uart_rx;

  cheshire_soc #(
    .Cfg                ( Cfg ),
    .ExtHartinfo        ( '0 ),
    .axi_ext_llc_req_t  ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t  ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t  ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t  ( axi_mst_rsp_t ),
    .axi_ext_slv_req_t  ( axi_slv_req_t ),
    .axi_ext_slv_rsp_t  ( axi_slv_rsp_t ),
    .reg_ext_req_t      ( reg_req_t ),
    .reg_ext_rsp_t      ( reg_rsp_t )
  ) i_cheshire_soc (
    .clk_i,
    .rst_ni             ( rst_n ),
    .test_mode_i        ( 1'b0 ),
    .boot_mode_i        ( '0 ),
    .rtc_i,
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
    .jtag_tck_i         ( jtag_tck    ),
    .jtag_trst_ni       ( jtag_trst_n ),
    .jtag_tms_i         ( jtag_tms    ),
    .jtag_tdi_i         ( jtag_tdi    ),
    .jtag_tdo_o         ( jtag_tdo    ),
    .jtag_tdo_oe_o      ( ),
    .uart_tx_o          ( uart_tx ),
    .uart_rx_i          ( uart_rx ),
    .uart_rts_no        ( ),
    .uart_dtr_no        ( ),
    .uart_cts_ni        ( 1'b0 ),
    .uart_dsr_ni        ( 1'b0 ),
    .uart_dcd_ni        ( 1'b0 ),
    .uart_rin_ni        ( 1'b0 ),
    .i2c_sda_o          ( ),
    .i2c_sda_i          ( 1'b0 ),
    .i2c_sda_en_o       ( ),
    .i2c_scl_o          ( ),
    .i2c_scl_i          ( 1'b0 ),
    .i2c_scl_en_o       ( ),
    .spih_sck_o         ( ),
    .spih_sck_en_o      ( ),
    .spih_csb_o         ( ),
    .spih_csb_en_o      ( ),
    .spih_sd_o          ( ),
    .spih_sd_en_o       ( ),
    .spih_sd_i          ( '0 ),
    .gpio_i             ( '0 ),
    .gpio_o             ( ),
    .gpio_en_o          ( ),
    .slink_rcv_clk_i    ( slink_rcv_clk_i ),
    .slink_rcv_clk_o    ( slink_rcv_clk_o ),
    .slink_i            ( slink_i         ),
    .slink_o            ( slink_o         ),
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

  ////////////////////
  //  Slink Master  //
  ////////////////////

  // Translate memory interface to AXI
  axi_mst_req_t slink_axi_mst_req;
  axi_mst_rsp_t slink_axi_mst_rsp;

  axi_from_mem #(
    .MemAddrWidth ( Cfg.AddrWidth    ),
    .AxiAddrWidth ( Cfg.AddrWidth    ),
    .DataWidth    ( Cfg.AxiDataWidth ),
    .MaxRequests  ( 64 ),
    .AxiProt      ( '0 ),
    .axi_req_t    ( axi_mst_req_t ),
    .axi_rsp_t    ( axi_mst_rsp_t )
  ) i_axi_from_mem (
    .clk_i,
    .rst_ni          ( rst_n ),
    .mem_req_i       ( slink_req_i       ),
    .mem_addr_i      ( slink_addr_i      ),
    .mem_we_i        ( slink_we_i        ),
    .mem_wdata_i     ( slink_wdata_i     ),
    .mem_be_i        ( slink_be_i        ),
    .mem_gnt_o       ( slink_gnt_o       ),
    .mem_rsp_valid_o ( slink_rsp_valid_o ),
    .mem_rsp_rdata_o ( slink_rsp_rdata_o ),
    .mem_rsp_error_o ( slink_rsp_error_o ),
    .slv_aw_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .slv_ar_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .axi_req_o       ( slink_axi_mst_req ),
    .axi_rsp_i       ( slink_axi_mst_rsp )
  );

  // Translate AXI accesses to serial Link PHY protocol using an actual link.
  // Outgoing serial link requests are not connected here.
  logic [SlinkNumChan-1:0]                    slink_rcv_clk_i;
  logic [SlinkNumChan-1:0]                    slink_rcv_clk_o;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o;

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
    .clk_i,
    .rst_ni         ( rst_n ),
    .clk_sl_i       ( clk_i ),
    .rst_sl_ni      ( rst_n ),
    .clk_reg_i      ( clk_i ),
    .rst_reg_ni     ( rst_n ),
    .testmode_i     ( 1'b0 ),
    .axi_in_req_i   ( slink_axi_mst_req ),
    .axi_in_rsp_o   ( slink_axi_mst_rsp ),
    .axi_out_req_o  ( ),
    .axi_out_rsp_i  ( '0 ),
    .cfg_req_i      ( '0 ),
    .cfg_rsp_o      ( ),
    .ddr_rcv_clk_i  ( slink_rcv_clk_o ),
    .ddr_rcv_clk_o  ( slink_rcv_clk_i ),
    .ddr_i          ( slink_o ),
    .ddr_o          ( slink_i ),
    .isolated_i     ( '0 ),
    .isolate_o      ( ),
    .clk_ena_o      ( ),
    .reset_no       ( )
  );

  //////////////////
  //  Sim Memory  //
  //////////////////

  // Convert AXI to two mem channels.
  // We split reads and writes to avoid R-W-channel serialization.
  // ATOPs are filtered out at the LLC port, so no need to handle them.
  logic      [1:0] mem_req;
  addr_t     [1:0] mem_addr;
  axi_data_t [1:0] mem_wdata;
  axi_strb_t [1:0] mem_strb;
  logic      [1:0] mem_we;
  logic      [1:0] mem_rvalid;
  axi_data_t [1:0] mem_rdata;

  axi_to_mem_split #(
    .axi_req_t    ( axi_llc_req_t ),
    .axi_resp_t   ( axi_llc_rsp_t ),
    .AddrWidth    ( Cfg.AddrWidth    ),
    .AxiDataWidth ( Cfg.AxiDataWidth ),
    .IdWidth      ( $bits(axi_llc_id_t) ),
    .MemDataWidth ( Cfg.AxiDataWidth ),
    .BufDepth     ( 1 ),
    .HideStrb     ( 1'b0 ),
    .OutFifoDepth ( 1 )
  ) i_axi_to_mem_split (
    .clk_i,
    .rst_ni       ( rst_n ),
    .test_i       ( 1'b0 ),
    .busy_o       ( ),
    .axi_req_i    ( axi_llc_mst_req ),
    .axi_resp_o   ( axi_llc_mst_rsp ),
    .mem_req_o    ( mem_req    ),
    .mem_gnt_i    ( 2'b11      ),
    .mem_addr_o   ( mem_addr   ),
    .mem_wdata_o  ( mem_wdata  ),
    .mem_strb_o   ( mem_strb   ),
    .mem_atop_o   ( ),
    .mem_we_o     ( mem_we     ),
    .mem_rvalid_i ( mem_rvalid ),
    .mem_rdata_i  ( mem_rdata  )
  );

  // Implement the actual memory as an associative byte array.
  // We write one big ugly process as this is most efficient in Verilator.
  byte mem [addr_t];

  always_ff @(posedge clk_i or negedge rst_n) begin
    if (~rst_ni) begin
      mem_rvalid <= '0;
      mem_rdata  <= '0;
    end else begin
      // Response is always valid one cycle after request
      mem_rvalid <= mem_req;
      // Port 1 is writes
      if (mem_req[1] && mem_we[1])
        for (int i = 0; i < Cfg.AxiDataWidth/8; ++i)
          if (mem_strb[1][i])
            mem[mem_addr[1]+i] = mem_wdata[1][8*i+:8];
      // Port 0 is reads. We do not care what the default value is.
      if (mem_req[0])
        for (int i = 0; i < Cfg.AxiDataWidth/8; ++i)
          mem_rdata[0][8*i+:8] <= mem[mem_addr[0]+i];
    end
  end

  // DPI-C exports for direct memory manipulation
  export "DPI-C" function chsvlt_dmr;
  export "DPI-C" function chsvlt_dmw;

  function byte chsvlt_dmr(input longint addr);
      return mem[addr];
  endfunction

  function void chsvlt_dmw(input longint addr, input byte data);
      mem[addr] = data;
  endfunction


  ////////////
  //  JTAG  //
  ////////////

  // JTAG itself can only be reset by testbench
  jtagdpi #(
    .ListenPort ( JtagListenPort )
  ) i_jtagdpi (
    .clk_i,
    .rst_ni,
    .active       ( jtag_dpi_active ),
    .jtag_tck     ( jtag_tck    ),
    .jtag_tms     ( jtag_tms    ),
    .jtag_tdi     ( jtag_tdi    ),
    .jtag_tdo     ( jtag_tdo    ),
    .jtag_trst_n  ( jtag_trst_n ),
    .jtag_srst_n  ( jtag_srst_n )
  );

  ////////////
  //  UART  //
  ////////////

  uartdpi #(
    .BAUD  ( UartBaudRate ),
    .FREQ  ( ClkFreqSys   )
  ) i_uartdpi (
    .clk_i,
    .rst_ni ( rst_n ),
    .active ( uart_dpi_active ),
    .tx_o   ( uart_rx ),
    .rx_i   ( uart_tx )
  );

endmodule
