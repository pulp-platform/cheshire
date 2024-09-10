# set BINARY ../../../sw/tests/helloworld.spm.elf
# set BINARY /home/zexifu/embench-iot-baremetal/bd/src/minver/minver
# set BINARY /home/zexifu/embench-iot-baremetal/bd_cheshire_uart_baremetal/src/minver/minver
# set BINARY /home/zexifu/riscv-coremark/coremark.bare.riscv

# Check if BINARY is set
if {![info exists ::env(BINARY_PATH)]} {
    error "BINARY_PATH environment variable not set"
}

set BINARY $::env(BINARY_PATH)

# Check if VCD_START and VCD_END are set
if {![info exists ::env(VCD_START)] || ![info exists ::env(VCD_END)]} {
    # error "VCD_START and/or VCD_END environment variables not set"
}

set TARGET_FREQ $::env(TARGET_FREQ)

set BOOTMODE 0
set PRELMODE $::env(PRELMODE)
# Compile design
source compile.cheshire_soc.tcl
# source compile.cheshire_soc.tcl.240817bak

# Start and run simulation
source start.cheshire_soc.tcl

# log -r *

do /usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cheshire/target/stimuli/vsim/wave.do

# run -all

# vcd dump
set vcd_root ./vcd
set VCD_FILE  ${vcd_root}/cva6_1000MHz_$::env(BINARY).vcd
set vcd_files [list ${VCD_FILE}]

# individual instructions time ranges
set VCD_START  $::env(VCD_START)
# set VCD_DUR    $::env(VCD_DUR)

# init vcd files and nets to log
# exec mkdir -p vcd
exec mkdir -p ${vcd_root}
foreach f $vcd_files {vcd files $f}
foreach f $vcd_files {vcd add -file $f -r /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/*}
foreach f $vcd_files {vcd off $f}

# go to start of mul
run ${VCD_START}
vcd on ${VCD_FILE}
# run ${VCD_DUR}
run -all

vcd flush ${VCD_FILE}
vcd off ${VCD_FILE}

exit



