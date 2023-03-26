/* Copyright 2022 ETH Zurich and University of Bologna. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Nicole Narr <narrn@student.ethz.ch> */
/* Christopher Reinwardt <creinwar@student.ethz.ch> */

ENTRY(_start)

MEMORY
{
  spm (rwx)     : ORIGIN = 0x10000000, LENGTH = 128K
  dram (rwx)    : ORIGIN = 0x80000000, LENGTH = 1024M
}

SECTIONS
{
  .text : {
    *(.text._start)
    *(.text)
    *(.text.*)
  } > spm

  . = ALIGN(16);

  .misc : {
    *(.rodata)
    *(.rodata.*)
    *(.data)
    *(.data.*)
    *(.srodata)
    *(.srodata.*)
    *(.sdata)
    *(.sdata.*)
  } > spm

  . = ALIGN(32);
  __bss_start = .;
  .bss : {
    *(.bss)
    *(.bss.*)
    *(.sbss)
    *(.sbss.*)
  } > spm
  . = ALIGN(32);
  __bss_end = .;

  .bulk : { 
    KEEP(*(.bulk))
    KEEP(*(.bulk.*))
  } > dram

  /DISCARD/ : { *(.riscv.attributes) *(.comment) }
  /* Global and stack pointer */
  __global_pointer$ = ADDR(.misc) + SIZEOF(.misc) / 2;
  __stack_pointer$  = ORIGIN(spm) + LENGTH(spm) - 8;

  /* Further addresses */
  __base_dma      = 0x01000000;
  __base_bootrom  = 0x02000000;
  __base_clint    = 0x02040000;
  __base_regs     = 0x03000000;
  __base_llc      = 0x03001000;
  __base_uart     = 0x03002000;
  __base_i2c      = 0x03003000;
  __base_spih     = 0x03004000;
  __base_gpio     = 0x03005000;
  __base_slink    = 0x03006000;
  __base_vga      = 0x03007000;
  __base_plic     = 0x04000000;
  __base_spm      = ORIGIN(spm);
  __base_dram     = ORIGIN(dram);
}
