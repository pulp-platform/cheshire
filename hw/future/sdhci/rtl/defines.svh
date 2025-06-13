`ifndef USER_SDHCI_DEFINES_SVH_
`define USER_SDHCI_DEFINES_SVH_

`define writable_reg_t(size) \
  struct packed {            \
    logic size d;            \
    logic de;                \
  }

`define ila(__name, __signal)  \
  (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [$bits(__signal)-1:0] __name; \
  assign __name = __signal;
`endif
