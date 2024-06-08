// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Yvan Tortorella <yvan.tortorella@unibo.it>
//
// Test for HMR functionalities.

#include "regs/cheshire.h"
#include "util.h"
#include "hmr.h"
#include "printf.h"

int main(void) {

    // Hart 0 enters first
    printf("%d!\n", hart_id());

    // Only hart 0 gets here
    if (hart_id() == 0) {
        // Check if DMR is enabled. If not, enable it
        if (!(*reg32(&__base_hmr, HMR_DMR_ENABLE))) *reg32(&__base_hmr, HMR_DMR_ENABLE) = 0x1;
        // Wake up the SMP core
        smp_resume();
     }

    chs_hmr_store_state(); // -> Save state on top of the stack
                           //    Fence.i to flush caches
                           //    Save sp (x2) in HMR dedicated reg
                           //    Save ra (x1) in DMR checkpoint reg
                           //    Write synchronization request
                           //    wfi() until reset

    // Both harts restart from here, but are locked as one
    chs_hmr_load_state(); // -> Code restarts executing from here because we
                          //    re-boot from the return address (x1)
                          //    Re-loads the saved state
                          //    Restores the sp

    printf("DMR: %d!\n", hart_id());

    // The two locked harts return
    return 0;
}
