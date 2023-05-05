
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu37p-fsvh2892-2L-e
   set_property BOARD_PART xilinx.com:vcu128:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:axi_ethernet:7.2\
ethz.ch:user:cheshire_xilinx_ip:1.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:ddr4:2.2\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:vio:3.0\
xilinx.com:ip:xdma:4.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set ddr4_sdram [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 ddr4_sdram ]

  set mdio_mdc [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_mdc ]

  set pci_express_x4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pci_express_x4 ]

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $pcie_refclk

  set sgmii_lvds [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_lvds ]

  set sgmii_phyclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sgmii_phyclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {625000000} \
   ] $sgmii_phyclk

  set sys_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $sys_clk


  # Create ports
  set dummy_port_in [ create_bd_port -dir I -type rst dummy_port_in ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $dummy_port_in
  set pcie_perstn [ create_bd_port -dir I -type rst pcie_perstn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pcie_perstn
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset
  set uart_rx_i [ create_bd_port -dir I uart_rx_i ]
  set uart_tx_o [ create_bd_port -dir O uart_tx_o ]

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_addr_width {64} \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_sg_length_width {16} \
   CONFIG.c_sg_use_stsapp_length {1} \
 ] $axi_dma_0

  # Create instance: axi_ethernet_0, and set properties
  set axi_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.2 axi_ethernet_0 ]
  set_property -dict [ list \
   CONFIG.DIFFCLK_BOARD_INTERFACE {sgmii_phyclk} \
   CONFIG.ENABLE_LVDS {true} \
   CONFIG.ETHERNET_BOARD_INTERFACE {sgmii_lvds} \
   CONFIG.InstantiateBitslice0 {true} \
   CONFIG.MDIO_BOARD_INTERFACE {mdio_mdc} \
   CONFIG.PHYADDR {0} \
   CONFIG.PHYRST_BOARD_INTERFACE {Custom} \
   CONFIG.PHYRST_BOARD_INTERFACE_DUMMY_PORT {dummy_port_in} \
   CONFIG.PHY_TYPE {SGMII} \
   CONFIG.RXCSUM {Full} \
   CONFIG.TXCSUM {Full} \
   CONFIG.lvdsclkrate {625} \
   CONFIG.rxlane0_placement {DIFF_PAIR_2} \
   CONFIG.rxnibblebitslice0used {false} \
   CONFIG.txlane0_placement {DIFF_PAIR_1} \
 ] $axi_ethernet_0

  # Create instance: cheshire_xilinx_ip_0, and set properties
  set cheshire_xilinx_ip_0 [ create_bd_cell -type ip -vlnv ethz.ch:user:cheshire_xilinx_ip:1.0 cheshire_xilinx_ip_0 ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {188.586} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {10.000} \
   CONFIG.CLKOUT1_USED {true} \
   CONFIG.CLKOUT2_JITTER {162.167} \
   CONFIG.CLKOUT2_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {20.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {132.683} \
   CONFIG.CLKOUT3_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {50.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_JITTER {115.831} \
   CONFIG.CLKOUT4_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {Custom} \
   CONFIG.CLK_OUT1_PORT {clk_10} \
   CONFIG.CLK_OUT2_PORT {clk_20} \
   CONFIG.CLK_OUT3_PORT {clk_50} \
   CONFIG.CLK_OUT4_PORT {clk_100} \
   CONFIG.ENABLE_CLOCK_MONITOR {false} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {120.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {60} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {24} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {12} \
   CONFIG.NUM_OUT_CLKS {4} \
   CONFIG.PRIMITIVE {MMCM} \
   CONFIG.PRIM_SOURCE {No_buffer} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.USE_BOARD_FLOW {true} \
   CONFIG.USE_LOCKED {true} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: concat_irq, and set properties
  set concat_irq [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_irq ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {12} \
 ] $concat_irq

  # Create instance: ddr4_0, and set properties
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]
  set_property -dict [ list \
   CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {None} \
   CONFIG.C0_CLOCK_BOARD_INTERFACE {Custom} \
   CONFIG.C0_DDR4_BOARD_INTERFACE {ddr4_sdram} \
   CONFIG.System_Clock {No_Buffer} \
 ] $ddr4_0

  # Create instance: low, and set properties
  set low [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 low ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $low

  # Create instance: psr_10, and set properties
  set psr_10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 psr_10 ]
  set_property -dict [ list \
   CONFIG.C_AUX_RESET_HIGH {1} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $psr_10

  # Create instance: psr_333, and set properties
  set psr_333 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 psr_333 ]
  set_property -dict [ list \
   CONFIG.C_AUX_RESET_HIGH {1} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
 ] $psr_333

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
 ] $smartconnect_0

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0 ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDS} \
   CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {Custom} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $util_ds_buf_0

  # Create instance: util_ds_buf_1, and set properties
  set util_ds_buf_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_1 ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
   CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {pcie_refclk} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $util_ds_buf_1

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $util_vector_logic_0

  # Create instance: vio_0, and set properties
  set vio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_0 ]
  set_property -dict [ list \
   CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
   CONFIG.C_NUM_PROBE_IN {0} \
   CONFIG.C_NUM_PROBE_OUT {3} \
   CONFIG.C_PROBE_OUT0_INIT_VAL {0x2} \
   CONFIG.C_PROBE_OUT0_WIDTH {2} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {0x2} \
   CONFIG.C_PROBE_OUT1_WIDTH {2} \
 ] $vio_0

  # Create instance: xbar_dram, and set properties
  set xbar_dram [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 xbar_dram ]
  set_property -dict [ list \
   CONFIG.HAS_ARESETN {1} \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $xbar_dram

  # Create instance: xbar_periph_in, and set properties
  set xbar_periph_in [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 xbar_periph_in ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {1} \
   CONFIG.NUM_SI {4} \
 ] $xbar_periph_in

  # Create instance: xbar_periph_out, and set properties
  set xbar_periph_out [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 xbar_periph_out ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {3} \
   CONFIG.NUM_MI {3} \
   CONFIG.NUM_SI {1} \
 ] $xbar_periph_out

  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [ list \
   CONFIG.PCIE_BOARD_INTERFACE {pci_express_x4} \
   CONFIG.PF0_DEVICE_ID_mqdma {9014} \
   CONFIG.PF2_DEVICE_ID_mqdma {9014} \
   CONFIG.PF3_DEVICE_ID_mqdma {9014} \
   CONFIG.SYS_RST_N_BOARD_INTERFACE {pcie_perstn} \
   CONFIG.axi_addr_width {64} \
   CONFIG.axi_bypass_64bit_en {true} \
   CONFIG.axi_bypass_prefetchable {true} \
   CONFIG.axist_bypass_en {true} \
   CONFIG.axist_bypass_scale {Gigabytes} \
   CONFIG.axist_bypass_size {4} \
   CONFIG.axisten_freq {125} \
   CONFIG.functional_mode {DMA} \
   CONFIG.pf0_device_id {9014} \
   CONFIG.pl_link_cap_max_link_width {X4} \
   CONFIG.xdma_axi_intf_mm {AXI_Memory_Mapped} \
   CONFIG.xdma_axilite_slave {false} \
 ] $xdma_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_CNTRL [get_bd_intf_pins axi_dma_0/M_AXIS_CNTRL] [get_bd_intf_pins axi_ethernet_0/s_axis_txc]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins axi_ethernet_0/s_axis_txd]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins xbar_periph_in/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins xbar_periph_in/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma_0/M_AXI_SG] [get_bd_intf_pins xbar_periph_in/S00_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxd [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins axi_ethernet_0/m_axis_rxd]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxs [get_bd_intf_pins axi_dma_0/S_AXIS_STS] [get_bd_intf_pins axi_ethernet_0/m_axis_rxs]
  connect_bd_intf_net -intf_net axi_ethernet_0_mdio [get_bd_intf_ports mdio_mdc] [get_bd_intf_pins axi_ethernet_0/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_0_sgmii [get_bd_intf_ports sgmii_lvds] [get_bd_intf_pins axi_ethernet_0/sgmii]
  connect_bd_intf_net -intf_net cheshire_xilinx_ip_0_dram_axi [get_bd_intf_pins cheshire_xilinx_ip_0/dram_axi] [get_bd_intf_pins xbar_dram/S00_AXI]
  connect_bd_intf_net -intf_net cheshire_xilinx_ip_0_periph_axi_m [get_bd_intf_pins cheshire_xilinx_ip_0/periph_axi_m] [get_bd_intf_pins xbar_periph_out/S00_AXI]
  connect_bd_intf_net -intf_net ddr4_0_C0_DDR4 [get_bd_intf_ports ddr4_sdram] [get_bd_intf_pins ddr4_0/C0_DDR4]
  connect_bd_intf_net -intf_net diff_clock_rtl_1 [get_bd_intf_ports sys_clk] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins util_ds_buf_1/CLK_IN_D]
  connect_bd_intf_net -intf_net sgmii_phyclk_1 [get_bd_intf_ports sgmii_phyclk] [get_bd_intf_pins axi_ethernet_0/lvds_clk]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI] [get_bd_intf_pins xbar_dram/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI1 [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins xbar_periph_in/S03_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins axi_ethernet_0/s_axi] [get_bd_intf_pins xbar_periph_out/M00_AXI]
  connect_bd_intf_net -intf_net xbar_periph_in_M00_AXI [get_bd_intf_pins cheshire_xilinx_ip_0/periph_axi_s] [get_bd_intf_pins xbar_periph_in/M00_AXI]
  connect_bd_intf_net -intf_net xbar_periph_out_M01_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins xbar_periph_out/M01_AXI]
  connect_bd_intf_net -intf_net xbar_periph_out_M02_AXI [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI_CTRL] [get_bd_intf_pins xbar_periph_out/M02_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins xdma_0/M_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_BYPASS [get_bd_intf_pins smartconnect_0/S01_AXI] [get_bd_intf_pins xdma_0/M_AXI_BYPASS]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pci_express_x4] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net axi_dma_0_mm2s_cntrl_reset_out_n [get_bd_pins axi_dma_0/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txc_arstn]
  connect_bd_net -net axi_dma_0_mm2s_introut [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins concat_irq/In2]
  connect_bd_net -net axi_dma_0_mm2s_prmry_reset_out_n [get_bd_pins axi_dma_0/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txd_arstn]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins concat_irq/In3]
  connect_bd_net -net axi_dma_0_s2mm_prmry_reset_out_n [get_bd_pins axi_dma_0/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxd_arstn]
  connect_bd_net -net axi_dma_0_s2mm_sts_reset_out_n [get_bd_pins axi_dma_0/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxs_arstn]
  connect_bd_net -net axi_ethernet_0_interrupt [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins concat_irq/In0]
  connect_bd_net -net axi_ethernet_0_mac_irq [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins concat_irq/In5]
  connect_bd_net -net cheshire_xilinx_ip_0_dram_axi_m_aclk [get_bd_pins cheshire_xilinx_ip_0/dram_axi_m_aclk] [get_bd_pins xbar_dram/aclk]
  connect_bd_net -net cheshire_xilinx_ip_0_periph_axi_m_aclk [get_bd_pins cheshire_xilinx_ip_0/periph_axi_m_aclk] [get_bd_pins xbar_periph_out/aclk]
  connect_bd_net -net cheshire_xilinx_ip_0_uart_tx_o [get_bd_ports uart_tx_o] [get_bd_pins cheshire_xilinx_ip_0/uart_tx_o]
  connect_bd_net -net clk_wiz_0_clk_10 [get_bd_pins cheshire_xilinx_ip_0/clk_10] [get_bd_pins clk_wiz_0/clk_10] [get_bd_pins psr_10/slowest_sync_clk]
  connect_bd_net -net clk_wiz_0_clk_20 [get_bd_pins cheshire_xilinx_ip_0/clk_20] [get_bd_pins clk_wiz_0/clk_20]
  connect_bd_net -net clk_wiz_0_clk_50 [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/m_axi_sg_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins axi_ethernet_0/s_axi_lite_clk] [get_bd_pins cheshire_xilinx_ip_0/clk_50] [get_bd_pins clk_wiz_0/clk_50] [get_bd_pins smartconnect_0/aclk1] [get_bd_pins vio_0/clk] [get_bd_pins xbar_periph_in/aclk] [get_bd_pins xbar_periph_out/aclk1]
  connect_bd_net -net clk_wiz_0_clk_100 [get_bd_pins cheshire_xilinx_ip_0/clk_100] [get_bd_pins clk_wiz_0/clk_100]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins psr_10/dcm_locked]
  connect_bd_net -net concat_irq_dout [get_bd_pins cheshire_xilinx_ip_0/gpio_i] [get_bd_pins concat_irq/dout]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins psr_333/slowest_sync_clk] [get_bd_pins xbar_dram/aclk1] [get_bd_pins xbar_periph_out/aclk2]
  connect_bd_net -net dummy_port_in_1 [get_bd_ports dummy_port_in] [get_bd_pins axi_ethernet_0/dummy_port_in]
  connect_bd_net -net low_dout [get_bd_pins cheshire_xilinx_ip_0/testmode_i] [get_bd_pins low/dout]
  connect_bd_net -net pcie_perstn_1 [get_bd_ports pcie_perstn] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net psr_10_interconnect_aresetn [get_bd_pins psr_10/interconnect_aresetn] [get_bd_pins xbar_dram/aresetn] [get_bd_pins xbar_periph_in/aresetn] [get_bd_pins xbar_periph_out/aresetn]
  connect_bd_net -net psr_10_peripheral_aresetn [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] [get_bd_pins psr_10/peripheral_aresetn]
  connect_bd_net -net psr_333_peripheral_aresetn [get_bd_pins ddr4_0/c0_ddr4_aresetn] [get_bd_pins psr_333/peripheral_aresetn]
  connect_bd_net -net psr_333_peripheral_reset [get_bd_pins ddr4_0/sys_rst] [get_bd_pins psr_333/peripheral_reset]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins psr_10/ext_reset_in] [get_bd_pins psr_333/ext_reset_in] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net uart_rx_i_1 [get_bd_ports uart_rx_i] [get_bd_pins cheshire_xilinx_ip_0/uart_rx_i]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins ddr4_0/c0_sys_clk_i] [get_bd_pins util_ds_buf_0/IBUF_OUT]
  connect_bd_net -net util_ds_buf_1_IBUF_DS_ODIV2 [get_bd_pins util_ds_buf_1/IBUF_DS_ODIV2] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net util_ds_buf_1_IBUF_OUT [get_bd_pins util_ds_buf_1/IBUF_OUT] [get_bd_pins xdma_0/sys_clk_gt]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins cheshire_xilinx_ip_0/cpu_reset] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net vio_0_probe_out0 [get_bd_pins cheshire_xilinx_ip_0/boot_mode_i] [get_bd_pins vio_0/probe_out0]
  connect_bd_net -net vio_0_probe_out2 [get_bd_pins util_vector_logic_0/Op2] [get_bd_pins vio_0/probe_out2]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins smartconnect_0/aclk] [get_bd_pins xdma_0/axi_aclk]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x0001000000000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs cheshire_xilinx_ip_0/periph_axi_s/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x0001000000000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs cheshire_xilinx_ip_0/periph_axi_s/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x0001000000000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs cheshire_xilinx_ip_0/periph_axi_s/reg0] -force
  assign_bd_address -offset 0x41E00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cheshire_xilinx_ip_0/periph_axi_m] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x40C00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cheshire_xilinx_ip_0/periph_axi_m] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces cheshire_xilinx_ip_0/dram_axi] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x00000000 -range 0x0001000000000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs cheshire_xilinx_ip_0/periph_axi_s/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x0001000000000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_BYPASS] [get_bd_addr_segs cheshire_xilinx_ip_0/periph_axi_s/reg0] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0x80000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces cheshire_xilinx_ip_0/periph_axi_m] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP_CTRL/C0_REG]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


