onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi_riscv_lrsc_tb/dut/i_lrsc/clk_i
add wave -noupdate /axi_riscv_lrsc_tb/dut/i_lrsc/rst_ni
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_valid
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_ready
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_id
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_addr
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_len
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_size
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_burst
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_lock
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_cache
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_prot
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_qos
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_region
add wave -noupdate -expand -group upstream -group upstream/ar /axi_riscv_lrsc_tb/upstream/ar_user
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_valid
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_ready
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_addr
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_id
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_len
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_size
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_burst
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_lock
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_cache
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_prot
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_qos
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_region
add wave -noupdate -expand -group upstream -expand -group upstream/aw /axi_riscv_lrsc_tb/upstream/aw_user
add wave -noupdate -expand -group upstream -group upstream/r /axi_riscv_lrsc_tb/upstream/r_valid
add wave -noupdate -expand -group upstream -group upstream/r /axi_riscv_lrsc_tb/upstream/r_ready
add wave -noupdate -expand -group upstream -group upstream/r /axi_riscv_lrsc_tb/upstream/r_id
add wave -noupdate -expand -group upstream -group upstream/r /axi_riscv_lrsc_tb/upstream/r_data
add wave -noupdate -expand -group upstream -group upstream/r /axi_riscv_lrsc_tb/upstream/r_resp
add wave -noupdate -expand -group upstream -group upstream/r /axi_riscv_lrsc_tb/upstream/r_last
add wave -noupdate -expand -group upstream -group upstream/r /axi_riscv_lrsc_tb/upstream/r_user
add wave -noupdate -expand -group upstream -expand -group upstream/w /axi_riscv_lrsc_tb/upstream/w_valid
add wave -noupdate -expand -group upstream -expand -group upstream/w /axi_riscv_lrsc_tb/upstream/w_ready
add wave -noupdate -expand -group upstream -expand -group upstream/w /axi_riscv_lrsc_tb/upstream/w_data
add wave -noupdate -expand -group upstream -expand -group upstream/w /axi_riscv_lrsc_tb/upstream/w_strb
add wave -noupdate -expand -group upstream -expand -group upstream/w /axi_riscv_lrsc_tb/upstream/w_last
add wave -noupdate -expand -group upstream -expand -group upstream/w /axi_riscv_lrsc_tb/upstream/w_user
add wave -noupdate -expand -group upstream -expand -group upstream/b /axi_riscv_lrsc_tb/upstream/b_valid
add wave -noupdate -expand -group upstream -expand -group upstream/b /axi_riscv_lrsc_tb/upstream/b_ready
add wave -noupdate -expand -group upstream -expand -group upstream/b /axi_riscv_lrsc_tb/upstream/b_id
add wave -noupdate -expand -group upstream -expand -group upstream/b /axi_riscv_lrsc_tb/upstream/b_resp
add wave -noupdate -expand -group upstream -expand -group upstream/b /axi_riscv_lrsc_tb/upstream/b_user
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/art_set_req
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/art_set_gnt
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/slv_b
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/slv_b_valid
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/slv_b_ready
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/w_cmd_inp
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/w_cmd_oup
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/w_cmd_push
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/w_cmd_pop
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/w_cmd_full
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/w_cmd_empty
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_inj_inp
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_inj_oup
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_inj_push
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_inj_pop
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_inj_full
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_inj_empty
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_inp_id
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_inp_cmd
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_inp_req
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_inp_gnt
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_oup_id
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_oup_cmd
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_oup_valid
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_oup_pop
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_oup_req
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_status_oup_gnt
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/art_check_res
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/ar_state_q
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/aw_state_q
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/b_state_q
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/art_check_clr_addr
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/art_check_clr_gnt
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/art_check_clr_req
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/art_check_id
add wave -noupdate -expand -group dut /axi_riscv_lrsc_tb/dut/i_lrsc/art_check_res
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_valid
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_ready
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_id
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_addr
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_len
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_size
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_burst
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_lock
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_cache
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_prot
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_qos
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_region
add wave -noupdate -expand -group downstream -group downstream/ar /axi_riscv_lrsc_tb/downstream/ar_user
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_valid
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_ready
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_addr
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_id
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_len
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_size
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_burst
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_lock
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_cache
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_prot
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_qos
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_region
add wave -noupdate -expand -group downstream -expand -group downstream/aw /axi_riscv_lrsc_tb/downstream/aw_user
add wave -noupdate -expand -group downstream -group downstream/r /axi_riscv_lrsc_tb/downstream/r_valid
add wave -noupdate -expand -group downstream -group downstream/r /axi_riscv_lrsc_tb/downstream/r_ready
add wave -noupdate -expand -group downstream -group downstream/r /axi_riscv_lrsc_tb/downstream/r_id
add wave -noupdate -expand -group downstream -group downstream/r /axi_riscv_lrsc_tb/downstream/r_data
add wave -noupdate -expand -group downstream -group downstream/r /axi_riscv_lrsc_tb/downstream/r_resp
add wave -noupdate -expand -group downstream -group downstream/r /axi_riscv_lrsc_tb/downstream/r_last
add wave -noupdate -expand -group downstream -group downstream/r /axi_riscv_lrsc_tb/downstream/r_user
add wave -noupdate -expand -group downstream -group downstream/w /axi_riscv_lrsc_tb/downstream/w_valid
add wave -noupdate -expand -group downstream -group downstream/w /axi_riscv_lrsc_tb/downstream/w_ready
add wave -noupdate -expand -group downstream -group downstream/w /axi_riscv_lrsc_tb/downstream/w_data
add wave -noupdate -expand -group downstream -group downstream/w /axi_riscv_lrsc_tb/downstream/w_strb
add wave -noupdate -expand -group downstream -group downstream/w /axi_riscv_lrsc_tb/downstream/w_last
add wave -noupdate -expand -group downstream -group downstream/w /axi_riscv_lrsc_tb/downstream/w_user
add wave -noupdate -expand -group downstream -expand -group downstream/b /axi_riscv_lrsc_tb/downstream/b_valid
add wave -noupdate -expand -group downstream -expand -group downstream/b /axi_riscv_lrsc_tb/downstream/b_ready
add wave -noupdate -expand -group downstream -expand -group downstream/b /axi_riscv_lrsc_tb/downstream/b_id
add wave -noupdate -expand -group downstream -expand -group downstream/b /axi_riscv_lrsc_tb/downstream/b_resp
add wave -noupdate -expand -group downstream -expand -group downstream/b /axi_riscv_lrsc_tb/downstream/b_user
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/inp_id_i
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/inp_data_i
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/inp_req_i
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/inp_gnt_o
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/oup_id_i
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/oup_pop_i
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/oup_req_i
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/oup_data_o
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/oup_data_valid_o
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/oup_gnt_o
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/head_tail_d
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/head_tail_q
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/linked_data_d
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/linked_data_q
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/full
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/no_id_match
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/head_tail_free
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/idx_matches_id
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/linked_data_free
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/match_id
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/head_tail_free_idx
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/match_idx
add wave -noupdate -group b_status_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_b_status_queue/linked_data_free_idx
add wave -noupdate -radix decimal /axi_riscv_lrsc_tb/b_queue.size
add wave -noupdate /axi_riscv_lrsc_tb/dut/i_lrsc/i_art/tbl_q
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/clk_i
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/rst_ni
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/exists_req_i
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/exists_gnt_o
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/exists_data_i
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/exists_o
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/inp_req_i
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/inp_gnt_o
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/inp_data_i
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/inp_id_i
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/oup_req_i
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/oup_gnt_o
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/oup_id_i
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/oup_pop_i
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/oup_data_o
add wave -noupdate -group read_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_read_in_flight_queue/oup_data_valid_o
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/clk_i
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/rst_ni
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/exists_req_i
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/exists_gnt_o
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/exists_data_i
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/exists_o
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/inp_req_i
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/inp_gnt_o
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/inp_data_i
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/inp_id_i
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/oup_req_i
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/oup_gnt_o
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/oup_id_i
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/oup_pop_i
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/oup_data_o
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/oup_data_valid_o
add wave -noupdate -group write_in_flight_queue /axi_riscv_lrsc_tb/dut/i_lrsc/i_write_in_flight_queue/linked_data_q
add wave -noupdate /axi_riscv_lrsc_tb/dut/i_lrsc/ar_push_ready
add wave -noupdate /axi_riscv_lrsc_tb/dut/i_lrsc/ar_push_valid
add wave -noupdate /axi_riscv_lrsc_tb/dut/i_lrsc/art_filter_ready
add wave -noupdate /axi_riscv_lrsc_tb/downstream_b_wait_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{illegal downstream.AW?} {158222010 ps} 1} {{upstream SC to  0x38} {157860020 ps} 1} {{Cursor 6} {21241320 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 239
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {49487360 ps}
