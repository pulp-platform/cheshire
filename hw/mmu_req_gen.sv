// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Matteo Perotti <mperotti@iis.ee.ethz.ch>
//
// Description: Simple memory translation request generator for CVA6's shared MMU
//              Generate a request after mmu_req_lat_i cycles from last answer
//              Enable with mmu_req_en_i

module mmu_req_gen (
  input logic                            clk_i,
  input logic                            rst_ni,
  input logic                            mmu_req_en_i,  // Enable the mmu req generator
  input logic [5:0]                      mmu_req_lat_i, // Latency for a new req after last answer (max: 62)
  // MMU interface with accelerator
  output  ariane_pkg::exception_t        acc_mmu_misaligned_ex_o,
  output  logic                          acc_mmu_req_o,        // request address translation
  output  logic [riscv::VLEN-1:0]        acc_mmu_vaddr_o,      // virtual address in
  output  logic                          acc_mmu_is_store_o,   // the translation is requested by a store
  input   logic                          acc_mmu_valid_i       // translation is valid
);

  // Registers
  `include "common_cells/registers.svh"

  logic       wait_ans_d, wait_ans_q;
  logic       acc_mmu_req_d, acc_mmu_req_q;
  logic       mmu_req_en_q;
  logic [5:0] mmu_req_lat_d, mmu_req_lat_q;
  logic [5:0] ans2req_cnt_d, ans2req_cnt_q;
  logic [5:0] cnt_threshold;

  `FF(wait_ans_q, wait_ans_d, '0, clk_i, rst_ni)
  `FF(mmu_req_en_q, mmu_req_en_i, '0, clk_i, rst_ni)
  `FF(mmu_req_lat_q, mmu_req_lat_d, '0, clk_i, rst_ni)
  `FF(ans2req_cnt_q, ans2req_cnt_d, '0, clk_i, rst_ni)
  `FF(acc_mmu_req_q, acc_mmu_req_d, '0, clk_i, rst_ni)

  assign cnt_threshold = mmu_req_lat_q;
  assign acc_mmu_req_o = acc_mmu_req_d | acc_mmu_req_q;

  always_comb begin
    acc_mmu_misaligned_ex_o = '0;
    acc_mmu_vaddr_o = '0;
    acc_mmu_is_store_o = '0;

    wait_ans_d    = wait_ans_q;
    mmu_req_lat_d = mmu_req_lat_q;
    ans2req_cnt_d = ans2req_cnt_q;
    acc_mmu_req_d = acc_mmu_req_q;

    // Act only if enabled
    if (mmu_req_en_q) begin
      // If we are not waiting for an answer or if it arrived, count up
      if (!wait_ans_q) begin
        ans2req_cnt_d += 1;

        // If we have reached the threshold already, make the request and wait for ans
        if (ans2req_cnt_q == cnt_threshold) begin
          acc_mmu_req_d = 1'b1;
          wait_ans_d    = 1'b1;
        end
      end

      // Ans arrived
      if (acc_mmu_valid_i) begin
        // Reset the req and the counter
        ans2req_cnt_d = '0;
        acc_mmu_req_d = 1'b0;
        // We are not waiting anymore for ans
        wait_ans_d    = 1'b0;
      end
    end
  end

endmodule
