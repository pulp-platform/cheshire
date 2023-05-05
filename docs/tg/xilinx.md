# Xilinx FGPAs

This page describes how to map Cheshire on Xilinx FPGAs to *execute baremetal programs* or *boot CVA6 Linux*. Please first read [Getting Started](../gs.md) to make sure have all dependencies and built the hardware, software, and Xilinx FPGA scripts. Additionally, for on-chip debugging you need:

- OpenOCD `>= 0.10.0`

We currently provide working setups for:

- Digilent Genesys 2 with Vivado `>= 2020.2`
- Xilinx VCU128 with Vivado `>= 2020.2`

We are working on support for more boards in the future.

## Building the bistream

Do to the structure of the Makefile flow. All the following commands are to be executed at the root of the Cheshire repository. If you want to see the targets that you will be using, you can find them in `sw/sw.mk` and `target/xilinx/xilinx.mk`.

First, make sure that you have generated all the RTL:

```bash
make chs-hw-all
```

Generate the bitstream `target/xilinx/out/cheshire_top_xilinx.bit` by running:

```bash
make chs-xil-all [VIVADO=version] [BOARD={genesys2,vcu128}] [MODE={batch,gui}] [INT-JTAG={0,1}]
```

See the argument list below:

| Argument | Relevance | Description                                                                                                                           |
|----------|-----------|---------------------------------------------------------------------------------------------------------------------------------------|
| VIVADO   | all       | Vivado command to use **(default "vitis-2020.2 vivado")**                                                                             |
| BOARD    | all       | `genesys-2` **(default)** <br>`vcu128`                                                                                                |
| INT-JTAG | vcu128    | `0` Connect the RV debug module to an external JTAG chain<br>`1` Connect the RV debug module to the internal JTAG chain **(default)** |
| MODE     | all       | `batch` Compile in Vivado shell<br>`gui` Compile in Vivado gui                                                                        |

The build time takes a couple of hours.

The above target used Bender and the file `Bender.yml` to generate the filelist required for Vivado. You can find it in 

## Board specificities

