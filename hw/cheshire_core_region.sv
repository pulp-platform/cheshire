// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

`include "cheshire/typedef.svh"
`include "ace/assign.svh"
`include "ace/domain.svh"

// Parametric core region: instantiates `Cfg.NumCores` CVA6 cores and exposes an
// AXI manager view to the Cheshire crossbar. When `Cfg.Coherence` is set the cores
// are ACE masters aggregated by a CCU; otherwise they are plain AXI masters.
module cheshire_core_region import cheshire_pkg::*; #(
  parameter cheshire_cfg_t Cfg          = '0,
  parameter logic [63:0]   BootAddr     = '0,
  parameter type           axi_mst_req_t = logic,
  parameter type           axi_mst_rsp_t = logic,
  parameter type           reg_req_t     = logic,
  parameter type           reg_rsp_t     = logic,
  // Derived
  localparam int unsigned  NumIntHarts     = Cfg.NumCores,
  localparam int unsigned  NumNocMst       = Cfg.Coherence ? 1 : NumIntHarts,
  localparam int unsigned  NumClicSysIntrs = NumIntIntrs + Cfg.NumExtClicIntrs,
  localparam int unsigned  NumClicIntrs    = NumCoreIrqs + NumClicSysIntrs
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic test_mode_i,
  // Hart interrupts
  input  cheshire_xeip_t [NumIntHarts-1:0] xeip_i,
  input  logic           [NumIntHarts-1:0] mtip_i,
  input  logic           [NumIntHarts-1:0] msip_i,
  input  logic           [NumIntHarts-1:0] debug_req_i,
  // Debug info
  output dm::hartinfo_t   [NumIntHarts-1:0] hartinfo_o,
  output logic            [NumIntHarts-1:0] unavail_o,
  // CLIC interrupt sources (one system-interrupt vector per core)
  input  logic [NumIntHarts-1:0][NumClicSysIntrs-1:0] clic_intr_i,
  // Combined core bus-error interrupt
  output axi_err_intr_t core_bus_err_intr_o,
  // Per-core CLIC register interface
  input  reg_req_t [NumIntHarts-1:0] clic_reg_req_i,
  output reg_rsp_t [NumIntHarts-1:0] clic_reg_rsp_o,
  // Per-core bus-error-unit register interface
  input  reg_req_t [NumIntHarts-1:0] bus_err_reg_req_i,
  output reg_rsp_t [NumIntHarts-1:0] bus_err_reg_rsp_o,
  // CCU register interface (coherent mode only)
  input  reg_req_t ccu_reg_req_i,
  output reg_rsp_t ccu_reg_rsp_o,
  // AXI manager ports to the crossbar
  output axi_mst_req_t [NumNocMst-1:0] noc_req_o,
  input  axi_mst_rsp_t [NumNocMst-1:0] noc_rsp_i
);

  localparam config_pkg::cva6_user_cfg_t Cva6Cfg = gen_cva6_cfg(Cfg);

  localparam type addr_t     = logic [Cfg.AddrWidth-1:0];
  localparam type axi_data_t = logic [Cfg.AxiDataWidth-1:0];
  localparam type axi_strb_t = logic [Cfg.AxiDataWidth/8-1:0];
  localparam type axi_user_t = logic [Cfg.AxiUserWidth-1:0];

  typedef struct packed {
    logic [NumClicSysIntrs-1:0] intr;
    cheshire_core_ip_t          core;
  } clic_intr_src_t;

  assign hartinfo_o = {(NumIntHarts){ariane_pkg::DebugHartInfo}};
  assign unavail_o  = '0;

  // Per-core bus-error interrupts, combined into one so cores coordinate handling
  axi_err_intr_t [NumIntHarts-1:0] core_bus_err_intr;
  always_comb begin
    core_bus_err_intr_o = '0;
    for (int i = 0; i < Cfg.BusErr * NumIntHarts; i++)
      core_bus_err_intr_o |= core_bus_err_intr[i];
  end

  // Shared CLIC signals (bus-type agnostic)
  logic [NumIntHarts-1:0] clic_irq_valid, clic_irq_ready;
  logic [NumIntHarts-1:0] clic_irq_kill_req, clic_irq_kill_ack;
  logic [NumIntHarts-1:0] clic_irq_shv, clic_irq_v;
  logic [NumIntHarts-1:0][$clog2(NumClicIntrs)-1:0] clic_irq_id;
  logic [NumIntHarts-1:0][7:0] clic_irq_level;
  riscv::priv_lvl_t [NumIntHarts-1:0] clic_irq_priv;
  logic [NumIntHarts-1:0][5:0] clic_irq_vsid;

  for (genvar i = 0; i < NumIntHarts; i++) begin : gen_clic
    if (Cfg.Clic) begin : gen_clic_en
      clic_intr_src_t clic_intr;
      assign clic_intr = '{
        intr: clic_intr_i[i],
        core: '{
          meip: xeip_i[i].m,
          seip: xeip_i[i].s,
          mtip: mtip_i[i],
          msip: msip_i[i],
          default: '0
        }
      };
      clic #(
        .N_SOURCE    ( NumClicIntrs ),
        .INTCTLBITS  ( Cfg.ClicIntCtlBits ),
        .reg_req_t   ( reg_req_t ),
        .reg_rsp_t   ( reg_rsp_t ),
        .SSCLIC      ( 1 ),
        .USCLIC      ( 0 ),
        .VSCLIC      ( Cfg.ClicVsclic ),
        .N_VSCTXTS   ( Cfg.ClicNumVsctxts ),
        .VSPRIO      ( Cfg.ClicVsprio ),
        .VSPRIO_W    ( Cfg.ClicPrioWidth )
      ) i_clic (
        .clk_i,
        .rst_ni,
        .reg_req_i      ( clic_reg_req_i[i] ),
        .reg_rsp_o      ( clic_reg_rsp_o[i] ),
        .intr_src_i     ( clic_intr ),
        .irq_valid_o    ( clic_irq_valid[i] ),
        .irq_ready_i    ( clic_irq_ready[i] ),
        .irq_id_o       ( clic_irq_id[i]    ),
        .irq_level_o    ( clic_irq_level[i] ),
        .irq_shv_o      ( clic_irq_shv[i]   ),
        .irq_priv_o     ( clic_irq_priv[i]  ),
        .irq_v_o        ( clic_irq_v[i]     ),
        .irq_vsid_o     ( clic_irq_vsid[i]  ),
        .irq_kill_req_o ( clic_irq_kill_req[i] ),
        .irq_kill_ack_i ( clic_irq_kill_ack[i] )
      );
    end else begin : gen_no_clic
      assign clic_irq_valid[i]    = '0;
      assign clic_irq_id[i]       = '0;
      assign clic_irq_level[i]    = '0;
      assign clic_irq_shv[i]      = '0;
      assign clic_irq_priv[i]     = riscv::priv_lvl_t'(0);
      assign clic_irq_v[i]        = '0;
      assign clic_irq_vsid[i]     = '0;
      assign clic_irq_kill_req[i] = '0;
      assign clic_reg_rsp_o[i]    = '0;
    end
  end

  if (Cfg.Coherence) begin : gen_coherent

    `CHESHIRE_TYPEDEF_ACE_CT(cva6_noc, addr_t, cva6_id_t, axi_data_t, axi_strb_t, axi_user_t)

    cva6_noc_req_t       [NumIntHarts-1:0] ccu_in_req;
    cva6_noc_rsp_t       [NumIntHarts-1:0] ccu_in_rsp;
    cva6_noc_snoop_req_t [NumIntHarts-1:0] ccu_out_snoop_req;
    cva6_noc_snoop_rsp_t [NumIntHarts-1:0] ccu_out_snoop_rsp;
    logic                [NumIntHarts-1:0] ccu_in_rack, ccu_in_wack;

    for (genvar i = 0; i < NumIntHarts; i++) begin : gen_cva6_cores
      cva6_noc_req_t core_out_req, core_ur_req;
      cva6_noc_rsp_t core_out_rsp, core_ur_rsp;
      cva6_noc_snoop_req_t core_snoop_req;
      cva6_noc_snoop_rsp_t core_snoop_rsp;

      cva6 #(
        .CVA6Cfg         ( build_config_pkg::build_config(Cva6Cfg) ),
        .axi_ar_chan_t   ( cva6_noc_ar_chan_t ),
        .axi_aw_chan_t   ( cva6_noc_aw_chan_t ),
        .axi_w_chan_t    ( cva6_noc_w_chan_t  ),
        .b_chan_t        ( cva6_noc_b_chan_t  ),
        .r_chan_t        ( cva6_noc_r_chan_t  ),
        .snoop_ac_chan_t ( cva6_noc_snoop_ac_chan_t ),
        .snoop_cr_chan_t ( cva6_noc_snoop_cr_chan_t ),
        .snoop_cd_chan_t ( cva6_noc_snoop_cd_chan_t ),
        .snoop_req_t     ( cva6_noc_snoop_req_t ),
        .snoop_resp_t    ( cva6_noc_snoop_rsp_t ),
        .noc_req_t       ( cva6_noc_req_t ),
        .noc_resp_t      ( cva6_noc_rsp_t )
      ) i_core_cva6 (
        .clk_i,
        .rst_ni,
        .boot_addr_i      ( BootAddr ),
        .hart_id_i        ( 64'(i) ),
        .irq_i            ( xeip_i[i] ),
        .ipi_i            ( msip_i[i] ),
        .time_irq_i       ( mtip_i[i] ),
        .debug_req_i      ( debug_req_i[i] ),
        `ifndef TARGET_OPENHW_CVA6
        .clic_irq_valid_i ( clic_irq_valid[i] ),
        .clic_irq_id_i    ( clic_irq_id[i]    ),
        .clic_irq_level_i ( clic_irq_level[i] ),
        .clic_irq_priv_i  ( clic_irq_priv[i]  ),
        .clic_irq_v_i     ( clic_irq_v[i]     ),
        .clic_irq_vsid_i  ( clic_irq_vsid[i]  ),
        .clic_irq_shv_i   ( clic_irq_shv[i]   ),
        .clic_irq_ready_o ( clic_irq_ready[i] ),
        .clic_kill_req_i  ( clic_irq_kill_req[i] ),
        .clic_kill_ack_o  ( clic_irq_kill_ack[i] ),
        `endif
        .rvfi_probes_o    ( ),
        .cvxif_req_o      ( ),
        .cvxif_resp_i     ( '0 ),
        .snoop_req_i      ( core_snoop_req ),
        .snoop_resp_o     ( core_snoop_rsp ),
        .noc_req_o        ( core_out_req ),
        .noc_resp_i       ( core_out_rsp ),
        .noc_rack_o       ( ccu_in_rack[i] ),
        .noc_wack_o       ( ccu_in_wack[i] )
      );

      if (Cfg.BusErr) begin : gen_cva6_bus_err
        axi_err_unit_wrap #(
          .AddrWidth          ( Cfg.AddrWidth ),
          .IdWidth            ( Cva6IdWidth   ),
          .UserErrBits        ( Cfg.AxiUserErrBits ),
          .UserErrBitsOffset  ( Cfg.AxiUserErrLsb ),
          .NumOutstanding     ( Cfg.CoreMaxTxns ),
          .NumStoredErrors    ( 4 ),
          .DropOldest         ( 1'b0 ),
          .axi_req_t          ( cva6_noc_req_t ),
          .axi_rsp_t          ( cva6_noc_rsp_t ),
          .reg_req_t          ( reg_req_t ),
          .reg_rsp_t          ( reg_rsp_t )
        ) i_cva6_bus_err (
          .clk_i,
          .rst_ni,
          .testmode_i ( test_mode_i ),
          .axi_req_i  ( core_out_req ),
          .axi_rsp_i  ( core_out_rsp ),
          .err_irq_o  ( core_bus_err_intr[i] ),
          .reg_req_i  ( bus_err_reg_req_i[i] ),
          .reg_rsp_o  ( bus_err_reg_rsp_o[i] )
        );
      end else begin : gen_no_bus_err
        assign core_bus_err_intr[i] = '0;
        assign bus_err_reg_rsp_o[i] = '0;
      end

      // Tag user bits with this core's AMO domain
      always_comb begin
        core_ur_req         = core_out_req;
        core_ur_req.aw.user = Cfg.AxiUserDefault;
        core_ur_req.ar.user = Cfg.AxiUserDefault;
        core_ur_req.w.user  = Cfg.AxiUserDefault;
        core_ur_req.aw.user [Cfg.AxiUserAmoMsb:Cfg.AxiUserAmoLsb] = Cfg.CoreUserAmoOffs + i;
        core_ur_req.ar.user [Cfg.AxiUserAmoMsb:Cfg.AxiUserAmoLsb] = Cfg.CoreUserAmoOffs + i;
        core_ur_req.w.user  [Cfg.AxiUserAmoMsb:Cfg.AxiUserAmoLsb] = Cfg.CoreUserAmoOffs + i;
        core_out_rsp        = core_ur_rsp;
      end

      `ACE_ASSIGN_REQ_STRUCT(ccu_in_req[i], core_ur_req)
      `ACE_ASSIGN_RESP_STRUCT(core_ur_rsp, ccu_in_rsp[i])
      `SNOOP_ASSIGN_REQ_STRUCT(core_snoop_req, ccu_out_snoop_req[i])
      `SNOOP_ASSIGN_RESP_STRUCT(ccu_out_snoop_rsp[i], core_snoop_rsp)
    end

    localparam ccu_pkg::ccu_user_config_t CcuUserCfg = '{
      numSubordinates          : NumIntHarts,
      numShareableTransactions : 8,
      numWriteTransactions     : 4,
      numSnoopTransactions     : 4,
      numArFifos               : 8,
      arFifoDepth              : NumIntHarts,
      writeHashWidth           : 2,
      axiAddressWidth          : Cfg.AddrWidth,
      axiDataWidth             : Cfg.AxiDataWidth,
      axiUserWidth             : Cfg.AxiUserWidth,
      axiSubordinateIdWidth    : Cva6IdWidth,
      cachelineWidth           : Cva6Cfg.DcacheLineWidth,
      addressCheckLsb          : 4,
      addressCheckMsb          : 19,
      snoopReqFifoFallthrough  : 1,
      snoopRespFifoFallthrough : 1,
      mmioIntf                 : ccu_pkg::CCU_MMIO_REGBUS,
      enableCSRs               : 1,
      frontendPipeAw           : 1,
      frontendPipeW            : 1,
      frontendPipeB            : 1,
      frontendPipeAr           : 1,
      frontendPipeR            : 1,
      default                  : '0
    };
    localparam ccu_pkg::ccu_config_t CcuCfg = ccu_pkg::ccu_build_cfg(CcuUserCfg);

    typedef logic [CcuCfg.axiManagerIdWidth-1:0] ccu_id_t;
    `CHESHIRE_TYPEDEF_AXI_CT(ccu_axi, addr_t, ccu_id_t, axi_data_t, axi_strb_t, axi_user_t)
    `ACE_TYPEDEF_DOMAIN_TYPEDEF_MAP_T(NumIntHarts, domain_map_t)

    ccu_axi_req_t ccu_out_req;
    ccu_axi_rsp_t ccu_out_rsp;

    domain_map_t [NumIntHarts-1:0] domain_map;
    for (genvar i = 0; i < NumIntHarts; i++) begin : gen_domain_map
      assign domain_map[i].initiator = 1 << i;
      assign domain_map[i].inner      = ~(1 << i);
      assign domain_map[i].outer      = ~(1 << i);
    end

    ccu_top #(
      .ccuCfg                     ( CcuCfg ),
      .domain_map_t               ( domain_map_t ),
      .ccu_ace_subordinate_ar_t   ( cva6_noc_ar_chan_t ),
      .ccu_ace_subordinate_aw_t   ( cva6_noc_aw_chan_t ),
      .ccu_w_t                    ( cva6_noc_w_chan_t ),
      .ccu_ace_subordinate_r_t    ( cva6_noc_r_chan_t ),
      .ccu_ace_subordinate_b_t    ( cva6_noc_b_chan_t ),
      .ccu_ace_subordinate_req_t  ( cva6_noc_req_t ),
      .ccu_ace_subordinate_resp_t ( cva6_noc_rsp_t ),
      .ccu_axi_manager_ar_t       ( ccu_axi_ar_chan_t ),
      .ccu_axi_manager_aw_t       ( ccu_axi_aw_chan_t ),
      .ccu_axi_manager_r_t        ( ccu_axi_r_chan_t ),
      .ccu_axi_manager_b_t        ( ccu_axi_b_chan_t ),
      .ccu_axi_manager_req_t      ( ccu_axi_req_t ),
      .ccu_axi_manager_resp_t     ( ccu_axi_rsp_t ),
      .ccu_snoop_ac_t             ( cva6_noc_snoop_ac_chan_t ),
      .ccu_snoop_cr_t             ( cva6_noc_snoop_cr_chan_t ),
      .ccu_snoop_cd_t             ( cva6_noc_snoop_cd_chan_t ),
      .ccu_snoop_req_t            ( cva6_noc_snoop_req_t ),
      .ccu_snoop_resp_t           ( cva6_noc_snoop_rsp_t ),
      .mmio_req_t                 ( reg_req_t ),
      .mmio_resp_t                ( reg_rsp_t )
    ) i_ace_ccu (
      .clk_i,
      .rst_ni,
      .domain_map_i            ( domain_map ),
      .subordinate_req_i       ( ccu_in_req ),
      .subordinate_resp_o      ( ccu_in_rsp ),
      .subordinate_rack_i      ( ccu_in_rack ),
      .subordinate_wack_i      ( ccu_in_wack ),
      .snoop_req_o             ( ccu_out_snoop_req ),
      .snoop_resp_i            ( ccu_out_snoop_rsp ),
      .manager_req_o           ( ccu_out_req ),
      .manager_resp_i          ( ccu_out_rsp ),
      .mmio_subordinate_req_i  ( ccu_reg_req_i ),
      .mmio_subordinate_resp_o ( ccu_reg_rsp_o )
    );

    axi_iw_converter #(
      .AxiSlvPortIdWidth      ( CcuCfg.axiManagerIdWidth ),
      .AxiMstPortIdWidth      ( Cfg.AxiMstIdWidth ),
      .AxiSlvPortMaxUniqIds   ( 2 ** Cva6IdWidth ),
      .AxiSlvPortMaxTxnsPerId ( 1 ),
      .AxiSlvPortMaxTxns      ( Cfg.CoreMaxTxns ),
      .AxiMstPortMaxUniqIds   ( 2 ** Cfg.AxiMstIdWidth ),
      .AxiMstPortMaxTxnsPerId ( Cfg.CoreMaxTxnsPerId ),
      .AxiAddrWidth           ( Cfg.AddrWidth ),
      .AxiDataWidth           ( Cfg.AxiDataWidth ),
      .AxiUserWidth           ( Cfg.AxiUserWidth ),
      .slv_req_t              ( ccu_axi_req_t ),
      .slv_resp_t             ( ccu_axi_rsp_t ),
      .mst_req_t              ( axi_mst_req_t ),
      .mst_resp_t             ( axi_mst_rsp_t )
    ) i_axi_iw_converter (
      .clk_i,
      .rst_ni,
      .slv_req_i  ( ccu_out_req ),
      .slv_resp_o ( ccu_out_rsp ),
      .mst_req_o  ( noc_req_o[0] ),
      .mst_resp_i ( noc_rsp_i[0] )
    );

  end else begin : gen_noncoherent

    `CHESHIRE_TYPEDEF_AXI_CT(axi_cva6, addr_t, cva6_id_t, axi_data_t, axi_strb_t, axi_user_t)

    assign ccu_reg_rsp_o = '0;

    for (genvar i = 0; i < NumIntHarts; i++) begin : gen_cva6_cores
      axi_cva6_req_t core_out_req, core_ur_req;
      axi_cva6_rsp_t core_out_rsp, core_ur_rsp;

      cva6 #(
        .CVA6Cfg        ( build_config_pkg::build_config(Cva6Cfg) ),
        .axi_ar_chan_t  ( axi_cva6_ar_chan_t ),
        .axi_aw_chan_t  ( axi_cva6_aw_chan_t ),
        .axi_w_chan_t   ( axi_cva6_w_chan_t  ),
        .b_chan_t       ( axi_cva6_b_chan_t  ),
        .r_chan_t       ( axi_cva6_r_chan_t  ),
        .noc_req_t      ( axi_cva6_req_t ),
        .noc_resp_t     ( axi_cva6_rsp_t )
      ) i_core_cva6 (
        .clk_i,
        .rst_ni,
        .boot_addr_i      ( BootAddr ),
        .hart_id_i        ( 64'(i) ),
        .irq_i            ( xeip_i[i] ),
        .ipi_i            ( msip_i[i] ),
        .time_irq_i       ( mtip_i[i] ),
        .debug_req_i      ( debug_req_i[i] ),
        `ifndef TARGET_OPENHW_CVA6
        .clic_irq_valid_i ( clic_irq_valid[i] ),
        .clic_irq_id_i    ( clic_irq_id[i]    ),
        .clic_irq_level_i ( clic_irq_level[i] ),
        .clic_irq_priv_i  ( clic_irq_priv[i]  ),
        .clic_irq_v_i     ( clic_irq_v[i]     ),
        .clic_irq_vsid_i  ( clic_irq_vsid[i]  ),
        .clic_irq_shv_i   ( clic_irq_shv[i]   ),
        .clic_irq_ready_o ( clic_irq_ready[i] ),
        .clic_kill_req_i  ( clic_irq_kill_req[i] ),
        .clic_kill_ack_o  ( clic_irq_kill_ack[i] ),
        `endif
        .rvfi_probes_o    ( ),
        .cvxif_req_o      ( ),
        .cvxif_resp_i     ( '0 ),
        .snoop_req_i      ( '0 ), // unused
        .snoop_resp_o     ( ),    // unused
        .noc_req_o        ( core_out_req ),
        .noc_resp_i       ( core_out_rsp ),
        .noc_rack_o       ( ),    // unused
        .noc_wack_o       ( )     // unused
      );

      if (Cfg.BusErr) begin : gen_cva6_bus_err
        axi_err_unit_wrap #(
          .AddrWidth          ( Cfg.AddrWidth ),
          .IdWidth            ( Cva6IdWidth   ),
          .UserErrBits        ( Cfg.AxiUserErrBits ),
          .UserErrBitsOffset  ( Cfg.AxiUserErrLsb ),
          .NumOutstanding     ( Cfg.CoreMaxTxns ),
          .NumStoredErrors    ( 4 ),
          .DropOldest         ( 1'b0 ),
          .axi_req_t          ( axi_cva6_req_t ),
          .axi_rsp_t          ( axi_cva6_rsp_t ),
          .reg_req_t          ( reg_req_t ),
          .reg_rsp_t          ( reg_rsp_t )
        ) i_cva6_bus_err (
          .clk_i,
          .rst_ni,
          .testmode_i ( test_mode_i ),
          .axi_req_i  ( core_out_req ),
          .axi_rsp_i  ( core_out_rsp ),
          .err_irq_o  ( core_bus_err_intr[i] ),
          .reg_req_i  ( bus_err_reg_req_i[i] ),
          .reg_rsp_o  ( bus_err_reg_rsp_o[i] )
        );
      end else begin : gen_no_bus_err
        assign core_bus_err_intr[i] = '0;
        assign bus_err_reg_rsp_o[i] = '0;
      end

      // Tag user bits with this core's AMO domain
      always_comb begin
        core_ur_req         = core_out_req;
        core_ur_req.aw.user = Cfg.AxiUserDefault;
        core_ur_req.ar.user = Cfg.AxiUserDefault;
        core_ur_req.w.user  = Cfg.AxiUserDefault;
        core_ur_req.aw.user [Cfg.AxiUserAmoMsb:Cfg.AxiUserAmoLsb] = Cfg.CoreUserAmoOffs + i;
        core_ur_req.ar.user [Cfg.AxiUserAmoMsb:Cfg.AxiUserAmoLsb] = Cfg.CoreUserAmoOffs + i;
        core_ur_req.w.user  [Cfg.AxiUserAmoMsb:Cfg.AxiUserAmoLsb] = Cfg.CoreUserAmoOffs + i;
        core_out_rsp        = core_ur_rsp;
      end

      // CVA6's ID encoding is wasteful; remap it statically to pack into available bits
      axi_id_serialize #(
        .AxiSlvPortIdWidth      ( Cva6IdWidth     ),
        .AxiSlvPortMaxTxns      ( Cfg.CoreMaxTxns ),
        .AxiMstPortIdWidth      ( Cfg.AxiMstIdWidth      ),
        .AxiMstPortMaxUniqIds   ( 2 ** Cfg.AxiMstIdWidth ),
        .AxiMstPortMaxTxnsPerId ( Cfg.CoreMaxTxnsPerId   ),
        .AxiAddrWidth           ( Cfg.AddrWidth    ),
        .AxiDataWidth           ( Cfg.AxiDataWidth ),
        .AxiUserWidth           ( Cfg.AxiUserWidth ),
        .AtopSupport            ( 1 ),
        .slv_req_t              ( axi_cva6_req_t ),
        .slv_resp_t             ( axi_cva6_rsp_t ),
        .mst_req_t              ( axi_mst_req_t  ),
        .mst_resp_t             ( axi_mst_rsp_t  ),
        .MstIdBaseOffset        ( '0 ),
        .IdMapNumEntries        ( Cva6IdsUsed ),
        .IdMap                  ( gen_cva6_id_map(Cfg) )
      ) i_axi_id_serialize (
        .clk_i,
        .rst_ni,
        .slv_req_i  ( core_ur_req ),
        .slv_resp_o ( core_ur_rsp ),
        .mst_req_o  ( noc_req_o[i] ),
        .mst_resp_i ( noc_rsp_i[i] )
      );
    end

  end

endmodule
