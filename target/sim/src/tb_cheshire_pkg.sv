// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>

/// This package contains parameters used in the simulation environment
package tb_cheshire_pkg;

    import cheshire_pkg::*;

    // An embedded 32 bit config
    function automatic cheshire_cfg_t gen_cheshire_emb_cfg();
      cheshire_cfg_t ret = DefaultCfg;
      ret.Clic = 1;
      ret.Vga = 0;
      ret.SerialLink = 0;
      ret.AxiDataWidth = 32;
      ret.AddrWidth = 32;
      ret.LlcOutRegionEnd = 'hFFFF_FFFF;
      return ret;
    endfunction : gen_cheshire_emb_cfg

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

    // Number of Cheshire configurations
    localparam int unsigned NumCheshireConfigs = 32'd4;

    // Assemble a configuration array indexed by a numeric parameter
    localparam cheshire_cfg_t [NumCheshireConfigs-1:0] TbCheshireConfigs = {
        gen_cheshire_emb_cfg(),   // 4: Embedded configuration
        gen_cheshire_vclic_cfg(), // 3: vCLIC-enabled configuration
        gen_cheshire_clic_cfg(),  // 2: CLIC-enabled configuration
        gen_cheshire_rt_cfg(),    // 1: RT-enabled configuration
        DefaultCfg                // 0: Default configuration
    };

endpackage
