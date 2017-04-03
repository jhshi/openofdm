///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /
// /___/   /\     Filename : USR_ACCESS_VIRTEX5.v
// \   \  /  \    Timestamp : Thu Jul 21 13:42:30 PDT 2005
//  \___\/\___\
//
// Revision:
//    07/21/05 - Initial version.
// End Revision

`timescale 1 ps / 1 ps 

module USR_ACCESS_VIRTEX5 (
        CFGCLK,
	DATA,
	DATAVALID
);

output CFGCLK;
output DATAVALID;
output [31:0] DATA;

specify
	specparam PATHPULSE$ = 0;
endspecify

endmodule
