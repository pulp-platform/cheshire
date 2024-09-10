# This script was generated automatically by bender.
set ROOT "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cheshire"

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/clk_rst_gen.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/rand_id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/rand_stream_mst.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/rand_synch_holdable_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/rand_verif_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/signal_highlighter.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/sim_timeout.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/stream_watchdog.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/rand_synch_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/src/rand_stream_slv.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/common_verification-8eae3e9fca231308/test/tb_clk_rst_gen.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/rtl/tc_sram.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/rtl/tc_sram_impl.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/rtl/tc_clk.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/deprecated/cluster_pwr_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/deprecated/generic_memory.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/deprecated/generic_rom.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/deprecated/pad_functional.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/deprecated/pulp_buffer.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/deprecated/pulp_pwr_cells.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/tc_pwr.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/test/tb_tc_sram.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/deprecated/pulp_clock_gating_async.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/deprecated/cluster_clk_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-223c43ccbeb688f9/src/deprecated/pulp_clk_cells.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/binary_to_gray.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cb_filter_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cc_onehot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cdc_reset_ctrlr_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cf_math_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/clk_int_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/credit_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/delta_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/ecc_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/edge_propagator_tx.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/exp_backoff.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/fifo_v3.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/gray_to_binary.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/isochronous_4phase_handshake.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/isochronous_spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/lfsr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/lfsr_16bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/lfsr_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/lossy_valid_to_stream.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/mv_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/onehot_to_bin.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/plru_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/passthrough_stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/popcount.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/rr_arb_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/rstgen_bypass.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/serial_deglitch.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/shift_reg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/shift_reg_gated.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/spill_register_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_demux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_fork.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_intf.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_join_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_mux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_throttle.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/sub_per_hash.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/unread.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/read.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/addr_decode_dync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cdc_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cdc_4phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/clk_int_div_static.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/addr_decode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/addr_decode_napot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/multiaddr_decode.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cb_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cdc_fifo_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/clk_mux_glitch_free.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/ecc_decode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/ecc_encode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/edge_detect.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/lzc.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/max_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/rstgen.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_delay.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_fork_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_join.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cdc_reset_ctrlr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cdc_fifo_gray.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/fall_through_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_arbiter_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_fifo_optimal_wrap.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_xbar.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cdc_fifo_gray_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/cdc_2phase_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/mem_to_banks_detailed.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_arbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/stream_omega_net.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/mem_to_banks.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/sram.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/addr_decode_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/cb_filter_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/cdc_2phase_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/cdc_2phase_clearable_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/cdc_fifo_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/cdc_fifo_clearable_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/fifo_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/graycode_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/id_queue_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/passthrough_stream_fifo_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/popcount_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/rr_arb_tree_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/stream_test.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/stream_register_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/stream_to_mem_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/sub_per_hash_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/isochronous_crossing_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/stream_omega_net_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/stream_xbar_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/clk_int_div_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/clk_int_div_static_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/clk_mux_glitch_free_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/test/lossy_valid_to_stream_tb.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/clock_divider_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/clk_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/find_first_one.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/generic_LFSR_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/generic_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/prioarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/pulp_sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/pulp_sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/rrarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/clock_divider.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/fifo_v2.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/deprecated/fifo_v1.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/edge_propagator_ack.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/edge_propagator.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/src/edge_propagator_rx.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/apb-521b279a5c028536/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/src/apb_pkg.sv" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/src/apb_intf.sv" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/src/apb_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/src/apb_regs.sv" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/src/apb_cdc.sv" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/src/apb_demux.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/apb-521b279a5c028536/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/src/apb_test.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/apb-521b279a5c028536/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/test/tb_apb_regs.sv" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/test/tb_apb_cdc.sv" \
    "$ROOT/.bender/git/checkouts/apb-521b279a5c028536/test/tb_apb_demux.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_intf.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_atop_filter.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_burst_splitter.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_bus_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_cdc_dst.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_cdc_src.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_cut.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_delayer.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_demux_simple.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_dw_downsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_dw_upsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_fifo.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_id_remap.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_id_prepend.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_isolate.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_from_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_mailbox.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_regs.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_to_axi.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_modify_address.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_rw_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_rw_split.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_serializer.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_slave_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_throttle.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_to_detailed_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_cdc.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_from_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_id_serialize.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_multicut.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_to_axi_lite.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_zero_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_interleaved_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_iw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_lite_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_xbar_unmuxed.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_to_mem_banked.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_to_mem_interleaved.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_to_mem_split.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_xp.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_chan_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_dumper.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_sim_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/src/axi_test.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_dw_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_xbar_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_addr_test.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_atop_filter.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_bus_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_cdc.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_delayer.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_dw_downsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_dw_upsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_fifo.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_isolate.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_lite_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_lite_mailbox.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_lite_regs.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_iw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_lite_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_lite_to_axi.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_lite_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_modify_address.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_serializer.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_sim_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_slave_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_to_axi_lite.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_to_mem_banked.sv" \
    "$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/test/tb_axi_xbar.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/fpu_div_sqrt_mvp-33e0a4fc0dc853c1/hdl/defs_div_sqrt_mvp.sv" \
    "$ROOT/.bender/git/checkouts/fpu_div_sqrt_mvp-33e0a4fc0dc853c1/hdl/iteration_div_sqrt_mvp.sv" \
    "$ROOT/.bender/git/checkouts/fpu_div_sqrt_mvp-33e0a4fc0dc853c1/hdl/control_mvp.sv" \
    "$ROOT/.bender/git/checkouts/fpu_div_sqrt_mvp-33e0a4fc0dc853c1/hdl/norm_div_sqrt_mvp.sv" \
    "$ROOT/.bender/git/checkouts/fpu_div_sqrt_mvp-33e0a4fc0dc853c1/hdl/preprocess_mvp.sv" \
    "$ROOT/.bender/git/checkouts/fpu_div_sqrt_mvp-33e0a4fc0dc853c1/hdl/nrbd_nrsc_mvp.sv" \
    "$ROOT/.bender/git/checkouts/fpu_div_sqrt_mvp-33e0a4fc0dc853c1/hdl/div_sqrt_top_mvp.sv" \
    "$ROOT/.bender/git/checkouts/fpu_div_sqrt_mvp-33e0a4fc0dc853c1/hdl/div_sqrt_mvp_wrapper.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_pkg.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_cast_multi.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_classifier.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk/rtl/gated_clk_cell.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_ctrl.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_ff1.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_pack_single.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_prepare.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_round_single.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_special.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_srt_single.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_top.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/pa_fpu_dp.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/pa_fpu_frbus.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/pa_fpu_src_type.v" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_divsqrt_th_32.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_divsqrt_multi.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_fma.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_fma_multi.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_sdotp_multi.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_sdotp_multi_wrapper.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_noncomp.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_opgroup_block.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_opgroup_fmt_slice.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_opgroup_multifmt_slice.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_rounding.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/lfsr_sr.sv" \
    "$ROOT/.bender/git/checkouts/fpnew-ed006ec0a4178e29/src/fpnew_top.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/apb-521b279a5c028536/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_intf.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/vendor/lowrisc_opentitan/src/prim_subreg_arb.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/vendor/lowrisc_opentitan/src/prim_subreg_ext.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/apb_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/axi_lite_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/axi_to_reg_v2.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/periph_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_cdc.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_cut.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_demux.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_filter_empty_writes.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_mux.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_to_tlul.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_to_axi.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_uniform.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/vendor/lowrisc_opentitan/src/prim_subreg_shadow.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/vendor/lowrisc_opentitan/src/prim_subreg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/deprecated/axi_to_reg.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/apb-521b279a5c028536/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/src/reg_test.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/apb-521b279a5c028536/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/slib_clock_div.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/slib_counter.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/slib_edge_detect.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/slib_fifo.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/slib_input_filter.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/slib_input_sync.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/slib_mv_filter.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/uart_baudgen.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/uart_interrupt.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/uart_receiver.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/uart_transmitter.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/apb_uart.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/apb_uart_wrap.sv" \
    "$ROOT/.bender/git/checkouts/apb_uart-38dcfab592cbc1a1/src/reg_uart_wrap.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_burst_cutter.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_data_way.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_merge_unit.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_read_unit.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_write_unit.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/eviction_refill/axi_llc_ax_master.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/eviction_refill/axi_llc_r_master.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/eviction_refill/axi_llc_w_master.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/hit_miss_detect/axi_llc_evict_box.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/hit_miss_detect/axi_llc_lock_box_bloom.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/hit_miss_detect/axi_llc_miss_counters.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/hit_miss_detect/axi_llc_tag_pattern_gen.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_chan_splitter.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_evict_unit.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_refill_unit.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_ways.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/hit_miss_detect/axi_llc_tag_store.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_config.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_hit_miss.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_top.sv" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/src/axi_llc_reg_wrap.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/test" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/test/tb_axi_llc.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/src/axi_res_tbl.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/src/axi_riscv_amos_alu.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/src/axi_riscv_amos.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/src/axi_riscv_lrsc.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/src/axi_riscv_atomics.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/src/axi_riscv_lrsc_wrap.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/src/axi_riscv_amos_wrap.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/src/axi_riscv_atomics_wrap.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/src/axi_riscv_atomics_structs.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/test/tb_axi_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/test/golden_memory.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/test/axi_riscv_atomics_tb.sv" \
    "$ROOT/.bender/git/checkouts/axi_riscv_atomics-40ad8d2d0e0daa8b/test/axi_riscv_lrsc_tb.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_rt-7cef46f372eaf0fb/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/axi_rt-7cef46f372eaf0fb/test/tb_axi_rt_unit_top.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/axi_vga-74c838b44ce780d5/src/axi_vga_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi_vga-74c838b44ce780d5/src/axi_vga_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/axi_vga-74c838b44ce780d5/src/axi_vga_timing_fsm.sv" \
    "$ROOT/.bender/git/checkouts/axi_vga-74c838b44ce780d5/src/axi_vga_fetcher.sv" \
    "$ROOT/.bender/git/checkouts/axi_vga-74c838b44ce780d5/src/axi_vga.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/axi_vga-74c838b44ce780d5/test/tb_axi_vga.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/clic-360fff7ce2d41116/src/clicint_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/clic-360fff7ce2d41116/src/clicint_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/clic-360fff7ce2d41116/src/mclic_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/clic-360fff7ce2d41116/src/mclic_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/clic-360fff7ce2d41116/src/clic_reg_adapter.sv" \
    "$ROOT/.bender/git/checkouts/clic-360fff7ce2d41116/src/clic_gateway.sv" \
    "$ROOT/.bender/git/checkouts/clic-360fff7ce2d41116/src/clic_target.sv" \
    "$ROOT/.bender/git/checkouts/clic-360fff7ce2d41116/src/clic_apb.sv" \
    "$ROOT/.bender/git/checkouts/clic-360fff7ce2d41116/src/clic.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/clint-de4a234303f657d0/src/clint_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/clint-de4a234303f657d0/src/clint_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/clint-de4a234303f657d0/src/clint.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/clint-de4a234303f657d0/test/clint_tb.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/config_pkg.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/cv64a6_imafdcsclic_sv39_config_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/riscv_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/ariane_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/mmu_sv39/tlb.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/mmu_sv39/mmu.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/mmu_sv39/ptw.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cva6_accel_first_pass_decoder_stub.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/mmu_sv39x4/cva6_tlb_sv39x4.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/mmu_sv39x4/cva6_mmu_sv39x4.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/mmu_sv39x4/cva6_ptw_sv39x4.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cva6_clic_controller.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/wt_cache_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/std_cache_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/acc_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/instr_tracer_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/cvxif_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cvxif_example/include/cvxif_instr_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cvxif_fu.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cvxif_example/cvxif_example_coprocessor.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cvxif_example/instr_decoder.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cva6.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/alu.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/fpu_wrap.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/branch_unit.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/compressed_decoder.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/controller.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/csr_buffer.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/csr_regfile.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/decoder.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/ex_stage.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/instr_realign.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/id_stage.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/issue_read_operands.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/issue_stage.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/load_unit.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/load_store_unit.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/lsu_bypass.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/mult.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/multiplier.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/serdiv.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/perf_counters.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/ariane_regfile_ff.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/ariane_regfile_fpga.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/scoreboard.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/store_buffer.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/amo_buffer.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/store_unit.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/commit_stage.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/axi_shim.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/acc_dispatcher.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cva6_rvfi_probes.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/frontend/btb.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/frontend/bht.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/frontend/ras.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/frontend/instr_scan.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/frontend/instr_queue.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/frontend/frontend.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/wt_dcache_ctrl.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/wt_dcache_mem.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/wt_dcache_missunit.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/wt_dcache_wbuffer.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/wt_dcache.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/cva6_icache.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/wt_cache_subsystem.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/wt_axi_adapter.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/tag_cmp.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/cache_ctrl.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/amo_alu.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/axi_adapter.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/miss_handler.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/std_nbdcache.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/cva6_icache_axi_wrapper.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/cache_subsystem/std_cache_subsystem.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/pmp/src/pmp.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/pmp/src/pmp_entry.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/common/local/util" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/common/local/util/sram_pulp.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/common/local/util" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/common/local/util/tc_sram_wrapper.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/common/local/util" \
    "+incdir+/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/core/include/instr_tracer_pkg.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/common/local/util/instr_tracer.sv" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cva6/common/local/util/instr_tracer_if.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/idma_transfer_id_gen.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_pkg.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_buffer.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_error_handler.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_channel_coupler.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_axi_transport_layer.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_axi_lite_transport_layer.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_obi_transport_layer.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_legalizer.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/idma_backend.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/legacy/axi_dma_backend.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/legacy/midends/idma_2D_midend.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/midends/idma_nd_midend.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/register_32bit_2d/idma_reg32_2d_frontend_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/register_32bit_2d/idma_reg32_2d_frontend_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/register_32bit_2d/idma_reg32_2d_frontend.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/register_64bit/idma_reg64_frontend_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/register_64bit/idma_reg64_frontend_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/register_64bit/idma_reg64_frontend.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/register_64bit_2d/idma_reg64_2d_frontend_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/register_64bit_2d/idma_reg64_2d_frontend_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/register_64bit_2d/idma_reg64_2d_frontend.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/desc64/idma_desc64_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/desc64/idma_desc64_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/desc64/idma_desc64_shared_counter.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/desc64/idma_desc64_reg_wrapper.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/frontends/desc64/idma_desc64_top.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/systems/cva6_reg/dma_core_wrap.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_SIMULATION \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/idma_intf.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/idma_tb_per2axi.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/idma_obi_asserter.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/idma_test.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/idma_obi2axi_bridge.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/tb_idma_backend.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/tb_idma_lite_backend.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/tb_idma_obi_backend.sv" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/tb_idma_nd_backend.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/test/frontends/tb_idma_desc64_top.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/irq_router-376b3d113c15d0ef/rtl/irq_router_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/irq_router-376b3d113c15d0ef/rtl/irq_router_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/irq_router-376b3d113c15d0ef/rtl/irq_router.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/irq_router-376b3d113c15d0ef/tb/irq_router_tb.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/prim_pulp_platform/prim_flop_2sync.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/prim_pulp_platform/prim_flop_en.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_fifo_sync_cnt.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_util_pkg.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_max_tree.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_sync_reqack.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_sync_reqack_data.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_pulse_sync.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_packer_fifo.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_fifo_sync.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_filter_ctr.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_intr_hw.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/prim/rtl/prim_fifo_async.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/gpio/rtl/gpio_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/i2c/rtl/i2c_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/rv_plic/rtl/rv_plic_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/gpio/rtl/gpio_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/i2c/rtl/i2c_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/rv_plic/rtl/rv_plic_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/i2c/rtl/i2c_pkg.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/i2c/rtl/i2c_fsm.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/rv_plic/rtl/rv_plic_gateway.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_byte_merge.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_byte_select.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_cmd_pkg.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_command_queue.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_fsm.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_window.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_data_fifos.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_shift_register.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/i2c/rtl/i2c_core.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/rv_plic/rtl/rv_plic_target.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host_core.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/gpio/rtl/gpio.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/i2c/rtl/i2c.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/spi_host/rtl/spi_host.sv" \
    "$ROOT/.bender/git/checkouts/opentitan_peripherals-7b624fb57f78de9a/src/rv_plic/rtl/rv_plic.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dm_pkg.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/debug_rom/debug_rom.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/debug_rom/debug_rom_one_scratch.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dm_csrs.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dm_mem.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dmi_cdc.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dmi_jtag_tap.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dm_sba.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dm_top.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dmi_jtag.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dm_obi_top.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dmi_test.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/src/dmi_intf.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/tb/jtag_dmi/jtag_intf.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/tb/jtag_dmi/jtag_test.sv" \
    "$ROOT/.bender/git/checkouts/riscv-dbg-1a98531d53bb4602/tb/jtag_dmi/tb_jtag_dmi.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/axis/include" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/regs/serial_link_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/regs/serial_link_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/regs/serial_link_single_channel_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/regs/serial_link_single_channel_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/serial_link_pkg.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/channel_allocator/stream_chopper.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/channel_allocator/stream_dechopper.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/channel_allocator/channel_despread_sfr.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/channel_allocator/channel_spread_sfr.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/channel_allocator/serial_link_channel_allocator.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/serial_link_network.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/serial_link_data_link.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/serial_link_physical.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/serial_link.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/serial_link_occamy_wrapper.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/axis/include" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/test/axi_channel_compare.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/test/tb_axi_serial_link.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/test/tb_ch_calib_serial_link.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/test/tb_stream_chopper.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/test/tb_stream_chopper_dechopper.sv" \
    "$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/test/tb_channel_allocator.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "$ROOT/.bender/git/checkouts/unbent-a93c32aef5b319fd/src/bus_err_unit_bare.sv" \
    "$ROOT/.bender/git/checkouts/unbent-a93c32aef5b319fd/src/bus_err_unit_reg_pkg.sv" \
    "$ROOT/.bender/git/checkouts/unbent-a93c32aef5b319fd/src/bus_err_unit_reg_top.sv" \
    "$ROOT/.bender/git/checkouts/unbent-a93c32aef5b319fd/src/bus_err_unit.sv" \
    "$ROOT/.bender/git/checkouts/unbent-a93c32aef5b319fd/src/axi_err_unit_wrap.sv" \
    "$ROOT/.bender/git/checkouts/unbent-a93c32aef5b319fd/src/obi_err_unit_wrap.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_rt-7cef46f372eaf0fb/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/axis/include" \
    "+incdir+$ROOT/hw/include" \
    "$ROOT/hw/future/UsbOhciAxi4.v" \
    "$ROOT/hw/future/spinal_usb_ohci.sv" \
    "$ROOT/hw/bootrom/cheshire_bootrom.sv" \
    "$ROOT/hw/regs/cheshire_reg_pkg.sv" \
    "$ROOT/hw/regs/cheshire_reg_top.sv" \
    "$ROOT/hw/cheshire_pkg.sv" \
    "$ROOT/hw/cheshire_soc.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_rt-7cef46f372eaf0fb/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/axis/include" \
    "+incdir+$ROOT/hw/include" \
    "$ROOT/target/sim/models/s25fs512s.v" \
    "$ROOT/target/sim/models/24FC1025.v" \
    "$ROOT/target/sim/src/vip_cheshire_soc.sv" \
    "$ROOT/target/sim/src/tb_cheshire_pkg.sv" \
    "$ROOT/target/sim/src/fixture_cheshire_soc.sv" \
    "$ROOT/target/sim/src/tb_cheshire_soc.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -suppress 2583 -suppress 13314 +define+SPIKE_TANDEM \
    +define+IVCS_INIT_MEM \
    +define+IVCS_FAST_FUNC \
    +define+TARGET_CV64A6_IMAFDCSCLIC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_GATE \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/.bender/git/checkouts/axi-ecdc900686449c15/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_llc-5fb8850caad4fcfa/include" \
    "+incdir+$ROOT/.bender/git/checkouts/axi_rt-7cef46f372eaf0fb/include" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-7f7ae0f5e6bf7fb5/include" \
    "+incdir+$ROOT/.bender/git/checkouts/idma-77bf7fa56d324e6a/src/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-902ad5bfde7bb98c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/serial_link-6e09ea4800bad616/src/axis/include" \
    "+incdir+$ROOT/hw/include" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/working_dir/cell_model/GF22FDX_SC8T_104CPP_BASE_CSC20SL.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/working_dir/cell_model/GF22FDX_SC8T_104CPP_BASE_CSC20L.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/working_dir/cell_model/GF22FDX_SC8T_104CPP_BASE_CSC24SL.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/working_dir/cell_model/GF22FDX_SC8T_104CPP_BASE_CSC24L.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/working_dir/cell_model/GF22FDX_SC8T_104CPP_BASE_CSC28SL.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/working_dir/cell_model/GF22FDX_SC8T_104CPP_BASE_CSC28L.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cheshire/working_dir/cell_model/prim.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B021M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B023M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B027M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B044M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B045M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B046M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B049M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B128M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B136M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00256B144M02C256.v" \
    "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/gf22/sourcecode/mems/model/verilog/IN22FDX_R1PH_NFHN_W00512B128M02C256.v" \
    "/scratch2/zexifu/cheshire_try_bak/cheshire/working_dir/cell_model/GF22FDX_SC8T_104CPP_HPK_CSL.v" \
    "CHANGEME_NETLIST" \
}]} {return 1}

vlog "/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cheshire/target/sim/src/elfloader.cpp" -ccflags "-std=c++11"
