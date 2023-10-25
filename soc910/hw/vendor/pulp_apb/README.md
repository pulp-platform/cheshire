# APB

This is the implementation of the AMBA APB4 protocol, version 2.0, developed as part of the PULP
platform at ETH Zurich.

Maintainer: Andreas Kurth <akurth@iis.ee.ethz.ch>

## Overview

### Package / Macros

|           Name                           |                     Description                                   |
|------------------------------------------|-------------------------------------------------------------------|
| [`apb_pkg`](src/apb_pkg.sv)              | Package with APB4 constants and type definitions                  |
| [`apb/typedef`](include/apb/typedef.svh) | Macros which define the APB4 request/response structs             |
| [`apb/assign`](include/apb/typedef.svh)  | Macros which assign/set/translates APB4 interfaces and structs    |

### Interfaces

|           Name                           |                     Description                                   |
|------------------------------------------|-------------------------------------------------------------------|
| [`APB`](src/apb_intf.sv)                 | APB4 interface with configurable address, data and sel widths     |
| [`APB_DV`](src/apb_intf.sv)              | Clocked variant of `APB` for design verification                  |

### Leaf Modules

| Name                             | Description                                               |
|----------------------------------+-----------------------------------------------------------|
| [`apb_regs`](src/apb_regs.sv)    | Read and write registers, with optional read only mapping |
| [`apb_demux`](src/apb_demux.sv)  | APB4 demultiplexer with using select signal               |

### Verification and Simulation

|           Name                           |                     Description                                   |
|------------------------------------------|-------------------------------------------------------------------|
| [`apb_driver`](src/apb_test.sv)          | APB driver (can act as either slave or master)                    |
