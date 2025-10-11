// Copyright 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Max Wipfli <mwipfli@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include <cstdint>

#include "svdpi.h"
#include "verilated.h"
#include "elfloader.h"

#include "Vcheshire_top_verilator.h"
#include "Vcheshire_top_verilator__Dpi.h"


int main(int argc, char** argv) {
    // Create context and pass args
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    // Create top in context and set scope to it
    Vcheshire_top_verilator* top = new Vcheshire_top_verilator(contextp);
    svSetScope(svGetScopeFromName("TOP.cheshire_top_verilator"));

    // Initial inputs
    top->clk_i  = 0;
    top->rst_ni = 1;
    top->rtc_i  = 0;

    top->uart_dpi_active = 1;
    top->jtag_dpi_active = 0;

    // Speedtest
    for (uint64_t b  = 0; b < 16*1024*1024; ++b) {
        if (b % (1024*1024) == 0)
            VL_PRINTF("Byte: %ld\n", b);
        chsvlt_dmw(b, 42);

    }


    // Simulation loop
    for (uint64_t cycle = 0; !contextp->gotFinish(); ++cycle) {

        top->clk_i = !top->clk_i;


        if (cycle == 10) chsvlt_dmw(10, 42);

        if (cycle == 20) {
            uint8_t bla = chsvlt_dmr(10);

            VL_PRINTF("Read back: %hhd\n", bla);

            bla = chsvlt_dmr(11);

            VL_PRINTF("Read back: %hhd\n", bla);

        }

        top->eval();
    }

    // Cleanup
    delete top;
    delete contextp;
    return 0;
}
