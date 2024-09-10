# set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/add.spm.elf
# set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/helloworld.spm.elf
# set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/generated_c_codes/feq_s.spm.elf
# set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/generated_c_codes/add.spm.elf
# set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/generated_c_codes/div.spm.elf
# set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/generated_c_codes/add.dram.memh
# set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/generated_c_codes/div.dram.memh
# set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/generated_c_codes/feq_s.dram.memh
# set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/generated_c_codes/fdiv_d.dram.memh
set BINARY /usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/generated_c_codes/sd_hit.dram.memh

set BOOTMODE 0
set PRELMODE 3

if {[catch { source compile.cheshire_soc.tcl \
}]} {return 1}
source start.cheshire_soc.tcl
log -r *
do /usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cheshire/target/stimuli/vsim/wave.do
run -all
