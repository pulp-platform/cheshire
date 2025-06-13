`include "common_cells/registers.svh"

module dat_read_timeout #(
  parameter int TIMEOUT_COUNTER_WIDTH = 28 // maximum timeout is 2**27
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic       running_i,
  input  logic [3:0] timeout_bits_i,

  output logic       timeout_o
);
  logic [TIMEOUT_COUNTER_WIDTH-1:0] timeout_counter_q, timeout_counter_d;
  `FF (timeout_counter_q, timeout_counter_d, 0, clk_i, rst_ni);
  
  assign timeout_o = (timeout_counter_q >= (1 << (timeout_bits_i + 13)));
  assign timeout_counter_d = running_i && !timeout_o ? timeout_counter_q + 1 : 0;
endmodule