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

  // Number of slave mems
  localparam int unsigned ChsPlaygndNumAxiMems = 3;

  // Total number of master and slaves
  localparam int unsigned ChsPlaygndNumSlvDevices = ChsPlaygndNumDsaDma +
                                                    ChsPlaygndNumPeriphs + ChsPlaygndNumAxiMems;
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
    Dsa0SlvIdx    = 'd1,
    MemWriteSlvIdx    = 'd2,
    MemDmaReadSlvIdx  = 'd3,
    MemCoreReadSlvIdx = 'd4
  } axi_slv_idx_t;

  // External AXI masters indexes
  typedef enum byte_bt {
    Dsa0MstIdx = 'd0
  } axi_mst_idx_t;

  typedef enum doub_bt {
    PeriphsBase   = 'h0000_0000_2000_1000,
    Dsa0Base      = 'h0000_0000_3000_1000,
    MemWriteBase    = 'h0000_0000_4000_0000,
    MemDmaReadBase  = 'h0000_0000_5000_0000,
    MemCoreReadBase = 'h0000_0000_6000_0000
  } axi_start_t;

  // AXI Slave Sizes
  localparam doub_bt PeriphsSize   = 'h0000_0000_0000_9000;
  localparam doub_bt Dsa0Size      = 'h0000_0000_0000_9000;
  localparam doub_bt MemWriteSize    = 'h0000_0000_1000_0000;
  localparam doub_bt MemDmaReadSize  = 'h0000_0000_1000_0000;
  localparam doub_bt MemCoreReadSize = 'h0000_0000_1000_0000;

  typedef enum doub_bt {
    PeriphsEnd   = PeriphsBase + PeriphsSize,
    Dsa0End      = Dsa0Base + Dsa0Size,
    MemWriteEnd    = MemWriteBase    + MemWriteSize,
    MemDmaReadEnd  = MemDmaReadBase  + MemDmaReadSize,
    MemCoreReadEnd = MemCoreReadBase + MemCoreReadSize
  } axi_end_t;

  function automatic cheshire_cfg_t gen_playground_cfg();
    cheshire_cfg_t ret = DefaultCfg;
    ret.Cva6ExtCieLength  = 'h6000_0000; // all above 0x3000_0000 cached
    ret.Cva6ExtCieOnTop   = 1;
    // External AXI ports (at most 8 ports and rules)
    ret.AxiExtNumMst      = 1; // For the playground, traffic DMA(s)
    ret.AxiExtNumSlv      = 5; // For the playground, traffic DMA(s) (config port), system timer
    ret.AxiExtNumRules    = 5;
    // External AXI region map
    ret.AxiExtRegionIdx   = '{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, MemCoreReadSlvIdx,
                              MemDmaReadSlvIdx, MemWriteSlvIdx, Dsa0SlvIdx, PeriphsSlvIdx };
    ret.AxiExtRegionStart = '{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, MemCoreReadBase,
                              MemDmaReadBase,   MemWriteBase,   Dsa0Base,   PeriphsBase   };
    ret.AxiExtRegionEnd   = '{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, MemCoreReadEnd,
                              MemDmaReadEnd,    MemWriteEnd,    Dsa0End,    PeriphsEnd    };
    ret.BusErr            = 0;
    ret.AxiRt             = 1;
    return ret;
  endfunction

  localparam cheshire_cfg_t ChsPlaygndCfg = gen_playground_cfg();

endpackage
