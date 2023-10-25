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

module uart_receiver(
	input wire		CLK,
	input wire		RST,
	input wire		RXCLK,
	input wire		RXCLEAR,
	input wire	[1:0] 	WLS,
	input wire		STB,
	input wire		PEN,
	input wire		EPS,
	input wire		SP,
	input wire		SIN,
	output logic		PE,
	output logic		FE,
	output logic		BI,
	output logic	[7:0] 	DOUT,
	output logic		RXFINISHED); // 507
/* design uart_receiver */
/* architecture rtl */
typedef enum {FALSE,TRUE} bool_t; // 527
typedef enum logic [2:0] {IDLE,
START,
DATA,
PAR,
STOP,
MWAIT} state_type; // 674
state_type CState, NState; // 908
reg [3:0] iBaudCount; // 605
reg iBaudCountClear; // 612
reg iBaudStep; // 612
reg iBaudStepD; // 612
reg iFilterClear; // 612
reg iFSIN; // 612
reg iFStopBit; // 612
reg iParity; // 612
reg iParityReceived; // 612
reg [3:0] iDataCount; // 900
reg iDataCountInit; // 612
reg iDataCountFinish; // 612
reg iRXFinished; // 612
reg iFE; // 612
reg iBI; // 612
reg iNoStopReceived; // 612
reg [7:0] iDOUT; // 605
slib_counter #(.WIDTH(4)) RX_BRC (
	.CLK(CLK),
	.RST(RST),
	.CLEAR(iBaudCountClear),
	.LOAD( 1'b0),
	.ENABLE(RXCLK),
	.DOWN( 1'b0),
	.D(4'b0000),
	.Q(iBaudCount),
	.OVERFLOW(iBaudStep)); // 879
slib_mv_filter #(.WIDTH(4),.THRESHOLD(10)) RX_MVF (
	.CLK(CLK),
	.RST(RST),
	.SAMPLE(RXCLK),
	.CLEAR(iFilterClear),
	.D(SIN),
	.Q(iFSIN)); // 879
slib_input_filter #(.SIZE(4)) RX_IFSB (
	.CLK(CLK),
	.RST(RST),
	.CE(RXCLK),
	.D(SIN),
	.Q(iFStopBit)); // 879

