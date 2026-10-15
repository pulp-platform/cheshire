# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Technology- and tool-agnostic timing constraints for `cheshire_asic_top`,
# i.e. `cheshire_soc` implemented as a block without pads. Adapted from earlier
# Cheshire implementations (block level in Carfield, chip level in GF22 and
# IHP130), without anything concerning pads.
#
# All times are given in ps and converted with `chs_asic_t`. Before sourcing,
# the flow must set:
#   CHS_ASIC_TCK_SYS         system clock period [ps]
#   CHS_ASIC_PS_PER_UNIT     ps per time unit of the libraries (1 for ps, 1000 for ns)
#   CHS_ASIC_CLK_TRANSITION  clock transition before clock tree synthesis [ps],
#                            a property of the technology
#   CHS_ASIC_HOLD_UNCERTAINTY  hold margin [ps], a property of the technology;
#                            unlike setup, it does not scale with the period
# and source a tool adapter (adapters/<tool>.tcl) providing `chs_asic_reg_q` and
# `chs_asic_count`. Other parameters have defaults below.

##############
# Parameters #
##############

proc chs_asic_default { var val } {
    if { ![info exists ::${var}] } { set ::${var} ${val} }
}
foreach var {CHS_ASIC_TCK_SYS CHS_ASIC_PS_PER_UNIT CHS_ASIC_CLK_TRANSITION \
             CHS_ASIC_HOLD_UNCERTAINTY} {
    if { ![info exists ${var}] } { error "cheshire_asic.sdc: ${var} is not set" }
}

# Clock periods [ps]: JTAG (25 MHz), USB (48 MHz)
chs_asic_default CHS_ASIC_TCK_JTAG 40000
chs_asic_default CHS_ASIC_TCK_USB 20833
# Worst-case (smallest) serial link clock division; a multiple of 4, so the
# forwarded clock can be shifted by a quarter period (here: 270 degrees)
chs_asic_default CHS_ASIC_SLINK_DIV 4
# Serial link skew budget of one chip, as fraction of the half eye (a quarter
# of the link clock period): the transmitter keeps its data lanes within this
# of their ideal position against the forwarded clock, the receiver accepts
# data skewed by as much (an identical chip at the other end)
chs_asic_default CHS_ASIC_SLINK_SKEW_FRAC 0.25
# Setup clock uncertainty (skew, jitter, and margin before clock tree
# synthesis), as fraction of each clock period
chs_asic_default CHS_ASIC_UNCERTAINTY 0.05
# Synthesis margin: extra setup uncertainty synthesis optimizes for, so place
# and route can still reach the target (fraction of each clock period; 0.17
# synthesizes for a period 17% shorter). Set 0 to measure what synthesis
# alone reaches.
chs_asic_default CHS_ASIC_SYNTH_MARGIN 0.17
# External budget of the on-chip interfaces (the LLC's DRAM port, the debug
# activity output, the boot mode), as a fraction of the period, both
# directions. The block registers them (LlcPortCut) and assumes its neighbour
# does too, so the outside only adds a register's clock-to-output or setup
# time and a short wire. Their minimum delays are 0: hold at the boundary
# needs no help from outside.
chs_asic_default CHS_ASIC_ONCHIP_EXT_FRAC 0.2
# Cap [ps] on the delay of asynchronous chip I/O (see Asynchronous chip I/O):
# they have no timing relationship to any clock here, and what they carry
# changes far more slowly (an RTC at up to a few MHz, UART bits of at least 32
# system cycles, far longer in practice)
chs_asic_default CHS_ASIC_ASYNC_IO_MAX_DELAY 5000
# Cap [ps] on the delay of the VGA outputs: a monitor samples all of them at
# once, near the middle of each pixel. A quarter of the shortest pixel of the
# fastest mode supported, 1080p at 60 Hz (148.5 MHz, 6.7 ns). A pixel lasts at
# least one system cycle, so a slow system clock (e.g. in 130 nm) supports
# only slower modes: the cap is at least a quarter of the system period.
chs_asic_default CHS_ASIC_VGA_MAX_DELAY 1700
# Cap [ps] on the delay of the SPI host's pins: a quarter of the shortest time
# between a change and its sampling, half an SCK period, at the fastest SCK
# supported, 50 MHz (SD cards in high-speed mode, common flash): 10 ns. Half an
# SCK period lasts at least one system cycle, so the cap is at least a quarter
# of the system period.
chs_asic_default CHS_ASIC_SPI_MAX_DELAY 2500
# Cap [ps] on the delay of the USB outputs: D+ and D- of a full-speed port must
# switch together; a quarter of the +-3.5 ns transmitter jitter full speed allows
chs_asic_default CHS_ASIC_USB_MAX_DELAY 1000
# Maximum delay of asynchronous crossings, as fraction of the system period.
# Half a period keeps gray-coded pointers together (serial link RX FIFO)
chs_asic_default CHS_ASIC_CDC_FRAC 0.5
# The same for the crossings to and from JTAG (debug module interface), which
# carry no gray-coded pointers: two-phase handshakes, and the non-decoupled
# four-phase CDC of the DMI's reset controller, whose source register feeds
# system logic directly; its data is stable a synchronizer's cycles before use
chs_asic_default CHS_ASIC_CDC_JTAG_FRAC 0.8

