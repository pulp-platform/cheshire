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

/// A monitor interface for `axi_sim_mem`'s monitor ports.
interface MONITOR_BUS #(
    parameter int unsigned ADDR_WIDTH = 0,
    parameter int unsigned DATA_WIDTH = 0,
    parameter int unsigned ID_WIDTH   = 0,
    parameter int unsigned USER_WIDTH = 0
);

    typedef logic [ID_WIDTH-1:0]   id_t;
    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [USER_WIDTH-1:0] user_t;

    logic          w_valid;
    addr_t         w_addr;
    data_t         w_data;
    id_t           w_id;
    user_t         w_user;
    axi_pkg::len_t w_beat_count;
    logic          w_last;

    logic          r_valid;
    addr_t         r_addr;
    data_t         r_data;
    id_t           r_id;
    user_t         r_user;
    axi_pkg::len_t r_beat_count;
    logic          r_last;


    modport Master (
        output w_valid, w_addr, w_data, w_id, w_user, w_beat_count, w_last, r_valid,
        output r_addr, r_data, r_id, r_user, r_beat_count, r_last
    );

    modport Slave (
        input w_valid, w_addr, w_data, w_id, w_user, w_beat_count, w_last, r_valid,
        input r_addr, r_data, r_id, r_user, r_beat_count, r_last
    );
endinterface

/// A clocked monitor interface for `axi_sim_mem`'s monitor ports.
interface MONITOR_BUS_DV #(
    parameter int unsigned ADDR_WIDTH = 0,
    parameter int unsigned DATA_WIDTH = 0,
    parameter int unsigned ID_WIDTH   = 0,
    parameter int unsigned USER_WIDTH = 0
)(
    input logic clk_i
);

    typedef logic [ID_WIDTH-1:0]   id_t;
    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [USER_WIDTH-1:0] user_t;

    logic          w_valid;
    addr_t         w_addr;
    data_t         w_data;
    id_t           w_id;
    user_t         w_user;
    axi_pkg::len_t w_beat_count;
    logic          w_last;

    logic          r_valid;
    addr_t         r_addr;
    data_t         r_data;
    id_t           r_id;
    user_t         r_user;
    axi_pkg::len_t r_beat_count;
    logic          r_last;


    modport Master (
        output w_valid, w_addr, w_data, w_id, w_user, w_beat_count, w_last, r_valid,
        output r_addr, r_data, r_id, r_user, r_beat_count, r_last
    );

    modport Slave (
        input w_valid, w_addr, w_data, w_id, w_user, w_beat_count, w_last, r_valid,
        input r_addr, r_data, r_id, r_user, r_beat_count, r_last
    );
endinterface

