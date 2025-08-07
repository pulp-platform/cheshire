# Xilinx FGPAs

This page describes how to map Cheshire on Xilinx FPGAs to *execute baremetal programs* or *boot CVA6 Linux*. Please first read [Getting Started](../gs.md) to make sure have all dependencies and built the hardware, software, and Xilinx FPGA scripts. Additionally, for on-chip debugging you need:

- OpenOCD `>= 0.10.0`

We currently provide working setups for:

- Digilent Genesys 2 with Vivado `>= 2020.2`
- Xilinx VCU118 with Vivado `>= 2020.2`
- Xilinx VCU128 with Vivado `>= 2020.2`

We are working on support for more boards in the future.

We assume that the `VIVADO` environment variable points to the main binary of your Vivado installation. Before proceeding, you can set this variable for your current shell as follows:

```
export VIVADO="/path/to/your/vivado"
```

## Implementation

Generate the bitstream `target/xilinx/out/cheshire.<myboard>.bit` for your desired board by running:

```
make chs-xilinx-<myboard>
```

Since available features vary between boards, we provide further documentation for each.

### Digilent Genesys 2 (`genesys2`)

Before flashing the bitstream to your device, take note of the position of onboard switches, which control important functionality:

  | Switch | Function                                        |
  | ------ | ------------------------------------------------|
  | 1 .. 0 | Boot mode; see [Boot ROM](../um/sw.md#boot-rom) |
  | 5 .. 2 | Fan level; *do not* keep at 0                   |
  | 7      | Test mode; *leave at zero*                      |

The reset, JTAG TAP, UART, I2C, and VGA are all connected to their onboard logic or ports. The UART has *no flow control*. The microSD slot is connected to chip select 0 of the SPI host peripheral. Serial link and GPIOs are currently not available.

### Xilinx VCU118 (`vcu118`) and VCU128 (`vcu128`)

Since there are no switches on these boards, the boot mode must be selected using Virtual IOs (see [Virtual IOs](#virtual_ios) below).

These boards provide a JTAG TAP and a UART without flow control connected to onboard ports. The SPI host peripheral connects to the `STARTUPE3` IP block, which provides access to the onboard flash. All other IOs are currently not available.

### Virtual IOs

To provide control of important IO without direct access to onboard switches, we provide the following virtual IOs on all boards, which may be controlled at runtime through Vivado's hardware manager:

  | Virtual IO          | Function                                   |
  | ------------------- | -------------------------------------------|
  | `vio_reset`         | Assert reset (active high)                 |
  | `vio_boot_mode`     | Externally override boot mode              |
  | `vio_boot_mode_sel` | Whether to override boot mode from FPGA IO |

### Inserting ILA probes

For analysis and debugging purposes, integrated logic analyzer (ILA) probes may be added to the design's RTL description. You can do this either by marking signals with appropriate attributes or by using the `ila` macro from the `phy_definitions.svh` header:

```systemverilog
/* Option 1 */ (* dont_touch = "yes" *) (* mark_debug = "true" *) logic mysignal;
/* Option 2 */ `ila(my_ila_name, mysignal)
```

## Debugging with OpenOCD

To establish a debug bridge over JTAG, ensure the target is in a debuggable state (for example by resetting into the idle boot mode 0) and launch OpenOCD with:

```
openocd -f util/openocd.<board_or_adapter>.tcl
```

If multiple JTAG adapters are connected to your debugging machine, you may have to extend the script to specify desired adapter's serial number.

In another shell, launch a RISC-V GDB session attaching to OpenOCD:

```
riscv64-unknown-elf-gdb -ex "target extended-remote localhost:3333"
```

You can now interrupt (Ctrl+C), inspect, and repoint execution with GDB as usual. Note that resetting the board during debug sessions is not supported. If the debug session dies or you need to reset the board for another reason:

1. Terminate GDB and OpenOCD
2. Reset the board
3. Relaunch OpenOCD, then GDB.

## Running Baremetal Code

Baremetal code can be preloaded through JTAG using OpenOCD and GDB or loaded from a bootable device, such as an SD card. In principle, other interfaces may also be used to boot if the board provides them, but no setups are available for this.

First, connect to UART using a serial communication program like minicom:

```
minicom -c on D /dev/ttyUSBX
```

Make sure that hardware flow control matches your board's setup (usually *off*).

In the following examples, we will use the `helloworld` test. As in simulation, you can replace this with any baremetal program of your choosing or design; see [Baremetal Programs](../um/sw.md#baremetal-programs).

### JTAG Preloading

Start a debug session in the project root and enter in GDB:

```
load sw/tests/helloworld.spm.elf
continue
```

You should see `Hello World!` output printed on the UART.

### Boot from SD card (`genesys2` only)

First, build an up-to-date GPT disk image for your desired binary. For `helloworld`:

```
make sw/tests/helloworld.gpt.bin
```

Then flash this image to an SD card (*note that this requires root privileges*):

```
sudo dd if=sw/tests/helloworld.gpt.bin of=/dev/<sdcard>
sudo sgdisk -e /dev/<sdcard>
```

The second command only ensures correctness of the partition layout; it moves the secondary GPT header at the end of the minimally sized image to the end of your actual SD card.

Insert your SD card and reset into boot mode 1. You should see a `Hello World!` UART output.

### Boot from onboard flash

Build a GPT disk image for your desired binary as explained above, then flash it to your board's flash. For `helloworld`:

```
make CHS_XILINX_FLASH_IMG=sw/tests/helloworld.gpt.bin chs-xilinx-flash-<myboard>
```

Flashing an image should take about 10 minutes. *Note that after flashing, your board's bitstream must be reprogrammed* as it is overridden for this task.

If the image given by `CHS_XILINX_FLASH_IMG` does not exist, `make` will attempt to build it before flashing. If `CHS_XILINX_FLASH_IMG` is not provided, the target assumes the default Linux image for your board.

After flashing your disk image and reprogramming your bitstream, reset into boot mode 2. For `helloworld`, you should again see a `Hello World!` UART output.

## Booting Linux

To boot Linux, we must load the *OpenSBI* firmware, which takes over M mode and launches the U-boot bootloader. U-boot then loads Linux. For more details, see [Boot Flow](../um/sw.md#boot-flow).

Clone the `cheshire` branch of CVA6 SDK and build the firmware (OpenSBI + U-boot) and Linux images (*this will take about 30 minutes*):

```
git submodule update --init --recursive sw/deps/cva6-sdk
cd sw/deps/cva6-sdk && make images
```

In principle, we can boot Linux through JTAG by loading all images into memory, launching OpenSBI, and instructing U-boot to load the kernel directly from memory. Here, we focus on autonomous boot from SD card or SPI flash.

In this case, OpenSBI is loaded by a regular baremetal program called the [Zero-Stage Loader](../um/sw.md#zero-stage-loader) (ZSL). The [boot ROM](../um/sw.md#boot-rom) loads the ZSL from SD card, which then loads the device tree and firmware from other SD card partitions into memory and launches OpenSBI.

To create a full Linux disk image from the ZSL, your board's device tree, the firmware, and Linux, run:

```
make ${CHS_ROOT}/sw/boot/linux.<myboard>.gpt.bin
```

where `CHS_ROOT` is the root of the Cheshire repository. Note that for some boards, additional images with different configurations (i.e. `linux.<myboard>_<myconfig>.gpt.bin`) may be available.

Flash your image to an SD card or SPI flash as described in the preceding sections, then reset into the boot mode corresponding for your boot medium. You should first see the ZSL print on the UART:

```
 /\___/\       Boot mode:       1
( o   o )      Real-time clock: ... Hz
(  =^=  )      System clock:    ... Hz
(        )     Read global ptr: 0x...
(    P    )    Read pointer:    0x...
(  U # L   )   Read argument:   0x...
(    P      )
(           ))))))))))
```

You should then boot through OpenSBI, U-Boot, and Linux until you are dropped into a shell.
