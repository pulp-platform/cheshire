// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

`ifndef CHESHIRE_TYPEDEF_SVH_
`define CHESHIRE_TYPEDEF_SVH_

`include "axi/typedef.svh"
`include "register_interface/typedef.svh"

`define CHESHIRE_TYPEDEF_AXI_CT(__name, __addr_t, __id_t, __data_t, __strb_t, __user_t) \
  `AXI_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_rsp_t, \
      __addr_t, __id_t, __data_t, __strb_t, __user_t)

`define CHESHIRE_TYPEDEF_AXI(__name, __name_llc, __addr_t, __cfg) \
  localparam cheshire_pkg::axi_in_t __name``__AxiIn = cheshire_pkg::gen_axi_in(__cfg); \
  localparam type __name``_addr_iommu_t = logic [55                     :0]; \
  localparam type __name``_data_t       = logic [__cfg.AxiDataWidth   -1:0]; \
  localparam type __name``_strb_t       = logic [__cfg.AxiDataWidth/8 -1:0]; \
  localparam type __name``_user_t       = logic [__cfg.AxiUserWidth   -1:0]; \
  localparam type __name``_mst_id_t     = logic [__cfg.AxiMstIdWidth  -1:0]; \
  localparam type __name``_slv_id_t     = logic [__cfg.AxiMstIdWidth + \
      $clog2(__name``__AxiIn.num_in)-1:0]; \
  localparam type __name_llc``_id_t  = logic [$bits(__name``_slv_id_t)+__cfg.LlcNotBypass-1:0]; \
  `CHESHIRE_TYPEDEF_AXI_CT(__name``_mst, __addr_t, \
      __name``_mst_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \
  `CHESHIRE_TYPEDEF_AXI_CT(__name``_mst_iommu, __name``_addr_iommu_t, \
      __name``_mst_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \
  `CHESHIRE_TYPEDEF_AXI_CT(__name``_slv, __addr_t, \
      __name``_slv_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \
  `CHESHIRE_TYPEDEF_AXI_CT(__name``_slv_iommu, __name``_addr_iommu_t, \
      __name``_slv_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \
  `CHESHIRE_TYPEDEF_AXI_CT(__name``_llc, __addr_t, \
      __name``_llc_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \

`define CHESHIRE_TYPEDEF_REG(__name, __addr_t) \
  `REG_BUS_TYPEDEF_ALL(__name, __addr_t, logic [31:0], logic [3:0])

`define AXI_TYPEDEF_IOMMU_AW_CHAN_T(__name, addr_t, id_t, user_t, sid_t, ssidv_t, ssid_t )  \
  typedef struct packed {                                       \
   id_t              id;                                        \
   addr_t            addr;                                      \
   axi_pkg::len_t    len;                                       \
   axi_pkg::size_t   size;                                      \
   axi_pkg::burst_t  burst;                                     \
   logic             lock;                                      \
   axi_pkg::cache_t  cache;                                     \
   axi_pkg::prot_t   prot;                                      \
   axi_pkg::qos_t    qos;                                       \
   axi_pkg::region_t region;                                    \
   axi_pkg::atop_t   atop;                                      \
   user_t            user;                                      \
   sid_t             stream_id;                                 \
   ssidv_t           ss_id_valid;                               \
   ssid_t            substream_id;                              \
  } __name;

`define AXI_TYPEDEF_IOMMU_AR_CHAN_T(__name, addr_t, id_t, user_t, sid_t, ssidv_t, ssid_t )  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    user_t            user;                                     \
    sid_t             stream_id;                                \
    ssidv_t           ss_id_valid;                              \
    ssid_t            substream_id;                             \
   } __name;

`define CHESHIRE_TYPEDEF_IOMMU(__name, __cfg)                             \
  localparam type __name``_user_t    = logic [__cfg.AxiUserWidth   -1:0]; \
  localparam type __name``_id_t      = logic [__cfg.AxiMstIdWidth  -1:0]; \
  localparam type __name``_data_t    = logic [__cfg.AxiDataWidth   -1:0]; \
  localparam type __name``_strb_t    = logic [__cfg.AxiDataWidth/8 -1:0]; \
  localparam type iommu_sid_t        = logic [23:0];                      \
  localparam type iommu_ssidv_t      = logic ;                            \
  localparam type iommu_ssid_t       = logic [19:0];                      \
  localparam type __addr_t           = logic [55:0];                      \
  `AXI_TYPEDEF_IOMMU_AW_CHAN_T(__name``_aw_chan_t, __addr_t, __name``_id_t, __name``_user_t,    \
                               iommu_sid_t, iommu_ssidv_t, iommu_ssid_t )                       \
  `AXI_TYPEDEF_IOMMU_AR_CHAN_T(__name``_ar_chan_t, __addr_t, __name``_id_t, __name``_user_t,    \
                               iommu_sid_t, iommu_ssidv_t, iommu_ssid_t )                       \
  `AXI_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __name``_data_t, __name``_strb_t, __name``_user_t)   \
  `AXI_TYPEDEF_B_CHAN_T(__name``_b_chan_t, __name``_id_t,  __name``_user_t)                     \
  `AXI_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __name``_data_t, __name``_id_t, __name``_user_t)     \
  `AXI_TYPEDEF_REQ_T(__name``_req_t, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t) \
  `AXI_TYPEDEF_RESP_T(__name``_rsp_t, __name``_b_chan_t, __name``_r_chan_t)

// Note that the prefix does *not* include a leading underscore.
`define CHESHIRE_TYPEDEF_ALL(__prefix, __cfg)                                               \
  localparam type __prefix``addr_t = logic [__cfg.AddrWidth-1:0];                           \
  `CHESHIRE_TYPEDEF_AXI(__prefix``axi, __prefix``axi_llc, __prefix``addr_t, __cfg)          \
  `CHESHIRE_TYPEDEF_REG(__prefix``reg, __prefix``addr_t)                                    \
  `CHESHIRE_TYPEDEF_IOMMU(__prefix``axi_iommu, __cfg )

`endif
