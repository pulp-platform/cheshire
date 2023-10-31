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

module reg_demux #(
  parameter int unsigned NoPorts = 32'd0,
  parameter type req_t = logic,
  parameter type rsp_t = logic,
  // Dependent parameters, DO NOT OVERRIDE!
  parameter int unsigned SelectWidth    = (NoPorts > 32'd1) ? $clog2(NoPorts) : 32'd1,
  parameter type         select_t       = logic [SelectWidth-1:0]
) (
  input  logic               clk_i,
  input  logic               rst_ni,
  input  select_t            in_select_i,
  input  req_t               in_req_i,
  output rsp_t               in_rsp_o,
  output req_t [NoPorts-1:0] out_req_o,
  input  rsp_t [NoPorts-1:0] out_rsp_i
);

  always_comb begin
    out_req_o = '0;
    in_rsp_o = '0;
    out_req_o[in_select_i] = in_req_i;
    in_rsp_o = out_rsp_i[in_select_i];
  end

endmodule
