package c910_pkg; 

  ////////////
  //  C910  //
  ////////////

  // 24 MByte in 8 byte words
  localparam NumWords = (24 * 1024 * 1024) / 8;
  localparam NrMasters = 1; // c910
  localparam AxiAddrWidth = 40;
  localparam AxiDataWidth = 128;
  localparam AxiIdWidthMaster = 8;
  localparam AxiIdWidthSlaves = AxiIdWidthMaster + $clog2(NrMasters); // 5
  localparam AxiUserWidth = 1;

endpackage