// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/FDDRCPE.v,v 1.16 2007/06/19 20:02:43 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Dual Data Rate D Flip-Flop with Asynchronous Clear and Preset and Clock Enable
// /___/   /\     Filename : FDDRCPE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:16 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Seperate GSR from clock block.
//    05/06/05 - Remove internal input data strobe and add to the output. (CR207678)
//    10/20/05 - Add set & reset check to main  block. (CR219794)
//    10/28/05 - combine strobe block and data block. (CR220298).
//    2/07/06 - Remove set & reset from main block and add specify block (CR225119)
//    06/19/07 - Change INIT to 1 bit (CR441955)
// End Revision

`timescale  1 ps / 1 ps


module FDDRCPE (Q, C0, C1, CE, CLR, D0, D1, PRE);

    parameter INIT = 1'b0;

    output Q;

    input  C0, C1, CE, CLR, D0, D1, PRE;

    wire Q;
    reg    q_out;
    tri0 GSR = glbl.GSR;

    reg q0_out, q1_out;
    reg C0_tmp, C1_tmp;

    initial begin
       q_out = INIT;
       q0_out = INIT;
       q1_out = INIT;
       C0_tmp = 0;
       C1_tmp = 0;
    end

   assign Q = q_out;

   always @(GSR or CLR or PRE)
      if (GSR) begin
            assign q_out = INIT;
            assign q0_out = INIT;
            assign q1_out = INIT;
            assign C0_tmp = 0;
            assign C1_tmp = 0;
       end
      else if (CLR) begin
            assign q_out = 0;
            assign q0_out = 0;
            assign q1_out = 0;
            assign C0_tmp = 0;
            assign C1_tmp = 0;
       end
      else if (PRE) begin
            assign q_out = 1;
            assign q0_out = 1;
            assign q1_out = 1;
            assign C0_tmp = 0;
            assign C1_tmp = 0;
      end
      else begin
            deassign q_out;
            deassign q0_out;
            deassign q1_out;
            deassign C0_tmp;
            deassign C1_tmp;
      end

    always @(posedge C0) 
     if ( CE) begin
      C0_tmp <=  1;
      C0_tmp <= #100 0;
      q0_out <=  D0;
    end

    always @(posedge C1)
     if ( CE ) begin
      C1_tmp <=  1;
      C1_tmp <= #100 0;
      q1_out <=  D1;
    end

    always @(posedge C0_tmp or posedge C1_tmp )
            if (C1_tmp)
               q_out =  q1_out;
            else 
               q_out =  q0_out;

    specify
        (posedge CLR => (Q +: 1'b0)) = (0, 0);
        if (!CLR)
            (posedge PRE => (Q +: 1'b1)) = (0, 0);
        if (!CLR && !PRE && CE)
            (posedge C0 => (Q +: D0)) = (100, 100);
        if (!CLR && !PRE && CE)
            (posedge C1 => (Q +: D1)) = (100, 100);
    endspecify

endmodule
