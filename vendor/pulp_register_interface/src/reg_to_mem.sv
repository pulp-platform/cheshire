// Copyright 2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Florian Zaruba <zarubaf@iis.ee.ethz.ch>
// Fabian Schuiki <fschuiki@iis.ee.ethz.ch>

`include "common_cells/registers.svh"

/// Register bus to SRAM interface.
module reg_to_mem #(
  parameter int unsigned AW = 0,
  parameter int unsigned DW = 0,
  parameter type req_t = logic,
  parameter type rsp_t = logic
) (
  input  logic               clk_i,
  input  logic               rst_ni,
  input  req_t               reg_req_i,
  output rsp_t               reg_rsp_o,
  // SRAM out
  output logic               req_o,
  input  logic               gnt_i,
  output logic               we_o,
  output logic [AW-1:0]      addr_o,
  output logic [DW-1:0]      wdata_o,
  output logic [DW/8-1:0]    wstrb_o,
  input  logic [DW-1:0]      rdata_i,
  input  logic               rvalid_i,
  input  logic               rerror_i
);

  logic wait_read_d, wait_read_q;
  `FF(wait_read_q, wait_read_d, 1'b0)

  always_comb begin
    wait_read_d = wait_read_q;
    if (req_o && gnt_i && !we_o) wait_read_d = 1'b1;
    if (wait_read_q && reg_rsp_o.ready) wait_read_d = 1'b0;
  end

  assign req_o = ~wait_read_q & reg_req_i.valid;
  assign we_o = reg_req_i.write;
  assign addr_o = reg_req_i.addr[AW-1:0];
  assign wstrb_o = reg_req_i.wstrb;
  assign wdata_o = reg_req_i.wdata;

  assign reg_rsp_o.rdata = rdata_i;
  assign reg_rsp_o.error = rerror_i;
  assign reg_rsp_o.ready = (reg_req_i.valid & gnt_i & we_o) | (wait_read_q & rvalid_i);

endmodule
