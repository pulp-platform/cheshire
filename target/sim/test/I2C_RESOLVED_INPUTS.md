# I2C resolved inputs in the simulation VIP

The I2C input buffers used `~i2c_*_en` as their enable.
When the DUT drove either line low, its corresponding input became high impedance.
The controller therefore could not observe the actual resolved bus value.

Sample both I2C inputs continuously. Preserve the open-drain output buffers,
pullups, and all SPI input/output buffers.

The finite test instantiates the real `vip_cheshire_soc_tristate` module.
It sweeps all 16 combinations of DUT and peer low/release controls for SDA/SCL.
It also checks released inputs and unchanged SPI input gating.
The test contains no EEPROM model.

Official base: `6c6dd5e834347f72c7be31cd6c41021ec293c5b9`.
VCS W-2024.09-SP1 compiled both versions. The same 78-check input produced
16 input mismatches on the original and zero on the patch.
The original ended with the expected failure. The patch finished normally at 250 ns.
Both used a 1 us HDL deadline and a 60-second wall-clock limit.

Run `make sim-test-i2c-inputs` with VCS on PATH. The target checks the
summary, normal finish and errors. Logs stay under `.bender/test-i2c-inputs`.

## Reproduction

The isolated test extracts the complete real tristate module without edits.
A small package supplies only the SPI chip-select port width for elaboration.
It does not model any I2C behavior or replace the DUT.
From the repository root with VCS on PATH:

```bash
ROOT=$PWD
mkdir test-i2c-inputs
cd test-i2c-inputs
cat > package.sv <<'SV'
package cheshire_pkg;
  localparam int unsigned SpihNumCs = 2;
endpackage
SV
sed -n '/^module vip_cheshire_soc_tristate/,$p' \
  "$ROOT/target/sim/src/vip_cheshire_soc.sv" > vip_tristate.sv
timeout 120 vcs -full64 -sverilog -timescale=1ns/1ps package.sv \
  vip_tristate.sv "$ROOT/target/sim/test/tb_i2c_resolved_inputs.sv" \
  -top tb_i2c_resolved_inputs -o simv -l compile.log
timeout 60 ./simv -l run.log
```

For the original comparison, extract the module from the stated official base.
Use a separate output directory and the identical test and package.
The patched log must contain one `I2C_PIN_DONE checks=78 errors=0`, a normal
`$finish`, and no mismatch, fatal, or timeout. The original must report exactly
16 mismatches and the failure marker. A process exit code alone is insufficient.

This is a four-state simulation-wrapper test. It does not verify the full
I2C controller, EEPROM protocol, or SoC. No synthesizable RTL changes.

The full SoC EEPROM boot was also compiled and run. Both the official base
and the patch report a 385 ns SCL low pulse against the EEPROM model minimum
of 500 ns. Full EEPROM boot therefore remains unverified. The finite input
test above passes independently of that timing failure.

AI assistance: OpenAI Codex assisted the patch, test, and validation.
