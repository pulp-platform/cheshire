// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Modified version of the RISC-V Frontend Server 
// (https://github.com/riscvarchive/riscv-fesvr, e41cfc3001293b5625c25412bd9b26e6e4ab8f7e)
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Max Wipfli <mwipfli@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include <svdpi.h>

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

char get_entry(long long *entry_ret);

char get_section(long long *address_ret, long long *len_ret);

char read_section(long long address, const svOpenArrayHandle buffer, long long len);

char read_section_raw(long long address, char *buf, long long len);

char read_elf(const char *filename);

#ifdef __cplusplus
}
#endif
