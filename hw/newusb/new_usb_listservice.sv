// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Services the lists of the four channel types and feeds the DMA with the it.

// One ED comes into the module, one goes out of the module. No register latency.

// Todo: implement device write back or do on different module
// add missing td
// when first TD of ED is initiated ED is served. Maybe increase counter after td and not ed.
// rewrite with listfilled
// scheduling overrun SOC
// init x axi
// HCAA 

  
// Todo: implement interrupt done, back to nonperiodic
// if interrupt done do periodic_frame 0

module new_usb_listservice import new_usb_ohci_pkg::*; #(
  //parameters
) (

  input logic clk_i,
  input logic rst_ni,

  input  logic          frame_periodic, // frame is currently in periodic or nonperiodic zone
  input  logic          frame_request,  // frame requests new data

  //next ED or TD and one of the four channel types
  input  logic          nextis_valid_i // needs to be one clock cycle
  input  logic          nextis_ed_i,
  input  channel        nextis_type_i,
  input  logic   [27:0] nextis_address_i,
  output logic          nextis_ready_o, // listservice is ready for nextis
  
  input  logic          counter_is_threshold_i, // nonperiodic counter full, switch to bulk

  output logic          controlbulkratio_qe,
  input  logic   [ 1:0] controlbulkratio_q,
  
  output logic          periodcurrent_ed_de,
  output logic   [27:0] periodcurrent_ed_d,
  input  logic   [27:0] periodcurrent_ed_q,
  
  output logic          controlcurrent_ed_de,
  output logic   [27:0] controlcurrent_ed_d,
  input  logic   [27:0] controlcurrent_ed_q,
  
  output logic          bulkcurrent_ed_de,
  output logic   [27:0] bulkcurrent_ed_d,
  input  logic   [27:0] bulkcurrent_ed_q,
  
  output logic          hcbulkhead_ed_de,
  output logic   [27:0] hcbulkhead_ed_d,
  input  logic   [27:0] hcbulkhead_ed_q,
  
  output logic          controlhead_ed_de,
  output logic   [27:0] controlhead_ed_d,
  input  logic   [27:0] controlhead_ed_q,
  
  output logic   [27:0] nextreadwriteaddress_o,
  output logic          validdmaaccess_o,
  output logic          dmawriteorread_o, // write high, read low
  output channel        current_type_o,
  output logic          current_ed_o,
  
  output logic          activebulkhead,
  output logic          activecontrolhead,
  input  logic          activebulkheadprocessed,
  input  logic          activecontrolheadprocessed,
  input  logic          activeaddress, // First ED address coming from head

);

  // listservice is not ready for nextis as long as we have an active head
  assign nextis_ready_d = !(activebulkhead || activecontrolhead);
  `FF(nextis_ready_o, nextis_ready_d, 1'b0) // one cycle delay to avoid concurrencies

  // Valid periodic or nonperiodic endpoint descriptor
  assign nextis_valid_ed = (nextis_valid_i && nextis_ed_i);
  assign nextis_valid_td = (nextis_valid_i && !nextis_ed_i);

  // Write enable
  assign bulkcurrent_ed_de    = ((nextis_valid_ed && (nextis_type_i == BULK)) || activebulkheadprocessed);
  assign controlcurrent_ed_de = ((nextis_valid_ed && (nextis_type_i == CONTROL)) || activecontrolheadprocessed);
  assign periodcurrent_ed_de  = ( nextis_valid_ed && ((nextis_type_i == ISOCHRONOUS) || (nextis_type_i == INTERRUPT)));
  
  // Store current address if write enabled
  assign periodcurrent_ed_d = nextis_address_i;
  assign controlcurrent_ed_d = nextis_address_i;
  assign bulkcurrent_ed_d = nextis_address_i;
  
  // channel scheduling
  logic channel_change;
  logic use_bulkhead;
  logic use_controlhead;
  logic clear_i;
  logic next_clear;
  logic en_i;
  logic next_enable;

  // Flip Flop format
  // `FFL(q, d, load_enable, reset_value)


  channel_change = (counter_is_threshold_i || (nextis_type_i[1] != frame_periodic)); // CBSR or frame zone induced channel change
        
  // channel scheduling output address write multiplexer
  // ToDo one TD each, rethink tree, list filled missing
  // create maybe validdmaaccess_o FF pulse
  always_comb begin
      nextreadwriteaddress_o = 28'b0;
      current_type_o = ISOCHRONOUS; // not important which default type
      validdmaaccess_o = 1'b0;
      dmawriteorread_o = 1'b0;
      current_ed_o = 1'b1;
      if(activebulkheadprocessed) begin // Send first BULK ED
          nextreadwriteaddress_o = active_address;
          current_type_o = BULK;
          validdmaaccess_o = 1'b1;
          // dmawriteorread_o = 1'b0;
          // current_ed_o = 1'b1;
          activebulkhead = 1'b0;
      end
      else if(activecontrolheadprocessed) begin // Send first CONTROL ED
          nextreadwriteaddress_o = active_address;
          current_type_o = CONTROL;
          validdmaaccess_o = 1'b1;
          // dmawriteorread_o = 1'b0;
          // current_ed_o = 1'b1;
          activecontrolhead = 1'b0;
      end
      else begin
          if(nextis_valid_i) begin
             validdmaaccess_o = 1'b1;
             if(nextis_ed_i) begin
                if(channel_change) begin
                    if(frame_periodic) begin
                        nextreadwriteaddress_o = periodcurrent_ed_q;
                        current_type_o = INTERRUPT;
                        // validdmaaccess_o = 1'b1;
                        // dmawriteorread_o = 1'b0;
                        // current_ed_o = 1'b1;
                    end
                    else begin
                        if(counter_overflown) begin
                            nextreadwriteaddress_o = bulkcurrent_ed_q;
                            current_type_o = BULK;
                            // validdmaaccess_o = 1'b1;
                            // dmawriteorread_o = 1'b0;
                            // current_ed_o = 1'b1;
                        end
                        else begin
                            nextreadwriteaddress_o = controlcurrent_ed_q;
                            current_type_o = CONTROL;
                            // validdmaaccess_o = 1'b1;
                            // dmawriteorread_o = 1'b0;
                            // current_ed_o = 1'b1;
                        end
                    end
                end
                else begin
                    nextreadwriteaddress_o = nextis_address_i;
                    current_type_o = nextis_type_i; // no channel change
                    // validdmaaccess_o = 1'b1;
                    // dmawriteorread_o = 1'b0;
                    // current_ed_o = 1'b1;
                end
             end
             else begin
                nextreadwriteaddress_o = nextis_address_i;
                current_type_o = nextis_type_i; // no channel change
                // validdmaaccess_o = 1'b1;
                // dmawriteorread_o = 1'b0;
                current_ed_o = 1'b0;
             end
          end
      end
  end

endmodule
