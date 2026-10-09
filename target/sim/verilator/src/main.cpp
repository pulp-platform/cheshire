// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>
//
// Based on prior work by Max Wipfli <mwipfli@student.ethz.ch>
// and Paul Scheffler <paulsc@iis.ee.ethz.ch>.

// C++ harness for untimed Verilator simulation of Cheshire. It generates clocks and resets, owns
// the simulated memories, and implements the preload and test protocols of `vip_cheshire_soc`.
//
// Plusargs (aligned with `tb_cheshire_soc` where applicable):
//   +BINARY=<elf>      ELF binary to preload and run in passive boot mode
//   +BOOTMODE=<n>      Boot mode (0: passive)
//   +PRELMODE=<n>      Preload mode in passive boot (0: JTAG, 1: serial link, 2: UART,
//                      3: direct DRAM preload with JTAG fallback and control)
//   +PRELOAD_BIN=<file>@<addr>[,...]  Write raw binaries directly into DRAM before simulation
//   +UART_BAUD=<n>     UART baud rate used to decode output (default: 115200)
//   +MAX_CYCLES=<n>    Abort with an error after this many system clock cycles (default: none)
//   +TRACE=<file>      Dump a waveform (only if built with tracing)
//   +TRACE_START=<n>   Start dumping the waveform at system clock cycle n (default: 0)
//   +SLINK_DEBUG       Log all serial link AXI transactions
//   +MEM_DEBUG=<mask>  Log accesses to the simulated memories selected by `mask` (bit i: MemId i)
//   +PROGRESS=<n>      Print simulation progress every n system clock cycles
//   +PC_SAMPLE=<n>     Print the commit-stage PC of hart 0 every n system clock cycles
//   +UART_INPUT=<text> Type text into the SoC UART (escapes: \n, \r, \t, \\)
//   +UART_INPUT_AFTER=<text>  Only type once the UART output contains this text; a leading `^`
//                             anchors it to the start of a line (e.g. `^# ` for a shell prompt)
//   +UART_INPUT_GAP=<n>       Idle system clock cycles between typed characters (default: 20000)

#include <algorithm>
#include <chrono>
#include <cinttypes>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iterator>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

#include "verilated.h"
#if VM_TRACE_FST
#include "verilated_fst_c.h"
using TraceFile = VerilatedFstC;
#elif VM_TRACE_VCD
#include "verilated_vcd_c.h"
using TraceFile = VerilatedVcdC;
#endif

#include "Vcheshire_top_verilator.h"
#include "Vcheshire_top_verilator__Dpi.h"
#include "elfloader.h"
#include "jtag.h"
#include "slink_axi.h"
#include "sparse_mem.h"
#include "uart.h"

// Timing in ps, matching the defaults of `vip_cheshire_soc`
static constexpr uint64_t ClkPeriodSys = 5000;
static constexpr uint64_t RstCycles = 5;

// Idle cycles between status polls, matching `vip_cheshire_soc`
static constexpr unsigned PollIdleLlc = 20;
static constexpr unsigned PollIdleEoc = 800;

// Maximum serial link burst size in bytes, matching `vip_cheshire_soc`
static constexpr uint64_t SlinkBurstBytes = 1024;

// UART debug protocol, matching `vip_cheshire_soc`
static constexpr uint8_t UartDebugCmdWrite = 0x12;
static constexpr uint8_t UartDebugCmdExec = 0x13;
static constexpr uint8_t UartDebugAck = 0x06;
static constexpr uint8_t UartDebugEot = 0x04;
static constexpr uint64_t UartBurstBytes = 256;
static constexpr uint64_t UartWaitBits = 60;

