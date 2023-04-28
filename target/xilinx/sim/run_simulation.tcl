
#source ips/xlnx_mig_ddr4/questa/compile.do
#source ips/xlnx_sim_clk_gen/questa/compile.do
source ../scripts/add_sources_vsim.tcl
#
#vopt -64 +acc=npr -l elaborate.log -L xpm -L microblaze_v11_0_4 -L xil_defaultlib -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_13 \
#  -L lmb_v10_v3_0_11 -L lmb_bram_if_cntlr_v4_0_19 -L blk_mem_gen_v8_4_4 -L iomodule_v3_1_6 -L unisims_ver -L unimacro_ver \
#  -L secureip -work work work.tb_cheshire_top_xilinx xil_defaultlib.glbl -o xlnx_mig_ddr4_opt

# vsim -L xpm -L microblaze_v11_0_4 -L xil_defaultlib -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_13 -L lmb_v10_v3_0_11 -L lmb_bram_if_cntlr_v4_0_19 -L blk_mem_gen_v8_4_4 -L iomodule_v3_1_6 -L unisims_ver -L unimacro_ver -L secureip -work xil_defaultlib xil_defaultlib.xlnx_mig_ddr4 xil_defaultlib.glbl

# set VOPTARGS "-O5 +acc=p+tb_cheshire_soc. +noacc=p+cheshire_soc. +acc=r+stream_xbar"

# vsim -c tb_cheshire_soc -t 1ps -vopt -voptargs=\"${VOPTARGS}\" -L microblaze_v11_0_4