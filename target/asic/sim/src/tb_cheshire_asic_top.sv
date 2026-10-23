// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Testbench of `cheshire_asic_top` (RTL or netlist): the boot and preload
// sequence of `tb_cheshire_soc` on `fixture_cheshire_asic_top`. Plusargs as
// there: BOOTMODE, PRELMODE (0: JTAG, 1: serial link, 2: UART, 3: memh), BINARY,
// IMAGE. Every change of the GPIO outputs (sampled with the clock, gpio_marker) is
// printed with its time: programs mark the phases of a workload on them (e.g.
// for an activity window).

module tb_cheshire_asic_top #(
  parameter bit      UseDramSys   = 1'b0,
  parameter realtime ClkPeriodSys = 5ns,
  parameter real     TAppl        = 0.1
);

  fixture_cheshire_asic_top #(
    .UseDramSys   ( UseDramSys ),
    .ClkPeriodSys ( ClkPeriodSys ),
    .TAppl        ( TAppl )
  ) fix();

  string      preload_elf;
  string      boot_hex;
  logic [1:0] boot_mode;
  logic [1:0] preload_mode;
  bit [31:0]  exit_code;

  initial begin
    if (!$value$plusargs("BOOTMODE=%d", boot_mode))     boot_mode     = 0;
    if (!$value$plusargs("PRELMODE=%d", preload_mode))  preload_mode  = 0;
    if (!$value$plusargs("BINARY=%s",   preload_elf))   preload_elf   = "";
    if (!$value$plusargs("IMAGE=%s",    boot_hex))      boot_hex      = "";

    fix.vip.set_boot_mode(boot_mode);
    fix.vip.i2c_eeprom_preload(boot_hex);
    fix.vip.spih_norflash_preload(boot_hex);

    fix.vip.wait_for_reset();

    if (boot_mode == 0) begin
      case (preload_mode)
        0: begin      // JTAG
          fix.vip.jtag_init();
          fix.vip.jtag_elf_run(preload_elf);
          fix.vip.jtag_wait_for_eoc(exit_code);
        end 1: begin  // Serial Link
          fix.vip.slink_elf_run(preload_elf);
          fix.vip.slink_wait_for_eoc(exit_code);
        end 2: begin  // UART
          fix.vip.uart_debug_elf_run_and_wait(preload_elf, exit_code);
        end 3: begin  // MEMH
          fix.vip.jtag_init();
          fix.vip.jtag_wait_for_llc_config_halt();
          fix.vip.memh_elf_preload(preload_elf);
          fix.vip.jtag_elf_run_no_preload(preload_elf);
          fix.vip.jtag_wait_for_eoc(exit_code);
        end default: begin
          $fatal(1, "Unsupported preload mode %d (reserved)!", preload_mode);
        end
      endcase
    end else begin
      // Autonomous boot: only poll the return code
      fix.vip.jtag_init();
      fix.vip.jtag_wait_for_eoc(exit_code);
    end

    wait (fix.vip.uart_reading_byte == 0);
    $finish;
  end

  // Workload phase markers on the GPIO outputs, sampled with the clock: with
  // delays, the outputs pass through intermediate values before they settle
  logic [31:0] gpio_marker;

  always @(posedge fix.clk) gpio_marker <= fix.gpio_o;

  always @(gpio_marker) begin
    if (fix.rst_n === 1'b1) $display("[GPIO] %t: 0x%08h", $time, gpio_marker);
  end

endmodule
