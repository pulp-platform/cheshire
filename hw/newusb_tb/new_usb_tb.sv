// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Testbench module for the direct SystemVerilog NewUSB OHCI.
/// The config port from new_usb_ohci is adapted to 32b Regbus, the DMA port to parametric AXI4.
/// The regbus is attached to a regbus driver to simulate the CPU.
/// The AXI4 is attached to the testbench memory axi_sim_mem, which loads test.mem.

module new_usb_tb import new_usb_ohci_pkg::*; #(
  /// parameters
) (
  /// SoC clock and reset
  // input  logic soc_clk_i,
  // input  logic soc_rst_ni,
);

initial begin
  $readmemh("new_usb_tb_mem.mem", i_axi_sim_mem.mem);
end

new_usb_ohci #(
  /// DMA manager port parameters
  .AxiMaxReads(),
  .AxiAddrWidth(),
  .AxiDataWidth(), // 32|64|128 causes 4|2|1 stages in the dmaoutputqueueED
  .AxiIdWidth(),
  .AxiUserWidth(),
  /// Default User and ID presented on DMA manager AR, AW, W channels.
  /// In most systems, these can or should be left at '0.
  .AxiId(),
  .AxiUser(),
  /// SoC interface types
  .reg_req_t(),
  .reg_rsp_t(),
  .axi_req_t(),
  .axi_rsp_t()
) i_new_usb_ohci (
  /// SoC clock and reset
  .soc_clk_i(),
  .soc_rst_ni(),
  /// Control subordinate port
  .ctrl_req_i(),
  .ctrl_rsp_o(),
  /// DMA manager port
  .dma_req_o(),
  .dma_rsp_i(),
  /// Interrupt
  .intr_o(),
  /// PHY clock and reset
  .phy_clk_i(),
  .phy_rst_ni(),
  /// PHY IO
  .phy_dm_i(),
  .phy_dm_o(),
  .phy_dm_oe_o(),
  .phy_dp_i(),
  .phy_dp_o(),
  .phy_dp_oe_o()
);

axi_sim_mem #(

) i_axi_sim_mem (

);
  
//Todo:regbusdriver


endmodule