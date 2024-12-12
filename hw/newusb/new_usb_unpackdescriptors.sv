// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Unpacks the data fields from the descriptors, whose addresses the DMA received from listservice,
/// and sends the next linked addresses back to listservice. 
/// The address field inside the secondinED in the two-stage queue is sent to listservice. 
/// The address of the first ED gets written into the respective current ED register as
/// soon it has been processed, two cycles before pop.
/// The module takes firstinED in the queue and sends its first TD address to listservice.
/// After processing the TD, it proceds to the next ED.


// Todo: only one package flying
// Todo: TD management in ED, overwrite HeadP if servedTD, halted or toggle Carry?

module new_usb_unpackdescriptors import new_usb_ohci_pkg::* #(
    parameter int unsigned AxiDataWidth = 0
)(
    /// control
    input  logic clk_i,
    input  logic rst_ni,
    input  logic [1:0] cbsr_i,
    output logic counter_is_threshold_o,
    /// next address element
    output logic        nextis_valid_o // needs to be one clock cycle
    output logic        nextis_ed_o, // 0 if empty ed rerequest or td
    output channel      nextis_type_o,
    output logic [27:0] nextis_address_o,
    input  logic        nextis_ready_i,
    /// Processed ED with data to write back, get address from currentED
    output endpoint_descriptor processed,
    output logic               processed_ed_store_o, // store request
    output store_type          processed_store_type_o, // isochronousTD, generalTD, ED 
    /// new currentED, updated after processed accessed it
    output logic [27:0] newcurrentED_o,
    output logic        newcurrentED_valid_o,
    /// id type
    input  logic [1:0]  id_valid_i,
    input  logic [2:0]  id_type_i,
    /// dma data
    input  logic [31:0] dma_data_i,
    input  logic        dma_valid_i,
    output logic        dma_ready_o,
    /// periodic, nonperiodic transitions
    input  logic context_switch_np2p_i,
    input  logic context_switch_p2np_i,
    /// head state
    input  logic sent_head_i
);
    
    `include "common_cells/registers.svh"

    localparam int unsigned DmaOutputQueueStages = 128/AxiDataWidth; // dmaoutputqueueED stages
    
    // active package flying to listservice
    logic flying_package;

    // nextis
    assign nextis_ed_o = (id_type[2] && empty_secondin) || !id_type[2]; 
    assign nextis_valid_o = !flying; 
    assign nextis_type = id_type[1:0];
    assign nextis_address_o = secondin.nextED.address;

    // 3 bit ID stack td or ed and channel type
    logic id_en;
    logic id_valid_i_prev;
    logic [2:0] id_type_flying;
    logic [2:0] id_type_secondin;
    logic [2:0] id_type_firstin;
    `FFL(id_type_flying,   id_type_i,        id_en,  3b'101) // ID type flying, sent into dma but not out yet
    `FFL(id_type_secondin, id_type_flying,   id_en,  3b'101) // ID type secondin
    `FFL(id_type_firstin,  id_type_secondin, id_en,  3b'101) // ID type firstin
    `FF(id_valid_i_prev, id_valid, 1'b0)
    assign id_en = id_valid_i && ~id_valid_i_prev;

    /// Exit sequence: served_td -> processed -> newcurrentED -> pop
    // processed
    assign processed.headTD.address = nextTD; //nextTD from servedTD
    assign processed_store_type_o = ED; // Todo:derive from ID stack firstin
    assign processed_ed_store_o = pop_very_early;
    // Todo: halt
    // Todo: skip
    
    // new currentED
    assign newcurrentED_o = firstin.nextED.address;
    assign newcurrentED_valid_o = pop_early;

    // control bulk ratio counter
    logic served_td;
    logic served_bulk_td;
    logic served_control_td;
    logic counter_overflown;
    assign served_td && (id_type_firstin == BULK);
    assign served_td && (id_type_firstin == CONTROL);

    new_usb_nonperiodiccounter i_nonperiodiccounter (
        .clk_i,
        .rst_ni,
        .served_bulk_td_i(served_bulk_td),
        .served_control_td_i(served_control_td),
        .cbsr_i,
        .counter_overflown_o(counter_overflown),
        .counter_is_threshold_o
    );

    // dma data path selector (ed | td | flush)
    assign dma_ready_o     = dma_ready_ed || dma_ready_td || dma_flush;
    assign dma_valid_ed    = dma_valid_i && ed && !dma_flush;
    assign dma_valid_td    = dma_valid_i && !ed && !dma_flush;

    // dma flush is an early flush to prevent faulty stage loading into the queues, save power and increase speed
    logic [Stages-1:0] flush;
    logic flushed;
    logic dma_flush;
    logic dma_flush_en;
    assign dma_flush_en = doublehead_invalid || context_flush; // Todo: add other flush reasons
    assign flushed = flush[Stages-1];
    `FFLARNC(dma_flush, 1'b1, dma_flush_en, flushed, 1b'0, clk_i, rst_ni)
    new_usb_registerchain #(
      .Width(1),
      .Stages(DmaOutputQueueStages)
    ) i_registerchain_flush (
      .clk_i,
      .rst_ni, // asynchronous, active low
      .clear_i(!dma_flush), // synchronous, active high
      .en_i(flush_en),
      .data_i(1'b1), // propagation of ones
      .register_o(flush)
    );

    // create flush enable, one pulse for one handshake
    logic flush_en;
    logic dma_flush_handshake;
    logic dma_flush_handshake_prev;
    assign dma_flush_handshake = dma_flush && dma_valid_i;
    `FF(dma_flush_handshake_prev, dma_flush_handshake, 1'b0)
    assign flush_en = dma_flush_handshake && ~dma_flush_handshake_prev;

    // validity doublehead check
    // Checks validity at secondin because at head we do 
    // double length reads from the DMA like in an array which is not HCD spec but predicted.
    logic loaded_head;
    logic doublehead_invalid;
    assign loaded_head = sent_head_i && secondin_loaded;
    assign doublehead_invalid = loaded_head && ((headED + 1) != secondin.nextED.address); // only upper 28 bits, so +1 instead of +128 

    // context switch with flying package to flush
    logic context_flush;
    logic context_switch;
    assign context_switch = context_switch_n2np || context_switch_p2np;
    assign context_flush = flying_package && context_switch;

    // generate pop 3 cycles delayed to served_td
    logic pop_handshake;
    logic pop_handshake_prev;
    assign pop_handshake = pop_ready && (served_td || aborted_td) && nextis_ready_i;
    `FF(pop_handshake_prev, pop_handshake, 1'b0)
    assign pop_very_early = pop_handshake && ~pop_handshake_prev; // pop_very_early one delayed
    `FF(pop_early, pop_very_early, 1'b0) // pop_early two delayed
    `FF(pop, pop_early, 1'b0) // pop three delayed

    // dma output queue endpoint descriptor
    logic pop;
    logic pop_ready;
    logic empty_secondin;
    logic firstin_valid;
    logic secondin_valid;
    logic secondin_loaded;
    logic dma_valid_ed;
    logic dma_ready_ed;
    endpoint_descriptor firstin;
    endpoint_descriptor secondin;

    // Todo: context switch with active stash get address from firstin.nextED.address and generally when secondin not valid/empty
    new_usb_dmaoutputqueueED i_dmaoutputqueueED (
        /// control
        .clk_i,
        .rst_ni,
        .pop_i(pop), // @pop store currenthead and do stash or secondin -> firstin
        .pop_ready_o(pop_ready), // stash or secondin ready for loading into firstin
        .context_switch_np2p_i, // nonperiodic to periodic
        .context_switch_p2np_i, // periodic to nonperiodic
        .context_switch_i(context_switch),
        .empty_secondin_o(empty_secondin), // request new ED with secondin.nextED.address
        .firstin_valid_o(firstin_valid),
        .secondin_valid_o(secondin_valid), // only valid if TDs inside secondinED
        .secondin_loaded_i(secondin_loaded), // secondinED loaded
        /// data input
        .dma_data_i,
        .dma_valid_i(dma_valid_ed),
        .dma_ready_o(dma_ready_ed),
        /// external ED access
        .secondin,
        .firstin
    );

    // dma output queue transfer descriptor
    logic [27:0] nextTD;
    logic        aborted_td;
    logic        retire_td;
    assign retire_td = served_td && !aborted_td;
    new_usb_dmaoutputqueueTD i_dmaoutputqueueTD (
        /// control
        .clk_i,
        .rst_ni,
        /// data input
        .dma_data_i(dma_data_i),
        .dma_valid_i(dma_valid_td),
        .dma_ready_o(dma_ready_td),
        /// external TD access
        .nextTD_address_o(nextTD),
        .served_td_o(served_td),
        .aborted_td_o(aborted_td)
    );

endmodule
