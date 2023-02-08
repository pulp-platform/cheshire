/* Copyright 2022 ETH Zurich and University of Bologna. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Nicole Narr <narrn@student.ethz.ch> */
/* Christopher Reinwardt <creinwar@student.ethz.ch> */

ENTRY(_start)

MEMORY
{
  bootrom (rx)  : ORIGIN = 0x01000000, LENGTH = 4K
  spm (rwx)     : ORIGIN = 0x70000000, LENGTH = 24K
}

SECTIONS
{
  .text : {
    *(.text._start)
    *(.text)
    *(.text.*)
  } > bootrom

  . = ALIGN(16);

  .misc : {
    *(.rodata)
    *(.rodata.*)
    *(.srodata)
    *(.srodata.*)
  } > bootrom

  /DISCARD/ : { *(.riscv.attributes) *(.comment) }
  /* Global and stack pointer */
  __global_pointer$ = ADDR(.misc) + SIZEOF(.misc) / 2;
  __stack_pointer$  = ORIGIN(spm) + LENGTH(spm) - 8;
  /* Further addresses */
  __base_bootrom        = 0x01000000;
  __base_cheshire_regs  = 0x02000000;
  __base_axi_llc        = 0x02001000;
  __base_ddr_link       = 0x02002000;
  __base_uart           = 0x02003000;
  __base_i2c            = 0x02004000;
  __base_spim           = 0x02005000;
  __base_vga            = 0x02006000;
  __base_clint          = 0x04000000;
  __base_clint_mtime    = 0x0400bff8;
  __base_plic           = 0x0c000000;
  __base_dma_conf       = 0x60000000;
  __base_spm            = ORIGIN(spm);
}
