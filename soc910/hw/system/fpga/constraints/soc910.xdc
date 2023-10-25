## Common soc910 XDCs

# 5 MHz max JTAG
create_clock -period 200 -name tck -waveform {0.000 50.000} [get_ports tck]

# GPIO is not a valid clock source
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tck_IBUF_inst/O]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_pins tck_IBUF_inst/O]]

set_input_jitter tck 1.000

# JTAG clock is asynchronous with every other clocks.
set_clock_groups -asynchronous -group [get_clocks tck]

# minimize routing delay
set_input_delay  -clock tck -clock_fall 5 [get_ports tdi    ]
set_input_delay  -clock tck -clock_fall 5 [get_ports tms    ]
set_output_delay -clock tck             5 [get_ports tdo    ]
# set_false_path   -from                    [get_ports trst_n ] 

set_max_delay -to   [get_ports { tdo }] 50
set_max_delay -from [get_ports { tms }] 50
set_max_delay -from [get_ports { tdi }] 50

# set multicycle path on reset, on the FPGA we do not care about the reset anyway
set_multicycle_path -from [get_pins i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg[3]/C] 4
set_multicycle_path -from [get_pins i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg[3]/C] 3  -hold
