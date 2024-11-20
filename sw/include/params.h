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
extern void *__base_regs;
extern void *__base_llc;
extern void *__base_uart;
extern void *__base_i2c;
extern void *__base_spih;
extern void *__base_gpio;
extern void *__base_slink;
extern void *__base_vga;
extern void *__base_clint;
extern void *__base_plic;
extern void *__base_dma;
extern void *__base_axirt;
extern void *__base_axirtgrd;
extern void *__base_bus_err;
extern void *__base_clic;
extern void *__base_usb;
extern void *__base_spm;
extern void *__base_dram;

// Default boot baudrate
static const uint32_t __BOOT_BAUDRATE = 115200;

// Maximum number of LBAs to copy to SPM for boot (48 KiB)
static const uint64_t __BOOT_SPM_MAX_LBAS = 2 * 48;

// Locations for payload and device tree
static void *const __BOOT_ZSL_DTB = (void *)0x80800000;
static void *const __BOOT_ZSL_FW = (void *)0x80000000;

// GUID of zero-stage loader partition we boot from
static const uint64_t __BOOT_ZSL_TYPE_GUID[2] = {0x4CE4FD950269B26AUL, 0x622C41011494CF98UL};

// GUID of flattened device tree blob
static const uint64_t __BOOT_DTB_TYPE_GUID[2] = {0x42DE2AEFBA442F61UL, 0x9DCB3A5DD7E43392UL};

// GUID of firmware partition we boot into
static const uint64_t __BOOT_FW_TYPE_GUID[2] = {0x4B0D3F5B99EC86DAUL, 0x59F8A5CFBAC44B8FUL};
