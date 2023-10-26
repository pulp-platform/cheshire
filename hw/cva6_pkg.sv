package cva6_pkg; 

  ////////////
  //  CVA6  //
  ////////////

  // CVA6 imposes an ID width of 4, but only 6 of 16 IDs are ever used
  localparam int unsigned Cva6IdWidth = 4;
  localparam int unsigned Cva6IdsUsed = 6;
  typedef logic [Cva6IdWidth-1:0] cva6_id_t;
  typedef int unsigned cva6_id_map_t [Cva6IdsUsed-1:0][0:1];

  // Symbols for used CVA6 IDs
  typedef enum cva6_id_t {
    Cva6IdBypMmu    = 'b1000,
    Cva6IdBypLoad   = 'b1001,
    Cva6IdBypStore  = 'b1010,
    Cva6IdBypAmo    = 'b1011,
    Cva6IdICache    = 'b0000,
    Cva6IdDCache    = 'b1100
  } cva6_id_e;

endpackage