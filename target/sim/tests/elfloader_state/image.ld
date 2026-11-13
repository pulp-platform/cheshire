/* Copyright 2026 CheshireAra contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */
ENTRY(_start)
PHDRS { fixture PT_LOAD FLAGS(5); }
SECTIONS {
  . = 0x80000000;
  .fixture : { *(.fixture) } :fixture
  /DISCARD/ : { *(.riscv.attributes) }
}
