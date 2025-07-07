#include <chrono> // timers
#include <memory> // std::unique_ptr

#include <verilated.h> // common Verilator routines
#if VM_TRACE
#include <verilated_vcd_c.h> // trace to VCD
#endif

#include "Vcheshire_soc_wrapper.h" // Verilated model

#include "Mem64Master.h"

// clock periods and time step in pico seconds
#define CLK_PERIOD_PS     5000
#define RTC_PERIOD_PS 30520000
#define TIME_STEP_PS      2500

#define RST_CYCLES 5

#define SIMULATION_RATE_CHUNK 10000

// #define BENCHMARK

extern "C" {
  char get_entry(long long *entry_ret);
  char get_section(long long *address_ret, long long *len_ret);
  char read_section_raw(long long address, char *buf, long long len);
  char read_elf(const char *filename);
}

std::unique_ptr<VerilatedContext> contextp;
std::unique_ptr<Vcheshire_soc_wrapper> topp;
std::unique_ptr<Mem64Master> mem_master;
bool do_exit = false;
int  exit_code = 0;

extern int jtag_tick(int port, unsigned char *jtag_TCK, unsigned char *jtag_TMS,
    unsigned char *jtag_TDI, unsigned char *jtag_TRSTn, unsigned char jtag_TDO);


static void jtag_tick_io() {
  static int count = 0;
  if (count < 10) {
    count++;
    return;
  }
  count = 0;

  unsigned char tck, tms, tdi, trst_n;
  int ret = jtag_tick(3335, &tck, &tms, &tdi, &trst_n, topp->jtag_tdo_o);
  if (ret) {
    do_exit = true;
    exit_code = ret >> 1;
    return;
  }

  topp->jtag_tck_i   = tck;
  topp->jtag_tms_i   = tms;
  topp->jtag_tdi_i   = tdi;
  topp->jtag_trst_ni = trst_n;
}

static void handle_uart(char data) {
  static std::string uart_buffer;
  uart_buffer.push_back(data);

  if (data == '\n') {
    VL_PRINTF("[UART] %s", uart_buffer.c_str());
    uart_buffer.clear();
  }
}

static bool elf_preload_open(const char *filename) {
    char ret = read_elf(filename);
    if (ret != 0) {
        VL_PRINTF("[ELF] failed to read ELF: %d\n", ret);
        return false;
    }
    return true;
}

static void elf_preload_write_enqueue() {
    long long section_address, section_len;
    size_t num_writes = 0;

    while (get_section(&section_address, &section_len)) {
        VL_PRINTF("[ELF] loading section at 0x%llx (%lld bytes)\n", section_address, section_len);

        char *buf = (char *)calloc(section_len + sizeof(uint64_t), 1);
        read_section_raw(section_address, buf, section_len);

        for (size_t i = 0; i < section_len; i += sizeof(uint64_t)) {
            mem_master->write(section_address + i, *(uint64_t *)(buf + i));
            num_writes++;
        }

        free(buf);
    }

    long long entry;
    get_entry(&entry);
    // write entrypoint
    mem_master->write(0x03000000, entry);
    num_writes++;
    // set start bit (read by boot ROM)
    mem_master->write(0x03000008, 2);
    num_writes++;

    VL_PRINTF("[ELF] enqueued %zu memory writes\n", num_writes);
}

static void poll_for_exit() {
    static bool request_inflight = false;
    static uint64_t idle_cycles = 0;

    if (request_inflight) {
      auto maybe_response = mem_master->get_read_response();
      if (maybe_response) {
        auto data = maybe_response->data;

        request_inflight = false;
        idle_cycles = 0;
        if (data & 0x1) {
          do_exit = true;
          exit_code = data >> 1;
          VL_PRINTF("[EXIT] received exit code from software: %d\n", exit_code);
        }
      }
    } else {
      idle_cycles++;

      if (idle_cycles >= 1000) {
        mem_master->read(0x03000008);
        request_inflight = true;
      }
    }

}

