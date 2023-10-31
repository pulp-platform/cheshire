// Copyright 2023 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Luca Valente <luca.valente@unibo.it>

`include "register_interface/assign.svh"
`include "common_cells/registers.svh"

module reg_cut #(
    parameter type req_t = logic,
    parameter type rsp_t = logic
) (
    input  logic clk_i,
    input  logic rst_ni,

    input  req_t src_req_i,
    output rsp_t src_rsp_o,

    output req_t dst_req_o,
    input  rsp_t dst_rsp_i
);

   typedef enum logic[1:0] {
     WaitValid = 2'b00,
     WaitReady = 2'b01,
     GiveReady = 2'b10
   } state_t;
   state_t state_d, state_q;

   req_t req_q;
   rsp_t rsp_q;

   always_comb begin
     dst_req_o.valid = 1'b0;
     src_rsp_o.ready = 1'b0;
     state_d = state_q;
     case(state_q)
       WaitValid : begin
          if(src_req_i.valid)
            state_d = WaitReady;
       end
       WaitReady : begin
          dst_req_o.valid = 1'b1;
          if(dst_rsp_i.ready)
            state_d = GiveReady;
       end
       GiveReady : begin
          src_rsp_o.ready = 1'b1;
          state_d = WaitValid;
       end
       default: ;
     endcase
   end

   assign src_rsp_o.error = rsp_q.error;
   assign src_rsp_o.rdata = rsp_q.rdata;
   assign dst_req_o.addr  = req_q.addr;
   assign dst_req_o.write = req_q.write;
   assign dst_req_o.wdata = req_q.wdata;
   assign dst_req_o.wstrb = req_q.wstrb;

   `FF(req_q,src_req_i,'0,clk_i,rst_ni)
   `FF(rsp_q,dst_rsp_i,'0,clk_i,rst_ni)
   `FF(state_q,state_d,WaitValid,clk_i,rst_ni)

endmodule
