// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

module tb_cheshire_soc;

  cheshire_soc_fixture fix();

  string        binary;
  logic [1:0]   boot_mode;
  logic         test_mode;

  bit [31:0] ret;

  initial begin
    fix.wait_for_reset();
    fix.jtag_init();
    fix.jtag_elf_run("../../../sw/tests/helloworld.spm.elf");

    #20000ns;

    fix.jtag_wait_for_eoc(ret);

    $finish;
  end

endmodule
