// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Fabian Hauser <fhauser@student.ethz.ch>

/// Main module for the direct SystemVerilog NewUSB OHCI, configured for AXI4 buses.
/// The config port is adapted to 32b Regbus, the DMA port to parametric AXI4.
/// The IOs are bundled into PULP structs and arrays to simplify connection.


// Changes inside this package need to be confirmed with a make hw-all, 
// because the package values need to update the configuration inside newusb_regs.hjson.
// Always delete the previous newusb_regs.hjson first, if you do changes here.
package new_usb_ohci_pkg;
  
  typedef enum int unsigned {
    OFF = 0,
    GLOBAL = 1,
    INDIVIDUAL = 2
  } state_activate;

  typedef enum int unsigned {
    DISABLE = 0,
    ENABLE = 1
  } state_permit;

  //OHCI supports between 1-15 ports
  localparam int unsigned   NumPhyPorts      = 2;
  localparam state_activate OverProtect      = OFF; // no overcurrent protection implemented yet
  localparam state_activate PowerSwitching   = OFF; // no power switching implemented yet
  localparam state_permit   InterruptRouting = DISABLE; // no system management interrupt SMI implemented yet
  localparam state_permit   RemoteWakeup     = DISABLE; // no remote wakeup implemented yet
  localparam state_permit   OwnershipChange  = DISABLE; // no ownership change implemented yet
  localparam int unsigned   FifodepthPort    = 1024; //test value
  localparam int unsigned   FifodepthDma     = 1024; //test value
  localparam int unsigned   Dmalength        = 1024; //test value
  
  // Todo: Maybe Crc16 input Byte size parameter with selectable parallel/pipelined processing, lookup table?

endpackage

module new_usb_ohci import new_usb_ohci_pkg::*; #(
  /// DMA manager port parameters
  parameter int unsigned AxiMaxReads   = 0,
  parameter int unsigned AxiAddrWidth  = 0,
  parameter int unsigned AxiDataWidth  = 0,
  parameter int unsigned AxiIdWidth    = 0,
  parameter int unsigned AxiUserWidth  = 0,
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
) i_newusb_regs (
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

assign phy_dm_o    = '0;
assign phy_dm_oe_o = '0;
assign phy_dp_o    = '0;
assign phy_dp_oe_o = '0;

endmodule
