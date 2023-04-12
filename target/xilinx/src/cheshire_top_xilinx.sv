// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

`include "phy_definitions.svh"

module cheshire_top_xilinx 
  import cheshire_pkg::*;
(
  input logic         cpu_resetn,

  output logic        uart_tx_o,
  input logic         uart_rx_i,

`ifdef USE_SWITCHES
  input logic         testmode_i,
  input logic [1:0]   boot_mode_i,
`endif

`ifdef USE_JTAG
  (* mark_debug = "true" *) input logic         jtag_tck_i,
  (* mark_debug = "true" *) input logic         jtag_tms_i,
  (* mark_debug = "true" *) input logic         jtag_tdi_i,
  (* mark_debug = "true" *) output logic        jtag_tdo_o,
`ifdef USE_JTAG_TRSTN
  (* mark_debug = "true" *) input logic         jtag_trst_ni,
`endif
`ifdef USE_JTAG_VDDGND
  (* mark_debug = "true" *) output logic        jtag_vdd_o,
  (* mark_debug = "true" *) output logic        jtag_gnd_o,
`endif
`endif

`ifdef USE_I2C
  inout wire          i2c_scl_io,
  inout wire          i2c_sda_io,
`endif

`ifdef USE_SD
  input logic         sd_cd_i,
  output logic        U46,
  inout wire  [3:0]   sd_d_io,
  output logic        sd_reset_o,
  output logic        sd_sclk_o,
`endif

`ifdef USE_FAN
  input logic [3:0]   fan_sw,
  output logic        fan_pwm,
`endif

`ifdef USE_QSPI
  output logic        qspi_clk,
  input  logic        qspi_dq0,
  input  logic        qspi_dq1,
  input  logic        qspi_dq2,
  input  logic        qspi_dq3,
  output logic        qspi_cs_b,
`endif

`ifdef USE_VGA
  // VGA Colour signals
  output logic [4:0]  vga_b,
  output logic [5:0]  vga_g,
  output logic [4:0]  vga_r,
  // VGA Sync signals
  output logic        vga_hs,
  output logic        vga_vs,
`endif

`ifdef USE_SERIAL
  // DDR Link
  output logic [4:0]  ddr_link_o,
  output logic        ddr_link_clk_o,
`endif

  // Phy interface for DDR4
`ifdef USE_DDR4
  `DDR4_INTF
`endif

);

  wire dram_clock_out; // 333 MHz
  wire dram_addn_clk_1_out; // 200 MHz
  wire dram_sync_reset;
  wire soc_clk;

  logic rst_n;

  axi_a48_d64_mst_u0_llc_req_t soc_req, dram_req;
  axi_a48_d64_mst_u0_llc_resp_t soc_resp, dram_resp;

  // Statically assign the response user signals
  // B Channel user
  assign dram_resp.b.user      = '0;

  // R Channel user
  assign dram_resp.r.user      = '0;


  ///////////////////
  // GPIOs         // 
  ///////////////////

  // Tie off signals if no switches on the board
`ifndef USE_SWITCHES
  logic         testmode_i;
  logic [1:0]   boot_mode_i;
  assign testmode_i  = '0;
  assign boot_mode_i = '0;
`endif

  // Give VDD and GND to JTAG
