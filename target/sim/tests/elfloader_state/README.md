# Reset the POSIX ELF loader state between files

This test calls the real `read_elf`, `get_entry`, `get_section`, and
`read_section` DPI functions in `target/sim/src/elfloader.cpp`. It uses the
simulator's real open-array API. It does not instantiate a CPU or SoC.

On official main `6c6dd5e834347f72c7be31cd6c41021ec293c5b9`, the POSIX loader keeps
`sections`, `mems`, and the section iterator between calls. `mems.insert` then
keeps the first payload when the next ELF uses the same load address. An
unconsumed iterator can also expose sections from earlier files. A failed open
leaves the earlier entry point visible.

The change clears these four per-file states at the start of the POSIX
`read_elf` implementation. The non-POSIX branch is unchanged. It keeps the existing API, parser, and first-load behavior.

## Reproduction

Requirements used here: LLVM 20.1.0, VCS W-2024.09-SP1, and GCC 13.3.1 on Linux.
The two fixtures contain one RX PT_LOAD segment at `0x80000000`. The first has
96 bytes and entry offset 0. The second has 64 bytes and entry offset 16.
Their byte formulas are `(13*i+17)&255` and `(13*i+114)&255`. These bytes are
loader data; a CPU never executes them.

Run from the contribution checkout. Use an empty output directory. Set `clang`
and `g++` to the installed versions if they are not on PATH.

```sh
repo=$PWD
fixture=$repo/target/sim/tests/elfloader_state
mkdir -p /tmp/cheshire-elfloader-check
cd /tmp/cheshire-elfloader-check
clang --target=riscv64-unknown-elf -march=rv64i -mabi=lp64 -nostdlib \
  -Wl,-T,"$fixture/image.ld" -DIMAGE_BYTES=96 -DIMAGE_TAG=17 \
  -DENTRY_OFFSET=0 "$fixture/image.S" -o first.elf
clang --target=riscv64-unknown-elf -march=rv64i -mabi=lp64 -nostdlib \
  -Wl,-T,"$fixture/image.ld" -DIMAGE_BYTES=64 -DIMAGE_TAG=114 \
  -DENTRY_OFFSET=16 "$fixture/image.S" -o second.elf
git -C "$repo" show 6c6dd5e834347f72c7be31cd6c41021ec293c5b9:target/sim/src/elfloader.cpp > original.cpp
first=$PWD/first.elf
second=$PWD/second.elf
for variant in original fixed; do
  mkdir "$variant"
  if [ "$variant" = original ]; then
    cpp=$PWD/original.cpp
  else
    cpp=$repo/target/sim/src/elfloader.cpp
  fi
  (cd "$variant" && timeout 1800 vcs -full64 -sverilog -timescale=1ns/1ps \
    -top tb_elfloader_state "$fixture/tb_elfloader_state.sv" "$cpp" \
    -cpp g++ -CFLAGS '-std=c++11 -Wall -Wextra' -o simv > build.log 2>&1)
  (cd "$variant" && timeout 60 ./simv +FIRST="$first" \
    +SECOND="$second" > run.log 2>&1)
done
```

The SystemVerilog deadline is 1 us.
Each simulation completes at 1 ns.

The call sequence is A, B, A, A without draining, B, A, an expected missing-file
open, then A again. The test checks entry points, segment addresses and lengths,
all payload bytes, untouched bytes in each 128-byte DPI buffer, iterator
exhaustion, failed-open state, and subsequent recovery. It does not test BSS,
ELF32, malformed ELF parsing, or the non-POSIX parser branch.

## Actual result

Both runs used exactly the same test and two ELF files:

| Input | SHA256 |
| --- | --- |
| first.elf | `f534f064f44f258ad58b6989a9db2921a5ac67e5561b42d13c20e89e1bebcc21` |
| second.elf | `b86862cae36d8f32ec50c5024486ce84b1e76690c94337bb1a6910bc6c74ad95` |
| tb_elfloader_state.sv | `bdbf752787ca4e7f3260e3a3ad0e52623ab076785a8c9d4db28aa5e976ce117b` |

Original: `ELFLOADER_DONE loads=7 drained=6 checks=954 errors=291`, followed by
`ELFLOADER_TEST_FAILED`. Fixed: `ELFLOADER_DONE loads=7 drained=6 checks=823 errors=0`
and normal `$finish`. Original checks are higher because the stale section list
exposes an extra segment and the test checks its bytes too. VCS returns zero
for the original `$fatal` here; the log result is required.

Require one fixed DONE summary with all the counts above, normal finish at
1000 ps, no TEST_FAILED or deadline, and no unexpected errors. Both logs must
contain exactly one expected unable-to-open diagnostic between
`ELFLOADER_EXPECTED_OPEN_FAILURE_BEGIN/END`. That diagnostic is the negative
control. Both C++/DPI builds pass. Both have the same existing linker warning
about VCS `rmar_nd.o` missing `.note.GNU-stack`; no added warning was found.
Synthesis checks do not apply to this host C++ utility.

The original loader authors and Apache-2.0 license remain. New fixtures and the
test use Apache-2.0. AI assistance was used for the change, test, and text.
