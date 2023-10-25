//
// UART 16750
//
// Converted to System Verilog by Jonathan Kimmitt
// This version has been partially checked with formality but some bugs remain
// Original Author:   Sebastian Witt
// Date:     14.03.2019
// Version:  1.6
//
// History:  1.0 - Initial version
//           1.1 - THR empty interrupt register connected to RST
//           1.2 - Registered outputs
//           1.3 - Automatic flow control
//           1.4 - De-assert IIR FIFO64 when FIFO is disabled
//           1.5 - Inverted low active outputs when RST is active
//           1.6 - Converted to System Verilog
//
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

module uart_interrupt(
	input wire		CLK,
	input wire		RST,
	input wire	[3:0] 	IER,
	input wire	[4:0] 	LSR,
	input wire		THI,
	input wire		RDA,
	input wire		CTI,
	input wire		AFE,
	input wire	[3:0] 	MSR,
	output logic	[3:0] 	IIR,
	output logic		INT); // 507
/* design uart_interrupt */
/* architecture rtl */
typedef enum {FALSE,TRUE} bool_t; // 527
reg iRLSInterrupt; // 612
reg iRDAInterrupt; // 612
reg iCTIInterrupt; // 612
reg iTHRInterrupt; // 612
reg iMSRInterrupt; // 612
reg [3:0] iIIR; // 605
assign /*432*/ iRLSInterrupt = IER[2] && (((LSR[1] | LSR[2]) | LSR[3]) | LSR[4]); // 434
assign /*432*/ iRDAInterrupt = IER[0] && RDA; // 434
assign /*432*/ iCTIInterrupt = IER[0] && CTI; // 434
assign /*432*/ iTHRInterrupt = IER[1] && THI; // 434
assign /*432*/ iMSRInterrupt = IER[3] && ((((MSR[0] &&  ~ AFE) | MSR[1]) | MSR[2]) | MSR[3]); // 434

always @(posedge CLK or posedge RST)
  if ((RST ==  1'b1))
    begin
       iIIR <= 4'b0001; // 413
    end
  else
    begin
       if ((iRLSInterrupt ==  1'b1))
         begin
            iIIR <= 4'b0110; // 413
         end
       else if ((iCTIInterrupt ==  1'b1))
         begin
            iIIR <= 4'b1100; // 413
         end
       else if ((iRDAInterrupt ==  1'b1))
         begin
            iIIR <= 4'b0100; // 413
         end
       else if ((iTHRInterrupt ==  1'b1))
         begin
            iIIR <= 4'b0010; // 413
         end
       else if ((iMSRInterrupt ==  1'b1))
         begin
            iIIR <= 4'b0000; // 413
         end
       else
         begin
            iIIR <= 4'b0001; // 413
         end
    end

assign /*432*/ IIR = iIIR; // 434
assign /*432*/ INT =  ~ iIIR[0]; // 434

endmodule // uart_interrupt
