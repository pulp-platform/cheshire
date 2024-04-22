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

   // An embedded 32 bit config
   function automatic cheshire_cfg_t gen_cheshire_emb_cfg();
      cheshire_cfg_t ret = DefaultCfg;
      ret.Vga = 0;
      ret.SerialLink = 0;
      ret.AxiUserWidth = 64;
      // ret.AxiDataWidth = 64;
      // ret.AddrWidth = 64;
      return ret;
   endfunction : gen_cheshire_emb_cfg

   function automatic cheshire_cfg_t gen_cheshire_memisl_cfg();
      cheshire_cfg_t ret = gen_cheshire_emb_cfg();
      ret.MemoryIsland  = 1;
      ret.LlcNotBypass  = 0;
      ret.LlcOutConnect = 0;
      return ret;
   endfunction : gen_cheshire_memisl_cfg

   // Number of Cheshire configurations
   localparam int unsigned NumCheshireConfigs = 32'd4;

   // Assemble a configuration array indexed by a numeric parameter
   localparam cheshire_cfg_t [NumCheshireConfigs-1:0] TbCheshireConfigs = {
      gen_cheshire_memisl_cfg(),  // 3: Embedded + Memory Island configuration
      gen_cheshire_emb_cfg(),  // 2: Embedded configuration
      gen_cheshire_rt_cfg(),  // 1: RT-enabled configuration
      DefaultCfg  // 0: Default configuration
   };

endpackage
