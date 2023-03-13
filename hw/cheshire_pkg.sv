// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

package cheshire_pkg;

  // Return either the argument minus 1 or 0 if 0; useful for IO vector width declaration
  function automatic integer unsigned iomsb (input integer unsigned width);
      return (width != 32'd0) ? unsigned'(width-1) : 32'd0;
  endfunction

  // Parameters defined by generated hardware (regenerate to adapt)
  localparam int unsigned NumIntIntrs     = 20; // Must agree with struct below
  localparam int unsigned NumExtIntrs     = rv_plic_reg_pkg::NumSrc - NumIntIntrs;
  localparam int unsigned SpihNumCs       = spi_host_reg_pkg::NumCS - 1;  // Last CS is dummy
  localparam int unsigned SlinkNumChan    = serial_link_single_channel_reg_pkg::NumChannels;
  localparam int unsigned SlinkNumBits    = serial_link_single_channel_reg_pkg::NumBits;
  localparam int unsigned SlinkMaxClkDiv  = 1 << serial_link_single_channel_reg_pkg::Log2MaxClkDiv;
  localparam int unsigned ClintNumCores   = clint_reg_pkg::NumCores;

  // Bit vector types for parameters.
  //We limit range to keep parameters sane.
  typedef bit [ 7:0] byte_bt;
  typedef bit [15:0] shrt_bt;
  typedef bit [31:0] word_bt;
  typedef bit [63:0] doub_bt;
  typedef bit [ 9:0] dw_bt;   // data widths
  typedef bit [ 5:0] aw_bt;   // address, ID widths or small buffers

  // Externally controllable parameters
  typedef struct packed {
    // Hart parameters
    bit     DualCore;
    doub_bt NumExtIrqHarts;
    doub_bt NumExtDbgHarts;
    shrt_bt NumExtIntrs;
    dw_bt   Core1UserAmoBit;
    aw_bt   CoreMaxTxnsPerId;
    aw_bt   CoreMaxUniqIds;
    // AXI parameters
    aw_bt   AddrWidth;
    dw_bt   AxiDataWidth;
    dw_bt   AxiUserWidth;
    aw_bt   AxiMstIdWidth;
    aw_bt   AxiMaxMstTrans;
    aw_bt   AxiMaxSlvTrans;
    // User signals identify atomics masters.
    // A '0 user signal indicates no atomics.
    dw_bt   AxiUserAmoMsb;
    dw_bt   AxiUserAmoLsb;
    doub_bt AxiUserAmoDomain;
    // Reg parameters
    aw_bt   RegMaxReadTxns;
    aw_bt   RegMaxWriteTxns;
    aw_bt   RegAmoNumCuts;
    bit     RegAmoPostCut;
    // External AXI ports (at most 8 ports and rules)
    bit     [2:0] AxiExtNumMst;
    bit     [2:0] AxiExtNumSlv;
    bit     [2:0] AxiExtNumRules;
    byte_bt [7:0] AxiExtRegionIdx;
    doub_bt [7:0] AxiExtRegionStart;
    doub_bt [7:0] AxiExtRegionEnd;
    // External reg slaves (at most 8 ports and rules)
    bit     [2:0] RegExtNumSlv;
    bit     [2:0] RegExtNumRules;
    byte_bt [7:0] RegExtRegionIdx;
    doub_bt [7:0] RegExtRegionStart;
    doub_bt [7:0] RegExtRegionEnd;
    // Real-time clock speed
    word_bt RtcFreq;
    // Address of platfrom ROM
    word_bt PlatformRom;
    // Enabled hardware features
    bit     Bootrom;
    bit     Uart;
    bit     I2c;
    bit     SpiHost;
    bit     Gpio;
    bit     Dma;
    bit     SerialLink;
    bit     Vga;
    // Parameters for Debug Module
    word_bt DbgIdCode;
    aw_bt   DbgMaxReqs;
    aw_bt   DbgMaxReadTxns;
    aw_bt   DbgMaxWriteTxns;
    aw_bt   DbgAmoNumCuts;
    bit     DbgAmoPostCut;
    // Parameters for LLC
    bit     LlcOrBypass;
    shrt_bt LlcSetAssoc;
    shrt_bt LlcNumLines;
    shrt_bt LlcNumBlocks;
    aw_bt   LlcMaxReadTxns;
    aw_bt   LlcMaxWriteTxns;
    aw_bt   LlcAmoNumCuts;
    bit     LlcAmoPostCut;
    bit     LlcOutConnect;
    doub_bt LlcOutRegionStart;
    doub_bt LlcOutRegionEnd;
    // Parameters for VGA
    byte_bt VgaRedWidth;
    byte_bt VgaGreenWidth;
    byte_bt VgaBlueWidth;
    aw_bt   VgaHCountWidth;
    aw_bt   VgaVCountWidth;
    // Parameters for Serial Link
    aw_bt   SlinkMaxTxnsPerId;
    aw_bt   SlinkMaxUniqIds;
    shrt_bt SlinkMaxClkDiv;
    doub_bt SlinkRegionStart;
    doub_bt SlinkRegionEnd;
    doub_bt SlinkTxAddrMask;
    doub_bt SlinkTxAddrDomain;
    dw_bt   SlinkUserAmoBit;
    // Parameters for DMA
    aw_bt   DmaConfMaxReadTxns;
    aw_bt   DmaConfMaxWriteTxns;
    aw_bt   DmaConfAmoNumCuts;
    bit     DmaConfAmoPostCut;
    // Parameters for GPIO
    bit     GpioInputSyncs;
  } cheshire_cfg_t;

  // Defined interrupts
  typedef struct packed {
    logic [iomsb(NumExtIntrs):0] ext;
    logic gpio;
    logic spih_spi_event;
    logic spih_error;
    logic i2c_host_timeout;
    logic i2c_unexp_stop;
    logic i2c_acq_full;
    logic i2c_tx_overflow;
    logic i2c_tx_stretch;
    logic i2c_cmd_complete;
    logic i2c_sda_unstable;
    logic i2c_stretch_timeout;
    logic i2c_sda_interference;
    logic i2c_scl_interference;
    logic i2c_nak;
    logic i2c_rx_overflow;
    logic i2c_fmt_overflow;
    logic i2c_rx_threshold;
    logic i2c_fmt_threshold;
    logic uart;
    logic zero;
  } cheshire_intr_t;

  // Declare Symbols for externally needed addresses
  localparam doub_bt BaseDbg      = 'hBAAD_F00D;
  localparam doub_bt BaseBootrom  = 'hBAAD_F00D;
  localparam doub_bt BaseSpm      = 'hBAAD_F00D;

  // AXI Xbar master indices
  typedef struct packed {
    aw_bt cores;
    aw_bt dbg;
    aw_bt dma;
    aw_bt slink;
    aw_bt vga;
    aw_bt ext_base;
    aw_bt num_in;
  } axi_in_t;

  function automatic axi_in_t gen_axi_in(cheshire_cfg_t cfg);
    automatic axi_in_t ret = '{cores: 0, dbg: 1, default: '0};
    automatic int unsigned i = 1;
    if (cfg.Dma)        ret.dma   = ++i;
    if (cfg.SerialLink) ret.slink = ++i;
    if (cfg.Vga)        ret.vga   = ++i;
    ret.ext_base  = ++i;
    ret.num_in    = i + cfg.AxiExtNumMst;
    return ret;
  endfunction

  // A generic address rule type (max-width addresses)
  typedef struct packed {
    aw_bt   idx;
    doub_bt start;
    doub_bt pte;
  } arul_bt;

  // AXI Xbar slave indices and map
  typedef struct packed {
    aw_bt dbg;
    aw_bt reg_demux;
    aw_bt llc;
    aw_bt spm;
    aw_bt dma;
    aw_bt slink;
    aw_bt ext_base;
    aw_bt num_out;
    aw_bt num_rules;
    arul_bt [aw_bt'(-1):0] map;
  } axi_out_t;

  function automatic axi_out_t gen_axi_out(cheshire_cfg_t cfg);
    automatic axi_out_t ret = '{dbg: 0, reg_demux: 1, default: '0};
    automatic int unsigned i = 1, r = 1;
    ret.map[0] = '{0, BaseDbg, 'hBAAD_F00D};
    ret.map[1] = '{1, 'hBAAD_F00D, 'hBAAD_F00D};
    // Whether we have an LLC or a bypass, the output port is has its
    // own Xbar output with the specified region iff it is connected.
    if (cfg.LlcOutConnect) begin ret.llc  = ++i;
        ret.map[++r] = '{i, cfg.LlcOutRegionStart, cfg.LlcOutRegionEnd}; end
    // We can only internally map the SPM region if an LLC exists.
    // Otherwise, we assume external ports map and back the SPM region.
    if (cfg.LlcOrBypass)  begin ret.spm   =   i; ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    if (cfg.Dma)          begin ret.dma   = ++i; ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    if (cfg.SerialLink)   begin ret.slink = ++i;
        ret.map[++r] = '{i, cfg.SlinkRegionStart, cfg.SlinkRegionEnd}; end
    // External port indices start after iternal ones
    ret.ext_base  = ++i;
    ret.num_out   = i + cfg.AxiExtNumSlv;
    ret.num_rules = ++r + cfg.AxiExtNumRules + cfg.RegExtNumRules;
    // Append external AXI rules to map
    for (int k = 0; k < cfg.AxiExtNumRules; ++k)
      ret.map[r++] = '{ret.ext_base + cfg.AxiExtRegionIdx[k],
          cfg.AxiExtRegionStart[k], cfg.AxiExtRegionEnd[k]};
    // Append external reg rules to map; these are directed to the reg demux
    for (int j = 0; j < cfg.RegExtNumRules; ++j)
      ret.map[r++] = '{1, cfg.RegExtRegionStart[j], cfg.RegExtRegionEnd[j]};
    return ret;

  endfunction

  // Reg demux slave indices and map
  typedef struct packed {
    aw_bt err;    // Error slave for decoder; has no rules
    aw_bt regs;
    aw_bt clint;
    aw_bt plic;
    aw_bt llc;
    aw_bt bootrom;
    aw_bt uart;
    aw_bt i2c;
    aw_bt spi_host;
    aw_bt gpio;
    aw_bt dma;
    aw_bt slink;
    aw_bt vga;
    aw_bt ext_base;
    aw_bt num_out;
    aw_bt num_rules;
    arul_bt [aw_bt'(-1):0] map;
  } reg_out_t;

  function automatic axi_in_t gen_reg_out(cheshire_cfg_t cfg);
    automatic reg_out_t ret = '{err: 0, regs: 1, clint: 2, plic: 3, default: '0};
    automatic int unsigned i = 3, r = 2;
    ret.map[1] = '{0, 'hBAAD_F00D, 'hBAAD_F00D};
    ret.map[2] = '{1, 'hBAAD_F00D, 'hBAAD_F00D};
    ret.map[3] = '{2, 'hBAAD_F00D, 'hBAAD_F00D};
    if (cfg.LlcOrBypass) begin ret.llc   = ++i;  ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    if (cfg.Bootrom)  begin ret.bootrom  = ++i;  ret.map[++r] = '{i, BaseBootrom, 'hBAAD_F00D}; end
    if (cfg.Uart)     begin ret.uart     = ++i;  ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    if (cfg.I2c)      begin ret.i2c      = ++i;  ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    if (cfg.SpiHost)  begin ret.spi_host = ++i;  ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    if (cfg.Gpio)     begin ret.gpio     = ++i;  ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    if (cfg.Dma)      begin ret.dma      = ++i;  ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    if (cfg.SerialLink) begin ret.slink  = ++i;  ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    if (cfg.Vga)      begin ret.vga      = ++i;  ret.map[++r] = '{i, 'hBAAD_F00D, 'hBAAD_F00D}; end
    ret.ext_base  = ++i;
    ret.num_out   = i + cfg.RegExtNumSlv;
    ret.num_rules = ++r + cfg.RegExtNumRules;
    // Append external slaves at end of map
    for (int k = 0; k < cfg.AxiExtNumRules; ++k)
      ret.map[r++] = '{ret.ext_base + cfg.RegExtRegionIdx[k],
          cfg.RegExtRegionStart[k], cfg.RegExtRegionEnd[k]};
    return ret;
  endfunction

endpackage
