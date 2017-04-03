// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/CAPTURE_SPARTAN3.v,v 1.7 2007/05/23 21:43:33 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Register State Capture for Bitstream Readback for SPARTAN3
// /___/   /\     Filename : CAPTURE_SPARTAN3.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:15 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    07/23/05 - Added ONESHOT to all CAPUTURE comps; CR # 212645
//    01/19/06 - made ONESHOT false; CR # 220151
//    05/23/07 - Changed timescale to 1 ps / 1 ps.

`timescale  1 ps / 1 ps


module CAPTURE_SPARTAN3 (CAP, CLK);

    input  CAP, CLK;

    parameter ONESHOT = "FALSE";

endmodule

