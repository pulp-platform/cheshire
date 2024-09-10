#!/bin/bash

questa_cmd="questa-2022.3"
# Define an array of BINARY values, each on a new line
binary_root="/usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/sw/tests/single_instruction/generated_c_codes"
netlist_root="/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/innovus_batch_20240908"

binaries=(
    "add" 
    "mul" 
    "div"
    "fadd_s"
    "fadd_d"
    "fmul_s"
    "fmul_d"
    "fdiv_s"
    "fdiv_d"
    "feq_s"
    "feq_d"

    "lw_hit"
    # "lw_miss"
    "ld_hit"
    # "ld_miss"
    "sw_hit"
    # "sw_miss"
    "sd_hit"
    # "sd_miss"
)

target_freq=(
  "1000"
#   "900"
  "800"
#   "700"
#   "600"
#   "500"
  "400"
#   "300"
  "200"
)  # Frequencies in MHz

# in ps
# vcd_start_times=(
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"

#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
#     "430092000"
# )

vcd_start_times=(
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"

    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
    "10162000"
)


# Loop through each BINARY value and start a QuestaSim process
for ((j=0; j<${#target_freq[@]}; j++)); do
    export TARGET_FREQ=${target_freq[$j]}
    netlist="$netlist_root/innovus_${target_freq[$j]}/out/cva6.v"
    for i in "${!binaries[@]}"; do
        export BINARY=${binaries[$i]}
        export BINARY_PATH=${binary_root}/${binaries[$i]}.dram.memh
        # export VCD_START=${vcd_start_times[$i]}
        export VCD_START=${vcd_start_times[$i]}
        # export VCD_DUR=${vcd_dur_times[$i]}
        export PRELMODE=3

        work_folder="work_${binaries[$i]}_${target_freq[$j]}"
        mkdir -p ${work_folder}
        cp compile.cheshire_soc.tcl ${work_folder}
        sed -i "s|CHANGEME_NETLIST|${netlist}|g" ${work_folder}/compile.cheshire_soc.tcl
        cp start.cheshire_soc.tcl ${work_folder}

        # multi gui mode
        cd ${work_folder} && \
        xterm -hold -e "${questa_cmd} vsim -do ../../../stimuli/vsim/run_single.tcl" &

        # # not used
        # cd ${work_folder} && \
        # ${questa_cmd} vsim -do ../../stimuli/vsim/run.tcl &
        
        # # bash mode
        # ${questa_cmd} vsim -do ../../stimuli/vsim/run.tcl &

        # # single gui mode
        # ${questa_cmd} vsim -do ../../stimuli/vsim/run.tcl
        sleep 3
    done
    sleep 10
done

# Wait for all background processes to complete
wait
