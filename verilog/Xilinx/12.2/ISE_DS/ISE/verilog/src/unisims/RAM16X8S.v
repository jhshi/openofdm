// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAM16X8S.v,v 1.9 2005/05/23 22:42:09 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Static Synchronous RAM 16-Deep by 8-Wide
// /___/   /\     Filename : RAM16X8S.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:33 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Remove for-loop in initial block;
//    05/23/05 - Change initial order (BugTrack#194).
// End Revision

`timescale  1 ps / 1 ps


module RAM16X8S (O, A0, A1, A2, A3, D, WCLK, WE);

    parameter INIT_00 = 16'h0000;
    parameter INIT_01 = 16'h0000;
    parameter INIT_02 = 16'h0000;
    parameter INIT_03 = 16'h0000;
    parameter INIT_04 = 16'h0000;
    parameter INIT_05 = 16'h0000;
    parameter INIT_06 = 16'h0000;
    parameter INIT_07 = 16'h0000;

    output [7:0] O;

    input  A0, A1, A2, A3, WCLK, WE;
    input [7:0] D;


    reg   [7:0] mem [15:0];
    integer i;
    reg test;

    wire [3:0] adr;

    assign adr = {A3, A2, A1, A0};
    assign O = mem[adr];

    initial  
        for (i = 0; i < 16; i=i+1) 
            mem[i] = {INIT_07[i], INIT_06[i], INIT_05[i], INIT_04[i], INIT_03[i], INIT_02[i],
                      INIT_01[i], INIT_00[i]};

    always @(posedge WCLK) 
        if (WE == 1'b1) 
            mem[adr] <= #100 D;

endmodule

