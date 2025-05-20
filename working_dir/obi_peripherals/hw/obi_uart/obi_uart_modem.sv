// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Hannah Pochert  <hpochert@ethz.ch>
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

`include "common_cells/registers.svh"

/// Synchronizes incoming modem signals, outputs modem signals and handles loopback 
module obi_uart_modem import obi_uart_pkg::*; #()
(
  input  logic clk_i,
  input  logic rst_ni,

  input  logic cts_ni,  // Modem Inp Clear To Send
  input  logic dsr_ni,  // Modem Inp Data Send Request
  input  logic ri_ni,   // Modem Inp Ring Indicator
  input  logic cd_ni,   // Modem Inp Carrier Detect
  output logic rts_no,  // Modem Oup Ready To Send
  output logic dtr_no,  // Modem Oup DaTa Ready
  output logic out1_no, // Modem Output 1
  output logic out2_no, // Modem Output 2

  input  reg_read_t reg_read_i,
  output MSR_bits_t reg_write_o
);
  // Flow control is left to SW. UART Modem Control only writes modem inputs to 
  // register and sets modem outputs from the register.

  // Modem inputs and outputs are active low. Values seen in the signals are the opposite of 
  // the ones read from or written to the modem status/control registers !

  //--Modem-Control-Signals-----------------------------------------------------------------------
  logic sync_cts_n, sync_cts_n_d, sync_cts_n_q;
  logic sync_dsr_n, sync_dsr_n_d, sync_dsr_n_q;
  logic sync_ri_n, sync_ri_n_d,  sync_ri_n_q;
  logic sync_cd_n, sync_cd_n_d,  sync_cd_n_q;

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Modem Input Synchronisation //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  sync #( 
    .STAGES (NrSyncStages) 
  ) i_sync_cts (
    .clk_i, 
    .rst_ni, 
    .serial_i(cts_ni), 
    .serial_o(sync_cts_n)
  
  );
  sync #( 
    .STAGES (NrSyncStages) 
  ) i_sync_dsr (
    .clk_i, 
    .rst_ni, 
    .serial_i(dsr_ni), 
    .serial_o(sync_dsr_n)
  );

  sync #( 
    .STAGES (NrSyncStages) 
  ) i_sync_ri (
    .clk_i, 
    .rst_ni, 
    .serial_i(ri_ni),  
    .serial_o(sync_ri_n)
  );

  sync #( 
    .STAGES (NrSyncStages) 
  ) i_sync_cd (
    .clk_i, 
    .rst_ni, 
    .serial_i(cd_ni),  
    .serial_o(sync_cd_n)
  );


  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Modem Input/Output and Loopback //
  ////////////////////////////////////////////////////////////////////////////////////////////////
  
  always_comb begin
    if(reg_read_i.mcr.loopback == 1'b1) begin
      rts_no  = 1'b1;
      dtr_no  = 1'b1;
      out1_no = 1'b1;
      out2_no = 1'b1;

      sync_cts_n_d = ~reg_read_i.mcr.rts;
      sync_dsr_n_d = ~reg_read_i.mcr.dtr;
      sync_ri_n_d  = ~reg_read_i.mcr.out1;
      sync_cd_n_d  = ~reg_read_i.mcr.out2;
    end else begin
      rts_no  = ~reg_read_i.mcr.rts;
      dtr_no  = ~reg_read_i.mcr.dtr;
      out1_no = ~reg_read_i.mcr.out1;
      out2_no = ~reg_read_i.mcr.out2;

      sync_cts_n_d = sync_cts_n;
      sync_dsr_n_d = sync_dsr_n;
      sync_ri_n_d  = sync_ri_n;
      sync_cd_n_d  = sync_cd_n;
    end
  end

  `FF(sync_cts_n_q, sync_cts_n_d, '1, clk_i, rst_ni) 
  `FF(sync_dsr_n_q, sync_dsr_n_d, '1, clk_i, rst_ni) 
  `FF(sync_ri_n_q, sync_ri_n_d, '1, clk_i, rst_ni) 
  `FF(sync_cd_n_q, sync_cd_n_d, '1, clk_i, rst_ni) 


  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Modem to MSR //
  ////////////////////////////////////////////////////////////////////////////////////////////////
  
  // Modem Inputs are negated
  assign reg_write_o.cts  = ~sync_cts_n_d;
  assign reg_write_o.dsr  = ~sync_dsr_n_d;
  assign reg_write_o.ri   = ~sync_ri_n_d;
  assign reg_write_o.cd   = ~sync_cd_n_d;

    // Change status bits
  assign reg_write_o.d_cts = sync_cts_n_d ^ sync_cts_n_q; // Delta: 1 if _d different from _q
  assign reg_write_o.d_dsr = sync_dsr_n_d ^ sync_dsr_n_q; // Delta: 1 if _d different from _q
  assign reg_write_o.te_ri = sync_ri_n_d & ~sync_ri_n_q;  // Trailing Edge: 1 on change from 0 to 1
  assign reg_write_o.d_cd  = sync_cd_n_d ^ sync_cd_n_q;   // Delta: 1 if _d different from _q

endmodule
