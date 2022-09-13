// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>


package cheshire_pkg;

  `include "axi/typedef.svh"
  `include "axi/assign.svh"
  `include "register_interface/typedef.svh"
  `include "apb/typedef.svh"

  // Inputs of X-Bar
  typedef enum int {
    AXI_XBAR_IN_CVA6,
    AXI_XBAR_IN_DEBUG,
    AXI_XBAR_IN_DDR_LINK,
    AXI_XBAR_IN_VGA,
    AXI_XBAR_IN_DMA,
    AXI_XBAR_NUM_INPUTS
  } axi_xbar_inputs_e;

  // Outputs of X-Bar
  typedef enum int {
    AXI_XBAR_OUT_DEBUG,
    AXI_XBAR_OUT_REGBUS_PERIPH,
    AXI_XBAR_OUT_DMA_CONF,
    AXI_XBAR_OUT_SPM,
    AXI_XBAR_OUT_RPC_DRAM,
    AXI_XBAR_OUT_DDR_LINK,
    AXI_XBAR_NUM_OUTPUTS
  } axi_xbar_outputs_e;

  localparam int unsigned AXI_ADDR_WIDTH           = 48;
  localparam int unsigned AXI_DATA_WIDTH           = 64;
  localparam int unsigned AXI_USER_WIDTH           = 1;
  localparam int unsigned AXI_STRB_WIDTH           = $clog2(AXI_DATA_WIDTH);

  localparam int unsigned AXI_XBAR_MASTER_ID_WIDTH = 4; // TODO
  localparam int unsigned AXI_XBAR_SLAVE_ID_WIDTH  = AXI_XBAR_MASTER_ID_WIDTH + $clog2(AXI_XBAR_NUM_INPUTS); 

  localparam int unsigned AXI_XBAR_COMBS           = AXI_XBAR_NUM_INPUTS * AXI_XBAR_NUM_OUTPUTS;
  localparam logic [AXI_XBAR_COMBS-1:0] AXI_XBAR_CONNECTIVITY = {AXI_XBAR_COMBS{1'b1}};

  localparam axi_pkg::xbar_cfg_t axi_xbar_cfg = '{
    NoSlvPorts:         AXI_XBAR_NUM_INPUTS,
    NoMstPorts:         AXI_XBAR_NUM_OUTPUTS,
    MaxSlvTrans:        12,
    MaxMstTrans:        12,
    FallThrough:        0,
    LatencyMode:        axi_pkg::CUT_ALL_PORTS,
    AxiIdWidthSlvPorts: AXI_XBAR_MASTER_ID_WIDTH,
    AxiIdUsedSlvPorts:  AXI_XBAR_MASTER_ID_WIDTH,
    UniqueIds:          0,
    AxiAddrWidth:       48,
    AxiDataWidth:       64,
    NoAddrRules:        6
  };

  typedef struct packed {
    logic [31:0] idx;
    logic [47:0] start_addr;
    logic [47:0] end_addr;
  } address_rule_48_t;

  // Address map of the AXI X-Bar
  localparam address_rule_48_t [AXI_XBAR_NUM_OUTPUTS-1:0] axi_xbar_addrmap = '{
    '{ idx: AXI_XBAR_OUT_DEBUG,         start_addr: 48'h000000000000, end_addr: 48'h000000001000},
    '{ idx: AXI_XBAR_OUT_REGBUS_PERIPH, start_addr: 48'h000001000000, end_addr: 48'h000030000000},
    '{ idx: AXI_XBAR_OUT_DMA_CONF,      start_addr: 48'h000040000000, end_addr: 48'h000040001000},
    '{ idx: AXI_XBAR_OUT_SPM,           start_addr: 48'h000070000000, end_addr: 48'h000070020000},
    '{ idx: AXI_XBAR_OUT_RPC_DRAM,      start_addr: 48'h000080000000, end_addr: 48'h000100000000},
    '{ idx: AXI_XBAR_OUT_DDR_LINK,      start_addr: 48'h100000000000, end_addr: 48'h200000000000}
  };

  // Inputs of the Regbus Demux
  typedef enum int {
    REGBUS_PERIPH_IN_XBAR,
    REGBUS_PERIPH_NUM_INPUTS
  } regbus_periph_inputs_e;

  // Outputs of the Regbus Demux
  typedef enum int {
    REGBUS_PERIPH_OUT_BOOTROM,
    REGBUS_PERIPH_OUT_UART,
    REGBUS_PERIPH_OUT_I2C,
    REGBUS_PERIPH_OUT_FLL,
    REGBUS_PERIPH_OUT_PAD_CTRL,
    REGBUS_PERIPH_OUT_CSR,
    REGBUS_PERIPH_OUT_SPIM,
    REGBUS_PERIPH_OUT_CLINT,
    REGBUS_PERIPH_OUT_PLIC,
    REGBUS_PERIPH_OUT_DDR_LINK,
    REGBUS_PERIPH_OUT_RPC_DRAM,
    REGBUS_PERIPH_OUT_VGA,
    REGBUS_PERIPH_NUM_OUTPUTS
  } regbus_periph_outputs_e;

  // Address map of the Regbus Demux
  localparam address_rule_48_t [REGBUS_PERIPH_NUM_OUTPUTS-1:0] regbus_periph_addrmap = '{
    '{ idx: REGBUS_PERIPH_OUT_BOOTROM,  start_addr: 48'h01000000, end_addr: 48'h01020000 },
    '{ idx: REGBUS_PERIPH_OUT_UART,     start_addr: 48'h02000000, end_addr: 48'h02001000 },  // UART
    '{ idx: REGBUS_PERIPH_OUT_I2C,      start_addr: 48'h02001000, end_addr: 48'h02002000 },  // I2C
    '{ idx: REGBUS_PERIPH_OUT_FLL,      start_addr: 48'h02002000, end_addr: 48'h02003000 },  // FLL
    '{ idx: REGBUS_PERIPH_OUT_PAD_CTRL, start_addr: 48'h02003000, end_addr: 48'h02004000 },  // PAD CTRL
    '{ idx: REGBUS_PERIPH_OUT_CSR,      start_addr: 48'h02004000, end_addr: 48'h02005000 },  // CSR
    '{ idx: REGBUS_PERIPH_OUT_SPIM,     start_addr: 48'h03000000, end_addr: 48'h03020000 },  // SPIM
    '{ idx: REGBUS_PERIPH_OUT_CLINT,    start_addr: 48'h04000000, end_addr: 48'h04100000 },  // CLINT
    '{ idx: REGBUS_PERIPH_OUT_PLIC,     start_addr: 48'h0c000000, end_addr: 48'h10000000 },  // PLIC
    '{ idx: REGBUS_PERIPH_OUT_DDR_LINK, start_addr: 48'h20000000, end_addr: 48'h20001000 },  // DDR Link
    '{ idx: REGBUS_PERIPH_OUT_RPC_DRAM, start_addr: 48'h20001000, end_addr: 48'h20002000 }, // RPC DRAM
    '{ idx: REGBUS_PERIPH_OUT_VGA,      start_addr: 48'h20002000, end_addr: 48'h20003000 }  // VGA
  };


  // Type definitions

  // Register bus with 48 bit address and 32 bit data
  `REG_BUS_TYPEDEF_ALL(reg_a48_d32, logic [47:0], logic [31:0], logic [3:0])

  // Register bus with 48 bit address and 64 bit data
  `REG_BUS_TYPEDEF_ALL(reg_a48_d64, logic [47:0], logic [63:0], logic [7:0])

  // AXI bus with 48 bit address and 64 bit data
  `AXI_TYPEDEF_ALL(axi_a48_d64_mst_u0, logic [47:0], logic [AXI_XBAR_MASTER_ID_WIDTH-1:0], logic [63:0], logic [7:0], logic [0:0])
  `AXI_TYPEDEF_ALL(axi_a48_d64_slv_u0, logic [47:0], logic [AXI_XBAR_SLAVE_ID_WIDTH-1:0], logic [63:0], logic [7:0], logic [0:0])
  
  // AXI bus with 48 bit address and 32 bit data
  `AXI_TYPEDEF_ALL(axi_a48_d32_slv_u0, logic [47:0], logic [AXI_XBAR_SLAVE_ID_WIDTH-1:0], logic [31:0], logic [3:0], logic [0:0])

  // AXI Lite bus with 48 bit address and 64 bit data
  `AXI_LITE_TYPEDEF_ALL(axi_lite_a48_d64, logic [47:0], logic [63:0], logic [7:0])

  // APB bus with 48 bit address and 32 bit data
  `APB_TYPEDEF_REQ_T(apb_a48_d32_req_t, logic [47:0], logic [31:0], logic [3:0])
  `APB_TYPEDEF_RESP_T(apb_a48_d32_rsp_t, logic [31:0])

  localparam ariane_pkg::ariane_cfg_t CheshireArianeConfig = '{
    RASDepth: 2,
    BTBEntries: 32,
    BHTEntries: 128,
    // Default config
    NrNonIdempotentRules: 2,
    NonIdempotentAddrBase: { 
        64'h0, 64'h0100_0000
    },
    NonIdempotentLength: {
        64'h0100_0000, 64'h2000_0000 // TODO Maybe a bit too large but looks nice and doesn't hurt
    },
    NrExecuteRegionRules: 4,
    // DRAM, SPM, Boot ROM, Debug Module
    ExecuteRegionAddrBase: {
        64'h8000_0000, 64'h7000_0000, 64'h0100_0000, 64'h0
    },
    ExecuteRegionLength: {
        64'h8000_0000, 64'h0002_0000, 64'h0002_0000, 64'h1000
    },
    // Cached region
    NrCachedRegionRules: 2,
    CachedRegionAddrBase: {
        64'h8000_0000, 64'h7001_0000
    },
    CachedRegionLength: {
        64'h8000_0000, 64'h0001_0000
    },
    // Cache config
    Axi64BitCompliant: 1'b1,
    SwapEndianess: 1'b0,
    // Debug
    DmBaseAddress: 64'h0,
    NrPMPEntries: 0
  };

  // Interrupts
  typedef struct packed {
    logic uart;
    logic spim_error;
    logic spim_spi_event;
    logic i2c_fmt_watermark;
    logic i2c_rx_watermark;
    logic i2c_fmt_overflow;
    logic i2c_rx_overflow;
    logic i2c_nak;
    logic i2c_scl_interference;
    logic i2c_sda_interference;
    logic i2c_stretch_timeout;
    logic i2c_sda_unstable;
    logic i2c_trans_complete;
    logic i2c_tx_empty;
    logic i2c_tx_nonempty;
    logic i2c_tx_overflow;
    logic i2c_acq_overflow;
    logic i2c_ack_stop;
    logic i2c_host_timeout;
    logic zero;
  } cheshire_interrupt_t;

  // SRAM cfg struct
  typedef struct packed {
    logic [2:0] ema;
    logic [1:0] emaw;
    logic [0:0] emas;
  } sram_cfg_t;

  // Debug Module
  localparam logic [15:0] PartNum = 1012;
  localparam logic [31:0] IDCode = (dm::DbgVersion013 << 28) | (PartNum << 12) | 32'h1;

  localparam SPM_BASE = axi_xbar_addrmap[AXI_XBAR_OUT_SPM].start_addr;
  localparam SCRATCH_REGS_BASE = regbus_periph_addrmap[REGBUS_PERIPH_OUT_CSR].start_addr;

endpackage