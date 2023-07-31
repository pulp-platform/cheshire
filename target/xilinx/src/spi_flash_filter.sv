// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Yann Picod, ypicod@ethz.ch
// Description: Filter SPI transactions to prevent from unexpected writing in flash.


module spi_flash_filter #(
    parameter int unsigned        SpihNumCs = 1
) (
    input                         clk_i,
    input                         rst_ni,
    // Flash Side
    output logic                  spih_sck_o,
    output logic                  spih_sck_en_o,
    output logic [SpihNumCs-1:0]  spih_csb_o,
    output logic [SpihNumCs-1:0]  spih_csb_en_o,
    output logic [ 3:0]           spih_sd_o,
    output logic [ 3:0]           spih_sd_en_o,
    input  logic [ 3:0]           spih_sd_i,
    // CHS Side
    input  logic                  spi_chs_sck,
    input  logic                  spi_chs_sck_en,
    input  logic [SpihNumCs-1:0]  spi_chs_csb,
    input  logic [SpihNumCs-1:0]  spi_chs_csb_en,
    input  logic [ 3:0]           spi_chs_sdo,
    input  logic [ 3:0]           spi_chs_sdo_en,
    output logic [ 3:0]           spi_chs_sdi
);

// Software RESET Operation
localparam RESET_ENABLE = 8'h66;
localparam RESET_MEMORY = 8'h99;

// READ MEMORY Operations
localparam READ                           = 8'h03;
localparam FAST_READ                      = 8'h0B;
localparam DUAL_OUTPUT_FAST_READ          = 8'h3B;
localparam DUAL_INPUTOUTPUT_FAST_READ     = 8'hBB;
localparam QUAD_OUTPUT_FAST_READ          = 8'h6B;
localparam QUAD_INPUTOUTPUT_FAST_READ     = 8'hEB;
localparam DTR_FAST_READ                  = 8'h0D;
localparam DTR_DUAL_OUTPUT_FAST_READ      = 8'h3D;
localparam DTR_DUAL_INPUTOUTPUT_FAST_READ = 8'hBD;
localparam DTR_QUAD_OUTPUT_FAST_READ      = 8'h6D;
localparam DTR_QUAD_INPUTOUTPUT_FAST_READ = 8'hED;
localparam QUAD_INPUTOUTPUT_WORD_READ     = 8'hE7;

// READ MEMORY Operations with 4-Byte Address
localparam OP_4BYTE_READ                  = 8'h13;
localparam OP_4BYTE_FAST_READ             = 8'h0C;
localparam OP_4BYTE_DUAL_OUTPUT_FAST_READ = 8'h3C;

logic [7:0] opcode_q, opcode_d;
logic       flag_q, flag_d;
int         counter_q, counter_d;
logic       err_q, err_d;

typedef enum logic [1:0] {
    IDLE, READ_OPCODE, ERR, FORWARD_REQ
} state_e;
state_e   state_d, state_q;

// tie-off
assign spih_sck_o    = err_q ? '1 : spi_chs_sck;
assign spih_sck_en_o = err_q ? '1 : spi_chs_sck_en;
assign spih_csb_o    = err_q ? '1 : spi_chs_csb;
assign spih_csb_en_o = err_q ? '1 : spi_chs_csb_en;
assign spih_sd_o     = err_q ? '1 : spi_chs_sdo;
assign spih_sd_en_o  = err_q ? '1 : spi_chs_sdo_en;
assign spi_chs_sdi   = err_q ? '1 : spih_sd_i;


always_comb begin

    // Keep the current state
    state_d = state_q;
    err_d   = err_q;

    unique case (state_q)
        IDLE: begin
            if (!spi_chs_csb[1]) begin // verify the en
                state_d = READ_OPCODE;
            end
        end

        READ_OPCODE: begin
            if (flag_q) begin
                //$fatal(1, "SPI FLASH READED OPCODE");
                if ( opcode_q == OP_4BYTE_READ ||
                     opcode_q == OP_4BYTE_READ     ) begin
                    state_d = FORWARD_REQ;
                end else begin
                    state_d = ERR;
                end
            end
        end

        ERR: begin
            err_d = 1;
            $fatal(1, "SPI FLASH WRONG OPCODE");
        end

        FORWARD_REQ: begin
            if (spi_chs_csb[1]) begin // wait for the end of the transaction
                state_d = IDLE;
            end
        end
    endcase

end


always @ (posedge spi_chs_sck) begin
    opcode_d  = opcode_q;
    counter_d = counter_q;
    flag_d    = flag_q;

    if ( spi_chs_sck_en && (state_q == READ_OPCODE) ) begin // verifie enable
        if (counter_d < 8) begin
            opcode_d[7-counter_d] = spi_chs_sdo;
            counter_d++;
        end else begin
            counter_d = 0;
            flag_d = 1;
        end
    end

    if (state_q == FORWARD_REQ) begin
        flag_d = 0;
    end
end


always_ff @(posedge clk_i, negedge rst_ni) begin // clk-reset
    if (!rst_ni) begin
      opcode_q  <= '0;
      flag_q    <= '0;
      counter_q <= '0;
      err_q     <= '0;
      state_q   <= IDLE;
    end else begin
      opcode_q  <= opcode_d;
      flag_q    <= flag_d;
      counter_q <= counter_d;
      err_q     <= err_d;
      state_q   <= state_d;
    end
  end

endmodule