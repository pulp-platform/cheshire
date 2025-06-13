`include "common_cells/registers.svh"

module crc16_write (
  input logic clk_i,
  input logic sd_clk_en_i,
  input logic rst_ni,

  input logic shift_out_crc16_i,
  input logic dat_ser_i,

  output logic crc_ser_o
);
  logic [4:0] lower_5_d,  lower_5_q;
  logic [6:0] middle_7_d, middle_7_q;
  logic [3:0] upper_4_d,  upper_4_q;
  logic dat_i_xor_out;

  always_comb begin : crc16_comb
    dat_i_xor_out = 1'b0;

    if (shift_out_crc16_i) begin : shift_out_result
      crc_ser_o       =  upper_4_q[3];
       upper_4_d[3:1] =  upper_4_q[2:0];
       upper_4_d[0]   = middle_7_q[6];
      middle_7_d[6:1] = middle_7_q[5:0];
      middle_7_d[0]   =  lower_5_q[4];
       lower_5_d[4:1] =  lower_5_q[3:0];
       lower_5_d[0]   = 1'b0; //shift in zeros while shifting out crc, no reset needed.
    end else begin : calc_crc16
      dat_i_xor_out   =  upper_4_q[3] ^ dat_ser_i;
       upper_4_d[3:1] =  upper_4_q[2:0];
       upper_4_d[0]   = middle_7_q[6] ^ dat_i_xor_out;
      middle_7_d[6:1] = middle_7_q[5:0];
      middle_7_d[0]   =  lower_5_d[4] ^ dat_i_xor_out;
       lower_5_d[4:1] =  lower_5_q[3:0];
       lower_5_d[0]   = dat_i_xor_out;
    end
  end

  `FFL ( upper_4_q,  upper_4_d, sd_clk_en_i, 0);
  `FFL (middle_7_q, middle_7_d, sd_clk_en_i, 0);
  `FFL ( lower_5_q,  lower_5_d, sd_clk_en_i, 0);

`ifdef VERILATOR
  logic [15:0] crc;
  assign crc = { upper_4_q, middle_7_q, lower_5_q };
`endif
endmodule
