`include "common_cells/registers.svh"

module crc16_read (
  input   logic   clk_i,
  input   logic   sd_clk_en_i,
  input   logic   rst_ni,

  input   logic   shift_in_i,

  input   logic   dat_ser_i,
  output  logic   [15:0]  crc16_o
);
  logic [4:0] lower_5_d,  lower_5_q;
  logic [6:0] middle_7_d, middle_7_q;
  logic [3:0] upper_4_d,  upper_4_q;
  logic int_rst_n, dat_i_xor_out;

  always_comb begin : crc_data_path
    crc16_o       = { upper_4_q, middle_7_q, lower_5_q };
    dat_i_xor_out = (dat_ser_i ^ upper_4_q[3]);

    if (shift_in_i) begin
       upper_4_d[3:1] =  upper_4_q[2:0];
       upper_4_d[0]   = middle_7_q[6] ^ dat_i_xor_out;
      middle_7_d[6:1] = middle_7_q[5:0];
      middle_7_d[0]   =  lower_5_q[4] ^ dat_i_xor_out;
       lower_5_d[4:1] =  lower_5_q[3:0];
       lower_5_d[0]   = dat_i_xor_out;
    end else begin
       upper_4_d = '0;
      middle_7_d = '0;
       lower_5_d = '0;
    end
  end

  `FFL ( lower_5_q,  lower_5_d, sd_clk_en_i, '0);
  `FFL (middle_7_q, middle_7_d, sd_clk_en_i, '0);
  `FFL ( upper_4_q,  upper_4_d, sd_clk_en_i, '0);
endmodule
