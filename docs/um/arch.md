# Architecture

![Image title](../img/arch.svg)

Cheshire is highly configurable; available features and resources depend on its parameterization. The above block diagram depicts a fully-featured Cheshire SoC, which currently provides:

* **Cores**:
    * Up to 16 Linux-capable CVA6 cores with self-invalidation-based coherence
    * A RISC-V debug module with JTAG transport

* **Peripherals**:
    * Various standard IO interfaces (UART, I2C, SPI, and GPIOs)
    * A boot ROM enabling boot from SD cards, SPI flash, or I2C EEPROM
    * A VGA display controller with built-in DMA
    * A fully-digital die-to-die serial link
    * A high-throughput system DMA

* **Interconnect**:
    * A last level cache (LLC) configurable as a scratchpad memory (SPM) per-way
    * Up to 16 external AXI manager ports and 16 AXI and Regbus subordinate ports
    * Per-manager traffic regulators for real-time applications

* **Interrupts**:
    * Core-local (CLINT *and* CLIC) and platform (PLIC) interrupt controllers
    * Dynamic interrupt routing from and to internal and external targets.

## Parameterization

Except for external hart info and interface types (see [Instantiating Cheshire](../tg/integr.md#instantiating_cheshire)), Cheshire is fully parameterized through the `Cfg` struct. We will first define SoC-wide parameters, then discuss device-specific parameters for each device.



## Memory Map

Cheshire's internal memory map is *static*. While device instantiation and layout may vary, each device is provided an address space of *fixed* location and size. For this, Cheshire *reserves* the address space from `0x0` to `0x2000_0000`, which is currently allocated as follows:

+--------------------+-------------------+-------------+------+-------+
| Block              | Device            | Start       | Size | Flags |
+====================+===================+=============+======+=======+
| 256K periphs @ AXI | Debug ROM         | 0x0000_0000 | 256K | E     |
+--------------------+-------------------+-------------+------+-------+
| 4K periphs @ AXI   | AXI DMA (Cfg)     | 0x0100_0000 | 4K   |       |
+--------------------+-------------------+-------------+------+-------+
| 256K periphs @ Reg | Boot ROM          | 0x0200_0000 | 256K | E     |
|                    +-------------------+-------------+------+-------+
|                    | CLINT             | 0x0204_0000 | 256K |       |
|                    +-------------------+-------------+------+-------+
|                    | IRQ router        | 0x0208_0000 | 256K |       |
+--------------------+-------------------+-------------+------+-------+
| 4K periphs @ Reg   | SoC Regs          | 0x0300_0000 | 4K   |       |
|                    +-------------------+-------------+------+-------+
|                    | LLC (Cfg)         | 0x0300_1000 | 4K   |       |
|                    +-------------------+-------------+------+-------+
|                    | UART              | 0x0300_2000 | 4K   |       |
|                    +-------------------+-------------+------+-------+
|                    | I2C               | 0x0300_3000 | 4K   |       |
|                    +-------------------+-------------+------+-------+
|                    | SPI Host          | 0x0300_4000 | 4K   |       |
|                    +-------------------+-------------+------+-------+
|                    | GPIO              | 0x0300_5000 | 4K   |       |
|                    +-------------------+-------------+------+-------+
|                    | Serial Link (Cfg) | 0x0300_6000 | 4K   |       |
|                    +-------------------+-------------+------+-------+
|                    | VGA (Cfg)         | 0x0300_7000 | 4K   |       |
|                    +-------------------+-------------+------+-------+
|                    | AXI RT (Cfg)      | 0x0300_8000 | 4K   |       |
+--------------------+-------------------+-------------+------+-------+
| INTCs @ Reg        | PLIC              | 0x0400_0000 | 64M  |       |
|                    +-------------------+-------------+------+-------+
|                    | CLICs             | 0x0800_0000 | 64M  |       |
+--------------------+-------------------+-------------+------+-------+
| SPM @ AXI          | cached            | 0x1000_0000 | 64M  | CIE   |
|                    +-------------------+-------------+------+-------+
|                    | uncached          | 0x1400_0000 | 64M  | IE    |
+--------------------+-------------------+-------------+------+-------+

The flags are defined as follows:

* **C***acheable*: accessed data may be cached in the L1 or LLC caches
* **I***dempotent*:
* **E***xecutable*:

+--------------------+-------------------+-------------+------+-------+
| External           | CIE               | 0x2000_0000 | 512M | CIE   |
|                    +-------------------+-------------+------+-------+
|                    | non-CIE           | 0x4000_0000 | 1G   |       |
+--------------------+-------------------+-------------+------+-------+
| LLC out (DRAM)     |                   | 0x8000_0000 |      | CIE   |
+--------------------+-------------------+-------------+------+-------+

## Boot ROM
