`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zuerich
// Engineer: Illian Gruenberg
// 
// Create Date: 03/14/2024 05:34:34 PM
// Design Name: 
// Module Name: axi_snoop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module axi_snoop #(
parameter bit enable = 1'b0,
parameter type axi_req_t = logic,
parameter type axi_rsp_t = logic

)(  
    input rst_ni,
    input clk_i,
    input axi_req_t  axi_req_i,
    input axi_rsp_t  axi_rsp_i
);

`include "common_cells/registers.svh"
    
   if(enable)begin

        // HIGHEST COUNTER VALUE = 2**26 -> probes = XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXX0_0000_0000_0000_0000_0000_0000

        ////////// HANDSHAKES //////////
        logic [63:0] r_handshake_cnt_q, r_handshake_cnt_d;
        `FF(r_handshake_cnt_q,  r_handshake_cnt_d,  '0, clk_i, rst_ni)
        assign r_handshake_cnt_d = (axi_rsp_i.r_valid && axi_req_i.r_ready) ? r_handshake_cnt_q + 1 : r_handshake_cnt_q;
        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [25:0] r_handshake_cnt;
        assign r_handshake_cnt = r_handshake_cnt_d[25:0];

        logic [63:0] w_handshake_cnt_q, w_handshake_cnt_d;
        `FF(w_handshake_cnt_q,  w_handshake_cnt_d,  '0, clk_i, rst_ni)
        assign w_handshake_cnt_d = (axi_rsp_i.r_valid && axi_req_i.r_ready) ? w_handshake_cnt_q + 1 : w_handshake_cnt_q;
        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [25:0] w_handshake_cnt;
        assign w_handshake_cnt= w_handshake_cnt_d[25:0]; 

        ////////// STALLS //////////
        logic[63:0] ar_stall_q, ar_stall_d;
        `FF(ar_stall_q,  ar_stall_d,  '0, clk_i, rst_ni)
        assign ar_stall_d = (axi_req_i.ar_valid && !axi_rsp_i.ar_ready) ? ar_stall_q + 1 : ar_stall_q;
        logic [25:0] ar_stall;
        assign ar_stall = ar_stall_q[25:0];

        logic[63:0] aw_stall_q, aw_stall_d;
        `FF(aw_stall_q,  aw_stall_d,  '0, clk_i, rst_ni)
        assign aw_stall_d = (axi_req_i.aw_valid && !axi_rsp_i.aw_ready) ? aw_stall_q + 1 : aw_stall_q;
        logic [25:0] aw_stall;
        assign aw_stall = aw_stall_q[25:0]; 

        logic [63:0] r_stall_q, r_stall_d;
        `FF(r_stall_q,  r_stall_d,  '0, clk_i, rst_ni)
        assign r_stall_d = (axi_rsp_i.r_valid && !axi_req_i.r_ready) ? r_stall_q + 1 : r_stall_q;
        logic [25:0] r_stall;
        assign r_stall = r_stall_q[25:0];

        logic [63:0] w_stall_d, w_stall_q;
        `FF(w_stall_q, w_stall_d, '0, clk_i, rst_ni)
        assign w_stall_d = (axi_req_i.w_valid && !axi_rsp_i.w_ready) ? w_stall_q + 1 : w_stall_q;

        logic [25:0] w_stall;
        assign w_stall = w_stall_q[25:0];

        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [2:0] w_byte_size, r_byte_size;
        assign w_byte_size = axi_req_i.aw.size;
        assign r_byte_size = axi_req_i.ar.size;

        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [5:0] w_atomic_logic;
        assign w_atomic_logic = axi_req_i.aw.atop;

    end
endmodule
