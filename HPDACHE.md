# HPDCache Evaluation Findings

The HPDCache has been integrated preliminarily into the [PULP fork of CVA6](https://github.com/pulp-platform/cva6/tree/paulsc/chs-hpdcache). This Cheshire branch tests and evaluates the integration and attempts to improve external bandwidth.

## BW Improvement Changes/Attempts So Far

Two changes were made in an attempt to improve NoC stream bandwidth so far:

* Replace `hpdcache_mem_req_write_arbiter` with a version that does not lockstep-couple the AW and W channels, i.e. does not block progress on receiving an AW until its W has been routed. In practice, there are usually two cycles of delay between AW and W, thus limiting peak possible writeout BW to 33%. See `hw/future/hpdcache_mem_req_write_arbiter_smart.sv` for a draft alternative design decoupling AW and W with a multiplexing decision FIFO.
* Integrate an autonomous stride-based prefetcher in the HPDCache, replacing the existing SW-controlled prefetcher. So far, it is only a simple stub capable of accelerating sequential streaming reads; see `hw/future/hwpf_stride_snoop_wrapper.sv`.

The effects of these improvements are small as the HPDcache is currently bottlenecked by its downstream (refill and writeback) bandwidth; especially the prefetcher is almost ineffectual as it is heavily stalled by refills on sequential reads.

Overall, the HPDCache achieves only fractions of the available NoC BW on streaming reads and writes even with the fixes above (see "Test Results").

## Run Testbench

We prepared a software test `corebw.spm.elf` that does a streaming write, then a streaming read (for now from the internal scratchpad to avoid latency-related issues). The goal is to maximize bandwidth to emulate strongly memory-bound sections common in OSes and memory management tasks, e.g. things involving memcpy and memset. To run this test in QuestaSim, first:

```
make all
```

then go to `target/sim/vsim` and start QuestaSim `>=2022.3`. In QuestaSim:

```
source compile.cheshire_soc.tcl
set BINARY ../../../sw/tests/corebw.spm.elf
set PRELMODE 1      ;# Preload using fastest method
source start.cheshire_soc.tcl
do hpdc.do          ;# Helpful wave file
run -all
```

The simulation should run for around 2.5 minutes real-time and a simulated time of ~3303us.

## Test Results

The test should report through a UART output (printed in per mille):

* A write throughput of 38.7%
* A read throughput of 23.3%

These are with the improved write adapter and the prefetcher working as expected, respectively.

You should see some helpful waveforms on the CVA6 AXI4 NoC port, the HPDCache core-side requests, and the HPDCache control PE illustrating bottleneck symptoms:

* The streaming write should happen from ~948us to ~1053us
* The streaming read should happen from ~1053us to ~1231us

In both cases, the core-side interface (includes both the core and prefetcher) is ready to issue accesses, but is stalled is by the cache itself.

## Interpretation (WIP, may be wrong)

I have tried looking at the control PE's behavior to understand the bottlenecks (superficially).

During the write, the core-side accesses seem to be slowed by the replay table (rtab). I am honestly not sure if this is avoidable through decoupled dataflow or caused by a fundamental underlying limitation (SRAM R/W exclusion? Would longer lines help?); I need to understand more about this.

During the read, the core is stalled out by refills. I think these stalls could at least be reduced as more core-side stall cycles are incurred than even worst-case SRAM R/W exclusion would impose.

The big question is why exactly these bottlenecks exist (limitation or oversight?) and if the associated coupling in the control PE can be relaxed somehow (with reasonable effort and PPA cost).
