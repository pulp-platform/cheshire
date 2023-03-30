// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

package cheshire_pkg;

  ///////////
  //  SoC  //
  ///////////

  // Return either the argument minus 1 or 0 if 0; useful for IO vector width declaration
  function automatic integer unsigned iomsb (input integer unsigned width);
      return (width != 32'd0) ? unsigned'(width-1) : 32'd0;
  endfunction

  // Parameters defined by generated hardware (regenerate to adapt)
  localparam int unsigned NumIntIntrs     = 51; // Must agree with struct below
  localparam int unsigned NumExtIntrs     = rv_plic_reg_pkg::NumSrc - NumIntIntrs;
  localparam int unsigned SpihNumCs       = spi_host_reg_pkg::NumCS - 1;  // Last CS is dummy
  localparam int unsigned SlinkNumChan    = serial_link_single_channel_reg_pkg::NumChannels;
  localparam int unsigned SlinkNumLanes   = serial_link_single_channel_reg_pkg::NumBits/2;
  localparam int unsigned SlinkMaxClkDiv  = 1 << serial_link_single_channel_reg_pkg::Log2MaxClkDiv;
  localparam int unsigned ClintNumCores   = clint_reg_pkg::NumCores;

  // Default JTAG ID code type
  typedef struct packed {
    bit         _one;
    bit [10:0]  manufacturer;
    bit [15:0]  part_num;
    bit [ 3:0]  version;
  } jtag_idcode_t;

  // PULP Platform manufacturer and default Cheshire part number
  localparam bit [10:0] JtagPulpManufacturer  = 12'h6d9;
  localparam bit [15:0] JtagCheshirePartNum   = 16'hc5e5;
  localparam bit [ 3:0] JtagCheshireVersion   = 4'h1;
  localparam jtag_idcode_t CheshireIdCode = '{
    _one          : 1,
    manufacturer  : JtagPulpManufacturer,
    part_num      : JtagCheshirePartNum,
    version       : JtagCheshireVersion
  };

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
    // CVA6 parameters
    shrt_bt Cva6RASDepth;
    shrt_bt Cva6BTBEntries;
    shrt_bt Cva6BHTEntries;
    shrt_bt Cva6NrPMPEntries;
    doub_bt Cva6ExtCieLength;
    // Hart parameters
    bit     DualCore;
    doub_bt NumExtIrqHarts;
    doub_bt NumExtDbgHarts;
    shrt_bt NumExtIntrs;
    dw_bt   Core1UserAmoBit;
    dw_bt   CoreMaxTxnsPerId;
    dw_bt   CoreMaxUniqIds;
    // AXI parameters
    aw_bt   AddrWidth;
    dw_bt   AxiDataWidth;
    dw_bt   AxiUserWidth;
    aw_bt   AxiMstIdWidth;
    dw_bt   AxiMaxMstTrans;
    dw_bt   AxiMaxSlvTrans;
    // User signals identify atomics masters.
    // A '0 user signal indicates no atomics.
    dw_bt   AxiUserAmoMsb;
    dw_bt   AxiUserAmoLsb;
    doub_bt AxiUserAmoDomain;
    // Reg parameters
    dw_bt   RegMaxReadTxns;
    dw_bt   RegMaxWriteTxns;
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
    jtag_idcode_t DbgIdCode;
    dw_bt   DbgMaxReqs;
    dw_bt   DbgMaxReadTxns;
    dw_bt   DbgMaxWriteTxns;
    aw_bt   DbgAmoNumCuts;
    bit     DbgAmoPostCut;
    // Parameters for LLC
    bit     LlcNotBypass;
    shrt_bt LlcSetAssoc;
    shrt_bt LlcNumLines;
    shrt_bt LlcNumBlocks;
    dw_bt   LlcMaxReadTxns;
    dw_bt   LlcMaxWriteTxns;
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
    dw_bt   SlinkMaxTxnsPerId;
    dw_bt   SlinkMaxUniqIds;
    shrt_bt SlinkMaxClkDiv;
    doub_bt SlinkRegionStart;
    doub_bt SlinkRegionEnd;
    doub_bt SlinkTxAddrMask;
    doub_bt SlinkTxAddrDomain;
    dw_bt   SlinkUserAmoBit;
    // Parameters for DMA
    dw_bt   DmaConfMaxReadTxns;
    dw_bt   DmaConfMaxWriteTxns;
    aw_bt   DmaConfAmoNumCuts;
    bit     DmaConfAmoPostCut;
    // Parameters for GPIO
    bit     GpioInputSyncs;
  } cheshire_cfg_t;

  // Defined interrupts
  typedef struct packed {
    logic [iomsb(NumExtIntrs):0] ext;
    logic [31:0] gpio;
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

  ////////////////////
  //  Interconnect  //
  ////////////////////

  // Return total size of LLC in bytes; this is equal to the maximum LLC SPM capacity.
  function automatic int unsigned get_llc_size(cheshire_cfg_t cfg);
    return cfg.LlcSetAssoc * cfg.LlcNumLines * cfg.LlcNumBlocks * cfg.AxiDataWidth / 8;
  endfunction

  // Static addresses
  localparam doub_bt AmDbg    = 'h0000_0000;  // Base of AXI peripherals
  localparam doub_bt AmBrom   = 'h0200_0000;  // Base of reg peripherals
  localparam doub_bt AmRegs   = 'h0300_0000;
  localparam doub_bt AmLlc    = 'h0300_1000;
  localparam doub_bt AmSlink  = 'h0300_6000;
  localparam doub_bt AmSpm    = 'h1000_0000;  // Cached region at bottom, uncached on top

  // Static masks
  localparam doub_bt AmSpmRegionMask = 'h03FF_FFFF;

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
    axi_in_t ret = '{cores: 0, dbg: 1, default: '0};
    int unsigned i = 1;
    if (cfg.Dma)        begin i++; ret.dma   = i; end
    if (cfg.SerialLink) begin i++; ret.slink = i; end
    if (cfg.Vga)        begin i++; ret.vga   = i; end
    i++;
    ret.ext_base = i;
    ret.num_in = i + cfg.AxiExtNumMst;
    return ret;
  endfunction

  // A generic address rule type (max-width addresses)
  typedef struct packed {
    aw_bt   idx;
    doub_bt start;
    doub_bt pte;
  } arul_t;

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
    arul_t [aw_bt'(-1):0] map;
  } axi_out_t;

  function automatic axi_out_t gen_axi_out(cheshire_cfg_t cfg);
    doub_bt SizeSpm = get_llc_size(cfg);
    axi_out_t ret = '{dbg: 0, reg_demux: 1, default: '0};
    int unsigned i = 1, r = 1;
    ret.map[0] = '{0, AmDbg,   AmDbg + 'h40000};
    ret.map[1] = '{1, 'h0200_0000, 'h0800_0000};
    // Whether we have an LLC or a bypass, the output port is has its
    // own Xbar output with the specified region iff it is connected.
    if (cfg.LlcOutConnect) begin i++; r++; ret.llc = i;
        ret.map[r] = '{i, cfg.LlcOutRegionStart, cfg.LlcOutRegionEnd}; end
    // We can only internally map the SPM region if an LLC exists.
    // Otherwise, we assume external ports map and back the SPM region.
    // We map both the cached and uncached regions.
    if (cfg.LlcNotBypass) begin
      ret.spm = i;
      r++; ret.map[r] = '{i, AmSpm, AmSpm + SizeSpm};
      r++; ret.map[r] = '{i, AmSpm + 'h0400_0000, AmSpm + 'h0400_0000 + SizeSpm};
    end
    if (cfg.Dma)          begin i++; r++; ret.dma = i; ret.map[r] = '{i, 'h0100_0000, 'h0100_1000}; end
    if (cfg.SerialLink)   begin i++; r++; ret.slink = i;
        ret.map[r] = '{i, cfg.SlinkRegionStart, cfg.SlinkRegionEnd}; end
    // External port indices start after iternal ones
    i++; r++;
    ret.ext_base  = i;
    ret.num_out   = i + cfg.AxiExtNumSlv;
    ret.num_rules = r + cfg.AxiExtNumRules + cfg.RegExtNumRules;
    // Append external AXI rules to map
    for (int k = 0; k < cfg.AxiExtNumRules; ++k) begin
      r++;
      ret.map[r] = '{ret.ext_base + cfg.AxiExtRegionIdx[k],
          cfg.AxiExtRegionStart[k], cfg.AxiExtRegionEnd[k]};
    end
    // Append external reg rules to map; these are directed to the reg demux
    for (int j = 0; j < cfg.RegExtNumRules; ++j) begin
      r++;
      ret.map[r] = '{1, cfg.RegExtRegionStart[j], cfg.RegExtRegionEnd[j]};
    end
    return ret;
  endfunction

  // Reg demux slave indices and map
  typedef struct packed {
    aw_bt err;    // Error slave for decoder; has no rules
    aw_bt clint;
    aw_bt plic;
    aw_bt regs;
    aw_bt bootrom;
    aw_bt llc;
    aw_bt uart;
    aw_bt i2c;
    aw_bt spi_host;
    aw_bt gpio;
    aw_bt slink;
    aw_bt vga;
    aw_bt ext_base;
    aw_bt num_out;
    aw_bt num_rules;
    arul_t [aw_bt'(-1):0] map;
  } reg_out_t;

  function automatic reg_out_t gen_reg_out(cheshire_cfg_t cfg);
    reg_out_t ret = '{err: 0, clint: 1, plic: 2, regs: 3, default: '0};
    int unsigned i = 3, r = 2;
    ret.map[0] = '{1, 'h0204_0000, 'h0208_0000};
    ret.map[1] = '{2, 'h0400_0000, 'h0800_0000};
    ret.map[2] = '{3, AmRegs,  AmRegs + 'h1000};
    if (cfg.Bootrom)  begin i++; ret.bootrom  = i; r++; ret.map[r] = '{i, AmBrom, AmBrom + 'h40000}; end
    if (cfg.LlcNotBypass) begin i++; ret.llc  = i; r++; ret.map[r] = '{i, AmLlc,    AmLlc + 'h1000}; end
    if (cfg.Uart)     begin i++; ret.uart     = i; r++; ret.map[r] = '{i, 'h0300_2000, 'h0300_3000}; end
    if (cfg.I2c)      begin i++; ret.i2c      = i; r++; ret.map[r] = '{i, 'h0300_3000, 'h0300_4000}; end
    if (cfg.SpiHost)  begin i++; ret.spi_host = i; r++; ret.map[r] = '{i, 'h0300_4000, 'h0300_5000}; end
    if (cfg.Gpio)     begin i++; ret.gpio     = i; r++; ret.map[r] = '{i, 'h0300_5000, 'h0300_6000}; end
    if (cfg.SerialLink) begin i++; ret.slink  = i; r++; ret.map[r] = '{i, AmSlink, AmSlink +'h1000}; end
    if (cfg.Vga)      begin i++; ret.vga      = i; r++; ret.map[r] = '{i, 'h0300_7000, 'h0300_8000}; end
    i++; r++;
    ret.ext_base  = i;
    ret.num_out   = i + cfg.RegExtNumSlv;
    ret.num_rules = r + cfg.RegExtNumRules;
    // Append external slaves at end of map
    for (int k = 0; k < cfg.AxiExtNumRules; ++k) begin
      r++;
      ret.map[r] = '{ret.ext_base + cfg.RegExtRegionIdx[k],
          cfg.RegExtRegionStart[k], cfg.RegExtRegionEnd[k]};
      end
    return ret;
  endfunction

  ////////////
  //  CVA6  //
  ////////////

  function automatic ariane_pkg::ariane_cfg_t gen_cva6_cfg(cheshire_cfg_t cfg);
    doub_bt SizeSpm = get_llc_size(cfg);
    doub_bt SizeLlcOut = cfg.LlcOutRegionEnd - cfg.LlcOutRegionStart;
    return ariane_pkg::ariane_cfg_t'{
      RASDepth              : cfg.Cva6RASDepth,
      BTBEntries            : cfg.Cva6BTBEntries,
      BHTEntries            : cfg.Cva6BHTEntries,
      NrNonIdempotentRules  : 2,   // Periphs, ExtNonCIE
      NonIdempotentAddrBase : {64'h0000_0000, 64'h4000_0000},
      NonIdempotentLength   : {64'h1000_0000, 64'h6000_0000 - cfg.Cva6ExtCieLength},
      NrExecuteRegionRules  : 5,   // Debug, Bootrom, AllSPM, LLCOut, ExtCIE
      ExecuteRegionAddrBase : {AmDbg, AmBrom, AmSpm, cfg.LlcOutRegionStart, 64'h2000_0000},
      ExecuteRegionLength   : {64'h40000, 64'h40000, 2*SizeSpm, SizeLlcOut, cfg.Cva6ExtCieLength},
      NrCachedRegionRules   : 3,   // CachedSPM, LLCOut, ExtCIE
      CachedRegionAddrBase  : {AmSpm,   cfg.LlcOutRegionStart,  64'h2000_0000},
      CachedRegionLength    : {SizeSpm, SizeLlcOut,             cfg.Cva6ExtCieLength},
      AxiCompliant          : 1,
      SwapEndianess         : 0,
      DmBaseAddress         : AmDbg,
      NrPMPEntries          : cfg.Cva6NrPMPEntries
    };
  endfunction

  ////////////////
  //  Defaults  //
  ////////////////

  // DO *NOT* BLINDLY ADOPT THE BELOW DEFAULTS WITHOUT FURTHER CONSIDERATION.
  // They are intended to provide references on reasonable defaults for *most*
  // parameters for select example SoCs. They will *likely* not be suitable for
  // your purposes and, depending on context, *may not work*. You were warned.

  localparam cheshire_cfg_t DefaultCfg = '{
    // CVA6 parameters
    Cva6RASDepth      : ariane_pkg::ArianeDefaultConfig.RASDepth,
    Cva6BTBEntries    : ariane_pkg::ArianeDefaultConfig.BTBEntries,
    Cva6BHTEntries    : ariane_pkg::ArianeDefaultConfig.BHTEntries,
    Cva6NrPMPEntries  : 0,
    Cva6ExtCieLength  : 'h2000_0000,
    // Harts
    DualCore          : 0,  // Only one core, but rest of config allows for two
    CoreMaxTxnsPerId  : 4,
    CoreMaxUniqIds    : 4,
    // Interconnect
    AddrWidth         : 48,
    AxiDataWidth      : 64,
    AxiUserWidth      : 2,  // Convention: bit 0 for core(s), bit 1 for serial link
    AxiMstIdWidth     : 2,
    AxiMaxMstTrans    : 8,
    AxiMaxSlvTrans    : 8,
    AxiUserAmoMsb     : 1,
    AxiUserAmoLsb     : 0,
    RegMaxReadTxns    : 8,
    RegMaxWriteTxns   : 8,
    RegAmoNumCuts     : 1,
    RegAmoPostCut     : 1,
    // RTC
    RtcFreq           : 32768,
    // Features
    Bootrom           : 1,
    Uart              : 1,
    I2c               : 1,
    SpiHost           : 1,
    Gpio              : 1,
    Dma               : 1,
    SerialLink        : 1,
    Vga               : 1,
    // Debug
    DbgIdCode         : CheshireIdCode,
    DbgMaxReqs        : 4,
    DbgMaxReadTxns    : 4,
    DbgMaxWriteTxns   : 4,
    DbgAmoNumCuts     : 1,
    DbgAmoPostCut     : 1,
    // LLC: 128 KiB, up to 2 GiB DRAM
    LlcNotBypass      : 1,
    LlcSetAssoc       : 8,
    LlcNumLines       : 256,
    LlcNumBlocks      : 8,
    LlcMaxReadTxns    : 8,
    LlcMaxWriteTxns   : 8,
    LlcAmoNumCuts     : 1,
    LlcAmoPostCut     : 1,
    LlcOutConnect     : 1,
    LlcOutRegionStart : 'h8000_0000,
    LlcOutRegionEnd   : 'h1_0000_0000,
    // VGA: RGB332
    VgaRedWidth       : 3,
    VgaGreenWidth     : 3,
    VgaBlueWidth      : 2,
    VgaHCountWidth    : 24, // TODO: Default is 32; is this needed?
    VgaVCountWidth    : 24, // TODO: See above
    // Serial Link: map other chip's lower 32bit to 'h1_000_0000
    SlinkMaxTxnsPerId : 4,
    SlinkMaxUniqIds   : 4,
    SlinkMaxClkDiv    : 1024,
    SlinkRegionStart  : 'h1_0000_0000,
    SlinkRegionEnd    : 'h2_0000_0000,
    SlinkTxAddrMask   : 'hFFFF_FFFF,
    SlinkTxAddrDomain : 'h0000_0000,
    SlinkUserAmoBit   : 1,  // Upper atomics bit for serial link
    // DMA config
    DmaConfMaxReadTxns  : 4,
    DmaConfMaxWriteTxns : 4,
    DmaConfAmoNumCuts   : 1,
    DmaConfAmoPostCut   : 1,
    // GPIOs
    GpioInputSyncs    : 1,
    // All non-set values should be zero
    default: '0
  };

endpackage
