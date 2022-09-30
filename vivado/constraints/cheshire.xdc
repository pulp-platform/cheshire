# Standard 200 MHz differential clock for Genesys 2 FPGA
create_clock -add -name sys_clk_pin -period 5.00 [get_ports sysclk_p]

# 50 MHz system Clock
create_generated_clock -name soc_clk -divide_by 4 -source [get_pins i_sys_clk_div/CLK] [get_pins i_sys_clk_div/clk_o]

# Avoid BUFG->BUFG problems
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_sys_clk_div/i_clk_mux/generated_clock]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_cheshire_soc/i_axi_vga/i_pixel_clk_div/i_clk_mux/generated_clock]
#set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets i_dram/u_xlnx_mig_7_ddr3_mig/u_ddr3_clk_ibuf/sys_clk_ibufg]

# 10 MHz clock for JTAG
create_clock -add -name jtag_clk -period 100.00 [get_ports jtag_tck_i]

set_input_jitter jtag_clk 1.000

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

# rst_n used for both 200 MHz and 50 MHz clock => maximum delay based on minimal clock frequency
set_max_delay -from [get_pins i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg\[3\]/Q] [expr 0.7*5]
