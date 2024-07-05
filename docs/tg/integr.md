# SoC Integration

Cheshire is designed to be *highly configurable* and provide host and interconnect infrastructure for systems on various scales. Examples of SoCs integrating Cheshire as a host are:

- [Basilisk](https://github.com/pulp-platform/cheshire-ihp130-o), an minimal end-to-end open-source Linux-capable SoC built with open tools.
- [Carfield](https://github.com/pulp-platform/carfield), a mixed-criticality SoC targeting the automotive domain.

## Using Cheshire In Your Project

As for internal targets, Cheshire *must be built* before use in external projects. We aim to simplify this as much as possible with a portable *make fragment*.

If you use GNU Make to build your project and Bender to handle dependencies, you can include the Cheshire build system into your own makefile with:

```make
include $(shell bender path cheshire)/cheshire.mk
```

All of Cheshire's build targets are now available with the prefix `chs-`. Alternatively, the variables `CHS_*` provide the non-phony targets built by each of these targets.

You can leverage this to ensure your Cheshire build is up to date and rebuild hardware and software whenever necessary. You can change the default value of any build parameter, replace source files to adapt Cheshire, or reuse parts of its build system, such as the software stack or the register and ROM generators.

## Instantiating Cheshire

Almost all features of Cheshire can be included, excluded, or scaled through parameterization. We impose an internal memory map and reasonable constraints on all parameters, but within these constraints, Cheshire can scale to fit numerous scenarios.

We provide a SystemVerilog macros header in `hw/include/cheshire/typedef.svh` that simplifies defining necessary interface types for Cheshire. To define a configuration struct for Cheshire, we recommend defining a *function* in a system package that starts from the default configuration `DefaultCfg` in `cheshire_pkg` and changes only necessary parameters.

Unused inputs and inputs of zero effective width should be tied so as to not initiate data transfers or handshakes (usually `'0`).

A minimal clean instantiation would look as follows:

```systemverilog
`include "cheshire/typedef.svh"

// Define function to derive configuration from defaults.
// This could also (preferrably) be done in a system package.
function automatic cheshire_pkg::cheshire_cfg_t gen_cheshire_cfg();
  cheshire_pkg::cheshire_cfg_t ret = cheshire_pkg::DefaultCfg;
  // Make overriding changes. Here, we add two AXI manager ports
  ret.AxiExtNumMst = 2;
  return ret;
endfunction

localparam cheshire_cfg_t CheshireCfg = gen_cheshire_cfg();

// Generate interface types prefixed by `csh_` from our configuration.
`CHESHIRE_TYPEDEF_ALL(csh_, CheshireCfg)

// Instantiate Cheshire with our configuration and interface types.
cheshire_soc #(
  .Cfg                ( CheshireCfg ),
  .ExtHartinfo        ( '0 ), // Tie iff there are no external harts.
  .axi_ext_llc_req_t  ( csh_axi_llc_req_t ),
  .axi_ext_llc_rsp_t  ( csh_axi_llc_rsp_t ),
  .axi_ext_mst_req_t  ( csh_axi_mst_req_t ),
  .axi_ext_mst_rsp_t  ( csh_axi_mst_rsp_t ),
  .axi_ext_slv_req_t  ( csh_axi_slv_req_t ),
  .axi_ext_slv_rsp_t  ( csh_axi_slv_rsp_t ),
  .reg_ext_req_t      ( csh_reg_req_t ),
  .reg_ext_rsp_t      ( csh_reg_rsp_t )
) dut (
  // ... IOs here ...
);
```

## Verifying Cheshire In-System

To simplify the simulation and verification of Cheshire in other systems, we provide a monolithic block of verification IPs called `cheshire_vip`. This includes:

* ELF binary preloading tasks over JTAG, serial link, and UART.
* External AXI manager ports accessing the chip through the serial link.
* A UART receiver printing to standard output.
* Serial link and LLC subordinate memories.
* Preloadable I2C EEPROM and SPI NOR Flash models (used to simulate boot).

Additionally, we provide a module `cheshire_vip_tristate` which adapts the unidirectional IO of this module to bidirectional IOs which may be interfaced with pads where necessary.

## Platform ROM

To set up boot-critical resources in the surrounding system (clock sources, IO pads, memories, PHYs, ...) or fork off execution from the built-in boot ROM, Cheshire can invoke an external *platform ROM* before external interaction if configured accordingly; see [Boot ROM](../um/sw.md#boot-rom).

Note that a reference clock, a sufficiently fast and stable system clock, correctly set-up IOs, and an accessible scratchpad memory are *required* for Cheshire's built-in boot modes. Platforms which do not inherently fulfill these criteria on boot ROM entry and want to use the built-in boot methods *must* provide a platform ROM.

The platform ROM can be also used to extend and customize the boot chain. This may include adding further boot modes, suspending Cheshire boot until a given time, or implementing security features.
