// Copyright (c) 2018 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`ifndef APB_ASSIGN_SVH_
`define APB_ASSIGN_SVH_

////////////////////////////////////////////////////////////////////////////////////////////////////
// Assign an APB4 interface to another, as if you would do in `assign slv = mst;`.
//
// Usage example:
// `APB_ASSIGN(slv, mst)
`define APB_ASSIGN(dst, src)         \
  assign dst.paddr   = src.paddr;    \
  assign dst.pprot   = src.pprot;    \
  assign dst.psel    = src.psel;     \
  assign dst.penable = src.penable;  \
  assign dst.pwrite  = src.pwrite;   \
  assign dst.pwdata  = src.pwdata;   \
  assign dst.pstrb   = src.pstrb;    \
  assign src.pready  = dst.pready;   \
  assign src.prdata  = dst.prdata;   \
  assign src.pslverr = dst.pslverr;
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Internal implementation for assigning interfaces from structs, allows for standalone assignments
// (with `opt_as = assign`) and assignments inside process (with `opt_as` void) with the same code.
`define APB_FROM_REQ(opt_as, apb_if, req_struct) \
  opt_as apb_if.paddr   = req_struct.paddr;      \
  opt_as apb_if.pprot   = req_struct.pprot;      \
  opt_as apb_if.psel    = req_struct.psel;       \
  opt_as apb_if.penable = req_struct.penable;    \
  opt_as apb_if.pwrite  = req_struct.pwrite;     \
  opt_as apb_if.pwdata  = req_struct.pwdata;     \
  opt_as apb_if.pstrb   = req_struct.pstrb;
`define APB_FROM_RESP(opt_as, apb_if, resp_struct) \
  opt_as apb_if.pready  = resp_struct.pready;      \
  opt_as apb_if.prdata  = resp_struct.prdata;      \
  opt_as apb_if.pslverr = resp_struct.pslverr;
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Setting an interface from request/response structs inside a process.
//
// Usage Example:
// always_comb begin
//   `APB_SET_FROM_REQ(my_if, my_req_struct)
//   `APB_SET_FROM_RESP(my_if, my_resp_struct)
// end
`define APB_SET_FROM_REQ(apb_if, req_struct)  `APB_FROM_REQ(, apb_if, req_struct)
`define APB_SET_FROM_RESP(apb_if, resp_struct) `APB_FROM_RESP(, apb_if, resp_struct)
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Assigning an interface from request/response structs outside a process.
//
// Usage Example:
// `APB_ASSIGN_FROM_REQ(my_if, my_req_struct)
// `APB_ASSIGN_FROM_RESP(my_if, my_resp_struct)
`define APB_ASSIGN_FROM_REQ(apb_if, req_struct)  `APB_FROM_REQ(assign, apb_if, req_struct)
`define APB_ASSIGN_FROM_RESP(apb_if, resp_struct) `APB_FROM_RESP(assign, apb_if, resp_struct)
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Internal implementation for assigning to structs from interfaces, allows for standalone
// assignments (with `opt_as = assign`) and assignments inside processes (with `opt_as` void) with
// the same code.
`define APB_TO_REQ(opt_as, req_struct, apb_if) \
  opt_as req_struct = '{                       \
    paddr:   apb_if.paddr,                     \
    pprot:   apb_if.pprot,                     \
    psel:    apb_if.psel,                      \
    penable: apb_if.penable,                   \
    pwrite:  apb_if.pwrite,                    \
    pwdata:  apb_if.pwdata,                    \
    pstrb:   apb_if.pstrb                      \
  };
`define APB_TO_RESP(opt_as, resp_struct, apb_if) \
  opt_as resp_struct = '{                        \
    pready:  apb_if.pready,                      \
    prdata:  apb_if.prdata,                      \
    pslverr: apb_if.pslverr                      \
  };
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Setting to an interface request/response structs inside a process.
//
// Usage Example:
// always_comb begin
//   `APB_SET_TO_REQ(my_req_struct, my_if);
//   `APB_SET_TO_RESP(my_resp_struct, my_if);
// end
`define APB_SET_TO_REQ(req_struct, apb_if)   `APB_TO_REQ(, req_struct, apb_if)
`define APB_SET_TO_RESP(resp_struct, apb_if) `APB_TO_RESP(, resp_struct, apb_if)
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Assigning to an interface request/response structs outside a process.
//
// Usage Example:
// `APB_ASSIGN_TO_REQ(my_req_struct, my_if);
`define APB_ASSIGN_TO_REQ(req_struct, apb_if)   `APB_TO_REQ(assign, req_struct, apb_if)
`define APB_ASSIGN_TO_RESP(resp_struct, apb_if) `APB_TO_RESP(assign, resp_struct, apb_if)
////////////////////////////////////////////////////////////////////////////////////////////////////

`endif
