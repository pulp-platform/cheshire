// Copyright 2026 CheshireAra contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Exercise the real loader C API and real DPI open arrays. No RTL DUT.
module tb_elfloader_state;
 timeunit 1ns; timeprecision 1ps;
 import "DPI-C" function byte read_elf(input string filename);
 import "DPI-C" function byte get_entry(output longint address);
 import "DPI-C" function byte get_section(output longint address, output longint length);
 import "DPI-C" function byte read_section(input longint address,
   inout byte unsigned buffer[], input longint length);
 int checks, errors, loads, drained;
 function automatic void check(bit condition, string detail);
  checks++;
  if(!condition)begin
   errors++;
   if(errors<=8)$display("ELFLOADER_ERROR %s",detail);
  end
 endfunction
 function automatic void load_image(string filename, int bytes, int tag,
                                    int entry_offset, bit drain);
  longint entry, address, length;
  byte unsigned data[];
  int sections;
  loads++;
  check(read_elf(filename)==0,"read_elf return");
  check(get_entry(entry)==0,"get_entry return");
  check(entry==64'h80000000+entry_offset,"latest entry point");
  if(drain)begin
   drained++;
   sections=0;
   while(get_section(address,length)!=0)begin
    sections++;
    if(sections>3)$fatal(1,"ELFLOADER unexpected unbounded section list");
    check(address==64'h80000000,"latest segment address");
    check(length==bytes,"latest segment length");
    data=new[128];foreach(data[i])data[i]=8'ha5;
    check(read_section(address,data,128)==0,"read_section return");
    foreach(data[i])begin
     if(i<bytes)check(data[i]===8'((i*13+tag)&255),$sformatf("payload byte %0d",i));
     else check(data[i]===8'ha5,$sformatf("untouched byte %0d",i));
    end
   end
   check(sections==1,"one segment from latest file only");
   check(get_section(address,length)==0,"iterator remains exhausted");
  end
 endfunction
 initial begin: deadline
  #1us;$fatal(1,"ELFLOADER HDL deadline");
 end
 initial begin
  string first,second;
  longint entry,address,length;
  first="first.elf";second="second.elf";
  if($value$plusargs("FIRST=%s",first))begin end
  if($value$plusargs("SECOND=%s",second))begin end
  load_image(first,96,8'h11,0,1);
  load_image(second,64,8'h72,16,1);
  load_image(first,96,8'h11,0,1);
  // Start a new image before the previous iterator is consumed.
  load_image(first,96,8'h11,0,0);
  load_image(second,64,8'h72,16,1);
  load_image(first,96,8'h11,0,1);
  $display("ELFLOADER_EXPECTED_OPEN_FAILURE_BEGIN");
  check(read_elf({first,".missing"})!=0,"missing file return");
  check(get_entry(entry)==0,"get_entry after failed open");
  check(entry==0,"failed open clears entry");
  check(get_section(address,length)==0,"failed open clears sections");
  $display("ELFLOADER_EXPECTED_OPEN_FAILURE_END");
  load_image(first,96,8'h11,0,1);
  #1ns;
  $display("ELFLOADER_DONE loads=%0d drained=%0d checks=%0d errors=%0d",loads,drained,checks,errors);
  if(errors!=0)$fatal(1,"ELFLOADER_TEST_FAILED");
  $finish;
 end
endmodule
