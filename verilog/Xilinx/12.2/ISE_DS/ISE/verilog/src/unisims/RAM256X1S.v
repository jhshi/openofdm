// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/RAM256X1S.v,v 1.5 2006/06/23 21:24:41 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Static Synchronous RAM 256-Deep by 1-Wide
// /___/   /\     Filename : RAM256X1S.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:32 PST 2004
//  \___\/\___\
//
// Revision:
//    02/07/05 - Initial version.
//    06/22/06 - Change initial to hex (CR 233085).
// End Revision

`timescale  1 ps / 1 ps


module RAM256X1S (O, A, D, WCLK, WE);

    parameter INIT = 256'h0;

    output O;

    input  [7:0] A;
    input  D;
    input  WCLK;
    input  WE;

    reg  [255:0] mem;

    initial
         mem = INIT;

    assign O = mem[A];

    always @(posedge WCLK) 
	if (WE == 1'b1)
	    mem[A] <= #100 D;


endmodule

