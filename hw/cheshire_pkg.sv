// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
// Thomas Benz <tbenz@iis.ee.ethz.ch>
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>

package cheshire_pkg;

  ///////////
  //  SoC  //
  ///////////

  // Return either the argument minus 1 or 0 if 0; useful for IO vector width declaration
  function automatic integer unsigned iomsb (input integer unsigned width);
      return (width != 32'd0) ? unsigned'(width-1) : 32'd0;
  endfunction

  // Parameterization constants
  localparam int unsigned MaxCoresWidth     = 5;
  localparam int unsigned MaxExtAxiMstWidth = 4;
  localparam int unsigned MaxExtAxiSlvWidth = 4;
  localparam int unsigned MaxExtRegSlvWidth = 4;

  // Parameters defined by generated hardware (regenerate to adapt)
  localparam int unsigned SpihNumCs       = spi_host_reg_pkg::NumCS - 1;  // Last CS is dummy
  localparam int unsigned SlinkNumChan    = serial_link_single_channel_reg_pkg::NumChannels;
  localparam int unsigned SlinkNumLanes   = serial_link_single_channel_reg_pkg::NumBits/2;
  localparam int unsigned SlinkMaxClkDiv  = 1 << serial_link_single_channel_reg_pkg::Log2MaxClkDiv;
  localparam int unsigned ClintNumCores   = clint_reg_pkg::NumCores;
  localparam int unsigned UsbNumPorts     = spinal_usb_ohci_pkg::NumPhyPorts;

  // Default JTAG ID code type
  typedef struct packed {
    bit [ 3:0]  version;
    bit [15:0]  part_num;
    bit [10:0]  manufacturer;
    bit         _one;
  } jtag_idcode_t;

  // PULP Platform manufacturer and default Cheshire part number
  localparam bit [10:0] JtagPulpManufacturer  = 11'h6d9;
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
    // To reduce parameterization entropy, the range [0x2.., 0x8..) is defined to contain exactly
    // one cached, idempotent, and executable (CIE) and one non-CIE region. The parameters below
    // control the CIE region's size and whether it abuts with the top or bottom of this range.
    doub_bt Cva6ExtCieLength;
    bit     Cva6ExtCieOnTop;
    // Hart parameters
    bit [MaxCoresWidth-1:0] NumCores;
    doub_bt NumExtIrqHarts;
    doub_bt NumExtDbgHarts;
    doub_bt CoreUserAmoOffs;
    dw_bt   CoreMaxTxns;
    dw_bt   CoreMaxTxnsPerId;
    // Interrupt parameters
    doub_bt NumExtInIntrs;
    shrt_bt NumExtClicIntrs;
    byte_bt NumExtOutIntrTgts;
    shrt_bt NumExtOutIntrs;
    shrt_bt ClicIntCtlBits;
    shrt_bt NumExtIntrSyncs;
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
    dw_bt   AxiUserErrBits;
    dw_bt   AxiUserErrLsb;
    doub_bt AxiUserDefault; // Default user assignment, adjusted by user features (AMO)
    // Reg parameters
    dw_bt   RegMaxReadTxns;
    dw_bt   RegMaxWriteTxns;
    aw_bt   RegAmoNumCuts;
    bit     RegAmoPostCut;
    bit     RegAdaptMemCut;
    // External AXI ports (limited number of ports and rules)
    bit     [MaxExtAxiMstWidth-1:0]     AxiExtNumMst;
    bit     [MaxExtAxiSlvWidth-1:0]     AxiExtNumSlv;
    bit     [MaxExtAxiSlvWidth-1:0]     AxiExtNumRules;
    byte_bt [2**MaxExtAxiSlvWidth-1:0]  AxiExtRegionIdx;
    doub_bt [2**MaxExtAxiSlvWidth-1:0]  AxiExtRegionStart;
    doub_bt [2**MaxExtAxiSlvWidth-1:0]  AxiExtRegionEnd;
    // External reg slaves (limited number of ports and rules)
    bit     [MaxExtRegSlvWidth-1:0]     RegExtNumSlv;
    bit     [MaxExtRegSlvWidth-1:0]     RegExtNumRules;
    byte_bt [2**MaxExtRegSlvWidth-1:0]  RegExtRegionIdx;
    doub_bt [2**MaxExtRegSlvWidth-1:0]  RegExtRegionStart;
    doub_bt [2**MaxExtRegSlvWidth-1:0]  RegExtRegionEnd;
    // Real-time clock speed
    word_bt RtcFreq;
    // Address of platform ROM
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
    bit     Usb;
    bit     AxiRt;
    bit     Clic;
    bit     IrqRouter;
    bit     BusErr;
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
    dw_bt   VgaBufferDepth;
    dw_bt   VgaMaxReadTxns;
    // Parameters for Serial Link
    dw_bt   SlinkMaxTxnsPerId;
    dw_bt   SlinkMaxUniqIds;
    shrt_bt SlinkMaxClkDiv;
    doub_bt SlinkRegionStart;
    doub_bt SlinkRegionEnd;
    doub_bt SlinkTxAddrMask;
    doub_bt SlinkTxAddrDomain;
    dw_bt   SlinkUserAmoBit;
    // Parameters for USB
    dw_bt   UsbDmaMaxReads;
    doub_bt UsbAddrMask;
    doub_bt UsbAddrDomain;
    // Parameters for DMA
    dw_bt   DmaConfMaxReadTxns;
    dw_bt   DmaConfMaxWriteTxns;
    aw_bt   DmaConfAmoNumCuts;
    bit     DmaConfAmoPostCut;
    bit     DmaConfEnableTwoD;
    dw_bt   DmaNumAxInFlight;
    dw_bt   DmaMemSysDepth;
    aw_bt   DmaJobFifoDepth;
    bit     DmaRAWCouplingAvail;
    // Parameters for GPIO
    bit     GpioInputSyncs;
    // Parameters for AXI RT
    aw_bt   AxiRtNumPending;
    dw_bt   AxiRtWBufferDepth;
    aw_bt   AxiRtNumAddrRegions;
    bit     AxiRtCutPaths;
    bit     AxiRtEnableChecks;
  } cheshire_cfg_t;

  //////////////////
  //  Interrupts  //
  //////////////////

  // Bus Error interrupts
  typedef struct packed {
    logic r;
    logic w;
  } axi_err_intr_t;

  typedef struct packed {
    axi_err_intr_t cores;
    axi_err_intr_t dma;
    axi_err_intr_t vga;
  } cheshire_bus_err_intr_t;

  // Defined interrupts
  typedef struct packed {
    cheshire_bus_err_intr_t bus_err;
    logic [31:0] gpio;
    logic usb;
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
  } cheshire_int_intr_t;

  typedef struct packed {
    logic [3:0] _rsvd_15to12;
    logic       meip;
    logic       _rsvd_10;
    logic       seip;
    logic       _rsvd_8;
    logic       mtip;
    logic [2:0] _rsvd_6to4;
    logic       msip;
    logic [2:0] _rsvd_2to0;
  } cheshire_core_ip_t;

  typedef struct packed {
    logic s;
    logic m;
  } cheshire_xeip_t;

  // Interrupt parameters
  localparam int unsigned NumIntIntrs     = $bits(cheshire_int_intr_t);
  localparam int unsigned NumIrqCtxts     = $bits(cheshire_xeip_t);
  localparam int unsigned NumCoreIrqs     = $bits(cheshire_core_ip_t);
  localparam int unsigned NumExtPlicIntrs = rv_plic_reg_pkg::NumSrc - NumIntIntrs;

  ////////////////////
  //  Interconnect  //
  ////////////////////

  // Return total size of LLC in bytes; this is equal to the maximum LLC SPM capacity.
  function automatic int unsigned get_llc_size(cheshire_cfg_t cfg);
    return cfg.LlcSetAssoc * cfg.LlcNumLines * cfg.LlcNumBlocks * cfg.AxiDataWidth / 8;
  endfunction

  // Static addresses (defined here only if multiply used)
  localparam doub_bt AmDbg    = 'h0000_0000;  // Base of AXI peripherals
  localparam doub_bt AmBrom   = 'h0200_0000;  // Base of reg peripherals
  localparam doub_bt AmRegs   = 'h0300_0000;
  localparam doub_bt AmLlc    = 'h0300_1000;
  localparam doub_bt AmSlink  = 'h0300_6000;
  localparam doub_bt AmBusErr = 'h0300_9000;
  localparam doub_bt AmSpm    = 'h1000_0000;  // Cached region at bottom, uncached on top
  localparam doub_bt AmSpmUnc = 'h1400_0000;
  localparam doub_bt AmClic   = 'h0800_0000;

  // Static masks
  localparam doub_bt AmSpmRegionMask = 'h03FF_FFFF;

  // Reg bus error unit indices
  localparam int unsigned RegBusErrVga        = 0;
  localparam int unsigned RegBusErrDma        = 1;
  localparam int unsigned RegBusErrCoresBase  = 2;

  // AXI Xbar master indices
  typedef struct packed {
    aw_bt [2**MaxCoresWidth-1:0] cores;
    aw_bt dbg;
    aw_bt dma;
    aw_bt slink;
    aw_bt vga;
    aw_bt usb;
    aw_bt ext_base;
    aw_bt num_in;
  } axi_in_t;

  function automatic axi_in_t gen_axi_in(cheshire_cfg_t cfg);
    axi_in_t ret = '{default: '0};
    int unsigned i = 0;
    for (int j = 0; j < cfg.NumCores; j++) begin ret.cores[i] = i; i++; end
    ret.dbg = i;
    if (cfg.Dma)        begin i++; ret.dma   = i; end
    if (cfg.SerialLink) begin i++; ret.slink = i; end
    if (cfg.Vga)        begin i++; ret.vga   = i; end
    if (cfg.Usb)        begin i++; ret.usb   = i; end
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
    ret.map[1] = '{1, 'h0200_0000, 'h0C00_0000};
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
      r++; ret.map[r] = '{i, AmSpmUnc, AmSpmUnc + SizeSpm};
    end
    if (cfg.Dma)          begin i++; r++; ret.dma = i; ret.map[r] = '{i, 'h0100_0000, 'h0100_1000}; end
    if (cfg.SerialLink)   begin i++; r++; ret.slink = i;
        ret.map[r] = '{i, cfg.SlinkRegionStart, cfg.SlinkRegionEnd}; end
    // External port indices start after internal ones
    i++; r++;
    ret.ext_base  = i;
    ret.num_out   = i + cfg.AxiExtNumSlv;
    ret.num_rules = r + cfg.AxiExtNumRules + cfg.RegExtNumRules;
    // Append external AXI rules to map
    for (int k = 0; k < cfg.AxiExtNumRules; ++k) begin
      ret.map[r] = '{ret.ext_base + cfg.AxiExtRegionIdx[k],
          cfg.AxiExtRegionStart[k], cfg.AxiExtRegionEnd[k]};
      r++;
    end
    // Append external reg rules to map; these are directed to the reg demux
    for (int j = 0; j < cfg.RegExtNumRules; ++j) begin
      ret.map[r] = '{1, cfg.RegExtRegionStart[j], cfg.RegExtRegionEnd[j]};
      r++;
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
    aw_bt usb;
    aw_bt axirt;
    aw_bt irq_router;
    aw_bt [2**MaxCoresWidth-1:0] bus_err;
    aw_bt [2**MaxCoresWidth-1:0] clic;
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
    if (cfg.Bootrom)      begin i++; ret.bootrom    = i; r++; ret.map[r] = '{i, AmBrom, AmBrom + 'h40000}; end
    if (cfg.LlcNotBypass) begin i++; ret.llc        = i; r++; ret.map[r] = '{i, AmLlc,    AmLlc + 'h1000}; end
    if (cfg.Uart)         begin i++; ret.uart       = i; r++; ret.map[r] = '{i, 'h0300_2000, 'h0300_3000}; end
    if (cfg.I2c)          begin i++; ret.i2c        = i; r++; ret.map[r] = '{i, 'h0300_3000, 'h0300_4000}; end
    if (cfg.SpiHost)      begin i++; ret.spi_host   = i; r++; ret.map[r] = '{i, 'h0300_4000, 'h0300_5000}; end
    if (cfg.Gpio)         begin i++; ret.gpio       = i; r++; ret.map[r] = '{i, 'h0300_5000, 'h0300_6000}; end
    if (cfg.SerialLink)   begin i++; ret.slink      = i; r++; ret.map[r] = '{i, AmSlink, AmSlink +'h1000}; end
    if (cfg.Vga)          begin i++; ret.vga        = i; r++; ret.map[r] = '{i, 'h0300_7000, 'h0300_8000}; end
    if (cfg.Usb)          begin i++; ret.usb        = i; r++; ret.map[r] = '{i, 'h0300_8000, 'h0300_9000}; end
    if (cfg.IrqRouter)    begin i++; ret.irq_router = i; r++; ret.map[r] = '{i, 'h0208_0000, 'h020c_0000}; end
    if (cfg.AxiRt)        begin i++; ret.axirt      = i; r++; ret.map[r] = '{i, 'h020c_0000, 'h0210_0000}; end
    if (cfg.Clic) for (int j = 0; j < cfg.NumCores; j++) begin
      i++; ret.clic[j]    = i; r++; ret.map[r] = '{i, AmClic + j*'h40000, AmClic + (j+1)*'h40000};
    end
    if (cfg.BusErr) for (int j = 0; j < 2 + cfg.NumCores; j++) begin
      i++; ret.bus_err[j] = i; r++; ret.map[r] = '{i, AmBusErr + j*'h40,  AmBusErr + (j+1)*'h40};
    end
    i++; r++;
    ret.ext_base  = i;
    ret.num_out   = i + cfg.RegExtNumSlv;
    ret.num_rules = r + cfg.RegExtNumRules;
    // Append external slaves at end of map
    for (int k = 0; k < cfg.RegExtNumRules; ++k) begin
      ret.map[r] = '{ret.ext_base + cfg.RegExtRegionIdx[k],
          cfg.RegExtRegionStart[k], cfg.RegExtRegionEnd[k]};
      r++;
      end
    return ret;
  endfunction

  ////////////
  //  CVA6  //
  ////////////

  // CVA6 imposes an ID width of 4, but only 7 of 16 IDs are ever used
  localparam int unsigned Cva6IdWidth = 4;
  localparam int unsigned Cva6IdsUsed = 7;
  typedef logic [Cva6IdWidth-1:0] cva6_id_t;
  typedef int unsigned cva6_id_map_t [Cva6IdsUsed-1:0][0:1];

  // Symbols for used CVA6 IDs
  typedef enum cva6_id_t {
    Cva6IdBypMmu    = 'b1000,
    Cva6IdBypLoad   = 'b1001,
    Cva6IdBypAccel  = 'b1010,
    Cva6IdBypStore  = 'b1011,
    Cva6IdBypAmo    = 'b1100,
    Cva6IdICache    = 'b0000,
    Cva6IdDCache    = 'b0111
  } cva6_id_e;

  // Choose static colocation of IDs based on how heavily used and/or critical they are
  function automatic cva6_id_map_t gen_cva6_id_map(cheshire_cfg_t cfg);
    int unsigned DefaultMapEntry[2] = '{0, 0};
    case (cfg.AxiMstIdWidth)
      // Provide exclusive ID to I-cache to prevent fetch blocking
      1: return '{'{Cva6IdBypMmu, 0}, '{Cva6IdBypLoad, 0}, '{Cva6IdBypAccel, 0}, '{Cva6IdBypStore, 0},
                  '{Cva6IdBypAmo, 0}, '{Cva6IdICache,  1}, '{Cva6IdDCache,   0}};
      // Colocate Load/Store and MMU/AMO bypasses, respectively
      2: return '{'{Cva6IdBypMmu, 0}, '{Cva6IdBypLoad, 1}, '{Cva6IdBypAccel, 1}, '{Cva6IdBypStore, 1},
                  '{Cva6IdBypAmo, 0}, '{Cva6IdICache,  2}, '{Cva6IdDCache,   3}};
      // Compress output ID space without any serialization
      3: return '{'{Cva6IdBypMmu, 0}, '{Cva6IdBypLoad, 1}, '{Cva6IdBypAccel, 6}, '{Cva6IdBypStore, 2},
                  '{Cva6IdBypAmo, 3}, '{Cva6IdICache,  4}, '{Cva6IdDCache,   5}};
      // With 4b of ID or more, no remapping is necessary; return redundant 0 -> 0 ID remaps.
      // This leaves ID mapping unaltered only if `MstIdBaseOffset` in `axi_id_serialize` is 0.
      default: return '{default: DefaultMapEntry};
    endcase
  endfunction

  function automatic config_pkg::cva6_cfg_t gen_cva6_cfg(cheshire_cfg_t cfg);
    doub_bt SizeSpm = get_llc_size(cfg);
    doub_bt SizeLlcOut = cfg.LlcOutRegionEnd - cfg.LlcOutRegionStart;
    doub_bt CieBase   = cfg.Cva6ExtCieOnTop ? 64'h8000_0000 - cfg.Cva6ExtCieLength : 64'h2000_0000;
    doub_bt NoCieBase = cfg.Cva6ExtCieOnTop ? 64'h2000_0000 : 64'h2000_0000 + cfg.Cva6ExtCieLength;
    return config_pkg::cva6_cfg_t'{
      NrCommitPorts         : 2,
      AxiAddrWidth          : cfg.AddrWidth,
      AxiDataWidth          : cfg.AxiDataWidth,
      AxiIdWidth            : Cva6IdWidth,
      AxiUserWidth          : cfg.AxiUserWidth,
      NrLoadBufEntries      : 2,
      FpuEn                 : 1,
      XF16                  : 0,
      XF16ALT               : 0,
      XF8                   : 0,
      XF8ALT                : 0,
      RVA                   : 1,
      RVB                   : 0,
      RVV                   : 0,
      RVC                   : 1,
      RVH                   : 1,
      RVZCB                 : 1,
      XFVec                 : 0,
      CvxifEn               : 0,
      ZiCondExtEn           : 1,
      RVSCLIC               : cfg.Clic,
      RVF                   : 1,
      RVD                   : 1,
      FpPresent             : 1,
      NSX                   : 0,
      FLen                  : 64,
      RVFVec                : 0,
      XF16Vec               : 0,
      XF16ALTVec            : 0,
      XF8Vec                : 0,
      NrRgprPorts           : 0,
      NrWbPorts             : 0,
      EnableAccelerator     : 0,
      RVS                   : 1,
      RVU                   : 1,
      HaltAddress           : 'h800, // Relative to AmDbg
      ExceptionAddress      : 'h810, // Relative to AmDbg
      RASDepth              : cfg.Cva6RASDepth,
      BTBEntries            : cfg.Cva6BTBEntries,
      BHTEntries            : cfg.Cva6BHTEntries,
      DmBaseAddress         : AmDbg,
      TvalEn                : 1,
      NrPMPEntries          : cfg.Cva6NrPMPEntries,
      PMPCfgRstVal          : {16{64'h0}},
      PMPAddrRstVal         : {16{64'h0}},
      PMPEntryReadOnly      : 16'd0,
      NOCType               : config_pkg::NOC_TYPE_AXI4_ATOP,
      CLICNumInterruptSrc   : NumCoreIrqs + NumIntIntrs + cfg.NumExtClicIntrs,
      NrNonIdempotentRules  : 2,   // Periphs, ExtNonCIE
      NonIdempotentAddrBase : {64'h0000_0000, NoCieBase},
      NonIdempotentLength   : {64'h1000_0000, 64'h6000_0000 - cfg.Cva6ExtCieLength},
      NrExecuteRegionRules  : 6,   // Debug, Bootrom, SPM, SPM Uncached, LLCOut, ExtCIE
      ExecuteRegionAddrBase : {AmDbg,     AmBrom,    AmSpm,   AmSpmUnc, cfg.LlcOutRegionStart, CieBase},
      ExecuteRegionLength   : {64'h40000, 64'h40000, SizeSpm, SizeSpm,  SizeLlcOut,            cfg.Cva6ExtCieLength},
      NrCachedRegionRules   : 3,   // CachedSPM, LLCOut, ExtCIE
      CachedRegionAddrBase  : {AmSpm,   cfg.LlcOutRegionStart,  CieBase},
      CachedRegionLength    : {SizeSpm, SizeLlcOut,             cfg.Cva6ExtCieLength},
      MaxOutstandingStores  : 7,
      DebugEn               : 1,
      NonIdemPotenceEn      : 0,
      AxiBurstWriteEn       : 0
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
    Cva6RASDepth      : 2,
    Cva6BTBEntries    : 32,
    Cva6BHTEntries    : 128,
    Cva6NrPMPEntries  : 0,
    Cva6ExtCieLength  : 'h2000_0000,  // [0x2.., 0x4..) is CIE, [0x4.., 0x8..) is non-CIE
    Cva6ExtCieOnTop   : 0,
    // Harts
    NumCores          : 1,
    CoreMaxTxns       : 8,
    CoreMaxTxnsPerId  : 4,
    CoreUserAmoOffs   : 0, // Convention: lower AMO bits for cores, MSB for serial link
    // Interrupts
    NumExtInIntrs     : 0,
    NumExtClicIntrs   : NumExtPlicIntrs,
    NumExtOutIntrTgts : 0,
    NumExtOutIntrs    : 0,
    ClicIntCtlBits    : 8,
    NumExtIntrSyncs   : 2,
    // Interconnect
    AddrWidth         : 48,
    AxiDataWidth      : 64,
    AxiUserWidth      : 2,  // AMO(2)
    AxiMstIdWidth     : 2,
    AxiMaxMstTrans    : 24,
    AxiMaxSlvTrans    : 24,
    AxiUserAmoMsb     : 1, // Convention: lower AMO bits for cores, MSB for serial link
    AxiUserAmoLsb     : 0, // Convention: lower AMO bits for cores, MSB for serial link
    AxiUserErrBits    : 0,
    AxiUserErrLsb     : 0,
    AxiUserDefault    : 0,
    RegMaxReadTxns    : 8,
    RegMaxWriteTxns   : 8,
    RegAmoNumCuts     : 1,
    RegAmoPostCut     : 1,
    RegAdaptMemCut    : 1,
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
    Usb               : 1,
    AxiRt             : 0,
    Clic              : 0,
    IrqRouter         : 0,
    BusErr            : 1,
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
    LlcMaxReadTxns    : 16,
    LlcMaxWriteTxns   : 16,
    LlcAmoNumCuts     : 1,
    LlcAmoPostCut     : 1,
    LlcOutConnect     : 1,
    LlcOutRegionStart : 'h8000_0000,
    LlcOutRegionEnd   : 64'h1_0000_0000,
    // VGA: RGB565
    VgaRedWidth       : 5,
    VgaGreenWidth     : 6,
    VgaBlueWidth      : 5,
    VgaHCountWidth    : 24, // TODO: Default is 32; is this needed?
    VgaVCountWidth    : 24, // TODO: See above
    VgaBufferDepth    : 16,
    VgaMaxReadTxns    : 24,
    // Serial Link: map other chip's lower 32bit to 'h1_000_0000
    SlinkMaxTxnsPerId : 4,
    SlinkMaxUniqIds   : 4,
    SlinkMaxClkDiv    : 1024,
    SlinkRegionStart  : 64'h1_0000_0000,
    SlinkRegionEnd    : 64'h2_0000_0000,
    SlinkTxAddrMask   : 'hFFFF_FFFF,
    SlinkTxAddrDomain : 'h0000_0000,
    SlinkUserAmoBit   : 1,  // Convention: lower AMO bits for cores, MSB for serial link
    // USB config
    UsbDmaMaxReads    : 16,
    UsbAddrMask       : 'hFFFF_FFFF,
    UsbAddrDomain     : 'h0000_0000,
    // DMA config
    DmaConfMaxReadTxns  : 4,
    DmaConfMaxWriteTxns : 4,
    DmaConfAmoNumCuts   : 1,
    DmaConfAmoPostCut   : 1,
    DmaConfEnableTwoD   : 1,
    DmaNumAxInFlight    : 16,
    DmaMemSysDepth      : 8,
    DmaJobFifoDepth     : 2,
    DmaRAWCouplingAvail : 1,
    // GPIOs
    GpioInputSyncs    : 1,
    // AXI RT
    AxiRtNumPending     : 16,
    AxiRtWBufferDepth   : 16,
    AxiRtNumAddrRegions : 2,
    AxiRtCutPaths       : 1,
    // All non-set values should be zero
    default: '0
  };

endpackage
