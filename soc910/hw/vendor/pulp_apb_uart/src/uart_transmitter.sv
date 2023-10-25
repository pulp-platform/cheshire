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

module uart_transmitter(
	input wire		CLK,
	input wire		RST,
	input wire		TXCLK,
	input wire		TXSTART,
	input wire		CLEAR,
	input wire	[1:0] 	WLS,
	input wire		STB,
	input wire		PEN,
	input wire		EPS,
	input wire		SP,
	input wire		BC,
	input wire	[7:0] 	DIN,
	output logic		TXFINISHED,
	output logic		SOUT); // 507
/* design uart_transmitter */
/* architecture rtl */
typedef enum {FALSE,TRUE} bool_t; // 527
typedef enum logic [3:0] {IDLE,
START,
BIT0,
BIT1,
BIT2,
BIT3,
BIT4,
BIT5,
BIT6,
BIT7,
PAR,
STOP,
STOP2} state_type; // 674
state_type CState, NState; // 908
reg iTx2; // 612
reg iSout; // 612
reg iParity; // 612
reg iFinished; // 612

always @(posedge CLK or posedge RST)
  if ((RST ==  1'b1))
    begin
       CState <= IDLE; // 413
       iTx2 <=  1'b0; // 413
    end
  else
    begin
       if ((TXCLK ==  1'b1))
         begin
            if ((iTx2 ==  1'b0))
              begin
                 CState <= NState; // 413
                 iTx2 <=  1'b1; // 413
              end
            else
              begin
                 if ((((WLS == 2'b00) && (STB ==  1'b1)) && CState == STOP2))
                   begin
                      CState <= NState; // 413
                      iTx2 <=  1'b1; // 413
                   end
                 else
                   begin
                      CState <= CState; // 413
                      iTx2 <=  1'b0; // 413
                   end
              end
         end
    end

always @(CState or TXSTART or DIN or WLS or PEN or SP or EPS or STB or iParity)
  begin
     NState <= IDLE; // 413
     iSout <=  1'b1; // 413
     case (CState)
       IDLE:
         begin
            if ((TXSTART ==  1'b1))
              begin
                 NState <= START; // 413
              end
            
         end
       
       START:
         begin
            iSout <=  1'b0; // 413
            NState <= BIT0; // 413
         end
       
       BIT0:
         begin
            iSout <= DIN[0]; // 413
            NState <= BIT1; // 413
         end
       
       BIT1:
         begin
            iSout <= DIN[1]; // 413
            NState <= BIT2; // 413
         end
       
       BIT2:
         begin
            iSout <= DIN[2]; // 413
            NState <= BIT3; // 413
         end
       
       BIT3:
         begin
            iSout <= DIN[3]; // 413
            NState <= BIT4; // 413
         end
       
       BIT4:
         begin
            iSout <= DIN[4]; // 413
            if ((WLS == 2'b00))
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
                 NState <= BIT5; // 413
              end
         end
       
       BIT5:
         begin
            iSout <= DIN[5]; // 413
            if ((WLS == 2'b01))
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
                 NState <= BIT6; // 413
              end
         end
       
       BIT6:
         begin
            iSout <= DIN[6]; // 413
            if ((WLS == 2'b10))
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
                 NState <= BIT7; // 413
              end
         end
       
       BIT7:
         begin
            iSout <= DIN[7]; // 413
            if ((PEN ==  1'b1))
              begin
                 NState <= PAR; // 413
              end
            else
              begin
                 NState <= STOP; // 413
              end
         end
       
       PAR:
         begin
            if ((SP ==  1'b1))
              begin
                 if ((EPS ==  1'b1))
                   begin
                      iSout <=  1'b0; // 413
                   end
                 else
                   begin
                      iSout <=  1'b1; // 413
                   end
              end
            else
              begin
                 if ((EPS ==  1'b1))
                   begin
                      iSout <= iParity; // 413
                   end
                 else
                   begin
                      iSout <=  ~ iParity; // 413
                   end
              end
            NState <= STOP; // 413
         end
       
       STOP:
         begin
            if ((STB ==  1'b1))
              begin
                 NState <= STOP2; // 413
              end
            else
              begin
                 if ((TXSTART ==  1'b1))
                   begin
                      NState <= START; // 413
                   end
                 
              end
         end
       
  STOP2:
    begin
       if ((TXSTART ==  1'b1))
         begin
            NState <= START; // 413
         end
       
    end
       
       default:
         begin
            begin end  end
       
     endcase
     
  end
   
    // Parity generation
    always @ (DIN or WLS)
    begin:TX_PAR
        logic iP40, iP50, iP60, iP70;
        iP40 = DIN[4] ^ DIN[3] ^ DIN[2] ^ DIN[1] ^ DIN[0];
        iP50 = DIN[5] ^ iP40;
        iP60 = DIN[6] ^ iP50;
        iP70 = DIN[7] ^ iP60;

        case(WLS)
            2'b00: iParity <= iP40;
            2'b01: iParity <= iP50;
            2'b10: iParity <= iP60;
            default: iParity <= iP70;
        endcase;
    end

    reg iLast;
    always @(posedge CLK or posedge RST)
    begin:TX_FIN
        if (RST)
          begin
             iFinished <= 1'b0;
             iLast <= 1'b0;
          end
        else
          begin
             iFinished <= 1'b0;
             if (iLast == 1'b0 && CState == STOP)
               iFinished <= 1'b1;
             if (CState == STOP)
               iLast <= 1'b1;
             else
               iLast <= 1'b0;
          end
    end

assign /*903*/ SOUT = BC ==  1'b0 ? iSout :   1'b0; // 905
assign /*432*/ TXFINISHED = iFinished; // 434

endmodule // uart_transmitter
