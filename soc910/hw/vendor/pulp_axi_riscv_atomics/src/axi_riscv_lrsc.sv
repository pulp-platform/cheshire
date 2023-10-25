// Copyright (c) 2018 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// AXI RISC-V LR/SC Adapter
//
// This adapter adds support for AXI4 exclusive accesses to a slave that natively does not support
// exclusive accesses.  It is to be placed between that slave and the upstream master port, so that
// the `mst` port of this module drives the slave and the `slv` port of this module is driven by
// the upstream master.
//
// Exclusive accesses are only enabled for a range of addresses specified through parameters.  All
// addresses within that range are guaranteed to fulfill the constraints described in A7.2 of the
// AXI4 standard, both for normal and exclusive memory accesses.  Addresses outside that range
// behave like a slave that does not support exclusive memory accesses (see AXI4, A7.2.5).
//
// Limitations:
//  -   The adapter does not support bursts in exclusive accessing.  Only single words can be
//      reserved.
//
// Maintainer: Andreas Kurth <akurth@iis.ee.ethz.ch>

module axi_riscv_lrsc #(
    /// Exclusively-accessible address range (closed interval from ADDR_BEGIN to ADDR_END)
    parameter longint unsigned ADDR_BEGIN = 0,
    parameter longint unsigned ADDR_END = 0,
    /// AXI Parameters
    parameter int unsigned AXI_ADDR_WIDTH = 0,
    parameter int unsigned AXI_DATA_WIDTH = 0,
    parameter int unsigned AXI_ID_WIDTH = 0,
    parameter int unsigned AXI_USER_WIDTH = 0,
    parameter int unsigned AXI_MAX_READ_TXNS = 0,  // Maximum number of in-flight read transactions
    parameter int unsigned AXI_MAX_WRITE_TXNS = 0, // Maximum number of in-flight write transactions
    parameter bit AXI_USER_AS_ID = 1'b0,           // Use the AXI User signal instead of the AXI ID to track reservations
    parameter int unsigned AXI_USER_ID_MSB = 0,    // MSB of the ID in the user signal
    parameter int unsigned AXI_USER_ID_LSB = 0,    // LSB of the ID in the user signal
    /// Enable debug prints (not synthesizable).
    parameter bit DEBUG = 1'b0,
    /// Derived Parameters (do NOT change manually!)
    localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8
) (
    input logic                         clk_i,
    input logic                         rst_ni,

    /// Slave Interface
    input  logic [AXI_ADDR_WIDTH-1:0]   slv_aw_addr_i,
    input  logic [2:0]                  slv_aw_prot_i,
    input  logic [3:0]                  slv_aw_region_i,
    input  logic [5:0]                  slv_aw_atop_i,
    input  logic [7:0]                  slv_aw_len_i,
    input  logic [2:0]                  slv_aw_size_i,
    input  logic [1:0]                  slv_aw_burst_i,
    input  logic                        slv_aw_lock_i,
    input  logic [3:0]                  slv_aw_cache_i,
    input  logic [3:0]                  slv_aw_qos_i,
    input  logic [AXI_ID_WIDTH-1:0]     slv_aw_id_i,
    input  logic [AXI_USER_WIDTH-1:0]   slv_aw_user_i,
    output logic                        slv_aw_ready_o,
    input  logic                        slv_aw_valid_i,

    input  logic [AXI_ADDR_WIDTH-1:0]   slv_ar_addr_i,
    input  logic [2:0]                  slv_ar_prot_i,
    input  logic [3:0]                  slv_ar_region_i,
    input  logic [7:0]                  slv_ar_len_i,
    input  logic [2:0]                  slv_ar_size_i,
    input  logic [1:0]                  slv_ar_burst_i,
    input  logic                        slv_ar_lock_i,
    input  logic [3:0]                  slv_ar_cache_i,
    input  logic [3:0]                  slv_ar_qos_i,
    input  logic [AXI_ID_WIDTH-1:0]     slv_ar_id_i,
    input  logic [AXI_USER_WIDTH-1:0]   slv_ar_user_i,
    output logic                        slv_ar_ready_o,
    input  logic                        slv_ar_valid_i,

    input  logic [AXI_DATA_WIDTH-1:0]   slv_w_data_i,
    input  logic [AXI_STRB_WIDTH-1:0]   slv_w_strb_i,
    input  logic [AXI_USER_WIDTH-1:0]   slv_w_user_i,
    input  logic                        slv_w_last_i,
    output logic                        slv_w_ready_o,
    input  logic                        slv_w_valid_i,

    output logic [AXI_DATA_WIDTH-1:0]   slv_r_data_o,
    output logic [1:0]                  slv_r_resp_o,
    output logic                        slv_r_last_o,
    output logic [AXI_ID_WIDTH-1:0]     slv_r_id_o,
    output logic [AXI_USER_WIDTH-1:0]   slv_r_user_o,
    input  logic                        slv_r_ready_i,
    output logic                        slv_r_valid_o,

    output logic [1:0]                  slv_b_resp_o,
    output logic [AXI_ID_WIDTH-1:0]     slv_b_id_o,
    output logic [AXI_USER_WIDTH-1:0]   slv_b_user_o,
    input  logic                        slv_b_ready_i,
    output logic                        slv_b_valid_o,

    /// Master Interface
    output logic [AXI_ADDR_WIDTH-1:0]   mst_aw_addr_o,
    output logic [2:0]                  mst_aw_prot_o,
    output logic [3:0]                  mst_aw_region_o,
    output logic [5:0]                  mst_aw_atop_o,
    output logic [7:0]                  mst_aw_len_o,
    output logic [2:0]                  mst_aw_size_o,
    output logic [1:0]                  mst_aw_burst_o,
    output logic                        mst_aw_lock_o,
    output logic [3:0]                  mst_aw_cache_o,
    output logic [3:0]                  mst_aw_qos_o,
    output logic [AXI_ID_WIDTH-1:0]     mst_aw_id_o,
    output logic [AXI_USER_WIDTH-1:0]   mst_aw_user_o,
    input  logic                        mst_aw_ready_i,
    output logic                        mst_aw_valid_o,

    output logic [AXI_ADDR_WIDTH-1:0]   mst_ar_addr_o,
    output logic [2:0]                  mst_ar_prot_o,
    output logic [3:0]                  mst_ar_region_o,
    output logic [7:0]                  mst_ar_len_o,
    output logic [2:0]                  mst_ar_size_o,
    output logic [1:0]                  mst_ar_burst_o,
    output logic                        mst_ar_lock_o,
    output logic [3:0]                  mst_ar_cache_o,
    output logic [3:0]                  mst_ar_qos_o,
    output logic [AXI_ID_WIDTH-1:0]     mst_ar_id_o,
    output logic [AXI_USER_WIDTH-1:0]   mst_ar_user_o,
    input  logic                        mst_ar_ready_i,
    output logic                        mst_ar_valid_o,

    output logic [AXI_DATA_WIDTH-1:0]   mst_w_data_o,
    output logic [AXI_STRB_WIDTH-1:0]   mst_w_strb_o,
    output logic [AXI_USER_WIDTH-1:0]   mst_w_user_o,
    output logic                        mst_w_last_o,
    input  logic                        mst_w_ready_i,
    output logic                        mst_w_valid_o,

    input  logic [AXI_DATA_WIDTH-1:0]   mst_r_data_i,
    input  logic [1:0]                  mst_r_resp_i,
    input  logic                        mst_r_last_i,
    input  logic [AXI_ID_WIDTH-1:0]     mst_r_id_i,
    input  logic [AXI_USER_WIDTH-1:0]   mst_r_user_i,
    output logic                        mst_r_ready_o,
    input  logic                        mst_r_valid_i,

    input  logic [1:0]                  mst_b_resp_i,
    input  logic [AXI_ID_WIDTH-1:0]     mst_b_id_i,
    input  logic [AXI_USER_WIDTH-1:0]   mst_b_user_i,
    output logic                        mst_b_ready_o,
    input  logic                        mst_b_valid_i
);

    // Declarations of Signals and Types
    localparam int unsigned RES_ID_WIDTH = AXI_USER_AS_ID ?
            AXI_USER_ID_MSB - AXI_USER_ID_LSB + 1
            : AXI_ID_WIDTH;

    typedef logic [AXI_ADDR_WIDTH-1:0]  axi_addr_t;
    typedef logic [AXI_DATA_WIDTH-1:0]  axi_data_t;
    typedef logic [AXI_ID_WIDTH-1:0]    axi_id_t;
    typedef logic [1:0]                 axi_resp_t;
    typedef logic [AXI_USER_WIDTH-1:0]  axi_user_t;
    typedef logic [AXI_ADDR_WIDTH-3:0]  res_addr_t; // Track reservations word wise.
    typedef logic [RES_ID_WIDTH-1:0]    res_id_t;

    typedef enum logic [1:0] {
        B_REGULAR='0, B_EXCLUSIVE, B_INJECT
    } b_cmd_t;

    typedef struct packed {
        axi_id_t    id;
        axi_user_t  user;
    } b_inj_t;

    typedef struct packed {
        axi_id_t    id;
        axi_user_t  user;
        axi_resp_t  resp;
    } b_chan_t;

    typedef struct packed {
        axi_id_t    id;
        axi_data_t  data;
        axi_resp_t  resp;
        axi_user_t  user;
        logic       last;
    } r_chan_t;

    typedef struct packed {
        logic   excl;
    } r_flight_t;

    typedef struct packed {
        logic       forward;
        axi_id_t    id;
        axi_user_t  user;
    } w_cmd_t;

    typedef struct packed {
        res_addr_t  addr;
        logic       excl;
    } w_flight_t;

    typedef struct packed {
        w_flight_t                      data;
        logic [$bits(w_flight_t)-1:0]   mask;
    } wifq_exists_t;

    typedef enum logic {
        AR_IDLE, AR_WAIT
    } ar_state_t;

    typedef enum logic {
        AW_IDLE, AW_WAIT
    } aw_state_t;

    typedef struct packed {
        axi_addr_t  addr;
        logic [2:0] prot;
        logic [3:0] region;
        logic [5:0] atop;
        logic [7:0] len;
        logic [2:0] size;
        logic [1:0] burst;
        logic [3:0] cache;
        logic [3:0] qos;
        axi_id_t    id;
        axi_user_t  user;
    } aw_chan_t;

    typedef enum logic {
        B_NORMAL, B_FORWARD
    } b_state_t;

    axi_id_t        b_status_inp_id,
                    b_status_oup_id,
                    rifq_oup_id;

    res_addr_t      ar_push_addr,
                    art_check_clr_addr;

    res_id_t        art_set_id,
                    art_check_id;

    logic           ar_push_excl,
                    ar_push_res;

    logic           art_check_clr_excl;

    logic           ar_push_valid,              ar_push_ready,
                    art_check_clr_req,          art_check_clr_gnt,
                    art_filter_valid,           art_filter_ready,
                    art_set_req,                art_set_gnt;

    logic           rifq_inp_req,               rifq_inp_gnt,
                    rifq_oup_req,               rifq_oup_gnt,
                    rifq_oup_pop,
                    rifq_oup_data_valid;

    r_flight_t      rifq_inp_data,
                    rifq_oup_data;

    logic           wifq_exists,
                    ar_wifq_exists_req,         ar_wifq_exists_gnt,
                    aw_wifq_exists_req,         aw_wifq_exists_gnt,
                    wifq_exists_req,            wifq_exists_gnt,
                                                wifq_inp_gnt,
                    wifq_oup_req,               wifq_oup_gnt,
                    wifq_oup_data_valid;

    wifq_exists_t   ar_wifq_exists_inp,
                    aw_wifq_exists_inp,
                    wifq_exists_inp;

    b_chan_t        slv_b;

    logic           slv_b_valid,                slv_b_ready;

    r_chan_t        slv_r;

    logic           slv_r_valid,                slv_r_ready;

    logic           mst_b_valid,                mst_b_ready;

    w_cmd_t         w_cmd_inp,                  w_cmd_oup;

    logic           w_cmd_push,                 w_cmd_pop,
                    w_cmd_full,                 w_cmd_empty;

    b_inj_t         b_inj_inp,                  b_inj_oup;

    logic           b_inj_push,                 b_inj_pop,
                    b_inj_full,                 b_inj_empty;

    b_cmd_t         b_status_inp_cmd,           b_status_oup_cmd;

    logic           b_status_inp_req,           b_status_oup_req,
                    b_status_inp_gnt,           b_status_oup_gnt,
                    b_status_oup_pop,
                    b_status_oup_valid;

    logic           art_check_res;

    ar_state_t      ar_state_d,                 ar_state_q;

    aw_state_t      aw_state_d,                 aw_state_q;

    b_state_t       b_state_d,                  b_state_q;

    aw_chan_t       slv_aw,                     mst_aw;

    logic           mst_aw_valid,               mst_aw_ready;

    // AR and R Channel

    // IQ Queue to track in-flight reads
    id_queue #(
        .ID_WIDTH   (AXI_ID_WIDTH),
        .CAPACITY   (AXI_MAX_READ_TXNS),
        .data_t     (r_flight_t)
    ) i_read_in_flight_queue (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .inp_id_i           (slv_ar_id_i),
        .inp_data_i         (rifq_inp_data),
        .inp_req_i          (rifq_inp_req),
        .inp_gnt_o          (rifq_inp_gnt),
        .exists_data_i      (),
        .exists_mask_i      (),
        .exists_req_i       (1'b0),
        .exists_o           (),
        .exists_gnt_o       (),
        .oup_id_i           (rifq_oup_id),
        .oup_pop_i          (rifq_oup_pop),
        .oup_req_i          (rifq_oup_req),
        .oup_data_o         (rifq_oup_data),
        .oup_data_valid_o   (rifq_oup_data_valid),
        .oup_gnt_o          (rifq_oup_gnt)
    );
    assign rifq_inp_data.excl = ar_push_excl;

    // Fork requests from AR into reservation table and queue of in-flight reads.
    stream_fork #(
        .N_OUP  (2)
    ) i_ar_push_fork (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .valid_i    (ar_push_valid),
        .ready_o    (ar_push_ready),
        .valid_o    ({art_filter_valid, rifq_inp_req}),
        .ready_i    ({art_filter_ready, rifq_inp_gnt})
    );

    stream_filter i_art_filter (
        .valid_i    (art_filter_valid),
        .ready_o    (art_filter_ready),
        .drop_i     (!ar_push_res),
        .valid_o    (art_set_req),
        .ready_i    (art_set_gnt)
    );

    // Time-Invariant Signal Assignments
    assign mst_ar_addr_o    = slv_ar_addr_i;
    assign mst_ar_prot_o    = slv_ar_prot_i;
    assign mst_ar_region_o  = slv_ar_region_i;
    assign mst_ar_len_o     = slv_ar_len_i;
    assign mst_ar_size_o    = slv_ar_size_i;
    assign mst_ar_burst_o   = slv_ar_burst_i;
    assign mst_ar_lock_o    = 1'b0;
    assign mst_ar_cache_o   = slv_ar_cache_i;
    assign mst_ar_qos_o     = slv_ar_qos_i;
    assign mst_ar_id_o      = slv_ar_id_i;
    assign mst_ar_user_o    = slv_ar_user_i;
    assign slv_r.data       = mst_r_data_i;
    assign slv_r.last       = mst_r_last_i;
    assign slv_r.id         = mst_r_id_i;
    assign slv_r.user       = mst_r_user_i;

    // Control R Channel
    always_comb begin
        mst_r_ready_o   = 1'b0;
        slv_r.resp      = '0;
        slv_r_valid     = 1'b0;
        rifq_oup_id     = '0;
        rifq_oup_pop    = 1'b0;
        rifq_oup_req    = 1'b0;
        if (mst_r_valid_i && slv_r_ready) begin
            rifq_oup_id     = mst_r_id_i;
            rifq_oup_pop    = mst_r_last_i;
            rifq_oup_req    = 1'b1;
            if (rifq_oup_gnt) begin
                mst_r_ready_o = 1'b1;
                if (mst_r_resp_i[1] == 1'b0) begin
                    slv_r.resp = {1'b0, rifq_oup_data.excl};
                end else begin
                    slv_r.resp = mst_r_resp_i;
                end
                slv_r_valid = 1'b1;
            end
        end
    end

// pragma translate_off
    always @(posedge clk_i) begin
        if (~rst_ni) begin
            if (rifq_oup_req && rifq_oup_gnt) begin
                assert (rifq_oup_data_valid) else $error("Unexpected R with ID %0x!", mst_r_id_i);
            end
        end
    end
// pragma translate_on

    // Control AR Channel
    always_comb begin
        mst_ar_valid_o                  = 1'b0;
        slv_ar_ready_o                  = 1'b0;
        ar_push_addr                    = '0;
        ar_push_excl                    = '0;
        ar_push_res                     = '0;
        ar_push_valid                   = 1'b0;
        ar_wifq_exists_inp.data.addr    = '0;
        ar_wifq_exists_inp.data.excl    = 1'b0;
        ar_wifq_exists_inp.mask         = '1;
        ar_wifq_exists_inp.mask[0]      = 1'b0; // Don't care on `excl` bit.
        ar_wifq_exists_req              = 1'b0;
        ar_state_d                      = ar_state_q;

        case (ar_state_q)

            AR_IDLE: begin
                if (slv_ar_valid_i) begin
                    ar_push_addr = slv_ar_addr_i[AXI_ADDR_WIDTH-1:2];
                    ar_push_excl = (slv_ar_addr_i >= ADDR_BEGIN && slv_ar_addr_i <= ADDR_END &&
                            slv_ar_lock_i && slv_ar_len_i == 8'h00);
                    if (ar_push_excl) begin
                        ar_wifq_exists_inp.data.addr = slv_ar_addr_i[AXI_ADDR_WIDTH-1:2];
                        ar_wifq_exists_req = 1'b1;
                        if (ar_wifq_exists_gnt) begin
                            ar_push_res = !wifq_exists;
                            ar_push_valid = 1'b1;
                        end
                    end else begin
                        ar_push_res = 1'b0;
                        ar_push_valid = 1'b1;
                    end
                    if (ar_push_ready) begin
                        mst_ar_valid_o = 1'b1;
                        if (mst_ar_ready_i) begin
                            slv_ar_ready_o = 1'b1;
                        end else begin
                            ar_state_d = AR_WAIT;
                        end
                    end
                end
            end

            AR_WAIT: begin
                mst_ar_valid_o = slv_ar_valid_i;
                slv_ar_ready_o = mst_ar_ready_i;
                if (mst_ar_ready_i && mst_ar_valid_o) begin
                    ar_state_d = AR_IDLE;
                end
            end

            default: begin
                ar_state_d = AR_IDLE;
            end
        endcase
    end

    // AW, W and B Channel

    // FIFO to track commands for W bursts.
    fifo_v3 #(
        .FALL_THROUGH   (1'b0), // There would be a combinatorial loop if this were a fall-through
                                // register.  Optimizing this can reduce the latency of this module.
        .dtype          (w_cmd_t),
        .DEPTH          (AXI_MAX_WRITE_TXNS)
    ) i_w_cmd_fifo (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .flush_i    (1'b0),
        .testmode_i (1'b0),
        .full_o     (w_cmd_full),
        .empty_o    (w_cmd_empty),
        .usage_o    (),
        .data_i     (w_cmd_inp),
        .push_i     (w_cmd_push),
        .data_o     (w_cmd_oup),
        .pop_i      (w_cmd_pop)
    );

    // ID Queue to track downstream W bursts and their pending B responses.
    // Workaround for bug in Questa (at least 2018.07 is affected) and VCS (at least 2020.12 is
    // affected):
    // Flatten the enum into a logic vector before using that type when instantiating `id_queue`.
    typedef logic [$bits(b_cmd_t)-1:0] b_cmd_flat_t;
    b_cmd_flat_t b_status_inp_cmd_flat, b_status_oup_cmd_flat;
    assign b_status_inp_cmd_flat = b_cmd_flat_t'(b_status_inp_cmd);
    id_queue #(
        .ID_WIDTH   (AXI_ID_WIDTH),
        .CAPACITY   (AXI_MAX_WRITE_TXNS),
        .data_t     (b_cmd_flat_t)
    ) i_b_status_queue (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .inp_id_i           (b_status_inp_id),
        .inp_data_i         (b_status_inp_cmd_flat),
        .inp_req_i          (b_status_inp_req),
        .inp_gnt_o          (b_status_inp_gnt),
        .exists_data_i      (),
        .exists_mask_i      (),
        .exists_req_i       (1'b0),
        .exists_o           (),
        .exists_gnt_o       (),
        .oup_id_i           (b_status_oup_id),
        .oup_pop_i          (b_status_oup_pop),
        .oup_req_i          (b_status_oup_req),
        .oup_data_o         (b_status_oup_cmd_flat),
        .oup_data_valid_o   (b_status_oup_valid),
        .oup_gnt_o          (b_status_oup_gnt)
    );
    assign b_status_oup_cmd = b_cmd_t'(b_status_oup_cmd_flat);

    // ID Queue to track in-flight writes.
    id_queue #(
        .ID_WIDTH   (AXI_ID_WIDTH),
        .CAPACITY   (AXI_MAX_WRITE_TXNS),
        .data_t     (w_flight_t)
    ) i_write_in_flight_queue (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .inp_id_i           (mst_aw_id_o),
        .inp_data_i         ({mst_aw_addr_o[AXI_ADDR_WIDTH-1:2], slv_aw_lock_i}),
        .inp_req_i          (mst_aw_valid && mst_aw_ready),
        .inp_gnt_o          (wifq_inp_gnt),
        .exists_data_i      (wifq_exists_inp.data),
        .exists_mask_i      (wifq_exists_inp.mask),
        .exists_req_i       (wifq_exists_req),
        .exists_o           (wifq_exists),
        .exists_gnt_o       (wifq_exists_gnt),
        .oup_id_i           (mst_b_id_i),
        .oup_pop_i          (1'b1),
        .oup_req_i          (wifq_oup_req),
        .oup_data_o         (),
        .oup_data_valid_o   (wifq_oup_data_valid),
        .oup_gnt_o          (wifq_oup_gnt)
    );

// pragma translate_off
    always @(posedge clk_i) begin
        if (~rst_ni) begin
            if (mst_aw_valid && mst_aw_ready) begin
                assert (wifq_inp_gnt) else $error("Missed enqueuing of in-flight write!");
            end
            if (wifq_oup_req && wifq_oup_gnt) begin
                assert (wifq_oup_data_valid) else $error("Unexpected B!");
            end
        end
    end
// pragma translate_on

    stream_arbiter #(
        .DATA_T (wifq_exists_t),
        .N_INP  (2)
    ) i_wifq_exists_arb (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .inp_data_i     ({ar_wifq_exists_inp,   aw_wifq_exists_inp}),
        .inp_valid_i    ({ar_wifq_exists_req,   aw_wifq_exists_req}),
        .inp_ready_o    ({ar_wifq_exists_gnt,   aw_wifq_exists_gnt}),
        .oup_data_o     (wifq_exists_inp),
        .oup_valid_o    (wifq_exists_req),
        .oup_ready_i    (wifq_exists_gnt)
    );

    stream_fork #(
        .N_OUP  (2)
    ) i_mst_b_fork (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .valid_i    (mst_b_valid_i),
        .ready_o    (mst_b_ready_o),
        .valid_o    ({mst_b_valid, wifq_oup_req}),
        .ready_i    ({mst_b_ready, wifq_oup_gnt})
    );

    // FIFO to track B responses that are to be injected.
    fifo_v3 #(
        .FALL_THROUGH   (1'b0),
        .dtype          (b_inj_t),
        .DEPTH          (AXI_MAX_WRITE_TXNS)
    ) i_b_inj_fifo (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .flush_i    (1'b0),
        .testmode_i (1'b0),
        .full_o     (b_inj_full),
        .empty_o    (b_inj_empty),
        .usage_o    (),
        .data_i     (b_inj_inp),
        .push_i     (b_inj_push),
        .data_o     (b_inj_oup),
        .pop_i      (b_inj_pop)
    );

    // Fall-through register to hold AW transactin that passed
    assign slv_aw = {slv_aw_addr_i,
                     slv_aw_prot_i,
                     slv_aw_region_i,
                     slv_aw_atop_i,
                     slv_aw_len_i,
                     slv_aw_size_i,
                     slv_aw_burst_i,
                     slv_aw_cache_i,
                     slv_aw_qos_i,
                     slv_aw_id_i,
                     slv_aw_user_i};
    assign {mst_aw_addr_o,
            mst_aw_prot_o,
            mst_aw_region_o,
            mst_aw_atop_o,
            mst_aw_len_o,
            mst_aw_size_o,
            mst_aw_burst_o,
            mst_aw_cache_o,
            mst_aw_qos_o,
            mst_aw_id_o,
            mst_aw_user_o} = mst_aw;


    fall_through_register #(
        .T (aw_chan_t)
    ) i_aw_trans_reg (
        .clk_i       (clk_i),
        .rst_ni      (rst_ni),
        .clr_i       (1'b0),
        .testmode_i  (1'b0),
        // Input
        .valid_i     (mst_aw_valid),
        .ready_o     (mst_aw_ready),
        .data_i      (slv_aw),
        // Output
        .valid_o     (mst_aw_valid_o),
        .ready_i     (mst_aw_ready_i),
        .data_o      (mst_aw)
    );

    // Time-Invariant Signal Assignments
    assign mst_aw_lock_o    = 1'b0;
    assign mst_w_data_o     = slv_w_data_i;
    assign mst_w_strb_o     = slv_w_strb_i;
    assign mst_w_user_o     = slv_w_user_i;
    assign mst_w_last_o     = slv_w_last_i;

    // Control AW Channel
    always_comb begin
        mst_aw_valid            = 1'b0;
        slv_aw_ready_o          = 1'b0;
        art_check_clr_addr      = '0;
        art_check_clr_excl      = '0;
        art_check_clr_req       = 1'b0;
        aw_wifq_exists_inp.data = '0;
        aw_wifq_exists_inp.mask = '1;
        aw_wifq_exists_req      = 1'b0;
        b_status_inp_id         = '0;
        b_status_inp_cmd        = B_REGULAR;
        b_status_inp_req        = 1'b0;
        w_cmd_inp               = '0;
        w_cmd_push              = 1'b0;
        aw_state_d              = aw_state_q;

        case (aw_state_q)
            AW_IDLE: begin
                if (slv_aw_valid_i && !w_cmd_full && b_status_inp_gnt && wifq_inp_gnt) begin
                    // New AW and we are ready to handle it.
                    if (slv_aw_addr_i >= ADDR_BEGIN && slv_aw_addr_i <= ADDR_END) begin
                        // Inside exclusively-accessible range.
                        // Make sure no exclusive AR to the same address is currently waiting.
                        if (!(slv_ar_valid_i && slv_ar_lock_i &&
                                slv_ar_addr_i[AXI_ADDR_WIDTH-1:2] == slv_aw_addr_i[AXI_ADDR_WIDTH-1:2])) begin
                            // Make sure no exclusive write to the same address is currently in
                            // flight.
                            aw_wifq_exists_inp.data.addr = slv_aw_addr_i[AXI_ADDR_WIDTH-1:2];
                            aw_wifq_exists_inp.data.excl = 1'b1;
                            aw_wifq_exists_req = 1'b1;
                            if (aw_wifq_exists_gnt && !wifq_exists) begin
                                // Check reservation and clear identical addresses.
                                art_check_clr_addr  = slv_aw_addr_i[AXI_ADDR_WIDTH-1:2];
                                art_check_clr_excl  = slv_aw_lock_i;
                                if (mst_aw_ready) begin
                                    art_check_clr_req = 1'b1;
                                end
                                if (art_check_clr_gnt) begin
                                    if (slv_aw_lock_i && slv_aw_len_i == 8'h00) begin
                                        // Exclusive access and no burst, so check reservation.
                                        if (art_check_res) begin
                                            // Reservation exists, so forward downstream.
                                            mst_aw_valid   = 1'b1;
                                            slv_aw_ready_o = mst_aw_ready;
                                            if (!mst_aw_ready) begin
                                                aw_state_d = AW_WAIT;
                                            end
                                        end else begin
                                            // No reservation exists, so drop AW.
                                            slv_aw_ready_o = 1'b1;
                                        end
                                        // Store command to forward or drop W burst.
                                        w_cmd_inp = '{forward: art_check_res, id: slv_aw_id_i,
                                                user: slv_aw_user_i};
                                        w_cmd_push = 1'b1;
                                        // Add B status for this ID (exclusive if there is a
                                        // reservation, inject otherwise).
                                        b_status_inp_cmd = art_check_res ? B_EXCLUSIVE : B_INJECT;
                                    end else begin
                                        // Non-exclusive access or burst, so forward downstream.
                                        mst_aw_valid   = 1'b1;
                                        slv_aw_ready_o = mst_aw_ready;
                                        // Store command to forward W burst.
                                        w_cmd_inp  = '{forward: 1'b1, id: '0, user: '0};
                                        w_cmd_push = 1'b1;
                                        // Track B response as regular-okay.
                                        b_status_inp_cmd = B_REGULAR;
                                        if (!mst_aw_ready) begin
                                            aw_state_d = AW_WAIT;
                                        end
                                    end
                                    b_status_inp_id = slv_aw_id_i;
                                    b_status_inp_req = 1'b1;
                                end
                            end
                        end
                    end else begin
                        // Outside exclusively-accessible address range, so bypass any
                        // modifications.
                        mst_aw_valid   = 1'b1;
                        slv_aw_ready_o = mst_aw_ready;
                        if (mst_aw_ready) begin
                            // Store command to forward W burst.
                            w_cmd_inp = '{forward: 1'b1, id: '0, user: '0};
                            w_cmd_push = 1'b1;
                            // Track B response as regular-okay.
                            b_status_inp_id  = slv_aw_id_i;
                            b_status_inp_cmd = B_REGULAR;
                            b_status_inp_req = 1'b1;
                        end
                    end
                end
            end

            AW_WAIT: begin
                mst_aw_valid   = 1'b1;
                slv_aw_ready_o = mst_aw_ready;
                if (mst_aw_ready) begin
                    aw_state_d = AW_IDLE;
                end
            end

            default:
                aw_state_d = AW_IDLE;
        endcase
    end

// pragma translate_off
    if (DEBUG) begin
        always @(posedge clk_i) begin
            if (b_status_inp_req && b_status_inp_gnt) begin
                $display("%0t: AW added %0x as %0d", $time, b_status_inp_id, b_status_inp_cmd);
            end
        end
    end
// pragma translate_on

    // Control W Channel
    always_comb begin
        mst_w_valid_o   = 1'b0;
        slv_w_ready_o   = 1'b0;
        b_inj_inp       = '0;
        b_inj_push      = 1'b0;
        w_cmd_pop       = 1'b0;
        if (slv_w_valid_i && !w_cmd_empty && !b_inj_full) begin
            if (w_cmd_oup.forward) begin
                // Forward
                mst_w_valid_o = 1'b1;
                slv_w_ready_o = mst_w_ready_i;
            end else begin
                // Drop
                slv_w_ready_o = 1'b1;
            end
            if (slv_w_ready_o && slv_w_last_i) begin
                w_cmd_pop = 1'b1;
                if (!w_cmd_oup.forward) begin
                    // Add command to inject B response.
                    b_inj_inp = '{id: w_cmd_oup.id, user: w_cmd_oup.user};
                    b_inj_push = 1'b1;
                end
            end
        end
    end

// pragma translate_off
    if (DEBUG) begin
        always @(posedge clk_i) begin
            if (b_inj_push) begin
                $display("%0t: W added inject for %0x", $time, b_inj_inp.id);
            end
        end
    end
// pragma translate_on

    // Control B Channel
    always_comb begin
        slv_b.id            = mst_b_id_i;
        slv_b.resp          = mst_b_resp_i;
        slv_b.user          = mst_b_user_i;
        slv_b_valid         = 1'b0;
        mst_b_ready         = 1'b0;
        b_inj_pop           = 1'b0;
        b_status_oup_id     = '0;
        b_status_oup_req    = 1'b0;
        b_state_d           = b_state_q;

        case (b_state_q)
            B_NORMAL: begin
                if (!b_inj_empty) begin
                    // There is a response to be injected ..
                    b_status_oup_id = b_inj_oup.id;
                    b_status_oup_req = 1'b1;
                    if (b_status_oup_gnt && b_status_oup_valid) begin
                        if (b_status_oup_cmd == B_INJECT) begin
                            // .. and the next B for that ID is indeed an injection, so go ahead and
                            // inject it.
                            slv_b.id    = b_inj_oup.id;
                            slv_b.resp  = axi_pkg::RESP_OKAY;
                            slv_b.user  = b_inj_oup.user;
                            slv_b_valid = 1'b1;
                            b_inj_pop   = slv_b_ready;
                        end else begin
                            // .. but the next B for that ID is *not* an injection, so try to
                            // forward a B.
                            b_state_d = B_FORWARD;
                        end
                    end
                end else if (mst_b_valid) begin
                    // There is currently no response to be injected, so try to forward a B.
                    b_status_oup_id = mst_b_id_i;
                    b_status_oup_req = 1'b1;
                    if (b_status_oup_gnt && b_status_oup_valid) begin
                        if (mst_b_resp_i[1] == 1'b0) begin
                            slv_b.resp = {1'b0, (b_status_oup_cmd == B_EXCLUSIVE)};
                        end else begin
                            slv_b.resp = mst_b_resp_i;
                        end
                        slv_b_valid = 1'b1;
                        mst_b_ready = slv_b_ready;
                    end
                end
            end

            B_FORWARD: begin
                if (mst_b_valid) begin
                    b_status_oup_id = mst_b_id_i;
                    b_status_oup_req = 1'b1;
                    if (b_status_oup_gnt && b_status_oup_valid) begin
                        if (mst_b_resp_i[1] == 1'b0) begin
                            slv_b.resp = {1'b0, (b_status_oup_cmd == B_EXCLUSIVE)};
                        end else begin
                            slv_b.resp = mst_b_resp_i;
                        end
                        slv_b_valid = 1'b1;
                        mst_b_ready = slv_b_ready;
                        if (slv_b_ready) begin
                            b_state_d = B_NORMAL;
                        end
                    end
                end
            end

            default:
                b_state_d = B_NORMAL;
        endcase
    end

// pragma translate_off
    always @(posedge clk_i) begin
        if (b_status_oup_req && b_status_oup_gnt) begin
            assert (b_status_oup_valid);
            if ((b_state_q == B_NORMAL && b_inj_empty) || b_state_q == B_FORWARD) begin
                assert (b_status_oup_cmd != B_INJECT);
            end
        end
    end
// pragma translate_on

// pragma translate_off
    if (DEBUG) begin
        always @(posedge clk_i) begin
            if (slv_b_valid && slv_b_ready) begin
                if (mst_b_ready) begin
                    $display("%0t: B forwarded %0x", $time, slv_b.id);
                end else begin
                    $display("%0t: B injected  %0x", $time, slv_b.id);
                end
            end
        end
    end
// pragma translate_on

    assign b_status_oup_pop = slv_b_valid && slv_b_ready;

    // Register in front of slv_b to prevent changes by FSM while valid and not yet ready.
    stream_register #(
        .T  (b_chan_t)
    ) slv_b_reg (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .clr_i      (1'b0),
        .testmode_i (1'b0),

        .valid_i    (slv_b_valid),
        .ready_o    (slv_b_ready),
        .data_i     (slv_b),

        .valid_o    (slv_b_valid_o),
        .ready_i    (slv_b_ready_i),
        .data_o     ({slv_b_id_o, slv_b_user_o, slv_b_resp_o})
    );

    // Fall-through register in front of slv_r to remove mutual dependency.
    spill_register #( // There would be a combinatorial loop if this were a fall-through register.
                      // Optimizing this can reduce the latency of this module.
        .T  (r_chan_t)
    ) slv_r_reg (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),

        .valid_i    (slv_r_valid),
        .ready_o    (slv_r_ready),
        .data_i     (slv_r),

        .valid_o    (slv_r_valid_o),
        .ready_i    (slv_r_ready_i),
        .data_o     ({slv_r_id_o, slv_r_data_o, slv_r_resp_o, slv_r_user_o, slv_r_last_o})
    );

    // AXI Reservation Table

    assign art_check_id = AXI_USER_AS_ID ?
            slv_aw_user_i[AXI_USER_ID_MSB:AXI_USER_ID_LSB]
            : slv_aw_id_i;
    assign art_set_id = AXI_USER_AS_ID ?
            slv_ar_user_i[AXI_USER_ID_MSB:AXI_USER_ID_LSB]
            : slv_ar_id_i;
    axi_res_tbl #(
        .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH-2), // Track reservations word-wise.
        .AXI_ID_WIDTH   (RES_ID_WIDTH)
    ) i_art (
        .clk_i                  (clk_i),
        .rst_ni                 (rst_ni),
        .check_clr_addr_i       (art_check_clr_addr),
        .check_id_i             (art_check_id),
        .check_clr_excl_i       (art_check_clr_excl),
        .check_res_o            (art_check_res),
        .check_clr_req_i        (art_check_clr_req),
        .check_clr_gnt_o        (art_check_clr_gnt),
        .set_addr_i             (ar_push_addr),
        .set_id_i               (art_set_id),
        .set_req_i              (art_set_req),
        .set_gnt_o              (art_set_gnt)
    );

    // Registers
    always_ff @(posedge clk_i, negedge rst_ni) begin
        if (~rst_ni) begin
            ar_state_q = AR_IDLE;
            aw_state_q = AW_IDLE;
            b_state_q  = B_NORMAL;
        end else begin
            ar_state_q = ar_state_d;
            aw_state_q = aw_state_d;
            b_state_q  = b_state_d;
        end
    end

    // Validate parameters.
// pragma translate_off
`ifndef VERILATOR
    initial begin: validate_params
        assert (ADDR_END > ADDR_BEGIN)
            else $fatal(1, "ADDR_END must be greater than ADDR_BEGIN!");
        assert (AXI_ADDR_WIDTH > 0)
            else $fatal(1, "AXI_ADDR_WIDTH must be greater than 0!");
        assert (AXI_DATA_WIDTH > 0)
            else $fatal(1, "AXI_DATA_WIDTH must be greater than 0!");
        assert (AXI_ID_WIDTH > 0)
            else $fatal(1, "AXI_ID_WIDTH must be greater than 0!");
        assert (AXI_MAX_READ_TXNS > 0)
            else $fatal(1, "AXI_MAX_READ_TXNS must be greater than 0!");
        assert (AXI_MAX_WRITE_TXNS > 0)
            else $fatal(1, "AXI_MAX_WRITE_TXNS must be greater than 0!");
        if (AXI_USER_AS_ID) begin
            assert (AXI_USER_ID_MSB >= AXI_USER_ID_LSB)
                else $fatal(1, "AXI_USER_ID_MSB must be greater equal to AXI_USER_ID_LSB!");
            assert (AXI_USER_WIDTH > AXI_USER_ID_MSB)
                else $fatal(1, "AXI_USER_WIDTH must be greater than AXI_USER_ID_MSB!");
        end
    end
`endif
// pragma translate_on

endmodule
