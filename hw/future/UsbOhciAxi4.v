// MIT License

// Copyright (c) 2016 Spinal HDL contributors

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// ------
// The Verilog RTL below this comment block was generated using the SpinalHDL
// library (licensed under the permissive MIT license above) available here:
//
// https://github.com/SpinalHDL/SpinalHDL
//
// The following file from the SpinalHDL library was used for generation (the
// generator version and git commit are specified in the generated output):
//
// lib/src/main/scala/spinal/lib/com/usb/ohci/UsbOhciAxi4.scala
// sbt> lib/runMain spinal.lib.com.usb.ohci.UsbOhciAxi4 \
//        --port-count=4 --dma-width=32 --fifo-bytes=1088
// ------
// Generator : SpinalHDL dev    git head : ed2ae179904c1c6421617f443c92966db416c54d
// Component : UsbOhciAxi4
// Git hash  : ed2ae179904c1c6421617f443c92966db416c54d

// `timescale 1ns/1ps

module UsbOhciAxi4 (
  output wire          io_dma_aw_valid,
  input  wire          io_dma_aw_ready,
  output wire [31:0]   io_dma_aw_payload_addr,
  output wire [7:0]    io_dma_aw_payload_len,
  output wire [2:0]    io_dma_aw_payload_size,
  output wire [3:0]    io_dma_aw_payload_cache,
  output wire [2:0]    io_dma_aw_payload_prot,
  output wire          io_dma_w_valid,
  input  wire          io_dma_w_ready,
  output wire [31:0]   io_dma_w_payload_data,
  output wire [3:0]    io_dma_w_payload_strb,
  output wire          io_dma_w_payload_last,
  input  wire          io_dma_b_valid,
  output wire          io_dma_b_ready,
  input  wire [1:0]    io_dma_b_payload_resp,
  output wire          io_dma_ar_valid,
  input  wire          io_dma_ar_ready,
  output wire [31:0]   io_dma_ar_payload_addr,
  output wire [7:0]    io_dma_ar_payload_len,
  output wire [2:0]    io_dma_ar_payload_size,
  output wire [3:0]    io_dma_ar_payload_cache,
  output wire [2:0]    io_dma_ar_payload_prot,
  input  wire          io_dma_r_valid,
  output wire          io_dma_r_ready,
  input  wire [31:0]   io_dma_r_payload_data,
  input  wire [1:0]    io_dma_r_payload_resp,
  input  wire          io_dma_r_payload_last,
  input  wire          io_ctrl_aw_valid,
  output wire          io_ctrl_aw_ready,
  input  wire [11:0]   io_ctrl_aw_payload_addr,
  input  wire [7:0]    io_ctrl_aw_payload_id,
  input  wire [3:0]    io_ctrl_aw_payload_region,
  input  wire [7:0]    io_ctrl_aw_payload_len,
  input  wire [2:0]    io_ctrl_aw_payload_size,
  input  wire [1:0]    io_ctrl_aw_payload_burst,
  input  wire [0:0]    io_ctrl_aw_payload_lock,
  input  wire [3:0]    io_ctrl_aw_payload_cache,
  input  wire [3:0]    io_ctrl_aw_payload_qos,
  input  wire [2:0]    io_ctrl_aw_payload_prot,
  input  wire          io_ctrl_w_valid,
  output wire          io_ctrl_w_ready,
  input  wire [31:0]   io_ctrl_w_payload_data,
  input  wire [3:0]    io_ctrl_w_payload_strb,
  input  wire          io_ctrl_w_payload_last,
  output wire          io_ctrl_b_valid,
  input  wire          io_ctrl_b_ready,
  output wire [7:0]    io_ctrl_b_payload_id,
  output wire [1:0]    io_ctrl_b_payload_resp,
  input  wire          io_ctrl_ar_valid,
  output wire          io_ctrl_ar_ready,
  input  wire [11:0]   io_ctrl_ar_payload_addr,
  input  wire [7:0]    io_ctrl_ar_payload_id,
  input  wire [3:0]    io_ctrl_ar_payload_region,
  input  wire [7:0]    io_ctrl_ar_payload_len,
  input  wire [2:0]    io_ctrl_ar_payload_size,
  input  wire [1:0]    io_ctrl_ar_payload_burst,
  input  wire [0:0]    io_ctrl_ar_payload_lock,
  input  wire [3:0]    io_ctrl_ar_payload_cache,
  input  wire [3:0]    io_ctrl_ar_payload_qos,
  input  wire [2:0]    io_ctrl_ar_payload_prot,
  output wire          io_ctrl_r_valid,
  input  wire          io_ctrl_r_ready,
  output wire [31:0]   io_ctrl_r_payload_data,
  output wire [7:0]    io_ctrl_r_payload_id,
  output wire [1:0]    io_ctrl_r_payload_resp,
  output wire          io_ctrl_r_payload_last,
  output wire          io_interrupt,
  input  wire          io_usb_0_dp_read,
  output wire          io_usb_0_dp_write,
  output wire          io_usb_0_dp_writeEnable,
  input  wire          io_usb_0_dm_read,
  output wire          io_usb_0_dm_write,
  output wire          io_usb_0_dm_writeEnable,
  input  wire          io_usb_1_dp_read,
  output wire          io_usb_1_dp_write,
  output wire          io_usb_1_dp_writeEnable,
  input  wire          io_usb_1_dm_read,
  output wire          io_usb_1_dm_write,
  output wire          io_usb_1_dm_writeEnable,
  input  wire          io_usb_2_dp_read,
  output wire          io_usb_2_dp_write,
  output wire          io_usb_2_dp_writeEnable,
  input  wire          io_usb_2_dm_read,
  output wire          io_usb_2_dm_write,
  output wire          io_usb_2_dm_writeEnable,
  input  wire          io_usb_3_dp_read,
  output wire          io_usb_3_dp_write,
  output wire          io_usb_3_dp_writeEnable,
  input  wire          io_usb_3_dm_read,
  output wire          io_usb_3_dm_write,
  output wire          io_usb_3_dm_writeEnable,
  input  wire          phy_clk,
  input  wire          phy_reset,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire                front_dmaBridge_io_output_arw_ready;
  wire                front_ctrlBridge_io_axi_arw_payload_write;
  wire                back_phy_io_management_0_overcurrent;
  wire                back_phy_io_management_1_overcurrent;
  wire                back_phy_io_management_2_overcurrent;
  wire                back_phy_io_management_3_overcurrent;
  wire                front_dmaBridge_io_input_cmd_ready;
  wire                front_dmaBridge_io_input_rsp_valid;
  wire                front_dmaBridge_io_input_rsp_payload_last;
  wire       [0:0]    front_dmaBridge_io_input_rsp_payload_fragment_opcode;
  wire       [31:0]   front_dmaBridge_io_input_rsp_payload_fragment_data;
  wire                front_dmaBridge_io_output_arw_valid;
  wire       [31:0]   front_dmaBridge_io_output_arw_payload_addr;
  wire       [7:0]    front_dmaBridge_io_output_arw_payload_len;
  wire       [2:0]    front_dmaBridge_io_output_arw_payload_size;
  wire       [3:0]    front_dmaBridge_io_output_arw_payload_cache;
  wire       [2:0]    front_dmaBridge_io_output_arw_payload_prot;
  wire                front_dmaBridge_io_output_arw_payload_write;
  wire                front_dmaBridge_io_output_w_valid;
  wire       [31:0]   front_dmaBridge_io_output_w_payload_data;
  wire       [3:0]    front_dmaBridge_io_output_w_payload_strb;
  wire                front_dmaBridge_io_output_w_payload_last;
  wire                front_dmaBridge_io_output_b_ready;
  wire                front_dmaBridge_io_output_r_ready;
  wire                front_ctrlBridge_io_axi_arw_ready;
  wire                front_ctrlBridge_io_axi_w_ready;
  wire                front_ctrlBridge_io_axi_b_valid;
  wire       [7:0]    front_ctrlBridge_io_axi_b_payload_id;
  wire       [1:0]    front_ctrlBridge_io_axi_b_payload_resp;
  wire                front_ctrlBridge_io_axi_r_valid;
  wire       [31:0]   front_ctrlBridge_io_axi_r_payload_data;
  wire       [7:0]    front_ctrlBridge_io_axi_r_payload_id;
  wire       [1:0]    front_ctrlBridge_io_axi_r_payload_resp;
  wire                front_ctrlBridge_io_axi_r_payload_last;
  wire                front_ctrlBridge_io_bmb_cmd_valid;
  wire                front_ctrlBridge_io_bmb_cmd_payload_last;
  wire       [8:0]    front_ctrlBridge_io_bmb_cmd_payload_fragment_source;
  wire       [0:0]    front_ctrlBridge_io_bmb_cmd_payload_fragment_opcode;
  wire       [11:0]   front_ctrlBridge_io_bmb_cmd_payload_fragment_address;
  wire       [9:0]    front_ctrlBridge_io_bmb_cmd_payload_fragment_length;
  wire       [31:0]   front_ctrlBridge_io_bmb_cmd_payload_fragment_data;
  wire       [3:0]    front_ctrlBridge_io_bmb_cmd_payload_fragment_mask;
  wire                front_ctrlBridge_io_bmb_rsp_ready;
  wire                streamArbiter_io_inputs_0_ready;
  wire                streamArbiter_io_inputs_1_ready;
  wire                streamArbiter_io_output_valid;
  wire       [11:0]   streamArbiter_io_output_payload_addr;
  wire       [7:0]    streamArbiter_io_output_payload_id;
  wire       [3:0]    streamArbiter_io_output_payload_region;
  wire       [7:0]    streamArbiter_io_output_payload_len;
  wire       [2:0]    streamArbiter_io_output_payload_size;
  wire       [1:0]    streamArbiter_io_output_payload_burst;
  wire       [0:0]    streamArbiter_io_output_payload_lock;
  wire       [3:0]    streamArbiter_io_output_payload_cache;
  wire       [3:0]    streamArbiter_io_output_payload_qos;
  wire       [2:0]    streamArbiter_io_output_payload_prot;
  wire       [0:0]    streamArbiter_io_chosen;
  wire       [1:0]    streamArbiter_io_chosenOH;
  wire                front_ohci_io_ctrl_cmd_ready;
  wire                front_ohci_io_ctrl_rsp_valid;
  wire                front_ohci_io_ctrl_rsp_payload_last;
  wire       [8:0]    front_ohci_io_ctrl_rsp_payload_fragment_source;
  wire       [0:0]    front_ohci_io_ctrl_rsp_payload_fragment_opcode;
  wire       [31:0]   front_ohci_io_ctrl_rsp_payload_fragment_data;
  wire                front_ohci_io_phy_lowSpeed;
  wire                front_ohci_io_phy_usbReset;
  wire                front_ohci_io_phy_usbResume;
  wire                front_ohci_io_phy_tx_valid;
  wire                front_ohci_io_phy_tx_payload_last;
  wire       [7:0]    front_ohci_io_phy_tx_payload_fragment;
  wire                front_ohci_io_phy_ports_0_removable;
  wire                front_ohci_io_phy_ports_0_power;
  wire                front_ohci_io_phy_ports_0_reset_valid;
  wire                front_ohci_io_phy_ports_0_suspend_valid;
  wire                front_ohci_io_phy_ports_0_resume_valid;
  wire                front_ohci_io_phy_ports_0_disable_valid;
  wire                front_ohci_io_phy_ports_1_removable;
  wire                front_ohci_io_phy_ports_1_power;
  wire                front_ohci_io_phy_ports_1_reset_valid;
  wire                front_ohci_io_phy_ports_1_suspend_valid;
  wire                front_ohci_io_phy_ports_1_resume_valid;
  wire                front_ohci_io_phy_ports_1_disable_valid;
  wire                front_ohci_io_phy_ports_2_removable;
  wire                front_ohci_io_phy_ports_2_power;
  wire                front_ohci_io_phy_ports_2_reset_valid;
  wire                front_ohci_io_phy_ports_2_suspend_valid;
  wire                front_ohci_io_phy_ports_2_resume_valid;
  wire                front_ohci_io_phy_ports_2_disable_valid;
  wire                front_ohci_io_phy_ports_3_removable;
  wire                front_ohci_io_phy_ports_3_power;
  wire                front_ohci_io_phy_ports_3_reset_valid;
  wire                front_ohci_io_phy_ports_3_suspend_valid;
  wire                front_ohci_io_phy_ports_3_resume_valid;
  wire                front_ohci_io_phy_ports_3_disable_valid;
  wire                front_ohci_io_dma_cmd_valid;
  wire                front_ohci_io_dma_cmd_payload_last;
  wire       [0:0]    front_ohci_io_dma_cmd_payload_fragment_opcode;
  wire       [31:0]   front_ohci_io_dma_cmd_payload_fragment_address;
  wire       [5:0]    front_ohci_io_dma_cmd_payload_fragment_length;
  wire       [31:0]   front_ohci_io_dma_cmd_payload_fragment_data;
  wire       [3:0]    front_ohci_io_dma_cmd_payload_fragment_mask;
  wire                front_ohci_io_dma_rsp_ready;
  wire                front_ohci_io_interrupt;
  wire                front_ohci_io_interruptBios;
  wire                back_phy_io_ctrl_overcurrent;
  wire                back_phy_io_ctrl_tick;
  wire                back_phy_io_ctrl_tx_ready;
  wire                back_phy_io_ctrl_txEop;
  wire                back_phy_io_ctrl_rx_flow_valid;
  wire                back_phy_io_ctrl_rx_flow_payload_stuffingError;
  wire       [7:0]    back_phy_io_ctrl_rx_flow_payload_data;
  wire                back_phy_io_ctrl_rx_active;
  wire                back_phy_io_ctrl_ports_0_reset_ready;
  wire                back_phy_io_ctrl_ports_0_suspend_ready;
  wire                back_phy_io_ctrl_ports_0_resume_ready;
  wire                back_phy_io_ctrl_ports_0_disable_ready;
  wire                back_phy_io_ctrl_ports_0_connect;
  wire                back_phy_io_ctrl_ports_0_disconnect;
  wire                back_phy_io_ctrl_ports_0_overcurrent;
  wire                back_phy_io_ctrl_ports_0_lowSpeed;
  wire                back_phy_io_ctrl_ports_0_remoteResume;
  wire                back_phy_io_ctrl_ports_1_reset_ready;
  wire                back_phy_io_ctrl_ports_1_suspend_ready;
  wire                back_phy_io_ctrl_ports_1_resume_ready;
  wire                back_phy_io_ctrl_ports_1_disable_ready;
  wire                back_phy_io_ctrl_ports_1_connect;
  wire                back_phy_io_ctrl_ports_1_disconnect;
  wire                back_phy_io_ctrl_ports_1_overcurrent;
  wire                back_phy_io_ctrl_ports_1_lowSpeed;
  wire                back_phy_io_ctrl_ports_1_remoteResume;
  wire                back_phy_io_ctrl_ports_2_reset_ready;
  wire                back_phy_io_ctrl_ports_2_suspend_ready;
  wire                back_phy_io_ctrl_ports_2_resume_ready;
  wire                back_phy_io_ctrl_ports_2_disable_ready;
  wire                back_phy_io_ctrl_ports_2_connect;
  wire                back_phy_io_ctrl_ports_2_disconnect;
  wire                back_phy_io_ctrl_ports_2_overcurrent;
  wire                back_phy_io_ctrl_ports_2_lowSpeed;
  wire                back_phy_io_ctrl_ports_2_remoteResume;
  wire                back_phy_io_ctrl_ports_3_reset_ready;
  wire                back_phy_io_ctrl_ports_3_suspend_ready;
  wire                back_phy_io_ctrl_ports_3_resume_ready;
  wire                back_phy_io_ctrl_ports_3_disable_ready;
  wire                back_phy_io_ctrl_ports_3_connect;
  wire                back_phy_io_ctrl_ports_3_disconnect;
  wire                back_phy_io_ctrl_ports_3_overcurrent;
  wire                back_phy_io_ctrl_ports_3_lowSpeed;
  wire                back_phy_io_ctrl_ports_3_remoteResume;
  wire                back_phy_io_usb_0_tx_enable;
  wire                back_phy_io_usb_0_tx_data;
  wire                back_phy_io_usb_0_tx_se0;
  wire                back_phy_io_usb_1_tx_enable;
  wire                back_phy_io_usb_1_tx_data;
  wire                back_phy_io_usb_1_tx_se0;
  wire                back_phy_io_usb_2_tx_enable;
  wire                back_phy_io_usb_2_tx_data;
  wire                back_phy_io_usb_2_tx_se0;
  wire                back_phy_io_usb_3_tx_enable;
  wire                back_phy_io_usb_3_tx_data;
  wire                back_phy_io_usb_3_tx_se0;
  wire                back_phy_io_management_0_power;
  wire                back_phy_io_management_1_power;
  wire                back_phy_io_management_2_power;
  wire                back_phy_io_management_3_power;
  wire                back_buffer_0_dp_read_buffercc_io_dataOut;
  wire                back_buffer_0_dm_read_buffercc_io_dataOut;
  wire                back_buffer_1_dp_read_buffercc_io_dataOut;
  wire                back_buffer_1_dm_read_buffercc_io_dataOut;
  wire                back_buffer_2_dp_read_buffercc_io_dataOut;
  wire                back_buffer_2_dm_read_buffercc_io_dataOut;
  wire                back_buffer_3_dp_read_buffercc_io_dataOut;
  wire                back_buffer_3_dm_read_buffercc_io_dataOut;
  wire                cc_input_overcurrent;
  wire                cc_input_tick;
  wire                cc_input_tx_ready;
  wire                cc_input_txEop;
  wire                cc_input_rx_flow_valid;
  wire                cc_input_rx_flow_payload_stuffingError;
  wire       [7:0]    cc_input_rx_flow_payload_data;
  wire                cc_input_rx_active;
  wire                cc_input_ports_0_reset_ready;
  wire                cc_input_ports_0_suspend_ready;
  wire                cc_input_ports_0_resume_ready;
  wire                cc_input_ports_0_disable_ready;
  wire                cc_input_ports_0_connect;
  wire                cc_input_ports_0_disconnect;
  wire                cc_input_ports_0_overcurrent;
  wire                cc_input_ports_0_lowSpeed;
  wire                cc_input_ports_0_remoteResume;
  wire                cc_input_ports_1_reset_ready;
  wire                cc_input_ports_1_suspend_ready;
  wire                cc_input_ports_1_resume_ready;
  wire                cc_input_ports_1_disable_ready;
  wire                cc_input_ports_1_connect;
  wire                cc_input_ports_1_disconnect;
  wire                cc_input_ports_1_overcurrent;
  wire                cc_input_ports_1_lowSpeed;
  wire                cc_input_ports_1_remoteResume;
  wire                cc_input_ports_2_reset_ready;
  wire                cc_input_ports_2_suspend_ready;
  wire                cc_input_ports_2_resume_ready;
  wire                cc_input_ports_2_disable_ready;
  wire                cc_input_ports_2_connect;
  wire                cc_input_ports_2_disconnect;
  wire                cc_input_ports_2_overcurrent;
  wire                cc_input_ports_2_lowSpeed;
  wire                cc_input_ports_2_remoteResume;
  wire                cc_input_ports_3_reset_ready;
  wire                cc_input_ports_3_suspend_ready;
  wire                cc_input_ports_3_resume_ready;
  wire                cc_input_ports_3_disable_ready;
  wire                cc_input_ports_3_connect;
  wire                cc_input_ports_3_disconnect;
  wire                cc_input_ports_3_overcurrent;
  wire                cc_input_ports_3_lowSpeed;
  wire                cc_input_ports_3_remoteResume;
  wire                cc_output_lowSpeed;
  wire                cc_output_usbReset;
  wire                cc_output_usbResume;
  wire                cc_output_tx_valid;
  wire                cc_output_tx_payload_last;
  wire       [7:0]    cc_output_tx_payload_fragment;
  wire                cc_output_ports_0_removable;
  wire                cc_output_ports_0_power;
  wire                cc_output_ports_0_reset_valid;
  wire                cc_output_ports_0_suspend_valid;
  wire                cc_output_ports_0_resume_valid;
  wire                cc_output_ports_0_disable_valid;
  wire                cc_output_ports_1_removable;
  wire                cc_output_ports_1_power;
  wire                cc_output_ports_1_reset_valid;
  wire                cc_output_ports_1_suspend_valid;
  wire                cc_output_ports_1_resume_valid;
  wire                cc_output_ports_1_disable_valid;
  wire                cc_output_ports_2_removable;
  wire                cc_output_ports_2_power;
  wire                cc_output_ports_2_reset_valid;
  wire                cc_output_ports_2_suspend_valid;
  wire                cc_output_ports_2_resume_valid;
  wire                cc_output_ports_2_disable_valid;
  wire                cc_output_ports_3_removable;
  wire                cc_output_ports_3_power;
  wire                cc_output_ports_3_reset_valid;
  wire                cc_output_ports_3_suspend_valid;
  wire                cc_output_ports_3_resume_valid;
  wire                cc_output_ports_3_disable_valid;
  wire                back_native_0_dp_read;
  wire                back_native_0_dp_write;
  wire                back_native_0_dp_writeEnable;
  wire                back_native_0_dm_read;
  wire                back_native_0_dm_write;
  wire                back_native_0_dm_writeEnable;
  wire                back_native_1_dp_read;
  wire                back_native_1_dp_write;
  wire                back_native_1_dp_writeEnable;
  wire                back_native_1_dm_read;
  wire                back_native_1_dm_write;
  wire                back_native_1_dm_writeEnable;
  wire                back_native_2_dp_read;
  wire                back_native_2_dp_write;
  wire                back_native_2_dp_writeEnable;
  wire                back_native_2_dm_read;
  wire                back_native_2_dm_write;
  wire                back_native_2_dm_writeEnable;
  wire                back_native_3_dp_read;
  wire                back_native_3_dp_write;
  wire                back_native_3_dp_writeEnable;
  wire                back_native_3_dm_read;
  wire                back_native_3_dm_write;
  wire                back_native_3_dm_writeEnable;
  wire                back_buffer_0_dp_read;
  wire                back_buffer_0_dp_write;
  wire                back_buffer_0_dp_writeEnable;
  wire                back_buffer_0_dm_read;
  wire                back_buffer_0_dm_write;
  wire                back_buffer_0_dm_writeEnable;
  reg                 back_native_0_dp_write_delay_1;
  reg                 back_native_0_dp_write_delay_2;
  reg                 back_native_0_dp_writeEnable_delay_1;
  reg                 back_native_0_dp_writeEnable_delay_2;
  reg                 back_native_0_dm_write_delay_1;
  reg                 back_native_0_dm_write_delay_2;
  reg                 back_native_0_dm_writeEnable_delay_1;
  reg                 back_native_0_dm_writeEnable_delay_2;
  wire                back_buffer_1_dp_read;
  wire                back_buffer_1_dp_write;
  wire                back_buffer_1_dp_writeEnable;
  wire                back_buffer_1_dm_read;
  wire                back_buffer_1_dm_write;
  wire                back_buffer_1_dm_writeEnable;
  reg                 back_native_1_dp_write_delay_1;
  reg                 back_native_1_dp_write_delay_2;
  reg                 back_native_1_dp_writeEnable_delay_1;
  reg                 back_native_1_dp_writeEnable_delay_2;
  reg                 back_native_1_dm_write_delay_1;
  reg                 back_native_1_dm_write_delay_2;
  reg                 back_native_1_dm_writeEnable_delay_1;
  reg                 back_native_1_dm_writeEnable_delay_2;
  wire                back_buffer_2_dp_read;
  wire                back_buffer_2_dp_write;
  wire                back_buffer_2_dp_writeEnable;
  wire                back_buffer_2_dm_read;
  wire                back_buffer_2_dm_write;
  wire                back_buffer_2_dm_writeEnable;
  reg                 back_native_2_dp_write_delay_1;
  reg                 back_native_2_dp_write_delay_2;
  reg                 back_native_2_dp_writeEnable_delay_1;
  reg                 back_native_2_dp_writeEnable_delay_2;
  reg                 back_native_2_dm_write_delay_1;
  reg                 back_native_2_dm_write_delay_2;
  reg                 back_native_2_dm_writeEnable_delay_1;
  reg                 back_native_2_dm_writeEnable_delay_2;
  wire                back_buffer_3_dp_read;
  wire                back_buffer_3_dp_write;
  wire                back_buffer_3_dp_writeEnable;
  wire                back_buffer_3_dm_read;
  wire                back_buffer_3_dm_write;
  wire                back_buffer_3_dm_writeEnable;
  reg                 back_native_3_dp_write_delay_1;
  reg                 back_native_3_dp_write_delay_2;
  reg                 back_native_3_dp_writeEnable_delay_1;
  reg                 back_native_3_dp_writeEnable_delay_2;
  reg                 back_native_3_dm_write_delay_1;
  reg                 back_native_3_dm_write_delay_2;
  reg                 back_native_3_dm_writeEnable_delay_1;
  reg                 back_native_3_dm_writeEnable_delay_2;

  UsbOhciAxi4_BmbToAxi4SharedBridge front_dmaBridge (
    .io_input_cmd_valid                    (front_ohci_io_dma_cmd_valid                             ), //i
    .io_input_cmd_ready                    (front_dmaBridge_io_input_cmd_ready                      ), //o
    .io_input_cmd_payload_last             (front_ohci_io_dma_cmd_payload_last                      ), //i
    .io_input_cmd_payload_fragment_opcode  (front_ohci_io_dma_cmd_payload_fragment_opcode           ), //i
    .io_input_cmd_payload_fragment_address (front_ohci_io_dma_cmd_payload_fragment_address[31:0]    ), //i
    .io_input_cmd_payload_fragment_length  (front_ohci_io_dma_cmd_payload_fragment_length[5:0]      ), //i
    .io_input_cmd_payload_fragment_data    (front_ohci_io_dma_cmd_payload_fragment_data[31:0]       ), //i
    .io_input_cmd_payload_fragment_mask    (front_ohci_io_dma_cmd_payload_fragment_mask[3:0]        ), //i
    .io_input_rsp_valid                    (front_dmaBridge_io_input_rsp_valid                      ), //o
    .io_input_rsp_ready                    (front_ohci_io_dma_rsp_ready                             ), //i
    .io_input_rsp_payload_last             (front_dmaBridge_io_input_rsp_payload_last               ), //o
    .io_input_rsp_payload_fragment_opcode  (front_dmaBridge_io_input_rsp_payload_fragment_opcode    ), //o
    .io_input_rsp_payload_fragment_data    (front_dmaBridge_io_input_rsp_payload_fragment_data[31:0]), //o
    .io_output_arw_valid                   (front_dmaBridge_io_output_arw_valid                     ), //o
    .io_output_arw_ready                   (front_dmaBridge_io_output_arw_ready                     ), //i
    .io_output_arw_payload_addr            (front_dmaBridge_io_output_arw_payload_addr[31:0]        ), //o
    .io_output_arw_payload_len             (front_dmaBridge_io_output_arw_payload_len[7:0]          ), //o
    .io_output_arw_payload_size            (front_dmaBridge_io_output_arw_payload_size[2:0]         ), //o
    .io_output_arw_payload_cache           (front_dmaBridge_io_output_arw_payload_cache[3:0]        ), //o
    .io_output_arw_payload_prot            (front_dmaBridge_io_output_arw_payload_prot[2:0]         ), //o
    .io_output_arw_payload_write           (front_dmaBridge_io_output_arw_payload_write             ), //o
    .io_output_w_valid                     (front_dmaBridge_io_output_w_valid                       ), //o
    .io_output_w_ready                     (io_dma_w_ready                                          ), //i
    .io_output_w_payload_data              (front_dmaBridge_io_output_w_payload_data[31:0]          ), //o
    .io_output_w_payload_strb              (front_dmaBridge_io_output_w_payload_strb[3:0]           ), //o
    .io_output_w_payload_last              (front_dmaBridge_io_output_w_payload_last                ), //o
    .io_output_b_valid                     (io_dma_b_valid                                          ), //i
    .io_output_b_ready                     (front_dmaBridge_io_output_b_ready                       ), //o
    .io_output_b_payload_resp              (io_dma_b_payload_resp[1:0]                              ), //i
    .io_output_r_valid                     (io_dma_r_valid                                          ), //i
    .io_output_r_ready                     (front_dmaBridge_io_output_r_ready                       ), //o
    .io_output_r_payload_data              (io_dma_r_payload_data[31:0]                             ), //i
    .io_output_r_payload_resp              (io_dma_r_payload_resp[1:0]                              ), //i
    .io_output_r_payload_last              (io_dma_r_payload_last                                   ), //i
    .ctrl_clk                              (ctrl_clk                                                ), //i
    .ctrl_reset                            (ctrl_reset                                              )  //i
  );
  UsbOhciAxi4_Axi4SharedToBmb front_ctrlBridge (
    .io_axi_arw_valid                    (streamArbiter_io_output_valid                             ), //i
    .io_axi_arw_ready                    (front_ctrlBridge_io_axi_arw_ready                         ), //o
    .io_axi_arw_payload_addr             (streamArbiter_io_output_payload_addr[11:0]                ), //i
    .io_axi_arw_payload_id               (streamArbiter_io_output_payload_id[7:0]                   ), //i
    .io_axi_arw_payload_region           (streamArbiter_io_output_payload_region[3:0]               ), //i
    .io_axi_arw_payload_len              (streamArbiter_io_output_payload_len[7:0]                  ), //i
    .io_axi_arw_payload_size             (streamArbiter_io_output_payload_size[2:0]                 ), //i
    .io_axi_arw_payload_burst            (streamArbiter_io_output_payload_burst[1:0]                ), //i
    .io_axi_arw_payload_lock             (streamArbiter_io_output_payload_lock                      ), //i
    .io_axi_arw_payload_cache            (streamArbiter_io_output_payload_cache[3:0]                ), //i
    .io_axi_arw_payload_qos              (streamArbiter_io_output_payload_qos[3:0]                  ), //i
    .io_axi_arw_payload_prot             (streamArbiter_io_output_payload_prot[2:0]                 ), //i
    .io_axi_arw_payload_write            (front_ctrlBridge_io_axi_arw_payload_write                 ), //i
    .io_axi_w_valid                      (io_ctrl_w_valid                                           ), //i
    .io_axi_w_ready                      (front_ctrlBridge_io_axi_w_ready                           ), //o
    .io_axi_w_payload_data               (io_ctrl_w_payload_data[31:0]                              ), //i
    .io_axi_w_payload_strb               (io_ctrl_w_payload_strb[3:0]                               ), //i
    .io_axi_w_payload_last               (io_ctrl_w_payload_last                                    ), //i
    .io_axi_b_valid                      (front_ctrlBridge_io_axi_b_valid                           ), //o
    .io_axi_b_ready                      (io_ctrl_b_ready                                           ), //i
    .io_axi_b_payload_id                 (front_ctrlBridge_io_axi_b_payload_id[7:0]                 ), //o
    .io_axi_b_payload_resp               (front_ctrlBridge_io_axi_b_payload_resp[1:0]               ), //o
    .io_axi_r_valid                      (front_ctrlBridge_io_axi_r_valid                           ), //o
    .io_axi_r_ready                      (io_ctrl_r_ready                                           ), //i
    .io_axi_r_payload_data               (front_ctrlBridge_io_axi_r_payload_data[31:0]              ), //o
    .io_axi_r_payload_id                 (front_ctrlBridge_io_axi_r_payload_id[7:0]                 ), //o
    .io_axi_r_payload_resp               (front_ctrlBridge_io_axi_r_payload_resp[1:0]               ), //o
    .io_axi_r_payload_last               (front_ctrlBridge_io_axi_r_payload_last                    ), //o
    .io_bmb_cmd_valid                    (front_ctrlBridge_io_bmb_cmd_valid                         ), //o
    .io_bmb_cmd_ready                    (front_ohci_io_ctrl_cmd_ready                              ), //i
    .io_bmb_cmd_payload_last             (front_ctrlBridge_io_bmb_cmd_payload_last                  ), //o
    .io_bmb_cmd_payload_fragment_source  (front_ctrlBridge_io_bmb_cmd_payload_fragment_source[8:0]  ), //o
    .io_bmb_cmd_payload_fragment_opcode  (front_ctrlBridge_io_bmb_cmd_payload_fragment_opcode       ), //o
    .io_bmb_cmd_payload_fragment_address (front_ctrlBridge_io_bmb_cmd_payload_fragment_address[11:0]), //o
    .io_bmb_cmd_payload_fragment_length  (front_ctrlBridge_io_bmb_cmd_payload_fragment_length[9:0]  ), //o
    .io_bmb_cmd_payload_fragment_data    (front_ctrlBridge_io_bmb_cmd_payload_fragment_data[31:0]   ), //o
    .io_bmb_cmd_payload_fragment_mask    (front_ctrlBridge_io_bmb_cmd_payload_fragment_mask[3:0]    ), //o
    .io_bmb_rsp_valid                    (front_ohci_io_ctrl_rsp_valid                              ), //i
    .io_bmb_rsp_ready                    (front_ctrlBridge_io_bmb_rsp_ready                         ), //o
    .io_bmb_rsp_payload_last             (front_ohci_io_ctrl_rsp_payload_last                       ), //i
    .io_bmb_rsp_payload_fragment_source  (front_ohci_io_ctrl_rsp_payload_fragment_source[8:0]       ), //i
    .io_bmb_rsp_payload_fragment_opcode  (front_ohci_io_ctrl_rsp_payload_fragment_opcode            ), //i
    .io_bmb_rsp_payload_fragment_data    (front_ohci_io_ctrl_rsp_payload_fragment_data[31:0]        )  //i
  );
  UsbOhciAxi4_StreamArbiter streamArbiter (
    .io_inputs_0_valid          (io_ctrl_ar_valid                           ), //i
    .io_inputs_0_ready          (streamArbiter_io_inputs_0_ready            ), //o
    .io_inputs_0_payload_addr   (io_ctrl_ar_payload_addr[11:0]              ), //i
    .io_inputs_0_payload_id     (io_ctrl_ar_payload_id[7:0]                 ), //i
    .io_inputs_0_payload_region (io_ctrl_ar_payload_region[3:0]             ), //i
    .io_inputs_0_payload_len    (io_ctrl_ar_payload_len[7:0]                ), //i
    .io_inputs_0_payload_size   (io_ctrl_ar_payload_size[2:0]               ), //i
    .io_inputs_0_payload_burst  (io_ctrl_ar_payload_burst[1:0]              ), //i
    .io_inputs_0_payload_lock   (io_ctrl_ar_payload_lock                    ), //i
    .io_inputs_0_payload_cache  (io_ctrl_ar_payload_cache[3:0]              ), //i
    .io_inputs_0_payload_qos    (io_ctrl_ar_payload_qos[3:0]                ), //i
    .io_inputs_0_payload_prot   (io_ctrl_ar_payload_prot[2:0]               ), //i
    .io_inputs_1_valid          (io_ctrl_aw_valid                           ), //i
    .io_inputs_1_ready          (streamArbiter_io_inputs_1_ready            ), //o
    .io_inputs_1_payload_addr   (io_ctrl_aw_payload_addr[11:0]              ), //i
    .io_inputs_1_payload_id     (io_ctrl_aw_payload_id[7:0]                 ), //i
    .io_inputs_1_payload_region (io_ctrl_aw_payload_region[3:0]             ), //i
    .io_inputs_1_payload_len    (io_ctrl_aw_payload_len[7:0]                ), //i
    .io_inputs_1_payload_size   (io_ctrl_aw_payload_size[2:0]               ), //i
    .io_inputs_1_payload_burst  (io_ctrl_aw_payload_burst[1:0]              ), //i
    .io_inputs_1_payload_lock   (io_ctrl_aw_payload_lock                    ), //i
    .io_inputs_1_payload_cache  (io_ctrl_aw_payload_cache[3:0]              ), //i
    .io_inputs_1_payload_qos    (io_ctrl_aw_payload_qos[3:0]                ), //i
    .io_inputs_1_payload_prot   (io_ctrl_aw_payload_prot[2:0]               ), //i
    .io_output_valid            (streamArbiter_io_output_valid              ), //o
    .io_output_ready            (front_ctrlBridge_io_axi_arw_ready          ), //i
    .io_output_payload_addr     (streamArbiter_io_output_payload_addr[11:0] ), //o
    .io_output_payload_id       (streamArbiter_io_output_payload_id[7:0]    ), //o
    .io_output_payload_region   (streamArbiter_io_output_payload_region[3:0]), //o
    .io_output_payload_len      (streamArbiter_io_output_payload_len[7:0]   ), //o
    .io_output_payload_size     (streamArbiter_io_output_payload_size[2:0]  ), //o
    .io_output_payload_burst    (streamArbiter_io_output_payload_burst[1:0] ), //o
    .io_output_payload_lock     (streamArbiter_io_output_payload_lock       ), //o
    .io_output_payload_cache    (streamArbiter_io_output_payload_cache[3:0] ), //o
    .io_output_payload_qos      (streamArbiter_io_output_payload_qos[3:0]   ), //o
    .io_output_payload_prot     (streamArbiter_io_output_payload_prot[2:0]  ), //o
    .io_chosen                  (streamArbiter_io_chosen                    ), //o
    .io_chosenOH                (streamArbiter_io_chosenOH[1:0]             ), //o
    .ctrl_clk                   (ctrl_clk                                   ), //i
    .ctrl_reset                 (ctrl_reset                                 )  //i
  );
  UsbOhciAxi4_UsbOhci front_ohci (
    .io_ctrl_cmd_valid                    (front_ctrlBridge_io_bmb_cmd_valid                         ), //i
    .io_ctrl_cmd_ready                    (front_ohci_io_ctrl_cmd_ready                              ), //o
    .io_ctrl_cmd_payload_last             (front_ctrlBridge_io_bmb_cmd_payload_last                  ), //i
    .io_ctrl_cmd_payload_fragment_source  (front_ctrlBridge_io_bmb_cmd_payload_fragment_source[8:0]  ), //i
    .io_ctrl_cmd_payload_fragment_opcode  (front_ctrlBridge_io_bmb_cmd_payload_fragment_opcode       ), //i
    .io_ctrl_cmd_payload_fragment_address (front_ctrlBridge_io_bmb_cmd_payload_fragment_address[11:0]), //i
    .io_ctrl_cmd_payload_fragment_length  (front_ctrlBridge_io_bmb_cmd_payload_fragment_length[9:0]  ), //i
    .io_ctrl_cmd_payload_fragment_data    (front_ctrlBridge_io_bmb_cmd_payload_fragment_data[31:0]   ), //i
    .io_ctrl_cmd_payload_fragment_mask    (front_ctrlBridge_io_bmb_cmd_payload_fragment_mask[3:0]    ), //i
    .io_ctrl_rsp_valid                    (front_ohci_io_ctrl_rsp_valid                              ), //o
    .io_ctrl_rsp_ready                    (front_ctrlBridge_io_bmb_rsp_ready                         ), //i
    .io_ctrl_rsp_payload_last             (front_ohci_io_ctrl_rsp_payload_last                       ), //o
    .io_ctrl_rsp_payload_fragment_source  (front_ohci_io_ctrl_rsp_payload_fragment_source[8:0]       ), //o
    .io_ctrl_rsp_payload_fragment_opcode  (front_ohci_io_ctrl_rsp_payload_fragment_opcode            ), //o
    .io_ctrl_rsp_payload_fragment_data    (front_ohci_io_ctrl_rsp_payload_fragment_data[31:0]        ), //o
    .io_phy_lowSpeed                      (front_ohci_io_phy_lowSpeed                                ), //o
    .io_phy_tx_valid                      (front_ohci_io_phy_tx_valid                                ), //o
    .io_phy_tx_ready                      (cc_input_tx_ready                                         ), //i
    .io_phy_tx_payload_last               (front_ohci_io_phy_tx_payload_last                         ), //o
    .io_phy_tx_payload_fragment           (front_ohci_io_phy_tx_payload_fragment[7:0]                ), //o
    .io_phy_txEop                         (cc_input_txEop                                            ), //i
    .io_phy_rx_flow_valid                 (cc_input_rx_flow_valid                                    ), //i
    .io_phy_rx_flow_payload_stuffingError (cc_input_rx_flow_payload_stuffingError                    ), //i
    .io_phy_rx_flow_payload_data          (cc_input_rx_flow_payload_data[7:0]                        ), //i
    .io_phy_rx_active                     (cc_input_rx_active                                        ), //i
    .io_phy_usbReset                      (front_ohci_io_phy_usbReset                                ), //o
    .io_phy_usbResume                     (front_ohci_io_phy_usbResume                               ), //o
    .io_phy_overcurrent                   (cc_input_overcurrent                                      ), //i
    .io_phy_tick                          (cc_input_tick                                             ), //i
    .io_phy_ports_0_disable_valid         (front_ohci_io_phy_ports_0_disable_valid                   ), //o
    .io_phy_ports_0_disable_ready         (cc_input_ports_0_disable_ready                            ), //i
    .io_phy_ports_0_removable             (front_ohci_io_phy_ports_0_removable                       ), //o
    .io_phy_ports_0_power                 (front_ohci_io_phy_ports_0_power                           ), //o
    .io_phy_ports_0_reset_valid           (front_ohci_io_phy_ports_0_reset_valid                     ), //o
    .io_phy_ports_0_reset_ready           (cc_input_ports_0_reset_ready                              ), //i
    .io_phy_ports_0_suspend_valid         (front_ohci_io_phy_ports_0_suspend_valid                   ), //o
    .io_phy_ports_0_suspend_ready         (cc_input_ports_0_suspend_ready                            ), //i
    .io_phy_ports_0_resume_valid          (front_ohci_io_phy_ports_0_resume_valid                    ), //o
    .io_phy_ports_0_resume_ready          (cc_input_ports_0_resume_ready                             ), //i
    .io_phy_ports_0_connect               (cc_input_ports_0_connect                                  ), //i
    .io_phy_ports_0_disconnect            (cc_input_ports_0_disconnect                               ), //i
    .io_phy_ports_0_overcurrent           (cc_input_ports_0_overcurrent                              ), //i
    .io_phy_ports_0_remoteResume          (cc_input_ports_0_remoteResume                             ), //i
    .io_phy_ports_0_lowSpeed              (cc_input_ports_0_lowSpeed                                 ), //i
    .io_phy_ports_1_disable_valid         (front_ohci_io_phy_ports_1_disable_valid                   ), //o
    .io_phy_ports_1_disable_ready         (cc_input_ports_1_disable_ready                            ), //i
    .io_phy_ports_1_removable             (front_ohci_io_phy_ports_1_removable                       ), //o
    .io_phy_ports_1_power                 (front_ohci_io_phy_ports_1_power                           ), //o
    .io_phy_ports_1_reset_valid           (front_ohci_io_phy_ports_1_reset_valid                     ), //o
    .io_phy_ports_1_reset_ready           (cc_input_ports_1_reset_ready                              ), //i
    .io_phy_ports_1_suspend_valid         (front_ohci_io_phy_ports_1_suspend_valid                   ), //o
    .io_phy_ports_1_suspend_ready         (cc_input_ports_1_suspend_ready                            ), //i
    .io_phy_ports_1_resume_valid          (front_ohci_io_phy_ports_1_resume_valid                    ), //o
    .io_phy_ports_1_resume_ready          (cc_input_ports_1_resume_ready                             ), //i
    .io_phy_ports_1_connect               (cc_input_ports_1_connect                                  ), //i
    .io_phy_ports_1_disconnect            (cc_input_ports_1_disconnect                               ), //i
    .io_phy_ports_1_overcurrent           (cc_input_ports_1_overcurrent                              ), //i
    .io_phy_ports_1_remoteResume          (cc_input_ports_1_remoteResume                             ), //i
    .io_phy_ports_1_lowSpeed              (cc_input_ports_1_lowSpeed                                 ), //i
    .io_phy_ports_2_disable_valid         (front_ohci_io_phy_ports_2_disable_valid                   ), //o
    .io_phy_ports_2_disable_ready         (cc_input_ports_2_disable_ready                            ), //i
    .io_phy_ports_2_removable             (front_ohci_io_phy_ports_2_removable                       ), //o
    .io_phy_ports_2_power                 (front_ohci_io_phy_ports_2_power                           ), //o
    .io_phy_ports_2_reset_valid           (front_ohci_io_phy_ports_2_reset_valid                     ), //o
    .io_phy_ports_2_reset_ready           (cc_input_ports_2_reset_ready                              ), //i
    .io_phy_ports_2_suspend_valid         (front_ohci_io_phy_ports_2_suspend_valid                   ), //o
    .io_phy_ports_2_suspend_ready         (cc_input_ports_2_suspend_ready                            ), //i
    .io_phy_ports_2_resume_valid          (front_ohci_io_phy_ports_2_resume_valid                    ), //o
    .io_phy_ports_2_resume_ready          (cc_input_ports_2_resume_ready                             ), //i
    .io_phy_ports_2_connect               (cc_input_ports_2_connect                                  ), //i
    .io_phy_ports_2_disconnect            (cc_input_ports_2_disconnect                               ), //i
    .io_phy_ports_2_overcurrent           (cc_input_ports_2_overcurrent                              ), //i
    .io_phy_ports_2_remoteResume          (cc_input_ports_2_remoteResume                             ), //i
    .io_phy_ports_2_lowSpeed              (cc_input_ports_2_lowSpeed                                 ), //i
    .io_phy_ports_3_disable_valid         (front_ohci_io_phy_ports_3_disable_valid                   ), //o
    .io_phy_ports_3_disable_ready         (cc_input_ports_3_disable_ready                            ), //i
    .io_phy_ports_3_removable             (front_ohci_io_phy_ports_3_removable                       ), //o
    .io_phy_ports_3_power                 (front_ohci_io_phy_ports_3_power                           ), //o
    .io_phy_ports_3_reset_valid           (front_ohci_io_phy_ports_3_reset_valid                     ), //o
    .io_phy_ports_3_reset_ready           (cc_input_ports_3_reset_ready                              ), //i
    .io_phy_ports_3_suspend_valid         (front_ohci_io_phy_ports_3_suspend_valid                   ), //o
    .io_phy_ports_3_suspend_ready         (cc_input_ports_3_suspend_ready                            ), //i
    .io_phy_ports_3_resume_valid          (front_ohci_io_phy_ports_3_resume_valid                    ), //o
    .io_phy_ports_3_resume_ready          (cc_input_ports_3_resume_ready                             ), //i
    .io_phy_ports_3_connect               (cc_input_ports_3_connect                                  ), //i
    .io_phy_ports_3_disconnect            (cc_input_ports_3_disconnect                               ), //i
    .io_phy_ports_3_overcurrent           (cc_input_ports_3_overcurrent                              ), //i
    .io_phy_ports_3_remoteResume          (cc_input_ports_3_remoteResume                             ), //i
    .io_phy_ports_3_lowSpeed              (cc_input_ports_3_lowSpeed                                 ), //i
    .io_dma_cmd_valid                     (front_ohci_io_dma_cmd_valid                               ), //o
    .io_dma_cmd_ready                     (front_dmaBridge_io_input_cmd_ready                        ), //i
    .io_dma_cmd_payload_last              (front_ohci_io_dma_cmd_payload_last                        ), //o
    .io_dma_cmd_payload_fragment_opcode   (front_ohci_io_dma_cmd_payload_fragment_opcode             ), //o
    .io_dma_cmd_payload_fragment_address  (front_ohci_io_dma_cmd_payload_fragment_address[31:0]      ), //o
    .io_dma_cmd_payload_fragment_length   (front_ohci_io_dma_cmd_payload_fragment_length[5:0]        ), //o
    .io_dma_cmd_payload_fragment_data     (front_ohci_io_dma_cmd_payload_fragment_data[31:0]         ), //o
    .io_dma_cmd_payload_fragment_mask     (front_ohci_io_dma_cmd_payload_fragment_mask[3:0]          ), //o
    .io_dma_rsp_valid                     (front_dmaBridge_io_input_rsp_valid                        ), //i
    .io_dma_rsp_ready                     (front_ohci_io_dma_rsp_ready                               ), //o
    .io_dma_rsp_payload_last              (front_dmaBridge_io_input_rsp_payload_last                 ), //i
    .io_dma_rsp_payload_fragment_opcode   (front_dmaBridge_io_input_rsp_payload_fragment_opcode      ), //i
    .io_dma_rsp_payload_fragment_data     (front_dmaBridge_io_input_rsp_payload_fragment_data[31:0]  ), //i
    .io_interrupt                         (front_ohci_io_interrupt                                   ), //o
    .io_interruptBios                     (front_ohci_io_interruptBios                               ), //o
    .ctrl_clk                             (ctrl_clk                                                  ), //i
    .ctrl_reset                           (ctrl_reset                                                )  //i
  );
  UsbOhciAxi4_UsbLsFsPhy back_phy (
    .io_ctrl_lowSpeed                      (cc_output_lowSpeed                            ), //i
    .io_ctrl_tx_valid                      (cc_output_tx_valid                            ), //i
    .io_ctrl_tx_ready                      (back_phy_io_ctrl_tx_ready                     ), //o
    .io_ctrl_tx_payload_last               (cc_output_tx_payload_last                     ), //i
    .io_ctrl_tx_payload_fragment           (cc_output_tx_payload_fragment[7:0]            ), //i
    .io_ctrl_txEop                         (back_phy_io_ctrl_txEop                        ), //o
    .io_ctrl_rx_flow_valid                 (back_phy_io_ctrl_rx_flow_valid                ), //o
    .io_ctrl_rx_flow_payload_stuffingError (back_phy_io_ctrl_rx_flow_payload_stuffingError), //o
    .io_ctrl_rx_flow_payload_data          (back_phy_io_ctrl_rx_flow_payload_data[7:0]    ), //o
    .io_ctrl_rx_active                     (back_phy_io_ctrl_rx_active                    ), //o
    .io_ctrl_usbReset                      (cc_output_usbReset                            ), //i
    .io_ctrl_usbResume                     (cc_output_usbResume                           ), //i
    .io_ctrl_overcurrent                   (back_phy_io_ctrl_overcurrent                  ), //o
    .io_ctrl_tick                          (back_phy_io_ctrl_tick                         ), //o
    .io_ctrl_ports_0_disable_valid         (cc_output_ports_0_disable_valid               ), //i
    .io_ctrl_ports_0_disable_ready         (back_phy_io_ctrl_ports_0_disable_ready        ), //o
    .io_ctrl_ports_0_removable             (cc_output_ports_0_removable                   ), //i
    .io_ctrl_ports_0_power                 (cc_output_ports_0_power                       ), //i
    .io_ctrl_ports_0_reset_valid           (cc_output_ports_0_reset_valid                 ), //i
    .io_ctrl_ports_0_reset_ready           (back_phy_io_ctrl_ports_0_reset_ready          ), //o
    .io_ctrl_ports_0_suspend_valid         (cc_output_ports_0_suspend_valid               ), //i
    .io_ctrl_ports_0_suspend_ready         (back_phy_io_ctrl_ports_0_suspend_ready        ), //o
    .io_ctrl_ports_0_resume_valid          (cc_output_ports_0_resume_valid                ), //i
    .io_ctrl_ports_0_resume_ready          (back_phy_io_ctrl_ports_0_resume_ready         ), //o
    .io_ctrl_ports_0_connect               (back_phy_io_ctrl_ports_0_connect              ), //o
    .io_ctrl_ports_0_disconnect            (back_phy_io_ctrl_ports_0_disconnect           ), //o
    .io_ctrl_ports_0_overcurrent           (back_phy_io_ctrl_ports_0_overcurrent          ), //o
    .io_ctrl_ports_0_remoteResume          (back_phy_io_ctrl_ports_0_remoteResume         ), //o
    .io_ctrl_ports_0_lowSpeed              (back_phy_io_ctrl_ports_0_lowSpeed             ), //o
    .io_ctrl_ports_1_disable_valid         (cc_output_ports_1_disable_valid               ), //i
    .io_ctrl_ports_1_disable_ready         (back_phy_io_ctrl_ports_1_disable_ready        ), //o
    .io_ctrl_ports_1_removable             (cc_output_ports_1_removable                   ), //i
    .io_ctrl_ports_1_power                 (cc_output_ports_1_power                       ), //i
    .io_ctrl_ports_1_reset_valid           (cc_output_ports_1_reset_valid                 ), //i
    .io_ctrl_ports_1_reset_ready           (back_phy_io_ctrl_ports_1_reset_ready          ), //o
    .io_ctrl_ports_1_suspend_valid         (cc_output_ports_1_suspend_valid               ), //i
    .io_ctrl_ports_1_suspend_ready         (back_phy_io_ctrl_ports_1_suspend_ready        ), //o
    .io_ctrl_ports_1_resume_valid          (cc_output_ports_1_resume_valid                ), //i
    .io_ctrl_ports_1_resume_ready          (back_phy_io_ctrl_ports_1_resume_ready         ), //o
    .io_ctrl_ports_1_connect               (back_phy_io_ctrl_ports_1_connect              ), //o
    .io_ctrl_ports_1_disconnect            (back_phy_io_ctrl_ports_1_disconnect           ), //o
    .io_ctrl_ports_1_overcurrent           (back_phy_io_ctrl_ports_1_overcurrent          ), //o
    .io_ctrl_ports_1_remoteResume          (back_phy_io_ctrl_ports_1_remoteResume         ), //o
    .io_ctrl_ports_1_lowSpeed              (back_phy_io_ctrl_ports_1_lowSpeed             ), //o
    .io_ctrl_ports_2_disable_valid         (cc_output_ports_2_disable_valid               ), //i
    .io_ctrl_ports_2_disable_ready         (back_phy_io_ctrl_ports_2_disable_ready        ), //o
    .io_ctrl_ports_2_removable             (cc_output_ports_2_removable                   ), //i
    .io_ctrl_ports_2_power                 (cc_output_ports_2_power                       ), //i
    .io_ctrl_ports_2_reset_valid           (cc_output_ports_2_reset_valid                 ), //i
    .io_ctrl_ports_2_reset_ready           (back_phy_io_ctrl_ports_2_reset_ready          ), //o
    .io_ctrl_ports_2_suspend_valid         (cc_output_ports_2_suspend_valid               ), //i
    .io_ctrl_ports_2_suspend_ready         (back_phy_io_ctrl_ports_2_suspend_ready        ), //o
    .io_ctrl_ports_2_resume_valid          (cc_output_ports_2_resume_valid                ), //i
    .io_ctrl_ports_2_resume_ready          (back_phy_io_ctrl_ports_2_resume_ready         ), //o
    .io_ctrl_ports_2_connect               (back_phy_io_ctrl_ports_2_connect              ), //o
    .io_ctrl_ports_2_disconnect            (back_phy_io_ctrl_ports_2_disconnect           ), //o
    .io_ctrl_ports_2_overcurrent           (back_phy_io_ctrl_ports_2_overcurrent          ), //o
    .io_ctrl_ports_2_remoteResume          (back_phy_io_ctrl_ports_2_remoteResume         ), //o
    .io_ctrl_ports_2_lowSpeed              (back_phy_io_ctrl_ports_2_lowSpeed             ), //o
    .io_ctrl_ports_3_disable_valid         (cc_output_ports_3_disable_valid               ), //i
    .io_ctrl_ports_3_disable_ready         (back_phy_io_ctrl_ports_3_disable_ready        ), //o
    .io_ctrl_ports_3_removable             (cc_output_ports_3_removable                   ), //i
    .io_ctrl_ports_3_power                 (cc_output_ports_3_power                       ), //i
    .io_ctrl_ports_3_reset_valid           (cc_output_ports_3_reset_valid                 ), //i
    .io_ctrl_ports_3_reset_ready           (back_phy_io_ctrl_ports_3_reset_ready          ), //o
    .io_ctrl_ports_3_suspend_valid         (cc_output_ports_3_suspend_valid               ), //i
    .io_ctrl_ports_3_suspend_ready         (back_phy_io_ctrl_ports_3_suspend_ready        ), //o
    .io_ctrl_ports_3_resume_valid          (cc_output_ports_3_resume_valid                ), //i
    .io_ctrl_ports_3_resume_ready          (back_phy_io_ctrl_ports_3_resume_ready         ), //o
    .io_ctrl_ports_3_connect               (back_phy_io_ctrl_ports_3_connect              ), //o
    .io_ctrl_ports_3_disconnect            (back_phy_io_ctrl_ports_3_disconnect           ), //o
    .io_ctrl_ports_3_overcurrent           (back_phy_io_ctrl_ports_3_overcurrent          ), //o
    .io_ctrl_ports_3_remoteResume          (back_phy_io_ctrl_ports_3_remoteResume         ), //o
    .io_ctrl_ports_3_lowSpeed              (back_phy_io_ctrl_ports_3_lowSpeed             ), //o
    .io_usb_0_tx_enable                    (back_phy_io_usb_0_tx_enable                   ), //o
    .io_usb_0_tx_data                      (back_phy_io_usb_0_tx_data                     ), //o
    .io_usb_0_tx_se0                       (back_phy_io_usb_0_tx_se0                      ), //o
    .io_usb_0_rx_dp                        (back_native_0_dp_read                         ), //i
    .io_usb_0_rx_dm                        (back_native_0_dm_read                         ), //i
    .io_usb_1_tx_enable                    (back_phy_io_usb_1_tx_enable                   ), //o
    .io_usb_1_tx_data                      (back_phy_io_usb_1_tx_data                     ), //o
    .io_usb_1_tx_se0                       (back_phy_io_usb_1_tx_se0                      ), //o
    .io_usb_1_rx_dp                        (back_native_1_dp_read                         ), //i
    .io_usb_1_rx_dm                        (back_native_1_dm_read                         ), //i
    .io_usb_2_tx_enable                    (back_phy_io_usb_2_tx_enable                   ), //o
    .io_usb_2_tx_data                      (back_phy_io_usb_2_tx_data                     ), //o
    .io_usb_2_tx_se0                       (back_phy_io_usb_2_tx_se0                      ), //o
    .io_usb_2_rx_dp                        (back_native_2_dp_read                         ), //i
    .io_usb_2_rx_dm                        (back_native_2_dm_read                         ), //i
    .io_usb_3_tx_enable                    (back_phy_io_usb_3_tx_enable                   ), //o
    .io_usb_3_tx_data                      (back_phy_io_usb_3_tx_data                     ), //o
    .io_usb_3_tx_se0                       (back_phy_io_usb_3_tx_se0                      ), //o
    .io_usb_3_rx_dp                        (back_native_3_dp_read                         ), //i
    .io_usb_3_rx_dm                        (back_native_3_dm_read                         ), //i
    .io_management_0_overcurrent           (back_phy_io_management_0_overcurrent          ), //i
    .io_management_0_power                 (back_phy_io_management_0_power                ), //o
    .io_management_1_overcurrent           (back_phy_io_management_1_overcurrent          ), //i
    .io_management_1_power                 (back_phy_io_management_1_power                ), //o
    .io_management_2_overcurrent           (back_phy_io_management_2_overcurrent          ), //i
    .io_management_2_power                 (back_phy_io_management_2_power                ), //o
    .io_management_3_overcurrent           (back_phy_io_management_3_overcurrent          ), //i
    .io_management_3_power                 (back_phy_io_management_3_power                ), //o
    .phy_clk                               (phy_clk                                       ), //i
    .phy_reset                             (phy_reset                                     )  //i
  );
  UsbOhciAxi4_BufferCC_8 back_buffer_0_dp_read_buffercc (
    .io_dataIn  (back_buffer_0_dp_read                    ), //i
    .io_dataOut (back_buffer_0_dp_read_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                  ), //i
    .phy_reset  (phy_reset                                )  //i
  );
  UsbOhciAxi4_BufferCC_8 back_buffer_0_dm_read_buffercc (
    .io_dataIn  (back_buffer_0_dm_read                    ), //i
    .io_dataOut (back_buffer_0_dm_read_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                  ), //i
    .phy_reset  (phy_reset                                )  //i
  );
  UsbOhciAxi4_BufferCC_8 back_buffer_1_dp_read_buffercc (
    .io_dataIn  (back_buffer_1_dp_read                    ), //i
    .io_dataOut (back_buffer_1_dp_read_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                  ), //i
    .phy_reset  (phy_reset                                )  //i
  );
  UsbOhciAxi4_BufferCC_8 back_buffer_1_dm_read_buffercc (
    .io_dataIn  (back_buffer_1_dm_read                    ), //i
    .io_dataOut (back_buffer_1_dm_read_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                  ), //i
    .phy_reset  (phy_reset                                )  //i
  );
  UsbOhciAxi4_BufferCC_8 back_buffer_2_dp_read_buffercc (
    .io_dataIn  (back_buffer_2_dp_read                    ), //i
    .io_dataOut (back_buffer_2_dp_read_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                  ), //i
    .phy_reset  (phy_reset                                )  //i
  );
  UsbOhciAxi4_BufferCC_8 back_buffer_2_dm_read_buffercc (
    .io_dataIn  (back_buffer_2_dm_read                    ), //i
    .io_dataOut (back_buffer_2_dm_read_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                  ), //i
    .phy_reset  (phy_reset                                )  //i
  );
  UsbOhciAxi4_BufferCC_8 back_buffer_3_dp_read_buffercc (
    .io_dataIn  (back_buffer_3_dp_read                    ), //i
    .io_dataOut (back_buffer_3_dp_read_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                  ), //i
    .phy_reset  (phy_reset                                )  //i
  );
  UsbOhciAxi4_BufferCC_8 back_buffer_3_dm_read_buffercc (
    .io_dataIn  (back_buffer_3_dm_read                    ), //i
    .io_dataOut (back_buffer_3_dm_read_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                  ), //i
    .phy_reset  (phy_reset                                )  //i
  );
  UsbOhciAxi4_CtrlCc cc (
    .input_lowSpeed                       (front_ohci_io_phy_lowSpeed                    ), //i
    .input_tx_valid                       (front_ohci_io_phy_tx_valid                    ), //i
    .input_tx_ready                       (cc_input_tx_ready                             ), //o
    .input_tx_payload_last                (front_ohci_io_phy_tx_payload_last             ), //i
    .input_tx_payload_fragment            (front_ohci_io_phy_tx_payload_fragment[7:0]    ), //i
    .input_txEop                          (cc_input_txEop                                ), //o
    .input_rx_flow_valid                  (cc_input_rx_flow_valid                        ), //o
    .input_rx_flow_payload_stuffingError  (cc_input_rx_flow_payload_stuffingError        ), //o
    .input_rx_flow_payload_data           (cc_input_rx_flow_payload_data[7:0]            ), //o
    .input_rx_active                      (cc_input_rx_active                            ), //o
    .input_usbReset                       (front_ohci_io_phy_usbReset                    ), //i
    .input_usbResume                      (front_ohci_io_phy_usbResume                   ), //i
    .input_overcurrent                    (cc_input_overcurrent                          ), //o
    .input_tick                           (cc_input_tick                                 ), //o
    .input_ports_0_disable_valid          (front_ohci_io_phy_ports_0_disable_valid       ), //i
    .input_ports_0_disable_ready          (cc_input_ports_0_disable_ready                ), //o
    .input_ports_0_removable              (front_ohci_io_phy_ports_0_removable           ), //i
    .input_ports_0_power                  (front_ohci_io_phy_ports_0_power               ), //i
    .input_ports_0_reset_valid            (front_ohci_io_phy_ports_0_reset_valid         ), //i
    .input_ports_0_reset_ready            (cc_input_ports_0_reset_ready                  ), //o
    .input_ports_0_suspend_valid          (front_ohci_io_phy_ports_0_suspend_valid       ), //i
    .input_ports_0_suspend_ready          (cc_input_ports_0_suspend_ready                ), //o
    .input_ports_0_resume_valid           (front_ohci_io_phy_ports_0_resume_valid        ), //i
    .input_ports_0_resume_ready           (cc_input_ports_0_resume_ready                 ), //o
    .input_ports_0_connect                (cc_input_ports_0_connect                      ), //o
    .input_ports_0_disconnect             (cc_input_ports_0_disconnect                   ), //o
    .input_ports_0_overcurrent            (cc_input_ports_0_overcurrent                  ), //o
    .input_ports_0_remoteResume           (cc_input_ports_0_remoteResume                 ), //o
    .input_ports_0_lowSpeed               (cc_input_ports_0_lowSpeed                     ), //o
    .input_ports_1_disable_valid          (front_ohci_io_phy_ports_1_disable_valid       ), //i
    .input_ports_1_disable_ready          (cc_input_ports_1_disable_ready                ), //o
    .input_ports_1_removable              (front_ohci_io_phy_ports_1_removable           ), //i
    .input_ports_1_power                  (front_ohci_io_phy_ports_1_power               ), //i
    .input_ports_1_reset_valid            (front_ohci_io_phy_ports_1_reset_valid         ), //i
    .input_ports_1_reset_ready            (cc_input_ports_1_reset_ready                  ), //o
    .input_ports_1_suspend_valid          (front_ohci_io_phy_ports_1_suspend_valid       ), //i
    .input_ports_1_suspend_ready          (cc_input_ports_1_suspend_ready                ), //o
    .input_ports_1_resume_valid           (front_ohci_io_phy_ports_1_resume_valid        ), //i
    .input_ports_1_resume_ready           (cc_input_ports_1_resume_ready                 ), //o
    .input_ports_1_connect                (cc_input_ports_1_connect                      ), //o
    .input_ports_1_disconnect             (cc_input_ports_1_disconnect                   ), //o
    .input_ports_1_overcurrent            (cc_input_ports_1_overcurrent                  ), //o
    .input_ports_1_remoteResume           (cc_input_ports_1_remoteResume                 ), //o
    .input_ports_1_lowSpeed               (cc_input_ports_1_lowSpeed                     ), //o
    .input_ports_2_disable_valid          (front_ohci_io_phy_ports_2_disable_valid       ), //i
    .input_ports_2_disable_ready          (cc_input_ports_2_disable_ready                ), //o
    .input_ports_2_removable              (front_ohci_io_phy_ports_2_removable           ), //i
    .input_ports_2_power                  (front_ohci_io_phy_ports_2_power               ), //i
    .input_ports_2_reset_valid            (front_ohci_io_phy_ports_2_reset_valid         ), //i
    .input_ports_2_reset_ready            (cc_input_ports_2_reset_ready                  ), //o
    .input_ports_2_suspend_valid          (front_ohci_io_phy_ports_2_suspend_valid       ), //i
    .input_ports_2_suspend_ready          (cc_input_ports_2_suspend_ready                ), //o
    .input_ports_2_resume_valid           (front_ohci_io_phy_ports_2_resume_valid        ), //i
    .input_ports_2_resume_ready           (cc_input_ports_2_resume_ready                 ), //o
    .input_ports_2_connect                (cc_input_ports_2_connect                      ), //o
    .input_ports_2_disconnect             (cc_input_ports_2_disconnect                   ), //o
    .input_ports_2_overcurrent            (cc_input_ports_2_overcurrent                  ), //o
    .input_ports_2_remoteResume           (cc_input_ports_2_remoteResume                 ), //o
    .input_ports_2_lowSpeed               (cc_input_ports_2_lowSpeed                     ), //o
    .input_ports_3_disable_valid          (front_ohci_io_phy_ports_3_disable_valid       ), //i
    .input_ports_3_disable_ready          (cc_input_ports_3_disable_ready                ), //o
    .input_ports_3_removable              (front_ohci_io_phy_ports_3_removable           ), //i
    .input_ports_3_power                  (front_ohci_io_phy_ports_3_power               ), //i
    .input_ports_3_reset_valid            (front_ohci_io_phy_ports_3_reset_valid         ), //i
    .input_ports_3_reset_ready            (cc_input_ports_3_reset_ready                  ), //o
    .input_ports_3_suspend_valid          (front_ohci_io_phy_ports_3_suspend_valid       ), //i
    .input_ports_3_suspend_ready          (cc_input_ports_3_suspend_ready                ), //o
    .input_ports_3_resume_valid           (front_ohci_io_phy_ports_3_resume_valid        ), //i
    .input_ports_3_resume_ready           (cc_input_ports_3_resume_ready                 ), //o
    .input_ports_3_connect                (cc_input_ports_3_connect                      ), //o
    .input_ports_3_disconnect             (cc_input_ports_3_disconnect                   ), //o
    .input_ports_3_overcurrent            (cc_input_ports_3_overcurrent                  ), //o
    .input_ports_3_remoteResume           (cc_input_ports_3_remoteResume                 ), //o
    .input_ports_3_lowSpeed               (cc_input_ports_3_lowSpeed                     ), //o
    .output_lowSpeed                      (cc_output_lowSpeed                            ), //o
    .output_tx_valid                      (cc_output_tx_valid                            ), //o
    .output_tx_ready                      (back_phy_io_ctrl_tx_ready                     ), //i
    .output_tx_payload_last               (cc_output_tx_payload_last                     ), //o
    .output_tx_payload_fragment           (cc_output_tx_payload_fragment[7:0]            ), //o
    .output_txEop                         (back_phy_io_ctrl_txEop                        ), //i
    .output_rx_flow_valid                 (back_phy_io_ctrl_rx_flow_valid                ), //i
    .output_rx_flow_payload_stuffingError (back_phy_io_ctrl_rx_flow_payload_stuffingError), //i
    .output_rx_flow_payload_data          (back_phy_io_ctrl_rx_flow_payload_data[7:0]    ), //i
    .output_rx_active                     (back_phy_io_ctrl_rx_active                    ), //i
    .output_usbReset                      (cc_output_usbReset                            ), //o
    .output_usbResume                     (cc_output_usbResume                           ), //o
    .output_overcurrent                   (back_phy_io_ctrl_overcurrent                  ), //i
    .output_tick                          (back_phy_io_ctrl_tick                         ), //i
    .output_ports_0_disable_valid         (cc_output_ports_0_disable_valid               ), //o
    .output_ports_0_disable_ready         (back_phy_io_ctrl_ports_0_disable_ready        ), //i
    .output_ports_0_removable             (cc_output_ports_0_removable                   ), //o
    .output_ports_0_power                 (cc_output_ports_0_power                       ), //o
    .output_ports_0_reset_valid           (cc_output_ports_0_reset_valid                 ), //o
    .output_ports_0_reset_ready           (back_phy_io_ctrl_ports_0_reset_ready          ), //i
    .output_ports_0_suspend_valid         (cc_output_ports_0_suspend_valid               ), //o
    .output_ports_0_suspend_ready         (back_phy_io_ctrl_ports_0_suspend_ready        ), //i
    .output_ports_0_resume_valid          (cc_output_ports_0_resume_valid                ), //o
    .output_ports_0_resume_ready          (back_phy_io_ctrl_ports_0_resume_ready         ), //i
    .output_ports_0_connect               (back_phy_io_ctrl_ports_0_connect              ), //i
    .output_ports_0_disconnect            (back_phy_io_ctrl_ports_0_disconnect           ), //i
    .output_ports_0_overcurrent           (back_phy_io_ctrl_ports_0_overcurrent          ), //i
    .output_ports_0_remoteResume          (back_phy_io_ctrl_ports_0_remoteResume         ), //i
    .output_ports_0_lowSpeed              (back_phy_io_ctrl_ports_0_lowSpeed             ), //i
    .output_ports_1_disable_valid         (cc_output_ports_1_disable_valid               ), //o
    .output_ports_1_disable_ready         (back_phy_io_ctrl_ports_1_disable_ready        ), //i
    .output_ports_1_removable             (cc_output_ports_1_removable                   ), //o
    .output_ports_1_power                 (cc_output_ports_1_power                       ), //o
    .output_ports_1_reset_valid           (cc_output_ports_1_reset_valid                 ), //o
    .output_ports_1_reset_ready           (back_phy_io_ctrl_ports_1_reset_ready          ), //i
    .output_ports_1_suspend_valid         (cc_output_ports_1_suspend_valid               ), //o
    .output_ports_1_suspend_ready         (back_phy_io_ctrl_ports_1_suspend_ready        ), //i
    .output_ports_1_resume_valid          (cc_output_ports_1_resume_valid                ), //o
    .output_ports_1_resume_ready          (back_phy_io_ctrl_ports_1_resume_ready         ), //i
    .output_ports_1_connect               (back_phy_io_ctrl_ports_1_connect              ), //i
    .output_ports_1_disconnect            (back_phy_io_ctrl_ports_1_disconnect           ), //i
    .output_ports_1_overcurrent           (back_phy_io_ctrl_ports_1_overcurrent          ), //i
    .output_ports_1_remoteResume          (back_phy_io_ctrl_ports_1_remoteResume         ), //i
    .output_ports_1_lowSpeed              (back_phy_io_ctrl_ports_1_lowSpeed             ), //i
    .output_ports_2_disable_valid         (cc_output_ports_2_disable_valid               ), //o
    .output_ports_2_disable_ready         (back_phy_io_ctrl_ports_2_disable_ready        ), //i
    .output_ports_2_removable             (cc_output_ports_2_removable                   ), //o
    .output_ports_2_power                 (cc_output_ports_2_power                       ), //o
    .output_ports_2_reset_valid           (cc_output_ports_2_reset_valid                 ), //o
    .output_ports_2_reset_ready           (back_phy_io_ctrl_ports_2_reset_ready          ), //i
    .output_ports_2_suspend_valid         (cc_output_ports_2_suspend_valid               ), //o
    .output_ports_2_suspend_ready         (back_phy_io_ctrl_ports_2_suspend_ready        ), //i
    .output_ports_2_resume_valid          (cc_output_ports_2_resume_valid                ), //o
    .output_ports_2_resume_ready          (back_phy_io_ctrl_ports_2_resume_ready         ), //i
    .output_ports_2_connect               (back_phy_io_ctrl_ports_2_connect              ), //i
    .output_ports_2_disconnect            (back_phy_io_ctrl_ports_2_disconnect           ), //i
    .output_ports_2_overcurrent           (back_phy_io_ctrl_ports_2_overcurrent          ), //i
    .output_ports_2_remoteResume          (back_phy_io_ctrl_ports_2_remoteResume         ), //i
    .output_ports_2_lowSpeed              (back_phy_io_ctrl_ports_2_lowSpeed             ), //i
    .output_ports_3_disable_valid         (cc_output_ports_3_disable_valid               ), //o
    .output_ports_3_disable_ready         (back_phy_io_ctrl_ports_3_disable_ready        ), //i
    .output_ports_3_removable             (cc_output_ports_3_removable                   ), //o
    .output_ports_3_power                 (cc_output_ports_3_power                       ), //o
    .output_ports_3_reset_valid           (cc_output_ports_3_reset_valid                 ), //o
    .output_ports_3_reset_ready           (back_phy_io_ctrl_ports_3_reset_ready          ), //i
    .output_ports_3_suspend_valid         (cc_output_ports_3_suspend_valid               ), //o
    .output_ports_3_suspend_ready         (back_phy_io_ctrl_ports_3_suspend_ready        ), //i
    .output_ports_3_resume_valid          (cc_output_ports_3_resume_valid                ), //o
    .output_ports_3_resume_ready          (back_phy_io_ctrl_ports_3_resume_ready         ), //i
    .output_ports_3_connect               (back_phy_io_ctrl_ports_3_connect              ), //i
    .output_ports_3_disconnect            (back_phy_io_ctrl_ports_3_disconnect           ), //i
    .output_ports_3_overcurrent           (back_phy_io_ctrl_ports_3_overcurrent          ), //i
    .output_ports_3_remoteResume          (back_phy_io_ctrl_ports_3_remoteResume         ), //i
    .output_ports_3_lowSpeed              (back_phy_io_ctrl_ports_3_lowSpeed             ), //i
    .phy_clk                              (phy_clk                                       ), //i
    .phy_reset                            (phy_reset                                     ), //i
    .ctrl_clk                             (ctrl_clk                                      ), //i
    .ctrl_reset                           (ctrl_reset                                    )  //i
  );
  assign front_dmaBridge_io_output_arw_ready = (front_dmaBridge_io_output_arw_payload_write ? io_dma_aw_ready : io_dma_ar_ready);
  assign io_dma_aw_valid = (front_dmaBridge_io_output_arw_valid && front_dmaBridge_io_output_arw_payload_write);
  assign io_dma_aw_payload_addr = front_dmaBridge_io_output_arw_payload_addr;
  assign io_dma_aw_payload_len = front_dmaBridge_io_output_arw_payload_len;
  assign io_dma_aw_payload_size = front_dmaBridge_io_output_arw_payload_size;
  assign io_dma_aw_payload_cache = front_dmaBridge_io_output_arw_payload_cache;
  assign io_dma_aw_payload_prot = front_dmaBridge_io_output_arw_payload_prot;
  assign io_dma_w_valid = front_dmaBridge_io_output_w_valid;
  assign io_dma_w_payload_data = front_dmaBridge_io_output_w_payload_data;
  assign io_dma_w_payload_strb = front_dmaBridge_io_output_w_payload_strb;
  assign io_dma_w_payload_last = front_dmaBridge_io_output_w_payload_last;
  assign io_dma_b_ready = front_dmaBridge_io_output_b_ready;
  assign io_dma_ar_valid = (front_dmaBridge_io_output_arw_valid && (! front_dmaBridge_io_output_arw_payload_write));
  assign io_dma_ar_payload_addr = front_dmaBridge_io_output_arw_payload_addr;
  assign io_dma_ar_payload_len = front_dmaBridge_io_output_arw_payload_len;
  assign io_dma_ar_payload_size = front_dmaBridge_io_output_arw_payload_size;
  assign io_dma_ar_payload_cache = front_dmaBridge_io_output_arw_payload_cache;
  assign io_dma_ar_payload_prot = front_dmaBridge_io_output_arw_payload_prot;
  assign io_dma_r_ready = front_dmaBridge_io_output_r_ready;
  assign io_ctrl_ar_ready = streamArbiter_io_inputs_0_ready;
  assign io_ctrl_aw_ready = streamArbiter_io_inputs_1_ready;
  assign io_ctrl_w_ready = front_ctrlBridge_io_axi_w_ready;
  assign io_ctrl_b_valid = front_ctrlBridge_io_axi_b_valid;
  assign io_ctrl_b_payload_id = front_ctrlBridge_io_axi_b_payload_id;
  assign io_ctrl_b_payload_resp = front_ctrlBridge_io_axi_b_payload_resp;
  assign io_ctrl_r_valid = front_ctrlBridge_io_axi_r_valid;
  assign io_ctrl_r_payload_data = front_ctrlBridge_io_axi_r_payload_data;
  assign io_ctrl_r_payload_id = front_ctrlBridge_io_axi_r_payload_id;
  assign io_ctrl_r_payload_resp = front_ctrlBridge_io_axi_r_payload_resp;
  assign io_ctrl_r_payload_last = front_ctrlBridge_io_axi_r_payload_last;
  assign front_ctrlBridge_io_axi_arw_payload_write = streamArbiter_io_chosenOH[1];
  assign io_interrupt = front_ohci_io_interrupt;
  assign back_phy_io_management_0_overcurrent = 1'b0;
  assign back_phy_io_management_1_overcurrent = 1'b0;
  assign back_phy_io_management_2_overcurrent = 1'b0;
  assign back_phy_io_management_3_overcurrent = 1'b0;
  assign back_native_0_dp_writeEnable = back_phy_io_usb_0_tx_enable;
  assign back_native_0_dm_writeEnable = back_phy_io_usb_0_tx_enable;
  assign back_native_0_dp_write = ((! back_phy_io_usb_0_tx_se0) && back_phy_io_usb_0_tx_data);
  assign back_native_0_dm_write = ((! back_phy_io_usb_0_tx_se0) && (! back_phy_io_usb_0_tx_data));
  assign back_native_1_dp_writeEnable = back_phy_io_usb_1_tx_enable;
  assign back_native_1_dm_writeEnable = back_phy_io_usb_1_tx_enable;
  assign back_native_1_dp_write = ((! back_phy_io_usb_1_tx_se0) && back_phy_io_usb_1_tx_data);
  assign back_native_1_dm_write = ((! back_phy_io_usb_1_tx_se0) && (! back_phy_io_usb_1_tx_data));
  assign back_native_2_dp_writeEnable = back_phy_io_usb_2_tx_enable;
  assign back_native_2_dm_writeEnable = back_phy_io_usb_2_tx_enable;
  assign back_native_2_dp_write = ((! back_phy_io_usb_2_tx_se0) && back_phy_io_usb_2_tx_data);
  assign back_native_2_dm_write = ((! back_phy_io_usb_2_tx_se0) && (! back_phy_io_usb_2_tx_data));
  assign back_native_3_dp_writeEnable = back_phy_io_usb_3_tx_enable;
  assign back_native_3_dm_writeEnable = back_phy_io_usb_3_tx_enable;
  assign back_native_3_dp_write = ((! back_phy_io_usb_3_tx_se0) && back_phy_io_usb_3_tx_data);
  assign back_native_3_dm_write = ((! back_phy_io_usb_3_tx_se0) && (! back_phy_io_usb_3_tx_data));
  assign back_buffer_0_dp_write = back_native_0_dp_write_delay_2;
  assign back_buffer_0_dp_writeEnable = back_native_0_dp_writeEnable_delay_2;
  assign back_native_0_dp_read = back_buffer_0_dp_read_buffercc_io_dataOut;
  assign back_buffer_0_dm_write = back_native_0_dm_write_delay_2;
  assign back_buffer_0_dm_writeEnable = back_native_0_dm_writeEnable_delay_2;
  assign back_native_0_dm_read = back_buffer_0_dm_read_buffercc_io_dataOut;
  assign back_buffer_1_dp_write = back_native_1_dp_write_delay_2;
  assign back_buffer_1_dp_writeEnable = back_native_1_dp_writeEnable_delay_2;
  assign back_native_1_dp_read = back_buffer_1_dp_read_buffercc_io_dataOut;
  assign back_buffer_1_dm_write = back_native_1_dm_write_delay_2;
  assign back_buffer_1_dm_writeEnable = back_native_1_dm_writeEnable_delay_2;
  assign back_native_1_dm_read = back_buffer_1_dm_read_buffercc_io_dataOut;
  assign back_buffer_2_dp_write = back_native_2_dp_write_delay_2;
  assign back_buffer_2_dp_writeEnable = back_native_2_dp_writeEnable_delay_2;
  assign back_native_2_dp_read = back_buffer_2_dp_read_buffercc_io_dataOut;
  assign back_buffer_2_dm_write = back_native_2_dm_write_delay_2;
  assign back_buffer_2_dm_writeEnable = back_native_2_dm_writeEnable_delay_2;
  assign back_native_2_dm_read = back_buffer_2_dm_read_buffercc_io_dataOut;
  assign back_buffer_3_dp_write = back_native_3_dp_write_delay_2;
  assign back_buffer_3_dp_writeEnable = back_native_3_dp_writeEnable_delay_2;
  assign back_native_3_dp_read = back_buffer_3_dp_read_buffercc_io_dataOut;
  assign back_buffer_3_dm_write = back_native_3_dm_write_delay_2;
  assign back_buffer_3_dm_writeEnable = back_native_3_dm_writeEnable_delay_2;
  assign back_native_3_dm_read = back_buffer_3_dm_read_buffercc_io_dataOut;
  assign back_buffer_0_dp_read = io_usb_0_dp_read;
  assign io_usb_0_dp_write = back_buffer_0_dp_write;
  assign io_usb_0_dp_writeEnable = back_buffer_0_dp_writeEnable;
  assign back_buffer_0_dm_read = io_usb_0_dm_read;
  assign io_usb_0_dm_write = back_buffer_0_dm_write;
  assign io_usb_0_dm_writeEnable = back_buffer_0_dm_writeEnable;
  assign back_buffer_1_dp_read = io_usb_1_dp_read;
  assign io_usb_1_dp_write = back_buffer_1_dp_write;
  assign io_usb_1_dp_writeEnable = back_buffer_1_dp_writeEnable;
  assign back_buffer_1_dm_read = io_usb_1_dm_read;
  assign io_usb_1_dm_write = back_buffer_1_dm_write;
  assign io_usb_1_dm_writeEnable = back_buffer_1_dm_writeEnable;
  assign back_buffer_2_dp_read = io_usb_2_dp_read;
  assign io_usb_2_dp_write = back_buffer_2_dp_write;
  assign io_usb_2_dp_writeEnable = back_buffer_2_dp_writeEnable;
  assign back_buffer_2_dm_read = io_usb_2_dm_read;
  assign io_usb_2_dm_write = back_buffer_2_dm_write;
  assign io_usb_2_dm_writeEnable = back_buffer_2_dm_writeEnable;
  assign back_buffer_3_dp_read = io_usb_3_dp_read;
  assign io_usb_3_dp_write = back_buffer_3_dp_write;
  assign io_usb_3_dp_writeEnable = back_buffer_3_dp_writeEnable;
  assign back_buffer_3_dm_read = io_usb_3_dm_read;
  assign io_usb_3_dm_write = back_buffer_3_dm_write;
  assign io_usb_3_dm_writeEnable = back_buffer_3_dm_writeEnable;
  always @(posedge phy_clk) begin
    back_native_0_dp_write_delay_1 <= back_native_0_dp_write;
    back_native_0_dp_write_delay_2 <= back_native_0_dp_write_delay_1;
    back_native_0_dp_writeEnable_delay_1 <= back_native_0_dp_writeEnable;
    back_native_0_dp_writeEnable_delay_2 <= back_native_0_dp_writeEnable_delay_1;
    back_native_0_dm_write_delay_1 <= back_native_0_dm_write;
    back_native_0_dm_write_delay_2 <= back_native_0_dm_write_delay_1;
    back_native_0_dm_writeEnable_delay_1 <= back_native_0_dm_writeEnable;
    back_native_0_dm_writeEnable_delay_2 <= back_native_0_dm_writeEnable_delay_1;
    back_native_1_dp_write_delay_1 <= back_native_1_dp_write;
    back_native_1_dp_write_delay_2 <= back_native_1_dp_write_delay_1;
    back_native_1_dp_writeEnable_delay_1 <= back_native_1_dp_writeEnable;
    back_native_1_dp_writeEnable_delay_2 <= back_native_1_dp_writeEnable_delay_1;
    back_native_1_dm_write_delay_1 <= back_native_1_dm_write;
    back_native_1_dm_write_delay_2 <= back_native_1_dm_write_delay_1;
    back_native_1_dm_writeEnable_delay_1 <= back_native_1_dm_writeEnable;
    back_native_1_dm_writeEnable_delay_2 <= back_native_1_dm_writeEnable_delay_1;
    back_native_2_dp_write_delay_1 <= back_native_2_dp_write;
    back_native_2_dp_write_delay_2 <= back_native_2_dp_write_delay_1;
    back_native_2_dp_writeEnable_delay_1 <= back_native_2_dp_writeEnable;
    back_native_2_dp_writeEnable_delay_2 <= back_native_2_dp_writeEnable_delay_1;
    back_native_2_dm_write_delay_1 <= back_native_2_dm_write;
    back_native_2_dm_write_delay_2 <= back_native_2_dm_write_delay_1;
    back_native_2_dm_writeEnable_delay_1 <= back_native_2_dm_writeEnable;
    back_native_2_dm_writeEnable_delay_2 <= back_native_2_dm_writeEnable_delay_1;
    back_native_3_dp_write_delay_1 <= back_native_3_dp_write;
    back_native_3_dp_write_delay_2 <= back_native_3_dp_write_delay_1;
    back_native_3_dp_writeEnable_delay_1 <= back_native_3_dp_writeEnable;
    back_native_3_dp_writeEnable_delay_2 <= back_native_3_dp_writeEnable_delay_1;
    back_native_3_dm_write_delay_1 <= back_native_3_dm_write;
    back_native_3_dm_write_delay_2 <= back_native_3_dm_write_delay_1;
    back_native_3_dm_writeEnable_delay_1 <= back_native_3_dm_writeEnable;
    back_native_3_dm_writeEnable_delay_2 <= back_native_3_dm_writeEnable_delay_1;
  end


endmodule

module UsbOhciAxi4_CtrlCc (
  input  wire          input_lowSpeed,
  input  wire          input_tx_valid,
  output wire          input_tx_ready,
  input  wire          input_tx_payload_last,
  input  wire [7:0]    input_tx_payload_fragment,
  output wire          input_txEop,
  output wire          input_rx_flow_valid,
  output wire          input_rx_flow_payload_stuffingError,
  output wire [7:0]    input_rx_flow_payload_data,
  output wire          input_rx_active,
  input  wire          input_usbReset,
  input  wire          input_usbResume,
  output wire          input_overcurrent,
  output wire          input_tick,
  input  wire          input_ports_0_disable_valid,
  output wire          input_ports_0_disable_ready,
  input  wire          input_ports_0_removable,
  input  wire          input_ports_0_power,
  input  wire          input_ports_0_reset_valid,
  output wire          input_ports_0_reset_ready,
  input  wire          input_ports_0_suspend_valid,
  output wire          input_ports_0_suspend_ready,
  input  wire          input_ports_0_resume_valid,
  output wire          input_ports_0_resume_ready,
  output wire          input_ports_0_connect,
  output wire          input_ports_0_disconnect,
  output wire          input_ports_0_overcurrent,
  output wire          input_ports_0_remoteResume,
  output wire          input_ports_0_lowSpeed,
  input  wire          input_ports_1_disable_valid,
  output wire          input_ports_1_disable_ready,
  input  wire          input_ports_1_removable,
  input  wire          input_ports_1_power,
  input  wire          input_ports_1_reset_valid,
  output wire          input_ports_1_reset_ready,
  input  wire          input_ports_1_suspend_valid,
  output wire          input_ports_1_suspend_ready,
  input  wire          input_ports_1_resume_valid,
  output wire          input_ports_1_resume_ready,
  output wire          input_ports_1_connect,
  output wire          input_ports_1_disconnect,
  output wire          input_ports_1_overcurrent,
  output wire          input_ports_1_remoteResume,
  output wire          input_ports_1_lowSpeed,
  input  wire          input_ports_2_disable_valid,
  output wire          input_ports_2_disable_ready,
  input  wire          input_ports_2_removable,
  input  wire          input_ports_2_power,
  input  wire          input_ports_2_reset_valid,
  output wire          input_ports_2_reset_ready,
  input  wire          input_ports_2_suspend_valid,
  output wire          input_ports_2_suspend_ready,
  input  wire          input_ports_2_resume_valid,
  output wire          input_ports_2_resume_ready,
  output wire          input_ports_2_connect,
  output wire          input_ports_2_disconnect,
  output wire          input_ports_2_overcurrent,
  output wire          input_ports_2_remoteResume,
  output wire          input_ports_2_lowSpeed,
  input  wire          input_ports_3_disable_valid,
  output wire          input_ports_3_disable_ready,
  input  wire          input_ports_3_removable,
  input  wire          input_ports_3_power,
  input  wire          input_ports_3_reset_valid,
  output wire          input_ports_3_reset_ready,
  input  wire          input_ports_3_suspend_valid,
  output wire          input_ports_3_suspend_ready,
  input  wire          input_ports_3_resume_valid,
  output wire          input_ports_3_resume_ready,
  output wire          input_ports_3_connect,
  output wire          input_ports_3_disconnect,
  output wire          input_ports_3_overcurrent,
  output wire          input_ports_3_remoteResume,
  output wire          input_ports_3_lowSpeed,
  output wire          output_lowSpeed,
  output wire          output_tx_valid,
  input  wire          output_tx_ready,
  output wire          output_tx_payload_last,
  output wire [7:0]    output_tx_payload_fragment,
  input  wire          output_txEop,
  input  wire          output_rx_flow_valid,
  input  wire          output_rx_flow_payload_stuffingError,
  input  wire [7:0]    output_rx_flow_payload_data,
  input  wire          output_rx_active,
  output wire          output_usbReset,
  output wire          output_usbResume,
  input  wire          output_overcurrent,
  input  wire          output_tick,
  output wire          output_ports_0_disable_valid,
  input  wire          output_ports_0_disable_ready,
  output wire          output_ports_0_removable,
  output wire          output_ports_0_power,
  output wire          output_ports_0_reset_valid,
  input  wire          output_ports_0_reset_ready,
  output wire          output_ports_0_suspend_valid,
  input  wire          output_ports_0_suspend_ready,
  output wire          output_ports_0_resume_valid,
  input  wire          output_ports_0_resume_ready,
  input  wire          output_ports_0_connect,
  input  wire          output_ports_0_disconnect,
  input  wire          output_ports_0_overcurrent,
  input  wire          output_ports_0_remoteResume,
  input  wire          output_ports_0_lowSpeed,
  output wire          output_ports_1_disable_valid,
  input  wire          output_ports_1_disable_ready,
  output wire          output_ports_1_removable,
  output wire          output_ports_1_power,
  output wire          output_ports_1_reset_valid,
  input  wire          output_ports_1_reset_ready,
  output wire          output_ports_1_suspend_valid,
  input  wire          output_ports_1_suspend_ready,
  output wire          output_ports_1_resume_valid,
  input  wire          output_ports_1_resume_ready,
  input  wire          output_ports_1_connect,
  input  wire          output_ports_1_disconnect,
  input  wire          output_ports_1_overcurrent,
  input  wire          output_ports_1_remoteResume,
  input  wire          output_ports_1_lowSpeed,
  output wire          output_ports_2_disable_valid,
  input  wire          output_ports_2_disable_ready,
  output wire          output_ports_2_removable,
  output wire          output_ports_2_power,
  output wire          output_ports_2_reset_valid,
  input  wire          output_ports_2_reset_ready,
  output wire          output_ports_2_suspend_valid,
  input  wire          output_ports_2_suspend_ready,
  output wire          output_ports_2_resume_valid,
  input  wire          output_ports_2_resume_ready,
  input  wire          output_ports_2_connect,
  input  wire          output_ports_2_disconnect,
  input  wire          output_ports_2_overcurrent,
  input  wire          output_ports_2_remoteResume,
  input  wire          output_ports_2_lowSpeed,
  output wire          output_ports_3_disable_valid,
  input  wire          output_ports_3_disable_ready,
  output wire          output_ports_3_removable,
  output wire          output_ports_3_power,
  output wire          output_ports_3_reset_valid,
  input  wire          output_ports_3_reset_ready,
  output wire          output_ports_3_suspend_valid,
  input  wire          output_ports_3_suspend_ready,
  output wire          output_ports_3_resume_valid,
  input  wire          output_ports_3_resume_ready,
  input  wire          output_ports_3_connect,
  input  wire          output_ports_3_disconnect,
  input  wire          output_ports_3_overcurrent,
  input  wire          output_ports_3_remoteResume,
  input  wire          output_ports_3_lowSpeed,
  input  wire          phy_clk,
  input  wire          phy_reset,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  reg                 input_tx_ccToggle_io_output_ready;
  wire                input_lowSpeed_buffercc_io_dataOut;
  wire                input_usbReset_buffercc_io_dataOut;
  wire                input_usbResume_buffercc_io_dataOut;
  wire                output_overcurrent_buffercc_io_dataOut;
  wire                input_tx_ccToggle_io_input_ready;
  wire                input_tx_ccToggle_io_output_valid;
  wire                input_tx_ccToggle_io_output_payload_last;
  wire       [7:0]    input_tx_ccToggle_io_output_payload_fragment;
  wire                input_tx_ccToggle_ctrl_reset_syncronized_1;
  wire                pulseCCByToggle_io_pulseOut;
  wire                pulseCCByToggle_phy_reset_syncronized_1;
  wire                output_rx_flow_ccToggle_io_output_valid;
  wire                output_rx_flow_ccToggle_io_output_payload_stuffingError;
  wire       [7:0]    output_rx_flow_ccToggle_io_output_payload_data;
  wire                output_rx_active_buffercc_io_dataOut;
  wire                pulseCCByToggle_1_io_pulseOut;
  wire                input_ports_0_removable_buffercc_io_dataOut;
  wire                input_ports_0_power_buffercc_io_dataOut;
  wire                output_ports_0_lowSpeed_buffercc_io_dataOut;
  wire                output_ports_0_overcurrent_buffercc_io_dataOut;
  wire                pulseCCByToggle_2_io_pulseOut;
  wire                pulseCCByToggle_3_io_pulseOut;
  wire                pulseCCByToggle_4_io_pulseOut;
  wire                input_ports_0_reset_ccToggle_io_input_ready;
  wire                input_ports_0_reset_ccToggle_io_output_valid;
  wire                input_ports_0_suspend_ccToggle_io_input_ready;
  wire                input_ports_0_suspend_ccToggle_io_output_valid;
  wire                input_ports_0_resume_ccToggle_io_input_ready;
  wire                input_ports_0_resume_ccToggle_io_output_valid;
  wire                input_ports_0_disable_ccToggle_io_input_ready;
  wire                input_ports_0_disable_ccToggle_io_output_valid;
  wire                input_ports_1_removable_buffercc_io_dataOut;
  wire                input_ports_1_power_buffercc_io_dataOut;
  wire                output_ports_1_lowSpeed_buffercc_io_dataOut;
  wire                output_ports_1_overcurrent_buffercc_io_dataOut;
  wire                pulseCCByToggle_5_io_pulseOut;
  wire                pulseCCByToggle_6_io_pulseOut;
  wire                pulseCCByToggle_7_io_pulseOut;
  wire                input_ports_1_reset_ccToggle_io_input_ready;
  wire                input_ports_1_reset_ccToggle_io_output_valid;
  wire                input_ports_1_suspend_ccToggle_io_input_ready;
  wire                input_ports_1_suspend_ccToggle_io_output_valid;
  wire                input_ports_1_resume_ccToggle_io_input_ready;
  wire                input_ports_1_resume_ccToggle_io_output_valid;
  wire                input_ports_1_disable_ccToggle_io_input_ready;
  wire                input_ports_1_disable_ccToggle_io_output_valid;
  wire                input_ports_2_removable_buffercc_io_dataOut;
  wire                input_ports_2_power_buffercc_io_dataOut;
  wire                output_ports_2_lowSpeed_buffercc_io_dataOut;
  wire                output_ports_2_overcurrent_buffercc_io_dataOut;
  wire                pulseCCByToggle_8_io_pulseOut;
  wire                pulseCCByToggle_9_io_pulseOut;
  wire                pulseCCByToggle_10_io_pulseOut;
  wire                input_ports_2_reset_ccToggle_io_input_ready;
  wire                input_ports_2_reset_ccToggle_io_output_valid;
  wire                input_ports_2_suspend_ccToggle_io_input_ready;
  wire                input_ports_2_suspend_ccToggle_io_output_valid;
  wire                input_ports_2_resume_ccToggle_io_input_ready;
  wire                input_ports_2_resume_ccToggle_io_output_valid;
  wire                input_ports_2_disable_ccToggle_io_input_ready;
  wire                input_ports_2_disable_ccToggle_io_output_valid;
  wire                input_ports_3_removable_buffercc_io_dataOut;
  wire                input_ports_3_power_buffercc_io_dataOut;
  wire                output_ports_3_lowSpeed_buffercc_io_dataOut;
  wire                output_ports_3_overcurrent_buffercc_io_dataOut;
  wire                pulseCCByToggle_11_io_pulseOut;
  wire                pulseCCByToggle_12_io_pulseOut;
  wire                pulseCCByToggle_13_io_pulseOut;
  wire                input_ports_3_reset_ccToggle_io_input_ready;
  wire                input_ports_3_reset_ccToggle_io_output_valid;
  wire                input_ports_3_suspend_ccToggle_io_input_ready;
  wire                input_ports_3_suspend_ccToggle_io_output_valid;
  wire                input_ports_3_resume_ccToggle_io_input_ready;
  wire                input_ports_3_resume_ccToggle_io_output_valid;
  wire                input_ports_3_disable_ccToggle_io_input_ready;
  wire                input_ports_3_disable_ccToggle_io_output_valid;
  wire                cc_input_tx_ccToggle_io_output_m2sPipe_valid;
  wire                cc_input_tx_ccToggle_io_output_m2sPipe_ready;
  wire                cc_input_tx_ccToggle_io_output_m2sPipe_payload_last;
  wire       [7:0]    cc_input_tx_ccToggle_io_output_m2sPipe_payload_fragment;
  reg                 cc_input_tx_ccToggle_io_output_rValid;
  reg                 cc_input_tx_ccToggle_io_output_rData_last;
  reg        [7:0]    cc_input_tx_ccToggle_io_output_rData_fragment;
  wire                when_Stream_l369;

  UsbOhciAxi4_BufferCC_8 input_lowSpeed_buffercc (
    .io_dataIn  (input_lowSpeed                    ), //i
    .io_dataOut (input_lowSpeed_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                           ), //i
    .phy_reset  (phy_reset                         )  //i
  );
  UsbOhciAxi4_BufferCC_8 input_usbReset_buffercc (
    .io_dataIn  (input_usbReset                    ), //i
    .io_dataOut (input_usbReset_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                           ), //i
    .phy_reset  (phy_reset                         )  //i
  );
  UsbOhciAxi4_BufferCC_8 input_usbResume_buffercc (
    .io_dataIn  (input_usbResume                    ), //i
    .io_dataOut (input_usbResume_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                            ), //i
    .phy_reset  (phy_reset                          )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_overcurrent_buffercc (
    .io_dataIn  (output_overcurrent                    ), //i
    .io_dataOut (output_overcurrent_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                              ), //i
    .ctrl_reset (ctrl_reset                            )  //i
  );
  UsbOhciAxi4_StreamCCByToggle input_tx_ccToggle (
    .io_input_valid             (input_tx_valid                                   ), //i
    .io_input_ready             (input_tx_ccToggle_io_input_ready                 ), //o
    .io_input_payload_last      (input_tx_payload_last                            ), //i
    .io_input_payload_fragment  (input_tx_payload_fragment[7:0]                   ), //i
    .io_output_valid            (input_tx_ccToggle_io_output_valid                ), //o
    .io_output_ready            (input_tx_ccToggle_io_output_ready                ), //i
    .io_output_payload_last     (input_tx_ccToggle_io_output_payload_last         ), //o
    .io_output_payload_fragment (input_tx_ccToggle_io_output_payload_fragment[7:0]), //o
    .ctrl_clk                   (ctrl_clk                                         ), //i
    .ctrl_reset                 (ctrl_reset                                       ), //i
    .phy_clk                    (phy_clk                                          ), //i
    .ctrl_reset_syncronized_1   (input_tx_ccToggle_ctrl_reset_syncronized_1       )  //o
  );
  UsbOhciAxi4_PulseCCByToggle pulseCCByToggle (
    .io_pulseIn              (output_txEop                           ), //i
    .io_pulseOut             (pulseCCByToggle_io_pulseOut            ), //o
    .phy_clk                 (phy_clk                                ), //i
    .phy_reset               (phy_reset                              ), //i
    .ctrl_clk                (ctrl_clk                               ), //i
    .phy_reset_syncronized_1 (pulseCCByToggle_phy_reset_syncronized_1)  //o
  );
  UsbOhciAxi4_FlowCCByToggle output_rx_flow_ccToggle (
    .io_input_valid                  (output_rx_flow_valid                                   ), //i
    .io_input_payload_stuffingError  (output_rx_flow_payload_stuffingError                   ), //i
    .io_input_payload_data           (output_rx_flow_payload_data[7:0]                       ), //i
    .io_output_valid                 (output_rx_flow_ccToggle_io_output_valid                ), //o
    .io_output_payload_stuffingError (output_rx_flow_ccToggle_io_output_payload_stuffingError), //o
    .io_output_payload_data          (output_rx_flow_ccToggle_io_output_payload_data[7:0]    ), //o
    .phy_clk                         (phy_clk                                                ), //i
    .phy_reset                       (phy_reset                                              ), //i
    .ctrl_clk                        (ctrl_clk                                               ), //i
    .phy_reset_syncronized           (pulseCCByToggle_phy_reset_syncronized_1                )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_rx_active_buffercc (
    .io_dataIn  (output_rx_active                    ), //i
    .io_dataOut (output_rx_active_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                            ), //i
    .ctrl_reset (ctrl_reset                          )  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_1 (
    .io_pulseIn            (output_tick                            ), //i
    .io_pulseOut           (pulseCCByToggle_1_io_pulseOut          ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_BufferCC_8 input_ports_0_removable_buffercc (
    .io_dataIn  (input_ports_0_removable                    ), //i
    .io_dataOut (input_ports_0_removable_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                    ), //i
    .phy_reset  (phy_reset                                  )  //i
  );
  UsbOhciAxi4_BufferCC_8 input_ports_0_power_buffercc (
    .io_dataIn  (input_ports_0_power                    ), //i
    .io_dataOut (input_ports_0_power_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                ), //i
    .phy_reset  (phy_reset                              )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_ports_0_lowSpeed_buffercc (
    .io_dataIn  (output_ports_0_lowSpeed                    ), //i
    .io_dataOut (output_ports_0_lowSpeed_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                                   ), //i
    .ctrl_reset (ctrl_reset                                 )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_ports_0_overcurrent_buffercc (
    .io_dataIn  (output_ports_0_overcurrent                    ), //i
    .io_dataOut (output_ports_0_overcurrent_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                                      ), //i
    .ctrl_reset (ctrl_reset                                    )  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_2 (
    .io_pulseIn            (output_ports_0_connect                 ), //i
    .io_pulseOut           (pulseCCByToggle_2_io_pulseOut          ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_3 (
    .io_pulseIn            (output_ports_0_disconnect              ), //i
    .io_pulseOut           (pulseCCByToggle_3_io_pulseOut          ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_4 (
    .io_pulseIn            (output_ports_0_remoteResume            ), //i
    .io_pulseOut           (pulseCCByToggle_4_io_pulseOut          ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_0_reset_ccToggle (
    .io_input_valid         (input_ports_0_reset_valid                   ), //i
    .io_input_ready         (input_ports_0_reset_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_0_reset_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_0_reset_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                    ), //i
    .ctrl_reset             (ctrl_reset                                  ), //i
    .phy_clk                (phy_clk                                     ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1  )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_0_suspend_ccToggle (
    .io_input_valid         (input_ports_0_suspend_valid                   ), //i
    .io_input_ready         (input_ports_0_suspend_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_0_suspend_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_0_suspend_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                      ), //i
    .ctrl_reset             (ctrl_reset                                    ), //i
    .phy_clk                (phy_clk                                       ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_0_resume_ccToggle (
    .io_input_valid         (input_ports_0_resume_valid                   ), //i
    .io_input_ready         (input_ports_0_resume_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_0_resume_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_0_resume_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                     ), //i
    .ctrl_reset             (ctrl_reset                                   ), //i
    .phy_clk                (phy_clk                                      ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1   )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_0_disable_ccToggle (
    .io_input_valid         (input_ports_0_disable_valid                   ), //i
    .io_input_ready         (input_ports_0_disable_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_0_disable_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_0_disable_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                      ), //i
    .ctrl_reset             (ctrl_reset                                    ), //i
    .phy_clk                (phy_clk                                       ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  UsbOhciAxi4_BufferCC_8 input_ports_1_removable_buffercc (
    .io_dataIn  (input_ports_1_removable                    ), //i
    .io_dataOut (input_ports_1_removable_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                    ), //i
    .phy_reset  (phy_reset                                  )  //i
  );
  UsbOhciAxi4_BufferCC_8 input_ports_1_power_buffercc (
    .io_dataIn  (input_ports_1_power                    ), //i
    .io_dataOut (input_ports_1_power_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                ), //i
    .phy_reset  (phy_reset                              )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_ports_1_lowSpeed_buffercc (
    .io_dataIn  (output_ports_1_lowSpeed                    ), //i
    .io_dataOut (output_ports_1_lowSpeed_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                                   ), //i
    .ctrl_reset (ctrl_reset                                 )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_ports_1_overcurrent_buffercc (
    .io_dataIn  (output_ports_1_overcurrent                    ), //i
    .io_dataOut (output_ports_1_overcurrent_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                                      ), //i
    .ctrl_reset (ctrl_reset                                    )  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_5 (
    .io_pulseIn            (output_ports_1_connect                 ), //i
    .io_pulseOut           (pulseCCByToggle_5_io_pulseOut          ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_6 (
    .io_pulseIn            (output_ports_1_disconnect              ), //i
    .io_pulseOut           (pulseCCByToggle_6_io_pulseOut          ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_7 (
    .io_pulseIn            (output_ports_1_remoteResume            ), //i
    .io_pulseOut           (pulseCCByToggle_7_io_pulseOut          ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_1_reset_ccToggle (
    .io_input_valid         (input_ports_1_reset_valid                   ), //i
    .io_input_ready         (input_ports_1_reset_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_1_reset_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_1_reset_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                    ), //i
    .ctrl_reset             (ctrl_reset                                  ), //i
    .phy_clk                (phy_clk                                     ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1  )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_1_suspend_ccToggle (
    .io_input_valid         (input_ports_1_suspend_valid                   ), //i
    .io_input_ready         (input_ports_1_suspend_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_1_suspend_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_1_suspend_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                      ), //i
    .ctrl_reset             (ctrl_reset                                    ), //i
    .phy_clk                (phy_clk                                       ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_1_resume_ccToggle (
    .io_input_valid         (input_ports_1_resume_valid                   ), //i
    .io_input_ready         (input_ports_1_resume_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_1_resume_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_1_resume_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                     ), //i
    .ctrl_reset             (ctrl_reset                                   ), //i
    .phy_clk                (phy_clk                                      ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1   )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_1_disable_ccToggle (
    .io_input_valid         (input_ports_1_disable_valid                   ), //i
    .io_input_ready         (input_ports_1_disable_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_1_disable_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_1_disable_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                      ), //i
    .ctrl_reset             (ctrl_reset                                    ), //i
    .phy_clk                (phy_clk                                       ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  UsbOhciAxi4_BufferCC_8 input_ports_2_removable_buffercc (
    .io_dataIn  (input_ports_2_removable                    ), //i
    .io_dataOut (input_ports_2_removable_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                    ), //i
    .phy_reset  (phy_reset                                  )  //i
  );
  UsbOhciAxi4_BufferCC_8 input_ports_2_power_buffercc (
    .io_dataIn  (input_ports_2_power                    ), //i
    .io_dataOut (input_ports_2_power_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                ), //i
    .phy_reset  (phy_reset                              )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_ports_2_lowSpeed_buffercc (
    .io_dataIn  (output_ports_2_lowSpeed                    ), //i
    .io_dataOut (output_ports_2_lowSpeed_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                                   ), //i
    .ctrl_reset (ctrl_reset                                 )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_ports_2_overcurrent_buffercc (
    .io_dataIn  (output_ports_2_overcurrent                    ), //i
    .io_dataOut (output_ports_2_overcurrent_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                                      ), //i
    .ctrl_reset (ctrl_reset                                    )  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_8 (
    .io_pulseIn            (output_ports_2_connect                 ), //i
    .io_pulseOut           (pulseCCByToggle_8_io_pulseOut          ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_9 (
    .io_pulseIn            (output_ports_2_disconnect              ), //i
    .io_pulseOut           (pulseCCByToggle_9_io_pulseOut          ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_10 (
    .io_pulseIn            (output_ports_2_remoteResume            ), //i
    .io_pulseOut           (pulseCCByToggle_10_io_pulseOut         ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_2_reset_ccToggle (
    .io_input_valid         (input_ports_2_reset_valid                   ), //i
    .io_input_ready         (input_ports_2_reset_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_2_reset_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_2_reset_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                    ), //i
    .ctrl_reset             (ctrl_reset                                  ), //i
    .phy_clk                (phy_clk                                     ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1  )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_2_suspend_ccToggle (
    .io_input_valid         (input_ports_2_suspend_valid                   ), //i
    .io_input_ready         (input_ports_2_suspend_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_2_suspend_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_2_suspend_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                      ), //i
    .ctrl_reset             (ctrl_reset                                    ), //i
    .phy_clk                (phy_clk                                       ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_2_resume_ccToggle (
    .io_input_valid         (input_ports_2_resume_valid                   ), //i
    .io_input_ready         (input_ports_2_resume_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_2_resume_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_2_resume_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                     ), //i
    .ctrl_reset             (ctrl_reset                                   ), //i
    .phy_clk                (phy_clk                                      ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1   )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_2_disable_ccToggle (
    .io_input_valid         (input_ports_2_disable_valid                   ), //i
    .io_input_ready         (input_ports_2_disable_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_2_disable_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_2_disable_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                      ), //i
    .ctrl_reset             (ctrl_reset                                    ), //i
    .phy_clk                (phy_clk                                       ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  UsbOhciAxi4_BufferCC_8 input_ports_3_removable_buffercc (
    .io_dataIn  (input_ports_3_removable                    ), //i
    .io_dataOut (input_ports_3_removable_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                    ), //i
    .phy_reset  (phy_reset                                  )  //i
  );
  UsbOhciAxi4_BufferCC_8 input_ports_3_power_buffercc (
    .io_dataIn  (input_ports_3_power                    ), //i
    .io_dataOut (input_ports_3_power_buffercc_io_dataOut), //o
    .phy_clk    (phy_clk                                ), //i
    .phy_reset  (phy_reset                              )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_ports_3_lowSpeed_buffercc (
    .io_dataIn  (output_ports_3_lowSpeed                    ), //i
    .io_dataOut (output_ports_3_lowSpeed_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                                   ), //i
    .ctrl_reset (ctrl_reset                                 )  //i
  );
  UsbOhciAxi4_BufferCC_11 output_ports_3_overcurrent_buffercc (
    .io_dataIn  (output_ports_3_overcurrent                    ), //i
    .io_dataOut (output_ports_3_overcurrent_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                                      ), //i
    .ctrl_reset (ctrl_reset                                    )  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_11 (
    .io_pulseIn            (output_ports_3_connect                 ), //i
    .io_pulseOut           (pulseCCByToggle_11_io_pulseOut         ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_12 (
    .io_pulseIn            (output_ports_3_disconnect              ), //i
    .io_pulseOut           (pulseCCByToggle_12_io_pulseOut         ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_PulseCCByToggle_1 pulseCCByToggle_13 (
    .io_pulseIn            (output_ports_3_remoteResume            ), //i
    .io_pulseOut           (pulseCCByToggle_13_io_pulseOut         ), //o
    .phy_clk               (phy_clk                                ), //i
    .phy_reset             (phy_reset                              ), //i
    .ctrl_clk              (ctrl_clk                               ), //i
    .phy_reset_syncronized (pulseCCByToggle_phy_reset_syncronized_1)  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_3_reset_ccToggle (
    .io_input_valid         (input_ports_3_reset_valid                   ), //i
    .io_input_ready         (input_ports_3_reset_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_3_reset_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_3_reset_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                    ), //i
    .ctrl_reset             (ctrl_reset                                  ), //i
    .phy_clk                (phy_clk                                     ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1  )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_3_suspend_ccToggle (
    .io_input_valid         (input_ports_3_suspend_valid                   ), //i
    .io_input_ready         (input_ports_3_suspend_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_3_suspend_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_3_suspend_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                      ), //i
    .ctrl_reset             (ctrl_reset                                    ), //i
    .phy_clk                (phy_clk                                       ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_3_resume_ccToggle (
    .io_input_valid         (input_ports_3_resume_valid                   ), //i
    .io_input_ready         (input_ports_3_resume_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_3_resume_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_3_resume_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                     ), //i
    .ctrl_reset             (ctrl_reset                                   ), //i
    .phy_clk                (phy_clk                                      ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1   )  //i
  );
  UsbOhciAxi4_StreamCCByToggle_1 input_ports_3_disable_ccToggle (
    .io_input_valid         (input_ports_3_disable_valid                   ), //i
    .io_input_ready         (input_ports_3_disable_ccToggle_io_input_ready ), //o
    .io_output_valid        (input_ports_3_disable_ccToggle_io_output_valid), //o
    .io_output_ready        (output_ports_3_disable_ready                  ), //i
    .ctrl_clk               (ctrl_clk                                      ), //i
    .ctrl_reset             (ctrl_reset                                    ), //i
    .phy_clk                (phy_clk                                       ), //i
    .ctrl_reset_syncronized (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  assign output_lowSpeed = input_lowSpeed_buffercc_io_dataOut;
  assign output_usbReset = input_usbReset_buffercc_io_dataOut;
  assign output_usbResume = input_usbResume_buffercc_io_dataOut;
  assign input_overcurrent = output_overcurrent_buffercc_io_dataOut;
  assign input_tx_ready = input_tx_ccToggle_io_input_ready;
  always @(*) begin
    input_tx_ccToggle_io_output_ready = cc_input_tx_ccToggle_io_output_m2sPipe_ready;
    if(when_Stream_l369) begin
      input_tx_ccToggle_io_output_ready = 1'b1;
    end
  end

  assign when_Stream_l369 = (! cc_input_tx_ccToggle_io_output_m2sPipe_valid);
  assign cc_input_tx_ccToggle_io_output_m2sPipe_valid = cc_input_tx_ccToggle_io_output_rValid;
  assign cc_input_tx_ccToggle_io_output_m2sPipe_payload_last = cc_input_tx_ccToggle_io_output_rData_last;
  assign cc_input_tx_ccToggle_io_output_m2sPipe_payload_fragment = cc_input_tx_ccToggle_io_output_rData_fragment;
  assign output_tx_valid = cc_input_tx_ccToggle_io_output_m2sPipe_valid;
  assign cc_input_tx_ccToggle_io_output_m2sPipe_ready = output_tx_ready;
  assign output_tx_payload_last = cc_input_tx_ccToggle_io_output_m2sPipe_payload_last;
  assign output_tx_payload_fragment = cc_input_tx_ccToggle_io_output_m2sPipe_payload_fragment;
  assign input_txEop = pulseCCByToggle_io_pulseOut;
  assign input_rx_flow_valid = output_rx_flow_ccToggle_io_output_valid;
  assign input_rx_flow_payload_stuffingError = output_rx_flow_ccToggle_io_output_payload_stuffingError;
  assign input_rx_flow_payload_data = output_rx_flow_ccToggle_io_output_payload_data;
  assign input_rx_active = output_rx_active_buffercc_io_dataOut;
  assign input_tick = pulseCCByToggle_1_io_pulseOut;
  assign output_ports_0_removable = input_ports_0_removable_buffercc_io_dataOut;
  assign output_ports_0_power = input_ports_0_power_buffercc_io_dataOut;
  assign input_ports_0_lowSpeed = output_ports_0_lowSpeed_buffercc_io_dataOut;
  assign input_ports_0_overcurrent = output_ports_0_overcurrent_buffercc_io_dataOut;
  assign input_ports_0_connect = pulseCCByToggle_2_io_pulseOut;
  assign input_ports_0_disconnect = pulseCCByToggle_3_io_pulseOut;
  assign input_ports_0_remoteResume = pulseCCByToggle_4_io_pulseOut;
  assign input_ports_0_reset_ready = input_ports_0_reset_ccToggle_io_input_ready;
  assign output_ports_0_reset_valid = input_ports_0_reset_ccToggle_io_output_valid;
  assign input_ports_0_suspend_ready = input_ports_0_suspend_ccToggle_io_input_ready;
  assign output_ports_0_suspend_valid = input_ports_0_suspend_ccToggle_io_output_valid;
  assign input_ports_0_resume_ready = input_ports_0_resume_ccToggle_io_input_ready;
  assign output_ports_0_resume_valid = input_ports_0_resume_ccToggle_io_output_valid;
  assign input_ports_0_disable_ready = input_ports_0_disable_ccToggle_io_input_ready;
  assign output_ports_0_disable_valid = input_ports_0_disable_ccToggle_io_output_valid;
  assign output_ports_1_removable = input_ports_1_removable_buffercc_io_dataOut;
  assign output_ports_1_power = input_ports_1_power_buffercc_io_dataOut;
  assign input_ports_1_lowSpeed = output_ports_1_lowSpeed_buffercc_io_dataOut;
  assign input_ports_1_overcurrent = output_ports_1_overcurrent_buffercc_io_dataOut;
  assign input_ports_1_connect = pulseCCByToggle_5_io_pulseOut;
  assign input_ports_1_disconnect = pulseCCByToggle_6_io_pulseOut;
  assign input_ports_1_remoteResume = pulseCCByToggle_7_io_pulseOut;
  assign input_ports_1_reset_ready = input_ports_1_reset_ccToggle_io_input_ready;
  assign output_ports_1_reset_valid = input_ports_1_reset_ccToggle_io_output_valid;
  assign input_ports_1_suspend_ready = input_ports_1_suspend_ccToggle_io_input_ready;
  assign output_ports_1_suspend_valid = input_ports_1_suspend_ccToggle_io_output_valid;
  assign input_ports_1_resume_ready = input_ports_1_resume_ccToggle_io_input_ready;
  assign output_ports_1_resume_valid = input_ports_1_resume_ccToggle_io_output_valid;
  assign input_ports_1_disable_ready = input_ports_1_disable_ccToggle_io_input_ready;
  assign output_ports_1_disable_valid = input_ports_1_disable_ccToggle_io_output_valid;
  assign output_ports_2_removable = input_ports_2_removable_buffercc_io_dataOut;
  assign output_ports_2_power = input_ports_2_power_buffercc_io_dataOut;
  assign input_ports_2_lowSpeed = output_ports_2_lowSpeed_buffercc_io_dataOut;
  assign input_ports_2_overcurrent = output_ports_2_overcurrent_buffercc_io_dataOut;
  assign input_ports_2_connect = pulseCCByToggle_8_io_pulseOut;
  assign input_ports_2_disconnect = pulseCCByToggle_9_io_pulseOut;
  assign input_ports_2_remoteResume = pulseCCByToggle_10_io_pulseOut;
  assign input_ports_2_reset_ready = input_ports_2_reset_ccToggle_io_input_ready;
  assign output_ports_2_reset_valid = input_ports_2_reset_ccToggle_io_output_valid;
  assign input_ports_2_suspend_ready = input_ports_2_suspend_ccToggle_io_input_ready;
  assign output_ports_2_suspend_valid = input_ports_2_suspend_ccToggle_io_output_valid;
  assign input_ports_2_resume_ready = input_ports_2_resume_ccToggle_io_input_ready;
  assign output_ports_2_resume_valid = input_ports_2_resume_ccToggle_io_output_valid;
  assign input_ports_2_disable_ready = input_ports_2_disable_ccToggle_io_input_ready;
  assign output_ports_2_disable_valid = input_ports_2_disable_ccToggle_io_output_valid;
  assign output_ports_3_removable = input_ports_3_removable_buffercc_io_dataOut;
  assign output_ports_3_power = input_ports_3_power_buffercc_io_dataOut;
  assign input_ports_3_lowSpeed = output_ports_3_lowSpeed_buffercc_io_dataOut;
  assign input_ports_3_overcurrent = output_ports_3_overcurrent_buffercc_io_dataOut;
  assign input_ports_3_connect = pulseCCByToggle_11_io_pulseOut;
  assign input_ports_3_disconnect = pulseCCByToggle_12_io_pulseOut;
  assign input_ports_3_remoteResume = pulseCCByToggle_13_io_pulseOut;
  assign input_ports_3_reset_ready = input_ports_3_reset_ccToggle_io_input_ready;
  assign output_ports_3_reset_valid = input_ports_3_reset_ccToggle_io_output_valid;
  assign input_ports_3_suspend_ready = input_ports_3_suspend_ccToggle_io_input_ready;
  assign output_ports_3_suspend_valid = input_ports_3_suspend_ccToggle_io_output_valid;
  assign input_ports_3_resume_ready = input_ports_3_resume_ccToggle_io_input_ready;
  assign output_ports_3_resume_valid = input_ports_3_resume_ccToggle_io_output_valid;
  assign input_ports_3_disable_ready = input_ports_3_disable_ccToggle_io_input_ready;
  assign output_ports_3_disable_valid = input_ports_3_disable_ccToggle_io_output_valid;
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      cc_input_tx_ccToggle_io_output_rValid <= 1'b0;
    end else begin
      if(input_tx_ccToggle_io_output_ready) begin
        cc_input_tx_ccToggle_io_output_rValid <= input_tx_ccToggle_io_output_valid;
      end
    end
  end

  always @(posedge phy_clk) begin
    if(input_tx_ccToggle_io_output_ready) begin
      cc_input_tx_ccToggle_io_output_rData_last <= input_tx_ccToggle_io_output_payload_last;
      cc_input_tx_ccToggle_io_output_rData_fragment <= input_tx_ccToggle_io_output_payload_fragment;
    end
  end


endmodule

//UsbOhciAxi4_BufferCC_7 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_6 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_5 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_4 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_3 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_2 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_1 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC replaced by UsbOhciAxi4_BufferCC_8

module UsbOhciAxi4_UsbLsFsPhy (
  input  wire          io_ctrl_lowSpeed,
  input  wire          io_ctrl_tx_valid,
  output reg           io_ctrl_tx_ready,
  input  wire          io_ctrl_tx_payload_last,
  input  wire [7:0]    io_ctrl_tx_payload_fragment,
  output reg           io_ctrl_txEop,
  output reg           io_ctrl_rx_flow_valid,
  output reg           io_ctrl_rx_flow_payload_stuffingError,
  output reg  [7:0]    io_ctrl_rx_flow_payload_data,
  output reg           io_ctrl_rx_active,
  input  wire          io_ctrl_usbReset,
  input  wire          io_ctrl_usbResume,
  output wire          io_ctrl_overcurrent,
  output wire          io_ctrl_tick,
  input  wire          io_ctrl_ports_0_disable_valid,
  output wire          io_ctrl_ports_0_disable_ready,
  input  wire          io_ctrl_ports_0_removable,
  input  wire          io_ctrl_ports_0_power,
  input  wire          io_ctrl_ports_0_reset_valid,
  output reg           io_ctrl_ports_0_reset_ready,
  input  wire          io_ctrl_ports_0_suspend_valid,
  output wire          io_ctrl_ports_0_suspend_ready,
  input  wire          io_ctrl_ports_0_resume_valid,
  output wire          io_ctrl_ports_0_resume_ready,
  output reg           io_ctrl_ports_0_connect,
  output wire          io_ctrl_ports_0_disconnect,
  output wire          io_ctrl_ports_0_overcurrent,
  output wire          io_ctrl_ports_0_remoteResume,
  output wire          io_ctrl_ports_0_lowSpeed,
  input  wire          io_ctrl_ports_1_disable_valid,
  output wire          io_ctrl_ports_1_disable_ready,
  input  wire          io_ctrl_ports_1_removable,
  input  wire          io_ctrl_ports_1_power,
  input  wire          io_ctrl_ports_1_reset_valid,
  output reg           io_ctrl_ports_1_reset_ready,
  input  wire          io_ctrl_ports_1_suspend_valid,
  output wire          io_ctrl_ports_1_suspend_ready,
  input  wire          io_ctrl_ports_1_resume_valid,
  output wire          io_ctrl_ports_1_resume_ready,
  output reg           io_ctrl_ports_1_connect,
  output wire          io_ctrl_ports_1_disconnect,
  output wire          io_ctrl_ports_1_overcurrent,
  output wire          io_ctrl_ports_1_remoteResume,
  output wire          io_ctrl_ports_1_lowSpeed,
  input  wire          io_ctrl_ports_2_disable_valid,
  output wire          io_ctrl_ports_2_disable_ready,
  input  wire          io_ctrl_ports_2_removable,
  input  wire          io_ctrl_ports_2_power,
  input  wire          io_ctrl_ports_2_reset_valid,
  output reg           io_ctrl_ports_2_reset_ready,
  input  wire          io_ctrl_ports_2_suspend_valid,
  output wire          io_ctrl_ports_2_suspend_ready,
  input  wire          io_ctrl_ports_2_resume_valid,
  output wire          io_ctrl_ports_2_resume_ready,
  output reg           io_ctrl_ports_2_connect,
  output wire          io_ctrl_ports_2_disconnect,
  output wire          io_ctrl_ports_2_overcurrent,
  output wire          io_ctrl_ports_2_remoteResume,
  output wire          io_ctrl_ports_2_lowSpeed,
  input  wire          io_ctrl_ports_3_disable_valid,
  output wire          io_ctrl_ports_3_disable_ready,
  input  wire          io_ctrl_ports_3_removable,
  input  wire          io_ctrl_ports_3_power,
  input  wire          io_ctrl_ports_3_reset_valid,
  output reg           io_ctrl_ports_3_reset_ready,
  input  wire          io_ctrl_ports_3_suspend_valid,
  output wire          io_ctrl_ports_3_suspend_ready,
  input  wire          io_ctrl_ports_3_resume_valid,
  output wire          io_ctrl_ports_3_resume_ready,
  output reg           io_ctrl_ports_3_connect,
  output wire          io_ctrl_ports_3_disconnect,
  output wire          io_ctrl_ports_3_overcurrent,
  output wire          io_ctrl_ports_3_remoteResume,
  output wire          io_ctrl_ports_3_lowSpeed,
  output reg           io_usb_0_tx_enable,
  output reg           io_usb_0_tx_data,
  output reg           io_usb_0_tx_se0,
  input  wire          io_usb_0_rx_dp,
  input  wire          io_usb_0_rx_dm,
  output reg           io_usb_1_tx_enable,
  output reg           io_usb_1_tx_data,
  output reg           io_usb_1_tx_se0,
  input  wire          io_usb_1_rx_dp,
  input  wire          io_usb_1_rx_dm,
  output reg           io_usb_2_tx_enable,
  output reg           io_usb_2_tx_data,
  output reg           io_usb_2_tx_se0,
  input  wire          io_usb_2_rx_dp,
  input  wire          io_usb_2_rx_dm,
  output reg           io_usb_3_tx_enable,
  output reg           io_usb_3_tx_data,
  output reg           io_usb_3_tx_se0,
  input  wire          io_usb_3_rx_dp,
  input  wire          io_usb_3_rx_dm,
  input  wire          io_management_0_overcurrent,
  output wire          io_management_0_power,
  input  wire          io_management_1_overcurrent,
  output wire          io_management_1_power,
  input  wire          io_management_2_overcurrent,
  output wire          io_management_2_power,
  input  wire          io_management_3_overcurrent,
  output wire          io_management_3_power,
  input  wire          phy_clk,
  input  wire          phy_reset
);
  localparam UsbOhciAxi4_txShared_frame_enumDef_BOOT = 4'd0;
  localparam UsbOhciAxi4_txShared_frame_enumDef_IDLE = 4'd1;
  localparam UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE = 4'd2;
  localparam UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC = 4'd3;
  localparam UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID = 4'd4;
  localparam UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY = 4'd5;
  localparam UsbOhciAxi4_txShared_frame_enumDef_SYNC = 4'd6;
  localparam UsbOhciAxi4_txShared_frame_enumDef_DATA = 4'd7;
  localparam UsbOhciAxi4_txShared_frame_enumDef_EOP_0 = 4'd8;
  localparam UsbOhciAxi4_txShared_frame_enumDef_EOP_1 = 4'd9;
  localparam UsbOhciAxi4_txShared_frame_enumDef_EOP_2 = 4'd10;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_BOOT = 4'd0;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF = 4'd1;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED = 4'd2;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED = 4'd3;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING = 4'd4;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY = 4'd5;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC = 4'd6;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED = 4'd7;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED = 4'd8;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING = 4'd9;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 = 4'd10;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 = 4'd11;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S = 4'd12;
  localparam UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E = 4'd13;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_BOOT = 4'd0;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF = 4'd1;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED = 4'd2;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED = 4'd3;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING = 4'd4;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY = 4'd5;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC = 4'd6;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED = 4'd7;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED = 4'd8;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING = 4'd9;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 = 4'd10;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 = 4'd11;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S = 4'd12;
  localparam UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E = 4'd13;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_BOOT = 4'd0;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF = 4'd1;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED = 4'd2;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED = 4'd3;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING = 4'd4;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY = 4'd5;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC = 4'd6;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED = 4'd7;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED = 4'd8;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING = 4'd9;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 = 4'd10;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 = 4'd11;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S = 4'd12;
  localparam UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E = 4'd13;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_BOOT = 4'd0;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF = 4'd1;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED = 4'd2;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED = 4'd3;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING = 4'd4;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY = 4'd5;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC = 4'd6;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED = 4'd7;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED = 4'd8;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING = 4'd9;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 = 4'd10;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 = 4'd11;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S = 4'd12;
  localparam UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E = 4'd13;
  localparam UsbOhciAxi4_upstreamRx_enumDef_BOOT = 2'd0;
  localparam UsbOhciAxi4_upstreamRx_enumDef_IDLE = 2'd1;
  localparam UsbOhciAxi4_upstreamRx_enumDef_SUSPEND = 2'd2;
  localparam UsbOhciAxi4_ports_0_rx_packet_enumDef_BOOT = 2'd0;
  localparam UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE = 2'd1;
  localparam UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET = 2'd2;
  localparam UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED = 2'd3;
  localparam UsbOhciAxi4_ports_1_rx_packet_enumDef_BOOT = 2'd0;
  localparam UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE = 2'd1;
  localparam UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET = 2'd2;
  localparam UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED = 2'd3;
  localparam UsbOhciAxi4_ports_2_rx_packet_enumDef_BOOT = 2'd0;
  localparam UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE = 2'd1;
  localparam UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET = 2'd2;
  localparam UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED = 2'd3;
  localparam UsbOhciAxi4_ports_3_rx_packet_enumDef_BOOT = 2'd0;
  localparam UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE = 2'd1;
  localparam UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET = 2'd2;
  localparam UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED = 2'd3;

  wire                ports_0_filter_io_filtred_dp;
  wire                ports_0_filter_io_filtred_dm;
  wire                ports_0_filter_io_filtred_d;
  wire                ports_0_filter_io_filtred_se0;
  wire                ports_0_filter_io_filtred_sample;
  wire                ports_1_filter_io_filtred_dp;
  wire                ports_1_filter_io_filtred_dm;
  wire                ports_1_filter_io_filtred_d;
  wire                ports_1_filter_io_filtred_se0;
  wire                ports_1_filter_io_filtred_sample;
  wire                ports_2_filter_io_filtred_dp;
  wire                ports_2_filter_io_filtred_dm;
  wire                ports_2_filter_io_filtred_d;
  wire                ports_2_filter_io_filtred_se0;
  wire                ports_2_filter_io_filtred_sample;
  wire                ports_3_filter_io_filtred_dp;
  wire                ports_3_filter_io_filtred_dm;
  wire                ports_3_filter_io_filtred_d;
  wire                ports_3_filter_io_filtred_se0;
  wire                ports_3_filter_io_filtred_sample;
  wire       [1:0]    _zz_tickTimer_counter_valueNext;
  wire       [0:0]    _zz_tickTimer_counter_valueNext_1;
  wire       [9:0]    _zz_txShared_timer_oneCycle;
  wire       [4:0]    _zz_txShared_timer_oneCycle_1;
  wire       [9:0]    _zz_txShared_timer_twoCycle;
  wire       [5:0]    _zz_txShared_timer_twoCycle_1;
  wire       [9:0]    _zz_txShared_timer_fourCycle;
  wire       [7:0]    _zz_txShared_timer_fourCycle_1;
  wire       [8:0]    _zz_txShared_rxToTxDelay_twoCycle;
  wire       [6:0]    _zz_txShared_rxToTxDelay_twoCycle_1;
  wire       [1:0]    _zz_txShared_lowSpeedSof_state;
  wire       [0:0]    _zz_txShared_lowSpeedSof_state_1;
  wire       [6:0]    _zz_when_UsbHubPhy_l506;
  wire       [11:0]   _zz_ports_0_rx_packet_errorTimeout_trigger;
  wire       [9:0]    _zz_ports_0_rx_packet_errorTimeout_trigger_1;
  wire       [6:0]    _zz_ports_0_rx_disconnect_counter;
  wire       [0:0]    _zz_ports_0_rx_disconnect_counter_1;
  wire       [23:0]   _zz_ports_0_fsm_timer_ONE_BIT;
  wire       [4:0]    _zz_ports_0_fsm_timer_ONE_BIT_1;
  wire       [23:0]   _zz_ports_0_fsm_timer_TWO_BIT;
  wire       [5:0]    _zz_ports_0_fsm_timer_TWO_BIT_1;
  wire       [6:0]    _zz_when_UsbHubPhy_l506_1;
  wire       [11:0]   _zz_ports_1_rx_packet_errorTimeout_trigger;
  wire       [9:0]    _zz_ports_1_rx_packet_errorTimeout_trigger_1;
  wire       [6:0]    _zz_ports_1_rx_disconnect_counter;
  wire       [0:0]    _zz_ports_1_rx_disconnect_counter_1;
  wire       [23:0]   _zz_ports_1_fsm_timer_ONE_BIT;
  wire       [4:0]    _zz_ports_1_fsm_timer_ONE_BIT_1;
  wire       [23:0]   _zz_ports_1_fsm_timer_TWO_BIT;
  wire       [5:0]    _zz_ports_1_fsm_timer_TWO_BIT_1;
  wire       [6:0]    _zz_when_UsbHubPhy_l506_2;
  wire       [11:0]   _zz_ports_2_rx_packet_errorTimeout_trigger;
  wire       [9:0]    _zz_ports_2_rx_packet_errorTimeout_trigger_1;
  wire       [6:0]    _zz_ports_2_rx_disconnect_counter;
  wire       [0:0]    _zz_ports_2_rx_disconnect_counter_1;
  wire       [23:0]   _zz_ports_2_fsm_timer_ONE_BIT;
  wire       [4:0]    _zz_ports_2_fsm_timer_ONE_BIT_1;
  wire       [23:0]   _zz_ports_2_fsm_timer_TWO_BIT;
  wire       [5:0]    _zz_ports_2_fsm_timer_TWO_BIT_1;
  wire       [6:0]    _zz_when_UsbHubPhy_l506_3;
  wire       [11:0]   _zz_ports_3_rx_packet_errorTimeout_trigger;
  wire       [9:0]    _zz_ports_3_rx_packet_errorTimeout_trigger_1;
  wire       [6:0]    _zz_ports_3_rx_disconnect_counter;
  wire       [0:0]    _zz_ports_3_rx_disconnect_counter_1;
  wire       [23:0]   _zz_ports_3_fsm_timer_ONE_BIT;
  wire       [4:0]    _zz_ports_3_fsm_timer_ONE_BIT_1;
  wire       [23:0]   _zz_ports_3_fsm_timer_TWO_BIT;
  wire       [5:0]    _zz_ports_3_fsm_timer_TWO_BIT_1;
  wire                tickTimer_counter_willIncrement;
  wire                tickTimer_counter_willClear;
  reg        [1:0]    tickTimer_counter_valueNext;
  reg        [1:0]    tickTimer_counter_value;
  wire                tickTimer_counter_willOverflowIfInc;
  wire                tickTimer_counter_willOverflow;
  wire                tickTimer_tick;
  reg                 txShared_timer_lowSpeed;
  reg        [9:0]    txShared_timer_counter;
  reg                 txShared_timer_clear;
  wire                txShared_timer_inc;
  wire                txShared_timer_oneCycle;
  wire                txShared_timer_twoCycle;
  wire                txShared_timer_fourCycle;
  reg                 txShared_rxToTxDelay_lowSpeed;
  reg        [8:0]    txShared_rxToTxDelay_counter;
  reg                 txShared_rxToTxDelay_clear;
  wire                txShared_rxToTxDelay_inc;
  wire                txShared_rxToTxDelay_twoCycle;
  reg                 txShared_rxToTxDelay_active;
  reg                 txShared_encoder_input_valid;
  reg                 txShared_encoder_input_ready;
  reg                 txShared_encoder_input_data;
  reg                 txShared_encoder_input_lowSpeed;
  reg                 txShared_encoder_output_valid;
  reg                 txShared_encoder_output_se0;
  reg                 txShared_encoder_output_lowSpeed;
  reg                 txShared_encoder_output_data;
  reg        [2:0]    txShared_encoder_counter;
  reg                 txShared_encoder_state;
  wire                when_UsbHubPhy_l194;
  wire                when_UsbHubPhy_l199;
  wire                when_UsbHubPhy_l213;
  reg                 txShared_serialiser_input_valid;
  reg                 txShared_serialiser_input_ready;
  reg        [7:0]    txShared_serialiser_input_data;
  reg                 txShared_serialiser_input_lowSpeed;
  reg        [2:0]    txShared_serialiser_bitCounter;
  wire                when_UsbHubPhy_l239;
  wire                when_UsbHubPhy_l245;
  reg        [4:0]    txShared_lowSpeedSof_timer;
  reg        [1:0]    txShared_lowSpeedSof_state;
  reg                 txShared_lowSpeedSof_increment;
  reg                 txShared_lowSpeedSof_overrideEncoder;
  reg                 txShared_encoder_output_valid_regNext;
  wire                when_UsbHubPhy_l254;
  wire                when_UsbHubPhy_l256;
  wire                io_ctrl_tx_fire;
  reg                 io_ctrl_tx_payload_first;
  wire                when_UsbHubPhy_l257;
  wire                when_UsbHubPhy_l264;
  wire                txShared_lowSpeedSof_valid;
  wire                txShared_lowSpeedSof_data;
  wire                txShared_lowSpeedSof_se0;
  wire                txShared_frame_wantExit;
  reg                 txShared_frame_wantStart;
  wire                txShared_frame_wantKill;
  wire                txShared_frame_busy;
  reg                 txShared_frame_wasLowSpeed;
  wire                upstreamRx_wantExit;
  reg                 upstreamRx_wantStart;
  wire                upstreamRx_wantKill;
  wire                upstreamRx_timer_lowSpeed;
  reg        [19:0]   upstreamRx_timer_counter;
  reg                 upstreamRx_timer_clear;
  wire                upstreamRx_timer_inc;
  wire                upstreamRx_timer_IDLE_EOI;
  wire                Rx_Suspend;
  reg                 resumeFromPort;
  reg                 ports_0_portLowSpeed;
  reg                 ports_0_rx_enablePackets;
  wire                ports_0_rx_j;
  wire                ports_0_rx_k;
  reg                 ports_0_rx_stuffingError;
  reg                 ports_0_rx_waitSync;
  reg                 ports_0_rx_decoder_state;
  reg                 ports_0_rx_decoder_output_valid;
  reg                 ports_0_rx_decoder_output_payload;
  wire                when_UsbHubPhy_l450;
  reg        [2:0]    ports_0_rx_destuffer_counter;
  wire                ports_0_rx_destuffer_unstuffNext;
  wire                ports_0_rx_destuffer_output_valid;
  wire                ports_0_rx_destuffer_output_payload;
  wire                when_UsbHubPhy_l471;
  wire                ports_0_rx_history_updated;
  wire                _zz_ports_0_rx_history_value;
  reg                 _zz_ports_0_rx_history_value_1;
  reg                 _zz_ports_0_rx_history_value_2;
  reg                 _zz_ports_0_rx_history_value_3;
  reg                 _zz_ports_0_rx_history_value_4;
  reg                 _zz_ports_0_rx_history_value_5;
  reg                 _zz_ports_0_rx_history_value_6;
  reg                 _zz_ports_0_rx_history_value_7;
  wire       [7:0]    ports_0_rx_history_value;
  wire                ports_0_rx_history_sync_hit;
  wire       [6:0]    ports_0_rx_eop_maxThreshold;
  wire       [5:0]    ports_0_rx_eop_minThreshold;
  reg        [6:0]    ports_0_rx_eop_counter;
  wire                ports_0_rx_eop_maxHit;
  reg                 ports_0_rx_eop_hit;
  wire                when_UsbHubPhy_l498;
  wire                when_UsbHubPhy_l499;
  wire                when_UsbHubPhy_l506;
  wire                ports_0_rx_packet_wantExit;
  reg                 ports_0_rx_packet_wantStart;
  wire                ports_0_rx_packet_wantKill;
  reg        [2:0]    ports_0_rx_packet_counter;
  wire                ports_0_rx_packet_errorTimeout_lowSpeed;
  reg        [11:0]   ports_0_rx_packet_errorTimeout_counter;
  reg                 ports_0_rx_packet_errorTimeout_clear;
  wire                ports_0_rx_packet_errorTimeout_inc;
  wire                ports_0_rx_packet_errorTimeout_trigger;
  reg                 ports_0_rx_packet_errorTimeout_p;
  reg                 ports_0_rx_packet_errorTimeout_n;
  reg        [6:0]    ports_0_rx_disconnect_counter;
  reg                 ports_0_rx_disconnect_clear;
  wire                ports_0_rx_disconnect_hit;
  reg                 ports_0_rx_disconnect_hitLast;
  wire                ports_0_rx_disconnect_event;
  wire                when_UsbHubPhy_l578;
  wire                ports_0_fsm_wantExit;
  reg                 ports_0_fsm_wantStart;
  wire                ports_0_fsm_wantKill;
  reg                 ports_0_fsm_timer_lowSpeed;
  reg        [23:0]   ports_0_fsm_timer_counter;
  reg                 ports_0_fsm_timer_clear;
  wire                ports_0_fsm_timer_inc;
  wire                ports_0_fsm_timer_DISCONNECTED_EOI;
  wire                ports_0_fsm_timer_RESET_DELAY;
  wire                ports_0_fsm_timer_RESET_EOI;
  wire                ports_0_fsm_timer_RESUME_EOI;
  wire                ports_0_fsm_timer_RESTART_EOI;
  wire                ports_0_fsm_timer_ONE_BIT;
  wire                ports_0_fsm_timer_TWO_BIT;
  reg                 ports_0_fsm_resetInProgress;
  reg                 ports_0_fsm_lowSpeedEop;
  wire                ports_0_fsm_forceJ;
  wire                when_UsbHubPhy_l772;
  reg                 ports_1_portLowSpeed;
  reg                 ports_1_rx_enablePackets;
  wire                ports_1_rx_j;
  wire                ports_1_rx_k;
  reg                 ports_1_rx_stuffingError;
  reg                 ports_1_rx_waitSync;
  reg                 ports_1_rx_decoder_state;
  reg                 ports_1_rx_decoder_output_valid;
  reg                 ports_1_rx_decoder_output_payload;
  wire                when_UsbHubPhy_l450_1;
  reg        [2:0]    ports_1_rx_destuffer_counter;
  wire                ports_1_rx_destuffer_unstuffNext;
  wire                ports_1_rx_destuffer_output_valid;
  wire                ports_1_rx_destuffer_output_payload;
  wire                when_UsbHubPhy_l471_1;
  wire                ports_1_rx_history_updated;
  wire                _zz_ports_1_rx_history_value;
  reg                 _zz_ports_1_rx_history_value_1;
  reg                 _zz_ports_1_rx_history_value_2;
  reg                 _zz_ports_1_rx_history_value_3;
  reg                 _zz_ports_1_rx_history_value_4;
  reg                 _zz_ports_1_rx_history_value_5;
  reg                 _zz_ports_1_rx_history_value_6;
  reg                 _zz_ports_1_rx_history_value_7;
  wire       [7:0]    ports_1_rx_history_value;
  wire                ports_1_rx_history_sync_hit;
  wire       [6:0]    ports_1_rx_eop_maxThreshold;
  wire       [5:0]    ports_1_rx_eop_minThreshold;
  reg        [6:0]    ports_1_rx_eop_counter;
  wire                ports_1_rx_eop_maxHit;
  reg                 ports_1_rx_eop_hit;
  wire                when_UsbHubPhy_l498_1;
  wire                when_UsbHubPhy_l499_1;
  wire                when_UsbHubPhy_l506_1;
  wire                ports_1_rx_packet_wantExit;
  reg                 ports_1_rx_packet_wantStart;
  wire                ports_1_rx_packet_wantKill;
  reg        [2:0]    ports_1_rx_packet_counter;
  wire                ports_1_rx_packet_errorTimeout_lowSpeed;
  reg        [11:0]   ports_1_rx_packet_errorTimeout_counter;
  reg                 ports_1_rx_packet_errorTimeout_clear;
  wire                ports_1_rx_packet_errorTimeout_inc;
  wire                ports_1_rx_packet_errorTimeout_trigger;
  reg                 ports_1_rx_packet_errorTimeout_p;
  reg                 ports_1_rx_packet_errorTimeout_n;
  reg        [6:0]    ports_1_rx_disconnect_counter;
  reg                 ports_1_rx_disconnect_clear;
  wire                ports_1_rx_disconnect_hit;
  reg                 ports_1_rx_disconnect_hitLast;
  wire                ports_1_rx_disconnect_event;
  wire                when_UsbHubPhy_l578_1;
  wire                ports_1_fsm_wantExit;
  reg                 ports_1_fsm_wantStart;
  wire                ports_1_fsm_wantKill;
  reg                 ports_1_fsm_timer_lowSpeed;
  reg        [23:0]   ports_1_fsm_timer_counter;
  reg                 ports_1_fsm_timer_clear;
  wire                ports_1_fsm_timer_inc;
  wire                ports_1_fsm_timer_DISCONNECTED_EOI;
  wire                ports_1_fsm_timer_RESET_DELAY;
  wire                ports_1_fsm_timer_RESET_EOI;
  wire                ports_1_fsm_timer_RESUME_EOI;
  wire                ports_1_fsm_timer_RESTART_EOI;
  wire                ports_1_fsm_timer_ONE_BIT;
  wire                ports_1_fsm_timer_TWO_BIT;
  reg                 ports_1_fsm_resetInProgress;
  reg                 ports_1_fsm_lowSpeedEop;
  wire                ports_1_fsm_forceJ;
  wire                when_UsbHubPhy_l772_1;
  reg                 ports_2_portLowSpeed;
  reg                 ports_2_rx_enablePackets;
  wire                ports_2_rx_j;
  wire                ports_2_rx_k;
  reg                 ports_2_rx_stuffingError;
  reg                 ports_2_rx_waitSync;
  reg                 ports_2_rx_decoder_state;
  reg                 ports_2_rx_decoder_output_valid;
  reg                 ports_2_rx_decoder_output_payload;
  wire                when_UsbHubPhy_l450_2;
  reg        [2:0]    ports_2_rx_destuffer_counter;
  wire                ports_2_rx_destuffer_unstuffNext;
  wire                ports_2_rx_destuffer_output_valid;
  wire                ports_2_rx_destuffer_output_payload;
  wire                when_UsbHubPhy_l471_2;
  wire                ports_2_rx_history_updated;
  wire                _zz_ports_2_rx_history_value;
  reg                 _zz_ports_2_rx_history_value_1;
  reg                 _zz_ports_2_rx_history_value_2;
  reg                 _zz_ports_2_rx_history_value_3;
  reg                 _zz_ports_2_rx_history_value_4;
  reg                 _zz_ports_2_rx_history_value_5;
  reg                 _zz_ports_2_rx_history_value_6;
  reg                 _zz_ports_2_rx_history_value_7;
  wire       [7:0]    ports_2_rx_history_value;
  wire                ports_2_rx_history_sync_hit;
  wire       [6:0]    ports_2_rx_eop_maxThreshold;
  wire       [5:0]    ports_2_rx_eop_minThreshold;
  reg        [6:0]    ports_2_rx_eop_counter;
  wire                ports_2_rx_eop_maxHit;
  reg                 ports_2_rx_eop_hit;
  wire                when_UsbHubPhy_l498_2;
  wire                when_UsbHubPhy_l499_2;
  wire                when_UsbHubPhy_l506_2;
  wire                ports_2_rx_packet_wantExit;
  reg                 ports_2_rx_packet_wantStart;
  wire                ports_2_rx_packet_wantKill;
  reg        [2:0]    ports_2_rx_packet_counter;
  wire                ports_2_rx_packet_errorTimeout_lowSpeed;
  reg        [11:0]   ports_2_rx_packet_errorTimeout_counter;
  reg                 ports_2_rx_packet_errorTimeout_clear;
  wire                ports_2_rx_packet_errorTimeout_inc;
  wire                ports_2_rx_packet_errorTimeout_trigger;
  reg                 ports_2_rx_packet_errorTimeout_p;
  reg                 ports_2_rx_packet_errorTimeout_n;
  reg        [6:0]    ports_2_rx_disconnect_counter;
  reg                 ports_2_rx_disconnect_clear;
  wire                ports_2_rx_disconnect_hit;
  reg                 ports_2_rx_disconnect_hitLast;
  wire                ports_2_rx_disconnect_event;
  wire                when_UsbHubPhy_l578_2;
  wire                ports_2_fsm_wantExit;
  reg                 ports_2_fsm_wantStart;
  wire                ports_2_fsm_wantKill;
  reg                 ports_2_fsm_timer_lowSpeed;
  reg        [23:0]   ports_2_fsm_timer_counter;
  reg                 ports_2_fsm_timer_clear;
  wire                ports_2_fsm_timer_inc;
  wire                ports_2_fsm_timer_DISCONNECTED_EOI;
  wire                ports_2_fsm_timer_RESET_DELAY;
  wire                ports_2_fsm_timer_RESET_EOI;
  wire                ports_2_fsm_timer_RESUME_EOI;
  wire                ports_2_fsm_timer_RESTART_EOI;
  wire                ports_2_fsm_timer_ONE_BIT;
  wire                ports_2_fsm_timer_TWO_BIT;
  reg                 ports_2_fsm_resetInProgress;
  reg                 ports_2_fsm_lowSpeedEop;
  wire                ports_2_fsm_forceJ;
  wire                when_UsbHubPhy_l772_2;
  reg                 ports_3_portLowSpeed;
  reg                 ports_3_rx_enablePackets;
  wire                ports_3_rx_j;
  wire                ports_3_rx_k;
  reg                 ports_3_rx_stuffingError;
  reg                 ports_3_rx_waitSync;
  reg                 ports_3_rx_decoder_state;
  reg                 ports_3_rx_decoder_output_valid;
  reg                 ports_3_rx_decoder_output_payload;
  wire                when_UsbHubPhy_l450_3;
  reg        [2:0]    ports_3_rx_destuffer_counter;
  wire                ports_3_rx_destuffer_unstuffNext;
  wire                ports_3_rx_destuffer_output_valid;
  wire                ports_3_rx_destuffer_output_payload;
  wire                when_UsbHubPhy_l471_3;
  wire                ports_3_rx_history_updated;
  wire                _zz_ports_3_rx_history_value;
  reg                 _zz_ports_3_rx_history_value_1;
  reg                 _zz_ports_3_rx_history_value_2;
  reg                 _zz_ports_3_rx_history_value_3;
  reg                 _zz_ports_3_rx_history_value_4;
  reg                 _zz_ports_3_rx_history_value_5;
  reg                 _zz_ports_3_rx_history_value_6;
  reg                 _zz_ports_3_rx_history_value_7;
  wire       [7:0]    ports_3_rx_history_value;
  wire                ports_3_rx_history_sync_hit;
  wire       [6:0]    ports_3_rx_eop_maxThreshold;
  wire       [5:0]    ports_3_rx_eop_minThreshold;
  reg        [6:0]    ports_3_rx_eop_counter;
  wire                ports_3_rx_eop_maxHit;
  reg                 ports_3_rx_eop_hit;
  wire                when_UsbHubPhy_l498_3;
  wire                when_UsbHubPhy_l499_3;
  wire                when_UsbHubPhy_l506_3;
  wire                ports_3_rx_packet_wantExit;
  reg                 ports_3_rx_packet_wantStart;
  wire                ports_3_rx_packet_wantKill;
  reg        [2:0]    ports_3_rx_packet_counter;
  wire                ports_3_rx_packet_errorTimeout_lowSpeed;
  reg        [11:0]   ports_3_rx_packet_errorTimeout_counter;
  reg                 ports_3_rx_packet_errorTimeout_clear;
  wire                ports_3_rx_packet_errorTimeout_inc;
  wire                ports_3_rx_packet_errorTimeout_trigger;
  reg                 ports_3_rx_packet_errorTimeout_p;
  reg                 ports_3_rx_packet_errorTimeout_n;
  reg        [6:0]    ports_3_rx_disconnect_counter;
  reg                 ports_3_rx_disconnect_clear;
  wire                ports_3_rx_disconnect_hit;
  reg                 ports_3_rx_disconnect_hitLast;
  wire                ports_3_rx_disconnect_event;
  wire                when_UsbHubPhy_l578_3;
  wire                ports_3_fsm_wantExit;
  reg                 ports_3_fsm_wantStart;
  wire                ports_3_fsm_wantKill;
  reg                 ports_3_fsm_timer_lowSpeed;
  reg        [23:0]   ports_3_fsm_timer_counter;
  reg                 ports_3_fsm_timer_clear;
  wire                ports_3_fsm_timer_inc;
  wire                ports_3_fsm_timer_DISCONNECTED_EOI;
  wire                ports_3_fsm_timer_RESET_DELAY;
  wire                ports_3_fsm_timer_RESET_EOI;
  wire                ports_3_fsm_timer_RESUME_EOI;
  wire                ports_3_fsm_timer_RESTART_EOI;
  wire                ports_3_fsm_timer_ONE_BIT;
  wire                ports_3_fsm_timer_TWO_BIT;
  reg                 ports_3_fsm_resetInProgress;
  reg                 ports_3_fsm_lowSpeedEop;
  wire                ports_3_fsm_forceJ;
  wire                when_UsbHubPhy_l772_3;
  reg        [3:0]    txShared_frame_stateReg;
  reg        [3:0]    txShared_frame_stateNext;
  wire                when_UsbHubPhy_l294;
  reg        [1:0]    upstreamRx_stateReg;
  reg        [1:0]    upstreamRx_stateNext;
  reg        [1:0]    ports_0_rx_packet_stateReg;
  reg        [1:0]    ports_0_rx_packet_stateNext;
  wire                when_UsbHubPhy_l532;
  wire                when_UsbHubPhy_l554;
  wire                when_StateMachine_l253;
  wire                when_StateMachine_l253_1;
  reg        [3:0]    ports_0_fsm_stateReg;
  reg        [3:0]    ports_0_fsm_stateNext;
  wire                when_UsbHubPhy_l643;
  wire                when_UsbHubPhy_l680;
  wire                when_UsbHubPhy_l693;
  wire                when_UsbHubPhy_l702;
  wire                when_UsbHubPhy_l710;
  wire                when_UsbHubPhy_l712;
  wire                when_UsbHubPhy_l753;
  wire                when_UsbHubPhy_l763;
  wire                when_StateMachine_l253_2;
  wire                when_StateMachine_l253_3;
  wire                when_StateMachine_l253_4;
  wire                when_StateMachine_l253_5;
  wire                when_StateMachine_l253_6;
  wire                when_StateMachine_l253_7;
  wire                when_StateMachine_l253_8;
  wire                when_StateMachine_l253_9;
  wire                when_UsbHubPhy_l615;
  wire                when_UsbHubPhy_l622;
  wire                when_UsbHubPhy_l623;
  reg        [1:0]    ports_1_rx_packet_stateReg;
  reg        [1:0]    ports_1_rx_packet_stateNext;
  wire                when_UsbHubPhy_l532_1;
  wire                when_UsbHubPhy_l554_1;
  wire                when_StateMachine_l253_10;
  wire                when_StateMachine_l253_11;
  reg        [3:0]    ports_1_fsm_stateReg;
  reg        [3:0]    ports_1_fsm_stateNext;
  wire                when_UsbHubPhy_l643_1;
  wire                when_UsbHubPhy_l680_1;
  wire                when_UsbHubPhy_l693_1;
  wire                when_UsbHubPhy_l702_1;
  wire                when_UsbHubPhy_l710_1;
  wire                when_UsbHubPhy_l712_1;
  wire                when_UsbHubPhy_l753_1;
  wire                when_UsbHubPhy_l763_1;
  wire                when_StateMachine_l253_12;
  wire                when_StateMachine_l253_13;
  wire                when_StateMachine_l253_14;
  wire                when_StateMachine_l253_15;
  wire                when_StateMachine_l253_16;
  wire                when_StateMachine_l253_17;
  wire                when_StateMachine_l253_18;
  wire                when_StateMachine_l253_19;
  wire                when_UsbHubPhy_l615_1;
  wire                when_UsbHubPhy_l622_1;
  wire                when_UsbHubPhy_l623_1;
  reg        [1:0]    ports_2_rx_packet_stateReg;
  reg        [1:0]    ports_2_rx_packet_stateNext;
  wire                when_UsbHubPhy_l532_2;
  wire                when_UsbHubPhy_l554_2;
  wire                when_StateMachine_l253_20;
  wire                when_StateMachine_l253_21;
  reg        [3:0]    ports_2_fsm_stateReg;
  reg        [3:0]    ports_2_fsm_stateNext;
  wire                when_UsbHubPhy_l643_2;
  wire                when_UsbHubPhy_l680_2;
  wire                when_UsbHubPhy_l693_2;
  wire                when_UsbHubPhy_l702_2;
  wire                when_UsbHubPhy_l710_2;
  wire                when_UsbHubPhy_l712_2;
  wire                when_UsbHubPhy_l753_2;
  wire                when_UsbHubPhy_l763_2;
  wire                when_StateMachine_l253_22;
  wire                when_StateMachine_l253_23;
  wire                when_StateMachine_l253_24;
  wire                when_StateMachine_l253_25;
  wire                when_StateMachine_l253_26;
  wire                when_StateMachine_l253_27;
  wire                when_StateMachine_l253_28;
  wire                when_StateMachine_l253_29;
  wire                when_UsbHubPhy_l615_2;
  wire                when_UsbHubPhy_l622_2;
  wire                when_UsbHubPhy_l623_2;
  reg        [1:0]    ports_3_rx_packet_stateReg;
  reg        [1:0]    ports_3_rx_packet_stateNext;
  wire                when_UsbHubPhy_l532_3;
  wire                when_UsbHubPhy_l554_3;
  wire                when_StateMachine_l253_30;
  wire                when_StateMachine_l253_31;
  reg        [3:0]    ports_3_fsm_stateReg;
  reg        [3:0]    ports_3_fsm_stateNext;
  wire                when_UsbHubPhy_l643_3;
  wire                when_UsbHubPhy_l680_3;
  wire                when_UsbHubPhy_l693_3;
  wire                when_UsbHubPhy_l702_3;
  wire                when_UsbHubPhy_l710_3;
  wire                when_UsbHubPhy_l712_3;
  wire                when_UsbHubPhy_l753_3;
  wire                when_UsbHubPhy_l763_3;
  wire                when_StateMachine_l253_32;
  wire                when_StateMachine_l253_33;
  wire                when_StateMachine_l253_34;
  wire                when_StateMachine_l253_35;
  wire                when_StateMachine_l253_36;
  wire                when_StateMachine_l253_37;
  wire                when_StateMachine_l253_38;
  wire                when_StateMachine_l253_39;
  wire                when_UsbHubPhy_l615_3;
  wire                when_UsbHubPhy_l622_3;
  wire                when_UsbHubPhy_l623_3;
  `ifndef SYNTHESIS
  reg [111:0] txShared_frame_stateReg_string;
  reg [111:0] txShared_frame_stateNext_string;
  reg [55:0] upstreamRx_stateReg_string;
  reg [55:0] upstreamRx_stateNext_string;
  reg [55:0] ports_0_rx_packet_stateReg_string;
  reg [55:0] ports_0_rx_packet_stateNext_string;
  reg [119:0] ports_0_fsm_stateReg_string;
  reg [119:0] ports_0_fsm_stateNext_string;
  reg [55:0] ports_1_rx_packet_stateReg_string;
  reg [55:0] ports_1_rx_packet_stateNext_string;
  reg [119:0] ports_1_fsm_stateReg_string;
  reg [119:0] ports_1_fsm_stateNext_string;
  reg [55:0] ports_2_rx_packet_stateReg_string;
  reg [55:0] ports_2_rx_packet_stateNext_string;
  reg [119:0] ports_2_fsm_stateReg_string;
  reg [119:0] ports_2_fsm_stateNext_string;
  reg [55:0] ports_3_rx_packet_stateReg_string;
  reg [55:0] ports_3_rx_packet_stateNext_string;
  reg [119:0] ports_3_fsm_stateReg_string;
  reg [119:0] ports_3_fsm_stateNext_string;
  `endif


  assign _zz_tickTimer_counter_valueNext_1 = tickTimer_counter_willIncrement;
  assign _zz_tickTimer_counter_valueNext = {1'd0, _zz_tickTimer_counter_valueNext_1};
  assign _zz_txShared_timer_oneCycle_1 = (txShared_timer_lowSpeed ? 5'h1f : 5'h03);
  assign _zz_txShared_timer_oneCycle = {5'd0, _zz_txShared_timer_oneCycle_1};
  assign _zz_txShared_timer_twoCycle_1 = (txShared_timer_lowSpeed ? 6'h3f : 6'h07);
  assign _zz_txShared_timer_twoCycle = {4'd0, _zz_txShared_timer_twoCycle_1};
  assign _zz_txShared_timer_fourCycle_1 = (txShared_timer_lowSpeed ? 8'h9f : 8'h13);
  assign _zz_txShared_timer_fourCycle = {2'd0, _zz_txShared_timer_fourCycle_1};
  assign _zz_txShared_rxToTxDelay_twoCycle_1 = (txShared_rxToTxDelay_lowSpeed ? 7'h7f : 7'h0f);
  assign _zz_txShared_rxToTxDelay_twoCycle = {2'd0, _zz_txShared_rxToTxDelay_twoCycle_1};
  assign _zz_txShared_lowSpeedSof_state_1 = txShared_lowSpeedSof_increment;
  assign _zz_txShared_lowSpeedSof_state = {1'd0, _zz_txShared_lowSpeedSof_state_1};
  assign _zz_when_UsbHubPhy_l506 = {1'd0, ports_0_rx_eop_minThreshold};
  assign _zz_ports_0_rx_packet_errorTimeout_trigger_1 = (ports_0_rx_packet_errorTimeout_lowSpeed ? 10'h27f : 10'h04f);
  assign _zz_ports_0_rx_packet_errorTimeout_trigger = {2'd0, _zz_ports_0_rx_packet_errorTimeout_trigger_1};
  assign _zz_ports_0_rx_disconnect_counter_1 = (! ports_0_rx_disconnect_hit);
  assign _zz_ports_0_rx_disconnect_counter = {6'd0, _zz_ports_0_rx_disconnect_counter_1};
  assign _zz_ports_0_fsm_timer_ONE_BIT_1 = (ports_0_fsm_timer_lowSpeed ? 5'h1f : 5'h03);
  assign _zz_ports_0_fsm_timer_ONE_BIT = {19'd0, _zz_ports_0_fsm_timer_ONE_BIT_1};
  assign _zz_ports_0_fsm_timer_TWO_BIT_1 = (ports_0_fsm_timer_lowSpeed ? 6'h3f : 6'h07);
  assign _zz_ports_0_fsm_timer_TWO_BIT = {18'd0, _zz_ports_0_fsm_timer_TWO_BIT_1};
  assign _zz_when_UsbHubPhy_l506_1 = {1'd0, ports_1_rx_eop_minThreshold};
  assign _zz_ports_1_rx_packet_errorTimeout_trigger_1 = (ports_1_rx_packet_errorTimeout_lowSpeed ? 10'h27f : 10'h04f);
  assign _zz_ports_1_rx_packet_errorTimeout_trigger = {2'd0, _zz_ports_1_rx_packet_errorTimeout_trigger_1};
  assign _zz_ports_1_rx_disconnect_counter_1 = (! ports_1_rx_disconnect_hit);
  assign _zz_ports_1_rx_disconnect_counter = {6'd0, _zz_ports_1_rx_disconnect_counter_1};
  assign _zz_ports_1_fsm_timer_ONE_BIT_1 = (ports_1_fsm_timer_lowSpeed ? 5'h1f : 5'h03);
  assign _zz_ports_1_fsm_timer_ONE_BIT = {19'd0, _zz_ports_1_fsm_timer_ONE_BIT_1};
  assign _zz_ports_1_fsm_timer_TWO_BIT_1 = (ports_1_fsm_timer_lowSpeed ? 6'h3f : 6'h07);
  assign _zz_ports_1_fsm_timer_TWO_BIT = {18'd0, _zz_ports_1_fsm_timer_TWO_BIT_1};
  assign _zz_when_UsbHubPhy_l506_2 = {1'd0, ports_2_rx_eop_minThreshold};
  assign _zz_ports_2_rx_packet_errorTimeout_trigger_1 = (ports_2_rx_packet_errorTimeout_lowSpeed ? 10'h27f : 10'h04f);
  assign _zz_ports_2_rx_packet_errorTimeout_trigger = {2'd0, _zz_ports_2_rx_packet_errorTimeout_trigger_1};
  assign _zz_ports_2_rx_disconnect_counter_1 = (! ports_2_rx_disconnect_hit);
  assign _zz_ports_2_rx_disconnect_counter = {6'd0, _zz_ports_2_rx_disconnect_counter_1};
  assign _zz_ports_2_fsm_timer_ONE_BIT_1 = (ports_2_fsm_timer_lowSpeed ? 5'h1f : 5'h03);
  assign _zz_ports_2_fsm_timer_ONE_BIT = {19'd0, _zz_ports_2_fsm_timer_ONE_BIT_1};
  assign _zz_ports_2_fsm_timer_TWO_BIT_1 = (ports_2_fsm_timer_lowSpeed ? 6'h3f : 6'h07);
  assign _zz_ports_2_fsm_timer_TWO_BIT = {18'd0, _zz_ports_2_fsm_timer_TWO_BIT_1};
  assign _zz_when_UsbHubPhy_l506_3 = {1'd0, ports_3_rx_eop_minThreshold};
  assign _zz_ports_3_rx_packet_errorTimeout_trigger_1 = (ports_3_rx_packet_errorTimeout_lowSpeed ? 10'h27f : 10'h04f);
  assign _zz_ports_3_rx_packet_errorTimeout_trigger = {2'd0, _zz_ports_3_rx_packet_errorTimeout_trigger_1};
  assign _zz_ports_3_rx_disconnect_counter_1 = (! ports_3_rx_disconnect_hit);
  assign _zz_ports_3_rx_disconnect_counter = {6'd0, _zz_ports_3_rx_disconnect_counter_1};
  assign _zz_ports_3_fsm_timer_ONE_BIT_1 = (ports_3_fsm_timer_lowSpeed ? 5'h1f : 5'h03);
  assign _zz_ports_3_fsm_timer_ONE_BIT = {19'd0, _zz_ports_3_fsm_timer_ONE_BIT_1};
  assign _zz_ports_3_fsm_timer_TWO_BIT_1 = (ports_3_fsm_timer_lowSpeed ? 6'h3f : 6'h07);
  assign _zz_ports_3_fsm_timer_TWO_BIT = {18'd0, _zz_ports_3_fsm_timer_TWO_BIT_1};
  UsbOhciAxi4_UsbLsFsPhyFilter ports_0_filter (
    .io_lowSpeed       (io_ctrl_lowSpeed                ), //i
    .io_usb_dp         (io_usb_0_rx_dp                  ), //i
    .io_usb_dm         (io_usb_0_rx_dm                  ), //i
    .io_filtred_dp     (ports_0_filter_io_filtred_dp    ), //o
    .io_filtred_dm     (ports_0_filter_io_filtred_dm    ), //o
    .io_filtred_d      (ports_0_filter_io_filtred_d     ), //o
    .io_filtred_se0    (ports_0_filter_io_filtred_se0   ), //o
    .io_filtred_sample (ports_0_filter_io_filtred_sample), //o
    .phy_clk           (phy_clk                         ), //i
    .phy_reset         (phy_reset                       )  //i
  );
  UsbOhciAxi4_UsbLsFsPhyFilter ports_1_filter (
    .io_lowSpeed       (io_ctrl_lowSpeed                ), //i
    .io_usb_dp         (io_usb_1_rx_dp                  ), //i
    .io_usb_dm         (io_usb_1_rx_dm                  ), //i
    .io_filtred_dp     (ports_1_filter_io_filtred_dp    ), //o
    .io_filtred_dm     (ports_1_filter_io_filtred_dm    ), //o
    .io_filtred_d      (ports_1_filter_io_filtred_d     ), //o
    .io_filtred_se0    (ports_1_filter_io_filtred_se0   ), //o
    .io_filtred_sample (ports_1_filter_io_filtred_sample), //o
    .phy_clk           (phy_clk                         ), //i
    .phy_reset         (phy_reset                       )  //i
  );
  UsbOhciAxi4_UsbLsFsPhyFilter ports_2_filter (
    .io_lowSpeed       (io_ctrl_lowSpeed                ), //i
    .io_usb_dp         (io_usb_2_rx_dp                  ), //i
    .io_usb_dm         (io_usb_2_rx_dm                  ), //i
    .io_filtred_dp     (ports_2_filter_io_filtred_dp    ), //o
    .io_filtred_dm     (ports_2_filter_io_filtred_dm    ), //o
    .io_filtred_d      (ports_2_filter_io_filtred_d     ), //o
    .io_filtred_se0    (ports_2_filter_io_filtred_se0   ), //o
    .io_filtred_sample (ports_2_filter_io_filtred_sample), //o
    .phy_clk           (phy_clk                         ), //i
    .phy_reset         (phy_reset                       )  //i
  );
  UsbOhciAxi4_UsbLsFsPhyFilter ports_3_filter (
    .io_lowSpeed       (io_ctrl_lowSpeed                ), //i
    .io_usb_dp         (io_usb_3_rx_dp                  ), //i
    .io_usb_dm         (io_usb_3_rx_dm                  ), //i
    .io_filtred_dp     (ports_3_filter_io_filtred_dp    ), //o
    .io_filtred_dm     (ports_3_filter_io_filtred_dm    ), //o
    .io_filtred_d      (ports_3_filter_io_filtred_d     ), //o
    .io_filtred_se0    (ports_3_filter_io_filtred_se0   ), //o
    .io_filtred_sample (ports_3_filter_io_filtred_sample), //o
    .phy_clk           (phy_clk                         ), //i
    .phy_reset         (phy_reset                       )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_BOOT : txShared_frame_stateReg_string = "BOOT          ";
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : txShared_frame_stateReg_string = "IDLE          ";
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : txShared_frame_stateReg_string = "TAKE_LINE     ";
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : txShared_frame_stateReg_string = "PREAMBLE_SYNC ";
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : txShared_frame_stateReg_string = "PREAMBLE_PID  ";
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : txShared_frame_stateReg_string = "PREAMBLE_DELAY";
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : txShared_frame_stateReg_string = "SYNC          ";
      UsbOhciAxi4_txShared_frame_enumDef_DATA : txShared_frame_stateReg_string = "DATA          ";
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : txShared_frame_stateReg_string = "EOP_0         ";
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : txShared_frame_stateReg_string = "EOP_1         ";
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : txShared_frame_stateReg_string = "EOP_2         ";
      default : txShared_frame_stateReg_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(txShared_frame_stateNext)
      UsbOhciAxi4_txShared_frame_enumDef_BOOT : txShared_frame_stateNext_string = "BOOT          ";
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : txShared_frame_stateNext_string = "IDLE          ";
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : txShared_frame_stateNext_string = "TAKE_LINE     ";
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : txShared_frame_stateNext_string = "PREAMBLE_SYNC ";
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : txShared_frame_stateNext_string = "PREAMBLE_PID  ";
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : txShared_frame_stateNext_string = "PREAMBLE_DELAY";
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : txShared_frame_stateNext_string = "SYNC          ";
      UsbOhciAxi4_txShared_frame_enumDef_DATA : txShared_frame_stateNext_string = "DATA          ";
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : txShared_frame_stateNext_string = "EOP_0         ";
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : txShared_frame_stateNext_string = "EOP_1         ";
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : txShared_frame_stateNext_string = "EOP_2         ";
      default : txShared_frame_stateNext_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(upstreamRx_stateReg)
      UsbOhciAxi4_upstreamRx_enumDef_BOOT : upstreamRx_stateReg_string = "BOOT   ";
      UsbOhciAxi4_upstreamRx_enumDef_IDLE : upstreamRx_stateReg_string = "IDLE   ";
      UsbOhciAxi4_upstreamRx_enumDef_SUSPEND : upstreamRx_stateReg_string = "SUSPEND";
      default : upstreamRx_stateReg_string = "???????";
    endcase
  end
  always @(*) begin
    case(upstreamRx_stateNext)
      UsbOhciAxi4_upstreamRx_enumDef_BOOT : upstreamRx_stateNext_string = "BOOT   ";
      UsbOhciAxi4_upstreamRx_enumDef_IDLE : upstreamRx_stateNext_string = "IDLE   ";
      UsbOhciAxi4_upstreamRx_enumDef_SUSPEND : upstreamRx_stateNext_string = "SUSPEND";
      default : upstreamRx_stateNext_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_BOOT : ports_0_rx_packet_stateReg_string = "BOOT   ";
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : ports_0_rx_packet_stateReg_string = "IDLE   ";
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : ports_0_rx_packet_stateReg_string = "PACKET ";
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : ports_0_rx_packet_stateReg_string = "ERRORED";
      default : ports_0_rx_packet_stateReg_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_0_rx_packet_stateNext)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_BOOT : ports_0_rx_packet_stateNext_string = "BOOT   ";
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : ports_0_rx_packet_stateNext_string = "IDLE   ";
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : ports_0_rx_packet_stateNext_string = "PACKET ";
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : ports_0_rx_packet_stateNext_string = "ERRORED";
      default : ports_0_rx_packet_stateNext_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_BOOT : ports_0_fsm_stateReg_string = "BOOT           ";
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : ports_0_fsm_stateReg_string = "POWER_OFF      ";
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : ports_0_fsm_stateReg_string = "DISCONNECTED   ";
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : ports_0_fsm_stateReg_string = "DISABLED       ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : ports_0_fsm_stateReg_string = "RESETTING      ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : ports_0_fsm_stateReg_string = "RESETTING_DELAY";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : ports_0_fsm_stateReg_string = "RESETTING_SYNC ";
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : ports_0_fsm_stateReg_string = "ENABLED        ";
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : ports_0_fsm_stateReg_string = "SUSPENDED      ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : ports_0_fsm_stateReg_string = "RESUMING       ";
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : ports_0_fsm_stateReg_string = "SEND_EOP_0     ";
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : ports_0_fsm_stateReg_string = "SEND_EOP_1     ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : ports_0_fsm_stateReg_string = "RESTART_S      ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : ports_0_fsm_stateReg_string = "RESTART_E      ";
      default : ports_0_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_0_fsm_stateNext)
      UsbOhciAxi4_ports_0_fsm_enumDef_BOOT : ports_0_fsm_stateNext_string = "BOOT           ";
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : ports_0_fsm_stateNext_string = "POWER_OFF      ";
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : ports_0_fsm_stateNext_string = "DISCONNECTED   ";
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : ports_0_fsm_stateNext_string = "DISABLED       ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : ports_0_fsm_stateNext_string = "RESETTING      ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : ports_0_fsm_stateNext_string = "RESETTING_DELAY";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : ports_0_fsm_stateNext_string = "RESETTING_SYNC ";
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : ports_0_fsm_stateNext_string = "ENABLED        ";
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : ports_0_fsm_stateNext_string = "SUSPENDED      ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : ports_0_fsm_stateNext_string = "RESUMING       ";
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : ports_0_fsm_stateNext_string = "SEND_EOP_0     ";
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : ports_0_fsm_stateNext_string = "SEND_EOP_1     ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : ports_0_fsm_stateNext_string = "RESTART_S      ";
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : ports_0_fsm_stateNext_string = "RESTART_E      ";
      default : ports_0_fsm_stateNext_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_BOOT : ports_1_rx_packet_stateReg_string = "BOOT   ";
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : ports_1_rx_packet_stateReg_string = "IDLE   ";
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : ports_1_rx_packet_stateReg_string = "PACKET ";
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : ports_1_rx_packet_stateReg_string = "ERRORED";
      default : ports_1_rx_packet_stateReg_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_1_rx_packet_stateNext)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_BOOT : ports_1_rx_packet_stateNext_string = "BOOT   ";
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : ports_1_rx_packet_stateNext_string = "IDLE   ";
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : ports_1_rx_packet_stateNext_string = "PACKET ";
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : ports_1_rx_packet_stateNext_string = "ERRORED";
      default : ports_1_rx_packet_stateNext_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_BOOT : ports_1_fsm_stateReg_string = "BOOT           ";
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : ports_1_fsm_stateReg_string = "POWER_OFF      ";
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : ports_1_fsm_stateReg_string = "DISCONNECTED   ";
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : ports_1_fsm_stateReg_string = "DISABLED       ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : ports_1_fsm_stateReg_string = "RESETTING      ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : ports_1_fsm_stateReg_string = "RESETTING_DELAY";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : ports_1_fsm_stateReg_string = "RESETTING_SYNC ";
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : ports_1_fsm_stateReg_string = "ENABLED        ";
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : ports_1_fsm_stateReg_string = "SUSPENDED      ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : ports_1_fsm_stateReg_string = "RESUMING       ";
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : ports_1_fsm_stateReg_string = "SEND_EOP_0     ";
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : ports_1_fsm_stateReg_string = "SEND_EOP_1     ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : ports_1_fsm_stateReg_string = "RESTART_S      ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : ports_1_fsm_stateReg_string = "RESTART_E      ";
      default : ports_1_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_1_fsm_stateNext)
      UsbOhciAxi4_ports_1_fsm_enumDef_BOOT : ports_1_fsm_stateNext_string = "BOOT           ";
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : ports_1_fsm_stateNext_string = "POWER_OFF      ";
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : ports_1_fsm_stateNext_string = "DISCONNECTED   ";
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : ports_1_fsm_stateNext_string = "DISABLED       ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : ports_1_fsm_stateNext_string = "RESETTING      ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : ports_1_fsm_stateNext_string = "RESETTING_DELAY";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : ports_1_fsm_stateNext_string = "RESETTING_SYNC ";
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : ports_1_fsm_stateNext_string = "ENABLED        ";
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : ports_1_fsm_stateNext_string = "SUSPENDED      ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : ports_1_fsm_stateNext_string = "RESUMING       ";
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : ports_1_fsm_stateNext_string = "SEND_EOP_0     ";
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : ports_1_fsm_stateNext_string = "SEND_EOP_1     ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : ports_1_fsm_stateNext_string = "RESTART_S      ";
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : ports_1_fsm_stateNext_string = "RESTART_E      ";
      default : ports_1_fsm_stateNext_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_BOOT : ports_2_rx_packet_stateReg_string = "BOOT   ";
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : ports_2_rx_packet_stateReg_string = "IDLE   ";
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : ports_2_rx_packet_stateReg_string = "PACKET ";
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : ports_2_rx_packet_stateReg_string = "ERRORED";
      default : ports_2_rx_packet_stateReg_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_2_rx_packet_stateNext)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_BOOT : ports_2_rx_packet_stateNext_string = "BOOT   ";
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : ports_2_rx_packet_stateNext_string = "IDLE   ";
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : ports_2_rx_packet_stateNext_string = "PACKET ";
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : ports_2_rx_packet_stateNext_string = "ERRORED";
      default : ports_2_rx_packet_stateNext_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_BOOT : ports_2_fsm_stateReg_string = "BOOT           ";
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : ports_2_fsm_stateReg_string = "POWER_OFF      ";
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : ports_2_fsm_stateReg_string = "DISCONNECTED   ";
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : ports_2_fsm_stateReg_string = "DISABLED       ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : ports_2_fsm_stateReg_string = "RESETTING      ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : ports_2_fsm_stateReg_string = "RESETTING_DELAY";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : ports_2_fsm_stateReg_string = "RESETTING_SYNC ";
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : ports_2_fsm_stateReg_string = "ENABLED        ";
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : ports_2_fsm_stateReg_string = "SUSPENDED      ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : ports_2_fsm_stateReg_string = "RESUMING       ";
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : ports_2_fsm_stateReg_string = "SEND_EOP_0     ";
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : ports_2_fsm_stateReg_string = "SEND_EOP_1     ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : ports_2_fsm_stateReg_string = "RESTART_S      ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : ports_2_fsm_stateReg_string = "RESTART_E      ";
      default : ports_2_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_2_fsm_stateNext)
      UsbOhciAxi4_ports_2_fsm_enumDef_BOOT : ports_2_fsm_stateNext_string = "BOOT           ";
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : ports_2_fsm_stateNext_string = "POWER_OFF      ";
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : ports_2_fsm_stateNext_string = "DISCONNECTED   ";
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : ports_2_fsm_stateNext_string = "DISABLED       ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : ports_2_fsm_stateNext_string = "RESETTING      ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : ports_2_fsm_stateNext_string = "RESETTING_DELAY";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : ports_2_fsm_stateNext_string = "RESETTING_SYNC ";
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : ports_2_fsm_stateNext_string = "ENABLED        ";
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : ports_2_fsm_stateNext_string = "SUSPENDED      ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : ports_2_fsm_stateNext_string = "RESUMING       ";
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : ports_2_fsm_stateNext_string = "SEND_EOP_0     ";
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : ports_2_fsm_stateNext_string = "SEND_EOP_1     ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : ports_2_fsm_stateNext_string = "RESTART_S      ";
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : ports_2_fsm_stateNext_string = "RESTART_E      ";
      default : ports_2_fsm_stateNext_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_BOOT : ports_3_rx_packet_stateReg_string = "BOOT   ";
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : ports_3_rx_packet_stateReg_string = "IDLE   ";
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : ports_3_rx_packet_stateReg_string = "PACKET ";
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : ports_3_rx_packet_stateReg_string = "ERRORED";
      default : ports_3_rx_packet_stateReg_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_3_rx_packet_stateNext)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_BOOT : ports_3_rx_packet_stateNext_string = "BOOT   ";
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : ports_3_rx_packet_stateNext_string = "IDLE   ";
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : ports_3_rx_packet_stateNext_string = "PACKET ";
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : ports_3_rx_packet_stateNext_string = "ERRORED";
      default : ports_3_rx_packet_stateNext_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_BOOT : ports_3_fsm_stateReg_string = "BOOT           ";
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : ports_3_fsm_stateReg_string = "POWER_OFF      ";
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : ports_3_fsm_stateReg_string = "DISCONNECTED   ";
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : ports_3_fsm_stateReg_string = "DISABLED       ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : ports_3_fsm_stateReg_string = "RESETTING      ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : ports_3_fsm_stateReg_string = "RESETTING_DELAY";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : ports_3_fsm_stateReg_string = "RESETTING_SYNC ";
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : ports_3_fsm_stateReg_string = "ENABLED        ";
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : ports_3_fsm_stateReg_string = "SUSPENDED      ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : ports_3_fsm_stateReg_string = "RESUMING       ";
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : ports_3_fsm_stateReg_string = "SEND_EOP_0     ";
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : ports_3_fsm_stateReg_string = "SEND_EOP_1     ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : ports_3_fsm_stateReg_string = "RESTART_S      ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : ports_3_fsm_stateReg_string = "RESTART_E      ";
      default : ports_3_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_3_fsm_stateNext)
      UsbOhciAxi4_ports_3_fsm_enumDef_BOOT : ports_3_fsm_stateNext_string = "BOOT           ";
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : ports_3_fsm_stateNext_string = "POWER_OFF      ";
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : ports_3_fsm_stateNext_string = "DISCONNECTED   ";
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : ports_3_fsm_stateNext_string = "DISABLED       ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : ports_3_fsm_stateNext_string = "RESETTING      ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : ports_3_fsm_stateNext_string = "RESETTING_DELAY";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : ports_3_fsm_stateNext_string = "RESETTING_SYNC ";
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : ports_3_fsm_stateNext_string = "ENABLED        ";
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : ports_3_fsm_stateNext_string = "SUSPENDED      ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : ports_3_fsm_stateNext_string = "RESUMING       ";
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : ports_3_fsm_stateNext_string = "SEND_EOP_0     ";
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : ports_3_fsm_stateNext_string = "SEND_EOP_1     ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : ports_3_fsm_stateNext_string = "RESTART_S      ";
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : ports_3_fsm_stateNext_string = "RESTART_E      ";
      default : ports_3_fsm_stateNext_string = "???????????????";
    endcase
  end
  `endif

  assign tickTimer_counter_willClear = 1'b0;
  assign tickTimer_counter_willOverflowIfInc = (tickTimer_counter_value == 2'b11);
  assign tickTimer_counter_willOverflow = (tickTimer_counter_willOverflowIfInc && tickTimer_counter_willIncrement);
  always @(*) begin
    tickTimer_counter_valueNext = (tickTimer_counter_value + _zz_tickTimer_counter_valueNext);
    if(tickTimer_counter_willClear) begin
      tickTimer_counter_valueNext = 2'b00;
    end
  end

  assign tickTimer_counter_willIncrement = 1'b1;
  assign tickTimer_tick = (tickTimer_counter_willOverflow == 1'b1);
  assign io_ctrl_tick = tickTimer_tick;
  always @(*) begin
    txShared_timer_clear = 1'b0;
    if(txShared_encoder_input_valid) begin
      if(txShared_encoder_input_data) begin
        if(txShared_timer_oneCycle) begin
          if(when_UsbHubPhy_l194) begin
            txShared_timer_clear = 1'b1;
          end
        end
      end
    end
    if(txShared_encoder_input_ready) begin
      txShared_timer_clear = 1'b1;
    end
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
        txShared_timer_clear = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
        if(txShared_timer_oneCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        if(txShared_timer_fourCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
        if(txShared_timer_twoCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
        if(txShared_timer_oneCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
        if(txShared_timer_twoCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign txShared_timer_inc = 1'b1;
  assign txShared_timer_oneCycle = (txShared_timer_counter == _zz_txShared_timer_oneCycle);
  assign txShared_timer_twoCycle = (txShared_timer_counter == _zz_txShared_timer_twoCycle);
  assign txShared_timer_fourCycle = (txShared_timer_counter == _zz_txShared_timer_fourCycle);
  always @(*) begin
    txShared_timer_lowSpeed = 1'b0;
    if(txShared_encoder_input_valid) begin
      txShared_timer_lowSpeed = txShared_encoder_input_lowSpeed;
    end
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
        txShared_timer_lowSpeed = 1'b0;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        txShared_timer_lowSpeed = 1'b0;
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
        txShared_timer_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
        txShared_timer_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
        txShared_timer_lowSpeed = txShared_frame_wasLowSpeed;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_rxToTxDelay_clear = 1'b0;
    if(ports_0_rx_eop_hit) begin
      txShared_rxToTxDelay_clear = 1'b1;
    end
    if(ports_1_rx_eop_hit) begin
      txShared_rxToTxDelay_clear = 1'b1;
    end
    if(ports_2_rx_eop_hit) begin
      txShared_rxToTxDelay_clear = 1'b1;
    end
    if(ports_3_rx_eop_hit) begin
      txShared_rxToTxDelay_clear = 1'b1;
    end
  end

  assign txShared_rxToTxDelay_inc = 1'b1;
  assign txShared_rxToTxDelay_twoCycle = (txShared_rxToTxDelay_counter == _zz_txShared_rxToTxDelay_twoCycle);
  always @(*) begin
    txShared_encoder_input_valid = 1'b0;
    if(txShared_serialiser_input_valid) begin
      txShared_encoder_input_valid = 1'b1;
    end
  end

  always @(*) begin
    txShared_encoder_input_ready = 1'b0;
    if(txShared_encoder_input_valid) begin
      if(txShared_encoder_input_data) begin
        if(txShared_timer_oneCycle) begin
          txShared_encoder_input_ready = 1'b1;
          if(when_UsbHubPhy_l194) begin
            txShared_encoder_input_ready = 1'b0;
          end
        end
      end else begin
        if(txShared_timer_oneCycle) begin
          txShared_encoder_input_ready = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    txShared_encoder_input_data = 1'bx;
    if(txShared_serialiser_input_valid) begin
      txShared_encoder_input_data = txShared_serialiser_input_data[txShared_serialiser_bitCounter];
    end
  end

  always @(*) begin
    txShared_encoder_input_lowSpeed = 1'bx;
    if(txShared_serialiser_input_valid) begin
      txShared_encoder_input_lowSpeed = txShared_serialiser_input_lowSpeed;
    end
  end

  always @(*) begin
    txShared_encoder_output_valid = 1'b0;
    if(txShared_encoder_input_valid) begin
      txShared_encoder_output_valid = txShared_encoder_input_valid;
    end
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
        txShared_encoder_output_valid = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        txShared_encoder_output_valid = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
        txShared_encoder_output_valid = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
        txShared_encoder_output_valid = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_encoder_output_se0 = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
        txShared_encoder_output_se0 = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_encoder_output_lowSpeed = 1'bx;
    if(txShared_encoder_input_valid) begin
      txShared_encoder_output_lowSpeed = txShared_encoder_input_lowSpeed;
    end
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
        txShared_encoder_output_lowSpeed = 1'b0;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        txShared_encoder_output_lowSpeed = 1'b0;
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
        txShared_encoder_output_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
        txShared_encoder_output_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_encoder_output_data = 1'bx;
    if(txShared_encoder_input_valid) begin
      if(txShared_encoder_input_data) begin
        txShared_encoder_output_data = txShared_encoder_state;
      end else begin
        txShared_encoder_output_data = (! txShared_encoder_state);
      end
    end
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
        txShared_encoder_output_data = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        txShared_encoder_output_data = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
        txShared_encoder_output_data = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UsbHubPhy_l194 = (txShared_encoder_counter == 3'b101);
  assign when_UsbHubPhy_l199 = (txShared_encoder_counter == 3'b110);
  assign when_UsbHubPhy_l213 = (! txShared_encoder_input_valid);
  always @(*) begin
    txShared_serialiser_input_valid = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
        txShared_serialiser_input_valid = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
        txShared_serialiser_input_valid = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
        txShared_serialiser_input_valid = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
        txShared_serialiser_input_valid = 1'b1;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_serialiser_input_ready = 1'b0;
    if(txShared_serialiser_input_valid) begin
      if(txShared_encoder_input_ready) begin
        if(when_UsbHubPhy_l239) begin
          txShared_serialiser_input_ready = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    txShared_serialiser_input_data = 8'bxxxxxxxx;
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
        txShared_serialiser_input_data = 8'h80;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
        txShared_serialiser_input_data = 8'h3c;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
        txShared_serialiser_input_data = 8'h80;
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
        txShared_serialiser_input_data = io_ctrl_tx_payload_fragment;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_serialiser_input_lowSpeed = 1'bx;
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
        txShared_serialiser_input_lowSpeed = 1'b0;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
        txShared_serialiser_input_lowSpeed = 1'b0;
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
        txShared_serialiser_input_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
        txShared_serialiser_input_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UsbHubPhy_l239 = (txShared_serialiser_bitCounter == 3'b111);
  assign when_UsbHubPhy_l245 = ((! txShared_serialiser_input_valid) || txShared_serialiser_input_ready);
  always @(*) begin
    txShared_lowSpeedSof_increment = 1'b0;
    if(when_UsbHubPhy_l256) begin
      if(when_UsbHubPhy_l257) begin
        txShared_lowSpeedSof_increment = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l254 = ((! txShared_encoder_output_valid) && txShared_encoder_output_valid_regNext);
  assign when_UsbHubPhy_l256 = (txShared_lowSpeedSof_state == 2'b00);
  assign io_ctrl_tx_fire = (io_ctrl_tx_valid && io_ctrl_tx_ready);
  assign when_UsbHubPhy_l257 = ((io_ctrl_tx_valid && io_ctrl_tx_payload_first) && (io_ctrl_tx_payload_fragment == 8'ha5));
  assign when_UsbHubPhy_l264 = (txShared_lowSpeedSof_timer == 5'h1f);
  assign txShared_lowSpeedSof_valid = (txShared_lowSpeedSof_state != 2'b00);
  assign txShared_lowSpeedSof_data = 1'b0;
  assign txShared_lowSpeedSof_se0 = (txShared_lowSpeedSof_state != 2'b11);
  assign txShared_frame_wantExit = 1'b0;
  always @(*) begin
    txShared_frame_wantStart = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
        txShared_frame_wantStart = 1'b1;
      end
    endcase
  end

  assign txShared_frame_wantKill = 1'b0;
  assign txShared_frame_busy = (! (txShared_frame_stateReg == UsbOhciAxi4_txShared_frame_enumDef_BOOT));
  always @(*) begin
    io_ctrl_tx_ready = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
        if(txShared_serialiser_input_ready) begin
          io_ctrl_tx_ready = 1'b1;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_txEop = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
        if(txShared_timer_twoCycle) begin
          io_ctrl_txEop = 1'b1;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  assign upstreamRx_wantExit = 1'b0;
  always @(*) begin
    upstreamRx_wantStart = 1'b0;
    case(upstreamRx_stateReg)
      UsbOhciAxi4_upstreamRx_enumDef_IDLE : begin
      end
      UsbOhciAxi4_upstreamRx_enumDef_SUSPEND : begin
      end
      default : begin
        upstreamRx_wantStart = 1'b1;
      end
    endcase
  end

  assign upstreamRx_wantKill = 1'b0;
  always @(*) begin
    upstreamRx_timer_clear = 1'b0;
    if(txShared_encoder_output_valid) begin
      upstreamRx_timer_clear = 1'b1;
    end
  end

  assign upstreamRx_timer_inc = 1'b1;
  assign upstreamRx_timer_IDLE_EOI = (upstreamRx_timer_counter == 20'h2327f);
  assign io_ctrl_overcurrent = 1'b0;
  always @(*) begin
    io_ctrl_rx_flow_valid = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : begin
        if(ports_0_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l532) begin
            io_ctrl_rx_flow_valid = ports_0_rx_enablePackets;
          end
        end
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : begin
        if(ports_1_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l532_1) begin
            io_ctrl_rx_flow_valid = ports_1_rx_enablePackets;
          end
        end
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : begin
        if(ports_2_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l532_2) begin
            io_ctrl_rx_flow_valid = ports_2_rx_enablePackets;
          end
        end
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : begin
        if(ports_3_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l532_3) begin
            io_ctrl_rx_flow_valid = ports_3_rx_enablePackets;
          end
        end
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_rx_active = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_active = 1'b1;
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : begin
        io_ctrl_rx_active = 1'b1;
      end
      default : begin
      end
    endcase
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_active = 1'b1;
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : begin
        io_ctrl_rx_active = 1'b1;
      end
      default : begin
      end
    endcase
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_active = 1'b1;
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : begin
        io_ctrl_rx_active = 1'b1;
      end
      default : begin
      end
    endcase
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_active = 1'b1;
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : begin
        io_ctrl_rx_active = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_rx_flow_payload_stuffingError = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_stuffingError = ports_0_rx_stuffingError;
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_stuffingError = ports_1_rx_stuffingError;
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_stuffingError = ports_2_rx_stuffingError;
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_stuffingError = ports_3_rx_stuffingError;
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_rx_flow_payload_data = 8'bxxxxxxxx;
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_data = ports_0_rx_history_value;
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_data = ports_1_rx_history_value;
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_data = ports_2_rx_history_value;
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_data = ports_3_rx_history_value;
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    resumeFromPort = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l753) begin
          resumeFromPort = 1'b1;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l763) begin
          resumeFromPort = 1'b1;
        end
      end
      default : begin
      end
    endcase
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l753_1) begin
          resumeFromPort = 1'b1;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l763_1) begin
          resumeFromPort = 1'b1;
        end
      end
      default : begin
      end
    endcase
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l753_2) begin
          resumeFromPort = 1'b1;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l763_2) begin
          resumeFromPort = 1'b1;
        end
      end
      default : begin
      end
    endcase
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l753_3) begin
          resumeFromPort = 1'b1;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l763_3) begin
          resumeFromPort = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_0_lowSpeed = ports_0_portLowSpeed;
  assign io_ctrl_ports_0_remoteResume = 1'b0;
  always @(*) begin
    ports_0_rx_enablePackets = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
        ports_0_rx_enablePackets = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_0_rx_j = ((ports_0_filter_io_filtred_dp == (! ports_0_portLowSpeed)) && (ports_0_filter_io_filtred_dm == ports_0_portLowSpeed));
  assign ports_0_rx_k = ((ports_0_filter_io_filtred_dp == ports_0_portLowSpeed) && (ports_0_filter_io_filtred_dm == (! ports_0_portLowSpeed)));
  assign io_management_0_power = io_ctrl_ports_0_power;
  assign io_ctrl_ports_0_overcurrent = io_management_0_overcurrent;
  always @(*) begin
    ports_0_rx_waitSync = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : begin
        ports_0_rx_waitSync = 1'b1;
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253) begin
      ports_0_rx_waitSync = 1'b1;
    end
  end

  always @(*) begin
    ports_0_rx_decoder_output_valid = 1'b0;
    if(ports_0_filter_io_filtred_sample) begin
      ports_0_rx_decoder_output_valid = 1'b1;
    end
  end

  always @(*) begin
    ports_0_rx_decoder_output_payload = 1'bx;
    if(ports_0_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l450) begin
        ports_0_rx_decoder_output_payload = 1'b0;
      end else begin
        ports_0_rx_decoder_output_payload = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l450 = ((ports_0_rx_decoder_state ^ ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed);
  assign ports_0_rx_destuffer_unstuffNext = (ports_0_rx_destuffer_counter == 3'b110);
  assign ports_0_rx_destuffer_output_valid = (ports_0_rx_decoder_output_valid && (! ports_0_rx_destuffer_unstuffNext));
  assign ports_0_rx_destuffer_output_payload = ports_0_rx_decoder_output_payload;
  assign when_UsbHubPhy_l471 = ((! ports_0_rx_decoder_output_payload) || ports_0_rx_destuffer_unstuffNext);
  assign ports_0_rx_history_updated = ports_0_rx_destuffer_output_valid;
  assign _zz_ports_0_rx_history_value = ports_0_rx_destuffer_output_payload;
  assign ports_0_rx_history_value = {_zz_ports_0_rx_history_value,{_zz_ports_0_rx_history_value_1,{_zz_ports_0_rx_history_value_2,{_zz_ports_0_rx_history_value_3,{_zz_ports_0_rx_history_value_4,{_zz_ports_0_rx_history_value_5,{_zz_ports_0_rx_history_value_6,_zz_ports_0_rx_history_value_7}}}}}}};
  assign ports_0_rx_history_sync_hit = (ports_0_rx_history_updated && (ports_0_rx_history_value == 8'hd5));
  assign ports_0_rx_eop_maxThreshold = (io_ctrl_lowSpeed ? 7'h60 : 7'h0c);
  assign ports_0_rx_eop_minThreshold = (io_ctrl_lowSpeed ? 6'h2a : 6'h05);
  assign ports_0_rx_eop_maxHit = (ports_0_rx_eop_counter == ports_0_rx_eop_maxThreshold);
  always @(*) begin
    ports_0_rx_eop_hit = 1'b0;
    if(ports_0_rx_j) begin
      if(when_UsbHubPhy_l506) begin
        ports_0_rx_eop_hit = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l498 = ((! ports_0_filter_io_filtred_dp) && (! ports_0_filter_io_filtred_dm));
  assign when_UsbHubPhy_l499 = (! ports_0_rx_eop_maxHit);
  assign when_UsbHubPhy_l506 = ((_zz_when_UsbHubPhy_l506 <= ports_0_rx_eop_counter) && (! ports_0_rx_eop_maxHit));
  assign ports_0_rx_packet_wantExit = 1'b0;
  always @(*) begin
    ports_0_rx_packet_wantStart = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
        ports_0_rx_packet_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_0_rx_packet_wantKill = 1'b0;
  always @(*) begin
    ports_0_rx_packet_errorTimeout_clear = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : begin
        if(when_UsbHubPhy_l554) begin
          ports_0_rx_packet_errorTimeout_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_1) begin
      ports_0_rx_packet_errorTimeout_clear = 1'b1;
    end
  end

  assign ports_0_rx_packet_errorTimeout_inc = 1'b1;
  assign ports_0_rx_packet_errorTimeout_lowSpeed = io_ctrl_lowSpeed;
  assign ports_0_rx_packet_errorTimeout_trigger = (ports_0_rx_packet_errorTimeout_counter == _zz_ports_0_rx_packet_errorTimeout_trigger);
  always @(*) begin
    ports_0_rx_disconnect_clear = 1'b0;
    if(when_UsbHubPhy_l578) begin
      ports_0_rx_disconnect_clear = 1'b1;
    end
    if(when_UsbHubPhy_l772) begin
      ports_0_rx_disconnect_clear = 1'b1;
    end
  end

  assign ports_0_rx_disconnect_hit = (ports_0_rx_disconnect_counter == 7'h68);
  assign ports_0_rx_disconnect_event = (ports_0_rx_disconnect_hit && (! ports_0_rx_disconnect_hitLast));
  assign when_UsbHubPhy_l578 = ((! ports_0_filter_io_filtred_se0) || io_usb_0_tx_enable);
  assign io_ctrl_ports_0_disconnect = ports_0_rx_disconnect_event;
  assign ports_0_fsm_wantExit = 1'b0;
  always @(*) begin
    ports_0_fsm_wantStart = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
        ports_0_fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_0_fsm_wantKill = 1'b0;
  always @(*) begin
    ports_0_fsm_timer_clear = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
        if(when_UsbHubPhy_l643) begin
          ports_0_fsm_timer_clear = 1'b1;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_2) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_3) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_4) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_5) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_6) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_7) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_8) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_9) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
  end

  assign ports_0_fsm_timer_inc = 1'b1;
  assign ports_0_fsm_timer_DISCONNECTED_EOI = (ports_0_fsm_timer_counter == 24'h005dbf);
  assign ports_0_fsm_timer_RESET_DELAY = (ports_0_fsm_timer_counter == 24'h00095f);
  assign ports_0_fsm_timer_RESET_EOI = (ports_0_fsm_timer_counter == 24'h249eff);
  assign ports_0_fsm_timer_RESUME_EOI = (ports_0_fsm_timer_counter == 24'h0f617f);
  assign ports_0_fsm_timer_RESTART_EOI = (ports_0_fsm_timer_counter == 24'h0012bf);
  assign ports_0_fsm_timer_ONE_BIT = (ports_0_fsm_timer_counter == _zz_ports_0_fsm_timer_ONE_BIT);
  assign ports_0_fsm_timer_TWO_BIT = (ports_0_fsm_timer_counter == _zz_ports_0_fsm_timer_TWO_BIT);
  always @(*) begin
    ports_0_fsm_timer_lowSpeed = ports_0_portLowSpeed;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_0_fsm_lowSpeedEop) begin
          ports_0_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_0_fsm_lowSpeedEop) begin
          ports_0_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_0_disable_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_0_reset_ready = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l680) begin
          io_ctrl_ports_0_reset_ready = 1'b1;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_0_resume_ready = 1'b1;
  assign io_ctrl_ports_0_suspend_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_0_connect = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
        if(ports_0_fsm_timer_DISCONNECTED_EOI) begin
          io_ctrl_ports_0_connect = 1'b1;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_0_tx_enable = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
        io_usb_0_tx_enable = txShared_encoder_output_valid;
        if(when_UsbHubPhy_l693) begin
          io_usb_0_tx_enable = txShared_lowSpeedSof_valid;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_0_tx_data = 1'bx;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
        io_usb_0_tx_data = ((txShared_encoder_output_data || ports_0_fsm_forceJ) ^ ports_0_portLowSpeed);
        if(when_UsbHubPhy_l693) begin
          io_usb_0_tx_data = txShared_lowSpeedSof_data;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
        io_usb_0_tx_data = ports_0_portLowSpeed;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_0_tx_data = (! ports_0_portLowSpeed);
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_0_tx_se0 = 1'bx;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
        io_usb_0_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
        io_usb_0_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
        io_usb_0_tx_se0 = (txShared_encoder_output_se0 && (! ports_0_fsm_forceJ));
        if(when_UsbHubPhy_l693) begin
          io_usb_0_tx_se0 = txShared_lowSpeedSof_se0;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
        io_usb_0_tx_se0 = 1'b0;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_0_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_0_tx_se0 = 1'b0;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ports_0_fsm_resetInProgress = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
        ports_0_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
        ports_0_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
        ports_0_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_0_fsm_forceJ = (ports_0_portLowSpeed && (! txShared_encoder_output_lowSpeed));
  assign when_UsbHubPhy_l772 = (&{(! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED)),{(! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED)),(! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED))}});
  assign io_ctrl_ports_1_lowSpeed = ports_1_portLowSpeed;
  assign io_ctrl_ports_1_remoteResume = 1'b0;
  always @(*) begin
    ports_1_rx_enablePackets = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
        ports_1_rx_enablePackets = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_1_rx_j = ((ports_1_filter_io_filtred_dp == (! ports_1_portLowSpeed)) && (ports_1_filter_io_filtred_dm == ports_1_portLowSpeed));
  assign ports_1_rx_k = ((ports_1_filter_io_filtred_dp == ports_1_portLowSpeed) && (ports_1_filter_io_filtred_dm == (! ports_1_portLowSpeed)));
  assign io_management_1_power = io_ctrl_ports_1_power;
  assign io_ctrl_ports_1_overcurrent = io_management_1_overcurrent;
  always @(*) begin
    ports_1_rx_waitSync = 1'b0;
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : begin
        ports_1_rx_waitSync = 1'b1;
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_10) begin
      ports_1_rx_waitSync = 1'b1;
    end
  end

  always @(*) begin
    ports_1_rx_decoder_output_valid = 1'b0;
    if(ports_1_filter_io_filtred_sample) begin
      ports_1_rx_decoder_output_valid = 1'b1;
    end
  end

  always @(*) begin
    ports_1_rx_decoder_output_payload = 1'bx;
    if(ports_1_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l450_1) begin
        ports_1_rx_decoder_output_payload = 1'b0;
      end else begin
        ports_1_rx_decoder_output_payload = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l450_1 = ((ports_1_rx_decoder_state ^ ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed);
  assign ports_1_rx_destuffer_unstuffNext = (ports_1_rx_destuffer_counter == 3'b110);
  assign ports_1_rx_destuffer_output_valid = (ports_1_rx_decoder_output_valid && (! ports_1_rx_destuffer_unstuffNext));
  assign ports_1_rx_destuffer_output_payload = ports_1_rx_decoder_output_payload;
  assign when_UsbHubPhy_l471_1 = ((! ports_1_rx_decoder_output_payload) || ports_1_rx_destuffer_unstuffNext);
  assign ports_1_rx_history_updated = ports_1_rx_destuffer_output_valid;
  assign _zz_ports_1_rx_history_value = ports_1_rx_destuffer_output_payload;
  assign ports_1_rx_history_value = {_zz_ports_1_rx_history_value,{_zz_ports_1_rx_history_value_1,{_zz_ports_1_rx_history_value_2,{_zz_ports_1_rx_history_value_3,{_zz_ports_1_rx_history_value_4,{_zz_ports_1_rx_history_value_5,{_zz_ports_1_rx_history_value_6,_zz_ports_1_rx_history_value_7}}}}}}};
  assign ports_1_rx_history_sync_hit = (ports_1_rx_history_updated && (ports_1_rx_history_value == 8'hd5));
  assign ports_1_rx_eop_maxThreshold = (io_ctrl_lowSpeed ? 7'h60 : 7'h0c);
  assign ports_1_rx_eop_minThreshold = (io_ctrl_lowSpeed ? 6'h2a : 6'h05);
  assign ports_1_rx_eop_maxHit = (ports_1_rx_eop_counter == ports_1_rx_eop_maxThreshold);
  always @(*) begin
    ports_1_rx_eop_hit = 1'b0;
    if(ports_1_rx_j) begin
      if(when_UsbHubPhy_l506_1) begin
        ports_1_rx_eop_hit = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l498_1 = ((! ports_1_filter_io_filtred_dp) && (! ports_1_filter_io_filtred_dm));
  assign when_UsbHubPhy_l499_1 = (! ports_1_rx_eop_maxHit);
  assign when_UsbHubPhy_l506_1 = ((_zz_when_UsbHubPhy_l506_1 <= ports_1_rx_eop_counter) && (! ports_1_rx_eop_maxHit));
  assign ports_1_rx_packet_wantExit = 1'b0;
  always @(*) begin
    ports_1_rx_packet_wantStart = 1'b0;
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
        ports_1_rx_packet_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_1_rx_packet_wantKill = 1'b0;
  always @(*) begin
    ports_1_rx_packet_errorTimeout_clear = 1'b0;
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : begin
        if(when_UsbHubPhy_l554_1) begin
          ports_1_rx_packet_errorTimeout_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_11) begin
      ports_1_rx_packet_errorTimeout_clear = 1'b1;
    end
  end

  assign ports_1_rx_packet_errorTimeout_inc = 1'b1;
  assign ports_1_rx_packet_errorTimeout_lowSpeed = io_ctrl_lowSpeed;
  assign ports_1_rx_packet_errorTimeout_trigger = (ports_1_rx_packet_errorTimeout_counter == _zz_ports_1_rx_packet_errorTimeout_trigger);
  always @(*) begin
    ports_1_rx_disconnect_clear = 1'b0;
    if(when_UsbHubPhy_l578_1) begin
      ports_1_rx_disconnect_clear = 1'b1;
    end
    if(when_UsbHubPhy_l772_1) begin
      ports_1_rx_disconnect_clear = 1'b1;
    end
  end

  assign ports_1_rx_disconnect_hit = (ports_1_rx_disconnect_counter == 7'h68);
  assign ports_1_rx_disconnect_event = (ports_1_rx_disconnect_hit && (! ports_1_rx_disconnect_hitLast));
  assign when_UsbHubPhy_l578_1 = ((! ports_1_filter_io_filtred_se0) || io_usb_1_tx_enable);
  assign io_ctrl_ports_1_disconnect = ports_1_rx_disconnect_event;
  assign ports_1_fsm_wantExit = 1'b0;
  always @(*) begin
    ports_1_fsm_wantStart = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
        ports_1_fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_1_fsm_wantKill = 1'b0;
  always @(*) begin
    ports_1_fsm_timer_clear = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
        if(when_UsbHubPhy_l643_1) begin
          ports_1_fsm_timer_clear = 1'b1;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_12) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_13) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_14) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_15) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_16) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_17) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_18) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_19) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
  end

  assign ports_1_fsm_timer_inc = 1'b1;
  assign ports_1_fsm_timer_DISCONNECTED_EOI = (ports_1_fsm_timer_counter == 24'h005dbf);
  assign ports_1_fsm_timer_RESET_DELAY = (ports_1_fsm_timer_counter == 24'h00095f);
  assign ports_1_fsm_timer_RESET_EOI = (ports_1_fsm_timer_counter == 24'h249eff);
  assign ports_1_fsm_timer_RESUME_EOI = (ports_1_fsm_timer_counter == 24'h0f617f);
  assign ports_1_fsm_timer_RESTART_EOI = (ports_1_fsm_timer_counter == 24'h0012bf);
  assign ports_1_fsm_timer_ONE_BIT = (ports_1_fsm_timer_counter == _zz_ports_1_fsm_timer_ONE_BIT);
  assign ports_1_fsm_timer_TWO_BIT = (ports_1_fsm_timer_counter == _zz_ports_1_fsm_timer_TWO_BIT);
  always @(*) begin
    ports_1_fsm_timer_lowSpeed = ports_1_portLowSpeed;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_1_fsm_lowSpeedEop) begin
          ports_1_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_1_fsm_lowSpeedEop) begin
          ports_1_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_1_disable_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_1_reset_ready = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l680_1) begin
          io_ctrl_ports_1_reset_ready = 1'b1;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_1_resume_ready = 1'b1;
  assign io_ctrl_ports_1_suspend_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_1_connect = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
        if(ports_1_fsm_timer_DISCONNECTED_EOI) begin
          io_ctrl_ports_1_connect = 1'b1;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_1_tx_enable = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
        io_usb_1_tx_enable = txShared_encoder_output_valid;
        if(when_UsbHubPhy_l693_1) begin
          io_usb_1_tx_enable = txShared_lowSpeedSof_valid;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_1_tx_data = 1'bx;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
        io_usb_1_tx_data = ((txShared_encoder_output_data || ports_1_fsm_forceJ) ^ ports_1_portLowSpeed);
        if(when_UsbHubPhy_l693_1) begin
          io_usb_1_tx_data = txShared_lowSpeedSof_data;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
        io_usb_1_tx_data = ports_1_portLowSpeed;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_1_tx_data = (! ports_1_portLowSpeed);
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_1_tx_se0 = 1'bx;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
        io_usb_1_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
        io_usb_1_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
        io_usb_1_tx_se0 = (txShared_encoder_output_se0 && (! ports_1_fsm_forceJ));
        if(when_UsbHubPhy_l693_1) begin
          io_usb_1_tx_se0 = txShared_lowSpeedSof_se0;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
        io_usb_1_tx_se0 = 1'b0;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_1_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_1_tx_se0 = 1'b0;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ports_1_fsm_resetInProgress = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
        ports_1_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
        ports_1_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
        ports_1_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_1_fsm_forceJ = (ports_1_portLowSpeed && (! txShared_encoder_output_lowSpeed));
  assign when_UsbHubPhy_l772_1 = (&{(! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED)),{(! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED)),(! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED))}});
  assign io_ctrl_ports_2_lowSpeed = ports_2_portLowSpeed;
  assign io_ctrl_ports_2_remoteResume = 1'b0;
  always @(*) begin
    ports_2_rx_enablePackets = 1'b0;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
        ports_2_rx_enablePackets = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_2_rx_j = ((ports_2_filter_io_filtred_dp == (! ports_2_portLowSpeed)) && (ports_2_filter_io_filtred_dm == ports_2_portLowSpeed));
  assign ports_2_rx_k = ((ports_2_filter_io_filtred_dp == ports_2_portLowSpeed) && (ports_2_filter_io_filtred_dm == (! ports_2_portLowSpeed)));
  assign io_management_2_power = io_ctrl_ports_2_power;
  assign io_ctrl_ports_2_overcurrent = io_management_2_overcurrent;
  always @(*) begin
    ports_2_rx_waitSync = 1'b0;
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : begin
        ports_2_rx_waitSync = 1'b1;
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_20) begin
      ports_2_rx_waitSync = 1'b1;
    end
  end

  always @(*) begin
    ports_2_rx_decoder_output_valid = 1'b0;
    if(ports_2_filter_io_filtred_sample) begin
      ports_2_rx_decoder_output_valid = 1'b1;
    end
  end

  always @(*) begin
    ports_2_rx_decoder_output_payload = 1'bx;
    if(ports_2_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l450_2) begin
        ports_2_rx_decoder_output_payload = 1'b0;
      end else begin
        ports_2_rx_decoder_output_payload = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l450_2 = ((ports_2_rx_decoder_state ^ ports_2_filter_io_filtred_d) ^ ports_2_portLowSpeed);
  assign ports_2_rx_destuffer_unstuffNext = (ports_2_rx_destuffer_counter == 3'b110);
  assign ports_2_rx_destuffer_output_valid = (ports_2_rx_decoder_output_valid && (! ports_2_rx_destuffer_unstuffNext));
  assign ports_2_rx_destuffer_output_payload = ports_2_rx_decoder_output_payload;
  assign when_UsbHubPhy_l471_2 = ((! ports_2_rx_decoder_output_payload) || ports_2_rx_destuffer_unstuffNext);
  assign ports_2_rx_history_updated = ports_2_rx_destuffer_output_valid;
  assign _zz_ports_2_rx_history_value = ports_2_rx_destuffer_output_payload;
  assign ports_2_rx_history_value = {_zz_ports_2_rx_history_value,{_zz_ports_2_rx_history_value_1,{_zz_ports_2_rx_history_value_2,{_zz_ports_2_rx_history_value_3,{_zz_ports_2_rx_history_value_4,{_zz_ports_2_rx_history_value_5,{_zz_ports_2_rx_history_value_6,_zz_ports_2_rx_history_value_7}}}}}}};
  assign ports_2_rx_history_sync_hit = (ports_2_rx_history_updated && (ports_2_rx_history_value == 8'hd5));
  assign ports_2_rx_eop_maxThreshold = (io_ctrl_lowSpeed ? 7'h60 : 7'h0c);
  assign ports_2_rx_eop_minThreshold = (io_ctrl_lowSpeed ? 6'h2a : 6'h05);
  assign ports_2_rx_eop_maxHit = (ports_2_rx_eop_counter == ports_2_rx_eop_maxThreshold);
  always @(*) begin
    ports_2_rx_eop_hit = 1'b0;
    if(ports_2_rx_j) begin
      if(when_UsbHubPhy_l506_2) begin
        ports_2_rx_eop_hit = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l498_2 = ((! ports_2_filter_io_filtred_dp) && (! ports_2_filter_io_filtred_dm));
  assign when_UsbHubPhy_l499_2 = (! ports_2_rx_eop_maxHit);
  assign when_UsbHubPhy_l506_2 = ((_zz_when_UsbHubPhy_l506_2 <= ports_2_rx_eop_counter) && (! ports_2_rx_eop_maxHit));
  assign ports_2_rx_packet_wantExit = 1'b0;
  always @(*) begin
    ports_2_rx_packet_wantStart = 1'b0;
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
        ports_2_rx_packet_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_2_rx_packet_wantKill = 1'b0;
  always @(*) begin
    ports_2_rx_packet_errorTimeout_clear = 1'b0;
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : begin
        if(when_UsbHubPhy_l554_2) begin
          ports_2_rx_packet_errorTimeout_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_21) begin
      ports_2_rx_packet_errorTimeout_clear = 1'b1;
    end
  end

  assign ports_2_rx_packet_errorTimeout_inc = 1'b1;
  assign ports_2_rx_packet_errorTimeout_lowSpeed = io_ctrl_lowSpeed;
  assign ports_2_rx_packet_errorTimeout_trigger = (ports_2_rx_packet_errorTimeout_counter == _zz_ports_2_rx_packet_errorTimeout_trigger);
  always @(*) begin
    ports_2_rx_disconnect_clear = 1'b0;
    if(when_UsbHubPhy_l578_2) begin
      ports_2_rx_disconnect_clear = 1'b1;
    end
    if(when_UsbHubPhy_l772_2) begin
      ports_2_rx_disconnect_clear = 1'b1;
    end
  end

  assign ports_2_rx_disconnect_hit = (ports_2_rx_disconnect_counter == 7'h68);
  assign ports_2_rx_disconnect_event = (ports_2_rx_disconnect_hit && (! ports_2_rx_disconnect_hitLast));
  assign when_UsbHubPhy_l578_2 = ((! ports_2_filter_io_filtred_se0) || io_usb_2_tx_enable);
  assign io_ctrl_ports_2_disconnect = ports_2_rx_disconnect_event;
  assign ports_2_fsm_wantExit = 1'b0;
  always @(*) begin
    ports_2_fsm_wantStart = 1'b0;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
        ports_2_fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_2_fsm_wantKill = 1'b0;
  always @(*) begin
    ports_2_fsm_timer_clear = 1'b0;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
        if(when_UsbHubPhy_l643_2) begin
          ports_2_fsm_timer_clear = 1'b1;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_22) begin
      ports_2_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_23) begin
      ports_2_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_24) begin
      ports_2_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_25) begin
      ports_2_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_26) begin
      ports_2_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_27) begin
      ports_2_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_28) begin
      ports_2_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_29) begin
      ports_2_fsm_timer_clear = 1'b1;
    end
  end

  assign ports_2_fsm_timer_inc = 1'b1;
  assign ports_2_fsm_timer_DISCONNECTED_EOI = (ports_2_fsm_timer_counter == 24'h005dbf);
  assign ports_2_fsm_timer_RESET_DELAY = (ports_2_fsm_timer_counter == 24'h00095f);
  assign ports_2_fsm_timer_RESET_EOI = (ports_2_fsm_timer_counter == 24'h249eff);
  assign ports_2_fsm_timer_RESUME_EOI = (ports_2_fsm_timer_counter == 24'h0f617f);
  assign ports_2_fsm_timer_RESTART_EOI = (ports_2_fsm_timer_counter == 24'h0012bf);
  assign ports_2_fsm_timer_ONE_BIT = (ports_2_fsm_timer_counter == _zz_ports_2_fsm_timer_ONE_BIT);
  assign ports_2_fsm_timer_TWO_BIT = (ports_2_fsm_timer_counter == _zz_ports_2_fsm_timer_TWO_BIT);
  always @(*) begin
    ports_2_fsm_timer_lowSpeed = ports_2_portLowSpeed;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_2_fsm_lowSpeedEop) begin
          ports_2_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_2_fsm_lowSpeedEop) begin
          ports_2_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_2_disable_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_2_reset_ready = 1'b0;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l680_2) begin
          io_ctrl_ports_2_reset_ready = 1'b1;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_2_resume_ready = 1'b1;
  assign io_ctrl_ports_2_suspend_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_2_connect = 1'b0;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
        if(ports_2_fsm_timer_DISCONNECTED_EOI) begin
          io_ctrl_ports_2_connect = 1'b1;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_2_tx_enable = 1'b0;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
        io_usb_2_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
        io_usb_2_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
        io_usb_2_tx_enable = txShared_encoder_output_valid;
        if(when_UsbHubPhy_l693_2) begin
          io_usb_2_tx_enable = txShared_lowSpeedSof_valid;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
        io_usb_2_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_2_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_2_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_2_tx_data = 1'bx;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
        io_usb_2_tx_data = ((txShared_encoder_output_data || ports_2_fsm_forceJ) ^ ports_2_portLowSpeed);
        if(when_UsbHubPhy_l693_2) begin
          io_usb_2_tx_data = txShared_lowSpeedSof_data;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
        io_usb_2_tx_data = ports_2_portLowSpeed;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_2_tx_data = (! ports_2_portLowSpeed);
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_2_tx_se0 = 1'bx;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
        io_usb_2_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
        io_usb_2_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
        io_usb_2_tx_se0 = (txShared_encoder_output_se0 && (! ports_2_fsm_forceJ));
        if(when_UsbHubPhy_l693_2) begin
          io_usb_2_tx_se0 = txShared_lowSpeedSof_se0;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
        io_usb_2_tx_se0 = 1'b0;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_2_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_2_tx_se0 = 1'b0;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ports_2_fsm_resetInProgress = 1'b0;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
        ports_2_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
        ports_2_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
        ports_2_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_2_fsm_forceJ = (ports_2_portLowSpeed && (! txShared_encoder_output_lowSpeed));
  assign when_UsbHubPhy_l772_2 = (&{(! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED)),{(! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED)),(! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED))}});
  assign io_ctrl_ports_3_lowSpeed = ports_3_portLowSpeed;
  assign io_ctrl_ports_3_remoteResume = 1'b0;
  always @(*) begin
    ports_3_rx_enablePackets = 1'b0;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
        ports_3_rx_enablePackets = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_3_rx_j = ((ports_3_filter_io_filtred_dp == (! ports_3_portLowSpeed)) && (ports_3_filter_io_filtred_dm == ports_3_portLowSpeed));
  assign ports_3_rx_k = ((ports_3_filter_io_filtred_dp == ports_3_portLowSpeed) && (ports_3_filter_io_filtred_dm == (! ports_3_portLowSpeed)));
  assign io_management_3_power = io_ctrl_ports_3_power;
  assign io_ctrl_ports_3_overcurrent = io_management_3_overcurrent;
  always @(*) begin
    ports_3_rx_waitSync = 1'b0;
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : begin
        ports_3_rx_waitSync = 1'b1;
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_30) begin
      ports_3_rx_waitSync = 1'b1;
    end
  end

  always @(*) begin
    ports_3_rx_decoder_output_valid = 1'b0;
    if(ports_3_filter_io_filtred_sample) begin
      ports_3_rx_decoder_output_valid = 1'b1;
    end
  end

  always @(*) begin
    ports_3_rx_decoder_output_payload = 1'bx;
    if(ports_3_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l450_3) begin
        ports_3_rx_decoder_output_payload = 1'b0;
      end else begin
        ports_3_rx_decoder_output_payload = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l450_3 = ((ports_3_rx_decoder_state ^ ports_3_filter_io_filtred_d) ^ ports_3_portLowSpeed);
  assign ports_3_rx_destuffer_unstuffNext = (ports_3_rx_destuffer_counter == 3'b110);
  assign ports_3_rx_destuffer_output_valid = (ports_3_rx_decoder_output_valid && (! ports_3_rx_destuffer_unstuffNext));
  assign ports_3_rx_destuffer_output_payload = ports_3_rx_decoder_output_payload;
  assign when_UsbHubPhy_l471_3 = ((! ports_3_rx_decoder_output_payload) || ports_3_rx_destuffer_unstuffNext);
  assign ports_3_rx_history_updated = ports_3_rx_destuffer_output_valid;
  assign _zz_ports_3_rx_history_value = ports_3_rx_destuffer_output_payload;
  assign ports_3_rx_history_value = {_zz_ports_3_rx_history_value,{_zz_ports_3_rx_history_value_1,{_zz_ports_3_rx_history_value_2,{_zz_ports_3_rx_history_value_3,{_zz_ports_3_rx_history_value_4,{_zz_ports_3_rx_history_value_5,{_zz_ports_3_rx_history_value_6,_zz_ports_3_rx_history_value_7}}}}}}};
  assign ports_3_rx_history_sync_hit = (ports_3_rx_history_updated && (ports_3_rx_history_value == 8'hd5));
  assign ports_3_rx_eop_maxThreshold = (io_ctrl_lowSpeed ? 7'h60 : 7'h0c);
  assign ports_3_rx_eop_minThreshold = (io_ctrl_lowSpeed ? 6'h2a : 6'h05);
  assign ports_3_rx_eop_maxHit = (ports_3_rx_eop_counter == ports_3_rx_eop_maxThreshold);
  always @(*) begin
    ports_3_rx_eop_hit = 1'b0;
    if(ports_3_rx_j) begin
      if(when_UsbHubPhy_l506_3) begin
        ports_3_rx_eop_hit = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l498_3 = ((! ports_3_filter_io_filtred_dp) && (! ports_3_filter_io_filtred_dm));
  assign when_UsbHubPhy_l499_3 = (! ports_3_rx_eop_maxHit);
  assign when_UsbHubPhy_l506_3 = ((_zz_when_UsbHubPhy_l506_3 <= ports_3_rx_eop_counter) && (! ports_3_rx_eop_maxHit));
  assign ports_3_rx_packet_wantExit = 1'b0;
  always @(*) begin
    ports_3_rx_packet_wantStart = 1'b0;
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
        ports_3_rx_packet_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_3_rx_packet_wantKill = 1'b0;
  always @(*) begin
    ports_3_rx_packet_errorTimeout_clear = 1'b0;
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : begin
        if(when_UsbHubPhy_l554_3) begin
          ports_3_rx_packet_errorTimeout_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_31) begin
      ports_3_rx_packet_errorTimeout_clear = 1'b1;
    end
  end

  assign ports_3_rx_packet_errorTimeout_inc = 1'b1;
  assign ports_3_rx_packet_errorTimeout_lowSpeed = io_ctrl_lowSpeed;
  assign ports_3_rx_packet_errorTimeout_trigger = (ports_3_rx_packet_errorTimeout_counter == _zz_ports_3_rx_packet_errorTimeout_trigger);
  always @(*) begin
    ports_3_rx_disconnect_clear = 1'b0;
    if(when_UsbHubPhy_l578_3) begin
      ports_3_rx_disconnect_clear = 1'b1;
    end
    if(when_UsbHubPhy_l772_3) begin
      ports_3_rx_disconnect_clear = 1'b1;
    end
  end

  assign ports_3_rx_disconnect_hit = (ports_3_rx_disconnect_counter == 7'h68);
  assign ports_3_rx_disconnect_event = (ports_3_rx_disconnect_hit && (! ports_3_rx_disconnect_hitLast));
  assign when_UsbHubPhy_l578_3 = ((! ports_3_filter_io_filtred_se0) || io_usb_3_tx_enable);
  assign io_ctrl_ports_3_disconnect = ports_3_rx_disconnect_event;
  assign ports_3_fsm_wantExit = 1'b0;
  always @(*) begin
    ports_3_fsm_wantStart = 1'b0;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
        ports_3_fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_3_fsm_wantKill = 1'b0;
  always @(*) begin
    ports_3_fsm_timer_clear = 1'b0;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
        if(when_UsbHubPhy_l643_3) begin
          ports_3_fsm_timer_clear = 1'b1;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_32) begin
      ports_3_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_33) begin
      ports_3_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_34) begin
      ports_3_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_35) begin
      ports_3_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_36) begin
      ports_3_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_37) begin
      ports_3_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_38) begin
      ports_3_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l253_39) begin
      ports_3_fsm_timer_clear = 1'b1;
    end
  end

  assign ports_3_fsm_timer_inc = 1'b1;
  assign ports_3_fsm_timer_DISCONNECTED_EOI = (ports_3_fsm_timer_counter == 24'h005dbf);
  assign ports_3_fsm_timer_RESET_DELAY = (ports_3_fsm_timer_counter == 24'h00095f);
  assign ports_3_fsm_timer_RESET_EOI = (ports_3_fsm_timer_counter == 24'h249eff);
  assign ports_3_fsm_timer_RESUME_EOI = (ports_3_fsm_timer_counter == 24'h0f617f);
  assign ports_3_fsm_timer_RESTART_EOI = (ports_3_fsm_timer_counter == 24'h0012bf);
  assign ports_3_fsm_timer_ONE_BIT = (ports_3_fsm_timer_counter == _zz_ports_3_fsm_timer_ONE_BIT);
  assign ports_3_fsm_timer_TWO_BIT = (ports_3_fsm_timer_counter == _zz_ports_3_fsm_timer_TWO_BIT);
  always @(*) begin
    ports_3_fsm_timer_lowSpeed = ports_3_portLowSpeed;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_3_fsm_lowSpeedEop) begin
          ports_3_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_3_fsm_lowSpeedEop) begin
          ports_3_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_3_disable_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_3_reset_ready = 1'b0;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l680_3) begin
          io_ctrl_ports_3_reset_ready = 1'b1;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_3_resume_ready = 1'b1;
  assign io_ctrl_ports_3_suspend_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_3_connect = 1'b0;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
        if(ports_3_fsm_timer_DISCONNECTED_EOI) begin
          io_ctrl_ports_3_connect = 1'b1;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_3_tx_enable = 1'b0;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
        io_usb_3_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
        io_usb_3_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
        io_usb_3_tx_enable = txShared_encoder_output_valid;
        if(when_UsbHubPhy_l693_3) begin
          io_usb_3_tx_enable = txShared_lowSpeedSof_valid;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
        io_usb_3_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_3_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_3_tx_enable = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_3_tx_data = 1'bx;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
        io_usb_3_tx_data = ((txShared_encoder_output_data || ports_3_fsm_forceJ) ^ ports_3_portLowSpeed);
        if(when_UsbHubPhy_l693_3) begin
          io_usb_3_tx_data = txShared_lowSpeedSof_data;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
        io_usb_3_tx_data = ports_3_portLowSpeed;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_3_tx_data = (! ports_3_portLowSpeed);
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_3_tx_se0 = 1'bx;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
        io_usb_3_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
        io_usb_3_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
        io_usb_3_tx_se0 = (txShared_encoder_output_se0 && (! ports_3_fsm_forceJ));
        if(when_UsbHubPhy_l693_3) begin
          io_usb_3_tx_se0 = txShared_lowSpeedSof_se0;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
        io_usb_3_tx_se0 = 1'b0;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_3_tx_se0 = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_3_tx_se0 = 1'b0;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ports_3_fsm_resetInProgress = 1'b0;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
        ports_3_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
        ports_3_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
        ports_3_fsm_resetInProgress = 1'b1;
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_3_fsm_forceJ = (ports_3_portLowSpeed && (! txShared_encoder_output_lowSpeed));
  assign when_UsbHubPhy_l772_3 = (&{(! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED)),{(! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED)),(! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED))}});
  always @(*) begin
    txShared_frame_stateNext = txShared_frame_stateReg;
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
        if(when_UsbHubPhy_l294) begin
          txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
        if(txShared_timer_oneCycle) begin
          if(io_ctrl_lowSpeed) begin
            txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC;
          end else begin
            txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_SYNC;
          end
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
        if(txShared_serialiser_input_ready) begin
          txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
        if(txShared_serialiser_input_ready) begin
          txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        if(txShared_timer_fourCycle) begin
          txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_SYNC;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
        if(txShared_serialiser_input_ready) begin
          txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_DATA;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
        if(txShared_serialiser_input_ready) begin
          if(io_ctrl_tx_payload_last) begin
            txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_EOP_0;
          end
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
        if(txShared_timer_twoCycle) begin
          txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_EOP_1;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
        if(txShared_timer_oneCycle) begin
          txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_EOP_2;
        end
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
        if(txShared_timer_twoCycle) begin
          txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(txShared_frame_wantStart) begin
      txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_IDLE;
    end
    if(txShared_frame_wantKill) begin
      txShared_frame_stateNext = UsbOhciAxi4_txShared_frame_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l294 = (io_ctrl_tx_valid && (! txShared_rxToTxDelay_active));
  always @(*) begin
    upstreamRx_stateNext = upstreamRx_stateReg;
    case(upstreamRx_stateReg)
      UsbOhciAxi4_upstreamRx_enumDef_IDLE : begin
        if(upstreamRx_timer_IDLE_EOI) begin
          upstreamRx_stateNext = UsbOhciAxi4_upstreamRx_enumDef_SUSPEND;
        end
      end
      UsbOhciAxi4_upstreamRx_enumDef_SUSPEND : begin
        if(txShared_encoder_output_valid) begin
          upstreamRx_stateNext = UsbOhciAxi4_upstreamRx_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(upstreamRx_wantStart) begin
      upstreamRx_stateNext = UsbOhciAxi4_upstreamRx_enumDef_IDLE;
    end
    if(upstreamRx_wantKill) begin
      upstreamRx_stateNext = UsbOhciAxi4_upstreamRx_enumDef_BOOT;
    end
  end

  assign Rx_Suspend = (upstreamRx_stateReg == UsbOhciAxi4_upstreamRx_enumDef_SUSPEND);
  always @(*) begin
    ports_0_rx_packet_stateNext = ports_0_rx_packet_stateReg;
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : begin
        if(ports_0_rx_history_sync_hit) begin
          ports_0_rx_packet_stateNext = UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET;
        end
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : begin
        if(ports_0_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l532) begin
            if(ports_0_rx_stuffingError) begin
              ports_0_rx_packet_stateNext = UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED;
            end
          end
        end
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : begin
        if(ports_0_rx_packet_errorTimeout_trigger) begin
          ports_0_rx_packet_stateNext = UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(ports_0_rx_eop_hit) begin
      ports_0_rx_packet_stateNext = UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE;
    end
    if(txShared_encoder_output_valid) begin
      ports_0_rx_packet_stateNext = UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE;
    end
    if(ports_0_rx_packet_wantStart) begin
      ports_0_rx_packet_stateNext = UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE;
    end
    if(ports_0_rx_packet_wantKill) begin
      ports_0_rx_packet_stateNext = UsbOhciAxi4_ports_0_rx_packet_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l532 = (ports_0_rx_packet_counter == 3'b111);
  assign when_UsbHubPhy_l554 = ((ports_0_rx_packet_errorTimeout_p != ports_0_filter_io_filtred_dp) || (ports_0_rx_packet_errorTimeout_n != ports_0_filter_io_filtred_dm));
  assign when_StateMachine_l253 = ((! (ports_0_rx_packet_stateReg == UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE)) && (ports_0_rx_packet_stateNext == UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE));
  assign when_StateMachine_l253_1 = ((! (ports_0_rx_packet_stateReg == UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED)) && (ports_0_rx_packet_stateNext == UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED));
  always @(*) begin
    ports_0_fsm_stateNext = ports_0_fsm_stateReg;
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
        if(io_ctrl_ports_0_power) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
        if(ports_0_fsm_timer_DISCONNECTED_EOI) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
        if(ports_0_fsm_timer_RESET_EOI) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
        if(ports_0_fsm_timer_RESET_DELAY) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l680) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
        if(io_ctrl_ports_0_suspend_valid) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED;
        end else begin
          if(when_UsbHubPhy_l702) begin
            ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E;
          end else begin
            if(io_ctrl_usbResume) begin
              ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING;
            end
          end
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
        if(when_UsbHubPhy_l710) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING;
        end else begin
          if(when_UsbHubPhy_l712) begin
            ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S;
          end
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
        if(ports_0_fsm_timer_RESUME_EOI) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_0_fsm_timer_TWO_BIT) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_0_fsm_timer_ONE_BIT) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l753) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING;
        end
        if(ports_0_fsm_timer_RESTART_EOI) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l763) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING;
        end
        if(ports_0_fsm_timer_RESTART_EOI) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED;
        end
      end
      default : begin
      end
    endcase
    if(when_UsbHubPhy_l615) begin
      ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF;
    end else begin
      if(ports_0_rx_disconnect_event) begin
        ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED;
      end else begin
        if(io_ctrl_ports_0_disable_valid) begin
          ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED;
        end else begin
          if(io_ctrl_ports_0_reset_valid) begin
            if(when_UsbHubPhy_l622) begin
              if(when_UsbHubPhy_l623) begin
                ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING;
              end
            end
          end
        end
      end
    end
    if(ports_0_fsm_wantStart) begin
      ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF;
    end
    if(ports_0_fsm_wantKill) begin
      ports_0_fsm_stateNext = UsbOhciAxi4_ports_0_fsm_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l643 = ((! ports_0_filter_io_filtred_dp) && (! ports_0_filter_io_filtred_dm));
  assign when_UsbHubPhy_l680 = (! txShared_encoder_output_valid);
  assign when_UsbHubPhy_l693 = (ports_0_portLowSpeed && txShared_lowSpeedSof_overrideEncoder);
  assign when_UsbHubPhy_l702 = (Rx_Suspend && (ports_0_filter_io_filtred_se0 || ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed))));
  assign when_UsbHubPhy_l710 = (io_ctrl_ports_0_resume_valid || ((! Rx_Suspend) && ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed))));
  assign when_UsbHubPhy_l712 = (Rx_Suspend && (ports_0_filter_io_filtred_se0 || ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed))));
  assign when_UsbHubPhy_l753 = ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed));
  assign when_UsbHubPhy_l763 = ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed));
  assign when_StateMachine_l253_2 = ((! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED)) && (ports_0_fsm_stateNext == UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED));
  assign when_StateMachine_l253_3 = ((! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING)) && (ports_0_fsm_stateNext == UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING));
  assign when_StateMachine_l253_4 = ((! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY)) && (ports_0_fsm_stateNext == UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY));
  assign when_StateMachine_l253_5 = ((! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING)) && (ports_0_fsm_stateNext == UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING));
  assign when_StateMachine_l253_6 = ((! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0)) && (ports_0_fsm_stateNext == UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0));
  assign when_StateMachine_l253_7 = ((! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1)) && (ports_0_fsm_stateNext == UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1));
  assign when_StateMachine_l253_8 = ((! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S)) && (ports_0_fsm_stateNext == UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S));
  assign when_StateMachine_l253_9 = ((! (ports_0_fsm_stateReg == UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E)) && (ports_0_fsm_stateNext == UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E));
  assign when_UsbHubPhy_l615 = ((! io_ctrl_ports_0_power) || io_ctrl_usbReset);
  assign when_UsbHubPhy_l622 = (! ports_0_fsm_resetInProgress);
  assign when_UsbHubPhy_l623 = (ports_0_filter_io_filtred_dm != ports_0_filter_io_filtred_dp);
  always @(*) begin
    ports_1_rx_packet_stateNext = ports_1_rx_packet_stateReg;
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : begin
        if(ports_1_rx_history_sync_hit) begin
          ports_1_rx_packet_stateNext = UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET;
        end
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : begin
        if(ports_1_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l532_1) begin
            if(ports_1_rx_stuffingError) begin
              ports_1_rx_packet_stateNext = UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED;
            end
          end
        end
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : begin
        if(ports_1_rx_packet_errorTimeout_trigger) begin
          ports_1_rx_packet_stateNext = UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(ports_1_rx_eop_hit) begin
      ports_1_rx_packet_stateNext = UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE;
    end
    if(txShared_encoder_output_valid) begin
      ports_1_rx_packet_stateNext = UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE;
    end
    if(ports_1_rx_packet_wantStart) begin
      ports_1_rx_packet_stateNext = UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE;
    end
    if(ports_1_rx_packet_wantKill) begin
      ports_1_rx_packet_stateNext = UsbOhciAxi4_ports_1_rx_packet_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l532_1 = (ports_1_rx_packet_counter == 3'b111);
  assign when_UsbHubPhy_l554_1 = ((ports_1_rx_packet_errorTimeout_p != ports_1_filter_io_filtred_dp) || (ports_1_rx_packet_errorTimeout_n != ports_1_filter_io_filtred_dm));
  assign when_StateMachine_l253_10 = ((! (ports_1_rx_packet_stateReg == UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE)) && (ports_1_rx_packet_stateNext == UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE));
  assign when_StateMachine_l253_11 = ((! (ports_1_rx_packet_stateReg == UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED)) && (ports_1_rx_packet_stateNext == UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED));
  always @(*) begin
    ports_1_fsm_stateNext = ports_1_fsm_stateReg;
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
        if(io_ctrl_ports_1_power) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
        if(ports_1_fsm_timer_DISCONNECTED_EOI) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
        if(ports_1_fsm_timer_RESET_EOI) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
        if(ports_1_fsm_timer_RESET_DELAY) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l680_1) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
        if(io_ctrl_ports_1_suspend_valid) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED;
        end else begin
          if(when_UsbHubPhy_l702_1) begin
            ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E;
          end else begin
            if(io_ctrl_usbResume) begin
              ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING;
            end
          end
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
        if(when_UsbHubPhy_l710_1) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING;
        end else begin
          if(when_UsbHubPhy_l712_1) begin
            ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S;
          end
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
        if(ports_1_fsm_timer_RESUME_EOI) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_1_fsm_timer_TWO_BIT) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_1_fsm_timer_ONE_BIT) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l753_1) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING;
        end
        if(ports_1_fsm_timer_RESTART_EOI) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l763_1) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING;
        end
        if(ports_1_fsm_timer_RESTART_EOI) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED;
        end
      end
      default : begin
      end
    endcase
    if(when_UsbHubPhy_l615_1) begin
      ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF;
    end else begin
      if(ports_1_rx_disconnect_event) begin
        ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED;
      end else begin
        if(io_ctrl_ports_1_disable_valid) begin
          ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED;
        end else begin
          if(io_ctrl_ports_1_reset_valid) begin
            if(when_UsbHubPhy_l622_1) begin
              if(when_UsbHubPhy_l623_1) begin
                ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING;
              end
            end
          end
        end
      end
    end
    if(ports_1_fsm_wantStart) begin
      ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF;
    end
    if(ports_1_fsm_wantKill) begin
      ports_1_fsm_stateNext = UsbOhciAxi4_ports_1_fsm_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l643_1 = ((! ports_1_filter_io_filtred_dp) && (! ports_1_filter_io_filtred_dm));
  assign when_UsbHubPhy_l680_1 = (! txShared_encoder_output_valid);
  assign when_UsbHubPhy_l693_1 = (ports_1_portLowSpeed && txShared_lowSpeedSof_overrideEncoder);
  assign when_UsbHubPhy_l702_1 = (Rx_Suspend && (ports_1_filter_io_filtred_se0 || ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed))));
  assign when_UsbHubPhy_l710_1 = (io_ctrl_ports_1_resume_valid || ((! Rx_Suspend) && ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed))));
  assign when_UsbHubPhy_l712_1 = (Rx_Suspend && (ports_1_filter_io_filtred_se0 || ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed))));
  assign when_UsbHubPhy_l753_1 = ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed));
  assign when_UsbHubPhy_l763_1 = ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed));
  assign when_StateMachine_l253_12 = ((! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED)) && (ports_1_fsm_stateNext == UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED));
  assign when_StateMachine_l253_13 = ((! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING)) && (ports_1_fsm_stateNext == UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING));
  assign when_StateMachine_l253_14 = ((! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY)) && (ports_1_fsm_stateNext == UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY));
  assign when_StateMachine_l253_15 = ((! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING)) && (ports_1_fsm_stateNext == UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING));
  assign when_StateMachine_l253_16 = ((! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0)) && (ports_1_fsm_stateNext == UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0));
  assign when_StateMachine_l253_17 = ((! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1)) && (ports_1_fsm_stateNext == UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1));
  assign when_StateMachine_l253_18 = ((! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S)) && (ports_1_fsm_stateNext == UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S));
  assign when_StateMachine_l253_19 = ((! (ports_1_fsm_stateReg == UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E)) && (ports_1_fsm_stateNext == UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E));
  assign when_UsbHubPhy_l615_1 = ((! io_ctrl_ports_1_power) || io_ctrl_usbReset);
  assign when_UsbHubPhy_l622_1 = (! ports_1_fsm_resetInProgress);
  assign when_UsbHubPhy_l623_1 = (ports_1_filter_io_filtred_dm != ports_1_filter_io_filtred_dp);
  always @(*) begin
    ports_2_rx_packet_stateNext = ports_2_rx_packet_stateReg;
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : begin
        if(ports_2_rx_history_sync_hit) begin
          ports_2_rx_packet_stateNext = UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET;
        end
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : begin
        if(ports_2_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l532_2) begin
            if(ports_2_rx_stuffingError) begin
              ports_2_rx_packet_stateNext = UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED;
            end
          end
        end
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : begin
        if(ports_2_rx_packet_errorTimeout_trigger) begin
          ports_2_rx_packet_stateNext = UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(ports_2_rx_eop_hit) begin
      ports_2_rx_packet_stateNext = UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE;
    end
    if(txShared_encoder_output_valid) begin
      ports_2_rx_packet_stateNext = UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE;
    end
    if(ports_2_rx_packet_wantStart) begin
      ports_2_rx_packet_stateNext = UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE;
    end
    if(ports_2_rx_packet_wantKill) begin
      ports_2_rx_packet_stateNext = UsbOhciAxi4_ports_2_rx_packet_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l532_2 = (ports_2_rx_packet_counter == 3'b111);
  assign when_UsbHubPhy_l554_2 = ((ports_2_rx_packet_errorTimeout_p != ports_2_filter_io_filtred_dp) || (ports_2_rx_packet_errorTimeout_n != ports_2_filter_io_filtred_dm));
  assign when_StateMachine_l253_20 = ((! (ports_2_rx_packet_stateReg == UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE)) && (ports_2_rx_packet_stateNext == UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE));
  assign when_StateMachine_l253_21 = ((! (ports_2_rx_packet_stateReg == UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED)) && (ports_2_rx_packet_stateNext == UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED));
  always @(*) begin
    ports_2_fsm_stateNext = ports_2_fsm_stateReg;
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
        if(io_ctrl_ports_2_power) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
        if(ports_2_fsm_timer_DISCONNECTED_EOI) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
        if(ports_2_fsm_timer_RESET_EOI) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
        if(ports_2_fsm_timer_RESET_DELAY) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l680_2) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
        if(io_ctrl_ports_2_suspend_valid) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED;
        end else begin
          if(when_UsbHubPhy_l702_2) begin
            ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E;
          end else begin
            if(io_ctrl_usbResume) begin
              ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING;
            end
          end
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
        if(when_UsbHubPhy_l710_2) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING;
        end else begin
          if(when_UsbHubPhy_l712_2) begin
            ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S;
          end
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
        if(ports_2_fsm_timer_RESUME_EOI) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_2_fsm_timer_TWO_BIT) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_2_fsm_timer_ONE_BIT) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l753_2) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING;
        end
        if(ports_2_fsm_timer_RESTART_EOI) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l763_2) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING;
        end
        if(ports_2_fsm_timer_RESTART_EOI) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED;
        end
      end
      default : begin
      end
    endcase
    if(when_UsbHubPhy_l615_2) begin
      ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF;
    end else begin
      if(ports_2_rx_disconnect_event) begin
        ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED;
      end else begin
        if(io_ctrl_ports_2_disable_valid) begin
          ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED;
        end else begin
          if(io_ctrl_ports_2_reset_valid) begin
            if(when_UsbHubPhy_l622_2) begin
              if(when_UsbHubPhy_l623_2) begin
                ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING;
              end
            end
          end
        end
      end
    end
    if(ports_2_fsm_wantStart) begin
      ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF;
    end
    if(ports_2_fsm_wantKill) begin
      ports_2_fsm_stateNext = UsbOhciAxi4_ports_2_fsm_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l643_2 = ((! ports_2_filter_io_filtred_dp) && (! ports_2_filter_io_filtred_dm));
  assign when_UsbHubPhy_l680_2 = (! txShared_encoder_output_valid);
  assign when_UsbHubPhy_l693_2 = (ports_2_portLowSpeed && txShared_lowSpeedSof_overrideEncoder);
  assign when_UsbHubPhy_l702_2 = (Rx_Suspend && (ports_2_filter_io_filtred_se0 || ((! ports_2_filter_io_filtred_se0) && ((! ports_2_filter_io_filtred_d) ^ ports_2_portLowSpeed))));
  assign when_UsbHubPhy_l710_2 = (io_ctrl_ports_2_resume_valid || ((! Rx_Suspend) && ((! ports_2_filter_io_filtred_se0) && ((! ports_2_filter_io_filtred_d) ^ ports_2_portLowSpeed))));
  assign when_UsbHubPhy_l712_2 = (Rx_Suspend && (ports_2_filter_io_filtred_se0 || ((! ports_2_filter_io_filtred_se0) && ((! ports_2_filter_io_filtred_d) ^ ports_2_portLowSpeed))));
  assign when_UsbHubPhy_l753_2 = ((! ports_2_filter_io_filtred_se0) && ((! ports_2_filter_io_filtred_d) ^ ports_2_portLowSpeed));
  assign when_UsbHubPhy_l763_2 = ((! ports_2_filter_io_filtred_se0) && ((! ports_2_filter_io_filtred_d) ^ ports_2_portLowSpeed));
  assign when_StateMachine_l253_22 = ((! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED)) && (ports_2_fsm_stateNext == UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED));
  assign when_StateMachine_l253_23 = ((! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING)) && (ports_2_fsm_stateNext == UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING));
  assign when_StateMachine_l253_24 = ((! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY)) && (ports_2_fsm_stateNext == UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY));
  assign when_StateMachine_l253_25 = ((! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING)) && (ports_2_fsm_stateNext == UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING));
  assign when_StateMachine_l253_26 = ((! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0)) && (ports_2_fsm_stateNext == UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0));
  assign when_StateMachine_l253_27 = ((! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1)) && (ports_2_fsm_stateNext == UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1));
  assign when_StateMachine_l253_28 = ((! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S)) && (ports_2_fsm_stateNext == UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S));
  assign when_StateMachine_l253_29 = ((! (ports_2_fsm_stateReg == UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E)) && (ports_2_fsm_stateNext == UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E));
  assign when_UsbHubPhy_l615_2 = ((! io_ctrl_ports_2_power) || io_ctrl_usbReset);
  assign when_UsbHubPhy_l622_2 = (! ports_2_fsm_resetInProgress);
  assign when_UsbHubPhy_l623_2 = (ports_2_filter_io_filtred_dm != ports_2_filter_io_filtred_dp);
  always @(*) begin
    ports_3_rx_packet_stateNext = ports_3_rx_packet_stateReg;
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : begin
        if(ports_3_rx_history_sync_hit) begin
          ports_3_rx_packet_stateNext = UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET;
        end
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : begin
        if(ports_3_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l532_3) begin
            if(ports_3_rx_stuffingError) begin
              ports_3_rx_packet_stateNext = UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED;
            end
          end
        end
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : begin
        if(ports_3_rx_packet_errorTimeout_trigger) begin
          ports_3_rx_packet_stateNext = UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(ports_3_rx_eop_hit) begin
      ports_3_rx_packet_stateNext = UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE;
    end
    if(txShared_encoder_output_valid) begin
      ports_3_rx_packet_stateNext = UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE;
    end
    if(ports_3_rx_packet_wantStart) begin
      ports_3_rx_packet_stateNext = UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE;
    end
    if(ports_3_rx_packet_wantKill) begin
      ports_3_rx_packet_stateNext = UsbOhciAxi4_ports_3_rx_packet_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l532_3 = (ports_3_rx_packet_counter == 3'b111);
  assign when_UsbHubPhy_l554_3 = ((ports_3_rx_packet_errorTimeout_p != ports_3_filter_io_filtred_dp) || (ports_3_rx_packet_errorTimeout_n != ports_3_filter_io_filtred_dm));
  assign when_StateMachine_l253_30 = ((! (ports_3_rx_packet_stateReg == UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE)) && (ports_3_rx_packet_stateNext == UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE));
  assign when_StateMachine_l253_31 = ((! (ports_3_rx_packet_stateReg == UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED)) && (ports_3_rx_packet_stateNext == UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED));
  always @(*) begin
    ports_3_fsm_stateNext = ports_3_fsm_stateReg;
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
        if(io_ctrl_ports_3_power) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
        if(ports_3_fsm_timer_DISCONNECTED_EOI) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
        if(ports_3_fsm_timer_RESET_EOI) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
        if(ports_3_fsm_timer_RESET_DELAY) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l680_3) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
        if(io_ctrl_ports_3_suspend_valid) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED;
        end else begin
          if(when_UsbHubPhy_l702_3) begin
            ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E;
          end else begin
            if(io_ctrl_usbResume) begin
              ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING;
            end
          end
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
        if(when_UsbHubPhy_l710_3) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING;
        end else begin
          if(when_UsbHubPhy_l712_3) begin
            ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S;
          end
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
        if(ports_3_fsm_timer_RESUME_EOI) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_3_fsm_timer_TWO_BIT) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_3_fsm_timer_ONE_BIT) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l753_3) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING;
        end
        if(ports_3_fsm_timer_RESTART_EOI) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l763_3) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING;
        end
        if(ports_3_fsm_timer_RESTART_EOI) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED;
        end
      end
      default : begin
      end
    endcase
    if(when_UsbHubPhy_l615_3) begin
      ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF;
    end else begin
      if(ports_3_rx_disconnect_event) begin
        ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED;
      end else begin
        if(io_ctrl_ports_3_disable_valid) begin
          ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED;
        end else begin
          if(io_ctrl_ports_3_reset_valid) begin
            if(when_UsbHubPhy_l622_3) begin
              if(when_UsbHubPhy_l623_3) begin
                ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING;
              end
            end
          end
        end
      end
    end
    if(ports_3_fsm_wantStart) begin
      ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF;
    end
    if(ports_3_fsm_wantKill) begin
      ports_3_fsm_stateNext = UsbOhciAxi4_ports_3_fsm_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l643_3 = ((! ports_3_filter_io_filtred_dp) && (! ports_3_filter_io_filtred_dm));
  assign when_UsbHubPhy_l680_3 = (! txShared_encoder_output_valid);
  assign when_UsbHubPhy_l693_3 = (ports_3_portLowSpeed && txShared_lowSpeedSof_overrideEncoder);
  assign when_UsbHubPhy_l702_3 = (Rx_Suspend && (ports_3_filter_io_filtred_se0 || ((! ports_3_filter_io_filtred_se0) && ((! ports_3_filter_io_filtred_d) ^ ports_3_portLowSpeed))));
  assign when_UsbHubPhy_l710_3 = (io_ctrl_ports_3_resume_valid || ((! Rx_Suspend) && ((! ports_3_filter_io_filtred_se0) && ((! ports_3_filter_io_filtred_d) ^ ports_3_portLowSpeed))));
  assign when_UsbHubPhy_l712_3 = (Rx_Suspend && (ports_3_filter_io_filtred_se0 || ((! ports_3_filter_io_filtred_se0) && ((! ports_3_filter_io_filtred_d) ^ ports_3_portLowSpeed))));
  assign when_UsbHubPhy_l753_3 = ((! ports_3_filter_io_filtred_se0) && ((! ports_3_filter_io_filtred_d) ^ ports_3_portLowSpeed));
  assign when_UsbHubPhy_l763_3 = ((! ports_3_filter_io_filtred_se0) && ((! ports_3_filter_io_filtred_d) ^ ports_3_portLowSpeed));
  assign when_StateMachine_l253_32 = ((! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED)) && (ports_3_fsm_stateNext == UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED));
  assign when_StateMachine_l253_33 = ((! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING)) && (ports_3_fsm_stateNext == UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING));
  assign when_StateMachine_l253_34 = ((! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY)) && (ports_3_fsm_stateNext == UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY));
  assign when_StateMachine_l253_35 = ((! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING)) && (ports_3_fsm_stateNext == UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING));
  assign when_StateMachine_l253_36 = ((! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0)) && (ports_3_fsm_stateNext == UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0));
  assign when_StateMachine_l253_37 = ((! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1)) && (ports_3_fsm_stateNext == UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1));
  assign when_StateMachine_l253_38 = ((! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S)) && (ports_3_fsm_stateNext == UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S));
  assign when_StateMachine_l253_39 = ((! (ports_3_fsm_stateReg == UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E)) && (ports_3_fsm_stateNext == UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E));
  assign when_UsbHubPhy_l615_3 = ((! io_ctrl_ports_3_power) || io_ctrl_usbReset);
  assign when_UsbHubPhy_l622_3 = (! ports_3_fsm_resetInProgress);
  assign when_UsbHubPhy_l623_3 = (ports_3_filter_io_filtred_dm != ports_3_filter_io_filtred_dp);
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      tickTimer_counter_value <= 2'b00;
      txShared_rxToTxDelay_active <= 1'b0;
      txShared_lowSpeedSof_state <= 2'b00;
      txShared_lowSpeedSof_overrideEncoder <= 1'b0;
      ports_0_rx_eop_counter <= 7'h00;
      ports_0_rx_disconnect_counter <= 7'h00;
      ports_1_rx_eop_counter <= 7'h00;
      ports_1_rx_disconnect_counter <= 7'h00;
      ports_2_rx_eop_counter <= 7'h00;
      ports_2_rx_disconnect_counter <= 7'h00;
      ports_3_rx_eop_counter <= 7'h00;
      ports_3_rx_disconnect_counter <= 7'h00;
      txShared_frame_stateReg <= UsbOhciAxi4_txShared_frame_enumDef_BOOT;
      upstreamRx_stateReg <= UsbOhciAxi4_upstreamRx_enumDef_BOOT;
      ports_0_rx_packet_stateReg <= UsbOhciAxi4_ports_0_rx_packet_enumDef_BOOT;
      ports_0_fsm_stateReg <= UsbOhciAxi4_ports_0_fsm_enumDef_BOOT;
      ports_1_rx_packet_stateReg <= UsbOhciAxi4_ports_1_rx_packet_enumDef_BOOT;
      ports_1_fsm_stateReg <= UsbOhciAxi4_ports_1_fsm_enumDef_BOOT;
      ports_2_rx_packet_stateReg <= UsbOhciAxi4_ports_2_rx_packet_enumDef_BOOT;
      ports_2_fsm_stateReg <= UsbOhciAxi4_ports_2_fsm_enumDef_BOOT;
      ports_3_rx_packet_stateReg <= UsbOhciAxi4_ports_3_rx_packet_enumDef_BOOT;
      ports_3_fsm_stateReg <= UsbOhciAxi4_ports_3_fsm_enumDef_BOOT;
    end else begin
      tickTimer_counter_value <= tickTimer_counter_valueNext;
      if(txShared_rxToTxDelay_twoCycle) begin
        txShared_rxToTxDelay_active <= 1'b0;
      end
      if(when_UsbHubPhy_l254) begin
        txShared_lowSpeedSof_overrideEncoder <= 1'b0;
      end
      txShared_lowSpeedSof_state <= (txShared_lowSpeedSof_state + _zz_txShared_lowSpeedSof_state);
      if(when_UsbHubPhy_l256) begin
        if(when_UsbHubPhy_l257) begin
          txShared_lowSpeedSof_overrideEncoder <= 1'b1;
        end
      end else begin
        if(when_UsbHubPhy_l264) begin
          txShared_lowSpeedSof_state <= (txShared_lowSpeedSof_state + 2'b01);
        end
      end
      if(when_UsbHubPhy_l498) begin
        if(when_UsbHubPhy_l499) begin
          ports_0_rx_eop_counter <= (ports_0_rx_eop_counter + 7'h01);
        end
      end else begin
        ports_0_rx_eop_counter <= 7'h00;
      end
      ports_0_rx_disconnect_counter <= (ports_0_rx_disconnect_counter + _zz_ports_0_rx_disconnect_counter);
      if(ports_0_rx_disconnect_clear) begin
        ports_0_rx_disconnect_counter <= 7'h00;
      end
      if(when_UsbHubPhy_l498_1) begin
        if(when_UsbHubPhy_l499_1) begin
          ports_1_rx_eop_counter <= (ports_1_rx_eop_counter + 7'h01);
        end
      end else begin
        ports_1_rx_eop_counter <= 7'h00;
      end
      ports_1_rx_disconnect_counter <= (ports_1_rx_disconnect_counter + _zz_ports_1_rx_disconnect_counter);
      if(ports_1_rx_disconnect_clear) begin
        ports_1_rx_disconnect_counter <= 7'h00;
      end
      if(when_UsbHubPhy_l498_2) begin
        if(when_UsbHubPhy_l499_2) begin
          ports_2_rx_eop_counter <= (ports_2_rx_eop_counter + 7'h01);
        end
      end else begin
        ports_2_rx_eop_counter <= 7'h00;
      end
      ports_2_rx_disconnect_counter <= (ports_2_rx_disconnect_counter + _zz_ports_2_rx_disconnect_counter);
      if(ports_2_rx_disconnect_clear) begin
        ports_2_rx_disconnect_counter <= 7'h00;
      end
      if(when_UsbHubPhy_l498_3) begin
        if(when_UsbHubPhy_l499_3) begin
          ports_3_rx_eop_counter <= (ports_3_rx_eop_counter + 7'h01);
        end
      end else begin
        ports_3_rx_eop_counter <= 7'h00;
      end
      ports_3_rx_disconnect_counter <= (ports_3_rx_disconnect_counter + _zz_ports_3_rx_disconnect_counter);
      if(ports_3_rx_disconnect_clear) begin
        ports_3_rx_disconnect_counter <= 7'h00;
      end
      txShared_frame_stateReg <= txShared_frame_stateNext;
      upstreamRx_stateReg <= upstreamRx_stateNext;
      ports_0_rx_packet_stateReg <= ports_0_rx_packet_stateNext;
      if(ports_0_rx_eop_hit) begin
        txShared_rxToTxDelay_active <= 1'b1;
      end
      ports_0_fsm_stateReg <= ports_0_fsm_stateNext;
      ports_1_rx_packet_stateReg <= ports_1_rx_packet_stateNext;
      if(ports_1_rx_eop_hit) begin
        txShared_rxToTxDelay_active <= 1'b1;
      end
      ports_1_fsm_stateReg <= ports_1_fsm_stateNext;
      ports_2_rx_packet_stateReg <= ports_2_rx_packet_stateNext;
      if(ports_2_rx_eop_hit) begin
        txShared_rxToTxDelay_active <= 1'b1;
      end
      ports_2_fsm_stateReg <= ports_2_fsm_stateNext;
      ports_3_rx_packet_stateReg <= ports_3_rx_packet_stateNext;
      if(ports_3_rx_eop_hit) begin
        txShared_rxToTxDelay_active <= 1'b1;
      end
      ports_3_fsm_stateReg <= ports_3_fsm_stateNext;
    end
  end

  always @(posedge phy_clk) begin
    if(txShared_timer_inc) begin
      txShared_timer_counter <= (txShared_timer_counter + 10'h001);
    end
    if(txShared_timer_clear) begin
      txShared_timer_counter <= 10'h000;
    end
    if(txShared_rxToTxDelay_inc) begin
      txShared_rxToTxDelay_counter <= (txShared_rxToTxDelay_counter + 9'h001);
    end
    if(txShared_rxToTxDelay_clear) begin
      txShared_rxToTxDelay_counter <= 9'h000;
    end
    if(txShared_encoder_input_valid) begin
      if(txShared_encoder_input_data) begin
        if(txShared_timer_oneCycle) begin
          txShared_encoder_counter <= (txShared_encoder_counter + 3'b001);
          if(when_UsbHubPhy_l194) begin
            txShared_encoder_state <= (! txShared_encoder_state);
          end
          if(when_UsbHubPhy_l199) begin
            txShared_encoder_counter <= 3'b000;
          end
        end
      end else begin
        if(txShared_timer_oneCycle) begin
          txShared_encoder_counter <= 3'b000;
          txShared_encoder_state <= (! txShared_encoder_state);
        end
      end
    end
    if(when_UsbHubPhy_l213) begin
      txShared_encoder_counter <= 3'b000;
      txShared_encoder_state <= 1'b1;
    end
    if(txShared_serialiser_input_valid) begin
      if(txShared_encoder_input_ready) begin
        txShared_serialiser_bitCounter <= (txShared_serialiser_bitCounter + 3'b001);
      end
    end
    if(when_UsbHubPhy_l245) begin
      txShared_serialiser_bitCounter <= 3'b000;
    end
    txShared_encoder_output_valid_regNext <= txShared_encoder_output_valid;
    if(when_UsbHubPhy_l256) begin
      if(when_UsbHubPhy_l257) begin
        txShared_lowSpeedSof_timer <= 5'h00;
      end
    end else begin
      txShared_lowSpeedSof_timer <= (txShared_lowSpeedSof_timer + 5'h01);
    end
    if(upstreamRx_timer_inc) begin
      upstreamRx_timer_counter <= (upstreamRx_timer_counter + 20'h00001);
    end
    if(upstreamRx_timer_clear) begin
      upstreamRx_timer_counter <= 20'h00000;
    end
    if(ports_0_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l450) begin
        ports_0_rx_decoder_state <= (! ports_0_rx_decoder_state);
      end
    end
    if(ports_0_rx_waitSync) begin
      ports_0_rx_decoder_state <= 1'b0;
    end
    if(ports_0_rx_decoder_output_valid) begin
      ports_0_rx_destuffer_counter <= (ports_0_rx_destuffer_counter + 3'b001);
      if(when_UsbHubPhy_l471) begin
        ports_0_rx_destuffer_counter <= 3'b000;
        if(ports_0_rx_decoder_output_payload) begin
          ports_0_rx_stuffingError <= 1'b1;
        end
      end
    end
    if(ports_0_rx_waitSync) begin
      ports_0_rx_destuffer_counter <= 3'b000;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_1 <= _zz_ports_0_rx_history_value;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_2 <= _zz_ports_0_rx_history_value_1;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_3 <= _zz_ports_0_rx_history_value_2;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_4 <= _zz_ports_0_rx_history_value_3;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_5 <= _zz_ports_0_rx_history_value_4;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_6 <= _zz_ports_0_rx_history_value_5;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_7 <= _zz_ports_0_rx_history_value_6;
    end
    if(ports_0_rx_packet_errorTimeout_inc) begin
      ports_0_rx_packet_errorTimeout_counter <= (ports_0_rx_packet_errorTimeout_counter + 12'h001);
    end
    if(ports_0_rx_packet_errorTimeout_clear) begin
      ports_0_rx_packet_errorTimeout_counter <= 12'h000;
    end
    ports_0_rx_disconnect_hitLast <= ports_0_rx_disconnect_hit;
    if(ports_0_fsm_timer_inc) begin
      ports_0_fsm_timer_counter <= (ports_0_fsm_timer_counter + 24'h000001);
    end
    if(ports_0_fsm_timer_clear) begin
      ports_0_fsm_timer_counter <= 24'h000000;
    end
    if(ports_1_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l450_1) begin
        ports_1_rx_decoder_state <= (! ports_1_rx_decoder_state);
      end
    end
    if(ports_1_rx_waitSync) begin
      ports_1_rx_decoder_state <= 1'b0;
    end
    if(ports_1_rx_decoder_output_valid) begin
      ports_1_rx_destuffer_counter <= (ports_1_rx_destuffer_counter + 3'b001);
      if(when_UsbHubPhy_l471_1) begin
        ports_1_rx_destuffer_counter <= 3'b000;
        if(ports_1_rx_decoder_output_payload) begin
          ports_1_rx_stuffingError <= 1'b1;
        end
      end
    end
    if(ports_1_rx_waitSync) begin
      ports_1_rx_destuffer_counter <= 3'b000;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_1 <= _zz_ports_1_rx_history_value;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_2 <= _zz_ports_1_rx_history_value_1;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_3 <= _zz_ports_1_rx_history_value_2;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_4 <= _zz_ports_1_rx_history_value_3;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_5 <= _zz_ports_1_rx_history_value_4;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_6 <= _zz_ports_1_rx_history_value_5;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_7 <= _zz_ports_1_rx_history_value_6;
    end
    if(ports_1_rx_packet_errorTimeout_inc) begin
      ports_1_rx_packet_errorTimeout_counter <= (ports_1_rx_packet_errorTimeout_counter + 12'h001);
    end
    if(ports_1_rx_packet_errorTimeout_clear) begin
      ports_1_rx_packet_errorTimeout_counter <= 12'h000;
    end
    ports_1_rx_disconnect_hitLast <= ports_1_rx_disconnect_hit;
    if(ports_1_fsm_timer_inc) begin
      ports_1_fsm_timer_counter <= (ports_1_fsm_timer_counter + 24'h000001);
    end
    if(ports_1_fsm_timer_clear) begin
      ports_1_fsm_timer_counter <= 24'h000000;
    end
    if(ports_2_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l450_2) begin
        ports_2_rx_decoder_state <= (! ports_2_rx_decoder_state);
      end
    end
    if(ports_2_rx_waitSync) begin
      ports_2_rx_decoder_state <= 1'b0;
    end
    if(ports_2_rx_decoder_output_valid) begin
      ports_2_rx_destuffer_counter <= (ports_2_rx_destuffer_counter + 3'b001);
      if(when_UsbHubPhy_l471_2) begin
        ports_2_rx_destuffer_counter <= 3'b000;
        if(ports_2_rx_decoder_output_payload) begin
          ports_2_rx_stuffingError <= 1'b1;
        end
      end
    end
    if(ports_2_rx_waitSync) begin
      ports_2_rx_destuffer_counter <= 3'b000;
    end
    if(ports_2_rx_history_updated) begin
      _zz_ports_2_rx_history_value_1 <= _zz_ports_2_rx_history_value;
    end
    if(ports_2_rx_history_updated) begin
      _zz_ports_2_rx_history_value_2 <= _zz_ports_2_rx_history_value_1;
    end
    if(ports_2_rx_history_updated) begin
      _zz_ports_2_rx_history_value_3 <= _zz_ports_2_rx_history_value_2;
    end
    if(ports_2_rx_history_updated) begin
      _zz_ports_2_rx_history_value_4 <= _zz_ports_2_rx_history_value_3;
    end
    if(ports_2_rx_history_updated) begin
      _zz_ports_2_rx_history_value_5 <= _zz_ports_2_rx_history_value_4;
    end
    if(ports_2_rx_history_updated) begin
      _zz_ports_2_rx_history_value_6 <= _zz_ports_2_rx_history_value_5;
    end
    if(ports_2_rx_history_updated) begin
      _zz_ports_2_rx_history_value_7 <= _zz_ports_2_rx_history_value_6;
    end
    if(ports_2_rx_packet_errorTimeout_inc) begin
      ports_2_rx_packet_errorTimeout_counter <= (ports_2_rx_packet_errorTimeout_counter + 12'h001);
    end
    if(ports_2_rx_packet_errorTimeout_clear) begin
      ports_2_rx_packet_errorTimeout_counter <= 12'h000;
    end
    ports_2_rx_disconnect_hitLast <= ports_2_rx_disconnect_hit;
    if(ports_2_fsm_timer_inc) begin
      ports_2_fsm_timer_counter <= (ports_2_fsm_timer_counter + 24'h000001);
    end
    if(ports_2_fsm_timer_clear) begin
      ports_2_fsm_timer_counter <= 24'h000000;
    end
    if(ports_3_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l450_3) begin
        ports_3_rx_decoder_state <= (! ports_3_rx_decoder_state);
      end
    end
    if(ports_3_rx_waitSync) begin
      ports_3_rx_decoder_state <= 1'b0;
    end
    if(ports_3_rx_decoder_output_valid) begin
      ports_3_rx_destuffer_counter <= (ports_3_rx_destuffer_counter + 3'b001);
      if(when_UsbHubPhy_l471_3) begin
        ports_3_rx_destuffer_counter <= 3'b000;
        if(ports_3_rx_decoder_output_payload) begin
          ports_3_rx_stuffingError <= 1'b1;
        end
      end
    end
    if(ports_3_rx_waitSync) begin
      ports_3_rx_destuffer_counter <= 3'b000;
    end
    if(ports_3_rx_history_updated) begin
      _zz_ports_3_rx_history_value_1 <= _zz_ports_3_rx_history_value;
    end
    if(ports_3_rx_history_updated) begin
      _zz_ports_3_rx_history_value_2 <= _zz_ports_3_rx_history_value_1;
    end
    if(ports_3_rx_history_updated) begin
      _zz_ports_3_rx_history_value_3 <= _zz_ports_3_rx_history_value_2;
    end
    if(ports_3_rx_history_updated) begin
      _zz_ports_3_rx_history_value_4 <= _zz_ports_3_rx_history_value_3;
    end
    if(ports_3_rx_history_updated) begin
      _zz_ports_3_rx_history_value_5 <= _zz_ports_3_rx_history_value_4;
    end
    if(ports_3_rx_history_updated) begin
      _zz_ports_3_rx_history_value_6 <= _zz_ports_3_rx_history_value_5;
    end
    if(ports_3_rx_history_updated) begin
      _zz_ports_3_rx_history_value_7 <= _zz_ports_3_rx_history_value_6;
    end
    if(ports_3_rx_packet_errorTimeout_inc) begin
      ports_3_rx_packet_errorTimeout_counter <= (ports_3_rx_packet_errorTimeout_counter + 12'h001);
    end
    if(ports_3_rx_packet_errorTimeout_clear) begin
      ports_3_rx_packet_errorTimeout_counter <= 12'h000;
    end
    ports_3_rx_disconnect_hitLast <= ports_3_rx_disconnect_hit;
    if(ports_3_fsm_timer_inc) begin
      ports_3_fsm_timer_counter <= (ports_3_fsm_timer_counter + 24'h000001);
    end
    if(ports_3_fsm_timer_clear) begin
      ports_3_fsm_timer_counter <= 24'h000000;
    end
    case(txShared_frame_stateReg)
      UsbOhciAxi4_txShared_frame_enumDef_IDLE : begin
        txShared_frame_wasLowSpeed <= io_ctrl_lowSpeed;
      end
      UsbOhciAxi4_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciAxi4_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
    case(ports_0_rx_packet_stateReg)
      UsbOhciAxi4_ports_0_rx_packet_enumDef_IDLE : begin
        ports_0_rx_packet_counter <= 3'b000;
        ports_0_rx_stuffingError <= 1'b0;
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_PACKET : begin
        if(ports_0_rx_destuffer_output_valid) begin
          ports_0_rx_packet_counter <= (ports_0_rx_packet_counter + 3'b001);
        end
      end
      UsbOhciAxi4_ports_0_rx_packet_enumDef_ERRORED : begin
        ports_0_rx_packet_errorTimeout_p <= ports_0_filter_io_filtred_dp;
        ports_0_rx_packet_errorTimeout_n <= ports_0_filter_io_filtred_dm;
      end
      default : begin
      end
    endcase
    if(ports_0_rx_eop_hit) begin
      txShared_rxToTxDelay_lowSpeed <= io_ctrl_lowSpeed;
    end
    case(ports_0_fsm_stateReg)
      UsbOhciAxi4_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESUMING : begin
        if(ports_0_fsm_timer_RESUME_EOI) begin
          ports_0_fsm_lowSpeedEop <= 1'b1;
        end
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(!when_UsbHubPhy_l615) begin
      if(!ports_0_rx_disconnect_event) begin
        if(!io_ctrl_ports_0_disable_valid) begin
          if(io_ctrl_ports_0_reset_valid) begin
            if(when_UsbHubPhy_l622) begin
              if(when_UsbHubPhy_l623) begin
                ports_0_portLowSpeed <= (! ports_0_filter_io_filtred_d);
              end
            end
          end
        end
      end
    end
    case(ports_1_rx_packet_stateReg)
      UsbOhciAxi4_ports_1_rx_packet_enumDef_IDLE : begin
        ports_1_rx_packet_counter <= 3'b000;
        ports_1_rx_stuffingError <= 1'b0;
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_PACKET : begin
        if(ports_1_rx_destuffer_output_valid) begin
          ports_1_rx_packet_counter <= (ports_1_rx_packet_counter + 3'b001);
        end
      end
      UsbOhciAxi4_ports_1_rx_packet_enumDef_ERRORED : begin
        ports_1_rx_packet_errorTimeout_p <= ports_1_filter_io_filtred_dp;
        ports_1_rx_packet_errorTimeout_n <= ports_1_filter_io_filtred_dm;
      end
      default : begin
      end
    endcase
    if(ports_1_rx_eop_hit) begin
      txShared_rxToTxDelay_lowSpeed <= io_ctrl_lowSpeed;
    end
    case(ports_1_fsm_stateReg)
      UsbOhciAxi4_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESUMING : begin
        if(ports_1_fsm_timer_RESUME_EOI) begin
          ports_1_fsm_lowSpeedEop <= 1'b1;
        end
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(!when_UsbHubPhy_l615_1) begin
      if(!ports_1_rx_disconnect_event) begin
        if(!io_ctrl_ports_1_disable_valid) begin
          if(io_ctrl_ports_1_reset_valid) begin
            if(when_UsbHubPhy_l622_1) begin
              if(when_UsbHubPhy_l623_1) begin
                ports_1_portLowSpeed <= (! ports_1_filter_io_filtred_d);
              end
            end
          end
        end
      end
    end
    case(ports_2_rx_packet_stateReg)
      UsbOhciAxi4_ports_2_rx_packet_enumDef_IDLE : begin
        ports_2_rx_packet_counter <= 3'b000;
        ports_2_rx_stuffingError <= 1'b0;
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_PACKET : begin
        if(ports_2_rx_destuffer_output_valid) begin
          ports_2_rx_packet_counter <= (ports_2_rx_packet_counter + 3'b001);
        end
      end
      UsbOhciAxi4_ports_2_rx_packet_enumDef_ERRORED : begin
        ports_2_rx_packet_errorTimeout_p <= ports_2_filter_io_filtred_dp;
        ports_2_rx_packet_errorTimeout_n <= ports_2_filter_io_filtred_dm;
      end
      default : begin
      end
    endcase
    if(ports_2_rx_eop_hit) begin
      txShared_rxToTxDelay_lowSpeed <= io_ctrl_lowSpeed;
    end
    case(ports_2_fsm_stateReg)
      UsbOhciAxi4_ports_2_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESUMING : begin
        if(ports_2_fsm_timer_RESUME_EOI) begin
          ports_2_fsm_lowSpeedEop <= 1'b1;
        end
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_2_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(!when_UsbHubPhy_l615_2) begin
      if(!ports_2_rx_disconnect_event) begin
        if(!io_ctrl_ports_2_disable_valid) begin
          if(io_ctrl_ports_2_reset_valid) begin
            if(when_UsbHubPhy_l622_2) begin
              if(when_UsbHubPhy_l623_2) begin
                ports_2_portLowSpeed <= (! ports_2_filter_io_filtred_d);
              end
            end
          end
        end
      end
    end
    case(ports_3_rx_packet_stateReg)
      UsbOhciAxi4_ports_3_rx_packet_enumDef_IDLE : begin
        ports_3_rx_packet_counter <= 3'b000;
        ports_3_rx_stuffingError <= 1'b0;
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_PACKET : begin
        if(ports_3_rx_destuffer_output_valid) begin
          ports_3_rx_packet_counter <= (ports_3_rx_packet_counter + 3'b001);
        end
      end
      UsbOhciAxi4_ports_3_rx_packet_enumDef_ERRORED : begin
        ports_3_rx_packet_errorTimeout_p <= ports_3_filter_io_filtred_dp;
        ports_3_rx_packet_errorTimeout_n <= ports_3_filter_io_filtred_dm;
      end
      default : begin
      end
    endcase
    if(ports_3_rx_eop_hit) begin
      txShared_rxToTxDelay_lowSpeed <= io_ctrl_lowSpeed;
    end
    case(ports_3_fsm_stateReg)
      UsbOhciAxi4_ports_3_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_DISABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_ENABLED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESUMING : begin
        if(ports_3_fsm_timer_RESUME_EOI) begin
          ports_3_fsm_lowSpeedEop <= 1'b1;
        end
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciAxi4_ports_3_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(!when_UsbHubPhy_l615_3) begin
      if(!ports_3_rx_disconnect_event) begin
        if(!io_ctrl_ports_3_disable_valid) begin
          if(io_ctrl_ports_3_reset_valid) begin
            if(when_UsbHubPhy_l622_3) begin
              if(when_UsbHubPhy_l623_3) begin
                ports_3_portLowSpeed <= (! ports_3_filter_io_filtred_d);
              end
            end
          end
        end
      end
    end
  end

  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      io_ctrl_tx_payload_first <= 1'b1;
    end else begin
      if(io_ctrl_tx_fire) begin
        io_ctrl_tx_payload_first <= io_ctrl_tx_payload_last;
      end
    end
  end


endmodule

module UsbOhciAxi4_UsbOhci (
  input  wire          io_ctrl_cmd_valid,
  output wire          io_ctrl_cmd_ready,
  input  wire          io_ctrl_cmd_payload_last,
  input  wire [8:0]    io_ctrl_cmd_payload_fragment_source,
  input  wire [0:0]    io_ctrl_cmd_payload_fragment_opcode,
  input  wire [11:0]   io_ctrl_cmd_payload_fragment_address,
  input  wire [9:0]    io_ctrl_cmd_payload_fragment_length,
  input  wire [31:0]   io_ctrl_cmd_payload_fragment_data,
  input  wire [3:0]    io_ctrl_cmd_payload_fragment_mask,
  output wire          io_ctrl_rsp_valid,
  input  wire          io_ctrl_rsp_ready,
  output wire          io_ctrl_rsp_payload_last,
  output wire [8:0]    io_ctrl_rsp_payload_fragment_source,
  output wire [0:0]    io_ctrl_rsp_payload_fragment_opcode,
  output wire [31:0]   io_ctrl_rsp_payload_fragment_data,
  output reg           io_phy_lowSpeed,
  output reg           io_phy_tx_valid,
  input  wire          io_phy_tx_ready,
  output reg           io_phy_tx_payload_last,
  output reg  [7:0]    io_phy_tx_payload_fragment,
  input  wire          io_phy_txEop,
  input  wire          io_phy_rx_flow_valid,
  input  wire          io_phy_rx_flow_payload_stuffingError,
  input  wire [7:0]    io_phy_rx_flow_payload_data,
  input  wire          io_phy_rx_active,
  output wire          io_phy_usbReset,
  output wire          io_phy_usbResume,
  input  wire          io_phy_overcurrent,
  input  wire          io_phy_tick,
  output wire          io_phy_ports_0_disable_valid,
  input  wire          io_phy_ports_0_disable_ready,
  output wire          io_phy_ports_0_removable,
  output wire          io_phy_ports_0_power,
  output wire          io_phy_ports_0_reset_valid,
  input  wire          io_phy_ports_0_reset_ready,
  output wire          io_phy_ports_0_suspend_valid,
  input  wire          io_phy_ports_0_suspend_ready,
  output wire          io_phy_ports_0_resume_valid,
  input  wire          io_phy_ports_0_resume_ready,
  input  wire          io_phy_ports_0_connect,
  input  wire          io_phy_ports_0_disconnect,
  input  wire          io_phy_ports_0_overcurrent,
  input  wire          io_phy_ports_0_remoteResume,
  input  wire          io_phy_ports_0_lowSpeed,
  output wire          io_phy_ports_1_disable_valid,
  input  wire          io_phy_ports_1_disable_ready,
  output wire          io_phy_ports_1_removable,
  output wire          io_phy_ports_1_power,
  output wire          io_phy_ports_1_reset_valid,
  input  wire          io_phy_ports_1_reset_ready,
  output wire          io_phy_ports_1_suspend_valid,
  input  wire          io_phy_ports_1_suspend_ready,
  output wire          io_phy_ports_1_resume_valid,
  input  wire          io_phy_ports_1_resume_ready,
  input  wire          io_phy_ports_1_connect,
  input  wire          io_phy_ports_1_disconnect,
  input  wire          io_phy_ports_1_overcurrent,
  input  wire          io_phy_ports_1_remoteResume,
  input  wire          io_phy_ports_1_lowSpeed,
  output wire          io_phy_ports_2_disable_valid,
  input  wire          io_phy_ports_2_disable_ready,
  output wire          io_phy_ports_2_removable,
  output wire          io_phy_ports_2_power,
  output wire          io_phy_ports_2_reset_valid,
  input  wire          io_phy_ports_2_reset_ready,
  output wire          io_phy_ports_2_suspend_valid,
  input  wire          io_phy_ports_2_suspend_ready,
  output wire          io_phy_ports_2_resume_valid,
  input  wire          io_phy_ports_2_resume_ready,
  input  wire          io_phy_ports_2_connect,
  input  wire          io_phy_ports_2_disconnect,
  input  wire          io_phy_ports_2_overcurrent,
  input  wire          io_phy_ports_2_remoteResume,
  input  wire          io_phy_ports_2_lowSpeed,
  output wire          io_phy_ports_3_disable_valid,
  input  wire          io_phy_ports_3_disable_ready,
  output wire          io_phy_ports_3_removable,
  output wire          io_phy_ports_3_power,
  output wire          io_phy_ports_3_reset_valid,
  input  wire          io_phy_ports_3_reset_ready,
  output wire          io_phy_ports_3_suspend_valid,
  input  wire          io_phy_ports_3_suspend_ready,
  output wire          io_phy_ports_3_resume_valid,
  input  wire          io_phy_ports_3_resume_ready,
  input  wire          io_phy_ports_3_connect,
  input  wire          io_phy_ports_3_disconnect,
  input  wire          io_phy_ports_3_overcurrent,
  input  wire          io_phy_ports_3_remoteResume,
  input  wire          io_phy_ports_3_lowSpeed,
  output wire          io_dma_cmd_valid,
  input  wire          io_dma_cmd_ready,
  output wire          io_dma_cmd_payload_last,
  output wire [0:0]    io_dma_cmd_payload_fragment_opcode,
  output wire [31:0]   io_dma_cmd_payload_fragment_address,
  output wire [5:0]    io_dma_cmd_payload_fragment_length,
  output wire [31:0]   io_dma_cmd_payload_fragment_data,
  output wire [3:0]    io_dma_cmd_payload_fragment_mask,
  input  wire          io_dma_rsp_valid,
  output wire          io_dma_rsp_ready,
  input  wire          io_dma_rsp_payload_last,
  input  wire [0:0]    io_dma_rsp_payload_fragment_opcode,
  input  wire [31:0]   io_dma_rsp_payload_fragment_data,
  output wire          io_interrupt,
  output wire          io_interruptBios,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);
  localparam UsbOhciAxi4_MainState_RESET = 2'd0;
  localparam UsbOhciAxi4_MainState_RESUME = 2'd1;
  localparam UsbOhciAxi4_MainState_OPERATIONAL = 2'd2;
  localparam UsbOhciAxi4_MainState_SUSPEND = 2'd3;
  localparam UsbOhciAxi4_FlowType_BULK = 2'd0;
  localparam UsbOhciAxi4_FlowType_CONTROL = 2'd1;
  localparam UsbOhciAxi4_FlowType_PERIODIC = 2'd2;
  localparam UsbOhciAxi4_endpoint_Status_OK = 1'd0;
  localparam UsbOhciAxi4_endpoint_Status_FRAME_TIME = 1'd1;
  localparam UsbOhciAxi4_endpoint_enumDef_BOOT = 5'd0;
  localparam UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD = 5'd1;
  localparam UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP = 5'd2;
  localparam UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE = 5'd3;
  localparam UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD = 5'd4;
  localparam UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP = 5'd5;
  localparam UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY = 5'd6;
  localparam UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE = 5'd7;
  localparam UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME = 5'd8;
  localparam UsbOhciAxi4_endpoint_enumDef_BUFFER_READ = 5'd9;
  localparam UsbOhciAxi4_endpoint_enumDef_TOKEN = 5'd10;
  localparam UsbOhciAxi4_endpoint_enumDef_DATA_TX = 5'd11;
  localparam UsbOhciAxi4_endpoint_enumDef_DATA_RX = 5'd12;
  localparam UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE = 5'd13;
  localparam UsbOhciAxi4_endpoint_enumDef_ACK_RX = 5'd14;
  localparam UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 = 5'd15;
  localparam UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 = 5'd16;
  localparam UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP = 5'd17;
  localparam UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA = 5'd18;
  localparam UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS = 5'd19;
  localparam UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD = 5'd20;
  localparam UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD = 5'd21;
  localparam UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC = 5'd22;
  localparam UsbOhciAxi4_endpoint_enumDef_ABORD = 5'd23;
  localparam UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT = 3'd0;
  localparam UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT = 3'd1;
  localparam UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB = 3'd2;
  localparam UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB = 3'd3;
  localparam UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION = 3'd4;
  localparam UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD = 3'd5;
  localparam UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD = 3'd6;
  localparam UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD = 3'd7;
  localparam UsbOhciAxi4_token_enumDef_BOOT = 3'd0;
  localparam UsbOhciAxi4_token_enumDef_INIT = 3'd1;
  localparam UsbOhciAxi4_token_enumDef_PID = 3'd2;
  localparam UsbOhciAxi4_token_enumDef_B1 = 3'd3;
  localparam UsbOhciAxi4_token_enumDef_B2 = 3'd4;
  localparam UsbOhciAxi4_token_enumDef_EOP = 3'd5;
  localparam UsbOhciAxi4_dataTx_enumDef_BOOT = 3'd0;
  localparam UsbOhciAxi4_dataTx_enumDef_PID = 3'd1;
  localparam UsbOhciAxi4_dataTx_enumDef_DATA = 3'd2;
  localparam UsbOhciAxi4_dataTx_enumDef_CRC_0 = 3'd3;
  localparam UsbOhciAxi4_dataTx_enumDef_CRC_1 = 3'd4;
  localparam UsbOhciAxi4_dataTx_enumDef_EOP = 3'd5;
  localparam UsbOhciAxi4_dataRx_enumDef_BOOT = 2'd0;
  localparam UsbOhciAxi4_dataRx_enumDef_IDLE = 2'd1;
  localparam UsbOhciAxi4_dataRx_enumDef_PID = 2'd2;
  localparam UsbOhciAxi4_dataRx_enumDef_DATA = 2'd3;
  localparam UsbOhciAxi4_sof_enumDef_BOOT = 2'd0;
  localparam UsbOhciAxi4_sof_enumDef_FRAME_TX = 2'd1;
  localparam UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD = 2'd2;
  localparam UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP = 2'd3;
  localparam UsbOhciAxi4_operational_enumDef_BOOT = 3'd0;
  localparam UsbOhciAxi4_operational_enumDef_SOF = 3'd1;
  localparam UsbOhciAxi4_operational_enumDef_ARBITER = 3'd2;
  localparam UsbOhciAxi4_operational_enumDef_END_POINT = 3'd3;
  localparam UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD = 3'd4;
  localparam UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP = 3'd5;
  localparam UsbOhciAxi4_operational_enumDef_WAIT_SOF = 3'd6;
  localparam UsbOhciAxi4_hc_enumDef_BOOT = 3'd0;
  localparam UsbOhciAxi4_hc_enumDef_RESET = 3'd1;
  localparam UsbOhciAxi4_hc_enumDef_RESUME = 3'd2;
  localparam UsbOhciAxi4_hc_enumDef_OPERATIONAL = 3'd3;
  localparam UsbOhciAxi4_hc_enumDef_SUSPEND = 3'd4;
  localparam UsbOhciAxi4_hc_enumDef_ANY_TO_RESET = 3'd5;
  localparam UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND = 3'd6;

  reg                 fifo_io_push_valid;
  reg        [31:0]   fifo_io_push_payload;
  reg                 fifo_io_pop_ready;
  reg                 fifo_io_flush;
  reg                 token_crc5_io_flush;
  reg                 token_crc5_io_input_valid;
  reg                 dataTx_crc16_io_flush;
  reg                 dataRx_crc16_io_flush;
  reg                 dataRx_crc16_io_input_valid;
  wire                fifo_io_push_ready;
  wire                fifo_io_pop_valid;
  wire       [31:0]   fifo_io_pop_payload;
  wire       [8:0]    fifo_io_occupancy;
  wire       [8:0]    fifo_io_availability;
  wire       [4:0]    token_crc5_io_result;
  wire       [4:0]    token_crc5_io_resultNext;
  wire       [15:0]   dataTx_crc16_io_result;
  wire       [15:0]   dataTx_crc16_io_resultNext;
  wire       [15:0]   dataRx_crc16_io_result;
  wire       [15:0]   dataRx_crc16_io_resultNext;
  wire       [3:0]    _zz_dmaCtx_pendingCounter;
  wire       [3:0]    _zz_dmaCtx_pendingCounter_1;
  wire       [0:0]    _zz_dmaCtx_pendingCounter_2;
  wire       [3:0]    _zz_dmaCtx_pendingCounter_3;
  wire       [0:0]    _zz_dmaCtx_pendingCounter_4;
  wire       [0:0]    _zz_reg_hcCommandStatus_startSoftReset;
  wire       [0:0]    _zz_reg_hcCommandStatus_CLF;
  wire       [0:0]    _zz_reg_hcCommandStatus_BLF;
  wire       [0:0]    _zz_reg_hcCommandStatus_OCR;
  wire       [0:0]    _zz_reg_hcInterrupt_MIE;
  wire       [0:0]    _zz_reg_hcInterrupt_MIE_1;
  wire       [0:0]    _zz_reg_hcInterrupt_SO_status;
  wire       [0:0]    _zz_reg_hcInterrupt_SO_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_SO_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_WDH_status;
  wire       [0:0]    _zz_reg_hcInterrupt_WDH_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_WDH_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_SF_status;
  wire       [0:0]    _zz_reg_hcInterrupt_SF_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_SF_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_RD_status;
  wire       [0:0]    _zz_reg_hcInterrupt_RD_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_RD_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_UE_status;
  wire       [0:0]    _zz_reg_hcInterrupt_UE_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_UE_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_FNO_status;
  wire       [0:0]    _zz_reg_hcInterrupt_FNO_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_FNO_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_RHSC_status;
  wire       [0:0]    _zz_reg_hcInterrupt_RHSC_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_RHSC_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_OC_status;
  wire       [0:0]    _zz_reg_hcInterrupt_OC_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_OC_enable_1;
  wire       [13:0]   _zz_reg_hcLSThreshold_hit;
  wire       [0:0]    _zz_reg_hcRhStatus_CCIC;
  wire       [0:0]    _zz_reg_hcRhStatus_clearGlobalPower;
  wire       [0:0]    _zz_reg_hcRhStatus_setRemoteWakeupEnable;
  wire       [0:0]    _zz_reg_hcRhStatus_setGlobalPower;
  wire       [0:0]    _zz_reg_hcRhStatus_clearRemoteWakeupEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_clearPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_setPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_setPortSuspend;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_clearSuspendStatus;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_setPortReset;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_setPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_clearPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_CSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_PESC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_PSSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_OCIC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_PRSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_clearPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_setPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_setPortSuspend;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_clearSuspendStatus;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_setPortReset;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_setPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_clearPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_CSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_PESC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_PSSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_OCIC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_PRSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_clearPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_setPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_setPortSuspend;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_clearSuspendStatus;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_setPortReset;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_setPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_clearPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_CSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_PESC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_PSSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_OCIC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_2_PRSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_clearPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_setPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_setPortSuspend;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_clearSuspendStatus;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_setPortReset;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_setPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_clearPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_CSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_PESC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_PSSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_OCIC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_3_PRSC_clear;
  wire       [7:0]    _zz_rxTimer_ackTx;
  wire       [3:0]    _zz_rxTimer_ackTx_1;
  wire       [15:0]   _zz_endpoint_TD_isoOverrun;
  wire       [12:0]   _zz_endpoint_TD_firstOffset;
  wire       [11:0]   _zz_endpoint_TD_firstOffset_1;
  wire       [12:0]   _zz_endpoint_TD_lastOffset;
  wire       [12:0]   _zz_endpoint_TD_lastOffset_1;
  wire       [0:0]    _zz_endpoint_TD_lastOffset_2;
  wire       [13:0]   _zz_endpoint_transactionSizeMinusOne;
  wire       [13:0]   _zz_endpoint_dataDone;
  wire       [5:0]    _zz_endpoint_dmaLogic_lengthMax;
  wire       [13:0]   _zz_endpoint_dmaLogic_lengthCalc;
  wire       [13:0]   _zz_endpoint_dmaLogic_lengthCalc_1;
  wire       [13:0]   _zz_endpoint_dmaLogic_lengthCalc_2;
  wire       [6:0]    _zz_endpoint_dmaLogic_beatCount;
  wire       [6:0]    _zz_endpoint_dmaLogic_beatCount_1;
  wire       [1:0]    _zz_endpoint_dmaLogic_beatCount_2;
  wire       [6:0]    _zz_endpoint_dmaLogic_lengthBmb;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_1;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_2;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_3;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_4;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_5;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_6;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_7;
  wire       [5:0]    _zz_endpoint_dmaLogic_beatLast;
  wire       [13:0]   _zz_endpoint_byteCountCalc;
  wire       [13:0]   _zz_endpoint_byteCountCalc_1;
  wire       [16:0]   _zz_endpoint_fsTimeCheck;
  wire       [16:0]   _zz_endpoint_fsTimeCheck_1;
  wire       [15:0]   _zz_token_data;
  wire       [4:0]    _zz_ioDma_cmd_payload_fragment_length;
  wire       [13:0]   _zz__zz_endpoint_lastAddress;
  wire       [13:0]   _zz__zz_endpoint_lastAddress_1;
  wire       [11:0]   _zz__zz_endpoint_lastAddress_2;
  wire       [13:0]   _zz_endpoint_lastAddress_1;
  wire       [13:0]   _zz_endpoint_lastAddress_2;
  wire       [13:0]   _zz_endpoint_lastAddress_3;
  wire       [13:0]   _zz_endpoint_lastAddress_4;
  wire       [13:0]   _zz_when_UsbOhci_l1333;
  wire       [1:0]    _zz_endpoint_TD_words_0;
  wire       [4:0]    _zz_ioDma_cmd_payload_fragment_length_1;
  wire       [3:0]    _zz_ioDma_cmd_payload_last;
  wire       [2:0]    _zz_ioDma_cmd_payload_last_1;
  wire       [11:0]   _zz__zz_ioDma_cmd_payload_fragment_data;
  wire       [13:0]   _zz__zz_ioDma_cmd_payload_fragment_data_1;
  wire       [13:0]   _zz__zz_ioDma_cmd_payload_fragment_data_2;
  wire       [13:0]   _zz__zz_ioDma_cmd_payload_fragment_data_3;
  reg        [7:0]    _zz_dataTx_data_payload_fragment;
  wire       [13:0]   _zz_when_UsbOhci_l1056;
  wire       [13:0]   _zz_endpoint_dmaLogic_overflow;
  wire       [13:0]   _zz_endpoint_lastAddress_5;
  wire       [13:0]   _zz_endpoint_lastAddress_6;
  wire       [13:0]   _zz_endpoint_lastAddress_7;
  wire       [10:0]   _zz_endpoint_dmaLogic_fromUsbCounter;
  wire       [0:0]    _zz_endpoint_dmaLogic_fromUsbCounter_1;
  wire       [13:0]   _zz_endpoint_currentAddress;
  wire       [13:0]   _zz_endpoint_currentAddress_1;
  wire       [13:0]   _zz_endpoint_currentAddress_2;
  wire       [13:0]   _zz_endpoint_currentAddress_3;
  wire       [31:0]   _zz_ioDma_cmd_payload_fragment_address;
  wire       [6:0]    _zz_ioDma_cmd_payload_fragment_address_1;
  reg                 unscheduleAll_valid;
  reg                 unscheduleAll_ready;
  reg                 ioDma_cmd_valid;
  wire                ioDma_cmd_ready;
  reg                 ioDma_cmd_payload_last;
  reg        [0:0]    ioDma_cmd_payload_fragment_opcode;
  reg        [31:0]   ioDma_cmd_payload_fragment_address;
  reg        [5:0]    ioDma_cmd_payload_fragment_length;
  reg        [31:0]   ioDma_cmd_payload_fragment_data;
  reg        [3:0]    ioDma_cmd_payload_fragment_mask;
  wire                ioDma_rsp_valid;
  wire                ioDma_rsp_ready;
  wire                ioDma_rsp_payload_last;
  wire       [0:0]    ioDma_rsp_payload_fragment_opcode;
  wire       [31:0]   ioDma_rsp_payload_fragment_data;
  reg        [3:0]    dmaCtx_pendingCounter;
  wire                ioDma_cmd_fire;
  wire                ioDma_rsp_fire;
  wire                dmaCtx_pendingFull;
  wire                dmaCtx_pendingEmpty;
  reg        [5:0]    dmaCtx_beatCounter;
  wire                when_UsbOhci_l158;
  wire                io_dma_cmd_fire;
  reg                 io_dma_cmd_payload_first;
  wire                _zz_io_dma_cmd_valid;
  wire       [31:0]   dmaRspMux_vec_0;
  wire       [31:0]   dmaRspMux_data;
  reg        [3:0]    dmaReadCtx_counter;
  reg        [3:0]    dmaWriteCtx_counter;
  reg                 ctrlHalt;
  wire                ctrl_readErrorFlag;
  wire                ctrl_writeErrorFlag;
  wire                ctrl_readHaltTrigger;
  reg                 ctrl_writeHaltTrigger;
  wire                ctrl_rsp_valid;
  wire                ctrl_rsp_ready;
  wire                ctrl_rsp_payload_last;
  wire       [8:0]    ctrl_rsp_payload_fragment_source;
  reg        [0:0]    ctrl_rsp_payload_fragment_opcode;
  reg        [31:0]   ctrl_rsp_payload_fragment_data;
  wire                _zz_ctrl_rsp_ready;
  reg                 _zz_ctrl_rsp_ready_1;
  wire                _zz_io_ctrl_rsp_valid;
  reg                 _zz_io_ctrl_rsp_valid_1;
  reg                 _zz_io_ctrl_rsp_payload_last;
  reg        [8:0]    _zz_io_ctrl_rsp_payload_fragment_source;
  reg        [0:0]    _zz_io_ctrl_rsp_payload_fragment_opcode;
  reg        [31:0]   _zz_io_ctrl_rsp_payload_fragment_data;
  wire                when_Stream_l369;
  wire                ctrl_askWrite;
  wire                ctrl_askRead;
  wire                io_ctrl_cmd_fire;
  wire                ctrl_doWrite;
  wire                ctrl_doRead;
  wire                when_BmbSlaveFactory_l33;
  wire                when_BmbSlaveFactory_l35;
  reg                 doUnschedule;
  reg                 doSoftReset;
  wire                when_UsbOhci_l238;
  wire       [4:0]    reg_hcRevision_REV;
  reg        [1:0]    reg_hcControl_CBSR;
  reg                 reg_hcControl_PLE;
  reg                 reg_hcControl_IE;
  reg                 reg_hcControl_CLE;
  reg                 reg_hcControl_BLE;
  reg        [1:0]    reg_hcControl_HCFS;
  reg                 reg_hcControl_IR;
  reg                 reg_hcControl_RWC;
  reg                 reg_hcControl_RWE;
  reg                 reg_hcControl_HCFSWrite_valid;
  wire       [1:0]    reg_hcControl_HCFSWrite_payload;
  reg                 reg_hcCommandStatus_startSoftReset;
  reg                 when_BusSlaveFactory_l377;
  wire                when_BusSlaveFactory_l379;
  reg                 reg_hcCommandStatus_CLF;
  reg                 when_BusSlaveFactory_l377_1;
  wire                when_BusSlaveFactory_l379_1;
  reg                 reg_hcCommandStatus_BLF;
  reg                 when_BusSlaveFactory_l377_2;
  wire                when_BusSlaveFactory_l379_2;
  reg                 reg_hcCommandStatus_OCR;
  reg                 when_BusSlaveFactory_l377_3;
  wire                when_BusSlaveFactory_l379_3;
  reg        [1:0]    reg_hcCommandStatus_SOC;
  reg                 reg_hcInterrupt_unmaskedPending;
  reg                 reg_hcInterrupt_MIE;
  reg                 when_BusSlaveFactory_l377_4;
  wire                when_BusSlaveFactory_l379_4;
  reg                 when_BusSlaveFactory_l341;
  wire                when_BusSlaveFactory_l347;
  reg                 reg_hcInterrupt_SO_status;
  reg                 when_BusSlaveFactory_l341_1;
  wire                when_BusSlaveFactory_l347_1;
  reg                 reg_hcInterrupt_SO_enable;
  reg                 when_BusSlaveFactory_l377_5;
  wire                when_BusSlaveFactory_l379_5;
  reg                 when_BusSlaveFactory_l341_2;
  wire                when_BusSlaveFactory_l347_2;
  wire                when_UsbOhci_l304;
  reg                 reg_hcInterrupt_WDH_status;
  reg                 when_BusSlaveFactory_l341_3;
  wire                when_BusSlaveFactory_l347_3;
  reg                 reg_hcInterrupt_WDH_enable;
  reg                 when_BusSlaveFactory_l377_6;
  wire                when_BusSlaveFactory_l379_6;
  reg                 when_BusSlaveFactory_l341_4;
  wire                when_BusSlaveFactory_l347_4;
  wire                when_UsbOhci_l304_1;
  reg                 reg_hcInterrupt_SF_status;
  reg                 when_BusSlaveFactory_l341_5;
  wire                when_BusSlaveFactory_l347_5;
  reg                 reg_hcInterrupt_SF_enable;
  reg                 when_BusSlaveFactory_l377_7;
  wire                when_BusSlaveFactory_l379_7;
  reg                 when_BusSlaveFactory_l341_6;
  wire                when_BusSlaveFactory_l347_6;
  wire                when_UsbOhci_l304_2;
  reg                 reg_hcInterrupt_RD_status;
  reg                 when_BusSlaveFactory_l341_7;
  wire                when_BusSlaveFactory_l347_7;
  reg                 reg_hcInterrupt_RD_enable;
  reg                 when_BusSlaveFactory_l377_8;
  wire                when_BusSlaveFactory_l379_8;
  reg                 when_BusSlaveFactory_l341_8;
  wire                when_BusSlaveFactory_l347_8;
  wire                when_UsbOhci_l304_3;
  reg                 reg_hcInterrupt_UE_status;
  reg                 when_BusSlaveFactory_l341_9;
  wire                when_BusSlaveFactory_l347_9;
  reg                 reg_hcInterrupt_UE_enable;
  reg                 when_BusSlaveFactory_l377_9;
  wire                when_BusSlaveFactory_l379_9;
  reg                 when_BusSlaveFactory_l341_10;
  wire                when_BusSlaveFactory_l347_10;
  wire                when_UsbOhci_l304_4;
  reg                 reg_hcInterrupt_FNO_status;
  reg                 when_BusSlaveFactory_l341_11;
  wire                when_BusSlaveFactory_l347_11;
  reg                 reg_hcInterrupt_FNO_enable;
  reg                 when_BusSlaveFactory_l377_10;
  wire                when_BusSlaveFactory_l379_10;
  reg                 when_BusSlaveFactory_l341_12;
  wire                when_BusSlaveFactory_l347_12;
  wire                when_UsbOhci_l304_5;
  reg                 reg_hcInterrupt_RHSC_status;
  reg                 when_BusSlaveFactory_l341_13;
  wire                when_BusSlaveFactory_l347_13;
  reg                 reg_hcInterrupt_RHSC_enable;
  reg                 when_BusSlaveFactory_l377_11;
  wire                when_BusSlaveFactory_l379_11;
  reg                 when_BusSlaveFactory_l341_14;
  wire                when_BusSlaveFactory_l347_14;
  wire                when_UsbOhci_l304_6;
  reg                 reg_hcInterrupt_OC_status;
  reg                 when_BusSlaveFactory_l341_15;
  wire                when_BusSlaveFactory_l347_15;
  reg                 reg_hcInterrupt_OC_enable;
  reg                 when_BusSlaveFactory_l377_12;
  wire                when_BusSlaveFactory_l379_12;
  reg                 when_BusSlaveFactory_l341_16;
  wire                when_BusSlaveFactory_l347_16;
  wire                reg_hcInterrupt_doIrq;
  wire       [31:0]   reg_hcHCCA_HCCA_address;
  reg        [23:0]   reg_hcHCCA_HCCA_reg;
  wire       [31:0]   reg_hcPeriodCurrentED_PCED_address;
  reg        [27:0]   reg_hcPeriodCurrentED_PCED_reg;
  wire                reg_hcPeriodCurrentED_isZero;
  wire       [31:0]   reg_hcControlHeadED_CHED_address;
  reg        [27:0]   reg_hcControlHeadED_CHED_reg;
  wire       [31:0]   reg_hcControlCurrentED_CCED_address;
  reg        [27:0]   reg_hcControlCurrentED_CCED_reg;
  wire                reg_hcControlCurrentED_isZero;
  wire       [31:0]   reg_hcBulkHeadED_BHED_address;
  reg        [27:0]   reg_hcBulkHeadED_BHED_reg;
  wire       [31:0]   reg_hcBulkCurrentED_BCED_address;
  reg        [27:0]   reg_hcBulkCurrentED_BCED_reg;
  wire                reg_hcBulkCurrentED_isZero;
  wire       [31:0]   reg_hcDoneHead_DH_address;
  reg        [27:0]   reg_hcDoneHead_DH_reg;
  reg        [13:0]   reg_hcFmInterval_FI;
  reg        [14:0]   reg_hcFmInterval_FSMPS;
  reg                 reg_hcFmInterval_FIT;
  reg        [13:0]   reg_hcFmRemaining_FR;
  reg                 reg_hcFmRemaining_FRT;
  reg        [15:0]   reg_hcFmNumber_FN;
  reg                 reg_hcFmNumber_overflow;
  wire       [15:0]   reg_hcFmNumber_FNp1;
  reg        [13:0]   reg_hcPeriodicStart_PS;
  reg        [11:0]   reg_hcLSThreshold_LST;
  wire                reg_hcLSThreshold_hit;
  wire       [7:0]    reg_hcRhDescriptorA_NDP;
  reg                 reg_hcRhDescriptorA_PSM;
  reg                 reg_hcRhDescriptorA_NPS;
  reg                 reg_hcRhDescriptorA_OCPM;
  reg                 reg_hcRhDescriptorA_NOCP;
  reg        [7:0]    reg_hcRhDescriptorA_POTPGT;
  reg        [3:0]    reg_hcRhDescriptorB_DR;
  reg        [3:0]    reg_hcRhDescriptorB_PPCM;
  reg                 reg_hcRhStatus_DRWE;
  reg                 reg_hcRhStatus_CCIC;
  reg                 when_BusSlaveFactory_l341_17;
  wire                when_BusSlaveFactory_l347_17;
  reg                 io_phy_overcurrent_regNext;
  wire                when_UsbOhci_l411;
  reg                 reg_hcRhStatus_clearGlobalPower;
  reg                 when_BusSlaveFactory_l377_13;
  wire                when_BusSlaveFactory_l379_13;
  reg                 reg_hcRhStatus_setRemoteWakeupEnable;
  reg                 when_BusSlaveFactory_l377_14;
  wire                when_BusSlaveFactory_l379_14;
  reg                 reg_hcRhStatus_setGlobalPower;
  reg                 when_BusSlaveFactory_l377_15;
  wire                when_BusSlaveFactory_l379_15;
  reg                 reg_hcRhStatus_clearRemoteWakeupEnable;
  reg                 when_BusSlaveFactory_l377_16;
  wire                when_BusSlaveFactory_l379_16;
  reg                 reg_hcRhPortStatus_0_clearPortEnable;
  reg                 when_BusSlaveFactory_l377_17;
  wire                when_BusSlaveFactory_l379_17;
  reg                 reg_hcRhPortStatus_0_setPortEnable;
  reg                 when_BusSlaveFactory_l377_18;
  wire                when_BusSlaveFactory_l379_18;
  reg                 reg_hcRhPortStatus_0_setPortSuspend;
  reg                 when_BusSlaveFactory_l377_19;
  wire                when_BusSlaveFactory_l379_19;
  reg                 reg_hcRhPortStatus_0_clearSuspendStatus;
  reg                 when_BusSlaveFactory_l377_20;
  wire                when_BusSlaveFactory_l379_20;
  reg                 reg_hcRhPortStatus_0_setPortReset;
  reg                 when_BusSlaveFactory_l377_21;
  wire                when_BusSlaveFactory_l379_21;
  reg                 reg_hcRhPortStatus_0_setPortPower;
  reg                 when_BusSlaveFactory_l377_22;
  wire                when_BusSlaveFactory_l379_22;
  reg                 reg_hcRhPortStatus_0_clearPortPower;
  reg                 when_BusSlaveFactory_l377_23;
  wire                when_BusSlaveFactory_l379_23;
  reg                 reg_hcRhPortStatus_0_resume;
  reg                 reg_hcRhPortStatus_0_reset;
  reg                 reg_hcRhPortStatus_0_suspend;
  reg                 reg_hcRhPortStatus_0_connected;
  reg                 reg_hcRhPortStatus_0_PSS;
  reg                 reg_hcRhPortStatus_0_PPS;
  wire                reg_hcRhPortStatus_0_CCS;
  reg                 reg_hcRhPortStatus_0_PES;
  wire                reg_hcRhPortStatus_0_CSC_set;
  reg                 reg_hcRhPortStatus_0_CSC_clear;
  reg                 reg_hcRhPortStatus_0_CSC_reg;
  reg                 when_BusSlaveFactory_l377_24;
  wire                when_BusSlaveFactory_l379_24;
  wire                reg_hcRhPortStatus_0_PESC_set;
  reg                 reg_hcRhPortStatus_0_PESC_clear;
  reg                 reg_hcRhPortStatus_0_PESC_reg;
  reg                 when_BusSlaveFactory_l377_25;
  wire                when_BusSlaveFactory_l379_25;
  wire                reg_hcRhPortStatus_0_PSSC_set;
  reg                 reg_hcRhPortStatus_0_PSSC_clear;
  reg                 reg_hcRhPortStatus_0_PSSC_reg;
  reg                 when_BusSlaveFactory_l377_26;
  wire                when_BusSlaveFactory_l379_26;
  wire                reg_hcRhPortStatus_0_OCIC_set;
  reg                 reg_hcRhPortStatus_0_OCIC_clear;
  reg                 reg_hcRhPortStatus_0_OCIC_reg;
  reg                 when_BusSlaveFactory_l377_27;
  wire                when_BusSlaveFactory_l379_27;
  wire                reg_hcRhPortStatus_0_PRSC_set;
  reg                 reg_hcRhPortStatus_0_PRSC_clear;
  reg                 reg_hcRhPortStatus_0_PRSC_reg;
  reg                 when_BusSlaveFactory_l377_28;
  wire                when_BusSlaveFactory_l379_28;
  wire                when_UsbOhci_l462;
  wire                when_UsbOhci_l462_1;
  wire                when_UsbOhci_l462_2;
  wire                when_UsbOhci_l463;
  wire                when_UsbOhci_l463_1;
  wire                when_UsbOhci_l464;
  wire                when_UsbOhci_l465;
  wire                when_UsbOhci_l466;
  wire                when_UsbOhci_l472;
  reg                 reg_hcRhPortStatus_0_CCS_regNext;
  wire                io_phy_ports_0_suspend_fire;
  wire                io_phy_ports_0_reset_fire;
  wire                io_phy_ports_0_resume_fire;
  reg                 reg_hcRhPortStatus_1_clearPortEnable;
  reg                 when_BusSlaveFactory_l377_29;
  wire                when_BusSlaveFactory_l379_29;
  reg                 reg_hcRhPortStatus_1_setPortEnable;
  reg                 when_BusSlaveFactory_l377_30;
  wire                when_BusSlaveFactory_l379_30;
  reg                 reg_hcRhPortStatus_1_setPortSuspend;
  reg                 when_BusSlaveFactory_l377_31;
  wire                when_BusSlaveFactory_l379_31;
  reg                 reg_hcRhPortStatus_1_clearSuspendStatus;
  reg                 when_BusSlaveFactory_l377_32;
  wire                when_BusSlaveFactory_l379_32;
  reg                 reg_hcRhPortStatus_1_setPortReset;
  reg                 when_BusSlaveFactory_l377_33;
  wire                when_BusSlaveFactory_l379_33;
  reg                 reg_hcRhPortStatus_1_setPortPower;
  reg                 when_BusSlaveFactory_l377_34;
  wire                when_BusSlaveFactory_l379_34;
  reg                 reg_hcRhPortStatus_1_clearPortPower;
  reg                 when_BusSlaveFactory_l377_35;
  wire                when_BusSlaveFactory_l379_35;
  reg                 reg_hcRhPortStatus_1_resume;
  reg                 reg_hcRhPortStatus_1_reset;
  reg                 reg_hcRhPortStatus_1_suspend;
  reg                 reg_hcRhPortStatus_1_connected;
  reg                 reg_hcRhPortStatus_1_PSS;
  reg                 reg_hcRhPortStatus_1_PPS;
  wire                reg_hcRhPortStatus_1_CCS;
  reg                 reg_hcRhPortStatus_1_PES;
  wire                reg_hcRhPortStatus_1_CSC_set;
  reg                 reg_hcRhPortStatus_1_CSC_clear;
  reg                 reg_hcRhPortStatus_1_CSC_reg;
  reg                 when_BusSlaveFactory_l377_36;
  wire                when_BusSlaveFactory_l379_36;
  wire                reg_hcRhPortStatus_1_PESC_set;
  reg                 reg_hcRhPortStatus_1_PESC_clear;
  reg                 reg_hcRhPortStatus_1_PESC_reg;
  reg                 when_BusSlaveFactory_l377_37;
  wire                when_BusSlaveFactory_l379_37;
  wire                reg_hcRhPortStatus_1_PSSC_set;
  reg                 reg_hcRhPortStatus_1_PSSC_clear;
  reg                 reg_hcRhPortStatus_1_PSSC_reg;
  reg                 when_BusSlaveFactory_l377_38;
  wire                when_BusSlaveFactory_l379_38;
  wire                reg_hcRhPortStatus_1_OCIC_set;
  reg                 reg_hcRhPortStatus_1_OCIC_clear;
  reg                 reg_hcRhPortStatus_1_OCIC_reg;
  reg                 when_BusSlaveFactory_l377_39;
  wire                when_BusSlaveFactory_l379_39;
  wire                reg_hcRhPortStatus_1_PRSC_set;
  reg                 reg_hcRhPortStatus_1_PRSC_clear;
  reg                 reg_hcRhPortStatus_1_PRSC_reg;
  reg                 when_BusSlaveFactory_l377_40;
  wire                when_BusSlaveFactory_l379_40;
  wire                when_UsbOhci_l462_3;
  wire                when_UsbOhci_l462_4;
  wire                when_UsbOhci_l462_5;
  wire                when_UsbOhci_l463_2;
  wire                when_UsbOhci_l463_3;
  wire                when_UsbOhci_l464_1;
  wire                when_UsbOhci_l465_1;
  wire                when_UsbOhci_l466_1;
  wire                when_UsbOhci_l472_1;
  reg                 reg_hcRhPortStatus_1_CCS_regNext;
  wire                io_phy_ports_1_suspend_fire;
  wire                io_phy_ports_1_reset_fire;
  wire                io_phy_ports_1_resume_fire;
  reg                 reg_hcRhPortStatus_2_clearPortEnable;
  reg                 when_BusSlaveFactory_l377_41;
  wire                when_BusSlaveFactory_l379_41;
  reg                 reg_hcRhPortStatus_2_setPortEnable;
  reg                 when_BusSlaveFactory_l377_42;
  wire                when_BusSlaveFactory_l379_42;
  reg                 reg_hcRhPortStatus_2_setPortSuspend;
  reg                 when_BusSlaveFactory_l377_43;
  wire                when_BusSlaveFactory_l379_43;
  reg                 reg_hcRhPortStatus_2_clearSuspendStatus;
  reg                 when_BusSlaveFactory_l377_44;
  wire                when_BusSlaveFactory_l379_44;
  reg                 reg_hcRhPortStatus_2_setPortReset;
  reg                 when_BusSlaveFactory_l377_45;
  wire                when_BusSlaveFactory_l379_45;
  reg                 reg_hcRhPortStatus_2_setPortPower;
  reg                 when_BusSlaveFactory_l377_46;
  wire                when_BusSlaveFactory_l379_46;
  reg                 reg_hcRhPortStatus_2_clearPortPower;
  reg                 when_BusSlaveFactory_l377_47;
  wire                when_BusSlaveFactory_l379_47;
  reg                 reg_hcRhPortStatus_2_resume;
  reg                 reg_hcRhPortStatus_2_reset;
  reg                 reg_hcRhPortStatus_2_suspend;
  reg                 reg_hcRhPortStatus_2_connected;
  reg                 reg_hcRhPortStatus_2_PSS;
  reg                 reg_hcRhPortStatus_2_PPS;
  wire                reg_hcRhPortStatus_2_CCS;
  reg                 reg_hcRhPortStatus_2_PES;
  wire                reg_hcRhPortStatus_2_CSC_set;
  reg                 reg_hcRhPortStatus_2_CSC_clear;
  reg                 reg_hcRhPortStatus_2_CSC_reg;
  reg                 when_BusSlaveFactory_l377_48;
  wire                when_BusSlaveFactory_l379_48;
  wire                reg_hcRhPortStatus_2_PESC_set;
  reg                 reg_hcRhPortStatus_2_PESC_clear;
  reg                 reg_hcRhPortStatus_2_PESC_reg;
  reg                 when_BusSlaveFactory_l377_49;
  wire                when_BusSlaveFactory_l379_49;
  wire                reg_hcRhPortStatus_2_PSSC_set;
  reg                 reg_hcRhPortStatus_2_PSSC_clear;
  reg                 reg_hcRhPortStatus_2_PSSC_reg;
  reg                 when_BusSlaveFactory_l377_50;
  wire                when_BusSlaveFactory_l379_50;
  wire                reg_hcRhPortStatus_2_OCIC_set;
  reg                 reg_hcRhPortStatus_2_OCIC_clear;
  reg                 reg_hcRhPortStatus_2_OCIC_reg;
  reg                 when_BusSlaveFactory_l377_51;
  wire                when_BusSlaveFactory_l379_51;
  wire                reg_hcRhPortStatus_2_PRSC_set;
  reg                 reg_hcRhPortStatus_2_PRSC_clear;
  reg                 reg_hcRhPortStatus_2_PRSC_reg;
  reg                 when_BusSlaveFactory_l377_52;
  wire                when_BusSlaveFactory_l379_52;
  wire                when_UsbOhci_l462_6;
  wire                when_UsbOhci_l462_7;
  wire                when_UsbOhci_l462_8;
  wire                when_UsbOhci_l463_4;
  wire                when_UsbOhci_l463_5;
  wire                when_UsbOhci_l464_2;
  wire                when_UsbOhci_l465_2;
  wire                when_UsbOhci_l466_2;
  wire                when_UsbOhci_l472_2;
  reg                 reg_hcRhPortStatus_2_CCS_regNext;
  wire                io_phy_ports_2_suspend_fire;
  wire                io_phy_ports_2_reset_fire;
  wire                io_phy_ports_2_resume_fire;
  reg                 reg_hcRhPortStatus_3_clearPortEnable;
  reg                 when_BusSlaveFactory_l377_53;
  wire                when_BusSlaveFactory_l379_53;
  reg                 reg_hcRhPortStatus_3_setPortEnable;
  reg                 when_BusSlaveFactory_l377_54;
  wire                when_BusSlaveFactory_l379_54;
  reg                 reg_hcRhPortStatus_3_setPortSuspend;
  reg                 when_BusSlaveFactory_l377_55;
  wire                when_BusSlaveFactory_l379_55;
  reg                 reg_hcRhPortStatus_3_clearSuspendStatus;
  reg                 when_BusSlaveFactory_l377_56;
  wire                when_BusSlaveFactory_l379_56;
  reg                 reg_hcRhPortStatus_3_setPortReset;
  reg                 when_BusSlaveFactory_l377_57;
  wire                when_BusSlaveFactory_l379_57;
  reg                 reg_hcRhPortStatus_3_setPortPower;
  reg                 when_BusSlaveFactory_l377_58;
  wire                when_BusSlaveFactory_l379_58;
  reg                 reg_hcRhPortStatus_3_clearPortPower;
  reg                 when_BusSlaveFactory_l377_59;
  wire                when_BusSlaveFactory_l379_59;
  reg                 reg_hcRhPortStatus_3_resume;
  reg                 reg_hcRhPortStatus_3_reset;
  reg                 reg_hcRhPortStatus_3_suspend;
  reg                 reg_hcRhPortStatus_3_connected;
  reg                 reg_hcRhPortStatus_3_PSS;
  reg                 reg_hcRhPortStatus_3_PPS;
  wire                reg_hcRhPortStatus_3_CCS;
  reg                 reg_hcRhPortStatus_3_PES;
  wire                reg_hcRhPortStatus_3_CSC_set;
  reg                 reg_hcRhPortStatus_3_CSC_clear;
  reg                 reg_hcRhPortStatus_3_CSC_reg;
  reg                 when_BusSlaveFactory_l377_60;
  wire                when_BusSlaveFactory_l379_60;
  wire                reg_hcRhPortStatus_3_PESC_set;
  reg                 reg_hcRhPortStatus_3_PESC_clear;
  reg                 reg_hcRhPortStatus_3_PESC_reg;
  reg                 when_BusSlaveFactory_l377_61;
  wire                when_BusSlaveFactory_l379_61;
  wire                reg_hcRhPortStatus_3_PSSC_set;
  reg                 reg_hcRhPortStatus_3_PSSC_clear;
  reg                 reg_hcRhPortStatus_3_PSSC_reg;
  reg                 when_BusSlaveFactory_l377_62;
  wire                when_BusSlaveFactory_l379_62;
  wire                reg_hcRhPortStatus_3_OCIC_set;
  reg                 reg_hcRhPortStatus_3_OCIC_clear;
  reg                 reg_hcRhPortStatus_3_OCIC_reg;
  reg                 when_BusSlaveFactory_l377_63;
  wire                when_BusSlaveFactory_l379_63;
  wire                reg_hcRhPortStatus_3_PRSC_set;
  reg                 reg_hcRhPortStatus_3_PRSC_clear;
  reg                 reg_hcRhPortStatus_3_PRSC_reg;
  reg                 when_BusSlaveFactory_l377_64;
  wire                when_BusSlaveFactory_l379_64;
  wire                when_UsbOhci_l462_9;
  wire                when_UsbOhci_l462_10;
  wire                when_UsbOhci_l462_11;
  wire                when_UsbOhci_l463_6;
  wire                when_UsbOhci_l463_7;
  wire                when_UsbOhci_l464_3;
  wire                when_UsbOhci_l465_3;
  wire                when_UsbOhci_l466_3;
  wire                when_UsbOhci_l472_3;
  reg                 reg_hcRhPortStatus_3_CCS_regNext;
  wire                io_phy_ports_3_suspend_fire;
  wire                io_phy_ports_3_reset_fire;
  wire                io_phy_ports_3_resume_fire;
  reg                 frame_run;
  reg                 frame_reload;
  wire                frame_overflow;
  reg                 frame_tick;
  wire                frame_section1;
  reg        [14:0]   frame_limitCounter;
  wire                frame_limitHit;
  reg        [2:0]    frame_decrementTimer;
  wire                frame_decrementTimerOverflow;
  wire                when_UsbOhci_l528;
  wire                when_UsbOhci_l530;
  wire                when_UsbOhci_l542;
  reg                 token_wantExit;
  reg                 token_wantStart;
  reg                 token_wantKill;
  reg        [3:0]    token_pid;
  reg        [10:0]   token_data;
  reg                 dataTx_wantExit;
  reg                 dataTx_wantStart;
  reg                 dataTx_wantKill;
  reg        [3:0]    dataTx_pid;
  reg                 dataTx_data_valid;
  reg                 dataTx_data_ready;
  reg                 dataTx_data_payload_last;
  reg        [7:0]    dataTx_data_payload_fragment;
  wire                dataTx_data_fire;
  wire                rxTimer_lowSpeed;
  reg        [7:0]    rxTimer_counter;
  reg                 rxTimer_clear;
  wire                rxTimer_rxTimeout;
  wire                rxTimer_ackTx;
  wire                rxPidOk;
  wire                _zz_1;
  wire       [7:0]    _zz_dataRx_pid;
  wire                when_Misc_l87;
  reg                 dataRx_wantExit;
  reg                 dataRx_wantStart;
  reg                 dataRx_wantKill;
  reg        [3:0]    dataRx_pid;
  reg                 dataRx_data_valid;
  wire       [7:0]    dataRx_data_payload;
  wire       [7:0]    dataRx_history_0;
  wire       [7:0]    dataRx_history_1;
  reg        [7:0]    _zz_dataRx_history_0;
  reg        [7:0]    _zz_dataRx_history_1;
  reg        [1:0]    dataRx_valids;
  reg                 dataRx_notResponding;
  reg                 dataRx_stuffingError;
  reg                 dataRx_pidError;
  reg                 dataRx_crcError;
  wire                dataRx_hasError;
  reg                 sof_wantExit;
  reg                 sof_wantStart;
  reg                 sof_wantKill;
  reg                 sof_doInterruptDelay;
  reg                 priority_bulk;
  reg        [1:0]    priority_counter;
  reg                 priority_tick;
  reg                 priority_skip;
  wire                when_UsbOhci_l665;
  reg        [2:0]    interruptDelay_counter;
  reg                 interruptDelay_tick;
  wire                interruptDelay_done;
  wire                interruptDelay_disabled;
  reg                 interruptDelay_disable;
  reg                 interruptDelay_load_valid;
  reg        [2:0]    interruptDelay_load_payload;
  wire                when_UsbOhci_l687;
  wire                when_UsbOhci_l691;
  reg                 endpoint_wantExit;
  reg                 endpoint_wantStart;
  reg                 endpoint_wantKill;
  reg        [1:0]    endpoint_flowType;
  reg        [0:0]    endpoint_status_1;
  reg                 endpoint_dataPhase;
  reg        [31:0]   endpoint_ED_address;
  reg        [31:0]   endpoint_ED_words_0;
  reg        [31:0]   endpoint_ED_words_1;
  reg        [31:0]   endpoint_ED_words_2;
  reg        [31:0]   endpoint_ED_words_3;
  wire       [6:0]    endpoint_ED_FA;
  wire       [3:0]    endpoint_ED_EN;
  wire       [1:0]    endpoint_ED_D;
  wire                endpoint_ED_S;
  wire                endpoint_ED_K;
  wire                endpoint_ED_F;
  wire       [10:0]   endpoint_ED_MPS;
  wire       [27:0]   endpoint_ED_tailP;
  wire                endpoint_ED_H;
  wire                endpoint_ED_C;
  wire       [27:0]   endpoint_ED_headP;
  wire       [27:0]   endpoint_ED_nextED;
  wire                endpoint_ED_tdEmpty;
  wire                endpoint_ED_isFs;
  wire                endpoint_ED_isoOut;
  wire                when_UsbOhci_l752;
  wire       [31:0]   endpoint_TD_address;
  reg        [31:0]   endpoint_TD_words_0;
  reg        [31:0]   endpoint_TD_words_1;
  reg        [31:0]   endpoint_TD_words_2;
  reg        [31:0]   endpoint_TD_words_3;
  wire       [3:0]    endpoint_TD_CC;
  wire       [1:0]    endpoint_TD_EC;
  wire       [1:0]    endpoint_TD_T;
  wire       [2:0]    endpoint_TD_DI;
  wire       [1:0]    endpoint_TD_DP;
  wire                endpoint_TD_R;
  wire       [31:0]   endpoint_TD_CBP;
  wire       [27:0]   endpoint_TD_nextTD;
  wire       [31:0]   endpoint_TD_BE;
  wire       [2:0]    endpoint_TD_FC;
  wire       [15:0]   endpoint_TD_SF;
  wire       [15:0]   endpoint_TD_isoRelativeFrameNumber;
  wire                endpoint_TD_tooEarly;
  wire       [2:0]    endpoint_TD_isoFrameNumber;
  wire                endpoint_TD_isoOverrun;
  reg                 endpoint_TD_isoOverrunReg;
  wire                endpoint_TD_isoLast;
  reg        [12:0]   endpoint_TD_isoBase;
  reg        [12:0]   endpoint_TD_isoBaseNext;
  reg                 endpoint_TD_isoZero;
  reg                 endpoint_TD_isoLastReg;
  reg                 endpoint_TD_tooEarlyReg;
  wire                endpoint_TD_isSinglePage;
  wire       [12:0]   endpoint_TD_firstOffset;
  reg        [12:0]   endpoint_TD_lastOffset;
  wire                endpoint_TD_allowRounding;
  reg                 endpoint_TD_retire;
  reg                 endpoint_TD_upateCBP;
  reg                 endpoint_TD_noUpdate;
  reg                 endpoint_TD_dataPhaseUpdate;
  wire       [1:0]    endpoint_TD_TNext;
  wire                endpoint_TD_dataPhaseNext;
  wire       [3:0]    endpoint_TD_dataPid;
  wire       [3:0]    endpoint_TD_dataPidWrong;
  reg                 endpoint_TD_clear;
  wire       [1:0]    endpoint_tockenType;
  wire                endpoint_isIn;
  reg                 endpoint_applyNextED;
  reg        [13:0]   endpoint_currentAddress;
  wire       [31:0]   endpoint_currentAddressFull;
  reg        [31:0]   _zz_endpoint_currentAddressBmb;
  wire       [31:0]   endpoint_currentAddressBmb;
  reg        [12:0]   endpoint_lastAddress;
  wire       [13:0]   endpoint_transactionSizeMinusOne;
  wire       [13:0]   endpoint_transactionSize;
  reg                 endpoint_zeroLength;
  wire                endpoint_dataDone;
  reg                 endpoint_dmaLogic_wantExit;
  reg                 endpoint_dmaLogic_wantStart;
  reg                 endpoint_dmaLogic_wantKill;
  reg                 endpoint_dmaLogic_validated;
  reg        [5:0]    endpoint_dmaLogic_length;
  wire       [5:0]    endpoint_dmaLogic_lengthMax;
  wire       [5:0]    endpoint_dmaLogic_lengthCalc;
  wire       [4:0]    endpoint_dmaLogic_beatCount;
  wire       [5:0]    endpoint_dmaLogic_lengthBmb;
  reg        [10:0]   endpoint_dmaLogic_fromUsbCounter;
  reg                 endpoint_dmaLogic_overflow;
  reg                 endpoint_dmaLogic_underflow;
  wire                endpoint_dmaLogic_underflowError;
  wire                when_UsbOhci_l940;
  reg        [12:0]   endpoint_dmaLogic_byteCtx_counter;
  wire                endpoint_dmaLogic_byteCtx_last;
  wire       [1:0]    endpoint_dmaLogic_byteCtx_sel;
  reg                 endpoint_dmaLogic_byteCtx_increment;
  wire       [3:0]    endpoint_dmaLogic_headMask;
  wire       [3:0]    endpoint_dmaLogic_lastMask;
  wire       [3:0]    endpoint_dmaLogic_fullMask;
  wire                endpoint_dmaLogic_beatLast;
  reg        [31:0]   endpoint_dmaLogic_buffer;
  reg                 endpoint_dmaLogic_push;
  wire                endpoint_dmaLogic_fsmStopped;
  wire       [13:0]   endpoint_byteCountCalc;
  wire                endpoint_fsTimeCheck;
  wire                endpoint_timeCheck;
  reg                 endpoint_ackRxFired;
  reg                 endpoint_ackRxActivated;
  reg                 endpoint_ackRxPidFailure;
  reg                 endpoint_ackRxStuffing;
  reg        [3:0]    endpoint_ackRxPid;
  wire       [31:0]   endpoint_tdUpdateAddress;
  reg                 operational_wantExit;
  reg                 operational_wantStart;
  reg                 operational_wantKill;
  reg                 operational_periodicHeadFetched;
  reg                 operational_periodicDone;
  reg                 operational_allowBulk;
  reg                 operational_allowControl;
  reg                 operational_allowPeriodic;
  reg                 operational_allowIsochronous;
  reg                 operational_askExit;
  wire                hc_wantExit;
  reg                 hc_wantStart;
  wire                hc_wantKill;
  reg                 hc_error;
  wire                hc_operationalIsDone;
  wire       [1:0]    _zz_reg_hcControl_HCFSWrite_payload;
  wire                when_BusSlaveFactory_l1041;
  wire                when_BusSlaveFactory_l1041_1;
  wire                when_BusSlaveFactory_l1041_2;
  wire                when_BusSlaveFactory_l1041_3;
  wire                when_BusSlaveFactory_l1041_4;
  wire                when_BusSlaveFactory_l1041_5;
  wire                when_BusSlaveFactory_l1041_6;
  wire                when_BusSlaveFactory_l1041_7;
  wire                when_BusSlaveFactory_l1041_8;
  wire                when_BusSlaveFactory_l1041_9;
  wire                when_BusSlaveFactory_l1041_10;
  wire                when_BusSlaveFactory_l1041_11;
  wire                when_BusSlaveFactory_l1041_12;
  wire                when_BusSlaveFactory_l1041_13;
  wire                when_BusSlaveFactory_l1041_14;
  wire                when_BusSlaveFactory_l1041_15;
  wire                when_BusSlaveFactory_l1041_16;
  wire                when_BusSlaveFactory_l1041_17;
  wire                when_BusSlaveFactory_l1041_18;
  wire                when_BusSlaveFactory_l1041_19;
  wire                when_BusSlaveFactory_l1041_20;
  wire                when_BusSlaveFactory_l1041_21;
  wire                when_BusSlaveFactory_l1041_22;
  wire                when_BusSlaveFactory_l1041_23;
  wire                when_BusSlaveFactory_l1041_24;
  wire                when_BusSlaveFactory_l1041_25;
  wire                when_BusSlaveFactory_l1041_26;
  wire                when_BusSlaveFactory_l1041_27;
  wire                when_BusSlaveFactory_l1041_28;
  wire                when_BusSlaveFactory_l1041_29;
  wire                when_BusSlaveFactory_l1041_30;
  wire                when_BusSlaveFactory_l1041_31;
  wire                when_BusSlaveFactory_l1041_32;
  wire                when_BusSlaveFactory_l1041_33;
  wire                when_BusSlaveFactory_l1041_34;
  wire                when_BusSlaveFactory_l1041_35;
  wire                when_BusSlaveFactory_l1041_36;
  wire                when_BusSlaveFactory_l1041_37;
  wire                when_BusSlaveFactory_l1041_38;
  wire                when_BusSlaveFactory_l1041_39;
  wire                when_BusSlaveFactory_l1041_40;
  wire                when_BusSlaveFactory_l1041_41;
  wire                when_BusSlaveFactory_l1041_42;
  wire                when_BusSlaveFactory_l1041_43;
  wire                when_BusSlaveFactory_l1041_44;
  wire                when_BusSlaveFactory_l1041_45;
  wire                when_BusSlaveFactory_l1041_46;
  reg                 _zz_when_UsbOhci_l255;
  wire                when_UsbOhci_l255;
  reg        [2:0]    token_stateReg;
  reg        [2:0]    token_stateNext;
  wire                when_StateMachine_l237;
  wire                unscheduleAll_fire;
  reg        [2:0]    dataTx_stateReg;
  reg        [2:0]    dataTx_stateNext;
  reg        [1:0]    dataRx_stateReg;
  reg        [1:0]    dataRx_stateNext;
  wire                when_Misc_l64;
  wire                when_Misc_l70;
  wire                when_Misc_l71;
  wire                when_Misc_l78;
  wire                when_StateMachine_l253;
  wire                when_Misc_l85;
  reg        [1:0]    sof_stateReg;
  reg        [1:0]    sof_stateNext;
  wire                when_UsbOhci_l207;
  wire                when_UsbOhci_l207_1;
  wire                when_UsbOhci_l628;
  wire                when_StateMachine_l237_1;
  reg        [4:0]    endpoint_stateReg;
  reg        [4:0]    endpoint_stateNext;
  wire                when_UsbOhci_l1130;
  wire                when_UsbOhci_l1313;
  wire                when_UsbOhci_l189;
  wire                when_UsbOhci_l189_1;
  wire                when_UsbOhci_l189_2;
  wire                when_UsbOhci_l189_3;
  wire                when_UsbOhci_l857;
  wire                when_UsbOhci_l863;
  wire                when_UsbOhci_l189_4;
  wire                when_UsbOhci_l189_5;
  wire                when_UsbOhci_l189_6;
  wire                when_UsbOhci_l189_7;
  wire                when_UsbOhci_l893;
  wire                when_UsbOhci_l189_8;
  wire                when_UsbOhci_l189_9;
  wire                when_UsbOhci_l893_1;
  wire                when_UsbOhci_l189_10;
  wire                when_UsbOhci_l189_11;
  wire                when_UsbOhci_l893_2;
  wire                when_UsbOhci_l189_12;
  wire                when_UsbOhci_l189_13;
  wire                when_UsbOhci_l893_3;
  wire                when_UsbOhci_l189_14;
  wire                when_UsbOhci_l189_15;
  wire                when_UsbOhci_l893_4;
  wire                when_UsbOhci_l189_16;
  wire                when_UsbOhci_l189_17;
  wire                when_UsbOhci_l893_5;
  wire                when_UsbOhci_l189_18;
  wire                when_UsbOhci_l189_19;
  wire                when_UsbOhci_l893_6;
  wire                when_UsbOhci_l189_20;
  wire                when_UsbOhci_l189_21;
  wire                when_UsbOhci_l893_7;
  wire                when_UsbOhci_l189_22;
  wire                when_UsbOhci_l900;
  wire       [13:0]   _zz_endpoint_lastAddress;
  wire                when_UsbOhci_l1120;
  reg                 when_UsbOhci_l1276;
  wire                when_UsbOhci_l1265;
  wire                when_UsbOhci_l1285;
  wire                when_UsbOhci_l1202;
  wire                when_UsbOhci_l1207;
  wire                when_UsbOhci_l1209;
  wire                when_UsbOhci_l1333;
  wire                when_UsbOhci_l1348;
  wire                when_UsbOhci_l207_2;
  wire                when_UsbOhci_l207_3;
  wire       [15:0]   _zz_ioDma_cmd_payload_fragment_data;
  wire                when_UsbOhci_l1380;
  wire                when_UsbOhci_l207_4;
  wire                when_UsbOhci_l1380_1;
  wire                when_UsbOhci_l207_5;
  wire                when_UsbOhci_l1380_2;
  wire                when_UsbOhci_l207_6;
  wire                when_UsbOhci_l1380_3;
  wire                when_UsbOhci_l207_7;
  wire                when_UsbOhci_l1380_4;
  wire                when_UsbOhci_l207_8;
  wire                when_UsbOhci_l1380_5;
  wire                when_UsbOhci_l207_9;
  wire                when_UsbOhci_l1380_6;
  wire                when_UsbOhci_l207_10;
  wire                when_UsbOhci_l1380_7;
  wire                when_UsbOhci_l207_11;
  wire                when_UsbOhci_l207_12;
  wire                when_UsbOhci_l207_13;
  wire                when_UsbOhci_l207_14;
  wire                when_UsbOhci_l1395;
  wire                when_UsbOhci_l207_15;
  wire                when_UsbOhci_l1410;
  wire                when_UsbOhci_l1417;
  wire                when_UsbOhci_l1420;
  wire                when_StateMachine_l237_2;
  wire                when_StateMachine_l253_1;
  wire                when_StateMachine_l253_2;
  wire                when_StateMachine_l253_3;
  wire                when_StateMachine_l253_4;
  reg        [2:0]    endpoint_dmaLogic_stateReg;
  reg        [2:0]    endpoint_dmaLogic_stateNext;
  wire                when_UsbOhci_l1027;
  wire                when_UsbOhci_l1056;
  wire       [3:0]    _zz_2;
  wire                when_UsbOhci_l1065;
  wire                when_UsbOhci_l1070;
  reg                 ioDma_cmd_payload_first;
  wire                when_StateMachine_l253_5;
  reg        [2:0]    operational_stateReg;
  reg        [2:0]    operational_stateNext;
  wire                when_UsbOhci_l1463;
  wire                when_UsbOhci_l1490;
  wire                when_UsbOhci_l1489;
  wire                when_StateMachine_l237_3;
  wire                when_StateMachine_l253_6;
  reg        [2:0]    hc_stateReg;
  reg        [2:0]    hc_stateNext;
  wire                when_UsbOhci_l1618;
  wire                when_UsbOhci_l1627;
  wire                when_UsbOhci_l1630;
  wire                when_UsbOhci_l1641;
  wire                when_UsbOhci_l1654;
  wire                when_StateMachine_l253_7;
  wire                when_StateMachine_l253_8;
  wire                when_StateMachine_l253_9;
  wire                when_UsbOhci_l1661;
  `ifndef SYNTHESIS
  reg [87:0] reg_hcControl_HCFS_string;
  reg [87:0] reg_hcControl_HCFSWrite_payload_string;
  reg [63:0] endpoint_flowType_string;
  reg [79:0] endpoint_status_1_string;
  reg [87:0] _zz_reg_hcControl_HCFSWrite_payload_string;
  reg [31:0] token_stateReg_string;
  reg [31:0] token_stateNext_string;
  reg [39:0] dataTx_stateReg_string;
  reg [39:0] dataTx_stateNext_string;
  reg [31:0] dataRx_stateReg_string;
  reg [31:0] dataRx_stateNext_string;
  reg [127:0] sof_stateReg_string;
  reg [127:0] sof_stateNext_string;
  reg [135:0] endpoint_stateReg_string;
  reg [135:0] endpoint_stateNext_string;
  reg [79:0] endpoint_dmaLogic_stateReg_string;
  reg [79:0] endpoint_dmaLogic_stateNext_string;
  reg [135:0] operational_stateReg_string;
  reg [135:0] operational_stateNext_string;
  reg [111:0] hc_stateReg_string;
  reg [111:0] hc_stateNext_string;
  `endif

  function [31:0] zz__zz_endpoint_currentAddressBmb(input dummy);
    begin
      zz__zz_endpoint_currentAddressBmb = 32'hffffffff;
      zz__zz_endpoint_currentAddressBmb[1 : 0] = 2'b00;
    end
  endfunction
  wire [31:0] _zz_3;

  assign _zz_dmaCtx_pendingCounter = (dmaCtx_pendingCounter + _zz_dmaCtx_pendingCounter_1);
  assign _zz_dmaCtx_pendingCounter_2 = (ioDma_cmd_fire && ioDma_cmd_payload_last);
  assign _zz_dmaCtx_pendingCounter_1 = {3'd0, _zz_dmaCtx_pendingCounter_2};
  assign _zz_dmaCtx_pendingCounter_4 = (ioDma_rsp_fire && ioDma_rsp_payload_last);
  assign _zz_dmaCtx_pendingCounter_3 = {3'd0, _zz_dmaCtx_pendingCounter_4};
  assign _zz_reg_hcCommandStatus_startSoftReset = 1'b1;
  assign _zz_reg_hcCommandStatus_CLF = 1'b1;
  assign _zz_reg_hcCommandStatus_BLF = 1'b1;
  assign _zz_reg_hcCommandStatus_OCR = 1'b1;
  assign _zz_reg_hcInterrupt_MIE = 1'b1;
  assign _zz_reg_hcInterrupt_MIE_1 = 1'b0;
  assign _zz_reg_hcInterrupt_SO_status = 1'b0;
  assign _zz_reg_hcInterrupt_SO_enable = 1'b1;
  assign _zz_reg_hcInterrupt_SO_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_WDH_status = 1'b0;
  assign _zz_reg_hcInterrupt_WDH_enable = 1'b1;
  assign _zz_reg_hcInterrupt_WDH_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_SF_status = 1'b0;
  assign _zz_reg_hcInterrupt_SF_enable = 1'b1;
  assign _zz_reg_hcInterrupt_SF_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_RD_status = 1'b0;
  assign _zz_reg_hcInterrupt_RD_enable = 1'b1;
  assign _zz_reg_hcInterrupt_RD_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_UE_status = 1'b0;
  assign _zz_reg_hcInterrupt_UE_enable = 1'b1;
  assign _zz_reg_hcInterrupt_UE_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_FNO_status = 1'b0;
  assign _zz_reg_hcInterrupt_FNO_enable = 1'b1;
  assign _zz_reg_hcInterrupt_FNO_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_RHSC_status = 1'b0;
  assign _zz_reg_hcInterrupt_RHSC_enable = 1'b1;
  assign _zz_reg_hcInterrupt_RHSC_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_OC_status = 1'b0;
  assign _zz_reg_hcInterrupt_OC_enable = 1'b1;
  assign _zz_reg_hcInterrupt_OC_enable_1 = 1'b0;
  assign _zz_reg_hcLSThreshold_hit = {2'd0, reg_hcLSThreshold_LST};
  assign _zz_reg_hcRhStatus_CCIC = 1'b0;
  assign _zz_reg_hcRhStatus_clearGlobalPower = 1'b1;
  assign _zz_reg_hcRhStatus_setRemoteWakeupEnable = 1'b1;
  assign _zz_reg_hcRhStatus_setGlobalPower = 1'b1;
  assign _zz_reg_hcRhStatus_clearRemoteWakeupEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_clearPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_setPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_setPortSuspend = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_clearSuspendStatus = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_setPortReset = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_setPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_clearPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_CSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_PESC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_PSSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_OCIC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_PRSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_clearPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_setPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_setPortSuspend = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_clearSuspendStatus = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_setPortReset = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_setPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_clearPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_CSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_PESC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_PSSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_OCIC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_PRSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_clearPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_setPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_setPortSuspend = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_clearSuspendStatus = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_setPortReset = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_setPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_clearPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_CSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_PESC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_PSSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_OCIC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_2_PRSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_clearPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_setPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_setPortSuspend = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_clearSuspendStatus = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_setPortReset = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_setPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_clearPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_CSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_PESC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_PSSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_OCIC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_3_PRSC_clear = 1'b1;
  assign _zz_rxTimer_ackTx_1 = (rxTimer_lowSpeed ? 4'b1111 : 4'b0001);
  assign _zz_rxTimer_ackTx = {4'd0, _zz_rxTimer_ackTx_1};
  assign _zz_endpoint_TD_isoOverrun = {13'd0, endpoint_TD_FC};
  assign _zz_endpoint_TD_firstOffset_1 = endpoint_TD_CBP[11 : 0];
  assign _zz_endpoint_TD_firstOffset = {1'd0, _zz_endpoint_TD_firstOffset_1};
  assign _zz_endpoint_TD_lastOffset = (endpoint_TD_isoBaseNext - _zz_endpoint_TD_lastOffset_1);
  assign _zz_endpoint_TD_lastOffset_2 = (! endpoint_TD_isoLast);
  assign _zz_endpoint_TD_lastOffset_1 = {12'd0, _zz_endpoint_TD_lastOffset_2};
  assign _zz_endpoint_transactionSizeMinusOne = {1'd0, endpoint_lastAddress};
  assign _zz_endpoint_dataDone = {1'd0, endpoint_lastAddress};
  assign _zz_endpoint_dmaLogic_lengthMax = endpoint_currentAddress[5:0];
  assign _zz_endpoint_dmaLogic_lengthCalc = ((endpoint_transactionSizeMinusOne < _zz_endpoint_dmaLogic_lengthCalc_1) ? endpoint_transactionSizeMinusOne : _zz_endpoint_dmaLogic_lengthCalc_2);
  assign _zz_endpoint_dmaLogic_lengthCalc_1 = {8'd0, endpoint_dmaLogic_lengthMax};
  assign _zz_endpoint_dmaLogic_lengthCalc_2 = {8'd0, endpoint_dmaLogic_lengthMax};
  assign _zz_endpoint_dmaLogic_beatCount = ({1'b0,endpoint_dmaLogic_length} + _zz_endpoint_dmaLogic_beatCount_1);
  assign _zz_endpoint_dmaLogic_beatCount_2 = endpoint_currentAddressFull[1 : 0];
  assign _zz_endpoint_dmaLogic_beatCount_1 = {5'd0, _zz_endpoint_dmaLogic_beatCount_2};
  assign _zz_endpoint_dmaLogic_lengthBmb = {endpoint_dmaLogic_beatCount,2'b11};
  assign _zz_endpoint_dmaLogic_lastMask = (endpoint_currentAddress + _zz_endpoint_dmaLogic_lastMask_1);
  assign _zz_endpoint_dmaLogic_lastMask_1 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_dmaLogic_lastMask_2 = (endpoint_currentAddress + _zz_endpoint_dmaLogic_lastMask_3);
  assign _zz_endpoint_dmaLogic_lastMask_3 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_dmaLogic_lastMask_4 = (endpoint_currentAddress + _zz_endpoint_dmaLogic_lastMask_5);
  assign _zz_endpoint_dmaLogic_lastMask_5 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_dmaLogic_lastMask_6 = (endpoint_currentAddress + _zz_endpoint_dmaLogic_lastMask_7);
  assign _zz_endpoint_dmaLogic_lastMask_7 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_dmaLogic_beatLast = {1'd0, endpoint_dmaLogic_beatCount};
  assign _zz_endpoint_byteCountCalc = (_zz_endpoint_byteCountCalc_1 - endpoint_currentAddress);
  assign _zz_endpoint_byteCountCalc_1 = {1'd0, endpoint_lastAddress};
  assign _zz_endpoint_fsTimeCheck = {2'd0, frame_limitCounter};
  assign _zz_endpoint_fsTimeCheck_1 = ({3'd0,endpoint_byteCountCalc} <<< 2'd3);
  assign _zz_token_data = reg_hcFmNumber_FN;
  assign _zz_ioDma_cmd_payload_fragment_length = (endpoint_ED_F ? 5'h1f : 5'h0f);
  assign _zz__zz_endpoint_lastAddress = ({1'b0,endpoint_TD_firstOffset} + _zz__zz_endpoint_lastAddress_1);
  assign _zz__zz_endpoint_lastAddress_2 = {1'b0,endpoint_ED_MPS};
  assign _zz__zz_endpoint_lastAddress_1 = {2'd0, _zz__zz_endpoint_lastAddress_2};
  assign _zz_endpoint_lastAddress_1 = (endpoint_ED_F ? _zz_endpoint_lastAddress_2 : ((_zz_endpoint_lastAddress_3 < _zz_endpoint_lastAddress) ? _zz_endpoint_lastAddress_4 : _zz_endpoint_lastAddress));
  assign _zz_endpoint_lastAddress_2 = {1'd0, endpoint_TD_lastOffset};
  assign _zz_endpoint_lastAddress_3 = {1'd0, endpoint_TD_lastOffset};
  assign _zz_endpoint_lastAddress_4 = {1'd0, endpoint_TD_lastOffset};
  assign _zz_when_UsbOhci_l1333 = {1'd0, endpoint_TD_lastOffset};
  assign _zz_endpoint_TD_words_0 = (endpoint_TD_EC + 2'b01);
  assign _zz_ioDma_cmd_payload_fragment_length_1 = (endpoint_ED_F ? 5'h1f : 5'h0f);
  assign _zz_ioDma_cmd_payload_last_1 = (endpoint_ED_F ? 3'b111 : 3'b011);
  assign _zz_ioDma_cmd_payload_last = {1'd0, _zz_ioDma_cmd_payload_last_1};
  assign _zz__zz_ioDma_cmd_payload_fragment_data_1 = (endpoint_ED_isoOut ? 14'h0000 : _zz__zz_ioDma_cmd_payload_fragment_data_2);
  assign _zz__zz_ioDma_cmd_payload_fragment_data = _zz__zz_ioDma_cmd_payload_fragment_data_1[11:0];
  assign _zz__zz_ioDma_cmd_payload_fragment_data_2 = (endpoint_currentAddress - _zz__zz_ioDma_cmd_payload_fragment_data_3);
  assign _zz__zz_ioDma_cmd_payload_fragment_data_3 = {1'd0, endpoint_TD_isoBase};
  assign _zz_when_UsbOhci_l1056 = {3'd0, endpoint_dmaLogic_fromUsbCounter};
  assign _zz_endpoint_dmaLogic_overflow = {3'd0, endpoint_dmaLogic_fromUsbCounter};
  assign _zz_endpoint_lastAddress_5 = (_zz_endpoint_lastAddress_6 - 14'h0001);
  assign _zz_endpoint_lastAddress_6 = (endpoint_currentAddress + _zz_endpoint_lastAddress_7);
  assign _zz_endpoint_lastAddress_7 = {3'd0, endpoint_dmaLogic_fromUsbCounter};
  assign _zz_endpoint_dmaLogic_fromUsbCounter_1 = (! endpoint_dmaLogic_fromUsbCounter[10]);
  assign _zz_endpoint_dmaLogic_fromUsbCounter = {10'd0, _zz_endpoint_dmaLogic_fromUsbCounter_1};
  assign _zz_endpoint_currentAddress = (endpoint_currentAddress + _zz_endpoint_currentAddress_1);
  assign _zz_endpoint_currentAddress_1 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_currentAddress_2 = (endpoint_currentAddress + _zz_endpoint_currentAddress_3);
  assign _zz_endpoint_currentAddress_3 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_ioDma_cmd_payload_fragment_address_1 = ({2'd0,reg_hcFmNumber_FN[4 : 0]} <<< 2'd2);
  assign _zz_ioDma_cmd_payload_fragment_address = {25'd0, _zz_ioDma_cmd_payload_fragment_address_1};
  UsbOhciAxi4_StreamFifo fifo (
    .io_push_valid   (fifo_io_push_valid        ), //i
    .io_push_ready   (fifo_io_push_ready        ), //o
    .io_push_payload (fifo_io_push_payload[31:0]), //i
    .io_pop_valid    (fifo_io_pop_valid         ), //o
    .io_pop_ready    (fifo_io_pop_ready         ), //i
    .io_pop_payload  (fifo_io_pop_payload[31:0] ), //o
    .io_flush        (fifo_io_flush             ), //i
    .io_occupancy    (fifo_io_occupancy[8:0]    ), //o
    .io_availability (fifo_io_availability[8:0] ), //o
    .ctrl_clk        (ctrl_clk                  ), //i
    .ctrl_reset      (ctrl_reset                )  //i
  );
  UsbOhciAxi4_Crc token_crc5 (
    .io_flush         (token_crc5_io_flush          ), //i
    .io_input_valid   (token_crc5_io_input_valid    ), //i
    .io_input_payload (token_data[10:0]             ), //i
    .io_result        (token_crc5_io_result[4:0]    ), //o
    .io_resultNext    (token_crc5_io_resultNext[4:0]), //o
    .ctrl_clk         (ctrl_clk                     ), //i
    .ctrl_reset       (ctrl_reset                   )  //i
  );
  UsbOhciAxi4_Crc_1 dataTx_crc16 (
    .io_flush         (dataTx_crc16_io_flush            ), //i
    .io_input_valid   (dataTx_data_fire                 ), //i
    .io_input_payload (dataTx_data_payload_fragment[7:0]), //i
    .io_result        (dataTx_crc16_io_result[15:0]     ), //o
    .io_resultNext    (dataTx_crc16_io_resultNext[15:0] ), //o
    .ctrl_clk         (ctrl_clk                         ), //i
    .ctrl_reset       (ctrl_reset                       )  //i
  );
  UsbOhciAxi4_Crc_2 dataRx_crc16 (
    .io_flush         (dataRx_crc16_io_flush           ), //i
    .io_input_valid   (dataRx_crc16_io_input_valid     ), //i
    .io_input_payload (_zz_dataRx_pid[7:0]             ), //i
    .io_result        (dataRx_crc16_io_result[15:0]    ), //o
    .io_resultNext    (dataRx_crc16_io_resultNext[15:0]), //o
    .ctrl_clk         (ctrl_clk                        ), //i
    .ctrl_reset       (ctrl_reset                      )  //i
  );
  always @(*) begin
    case(endpoint_dmaLogic_byteCtx_sel)
      2'b00 : _zz_dataTx_data_payload_fragment = fifo_io_pop_payload[7 : 0];
      2'b01 : _zz_dataTx_data_payload_fragment = fifo_io_pop_payload[15 : 8];
      2'b10 : _zz_dataTx_data_payload_fragment = fifo_io_pop_payload[23 : 16];
      default : _zz_dataTx_data_payload_fragment = fifo_io_pop_payload[31 : 24];
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(reg_hcControl_HCFS)
      UsbOhciAxi4_MainState_RESET : reg_hcControl_HCFS_string = "RESET      ";
      UsbOhciAxi4_MainState_RESUME : reg_hcControl_HCFS_string = "RESUME     ";
      UsbOhciAxi4_MainState_OPERATIONAL : reg_hcControl_HCFS_string = "OPERATIONAL";
      UsbOhciAxi4_MainState_SUSPEND : reg_hcControl_HCFS_string = "SUSPEND    ";
      default : reg_hcControl_HCFS_string = "???????????";
    endcase
  end
  always @(*) begin
    case(reg_hcControl_HCFSWrite_payload)
      UsbOhciAxi4_MainState_RESET : reg_hcControl_HCFSWrite_payload_string = "RESET      ";
      UsbOhciAxi4_MainState_RESUME : reg_hcControl_HCFSWrite_payload_string = "RESUME     ";
      UsbOhciAxi4_MainState_OPERATIONAL : reg_hcControl_HCFSWrite_payload_string = "OPERATIONAL";
      UsbOhciAxi4_MainState_SUSPEND : reg_hcControl_HCFSWrite_payload_string = "SUSPEND    ";
      default : reg_hcControl_HCFSWrite_payload_string = "???????????";
    endcase
  end
  always @(*) begin
    case(endpoint_flowType)
      UsbOhciAxi4_FlowType_BULK : endpoint_flowType_string = "BULK    ";
      UsbOhciAxi4_FlowType_CONTROL : endpoint_flowType_string = "CONTROL ";
      UsbOhciAxi4_FlowType_PERIODIC : endpoint_flowType_string = "PERIODIC";
      default : endpoint_flowType_string = "????????";
    endcase
  end
  always @(*) begin
    case(endpoint_status_1)
      UsbOhciAxi4_endpoint_Status_OK : endpoint_status_1_string = "OK        ";
      UsbOhciAxi4_endpoint_Status_FRAME_TIME : endpoint_status_1_string = "FRAME_TIME";
      default : endpoint_status_1_string = "??????????";
    endcase
  end
  always @(*) begin
    case(_zz_reg_hcControl_HCFSWrite_payload)
      UsbOhciAxi4_MainState_RESET : _zz_reg_hcControl_HCFSWrite_payload_string = "RESET      ";
      UsbOhciAxi4_MainState_RESUME : _zz_reg_hcControl_HCFSWrite_payload_string = "RESUME     ";
      UsbOhciAxi4_MainState_OPERATIONAL : _zz_reg_hcControl_HCFSWrite_payload_string = "OPERATIONAL";
      UsbOhciAxi4_MainState_SUSPEND : _zz_reg_hcControl_HCFSWrite_payload_string = "SUSPEND    ";
      default : _zz_reg_hcControl_HCFSWrite_payload_string = "???????????";
    endcase
  end
  always @(*) begin
    case(token_stateReg)
      UsbOhciAxi4_token_enumDef_BOOT : token_stateReg_string = "BOOT";
      UsbOhciAxi4_token_enumDef_INIT : token_stateReg_string = "INIT";
      UsbOhciAxi4_token_enumDef_PID : token_stateReg_string = "PID ";
      UsbOhciAxi4_token_enumDef_B1 : token_stateReg_string = "B1  ";
      UsbOhciAxi4_token_enumDef_B2 : token_stateReg_string = "B2  ";
      UsbOhciAxi4_token_enumDef_EOP : token_stateReg_string = "EOP ";
      default : token_stateReg_string = "????";
    endcase
  end
  always @(*) begin
    case(token_stateNext)
      UsbOhciAxi4_token_enumDef_BOOT : token_stateNext_string = "BOOT";
      UsbOhciAxi4_token_enumDef_INIT : token_stateNext_string = "INIT";
      UsbOhciAxi4_token_enumDef_PID : token_stateNext_string = "PID ";
      UsbOhciAxi4_token_enumDef_B1 : token_stateNext_string = "B1  ";
      UsbOhciAxi4_token_enumDef_B2 : token_stateNext_string = "B2  ";
      UsbOhciAxi4_token_enumDef_EOP : token_stateNext_string = "EOP ";
      default : token_stateNext_string = "????";
    endcase
  end
  always @(*) begin
    case(dataTx_stateReg)
      UsbOhciAxi4_dataTx_enumDef_BOOT : dataTx_stateReg_string = "BOOT ";
      UsbOhciAxi4_dataTx_enumDef_PID : dataTx_stateReg_string = "PID  ";
      UsbOhciAxi4_dataTx_enumDef_DATA : dataTx_stateReg_string = "DATA ";
      UsbOhciAxi4_dataTx_enumDef_CRC_0 : dataTx_stateReg_string = "CRC_0";
      UsbOhciAxi4_dataTx_enumDef_CRC_1 : dataTx_stateReg_string = "CRC_1";
      UsbOhciAxi4_dataTx_enumDef_EOP : dataTx_stateReg_string = "EOP  ";
      default : dataTx_stateReg_string = "?????";
    endcase
  end
  always @(*) begin
    case(dataTx_stateNext)
      UsbOhciAxi4_dataTx_enumDef_BOOT : dataTx_stateNext_string = "BOOT ";
      UsbOhciAxi4_dataTx_enumDef_PID : dataTx_stateNext_string = "PID  ";
      UsbOhciAxi4_dataTx_enumDef_DATA : dataTx_stateNext_string = "DATA ";
      UsbOhciAxi4_dataTx_enumDef_CRC_0 : dataTx_stateNext_string = "CRC_0";
      UsbOhciAxi4_dataTx_enumDef_CRC_1 : dataTx_stateNext_string = "CRC_1";
      UsbOhciAxi4_dataTx_enumDef_EOP : dataTx_stateNext_string = "EOP  ";
      default : dataTx_stateNext_string = "?????";
    endcase
  end
  always @(*) begin
    case(dataRx_stateReg)
      UsbOhciAxi4_dataRx_enumDef_BOOT : dataRx_stateReg_string = "BOOT";
      UsbOhciAxi4_dataRx_enumDef_IDLE : dataRx_stateReg_string = "IDLE";
      UsbOhciAxi4_dataRx_enumDef_PID : dataRx_stateReg_string = "PID ";
      UsbOhciAxi4_dataRx_enumDef_DATA : dataRx_stateReg_string = "DATA";
      default : dataRx_stateReg_string = "????";
    endcase
  end
  always @(*) begin
    case(dataRx_stateNext)
      UsbOhciAxi4_dataRx_enumDef_BOOT : dataRx_stateNext_string = "BOOT";
      UsbOhciAxi4_dataRx_enumDef_IDLE : dataRx_stateNext_string = "IDLE";
      UsbOhciAxi4_dataRx_enumDef_PID : dataRx_stateNext_string = "PID ";
      UsbOhciAxi4_dataRx_enumDef_DATA : dataRx_stateNext_string = "DATA";
      default : dataRx_stateNext_string = "????";
    endcase
  end
  always @(*) begin
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_BOOT : sof_stateReg_string = "BOOT            ";
      UsbOhciAxi4_sof_enumDef_FRAME_TX : sof_stateReg_string = "FRAME_TX        ";
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : sof_stateReg_string = "FRAME_NUMBER_CMD";
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : sof_stateReg_string = "FRAME_NUMBER_RSP";
      default : sof_stateReg_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(sof_stateNext)
      UsbOhciAxi4_sof_enumDef_BOOT : sof_stateNext_string = "BOOT            ";
      UsbOhciAxi4_sof_enumDef_FRAME_TX : sof_stateNext_string = "FRAME_TX        ";
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : sof_stateNext_string = "FRAME_NUMBER_CMD";
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : sof_stateNext_string = "FRAME_NUMBER_RSP";
      default : sof_stateNext_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_BOOT : endpoint_stateReg_string = "BOOT             ";
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : endpoint_stateReg_string = "ED_READ_CMD      ";
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : endpoint_stateReg_string = "ED_READ_RSP      ";
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : endpoint_stateReg_string = "ED_ANALYSE       ";
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : endpoint_stateReg_string = "TD_READ_CMD      ";
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : endpoint_stateReg_string = "TD_READ_RSP      ";
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : endpoint_stateReg_string = "TD_READ_DELAY    ";
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : endpoint_stateReg_string = "TD_ANALYSE       ";
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : endpoint_stateReg_string = "TD_CHECK_TIME    ";
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : endpoint_stateReg_string = "BUFFER_READ      ";
      UsbOhciAxi4_endpoint_enumDef_TOKEN : endpoint_stateReg_string = "TOKEN            ";
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : endpoint_stateReg_string = "DATA_TX          ";
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : endpoint_stateReg_string = "DATA_RX          ";
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : endpoint_stateReg_string = "DATA_RX_VALIDATE ";
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : endpoint_stateReg_string = "ACK_RX           ";
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : endpoint_stateReg_string = "ACK_TX_0         ";
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : endpoint_stateReg_string = "ACK_TX_1         ";
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : endpoint_stateReg_string = "ACK_TX_EOP       ";
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : endpoint_stateReg_string = "DATA_RX_WAIT_DMA ";
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : endpoint_stateReg_string = "UPDATE_TD_PROCESS";
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : endpoint_stateReg_string = "UPDATE_TD_CMD    ";
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : endpoint_stateReg_string = "UPDATE_ED_CMD    ";
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : endpoint_stateReg_string = "UPDATE_SYNC      ";
      UsbOhciAxi4_endpoint_enumDef_ABORD : endpoint_stateReg_string = "ABORD            ";
      default : endpoint_stateReg_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(endpoint_stateNext)
      UsbOhciAxi4_endpoint_enumDef_BOOT : endpoint_stateNext_string = "BOOT             ";
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : endpoint_stateNext_string = "ED_READ_CMD      ";
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : endpoint_stateNext_string = "ED_READ_RSP      ";
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : endpoint_stateNext_string = "ED_ANALYSE       ";
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : endpoint_stateNext_string = "TD_READ_CMD      ";
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : endpoint_stateNext_string = "TD_READ_RSP      ";
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : endpoint_stateNext_string = "TD_READ_DELAY    ";
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : endpoint_stateNext_string = "TD_ANALYSE       ";
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : endpoint_stateNext_string = "TD_CHECK_TIME    ";
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : endpoint_stateNext_string = "BUFFER_READ      ";
      UsbOhciAxi4_endpoint_enumDef_TOKEN : endpoint_stateNext_string = "TOKEN            ";
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : endpoint_stateNext_string = "DATA_TX          ";
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : endpoint_stateNext_string = "DATA_RX          ";
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : endpoint_stateNext_string = "DATA_RX_VALIDATE ";
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : endpoint_stateNext_string = "ACK_RX           ";
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : endpoint_stateNext_string = "ACK_TX_0         ";
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : endpoint_stateNext_string = "ACK_TX_1         ";
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : endpoint_stateNext_string = "ACK_TX_EOP       ";
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : endpoint_stateNext_string = "DATA_RX_WAIT_DMA ";
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : endpoint_stateNext_string = "UPDATE_TD_PROCESS";
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : endpoint_stateNext_string = "UPDATE_TD_CMD    ";
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : endpoint_stateNext_string = "UPDATE_ED_CMD    ";
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : endpoint_stateNext_string = "UPDATE_SYNC      ";
      UsbOhciAxi4_endpoint_enumDef_ABORD : endpoint_stateNext_string = "ABORD            ";
      default : endpoint_stateNext_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT : endpoint_dmaLogic_stateReg_string = "BOOT      ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : endpoint_dmaLogic_stateReg_string = "INIT      ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : endpoint_dmaLogic_stateReg_string = "TO_USB    ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : endpoint_dmaLogic_stateReg_string = "FROM_USB  ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : endpoint_dmaLogic_stateReg_string = "VALIDATION";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : endpoint_dmaLogic_stateReg_string = "CALC_CMD  ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : endpoint_dmaLogic_stateReg_string = "READ_CMD  ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : endpoint_dmaLogic_stateReg_string = "WRITE_CMD ";
      default : endpoint_dmaLogic_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(endpoint_dmaLogic_stateNext)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT : endpoint_dmaLogic_stateNext_string = "BOOT      ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : endpoint_dmaLogic_stateNext_string = "INIT      ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : endpoint_dmaLogic_stateNext_string = "TO_USB    ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : endpoint_dmaLogic_stateNext_string = "FROM_USB  ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : endpoint_dmaLogic_stateNext_string = "VALIDATION";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : endpoint_dmaLogic_stateNext_string = "CALC_CMD  ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : endpoint_dmaLogic_stateNext_string = "READ_CMD  ";
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : endpoint_dmaLogic_stateNext_string = "WRITE_CMD ";
      default : endpoint_dmaLogic_stateNext_string = "??????????";
    endcase
  end
  always @(*) begin
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_BOOT : operational_stateReg_string = "BOOT             ";
      UsbOhciAxi4_operational_enumDef_SOF : operational_stateReg_string = "SOF              ";
      UsbOhciAxi4_operational_enumDef_ARBITER : operational_stateReg_string = "ARBITER          ";
      UsbOhciAxi4_operational_enumDef_END_POINT : operational_stateReg_string = "END_POINT        ";
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : operational_stateReg_string = "PERIODIC_HEAD_CMD";
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : operational_stateReg_string = "PERIODIC_HEAD_RSP";
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : operational_stateReg_string = "WAIT_SOF         ";
      default : operational_stateReg_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(operational_stateNext)
      UsbOhciAxi4_operational_enumDef_BOOT : operational_stateNext_string = "BOOT             ";
      UsbOhciAxi4_operational_enumDef_SOF : operational_stateNext_string = "SOF              ";
      UsbOhciAxi4_operational_enumDef_ARBITER : operational_stateNext_string = "ARBITER          ";
      UsbOhciAxi4_operational_enumDef_END_POINT : operational_stateNext_string = "END_POINT        ";
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : operational_stateNext_string = "PERIODIC_HEAD_CMD";
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : operational_stateNext_string = "PERIODIC_HEAD_RSP";
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : operational_stateNext_string = "WAIT_SOF         ";
      default : operational_stateNext_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(hc_stateReg)
      UsbOhciAxi4_hc_enumDef_BOOT : hc_stateReg_string = "BOOT          ";
      UsbOhciAxi4_hc_enumDef_RESET : hc_stateReg_string = "RESET         ";
      UsbOhciAxi4_hc_enumDef_RESUME : hc_stateReg_string = "RESUME        ";
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : hc_stateReg_string = "OPERATIONAL   ";
      UsbOhciAxi4_hc_enumDef_SUSPEND : hc_stateReg_string = "SUSPEND       ";
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : hc_stateReg_string = "ANY_TO_RESET  ";
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : hc_stateReg_string = "ANY_TO_SUSPEND";
      default : hc_stateReg_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(hc_stateNext)
      UsbOhciAxi4_hc_enumDef_BOOT : hc_stateNext_string = "BOOT          ";
      UsbOhciAxi4_hc_enumDef_RESET : hc_stateNext_string = "RESET         ";
      UsbOhciAxi4_hc_enumDef_RESUME : hc_stateNext_string = "RESUME        ";
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : hc_stateNext_string = "OPERATIONAL   ";
      UsbOhciAxi4_hc_enumDef_SUSPEND : hc_stateNext_string = "SUSPEND       ";
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : hc_stateNext_string = "ANY_TO_RESET  ";
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : hc_stateNext_string = "ANY_TO_SUSPEND";
      default : hc_stateNext_string = "??????????????";
    endcase
  end
  `endif

  always @(*) begin
    io_phy_lowSpeed = 1'b0;
    if(when_UsbOhci_l752) begin
      io_phy_lowSpeed = endpoint_ED_S;
    end
  end

  always @(*) begin
    unscheduleAll_valid = 1'b0;
    if(doUnschedule) begin
      unscheduleAll_valid = 1'b1;
    end
  end

  always @(*) begin
    unscheduleAll_ready = 1'b1;
    if(when_UsbOhci_l158) begin
      unscheduleAll_ready = 1'b0;
    end
  end

  assign ioDma_cmd_fire = (ioDma_cmd_valid && ioDma_cmd_ready);
  assign ioDma_rsp_fire = (ioDma_rsp_valid && ioDma_rsp_ready);
  assign dmaCtx_pendingFull = dmaCtx_pendingCounter[3];
  assign dmaCtx_pendingEmpty = (dmaCtx_pendingCounter == 4'b0000);
  assign when_UsbOhci_l158 = (! dmaCtx_pendingEmpty);
  assign io_dma_cmd_fire = (io_dma_cmd_valid && io_dma_cmd_ready);
  assign _zz_io_dma_cmd_valid = (! (dmaCtx_pendingFull || (unscheduleAll_valid && io_dma_cmd_payload_first)));
  assign ioDma_cmd_ready = (io_dma_cmd_ready && _zz_io_dma_cmd_valid);
  assign io_dma_cmd_valid = (ioDma_cmd_valid && _zz_io_dma_cmd_valid);
  assign io_dma_cmd_payload_last = ioDma_cmd_payload_last;
  assign io_dma_cmd_payload_fragment_opcode = ioDma_cmd_payload_fragment_opcode;
  assign io_dma_cmd_payload_fragment_address = ioDma_cmd_payload_fragment_address;
  assign io_dma_cmd_payload_fragment_length = ioDma_cmd_payload_fragment_length;
  assign io_dma_cmd_payload_fragment_data = ioDma_cmd_payload_fragment_data;
  assign io_dma_cmd_payload_fragment_mask = ioDma_cmd_payload_fragment_mask;
  assign ioDma_rsp_valid = io_dma_rsp_valid;
  assign io_dma_rsp_ready = ioDma_rsp_ready;
  assign ioDma_rsp_payload_last = io_dma_rsp_payload_last;
  assign ioDma_rsp_payload_fragment_opcode = io_dma_rsp_payload_fragment_opcode;
  assign ioDma_rsp_payload_fragment_data = io_dma_rsp_payload_fragment_data;
  always @(*) begin
    ioDma_cmd_valid = 1'b0;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_last = 1'bx;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_payload_last = (dmaWriteCtx_counter == 4'b0001);
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_payload_last = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_payload_last = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_payload_last = (dmaWriteCtx_counter == _zz_ioDma_cmd_payload_last);
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_payload_last = (dmaWriteCtx_counter == 4'b0011);
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_payload_last = 1'b1;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_last = endpoint_dmaLogic_beatLast;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_payload_last = 1'b1;
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_opcode = 1'bx;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b1;
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b0;
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b0;
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b0;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b1;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b0;
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_address = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_payload_fragment_address = (reg_hcHCCA_HCCA_address | 32'h00000080);
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_ED_address;
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_TD_address;
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_TD_address;
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_ED_address;
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_currentAddressBmb;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_currentAddressBmb;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_payload_fragment_address = (reg_hcHCCA_HCCA_address | _zz_ioDma_cmd_payload_fragment_address);
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_length = 6'bxxxxxx;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_payload_fragment_length = 6'h07;
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_payload_fragment_length = 6'h0f;
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_payload_fragment_length = {1'd0, _zz_ioDma_cmd_payload_fragment_length};
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_payload_fragment_length = {1'd0, _zz_ioDma_cmd_payload_fragment_length_1};
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_payload_fragment_length = 6'h0f;
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_payload_fragment_length = endpoint_dmaLogic_lengthBmb;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_length = endpoint_dmaLogic_lengthBmb;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_payload_fragment_length = 6'h03;
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_data = 32'h00000000;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
        if(when_UsbOhci_l207) begin
          ioDma_cmd_payload_fragment_data[31 : 0] = {16'h0000,reg_hcFmNumber_FN};
        end
        if(sof_doInterruptDelay) begin
          if(when_UsbOhci_l207_1) begin
            ioDma_cmd_payload_fragment_data[31 : 0] = {reg_hcDoneHead_DH_address[31 : 1],reg_hcInterrupt_unmaskedPending};
          end
        end
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
        if(endpoint_ED_F) begin
          if(endpoint_TD_isoOverrunReg) begin
            if(when_UsbOhci_l207_2) begin
              ioDma_cmd_payload_fragment_data[31 : 24] = {{4'b1000,endpoint_TD_words_0[27]},endpoint_TD_FC};
            end
          end else begin
            if(endpoint_TD_isoLastReg) begin
              if(when_UsbOhci_l207_3) begin
                ioDma_cmd_payload_fragment_data[31 : 24] = {{4'b0000,endpoint_TD_words_0[27]},endpoint_TD_FC};
              end
            end
            if(when_UsbOhci_l1380) begin
              if(when_UsbOhci_l207_4) begin
                ioDma_cmd_payload_fragment_data[15 : 0] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1380_1) begin
              if(when_UsbOhci_l207_5) begin
                ioDma_cmd_payload_fragment_data[31 : 16] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1380_2) begin
              if(when_UsbOhci_l207_6) begin
                ioDma_cmd_payload_fragment_data[15 : 0] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1380_3) begin
              if(when_UsbOhci_l207_7) begin
                ioDma_cmd_payload_fragment_data[31 : 16] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1380_4) begin
              if(when_UsbOhci_l207_8) begin
                ioDma_cmd_payload_fragment_data[15 : 0] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1380_5) begin
              if(when_UsbOhci_l207_9) begin
                ioDma_cmd_payload_fragment_data[31 : 16] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1380_6) begin
              if(when_UsbOhci_l207_10) begin
                ioDma_cmd_payload_fragment_data[15 : 0] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1380_7) begin
              if(when_UsbOhci_l207_11) begin
                ioDma_cmd_payload_fragment_data[31 : 16] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
          end
        end else begin
          if(when_UsbOhci_l207_12) begin
            ioDma_cmd_payload_fragment_data[31 : 24] = {{endpoint_TD_CC,endpoint_TD_EC},endpoint_TD_TNext};
          end
          if(endpoint_TD_upateCBP) begin
            if(when_UsbOhci_l207_13) begin
              ioDma_cmd_payload_fragment_data[31 : 0] = endpoint_tdUpdateAddress;
            end
          end
        end
        if(endpoint_TD_retire) begin
          if(when_UsbOhci_l207_14) begin
            ioDma_cmd_payload_fragment_data[31 : 0] = reg_hcDoneHead_DH_address;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
        if(endpoint_TD_retire) begin
          if(when_UsbOhci_l207_15) begin
            ioDma_cmd_payload_fragment_data[31 : 0] = {{{endpoint_TD_nextTD,2'b00},endpoint_TD_dataPhaseNext},endpoint_ED_H};
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_data = fifo_io_pop_payload;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_mask = 4'b0000;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
        if(when_UsbOhci_l207) begin
          ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
        end
        if(sof_doInterruptDelay) begin
          if(when_UsbOhci_l207_1) begin
            ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
          end
        end
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
        if(endpoint_ED_F) begin
          if(endpoint_TD_isoOverrunReg) begin
            if(when_UsbOhci_l207_2) begin
              ioDma_cmd_payload_fragment_mask[3 : 3] = 1'b1;
            end
          end else begin
            if(endpoint_TD_isoLastReg) begin
              if(when_UsbOhci_l207_3) begin
                ioDma_cmd_payload_fragment_mask[3 : 3] = 1'b1;
              end
            end
            if(when_UsbOhci_l1380) begin
              if(when_UsbOhci_l207_4) begin
                ioDma_cmd_payload_fragment_mask[1 : 0] = 2'b11;
              end
            end
            if(when_UsbOhci_l1380_1) begin
              if(when_UsbOhci_l207_5) begin
                ioDma_cmd_payload_fragment_mask[3 : 2] = 2'b11;
              end
            end
            if(when_UsbOhci_l1380_2) begin
              if(when_UsbOhci_l207_6) begin
                ioDma_cmd_payload_fragment_mask[1 : 0] = 2'b11;
              end
            end
            if(when_UsbOhci_l1380_3) begin
              if(when_UsbOhci_l207_7) begin
                ioDma_cmd_payload_fragment_mask[3 : 2] = 2'b11;
              end
            end
            if(when_UsbOhci_l1380_4) begin
              if(when_UsbOhci_l207_8) begin
                ioDma_cmd_payload_fragment_mask[1 : 0] = 2'b11;
              end
            end
            if(when_UsbOhci_l1380_5) begin
              if(when_UsbOhci_l207_9) begin
                ioDma_cmd_payload_fragment_mask[3 : 2] = 2'b11;
              end
            end
            if(when_UsbOhci_l1380_6) begin
              if(when_UsbOhci_l207_10) begin
                ioDma_cmd_payload_fragment_mask[1 : 0] = 2'b11;
              end
            end
            if(when_UsbOhci_l1380_7) begin
              if(when_UsbOhci_l207_11) begin
                ioDma_cmd_payload_fragment_mask[3 : 2] = 2'b11;
              end
            end
          end
        end else begin
          if(when_UsbOhci_l207_12) begin
            ioDma_cmd_payload_fragment_mask[3 : 3] = 1'b1;
          end
          if(endpoint_TD_upateCBP) begin
            if(when_UsbOhci_l207_13) begin
              ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
            end
          end
        end
        if(endpoint_TD_retire) begin
          if(when_UsbOhci_l207_14) begin
            ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
        if(endpoint_TD_retire) begin
          if(when_UsbOhci_l207_15) begin
            ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_mask = ((endpoint_dmaLogic_fullMask & (ioDma_cmd_payload_first ? endpoint_dmaLogic_headMask : endpoint_dmaLogic_fullMask)) & (ioDma_cmd_payload_last ? endpoint_dmaLogic_lastMask : endpoint_dmaLogic_fullMask));
      end
      default : begin
      end
    endcase
  end

  assign ioDma_rsp_ready = 1'b1;
  assign dmaRspMux_vec_0 = ioDma_rsp_payload_fragment_data[31 : 0];
  assign dmaRspMux_data = dmaRspMux_vec_0;
  always @(*) begin
    fifo_io_push_valid = 1'b0;
    if(when_UsbOhci_l940) begin
      fifo_io_push_valid = 1'b1;
    end
    if(endpoint_dmaLogic_push) begin
      fifo_io_push_valid = 1'b1;
    end
  end

  always @(*) begin
    fifo_io_push_payload = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    if(when_UsbOhci_l940) begin
      fifo_io_push_payload = ioDma_rsp_payload_fragment_data;
    end
    if(endpoint_dmaLogic_push) begin
      fifo_io_push_payload = endpoint_dmaLogic_buffer;
    end
  end

  always @(*) begin
    fifo_io_pop_ready = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
        if(dataTx_data_ready) begin
          if(when_UsbOhci_l1027) begin
            fifo_io_pop_ready = 1'b1;
          end
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        if(ioDma_cmd_ready) begin
          fifo_io_pop_ready = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fifo_io_flush = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
        fifo_io_flush = 1'b1;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_phy_tx_valid = 1'b0;
    case(token_stateReg)
      UsbOhciAxi4_token_enumDef_INIT : begin
      end
      UsbOhciAxi4_token_enumDef_PID : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciAxi4_token_enumDef_B1 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciAxi4_token_enumDef_B2 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciAxi4_token_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(dataTx_stateReg)
      UsbOhciAxi4_dataTx_enumDef_PID : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciAxi4_dataTx_enumDef_DATA : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_0 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_1 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciAxi4_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_phy_tx_payload_fragment = 8'bxxxxxxxx;
    case(token_stateReg)
      UsbOhciAxi4_token_enumDef_INIT : begin
      end
      UsbOhciAxi4_token_enumDef_PID : begin
        io_phy_tx_payload_fragment = {(~ token_pid),token_pid};
      end
      UsbOhciAxi4_token_enumDef_B1 : begin
        io_phy_tx_payload_fragment = token_data[7 : 0];
      end
      UsbOhciAxi4_token_enumDef_B2 : begin
        io_phy_tx_payload_fragment = {token_crc5_io_result,token_data[10 : 8]};
      end
      UsbOhciAxi4_token_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(dataTx_stateReg)
      UsbOhciAxi4_dataTx_enumDef_PID : begin
        io_phy_tx_payload_fragment = {(~ dataTx_pid),dataTx_pid};
      end
      UsbOhciAxi4_dataTx_enumDef_DATA : begin
        io_phy_tx_payload_fragment = dataTx_data_payload_fragment;
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_0 : begin
        io_phy_tx_payload_fragment = dataTx_crc16_io_result[7 : 0];
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_1 : begin
        io_phy_tx_payload_fragment = dataTx_crc16_io_result[15 : 8];
      end
      UsbOhciAxi4_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
        io_phy_tx_payload_fragment = 8'hd2;
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_phy_tx_payload_last = 1'bx;
    case(token_stateReg)
      UsbOhciAxi4_token_enumDef_INIT : begin
      end
      UsbOhciAxi4_token_enumDef_PID : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciAxi4_token_enumDef_B1 : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciAxi4_token_enumDef_B2 : begin
        io_phy_tx_payload_last = 1'b1;
      end
      UsbOhciAxi4_token_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(dataTx_stateReg)
      UsbOhciAxi4_dataTx_enumDef_PID : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciAxi4_dataTx_enumDef_DATA : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_0 : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_1 : begin
        io_phy_tx_payload_last = 1'b1;
      end
      UsbOhciAxi4_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
        io_phy_tx_payload_last = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ctrlHalt = 1'b0;
    case(hc_stateReg)
      UsbOhciAxi4_hc_enumDef_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_RESUME : begin
      end
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciAxi4_hc_enumDef_SUSPEND : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : begin
        ctrlHalt = 1'b1;
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : begin
        ctrlHalt = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign ctrl_readErrorFlag = 1'b0;
  assign ctrl_writeErrorFlag = 1'b0;
  assign ctrl_readHaltTrigger = 1'b0;
  always @(*) begin
    ctrl_writeHaltTrigger = 1'b0;
    if(ctrlHalt) begin
      ctrl_writeHaltTrigger = 1'b1;
    end
  end

  assign _zz_ctrl_rsp_ready = (! (ctrl_readHaltTrigger || ctrl_writeHaltTrigger));
  assign ctrl_rsp_ready = (_zz_ctrl_rsp_ready_1 && _zz_ctrl_rsp_ready);
  always @(*) begin
    _zz_ctrl_rsp_ready_1 = io_ctrl_rsp_ready;
    if(when_Stream_l369) begin
      _zz_ctrl_rsp_ready_1 = 1'b1;
    end
  end

  assign when_Stream_l369 = (! _zz_io_ctrl_rsp_valid);
  assign _zz_io_ctrl_rsp_valid = _zz_io_ctrl_rsp_valid_1;
  assign io_ctrl_rsp_valid = _zz_io_ctrl_rsp_valid;
  assign io_ctrl_rsp_payload_last = _zz_io_ctrl_rsp_payload_last;
  assign io_ctrl_rsp_payload_fragment_source = _zz_io_ctrl_rsp_payload_fragment_source;
  assign io_ctrl_rsp_payload_fragment_opcode = _zz_io_ctrl_rsp_payload_fragment_opcode;
  assign io_ctrl_rsp_payload_fragment_data = _zz_io_ctrl_rsp_payload_fragment_data;
  assign ctrl_askWrite = (io_ctrl_cmd_valid && (io_ctrl_cmd_payload_fragment_opcode == 1'b1));
  assign ctrl_askRead = (io_ctrl_cmd_valid && (io_ctrl_cmd_payload_fragment_opcode == 1'b0));
  assign io_ctrl_cmd_fire = (io_ctrl_cmd_valid && io_ctrl_cmd_ready);
  assign ctrl_doWrite = (io_ctrl_cmd_fire && (io_ctrl_cmd_payload_fragment_opcode == 1'b1));
  assign ctrl_doRead = (io_ctrl_cmd_fire && (io_ctrl_cmd_payload_fragment_opcode == 1'b0));
  assign ctrl_rsp_valid = io_ctrl_cmd_valid;
  assign io_ctrl_cmd_ready = ctrl_rsp_ready;
  assign ctrl_rsp_payload_last = 1'b1;
  assign when_BmbSlaveFactory_l33 = (ctrl_doWrite && ctrl_writeErrorFlag);
  always @(*) begin
    if(when_BmbSlaveFactory_l33) begin
      ctrl_rsp_payload_fragment_opcode = 1'b1;
    end else begin
      if(when_BmbSlaveFactory_l35) begin
        ctrl_rsp_payload_fragment_opcode = 1'b1;
      end else begin
        ctrl_rsp_payload_fragment_opcode = 1'b0;
      end
    end
  end

  assign when_BmbSlaveFactory_l35 = (ctrl_doRead && ctrl_readErrorFlag);
  always @(*) begin
    ctrl_rsp_payload_fragment_data = 32'h00000000;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h000 : begin
        ctrl_rsp_payload_fragment_data[4 : 0] = reg_hcRevision_REV;
      end
      12'h004 : begin
        ctrl_rsp_payload_fragment_data[1 : 0] = reg_hcControl_CBSR;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcControl_PLE;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcControl_IE;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcControl_CLE;
        ctrl_rsp_payload_fragment_data[5 : 5] = reg_hcControl_BLE;
        ctrl_rsp_payload_fragment_data[7 : 6] = reg_hcControl_HCFS;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcControl_IR;
        ctrl_rsp_payload_fragment_data[9 : 9] = reg_hcControl_RWC;
        ctrl_rsp_payload_fragment_data[10 : 10] = reg_hcControl_RWE;
      end
      12'h008 : begin
        ctrl_rsp_payload_fragment_data[0 : 0] = doSoftReset;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcCommandStatus_CLF;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcCommandStatus_BLF;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcCommandStatus_OCR;
        ctrl_rsp_payload_fragment_data[17 : 16] = reg_hcCommandStatus_SOC;
      end
      12'h010 : begin
        ctrl_rsp_payload_fragment_data[31 : 31] = reg_hcInterrupt_MIE;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcInterrupt_SO_enable;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcInterrupt_WDH_enable;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcInterrupt_SF_enable;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcInterrupt_RD_enable;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcInterrupt_UE_enable;
        ctrl_rsp_payload_fragment_data[5 : 5] = reg_hcInterrupt_FNO_enable;
        ctrl_rsp_payload_fragment_data[6 : 6] = reg_hcInterrupt_RHSC_enable;
        ctrl_rsp_payload_fragment_data[30 : 30] = reg_hcInterrupt_OC_enable;
      end
      12'h014 : begin
        ctrl_rsp_payload_fragment_data[31 : 31] = reg_hcInterrupt_MIE;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcInterrupt_SO_enable;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcInterrupt_WDH_enable;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcInterrupt_SF_enable;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcInterrupt_RD_enable;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcInterrupt_UE_enable;
        ctrl_rsp_payload_fragment_data[5 : 5] = reg_hcInterrupt_FNO_enable;
        ctrl_rsp_payload_fragment_data[6 : 6] = reg_hcInterrupt_RHSC_enable;
        ctrl_rsp_payload_fragment_data[30 : 30] = reg_hcInterrupt_OC_enable;
      end
      12'h00c : begin
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcInterrupt_SO_status;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcInterrupt_WDH_status;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcInterrupt_SF_status;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcInterrupt_RD_status;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcInterrupt_UE_status;
        ctrl_rsp_payload_fragment_data[5 : 5] = reg_hcInterrupt_FNO_status;
        ctrl_rsp_payload_fragment_data[6 : 6] = reg_hcInterrupt_RHSC_status;
        ctrl_rsp_payload_fragment_data[30 : 30] = reg_hcInterrupt_OC_status;
      end
      12'h018 : begin
        ctrl_rsp_payload_fragment_data[31 : 8] = reg_hcHCCA_HCCA_reg;
      end
      12'h01c : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcPeriodCurrentED_PCED_reg;
      end
      12'h020 : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcControlHeadED_CHED_reg;
      end
      12'h024 : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcControlCurrentED_CCED_reg;
      end
      12'h028 : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcBulkHeadED_BHED_reg;
      end
      12'h02c : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcBulkCurrentED_BCED_reg;
      end
      12'h030 : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcDoneHead_DH_reg;
      end
      12'h034 : begin
        ctrl_rsp_payload_fragment_data[13 : 0] = reg_hcFmInterval_FI;
        ctrl_rsp_payload_fragment_data[30 : 16] = reg_hcFmInterval_FSMPS;
        ctrl_rsp_payload_fragment_data[31 : 31] = reg_hcFmInterval_FIT;
      end
      12'h038 : begin
        ctrl_rsp_payload_fragment_data[13 : 0] = reg_hcFmRemaining_FR;
        ctrl_rsp_payload_fragment_data[31 : 31] = reg_hcFmRemaining_FRT;
      end
      12'h03c : begin
        ctrl_rsp_payload_fragment_data[15 : 0] = reg_hcFmNumber_FN;
      end
      12'h040 : begin
        ctrl_rsp_payload_fragment_data[13 : 0] = reg_hcPeriodicStart_PS;
      end
      12'h044 : begin
        ctrl_rsp_payload_fragment_data[11 : 0] = reg_hcLSThreshold_LST;
      end
      12'h048 : begin
        ctrl_rsp_payload_fragment_data[7 : 0] = reg_hcRhDescriptorA_NDP;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcRhDescriptorA_PSM;
        ctrl_rsp_payload_fragment_data[9 : 9] = reg_hcRhDescriptorA_NPS;
        ctrl_rsp_payload_fragment_data[11 : 11] = reg_hcRhDescriptorA_OCPM;
        ctrl_rsp_payload_fragment_data[12 : 12] = reg_hcRhDescriptorA_NOCP;
        ctrl_rsp_payload_fragment_data[31 : 24] = reg_hcRhDescriptorA_POTPGT;
      end
      12'h04c : begin
        ctrl_rsp_payload_fragment_data[4 : 1] = reg_hcRhDescriptorB_DR;
        ctrl_rsp_payload_fragment_data[20 : 17] = reg_hcRhDescriptorB_PPCM;
      end
      12'h050 : begin
        ctrl_rsp_payload_fragment_data[1 : 1] = io_phy_overcurrent;
        ctrl_rsp_payload_fragment_data[15 : 15] = reg_hcRhStatus_DRWE;
        ctrl_rsp_payload_fragment_data[17 : 17] = reg_hcRhStatus_CCIC;
      end
      12'h054 : begin
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcRhPortStatus_0_PSS;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcRhPortStatus_0_PPS;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcRhPortStatus_0_CCS;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcRhPortStatus_0_PES;
        ctrl_rsp_payload_fragment_data[3 : 3] = io_phy_ports_0_overcurrent;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcRhPortStatus_0_reset;
        ctrl_rsp_payload_fragment_data[9 : 9] = io_phy_ports_0_lowSpeed;
        ctrl_rsp_payload_fragment_data[16 : 16] = reg_hcRhPortStatus_0_CSC_reg;
        ctrl_rsp_payload_fragment_data[17 : 17] = reg_hcRhPortStatus_0_PESC_reg;
        ctrl_rsp_payload_fragment_data[18 : 18] = reg_hcRhPortStatus_0_PSSC_reg;
        ctrl_rsp_payload_fragment_data[19 : 19] = reg_hcRhPortStatus_0_OCIC_reg;
        ctrl_rsp_payload_fragment_data[20 : 20] = reg_hcRhPortStatus_0_PRSC_reg;
      end
      12'h058 : begin
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcRhPortStatus_1_PSS;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcRhPortStatus_1_PPS;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcRhPortStatus_1_CCS;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcRhPortStatus_1_PES;
        ctrl_rsp_payload_fragment_data[3 : 3] = io_phy_ports_1_overcurrent;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcRhPortStatus_1_reset;
        ctrl_rsp_payload_fragment_data[9 : 9] = io_phy_ports_1_lowSpeed;
        ctrl_rsp_payload_fragment_data[16 : 16] = reg_hcRhPortStatus_1_CSC_reg;
        ctrl_rsp_payload_fragment_data[17 : 17] = reg_hcRhPortStatus_1_PESC_reg;
        ctrl_rsp_payload_fragment_data[18 : 18] = reg_hcRhPortStatus_1_PSSC_reg;
        ctrl_rsp_payload_fragment_data[19 : 19] = reg_hcRhPortStatus_1_OCIC_reg;
        ctrl_rsp_payload_fragment_data[20 : 20] = reg_hcRhPortStatus_1_PRSC_reg;
      end
      12'h05c : begin
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcRhPortStatus_2_PSS;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcRhPortStatus_2_PPS;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcRhPortStatus_2_CCS;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcRhPortStatus_2_PES;
        ctrl_rsp_payload_fragment_data[3 : 3] = io_phy_ports_2_overcurrent;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcRhPortStatus_2_reset;
        ctrl_rsp_payload_fragment_data[9 : 9] = io_phy_ports_2_lowSpeed;
        ctrl_rsp_payload_fragment_data[16 : 16] = reg_hcRhPortStatus_2_CSC_reg;
        ctrl_rsp_payload_fragment_data[17 : 17] = reg_hcRhPortStatus_2_PESC_reg;
        ctrl_rsp_payload_fragment_data[18 : 18] = reg_hcRhPortStatus_2_PSSC_reg;
        ctrl_rsp_payload_fragment_data[19 : 19] = reg_hcRhPortStatus_2_OCIC_reg;
        ctrl_rsp_payload_fragment_data[20 : 20] = reg_hcRhPortStatus_2_PRSC_reg;
      end
      12'h060 : begin
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcRhPortStatus_3_PSS;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcRhPortStatus_3_PPS;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcRhPortStatus_3_CCS;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcRhPortStatus_3_PES;
        ctrl_rsp_payload_fragment_data[3 : 3] = io_phy_ports_3_overcurrent;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcRhPortStatus_3_reset;
        ctrl_rsp_payload_fragment_data[9 : 9] = io_phy_ports_3_lowSpeed;
        ctrl_rsp_payload_fragment_data[16 : 16] = reg_hcRhPortStatus_3_CSC_reg;
        ctrl_rsp_payload_fragment_data[17 : 17] = reg_hcRhPortStatus_3_PESC_reg;
        ctrl_rsp_payload_fragment_data[18 : 18] = reg_hcRhPortStatus_3_PSSC_reg;
        ctrl_rsp_payload_fragment_data[19 : 19] = reg_hcRhPortStatus_3_OCIC_reg;
        ctrl_rsp_payload_fragment_data[20 : 20] = reg_hcRhPortStatus_3_PRSC_reg;
      end
      default : begin
      end
    endcase
  end

  assign ctrl_rsp_payload_fragment_source = io_ctrl_cmd_payload_fragment_source;
  assign when_UsbOhci_l238 = (! doUnschedule);
  assign reg_hcRevision_REV = 5'h10;
  always @(*) begin
    reg_hcControl_HCFSWrite_valid = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h004 : begin
        if(ctrl_doWrite) begin
          reg_hcControl_HCFSWrite_valid = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    reg_hcCommandStatus_startSoftReset = 1'b0;
    if(when_BusSlaveFactory_l377) begin
      if(when_BusSlaveFactory_l379) begin
        reg_hcCommandStatus_startSoftReset = _zz_reg_hcCommandStatus_startSoftReset[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h008 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    when_BusSlaveFactory_l377_1 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h008 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_1 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    when_BusSlaveFactory_l377_2 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h008 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_2 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_2 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    when_BusSlaveFactory_l377_3 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h008 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_3 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_3 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    reg_hcInterrupt_unmaskedPending = 1'b0;
    if(when_UsbOhci_l304) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l304_1) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l304_2) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l304_3) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l304_4) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l304_5) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l304_6) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_4 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_4 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_4 = io_ctrl_cmd_payload_fragment_data[31];
  always @(*) begin
    when_BusSlaveFactory_l341 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347 = io_ctrl_cmd_payload_fragment_data[31];
  always @(*) begin
    when_BusSlaveFactory_l341_1 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_1 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    when_BusSlaveFactory_l377_5 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_5 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_5 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    when_BusSlaveFactory_l341_2 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_2 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_2 = io_ctrl_cmd_payload_fragment_data[0];
  assign when_UsbOhci_l304 = (reg_hcInterrupt_SO_status && reg_hcInterrupt_SO_enable);
  always @(*) begin
    when_BusSlaveFactory_l341_3 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_3 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_3 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    when_BusSlaveFactory_l377_6 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_6 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_6 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    when_BusSlaveFactory_l341_4 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_4 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_4 = io_ctrl_cmd_payload_fragment_data[1];
  assign when_UsbOhci_l304_1 = (reg_hcInterrupt_WDH_status && reg_hcInterrupt_WDH_enable);
  always @(*) begin
    when_BusSlaveFactory_l341_5 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_5 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_5 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    when_BusSlaveFactory_l377_7 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_7 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_7 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    when_BusSlaveFactory_l341_6 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_6 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_6 = io_ctrl_cmd_payload_fragment_data[2];
  assign when_UsbOhci_l304_2 = (reg_hcInterrupt_SF_status && reg_hcInterrupt_SF_enable);
  always @(*) begin
    when_BusSlaveFactory_l341_7 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_7 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_7 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    when_BusSlaveFactory_l377_8 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_8 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_8 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    when_BusSlaveFactory_l341_8 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_8 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_8 = io_ctrl_cmd_payload_fragment_data[3];
  assign when_UsbOhci_l304_3 = (reg_hcInterrupt_RD_status && reg_hcInterrupt_RD_enable);
  always @(*) begin
    when_BusSlaveFactory_l341_9 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_9 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_9 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    when_BusSlaveFactory_l377_9 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_9 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_9 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    when_BusSlaveFactory_l341_10 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_10 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_10 = io_ctrl_cmd_payload_fragment_data[4];
  assign when_UsbOhci_l304_4 = (reg_hcInterrupt_UE_status && reg_hcInterrupt_UE_enable);
  always @(*) begin
    when_BusSlaveFactory_l341_11 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_11 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_11 = io_ctrl_cmd_payload_fragment_data[5];
  always @(*) begin
    when_BusSlaveFactory_l377_10 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_10 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_10 = io_ctrl_cmd_payload_fragment_data[5];
  always @(*) begin
    when_BusSlaveFactory_l341_12 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_12 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_12 = io_ctrl_cmd_payload_fragment_data[5];
  assign when_UsbOhci_l304_5 = (reg_hcInterrupt_FNO_status && reg_hcInterrupt_FNO_enable);
  always @(*) begin
    when_BusSlaveFactory_l341_13 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_13 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_13 = io_ctrl_cmd_payload_fragment_data[6];
  always @(*) begin
    when_BusSlaveFactory_l377_11 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_11 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_11 = io_ctrl_cmd_payload_fragment_data[6];
  always @(*) begin
    when_BusSlaveFactory_l341_14 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_14 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_14 = io_ctrl_cmd_payload_fragment_data[6];
  assign when_UsbOhci_l304_6 = (reg_hcInterrupt_RHSC_status && reg_hcInterrupt_RHSC_enable);
  always @(*) begin
    when_BusSlaveFactory_l341_15 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_15 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_15 = io_ctrl_cmd_payload_fragment_data[30];
  always @(*) begin
    when_BusSlaveFactory_l377_12 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_12 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_12 = io_ctrl_cmd_payload_fragment_data[30];
  always @(*) begin
    when_BusSlaveFactory_l341_16 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_16 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_16 = io_ctrl_cmd_payload_fragment_data[30];
  assign reg_hcInterrupt_doIrq = (reg_hcInterrupt_unmaskedPending && reg_hcInterrupt_MIE);
  assign io_interrupt = (reg_hcInterrupt_doIrq && (! reg_hcControl_IR));
  assign io_interruptBios = ((reg_hcInterrupt_doIrq && reg_hcControl_IR) || (reg_hcInterrupt_OC_status && reg_hcInterrupt_OC_enable));
  assign reg_hcHCCA_HCCA_address = {reg_hcHCCA_HCCA_reg,8'h00};
  assign reg_hcPeriodCurrentED_PCED_address = {reg_hcPeriodCurrentED_PCED_reg,4'b0000};
  assign reg_hcPeriodCurrentED_isZero = (reg_hcPeriodCurrentED_PCED_reg == 28'h0000000);
  assign reg_hcControlHeadED_CHED_address = {reg_hcControlHeadED_CHED_reg,4'b0000};
  assign reg_hcControlCurrentED_CCED_address = {reg_hcControlCurrentED_CCED_reg,4'b0000};
  assign reg_hcControlCurrentED_isZero = (reg_hcControlCurrentED_CCED_reg == 28'h0000000);
  assign reg_hcBulkHeadED_BHED_address = {reg_hcBulkHeadED_BHED_reg,4'b0000};
  assign reg_hcBulkCurrentED_BCED_address = {reg_hcBulkCurrentED_BCED_reg,4'b0000};
  assign reg_hcBulkCurrentED_isZero = (reg_hcBulkCurrentED_BCED_reg == 28'h0000000);
  assign reg_hcDoneHead_DH_address = {reg_hcDoneHead_DH_reg,4'b0000};
  assign reg_hcFmNumber_FNp1 = (reg_hcFmNumber_FN + 16'h0001);
  assign reg_hcLSThreshold_hit = (reg_hcFmRemaining_FR < _zz_reg_hcLSThreshold_hit);
  assign reg_hcRhDescriptorA_NDP = 8'h04;
  always @(*) begin
    when_BusSlaveFactory_l341_17 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l341_17 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l347_17 = io_ctrl_cmd_payload_fragment_data[17];
  assign when_UsbOhci_l411 = (io_phy_overcurrent ^ io_phy_overcurrent_regNext);
  always @(*) begin
    reg_hcRhStatus_clearGlobalPower = 1'b0;
    if(when_BusSlaveFactory_l377_13) begin
      if(when_BusSlaveFactory_l379_13) begin
        reg_hcRhStatus_clearGlobalPower = _zz_reg_hcRhStatus_clearGlobalPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_13 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_13 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_13 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    reg_hcRhStatus_setRemoteWakeupEnable = 1'b0;
    if(when_BusSlaveFactory_l377_14) begin
      if(when_BusSlaveFactory_l379_14) begin
        reg_hcRhStatus_setRemoteWakeupEnable = _zz_reg_hcRhStatus_setRemoteWakeupEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_14 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_14 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_14 = io_ctrl_cmd_payload_fragment_data[15];
  always @(*) begin
    reg_hcRhStatus_setGlobalPower = 1'b0;
    if(when_BusSlaveFactory_l377_15) begin
      if(when_BusSlaveFactory_l379_15) begin
        reg_hcRhStatus_setGlobalPower = _zz_reg_hcRhStatus_setGlobalPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_15 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_15 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_15 = io_ctrl_cmd_payload_fragment_data[16];
  always @(*) begin
    reg_hcRhStatus_clearRemoteWakeupEnable = 1'b0;
    if(when_BusSlaveFactory_l377_16) begin
      if(when_BusSlaveFactory_l379_16) begin
        reg_hcRhStatus_clearRemoteWakeupEnable = _zz_reg_hcRhStatus_clearRemoteWakeupEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_16 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_16 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_16 = io_ctrl_cmd_payload_fragment_data[31];
  always @(*) begin
    reg_hcRhPortStatus_0_clearPortEnable = 1'b0;
    if(when_BusSlaveFactory_l377_17) begin
      if(when_BusSlaveFactory_l379_17) begin
        reg_hcRhPortStatus_0_clearPortEnable = _zz_reg_hcRhPortStatus_0_clearPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_17 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_17 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_17 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    reg_hcRhPortStatus_0_setPortEnable = 1'b0;
    if(when_BusSlaveFactory_l377_18) begin
      if(when_BusSlaveFactory_l379_18) begin
        reg_hcRhPortStatus_0_setPortEnable = _zz_reg_hcRhPortStatus_0_setPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_18 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_18 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_18 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    reg_hcRhPortStatus_0_setPortSuspend = 1'b0;
    if(when_BusSlaveFactory_l377_19) begin
      if(when_BusSlaveFactory_l379_19) begin
        reg_hcRhPortStatus_0_setPortSuspend = _zz_reg_hcRhPortStatus_0_setPortSuspend[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_19 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_19 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_19 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    reg_hcRhPortStatus_0_clearSuspendStatus = 1'b0;
    if(when_BusSlaveFactory_l377_20) begin
      if(when_BusSlaveFactory_l379_20) begin
        reg_hcRhPortStatus_0_clearSuspendStatus = _zz_reg_hcRhPortStatus_0_clearSuspendStatus[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_20 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_20 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_20 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    reg_hcRhPortStatus_0_setPortReset = 1'b0;
    if(when_BusSlaveFactory_l377_21) begin
      if(when_BusSlaveFactory_l379_21) begin
        reg_hcRhPortStatus_0_setPortReset = _zz_reg_hcRhPortStatus_0_setPortReset[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_21 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_21 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_21 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    reg_hcRhPortStatus_0_setPortPower = 1'b0;
    if(when_BusSlaveFactory_l377_22) begin
      if(when_BusSlaveFactory_l379_22) begin
        reg_hcRhPortStatus_0_setPortPower = _zz_reg_hcRhPortStatus_0_setPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_22 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_22 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_22 = io_ctrl_cmd_payload_fragment_data[8];
  always @(*) begin
    reg_hcRhPortStatus_0_clearPortPower = 1'b0;
    if(when_BusSlaveFactory_l377_23) begin
      if(when_BusSlaveFactory_l379_23) begin
        reg_hcRhPortStatus_0_clearPortPower = _zz_reg_hcRhPortStatus_0_clearPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_23 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_23 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_23 = io_ctrl_cmd_payload_fragment_data[9];
  assign reg_hcRhPortStatus_0_CCS = ((reg_hcRhPortStatus_0_connected || reg_hcRhDescriptorB_DR[0]) && reg_hcRhPortStatus_0_PPS);
  always @(*) begin
    reg_hcRhPortStatus_0_CSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_24) begin
      if(when_BusSlaveFactory_l379_24) begin
        reg_hcRhPortStatus_0_CSC_clear = _zz_reg_hcRhPortStatus_0_CSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_24 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_24 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_24 = io_ctrl_cmd_payload_fragment_data[16];
  always @(*) begin
    reg_hcRhPortStatus_0_PESC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_25) begin
      if(when_BusSlaveFactory_l379_25) begin
        reg_hcRhPortStatus_0_PESC_clear = _zz_reg_hcRhPortStatus_0_PESC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_25 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_25 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_25 = io_ctrl_cmd_payload_fragment_data[17];
  always @(*) begin
    reg_hcRhPortStatus_0_PSSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_26) begin
      if(when_BusSlaveFactory_l379_26) begin
        reg_hcRhPortStatus_0_PSSC_clear = _zz_reg_hcRhPortStatus_0_PSSC_clear[0];
      end
    end
    if(reg_hcRhPortStatus_0_PRSC_set) begin
      reg_hcRhPortStatus_0_PSSC_clear = 1'b1;
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_26 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_26 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_26 = io_ctrl_cmd_payload_fragment_data[18];
  always @(*) begin
    reg_hcRhPortStatus_0_OCIC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_27) begin
      if(when_BusSlaveFactory_l379_27) begin
        reg_hcRhPortStatus_0_OCIC_clear = _zz_reg_hcRhPortStatus_0_OCIC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_27 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_27 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_27 = io_ctrl_cmd_payload_fragment_data[19];
  always @(*) begin
    reg_hcRhPortStatus_0_PRSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_28) begin
      if(when_BusSlaveFactory_l379_28) begin
        reg_hcRhPortStatus_0_PRSC_clear = _zz_reg_hcRhPortStatus_0_PRSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_28 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_28 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_28 = io_ctrl_cmd_payload_fragment_data[20];
  assign when_UsbOhci_l462 = ((reg_hcRhPortStatus_0_clearPortEnable || reg_hcRhPortStatus_0_PESC_set) || (! reg_hcRhPortStatus_0_PPS));
  assign when_UsbOhci_l462_1 = (reg_hcRhPortStatus_0_PRSC_set || reg_hcRhPortStatus_0_PSSC_set);
  assign when_UsbOhci_l462_2 = (reg_hcRhPortStatus_0_setPortEnable && reg_hcRhPortStatus_0_CCS);
  assign when_UsbOhci_l463 = (((reg_hcRhPortStatus_0_PSSC_set || reg_hcRhPortStatus_0_PRSC_set) || (! reg_hcRhPortStatus_0_PPS)) || (reg_hcControl_HCFS == UsbOhciAxi4_MainState_RESUME));
  assign when_UsbOhci_l463_1 = (reg_hcRhPortStatus_0_setPortSuspend && reg_hcRhPortStatus_0_CCS);
  assign when_UsbOhci_l464 = (reg_hcRhPortStatus_0_setPortSuspend && reg_hcRhPortStatus_0_CCS);
  assign when_UsbOhci_l465 = (reg_hcRhPortStatus_0_clearSuspendStatus && reg_hcRhPortStatus_0_PSS);
  assign when_UsbOhci_l466 = (reg_hcRhPortStatus_0_setPortReset && reg_hcRhPortStatus_0_CCS);
  assign when_UsbOhci_l472 = reg_hcRhDescriptorB_PPCM[0];
  assign reg_hcRhPortStatus_0_CSC_set = ((((reg_hcRhPortStatus_0_CCS ^ reg_hcRhPortStatus_0_CCS_regNext) || (reg_hcRhPortStatus_0_setPortEnable && (! reg_hcRhPortStatus_0_CCS))) || (reg_hcRhPortStatus_0_setPortSuspend && (! reg_hcRhPortStatus_0_CCS))) || (reg_hcRhPortStatus_0_setPortReset && (! reg_hcRhPortStatus_0_CCS)));
  assign reg_hcRhPortStatus_0_PESC_set = io_phy_ports_0_overcurrent;
  assign io_phy_ports_0_suspend_fire = (io_phy_ports_0_suspend_valid && io_phy_ports_0_suspend_ready);
  assign reg_hcRhPortStatus_0_PSSC_set = (io_phy_ports_0_suspend_fire || io_phy_ports_0_remoteResume);
  assign reg_hcRhPortStatus_0_OCIC_set = io_phy_ports_0_overcurrent;
  assign io_phy_ports_0_reset_fire = (io_phy_ports_0_reset_valid && io_phy_ports_0_reset_ready);
  assign reg_hcRhPortStatus_0_PRSC_set = io_phy_ports_0_reset_fire;
  assign io_phy_ports_0_disable_valid = reg_hcRhPortStatus_0_clearPortEnable;
  assign io_phy_ports_0_removable = reg_hcRhDescriptorB_DR[0];
  assign io_phy_ports_0_power = reg_hcRhPortStatus_0_PPS;
  assign io_phy_ports_0_resume_valid = reg_hcRhPortStatus_0_resume;
  assign io_phy_ports_0_resume_fire = (io_phy_ports_0_resume_valid && io_phy_ports_0_resume_ready);
  assign io_phy_ports_0_reset_valid = reg_hcRhPortStatus_0_reset;
  assign io_phy_ports_0_suspend_valid = reg_hcRhPortStatus_0_suspend;
  always @(*) begin
    reg_hcRhPortStatus_1_clearPortEnable = 1'b0;
    if(when_BusSlaveFactory_l377_29) begin
      if(when_BusSlaveFactory_l379_29) begin
        reg_hcRhPortStatus_1_clearPortEnable = _zz_reg_hcRhPortStatus_1_clearPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_29 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_29 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_29 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    reg_hcRhPortStatus_1_setPortEnable = 1'b0;
    if(when_BusSlaveFactory_l377_30) begin
      if(when_BusSlaveFactory_l379_30) begin
        reg_hcRhPortStatus_1_setPortEnable = _zz_reg_hcRhPortStatus_1_setPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_30 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_30 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_30 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    reg_hcRhPortStatus_1_setPortSuspend = 1'b0;
    if(when_BusSlaveFactory_l377_31) begin
      if(when_BusSlaveFactory_l379_31) begin
        reg_hcRhPortStatus_1_setPortSuspend = _zz_reg_hcRhPortStatus_1_setPortSuspend[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_31 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_31 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_31 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    reg_hcRhPortStatus_1_clearSuspendStatus = 1'b0;
    if(when_BusSlaveFactory_l377_32) begin
      if(when_BusSlaveFactory_l379_32) begin
        reg_hcRhPortStatus_1_clearSuspendStatus = _zz_reg_hcRhPortStatus_1_clearSuspendStatus[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_32 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_32 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_32 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    reg_hcRhPortStatus_1_setPortReset = 1'b0;
    if(when_BusSlaveFactory_l377_33) begin
      if(when_BusSlaveFactory_l379_33) begin
        reg_hcRhPortStatus_1_setPortReset = _zz_reg_hcRhPortStatus_1_setPortReset[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_33 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_33 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_33 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    reg_hcRhPortStatus_1_setPortPower = 1'b0;
    if(when_BusSlaveFactory_l377_34) begin
      if(when_BusSlaveFactory_l379_34) begin
        reg_hcRhPortStatus_1_setPortPower = _zz_reg_hcRhPortStatus_1_setPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_34 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_34 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_34 = io_ctrl_cmd_payload_fragment_data[8];
  always @(*) begin
    reg_hcRhPortStatus_1_clearPortPower = 1'b0;
    if(when_BusSlaveFactory_l377_35) begin
      if(when_BusSlaveFactory_l379_35) begin
        reg_hcRhPortStatus_1_clearPortPower = _zz_reg_hcRhPortStatus_1_clearPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_35 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_35 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_35 = io_ctrl_cmd_payload_fragment_data[9];
  assign reg_hcRhPortStatus_1_CCS = ((reg_hcRhPortStatus_1_connected || reg_hcRhDescriptorB_DR[1]) && reg_hcRhPortStatus_1_PPS);
  always @(*) begin
    reg_hcRhPortStatus_1_CSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_36) begin
      if(when_BusSlaveFactory_l379_36) begin
        reg_hcRhPortStatus_1_CSC_clear = _zz_reg_hcRhPortStatus_1_CSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_36 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_36 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_36 = io_ctrl_cmd_payload_fragment_data[16];
  always @(*) begin
    reg_hcRhPortStatus_1_PESC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_37) begin
      if(when_BusSlaveFactory_l379_37) begin
        reg_hcRhPortStatus_1_PESC_clear = _zz_reg_hcRhPortStatus_1_PESC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_37 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_37 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_37 = io_ctrl_cmd_payload_fragment_data[17];
  always @(*) begin
    reg_hcRhPortStatus_1_PSSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_38) begin
      if(when_BusSlaveFactory_l379_38) begin
        reg_hcRhPortStatus_1_PSSC_clear = _zz_reg_hcRhPortStatus_1_PSSC_clear[0];
      end
    end
    if(reg_hcRhPortStatus_1_PRSC_set) begin
      reg_hcRhPortStatus_1_PSSC_clear = 1'b1;
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_38 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_38 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_38 = io_ctrl_cmd_payload_fragment_data[18];
  always @(*) begin
    reg_hcRhPortStatus_1_OCIC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_39) begin
      if(when_BusSlaveFactory_l379_39) begin
        reg_hcRhPortStatus_1_OCIC_clear = _zz_reg_hcRhPortStatus_1_OCIC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_39 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_39 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_39 = io_ctrl_cmd_payload_fragment_data[19];
  always @(*) begin
    reg_hcRhPortStatus_1_PRSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_40) begin
      if(when_BusSlaveFactory_l379_40) begin
        reg_hcRhPortStatus_1_PRSC_clear = _zz_reg_hcRhPortStatus_1_PRSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_40 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_40 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_40 = io_ctrl_cmd_payload_fragment_data[20];
  assign when_UsbOhci_l462_3 = ((reg_hcRhPortStatus_1_clearPortEnable || reg_hcRhPortStatus_1_PESC_set) || (! reg_hcRhPortStatus_1_PPS));
  assign when_UsbOhci_l462_4 = (reg_hcRhPortStatus_1_PRSC_set || reg_hcRhPortStatus_1_PSSC_set);
  assign when_UsbOhci_l462_5 = (reg_hcRhPortStatus_1_setPortEnable && reg_hcRhPortStatus_1_CCS);
  assign when_UsbOhci_l463_2 = (((reg_hcRhPortStatus_1_PSSC_set || reg_hcRhPortStatus_1_PRSC_set) || (! reg_hcRhPortStatus_1_PPS)) || (reg_hcControl_HCFS == UsbOhciAxi4_MainState_RESUME));
  assign when_UsbOhci_l463_3 = (reg_hcRhPortStatus_1_setPortSuspend && reg_hcRhPortStatus_1_CCS);
  assign when_UsbOhci_l464_1 = (reg_hcRhPortStatus_1_setPortSuspend && reg_hcRhPortStatus_1_CCS);
  assign when_UsbOhci_l465_1 = (reg_hcRhPortStatus_1_clearSuspendStatus && reg_hcRhPortStatus_1_PSS);
  assign when_UsbOhci_l466_1 = (reg_hcRhPortStatus_1_setPortReset && reg_hcRhPortStatus_1_CCS);
  assign when_UsbOhci_l472_1 = reg_hcRhDescriptorB_PPCM[1];
  assign reg_hcRhPortStatus_1_CSC_set = ((((reg_hcRhPortStatus_1_CCS ^ reg_hcRhPortStatus_1_CCS_regNext) || (reg_hcRhPortStatus_1_setPortEnable && (! reg_hcRhPortStatus_1_CCS))) || (reg_hcRhPortStatus_1_setPortSuspend && (! reg_hcRhPortStatus_1_CCS))) || (reg_hcRhPortStatus_1_setPortReset && (! reg_hcRhPortStatus_1_CCS)));
  assign reg_hcRhPortStatus_1_PESC_set = io_phy_ports_1_overcurrent;
  assign io_phy_ports_1_suspend_fire = (io_phy_ports_1_suspend_valid && io_phy_ports_1_suspend_ready);
  assign reg_hcRhPortStatus_1_PSSC_set = (io_phy_ports_1_suspend_fire || io_phy_ports_1_remoteResume);
  assign reg_hcRhPortStatus_1_OCIC_set = io_phy_ports_1_overcurrent;
  assign io_phy_ports_1_reset_fire = (io_phy_ports_1_reset_valid && io_phy_ports_1_reset_ready);
  assign reg_hcRhPortStatus_1_PRSC_set = io_phy_ports_1_reset_fire;
  assign io_phy_ports_1_disable_valid = reg_hcRhPortStatus_1_clearPortEnable;
  assign io_phy_ports_1_removable = reg_hcRhDescriptorB_DR[1];
  assign io_phy_ports_1_power = reg_hcRhPortStatus_1_PPS;
  assign io_phy_ports_1_resume_valid = reg_hcRhPortStatus_1_resume;
  assign io_phy_ports_1_resume_fire = (io_phy_ports_1_resume_valid && io_phy_ports_1_resume_ready);
  assign io_phy_ports_1_reset_valid = reg_hcRhPortStatus_1_reset;
  assign io_phy_ports_1_suspend_valid = reg_hcRhPortStatus_1_suspend;
  always @(*) begin
    reg_hcRhPortStatus_2_clearPortEnable = 1'b0;
    if(when_BusSlaveFactory_l377_41) begin
      if(when_BusSlaveFactory_l379_41) begin
        reg_hcRhPortStatus_2_clearPortEnable = _zz_reg_hcRhPortStatus_2_clearPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_41 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_41 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_41 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    reg_hcRhPortStatus_2_setPortEnable = 1'b0;
    if(when_BusSlaveFactory_l377_42) begin
      if(when_BusSlaveFactory_l379_42) begin
        reg_hcRhPortStatus_2_setPortEnable = _zz_reg_hcRhPortStatus_2_setPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_42 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_42 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_42 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    reg_hcRhPortStatus_2_setPortSuspend = 1'b0;
    if(when_BusSlaveFactory_l377_43) begin
      if(when_BusSlaveFactory_l379_43) begin
        reg_hcRhPortStatus_2_setPortSuspend = _zz_reg_hcRhPortStatus_2_setPortSuspend[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_43 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_43 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_43 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    reg_hcRhPortStatus_2_clearSuspendStatus = 1'b0;
    if(when_BusSlaveFactory_l377_44) begin
      if(when_BusSlaveFactory_l379_44) begin
        reg_hcRhPortStatus_2_clearSuspendStatus = _zz_reg_hcRhPortStatus_2_clearSuspendStatus[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_44 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_44 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_44 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    reg_hcRhPortStatus_2_setPortReset = 1'b0;
    if(when_BusSlaveFactory_l377_45) begin
      if(when_BusSlaveFactory_l379_45) begin
        reg_hcRhPortStatus_2_setPortReset = _zz_reg_hcRhPortStatus_2_setPortReset[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_45 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_45 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_45 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    reg_hcRhPortStatus_2_setPortPower = 1'b0;
    if(when_BusSlaveFactory_l377_46) begin
      if(when_BusSlaveFactory_l379_46) begin
        reg_hcRhPortStatus_2_setPortPower = _zz_reg_hcRhPortStatus_2_setPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_46 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_46 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_46 = io_ctrl_cmd_payload_fragment_data[8];
  always @(*) begin
    reg_hcRhPortStatus_2_clearPortPower = 1'b0;
    if(when_BusSlaveFactory_l377_47) begin
      if(when_BusSlaveFactory_l379_47) begin
        reg_hcRhPortStatus_2_clearPortPower = _zz_reg_hcRhPortStatus_2_clearPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_47 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_47 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_47 = io_ctrl_cmd_payload_fragment_data[9];
  assign reg_hcRhPortStatus_2_CCS = ((reg_hcRhPortStatus_2_connected || reg_hcRhDescriptorB_DR[2]) && reg_hcRhPortStatus_2_PPS);
  always @(*) begin
    reg_hcRhPortStatus_2_CSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_48) begin
      if(when_BusSlaveFactory_l379_48) begin
        reg_hcRhPortStatus_2_CSC_clear = _zz_reg_hcRhPortStatus_2_CSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_48 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_48 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_48 = io_ctrl_cmd_payload_fragment_data[16];
  always @(*) begin
    reg_hcRhPortStatus_2_PESC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_49) begin
      if(when_BusSlaveFactory_l379_49) begin
        reg_hcRhPortStatus_2_PESC_clear = _zz_reg_hcRhPortStatus_2_PESC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_49 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_49 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_49 = io_ctrl_cmd_payload_fragment_data[17];
  always @(*) begin
    reg_hcRhPortStatus_2_PSSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_50) begin
      if(when_BusSlaveFactory_l379_50) begin
        reg_hcRhPortStatus_2_PSSC_clear = _zz_reg_hcRhPortStatus_2_PSSC_clear[0];
      end
    end
    if(reg_hcRhPortStatus_2_PRSC_set) begin
      reg_hcRhPortStatus_2_PSSC_clear = 1'b1;
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_50 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_50 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_50 = io_ctrl_cmd_payload_fragment_data[18];
  always @(*) begin
    reg_hcRhPortStatus_2_OCIC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_51) begin
      if(when_BusSlaveFactory_l379_51) begin
        reg_hcRhPortStatus_2_OCIC_clear = _zz_reg_hcRhPortStatus_2_OCIC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_51 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_51 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_51 = io_ctrl_cmd_payload_fragment_data[19];
  always @(*) begin
    reg_hcRhPortStatus_2_PRSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_52) begin
      if(when_BusSlaveFactory_l379_52) begin
        reg_hcRhPortStatus_2_PRSC_clear = _zz_reg_hcRhPortStatus_2_PRSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_52 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h05c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_52 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_52 = io_ctrl_cmd_payload_fragment_data[20];
  assign when_UsbOhci_l462_6 = ((reg_hcRhPortStatus_2_clearPortEnable || reg_hcRhPortStatus_2_PESC_set) || (! reg_hcRhPortStatus_2_PPS));
  assign when_UsbOhci_l462_7 = (reg_hcRhPortStatus_2_PRSC_set || reg_hcRhPortStatus_2_PSSC_set);
  assign when_UsbOhci_l462_8 = (reg_hcRhPortStatus_2_setPortEnable && reg_hcRhPortStatus_2_CCS);
  assign when_UsbOhci_l463_4 = (((reg_hcRhPortStatus_2_PSSC_set || reg_hcRhPortStatus_2_PRSC_set) || (! reg_hcRhPortStatus_2_PPS)) || (reg_hcControl_HCFS == UsbOhciAxi4_MainState_RESUME));
  assign when_UsbOhci_l463_5 = (reg_hcRhPortStatus_2_setPortSuspend && reg_hcRhPortStatus_2_CCS);
  assign when_UsbOhci_l464_2 = (reg_hcRhPortStatus_2_setPortSuspend && reg_hcRhPortStatus_2_CCS);
  assign when_UsbOhci_l465_2 = (reg_hcRhPortStatus_2_clearSuspendStatus && reg_hcRhPortStatus_2_PSS);
  assign when_UsbOhci_l466_2 = (reg_hcRhPortStatus_2_setPortReset && reg_hcRhPortStatus_2_CCS);
  assign when_UsbOhci_l472_2 = reg_hcRhDescriptorB_PPCM[2];
  assign reg_hcRhPortStatus_2_CSC_set = ((((reg_hcRhPortStatus_2_CCS ^ reg_hcRhPortStatus_2_CCS_regNext) || (reg_hcRhPortStatus_2_setPortEnable && (! reg_hcRhPortStatus_2_CCS))) || (reg_hcRhPortStatus_2_setPortSuspend && (! reg_hcRhPortStatus_2_CCS))) || (reg_hcRhPortStatus_2_setPortReset && (! reg_hcRhPortStatus_2_CCS)));
  assign reg_hcRhPortStatus_2_PESC_set = io_phy_ports_2_overcurrent;
  assign io_phy_ports_2_suspend_fire = (io_phy_ports_2_suspend_valid && io_phy_ports_2_suspend_ready);
  assign reg_hcRhPortStatus_2_PSSC_set = (io_phy_ports_2_suspend_fire || io_phy_ports_2_remoteResume);
  assign reg_hcRhPortStatus_2_OCIC_set = io_phy_ports_2_overcurrent;
  assign io_phy_ports_2_reset_fire = (io_phy_ports_2_reset_valid && io_phy_ports_2_reset_ready);
  assign reg_hcRhPortStatus_2_PRSC_set = io_phy_ports_2_reset_fire;
  assign io_phy_ports_2_disable_valid = reg_hcRhPortStatus_2_clearPortEnable;
  assign io_phy_ports_2_removable = reg_hcRhDescriptorB_DR[2];
  assign io_phy_ports_2_power = reg_hcRhPortStatus_2_PPS;
  assign io_phy_ports_2_resume_valid = reg_hcRhPortStatus_2_resume;
  assign io_phy_ports_2_resume_fire = (io_phy_ports_2_resume_valid && io_phy_ports_2_resume_ready);
  assign io_phy_ports_2_reset_valid = reg_hcRhPortStatus_2_reset;
  assign io_phy_ports_2_suspend_valid = reg_hcRhPortStatus_2_suspend;
  always @(*) begin
    reg_hcRhPortStatus_3_clearPortEnable = 1'b0;
    if(when_BusSlaveFactory_l377_53) begin
      if(when_BusSlaveFactory_l379_53) begin
        reg_hcRhPortStatus_3_clearPortEnable = _zz_reg_hcRhPortStatus_3_clearPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_53 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_53 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_53 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    reg_hcRhPortStatus_3_setPortEnable = 1'b0;
    if(when_BusSlaveFactory_l377_54) begin
      if(when_BusSlaveFactory_l379_54) begin
        reg_hcRhPortStatus_3_setPortEnable = _zz_reg_hcRhPortStatus_3_setPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_54 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_54 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_54 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    reg_hcRhPortStatus_3_setPortSuspend = 1'b0;
    if(when_BusSlaveFactory_l377_55) begin
      if(when_BusSlaveFactory_l379_55) begin
        reg_hcRhPortStatus_3_setPortSuspend = _zz_reg_hcRhPortStatus_3_setPortSuspend[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_55 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_55 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_55 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    reg_hcRhPortStatus_3_clearSuspendStatus = 1'b0;
    if(when_BusSlaveFactory_l377_56) begin
      if(when_BusSlaveFactory_l379_56) begin
        reg_hcRhPortStatus_3_clearSuspendStatus = _zz_reg_hcRhPortStatus_3_clearSuspendStatus[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_56 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_56 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_56 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    reg_hcRhPortStatus_3_setPortReset = 1'b0;
    if(when_BusSlaveFactory_l377_57) begin
      if(when_BusSlaveFactory_l379_57) begin
        reg_hcRhPortStatus_3_setPortReset = _zz_reg_hcRhPortStatus_3_setPortReset[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_57 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_57 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_57 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    reg_hcRhPortStatus_3_setPortPower = 1'b0;
    if(when_BusSlaveFactory_l377_58) begin
      if(when_BusSlaveFactory_l379_58) begin
        reg_hcRhPortStatus_3_setPortPower = _zz_reg_hcRhPortStatus_3_setPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_58 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_58 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_58 = io_ctrl_cmd_payload_fragment_data[8];
  always @(*) begin
    reg_hcRhPortStatus_3_clearPortPower = 1'b0;
    if(when_BusSlaveFactory_l377_59) begin
      if(when_BusSlaveFactory_l379_59) begin
        reg_hcRhPortStatus_3_clearPortPower = _zz_reg_hcRhPortStatus_3_clearPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_59 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_59 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_59 = io_ctrl_cmd_payload_fragment_data[9];
  assign reg_hcRhPortStatus_3_CCS = ((reg_hcRhPortStatus_3_connected || reg_hcRhDescriptorB_DR[3]) && reg_hcRhPortStatus_3_PPS);
  always @(*) begin
    reg_hcRhPortStatus_3_CSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_60) begin
      if(when_BusSlaveFactory_l379_60) begin
        reg_hcRhPortStatus_3_CSC_clear = _zz_reg_hcRhPortStatus_3_CSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_60 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_60 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_60 = io_ctrl_cmd_payload_fragment_data[16];
  always @(*) begin
    reg_hcRhPortStatus_3_PESC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_61) begin
      if(when_BusSlaveFactory_l379_61) begin
        reg_hcRhPortStatus_3_PESC_clear = _zz_reg_hcRhPortStatus_3_PESC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_61 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_61 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_61 = io_ctrl_cmd_payload_fragment_data[17];
  always @(*) begin
    reg_hcRhPortStatus_3_PSSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_62) begin
      if(when_BusSlaveFactory_l379_62) begin
        reg_hcRhPortStatus_3_PSSC_clear = _zz_reg_hcRhPortStatus_3_PSSC_clear[0];
      end
    end
    if(reg_hcRhPortStatus_3_PRSC_set) begin
      reg_hcRhPortStatus_3_PSSC_clear = 1'b1;
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_62 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_62 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_62 = io_ctrl_cmd_payload_fragment_data[18];
  always @(*) begin
    reg_hcRhPortStatus_3_OCIC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_63) begin
      if(when_BusSlaveFactory_l379_63) begin
        reg_hcRhPortStatus_3_OCIC_clear = _zz_reg_hcRhPortStatus_3_OCIC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_63 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_63 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_63 = io_ctrl_cmd_payload_fragment_data[19];
  always @(*) begin
    reg_hcRhPortStatus_3_PRSC_clear = 1'b0;
    if(when_BusSlaveFactory_l377_64) begin
      if(when_BusSlaveFactory_l379_64) begin
        reg_hcRhPortStatus_3_PRSC_clear = _zz_reg_hcRhPortStatus_3_PRSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l377_64 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h060 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l377_64 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l379_64 = io_ctrl_cmd_payload_fragment_data[20];
  assign when_UsbOhci_l462_9 = ((reg_hcRhPortStatus_3_clearPortEnable || reg_hcRhPortStatus_3_PESC_set) || (! reg_hcRhPortStatus_3_PPS));
  assign when_UsbOhci_l462_10 = (reg_hcRhPortStatus_3_PRSC_set || reg_hcRhPortStatus_3_PSSC_set);
  assign when_UsbOhci_l462_11 = (reg_hcRhPortStatus_3_setPortEnable && reg_hcRhPortStatus_3_CCS);
  assign when_UsbOhci_l463_6 = (((reg_hcRhPortStatus_3_PSSC_set || reg_hcRhPortStatus_3_PRSC_set) || (! reg_hcRhPortStatus_3_PPS)) || (reg_hcControl_HCFS == UsbOhciAxi4_MainState_RESUME));
  assign when_UsbOhci_l463_7 = (reg_hcRhPortStatus_3_setPortSuspend && reg_hcRhPortStatus_3_CCS);
  assign when_UsbOhci_l464_3 = (reg_hcRhPortStatus_3_setPortSuspend && reg_hcRhPortStatus_3_CCS);
  assign when_UsbOhci_l465_3 = (reg_hcRhPortStatus_3_clearSuspendStatus && reg_hcRhPortStatus_3_PSS);
  assign when_UsbOhci_l466_3 = (reg_hcRhPortStatus_3_setPortReset && reg_hcRhPortStatus_3_CCS);
  assign when_UsbOhci_l472_3 = reg_hcRhDescriptorB_PPCM[3];
  assign reg_hcRhPortStatus_3_CSC_set = ((((reg_hcRhPortStatus_3_CCS ^ reg_hcRhPortStatus_3_CCS_regNext) || (reg_hcRhPortStatus_3_setPortEnable && (! reg_hcRhPortStatus_3_CCS))) || (reg_hcRhPortStatus_3_setPortSuspend && (! reg_hcRhPortStatus_3_CCS))) || (reg_hcRhPortStatus_3_setPortReset && (! reg_hcRhPortStatus_3_CCS)));
  assign reg_hcRhPortStatus_3_PESC_set = io_phy_ports_3_overcurrent;
  assign io_phy_ports_3_suspend_fire = (io_phy_ports_3_suspend_valid && io_phy_ports_3_suspend_ready);
  assign reg_hcRhPortStatus_3_PSSC_set = (io_phy_ports_3_suspend_fire || io_phy_ports_3_remoteResume);
  assign reg_hcRhPortStatus_3_OCIC_set = io_phy_ports_3_overcurrent;
  assign io_phy_ports_3_reset_fire = (io_phy_ports_3_reset_valid && io_phy_ports_3_reset_ready);
  assign reg_hcRhPortStatus_3_PRSC_set = io_phy_ports_3_reset_fire;
  assign io_phy_ports_3_disable_valid = reg_hcRhPortStatus_3_clearPortEnable;
  assign io_phy_ports_3_removable = reg_hcRhDescriptorB_DR[3];
  assign io_phy_ports_3_power = reg_hcRhPortStatus_3_PPS;
  assign io_phy_ports_3_resume_valid = reg_hcRhPortStatus_3_resume;
  assign io_phy_ports_3_resume_fire = (io_phy_ports_3_resume_valid && io_phy_ports_3_resume_ready);
  assign io_phy_ports_3_reset_valid = reg_hcRhPortStatus_3_reset;
  assign io_phy_ports_3_suspend_valid = reg_hcRhPortStatus_3_suspend;
  always @(*) begin
    frame_run = 1'b0;
    case(hc_stateReg)
      UsbOhciAxi4_hc_enumDef_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_RESUME : begin
      end
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : begin
        frame_run = 1'b1;
      end
      UsbOhciAxi4_hc_enumDef_SUSPEND : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frame_reload = 1'b0;
    if(when_UsbOhci_l528) begin
      if(frame_overflow) begin
        frame_reload = 1'b1;
      end
    end
    if(when_StateMachine_l253_7) begin
      frame_reload = 1'b1;
    end
  end

  assign frame_overflow = (reg_hcFmRemaining_FR == 14'h0000);
  always @(*) begin
    frame_tick = 1'b0;
    if(when_UsbOhci_l528) begin
      if(frame_overflow) begin
        frame_tick = 1'b1;
      end
    end
  end

  assign frame_section1 = (reg_hcPeriodicStart_PS < reg_hcFmRemaining_FR);
  assign frame_limitHit = (frame_limitCounter == 15'h0000);
  assign frame_decrementTimerOverflow = (frame_decrementTimer == 3'b110);
  assign when_UsbOhci_l528 = (frame_run && io_phy_tick);
  assign when_UsbOhci_l530 = ((! frame_limitHit) && (! frame_decrementTimerOverflow));
  assign when_UsbOhci_l542 = (reg_hcFmNumber_FNp1[15] ^ reg_hcFmNumber_FN[15]);
  always @(*) begin
    token_wantExit = 1'b0;
    case(token_stateReg)
      UsbOhciAxi4_token_enumDef_INIT : begin
      end
      UsbOhciAxi4_token_enumDef_PID : begin
      end
      UsbOhciAxi4_token_enumDef_B1 : begin
      end
      UsbOhciAxi4_token_enumDef_B2 : begin
      end
      UsbOhciAxi4_token_enumDef_EOP : begin
        if(io_phy_txEop) begin
          token_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    token_wantStart = 1'b0;
    if(when_StateMachine_l237_1) begin
      token_wantStart = 1'b1;
    end
    if(when_StateMachine_l253_1) begin
      token_wantStart = 1'b1;
    end
  end

  always @(*) begin
    token_wantKill = 1'b0;
    if(unscheduleAll_fire) begin
      token_wantKill = 1'b1;
    end
  end

  always @(*) begin
    token_pid = 4'bxxxx;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
        token_pid = 4'b0101;
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
        case(endpoint_tockenType)
          2'b00 : begin
            token_pid = 4'b1101;
          end
          2'b01 : begin
            token_pid = 4'b0001;
          end
          2'b10 : begin
            token_pid = 4'b1001;
          end
          default : begin
          end
        endcase
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    token_data = 11'bxxxxxxxxxxx;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
        token_data = _zz_token_data[10:0];
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
        token_data = {endpoint_ED_EN,endpoint_ED_FA};
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    token_crc5_io_flush = 1'b0;
    if(when_StateMachine_l237) begin
      token_crc5_io_flush = 1'b1;
    end
  end

  always @(*) begin
    token_crc5_io_input_valid = 1'b0;
    case(token_stateReg)
      UsbOhciAxi4_token_enumDef_INIT : begin
        token_crc5_io_input_valid = 1'b1;
      end
      UsbOhciAxi4_token_enumDef_PID : begin
      end
      UsbOhciAxi4_token_enumDef_B1 : begin
      end
      UsbOhciAxi4_token_enumDef_B2 : begin
      end
      UsbOhciAxi4_token_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_wantExit = 1'b0;
    case(dataTx_stateReg)
      UsbOhciAxi4_dataTx_enumDef_PID : begin
      end
      UsbOhciAxi4_dataTx_enumDef_DATA : begin
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_0 : begin
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_1 : begin
      end
      UsbOhciAxi4_dataTx_enumDef_EOP : begin
        if(io_phy_txEop) begin
          dataTx_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_wantStart = 1'b0;
    if(when_StateMachine_l253_2) begin
      dataTx_wantStart = 1'b1;
    end
  end

  always @(*) begin
    dataTx_wantKill = 1'b0;
    if(unscheduleAll_fire) begin
      dataTx_wantKill = 1'b1;
    end
  end

  always @(*) begin
    dataTx_pid = 4'bxxxx;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
        dataTx_pid = {endpoint_dataPhase,3'b011};
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_data_valid = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
        dataTx_data_valid = 1'b1;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_data_payload_last = 1'bx;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
        dataTx_data_payload_last = endpoint_dmaLogic_byteCtx_last;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_data_payload_fragment = 8'bxxxxxxxx;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
        dataTx_data_payload_fragment = _zz_dataTx_data_payload_fragment;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_data_ready = 1'b0;
    case(dataTx_stateReg)
      UsbOhciAxi4_dataTx_enumDef_PID : begin
      end
      UsbOhciAxi4_dataTx_enumDef_DATA : begin
        if(io_phy_tx_ready) begin
          dataTx_data_ready = 1'b1;
        end
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_0 : begin
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_1 : begin
      end
      UsbOhciAxi4_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
  end

  assign dataTx_data_fire = (dataTx_data_valid && dataTx_data_ready);
  always @(*) begin
    dataTx_crc16_io_flush = 1'b0;
    case(dataTx_stateReg)
      UsbOhciAxi4_dataTx_enumDef_PID : begin
        dataTx_crc16_io_flush = 1'b1;
      end
      UsbOhciAxi4_dataTx_enumDef_DATA : begin
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_0 : begin
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_1 : begin
      end
      UsbOhciAxi4_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    rxTimer_clear = 1'b0;
    if(io_phy_rx_active) begin
      rxTimer_clear = 1'b1;
    end
    if(when_StateMachine_l253) begin
      rxTimer_clear = 1'b1;
    end
    if(when_StateMachine_l253_4) begin
      rxTimer_clear = 1'b1;
    end
  end

  assign rxTimer_rxTimeout = (rxTimer_counter == (rxTimer_lowSpeed ? 8'hbf : 8'h17));
  assign rxTimer_ackTx = (rxTimer_counter == _zz_rxTimer_ackTx);
  assign rxPidOk = (io_phy_rx_flow_payload_data[3 : 0] == (~ io_phy_rx_flow_payload_data[7 : 4]));
  assign _zz_1 = io_phy_rx_flow_valid;
  assign _zz_dataRx_pid = io_phy_rx_flow_payload_data;
  assign when_Misc_l87 = (io_phy_rx_flow_valid && io_phy_rx_flow_payload_stuffingError);
  always @(*) begin
    dataRx_wantExit = 1'b0;
    case(dataRx_stateReg)
      UsbOhciAxi4_dataRx_enumDef_IDLE : begin
        if(!io_phy_rx_active) begin
          if(rxTimer_rxTimeout) begin
            dataRx_wantExit = 1'b1;
          end
        end
      end
      UsbOhciAxi4_dataRx_enumDef_PID : begin
        if(!_zz_1) begin
          if(when_Misc_l64) begin
            dataRx_wantExit = 1'b1;
          end
        end
      end
      UsbOhciAxi4_dataRx_enumDef_DATA : begin
        if(when_Misc_l70) begin
          dataRx_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataRx_wantStart = 1'b0;
    if(when_StateMachine_l253_3) begin
      dataRx_wantStart = 1'b1;
    end
  end

  always @(*) begin
    dataRx_wantKill = 1'b0;
    if(unscheduleAll_fire) begin
      dataRx_wantKill = 1'b1;
    end
  end

  assign dataRx_history_0 = _zz_dataRx_history_0;
  assign dataRx_history_1 = _zz_dataRx_history_1;
  assign dataRx_hasError = (|{dataRx_crcError,{dataRx_pidError,{dataRx_stuffingError,dataRx_notResponding}}});
  always @(*) begin
    dataRx_data_valid = 1'b0;
    case(dataRx_stateReg)
      UsbOhciAxi4_dataRx_enumDef_IDLE : begin
      end
      UsbOhciAxi4_dataRx_enumDef_PID : begin
      end
      UsbOhciAxi4_dataRx_enumDef_DATA : begin
        if(!when_Misc_l70) begin
          if(_zz_1) begin
            if(when_Misc_l78) begin
              dataRx_data_valid = 1'b1;
            end
          end
        end
      end
      default : begin
      end
    endcase
  end

  assign dataRx_data_payload = dataRx_history_1;
  always @(*) begin
    dataRx_crc16_io_input_valid = 1'b0;
    case(dataRx_stateReg)
      UsbOhciAxi4_dataRx_enumDef_IDLE : begin
      end
      UsbOhciAxi4_dataRx_enumDef_PID : begin
      end
      UsbOhciAxi4_dataRx_enumDef_DATA : begin
        if(!when_Misc_l70) begin
          if(_zz_1) begin
            dataRx_crc16_io_input_valid = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataRx_crc16_io_flush = 1'b0;
    case(dataRx_stateReg)
      UsbOhciAxi4_dataRx_enumDef_IDLE : begin
      end
      UsbOhciAxi4_dataRx_enumDef_PID : begin
        dataRx_crc16_io_flush = 1'b1;
      end
      UsbOhciAxi4_dataRx_enumDef_DATA : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    sof_wantExit = 1'b0;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          sof_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    sof_wantStart = 1'b0;
    if(when_StateMachine_l253_6) begin
      sof_wantStart = 1'b1;
    end
  end

  always @(*) begin
    sof_wantKill = 1'b0;
    if(unscheduleAll_fire) begin
      sof_wantKill = 1'b1;
    end
  end

  always @(*) begin
    priority_tick = 1'b0;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(when_UsbOhci_l1420) begin
            priority_tick = 1'b1;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    priority_skip = 1'b0;
    if(priority_tick) begin
      if(when_UsbOhci_l665) begin
        priority_skip = 1'b1;
      end
    end
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
        if(!operational_askExit) begin
          if(!frame_limitHit) begin
            if(!when_UsbOhci_l1489) begin
              priority_skip = 1'b1;
              if(priority_bulk) begin
                if(operational_allowBulk) begin
                  if(reg_hcBulkCurrentED_isZero) begin
                    if(reg_hcCommandStatus_BLF) begin
                      priority_skip = 1'b0;
                    end
                  end else begin
                    priority_skip = 1'b0;
                  end
                end
              end else begin
                if(operational_allowControl) begin
                  if(reg_hcControlCurrentED_isZero) begin
                    if(reg_hcCommandStatus_CLF) begin
                      priority_skip = 1'b0;
                    end
                  end else begin
                    priority_skip = 1'b0;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UsbOhci_l665 = (priority_bulk || (priority_counter == reg_hcControl_CBSR));
  always @(*) begin
    interruptDelay_tick = 1'b0;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          interruptDelay_tick = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign interruptDelay_done = (interruptDelay_counter == 3'b000);
  assign interruptDelay_disabled = (interruptDelay_counter == 3'b111);
  always @(*) begin
    interruptDelay_disable = 1'b0;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          if(sof_doInterruptDelay) begin
            interruptDelay_disable = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l237_3) begin
      interruptDelay_disable = 1'b1;
    end
  end

  always @(*) begin
    interruptDelay_load_valid = 1'b0;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(endpoint_TD_retire) begin
            interruptDelay_load_valid = 1'b1;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    interruptDelay_load_payload = 3'bxxx;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(endpoint_TD_retire) begin
            interruptDelay_load_payload = endpoint_TD_DI;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UsbOhci_l687 = ((interruptDelay_tick && (! interruptDelay_done)) && (! interruptDelay_disabled));
  assign when_UsbOhci_l691 = (interruptDelay_load_valid && (interruptDelay_load_payload < interruptDelay_counter));
  always @(*) begin
    endpoint_wantExit = 1'b0;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
        if(when_UsbOhci_l863) begin
          endpoint_wantExit = 1'b1;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          endpoint_wantExit = 1'b1;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
        endpoint_wantExit = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    endpoint_wantStart = 1'b0;
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
        if(!operational_askExit) begin
          if(!frame_limitHit) begin
            if(when_UsbOhci_l1489) begin
              if(!when_UsbOhci_l1490) begin
                if(!reg_hcPeriodCurrentED_isZero) begin
                  endpoint_wantStart = 1'b1;
                end
              end
            end else begin
              if(priority_bulk) begin
                if(operational_allowBulk) begin
                  if(!reg_hcBulkCurrentED_isZero) begin
                    endpoint_wantStart = 1'b1;
                  end
                end
              end else begin
                if(operational_allowControl) begin
                  if(!reg_hcControlCurrentED_isZero) begin
                    endpoint_wantStart = 1'b1;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    endpoint_wantKill = 1'b0;
    if(unscheduleAll_fire) begin
      endpoint_wantKill = 1'b1;
    end
  end

  assign endpoint_ED_FA = endpoint_ED_words_0[6 : 0];
  assign endpoint_ED_EN = endpoint_ED_words_0[10 : 7];
  assign endpoint_ED_D = endpoint_ED_words_0[12 : 11];
  assign endpoint_ED_S = endpoint_ED_words_0[13];
  assign endpoint_ED_K = endpoint_ED_words_0[14];
  assign endpoint_ED_F = endpoint_ED_words_0[15];
  assign endpoint_ED_MPS = endpoint_ED_words_0[26 : 16];
  assign endpoint_ED_tailP = endpoint_ED_words_1[31 : 4];
  assign endpoint_ED_H = endpoint_ED_words_2[0];
  assign endpoint_ED_C = endpoint_ED_words_2[1];
  assign endpoint_ED_headP = endpoint_ED_words_2[31 : 4];
  assign endpoint_ED_nextED = endpoint_ED_words_3[31 : 4];
  assign endpoint_ED_tdEmpty = (endpoint_ED_tailP == endpoint_ED_headP);
  assign endpoint_ED_isFs = (! endpoint_ED_S);
  assign endpoint_ED_isoOut = endpoint_ED_D[0];
  assign when_UsbOhci_l752 = (! (endpoint_stateReg == UsbOhciAxi4_endpoint_enumDef_BOOT));
  assign rxTimer_lowSpeed = endpoint_ED_S;
  assign endpoint_TD_address = ({4'd0,endpoint_ED_headP} <<< 3'd4);
  assign endpoint_TD_CC = endpoint_TD_words_0[31 : 28];
  assign endpoint_TD_EC = endpoint_TD_words_0[27 : 26];
  assign endpoint_TD_T = endpoint_TD_words_0[25 : 24];
  assign endpoint_TD_DI = endpoint_TD_words_0[23 : 21];
  assign endpoint_TD_DP = endpoint_TD_words_0[20 : 19];
  assign endpoint_TD_R = endpoint_TD_words_0[18];
  assign endpoint_TD_CBP = endpoint_TD_words_1[31 : 0];
  assign endpoint_TD_nextTD = endpoint_TD_words_2[31 : 4];
  assign endpoint_TD_BE = endpoint_TD_words_3[31 : 0];
  assign endpoint_TD_FC = endpoint_TD_words_0[26 : 24];
  assign endpoint_TD_SF = endpoint_TD_words_0[15 : 0];
  assign endpoint_TD_isoRelativeFrameNumber = (reg_hcFmNumber_FN - endpoint_TD_SF);
  assign endpoint_TD_tooEarly = endpoint_TD_isoRelativeFrameNumber[15];
  assign endpoint_TD_isoFrameNumber = endpoint_TD_isoRelativeFrameNumber[2 : 0];
  assign endpoint_TD_isoOverrun = ((! endpoint_TD_tooEarly) && (_zz_endpoint_TD_isoOverrun < endpoint_TD_isoRelativeFrameNumber));
  assign endpoint_TD_isoLast = (((! endpoint_TD_isoOverrun) && (! endpoint_TD_tooEarly)) && (endpoint_TD_isoFrameNumber == endpoint_TD_FC));
  assign endpoint_TD_isSinglePage = (endpoint_TD_CBP[31 : 12] == endpoint_TD_BE[31 : 12]);
  assign endpoint_TD_firstOffset = (endpoint_ED_F ? endpoint_TD_isoBase : _zz_endpoint_TD_firstOffset);
  assign endpoint_TD_allowRounding = ((! endpoint_ED_F) && endpoint_TD_R);
  assign endpoint_TD_TNext = (endpoint_TD_dataPhaseUpdate ? {1'b1,(! endpoint_dataPhase)} : endpoint_TD_T);
  assign endpoint_TD_dataPhaseNext = (endpoint_dataPhase ^ endpoint_TD_dataPhaseUpdate);
  assign endpoint_TD_dataPid = (endpoint_dataPhase ? 4'b1011 : 4'b0011);
  assign endpoint_TD_dataPidWrong = (endpoint_dataPhase ? 4'b0011 : 4'b1011);
  always @(*) begin
    endpoint_TD_clear = 1'b0;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
        endpoint_TD_clear = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  assign endpoint_tockenType = ((endpoint_ED_D[0] != endpoint_ED_D[1]) ? endpoint_ED_D : endpoint_TD_DP);
  assign endpoint_isIn = (endpoint_tockenType == 2'b10);
  always @(*) begin
    endpoint_applyNextED = 1'b0;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
        if(when_UsbOhci_l863) begin
          endpoint_applyNextED = 1'b1;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(when_UsbOhci_l1417) begin
            endpoint_applyNextED = 1'b1;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  assign endpoint_currentAddressFull = {(endpoint_currentAddress[12] ? endpoint_TD_BE[31 : 12] : endpoint_TD_CBP[31 : 12]),endpoint_currentAddress[11 : 0]};
  assign _zz_3 = zz__zz_endpoint_currentAddressBmb(1'b0);
  always @(*) _zz_endpoint_currentAddressBmb = _zz_3;
  assign endpoint_currentAddressBmb = (endpoint_currentAddressFull & _zz_endpoint_currentAddressBmb);
  assign endpoint_transactionSizeMinusOne = (_zz_endpoint_transactionSizeMinusOne - endpoint_currentAddress);
  assign endpoint_transactionSize = (endpoint_transactionSizeMinusOne + 14'h0001);
  assign endpoint_dataDone = (endpoint_zeroLength || (_zz_endpoint_dataDone < endpoint_currentAddress));
  always @(*) begin
    endpoint_dmaLogic_wantExit = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
        if(dataTx_data_ready) begin
          if(endpoint_dmaLogic_byteCtx_last) begin
            endpoint_dmaLogic_wantExit = 1'b1;
          end
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
        if(when_UsbOhci_l1070) begin
          endpoint_dmaLogic_wantExit = 1'b1;
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
        if(endpoint_dataDone) begin
          if(endpoint_isIn) begin
            endpoint_dmaLogic_wantExit = 1'b1;
          end
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    endpoint_dmaLogic_wantStart = 1'b0;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
        if(!endpoint_timeCheck) begin
          if(!when_UsbOhci_l1120) begin
            endpoint_dmaLogic_wantStart = 1'b1;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_3) begin
      endpoint_dmaLogic_wantStart = 1'b1;
    end
  end

  always @(*) begin
    endpoint_dmaLogic_wantKill = 1'b0;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
        if(when_UsbOhci_l1130) begin
          if(endpoint_timeCheck) begin
            endpoint_dmaLogic_wantKill = 1'b1;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    if(unscheduleAll_fire) begin
      endpoint_dmaLogic_wantKill = 1'b1;
    end
  end

  always @(*) begin
    endpoint_dmaLogic_validated = 1'b0;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
        endpoint_dmaLogic_validated = 1'b1;
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  assign endpoint_dmaLogic_lengthMax = (~ _zz_endpoint_dmaLogic_lengthMax);
  assign endpoint_dmaLogic_lengthCalc = _zz_endpoint_dmaLogic_lengthCalc[5:0];
  assign endpoint_dmaLogic_beatCount = _zz_endpoint_dmaLogic_beatCount[6 : 2];
  assign endpoint_dmaLogic_lengthBmb = _zz_endpoint_dmaLogic_lengthBmb[5:0];
  assign endpoint_dmaLogic_underflowError = (endpoint_dmaLogic_underflow && (! endpoint_TD_allowRounding));
  assign when_UsbOhci_l940 = (((! (endpoint_dmaLogic_stateReg == UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT)) && (! endpoint_isIn)) && ioDma_rsp_valid);
  assign endpoint_dmaLogic_byteCtx_last = (endpoint_dmaLogic_byteCtx_counter == endpoint_lastAddress);
  assign endpoint_dmaLogic_byteCtx_sel = endpoint_dmaLogic_byteCtx_counter[1:0];
  always @(*) begin
    endpoint_dmaLogic_byteCtx_increment = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
        if(dataTx_data_ready) begin
          endpoint_dmaLogic_byteCtx_increment = 1'b1;
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
        if(dataRx_data_valid) begin
          endpoint_dmaLogic_byteCtx_increment = 1'b1;
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  assign endpoint_dmaLogic_headMask = {(endpoint_currentAddress[1 : 0] <= 2'b11),{(endpoint_currentAddress[1 : 0] <= 2'b10),{(endpoint_currentAddress[1 : 0] <= 2'b01),(endpoint_currentAddress[1 : 0] <= 2'b00)}}};
  assign endpoint_dmaLogic_lastMask = {(2'b11 <= _zz_endpoint_dmaLogic_lastMask[1 : 0]),{(2'b10 <= _zz_endpoint_dmaLogic_lastMask_2[1 : 0]),{(2'b01 <= _zz_endpoint_dmaLogic_lastMask_4[1 : 0]),(2'b00 <= _zz_endpoint_dmaLogic_lastMask_6[1 : 0])}}};
  assign endpoint_dmaLogic_fullMask = 4'b1111;
  assign endpoint_dmaLogic_beatLast = (dmaCtx_beatCounter == _zz_endpoint_dmaLogic_beatLast);
  assign endpoint_byteCountCalc = (_zz_endpoint_byteCountCalc + 14'h0001);
  assign endpoint_fsTimeCheck = (endpoint_zeroLength ? (frame_limitCounter == 15'h0000) : (_zz_endpoint_fsTimeCheck <= _zz_endpoint_fsTimeCheck_1));
  assign endpoint_timeCheck = ((endpoint_ED_isFs && endpoint_fsTimeCheck) || (endpoint_ED_S && reg_hcLSThreshold_hit));
  assign endpoint_tdUpdateAddress = ((endpoint_TD_retire && (! ((endpoint_isIn && ((endpoint_TD_CC == 4'b0000) || (endpoint_TD_CC == 4'b1001))) && endpoint_dmaLogic_underflow))) ? 32'h00000000 : endpoint_currentAddressFull);
  always @(*) begin
    operational_wantExit = 1'b0;
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
        if(operational_askExit) begin
          operational_wantExit = 1'b1;
        end
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    operational_wantStart = 1'b0;
    if(when_StateMachine_l253_7) begin
      operational_wantStart = 1'b1;
    end
  end

  always @(*) begin
    operational_wantKill = 1'b0;
    if(unscheduleAll_fire) begin
      operational_wantKill = 1'b1;
    end
  end

  always @(*) begin
    operational_askExit = 1'b0;
    case(hc_stateReg)
      UsbOhciAxi4_hc_enumDef_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_RESUME : begin
      end
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciAxi4_hc_enumDef_SUSPEND : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : begin
        operational_askExit = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign hc_wantExit = 1'b0;
  always @(*) begin
    hc_wantStart = 1'b0;
    case(hc_stateReg)
      UsbOhciAxi4_hc_enumDef_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_RESUME : begin
      end
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciAxi4_hc_enumDef_SUSPEND : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : begin
      end
      default : begin
        hc_wantStart = 1'b1;
      end
    endcase
  end

  assign hc_wantKill = 1'b0;
  always @(*) begin
    reg_hcControl_HCFS = UsbOhciAxi4_MainState_RESET;
    case(hc_stateReg)
      UsbOhciAxi4_hc_enumDef_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_RESUME : begin
        reg_hcControl_HCFS = UsbOhciAxi4_MainState_RESUME;
      end
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : begin
        reg_hcControl_HCFS = UsbOhciAxi4_MainState_OPERATIONAL;
      end
      UsbOhciAxi4_hc_enumDef_SUSPEND : begin
        reg_hcControl_HCFS = UsbOhciAxi4_MainState_SUSPEND;
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : begin
        reg_hcControl_HCFS = UsbOhciAxi4_MainState_RESET;
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : begin
        reg_hcControl_HCFS = UsbOhciAxi4_MainState_SUSPEND;
      end
      default : begin
      end
    endcase
  end

  assign io_phy_usbReset = (reg_hcControl_HCFS == UsbOhciAxi4_MainState_RESET);
  assign io_phy_usbResume = (reg_hcControl_HCFS == UsbOhciAxi4_MainState_RESUME);
  always @(*) begin
    hc_error = 1'b0;
    case(hc_stateReg)
      UsbOhciAxi4_hc_enumDef_RESET : begin
        if(reg_hcControl_HCFSWrite_valid) begin
          case(reg_hcControl_HCFSWrite_payload)
            UsbOhciAxi4_MainState_OPERATIONAL : begin
            end
            default : begin
              hc_error = 1'b1;
            end
          endcase
        end
      end
      UsbOhciAxi4_hc_enumDef_RESUME : begin
      end
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciAxi4_hc_enumDef_SUSPEND : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : begin
      end
      default : begin
      end
    endcase
  end

  assign _zz_reg_hcControl_HCFSWrite_payload = io_ctrl_cmd_payload_fragment_data[7 : 6];
  assign reg_hcControl_HCFSWrite_payload = _zz_reg_hcControl_HCFSWrite_payload;
  assign when_BusSlaveFactory_l1041 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_1 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_2 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_3 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_4 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_5 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_6 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_7 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_8 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_9 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l1041_10 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l1041_11 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_12 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_13 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l1041_14 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l1041_15 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_16 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_17 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l1041_18 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l1041_19 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_20 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_21 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l1041_22 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l1041_23 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_24 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_25 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l1041_26 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l1041_27 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_28 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_29 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l1041_30 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l1041_31 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_32 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_33 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l1041_34 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l1041_35 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l1041_36 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_37 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_38 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_39 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_40 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_41 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_42 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_43 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l1041_44 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l1041_45 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l1041_46 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_UsbOhci_l255 = (doSoftReset || _zz_when_UsbOhci_l255);
  always @(*) begin
    token_stateNext = token_stateReg;
    case(token_stateReg)
      UsbOhciAxi4_token_enumDef_INIT : begin
        token_stateNext = UsbOhciAxi4_token_enumDef_PID;
      end
      UsbOhciAxi4_token_enumDef_PID : begin
        if(io_phy_tx_ready) begin
          token_stateNext = UsbOhciAxi4_token_enumDef_B1;
        end
      end
      UsbOhciAxi4_token_enumDef_B1 : begin
        if(io_phy_tx_ready) begin
          token_stateNext = UsbOhciAxi4_token_enumDef_B2;
        end
      end
      UsbOhciAxi4_token_enumDef_B2 : begin
        if(io_phy_tx_ready) begin
          token_stateNext = UsbOhciAxi4_token_enumDef_EOP;
        end
      end
      UsbOhciAxi4_token_enumDef_EOP : begin
        if(io_phy_txEop) begin
          token_stateNext = UsbOhciAxi4_token_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(token_wantStart) begin
      token_stateNext = UsbOhciAxi4_token_enumDef_INIT;
    end
    if(token_wantKill) begin
      token_stateNext = UsbOhciAxi4_token_enumDef_BOOT;
    end
  end

  assign when_StateMachine_l237 = ((token_stateReg == UsbOhciAxi4_token_enumDef_BOOT) && (! (token_stateNext == UsbOhciAxi4_token_enumDef_BOOT)));
  assign unscheduleAll_fire = (unscheduleAll_valid && unscheduleAll_ready);
  always @(*) begin
    dataTx_stateNext = dataTx_stateReg;
    case(dataTx_stateReg)
      UsbOhciAxi4_dataTx_enumDef_PID : begin
        if(io_phy_tx_ready) begin
          if(dataTx_data_valid) begin
            dataTx_stateNext = UsbOhciAxi4_dataTx_enumDef_DATA;
          end else begin
            dataTx_stateNext = UsbOhciAxi4_dataTx_enumDef_CRC_0;
          end
        end
      end
      UsbOhciAxi4_dataTx_enumDef_DATA : begin
        if(io_phy_tx_ready) begin
          if(dataTx_data_payload_last) begin
            dataTx_stateNext = UsbOhciAxi4_dataTx_enumDef_CRC_0;
          end
        end
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_0 : begin
        if(io_phy_tx_ready) begin
          dataTx_stateNext = UsbOhciAxi4_dataTx_enumDef_CRC_1;
        end
      end
      UsbOhciAxi4_dataTx_enumDef_CRC_1 : begin
        if(io_phy_tx_ready) begin
          dataTx_stateNext = UsbOhciAxi4_dataTx_enumDef_EOP;
        end
      end
      UsbOhciAxi4_dataTx_enumDef_EOP : begin
        if(io_phy_txEop) begin
          dataTx_stateNext = UsbOhciAxi4_dataTx_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(dataTx_wantStart) begin
      dataTx_stateNext = UsbOhciAxi4_dataTx_enumDef_PID;
    end
    if(dataTx_wantKill) begin
      dataTx_stateNext = UsbOhciAxi4_dataTx_enumDef_BOOT;
    end
  end

  always @(*) begin
    dataRx_stateNext = dataRx_stateReg;
    case(dataRx_stateReg)
      UsbOhciAxi4_dataRx_enumDef_IDLE : begin
        if(io_phy_rx_active) begin
          dataRx_stateNext = UsbOhciAxi4_dataRx_enumDef_PID;
        end else begin
          if(rxTimer_rxTimeout) begin
            dataRx_stateNext = UsbOhciAxi4_dataRx_enumDef_BOOT;
          end
        end
      end
      UsbOhciAxi4_dataRx_enumDef_PID : begin
        if(_zz_1) begin
          dataRx_stateNext = UsbOhciAxi4_dataRx_enumDef_DATA;
        end else begin
          if(when_Misc_l64) begin
            dataRx_stateNext = UsbOhciAxi4_dataRx_enumDef_BOOT;
          end
        end
      end
      UsbOhciAxi4_dataRx_enumDef_DATA : begin
        if(when_Misc_l70) begin
          dataRx_stateNext = UsbOhciAxi4_dataRx_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(dataRx_wantStart) begin
      dataRx_stateNext = UsbOhciAxi4_dataRx_enumDef_IDLE;
    end
    if(dataRx_wantKill) begin
      dataRx_stateNext = UsbOhciAxi4_dataRx_enumDef_BOOT;
    end
  end

  assign when_Misc_l64 = (! io_phy_rx_active);
  assign when_Misc_l70 = (! io_phy_rx_active);
  assign when_Misc_l71 = ((! (&dataRx_valids)) || (dataRx_crc16_io_result != 16'h800d));
  assign when_Misc_l78 = (&dataRx_valids);
  assign when_StateMachine_l253 = ((! (dataRx_stateReg == UsbOhciAxi4_dataRx_enumDef_IDLE)) && (dataRx_stateNext == UsbOhciAxi4_dataRx_enumDef_IDLE));
  assign when_Misc_l85 = (! (dataRx_stateReg == UsbOhciAxi4_dataRx_enumDef_BOOT));
  always @(*) begin
    sof_stateNext = sof_stateReg;
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
        if(token_wantExit) begin
          sof_stateNext = UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD;
        end
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
        if(when_UsbOhci_l628) begin
          sof_stateNext = UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP;
        end
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          sof_stateNext = UsbOhciAxi4_sof_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(sof_wantStart) begin
      sof_stateNext = UsbOhciAxi4_sof_enumDef_FRAME_TX;
    end
    if(sof_wantKill) begin
      sof_stateNext = UsbOhciAxi4_sof_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l207 = (dmaWriteCtx_counter == 4'b0000);
  assign when_UsbOhci_l207_1 = (dmaWriteCtx_counter == 4'b0001);
  assign when_UsbOhci_l628 = (ioDma_cmd_ready && ioDma_cmd_payload_last);
  assign when_StateMachine_l237_1 = ((sof_stateReg == UsbOhciAxi4_sof_enumDef_BOOT) && (! (sof_stateNext == UsbOhciAxi4_sof_enumDef_BOOT)));
  always @(*) begin
    endpoint_stateNext = endpoint_stateReg;
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
        if(ioDma_cmd_ready) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
        if(when_UsbOhci_l857) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
        if(when_UsbOhci_l863) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_BOOT;
        end else begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
        if(ioDma_cmd_ready) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
        if(when_UsbOhci_l900) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
        endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE;
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
        endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME;
        if(endpoint_ED_F) begin
          if(endpoint_TD_tooEarlyReg) begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC;
          end
          if(endpoint_TD_isoOverrunReg) begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
        if(endpoint_timeCheck) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ABORD;
        end else begin
          if(when_UsbOhci_l1120) begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_TOKEN;
          end else begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_BUFFER_READ;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
        if(when_UsbOhci_l1130) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_TOKEN;
          if(endpoint_timeCheck) begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ABORD;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
        if(token_wantExit) begin
          if(endpoint_isIn) begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_DATA_RX;
          end else begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_DATA_TX;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
        if(dataTx_wantExit) begin
          if(endpoint_ED_F) begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS;
          end else begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ACK_RX;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
        if(dataRx_wantExit) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
        endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA;
        if(!dataRx_notResponding) begin
          if(!dataRx_stuffingError) begin
            if(!dataRx_pidError) begin
              if(!endpoint_ED_F) begin
                case(dataRx_pid)
                  4'b1010 : begin
                  end
                  4'b1110 : begin
                  end
                  4'b0011, 4'b1011 : begin
                    if(when_UsbOhci_l1265) begin
                      endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ACK_TX_0;
                    end
                  end
                  default : begin
                  end
                endcase
              end
              if(when_UsbOhci_l1276) begin
                if(!dataRx_crcError) begin
                  if(when_UsbOhci_l1285) begin
                    endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ACK_TX_0;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
        if(when_UsbOhci_l1207) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS;
          if(!when_UsbOhci_l1209) begin
            if(!endpoint_ackRxStuffing) begin
              if(!endpoint_ackRxPidFailure) begin
                case(endpoint_ackRxPid)
                  4'b0010 : begin
                  end
                  4'b1010 : begin
                    endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC;
                  end
                  4'b1110 : begin
                  end
                  default : begin
                  end
                endcase
              end
            end
          end
        end
        if(rxTimer_rxTimeout) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
        if(rxTimer_ackTx) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ACK_TX_1;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
        if(io_phy_tx_ready) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
        if(io_phy_txEop) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
        if(when_UsbOhci_l1313) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
        endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD;
        if(!endpoint_ED_F) begin
          if(endpoint_TD_noUpdate) begin
            endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
        if(when_UsbOhci_l1395) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
        if(when_UsbOhci_l1410) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_BOOT;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
        endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_BOOT;
      end
      default : begin
      end
    endcase
    if(endpoint_wantStart) begin
      endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD;
    end
    if(endpoint_wantKill) begin
      endpoint_stateNext = UsbOhciAxi4_endpoint_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l189 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0000));
  assign when_UsbOhci_l189_1 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0001));
  assign when_UsbOhci_l189_2 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0010));
  assign when_UsbOhci_l189_3 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0011));
  assign when_UsbOhci_l857 = (ioDma_rsp_valid && ioDma_rsp_payload_last);
  assign when_UsbOhci_l863 = ((endpoint_ED_H || endpoint_ED_K) || endpoint_ED_tdEmpty);
  assign when_UsbOhci_l189_4 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0000));
  assign when_UsbOhci_l189_5 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0001));
  assign when_UsbOhci_l189_6 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0010));
  assign when_UsbOhci_l189_7 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0011));
  assign when_UsbOhci_l893 = (endpoint_TD_isoFrameNumber == 3'b000);
  assign when_UsbOhci_l189_8 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0100));
  assign when_UsbOhci_l189_9 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0100));
  assign when_UsbOhci_l893_1 = (endpoint_TD_isoFrameNumber == 3'b001);
  assign when_UsbOhci_l189_10 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0100));
  assign when_UsbOhci_l189_11 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0101));
  assign when_UsbOhci_l893_2 = (endpoint_TD_isoFrameNumber == 3'b010);
  assign when_UsbOhci_l189_12 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0101));
  assign when_UsbOhci_l189_13 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0101));
  assign when_UsbOhci_l893_3 = (endpoint_TD_isoFrameNumber == 3'b011);
  assign when_UsbOhci_l189_14 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0101));
  assign when_UsbOhci_l189_15 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0110));
  assign when_UsbOhci_l893_4 = (endpoint_TD_isoFrameNumber == 3'b100);
  assign when_UsbOhci_l189_16 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0110));
  assign when_UsbOhci_l189_17 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0110));
  assign when_UsbOhci_l893_5 = (endpoint_TD_isoFrameNumber == 3'b101);
  assign when_UsbOhci_l189_18 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0110));
  assign when_UsbOhci_l189_19 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0111));
  assign when_UsbOhci_l893_6 = (endpoint_TD_isoFrameNumber == 3'b110);
  assign when_UsbOhci_l189_20 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0111));
  assign when_UsbOhci_l189_21 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0111));
  assign when_UsbOhci_l893_7 = (endpoint_TD_isoFrameNumber == 3'b111);
  assign when_UsbOhci_l189_22 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0111));
  assign when_UsbOhci_l900 = (ioDma_rsp_fire && ioDma_rsp_payload_last);
  assign _zz_endpoint_lastAddress = (_zz__zz_endpoint_lastAddress - 14'h0001);
  assign when_UsbOhci_l1120 = (endpoint_isIn || endpoint_zeroLength);
  always @(*) begin
    when_UsbOhci_l1276 = 1'b0;
    if(endpoint_ED_F) begin
      case(dataRx_pid)
        4'b1110, 4'b1010 : begin
        end
        4'b0011, 4'b1011 : begin
          when_UsbOhci_l1276 = 1'b1;
        end
        default : begin
        end
      endcase
    end else begin
      case(dataRx_pid)
        4'b1010 : begin
        end
        4'b1110 : begin
        end
        4'b0011, 4'b1011 : begin
          if(!when_UsbOhci_l1265) begin
            when_UsbOhci_l1276 = 1'b1;
          end
        end
        default : begin
        end
      endcase
    end
  end

  assign when_UsbOhci_l1265 = (dataRx_pid == endpoint_TD_dataPidWrong);
  assign when_UsbOhci_l1285 = (! endpoint_ED_F);
  assign when_UsbOhci_l1202 = ((! rxPidOk) || endpoint_ackRxFired);
  assign when_UsbOhci_l1207 = ((! io_phy_rx_active) && endpoint_ackRxActivated);
  assign when_UsbOhci_l1209 = (! endpoint_ackRxFired);
  assign when_UsbOhci_l1333 = ((endpoint_dmaLogic_underflow || (_zz_when_UsbOhci_l1333 < endpoint_currentAddress)) || endpoint_zeroLength);
  assign when_UsbOhci_l1348 = (endpoint_TD_EC != 2'b10);
  assign when_UsbOhci_l207_2 = (dmaWriteCtx_counter == 4'b0000);
  assign when_UsbOhci_l207_3 = (dmaWriteCtx_counter == 4'b0000);
  assign _zz_ioDma_cmd_payload_fragment_data = {endpoint_TD_CC,_zz__zz_ioDma_cmd_payload_fragment_data};
  assign when_UsbOhci_l1380 = (endpoint_TD_isoFrameNumber == 3'b000);
  assign when_UsbOhci_l207_4 = (dmaWriteCtx_counter == 4'b0100);
  assign when_UsbOhci_l1380_1 = (endpoint_TD_isoFrameNumber == 3'b001);
  assign when_UsbOhci_l207_5 = (dmaWriteCtx_counter == 4'b0100);
  assign when_UsbOhci_l1380_2 = (endpoint_TD_isoFrameNumber == 3'b010);
  assign when_UsbOhci_l207_6 = (dmaWriteCtx_counter == 4'b0101);
  assign when_UsbOhci_l1380_3 = (endpoint_TD_isoFrameNumber == 3'b011);
  assign when_UsbOhci_l207_7 = (dmaWriteCtx_counter == 4'b0101);
  assign when_UsbOhci_l1380_4 = (endpoint_TD_isoFrameNumber == 3'b100);
  assign when_UsbOhci_l207_8 = (dmaWriteCtx_counter == 4'b0110);
  assign when_UsbOhci_l1380_5 = (endpoint_TD_isoFrameNumber == 3'b101);
  assign when_UsbOhci_l207_9 = (dmaWriteCtx_counter == 4'b0110);
  assign when_UsbOhci_l1380_6 = (endpoint_TD_isoFrameNumber == 3'b110);
  assign when_UsbOhci_l207_10 = (dmaWriteCtx_counter == 4'b0111);
  assign when_UsbOhci_l1380_7 = (endpoint_TD_isoFrameNumber == 3'b111);
  assign when_UsbOhci_l207_11 = (dmaWriteCtx_counter == 4'b0111);
  assign when_UsbOhci_l207_12 = (dmaWriteCtx_counter == 4'b0000);
  assign when_UsbOhci_l207_13 = (dmaWriteCtx_counter == 4'b0001);
  assign when_UsbOhci_l207_14 = (dmaWriteCtx_counter == 4'b0010);
  assign when_UsbOhci_l1395 = (ioDma_cmd_ready && ioDma_cmd_payload_last);
  assign when_UsbOhci_l207_15 = (dmaWriteCtx_counter == 4'b0010);
  assign when_UsbOhci_l1410 = (ioDma_cmd_ready && ioDma_cmd_payload_last);
  assign when_UsbOhci_l1417 = (! (endpoint_ED_F && endpoint_TD_isoOverrunReg));
  assign when_UsbOhci_l1420 = (endpoint_flowType != UsbOhciAxi4_FlowType_PERIODIC);
  assign when_StateMachine_l237_2 = ((endpoint_stateReg == UsbOhciAxi4_endpoint_enumDef_BOOT) && (! (endpoint_stateNext == UsbOhciAxi4_endpoint_enumDef_BOOT)));
  assign when_StateMachine_l253_1 = ((! (endpoint_stateReg == UsbOhciAxi4_endpoint_enumDef_TOKEN)) && (endpoint_stateNext == UsbOhciAxi4_endpoint_enumDef_TOKEN));
  assign when_StateMachine_l253_2 = ((! (endpoint_stateReg == UsbOhciAxi4_endpoint_enumDef_DATA_TX)) && (endpoint_stateNext == UsbOhciAxi4_endpoint_enumDef_DATA_TX));
  assign when_StateMachine_l253_3 = ((! (endpoint_stateReg == UsbOhciAxi4_endpoint_enumDef_DATA_RX)) && (endpoint_stateNext == UsbOhciAxi4_endpoint_enumDef_DATA_RX));
  assign when_StateMachine_l253_4 = ((! (endpoint_stateReg == UsbOhciAxi4_endpoint_enumDef_ACK_RX)) && (endpoint_stateNext == UsbOhciAxi4_endpoint_enumDef_ACK_RX));
  always @(*) begin
    endpoint_dmaLogic_stateNext = endpoint_dmaLogic_stateReg;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
        if(endpoint_isIn) begin
          endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB;
        end else begin
          endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD;
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
        if(dataTx_data_ready) begin
          if(endpoint_dmaLogic_byteCtx_last) begin
            endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT;
          end
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
        if(dataRx_wantExit) begin
          endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION;
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
        if(when_UsbOhci_l1070) begin
          endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT;
        end else begin
          if(endpoint_dmaLogic_validated) begin
            endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD;
          end
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
        if(endpoint_dataDone) begin
          if(endpoint_isIn) begin
            endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT;
          end else begin
            if(dmaCtx_pendingEmpty) begin
              endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB;
            end
          end
        end else begin
          if(endpoint_isIn) begin
            endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD;
          end else begin
            endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD;
          end
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
        if(ioDma_cmd_ready) begin
          endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD;
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        if(ioDma_cmd_ready) begin
          if(endpoint_dmaLogic_beatLast) begin
            endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD;
          end
        end
      end
      default : begin
      end
    endcase
    if(endpoint_dmaLogic_wantStart) begin
      endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT;
    end
    if(endpoint_dmaLogic_wantKill) begin
      endpoint_dmaLogic_stateNext = UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l1027 = (&endpoint_dmaLogic_byteCtx_sel);
  assign when_UsbOhci_l1056 = (_zz_when_UsbOhci_l1056 < endpoint_transactionSize);
  assign _zz_2 = ({3'd0,1'b1} <<< endpoint_dmaLogic_byteCtx_sel);
  assign when_UsbOhci_l1065 = (&endpoint_dmaLogic_byteCtx_sel);
  assign when_UsbOhci_l1070 = (endpoint_dmaLogic_fromUsbCounter == 11'h000);
  assign when_StateMachine_l253_5 = ((! (endpoint_dmaLogic_stateReg == UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB)) && (endpoint_dmaLogic_stateNext == UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB));
  assign endpoint_dmaLogic_fsmStopped = (endpoint_dmaLogic_stateReg == UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT);
  assign when_UsbOhci_l1130 = (endpoint_dmaLogic_stateReg == UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB);
  assign when_UsbOhci_l1313 = (endpoint_dmaLogic_stateReg == UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT);
  always @(*) begin
    operational_stateNext = operational_stateReg;
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
        if(sof_wantExit) begin
          operational_stateNext = UsbOhciAxi4_operational_enumDef_ARBITER;
        end
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
        if(operational_askExit) begin
          operational_stateNext = UsbOhciAxi4_operational_enumDef_BOOT;
        end else begin
          if(frame_limitHit) begin
            operational_stateNext = UsbOhciAxi4_operational_enumDef_WAIT_SOF;
          end else begin
            if(when_UsbOhci_l1489) begin
              if(when_UsbOhci_l1490) begin
                operational_stateNext = UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD;
              end else begin
                if(!reg_hcPeriodCurrentED_isZero) begin
                  operational_stateNext = UsbOhciAxi4_operational_enumDef_END_POINT;
                end
              end
            end else begin
              if(priority_bulk) begin
                if(operational_allowBulk) begin
                  if(!reg_hcBulkCurrentED_isZero) begin
                    operational_stateNext = UsbOhciAxi4_operational_enumDef_END_POINT;
                  end
                end
              end else begin
                if(operational_allowControl) begin
                  if(!reg_hcControlCurrentED_isZero) begin
                    operational_stateNext = UsbOhciAxi4_operational_enumDef_END_POINT;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
        if(endpoint_wantExit) begin
          case(endpoint_status_1)
            UsbOhciAxi4_endpoint_Status_OK : begin
              operational_stateNext = UsbOhciAxi4_operational_enumDef_ARBITER;
            end
            default : begin
              operational_stateNext = UsbOhciAxi4_operational_enumDef_WAIT_SOF;
            end
          endcase
        end
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
        if(ioDma_cmd_ready) begin
          operational_stateNext = UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP;
        end
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
        if(ioDma_rsp_valid) begin
          operational_stateNext = UsbOhciAxi4_operational_enumDef_ARBITER;
        end
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
        if(frame_tick) begin
          operational_stateNext = UsbOhciAxi4_operational_enumDef_SOF;
        end
      end
      default : begin
      end
    endcase
    if(operational_wantStart) begin
      operational_stateNext = UsbOhciAxi4_operational_enumDef_WAIT_SOF;
    end
    if(operational_wantKill) begin
      operational_stateNext = UsbOhciAxi4_operational_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l1463 = (operational_allowPeriodic && (! operational_periodicDone));
  assign when_UsbOhci_l1490 = (! operational_periodicHeadFetched);
  assign when_UsbOhci_l1489 = ((operational_allowPeriodic && (! operational_periodicDone)) && (! frame_section1));
  assign when_StateMachine_l237_3 = ((operational_stateReg == UsbOhciAxi4_operational_enumDef_BOOT) && (! (operational_stateNext == UsbOhciAxi4_operational_enumDef_BOOT)));
  assign when_StateMachine_l253_6 = ((! (operational_stateReg == UsbOhciAxi4_operational_enumDef_SOF)) && (operational_stateNext == UsbOhciAxi4_operational_enumDef_SOF));
  assign hc_operationalIsDone = (operational_stateReg == UsbOhciAxi4_operational_enumDef_BOOT);
  always @(*) begin
    hc_stateNext = hc_stateReg;
    case(hc_stateReg)
      UsbOhciAxi4_hc_enumDef_RESET : begin
        if(reg_hcControl_HCFSWrite_valid) begin
          case(reg_hcControl_HCFSWrite_payload)
            UsbOhciAxi4_MainState_OPERATIONAL : begin
              hc_stateNext = UsbOhciAxi4_hc_enumDef_OPERATIONAL;
            end
            default : begin
            end
          endcase
        end
      end
      UsbOhciAxi4_hc_enumDef_RESUME : begin
        if(when_UsbOhci_l1618) begin
          hc_stateNext = UsbOhciAxi4_hc_enumDef_OPERATIONAL;
        end
      end
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciAxi4_hc_enumDef_SUSPEND : begin
        if(when_UsbOhci_l1627) begin
          hc_stateNext = UsbOhciAxi4_hc_enumDef_RESUME;
        end else begin
          if(when_UsbOhci_l1630) begin
            hc_stateNext = UsbOhciAxi4_hc_enumDef_OPERATIONAL;
          end
        end
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : begin
        if(when_UsbOhci_l1641) begin
          hc_stateNext = UsbOhciAxi4_hc_enumDef_RESET;
        end
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : begin
        if(when_UsbOhci_l1654) begin
          hc_stateNext = UsbOhciAxi4_hc_enumDef_SUSPEND;
        end
      end
      default : begin
      end
    endcase
    if(when_UsbOhci_l1661) begin
      hc_stateNext = UsbOhciAxi4_hc_enumDef_ANY_TO_RESET;
    end
    if(reg_hcCommandStatus_startSoftReset) begin
      hc_stateNext = UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND;
    end
    if(hc_wantStart) begin
      hc_stateNext = UsbOhciAxi4_hc_enumDef_RESET;
    end
    if(hc_wantKill) begin
      hc_stateNext = UsbOhciAxi4_hc_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l1618 = (reg_hcControl_HCFSWrite_valid && (reg_hcControl_HCFSWrite_payload == UsbOhciAxi4_MainState_OPERATIONAL));
  assign when_UsbOhci_l1627 = (reg_hcRhStatus_DRWE && (|{reg_hcRhPortStatus_3_CSC_reg,{reg_hcRhPortStatus_2_CSC_reg,{reg_hcRhPortStatus_1_CSC_reg,reg_hcRhPortStatus_0_CSC_reg}}}));
  assign when_UsbOhci_l1630 = (reg_hcControl_HCFSWrite_valid && (reg_hcControl_HCFSWrite_payload == UsbOhciAxi4_MainState_OPERATIONAL));
  assign when_UsbOhci_l1641 = (! doUnschedule);
  assign when_UsbOhci_l1654 = (((! doUnschedule) && (! doSoftReset)) && hc_operationalIsDone);
  assign when_StateMachine_l253_7 = ((! (hc_stateReg == UsbOhciAxi4_hc_enumDef_OPERATIONAL)) && (hc_stateNext == UsbOhciAxi4_hc_enumDef_OPERATIONAL));
  assign when_StateMachine_l253_8 = ((! (hc_stateReg == UsbOhciAxi4_hc_enumDef_ANY_TO_RESET)) && (hc_stateNext == UsbOhciAxi4_hc_enumDef_ANY_TO_RESET));
  assign when_StateMachine_l253_9 = ((! (hc_stateReg == UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND)) && (hc_stateNext == UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND));
  assign when_UsbOhci_l1661 = (reg_hcControl_HCFSWrite_valid && (reg_hcControl_HCFSWrite_payload == UsbOhciAxi4_MainState_RESET));
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      dmaCtx_pendingCounter <= 4'b0000;
      dmaCtx_beatCounter <= 6'h00;
      io_dma_cmd_payload_first <= 1'b1;
      dmaReadCtx_counter <= 4'b0000;
      dmaWriteCtx_counter <= 4'b0000;
      _zz_io_ctrl_rsp_valid_1 <= 1'b0;
      doUnschedule <= 1'b0;
      doSoftReset <= 1'b0;
      reg_hcControl_IR <= 1'b0;
      reg_hcControl_RWC <= 1'b0;
      reg_hcFmNumber_overflow <= 1'b0;
      reg_hcPeriodicStart_PS <= 14'h0000;
      io_phy_overcurrent_regNext <= 1'b0;
      reg_hcRhPortStatus_0_connected <= 1'b0;
      reg_hcRhPortStatus_0_CCS_regNext <= 1'b0;
      reg_hcRhPortStatus_1_connected <= 1'b0;
      reg_hcRhPortStatus_1_CCS_regNext <= 1'b0;
      reg_hcRhPortStatus_2_connected <= 1'b0;
      reg_hcRhPortStatus_2_CCS_regNext <= 1'b0;
      reg_hcRhPortStatus_3_connected <= 1'b0;
      reg_hcRhPortStatus_3_CCS_regNext <= 1'b0;
      interruptDelay_counter <= 3'b111;
      endpoint_dmaLogic_push <= 1'b0;
      _zz_when_UsbOhci_l255 <= 1'b1;
      token_stateReg <= UsbOhciAxi4_token_enumDef_BOOT;
      dataTx_stateReg <= UsbOhciAxi4_dataTx_enumDef_BOOT;
      dataRx_stateReg <= UsbOhciAxi4_dataRx_enumDef_BOOT;
      sof_stateReg <= UsbOhciAxi4_sof_enumDef_BOOT;
      endpoint_stateReg <= UsbOhciAxi4_endpoint_enumDef_BOOT;
      endpoint_dmaLogic_stateReg <= UsbOhciAxi4_endpoint_dmaLogic_enumDef_BOOT;
      operational_stateReg <= UsbOhciAxi4_operational_enumDef_BOOT;
      hc_stateReg <= UsbOhciAxi4_hc_enumDef_BOOT;
    end else begin
      dmaCtx_pendingCounter <= (_zz_dmaCtx_pendingCounter - _zz_dmaCtx_pendingCounter_3);
      if(ioDma_cmd_fire) begin
        dmaCtx_beatCounter <= (dmaCtx_beatCounter + 6'h01);
        if(io_dma_cmd_payload_last) begin
          dmaCtx_beatCounter <= 6'h00;
        end
      end
      if(io_dma_cmd_fire) begin
        io_dma_cmd_payload_first <= io_dma_cmd_payload_last;
      end
      if(ioDma_rsp_fire) begin
        dmaReadCtx_counter <= (dmaReadCtx_counter + 4'b0001);
        if(ioDma_rsp_payload_last) begin
          dmaReadCtx_counter <= 4'b0000;
        end
      end
      if(ioDma_cmd_fire) begin
        dmaWriteCtx_counter <= (dmaWriteCtx_counter + 4'b0001);
        if(ioDma_cmd_payload_last) begin
          dmaWriteCtx_counter <= 4'b0000;
        end
      end
      if(_zz_ctrl_rsp_ready_1) begin
        _zz_io_ctrl_rsp_valid_1 <= (ctrl_rsp_valid && _zz_ctrl_rsp_ready);
      end
      if(unscheduleAll_ready) begin
        doUnschedule <= 1'b0;
      end
      if(when_UsbOhci_l238) begin
        doSoftReset <= 1'b0;
      end
      io_phy_overcurrent_regNext <= io_phy_overcurrent;
      if(io_phy_ports_0_connect) begin
        reg_hcRhPortStatus_0_connected <= 1'b1;
      end
      if(io_phy_ports_0_disconnect) begin
        reg_hcRhPortStatus_0_connected <= 1'b0;
      end
      reg_hcRhPortStatus_0_CCS_regNext <= reg_hcRhPortStatus_0_CCS;
      if(io_phy_ports_1_connect) begin
        reg_hcRhPortStatus_1_connected <= 1'b1;
      end
      if(io_phy_ports_1_disconnect) begin
        reg_hcRhPortStatus_1_connected <= 1'b0;
      end
      reg_hcRhPortStatus_1_CCS_regNext <= reg_hcRhPortStatus_1_CCS;
      if(io_phy_ports_2_connect) begin
        reg_hcRhPortStatus_2_connected <= 1'b1;
      end
      if(io_phy_ports_2_disconnect) begin
        reg_hcRhPortStatus_2_connected <= 1'b0;
      end
      reg_hcRhPortStatus_2_CCS_regNext <= reg_hcRhPortStatus_2_CCS;
      if(io_phy_ports_3_connect) begin
        reg_hcRhPortStatus_3_connected <= 1'b1;
      end
      if(io_phy_ports_3_disconnect) begin
        reg_hcRhPortStatus_3_connected <= 1'b0;
      end
      reg_hcRhPortStatus_3_CCS_regNext <= reg_hcRhPortStatus_3_CCS;
      if(frame_reload) begin
        if(when_UsbOhci_l542) begin
          reg_hcFmNumber_overflow <= 1'b1;
        end
      end
      if(when_UsbOhci_l687) begin
        interruptDelay_counter <= (interruptDelay_counter - 3'b001);
      end
      if(when_UsbOhci_l691) begin
        interruptDelay_counter <= interruptDelay_load_payload;
      end
      if(interruptDelay_disable) begin
        interruptDelay_counter <= 3'b111;
      end
      endpoint_dmaLogic_push <= 1'b0;
      case(io_ctrl_cmd_payload_fragment_address)
        12'h004 : begin
          if(ctrl_doWrite) begin
            if(when_BusSlaveFactory_l1041_5) begin
              reg_hcControl_IR <= io_ctrl_cmd_payload_fragment_data[8];
            end
            if(when_BusSlaveFactory_l1041_6) begin
              reg_hcControl_RWC <= io_ctrl_cmd_payload_fragment_data[9];
            end
          end
        end
        12'h040 : begin
          if(ctrl_doWrite) begin
            if(when_BusSlaveFactory_l1041_36) begin
              reg_hcPeriodicStart_PS[7 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 0];
            end
            if(when_BusSlaveFactory_l1041_37) begin
              reg_hcPeriodicStart_PS[13 : 8] <= io_ctrl_cmd_payload_fragment_data[13 : 8];
            end
          end
        end
        default : begin
        end
      endcase
      _zz_when_UsbOhci_l255 <= 1'b0;
      token_stateReg <= token_stateNext;
      dataTx_stateReg <= dataTx_stateNext;
      dataRx_stateReg <= dataRx_stateNext;
      sof_stateReg <= sof_stateNext;
      case(sof_stateReg)
        UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
        end
        UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
        end
        UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
          if(ioDma_rsp_valid) begin
            reg_hcFmNumber_overflow <= 1'b0;
          end
        end
        default : begin
        end
      endcase
      endpoint_stateReg <= endpoint_stateNext;
      endpoint_dmaLogic_stateReg <= endpoint_dmaLogic_stateNext;
      case(endpoint_dmaLogic_stateReg)
        UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
        end
        UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
        end
        UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
          if(dataRx_wantExit) begin
            endpoint_dmaLogic_push <= (|endpoint_dmaLogic_byteCtx_sel);
          end
          if(dataRx_data_valid) begin
            if(when_UsbOhci_l1065) begin
              endpoint_dmaLogic_push <= 1'b1;
            end
          end
        end
        UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
        end
        UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
        end
        UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
        end
        UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        end
        default : begin
        end
      endcase
      operational_stateReg <= operational_stateNext;
      hc_stateReg <= hc_stateNext;
      if(when_StateMachine_l253_8) begin
        doUnschedule <= 1'b1;
      end
      if(when_StateMachine_l253_9) begin
        doUnschedule <= 1'b1;
      end
      if(reg_hcCommandStatus_startSoftReset) begin
        doSoftReset <= 1'b1;
      end
    end
  end

  always @(posedge ctrl_clk) begin
    if(_zz_ctrl_rsp_ready_1) begin
      _zz_io_ctrl_rsp_payload_last <= ctrl_rsp_payload_last;
      _zz_io_ctrl_rsp_payload_fragment_source <= ctrl_rsp_payload_fragment_source;
      _zz_io_ctrl_rsp_payload_fragment_opcode <= ctrl_rsp_payload_fragment_opcode;
      _zz_io_ctrl_rsp_payload_fragment_data <= ctrl_rsp_payload_fragment_data;
    end
    if(when_BusSlaveFactory_l377_1) begin
      if(when_BusSlaveFactory_l379_1) begin
        reg_hcCommandStatus_CLF <= _zz_reg_hcCommandStatus_CLF[0];
      end
    end
    if(when_BusSlaveFactory_l377_2) begin
      if(when_BusSlaveFactory_l379_2) begin
        reg_hcCommandStatus_BLF <= _zz_reg_hcCommandStatus_BLF[0];
      end
    end
    if(when_BusSlaveFactory_l377_3) begin
      if(when_BusSlaveFactory_l379_3) begin
        reg_hcCommandStatus_OCR <= _zz_reg_hcCommandStatus_OCR[0];
      end
    end
    if(when_BusSlaveFactory_l377_4) begin
      if(when_BusSlaveFactory_l379_4) begin
        reg_hcInterrupt_MIE <= _zz_reg_hcInterrupt_MIE[0];
      end
    end
    if(when_BusSlaveFactory_l341) begin
      if(when_BusSlaveFactory_l347) begin
        reg_hcInterrupt_MIE <= _zz_reg_hcInterrupt_MIE_1[0];
      end
    end
    if(when_BusSlaveFactory_l341_1) begin
      if(when_BusSlaveFactory_l347_1) begin
        reg_hcInterrupt_SO_status <= _zz_reg_hcInterrupt_SO_status[0];
      end
    end
    if(when_BusSlaveFactory_l377_5) begin
      if(when_BusSlaveFactory_l379_5) begin
        reg_hcInterrupt_SO_enable <= _zz_reg_hcInterrupt_SO_enable[0];
      end
    end
    if(when_BusSlaveFactory_l341_2) begin
      if(when_BusSlaveFactory_l347_2) begin
        reg_hcInterrupt_SO_enable <= _zz_reg_hcInterrupt_SO_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l341_3) begin
      if(when_BusSlaveFactory_l347_3) begin
        reg_hcInterrupt_WDH_status <= _zz_reg_hcInterrupt_WDH_status[0];
      end
    end
    if(when_BusSlaveFactory_l377_6) begin
      if(when_BusSlaveFactory_l379_6) begin
        reg_hcInterrupt_WDH_enable <= _zz_reg_hcInterrupt_WDH_enable[0];
      end
    end
    if(when_BusSlaveFactory_l341_4) begin
      if(when_BusSlaveFactory_l347_4) begin
        reg_hcInterrupt_WDH_enable <= _zz_reg_hcInterrupt_WDH_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l341_5) begin
      if(when_BusSlaveFactory_l347_5) begin
        reg_hcInterrupt_SF_status <= _zz_reg_hcInterrupt_SF_status[0];
      end
    end
    if(when_BusSlaveFactory_l377_7) begin
      if(when_BusSlaveFactory_l379_7) begin
        reg_hcInterrupt_SF_enable <= _zz_reg_hcInterrupt_SF_enable[0];
      end
    end
    if(when_BusSlaveFactory_l341_6) begin
      if(when_BusSlaveFactory_l347_6) begin
        reg_hcInterrupt_SF_enable <= _zz_reg_hcInterrupt_SF_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l341_7) begin
      if(when_BusSlaveFactory_l347_7) begin
        reg_hcInterrupt_RD_status <= _zz_reg_hcInterrupt_RD_status[0];
      end
    end
    if(when_BusSlaveFactory_l377_8) begin
      if(when_BusSlaveFactory_l379_8) begin
        reg_hcInterrupt_RD_enable <= _zz_reg_hcInterrupt_RD_enable[0];
      end
    end
    if(when_BusSlaveFactory_l341_8) begin
      if(when_BusSlaveFactory_l347_8) begin
        reg_hcInterrupt_RD_enable <= _zz_reg_hcInterrupt_RD_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l341_9) begin
      if(when_BusSlaveFactory_l347_9) begin
        reg_hcInterrupt_UE_status <= _zz_reg_hcInterrupt_UE_status[0];
      end
    end
    if(when_BusSlaveFactory_l377_9) begin
      if(when_BusSlaveFactory_l379_9) begin
        reg_hcInterrupt_UE_enable <= _zz_reg_hcInterrupt_UE_enable[0];
      end
    end
    if(when_BusSlaveFactory_l341_10) begin
      if(when_BusSlaveFactory_l347_10) begin
        reg_hcInterrupt_UE_enable <= _zz_reg_hcInterrupt_UE_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l341_11) begin
      if(when_BusSlaveFactory_l347_11) begin
        reg_hcInterrupt_FNO_status <= _zz_reg_hcInterrupt_FNO_status[0];
      end
    end
    if(when_BusSlaveFactory_l377_10) begin
      if(when_BusSlaveFactory_l379_10) begin
        reg_hcInterrupt_FNO_enable <= _zz_reg_hcInterrupt_FNO_enable[0];
      end
    end
    if(when_BusSlaveFactory_l341_12) begin
      if(when_BusSlaveFactory_l347_12) begin
        reg_hcInterrupt_FNO_enable <= _zz_reg_hcInterrupt_FNO_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l341_13) begin
      if(when_BusSlaveFactory_l347_13) begin
        reg_hcInterrupt_RHSC_status <= _zz_reg_hcInterrupt_RHSC_status[0];
      end
    end
    if(when_BusSlaveFactory_l377_11) begin
      if(when_BusSlaveFactory_l379_11) begin
        reg_hcInterrupt_RHSC_enable <= _zz_reg_hcInterrupt_RHSC_enable[0];
      end
    end
    if(when_BusSlaveFactory_l341_14) begin
      if(when_BusSlaveFactory_l347_14) begin
        reg_hcInterrupt_RHSC_enable <= _zz_reg_hcInterrupt_RHSC_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l341_15) begin
      if(when_BusSlaveFactory_l347_15) begin
        reg_hcInterrupt_OC_status <= _zz_reg_hcInterrupt_OC_status[0];
      end
    end
    if(when_BusSlaveFactory_l377_12) begin
      if(when_BusSlaveFactory_l379_12) begin
        reg_hcInterrupt_OC_enable <= _zz_reg_hcInterrupt_OC_enable[0];
      end
    end
    if(when_BusSlaveFactory_l341_16) begin
      if(when_BusSlaveFactory_l347_16) begin
        reg_hcInterrupt_OC_enable <= _zz_reg_hcInterrupt_OC_enable_1[0];
      end
    end
    if(reg_hcCommandStatus_OCR) begin
      reg_hcInterrupt_OC_status <= 1'b1;
    end
    if(when_BusSlaveFactory_l341_17) begin
      if(when_BusSlaveFactory_l347_17) begin
        reg_hcRhStatus_CCIC <= _zz_reg_hcRhStatus_CCIC[0];
      end
    end
    if(when_UsbOhci_l411) begin
      reg_hcRhStatus_CCIC <= 1'b1;
    end
    if(reg_hcRhStatus_setRemoteWakeupEnable) begin
      reg_hcRhStatus_DRWE <= 1'b1;
    end
    if(reg_hcRhStatus_clearRemoteWakeupEnable) begin
      reg_hcRhStatus_DRWE <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_CSC_clear) begin
      reg_hcRhPortStatus_0_CSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_CSC_set) begin
      reg_hcRhPortStatus_0_CSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_CSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PESC_clear) begin
      reg_hcRhPortStatus_0_PESC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_PESC_set) begin
      reg_hcRhPortStatus_0_PESC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PESC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PSSC_clear) begin
      reg_hcRhPortStatus_0_PSSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_PSSC_set) begin
      reg_hcRhPortStatus_0_PSSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PSSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_OCIC_clear) begin
      reg_hcRhPortStatus_0_OCIC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_OCIC_set) begin
      reg_hcRhPortStatus_0_OCIC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_OCIC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PRSC_clear) begin
      reg_hcRhPortStatus_0_PRSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_PRSC_set) begin
      reg_hcRhPortStatus_0_PRSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PRSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(when_UsbOhci_l462) begin
      reg_hcRhPortStatus_0_PES <= 1'b0;
    end
    if(when_UsbOhci_l462_1) begin
      reg_hcRhPortStatus_0_PES <= 1'b1;
    end
    if(when_UsbOhci_l462_2) begin
      reg_hcRhPortStatus_0_PES <= 1'b1;
    end
    if(when_UsbOhci_l463) begin
      reg_hcRhPortStatus_0_PSS <= 1'b0;
    end
    if(when_UsbOhci_l463_1) begin
      reg_hcRhPortStatus_0_PSS <= 1'b1;
    end
    if(when_UsbOhci_l464) begin
      reg_hcRhPortStatus_0_suspend <= 1'b1;
    end
    if(when_UsbOhci_l465) begin
      reg_hcRhPortStatus_0_resume <= 1'b1;
    end
    if(when_UsbOhci_l466) begin
      reg_hcRhPortStatus_0_reset <= 1'b1;
    end
    if(reg_hcRhDescriptorA_NPS) begin
      reg_hcRhPortStatus_0_PPS <= 1'b1;
    end else begin
      if(reg_hcRhDescriptorA_PSM) begin
        if(when_UsbOhci_l472) begin
          if(reg_hcRhPortStatus_0_clearPortPower) begin
            reg_hcRhPortStatus_0_PPS <= 1'b0;
          end
          if(reg_hcRhPortStatus_0_setPortPower) begin
            reg_hcRhPortStatus_0_PPS <= 1'b1;
          end
        end else begin
          if(reg_hcRhStatus_clearGlobalPower) begin
            reg_hcRhPortStatus_0_PPS <= 1'b0;
          end
          if(reg_hcRhStatus_setGlobalPower) begin
            reg_hcRhPortStatus_0_PPS <= 1'b1;
          end
        end
      end else begin
        if(reg_hcRhStatus_clearGlobalPower) begin
          reg_hcRhPortStatus_0_PPS <= 1'b0;
        end
        if(reg_hcRhStatus_setGlobalPower) begin
          reg_hcRhPortStatus_0_PPS <= 1'b1;
        end
      end
    end
    if(io_phy_overcurrent) begin
      reg_hcRhPortStatus_0_PPS <= 1'b0;
    end
    if(io_phy_ports_0_resume_fire) begin
      reg_hcRhPortStatus_0_resume <= 1'b0;
    end
    if(io_phy_ports_0_reset_fire) begin
      reg_hcRhPortStatus_0_reset <= 1'b0;
    end
    if(io_phy_ports_0_suspend_fire) begin
      reg_hcRhPortStatus_0_suspend <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_CSC_clear) begin
      reg_hcRhPortStatus_1_CSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_CSC_set) begin
      reg_hcRhPortStatus_1_CSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_CSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PESC_clear) begin
      reg_hcRhPortStatus_1_PESC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_PESC_set) begin
      reg_hcRhPortStatus_1_PESC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PESC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PSSC_clear) begin
      reg_hcRhPortStatus_1_PSSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_PSSC_set) begin
      reg_hcRhPortStatus_1_PSSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PSSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_OCIC_clear) begin
      reg_hcRhPortStatus_1_OCIC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_OCIC_set) begin
      reg_hcRhPortStatus_1_OCIC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_OCIC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PRSC_clear) begin
      reg_hcRhPortStatus_1_PRSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_PRSC_set) begin
      reg_hcRhPortStatus_1_PRSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PRSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(when_UsbOhci_l462_3) begin
      reg_hcRhPortStatus_1_PES <= 1'b0;
    end
    if(when_UsbOhci_l462_4) begin
      reg_hcRhPortStatus_1_PES <= 1'b1;
    end
    if(when_UsbOhci_l462_5) begin
      reg_hcRhPortStatus_1_PES <= 1'b1;
    end
    if(when_UsbOhci_l463_2) begin
      reg_hcRhPortStatus_1_PSS <= 1'b0;
    end
    if(when_UsbOhci_l463_3) begin
      reg_hcRhPortStatus_1_PSS <= 1'b1;
    end
    if(when_UsbOhci_l464_1) begin
      reg_hcRhPortStatus_1_suspend <= 1'b1;
    end
    if(when_UsbOhci_l465_1) begin
      reg_hcRhPortStatus_1_resume <= 1'b1;
    end
    if(when_UsbOhci_l466_1) begin
      reg_hcRhPortStatus_1_reset <= 1'b1;
    end
    if(reg_hcRhDescriptorA_NPS) begin
      reg_hcRhPortStatus_1_PPS <= 1'b1;
    end else begin
      if(reg_hcRhDescriptorA_PSM) begin
        if(when_UsbOhci_l472_1) begin
          if(reg_hcRhPortStatus_1_clearPortPower) begin
            reg_hcRhPortStatus_1_PPS <= 1'b0;
          end
          if(reg_hcRhPortStatus_1_setPortPower) begin
            reg_hcRhPortStatus_1_PPS <= 1'b1;
          end
        end else begin
          if(reg_hcRhStatus_clearGlobalPower) begin
            reg_hcRhPortStatus_1_PPS <= 1'b0;
          end
          if(reg_hcRhStatus_setGlobalPower) begin
            reg_hcRhPortStatus_1_PPS <= 1'b1;
          end
        end
      end else begin
        if(reg_hcRhStatus_clearGlobalPower) begin
          reg_hcRhPortStatus_1_PPS <= 1'b0;
        end
        if(reg_hcRhStatus_setGlobalPower) begin
          reg_hcRhPortStatus_1_PPS <= 1'b1;
        end
      end
    end
    if(io_phy_overcurrent) begin
      reg_hcRhPortStatus_1_PPS <= 1'b0;
    end
    if(io_phy_ports_1_resume_fire) begin
      reg_hcRhPortStatus_1_resume <= 1'b0;
    end
    if(io_phy_ports_1_reset_fire) begin
      reg_hcRhPortStatus_1_reset <= 1'b0;
    end
    if(io_phy_ports_1_suspend_fire) begin
      reg_hcRhPortStatus_1_suspend <= 1'b0;
    end
    if(reg_hcRhPortStatus_2_CSC_clear) begin
      reg_hcRhPortStatus_2_CSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_2_CSC_set) begin
      reg_hcRhPortStatus_2_CSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_2_CSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_2_PESC_clear) begin
      reg_hcRhPortStatus_2_PESC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_2_PESC_set) begin
      reg_hcRhPortStatus_2_PESC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_2_PESC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_2_PSSC_clear) begin
      reg_hcRhPortStatus_2_PSSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_2_PSSC_set) begin
      reg_hcRhPortStatus_2_PSSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_2_PSSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_2_OCIC_clear) begin
      reg_hcRhPortStatus_2_OCIC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_2_OCIC_set) begin
      reg_hcRhPortStatus_2_OCIC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_2_OCIC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_2_PRSC_clear) begin
      reg_hcRhPortStatus_2_PRSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_2_PRSC_set) begin
      reg_hcRhPortStatus_2_PRSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_2_PRSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(when_UsbOhci_l462_6) begin
      reg_hcRhPortStatus_2_PES <= 1'b0;
    end
    if(when_UsbOhci_l462_7) begin
      reg_hcRhPortStatus_2_PES <= 1'b1;
    end
    if(when_UsbOhci_l462_8) begin
      reg_hcRhPortStatus_2_PES <= 1'b1;
    end
    if(when_UsbOhci_l463_4) begin
      reg_hcRhPortStatus_2_PSS <= 1'b0;
    end
    if(when_UsbOhci_l463_5) begin
      reg_hcRhPortStatus_2_PSS <= 1'b1;
    end
    if(when_UsbOhci_l464_2) begin
      reg_hcRhPortStatus_2_suspend <= 1'b1;
    end
    if(when_UsbOhci_l465_2) begin
      reg_hcRhPortStatus_2_resume <= 1'b1;
    end
    if(when_UsbOhci_l466_2) begin
      reg_hcRhPortStatus_2_reset <= 1'b1;
    end
    if(reg_hcRhDescriptorA_NPS) begin
      reg_hcRhPortStatus_2_PPS <= 1'b1;
    end else begin
      if(reg_hcRhDescriptorA_PSM) begin
        if(when_UsbOhci_l472_2) begin
          if(reg_hcRhPortStatus_2_clearPortPower) begin
            reg_hcRhPortStatus_2_PPS <= 1'b0;
          end
          if(reg_hcRhPortStatus_2_setPortPower) begin
            reg_hcRhPortStatus_2_PPS <= 1'b1;
          end
        end else begin
          if(reg_hcRhStatus_clearGlobalPower) begin
            reg_hcRhPortStatus_2_PPS <= 1'b0;
          end
          if(reg_hcRhStatus_setGlobalPower) begin
            reg_hcRhPortStatus_2_PPS <= 1'b1;
          end
        end
      end else begin
        if(reg_hcRhStatus_clearGlobalPower) begin
          reg_hcRhPortStatus_2_PPS <= 1'b0;
        end
        if(reg_hcRhStatus_setGlobalPower) begin
          reg_hcRhPortStatus_2_PPS <= 1'b1;
        end
      end
    end
    if(io_phy_overcurrent) begin
      reg_hcRhPortStatus_2_PPS <= 1'b0;
    end
    if(io_phy_ports_2_resume_fire) begin
      reg_hcRhPortStatus_2_resume <= 1'b0;
    end
    if(io_phy_ports_2_reset_fire) begin
      reg_hcRhPortStatus_2_reset <= 1'b0;
    end
    if(io_phy_ports_2_suspend_fire) begin
      reg_hcRhPortStatus_2_suspend <= 1'b0;
    end
    if(reg_hcRhPortStatus_3_CSC_clear) begin
      reg_hcRhPortStatus_3_CSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_3_CSC_set) begin
      reg_hcRhPortStatus_3_CSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_3_CSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_3_PESC_clear) begin
      reg_hcRhPortStatus_3_PESC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_3_PESC_set) begin
      reg_hcRhPortStatus_3_PESC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_3_PESC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_3_PSSC_clear) begin
      reg_hcRhPortStatus_3_PSSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_3_PSSC_set) begin
      reg_hcRhPortStatus_3_PSSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_3_PSSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_3_OCIC_clear) begin
      reg_hcRhPortStatus_3_OCIC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_3_OCIC_set) begin
      reg_hcRhPortStatus_3_OCIC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_3_OCIC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_3_PRSC_clear) begin
      reg_hcRhPortStatus_3_PRSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_3_PRSC_set) begin
      reg_hcRhPortStatus_3_PRSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_3_PRSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(when_UsbOhci_l462_9) begin
      reg_hcRhPortStatus_3_PES <= 1'b0;
    end
    if(when_UsbOhci_l462_10) begin
      reg_hcRhPortStatus_3_PES <= 1'b1;
    end
    if(when_UsbOhci_l462_11) begin
      reg_hcRhPortStatus_3_PES <= 1'b1;
    end
    if(when_UsbOhci_l463_6) begin
      reg_hcRhPortStatus_3_PSS <= 1'b0;
    end
    if(when_UsbOhci_l463_7) begin
      reg_hcRhPortStatus_3_PSS <= 1'b1;
    end
    if(when_UsbOhci_l464_3) begin
      reg_hcRhPortStatus_3_suspend <= 1'b1;
    end
    if(when_UsbOhci_l465_3) begin
      reg_hcRhPortStatus_3_resume <= 1'b1;
    end
    if(when_UsbOhci_l466_3) begin
      reg_hcRhPortStatus_3_reset <= 1'b1;
    end
    if(reg_hcRhDescriptorA_NPS) begin
      reg_hcRhPortStatus_3_PPS <= 1'b1;
    end else begin
      if(reg_hcRhDescriptorA_PSM) begin
        if(when_UsbOhci_l472_3) begin
          if(reg_hcRhPortStatus_3_clearPortPower) begin
            reg_hcRhPortStatus_3_PPS <= 1'b0;
          end
          if(reg_hcRhPortStatus_3_setPortPower) begin
            reg_hcRhPortStatus_3_PPS <= 1'b1;
          end
        end else begin
          if(reg_hcRhStatus_clearGlobalPower) begin
            reg_hcRhPortStatus_3_PPS <= 1'b0;
          end
          if(reg_hcRhStatus_setGlobalPower) begin
            reg_hcRhPortStatus_3_PPS <= 1'b1;
          end
        end
      end else begin
        if(reg_hcRhStatus_clearGlobalPower) begin
          reg_hcRhPortStatus_3_PPS <= 1'b0;
        end
        if(reg_hcRhStatus_setGlobalPower) begin
          reg_hcRhPortStatus_3_PPS <= 1'b1;
        end
      end
    end
    if(io_phy_overcurrent) begin
      reg_hcRhPortStatus_3_PPS <= 1'b0;
    end
    if(io_phy_ports_3_resume_fire) begin
      reg_hcRhPortStatus_3_resume <= 1'b0;
    end
    if(io_phy_ports_3_reset_fire) begin
      reg_hcRhPortStatus_3_reset <= 1'b0;
    end
    if(io_phy_ports_3_suspend_fire) begin
      reg_hcRhPortStatus_3_suspend <= 1'b0;
    end
    frame_decrementTimer <= (frame_decrementTimer + 3'b001);
    if(frame_decrementTimerOverflow) begin
      frame_decrementTimer <= 3'b000;
    end
    if(when_UsbOhci_l528) begin
      reg_hcFmRemaining_FR <= (reg_hcFmRemaining_FR - 14'h0001);
      if(when_UsbOhci_l530) begin
        frame_limitCounter <= (frame_limitCounter - 15'h0001);
      end
    end
    if(frame_reload) begin
      reg_hcFmRemaining_FR <= reg_hcFmInterval_FI;
      reg_hcFmRemaining_FRT <= reg_hcFmInterval_FIT;
      reg_hcFmNumber_FN <= reg_hcFmNumber_FNp1;
      frame_limitCounter <= reg_hcFmInterval_FSMPS;
      frame_decrementTimer <= 3'b000;
    end
    if(io_phy_tick) begin
      rxTimer_counter <= (rxTimer_counter + 8'h01);
    end
    if(rxTimer_clear) begin
      rxTimer_counter <= 8'h00;
    end
    if(_zz_1) begin
      _zz_dataRx_history_0 <= _zz_dataRx_pid;
    end
    if(_zz_1) begin
      _zz_dataRx_history_1 <= _zz_dataRx_history_0;
    end
    if(priority_tick) begin
      priority_counter <= (priority_counter + 2'b01);
    end
    if(priority_skip) begin
      priority_bulk <= (! priority_bulk);
      priority_counter <= 2'b00;
    end
    endpoint_TD_isoOverrunReg <= endpoint_TD_isoOverrun;
    endpoint_TD_isoZero <= (endpoint_TD_isoLast ? (endpoint_TD_isoBaseNext < endpoint_TD_isoBase) : (endpoint_TD_isoBase == endpoint_TD_isoBaseNext));
    endpoint_TD_isoLastReg <= endpoint_TD_isoLast;
    endpoint_TD_tooEarlyReg <= endpoint_TD_tooEarly;
    endpoint_TD_lastOffset <= (endpoint_ED_F ? _zz_endpoint_TD_lastOffset : {(! endpoint_TD_isSinglePage),endpoint_TD_BE[11 : 0]});
    if(endpoint_TD_clear) begin
      endpoint_TD_retire <= 1'b0;
      endpoint_TD_dataPhaseUpdate <= 1'b0;
      endpoint_TD_upateCBP <= 1'b0;
      endpoint_TD_noUpdate <= 1'b0;
    end
    if(endpoint_applyNextED) begin
      case(endpoint_flowType)
        UsbOhciAxi4_FlowType_BULK : begin
          reg_hcBulkCurrentED_BCED_reg <= endpoint_ED_nextED;
        end
        UsbOhciAxi4_FlowType_CONTROL : begin
          reg_hcControlCurrentED_CCED_reg <= endpoint_ED_nextED;
        end
        default : begin
          reg_hcPeriodCurrentED_PCED_reg <= endpoint_ED_nextED;
        end
      endcase
    end
    if(endpoint_dmaLogic_byteCtx_increment) begin
      endpoint_dmaLogic_byteCtx_counter <= (endpoint_dmaLogic_byteCtx_counter + 13'h0001);
    end
    case(io_ctrl_cmd_payload_fragment_address)
      12'h004 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041) begin
            reg_hcControl_CBSR[1 : 0] <= io_ctrl_cmd_payload_fragment_data[1 : 0];
          end
          if(when_BusSlaveFactory_l1041_1) begin
            reg_hcControl_PLE <= io_ctrl_cmd_payload_fragment_data[2];
          end
          if(when_BusSlaveFactory_l1041_2) begin
            reg_hcControl_IE <= io_ctrl_cmd_payload_fragment_data[3];
          end
          if(when_BusSlaveFactory_l1041_3) begin
            reg_hcControl_CLE <= io_ctrl_cmd_payload_fragment_data[4];
          end
          if(when_BusSlaveFactory_l1041_4) begin
            reg_hcControl_BLE <= io_ctrl_cmd_payload_fragment_data[5];
          end
          if(when_BusSlaveFactory_l1041_7) begin
            reg_hcControl_RWE <= io_ctrl_cmd_payload_fragment_data[10];
          end
        end
      end
      12'h018 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_8) begin
            reg_hcHCCA_HCCA_reg[7 : 0] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l1041_9) begin
            reg_hcHCCA_HCCA_reg[15 : 8] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l1041_10) begin
            reg_hcHCCA_HCCA_reg[23 : 16] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h020 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_11) begin
            reg_hcControlHeadED_CHED_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l1041_12) begin
            reg_hcControlHeadED_CHED_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l1041_13) begin
            reg_hcControlHeadED_CHED_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l1041_14) begin
            reg_hcControlHeadED_CHED_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h024 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_15) begin
            reg_hcControlCurrentED_CCED_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l1041_16) begin
            reg_hcControlCurrentED_CCED_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l1041_17) begin
            reg_hcControlCurrentED_CCED_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l1041_18) begin
            reg_hcControlCurrentED_CCED_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h028 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_19) begin
            reg_hcBulkHeadED_BHED_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l1041_20) begin
            reg_hcBulkHeadED_BHED_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l1041_21) begin
            reg_hcBulkHeadED_BHED_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l1041_22) begin
            reg_hcBulkHeadED_BHED_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h02c : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_23) begin
            reg_hcBulkCurrentED_BCED_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l1041_24) begin
            reg_hcBulkCurrentED_BCED_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l1041_25) begin
            reg_hcBulkCurrentED_BCED_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l1041_26) begin
            reg_hcBulkCurrentED_BCED_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h030 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_27) begin
            reg_hcDoneHead_DH_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l1041_28) begin
            reg_hcDoneHead_DH_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l1041_29) begin
            reg_hcDoneHead_DH_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l1041_30) begin
            reg_hcDoneHead_DH_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h034 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_31) begin
            reg_hcFmInterval_FI[7 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 0];
          end
          if(when_BusSlaveFactory_l1041_32) begin
            reg_hcFmInterval_FI[13 : 8] <= io_ctrl_cmd_payload_fragment_data[13 : 8];
          end
          if(when_BusSlaveFactory_l1041_33) begin
            reg_hcFmInterval_FSMPS[7 : 0] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l1041_34) begin
            reg_hcFmInterval_FSMPS[14 : 8] <= io_ctrl_cmd_payload_fragment_data[30 : 24];
          end
          if(when_BusSlaveFactory_l1041_35) begin
            reg_hcFmInterval_FIT <= io_ctrl_cmd_payload_fragment_data[31];
          end
        end
      end
      12'h044 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_38) begin
            reg_hcLSThreshold_LST[7 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 0];
          end
          if(when_BusSlaveFactory_l1041_39) begin
            reg_hcLSThreshold_LST[11 : 8] <= io_ctrl_cmd_payload_fragment_data[11 : 8];
          end
        end
      end
      12'h048 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_40) begin
            reg_hcRhDescriptorA_PSM <= io_ctrl_cmd_payload_fragment_data[8];
          end
          if(when_BusSlaveFactory_l1041_41) begin
            reg_hcRhDescriptorA_NPS <= io_ctrl_cmd_payload_fragment_data[9];
          end
          if(when_BusSlaveFactory_l1041_42) begin
            reg_hcRhDescriptorA_OCPM <= io_ctrl_cmd_payload_fragment_data[11];
          end
          if(when_BusSlaveFactory_l1041_43) begin
            reg_hcRhDescriptorA_NOCP <= io_ctrl_cmd_payload_fragment_data[12];
          end
          if(when_BusSlaveFactory_l1041_44) begin
            reg_hcRhDescriptorA_POTPGT[7 : 0] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h04c : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l1041_45) begin
            reg_hcRhDescriptorB_DR[3 : 0] <= io_ctrl_cmd_payload_fragment_data[4 : 1];
          end
          if(when_BusSlaveFactory_l1041_46) begin
            reg_hcRhDescriptorB_PPCM[3 : 0] <= io_ctrl_cmd_payload_fragment_data[20 : 17];
          end
        end
      end
      default : begin
      end
    endcase
    if(when_UsbOhci_l255) begin
      reg_hcControl_CBSR <= 2'b00;
      reg_hcControl_PLE <= 1'b0;
      reg_hcControl_IE <= 1'b0;
      reg_hcControl_CLE <= 1'b0;
      reg_hcControl_BLE <= 1'b0;
      reg_hcControl_RWE <= 1'b0;
      reg_hcCommandStatus_CLF <= 1'b0;
      reg_hcCommandStatus_BLF <= 1'b0;
      reg_hcCommandStatus_OCR <= 1'b0;
      reg_hcCommandStatus_SOC <= 2'b00;
      reg_hcInterrupt_MIE <= 1'b0;
      reg_hcInterrupt_SO_status <= 1'b0;
      reg_hcInterrupt_SO_enable <= 1'b0;
      reg_hcInterrupt_WDH_status <= 1'b0;
      reg_hcInterrupt_WDH_enable <= 1'b0;
      reg_hcInterrupt_SF_status <= 1'b0;
      reg_hcInterrupt_SF_enable <= 1'b0;
      reg_hcInterrupt_RD_status <= 1'b0;
      reg_hcInterrupt_RD_enable <= 1'b0;
      reg_hcInterrupt_UE_status <= 1'b0;
      reg_hcInterrupt_UE_enable <= 1'b0;
      reg_hcInterrupt_FNO_status <= 1'b0;
      reg_hcInterrupt_FNO_enable <= 1'b0;
      reg_hcInterrupt_RHSC_status <= 1'b0;
      reg_hcInterrupt_RHSC_enable <= 1'b0;
      reg_hcInterrupt_OC_status <= 1'b0;
      reg_hcInterrupt_OC_enable <= 1'b0;
      reg_hcHCCA_HCCA_reg <= 24'h000000;
      reg_hcPeriodCurrentED_PCED_reg <= 28'h0000000;
      reg_hcControlHeadED_CHED_reg <= 28'h0000000;
      reg_hcControlCurrentED_CCED_reg <= 28'h0000000;
      reg_hcBulkHeadED_BHED_reg <= 28'h0000000;
      reg_hcBulkCurrentED_BCED_reg <= 28'h0000000;
      reg_hcDoneHead_DH_reg <= 28'h0000000;
      reg_hcFmInterval_FI <= 14'h2edf;
      reg_hcFmInterval_FIT <= 1'b0;
      reg_hcFmRemaining_FR <= 14'h0000;
      reg_hcFmRemaining_FRT <= 1'b0;
      reg_hcFmNumber_FN <= 16'h0000;
      reg_hcLSThreshold_LST <= 12'h628;
      reg_hcRhDescriptorA_PSM <= 1'b0;
      reg_hcRhDescriptorA_NPS <= 1'b0;
      reg_hcRhDescriptorA_OCPM <= 1'b0;
      reg_hcRhDescriptorA_NOCP <= 1'b0;
      reg_hcRhDescriptorA_POTPGT <= 8'h0a;
      reg_hcRhDescriptorB_DR <= {1'b0,{1'b0,{1'b0,1'b0}}};
      reg_hcRhDescriptorB_PPCM <= {1'b1,{1'b1,{1'b1,1'b1}}};
      reg_hcRhStatus_DRWE <= 1'b0;
      reg_hcRhStatus_CCIC <= 1'b0;
      reg_hcRhPortStatus_0_resume <= 1'b0;
      reg_hcRhPortStatus_0_reset <= 1'b0;
      reg_hcRhPortStatus_0_suspend <= 1'b0;
      reg_hcRhPortStatus_0_PSS <= 1'b0;
      reg_hcRhPortStatus_0_PPS <= 1'b0;
      reg_hcRhPortStatus_0_PES <= 1'b0;
      reg_hcRhPortStatus_0_CSC_reg <= 1'b0;
      reg_hcRhPortStatus_0_PESC_reg <= 1'b0;
      reg_hcRhPortStatus_0_PSSC_reg <= 1'b0;
      reg_hcRhPortStatus_0_OCIC_reg <= 1'b0;
      reg_hcRhPortStatus_0_PRSC_reg <= 1'b0;
      reg_hcRhPortStatus_1_resume <= 1'b0;
      reg_hcRhPortStatus_1_reset <= 1'b0;
      reg_hcRhPortStatus_1_suspend <= 1'b0;
      reg_hcRhPortStatus_1_PSS <= 1'b0;
      reg_hcRhPortStatus_1_PPS <= 1'b0;
      reg_hcRhPortStatus_1_PES <= 1'b0;
      reg_hcRhPortStatus_1_CSC_reg <= 1'b0;
      reg_hcRhPortStatus_1_PESC_reg <= 1'b0;
      reg_hcRhPortStatus_1_PSSC_reg <= 1'b0;
      reg_hcRhPortStatus_1_OCIC_reg <= 1'b0;
      reg_hcRhPortStatus_1_PRSC_reg <= 1'b0;
      reg_hcRhPortStatus_2_resume <= 1'b0;
      reg_hcRhPortStatus_2_reset <= 1'b0;
      reg_hcRhPortStatus_2_suspend <= 1'b0;
      reg_hcRhPortStatus_2_PSS <= 1'b0;
      reg_hcRhPortStatus_2_PPS <= 1'b0;
      reg_hcRhPortStatus_2_PES <= 1'b0;
      reg_hcRhPortStatus_2_CSC_reg <= 1'b0;
      reg_hcRhPortStatus_2_PESC_reg <= 1'b0;
      reg_hcRhPortStatus_2_PSSC_reg <= 1'b0;
      reg_hcRhPortStatus_2_OCIC_reg <= 1'b0;
      reg_hcRhPortStatus_2_PRSC_reg <= 1'b0;
      reg_hcRhPortStatus_3_resume <= 1'b0;
      reg_hcRhPortStatus_3_reset <= 1'b0;
      reg_hcRhPortStatus_3_suspend <= 1'b0;
      reg_hcRhPortStatus_3_PSS <= 1'b0;
      reg_hcRhPortStatus_3_PPS <= 1'b0;
      reg_hcRhPortStatus_3_PES <= 1'b0;
      reg_hcRhPortStatus_3_CSC_reg <= 1'b0;
      reg_hcRhPortStatus_3_PESC_reg <= 1'b0;
      reg_hcRhPortStatus_3_PSSC_reg <= 1'b0;
      reg_hcRhPortStatus_3_OCIC_reg <= 1'b0;
      reg_hcRhPortStatus_3_PRSC_reg <= 1'b0;
    end
    case(dataRx_stateReg)
      UsbOhciAxi4_dataRx_enumDef_IDLE : begin
        if(!io_phy_rx_active) begin
          if(rxTimer_rxTimeout) begin
            dataRx_notResponding <= 1'b1;
          end
        end
      end
      UsbOhciAxi4_dataRx_enumDef_PID : begin
        dataRx_valids <= 2'b00;
        dataRx_pidError <= 1'b1;
        if(_zz_1) begin
          dataRx_pid <= _zz_dataRx_pid[3 : 0];
          dataRx_pidError <= (_zz_dataRx_pid[3 : 0] != (~ _zz_dataRx_pid[7 : 4]));
        end
      end
      UsbOhciAxi4_dataRx_enumDef_DATA : begin
        if(when_Misc_l70) begin
          if(when_Misc_l71) begin
            dataRx_crcError <= 1'b1;
          end
        end else begin
          if(_zz_1) begin
            dataRx_valids <= {dataRx_valids[0],1'b1};
          end
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253) begin
      dataRx_notResponding <= 1'b0;
      dataRx_stuffingError <= 1'b0;
      dataRx_pidError <= 1'b0;
      dataRx_crcError <= 1'b0;
    end
    if(when_Misc_l85) begin
      if(_zz_1) begin
        if(when_Misc_l87) begin
          dataRx_stuffingError <= 1'b1;
        end
      end
    end
    case(sof_stateReg)
      UsbOhciAxi4_sof_enumDef_FRAME_TX : begin
        sof_doInterruptDelay <= (interruptDelay_done && (! reg_hcInterrupt_WDH_status));
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciAxi4_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          reg_hcInterrupt_SF_status <= 1'b1;
          if(reg_hcFmNumber_overflow) begin
            reg_hcInterrupt_FNO_status <= 1'b1;
          end
          if(sof_doInterruptDelay) begin
            reg_hcInterrupt_WDH_status <= 1'b1;
            reg_hcDoneHead_DH_reg <= 28'h0000000;
          end
        end
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciAxi4_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ED_READ_RSP : begin
        if(when_UsbOhci_l189) begin
          endpoint_ED_words_0 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l189_1) begin
          endpoint_ED_words_1 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l189_2) begin
          endpoint_ED_words_2 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l189_3) begin
          endpoint_ED_words_3 <= dmaRspMux_vec_0[31 : 0];
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_RSP : begin
        if(when_UsbOhci_l189_4) begin
          endpoint_TD_words_0 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l189_5) begin
          endpoint_TD_words_1 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l189_6) begin
          endpoint_TD_words_2 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l189_7) begin
          endpoint_TD_words_3 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l893) begin
          if(when_UsbOhci_l189_8) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[12 : 0];
          end
          if(when_UsbOhci_l189_9) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(when_UsbOhci_l893_1) begin
          if(when_UsbOhci_l189_10) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[28 : 16];
          end
          if(when_UsbOhci_l189_11) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[12 : 0];
          end
        end
        if(when_UsbOhci_l893_2) begin
          if(when_UsbOhci_l189_12) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[12 : 0];
          end
          if(when_UsbOhci_l189_13) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(when_UsbOhci_l893_3) begin
          if(when_UsbOhci_l189_14) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[28 : 16];
          end
          if(when_UsbOhci_l189_15) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[12 : 0];
          end
        end
        if(when_UsbOhci_l893_4) begin
          if(when_UsbOhci_l189_16) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[12 : 0];
          end
          if(when_UsbOhci_l189_17) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(when_UsbOhci_l893_5) begin
          if(when_UsbOhci_l189_18) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[28 : 16];
          end
          if(when_UsbOhci_l189_19) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[12 : 0];
          end
        end
        if(when_UsbOhci_l893_6) begin
          if(when_UsbOhci_l189_20) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[12 : 0];
          end
          if(when_UsbOhci_l189_21) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(when_UsbOhci_l893_7) begin
          if(when_UsbOhci_l189_22) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(endpoint_TD_isoLast) begin
          endpoint_TD_isoBaseNext <= {(! endpoint_TD_isSinglePage),endpoint_TD_BE[11 : 0]};
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciAxi4_endpoint_enumDef_TD_ANALYSE : begin
        case(endpoint_flowType)
          UsbOhciAxi4_FlowType_CONTROL : begin
            reg_hcCommandStatus_CLF <= 1'b1;
          end
          UsbOhciAxi4_FlowType_BULK : begin
            reg_hcCommandStatus_BLF <= 1'b1;
          end
          default : begin
          end
        endcase
        endpoint_dmaLogic_byteCtx_counter <= endpoint_TD_firstOffset;
        endpoint_currentAddress <= {1'd0, endpoint_TD_firstOffset};
        endpoint_lastAddress <= _zz_endpoint_lastAddress_1[12:0];
        endpoint_zeroLength <= (endpoint_ED_F ? endpoint_TD_isoZero : (endpoint_TD_CBP == 32'h00000000));
        endpoint_dataPhase <= (endpoint_ED_F ? 1'b0 : (endpoint_TD_T[1] ? endpoint_TD_T[0] : endpoint_ED_C));
        if(endpoint_ED_F) begin
          if(endpoint_TD_isoOverrunReg) begin
            endpoint_TD_retire <= 1'b1;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TD_CHECK_TIME : begin
        if(endpoint_timeCheck) begin
          endpoint_status_1 <= UsbOhciAxi4_endpoint_Status_FRAME_TIME;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_BUFFER_READ : begin
        if(when_UsbOhci_l1130) begin
          if(endpoint_timeCheck) begin
            endpoint_status_1 <= UsbOhciAxi4_endpoint_Status_FRAME_TIME;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_TX : begin
        if(dataTx_wantExit) begin
          if(endpoint_ED_F) begin
            endpoint_TD_words_0[31 : 28] <= 4'b0000;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_VALIDATE : begin
        endpoint_TD_words_0[31 : 28] <= 4'b0000;
        if(dataRx_notResponding) begin
          endpoint_TD_words_0[31 : 28] <= 4'b0101;
        end else begin
          if(dataRx_stuffingError) begin
            endpoint_TD_words_0[31 : 28] <= 4'b0010;
          end else begin
            if(dataRx_pidError) begin
              endpoint_TD_words_0[31 : 28] <= 4'b0110;
            end else begin
              if(endpoint_ED_F) begin
                case(dataRx_pid)
                  4'b1110, 4'b1010 : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0100;
                  end
                  4'b0011, 4'b1011 : begin
                  end
                  default : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0111;
                  end
                endcase
              end else begin
                case(dataRx_pid)
                  4'b1010 : begin
                    endpoint_TD_noUpdate <= 1'b1;
                  end
                  4'b1110 : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0100;
                  end
                  4'b0011, 4'b1011 : begin
                    if(when_UsbOhci_l1265) begin
                      endpoint_TD_words_0[31 : 28] <= 4'b0011;
                    end
                  end
                  default : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0111;
                  end
                endcase
              end
              if(when_UsbOhci_l1276) begin
                if(dataRx_crcError) begin
                  endpoint_TD_words_0[31 : 28] <= 4'b0001;
                end else begin
                  if(endpoint_dmaLogic_underflowError) begin
                    endpoint_TD_words_0[31 : 28] <= 4'b1001;
                  end else begin
                    if(endpoint_dmaLogic_overflow) begin
                      endpoint_TD_words_0[31 : 28] <= 4'b1000;
                    end
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_RX : begin
        if(io_phy_rx_flow_valid) begin
          endpoint_ackRxFired <= 1'b1;
          endpoint_ackRxPid <= io_phy_rx_flow_payload_data[3 : 0];
          if(io_phy_rx_flow_payload_stuffingError) begin
            endpoint_ackRxStuffing <= 1'b1;
          end
          if(when_UsbOhci_l1202) begin
            endpoint_ackRxPidFailure <= 1'b1;
          end
        end
        if(io_phy_rx_active) begin
          endpoint_ackRxActivated <= 1'b1;
        end
        if(when_UsbOhci_l1207) begin
          if(when_UsbOhci_l1209) begin
            endpoint_TD_words_0[31 : 28] <= 4'b0110;
          end else begin
            if(endpoint_ackRxStuffing) begin
              endpoint_TD_words_0[31 : 28] <= 4'b0010;
            end else begin
              if(endpoint_ackRxPidFailure) begin
                endpoint_TD_words_0[31 : 28] <= 4'b0110;
              end else begin
                case(endpoint_ackRxPid)
                  4'b0010 : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0000;
                  end
                  4'b1010 : begin
                  end
                  4'b1110 : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0100;
                  end
                  default : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0111;
                  end
                endcase
              end
            end
          end
        end
        if(rxTimer_rxTimeout) begin
          endpoint_TD_words_0[31 : 28] <= 4'b0101;
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciAxi4_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciAxi4_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_PROCESS : begin
        if(endpoint_ED_F) begin
          if(endpoint_TD_isoLastReg) begin
            endpoint_TD_retire <= 1'b1;
          end
        end else begin
          endpoint_TD_words_0[27 : 26] <= 2'b00;
          case(endpoint_TD_CC)
            4'b0000 : begin
              if(when_UsbOhci_l1333) begin
                endpoint_TD_retire <= 1'b1;
              end
              endpoint_TD_dataPhaseUpdate <= 1'b1;
              endpoint_TD_upateCBP <= 1'b1;
            end
            4'b1001 : begin
              endpoint_TD_retire <= 1'b1;
              endpoint_TD_dataPhaseUpdate <= 1'b1;
              endpoint_TD_upateCBP <= 1'b1;
            end
            4'b1000 : begin
              endpoint_TD_retire <= 1'b1;
              endpoint_TD_dataPhaseUpdate <= 1'b1;
            end
            4'b0010, 4'b0001, 4'b0110, 4'b0101, 4'b0111, 4'b0011 : begin
              endpoint_TD_words_0[27 : 26] <= _zz_endpoint_TD_words_0;
              if(when_UsbOhci_l1348) begin
                endpoint_TD_words_0[31 : 28] <= 4'b0000;
              end else begin
                endpoint_TD_retire <= 1'b1;
              end
            end
            default : begin
              endpoint_TD_retire <= 1'b1;
            end
          endcase
          if(endpoint_TD_noUpdate) begin
            endpoint_TD_retire <= 1'b0;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_TD_CMD : begin
        endpoint_ED_words_2[0] <= ((! endpoint_ED_F) && (endpoint_TD_CC != 4'b0000));
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciAxi4_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(endpoint_TD_retire) begin
            reg_hcDoneHead_DH_reg <= endpoint_ED_headP;
          end
        end
      end
      UsbOhciAxi4_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l237_2) begin
      endpoint_status_1 <= UsbOhciAxi4_endpoint_Status_OK;
    end
    if(when_StateMachine_l253_4) begin
      endpoint_ackRxFired <= 1'b0;
      endpoint_ackRxActivated <= 1'b0;
      endpoint_ackRxPidFailure <= 1'b0;
      endpoint_ackRxStuffing <= 1'b0;
    end
    case(endpoint_dmaLogic_stateReg)
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_INIT : begin
        endpoint_dmaLogic_underflow <= 1'b0;
        endpoint_dmaLogic_overflow <= 1'b0;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_FROM_USB : begin
        if(dataRx_wantExit) begin
          endpoint_dmaLogic_underflow <= when_UsbOhci_l1056;
          endpoint_dmaLogic_overflow <= ((! when_UsbOhci_l1056) && (_zz_endpoint_dmaLogic_overflow != endpoint_transactionSize));
          if(endpoint_zeroLength) begin
            endpoint_dmaLogic_underflow <= 1'b0;
            endpoint_dmaLogic_overflow <= (endpoint_dmaLogic_fromUsbCounter != 11'h000);
          end
          if(when_UsbOhci_l1056) begin
            endpoint_lastAddress <= _zz_endpoint_lastAddress_5[12:0];
          end
        end
        if(dataRx_data_valid) begin
          endpoint_dmaLogic_fromUsbCounter <= (endpoint_dmaLogic_fromUsbCounter + _zz_endpoint_dmaLogic_fromUsbCounter);
          if(_zz_2[0]) begin
            endpoint_dmaLogic_buffer[7 : 0] <= dataRx_data_payload;
          end
          if(_zz_2[1]) begin
            endpoint_dmaLogic_buffer[15 : 8] <= dataRx_data_payload;
          end
          if(_zz_2[2]) begin
            endpoint_dmaLogic_buffer[23 : 16] <= dataRx_data_payload;
          end
          if(_zz_2[3]) begin
            endpoint_dmaLogic_buffer[31 : 24] <= dataRx_data_payload;
          end
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_CALC_CMD : begin
        endpoint_dmaLogic_length <= endpoint_dmaLogic_lengthCalc;
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_READ_CMD : begin
        if(ioDma_cmd_ready) begin
          endpoint_currentAddress <= (_zz_endpoint_currentAddress + 14'h0001);
        end
      end
      UsbOhciAxi4_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        if(ioDma_cmd_ready) begin
          if(endpoint_dmaLogic_beatLast) begin
            endpoint_currentAddress <= (_zz_endpoint_currentAddress_2 + 14'h0001);
          end
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l253_5) begin
      endpoint_dmaLogic_fromUsbCounter <= 11'h000;
    end
    case(operational_stateReg)
      UsbOhciAxi4_operational_enumDef_SOF : begin
        if(sof_wantExit) begin
          if(when_UsbOhci_l1463) begin
            reg_hcInterrupt_SO_status <= 1'b1;
            reg_hcCommandStatus_SOC <= (reg_hcCommandStatus_SOC + 2'b01);
          end
          operational_allowBulk <= reg_hcControl_BLE;
          operational_allowControl <= reg_hcControl_CLE;
          operational_allowPeriodic <= reg_hcControl_PLE;
          operational_allowIsochronous <= reg_hcControl_IE;
          operational_periodicDone <= 1'b0;
          operational_periodicHeadFetched <= 1'b0;
          priority_bulk <= 1'b0;
          priority_counter <= 2'b00;
        end
      end
      UsbOhciAxi4_operational_enumDef_ARBITER : begin
        if(reg_hcControl_BLE) begin
          operational_allowBulk <= 1'b1;
        end
        if(reg_hcControl_CLE) begin
          operational_allowControl <= 1'b1;
        end
        if(!operational_askExit) begin
          if(!frame_limitHit) begin
            if(when_UsbOhci_l1489) begin
              if(!when_UsbOhci_l1490) begin
                if(reg_hcPeriodCurrentED_isZero) begin
                  operational_periodicDone <= 1'b1;
                end else begin
                  endpoint_flowType <= UsbOhciAxi4_FlowType_PERIODIC;
                  endpoint_ED_address <= reg_hcPeriodCurrentED_PCED_address;
                end
              end
            end else begin
              if(priority_bulk) begin
                if(operational_allowBulk) begin
                  if(reg_hcBulkCurrentED_isZero) begin
                    if(reg_hcCommandStatus_BLF) begin
                      reg_hcBulkCurrentED_BCED_reg <= reg_hcBulkHeadED_BHED_reg;
                      reg_hcCommandStatus_BLF <= 1'b0;
                    end
                  end else begin
                    endpoint_flowType <= UsbOhciAxi4_FlowType_BULK;
                    endpoint_ED_address <= reg_hcBulkCurrentED_BCED_address;
                  end
                end
              end else begin
                if(operational_allowControl) begin
                  if(reg_hcControlCurrentED_isZero) begin
                    if(reg_hcCommandStatus_CLF) begin
                      reg_hcControlCurrentED_CCED_reg <= reg_hcControlHeadED_CHED_reg;
                      reg_hcCommandStatus_CLF <= 1'b0;
                    end
                  end else begin
                    endpoint_flowType <= UsbOhciAxi4_FlowType_CONTROL;
                    endpoint_ED_address <= reg_hcControlCurrentED_CCED_address;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciAxi4_operational_enumDef_END_POINT : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_CMD : begin
      end
      UsbOhciAxi4_operational_enumDef_PERIODIC_HEAD_RSP : begin
        if(ioDma_rsp_valid) begin
          operational_periodicHeadFetched <= 1'b1;
          reg_hcPeriodCurrentED_PCED_reg <= dmaRspMux_data[31 : 4];
        end
      end
      UsbOhciAxi4_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l237_3) begin
      operational_allowPeriodic <= 1'b0;
    end
    case(hc_stateReg)
      UsbOhciAxi4_hc_enumDef_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_RESUME : begin
      end
      UsbOhciAxi4_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciAxi4_hc_enumDef_SUSPEND : begin
        if(when_UsbOhci_l1627) begin
          reg_hcInterrupt_RD_status <= 1'b1;
        end
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciAxi4_hc_enumDef_ANY_TO_SUSPEND : begin
      end
      default : begin
      end
    endcase
  end

  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      ioDma_cmd_payload_first <= 1'b1;
    end else begin
      if(ioDma_cmd_fire) begin
        ioDma_cmd_payload_first <= ioDma_cmd_payload_last;
      end
    end
  end


endmodule

module UsbOhciAxi4_StreamArbiter (
  input  wire          io_inputs_0_valid,
  output wire          io_inputs_0_ready,
  input  wire [11:0]   io_inputs_0_payload_addr,
  input  wire [7:0]    io_inputs_0_payload_id,
  input  wire [3:0]    io_inputs_0_payload_region,
  input  wire [7:0]    io_inputs_0_payload_len,
  input  wire [2:0]    io_inputs_0_payload_size,
  input  wire [1:0]    io_inputs_0_payload_burst,
  input  wire [0:0]    io_inputs_0_payload_lock,
  input  wire [3:0]    io_inputs_0_payload_cache,
  input  wire [3:0]    io_inputs_0_payload_qos,
  input  wire [2:0]    io_inputs_0_payload_prot,
  input  wire          io_inputs_1_valid,
  output wire          io_inputs_1_ready,
  input  wire [11:0]   io_inputs_1_payload_addr,
  input  wire [7:0]    io_inputs_1_payload_id,
  input  wire [3:0]    io_inputs_1_payload_region,
  input  wire [7:0]    io_inputs_1_payload_len,
  input  wire [2:0]    io_inputs_1_payload_size,
  input  wire [1:0]    io_inputs_1_payload_burst,
  input  wire [0:0]    io_inputs_1_payload_lock,
  input  wire [3:0]    io_inputs_1_payload_cache,
  input  wire [3:0]    io_inputs_1_payload_qos,
  input  wire [2:0]    io_inputs_1_payload_prot,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire [11:0]   io_output_payload_addr,
  output wire [7:0]    io_output_payload_id,
  output wire [3:0]    io_output_payload_region,
  output wire [7:0]    io_output_payload_len,
  output wire [2:0]    io_output_payload_size,
  output wire [1:0]    io_output_payload_burst,
  output wire [0:0]    io_output_payload_lock,
  output wire [3:0]    io_output_payload_cache,
  output wire [3:0]    io_output_payload_qos,
  output wire [2:0]    io_output_payload_prot,
  output wire [0:0]    io_chosen,
  output wire [1:0]    io_chosenOH,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire       [3:0]    _zz__zz_maskProposal_0_2;
  wire       [3:0]    _zz__zz_maskProposal_0_2_1;
  wire       [1:0]    _zz__zz_maskProposal_0_2_2;
  reg                 locked;
  wire                maskProposal_0;
  wire                maskProposal_1;
  reg                 maskLocked_0;
  reg                 maskLocked_1;
  wire                maskRouted_0;
  wire                maskRouted_1;
  wire       [1:0]    _zz_maskProposal_0;
  wire       [3:0]    _zz_maskProposal_0_1;
  wire       [3:0]    _zz_maskProposal_0_2;
  wire       [1:0]    _zz_maskProposal_0_3;
  wire                io_output_fire;
  wire                _zz_io_chosen;

  assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
  assign _zz__zz_maskProposal_0_2_2 = {maskLocked_0,maskLocked_1};
  assign _zz__zz_maskProposal_0_2_1 = {2'd0, _zz__zz_maskProposal_0_2_2};
  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign maskRouted_1 = (locked ? maskLocked_1 : maskProposal_1);
  assign _zz_maskProposal_0 = {io_inputs_1_valid,io_inputs_0_valid};
  assign _zz_maskProposal_0_1 = {_zz_maskProposal_0,_zz_maskProposal_0};
  assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~ _zz__zz_maskProposal_0_2));
  assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[3 : 2] | _zz_maskProposal_0_2[1 : 0]);
  assign maskProposal_0 = _zz_maskProposal_0_3[0];
  assign maskProposal_1 = _zz_maskProposal_0_3[1];
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign io_output_valid = ((io_inputs_0_valid && maskRouted_0) || (io_inputs_1_valid && maskRouted_1));
  assign io_output_payload_addr = (maskRouted_0 ? io_inputs_0_payload_addr : io_inputs_1_payload_addr);
  assign io_output_payload_id = (maskRouted_0 ? io_inputs_0_payload_id : io_inputs_1_payload_id);
  assign io_output_payload_region = (maskRouted_0 ? io_inputs_0_payload_region : io_inputs_1_payload_region);
  assign io_output_payload_len = (maskRouted_0 ? io_inputs_0_payload_len : io_inputs_1_payload_len);
  assign io_output_payload_size = (maskRouted_0 ? io_inputs_0_payload_size : io_inputs_1_payload_size);
  assign io_output_payload_burst = (maskRouted_0 ? io_inputs_0_payload_burst : io_inputs_1_payload_burst);
  assign io_output_payload_lock = (maskRouted_0 ? io_inputs_0_payload_lock : io_inputs_1_payload_lock);
  assign io_output_payload_cache = (maskRouted_0 ? io_inputs_0_payload_cache : io_inputs_1_payload_cache);
  assign io_output_payload_qos = (maskRouted_0 ? io_inputs_0_payload_qos : io_inputs_1_payload_qos);
  assign io_output_payload_prot = (maskRouted_0 ? io_inputs_0_payload_prot : io_inputs_1_payload_prot);
  assign io_inputs_0_ready = (maskRouted_0 && io_output_ready);
  assign io_inputs_1_ready = (maskRouted_1 && io_output_ready);
  assign io_chosenOH = {maskRouted_1,maskRouted_0};
  assign _zz_io_chosen = io_chosenOH[1];
  assign io_chosen = _zz_io_chosen;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      locked <= 1'b0;
      maskLocked_0 <= 1'b0;
      maskLocked_1 <= 1'b1;
    end else begin
      if(io_output_valid) begin
        maskLocked_0 <= maskRouted_0;
        maskLocked_1 <= maskRouted_1;
      end
      if(io_output_valid) begin
        locked <= 1'b1;
      end
      if(io_output_fire) begin
        locked <= 1'b0;
      end
    end
  end


endmodule

module UsbOhciAxi4_Axi4SharedToBmb (
  input  wire          io_axi_arw_valid,
  output wire          io_axi_arw_ready,
  input  wire [11:0]   io_axi_arw_payload_addr,
  input  wire [7:0]    io_axi_arw_payload_id,
  input  wire [3:0]    io_axi_arw_payload_region,
  input  wire [7:0]    io_axi_arw_payload_len,
  input  wire [2:0]    io_axi_arw_payload_size,
  input  wire [1:0]    io_axi_arw_payload_burst,
  input  wire [0:0]    io_axi_arw_payload_lock,
  input  wire [3:0]    io_axi_arw_payload_cache,
  input  wire [3:0]    io_axi_arw_payload_qos,
  input  wire [2:0]    io_axi_arw_payload_prot,
  input  wire          io_axi_arw_payload_write,
  input  wire          io_axi_w_valid,
  output wire          io_axi_w_ready,
  input  wire [31:0]   io_axi_w_payload_data,
  input  wire [3:0]    io_axi_w_payload_strb,
  input  wire          io_axi_w_payload_last,
  output wire          io_axi_b_valid,
  input  wire          io_axi_b_ready,
  output wire [7:0]    io_axi_b_payload_id,
  output reg  [1:0]    io_axi_b_payload_resp,
  output wire          io_axi_r_valid,
  input  wire          io_axi_r_ready,
  output wire [31:0]   io_axi_r_payload_data,
  output wire [7:0]    io_axi_r_payload_id,
  output reg  [1:0]    io_axi_r_payload_resp,
  output wire          io_axi_r_payload_last,
  output wire          io_bmb_cmd_valid,
  input  wire          io_bmb_cmd_ready,
  output wire          io_bmb_cmd_payload_last,
  output wire [8:0]    io_bmb_cmd_payload_fragment_source,
  output wire [0:0]    io_bmb_cmd_payload_fragment_opcode,
  output wire [11:0]   io_bmb_cmd_payload_fragment_address,
  output wire [9:0]    io_bmb_cmd_payload_fragment_length,
  output wire [31:0]   io_bmb_cmd_payload_fragment_data,
  output wire [3:0]    io_bmb_cmd_payload_fragment_mask,
  input  wire          io_bmb_rsp_valid,
  output wire          io_bmb_rsp_ready,
  input  wire          io_bmb_rsp_payload_last,
  input  wire [8:0]    io_bmb_rsp_payload_fragment_source,
  input  wire [0:0]    io_bmb_rsp_payload_fragment_opcode,
  input  wire [31:0]   io_bmb_rsp_payload_fragment_data
);

  wire       [9:0]    _zz_io_bmb_cmd_payload_fragment_length;
  wire                hazard;
  wire                io_bmb_cmd_fire;
  wire                rspIsWrite;
  wire                when_Axi4SharedToBmb_l42;
  wire                when_Axi4SharedToBmb_l49;

  assign _zz_io_bmb_cmd_payload_fragment_length = ({2'd0,io_axi_arw_payload_len} <<< 2'd2);
  assign hazard = (io_axi_arw_payload_write && (! io_axi_w_valid));
  assign io_bmb_cmd_valid = (io_axi_arw_valid && (! hazard));
  assign io_bmb_cmd_payload_fragment_source = {io_axi_arw_payload_write,io_axi_arw_payload_id};
  assign io_bmb_cmd_payload_fragment_opcode = io_axi_arw_payload_write;
  assign io_bmb_cmd_payload_fragment_address = io_axi_arw_payload_addr;
  assign io_bmb_cmd_payload_fragment_length = (_zz_io_bmb_cmd_payload_fragment_length | 10'h003);
  assign io_bmb_cmd_payload_fragment_data = io_axi_w_payload_data;
  assign io_bmb_cmd_payload_fragment_mask = io_axi_w_payload_strb;
  assign io_bmb_cmd_payload_last = ((! io_axi_arw_payload_write) || io_axi_w_payload_last);
  assign io_bmb_cmd_fire = (io_bmb_cmd_valid && io_bmb_cmd_ready);
  assign io_axi_arw_ready = (io_bmb_cmd_fire && io_bmb_cmd_payload_last);
  assign io_axi_w_ready = (io_bmb_cmd_fire && (io_bmb_cmd_payload_fragment_opcode == 1'b1));
  assign rspIsWrite = io_bmb_rsp_payload_fragment_source[8];
  assign io_axi_b_valid = (io_bmb_rsp_valid && rspIsWrite);
  assign io_axi_b_payload_id = io_bmb_rsp_payload_fragment_source[7:0];
  always @(*) begin
    io_axi_b_payload_resp = 2'b00;
    if(when_Axi4SharedToBmb_l42) begin
      io_axi_b_payload_resp = 2'b11;
    end
  end

  assign when_Axi4SharedToBmb_l42 = (io_bmb_rsp_payload_fragment_opcode == 1'b1);
  assign io_axi_r_valid = (io_bmb_rsp_valid && (! rspIsWrite));
  assign io_axi_r_payload_data = io_bmb_rsp_payload_fragment_data;
  assign io_axi_r_payload_id = io_bmb_rsp_payload_fragment_source[7:0];
  assign io_axi_r_payload_last = io_bmb_rsp_payload_last;
  always @(*) begin
    io_axi_r_payload_resp = 2'b00;
    if(when_Axi4SharedToBmb_l49) begin
      io_axi_r_payload_resp = 2'b11;
    end
  end

  assign when_Axi4SharedToBmb_l49 = (io_bmb_rsp_payload_fragment_opcode == 1'b1);
  assign io_bmb_rsp_ready = (rspIsWrite ? io_axi_b_ready : io_axi_r_ready);

endmodule

module UsbOhciAxi4_BmbToAxi4SharedBridge (
  input  wire          io_input_cmd_valid,
  output wire          io_input_cmd_ready,
  input  wire          io_input_cmd_payload_last,
  input  wire [0:0]    io_input_cmd_payload_fragment_opcode,
  input  wire [31:0]   io_input_cmd_payload_fragment_address,
  input  wire [5:0]    io_input_cmd_payload_fragment_length,
  input  wire [31:0]   io_input_cmd_payload_fragment_data,
  input  wire [3:0]    io_input_cmd_payload_fragment_mask,
  output reg           io_input_rsp_valid,
  input  wire          io_input_rsp_ready,
  output reg           io_input_rsp_payload_last,
  output reg  [0:0]    io_input_rsp_payload_fragment_opcode,
  output wire [31:0]   io_input_rsp_payload_fragment_data,
  output wire          io_output_arw_valid,
  input  wire          io_output_arw_ready,
  output wire [31:0]   io_output_arw_payload_addr,
  output wire [7:0]    io_output_arw_payload_len,
  output wire [2:0]    io_output_arw_payload_size,
  output wire [3:0]    io_output_arw_payload_cache,
  output wire [2:0]    io_output_arw_payload_prot,
  output wire          io_output_arw_payload_write,
  output wire          io_output_w_valid,
  input  wire          io_output_w_ready,
  output wire [31:0]   io_output_w_payload_data,
  output wire [3:0]    io_output_w_payload_strb,
  output wire          io_output_w_payload_last,
  input  wire          io_output_b_valid,
  output wire          io_output_b_ready,
  input  wire [1:0]    io_output_b_payload_resp,
  input  wire          io_output_r_valid,
  output wire          io_output_r_ready,
  input  wire [31:0]   io_output_r_payload_data,
  input  wire [1:0]    io_output_r_payload_resp,
  input  wire          io_output_r_payload_last,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire                writeCmdInfo_fifo_io_pop_ready;
  wire                writeCmdInfo_fifo_io_flush;
  wire                readCmdInfo_fifo_io_pop_ready;
  wire                readCmdInfo_fifo_io_flush;
  wire                writeCmdInfo_fifo_io_push_ready;
  wire                writeCmdInfo_fifo_io_pop_valid;
  wire       [5:0]    writeCmdInfo_fifo_io_occupancy;
  wire       [5:0]    writeCmdInfo_fifo_io_availability;
  wire                readCmdInfo_fifo_io_push_ready;
  wire                readCmdInfo_fifo_io_pop_valid;
  wire       [5:0]    readCmdInfo_fifo_io_occupancy;
  wire       [5:0]    readCmdInfo_fifo_io_availability;
  wire       [3:0]    _zz_io_output_arw_payload_len;
  reg                 pendingWrite;
  reg        [4:0]    pendingCounter;
  wire                io_input_cmd_fire;
  wire                when_Utils_l706;
  wire                io_input_rsp_fire;
  wire                when_Utils_l709;
  reg                 states_0_counter_incrementIt;
  reg                 states_0_counter_decrementIt;
  wire       [4:0]    states_0_counter_valueNext;
  reg        [4:0]    states_0_counter_value;
  wire                states_0_counter_mayOverflow;
  wire                states_0_counter_willOverflowIfInc;
  wire                states_0_counter_willOverflow;
  reg        [4:0]    states_0_counter_finalIncrement;
  wire                when_Utils_l735;
  wire                when_Utils_l737;
  wire                when_BmbToAxi4Bridge_l45;
  reg                 states_0_write;
  wire                when_BmbToAxi4Bridge_l47;
  wire                hazard;
  wire                _zz_io_input_cmd_ready;
  wire                _zz_cmdFork_valid;
  reg                 _zz_io_input_cmd_ready_1;
  wire                _zz_cmdFork_payload_last;
  wire       [0:0]    _zz_cmdFork_payload_fragment_opcode;
  wire       [31:0]   _zz_cmdFork_payload_fragment_address;
  wire       [5:0]    _zz_cmdFork_payload_fragment_length;
  wire       [31:0]   _zz_cmdFork_payload_fragment_data;
  wire       [3:0]    _zz_cmdFork_payload_fragment_mask;
  wire                cmdFork_valid;
  reg                 cmdFork_ready;
  wire                cmdFork_payload_last;
  wire       [0:0]    cmdFork_payload_fragment_opcode;
  wire       [31:0]   cmdFork_payload_fragment_address;
  wire       [5:0]    cmdFork_payload_fragment_length;
  wire       [31:0]   cmdFork_payload_fragment_data;
  wire       [3:0]    cmdFork_payload_fragment_mask;
  wire                dataFork_valid;
  reg                 dataFork_ready;
  wire                dataFork_payload_last;
  wire       [0:0]    dataFork_payload_fragment_opcode;
  wire       [31:0]   dataFork_payload_fragment_address;
  wire       [5:0]    dataFork_payload_fragment_length;
  wire       [31:0]   dataFork_payload_fragment_data;
  wire       [3:0]    dataFork_payload_fragment_mask;
  reg                 _zz_cmdFork_valid_1;
  reg                 _zz_dataFork_valid;
  wire                when_Stream_l1049;
  wire                when_Stream_l1049_1;
  wire                cmdFork_fire;
  wire                dataFork_fire;
  reg                 io_input_cmd_payload_first;
  wire                when_Stream_l439;
  reg                 cmdStage_valid;
  wire                cmdStage_ready;
  wire                cmdStage_payload_last;
  wire       [0:0]    cmdStage_payload_fragment_opcode;
  wire       [31:0]   cmdStage_payload_fragment_address;
  wire       [5:0]    cmdStage_payload_fragment_length;
  wire       [31:0]   cmdStage_payload_fragment_data;
  wire       [3:0]    cmdStage_payload_fragment_mask;
  wire                when_Stream_l439_1;
  reg                 dataStage_valid;
  wire                dataStage_ready;
  wire                dataStage_payload_last;
  wire       [0:0]    dataStage_payload_fragment_opcode;
  wire       [31:0]   dataStage_payload_fragment_address;
  wire       [5:0]    dataStage_payload_fragment_length;
  wire       [31:0]   dataStage_payload_fragment_data;
  wire       [3:0]    dataStage_payload_fragment_mask;
  wire                writeCmdInfo_valid;
  wire                writeCmdInfo_ready;
  wire                readCmdInfo_valid;
  wire                readCmdInfo_ready;
  wire                cmdStage_fire;
  wire                writeRspInfo_valid;
  wire                writeRspInfo_ready;
  reg                 front_dmaBridge_writeCmdInfo_fifo_io_pop_rValid;
  wire                writeRspInfo_fire;
  wire                readRspInfo_valid;
  wire                readRspInfo_ready;
  reg                 front_dmaBridge_readCmdInfo_fifo_io_pop_rValid;
  wire                readRspInfo_fire;
  wire                _zz_io_output_arw_valid;
  reg                 rspSelLock;
  wire                when_BmbToAxi4Bridge_l87;
  wire                io_output_r_fire;
  wire                io_output_b_fire;
  wire                when_BmbToAxi4Bridge_l87_1;
  wire                when_BmbToAxi4Bridge_l88;
  reg                 rspSelReadLast;
  wire                rspSelRead;
  wire                when_BmbToAxi4Bridge_l108;

  assign _zz_io_output_arw_payload_len = io_input_cmd_payload_fragment_length[5 : 2];
  UsbOhciAxi4_StreamFifo_1 writeCmdInfo_fifo (
    .io_push_valid   (writeCmdInfo_valid                    ), //i
    .io_push_ready   (writeCmdInfo_fifo_io_push_ready       ), //o
    .io_pop_valid    (writeCmdInfo_fifo_io_pop_valid        ), //o
    .io_pop_ready    (writeCmdInfo_fifo_io_pop_ready        ), //i
    .io_flush        (writeCmdInfo_fifo_io_flush            ), //i
    .io_occupancy    (writeCmdInfo_fifo_io_occupancy[5:0]   ), //o
    .io_availability (writeCmdInfo_fifo_io_availability[5:0]), //o
    .ctrl_clk        (ctrl_clk                              ), //i
    .ctrl_reset      (ctrl_reset                            )  //i
  );
  UsbOhciAxi4_StreamFifo_1 readCmdInfo_fifo (
    .io_push_valid   (readCmdInfo_valid                    ), //i
    .io_push_ready   (readCmdInfo_fifo_io_push_ready       ), //o
    .io_pop_valid    (readCmdInfo_fifo_io_pop_valid        ), //o
    .io_pop_ready    (readCmdInfo_fifo_io_pop_ready        ), //i
    .io_flush        (readCmdInfo_fifo_io_flush            ), //i
    .io_occupancy    (readCmdInfo_fifo_io_occupancy[5:0]   ), //o
    .io_availability (readCmdInfo_fifo_io_availability[5:0]), //o
    .ctrl_clk        (ctrl_clk                             ), //i
    .ctrl_reset      (ctrl_reset                           )  //i
  );
  always @(*) begin
    pendingWrite = 1'bx;
    if(when_BmbToAxi4Bridge_l47) begin
      pendingWrite = states_0_write;
    end
  end

  always @(*) begin
    pendingCounter = 5'bxxxxx;
    if(when_BmbToAxi4Bridge_l47) begin
      pendingCounter = states_0_counter_value;
    end
  end

  assign io_input_cmd_fire = (io_input_cmd_valid && io_input_cmd_ready);
  assign when_Utils_l706 = ((1'b1 && io_input_cmd_fire) && io_input_cmd_payload_last);
  assign io_input_rsp_fire = (io_input_rsp_valid && io_input_rsp_ready);
  assign when_Utils_l709 = ((1'b1 && io_input_rsp_fire) && io_input_rsp_payload_last);
  always @(*) begin
    states_0_counter_incrementIt = 1'b0;
    if(when_Utils_l706) begin
      states_0_counter_incrementIt = 1'b1;
    end
  end

  always @(*) begin
    states_0_counter_decrementIt = 1'b0;
    if(when_Utils_l709) begin
      states_0_counter_decrementIt = 1'b1;
    end
  end

  assign states_0_counter_mayOverflow = (states_0_counter_value == 5'h1f);
  assign states_0_counter_willOverflowIfInc = (states_0_counter_mayOverflow && (! states_0_counter_decrementIt));
  assign states_0_counter_willOverflow = (states_0_counter_willOverflowIfInc && states_0_counter_incrementIt);
  assign when_Utils_l735 = (states_0_counter_incrementIt && (! states_0_counter_decrementIt));
  always @(*) begin
    if(when_Utils_l735) begin
      states_0_counter_finalIncrement = 5'h01;
    end else begin
      if(when_Utils_l737) begin
        states_0_counter_finalIncrement = 5'h1f;
      end else begin
        states_0_counter_finalIncrement = 5'h00;
      end
    end
  end

  assign when_Utils_l737 = ((! states_0_counter_incrementIt) && states_0_counter_decrementIt);
  assign states_0_counter_valueNext = (states_0_counter_value + states_0_counter_finalIncrement);
  assign when_BmbToAxi4Bridge_l45 = (1'b1 && io_input_cmd_fire);
  assign when_BmbToAxi4Bridge_l47 = 1'b1;
  assign hazard = ((((io_input_cmd_payload_fragment_opcode == 1'b1) != pendingWrite) && (pendingCounter != 5'h00)) || (pendingCounter == 5'h1f));
  assign _zz_io_input_cmd_ready = (! hazard);
  assign _zz_cmdFork_valid = (io_input_cmd_valid && _zz_io_input_cmd_ready);
  assign io_input_cmd_ready = (_zz_io_input_cmd_ready_1 && _zz_io_input_cmd_ready);
  assign _zz_cmdFork_payload_last = io_input_cmd_payload_last;
  assign _zz_cmdFork_payload_fragment_opcode = io_input_cmd_payload_fragment_opcode;
  assign _zz_cmdFork_payload_fragment_address = io_input_cmd_payload_fragment_address;
  assign _zz_cmdFork_payload_fragment_length = io_input_cmd_payload_fragment_length;
  assign _zz_cmdFork_payload_fragment_data = io_input_cmd_payload_fragment_data;
  assign _zz_cmdFork_payload_fragment_mask = io_input_cmd_payload_fragment_mask;
  always @(*) begin
    _zz_io_input_cmd_ready_1 = 1'b1;
    if(when_Stream_l1049) begin
      _zz_io_input_cmd_ready_1 = 1'b0;
    end
    if(when_Stream_l1049_1) begin
      _zz_io_input_cmd_ready_1 = 1'b0;
    end
  end

  assign when_Stream_l1049 = ((! cmdFork_ready) && _zz_cmdFork_valid_1);
  assign when_Stream_l1049_1 = ((! dataFork_ready) && _zz_dataFork_valid);
  assign cmdFork_valid = (_zz_cmdFork_valid && _zz_cmdFork_valid_1);
  assign cmdFork_payload_last = _zz_cmdFork_payload_last;
  assign cmdFork_payload_fragment_opcode = _zz_cmdFork_payload_fragment_opcode;
  assign cmdFork_payload_fragment_address = _zz_cmdFork_payload_fragment_address;
  assign cmdFork_payload_fragment_length = _zz_cmdFork_payload_fragment_length;
  assign cmdFork_payload_fragment_data = _zz_cmdFork_payload_fragment_data;
  assign cmdFork_payload_fragment_mask = _zz_cmdFork_payload_fragment_mask;
  assign cmdFork_fire = (cmdFork_valid && cmdFork_ready);
  assign dataFork_valid = (_zz_cmdFork_valid && _zz_dataFork_valid);
  assign dataFork_payload_last = _zz_cmdFork_payload_last;
  assign dataFork_payload_fragment_opcode = _zz_cmdFork_payload_fragment_opcode;
  assign dataFork_payload_fragment_address = _zz_cmdFork_payload_fragment_address;
  assign dataFork_payload_fragment_length = _zz_cmdFork_payload_fragment_length;
  assign dataFork_payload_fragment_data = _zz_cmdFork_payload_fragment_data;
  assign dataFork_payload_fragment_mask = _zz_cmdFork_payload_fragment_mask;
  assign dataFork_fire = (dataFork_valid && dataFork_ready);
  assign when_Stream_l439 = (! io_input_cmd_payload_first);
  always @(*) begin
    cmdStage_valid = cmdFork_valid;
    if(when_Stream_l439) begin
      cmdStage_valid = 1'b0;
    end
  end

  always @(*) begin
    cmdFork_ready = cmdStage_ready;
    if(when_Stream_l439) begin
      cmdFork_ready = 1'b1;
    end
  end

  assign cmdStage_payload_last = cmdFork_payload_last;
  assign cmdStage_payload_fragment_opcode = cmdFork_payload_fragment_opcode;
  assign cmdStage_payload_fragment_address = cmdFork_payload_fragment_address;
  assign cmdStage_payload_fragment_length = cmdFork_payload_fragment_length;
  assign cmdStage_payload_fragment_data = cmdFork_payload_fragment_data;
  assign cmdStage_payload_fragment_mask = cmdFork_payload_fragment_mask;
  assign when_Stream_l439_1 = (! (dataFork_payload_fragment_opcode == 1'b1));
  always @(*) begin
    dataStage_valid = dataFork_valid;
    if(when_Stream_l439_1) begin
      dataStage_valid = 1'b0;
    end
  end

  always @(*) begin
    dataFork_ready = dataStage_ready;
    if(when_Stream_l439_1) begin
      dataFork_ready = 1'b1;
    end
  end

  assign dataStage_payload_last = dataFork_payload_last;
  assign dataStage_payload_fragment_opcode = dataFork_payload_fragment_opcode;
  assign dataStage_payload_fragment_address = dataFork_payload_fragment_address;
  assign dataStage_payload_fragment_length = dataFork_payload_fragment_length;
  assign dataStage_payload_fragment_data = dataFork_payload_fragment_data;
  assign dataStage_payload_fragment_mask = dataFork_payload_fragment_mask;
  assign cmdStage_fire = (cmdStage_valid && cmdStage_ready);
  assign writeCmdInfo_valid = (cmdStage_fire && (cmdStage_payload_fragment_opcode == 1'b1));
  assign readCmdInfo_valid = (cmdStage_fire && (cmdStage_payload_fragment_opcode == 1'b0));
  assign writeCmdInfo_ready = writeCmdInfo_fifo_io_push_ready;
  assign writeRspInfo_fire = (writeRspInfo_valid && writeRspInfo_ready);
  assign writeCmdInfo_fifo_io_pop_ready = (! front_dmaBridge_writeCmdInfo_fifo_io_pop_rValid);
  assign writeRspInfo_valid = front_dmaBridge_writeCmdInfo_fifo_io_pop_rValid;
  assign readCmdInfo_ready = readCmdInfo_fifo_io_push_ready;
  assign readRspInfo_fire = (readRspInfo_valid && readRspInfo_ready);
  assign readCmdInfo_fifo_io_pop_ready = (! front_dmaBridge_readCmdInfo_fifo_io_pop_rValid);
  assign readRspInfo_valid = front_dmaBridge_readCmdInfo_fifo_io_pop_rValid;
  assign _zz_io_output_arw_valid = (! ((! writeCmdInfo_ready) || (! readCmdInfo_ready)));
  assign cmdStage_ready = (io_output_arw_ready && _zz_io_output_arw_valid);
  assign io_output_arw_valid = (cmdStage_valid && _zz_io_output_arw_valid);
  assign io_output_arw_payload_write = (io_input_cmd_payload_fragment_opcode == 1'b1);
  assign io_output_arw_payload_addr = io_input_cmd_payload_fragment_address;
  assign io_output_arw_payload_len = {4'd0, _zz_io_output_arw_payload_len};
  assign io_output_arw_payload_size = 3'b010;
  assign io_output_arw_payload_prot = 3'b010;
  assign io_output_arw_payload_cache = 4'b1111;
  assign io_output_w_valid = dataStage_valid;
  assign dataStage_ready = io_output_w_ready;
  assign io_output_w_payload_data = dataStage_payload_fragment_data;
  assign io_output_w_payload_strb = dataStage_payload_fragment_mask;
  assign io_output_w_payload_last = dataStage_payload_last;
  assign when_BmbToAxi4Bridge_l87 = (io_output_r_valid || io_output_b_valid);
  assign io_output_r_fire = (io_output_r_valid && io_output_r_ready);
  assign io_output_b_fire = (io_output_b_valid && io_output_b_ready);
  assign when_BmbToAxi4Bridge_l87_1 = ((io_output_r_fire && io_output_r_payload_last) || io_output_b_fire);
  assign when_BmbToAxi4Bridge_l88 = (! rspSelLock);
  assign rspSelRead = (rspSelLock ? rspSelReadLast : io_output_r_valid);
  assign io_output_b_ready = ((io_input_rsp_ready && (! rspSelRead)) && writeRspInfo_valid);
  assign io_output_r_ready = ((io_input_rsp_ready && rspSelRead) && readRspInfo_valid);
  assign writeRspInfo_ready = ((io_input_rsp_fire && io_input_rsp_payload_last) && (! rspSelRead));
  assign readRspInfo_ready = ((io_input_rsp_fire && io_input_rsp_payload_last) && rspSelRead);
  assign io_input_rsp_payload_fragment_data = io_output_r_payload_data;
  always @(*) begin
    if(rspSelRead) begin
      io_input_rsp_valid = (io_output_r_valid && readRspInfo_valid);
    end else begin
      io_input_rsp_valid = (io_output_b_valid && writeRspInfo_valid);
    end
  end

  always @(*) begin
    if(rspSelRead) begin
      io_input_rsp_payload_last = io_output_r_payload_last;
    end else begin
      io_input_rsp_payload_last = 1'b1;
    end
  end

  assign when_BmbToAxi4Bridge_l108 = (rspSelRead ? (io_output_r_payload_resp == 2'b00) : (io_output_b_payload_resp == 2'b00));
  always @(*) begin
    if(when_BmbToAxi4Bridge_l108) begin
      io_input_rsp_payload_fragment_opcode = 1'b0;
    end else begin
      io_input_rsp_payload_fragment_opcode = 1'b1;
    end
  end

  assign writeCmdInfo_fifo_io_flush = 1'b0;
  assign readCmdInfo_fifo_io_flush = 1'b0;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      states_0_counter_value <= 5'h00;
      _zz_cmdFork_valid_1 <= 1'b1;
      _zz_dataFork_valid <= 1'b1;
      io_input_cmd_payload_first <= 1'b1;
      front_dmaBridge_writeCmdInfo_fifo_io_pop_rValid <= 1'b0;
      front_dmaBridge_readCmdInfo_fifo_io_pop_rValid <= 1'b0;
      rspSelLock <= 1'b0;
    end else begin
      states_0_counter_value <= states_0_counter_valueNext;
      if(cmdFork_fire) begin
        _zz_cmdFork_valid_1 <= 1'b0;
      end
      if(dataFork_fire) begin
        _zz_dataFork_valid <= 1'b0;
      end
      if(_zz_io_input_cmd_ready_1) begin
        _zz_cmdFork_valid_1 <= 1'b1;
        _zz_dataFork_valid <= 1'b1;
      end
      if(io_input_cmd_fire) begin
        io_input_cmd_payload_first <= io_input_cmd_payload_last;
      end
      if(writeCmdInfo_fifo_io_pop_valid) begin
        front_dmaBridge_writeCmdInfo_fifo_io_pop_rValid <= 1'b1;
      end
      if(writeRspInfo_fire) begin
        front_dmaBridge_writeCmdInfo_fifo_io_pop_rValid <= 1'b0;
      end
      if(readCmdInfo_fifo_io_pop_valid) begin
        front_dmaBridge_readCmdInfo_fifo_io_pop_rValid <= 1'b1;
      end
      if(readRspInfo_fire) begin
        front_dmaBridge_readCmdInfo_fifo_io_pop_rValid <= 1'b0;
      end
      if(when_BmbToAxi4Bridge_l87) begin
        rspSelLock <= 1'b1;
      end
      if(when_BmbToAxi4Bridge_l87_1) begin
        rspSelLock <= 1'b0;
      end
    end
  end

  always @(posedge ctrl_clk) begin
    if(when_BmbToAxi4Bridge_l45) begin
      states_0_write <= (io_input_cmd_payload_fragment_opcode == 1'b1);
    end
    if(when_BmbToAxi4Bridge_l88) begin
      rspSelReadLast <= io_output_r_valid;
    end
  end


endmodule

//UsbOhciAxi4_StreamCCByToggle_16 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_15 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_14 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_13 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_13 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_12 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_11 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_BufferCC_28 replaced by UsbOhciAxi4_BufferCC_11

//UsbOhciAxi4_BufferCC_27 replaced by UsbOhciAxi4_BufferCC_11

//UsbOhciAxi4_BufferCC_26 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_25 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_StreamCCByToggle_12 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_11 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_10 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_9 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_10 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_9 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_8 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_BufferCC_24 replaced by UsbOhciAxi4_BufferCC_11

//UsbOhciAxi4_BufferCC_23 replaced by UsbOhciAxi4_BufferCC_11

//UsbOhciAxi4_BufferCC_22 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_21 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_StreamCCByToggle_8 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_7 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_6 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_5 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_7 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_6 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_5 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_BufferCC_20 replaced by UsbOhciAxi4_BufferCC_11

//UsbOhciAxi4_BufferCC_19 replaced by UsbOhciAxi4_BufferCC_11

//UsbOhciAxi4_BufferCC_18 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_17 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_StreamCCByToggle_4 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_3 replaced by UsbOhciAxi4_StreamCCByToggle_1

//UsbOhciAxi4_StreamCCByToggle_2 replaced by UsbOhciAxi4_StreamCCByToggle_1

module UsbOhciAxi4_StreamCCByToggle_1 (
  input  wire          io_input_valid,
  output wire          io_input_ready,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset,
  input  wire          phy_clk,
  input  wire          ctrl_reset_syncronized
);

  wire                outHitSignal_buffercc_io_dataOut;
  wire                pushArea_target_buffercc_io_dataOut;
  wire                outHitSignal;
  wire                pushArea_hit;
  wire                pushArea_accept;
  reg                 pushArea_target;
  reg                 _zz_io_input_ready;
  wire                popArea_stream_valid;
  wire                popArea_stream_ready;
  wire                popArea_target;
  wire                popArea_stream_fire;
  reg                 popArea_hit;

  UsbOhciAxi4_BufferCC_77 outHitSignal_buffercc (
    .io_dataIn  (outHitSignal                    ), //i
    .io_dataOut (outHitSignal_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                        ), //i
    .ctrl_reset (ctrl_reset                      )  //i
  );
  UsbOhciAxi4_BufferCC_79 pushArea_target_buffercc (
    .io_dataIn              (pushArea_target                    ), //i
    .io_dataOut             (pushArea_target_buffercc_io_dataOut), //o
    .phy_clk                (phy_clk                            ), //i
    .ctrl_reset_syncronized (ctrl_reset_syncronized             )  //i
  );
  assign pushArea_hit = outHitSignal_buffercc_io_dataOut;
  assign pushArea_accept = ((! _zz_io_input_ready) && io_input_valid);
  assign io_input_ready = (_zz_io_input_ready && (pushArea_hit == pushArea_target));
  assign popArea_target = pushArea_target_buffercc_io_dataOut;
  assign popArea_stream_fire = (popArea_stream_valid && popArea_stream_ready);
  assign outHitSignal = popArea_hit;
  assign popArea_stream_valid = (popArea_target != popArea_hit);
  assign io_output_valid = popArea_stream_valid;
  assign popArea_stream_ready = io_output_ready;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      pushArea_target <= 1'b0;
      _zz_io_input_ready <= 1'b0;
    end else begin
      if(pushArea_accept) begin
        pushArea_target <= (! pushArea_target);
      end
      if(pushArea_accept) begin
        _zz_io_input_ready <= 1'b1;
      end
      if(io_input_ready) begin
        _zz_io_input_ready <= 1'b0;
      end
    end
  end

  always @(posedge phy_clk or posedge ctrl_reset_syncronized) begin
    if(ctrl_reset_syncronized) begin
      popArea_hit <= 1'b0;
    end else begin
      if(popArea_stream_fire) begin
        popArea_hit <= popArea_target;
      end
    end
  end


endmodule

//UsbOhciAxi4_PulseCCByToggle_4 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_3 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_PulseCCByToggle_2 replaced by UsbOhciAxi4_PulseCCByToggle_1

//UsbOhciAxi4_BufferCC_16 replaced by UsbOhciAxi4_BufferCC_11

//UsbOhciAxi4_BufferCC_15 replaced by UsbOhciAxi4_BufferCC_11

//UsbOhciAxi4_BufferCC_14 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_13 replaced by UsbOhciAxi4_BufferCC_8

module UsbOhciAxi4_PulseCCByToggle_1 (
  input  wire          io_pulseIn,
  output wire          io_pulseOut,
  input  wire          phy_clk,
  input  wire          phy_reset,
  input  wire          ctrl_clk,
  input  wire          phy_reset_syncronized
);

  wire                inArea_target_buffercc_io_dataOut;
  reg                 inArea_target;
  wire                outArea_target;
  reg                 outArea_target_regNext;

  UsbOhciAxi4_BufferCC_76 inArea_target_buffercc (
    .io_dataIn             (inArea_target                    ), //i
    .io_dataOut            (inArea_target_buffercc_io_dataOut), //o
    .ctrl_clk              (ctrl_clk                         ), //i
    .phy_reset_syncronized (phy_reset_syncronized            )  //i
  );
  assign outArea_target = inArea_target_buffercc_io_dataOut;
  assign io_pulseOut = (outArea_target ^ outArea_target_regNext);
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      inArea_target <= 1'b0;
    end else begin
      if(io_pulseIn) begin
        inArea_target <= (! inArea_target);
      end
    end
  end

  always @(posedge ctrl_clk or posedge phy_reset_syncronized) begin
    if(phy_reset_syncronized) begin
      outArea_target_regNext <= 1'b0;
    end else begin
      outArea_target_regNext <= outArea_target;
    end
  end


endmodule

//UsbOhciAxi4_BufferCC_12 replaced by UsbOhciAxi4_BufferCC_11

module UsbOhciAxi4_FlowCCByToggle (
  input  wire          io_input_valid,
  input  wire          io_input_payload_stuffingError,
  input  wire [7:0]    io_input_payload_data,
  output wire          io_output_valid,
  output wire          io_output_payload_stuffingError,
  output wire [7:0]    io_output_payload_data,
  input  wire          phy_clk,
  input  wire          phy_reset,
  input  wire          ctrl_clk,
  input  wire          phy_reset_syncronized
);

  wire                inputArea_target_buffercc_io_dataOut;
  reg                 inputArea_target;
  reg                 inputArea_data_stuffingError;
  reg        [7:0]    inputArea_data_data;
  wire                outputArea_target;
  reg                 outputArea_hit;
  wire                outputArea_flow_valid;
  wire                outputArea_flow_payload_stuffingError;
  wire       [7:0]    outputArea_flow_payload_data;
  reg                 outputArea_flow_m2sPipe_valid;
  (* async_reg = "true" *) reg                 outputArea_flow_m2sPipe_payload_stuffingError;
  (* async_reg = "true" *) reg        [7:0]    outputArea_flow_m2sPipe_payload_data;

  UsbOhciAxi4_BufferCC_76 inputArea_target_buffercc (
    .io_dataIn             (inputArea_target                    ), //i
    .io_dataOut            (inputArea_target_buffercc_io_dataOut), //o
    .ctrl_clk              (ctrl_clk                            ), //i
    .phy_reset_syncronized (phy_reset_syncronized               )  //i
  );
  assign outputArea_target = inputArea_target_buffercc_io_dataOut;
  assign outputArea_flow_valid = (outputArea_target != outputArea_hit);
  assign outputArea_flow_payload_stuffingError = inputArea_data_stuffingError;
  assign outputArea_flow_payload_data = inputArea_data_data;
  assign io_output_valid = outputArea_flow_m2sPipe_valid;
  assign io_output_payload_stuffingError = outputArea_flow_m2sPipe_payload_stuffingError;
  assign io_output_payload_data = outputArea_flow_m2sPipe_payload_data;
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      inputArea_target <= 1'b0;
    end else begin
      if(io_input_valid) begin
        inputArea_target <= (! inputArea_target);
      end
    end
  end

  always @(posedge phy_clk) begin
    if(io_input_valid) begin
      inputArea_data_stuffingError <= io_input_payload_stuffingError;
      inputArea_data_data <= io_input_payload_data;
    end
  end

  always @(posedge ctrl_clk or posedge phy_reset_syncronized) begin
    if(phy_reset_syncronized) begin
      outputArea_flow_m2sPipe_valid <= 1'b0;
      outputArea_hit <= 1'b0;
    end else begin
      outputArea_hit <= outputArea_target;
      outputArea_flow_m2sPipe_valid <= outputArea_flow_valid;
    end
  end

  always @(posedge ctrl_clk) begin
    if(outputArea_flow_valid) begin
      outputArea_flow_m2sPipe_payload_stuffingError <= outputArea_flow_payload_stuffingError;
      outputArea_flow_m2sPipe_payload_data <= outputArea_flow_payload_data;
    end
  end


endmodule

module UsbOhciAxi4_PulseCCByToggle (
  input  wire          io_pulseIn,
  output wire          io_pulseOut,
  input  wire          phy_clk,
  input  wire          phy_reset,
  input  wire          ctrl_clk,
  output wire          phy_reset_syncronized_1
);

  wire                bufferCC_io_dataIn;
  wire                bufferCC_io_dataOut;
  wire                inArea_target_buffercc_io_dataOut;
  reg                 inArea_target;
  wire                phy_reset_syncronized;
  wire                outArea_target;
  reg                 outArea_target_regNext;

  UsbOhciAxi4_BufferCC_75 bufferCC (
    .io_dataIn  (bufferCC_io_dataIn ), //i
    .io_dataOut (bufferCC_io_dataOut), //o
    .ctrl_clk   (ctrl_clk           ), //i
    .phy_reset  (phy_reset          )  //i
  );
  UsbOhciAxi4_BufferCC_76 inArea_target_buffercc (
    .io_dataIn             (inArea_target                    ), //i
    .io_dataOut            (inArea_target_buffercc_io_dataOut), //o
    .ctrl_clk              (ctrl_clk                         ), //i
    .phy_reset_syncronized (phy_reset_syncronized            )  //i
  );
  assign bufferCC_io_dataIn = (1'b0 ^ 1'b0);
  assign phy_reset_syncronized = bufferCC_io_dataOut;
  assign outArea_target = inArea_target_buffercc_io_dataOut;
  assign io_pulseOut = (outArea_target ^ outArea_target_regNext);
  assign phy_reset_syncronized_1 = phy_reset_syncronized;
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      inArea_target <= 1'b0;
    end else begin
      if(io_pulseIn) begin
        inArea_target <= (! inArea_target);
      end
    end
  end

  always @(posedge ctrl_clk or posedge phy_reset_syncronized) begin
    if(phy_reset_syncronized) begin
      outArea_target_regNext <= 1'b0;
    end else begin
      outArea_target_regNext <= outArea_target;
    end
  end


endmodule

module UsbOhciAxi4_StreamCCByToggle (
  input  wire          io_input_valid,
  output wire          io_input_ready,
  input  wire          io_input_payload_last,
  input  wire [7:0]    io_input_payload_fragment,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire          io_output_payload_last,
  output wire [7:0]    io_output_payload_fragment,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset,
  input  wire          phy_clk,
  output wire          ctrl_reset_syncronized_1
);

  wire                bufferCC_io_dataIn;
  wire                outHitSignal_buffercc_io_dataOut;
  wire                bufferCC_io_dataOut;
  wire                pushArea_target_buffercc_io_dataOut;
  wire                outHitSignal;
  wire                pushArea_hit;
  wire                pushArea_accept;
  reg                 pushArea_target;
  reg                 pushArea_data_last;
  reg        [7:0]    pushArea_data_fragment;
  wire                io_input_fire;
  wire                ctrl_reset_syncronized;
  wire                popArea_stream_valid;
  reg                 popArea_stream_ready;
  wire                popArea_stream_payload_last;
  wire       [7:0]    popArea_stream_payload_fragment;
  wire                popArea_target;
  wire                popArea_stream_fire;
  reg                 popArea_hit;
  wire                popArea_stream_m2sPipe_valid;
  wire                popArea_stream_m2sPipe_ready;
  wire                popArea_stream_m2sPipe_payload_last;
  wire       [7:0]    popArea_stream_m2sPipe_payload_fragment;
  reg                 popArea_stream_rValid;
  (* async_reg = "true" *) reg                 popArea_stream_rData_last;
  (* async_reg = "true" *) reg        [7:0]    popArea_stream_rData_fragment;
  wire                when_Stream_l369;

  UsbOhciAxi4_BufferCC_77 outHitSignal_buffercc (
    .io_dataIn  (outHitSignal                    ), //i
    .io_dataOut (outHitSignal_buffercc_io_dataOut), //o
    .ctrl_clk   (ctrl_clk                        ), //i
    .ctrl_reset (ctrl_reset                      )  //i
  );
  UsbOhciAxi4_BufferCC_78 bufferCC (
    .io_dataIn  (bufferCC_io_dataIn ), //i
    .io_dataOut (bufferCC_io_dataOut), //o
    .phy_clk    (phy_clk            ), //i
    .ctrl_reset (ctrl_reset         )  //i
  );
  UsbOhciAxi4_BufferCC_79 pushArea_target_buffercc (
    .io_dataIn              (pushArea_target                    ), //i
    .io_dataOut             (pushArea_target_buffercc_io_dataOut), //o
    .phy_clk                (phy_clk                            ), //i
    .ctrl_reset_syncronized (ctrl_reset_syncronized             )  //i
  );
  assign pushArea_hit = outHitSignal_buffercc_io_dataOut;
  assign io_input_fire = (io_input_valid && io_input_ready);
  assign pushArea_accept = io_input_fire;
  assign io_input_ready = (pushArea_hit == pushArea_target);
  assign bufferCC_io_dataIn = (1'b0 ^ 1'b0);
  assign ctrl_reset_syncronized = bufferCC_io_dataOut;
  assign popArea_target = pushArea_target_buffercc_io_dataOut;
  assign popArea_stream_fire = (popArea_stream_valid && popArea_stream_ready);
  assign outHitSignal = popArea_hit;
  assign popArea_stream_valid = (popArea_target != popArea_hit);
  assign popArea_stream_payload_last = pushArea_data_last;
  assign popArea_stream_payload_fragment = pushArea_data_fragment;
  always @(*) begin
    popArea_stream_ready = popArea_stream_m2sPipe_ready;
    if(when_Stream_l369) begin
      popArea_stream_ready = 1'b1;
    end
  end

  assign when_Stream_l369 = (! popArea_stream_m2sPipe_valid);
  assign popArea_stream_m2sPipe_valid = popArea_stream_rValid;
  assign popArea_stream_m2sPipe_payload_last = popArea_stream_rData_last;
  assign popArea_stream_m2sPipe_payload_fragment = popArea_stream_rData_fragment;
  assign io_output_valid = popArea_stream_m2sPipe_valid;
  assign popArea_stream_m2sPipe_ready = io_output_ready;
  assign io_output_payload_last = popArea_stream_m2sPipe_payload_last;
  assign io_output_payload_fragment = popArea_stream_m2sPipe_payload_fragment;
  assign ctrl_reset_syncronized_1 = ctrl_reset_syncronized;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      pushArea_target <= 1'b0;
    end else begin
      if(pushArea_accept) begin
        pushArea_target <= (! pushArea_target);
      end
    end
  end

  always @(posedge ctrl_clk) begin
    if(pushArea_accept) begin
      pushArea_data_last <= io_input_payload_last;
      pushArea_data_fragment <= io_input_payload_fragment;
    end
  end

  always @(posedge phy_clk or posedge ctrl_reset_syncronized) begin
    if(ctrl_reset_syncronized) begin
      popArea_hit <= 1'b0;
      popArea_stream_rValid <= 1'b0;
    end else begin
      if(popArea_stream_fire) begin
        popArea_hit <= popArea_target;
      end
      if(popArea_stream_ready) begin
        popArea_stream_rValid <= popArea_stream_valid;
      end
    end
  end

  always @(posedge phy_clk) begin
    if(popArea_stream_fire) begin
      popArea_stream_rData_last <= popArea_stream_payload_last;
      popArea_stream_rData_fragment <= popArea_stream_payload_fragment;
    end
  end


endmodule

module UsbOhciAxi4_BufferCC_11 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end


endmodule

//UsbOhciAxi4_BufferCC_10 replaced by UsbOhciAxi4_BufferCC_8

//UsbOhciAxi4_BufferCC_9 replaced by UsbOhciAxi4_BufferCC_8

module UsbOhciAxi4_BufferCC_8 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          phy_clk,
  input  wire          phy_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge phy_clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end


endmodule

//UsbOhciAxi4_UsbLsFsPhyFilter_3 replaced by UsbOhciAxi4_UsbLsFsPhyFilter

//UsbOhciAxi4_UsbLsFsPhyFilter_2 replaced by UsbOhciAxi4_UsbLsFsPhyFilter

//UsbOhciAxi4_UsbLsFsPhyFilter_1 replaced by UsbOhciAxi4_UsbLsFsPhyFilter

module UsbOhciAxi4_UsbLsFsPhyFilter (
  input  wire          io_lowSpeed,
  input  wire          io_usb_dp,
  input  wire          io_usb_dm,
  output wire          io_filtred_dp,
  output wire          io_filtred_dm,
  output wire          io_filtred_d,
  output wire          io_filtred_se0,
  output wire          io_filtred_sample,
  input  wire          phy_clk,
  input  wire          phy_reset
);

  wire       [4:0]    _zz_timer_sampleDo;
  reg                 timer_clear;
  reg        [4:0]    timer_counter;
  wire       [4:0]    timer_counterLimit;
  wire                when_UsbHubPhy_l98;
  wire       [3:0]    timer_sampleAt;
  wire                timer_sampleDo;
  reg                 io_usb_dp_regNext;
  reg                 io_usb_dm_regNext;
  wire                when_UsbHubPhy_l105;

  assign _zz_timer_sampleDo = {1'd0, timer_sampleAt};
  always @(*) begin
    timer_clear = 1'b0;
    if(when_UsbHubPhy_l105) begin
      timer_clear = 1'b1;
    end
  end

  assign timer_counterLimit = (io_lowSpeed ? 5'h1f : 5'h03);
  assign when_UsbHubPhy_l98 = ((timer_counter == timer_counterLimit) || timer_clear);
  assign timer_sampleAt = (io_lowSpeed ? 4'b1110 : 4'b0000);
  assign timer_sampleDo = ((timer_counter == _zz_timer_sampleDo) && (! timer_clear));
  assign when_UsbHubPhy_l105 = ((io_usb_dp ^ io_usb_dp_regNext) || (io_usb_dm ^ io_usb_dm_regNext));
  assign io_filtred_dp = io_usb_dp;
  assign io_filtred_dm = io_usb_dm;
  assign io_filtred_d = io_usb_dp;
  assign io_filtred_sample = timer_sampleDo;
  assign io_filtred_se0 = ((! io_usb_dp) && (! io_usb_dm));
  always @(posedge phy_clk) begin
    timer_counter <= (timer_counter + 5'h01);
    if(when_UsbHubPhy_l98) begin
      timer_counter <= 5'h00;
    end
    io_usb_dp_regNext <= io_usb_dp;
    io_usb_dm_regNext <= io_usb_dm;
  end


endmodule

module UsbOhciAxi4_Crc_2 (
  input  wire          io_flush,
  input  wire          io_input_valid,
  input  wire [7:0]    io_input_payload,
  output wire [15:0]   io_result,
  output wire [15:0]   io_resultNext,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire       [15:0]   _zz_acc_1;
  wire       [15:0]   _zz_acc_2;
  wire       [15:0]   _zz_acc_3;
  wire       [15:0]   _zz_acc_4;
  wire       [15:0]   _zz_acc_5;
  wire       [15:0]   _zz_acc_6;
  wire       [15:0]   _zz_acc_7;
  wire       [15:0]   _zz_acc_8;
  reg        [15:0]   acc_8;
  reg        [15:0]   acc_7;
  reg        [15:0]   acc_6;
  reg        [15:0]   acc_5;
  reg        [15:0]   acc_4;
  reg        [15:0]   acc_3;
  reg        [15:0]   acc_2;
  reg        [15:0]   acc_1;
  reg        [15:0]   state;
  wire       [15:0]   acc;
  wire       [15:0]   stateXor;
  wire       [15:0]   accXor;

  assign _zz_acc_1 = (acc <<< 1);
  assign _zz_acc_2 = (acc_1 <<< 1);
  assign _zz_acc_3 = (acc_2 <<< 1);
  assign _zz_acc_4 = (acc_3 <<< 1);
  assign _zz_acc_5 = (acc_4 <<< 1);
  assign _zz_acc_6 = (acc_5 <<< 1);
  assign _zz_acc_7 = (acc_6 <<< 1);
  assign _zz_acc_8 = (acc_7 <<< 1);
  always @(*) begin
    acc_8 = acc_7;
    acc_8 = (_zz_acc_8 ^ ((io_input_payload[7] ^ acc_7[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_7 = acc_6;
    acc_7 = (_zz_acc_7 ^ ((io_input_payload[6] ^ acc_6[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_6 = acc_5;
    acc_6 = (_zz_acc_6 ^ ((io_input_payload[5] ^ acc_5[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_5 = acc_4;
    acc_5 = (_zz_acc_5 ^ ((io_input_payload[4] ^ acc_4[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_4 = acc_3;
    acc_4 = (_zz_acc_4 ^ ((io_input_payload[3] ^ acc_3[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_3 = acc_2;
    acc_3 = (_zz_acc_3 ^ ((io_input_payload[2] ^ acc_2[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_2 = acc_1;
    acc_2 = (_zz_acc_2 ^ ((io_input_payload[1] ^ acc_1[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_1 = acc;
    acc_1 = (_zz_acc_1 ^ ((io_input_payload[0] ^ acc[15]) ? 16'h8005 : 16'h0000));
  end

  assign acc = state;
  assign stateXor = (state ^ 16'h0000);
  assign accXor = (acc_8 ^ 16'h0000);
  assign io_result = stateXor;
  assign io_resultNext = accXor;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 16'hffff;
    end else begin
      if(io_input_valid) begin
        state <= acc_8;
      end
      if(io_flush) begin
        state <= 16'hffff;
      end
    end
  end


endmodule

module UsbOhciAxi4_Crc_1 (
  input  wire          io_flush,
  input  wire          io_input_valid,
  input  wire [7:0]    io_input_payload,
  output wire [15:0]   io_result,
  output wire [15:0]   io_resultNext,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire       [15:0]   _zz_acc_1;
  wire       [15:0]   _zz_acc_2;
  wire       [15:0]   _zz_acc_3;
  wire       [15:0]   _zz_acc_4;
  wire       [15:0]   _zz_acc_5;
  wire       [15:0]   _zz_acc_6;
  wire       [15:0]   _zz_acc_7;
  wire       [15:0]   _zz_acc_8;
  wire                _zz_io_result;
  wire       [0:0]    _zz_io_result_1;
  wire       [6:0]    _zz_io_result_2;
  wire                _zz_io_resultNext;
  wire       [0:0]    _zz_io_resultNext_1;
  wire       [6:0]    _zz_io_resultNext_2;
  reg        [15:0]   acc_8;
  reg        [15:0]   acc_7;
  reg        [15:0]   acc_6;
  reg        [15:0]   acc_5;
  reg        [15:0]   acc_4;
  reg        [15:0]   acc_3;
  reg        [15:0]   acc_2;
  reg        [15:0]   acc_1;
  reg        [15:0]   state;
  wire       [15:0]   acc;
  wire       [15:0]   stateXor;
  wire       [15:0]   accXor;

  assign _zz_acc_1 = (acc <<< 1);
  assign _zz_acc_2 = (acc_1 <<< 1);
  assign _zz_acc_3 = (acc_2 <<< 1);
  assign _zz_acc_4 = (acc_3 <<< 1);
  assign _zz_acc_5 = (acc_4 <<< 1);
  assign _zz_acc_6 = (acc_5 <<< 1);
  assign _zz_acc_7 = (acc_6 <<< 1);
  assign _zz_acc_8 = (acc_7 <<< 1);
  assign _zz_io_result = stateXor[7];
  assign _zz_io_result_1 = stateXor[8];
  assign _zz_io_result_2 = {stateXor[9],{stateXor[10],{stateXor[11],{stateXor[12],{stateXor[13],{stateXor[14],stateXor[15]}}}}}};
  assign _zz_io_resultNext = accXor[7];
  assign _zz_io_resultNext_1 = accXor[8];
  assign _zz_io_resultNext_2 = {accXor[9],{accXor[10],{accXor[11],{accXor[12],{accXor[13],{accXor[14],accXor[15]}}}}}};
  always @(*) begin
    acc_8 = acc_7;
    acc_8 = (_zz_acc_8 ^ ((io_input_payload[7] ^ acc_7[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_7 = acc_6;
    acc_7 = (_zz_acc_7 ^ ((io_input_payload[6] ^ acc_6[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_6 = acc_5;
    acc_6 = (_zz_acc_6 ^ ((io_input_payload[5] ^ acc_5[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_5 = acc_4;
    acc_5 = (_zz_acc_5 ^ ((io_input_payload[4] ^ acc_4[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_4 = acc_3;
    acc_4 = (_zz_acc_4 ^ ((io_input_payload[3] ^ acc_3[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_3 = acc_2;
    acc_3 = (_zz_acc_3 ^ ((io_input_payload[2] ^ acc_2[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_2 = acc_1;
    acc_2 = (_zz_acc_2 ^ ((io_input_payload[1] ^ acc_1[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_1 = acc;
    acc_1 = (_zz_acc_1 ^ ((io_input_payload[0] ^ acc[15]) ? 16'h8005 : 16'h0000));
  end

  assign acc = state;
  assign stateXor = (state ^ 16'hffff);
  assign accXor = (acc_8 ^ 16'hffff);
  assign io_result = {stateXor[0],{stateXor[1],{stateXor[2],{stateXor[3],{stateXor[4],{stateXor[5],{stateXor[6],{_zz_io_result,{_zz_io_result_1,_zz_io_result_2}}}}}}}}};
  assign io_resultNext = {accXor[0],{accXor[1],{accXor[2],{accXor[3],{accXor[4],{accXor[5],{accXor[6],{_zz_io_resultNext,{_zz_io_resultNext_1,_zz_io_resultNext_2}}}}}}}}};
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 16'hffff;
    end else begin
      if(io_input_valid) begin
        state <= acc_8;
      end
      if(io_flush) begin
        state <= 16'hffff;
      end
    end
  end


endmodule

module UsbOhciAxi4_Crc (
  input  wire          io_flush,
  input  wire          io_input_valid,
  input  wire [10:0]   io_input_payload,
  output wire [4:0]    io_result,
  output wire [4:0]    io_resultNext,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire       [4:0]    _zz_acc_1;
  wire       [4:0]    _zz_acc_2;
  wire       [4:0]    _zz_acc_3;
  wire       [4:0]    _zz_acc_4;
  wire       [4:0]    _zz_acc_5;
  wire       [4:0]    _zz_acc_6;
  wire       [4:0]    _zz_acc_7;
  wire       [4:0]    _zz_acc_8;
  wire       [4:0]    _zz_acc_9;
  wire       [4:0]    _zz_acc_10;
  wire       [4:0]    _zz_acc_11;
  reg        [4:0]    acc_11;
  reg        [4:0]    acc_10;
  reg        [4:0]    acc_9;
  reg        [4:0]    acc_8;
  reg        [4:0]    acc_7;
  reg        [4:0]    acc_6;
  reg        [4:0]    acc_5;
  reg        [4:0]    acc_4;
  reg        [4:0]    acc_3;
  reg        [4:0]    acc_2;
  reg        [4:0]    acc_1;
  reg        [4:0]    state;
  wire       [4:0]    acc;
  wire       [4:0]    stateXor;
  wire       [4:0]    accXor;

  assign _zz_acc_1 = (acc <<< 1);
  assign _zz_acc_2 = (acc_1 <<< 1);
  assign _zz_acc_3 = (acc_2 <<< 1);
  assign _zz_acc_4 = (acc_3 <<< 1);
  assign _zz_acc_5 = (acc_4 <<< 1);
  assign _zz_acc_6 = (acc_5 <<< 1);
  assign _zz_acc_7 = (acc_6 <<< 1);
  assign _zz_acc_8 = (acc_7 <<< 1);
  assign _zz_acc_9 = (acc_8 <<< 1);
  assign _zz_acc_10 = (acc_9 <<< 1);
  assign _zz_acc_11 = (acc_10 <<< 1);
  always @(*) begin
    acc_11 = acc_10;
    acc_11 = (_zz_acc_11 ^ ((io_input_payload[10] ^ acc_10[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_10 = acc_9;
    acc_10 = (_zz_acc_10 ^ ((io_input_payload[9] ^ acc_9[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_9 = acc_8;
    acc_9 = (_zz_acc_9 ^ ((io_input_payload[8] ^ acc_8[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_8 = acc_7;
    acc_8 = (_zz_acc_8 ^ ((io_input_payload[7] ^ acc_7[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_7 = acc_6;
    acc_7 = (_zz_acc_7 ^ ((io_input_payload[6] ^ acc_6[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_6 = acc_5;
    acc_6 = (_zz_acc_6 ^ ((io_input_payload[5] ^ acc_5[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_5 = acc_4;
    acc_5 = (_zz_acc_5 ^ ((io_input_payload[4] ^ acc_4[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_4 = acc_3;
    acc_4 = (_zz_acc_4 ^ ((io_input_payload[3] ^ acc_3[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_3 = acc_2;
    acc_3 = (_zz_acc_3 ^ ((io_input_payload[2] ^ acc_2[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_2 = acc_1;
    acc_2 = (_zz_acc_2 ^ ((io_input_payload[1] ^ acc_1[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_1 = acc;
    acc_1 = (_zz_acc_1 ^ ((io_input_payload[0] ^ acc[4]) ? 5'h05 : 5'h00));
  end

  assign acc = state;
  assign stateXor = (state ^ 5'h1f);
  assign accXor = (acc_11 ^ 5'h1f);
  assign io_result = {stateXor[0],{stateXor[1],{stateXor[2],{stateXor[3],stateXor[4]}}}};
  assign io_resultNext = {accXor[0],{accXor[1],{accXor[2],{accXor[3],accXor[4]}}}};
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 5'h1f;
    end else begin
      if(io_input_valid) begin
        state <= acc_11;
      end
      if(io_flush) begin
        state <= 5'h1f;
      end
    end
  end


endmodule

module UsbOhciAxi4_StreamFifo (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [31:0]   io_push_payload,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [31:0]   io_pop_payload,
  input  wire          io_flush,
  output wire [8:0]    io_occupancy,
  output wire [8:0]    io_availability,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  reg        [31:0]   logic_ram_spinal_port1;
  wire       [8:0]    _zz_logic_ptr_notPow2_counter;
  wire       [8:0]    _zz_logic_ptr_notPow2_counter_1;
  wire       [0:0]    _zz_logic_ptr_notPow2_counter_2;
  wire       [8:0]    _zz_logic_ptr_notPow2_counter_3;
  wire       [0:0]    _zz_logic_ptr_notPow2_counter_4;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [8:0]    logic_ptr_push;
  reg        [8:0]    logic_ptr_pop;
  wire       [8:0]    logic_ptr_occupancy;
  wire       [8:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1234;
  reg                 logic_ptr_wentUp;
  wire                when_Stream_l1269;
  wire                when_Stream_l1273;
  reg        [8:0]    logic_ptr_notPow2_counter;
  wire                io_push_fire;
  wire                io_pop_fire;
  wire                logic_push_onRam_write_valid;
  wire       [8:0]    logic_push_onRam_write_payload_address;
  wire       [31:0]   logic_push_onRam_write_payload_data;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [8:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [8:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [8:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l369;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [8:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [31:0]   logic_pop_sync_readPort_rsp;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [31:0]   logic_pop_sync_readArbitation_translated_payload;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [8:0]    logic_pop_sync_popReg;
  reg [31:0] logic_ram [0:271];

  assign _zz_logic_ptr_notPow2_counter = (logic_ptr_notPow2_counter + _zz_logic_ptr_notPow2_counter_1);
  assign _zz_logic_ptr_notPow2_counter_2 = io_push_fire;
  assign _zz_logic_ptr_notPow2_counter_1 = {8'd0, _zz_logic_ptr_notPow2_counter_2};
  assign _zz_logic_ptr_notPow2_counter_4 = io_pop_fire;
  assign _zz_logic_ptr_notPow2_counter_3 = {8'd0, _zz_logic_ptr_notPow2_counter_4};
  always @(posedge ctrl_clk) begin
    if(_zz_1) begin
      logic_ram[logic_push_onRam_write_payload_address] <= logic_push_onRam_write_payload_data;
    end
  end

  always @(posedge ctrl_clk) begin
    if(logic_pop_sync_readPort_cmd_valid) begin
      logic_ram_spinal_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_push_onRam_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign when_Stream_l1234 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_empty = ((logic_ptr_push == logic_ptr_pop) && (! logic_ptr_wentUp));
  assign when_Stream_l1269 = (logic_ptr_push == 9'h10f);
  assign when_Stream_l1273 = (logic_ptr_pop == 9'h10f);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign io_pop_fire = (io_pop_valid && io_pop_ready);
  assign logic_ptr_occupancy = logic_ptr_notPow2_counter;
  assign io_push_ready = (! logic_ptr_full);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push;
  assign logic_push_onRam_write_payload_data = io_push_payload;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop;
  assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
  assign logic_ptr_doPop = logic_pop_addressGen_fire;
  always @(*) begin
    logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
    if(when_Stream_l369) begin
      logic_pop_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l369 = (! logic_pop_sync_readArbitation_valid);
  assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
  assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
  assign logic_pop_sync_readPort_rsp = logic_ram_spinal_port1;
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_fire;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload = logic_pop_sync_readPort_rsp;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload = logic_pop_sync_readArbitation_translated_payload;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (9'h110 - logic_ptr_occupancy);
  assign logic_ptr_full = 1'b0;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      logic_ptr_push <= 9'h000;
      logic_ptr_pop <= 9'h000;
      logic_ptr_wentUp <= 1'b0;
      logic_ptr_notPow2_counter <= 9'h000;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 9'h000;
    end else begin
      if(when_Stream_l1234) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 9'h001);
        if(when_Stream_l1269) begin
          logic_ptr_push <= 9'h000;
        end
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 9'h001);
        if(when_Stream_l1273) begin
          logic_ptr_pop <= 9'h000;
        end
      end
      if(io_flush) begin
        logic_ptr_push <= 9'h000;
        logic_ptr_pop <= 9'h000;
      end
      logic_ptr_notPow2_counter <= (_zz_logic_ptr_notPow2_counter - _zz_logic_ptr_notPow2_counter_3);
      if(io_flush) begin
        logic_ptr_notPow2_counter <= 9'h000;
      end
      if(logic_pop_addressGen_ready) begin
        logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
      end
      if(io_flush) begin
        logic_pop_addressGen_rValid <= 1'b0;
      end
      if(logic_pop_sync_readArbitation_fire) begin
        logic_pop_sync_popReg <= logic_ptr_pop;
      end
      if(io_flush) begin
        logic_pop_sync_popReg <= 9'h000;
      end
    end
  end

  always @(posedge ctrl_clk) begin
    if(logic_pop_addressGen_ready) begin
      logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
    end
  end


endmodule

//UsbOhciAxi4_StreamFifo_2 replaced by UsbOhciAxi4_StreamFifo_1

module UsbOhciAxi4_StreamFifo_1 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  input  wire          io_flush,
  output wire [5:0]    io_occupancy,
  output wire [5:0]    io_availability,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [5:0]    logic_ptr_push;
  reg        [5:0]    logic_ptr_pop;
  wire       [5:0]    logic_ptr_occupancy;
  wire       [5:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1234;
  reg                 logic_ptr_wentUp;
  wire                io_push_fire;
  wire                logic_push_onRam_write_valid;
  wire       [4:0]    logic_push_onRam_write_payload_address;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [4:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [4:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [4:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l369;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [4:0]    logic_pop_sync_readPort_cmd_payload;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [5:0]    logic_pop_sync_popReg;

  assign when_Stream_l1234 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 6'h20) == 6'h00);
  assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
  assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
  assign io_push_ready = (! logic_ptr_full);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push[4:0];
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop[4:0];
  assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
  assign logic_ptr_doPop = logic_pop_addressGen_fire;
  always @(*) begin
    logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
    if(when_Stream_l369) begin
      logic_pop_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l369 = (! logic_pop_sync_readArbitation_valid);
  assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
  assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_fire;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (6'h20 - logic_ptr_occupancy);
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      logic_ptr_push <= 6'h00;
      logic_ptr_pop <= 6'h00;
      logic_ptr_wentUp <= 1'b0;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 6'h00;
    end else begin
      if(when_Stream_l1234) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 6'h01);
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 6'h01);
      end
      if(io_flush) begin
        logic_ptr_push <= 6'h00;
        logic_ptr_pop <= 6'h00;
      end
      if(logic_pop_addressGen_ready) begin
        logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
      end
      if(io_flush) begin
        logic_pop_addressGen_rValid <= 1'b0;
      end
      if(logic_pop_sync_readArbitation_fire) begin
        logic_pop_sync_popReg <= logic_ptr_pop;
      end
      if(io_flush) begin
        logic_pop_sync_popReg <= 6'h00;
      end
    end
  end

  always @(posedge ctrl_clk) begin
    if(logic_pop_addressGen_ready) begin
      logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
    end
  end


endmodule

//UsbOhciAxi4_BufferCC_30 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_29 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_32 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_31 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_34 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_33 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_36 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_35 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_37 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_38 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_39 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_41 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_40 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_43 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_42 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_45 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_44 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_47 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_46 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_48 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_49 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_50 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_52 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_51 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_54 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_53 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_56 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_55 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_58 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_57 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_59 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_60 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_61 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_63 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_62 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_65 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_64 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_67 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_66 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_69 replaced by UsbOhciAxi4_BufferCC_79

//UsbOhciAxi4_BufferCC_68 replaced by UsbOhciAxi4_BufferCC_77

//UsbOhciAxi4_BufferCC_70 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_71 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_72 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_73 replaced by UsbOhciAxi4_BufferCC_76

//UsbOhciAxi4_BufferCC_74 replaced by UsbOhciAxi4_BufferCC_76

module UsbOhciAxi4_BufferCC_76 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          ctrl_clk,
  input  wire          phy_reset_syncronized
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk or posedge phy_reset_syncronized) begin
    if(phy_reset_syncronized) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module UsbOhciAxi4_BufferCC_75 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          ctrl_clk,
  input  wire          phy_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk or posedge phy_reset) begin
    if(phy_reset) begin
      buffers_0 <= 1'b1;
      buffers_1 <= 1'b1;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module UsbOhciAxi4_BufferCC_79 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          phy_clk,
  input  wire          ctrl_reset_syncronized
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge phy_clk or posedge ctrl_reset_syncronized) begin
    if(ctrl_reset_syncronized) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module UsbOhciAxi4_BufferCC_78 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          phy_clk,
  input  wire          ctrl_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge phy_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      buffers_0 <= 1'b1;
      buffers_1 <= 1'b1;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module UsbOhciAxi4_BufferCC_77 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule
