// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>

`include "cheshire/typedef.svh"

package cheshire_ext_playground_pkg;

  import cheshire_pkg::*;

  // Number of DSA DMAs
  localparam int unsigned ChsPlaygndNumDsaDma = 1;

  // Number of slave peripherals
  localparam int unsigned ChsPlaygndNumPeriphs = 1;

  // Total number of master and slaves
  localparam int unsigned ChsPlaygndNumSlvDevices = ChsPlaygndNumDsaDma + ChsPlaygndNumPeriphs;
  localparam int unsigned ChsPlaygndNumMstDevices = ChsPlaygndNumDsaDma;

  // Narrow AXI widths
  localparam int unsigned ChsPlaygndAxiNarrowAddrWidth = 32;
  localparam int unsigned ChsPlaygndAxiNarrowDataWidth = 32;
  localparam int unsigned ChsPlaygndAxiNarrowStrobe    = ChsPlaygndAxiNarrowDataWidth/8;

  // Narrow AXI types
  typedef logic [     ChsPlaygndAxiNarrowAddrWidth-1:0] chs_playgnd_nar_addrw_t;
  typedef logic [     ChsPlaygndAxiNarrowDataWidth-1:0] chs_playgnd_nar_dataw_t;
  typedef logic [        ChsPlaygndAxiNarrowStrobe-1:0] chs_playgnd_nar_strb_t;

  // External AXI slaves indexes
  typedef enum byte_bt {
    PeriphsSlvIdx = 'd0,
    Dsa0SlvIdx    = 'd1
  } axi_slv_idx_t;

  // External AXI masters indexes
  typedef enum byte_bt {
    Dsa0MstIdx = 'd0
  } axi_mst_idx_t;

  typedef enum doub_bt {
    PeriphsBase   = 'h0000_0000_2000_1000,
    Dsa0Base      = 'h0000_0000_3000_1000
  } axi_start_t;

  // AXI Slave Sizes
  localparam doub_bt PeriphsSize   = 'h0000_0000_0000_9000;
  localparam doub_bt Dsa0Size      = 'h0000_0000_0000_9000;

  typedef enum doub_bt {
    PeriphsEnd   = PeriphsBase + PeriphsSize,
    Dsa0End      = Dsa0Base + Dsa0Size
  } axi_end_t;

  // APB peripherals
  localparam int unsigned NumApbMst = 1;

  typedef enum int {
    SystemTimerIdx   = 'd0
  } chs_playgnd_peripherals_e;

  // APB start
  typedef enum word_bt {
    SystemTimerBase   = 'h2000_4000
  } apb_start_t;

  // APB Sizes
  localparam word_bt SystemTimerSize   = 'h0000_1000;

  typedef enum word_bt {
    SystemTimerEnd   = SystemTimerBase + SystemTimerSize
  } apb_end_t;

endpackage
