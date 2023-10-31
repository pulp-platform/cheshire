// Copyright 2023 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Michael Rogenmoser <michaero@iis.ee.ethz.ch>
// Robert Balas <balasr@iis.ee.ethz.ch>

/// Filter write requests where the strobe is all '0.
/// This is useful for regtool generated register files because these
/// categorically reject empty strobes.
module reg_filter_empty_writes #(
  parameter type req_t = logic,
  parameter type rsp_t = logic
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  req_t in_req_i,
  output rsp_t in_rsp_o,
  output req_t out_req_o,
  input  rsp_t out_rsp_i
);

  always_comb begin
    out_req_o = in_req_i;
    in_rsp_o = out_rsp_i;

    if (in_req_i.valid && in_req_i.write && in_req_i.wstrb == '0) begin
      out_req_o.valid = 1'b0;
      in_rsp_o.ready = 1'b1;
      in_rsp_o.error = 1'b0;
    end
  end

endmodule
