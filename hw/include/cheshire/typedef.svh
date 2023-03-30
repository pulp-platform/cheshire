// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

`ifndef CHESHIRE_TYPEDEF_SVH_
`define CHESHIRE_TYPEDEF_SVH_

`include "axi/typedef.svh"
`include "register_interface/typedef.svh"

`define CHESHIRE_TYPEDEF_AXI(__name, __name_llc, __addr_t, __cfg) \
  localparam cheshire_pkg::axi_in_t __name``__AxiIn = cheshire_pkg::gen_axi_in(__cfg); \
  localparam type __name``_data_t    = logic [__cfg.AxiDataWidth   -1:0]; \
  localparam type __name``_strb_t    = logic [__cfg.AxiDataWidth/8 -1:0]; \
  localparam type __name``_user_t    = logic [__cfg.AxiUserWidth   -1:0]; \
  localparam type __name``_mst_id_t  = logic [__cfg.AxiMstIdWidth  -1:0]; \
  localparam type __name``_slv_id_t  = logic [__cfg.AxiMstIdWidth + \
      $clog2(__name``__AxiIn.num_in)-1:0]; \
  localparam type __name_llc``_id_t  = logic [$bits(__name``_slv_id_t)+__cfg.LlcNotBypass-1:0]; \
  `AXI_TYPEDEF_ALL_CT(__name``_mst, __name``_mst_req_t, __name``_mst_rsp_t, __addr_t, \
      __name``_mst_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \
  `AXI_TYPEDEF_ALL_CT(__name``_slv, __name``_slv_req_t, __name``_slv_rsp_t, __addr_t, \
      __name``_slv_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \
  `AXI_TYPEDEF_ALL_CT(__name_llc, __name_llc``_req_t, __name_llc``_rsp_t, __addr_t, \
      __name``_llc_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \

`define CHESHIRE_TYPEDEF_REG(__name, __addr_t) \
  `REG_BUS_TYPEDEF_ALL(__name, __addr_t, logic [31:0], logic [3:0])

// Note that the prefix does *not* include a leading underscore.
`define CHESHIRE_TYPEDEF_ALL(__prefix, __cfg) \
  localparam type __prefix``addr_t = logic [__cfg.AddrWidth-1:0]; \
  `CHESHIRE_TYPEDEF_AXI(__prefix``axi, __prefix``axi_llc, __prefix``addr_t, __cfg) \
  `CHESHIRE_TYPEDEF_REG(__prefix``reg, __prefix``addr_t)

`endif
