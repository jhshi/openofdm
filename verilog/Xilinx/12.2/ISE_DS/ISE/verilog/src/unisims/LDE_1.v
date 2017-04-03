// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/LDE_1.v,v 1.12 2006/04/10 20:46:00 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Transparent Data Latch with Gate Enable and Inverted Gate
// /___/   /\     Filename : LDE_1.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:52 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Seperate GSR from clock block.
//    08/09/05 - Add GSR to main block (CR 215196).
//    03/31/06 - Add specify block for 100ps delay. (CR 228298)
// End Revision

`timescale  1 ps / 1 ps


module LDE_1 (Q, D, G, GE);

    parameter INIT = 1'b0;

    output Q;
    wire Q;

    input  D, G, GE;

    tri0 GSR = glbl.GSR;


    reg q_out;
    
    initial q_out = INIT;
    
    assign Q = q_out;
    
	always @(D or G or GE or GSR)
         if (GSR)
          q_out <= INIT;
         else
	    if (!G && GE)
		q_out <= D;
    
    specify
	if (!G && GE)
	    (D +=> Q) = (100, 100);
	if (GE)
	    (negedge G => (Q +: D)) = (100, 100);
	if (!G)
	    (posedge GE => (Q +: D)) = (100, 100);
    endspecify
endmodule
