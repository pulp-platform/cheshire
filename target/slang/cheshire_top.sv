

package cheshire_top_pkg;

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;

  localparam cheshire_cfg_t Cfg = DefaultCfg;
  `CHESHIRE_TYPEDEF_ALL(, Cfg)

endpackage

module cheshire_top import cheshire_top_pkg::*; import cheshire_pkg::*;
    (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        test_mode_i,
    input  logic [1:0]  boot_mode_i,
    input  logic        rtc_i,
    // External AXI LLC (DRAM) port
    output axi_llc_req_t axi_llc_mst_req_o,
    input  axi_llc_rsp_t axi_llc_mst_rsp_i,
    // External AXI crossbar ports
    input  axi_mst_req_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_req_i,
    output axi_mst_rsp_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_rsp_o,
    output axi_slv_req_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_req_o,
    input  axi_slv_rsp_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_rsp_i,
    // External reg demux slaves
    output reg_req_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_req_o,
    input  reg_rsp_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_rsp_i,
    // Interrupts from external devices
    input  logic [iomsb(Cfg.NumExtIntrs):0] intr_ext_i,
    // Interrupts to external harts
    output logic [iomsb(Cfg.NumExtIrqHarts):0] meip_ext_o,
    output logic [iomsb(Cfg.NumExtIrqHarts):0] seip_ext_o,
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
    input  logic [SlinkNumChan-1:0]                     slink_rcv_clk_i,
    output logic [SlinkNumChan-1:0]                     slink_rcv_clk_o,
    input  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_i,
    output logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_o,
    // VGA interface
    output logic                          vga_hsync_o,
    output logic                          vga_vsync_o,
    output logic [Cfg.VgaRedWidth  -1:0]  vga_red_o,
    output logic [Cfg.VgaGreenWidth-1:0]  vga_green_o,
    output logic [Cfg.VgaBlueWidth -1:0]  vga_blue_o
  );

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
    .reg_ext_rsp_t      ( reg_req_t )
  ) i_cheshire_soc (
    .clk_i             , 
    .rst_ni            , 
    .test_mode_i       , 
    .boot_mode_i       , 
    .rtc_i             , 
    .axi_llc_mst_req_o , 
    .axi_llc_mst_rsp_i , 
    .axi_ext_mst_req_i , 
    .axi_ext_mst_rsp_o , 
    .axi_ext_slv_req_o , 
    .axi_ext_slv_rsp_i , 
    .reg_ext_slv_req_o , 
    .reg_ext_slv_rsp_i , 
    .intr_ext_i        , 
    .meip_ext_o        , 
    .seip_ext_o        , 
    .mtip_ext_o        , 
    .msip_ext_o        , 
    .dbg_active_o      , 
    .dbg_ext_req_o     , 
    .dbg_ext_unavail_i , 
    .jtag_tck_i        , 
    .jtag_trst_ni      , 
    .jtag_tms_i        , 
    .jtag_tdi_i        , 
    .jtag_tdo_o        , 
    .jtag_tdo_oe_o     , 
    .uart_tx_o         , 
    .uart_rx_i         , 
    .uart_rts_no       , 
    .uart_dtr_no       , 
    .uart_cts_ni       , 
    .uart_dsr_ni       , 
    .uart_dcd_ni       , 
    .uart_rin_ni       , 
    .i2c_sda_o         , 
    .i2c_sda_i         , 
    .i2c_sda_en_o      , 
    .i2c_scl_o         , 
    .i2c_scl_i         , 
    .i2c_scl_en_o      , 
    .spih_sck_o        , 
    .spih_sck_en_o     , 
    .spih_csb_o        , 
    .spih_csb_en_o     , 
    .spih_sd_o         , 
    .spih_sd_en_o      , 
    .spih_sd_i         , 
    .gpio_i            , 
    .gpio_o            , 
    .gpio_en_o         , 
    .slink_rcv_clk_i   , 
    .slink_rcv_clk_o   , 
    .slink_i           , 
    .slink_o           , 
    .vga_hsync_o       , 
    .vga_vsync_o       , 
    .vga_red_o         , 
    .vga_green_o       , 
    .vga_blue_o         
  );

endmodule