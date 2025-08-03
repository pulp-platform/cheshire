// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"

#define CTU_CAN_FD_DEVICE_ID 0x0
#define CTU_CAN_FD_VERSION 0x2
#define CTU_CAN_FD_MODE 0x4

int main(void) {
    uint32_t can_fd_mode = *reg32(&__base_can_bus, CTU_CAN_FD_MODE);
    uint32_t can_fd_mode_buffer = can_fd_mode;
    can_fd_mode ^= 1 << 22;
    *reg32(&__base_can_bus, CTU_CAN_FD_MODE) = can_fd_mode;
    can_fd_mode = *reg32(&__base_can_bus, CTU_CAN_FD_MODE);
    int error = (can_fd_mode == can_fd_mode_buffer);
    return error;
}