// Debug module registers and fields (see `dm_pkg`)
namespace dm {
static constexpr unsigned Data0 = 0x04;
static constexpr unsigned Data1 = 0x05;
static constexpr unsigned DmControl = 0x10;
static constexpr unsigned DmStatus = 0x11;
static constexpr unsigned AbstractCs = 0x16;
static constexpr unsigned Command = 0x17;
static constexpr unsigned Sbcs = 0x38;
static constexpr unsigned SbAddress0 = 0x39;
static constexpr unsigned SbAddress1 = 0x3a;
static constexpr unsigned SbData0 = 0x3c;
static constexpr unsigned SbData1 = 0x3d;

static constexpr uint32_t DmActive = 1u << 0;
static constexpr uint32_t ResumeReq = 1u << 30;
static constexpr uint32_t HaltReq = 1u << 31;
static constexpr uint32_t AllHalted = 1u << 9;
static constexpr uint32_t AcsBusy = 1u << 12;
static constexpr uint32_t AcsCmdErr = 7u << 8;
static constexpr uint32_t SbReadOnAddr = 1u << 20;
static constexpr uint32_t SbAutoIncr = 1u << 16;
static constexpr uint32_t SbReadOnData = 1u << 15;
static constexpr uint32_t SbBusy = 1u << 21;
static constexpr uint32_t SbBusyError = 1u << 22;
static constexpr uint32_t SbError = 7u << 12;
static constexpr uint32_t sbaccess(unsigned size) {
    return size << 17;
}

// Abstract command writing `data1:data0` to `dpc`
static constexpr uint32_t CmdWriteDpc = 0x003307b1;
} // namespace dm

// Raised to end the simulation early (e.g. timeout or `$finish`)
struct SimAbort : std::runtime_error {
    using std::runtime_error::runtime_error;
};

////////////////
//  Memories  //
////////////////

// Memory IDs as used by `cheshire_vlt_axi_mem` instances in the top level
enum MemId : unsigned { MemDram = 0, MemSlink = 1, NumMems };

static SparseMem mems[NumMems];
static unsigned mem_debug = 0;

static SparseMem &get_mem(unsigned mem_id) {
    if (mem_id >= NumMems) {
        fprintf(stderr, "[VLT] Fatal: access to unknown memory %u\n", mem_id);
        abort();
    }
    return mems[mem_id];
}

// DPI functions imported by `cheshire_vlt_axi_mem`
extern "C" unsigned long long chs_vlt_mem_read(unsigned int mem_id, unsigned long long addr) {
    uint64_t data = get_mem(mem_id).read64(addr);
    if ((mem_debug >> mem_id) & 1)
        printf("[MEM%u] R 0x%016llx: 0x%016" PRIx64 "\n", mem_id, addr, data);
    return data;
}

extern "C" void chs_vlt_mem_write(unsigned int mem_id, unsigned long long addr,
                                  unsigned long long data, unsigned char strb) {
    if ((mem_debug >> mem_id) & 1)
        printf("[MEM%u] W 0x%016llx: 0x%016llx strb 0x%02x\n", mem_id, addr, data, strb);
    get_mem(mem_id).write64(addr, data, strb);
}

/////////////////
//  Simulator  //
/////////////////

class Sim {
  public:
    Sim(VerilatedContext *ctx, uint64_t uart_baud, uint64_t max_cycles, uint64_t progress,
        uint64_t pc_sample)
        : ctx_(ctx), top_(new Vcheshire_top_verilator(ctx, "TOP")), slink_(top_.get()),
          jtag_(
              top_.get(), [this] { tick(); }, [this] { return cycle_; }),
          uart_(uart_baud), uart_tx_(uart_baud), uart_bit_ps_(1000000000000ull / uart_baud),
          max_cycles_(max_cycles), progress_(progress), pc_sample_(pc_sample),
          start_(std::chrono::steady_clock::now()) {
        svSetScope(svGetScopeFromName("TOP.cheshire_top_verilator"));
        unsigned char llc_not_bypass;
        unsigned int idcode, rtc_freq;
        chs_vlt_get_cfg(&cfg_.scratch_base, &cfg_.llc_spm_cfg_addr, &llc_not_bypass,
                        &cfg_.dram_base, &cfg_.dram_end, &idcode, &rtc_freq);
        cfg_.llc_not_bypass = llc_not_bypass;
        cfg_.dbg_idcode = idcode;
        // The RTC must match the frequency the SoC reports, as software calibrates against it
        rtc_half_period_ = 500000000000ull / rtc_freq;
    }

    ~Sim() {
        top_->final();
#if VM_TRACE
        if (trace_) trace_->close();
#endif
    }

