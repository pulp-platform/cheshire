# Changelog

All notable changes to this project will be documented in this file.
It is updated on each new release based on contributions since the last release.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## 0.3.1 - 2025-06-16

### Added

- target/sim: Add support for non-POSIX systems in `elfloader.cpp`

### Changed

- deps: Update `apb_uart` to `v0.2.2` and its dependencies as needed

### Fixed

- target/sim: Split serial link preload at page boundaries
- target/sim: Fix `-permissive` flag in `vsim` start script
- doc: Fix documented boot mode index of I2C EEPROM


## 0.3.0 - 2025-04-14

### Added

- sw: Add `wfi` to weak trap handler to avoid spinning
- sw: Add basic test for uncached SPM

### Changed

- deps: Update AXI-RT to `0.0.0-alpha.10`
- sw: Move decoupling flags to new config argument in DMA calls

### Fixed

- bootrom: Fix platform ROM fallthrough to boot
- sw: Do not print null terminators
- target/sim: Prevent zero-length serial link bursts on preload
- target/xilinx: Avoid read-in issues when certain defines are not set
- hw: Fix executability of uncached SPM region
- bootrom: Reduce SD frequency when core frequency too low


## 0.2.0 - 2025-01-08

### Added

- sw: Add tests for DMA 2D transfers, AXI-REALM isolation, and CLIC
- sw: Add target-aware linking for BMPs
- hw: Add wrapper for new iDMA version (removed upstream)
- bootrom: Add `ebreak` on return for easier external debugging
- sw: Add SD and NOR flash write support
- util: Add disk flashing utility
- target/xilinx: Add QSPI and NOR flash boot support on Genesys2
- target/sim: Add VCS simulation setup

### Changed

- deps: Update iDMA to `v0.6.3`
- deps: Update AXI-RT to `0.0.0-alpha.9`
- sw: Various improvements to DMA and AXI-RT tests
- util: Increase OpenOCD adapter speed to 8 kHz
- sw: Clean up VCU128 NOR flash device tree entry

### Fixed

- hw: Fix uncached SPM accessibility
- sw: Avoid potentially incorrect `.bss` section delimiters
- build: Ensure use of real path as root
- hw: Fix CVA6 debug module addresses
- sw: Fix various `-Wpedantic` warnings


## 0.1.0 - 2024-10-02

### Added

- Initial versioned release of the project
- Add version-level changelog
