// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAM32X8S.v,v 1.9 2005/05/23 22:42:09 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Static Synchronous RAM 32-Deep by 8-Wide
// /___/   /\     Filename : RAM32X8S.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:34 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Remove for-loop in initial block;
//    05/23/05 - Change initial order (BugTrack#194).
// End Revision

`timescale  1 ps / 1 ps


module RAM32X8S (O, A0, A1, A2, A3, A4, D, WCLK, WE);

    parameter INIT_00 = 32'h00000000;
    parameter INIT_01 = 32'h00000000;
    parameter INIT_02 = 32'h00000000;
    parameter INIT_03 = 32'h00000000;
    parameter INIT_04 = 32'h00000000;
    parameter INIT_05 = 32'h00000000;
    parameter INIT_06 = 32'h00000000;
    parameter INIT_07 = 32'h00000000;

    output [7:0] O;

    input  A0, A1, A2, A3, A4, WCLK, WE;
    input [7:0] D;

    reg   [7:0] mem [31:0];
    integer i;

    wire [4:0] adr;

    assign adr = {A4, A3, A2, A1, A0};
    assign O = mem[adr];

    initial 
        for (i = 0; i < 32; i=i+1)
            mem[i] = {INIT_07[i], INIT_06[i], INIT_05[i], INIT_04[i], INIT_03[i], INIT_02[i],
                      INIT_01[i], INIT_00[i]};

    always @(posedge WCLK) 
        if (WE == 1'b1) 
            mem[adr] <= #100 D;

endmodule

