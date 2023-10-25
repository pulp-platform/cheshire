# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/), and this project adheres to
[Semantic Versioning](http://semver.org).

## 0.6.0 - 2022-09-29

### Added
- `axi_riscv_atomics`: Add parameterizable cut between amo and lrsc stage

### Changed
- `axi_riscv_lrsc_tb`: Remove timeunit to improve tool compatibility


## 0.5.0 - 2022-05-03

### Changed
- `axi_riscv_lrsc`: Always apply tool workaround, as VCS also has trouble with the syntax and
  it is likely that other Synopsys tools suffer from the same problem.


## 0.4.0 - 2022-04-13

### Added
- `axi_riscv_atomics`: Add capability to use the AXI User signal as reservation ID.

### Fixed
- `axi_riscv_amos`: Use `axi_pkg::ATOP_R_RESP` to determine the need for an R response.
- `axi_riscv_amos`: Only treat requests as ATOPs if the two MSBs are nonzero.


## 0.3.0 - 2022-03-11

### Added
- Add testbench for `axi_riscv_atomics`

### Changed
- `axi_riscv_lrsc` now supports a configurable number of in-flight read and write transfers
  downstream.

### Fixed
- `axi_riscv_lrsc` is now able to sustain the nominal write bandwidth.
- `axi_riscv_lrsc` now orders SWs and SCs in accordance with RVWMO (#4).
- `axi_riscv_amos` use LR/SC to guarantee atomicity despite in-flight writes downstream.


## v0.2.2 - 2019-02-28

### Changed
- Update `axi` dependency to v0.6.0 (from an intermediary commit).


## v0.2.1 - 2019-02-25

### Fixed
- `axi_riscv_amos`: Fixed timing of R response (#10).


## v0.2.0 - 2019-02-21

### Changed
- Made SystemVerilog interfaces optional.  Top-level modules now expose a flattened port list, and
  an optional wrapper provides SystemVerilog interfaces.  This improves compatibility with tools
  that have poor support for SystemVerilog interfaces.


## Fixed
- `axi_riscv_amos`: Fixed burst, cache, lock, prot, qos, region, size, and user of ARs.


## v0.1.1 - 2019-02-20

### Fixed
- `axi_res_tbl`: Fixed assignments in `always_ff` process.
- `axi_riscv_amos`: Removed unused register.
- `axi_riscv_amos`: Added missing default assignments in AW FSM.
- `axi_riscv_amos`: Fixed sign extension of 32bit AMOs on 64bit ALU.
- `axi_riscv_amos`: Removed unused signals.
- `axi_riscv_atomics_wrap`: Fixed syntax of interface signal assignments.
- `axi_riscv_lrsc`: Added missing feedthrough of `aw_atop`.
- `axi_riscv_lrsc`: Fixed assignments in `always_ff` process.
- `axi_riscv_lrsc_wrap`: Fixed syntax of interface signal assignments.

### Added
- Added simple standalone synthesis bench for `axi_riscv_atomics`.
- Added simple standalone synthesis bench for `axi_riscv_lrsc`.


## v0.1.0 - 2019-02-19

Initial public development release
