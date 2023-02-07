// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

`include "axi/assign.svh"
`include "common_cells/registers.svh"

module cheshire_soc import cheshire_pkg::*; #(
  parameter cheshire_cfg_t CheshireCfg = CheshireCfgASICDefault
) (
  input   logic               clk_i,
  input   logic               rst_ni,

  input   logic               testmode_i,

  // Boot mode selection
  input   logic [1:0]         boot_mode_i,

  // Boot address for CVA6
  input   logic [63:0]        boot_addr_i,

  // DRAM AXI interface
  output  axi_a48_d64_mst_u0_llc_req_t    dram_req_o,
  input   axi_a48_d64_mst_u0_llc_resp_t   dram_resp_i,

  // DDR-Link
  input   logic [3:0]         ddr_link_i,
  output  logic [3:0]         ddr_link_o,

  input   logic               ddr_link_clk_i,
  output  logic               ddr_link_clk_o,

  // VGA Controller
  output  logic                                   vga_hsync_o,
  output  logic                                   vga_vsync_o,
  output  logic [CheshireCfg.VgaRedWidth-1:0]     vga_red_o,
  output  logic [CheshireCfg.VgaGreenWidth-1:0]   vga_green_o,
  output  logic [CheshireCfg.VgaBlueWidth-1:0]    vga_blue_o,

  // JTAG Interface
  input   logic               jtag_tck_i,
  input   logic               jtag_trst_ni,
  input   logic               jtag_tms_i,
  input   logic               jtag_tdi_i,
  output  logic               jtag_tdo_o,

  // UART Interface
  output logic                uart_tx_o,
  input  logic                uart_rx_i,

  // I2C Interface
  output logic                i2c_sda_o,
  input  logic                i2c_sda_i,
  output logic                i2c_sda_en_o,
  output logic                i2c_scl_o,
  input  logic                i2c_scl_i,
  output logic                i2c_scl_en_o,

  // SPI Host Interface
  output logic                spim_sck_o,
  output logic                spim_sck_en_o,
  output logic [ 1:0]         spim_csb_o,
  output logic [ 1:0]         spim_csb_en_o,
  output logic [ 3:0]         spim_sd_o,
  output logic [ 3:0]         spim_sd_en_o,
  input  logic [ 3:0]         spim_sd_i,

  // CLINT
  input  logic                rtc_i,

  // CLK locked signal
  input  logic                clk_locked_i,

  // External Regbus
  output reg_a48_d32_req_t    external_reg_req_o,
  input  reg_a48_d32_rsp_t    external_reg_rsp_i

);

  // X-Bar
  axi_a48_d64_slv_u0_req_t  [AxiXbarNumOutputs-1:0]  axi_xbar_mst_port_reqs;
  axi_a48_d64_slv_u0_resp_t [AxiXbarNumOutputs-1:0]  axi_xbar_mst_port_rsps;

  axi_a48_d64_mst_u0_req_t  [AxiXbarNumInputs-1:0]   axi_xbar_slv_port_reqs;
  axi_a48_d64_mst_u0_resp_t [AxiXbarNumInputs-1:0]   axi_xbar_slv_port_rsps;


  // Regbus Peripherals
  reg_a48_d32_req_t [RegbusNumOutputs-1:0] regbus_out_req;
  reg_a48_d32_rsp_t [RegbusNumOutputs-1:0] regbus_out_rsp;


  // Machine/Supervisor timer and machine/supervisor software interrupt pending.
  logic [1:0] mstip, mssip;

  // External interrupt pending (Machine/Supervisor context)
  logic [1:0] eip;

  // Interrupt vector
  cheshire_interrupt_t irq;

  // Debug Module debug request signal for CVA6
  logic debug_req;

  // External Regbus sinals
  assign external_reg_req_o = regbus_out_req[RegbusOutExternal];
  assign regbus_out_rsp[RegbusOutExternal] = external_reg_rsp_i;

  ////////////
  //  CVA6  //
  ////////////

  axi_cva6_req_t  cva6_out_req, cva6_user_id_req;
  axi_cva6_resp_t cva6_out_resp, cva6_user_id_resp;

  always_comb begin
    cva6_user_id_req          = cva6_out_req;
    cva6_user_id_req.aw.user  = Cva6Identifier;
    cva6_user_id_req.w.user   = Cva6Identifier;
    cva6_user_id_req.ar.user  = Cva6Identifier;
    cva6_out_resp             = cva6_user_id_resp;
  end

  cva6 #(
    .ArianeCfg    ( CheshireArianeConfig  )
  ) i_cva6 (
    .clk_i,
    .rst_ni,
    .boot_addr_i,
    .hart_id_i    ( 64'h0         ),
    .irq_i        ( eip           ),
    .ipi_i        ( mssip[0]      ),
    .time_irq_i   ( mstip[0]      ),
    .debug_req_i  ( debug_req     ),
    .cvxif_req_o  (               ),
    .cvxif_resp_i ( '0            ),
    .axi_req_o    ( cva6_out_req  ),
    .axi_resp_i   ( cva6_out_resp )
  );

  // Remap CVA6s 4 id bits to the system width
  axi_id_remap #(
    .AxiSlvPortIdWidth      ( 4                         ),
    .AxiSlvPortMaxUniqIds   ( 4                         ),
    .AxiMaxTxnsPerId        ( 1                         ),
    .AxiMstPortIdWidth      ( AxiXbarMasterIdWidth      ),
    .slv_req_t              ( axi_cva6_req_t            ),
    .slv_resp_t             ( axi_cva6_resp_t           ),
    .mst_req_t              ( axi_a48_d64_mst_u0_req_t  ),
    .mst_resp_t             ( axi_a48_d64_mst_u0_resp_t )
  ) i_axi_id_remap_cva6 (
    .clk_i,
    .rst_ni,
    .slv_req_i              ( cva6_user_id_req                      ),
    .slv_resp_o             ( cva6_user_id_resp                     ),
    .mst_req_o              ( axi_xbar_slv_port_reqs[AxiXbarInCva6] ),
    .mst_resp_i             ( axi_xbar_slv_port_rsps[AxiXbarInCva6] )
  );

  /////////////////
  //  AXI X-Bar  //
  /////////////////

  axi_xbar #(
    .Cfg            ( AxiXbarCfg                    ),
    .ATOPs          ( 1'b1                          ),
    .Connectivity   ( AxiXbarConnectivity           ),
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
    .addr_map_i             ( AxiXbarAddrmap             ),
    .en_default_mst_port_i  ( '0                         ),
    .default_mst_port_i     ( '0                         )
  );

  /////////////
  //  Debug  //
  /////////////

  // DMI signals for JTAG DMI <-> DM communication
  logic dmi_rst_n;
  dm::dmi_req_t dmi_req;
  logic dmi_req_ready;
  logic dmi_req_valid;
  dm::dmi_resp_t dmi_resp;
  logic dmi_resp_ready;
  logic dmi_resp_valid;

  // Slave side of the debug module
  logic           dbg_req;
  logic   [47:0]  dbg_addr;
  logic           dbg_we;
  logic   [63:0]  dbg_wdata;
  logic   [ 7:0]  dbg_wstrb;
  logic   [63:0]  dbg_rdata;
  logic           dbg_rvalid;

  // System Bus Access for the debug module
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
    .IdWidth         ( AxiXbarSlaveIdWidth       ),
    .NumBanks        ( 1                         ),
    .BufDepth        ( 3                         )
  ) i_axi_to_mem_dbg (
    .clk_i,
    .rst_ni,
    .busy_o          (                           ),
    .axi_req_i       ( axi_xbar_mst_port_reqs[AxiXbarOutDebug] ),
    .axi_resp_o      ( axi_xbar_mst_port_rsps[AxiXbarOutDebug] ),
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

  // dbg_rvalid = #1 dbg_req
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

  // From DM --> AXI X-Bar
  axi_from_mem #(
    .MemAddrWidth    ( 48                        ),
    .AxiAddrWidth    ( AxiAddrWidth              ),
    .DataWidth       ( 64                        ),
    .MaxRequests     ( 2                         ),
    .AxiProt         ( '0                        ),
    .axi_req_t       ( axi_a48_d64_mst_u0_req_t  ),
    .axi_rsp_t       ( axi_a48_d64_mst_u0_resp_t )
  ) i_axi_from_mem_dbg (
    .clk_i,
    .rst_ni,
    .mem_req_i       ( sba_req                   ),
    .mem_addr_i      ( sba_addr                  ),
    .mem_we_i        ( sba_we                    ),
    .mem_wdata_i     ( sba_wdata                 ),
    .mem_be_i        ( sba_strb                  ),
    .mem_gnt_o       ( sba_gnt                   ),
    .mem_rsp_valid_o ( sba_rvalid                ),
    .mem_rsp_rdata_o ( sba_rdata                 ),
    .mem_rsp_error_o ( sba_err                   ),
    .slv_aw_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .slv_ar_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .axi_req_o       ( axi_xbar_slv_port_reqs[AxiXbarInDebug] ),
    .axi_rsp_i       ( axi_xbar_slv_port_rsps[AxiXbarInDebug] )
  );

  // Debug Transfer Module + Debug Module Interface
  dmi_jtag #(
    .IdcodeValue      ( IDCode )
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

  if(CheshireCfg.SerialLink) begin : gen_serial_link

    axi_a48_d64_mst_u0_req_t ddr_link_axi_in_req;
    axi_a48_d64_mst_u0_resp_t ddr_link_axi_in_rsp;

    // Remap wider ID to smaller ID
    axi_id_remap #(
      .AxiSlvPortIdWidth    ( AxiXbarSlaveIdWidth       ),
      .AxiSlvPortMaxUniqIds ( 2**AxiXbarMasterIdWidth   ),
      .AxiMaxTxnsPerId      ( 1                         ),
      .AxiMstPortIdWidth    ( AxiXbarMasterIdWidth      ),
      .slv_req_t            ( axi_a48_d64_slv_u0_req_t  ),
      .slv_resp_t           ( axi_a48_d64_slv_u0_resp_t ),
      .mst_req_t            ( axi_a48_d64_mst_u0_req_t  ),
      .mst_resp_t           ( axi_a48_d64_mst_u0_resp_t )
    ) i_axi_id_remap_ddr_link (
      .clk_i,
      .rst_ni,
      .slv_req_i            ( axi_xbar_mst_port_reqs[AxiXbarOutSerialLink] ),
      .slv_resp_o           ( axi_xbar_mst_port_rsps[AxiXbarOutSerialLink] ),
      .mst_req_o            ( ddr_link_axi_in_req       ),
      .mst_resp_i           ( ddr_link_axi_in_rsp       )
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
      .testmode_i,
      .axi_in_req_i   ( ddr_link_axi_in_req   ),
      .axi_in_rsp_o   ( ddr_link_axi_in_rsp   ),
      .axi_out_req_o  ( axi_xbar_slv_port_reqs[AxiXbarInSerialLink] ),
      .axi_out_rsp_i  ( axi_xbar_slv_port_rsps[AxiXbarInSerialLink] ),
      .cfg_req_i      ( regbus_out_req[RegbusOutSerialLink] ),
      .cfg_rsp_o      ( regbus_out_rsp[RegbusOutSerialLink] ),
      .ddr_rcv_clk_i  ( ddr_link_clk_i        ),
      .ddr_rcv_clk_o  ( ddr_link_clk_o        ),
      .ddr_i          ( ddr_link_i            ),
      .ddr_o          ( ddr_link_o            ),
      .isolated_i     ( '0                    ),
      .isolate_o      (                       ),
      .clk_ena_o      (                       ),
      .reset_no       (                       )
    );

  end : gen_serial_link else begin : gen_serial_link_dummy

    assign ddr_link_clk_o = '1;
    assign ddr_link_o = '0;

    assign axi_xbar_slv_port_reqs[AxiXbarInSerialLink] = '0;

    axi_err_slv #(
      .AxiIdWidth ( AxiXbarSlaveIdWidth       ),
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
      .slv_req_i  ( axi_xbar_mst_port_reqs[AxiXbarOutSerialLink] ),
      .slv_resp_o ( axi_xbar_mst_port_rsps[AxiXbarOutSerialLink] )
    );

    reg_err_slv #(
      .DW      ( 32                 ),
      .ERR_VAL ( 32'hBADCAB1E       ),
      .req_t   ( reg_a48_d32_req_t  ),
      .rsp_t   ( reg_a48_d32_rsp_t  )
    ) i_reg_err_slv_ddr_link (
      .req_i   ( regbus_out_req[RegbusOutSerialLink] ),
      .rsp_o   ( regbus_out_rsp[RegbusOutSerialLink] )
    );

  end : gen_serial_link_dummy

  //////////////////////
  //  VGA Controller  //
  //////////////////////

  if(CheshireCfg.Vga) begin : gen_vga

    axi_vga #(
      .RedWidth       ( CheshireCfg.VgaRedWidth   ),
      .GreenWidth     ( CheshireCfg.VgaGreenWidth ),
      .BlueWidth      ( CheshireCfg.VgaBlueWidth  ),
      .HCountWidth    ( 32                        ),
      .VCountWidth    ( 32                        ),
      .AXIAddrWidth   ( AxiAddrWidth              ),
      .AXIDataWidth   ( AxiDataWidth              ),
      .AXIStrbWidth   ( AxiStrbWidth              ),
      .axi_req_t      ( axi_a48_d64_mst_u0_req_t  ),
      .axi_resp_t     ( axi_a48_d64_mst_u0_resp_t ),
      .reg_req_t      ( reg_a48_d32_req_t         ),
      .reg_resp_t     ( reg_a48_d32_rsp_t         )
    ) i_axi_vga (
      .clk_i,
      .rst_ni,
      .test_mode_en_i ( testmode_i                      ),
      .reg_req_i      ( regbus_out_req[RegbusOutVga]    ),
      .reg_rsp_o      ( regbus_out_rsp[RegbusOutVga]    ),
      .axi_req_o      ( axi_xbar_slv_port_reqs[AxiXbarInVga] ),
      .axi_resp_i     ( axi_xbar_slv_port_rsps[AxiXbarInVga] ),
      .hsync_o        ( vga_hsync_o                     ),
      .vsync_o        ( vga_vsync_o                     ),
      .red_o          ( vga_red_o                       ),
      .green_o        ( vga_green_o                     ),
      .blue_o         ( vga_blue_o                      )
    );

  end : gen_vga else begin : gen_vga_dummy

    assign axi_xbar_slv_port_reqs[AxiXbarInVga] = '0;

    assign vga_hsync_o  = '0;
    assign vga_vsync_o  = '0;
    assign vga_red_o    = '0;
    assign vga_green_o  = '0;
    assign vga_blue_o   = '0;

    reg_err_slv #(
      .DW      ( 32                 ),
      .ERR_VAL ( 32'hBADCAB1E       ),
      .req_t   ( reg_a48_d32_req_t  ),
      .rsp_t   ( reg_a48_d32_rsp_t  )
    ) i_reg_err_slv_vga (
      .req_i   ( regbus_out_req[RegbusOutVga] ),
      .rsp_o   ( regbus_out_rsp[RegbusOutVga] )
    );

  end : gen_vga_dummy

  //////////////////////
  //  DMA Controller  //
  //////////////////////

  if(CheshireCfg.Dma) begin : gen_dma

    AXI_BUS #(
      .AXI_ADDR_WIDTH ( AxiAddrWidth          ),
      .AXI_DATA_WIDTH ( AxiDataWidth          ),
      .AXI_ID_WIDTH   ( AxiXbarSlaveIdWidth   ),
      .AXI_USER_WIDTH ( AxiUserWidth          )
    ) axi_xbar_atomics_dma ();

    AXI_BUS #(
      .AXI_ADDR_WIDTH ( AxiAddrWidth          ),
      .AXI_DATA_WIDTH ( AxiDataWidth          ),
      .AXI_ID_WIDTH   ( AxiXbarSlaveIdWidth   ),
      .AXI_USER_WIDTH ( AxiUserWidth          )
    ) axi_atomics_dma_wrap ();

    AXI_BUS #(
      .AXI_ADDR_WIDTH ( AxiAddrWidth          ),
      .AXI_DATA_WIDTH ( AxiDataWidth          ),
      .AXI_ID_WIDTH   ( AxiXbarMasterIdWidth  ),
      .AXI_USER_WIDTH ( AxiUserWidth          )
    ) dma_wrap_axi_xbar ();

    axi_a48_d64_slv_u0_req_t axi_xbar_atomics_dma_req;
    axi_a48_d64_slv_u0_resp_t axi_xbar_atomics_dma_rsp;

    axi_a48_d64_mst_u0_req_t dma_wrap_axi_xbar_req;
    axi_a48_d64_mst_u0_resp_t dma_wrap_axi_xbar_rsp;

    assign axi_xbar_atomics_dma_req = axi_xbar_mst_port_reqs[AxiXbarOutDmaConf];
    assign axi_xbar_mst_port_rsps[AxiXbarOutDmaConf] = axi_xbar_atomics_dma_rsp;

    // From XBar to atomics wrap
    `AXI_ASSIGN_FROM_REQ(axi_xbar_atomics_dma, axi_xbar_atomics_dma_req)
    `AXI_ASSIGN_TO_RESP(axi_xbar_atomics_dma_rsp, axi_xbar_atomics_dma)

    // From DMA wrap to XBar
    `AXI_ASSIGN_TO_REQ(dma_wrap_axi_xbar_req, dma_wrap_axi_xbar)
    `AXI_ASSIGN_FROM_RESP(dma_wrap_axi_xbar, dma_wrap_axi_xbar_rsp)

    assign axi_xbar_slv_port_reqs[AxiXbarInDma] = dma_wrap_axi_xbar_req;
    assign dma_wrap_axi_xbar_rsp = axi_xbar_slv_port_rsps[AxiXbarInDma];

    axi_riscv_atomics_wrap #(
      .AXI_ADDR_WIDTH     ( AxiAddrWidth        ),
      .AXI_DATA_WIDTH     ( AxiDataWidth        ),
      .AXI_ID_WIDTH       ( AxiXbarSlaveIdWidth ),
      .AXI_USER_WIDTH     ( AxiUserWidth        ),
      .AXI_MAX_READ_TXNS  ( 4                   ),
      .AXI_MAX_WRITE_TXNS ( 4                   ),
      .AXI_USER_AS_ID     ( 1'b1                ),
      .AXI_USER_ID_MSB    ( 0                   ),
      .AXI_USER_ID_LSB    ( 0                   ),
      .RISCV_WORD_WIDTH   ( 64                  )
    ) i_axi_riscv_atomics_dma (
      .clk_i,
      .rst_ni,
      .mst                ( axi_atomics_dma_wrap.Master ),
      .slv                ( axi_xbar_atomics_dma.Slave  )
    );

    dma_core_wrap #(
      .AXI_ADDR_WIDTH   ( AxiAddrWidth          ),
      .AXI_DATA_WIDTH   ( AxiDataWidth          ),
      .AXI_USER_WIDTH   ( AxiUserWidth          ),
      .AXI_ID_WIDTH     ( AxiXbarMasterIdWidth  ),
      .AXI_SLV_ID_WIDTH ( AxiXbarSlaveIdWidth   )
    ) i_dma_core_wrap (
      .clk_i,
      .rst_ni,
      .testmode_i,
      .axi_master       ( dma_wrap_axi_xbar.Master    ),
      .axi_slave        ( axi_atomics_dma_wrap.Slave  )
    );

  end : gen_dma else begin : gen_dma_dummy

    assign axi_xbar_slv_port_reqs[AxiXbarInDma] = '0;

    axi_err_slv #(
      .AxiIdWidth ( AxiXbarSlaveIdWidth       ),
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
      .slv_req_i  ( axi_xbar_mst_port_reqs[AxiXbarOutDmaConf] ),
      .slv_resp_o ( axi_xbar_mst_port_rsps[AxiXbarOutDmaConf] )
    );

  end : gen_dma_dummy

  /////////
  // LLC //
  /////////

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth          ),
    .AXI_DATA_WIDTH ( AxiDataWidth          ),
    .AXI_ID_WIDTH   ( AxiXbarSlaveIdWidth   ),
    .AXI_USER_WIDTH ( AxiUserWidth          )
  ) axi_xbar_atomics_dram();

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth          ),
    .AXI_DATA_WIDTH ( AxiDataWidth          ),
    .AXI_ID_WIDTH   ( AxiXbarSlaveIdWidth   ),
    .AXI_USER_WIDTH ( AxiUserWidth          )
  ) axi_dram_out();

  `AXI_ASSIGN_FROM_REQ(axi_xbar_atomics_dram, axi_xbar_mst_port_reqs[AxiXbarOutLlc])
  `AXI_ASSIGN_TO_RESP(axi_xbar_mst_port_rsps[AxiXbarOutLlc], axi_xbar_atomics_dram)

  `AXI_ASSIGN_TO_REQ(axi_atomics_to_llc_req, axi_dram_out)
  `AXI_ASSIGN_FROM_RESP(axi_dram_out, axi_atomics_to_llc_rsp)

  axi_a48_d64_slv_u0_req_t  axi_atomics_to_llc_req;
  axi_a48_d64_slv_u0_resp_t axi_atomics_to_llc_rsp;

  axi_a48_d64_mst_u0_llc_req_t  llc_to_dram_req;
  axi_a48_d64_mst_u0_llc_resp_t llc_to_dram_rsp;

  axi_riscv_atomics_wrap #(
    .AXI_ADDR_WIDTH     ( AxiAddrWidth        ),
    .AXI_DATA_WIDTH     ( AxiDataWidth        ),
    .AXI_ID_WIDTH       ( AxiXbarSlaveIdWidth ),
    .AXI_USER_WIDTH     ( AxiUserWidth        ),
    .AXI_MAX_READ_TXNS  ( 4                   ),
    .AXI_MAX_WRITE_TXNS ( 4                   ),
    .AXI_USER_AS_ID     ( 1'b1                ),
    .AXI_USER_ID_MSB    ( 0                   ),
    .AXI_USER_ID_LSB    ( 0                   ),
    .RISCV_WORD_WIDTH   ( 64                  )
  ) i_axi_riscv_atomics_dram (
    .clk_i,
    .rst_ni,
    .mst                ( axi_dram_out.Master         ),
    .slv                ( axi_xbar_atomics_dram.Slave )
  );

  axi_llc_reg_wrap #(
    .SetAssociativity    ( 3                              ),
    .NumLines            ( 256                            ),
    .NumBlocks           ( 4                              ),
    .AxiIdWidth          ( AxiXbarSlaveIdWidth            ),
    .AxiAddrWidth        ( AxiAddrWidth                   ),
    .AxiDataWidth        ( AxiDataWidth                   ),
    .AxiUserWidth        ( AxiUserWidth                   ),
    .slv_req_t           ( axi_a48_d64_slv_u0_req_t       ),
    .slv_resp_t          ( axi_a48_d64_slv_u0_resp_t      ),
    .mst_req_t           ( axi_a48_d64_mst_u0_llc_req_t   ),
    .mst_resp_t          ( axi_a48_d64_mst_u0_llc_resp_t  ),
    .reg_req_t           ( reg_a48_d32_req_t              ),
    .reg_resp_t          ( reg_a48_d32_rsp_t              ),
    .rule_full_t         ( address_rule_48_t              )
  ) i_axi_llc_reg_wrap (
    .clk_i,
    .rst_ni,
    .test_i              ( testmode_i                                 ),
    .slv_req_i           ( axi_atomics_to_llc_req                     ),
    .slv_resp_o          ( axi_atomics_to_llc_rsp                     ),
    .mst_req_o           ( llc_to_dram_req                            ),
    .mst_resp_i          ( llc_to_dram_rsp                            ),
    .conf_req_i          ( regbus_out_req[RegbusOutLlc]               ),
    .conf_resp_o         ( regbus_out_rsp[RegbusOutLlc]               ),
    .cached_start_addr_i ( AxiXbarAddrmap[AxiXbarOutLlc+1].start_addr ),
    .cached_end_addr_i   ( AxiXbarAddrmap[AxiXbarOutLlc+1].end_addr   ),
    .spm_start_addr_i    ( AxiXbarAddrmap[AxiXbarOutLlc].start_addr   ),
    .axi_llc_events_o    ( /* TODO: connect me to CSRs? */            )
  );

  //////////
  // DRAM //
  //////////

  if(CheshireCfg.Dram) begin : gen_dram

    // Connect the external DRAM signals
    assign dram_req_o = llc_to_dram_req;
    assign llc_to_dram_rsp = dram_resp_i;

  end : gen_dram else begin : gen_dram_dummy

    assign dram_req_o = '0;

    axi_err_slv #(
      .AxiIdWidth ( AxiXbarSlaveIdWidth           ),
      .axi_req_t  ( axi_a48_d64_mst_u0_llc_req_t  ),
      .axi_resp_t ( axi_a48_d64_mst_u0_llc_resp_t ),
      .RespWidth  ( 64                            ),
      .RespData   ( 64'hCA11AB1EBADCAB1E          ),
      .ATOPs      ( 1'b1                          ),
      .MaxTrans   ( 1                             )
    ) i_axi_err_slv_dram (
      .clk_i,
      .rst_ni,
      .test_i     ( testmode_i      ),
      .slv_req_i  ( llc_to_dram_req ),
      .slv_resp_o ( llc_to_dram_rsp )
    );

  end : gen_dram_dummy

  //////////////
  //  Regbus  //
  //////////////

  logic [cf_math_pkg::idx_width(RegbusNumOutputs)-1:0] regbus_select;

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth          ),
    .AXI_DATA_WIDTH ( AxiDataWidth          ),
    .AXI_ID_WIDTH   ( AxiXbarSlaveIdWidth   ),
    .AXI_USER_WIDTH ( AxiUserWidth          )
  ) axi_xbar_atomics_regbus();

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth          ),
    .AXI_DATA_WIDTH ( AxiDataWidth          ),
    .AXI_ID_WIDTH   ( AxiXbarSlaveIdWidth   ),
    .AXI_USER_WIDTH ( AxiUserWidth          )
  ) axi_atomics_dw_conv();

  axi_a48_d64_slv_u0_req_t  axi_xbar_atomics_req;
  axi_a48_d64_slv_u0_resp_t axi_xbar_atomics_rsp;

  axi_a48_d64_slv_u0_req_t  axi_atomics_dw_conv_req;
  axi_a48_d64_slv_u0_resp_t axi_atomics_dw_conv_rsp;

  axi_a48_d32_slv_u0_req_t axi_dw_conv_to_req;
  axi_a48_d32_slv_u0_resp_t axi_dw_conv_to_rsp;

  reg_a48_d32_req_t  regbus_in_req;
  reg_a48_d32_rsp_t  regbus_in_rsp;

  // From XBar to Atomics Wrap
  `AXI_ASSIGN_FROM_REQ(axi_xbar_atomics_regbus, axi_xbar_atomics_req)
  `AXI_ASSIGN_TO_RESP(axi_xbar_atomics_rsp, axi_xbar_atomics_regbus)

  // From Atomics Wrap to DW Converter
  `AXI_ASSIGN_TO_REQ(axi_atomics_dw_conv_req, axi_atomics_dw_conv)
  `AXI_ASSIGN_FROM_RESP(axi_atomics_dw_conv, axi_atomics_dw_conv_rsp)

  assign axi_xbar_atomics_req = axi_xbar_mst_port_reqs[AxiXbarOutRegbus];
  assign axi_xbar_mst_port_rsps[AxiXbarOutRegbus] = axi_xbar_atomics_rsp;

  axi_riscv_atomics_wrap #(
    .AXI_ADDR_WIDTH     ( AxiAddrWidth        ),
    .AXI_DATA_WIDTH     ( AxiDataWidth        ),
    .AXI_ID_WIDTH       ( AxiXbarSlaveIdWidth ),
    .AXI_USER_WIDTH     ( AxiUserWidth        ),
    .AXI_MAX_READ_TXNS  ( 4                   ),
    .AXI_MAX_WRITE_TXNS ( 4                   ),
    .AXI_USER_AS_ID     ( 1'b1                ),
    .AXI_USER_ID_MSB    ( 0                   ),
    .AXI_USER_ID_LSB    ( 0                   ),
    .RISCV_WORD_WIDTH   ( 64                  )
  ) i_axi_riscv_atomics_regbus (
    .clk_i,
    .rst_ni,
    .mst                ( axi_atomics_dw_conv.Master ),
    .slv                ( axi_xbar_atomics_regbus.Slave )
  );

  axi_dw_converter #(
    .AxiSlvPortDataWidth  ( AxiDataWidth                 ),
    .AxiMstPortDataWidth  ( 32                           ),
    .AxiAddrWidth         ( AxiAddrWidth                 ),
    .AxiIdWidth           ( AxiXbarSlaveIdWidth          ),
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
  ) i_axi_dw_converter_regbus (
    .clk_i,
    .rst_ni,
    .slv_req_i            ( axi_atomics_dw_conv_req      ),
    .slv_resp_o           ( axi_atomics_dw_conv_rsp      ),
    .mst_req_o            ( axi_dw_conv_to_req           ),
    .mst_resp_i           ( axi_dw_conv_to_rsp           )
  );

  axi_to_reg #(
    .ADDR_WIDTH         ( AxiAddrWidth              ),
    .DATA_WIDTH         ( 32                        ),
    .ID_WIDTH           ( AxiXbarSlaveIdWidth       ),
    .USER_WIDTH         ( AxiUserWidth              ),
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
    .axi_req_i          ( axi_dw_conv_to_req  ),
    .axi_rsp_o          ( axi_dw_conv_to_rsp  ),
    .reg_req_o          ( regbus_in_req       ),
    .reg_rsp_i          ( regbus_in_rsp       )
  );

  addr_decode #(
    .NoIndices        ( RegbusNumOutputs    ),
    .NoRules          ( RegbusNumOutputs    ), // Assume one rule per peripheral
    .addr_t           ( logic [47:0]        ),
    .rule_t           ( address_rule_48_t   )
  ) i_addr_decode_regbus (
    .addr_i           ( regbus_in_req.addr  ),
    .addr_map_i       ( RegbusAddrmap       ),
    .idx_o            ( regbus_select       ),
    .dec_valid_o      (                     ),
    .dec_error_o      (                     ),
    .en_default_idx_i ( '0                  ),
    .default_idx_i    ( '0                  )
  );

  reg_demux #(
    .NoPorts      ( RegbusNumOutputs    ),
    .req_t        ( reg_a48_d32_req_t   ),
    .rsp_t        ( reg_a48_d32_rsp_t   )
  ) i_soc_regbus (
    .clk_i,
    .rst_ni,
    .in_select_i  ( regbus_select  ),
    .in_req_i     ( regbus_in_req  ),
    .in_rsp_o     ( regbus_in_rsp  ),
    .out_req_o    ( regbus_out_req ),
    .out_rsp_i    ( regbus_out_rsp )
  );

  ////////////
  //  UART  //
  ////////////

  if(CheshireCfg.Uart) begin : gen_uart

    reg_uart_wrap #(
      .AddrWidth  ( AxiAddrWidth      ),
      .reg_req_t  ( reg_a48_d32_req_t ),
      .reg_rsp_t  ( reg_a48_d32_rsp_t )
    ) i_uart (
      .clk_i,
      .rst_ni,
      .reg_req_i  ( regbus_out_req[RegbusOutUart] ),
      .reg_rsp_o  ( regbus_out_rsp[RegbusOutUart] ),
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

  end : gen_uart else begin : gen_uart_dummy

    // Bind UART output to 0
    assign uart_tx_o  = '0;

    // Bind UART interrupt to 0
    assign irq.uart   = '0;

    reg_err_slv #(
      .DW      ( 32                 ),
      .ERR_VAL ( 32'hBADCAB1E       ),
      .req_t   ( reg_a48_d32_req_t  ),
      .rsp_t   ( reg_a48_d32_rsp_t  )
    ) i_reg_err_slv_uart (
      .req_i   ( regbus_out_req[RegbusOutUart] ),
      .rsp_o   ( regbus_out_rsp[RegbusOutUart] )
    );

  end : gen_uart_dummy

  ///////////
  //  I2C  //
  ///////////

  if(CheshireCfg.I2c) begin : gen_i2c

    i2c #(
      .reg_req_t                ( reg_a48_d32_req_t        ),
      .reg_rsp_t                ( reg_a48_d32_rsp_t        )
    ) i_i2c (
      .clk_i,
      .rst_ni,
      .reg_req_i                ( regbus_out_req[RegbusOutI2c] ),
      .reg_rsp_o                ( regbus_out_rsp[RegbusOutI2c] ),
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

  end : gen_i2c else begin : gen_i2c_dummy

    // Bind I2C outputs to 0
    assign i2c_scl_o    = '0;
    assign i2c_scl_en_o = '0;
    assign i2c_sda_o    = '0;
    assign i2c_sda_en_o = '0;

    // Bind I2C interrupts to 0
    assign irq.i2c_fmt_watermark    = '0;
    assign irq.i2c_rx_watermark     = '0;
    assign irq.i2c_fmt_overflow     = '0;
    assign irq.i2c_rx_overflow      = '0;
    assign irq.i2c_nak              = '0;
    assign irq.i2c_scl_interference = '0;
    assign irq.i2c_sda_interference = '0;
    assign irq.i2c_stretch_timeout  = '0;
    assign irq.i2c_sda_unstable     = '0;
    assign irq.i2c_trans_complete   = '0;
    assign irq.i2c_tx_empty         = '0;
    assign irq.i2c_tx_nonempty      = '0;
    assign irq.i2c_tx_overflow      = '0;
    assign irq.i2c_acq_overflow     = '0;
    assign irq.i2c_ack_stop         = '0;
    assign irq.i2c_host_timeout     = '0;

    reg_err_slv #(
      .DW      ( 32                 ),
      .ERR_VAL ( 32'hBADCAB1E       ),
      .req_t   ( reg_a48_d32_req_t  ),
      .rsp_t   ( reg_a48_d32_rsp_t  )
    ) i_reg_err_slv_i2c (
      .req_i   ( regbus_out_req[RegbusOutI2c] ),
      .rsp_o   ( regbus_out_rsp[RegbusOutI2c] )
    );

  end : gen_i2c_dummy

  ////////////
  //  SPIM  //
  ////////////

  if(CheshireCfg.Spim) begin : gen_spi

    spi_host #(
      .reg_req_t        ( reg_a48_d32_req_t  ),
      .reg_rsp_t        ( reg_a48_d32_rsp_t  )
    ) i_spi_host (
      .clk_i,
      .rst_ni,
      .clk_core_i       ( clk_i              ),
      .rst_core_ni      ( rst_ni             ),
      .reg_req_i        ( regbus_out_req[RegbusOutSpim] ),
      .reg_rsp_o        ( regbus_out_rsp[RegbusOutSpim] ),
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

  end : gen_spi else begin : gen_spi_dummy

    // Bind SPI outputs to 0
    assign spi_sck_o      = '0;
    assign spim_sck_en_o  = '0;
    assign spim_csb       = '1;
    assign spim_csb_en_o  = '0;
    assign spim_sd_o      = '0;
    assign spim_sd_en_o   = '0;

    // Bind SPI interrupts to 0
    assign irq.spim_error     = '0;
    assign irq.spim_spi_event = '0;

    reg_err_slv #(
      .DW      ( 32                 ),
      .ERR_VAL ( 32'hBADCAB1E       ),
      .req_t   ( reg_a48_d32_req_t  ),
      .rsp_t   ( reg_a48_d32_rsp_t  )
    ) i_reg_err_slv_spim (
      .req_i   ( regbus_out_req[RegbusOutSpim] ),
      .rsp_o   ( regbus_out_rsp[RegbusOutSpim] )
    );

  end : gen_spi_dummy

  /////////////////////
  //  Register File  //
  /////////////////////

  cheshire_reg_pkg::cheshire_hw2reg_t reg_file_in;

  assign reg_file_in.boot_mode.d               = boot_mode_i;
  assign reg_file_in.status.clock_lock.d       = clk_locked_i;
  assign reg_file_in.status.uart_present.d     = CheshireCfg.Uart;
  assign reg_file_in.status.spi_present.d      = CheshireCfg.Spim;
  assign reg_file_in.status.i2c_present.d      = CheshireCfg.I2c;
  assign reg_file_in.status.dma_present.d      = CheshireCfg.Dma;
  assign reg_file_in.status.ddr_link_present.d = CheshireCfg.SerialLink;
  assign reg_file_in.status.dram_present.d     = CheshireCfg.Dram;
  assign reg_file_in.status.vga_present.d      = CheshireCfg.Vga;
  assign reg_file_in.vga_red_width.d           = CheshireCfg.VgaRedWidth;
  assign reg_file_in.vga_green_width.d         = CheshireCfg.VgaGreenWidth;
  assign reg_file_in.vga_blue_width.d          = CheshireCfg.VgaBlueWidth;
  assign reg_file_in.reset_freq.d              = CheshireCfg.ResetFreq;

  cheshire_reg_top #(
    .reg_req_t  ( reg_a48_d32_req_t ),
    .reg_rsp_t  ( reg_a48_d32_rsp_t )
  ) i_cheshire_reg_file (
    .clk_i,
    .rst_ni,
    .reg_req_i  ( regbus_out_req[RegbusOutCsr] ),
    .reg_rsp_o  ( regbus_out_rsp[RegbusOutCsr] ),
    .hw2reg     ( reg_file_in       ),
    .devmode_i  ( 1'b1              )
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
    .reg_req_i  ( regbus_out_req[RegbusOutBootrom] ),
    .reg_rsp_o  ( regbus_out_rsp[RegbusOutBootrom] ),
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

  cheshire_bootrom #(
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

  // As the bootrom can answer in the same clock cycle the valid signal is
  // just the one clock cycle delayed version of the request signal
  `FF(rom_rvalid, rom_req, '0, clk_i, rst_ni)

  ////////////
  //  PLIC  //
  ////////////

  rv_plic #(
      .reg_req_t  ( reg_a48_d32_req_t ),
      .reg_rsp_t  ( reg_a48_d32_rsp_t )
  ) i_plic (
      .clk_i,
      .rst_ni,
      .reg_req_i  ( regbus_out_req[RegbusOutPlic] ),
      .reg_rsp_o  ( regbus_out_rsp[RegbusOutPlic] ),
      .intr_src_i ( irq               ),
      .irq_o      ( eip               ),
      .irq_id_o   (                   ),
      .msip_o     (                   )
  );

  // Interrupt ID 0 is a dummy interrupt meaning "no interrupt"
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
    .reg_req_i    ( regbus_out_req[RegbusOutClint] ),
    .reg_rsp_o    ( regbus_out_rsp[RegbusOutClint] ),
    .rtc_i        ( rtc_i             ),
    .timer_irq_o  ( mstip             ),
    .ipi_o        ( mssip             )
  );

endmodule
