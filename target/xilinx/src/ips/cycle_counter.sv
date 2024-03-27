`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
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

module cycle_counter #(
    
)
(
    input clk_i
);
 (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [63:0] counter_clk_cycles_q;
 logic [63:0] counter_clk_cycles_d;
 
 inital begin
    counter_clk_cycles_d = 64'b0;
    counter_clk_cycles_q = 64'b0;
 end

always_ff @(posedge clk_i) begin
    counter_clk_cycles_q <= counter_clk_cycles_d + 1;
    counter_clk_cycles_d <= counter_clk_cycles_q;
end