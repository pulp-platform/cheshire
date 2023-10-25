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

module apb_uart(
	input wire		CLK,
	input wire		RSTN,
	input wire		PSEL,
	input wire		PENABLE,
	input wire		PWRITE,
	input wire	[2:0] 	PADDR,
	input wire	[31:0] 	PWDATA,
	output logic	[31:0] 	PRDATA,
	output logic		PREADY,
	output logic		PSLVERR,
	output logic		INT,
	output logic		OUT1N,
	output logic		OUT2N,
	output logic		RTSN,
	output logic		DTRN,
	input wire		CTSN,
	input wire		DSRN,
	input wire		DCDN,
	input wire		RIN,
	input wire		SIN,
	output logic		SOUT); // 507
/* design apb_uart */
/* architecture rtl */
typedef enum {FALSE,TRUE} bool_t; // 527
// Declare component uart_transmitter; // 950
// Declare component uart_receiver; // 950
// Declare component uart_interrupt; // 950
// Declare component uart_baudgen; // 950
// Declare component slib_edge_detect; // 950
// Declare component slib_input_sync; // 950
reg iWrite; // 612
reg iRead; // 612
reg iRST; // 612
reg iRBRRead; // 612
reg iTHRWrite; // 612
reg iDLLWrite; // 612
reg iDLMWrite; // 612
reg iIERWrite; // 612
reg iIIRRead; // 612
reg iFCRWrite; // 612
reg iLCRWrite; // 612
reg iMCRWrite; // 612
reg iLSRRead; // 612
reg iMSRRead; // 612
reg iSCRWrite; // 612
reg [7:0] iTSR; // 605
reg [7:0] iRBR; // 605
reg [7:0] iDLL; // 605
reg [7:0] iDLM; // 605
reg [7:0] iIER; // 605
reg [7:0] iIIR; // 605
reg [7:0] iFCR; // 605
reg [7:0] iLCR; // 605
reg [7:0] iMCR; // 605
reg [7:0] iLSR; // 605
reg [7:0] iMSR; // 605
reg [7:0] iSCR; // 605
reg iIER_ERBI; // 612
reg iIER_ETBEI; // 612
reg iIER_ELSI; // 612
reg iIER_EDSSI; // 612
reg iIIR_PI; // 612
reg iIIR_ID0; // 612
reg iIIR_ID1; // 612
reg iIIR_ID2; // 612
reg iIIR_FIFO64; // 612
reg iFCR_FIFOEnable; // 612
reg iFCR_RXFIFOReset; // 612
reg iFCR_TXFIFOReset; // 612
reg iFCR_DMAMode; // 612
reg iFCR_FIFO64E; // 612
reg [1:0] iFCR_RXTrigger; // 605
reg [1:0] iLCR_WLS; // 605
reg iLCR_STB; // 612
reg iLCR_PEN; // 612
reg iLCR_EPS; // 612
reg iLCR_SP; // 612
reg iLCR_BC; // 612
reg iLCR_DLAB; // 612
reg iMCR_DTR; // 612
reg iMCR_RTS; // 612
reg iMCR_OUT1; // 612
reg iMCR_OUT2; // 612
reg iMCR_LOOP; // 612
reg iMCR_AFE; // 612
reg iLSR_DR; // 612
reg iLSR_OE; // 612
reg iLSR_PE; // 612
reg iLSR_FE; // 612
reg iLSR_BI; // 612
reg iLSR_THRE; // 612
reg iLSR_THRNF; // 612
reg iLSR_TEMT; // 612
reg iLSR_FIFOERR; // 612
reg iMSR_dCTS; // 612
reg iMSR_dDSR; // 612
reg iMSR_TERI; // 612
reg iMSR_dDCD; // 612
reg iMSR_CTS; // 612
reg iMSR_DSR; // 612
reg iMSR_RI; // 612
reg iMSR_DCD; // 612
reg iCTSNs; // 612
reg iDSRNs; // 612
reg iDCDNs; // 612
reg iRINs; // 612
reg iCTSn; // 612
reg iDSRn; // 612
reg iDCDn; // 612
reg iRIn; // 612
reg iCTSnRE; // 612
reg iCTSnFE; // 612
reg iDSRnRE; // 612
reg iDSRnFE; // 612
reg iDCDnRE; // 612
reg iDCDnFE; // 612
reg iRInRE; // 612
reg iRInFE; // 612
reg [15:0] iBaudgenDiv; // 605
reg iBaudtick16x; // 612
reg iBaudtick2x; // 612
reg iRCLK; // 612
reg iBAUDOUTN; // 612
reg iTXFIFOClear; // 612
reg iTXFIFOWrite; // 612
reg iTXFIFORead; // 612
reg iTXFIFOEmpty; // 612
reg iTXFIFOFull; // 612
reg iTXFIFO16Full; // 612
reg iTXFIFO64Full; // 612
reg [5:0] iTXFIFOUsage; // 605
reg [7:0] iTXFIFOQ; // 605
reg iRXFIFOClear; // 612
reg iRXFIFOWrite; // 612
reg iRXFIFORead; // 612
reg iRXFIFOEmpty; // 612
reg iRXFIFOFull; // 612
reg iRXFIFO16Full; // 612
reg iRXFIFO64Full; // 612
reg [10:0] iRXFIFOD; // 605
reg [10:0] iRXFIFOQ; // 605
reg [5:0] iRXFIFOUsage; // 605
reg iRXFIFOTrigger; // 612
reg iRXFIFO16Trigger; // 612
reg iRXFIFO64Trigger; // 612
reg iRXFIFOPE; // 612
reg iRXFIFOFE; // 612
reg iRXFIFOBI; // 612
reg iSOUT; // 612
reg iTXStart; // 612
reg iTXClear; // 612
reg iTXFinished; // 612
reg iTXRunning; // 612
reg iSINr; // 612
reg iSIN; // 612
reg iRXFinished; // 612
reg iRXClear; // 612
reg [7:0] iRXData; // 605
reg iRXPE; // 612
reg iRXFE; // 612
reg iRXBI; // 612
reg iFERE; // 612
reg iPERE; // 612
reg iBIRE; // 612
reg [6:0] iFECounter; // 900
reg iFEIncrement; // 612
reg iFEDecrement; // 612
reg iRDAInterrupt; // 612
reg [5:0] iTimeoutCount; // 605
reg iCharTimeout; // 612
reg iLSR_THRERE; // 612
reg iTHRInterrupt; // 612
reg iTXEnable; // 612
reg iRTS; // 612
assign /*903*/ iWrite = (PSEL ==  1'b1 && PENABLE ==  1'b1) && PWRITE ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iRead = (PSEL ==  1'b1 && PENABLE ==  1'b1) && PWRITE ==  1'b0 ?  1'b1 :   1'b0; // 905
assign /*903*/ iRST = RSTN ==  1'b0 ?  1'b1 :   1'b0; // 905
assign /*903*/ iRBRRead = (iRead ==  1'b1 && PADDR == 3'b000) && iLCR_DLAB ==  1'b0 ?  1'b1 :   1'b0; // 905
assign /*903*/ iTHRWrite = (iWrite ==  1'b1 && PADDR == 3'b000) && iLCR_DLAB ==  1'b0 ?  1'b1 :   1'b0; // 905
assign /*903*/ iDLLWrite = (iWrite ==  1'b1 && PADDR == 3'b000) && iLCR_DLAB ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iDLMWrite = (iWrite ==  1'b1 && PADDR == 3'b001) && iLCR_DLAB ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iIERWrite = (iWrite ==  1'b1 && PADDR == 3'b001) && iLCR_DLAB ==  1'b0 ?  1'b1 :   1'b0; // 905
assign /*903*/ iIIRRead = iRead ==  1'b1 && PADDR == 3'b010 ?  1'b1 :   1'b0; // 905
assign /*903*/ iFCRWrite = iWrite ==  1'b1 && PADDR == 3'b010 ?  1'b1 :   1'b0; // 905
assign /*903*/ iLCRWrite = iWrite ==  1'b1 && PADDR == 3'b011 ?  1'b1 :   1'b0; // 905
assign /*903*/ iMCRWrite = iWrite ==  1'b1 && PADDR == 3'b100 ?  1'b1 :   1'b0; // 905
assign /*903*/ iLSRRead = iRead ==  1'b1 && PADDR == 3'b101 ?  1'b1 :   1'b0; // 905
assign /*903*/ iMSRRead = iRead ==  1'b1 && PADDR == 3'b110 ?  1'b1 :   1'b0; // 905
assign /*903*/ iSCRWrite = iWrite ==  1'b1 && PADDR == 3'b111 ?  1'b1 :   1'b0; // 905
slib_input_sync UART_IS_SIN (CLK,iRST,SIN,iSINr); // 879
slib_input_sync UART_IS_CTS (CLK,iRST,CTSN,iCTSNs); // 879
slib_input_sync UART_IS_DSR (CLK,iRST,DSRN,iDSRNs); // 879
slib_input_sync UART_IS_DCD (CLK,iRST,DCDN,iDCDNs); // 879
slib_input_sync UART_IS_RI (CLK,iRST,RIN,iRINs); // 879
slib_input_filter #(.SIZE(2)) UART_IF_CTS (CLK,iRST,iBaudtick2x,iCTSNs,iCTSn); // 879
slib_input_filter #(.SIZE(2)) UART_IF_DSR (CLK,iRST,iBaudtick2x,iDSRNs,iDSRn); // 879
slib_input_filter #(.SIZE(2)) UART_IF_DCD (CLK,iRST,iBaudtick2x,iDCDNs,iDCDn); // 879
slib_input_filter #(.SIZE(2)) UART_IF_RI (CLK,iRST,iBaudtick2x,iRINs,iRIn); // 879

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       /* block const 263 */
       iDLL <= (0<<7)|(0<<6)|(0<<5)|(0<<4)|(0<<3)|(0<<2)|(0<<1)|(1<<0);
       /* block const 263 */
       iDLM <= (0<<7)|(0<<6)|(0<<5)|(0<<4)|(0<<3)|(0<<2)|(0<<1)|(0<<0);
    end
  else
    begin
       if ((iDLLWrite ==  1'b1))
         begin
            iDLL <= PWDATA[7:0] ; // 413
         end
       if ((iDLMWrite ==  1'b1))
         begin
            iDLM <= PWDATA[7:0] ; // 413
         end
    end

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       iIER[3:0] <= 0;
    end
  else
    begin
       if ((iIERWrite ==  1'b1))
         begin
            iIER[3:0] <= PWDATA[3:0];
         end
    end

assign /*432*/ iIER_ERBI = iIER[0]; // 434
assign /*432*/ iIER_ETBEI = iIER[1]; // 434
assign /*432*/ iIER_ELSI = iIER[2]; // 434
assign /*432*/ iIER_EDSSI = iIER[3]; // 434
assign iIER[7:4] = 0;

uart_interrupt UART_IIC (
	.CLK(CLK),
	.RST(iRST),
	.IER(iIER[3:0] ),
	.LSR(iLSR[4:0] ),
	.THI(iTHRInterrupt),
	.RDA(iRDAInterrupt),
	.CTI(iCharTimeout),
	.AFE(iMCR_AFE),
	.MSR(iMSR[3:0] ),
	.IIR(iIIR[3:0] ),
	.INT(INT)); // 879
slib_edge_detect UART_IIC_THRE_ED (
	.CLK(CLK),
	.RST(iRST),
	.D(iLSR_THRE),
	.RE(iLSR_THRERE),
        .FE()); // 879

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       iTHRInterrupt <=  1'b0; // 413
    end
  else
    begin
       if (((iLSR_THRERE ==  1'b1 | iFCR_TXFIFOReset ==  1'b1) | ((iIERWrite ==  1'b1 && PWDATA[1] ==  1'b1) && iLSR_THRE ==  1'b1)))
         begin
            iTHRInterrupt <=  1'b1; // 413
         end
       else if     (((iIIRRead ==  1'b1 && iIIR[3:1]  == 3'b001) | iTHRWrite ==  1'b1))
         begin
            iTHRInterrupt <=  1'b0; // 413
         end
    end

assign /*903*/ iRDAInterrupt = (iFCR_FIFOEnable ==  1'b0 && iLSR_DR ==  1'b1) | (iFCR_FIFOEnable ==  1'b1 && iRXFIFOTrigger ==  1'b1) ?  1'b1 :   1'b0; // 905
assign /*432*/ iIIR_PI = iIIR[0]; // 434
assign /*432*/ iIIR_ID0 = iIIR[1]; // 434
assign /*432*/ iIIR_ID1 = iIIR[2]; // 434
assign /*432*/ iIIR_ID2 = iIIR[3]; // 434
assign /*432*/ iIIR_FIFO64 = iIIR[5]; // 434
assign iIIR[4] = 0;
assign iIIR[5] = iFCR_FIFOEnable ? iFCR_FIFO64E : 1'b0;
assign iIIR[6] = iFCR_FIFOEnable;
assign iIIR[7] = iFCR_FIFOEnable;
   
always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       /* block const 263 */
       iTimeoutCount <= (0<<5)|(0<<4)|(0<<3)|(0<<2)|(0<<1)|(0<<0);
       iCharTimeout <=  1'b0; // 413
    end
  else
    begin
       if (((iRXFIFOEmpty ==  1'b1 | iRBRRead ==  1'b1) | iRXFIFOWrite ==  1'b1))
         begin
            /* block const 263 */
            iTimeoutCount <= (0<<5)|(0<<4)|(0<<3)|(0<<2)|(0<<1)|(0<<0);
         end
       else if     (((iRXFIFOEmpty ==  1'b0 && iBaudtick2x ==  1'b1) && iTimeoutCount[5] ==  1'b0))
         begin
            iTimeoutCount <= iTimeoutCount + 1; // 413
         end
       if ((iFCR_FIFOEnable ==  1'b1))
         begin
            if ((iRBRRead ==  1'b1))
              begin
                 iCharTimeout <=  1'b0; // 413
              end
            else if         ((iTimeoutCount[5] ==  1'b1))
              begin
                 iCharTimeout <=  1'b1; // 413
              end
         end
       else
         begin
            iCharTimeout <=  1'b0; // 413
         end
    end

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       iFCR_FIFOEnable <=  1'b0; // 413
       iFCR_RXFIFOReset <=  1'b0; // 413
       iFCR_TXFIFOReset <=  1'b0; // 413
       iFCR_DMAMode <=  1'b0; // 413
       iFCR_FIFO64E <=  1'b0; // 413
       /* block const 263 */
       iFCR_RXTrigger <= (0<<1)|(0<<0);
    end
  else
    begin
       iFCR_RXFIFOReset <=  1'b0; // 413
       iFCR_TXFIFOReset <=  1'b0; // 413
       if ((iFCRWrite ==  1'b1))
         begin
            iFCR_FIFOEnable <= PWDATA[0]; // 413
            iFCR_DMAMode <= PWDATA[3]; // 413
            iFCR_RXTrigger <= PWDATA[7:6] ; // 413
            if ((iLCR_DLAB ==  1'b1))
              begin
                 iFCR_FIFO64E <= PWDATA[5]; // 413
              end
            
            if (((PWDATA[1] ==  1'b1 | (iFCR_FIFOEnable ==  1'b0 && PWDATA[0] ==  1'b1)) | (iFCR_FIFOEnable ==  1'b1 && PWDATA[0] ==  1'b0)))
              begin
                 iFCR_RXFIFOReset <=  1'b1; // 413
              end
            
            if (((PWDATA[2] ==  1'b1 | (iFCR_FIFOEnable ==  1'b0 && PWDATA[0] ==  1'b1)) | (iFCR_FIFOEnable ==  1'b1 && PWDATA[0] ==  1'b0)))
              begin
                 iFCR_TXFIFOReset <=  1'b1; // 413
              end
         end
    end

assign    iFCR[0] = iFCR_FIFOEnable;
assign    iFCR[1] = iFCR_RXFIFOReset;
assign    iFCR[2] = iFCR_TXFIFOReset;
assign    iFCR[3] = iFCR_DMAMode;
assign    iFCR[4] = 1'b0;
assign    iFCR[5] = iFCR_FIFO64E;
assign    iFCR[7:6] = iFCR_RXTrigger;

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       /* block const 263 */
       iLCR <= (0<<7)|(0<<6)|(0<<5)|(0<<4)|(0<<3)|(0<<2)|(0<<1)|(0<<0);
    end
  else
    begin
       if ((iLCRWrite ==  1'b1))
         begin
            iLCR <= PWDATA[7:0] ; // 413
         end
    end

assign /*432*/ iLCR_WLS = iLCR[1:0] ; // 434
assign /*432*/ iLCR_STB = iLCR[2]; // 434
assign /*432*/ iLCR_PEN = iLCR[3]; // 434
assign /*432*/ iLCR_EPS = iLCR[4]; // 434
assign /*432*/ iLCR_SP = iLCR[5]; // 434
assign /*432*/ iLCR_BC = iLCR[6]; // 434
assign /*432*/ iLCR_DLAB = iLCR[7]; // 434

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       iMCR[5:0] <= 0;
    end
  else
    begin
       if ((iMCRWrite ==  1'b1))
         begin
            iMCR[5:0] <= PWDATA[5:0];
         end
    end

assign /*432*/ iMCR_DTR = iMCR[0]; // 434
assign /*432*/ iMCR_RTS = iMCR[1]; // 434
assign /*432*/ iMCR_OUT1 = iMCR[2]; // 434
assign /*432*/ iMCR_OUT2 = iMCR[3]; // 434
assign /*432*/ iMCR_LOOP = iMCR[4]; // 434
assign /*432*/ iMCR_AFE = iMCR[5]; // 434
assign iMCR[7:6] = 0;

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       iLSR_OE <=  1'b0; // 413
       iLSR_PE <=  1'b0; // 413
       iLSR_FE <=  1'b0; // 413
       iLSR_BI <=  1'b0; // 413
       iFECounter <= 0; // 413
       iLSR_FIFOERR <=  1'b0; // 413
    end
  else
    begin
       if ((((iFCR_FIFOEnable ==  1'b0 && iLSR_DR ==  1'b1) && iRXFinished ==  1'b1) | ((iFCR_FIFOEnable ==  1'b1 && iRXFIFOFull ==  1'b1) && iRXFinished ==  1'b1)))
         begin
            iLSR_OE <=  1'b1; // 413
         end
       else if     ((iLSRRead ==  1'b1))
         begin
            iLSR_OE <=  1'b0; // 413
         end
       if ((iPERE ==  1'b1))
         begin
            iLSR_PE <=  1'b1; // 413
         end
       else if     ((iLSRRead ==  1'b1))
         begin
            iLSR_PE <=  1'b0; // 413
         end
       if ((iFERE ==  1'b1))
         begin
            iLSR_FE <=  1'b1; // 413
         end
       else if     ((iLSRRead ==  1'b1))
         begin
            iLSR_FE <=  1'b0; // 413
         end
       if ((iBIRE ==  1'b1))
         begin
            iLSR_BI <=  1'b1; // 413
         end
       else if     ((iLSRRead ==  1'b1))
         begin
            iLSR_BI <=  1'b0; // 413
         end
       if ((iFECounter != 0))
         begin
            iLSR_FIFOERR <=  1'b1; // 413
         end
       else if     ((iRXFIFOEmpty ==  1'b1 | iRXFIFOQ[10:8]  == 3'b000))
         begin
            iLSR_FIFOERR <=  1'b0; // 413
         end
       if ((iRXFIFOClear ==  1'b1))
         begin
            iFECounter <= 0; // 413
         end
       else
         begin
            if ((iFEIncrement ==  1'b1 && iFEDecrement ==  1'b0))
              begin
                 iFECounter <= iFECounter + 1; // 413
              end
            else if         ((iFEIncrement ==  1'b0 && iFEDecrement ==  1'b1))
              begin
                 iFECounter <= iFECounter - 1; // 413
              end
         end
    end

assign /*903*/ iRXFIFOPE = iRXFIFOEmpty ==  1'b0 && iRXFIFOQ[8] ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iRXFIFOFE = iRXFIFOEmpty ==  1'b0 && iRXFIFOQ[9] ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iRXFIFOBI = iRXFIFOEmpty ==  1'b0 && iRXFIFOQ[10] ==  1'b1 ?  1'b1 :   1'b0; // 905
slib_edge_detect UART_PEDET (.CLK,.RST(iRST),.D(iRXFIFOPE),.RE(iPERE),.FE()); // 879
slib_edge_detect UART_FEDET (.CLK,.RST(iRST),.D(iRXFIFOFE),.RE(iFERE),.FE()); // 879
slib_edge_detect UART_BIDET (.CLK,.RST(iRST),.D(iRXFIFOBI),.RE(iBIRE),.FE()); // 879
assign /*903*/ iFEIncrement = iRXFIFOWrite ==  1'b1 && iRXFIFOD[10:8]  != 3'b000 ?  1'b1 :   1'b0; // 905
assign /*903*/ iFEDecrement = (iFECounter != 0 && iRXFIFOEmpty ==  1'b0) && ((iPERE ==  1'b1 | iFERE ==  1'b1) | iBIRE ==  1'b1) ?  1'b1 :   1'b0; // 905
assign     iLSR[0]         = iLSR_DR;
assign     iLSR[1]         = iLSR_OE;
assign     iLSR[2]         = iLSR_PE;
assign     iLSR[3]         = iLSR_FE;
assign     iLSR[4]         = iLSR_BI;
assign     iLSR[5]         = iLSR_THRNF;
assign     iLSR[6]         = iLSR_TEMT;
assign     iLSR[7]         = iFCR_FIFOEnable && iLSR_FIFOERR;
   
assign /*903*/ iLSR_DR = iRXFIFOEmpty ==  1'b0 | iRXFIFOWrite ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iLSR_THRE = iTXFIFOEmpty ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iLSR_TEMT = iTXRunning ==  1'b0 && iLSR_THRE ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iLSR_THRNF = ((iFCR_FIFOEnable ==  1'b0 && iTXFIFOEmpty ==  1'b1) | (iFCR_FIFOEnable ==  1'b1 && iTXFIFOFull ==  1'b0)) ?  1'b1 :   1'b0; // 905
assign /*903*/ iMSR_CTS = (iMCR_LOOP ==  1'b1 && iRTS ==  1'b1) | (iMCR_LOOP ==  1'b0 && iCTSn ==  1'b0) ?  1'b1 :   1'b0; // 905
assign /*903*/ iMSR_DSR = (iMCR_LOOP ==  1'b1 && iMCR_DTR ==  1'b1) | (iMCR_LOOP ==  1'b0 && iDSRn ==  1'b0) ?  1'b1 :   1'b0; // 905
assign /*903*/ iMSR_RI = (iMCR_LOOP ==  1'b1 && iMCR_OUT1 ==  1'b1) | (iMCR_LOOP ==  1'b0 && iRIn ==  1'b0) ?  1'b1 :   1'b0; // 905
assign /*903*/ iMSR_DCD = (iMCR_LOOP ==  1'b1 && iMCR_OUT2 ==  1'b1) | (iMCR_LOOP ==  1'b0 && iDCDn ==  1'b0) ?  1'b1 :   1'b0; // 905
slib_edge_detect UART_ED_CTS (
	.CLK(CLK),
	.RST(iRST),
	.D(iMSR_CTS),
	.RE(iCTSnRE),
	.FE(iCTSnFE)); // 879
slib_edge_detect UART_ED_DSR (
	.CLK(CLK),
	.RST(iRST),
	.D(iMSR_DSR),
	.RE(iDSRnRE),
	.FE(iDSRnFE)); // 879
slib_edge_detect UART_ED_RI (
	.CLK(CLK),
	.RST(iRST),
	.D(iMSR_RI),
	.RE(iRInRE),
	.FE(iRInFE)); // 879
slib_edge_detect UART_ED_DCD (
	.CLK(CLK),
	.RST(iRST),
	.D(iMSR_DCD),
	.RE(iDCDnRE),
	.FE(iDCDnFE)); // 879

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       iMSR_dCTS <=  1'b0; // 413
       iMSR_dDSR <=  1'b0; // 413
       iMSR_TERI <=  1'b0; // 413
       iMSR_dDCD <=  1'b0; // 413
    end
  else
    begin
       if ((iCTSnRE ==  1'b1 | iCTSnFE ==  1'b1))
         begin
            iMSR_dCTS <=  1'b1; // 413
         end
       else if     ((iMSRRead ==  1'b1))
         begin
            iMSR_dCTS <=  1'b0; // 413
         end
       if ((iDSRnRE ==  1'b1 | iDSRnFE ==  1'b1))
         begin
            iMSR_dDSR <=  1'b1; // 413
         end
       else if     ((iMSRRead ==  1'b1))
         begin
            iMSR_dDSR <=  1'b0; // 413
         end
       if ((iRInFE ==  1'b1))
         begin
            iMSR_TERI <=  1'b1; // 413
         end
       else if     ((iMSRRead ==  1'b1))
         begin
            iMSR_TERI <=  1'b0; // 413
         end
       if ((iDCDnRE ==  1'b1 | iDCDnFE ==  1'b1))
         begin
            iMSR_dDCD <=  1'b1; // 413
         end
       else if     ((iMSRRead ==  1'b1))
         begin
            iMSR_dDCD <=  1'b0; // 413
         end
    end

assign    iMSR[0]     = iMSR_dCTS;
assign    iMSR[1]     = iMSR_dDSR;
assign    iMSR[2]     = iMSR_TERI;
assign    iMSR[3]     = iMSR_dDCD;
assign    iMSR[4]     = iMSR_CTS;
assign    iMSR[5]     = iMSR_DSR;
assign    iMSR[6]     = iMSR_RI;
assign    iMSR[7]     = iMSR_DCD;

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       /* block const 263 */
       iSCR <= (0<<7)|(0<<6)|(0<<5)|(0<<4)|(0<<3)|(0<<2)|(0<<1)|(0<<0);
    end
  else
    begin
       if ((iSCRWrite ==  1'b1))
         begin
            iSCR <= PWDATA[7:0] ; // 413
         end
    end

assign /*432*/ iBaudgenDiv = {iDLM, iDLL}
; // 434
uart_baudgen UART_BG16 (
	.CLK(CLK),
	.RST(iRST),
	.CE( 1'b1),
	.CLEAR( 1'b0),
	.DIVIDER(iBaudgenDiv),
	.BAUDTICK(iBaudtick16x)); // 879
slib_clock_div #(.RATIO(8)) UART_BG2 (
	.CLK(CLK),
	.RST(iRST),
	.CE(iBaudtick16x),
	.Q(iBaudtick2x)); // 879
slib_edge_detect UART_RCLK (
	.CLK(CLK),
	.RST(iRST),
	.D(iBAUDOUTN),
	.RE(iRCLK),
        .FE()); // 879
slib_fifo #(.WIDTH(8), .SIZE_E(6)) UART_TXFF (
	.CLK(CLK),
	.RST(iRST),
	.CLEAR(iTXFIFOClear),
	.WRITE(iTXFIFOWrite),
	.READ(iTXFIFORead),
	.D(PWDATA[7:0] ),
	.Q(iTXFIFOQ),
	.EMPTY(iTXFIFOEmpty),
	.FULL(iTXFIFO64Full),
	.USAGE(iTXFIFOUsage)); // 879
assign /*432*/ iTXFIFO16Full = iTXFIFOUsage[4]; // 434
assign /*903*/ iTXFIFOFull = iFCR_FIFO64E ==  1'b0 ? iTXFIFO16Full :  iTXFIFO64Full; // 905
assign /*903*/ iTXFIFOWrite = ((iFCR_FIFOEnable ==  1'b0 && iTXFIFOEmpty ==  1'b1) | (iFCR_FIFOEnable ==  1'b1 && iTXFIFOFull ==  1'b0)) && iTHRWrite ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iTXFIFOClear = iFCR_TXFIFOReset ==  1'b1 ?  1'b1 :   1'b0; // 905
slib_fifo #(.WIDTH(11), .SIZE_E(6)) UART_RXFF (
	.CLK(CLK),
	.RST(iRST),
	.CLEAR(iRXFIFOClear),
	.WRITE(iRXFIFOWrite),
	.READ(iRXFIFORead),
	.D(iRXFIFOD),
	.Q(iRXFIFOQ),
	.EMPTY(iRXFIFOEmpty),
	.FULL(iRXFIFO64Full),
	.USAGE(iRXFIFOUsage)); // 879
assign /*903*/ iRXFIFORead = iRBRRead ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*432*/ iRXFIFO16Full = iRXFIFOUsage[4]; // 434
assign /*903*/ iRXFIFOFull = iFCR_FIFO64E ==  1'b0 ? iRXFIFO16Full :  iRXFIFO64Full; // 905
assign /*432*/ iRBR = iRXFIFOQ[7:0] ; // 434
assign /*903*/ iRXFIFO16Trigger = ((((iFCR_RXTrigger == 2'b00 && iRXFIFOEmpty ==  1'b0) | (iFCR_RXTrigger == 2'b01 && (iRXFIFOUsage[2] ==  1'b1 | iRXFIFOUsage[3] ==  1'b1))) | (iFCR_RXTrigger == 2'b10 && iRXFIFOUsage[3] ==  1'b1)) | (((iFCR_RXTrigger == 2'b11 && iRXFIFOUsage[3] ==  1'b1) && iRXFIFOUsage[2] ==  1'b1) && iRXFIFOUsage[1] ==  1'b1)) | iRXFIFO16Full ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iRXFIFO64Trigger = ((((iFCR_RXTrigger == 2'b00 && iRXFIFOEmpty ==  1'b0) | (iFCR_RXTrigger == 2'b01 && (iRXFIFOUsage[4] ==  1'b1 | iRXFIFOUsage[5] ==  1'b1))) | (iFCR_RXTrigger == 2'b10 && iRXFIFOUsage[5] ==  1'b1)) | (((iFCR_RXTrigger == 2'b11 && iRXFIFOUsage[5] ==  1'b1) && iRXFIFOUsage[4] ==  1'b1) && iRXFIFOUsage[3] ==  1'b1)) | iRXFIFO64Full ==  1'b1 ?  1'b1 :   1'b0; // 905
assign /*903*/ iRXFIFOTrigger = iFCR_FIFO64E ==  1'b0 ? iRXFIFO16Trigger :  iRXFIFO64Trigger; // 905
uart_transmitter UART_TX (
	.CLK(CLK),
	.RST(iRST),
	.TXCLK(iBaudtick2x),
	.TXSTART(iTXStart),
	.CLEAR(iTXClear),
	.WLS(iLCR_WLS),
	.STB(iLCR_STB),
	.PEN(iLCR_PEN),
	.EPS(iLCR_EPS),
	.SP(iLCR_SP),
	.BC(iLCR_BC),
	.DIN(iTSR),
	.TXFINISHED(iTXFinished),
	.SOUT(iSOUT)); // 879
assign /*432*/ iTXClear =  1'b0; // 434
uart_receiver UART_RX (
	.CLK(CLK),
	.RST(iRST),
	.RXCLK(iRCLK),
	.RXCLEAR(iRXClear),
	.WLS(iLCR_WLS),
	.STB(iLCR_STB),
	.PEN(iLCR_PEN),
	.EPS(iLCR_EPS),
	.SP(iLCR_SP),
	.SIN(iSIN),
	.PE(iRXPE),
	.FE(iRXFE),
	.BI(iRXBI),
	.DOUT(iRXData),
	.RXFINISHED(iRXFinished)); // 879
assign /*432*/ iRXClear =  1'b0; // 434
assign /*903*/ iSIN = iMCR_LOOP ==  1'b0 ? iSINr :  iSOUT; // 905
assign /*903*/ iTXEnable = iTXFIFOEmpty ==  1'b0 && (iMCR_AFE ==  1'b0 | (iMCR_AFE ==  1'b1 && iMSR_CTS ==  1'b1)) ?  1'b1 :   1'b0; // 905

   typedef enum logic [1:0] {TXIDLE, TXSTART, TXRUN, TXEND} tx_state_type;
   typedef enum logic {RXIDLE, RXSAVE} rx_state_type;
   
   rx_state_type rx_State;
   tx_state_type tx_State;
   
    // Transmitter process
    always @ (posedge CLK or posedge iRST)
        if (iRST == 1'b1)
          begin
            tx_State    <= TXIDLE;
            iTSR        <= 0;
            iTXStart    <= 1'b0;
            iTXFIFORead <= 1'b0;
            iTXRunning  <= 1'b0;
          end
        else
          begin
            // Defaults
            iTXStart    <= 1'b0;
            iTXFIFORead <= 1'b0;
            iTXRunning  <= 1'b0;

            case(tx_State)
                TXIDLE       :
                  begin
                     if (iTXEnable == 1'b1)
                       begin
                          iTXStart <= 1'b1;            // Start transmitter
                          tx_State <= TXSTART;
                       end
                     else
                       tx_State <= TXIDLE;
                  end
                TXSTART    :
                  begin
                     iTSR <= iTXFIFOQ;
                     iTXStart <= 1'b1;                // Start transmitter
                     iTXFIFORead <= 1'b1;             // Increment TX FIFO read counter
                     tx_State <= TXRUN;
                  end
                TXRUN      :
                  begin
                     if (iTXFinished == 1'b1)     // TX finished
                       tx_State <= TXEND;
                     else
                       tx_State <= TXRUN;
                     iTXRunning <= 1'b1;
                     iTXStart   <= 1'b1;
                  end
                TXEND      :  tx_State <= TXIDLE;
                default    :  tx_State <= TXIDLE;
            endcase;
    end

    // Receiver process
    always @(posedge CLK or posedge iRST)
        if (iRST == 1'b1)
          begin
            rx_State        <= RXIDLE;
            iRXFIFOWrite <= 1'b0;
            iRXFIFOClear <= 1'b0;
            iRXFIFOD     <= 0;
          end
        else
          begin
            // Defaults
            iRXFIFOWrite <= 1'b0;
            iRXFIFOClear <= iFCR_RXFIFOReset;

            case (rx_State)
                RXIDLE       :
                  begin
                     if (iRXFinished == 1'b1)
                       begin // Receive finished
                          iRXFIFOD <= {iRXBI, iRXFE, iRXPE, iRXData};
                          if (iFCR_FIFOEnable == 1'b0)
                            iRXFIFOClear <= 1'b1;    // Non-FIFO mode
                          rx_State <= RXSAVE;
                       end
                     else
                       rx_State <= RXIDLE;
                  end
                RXSAVE    :
                  begin
                     if (iFCR_FIFOEnable == 1'b0)
                       iRXFIFOWrite <= 1'b1;        // Non-FIFO mode: Overwrite
                     else if (iRXFIFOFull == 1'b0)
                       iRXFIFOWrite <= 1'b1;        // FIFO mode
                     rx_State <= RXIDLE;
                  end
                default    :  rx_State <= RXIDLE;
             endcase; // case rx_State
          end

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       iRTS <=  1'b0; // 413
    end
  else
    begin
       if ((iMCR_RTS ==  1'b0 | (iMCR_AFE ==  1'b1 && iRXFIFOTrigger ==  1'b1)))
         begin
            iRTS <=  1'b0; // 413
         end
       else if     ((iMCR_RTS ==  1'b1 && (iMCR_AFE ==  1'b0 | (iMCR_AFE ==  1'b1 && iRXFIFOEmpty ==  1'b1))))
         begin
            iRTS <=  1'b1; // 413
         end
    end

always @(posedge CLK or posedge iRST)
  if ((iRST ==  1'b1))
    begin
       iBAUDOUTN <=  1'b1; // 413
       OUT1N <=  1'b1; // 413
       OUT2N <=  1'b1; // 413
       RTSN <=  1'b1; // 413
       DTRN <=  1'b1; // 413
       SOUT <=  1'b1; // 413
    end
  else
    begin
       iBAUDOUTN <=  1'b0; // 413
       OUT1N <=  1'b0; // 413
       OUT2N <=  1'b0; // 413
       RTSN <=  1'b0; // 413
       DTRN <=  1'b0; // 413
       SOUT <=  1'b0; // 413
       if ((iBaudtick16x ==  1'b0))
         begin
            iBAUDOUTN <=  1'b1; // 413
         end
       
       if ((iMCR_LOOP ==  1'b1 | iMCR_OUT1 ==  1'b0))
         begin
            OUT1N <=  1'b1; // 413
         end
       
       if ((iMCR_LOOP ==  1'b1 | iMCR_OUT2 ==  1'b0))
         begin
            OUT2N <=  1'b1; // 413
         end
       
       if ((iMCR_LOOP ==  1'b1 | iRTS ==  1'b0))
         begin
            RTSN <=  1'b1; // 413
         end
       
       if ((iMCR_LOOP ==  1'b1 | iMCR_DTR ==  1'b0))
         begin
            DTRN <=  1'b1; // 413
         end
       
       if ((iMCR_LOOP ==  1'b1 | iSOUT ==  1'b1))
         begin
            SOUT <=  1'b1; // 413
              end
    end

always @(PADDR or iLCR_DLAB or iRBR or iDLL or iDLM or iIER or iIIR or iLCR or iMCR or iLSR or iMSR or iSCR)
  begin
     case (PADDR)
       3'b000:
         begin
            if ((iLCR_DLAB ==  1'b0))
              begin
                 PRDATA[7:0] <= iRBR;
              end
            else
              begin
                 PRDATA[7:0] <= iDLL;
              end
         end
       
       3'b001:
         begin
            if ((iLCR_DLAB ==  1'b0))
              begin
                 PRDATA[7:0] <= iIER;
              end
            else
              begin
                 PRDATA[7:0] <= iDLM;
              end
         end
       
       3'b010:
         begin
            PRDATA[7:0] <= iIIR;
         end
       
       3'b011:
         begin
            PRDATA[7:0] <= iLCR;
         end
       
       3'b100:
         begin
            PRDATA[7:0] <= iMCR;
         end
       
       3'b101:
         begin
            PRDATA[7:0] <= iLSR;
         end
       
       3'b110:
         begin
            PRDATA[7:0] <= iMSR;
         end
       
       3'b111:
         begin
            PRDATA[7:0] <= iSCR;
         end
       
       default:
         begin
            PRDATA[7:0] <= iRBR;
         end
       
     endcase

  end

assign PRDATA[31:8] = 24'b0;
assign /*432*/ PREADY =  1'b1; // 434
assign /*432*/ PSLVERR =  1'b0; // 434

endmodule // apb_uart
