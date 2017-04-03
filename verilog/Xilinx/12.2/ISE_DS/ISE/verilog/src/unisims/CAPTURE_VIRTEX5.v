///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Register State Capture for Bitstream Readback for VIRTEX5
// /___/   /\     Filename : CAPTURE_VIRTEX5.v
// \   \  /  \    Timestamp : Thu Jul 21 13:42:30 PDT 2005
//  \___\/\___\
//
// Revision:
//    07/21/05 - Initial version.
// End Revision

`timescale 1 ps / 1 ps 

module CAPTURE_VIRTEX5 (
	CAP,
	CLK
);

input CAP;
input CLK;

parameter ONESHOT = "TRUE";

specify
	specparam PATHPULSE$ = 0;
endspecify

endmodule
