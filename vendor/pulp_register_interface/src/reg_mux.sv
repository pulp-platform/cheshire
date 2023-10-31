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

`include "register_interface/typedef.svh"

/// Multiplex/Arbitrate one register interface to `NoPorts`.
module reg_mux #(
  parameter int unsigned NoPorts = 32'd0,
  parameter int unsigned AW = 0,
  parameter int unsigned DW = 0,
  parameter type req_t = logic,
  parameter type rsp_t = logic
) (
  input  logic               clk_i,
  input  logic               rst_ni,
  input  req_t [NoPorts-1:0] in_req_i,
  output rsp_t [NoPorts-1:0] in_rsp_o,
  output req_t               out_req_o,
  input  rsp_t               out_rsp_i
);

  logic [NoPorts-1:0] in_valid, in_ready;
  `REG_BUS_TYPEDEF_REQ(req_payload_t, logic [AW-1:0], logic [DW-1:0], logic [DW/8-1:0])

  req_payload_t [NoPorts-1:0] in_payload;
  req_payload_t out_payload;

  for (genvar i = 0; i < NoPorts; i++) begin : gen_unpack
    // Request
    assign in_valid[i] = in_req_i[i].valid;
    assign in_payload[i].addr = in_req_i[i].addr;
    assign in_payload[i].write = in_req_i[i].write;
    assign in_payload[i].wdata = in_req_i[i].wdata;
    assign in_payload[i].wstrb = in_req_i[i].wstrb;
    assign in_payload[i].valid = in_req_i[i].valid;
    // Response
    assign in_rsp_o[i].ready = in_ready[i];
    assign in_rsp_o[i].rdata = out_rsp_i.rdata;
    assign in_rsp_o[i].error = out_rsp_i.error;
  end

  stream_arbiter #(
    .DATA_T (req_payload_t),
    .N_INP (NoPorts)
  ) i_stream_arbiter (
    .clk_i,
    .rst_ni,
    .inp_data_i (in_payload),
    .inp_valid_i (in_valid),
    .inp_ready_o (in_ready),
    .oup_data_o (out_payload),
    .oup_valid_o (out_req_o.valid),
    .oup_ready_i (out_rsp_i.ready)
  );

  assign out_req_o.addr = out_payload.addr;
  assign out_req_o.write = out_payload.write;
  assign out_req_o.wdata = out_payload.wdata;
  assign out_req_o.wstrb = out_payload.wstrb;

endmodule