    // Dump a waveform to `file` from cycle `start` on
    void set_trace(const std::string &file, uint64_t start) {
#if VM_TRACE
        trace_file_ = file;
        trace_start_ = start;
#else
        (void)file;
        (void)start;
        printf("[VLT] Warning: model built without tracing support, ignoring +TRACE\n");
#endif
    }

    void set_slink_debug(bool en) {
        slink_.set_debug(en);
    }

    // Type `text` into the SoC UART once its output contains `after` (right away if empty),
    // pausing `gap` cycles after each character so the receive FIFO does not overrun
    void set_uart_input(const std::string &text, const std::string &after, uint64_t gap) {
        uart_input_ = text;
        uart_input_gap_ = gap;
        if (after.empty())
            send_uart_input();
        else
            uart_.expect(after);
    }

    uint64_t cycles() const {
        return cycle_;
    }

    double elapsed() const {
        return std::chrono::duration<double>(std::chrono::steady_clock::now() - start_).count();
    }

    void print_progress() const {
        double secs = elapsed();
        printf("[VLT] Simulated %" PRIu64 " cycles in %.2f s (%.2f kHz)\n", cycle_, secs,
               cycle_ / secs / 1e3);
    }

    ///////////////////////
    //  Clock and Reset  //
    ///////////////////////

    // Apply reset like `clk_rst_gen`, starting from deasserted resets to create proper edges.
    void reset(uint8_t boot_mode) {
        top_->clk_i = 0;
        top_->rtc_i = 0;
        top_->rst_ni = 1;
        top_->boot_mode_i = boot_mode;
        top_->jtag_tck_i = 0;
        top_->jtag_tms_i = 1;
        top_->jtag_tdi_i = 0;
        top_->jtag_trst_ni = 1;
        top_->uart_rx_i = 1;
        top_->eval();
        top_->rst_ni = 0;
        top_->jtag_trst_ni = 0;
        run(RstCycles);
        top_->rst_ni = 1;
        top_->jtag_trst_ni = 1;
        tick();
    }

    // Simulate one system clock cycle, starting from a falling edge.
    void tick() {
        uint64_t t = ctx_->time();
        // Falling edge: apply inputs
        top_->clk_i = 0;
        if (t >= next_rtc_) {
            top_->rtc_i = !top_->rtc_i;
            next_rtc_ += rtc_half_period_;
        }
        slink_.drive();
        jtag_.drive(cycle_);
        top_->uart_rx_i = uart_tx_.line(t);
        eval();
        // Sample handshakes and outputs seen by the upcoming rising edge
        slink_.sample();
        uart_.sample(t, top_->uart_tx_o);
        if (!uart_input_.empty() && uart_.take_match()) send_uart_input();
        ctx_->timeInc(ClkPeriodSys / 2);
        // Rising edge
        top_->clk_i = 1;
        eval();
        ctx_->timeInc(ClkPeriodSys / 2);
        slink_.commit(cycle_);
        ++cycle_;
        if (progress_ && cycle_ % progress_ == 0) print_progress();
        if (pc_sample_ && cycle_ % pc_sample_ == 0)
            printf("[VLT] PC %9" PRIu64 ": 0x%016" PRIx64 "\n", cycle_,
                   uint64_t(top_->dbg_pc_commit_o));
        if (ctx_->gotFinish()) throw SimAbort("$finish called");
        if (max_cycles_ && cycle_ >= max_cycles_)
            throw SimAbort("Reached cycle limit (" + std::to_string(max_cycles_) + ")");
    }

    void run(uint64_t n) {
        while (n--) tick();
    }

    template <class F> void run_until(F cond) {
        while (!cond()) tick();
    }

    // Wait for the UART to finish receiving the current byte, then print any partial line.
    void uart_flush() {
        run_until([&] { return !uart_.busy(); });
        uart_.flush();
    }

    //////////////////////////
    //  Serial Link Access  //
    //////////////////////////

    void slink_drain() {
        run_until([&] { return slink_.idle(); });
    }

    uint32_t slink_read32(uint64_t addr) {
        slink_.read(addr, 2, 0);
        slink_drain();
        return uint32_t(slink_.pop_rdata() >> (8 * (addr & 7)));
    }

