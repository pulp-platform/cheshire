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

module automatic axi_riscv_atomics_tb;

    // Constants
    parameter NUM_MASTERS    = 32;
    parameter OFFSET         = 16;
    parameter MAX_TIMEOUT    = 1000; // Cycles
    parameter USER_AS_ID     = `ifdef DEF_USER_AS_ID `DEF_USER_AS_ID `else 0 `endif; // Use the aw_user signal as the reservation ID instead of the aw_id

    parameter AXI_ADDR_WIDTH = 64;
    parameter AXI_DATA_WIDTH = 64;
    parameter AXI_ID_WIDTH_M = 8;
    parameter AXI_ID_WIDTH_S = AXI_ID_WIDTH_M + $clog2(NUM_MASTERS);
    parameter AXI_ID_WIDTH_N = USER_AS_ID ? AXI_ID_WIDTH_M : AXI_ID_WIDTH_S;
    parameter AXI_USER_WIDTH = $clog2(NUM_MASTERS);

    parameter SYS_DATA_WIDTH = 64;
    parameter SYS_OFFSET_BIT = $clog2(SYS_DATA_WIDTH/8);

    parameter MEM_ADDR_WIDTH = 18;
    parameter MEM_START_ADDR = 128'h0000_0000_0000_0000_0000_0000_0000_0000; //32'h1C00_0000;
    parameter MEM_END_ADDR   = 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF; //MEM_START_ADDR + (2**MEM_ADDR_WIDTH);

    // Signal declarations
    logic clk   = 0;
    logic rst_n = 0;

    // Generate clock
    localparam tCK = 10ns;

    initial begin : clk_gen
        #tCK;
        while (1) begin
            clk <= 1;
            #(tCK/2);
            clk <= 0;
            #(tCK/2);
        end
    end

    initial begin : rst_gen
        rst_n <= 0;
        @(posedge clk);
        #(tCK/2);
        rst_n <= 1;
    end

    initial $timeformat(-9, 2, " ns", 10);

    // Testbench status
    logic finished = 0;
    int unsigned num_errors = 0;

    // AXI bus declarations
    AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH_N ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH )
    ) axi_mem();

    AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH_S ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH )
    ) axi_iwc();

    AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH_N ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH )
    ) axi_dut();

    // Simulated clusters
    AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH_M ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH )
    ) axi_cl[NUM_MASTERS]();

    AXI_BUS_DV #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH_M ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH )
    ) axi_cl_dv[NUM_MASTERS](
        .clk_i          ( clk            )
    );

    // Monitor bus for golden model
    MONITOR_BUS_DV #(
        .ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .DATA_WIDTH ( AXI_DATA_WIDTH ),
        .ID_WIDTH   ( AXI_ID_WIDTH_N ),
        .USER_WIDTH ( AXI_USER_WIDTH )
    ) mem_monitor_dv (
        .clk_i  ( clk )
    );

    generate
        for (genvar i = 0; i < NUM_MASTERS; i++) begin
            `AXI_ASSIGN(axi_cl[i], axi_cl_dv[i]);
        end
    endgenerate

    // Multiplexer between simulated clusters and atomics adapter
    axi_mux_intf #(
        .SLV_AXI_ID_WIDTH   ( AXI_ID_WIDTH_M ),
        .MST_AXI_ID_WIDTH   ( AXI_ID_WIDTH_S ),
        .AXI_ADDR_WIDTH     ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH     ( AXI_DATA_WIDTH ),
        .AXI_USER_WIDTH     ( AXI_USER_WIDTH ),
        .NO_SLV_PORTS       ( NUM_MASTERS    ),
        .MAX_W_TRANS        ( 8              ),
        .FALL_THROUGH       ( 1'b1           ),
        .SPILL_AW           ( 1'b0           ),
        .SPILL_W            ( 1'b0           ),
        .SPILL_B            ( 1'b0           ),
        .SPILL_AR           ( 1'b0           ),
        .SPILL_R            ( 1'b0           )
    ) i_axi_mux (
        .clk_i  ( clk     ),
        .rst_ni ( rst_n   ),
        .test_i ( 1'b0    ),
        .slv    ( axi_cl  ),
        .mst    ( axi_iwc )
    );

    axi_iw_converter_intf #(
      .AXI_SLV_PORT_ID_WIDTH        ( AXI_ID_WIDTH_S    ),
      .AXI_MST_PORT_ID_WIDTH        ( AXI_ID_WIDTH_N    ),
      .AXI_SLV_PORT_MAX_UNIQ_IDS    ( 2**AXI_ID_WIDTH_S ),
      .AXI_SLV_PORT_MAX_TXNS_PER_ID ( 8                 ),
      .AXI_SLV_PORT_MAX_TXNS        ( NUM_MASTERS*8     ),
      .AXI_MST_PORT_MAX_UNIQ_IDS    ( 2**AXI_ID_WIDTH_N ),
      .AXI_MST_PORT_MAX_TXNS_PER_ID ( 8                 ),
      .AXI_ADDR_WIDTH               ( AXI_ADDR_WIDTH    ),
      .AXI_DATA_WIDTH               ( AXI_DATA_WIDTH    ),
      .AXI_USER_WIDTH               ( AXI_USER_WIDTH    )
    ) i_axi_iw_converter_intf (
      .clk_i  ( clk     ),
      .rst_ni ( rst_n   ),
      .slv    ( axi_iwc ),
      .mst    ( axi_dut )
    );

    // axi_riscv_amos_wrap #(
    axi_riscv_atomics_wrap #(
        .AXI_ADDR_WIDTH     ( AXI_ADDR_WIDTH   ),
        .AXI_DATA_WIDTH     ( AXI_DATA_WIDTH   ),
        .AXI_ID_WIDTH       ( AXI_ID_WIDTH_N   ),
        .AXI_USER_WIDTH     ( AXI_USER_WIDTH   ),
        .AXI_MAX_READ_TXNS  ( 31               ),
        .AXI_MAX_WRITE_TXNS ( 31               ),
        .AXI_USER_AS_ID     ( USER_AS_ID       ),
        .AXI_USER_ID_MSB    ( AXI_USER_WIDTH-1 ),
        .AXI_USER_ID_LSB    ( 0                ),
        .RISCV_WORD_WIDTH   ( SYS_DATA_WIDTH   ),
        .N_AXI_CUT          ( 1                )
    ) i_axi_atomic_adapter (
        .clk_i    ( clk     ),
        .rst_ni   ( rst_n   ),
        .mst      ( axi_mem ),
        .slv      ( axi_dut )
    );

    // Memory accessible over AXI bus
    axi_sim_mem_intf #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH_N ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH ),
        .APPL_DELAY     ( tCK * 1 / 4    ),
        .ACQ_DELAY      ( tCK * 3 / 4    )
    ) i_axi_sim_mem (
        .clk_i              ( clk                         ),
        .rst_ni             ( rst_n                       ),
        .axi_slv            ( axi_mem                     ),
        .mon_w_valid_o      ( mem_monitor_dv.w_valid      ),
        .mon_w_addr_o       ( mem_monitor_dv.w_addr       ),
        .mon_w_data_o       ( mem_monitor_dv.w_data       ),
        .mon_w_id_o         ( mem_monitor_dv.w_id         ),
        .mon_w_user_o       ( mem_monitor_dv.w_user       ),
        .mon_w_beat_count_o ( mem_monitor_dv.w_beat_count ),
        .mon_w_last_o       ( mem_monitor_dv.w_last       ),
        .mon_r_valid_o      ( mem_monitor_dv.r_valid      ),
        .mon_r_addr_o       ( mem_monitor_dv.r_addr       ),
        .mon_r_data_o       ( mem_monitor_dv.r_data       ),
        .mon_r_id_o         ( mem_monitor_dv.r_id         ),
        .mon_r_user_o       ( mem_monitor_dv.r_user       ),
        .mon_r_beat_count_o ( mem_monitor_dv.r_beat_count ),
        .mon_r_last_o       ( mem_monitor_dv.r_last       )
    );

    // AXI Testbench
    // AXI driver
    tb_axi_pkg::axi_access #(
        .AW( AXI_ADDR_WIDTH ),
        .DW( AXI_DATA_WIDTH ),
        .IW( AXI_ID_WIDTH_M ),
        .UW( AXI_USER_WIDTH ),
        .SW( SYS_DATA_WIDTH ),
        .TA( tCK * 1 / 4    ),
        .TT( tCK * 3 / 4    )
    ) axi_dut_master[NUM_MASTERS];

    generate
        for (genvar i = 0; i < NUM_MASTERS; i++) begin : gen_axi_access
            initial begin
                axi_dut_master[i] = new(i, axi_cl_dv[i]);
            end
        end
    endgenerate

    // Golden model
    // The `axi_sim_mem` can hold the full addressable range of memory, so let's do the same
    golden_model_pkg::golden_memory #(
        .MEM_ADDR_WIDTH( AXI_ADDR_WIDTH ),
        .MEM_DATA_WIDTH( SYS_DATA_WIDTH ),
        .AXI_ADDR_WIDTH( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH_M( AXI_ID_WIDTH_M ),
        .AXI_ID_WIDTH_S( AXI_ID_WIDTH_N ),
        .AXI_USER_WIDTH( AXI_USER_WIDTH ),
        .USER_AS_ID    ( USER_AS_ID     ),
        .APPL_DELAY    ( tCK * 1 / 4    ),
        .ACQ_DELAY     ( tCK * 3 / 4    )
    ) gold_memory = new(mem_monitor_dv);

    /*====================================================================
    =                                Main                                =
    ====================================================================*/
    initial begin : main
        // Initialize the AXI drivers
        for (int i = 0; i < NUM_MASTERS; i++) begin
            axi_dut_master[i].reset_master();
        end
        // Wait for reset
        @(posedge clk);
        wait (rst_n);
        @(posedge clk);
        // Run tests!
        test_all_amos();
        test_same_address();
        test_amo_write_consistency();
        // test_interleaving(); // Only works on old memory controller
        test_atomic_counter();
        random_amo();

        overtake_r();

        finished = 1;
    end

    /*====================================================================
    =                               Timeout                              =
    ====================================================================*/
    initial begin : timeout_block
        // Signals to check
        automatic int unsigned timeout = 0;
        automatic logic [3:0] handshake = 0;
        // Check for timeout
        @(posedge clk);
        wait (rst_n);

        fork
            while (timeout < MAX_TIMEOUT) begin
                handshake = {axi_dut.aw_valid, axi_dut.aw_ready, axi_dut.ar_valid, axi_dut.ar_ready};
                #100ns;
                @(posedge clk);
                if (handshake != {axi_dut.aw_valid, axi_dut.aw_ready, axi_dut.ar_valid, axi_dut.ar_ready}) begin
                    timeout = 0;
                end else begin
                    timeout += 1;
                end
            end
            while (!finished) begin
                #100ns;
                @(posedge clk);
            end
        join_any

        if (finished && num_errors == 0) begin
            $display("\nSUCCESS\n");
        end else if (finished) begin
            $display("\nFINISHED\n");
            if (num_errors > 0) begin
                $fatal(1, "Encountered %d errors.", num_errors);
            end else begin
                $display("All tests passed.");
            end
        end else begin
            $fatal(1, "TIMEOUT");
        end

        $stop;
    end

    /*====================================================================
    =                            Random tests                            =
    ====================================================================*/
    task automatic random_amo();

        $display("Test random atomic accesses...\n");

        // Create multiple drivers
        for (int i = 0; i < NUM_MASTERS; i++) begin
            fork
                automatic int m = i;
                begin
                    automatic logic [AXI_ADDR_WIDTH-1:0] address;
                    automatic logic [AXI_ID_WIDTH_M-1:0] id;
                    automatic logic [AXI_USER_WIDTH-1:0] user;
                    automatic logic [SYS_DATA_WIDTH-1:0] data_init;
                    automatic logic [SYS_DATA_WIDTH-1:0] data_amo;
                    automatic logic [2:0]                size;
                    automatic logic [5:0]                atop;

                    automatic logic [SYS_DATA_WIDTH-1:0] r_data;
                    automatic logic [SYS_DATA_WIDTH-1:0] exp_data;
                    automatic logic [SYS_DATA_WIDTH-1:0] act_data;
                    automatic logic [1:0]                b_resp;
                    automatic logic [1:0]                exp_b_resp;

                    // Make some non-atomic transactions
                    repeat (100) begin
                        void'(randomize(address));
                        void'(randomize(data_init));
                        void'(randomize(id));
                        void'(randomize(user));
                        size = $urandom_range(0,SYS_OFFSET_BIT);
                        create_consistent_transaction(address, size, 0);
                        // Write
                        fork
                            axi_dut_master[m].axi_write(address, data_init, size, id, user, r_data, b_resp);
                            gold_memory.write(address, data_init, size, id, user, m, exp_data, exp_b_resp);
                        join
                        assert(b_resp == exp_b_resp) else begin
                            $warning("B (0x%1x) did not match expected (0x%1x)", b_resp, exp_b_resp);
                            num_errors += 1;
                        end
                        // Read
                        fork
                            axi_dut_master[m].axi_read(address, act_data, size, id, user);
                            gold_memory.read(address, exp_data, size, id, user, m);
                        join
                        assert(act_data == exp_data) else begin
                            $warning("R (0x%x) did not match expected data (0x%x) at address 0x%x, size 0x%x", act_data, exp_data, address, size);
                            num_errors += 1;
                        end
                    end

                    repeat (500) @(posedge clk);
                    repeat (2000) begin
                        void'(randomize(address));
                        void'(randomize(data_init));
                        void'(randomize(data_amo));
                        void'(randomize(id));
                        void'(randomize(atop));
                        size = $urandom_range(0,SYS_OFFSET_BIT);

                        // Mix in some non-atomic accesses
                        if (atop[3] == 1'b1) begin
                            atop = 6'b0;
                        end
                        // Make transaction valid
                        create_consistent_transaction(address, size, atop);
                        // Execute a write with data init, a AMO with data_amo and read result
                        write_amo_read_cycle(m, address, data_init, data_amo, size, id, m, atop);
                        // Wait a random amount of cycles
                        repeat ($urandom_range(100,MAX_TIMEOUT/2)) @(posedge clk);
                    end
                end
            join_none
        end

        // Wait for all cores to finish
        wait fork;

    endtask : random_amo

    task automatic overtake_r();

        $display("Try to overtake R...\n");
        fork
            begin
                // Create writes to slow down other thread
                automatic logic [AXI_ADDR_WIDTH-1:0] address;
                automatic logic [AXI_ID_WIDTH_M-1:0] id;
                automatic logic [SYS_DATA_WIDTH-1:0] data_init;
                automatic logic [2:0]                size;
                automatic logic [SYS_DATA_WIDTH-1:0] r_data;
                automatic logic [1:0]                b_resp;

                void'(randomize(address));
                void'(randomize(data_init));
                void'(randomize(id));
                size = $urandom_range(0,SYS_OFFSET_BIT);
                create_consistent_transaction(address, size, 0);

                repeat (20000) begin
                    axi_dut_master[0].axi_write(address, data_init, size, id, 0, r_data, b_resp);
                end
            end
            begin
                // Create AMOs
                automatic logic [AXI_ADDR_WIDTH-1:0] address;
                automatic logic [AXI_ID_WIDTH_M-1:0] id;
                automatic logic [SYS_DATA_WIDTH-1:0] data_init;
                automatic logic [SYS_DATA_WIDTH-1:0] data_amo;
                automatic logic [2:0]                size;
                automatic logic [5:0]                atop = 6'b100000;

                repeat (2000) begin
                    void'(randomize(address));
                    void'(randomize(data_init));
                    void'(randomize(data_amo));
                    void'(randomize(id));
                    size = $urandom_range(0,SYS_OFFSET_BIT);

                    // Make transaction valid
                    create_consistent_transaction(address, size, atop);
                    // Execute a write with data init, a AMO with data_amo and read result
                    write_amo_read_cycle(1, address, data_init, data_amo, size, id, 1, atop);
                    // Wait a random amount of cycles
                    // repeat ($urandom_range(100,1000)) @(posedge clk);
                end
            end
        join

    endtask : overtake_r

    /*====================================================================
    =                         Hand crafted tests                         =
    ====================================================================*/
    task automatic test_all_amos();

        localparam AXI_OFFSET_BIT = $clog2(AXI_DATA_WIDTH/8);

        automatic logic [AXI_ADDR_WIDTH-1:0] address;
        automatic logic [SYS_DATA_WIDTH-1:0] data_init;
        automatic logic [SYS_DATA_WIDTH-1:0] data_amo;
        automatic logic [2:0]                size;
        automatic logic [1:0]                atomic_transaction;
        automatic logic [2:0]                atomic_operation;
        automatic logic [5:0]                atop;

        $display("Test all possible amos with a single thread...\n");

        // There are 17 AMO instructions + regular write
        for (int i = 0; i < 18; i++) begin
            // Go through all atomic operations
            atomic_operation   = i % 8;
            if (i < 8) begin
                // Atomic load
                atomic_transaction = 2'b10;
            end else if (i < 16) begin
                // Atomic store
                atomic_transaction = 2'b01;
            end else if (i == 16) begin
                // Atomic swap
                atomic_transaction = 2'b11;
                atomic_operation   = 0;
            end else if (i == 17) begin
                // Atomic swap
                atomic_transaction = 2'b0;
                atomic_operation   = 0;
            end
            atop = {atomic_transaction, 1'b0, atomic_operation};

            // Check all possible sizes
            for (int j = 2; j <= SYS_OFFSET_BIT; j++) begin
                // AMOs need to have at least 4 bytes --> start with size = 2
                size = j;

                // Test all possible alignments
                for (int k = 0; k < AXI_DATA_WIDTH/8; k = k+(2**size)) begin

                    // Test instructions with all possible signed/unsigned combinations
                    for (int l = 0; l < 4; l++) begin
                        // Find MSB (size is log2(num_bytes))
                        int unsigned msb = 2**size * 8;
                        void'(randomize(address));
                        void'(randomize(data_init));
                        void'(randomize(data_amo));
                        address[AXI_OFFSET_BIT-1:0] = k;

                        case (l)
                            0 : begin
                                // unsigned/unsigned
                                data_init[msb-1] = 1'b0;
                                data_amo[msb-1]  = 1'b0;
                            end
                            1 : begin
                                // unsigned/signed
                                data_init[msb-1] = 1'b0;
                                data_amo[msb-1]  = 1'b1;
                            end
                            2 : begin
                                // signed/unsigned
                                data_init[msb-1] = 1'b1;
                                data_amo[msb-1]  = 1'b0;
                            end
                            3 : begin
                                // signed/signed
                                data_init[msb-1] = 1'b1;
                                data_amo[msb-1]  = 1'b1;
                            end
                        endcase

                        create_consistent_transaction(address, size, atop);
                        // $display("Test: AMO=%x, Size=%x, Offset=%x, Sign=%x: %x # %x @(%x)", i, j, k, l, data_init, data_amo, address);
                        write_amo_read_cycle(0, address, data_init, data_amo, size, 0, 0, atop);

                    end
                end
            end
        end

    endtask : test_all_amos

    // Test multiple atomic accesses to the same address
    task automatic test_atomic_counter();
        // Parameters
        parameter NUM_ITERATION = 100;
        parameter COUNTER_ADDR  = 'h01002000;
        // Variables
        automatic logic [SYS_DATA_WIDTH-1:0] r_data;
        automatic logic [2:0] size = SYS_OFFSET_BIT;
        automatic logic [1:0] b_resp;

        $display("Run atomic counter...\n");

        // Initialize to zero
        axi_dut_master[0].axi_write(COUNTER_ADDR, 0, size, 0, 0, r_data, b_resp, 6'b000000);

        // Create multiple drivers
        for (int i = 0; i < NUM_MASTERS; i++) begin
            fork
                automatic int m = i;
                for (int i = 0; i < NUM_ITERATION; i++) begin
                    axi_dut_master[m].axi_write(COUNTER_ADDR, 1, size, m, m, r_data, b_resp, 6'b100000);
                end
            join_none
        end

        // Wait for all cores to finish
        wait fork;

        // Check result
        axi_dut_master[0].axi_read(COUNTER_ADDR, r_data, size, 0, 0);

        if (r_data == NUM_ITERATION*NUM_MASTERS) begin
            $display("Adder result correct: %d", r_data);
        end else begin
            $display("Adder result wrong: %d (Expected: %d)", r_data, NUM_ITERATION*NUM_MASTERS);
        end

    endtask : test_atomic_counter

    // Test if the adapter protects the atomic region correctly
    task automatic test_same_address();
        // Parameters
        parameter NUM_ITERATION = 10;
        parameter ADDRESS = 'h01004000;
        // Variables
        automatic logic [AXI_ADDR_WIDTH-1:0] address = ADDRESS; // shared by all threads
        automatic logic [SYS_DATA_WIDTH-1:0] r_data_init;
        automatic logic [1:0] b_resp_init;
        automatic logic [SYS_DATA_WIDTH-1:0] exp_data_init;
        automatic logic [1:0] exp_b_resp_init;

        $display("Test random accesses to the same memory location...\n");

        // Initialize memory with 0
        fork
            axi_dut_master[0].axi_write(address, 0, SYS_OFFSET_BIT, 1, 1, r_data_init, b_resp_init);
            gold_memory.write(address, 0, SYS_OFFSET_BIT, 1, 1, 0, exp_data_init, exp_b_resp_init);
        join

        // Spawn multiple processes accessing this address
        for (int i = 0; i < NUM_MASTERS; i++) begin
            fork
                automatic int m = i;
                automatic logic [SYS_OFFSET_BIT-1:0] addr_range;
                automatic logic [AXI_ID_WIDTH_M-1:0] id;
                automatic logic [AXI_USER_WIDTH-1:0] user;
                automatic logic [AXI_ID_WIDTH_S-1:0] s_id;
                automatic logic [SYS_DATA_WIDTH-1:0] w_data;
                automatic logic [2:0]                size = 3'b011;
                automatic logic [SYS_DATA_WIDTH-1:0] r_data;
                automatic logic [SYS_DATA_WIDTH-1:0] exp_data;
                automatic logic [1:0] b_resp;
                automatic logic [1:0] exp_b_resp;
                automatic logic [5:0] atop;
                for (int j = 0; j < NUM_ITERATION; j++) begin
                    // Randomize address but keep it in same word
                    void'(randomize(addr_range));
                    address = ADDRESS + addr_range;
                    user = m;
                    void'(randomize(id));
                    void'(randomize(w_data));
                    void'(randomize(atop));
                    void'(randomize(size));
                    size = 3'b011;
                    if (atop[3] | (&atop[5:4] & |atop[2:0])) begin
                        atop = 6'b000000;
                    end
                    create_consistent_transaction(address, size, atop);
                    fork
                        axi_dut_master[m].axi_write(address, w_data, size, id, user, r_data, b_resp, atop);
                        gold_memory.write(address, w_data, size, id, user, m, exp_data, exp_b_resp, atop);
                    join
                    assert(b_resp == exp_b_resp) else begin
                        $warning("B (0x%1x) did not match expected (0x%1x)", b_resp, exp_b_resp);
                        num_errors += 1;
                    end
                    if ((atop[5:3] == {axi_pkg::ATOP_ATOMICLOAD, axi_pkg::ATOP_LITTLE_END}) |
                        (atop[5:3] == {axi_pkg::ATOP_ATOMICSWAP, axi_pkg::ATOP_LITTLE_END})) begin
                        assert(r_data == exp_data) else begin
                            $warning("ATOP (0x%x) did not match expected data (0x%x) at address 0x%x at operation: 0x%2x", r_data, exp_data, address, atop);
                            num_errors += 1;
                        end
                    end
                end
            join_none
        end

        // Wait for all cores to finish
        wait fork;

        #1000ns;

    endtask : test_same_address

    // Test if the adapter protects the atomic region correctly
    task automatic test_amo_write_consistency();
        // Parameters
        parameter NUM_ITERATION = 200;
        parameter ADDRESS_START = 'h01004000;
        parameter ADDRESS_END   = 'h01004040;
        // Variables
        automatic logic [AXI_ADDR_WIDTH-1:0] address = ADDRESS_START; // shared by all threads
        automatic logic [SYS_DATA_WIDTH-1:0] r_data_init;
        automatic logic [1:0] b_resp_init;
        automatic logic [SYS_DATA_WIDTH-1:0] exp_data_init;
        automatic logic [1:0] exp_b_resp_init;

        $display("Test AMO and write consistency...\n");

        // Initialize memory with 0
        for (int i = 0; i < (ADDRESS_END-ADDRESS_START)/(SYS_DATA_WIDTH/8); i+=(SYS_DATA_WIDTH/8)) begin
            write_amo_read_cycle(0, ADDRESS_START+i, 0, 0, SYS_OFFSET_BIT, 0, 0, 0);
        end

        // Spawn multiple processes accessing this address
        for (int i = 0; i < NUM_MASTERS; i++) begin
            fork
                automatic int m = i;
                automatic logic [AXI_ADDR_WIDTH-1:0] address;
                automatic logic [AXI_ID_WIDTH_M-1:0] id;
                automatic logic [AXI_USER_WIDTH-1:0] user = m;
                automatic logic [SYS_DATA_WIDTH-1:0] data_init;
                automatic logic [SYS_DATA_WIDTH-1:0] data_amo;
                automatic logic [2:0]                size;
                automatic logic [5:0]                atop;
                for (int j = 0; j < NUM_ITERATION; j++) begin
                    // Randomize address but keep it in same word
                    address = $urandom_range(ADDRESS_START,ADDRESS_END);
                    void'(randomize(id));
                    void'(randomize(data_init));
                    void'(randomize(data_amo));
                    void'(randomize(atop));
                    atop = create_valid_atop();
                    // void'(randomize(size)); // Half-word not supported by LRSC yet
                    size = SYS_OFFSET_BIT;
                    create_consistent_transaction(address, size, atop);
                    write_amo_read_cycle(m, address, data_init, data_amo, size, id, user, atop);
                end
            join_none
        end

        // Wait for all cores to finish
        wait fork;

        #1000ns;

    endtask : test_amo_write_consistency

    /*====================================================================
    =                          Helper Functions                          =
    ====================================================================*/
    task automatic create_consistent_transaction(
        inout logic [AXI_ADDR_WIDTH-1:0] address,
        inout logic [2:0]                size,
        input logic [5:0]                amo
    );
        // Transaction must be single burst --> max size is system size
        if (size > SYS_OFFSET_BIT) begin
            size = SYS_OFFSET_BIT;
        end

        // AMO transactions need to be 4 bytes at least
        if ((size < 3'b010) && amo) begin
            size = 3'b010;
        end

        // Address needs to by size aligned
        if (size) begin
            // At least two bytes --> alignment necessary
            for (int i = 0; i < size; i++) begin
                address[i] = 1'b0;
            end
        end
    endtask : create_consistent_transaction

    function automatic logic [5:0] create_valid_atop();
        int random_atop = $urandom_range(0, 16);
        void'(randomize(create_valid_atop));

        if (random_atop < 8) begin
            // Store
            create_valid_atop[5:3] = 3'b010;
        end else if (random_atop < 16) begin
            // Load
            create_valid_atop[5:3] = 3'b100;
        end else begin
            create_valid_atop = 6'b110000;
        end
    endfunction : create_valid_atop

    task automatic write_amo_read_cycle(
        input int unsigned               driver,
        input logic [AXI_ADDR_WIDTH-1:0] address,
        input logic [SYS_DATA_WIDTH-1:0] data_init,
        input logic [SYS_DATA_WIDTH-1:0] data_amo,
        input logic [2:0]                size,
        input logic [AXI_ID_WIDTH_M-1:0] id,
        input logic [AXI_USER_WIDTH-1:0] user,
        input logic [5:0]                atop
    );
        automatic logic [AXI_ID_WIDTH_M-1:0] trans_id = id;
        automatic logic [SYS_DATA_WIDTH-1:0] r_data;
        automatic logic [SYS_DATA_WIDTH-1:0] exp_data;
        automatic logic [SYS_DATA_WIDTH-1:0] act_data;
        automatic logic [1:0]  b_resp;
        automatic logic [1:0]  exp_b_resp;

        // Write (Need valid memory for atop)
        if (!id) begin
            void'(randomize(trans_id));
        end
        fork
            axi_dut_master[driver].axi_write(address, data_init, size, trans_id, user, r_data, b_resp);
            gold_memory.write(address, data_init, size, trans_id, user, driver, exp_data, exp_b_resp);
        join
        // AMO
        if (!id) begin
            void'(randomize(trans_id));
        end
        fork
            // Atomic operation
            axi_dut_master[driver].axi_write(address, data_amo, size, trans_id, user, r_data, b_resp, atop);
            // Golden model
            gold_memory.write(address, data_amo, size, trans_id, user, driver, exp_data, exp_b_resp, atop);
        join
        assert(b_resp == exp_b_resp) else begin
            $warning("B (0x%1x) did not match expected (0x%1x)", b_resp, exp_b_resp);
            num_errors += 1;
        end
        if ((atop[5:3] == {axi_pkg::ATOP_ATOMICLOAD, axi_pkg::ATOP_LITTLE_END}) |
            (atop[5:3] == {axi_pkg::ATOP_ATOMICSWAP, axi_pkg::ATOP_LITTLE_END})) begin
            assert(r_data == exp_data) else begin
                $warning("ATOP (0x%x) did not match expected data (0x%x) at address 0x%x at operation: 0x%2x", r_data, exp_data, address, atop);
                num_errors += 1;
            end
        end
        // Read result
        if (!id) begin
            void'(randomize(trans_id));
        end
        fork
            begin
                @(posedge clk);
                axi_dut_master[driver].axi_read(address, act_data, size, trans_id, user);
            end
            gold_memory.read(address, exp_data, size, trans_id, user, driver);
        join
        assert(act_data == exp_data) else begin
            $warning("R (0x%x) did not match expected data (0x%x) at address 0x%x, size %x, after operation: 0x%2x (0x%x)", act_data, exp_data, address, size, atop, data_init);
            num_errors += 1;
        end
    endtask : write_amo_read_cycle
endmodule