`ifdef USE_JTAG_VDDGND
  assign jtag_vdd_o  = '1;
  assign jtag_gnd_o  = '0;
`endif
`ifndef USE_JTAG_TRSTN
   logic jtag_trst_ni;
   assign jtag_trst_ni = '1;
`endif

  ///////////////////
  // Clock Divider // 
  ///////////////////

  clk_int_div #(
    .DIV_VALUE_WIDTH       ( 4                ),
    .DEFAULT_DIV_VALUE     ( `DDR_CLK_DIVIDER ),
    .ENABLE_CLOCK_IN_RESET ( 1'b0             )
  ) i_sys_clk_div (
    .clk_i                 ( dram_addn_clk_1_out ),
    .rst_ni                ( ~dram_sync_reset  ),
    .en_i                  ( 1'b1              ),
    .test_mode_en_i        ( testmode_i        ),
    .div_i                 ( `DDR_CLK_DIVIDER  ),
    .div_valid_i           ( 1'b0              ),
    .div_ready_o           (                   ),
    .clk_o                 ( soc_clk           ),
    .cycl_count_o          (                   )
  );

  /////////////////////
  // Reset Generator //
  /////////////////////

  rstgen i_rstgen_main (
    .clk_i        ( soc_clk                  ),
    .rst_ni       ( ~dram_sync_reset         ),
    .test_mode_i  ( test_en                  ),
    .rst_no       ( rst_n                    ),
    .init_no      (                          ) // keep open
  );


  ///////////////////////////////////////////
  // AXI Clock Domain Crossing SoC -> DRAM //
  ///////////////////////////////////////////

  axi_a48_d64_mst_u0_llc_req_t dram_req_cdc;
  axi_a48_d64_mst_u0_llc_resp_t dram_resp_cdc;

  axi_cdc #(
    .aw_chan_t  ( axi_a48_d64_mst_u0_llc_aw_chan_t    ),
    .w_chan_t   ( axi_a48_d64_mst_u0_llc_w_chan_t     ),
    .b_chan_t   ( axi_a48_d64_mst_u0_llc_b_chan_t     ),
    .ar_chan_t  ( axi_a48_d64_mst_u0_llc_ar_chan_t    ),
    .r_chan_t   ( axi_a48_d64_mst_u0_llc_r_chan_t     ),
    .axi_req_t  ( axi_a48_d64_mst_u0_llc_req_t        ),
    .axi_resp_t ( axi_a48_d64_mst_u0_llc_resp_t       ),
    .LogDepth   ( 1                                   )
  ) i_axi_cdc_mig (
    .src_clk_i    ( soc_clk           ),
    .src_rst_ni   ( rst_n             ),
    .src_req_i    ( soc_req           ),
    .src_resp_o   ( soc_resp          ),
    .dst_clk_i    ( dram_clock_out    ),
    .dst_rst_ni   ( rst_n             ),
    .dst_req_o    ( dram_req_cdc      ),
    .dst_resp_i   ( dram_resp_cdc     )
  );

  // AXI CUT (spill register) between the AXI CDC and the MIG to
  // reduce timing pressure
  axi_cut #(
    .Bypass     ( 1'b0  ),
    .aw_chan_t  ( axi_a48_d64_mst_u0_llc_aw_chan_t  ),
    .w_chan_t   ( axi_a48_d64_mst_u0_llc_w_chan_t   ),
    .b_chan_t   ( axi_a48_d64_mst_u0_llc_b_chan_t   ),
    .ar_chan_t  ( axi_a48_d64_mst_u0_llc_ar_chan_t  ),
    .r_chan_t   ( axi_a48_d64_mst_u0_llc_r_chan_t   ),
    .axi_req_t  ( axi_a48_d64_mst_u0_llc_req_t      ),
    .axi_resp_t ( axi_a48_d64_mst_u0_llc_resp_t     )
  ) i_axi_cut_soc_dram (
    .clk_i      ( dram_clock_out  ),
    .rst_ni     ( rst_n           ),

    .slv_req_i  ( dram_req_cdc    ),
    .slv_resp_o ( dram_resp_cdc   ),

    .mst_req_o  ( dram_req        ),
    .mst_resp_i ( dram_resp       )
  );

  //////////////
  // DRAM MIG //
  //////////////

    dram_wrapper i_dram_wrapper (
    // Rst
    .sys_rst                   ( cpu_resetn             ),
    .aresetn                   ( arst_n                 ),
    // Clk rst out
    .clk_o                     ( dram_clock_out         ),
    .addn_clk_1_o              ( dram_addn_clk_1_out    ),
    .sync_rst_o                ( dram_sync_reset        ),
    // Axi
    .s_axi_awid                ( dram_req.aw.id         ),
    .s_axi_awaddr              ( dram_req.aw.addr[29:0] ),
    .s_axi_awlen               ( dram_req.aw.len        ),
    .s_axi_awsize              ( dram_req.aw.size       ),
    .s_axi_awburst             ( dram_req.aw.burst      ),
    .s_axi_awlock              ( dram_req.aw.lock       ),
    .s_axi_awcache             ( dram_req.aw.cache      ),
    .s_axi_awprot              ( dram_req.aw.prot       ),
    .s_axi_awqos               ( dram_req.aw.qos        ),
    .s_axi_awvalid             ( dram_req.aw_valid      ),
    .s_axi_awready             ( dram_resp.aw_ready     ),
    .s_axi_wdata               ( dram_req.w.data        ),
    .s_axi_wstrb               ( dram_req.w.strb        ),
    .s_axi_wlast               ( dram_req.w.last        ),
    .s_axi_wvalid              ( dram_req.w_valid       ),
    .s_axi_wready              ( dram_resp.w_ready      ),
    .s_axi_bready              ( dram_req.b_ready       ),
    .s_axi_bid                 ( dram_resp.b.id         ),
    .s_axi_bresp               ( dram_resp.b.resp       ),
    .s_axi_bvalid              ( dram_resp.b_valid      ),
    .s_axi_arid                ( dram_req.ar.id         ),
    .s_axi_araddr              ( dram_req.ar.addr[29:0] ),
    .s_axi_arlen               ( dram_req.ar.len        ),
    .s_axi_arsize              ( dram_req.ar.size       ),
    .s_axi_arburst             ( dram_req.ar.burst      ),
    .s_axi_arlock              ( dram_req.ar.lock       ),
    .s_axi_arcache             ( dram_req.ar.cache      ),
    .s_axi_arprot              ( dram_req.ar.prot       ),
    .s_axi_arqos               ( dram_req.ar.qos        ),
    .s_axi_arvalid             ( dram_req.ar_valid      ),
    .s_axi_arready             ( dram_resp.ar_ready     ),
    .s_axi_rready              ( dram_req.r_ready       ),
    .s_axi_rid                 ( dram_resp.r.id         ),
    .s_axi_rdata               ( dram_resp.r.data       ),
    .s_axi_rresp               ( dram_resp.r.resp       ),
    .s_axi_rlast               ( dram_resp.r.last       ),
    .s_axi_rvalid              ( dram_resp.r_valid      ),
    // Phy
    .*
  );

  //////////////////
  // I2C Adaption //
  //////////////////

  logic i2c_sda_soc_out;
  logic i2c_sda_soc_in;
  logic i2c_scl_soc_out;
  logic i2c_scl_soc_in;
  logic i2c_sda_en;
  logic i2c_scl_en;

