// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// UART (8N1) receiver and transmitter for the SoC UART, behaving like `vip_cheshire_soc`.

#pragma once

#include <cstdint>
#include <cstdio>
#include <deque>
#include <string>

// Samples the SoC TX line and prints received lines. Received bytes can instead be scooped
// by the UART debug protocol, and the end-of-computation byte is flagged.
class UartRx {
  public:
    static constexpr uint8_t DebugEoc = 0x14;

    explicit UartRx(uint64_t baud) : bit_ps_(1000000000000ull / baud) {
    }

    // Sample the line at time `t` (ps); call at least once per system clock cycle.
    void sample(uint64_t t, bool tx) {
        switch (state_) {
        case Idle:
            if (prev_ && !tx) {
                state_ = Start;
                next_ = t + bit_ps_ / 2;
            }
            break;
        case Start:
            if (t >= next_) {
                // A start bit holds the line low until mid-bit; shorter pulses are noise
                state_ = tx ? Idle : Data;
                bit_ = 0;
                byte_ = 0;
                next_ += bit_ps_;
            }
            break;
        case Data:
            if (t >= next_) {
                byte_ |= uint8_t(tx) << bit_;
                next_ += bit_ps_;
                if (++bit_ == 8) state_ = Stop;
            }
            break;
        case Stop:
            if (t >= next_) {
                state_ = Idle;
                receive(byte_);
            }
            break;
        }
        prev_ = tx;
    }

    bool busy() const {
        return state_ != Idle;
    }

    // Divert the next `n` received bytes from the console output into the scoop queue
    void scoop(unsigned n) {
        scoop_req_ += n;
    }

    bool scooped() const {
        return !scooped_.empty();
    }

    uint8_t pop_scooped() {
        uint8_t c = scooped_.front();
        scooped_.pop_front();
        return c;
    }

    // Whether the end-of-computation byte was received; clears the flag
    bool take_eoc() {
        bool eoc = eoc_;
        eoc_ = false;
        return eoc;
    }

    // Watch the output for `text`, which may end a partial line (e.g. a shell prompt).
    // A leading `^` anchors it to the start of the line.
    void expect(const std::string &text) {
        expect_ = text;
        matched_ = false;
    }

    // Whether the expected text was received; clears the flag
    bool take_match() {
        bool m = matched_;
        matched_ = false;
        return m;
    }

    // Print any partial line left in the buffer
    void flush() {
        if (!line_.empty()) print_line();
    }

  private:
    void receive(uint8_t c) {
        if (scoop_req_) {
            --scoop_req_;
            scooped_.push_back(c);
        } else if (c == '\n') {
            print_line();
        } else if (c == DebugEoc) {
            eoc_ = true;
        } else if (c != '\r') {
            line_.push_back(char(c));
            if (!expect_.empty() && line_matches_expected()) {
                matched_ = true;
                expect_.clear();
            }
        }
    }

    bool line_matches_expected() const {
        if (expect_[0] == '^') return line_.compare(0, std::string::npos, expect_, 1) == 0;
        return line_.size() >= expect_.size() &&
               line_.compare(line_.size() - expect_.size(), expect_.size(), expect_) == 0;
    }

    void print_line() {
        printf("[UART] %s\n", line_.c_str());
        line_.clear();
    }

    enum State { Idle, Start, Data, Stop };

    uint64_t bit_ps_;
    State state_ = Idle;
    bool prev_ = true;
    uint64_t next_ = 0;
    unsigned bit_ = 0;
    uint8_t byte_ = 0;
    std::string line_;
    unsigned scoop_req_ = 0;
    std::deque<uint8_t> scooped_;
    bool eoc_ = false;
    std::string expect_;
    bool matched_ = false;
};

// Drives the SoC RX line with queued bytes.
class UartTx {
  public:
    explicit UartTx(uint64_t baud) : bit_ps_(1000000000000ull / baud) {
    }

    void send(uint8_t c) {
        queue_.push_back(c);
    }

    // Idle time (ps) inserted after each frame, e.g. to pace typed input
    void set_gap(uint64_t gap_ps) {
        gap_ps_ = gap_ps;
    }

    bool idle() const {
        return queue_.empty() && bit_ < 0;
    }

    // Return the line level at time `t` (ps); call at least once per system clock cycle.
    bool line(uint64_t t) {
        if (bit_ < 0) {
            if (queue_.empty() || t < next_) return true;
            frame_ = uint16_t(queue_.front()) << 1 | 0x200; // start bit, data, stop bit
            queue_.pop_front();
            bit_ = 0;
            next_ = t + bit_ps_;
        } else if (t >= next_) {
            if (++bit_ == 10) {
                // The next frame may start right at the end of the stop bit, or after the gap
                bit_ = -1;
                next_ += gap_ps_;
                return line(t);
            }
            next_ += bit_ps_;
        }
        return (frame_ >> bit_) & 1;
    }

  private:
    uint64_t bit_ps_;
    std::deque<uint8_t> queue_;
    uint16_t frame_ = 0;
    int bit_ = -1;
    uint64_t next_ = 0;
    uint64_t gap_ps_ = 0;
};
