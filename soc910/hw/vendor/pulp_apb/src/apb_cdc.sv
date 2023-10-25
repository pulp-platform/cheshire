// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// APB Clock Domain Crossing
// Author: Manuel Eggimann <meggimann@iis.ee.ethz.ch>
// Description: A clock domain crossing module on an APB interface. The module uses gray-counting
// CDC FIFOS in both directions to synchronize source side with destination side.
// Parameters:
// - `LogDepth`:     The FIFO crossing the clock domain has `2^LogDepth` entries
// - `req_t`:        APB4 request struct. See macro definition in `include/typedef.svh`
// - `resp_t`:       APB4 response struct. See macro definition in `include/typedef.svh`
//
// Ports:
//
// - `src_pclk_i:    Source side clock input signal (1-bit).
// - `src_preset_ni: Source side asynchronous active low reset signal (1-bit).
// - `src_req_i:     Source side APB4 request struct, bundles all APB4 signals from the master (req_t).
// - `src_resp_o:    Source side APB4 response struct, bundles all APB4 signals to the master (resp_t).
// - `dst_pclk_i:    Destination side clock input signal (1-bit).
// - `dst_preset_ni: Destination side asynchronous active low reset signal (1-bit).
// - `dst_req_o:     Destination side APB4 request struct, bundles all APB4 signals to the slave (req_t).
// - `dst_resp_i:    Destination side APB4 response struct, bundles all APB4 signals from the slave (resp_t).
//
// This file also features the module `apb_cdc_intf`. The difference is that instead of the
// request and response structs it uses a `APB` interfaces. The parameters have the same
// function, however are defined in `ALL_CAPS`.

(* no_ungroup *)
(* no_boundary_optimization *)
module apb_cdc #(
  parameter LogDepth = 1,
  parameter type req_t = logic,
  parameter type resp_t = logic,
  parameter type addr_t = logic,
  parameter type data_t = logic,
  parameter type strb_t = logic
) (
   // synchronous slave port - clocked by `src_pclk_i`
  input logic                    src_pclk_i,
  input logic                    src_preset_ni,
  input req_t                    src_req_i,
  output resp_t                  src_resp_o,
  // synchronous master port - clocked by `dst_pclk_i`
  input logic                    dst_pclk_i,
  input logic                    dst_preset_ni,
  output req_t                   dst_req_o,
  input resp_t                   dst_resp_i
);

  typedef struct packed {
    addr_t          paddr;
    apb_pkg::prot_t pprot;
    logic           pwrite;
    data_t          pwdata;
    strb_t          pstrb;
  } apb_async_req_data_t;

  typedef struct packed {
    data_t        prdata;
    logic        pslverr;
  } apb_async_resp_data_t;

  typedef enum logic {Src_Idle, Src_Busy} src_fsm_state_e;
  typedef enum logic[1:0] {Dst_Idle, Dst_Access, Dst_Busy} dst_fsm_state_e;
  src_fsm_state_e src_state_d, src_state_q;
  dst_fsm_state_e dst_state_d, dst_state_q;
  logic        src_req_valid, src_req_ready, src_resp_valid, src_resp_ready;
  logic        dst_req_valid, dst_req_ready, dst_resp_valid, dst_resp_ready;

  apb_async_req_data_t src_req_data, dst_req_data;

  apb_async_resp_data_t dst_resp_data_d, dst_resp_data_q, src_resp_data;

  assign src_req_data.paddr  = src_req_i.paddr;
  assign src_req_data.pprot  = src_req_i.pprot;
  assign src_req_data.pwrite = src_req_i.pwrite;
  assign src_req_data.pwdata = src_req_i.pwdata;
  assign src_req_data.pstrb  = src_req_i.pstrb;

  assign dst_req_o.paddr  = dst_req_data.paddr;
  assign dst_req_o.pprot  = dst_req_data.pprot;
  assign dst_req_o.pwrite = dst_req_data.pwrite;
  assign dst_req_o.pwdata = dst_req_data.pwdata;
  assign dst_req_o.pstrb  = dst_req_data.pstrb;

  assign src_resp_o.prdata  = src_resp_data.prdata;
  assign src_resp_o.pslverr = src_resp_data.pslverr;

  //////////////////////////
  // SRC DOMAIN HANDSHAKE //
  //////////////////////////

  // In the source domain we translate simultaneous assertion of psel and penable into a transaction
  // on the CDC. The FSM then transitions into a busy state where it waits for a response comming
  // back on the other CDC FIFO. Once this response appears the pready signal is asserted to finish
  // the APB transaction.

  always_comb begin
    src_state_d       = src_state_q;
    src_req_valid     = 1'b0;
    src_resp_ready    = 1'b0;
    src_resp_o.pready = 1'b0;
    case (src_state_q)
      Src_Idle: begin
        if (src_req_i.psel & src_req_i.penable) begin
          src_req_valid = 1'b1;
          if (src_req_ready) src_state_d = Src_Busy;
        end
      end
      Src_Busy: begin
        src_resp_ready = 1'b1;
        if (src_resp_valid) begin
          src_resp_o.pready = 1'b1;
          src_state_d = Src_Idle;
        end
      end
      default:;
    endcase
  end

  always_ff @(posedge src_pclk_i, negedge src_preset_ni) begin
    if (!src_preset_ni)
      src_state_q <= Src_Idle;
    else
      src_state_q <= src_state_d;
  end


  //////////////////////////
  // DST DOMAIN HANDSHAKE //
  //////////////////////////

  // In the destination domain we need to perform a proper APB handshake with setup and access
  // phase. Once the destination slave asserts the pready signal we store the response data and
  // transition into a busy state. In the busy state we send the response data back to the src
  // domain and wait for the transaction to complete.

  always_comb begin
    dst_state_d       = dst_state_q;
    dst_req_ready     = 1'b0;
    dst_resp_valid    = 1'b0;
    dst_req_o.psel    = 1'b0;
    dst_req_o.penable = 1'b0;
    dst_resp_data_d   = dst_resp_data_q;
    case (dst_state_q)
      Dst_Idle: begin
        if (dst_req_valid) begin
          dst_req_o.psel = 1'b1;
          dst_state_d = Dst_Access;
        end
      end

      Dst_Access: begin
        dst_req_o.psel    = 1'b1;
        dst_req_o.penable = 1'b1;
        if (dst_resp_i.pready) begin
          dst_req_ready           = 1'b1;
          dst_resp_data_d.prdata  = dst_resp_i.prdata;
          dst_resp_data_d.pslverr = dst_resp_i.pslverr;
          dst_state_d             = Dst_Busy;
        end
      end

      Dst_Busy: begin
        dst_resp_valid = 1'b1;
        if (dst_resp_ready) begin
          dst_state_d = Dst_Idle;
        end
      end

      default: begin
        dst_state_d = Dst_Idle;
      end
    endcase
  end

  always_ff @(posedge dst_pclk_i, negedge dst_preset_ni) begin
    if (!dst_preset_ni) begin
      dst_state_q     <= Dst_Idle;
      dst_resp_data_q <= '0;
    end else begin
      dst_state_q     <= dst_state_d;
      dst_resp_data_q <= dst_resp_data_d;
    end
  end


  ///////////////
  // CDC FIFOS //
  ///////////////

  cdc_fifo_gray #(
    .T         ( apb_async_req_data_t ),
    .LOG_DEPTH (  LogDepth            )
  ) i_cdc_fifo_gray_req (
   .src_clk_i   ( src_pclk_i    ),
   .src_rst_ni  ( src_preset_ni ),
   .src_data_i  ( src_req_data  ),
   .src_valid_i ( src_req_valid ),
   .src_ready_o ( src_req_ready ),

   .dst_clk_i   ( dst_pclk_i    ),
   .dst_rst_ni  ( dst_preset_ni ),
   .dst_data_o  ( dst_req_data  ),
   .dst_valid_o ( dst_req_valid ),
   .dst_ready_i ( dst_req_ready )
  );

  cdc_fifo_gray #(
    .T         ( apb_async_resp_data_t ),
    .LOG_DEPTH (  LogDepth             )
  ) i_cdc_fifo_gray_resp (
   .src_clk_i   ( dst_pclk_i      ),
   .src_rst_ni  ( dst_preset_ni   ),
   .src_data_i  ( dst_resp_data_q ),
   .src_valid_i ( dst_resp_valid  ),
   .src_ready_o ( dst_resp_ready  ),

   .dst_clk_i   ( src_pclk_i      ),
   .dst_rst_ni  ( src_preset_ni   ),
   .dst_data_o  ( src_resp_data   ),
   .dst_valid_o ( src_resp_valid  ),
   .dst_ready_i ( src_resp_ready  )
  );

