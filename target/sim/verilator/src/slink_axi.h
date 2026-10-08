// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// AXI4 master driving the mirror serial link port of `cheshire_top_verilator`. It issues INCR
// bursts with a single ID on the 64-bit data bus, allowing multiple bursts in flight.

#pragma once

#include <cinttypes>
#include <cstdint>
#include <cstdio>
#include <deque>
#include <stdexcept>
#include <vector>

#include "Vcheshire_top_verilator.h"

class SlinkAxi {
  public:
    explicit SlinkAxi(Vcheshire_top_verilator *top) : top_(top) {
    }

    void set_debug(bool en) {
        debug_ = en;
    }

    // Enqueue a write burst starting at `addr` with one strobe byte per 64-bit data beat.
    void write(uint64_t addr, unsigned size, std::vector<uint64_t> data,
               std::vector<uint8_t> strb) {
        aw_q_.push_back({addr, size, std::move(data), std::move(strb)});
    }

    // Enqueue a read burst of `len + 1` beats starting at `addr`.
    void read(uint64_t addr, unsigned size, unsigned len) {
        ar_q_.push_back({addr, size, len});
    }

    // Whether all enqueued bursts have completed
    bool idle() const {
        return aw_q_.empty() && w_q_.empty() && !b_pending_ && ar_q_.empty() && !r_pending_;
    }

    // Pop the oldest received read beat
    uint64_t pop_rdata() {
        uint64_t data = rdata_.front();
        rdata_.pop_front();
        return data;
    }

    unsigned errors() const {
        return errors_;
    }

    // Drive channels after the falling clock edge
    void drive() {
        top_->slink_aw_valid_i = !aw_q_.empty();
        if (!aw_q_.empty()) {
            const WrBurst &aw = aw_q_.front();
            top_->slink_aw_addr_i = aw.addr;
            top_->slink_aw_len_i = aw.data.size() - 1;
            top_->slink_aw_size_i = aw.size;
        }
        top_->slink_w_valid_i = !w_q_.empty();
        if (!w_q_.empty()) {
            const WrBurst &w = w_q_.front();
            top_->slink_w_data_i = w.data[w_beat_];
            top_->slink_w_strb_i = w.strb[w_beat_];
            top_->slink_w_last_i = (w_beat_ + 1 == w.data.size());
        }
        top_->slink_ar_valid_i = !ar_q_.empty();
        if (!ar_q_.empty()) {
            const RdBurst &ar = ar_q_.front();
            top_->slink_ar_addr_i = ar.addr;
            top_->slink_ar_len_i = ar.len;
            top_->slink_ar_size_i = ar.size;
        }
        top_->slink_b_ready_i = 1;
        top_->slink_r_ready_i = 1;
    }

    // Sample handshakes before the rising clock edge
    void sample() {
        aw_hs_ = top_->slink_aw_valid_i && top_->slink_aw_ready_o;
        w_hs_ = top_->slink_w_valid_i && top_->slink_w_ready_o;
        ar_hs_ = top_->slink_ar_valid_i && top_->slink_ar_ready_o;
        b_hs_ = top_->slink_b_valid_o;
        b_resp_ = top_->slink_b_resp_o;
        r_hs_ = top_->slink_r_valid_o;
        r_data_ = top_->slink_r_data_o;
        r_resp_ = top_->slink_r_resp_o;
        r_last_ = top_->slink_r_last_o;
    }

    // Update state after the rising clock edge
    void commit(uint64_t cycle) {
        if (aw_hs_) {
            if (debug_)
                printf("[SLINK] %9" PRIu64 ": AW 0x%016" PRIx64 " len %zu size %u\n", cycle,
                       aw_q_.front().addr, aw_q_.front().data.size() - 1, aw_q_.front().size);
            w_q_.push_back(std::move(aw_q_.front()));
            aw_q_.pop_front();
            ++b_pending_;
        }
        // W beats only start in the cycle after their AW, so this never precedes the push above
        if (w_hs_ && ++w_beat_ == w_q_.front().data.size()) {
            w_q_.pop_front();
            w_beat_ = 0;
        }
        if (b_hs_) {
            if (debug_) printf("[SLINK] %9" PRIu64 ": B resp %u\n", cycle, b_resp_);
            if (!b_pending_) throw std::runtime_error("Unexpected serial link B response");
            --b_pending_;
            check_resp("write", b_resp_);
        }
        if (ar_hs_) {
            if (debug_)
                printf("[SLINK] %9" PRIu64 ": AR 0x%016" PRIx64 " len %u size %u\n", cycle,
                       ar_q_.front().addr, ar_q_.front().len, ar_q_.front().size);
            ar_q_.pop_front();
            ++r_pending_;
        }
        if (r_hs_) {
            if (debug_)
                printf("[SLINK] %9" PRIu64 ": R data 0x%016" PRIx64 " resp %u%s\n", cycle, r_data_,
                       r_resp_, r_last_ ? " last" : "");
            if (!r_pending_) throw std::runtime_error("Unexpected serial link R response");
            rdata_.push_back(r_data_);
            check_resp("read", r_resp_);
            if (r_last_) --r_pending_;
        }
    }

  private:
    struct WrBurst {
        uint64_t addr;
        unsigned size;
        std::vector<uint64_t> data;
        std::vector<uint8_t> strb;
    };

    struct RdBurst {
        uint64_t addr;
        unsigned size;
        unsigned len;
    };

    void check_resp(const char *kind, unsigned resp) {
        if (resp) {
            printf("[SLINK] Error: %s error response %u\n", kind, resp);
            ++errors_;
        }
    }

    Vcheshire_top_verilator *top_;
    bool debug_ = false;

    std::deque<WrBurst> aw_q_; // Waiting for AW handshake
    std::deque<WrBurst> w_q_;  // AW done, W beats pending
    size_t w_beat_ = 0;
    unsigned b_pending_ = 0;
    std::deque<RdBurst> ar_q_;
    unsigned r_pending_ = 0;
    std::deque<uint64_t> rdata_;
    unsigned errors_ = 0;

    // Handshakes sampled before the rising edge
    bool aw_hs_ = false, w_hs_ = false, ar_hs_ = false, b_hs_ = false, r_hs_ = false;
    unsigned b_resp_ = 0, r_resp_ = 0;
    bool r_last_ = false;
    uint64_t r_data_ = 0;
};
