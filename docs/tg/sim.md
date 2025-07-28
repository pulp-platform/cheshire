# Simulation

This page describes how to simulate Cheshire to *execute baremetal programs*. Please first read [Getting Started](../gs.md) to make sure have all dependencies and built the hardware, software, and simulation scripts.

We currently provide working setups for:

- Questa Advanced Simulator (QuestaSim) `>= 2022.3`
- VCS `>= 2024.09`

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
