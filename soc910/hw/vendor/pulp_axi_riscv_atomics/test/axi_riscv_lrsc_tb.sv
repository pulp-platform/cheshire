// Copyright (c) 2019 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "axi/assign.svh"

module axi_riscv_lrsc_tb #(
    // Exclusive Adapter Parameters
    parameter int unsigned AXI_ADDR_WIDTH = 8,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH = 10,
    parameter int unsigned AXI_USER_WIDTH = 4,
    parameter int unsigned ADDR_BEGIN = 8'h20,
    parameter int unsigned ADDR_END = 8'hAF,
    parameter int unsigned AXI_MAX_READ_TXNS = 16,
    parameter int unsigned AXI_MAX_WRITE_TXNS = 16,
    parameter bit DEBUG = 1'b0,
    // TB Parameters
    parameter int unsigned REQ_MIN_WAIT_CYCLES = 0,
    parameter int unsigned REQ_MAX_WAIT_CYCLES = 10,
    parameter int unsigned RESP_MIN_WAIT_CYCLES = 0,
    parameter int unsigned RESP_MAX_WAIT_CYCLES = REQ_MAX_WAIT_CYCLES/2,
    parameter int unsigned N_TXNS = 10000,
    parameter bit VERBOSE = 1'b0
);

    localparam time TCLK = 10ns;
    localparam time TA = TCLK * 1/4;
    localparam time TT = TCLK * 3/4;

    localparam int unsigned AXI_WORD_OFF = $clog2(AXI_DATA_WIDTH/8);

    typedef logic [AXI_ADDR_WIDTH-1:0]  axi_addr_t;
    typedef logic [AXI_DATA_WIDTH-1:0]  axi_data_t;
    typedef logic [AXI_ID_WIDTH-1:0]    axi_id_t;
    typedef logic [AXI_USER_WIDTH-1:0]  axi_user_t;

    logic   clk,
            rst_n;

    clk_rst_gen #(
        .ClkPeriod      (TCLK),
        .RstClkCycles   (5)
    ) i_clk_rst_gen (
        .clk_o  (clk),
        .rst_no (rst_n)
    );

    AXI_BUS_DV #(
        .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
        .AXI_ID_WIDTH   (AXI_ID_WIDTH),
        .AXI_USER_WIDTH (AXI_USER_WIDTH)
    ) upstream_dv (
        .clk_i  (clk)
    );

    AXI_BUS #(
        .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
        .AXI_ID_WIDTH   (AXI_ID_WIDTH),
        .AXI_USER_WIDTH (AXI_USER_WIDTH)
    ) upstream ();

    `AXI_ASSIGN(upstream, upstream_dv);

    AXI_BUS_DV #(
        .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
        .AXI_ID_WIDTH   (AXI_ID_WIDTH),
        .AXI_USER_WIDTH (AXI_USER_WIDTH)
    ) downstream_dv (
        .clk_i  (clk)
    );

    AXI_BUS #(
        .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
        .AXI_ID_WIDTH   (AXI_ID_WIDTH),
        .AXI_USER_WIDTH (AXI_USER_WIDTH)
    ) downstream ();

    `AXI_ASSIGN(downstream_dv, downstream);

    axi_riscv_lrsc_wrap #(
        .ADDR_BEGIN             (ADDR_BEGIN),
        .ADDR_END               (ADDR_END),
        .AXI_ADDR_WIDTH         (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH         (AXI_DATA_WIDTH),
        .AXI_ID_WIDTH           (AXI_ID_WIDTH),
        .AXI_USER_WIDTH         (AXI_USER_WIDTH),
        .AXI_MAX_READ_TXNS      (AXI_MAX_READ_TXNS),
        .AXI_MAX_WRITE_TXNS     (AXI_MAX_WRITE_TXNS),
        .DEBUG                  (DEBUG)
    ) dut (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .mst    (downstream),
        .slv    (upstream)
    );

    typedef axi_test::axi_driver #(
        .AW (AXI_ADDR_WIDTH),
        .DW (AXI_DATA_WIDTH),
        .IW (AXI_ID_WIDTH),
        .UW (AXI_USER_WIDTH),
        .TA (TA),
        .TT (TT)
    ) axi_driver_t;

    task rand_req_wait();
        rand_verif_pkg::rand_wait(REQ_MIN_WAIT_CYCLES, REQ_MAX_WAIT_CYCLES, clk);
    endtask

    task rand_resp_wait();
        rand_verif_pkg::rand_wait(RESP_MIN_WAIT_CYCLES, RESP_MAX_WAIT_CYCLES, clk);
    endtask

    // AXI Master
    import rand_id_queue_pkg::rand_id_queue;
    rand_id_queue #(
        .data_t     (axi_driver_t::ax_beat_t),
        .ID_WIDTH   (AXI_ID_WIDTH)
    ) aw_excl_queue = new;
    axi_driver_t axi_master = new(upstream_dv);
    logic mst_done = 1'b0;
    initial begin
        static axi_driver_t::r_beat_t   r_beat;
        static axi_driver_t::b_beat_t   b_beat;
        static axi_driver_t::ax_beat_t  aw_queue[$];
        static axi_driver_t::ax_beat_t  ar_excl_queue[2**AXI_ID_WIDTH-1:0][$];
        static logic [1:0]              aw_type = '0;
        static logic                    ar_done = 1'b0,
                                        aw_done = 1'b0;
        static int unsigned             r_flight_cnt = 0,
                                        w_flight_cnt = 0;
        axi_master.reset_master();
        wait (rst_n);
        @(posedge clk);
        fork
            // AR
            begin
                repeat (N_TXNS) begin
                    automatic axi_driver_t::ax_beat_t ar_beat = new;
                    rand_req_wait();
                    void'(randomize(ar_beat));
                    ar_beat.ax_len = '0; // Bursts are not supported right now.
                    ar_beat.ax_lock = $random();
                    if (ar_beat.ax_lock) begin
                        // Exclusive accesses must be aligned to the number of bytes in the transaction.
                        ar_beat.ax_addr[AXI_WORD_OFF-1:0] = '0;
                    end
                    ar_beat.ax_size = AXI_WORD_OFF;
                    axi_master.send_ar(ar_beat);
                    if (ar_beat.ax_lock) begin
                        ar_excl_queue[ar_beat.ax_id].push_back(ar_beat);
                    end
                    r_flight_cnt++;
                end
                ar_done = 1'b1;
            end
            // R
            while (!(ar_done && r_flight_cnt == 0)) begin
                rand_resp_wait();
                axi_master.recv_r(r_beat);
                if (r_beat.r_resp == axi_pkg::RESP_EXOKAY) begin
                    assert (ar_excl_queue[r_beat.r_id].size() != 0)
                        else $error("%0t: Master received R with EXOKAY on non-exclusive AR!",
                            $time);
                    aw_excl_queue.push(r_beat.r_id, ar_excl_queue[r_beat.r_id].pop_front());
                end
                if (r_beat.r_last) r_flight_cnt--;
            end
            // AW
            begin
                repeat (N_TXNS) begin
                    automatic axi_driver_t::ax_beat_t aw_beat;
                    rand_req_wait();
                    aw_type = $random();
                    if (aw_type[1] && !aw_excl_queue.empty()) begin // Follow up on exclusive AR.
                        aw_beat = new aw_excl_queue.pop();
                        aw_beat.ax_lock = aw_type[0]; // Still exclusive?
                    end else begin
                        aw_beat = new;
                        void'(randomize(aw_beat));
                        aw_beat.ax_len = '0; // Bursts are not supported right now.
                        aw_beat.ax_size = AXI_WORD_OFF;
                    end
                    axi_master.send_aw(aw_beat);
                    aw_queue.push_back(aw_beat);
                    w_flight_cnt++;
                end
                aw_done = 1'b1;
            end
            // W
            while (!(aw_done && aw_queue.size() == 0)) begin
                automatic axi_driver_t::w_beat_t w_beat = new;
                while (aw_queue.size() == 0) begin
                    @(posedge clk);
                end
                rand_req_wait();
                void'(randomize(w_beat));
                if (aw_queue[0].ax_len == '0) begin
                    w_beat.w_last = 1'b1;
                    void'(aw_queue.pop_front());
                end else begin
                    w_beat.w_last = 1'b0;
                    aw_queue[0].ax_len--;
                end
                axi_master.send_w(w_beat);
            end
            // B
            while (!(aw_done && w_flight_cnt == 0)) begin
                rand_resp_wait();
                axi_master.recv_b(b_beat);
                w_flight_cnt--;
            end
        join
        mst_done = 1'b1;
    end

    initial begin
        wait (mst_done);
        $display("Simulation completed after %0d read and write transactions.", N_TXNS);
        $finish();
    end

    function axi_data_t update_mem(
        input axi_driver_t::w_beat_t w_beat,
        axi_data_t prior_data
    );
        automatic axi_data_t data = prior_data;
        for (int unsigned i = 0; i < AXI_DATA_WIDTH/8; i++) begin
            if (w_beat.w_strb[i]) begin
                data[i*8+:8] = w_beat.w_data[i*8+:8];
            end
        end
        return data;
    endfunction

    // AXI Slave
    rand_id_queue #(
        .data_t     (axi_driver_t::ax_beat_t),
        .ID_WIDTH   (AXI_ID_WIDTH)
    ) ar_queue = new;
    rand_id_queue #(
        .data_t     (axi_driver_t::b_beat_t),
        .ID_WIDTH   (AXI_ID_WIDTH)
    ) b_queue = new;
    axi_driver_t axi_slave = new(downstream_dv);
    initial begin
        static axi_driver_t::ax_beat_t  ar_beat, ar_beat_r;
        static axi_driver_t::ax_beat_t  aw_beat, aw_beat_w;
        static axi_driver_t::w_beat_t   w_beat;
        static axi_driver_t::b_beat_t   b_beat;
        static axi_driver_t::ax_beat_t  aw_queue[$];
        static axi_data_t mem[logic[AXI_ADDR_WIDTH-AXI_WORD_OFF-1:0]] = '{default: 'x};
        static logic [AXI_ADDR_WIDTH-AXI_WORD_OFF-1:0] mem_addr;
        static axi_data_t data;
        axi_slave.reset_slave();
        wait (rst_n);
        @(posedge clk);
        fork
            // AR
            forever begin
                rand_resp_wait();
                axi_slave.recv_ar(ar_beat);
                ar_queue.push(ar_beat.ax_id, ar_beat);
            end
            // R
            forever begin
                automatic axi_driver_t::r_beat_t r_beat = new;
                while (ar_queue.empty()) begin
                    @(posedge clk);
                end
                ar_beat_r = ar_queue.peek();
                r_beat.r_id = ar_beat_r.ax_id;
                r_beat.r_data = mem[ar_beat_r.ax_addr[AXI_ADDR_WIDTH-AXI_WORD_OFF-1:0]];
                r_beat.r_resp = axi_pkg::RESP_OKAY;
                r_beat.r_user = ar_beat_r.ax_user;
                if (ar_beat_r.ax_len == 0) begin
                    r_beat.r_last = 1'b1;
                    void'(ar_queue.pop_id(ar_beat_r.ax_id));
                end else begin
                    r_beat.r_last = 1'b0;
                    ar_beat_r.ax_len--;
                    ar_beat_r.ax_addr += (2**AXI_WORD_OFF);
                    ar_queue.set(ar_beat_r.ax_id, ar_beat_r);
                end
                rand_resp_wait();
                axi_slave.send_r(r_beat);
            end
            // AW
            forever begin
                rand_resp_wait();
                axi_slave.recv_aw(aw_beat);
                aw_queue.push_back(aw_beat);
            end
            // W
            forever begin
                rand_resp_wait();
                axi_slave.recv_w(w_beat);
                while (aw_queue.size() == 0) begin
                    @(posedge clk);
                end
                aw_beat_w = aw_queue[0];
                mem_addr = aw_beat_w.ax_addr[AXI_ADDR_WIDTH-AXI_WORD_OFF-1:0];
                mem[mem_addr] = update_mem(w_beat, mem[mem_addr]);
                if (w_beat.w_last) begin
                    automatic axi_driver_t::b_beat_t b_beat_w = new;
                    void'(aw_queue.pop_front());
                    b_beat_w.b_id = aw_beat_w.ax_id;
                    b_beat_w.b_resp = axi_pkg::RESP_OKAY;
                    b_beat_w.b_user = aw_beat_w.ax_user;
                    b_queue.push(aw_beat_w.ax_id, b_beat_w);
                end else begin
                    aw_beat_w.ax_addr += (2**AXI_WORD_OFF);
                    aw_queue[0] = aw_beat_w;
                end
            end
            // B
            forever begin
                while (b_queue.empty()) begin
                    @(posedge clk);
                end
                rand_resp_wait();
                b_beat = b_queue.pop();
                axi_slave.send_b(b_beat);
            end
        join
    end

    typedef enum logic [1:0] {
        B_FORWARD, B_EXCLUSIVE, B_INJECT
    } b_cmd_t;

    typedef struct packed {
        logic excl;
    } r_cmd_t;

    typedef struct packed {
        logic       excl;
        axi_id_t    id;
        logic       thru;
        axi_user_t  user;
    } w_cmd_t;

    typedef struct packed {
        axi_addr_t  addr;
        logic       excl;
    } w_flight_t;

    // Monitor and check repsonses of AEA.
    logic downstream_b_wait_d,  downstream_b_wait_q;
    initial begin
        static logic [2**AXI_ID_WIDTH-1:0][AXI_ADDR_WIDTH-1:0] res_addr = 'x;
        static axi_driver_t::ax_beat_t  ar_transfer_queue[$],
                                        aw_transfer_queue[$];
        static b_cmd_t                  b_cmd_queues[2**AXI_ID_WIDTH-1:0][$];
        static axi_driver_t::b_beat_t   b_checkback_queues[2**AXI_ID_WIDTH-1:0][$],
                                        b_inject_queues[2**AXI_ID_WIDTH-1:0][$],
                                        b_transfer_queues[2**AXI_ID_WIDTH-1:0][$];
        static r_cmd_t                  r_cmd_queues[2**AXI_ID_WIDTH-1:0][$];
        static axi_driver_t::r_beat_t   r_transfer_queue[$];
        static w_cmd_t                  w_cmd_queue[$];
        static w_flight_t               w_flight_queues [2**AXI_ID_WIDTH-1:0][$];
        static axi_driver_t::w_beat_t   w_transfer_queue[$];
        wait (rst_n);
        forever begin
            @(posedge clk);
            #(TT);
            // Ensure that downstream never sees an `ar_lock` or an `aw_lock`.
            if (downstream.ar_valid) begin
                assert (!downstream.ar_lock);
            end
            if (downstream.aw_valid) begin
                assert (!downstream.aw_lock);
            end
            // Push upstream ARs into transfer queues and fill R command queues.
            if (upstream.ar_valid && upstream.ar_ready) begin
                automatic axi_driver_t::ax_beat_t ar_beat = new;
                automatic logic excl = 1'b0;
                ar_beat.ax_id       = upstream.ar_id;
                ar_beat.ax_addr     = upstream.ar_addr;
                ar_beat.ax_len      = upstream.ar_len;
                ar_beat.ax_size     = upstream.ar_size;
                ar_beat.ax_burst    = upstream.ar_burst;
                ar_beat.ax_lock     = upstream.ar_lock;
                ar_beat.ax_cache    = upstream.ar_cache;
                ar_beat.ax_prot     = upstream.ar_prot;
                ar_beat.ax_qos      = upstream.ar_qos;
                ar_beat.ax_region   = upstream.ar_region;
                ar_beat.ax_user     = upstream.ar_user;
                ar_transfer_queue.push_back(ar_beat);
                if (upstream.ar_addr >= ADDR_BEGIN && upstream.ar_addr <= ADDR_END &&
                    upstream.ar_lock && upstream.ar_len == 8'h00) begin
                    excl = 1'b1;
                end
                r_cmd_queues[upstream.ar_id].push_back('{excl: excl});
            end
            // Check downstream ARs and place reservations.
            if (downstream.ar_valid && downstream.ar_ready) begin
                static axi_driver_t::ax_beat_t ar_beat;
                assert (ar_transfer_queue.size() > 0) else $fatal("downstream.AR: Illegal beat!");
                ar_beat = ar_transfer_queue.pop_front();
                assert (downstream.ar_id        == ar_beat.ax_id);
                assert (downstream.ar_addr      == ar_beat.ax_addr);
                assert (downstream.ar_len       == ar_beat.ax_len);
                assert (downstream.ar_size      == ar_beat.ax_size);
                assert (downstream.ar_burst     == ar_beat.ax_burst);
                assert (downstream.ar_cache     == ar_beat.ax_cache);
                assert (downstream.ar_prot      == ar_beat.ax_prot);
                assert (downstream.ar_qos       == ar_beat.ax_qos);
                assert (downstream.ar_region    == ar_beat.ax_region);
                assert (downstream.ar_user      == ar_beat.ax_user);
                if (ar_beat.ax_lock && downstream.ar_addr >= ADDR_BEGIN &&
                    downstream.ar_addr <= ADDR_END && downstream.ar_len == 8'h00) begin
                    automatic logic w_in_flight = 1'b0;
                    // Place reservation if no write to same address in flight.
                    for (int unsigned id = 0; id < 2**AXI_ID_WIDTH; id++) begin
                        for (int unsigned i = 0; i < w_flight_queues[id].size(); i++) begin
                            if (w_flight_queues[id][i].addr == downstream.ar_addr) begin
                                w_in_flight = 1'b1;
                                break;
                            end
                        end
                        if (w_in_flight)
                            break;
                    end
                    if (!w_in_flight) begin
                        res_addr[downstream.ar_id] = downstream.ar_addr;
                    end
                end
            end
            // Push upstream AWs into transfer queue.
            if (upstream.aw_valid && upstream.aw_ready) begin
                automatic axi_driver_t::ax_beat_t aw_beat = new;
                aw_beat.ax_id       = upstream.aw_id;
                aw_beat.ax_addr     = upstream.aw_addr;
                aw_beat.ax_len      = upstream.aw_len;
                aw_beat.ax_size     = upstream.aw_size;
                aw_beat.ax_burst    = upstream.aw_burst;
                aw_beat.ax_lock     = upstream.aw_lock;
                aw_beat.ax_cache    = upstream.aw_cache;
                aw_beat.ax_prot     = upstream.aw_prot;
                aw_beat.ax_qos      = upstream.aw_qos;
                aw_beat.ax_region   = upstream.aw_region;
                aw_beat.ax_user     = upstream.aw_user;
                aw_transfer_queue.push_back(aw_beat);
            end
            if (downstream.aw_valid && downstream.aw_ready) begin
                automatic axi_driver_t::ax_beat_t exp_beat;
                automatic w_flight_t w_flight;
                forever begin
                    automatic logic done = 1'b0;
                    automatic b_cmd_t b_cmd;
                    automatic w_cmd_t w_cmd;
                    assert (aw_transfer_queue.size() > 0)
                        else $fatal("downstream.AW: Illegal beat!");
                    exp_beat = aw_transfer_queue.pop_front();
                    w_cmd.excl = exp_beat.ax_lock;
                    w_cmd.id = exp_beat.ax_id;
                    w_cmd.user = exp_beat.ax_user;
                    if (exp_beat.ax_id == downstream.aw_id &&
                        exp_beat.ax_addr == downstream.aw_addr) begin
                        // Found AW beat that was forwarded.
                        done = 1'b1;
                        if (exp_beat.ax_lock && exp_beat.ax_addr >= ADDR_BEGIN &&
                            exp_beat.ax_addr <= ADDR_END && exp_beat.ax_len == 8'h00) begin
                            b_cmd = B_EXCLUSIVE;
                        end else begin
                            b_cmd = B_FORWARD;
                        end
                        w_cmd.thru = 1'b1;
                    end else begin
                        // Found AW beat that was dropped.
                        assert (exp_beat.ax_lock) else $error("Non-exclusive AW was dropped!");
                        // TODO: Warn if exclusive AW should not have been dropped.
                        b_cmd = B_INJECT;
                        w_cmd.thru = 1'b0;
                    end
                    w_cmd_queue.push_back(w_cmd);
                    if (VERBOSE) $display("%0t: Added W cmd for ID %03x.", $time, w_cmd.id);
                    b_cmd_queues[exp_beat.ax_id].push_back(b_cmd);
                    if (done) begin
                        break;
                    end
                end
                assert (downstream.aw_addr      == exp_beat.ax_addr);
                assert (downstream.aw_len       == exp_beat.ax_len);
                assert (downstream.aw_size      == exp_beat.ax_size);
                assert (downstream.aw_burst     == exp_beat.ax_burst);
                assert (downstream.aw_cache     == exp_beat.ax_cache);
                assert (downstream.aw_prot      == exp_beat.ax_prot);
                assert (downstream.aw_qos       == exp_beat.ax_qos);
                assert (downstream.aw_region    == exp_beat.ax_region);
                assert (downstream.aw_user      == exp_beat.ax_user);
                for (int unsigned id = 0; id < 2**AXI_ID_WIDTH; id++) begin
                    // Ensure that no exclusive write to the same address is in-flight.
                    for (int unsigned i = 0; i < w_flight_queues[id].size(); i++) begin
                        if (w_flight_queues[id][i].excl) begin
                            assert (w_flight_queues[id][i].addr != downstream.aw_addr)
                                else $error("Illegal downstream AW to address to which ",
                                    "an exclusive write is in flight!");
                        end
                    end
                end
                w_flight.addr = downstream.aw_addr;
                w_flight.excl = (exp_beat.ax_lock && exp_beat.ax_addr >= ADDR_BEGIN &&
                    exp_beat.ax_addr <= ADDR_END && exp_beat.ax_len == 8'h00 &&
                    res_addr[downstream.aw_id] === downstream.aw_addr);
                w_flight_queues[downstream.aw_id].push_back(w_flight);
                for (int unsigned id = 0; id < 2**AXI_ID_WIDTH; id++) begin
                    // Clear reservations to same address.
                    if (res_addr[id] === downstream.aw_addr) begin
                        res_addr[id] = 'x;
                    end
                end
            end
            // Push downstream Rs into transfer queue.
            if (downstream.r_valid && downstream.r_ready) begin
                automatic axi_driver_t::r_beat_t r_beat = new;
                r_beat.r_id     = downstream.r_id;
                r_beat.r_data   = downstream.r_data;
                r_beat.r_resp   = downstream.r_resp;
                r_beat.r_last   = downstream.r_last;
                r_beat.r_user   = downstream.r_user;
                r_transfer_queue.push_back(r_beat);
            end
            // Check upstream Rs.
            if (upstream.r_valid && upstream.r_ready) begin
                automatic axi_driver_t::r_beat_t r_beat;
                assert (r_transfer_queue.size() > 0)
                    else $fatal("upstream.R: Illegal beat!");
                r_beat = r_transfer_queue.pop_front();
                assert (upstream.r_id   == r_beat.r_id);
                assert (upstream.r_data === r_beat.r_data);
                if (r_beat.r_resp[1]) begin
                    assert (upstream.r_resp == r_beat.r_resp);
                end else begin
                    automatic r_cmd_t r_cmd = r_cmd_queues[r_beat.r_id][0];
                    assert (upstream.r_resp == {1'b0, r_cmd.excl});
                end
                assert (upstream.r_last == r_beat.r_last);
                assert (upstream.r_user == r_beat.r_user);
                if (r_beat.r_last) begin
                    void'(r_cmd_queues[r_beat.r_id].pop_front());
                end
            end
            // Push upstream W beats into transfer queue.
            if (upstream.w_valid && upstream.w_ready) begin
                automatic axi_driver_t::w_beat_t w_beat = new;
                w_beat.w_data = upstream.w_data;
                w_beat.w_strb = upstream.w_strb;
                w_beat.w_last = upstream.w_last;
                w_beat.w_user = upstream.w_user;
                w_transfer_queue.push_back(w_beat);
            end
            // Clear dropped W beats from transfer queue.
            forever begin
                automatic w_cmd_t w_cmd;
                if (w_cmd_queue.size() == 0 || w_transfer_queue.size() == 0) begin
                    break;
                end
                w_cmd = w_cmd_queue[0];
                if (!w_cmd.thru) begin
                    forever begin
                        automatic axi_driver_t::w_beat_t w_beat;
                        if (w_transfer_queue.size() == 0) begin
                            break;
                        end
                        w_beat = w_transfer_queue.pop_front();
                        if (w_beat.w_last) begin
                            automatic axi_driver_t::b_beat_t b_beat = new;
                            b_beat.b_id = w_cmd.id;
                            b_beat.b_resp = 2'b00;
                            b_beat.b_user = w_cmd.user;
                            if (VERBOSE) $display("%0t: Added B for ID %03x to injects.", $time,
                                    b_beat.b_id);
                            b_inject_queues[b_beat.b_id].push_back(b_beat);
                            void'(w_cmd_queue.pop_front());
                            break;
                        end
                    end
                end else begin
                    break;
                end
            end
            // Ensure downstream W beats match remaining beats in the W transfer queue.
            if (downstream.w_valid && downstream.w_ready) begin
                automatic axi_driver_t::w_beat_t w_beat;
                automatic w_cmd_t w_cmd;
                assert (w_cmd_queue.size() > 0) else $fatal("downstream.W: Illegal beat!");
                w_cmd = w_cmd_queue[0];
                assert (w_cmd.thru) else $error("downstream.W: Beat should not have gone through!");
                w_beat = w_transfer_queue.pop_front();
                assert (downstream.w_data == w_beat.w_data);
                assert (downstream.w_strb == w_beat.w_strb);
                assert (downstream.w_last == w_beat.w_last);
                assert (downstream.w_user == w_beat.w_user);
                if (w_beat.w_last) begin
                    void'(w_cmd_queue.pop_front());
                end
            end
            // Push downstream B beats into transfer queues and remove write from in-flights.
            if (downstream.b_valid && !downstream_b_wait_q) begin
                automatic axi_driver_t::b_beat_t b_beat = new;
                b_beat.b_id     = downstream.b_id;
                b_beat.b_resp   = downstream.b_resp;
                b_beat.b_user   = downstream.b_user;
                b_transfer_queues[b_beat.b_id].push_back(b_beat);
                assert (w_flight_queues[downstream.b_id].size() > 0)
                    else $error("downstream.B: Unknown ID!");
                void'(w_flight_queues[downstream.b_id].pop_front());
            end
            // Push upstream B beats into checkback queues.
            if (upstream.b_valid && upstream.b_ready) begin
                automatic axi_driver_t::b_beat_t b_beat = new;
                b_beat.b_id = upstream.b_id;
                b_beat.b_user = upstream.b_user;
                b_beat.b_resp = upstream.b_resp;
                b_checkback_queues[upstream.b_id].push_back(b_beat);
            end
            // Reduce B checkback queues by decided beats.
            for (int unsigned id = 0; id < 2**AXI_ID_WIDTH; id++) begin
                if (b_checkback_queues[id].size() > 0) begin
                    automatic b_cmd_t b_cmd;
                    automatic axi_driver_t::b_beat_t act_beat, exp_beat;
                    if (b_cmd_queues[id].size() == 0) begin
                        // We do not yet know what to do with this beat, try another one.
                        continue;
                    end
                    b_cmd = b_cmd_queues[id].pop_front();
                    act_beat = b_checkback_queues[id].pop_front();
                    if (b_cmd == B_INJECT) begin
                        assert (b_inject_queues[id].size() > 0)
                            else $fatal("upstream.B: Beat for ID %0x not found in inject queue!",
                                id);
                        exp_beat = b_inject_queues[id].pop_front();
                    end else begin
                        assert (b_transfer_queues[id].size() > 0)
                            else $fatal("upstream.B: Beat for ID %0x not found in transfer queue!",
                                id);
                        exp_beat = b_transfer_queues[id].pop_front();
                    end
                    assert (act_beat.b_id == exp_beat.b_id);
                    assert (act_beat.b_user == exp_beat.b_user);
                    assert (act_beat.b_resp[1] == exp_beat.b_resp[1]);
                    if (act_beat.b_resp[1] == 1'b0) begin
                        automatic logic exp_bit = (b_cmd == B_EXCLUSIVE);
                        assert (act_beat.b_resp[0] == exp_bit)
                            else $error("upstream.B: Expected resp 0%01b for ID %0x but got %02b!",
                                exp_bit, act_beat.b_id, act_beat.b_resp);
                    end else begin
                        assert (act_beat.b_resp[0] == exp_beat.b_resp[0]);
                    end
                end
            end
        end
    end

    always_comb begin
        downstream_b_wait_d = downstream_b_wait_q;
        if (downstream.b_valid) begin
            if (downstream.b_ready) begin
                downstream_b_wait_d = 1'b0;
            end else begin
                downstream_b_wait_d = 1'b1;
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            downstream_b_wait_q <= 1'b0;
        end else begin
            downstream_b_wait_q <= downstream_b_wait_d;
        end
    end

endmodule
