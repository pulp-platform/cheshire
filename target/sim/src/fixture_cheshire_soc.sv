// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

module cheshire_soc_fixture;

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;

  ///////////
  //  DPI  //
  ///////////

  import "DPI-C" function byte read_elf(input string filename);
  import "DPI-C" function byte get_entry(output longint entry);
  import "DPI-C" function byte get_section(output longint address, output longint len);
  import "DPI-C" context function byte read_section(input longint address, inout byte buffer[], input longint len);

  //////////////////
  //  Parameters  //
  //////////////////

  localparam cheshire_cfg_t DutCfg = DefaultCfg;
  `CHESHIRE_TYPEDEF_ALL(, DutCfg)

  localparam time ClkPeriodSys    = 5ns;
  localparam time ClkPeriodJtag   = 20ns;
  localparam time ClkPeriodRtc    = 30518ns;

  localparam int unsigned RstCycles = 5;

  localparam real TAppl   = 0.1;
  localparam real TTest   = 0.9;

  localparam int unsigned UartBaudRate  = 115200;
  localparam int unsigned UartParityEna  = 0;

  //////////////
  //  DUT IO  //
  //////////////

  logic       clk;
  logic       rst_n;
  logic       test_mode;
  logic [1:0] boot_mode;
  logic       rtc;

  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

  logic jtag_tck;
  logic jtag_trst_n;
  logic jtag_tms;
  logic jtag_tdi;
  logic jtag_tdo;
  logic jtag_tdo_oe;

  logic uart_tx;
  logic uart_rx;

  logic i2c_sda_o;
  logic i2c_sda_i;
  logic i2c_sda_en;
  logic i2c_scl_o;
  logic i2c_scl_i;
  logic i2c_scl_en;

  logic                 spih_sck;
  logic                 spih_sck_en;
  logic [SpihNumCs-1:0] spih_csb;
  logic [SpihNumCs-1:0] spih_csb_en;
  logic [ 3:0]          spih_sd_o;
  logic [ 3:0]          spih_sd_i;
  logic [ 3:0]          spih_sd_en;

  logic [SlinkNumChan-1:0]                    slink_clk_i;
  logic [SlinkNumChan-1:0]                    slink_clk_o;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o;

  ///////////
  //  DUT  //
  ///////////

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
    .reg_ext_rsp_t      ( reg_req_t )
  ) i_dut (
    .clk_i              ( clk       ),
    .rst_ni             ( rst_n     ),
    .test_mode_i        ( test_mode ),
    .boot_mode_i        ( boot_mode ),
    .rtc_i              ( rtc       ),
    .axi_llc_mst_req_o  ( axi_llc_mst_req ),
    .axi_llc_mst_rsp_i  ( axi_llc_mst_rsp ),
    .axi_ext_mst_req_i  ( '0 ),
    .axi_ext_mst_rsp_o  ( ),
    .axi_ext_slv_req_o  ( ),
    .axi_ext_slv_rsp_i  ( '0 ),
    .reg_ext_slv_req_o  ( ),
    .reg_ext_slv_rsp_i  ( '0 ),
    .intr_ext_i         ( '0 ),
    .meip_ext_o         ( ),
    .seip_ext_o         ( ),
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
    .jtag_tdo_oe_o      ( jtag_tdo_oe ),
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
    .spih_sck_o         ( spih_sck    ),
    .spih_sck_en_o      ( spih_sck_en ),
    .spih_csb_o         ( spih_csb    ),
    .spih_csb_en_o      ( spih_csb_en ),
    .spih_sd_o          ( spih_sd_o   ),
    .spih_sd_en_o       ( spih_sd_en  ),
    .spih_sd_i          ( spih_sd_i   ),
    .gpio_i             ( '0 ),
    .gpio_o             ( ),
    .gpio_en_o          ( ),
    .slink_rcv_clk_i    ( slink_clk_i ),
    .slink_rcv_clk_o    ( slink_clk_o ),
    .slink_i            ( slink_i     ),
    .slink_o            ( slink_o     ),
    .vga_hsync_o        ( ),
    .vga_vsync_o        ( ),
    .vga_red_o          ( ),
    .vga_green_o        ( ),
    .vga_blue_o         ( )
  );

  ////////////
  //  DRAM  //
  ////////////

  axi_sim_mem #(
    .AddrWidth          ( DutCfg.AddrWidth    ),
    .DataWidth          ( DutCfg.AxiDataWidth ),
    .IdWidth            ( $bits(axi_llc_id_t) ),
    .UserWidth          ( DutCfg.AxiUserWidth ),
    .axi_req_t          ( axi_llc_req_t ),
    .axi_rsp_t          ( axi_llc_rsp_t ),
    .WarnUninitialized  ( 1 ),
    .ClearErrOnAccess   ( 1 ),
    .ApplDelay          ( ClkPeriodSys * TAppl ),
    .AcqDelay           ( ClkPeriodSys * TTest )
  ) i_dram_sim_mem (
    .clk_i              ( clk   ),
    .rst_ni             ( rst_n ),
    .axi_req_i          ( axi_llc_mst_req ),
    .axi_rsp_o          ( axi_llc_mst_rsp ),
    .mon_w_valid_o      ( ),
    .mon_w_addr_o       ( ),
    .mon_w_data_o       ( ),
    .mon_w_id_o         ( ),
    .mon_w_user_o       ( ),
    .mon_w_beat_count_o ( ),
    .mon_w_last_o       ( ),
    .mon_r_valid_o      ( ),
    .mon_r_addr_o       ( ),
    .mon_r_data_o       ( ),
    .mon_r_id_o         ( ),
    .mon_r_user_o       ( ),
    .mon_r_beat_count_o ( ),
    .mon_r_last_o       ( )
  );

  ///////////////////////////////
  //  SoC Clock, Reset, Modes  //
  ///////////////////////////////

  clk_rst_gen #(
    .ClkPeriod    ( ClkPeriodSys ),
    .RstClkCycles ( RstCycles )
  ) i_clk_rst_sys (
    .clk_o  ( clk   ),
    .rst_no ( rst_n )
  );

  clk_rst_gen #(
    .ClkPeriod    ( ClkPeriodRtc ),
    .RstClkCycles ( RstCycles )
  ) i_clk_rst_rtc (
    .clk_o  ( rtc ),
    .rst_no ( )
  );

  initial begin
    test_mode = '0;
    boot_mode = '0;
  end

  task wait_for_reset;
    @(posedge rst_n);
    @(posedge clk);
  endtask

  task set_test_mode(input logic mode);
    test_mode = mode;
  endtask

  task set_boot_mode(input logic [1:0] mode);
    boot_mode = mode;
  endtask

  ////////////
  //  JTAG  //
  ////////////

  localparam dm::sbcs_t JtagInitSbcs = dm::sbcs_t'{
      sbautoincrement: 1'b1, sbreadondata: 1'b1, sbaccess: 3, default: '0};

  // Generate clock
  clk_rst_gen #(
    .ClkPeriod    ( ClkPeriodJtag ),
    .RstClkCycles ( RstCycles )
  ) i_clk_jtag (
    .clk_o  ( jtag_tck ),
    .rst_no ( )
  );

  // Define test bus and driver
  JTAG_DV jtag(jtag_tck);

  typedef jtag_test::riscv_dbg #(
    .IrLength ( 5 ),
    .TA       ( ClkPeriodJtag * TAppl ),
    .TT       ( ClkPeriodJtag * TTest )
  ) riscv_dbg_t;

  riscv_dbg_t::jtag_driver_t  jtag_dv   = new (jtag);
  riscv_dbg_t                 jtag_dbg  = new (jtag_dv);

  // Connect DUT to test bus
  assign jtag_trst_n  = jtag.trst_n;
  assign jtag_tms     = jtag.tms;
  assign jtag_tdi     = jtag.tdi;
  assign jtag.tdo     = jtag_tdo;

  task automatic jtag_write(
    input dm::dm_csr_e addr,
    input word_bt data,
    input bit wait_cmd = 0,
    input bit wait_sba = 0
  );
    jtag_dbg.write_dmi(addr, data);
    if (wait_cmd) begin
      dm::abstractcs_t acs;
      do begin
        jtag_dbg.read_dmi_exp_backoff(dm::AbstractCS, acs);
        if (acs.cmderr) $fatal(1, "[JTAG] Abstract command error!");
      end while (acs.busy);
    end
    if (wait_sba) begin
      dm::sbcs_t sbcs;
      do begin
        jtag_dbg.read_dmi_exp_backoff(dm::SBCS, sbcs);
        if (sbcs.sberror | sbcs.sbbusyerror) $fatal(1, "[JTAG] System bus error!");
      end while (sbcs.sbbusy);
    end
  endtask

  task automatic jtag_poll_bit0(
    input doub_bt addr,
    output word_bt data,
    input int unsigned idle_cycles
  );
    // Update SBCS
    automatic dm::sbcs_t sbcs = dm::sbcs_t'{sbreadonaddr: 1'b1, sbaccess: 2, default: '0};
    jtag_write(dm::SBCS, sbcs, 0, 1);
    // Poll scratch register 0
    jtag_write(dm::SBAddress1, addr[63:32]);
    do begin
      jtag_write(dm::SBAddress0, addr[31:0]);
      jtag_dbg.wait_idle(idle_cycles);
      jtag_dbg.read_dmi_exp_backoff(dm::SBData0, data);
    end while (~data[0]);
  endtask

  // Initialize the debug module
  task automatic jtag_init;
    jtag_idcode_t idcode;
    dm::dmcontrol_t dmcontrol = '{dmactive: 1, default: '0};
    // Reset debug module
    jtag_dbg.reset_master();
    // Check ID code
    jtag_dbg.get_idcode(idcode);
    if (idcode != DutCfg.DbgIdCode)
        $fatal(1, "[JTAG] Unexpected ID code: expected 0x%h, got 0x%h!", idcode, DutCfg.DbgIdCode);
    // Activate, wait for debug module
    jtag_write(dm::DMControl, dmcontrol);
    do jtag_dbg.read_dmi_exp_backoff(dm::DMControl, dmcontrol);
    while (~dmcontrol.dmactive);
    // Activate, wait for system bus
    jtag_write(dm::SBCS, JtagInitSbcs, 0, 1);
    $display("[JTAG] Initializion success");
  endtask

  // Load a binary; this expects precautions to have been taken (e.g. halted hart)
  task automatic jtag_elf_preload(input string binary, output doub_bt entry);
    longint sec_addr, sec_len;
    $display("[JTAG] Preloading ELF binary: %s", binary);
    if (read_elf(binary))
      $fatal(1, "[JTAG] Failed to load ELF!");
    while (get_section(sec_addr, sec_len)) begin
      byte bf[] = new [sec_len];
      $display("[JTAG] Preloading section at 0x%h (%0d bytes)", sec_addr, sec_len);
      if (read_section(sec_addr, bf, sec_len)) $fatal(1, "[JTAG] Failed to read ELF section!");
      jtag_write(dm::SBCS, JtagInitSbcs, 1, 1);
      // Write bootloader as 64-bit doubless
      jtag_write(dm::SBAddress1, sec_addr[63:32]);
      jtag_write(dm::SBAddress0, sec_addr[31:0]);
      for (longint i = 0; i <= sec_len ; i += 8) begin
        bit checkpoint = (i != 0 && i % 512 == 0);
        if (checkpoint)
          $display("   %6d/%6d Bytes (%0d%%)", i, sec_len, i*100/(sec_len>1 ? sec_len-1 : 1));
        jtag_write(dm::SBData1, {bf[i+7], bf[i+6], bf[i+5], bf[i+4]});
        jtag_write(dm::SBData0, {bf[i+3], bf[i+2], bf[i+1], bf[i]}, checkpoint, checkpoint);
      end
    end
    void'(get_entry(entry));
    $display("[JTAG] Preload complete");
  endtask

  // Run a binary
  task automatic jtag_elf_run(input string binary);
    dm::dmstatus_t status;
    doub_bt entry;
    // Wait until bootrom initialized LLC
    if (DutCfg.LlcNotBypass) begin
      word_bt regval;
      $display("[JTAG] Wait for LLC configuration");
      jtag_poll_bit0(AmLlc + axi_llc_reg_pkg::AXI_LLC_CFG_SPM_LOW_OFFSET, regval, 20);
    end
    // Halt hart 0
    jtag_write(dm::DMControl, dm::dmcontrol_t'{haltreq: 1, dmactive: 1, default: '0});
    do jtag_dbg.read_dmi_exp_backoff(dm::DMStatus, status);
    while (~status.allhalted);
    $display("[JTAG] Halted hart 0");
    // Preload binary
    jtag_elf_preload(binary, entry);
    // Repoint execution
    jtag_write(dm::Data1, entry[63:32]);
    jtag_write(dm::Data0, entry[31:0]);
    jtag_write(dm::Command, 32'h0033_07b1, 0, 1);
    // Resume hart 0
    jtag_write(dm::DMControl, dm::dmcontrol_t'{resumereq: 1, dmactive: 1, default: '0});
    $display("[JTAG] Resumed hart 0 from 0x%h", entry);
  endtask

  task automatic jtag_wait_for_eoc(output word_bt exit_code);
    jtag_poll_bit0(AmRegs + cheshire_reg_pkg::CHESHIRE_SCRATCH_1_OFFSET, exit_code, 800);
    exit_code >>= 1;
    if (exit_code) $error("[JTAG] FAILED: return code %d", exit_code);
    else $display("[JTAG] SUCCESS");
  endtask

  ////////////
  //  UART  //
  ////////////

  // TODO: Implement UART boot
  assign uart_rx = '0;

  uart_tb_rx #(
    .BAUD_RATE  ( UartBaudRate  ),
    .PARITY_EN  ( UartParityEna )
  ) i_uart_rx_model (
    .rx        ( uart_tx ),
    .rx_en     ( 1'b1 ),
    .word_done ( )
  );

  ///////////
  //  I2C  //
  ///////////

  // TODO:
  assign i2c_sda_i = '0;
  assign i2c_scl_i = '0;

  ////////////////
  //  SPI Host  //
  ////////////////

  // TODO
  assign spih_sd_i = '0;

  ///////////////////
  //  Serial Link  //
  ///////////////////

  // TODO
  assign slink_clk_i  = '0;
  assign slink_i      = '0;

endmodule
