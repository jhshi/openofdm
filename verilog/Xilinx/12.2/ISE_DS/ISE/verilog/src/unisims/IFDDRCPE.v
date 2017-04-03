// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IFDDRCPE.v,v 1.4 2005/03/14 22:32:53 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Dual Data Rate Input D Flip-Flop with Asynchronous Clear and Preset and Clock Enable
// /___/   /\     Filename : IFDDRCPE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:37 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  1 ps / 1 ps

module IFDDRCPE (Q0, Q1, C0, C1, CE, CLR, D, PRE);

    output Q0, Q1;

    input  C0, C1, CE, CLR, D, PRE;

    wire   d_in;

    IBUF I1 (.I(D),
	.O(d_in));

    FDCPE F0 (.C(C0),
	.CE(CE),
	.CLR(CLR),
	.D(d_in),
	.PRE(PRE),
	.Q(Q0));
    defparam F0.INIT = 1'b0;

    FDCPE F1 (.C(C1),
	.CE(CE),
	.CLR(CLR),
	.D(d_in),
	.PRE(PRE),
	.Q(Q1));
    defparam F1.INIT = 1'b0;

endmodule
