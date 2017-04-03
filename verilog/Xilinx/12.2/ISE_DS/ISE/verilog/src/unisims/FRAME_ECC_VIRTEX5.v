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
// /___/   /\     Filename : FRAME_ECC_VIRTEX5.v
// \   \  /  \    Timestamp : Thu Jul 21 13:42:30 PDT 2005
//  \___\/\___\
//
// Revision:
//    07/21/05 - Initial version.
// End Revision

`timescale 1 ps / 1 ps 

module FRAME_ECC_VIRTEX5 (
	CRCERROR,
	ECCERROR,
	SYNDROME,
	SYNDROMEVALID
);

output CRCERROR;
output ECCERROR;
output SYNDROMEVALID;
output [11:0] SYNDROME;

specify
	specparam PATHPULSE$ = 0;
endspecify

endmodule

