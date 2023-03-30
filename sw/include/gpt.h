// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>

typedef int (*gpt_read_t)(void *priv, void *buf, uint64_t addr, uint64_t len);

int gpt_check_signature(gpt_read_t read, void *priv);

int gpt_find_boot_partition(gpt_read_t read, void *priv, uint64_t *lba_begin, uint64_t *lba_end,
                            uint64_t max_lbas);

int gpt_boot_part_else_raw(gpt_read_t read, void *priv, void *code_buf, uint64_t max_lbas);
