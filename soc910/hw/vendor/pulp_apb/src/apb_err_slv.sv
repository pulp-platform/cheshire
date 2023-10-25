//-----------------------------------------------------------------------------
// Title         : APB Error Slave
//-----------------------------------------------------------------------------
// File          : apb_err_slv.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 05.12.2022
//-----------------------------------------------------------------------------
// Description :
// This module always responds with an error response on any request of its APB
// slave port. Use thismodule e.g. as the default port in a APB demultiplexer
// to handle illegal access. Following the reccomendation of the APB 2.0
// specification, the error response will only be asserted on a valid
//  transaction.
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2022 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------
module apb_err_slv #(
  parameter                       type req_t = logic,     // APB request struct
  parameter                       type resp_t = logic,    // APB response struct
  parameter int unsigned          RespWidth = 32'd32,     // Data width of the response. Gets zero extended or truncated to r.data.
  parameter logic [RespWidth-1:0] RespData = 32'hBADCAB1E // Hexvalue for the data to return on error.
) (
  input req_t slv_req_i,
  output resp_t slv_resp_o
);

  assign slv_resp_o.prdata = RespData;
  assign slv_resp_o.pready = 1'b1;
  // Following the APB recommendations, we only assert the error signal if there is actually a
  // request.
  assign slv_resp_o.pslverr = (slv_req_i.psel & slv_req_i.penable)?
                              apb_pkg::RESP_SLVERR : apb_pkg::RESP_OKAY;

endmodule


`include "apb/typedef.svh"
`include "apb/assign.svh"

module apb_err_slv_intf #(
  parameter int unsigned          APB_ADDR_WIDTH = 0,
  parameter int unsigned          APB_DATA_WIDTH = 0,
  parameter logic [APB_DATA_WIDTH-1:0] RespData  = 32'hBADCAB1E
) (
  APB.Slave slv
);

  typedef logic [APB_ADDR_WIDTH-1:0] addr_t;
  typedef logic [APB_DATA_WIDTH-1:0] data_t;
  typedef logic [APB_DATA_WIDTH/8-1:0] strb_t;

  `APB_TYPEDEF_REQ_T(apb_req_t, addr_t, data_t, strb_t)
  `APB_TYPEDEF_RESP_T(apb_resp_t, data_t)

  apb_req_t slv_req;
  apb_resp_t slv_resp;

  `APB_ASSIGN_TO_REQ(slv_req, slv)
  `APB_ASSIGN_FROM_RESP(slv, slv_resp)

  apb_err_slv #(
    .req_t     ( apb_req_t      ),
    .resp_t    ( apb_resp_t     ),
    .RespWidth ( APB_DATA_WIDTH ),
    .RespData  ( RespData       )
  ) i_apb_err_slv (
    .slv_req_i  ( slv_req  ),
    .slv_resp_o ( slv_resp )
  );

endmodule
