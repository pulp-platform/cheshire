//CRC7 calculation. Takes in serial data.
//shifts out result MSb first when shift_out_crc7_i is high, output should otherwise be ignored.
//polynomial: x⁷ + x³ + 1

`include "common_cells/registers.svh"

module crc7_write (
  input   logic clk_i,
  input   logic clk_en_i,
  input   logic rst_ni,

  input   logic shift_out_crc7_i,
  input   logic input_en_i, //enable for data_ser_i
  input   logic dat_ser_i,
  output  logic crc_ser_o
);
  logic [2:0] lower_3_d, lower_3_q;
  logic [3:0] upper_4_d, upper_4_q;
  logic dat_ser;
  logic dat_i_xor_out;

  assign dat_ser = (input_en_i) ? dat_ser_i : 1'b0; //unnecessary in current implementation, but seems wise
  assign dat_i_xor_out = (dat_ser ^ crc_ser_o);

  always_comb begin : crc7_comb
    lower_3_d = lower_3_q;
    upper_4_d = upper_4_q;
    
    if (shift_out_crc7_i) begin : shift_out_result
      upper_4_d[3:1]  = upper_4_q[2:0];
      upper_4_d[0]    = lower_3_q[2];
      lower_3_d[2:1]  = lower_3_q[1:0];
      lower_3_d[0]    = 1'b0; //Fill with zeros while shifting out crc; no reset needed?
    end else begin : calc_crc7
      upper_4_d[3:1]  = upper_4_q[2:0];
      upper_4_d[0]    = (lower_3_q[2] ^ dat_i_xor_out);
      lower_3_d[2:1]  = lower_3_q[1:0];
      lower_3_d[0]    = dat_i_xor_out;
    end
  end
  
  `FFL (lower_3_q, lower_3_d, clk_en_i, 0, clk_i, rst_ni);
  `FFL (upper_4_q, upper_4_d, clk_en_i, 0, clk_i, rst_ni);
  
  //Output assignment
  assign crc_ser_o = upper_4_q[3];

endmodule