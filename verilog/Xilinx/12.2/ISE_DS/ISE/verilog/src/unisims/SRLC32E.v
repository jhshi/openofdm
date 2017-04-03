// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/SRLC32E.v,v 1.3 2010/01/06 00:48:06 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  32-Bit Shift Register Look-Up-Table with Carry and Clock Enable
// /___/   /\     Filename : SRLC32E.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:40 PST 2004
//  \___\/\___\
//
// Revision:
//    03/15/05 - Initial version.
// End Revision

`timescale  1 ps / 1 ps


module SRLC32E (Q, Q31, A, CE, CLK, D);

    parameter INIT = 32'h00000000;

    output Q;
    output Q31;

    input  [4:0] A;
    input  CE, CLK, D;

    reg  [31:0] data;


    assign  Q = data[A];
    assign  Q31 = data[31];

    initial
    begin
          assign  data = INIT;
          while (CLK === 1'b1 || CLK===1'bX) 
            #10; 
          deassign data;
    end

    always @(posedge CLK)
	if (CE == 1'b1) 
	    data <= #100 {data[30:0], D};


endmodule

