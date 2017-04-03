// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/ROM64X1.v,v 1.9 2007/05/23 21:43:44 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  64-Deep by 1-Wide ROM
// /___/   /\     Filename : ROM64X1.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:40 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Remove for-loop in initial block;
//    05/23/07 - Changed timescale to 1 ps / 1 ps.

`timescale  1 ps / 1 ps


module ROM64X1 (O, A0, A1, A2, A3, A4, A5);

    parameter INIT = 64'h0000000000000000;

    output O;

    input  A0, A1, A2, A3, A4, A5;

    reg [63:0] mem;

    initial 
            mem = INIT;

    assign O = mem[{A5, A4, A3, A2, A1, A0}];


endmodule

