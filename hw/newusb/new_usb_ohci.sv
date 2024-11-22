// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Main module for the direct SystemVerilog NewUSB OHCI, configured for AXI4 buses.
/// The config port is adapted to 32b Regbus, the DMA port to parametric AXI4.
/// The IOs are bundled into PULP structs and arrays to simplify connection.

// Changes inside this package need to be confirmed with a make hw-all, 
// because the package values need to update the configuration inside newusb_regs.hjson.
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

  typedef enum logic [1:0] {
    BULK = 2'b00,
    CONTROL = 2'b01,
    ISOCHRONOUS = 2'b10,
    INTERRUPT = 2'11
  } channel;

  typedef enum logic [1:0] {
    ED = 2'b00,
    GENTD = 2'b01,
    ISOTD = 2'b10
  } store_type;
  
  // OHCI supports between 1-15 ports
  localparam int unsigned   NumPhyPorts          = 2;
  localparam state_activate OverProtect          = OFF; // no overcurrent protection implemented yet
  localparam state_activate PowerSwitching       = OFF; // no power switching implemented yet
  localparam state_permit   InterruptRouting     = DISABLE; // no system management interrupt (SMI) implemented yet
  localparam state_permit   RemoteWakeup         = DISABLE; // no remote wakeup implemented yet
  localparam state_permit   OwnershipChange      = DISABLE; // no ownership change implemented yet
  localparam int unsigned   FifoDepthPort        = 1024; // test value
  localparam int unsigned   DmaLength            = 128; // test value
  
  // Todo: Maybe Crc16 input Byte size parameter with selectable parallel/pipelined processing, lookup table?

endpackage

