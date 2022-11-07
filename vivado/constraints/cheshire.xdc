# Standard 200 MHz differential clock for Genesys 2 FPGA
create_clock -add -name sys_clk_pin -period 5.00 [get_ports sysclk_p]

# 50 MHz system Clock
create_generated_clock -name soc_clk -divide_by 4 -source [get_pins i_sys_clk_div/t_ff1_q_reg/C] [get_pins i_sys_clk_div/t_ff1_q_reg/Q]

# 10 MHz clock for JTAG
create_clock -add -name jtag_clk -period 100.00 [get_ports jtag_tck_i]

set_input_jitter jtag_clk 1.000

# 25 MHz clock for SPI
create_generated_clock -name spi_clk -divide_by 2 -source [get_pins i_sys_clk_div/t_ff1_q_reg/Q] [get_pins i_cheshire_soc/i_spi_host/u_spi_core/u_fsm/gen_csb_gen[0].sck_q_reg/Q]

# JTAG Clock is asynchronous to all other clocks
set_clock_groups -name jtag_async -asynchronous -group [get_clocks jtag_clk]

# Accept suboptimal BUFG-BUFG cascades
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_sys_clk_div/i_clk_mux/generated_clock]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_cheshire_soc/i_axi_vga/i_pixel_clk_div/i_clk_mux/generated_clock]

# Set conservative input/output delays for SPI
set_input_delay  -clock soc_clk 10 [get_ports sd_d_io*]
set_output_delay -clock spi_clk 10 [get_ports {sd_d_io* sd_cmd_o}]

# minimize routing delay
set_input_delay  -clock jtag_clk -clock_fall 5 [get_ports jtag_tdi_i    ]
set_input_delay  -clock jtag_clk -clock_fall 5 [get_ports jtag_tms_i    ]
set_output_delay -clock jtag_clk             5 [get_ports jtag_tdo_o    ]
set_false_path   -from                         [get_ports jtag_trst_ni  ]

set_max_delay -to   [get_ports { jtag_tdo_o }] 20
set_max_delay -from [get_ports { jtag_tms_i }] 20
set_max_delay -from [get_ports { jtag_tdi_i }] 20
set_max_delay -from [get_ports { jtag_trst_ni}] 20

set_false_path -from [get_pins i_dram/u_xlnx_mig_7_ddr3_mig/u_ddr3_infrastructure/rstdiv0_sync_r1_reg_rep/C]

# Constrain clock domain crossings
# cdc_fifo_gray
set async_pins [get_pins "i_axi_cdc_mig/*/*async*"]
set_max_delay -through ${async_pins} -through ${async_pins} 4.6

# rst comes from MIG => Is already synchronous to 200 MHz -> Only need to enforce synch to soc_clk
set_max_delay -from [get_pins i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg\[3\]/C] [expr 0.7*20]
