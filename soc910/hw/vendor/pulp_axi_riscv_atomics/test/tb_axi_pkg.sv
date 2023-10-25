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

import axi_pkg::*;
import axi_test::*;

package tb_axi_pkg;

    axi_pkg::atop_t ATOP_LRSC = 6'b000111;

    class axi_access #(
        parameter int  AW = 32  , // AXI address width
        parameter int  DW = 32  , // AXI data width
        parameter int  IW =  9  , // AXI ID width
        parameter int  UW =  1  , // AXI user width
        parameter int  SW = 32  , // System data width
        parameter time TA = 0ns , // Stimuli application time
        parameter time TT = 1ns   // Response acquisition time
    ) extends axi_test::axi_driver #(
        .AW( AW ),
        .DW( DW ),
        .IW( IW ),
        .UW( UW ),
        .TA( TA ),
        .TT( TT )
    );

        int unsigned RAND_DELAY = 20;
        int unsigned obj_id = 100;

        function new(
            int unsigned obj_id_in,
            virtual AXI_BUS_DV #(
                .AXI_ADDR_WIDTH(AW),
                .AXI_DATA_WIDTH(DW),
                .AXI_ID_WIDTH(IW),
                .AXI_USER_WIDTH(UW)
            ) axi
        );
            super.new(axi);
            obj_id = obj_id_in;
            $timeformat(-9, 2, " ns", 10);
            $display("%d: PARAMS %d, %d, %d, %d, %t, %t", obj_id, AW, DW, IW, UW, TA, TT);
        endfunction : new

        // Wait a random amount of cycles
        task rand_delay(int min, int max);
            repeat ($urandom_range(min, max)) begin
                @(posedge axi.clk_i);
            end
        endtask : rand_delay

        // Write over AXI
        task axi_write(
            input  logic [AW-1:0] address,
            input  logic [SW-1:0] data,
            input  logic [2:0]    size,
            input  logic [IW-1:0] id,
            input  logic [UW-1:0] user,
            output logic [DW-1:0] result,
            output logic [1:0]    b_resp,
            input  logic [5:0]    atop = 0
        );
            automatic ax_beat_t ax_beat = new;
            automatic r_beat_t  r_beat  = new;
            automatic w_beat_t  w_beat  = new;
            automatic b_beat_t  b_beat  = new;
            logic [DW-1:0]   axi_data;
            logic [DW/8-1:0] strb;
            map_sys2axi_data(address, data, size, axi_data, strb);
            // Send AW and W request
            ax_beat.ax_id    = id;
            ax_beat.ax_user  = user;
            ax_beat.ax_addr  = address;
            ax_beat.ax_size  = size;
            ax_beat.ax_burst = axi_pkg::BURST_INCR;
            w_beat.w_data    = axi_data;
            w_beat.w_strb    = strb;
            w_beat.w_last    = 1'b1;
            if (atop == ATOP_LRSC) begin
                // LRSC pair
                axi_read(address, result, size, id, user, 1'b1);
                rand_delay(0,10*RAND_DELAY);
                ax_beat.ax_atop = '0;
                ax_beat.ax_lock = 1'b1;
            end else begin
                ax_beat.ax_atop = atop;
                ax_beat.ax_lock = 1'b0;
            end
            fork
                // AW
                begin
                    rand_delay(0,RAND_DELAY);
                    send_aw(ax_beat);
                end
                // W
                begin
                    rand_delay(0,RAND_DELAY);
                    send_w(w_beat);
                end
            join

            // Wait for B response
            fork
                // B
                begin
                    rand_delay(0,RAND_DELAY);
                    recv_b(b_beat);
                    b_resp = b_beat.b_resp;
                    if (b_beat.b_id != id) begin
                        $display("%0t: %d: AXI WRITE: b_id (0x%x) did not match aw_id (0x%x)", $time, obj_id, b_beat.b_id, id);
                    end
                end
                // R response if atop
                begin
                    if (atop[axi_pkg::ATOP_R_RESP]) begin // Atomic operations with read response
                        rand_delay(0,RAND_DELAY);
                        recv_r(r_beat);
                        result = r_beat.r_data;
                        if (r_beat.r_id != id) begin
                            $display("%0t: %d: AXI WRITE: r_id (0x%x) did not match aw_id (0x%x)", $time, obj_id, r_beat.r_id, id);
                        end
                    end
                end
            join
            map_axi2sys_data(address, result, size, result);
        endtask : axi_write

        // Read over AXI
        task axi_read(
            input  logic [AW-1:0] address,
            output logic [SW-1:0] data,
            input  logic [2:0]    size,
            input  logic [IW-1:0] id,
            input  logic [UW-1:0] user,
            input  logic          lock = 1'b0
        );
            automatic ax_beat_t ax_beat = new;
            automatic r_beat_t  r_beat  = new;
            // Send AW and W request
            ax_beat.ax_id    = id;
            ax_beat.ax_user  = user;
            ax_beat.ax_addr  = address;
            ax_beat.ax_size  = size;
            ax_beat.ax_lock  = lock;
            ax_beat.ax_burst = axi_pkg::BURST_INCR;
            fork
                // AR
                begin
                    rand_delay(0,RAND_DELAY);
                    send_ar(ax_beat);
                end
                // R
                begin
                    rand_delay(0,RAND_DELAY);
                    recv_r(r_beat);
                    data = r_beat.r_data;
                    if (r_beat.r_id != id) begin
                        $display("%0t: %d: AXI READ: r_id (0x%x) did not match ar_id (0x%x)", $time, obj_id, r_beat.r_id, id);
                    end
                    if ((lock && r_beat.r_resp != axi_pkg::RESP_EXOKAY) || (!lock && r_beat.r_resp != axi_pkg::RESP_OKAY)) begin
                        $display("%0t: %d: AXI READ: r_resp was 0x%x", $time, obj_id, r_beat.r_resp);
                    end
                end
            join
            map_axi2sys_data(address, r_beat.r_data, size, data);
        endtask : axi_read

        task map_sys2axi_data(
            input  logic [AW-1:0]   address,
            input  logic [SW-1:0]   data,
            input  logic [2:0]      size,
            output logic [DW-1:0]   result,
            output logic [DW/8-1:0] strb
        );

            localparam int unsigned OFFSET_BITS = $clog2(DW/8);

            // Initialize variables
            result = 'X;
            strb   = '0;

            // Assign specific bytes
            for (int i = 0; i < 2**size; i++) begin
                int j = address[OFFSET_BITS-1:0]+i;
                result[j*8 +: 8] = data[i*8 +: 8];
                strb[j]          = 1'b1;
            end

        endtask : map_sys2axi_data

        task map_axi2sys_data(
            input  logic [AW-1:0]   address,
            input  logic [DW-1:0]   data,
            input  logic [2:0]      size,
            output logic [SW-1:0]   result
        );

            localparam int unsigned OFFSET_BITS = $clog2(DW/8);

            result = '0;

            for (int i = 0; i < 2**size; i++) begin
                int j = address[OFFSET_BITS-1:0]+i;
                result[i*8 +: 8] = data[j*8 +: 8];
            end

        endtask : map_axi2sys_data

    endclass : axi_access

endpackage : tb_axi_pkg