package golden_model_pkg;

    class golden_memory #(
        parameter int unsigned MEM_ADDR_WIDTH = 20,
        parameter int unsigned MEM_DATA_WIDTH = 32,
        parameter int unsigned AXI_ADDR_WIDTH = 32,
        parameter int unsigned AXI_DATA_WIDTH = 32,
        parameter int unsigned AXI_ID_WIDTH_M = 8,
        parameter int unsigned AXI_ID_WIDTH_S = 16,
        parameter int unsigned AXI_USER_WIDTH = 0,
        parameter int unsigned USER_AS_ID = 0,
        parameter time APPL_DELAY = 1ns,
        parameter time ACQ_DELAY = 1ns
    );

        localparam int unsigned MEM_OFFSET_BITS = $clog2(MEM_DATA_WIDTH/8);
        localparam int unsigned NUM_MAST_WIDTH  = AXI_ID_WIDTH_S-AXI_ID_WIDTH_M;
        localparam int unsigned RES_ID_WIDTH    = USER_AS_ID ? AXI_USER_WIDTH : AXI_ID_WIDTH_S;

        typedef logic [MEM_ADDR_WIDTH-1:0] mem_addr_t;

        // Static variable for memory
        static logic [7:0] memory [mem_addr_t];

        // AXI Bus to actual memory (after memory AXI-buffer)
        // This bus is only read to get the same linearization
        // in both the actual memory and the golden model.
        virtual MONITOR_BUS_DV #(
          .ADDR_WIDTH(AXI_ADDR_WIDTH),
          .DATA_WIDTH(AXI_DATA_WIDTH),
          .ID_WIDTH  (AXI_ID_WIDTH_S),
          .USER_WIDTH(AXI_USER_WIDTH)
        ) monitor;

        function new(virtual MONITOR_BUS_DV #(
                .ADDR_WIDTH(AXI_ADDR_WIDTH),
                .DATA_WIDTH(AXI_DATA_WIDTH),
                .ID_WIDTH  (AXI_ID_WIDTH_S),
                .USER_WIDTH(AXI_USER_WIDTH)
            ) monitor
        );
            this.monitor = monitor;
            void'(randomize(memory));
        endfunction : new

        function automatic logic [MEM_ADDR_WIDTH-1:0] calculate_address(logic [AXI_ADDR_WIDTH-1:0] addr );
            // Crop address
            calculate_address = addr[MEM_ADDR_WIDTH-1:0];
        endfunction : calculate_address

        function automatic logic [AXI_ADDR_WIDTH-1:0] calculate_dut_address(logic [AXI_ADDR_WIDTH-1:0] addr);
            // Shift address
            calculate_dut_address = {{$clog2(AXI_DATA_WIDTH/8){1'b0}}, addr[AXI_ADDR_WIDTH-1:$clog2(AXI_DATA_WIDTH/8)]};
        endfunction : calculate_dut_address

        function automatic logic [AXI_ID_WIDTH_S-1:0] slave_id(logic [AXI_ID_WIDTH_M-1:0] master_id, logic [NUM_MAST_WIDTH-1:0] master_channel);
            slave_id = '0;
            if (AXI_ID_WIDTH_S > AXI_ID_WIDTH_M) begin
                slave_id |= (~master_channel) << AXI_ID_WIDTH_M;
            end
            slave_id[AXI_ID_WIDTH_M-1:0] = master_id;
        endfunction : slave_id

        function automatic logic [RES_ID_WIDTH-1:0] get_monitor_w_id();
            if (USER_AS_ID) begin
                get_monitor_w_id = monitor.w_user;
            end else begin
                get_monitor_w_id = monitor.w_id[RES_ID_WIDTH-1:0];
            end
        endfunction : get_monitor_w_id

        function automatic logic [RES_ID_WIDTH-1:0] get_monitor_r_id();
            if (USER_AS_ID) begin
                get_monitor_r_id = monitor.r_user;
            end else begin
                get_monitor_r_id = monitor.r_id[RES_ID_WIDTH-1:0];
            end
        endfunction : get_monitor_r_id

        /**
         * Take data that is MEM_DATA_WIDTH wide and cut it back to the specified size and optionally sign extend it
         */
        function automatic logic [MEM_DATA_WIDTH-1:0] crop_data(logic [MEM_DATA_WIDTH-1:0] data, logic [2:0] size, logic sign_ext = 0);
            int unsigned num_bytes = 2**size;
            logic sign             = data[(8*num_bytes)-1];

            if (sign && sign_ext) begin
                crop_data = '1;
            end else begin
                crop_data = '0;
            end
            // For loop necessary because SystemVerilog does not allow variable ranges
            for (int i = 0; i < num_bytes; i++) begin
                crop_data[i*8 +: 8] = data[i*8 +: 8];
            end
        endfunction : crop_data

        task set_memory(logic [MEM_ADDR_WIDTH-1:0] addr, logic [MEM_DATA_WIDTH-1:0] data, logic [2:0] size);
            int unsigned num_bytes = 2**size;
            #(APPL_DELAY)
            for (int i = 0; i < num_bytes; i++) begin
                memory[addr+i] = data[i*8 +: 8];
            end
        endtask : set_memory

        function logic [MEM_DATA_WIDTH-1:0] get_memory(logic [MEM_ADDR_WIDTH-1:0] addr, logic [2:0] size);
            int unsigned num_bytes = 2**size;
            // void'(randomize(get_memory));
            get_memory = '0;
            for (int i = 0; i < num_bytes; i++) begin
                get_memory[i*8 +: 8] = memory[addr+i];
            end
        endfunction : get_memory

        task write(
            input  logic [AXI_ADDR_WIDTH-1:0] addr,
            input  logic [MEM_DATA_WIDTH-1:0] w_data,
            input  logic [2:0]                size,
            input  logic [AXI_ID_WIDTH_M-1:0] m_id,
            input  logic [AXI_USER_WIDTH-1:0] user,
            input  logic [NUM_MAST_WIDTH-1:0] master = 0,
            output logic [MEM_DATA_WIDTH-1:0] r_data,
            output logic [1:0]                b_resp,
            input  logic [5:0]                atop = 0
        );

            automatic logic unsigned [MEM_ADDR_WIDTH-1:0] address  = calculate_address(addr);

            automatic logic unsigned [MEM_DATA_WIDTH-1:0] data_ui  = $unsigned(crop_data(w_data, size));
            automatic logic unsigned [MEM_DATA_WIDTH-1:0] data_uo  = 0;
            automatic logic   signed [MEM_DATA_WIDTH-1:0] data_si  = $signed(crop_data(w_data, size, 1));
            automatic logic   signed [MEM_DATA_WIDTH-1:0] data_so  = 0;

            automatic logic          [AXI_ID_WIDTH_S-1:0] id = slave_id(m_id, master);

            automatic logic          [RES_ID_WIDTH-1:0]   trans_id = 1;
            automatic logic          [RES_ID_WIDTH-1:0]   res_id = USER_AS_ID ? user : id;

            b_resp = axi_pkg::RESP_OKAY;

            if (atop == tb_axi_pkg::ATOP_LRSC) begin
                // LR/SC pair
                // Wait for LR
                read(addr, r_data, size, m_id, user, master);

                // Check reservation
                wait_write(addr, size, res_id, trans_id);
                if (trans_id != res_id) begin
                    // SC failed
                    b_resp = axi_pkg::RESP_OKAY;
                end else begin
                    // Success
                    set_memory(address, w_data, size);
                    b_resp = axi_pkg::RESP_EXOKAY;
                end
            end else if (atop[5:4] == axi_pkg::ATOP_NONE) begin
                // Wait for the write
                wait_b(res_id);
                set_memory(address, w_data, size);
                r_data = '0;
            end else if (atop == axi_pkg::ATOP_ATOMICSWAP) begin
                // Wait for the write to happen
                wait_b(res_id);
                // Read before writing and then update memory
                r_data = get_memory(address, size);
                set_memory(address, w_data, size);
            end else if ((atop[5:3] == {axi_pkg::ATOP_ATOMICLOAD,  axi_pkg::ATOP_LITTLE_END}) ||
                         (atop[5:3] == {axi_pkg::ATOP_ATOMICSTORE, axi_pkg::ATOP_LITTLE_END})) begin
                // Wait for the write to happen
                wait_b(res_id);
                data_uo = $unsigned(get_memory(address, size));
                data_so = $signed(crop_data(get_memory(address, size), size, 1));

                r_data  = data_uo;

                // Write result
                unique case (atop[2:0])
                    axi_pkg::ATOP_ADD : begin
                        w_data = data_uo + w_data;
                    end
                    axi_pkg::ATOP_CLR : begin
                        w_data = data_uo & (~w_data);
                    end
                    axi_pkg::ATOP_EOR : begin
                        w_data = data_uo ^ w_data;
                    end
                    axi_pkg::ATOP_SET : begin
                        w_data = data_uo | w_data;
                    end
                    axi_pkg::ATOP_SMAX: begin
                        w_data = (data_so > data_si) ? data_uo : w_data;
                    end
                    axi_pkg::ATOP_SMIN: begin
                        w_data = (data_so > data_si) ? w_data : data_uo;
                    end
                    axi_pkg::ATOP_UMAX: begin
                        w_data = (data_uo > data_ui) ? data_uo : w_data;
                    end
                    axi_pkg::ATOP_UMIN: begin
                        w_data = (data_uo > data_ui) ? w_data : data_uo;
                    end
                    default: begin
                        w_data = data_uo;
                    end
                endcase

                set_memory(address, w_data, size);

            end else begin
                b_resp = axi_pkg::RESP_SLVERR;
                r_data = '0;
            end

            r_data = crop_data(r_data, size);

        endtask : write

        task read(
            input  logic [AXI_ADDR_WIDTH-1:0] addr,
            output logic [MEM_DATA_WIDTH-1:0] r_data,
            input  logic [2:0]                size,
            input  logic [AXI_ID_WIDTH_M-1:0] id,
            input  logic [AXI_USER_WIDTH-1:0] user,
            input  logic [NUM_MAST_WIDTH-1:0] master = 0
        );
            // Calculate memory address
            automatic logic unsigned [MEM_ADDR_WIDTH-1:0] address = calculate_address(addr);
            // Wait until the transaction actually happens
            if (USER_AS_ID) begin
                wait_read(addr, size, user);
            end else begin
                wait_read(addr, size, slave_id(id, master));
            end
            // Read data from golden model
            r_data = crop_data(get_memory(address, size), size);
        endtask : read

        // Linearization Functions
        logic [RES_ID_WIDTH-1:0] default_id = 0; // Systemverilog requires a assignable default value (required to make this argument optional)
        task wait_write(
            input logic [AXI_ADDR_WIDTH-1:0] addr,
            input logic [2:0]                size,
            input logic [RES_ID_WIDTH-1:0]   id,
            inout logic [RES_ID_WIDTH-1:0]   out_id=default_id
        );
            if (out_id) begin
                // Wait for a transaction to be through the memory controller's buffers and return its ID
                forever begin
                    @(posedge monitor.clk_i);
                    #(ACQ_DELAY);
                    if (monitor.w_valid && monitor.w_addr == addr) begin
                        break;
                    end
                end
                out_id = get_monitor_w_id();
            end else begin
                // Wait for the transaction to be through the memory controller's buffers
                forever begin
                    @(posedge monitor.clk_i);
                    #(ACQ_DELAY);
                    if (monitor.w_valid && get_monitor_w_id() == id
                            && monitor.w_addr == addr) begin
                        break;
                    end
                end
            end
        endtask : wait_write

        task wait_b(
            input logic [RES_ID_WIDTH-1:0] id
        );
            // Wait for the transaction to be confirmed by the memory controller
            forever begin
                @(posedge monitor.clk_i);
                #(ACQ_DELAY);
                if (monitor.w_valid && get_monitor_w_id() == id) begin
                    break;
                end
            end
        endtask : wait_b

        task wait_read(
            input logic [AXI_ADDR_WIDTH-1:0] addr,
            input logic [2:0]                size,
            input logic [RES_ID_WIDTH-1:0]   id
        );
            // Wait for the transaction to be through the memory controller's buffers
            forever begin
                @(posedge monitor.clk_i);
                #(ACQ_DELAY);
                if (monitor.r_valid && get_monitor_r_id() == id
                        && monitor.r_addr == addr) begin
                    break;
                end
            end
        endtask : wait_read

    endclass : golden_memory
endpackage : golden_model_pkg
