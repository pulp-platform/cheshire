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

module slib_fifo # (parameter WIDTH = 8, parameter SIZE_E=6) (
	input wire		CLK,
	input wire		RST,
	input wire		CLEAR,
	input wire		WRITE,
	input wire		READ,
	input wire	[WIDTH - 1:0] 	D,
	output logic	[WIDTH - 1:0] 	Q,
	output logic		EMPTY,
	output logic		FULL,
	output logic	[SIZE_E - 1:0] 	USAGE); // 507
/* design slib_fifo */
/* architecture rtl */
typedef enum {FALSE,TRUE} bool_t; // 527
reg iEMPTY; // 612
reg iFULL; // 612
reg [SIZE_E:0] iWRAddr; // 605
reg [SIZE_E:0] iRDAddr; // 605
reg [SIZE_E:0] init; // 605
reg [SIZE_E - 1:0] iUSAGE; // 605
reg [WIDTH-1:0] iFIFOMem [0:2**SIZE_E-1];
   
assign /*903*/ iFULL = (iRDAddr[SIZE_E - 1:0]  == iWRAddr[SIZE_E - 1:0] ) && (iRDAddr[SIZE_E] != iWRAddr[SIZE_E]) ?  1'b1 :   1'b0; // 905

always @(posedge CLK or posedge RST)
begin
if ((RST ==  1'b1))
  begin
  /* block const 263 */
iWRAddr <= 0;
/* block const 263 */
iRDAddr <= 0;
iEMPTY <=  1'b1; // 413
      end
  else
  begin
  if ((WRITE ==  1'b1 && iFULL ==  1'b0))
          begin
      iWRAddr <= iWRAddr + 1; // 413
              end
      
if ((READ ==  1'b1 && iEMPTY ==  1'b0))
          begin
      iRDAddr <= iRDAddr + 1; // 413
              end
      
if ((CLEAR ==  1'b1))
          begin
      /* block const 263 */
iWRAddr <= 0;
/* block const 263 */
iRDAddr <= 0;
      end
      
if ((iRDAddr == iWRAddr))
          begin
      iEMPTY <=  1'b1; // 413
              end
       else
      begin
      iEMPTY <=  1'b0; // 413
              end
        end
  
end


always @(posedge CLK or posedge RST)
begin
if ((RST ==  1'b1))
  begin
  /* block const 263 */
     for (init = 0; init < 2**SIZE_E; init++)
       iFIFOMem[init[SIZE_E-1:0]] <= 0;
     Q <= (0<<0);
  end
  else
  begin
  if ((WRITE ==  1'b1 && iFULL ==  1'b0))
    begin
       iFIFOMem[iWRAddr[SIZE_E-1:0]] <= D;
    end
      
Q <= iFIFOMem[iRDAddr[SIZE_E - 1:0]]; // 413
      end
  
end


always @(posedge CLK or posedge RST)
begin
if ((RST ==  1'b1))
  begin
  /* block const 263 */
iUSAGE <= 0;
  end
  else
  begin
  if ((CLEAR ==  1'b1))
          begin
      /* block const 263 */
iUSAGE <= 0;
      end
       else
      begin
      if (((READ ==  1'b0 && WRITE ==  1'b1) && iFULL ==  1'b0))
                  begin
          iUSAGE <= iUSAGE + 1; // 413
                      end
          
if (((WRITE ==  1'b0 && READ ==  1'b1) && iEMPTY ==  1'b0))
                  begin
          iUSAGE <= iUSAGE - 1; // 413
                      end
          
      end
        end
  
end

assign /*432*/ EMPTY = iEMPTY; // 434
assign /*432*/ FULL = iFULL; // 434
assign /*432*/ USAGE = iUSAGE; // 434

endmodule // slib_fifo