# Convert ps to the time unit of the libraries
proc chs_asic_t { ps } {
    return [expr { double(${ps}) / $::CHS_ASIC_PS_PER_UNIT }]
}

# Fraction `frac` of a period `tck` [ps], in the time unit of the libraries
proc chs_asic_frac { frac tck } {
    return [chs_asic_t [expr { ${frac} * ${tck} }]]
}

set TCK_SYS ${CHS_ASIC_TCK_SYS}
set TCK_JTAG ${CHS_ASIC_TCK_JTAG}
set TCK_USB ${CHS_ASIC_TCK_USB}
set TCK_SLINK [expr { ${CHS_ASIC_SLINK_DIV} * ${TCK_SYS} }]

if { ${CHS_ASIC_SLINK_DIV} % 4 != 0 } {
    error "cheshire_asic.sdc: CHS_ASIC_SLINK_DIV must be a multiple of 4"
}

##########
# Clocks #
##########

create_clock -name clk_sys -period [chs_asic_t ${TCK_SYS}] [get_ports clk_i]
create_clock -name clk_jtag -period [chs_asic_t ${TCK_JTAG}] [get_ports jtag_tck_i]
create_clock -name clk_usb -period [chs_asic_t ${TCK_USB}] [get_ports usb_clk_i]

# The RTC input is not a clock: it only feeds a synchronizer in the CLINT,
# whose synchronized value increments the timer (see Inputs below).

# Serial link RX: data is launched by a virtual 0-degree clock; the received
# clock is shifted by 270 degrees, so DDR data is sampled in its middle
set slink_rx_edges [list [chs_asic_t [expr { 0.75 * ${TCK_SLINK} }]] \
    [chs_asic_t [expr { 1.25 * ${TCK_SLINK} }]]]
create_clock -name clk_slink_rx_virt -period [chs_asic_t ${TCK_SLINK}]
create_clock -name clk_slink_rx -period [chs_asic_t ${TCK_SLINK}] \
    -waveform ${slink_rx_edges} [get_ports slink_rcv_clk_i*]

