`include "axi/assign.svh"

module cheshire_soc
  import cheshire_pkg::*;
(
  input   logic                       clk_i,
  input   logic                       rst_ni,

  input   logic                       testmode_i,

  // Boot address for CVA6
  input   logic                       boot_mode_i,

  // Boot address for CVA6
  input   logic [63:0]                boot_addr_i,

  // DDR-Link
  input   logic [3:0]                 ddr_link_i,
  output  logic [3:0]                 ddr_link_o,

  input   logic                       ddr_link_clk_i,
  output  logic                       ddr_link_clk_o

  // VGA Controller
  output  logic                       vga_hsync_o,
  output  logic                       vga_vsync_o,
  output  logic                       vga_red_o,
  output  logic                       vga_green_o,
  output  logic                       vga_blue_o,

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
    .ipi_i        ( msip[0]                                  ),
    .time_irq_i   ( mtip[0]                                  ),
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
    .ATOPs          ( 1'b1                          ),
    .Cfg            ( axi_xbar_cfg                  ),
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
    .en_default_mst_port_i  ( '1                         ),
    .default_mst_port_i     ( '0                         )
  );

  /////////////
  //  Debug  //
  /////////////

  // TODO

  ///////////////////
  //  Serial Link  //
  ///////////////////

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
    .slv_resp_o             ( axi_xbar_mst_port_rsps[AXI_XBAR_IN_DDR_LINK]  ),
    .mst_req_o              ( ddr_link_axi_in_req           ),
    .mst_resp_i             ( ddr_link_axi_in_rsp           )
  );

  serial_link #(
    .axi_req_t      ( axi_a48_d64_mst_u0_req_t        ),
    .axi_rsp_t      ( axi_a48_d64_mst_u0_resp_t       ),
    .cfg_req_t      ( reg_a48_d32_req_t               ),
    .cfg_rsp_t      ( reg_a48_d32_rsp_t               ),
    .aw_chan_t      ( axi_a48_d64_mst_u0_aw_chan_t    ),
    .ar_chan_t      ( axi_a48_d64_mst_u0_ar_chan_t    ),
    .r_chan_t       ( axi_a48_d64_mst_u0_r_chan_t     ),
    .w_chan_t       ( axi_a48_d64_mst_u0_w_chan_t     ),
    .b_chan_t       ( axi_a48_d64_mst_u0_b_chan_t     ),
    .hw2reg_t       ( serial_link_single_channel_reg_pkg::serial_link_single_channel_hw2reg_t ),
    .reg2hw_t       ( serial_link_single_channel_reg_pkg::serial_link_single_channel_reg2hw_t ),
    .NumChannels    ( 1                               ),
    .NumLanes       ( 4                               ),
    .MaxClkDiv      ( 1024                            )
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
    .axi_out_req_o  ( axi_xbar_slv_port_reqs[AXI_XBAR_IN_SERIAL_LINK]   ),
    .axi_out_rsp_i  ( axi_xbar_slv_port_rsps[AXI_XBAR_IN_SERIAL_LINK]   ),
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

  //////////////////////
  //  VGA Controller  //
  //////////////////////

  neo_vga #(
    .RedWidth       ( 3                         ),
    .GreenWidth     ( 3                         ),
    .BlueWidth      ( 2                         ),
    .HCountWidth    ( 32                        ),
    .VCountWidth    ( 32                        ),
    .axi_req_t      ( axi_a48_d64_mst_u0_req_t  ),
    .axi_resp_t     ( axi_a48_d64_mst_u0_resp_t ),
    .reg_req_t      ( reg_a48_d32_req_t         ),
    .reg_resp_t     ( reg_a48_d32_rsp_t         )
  ) i_neo_vga (
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

  //////////////////////
  //  DMA Controller  //
  //////////////////////

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( 48  ),
    .AXI_DATA_WIDTH ( 64  ),
    .AXI_ID_WIDTH   ( AXI_XBAR_MASTER_ID_WIDTH  ),
    .AXI_USER_WIDTH ( 1   )
  ) axi_xbar_atomics_dma ();

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( 48  ),
    .AXI_DATA_WIDTH ( 64  ),
    .AXI_ID_WIDTH   ( AXI_XBAR_MASTER_ID_WIDTH  ),
    .AXI_USER_WIDTH ( 1   )
  ) axi_atomics_to_reg ();

  axi_a48_d64_slv_u0_req_t axi_xbar_atomics_dma_req;
  axi_a48_d64_slv_u0_resp_t axi_xbar_atomics_dma_rsp;

  axi_a48_d64_slv_u0_req_t axi_atomics_to_reg_req;
  axi_a48_d64_slv_u0_resp_t axi_atomics_to_reg_rsp;

  // TODO 
  //`AXI_ASSIGN_(axi_xbar_atomics_dma, axi_xbar_atomics_dma_req)
  //`AXI_ASSIGN_(axi_xbar_atomics_dma, axi_xbar_atomics_dma_rsp)
  //`AXI_ASSIGN_FROM_REQ(axi_atomics_to_reg, axi_atomics_to_reg_req)
  //`AXI_ASSIGN_FROM_RESP(axi_atomics_to_reg, axi_atomics_to_reg_rsp)

  assign axi_xbar_slv_port_reqs[AXI_XBAR_IN_DMA] = axi_xbar_atomics_dma_req;
  assign axi_xbar_atomics_dma_rsp = axi_xbar_slv_port_rsps[AXI_XBAR_IN_DMA];

  reg_a48_d64_req_t idma_cfg_reg_req;
  reg_a48_d64_rsp_t idma_cfg_reg_rsp;

  axi_riscv_atomics_wrap #(
    .AXI_ADDR_WIDTH     ( 48                         ),
    .AXI_DATA_WIDTH     ( 64                         ),
    .AXI_ID_WIDTH       ( AXI_XBAR_SLAVE_ID_WIDTH    ),
    .AXI_USER_WIDTH     ( 1                          ),
    .AXI_MAX_READ_TXNS  ( 4                          ),
    .AXI_MAX_WRITE_TXNS ( 4                          ),
    .AXI_USER_AS_ID     ( 1'b1                       ),
    .AXI_USER_ID_MSB    ( 0                          ),
    .AXI_USER_ID_LSB    ( 0                          ),
    .RISCV_WORD_WIDTH   ( 64                         ),
    .AXI_STRB_WIDTH     ( 1                          )
  ) i_axi_riscv_atomics_dma (
    .clk_i,
    .rst_ni,
    .mst                ( axi_xbar_atomics_dma.Master  ), // TODO
    .slv                ( axi_atomics_to_reg.Slave   )  // TODO
  );

  axi_to_reg #(
    .ADDR_WIDTH  ( 48                        ),
    .DATA_WIDTH  ( 64                        ),
    .ID_WIDTH    ( AXI_XBAR_SLAVE_ID_WIDTH   ),
    .USER_WIDTH  ( 1                         ),
    .axi_req_t   ( axi_a48_d64_slv_u0_req_t  ),
    .axi_rsp_t   ( axi_a48_d64_slv_u0_resp_t ),
    .reg_req_t   ( reg_a48_d64_req_t         ),
    .reg_rsp_t   ( reg_a48_d64_rsp_t         )
  ) i_axi_to_reg_idma_cfg (
    .clk_i,
    .rst_ni,
    .testmode_i  ( testmode_i                ),
    .axi_req_i   ( axi_atomics_to_reg_req    ),
    .axi_rsp_o   ( axi_atomics_to_reg_rsp    ),
    .reg_req_o   ( idma_cfg_reg_req          ),
    .reg_rsp_i   ( idma_cfg_reg_rsp          )
  );

  idma_reg64_frontend #(
    .DmaAddrWidth      ( 'd48                   ),
    .dma_regs_req_t    ( reg_a48_d64_req_t      ),
    .dma_regs_rsp_t    ( reg_a48_d64_rsp_t      ),
    .burst_req_t       ( idma_burst_req_t       )
  ) i_idma_reg64_frontend (
    .clk_i,
    .rst_ni,
    .dma_ctrl_req_i    ( idma_cfg_reg_req       ),
    .dma_ctrl_rsp_o    ( idma_cfg_reg_rsp       ),
    .burst_req_o       ( idma_burst_req         ),
    .valid_o           ( idma_be_valid          ),
    .ready_i           ( idma_be_ready          ),
    .backend_idle_i    ( idma_be_idle           ),
    .trans_complete_i  ( idma_be_trans_complete )
  );

  axi_dma_backend #(
    .DataWidth         ( 64                        ),
    .AddrWidth         ( 48                        ),
    .IdWidth           ( AXI_XBAR_MASTER_ID_WIDTH  ),
    .AxReqFifoDepth    ( 'd8                       ),
    .TransFifoDepth    ( 'd8                       ),
    .BufferDepth       ( 'd3                       ),
    .axi_req_t         ( axi_a48_d64_mst_u0_req_t  ),
    .axi_res_t         ( axi_a48_d64_mst_u0_resp_t ),
    .burst_req_t       ( idma_burst_req_t          ),
    .DmaIdWidth        ( 'd32                      ),
    .DmaTracing        ( 1'b1                      )
  ) i_axi_dma_backend (
    .clk_i,
    .rst_ni,
    .dma_id_i          ( 'd0                       ),
    .axi_dma_req_o     ( dma_xbar_req              ),
    .axi_dma_res_i     ( dma_xbar_resp             ),
    .burst_req_i       ( idma_burst_req            ),
    .valid_i           ( idma_be_valid             ),
    .ready_o           ( idma_be_ready             ),
    .backend_idle_o    ( idma_be_idle              ),
    .trans_complete_o  ( idma_be_trans_complete    )
  );


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
  //  Regbus  //
  //////////////

  logic [cf_math_pkg::idx_width(REGBUS_PERIPH_NUM_OUTPUTS)-1:0] regbus_periph_select; // TODO

  AXI_BUS axi_xbar_atomics_regbus();
  AXI_BUS axi_atomics_dw_conv();

  axi_a48_d64_slv_u0_req_t  axi_xbar_atomics_req;
  axi_a48_d64_slv_u0_resp_t axi_xbar_atomics_rsp;

  axi_a48_d64_slv_u0_req_t  axi_atomics_dw_conv_req;
  axi_a48_d64_slv_u0_resp_t axi_atomics_dw_conv_rsp;

  // TODO
  //`AXI_ASSIGN_TO_REQ(axi_xbar_atomics, axi_xbar_atomics_req)
  //`AXI_ASSIGN_TO_RESP(axi_xbar_atomics, axi_xbar_atomics_rsp)

  //`AXI_ASSIGN_FROM_REQ(axi_atomics_dw_conv, axi_atomics_dw_conv_req)
  //`AXI_ASSIGN_FROM_RESP(axi_atomics_dw_conv, axi_atomics_dw_conv_rsp)

  assign axi_xbar_atomics_req = axi_xbar_mst_port_reqs[AXI_XBAR_OUT_REGBUS];
  assign axi_xbar_mst_port_rsps[AXI_XBAR_OUT_REGBUS] = axi_xbar_atomics_rsp;

  axi_riscv_atomics_wrap #(
    .AXI_ADDR_WIDTH     ( 48                         ),
    .AXI_DATA_WIDTH     ( 64                         ),
    .AXI_ID_WIDTH       ( AXI_XBAR_SLAVE_ID_WIDTH    ),
    .AXI_USER_WIDTH     ( 1                          ),
    .AXI_MAX_READ_TXNS  ( 4                          ),
    .AXI_MAX_WRITE_TXNS ( 4                          ),
    .AXI_USER_AS_ID     ( 1'b1                       ),
    .AXI_USER_ID_MSB    ( 0                          ),
    .AXI_USER_ID_LSB    ( 0                          ),
    .RISCV_WORD_WIDTH   ( 64                         ),
    .AXI_STRB_WIDTH     ( 1                          )
  ) i_axi_riscv_atomics_regbus (
    .clk_i,
    .rst_ni,
    .mst                ( axi_xbar_atomics_regbus.Master ), // TODO
    .slv                ( axi_atomics_dw_conv.Slave  )      // TODO
  );

  axi_dw_converter #(
	  .AxiSlvPortDataWidth  ( 64                           ),
	  .AxiMstPortDataWidth  ( 32                           ),
    .AxiAddrWidth         ( 48                           ),
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
	  .ADDR_WIDTH         ( 48                        ),
	  .DATA_WIDTH         ( 32                        ),
	  .ID_WIDTH           ( AXI_XBAR_SLAVE_ID_WIDTH   ),
	  .USER_WIDTH         ( 1                         ),
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
    .addr_map_i       ( RegbusPeriphAddrmap       ),
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

  ///////////
  //  I2C  //
  ///////////

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

  ////////////
  //  SPIM  //
  ////////////

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
    .timer_irq_o  ( mtip              ), 
    .ipi_o        ( msip              ) 
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