// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/RAM128X1D.v,v 1.5 2006/06/23 21:24:41 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Static Dual Port Synchronous RAM 128-Deep by 1-Wide
// /___/   /\     Filename : RAM128X1D.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:34 PST 2004
//  \___\/\___\
//
// Revision:
//    02/07/05 - Initial version.
//    06/22/06 - Change initial to hex (CR 233085).
// End Revision

`timescale  1 ps / 1 ps


module RAM128X1D (DPO, SPO, A, D, DPRA, WCLK, WE);

    parameter INIT = 128'h0;

    output DPO, SPO;

    input  [6:0] A;
    input  [6:0] DPRA;
    input  D;
    input  WCLK;
    input  WE;

    reg [127:0] mem;


    assign SPO = mem[A];
    assign DPO = mem[DPRA];


    initial 
         mem = INIT;

    always @(posedge WCLK) 
	if (WE == 1'b1)
	    mem[A] <= #100 D;


endmodule