# Serial link TX: `clk_slow` divides the system clock and launches the output
# data; the `ddr_rcv_clk_o` toggle register produces the forwarded clock,
# shifted by 270 degrees (edges counted on the system clock)
set slink_slow_q [chs_asic_reg_q *i_serial_link* clk_slow]
set slink_fwd_q [chs_asic_reg_q *i_serial_link* ddr_rcv_clk_o]
if { [chs_asic_count ${slink_slow_q}] == 0 || [chs_asic_count ${slink_fwd_q}] == 0 } {
    error "cheshire_asic.sdc: serial link clock registers not found"
}
set half_div [expr { ${CHS_ASIC_SLINK_DIV} / 2 }]
set fwd_edges [list [expr { 1 + 3 * ${half_div} }] [expr { 1 + 5 * ${half_div} }] \
    [expr { 1 + 7 * ${half_div} }]]
create_generated_clock -name clk_slink_tx_slow -source [get_ports clk_i] \
    -divide_by ${CHS_ASIC_SLINK_DIV} ${slink_slow_q}
create_generated_clock -name clk_slink_tx_fwd -source [get_ports clk_i] \
    -edges ${fwd_edges} ${slink_fwd_q}
create_generated_clock -name clk_slink_tx_out -combinational -source ${slink_fwd_q} \
    [get_ports slink_rcv_clk_o*]
# `clk_slow` also selects the DDR output multiplexers; it is a clock only up to them
set_sense -type clock -stop_propagation -clocks [get_clocks {clk_slink_tx_slow clk_slink_tx_fwd}] \
    [get_ports slink_o*]

# Uncertainty and transition (pre-CTS: ideal clocks); the virtual RX clock has
# no network to transition on. Setup uncertainty scales with the period, hold
# uncertainty does not: a fraction of the slow JTAG and USB periods (2 ns and
# 1 ns at 5%) would demand that much delay on every path they capture.
set chs_asic_clocks [list clk_sys ${TCK_SYS} clk_jtag ${TCK_JTAG} clk_usb ${TCK_USB} \
    clk_slink_rx ${TCK_SLINK} clk_slink_tx_slow ${TCK_SLINK} clk_slink_tx_fwd ${TCK_SLINK}]

# Setup uncertainty of every clock: CHS_ASIC_UNCERTAINTY as a fraction of its
# period, plus `margin` on paths within its domain only (an inter-clock
# uncertainty from the clock to itself), so the crossings' bounds keep their
# value. Synthesis applies CHS_ASIC_SYNTH_MARGIN; a flow sets 0 again before
# writing constraints for place and route.
proc chs_asic_set_setup_uncertainty { margin } {
    foreach {clk tck} $::chs_asic_clocks {
        set_clock_uncertainty -setup [chs_asic_frac $::CHS_ASIC_UNCERTAINTY ${tck}] [get_clocks ${clk}]
        set_clock_uncertainty -setup \
            [chs_asic_frac [expr { $::CHS_ASIC_UNCERTAINTY + ${margin} }] ${tck}] \
            -from [get_clocks ${clk}] -to [get_clocks ${clk}]
    }
}
chs_asic_set_setup_uncertainty ${CHS_ASIC_SYNTH_MARGIN}

foreach {clk tck} ${chs_asic_clocks} {
    set_clock_uncertainty -hold [chs_asic_t ${CHS_ASIC_HOLD_UNCERTAINTY}] [get_clocks ${clk}]
    set_clock_transition [chs_asic_t ${CHS_ASIC_CLK_TRANSITION}] [get_clocks ${clk}]
}

# All domains are asynchronous to each other. `-allow_paths` keeps paths between
# them timed, so a crossing without an explicit exception shows up as a
# violation instead of being silently ignored.
set_clock_groups -asynchronous -allow_paths -name chs_async \
    -group {clk_sys clk_slink_tx_slow clk_slink_tx_fwd clk_slink_tx_out} \
    -group {clk_jtag} \
    -group {clk_usb} \
    -group {clk_slink_rx clk_slink_rx_virt}

####################
# Static and reset #
####################

# Test mode is tied off in functional operation
set_case_analysis 0 [get_ports test_mode_i]

# Boot mode is fixed from reset on, but read by software through the register
# file without a register of its own: it is an on-chip input (see On-chip
# interfaces), as if a register of the system clock drove it.

