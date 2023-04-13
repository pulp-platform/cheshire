// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "gpt.h"
#include "util.h"

int gpt_check_signature(gpt_read_t read, void *priv) {
    // Signature is first 8 bytes of LBA1 (512B from disk start)
    uint64_t sig;
    // If call fails, we may as well report no signature was found
    if (read(priv, &sig, 0x200, sizeof(sig))) return 0;
    return (sig == 0x5452415020494645UL /*EFI PART*/);
}

int gpt_find_boot_partition(gpt_read_t read, void *priv, uint64_t *lba_begin, uint64_t *lba_end,
                            uint64_t max_lbas) {
    // Read partition-essential info from GPT header
    struct __attribute__((packed)) hdr_fields {
        uint64_t lba;
        uint32_t count;
        uint32_t size;
    } hf;
    uint64_t hf_offs = 0x200 + 0x48;
    CHECK_CALL(read(priv, &hf, hf_offs, sizeof(hf)));
    // The first partition to fit in SPM and fulfill one of the following is our boot partition:
    // * Attributes: bit 2 (BIOS bootable) or 56 (ChromeOS boot success) or 46 (custom) set.
    // * Name: starts with either "firmware" or "cheshire" (UTF16 encoded).
    // If no such partition is found, the first partition (at most an SPM-fitting chunk) is booted.
    struct __attribute__((packed)) part_fields {
        uint64_t lba_begin;
        uint64_t lba_end;
        uint64_t flags;
        uint64_t name_d0;
        uint64_t name_d1;
    } pf;
    uint64_t p;
    for (p = 0; p < hf.count; ++p) {
        // Read first two partition fields for size
        uint64_t pf_offs = 0x200 * hf.lba + p * hf.size + 0x20;
        CHECK_CALL(read(priv, &pf, pf_offs, 2 * sizeof(uint64_t)));
        // Record first partition in any case (but only subset of bootable size)
        if (p == 0) {
            *lba_begin = pf.lba_begin;
            *lba_end = MIN(pf.lba_end, pf.lba_begin + max_lbas - 1);
        }
        // Skip if partition if it is too large to boot
        if (pf.lba_end - pf.lba_begin >= max_lbas) continue;
        // If it does fit in SPM, check our criteria, reading data as needed
        CHECK_CALL(read(priv, &pf.flags, pf_offs + 16, sizeof(uint64_t)));
        if (pf.flags & ((1UL << 2) | (1UL << 46) | (1UL << 46))) break;
        CHECK_CALL(read(priv, &pf.name_d0, pf_offs + 24, 2 * sizeof(uint64_t)));
        if (pf.name_d0 == 0x006d007200690066UL /*firm*/ &&
            pf.name_d1 == 0x0065007200610077UL /*ware*/)
            break;
        if (pf.name_d0 == 0x0073006500680063UL /*ches*/ &&
            pf.name_d1 == 0x0065007200690068UL /*hire*/)
            break;
    }
    // If we did find a viable partition after the first, write out LBA range
    if (p != hf.count) {
        *lba_begin = pf.lba_begin;
        *lba_end = pf.lba_end;
    }
    // Nothing went wrong
    return 0;
}

int gpt_boot_part_else_raw(gpt_read_t read, void *priv, void *code_buf, uint64_t max_lbas) {
    uint64_t lba_begin = 0, lba_end = max_lbas - 1;
    if (gpt_check_signature(read, priv))
        CHECK_CALL(gpt_find_boot_partition(read, priv, &lba_begin, &lba_end, max_lbas))
    // Copy code to SPM (end is *inclusive*, not past-the-end)
    uint64_t addr = 0x200 * lba_begin;
    uint64_t len = 0x200 * (lba_end - lba_begin + 1);
    CHECK_CALL(read(priv, code_buf, addr, len));
    // Invoke code
    return invoke((void *)code_buf);
}
