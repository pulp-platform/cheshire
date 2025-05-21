// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Hannah Pochert  <hpochert@ethz.ch>
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

package obi_uart_pkg;

  //-- Configurable values -----------------------------------------------------------------------
  localparam int RegAlignBytes = 4; // regs aligned to this many bytes (4 -> 32-bit aligned)

  // Number of input synchronization stages
  localparam int NrSyncStages = 2;

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // RX and TX Statemachine typedefs //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  // RX FSM states
  typedef enum bit [2:0] {
    RXIDLE,
    RXSTART,
    RXDATA,
    RXPAR,
    RXSTOP,
    RXRESYNCHRONIZE
  } state_type_rx_e;

  // TX FSM states
  typedef enum bit [2:0] {
    TXIDLE,
    TXSTART,
    TXDATA,
    TXPAR,
    TXSTOP1,
    TXSTOP2,
    TXWAIT
  } state_type_tx_e;

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Address Offsets //
  ////////////////////////////////////////////////////////////////////////////////////////////////
  localparam int RegWidth      = 8;
  // Address widths used for decoding
  localparam int AddressBits   = 3;
  localparam int AddressOffset = $clog2(RegAlignBytes);

  // Register Address Offsets
  localparam bit [AddressBits-1:0] RegAddrRHR = 3'b000;
  localparam bit [AddressBits-1:0] RegAddrTHR = 3'b000;
  localparam bit [AddressBits-1:0] RegAddrIER = 3'b001;
  localparam bit [AddressBits-1:0] RegAddrISR = 3'b010;
  localparam bit [AddressBits-1:0] RegAddrFCR = 3'b010;
  localparam bit [AddressBits-1:0] RegAddrLCR = 3'b011;
  localparam bit [AddressBits-1:0] RegAddrMCR = 3'b100;
  localparam bit [AddressBits-1:0] RegAddrLSR = 3'b101;
  localparam bit [AddressBits-1:0] RegAddrMSR = 3'b110;
  localparam bit [AddressBits-1:0] RegAddrSPR = 3'b111;
  localparam bit [AddressBits-1:0] RegAddrDLL = 3'b000;
  localparam bit [AddressBits-1:0] RegAddrDLM = 3'b001;
  //localparam bit [AddressBits-1:0] RegAddrPSD = 3'b101;


  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Single Register Unions for Register Interface//
  ////////////////////////////////////////////////////////////////////////////////////////////////

  //----------------------------------------------------------------------------------------------
  // Single Register Structs with Bit Definitions
  //----------------------------------------------------------------------------------------------

  typedef struct packed {
    logic [7:0] char_rx;     // Character received
  } RHR_bits_t;

  typedef struct packed {
    logic [7:0] char_tx;     // Character transmitted
  } THR_bits_t;

  typedef struct packed {
    logic unused7;           // Optional: DMA
    logic unused6;           // Optional: DMA
    logic unused5;           // 0
    logic unused4;           // 0
    logic mstat;             // Modem Status
    logic rlstat;            // Receive Line Status
    logic thr_empty;         // THR Empty
    logic dtr;               // Data Ready or Reception Timeout
  } IER_bits_t;

  typedef struct packed {
    logic [1:0] fifos_en;    // Standard: 2'b00: 8250; 2'b01: 16550; 2'b10: 16750; 2'b11: 16550A
    logic unused5;           // Optional: DMA
    logic unused4;           // Optional: DMA
    logic [2:0] id;          // Intrpt Code ID
    logic       status;      // Intrpt Status
  } ISR_bits_t;

  typedef struct packed {
    logic [1:0] rx_fifo_tl;  // Rx FIFO Trigger Level
    logic       unused5;     // 0
    logic       unused4;     // Optional: DMA
    logic       unused3;     // Optional: DMA
    logic       tx_fifo_rst; // Tx FIFO reset
    logic       rx_fifo_rst; // Rx FIFO reset
    logic       fifo_en;     // FIFO Enable
  } FCR_bits_t;

  typedef struct packed {
    logic       dlab;        // DLAB Address multiplexing
    logic       set_break;   // Set Break
    logic       force_par;   // Force Parity
    logic       even_par;    // Even Parity
    logic       par_en;      // Parity Enable
    logic       stop_bits;   // Stop Bits
    logic [1:0] word_len;    // Word Length 2'b00: 5 | 2'b01: 6 | 2'b10: 7 | 2'b11: 8
  } LCR_bits_t;

  typedef struct packed {
    logic       unused7;     // 0
    logic       unused6;     // 0
    logic       unused5;     // 0
    logic       loopback;    // Loop Back
    logic       out2;        // Optional: Gpio Output
    logic       out1;        // Optional: Gpio Output
    logic       rts;         // Request to Send
    logic       dtr;         // DaTa Ready
  } MCR_bits_t;

  typedef struct packed {
    logic fifo_err;          // FIFO Data Error
    logic tx_empty;          // Transmitter Empty (no bits to send)
    logic thr_empty;         // THR (and FIFO) Empty
    logic break_intrpt;      // Break Interrupt
    logic frame_err;         // Framing Error
    logic par_err;           // Parity Error
    logic overrun_err;       // Overrun Error
    logic data_ready;        // Data Ready
  } LSR_bits_t;

  typedef struct packed {
    logic cd;                // Carrier Detect
    logic ri;                // Ring Indicator
    logic dsr;               // Data Set Ready
    logic cts;               // Clear to Send
    logic d_cd;              // Delta CD: Indicates change
    logic te_ri;             // Trailing Edge RI: Detects trailing Edge (Transition high to low)
    logic d_dsr;             // Delta
    logic d_cts;             // Delta Clear to Send
  } MSR_bits_t;

  typedef struct packed {
    logic [7:0] lsb;         // Baudrate's Divisor Constant LSByte
  } DLL_bits_t;

  typedef struct packed {
    logic [7:0] msb;         // Baudrate's Divisor Constant MSByte
  } DLM_bits_t;


  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Registers //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  typedef struct packed {
    RHR_bits_t RHR;    // Read Hold Register
    THR_bits_t THR;    // Transmit Hold Register
    IER_bits_t IER;    // Interrupt Enable Register
    //ISR_bits_t ISR;  // Interrupt Status Register, stored seperately in interrupts module
    FCR_bits_t FCR;    // Fifo Control Register
    LCR_bits_t LCR;    // Line Control Register
    MCR_bits_t MCR;    // Modem Control Register
    LSR_bits_t LSR;    // Line Status Register
    MSR_bits_t MSR;    // Modem Status Register
    //logic [7:0] SPR; // Scratch Pad Register, Not Implemented
    DLL_bits_t DLL;    // Divisor Latch Least signf. byte
    DLM_bits_t DLM;    // Divisor Latch Most sign. byte
    //logic [7:0] PSD; // Pre Scaler Division, Optional
  } uart_reg_fields_t;


  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Default/Reset Register Values //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  // Default values for the Registers from UART 16550A Standard
  localparam uart_reg_fields_t RegResetVal = '{
    RHR: 8'h00,
    THR: 8'h00,
    IER: 8'h00,
    // ISR: 8'hC1, // -> 11000001; bit 6 and 7 high -> 16550A (implemented in interrupt module)
    FCR: 8'h00,
    LCR: 8'h00,
    MCR: 8'h00,
    LSR: 8'h60,
    MSR: 8'h00,
    // SPR: 8'h00, // scratch reg not implemented, always return zero
    DLL: 8'h01,
    DLM: 8'h00
    // PSD: PSD_DEFAULT //  PSD not implemented
  };


  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Interface between UART INTERNAL LOGIC and Register //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  typedef struct packed {
    // current register values
    THR_bits_t thr;
    IER_bits_t ier;
    ISR_bits_t isr;
    FCR_bits_t fcr;
    LCR_bits_t lcr;
    MCR_bits_t mcr;
    DLL_bits_t dll;
    DLM_bits_t dlm;
    // read/write indicators
    logic      obi_read_rhr;
    logic      obi_read_isr;
    logic      obi_read_lsr;
    logic      obi_read_msr;
    logic      obi_write_thr;
    logic      obi_write_dllm;
  } reg_read_t;

  // new values from rx module
  typedef struct packed {
    RHR_bits_t  rhr;
    logic       fifo_rst;
    logic       fifo_err;
    logic       data_ready;
    logic       overrun_err;
    logic       par_err;
    logic       frame_err;
    logic       break_intrpt;

    logic       rhr_valid;
    logic       fifo_rst_valid;
    logic       fifo_err_valid;
    logic       dr_valid;
    logic       overrun_valid;
    logic       par_valid;
    logic       frame_valid;
    logic       break_valid;
  } rx_reg_write_t;

  // new values from tx module
  typedef struct packed {
    logic       fifo_rst;
    logic       tx_empty;
    logic       thr_empty;

    logic       fifo_rst_valid;
    logic       empty_valid;
    logic       thr_valid;
  } tx_reg_write_t;

  typedef struct packed {
    rx_reg_write_t rx;
    tx_reg_write_t tx;
    ISR_bits_t     isr;
    MSR_bits_t     modem;
  } reg_write_t;


endpackage
