//
// UART 16750
//
// Authors:
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Description: This wrapper adapts the flat interface of apb_uart to
//              the Regbus interface. Note that your Regbus must have
//              a datawidth of 32 to match the IP.
//
// This code is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This code is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the
// Free Software  Foundation, Inc., 59 Temple Place, Suite 330,
// Boston, MA  02111-1307  USA
//

`include "apb/typedef.svh"

module reg_uart_wrap #(
    parameter int unsigned AddrWidth = -1,
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic
) (
  input  logic clk_i,
  input  logic rst_ni,

  // Regbus
  input  reg_req_t reg_req_i,
  output reg_rsp_t reg_rsp_o,

  // Physical interface
  output logic intr_o,
  output logic out1_no,
  output logic out2_no,
  output logic rts_no,
  output logic dtr_no,
  input  logic cts_ni,
  input  logic dsr_ni,
  input  logic dcd_ni,
  input  logic rin_ni,
  input  logic sin_i,   // RX
  output logic sout_o   // TX
);
  `APB_TYPEDEF_REQ_T(reg_uart_apb_req_t, logic [AddrWidth-1:0], logic [31:0], logic [3:0])
  `APB_TYPEDEF_RESP_T(reg_uart_apb_rsp_t, logic [31:0])

  reg_uart_apb_req_t uart_apb_req;
  reg_uart_apb_rsp_t uart_apb_rsp;

  reg_to_apb #(
    .reg_req_t  ( reg_req_t             ),
    .reg_rsp_t  ( reg_rsp_t             ),
    .apb_req_t  ( reg_uart_apb_req_t    ),
    .apb_rsp_t  ( reg_uart_apb_rsp_t    )
  ) i_reg_uart_reg_to_apb (
    .clk_i,
    .rst_ni,
    .reg_req_i,
    .reg_rsp_o,
    .apb_req_o  ( uart_apb_req          ),
    .apb_rsp_i  ( uart_apb_rsp          )
  );

  apb_uart i_apb_uart (
    .CLK      ( clk_i   ),
    .RSTN     ( rst_ni  ),
    .PSEL     ( uart_apb_req.psel        ),
    .PENABLE  ( uart_apb_req.penable     ),
    .PWRITE   ( uart_apb_req.pwrite      ),
    .PADDR    ( uart_apb_req.paddr[4:2]  ),
    .PWDATA   ( uart_apb_req.pwdata      ),
    .PRDATA   ( uart_apb_rsp.prdata      ),
    .PREADY   ( uart_apb_rsp.pready      ),
    .PSLVERR  ( uart_apb_rsp.pslverr     ),
    .INT      ( intr_o  ),
    .OUT1N    ( out1_no ),
    .OUT2N    ( out2_no ),
    .RTSN     ( rts_no  ),
    .DTRN     ( dtr_no  ),
    .CTSN     ( cts_ni  ),
    .DSRN     ( dsr_ni  ),
    .DCDN     ( dcd_ni  ),
    .RIN      ( rin_ni  ),
    .SIN      ( sin_i   ),
    .SOUT     ( sout_o  )
  );

endmodule
