// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Date:   05.12.2022

#include <stddef.h>

#include "gpt.h"
#include "printf.h"

int gpt_info(int (*read_blocks)(void *priv, unsigned int lba, void *buf, unsigned int count), void *priv) {
    // Ignore LBA0
    // Load LBA1
    uint8_t lba1_buf[BLOCK_SIZE] = {0};
    uint8_t lba2_buf[BLOCK_SIZE] = {0};
    gpt_header_t *gpt_header = (gpt_header_t *)lba1_buf;

    // Copy header
    int ret = read_blocks(priv, 1, (void *) lba1_buf, 1);

    if (ret != 0) {
        printf("SD card copy of header failed!\r\n");
        return ret;
    }

    printf("GPT partition table header:\r\n");
    printf("\tsignature:\t 0x%lx\r\n", gpt_header->signature);
    printf("\trevision:\t 0x%x\r\n", gpt_header->revision);
    printf("\theader size:\t\t 0x%x\r\n", gpt_header->header_size);
    printf("\treserved:\t 0x%x\r\n", gpt_header->reserved);
    printf("\tmy lba:\t 0x%lx\r\n", gpt_header->my_lba);
    printf("\talternate lba:\t 0x%lx\r\n", gpt_header->alternate_lba);
    printf("\tpartition entry lba:\t 0x%lx\r\n", gpt_header->partition_entry_lba);
    printf("\tnumber partition entries:\t %d\r\n", gpt_header->nr_partition_entries);
    printf("\tsize partition entries:  \t %d\r\n", gpt_header->size_partition_entry);

    // Copy partition entries
    ret = read_blocks(priv, gpt_header->partition_entry_lba, (void *) lba2_buf, 1);

    if (ret != 0) {
        printf("SD card copy of partition entries failed!\r\n");
        return ret;
    }

    for (int i = 0; i < 4; i++) {
        partition_entry_t *part_entry = (partition_entry_t *)(lba2_buf + (i * 128));
        printf("GPT partition entry %d\r\n", i);
        // printf("\tpartition type guid:\t");
        // for (int j = 0; j < 16; j++)
        //    printf("%i", part_entry->partition_type_guid[j]);
        // printf("\r\n");
        // printf("\tpartition guid:     \t");
        // for (int j = 0; j < 16; j++)
        //    printf("%", part_entry->partition_guid[j]);
        printf("\tfirst lba:\t 0x%lx\r\n", part_entry->starting_lba);
        printf("\tlast lba:\t 0x%lx\r\n", part_entry->ending_lba);
        printf("\tattributes:\t 0x%lx\r\n", part_entry->attributes);
        printf("\tname:\t");
        for (int j = 0; j < 72; j++)
            printf("%c", part_entry->partition_name[j]);
        printf("\r\n");
    }

    return 0;
}

int gpt_find_partition(int (*read_blocks)(void *priv, unsigned int lba, void *buf, unsigned int count), void *priv,
                        unsigned int part, unsigned int *start_lba, unsigned int *end_lba) {
    // Ignore LBA0
    // Load LBA1
    uint8_t lba1_buf[BLOCK_SIZE] = {0};
    uint8_t lba2_buf[BLOCK_SIZE] = {0};
    gpt_header_t *gpt_header = (gpt_header_t *)lba1_buf;

    // Copy header
    int ret = read_blocks(priv, 1, (void *) lba1_buf, 1);

    if (ret != 0) {
        printf("Copying the header failed!\r\n");
        return ret;
    }


    // Copy partition entries
    ret = read_blocks(priv, gpt_header->partition_entry_lba, (void *) lba2_buf, 1);

    if (ret != 0) {
        printf("Copying the partition entries failed!\r\n");
        return ret;
    }

    partition_entry_t *part_entry = (partition_entry_t *)(lba2_buf + (part * 128));

    if(start_lba)
        *start_lba = part_entry->starting_lba;

    if(end_lba)
        *end_lba = part_entry->ending_lba;

    return 0;
}
