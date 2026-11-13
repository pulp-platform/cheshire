# EEPROM block and chip address encoding

The 24FC1025 control byte is `1010 B0 A1 A0 R/W`.
The HAL maps logical address bit 16 to B0 and bits 17/18 to the device select pins.
The old shifts placed these bits above the byte passed to the DIF.
Truncation therefore discarded all block and chip selections.
The one-line patch places them in control-byte bits 3, 1, and 2.

Reference: [Microchip DS20001941M, Device Addressing](https://ww1.microchip.com/downloads/aemDocuments/documents/MPD/ProductDocuments/DataSheets/24AA1025-24LC1025-24FC1025-1024-Kbit-I2C-Serial-EEPROM-20001941M.pdf).

The host test runs the actual HAL C source and the actual locked OpenTitan DIF.
It instruments the existing MMIO boundary and checks the encoded FDATA bytes.
Expected control bytes are a literal table, independent of the HAL shifts.
Ten one-byte reads cover all eight block/device selections and two boundary addresses.
Both versions check returned data and all buffer guards.

Base: Cheshire `6c6dd5e834347f72c7be31cd6c41021ec293c5b9`.
Its Bender.lock pins opentitan_peripherals to `cd3153de2783abd3d03d0595e6c4b32413c62f14`.
GCC with `-Wall -Wextra -Werror` compiled both versions without warnings.
The same test produced 16 control-byte errors before the patch and zero after it.
Both versions returned the scripted data and preserved the guards.

The test aliases the HAL initializer's `base` field token to the instrumented
MMIO type's `mock` field only while it includes the exact HAL source.
It supplies a CLINT wait callback and scripted FIFO responses.
These adapters allow a host build without changing production initialization.
They do not model the EEPROM or controller RTL.
This test verifies software command encoding only. It does not verify bus timing,
STOP completion, page writes, or the separate chunking defects.

Run `make sw-test-eeprom` from the repository root to build and run the
host regression against the actual HAL and locked DIF. The target uses `CC`
and writes its binary under `.bender/test-eeprom`.

## Reproduction

Set `OTP` to the locked dependency checkout.
Run from this repository root:

```bash
ROOT=$PWD
mkdir test-eeprom-control
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -DMOCK_MMIO \
  "-DHAL_SOURCE=\"$ROOT/sw/lib/hal/i2c_24fc1025.c\"" \
  -I"$ROOT/sw/include" -I"$OTP" -I"$OTP/sw/include" \
  sw/tests/host/test_eeprom_control.c \
  "$OTP/sw/device/lib/dif/dif_i2c.c" \
  "$OTP/sw/device/lib/dif/autogen/dif_i2c_autogen.c" \
  "$OTP/sw/device/lib/base/bitfield.c" -o test-eeprom-control/test
timeout 10 ./test-eeprom-control/test
```

For the original comparison, set `HAL_SOURCE` to the file from the stated base.
Keep the same test, headers, DIF, and compiler options.
The original reports `EEPROM_CONTROL_DONE cases=10 errors=16` and returns 1.
The patch reports `EEPROM_CONTROL_DONE cases=10 errors=0` and returns 0.

AI assistance: OpenAI Codex assisted the patch, test, and validation.
