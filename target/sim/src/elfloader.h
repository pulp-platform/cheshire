// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// Interface of the ELF loader, used through DPI by SV testbenches and directly by C++ harnesses.

#pragma once

#include <svdpi.h>

#ifdef __cplusplus
extern "C" {
#endif

// Parse an ELF file and register its loadable segments; returns nonzero on failure.
char read_elf(const char *filename);

// Get the entry point of the last read ELF file.
char get_entry(long long *entry_ret);

// Iterate over loadable segments; returns 1 while there are more segments to load.
char get_section(long long *address_ret, long long *len_ret);

// Copy the file contents of the segment at `address` into an SV open array.
char read_section(long long address, const svOpenArrayHandle buffer, long long len);

// Copy the file contents of the segment at `address` into a raw buffer of `len` bytes.
// Bytes beyond the file contents (e.g. `.bss`) are left untouched.
char read_section_raw(long long address, char *buf, long long len);

#ifdef __cplusplus
}
#endif