    void slink_write32(uint64_t addr, uint32_t data) {
        slink_.write(addr, 2, {uint64_t(data) << (8 * (addr & 7))}, {uint8_t(0xf << (addr & 7))});
        slink_drain();
    }

    // Write a buffer in bursts that never exceed `SlinkBurstBytes` or cross a 4 KiB page.
    void slink_write_buf(uint64_t addr, const uint8_t *buf, uint64_t len) {
        for (uint64_t offs = 0; offs < len;) {
            uint64_t cur = addr + offs;
            uint64_t n = std::min({SlinkBurstBytes, len - offs, 4096 - (cur & 0xfff)});
            std::vector<uint64_t> data;
            std::vector<uint8_t> strb;
            // Beats are bus-aligned; strobes mask bytes outside of the buffer
            for (uint64_t beat = cur & ~7ull; beat < cur + n; beat += 8) {
                uint64_t d = 0;
                uint8_t s = 0;
                for (unsigned b = 0; b < 8; ++b) {
                    if (beat + b >= cur && beat + b < cur + n) {
                        d |= uint64_t(buf[beat + b - addr]) << (8 * b);
                        s |= uint8_t(1u << b);
                    }
                }
                data.push_back(d);
                strb.push_back(s);
            }
            slink_.write(cur & ~7ull, 3, std::move(data), std::move(strb));
            offs += n;
        }
        slink_drain();
    }

    uint32_t slink_poll_bit0(uint64_t addr, unsigned idle_cycles) {
        uint32_t data;
        do {
            run(idle_cycles);
            data = slink_read32(addr);
        } while (!(data & 1));
        return data;
    }

    unsigned slink_errors() const {
        return slink_.errors();
    }

    //////////////////
    //  Test Flows  //
    //////////////////

    uint64_t scratch_addr(unsigned idx) const {
        return cfg_.scratch_base + 4 * idx;
    }

    // Preload an ELF binary through the serial link and launch it, like `slink_elf_run`.
    void slink_elf_run(const std::string &binary) {
        if (cfg_.llc_not_bypass) {
            printf("[SLINK] Wait for LLC configuration\n");
            slink_poll_bit0(cfg_.llc_spm_cfg_addr, PollIdleLlc);
        }
        uint64_t entry =
            elf_preload("SLINK", binary, [&](uint64_t addr, const std::vector<uint8_t> &buf) {
                slink_write_buf(addr, buf.data(), buf.size());
            });
        slink_write32(scratch_addr(1), uint32_t(entry >> 32));
        slink_write32(scratch_addr(0), uint32_t(entry));
        slink_write32(scratch_addr(2), 2);
        printf("[SLINK] Wrote launch signal and entry point 0x%016" PRIx64 "\n", entry);
    }

    // Poll for the end of computation and return the exit code, like `slink_wait_for_eoc`.
    uint32_t slink_wait_for_eoc() {
        uint32_t exit_code = slink_poll_bit0(scratch_addr(2), PollIdleEoc) >> 1;
        report("SLINK", exit_code);
        return exit_code;
    }

    ////////////
    //  JTAG  //
    ////////////

    // Write a DM register, optionally waiting for abstract commands or system bus accesses
    void jtag_write(unsigned addr, uint32_t data, bool wait_cmd = false, bool wait_sba = false) {
        jtag_.write_dmi(addr, data);
        if (wait_cmd) {
            uint32_t acs;
            do {
                acs = jtag_.read_dmi_exp_backoff(dm::AbstractCs);
                if (acs & dm::AcsCmdErr) throw SimAbort("[JTAG] Abstract command error");
            } while (acs & dm::AcsBusy);
        }
        if (wait_sba) {
            uint32_t sbcs;
            do {
                sbcs = jtag_.read_dmi_exp_backoff(dm::Sbcs);
                if (sbcs & (dm::SbError | dm::SbBusyError))
                    throw SimAbort("[JTAG] System bus error");
            } while (sbcs & dm::SbBusy);
        }
    }

