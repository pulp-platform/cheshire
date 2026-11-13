// Copyright 2026 CheshireAra contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// This ELF contains loader test bytes. It is never executed by a CPU.
.section .fixture,"ax",@progbits
.global fixture_start
fixture_start:
.set byte_index, 0
.rept IMAGE_BYTES
.byte (byte_index * 13 + IMAGE_TAG) & 255
.set byte_index, byte_index + 1
.endr
.global _start
.set _start, fixture_start + ENTRY_OFFSET
