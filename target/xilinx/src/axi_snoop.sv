`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
<<<<<<< HEAD
// Company: 
=======
// Company: ETH Zuerich
>>>>>>> a555d4af (stalls & handshake 32 bit)
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
    input axi_mst_rsp_t  axi_mst_rsp_i,
    output axi_mst_req_t axi_mst_req_o,
    output axi_mst_rsp_t axi_mst_rsp_o

    );
      
<<<<<<< HEAD
    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [63:0] counter_reg_q ;
    logic [63:0] counter_reg_d ;
    /*(* dont_touch = "yes" *) (* mark_debug = "true" *) logic [63:0] counter_stall_q ;
    logic [63:0] counter_stall_d ;
    */
    initial begin
      counter_reg_q = 64'b0;
      counter_reg_d = 64'b0;
      /*counter_stall_q = 64'b0;
      counter_stall_d = 64'b0;*/
    end
 
    always_ff @(posedge clk_i) begin

        if (axi_mst_req_i.aw_valid & axi_mst_rsp_i.aw_ready) begin
            counter_reg_q <= counter_reg_d + 1;
            counter_reg_d <= counter_reg_q;
=======
    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] counter_reg_q ;
    logic [31:0] counter_reg_d ;
    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] counter_stall_q ;
    logic [31:0] counter_stall_d ;
    
    initial begin
      counter_reg_q = 32'b0;
      counter_reg_d = 32'b0;
      counter_stall_q = 32'b0;
      counter_stall_d = 32'b0;
    end
    
    
    always_ff @(posedge clk_i) begin
            if (axi_mst_rsp_i.r_valid & axi_mst_req_i.r_ready) begin
                counter_reg_q <= counter_reg_d + 1;
                counter_reg_d <= counter_reg_q;
            end
       
            if (axi_mst_rsp_i.b_valid & axi_mst_req_i.b_ready) begin
                counter_reg_q <= counter_reg_d + 1;
                counter_reg_d <= counter_reg_q;
            end

            if (!rst_ni)begin
            counter_reg_d <= 0;
            counter_reg_q <= 0;
            end
    end

    always_ff @(posedge clk_i) begin
            if ((axi_mst_rsp_i.r_valid && !axi_mst_req_i.r_ready)) begin
                counter_stall_q <= counter_stall_d + 1;
                counter_stall_d <= counter_stall_q;
            end
       
            if ((axi_mst_rsp_i.b_valid && !axi_mst_req_i.b_ready)) begin
                counter_stall_q <= counter_stall_d + 1;
                counter_stall_d <= counter_stall_q;
            end

            if (!rst_ni)begin
            counter_stall_d <= 0;
            counter_stall_q <= 0;
<<<<<<< HEAD
>>>>>>> a555d4af (stalls & handshake 32 bit)
        end
    end
    always_ff @(posedge clk_i) begin
        if(rst_ni) begin
            if (axi_mst_req_i.aw_valid & axi_mst_rsp_i.aw_ready) begin
                counter_reg_q <= counter_reg_d + 1;
                counter_reg_d <= counter_reg_q;
            end
       
<<<<<<< HEAD
        if (axi_mst_rsp_i.b_valid & axi_slv_rsp_i.b_ready) begin
            counter_reg_q <= counter_reg_d + 1;
            counter_reg_d <= counter_reg_q;
        end 
=======
            if (axi_mst_rsp_i.b_valid & axi_slv_rsp_i.b_ready) begin
                counter_reg_q <= counter_reg_d + 1;
                counter_reg_d <= counter_reg_q;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if(rst_ni) begin 
            if (axi_mst_rsp_i.r_valid & !(axi_mst_req_i.r_ready)) begin
                counter_stall_q <= counter_stall_d + 1;
                counter_stall_d <= counter_stall_q;
            end
       
            if (axi_mst_rsp_i.b_valid & !(axi_mst_req_i.b_ready)) begin
                counter_stall_q <= counter_stall_d + 1;
                counter_stall_d <= counter_stall_q;
            end 
        end
>>>>>>> a555d4af (stalls & handshake 32 bit)
=======
            end
>>>>>>> faebb51c (need image)
    end

    /*always_ff @(posedge clk_i) begin

        if (axi_mst_req_i.aw_valid & !(axi_mst_rsp_i.aw_ready)) begin
            counter_stall_q <= counter_stall_d + 1;
            counter_stall_d <= counter_stall_q;
        end
       
        if (axi_mst_rsp_i.b_valid & !(axi_slv_rsp_i.b_ready)) begin
            counter_stall_q <= counter_stall_d + 1;
            counter_stall_d <= counter_stall_q;
        end 
    end
    */
    assign axi_mst_req_o = axi_mst_req_i;
    assign axi_mst_rsp_o = axi_mst_rsp_i;

endmodule
