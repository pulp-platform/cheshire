// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

module fixture_cheshire_soc #(
  /// The selected simulation configuration from the `tb_cheshire_pkg`.
  parameter int unsigned SelectedCfg = 32'd2
);

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;
  import tb_cheshire_pkg::*;

  localparam cheshire_cfg_t DutCfg = TbCheshireConfigs[SelectedCfg];

  `CHESHIRE_TYPEDEF_ALL(, DutCfg)

  ///////////
  //  DUT  //
  ///////////

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

  logic uart_tx;
  logic uart_rx;

  logic i2c_sda_o;
  logic i2c_sda_i;
  logic i2c_sda_en;
  logic i2c_scl_o;
  logic i2c_scl_i;
  logic i2c_scl_en;

  logic                 spih_sck_o;
  logic                 spih_sck_en;
  logic [SpihNumCs-1:0] spih_csb_o;
  logic [SpihNumCs-1:0] spih_csb_en;
  logic [ 3:0]          spih_sd_o;
  logic [ 3:0]          spih_sd_i;
  logic [ 3:0]          spih_sd_en;

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
  ) dut (
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
    .vga_blue_o         ( )
  );

  ////////////////////////
  //  Tristate Adapter  //
  ////////////////////////

  wire i2c_sda;
  wire i2c_scl;

  wire                 spih_sck;
  wire [SpihNumCs-1:0] spih_csb;
  wire [ 3:0]          spih_sd;

  vip_cheshire_soc_tristate vip_tristate (.*);

  ///////////
  //  VIP  //
  ///////////

  axi_mst_req_t axi_slink_mst_req;
  axi_mst_rsp_t axi_slink_mst_rsp;

  assign axi_slink_mst_req = '0;

  vip_cheshire_soc #(
    .DutCfg            ( DutCfg ),
    .axi_ext_llc_req_t ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t ( axi_mst_rsp_t ),
    .RstCycles         (16)
  ) vip (.*);


  ////////////
  // co-sim //
  ////////////

`ifndef TARGET_GATE
`ifdef SPIKE_TANDEM
  localparam NUM_WORDS = 2**24;
  localparam NR_COMMIT_PORTS = 7; // c910 has 7 ex pipe
  localparam NR_RETIRE_PORTS = 3; // c910 is 3 issue
  localparam ROB_CMPLT_CNT = 3;

  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read0_commit // wire
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read1_commit
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read2_commit

  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire0 // wire
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire1
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire2
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire0_pc // wire [39:0]
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire1_pc
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire2_pc

  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_mstatus // wire [63:0]
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_regs.mcause_value // wire [63 :0]
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_regs.cp0_yy_priv_mode // wire [1  :0]
  
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg95_reg_dout // wire [63:0]
  // dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_31.preg // wire [6:0]

  logic [1:0]        priv_lvl;

  logic [NR_COMMIT_PORTS-1:0]         commit_vld;
  logic [NR_RETIRE_PORTS-1:0]         retire_vld;
  logic [NR_RETIRE_PORTS-1:0][39:0]   retire_pc;
  logic [NR_RETIRE_PORTS-1:0][39:0]   retire_nxt_pc;
  logic [NR_RETIRE_PORTS-1:0][1:0]    retire_folded_inst_num_d, retire_folded_inst_num_q;
  
  logic [63:0]       mstatus_value;
  logic [63:0]       mcause_value;
  logic [63:0]       minstret_value;
  logic [63:0]       mcycle_value;

  logic [95:0][63:0] preg_value;
  logic [31:0][6:0]  areg_preg_idx_uncommited, areg_preg_idx_commited;
  logic [31:0][63:0] areg_value;

  // spike #(
  //   .NR_COMMIT_PORTS (NR_COMMIT_PORTS),
  //   .NR_RETIRE_PORTS (NR_RETIRE_PORTS),
  //   .Size ( NUM_WORDS * 8 )
  // ) i_spike (
  //     .clk_i                    ( clk                       ),
  //     .rst_ni                   ( rst_n                     ),
  //     .clint_tick_i             ( rtc                       ),
  //     .commit_vld_i             ( commit_vld                ),
  //     .retire_vld_i             ( retire_vld                ),
  //     .retire_pc_i              ( retire_pc                 ),
  //     .retire_nxt_pc_i          ( retire_nxt_pc             ),
  //     // .retire_folded_inst_num_i ( retire_folded_inst_num_q  ),
  //     .areg_value_i             ( areg_value                ),
  //     .mstatus_value_i          ( mstatus_value             ),
  //     .mcause_value_i           ( mcause_value              ),
  //     .minstret_value_i         ( minstret_value            ),
  //     .priv_lvl_i               ( priv_lvl                  )
  // );
  // initial begin
  //     $display("Running binary in tandem mode");
  // end
`endif

  assign priv_lvl = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_regs.cp0_yy_priv_mode;

  // assign commit_vld[0] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read0_commit;
  // assign commit_vld[1] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read1_commit;
  // assign commit_vld[2] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read2_commit;

  assign commit_vld[0] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.iu_rtu_pipe0_cmplt;
  assign commit_vld[1] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.iu_rtu_pipe1_cmplt;
  assign commit_vld[2] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.iu_rtu_pipe2_cmplt;
  assign commit_vld[3] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.lsu_rtu_wb_pipe3_cmplt;
  assign commit_vld[4] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.lsu_rtu_wb_pipe4_cmplt;
  assign commit_vld[5] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.vfpu_rtu_pipe6_cmplt;
  assign commit_vld[6] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.vfpu_rtu_pipe7_cmplt;


  assign retire_vld[0] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire0;
  assign retire_vld[1] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire1;
  assign retire_vld[2] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire2;

  assign retire_pc[0] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire0_pc;
  assign retire_pc[1] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire1_pc;
  assign retire_pc[2] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_retire2_pc;
  
  assign retire_nxt_pc[0] = {dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_retire_inst0_next_pc, 1'b0};
  assign retire_nxt_pc[1] = {dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_retire_inst1_next_pc, 1'b0};
  assign retire_nxt_pc[2] = {dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_retire_inst2_next_pc, 1'b0};

  assign retire_folded_inst_num_d[0] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read0_data[ROB_CMPLT_CNT:ROB_CMPLT_CNT-1];
  assign retire_folded_inst_num_d[1] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read1_data[ROB_CMPLT_CNT:ROB_CMPLT_CNT-1];
  assign retire_folded_inst_num_d[2] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read2_data[ROB_CMPLT_CNT:ROB_CMPLT_CNT-1];

  // always_ff @(posedge clk or negedge rst_n) begin
  //   if(!rst_n) begin
  //     retire_folded_inst_num_q  <= '0;
  //   end else begin
  //     retire_folded_inst_num_q  <= retire_folded_inst_num_d;
  //   end
  // end

  assign mstatus_value  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.core0_pad_mstatus;
  assign mcause_value   = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_regs.mcause_value;
  assign minstret_value = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_hpcp_top.minstret_value;
  assign mcycle_value   = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_hpcp_top.mcycle_value;

  generate
    for(genvar i = 0; i < 32; i++) begin
      assign areg_value[i] = preg_value[areg_preg_idx_commited[i]];
    end     
  endgenerate

  assign areg_preg_idx_uncommited[0]  = '0;
  assign areg_preg_idx_uncommited[1]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_1.preg;
  assign areg_preg_idx_uncommited[2]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_2.preg;
  assign areg_preg_idx_uncommited[3]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_3.preg;
  assign areg_preg_idx_uncommited[4]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_4.preg;
  assign areg_preg_idx_uncommited[5]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_5.preg;
  assign areg_preg_idx_uncommited[6]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_6.preg;
  assign areg_preg_idx_uncommited[7]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_7.preg;
  assign areg_preg_idx_uncommited[8]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_8.preg;
  assign areg_preg_idx_uncommited[9]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_9.preg;
  assign areg_preg_idx_uncommited[10] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_10.preg;
  assign areg_preg_idx_uncommited[11] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_11.preg;
  assign areg_preg_idx_uncommited[12] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_12.preg;
  assign areg_preg_idx_uncommited[13] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_13.preg;
  assign areg_preg_idx_uncommited[14] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_14.preg;
  assign areg_preg_idx_uncommited[15] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_15.preg;
  assign areg_preg_idx_uncommited[16] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_16.preg;
  assign areg_preg_idx_uncommited[17] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_17.preg;
  assign areg_preg_idx_uncommited[18] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_18.preg;
  assign areg_preg_idx_uncommited[19] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_19.preg;
  assign areg_preg_idx_uncommited[20] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_20.preg;
  assign areg_preg_idx_uncommited[21] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_21.preg;
  assign areg_preg_idx_uncommited[22] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_22.preg;
  assign areg_preg_idx_uncommited[23] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_23.preg;
  assign areg_preg_idx_uncommited[24] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_24.preg;
  assign areg_preg_idx_uncommited[25] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_25.preg;
  assign areg_preg_idx_uncommited[26] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_26.preg;
  assign areg_preg_idx_uncommited[27] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_27.preg;
  assign areg_preg_idx_uncommited[28] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_28.preg;
  assign areg_preg_idx_uncommited[29] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_29.preg;
  assign areg_preg_idx_uncommited[30] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_30.preg;
  assign areg_preg_idx_uncommited[31] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_31.preg;


  assign areg_preg_idx_commited[0]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r0_preg;
  assign areg_preg_idx_commited[1]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r1_preg;
  assign areg_preg_idx_commited[2]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r2_preg;
  assign areg_preg_idx_commited[3]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r3_preg;
  assign areg_preg_idx_commited[4]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r4_preg;
  assign areg_preg_idx_commited[5]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r5_preg;
  assign areg_preg_idx_commited[6]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r6_preg;
  assign areg_preg_idx_commited[7]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r7_preg;
  assign areg_preg_idx_commited[8]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r8_preg;
  assign areg_preg_idx_commited[9]  = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r9_preg;
  assign areg_preg_idx_commited[10] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r10_preg;
  assign areg_preg_idx_commited[11] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r11_preg;
  assign areg_preg_idx_commited[12] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r12_preg;
  assign areg_preg_idx_commited[13] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r13_preg;
  assign areg_preg_idx_commited[14] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r14_preg;
  assign areg_preg_idx_commited[15] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r15_preg;
  assign areg_preg_idx_commited[16] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r16_preg;
  assign areg_preg_idx_commited[17] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r17_preg;
  assign areg_preg_idx_commited[18] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r18_preg;
  assign areg_preg_idx_commited[19] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r19_preg;
  assign areg_preg_idx_commited[20] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r20_preg;
  assign areg_preg_idx_commited[21] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r21_preg;
  assign areg_preg_idx_commited[22] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r22_preg;
  assign areg_preg_idx_commited[23] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r23_preg;
  assign areg_preg_idx_commited[24] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r24_preg;
  assign areg_preg_idx_commited[25] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r25_preg;
  assign areg_preg_idx_commited[26] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r26_preg;
  assign areg_preg_idx_commited[27] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r27_preg;
  assign areg_preg_idx_commited[28] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r28_preg;
  assign areg_preg_idx_commited[29] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r29_preg;
  assign areg_preg_idx_commited[30] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r30_preg;
  assign areg_preg_idx_commited[31] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r31_preg;


  assign preg_value[0] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg0_reg_dout;  
  assign preg_value[1] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg1_reg_dout;
  assign preg_value[2] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg2_reg_dout;
  assign preg_value[3] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg3_reg_dout;
  assign preg_value[4] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg4_reg_dout;
  assign preg_value[5] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg5_reg_dout;
  assign preg_value[6] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg6_reg_dout;
  assign preg_value[7] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg7_reg_dout;
  assign preg_value[8] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg8_reg_dout;
  assign preg_value[9] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg9_reg_dout;
  assign preg_value[10] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg10_reg_dout;
  assign preg_value[11] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg11_reg_dout;
  assign preg_value[12] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg12_reg_dout;
  assign preg_value[13] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg13_reg_dout;
  assign preg_value[14] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg14_reg_dout;
  assign preg_value[15] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg15_reg_dout;
  assign preg_value[16] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg16_reg_dout;
  assign preg_value[17] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg17_reg_dout;
  assign preg_value[18] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg18_reg_dout;
  assign preg_value[19] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg19_reg_dout;
  assign preg_value[20] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg20_reg_dout;
  assign preg_value[21] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg21_reg_dout;
  assign preg_value[22] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg22_reg_dout;
  assign preg_value[23] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg23_reg_dout;
  assign preg_value[24] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg24_reg_dout;
  assign preg_value[25] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg25_reg_dout;
  assign preg_value[26] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg26_reg_dout;
  assign preg_value[27] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg27_reg_dout;
  assign preg_value[28] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg28_reg_dout;
  assign preg_value[29] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg29_reg_dout;
  assign preg_value[30] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg30_reg_dout;
  assign preg_value[31] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg31_reg_dout;
  assign preg_value[32] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg32_reg_dout;
  assign preg_value[33] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg33_reg_dout;
  assign preg_value[34] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg34_reg_dout;
  assign preg_value[35] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg35_reg_dout;
  assign preg_value[36] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg36_reg_dout;
  assign preg_value[37] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg37_reg_dout;
  assign preg_value[38] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg38_reg_dout;
  assign preg_value[39] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg39_reg_dout;
  assign preg_value[40] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg40_reg_dout;
  assign preg_value[41] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg41_reg_dout;
  assign preg_value[42] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg42_reg_dout;
  assign preg_value[43] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg43_reg_dout;
  assign preg_value[44] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg44_reg_dout;
  assign preg_value[45] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg45_reg_dout;
  assign preg_value[46] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg46_reg_dout;
  assign preg_value[47] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg47_reg_dout;
  assign preg_value[48] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg48_reg_dout;
  assign preg_value[49] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg49_reg_dout;
  assign preg_value[50] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg50_reg_dout;
  assign preg_value[51] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg51_reg_dout;
  assign preg_value[52] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg52_reg_dout;
  assign preg_value[53] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg53_reg_dout;
  assign preg_value[54] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg54_reg_dout;
  assign preg_value[55] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg55_reg_dout;
  assign preg_value[56] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg56_reg_dout;
  assign preg_value[57] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg57_reg_dout;
  assign preg_value[58] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg58_reg_dout;
  assign preg_value[59] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg59_reg_dout;
  assign preg_value[60] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg60_reg_dout;
  assign preg_value[61] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg61_reg_dout;
  assign preg_value[62] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg62_reg_dout;
  assign preg_value[63] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg63_reg_dout;
  assign preg_value[64] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg64_reg_dout;
  assign preg_value[65] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg65_reg_dout;
  assign preg_value[66] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg66_reg_dout;
  assign preg_value[67] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg67_reg_dout;
  assign preg_value[68] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg68_reg_dout;
  assign preg_value[69] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg69_reg_dout;
  assign preg_value[70] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg70_reg_dout;
  assign preg_value[71] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg71_reg_dout;
  assign preg_value[72] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg72_reg_dout;
  assign preg_value[73] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg73_reg_dout;
  assign preg_value[74] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg74_reg_dout;
  assign preg_value[75] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg75_reg_dout;
  assign preg_value[76] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg76_reg_dout;
  assign preg_value[77] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg77_reg_dout;
  assign preg_value[78] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg78_reg_dout;
  assign preg_value[79] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg79_reg_dout;
  assign preg_value[80] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg80_reg_dout;
  assign preg_value[81] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg81_reg_dout;
  assign preg_value[82] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg82_reg_dout;
  assign preg_value[83] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg83_reg_dout;
  assign preg_value[84] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg84_reg_dout;
  assign preg_value[85] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg85_reg_dout;
  assign preg_value[86] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg86_reg_dout;
  assign preg_value[87] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg87_reg_dout;
  assign preg_value[88] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg88_reg_dout;
  assign preg_value[89] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg89_reg_dout;
  assign preg_value[90] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg90_reg_dout;
  assign preg_value[91] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg91_reg_dout;
  assign preg_value[92] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg92_reg_dout;
  assign preg_value[93] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg93_reg_dout;
  assign preg_value[94] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg94_reg_dout;
  assign preg_value[95] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg95_reg_dout;
`endif


endmodule
