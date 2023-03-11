// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

`include "axi/assign.svh"
`include "common_cells/registers.svh"
`include "common_cells/assert.svh"

module cheshire_soc import cheshire_pkg::*; #(
  // Cheshire config
  parameter cheshire_cfg_t CheshireCfg = '0,
  // CVA6 config (must agree with Cheshire config)
  parameter ariane_pkg::ariane_cfg_t Cva6Cfg = '0,
  // Debug info for external harts
  parameter dm::hartinfo_t [iomsb(Cfg.NumExtDbgHarts)-1:0] ExtHartinfo = '0,
  // Interconnect types (must agree with Cheshire config)
  parameter type axi_ext_mst_req_t  = logic,
  parameter type axi_ext_mst_rsp_t  = logic,
  parameter type axi_llc_mst_req_t  = logic,
  parameter type axi_llc_mst_rsp_t  = logic,
  parameter type axi_ext_slv_req_t  = logic,
  parameter type axi_ext_slv_rsp_t  = logic,
  parameter type reg_ext_req_t      = logic,
  parameter type reg_ext_rsp_t      = logic
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        test_mode_i,
  input  logic [1:0]  boot_mode_i,
  input  logic        rtc_i,
  // External AXI LLC (DRAM) port
  output axi_llc_mst_req_t axi_llc_mst_req_o,
  input  axi_llc_mst_rsp_t axi_llc_mst_rsp_i,
  // External AXI crossbar ports
  output axi_ext_mst_req_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_req_o,
  input  axi_ext_mst_rsp_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_rsp_i,
  input  axi_slv_req_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_req_i,
  output axi_slv_rsp_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_rsp_o,
  // External reg demux slaves
  input  reg_ext_req_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_req_i,
  output reg_ext_rsp_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_rsp_o,
  // Interrupts from external devices
  input  logic [iomsb(Cfg.NumExtIntrs):0] intr_ext_i
  // Interrupts to external harts
  output logic [iomsb(Cfg.NumExtIrqHarts):0] meip_ext_o,
  output logic [iomsb(Cfg.NumExtIrqHarts):0] mtip_ext_o,
  output logic [iomsb(Cfg.NumExtIrqHarts):0] msip_ext_o,
  // Debug interface to external harts
  output logic                                dbg_active_o,
  output logic [iomsb(Cfg.NumExtDbgHarts):0]  dbg_ext_req_o,
  input  logic [iomsb(Cfg.NumExtDbgHarts):0]  dbg_ext_unavail_i,
  // JTAG interface
  input  logic  jtag_tck_i,
  input  logic  jtag_trst_ni,
  input  logic  jtag_tms_i,
  input  logic  jtag_tdi_i,
  output logic  jtag_tdo_o,
  output logic  jtag_tdo_oe_o,
  // UART interface
  output logic  uart_tx_o,
  input  logic  uart_rx_i,
  // UART Modem flow control
  output logic  uart_rts_no,
  output logic  uart_dtr_no,
  input  logic  uart_cts_ni,
  input  logic  uart_dsr_ni,
  input  logic  uart_dcd_ni,
  input  logic  uart_rin_ni,
  // I2C interface
  output logic  i2c_sda_o,
  input  logic  i2c_sda_i,
  output logic  i2c_sda_en_o,
  output logic  i2c_scl_o,
  input  logic  i2c_scl_i,
  output logic  i2c_scl_en_o,
  // SPI host interface
  output logic                  spih_sck_o,
  output logic                  spih_sck_en_o,
  output logic [SpihNumCs-1:0]  spih_csb_o,
  output logic [SpihNumCs-1:0]  spih_csb_en_o,
  output logic [ 3:0]           spih_sd_o,
  output logic [ 3:0]           spih_sd_en_o,
  input  logic [ 3:0]           spih_sd_i,
  // GPIO interface
  input  logic [31:0] gpio_i,
  output logic [31:0] gpio_o,
  output logic [31:0] gpio_en_o,
  // Serial link interface
  input  logic [SlinkNumChan-1:0]                   slink_rcv_clk_i,
  output logic [SlinkNumChan-1:0]                   slink_rcv_clk_o,
  input  logic [SlinkNumChan-1:0][SlinkNumBits-1:0] slink_i,
  output logic [SlinkNumChan-1:0][SlinkNumBits-1:0] slink_o,
  // VGA interface
  output logic                          vga_hsync_o,
  output logic                          vga_vsync_o,
  output logic [Cfg.VgaRedWidth  -1:0]  vga_red_o,
  output logic [Cfg.VgaGreenWidth-1:0]  vga_green_o,
  output logic [Cfg.VgaBlueWidth -1:0]  vga_blue_o
);

  //////////////////
  //  Interrupts  //
  //////////////////

  localparam int unsigned NumIntHarts = 1 + Cfg.DualCore;
  localparam int unsigned NumIrqHarts = NumIntHarts + Cfg.NumExtIrqHarts;

  cheshire_intr_t       intr;
  logic [NumIrqHarts-1:0]  irq, time_irq, ipi;

  // Collect external interrupts
  assign intr.ext   = intr_ext_i;
  assign intr.zero  = 0;

  // Forward IRQs to external interruptible harts if any
  if (Cfg.NumExtIrqHarts != 0) begin : gen_ext_irqs
    assign meip_ext_o = irq      [NumIrqHarts-1:NumIntHarts];
    assign mtip_ext_o = time_irq [NumIrqHarts-1:NumIntHarts];
    assign msip_ext_o = ipi      [NumIrqHarts-1:NumIntHarts];
  end else begin : gen_no_ext_irqs
    assign meip_ext_o = '0;
    assign mtip_ext_o = '0;
    assign msip_ext_o = '0;
  end

  /////////////////////
  //  Interconnnect  //
  /////////////////////

  localparam AxiInCores


  // We assume that all internal cores share one port
  localparam int unsigned AxiNumMst     = 2 + AxiExtNumMst;
  localparam int unsigned AxiStrbWidth  = Cfg.AxiDataWidth;
  localparam int unsigned AxiSlvIdWidth = 0;

  localparam type aidx_t      = logic [7:0];
  localparam type addr_t      = logic [AddrWidth-1:0];
  localparam type axi_data_t  = logic [Cfg.AxiDataWidth-1:0];
  localparam type axi_strb_t  = logic [AxiStrbWidth-1:0];
  localparam type axi_strb_t  = logic [CfgAxiStrbWidth-1:0];

  `AXI_TYPEDEF_ALL(axi_mst, addr_t, logic [AxiXbarMasterIdWidth-1:0], axi_data_t, axi_strb_t, logic [0:0])




  typedef struct packed {
    aidx_t idx;
    addr_t start_addr;
    addr_t end_addr;
  } addr_rule_t;

  axi_xbar #(
    .Cfg            ( AxiXbarCfg ),
    .ATOPs          ( 1  ),
    .Connectivity   ( '1 ),
    .slv_aw_chan_t  ( axi_mst_aw_chan_t ),
    .mst_aw_chan_t  ( axi_slv_aw_chan_t ),
    .w_chan_t       ( axi_mst_w_chan_t  ),
    .slv_b_chan_t   ( axi_mst_b_chan_t  ),
    .mst_b_chan_t   ( axi_slv_b_chan_t  ),
    .slv_ar_chan_t  ( axi_mst_ar_chan_t ),
    .mst_ar_chan_t  ( axi_slv_ar_chan_t ),
    .slv_r_chan_t   ( axi_mst_r_chan_t  ),
    .mst_r_chan_t   ( axi_slv_r_chan_t  ),
    .slv_req_t      ( axi_mst_req_t ),
    .slv_resp_t     ( axi_mst_rsp_t ),
    .mst_req_t      ( axi_slv_req_t ),
    .mst_resp_t     ( axi_slv_rsp_t ),
    .rule_t         ( addr_rule_t )
  ) i_axi_xbar (
    .clk_i,
    .rst_ni,
    .test_i                 ( test_mode_i ),
    .slv_ports_req_i        ( axi_in_req  ),
    .slv_ports_resp_o       ( axi_in_rsp  ),
    .mst_ports_req_o        ( axi_out_req ),
    .mst_ports_resp_i       ( axi_out_rsp ),
    .addr_map_i             ( AxiXbarAddrmap ),
    .en_default_mst_port_i  ( '0 ),
    .default_mst_port_i     ( '0 )
  );




















  // TODO: ensure that every master gets its atomics user range mapped!

  // TODO




  // TODO
  localparam addr_t BaseDbg     = '0;
  localparam addr_t BaseBootrom = 'h0100_0000;

  // TODO: define all sub channel types at least. Do some checking with assertions?

  // TODO




















  /////////////////
  //  Reg demux  //
  /////////////////





  ///////////
  //  LLC  //
  ///////////

  // TODO














  /////////////
  //  Cores  //
  /////////////

  // TODO: Migrate to upstream CVA6 (We currently use a 48b-address fork)
  // TODO: Implement WIP coherent dual-core CVA6
  // TODO: Implement X interface support

  // Boot from boot ROM only if available, otherwise from platform ROM
  localparam addr_t BootAddr = (Cfg.Bootrom ? BaseBootrom : Cfg.PlatformRom);

  // Debug interface for internal harts
  dm::hartinfo_t [NumIntHarts-1:0] dbg_int_info;
  logic          [NumIntHarts-1:0] dbg_int_unavail;
  logic          [NumIntHarts-1:0] dbg_int_req;

  // All internal harts are CVA6 and always available
  assign dbg_int_info     = {(NumIntHarts){ariane_pkg::DebugHartInfo}};
  assign dbg_int_unavail  = '0;

  ariane_axi::req_t   core_out_req, core_ur_req;
  ariane_axi::resp_t  core_out_rsp, core_ur_rsp;

  // Currently, we support only one core
  cva6 #(
    .ArianeCfg  ( Cva6Cfg )
  ) i_core_cva6 (
    .clk_i,
    .rst_ni,
    .boot_addr_i  ( BootAddr )
    .hart_id_i    ( '0 ),
    .irq_i        ( irq[0]      ),
    .ipi_i        ( ipi[0]      ),
    .time_irq_i   ( time_irq[0] ),
    .debug_req_i  ( dbg_int_req[0] ),
    .cvxif_req_o  (  ),
    .cvxif_resp_i ( '0 ),
    .axi_req_o    ( core_out_req ),
    .axi_resp_i   ( core_out_rsp )
  );

  // Map user to AMO domain as we are an atomics-capable master.
  // As we are core 0, the core 1 and serial link AMO bits should *not* be set.
  always_comb begin
    core_ur_req         = core_out_req;
    core_ur_req.aw.user = AxiUserAmoDomain;
    core_ur_req.ar.user = AxiUserAmoDomain;
    core_ur_req.w.user  = AxiUserAmoDomain;
    core_out_rsp        = core_ur_rsp;
  end

  // Remap core ID width to configured ID width
  axi_id_remap #(
    .AxiSlvPortIdWidth    ( ariane_axi_pkg::IdWidth ),
    .AxiSlvPortMaxUniqIds ( Cfg.CoreMaxTxnsPerId ),
    .AxiMaxTxnsPerId      ( Cfg.CoreMaxUniqIds   ),
    .AxiMstPortIdWidth    ( Cfg.AxiMstIdWidth    ),
    .slv_req_t            ( ariane_axi::req_t  ),
    .slv_resp_t           ( ariane_axi::resp_t ),
    .mst_req_t            ( axi_mst_req_t   ),
    .mst_resp_t           ( axi_mst_rsp_t   )
  ) i_core_axi_id_remap (
    .clk_i,
    .rst_ni,
    .slv_req_i  ( core_ur_req ),
    .slv_resp_o ( core_ur_rsp ),
    .mst_req_o  ( axi_in_req[AxiInCore] ),
    .mst_resp_i ( axi_in_rsp[AxiInCore] )
  );

  /////////////////////////
  //  JTAG Debug Module  //
  /////////////////////////

  localparam int unsigned NumDbgHarts = NumIntHarts + Cfg.NumExtDbgHarts;

  // Filter atomics and cut
  axi_slv_req_t dbg_slv_axi_amo_req, dbg_slv_axi_cut_req;
  axi_slv_rsp_t dbg_slv_axi_amo_rsp, dbg_slv_axi_cut_rsp;

  // Hart debug interface
  dm::hartinfo_t [NumDbgHarts-1:0] dbg_info;
  logic          [NumDbgHarts-1:0] dbg_unavail;
  logic          [NumDbgHarts-1:0] dbg_req;

  // Debug module slave interface
  logic       dbg_slv_req;
  addr_t      dbg_slv_addr;
  data_t      dbg_slv_addr_long;
  logic       dbg_slv_we;
  axi_data_t  dbg_slv_wdata;
  axi_strb_t  dbg_slv_wstrb;
  addr_t      dbg_slv_rdata;
  logic       dbg_slv_rvalid;

  // Debug module system bus access interface
  logic       dbg_sba_req;
  addr_t      dbg_sba_addr;
  axi_data_t  dbg_sba_addr_long;
  logic       dbg_sba_we;
  axi_data_t  dbg_sba_wdata;
  axi_strb_t  dbg_sba_strb;
  logic       dbg_sba_gnt;
  axi_data_t  dbg_sba_rdata;
  logic       dbg_sba_rvalid;
  logic       dbg_sba_err;

  // JTAG DMI to debug module
  logic           dbg_dmi_rst_n;
  dm::dmi_req_t   dbg_dmi_req;
  logic           dbg_dmi_req_ready, dbg_dmi_req_valid;
  dm::dmi_resp_t  dbg_dmi_rsp;
  logic           dbg_dmi_rsp_ready, dbg_dmi_rsp_valid;

  // Truncate and pad addresses as necessary
  assign dbg_sba_addr       = dbg_sba_addr_long;
  assign dbg_slv_addr_long  = dbg_slv_addr;

  // Connect internal harts to debug interface
  assign dbg_info    [NumIntHarts-1:0] = dbg_int_info;
  assign dbg_unavail [NumIntHarts-1:0] = dbg_int_unavail;
  assign dbg_int_req = dbg_req[NumIntHarts-1:0];

  // Connect external harts to debug interface
  if (Cfg.NumExtDbgHarts != 0) begin : gen_dbg_ext
    assign dbg_info    [NumDbgHarts-1:NumIntHarts] = ExtHartinfo;
    assign dbg_unavail [NumDbgHarts-1:NumIntHarts] = dbg_ext_unavail_i;
    assign dbg_ext_req_o = dbg_req[NumDbgHarts-1:NumIntHarts];
  end

  // Filter atomic accesses
  axi_riscv_atomics_structs #(
    .AxiAddrWidth     ( Cfg.AxiAddrWidth ),
    .AxiDataWidth     ( Cfg.AxiDataWidth ),
    .AxiIdWidth       ( AxiSlvIdWidth    ),
    .AxiUserWidth     ( Cfg.AxiUserWidth ),
    .AxiMaxReadTxns   ( Cfg.DbgMaxReadTxns  ),
    .AxiMaxWriteTxns  ( Cfg.DbgMaxWriteTxns ),
    .AxiUserAsId      ( 1 ),
    .AxiUserIdMsb     ( Cfg.AxiUserAmoMsb ),
    .AxiUserIdLsb     ( Cfg.AxiUserAmoLsb ),
    .RiscvWordWidth   ( 64 ),
    .NAxiCuts         ( Cfg.DbgAmoNumCuts ),
    .axi_req_t        ( axi_slv_req_t ),
    .axi_rsp_t        ( axi_slv_rsp_t )
  ) i_dbg_slv_axi_atomics (
    .clk_i,
    .rst_ni,
    .axi_slv_req_i ( axi_out_req[AxiInDbg]  ),
    .axi_slv_rsp_o ( axi_out_rsp[AxiOutDbg] ),
    .axi_mst_req_o ( dbg_slv_axi_amo_req ),
    .axi_mst_rsp_i ( dbg_slv_axi_amo_rsp )
  );

  axi_cut #(
    .Bypass     ( ~DbgAmoPostCut ),
    .aw_chan_t  ( axi_slv_aw_chan_t  ),
    .w_chan_t   ( axi_slv_w_chan_t   ),
    .b_chan_t   ( axi_slv_b_chan_t   ),
    .ar_chan_t  ( axi_slv_ar_chan_t  ),
    .r_chan_t   ( axi_slv_r_chan_t   ),
    .axi_req_t  ( axi_slv_req_t  ),
    .axi_resp_t ( axi_slv_resp_t )
  ) i_dbg_slv_axi_atomics_cut (
    .clk_i,
    .rst_ni,
    .slv_req_i  ( dbg_slv_axi_amo_req ),
    .slv_resp_o ( dbg_slv_axi_amo_rsp ),
    .mst_req_o  ( dbg_slv_axi_cut_req ),
    .mst_resp_i ( dbg_slv_axi_cut_rsp )
  );

  // AXI access to debug module
  axi_to_mem_interleaved #(
    .axi_req_t  ( axi_slv_req_t ),
    .axi_resp_t ( axi_slv_rsp_t ),
    .AddrWidth  ( AddrWidth     ),
    .DataWidth  ( AxiDataWidth  ),
    .IdWidth    ( AxiSlvIdWidth ),
    .NumBanks   ( 1 ),
    .BufDepth   ( 4 )
  ) i_dbg_slv_axi_to_mem (
    .clk_i,
    .rst_ni,
    .busy_o       ( ),
    .axi_req_i    ( dbg_slv_axi_cut_req ),
    .axi_resp_o   ( dbg_slv_axi_cut_rsp ),
    .mem_req_o    ( dbg_slv_req    ),
    .mem_gnt_i    ( dbg_slv_req    ),
    .mem_addr_o   ( dbg_slv_addr   ),
    .mem_wdata_o  ( dbg_slv_wdata  ),
    .mem_strb_o   ( dbg_slv_wstrb  ),
    .mem_atop_o   ( ),
    .mem_we_o     ( dbg_slv_we     ),
    .mem_rvalid_i ( dbg_slv_rvalid ),
    .mem_rdata_i  ( dbg_slv_rdata  )
  );

  // Read response is valid one cycle after request
  `FF(dbg_slv_rvalid, dbg_slv_req, 1'b0, clk_i, rst_ni)

  // Debug Module
  dm_top #(
    .NrHarts        ( NumDbgHarts  ),
    .BusWidth       ( AxiDataWidth ),
    .DmBaseAddress  ( BaseDbg )
  ) i_dbg_dm_top (
    .clk_i,
    .rst_ni,
    .testmode_i           ( test_mode_i ),
    .ndmreset_o           ( ),
    .dmactive_o           ( dbg_active_o  ),
    .debug_req_o          ( dbg_req       ),
    .unavailable_i        ( dbg_unavail   ),
    .hartinfo_i           ( dbg_info      ),
    .slave_req_i          ( dbg_slv_req       ),
    .slave_we_i           ( dbg_slv_we        ),
    .slave_addr_i         ( dbg_slv_addr_long ),
    .slave_be_i           ( dbg_slv_wstrb     ),
    .slave_wdata_i        ( dbg_slv_wdata     ),
    .slave_rdata_o        ( dbg_slv_rdata     ),
    .master_req_o         ( dbg_sba_req       ),
    .master_add_o         ( dbg_sba_addr_long ),
    .master_we_o          ( dbg_sba_we        ),
    .master_wdata_o       ( dbg_sba_wdata     ),
    .master_be_o          ( dbg_sba_strb      ),
    .master_gnt_i         ( dbg_sba_gnt       ),
    .master_r_valid_i     ( dbg_sba_rvalid    ),
    .master_r_rdata_i     ( dbg_sba_rdata     ),
    .master_r_err_i       ( dbg_sba_err       ),
    .master_r_other_err_i ( 0 ),
    .dmi_rst_ni           ( dbg_dmi_rst_n      ),
    .dmi_req_valid_i      ( dbg_dmi_req_valid  ),
    .dmi_req_ready_o      ( dbg_dmi_req_ready  ),
    .dmi_req_i            ( dbg_dmi_req        ),
    .dmi_resp_valid_o     ( dbg_dmi_resp_valid ),
    .dmi_resp_ready_i     ( dbg_dmi_resp_ready ),
    .dmi_resp_o           ( dbg_dmi_resp       )
  );

  // Debug module system bus access to AXI crossbar
  axi_from_mem #(
    .MemAddrWidth ( AddrWidth    ),
    .AxiAddrWidth ( AddrWidth    ),
    .DataWidth    ( AxiDataWidth ),
    .MaxRequests  ( Cfg.JtagDmMaxReqs ),
    .AxiProt      ( '0 ),
    .axi_req_t    ( axi_req_t  ),
    .axi_rsp_t    ( axi_resp_t )
  ) i_dbg_sba_axi_from_mem (
    .clk_i,
    .rst_ni,
    .mem_req_i       ( sba_req    ),
    .mem_addr_i      ( sba_addr   ),
    .mem_we_i        ( sba_we     ),
    .mem_wdata_i     ( sba_wdata  ),
    .mem_be_i        ( sba_strb   ),
    .mem_gnt_o       ( sba_gnt    ),
    .mem_rsp_valid_o ( sba_rvalid ),
    .mem_rsp_rdata_o ( sba_rdata  ),
    .mem_rsp_error_o ( sba_err    ),
    .slv_aw_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .slv_ar_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .axi_req_o       ( axi_xbar_slv_port_reqs[AxiXbarInDebug] ),
    .axi_rsp_i       ( axi_xbar_slv_port_rsps[AxiXbarInDebug] )
  );

  // Debug Transfer Module and JTAG interface
  dmi_jtag #(
    .IdcodeValue  ( Cfg.DbgIdCode )
  ) i_dbg_dmi_jtag (
    .clk_i,
    .rst_ni,
    .testmode_i       ( test_mode_i )
    .dmi_rst_no       ( dbg_dmi_rst_n      ),
    .dmi_req_o        ( dbg_dmi_req        ),
    .dmi_req_ready_i  ( dbg_dmi_req_ready  ),
    .dmi_req_valid_o  ( dbg_dmi_req_valid  ),
    .dmi_resp_i       ( dbg_dmi_resp       ),
    .dmi_resp_ready_o ( dbg_dmi_resp_ready ),
    .dmi_resp_valid_i ( dbg_dmi_resp_valid ),
    .tck_i            ( jtag_tck_i     ),
    .tms_i            ( jtag_tms_i     ),
    .trst_ni          ( jtag_trst_ni   ),
    .td_i             ( jtag_tdi_i     ),
    .td_o             ( jtag_tdo_o     ),
    .tdo_oe_o         ( jtag_tdo_oe_o  )
  );

  /////////////////////
  //  Register File  //
  /////////////////////

  cheshire_reg_pkg::cheshire_hw2reg_t reg_hw2reg;

  assign reg_hw2reg = '{
    .boot_mode    = boot_mode_i,
    .rtc_freq     = Cfg.RtcFreq,
    .platform_rom = Cfg.PlatformRom,
    .hw_features  = '{
      .bootrom      = Cfg.BootRom;
      .uart         = Cfg.Uart;
      .i2c          = Cfg.I2c;
      .spi_host     = Cfg.SpiHost;
      .dma          = Cfg.Dma;
      .serial_link  = Cfg.SerialLink;
      .vga          = Cfg.Vga;
    },
    .vga_params   = '{
      .red_width    = Cfg.VgaRedWidth,
      .green_width  = Cfg.VgaGreenWidth,
      .blue_width   = Cfg.VgaBlueWidth
    }
  };

  cheshire_reg_top #(
    .reg_req_t  ( reg_req_t ),
    .reg_rsp_t  ( reg_rsp_t )
  ) i_regs (
    .clk_i,
    .rst_ni,
    .reg_req_i  ( reg_out_req[RegOutCsr] ),
    .reg_rsp_o  ( reg_out_rsp[RegOutCsr] ),
    .hw2reg     ( reg_hw2reg ),
    .devmode_i  ( 1'b1 )
  );

  ////////////
  //  PLIC  //
  ////////////

  rv_plic #(
    .reg_req_t  ( reg_req_t ),
    .reg_rsp_t  ( reg_rsp_t )
  ) i_plic (
    .clk_i,
    .rst_ni,
    .reg_req_i  ( reg_out_req[RegOutPlic] ),
    .reg_rsp_o  ( reg_out_rsp[RegOutPlic] ),
    .intr_src_i ( intr ),
    .irq_o      ( irq  ),
    .irq_id_o   ( ),
    .msip_o     ( )
  );

  /////////////
  //  CLINT  //
  /////////////

  clint #(
    .reg_req_t  ( reg_req_t ),
    .reg_rsp_t  ( reg_rsp_t )
  ) i_clint (
    .clk_i,
    .rst_ni,
    .testmode_i   ( test_mode_i )
    .reg_req_i    ( reg_out_req[RegOutClint] ),
    .reg_rsp_o    ( reg_out_rsp[RegOutClint] ),
    .rtc_i
    .timer_irq_o  ( time_irq ),
    .ipi_o        ( ipi      )
  );

  ////////////////
  //  Boot ROM  //
  ////////////////

  if (Cfg.Bootrom) begin : gen_bootrom

    logic [15:0]  bootrom_addr;
    logic [31:0]  bootrom_data, bootrom_data_q;
    logic         bootrom_req,  bootrom_req_q;
    logic         bootrom_we,   bootrom_we_q;

    // Delay response by one cycle to fulfill mem protocol
    `FF(bootrom_data_q, bootrom_data, '0, clk_i, rst_ni)
    `FF(bootrom_req_q,  bootrom_req,  '0, clk_i, rst_ni)
    `FF(bootrom_we_q,   bootrom_we,   '0, clk_i, rst_ni)

    reg_to_mem #(
      .AW     ( 16 ),
      .DW     ( 32 ),
      .req_t  ( reg_req_t ),
      .rsp_t  ( reg_rsp_t )
    ) i_reg_to_bootrom (
      .clk_i,
      .rst_ni,
      .reg_req_i  ( reg_out_req[RegOutBootrom] ),
      .reg_rsp_o  ( reg_out_rsp[RegOutBootrom] ),
      .req_o      ( bootrom_req  ),
      .gnt_i      ( bootrom_req  ),
      .we_o       ( bootrom_we   ),
      .addr_o     ( bootrom_addr ),
      .wdata_o    ( ),
      .wstrb_o    ( ),
      .rdata_i    ( bootrom_data_q ),
      .rvalid_i   ( bootrom_req_q  ),
      .rerror_i   ( bootrom_we_q   )
    );

    cheshire_bootrom #(
      .AddrWidth  ( 16 ),
      .DataWidth  ( 32 )
    ) i_bootrom (
      .clk_i,
      .rst_ni,
      .req_i    ( bootrom_req  ),
      .addr_i   ( bootrom_addr ),
      .data_o   ( bootrom_data )
    );

  end else begin : gen_no_bootrom

    reg_err_slv #(
      .DW       ( 32 ),
      .ERR_VAL  ( 32'hBADCAB1E ),
      .req_t    ( reg_req_t ),
      .rsp_t    ( reg_rsp_t )
    ) i_bootrom_err_slv (
      .req_i  ( reg_out_req[RegOutBootrom] ),
      .rsp_o  ( reg_out_rsp[RegOutBootrom] )
    );

  end

  ////////////
  //  UART  //
  ////////////

  if (Cfg.Uart) begin : gen_uart

    reg_uart_wrap #(
      .AddrWidth  ( AddrWidth ),
      .reg_req_t  ( reg_req_t ),
      .reg_rsp_t  ( reg_rsp_t )
    ) i_uart (
      .clk_i,
      .rst_ni,
      .reg_req_i  ( reg_out_req[RegOutUart] ),
      .reg_rsp_o  ( reg_out_rsp[RegOutUart] ),
      .intr_o     ( intr.uart ),
      .out2_no    ( ),
      .out1_no    ( ),
      .rts_no     ( uart_rts_no ),
      .dtr_no     ( uart_dtr_no ),
      .cts_ni     ( uart_cts_ni ),
      .dsr_ni     ( uart_dsr_ni ),
      .dcd_ni     ( uart_dcd_ni ),
      .rin_ni     ( uart_rin_ni ),
      .sin_i      ( uart_rx_i   ),
      .sout_o     ( uart_tx_o   )
    );

  end else begin : gen_no_uart

    assign uart_rts_no  = 0;
    assign uart_dtr_no  = 0;
    assign uart_tx_o    = 0;

    assign intr.uart  = 0;

    reg_err_slv #(
      .DW       ( 32 ),
      .ERR_VAL  ( 32'hBADCAB1E ),
      .req_t    ( reg_req_t ),
      .rsp_t    ( reg_rsp_t )
    ) i_uart_err_slv (
      .req_i  ( reg_out_req[RegOutUart] ),
      .rsp_o  ( reg_out_rsp[RegOutUart] )
    );

  end

  ///////////
  //  I2C  //
  ///////////

  if (Cfg.I2c) begin : gen_i2c

    i2c #(
      .reg_req_t  ( reg_req_t ),
      .reg_rsp_t  ( reg_rsp_t )
    ) i_i2c (
      .clk_i,
      .rst_ni,
      .reg_req_i                ( reg_out_req[RegOutI2c] ),
      .reg_rsp_o                ( reg_out_rsp[RegOutI2c] ),
      .cio_scl_i                ( i2c_scl_i    ),
      .cio_scl_o                ( i2c_scl_o    ),
      .cio_scl_en_o             ( i2c_scl_en_o ),
      .cio_sda_i                ( i2c_sda_i    ),
      .cio_sda_o                ( i2c_sda_o    ),
      .cio_sda_en_o             ( i2c_sda_en_o ),
      .intr_fmt_threshold_o     ( intr.i2c_fmt_threshold    ),
      .intr_rx_threshold_o      ( intr.i2c_rx_threshold     ),
      .intr_fmt_overflow_o      ( intr.i2c_fmt_overflow     ),
      .intr_rx_overflow_o       ( intr.i2c_rx_overflow      ),
      .intr_nak_o               ( intr.i2c_nak              ),
      .intr_scl_interference_o  ( intr.i2c_scl_interference ),
      .intr_sda_interference_o  ( intr.i2c_sda_interference ),
      .intr_stretch_timeout_o   ( intr.i2c_stretch_timeout  ),
      .intr_sda_unstable_o      ( intr.i2c_sda_unstable     ),
      .intr_cmd_complete_o      ( intr.i2c_cmd_complete     ),
      .intr_tx_stretch_o        ( intr.i2c_tx_stretch       ),
      .intr_tx_overflow_o       ( intr.i2c_tx_overflow      ),
      .intr_acq_full_o          ( intr.i2c_acq_full         ),
      .intr_unexp_stop_o        ( intr.i2c_unexp_stop       ),
      .intr_host_timeout_o      ( intr.i2c_host_timeout     )
    );

  end else begin : gen_no_i2c

    assign i2c_scl_o    = 0;
    assign i2c_scl_en_o = 0;
    assign i2c_sda_o    = 0;
    assign i2c_sda_en_o = 0;

    assign intr.i2c_fmt_threshold     = 0;
    assign intr.i2c_rx_threshold      = 0;
    assign intr.i2c_fmt_overflow      = 0;
    assign intr.i2c_rx_overflow       = 0;
    assign intr.i2c_nak               = 0;
    assign intr.i2c_scl_interference  = 0;
    assign intr.i2c_sda_interference  = 0;
    assign intr.i2c_stretch_timeout   = 0;
    assign intr.i2c_sda_unstable      = 0;
    assign intr.i2c_cmd_complete      = 0;
    assign intr.i2c_tx_stretch        = 0;
    assign intr.i2c_tx_overflow       = 0;
    assign intr.i2c_acq_full          = 0;
    assign intr.i2c_unexp_stop        = 0;
    assign intr.i2c_host_timeout      = 0;

    reg_err_slv #(
      .DW       ( 32 ),
      .ERR_VAL  ( 32'hBADCAB1E ),
      .req_t    ( reg_req_t ),
      .rsp_t    ( reg_rsp_t )
    ) i_i2c_err_slv (
      .req_i  ( reg_out_req[RegOutI2c] ),
      .rsp_o  ( reg_out_rsp[RegOutI2c] )
    );

  end

  ////////////////
  //  SPI Host  //
  ////////////////

  if (Cfg.SpiHost) begin : gen_spi_host

    // Last CS is an internal dummy for devices that need it
    logic spih_csb_dummy, spih_csb_dummy_en;

    spi_host #(
      .reg_req_t  ( reg_req_t ),
      .reg_rsp_t  ( reg_rsp_t )
    ) i_spi_host (
      .clk_i,
      .rst_ni,
      .reg_req_i        ( regbus_out_req[RegOutSpim] ),
      .reg_rsp_o        ( regbus_out_rsp[RegOutSpim] ),
      .cio_sck_o        ( spih_sck_o    ),
      .cio_sck_en_o     ( spih_sck_en_o ),
      .cio_csb_o        ( {spih_csb_dummy,    spih_csb_o   } ),
      .cio_csb_en_o     ( {spih_csb_dummy_en, spih_csb_en_o} ),
      .cio_sd_o         ( spih_sd_o     ),
      .cio_sd_en_o      ( spih_sd_en_o  ),
      .cio_sd_i         ( spih_sd_i     ),
      .intr_error_o     ( intr.spih_error     ),
      .intr_spi_event_o ( intr.spih_spi_event )
    );

  end else begin : gen_no_spi_host

    assign spih_sck_o     = 0;
    assign spih_sck_en_o  = 0;
    assign spih_csb_o     = '1;
    assign spih_csb_en_o  = '0;
    assign spih_sd_o      = '0;
    assign spih_sd_en_o   = '0;

    assign intr.spih_error      = 0;
    assign intr.spih_spi_event  = 0;

    reg_err_slv #(
      .DW       ( 32 ),
      .ERR_VAL  ( 32'hBADCAB1E ),
      .req_t    ( reg_req_t ),
      .rsp_t    ( reg_rsp_t )
    ) i_spi_host_err_slv (
      .req_i  ( reg_out_req[RegOutSpim] ),
      .rsp_o  ( reg_out_rsp[RegOutSpim] )
    );

  end

  ////////////
  //  GPIO  //
  ////////////

  if (Cfg.Gpio) begin : gen_gpio

    gpio #(
      .reg_req_t   ( reg_req_t ),
      .reg_rsp_t   ( reg_rsp_t ),
      .GpioAsyncOn ( Cfg.GpioInputSyncs )
    ) i_gpio (
      .clk_i,
      .rst_ni,
      .reg_req_i     ( reg_out_req[RegOutGpio] ),
      .reg_rsp_o     ( reg_out_rsp[RegOutGpio] ),
      .intr_gpio_o   ( intr.gpio ),
      .cio_gpio_i    ( gpio_i    ),
      .cio_gpio_o    ( gpio_o    ),
      .cio_gpio_en_o ( gpio_en_o )
    );

  end else begin : gen_no_gpio

    assign gpio_o     = '0;
    assign gpio_en_o  = '0;

    assign intr.gpio  = 0;

    reg_err_slv #(
      .DW       ( 32 ),
      .ERR_VAL  ( 32'hBADCAB1E ),
      .req_t    ( reg_req_t ),
      .rsp_t    ( reg_rsp_t )
    ) i_spi_host_err_slv (
      .req_i  ( reg_out_req[RegOutGpio] ),
      .rsp_o  ( reg_out_rsp[RegOutGpio] )
    );

  end

  ///////////
  //  DMA  //
  ///////////

  if(Cfg.Dma) begin : gen_dma

    axi_slv_req_t dma_amo_req, dma_cut_req;
    axi_slv_rsp_t dma_amo_rsp, dma_cut_rsp;

    axi_riscv_atomics_structs #(
      .AxiAddrWidth     ( Cfg.AxiAddrWidth ),
      .AxiDataWidth     ( Cfg.AxiDataWidth ),
      .AxiIdWidth       ( AxiSlvIdWidth    ),
      .AxiUserWidth     ( Cfg.AxiUserWidth ),
      .AxiMaxReadTxns   ( Cfg.DmaConfMaxReadTxns  ),
      .AxiMaxWriteTxns  ( Cfg.DmaConfMaxWriteTxns ),
      .AxiUserAsId      ( 1 ),
      .AxiUserIdMsb     ( Cfg.AxiUserAmoMsb ),
      .AxiUserIdLsb     ( Cfg.AxiUserAmoLsb ),
      .RiscvWordWidth   ( 64 ),
      .NAxiCuts         ( Cfg.DmaConfAmoNumCuts ),
      .axi_req_t        ( axi_slv_req_t ),
      .axi_rsp_t        ( axi_slv_rsp_t )
    ) i_dma_conf_atomics (
      .clk_i,
      .rst_ni,
      .axi_slv_req_i ( axi_out_req[AxiInDma]  ),
      .axi_slv_rsp_o ( axi_out_rsp[AxiOutDma] ),
      .axi_mst_req_o ( dma_amo_req ),
      .axi_mst_rsp_i ( dma_amo_rsp )
    );

    axi_cut #(
      .Bypass     ( ~DmaConfAmoPostCut ),
      .aw_chan_t  ( axi_slv_aw_chan_t  ),
      .w_chan_t   ( axi_slv_w_chan_t   ),
      .b_chan_t   ( axi_slv_b_chan_t   ),
      .ar_chan_t  ( axi_slv_ar_chan_t  ),
      .r_chan_t   ( axi_slv_r_chan_t   ),
      .axi_req_t  ( axi_slv_req_t  ),
      .axi_resp_t ( axi_slv_resp_t )
    ) i_dma_conf_atomics_cut (
      .clk_i,
      .rst_ni,
      .slv_req_i  ( dma_amo_req ),
      .slv_resp_o ( dma_amo_rsp ),
      .mst_req_o  ( dma_cut_req ),
      .mst_resp_i ( dma_cut_rsp )
    );

    dma_core_wrap #(
      .AxiAddrWidth   ( Cfg.AxiAddrWidth  ),
      .AxiDataWidth   ( Cfg.AxiDataWidth  ),
      .AxiIdWidth     ( Cfg.AxiMstIdWidth ),
      .AxiUserWidth   ( Cfg.AxiUserWidth  ),
      .AxiSlvIdWidth  ( AxiSlvIdWidth     ),
      .axi_mst_req_t  ( axi_mst_req_t ),
      .axi_mst_rsp_t  ( axi_mst_req_t ),
      .axi_slv_req_t  ( axi_slv_req_t ),
      .axi_slv_rsp_t  ( axi_slv_req_t )
    ) i_dma (
      .clk_i,
      .rst_ni,
      .testmode_i     ( test_mode_i ),
      .axi_mst_req_o  ( axi_in_req[AxiInDma] ),
      .axi_mst_rsp_i  ( axi_in_rsp[AxiInDma] ),
      .axi_slv_req_i  ( dma_cut_req ),
      .axi_slv_rsp_o  ( dma_cut_rsp )
    );

  end else begin : gen_no_dma

    assign axi_in_req[AxiInDma] = '0;

    axi_err_slv #(
      .AxiIdWidth ( AxiSlvIdWidth ),
      .axi_req_t  ( axi_req_t ),
      .axi_resp_t ( axi_rsp_t ),
      .RespWidth  ( 64 ),
      .RespData   ( 64'hCA11AB1EBADCAB1E ),
      .ATOPs      ( 1 ),
      .MaxTrans   ( 1 )
    ) i_dma_err_slv (
      .clk_i,
      .rst_ni,
      .test_i     ( test_mode_i ),
      .slv_req_i  ( axi_out_req[AxiOutDmaConf] ),
      .slv_resp_o ( axi_out_rsp[AxiOutDmaConf] )
    );

  end

  ///////////////////
  //  Serial Link  //
  ///////////////////

  // TODO: ensure gating and connect isolation IO properly

  if(Cfg.SerialLink) begin : gen_serial_link

    axi_slv_req_t slink_tx_uar_req;
    axi_slv_rsp_t slink_tx_uar_rsp;

    axi_mst_req_t slink_tx_idr_req;
    axi_mst_rsp_t slink_tx_idr_rsp;

    // TX outgoing channels: Remap address and set serial link user bit
    always_comb begin
      slink_tx_uar_req          = axi_out_req[AxiOutSerialLink];
      slink_tx_uar_req.aw.addr  = (Cfg.SlinkTxAddrDomain    & ~Cfg.SlinkTxAddrMask) |
                                  (slink_tx_uar_req.aw.addr &  Cfg.SlinkTxAddrMask);
      slink_tx_uar_req.ar.addr  = (Cfg.SlinkTxAddrDomain    & ~Cfg.SlinkTxAddrMask) |
                                  (slink_tx_uar_req.ar.addr &  Cfg.SlinkTxAddrMask);
      slink_tx_uar_req.aw.user |= (64'b1 << SlinkUserAmoBit);
      slink_tx_uar_req.ar.user |= (64'b1 << SlinkUserAmoBit);
      slink_tx_uar_req.w.user  |= (64'b1 << SlinkUserAmoBit);
    end

    // TX incoming channels: unset serial link user bit
    always_comb begin
      axi_out_rsp[AxiOutSerialLink]         = slink_tx_uar_rsp;
      axi_out_rsp[AxiOutSerialLink].r.user &= ~(64'b1 << SlinkUserAmoBit);
      axi_out_rsp[AxiOutSerialLink].b.user &= ~(64'b1 << SlinkUserAmoBit);
    end

    // TX: Remap wider slave ID to narrower master ID
    axi_id_remap #(
      .AxiSlvPortIdWidth    ( AxiSlvIdWidth         ),
      .AxiSlvPortMaxUniqIds ( Cfg.SlinkMaxUniqIds   ),
      .AxiMaxTxnsPerId      ( Cfg.SlinkMaxTxnsPerId ),
      .AxiMstPortIdWidth    ( Cfg.AxiMstIdWidth     ),
      .slv_req_t            ( axi_slv_req_t ),
      .slv_resp_t           ( axi_slv_rsp_t ),
      .mst_req_t            ( axi_mst_req_t ),
      .mst_resp_t           ( axi_mst_rsp_t )
    ) i_serial_link_tx_id_remap (
      .clk_i,
      .rst_ni,
      .slv_req_i  ( slink_tx_uar_req ),
      .slv_resp_o ( slink_tx_uar_rsp ),
      .mst_req_o  ( slink_tx_idr_req ),
      .mst_resp_i ( slink_tx_idr_rsp )
    );

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
      .NumLanes     ( SlinkNumBits   ),
      .MaxClkDiv    ( SlinkMaxClkDiv )
    ) i_serial_link (
      .clk_i,
      .rst_ni,
      .clk_sl_i       ( clk_i  ),
      .rst_sl_ni      ( rst_ni ),
      .clk_reg_i      ( clk_i  ),
      .rst_reg_ni     ( rst_ni ),
      .testmode_i     ( test_mode_i ),
      .axi_in_req_i   ( slink_tx_idr_req ),
      .axi_in_rsp_o   ( slink_tx_idr_rsp ),
      .axi_out_req_o  ( axi_in_req[AxiInSerialLink]   ),
      .axi_out_rsp_i  ( axi_in_rsp[AxiInSerialLink]   ),
      .cfg_req_i      ( reg_out_req[RegOutSerialLink] ),
      .cfg_rsp_o      ( reg_out_rsp[RegOutSerialLink] ),
      .ddr_rcv_clk_i  ( slink_clk_i ),
      .ddr_rcv_clk_o  ( slink_clk_o ),
      .ddr_i          ( slink_i     ),
      .ddr_o          ( slink_o     ),
      .isolated_i     ( '0 ),
      .isolate_o      ( ),
      .clk_ena_o      ( ),
      .reset_no       ( )
    );

  end else begin : gen_no_serial_link

    assign axi_in_req[AxiInSerialLink] = '0;

    assign ddr_link_clk_o = 1;
    assign ddr_link_o     = '0;

    axi_err_slv #(
      .AxiIdWidth ( AxiSlvIdWidth ),
      .axi_req_t  ( axi_slv_req_t ),
      .axi_resp_t ( axi_slv_rsp_t ),
      .RespWidth  ( 64 ),
      .RespData   ( 64'hCA11AB1EBADCAB1E ),
      .ATOPs      ( 1 ),
      .MaxTrans   ( 1 )
    ) i_serial_link_axi_err_slv (
      .clk_i,
      .rst_ni,
      .test_i     ( testmode_i ),
      .slv_req_i  ( axi_out_req[AxiOutSerialLink] ),
      .slv_resp_o ( axi_out_rsp[AxiOutSerialLink] )
    );

    reg_err_slv #(
      .DW      ( 32 ),
      .ERR_VAL ( 32'hBADCAB1E ),
      .req_t   ( reg_req_t ),
      .rsp_t   ( reg_rsp_t )
    ) i_serial_link_reg_err_slv (
      .req_i   ( reg_out_req[RegOutSerialLink] ),
      .rsp_o   ( reg_out_rsp[RegOutSerialLink] )
    );

  end

  ///////////
  //  VGA  //
  ///////////

  if (Cfg.Vga) begin : gen_vga

    axi_vga #(
      .RedWidth     ( Cfg.VgaRedWidth   ),
      .GreenWidth   ( Cfg.VgaGreenWidth ),
      .BlueWidth    ( Cfg.VgaBlueWidth  ),
      .HCountWidth  ( Cfg.HCountWidth   ),
      .VCountWidth  ( Cfg.VCountWidth   ),
      .AXIAddrWidth ( Cfg.AddrWidth     ),
      .AXIDataWidth ( Cfg.AxiDataWidth  ),
      .AXIStrbWidth ( AxiStrbWidth      ),
      .axi_req_t    ( axi_slv_req_t ),
      .axi_resp_t   ( axi_slv_rsp_t ),
      .reg_req_t    ( reg_req_t ),
      .reg_resp_t   ( reg_rsp_t )
    ) i_axi_vga (
      .clk_i,
      .rst_ni,
      .test_mode_en_i ( test_mode_i ),
      .reg_req_i      ( reg_out_req[RegOutVga] ),
      .reg_rsp_o      ( reg_out_rsp[RegOutVga] ),
      .axi_req_o      ( axi_in_req[AxiInVga]   ),
      .axi_resp_i     ( axi_in_rsp[AxiInVga]   ),
      .hsync_o        ( vga_hsync_o ),
      .vsync_o        ( vga_vsync_o ),
      .red_o          ( vga_red_o   ),
      .green_o        ( vga_green_o ),
      .blue_o         ( vga_blue_o  )
    );

  end else begin : gen_no_vga

    assign axi_out_reqs[AxiInVga] = '0;

    assign vga_hsync_o  = 0;
    assign vga_vsync_o  = 0;
    assign vga_red_o    = '0;
    assign vga_green_o  = '0;
    assign vga_blue_o   = '0;

    reg_err_slv #(
      .DW       ( 32 ),
      .ERR_VAL  ( 32'hBADCAB1E ),
      .req_t    ( reg_req_t ),
      .rsp_t    ( reg_rsp_t )
    ) i_axi_vga_err_slv (
      .req_i  ( reg_out_req[RegOutVga] ),
      .rsp_o  ( reg_out_rsp[RegOutVga] )
    );

  end

  //////////////////
  //  Assertions  //
  //////////////////

  `ASSERT_INIT(NoDualCoreSupport, ~Cfg.DualCore)

  // TODO: check that CVA6 and Cheshire config agree
  // TODO: check that all interconnect params agree
  // TODO: check that params with min/max values are within legal range
  // TODO: check that CLINT and PLIC target counts are both `NumIntHarts + Cfg.NumExtHarts`
  // TODO: check that (for now) `NumIntHarts == 1`
  // TODO: check that available user bits suffice to identify all masters
  // TODO: check that atomics user domain is nonzero
  // TODO: check that `ext` (IO) and internal types agree
  // TODO: many other things I most likely forgot

endmodule
