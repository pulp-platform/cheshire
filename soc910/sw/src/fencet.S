# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nils Wistoff <nwistoff@iis.ee.ethz.ch>

.text
.global _start
_start:
li sp, 0xee000
li a0, 2

# .align 12
# l1:
#   j l2
# .align 12
# l2:
#   j l3
# .align 12
# l3:
#   j l4
# .align 12
# l4:
#   j l5
# .align 12
# l5:
#   j l6
# .align 12
# l6:
#   j l7
# .align 12
l7:
  nop
  call fence_t
  addi a0, a0, -1
  bnez a0, l7

end:
  j end

fence_t:
  # save stack pointer in CSR
  csrw mscratch, sp

  # save registers on stack
  sd x1,  0*8(sp)
  # skip sp
  sd x3,  1*8(sp)
  sd x4,  2*8(sp)
  sd x5,  3*8(sp)
  sd x6,  4*8(sp)
  sd x7,  5*8(sp)
  sd x8,  6*8(sp)
  sd x9,  7*8(sp)
  sd x10, 8*8(sp)
  sd x11, 9*8(sp)
  sd x12, 10*8(sp)
  sd x13, 11*8(sp)
  sd x14, 12*8(sp)
  sd x15, 13*8(sp)
  sd x16, 14*8(sp)
  sd x17, 15*8(sp)
  sd x18, 16*8(sp)
  sd x19, 17*8(sp)
  sd x20, 18*8(sp)
  sd x21, 19*8(sp)
  sd x22, 20*8(sp)
  sd x23, 21*8(sp)
  sd x24, 22*8(sp)
  sd x25, 23*8(sp)
  sd x26, 24*8(sp)
  sd x27, 25*8(sp)
  sd x28, 26*8(sp)
  sd x29, 27*8(sp)
  sd x30, 28*8(sp)
  sd x31, 29*8(sp)

  # configure reset vector
  la a0, post_fence_t
  csrw mrvbr, a0

  # clear dcache
  .word 0x0010000b # dcache.call

  # microreset
  .word 0x01a0000b # sync.i
  .word 0x01c0000b # fence.t
post_fence_t:
  .word 0x01a0000b # sync.i

  # restore stack pointer from CSR
  csrr sp, mscratch

  # restore registers from stack
  ld x1,  0*8(sp)
  # skip sp
  ld x3,  1*8(sp)
  ld x4,  2*8(sp)
  ld x5,  3*8(sp)
  ld x6,  4*8(sp)
  ld x7,  5*8(sp)
  ld x8,  6*8(sp)
  ld x9,  7*8(sp)
  ld x10, 8*8(sp)
  ld x11, 9*8(sp)
  ld x12, 10*8(sp)
  ld x13, 11*8(sp)
  ld x14, 12*8(sp)
  ld x15, 13*8(sp)
  ld x16, 14*8(sp)
  ld x17, 15*8(sp)
  ld x18, 16*8(sp)
  ld x19, 17*8(sp)
  ld x20, 18*8(sp)
  ld x21, 19*8(sp)
  ld x22, 20*8(sp)
  ld x23, 21*8(sp)
  ld x24, 22*8(sp)
  ld x25, 23*8(sp)
  ld x26, 24*8(sp)
  ld x27, 25*8(sp)
  ld x28, 26*8(sp)
  ld x29, 27*8(sp)
  ld x30, 28*8(sp)
  ld x31, 29*8(sp)

  ret