endmodule // apb_cdc


`include "apb/typedef.svh"
`include "apb/assign.svh"

module apb_cdc_intf #(
  parameter int unsigned APB_ADDR_WIDTH = 0,
  parameter int unsigned APB_DATA_WIDTH = 0,
  /// Depth of the FIFO crossing the clock domain, given as 2**LOG_DEPTH.
  parameter int unsigned LOG_DEPTH = 1
)(
  input logic src_pclk_i,
  input logic src_preset_ni,
  APB.Slave   src,
  input logic dst_pclk_i,
  input logic dst_preset_ni,
  APB.Master  dst
);

  typedef logic [APB_ADDR_WIDTH-1:0] addr_t;
  typedef logic [APB_DATA_WIDTH-1:0] data_t;
  typedef logic [APB_DATA_WIDTH/8-1:0] strb_t;

  `APB_TYPEDEF_REQ_T(apb_req_t, addr_t, data_t, strb_t)
  `APB_TYPEDEF_RESP_T(apb_resp_t, data_t)

  apb_req_t src_req, dst_req;
  apb_resp_t dst_resp, src_resp;

  `APB_ASSIGN_TO_REQ(src_req, src)
  `APB_ASSIGN_FROM_REQ(dst, dst_req)
  `APB_ASSIGN_FROM_RESP(src, src_resp)
  `APB_ASSIGN_TO_RESP(dst_resp, dst)

  apb_cdc #(
   .LogDepth ( LOG_DEPTH  ),
   .req_t    ( apb_req_t  ),
   .resp_t   ( apb_resp_t ),
   .addr_t   ( addr_t     ),
   .data_t   ( data_t     ),
   .strb_t   ( strb_t     )
 ) i_apb_cdc (
   .src_pclk_i,
   .src_preset_ni,
   .src_req_i  ( src_req  ),
   .src_resp_o ( src_resp ),
   .dst_pclk_i,
   .dst_preset_ni,
   .dst_req_o  ( dst_req  ),
   .dst_resp_i ( dst_resp )
  );
endmodule
