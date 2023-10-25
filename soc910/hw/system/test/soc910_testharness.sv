// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nils Wistoff <nwistoff@iis.ee.ethz.ch>

module soc910_testharness import soc910_pkg::*; (
  input logic clk_i,
  input logic rst_ni
);

logic rx, tx;

axi_slave_req_t  axi_soc910_mem_req;
axi_slave_resp_t axi_soc910_mem_resp;

logic jtag_TCK;
logic jtag_TMS;
logic jtag_TDI;
logic jtag_TRSTn;
logic jtag_TDO_data;
logic jtag_TDO_driven;

// ---------------
// SoC910
// ---------------
soc910 i_soc910 (
  .clk_i           ( clk_i               ),
  .rst_ni          ( rst_ni              ),
  .axi_dram_req_o  ( axi_soc910_mem_req  ),
  .axi_dram_resp_i ( axi_soc910_mem_resp ),
  .axi_debug_req_i  ( '0                 ),
  .axi_debug_resp_o (                    ),
  .tck             ( jtag_TCK            ),
  .tms             ( jtag_TMS            ),
  .tdi             ( jtag_TDI            ),
  .tdo             ( jtag_TDO_data       ),
  .tdo_en          ( jtag_TDO_driven     ),
  .rx              ( rx                  ),
  .tx              ( tx                  )
);

// ---------------
// UART
// ---------------
uart_bus #(
  .BAUD_RATE(115200),
  .PARITY_EN(0)
) i_uart_bus (
  .rx(tx),
  .tx(rx),
  .rx_en(1'b1)
);

// ----------------
// JTAG
// ----------------
// SiFive's SimJTAG Module
// Converts to DPI calls
SimJTAG i_SimJTAG (
  .clock                ( clk_i           ),
  .reset                ( ~rst_ni         ),
  .enable               ( 1'b1            ),
  .init_done            ( rst_ni          ),
  .jtag_TCK             ( jtag_TCK        ),
  .jtag_TMS             ( jtag_TMS        ),
  .jtag_TDI             ( jtag_TDI        ),
  .jtag_TRSTn           ( jtag_TRSTn      ),
  .jtag_TDO_data        ( jtag_TDO_data   ),
  .jtag_TDO_driven      ( jtag_TDO_driven ),
  .exit                 (                 )
);

// ---------------
// DDR
// ---------------
logic                        mem_req;
logic                        mem_gnt;
logic [AxiAddrWidth-1:0]     mem_addr;
logic [AxiDataWidth-1:0]     mem_wdata;
logic [(AxiDataWidth/8)-1:0] mem_strb;
logic                        mem_we;
logic                        mem_rvalid;
logic [AxiDataWidth-1:0]     mem_rdata;

axi_to_mem #(
  .axi_req_t  ( axi_slave_req_t  ),
  .axi_resp_t ( axi_slave_resp_t ),
  .AddrWidth  ( AxiAddrWidth     ),
  .DataWidth  ( AxiDataWidth     ),
  .IdWidth    ( AxiIdWidthSlaves ),
  .NumBanks   ( 1                ),
  .BufDepth   ( 1                ),
  .HideStrb   ( 1'b0             )
) i_axi_to_mem (
  .clk_i        ( clk_i               ),
  .rst_ni       ( rst_ni              ),
  .busy_o       (                     ),
  .axi_req_i    ( axi_soc910_mem_req  ),
  .axi_resp_o   ( axi_soc910_mem_resp ),
  .mem_req_o    ( mem_req             ),
  .mem_gnt_i    ( mem_gnt             ),
  .mem_addr_o   ( mem_addr            ),
  .mem_wdata_o  ( mem_wdata           ),
  .mem_strb_o   ( mem_strb            ),
  .mem_atop_o   (                     ),
  .mem_we_o     ( mem_we              ),
  .mem_rvalid_i ( mem_rvalid          ),
  .mem_rdata_i  ( mem_rdata           )
);

localparam int unsigned NumWords = 2**20;

tc_sram #(
  .NumWords     ( NumWords     ),
  .DataWidth    ( AxiDataWidth ),
  .ByteWidth    ( 32'd8        ),
  .NumPorts     ( 32'd1        ),
  .Latency      ( 32'd1        ),
  .SimInit      ( "none"       ),
  .PrintSimCfg  ( 1'b0         ),
  .ImplKey      ( "none"       )
) i_tc_sram (
  .clk_i        ( clk_i     ),
  .rst_ni       ( rst_ni    ),
  .req_i        ( mem_req   ),
  .we_i         ( mem_we    ),
  .addr_i       ( mem_addr[$clog2(NumWords)-1:0] ),
  .wdata_i      ( mem_wdata ),
  .be_i         ( mem_strb  ),
  .rdata_o      ( mem_rdata )
);

endmodule
