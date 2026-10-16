// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// Byte-addressable memory over the full 64-bit space, allocated lazily in zero-filled pages.

#pragma once

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <memory>
#include <unordered_map>

class SparseMem {
  public:
    // Read the 64-bit word containing `addr`
    uint64_t read64(uint64_t addr) {
        uint64_t data = 0;
        if (const uint8_t *p = page(addr, false)) memcpy(&data, p + offs(addr & ~7ull), 8);
        return data;
    }

    // Write the bytes enabled by `strb` in the 64-bit word containing `addr`
    void write64(uint64_t addr, uint64_t data, uint8_t strb) {
        uint8_t *p = page(addr, true) + offs(addr & ~7ull);
        for (int i = 0; i < 8; ++i)
            if ((strb >> i) & 1) p[i] = uint8_t(data >> (8 * i));
    }

    void write(uint64_t addr, const uint8_t *buf, uint64_t len) {
        while (len) {
            uint64_t chunk = std::min<uint64_t>(len, PageSize - offs(addr));
            memcpy(page(addr, true) + offs(addr), buf, chunk);
            addr += chunk;
            buf += chunk;
            len -= chunk;
        }
    }

  private:
    static constexpr unsigned PageBits = 20;
    static constexpr uint64_t PageSize = 1ull << PageBits;

    static uint64_t offs(uint64_t addr) {
        return addr & (PageSize - 1);
    }

    uint8_t *page(uint64_t addr, bool alloc) {
        uint64_t idx = addr >> PageBits;
        if (idx == last_idx_ && last_page_) return last_page_;
        auto it = pages_.find(idx);
        if (it == pages_.end()) {
            if (!alloc) return nullptr;
            it = pages_.emplace(idx, std::unique_ptr<uint8_t[]>(new uint8_t[PageSize]())).first;
        }
        last_idx_ = idx;
        last_page_ = it->second.get();
        return last_page_;
    }

    std::unordered_map<uint64_t, std::unique_ptr<uint8_t[]>> pages_;
    uint64_t last_idx_ = ~0ull;
    uint8_t *last_page_ = nullptr;
};
