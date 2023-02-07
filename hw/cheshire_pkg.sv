// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

/// Contains the structs and configurations necessary for the Cheshire Platform
package cheshire_pkg;

  `include "axi/typedef.svh"
  `include "axi/assign.svh"
  `include "register_interface/typedef.svh"
  `include "apb/typedef.svh"

  /// Inputs of X-Bar
  typedef enum int {
    AxiXbarInCva6,
    AxiXbarInDebug,
    AxiXbarInSerialLink,
    AxiXbarInVga,
    AxiXbarInDma,
    AxiXbarNumInputs
  } axi_xbar_inputs_e;

  /// Outputs of X-Bar
  typedef enum int {
    AxiXbarOutDebug,
    AxiXbarOutRegbus,
    AxiXbarOutDmaConf,
    AxiXbarOutLlc,
    AxiXbarOutSerialLink,
    AxiXbarNumOutputs
  } axi_xbar_outputs_e;

  /// Parameters for AXI types
  localparam int unsigned AxiAddrWidth = 48;
  localparam int unsigned AxiDataWidth = 64;
  localparam int unsigned AxiUserWidth = 1;
  localparam int unsigned AxiStrbWidth = AxiDataWidth/8;  // Using byte strobes

  localparam int unsigned AxiXbarMasterIdWidth = 2;
  localparam int unsigned AxiXbarSlaveIdWidth  = AxiXbarMasterIdWidth + $clog2(AxiXbarNumInputs);

  localparam int unsigned AxiXbarCombs = AxiXbarNumInputs * AxiXbarNumOutputs;
  localparam logic [AxiXbarCombs-1:0] AxiXbarConnectivity = {AxiXbarCombs{1'b1}};

  /// Configuration struct of X-Bar
  localparam axi_pkg::xbar_cfg_t AxiXbarCfg = '{
    NoSlvPorts:         AxiXbarNumInputs,
    NoMstPorts:         AxiXbarNumOutputs,
    MaxMstTrans:        12,
    MaxSlvTrans:        12,
    FallThrough:        0,
    LatencyMode:        axi_pkg::CUT_ALL_PORTS,
    PipelineStages:     1,
    AxiIdWidthSlvPorts: AxiXbarMasterIdWidth,
    AxiIdUsedSlvPorts:  AxiXbarMasterIdWidth,
    UniqueIds:          0,
    AxiAddrWidth:       48,
    AxiDataWidth:       64,
    NoAddrRules:        6
  };

  /// Address rule struct
  typedef struct packed {
    logic [31:0] idx;
    logic [47:0] start_addr;
    logic [47:0] end_addr;
  } address_rule_48_t;

  /// Address map of the AXI X-Bar
  /// NUM_OUTPUT rules + 1 additional for LLC (SPM and DRAM)
  localparam address_rule_48_t [AxiXbarNumOutputs:0] AxiXbarAddrmap = '{
    '{ idx: AxiXbarOutSerialLink,  start_addr: 48'h100000000000, end_addr: 48'h200000000000},
    '{ idx: AxiXbarOutLlc,         start_addr: 48'h000080000000, end_addr: 48'h000100000000},
    '{ idx: AxiXbarOutLlc,         start_addr: 48'h000070000000, end_addr: 48'h000070006000},
    '{ idx: AxiXbarOutDmaConf,     start_addr: 48'h000060000000, end_addr: 48'h000060001000},
    '{ idx: AxiXbarOutRegbus,      start_addr: 48'h000001000000, end_addr: 48'h000060000000},
    '{ idx: AxiXbarOutDebug,       start_addr: 48'h000000000000, end_addr: 48'h000000001000}
  };

  /// Inputs of the Regbus Demux
  typedef enum int {
    RegbusInXbar,
    RegbusNumInputs
  } regbus_inputs_e;

  /// Outputs of the Regbus Demux
  typedef enum int {
    RegbusOutBootrom,
    RegbusOutCsr,
    RegbusOutLlc,
    RegbusOutSerialLink,
    RegbusOutUart,
    RegbusOutI2c,
    RegbusOutSpim,
    RegbusOutVga,
    RegbusOutClint,
    RegbusOutPlic,
    RegbusOutExternal,
    RegbusNumOutputs
  } regbus_outputs_e;

  /// Address map of the Regbus Demux
  localparam address_rule_48_t [RegbusNumOutputs-1:0] RegbusAddrmap = '{
    '{ idx: RegbusOutExternal,    start_addr: 48'h10000000, end_addr: 48'h60000000 },  // EXTERNAL    - 1.25 GiB
    '{ idx: RegbusOutPlic,        start_addr: 48'h0c000000, end_addr: 48'h10000000 },  // PLIC        -   64 MiB
    '{ idx: RegbusOutClint,       start_addr: 48'h04000000, end_addr: 48'h04100000 },  // CLINT       -    1 MiB
    '{ idx: RegbusOutVga,         start_addr: 48'h02006000, end_addr: 48'h02007000 },  // VGA         -    4 KiB
    '{ idx: RegbusOutSpim,        start_addr: 48'h02005000, end_addr: 48'h02006000 },  // SPIM        -    4 KiB
    '{ idx: RegbusOutI2c,         start_addr: 48'h02004000, end_addr: 48'h02005000 },  // I2C         -    4 KiB
    '{ idx: RegbusOutUart,        start_addr: 48'h02003000, end_addr: 48'h02004000 },  // UART        -    4 KiB
    '{ idx: RegbusOutSerialLink,  start_addr: 48'h02002000, end_addr: 48'h02003000 },  // Serial Link -    4 KiB
    '{ idx: RegbusOutLlc,         start_addr: 48'h02001000, end_addr: 48'h02002000 },  // LLC         -    4 KiB
    '{ idx: RegbusOutCsr,         start_addr: 48'h02000000, end_addr: 48'h02001000 },  // CSR         -    4 KiB
    '{ idx: RegbusOutBootrom,     start_addr: 48'h01000000, end_addr: 48'h01020000 }   // Bootrom     -  128 KiB
  };

  /// Type definitions
  ///
  /// Register bus with 48 bit address and 32 bit data
  `REG_BUS_TYPEDEF_ALL(reg_a48_d32, logic [47:0], logic [31:0], logic [3:0])

  /// Register bus with 48 bit address and 64 bit data
  `REG_BUS_TYPEDEF_ALL(reg_a48_d64, logic [47:0], logic [63:0], logic [7:0])

  /// AXI bus with 48 bit address and 64 bit data
  `AXI_TYPEDEF_ALL(axi_a48_d64_mst_u0, logic [47:0], logic [AxiXbarMasterIdWidth-1:0], logic [63:0], logic [7:0], logic [0:0])
  `AXI_TYPEDEF_ALL(axi_a48_d64_slv_u0, logic [47:0], logic [AxiXbarSlaveIdWidth-1:0], logic [63:0], logic [7:0], logic [0:0])

  /// Same AXI bus with 48 bit address and 64 bit data but with CVA6s 4 bit ID
  `AXI_TYPEDEF_ALL(axi_cva6, logic [47:0], logic [3:0], logic [63:0], logic [7:0], logic [0:0])

  /// AXI bus for LLC (one additional ID bit)
  `AXI_TYPEDEF_ALL(axi_a48_d64_mst_u0_llc, logic [47:0], logic [AxiXbarSlaveIdWidth:0], logic [63:0], logic [7:0], logic [0:0])

  /// AXI bus with 48 bit address and 32 bit data
  `AXI_TYPEDEF_ALL(axi_a48_d32_slv_u0, logic [47:0], logic [AxiXbarSlaveIdWidth-1:0], logic [31:0], logic [3:0], logic [0:0])

  /// Identifier used for user-signal based ATOPs by CVA6
  localparam logic [0:0] Cva6Identifier = 1'b1;

  /// CVA6 Configuration struct
  localparam ariane_pkg::ariane_cfg_t CheshireArianeConfig = '{
    /// Default config
    RASDepth: 2,
    BTBEntries: 32,
    BHTEntries: 128,
    /// Non idempotent regions
    NrNonIdempotentRules: 1,
    NonIdempotentAddrBase: {
        64'h0100_0000
    },
    // Everything up until the SPM is assumed non idempotent
    NonIdempotentLength: {
        64'h6F00_0000
    },
    /// DRAM, SPM, Boot ROM, Debug Module
    NrExecuteRegionRules: 4,
    ExecuteRegionAddrBase: {
        64'h8000_0000, 64'h7000_0000, 64'h0100_0000, 64'h0
    },
    ExecuteRegionLength: {
        64'h8000_0000, 64'h0000_6000, 64'h0002_0000, 64'h1000
    },
    /// Cached regions: DRAM
    NrCachedRegionRules: 1,
    CachedRegionAddrBase: {
        64'h8000_0000
    },
    CachedRegionLength: {
        64'h8000_0000
    },
    Axi64BitCompliant: 1'b1,
    SwapEndianess: 1'b0,
    /// Debug
    DmBaseAddress: 64'h0,
    NrPMPEntries: 0
  };

  /// Interrupts
  typedef struct packed {
    logic uart;
    logic spim_spi_event;
    logic spim_error;
    logic i2c_host_timeout;
    logic i2c_ack_stop;
    logic i2c_acq_overflow;
    logic i2c_tx_overflow;
    logic i2c_tx_nonempty;
    logic i2c_tx_empty;
    logic i2c_trans_complete;
    logic i2c_sda_unstable;
    logic i2c_stretch_timeout;
    logic i2c_sda_interference;
    logic i2c_scl_interference;
    logic i2c_nak;
    logic i2c_rx_overflow;
    logic i2c_fmt_overflow;
    logic i2c_rx_watermark;
    logic i2c_fmt_watermark;
    logic zero;
  } cheshire_interrupt_t;

  /// Debug Module parameter
  localparam logic [15:0] PartNum = 1012;
  localparam logic [31:0] IDCode = (dm::DbgVersion013 << 28) | (PartNum << 12) | 32'h1;

  /// Testbench start adresses
  localparam logic [47:0] SpmBase = AxiXbarAddrmap[AxiXbarOutLlc].start_addr;
  localparam logic [47:0] ScratchRegsBase = RegbusAddrmap[RegbusOutCsr].start_addr;

  /// Cheshire Config
  /// Can be used to exclude parts of the system
  typedef struct packed {
    bit Uart;
    bit Spim;
    bit I2c;
    bit Dma;
    bit SerialLink;
    bit Dram;
    bit Vga;
    /// Width of the VGA red channel, ignored if VGA set to 0
    logic [31:0] VgaRedWidth;
    /// Width of the VGA green channel, ignored if VGA set to 0
    logic [31:0] VgaGreenWidth;
    /// Width of the VGA blue channel, ignored if VGA set to 0
    logic [31:0] VgaBlueWidth;
    /// The Clock frequency after coming out of reset
    logic [31:0] ResetFreq;
  } cheshire_cfg_t;

  /// Default FPGA config for Cheshire Platform
  localparam cheshire_cfg_t CheshireCfgFPGADefault = '{
    Uart:           1'b1,
    Spim:           1'b1,
    I2c:            1'b1,
    Dma:            1'b1,
    SerialLink:     1'b0,
    Dram:           1'b1,
    Vga:            1'b1,
    VgaRedWidth:    32'd5,
    VgaGreenWidth:  32'd6,
    VgaBlueWidth:   32'd5,
    ResetFreq:      32'd50000000
  };

  /// Default ASIC config for Cheshire Platform
  localparam cheshire_cfg_t CheshireCfgASICDefault = '{
    Uart:           1'b1,
    Spim:           1'b1,
    I2c:            1'b1,
    Dma:            1'b1,
    SerialLink:     1'b1,
    Dram:           1'b1,
    Vga:            1'b1,
    VgaRedWidth:    32'd2,
    VgaGreenWidth:  32'd3,
    VgaBlueWidth:   32'd3,
    ResetFreq:      32'd200000000
  };

endpackage
