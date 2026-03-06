/* Copyright 2022 ETH Zurich and University of Bologna. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Nicole Narr <narrn@student.ethz.ch> */
/* Christopher Reinwardt <creinwar@student.ethz.ch> */
/* Paul Scheffler <paulsc@iis.ee.ethz.ch> */

INCLUDE common.ldh

SECTIONS {
  __stack_pointer$  = ORIGIN(chs_spm) + LENGTH(chs_spm) - 8;

  .text : {
    *(.text._start)
    *(.text)
    *(.text.*)
  } > chs_bootrom

  .misc : ALIGN(16) {
    *(.rodata)
    *(.rodata.*)
    *(.data)
    *(.data.*)
    *(.srodata)
    *(.srodata.*)
    *(.sdata)
    *(.sdata.*)
  } > chs_bootrom

  . = ALIGN(32);
  __bss_start = .;
  .bss : {
    *(.bss)
    *(.bss.*)
    *(.sbss)
    *(.sbss.*)
  } > chs_bootrom
  . = ALIGN(32);
  __bss_end = .;

  .bulk : ALIGN(16) {
    *(.bulk)
    *(.bulk.*)
  } > chs_bootrom
}
