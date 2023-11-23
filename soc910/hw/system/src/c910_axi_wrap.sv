// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nils Wistoff <nwistoff@iis.ee.ethz.ch>

module c910_axi_wrap #(
  parameter type axi_req_t = logic,
  parameter type axi_rsp_t = logic
)(
  input  logic        clk_i,
  input  logic        rst_ni,
  // clint
  input  logic        ipi_i,
  input  logic        time_irq_i,
  // External interrupts
  input  logic [39:0] ext_int_i,
  // JTAG
  input  logic        jtag_tck_i,
  input  logic        jtag_tdi_i,
  input  logic        jtag_tms_i,
  output logic        jtag_tdo_o,
  output logic        jtag_tdo_en_o,
  input  logic        jtag_trst_ni,
  // AXI interface
  output axi_req_t    axi_req_o,
  input  axi_rsp_t    axi_rsp_i
);

  cpu_sub_system_axi cpu_sub_system_axi_i (
    .axim_clk_en          ( '1                       ),
    .pad_biu_arready      ( axi_rsp_i.ar_ready       ),
    .pad_biu_awready      ( axi_rsp_i.aw_ready       ),
    .pad_biu_bid          ( axi_rsp_i.b.id           ),
    .pad_biu_bresp        ( axi_rsp_i.b.resp         ),
    .pad_biu_bvalid       ( axi_rsp_i.b_valid        ),
    .pad_biu_rdata        ( axi_rsp_i.r.data         ),
    .pad_biu_rid          ( axi_rsp_i.r.id           ),
    .pad_biu_rlast        ( axi_rsp_i.r.last         ),
    // .pad_biu_rresp        ( {2'b0, axi_rsp_i.r.resp} ),
    .pad_biu_rresp        ( '0 ),
    .pad_biu_rvalid       ( axi_rsp_i.r_valid        ),
    .pad_biu_wready       ( axi_rsp_i.w_ready        ),
    .pad_cpu_rst_b        ( rst_ni                   ),
    .pad_had_jtg_tclk     ( jtag_tck_i               ),
    .pad_had_jtg_tdi      ( jtag_tdi_i               ),
    .pad_had_jtg_trst_b   ( jtag_trst_ni             ),
    .pad_yy_dft_clk_rst_b ( rst_ni                   ),
    .pll_cpu_clk          ( clk_i                    ),
    .biu_pad_araddr       ( axi_req_o.ar.addr        ),
    .biu_pad_arburst      ( axi_req_o.ar.burst       ),
    .biu_pad_arcache      ( axi_req_o.ar.cache       ),
    .biu_pad_arid         ( axi_req_o.ar.id          ),
    .biu_pad_arlen        ( axi_req_o.ar.len         ),
    .biu_pad_arlock       ( axi_req_o.ar.lock        ),
    .biu_pad_arprot       ( axi_req_o.ar.prot        ),
    .biu_pad_arsize       ( axi_req_o.ar.size        ),
    .biu_pad_arvalid      ( axi_req_o.ar_valid       ),
    .biu_pad_awaddr       ( axi_req_o.aw.addr        ),
    .biu_pad_awburst      ( axi_req_o.aw.burst       ),
    .biu_pad_awcache      ( axi_req_o.aw.cache       ),
    .biu_pad_awid         ( axi_req_o.aw.id          ),
    .biu_pad_awlen        ( axi_req_o.aw.len         ),
    .biu_pad_awlock       ( axi_req_o.aw.lock        ),
    .biu_pad_awprot       ( axi_req_o.aw.prot        ),
    .biu_pad_awsize       ( axi_req_o.aw.size        ),
    .biu_pad_awvalid      ( axi_req_o.aw_valid       ),
    .biu_pad_bready       ( axi_req_o.b_ready        ),
    .biu_pad_rready       ( axi_req_o.r_ready        ),
    .biu_pad_wdata        ( axi_req_o.w.data         ),
    .biu_pad_wlast        ( axi_req_o.w.last         ),
    .biu_pad_wstrb        ( axi_req_o.w.strb         ),
    .biu_pad_wvalid       ( axi_req_o.w_valid        ),
    .had_pad_jtg_tdo      ( jtag_tdo_o               ),
    .had_pad_jtg_tdo_en   ( jtag_tdo_en_o            ),
    .xx_intc_vld          ( ext_int_i                ),
    .per_clk              ( clk_i                    ),
    .i_pad_jtg_tms        ( jtag_tms_i               ),
    .biu_pad_wid          (                          ),
    .biu_pad_lpmd_b       (                          ),
    .ipi_i                ( ipi_i                    ),
    .time_irq_i           ( time_irq_i               )
  );

  assign axi_req_o.aw.qos    = '0;
  assign axi_req_o.aw.region = '0;
  assign axi_req_o.aw.atop   = axi_pkg::CACHE_MODIFIABLE;
  assign axi_req_o.aw.user   = '0;
  assign axi_req_o.w.user    = '0;
  assign axi_req_o.ar.qos    = '0;
  assign axi_req_o.ar.region = '0;
  assign axi_req_o.ar.user   = '0;

endmodule
