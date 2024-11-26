// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Hauser <fhauser@student.ethz.ch>
//
/// Changes inside this package need to be confirmed with a make hw-all, 
/// because the package parameter values need to update the configuration inside newusb_regs.hjson.

package new_usb_ohci_pkg;
  
  typedef enum int unsigned {
    OFF = 0,
    GLOBAL = 1,
    INDIVIDUAL = 2
  } state_activate;

  typedef enum int unsigned {
    DISABLE = 0,
    ENABLE = 1
  } state_permit;

  typedef enum logic [1:0] {
    BULK = 2'b00,
    CONTROL = 2'b01,
    ISOCHRONOUS = 2'b10,
    INTERRUPT = 2'11
  } channel;

  typedef enum logic [1:0] {
    ED = 2'b00,
    GENTD = 2'b01,
    ISOTD = 2'b10
  } store_type;

  typedef struct packed {
    struct packed {
      logic [27:0]  address;
    } nextTD;
  } gen_transfer_descriptor;

  typedef struct packed {
    struct packed {
      logic [27:0]  address;
    } nextTD;
  } iso_transfer_descriptor;

  typedef struct packed {
    struct packed {
      logic [10:0]  MPS; // 26:16
      logic         F; // 15
      logic         K; // 14
      logic         S; // 13
      logic [12:11] D; // 12:11
      logic [10:7]  EN; // 10:7
      logic [6:0]   FA; // 6:0
    } status;
    struct packed {
      logic [27:0]  address; // 31:4
      logic         C; // 1
      logic         H; // 0
    } headTD;
    struct packed {
      logic [27:0]  address; // 31:4
    } nextED;
  } endpoint_descriptor;
  
  localparam int unsigned   NumPhyPorts          = 2; // OHCI supports between 1-15 ports
  localparam state_activate OverProtect          = OFF; // no overcurrent protection implemented yet
  localparam state_activate PowerSwitching       = OFF; // no power switching implemented yet
  localparam state_permit   InterruptRouting     = DISABLE; // no system management interrupt (SMI) implemented yet
  localparam state_permit   RemoteWakeup         = DISABLE; // no remote wakeup implemented yet
  localparam state_permit   OwnershipChange      = DISABLE; // no ownership change implemented yet
  localparam int unsigned   FifoDepthPort        = 1024; // test value
  localparam int unsigned   DmaLength            = 128; // test value
  
  // Todo: Maybe Crc16 input Byte size parameter with selectable parallel/pipelined processing, lookup table?

endpackage