    uint32_t jtag_poll_bit0(uint64_t addr, unsigned idle_cycles) {
        uint32_t data;
        jtag_write(dm::Sbcs, dm::SbReadOnAddr | dm::sbaccess(2), false, true);
        jtag_write(dm::SbAddress1, uint32_t(addr >> 32));
        do {
            jtag_write(dm::SbAddress0, uint32_t(addr));
            jtag_.wait_idle(idle_cycles);
            data = jtag_.read_dmi_exp_backoff(dm::SbData0);
        } while (!(data & 1));
        return data;
    }

    // Initialize the debug module, like `jtag_init`
    void jtag_init() {
        jtag_.reset_master();
        jtag_.wait_idle(100);
        uint32_t idcode = jtag_.get_idcode();
        if (idcode != cfg_.dbg_idcode)
            throw SimAbort("[JTAG] Unexpected ID code: " + std::to_string(idcode));
        jtag_write(dm::DmControl, dm::DmActive);
        while (!(jtag_.read_dmi_exp_backoff(dm::DmControl) & dm::DmActive)) {
        }
        jtag_write(dm::Sbcs, JtagInitSbcs, false, true);
        printf("[JTAG] Initialization success\n");
    }

    // Wait for the boot ROM to configure the LLC and halt hart 0
    void jtag_wait_for_llc_config_halt() {
        if (cfg_.llc_not_bypass) {
            printf("[JTAG] Wait for LLC configuration\n");
            jtag_poll_bit0(cfg_.llc_spm_cfg_addr, PollIdleLlc);
        }
        jtag_write(dm::DmControl, dm::HaltReq | dm::DmActive);
        while (!(jtag_.read_dmi_exp_backoff(dm::DmStatus) & dm::AllHalted)) {
        }
        printf("[JTAG] Halted hart 0\n");
    }

    void jtag_load_section(uint64_t addr, const std::vector<uint8_t> &buf) {
        jtag_write(dm::Sbcs, JtagInitSbcs, true, true);
        jtag_write(dm::SbAddress1, uint32_t(addr >> 32));
        jtag_write(dm::SbAddress0, uint32_t(addr));
        for (uint64_t i = 0; i < buf.size(); i += 8) {
            uint64_t data = 0;
            for (unsigned b = 0; b < 8 && i + b < buf.size(); ++b)
                data |= uint64_t(buf[i + b]) << (8 * b);
            bool checkpoint = i != 0 && i % 512 == 0;
            if (checkpoint) printf("[JTAG] - %" PRIu64 "/%zu bytes\n", i, buf.size());
            jtag_write(dm::SbData1, uint32_t(data >> 32));
            jtag_write(dm::SbData0, uint32_t(data), checkpoint, checkpoint);
        }
    }

    // Halt, preload an ELF binary, and resume at its entry point, like `jtag_elf_run`
    void jtag_elf_run(const std::string &binary) {
        jtag_wait_for_llc_config_halt();
        uint64_t entry =
            elf_preload("JTAG", binary, [&](uint64_t addr, const std::vector<uint8_t> &buf) {
                jtag_load_section(addr, buf);
            });
        jtag_resume(entry);
    }

    // Point the halted hart 0 to `entry` and resume it
    void jtag_resume(uint64_t entry) {
        jtag_write(dm::Data1, uint32_t(entry >> 32));
        jtag_write(dm::Data0, uint32_t(entry));
        jtag_write(dm::Command, dm::CmdWriteDpc, true, false);
        jtag_write(dm::DmControl, dm::ResumeReq | dm::DmActive);
        printf("[JTAG] Resumed hart 0 from 0x%016" PRIx64 "\n", entry);
    }

    uint32_t jtag_wait_for_eoc() {
        uint32_t exit_code = jtag_poll_bit0(scratch_addr(2), PollIdleEoc) >> 1;
        report("JTAG", exit_code);
        return exit_code;
    }

    /////////////////////////
    //  Direct Preloading  //
    /////////////////////////

    bool in_dram(uint64_t addr, uint64_t len) const {
        return addr >= cfg_.dram_base && addr + len <= cfg_.dram_end;
    }

