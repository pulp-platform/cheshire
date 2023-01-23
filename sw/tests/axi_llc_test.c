// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "axi_llc_reg32.h"
#include "printf.h"
#include "trap.h"
#include "uart.h"

char uart_initialized = 0;

extern void *__base_axi_llc;

void __attribute__((aligned(4))) trap_vector(void) { test_trap_vector(&uart_initialized); }

void init_llc(void *base) {
    printf("[axi_llc] AXI LLC Version   :       0x%lx\r\n", axi_llc_reg32_get_version(base));
    printf("[axi_llc] Set Associativity :       %d\r\n", axi_llc_reg32_get_set_asso(base));
    printf("[axi_llc] Num Blocks        :       %d\r\n", axi_llc_reg32_get_num_blocks(base));
    printf("[axi_llc] Num Lines         :       %d\r\n", axi_llc_reg32_get_num_lines(base));
    printf("[axi_llc] BIST Outcome      :       %d\r\n", axi_llc_reg32_get_bist_out(base));

    axi_llc_reg32_all_spm(base);
}

int main(void) {
    // init_uart(200000000, 115200);
    init_uart(50000000, 115200);

    uart_initialized = 1;

    init_llc((void *)&__base_axi_llc);
}
