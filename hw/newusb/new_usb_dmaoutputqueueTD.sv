// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Output queue of the DMA for general transfer descriptors Stages*AxiDataWidth=128 bit buffering for isochronous 2*Stages*AxiDataWidth=256
///
/// Todo: implement ISOCHRONOUS
/// Todo: implement listservicing TDs

module new_usb_dmaoutputqueueTD import new_usb_ohci_pkg::*; (
    /// control
    input  logic clk_i,
    input  logic rst_ni,
    /// data input
    input  logic [AxiDataWidth-1:0] dma_data_i,
    input  logic                    dma_valid_i,
    output logic                    dma_ready_o,
    /// external TD access
    output logic [27:0] nextTD_address_o,
    output logic        served_td_o, // a service attempt was made
    output logic        aborted_td_o // the service was aborted before or after the attempt
    
);
    `include "common_cells/registers.svh"
    
    gen_transfer_descriptor general;
    assign nextTD_address_o = general.nextTD;
    assign served_td_o = propagate_valid; // As soon as propagated => served_td // Todo: Actually implement the serving.
    assign aborted_td_o = 0'b0; // Todo: The system needs to pre-emptively abort a TD if its data is not fitting inside the periodic, nonperiodic window 

    logic [31:0] dword0;
    logic [31:0] dword1;
    logic [31:0] dword2;
    logic [31:0] dword3;

    assign dword0 [26:16] = general.nextTD;

    // create enable, one pulse for one handshake
    logic  en;
    logic  dma_handshake;
    logic  dma_handshake_prev;
    assign dma_handshake = dma_ready && dma_valid_i;
    `FF(dma_handshake_prev, dma_handshake, 1'b0)
    assign en = dma_handshake && ~dma_handshake_prev;

    // registers
    new_usb_registerchain #(
      .Width(AxiDataWidth),
      .Stages(DmaOutputQueueStages)
    ) i_registerchain_td (
      .clk_i,
      .rst_ni, // asynchronous, active low
      .clear_i(1'b0), // never cleared only its propagation validity bit (avoids timing issues, saves power)
      .en_i(en),
      .data_i(dma_data_i),
      .register_o({dword0, dword1, dword2, dword3})
    );

    // fill propagation
    logic propagate_valid;
    logic clear_propagate;
    logic [Stages-1:0] propagate;
    assign propagate_valid = propagate[Stages-1];
    assign clear_propagate = pop_i;
    assign dma_ready = !propagate_valid;
    // Todo: Maybe replace with just transfer_done through loading without register chain
    new_usb_registerchain #(
      .Width(1),
      .Stages(DmaOutputQueueStages)
    ) i_registerchain_td_propagate (
      .clk_i,
      .rst_ni, // asynchronous, active low
      .clear_i(clear_propagate), // synchronous, active high
      .en_i(en),
      .data_i(1'b1), // propagation of ones
      .register_o(propagate)
    );

endmodule