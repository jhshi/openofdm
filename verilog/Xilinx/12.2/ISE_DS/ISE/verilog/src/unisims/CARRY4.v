// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/CARRY4.v,v 1.5 2007/06/01 00:24:45 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Fast Carry Logic with Look Ahead 
// /___/   /\     Filename : CARRY4.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:55 PST 2004
//  \___\/\___\
//
// Revision:
//    04/11/05 - Initial version.
//    05/06/05 - Unused CYINT or CI pin need grounded instead of open (CR207752)
//    05/31/05 - Change pin order, remove connection check for CYINIT and CI.
//    05/30/07 - Change timescale to 1 ps / 1ps.
// End Revision

`timescale  1 ps / 1 ps


module CARRY4 (CO, O, CI, CYINIT, DI, S);

    output [3:0] CO;
    output [3:0] O;
    input        CI;
    input        CYINIT;
    input  [3:0] DI;
    input  [3:0] S;

    wire ci_or_cyinit;

//    initial
//       ci_or_cyinit = 0;

    assign O = S ^ {CO[2:0], ci_or_cyinit};
    assign CO[0] = S[0] ? ci_or_cyinit : DI[0];
    assign CO[1] = S[1] ? CO[0] : DI[1];
    assign CO[2] = S[2] ? CO[1] : DI[2];
    assign CO[3] = S[3] ? CO[2] : DI[3];
    assign ci_or_cyinit = CYINIT | CI;

//    always @(CYINIT or CI)
//      if (CYINIT === 1'bz || CYINIT === 1'bx) begin
//           $display("Error: CARRY4 instance, %m, detects CYINIT unconnected. Only one of CI and CYINIT inputs can be used and other one need be grounded.");
//           $finish;
//     end
//      else if (CI=== 1'bz || CI=== 1'bx) begin
//           $display("Error: CARRY4 instance, %m, detects CI unconnected. Only one of CI and CYINIT inputs can be used and other one need be grounded.");
//           $finish;
//     end
//      else 
//           ci_or_cyinit = CYINIT | CI;

endmodule

