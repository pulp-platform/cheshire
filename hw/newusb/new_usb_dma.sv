// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// NewUSB DMA AXI X INIT

module new_usb_dma #(
    /// Data width
    parameter int unsigned DataWidth        = 32'd32,
    /// Address width
    parameter int unsigned AddrWidth        = 32'd32,
    /// AXI user width
    parameter int unsigned UserWidth        = 32'd1,
    /// AXI ID width
    parameter int unsigned AxiIdWidth       = 32'd1,
    /// Width of a transfer: max transfer size is `2**TFLenWidth` bytes
    parameter int unsigned TFLenWidth       = 32'd8, // or 7?
    /// AXI A channel type
    parameter type axi_a_chan_t       = logic,
    /// AXI request struct type.
    parameter type axi_req_t          = logic,
    /// AXI response struct type.
    parameter type axi_rsp_t          = logic,
    /// *NOT OVERWRITE*: Address type
    parameter type addr_t             = logic [AddrWidth-1:0],
    /// *NOT OVERWRITE*: Data type
    parameter type data_t             = logic [DataWidth-1:0],
    /// *NOT OVERWRITE*: Length type
    parameter type tf_len_t           = logic [TFLenWidth-1:0]
)(
    input  logic     clk_i,
    input  logic     rst_ni,
    /// Request channel
    input  addr_t    src_addr_i,
    input  tf_len_t  num_bytes_i,
    input  logic     req_valid_i,
    output logic     req_ready_o,
    /// Response
    output logic     transfer_done_o,
    /// AXI read port
    output axi_req_t axil_read_req_o,
    input  axi_rsp_t axil_read_rsp_i,
    /// FIFO interface
    output data_t    fifo_data_o,
    output logic     fifo_valid_o,
    input  logic     fifo_ready_i,
    // Status
    output logic     busy_o
);

    // Dependent parameter
    localparam int unsigned StrbWidth = DataWidth / 32'd8;

    // Dependent types
    typedef logic [StrbWidth-1:0]   strb_t;
    typedef logic [UserWidth-1:0]   user_t;
    typedef logic [AxiIdWidth-1:0]  id_t;

    /// Init read request
    typedef struct packed {
        addr_t  cfg;
        data_t  term;
        strb_t  strb;
        id_t    id;
    } init_req_chan_t;

    typedef struct packed {
        init_req_chan_t req_chan;
        logic           req_valid;
        logic           rsp_ready;
    } init_req_t;

    typedef struct packed {
        logic [DataWidth-1:0] init;
    } init_rsp_chan_t;

    typedef struct packed {
        init_rsp_chan_t rsp_chan;
        logic           rsp_valid;
        logic           req_ready;
    } init_rsp_t;

    // Meta Channel Widths
    localparam int unsigned init_req_chan_width = $bits(init_req_chan_t);
    localparam int unsigned axil_a_chan_width = $bits(axil_a_chan_t);

    // iDMA request / response types
    `IDMA_TYPEDEF_FULL_REQ_T(idma_req_t, id_t, addr_t, tf_len_t)
    `IDMA_TYPEDEF_FULL_RSP_T(idma_rsp_t, addr_t)

    // Meta channels //Todo: read write?
    typedef struct packed {
        axil_a_chan_t a_chan;
    } axil_read_meta_channel_t;

    typedef struct packed {
        axil_read_meta_channel_t axil;
    } read_meta_channel_t;

    typedef struct packed {
        init_req_chan_t req_chan;
    } init_write_meta_channel_t;

    typedef struct packed {
        init_write_meta_channel_t init;
    } write_meta_channel_t;

    // Local Signals
    idma_req_t            idma_req;
    idma_pkg::idma_busy_t idma_busy;
    init_req_t            init_write_req;
    init_rsp_t            init_write_rsp;


    // Construct Request
    always_comb begin : proc_assign_request
        idma_req                  = '0;
        idma_req.length           = num_bytes_i;
        idma_req.src_addr         = src_addr_i;
        idma_req.opt.src_protocol = idma_pkg::AXI_LITE;
        idma_req.opt.dst_protocol = idma_pkg::INIT;
    end

    // Connect FIFO interface
    assign fifo_data_o  = init_write_req.req_chan.term;
    assign fifo_valid_o = init_write_req.req_valid;

    assign init_write_rsp.rsp_chan.init = '0;
    assign init_write_rsp.rsp_valid     = 1'b1;
    assign init_write_rsp.req_ready     = fifo_ready_i;

    // Connect busy signals
    assign busy_o = |idma_busy;

    // DMA
    idma_backend_rw_axil_rw_init #(
        .CombinedShifter      ( 1'b0                        ),
        .DataWidth            ( DataWidth                   ),
        .AddrWidth            ( AddrWidth                   ),
        .AxiIdWidth           ( AxiIdWidth                  ),
        .UserWidth            ( UserWidth                   ),
        .TFLenWidth           ( TFLenWidth                  ), // 7 or 8?
        .MaskInvalidData      ( 1'b1                        ),
        .BufferDepth          ( 32'd3                       ), // what is misaligned?
        .RAWCouplingAvail     ( 1'b0                        ),
        .HardwareLegalizer    ( 1'b1                        ),
        .RejectZeroTransfers  ( 1'b1                        ),
        .ErrorCap             ( idma_pkg::NO_ERROR_HANDLING ),
        .PrintFifoInfo        ( 1'b0                        ),
        .NumAxInFlight        ( 32'd2                       ), // How many?
        .MemSysDepth          ( 32'd0                       ),
        .idma_req_t           ( idma_req_t                  ),
        .idma_rsp_t           ( idma_rsp_t                  ),
        .idma_eh_req_t        ( idma_pkg::idma_eh_req_t     ),
        .idma_busy_t          ( idma_pkg::idma_busy_t       ),
        .init_req_t           ( init_req_t                  ),
        .init_rsp_t           ( init_rsp_t                  ),
        .axil_req_t           ( axil_req_t                  ),
        .axil_rsp_t           ( axil_rsp_t                  ),
        .write_meta_channel_t ( write_meta_channel_t        ),
        .read_meta_channel_t  ( read_meta_channel_t         )
    ) i_idma_backend  (
        .clk_i,
        .rst_ni,
        .testmode_i       ( 1'b0                ),
        .idma_req_i       ( idma_req            ),
        .req_valid_i      ( req_valid_i         ),
        .req_ready_o      ( req_ready_o         ),
        .idma_rsp_o       ( /* NOT CONNECTED */ ),
        .rsp_valid_o      ( transfer_done_o     ),
        .rsp_ready_i      ( 1'b1                ),
        .idma_eh_req_i    (  '0                 ),
        .eh_req_valid_i   ( 1'b0                ), // What is this?
        .eh_req_ready_o   ( /* NOT CONNECTED */ ),
        .axil_read_req_o  ( axil_read_req_o     ), // Todo: connect to write axil with JOIN
        .axil_read_rsp_i  ( axil_read_rsp_i     ), // Todo: connect to write axil with JOIN
        .init_read_req_o  ( xxxxxxx_o           ), // Todo
        .init_read_rsp_i  ( xxxxxxx_i           ), // Todo
        .axil_write_req_o ( xxxxxxx_x           ), // Todo
        .axil_write_rsp_i ( xxxxxxx_x           ), // Todo
        .init_write_req_o ( init_write_req      ),
        .init_write_rsp_i ( init_write_rsp      ),
        .busy_o           ( idma_busy           )
    );

    idma_backend_rw_axil_rw_init #(
        /// Data width
        parameter int unsigned DataWidth        = 32'd16,
        /// Address width
        parameter int unsigned AddrWidth        = 32'd24,
        /// AXI user width
        parameter int unsigned UserWidth        = 32'd1,
        /// AXI ID width
        parameter int unsigned AxiIdWidth       = 32'd1,
        /// Number of transaction that can be in-flight concurrently
        parameter int unsigned NumAxInFlight    = 32'd2,
        /// The depth of the internal reorder buffer:
        /// - '2': minimal possible configuration
        /// - '3': efficiently handle misaligned transfers (recommended)
        parameter int unsigned BufferDepth      = 32'd2,
        /// With of a transfer: max transfer size is `2**TFLenWidth` bytes
        parameter int unsigned TFLenWidth       = 32'd24,
        /// The depth of the memory system the backend is attached to
        parameter int unsigned MemSysDepth      = 32'd0,
        /// Should both data shifts be done before the dataflow element?
        /// If this is enabled, then the data inserted into the dataflow element
        /// will no longer be word aligned, but only a single shifter is needed
        parameter bit          CombinedShifter  = 1'b0,
        /// Should the `R`-`AW` coupling hardware be present? (recommended)
        parameter bit          RAWCouplingAvail = 1'b0,
        /// Mask invalid data on the manager interface
        parameter bit MaskInvalidData            = 1'b1,
        /// Should hardware legalization be present? (recommended)
        /// If not, software legalization is required to ensure the transfers are
        /// AXI4-conformal
        parameter bit HardwareLegalizer          = 1'b1,
        /// Reject zero-length transfers
        parameter bit RejectZeroTransfers        = 1'b1,
        /// Should the error handler be present?
        parameter idma_pkg::error_cap_e ErrorCap = idma_pkg::NO_ERROR_HANDLING,
        /// Print the info of the FIFO configuration
        parameter bit PrintFifoInfo              = 1'b0,
        /// 1D iDMA request type
        parameter type idma_req_t                = logic,
        /// iDMA response type
        parameter type idma_rsp_t                = logic,
        /// Error Handler request type
        parameter type idma_eh_req_t             = logic,
        /// iDMA busy signal
        parameter type idma_busy_t               = logic,
        /// AXI-Lite Request and Response channel type
        parameter type axil_req_t = logic,
        parameter type axil_rsp_t = logic,
        /// Memory Init Request and Response channel type
        parameter type init_req_t = logic,
        parameter type init_rsp_t = logic,
        /// Address Read Channel type
        parameter type read_meta_channel_t  = logic,
        /// Address Write Channel type
        parameter type write_meta_channel_t = logic,
        /// Strobe Width (do not override!)
        parameter int unsigned StrbWidth    = DataWidth / 8,
        /// Offset Width (do not override!)
        parameter int unsigned OffsetWidth  = $clog2(StrbWidth)
    ) i_idma_backend (
        /// Clock
        input  logic clk_i,
        /// Asynchronous reset, active low
        input  logic rst_ni,
        /// Testmode in
        input  logic testmode_i,

        /// 1D iDMA request
        input  idma_req_t idma_req_i,
        /// 1D iDMA request valid
        input  logic req_valid_i,
        /// 1D iDMA request ready
        output logic req_ready_o,

        /// iDMA response
        output idma_rsp_t idma_rsp_o,
        /// iDMA response valid
        output logic rsp_valid_o,
        /// iDMA response ready
        input  logic rsp_ready_i,

        /// Error handler request
        input  idma_eh_req_t idma_eh_req_i,
        /// Error handler request valid
        input  logic eh_req_valid_i,
        /// Error handler request ready
        output logic eh_req_ready_o,

        /// AXI-Lite read request
        output axil_req_t axil_read_req_o,
        /// AXI-Lite read response
        input  axil_rsp_t axil_read_rsp_i,
        
        /// Memory Init read request
        output init_req_t init_read_req_o,
        /// Memory Init read response
        input  init_rsp_t init_read_rsp_i,
        
        /// AXI-Lite write request
        output axil_req_t axil_write_req_o,
        /// AXI-Lite write response
        input  axil_rsp_t axil_write_rsp_i,
        
        /// Memory Init write request
        output init_req_t init_write_req_o,
        /// Memory Init write response
        input  init_rsp_t init_write_rsp_i,
        
        /// iDMA busy flags
        output idma_busy_t busy_o
);

endmodule