// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAM64X2S.v,v 1.8 2005/03/14 22:32:58 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Static Synchronous RAM 64-Deep by 2-Wide
// /___/   /\     Filename : RAM64X2S.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:34 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Remove for-loop in initial block;
// End Revision

`timescale  1 ps / 1 ps


module RAM64X2S (O0, O1, A0, A1, A2, A3, A4, A5, D0, D1, WCLK, WE);

    parameter INIT_00 = 64'h0000000000000000;
    parameter INIT_01 = 64'h0000000000000000;

    output O0, O1;

    input  A0, A1, A2, A3, A4, A5, D0, D1, WCLK, WE;

    reg  [63:0] mem1;
    reg  [63:0] mem2;

    wire [5:0] adr;

    assign adr = {A5, A4, A3, A2, A1, A0};
    assign O0 = mem1[adr];
    assign O1 = mem2[adr];

    initial  begin
        mem1 = INIT_00;
        mem2 = INIT_01;
    end

    always @(posedge WCLK) 
        if (WE == 1'b1) begin
            mem1[adr] <= #100 D0;
            mem2[adr] <= #100 D1;
        end

endmodule

