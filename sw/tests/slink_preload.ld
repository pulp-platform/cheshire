/* Copyright 2026 Zhao Wenyao. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

INCLUDE common.ldh

PHDRS {
  payload_a PT_LOAD FLAGS(4);
  payload_b PT_LOAD FLAGS(4);
  program PT_LOAD FLAGS(7);
}

SECTIONS {
  .slink_preload_a ORIGIN(spm) + 0x2000 : {
    KEEP(*(.slink_preload_a))
  } > spm :payload_a

  .slink_preload_b ORIGIN(spm) + 0x200d : {
    KEEP(*(.slink_preload_b))
  } > spm :payload_b

  ASSERT(SIZEOF(.slink_preload_a) == 13 && SIZEOF(.slink_preload_b) == 9,
         "Serial link preload regression requires adjacent 13-byte and 9-byte segments")

  .text ORIGIN(spm) + 0x4000 : {
    *(.text._start)
    *(.text)
    *(.text.*)
  } > spm :program

  .misc : ALIGN(16) {
    *(.rodata) *(.rodata.*)
    *(.data) *(.data.*)
    *(.srodata) *(.srodata.*)
    *(.sdata) *(.sdata.*)
  } > spm :program

  .bss : ALIGN(16) {
    __bss_start = .;
    *(.bss) *(.bss.*) *(.sbss) *(.sbss.*)
    __bss_end = .;
  } > spm :program
}
