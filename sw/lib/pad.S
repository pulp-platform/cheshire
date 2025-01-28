// Copyright 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nils Wistoff <nwistoff@iis.ee.ethz.ch>
//
// void pad(uint64_t cycles)
//
// Pause execution for a given number of cycles by executing a corresponding number of `nop`s.
// This assumes that one `nop` takes one cycle.

  .global pad
  .type pad, @function

pad:
  la t1, pad_end
  slli a0, a0, 1
  sub t1, t1, a0
  jr t1
  .rept 3000
  nop
  .endr
pad_end:
  ret
