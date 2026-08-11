// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>

/// This package contains parameters used in the simulation environment
package tb_cheshire_pkg;

    import cheshire_pkg::*;

    // A dedicated RT config
    function automatic cheshire_cfg_t gen_cheshire_rt_cfg();
      cheshire_cfg_t ret = DefaultCfg;
      ret.AxiRt = 1;
      return ret;
    endfunction

    // A dedicated CLIC config
    function automatic cheshire_cfg_t gen_cheshire_clic_cfg();
      cheshire_cfg_t ret = DefaultCfg;
      ret.Clic = 1;
      return ret;
    endfunction

    // A dedicated vCLIC config
    function automatic cheshire_cfg_t gen_cheshire_vclic_cfg();
      cheshire_cfg_t ret = DefaultCfg;
      ret.Clic = 1;
      ret.ClicVsclic = 1;
      ret.ClicVsprio = 1;
      ret.ClicNumVsctxts = 4;
      ret.ClicPrioWidth = 1;
      return ret;
    endfunction

    // VGA 640x480 simulation mode
    localparam int unsigned VgaFrameWidth      = 32;
    localparam int unsigned VgaFrameHeight     = 16;
    localparam int unsigned VgaClkDiv          = 2;
    localparam int unsigned VgaHoriFrontPorch  = 16;
    localparam int unsigned VgaHoriSyncSize    = 96;
    localparam int unsigned VgaHoriBackPorch   = 48;
    localparam int unsigned VgaVertFrontPorch  = 10;
    localparam int unsigned VgaVertSyncSize    = 2;
    localparam int unsigned VgaVertBackPorch   = 33;
    localparam bit VgaHsyncPol                 = 1'b1;
    localparam bit VgaVsyncPol                 = 1'b1;

    // Number of Cheshire configurations
    localparam int unsigned NumCheshireConfigs = 32'd4;

    // Assemble a configuration array indexed by a numeric parameter
    localparam cheshire_cfg_t [NumCheshireConfigs-1:0] TbCheshireConfigs = {
        gen_cheshire_vclic_cfg(), // 3: vCLIC-enabled configuration
        gen_cheshire_clic_cfg(),  // 2: CLIC-enabled configuration
        gen_cheshire_rt_cfg(),    // 1: RT-enabled configuration
        DefaultCfg                // 0: Default configuration
    };

endpackage
