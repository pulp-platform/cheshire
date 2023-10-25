log -r *
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_apb_regs/i_apb_regs_dut/pclk_i
add wave -noupdate /tb_apb_regs/i_apb_regs_dut/preset_ni
add wave -noupdate /tb_apb_regs/i_apb_regs_dut/base_addr_i
add wave -noupdate -expand /tb_apb_regs/i_apb_regs_dut/apb_req
add wave -noupdate -expand /tb_apb_regs/i_apb_regs_dut/apb_resp
add wave -noupdate /tb_apb_regs/i_apb_regs_dut/base_addr_i
add wave -noupdate /tb_apb_regs/i_apb_regs_dut/reg_init_i
add wave -noupdate /tb_apb_regs/i_apb_regs_dut/reg_q_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 310
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {20648 ns}
