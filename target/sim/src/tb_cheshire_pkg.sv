// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>

/// This package contains parameters used in the simulation environment
package tb_cheshire_pkg;

    import cheshire_pkg::*;

    // A dedicated periph config
    function automatic cheshire_cfg_t gen_cheshire_periph_cfg();
      cheshire_cfg_t ret = DefaultCfg;
      ret.NumExtDbgHarts   = 1;
      ret.NumCores         = 0;
      ret.Bootrom          = 0;
      ret.Uart             = 0;
      ret.I2c              = 0;
      ret.SpiHost          = 0;
      ret.Gpio             = 0;
      ret.Dma              = 0;
      ret.Usb              = 0;
      ret.BusErr           = 0;
      ret.LlcNotBypass     = 0;
      return ret;
    endfunction

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

    // Number of Cheshire configurations
    localparam int unsigned NumCheshireConfigs = 32'd4;

    // Assemble a configuration array indexed by a numeric parameter
    localparam cheshire_cfg_t [NumCheshireConfigs-1:0] TbCheshireConfigs = {
        gen_cheshire_periph_cfg(), // 3: Peripheral-only configuration
        gen_cheshire_clic_cfg(),   // 2: CLIC-enabled configuration
        gen_cheshire_rt_cfg(),     // 1: RT-enabled configuration
        DefaultCfg                 // 0: Default configuration
    };

endpackage