# Resets: assertion is asynchronous; de-assertion must reach the registers of
# the respective domain within one of its cycles. Registers of another domain
# (e.g. the USB host controller's clock-crossing buffers, clocked by the USB
# clock but reset by `rst_ni`) see de-assertion as a crossing like any other,
# bounded in the CDC section: a period bound would also subtract the capturing
# clock's setup uncertainty (5% of its period, 1 ns for the USB clock).
foreach {port clk tck} [list rst_ni clk_sys ${TCK_SYS} usb_rst_ni clk_usb ${TCK_USB} \
    jtag_trst_ni clk_jtag ${TCK_JTAG}] {
    set_input_delay 0 -clock ${clk} [get_ports ${port}]
    set_false_path -fall_from [get_ports ${port}]
    set_false_path -hold -from [get_ports ${port}]
    set_max_delay -rise_from [get_ports ${port}] -to [get_clocks ${clk}] [chs_asic_t ${tck}]
}

######################
# On-chip interfaces #
######################

# Signals to and from other blocks of a chip on the system clock: the LLC's
# DRAM port (to a DRAM controller), the debug module's activity (e.g. to a
# power or clock controller) and the boot mode (e.g. from a configuration
# register). Both sides register them; see CHS_ASIC_ONCHIP_EXT_FRAC.
set onchip_in [get_ports {axi_llc_mst_rsp_i* boot_mode_i*}]
set onchip_out [get_ports {axi_llc_mst_req_o* dbg_active_o}]
set onchip_ext [chs_asic_frac ${CHS_ASIC_ONCHIP_EXT_FRAC} ${TCK_SYS}]
set_input_delay -max -clock clk_sys ${onchip_ext} ${onchip_in}
set_input_delay -min -clock clk_sys 0 ${onchip_in}
set_output_delay -max -clock clk_sys ${onchip_ext} ${onchip_out}
set_output_delay -min -clock clk_sys 0 ${onchip_out}

#########################
# Asynchronous chip I/O #
#########################

# Chip pins without a timing relationship to any clock here. The inputs go
# straight into a synchronizer: the RTC (into the CLINT), the UART's receive
# data and modem inputs, the GPIO inputs (GpioInputSyncs, checked in the
# wrapper), I2C's SCL and SDA (also sampled raw into the VAL history), the USB
# ports' D+ and D- (into the USB clock's synchronizers). The outputs come from
# registers: UART transmit data and modem outputs (through the loopback
# multiplexer), GPIO data and enables, I2C's open-drain enables (through the
# override multiplexer; its data outputs are constant 0). A constant delay does
# not matter to them (a UART receiver resynchronizes on every start bit; GPIO
# changes at register-write pace, writes apart) and no two of them need to be
# balanced: I2C's SCL-to-SDA timing is counted in system cycles (hundreds of ns
# of programmed setup and hold) against nanoseconds of on-chip skew. So there is
# no hold check and the delay is only capped, far below what they carry. The I/O
# delays are a reference for the caps, not a timing relationship.
set async_in [get_ports {rtc_i uart_rx_i uart_*_ni gpio_i* i2c_*_i usb_dm_i* usb_dp_i*}]
set async_out [get_ports {uart_tx_o uart_*_no gpio_o* gpio_en_o* i2c_*_o}]
set async_max [chs_asic_t ${CHS_ASIC_ASYNC_IO_MAX_DELAY}]
set_input_delay 0 -clock clk_sys ${async_in}
set_output_delay 0 -clock clk_sys ${async_out}
set_max_delay ${async_max} -from ${async_in}
set_max_delay ${async_max} -to ${async_out}
set_false_path -hold -from ${async_in}
set_false_path -hold -to ${async_out}

