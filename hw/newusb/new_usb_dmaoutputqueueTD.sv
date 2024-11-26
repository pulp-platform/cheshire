// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Output queue of the DMA for general transfer descriptors 4x32 bit buffering for isochronous 8x32 
/// Todo: implement ISOCHRONOUS
/// Todo: implement listservicing TDs

module new_usb_dmaoutputqueueTD import new_usb_ohci_pkg::*; (
    /// control
    input  logic clk_i,
    input  logic rst_ni,
    /// data input
    input  logic [31:0] dma_data_i,
    input  logic        dma_valid_i,
    output logic        dma_ready_o,
    /// external TD access
    output logic [27:0] nextTD_address_o,
    output logic        served_td_o
);
    gen_transfer_descriptor general;
    assign nextTD_address_o = general.nextTD;
    assign served_td_o = propagate_level3;

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
    `FFL(dword0, dma_data, en, 32b'0) // Dword0
    `FFL(dword1, dword0,   en, 32b'0) // Dword1
    `FFL(dword2, dword1,   en, 32b'0) // Dword2
    `FFL(dword3, dword2,   en, 32b'0) // Dword3

    // fill propagation
    logic propagate_level0;
    logic propagate_level1;
    logic propagate_level2;
    logic propagate_level3;
    logic rst_n_propagate;
    assign rst_n_propagate = rst_ni;
    `FFL(propagate_level0, 1'b1,             en, 1b'0, clk_i, rst_n_propagate) // Propagatelevel0
    `FFL(propagate_level1, propagate_level0, en, 1b'0, clk_i, rst_n_propagate) // Propagatelevel1
    `FFL(propagate_level2, propagate_level1, en, 1b'0, clk_i, rst_n_propagate) // Propagatelevel2
    `FFL(propagate_level3, propagate_level2, en, 1b'0, clk_i, rst_n_propagate) // Propagatelevel3
    assign dma_ready = !propagate_level3;

endmodule