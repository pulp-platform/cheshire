for {set i 0} {$i < 32} {incr i} {
    # eval "add wave -position insertpoint {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/gen_c910_core/i_c910_axi_wrap/cpu_sub_system_axi_i/x_rv_integration_platform/x_cpu_top/x_ct_top_0/x_ct_core/x_ct_idu_top/x_ct_idu_ir_rt/x_ct_idu_ir_rt_entry_reg_$i/preg}"
    eval "add wave -position insertpoint {sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/gen_c910_core/i_c910_axi_wrap/cpu_sub_system_axi_i/x_rv_integration_platform/x_cpu_top/x_ct_top_0/x_ct_core/x_ct_rtu_top/x_ct_rtu_pst_preg/r${i}_preg_expand}"
}