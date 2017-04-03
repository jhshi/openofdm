// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAM16X4S.v,v 1.8 2005/03/14 22:32:58 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Static Synchronous RAM 16-Deep by 4-Wide
// /___/   /\     Filename : RAM16X4S.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:33 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Remove for-loop in initial block;
// End Revision

`timescale  1 ps / 1 ps


module RAM16X4S (O0, O1, O2, O3, A0, A1, A2, A3, D0, D1, D2, D3, WCLK, WE);

    parameter INIT_00 = 16'h0000;
    parameter INIT_01 = 16'h0000;
    parameter INIT_02 = 16'h0000;
    parameter INIT_03 = 16'h0000;

    output O0, O1, O2, O3;

    input  A0, A1, A2, A3, D0, D1, D2, D3, WCLK, WE;

    reg  [15:0] mem0;
    reg  [15:0] mem1;
    reg  [15:0] mem2;
    reg  [15:0] mem3;

    wire [3:0] adr;

    assign adr = {A3, A2, A1, A0};
    assign O0 = mem0[adr];
    assign O1 = mem1[adr];
    assign O2 = mem2[adr];
    assign O3 = mem3[adr];

    initial  begin
        mem0 = INIT_00;
        mem1 = INIT_01;
        mem2 = INIT_02;
        mem3 = INIT_03;
    end

    always @(posedge WCLK) 
        if (WE == 1'b1) begin
            mem0[adr] <= #100 D0;
            mem1[adr] <= #100 D1;
            mem2[adr] <= #100 D2;
            mem3[adr] <= #100 D3;
        end

endmodule

