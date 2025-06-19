// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Authors:
// - Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

module axi_fifo_delay_dyn #(
  // AXI channel types
  parameter type  aw_chan_t = logic,
  parameter type   w_chan_t = logic,
  parameter type   b_chan_t = logic,
  parameter type  ar_chan_t = logic,
  parameter type   r_chan_t = logic,
  // AXI request & response types
  parameter type  axi_req_t = logic,
  parameter type axi_resp_t = logic,
  // delay parameters
  parameter int unsigned DepthAR  = 4,    // Power of two
  parameter int unsigned DepthAW  = 4,    // Power of two
  parameter int unsigned DepthR   = 4,    // Power of two
  parameter int unsigned DepthW   = 4,    // Power of two
  parameter int unsigned DepthB   = 4,     // Power of two
  parameter int unsigned MaxDelay = 1024,
  // DO NOT EDIT, derived parameters
  localparam int unsigned DelayWidth = $clog2(MaxDelay) + 1
) (
  input  logic                  clk_i,      // Clock
  input  logic                  rst_ni,     // Asynchronous reset active low
  input  logic [DelayWidth-1:0] aw_delay_i,
  input  logic [DelayWidth-1:0] w_delay_i,
  input  logic [DelayWidth-1:0] b_delay_i,
  input  logic [DelayWidth-1:0] ar_delay_i,
  input  logic [DelayWidth-1:0] r_delay_i,
  // slave port
  input  axi_req_t              slv_req_i,
  output axi_resp_t             slv_resp_o,
  // master port
  output axi_req_t              mst_req_o,
  input  axi_resp_t             mst_resp_i
);

  if (DepthAR > 0) begin
    stream_fifo_delay_dyn #(
      .payload_t ( ar_chan_t ),
      .MaxDelay  ( MaxDelay  ),
      .Depth     ( DepthAR   )
    ) i_ar_fifo_delay (
      .clk_i     ( clk_i               ),
      .rst_ni    ( rst_ni              ),
      .delay_i   ( ar_delay_i          ),
      .payload_i ( slv_req_i.ar        ),
      .ready_o   ( slv_resp_o.ar_ready ),
      .valid_i   ( slv_req_i.ar_valid  ),
      .payload_o ( mst_req_o.ar        ),
      .ready_i   ( mst_resp_i.ar_ready ),
      .valid_o   ( mst_req_o.ar_valid  )
    );
  end else begin
    // AR channel pass-through
    assign mst_req_o.ar        = slv_req_i.ar;
    assign mst_req_o.ar_valid  = slv_req_i.ar_valid;
    assign slv_resp_o.ar_ready = mst_resp_i.ar_ready;
  end

  if (DepthAW > 0) begin
    stream_fifo_delay_dyn #(
      .payload_t ( aw_chan_t ),
      .MaxDelay  ( MaxDelay  ),
      .Depth     ( DepthAW   )
    ) i_aw_fifo_delay (
      .clk_i     ( clk_i               ),
      .rst_ni    ( rst_ni              ),
      .delay_i   ( aw_delay_i          ),
      .payload_i ( slv_req_i.aw        ),
      .ready_o   ( slv_resp_o.aw_ready ),
      .valid_i   ( slv_req_i.aw_valid  ),
      .payload_o ( mst_req_o.aw        ),
      .ready_i   ( mst_resp_i.aw_ready ),
      .valid_o   ( mst_req_o.aw_valid  )
    );
  end else begin
    // AW channel pass-through
    assign mst_req_o.aw        = slv_req_i.aw;
    assign mst_req_o.aw_valid  = slv_req_i.aw_valid;
    assign slv_resp_o.aw_ready = mst_resp_i.aw_ready;
  end

  if (DepthR > 0) begin
    stream_fifo_delay_dyn #(
      .payload_t ( r_chan_t ),
      .MaxDelay  ( MaxDelay ),
      .Depth     ( DepthR   )
    ) i_r_fifo_delay (
      .clk_i     ( clk_i              ),
      .rst_ni    ( rst_ni             ),
      .delay_i   ( r_delay_i          ),
      .payload_i ( mst_resp_i.r       ),
      .ready_o   ( mst_req_o.r_ready  ),
      .valid_i   ( mst_resp_i.r_valid ),
      .payload_o ( slv_resp_o.r       ),
      .ready_i   ( slv_req_i.r_ready  ),
      .valid_o   ( slv_resp_o.r_valid )
    );
  end else begin
    // R channel pass-through
    assign mst_req_o.r_ready  = slv_req_i.r_ready;
    assign slv_resp_o.r_valid = mst_resp_i.r_valid;
    assign slv_resp_o.r       = mst_resp_i.r;
  end

  if (DepthW > 0) begin
    stream_fifo_delay_dyn #(
      .payload_t ( w_chan_t ),
      .MaxDelay  ( MaxDelay ),
      .Depth     ( DepthW   )
    ) i_w_fifo_delay (
      .clk_i     ( clk_i              ),
      .rst_ni    ( rst_ni             ),
      .delay_i   ( w_delay_i          ),
      .payload_i ( slv_req_i.w        ),
      .ready_o   ( slv_resp_o.w_ready ),
      .valid_i   ( slv_req_i.w_valid  ),
      .payload_o ( mst_req_o.w        ),
      .ready_i   ( mst_resp_i.w_ready ),
      .valid_o   ( mst_req_o.w_valid  )
    );
  end else begin
    // W channel pass-through
    assign mst_req_o.w         = slv_req_i.w;
    assign mst_req_o.w_valid   = slv_req_i.w_valid;
    assign slv_resp_o.w_ready  = mst_resp_i.w_ready;
  end

  if (DepthB > 0) begin
    stream_fifo_delay_dyn #(
      .payload_t ( b_chan_t ),
      .MaxDelay  ( MaxDelay ),
      .Depth     ( DepthB   )
    ) i_b_fifo_delay (
      .clk_i     ( clk_i              ),
      .rst_ni    ( rst_ni             ),
      .delay_i   ( b_delay_i          ),
      .payload_i ( mst_resp_i.b       ),
      .ready_o   ( mst_req_o.b_ready  ),
      .valid_i   ( mst_resp_i.b_valid ),
      .payload_o ( slv_resp_o.b       ),
      .ready_i   ( slv_req_i.b_ready  ),
      .valid_o   ( slv_resp_o.b_valid )
    );
  end else begin
    // B channel pass-through
    assign mst_req_o.b_ready   = slv_req_i.b_ready;
    assign slv_resp_o.b        = mst_resp_i.b;
    assign slv_resp_o.b_valid  = mst_resp_i.b_valid;
  end


