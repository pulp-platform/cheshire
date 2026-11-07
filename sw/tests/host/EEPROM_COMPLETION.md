# EEPROM STOP and host completion

The HAL previously omitted the final write/read STOP flag and returned after
FIFO availability. FIFO empty does not prove that the final ACK and STOP ended.
The write path also omitted the device write-cycle wait.

Request STOP on the final payload/read command. Poll the real DIF host status
before reusing the controller and before returning. After writes, request a
CLINT wait of `ceil(rtc_freq / 200) + 1` ticks after host idle.
The extra tick covers RTC phase. Read the frequency through the current official
`CHS_REGS->rtc_freq` field and reject zero before any I2C MMIO.
[Microchip DS20001941M](https://ww1.microchip.com/downloads/aemDocuments/documents/MPD/ProductDocuments/DataSheets/24AA1025-24LC1025-24FC1025-1024-Kbit-I2C-Serial-EEPROM-20001941M.pdf)
specifies a maximum 5 ms write cycle.

The test executes the actual HAL C and its locked actual I2C DIF.
The existing MMIO boundary supplies scripted FIFO-empty/RX-ready responses
while host-idle remains delayed by four status reads. The test records the
final command STOP bit and CLINT callback order/arguments.

Base: Cheshire `6c6dd5e834347f72c7be31cd6c41021ec293c5b9`.
Locked DIF: opentitan_peripherals `cd3153de2783abd3d03d0595e6c4b32413c62f14`.
GCC `-O2 -Wall -Wextra -Werror` compiled both versions without warnings.
The identical six-case input produced 25 errors before the patch and zero after it.
It includes one aligned one-byte read, zero-RTC write rejection, and four
aligned one-byte writes with RTC frequencies 1/200/32768/UINT32_MAX.
Literal expected write delays are 2/2/165/21474838 ticks.
All data and guards are checked.

The host test maps the RTC register field to a host object with its actual
register type. It aliases the initializer's `base` token to the instrumented
MMIO type's `mock` field while including the unchanged HAL C source.
The CLINT callback records the requested wait. It does not wait in real time.
This is software command/order validation, not EEPROM/controller RTL or physical
timing validation. No EEPROM model is included.

Control-byte and chunk-progression fixes remain separate. General writes larger
than half the FIFO still need the independent chunk fix. This test uses one-byte
transfers to isolate completion from those known payload defects.

## Reproduction

Set `OTP` to the locked dependency checkout. From this repository root:

```bash
ROOT=$PWD
mkdir test-eeprom-completion
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -DMOCK_MMIO \
  "-DHAL_SOURCE=\"$ROOT/sw/lib/hal/i2c_24fc1025.c\"" \
  -I"$ROOT/sw/include" -I"$OTP" -I"$OTP/sw/include" \
  sw/tests/host/test_eeprom_completion.c \
  "$OTP/sw/device/lib/dif/dif_i2c.c" \
  "$OTP/sw/device/lib/dif/autogen/dif_i2c_autogen.c" \
  "$OTP/sw/device/lib/base/bitfield.c" -o test-eeprom-completion/test
timeout 10 ./test-eeprom-completion/test
```

For the original comparison, point `HAL_SOURCE` to the C file from the stated base.
Keep the same test, headers, DIF, and compiler options.
Original: `EEPROM_COMPLETION_DONE cases=6 errors=25`, return 1.
Patch: `EEPROM_COMPLETION_DONE cases=6 errors=0`, return 0.
The test also enforces a finite MMIO polling budget.

AI assistance: OpenAI Codex assisted implementation, test, and validation.