always @(posedge CLK or posedge RST)
  begin
     if ((RST ==  1'b1))
       begin
          iBaudStepD <=  1'b0; // 413
       end
     else
       begin
          iBaudStepD <= iBaudStep; // 413
       end
  end

assign /*432*/ iFilterClear = iBaudStepD | iBaudCountClear; // 434

always @(iDOUT or EPS)
begin
iParity <= (((((((iDOUT[7] ^ iDOUT[6]) ^ iDOUT[5]) ^ iDOUT[4]) ^ iDOUT[3]) ^ iDOUT[2]) ^ iDOUT[1]) ^ iDOUT[0]) ^  ~ EPS; // 413

end


always @(posedge CLK or posedge RST)
  if ((RST ==  1'b1))
    begin
       iDataCount <= 0; // 413
       /* block const 263 */
       iDOUT <= (0<<7)|(0<<6)|(0<<5)|(0<<4)|(0<<3)|(0<<2)|(0<<1)|(0<<0);
    end
  else
    begin
       if ((iDataCountInit ==  1'b1))
         begin
            iDataCount <= 0; // 413
            /* block const 263 */
            iDOUT <= (0<<7)|(0<<6)|(0<<5)|(0<<4)|(0<<3)|(0<<2)|(0<<1)|(0<<0);
         end
       else
         begin
            if ((iBaudStep ==  1'b1 && iDataCountFinish ==  1'b0))
              begin
                 iDOUT[iDataCount] <= iFSIN;
                 iDataCount <= iDataCount + 1; // 413
              end
         end
    end

assign /*903*/ iDataCountFinish = (((WLS == 2'b00 && iDataCount == 5) | (WLS == 2'b01 && iDataCount == 6)) | (WLS == 2'b10 && iDataCount == 7)) | (WLS == 2'b11 && iDataCount == 8) ?  1'b1 :   1'b0; // 905

always @(posedge CLK or posedge RST)
  if ((RST ==  1'b1))
    begin
       CState <= IDLE; // 413
    end
  else
    begin
       CState <= NState; // 413
    end

always @(CState or SIN or iFSIN or iFStopBit or iBaudStep or iBaudCount or iDataCountFinish or PEN or WLS or STB)
begin
NState <= IDLE; // 413
iBaudCountClear <=  1'b0; // 413
iDataCountInit <=  1'b0; // 413
iRXFinished <=  1'b0; // 413
case (CState)
  IDLE:
    begin
  if ((SIN ==  1'b0))
          begin
      NState <= START; // 413
              end
      
iBaudCountClear <=  1'b1; // 413
    iDataCountInit <=  1'b1; // 413
      end
  
  START:
    begin
  iDataCountInit <=  1'b1; // 413
    if ((iBaudStep ==  1'b1))
          begin
      if ((iFSIN ==  1'b0))
                  begin
          NState <= DATA; // 413
                      end
          
      end
       else
      begin
      NState <= START; // 413
              end
        end
  
  DATA:
    begin
  if ((iDataCountFinish ==  1'b1))
          begin
      if ((PEN ==  1'b1))
                  begin
          NState <= PAR; // 413
                      end
           else
          begin
          NState <= STOP; // 413
                      end
                end
       else
      begin
      NState <= DATA; // 413
              end
        end
  
  PAR:
    begin
  if ((iBaudStep ==  1'b1))
          begin
      NState <= STOP; // 413
              end
       else
      begin
      NState <= PAR; // 413
              end
        end
  
  STOP:
    begin
  if ((iBaudCount[3] ==  1'b1))
          begin
      if ((iFStopBit ==  1'b0))
                  begin
          iRXFinished <=  1'b1; // 413
            NState <= MWAIT; // 413
                      end
           else
          begin
          iRXFinished <=  1'b1; // 413
            NState <= IDLE; // 413
                      end
                end
       else
      begin
      NState <= STOP; // 413
              end
        end
  
  MWAIT:
    begin
  if ((SIN ==  1'b0))
          begin
      NState <= MWAIT; // 413
              end
      
  end
  
  default:
    begin
  begin end  end
  
endcase

end


always @(posedge CLK or posedge RST)
begin
if ((RST ==  1'b1))
  begin
  PE <=  1'b0; // 413
    iParityReceived <=  1'b0; // 413
      end
  else
  begin
  if ((CState == PAR && iBaudStep ==  1'b1))
          begin
      iParityReceived <= iFSIN; // 413
              end
      
if ((PEN ==  1'b1))
          begin
      PE <=  1'b0; // 413
        if ((SP ==  1'b1))
                  begin
          if (((EPS ^ iParityReceived) ==  1'b0))
                          begin
              PE <=  1'b1; // 413
                              end
              
          end
           else
          begin
          if ((iParity != iParityReceived))
                          begin
              PE <=  1'b1; // 413
                              end
              
          end
                end
       else
      begin
      PE <=  1'b0; // 413
        iParityReceived <=  1'b0; // 413
              end
        end
  
end

assign /*903*/ iNoStopReceived = iFStopBit ==  1'b0 && (CState == STOP) ?  1'b1 :   1'b0; // 905
assign /*903*/ iBI = (iDOUT == 8'b00000000 && iParityReceived ==  1'b0) && iNoStopReceived ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iFE = iNoStopReceived ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*432*/ DOUT = iDOUT; // 434
assign /*432*/ BI = iBI; // 434
assign /*432*/ FE = iFE; // 434
assign /*432*/ RXFINISHED = iRXFinished; // 434
endmodule
