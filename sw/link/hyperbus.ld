/* Copyright 2026 ETH Zurich and University of Bologna. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

INCLUDE common.ldh

/* Mapped by the platform, so absent from cheshire_addrs.ldh */
MEMORY {
  hyperbus (rwx) : ORIGIN = 0x70000000, LENGTH = 0x2000000
}

SECTIONS {
  __stack_pointer$  = ORIGIN(hyperbus) + LENGTH(hyperbus) - 8;

  .text : {
    *(.text._start)
    *(.text)
    *(.text.*)
  } > hyperbus

  .misc : ALIGN(16) {
    *(.rodata)
    *(.rodata.*)
    *(.data)
    *(.data.*)
    *(.srodata)
    *(.srodata.*)
    *(.sdata)
    *(.sdata.*)
  } > hyperbus

  .bss : ALIGN(16) {
    __bss_start = .;
    *(.bss)
    *(.bss.*)
    *(.sbss)
    *(.sbss.*)
    __bss_end = .;
  } > hyperbus

  .bulk : ALIGN(16) {
    *(.bulk)
    *(.bulk.*)
  } > hyperbus
}