    // Write a raw binary file directly into DRAM; must happen before the SoC accesses that region
    void dram_preload_bin(const std::string &file, uint64_t addr) {
        std::ifstream f(file, std::ios::binary);
        if (!f) throw SimAbort("Failed to open " + file);
        std::vector<uint8_t> buf((std::istreambuf_iterator<char>(f)),
                                 std::istreambuf_iterator<char>());
        if (!in_dram(addr, buf.size()))
            throw SimAbort("Binary " + file + " does not fit into DRAM at the requested address");
        mems[MemDram].write(addr, buf.data(), buf.size());
        printf("[MEMH] Preloaded %s (%zu bytes) at 0x%016" PRIx64 "\n", file.c_str(), buf.size(),
               addr);
    }

    // Halt hart 0, write DRAM sections directly and others through JTAG, and resume, like
    // `memh_elf_preload` and `jtag_elf_run_no_preload`. The hart is halted and no cache holds
    // DRAM lines yet, so writing DRAM behind the SoC is coherent.
    void memh_elf_run(const std::string &binary) {
        jtag_wait_for_llc_config_halt();
        uint64_t entry =
            elf_preload("MEMH", binary, [&](uint64_t addr, const std::vector<uint8_t> &buf) {
                if (in_dram(addr, buf.size())) {
                    mems[MemDram].write(addr, buf.data(), buf.size());
                } else {
                    printf("[MEMH] Section at 0x%016" PRIx64
                           " is not in DRAM, falling back to JTAG\n",
                           addr);
                    jtag_load_section(addr, buf);
                }
            });
        jtag_resume(entry);
    }

    ////////////
    //  UART  //
    ////////////

    void uart_send(uint8_t c) {
        uart_tx_.send(c);
    }

    void send_uart_input() {
        printf("[VLT] Typing UART input (cycle %" PRIu64 ")\n", cycle_);
        uart_tx_.set_gap(uart_input_gap_ * ClkPeriodSys);
        for (char c : uart_input_) uart_send(uint8_t(c));
        uart_input_.clear();
    }

    void uart_send_u64(uint64_t v) {
        for (unsigned i = 0; i < 8; ++i) uart_send(uint8_t(v >> (8 * i)));
    }

    uint8_t uart_scoop() {
        uart_.scoop(1);
        run_until([&] { return uart_.scooped(); });
        return uart_.pop_scooped();
    }

    void uart_scoop_expect(const char *name, uint8_t exp) {
        uint8_t c = uart_scoop();
        if (c != exp)
            throw SimAbort(std::string("[UART] Expected ") + name + ", received " +
                           std::to_string(c));
    }

    // Preload an ELF binary through the boot ROM UART debug server and run it, like
    // `uart_debug_elf_run_and_wait`
    uint32_t uart_debug_elf_run_and_wait(const std::string &binary) {
        // Wait for the debug loop to start; there is no way to query this using only UART
        printf("[UART] Waiting for debug loop to start\n");
        run_until(
            [&, t = ctx_->time() + UartWaitBits * uart_bit_ps_] { return ctx_->time() >= t; });
        printf("[UART] Sending ACK challenge\n");
        uart_.scoop(1);
        uart_send(UartDebugAck);
        run_until([&] { return uart_.scooped(); });
        if (uart_.pop_scooped() != UartDebugAck)
            throw SimAbort("[UART] Expected ACK challenge response");
        uint64_t entry =
            elf_preload("UART", binary, [&](uint64_t addr, const std::vector<uint8_t> &buf) {
                for (uint64_t i = 0; i < buf.size(); i += UartBurstBytes) {
                    uint64_t len = std::min(UartBurstBytes, buf.size() - i);
                    if (i) printf("[UART] - %" PRIu64 "/%zu bytes\n", i, buf.size());
                    uart_send(UartDebugCmdWrite);
                    uart_send_u64(addr + i);
                    uart_send_u64(len);
                    uart_scoop_expect("ACK", UartDebugAck);
                    for (uint64_t b = 0; b < len; ++b) uart_send(buf[i + b]);
                    uart_scoop_expect("EOT", UartDebugEot);
                }
            });
        printf("[UART] Sending EXEC command for address 0x%016" PRIx64 "\n", entry);
        uart_send(UartDebugCmdExec);
        uart_send_u64(entry);
        uart_scoop_expect("ACK", UartDebugAck);
        run_until([&] { return uart_.take_eoc(); });
        printf("[UART] Received EOC signal\n");
        uint32_t exit_code = 0;
        for (unsigned i = 0; i < 4; ++i) exit_code |= uint32_t(uart_scoop()) << (8 * i);
        report("UART", exit_code);
        return exit_code;
    }

