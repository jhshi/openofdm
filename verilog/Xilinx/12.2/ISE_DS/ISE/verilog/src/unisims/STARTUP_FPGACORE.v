// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/STARTUP_FPGACORE.v,v 1.5 2007/05/23 21:43:44 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  User Interface to Global Clock, Reset and 3-State Controls for FPGACORE
// /___/   /\     Filename : STARTUP_FPGACORE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:41 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.

`timescale  1 ps / 1 ps


module STARTUP_FPGACORE (CLK, GSR);

    input  CLK, GSR;

    tri0 GSR;

	assign glbl.GSR = GSR;

endmodule

