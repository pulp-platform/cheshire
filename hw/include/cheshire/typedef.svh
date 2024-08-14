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
  localparam type __name``_data_t    = logic [__cfg.AxiDataWidth   -1:0]; \
  localparam type __name``_strb_t    = logic [__cfg.AxiDataWidth/8 -1:0]; \
  localparam type __name``_user_t    = logic [__cfg.AxiUserWidth   -1:0]; \
  localparam type __name``_mst_id_t  = logic [__cfg.AxiMstIdWidth  -1:0]; \
  localparam type __name``_slv_id_t  = logic [__cfg.AxiMstIdWidth + \
      $clog2(__name``__AxiIn.num_in)-1:0]; \
  localparam type __name_llc``_id_t  = logic [$bits(__name``_slv_id_t)+__cfg.LlcNotBypass-1:0]; \
  `CHESHIRE_TYPEDEF_AXI_CT(__name``_mst, __addr_t, \
      __name``_mst_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \
  `CHESHIRE_TYPEDEF_AXI_CT(__name``_slv, __addr_t, \
      __name``_slv_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \
  `CHESHIRE_TYPEDEF_AXI_CT(__name``_llc, __addr_t, \
      __name``_llc_id_t, __name``_data_t, __name``_strb_t, __name``_user_t) \

`define CHESHIRE_TYPEDEF_REG(__name, __addr_t) \
  `REG_BUS_TYPEDEF_ALL(__name, __addr_t, logic [31:0], logic [3:0])

`define CHESHIRE_TYPEDEF_MEMORYISLAND_WIDE(__prefix, __cfg) \
  localparam type __prefix``addr_t = logic [__cfg.AddrWidth-1:0]; \
  localparam int wideDataWidth = __cfg.AxiDataWidth*__cfg.MemIslNarrowToWideFactor; \
  localparam type __prefix``_axi_data_t    = logic [wideDataWidth   -1:0]; \
  localparam type __prefix``_axi_strb_t    = logic [wideDataWidth/8 -1:0]; \
  localparam type __prefix``_axi_user_t    = logic [__cfg.AxiUserWidth   -1:0]; \
  localparam type __prefix``_axi_mst_id_t  = logic [0:0]; \
  localparam type __prefix``_axi_slv_id_t  = logic [$clog2(__cfg.MemIslWidePorts):0]; \
  `CHESHIRE_TYPEDEF_AXI_CT(__prefix``_axi_mst, __prefix``addr_t, \
      __prefix``_axi_mst_id_t, __prefix``_axi_data_t, __prefix``_axi_strb_t, __prefix``_axi_user_t) \
  `CHESHIRE_TYPEDEF_AXI_CT(__prefix``_axi_slv, __prefix``addr_t, \
      __prefix``_axi_slv_id_t, __prefix``_axi_data_t, __prefix``_axi_strb_t, __prefix``_axi_user_t) \

// Note that the prefix does *not* include a leading underscore.
`define CHESHIRE_TYPEDEF_ALL(__prefix, __cfg) \
  localparam type __prefix``addr_t = logic [__cfg.AddrWidth-1:0]; \
  `CHESHIRE_TYPEDEF_AXI(__prefix``axi, __prefix``axi_llc, __prefix``addr_t, __cfg) \
  `CHESHIRE_TYPEDEF_REG(__prefix``reg, __prefix``addr_t) \
  `CHESHIRE_TYPEDEF_MEMORYISLAND_WIDE(mem_isl_wide, __cfg)

`endif
