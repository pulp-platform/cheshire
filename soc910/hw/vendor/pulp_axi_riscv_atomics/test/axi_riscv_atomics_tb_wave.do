onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_id
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_addr
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_len
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_size
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_burst
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_lock
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_cache
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_prot
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_qos
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_region
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_atop
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_user
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_valid
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/aw_ready
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/w_data
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/w_strb
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/w_last
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/w_user
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/w_valid
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/w_ready
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/b_id
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/b_resp
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/b_user
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/b_valid
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/b_ready
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_id
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_addr
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_len
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_size
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_burst
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_lock
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_cache
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_prot
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_qos
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_region
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_user
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_valid
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/ar_ready
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/r_id
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/r_data
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/r_resp
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/r_last
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/r_user
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/r_valid
add wave -noupdate -group {AXIBUS dut} /axi_riscv_atomics_tb/axi_dut/r_ready
add wave -noupdate -group {AXIBUS lrsc} -label aw_addr /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_addr
add wave -noupdate -group {AXIBUS lrsc} -label aw_prot /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_prot
add wave -noupdate -group {AXIBUS lrsc} -label aw_region /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_region
add wave -noupdate -group {AXIBUS lrsc} -label aw_atop /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_atop
add wave -noupdate -group {AXIBUS lrsc} -label aw_len /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_len
add wave -noupdate -group {AXIBUS lrsc} -label aw_size /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_size
add wave -noupdate -group {AXIBUS lrsc} -label aw_burst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_burst
add wave -noupdate -group {AXIBUS lrsc} -label aw_lock /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_lock
add wave -noupdate -group {AXIBUS lrsc} -label aw_cache /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_cache
add wave -noupdate -group {AXIBUS lrsc} -label aw_qos /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_qos
add wave -noupdate -group {AXIBUS lrsc} -label aw_id /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_id
add wave -noupdate -group {AXIBUS lrsc} -label aw_user /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_user
add wave -noupdate -group {AXIBUS lrsc} -color {Cornflower Blue} -label aw_valid /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_valid
add wave -noupdate -group {AXIBUS lrsc} -label aw_ready /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_aw_ready
add wave -noupdate -group {AXIBUS lrsc} -label w_data /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_w_data
add wave -noupdate -group {AXIBUS lrsc} -label w_strb /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_w_strb
add wave -noupdate -group {AXIBUS lrsc} -label w_user /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_w_user
add wave -noupdate -group {AXIBUS lrsc} -label w_last /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_w_last
add wave -noupdate -group {AXIBUS lrsc} -color {Cornflower Blue} -label w_valid /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_w_valid
add wave -noupdate -group {AXIBUS lrsc} -label w_ready /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_w_ready
add wave -noupdate -group {AXIBUS lrsc} -label b_resp /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_b_resp
add wave -noupdate -group {AXIBUS lrsc} -label b_id /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_b_id
add wave -noupdate -group {AXIBUS lrsc} -label b_user /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_b_user
add wave -noupdate -group {AXIBUS lrsc} -color {Cornflower Blue} -label b_valid /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_b_valid
add wave -noupdate -group {AXIBUS lrsc} -label b_ready /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_b_ready
add wave -noupdate -group {AXIBUS lrsc} -label ar_addr /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_addr
add wave -noupdate -group {AXIBUS lrsc} -label ar_prot /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_prot
add wave -noupdate -group {AXIBUS lrsc} -label ar_region /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_region
add wave -noupdate -group {AXIBUS lrsc} -label ar_len /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_len
add wave -noupdate -group {AXIBUS lrsc} -label ar_size /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_size
add wave -noupdate -group {AXIBUS lrsc} -label ar_burst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_burst
add wave -noupdate -group {AXIBUS lrsc} -label ar_lock /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_lock
add wave -noupdate -group {AXIBUS lrsc} -label ar_cache /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_cache
add wave -noupdate -group {AXIBUS lrsc} -label ar_qos /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_qos
add wave -noupdate -group {AXIBUS lrsc} -label ar_id /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_id
add wave -noupdate -group {AXIBUS lrsc} -label ar_user /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_user
add wave -noupdate -group {AXIBUS lrsc} -color {Cornflower Blue} -label ar_valid /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_valid
add wave -noupdate -group {AXIBUS lrsc} -label ar_ready /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_ar_ready
add wave -noupdate -group {AXIBUS lrsc} -label r_data /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_r_data
add wave -noupdate -group {AXIBUS lrsc} -label r_resp /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_r_resp
add wave -noupdate -group {AXIBUS lrsc} -label r_last /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_r_last
add wave -noupdate -group {AXIBUS lrsc} -label r_id /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_r_id
add wave -noupdate -group {AXIBUS lrsc} -label r_user /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_r_user
add wave -noupdate -group {AXIBUS lrsc} -color {Cornflower Blue} -label r_valid /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_r_valid
add wave -noupdate -group {AXIBUS lrsc} -label r_ready /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/int_axi_r_ready
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_id
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_addr
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_len
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_size
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_burst
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_lock
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_cache
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_prot
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_qos
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_region
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_atop
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_user
add wave -noupdate -group {AXIBUS mem} -color {Steel Blue} /axi_riscv_atomics_tb/axi_mem/aw_valid
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/aw_ready
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/w_data
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/w_strb
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/w_last
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/w_user
add wave -noupdate -group {AXIBUS mem} -color {Steel Blue} /axi_riscv_atomics_tb/axi_mem/w_valid
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/w_ready
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/b_id
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/b_resp
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/b_user
add wave -noupdate -group {AXIBUS mem} -color {Steel Blue} /axi_riscv_atomics_tb/axi_mem/b_valid
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/b_ready
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_id
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_addr
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_len
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_size
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_burst
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_lock
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_cache
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_prot
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_qos
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_region
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_user
add wave -noupdate -group {AXIBUS mem} -color {Steel Blue} /axi_riscv_atomics_tb/axi_mem/ar_valid
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/ar_ready
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/r_id
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/r_data
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/r_resp
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/r_last
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/r_user
add wave -noupdate -group {AXIBUS mem} -color {Steel Blue} /axi_riscv_atomics_tb/axi_mem/r_valid
add wave -noupdate -group {AXIBUS mem} /axi_riscv_atomics_tb/axi_mem/r_ready
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_id}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_addr}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_len}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_size}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_burst}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_lock}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_cache}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_prot}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_qos}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_region}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_atop}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_user}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_valid}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/aw_ready}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/w_data}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/w_strb}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/w_last}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/w_user}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/w_valid}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/w_ready}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/b_id}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/b_resp}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/b_user}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/b_valid}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/b_ready}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_id}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_addr}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_len}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_size}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_burst}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_lock}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_cache}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_prot}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_qos}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_region}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_user}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_valid}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/ar_ready}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/r_id}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/r_data}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/r_resp}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/r_last}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/r_user}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/r_valid}
add wave -noupdate -group {AXIBUS_cl_[0]} {/axi_riscv_atomics_tb/axi_cl[0]/r_ready}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_id}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_addr}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_len}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_size}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_burst}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_lock}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_cache}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_prot}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_qos}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_region}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_atop}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_user}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_valid}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/aw_ready}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/w_data}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/w_strb}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/w_last}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/w_user}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/w_valid}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/w_ready}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/b_id}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/b_resp}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/b_user}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/b_valid}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/b_ready}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_id}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_addr}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_len}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_size}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_burst}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_lock}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_cache}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_prot}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_qos}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_region}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_user}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_valid}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/ar_ready}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/r_id}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/r_data}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/r_resp}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/r_last}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/r_user}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/r_valid}
add wave -noupdate -group {AXIBUS_cl_[1]} {/axi_riscv_atomics_tb/axi_cl[1]/r_ready}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_id}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_addr}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_len}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_size}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_burst}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_lock}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_cache}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_prot}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_qos}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_region}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_atop}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_user}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_valid}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/aw_ready}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/w_data}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/w_strb}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/w_last}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/w_user}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/w_valid}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/w_ready}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/b_id}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/b_resp}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/b_user}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/b_valid}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/b_ready}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_id}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_addr}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_len}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_size}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_burst}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_lock}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_cache}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_prot}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_qos}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_region}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_user}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_valid}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/ar_ready}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/r_id}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/r_data}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/r_resp}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/r_last}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/r_user}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/r_valid}
add wave -noupdate -group {AXI_cl[7]} {/axi_riscv_atomics_tb/axi_cl[7]/r_ready}
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/clk_i
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/rst_ni
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_addr_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_prot_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_region_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_atop_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_len_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_size_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_burst_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_lock_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_cache_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_qos_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_id_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_user_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_ready_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_aw_valid_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_addr_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_prot_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_region_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_len_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_size_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_burst_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_lock_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_cache_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_qos_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_id_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_user_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_ready_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_ar_valid_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_w_data_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_w_strb_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_w_user_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_w_last_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_w_ready_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_w_valid_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_r_data_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_r_resp_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_r_last_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_r_id_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_r_user_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_r_ready_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_r_valid_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_b_resp_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_b_id_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_b_user_o
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_b_ready_i
add wave -noupdate -group {AMO Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/slv_b_valid_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_addr_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_prot_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_region_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_atop_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_len_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_size_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_burst_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_lock_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_cache_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_qos_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_id_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_user_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_ready_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_aw_valid_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_addr_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_prot_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_region_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_len_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_size_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_burst_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_lock_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_cache_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_qos_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_id_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_user_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_ready_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_ar_valid_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_w_data_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_w_strb_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_w_user_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_w_last_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_w_ready_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_w_valid_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_r_data_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_r_resp_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_r_last_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_r_id_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_r_user_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_r_ready_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_r_valid_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_b_resp_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_b_id_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_b_user_i
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_b_ready_o
add wave -noupdate -group {AMO Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/mst_b_valid_i
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/aw_state_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/aw_state_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_state_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_state_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/b_state_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/b_state_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/ar_state_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/ar_state_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_state_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_state_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/adapter_ready
add wave -noupdate -group {AMO Adapter} -color Orange /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/atop_valid_d
add wave -noupdate -group {AMO Adapter} -color Orange /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/atop_valid_q
add wave -noupdate -group {AMO Adapter} -color Yellow /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/force_wf_d
add wave -noupdate -group {AMO Adapter} -color Yellow /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/force_wf_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/start_wf_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/start_wf_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/b_resp_valid
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/aw_free
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_free
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/b_free
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/ar_free
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_free
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/aw_trans_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/aw_trans_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_cnt_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_cnt_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_cnt_req_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_cnt_req_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_cnt_inj_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_cnt_inj_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/addr_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/addr_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/size_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/size_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/strb_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/strb_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/id_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/id_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/cache_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/cache_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/prot_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/prot_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/qos_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/qos_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/region_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/region_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/aw_user_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/aw_user_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_user_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_user_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_user_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_user_q
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_resp_d
add wave -noupdate -group {AMO Adapter} -expand -group Transaction /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_resp_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/atop_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/atop_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_data_d
add wave -noupdate -group {AMO Adapter} -color {Cornflower Blue} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_data_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_data_d
add wave -noupdate -group {AMO Adapter} -color {Cornflower Blue} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_data_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/result_d
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/result_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_d_valid_d
add wave -noupdate -group {AMO Adapter} -color {Cornflower Blue} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/w_d_valid_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_d_valid_d
add wave -noupdate -group {AMO Adapter} -color {Cornflower Blue} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/r_d_valid_q
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/alu_operand_a
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/alu_operand_b
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/alu_result
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/alu_result_ext
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/transaction_collision
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/op_a
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/op_b
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/op_a_sign_ext
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/op_b_sign_ext
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/res
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/strb_ext
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/sign_a
add wave -noupdate -group {AMO Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/sign_b
add wave -noupdate -group {AMO Adapter} -expand -group ALU /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/i_amo_alu/amo_op_i
add wave -noupdate -group {AMO Adapter} -expand -group ALU /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/i_amo_alu/amo_operand_a_i
add wave -noupdate -group {AMO Adapter} -expand -group ALU /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/i_amo_alu/amo_operand_b_i
add wave -noupdate -group {AMO Adapter} -expand -group ALU /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/i_amo_alu/amo_result_o
add wave -noupdate -group {AMO Adapter} -expand -group ALU /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/i_amo_alu/adder_sum
add wave -noupdate -group {AMO Adapter} -expand -group ALU /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/i_amo_alu/adder_operand_a
add wave -noupdate -group {AMO Adapter} -expand -group ALU /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_amos/i_amo_alu/adder_operand_b
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/clk_i
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rst_ni
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_addr_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_prot_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_region_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_atop_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_len_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_size_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_burst_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_lock_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_cache_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_qos_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_id_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_user_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_ready_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_aw_valid_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_addr_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_prot_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_region_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_len_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_size_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_burst_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_lock_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_cache_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_qos_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_id_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_user_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_ready_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_ar_valid_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_w_data_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_w_strb_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_w_user_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_w_last_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_w_ready_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_w_valid_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r_data_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r_resp_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r_last_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r_id_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r_user_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r_ready_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r_valid_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_b_resp_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_b_id_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_b_user_o
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_b_ready_i
add wave -noupdate -group {LRSC Adapter} -group slv /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_b_valid_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_addr_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_prot_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_region_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_atop_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_len_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_size_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_burst_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_lock_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_cache_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_qos_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_id_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_user_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_ready_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_valid_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_ready
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_aw_valid
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/clk_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/rst_ni
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/clr_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/testmode_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/valid_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/ready_o
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/data_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/valid_o
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/ready_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/data_o
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/fifo_empty
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/fifo_full
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/clk_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/rst_ni
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/flush_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/testmode_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/full_o
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/empty_o
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/usage_o
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO -color {Cornflower Blue} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/push_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/data_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO -color {Cornflower Blue} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/pop_i
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/data_o
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/gate_clock
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/read_pointer_n
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/read_pointer_q
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/write_pointer_n
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/write_pointer_q
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/status_cnt_n
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/status_cnt_q
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/mem_n
add wave -noupdate -group {LRSC Adapter} -group mst -group aw_trans_fifo -expand -group FIFO /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_aw_trans_reg/i_fifo/i_fifo_v3/mem_q
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_addr_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_prot_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_region_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_len_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_size_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_burst_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_lock_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_cache_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_qos_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_id_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_user_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_ready_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_ar_valid_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_w_data_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_w_strb_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_w_user_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_w_last_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_w_ready_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_w_valid_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_r_data_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_r_resp_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_r_last_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_r_id_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_r_user_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_r_ready_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_r_valid_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_b_resp_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_b_id_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_b_user_i
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_b_ready_o
add wave -noupdate -group {LRSC Adapter} -group mst /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_b_valid_i
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_push_id
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_check_id
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_check_res
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_check_clr_addr
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_check_clr_excl
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_check_clr_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_check_clr_gnt
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/clk_i
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/rst_ni
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/check_clr_addr_i
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/check_id_i
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/check_clr_excl_i
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/check_res_o
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/check_clr_req_i
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/check_clr_gnt_o
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/set_addr_i
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/set_id_i
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/set_req_i
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/set_gnt_o
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/clr
add wave -noupdate -group {LRSC Adapter} -group art /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/gen_res_tbl/i_art/set
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/w_cmd_inp
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/w_cmd_oup
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/w_cmd_push
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/w_cmd_pop
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/w_cmd_full
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/w_cmd_empty
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_inp_id
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_inp_cmd
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_inp_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_inp_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_inj_inp
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_inj_push
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_inj_oup
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_inj_pop
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_oup_id
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_inj_full
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_inj_empty
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_oup_cmd
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_oup_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_oup_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_oup_pop
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_status_oup_valid
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_state_d
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/b_state_q
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rifq_oup_id
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_push_addr
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_push_excl
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_push_res
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_push_valid
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_push_ready
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_filter_valid
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_filter_ready
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_set_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/art_set_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rifq_inp_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rifq_inp_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rifq_oup_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rifq_oup_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rifq_oup_pop
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rifq_oup_data_valid
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rifq_inp_data
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/rifq_oup_data
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/wifq_exists
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_wifq_exists_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_wifq_exists_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/aw_wifq_exists_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/aw_wifq_exists_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/wifq_exists_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/wifq_exists_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/wifq_inp_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/wifq_oup_req
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/wifq_oup_gnt
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/wifq_oup_data_valid
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_wifq_exists_inp
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/aw_wifq_exists_inp
add wave -noupdate -group {LRSC Adapter} -expand /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/wifq_exists_inp
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_b
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_b_valid
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_b_ready
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r_valid
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/slv_r_ready
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_b_valid
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/mst_b_ready
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_state_d
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/ar_state_q
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/aw_state_d
add wave -noupdate -group {LRSC Adapter} /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/aw_state_q
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/clk_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/rst_ni
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/inp_id_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/inp_data_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/inp_req_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/inp_gnt_o
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/exists_data_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/exists_mask_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/exists_req_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/exists_o
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/exists_gnt_o
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/oup_id_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/oup_pop_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/oup_req_i
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/oup_data_o
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/oup_data_valid_o
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/oup_gnt_o
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/head_tail_d
add wave -noupdate -group Write_in_flight_Q -expand /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/head_tail_q
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/linked_data_d
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/linked_data_q
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/full
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/head_tail_free
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/exists_match
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/linked_data_free
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/head_tail_free_idx
add wave -noupdate -group Write_in_flight_Q /axi_riscv_atomics_tb/i_axi_atomic_adapter/i_atomics/i_lrsc/i_write_in_flight_queue/linked_data_free_idx
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/clk_i
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/w_valid
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/w_addr
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/w_data
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/w_id
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/w_user
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/w_beat_count
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/w_last
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/r_valid
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/r_addr
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/r_data
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/r_id
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/r_user
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/r_beat_count
add wave -noupdate -group {Memory Monitor} /axi_riscv_atomics_tb/mem_monitor_dv/r_last
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 192
configure wave -valuecolwidth 193
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
WaveRestoreZoom {0 ps} {186396 ns}
