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
extern void *__chs_bootrom_base_addr__;
extern void *__chs_llc_base_addr__;
extern void *__chs_uart_base_addr__;
extern void *__chs_i2c_base_addr__;
extern void *__chs_spih_base_addr__;
extern void *__chs_gpio_base_addr__;
extern void *__chs_slink_base_addr__;
extern void *__chs_vga_base_addr__;
extern void *__chs_clint_base_addr__;
extern void *__chs_plic_base_addr__;
extern void *__chs_dma_base_addr__;
extern void *__chs_axirt_base_addr__;
extern void *__chs_axirtgrd_base_addr__;
extern void *__chs_bus_err_base_addr__;
extern void *__chs_clic_base_addr__;
extern void *__chs_usb_base_addr__;
extern void *__chs_spm_base_addr__;
extern void *__chs_dram_base_addr__;

// Aliases for external dependencies using legacy __base_* naming
#define __base_axirt __chs_axirt_base_addr__
#define __base_axirtgrd __chs_axirtgrd_base_addr__

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
