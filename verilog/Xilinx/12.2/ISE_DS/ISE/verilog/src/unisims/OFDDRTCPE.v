// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/OFDDRTCPE.v,v 1.4 2005/03/14 22:32:58 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Dual Data Rate Output D Flip-Flop with 3-State Output, Asynchronous Clear and Preset and Clock Enable
// /___/   /\     Filename : OFDDRTCPE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:30 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  1 ps / 1 ps

module OFDDRTCPE (O, C0, C1, CE, CLR, D0, D1, PRE, T);

    output O;

    input  C0, C1, CE, CLR, D0, D1, PRE, T;

    wire   q_out;

    FDDRCPE F0 (.C0(C0),
	.C1(C1),
	.CE(CE),
	.CLR(CLR),
	.D0(D0),
	.D1(D1),
	.PRE(PRE),
	.Q(q_out));
    defparam F0.INIT = 1'b0;

    OBUFT O1 (.I(q_out),
	.T(T),
	.O(O));

endmodule
