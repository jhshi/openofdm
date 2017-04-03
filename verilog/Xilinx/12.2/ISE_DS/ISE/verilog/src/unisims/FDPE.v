// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/FDPE.v,v 1.13 2006/02/13 22:07:02 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  D Flip-Flop with Asynchronous Preset and Clock Enable
// /___/   /\     Filename : FDPE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:17 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Seperate GSR from clock block.
//    08/09/05 - Add PRE to GSR block (CR 215196).
//    10/20/05 - Add set & reset check to main  block. (CR219794)
//    2/07/06 - Remove set & reset from main block and add specify block (CR225119)
//    2/10/06 - Change Q from reg to wire (CR 225613)
// End Revision

`timescale  1 ps / 1 ps


module FDPE (Q, C, CE, D, PRE);

    parameter INIT = 1'b1;

    output Q;

    input  C, CE, D, PRE;

    wire Q;
    reg q_out;
    tri0 GSR = glbl.GSR;

    initial q_out = INIT;


    assign Q = q_out;

    always @(GSR or PRE)
      if (GSR)
            assign q_out = INIT;
      else if (PRE)
            assign q_out = 1;
      else
            deassign q_out;

    always @(posedge C )
               if (CE)
		    q_out <=  D;

    specify
        (posedge PRE => (Q +: 1'b1)) = (0, 0);
        if (!PRE && CE)
            (posedge C => (Q +: D)) = (100, 100);
    endspecify


endmodule
