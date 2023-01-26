# TODO: THIS README NEEDS TO BE REWORKED

# Cheshire: Linux-capable RISC-V SoC platform

This repository is the house of the Cheshire SoC platform. Cheshire is a Linux
capable SoC built around the RISC-V CVA6 core. It is developed within the PULP
project, started in 2013 as a joint effort between ETHZ in Zurich and University
of Bologna in Italy.

## SoC hardware architecture

TBD

## SoC software stack

TBD

## Build the platform

Before starting RTL simulation, FPGA mapping or ASIC implementation, we need to
build the full set of hardware sources. This includes:

* Fetching the `nonfree` services containing tech-dependent scripts and
  vendor-specific models that can't be open-sourced.
* Fetching `git submodules` dependencies.
* Fetching IP dependencies to build the SoC. The default IP dependency tool is
  [Bender](https://github.com/pulp-platform/bender).
* Compiling memory-mapped registers for external IOs to build the SoC. Registers
  are handled with OpenTitan's
  [reggen](https://github.com/pulp-platform/register_interface/blob/master/vendor/lowrisc_opentitan/util/regtool.py)
  tool.
* Compiling the bootcode and generating the synthesizable boot ROM to build the
  SoC.

To accomplish this, follow the instructions below.

### Cloning the `nonfree` services
Some services are not available open-source. This includes tech-dependent files
for ASIC, external IP behavioral models for RTL simulation, and internal CI.
They are collected in a private repository that can be cloned as a `make`
target. For ETH/UNIBO members, from the root of the repository type:

```console
make nonfree
```

Note that services included in the `nonfree` repository are **not mandatory** to
setup a functional simulation of the SoC, as hardware IPs that need external
models, such as DDR controller, SPI or I2C peripherals are disabled by default
and need to be manually enabled (see "Configure Cheshire" below).

### Get the submodules
From the root of the repository type:

```console
git submodule update --init --recursive
```

### Get the hardware (IP dependencies, registers generation, bootrom)
All of the hardware IPs of cheshire are open-source and exist in standalone
repositories. From the root of the repository type:

```console
make hw-all
```

## Configure Cheshire
Once the hardware IPs are fetched with Bender, Cheshire can be configured. There
are several configuration flavours:

1. Tune CVA6 features according to your needs.
2. Tune on-chip memory size according to the application.
3. Enable/disable hardware modules: as explained above, the default
   configuration of the SoC comes with fundamental peripherals that do not need
   external models in simulation, such as UART and JTAG.

**TBD TODO @ale:** expand this section

## Add your own C/C++ code

Cheshire is a general-purpose system in its minimal single-core configuration.
The steps described below allows you to add your own code in embedded
C/C++ and compile it for the Cheshire platform.

From the root of the repository, go in the `sw/tests` directory.

```console
cd sw/tests
```

Add the C/C++ sources of your application.

Compile the code from the root of the repository:

```console
make sw-all
```

This will create the executable (`.elf`) and disassembly (`.dump`) of your code
in the `sw/tests` directory. The executable serves as input for both the RTL-
and FPGA-based simulations, as explained below.

### Caveat: Compiling for RTL or FPGA simulations

There is no major difference between a user code to be executed with RTL or FPGA
simulations. The only caveat is the baudrate of the UART to display stdout characters.

When compiling code for RTL simulation, in your C file use:

```C
init_uart(200000000, 115200);
```

While for FPGA simulation, use

```C
init_uart(50000000, 115200);
```

## SoC RTL simulation - User Guide

Cycle-accurate RTL simulation of bare-metal user code in C is currently
performed with Mentor Questasim as default simulation target. Cheshire is
instantiated as Device Under Test (DUT) in a testbench environment. The
testbench controls the preloading of user executable you compiled in the
previous step in Cheshire's on-chip SRAM memory through chip-like IO interfaces,
such as JTAG or the faster Serial Link. Subsequently, the testbench drives the
booting process and monitors a specific memory-mapped register in the SoC (end
of computation register, EOC), which stores the return value of the user code
and signals the end of the execution.

From the root of the repository, type:

```console
make sim-all
cd target/sim/vsim
vsim &
```

From the Questasim GUI, type:

```console
vsim> source ./compile.cheshire_soc.tcl
vsim> set BINARY ../../../sw/tests/<your_binary.elf>
vsim> source ./start.cheshire_soc.tcl
```

We have implemented `printf` such that the microcontroller can display output on
the simulator terminal.

## SoC FPGA prototyping - User Guide

FPGA mapping of the SoC for bare-metal and Linux-driven simulation of user code
in C is currently performed with Xilinx Genesys II as target board through Xilinx Vivado.

### FPGA synthesis and implementation

To synthesize and implement the design for the target board, from the root of
the repository type:

```console
make xilinx-all
```

This will generate the bitstream of the Cheshire SoC with Xilinx Vivado in batch
mode.

### FPGA user code simulation

We distinguish between simple bare-metal and Linux-driven simulations. The
former allows code inspection and debugging with GDB, but is restricted to user
(U) and machine (M) privilege modes of the CVA6. The second relies on OpenSBI to
boot Linux and enjoy full kernel-space control of the platform.

#### Bare-metal simulation
Similarly to what described for the RTL simulation, we preload Cheshire's
on-chip SRAM with the executable code. We rely on GDB and OpenOCD to bridge the
JTAG IO interface of the SoC with the user.

#### Program the FPGA with Cheshire SoC
Connect the board to your local machine and open the Vivado project generated
when synthesizing and implementing the platform on the FPGA. We rely on
Vitis-2022.1. From the root of the repository:

```console
vitis-2022.1 vivado target/xilinx/cheshire.xpr
```

From the Vivado GUI, type:

```console
source ./scripts/program.tcl
```

#### Connect GDB to the board with OpenOCD

Set the OpenOCD bridge. Open a new terminal and type:

```console
openocd -f .bender/git/checkouts/ariane-02cf77db1585adc7/corev_apu/fpga/ariane.cfg
```

Connect GDB through OpenOCD. Open a second terminal and type:

```console
riscv64-unknown-elf-gdb -ex "target extended-remote localhost:3333"
```

Display Cheshire's UART stdout through the UART/USB interface. Connect the
UART/USB of the board (e.g., the Genesys II) to a USB port of your local
machine. Then open a third terminal and type:

```console
minicom -D /dev/ttyUSBX
```

Where `X` is the USB port of your local machine.

You are now ready to preload code in GDB and debug it! From the GDB shell (the
second of the three you opened)

```console
gdb> file <path to your .elf executable>
load
continue
```

#### Linux build and simulation

To build Linux, type:

```console
cd sw/cva6-sdk
make fw_payload.bin
make uImage
```

The generated Linux image needs to be copied on SD card. Format the SD card as
follow:

TBD

On the board, set the bootmode to 0 (`SW0` and `SW1` are OFF).

### Repository structure

The root repository is structured as follows:

| Directory | Description | Documentation |
| ------ | ------ | ------ |
| `hw` | Contains the hardware top-level sources in SystemVerilog. | [hw/README.md](./hw) |
| `sw` | Contains the main dependencies of the software stack, the CVA6 SDK (as a submodule), and user tests. | [sw/README.md](./sw) |
| `target`| Contains simulation, FPGA and ASIC targets. | [target/README.md](./target) |
| `util` | Contains several utilities such as bootrom generation script, linters and licence checkers. | [util/README.md](./util) |