# VGA: no pixel clock leaves the chip; the monitor recovers it from the syncs
# and samples the color bits and syncs together near the middle of each pixel
# (clk_div system cycles). The outputs come from registers through the timing
# FSM's decode and the blanking multiplexer. No hold check; their delay, and so
# their skew, is capped well inside a pixel of the fastest mode supported.
set vga_out [get_ports vga_*]
set vga_max [chs_asic_t [expr { max(${CHS_ASIC_VGA_MAX_DELAY}, ${TCK_SYS} / 4.0) }]]
set_output_delay 0 -clock clk_sys ${vga_out}
set_max_delay ${vga_max} -to ${vga_out}
set_false_path -hold -to ${vga_out}

# SPI host: SCK (clk_sys / (2 (clkdiv + 1))) and the chip selects come from
# registers; the data outputs pass the standard/dual/quad multiplexer, whose
# select can follow a new command from the register bus combinationally (only
# when a command starts, the chip select lead time before the first SCK edge).
# A device samples data half an SCK period after it changes; read data returns
# through the device's clock-to-output and is sampled, without synchronizer, at
# the internal sampling edge. No hold check; the delay, and so the skew to SCK
# and the block's share of the read round trip, is capped.
set spi_in [get_ports spih_sd_i*]
set spi_out [get_ports spih_*_o*]
set spi_max [chs_asic_t [expr { max(${CHS_ASIC_SPI_MAX_DELAY}, ${TCK_SYS} / 4.0) }]]
set_input_delay 0 -clock clk_sys ${spi_in}
set_output_delay 0 -clock clk_sys ${spi_out}
set_max_delay ${spi_max} -from ${spi_in}
set_max_delay ${spi_max} -to ${spi_out}
set_false_path -hold -from ${spi_in}
set_false_path -hold -to ${spi_out}

########
# JTAG #
########

set jtag_in [get_ports {jtag_tdi_i jtag_tms_i}]
set jtag_out [get_ports {jtag_tdo_o jtag_tdo_oe_o}]
set_input_delay -min -clock clk_jtag [chs_asic_frac 0.10 ${TCK_JTAG}] ${jtag_in}
set_input_delay -max -clock clk_jtag [chs_asic_frac 0.50 ${TCK_JTAG}] ${jtag_in}
set_output_delay -min -clock clk_jtag [chs_asic_frac 0.05 ${TCK_JTAG}] ${jtag_out}
set_output_delay -max -clock clk_jtag [chs_asic_frac 0.25 ${TCK_JTAG}] ${jtag_out}

#######
# USB #
#######

# Full-speed USB (12 Mbit/s): a device sends with its own bit clock, which the
# PHY oversamples (48 MHz, USB clock); the inputs go straight into synchronizers
# and are asynchronous chip I/O (see there). The outputs come straight from
# registers of the USB clock; no clock leaves with them, the device recovers it
# from the transitions. Only D+ and D- of a port must switch together: no hold
# check; the delay, and so the pair skew, is capped. The reference clock is the
# system clock, as for the other asynchronous pins (the USB clock's 5% setup
# uncertainty, 1 ns, would leave nothing of the cap).
set usb_out [get_ports {usb_dm_o* usb_dp_o*}]   ;# also matches usb_d?_oe_o*
set_output_delay 0 -clock clk_sys ${usb_out}
set_max_delay [chs_asic_t ${CHS_ASIC_USB_MAX_DELAY}] -to ${usb_out}
set_false_path -hold -to ${usb_out}

###############
# Serial link #
###############

# DDR: only rise-to-fall and fall-to-rise transfers are real for setup, only
# rise-to-rise and fall-to-fall for hold
foreach {launch capture} {clk_slink_rx_virt clk_slink_rx clk_slink_tx_slow clk_slink_tx_out} {
    set launch [get_clocks ${launch}]
    set capture [get_clocks ${capture}]
    set_false_path -setup -rise_from ${launch} -rise_to ${capture}
    set_false_path -setup -fall_from ${launch} -fall_to ${capture}
    set_false_path -hold -rise_from ${launch} -fall_to ${capture}
    set_false_path -hold -fall_from ${launch} -rise_to ${capture}
}

