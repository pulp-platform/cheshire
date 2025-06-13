//serial to parallel converter with active low asynchronous reset
//shifts in MSb first!

`include "common_cells/registers.svh"

module ser_par_shift_reg #(
  parameter int unsigned  NumBits     = 48,
  parameter bit           MaskOutput  = 0  //if output is masked with zeros during shifting, if 1, par_output_en_i is needed.
) (
  input   logic               clk_i,
  input   logic               clk_en_i,
  input   logic               rst_ni,

  input   logic               shift_in_en_i,
  input   logic               par_output_en_i,

  input   logic               dat_ser_i,
  output  logic [NumBits-1:0] dat_par_o
);
  logic [NumBits-1:0] dat_d, dat_q;
  
  always_comb begin
    dat_d = dat_q; //default assignment

    if (shift_in_en_i) begin : shift_in
      dat_d[NumBits-1:1]  = dat_q[NumBits-2:0];
      dat_d[0]            = dat_ser_i;
    end
  end

  `FFL(dat_q, dat_d, clk_en_i, 0, clk_i, rst_ni);

  generate
    if (MaskOutput) begin
      assign  dat_par_o = (par_output_en_i) ? dat_q : '0;
    end else begin
      assign  dat_par_o = dat_q;
    end
  endgenerate
  
endmodule