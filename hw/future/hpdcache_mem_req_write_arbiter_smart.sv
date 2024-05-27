// TODO: header

module hpdcache_mem_req_write_arbiter_smart import hpdcache_pkg::*; #(
    parameter hpdcache_uint N = 0,
    parameter type hpdcache_mem_req_t = logic,
    parameter type hpdcache_mem_req_w_t = logic,
    parameter int unsigned ArbFifoDepth = 24
)(
    input  logic                  clk_i,
    input  logic                  rst_ni,

    output logic                 mem_req_write_ready_o      [N-1:0],
    input  logic                 mem_req_write_valid_i      [N-1:0],
    input  hpdcache_mem_req_t    mem_req_write_i            [N-1:0],

    output logic                 mem_req_write_data_ready_o [N-1:0],
    input  logic                 mem_req_write_data_valid_i [N-1:0],
    input  hpdcache_mem_req_w_t  mem_req_write_data_i       [N-1:0],

    input  logic                 mem_req_write_ready_i,
    output logic                 mem_req_write_valid_o,
    output hpdcache_mem_req_t    mem_req_write_o,

    input  logic                 mem_req_write_data_ready_i,
    output logic                 mem_req_write_data_valid_o,
    output hpdcache_mem_req_w_t  mem_req_write_data_o
);

    // Types and parameters
    typedef logic [(N > 1 ? $clog2(N)-1 : 0):0] sel_t;

    // Repack incoming arrays for easier handling
    logic               [N-1:0] req_valid_in, req_ready_in;
    hpdcache_mem_req_t  [N-1:0] req_in;

    logic                   [N-1:0] wdata_valid_in, wdata_ready_in;
    hpdcache_mem_req_w_t    [N-1:0] wdata_in;

    for (genvar i = 0; i < N; ++i) begin : gen_repack_in
        assign req_valid_in[i] = mem_req_write_valid_i[i];
        assign mem_req_write_ready_o[i] = req_ready_in[i];
        assign req_in[i] = mem_req_write_i[i];

        assign wdata_valid_in[i] = mem_req_write_data_valid_i[i];
        assign mem_req_write_data_ready_o[i] = wdata_ready_in[i];
        assign wdata_in[i] = mem_req_write_data_i[i];
    end

    // Arbitrate requests, grabbing chosen output index for later same-order write arbitration.
    // We use a priority arbiter as in original module (was this an intentional choice over RR?)
    logic [N-1:0] req_valid_rr, req_ready_rr;
    sel_t req_sel;

    rr_arb_tree #(
        .NumIn      ( N ),
        .DataType   ( hpdcache_mem_req_t ),
        .ExtPrio    ( 1'b1 ),
        .AxiVldRdy  ( 1'b1 ),
        .LockIn     ( 1'b0 )    /* TODO: this is scary! but common_cells leaves us no choice... */
    ) i_rr_arb_tree_req (
        .clk_i,
        .rst_ni,
        .flush_i    ( 1'b0 ),
        .rr_i       ( '0 ),
        .req_i      ( req_valid_rr  ),
        .gnt_o      ( req_ready_rr  ),
        .data_i     ( req_in        ),
        .req_o      ( mem_req_write_valid_o ),
        .gnt_i      ( mem_req_write_ready_i ),
        .data_o     ( mem_req_write_o       ),
        .idx_o      ( req_sel )
    );

    // We store the sequence of arbitration decisions in a FIFO
    logic req_valid_fifo, req_ready_fifo;
    logic sel_w_valid, sel_w_ready;
    sel_t sel_w;

    stream_fifo #(
        .FALL_THROUGH ( 1'b0 ),
        .DATA_WIDTH   ( 1 ),
        .DEPTH        ( ArbFifoDepth )
    ) i_stream_fifo_req_sel (
        .clk_i,
        .rst_ni,
        .flush_i    ( 1'b0 ),
        .testmode_i ( 1'b0 ),
        .usage_o    (  ),
        .data_i     ( req_sel ),
        .valid_i    ( req_valid_fifo ),
        .ready_o    ( req_ready_fifo ),
        .data_o     ( sel_w ),
        .valid_o    ( sel_w_valid ),
        .ready_i    ( sel_w_ready )
    );

    // Requests can be blocked either by the arbiter or because the FIFO is full
    assign req_valid_rr     = req_ready_fifo ? req_valid_in : '0;
    assign req_ready_in     = req_ready_fifo ? req_ready_rr : '0;
    assign req_valid_fifo   = |(req_valid_in & req_ready_rr);

    // Multiplex write data, reusing sequence of request arbitration choices
    logic [N-1:0] wdata_valid_mux, wdata_ready_mux;

    stream_mux #(
        .DATA_T ( hpdcache_mem_req_w_t ),
        .N_INP  ( N )
        ) i_stream_mux (
        .inp_sel_i      ( sel_w ),
        .inp_data_i     ( wdata_in ),
        .inp_valid_i    ( wdata_valid_mux ),
        .inp_ready_o    ( wdata_ready_mux ),
        .oup_data_o     ( mem_req_write_data_o       ),
        .oup_valid_o    ( mem_req_write_data_valid_o ),
        .oup_ready_i    ( mem_req_write_data_ready_i )
    );

    // Write data is blocked if no request arbitration outcomes are available (yet)
    assign wdata_valid_mux  = sel_w_valid ? wdata_valid_in : '0;
    assign wdata_ready_in   = sel_w_valid ? wdata_ready_mux : '0;
    assign sel_w_ready      = wdata_valid_in[sel_w] & wdata_ready_in[sel_w];

endmodule
