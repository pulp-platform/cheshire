# Copyright 2020 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

set jtag_gnd_o [ create_bd_port -dir O jtag_gnd_o ]
set jtag_tck_i [ create_bd_port -dir I jtag_tck_i ]
set jtag_tdi_i [ create_bd_port -dir I jtag_tdi_i ]
set jtag_tdo_o [ create_bd_port -dir O jtag_tdo_o ]
set jtag_tms_i [ create_bd_port -dir I jtag_tms_i ]
set jtag_vdd_o [ create_bd_port -dir O jtag_vdd_o ]
connect_bd_net -net cheshire_xilinx_ip_0_jtag_gnd_o [get_bd_ports jtag_gnd_o] [get_bd_pins cheshire_xilinx_ip_0/jtag_gnd_o]
connect_bd_net -net cheshire_xilinx_ip_0_jtag_tdo_o [get_bd_ports jtag_tdo_o] [get_bd_pins cheshire_xilinx_ip_0/jtag_tdo_o]
connect_bd_net -net cheshire_xilinx_ip_0_jtag_vdd_o [get_bd_ports jtag_vdd_o] [get_bd_pins cheshire_xilinx_ip_0/jtag_vdd_o]
connect_bd_net -net jtag_tck_i_1 [get_bd_ports jtag_tck_i] [get_bd_pins cheshire_xilinx_ip_0/jtag_tck_i]
connect_bd_net -net jtag_tdi_i_1 [get_bd_ports jtag_tdi_i] [get_bd_pins cheshire_xilinx_ip_0/jtag_tdi_i]
connect_bd_net -net jtag_tms_i_1 [get_bd_ports jtag_tms_i] [get_bd_pins cheshire_xilinx_ip_0/jtag_tms_i]
