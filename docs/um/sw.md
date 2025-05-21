# Software Stack

Cheshire's software stack currently provides:

- A baremetal programming environment and hardware abstraction layer.
- A zero-stage bootloader (ZSL) and Linux boot chain.
- A CVA6 Linux with additional drivers and patches.

## Baremetal programs

Baremetal programs (BMPs) may be preloaded and invoked either by the boot ROM (see [Boot Flow](#boot-flow)) or through the RISC-V [Debug Module](arch.md#debug-module) interfaced through JTAG. They run directly in M mode. With the provided setup, BMPs can be linked to execute either from the internal scratchpad memory (SPM) or from DRAM.

The toolchain in `sw` can be used to build custom BMPs; the programs in `sw/tests` and `sw/boot` may serve as references. BMPs are linked against `libcheshire` (`sw/lib` and `sw/include`), which provides a hardware abstraction layer (HAL) and a minimal C runtime.

The C runtime calls `int main(void)` and forwards traps to the weakly-defined handler `void trap_vector(void)`, which may be left undefined if trap handling is not needed.

On program termination, bit 0 of scratch register 2 (`scratch[2][0]`) is set to 1 and the return value of `main()` is written to `scratch[2][31:1]`. Furthermore, when preloading through UART, the return value is sent out by the UART debug server (see [Passive Preload](#passive-preload)). In simulation, the testbench catches the return value and terminates the simulator, whose exit code will be nonzero *iff* the return value is.

To build a baremetal program (here `sw/tests/helloworld.c`) executing from the SPM, run:

```
make sw/tests/helloworld.spm.elf
```

To create the same program executing from DRAM, `sw/tests/helloworld.dram.elf` can instead be built from the same source.

Not all BMPs may be designed to be linked in multiple ways like `helloworld` above is. Linking is controlled by the linker scripts in `sw/link`. By convention, BMP main source files with a suffix are intended to only be linked with the corresponding script; for example, `sw/tests/dma_2d.spm.c` should only be linked against SPM using `sw/link/spm.ld`.

When building BMPs, the toolchain will strip any suffixes corresponding to existing linker scripts. When running `make sw-all`, tests in `sw/tests` will be built only for their intended linking targets. Tests without suffixes, like `helloworld`, are assumed to be agnostic and will be built for all linking targets.

## Boot Flow

On reset, Cheshire immediately starts execution and initializes a minimal C execution environment for the boot ROM by:

1. Resetting all integer registers (the FPU is disabled).
2. Pausing all nonzero harts.
3. Completing the LLC's self test (if present) and switching it to SPM.
4. Invoking the [Platform ROM](../tg/integr.md#platform-rom) (if present).

### Boot ROM

The boot ROM is implemented in *hardware* and therefore *immutable*. To guarantee verifiability and prevent silicon bricks, it provides only a handful redundant boot modes loading just enough code to run another *mutable* program or loader. It aims to do this in minimal time and without accessing unnecessary interfaces.

The boot ROM supports four builtin boot modes chosen from by the `boot_mode_i` pins:

| `boot_mode_i[1:0]`  | Boot Medium           | Interface Used             |
| ------------------- | --------------------- | -------------------------- |
| `0b00`              | Passive Preload       | JTAG, Serial Link, or UART |
| `0b01`              | SD Card               | SPI                        |
| `0b10`              | NOR Flash (S25FS512S) | SPI                        |
| `0b11`              | EEPROM (24FC1025)     | I2C                        |


Should a program invoked by the boot ROM return, the boot ROM will attempt to yield control to an external debugger if present, such as GDB, using the `ebreak` instruction.

#### Passive Preload

The *passive preload* boot mode expects code to be preloaded to an executable location and an entry point to be written to `scratch[1:0]`. After preloading, execution is launched when `scratch[2][0]` is set to 1. Unlike for autonomous boot modes, BMPs can directly be preloaded into DRAM and have no size restriction.

The JTAG and serial link interfaces can preload programs by directly accessing the memory system. Preloading through UART is special, as UART by itself does not provide a memory access protocol. On receiving an `ACK` (`0x06`) byte over UART, the boot ROM launches a *debug server* that waits for and handles the following commands:

| TX Opcode      | TX Arguments            | Command Sequence                          |
| -------------- | ----------------------- | ----------------------------------------- |
| `0x11` (Read)  | 64b address, 64b length | RX `ACK`, RX read data, RX `EOT`          |
| `0x12` (Write) | 64b address, 64b length | RX `ACK`, TX write data, RX `EOT`         |
| `0x13` (Exec)  | 64b address             | RX `ACK`, execution, RX `ACK`, RX return  |

#### Autonomous Boot

The *autonomous* boot modes load a BMP of at most 48 KiB from their boot medium into SPM, then execute it. The boot medium can either be GPT-formatted or contain raw code. If no GPT header is found, raw code execution starts from sector 0 of the boot medium.

If the boot medium is GPT-formatted, the boot ROM will search for and preload the first partition under 48 KiB in size that is formatted as a *Cheshire zero-stage loader* (see [Partition GUIDs](#partition-guids)). If no such partition is found, the boot ROM will fall back to booting from the beginning of the boot medium's first partition.

BMPs that run from SPM and fit into the alotted size can be compiled into raw images (ROMs) or GPT disk images as follows:

```
make sw/tests/helloworld.(rom|gpt).(bin|memh)
```

These images then can be copied onto a bootable disk. For convenience, we also provide a BMP that can flash images preloaded into DRAM to selected devices (`sw/boot/flash.spm.elf`). This BMP can be invoked through OpenOCD using the following script (see BMP and script for details):

```
util/flash_disk.sh <board_or_adapter> <disk_type_idx> <image>
```

### Zero-Stage Loader

The zero-stage loader (ZSL) is a simple BMP running from SPM that is responsible for chain-loading the OpenSBI firmware, which will take over and manage M mode. The OpenSBI image bundles the U-Boot bootlader as its payload, which will chain-load and invoke Linux.

Unlike the boot ROM, the ZSL is fully *mutable*. Thus, there is no danger to preloading large amounts of data, printing large messages, or accessing DRAM, as any potential bugs cannot brick silicon. The ZSL:

1. Prints a first UART output listing essential boot parameters.
2. Loads the *device tree* from the boot medium into DRAM, reusing boot ROM drivers.
3. Loads the *firmware* from the boot medium into DRAM, reusing boot ROM drivers.
4. Invokes the *firmware*, passing the *device tree* as an argument.

Note that when using preloading boot modes, steps 2 and 3 are skipped as the device tree and firmware are assumed to also be preloaded. If the ZSL is autonomously booted, both are loaded from the first partitions of corresponding type on the boot medium (see [Partition GUIDs](#partition-guids)).

### Firmware

OpenSBI takes over M mode and invokes the bundled U-Boot bootloader. U-Boot's behavior is defined by the passed device tree and its default boot command (both target-dependent), but can also dynamically be changed through its command line.

Both OpenSBI and U-Boot, provided through a fork of the [CVA6 SDK](https://github.com/pulp-platform/cva6-sdk/tree/cheshire), are largely unchanged from their upstream code bases. U-Boot is patched with a driver for Cheshire's SPI host. Non-SPI loading is currently not implemented, but can be added. Alternatively, the ZSL can be modified to directly load the Linux image to invoke into DRAM.

### Partition GUIDs

For boot purposes, Cheshire defines the following partition type GUIDs:

| Partition Type    | Type GUID                              |
| ----------------- | -------------------------------------- |
| Zero-Stage Loader | `0269B26A-FD95-4CE4-98CF-941401412C62` |
| Device Tree       | `BA442F61-2AEF-42DE-9233-E4D75D3ACB9D` |
| Firmware          | `99EC86DA-3F5B-4B0D-8F4B-C4BACFA5F859` |

In a Linux context, Cheshire adheres to established partition type GUIDs.

## Linux

Cheshire runs a slightly modified version of CVA6 Linux from the [CVA6 SDK](https://github.com/pulp-platform/cva6-sdk/tree/cheshire). Currently, it adds drivers for our SPI host to enable persistent disk IO, for example on SD cards. We plan on extending Linux driver support for Cheshire's hardware in the future.