# Data windows. Each data bit lasts half a period, and the clock edge that
# samples it comes in its middle: the data changes a quarter period (T/4)
# before and after the edge. Each chip may skew its pins' data against that
# ideal by S = CHS_ASIC_SLINK_SKEW_FRAC x T/4 either way. Receiver: data
# changes within +-S of the 0-degree virtual clock; the receiver keeps T/4 - S
# for its own skew. Transmitter: an external setup of T/4 - S and hold of
# T/4 - S against the forwarded clock at the pins, i.e. data within +-S of
# its ideal position, T/4 before the edge (pads and board are outside the
# block, as for all I/O). The forwarded clock register sits on the system
# clock tree, the data registers behind `clk_slow`, whose clock-to-output
# delays their data against the forwarded clock.
set slink_skew [expr { ${CHS_ASIC_SLINK_SKEW_FRAC} * ${TCK_SLINK} / 4 }]
set slink_ext [expr { ${TCK_SLINK} / 4 - ${slink_skew} }]
foreach edge {{} -clock_fall} {
    set_input_delay -add_delay -max {*}${edge} -clock clk_slink_rx_virt \
        [chs_asic_t ${slink_skew}] [get_ports slink_i*]
    set_input_delay -add_delay -min {*}${edge} -clock clk_slink_rx_virt \
        [chs_asic_t [expr { -${slink_skew} }]] [get_ports slink_i*]
    set_output_delay -add_delay -max {*}${edge} -clock clk_slink_tx_out \
        [chs_asic_t ${slink_ext}] [get_ports slink_o*]
    set_output_delay -add_delay -min {*}${edge} -clock clk_slink_tx_out \
        [chs_asic_t [expr { -${slink_ext} }]] [get_ports slink_o*]
}

# Both TX clock registers feed their own Q back to D, through the clock tree
# built on Q. OpenSTA times that feedback only from the generated clock (not
# as a system clock path), whose early source latency it takes from the fast
# corner even in the slow one, which shows as a hold violation. A
# register's own feedback cannot fail hold; setup stays timed.
set_false_path -hold -from [get_clocks clk_slink_tx_slow] -to [get_cells -of_objects ${slink_slow_q}]
set_false_path -hold -from [get_clocks clk_slink_tx_fwd] -to [get_cells -of_objects ${slink_fwd_q}]

################################
# Clock domain crossings (CDC) #
################################

# Domains meet in synchronizers and handshakes: the DMI (JTAG), the USB host
# controller (USB), and the serial link RX FIFO (serial link RX). Bound all
# paths between each domain and the system clock, in both directions, selected
# by clock pair: complete whatever the cells are called, the same on
# hierarchical and flat netlists and in every tool, unlike name patterns (the
# IPs name their synchronizers differently; none of the crossing registers
# matches *async*). The minimum delay offsets the capturing clock's hold
# uncertainty, so the hold requirement of a crossing is zero.
set cdc_min [chs_asic_t [expr { -${CHS_ASIC_HOLD_UNCERTAINTY} }]]
foreach {clk frac} [list clk_jtag ${CHS_ASIC_CDC_JTAG_FRAC} clk_usb ${CHS_ASIC_CDC_FRAC} \
    clk_slink_rx ${CHS_ASIC_CDC_FRAC}] {
    set cdc_max [chs_asic_frac ${frac} ${TCK_SYS}]
    foreach {from to} [list clk_sys ${clk} ${clk} clk_sys] {
        set_max_delay ${cdc_max} -from [get_clocks ${from}] -to [get_clocks ${to}] \
            -ignore_clock_latency
        set_min_delay ${cdc_min} -from [get_clocks ${from}] -to [get_clocks ${to}] \
            -ignore_clock_latency
    }
}
