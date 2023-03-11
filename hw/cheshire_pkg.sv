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
  localparam int unsigned NumExtIntrs     = plic_reg_pkg::NumSrc - NumIntIntrs;
  localparam int unsigned SpihNumCs       = spi_host_reg_pkg::NumCs - 1;  // Last CS is dummy
  localparam int unsigned SlinkNumChan    = serial_link_single_channel_reg_pkg::NumChannels;
  localparam int unsigned SlinkNumBits    = serial_link_single_channel_reg_pkg::NumBits;
  localparam int unsigned SlinkMaxClkDiv  = 1 << serial_link_single_channel_reg_pkg::Log2MaxClkDiv;
  localparam int unsigned ClintNumCores   = serial_link_single_channel_reg_pkg::NumCores;

  // Externally controllable parameters
  typedef struct packed {
    // Hart parameters
    bit             DualCore;
    bit [63:0]      NumExtIrqHarts;
    bit [63:0]      NumExtDbgHarts;
    bit [ 9:0]      Core1UserAmoBit;
    bit [ 5:0]      CoreMaxTxnsPerId;
    bit [ 5:0]      CoreMaxUniqIds;
    // Interconnect parameters
    bit [ 5:0]      AddrWidth;
    bit [ 9:0]      AxiDataWidth;
    bit [ 9:0]      AxiUserWidth;
    bit [ 5:0]      AxiMstIdWidth;
    // User signals identify atomics masters.
    // A '0 user signal indicates no atomics.
    bit [ 9:0]      AxiUserAmoMsb;
    bit [ 9:0]      AxiUserAmoLsb;
    bit [63:0]      AxiUserAmoDomain;
    // External AXI ports (at most 8)
    bit [2:0]       AxiExtNumMst;
    bit [2:0]       AxiExtNumSlv;
    bit [7:0][ 7:0] AxiExtRegionIdx;
    bit [7:0][63:0] AxiExtRegionStart;
    bit [7:0][63:0] AxiExtRegionEnd;
    // External reg slaves (at most 8)
    bit [2:0]       RegExtNumSlv;
    bit [7:0][ 7:0] RegExtRegionIdx;
    bit [7:0][63:0] RegExtRegionStart;
    bit [7:0][63:0] RegExtRegionEnd;
    // Real-time clock speed
    bit [31:0]      RtcFreq;
    // Address of platfrom ROM
    bit [31:0]      PlatformRom;
    // Enabled hardware features
    bit             Bootrom;
    bit             Uart;
    bit             I2c;
    bit             SpiHost;
    bit             Gpio;
    bit             Dma;
    bit             SerialLink;
    bit             Vga;
    // Parameters for Debug Module
    bit [31:0]      DbgIdcode;
    bit [ 9:0]      DbgMaxReqs;
    bit [ 9:0]      DbgMaxReadTxns;
    bit [ 9:0]      DbgMaxWriteTxns;
    bit [ 9:0]      DbgAmoNumCuts;
    bit [ 9:0]      DbgAmoPostCut;
    // Parameters for LLC
    bit             LlcNotSpm;
    bit [15:0]      LlcSetAssoc;
    bit [15:0]      LlcNumLines;
    bit [15:0]      LlcNumBlocks;
    // Parameters for VGA
    bit [ 7:0]      VgaRedWidth;
    bit [ 7:0]      VgaGreenWidth;
    bit [ 7:0]      VgaBlueWidth;
    bit [ 5:0]      VgaHCountWidth;
    bit [ 5:0]      VgaVCountWidth;
    // Parameters for Serial Link
    bit [ 5:0]      SlinkMaxTxnsPerId;
    bit [ 5:0]      SlinkMaxUniqIds;
    bit [ 5:0]      SlinkMaxClkDiv;
    bit [63:0]      SlinkRegionStart;
    bit [63:0]      SlinkRegionEnd;
    bit [63:0]      SlinkTxAddrMask;
    bit [63:0]      SlinkTxAddrDomain;
    bit [ 9:0]      SlinkUserAmoBit;
    // Parameters for DMA
    bit [ 9:0]      DmaConfMaxReadTxns;
    bit [ 9:0]      DmaConfMaxWriteTxns;
    bit [ 9:0]      DmaConfAmoNumCuts;
    bit             DmaConfAmoPostCut;
    // Parameters for GPIO
    bit             GpioInputSyncs;
  } cheshire_cfg_t;

    // Internally defined interrupts.
  // User interrupts are added on top of these.
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

endpackage
