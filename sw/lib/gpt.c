// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "gpt.h"
#include "util.h"
#include "regs/cheshire.h"
#include "params.h"

int gpt_check_signature(gpt_read_t read, void *priv) {
    // Signature is first 8 bytes of LBA1 (512B from disk start)
    uint64_t sig;
    // If call fails, we may as well report no signature was found
    if (read(priv, &sig, 0x200, sizeof(sig))) return 0;
    return (sig == 0x5452415020494645UL /*EFI PART*/);
}

int gpt_find_partition(gpt_read_t read, void *priv, int64_t *part_idx, uint64_t *lba_begin,
                       uint64_t *lba_end, uint64_t max_lbas, const uint64_t *tguid,
                       const uint64_t *pguid) {
    // Read partition-essential info from GPT header
    struct __attribute__((packed)) hdr_fields {
        uint64_t lba;
        uint32_t count;
        uint32_t size;
    } hf;
    uint64_t hf_offs = 0x200 + 0x48;
    CHECK_CALL(read(priv, &hf, hf_offs, sizeof(hf)));
    // Find the first partition to fit in `max_lbas` and match the passed type or partition GUID.
    // If no such partition is found, the first partition (at most a `max_lbas` chunk) is booted.
    struct __attribute__((packed)) part_fields {
        uint64_t lba_begin;
        uint64_t lba_end;
    } dim;
    int64_t p;
    uint64_t guid[2];
    for (p = 0; p < hf.count; ++p) {
        // Read first two partition fields for size
        uint64_t pe_offs = 0x200 * hf.lba + p * hf.size;
        CHECK_CALL(read(priv, &dim, pe_offs + 0x20, sizeof(dim)));
        // Record first partition in any case (but only subset of bootable size)
        if (p == 0) {
            *lba_begin = dim.lba_begin;
            *lba_end = MIN(dim.lba_end, dim.lba_begin + max_lbas - 1);
        }
        // Skip if partition if it is too large to fit our criteria
        if (dim.lba_end - dim.lba_begin >= max_lbas) continue;
        // If it does fit in SPM, check our criteria, reading data as needed
        if (tguid) {
            CHECK_CALL(read(priv, &guid[0], pe_offs, sizeof(guid)))
            if (guid[0] == tguid[0] && guid[1] == tguid[1]) break;
        }
        if (pguid) {
            CHECK_CALL(read(priv, &guid[0], pe_offs + 0x10, sizeof(guid)))
            if (guid[0] == pguid[0] && guid[1] == pguid[1]) break;
        }
    }
    // If we did find a viable partition after the first, write out LBA range
    *part_idx = -1;
    if (p != hf.count) {
        *part_idx = p;
        *lba_begin = dim.lba_begin;
        *lba_end = dim.lba_end;
    }
    // Nothing went wrong
    return 0;
}

int gpt_boot_part_else_raw(gpt_read_t read, void *priv, void *code_buf, uint64_t max_lbas,
                           const uint64_t *tguid, const uint64_t *pguid) {
    uint64_t lba_begin = 0, lba_end = max_lbas - 1;
    int64_t part_idx;
    if (gpt_check_signature(read, priv))
        CHECK_CALL(
            gpt_find_partition(read, priv, &part_idx, &lba_begin, &lba_end, max_lbas, tguid, pguid))
    // Copy code to SPM (end is *inclusive*, not past-the-end)
    uint64_t addr = 0x200 * lba_begin;
    uint64_t len = 0x200 * (lba_end - lba_begin + 1);
    CHECK_CALL(read(priv, code_buf, addr, len));
    // Write pointers for used read function to scratch registers for use in following stages
    *reg32(&__base_regs, CHESHIRE_SCRATCH_0_REG_OFFSET) = (uintptr_t)((void *)read) | 1;
    *reg32(&__base_regs, CHESHIRE_SCRATCH_1_REG_OFFSET) = (uintptr_t)priv;
    *reg32(&__base_regs, CHESHIRE_SCRATCH_3_REG_OFFSET) = (uintptr_t)gprw(0);
    // Invoke code
    return boot_next_stage((void *)code_buf);
}
