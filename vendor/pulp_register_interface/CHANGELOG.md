# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 0.4.2 - 2023-09-15
### Added
- Expose `axi_to_axi_lite` module's `FULL_BW` parameter in `axi_to_reg`.
- Add `axi_to_reg_v2` with simpler design and improved performance.
- Add `regtool` patch to generate documentation.
### Changed
- Deprecate `axi_to_reg` in favor of `axi_to_reg_v2`.
- Bump `axi` dependency minor version to `v0.39.1`.

## 0.4.1 - 2023-06-12
### Added
- `reg_cut` module that cuts all combinational paths between src and dst
- Added basic CI tests
### Changed
- Added optional parameter to `reg_cdc` to choose between different CDC flavors.
### Fixed
- Fix typo in `reg_filter_empty_writes`.
- Remove timing loop in `reg_to_tlul`
- Add option to use 4phase CDC 

## 0.4.0 - 2023-04-28
### Breaking Changes
- Removed payload_t parameter of reg_err_slave and directly use a logic array to improve general tool support.

### Added
- Add `reg_filter_empty_writes` to return a ready without forwarding the valid for writes with strb='0.
- Split `reg_cdc` module into two different modules (`reg_cdc_src` and `reg_cdc_dst`) for source and destination side of the clock domain crossing. The `reg_cdc` module internally instantiates these IPs while maintaining the same external interface.

### Changed
- Add optional parameter to apb_to_reg converter to latch inputs on apb_sel assertions rather than feeding all signals through combinationally. The default parameter value is to not change existing behavior and this particular change is thus backward compatible.


## 0.3.9 - 2023-03-28
### Changed
- Updated Bender.yml to be in line with latest bender vendor syntax

### Fixed
- Packported upstream fix for wrong mux sel width in case of more than one window.
- Use BlockAW width rather than AW for address signal width.

## 0.3.8 - 2022-12-13
### Added
- Added interface variant of the apb_to_reg converter

### Changed
- Added APB as a dependency of this repository (we need the interface definition)
- The reggen tool now also generates regfile variants with a SystemVerilog interface port for the regbus.

## 0.3.7 - 2022-12-02
### Changed
- Bump AXI version to v0.38.0

## 0.3.6 - 2022-11-07
### Added
- Add `reg_to_abp` adapter to convert between register_interface protocol to AMBA APB

## 0.3.5 - 2022-11-02
### Added
- Add `reg_err_slv` module, a reg interface slave that always responds with an error.
### Changed
- Added an `external_import` section to the `Bender.yml` to replace the `vendor.py` import with the new bender feature.

## 0.3.4 - 2022-10-14
### Added
- Add reg2tlul protocol converter

## 0.3.3 - 2022-08-26
### Fixed
- Fix `reg_mux` multiple assignments
- Add patches from `snitch`:
  - `vendor.py`: Add capability to patch individual files
  - `reggen`: Fix windowing bug
  - `reggen`: Fix solderpad license check

## 0.3.2 - 2022-04-11
### Changed
- Bump AXI version

## 0.3.1 - 2021-06-24
### Fixed
- Align AXI version in ips_list.yml with Bender.yml

## 0.3.0 - 2021-06-09
### Changed
- Rebased register_interface specific change of reggen tool on lowRISC upstream master
- Bump AXI version

## 0.2.2 - 2021-04-20
### Added
- Add `periph_to_reg`.

### Changed
- Bump AXI version

## 0.2.1 - 2021-02-03
### Changed
- Update `axi` to `0.23.0`
- Update `common_cells` to `1.21.0`

### Added
- Add ipapprox description

## 0.2.0 - 2020-12-30
### Fixed
- Fix bug in AXI-Lite to register interface conversion
- Fix minor style problems (`verible-lint`)

## Removed
- Remove `reg_intf_pkg.sv`. Type definitions are provided by `typedef.svh`.

### Added
- Add `reggen` tool from lowrisc.
- Add `typedef` and `assign` macros.
- Add `reg_cdc`.
- Add `reg_demux`.
- Add `reg_mux`.
- Add `reg_to_mem`.
- AXI to reg interface.
- Open source release.

### Changed
- Updated AXI dependency

## 0.1.3 - 2018-06-02
### Fixed
- Add `axi_lite_to_reg.sv` to list of source files.

## 0.1.2 - 2018-03-23
### Fixed
- Remove time unit from test package. Fixes delay annotation issues.

## 0.1.1 - 2018-03-23
### Fixed
- Add a clock port to the `REG_BUS` interface. This fixes the test driver.

## 0.1.0 - 2018-03-23
### Added
- Add register bus interfaces.
- Add uniform register.
- Add AXI-Lite to register bus adapter.
- Add test package with testbench utilities.
