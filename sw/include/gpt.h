// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>

extern int boot_next_stage(void *);

typedef int (*gpt_read_t)(void *priv, void *buf, uint64_t addr, uint64_t len);

int gpt_check_signature(gpt_read_t read, void *priv);

// Either the partition type or identity must match
int gpt_find_partition(gpt_read_t read, void *priv, int64_t *part_idx, uint64_t *lba_begin,
                       uint64_t *lba_end, uint64_t max_lbas, const uint64_t *tguid,
                       const uint64_t *pguid);

int gpt_boot_part_else_raw(gpt_read_t read, void *priv, void *code_buf, uint64_t max_lbas,
                           const uint64_t *tguid, const uint64_t *pguid);
