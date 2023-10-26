// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nils Wistoff <nwistoff@iis.ee.ethz.ch>

`include "axi/typedef.svh"
`include "apb/typedef.svh"

package soc910_pkg;

// 24 MByte in 8 byte words
localparam NumWords = (24 * 1024 * 1024) / 8;
localparam NrMasters = 2; // c910 + debug
localparam AxiAddrWidth = 40;
localparam AxiDataWidth = 128;
localparam AxiIdWidthMaster = 8;
localparam AxiIdWidthSlaves = AxiIdWidthMaster + $clog2(NrMasters); // 5
localparam AxiUserWidth = 2;

`AXI_TYPEDEF_ALL(axi_master,
                 logic [    AxiAddrWidth-1:0],
                 logic [AxiIdWidthMaster-1:0],
                 logic [    AxiDataWidth-1:0],
                 logic [(AxiDataWidth/8)-1:0],
                 logic [    AxiUserWidth-1:0])

`AXI_TYPEDEF_ALL(axi_slave,
                 logic [    AxiAddrWidth-1:0],
                 logic [AxiIdWidthSlaves-1:0],
                 logic [    AxiDataWidth-1:0],
                 logic [(AxiDataWidth/8)-1:0],
                 logic [    AxiUserWidth-1:0])

`AXI_TYPEDEF_ALL(axi_narrow,
                 logic [    AxiAddrWidth-1:0],
                 logic [AxiIdWidthSlaves-1:0],
                 logic [              32-1:0],
                 logic [          (32/8)-1:0],
                 logic [    AxiUserWidth-1:0])

`AXI_LITE_TYPEDEF_ALL(axi_lite,
                      logic [AxiAddrWidth-1:0],
                      logic [          32-1:0],
                      logic [      (32/8)-1:0])

`APB_TYPEDEF_ALL(apb,
                 logic [AxiAddrWidth-1:0],
                 logic [          32-1:0],
                 logic [      (32/8)-1:0])

endpackage
