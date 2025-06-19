#include <memory> // std::unique_ptr

#include <verilated.h> // common Verilator routines
#include <verilated_vcd_c.h> // trace to VCD

#include "Vcheshire_soc_wrapper.h" // Verilated model

#define TRACE

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

    // "WRAPPER" will be the hierarchical name of the module
    const auto top = std::make_unique<Vcheshire_soc_wrapper>(contextp.get(), "TOP");

#ifdef TRACE
    Verilated::traceEverOn(true);
    const auto trace = std::make_unique<VerilatedVcdC>();
    top->trace(trace.get(), 2);
    trace->open("dump.vcd");
#endif

    // Set Vtop's input signals
    // top->reset_l = !0;
    // top->clk = 0;
    // top->in_small = 1;
    // top->in_quad = 0x1234;
    // top->in_wide[0] = 0x11111111;
    // top->in_wide[1] = 0x22222222;
    // top->in_wide[2] = 0x3;

    // Simulate until $finish
    while (!contextp->gotFinish()) {
        contextp->timeInc(1);  // 1 timeprecision period passes...

        // VL_PRINTF("toggle...\n");

        // Toggle control signals on an edge that doesn't correspond
        // to where the controls are sampled; in this example we do
        // this only on a negedge of clk, because we know
        // reset is not sampled there.
        // if (!top->clk) {
        //     if (contextp->time() > 1 && contextp->time() < 10) {
        //         top->reset_l = !1;  // Assert reset
        //     } else {
        //         top->reset_l = !0;  // Deassert reset
        //     }
        //     // Assign some other inputs
        //     top->in_quad += 0x12;
        // }

        // Evaluate model
        // (If you have multiple models being simulated in the same
        // timestep then instead of eval(), call eval_step() on each, then
        // eval_end_step() on each. See the manual.)
        top->eval();

#ifdef TRACE
        trace->dump(contextp->time());
#endif

        // // Read outputs
        // VL_PRINTF("[%" PRId64 "] clk=%x rstl=%x iquad=%" PRIx64 " -> oquad=%" PRIx64
        //           " owide=%x_%08x_%08x\n",
        //           contextp->time(), top->clk, top->reset_l, top->in_quad, top->out_quad,
        //           top->out_wide[2], top->out_wide[1], top->out_wide[0]);
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
    return 0;
}
