// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Configurations and types for the technology-agnostic ASIC implementation top.
//
// The configuration is selected at package level, not by a top parameter, so
// that its types can size the ports of `cheshire_asic_top`. Select it with a
// define, e.g. `-D CHS_ASIC_CFG=1`; this works identically for all tools.

`include "cheshire/typedef.svh"

`ifndef CHS_ASIC_CFG
`define CHS_ASIC_CFG 0
`endif

package cheshire_asic_pkg;

  import cheshire_pkg::*;

  // Base of all implementation configurations: the default one without the
  // bus error units (CVA6 cores, DMA, VGA), which cost area and timing. The
  // LLC atomics' LR/SC queues grant a new entry only when not full, which cuts
  // their pop-to-push path, one of Cheshire's longest; a full queue accepts
  // again one cycle after a pop.
  function automatic cheshire_cfg_t gen_cheshire_asic_base_cfg();
    cheshire_cfg_t ret = DefaultCfg;
    ret.BusErr = 0;
    ret.LlcAmoCutOupPopInpGnt = 1;
    return ret;
  endfunction

  function automatic cheshire_cfg_t gen_cheshire_asic_clic_cfg();
    cheshire_cfg_t ret = gen_cheshire_asic_base_cfg();
    ret.Clic = 1;
    return ret;
  endfunction

  function automatic cheshire_cfg_t gen_cheshire_asic_rt_cfg();
    cheshire_cfg_t ret = gen_cheshire_asic_base_cfg();
    ret.AxiRt = 1;
    return ret;
  endfunction

  // Number of implementation configurations
  localparam int unsigned NumAsicCfgs = 32'd3;

  // Assemble a configuration array indexed by `CHS_ASIC_CFG`
  localparam cheshire_cfg_t [NumAsicCfgs-1:0] AsicCfgs = {
    gen_cheshire_asic_rt_cfg(),   // 2: RT-enabled configuration
    gen_cheshire_asic_clic_cfg(), // 1: CLIC-enabled configuration
    gen_cheshire_asic_base_cfg()  // 0: Default configuration
  };

  localparam int unsigned   AsicCfgIdx = `CHS_ASIC_CFG;
  localparam cheshire_cfg_t AsicCfg    = AsicCfgs[AsicCfgIdx];

  `CHESHIRE_TYPEDEF_ALL(asic_, AsicCfg)

endpackage
