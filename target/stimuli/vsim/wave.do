onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cheshire_soc/fix/dut/clk_i
add wave -noupdate /tb_cheshire_soc/fix/dut/rst_ni
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/boot_addr_i}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/hart_id_i}
add wave -noupdate /tb_cheshire_soc/fix/dut/xeip
add wave -noupdate /tb_cheshire_soc/fix/dut/msip
add wave -noupdate /tb_cheshire_soc/fix/dut/mtip
add wave -noupdate /tb_cheshire_soc/fix/dut/dbg_int_req
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/clic_irq_valid}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/clic_irq_id}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/clic_irq_level}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/clic_irq_priv}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/clic_irq_shv}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/clic_irq_ready}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/clic_irq_kill_req}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/clic_irq_kill_ack}
add wave -noupdate -expand {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/core_out_req}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/core_out_rsp}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/commit_ack}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/pc_commit}
add wave -noupdate {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/csr_regfile_i/mcause_q}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {226845000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 166
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {664651759 ps}
