// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Two-stage output queue of the DMA for endpoint descriptors
/// Additional stash register for nonperiodic/periodic context switches

module new_usb_dmaoutputqueueED import new_usb_ohci_pkg::*; #(
    parameter int unsigned AxiDataWidth = 0,
    parameter int unsigned DmaOutputQueueStages = 0
)(
    /// control
    input  logic clk_i,
    input  logic rst_ni,
    input  logic pop_i, // @pop store currenthead and do stash or secondin -> firstin
    input  logic pop_ready_o,
    input  logic context_switch_np2p_i, // nonperiodic to periodic
    input  logic context_switch_p2np_i, // periodic to nonperiodic
    input  logic context_switch_i,
    output logic empty_secondin_o, // request new ED
    output logic firstin_valid_o,
    output logic secondin_valid_o,
    output logic secondin_loaded_o,
    /// data input
    input  logic [31:0] dma_data_i,
    input  logic        dma_valid_i,
    output logic        dma_ready_o,
    /// external ED access
    output endpoint_descriptor secondin,
    output endpoint_descriptor firstin
);
    `include "common_cells/registers.svh"

    endpoint_descriptor stash;
    endpoint_descriptor secondinmux;

    logic [31:0] dword0;
    logic [31:0] dword1;
    logic [31:0] dword2;
    logic [31:0] dword3;

    assign dword0 [26:16] = secondin.status.MPS;
    assign dword0 [15]    = secondin.status.F;
    assign dword0 [14]    = secondin.status.K;
    assign dword0 [13]    = secondin.status.S;
    assign dword0 [12:11] = secondin.status.D;
    assign dword0 [10:7]  = secondin.status.EN;
    assign dword0 [6:0]   = secondin.status.FA;
    assign dword2 [31:4]  = secondin.headTD.address;
    assign dword2 [1]     = secondin.headTD.C;
    assign dword2 [0]     = secondin.headTD.H;
    assign dword3 [31:4]  = secondin.nextED.address;

    // control logic
    assign dword1 [31:4]  = tailp; // tailpointerTD only used for empty check
    assign noTD = (tailp == secondin.headTD.address); // we have no TDs or it's not loaded yet
    assign empty_secondin_o = noTD && propagate_valid; // no TDs
    assign secondin_valid_o = !noTD && propagate_valid; // loaded and nonempty secondin
    assign secondin_loaded_o = propagate_valid;
    logic  non_empty_context_switch_np2p;
    assign non_empty_context_switch_np2p = secondin_valid_o && context_switch_np2p_i;

    // create enable, one pulse for one handshake
    logic  en;
    logic  dma_handshake;
    logic  dma_handshake_prev;
    assign dma_handshake = dma_ready && dma_valid_i;
    `FF(dma_handshake_prev, dma_handshake, 1'b0)
    assign en = dma_handshake && ~dma_handshake_prev;

    // secondin registers    
    new_usb_registerchain #(
      .Width(AxiDataWidth),
      .Stages(DmaOutputQueueStages)
    ) i_registerchain_secondin (
      .clk_i,
      .rst_ni, // asynchronous, active low
      .clear_i(1'b0), // never cleared only its propagation validity bit (avoids timing issues, saves power)
      .en_i(en),
      .data_i(dma_data_i),
      .register_o({dword0, dword1, dword2, dword3})
    );

    // secondin fill propagation
    logic propagate_valid;
    logic clear_propagate;
    logic [Stages-1:0] propagate;
    assign propagate_valid = propagate[Stages-1];
    assign clear_propagate = pop_i || empty_secondin_o || context_switch_i;
    assign dma_ready = !propagate_valid;

    new_usb_registerchain #(
      .Width(1),
      .Stages(DmaOutputQueueStages)
    ) i_registerchain_secondin_propagate (
      .clk_i,
      .rst_ni, // asynchronous, active low
      .clear_i(clear_propagate), // synchronous, active high
      .en_i(en),
      .data_i(1'b1), // propagation of ones
      .register_o(propagate)
    );


    // context switch stash (only np EDs are stashed)
    logic active_stash;
    logic rst_n_stash;
    logic non_empty_context_switch_p2np;
    assign non_empty_context_switch_p2np = active_stash && context_switch_p2np_i;
    assign rst_n_stash = !context_switch_p2np_i && rst_ni; // equivalent to !(context_switch_p2np_i || rst_i )
    `FFL(active_stash, 1'b1, non_empty_context_switch_np2p, 1b'0, clk_i, rst_n_stash)
    `FFL(stash, secondin, non_empty_context_switch_np2p, '0) // stash secondin at np2p context switch if valid secondin
    
    // create valid firstin ready for TD processing
    assign pop_ready_o = secondin_valid_o || non_empty_context_switch_p2np;
    `FFL(firstin_valid_o, 1'b1, pop_i, 1b'0) // firstin stays valid until next rst_ni

    // stash and secondin muxed into firstin
    assign secondinmux = non_empty_context_switch_p2np ? stash : secondin;

    // The nextED address needs to be updated in firstin in case secondinED has no TD and secondin's nextED is loaded instead.
    assign firstin_nextED_overwrite = pop_i || empty_secondin_o;
    `FFL(firstin.status.MPS,     secondinmux.status.MPS,     pop_i, '0) // firstin register
    `FFL(firstin.status.F,       secondinmux.status.F,       pop_i, '0) // firstin register
    `FFL(firstin.status.K,       secondinmux.status.K,       pop_i, '0) // firstin register
    `FFL(firstin.status.S,       secondinmux.status.S,       pop_i, '0) // firstin register
    `FFL(firstin.status.D,       secondinmux.status.D,       pop_i, '0) // firstin register
    `FFL(firstin.status.EN,      secondinmux.status.EN,      pop_i, '0) // firstin register
    `FFL(firstin.status.FA,      secondinmux.status.FA,      pop_i, '0) // firstin register
    `FFL(firstin.headTD.address, secondinmux.headTD.address, pop_i, '0) // firstin register
    `FFL(firstin.headTD.C,       secondinmux.headTD.C,       pop_i, '0) // firstin register
    `FFL(firstin.headTD.H,       secondinmux.headTD.H,       pop_i, '0) // firstin register
    `FFL(firstin.nextED.address, secondinmux.nextED.address, firstin_nextED_overwrite, '0) // firstin register

endmodule