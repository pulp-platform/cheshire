# Changelog

All notable changes to this project will be documented in this file.
It is updated on each new release based on contributions since the last release.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- sw: Fix various various `-Wpedantic` warnings


## 0.1.0 - 2024-10-02

### Added

- Initial versioned release of the project
- Add version-level changelog
