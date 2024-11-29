// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Testbench module for the direct SystemVerilog NewUSB OHCI.
/// The config port from new_usb_ohci is setup as a 32b Regbus slave, the DMA port as an AXI Lite master.
/// The regbus slave is attached to a regbus driver to simulate the system master.
/// The AXI Lite master (via a converter now a AXI4 master) is attached to the testbench memory axi_sim_mem, which loads .mem.

`timescale 1ps/1ps

module new_usb_tb #(
  /// DMA manager port parameters
  parameter int unsigned AxiMaxReads   = 0,
  parameter int unsigned AxiAddrWidth  = 32,
  parameter int unsigned AxiDataWidth  = 32, // 32|64|128 causes 4|2|1 stages in the dmaoutputqueueED
  parameter int unsigned AxiIdWidth    = 0,
  parameter int unsigned AxiUserWidth  = 0,
  /// Default User and ID presented on DMA manager AR, AW, W channels.
  /// In most systems, these can or should be left at '0.
  parameter logic [AxiIdWidth-1:0]    AxiId    = '0,
  parameter logic [AxiUserWidth-1:0]  AxiUser  = '0,
  /// SoC interface types
  parameter type reg_req_t = logic,
  parameter type reg_rsp_t = logic,
  parameter type axi_req_t = logic,
  parameter type axi_rsp_t = logic
) (
  /// SoC clock and reset
  // input  logic soc_clk_i,
  // input  logic soc_rst_ni,
);



logic [AxiAddrWidth-1:0] address;
logic [31:0] dword [3:0];
reg [7:0] mem [logic [AxiAddrWidth-1:0]];
integer file, status, i, j;
string line;

initial begin
    
    file = $fopen("../../../hw/newusb_tb/new_usb_tb.mem", "r");
    if (file == 0) begin
      $display("Failed to open file.");
      $finish;
    end

    while (!$feof(file)) begin
        // Read a line
        status = $fgets(line, file);

        // Skip empty lines or lines that start with "/"
        if (line[0] == "/" || line[0] == "\n" || line[0] == " " || line[0] == "\0") begin
            // $display("comment line");
            continue;
        end
        // Try to parse the address and data
        status = $sscanf(line, "@%h %h %h %h %h", address, dword[0], dword[1], dword[2], dword[3]);
        
        if (status == 5) begin  // Successfully read 5 values
            for (i = 0; i < 4; i++) begin
                mem[address + i * 4 + 0] = dword[i][7:0];    // LSB to lowest address
                mem[address + i * 4 + 1] = dword[i][15:8];   
                mem[address + i * 4 + 2] = dword[i][23:16];  
                mem[address + i * 4 + 3] = dword[i][31:24];  // MSB to highest address
                $display("Written into mem: @%h %h", address + i*4, dword[i]);
            end
        end 
        else begin
            $display("Invalid data format in line: %s", line);
        end

        if ($feof(file)) begin
            break;
        end
    end

    $fclose(file);
    #1000;
    $finish;
end


// axi_sim_mem #(
//   
// ) i_axi_sim_mem (
// 
// );
// 
// 
// //Todo:regbusdriver
// 
// 
// new_usb_ohci #(
//   /// DMA manager port parameters
//   .AxiMaxReads,
//   .AxiAddrWidth,
//   .AxiDataWidth, // 32|64|128 causes 4|2|1 stages in the dmaoutputqueueED
//   .AxiIdWidth,
//   .AxiUserWidth,
//   /// Default User and ID presented on DMA manager AR, AW, W channels.
//   /// In most systems, these can or should be left at '0.
//   .AxiId,
//   .AxiUser,
//   /// SoC interface types
//   .reg_req_t(),
//   .reg_rsp_t(),
//   .axi_req_t(),
//   .axi_rsp_t()
// ) i_new_usb_ohci (
//   /// SoC clock and reset
//   .soc_clk_i(),
//   .soc_rst_ni(),
//   /// Control subordinate port
//   .ctrl_req_i(),
//   .ctrl_rsp_o(),
//   /// DMA manager port
//   .dma_req_o(),
//   .dma_rsp_i(),
//   /// Interrupt
//   .intr_o(),
//   /// PHY clock and reset
//   .phy_clk_i(),
//   .phy_rst_ni(),
//   /// PHY IO
//   .phy_dm_i(),
//   .phy_dm_o(),
//   .phy_dm_oe_o(),
//   .phy_dp_i(),
//   .phy_dp_o(),
//   .phy_dp_oe_o()
// );



endmodule