`ifdef USE_I2C
  // Three state buffer for SCL
  IOBUF #(
    .DRIVE        ( 12        ),
    .IBUF_LOW_PWR ( "FALSE"   ),
    .IOSTANDARD   ( "DEFAULT" ),
    .SLEW         ( "FAST"    )
  ) i_scl_iobuf (
    .O  ( i2c_scl_soc_in      ),
    .IO ( i2c_scl_io          ),
    .I  ( i2c_scl_soc_out     ),
    .T  ( ~i2c_scl_en         )
  );

  // Three state buffer for SDA
  IOBUF #(
    .DRIVE        ( 12        ),
    .IBUF_LOW_PWR ( "FALSE"   ),
    .IOSTANDARD   ( "DEFAULT" ),
    .SLEW         ( "FAST"    )
  ) i_sda_iobuf (
    .O  ( i2c_sda_soc_in      ),
    .IO ( i2c_sda_io          ),
    .I  ( i2c_sda_soc_out     ),
    .T  ( ~i2c_sda_en         )
  );
`endif


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

`ifdef USE_SD
  // Assert reset low => Apply power to the SD Card
  assign sd_reset_o       = 1'b0;
  // SCK  - SD CLK signal
  assign sd_sclk_o        = spi_sck_en    ? spi_sck_soc       : 1'b1;
  // CS   - SD DAT3 signal
  assign sd_d_io[3]       = spi_cs_en[0]  ? spi_cs_soc[0]     : 1'b1;
  // MOSI - SD CMD signal
  assign sd_cmd_o         = spi_sd_en[0]  ? spi_sd_soc_out[0] : 1'b1;
  // MISO - SD DAT0 signal
  assign spi_sd_soc_in[1] = sd_d_io[0];
  // SD DAT1 and DAT2 signal tie-off - Not used for SPI mode
  assign sd_d_io[2:1]     = 2'b11;
  // Bind input side of SoC low for output signals
  assign spi_sd_soc_in[0] = 1'b0;
  assign spi_sd_soc_in[2] = 1'b0;
  assign spi_sd_soc_in[3] = 1'b0;
`endif

