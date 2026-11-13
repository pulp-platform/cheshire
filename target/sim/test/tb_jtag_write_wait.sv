// Copyright 2026 CheshireAra contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Exact VIP task extraction with actual locked DTM/TAP/CDC/JTAG driver.
`timescale 1ns/1ps
module tb_jtag_write_wait;
 typedef bit [31:0] word_bt;
 bit clk=0,tck=0,rst_n=0;
 always #2.5ns clk=~clk;
 always #10ns tck=~tck;
 JTAG_DV jtag(tck);
 dm::dmi_req_t request;
 dm::dmi_resp_t response;
 logic request_valid,request_ready,response_valid,response_ready,dmi_rst_n;
 int unsigned latency=0,delay_left=0,accepted=0,returned=0,errors=0,checks=0;
 bit pending=0;
 logic[31:0] values[128];
 jtag_test::jtag_driver #(.IrLength(5),.TA(2ns),.TT(18ns)) driver;
 jtag_test::riscv_dbg #(.IrLength(5),.TA(2ns),.TT(18ns)) jtag_dbg;
 dmi_jtag dtm(.clk_i(clk),.rst_ni(rst_n),.testmode_i(1'b0),.dmi_rst_no(dmi_rst_n),
  .dmi_req_o(request),.dmi_req_valid_o(request_valid),.dmi_req_ready_i(request_ready),
  .dmi_resp_i(response),.dmi_resp_ready_o(response_ready),.dmi_resp_valid_i(response_valid),
  .tck_i(tck),.tms_i(jtag.tms),.trst_ni(jtag.trst_n),.td_i(jtag.tdi),.td_o(jtag.tdo),.tdo_oe_o());
 assign request_ready=dmi_rst_n && !pending;
 assign response_valid=dmi_rst_n && pending && delay_left==0;
 always @(posedge clk)begin
  if(!rst_n || !dmi_rst_n)begin pending<=0;delay_left<=0;end
  else begin
   if(pending && delay_left!=0)delay_left<=delay_left-1;
   if(response_valid && response_ready)begin pending<=0;returned++;end
   if(request_valid && request_ready)begin
    pending<=1;delay_left<=latency;
    response.resp<=dm::DTM_SUCCESS;response.data<=values[request.addr];
    if(request.op==dm::DTM_WRITE)begin
     values[request.addr]<=request.data;accepted++;
     $display("JTAG_WAIT_ACCEPT addr=%h data=%h",request.addr,request.data);
    end
   end
  end
 end
 task automatic check(input bit ok,input string label,input logic[63:0] got,want);
  checks++;if(!ok)begin errors++;$display("JTAG_WAIT_ERROR %s got=%h want=%h",label,got,want);end
 endtask
 `include "jtag_write_task.svh"
 initial begin
  dm::dtmcs_t status;
  void'($value$plusargs("LATENCY=%d",latency));
  foreach(values[i])values[i]='0;
  driver=new(jtag);jtag_dbg=new(driver);
  jtag_dbg.reset_master();repeat(10)@(posedge clk);rst_n=1;
  repeat(10)@(posedge tck);
  for(int i=0;i<32;i++)jtag_write(dm::dm_csr_e'(7'h10+i),32'ha5b60000+i);
  jtag_dbg.wait_idle(32);
  check(accepted==32,"write count",accepted,32);
  check(returned==32,"response count",returned,32);
  for(int i=0;i<32;i++)check(values[7'h10+i]===32'ha5b60000+i,"payload",values[7'h10+i],32'ha5b60000+i);
  jtag_dbg.read_dtmcs(status);
  check(status.dmistat===0,"DTM status",status.dmistat,0);
  $display("JTAG_WAIT_DONE writes=32 latency=%0d checks=%0d errors=%0d accepted=%0d returned=%0d",latency,checks,errors,accepted,returned);
  $finish;
 end
 initial begin #1ms;$fatal(1,"JTAG_WAIT_HDL_LIMIT");end
endmodule
