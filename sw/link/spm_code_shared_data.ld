/* Copyright 2022 ETH Zurich and University of Bologna. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Nicole Narr <narrn@student.ethz.ch> */
/* Christopher Reinwardt <creinwar@student.ethz.ch> */
/* Paul Scheffler <paulsc@iis.ee.ethz.ch> */

INCLUDE common.ldh

SECTIONS {
  /* change this between > spm and > dram */
  .shared_data : ALIGN(16) {
    *(.shared_data)
    . = ALIGN(16K);
  } > dram

  .text : {
    /* ignore first way so we can map it as LLC cache instead.
       this is unnecessary if shared_data is in spm, but for easier */
    . = . + 16K;

    *(.text._start)
    *(.text)
    *(.text.*)
  } > spm

  .misc : ALIGN(16) {
    *(.rodata)
    *(.rodata.*)
    *(.data)
    *(.data.*)
    *(.srodata)
    *(.srodata.*)
    *(.sdata)
    *(.sdata.*)
  } > spm

  .bss : ALIGN(16) {
    __bss_start = .;
    *(.bss)
    *(.bss.*)
    *(.sbss)
    *(.sbss.*)
    __bss_end = .;
  } > spm

  .bulk : ALIGN(16) {
    *(.bulk)
    *(.bulk.*)
  } > spm

  .results : ALIGN(16) {
    *(.results)
  } > spm

  .dram : ALIGN(16K) {
    *(.dram)
  } > dram
}
