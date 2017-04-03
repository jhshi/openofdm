// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/JTAGPPC.v,v 1.6 2007/05/23 21:43:39 patrickp Exp $
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
// /___/   /\     Filename : JTAGPPC.v
// \   \  /  \    Timestamp : Thu Jun 24 16:42:51 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.

`timescale  1 ps / 1 ps

module JTAGPPC (TCK, TDIPPC, TMS, TDOPPC, TDOTSPPC);

output TCK;
output TDIPPC;
output TMS;

input TDOPPC;
input TDOTSPPC;

	assign TCK = 1'b1;
	assign TDIPPC = 1'b1;
	assign TMS = 1'b1;
endmodule
