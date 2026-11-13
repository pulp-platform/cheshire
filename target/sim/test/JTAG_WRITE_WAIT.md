# Check JTAG write request and completion status

The current locked DTM does not report BUSY at Capture while a write is pending.
[riscv-dbg #214](https://github.com/pulp-platform/riscv-dbg/pull/214) corrects that
behavior. With that correction, the VIP's next back-to-back write scan can set
sticky BUSY before the preceding response returns through the CDC.
The VIP now checks the write-request scan and a later NOP completion scan.
It keeps eight idle TCK cycles between them. It also checks DTMCS before and
after the operation, because the locked DTM can retain stale DMI bits after FAILED.
`jtag_write` keeps its existing arguments and stops on any non-SUCCESS status.
`jtag_write_status` returns the status for directed tests. Neither task retries
a write or clears sticky status. The existing command and SBA polling stay unchanged.

Base: Cheshire `6c6dd5e834347f72c7be31cd6c41021ec293c5b9`.
The test uses its actual locked riscv-dbg `358f90110220adf7a083f8b65d157e836d706236`,
common_cells `9afda9abb565971649c2aa0985639c096f351171` and
tech_cells_generic `7968dd6e6180df2c644636bc6d2908a49f2190cf`.
The strict comparison replaces only the DTM source with #214's
`src/dmi_jtag.sv` from the checked #214 correction, SHA256
`b803ad7eb081560e28fd83fe66ccc03388d403d3a964409a7f75743d5d7761df`.
That file also moves a declaration compared with the locked source; it retains
the same public ports. All other modules and the driver stay at the lock.

The test extracts the exact `jtag_write_status` and `jtag_write` tasks from the actual VIP.
It uses the real locked JTAG driver, DTM, TAP and CDC, with a standard DMI endpoint.
It does not elaborate the full SoC VIP or use an EEPROM model.
The endpoint records all 32 literal address/payload writes and supplies SUCCESS
responses after 0, 4 or 12 system cycles. System period is 5 ns; TCK is 20 ns.
Each run checks accepted writes, responses, all payloads and final DTM status.

The earlier spacing-only comparison is retained below.

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

## Status regression and Make entry

Run `make sim-test-jtag-write` with VCS on PATH. The target uses the
locked Bender dependencies. It runs all seven profiles and checks their summary,
normal finish, assertions and exit status. Output goes under `.bender/test-jtag-write`.
For the corrected-DTM comparison, set `CHS_JTAG_DTM` to its absolute source path.
Copy `.bender/test-jtag-write` before the comparison to keep both sets of logs.

The current status driver passes both DTM versions. Each version runs normal
latencies 0/4/12 (35 checks, 32 accepted and returned writes), plus four error
profiles (7 checks, 2 accepted and returned writes including recovery):

- `long`: a response delayed by 4096 system cycles reports BUSY.
- `blocked`: a held request reports BUSY, then completes once after release.
- `failed` and `busy`: endpoint error responses remain sticky.

Each error profile rejects a second write, waits for the original completion,
clears sticky status explicitly, and checks a successful recovery write.
No automatic retry is permitted. Both versions complete all seven profiles
with zero errors, normal finish and no assertion failures under VCS W-2024.09-SP1.
The 1 ms HDL and 60 s per-run wall limits remain in effect.

The test uses extracted VIP tasks, not the full SoC. The original spacing-only
failure above remains a compatibility control, not a claim against current main.

AI assistance: OpenAI Codex assisted implementation, test and validation.
