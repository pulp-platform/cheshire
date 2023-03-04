# Cheshire

This repository hosts the Cheshire SoC platform. Cheshire is a minimal
Linux-capable SoC built around the RISC-V CVA6 core. It is developed as part of
the PULP project, a joint effort between ETH Zurich and the University of
Bologna started in 2013.

## Disclaimer

This project is still considered to be in early development; some parts may not
yet be functional, and existing interfaces and conventions may be broken without
prior notice. We target a formal release in the very near future.

## Build the platform

We rely on [`bender`](https://github.com/pulp-platform/bender) as IP dependency
tool. Please follow the instructions in the `bender` repository for instalation
guidelines.

To build different parts of the project, run `make` followed by these targets:

* `hw-all`: generated hardware IPs. Running `hw-all` is *required* at least once
to correctly configure IPs we depend on. On reconfiguring any generated hardware
or changing IP versions, `hw-all` should be rerun.
* `bootrom-all`[^1]: generated boot ROM
* `sw-all`[^1]: software running on our hardware
* `sim-all`[^2]: scripts and external models for simulation
* `xilinx-all`: scripts for Xilinx FPGA implementation

[^1] `bootrom-all` and `sw-all` demand RV64 gcc compiler, and is required to add
it to the `PATH` variable:

```
export PATH=<path_to_your_rv64_gcc_compiler>/bin:$PATH
```

If you have access to our internal servers, you can use:

```
export PATH=/usr/pack/riscv-1.0-kgf/riscv64-gcc-11.2.0/bin:$PATH
```

[^2] `sim-all` will download externally provided peripheral simulation models,
some proprietary and with non-free license terms, from their publically
accessible sources; see `Makefile` for details. By running `sim-all` or the
default target `all`, you accept this.*


To run all build targets above:

```
make all
```

If you have access to our internal servers, you can run `make nonfree-init` to
fetch additional resources we cannot make publically accessible. Note that these
are *not required* to use anything provided in this repository.


## Add your own C/C++ code

Cheshire is a general-purpose system in its minimal single-core configuration.
The steps described below allows you to add your own code in embedded C/C++ and
compile it for the Cheshire platform.

From the root of the repository, go in the `sw/tests` directory.

`cd sw/tests`

Add the C/C++ sources of your application.

Compile the code from the root of the repository (remember to set the compiler path as explained in [^1]):

`make sw-all`

This will create the executable (`.elf`) and disassembly (`.dump`) of your code
in the `sw/tests` directory. The executable serves as input for both the RTL-
and FPGA-based simulations, as explained below.

### Caveat: Compiling for RTL or FPGA simulations

Currently, an application code requires to differentiate the baudrate of the
UART to display characters between RTL to FPGA simulation.

When compiling code for RTL simulation, in your C file use:

`init_uart(200000000, 115200);`

While for FPGA simulation, use

`init_uart(50000000, 115200);`

## Start an RTL simulation

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

```
cd target/sim/vsim
vsim &
```

From the Questasim GUI, type:

```
vsim> source ./compile.cheshire_soc.tcl
vsim> set BINARY ../../../sw/tests/<your_binary.elf>
vsim> set TESTBENCH tb_cheshire_soc
vsim> source ./start.cheshire_soc.tcl`
```

## FPGA prototyping

FPGA mapping of the SoC for both bare-metal and Linux-driven operation modes
currently targets `Xilinx Genesys II` with `Xilinx Vivado`. We rely on
`Vitis-2022.1`, but other versions can be used.

### FPGA synthesis and implementation

To synthesize and implement the design for the target board, from the root of the repository type:

```
make -C target/xilinx
```

This will generate the bitstream of the Cheshire SoC with `Xilinx Vivado` in batch
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
when synthesizing and implementing the platform on the FPGA. From the root of
the repository:

```
cd target/xilinx
vitis-2022.1 vivado cheshire.xpr -nojournal -mode batch -source scripts/pragram.tcl
```

#### Connect GDB to the board with OpenOCD

Set the OpenOCD bridge. Open a new terminal and type:

```
openocd -f $(bender path ariane)/corev_apu/fpga/ariane.cfg
```

Connect GDB through OpenOCD. Open a second terminal and make sure the cRV64 gcc
compiler is still in your `PATH` as in [^1]. Type:

```
riscv64-unknown-elf-gdb -ex "target extended-remote localhost:3333"
```

Display Cheshire's UART stdout through the UART/USB interface. Connect the
UART/USB of the board (e.g., the `Digilent Genesys II`) to a USB port of your
local machine. Then open a third terminal and type:

```
minicom -D /dev/ttyUSBX
```

Where `X` is the USB port of your local machine.

You are now ready to preload code in GDB and have fun. From the GDB shell (the
second of the three you opened)

```
gdb> load <path to your .elf executable>
gdb> continue
```

### Repository structure

The root repository is structured as follows:

| Directory | Description | Documentation |
| --- | --- | --- |
| `hw` | Contains the hardware top-level sources in SystemVerilog. | [hw/README.md](http://./hw) |
| `sw` | Contains the main dependencies of the software stack, the CVA6 SDK (as a submodule), and user tests. | [sw/README.md](http://./sw) |
| `target` | Contains simulation, FPGA and ASIC targets. | [target/README.md](http://./target) |
| `util` | Contains several utilities such as bootrom generation script, linters and licence checkers. | [util/README.md](http://./util) |

## License

Unless specified otherwise in the respective file headers, all code checked into
this repository is made available under a permissive license. All hardware
sources and tool scripts are licensed under the Solderpad Hardware License 0.51
(see `LICENSE`) with the exception of generated register file code (e.g.
`hw/regs/*.sv`), which is generated by a fork of lowRISC's
[`regtool`](https://github.com/lowRISC/opentitan/blob/master/util/regtool.py)
and licensed under Apache 2.0. All software sources are licensed under Apache
2.0.