module new_usb_ohci import new_usb_ohci_pkg::*; #(
  /// DMA manager port parameters
  parameter int unsigned AxiMaxReads   = 0,
  parameter int unsigned AxiAddrWidth  = 0,
  parameter int unsigned AxiDataWidth  = 0, // 32|64|128 causes 4|2|1 stages in the dmaoutputqueueED
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

  newusb_reg_pkg::newusb_hw2reg_t newusb_hw2reg;
  newusb_reg_pkg::newusb_reg2hw_t newusb_reg2hw;
  
  newusb_reg_top #(
    .reg_req_t  ( reg_req_t ),
    .reg_rsp_t  ( reg_rsp_t )
  ) i_newusb_regs (
    .clk_i  ( soc_clk_i ),
    .rst_ni ( soc_rst_ni ),
    .reg_req_i ( ctrl_req_i ), // SW HCD
    .reg_rsp_o ( ctrl_rsp_o ), // SW HCD
    .reg2hw    ( newusb_reg2hw ), // HW HC to Reg
    .hw2reg    ( newusb_hw2reg ), // HW Reg to HC
    .devmode_i ( 1'b1       )
  );
  
  // frame periodic/nonperiodic and its transition pulses
  logic frame_periodic; // 0 if nonperiodic 1 if periodic
  logic frame_periodic_prev;
  logic context_switch_np2p;
  logic context_switch_p2np;
  `FF(frame_periodic_prev, frame_periodic, 1'b0)
  assign context_switch_np2p = frame_periodic && ~frame_periodic_prev; // one cycle high nonperiodic to periodic
  assign context_switch_n2np = ~frame_periodic && frame_periodic_prev; // one cyble high periodic to nonperiodic

  // listservice
  logic               start; // start if USB goes to operational
  logic               counter_is_threshold;
  logic               nextis_valid;
  logic               nextis_ed;
  channel             nextis_type;
  logic [27:0]        nextis_address;
  logic               nextis_ready;
  endpoint_descriptor processed;
  logic               processed_ed_store;
  store_type          processed_store_type;
  logic [27:0]        newcurrentED_o,
  logic               newcurrentED_valid_o,
  logic               id_valid;
  logic [2:0]         id_type;
  logic               sent_head;

  new_usb_listservice i_listservice (
    /// control
    .clk_i(soc_clk_i),
    .rst_ni(soc_rst_ni),
    .start_i(start),
    .frame_periodic_i(frame_periodic),
    .counter_is_threshold_i(counter_is_threshold),
    /// next ED or TD and one of the four channel types
    .nextis_valid_i(nextis_valid),
    .nextis_ed_i(nextis_ed),
    .nextis_type_i(nextis_type),
    .nextis_address_i(nextis_address),
    .nextis_ready_o(nextis_ready),
    /// processed
    .processed,
    .processed_ed_store_i(processed_ed_store), // store request
    .processed_store_type_i(processed_store_type), // isochronousTD, generalTD, ED 
    /// newcurrentED
    .newcurrentED_i(newcurrentED),
    .newcurrentED_valid_i(newcurrentED_valid),
    /// ID
    .id_valid_o(id_valid),
    .id_type_o(id_type),
    /// registers
    .controlbulkratio_q(reg2hw.hccontrol.cbsr.q),
    .periodcurrent_ed_de_o(newusb_hw2reg.hcperiodcurrented.pced.de),
    .periodcurrent_ed_d_o(newusb_hw2reg.hcperiodcurrented.pced.d),
    .periodcurrent_ed_q_i(newusb_reg2hw.hcperiodcurrented.pced.q),
    .controlcurrent_ed_de_o(newusb_hw2reg.hccontrolcurrented.cced.de),
    .controlcurrent_ed_d_o(newusb_hw2reg.hccontrolcurrented.cced.d),
    .controlcurrent_ed_q_i(newusb_reg2hw.hccontrolcurrented.cced.q),
    .bulkcurrent_ed_de_o(newusb_hw2reg.hcbulkcurrented.bced.de),
    .bulkcurrent_ed_d_o(newusb_hw2reg.hcbulkcurrented.bced.d),
    .bulkcurrent_ed_q_i(newusb_reg2hw.hcbulkcurrented.bced.q),
    .hcbulkhead_ed_de_o(newusb_hw2reg.hcbulkheaded.bhed.de),
    .hcbulkhead_ed_d_o(newusb_hw2reg.hcbulkheaded.bhed.d) ,
    .hcbulkhead_ed_q_i(newusb_reg2hw.hcbulkheaded.bhed.q),
    .controlhead_ed_de_o(newusb_hw2reg.hccontrolheaded.ched.de),
    .controlhead_ed_d_o(newusb_hw2reg.hccontrolheaded.ched.d) ,
    .controlhead_ed_q_i(newusb_reg2hw.hccontrolheaded.ched.q),
    /// send
    .nextreadwriteaddress_o(),
    .validdmaaccess_o(),
    .current_type_o(),
    .sent_head_o(sent_head)
  );

  new_usb_unpackdescriptors #(
    .AxiDataWidth(AxiDataWidth)
    ) i_new_usb_unpackdescriptors (
    /// control
    .clk_i(soc_clk_i),
    .rst_ni(soc_rst_ni),
    .counter_is_threshold_o(counter_is_threshold),
    .cbsr_i(reg2hw.hccontrol.cbsr.q),
    /// nextis
    .nextis_valid_o(nextis_valid) // needs to be one clock cycle
    .nextis_ed_o(nextis_ed), // 0 if empty ed rerequest or td
    .nextis_type_o(nextis_type),
    .nextis_address_o(nextis_address),
    .nextis_ready_i(nextis_ready),
    /// processed
    .processed,
    .processed_ed_store_o(processed_ed_store), // store request
    .processed_store_type_o(processed_store_type), // isochronousTD, generalTD, ED 
    /// newcurrentED
    .newcurrentED_o(newcurrentED),
    .newcurrentED_valid_o(newcurrentED_valid),
    /// ID
    .id_valid_i(id_valid),
    .id_type_i(id_type),
    /// DMA
    .dma_data_i(),
    .dma_valid_i(),
    .dma_ready_o(),
    /// periodic
    .context_switch_np2p_i,
    .context_switch_p2np_i,
    /// head state
    .sent_head_i(sent_head)
);
  


  // Todo: insert DMA

  assign dma_req_o = '0;
  // IRQ tied-off
  assign intr_o = '0;
  
  assign phy_dm_o    = '0;
  assign phy_dm_oe_o = '0;
  assign phy_dp_o    = '0;
  assign phy_dp_oe_o = '0;

endmodule
