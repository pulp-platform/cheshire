
`timescale 1ns/1ps


module chehsire_top_xlnx_tb;

wire clk_n;
wire clk_p;

xlnx_sim_clk_gen xlnx_sim_clk_gen_i (
  .clk_n(clk_n),
  .clk_p(clk_p)
);


cheshire_top_xilinx cheshire_top_xilinx_i (
);


endmodule
