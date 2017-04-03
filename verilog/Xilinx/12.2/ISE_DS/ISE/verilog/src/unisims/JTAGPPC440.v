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
// /___/   /\     Filename : JTAGPPC440.v
// \   \  /  \    Timestamp : Wed Aug 17 16:23:43 PDT 2005
//  \___\/\___\
//
// Revision:
//    08/17/05 - Initial version.
// End Revision

`timescale 1 ps / 1 ps 

module JTAGPPC440 (
        TCK,
        TDIPPC,
        TMS,
        TDOPPC
);

output TCK;
output TDIPPC;
output TMS;

input TDOPPC;

specify
	specparam PATHPULSE$ = 0;
endspecify

endmodule
