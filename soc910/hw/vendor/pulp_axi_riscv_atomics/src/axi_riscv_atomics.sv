// Copyright (c) 2018 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// AXI RISC-V Atomics ("A" Extension) Adapter
//
// This AXI adapter implements the RISC-V "A" extension and adheres to the RVWMO memory consistency
// model.
//
// Maintainer: Andreas Kurth <akurth@iis.ee.ethz.ch>

module axi_riscv_atomics
  `include "axi/typedef.svh"
#(
    /// AXI Parameters
    parameter int unsigned AXI_ADDR_WIDTH = 0,
    parameter int unsigned AXI_DATA_WIDTH = 0,
    parameter int unsigned AXI_ID_WIDTH = 0,
    parameter int unsigned AXI_USER_WIDTH = 0,
    // Maximum number of AXI read bursts outstanding at the same time
    parameter int unsigned AXI_MAX_READ_TXNS = 0,
    // Maximum number of AXI write bursts outstanding at the same time
    parameter int unsigned AXI_MAX_WRITE_TXNS = 0,
    // Use the AXI User signal instead of the AXI ID to track reservations
    parameter bit AXI_USER_AS_ID = 1'b0,
    // MSB of the ID in the user signal
    parameter int unsigned AXI_USER_ID_MSB = 0,
    // LSB of the ID in the user signal
    parameter int unsigned AXI_USER_ID_LSB = 0,
    // Word width of the widest RISC-V processor that can issue requests to this module.
    // 32 for RV32; 64 for RV64, where both 32-bit (.W suffix) and 64-bit (.D suffix) AMOs are
    // supported if `aw_strb` is set correctly.
    parameter int unsigned RISCV_WORD_WIDTH = 0,
    // Add a cut between axi_riscv_amos and axi_riscv_lrsc
    parameter int unsigned N_AXI_CUT = 0,
    /// Derived Parameters (do NOT change manually!)
    localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8
) (
    input logic                         clk_i,
    input logic                         rst_ni,

    /// Slave Interface
    input  logic [AXI_ADDR_WIDTH-1:0]   slv_aw_addr_i,
    input  logic [2:0]                  slv_aw_prot_i,
    input  logic [3:0]                  slv_aw_region_i,
    input  logic [5:0]                  slv_aw_atop_i,
    input  logic [7:0]                  slv_aw_len_i,
    input  logic [2:0]                  slv_aw_size_i,
    input  logic [1:0]                  slv_aw_burst_i,
    input  logic                        slv_aw_lock_i,
    input  logic [3:0]                  slv_aw_cache_i,
    input  logic [3:0]                  slv_aw_qos_i,
    input  logic [AXI_ID_WIDTH-1:0]     slv_aw_id_i,
    input  logic [AXI_USER_WIDTH-1:0]   slv_aw_user_i,
    output logic                        slv_aw_ready_o,
    input  logic                        slv_aw_valid_i,

    input  logic [AXI_ADDR_WIDTH-1:0]   slv_ar_addr_i,
    input  logic [2:0]                  slv_ar_prot_i,
    input  logic [3:0]                  slv_ar_region_i,
    input  logic [7:0]                  slv_ar_len_i,
    input  logic [2:0]                  slv_ar_size_i,
    input  logic [1:0]                  slv_ar_burst_i,
    input  logic                        slv_ar_lock_i,
    input  logic [3:0]                  slv_ar_cache_i,
    input  logic [3:0]                  slv_ar_qos_i,
    input  logic [AXI_ID_WIDTH-1:0]     slv_ar_id_i,
    input  logic [AXI_USER_WIDTH-1:0]   slv_ar_user_i,
    output logic                        slv_ar_ready_o,
    input  logic                        slv_ar_valid_i,

    input  logic [AXI_DATA_WIDTH-1:0]   slv_w_data_i,
    input  logic [AXI_STRB_WIDTH-1:0]   slv_w_strb_i,
    input  logic [AXI_USER_WIDTH-1:0]   slv_w_user_i,
    input  logic                        slv_w_last_i,
    output logic                        slv_w_ready_o,
    input  logic                        slv_w_valid_i,

    output logic [AXI_DATA_WIDTH-1:0]   slv_r_data_o,
    output logic [1:0]                  slv_r_resp_o,
    output logic                        slv_r_last_o,
    output logic [AXI_ID_WIDTH-1:0]     slv_r_id_o,
    output logic [AXI_USER_WIDTH-1:0]   slv_r_user_o,
    input  logic                        slv_r_ready_i,
    output logic                        slv_r_valid_o,

    output logic [1:0]                  slv_b_resp_o,
    output logic [AXI_ID_WIDTH-1:0]     slv_b_id_o,
    output logic [AXI_USER_WIDTH-1:0]   slv_b_user_o,
    input  logic                        slv_b_ready_i,
    output logic                        slv_b_valid_o,

    /// Master Interface
    output logic [AXI_ADDR_WIDTH-1:0]   mst_aw_addr_o,
    output logic [2:0]                  mst_aw_prot_o,
    output logic [3:0]                  mst_aw_region_o,
    output logic [5:0]                  mst_aw_atop_o,
    output logic [7:0]                  mst_aw_len_o,
    output logic [2:0]                  mst_aw_size_o,
    output logic [1:0]                  mst_aw_burst_o,
    output logic                        mst_aw_lock_o,
    output logic [3:0]                  mst_aw_cache_o,
    output logic [3:0]                  mst_aw_qos_o,
    output logic [AXI_ID_WIDTH-1:0]     mst_aw_id_o,
    output logic [AXI_USER_WIDTH-1:0]   mst_aw_user_o,
    input  logic                        mst_aw_ready_i,
    output logic                        mst_aw_valid_o,

    output logic [AXI_ADDR_WIDTH-1:0]   mst_ar_addr_o,
    output logic [2:0]                  mst_ar_prot_o,
    output logic [3:0]                  mst_ar_region_o,
    output logic [7:0]                  mst_ar_len_o,
    output logic [2:0]                  mst_ar_size_o,
    output logic [1:0]                  mst_ar_burst_o,
    output logic                        mst_ar_lock_o,
    output logic [3:0]                  mst_ar_cache_o,
    output logic [3:0]                  mst_ar_qos_o,
    output logic [AXI_ID_WIDTH-1:0]     mst_ar_id_o,
    output logic [AXI_USER_WIDTH-1:0]   mst_ar_user_o,
    input  logic                        mst_ar_ready_i,
    output logic                        mst_ar_valid_o,

    output logic [AXI_DATA_WIDTH-1:0]   mst_w_data_o,
    output logic [AXI_STRB_WIDTH-1:0]   mst_w_strb_o,
    output logic [AXI_USER_WIDTH-1:0]   mst_w_user_o,
    output logic                        mst_w_last_o,
    input  logic                        mst_w_ready_i,
    output logic                        mst_w_valid_o,

    input  logic [AXI_DATA_WIDTH-1:0]   mst_r_data_i,
    input  logic [1:0]                  mst_r_resp_i,
    input  logic                        mst_r_last_i,
    input  logic [AXI_ID_WIDTH-1:0]     mst_r_id_i,
    input  logic [AXI_USER_WIDTH-1:0]   mst_r_user_i,
    output logic                        mst_r_ready_o,
    input  logic                        mst_r_valid_i,

    input  logic [1:0]                  mst_b_resp_i,
    input  logic [AXI_ID_WIDTH-1:0]     mst_b_id_i,
    input  logic [AXI_USER_WIDTH-1:0]   mst_b_user_i,
    output logic                        mst_b_ready_o,
    input  logic                        mst_b_valid_i
);

    // Make the entire address range exclusively accessible. Since the AMO adapter does not support
    // address ranges, it would not make sense to expose the address range as a parameter of this
    // module.
    localparam longint unsigned ADDR_BEGIN  = '0;
    localparam longint unsigned ADDR_END    = {AXI_ADDR_WIDTH{1'b1}};

    `AXI_TYPEDEF_ALL(int_axi, logic [AXI_ADDR_WIDTH-1:0], logic [AXI_ID_WIDTH-1:0], logic [AXI_DATA_WIDTH-1:0], logic [AXI_STRB_WIDTH-1:0], logic [AXI_USER_WIDTH-1:0])

    int_axi_req_t int_axi_req, int_axi_cut_req;
    int_axi_resp_t int_axi_rsp, int_axi_cut_rsp;

    logic [AXI_ADDR_WIDTH-1:0]   int_axi_aw_addr;
    logic [2:0]                  int_axi_aw_prot;
    logic [3:0]                  int_axi_aw_region;
    logic [5:0]                  int_axi_aw_atop;
    logic [7:0]                  int_axi_aw_len;
    logic [2:0]                  int_axi_aw_size;
    logic [1:0]                  int_axi_aw_burst;
    logic                        int_axi_aw_lock;
    logic [3:0]                  int_axi_aw_cache;
    logic [3:0]                  int_axi_aw_qos;
    logic [AXI_ID_WIDTH-1:0]     int_axi_aw_id;
    logic [AXI_USER_WIDTH-1:0]   int_axi_aw_user;
    logic                        int_axi_aw_ready;
    logic                        int_axi_aw_valid;

    logic [AXI_ADDR_WIDTH-1:0]   int_axi_ar_addr;
    logic [2:0]                  int_axi_ar_prot;
    logic [3:0]                  int_axi_ar_region;
    logic [7:0]                  int_axi_ar_len;
    logic [2:0]                  int_axi_ar_size;
    logic [1:0]                  int_axi_ar_burst;
    logic                        int_axi_ar_lock;
    logic [3:0]                  int_axi_ar_cache;
    logic [3:0]                  int_axi_ar_qos;
    logic [AXI_ID_WIDTH-1:0]     int_axi_ar_id;
    logic [AXI_USER_WIDTH-1:0]   int_axi_ar_user;
    logic                        int_axi_ar_ready;
    logic                        int_axi_ar_valid;

    logic [AXI_DATA_WIDTH-1:0]   int_axi_w_data;
    logic [AXI_STRB_WIDTH-1:0]   int_axi_w_strb;
    logic [AXI_USER_WIDTH-1:0]   int_axi_w_user;
    logic                        int_axi_w_last;
    logic                        int_axi_w_ready;
    logic                        int_axi_w_valid;

    logic [AXI_DATA_WIDTH-1:0]   int_axi_r_data;
    logic [1:0]                  int_axi_r_resp;
    logic                        int_axi_r_last;
    logic [AXI_ID_WIDTH-1:0]     int_axi_r_id;
    logic [AXI_USER_WIDTH-1:0]   int_axi_r_user;
    logic                        int_axi_r_ready;
    logic                        int_axi_r_valid;

    logic [1:0]                  int_axi_b_resp;
    logic [AXI_ID_WIDTH-1:0]     int_axi_b_id;
    logic [AXI_USER_WIDTH-1:0]   int_axi_b_user;
    logic                        int_axi_b_ready;
    logic                        int_axi_b_valid;

    logic [AXI_ADDR_WIDTH-1:0]   int_axi_cut_aw_addr;
    logic [2:0]                  int_axi_cut_aw_prot;
    logic [3:0]                  int_axi_cut_aw_region;
    logic [5:0]                  int_axi_cut_aw_atop;
    logic [7:0]                  int_axi_cut_aw_len;
    logic [2:0]                  int_axi_cut_aw_size;
    logic [1:0]                  int_axi_cut_aw_burst;
    logic                        int_axi_cut_aw_lock;
    logic [3:0]                  int_axi_cut_aw_cache;
    logic [3:0]                  int_axi_cut_aw_qos;
    logic [AXI_ID_WIDTH-1:0]     int_axi_cut_aw_id;
    logic [AXI_USER_WIDTH-1:0]   int_axi_cut_aw_user;
    logic                        int_axi_cut_aw_ready;
    logic                        int_axi_cut_aw_valid;

    logic [AXI_ADDR_WIDTH-1:0]   int_axi_cut_ar_addr;
    logic [2:0]                  int_axi_cut_ar_prot;
    logic [3:0]                  int_axi_cut_ar_region;
    logic [7:0]                  int_axi_cut_ar_len;
    logic [2:0]                  int_axi_cut_ar_size;
    logic [1:0]                  int_axi_cut_ar_burst;
    logic                        int_axi_cut_ar_lock;
    logic [3:0]                  int_axi_cut_ar_cache;
    logic [3:0]                  int_axi_cut_ar_qos;
    logic [AXI_ID_WIDTH-1:0]     int_axi_cut_ar_id;
    logic [AXI_USER_WIDTH-1:0]   int_axi_cut_ar_user;
    logic                        int_axi_cut_ar_ready;
    logic                        int_axi_cut_ar_valid;

    logic [AXI_DATA_WIDTH-1:0]   int_axi_cut_w_data;
    logic [AXI_STRB_WIDTH-1:0]   int_axi_cut_w_strb;
    logic [AXI_USER_WIDTH-1:0]   int_axi_cut_w_user;
    logic                        int_axi_cut_w_last;
    logic                        int_axi_cut_w_ready;
    logic                        int_axi_cut_w_valid;

    logic [AXI_DATA_WIDTH-1:0]   int_axi_cut_r_data;
    logic [1:0]                  int_axi_cut_r_resp;
    logic                        int_axi_cut_r_last;
    logic [AXI_ID_WIDTH-1:0]     int_axi_cut_r_id;
    logic [AXI_USER_WIDTH-1:0]   int_axi_cut_r_user;
    logic                        int_axi_cut_r_ready;
    logic                        int_axi_cut_r_valid;

    logic [1:0]                  int_axi_cut_b_resp;
    logic [AXI_ID_WIDTH-1:0]     int_axi_cut_b_id;
    logic [AXI_USER_WIDTH-1:0]   int_axi_cut_b_user;
    logic                        int_axi_cut_b_ready;
    logic                        int_axi_cut_b_valid;

    axi_riscv_amos #(
        .AXI_ADDR_WIDTH     (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH     (AXI_DATA_WIDTH),
        .AXI_ID_WIDTH       (AXI_ID_WIDTH),
        .AXI_USER_WIDTH     (AXI_USER_WIDTH),
        .AXI_MAX_WRITE_TXNS (AXI_MAX_WRITE_TXNS),
        .RISCV_WORD_WIDTH   (RISCV_WORD_WIDTH)
    ) i_amos (
        .clk_i              ( clk_i             ),
        .rst_ni             ( rst_ni            ),
        .slv_aw_addr_i      ( slv_aw_addr_i     ),
        .slv_aw_prot_i      ( slv_aw_prot_i     ),
        .slv_aw_region_i    ( slv_aw_region_i   ),
        .slv_aw_atop_i      ( slv_aw_atop_i     ),
        .slv_aw_len_i       ( slv_aw_len_i      ),
        .slv_aw_size_i      ( slv_aw_size_i     ),
        .slv_aw_burst_i     ( slv_aw_burst_i    ),
        .slv_aw_lock_i      ( slv_aw_lock_i     ),
        .slv_aw_cache_i     ( slv_aw_cache_i    ),
        .slv_aw_qos_i       ( slv_aw_qos_i      ),
        .slv_aw_id_i        ( slv_aw_id_i       ),
        .slv_aw_user_i      ( slv_aw_user_i     ),
        .slv_aw_ready_o     ( slv_aw_ready_o    ),
        .slv_aw_valid_i     ( slv_aw_valid_i    ),
        .slv_ar_addr_i      ( slv_ar_addr_i     ),
        .slv_ar_prot_i      ( slv_ar_prot_i     ),
        .slv_ar_region_i    ( slv_ar_region_i   ),
        .slv_ar_len_i       ( slv_ar_len_i      ),
        .slv_ar_size_i      ( slv_ar_size_i     ),
        .slv_ar_burst_i     ( slv_ar_burst_i    ),
        .slv_ar_lock_i      ( slv_ar_lock_i     ),
        .slv_ar_cache_i     ( slv_ar_cache_i    ),
        .slv_ar_qos_i       ( slv_ar_qos_i      ),
        .slv_ar_id_i        ( slv_ar_id_i       ),
        .slv_ar_user_i      ( slv_ar_user_i     ),
        .slv_ar_ready_o     ( slv_ar_ready_o    ),
        .slv_ar_valid_i     ( slv_ar_valid_i    ),
        .slv_w_data_i       ( slv_w_data_i      ),
        .slv_w_strb_i       ( slv_w_strb_i      ),
        .slv_w_user_i       ( slv_w_user_i      ),
        .slv_w_last_i       ( slv_w_last_i      ),
        .slv_w_ready_o      ( slv_w_ready_o     ),
        .slv_w_valid_i      ( slv_w_valid_i     ),
        .slv_r_data_o       ( slv_r_data_o      ),
        .slv_r_resp_o       ( slv_r_resp_o      ),
        .slv_r_last_o       ( slv_r_last_o      ),
        .slv_r_id_o         ( slv_r_id_o        ),
        .slv_r_user_o       ( slv_r_user_o      ),
        .slv_r_ready_i      ( slv_r_ready_i     ),
        .slv_r_valid_o      ( slv_r_valid_o     ),
        .slv_b_resp_o       ( slv_b_resp_o      ),
        .slv_b_id_o         ( slv_b_id_o        ),
        .slv_b_user_o       ( slv_b_user_o      ),
        .slv_b_ready_i      ( slv_b_ready_i     ),
        .slv_b_valid_o      ( slv_b_valid_o     ),
        .mst_aw_addr_o      ( int_axi_aw_addr   ),
        .mst_aw_prot_o      ( int_axi_aw_prot   ),
        .mst_aw_region_o    ( int_axi_aw_region ),
        .mst_aw_atop_o      ( int_axi_aw_atop   ),
        .mst_aw_len_o       ( int_axi_aw_len    ),
        .mst_aw_size_o      ( int_axi_aw_size   ),
        .mst_aw_burst_o     ( int_axi_aw_burst  ),
        .mst_aw_lock_o      ( int_axi_aw_lock   ),
        .mst_aw_cache_o     ( int_axi_aw_cache  ),
        .mst_aw_qos_o       ( int_axi_aw_qos    ),
        .mst_aw_id_o        ( int_axi_aw_id     ),
        .mst_aw_user_o      ( int_axi_aw_user   ),
        .mst_aw_ready_i     ( int_axi_aw_ready  ),
        .mst_aw_valid_o     ( int_axi_aw_valid  ),
        .mst_ar_addr_o      ( int_axi_ar_addr   ),
        .mst_ar_prot_o      ( int_axi_ar_prot   ),
        .mst_ar_region_o    ( int_axi_ar_region ),
        .mst_ar_len_o       ( int_axi_ar_len    ),
        .mst_ar_size_o      ( int_axi_ar_size   ),
        .mst_ar_burst_o     ( int_axi_ar_burst  ),
        .mst_ar_lock_o      ( int_axi_ar_lock   ),
        .mst_ar_cache_o     ( int_axi_ar_cache  ),
        .mst_ar_qos_o       ( int_axi_ar_qos    ),
        .mst_ar_id_o        ( int_axi_ar_id     ),
        .mst_ar_user_o      ( int_axi_ar_user   ),
        .mst_ar_ready_i     ( int_axi_ar_ready  ),
        .mst_ar_valid_o     ( int_axi_ar_valid  ),
        .mst_w_data_o       ( int_axi_w_data    ),
        .mst_w_strb_o       ( int_axi_w_strb    ),
        .mst_w_user_o       ( int_axi_w_user    ),
        .mst_w_last_o       ( int_axi_w_last    ),
        .mst_w_ready_i      ( int_axi_w_ready   ),
        .mst_w_valid_o      ( int_axi_w_valid   ),
        .mst_r_data_i       ( int_axi_r_data    ),
        .mst_r_resp_i       ( int_axi_r_resp    ),
        .mst_r_last_i       ( int_axi_r_last    ),
        .mst_r_id_i         ( int_axi_r_id      ),
        .mst_r_user_i       ( int_axi_r_user    ),
        .mst_r_ready_o      ( int_axi_r_ready   ),
        .mst_r_valid_i      ( int_axi_r_valid   ),
        .mst_b_resp_i       ( int_axi_b_resp    ),
        .mst_b_id_i         ( int_axi_b_id      ),
        .mst_b_user_i       ( int_axi_b_user    ),
        .mst_b_ready_o      ( int_axi_b_ready   ),
        .mst_b_valid_i      ( int_axi_b_valid   )
    );

    assign int_axi_req.aw.addr   = int_axi_aw_addr;
    assign int_axi_req.aw.prot   = int_axi_aw_prot;
    assign int_axi_req.aw.region = int_axi_aw_region;
    assign int_axi_req.aw.atop   = int_axi_aw_atop;
    assign int_axi_req.aw.len    = int_axi_aw_len;
    assign int_axi_req.aw.size   = int_axi_aw_size;
    assign int_axi_req.aw.burst  = int_axi_aw_burst;
    assign int_axi_req.aw.lock   = int_axi_aw_lock;
    assign int_axi_req.aw.cache  = int_axi_aw_cache;
    assign int_axi_req.aw.qos    = int_axi_aw_qos;
    assign int_axi_req.aw.id     = int_axi_aw_id;
    assign int_axi_req.aw.user   = int_axi_aw_user;
    assign int_axi_aw_ready      = int_axi_rsp.aw_ready;
    assign int_axi_req.aw_valid  = int_axi_aw_valid;
    assign int_axi_req.ar.addr   = int_axi_ar_addr;
    assign int_axi_req.ar.prot   = int_axi_ar_prot;
    assign int_axi_req.ar.region = int_axi_ar_region;
    assign int_axi_req.ar.len    = int_axi_ar_len;
    assign int_axi_req.ar.size   = int_axi_ar_size;
    assign int_axi_req.ar.burst  = int_axi_ar_burst;
    assign int_axi_req.ar.lock   = int_axi_ar_lock;
    assign int_axi_req.ar.cache  = int_axi_ar_cache;
    assign int_axi_req.ar.qos    = int_axi_ar_qos;
    assign int_axi_req.ar.id     = int_axi_ar_id;
    assign int_axi_req.ar.user   = int_axi_ar_user;
    assign int_axi_ar_ready      = int_axi_rsp.ar_ready;
    assign int_axi_req.ar_valid  = int_axi_ar_valid;
    assign int_axi_req.w.data    = int_axi_w_data;
    assign int_axi_req.w.strb    = int_axi_w_strb;
    assign int_axi_req.w.user    = int_axi_w_user;
    assign int_axi_req.w.last    = int_axi_w_last;
    assign int_axi_w_ready       = int_axi_rsp.w_ready;
    assign int_axi_req.w_valid   = int_axi_w_valid;
    assign int_axi_r_data        = int_axi_rsp.r.data;
    assign int_axi_r_resp        = int_axi_rsp.r.resp;
    assign int_axi_r_last        = int_axi_rsp.r.last;
    assign int_axi_r_id          = int_axi_rsp.r.id;
    assign int_axi_r_user        = int_axi_rsp.r.user;
    assign int_axi_req.r_ready   = int_axi_r_ready;
    assign int_axi_r_valid       = int_axi_rsp.r_valid;
    assign int_axi_b_resp        = int_axi_rsp.b.resp;
    assign int_axi_b_id          = int_axi_rsp.b.id;
    assign int_axi_b_user        = int_axi_rsp.b.user;
    assign int_axi_req.b_ready   = int_axi_b_ready;
    assign int_axi_b_valid       = int_axi_rsp.b_valid;

    axi_multicut #(
        .NoCuts     ( N_AXI_CUT         ),
        .aw_chan_t  ( int_axi_aw_chan_t ),
        .w_chan_t   ( int_axi_w_chan_t  ),
        .b_chan_t   ( int_axi_b_chan_t  ),
        .ar_chan_t  ( int_axi_ar_chan_t ),
        .r_chan_t   ( int_axi_r_chan_t  ),
        .axi_req_t  ( int_axi_req_t     ),
        .axi_resp_t ( int_axi_resp_t    )
    ) i_axi_wide_in_cut (
        .clk_i      ( clk_i           ),
        .rst_ni     ( rst_ni          ),
        .slv_req_i  ( int_axi_req     ),
        .slv_resp_o ( int_axi_rsp     ),
        .mst_req_o  ( int_axi_cut_req ),
        .mst_resp_i ( int_axi_cut_rsp )
    );

    assign int_axi_cut_aw_addr   = int_axi_cut_req.aw.addr;
    assign int_axi_cut_aw_prot   = int_axi_cut_req.aw.prot;
    assign int_axi_cut_aw_region = int_axi_cut_req.aw.region;
    assign int_axi_cut_aw_atop   = int_axi_cut_req.aw.atop;
    assign int_axi_cut_aw_len    = int_axi_cut_req.aw.len;
    assign int_axi_cut_aw_size   = int_axi_cut_req.aw.size;
    assign int_axi_cut_aw_burst  = int_axi_cut_req.aw.burst;
    assign int_axi_cut_aw_lock   = int_axi_cut_req.aw.lock;
    assign int_axi_cut_aw_cache  = int_axi_cut_req.aw.cache;
    assign int_axi_cut_aw_qos    = int_axi_cut_req.aw.qos;
    assign int_axi_cut_aw_id     = int_axi_cut_req.aw.id;
    assign int_axi_cut_aw_user   = int_axi_cut_req.aw.user;
    assign int_axi_cut_rsp.aw_ready = int_axi_cut_aw_ready;
    assign int_axi_cut_aw_valid  = int_axi_cut_req.aw_valid;
    assign int_axi_cut_ar_addr   = int_axi_cut_req.ar.addr;
    assign int_axi_cut_ar_prot   = int_axi_cut_req.ar.prot;
    assign int_axi_cut_ar_region = int_axi_cut_req.ar.region;
    assign int_axi_cut_ar_len    = int_axi_cut_req.ar.len;
    assign int_axi_cut_ar_size   = int_axi_cut_req.ar.size;
    assign int_axi_cut_ar_burst  = int_axi_cut_req.ar.burst;
    assign int_axi_cut_ar_lock   = int_axi_cut_req.ar.lock;
    assign int_axi_cut_ar_cache  = int_axi_cut_req.ar.cache;
    assign int_axi_cut_ar_qos    = int_axi_cut_req.ar.qos;
    assign int_axi_cut_ar_id     = int_axi_cut_req.ar.id;
    assign int_axi_cut_ar_user   = int_axi_cut_req.ar.user;
    assign int_axi_cut_rsp.ar_ready = int_axi_cut_ar_ready;
    assign int_axi_cut_ar_valid  = int_axi_cut_req.ar_valid;
    assign int_axi_cut_w_data    = int_axi_cut_req.w.data;
    assign int_axi_cut_w_strb    = int_axi_cut_req.w.strb;
    assign int_axi_cut_w_user    = int_axi_cut_req.w.user;
    assign int_axi_cut_w_last    = int_axi_cut_req.w.last;
    assign int_axi_cut_rsp.w_ready = int_axi_cut_w_ready;
    assign int_axi_cut_w_valid   = int_axi_cut_req.w_valid;

    assign int_axi_cut_rsp.r.data  = int_axi_cut_r_data;
    assign int_axi_cut_rsp.r.resp  = int_axi_cut_r_resp;
    assign int_axi_cut_rsp.r.last  = int_axi_cut_r_last;
    assign int_axi_cut_rsp.r.id    = int_axi_cut_r_id;
    assign int_axi_cut_rsp.r.user  = int_axi_cut_r_user;
    assign int_axi_cut_r_ready     = int_axi_cut_req.r_ready;
    assign int_axi_cut_rsp.r_valid = int_axi_cut_r_valid;

    assign int_axi_cut_rsp.b.resp  = int_axi_cut_b_resp;
    assign int_axi_cut_rsp.b.id    = int_axi_cut_b_id;
    assign int_axi_cut_rsp.b.user  = int_axi_cut_b_user;
    assign int_axi_cut_b_ready     = int_axi_cut_req.b_ready;
    assign int_axi_cut_rsp.b_valid = int_axi_cut_b_valid;

    axi_riscv_lrsc #(
        .ADDR_BEGIN         (ADDR_BEGIN),
        .ADDR_END           (ADDR_END),
        .AXI_ADDR_WIDTH     (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH     (AXI_DATA_WIDTH),
        .AXI_ID_WIDTH       (AXI_ID_WIDTH),
        .AXI_USER_WIDTH     (AXI_USER_WIDTH),
        .AXI_MAX_READ_TXNS  (AXI_MAX_READ_TXNS),
        .AXI_MAX_WRITE_TXNS (AXI_MAX_WRITE_TXNS),
        .AXI_USER_AS_ID     (AXI_USER_AS_ID),
        .AXI_USER_ID_MSB    (AXI_USER_ID_MSB),
        .AXI_USER_ID_LSB    (AXI_USER_ID_LSB)
    ) i_lrsc (
        .clk_i              ( clk_i                 ),
        .rst_ni             ( rst_ni                ),
        .slv_aw_addr_i      ( int_axi_cut_aw_addr   ),
        .slv_aw_prot_i      ( int_axi_cut_aw_prot   ),
        .slv_aw_region_i    ( int_axi_cut_aw_region ),
        .slv_aw_atop_i      ( int_axi_cut_aw_atop   ),
        .slv_aw_len_i       ( int_axi_cut_aw_len    ),
        .slv_aw_size_i      ( int_axi_cut_aw_size   ),
        .slv_aw_burst_i     ( int_axi_cut_aw_burst  ),
        .slv_aw_lock_i      ( int_axi_cut_aw_lock   ),
        .slv_aw_cache_i     ( int_axi_cut_aw_cache  ),
        .slv_aw_qos_i       ( int_axi_cut_aw_qos    ),
        .slv_aw_id_i        ( int_axi_cut_aw_id     ),
        .slv_aw_user_i      ( int_axi_cut_aw_user   ),
        .slv_aw_ready_o     ( int_axi_cut_aw_ready  ),
        .slv_aw_valid_i     ( int_axi_cut_aw_valid  ),
        .slv_ar_addr_i      ( int_axi_cut_ar_addr   ),
        .slv_ar_prot_i      ( int_axi_cut_ar_prot   ),
        .slv_ar_region_i    ( int_axi_cut_ar_region ),
        .slv_ar_len_i       ( int_axi_cut_ar_len    ),
        .slv_ar_size_i      ( int_axi_cut_ar_size   ),
        .slv_ar_burst_i     ( int_axi_cut_ar_burst  ),
        .slv_ar_lock_i      ( int_axi_cut_ar_lock   ),
        .slv_ar_cache_i     ( int_axi_cut_ar_cache  ),
        .slv_ar_qos_i       ( int_axi_cut_ar_qos    ),
        .slv_ar_id_i        ( int_axi_cut_ar_id     ),
        .slv_ar_user_i      ( int_axi_cut_ar_user   ),
        .slv_ar_ready_o     ( int_axi_cut_ar_ready  ),
        .slv_ar_valid_i     ( int_axi_cut_ar_valid  ),
        .slv_w_data_i       ( int_axi_cut_w_data    ),
        .slv_w_strb_i       ( int_axi_cut_w_strb    ),
        .slv_w_user_i       ( int_axi_cut_w_user    ),
        .slv_w_last_i       ( int_axi_cut_w_last    ),
        .slv_w_ready_o      ( int_axi_cut_w_ready   ),
        .slv_w_valid_i      ( int_axi_cut_w_valid   ),
        .slv_r_data_o       ( int_axi_cut_r_data    ),
        .slv_r_resp_o       ( int_axi_cut_r_resp    ),
        .slv_r_last_o       ( int_axi_cut_r_last    ),
        .slv_r_id_o         ( int_axi_cut_r_id      ),
        .slv_r_user_o       ( int_axi_cut_r_user    ),
        .slv_r_ready_i      ( int_axi_cut_r_ready   ),
        .slv_r_valid_o      ( int_axi_cut_r_valid   ),
        .slv_b_resp_o       ( int_axi_cut_b_resp    ),
        .slv_b_id_o         ( int_axi_cut_b_id      ),
        .slv_b_user_o       ( int_axi_cut_b_user    ),
        .slv_b_ready_i      ( int_axi_cut_b_ready   ),
        .slv_b_valid_o      ( int_axi_cut_b_valid   ),
        .mst_aw_addr_o      ( mst_aw_addr_o         ),
        .mst_aw_prot_o      ( mst_aw_prot_o         ),
        .mst_aw_region_o    ( mst_aw_region_o       ),
        .mst_aw_atop_o      ( mst_aw_atop_o         ),
        .mst_aw_len_o       ( mst_aw_len_o          ),
        .mst_aw_size_o      ( mst_aw_size_o         ),
        .mst_aw_burst_o     ( mst_aw_burst_o        ),
        .mst_aw_lock_o      ( mst_aw_lock_o         ),
        .mst_aw_cache_o     ( mst_aw_cache_o        ),
        .mst_aw_qos_o       ( mst_aw_qos_o          ),
        .mst_aw_id_o        ( mst_aw_id_o           ),
        .mst_aw_user_o      ( mst_aw_user_o         ),
        .mst_aw_ready_i     ( mst_aw_ready_i        ),
        .mst_aw_valid_o     ( mst_aw_valid_o        ),
        .mst_ar_addr_o      ( mst_ar_addr_o         ),
        .mst_ar_prot_o      ( mst_ar_prot_o         ),
        .mst_ar_region_o    ( mst_ar_region_o       ),
        .mst_ar_len_o       ( mst_ar_len_o          ),
        .mst_ar_size_o      ( mst_ar_size_o         ),
        .mst_ar_burst_o     ( mst_ar_burst_o        ),
        .mst_ar_lock_o      ( mst_ar_lock_o         ),
        .mst_ar_cache_o     ( mst_ar_cache_o        ),
        .mst_ar_qos_o       ( mst_ar_qos_o          ),
        .mst_ar_id_o        ( mst_ar_id_o           ),
        .mst_ar_user_o      ( mst_ar_user_o         ),
        .mst_ar_ready_i     ( mst_ar_ready_i        ),
        .mst_ar_valid_o     ( mst_ar_valid_o        ),
        .mst_w_data_o       ( mst_w_data_o          ),
        .mst_w_strb_o       ( mst_w_strb_o          ),
        .mst_w_user_o       ( mst_w_user_o          ),
        .mst_w_last_o       ( mst_w_last_o          ),
        .mst_w_ready_i      ( mst_w_ready_i         ),
        .mst_w_valid_o      ( mst_w_valid_o         ),
        .mst_r_data_i       ( mst_r_data_i          ),
        .mst_r_resp_i       ( mst_r_resp_i          ),
        .mst_r_last_i       ( mst_r_last_i          ),
        .mst_r_id_i         ( mst_r_id_i            ),
        .mst_r_user_i       ( mst_r_user_i          ),
        .mst_r_ready_o      ( mst_r_ready_o         ),
        .mst_r_valid_i      ( mst_r_valid_i         ),
        .mst_b_resp_i       ( mst_b_resp_i          ),
        .mst_b_id_i         ( mst_b_id_i            ),
        .mst_b_user_i       ( mst_b_user_i          ),
        .mst_b_ready_o      ( mst_b_ready_o         ),
        .mst_b_valid_i      ( mst_b_valid_i         )
    );

endmodule
