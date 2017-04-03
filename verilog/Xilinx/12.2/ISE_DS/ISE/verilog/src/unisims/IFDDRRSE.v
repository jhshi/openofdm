// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IFDDRRSE.v,v 1.4 2005/03/14 22:32:53 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Dual Data Rate Input D Flip-Flop with Synchronous Reset and SET and Clock Enable
// /___/   /\     Filename : IFDDRRSE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:37 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  1 ps / 1 ps

module IFDDRRSE (Q0, Q1, C0, C1, CE, D, R, S);

    output Q0, Q1;

    input  C0, C1, CE, D, R, S;

    wire   d_in;

    IBUF I1 (.I(D),
	.O(d_in));

    FDRSE F0 (.C(C0),
	.CE(CE),
	.R(R),
	.D(d_in),
	.S(S),
	.Q(Q0));
    defparam F0.INIT = 1'b0;

    FDRSE F1 (.C(C1),
	.CE(CE),
	.R(R),
	.D(d_in),
	.S(S),
	.Q(Q1));
    defparam F1.INIT = "0";

endmodule
