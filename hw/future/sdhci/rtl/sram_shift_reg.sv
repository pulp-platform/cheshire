/**
 * Shift Register built using an SRAM
 * The first element is always readable at `read_data_o`
 * Asserting `pop_front_i` tries to put the next word into `read_data_o` within one clock cycle
 * If a push is happening at the same time the pop is delayed by a clock cycle
 * The first push (when empty_o = '1) takes 2 clock cycles to appear in the `front_data_o`
 */

`ifdef VERILATOR
`define INC_ASSERT
`endif

`include "common_cells/registers.svh"
`include "common_cells/assertions.svh"

module sram_shift_reg #(
  parameter int unsigned NumWords     = 1024,
  parameter int unsigned DataWidth    = 32,
  parameter int unsigned AddrWidth    = cf_math_pkg::idx_width(NumWords),
  parameter int unsigned LengthWidth  = cf_math_pkg::idx_width(NumWords + 1)
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic en_i,


  input  logic                 pop_front_i,
  output logic [DataWidth-1:0] front_data_o,
  input  logic                 push_back_i,
  input  logic [DataWidth-1:0] back_data_i,

  output logic                   empty_o,
  output logic                   full_o,
  output logic [LengthWidth-1:0] length_o
);
  // Push a pop operation to the next clock cycle if the sram is busy
  logic pop_front_q, pop_front_d;
  `FF(pop_front_q, pop_front_d, '0, clk_i, rst_ni);
  assign pop_front_d = pop_front_i & (push_back_i | pop_front_q);

  `ASSERT_NEVER(Overload, pop_front_i & push_back_i & pop_front_q);

  logic [AddrWidth-1:0] back_addr_q, back_addr_d;
  `FF(back_addr_q, back_addr_d, '0, clk_i, rst_ni);

  logic [LengthWidth-1:0] length_q, length_d;
  `FF(length_q, length_d, '0, clk_i, rst_ni);

  always_comb begin
    length_d = length_q;
    back_addr_d = back_addr_q;

    if (!en_i) begin
      length_d = '0;
    end else if (push_back_i) begin
      length_d = length_q + 1;
      back_addr_d = AddrWidth'((back_addr_q + 1) % NumWords);
    end else if (pop_front_i || pop_front_q) begin
      length_d = length_q - 1;
    end
  end

  assign empty_o  = length_q == '0;
  assign full_o   = length_q == NumWords;
  assign length_o = length_q;

  `ASSERT_NEVER(Underflow, (pop_front_i || pop_front_q) && empty_o);
  `ASSERT_NEVER(Overflow,  push_back_i && full_o);

  tc_sram_impl #(
    .NumWords  ( NumWords ),
    .DataWidth ( DataWidth ),
    .NumPorts  ( 1 ),
    .Latency   ( 1 )
  ) i_sram (
    .clk_i,
    .rst_ni,

    .impl_i  ('1),
    .impl_o  ( ),

    .req_i   (en_i),
    .we_i    (push_back_i),
    .addr_i  (push_back_i ? back_addr_q : AddrWidth'((back_addr_q - length_q) % NumWords)),

    .wdata_i (back_data_i),
    .be_i    ('1),
    .rdata_o (front_data_o)
  );
endmodule