endmodule

`include "axi/typedef.svh"
`include "axi/assign.svh"

// interface wrapper
module axi_fifo_delay_dyn_intf #(
  // Synopsys DC requires a default value for parameters.
  parameter int unsigned AXI_ID_WIDTH        = 0,
  parameter int unsigned AXI_ADDR_WIDTH      = 0,
  parameter int unsigned AXI_DATA_WIDTH      = 0,
  parameter int unsigned AXI_USER_WIDTH      = 0,
  parameter int unsigned DEPTH_AR            = 4, // Power of two
  parameter int unsigned DEPTH_AW            = 4, // Power of two
  parameter int unsigned DEPTH_R             = 4, // Power of two
  parameter int unsigned DEPTH_W             = 4, // Power of two
  parameter int unsigned DEPTH_B             = 4, // Power of two
  parameter int unsigned MAX_DELAY           = 0,
  // DO NOT EDIT, derived parameters
  parameter int unsigned DELAY_WIDTH         = $clog2(MAX_DELAY) + 1
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic [MAX_DELAY-1:0] aw_delay_i,
  input  logic [MAX_DELAY-1:0] w_delay_i,
  input  logic [MAX_DELAY-1:0] b_delay_i,
  input  logic [MAX_DELAY-1:0] ar_delay_i,
  input  logic [MAX_DELAY-1:0] r_delay_i,
  AXI_BUS.Slave                slv,
  AXI_BUS.Master               mst
);

  typedef logic [AXI_ID_WIDTH-1:0]     id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0]   addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0]   data_t;
  typedef logic [AXI_DATA_WIDTH/8-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0]   user_t;

  `AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)
  `AXI_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)

  axi_req_t  slv_req,  mst_req;
  axi_resp_t slv_resp, mst_resp;

  `AXI_ASSIGN_TO_REQ(slv_req, slv)
  `AXI_ASSIGN_FROM_RESP(slv, slv_resp)

  `AXI_ASSIGN_FROM_REQ(mst, mst_req)
  `AXI_ASSIGN_TO_RESP(mst_resp, mst)

  axi_fifo_delay #(
    .aw_chan_t  (  aw_chan_t ),
    .w_chan_t   (   w_chan_t ),
    .b_chan_t   (   b_chan_t ),
    .ar_chan_t  (  ar_chan_t ),
    .r_chan_t   (   r_chan_t ),
    .axi_req_t  (  axi_req_t ),
    .axi_resp_t ( axi_resp_t ),
    .DepthAR    (   DEPTH_AR ),
    .DepthAW    (   DEPTH_AW ),
    .DepthR     (    DEPTH_R ),
    .DepthW     (    DEPTH_W ),
    .DepthB     (    DEPTH_B ),
    .MaxDelay   (  MAX_DELAY )
  ) i_axi_delayer (
    .clk_i,   // Clock
    .rst_ni,  // Asynchronous reset active low
    .aw_delay_i ( aw_delay_i ),
    .w_delay_i  ( w_delay_i  ),
    .b_delay_i  ( b_delay_i  ),
    .ar_delay_i ( ar_delay_i ),
    .r_delay_i  ( r_delay_i  ),
    .slv_req_i  ( slv_req    ),
    .slv_resp_o ( slv_resp   ),
    .mst_req_o  ( mst_req    ),
    .mst_resp_i ( mst_resp   )
  );

// pragma translate_off
`ifndef VERILATOR
  initial begin: p_assertions
    assert (AXI_ID_WIDTH >= 1) else $fatal(1, "AXI ID width must be at least 1!");
    assert (AXI_ADDR_WIDTH >= 1) else $fatal(1, "AXI ADDR width must be at least 1!");
    assert (AXI_DATA_WIDTH >= 1) else $fatal(1, "AXI DATA width must be at least 1!");
    assert (AXI_USER_WIDTH >= 1) else $fatal(1, "AXI USER width must be at least 1!");
  end
`endif
// pragma translate_on
endmodule
