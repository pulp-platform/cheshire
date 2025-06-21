#include <chrono> // timers
#include <memory> // std::unique_ptr

#include <verilated.h> // common Verilator routines
#include <verilated_vcd_c.h> // trace to VCD

#include "Vcheshire_soc_wrapper.h" // Verilated model

// clock periods and time step in pico seconds
#define CLK_PERIOD_PS     5000
#define RTC_PERIOD_PS 30520000
#define TIME_STEP_PS      2500

#define RST_CYCLES 5

#define SIMULATION_RATE_CHUNK 10000

// #define BENCHMARK

bool do_exit = false;
int  exit_code = 0;

extern int jtag_tick(int port, unsigned char *jtag_TCK, unsigned char *jtag_TMS,
    unsigned char *jtag_TDI, unsigned char *jtag_TRSTn, unsigned char jtag_TDO);


static void jtag_tick_io(Vcheshire_soc_wrapper& top) {
  static int count = 0;
  if (count < 10) {
    count++;
    return;
  }
  count = 0;

  unsigned char tck, tms, tdi, trst_n;
  int ret = jtag_tick(3335, &tck, &tms, &tdi, &trst_n, top.jtag_tdo_o);
  if (ret) {
    do_exit = true;
    exit_code = ret >> 1;
    return;
  }

  top.jtag_tck_i   = tck;
  top.jtag_tms_i   = tms;
  top.jtag_tdi_i   = tdi;
  top.jtag_trst_ni = trst_n;
}

static void handle_uart(char data) {
  static std::string uart_buffer;
  uart_buffer.push_back(data);

  if (data == '\r' || data == '\n') {
    VL_PRINTF("[UART] %s", uart_buffer.c_str());
    uart_buffer.clear();
  }
}

int main(int argc, char** argv) {
    // This is a more complicated example, please also see the simpler examples/make_hello_c.

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct a VerilatedContext to hold simulation time, etc.
    // Multiple modules (made later below with Vtop) may share the same
    // context to share time, or modules may have different contexts if
    // they should be independent from each other.

    // Using unique_ptr is similar to
    // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
    const auto contextp = std::make_unique<VerilatedContext>();
    // const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    // Do not instead make Vtop as a file-scope static variable, as the
    // "C++ static initialization order fiasco" may cause a crash

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // "TOP" will be the hierarchical name of the module
    const auto top = std::make_unique<Vcheshire_soc_wrapper>(contextp.get(), "TOP");

#if CHS_TRACE_VCD
    Verilated::traceEverOn(true);
    const auto trace = std::make_unique<VerilatedVcdC>();
    top->trace(trace.get(), 5);
    trace->open("dump.vcd");
#endif

    // Initial Inputs
    top->clk_i  = 1;
    top->rtc_i  = 1;
    top->rst_ni = 0;

    auto start = std::chrono::high_resolution_clock::now();
    auto last = start;
    uint64_t cycle = 0;
    uint64_t next_rtc_toggle_ps = 0;

    // Simulate until $finish
    while (!contextp->gotFinish() && !do_exit) {
        // Toggle Clock
        top->clk_i = !top->clk_i;

        // Apply Inputs (negedge clk_i)
        if (!top->clk_i) {
          cycle++;

          // Release Reset
          if (cycle == RST_CYCLES)
            top->rst_ni = 1;

          // Toggle Real Time Clock
          if (contextp->time() >= next_rtc_toggle_ps) {
            top->rtc_i = !top->rtc_i;
            next_rtc_toggle_ps += RTC_PERIOD_PS / 2;
          }

          // JTAG I/O
          if (top->rst_ni) {
#if 0
            jtag_tick_io(*top);
#endif
          }
        }

        contextp->timeInc(TIME_STEP_PS);

        // Evaluate model
        top->eval();

#if CHS_TRACE_VCD
        trace->dump(contextp->time());
#endif

        // Monitoring (posedge clk_i)
        if (top->clk_i) {
          if (top->uart_data_valid_o) {
            handle_uart(top->uart_data_o);
          }

          if (cycle % SIMULATION_RATE_CHUNK == 0) {
            auto current = std::chrono::high_resolution_clock::now();
            auto total_elapsed_us = std::chrono::duration_cast<std::chrono::microseconds>(current - start).count();
            auto last_elapsed_us = std::chrono::duration_cast<std::chrono::microseconds>(current - last).count();
            last = current;
            auto total_cycles_per_sec = 1000000.0 * cycle / total_elapsed_us;
            auto last_cycles_per_sec = 1000000.0 * SIMULATION_RATE_CHUNK / last_elapsed_us;
            VL_PRINTF("elapsed: %lu us, %.1f cycles/sec (total), %.1f cycles/sec (last)\n",
                total_elapsed_us, total_cycles_per_sec, last_cycles_per_sec);
          }
#ifdef BENCHMARK
          if (cycle == 1000000)
            break;
#endif
        }
    }

    // Final model cleanup
    top->final();

#ifdef TRACE
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
