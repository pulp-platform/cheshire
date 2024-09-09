# Getting Started

We first discuss the Cheshire's project structure, its dependencies, and how to build it.

## Repository structure

The project is structured as follows:

| Directory | Description                              | Documentation              |
| --------- | ---------------------------------------- | ---------------------------|
| `hw`      | Hardware sources as SystemVerilog RTL    | [Architecture](um/arch.md) |
| `sw`      | Software stack, build setup, and tests   | [Software Stack](um/sw.md) |
| `target`  | Simulation, FPGA, and ASIC target setups | [Targets](tg/index.md)     |
| `util`    | Utility scripts                          |                            |
| `doc`     | Documentation                            | [Home](index.md)           |


## Dependencies

To *build* Cheshire, you will need:

- GNU Make `>= 3.82`
- CMake `>=3.24.0`
- Python `>= 3.9`
- Bender `>= 0.27.1`
- RISCV GCC `>= 11.2.0`
- Python packages in `requirements.txt`

We use [Bender](https://github.com/pulp-platform/bender) for hardware IP and dependency management; for more information on using Bender, please see its documentation. You can install Bender directly through the Rust package manager Cargo:

```
cargo install bender
```

Depending on your desired target, additional dependencies may be needed.

## Tool Paths

Our build system assumes sane default paths for tools. However, you may need to repoint the following environment variables to specify the correct install locations on your system:

- `BENDER`: Path to Bender binary.
- `CXX_PATH`: Path to host C++ compiler within full toolchain installation (used for SystemVerilog DPI).
- `CHS_SW_GCC_BINROOT`: Path of RV64 GCC compiler within full toolchain installation.
- `CHS_SW_DTC`: Linux device tree compiler.

## Building Cheshire

To build different parts of Cheshire, run `make` followed by these targets:

- `hw-all`: generated hardware, including IPs and boot ROM
- `sw-all`: software running on our hardware
- `sim-all`(†): scripts and external models for simulation

† *`sim-all` will download externally provided peripheral simulation models, some proprietary and with non-free license terms, from their publically accessible sources; see `Makefile` for details. By running `sim-all` or the default target `all`, you accept this.*

Running `hw-all` is *required* at least once to correctly configure IPs we depend on. On reconfiguring any generated hardware or changing IP versions, `hw-all` should be rerun.

To run all build targets above (†):

```
make all
```

The following additional targets are not invoked by the above, but also available:

- `bootrom-all`: Rebuilds the boot ROM. This is not done by default as reproducible builds (as checked by CI) can only be guaranteed for fixed compiler versions.
- `nonfree-init`: Clones our internal repository with nonfree resources we cannot release, including our internal CI. *This is not necessary to use Cheshire*.
- `clean-deps`: Removes checked-out bender dependencies and submodules. This is useful when references to dependencies are updated.
- `dramsys-all`: Builds [DRAMSys-based DRAM Simulation](https://github.com/pulp-platform/dram_rtl_sim) for Cheshire's simulation targets; see [Testbench](tg/sim.md#DramSys).

## Targets

A *target* is an end use for Cheshire. Each target requires different steps from here; read the page for your desired target in the following [Targets](tg/index.md) chapter.
