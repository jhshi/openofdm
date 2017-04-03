///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  User Interface to Global Clock, Reset and 3-State Controls for SPARTAN3A
// /___/   /\     Filename : STARTUP_SPARTAN3A.v
// \   \  /  \    Timestamp : Fri Jul  1 14:45:00 PDT 2005
//  \___\/\___\
//
// Revision:
//    07/01/05 - Initial version.
// End Revision

`timescale  1 ps / 1 ps


module STARTUP_SPARTAN3A (CLK, GSR, GTS);

    input  CLK, GSR, GTS;

    tri0 GSR, GTS;

	assign glbl.GSR = GSR;
	assign glbl.GTS = GTS;

endmodule
