// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#pragma once

#include "opentitan_qspi.h"
#include <stdint.h>

#define BLOCK_SIZE 512

// LBA 0: Protective MBR
// ignored here

// Partition Table Header (LBA 1)
typedef struct gpt_header {
    uint64_t signature;
    uint32_t revision;
    uint32_t header_size; //! little endian, usually 0x5c = 92
    uint32_t header_crc32;
    uint32_t reserved; //! must be 0
    uint64_t my_lba;
    uint64_t alternate_lba;
    uint64_t first_usable_lba;
    uint64_t last_usable_lba;
    uint8_t disk_guid[16];
    uint64_t partition_entry_lba;
    uint32_t nr_partition_entries;
    uint32_t size_partition_entry; //! usually 0x80 = 128
    uint32_t partition_entry_crc32;
} gpt_header_t;

// Partition Entries (LBA 2-33)
typedef struct partition_entry {
    uint8_t partition_type_guid[16];
    uint8_t partition_guid[16];
    uint64_t starting_lba;
    uint64_t ending_lba; //! inclusive
    uint64_t attributes;
    uint8_t partition_name[72]; //! utf16 encoded
} partition_entry_t;

// Print info about partitions
int gpt_info(int (*read_blocks)(void *priv, unsigned int lba, void *buf, unsigned int count), void *priv);

// Find partition and load it to the destination
int gpt_find_partition(int (*read_blocks)(void *priv, unsigned int lba, void *buf, unsigned int count), void *priv,
                       unsigned int part, unsigned int *start_lba, unsigned int *end_lba);
