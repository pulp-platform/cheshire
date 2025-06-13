//Parallel to serial converter with active low asynchronous reset
//shifts out MSb first!

`include "common_cells/registers.svh"

module par_ser_shift_reg #(
  parameter int unsigned  NumBits     = 40,   //Number of bits
  parameter bit           ShiftInVal  = 0     //value to be shifted in, unimportant
) (
  input   logic clk_i,
  input   logic clk_en_i,
  input   logic rst_ni,

  input   logic par_write_en_i, //write data in parallel to shift register
  input   logic shift_en_i,     //enable shifting, non-latching!

  input   logic [NumBits-1:0] dat_par_i,
  output  logic               dat_ser_o
);
  logic [NumBits-1:0] dat_d, dat_q;

  always_comb begin
    dat_d = dat_q;  //default assignment

    if (par_write_en_i) begin : parallel_write
      dat_d = dat_par_i;
    end
    else if (shift_en_i) begin : shift_data
      dat_d[NumBits-1:1] = dat_q[NumBits-2:0];
      dat_d[0] = ShiftInVal;  //backfill with ShiftInVal
    end
  end
  
  `FFL(dat_q, dat_d, clk_en_i, 0, clk_i, rst_ni);

  //output assignment
  assign dat_ser_o = dat_q[NumBits-1];
endmodule