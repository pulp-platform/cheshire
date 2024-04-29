// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Luka Guzenko <lguzenko@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

/// Wrapper for the SpinalHDL USB OHCI, configured for AXI4 buses and 4 ports.
/// The config port is adapted to 32b Regbus, the DMA port to parametric AXI4.
/// The IOs are bundled into PULP structs and arrays to simplify connection.

// verilog_lint: waive package-filename
package spinal_usb_ohci_pkg;
  localparam int unsigned NumPhyPorts = 4;
endpackage

module spinal_usb_ohci import spinal_usb_ohci_pkg::*; #(
  /// DMA manager port parameters
  parameter int unsigned AxiMaxReads   = 0,
  parameter int unsigned AxiAddrWidth  = 0,
  parameter int unsigned AxiDataWidth  = 0,
  parameter int unsigned AxiIdWidth    = 0,
  parameter int unsigned AxiUserWidth  = 0,
  /// The current controller can only address a 32b address space.
  /// This parameter can statically add a domain and mask for the lower bits.
  parameter logic [AxiAddrWidth-1:0]  AxiAddrDomain = '0,
  parameter logic [AxiAddrWidth-1:0]  AxiAddrMask   = 'hFFFF_FFFF,
  /// Default User and ID presented on DMA manager AR, AW, W channels.
  /// In most systems, these can or should be left at '0.
  parameter logic [AxiIdWidth-1:0]    AxiId    = '0,
  parameter logic [AxiUserWidth-1:0]  AxiUser  = '0,
  /// SoC interface types
  parameter type reg_req_t = logic,
  parameter type reg_rsp_t = logic,
  parameter type axi_req_t = logic,
  parameter type axi_rsp_t = logic
) (
  /// SoC clock and reset
  input  logic soc_clk_i,
  input  logic soc_rst_ni,
  /// Control subordinate port
  input  reg_req_t ctrl_req_i,
  output reg_rsp_t ctrl_rsp_o,
  /// DMA manager port
  output axi_req_t dma_req_o,
  input  axi_rsp_t dma_rsp_i,
  /// Interrupt
  output logic intr_o,
  /// PHY clock and reset
  input  logic phy_clk_i,
  input  logic phy_rst_ni,
  /// PHY IO
  input  logic [NumPhyPorts-1:0] phy_dm_i,
  output logic [NumPhyPorts-1:0] phy_dm_o,
  output logic [NumPhyPorts-1:0] phy_dm_oe_o,
  input  logic [NumPhyPorts-1:0] phy_dp_i,
  output logic [NumPhyPorts-1:0] phy_dp_o,
  output logic [NumPhyPorts-1:0] phy_dp_oe_o
);

  `include "axi/typedef.svh"

  // Convert 32b-DW Regbus subordinate to controller's 32b-DW control AXI port
  `AXI_TYPEDEF_ALL(ctrl_int, logic [11:0], logic [7:0], logic [31:0], logic [3:0], logic)
  ctrl_int_req_t  ctrl_int_req;
  ctrl_int_resp_t ctrl_int_rsp;

  // The adapter implicitly truncates our address and emits ID 0
  reg_to_axi #(
    .DataWidth  ( 32 ),
    .reg_req_t  ( reg_req_t ),
    .reg_rsp_t  ( reg_rsp_t ),
    .axi_req_t  ( ctrl_int_req_t  ),
    .axi_rsp_t  ( ctrl_int_resp_t )
  ) i_reg_to_axi_ctrl (
    .clk_i      ( soc_clk_i  ),
    .rst_ni     ( soc_rst_ni ),
    .reg_req_i  ( ctrl_req_i ),
    .reg_rsp_o  ( ctrl_rsp_o ),
    .axi_req_o  ( ctrl_int_req ),
    .axi_rsp_i  ( ctrl_int_rsp )
  );

  // Forward-declare DMA manager port signals
  `AXI_TYPEDEF_ALL(dma_int, logic [31:0], logic [AxiIdWidth-1:0],
      logic [31:0], logic [3:0], logic [AxiUserWidth-1:0])
  dma_int_req_t   dma_int_req;
  dma_int_resp_t  dma_int_rsp;

  // Tie parts of DMA manager request port not connected to OHCI controller
  always_comb begin
    // AR
    dma_int_req.ar.id     = AxiId;
    dma_int_req.ar.user   = AxiUser;
    dma_int_req.ar.burst  = axi_pkg::BURST_INCR;
    dma_int_req.ar.lock   = '0;
    dma_int_req.ar.qos    = '0;
    dma_int_req.ar.region = '0;
    // AW
    dma_int_req.aw.id     = AxiId;
    dma_int_req.aw.user   = AxiUser;
    dma_int_req.aw.burst  = axi_pkg::BURST_INCR;
    dma_int_req.aw.lock   = '0;
    dma_int_req.aw.qos    = '0;
    dma_int_req.aw.region = '0;
    dma_int_req.aw.atop   = '0;
    // W
    dma_int_req.w.user    = AxiUser;
  end

  // Convert 32b DW to our AXI DW
  `AXI_TYPEDEF_ALL(dma_int_dw, logic [31:0], logic [AxiIdWidth-1:0],
      logic [AxiDataWidth-1:0], logic [AxiDataWidth/8-1:0], logic [AxiUserWidth-1:0])
  dma_int_dw_req_t   dma_int_dw_req;
  dma_int_dw_resp_t  dma_int_dw_rsp;

  axi_dw_converter #(
    .AxiMaxReads          ( AxiMaxReads ),
    .AxiSlvPortDataWidth  ( 32 ),
    .AxiMstPortDataWidth  ( AxiDataWidth ),
    .AxiAddrWidth         ( 32 ),
    .AxiIdWidth           ( AxiIdWidth ),
    .aw_chan_t            ( dma_int_aw_chan_t ),
    .ar_chan_t            ( dma_int_ar_chan_t ),
    .mst_w_chan_t         ( dma_int_dw_w_chan_t ),
    .slv_w_chan_t         ( dma_int_w_chan_t ),
    .b_chan_t             ( dma_int_b_chan_t ),
    .mst_r_chan_t         ( dma_int_dw_r_chan_t ),
    .slv_r_chan_t         ( dma_int_r_chan_t ),
    .axi_slv_req_t        ( dma_int_req_t  ),
    .axi_slv_resp_t       ( dma_int_resp_t ),
    .axi_mst_req_t        ( dma_int_dw_req_t  ),
    .axi_mst_resp_t       ( dma_int_dw_resp_t )
  ) i_axi_dw_converter_dma (
    .clk_i      ( soc_clk_i  ),
    .rst_ni     ( soc_rst_ni ),
    .slv_req_i  ( dma_int_req ),
    .slv_resp_o ( dma_int_rsp ),
    .mst_req_o  ( dma_int_dw_req ),
    .mst_resp_i ( dma_int_dw_rsp )
  );

  // Adapt 32b AW to our AXI AW
  axi_modify_address #(
    .slv_req_t  ( dma_int_dw_req_t ),
    .mst_req_t  ( axi_req_t ),
    .mst_addr_t ( logic [AxiAddrWidth-1:0] ),
    .axi_resp_t ( axi_rsp_t )
  ) i_axi_modify_address_dma (
    .slv_req_i    ( dma_int_dw_req ),
    .slv_resp_o   ( dma_int_dw_rsp ),
    // TODO: how to write to addresses exceeding 32 bit? Find solution.
    .mst_aw_addr_i( (AxiAddrDomain & ~AxiAddrMask) | (dma_int_dw_req.aw.addr & AxiAddrMask) ),
    .mst_ar_addr_i( (AxiAddrDomain & ~AxiAddrMask) | (dma_int_dw_req.ar.addr & AxiAddrMask) ),
    .mst_req_o    ( dma_req_o ),
    .mst_resp_i   ( dma_rsp_i )
  );

  // Spinal OHCI controller
  UsbOhciAxi4 i_UsbOhciAxi4 (
    .io_dma_aw_valid            ( dma_int_req.aw_valid ),
    .io_dma_aw_ready            ( dma_int_rsp.aw_ready ),
    .io_dma_aw_payload_addr     ( dma_int_req.aw.addr  ),
    .io_dma_aw_payload_len      ( dma_int_req.aw.len   ),
    .io_dma_aw_payload_size     ( dma_int_req.aw.size  ),
    .io_dma_aw_payload_cache    ( dma_int_req.aw.cache ),
    .io_dma_aw_payload_prot     ( dma_int_req.aw.prot  ),
    .io_dma_w_valid             ( dma_int_req.w_valid  ),
    .io_dma_w_ready             ( dma_int_rsp.w_ready  ),
    .io_dma_w_payload_data      ( dma_int_req.w.data   ),
    .io_dma_w_payload_strb      ( dma_int_req.w.strb   ),
    .io_dma_w_payload_last      ( dma_int_req.w.last   ),
    .io_dma_b_valid             ( dma_int_rsp.b_valid  ),
    .io_dma_b_ready             ( dma_int_req.b_ready  ),
    .io_dma_b_payload_resp      ( dma_int_rsp.b.resp   ),
    .io_dma_ar_valid            ( dma_int_req.ar_valid ),
    .io_dma_ar_ready            ( dma_int_rsp.ar_ready ),
    .io_dma_ar_payload_addr     ( dma_int_req.ar.addr  ),
    .io_dma_ar_payload_len      ( dma_int_req.ar.len   ),
    .io_dma_ar_payload_size     ( dma_int_req.ar.size  ),
    .io_dma_ar_payload_cache    ( dma_int_req.ar.cache ),
    .io_dma_ar_payload_prot     ( dma_int_req.ar.prot  ),
    .io_dma_r_valid             ( dma_int_rsp.r_valid  ),
    .io_dma_r_ready             ( dma_int_req.r_ready  ),
    .io_dma_r_payload_data      ( dma_int_rsp.r.data   ),
    .io_dma_r_payload_resp      ( dma_int_rsp.r.resp   ),
    .io_dma_r_payload_last      ( dma_int_rsp.r.last   ),
    .io_ctrl_aw_valid           ( ctrl_int_req.aw_valid  ),
    .io_ctrl_aw_ready           ( ctrl_int_rsp.aw_ready  ),
    .io_ctrl_aw_payload_addr    ( ctrl_int_req.aw.addr   ),
    .io_ctrl_aw_payload_id      ( ctrl_int_req.aw.id     ),
    .io_ctrl_aw_payload_region  ( ctrl_int_req.aw.region ),
    .io_ctrl_aw_payload_len     ( ctrl_int_req.aw.len    ),
    .io_ctrl_aw_payload_size    ( ctrl_int_req.aw.size   ),
    .io_ctrl_aw_payload_burst   ( ctrl_int_req.aw.burst  ),
    .io_ctrl_aw_payload_lock    ( ctrl_int_req.aw.lock   ),
    .io_ctrl_aw_payload_cache   ( ctrl_int_req.aw.cache  ),
    .io_ctrl_aw_payload_qos     ( ctrl_int_req.aw.qos    ),
    .io_ctrl_aw_payload_prot    ( ctrl_int_req.aw.prot   ),
    .io_ctrl_w_valid            ( ctrl_int_req.w_valid   ),
    .io_ctrl_w_ready            ( ctrl_int_rsp.w_ready   ),
    .io_ctrl_w_payload_data     ( ctrl_int_req.w.data    ),
    .io_ctrl_w_payload_strb     ( ctrl_int_req.w.strb    ),
    .io_ctrl_w_payload_last     ( ctrl_int_req.w.last    ),
    .io_ctrl_b_valid            ( ctrl_int_rsp.b_valid   ),
    .io_ctrl_b_ready            ( ctrl_int_req.b_ready   ),
    .io_ctrl_b_payload_id       ( ctrl_int_rsp.b.id      ),
    .io_ctrl_b_payload_resp     ( ctrl_int_rsp.b.resp    ),
    .io_ctrl_ar_valid           ( ctrl_int_req.ar_valid  ),
    .io_ctrl_ar_ready           ( ctrl_int_rsp.ar_ready  ),
    .io_ctrl_ar_payload_addr    ( ctrl_int_req.ar.addr   ),
    .io_ctrl_ar_payload_id      ( ctrl_int_req.ar.id     ),
    .io_ctrl_ar_payload_region  ( ctrl_int_req.ar.region ),
    .io_ctrl_ar_payload_len     ( ctrl_int_req.ar.len    ),
    .io_ctrl_ar_payload_size    ( ctrl_int_req.ar.size   ),
    .io_ctrl_ar_payload_burst   ( ctrl_int_req.ar.burst  ),
    .io_ctrl_ar_payload_lock    ( ctrl_int_req.ar.lock   ),
    .io_ctrl_ar_payload_cache   ( ctrl_int_req.ar.cache  ),
    .io_ctrl_ar_payload_qos     ( ctrl_int_req.ar.qos    ),
    .io_ctrl_ar_payload_prot    ( ctrl_int_req.ar.prot   ),
    .io_ctrl_r_valid            ( ctrl_int_rsp.r_valid   ),
    .io_ctrl_r_ready            ( ctrl_int_req.r_ready   ),
    .io_ctrl_r_payload_data     ( ctrl_int_rsp.r.data    ),
    .io_ctrl_r_payload_id       ( ctrl_int_rsp.r.id      ),
    .io_ctrl_r_payload_resp     ( ctrl_int_rsp.r.resp    ),
    .io_ctrl_r_payload_last     ( ctrl_int_rsp.r.last    ),
    .io_interrupt               ( intr_o ),
    .io_usb_0_dp_read           ( phy_dp_i    [0] ),
    .io_usb_0_dp_write          ( phy_dp_o    [0] ),
    .io_usb_0_dp_writeEnable    ( phy_dp_oe_o [0] ),
    .io_usb_0_dm_read           ( phy_dm_i    [0] ),
    .io_usb_0_dm_write          ( phy_dm_o    [0] ),
    .io_usb_0_dm_writeEnable    ( phy_dm_oe_o [0] ),
    .io_usb_1_dp_read           ( phy_dp_i    [1] ),
    .io_usb_1_dp_write          ( phy_dp_o    [1] ),
    .io_usb_1_dp_writeEnable    ( phy_dp_oe_o [1] ),
    .io_usb_1_dm_read           ( phy_dm_i    [1] ),
    .io_usb_1_dm_write          ( phy_dm_o    [1] ),
    .io_usb_1_dm_writeEnable    ( phy_dm_oe_o [1] ),
    .io_usb_2_dp_read           ( phy_dp_i    [2] ),
    .io_usb_2_dp_write          ( phy_dp_o    [2] ),
    .io_usb_2_dp_writeEnable    ( phy_dp_oe_o [2] ),
    .io_usb_2_dm_read           ( phy_dm_i    [2] ),
    .io_usb_2_dm_write          ( phy_dm_o    [2] ),
    .io_usb_2_dm_writeEnable    ( phy_dm_oe_o [2] ),
    .io_usb_3_dp_read           ( phy_dp_i    [3] ),
    .io_usb_3_dp_write          ( phy_dp_o    [3] ),
    .io_usb_3_dp_writeEnable    ( phy_dp_oe_o [3] ),
    .io_usb_3_dm_read           ( phy_dm_i    [3] ),
    .io_usb_3_dm_write          ( phy_dm_o    [3] ),
    .io_usb_3_dm_writeEnable    ( phy_dm_oe_o [3] ),
    .phy_clk                    ( phy_clk_i   ),
    .phy_reset                  ( ~phy_rst_ni ),
    .ctrl_clk                   ( soc_clk_i   ),
    .ctrl_reset                 ( ~soc_rst_ni )
  );

endmodule
