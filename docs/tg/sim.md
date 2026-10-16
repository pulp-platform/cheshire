# Simulation

This page describes how to simulate Cheshire to *execute baremetal programs*. Please first read [Getting Started](../gs.md) to make sure have all dependencies and built the hardware, software, and simulation scripts.

We currently provide working setups for:

- Questa Advanced Simulator (QuestaSim) `>= 2022.3`
- VCS `>= 2024.09`
- Verilator `>= 5.052` (untimed, with a C++ harness; see [Verilator](#verilator))

We plan on supporting more simulators in the future. If your situation requires it, simulating Cheshire on other setups should be straightforward.

## Testbench

We provide a SystemVerilog testbench for `cheshire_soc` running baremetal programs. This code is either preloaded through simulated interface drivers or read from external memory models by the boot ROM and then executed, depending on how the  `PRELMODE` and `BOOTMODE` variables are set:

| `BOOTMODE` | `PRELMODE` | Action                                                |
| ---------- | ---------- | ----------------------------------------------------- |
| 0          | 0          | Preload through JTAG                                  |
| 0          | 1          | Preload through serial link                           |
| 0          | 2          | Preload through UART                                  |
| 1-3        | -          | Autonomous boot, see [Boot ROM](../um/sw.md#boot-rom) |

Preloading boot modes expect an ELF executable to be passed through `BINARY`, while autonomous boot modes expect a disk image (GPT formatted or raw code) to be passed through `IMAGE`. For more information on how to build software for Cheshire and its boot process, see [Software Stack](../um/sw.md).

The `SELCFG` variable selects the Cheshire configuration used in simulations. Possible configurations are specified in the `tb_cheshire_pkg` package. If not set or set to `0`, the default configuration is selected.

| `SELCFG` | Configuration in (`tb_cheshire_pkg`)      |
| -------- | ----------------------------------------- |
| 0        | Default configuration from `cheshire_pkg` |
| 1        | AXI-RT-enabled configuration              |
| 2        | CLIC-enabled configuration                |

The `USE_DRAMSYS` variable controls whether simulations are linked against and use DRAMSys for DRAM simulation. Note that before starting a simulation using DRAMSys, it must be built with `make chs-dramsys-all` first.

For simulation of Cheshire in other designs, we provide the module `cheshire_vip` encapsulating all verification IPs and their interfaces. For details, see [Verifying Cheshire In-System](integr.md#verifying-cheshire-in-system).

## QuestaSim

Variables are read from QuestaSim's Tcl environment. After building Cheshire, start QuestaSim in `target/sim/vsim` and run:

```tcl
# Preload `helloworld.spm.elf` through serial link
set BINARY ../../../sw/tests/helloworld.spm.elf
set BOOTMODE 0
set PRELMODE 1

# Compile design
source compile.cheshire_soc.tcl

# Start and run simulation
source start.cheshire_soc.tcl
run -all
```

The design needs to be recompiled only when hardware is changed. The simulation can be restarted by re-sourcing `start.cheshire_soc.tcl`, allowing binary (or image) and load method changes beforehand.

## VCS

Variables are read from your shell environment. After building Cheshire, start a POSIX-compliant shell in `target/sim/vcs` and run:

```sh
# Preload `helloworld.spm.elf` through serial link
export BINARY="../../../sw/tests/helloworld.spm.elf"
export BOOTMODE=0
export PRELMODE=1

# Compile design
./compile.cheshire_soc.sh

# Start and run simulation
./start.cheshire_soc.sh
```

The design needs to be recompiled only when hardware is changed. The simulation can be run repeatedly using `start.cheshire_soc.sh`, allowing binary (or image) and load method changes beforehand.

## Verilator

The Verilator setup in `target/sim/verilator` does not use the SystemVerilog testbench. Instead, the top level `cheshire_top_verilator` instantiates `cheshire_soc` in a configuration from `tb_cheshire_pkg`, and a C++ harness generates clocks and resets and implements the preload protocols of `vip_cheshire_soc`. DRAM and the far side of the serial link are sparse C++ memories accessed through DPI. Models are untimed (no `--timing`), and each configuration is compiled into its own model.

The harness supports the following modes:

| `BOOTMODE` | `PRELMODE` | Action                                                                     |
| ---------- | ---------- | -------------------------------------------------------------------------- |
| 0          | 0          | Preload through JTAG                                                       |
| 0          | 1          | Preload through serial link                                                |
| 0          | 2          | Preload through UART                                                       |
| 0          | 3          | Write DRAM sections directly into DRAM, others through JTAG; run via JTAG |

Autonomous boot modes and DRAMSys are not supported, as their memory models are not available for Verilator. Assertions are disabled, and uninitialized state starts at zero.

To build a model, run:

```sh
make vlt-all
```

The following variables configure the model. Each combination is built in its own directory under `target/sim/verilator/build`:

| Variable           | Default | Description                                                                      |
| ------------------ | ------- | -------------------------------------------------------------------------------- |
| `CHS_VLT_SELCFG`   | `0`     | Configuration in `tb_cheshire_pkg`, as for `SELCFG` above                        |
| `CHS_VLT_RTC_FREQ` |         | RTC frequency in Hz, overriding that of the configuration (32768 Hz by default) |
| `CHS_VLT_THREADS`  | `1`     | Number of simulation threads                                                     |
| `CHS_VLT_CPUS`     |         | CPUs to pin the simulation to with `taskset`, e.g. `0-3`                         |
| `CHS_VLT_COMPILER` | `clang` | C++ compiler for the model (`clang` or `gcc`)                                    |
| `CHS_VLT_PGO`      | `0`     | Set to `1` for profile-guided optimization, trained on `CHS_VLT_PGO_BINS`        |
| `CHS_VLT_TRACE`    | `0`     | Set to `1` for waveform support, in `CHS_VLT_TRACE_FMT` (`fst` or `vcd`)         |
| `CHS_VLT_PREFIX`   |         | Command prefix for Verilator and the model, e.g. to run them in a container      |
| `CHS_VLT_ARGS`     |         | Additional Verilator arguments                                                   |

To run a program, building the model if needed, run:

```sh
# Preload `helloworld.spm.elf` through serial link
make vlt-run BINARY=sw/tests/helloworld.spm.elf PRELMODE=1
```

`BINARY`, `BOOTMODE`, and `PRELMODE` are passed to the model as plusargs; additional plusargs can be passed through `CHS_VLT_RUN_ARGS`:

| Plusarg                            | Description                                                                         |
| ---------------------------------- | ----------------------------------------------------------------------------------- |
| `+PRELOAD_BIN=<file>@<addr>[,...]` | Write raw binaries, such as firmware or an initrd, into DRAM before simulation      |
| `+UART_BAUD=<n>`                   | Baud rate used to decode UART output (default: 115200)                              |
| `+UART_INPUT=<text>`               | Type text into the UART (escapes: `\n`, `\r`, `\t`, `\\`)                           |
| `+UART_INPUT_AFTER=<text>`         | Type only once the UART output contains this text; a leading `^` anchors it to the start of a line |
| `+UART_INPUT_GAP=<n>`              | Idle cycles between typed characters (default: 20000)                               |
| `+MAX_CYCLES=<n>`                  | Abort after `n` system clock cycles                                                 |
| `+PROGRESS=<n>`                    | Print the simulation progress every `n` cycles                                      |
| `+PC_SAMPLE=<n>`                   | Print the PC at the commit stage of hart 0 every `n` cycles, e.g. for profiling     |
| `+TRACE=<file>`                    | Dump a waveform (requires `CHS_VLT_TRACE=1`)                                        |
| `+TRACE_START=<n>`                 | Start the waveform at cycle `n`                                                     |
| `+SLINK_DEBUG`                     | Log all serial link AXI transactions                                                |
| `+MEM_DEBUG=<mask>`                | Log accesses to simulated memories (bit 0: DRAM, bit 1: serial link)                |

The model exits with code 0 on success, 1 if the program returns a nonzero value, and 2 on harness errors such as reaching `+MAX_CYCLES`.

Verilator 5.046 miscompiles Cheshire, which makes simulations hang; with this version, pass `CHS_VLT_ARGS=-fno-dfg`.

### Performance

Simulation speed mostly depends on the C++ compiler, profile-guided optimization, and thread placement. On a server CPU, models simulate at roughly 30 kHz with one thread and 90 kHz with profile-guided optimization and four threads pinned to CPUs sharing a last-level cache. Threads that are not pinned or spread over multiple last-level caches are significantly slower. Profile-guided optimization needs the training programs, which are built by `make sw-all`:

```sh
make vlt-run CHS_VLT_PGO=1 CHS_VLT_THREADS=4 CHS_VLT_CPUS=0-3 BINARY=sw/tests/helloworld.spm.elf PRELMODE=1
```

For regressions, running many single-threaded simulations in parallel gives the highest throughput.

### Booting Linux

Instead of the zero-stage loader and U-Boot, we preload OpenSBI with Linux as its payload and the device tree embedded. The device tree `sw/boot/cheshire.verilator.dts` adapts Cheshire's to simulation (200 MHz clocks, 4 Mbaud console, 256 MiB DRAM) and passes kernel arguments that shorten boot without functional changes. It expects a 1 MHz RTC, so models must be built with `CHS_VLT_RTC_FREQ=1000000`.

First, build the CVA6 SDK images as described in [Xilinx FPGAs](xilinx.md#booting-linux). Then, build the firmware:

```sh
make sw/boot/cheshire.verilator.dtb
make -C sw/deps/cva6-sdk/opensbi PLATFORM=generic \
    CROSS_COMPILE=$PWD/sw/deps/cva6-sdk/buildroot/output/host/bin/riscv64-buildroot-linux-gnu- \
    FW_PAYLOAD_PATH=$PWD/sw/deps/cva6-sdk/install64/Image \
    FW_FDT_PATH=$PWD/sw/boot/cheshire.verilator.dtb
```

Finally, preload the firmware into DRAM and boot it. In this example, `uname -a` is typed into the shell once its prompt appears:

```sh
make vlt-run CHS_VLT_RTC_FREQ=1000000 CHS_VLT_PGO=1 CHS_VLT_THREADS=4 CHS_VLT_CPUS=0-3 PRELMODE=3 \
    BINARY=sw/deps/cva6-sdk/opensbi/build/platform/generic/firmware/fw_payload.elf \
    CHS_VLT_RUN_ARGS="+UART_BAUD=4166667 '+UART_INPUT=uname -a\n' '+UART_INPUT_AFTER=^# '"
```

The simulation does not end by itself; stop it with `Ctrl-C` or through `+MAX_CYCLES`. Note that the console runs at 4.17 Mbaud, the closest rate the UART divider can produce.

By default, the CVA6 SDK builds its root filesystem into the kernel as a compressed initramfs, and its init scripts start services not usable in simulation. Unpacking and starting them takes most of the boot time. To shorten it, build the root filesystem as an uncompressed archive (`rootfs.cpio`) instead, remove files and init scripts you do not need, and pass it as an external initrd. Before building the firmware, add the initrd location to the device tree, then preload it with the firmware:

```sh
fdtput -t x sw/boot/cheshire.verilator.dtb /chosen linux,initrd-start 0x0 0x8e000000
fdtput -t x sw/boot/cheshire.verilator.dtb /chosen linux,initrd-end 0x0 \
    $(printf '0x%x' $((0x8e000000 + $(stat -c %s rootfs.cpio))))
# Add to `CHS_VLT_RUN_ARGS`:
#   +PRELOAD_BIN=rootfs.cpio@0x8e000000
```

With an initrd starting no init services, Linux reaches the shell prompt after roughly 170 M cycles, about half an hour with profile-guided optimization and four threads.
