/* SPDX-License-Identifier: Apache-2.0 */
ENTRY(_start)
PHDRS { fixture PT_LOAD FLAGS(5); }
SECTIONS {
  . = 0x80000000;
  .fixture : { *(.fixture) } :fixture
  /DISCARD/ : { *(.riscv.attributes) }
}
