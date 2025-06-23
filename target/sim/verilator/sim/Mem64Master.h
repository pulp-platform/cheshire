// Copyright 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Max Wipfli <mwipfli@student.ethz.ch>

#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <queue>

// 64-bit memory interface master (currently only supporting aligned 64-bit writes)
class Mem64Master {
private:
    struct WriteTransaction {
        uint64_t addr;
        uint64_t data;
    };

public:
    Mem64Master(
        uint8_t*  mem_req_o,
        uint64_t* mem_addr_o,
        uint8_t*  mem_we_o,
        uint64_t* mem_wdata_o,
        uint8_t*  mem_be_o,
        uint8_t*  mem_gnt_i
    ) : m_mem_req_o(mem_req_o)
      , m_mem_addr_o(mem_addr_o)
      , m_mem_we_o(mem_we_o)
      , m_mem_wdata_o(mem_wdata_o)
      , m_mem_be_o(mem_be_o)
      , m_mem_gnt_i(mem_gnt_i) {
        // zero all outputs
        *m_mem_req_o = 0;
        *m_mem_addr_o = 0;
        *m_mem_we_o = 0;
        *m_mem_wdata_o = 0;
        *m_mem_be_o = 0;
    }

    void write(uint64_t addr, uint64_t data) {
        m_write_queue.push({ addr, data });
    }

    void write_chunk(uint64_t addr, void *data, size_t bytes) {
        assert(addr % sizeof(uint64_t) == 0 && "unaligned writes not yet supported");
        assert(bytes % sizeof(uint64_t) == 0 && "unaligned write size not yet supported");

        for (size_t i = 0; i < bytes; i += sizeof(uint64_t)) {
            uint64_t word;
            memcpy(&word, (char *)data + i, sizeof(uint64_t));
            write(addr + i, word);
        }
    }

    // handle before @(posedge clk): reads signals, does not modify signals
    void handle_before() {
        m_handshake = (*m_mem_req_o && *m_mem_gnt_i);
    }

    // handle before @(posedge clk): modifies signals for next cycle
    void handle_after() {
        if (m_handshake) {
            // current request was handled
            m_handshake = false;
            *m_mem_req_o = 0;
        }

        if (!*m_mem_req_o && !m_write_queue.empty()) {
            // apply new request
            const auto& transaction = m_write_queue.front();
            *m_mem_req_o   = 1;
            *m_mem_addr_o  = transaction.addr;
            *m_mem_we_o    = 1;
            *m_mem_wdata_o = transaction.data;
            *m_mem_be_o    = 0xff;
            m_write_queue.pop();
            if (m_write_queue.empty()) {
                printf("Mem64Master: emptied write queue\n");
            }
        }
    }

private:
    // holds pairs of (addr, data)
    std::queue<WriteTransaction> m_write_queue;

    // handshake detected
    bool m_handshake;

    // interface
    uint8_t*  m_mem_req_o;
    uint64_t* m_mem_addr_o;
    uint8_t*  m_mem_we_o;
    uint64_t* m_mem_wdata_o;
    uint8_t*  m_mem_be_o;
    uint8_t*  m_mem_gnt_i;
};
