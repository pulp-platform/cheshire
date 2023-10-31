// Copyright 2023 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Florian Zaruba <zarubaf@iis.ee.ethz.ch>

module apb_to_reg #(
  parameter bit Feedthrough = 1'b1
)(
  input  logic          clk_i,
  input  logic          rst_ni,

  input  logic          penable_i,
  input  logic          pwrite_i,
  input  logic [31:0]   paddr_i,
  input  logic          psel_i,
  input  logic [31:0]   pwdata_i,
  output logic [31:0]   prdata_o,
  output logic          pready_o,
  output logic          pslverr_o,

  REG_BUS.out  reg_o
);

  if (Feedthrough) begin : gen_feedthrough
    // in this mode just using plain register interface makes more sense
    always_comb begin
      reg_o.addr = paddr_i;
      reg_o.write = pwrite_i;
      reg_o.wdata = pwdata_i;
      reg_o.wstrb = '1;
      reg_o.valid = psel_i & penable_i;
      pready_o = reg_o.ready;
      pslverr_o = reg_o.error;
      prdata_o = reg_o.rdata;
    end

  end else begin : gen_apb_reg
    // latch forward path as apb intends
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        reg_o.addr  <= '0;
        reg_o.write <= '0;
        reg_o.wdata <= '0;
      end else if (psel_i && !penable_i) begin
        reg_o.addr  <= paddr_i;
        reg_o.write <= pwrite_i;
        reg_o.wdata <= pwdata_i;
      end
    end

    always_comb begin
      reg_o.valid = psel_i & penable_i;
      reg_o.wstrb = '1;
      pready_o = reg_o.ready;
      pslverr_o = reg_o.error;
      prdata_o = reg_o.rdata;
    end
  end
endmodule

module apb_to_reg_intf #(
  parameter int unsigned DATA_WIDTH = 32,
  parameter int unsigned ADDR_WIDTH = 32
)(
  APB.Slave    apb_i,
  REG_BUS.out  reg_o
);

  always_comb begin
    reg_o.addr    = apb_i.paddr;
    reg_o.write   = apb_i.pwrite;
    reg_o.wdata   = apb_i.pwdata;
    reg_o.wstrb   = '1;
    reg_o.valid   = apb_i.psel & apb_i.penable;
    apb_i.pready  = reg_o.ready;
    apb_i.pslverr = reg_o.error;
    apb_i.prdata  = reg_o.rdata;
  end

endmodule
