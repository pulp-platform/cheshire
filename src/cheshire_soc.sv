// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>


`include "axi/assign.svh"
`include "common_cells/registers.svh"

module cheshire_soc import cheshire_pkg::*; #(
  parameter cheshire_cfg_t CheshireCfg = CheshireCfgDefault
) (
  input   logic                       clk_i,
  input   logic                       rst_ni,

  input   logic                       testmode_i,

  // Boot mode selection
  input   logic [1:0]                 boot_mode_i,

  // Boot address for CVA6
  input   logic [63:0]                boot_addr_i,

  // DRAM AXI interface
  output  axi_a48_d64_slv_u0_req_t    dram_req_o,
  input   axi_a48_d64_slv_u0_resp_t   dram_resp_i,

  // DRAM Regbus interface
  output  reg_a48_d32_req_t           dram_conf_req_o,
  input   reg_a48_d32_rsp_t           dram_conf_rsp_i,

  // DDR-Link
  input   logic [3:0]                 ddr_link_i,
  output  logic [3:0]                 ddr_link_o,

  input   logic                       ddr_link_clk_i,
  output  logic                       ddr_link_clk_o,

  // VGA Controller
  output  logic                       vga_hsync_o,
  output  logic                       vga_vsync_o,
  output  logic [CheshireCfg.VGARedWidth-1:0]    vga_red_o,
  output  logic [CheshireCfg.VGAGreenWidth-1:0]  vga_green_o,
  output  logic [CheshireCfg.VGABlueWidth-1:0]   vga_blue_o,

  // JTAG Interface
  input   logic                       jtag_tck_i,
  input   logic                       jtag_trst_ni,
  input   logic                       jtag_tms_i,
  input   logic                       jtag_tdi_i,
  output  logic                       jtag_tdo_o,

  // UART Interface
  output logic                        uart_tx_o,
  input  logic                        uart_rx_i,

  // I2C Interface
  output logic                        i2c_sda_o,
  input  logic                        i2c_sda_i,
  output logic                        i2c_sda_en_o,
  output logic                        i2c_scl_o,
  input  logic                        i2c_scl_i,
  output logic                        i2c_scl_en_o,

  // SPI Host Interface
  output logic                        spim_sck_o,
  output logic                        spim_sck_en_o,
  output logic [ 1:0]                 spim_csb_o,
  output logic [ 1:0]                 spim_csb_en_o,
  output logic [ 3:0]                 spim_sd_o,
  output logic [ 3:0]                 spim_sd_en_o,
  input  logic [ 3:0]                 spim_sd_i,

  // CLINT
  input  logic                        rtc_i,

  // FLL
  output reg_a48_d32_req_t            fll_reg_req_o,
  input  reg_a48_d32_rsp_t            fll_reg_rsp_i,
  input  logic                        fll_lock_i,

  // PAD CTRL
  output  reg_a48_d32_req_t           pad_config_req_o,
  input   reg_a48_d32_rsp_t           pad_config_rsp_i

);

  // X-Bar 
  axi_a48_d64_slv_u0_req_t [AXI_XBAR_NUM_OUTPUTS-1:0] axi_xbar_mst_port_reqs;
  axi_a48_d64_slv_u0_resp_t [AXI_XBAR_NUM_OUTPUTS-1:0] axi_xbar_mst_port_rsps;

  axi_a48_d64_mst_u0_req_t [AXI_XBAR_NUM_INPUTS-1:0] axi_xbar_slv_port_reqs;
  axi_a48_d64_mst_u0_resp_t [AXI_XBAR_NUM_INPUTS-1:0] axi_xbar_slv_port_rsps;


  // Regbus Peripherals 
  reg_a48_d32_req_t  regbus_periph_in_req;
  reg_a48_d32_rsp_t  regbus_periph_in_rsp;

  reg_a48_d32_req_t [REGBUS_PERIPH_NUM_OUTPUTS-1:0] regbus_periph_out_req;
  reg_a48_d32_rsp_t [REGBUS_PERIPH_NUM_OUTPUTS-1:0] regbus_periph_out_rsp;


  // Machine/Supervisor timer and machine/supervisor software interrupt pending.
  logic [1:0] mstip, mssip;

  // External interrupt pending (Machine/Supervisor context)
  logic [1:0] eip;

  cheshire_interrupt_t irq;

  logic debug_req;
  
  ////////////
  //  CVA6  //
  ////////////

  cva6 #(
    .ArianeCfg    ( CheshireArianeConfig                     )
  ) i_cva6 (
    .clk_i,
    .rst_ni,
    .boot_addr_i,
    .hart_id_i    ( 64'h0                                    ),
    .irq_i        ( eip                                      ),
    .ipi_i        ( mssip[0]                                 ),
    .time_irq_i   ( mstip[0]                                 ),
    .debug_req_i  ( debug_req                                ),
    .cvxif_req_o  (                                          ),
    .cvxif_resp_i ( '0                                       ),
    .axi_req_o    ( axi_xbar_slv_port_reqs[AXI_XBAR_IN_CVA6] ),
    .axi_resp_i   ( axi_xbar_slv_port_rsps[AXI_XBAR_IN_CVA6] )
  );

  /////////////////
  //  AXI X-Bar  //
  /////////////////

  axi_xbar #(
    .Cfg            ( axi_xbar_cfg                  ),
    .ATOPs          ( 1'b1                          ),
    .Connectivity   ( AXI_XBAR_CONNECTIVITY         ),
    .slv_aw_chan_t  ( axi_a48_d64_mst_u0_aw_chan_t  ),
    .mst_aw_chan_t  ( axi_a48_d64_slv_u0_aw_chan_t  ),
    .w_chan_t       ( axi_a48_d64_mst_u0_w_chan_t   ),
    .slv_b_chan_t   ( axi_a48_d64_mst_u0_b_chan_t   ),
    .mst_b_chan_t   ( axi_a48_d64_slv_u0_b_chan_t   ),
    .slv_ar_chan_t  ( axi_a48_d64_mst_u0_ar_chan_t  ),
    .mst_ar_chan_t  ( axi_a48_d64_slv_u0_ar_chan_t  ),
    .slv_r_chan_t   ( axi_a48_d64_mst_u0_r_chan_t   ),
    .mst_r_chan_t   ( axi_a48_d64_slv_u0_r_chan_t   ),
    .slv_req_t      ( axi_a48_d64_mst_u0_req_t      ),
    .slv_resp_t     ( axi_a48_d64_mst_u0_resp_t     ),
    .mst_req_t      ( axi_a48_d64_slv_u0_req_t      ),
    .mst_resp_t     ( axi_a48_d64_slv_u0_resp_t     ),
    .rule_t         ( address_rule_48_t             )
  ) i_axi_xbar (
    .clk_i,
    .rst_ni,
    .test_i                 ( testmode_i                 ),
    .slv_ports_req_i        ( axi_xbar_slv_port_reqs     ),
    .slv_ports_resp_o       ( axi_xbar_slv_port_rsps     ),
    .mst_ports_req_o        ( axi_xbar_mst_port_reqs     ),
    .mst_ports_resp_i       ( axi_xbar_mst_port_rsps     ),
    .addr_map_i             ( axi_xbar_addrmap           ),
    .en_default_mst_port_i  ( '0                         ),
    .default_mst_port_i     ( '0                         )
  );


  /////////////
  //  Debug  //
  /////////////

  logic dmi_rst_n;
  dm::dmi_req_t dmi_req;
  logic dmi_req_ready;
  logic dmi_req_valid;
  dm::dmi_resp_t dmi_resp;
  logic dmi_resp_ready;
  logic dmi_resp_valid;

  logic           dbg_req;
  logic   [47:0]  dbg_addr;
  logic           dbg_we;
  logic   [63:0]  dbg_wdata;
  logic   [ 7:0]  dbg_wstrb;
  logic   [63:0]  dbg_rdata;
  logic           dbg_rvalid;
    
  
  logic           sba_req;
  logic   [47:0]  sba_addr;
  logic   [63:0]  sba_addr_long;
  logic           sba_we;
  logic   [63:0]  sba_wdata;
  logic   [ 7:0]  sba_strb;
  logic           sba_gnt;
  logic   [63:0]  sba_rdata;
  logic           sba_rvalid;
  logic           sba_err;

  // Ignore the upper 16 bits
  assign sba_addr = sba_addr_long[47:0];

  // AXI4+ATOP -> Memory Inteface
  axi_to_mem_interleaved #(
    .axi_req_t       ( axi_a48_d64_slv_u0_req_t  ),
    .axi_resp_t      ( axi_a48_d64_slv_u0_resp_t ),
    .AddrWidth       ( 48                        ),
    .DataWidth       ( 64                        ),
    .IdWidth         ( AXI_XBAR_SLAVE_ID_WIDTH   ),
    .NumBanks        ( 1                         ),
    .BufDepth        ( 3                         )
  ) i_axi_to_mem_dbg (
    .clk_i,
    .rst_ni,
    .busy_o          (                           ),
    .axi_req_i       ( axi_xbar_mst_port_reqs[AXI_XBAR_OUT_DEBUG] ),
    .axi_resp_o      ( axi_xbar_mst_port_rsps[AXI_XBAR_OUT_DEBUG] ),
    .mem_req_o       ( dbg_req                   ),
    .mem_gnt_i       ( dbg_req                   ),
    .mem_addr_o      ( dbg_addr                  ),
    .mem_wdata_o     ( dbg_wdata                 ),
    .mem_strb_o      ( dbg_wstrb                 ),
    .mem_atop_o      (                           ),
    .mem_we_o        ( dbg_we                    ),
    .mem_rvalid_i    ( dbg_rvalid                ),
    .mem_rdata_i     ( dbg_rdata                 )
  );

  //dbg_rvalid = #1 dbg_req
  `FF(dbg_rvalid, dbg_req, 1'b0, clk_i, rst_ni)

  dm::hartinfo_t [0:0] hartinfo;
  assign hartinfo[0] = ariane_pkg::DebugHartInfo;

  // Debug Module
  dm_top #(
    .NrHarts              ( 1                 ),
    .BusWidth             ( 64                ),
    .DmBaseAddress        ( 'h0               )
  ) i_dm_top (
    .clk_i,
    .rst_ni,
    .testmode_i,
    .ndmreset_o           (                   ),
    .dmactive_o           (                   ),
    .debug_req_o          ( debug_req         ),
    .unavailable_i        ( '0                ),
    .hartinfo_i           ( hartinfo          ),
    .slave_req_i          ( dbg_req           ),
    .slave_we_i           ( dbg_we            ),
    .slave_addr_i         ( {16'b0, dbg_addr} ),
    .slave_be_i           ( dbg_wstrb         ),
    .slave_wdata_i        ( dbg_wdata         ),
    .slave_rdata_o        ( dbg_rdata         ),
    .master_req_o         ( sba_req           ),
    .master_add_o         ( sba_addr_long     ),
    .master_we_o          ( sba_we            ),
    .master_wdata_o       ( sba_wdata         ),
    .master_be_o          ( sba_strb          ),
    .master_gnt_i         ( sba_gnt           ),
    .master_r_valid_i     ( sba_rvalid        ),
    .master_r_rdata_i     ( sba_rdata         ),
    .master_r_err_i       ( sba_err           ),
    .master_r_other_err_i ( 1'b0              ),
    .dmi_rst_ni           ( dmi_rst_n         ),
    .dmi_req_valid_i      ( dmi_req_valid     ),
    .dmi_req_ready_o      ( dmi_req_ready     ),
    .dmi_req_i            ( dmi_req           ),
    .dmi_resp_valid_o     ( dmi_resp_valid    ),
    .dmi_resp_ready_i     ( dmi_resp_ready    ),
    .dmi_resp_o           ( dmi_resp          )
  );

  axi_lite_a48_d64_req_t dbg_axi_lite_to_axi_req;
  axi_lite_a48_d64_resp_t dbg_axi_lite_to_axi_rsp;

  // From DM --> AXI Lite
  mem_to_axi_lite #(
    .MemAddrWidth    ( 48                      ),
    .AxiAddrWidth    ( AXI_ADDR_WIDTH          ),
    .DataWidth       ( 64                      ),
    .MaxRequests     ( 2                       ),
    .AxiProt         ( '0                      ),
    .axi_req_t       ( axi_lite_a48_d64_req_t  ),
    .axi_rsp_t       ( axi_lite_a48_d64_resp_t )
  ) i_mem_to_axi_lite_dbg (
    .clk_i,
    .rst_ni,
    .mem_req_i       ( sba_req                 ),
    .mem_addr_i      ( sba_addr                ),
    .mem_we_i        ( sba_we                  ),
    .mem_wdata_i     ( sba_wdata               ),
    .mem_be_i        ( sba_strb                ),
    .mem_gnt_o       ( sba_gnt                 ),
    .mem_rsp_valid_o ( sba_rvalid              ),
    .mem_rsp_rdata_o ( sba_rdata               ),
    .mem_rsp_error_o ( sba_err                 ),
    .axi_req_o       ( dbg_axi_lite_to_axi_req ),
    .axi_rsp_i       ( dbg_axi_lite_to_axi_rsp )
  );

  // AXI Lite --> AXI crossbar
  axi_lite_to_axi #(
    .AxiDataWidth    ( AXI_DATA_WIDTH            ),
    .req_lite_t      ( axi_lite_a48_d64_req_t    ),
    .resp_lite_t     ( axi_lite_a48_d64_resp_t   ),
    .axi_req_t       ( axi_a48_d64_mst_u0_req_t  ),
    .axi_resp_t      ( axi_a48_d64_mst_u0_resp_t )
  ) i_axi_lite_to_axi_dbg (
    .slv_req_lite_i  ( dbg_axi_lite_to_axi_req   ),
    .slv_resp_lite_o ( dbg_axi_lite_to_axi_rsp   ),
    .slv_aw_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .slv_ar_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .mst_req_o       ( axi_xbar_slv_port_reqs[AXI_XBAR_IN_DEBUG] ),
    .mst_resp_i      ( axi_xbar_slv_port_rsps[AXI_XBAR_IN_DEBUG] )
  );

  // Debug Transfer Module + Debug Module Interface
  dmi_jtag #(
    .IdcodeValue      ( cheshire_pkg::IDCode )
  ) i_dmi_jtag (
    .clk_i,
    .rst_ni,
    .testmode_i,
    .dmi_rst_no       ( dmi_rst_n            ),
    .dmi_req_o        ( dmi_req              ),
    .dmi_req_ready_i  ( dmi_req_ready        ),
    .dmi_req_valid_o  ( dmi_req_valid        ),
    .dmi_resp_i       ( dmi_resp             ),
    .dmi_resp_ready_o ( dmi_resp_ready       ),
    .dmi_resp_valid_i ( dmi_resp_valid       ),
    .tck_i            ( jtag_tck_i           ),
    .tms_i            ( jtag_tms_i           ),
    .trst_ni          ( jtag_trst_ni         ),
    .td_i             ( jtag_tdi_i           ),
    .td_o             ( jtag_tdo_o           ),
    .tdo_oe_o         (                      )
  );

  ///////////////////
  //  Serial Link  //
  ///////////////////

  generate
    if(CheshireCfg.DDR_LINK) begin

      // TODO: maybe axi multicut needed?
  
      axi_a48_d64_mst_u0_req_t ddr_link_axi_in_req;
      axi_a48_d64_mst_u0_resp_t ddr_link_axi_in_rsp;

      // Remap wider ID to smaller ID
      axi_id_remap #(
        .AxiSlvPortIdWidth      ( AXI_XBAR_SLAVE_ID_WIDTH       ),
        .AxiSlvPortMaxUniqIds   ( 2**AXI_XBAR_MASTER_ID_WIDTH   ),   // TODO
        .AxiMaxTxnsPerId        ( 1                             ),   // TODO?
        .AxiMstPortIdWidth      ( AXI_XBAR_MASTER_ID_WIDTH      ),
        .slv_req_t              ( axi_a48_d64_slv_u0_req_t      ),
        .slv_resp_t             ( axi_a48_d64_slv_u0_resp_t     ),
        .mst_req_t              ( axi_a48_d64_mst_u0_req_t      ),
        .mst_resp_t             ( axi_a48_d64_mst_u0_resp_t     )
      ) i_axi_id_remap_ddr_link (
        .clk_i,
        .rst_ni,
        .slv_req_i              ( axi_xbar_mst_port_reqs[AXI_XBAR_OUT_DDR_LINK] ),
        .slv_resp_o             ( axi_xbar_mst_port_rsps[AXI_XBAR_OUT_DDR_LINK]  ),
        .mst_req_o              ( ddr_link_axi_in_req           ),
        .mst_resp_i             ( ddr_link_axi_in_rsp           )
      );

      serial_link #(
        .axi_req_t      ( axi_a48_d64_mst_u0_req_t     ),
        .axi_rsp_t      ( axi_a48_d64_mst_u0_resp_t    ),
        .cfg_req_t      ( reg_a48_d32_req_t            ),
        .cfg_rsp_t      ( reg_a48_d32_rsp_t            ),
        .aw_chan_t      ( axi_a48_d64_mst_u0_aw_chan_t ),
        .ar_chan_t      ( axi_a48_d64_mst_u0_ar_chan_t ),
        .r_chan_t       ( axi_a48_d64_mst_u0_r_chan_t  ),
        .w_chan_t       ( axi_a48_d64_mst_u0_w_chan_t  ),
        .b_chan_t       ( axi_a48_d64_mst_u0_b_chan_t  ),
        .hw2reg_t       ( serial_link_single_channel_reg_pkg::serial_link_single_channel_hw2reg_t ),
        .reg2hw_t       ( serial_link_single_channel_reg_pkg::serial_link_single_channel_reg2hw_t ),
        .NumChannels    ( 1                            ),
        .NumLanes       ( 4                            ),
        .MaxClkDiv      ( 1024                         )
      ) i_serial_link (
        .clk_i          ( clk_i                 ),
        .rst_ni         ( rst_ni                ),
        .clk_sl_i       ( clk_i                 ),
        .rst_sl_ni      ( rst_ni                ),
        .clk_reg_i      ( clk_i                 ),
        .rst_reg_ni     ( rst_ni                ),
        .testmode_i     ( testmode_i            ),
        .axi_in_req_i   ( ddr_link_axi_in_req   ),
        .axi_in_rsp_o   ( ddr_link_axi_in_rsp   ),
        .axi_out_req_o  ( axi_xbar_slv_port_reqs[AXI_XBAR_IN_DDR_LINK]      ),
        .axi_out_rsp_i  ( axi_xbar_slv_port_rsps[AXI_XBAR_IN_DDR_LINK]      ),
        .cfg_req_i      ( regbus_periph_out_req[REGBUS_PERIPH_OUT_DDR_LINK] ),
        .cfg_rsp_o      ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_DDR_LINK] ),
        .ddr_rcv_clk_i  ( ddr_link_clk_i        ),
        .ddr_rcv_clk_o  ( ddr_link_clk_o        ),
        .ddr_i          ( ddr_link_i            ),
        .ddr_o          ( ddr_link_o            ),
        .isolated_i     ( '0                    ),
        .isolate_o      (                       ),
        .clk_ena_o      (                       ),
        .reset_no       (                       )
      );

    end else begin
      
      assign ddr_link_clk_o = '1;
      assign ddr_link_o = '0;

      axi_err_slv #(
        .AxiIdWidth ( AXI_XBAR_SLAVE_ID_WIDTH   ),
        .axi_req_t  ( axi_a48_d64_slv_u0_req_t  ),
        .axi_resp_t ( axi_a48_d64_slv_u0_resp_t ),
        .RespWidth  ( 64                        ),
        .RespData   ( 64'hCA11AB1EBADCAB1E      ),
        .ATOPs      ( 1'b1                      ),
        .MaxTrans   ( 1                         )
      ) i_axi_err_slv_ddr_link (
        .clk_i,
        .rst_ni,
        .test_i     ( testmode_i                ),
        .slv_req_i  ( axi_xbar_mst_port_reqs[AXI_XBAR_OUT_DDR_LINK] ),
        .slv_resp_o ( axi_xbar_mst_port_rsps[AXI_XBAR_OUT_DDR_LINK] )
      );

      reg_err_slv #(
        .DW      ( 32 ),
        .ERR_VAL ( 32'hBADCAB1E ),
        .req_t   ( reg_a48_d32_req_t ),
        .rsp_t   ( reg_a48_d32_rsp_t )
      ) i_reg_err_slv_ddr_link (
        .req_i   ( regbus_periph_out_req[REGBUS_PERIPH_OUT_DDR_LINK] ),
        .rsp_o   ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_DDR_LINK] )
      );

    end
  endgenerate

  //////////////////////
  //  VGA Controller  //
  //////////////////////

  generate
    if(CheshireCfg.VGA) begin

      axi_vga #(
        .RedWidth       ( CheshireCfg.VGARedWidth   ),
        .GreenWidth     ( CheshireCfg.VGAGreenWidth ),
        .BlueWidth      ( CheshireCfg.VGABlueWidth  ),
        .HCountWidth    ( 32                        ),
        .VCountWidth    ( 32                        ),
        .AXIAddrWidth   ( AXI_ADDR_WIDTH            ),
        .AXIDataWidth   ( AXI_DATA_WIDTH            ),          
        .AXIStrbWidth   ( AXI_STRB_WIDTH            ),
        .axi_req_t      ( axi_a48_d64_mst_u0_req_t  ),
        .axi_resp_t     ( axi_a48_d64_mst_u0_resp_t ),
        .reg_req_t      ( reg_a48_d32_req_t         ),
        .reg_resp_t     ( reg_a48_d32_rsp_t         )
      ) i_axi_vga (
        .clk_i,
        .rst_ni,
        .test_mode_en_i ( testmode_i                ),
        .reg_req_i      ( regbus_periph_out_req[REGBUS_PERIPH_OUT_VGA] ),
        .reg_rsp_o      ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_VGA] ),
        .axi_req_o      ( axi_xbar_slv_port_reqs[AXI_XBAR_IN_VGA]      ),
        .axi_resp_i     ( axi_xbar_slv_port_rsps[AXI_XBAR_IN_VGA]      ),
        .hsync_o        ( vga_hsync_o               ),
        .vsync_o        ( vga_vsync_o               ),
        .red_o          ( vga_red_o                 ),
        .green_o        ( vga_green_o               ),
        .blue_o         ( vga_blue_o                )
      );
    
    end else begin

      assign axi_xbar_slv_port_reqs[AXI_XBAR_IN_VGA] = '0; // TODO

      assign vga_hsync_o = '0;
      assign vga_vsync_o = '0;
      assign vga_red_o = '0;
      assign vga_green_o = '0;
      assign vga_blue_o = '0;

      reg_err_slv #(
        .DW      ( 32 ),
        .ERR_VAL ( 32'hBADCAB1E ),
        .req_t   ( reg_a48_d32_req_t ),
        .rsp_t   ( reg_a48_d32_rsp_t )
      ) i_reg_err_slv_vga (
        .req_i   ( regbus_periph_out_req[REGBUS_PERIPH_OUT_VGA] ),
        .rsp_o   ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_VGA] )
      );

    end
  endgenerate

  //////////////////////
  //  DMA Controller  //
  //////////////////////

  generate
    if(CheshireCfg.DMA) begin

      AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH            ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH            ),
        .AXI_ID_WIDTH   ( AXI_XBAR_SLAVE_ID_WIDTH  ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH            )
      ) axi_xbar_atomics_dma ();

      AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH           ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH           ),
        .AXI_ID_WIDTH   ( AXI_XBAR_SLAVE_ID_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH           )
      ) axi_atomics_dma_wrap ();

      AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH           ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH           ),
        .AXI_ID_WIDTH   ( AXI_XBAR_MASTER_ID_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH           )
      ) dma_wrap_axi_xbar ();

      axi_a48_d64_slv_u0_req_t axi_xbar_atomics_dma_req;
      axi_a48_d64_slv_u0_resp_t axi_xbar_atomics_dma_rsp;

      axi_a48_d64_mst_u0_req_t dma_wrap_axi_xbar_req;
      axi_a48_d64_mst_u0_resp_t dma_wrap_axi_xbar_rsp;

      assign axi_xbar_atomics_dma_req = axi_xbar_mst_port_reqs[AXI_XBAR_OUT_DMA_CONF];
      assign axi_xbar_mst_port_rsps[AXI_XBAR_OUT_DMA_CONF] = axi_xbar_atomics_dma_rsp;

      // From XBar to atomics wrap
      `AXI_ASSIGN_FROM_REQ(axi_xbar_atomics_dma, axi_xbar_atomics_dma_req)
      `AXI_ASSIGN_TO_RESP(axi_xbar_atomics_dma_rsp, axi_xbar_atomics_dma)

      // From DMA wrap to XBar
      `AXI_ASSIGN_TO_REQ(dma_wrap_axi_xbar_req, dma_wrap_axi_xbar)
      `AXI_ASSIGN_FROM_RESP(dma_wrap_axi_xbar, dma_wrap_axi_xbar_rsp)

      assign axi_xbar_slv_port_reqs[AXI_XBAR_IN_DMA] = dma_wrap_axi_xbar_req;
      assign dma_wrap_axi_xbar_rsp = axi_xbar_slv_port_rsps[AXI_XBAR_IN_DMA];
  
      axi_riscv_atomics_wrap #(
        .AXI_ADDR_WIDTH     ( AXI_ADDR_WIDTH              ),
        .AXI_DATA_WIDTH     ( AXI_DATA_WIDTH              ),
        .AXI_ID_WIDTH       ( AXI_XBAR_SLAVE_ID_WIDTH     ),
        .AXI_USER_WIDTH     ( AXI_USER_WIDTH              ),
        .AXI_MAX_READ_TXNS  ( 4                           ),
        .AXI_MAX_WRITE_TXNS ( 4                           ),
        .AXI_USER_AS_ID     ( 1'b1                        ),
        .AXI_USER_ID_MSB    ( 0                           ),
        .AXI_USER_ID_LSB    ( 0                           ),
        .RISCV_WORD_WIDTH   ( 64                          )
      ) i_axi_riscv_atomics_dma (
        .clk_i,
        .rst_ni,
        .mst                ( axi_atomics_dma_wrap.Master ),
        .slv                ( axi_xbar_atomics_dma.Slave    )
      );

      dma_core_wrap #(
        .AXI_ADDR_WIDTH   ( AXI_ADDR_WIDTH              ),
        .AXI_DATA_WIDTH   ( AXI_DATA_WIDTH              ),
        .AXI_USER_WIDTH   ( AXI_USER_WIDTH              ),
        .AXI_ID_WIDTH     ( AXI_XBAR_SLAVE_ID_WIDTH     ), // TODO
        .AXI_SLV_ID_WIDTH ( AXI_XBAR_SLAVE_ID_WIDTH     )
      ) i_dma_core_wrap (
        .clk_i,
        .rst_ni,
        .testmode_i,
        .axi_master       ( dma_wrap_axi_xbar.Master    ),
        .axi_slave        ( axi_atomics_dma_wrap.Slave  )
      );
    
    end else begin

      assign axi_xbar_slv_port_reqs[AXI_XBAR_IN_DMA] = '0;

      axi_err_slv #(
        .AxiIdWidth ( AXI_XBAR_SLAVE_ID_WIDTH   ),
        .axi_req_t  ( axi_a48_d64_slv_u0_req_t  ),
        .axi_resp_t ( axi_a48_d64_slv_u0_resp_t ),
        .RespWidth  ( 64                        ),
        .RespData   ( 64'hCA11AB1EBADCAB1E      ),
        .ATOPs      ( 1'b1                      ),
        .MaxTrans   ( 1                         )
      ) i_axi_err_slv_dma (
        .clk_i,
        .rst_ni,
        .test_i     ( testmode_i                ),
        .slv_req_i  ( axi_xbar_mst_port_reqs[AXI_XBAR_OUT_DMA_CONF] ),
        .slv_resp_o ( axi_xbar_mst_port_rsps[AXI_XBAR_OUT_DMA_CONF] )
      );

    end
  endgenerate



  /////////////////////////
  //  Scratchpad memory  //
  /////////////////////////

  logic spm_req, spm_gnt, spm_we, spm_rvalid;
  logic [47:0] spm_addr;
  logic [63:0] spm_wdata, spm_rdata;
  logic [7:0]  spm_strb;

  axi_to_mem_interleaved #(
    .axi_req_t    ( axi_a48_d64_slv_u0_req_t  ),
    .axi_resp_t   ( axi_a48_d64_slv_u0_resp_t ),
    .AddrWidth    ( 48                        ),
    .DataWidth    ( 64                        ),
    .IdWidth      ( AXI_XBAR_SLAVE_ID_WIDTH   ),
    .NumBanks     ( 1                         ),
    .BufDepth     ( 3                         )
  ) i_axi_to_mem_spm (
    .clk_i,
    .rst_ni,
    .busy_o       (                           ),
    .axi_req_i    ( axi_xbar_mst_port_reqs[AXI_XBAR_OUT_SPM] ),
    .axi_resp_o   ( axi_xbar_mst_port_rsps[AXI_XBAR_OUT_SPM] ),
    .mem_req_o    ( spm_req                   ),
    .mem_gnt_i    ( spm_gnt                   ),
    .mem_addr_o   ( spm_addr                  ),
    .mem_wdata_o  ( spm_wdata                 ),
    .mem_strb_o   ( spm_strb                  ),
    .mem_atop_o   (                           ),
    .mem_we_o     ( spm_we                    ),
    .mem_rvalid_i ( spm_rvalid                ),
    .mem_rdata_i  ( spm_rdata                 )
  );

  // Scratch Pad Memory
  spm_1p_adv #(
    .NumWords             ( 16384           ),  // 128 KiB
    .DataWidth            ( 64              ),
    .ByteWidth            ( 8               ),
    .EnableInputPipeline  ( 1               ),
    .EnableOutputPipeline ( 1               ),
    .EnableECC            ( 0               ),
    .SimInit              ( "zeros"         ),
    .sram_cfg_t           ( sram_cfg_t      )
  ) i_spm (
    .clk_i,
    .rst_ni,
    .valid_i              ( spm_req         ),
    .ready_o              ( spm_gnt         ),
    .we_i                 ( spm_we          ),
    .addr_i               ( spm_addr[16:3]  ),
    .wdata_i              ( spm_wdata       ),
    .be_i                 ( spm_strb        ),
    .rdata_o              ( spm_rdata       ),
    .rvalid_o             ( spm_rvalid      ),
    .rerror_o             (                 ), // TODO
    .sram_cfg_i           ( '0              )
  );


  //////////////
  // RPC DRAM //
  //////////////

  generate
    if(CheshireCfg.RPC_DRAM) begin
      
      AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH          ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH          ),
        .AXI_ID_WIDTH   ( AXI_XBAR_SLAVE_ID_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH          )
      ) axi_xbar_atomics_dram();

      AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH          ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH          ),
        .AXI_ID_WIDTH   ( AXI_XBAR_SLAVE_ID_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH          )
      ) axi_dram_out();

      `AXI_ASSIGN_FROM_REQ(axi_xbar_atomics_dram, axi_xbar_mst_port_reqs[AXI_XBAR_OUT_RPC_DRAM])
      `AXI_ASSIGN_TO_RESP(axi_xbar_mst_port_rsps[AXI_XBAR_OUT_RPC_DRAM], axi_xbar_atomics_dram)

      `AXI_ASSIGN_TO_REQ(dram_req_o, axi_dram_out)
      `AXI_ASSIGN_FROM_RESP(axi_dram_out, dram_resp_i)   
   
      axi_riscv_atomics_wrap #(
        .AXI_ADDR_WIDTH     ( AXI_ADDR_WIDTH              ),
        .AXI_DATA_WIDTH     ( AXI_DATA_WIDTH              ),
        .AXI_ID_WIDTH       ( AXI_XBAR_SLAVE_ID_WIDTH     ),
        .AXI_USER_WIDTH     ( AXI_USER_WIDTH              ),
        .AXI_MAX_READ_TXNS  ( 4                           ),
        .AXI_MAX_WRITE_TXNS ( 4                           ),
        .AXI_USER_AS_ID     ( 1'b1                        ),
        .AXI_USER_ID_MSB    ( 0                           ),
        .AXI_USER_ID_LSB    ( 0                           ),
        .RISCV_WORD_WIDTH   ( 64                          )
      ) i_axi_riscv_atomics_dram (
        .clk_i,
        .rst_ni,
        .mst                ( axi_dram_out.Master ),
        .slv                ( axi_xbar_atomics_dram.Slave  )
      );

      // Connect the external DRAM signals
      // Regbus
      assign dram_conf_req_o = regbus_periph_out_req[REGBUS_PERIPH_OUT_RPC_DRAM];
      assign regbus_periph_out_rsp[REGBUS_PERIPH_OUT_RPC_DRAM] = dram_conf_rsp_i;
  
    end else begin
      
      axi_err_slv #(
        .AxiIdWidth ( AXI_XBAR_SLAVE_ID_WIDTH   ),
        .axi_req_t  ( axi_a48_d64_slv_u0_req_t  ),
        .axi_resp_t ( axi_a48_d64_slv_u0_resp_t ),
        .RespWidth  ( 64                        ),
        .RespData   ( 64'hCA11AB1EBADCAB1E      ),
        .ATOPs      ( 1'b1                      ),
        .MaxTrans   ( 1                         )
      ) i_axi_err_slv_rpc_dram (
        .clk_i,
        .rst_ni,
        .test_i     ( testmode_i                ),
        .slv_req_i  ( axi_xbar_mst_port_reqs[AXI_XBAR_OUT_RPC_DRAM] ),
        .slv_resp_o ( axi_xbar_mst_port_rsps[AXI_XBAR_OUT_RPC_DRAM] )
      );

      reg_err_slv #(
        .DW      ( 32 ),
        .ERR_VAL ( 32'hBADCAB1E ),
        .req_t   ( reg_a48_d32_req_t ),
        .rsp_t   ( reg_a48_d32_rsp_t )
      ) i_reg_err_slv_rpc_dram (
        .req_i   ( regbus_periph_out_req[REGBUS_PERIPH_OUT_RPC_DRAM] ),
        .rsp_o   ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_RPC_DRAM] )
      );


    end
  endgenerate
   
  //////////////
  //  Regbus  //
  //////////////

  logic [cf_math_pkg::idx_width(REGBUS_PERIPH_NUM_OUTPUTS)-1:0] regbus_periph_select; // TODO

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH          ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH          ),
    .AXI_ID_WIDTH   ( AXI_XBAR_SLAVE_ID_WIDTH ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH          )
  ) axi_xbar_atomics_regbus();

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH          ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH          ),
    .AXI_ID_WIDTH   ( AXI_XBAR_SLAVE_ID_WIDTH ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH          )
  ) axi_atomics_dw_conv();

  axi_a48_d64_slv_u0_req_t  axi_xbar_atomics_req;
  axi_a48_d64_slv_u0_resp_t axi_xbar_atomics_rsp;

  axi_a48_d64_slv_u0_req_t  axi_atomics_dw_conv_req;
  axi_a48_d64_slv_u0_resp_t axi_atomics_dw_conv_rsp;

  axi_a48_d32_slv_u0_req_t axi_dw_conv_to_req;
  axi_a48_d32_slv_u0_resp_t axi_dw_conv_to_rsp;

  // From XBar to Atomics Wrap
  `AXI_ASSIGN_FROM_REQ(axi_xbar_atomics_regbus, axi_xbar_atomics_req)
  `AXI_ASSIGN_TO_RESP(axi_xbar_atomics_rsp, axi_xbar_atomics_regbus)

  // From Atomics Wrap to DW Converter
  `AXI_ASSIGN_TO_REQ(axi_atomics_dw_conv_req, axi_atomics_dw_conv)
  `AXI_ASSIGN_FROM_RESP(axi_atomics_dw_conv, axi_atomics_dw_conv_rsp)

  assign axi_xbar_atomics_req = axi_xbar_mst_port_reqs[AXI_XBAR_OUT_REGBUS_PERIPH];
  assign axi_xbar_mst_port_rsps[AXI_XBAR_OUT_REGBUS_PERIPH] = axi_xbar_atomics_rsp;

  axi_riscv_atomics_wrap #(
    .AXI_ADDR_WIDTH     ( AXI_ADDR_WIDTH             ),
    .AXI_DATA_WIDTH     ( AXI_DATA_WIDTH             ),
    .AXI_ID_WIDTH       ( AXI_XBAR_SLAVE_ID_WIDTH    ),
    .AXI_USER_WIDTH     ( AXI_USER_WIDTH             ),
    .AXI_MAX_READ_TXNS  ( 4                          ),
    .AXI_MAX_WRITE_TXNS ( 4                          ),
    .AXI_USER_AS_ID     ( 1'b1                       ),
    .AXI_USER_ID_MSB    ( 0                          ),
    .AXI_USER_ID_LSB    ( 0                          ),
    .RISCV_WORD_WIDTH   ( 64                         )
  ) i_axi_riscv_atomics_regbus (
    .clk_i,
    .rst_ni,
    .mst                ( axi_atomics_dw_conv.Master ),
    .slv                ( axi_xbar_atomics_regbus.Slave )
  );

  axi_dw_converter #(
	  .AxiSlvPortDataWidth  ( AXI_DATA_WIDTH               ),
	  .AxiMstPortDataWidth  ( 32                           ),
    .AxiAddrWidth         ( AXI_ADDR_WIDTH               ),
    .AxiIdWidth           ( AXI_XBAR_SLAVE_ID_WIDTH      ),
	  .aw_chan_t            ( axi_a48_d32_slv_u0_aw_chan_t ),
    .mst_w_chan_t         ( axi_a48_d32_slv_u0_w_chan_t  ),
    .slv_w_chan_t         ( axi_a48_d64_slv_u0_w_chan_t  ),
    .b_chan_t             ( axi_a48_d32_slv_u0_b_chan_t  ),
    .ar_chan_t            ( axi_a48_d32_slv_u0_ar_chan_t ),
    .mst_r_chan_t         ( axi_a48_d32_slv_u0_r_chan_t  ),
    .slv_r_chan_t         ( axi_a48_d64_slv_u0_r_chan_t  ),
    .axi_mst_req_t        ( axi_a48_d32_slv_u0_req_t     ),
    .axi_mst_resp_t       ( axi_a48_d32_slv_u0_resp_t    ),
    .axi_slv_req_t        ( axi_a48_d64_slv_u0_req_t     ),
	  .axi_slv_resp_t       ( axi_a48_d64_slv_u0_resp_t    )
  ) i_axi_dw_converter (
	  .clk_i,
	  .rst_ni,
	  .slv_req_i            ( axi_atomics_dw_conv_req      ),
	  .slv_resp_o           ( axi_atomics_dw_conv_rsp      ),
	  .mst_req_o            ( axi_dw_conv_to_req           ),
	  .mst_resp_i           ( axi_dw_conv_to_rsp           )
  );

  axi_to_reg #(
	  .ADDR_WIDTH         ( AXI_ADDR_WIDTH            ),
	  .DATA_WIDTH         ( 32                        ),
	  .ID_WIDTH           ( AXI_XBAR_SLAVE_ID_WIDTH   ),
	  .USER_WIDTH         ( AXI_USER_WIDTH            ),
	  .AXI_MAX_WRITE_TXNS ( 4                         ),
	  .AXI_MAX_READ_TXNS  ( 4                         ),
	  .DECOUPLE_W         ( 1                         ),
	  .axi_req_t          ( axi_a48_d32_slv_u0_req_t  ),
	  .axi_rsp_t          ( axi_a48_d32_slv_u0_resp_t ),
	  .reg_req_t          ( reg_a48_d32_req_t         ),
	  .reg_rsp_t          ( reg_a48_d32_rsp_t         )
  ) i_axi_to_reg (
	  .clk_i,
	  .rst_ni,
	  .testmode_i,
	  .axi_req_i          ( axi_dw_conv_to_req        ), 
	  .axi_rsp_o          ( axi_dw_conv_to_rsp        ), 
	  .reg_req_o          ( regbus_periph_in_req      ),
	  .reg_rsp_i          ( regbus_periph_in_rsp      )
  );

  addr_decode #(
    .NoIndices        ( REGBUS_PERIPH_NUM_OUTPUTS ),
    .NoRules          ( REGBUS_PERIPH_NUM_OUTPUTS ), // Assume one rule per peripheral
    .addr_t           ( logic [47:0]              ), 
    .rule_t           ( address_rule_48_t         )
  ) i_addr_decode_regbus_periph (
    .addr_i           ( regbus_periph_in_req.addr ),
    .addr_map_i       ( regbus_periph_addrmap     ),
    .idx_o            ( regbus_periph_select      ),
    .dec_valid_o      (                           ),
    .dec_error_o      (                           ),
    .en_default_idx_i ( '0                        ),
    .default_idx_i    ( '0                        )
  );

  reg_demux #(
  	.NoPorts      ( REGBUS_PERIPH_NUM_OUTPUTS ),
    .req_t        ( reg_a48_d32_req_t         ),
    .rsp_t        ( reg_a48_d32_rsp_t         )
  ) i_soc_regbus_periph (
    .clk_i,
    .rst_ni,
    .in_select_i  ( regbus_periph_select      ),
    .in_req_i     ( regbus_periph_in_req      ),
    .in_rsp_o     ( regbus_periph_in_rsp      ),
    .out_req_o    ( regbus_periph_out_req     ),
    .out_rsp_i    ( regbus_periph_out_rsp     )
  );

  ////////////
  //  UART  //
  ////////////

  generate
    if(CheshireCfg.UART) begin

      apb_a48_d32_req_t uart_apb_req;
      apb_a48_d32_rsp_t uart_apb_rsp;

      reg_to_apb #(
        .reg_req_t  ( reg_a48_d32_req_t ),
        .reg_rsp_t  ( reg_a48_d32_rsp_t ),
        .apb_req_t  ( apb_a48_d32_req_t ),
        .apb_rsp_t  ( apb_a48_d32_rsp_t )
      ) i_reg_to_apb_uart (
        .clk_i,
        .rst_ni,
        .reg_req_i  ( regbus_periph_out_req[REGBUS_PERIPH_OUT_UART] ),
        .reg_rsp_o  ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_UART] ),
        .apb_req_o  ( uart_apb_req      ),
        .apb_rsp_i  ( uart_apb_rsp      )
      );

      apb_uart_wrap #(
        .apb_req_t  ( apb_a48_d32_req_t ),
        .apb_rsp_t  ( apb_a48_d32_rsp_t )
      ) i_uart (
        .clk_i,
        .rst_ni,
        .apb_req_i  ( uart_apb_req      ),
        .apb_rsp_o  ( uart_apb_rsp      ),
        .intr_o     ( irq.uart          ),
        .out2_no    (                   ),  // keep open
        .out1_no    (                   ),  // keep open
        .rts_no     (                   ),  // no flow control
        .dtr_no     (                   ),  // no flow control
        .cts_ni     ( 1'b0              ),  // no flow control
        .dsr_ni     ( 1'b0              ),  // no flow control
        .dcd_ni     ( 1'b0              ),  // no flow control
        .rin_ni     ( 1'b0              ),
        .sin_i      ( uart_rx_i         ),
        .sout_o     ( uart_tx_o         )
      );
    
    end else begin

      assign uart_tx_o = '0;

      assign irq.uart = '0;

      reg_err_slv #(
        .DW      ( 32 ),
        .ERR_VAL ( 32'hBADCAB1E ),
        .req_t   ( reg_a48_d32_req_t ),
        .rsp_t   ( reg_a48_d32_rsp_t )
      ) i_reg_err_slv_uart (
        .req_i   ( regbus_periph_out_req[REGBUS_PERIPH_OUT_UART] ),
        .rsp_o   ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_UART] )
      );
    
    end
  endgenerate

  ///////////
  //  I2C  //
  ///////////

  generate
    if(CheshireCfg.I2C) begin

      i2c #(
        .reg_req_t                ( reg_a48_d32_req_t        ),
        .reg_rsp_t                ( reg_a48_d32_rsp_t        )
      ) i_i2c (
        .clk_i,
        .rst_ni,
        .reg_req_i                ( regbus_periph_out_req[REGBUS_PERIPH_OUT_I2C] ),
        .reg_rsp_o                ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_I2C] ),
        .cio_scl_i                ( i2c_scl_i                ),
        .cio_scl_o                ( i2c_scl_o                ),
        .cio_scl_en_o             ( i2c_scl_en_o             ),
        .cio_sda_i                ( i2c_sda_i                ),
        .cio_sda_o                ( i2c_sda_o                ),
        .cio_sda_en_o             ( i2c_sda_en_o             ),
        .intr_fmt_watermark_o     ( irq.i2c_fmt_watermark    ),
        .intr_rx_watermark_o      ( irq.i2c_rx_watermark     ),
        .intr_fmt_overflow_o      ( irq.i2c_fmt_overflow     ),
        .intr_rx_overflow_o       ( irq.i2c_rx_overflow      ),
        .intr_nak_o               ( irq.i2c_nak              ),
        .intr_scl_interference_o  ( irq.i2c_scl_interference ),
        .intr_sda_interference_o  ( irq.i2c_sda_interference ),
        .intr_stretch_timeout_o   ( irq.i2c_stretch_timeout  ),
        .intr_sda_unstable_o      ( irq.i2c_sda_unstable     ),
        .intr_trans_complete_o    ( irq.i2c_trans_complete   ),
        .intr_tx_empty_o          ( irq.i2c_tx_empty         ),
        .intr_tx_nonempty_o       ( irq.i2c_tx_nonempty      ),
        .intr_tx_overflow_o       ( irq.i2c_tx_overflow      ),
        .intr_acq_overflow_o      ( irq.i2c_acq_overflow     ),
        .intr_ack_stop_o          ( irq.i2c_ack_stop         ),
        .intr_host_timeout_o      ( irq.i2c_host_timeout     )
      );
    
    end else begin

      assign i2c_scl_o = '0;
      assign i2c_scl_en_o = '0;
      assign i2c_sda_o = '0;
      assign i2c_sda_en_o = '0;

      assign irq.i2c_fmt_watermark = '0;
      assign irq.i2c_rx_watermark = '0;
      assign irq.i2c_fmt_overflow = '0;
      assign irq.i2c_rx_overflow = '0;
      assign irq.i2c_nak = '0;
      assign irq.i2c_scl_interference = '0;
      assign irq.i2c_sda_interference = '0;
      assign irq.i2c_stretch_timeout = '0;
      assign irq.i2c_sda_unstable = '0;
      assign irq.i2c_trans_complete = '0;
      assign irq.i2c_tx_empty = '0;
      assign irq.i2c_tx_nonempty = '0;
      assign irq.i2c_tx_overflow = '0;
      assign irq.i2c_acq_overflow = '0;
      assign irq.i2c_ack_stop = '0;
      assign irq.i2c_host_timeout = '0;

      reg_err_slv #(
        .DW      ( 32 ),
        .ERR_VAL ( 32'hBADCAB1E ),
        .req_t   ( reg_a48_d32_req_t ),
        .rsp_t   ( reg_a48_d32_rsp_t )
      ) i_reg_err_slv_i2c (
        .req_i   ( regbus_periph_out_req[REGBUS_PERIPH_OUT_I2C] ),
        .rsp_o   ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_I2C] )
      );

    end
  endgenerate

  ////////////
  //  SPIM  //
  ////////////

  generate
    if(CheshireCfg.SPI) begin

      spi_host #(
        .reg_req_t        ( reg_a48_d32_req_t  ),
        .reg_rsp_t        ( reg_a48_d32_rsp_t  )
      ) i_spi_host (
        .clk_i,
        .rst_ni,
        .clk_core_i       ( clk_i              ),
        .rst_core_ni      ( rst_ni             ),
        .reg_req_i        ( regbus_periph_out_req[REGBUS_PERIPH_OUT_SPIM] ),
        .reg_rsp_o        ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_SPIM] ),
        .cio_sck_o        ( spim_sck_o         ),
        .cio_sck_en_o     ( spim_sck_en_o      ),
        .cio_csb_o        ( spim_csb_o         ),
        .cio_csb_en_o     ( spim_csb_en_o      ),
        .cio_sd_o         ( spim_sd_o          ),
        .cio_sd_en_o      ( spim_sd_en_o       ),
        .cio_sd_i         ( spim_sd_i          ),
        .intr_error_o     ( irq.spim_error     ), 
        .intr_spi_event_o ( irq.spim_spi_event ) 
      );

    end else begin

      assign spi_sck_o = '0;
      assign spim_sck_en_o = '0;
      assign spim_csb = '0;
      assign spim_csb_en_o = '0;
      assign spim_sd_o = '0;
      assign spim_sd_en_o = '0;

      assign irq.spim_error = '0;
      assign irq.spim_spi_event = '0;

      reg_err_slv #(
        .DW      ( 32 ),
        .ERR_VAL ( 32'hBADCAB1E ),
        .req_t   ( reg_a48_d32_req_t ),
        .rsp_t   ( reg_a48_d32_rsp_t )
      ) i_reg_err_slv_spim (
        .req_i   ( regbus_periph_out_req[REGBUS_PERIPH_OUT_SPIM] ),
        .rsp_o   ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_SPIM] )
      );

    end
  endgenerate

  /////////////////////
  //  Register File  //
  /////////////////////

  cheshire_register_file_reg_pkg::cheshire_register_file_hw2reg_t reg_file_in;

  assign reg_file_in.boot_mode.d = boot_mode_i;
  assign reg_file_in.fll_lock.d  = fll_lock_i;
  

  cheshire_register_file_reg_top #(
    .reg_req_t  ( reg_a48_d32_req_t ),
    .reg_rsp_t  ( reg_a48_d32_rsp_t )
  ) i_register_file (
    .clk_i,
    .rst_ni,
    .reg_req_i  ( regbus_periph_out_req[REGBUS_PERIPH_OUT_CSR] ),
    .reg_rsp_o  ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_CSR] ),
    .hw2reg     ( reg_file_in       ),
    .devmode_i  ( 1'b1              )     // TODO
  );

  ///////////////
  //  Bootrom  //
  ///////////////

  logic rom_req, rom_rvalid;
  logic [15:0] rom_addr;
  logic [31:0] rom_data_q, rom_data_d;

  reg_to_mem #(
    .AW         ( 16                ),
    .DW         ( 32                ),
    .req_t      ( reg_a48_d32_req_t ),
    .rsp_t      ( reg_a48_d32_rsp_t )
  ) i_reg_to_rom (
    .clk_i,
    .rst_ni,
    .reg_req_i  ( regbus_periph_out_req[REGBUS_PERIPH_OUT_BOOTROM] ),
    .reg_rsp_o  ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_BOOTROM] ),
    .req_o      ( rom_req           ),
    .gnt_i      ( rom_req           ),
    .we_o       (                   ),
    .addr_o     ( rom_addr          ),
    .wdata_o    (                   ),
    .wstrb_o    (                   ),
    .rdata_i    ( rom_data_q        ),
    .rvalid_i   ( rom_rvalid        ),
    .rerror_i   ( '0                )
  );

  bootrom #(
    .AddrWidth  ( 16         ),
    .DataWidth  ( 32         )
  ) i_bootrom (
    .clk_i,
    .rst_ni,
    .req_i      ( rom_req    ),
    .addr_i     ( rom_addr   ),
    .data_o     ( rom_data_d )
  );

  // Data register
  `FF(rom_data_q, rom_data_d, '0, clk_i, rst_ni)

  // As the bootrom can answer in one clock cycle the valid signal is
  // just the one clock cycle delayed version of the request signal
  `FF(rom_rvalid, rom_req, '0, clk_i, rst_ni)
   
  ////////////
  //  PLIC  //
  ////////////

  rv_plic #(
      .reg_req_t  ( reg_a48_d32_req_t ),
      .reg_rsp_t  ( reg_a48_d32_rsp_t )
  ) i_rv_plic (
      .clk_i,
      .rst_ni,
      .reg_req_i  ( regbus_periph_out_req[REGBUS_PERIPH_OUT_PLIC] ),
      .reg_rsp_o  ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_PLIC] ),
      .intr_src_i ( irq               ), 
      .irq_o      ( eip               ), 
      .irq_id_o   (                   ),
      .msip_o     (                   )
  );

  assign irq.zero = 1'b0;

  /////////////
  //  CLINT  //
  /////////////

  clint #(
    .reg_req_t    ( reg_a48_d32_req_t ),
    .reg_rsp_t    ( reg_a48_d32_rsp_t )
  ) i_clint (
    .clk_i,
    .rst_ni,
    .testmode_i,
    .reg_req_i    ( regbus_periph_out_req[REGBUS_PERIPH_OUT_CLINT] ),
    .reg_rsp_o    ( regbus_periph_out_rsp[REGBUS_PERIPH_OUT_CLINT] ),
    .rtc_i        ( rtc_i             ),
    .timer_irq_o  ( mstip             ), 
    .ipi_o        ( mssip             ) 
  );

  ///////////////
  //  FLL CFG  //
  ///////////////

  assign fll_reg_req_o = regbus_periph_out_req[REGBUS_PERIPH_OUT_FLL];
  assign regbus_periph_out_rsp[REGBUS_PERIPH_OUT_FLL] = fll_reg_rsp_i;

  ////////////////////
  //  Pad CTRL CFG  //
  ////////////////////

  assign pad_config_req_o = regbus_periph_out_req[REGBUS_PERIPH_OUT_PAD_CTRL];
  assign regbus_periph_out_rsp[REGBUS_PERIPH_OUT_PAD_CTRL] = pad_config_rsp_i;

endmodule
