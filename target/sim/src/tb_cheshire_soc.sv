// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

module tb_cheshire_soc;

  cheshire_soc_fixture fix();

  string      preload_elf;
  string      boot_hex;
  logic [1:0] boot_mode;
  logic [1:0] preload_mode;
  logic       test_mode;
  bit [31:0]  exit_code;

  initial begin
    // Fetch plusargs or use safe (fail-fast) defaults
    if (!$value$plusargs("BOOTMODE=%d", boot_mode))     boot_mode     = 0;
    if (!$value$plusargs("PRELMODE=%d", preload_mode))  preload_mode  = 0;
    if (!$value$plusargs("TESTMODE=%d", test_mode))     test_mode     = 0;
    if (!$value$plusargs("BINARY=%s",   preload_elf))   preload_elf   = "";
    if (!$value$plusargs("IMAGE=%s",    boot_hex))      boot_hex      = "";

    // Set test and boot mode
    fix.set_test_mode(boot_mode);
    fix.set_boot_mode(boot_mode);

    // Preload boot image if there is one
    fix.i2c_eeprom_preload(boot_hex);
    fix.spih_norflash_preload(boot_hex);

    // Wait for reset
    fix.wait_for_reset();

    // Preload in idle mode or wait for completion in autonomous boot
    if (boot_mode == 0) begin
      // Idle boot: preload with the specified mode
      case (preload_mode)
        0: begin      // JTAG
          fix.jtag_init();
          fix.jtag_elf_run(preload_elf);
          fix.jtag_wait_for_eoc(exit_code);
        end 1: begin  // Serial Link
          fix.slink_elf_run(preload_elf);
          fix.slink_wait_for_eoc(exit_code);
        end 2: begin  // UART
          fix.uart_debug_elf_run_and_wait(preload_elf, exit_code);
        end default: begin
          $fatal(1, "Unsupported preload mode %d (reserved)!", boot_mode);
        end
      endcase
    end else if (boot_mode == 1) begin
      $fatal(1, "Unsupported boot mode %d (SD Card)!", boot_mode);
    end else begin
      // Autonomous boot: Only poll return code
      fix.jtag_init();
      fix.jtag_wait_for_eoc(exit_code);
    end

    $finish;
  end

endmodule
