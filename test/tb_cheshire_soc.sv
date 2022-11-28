// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

module tb_cheshire_soc;

  cheshire_soc_fixture fix();

  string binary;
  longint entry_int;
  logic [63:0] entry;

  initial begin

    fix.set_bootmode(0);
    fix.set_testmode(0);
 
     
    fix.wait_for_reset();

    // Load binaries into memory (if any)
    if ($value$plusargs("BINARY=%s", binary)) begin
      $display("[tb_cheshire_soc] BINARY = %s", binary);
      fix.load_binary(binary);

      // Obtain the entry point from the ELF file
      void'(fix.get_entry(entry_int));
      entry = entry_int[63:0];
      
    end else begin
      // If no ELF file is provided jump to the beginning of the SPM
      entry = cheshire_pkg::SPM_BASE;
    end

    fix.jtag_init();

    fix.jtag_cfg_llc_spm();

    fix.sl_preload();

    // Preload the sections from an ELF file
    //fix.jtag_preload();
    
    // Check the preloaded sections
    //fix.jtag_preload_check();

    // Run from entrypoint
    fix.jtag_run(entry);

    // Wait for the application to write the return value to the first scratch register
    fix.jtag_wait_for_eoc(cheshire_pkg::SCRATCH_REGS_BASE + 64'h4);
    //fix.jtag_wait_for_eoc(64'h00000000_02004004);

    $finish;
  end

endmodule
