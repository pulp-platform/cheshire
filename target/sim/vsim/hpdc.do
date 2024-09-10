onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {CVA6 NoC ports}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/noc_req_o}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/noc_resp_i}
add wave -noupdate -divider {CVA6 R channel}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/noc_resp_i.r}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/noc_resp_i.r_valid}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/noc_req_o.r_ready}
add wave -noupdate -divider {CVA6 W channel}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/noc_req_o.w}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/noc_req_o.w_valid}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/noc_resp_i.w_ready}
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {HPDCache core inputs}
add wave -noupdate -expand {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/core_req_valid_i}
add wave -noupdate -expand {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/core_req_ready_o}
add wave -noupdate -subitemconfig {{/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/core_req_i[1]} -expand} {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/core_req_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/core_req_abort_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/core_req_tag_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/core_req_pma_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/core_rsp_valid_o}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/core_rsp_o}
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {HPDCache control PE}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/core_req_valid_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/core_req_ready_o}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/rtab_req_valid_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/rtab_req_ready_o}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/refill_req_valid_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/refill_req_ready_o}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/inval_req_valid_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/inval_req_ready_o}
add wave -noupdate -divider <NULL>
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/refill_busy_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/rtab_full_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/cmo_busy_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/uc_busy_i}
add wave -noupdate -divider <NULL>
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/evt_read_req_o}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/evt_prefetch_req_o}
add wave -noupdate -divider <NULL>
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/evt_stall_refill_o}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_hpd/i_cache_subsystem/i_hpdcache/hpdcache_ctrl_i/hpdcache_ctrl_pe_i/evt_stall_o}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {1986284621 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 233
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1986037301 ps} {1986709258 ps}
