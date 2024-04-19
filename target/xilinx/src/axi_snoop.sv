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
parameter type axi_mst_req_t = logic,
parameter type axi_mst_rsp_t = logic

)(  
    input rst_ni,
    input clk_i,
    input axi_mst_req_t  axi_mst_req_i,
    input axi_mst_rsp_t  axi_mst_rsp_i
    );
    
    if(enable)begin


        logic [63:0] r_handshake_d ;
        logic [63:0] r_handshake_q;

        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [63:0] r_adder;
        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [63:0] w_adder;
        logic [63:0] aw_adder;
        logic [63:0] ar_adder;
        logic [63:0] b_adder;


        logic [63:0] w_handshake_d ;
        logic [63:0] w_handshake_q;

        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [43:0] r_hs_simple ;

        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [43:0] w_hs_simple;



        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [63:0] w_stall_d ;
        logic [63:0] w_stall_q ;

        (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [63:0] r_stall_d ;
        logic [63:0] r_stall_q ;

        logic [63:0] aw_stall_d ;
        logic [63:0] aw_stall_q ;    
        
        logic [63:0] ar_stall_d ;
        logic [63:0] ar_stall_q ;

        logic [63:0] b_stall_d ;
        logic [63:0] b_stall_q ;        
        
        initial begin
        r_adder = 64'b0;
        w_adder = 64'b0;
        aw_adder = 64'b0;
        ar_adder = 64'b0;
        b_adder= 64'b0;


        r_hs_simple = 44'b0;
        r_hs_simple = 44'b0;

        w_handshake_d = 64'b0;
        w_handshake_q = 64'b0;

        r_handshake_d = 64'b0;
        r_handshake_q = 64'b0;

        w_stall_d = 64'b0;
        w_stall_q = 64'b0;

        r_stall_d = 64'b0;
        r_stall_q = 64'b0;
        
        aw_stall_d = 64'b0;
        aw_stall_q = 64'b0;

        ar_stall_d = 64'b0;
        ar_stall_d = 64'b0;

        b_stall_d = 64'b0;
        b_stall_d = 64'b0;

        end
        assign r_hs_simple = r_handshake_d >> 20;
        assign w_hs_simple = w_handshake_d >> 20;


        always_comb begin
            r_adder = axi_mst_rsp_i.r.data ;
            
            w_adder = axi_mst_req_i.w.data;
            
            aw_adder = axi_mst_req_i.aw.addr;
            
            ar_adder = axi_mst_req_i.ar.addr;
            
            b_adder = axi_mst_rsp_i.b.resp;  
        end

        
        always_ff @(posedge clk_i) begin
            if (!rst_ni)begin
                r_handshake_d <= 0;
                r_handshake_q <= 0;
            end
            else if (axi_mst_rsp_i.r_valid && axi_mst_req_i.r_ready) begin
                r_handshake_d <= r_handshake_q + r_adder;
                r_handshake_q <= r_handshake_d;
            end
        end

        always_ff @(posedge clk_i) begin
            if (!rst_ni)begin
                w_handshake_q <= 0;
                w_handshake_d <= 0;
            end
            else if (axi_mst_req_i.w_valid && axi_mst_rsp_i.w_ready) begin
                w_handshake_d <= w_handshake_q + w_adder;
                w_handshake_q <= w_handshake_d;
            end
        end    


        always_ff @(posedge clk_i) begin
            if (!rst_ni)begin
                r_stall_q <= 0;
                r_stall_d <= 0;
            end
            else if ((axi_mst_rsp_i.r_valid && !axi_mst_req_i.r_ready)) begin
                r_stall_d <= r_stall_q + r_adder;
                r_stall_q <= r_stall_d;
            end
        end

        always_ff @(posedge clk_i) begin
            if (!rst_ni)begin
                w_stall_q <= 0;
                w_stall_d <= 0;
            end
            else if ((axi_mst_req_i.w_valid && !axi_mst_rsp_i.w_ready)) begin
                w_stall_d <= w_stall_q + w_adder;
                w_stall_q <= w_stall_d;
            end
        end

        always_ff @(posedge clk_i) begin
            if (!rst_ni)begin
                aw_stall_q <= 0;
                aw_stall_d <= 0;
            end
            if ((axi_mst_req_i.aw_valid && !axi_mst_rsp_i.aw_ready)) begin
                aw_stall_d <= aw_stall_q + aw_adder;
                aw_stall_q <= aw_stall_d;
            end
        end    

        always_ff @(posedge clk_i) begin
            if (!rst_ni)begin
                ar_stall_q <= 0;
                ar_stall_d <= 0;
            end
            else if ((axi_mst_req_i.ar_valid && !axi_mst_rsp_i.ar_ready)) begin
                ar_stall_d <= ar_stall_q + ar_adder;
                ar_stall_q <= ar_stall_d;
            end
        end

        always_ff @(posedge clk_i) begin
            if (!rst_ni)begin
                b_stall_q <= 0;
                b_stall_d <= 0;
            end
            else if ((axi_mst_rsp_i.b_valid && !axi_mst_req_i.b_ready)) begin
                b_stall_d <= b_stall_q + b_adder;
                b_stall_q <= b_stall_d;
            end
        end
    end
endmodule