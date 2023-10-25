// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// APB Demultiplexer Description:
// This module demultiplexes one APB slave portto several master ports using
// the select_i signal.

module apb_demux #(
  parameter int unsigned NoMstPorts  = 32'd2, // The number of demux ports. If
                                              // 1, degenerates gracefully to a
                                              // feedthrough.
  parameter type req_t               = logic, // APB request strcut
  parameter type resp_t              = logic, // APB response struct
  // DEPENDENT PARAMETERS DO NOT OVERWRITE!
  parameter int unsigned SelectWidth = (NoMstPorts > 32'd1)? $clog2(NoMstPorts) : 32'd1,
  parameter type select_t            = logic [SelectWidth-1:0]
)(
  input req_t                   slv_req_i,
  output resp_t                 slv_resp_o,
  output req_t [NoMstPorts-1:0] mst_req_o,
  input resp_t [NoMstPorts-1:0] mst_resp_i,
  input select_t                select_i
);

  if (NoMstPorts == 32'd1)  begin
    assign mst_req_o[0] = slv_req_i;
    assign slv_resp_o   = mst_resp_i[0];
  end else begin
    for (genvar idx = 0; idx < NoMstPorts; idx++) begin
      assign mst_req_o[idx].paddr   = slv_req_i.paddr;
      assign mst_req_o[idx].pprot   = slv_req_i.pprot;
      assign mst_req_o[idx].psel    = (select_i == idx)? slv_req_i.psel: 1'b0;
      assign mst_req_o[idx].penable = (select_i == idx)? slv_req_i.penable: 1'b0;
      assign mst_req_o[idx].pwrite  = slv_req_i.pwrite;
      assign mst_req_o[idx].pwdata  = slv_req_i.pwdata;
      assign mst_req_o[idx].pstrb   = slv_req_i.pstrb;
    end

    always_comb begin
      if (select_i < NoMstPorts) begin
        slv_resp_o.pready  = mst_resp_i[select_i].pready;
        slv_resp_o.prdata  = mst_resp_i[select_i].prdata;
        slv_resp_o.pslverr = mst_resp_i[select_i].pslverr;
      end else begin
        slv_resp_o.pready  = 1'b1;
        slv_resp_o.prdata  = '0;
        slv_resp_o.pslverr = 1'b1;
      end
    end
  end

endmodule

`include "apb/typedef.svh"
`include "apb/assign.svh"

module apb_demux_intf #(
  parameter int unsigned APB_ADDR_WIDTH = 0,
  parameter int unsigned APB_DATA_WIDTH = 0,
  parameter int unsigned NoMstPorts = 32'd2,
  // DEPENDENT PARAMETERS DO NOT OVERWRITE!
  parameter int unsigned SelectWidth = (NoMstPorts > 32'd1)? $clog2(NoMstPorts) : 32'd1,
  parameter type select_t = logic [SelectWidth-1:0]
)(
  APB.Slave   slv,
  APB.Master  mst [NoMstPorts-1:0],
  input select_t select_i
);

  typedef logic [APB_ADDR_WIDTH-1:0] addr_t;
  typedef logic [APB_DATA_WIDTH-1:0] data_t;
  typedef logic [APB_DATA_WIDTH/8-1:0] strb_t;

  `APB_TYPEDEF_REQ_T(apb_req_t, addr_t, data_t, strb_t)
  `APB_TYPEDEF_RESP_T(apb_resp_t, data_t)

  apb_req_t slv_req;
  apb_resp_t slv_resp;

  apb_req_t [NoMstPorts-1:0] mst_req;
  apb_resp_t [NoMstPorts-1:0] mst_resp;

  for (genvar idx = 0; idx < NoMstPorts; idx++) begin
    `APB_ASSIGN_FROM_REQ(mst[idx], mst_req[idx])
    `APB_ASSIGN_TO_RESP(mst_resp[idx], mst[idx])
  end
  `APB_ASSIGN_TO_REQ(slv_req, slv)
  `APB_ASSIGN_FROM_RESP(slv, slv_resp)

  apb_demux #(
   .NoMstPorts ( NoMstPorts ),
   .req_t    ( apb_req_t  ),
   .resp_t   ( apb_resp_t )
 ) i_apb_cdc (
   .slv_req_i  ( slv_req  ),
   .slv_resp_o ( slv_resp ),
   .mst_req_o  ( mst_req  ),
   .mst_resp_i ( mst_resp ),
   .select_i
  );
endmodule