int main(int argc, char** argv) {
    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct a VerilatedContext to hold simulation time, etc.
    contextp = std::make_unique<VerilatedContext>();

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

#if VM_TRACE
    // Verilator must compute traced signals
    contextp->traceEverOn(true);
#endif

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // "TOP" will be the hierarchical name of the module
    topp = std::make_unique<Vcheshire_soc_wrapper>(contextp.get(), "TOP");

#if VM_TRACE
    Verilated::traceEverOn(true);
    const auto trace = std::make_unique<VerilatedVcdC>();
    topp->trace(trace.get(), 5);
    trace->open("dump.vcd");
#endif

    // Initial Inputs
    topp->clk_i  = 1;
    topp->rtc_i  = 1;
    topp->rst_ni = 1;

    auto start = std::chrono::high_resolution_clock::now();
    auto last = start;
    uint64_t cycle = 0;
    uint64_t next_rtc_toggle_ps = 0;
    bool reset_done = false;

    mem_master = std::make_unique<Mem64Master>(
        &topp->slink_mem_req_i,
        &topp->slink_mem_addr_i,
        &topp->slink_mem_we_i,
        &topp->slink_mem_wdata_i,
        &topp->slink_mem_be_i,
        &topp->slink_mem_gnt_o,
        &topp->slink_mem_rsp_valid_o,
        &topp->slink_mem_rsp_rdata_o
    );

    // ELF preloading
    const char *filename = "../../../sw/tests/helloworld.spm.elf";
    if (!elf_preload_open(filename))
      return 1;

    // Simulate until $finish
    while (!contextp->gotFinish() && !do_exit) {
        // Toggle Clock
        topp->clk_i = !topp->clk_i;

        // Apply Inputs (negedge clk_i)
        if (!topp->clk_i) {
          if (cycle == 1) {
            // Apply Reset
            topp->rst_ni = 0;
          }

          if (cycle == RST_CYCLES + 1) {
            // Release Reset
            topp->rst_ni = 1;
            reset_done = true;
          }

          // Toggle Real Time Clock
          if (contextp->time() >= next_rtc_toggle_ps) {
            topp->rtc_i = !topp->rtc_i;
            next_rtc_toggle_ps += RTC_PERIOD_PS / 2;
          }

          // TODO: This is determined experimentally.
          // We should rather poll until the SPM has been configured properly.
          if (cycle == 2000)
            elf_preload_write_enqueue();

          // I/O
          if (reset_done) {
            poll_for_exit();
#if 0
            jtag_tick_io();
#endif
          }
        }


        contextp->timeInc(TIME_STEP_PS);

        // Monitor Synchronous Outputs: just before @(posedge clk_i)
        if (reset_done && topp->clk_i) {
          mem_master->handle_before();
        }

        // Evaluate model
        topp->eval();

        // Apply Synchronous Inputs: just after @(posedge clk_i)
        if (reset_done && topp->clk_i) {
          mem_master->handle_after();
        }

#if VM_TRACE
        trace->dump(contextp->time());
#endif

        // Monitoring (posedge clk_i)
        if (topp->clk_i) {
          cycle++;

          if (topp->uart_data_valid_o) {
            handle_uart(topp->uart_data_o);
          }

          if (cycle % SIMULATION_RATE_CHUNK == 0) {
            auto current = std::chrono::high_resolution_clock::now();
            auto total_elapsed_us = std::chrono::duration_cast<std::chrono::microseconds>(current - start).count();
            auto last_elapsed_us = std::chrono::duration_cast<std::chrono::microseconds>(current - last).count();
            last = current;
            auto total_cycles_per_sec = 1000000.0 * cycle / total_elapsed_us;
            auto last_cycles_per_sec = 1000000.0 * SIMULATION_RATE_CHUNK / last_elapsed_us;
            VL_PRINTF("elapsed: %.3f sec, %lu cycles, %.1f cycles/sec (total), %.1f cycles/sec (last)\n",
                total_elapsed_us / 1e6, cycle, total_cycles_per_sec, last_cycles_per_sec);
          }
#ifdef BENCHMARK
          if (cycle == 1000000)
            break;
#endif
        }
    }

    // Final model cleanup
    topp->final();

#if VM_TRACE
      trace->close();
#endif

    // Coverage analysis (calling write only after the test is known to pass)
#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

    // Final simulation summary
    contextp->statsPrintSummary();

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return exit_code;
}
