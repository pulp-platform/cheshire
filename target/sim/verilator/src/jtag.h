// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// JTAG driver for the RISC-V debug transport module, mirroring the `riscv_dbg` driver in
// `riscv-dbg/tb/jtag_dmi/jtag_test.sv` used by `vip_cheshire_soc`. Accesses are blocking and
// advance the simulation through a callback running one system clock cycle.

#pragma once

#include <cstdint>
#include <functional>

#include "Vcheshire_top_verilator.h"

class JtagDmi {
  public:
    // JTAG instructions and DMI parameters of `dmi_jtag`
    static constexpr unsigned IrLength = 5;
    static constexpr unsigned IrIdcode = 0x01;
    static constexpr unsigned IrDtmcs = 0x10;
    static constexpr unsigned IrDmi = 0x11;
    static constexpr unsigned DmiAbits = 7;
    static constexpr unsigned DmiWidth = DmiAbits + 32 + 2;
    static constexpr unsigned OpNop = 0;
    static constexpr unsigned OpRead = 1;
    static constexpr unsigned OpWrite = 2;
    static constexpr unsigned OpBusy = 3;

    // TCK runs at a quarter of the system clock (20 ns at 5 ns), as in `vip_cheshire_soc`
    static constexpr unsigned TckDiv = 4;

    JtagDmi(Vcheshire_top_verilator *top, std::function<void()> tick,
            std::function<uint64_t()> cycle)
        : top_(top), tick_(std::move(tick)), cycle_(std::move(cycle)) {
    }

    // Drive TCK for system clock cycle `cycle`; call before evaluating the falling edge.
    void drive(uint64_t cycle) {
        if (active_) top_->jtag_tck_i = (cycle % TckDiv) >= TckDiv / 2;
    }

    // Start the free-running TCK and reset the TAP like `reset_master`. As the TAP resets to
    // Run-Test/Idle, we additionally soft-reset it to return to Run-Test/Idle from a known state.
    void reset_master() {
        active_ = true;
        top_->jtag_tms_i = 1;
        top_->jtag_tdi_i = 0;
        top_->jtag_trst_ni = 0;
        clock(1, 0);
        clock(1, 0);
        top_->jtag_trst_ni = 1;
        for (unsigned i = 0; i < 6; ++i) clock(1, 0); // Test-Logic-Reset
        clock(0, 0);                                  // Run-Test/Idle
        ir_ = IrIdcode;
    }

    void wait_idle(unsigned cycles) {
        for (unsigned i = 0; i < cycles; ++i) clock(0, 0);
    }

    uint32_t get_idcode() {
        set_ir(IrIdcode);
        return uint32_t(shift_dr(0, 32));
    }

    void reset_dmi() {
        set_ir(IrDtmcs);
        shift_dr(1u << 16, 32); // dmireset
    }

    void write_dmi(unsigned addr, uint32_t data) {
        set_ir(IrDmi);
        shift_dr(dmi_word(addr, data, OpWrite), DmiWidth);
    }

    // Issue a DMI read and return its response op (status) and data
    unsigned read_dmi(unsigned addr, uint32_t &data, unsigned wait_cycles = 10) {
        set_ir(IrDmi);
        shift_dr(dmi_word(addr, 0, OpRead), DmiWidth);
        wait_idle(wait_cycles);
        uint64_t rsp = shift_dr(dmi_word(addr, 0, OpNop), DmiWidth);
        data = uint32_t(rsp >> 2);
        return unsigned(rsp & 3);
    }

    // Repeat DMI reads with exponentially increasing delays until they do not report busy
    uint32_t read_dmi_exp_backoff(unsigned addr) {
        uint32_t data;
        unsigned wait_cycles = 8;
        for (unsigned trial = 0;; ++trial, wait_cycles *= 2) {
            if (trial) reset_dmi();
            if (read_dmi(addr, data, wait_cycles) != OpBusy) return data;
        }
    }

  private:
    static uint64_t dmi_word(unsigned addr, uint32_t data, unsigned op) {
        return (uint64_t(addr) << 34) | (uint64_t(data) << 2) | op;
    }

    // Apply TMS and TDI after a rising TCK edge and return TDO sampled before the next one.
    bool clock(bool tms, bool tdi) {
        top_->jtag_tms_i = tms;
        top_->jtag_tdi_i = tdi;
        // Run until the next cycle raises TCK, then sample TDO and let TCK rise
        do tick_();
        while (cycle_() % TckDiv != TckDiv / 2);
        bool tdo = top_->jtag_tdo_o;
        tick_();
        return tdo;
    }

    // Shift `len` bits LSB first and leave the shift state with the last bit
    uint64_t shift_bits(uint64_t data, unsigned len) {
        uint64_t out = 0;
        for (unsigned i = 0; i < len; ++i)
            out |= uint64_t(clock(i == len - 1, (data >> i) & 1)) << i;
        return out;
    }

    // Set IR from Run-Test/Idle, but only if it needs to be changed
    void set_ir(unsigned ir) {
        if (ir_ == ir) return;
        clock(1, 0); // Select-DR-Scan
        clock(1, 0); // Select-IR-Scan
        clock(0, 0); // Capture-IR
        clock(0, 0); // Shift-IR
        shift_bits(ir, IrLength);
        clock(1, 0); // Update-IR
        clock(0, 0); // Run-Test/Idle
        ir_ = ir;
    }

    // Shift a DR from Run-Test/Idle and return to it, returning the captured bits
    uint64_t shift_dr(uint64_t data, unsigned len) {
        clock(1, 0); // Select-DR-Scan
        clock(0, 0); // Capture-DR
        clock(0, 0); // Shift-DR
        uint64_t out = shift_bits(data, len);
        clock(1, 0); // Update-DR
        clock(0, 0); // Run-Test/Idle
        return out;
    }

    Vcheshire_top_verilator *top_;
    std::function<void()> tick_;
    std::function<uint64_t()> cycle_;
    bool active_ = false;
    unsigned ir_ = IrIdcode;
};
