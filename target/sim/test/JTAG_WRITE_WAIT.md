# JTAG VIP write spacing with strict Capture status

The current locked DTM does not report BUSY at Capture while a write is pending.
[riscv-dbg #214](https://github.com/pulp-platform/riscv-dbg/pull/214) corrects that
behavior. With that correction, the VIP's next back-to-back write scan can set
sticky BUSY before the preceding response returns through the CDC.
Wait eight TCK cycles after each VIP write, using the existing JTAG driver method.
This provides spacing for the tested CDC path. It is not a general response
polling protocol for an endpoint with arbitrary backpressure.

Base: Cheshire `6c6dd5e834347f72c7be31cd6c41021ec293c5b9`.
The test uses its actual locked riscv-dbg `358f90110220adf7a083f8b65d157e836d706236`,
common_cells `9afda9abb565971649c2aa0985639c096f351171` and
tech_cells_generic `7968dd6e6180df2c644636bc6d2908a49f2190cf`.
The strict comparison replaces only the DTM source with #214's
`src/dmi_jtag.sv` at `7d278248e94ae35f5c913cdca5e269b1c9dfc0d7`.
That file also moves a declaration compared with the locked source; it retains
the same public ports. All other modules and the driver stay at the lock.

The test extracts the exact complete `jtag_write` task from the actual VIP.
It uses the real locked JTAG driver, DTM, TAP and CDC, with a standard DMI endpoint.
It does not elaborate the full SoC VIP or use an EEPROM model.
The endpoint records all 32 literal address/payload writes and supplies SUCCESS
responses after 0, 4 or 12 system cycles. System period is 5 ns; TCK is 20 ns.
Each run checks accepted writes, responses, all payloads and final DTM status.

| DTM | VIP | Results at each latency |
| --- | --- | --- |
| Current lock | Original | 32 writes, 32 responses, zero errors |
| Strict Capture | Original | 1 write, 1 response, 34 errors |
| Strict Capture | Eight idle cycles | 32 writes, 32 responses, zero errors |
| Current lock | Eight idle cycles | 32 writes, 32 responses, zero errors |

The current-lock control passes. The failure is the compatibility interaction
with the related DTM correction. No current-main standalone failure is claimed.
VCS W-2024.09-SP1 runs use a 1 ms HDL deadline and 60 s wall limit.
A run is accepted only with one `JTAG_WAIT_DONE`, 35 checks, zero errors,
32 accepted/returned writes, normal finish and no assertion/deadline errors.
An error count remains a failure even if simv exits zero.
This is a simulation task change, so no synthesis check applies.

## Reproduction

Set `DBG`, `CC`, and `TC` to the exact locked dependency checkouts and `CHS` to
this checkout. Keep all inputs fixed. Extract the task into the output directory:

```bash
mkdir run-jtag-write-wait
cd run-jtag-write-wait
python3 - "$CHS/target/sim/src/vip_cheshire_soc.sv" <<'EXTRACT'
import pathlib, sys
source = pathlib.Path(sys.argv[1]).read_text()
start = source.index('  task automatic jtag_write(')
end = source.index('  endtask', start) + len('  endtask')
pathlib.Path('jtag_write_task.svh').write_text(source[start:end] + '\n')
EXTRACT
timeout 180 vcs -full64 -sverilog -timescale=1ns/1ps +lint=all \
  "+incdir+$CC/include+$PWD" \
  "$TC/src/rtl/tc_clk.sv" "$CC/src/cf_math_pkg.sv" "$CC/src/sync.sv" \
  "$CC/src/cdc_reset_ctrlr_pkg.sv" "$CC/src/cdc_4phase.sv" \
  "$CC/src/cdc_reset_ctrlr.sv" "$CC/src/cdc_2phase_clearable.sv" \
  "$DBG/src/dm_pkg.sv" "$DBG/src/dmi_cdc.sv" "$DBG/src/dmi_jtag_tap.sv" \
  "$DBG/tb/jtag_dmi/jtag_intf.sv" "$DBG/tb/jtag_dmi/jtag_test.sv" \
  "$DTM" "$CHS/target/sim/test/tb_jtag_write_wait.sv" \
  -top tb_jtag_write_wait -o simv -l compile.log
for latency in 0 4 12; do
  mkdir "latency-$latency"
  (cd "latency-$latency"; timeout 60 ../simv "+LATENCY=$latency" -l run.log)
done
```

`DTM` selects the locked or strict source specified above. Extract the task from
the original base for the original-VIP comparison. Use independent build/run
directories for each combination. Do not mutate active source inputs.

AI assistance: OpenAI Codex assisted implementation, test and validation.
