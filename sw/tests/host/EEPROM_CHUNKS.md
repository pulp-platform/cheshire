# EEPROM chunk progress

The old initial unaligned chunk could exceed the requested length.
Its write helper also selected a later final byte and recursively advanced
by the full length instead of the transmitted half. These paths could modify
read guards, skip write payload, and issue bytes beyond the caller's request.

Return immediately for length zero. Limit each chunk to the remaining request
and its FIFO-aligned boundary. Advance by the actual chunk length.
Keep writes within half the FIFO, with contiguous data and no recursive skip.
This patch preserves control-byte encoding, STOP flags, and completion waits.
Those defects have separate fixes.

The host test runs the actual HAL C source and the locked actual I2C DIF.
It instruments their existing MMIO boundary. It checks 100 cases:
read/write, starting addresses 0/1/31/63/127, and lengths
0/1/31/32/33/63/64/65/128/129.
It checks every data/guard byte, contiguous write addresses, exact write length,
zero-length MMIO inactivity, RX FIFO capacity, and 128-byte write-page boundaries.
Expected payload comes from the caller's source buffer or an independent
address-based read pattern. The test does not duplicate the HAL chunk loop.

Official base: Cheshire `6c6dd5e834347f72c7be31cd6c41021ec293c5b9`.
Its Bender.lock pins opentitan_peripherals to `cd3153de2783abd3d03d0595e6c4b32413c62f14`.
GCC `-O2 -Wall -Wextra -Werror` compiled both versions without warnings.
The same 100-case input produced 2108 errors on the original and zero on the patch.

The test aliases the HAL initializer's `base` field token to the instrumented
MMIO type's `mock` field only while including the actual HAL C source.
It supplies a CLINT callback and scripted FIFO responses.
These are host test adapters, not a controller or EEPROM RTL model.
This test checks software request/data progress. It does not check STOP
completion, real bus timing, or the separate block/device control-byte issue.
No EEPROM model is included.

## Reproduction

Set `OTP` to the locked dependency checkout. From the repository root:

```bash
ROOT=$PWD
mkdir test-eeprom-chunks
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -DMOCK_MMIO \
  "-DHAL_SOURCE=\"$ROOT/sw/lib/hal/i2c_24fc1025.c\"" \
  -I"$ROOT/sw/include" -I"$OTP" -I"$OTP/sw/include" \
  sw/tests/host/test_eeprom_chunks.c \
  "$OTP/sw/device/lib/dif/dif_i2c.c" \
  "$OTP/sw/device/lib/dif/autogen/dif_i2c_autogen.c" \
  "$OTP/sw/device/lib/base/bitfield.c" -o test-eeprom-chunks/test
timeout 10 ./test-eeprom-chunks/test
```

For the original comparison, point `HAL_SOURCE` to the C file from the stated base.
Keep the test, headers, DIF, and compiler options identical.
The original reports `EEPROM_CHUNK_DONE cases=100 errors=2108` and returns 1.
The patch reports `EEPROM_CHUNK_DONE cases=100 errors=0` and returns 0.
The test also limits MMIO calls to reject a polling hang.

AI assistance: OpenAI Codex assisted implementation, test, and validation.