### Digilent Genesys 2
> ##### Bootmode and switches
> 
> Before flashing the bitstream to your device, take note of the position of onboard switches, which control important functionality:
> 
> 
>   | Switch | Function                                        |
>   | ------ | ------------------------------------------------|
>   | 1 .. 0 | Boot mode; see [Boot ROM](../um/sw.md#boot-rom) |
>   | 5 .. 2 | Fan level; *do not* keep at 0                   |
>   | 7      | Test mode; *leave at zero*                      |
> 
> The reset, JTAG TAP, UART, I2C, and VGA are all connected to their onboard logic or ports. The UART has *no flow control*. The microSD slot is connected to chip select 0 of the SPI host peripheral. Serial link and GPIOs are currently not available.
> 
### Xilinx VCU128
> #### Bootmode and VIOs
> 
> As there are no switches on this board, the CVA6 bootmode (see [Boot ROM](../um/sw.md#boot-rom)) is selected by Xilinx VIOs that can be set in the Vivado GUI (see [Using Vivado GUI](#bringup_vivado_gui)).
> 
> #### External JTAG chain
> 
> The VCU128 development board only provides one JTAG chain, used by Vivado to program the bitstream, and interact with certain IPs (ILAs, VIOs, ...). The RV64 host also requires a JTAG chain to connect GDB to the debug-module in the bitstream. It is possible to use the same JTAG chain for both by using `INT-JTAG=1`. In this case no external cable is required but it will not be possible to use GDB (to debug the program running on the host) and communicate with the bitstream (to debug signals using ILAs) at the same time. By using `INT-JTAG=0` it is possible to add an external JTAG chain for the RV64 host through GPIOs. Since the VCU128 does not have GPIOs we use we use a Digilent JTAG-HS2 cable connected to the Xilinx XM105 FMC debug card. See the connections in `vcu128.xdc`.

## Bare-metal bringup 

### Programming the FPGA

#### Using Vivado GUI <a name="bringup_vivado_gui"></a>

If you have closed Vivado, or compiled in batch mode, you can open the Vivado GUI with:

```bash
make chs-xil-gui
```

You can now open the Hardware Manager and program the FPGA. Once done, Vivado will give you access the to Virtual Inputs Outputs (VIOs). You can now assert the following signals (on Cheshire top level).

  | VIO               | Function                                                        |
  | ----------------- | ----------------------------------------------------------------|
  | vio_reset         | Positive edge-sensitive reset for the whole system              |
  | vio_boot_mode     | Override the boot-mode switches described above                 |
  | vio_boot_mode_sel | Select between 0: using boot mode switches 1: use boot mode VIO |

#### Using command line <a name="bringup_vivado_cli"></a>

A script `program.tcl` is available to flash the bitstream without opening Vivado GUI. You will need to give the following variable to access your board (see `target/xilinx/xilinx.mk`).

- `XILINX_PORT`: Vivado opened port (**default 3121**)
- `FPGA_PATH`: Vivado path to your FPGA (**default xilinx_tcf/Xilinx/[serial_id]**)
- `XILINX_HOST`: Path to your Vivado server (**default localhost**)

Change the values to the appropriate ones (can be found in the Vivado GUI) and programm the board:

```bash
make chs-xil-program MODE=batch BOARD=vcu128
```

### Loading binary and debugging with OpenOCD

To establish a debug bridge over JTAG, ensure the target is in a debuggable state (for example by setting the boot mode to 0 before resetting) then launch OpenOCD with:

```bash
# VCU128 : Internal JTAG
openocd -f util/openocd_vcu128.cfg
# Genesys2 : Internal JTAG
oprnocd -f util/openocd_genesys2.cfg
# All boards : External JTAG (Digilent HS2)
openocd -f util/openocd_hs2.cfg
```

In another shell, launch a RISC-V GDB session attaching to OpenOCD:

```
riscv64-unknown-elf-gdb -ex "target extended-remote localhost:3333"
```

You can now interrupt (Ctrl+C), inspect, and repoint execution with GDB as usual. Note that resetting the board during debug sessions is not supported. If the debug session dies or you need to reset the board for another reason:

1. Terminate GDB and OpenOCD
2. Reset the board
3. Relaunch OpenOCD, then GDB.

## Running Baremetal Code

Baremetal code can be preloaded through JTAG using OpenOCD and GDB or loaded from an SD Card. In principle, other interfaces may also be used to boot if the board provides them, but no setups are available for this.

First, connect to UART using a serial communication program like minicom:

```
minicom -cD /dev/ttyUSBX
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

### Load from SD Card (Genesys2) <a name="bringup_flash_sd"></a>

First, build an up-to-date a disk image for your desired binary. For `helloworld`:

```
make sw/tests/helloworld.gpt.bin
```

Then flash this image to an SD card (*note that this requires root privileges*):

```
sudo dd if=sw/tests/helloworld.gpt.bin of=/dev/<sdcard>
sudo sgdisk -e /dev/<sdcard>
```

The second command only ensures correctness of the partition layout; it moves the secondary GPT header at the end of the minimally sized image to the end of your actual SD card.

Insert your SD card and reset into __boot mode 1__. You should see a `Hello World!` UART output.

## Booting Linux

To boot Linux, we must load the *OpenSBI* firmware, which takes over M mode and launches the U-boot bootloader. U-boot then loads Linux. For more details, see [Boot Flow](../um/sw.md#boot-flow).

Clone the `cheshire` branch of CVA6 SDK into `sw/deps/cva6-sdk` and build the firmware (OpenSBI + U-boot) and Linux images (*this will take about 30 minutes*):

```bash
git submodule update --init --recursive sw/deps/cva6-sdk
make -C sw/deps/cva6-sdk images
```

In principle, we can boot Linux through JTAG by loading all images into memory, launching OpenSBI, and instructing U-boot to load the kernel directly from memory. Here, we focus on autonomous boot from SD card or SPI flash.

In this case, OpenSBI is loaded by a regular baremetal program called the [Zero-Stage Loader](../um/sw.md#zero-stage-loader) (ZSL). The [boot ROM](../um/sw.md#boot-rom) loads the ZSL from SD card, which then loads the device tree and firmware from other SD card partitions into memory and launches OpenSBI.

To create a full Linux disk image from the ZSL, device tree, firmware, and Linux, run:

```bash
# Note that the device tree's flavor depends on the board (see sw/boot/*.dts)
make chs-linux-img BOARD=[genesys2, vcu128]
```

### Digilent Genesys 2
> 
> Flash this image to an SD card as for the hello world (see [Load from SD Card](#bringup_flash_sd)), then insert the SD card and reset into boot mode 1. You should first see the ZSL print on the UART:
> 
> ```
>  /\___/\       Boot mode:       1
> ( o   o )      Real-time clock: ... Hz
> (  =^=  )      System clock:    ... Hz
> (        )     Read global ptr: 0x...
> (    P    )    Read pointer:    0x...
> (  U # L   )   Read argument:   0x...
> (    P      )
> (           ))))))))))
> ```
> You should then boot through OpenSBI, U-Boot, and Linux until you are dropped into a shell.
> 
### Xilinx VCU128
> 
> This board does not offer a SD card reader. We need to load the image in the integrated flash:
> 
> ```
> make chs-xil-flash MODE=batch BOARD=vcu128
> ```
> 
> Use the parameters defined in [Using command line](#bringup_vivado_cli) (defaults are in `target/xilinx/xilinx.mk`) to select your board:
>
> This script will erase your bitstream, once the flash has been written (c.a. 10min) you will need to re-program the bitstream on the board.

## Add your own board

If you wish to add a flow for a new FPGA board, please do the following steps:  
_Please consider opening a pull request containing the necessary changes to integrate your new board (:_

### Makefile

Add your board on top of `target/xilinx/xilinx.mk`, in particular `XILINX_PART` and `XILINX_BOARD` are identifying the FPGA chip and board (can be found in VIvado GUI). The parameters identifying your personal device `XILINX_PORT`, `FPGA_PATH`, `XILINX_HOST` can be left empty for now.  
You then need to define `ip-names` with the Xilinx IPs that you will be using: DDR3/4 depending on your board, Clock Wizard, VIOs. See next sections for more explanations.

### Vivado IPs

#### Re-arametrize existing IPs

Cheshire's emulation requires a few Vivado IPs to work properly. They are defined and pre-compiled in `target/xilinx/xilinx/*`.  
If you add a new board, you will need to reconfigure your IPs for this board. For instance, to use the _Vivado MIG DDR4 controller_, modify `target/xilinx/xilinx/xlnx_mig_ddr4/run.tcl`. There, add the relvant `$::env(BOARD)` entry with your configuration.  
To know which configuration to use your board, you can open a blank project in Vivado GUI, create a blank block design, and instanciate the MIG DDR4 IP there. The Vivado TCL console should write the default parameters for your FPGA. You can later re-configure the IP in the block design and Vivado will print to the tcl console the modified parameters. Then yuo can copy these tcl lines to the `run.tcl` file. Make sure that you added your ip to `target/xilinx/xilinx.mk` under "ip-names".

#### Add a new IP

If your board require a new IP that has not been integrated already do the following :

- Add a new folder `target/xilinx/xilinx/[your_ip]` taking the example of the `xlnx_mig_ddr4`.
- Modify `target/xilinx/xilinx/[your_ip]/tcl/run.tcl` and `target/xilinx/xilinx/[your_ip]/Makefile` accordingly.
- Add your IP to `target/xilinx/xilinx.mk` under "ip-names".

#### Instantiate your IP

Connect it's top module in the top-level: `target/xilinx/src/cheshire_top_xilinx.sv` (you can already ). If your IP is a DDR controller, please add it to `target/xilinx/src/dram_wrapper_xilinx.sv`. Note that this file contains a pipeline to resize AXI transactions from Cheshire to your controller.

Add the relevant macro parameters to `target/xilinx/src/phy_definitions.sv` in order to disable your IP for non-relevant boards.

#### Debug

It is possible to use ILA (Integrated Logic Analyzers) in order to debug some signals on the running FPGA. Add the following before declaring your signals:

```verilog
  // Indicate that you need to debug a signal
  (* dont_touch = "yes" *) (* mark_debug = "true" *) logic signal_d0;
  // You can also use the following macro from phy_definitions.svh
  `ila(ila_signal_d0, signal_d0)
```

Then, re-build your bitstream.

It is also possible to simulate your IPs with `target/xilinx/sim` (undocumented yet).
