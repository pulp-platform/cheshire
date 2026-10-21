#Alina Zmeu

set faultsim_tb $::env(FAULTSIM_TB)
set num_fault_sim $::env(NUM_FAULT_SIM)
set bootmode $::env(BOOTMODE)
set prelmode $::env(PRELMODE)
set binary   $::env(BINARY)


set_config -global_max_jobs 12

# Create fault campaign (Build fault universe through VC FCC)
create_campaign -localhost -args "-full64 -daidir simv.daidir -dut ${faultsim_tb}.fix.dut.gen_cva6_cores[0].i_core_cva6 -sff states.sff -sff ${faultsim_tb}.sff -campaign fc1 -sample num:${num_fault_sim} -overwrite "

create_testcases -name {test1} -exec simv -daidir simv.daidir -campaign fc1 -args "-no_save +BOOTMODE=\"$bootmode\" +PRELMODE=\"$prelmode\" +BINARY=\"$binary\""

# Run fault simulation campaign
fsim -fsim_args "-no_save" -localhost -no_coats 

# Reporting after fault simulation
report -campaign fc1 
show_fault_results -campaign fc1

