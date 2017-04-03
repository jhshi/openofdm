///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Register State Capture for Bitstream Readback for SPARTAN3A
// /___/   /\     Filename : CAPTURE_SPARTAN3A.v
// \   \  /  \    Timestamp : Fri Jul  1 14:45:00 PDT 2005
//  \___\/\___\
//
// Revision:
//    07/01/05 - Initial version.
// End Revision

`timescale  1 ps / 1 ps


module CAPTURE_SPARTAN3A (CAP, CLK);

    input  CAP, CLK;
    
    parameter ONESHOT = "TRUE";

endmodule
