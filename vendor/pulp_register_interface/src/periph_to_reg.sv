// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Translates XBAR_PERIPH_BUS to register_interface

module periph_to_reg #(
  parameter int unsigned AW    = 32,    // Address Width
  parameter int unsigned DW    = 32,    // Data Width
  parameter int unsigned BW    = 8,     // Byte Width
  parameter int unsigned IW    = 0,     // ID Width
  parameter type         req_t = logic, // reg request type
  parameter type         rsp_t = logic  // reg response type
) (
  input  logic             clk_i,    // Clock
  input  logic             rst_ni,   // Asynchronous reset active low

  input  logic             req_i,
  input  logic [   AW-1:0] add_i,
  input  logic             wen_i,
  input  logic [   DW-1:0] wdata_i,
  input  logic [DW/BW-1:0] be_i,
  input  logic [   IW-1:0] id_i,
  output logic             gnt_o,
  output logic [   DW-1:0] r_rdata_o,
  output logic             r_opc_o,
  output logic [   IW-1:0] r_id_o,
  output logic             r_valid_o,

  output req_t             reg_req_o,
  input  rsp_t             reg_rsp_i
);

  logic [IW-1:0] r_id_d, r_id_q;
  logic          r_opc_d, r_opc_q;
  logic          r_valid_d, r_valid_q;
  logic [DW-1:0] r_rdata_d, r_rdata_q;

  always_comb begin : proc_logic
    r_id_d = id_i;
    r_opc_d = reg_rsp_i.error;
    r_valid_d = gnt_o;
    r_rdata_d = reg_rsp_i.rdata;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_seq
    if (!rst_ni) begin
      r_id_q <= '0;
      r_opc_q <= '0;
      r_valid_q <= '0;
      r_rdata_q <= '0;
    end else begin
      r_id_q <= r_id_d;
      r_opc_q <= r_opc_d;
      r_valid_q <= r_valid_d;
      r_rdata_q <= r_rdata_d;
    end
  end

  assign reg_req_o.addr  = add_i;
  assign reg_req_o.write = ~wen_i;
  assign reg_req_o.wdata = wdata_i;
  assign reg_req_o.wstrb = be_i;
  assign reg_req_o.valid = req_i;

  assign gnt_o     = req_i & reg_rsp_i.ready;

  assign r_rdata_o = r_rdata_q;
  assign r_opc_o   = r_opc_q;
  assign r_id_o    = r_id_q;
  assign r_valid_o = r_valid_q;

/* Signal explanation for reference
{signal: [
  {name: 'clk',        wave: 'p.|....'},
  {name: 'PE_req',     wave: '01|..0.'},
  {name: 'PE_add',     wave: 'x2|..x.', data: ["addr"]},
  {name: 'PE_wen',     wave: 'x2|..x.', data: ["wen"]},
  {name: 'PE_wdata',   wave: 'x2|..x.', data: ["wdata"]},
  {name: 'PE_be',      wave: 'x2|..x.', data: ["strb"]},
  {name: 'PE_gnt',     wave: '0.|.10.'},
  {name: 'PE_id',      wave: 'x2|..x.', data: ["ID"]},
  {name: 'PE_r_valid', wave: '0.|..10'},
  {name: 'PE_r_opc',   wave: 'x.|..2x', data: ["error"]},
  {name: 'PE_r_id',    wave: 'x.|..2x', data: ["ID"]},
  {name: 'PE_r_rdata', wave: 'x.|..2x', data: ["rdata"]},
  {},
  {name: 'write', wave: 'x2|..x.', data:['~wen']},
  {name: 'addr' , wave: 'x2|..x.', data: ["addr"]},
  {name: 'rdata', wave: 'x.|.2x.', data: ["rdata"]},
  {name: 'wdata', wave: 'x2|..x.', data: ["wdata"]},
  {name: 'wstrb', wave: 'x2|..x.', data: ["strb"]},
  {name: 'error', wave: 'x.|.2x.', data: ["error"]},
  {name: 'valid', wave: '01|..0.'},
  {name: 'ready', wave: 'x0|.1x.'},
]}
*/

endmodule
