// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// AXI memory for Verilator simulation. AXI is converted to separate read and write memory ports
// to avoid R/W serialization, and the storage itself is a sparse memory in the C++ harness,
// accessed through DPI. This keeps the model small, fast, and directly preloadable from C++.
//
// The memory only accepts an AW together with its first W beat. Masters that cannot provide W
// before their AW is accepted (e.g. a serial link delivering channels in order) need a FIFO
// decoupling the channels, enabled with `FifoDepth > 0`.

module cheshire_vlt_axi_mem #(
  /// Memory ID passed to the C++ harness to select a storage instance.
  parameter int unsigned MemId      = 0,
  parameter int unsigned AddrWidth  = 0,
  parameter int unsigned DataWidth  = 0,
  parameter int unsigned IdWidth    = 0,
  /// Depth of an optional input FIFO on all channels (0: no FIFO)
  parameter int unsigned FifoDepth  = 0,
  parameter type         aw_chan_t  = logic,
  parameter type         w_chan_t   = logic,
  parameter type         b_chan_t   = logic,
  parameter type         ar_chan_t  = logic,
  parameter type         r_chan_t   = logic,
  parameter type         axi_req_t  = logic,
  parameter type         axi_rsp_t  = logic
) (
  input  logic      clk_i,
  input  logic      rst_ni,
  input  axi_req_t  axi_req_i,
  output axi_rsp_t  axi_rsp_o
);

  import "DPI-C" function longint unsigned chs_vlt_mem_read(
    input int unsigned mem_id, input longint unsigned addr);
  import "DPI-C" function void chs_vlt_mem_write(
    input int unsigned mem_id, input longint unsigned addr,
    input longint unsigned data, input byte unsigned strb);

  if (DataWidth != 64) begin : gen_dw_check
    $fatal(1, "cheshire_vlt_axi_mem only supports a data width of 64 bits.");
  end

  typedef logic [AddrWidth-1:0]   addr_t;
  typedef logic [DataWidth-1:0]   data_t;
  typedef logic [DataWidth/8-1:0] strb_t;

  axi_req_t axi_req;
  axi_rsp_t axi_rsp;

  if (FifoDepth > 0) begin : gen_fifo
    axi_fifo #(
      .Depth      ( FifoDepth ),
      .FallThrough( 1'b0 ),
      .aw_chan_t  ( aw_chan_t ),
      .w_chan_t   ( w_chan_t  ),
      .b_chan_t   ( b_chan_t  ),
      .ar_chan_t  ( ar_chan_t ),
      .r_chan_t   ( r_chan_t  ),
      .axi_req_t  ( axi_req_t ),
      .axi_resp_t ( axi_rsp_t )
    ) i_axi_fifo (
      .clk_i,
      .rst_ni,
      .test_i     ( 1'b0 ),
      .slv_req_i  ( axi_req_i ),
      .slv_resp_o ( axi_rsp_o ),
      .mst_req_o  ( axi_req   ),
      .mst_resp_i ( axi_rsp   )
    );
  end else begin : gen_no_fifo
    assign axi_req   = axi_req_i;
    assign axi_rsp_o = axi_rsp;
  end

  // Port 0 handles reads, port 1 handles writes.
  logic  [1:0] mem_req;
  addr_t [1:0] mem_addr;
  data_t [1:0] mem_wdata;
  strb_t [1:0] mem_strb;
  logic  [1:0] mem_we;
  logic  [1:0] mem_rvalid;
  data_t [1:0] mem_rdata;

  axi_to_mem_split #(
    .axi_req_t    ( axi_req_t ),
    .axi_resp_t   ( axi_rsp_t ),
    .AddrWidth    ( AddrWidth ),
    .AxiDataWidth ( DataWidth ),
    .IdWidth      ( IdWidth   ),
    .MemDataWidth ( DataWidth ),
    .BufDepth     ( 1 ),
    .HideStrb     ( 1'b0 ),
    .OutFifoDepth ( 1 )
  ) i_axi_to_mem_split (
    .clk_i,
    .rst_ni,
    .test_i       ( 1'b0 ),
    .busy_o       ( ),
    .axi_req_i    ( axi_req ),
    .axi_resp_o   ( axi_rsp ),
    .mem_req_o    ( mem_req   ),
    .mem_gnt_i    ( 2'b11     ),
    .mem_addr_o   ( mem_addr  ),
    .mem_wdata_o  ( mem_wdata ),
    .mem_strb_o   ( mem_strb  ),
    .mem_atop_o   ( ),
    .mem_we_o     ( mem_we    ),
    .mem_rvalid_i ( mem_rvalid ),
    .mem_rdata_i  ( mem_rdata  )
  );

  // Every request is answered in the following cycle.
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      mem_rvalid <= '0;
      mem_rdata  <= '0;
    end else begin
      mem_rvalid <= mem_req;
      if (mem_req[0])
        mem_rdata[0] <= chs_vlt_mem_read(MemId, 64'(mem_addr[0]));
      if (mem_req[1] && mem_we[1])
        chs_vlt_mem_write(MemId, 64'(mem_addr[1]), 64'(mem_wdata[1]), 8'(mem_strb[1]));
    end
  end

endmodule
