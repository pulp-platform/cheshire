// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Paul Scheffler <paulsc@iis.ee.ethz.ch>

/// An autonomous, snooping version of the HPDCache stride prefetcher wrapper.
module hwpf_stride_snoop_wrapper
  import hwpf_stride_pkg::*;
  import hpdcache_pkg::*;
#(
  parameter int unsigned NUM_HW_PREFETCH    = 1,
  parameter int unsigned NUM_SNOOP_PORTS    = 1,
  parameter int unsigned MAX_LOG2_BURSTLEN  = 6,    // Stop expanding after a 64-long prefetch (128 blocks total)
  parameter int unsigned TIMEOUT_PER_FETCH  = 6,    // Stop unless we sustain one successful prefetch per 6 fetches
  parameter int unsigned STRIDE_WIDTH       = 16,
  parameter int unsigned TIMER_WIDTH        = 16
) (
  input  logic  clk_i,
  input  logic  rst_ni,
  // CSR ports (Unused here, kept for drop-in replacement)
  input  logic                  [NUM_HW_PREFETCH-1:0] hwpf_stride_base_set_i,
  input  hwpf_stride_base_t     [NUM_HW_PREFETCH-1:0] hwpf_stride_base_i,
  output hwpf_stride_base_t     [NUM_HW_PREFETCH-1:0] hwpf_stride_base_o,
  input  logic                  [NUM_HW_PREFETCH-1:0] hwpf_stride_param_set_i,
  input  hwpf_stride_param_t    [NUM_HW_PREFETCH-1:0] hwpf_stride_param_i,
  output hwpf_stride_param_t    [NUM_HW_PREFETCH-1:0] hwpf_stride_param_o,
  input  logic                  [NUM_HW_PREFETCH-1:0] hwpf_stride_throttle_set_i,
  input  hwpf_stride_throttle_t [NUM_HW_PREFETCH-1:0] hwpf_stride_throttle_i,
  output hwpf_stride_throttle_t [NUM_HW_PREFETCH-1:0] hwpf_stride_throttle_o,
  output hwpf_stride_status_t                         hwpf_stride_status_o,
  // Snoop ports
  input  hpdcache_tag_t         [NUM_SNOOP_PORTS-1:0] snoop_addr_tag_i,
  input  hpdcache_tag_t         [NUM_SNOOP_PORTS-1:0] snoop_phys_tag_i,
  input  hpdcache_pma_t         [NUM_SNOOP_PORTS-1:0] snoop_virt_pma_i,
  input  hpdcache_pma_t         [NUM_SNOOP_PORTS-1:0] snoop_phys_pma_i,
  input  hpdcache_req_offset_t  [NUM_SNOOP_PORTS-1:0] snoop_addr_offset_i,
  input  logic                  [NUM_SNOOP_PORTS-1:0] snoop_phys_indexed_i,
  input  logic                  [NUM_SNOOP_PORTS-1:0] snoop_valid_i,
  input  logic                  [NUM_SNOOP_PORTS-1:0] snoop_abort_i,
  // D-Cache requests
  output hpdcache_req_t     hpdcache_req_o,
  input  hpdcache_req_sid_t hpdcache_req_sid_i,
  output hpdcache_tag_t     hpdcache_req_tag_o,
  output hpdcache_pma_t     hpdcache_req_pma_o,
  output logic              hpdcache_req_valid_o,
  input  logic              hpdcache_req_ready_i,
  output logic              hpdcache_req_abort_o,
  input  hpdcache_rsp_t     hpdcache_rsp_i,
  input  logic              hpdcache_rsp_valid_i
);

  `include "common_cells/registers.svh"

  // Parameters and types
  typedef logic [STRIDE_WIDTH-1:0] pfetch_stride_t;
  typedef logic [cf_math_pkg::idx_width(MAX_LOG2_BURSTLEN+1)-1:0]  pfetch_lcount_t;
  typedef logic [TIMER_WIDTH-1:0]pfetch_timer_t;

  // Resolve snoop cache line address irrespective of addressing mode
  logic                 [NUM_SNOOP_PORTS-1:0] snoop_valid;
  hpdcache_nline_t      [NUM_SNOOP_PORTS-1:0] snoop_nline;

  for (genvar s = 0; s < NUM_SNOOP_PORTS; s++) begin :gen_snoop_resolve
    logic                 snoop_valid_q;
    hpdcache_req_offset_t snoop_addr_offset_q;

    // Virtual tag is valid one cycle later, so delay non-phys-indexed accesses
    `FF(snoop_valid_q,        snoop_valid_i[s],       '0)
    `FF(snoop_addr_offset_q,  snoop_addr_offset_i[s], '0)

    always_comb begin
      // Physical addressing
      if (snoop_phys_indexed_i[s]) begin
        snoop_valid[s] = snoop_valid_i[s] & ~snoop_phys_pma_i[s].uncacheable;
        snoop_nline[s] = hpdcache_get_req_addr_nline({snoop_phys_tag_i[s], snoop_addr_offset_i[s]});
      // Virtual addressing
      end else begin
        snoop_valid[s] = snoop_valid_q & ~snoop_virt_pma_i[s].uncacheable & !snoop_abort_i;
        snoop_nline[s] = hpdcache_get_req_addr_nline({snoop_addr_tag_i[s], snoop_addr_offset_q});
      end
    end
  end

  // Combine snoops to a common valid-only stream. We assume here that:
  // * Shared bandwidth is (at least approximately) <1, so snoop drops are few
  // * Lower snoop ports have priority (current order is: Read, Write, CMO)
  hpdcache_nline_t    snoop_comb_nline;
  logic               snoop_comb_valid;

  /* 
  // TODO: decide for read-only prefetch?
  // Priority arbiter for snoop ports
  always_comb begin
    snoop_comb_valid = 1'b0;
    snoop_comb_nline = '0;
    for (int i = 0; i < NUM_SNOOP_PORTS; ++i) begin
      if (snoop_valid[i]) begin
        snoop_comb_valid  = 1'b1;
        snoop_comb_nline  = snoop_nline[i];
        break;
      end
    end
  end
  */

  assign snoop_comb_nline = snoop_nline[0];
  assign snoop_comb_valid = snoop_valid[0];

  // Determine highest-priority matching prefetcher
  logic [NUM_HW_PREFETCH-1:0] match_pfetch, match_train, match_idle;
  logic [NUM_HW_PREFETCH-1:0] match_prio, match_chosen;

  // First identify highest-piority state actove among all prefetchers
  assign match_prio = (|match_pfetch) ? match_pfetch :
      ((|match_train) ? match_train : match_idle);

  // Then use priority arbiter to select highest-priority prefetcher in prioritized state
  always_comb begin
    match_chosen = '0;
    for (int i = 0; i < NUM_HW_PREFETCH; ++i) begin
      if (match_prio[i]) begin
        match_chosen[i] = 1'b1;
        break;
      end
    end
  end

  // Forward-declare dynamic shared mask for training stride detection
  hpdcache_nline_t snoop_comb_tmask;

  // Forward-declare prefetcher request interface
  logic            [NUM_HW_PREFETCH-1:0] hwpf_stride_arb_in_req_valid;
  logic            [NUM_HW_PREFETCH-1:0] hwpf_stride_arb_in_req_ready;
  hpdcache_req_t   [NUM_HW_PREFETCH-1:0] hwpf_stride_arb_in_req;
  logic            [NUM_HW_PREFETCH-1:0] hwpf_stride_arb_in_rsp_valid;
  hpdcache_rsp_t   [NUM_HW_PREFETCH-1:0] hwpf_stride_arb_in_rsp;

  // Generate prefetchers
  for (genvar p = 0; p < NUM_HW_PREFETCH; p++) begin : gen_hw_prefetch

    hpdcache_nline_t  pfetch_base;
    pfetch_stride_t   pfetch_stride;
    pfetch_lcount_t   pfetch_lcount;
    logic             pfetch_update;
    logic             pfetch_ena;

    hwpf_stride_snoop_walker #(
      .pfetch_stride_t  ( pfetch_stride_t ),
      .pfetch_lcount_t  ( pfetch_lcount_t ),
      .pfetch_timer_t   ( pfetch_timer_t  ),
      .TimeoutPerFetch  ( TIMEOUT_PER_FETCH ),
      .MaxLog2BurstLen  ( MAX_LOG2_BURSTLEN )
    ) i_hwpf_stride_snoop_walker (
      .clk_i,
      .rst_ni,
      .match_nline_i    ( snoop_comb_nline ),
      .match_tmask_i    ( snoop_comb_tmask ),
      .match_valid_i    ( snoop_comb_valid ),
      .match_pfetch_o   ( match_pfetch [p] ),
      .match_train_o    ( match_train  [p] ),
      .match_idle_o     ( match_idle   [p] ),
      .match_chosen_i   ( match_chosen [p] ),
      .pfetch_base_o    ( pfetch_base   ),
      .pfetch_stride_o  ( pfetch_stride ),
      .pfetch_lcount_o  ( pfetch_lcount ),
      .pfetch_update_o  ( pfetch_update ),
      .pfetch_ena_o     ( pfetch_ena    )
    );

    // Counter to generate prefetches
    logic req_ena, req_valid, req_ready;
    pfetch_timer_t req_cnt;


    // Counter to generate line addresses
    hpdcache_nline_t req_nline;

    // TODO: remove address limitation cancer
    assign req_valid  = pfetch_ena & (req_cnt != '0); // & (req_nline < 64'h1002000);
    assign req_ena    = req_valid & req_ready;

    counter #(
      .WIDTH ( TIMER_WIDTH )
    ) i_counter_reqs (
      .clk_i,
      .rst_ni,
      .clear_i    ( 1'b0 ),
      .en_i       ( req_ena ),
      .load_i     ( pfetch_update ),
      .down_i     ( 1'b1 ),
      .d_i        ( TIMER_WIDTH'(1) << pfetch_lcount ),
      .q_o        ( req_cnt ),
      .overflow_o (  )
    );

    delta_counter #(
      .WIDTH ( $bits(hpdcache_nline_t) )
    ) i_counter_addrs (
      .clk_i,
      .rst_ni,
      .clear_i    ( 1'b0 ),
      .en_i       ( req_ena ),
      .load_i     ( pfetch_update ),
      .down_i     ( 1'b0 ),
      .delta_i    ( hpdcache_nline_t'(pfetch_stride) ),
      .d_i        ( pfetch_base ),
      .q_o        ( req_nline ),
      .overflow_o (  )
    );

    // Connect to request the same way as SW prefetchers
    hpdcache_set_t hpdcache_req_set;
    hpdcache_tag_t hpdcache_req_tag;

    assign hpdcache_req_set = req_nline[0                  +: HPDCACHE_SET_WIDTH];
    assign hpdcache_req_tag = req_nline[HPDCACHE_SET_WIDTH +: HPDCACHE_TAG_WIDTH];

    assign hwpf_stride_arb_in_req[p] = '{
      addr_offset     : { hpdcache_req_set, {HPDCACHE_OFFSET_WIDTH{1'b0}} },
      wdata           : '0,
      op              : HPDCACHE_REQ_CMO,
      be              : '1,
      size            : HPDCACHE_REQ_CMO_PREFETCH,
      sid             : hpdcache_req_sid_i,
      tid             : hpdcache_req_tid_t'(p),
      need_rsp        : 1'b0, // TODO: why? Original prefetcher needs responses...
      phys_indexed    : 1'b1,
      addr_tag        : hpdcache_req_tag,
      pma             : '0
    };

    assign hwpf_stride_arb_in_req_valid[p] = req_valid;
    //assign hwpf_stride_arb_in_req_valid[p] = '0;
    assign req_ready = hwpf_stride_arb_in_req_ready[p]; // |  (req_nline >= 64'h1002000);

/*
  assign hwpf_stride_arb_in_req_valid[p] = '0;
  assign req_ready = '0;
  assign hwpf_stride_arb_in_req[p] = '0;
*/

  end

  // TODO: Vote on dynamic shared stride detection mask (static for now at 16 blocks)
  assign snoop_comb_tmask = ~'hF;

  //  Hardware prefetcher arbiter between engines
  hwpf_stride_arb #(
    .NUM_HW_PREFETCH ( NUM_HW_PREFETCH )
  ) hwpf_stride_arb_i (
    .clk_i,
    .rst_ni,
    .hwpf_stride_req_valid_i  ( hwpf_stride_arb_in_req_valid ),
    .hwpf_stride_req_ready_o  ( hwpf_stride_arb_in_req_ready ),
    .hwpf_stride_req_i        ( hwpf_stride_arb_in_req ),
    .hwpf_stride_rsp_valid_o  ( hwpf_stride_arb_in_rsp_valid ),
    .hwpf_stride_rsp_o        ( hwpf_stride_arb_in_rsp ),
    .hpdcache_req_valid_o,
    .hpdcache_req_ready_i,
    .hpdcache_req_o,
    .hpdcache_rsp_valid_i,
    .hpdcache_rsp_i
  );

  // Used on physically indexed requests (tied off)
  assign hpdcache_req_abort_o = '0;
  assign hpdcache_req_tag_o   = '0;
  assign hpdcache_req_pma_o   = '0;

  // Used by SW-controlled prefetchers (tied off)
  assign hwpf_stride_base_o     = '0;
  assign hwpf_stride_param_o    = '0;
  assign hwpf_stride_throttle_o = '0;
  assign hwpf_stride_status_o   = '0;

endmodule


module hwpf_stride_snoop_walker
  import hwpf_stride_pkg::*;
  import hpdcache_pkg::*;
#(
  parameter type          pfetch_stride_t = logic,
  parameter type          pfetch_lcount_t = logic,
  parameter type          pfetch_timer_t  = logic,
  parameter int unsigned  TimeoutPerFetch = 0,
  parameter int unsigned  MaxLog2BurstLen = 0
) (
  input  logic  clk_i,
  input  logic  rst_ni,
  // Line match handshake. We check for matches and wrapper chooses a unit.
  // In Idle state, any line will match (we can start tracking any address).
  // In Train state, we apply an external mask for stride locality.
  input  hpdcache_nline_t match_nline_i,
  input  hpdcache_nline_t match_tmask_i,
  input  logic            match_valid_i,
  output logic            match_pfetch_o,
  output logic            match_train_o,
  output logic            match_idle_o,
  input  logic            match_chosen_i,
  // Base (next query_nline_o), stride, and log2 line count for prefetch.
  // We communicate updates to ensure the request window stays timely.
  output hpdcache_nline_t pfetch_base_o,
  output pfetch_stride_t  pfetch_stride_o,
  output pfetch_lcount_t  pfetch_lcount_o,
  output logic            pfetch_update_o,
  output logic            pfetch_ena_o
);

  typedef enum logic [1:0] {
    Idle      = 0,
    Train     = 1,
    Prefetch  = 2
  } pfetch_state_t;

  pfetch_state_t    state_d,  state_q;
  hpdcache_nline_t  base_d,   base_q;
  hpdcache_nline_t  base_qd,  base_qq;
  pfetch_stride_t   stride_d, stride_q;
  pfetch_lcount_t   lcount_d, lcount_q;

  `FF(state_q,  state_d,  Idle)
  `FF(base_q,   base_d,   '0)
  `FF(base_qq,  base_qd,  '0)
  `FF(stride_q, stride_d, '0)
  `FF(lcount_q, lcount_d, '0)

  // Timeout timer ensures unused prefetch contexts are evicted
  logic           timer_set, timer_overflow;
  pfetch_timer_t  timer_d, timer_q;

  counter #(
    .WIDTH            ( $bits(pfetch_timer_t) )
  ) i_counter_timeout (
    .clk_i,
    .rst_ni,
    .clear_i     ( 1'b0 ),
    .en_i        ( match_valid_i ),
    .load_i      ( timer_set ),
    .down_i      ( 1'b1 ),
    .d_i         ( timer_d ),
    .q_o         ( timer_q ),
    .overflow_o  (  )
  );

  // FSM
  always_comb begin
    // Default registers
    state_d   = state_q;
    stride_d  = stride_q;
    base_d    = base_q;
    base_qd   = base_qq;
    lcount_d  = lcount_q;

    // Default outputs
    match_idle_o    = 1'b0;
    match_train_o   = 1'b0;
    match_pfetch_o  = 1'b0;
    pfetch_base_o   = base_q;
    pfetch_stride_o = stride_q;
    pfetch_lcount_o = lcount_q;
    pfetch_update_o = 1'b0;
    pfetch_ena_o    = 1'b0;

    // Timer
    timer_d   = '0;
    timer_set = 1'b0;

    // State cases
    case (state_q)
      Idle: begin
        match_idle_o = 1'b1;
        // Capture matched (assigned) lines as base
        if (match_valid_i & match_chosen_i) begin
          base_d    = match_nline_i;
          base_qd   = '0;
          state_d   = Train;
          timer_set = 1'b1;
          timer_d   = TimeoutPerFetch;
        end
      end

      Train: begin
        match_train_o = ((match_nline_i & match_tmask_i) == (base_q & match_tmask_i));
        if (match_valid_i & match_chosen_i) begin
          stride_d  = match_nline_i - base_q;
          base_d    = match_nline_i + stride_d;
          base_qd   = base_d;
          lcount_d  = 1;
          timer_set = 1'b1;
          timer_d   = 2 * TimeoutPerFetch;
          // Consume, but do not initiate prefetch on zero stride
          if (match_nline_i != base_q) begin
            state_d = Prefetch;
          end
        end
        // Return to Idle if timeout expires
        if (timer_q == '0) begin
          state_d = Idle;
        end
      end

      Prefetch: begin
        pfetch_ena_o    = 1'b1;
        match_pfetch_o  = (match_nline_i == base_qq);
        // If we hit the timeout, return to idle
        if (timer_q == '0) begin
          state_d = Idle; 
        // Otherwise, if we hit trigger, continue prefetching
        end else if (match_valid_i & match_chosen_i) begin
          pfetch_update_o = 1'b1;
          base_d    = base_q + (hpdcache_nline_t'(1) << lcount_q);
          base_qd   = base_q;
          timer_set = 1'b1;
          timer_d   = (hpdcache_nline_t'(TimeoutPerFetch) << lcount_q);
          // If we did not hit the maximum burst length, increase
          if (lcount_q != MaxLog2BurstLen) begin
            lcount_d  = lcount_q + 1;
          end
        end
      end
    endcase

    // In any state, return to Idle if timeout expires
    if (timer_q == '0) begin
      state_d = Idle;
    end
  end

endmodule
