# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## Unreleased

### Added

### Changed

### Fixed

## 0.2.3 - 2022-12-20

### Added
- Add APB error slave (`apb_err_slv`).
- Add APB demux (`apb_demux`) and testbench.


## 0.2.2 - 2022-12-02

### Added
- Add APB clock domain crossing (`apb_cdc`).
- Add additional VIP classes `apb_rand_slave` and `apb_rand_master`.

### Fixed
- Improve tool compatibility by explicitly annotating the type of a `struct` assignment.
- Set the initial value of the registers as soon as the reset is released, rather than as reset
  value, because driving the reset value from an input signal is potentially unsafe.


## 0.2.1 - 2021-06-02

### Fixed
- Fix bug in `APB_TO_RESP` macro.


## 0.2.0 - 2020-03-13

### Added
- Add clocked `APB_DV` interface for design verification.
- Define macros for APB typedefs.
- Define macros for assigning APB interfaces.
- Add `apb_regs` read-write registers with APB interface with optional read only mapping.
- Add basic test infrastructure for APB modules.
- Add contribution guidelines.
- Add RTL testbenches for modules.
- Add synthesis and simulation scripts.
- `synth_bench`: add synthesis bench.

### Changed
- Rename `APB_BUS` interface to `APB`, change its parameters to constants, and remove `in` and `out` modports.


## 0.1.0 - 2018-09-12
### Changed
- Open source release.

### Added
- Initial commit.