`ifdef USE_QSPI
  assign qspi_clk  = spi_sck_en    ? spi_sck_soc       : 1'b1;
  assign qspi_cs_b = spi_cs_soc[0];
  assign spi_sd_soc_in[1] = qspi_dq0;
`endif

  /////////////////////////
  // "RTC" Clock Divider //
  /////////////////////////

  logic rtc_clk_d, rtc_clk_q;
  logic [4:0] counter_d, counter_q;

  // Divide soc_clk (50 MHz) by 50 => 1 MHz RTC Clock
  always_comb begin
    counter_d = counter_q + 1;
    rtc_clk_d = rtc_clk_q;

    if(counter_q == 24) begin
      counter_d = 5'b0;
      rtc_clk_d = ~rtc_clk_q;
    end
  end

  always_ff @(posedge soc_clk, negedge rst_n) begin
    if(~rst_n) begin
      counter_q <= 5'b0;
      rtc_clk_q <= 0;
    end else begin
      counter_q <= counter_d;
      rtc_clk_q <= rtc_clk_d;
    end
  end


  /////////////////
  // Fan Control //
  /////////////////

`ifdef USE_FAN
  fan_ctrl i_fan_ctrl (
    .clk_i         ( soc_clk    ),
    .rst_ni        ( rst_n      ),
    .pwm_setting_i ( fan_sw     ),
    .fan_pwm_o     ( fan_pwm    )
  );
`endif

  ////////////////////////
  // Regbus Error Slave //
  ////////////////////////

  reg_a48_d32_req_t ext_req;
  reg_a48_d32_rsp_t ext_rsp; 
   
  reg_err_slv #(
    .DW       ( 32                 ),
    .ERR_VAL  ( 32'hBADCAB1E       ),
    .req_t    ( reg_a48_d32_req_t  ),
    .rsp_t    ( reg_a48_d32_rsp_t  )
  ) i_reg_err_slv_ext (
    .req_i ( ext_req  ),
    .rsp_o ( ext_rsp  )
  );


  //////////////////
  // Cheshire SoC //
  //////////////////

  cheshire_soc #(
    .CheshireCfg          ( CheshireCfgFPGADefault)
  ) i_cheshire_soc (
    .clk_i                ( soc_clk               ),
    .rst_ni               ( rst_n                 ),
    .testmode_i,
    .boot_mode_i,
    .boot_addr_i          ( 64'h00000000_01000000 ),
    .dram_req_o           ( soc_req               ),
    .dram_resp_i          ( soc_resp              ),
    .rtc_i                ( rtc_clk_q             ),
    .clk_locked_i         ( 1'b0                  ),
    .uart_tx_o,
    .uart_rx_i,
// Serial Link may be disabled
`ifdef USE_SERIAL
    .ddr_link_i           ( '0                    ),
    .ddr_link_o,
    .ddr_link_clk_i       ( 1'b1                  ),
    .ddr_link_clk_o,
`endif
// External JTAG may be disabled
`ifdef USE_JTAG
    .jtag_tck_i,
    .jtag_trst_ni,
    .jtag_tms_i,
    .jtag_tdi_i,
    .jtag_tdo_o,
`endif
// I2C Uses internal signals that are always defined
    .i2c_sda_o            ( i2c_sda_soc_out       ),
    .i2c_sda_i            ( i2c_sda_soc_in        ),
    .i2c_sda_en_o         ( i2c_sda_en            ),
    .i2c_scl_o            ( i2c_scl_soc_out       ),
    .i2c_scl_i            ( i2c_scl_soc_in        ),
    .i2c_scl_en_o         ( i2c_scl_en            ),
// SPI Uses internal signals that are always defined
    .spim_sck_o           ( spi_sck_soc           ),
    .spim_sck_en_o        ( spi_sck_en            ),
    .spim_csb_o           ( spi_cs_soc            ),
    .spim_csb_en_o        ( spi_cs_en             ),
    .spim_sd_o            ( spi_sd_soc_out        ),
    .spim_sd_en_o         ( spi_sd_en             ),
    .spim_sd_i            ( spi_sd_soc_in         ),
`ifdef USE_VGA
    .vga_hsync_o          ( vga_hs                ),
    .vga_vsync_o          ( vga_vs                ),
    .vga_red_o            ( vga_r                 ),
    .vga_green_o          ( vga_g                 ),
    .vga_blue_o           ( vga_b                 ),
`endif
    .external_reg_req_o   ( ext_req               ),
    .external_reg_rsp_i   ( ext_rsp               )
  );

endmodule
