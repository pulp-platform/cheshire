// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
//
// This header provides information defined by hardware parameters, such as
// the address map. In the future, it should be generated automatically as
// part of the SoC generation process.

#pragma once

// Base addresses provided at link time
extern void *__base_bootrom;
extern void *__base_cheshire_regs;
extern void *__base_axi_llc;
extern void *__base_serial_link_cfg;
extern void *__base_uart;
extern void *__base_i2c;
extern void *__base_spim;
extern void *__base_vga;
extern void *__base_clint;
extern void *__base_plic;
extern void *__base_dma;
extern void *__base_spm;
extern void *__base_dram;

// Maximum number of LBAs to copy to SPM for boot (now: 52 KiB)
static const uint64_t __BOOT_SPM_MAX_LBAS = 52*2;
