// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Fabian Hauser <fhauser@student.ethz.ch>

/// Main module for the direct SystemVerilog New USB OHCI, configured for AXI4 buses.
/// The config port is adapted to 32b Regbus, the DMA port to parametric AXI4.
/// The IOs are bundled into PULP structs and arrays to simplify connection.


// Changes inside this package need to be confirmed with a make hw-all, 
// because the package values need to influence the configuration inside newusb_regs.hjson.
package new_usb_ohci_pkg;
  //Supports between 1-15 ports
  localparam int unsigned NumPhyPorts = 8;
  //To Do: Overcurrent protection global/individual
  //       0: off
  //       1: global
  //       2: individual
  //To Do: Power switching protection global/individual
  //       0: off
  //       1: global
  //       2: individual
  //To Do: Fifodepth
  //To Do: Usb Dmalength
  //To Do: Beats per Dmalength
  //To Do: words per Beat
endpackage

module new_usb_ohci import new_usb_ohci_pkg::*; #(
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

newusb_reg_top #(
  .reg_req_t  ( reg_req_t ),
  .reg_rsp_t  ( reg_rsp_t )
) i_regs (
  .clk_i  ( soc_clk_i ),
  .rst_ni ( soc_rst_ni ),
  .reg_req_i ( ctrl_req_i ), //SW HCD
  .reg_rsp_o ( ctrl_rsp_o ), //SW HCD
  .reg2hw    ( /* NC */   ), //HW HC
  .hw2reg    ( '0         ), //HW HC
  .devmode_i (  1'b1      )
);

  assign dma_req_o = '0;
  // IRQ tied-off
  assign intr_o = '0;

  // assign usb_dm_o    = '0;
  // assign usb_dm_oe_o = '0;
  // assign usb_dp_o    = '0;
  // assign usb_dp_oe_o = '0;
endmodule
