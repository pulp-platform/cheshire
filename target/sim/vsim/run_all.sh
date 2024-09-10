#!/bin/bash

questa_cmd="questa-2022.3"
# Define an array of BINARY values, each on a new line
# binary_root="/home/zexifu/embench-iot-baremetal/bd_cheshire_uart_baremetal/src"

# binaries=(
#     "aha-mont64"
#     "crc32"
#     "edn"
#     "huffbench"
#     "matmult-int"
#     "minver"
#     "nbody"
#     "nettle-aes"
#     "nettle-sha256"
#     "nsichneu"
#     "picojpeg"
#     "qrduino"
#     "sglib-combined"
#     "slre"
#     "st"
#     "statemate"
#     "ud"
#     "wikisort"
# )

# binaries=(
#     "wikisort"
# )

# binary_root="/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cheshire/sw/tests"
# binaries=(
#     "helloworld.spm.elf"
# )

binary_root="/home/zexifu/riscv-coremark"
binaries=(
    "coremark.bare.riscv"
)


vcd_start_times=(
    "56398146ps"
    "81713016ps"
    "128528568ps"
    "320929434ps"
    "342305880ps"
    "62401458ps"
    "60945612ps"
    "219614262ps"
    "120368262ps"
    "210803502ps"
    "802408242ps"
    "623381976ps"
    "281692992ps"
    "98402052ps"
    "77742462ps"
    "95137644ps"
    "93451176ps"
    "468610338ps"
)

vcd_dur_times=(
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
)

# Loop through each BINARY value and start a QuestaSim process
for i in "${!binaries[@]}"; do
    export BINARY=${binaries[$i]}
    # export BINARY_PATH=${binary_root}/${binaries[$i]}/${binaries[$i]}
    export BINARY_PATH=${binary_root}/${binaries[$i]}
    # export VCD_START=${vcd_start_times[$i]}
    export VCD_START=${vcd_start_times[$i]}
    export VCD_DUR=${vcd_dur_times[$i]}

    mkdir -p "work_${binaries[$i]}"
    cp compile.cheshire_soc.tcl work_${binaries[$i]}
    cp start.cheshire_soc.tcl work_${binaries[$i]}

    # multi gui mode
    cd work_${binaries[$i]} && \
    xterm -hold -e "${questa_cmd} vsim -do ../../../stimuli/vsim/run.tcl" &

    # # not used
    # cd work_${binaries[$i]} && \
    # ${questa_cmd} vsim -do ../../stimuli/vsim/run.tcl &
    
    # # bash mode
    # ${questa_cmd} vsim -do ../../stimuli/vsim/run.tcl &

    # #single gui mode
    # ${questa_cmd} vsim -do ../../stimuli/vsim/run.tcl
done

# Wait for all background processes to complete
wait
