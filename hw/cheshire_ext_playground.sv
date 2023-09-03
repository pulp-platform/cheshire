// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>

`include "cheshire/typedef.svh"
`include "axi/typedef.svh"
`include "apb/typedef.svh"

module cheshire_ext_playground
  import cheshire_pkg::*;
  import cheshire_ext_playground_pkg::*;
#(
  // Cheshire config
  parameter cheshire_cfg_t Cfg = '0,
  // Interconnect types (must agree with Cheshire config)
  parameter type axi_ext_mst_req_t  = logic,
  parameter type axi_ext_mst_rsp_t  = logic,
  parameter type axi_ext_slv_req_t  = logic,
  parameter type axi_ext_slv_rsp_t  = logic,
  parameter type reg_ext_req_t      = logic,
  parameter type reg_ext_rsp_t      = logic
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        test_mode_i,
  input  logic        rtc_i,
  // External AXI crossbar ports
  output axi_ext_mst_req_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_req_o,
  input  axi_ext_mst_rsp_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_rsp_i,
  input  axi_ext_slv_req_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_req_i,
  output axi_ext_slv_rsp_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_rsp_o,
  // External reg demux slaves
  input  reg_ext_req_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_req_i,
  output reg_ext_rsp_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_rsp_o
);

  // General parameters and defines
  `CHESHIRE_TYPEDEF_ALL(chs_playgnd_, Cfg)

  // Generate indices and get maps for all ports
  localparam axi_in_t   AxiIn   = gen_axi_in(Cfg);
  localparam axi_out_t  AxiOut  = gen_axi_out(Cfg);

  localparam int unsigned ChsPlaygndAxiSlvIdWidth = Cfg.AxiMstIdWidth + $clog2(AxiIn.num_in);

  ///////////////////////////////////////////////////////////////
  // Peripheral subsystem (system timer only for measurements) //
  ///////////////////////////////////////////////////////////////

  chs_playgnd_axi_slv_req_t axi_d64_a48_amo_peripherals_req;
  chs_playgnd_axi_slv_rsp_t axi_d64_a48_amo_peripherals_rsp;

  axi_riscv_atomics_structs #(
    .AxiAddrWidth     ( Cfg.AddrWidth          ),
    .AxiDataWidth     ( Cfg.AxiDataWidth       ),
    .AxiIdWidth       ( ChsPlaygndAxiSlvIdWidth),
    .AxiUserWidth     ( Cfg.AxiUserWidth       ),
    .AxiMaxReadTxns   ( Cfg.RegMaxReadTxns     ),
    .AxiMaxWriteTxns  ( Cfg.RegMaxWriteTxns    ),
    .AxiUserAsId      ( 1                      ),
    .AxiUserIdMsb     ( Cfg.AxiUserAmoMsb      ),
    .AxiUserIdLsb     ( Cfg.AxiUserAmoLsb      ),
    .RiscvWordWidth   ( 64                     ),
    .NAxiCuts         ( Cfg.RegAmoNumCuts      ),
    .axi_req_t        ( chs_playgnd_axi_slv_req_t ),
    .axi_rsp_t        ( chs_playgnd_axi_slv_rsp_t )
  ) i_atomics_peripherals (
    .clk_i,
    .rst_ni,
    .axi_slv_req_i ( axi_ext_slv_req_i[PeriphsSlvIdx] ),
    .axi_slv_rsp_o ( axi_ext_slv_rsp_o[PeriphsSlvIdx] ),
    .axi_mst_req_o ( axi_d64_a48_amo_peripherals_req ),
    .axi_mst_rsp_i ( axi_d64_a48_amo_peripherals_rsp )
  );

  chs_playgnd_axi_slv_req_t axi_d64_a48_amo_cut_peripherals_req;
  chs_playgnd_axi_slv_rsp_t axi_d64_a48_amo_cut_peripherals_rsp;

  axi_cut #(
    .Bypass     ( ~Cfg.RegAmoPostCut            ),
    .aw_chan_t  ( chs_playgnd_axi_slv_aw_chan_t ),
    .w_chan_t   ( chs_playgnd_axi_slv_w_chan_t  ),
    .b_chan_t   ( chs_playgnd_axi_slv_b_chan_t  ),
    .ar_chan_t  ( chs_playgnd_axi_slv_ar_chan_t ),
    .r_chan_t   ( chs_playgnd_axi_slv_r_chan_t  ),
    .axi_req_t  ( chs_playgnd_axi_slv_req_t     ),
    .axi_resp_t ( chs_playgnd_axi_slv_rsp_t     )
  ) i_atomics_cut_peripherals (
    .clk_i,
    .rst_ni,
    .slv_req_i  ( axi_d64_a48_amo_peripherals_req ),
    .slv_resp_o ( axi_d64_a48_amo_peripherals_rsp ),
    .mst_req_o  ( axi_d64_a48_amo_cut_peripherals_req ),
    .mst_resp_i ( axi_d64_a48_amo_cut_peripherals_rsp )
  );

  // Convert to d32 a48
  // verilog_lint: waive-start line-length
  `AXI_TYPEDEF_ALL_CT(chs_playgnd_axi_d32_a48_slv,
      chs_playgnd_axi_d32_a48_slv_req_t,
      chs_playgnd_axi_d32_a48_slv_rsp_t,
      chs_playgnd_addr_t,
      chs_playgnd_axi_slv_id_t,
      chs_playgnd_nar_dataw_t,
      chs_playgnd_nar_strb_t,
      chs_playgnd_axi_user_t)
  // verilog_lint: waive-stop line-length

  chs_playgnd_axi_d32_a48_slv_req_t axi_d32_a48_peripherals_req;
  chs_playgnd_axi_d32_a48_slv_rsp_t axi_d32_a48_peripherals_rsp;

  axi_dw_converter #(
    .AxiSlvPortDataWidth  ( Cfg.AxiDataWidth             ),
    .AxiMstPortDataWidth  ( ChsPlaygndAxiNarrowDataWidth ),
    .AxiAddrWidth         ( Cfg.AddrWidth                ),
    .AxiIdWidth           ( ChsPlaygndAxiSlvIdWidth      ),
    .aw_chan_t            ( chs_playgnd_axi_slv_aw_chan_t        ),
    .mst_w_chan_t         ( chs_playgnd_axi_d32_a48_slv_w_chan_t ),
    .slv_w_chan_t         ( chs_playgnd_axi_slv_w_chan_t         ),
    .b_chan_t             ( chs_playgnd_axi_slv_b_chan_t         ),
    .ar_chan_t            ( chs_playgnd_axi_slv_ar_chan_t        ),
    .mst_r_chan_t         ( chs_playgnd_axi_d32_a48_slv_r_chan_t ),
    .slv_r_chan_t         ( chs_playgnd_axi_slv_r_chan_t         ),
    .axi_mst_req_t        ( chs_playgnd_axi_d32_a48_slv_req_t    ),
    .axi_mst_resp_t       ( chs_playgnd_axi_d32_a48_slv_rsp_t    ),
    .axi_slv_req_t        ( chs_playgnd_axi_slv_req_t            ),
    .axi_slv_resp_t       ( chs_playgnd_axi_slv_rsp_t            )
  ) i_axi_dw_converter_peripherals (
    .clk_i,
    .rst_ni,
    .slv_req_i  ( axi_d64_a48_amo_cut_peripherals_req ),
    .slv_resp_o ( axi_d64_a48_amo_cut_peripherals_rsp ),
    .mst_req_o  ( axi_d32_a48_peripherals_req     ),
    .mst_resp_i ( axi_d32_a48_peripherals_rsp     )
  );

  // Convert to d32_a32
  // verilog_lint: waive-start line-length
  `AXI_TYPEDEF_ALL_CT(chs_playgnd_axi_d32_a32_slv,
      chs_playgnd_axi_d32_a32_slv_req_t,
      chs_playgnd_axi_d32_a32_slv_rsp_t,
      chs_playgnd_nar_addrw_t,
      chs_playgnd_axi_slv_id_t,
      chs_playgnd_nar_dataw_t,
      chs_playgnd_nar_strb_t,
      chs_playgnd_axi_user_t)
  // verilog_lint: waive-stop line-length

  chs_playgnd_axi_d32_a32_slv_req_t axi_d32_a32_peripherals_req;
  chs_playgnd_axi_d32_a32_slv_rsp_t axi_d32_a32_peripherals_rsp;

  axi_modify_address #(
    .slv_req_t  ( chs_playgnd_axi_d32_a48_slv_req_t ),
    .mst_addr_t ( chs_playgnd_nar_addrw_t           ),
    .mst_req_t  ( chs_playgnd_axi_d32_a32_slv_req_t ),
    .axi_resp_t ( chs_playgnd_axi_d32_a32_slv_rsp_t )
  ) i_axi_modify_addr_peripherals (
    .slv_req_i     ( axi_d32_a48_peripherals_req               ),
    .slv_resp_o    ( axi_d32_a48_peripherals_rsp               ),
    .mst_req_o     ( axi_d32_a32_peripherals_req               ),
    .mst_resp_i    ( axi_d32_a32_peripherals_rsp               ),
    .mst_aw_addr_i ( axi_d32_a48_peripherals_req.aw.addr[31:0] ),
    .mst_ar_addr_i ( axi_d32_a48_peripherals_req.ar.addr[31:0] )
  );

  // AXI to AXI lite conversion
  // verilog_lint: waive-start line-length
  `AXI_LITE_TYPEDEF_ALL_CT(chs_playgnd_axi_lite_d32_a32,
      chs_playgnd_axi_lite_d32_a32_slv_req_t,
      chs_playgnd_axi_lite_d32_a32_slv_rsp_t,
      chs_playgnd_nar_addrw_t,
      chs_playgnd_nar_dataw_t,
      chs_playgnd_nar_strb_t)
  // verilog_lint: waive-stop line-length

  chs_playgnd_axi_lite_d32_a32_slv_req_t axi_lite_d32_a32_peripherals_req;
  chs_playgnd_axi_lite_d32_a32_slv_rsp_t axi_lite_d32_a32_peripherals_rsp;

  axi_to_axi_lite #(
    .AxiAddrWidth   ( ChsPlaygndAxiNarrowAddrWidth ),
    .AxiDataWidth   ( ChsPlaygndAxiNarrowDataWidth ),
    .AxiIdWidth     ( ChsPlaygndAxiSlvIdWidth      ),
    .AxiUserWidth   ( Cfg.AxiUserWidth             ),
    .AxiMaxWriteTxns( 1                            ),
    .AxiMaxReadTxns ( 1                            ),
    .FallThrough    ( 1                            ),
    .full_req_t     ( chs_playgnd_axi_d32_a32_slv_req_t      ),
    .full_resp_t    ( chs_playgnd_axi_d32_a32_slv_rsp_t      ),
    .lite_req_t     ( chs_playgnd_axi_lite_d32_a32_slv_req_t ),
    .lite_resp_t    ( chs_playgnd_axi_lite_d32_a32_slv_rsp_t )
  ) i_axi_to_axi_lite_peripherals (
    .clk_i,
    .rst_ni,
    .test_i    ( test_mode_i ),
    .slv_req_i ( axi_d32_a32_peripherals_req      ),
    .slv_resp_o( axi_d32_a32_peripherals_rsp      ),
    .mst_req_o ( axi_lite_d32_a32_peripherals_req ),
    .mst_resp_i( axi_lite_d32_a32_peripherals_rsp )
  );

  // Address map of peripheral system
  typedef struct packed {
      logic [31:0] idx;
      chs_playgnd_nar_addrw_t start_addr;
      chs_playgnd_nar_addrw_t end_addr;
  } chs_playgnd_addr_map_rule_t;

  localparam chs_playgnd_addr_map_rule_t [NumApbMst-1:0] PeriphApbAddrMapRule = '{
   '{ idx: SystemTimerIdx,   start_addr: SystemTimerBase,
                             end_addr:   SystemTimerEnd
    } // 0: System Timer
  };

  // APB req/rsp
  `APB_TYPEDEF_REQ_T(chs_playgnd_apb_req_t,
      chs_playgnd_nar_addrw_t,
      chs_playgnd_nar_dataw_t,
      chs_playgnd_nar_strb_t)
  `APB_TYPEDEF_RESP_T(chs_playgnd_apb_rsp_t,
      chs_playgnd_nar_dataw_t)

  // APB masters
  chs_playgnd_apb_req_t [NumApbMst-1:0] apb_mst_req;
  chs_playgnd_apb_rsp_t [NumApbMst-1:0] apb_mst_rsp;

  axi_lite_to_apb #(
    .NoApbSlaves     ( NumApbMst                           ),
    .NoRules         ( NumApbMst                           ),
    .AddrWidth       ( ChsPlaygndAxiNarrowAddrWidth        ),
    .DataWidth       ( ChsPlaygndAxiNarrowDataWidth        ),
    .PipelineRequest ( '0                                  ),
    .PipelineResponse( '0                                  ),
    .axi_lite_req_t  ( chs_playgnd_axi_lite_d32_a32_slv_req_t ),
    .axi_lite_resp_t ( chs_playgnd_axi_lite_d32_a32_slv_rsp_t ),
    .apb_req_t       ( chs_playgnd_apb_req_t                  ),
    .apb_resp_t      ( chs_playgnd_apb_rsp_t                  ),
    .rule_t          ( chs_playgnd_addr_map_rule_t            )
  ) i_axi_lite_to_apb_peripherals (
    .clk_i,
    .rst_ni,
    .axi_lite_req_i ( axi_lite_d32_a32_peripherals_req     ),
    .axi_lite_resp_o( axi_lite_d32_a32_peripherals_rsp     ),
    .apb_req_o      ( apb_mst_req                          ),
    .apb_resp_i     ( apb_mst_rsp                          ),
    .addr_map_i     ( PeriphApbAddrMapRule                 )
  );

  // System timer
  apb_timer_unit #(
    .APB_ADDR_WIDTH ( ChsPlaygndAxiNarrowAddrWidth )
  ) i_system_timer (
    .HCLK       ( clk_i  ),
    .HRESETn    ( rst_ni ),
    .PADDR      ( apb_mst_req[SystemTimerIdx].paddr   ),
    .PWDATA     ( apb_mst_req[SystemTimerIdx].pwdata  ),
    .PWRITE     ( apb_mst_req[SystemTimerIdx].pwrite  ),
    .PSEL       ( apb_mst_req[SystemTimerIdx].psel    ),
    .PENABLE    ( apb_mst_req[SystemTimerIdx].penable ),
    .PRDATA     ( apb_mst_rsp[SystemTimerIdx].prdata  ),
    .PREADY     ( apb_mst_rsp[SystemTimerIdx].pready  ),
    .PSLVERR    ( apb_mst_rsp[SystemTimerIdx].pslverr ),
    .ref_clk_i  ( rtc_i ),
    .event_lo_i ( '0    ),
    .event_hi_i ( '0    ),
    .irq_lo_o   ( /* Unconnected, using freerunning timer */ ),
    .irq_hi_o   ( /* Unconnected, using freerunning timer */ ),
    .busy_o     ( /* Unconnected */ )
  );


  ///////////////////////////////////////
  // DSAs' traffic generators (dma(s)) //
  ///////////////////////////////////////

  chs_playgnd_axi_slv_req_t [ChsPlaygndNumDsaDma-1:0] dsa_dma_amo_req, dsa_dma_cut_req;
  chs_playgnd_axi_slv_rsp_t [ChsPlaygndNumDsaDma-1:0] dsa_dma_amo_rsp, dsa_dma_cut_rsp;

  if (ChsPlaygndNumSlvDevices != Cfg.AxiExtNumSlv)
    $fatal(1, "the number of slave devices must be equal to the number of slave AXI ports");

  if (ChsPlaygndNumMstDevices != Cfg.AxiExtNumMst)
    $fatal(1, "the number of master devices must be equal to the number of master AXI ports");

  for (genvar i=0; i<ChsPlaygndNumDsaDma; i++) begin : gen_dsa_dmas
    axi_riscv_atomics_structs #(
      .AxiAddrWidth    ( Cfg.AddrWidth    ),
      .AxiDataWidth    ( Cfg.AxiDataWidth ),
      .AxiIdWidth      ( ChsPlaygndAxiSlvIdWidth ),
      .AxiUserWidth    ( Cfg.AxiUserWidth ),
      .AxiMaxReadTxns  ( Cfg.DmaConfMaxReadTxns  ),
      .AxiMaxWriteTxns ( Cfg.DmaConfMaxWriteTxns ),
      .AxiUserAsId     ( 1 ),
      .AxiUserIdMsb    ( Cfg.AxiUserAmoMsb ),
      .AxiUserIdLsb    ( Cfg.AxiUserAmoLsb ),
      .RiscvWordWidth  ( 64 ),
      .NAxiCuts        ( Cfg.DmaConfAmoNumCuts ),
      .axi_req_t       ( chs_playgnd_axi_slv_req_t ),
      .axi_rsp_t       ( chs_playgnd_axi_slv_rsp_t )
    ) i_dsa_dma_conf_atomics (
      .clk_i,
      .rst_ni,
      .axi_slv_req_i ( axi_ext_slv_req_i[Dsa0SlvIdx + i] ),
      .axi_slv_rsp_o ( axi_ext_slv_rsp_o[Dsa0SlvIdx + i] ),
      .axi_mst_req_o ( dsa_dma_amo_req[i] ),
      .axi_mst_rsp_i ( dsa_dma_amo_rsp[i] )
    );

    axi_cut #(
      .Bypass     ( ~Cfg.DmaConfAmoPostCut ),
      .aw_chan_t  ( chs_playgnd_axi_slv_aw_chan_t ),
      .w_chan_t   ( chs_playgnd_axi_slv_w_chan_t  ),
      .b_chan_t   ( chs_playgnd_axi_slv_b_chan_t  ),
      .ar_chan_t  ( chs_playgnd_axi_slv_ar_chan_t ),
      .r_chan_t   ( chs_playgnd_axi_slv_r_chan_t  ),
      .axi_req_t  ( chs_playgnd_axi_slv_req_t ),
      .axi_resp_t ( chs_playgnd_axi_slv_rsp_t )
    ) i_dsa_dma_conf_atomics_cut (
      .clk_i,
      .rst_ni,
      .slv_req_i  ( dsa_dma_amo_req[i] ),
      .slv_resp_o ( dsa_dma_amo_rsp[i] ),
      .mst_req_o  ( dsa_dma_cut_req[i] ),
      .mst_resp_i ( dsa_dma_cut_rsp[i] )
    );

    chs_playgnd_axi_mst_req_t [ChsPlaygndNumDsaDma-1:0] axi_dsa_dma_req;

    always_comb begin
      axi_ext_mst_req_o[Dsa0MstIdx + i]         = axi_dsa_dma_req[i];
      axi_ext_mst_req_o[Dsa0MstIdx + i].aw.user = Cfg.AxiUserDefault;
      axi_ext_mst_req_o[Dsa0MstIdx + i].w.user  = Cfg.AxiUserDefault;
      axi_ext_mst_req_o[Dsa0MstIdx + i].ar.user = Cfg.AxiUserDefault;
    end

    dma_core_wrap #(
      .AxiAddrWidth   ( Cfg.AddrWidth     ),
      .AxiDataWidth   ( Cfg.AxiDataWidth  ),
      .AxiIdWidth     ( Cfg.AxiMstIdWidth ),
      .AxiUserWidth   ( Cfg.AxiUserWidth  ),
      .AxiSlvIdWidth  ( ChsPlaygndAxiSlvIdWidth ),
      .axi_mst_req_t  ( chs_playgnd_axi_mst_req_t ),
      .axi_mst_rsp_t  ( chs_playgnd_axi_mst_rsp_t ),
      .axi_slv_req_t  ( chs_playgnd_axi_slv_req_t ),
      .axi_slv_rsp_t  ( chs_playgnd_axi_slv_rsp_t )
    ) i_dsa_dma (
      .clk_i,
      .rst_ni,
      .testmode_i     ( test_mode_i ),
      .axi_mst_req_o  ( axi_dsa_dma_req[i] ),
      .axi_mst_rsp_i  ( axi_ext_mst_rsp_i[Dsa0MstIdx + i] ),
      .axi_slv_req_i  ( dsa_dma_cut_req[i] ),
      .axi_slv_rsp_o  ( dsa_dma_cut_rsp[i] )
    );
  end

endmodule