  private:
    struct Config {
        unsigned long long scratch_base;
        unsigned long long llc_spm_cfg_addr;
        bool llc_not_bypass;
        unsigned long long dram_base;
        unsigned long long dram_end;
        uint32_t dbg_idcode;
    };

    void eval() {
        top_->eval();
#if VM_TRACE
        if (!trace_ && !trace_file_.empty() && cycle_ >= trace_start_) {
            trace_.reset(new TraceFile);
            top_->trace(trace_.get(), 99);
            trace_->open(trace_file_.c_str());
            printf("[VLT] Dumping waveform to %s from cycle %" PRIu64 "\n", trace_file_.c_str(),
                   cycle_);
        }
        if (trace_) trace_->dump(ctx_->time());
#endif
    }

    static void report(const char *tag, uint32_t exit_code) {
        if (exit_code)
            printf("[%s] FAILED: return code %u\n", tag, exit_code);
        else
            printf("[%s] SUCCESS\n", tag);
        fflush(stdout);
    }

    template <class F>
    uint64_t elf_preload(const char *tag, const std::string &binary, F write_section) {
        printf("[%s] Preloading ELF binary: %s\n", tag, binary.c_str());
        if (read_elf(binary.c_str())) throw SimAbort("Failed to load ELF " + binary);
        long long addr, len;
        while (get_section(&addr, &len)) {
            printf("[%s] Preloading section at 0x%016llx (%lld bytes)\n", tag, addr, len);
            fflush(stdout);
            std::vector<uint8_t> buf(len, 0);
            if (read_section_raw(addr, reinterpret_cast<char *>(buf.data()), len))
                throw SimAbort("Failed to read ELF section");
            write_section(uint64_t(addr), buf);
        }
        long long entry;
        get_entry(&entry);
        printf("[%s] Preload complete\n", tag);
        return uint64_t(entry);
    }

    VerilatedContext *ctx_;
    std::unique_ptr<Vcheshire_top_verilator> top_;
#if VM_TRACE
    std::unique_ptr<TraceFile> trace_;
    std::string trace_file_;
    uint64_t trace_start_ = 0;
#endif
    static constexpr uint32_t JtagInitSbcs = dm::SbAutoIncr | dm::SbReadOnData | dm::sbaccess(3);

    Config cfg_;
    SlinkAxi slink_;
    JtagDmi jtag_;
    UartRx uart_;
    UartTx uart_tx_;
    uint64_t uart_bit_ps_;
    uint64_t max_cycles_;
    uint64_t progress_;
    uint64_t pc_sample_;
    std::string uart_input_;
    uint64_t uart_input_gap_ = 0;
    std::chrono::steady_clock::time_point start_;
    uint64_t cycle_ = 0;
    uint64_t next_rtc_ = 0;
    uint64_t rtc_half_period_ = 0;
};

////////////
//  Main  //
////////////

static bool plusarg(VerilatedContext *ctx, const char *name, std::string &value) {
    std::string prefix = std::string(name) + "=";
    const char *match = ctx->commandArgsPlusMatch(prefix.c_str());
    if (!match || !*match) return false;
    value = match + 1 + prefix.size();
    return true;
}

static uint64_t plusarg_u64(VerilatedContext *ctx, const char *name, uint64_t dflt) {
    std::string value;
    return plusarg(ctx, name, value) ? strtoull(value.c_str(), nullptr, 0) : dflt;
}

// Resolve the escapes \n, \r, \t, and \\ in a plusarg string
static std::string unescape(const std::string &s) {
    std::string out;
    for (size_t i = 0; i < s.size(); ++i) {
        if (s[i] != '\\' || i + 1 == s.size()) {
            out += s[i];
            continue;
        }
        switch (s[++i]) {
        case 'n':
            out += '\n';
            break;
        case 'r':
            out += '\r';
            break;
        case 't':
            out += '\t';
            break;
        default:
            out += s[i];
        }
    }
    return out;
}

