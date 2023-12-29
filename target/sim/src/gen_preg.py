#!/usr/bin/env python3

# for i in range(96):
#     print("assign preg_value[%d] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg%d_reg_dout;" % (i, i))

for i in range(32):
    print("assign areg_preg_idx[%d] = dut.gen_cva6_cores[0].gen_c910_core.i_c910_axi_wrap.cpu_sub_system_axi_i.x_rv_integration_platform.x_cpu_top.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_rt.x_ct_idu_ir_rt_entry_reg_%d.preg;"%(i,i))
