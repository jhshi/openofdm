// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/LDP.v,v 1.12 2006/04/10 20:46:00 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Transparent Data Latch with Asynchronous Preset
// /___/   /\     Filename : LDP.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:53 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Seperate GSR from clock block.
//    08/09/05 - Add GSR to main block (CR 215196).
//    03/31/06 - Add specify block for 100ps delay. (CR 228298)
// End Revision

`timescale  1 ps / 1 ps


module LDP (Q, D, G, PRE);

    parameter INIT = 1'b1;

    output Q;
    wire Q;

    input  D, G, PRE;

    tri0 GSR = glbl.GSR;


    reg q_out;
    
    initial q_out = INIT;
    
    assign Q = q_out;
    
	always @(PRE or D or G or GSR)
         if (GSR )
            q_out <= INIT;
         else
	    if (PRE)
		q_out <= 1;
	    else if (G)
		q_out <= D;
    
    specify
	if (!PRE && G)
	    (D +=> Q) = (100, 100);
	if (!PRE)
	    (posedge G => (Q +: D)) = (100, 100);
	(posedge PRE => (Q +: 1'b1)) = (0, 0);
    endspecify
endmodule
