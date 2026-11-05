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

    // A dedicated coherent multi-core config
    function automatic cheshire_cfg_t gen_cheshire_multicore_cfg(bit [MaxCoresWidth-1:0] num_cores);
      cheshire_cfg_t ret = DefaultCfg;
      ret.NumCores = num_cores;
      return ret;
    endfunction

    // Number of Cheshire configurations
    localparam int unsigned NumCheshireConfigs = 32'd7;

    // Assemble a configuration array indexed by a numeric parameter
    localparam cheshire_cfg_t [NumCheshireConfigs-1:0] TbCheshireConfigs = {
        gen_cheshire_multicore_cfg(8), // 6: Coherent octa-core configuration
        gen_cheshire_multicore_cfg(4), // 5: Coherent quad-core configuration
        gen_cheshire_multicore_cfg(2), // 4: Coherent dual-core configuration
        gen_cheshire_vclic_cfg(),      // 3: vCLIC-enabled configuration
        gen_cheshire_clic_cfg(),       // 2: CLIC-enabled configuration
        gen_cheshire_rt_cfg(),         // 1: RT-enabled configuration
        DefaultCfg                     // 0: Default configuration
    };

endpackage
