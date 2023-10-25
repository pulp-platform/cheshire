//
// UART 16750
//
// Author: Paul Scheffler <paulsc@iis.ee.ethz.ch>
//
// Description: This wrapper adapts the flat interface of apb_uart to
//              an interface using passed structs for APB and port
//              names aligned with our style guide. Note that your
//              APB must have a datawidth of 32 to match the IP.
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

module apb_uart_wrap #(
    parameter type apb_req_t = logic,
    parameter type apb_rsp_t = logic
) (
  input  logic clk_i,
  input  logic rst_ni,

  // APB
  input  apb_req_t apb_req_i,
  output apb_rsp_t apb_rsp_o,

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

  apb_uart i_apb_uart (
    .CLK      ( clk_i   ),
    .RSTN     ( rst_ni  ),
    .PSEL     ( apb_req_i.psel        ),
    .PENABLE  ( apb_req_i.penable     ),
    .PWRITE   ( apb_req_i.pwrite      ),
    .PADDR    ( apb_req_i.paddr[4:2]  ),
    .PWDATA   ( apb_req_i.pwdata      ),
    .PRDATA   ( apb_rsp_o.prdata      ),
    .PREADY   ( apb_rsp_o.pready      ),
    .PSLVERR  ( apb_rsp_o.pslverr     ),
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