int main(int argc, char **argv) {
    // Keep logs current even when redirected to files
    setvbuf(stdout, nullptr, _IOLBF, 0);

    std::unique_ptr<VerilatedContext> ctx(new VerilatedContext);
    ctx->commandArgs(argc, argv);
    // Pin simulation threads unless the process already has an affinity mask
    // (see `VERILATOR_NUMA_STRATEGY`); floating threads severely degrade performance.
    ctx->useNumaAssign(true);

    std::string binary, trace_file;
    plusarg(ctx.get(), "BINARY", binary);
    uint64_t boot_mode = plusarg_u64(ctx.get(), "BOOTMODE", 0);
    uint64_t preload_mode = plusarg_u64(ctx.get(), "PRELMODE", 0);
    uint64_t uart_baud = plusarg_u64(ctx.get(), "UART_BAUD", 115200);
    uint64_t max_cycles = plusarg_u64(ctx.get(), "MAX_CYCLES", 0);
    uint64_t progress = plusarg_u64(ctx.get(), "PROGRESS", 0);
    mem_debug = plusarg_u64(ctx.get(), "MEM_DEBUG", 0);
    std::string preload_bins;
    plusarg(ctx.get(), "PRELOAD_BIN", preload_bins);

    // Tracing must be enabled before the model is constructed
    bool trace = plusarg(ctx.get(), "TRACE", trace_file);
    if (trace) ctx->traceEverOn(true);

    Sim sim(ctx.get(), uart_baud, max_cycles, progress, plusarg_u64(ctx.get(), "PC_SAMPLE", 0));
    if (trace) sim.set_trace(trace_file, plusarg_u64(ctx.get(), "TRACE_START", 0));
    sim.set_slink_debug(ctx->commandArgsPlusMatch("SLINK_DEBUG")[0]);
    std::string uart_input, uart_input_after;
    if (plusarg(ctx.get(), "UART_INPUT", uart_input)) {
        plusarg(ctx.get(), "UART_INPUT_AFTER", uart_input_after);
        sim.set_uart_input(unescape(uart_input), unescape(uart_input_after),
                           plusarg_u64(ctx.get(), "UART_INPUT_GAP", 20000));
    }

    int ret = 0;
    uint32_t exit_code = 0;

    try {
        // Raw binaries go into DRAM before anything can cache it
        for (size_t pos = 0; pos < preload_bins.size();) {
            size_t end = preload_bins.find(',', pos);
            if (end == std::string::npos) end = preload_bins.size();
            std::string item = preload_bins.substr(pos, end - pos);
            size_t at = item.rfind('@');
            if (at == std::string::npos) throw SimAbort("Expected <file>@<addr> in +PRELOAD_BIN");
            sim.dram_preload_bin(item.substr(0, at), strtoull(item.c_str() + at + 1, nullptr, 0));
            pos = end + 1;
        }
        sim.reset(uint8_t(boot_mode));
        if (boot_mode != 0) throw SimAbort("Unsupported boot mode " + std::to_string(boot_mode));
        if (binary.empty()) throw SimAbort("No binary specified (+BINARY=<elf>)");
        switch (preload_mode) {
        case 0:
            sim.jtag_init();
            sim.jtag_elf_run(binary);
            exit_code = sim.jtag_wait_for_eoc();
            break;
        case 1:
            sim.slink_elf_run(binary);
            exit_code = sim.slink_wait_for_eoc();
            break;
        case 2:
            exit_code = sim.uart_debug_elf_run_and_wait(binary);
            break;
        case 3:
            sim.jtag_init();
            sim.memh_elf_run(binary);
            exit_code = sim.jtag_wait_for_eoc();
            break;
        default:
            throw SimAbort("Unsupported preload mode " + std::to_string(preload_mode));
        }
        sim.uart_flush();
        if (sim.slink_errors()) {
            printf("[VLT] Error: %u serial link error responses\n", sim.slink_errors());
            ret = 2;
        }
        if (exit_code) ret = 1;
    } catch (const std::exception &e) {
        printf("[VLT] Error: %s (cycle %" PRIu64 ")\n", e.what(), sim.cycles());
        ret = 2;
    }

    sim.print_progress();
    return ret;
}
