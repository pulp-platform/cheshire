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
parameter type axi_mst_req_t = logic,
parameter type axi_mst_rsp_t = logic

)(  
    input rst_ni,
    input clk_i,
    input axi_mst_req_t  axi_mst_req_i,
    input axi_mst_rsp_t  axi_mst_rsp_i

    );
      
    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] w_handshake_d ;
    logic [31:0] w_handshake_q;

    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] r_handshake_d ;
    logic [31:0] r_handshake_q;

    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] w_stall_d ;
    logic [31:0] w_stall_q ;

    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] r_stall_d ;
    logic [31:0] r_stall_q ;

    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] aw_stall_d ;
    logic [31:0] aw_stall_q ;    
    
    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] ar_stall_d ;
    logic [31:0] ar_stall_q ;

    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] b_stall_d ;
    logic [31:0] b_stall_q ;        
    initial begin
      w_handshake_d = 32'b0;
      w_handshake_q = 32'b0;

      r_handshake_d = 32'b0;
      r_handshake_q = 32'b0;

      w_stall_d = 32'b0;
      w_stall_q = 32'b0;

      r_stall_d = 32'b0;
      r_stall_q = 32'b0;
      
      aw_stall_d = 32'b0;
      aw_stall_q = 32'b0;

      ar_stall_d = 32'b0;
      ar_stall_d = 32'b0;

      b_stall_d = 32'b0;
      b_stall_d = 32'b0;

    end
    
    
    always_ff @(posedge clk_i) begin
        if (axi_mst_rsp_i.r_valid & axi_mst_req_i.r_ready) begin
            r_handshake_d <= r_handshake_q + 1;
            r_handshake_q <= r_handshake_d;
        end

        if (!rst_ni)begin
            r_handshake_d <= 0;
            r_handshake_q <= 0;
        end
    end

    always_ff @(posedge clk_i) begin
        if (axi_mst_req_i.w_valid & axi_mst_rsp_i.w_ready) begin
            w_handshake_d <= w_handshake_q + 1;
            w_handshake_q <= w_handshake_d;
        end

        if (!rst_ni)begin
            w_handshake_q <= 0;
            w_handshake_d <= 0;
        end
    end    


    always_ff @(posedge clk_i) begin
        if ((axi_mst_rsp_i.r_valid && !axi_mst_req_i.r_ready)) begin
            r_stall_d <= r_stall_q + 1;
            r_stall_q <= r_stall_d;
        end

        if (!rst_ni)begin
            r_stall_q <= 0;
            r_stall_d <= 0;
        end
    end



    always_ff @(posedge clk_i) begin

        if ((axi_mst_req_i.w_valid && !axi_mst_rsp_i.w_ready)) begin
            w_stall_d <= w_stall_q + 1;
            w_stall_q <= w_stall_d;
        end

        if (!rst_ni)begin
            w_stall_q <= 0;
            w_stall_d <= 0;
        end
    end

    always_ff @(posedge clk_i) begin

        if ((axi_mst_req_i.aw_valid && !axi_mst_rsp_i.aw_ready)) begin
            aw_stall_d <= aw_stall_q + 1;
            aw_stall_q <= aw_stall_d;
        end

        if (!rst_ni)begin
            aw_stall_q <= 0;
            aw_stall_d <= 0;
        end
    end    

    always_ff @(posedge clk_i) begin

        if ((axi_mst_req_i.ar_valid && !axi_mst_rsp_i.ar_ready)) begin
            ar_stall_d <= ar_stall_q + 1;
            ar_stall_q <= ar_stall_d;
        end

        if (!rst_ni)begin
            ar_stall_q <= 0;
            ar_stall_d <= 0;
        end
    end

    always_ff @(posedge clk_i) begin

        if ((axi_mst_rsp_i.b_valid && !axi_mst_req_i.b_ready)) begin
            b_stall_d <= b_stall_q + 1;
            b_stall_q <= b_stall_d;
        end

        if (!rst_ni)begin
            b_stall_q <= 0;
            b_stall_d <= 0;
        end
    end
endmodule