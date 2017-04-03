// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/MULT18X18S.v,v 1.10 2006/01/11 08:27:07 fphillip Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  18X18 Signed Registered Multiplier
// /___/   /\     Filename : MULT18X18S.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:54 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    01/10/06 - Reversed from I.25 to H.42 model -- CR 223831
// End Revision

`timescale  1 ps / 1 ps


module MULT18X18S (P, A, B, C, CE, R);

    output [35:0] P;

    input  [17:0] A;
    input  [17:0] B;
    input  C, CE, R;

    wire [35:0] a_in, b_in;
    wire [35:0] p_in;
    reg [35:0] p_out;

    wire p0_out, p1_out, p2_out, p3_out, p4_out, p5_out, p6_out, p7_out, p8_out, p9_out, p10_out, p11_out, p12_out, p13_out, p14_out, p15_out, p16_out, p17_out, p18_out, p19_out, p20_out, p21_out, p22_out, p23_out, p24_out, p25_out, p26_out, p27_out, p28_out, p29_out, p30_out, p31_out, p32_out, p33_out, p34_out, p35_out;

    tri0 GSR = glbl.GSR;

    buf A0 (a_in[0], A[0]);
    buf A1 (a_in[1], A[1]);
    buf A2 (a_in[2], A[2]);
    buf A3 (a_in[3], A[3]);
    buf A4 (a_in[4], A[4]);
    buf A5 (a_in[5], A[5]);
    buf A6 (a_in[6], A[6]);
    buf A7 (a_in[7], A[7]);
    buf A8 (a_in[8], A[8]);
    buf A9 (a_in[9], A[9]);
    buf A10 (a_in[10], A[10]);
    buf A11 (a_in[11], A[11]);
    buf A12 (a_in[12], A[12]);
    buf A13 (a_in[13], A[13]);
    buf A14 (a_in[14], A[14]);
    buf A15 (a_in[15], A[15]);
    buf A16 (a_in[16], A[16]);
    buf A17 (a_in[17], A[17]);
    buf A18 (a_in[18], A[17]);
    buf A19 (a_in[19], A[17]);
    buf A20 (a_in[20], A[17]);
    buf A21 (a_in[21], A[17]);
    buf A22 (a_in[22], A[17]);
    buf A23 (a_in[23], A[17]);
    buf A24 (a_in[24], A[17]);
    buf A25 (a_in[25], A[17]);
    buf A26 (a_in[26], A[17]);
    buf A27 (a_in[27], A[17]);
    buf A28 (a_in[28], A[17]);
    buf A29 (a_in[29], A[17]);
    buf A30 (a_in[30], A[17]);
    buf A31 (a_in[31], A[17]);
    buf A32 (a_in[32], A[17]);
    buf A33 (a_in[33], A[17]);
    buf A34 (a_in[34], A[17]);
    buf A35 (a_in[35], A[17]);
    buf B0 (b_in[0], B[0]);
    buf B1 (b_in[1], B[1]);
    buf B2 (b_in[2], B[2]);
    buf B3 (b_in[3], B[3]);
    buf B4 (b_in[4], B[4]);
    buf B5 (b_in[5], B[5]);
    buf B6 (b_in[6], B[6]);
    buf B7 (b_in[7], B[7]);
    buf B8 (b_in[8], B[8]);
    buf B9 (b_in[9], B[9]);
    buf B10 (b_in[10], B[10]);
    buf B11 (b_in[11], B[11]);
    buf B12 (b_in[12], B[12]);
    buf B13 (b_in[13], B[13]);
    buf B14 (b_in[14], B[14]);
    buf B15 (b_in[15], B[15]);
    buf B16 (b_in[16], B[16]);
    buf B17 (b_in[17], B[17]);
    buf B18 (b_in[18], B[17]);
    buf B19 (b_in[19], B[17]);
    buf B20 (b_in[20], B[17]);
    buf B21 (b_in[21], B[17]);
    buf B22 (b_in[22], B[17]);
    buf B23 (b_in[23], B[17]);
    buf B24 (b_in[24], B[17]);
    buf B25 (b_in[25], B[17]);
    buf B26 (b_in[26], B[17]);
    buf B27 (b_in[27], B[17]);
    buf B28 (b_in[28], B[17]);
    buf B29 (b_in[29], B[17]);
    buf B30 (b_in[30], B[17]);
    buf B31 (b_in[31], B[17]);
    buf B32 (b_in[32], B[17]);
    buf B33 (b_in[33], B[17]);
    buf B34 (b_in[34], B[17]);
    buf B35 (b_in[35], B[17]);

    buf P0 (P[0], p0_out);
    buf P1 (P[1], p1_out);
    buf P2 (P[2], p2_out);
    buf P3 (P[3], p3_out);
    buf P4 (P[4], p4_out);
    buf P5 (P[5], p5_out);
    buf P6 (P[6], p6_out);
    buf P7 (P[7], p7_out);
    buf P8 (P[8], p8_out);
    buf P9 (P[9], p9_out);
    buf P10 (P[10], p10_out);
    buf P11 (P[11], p11_out);
    buf P12 (P[12], p12_out);
    buf P13 (P[13], p13_out);
    buf P14 (P[14], p14_out);
    buf P15 (P[15], p15_out);
    buf P16 (P[16], p16_out);
    buf P17 (P[17], p17_out);
    buf P18 (P[18], p18_out);
    buf P19 (P[19], p19_out);
    buf P20 (P[20], p20_out);
    buf P21 (P[21], p21_out);
    buf P22 (P[22], p22_out);
    buf P23 (P[23], p23_out);
    buf P24 (P[24], p24_out);
    buf P25 (P[25], p25_out);
    buf P26 (P[26], p26_out);
    buf P27 (P[27], p27_out);
    buf P28 (P[28], p28_out);
    buf P29 (P[29], p29_out);
    buf P30 (P[30], p30_out);
    buf P31 (P[31], p31_out);
    buf P32 (P[32], p32_out);
    buf P33 (P[33], p33_out);
    buf P34 (P[34], p34_out);
    buf P35 (P[35], p35_out);

    assign p_in = a_in * b_in;
    assign {p35_out, p34_out, p33_out, p32_out, p31_out, p30_out, p29_out, p28_out, p27_out, p26_out, p25_out, p24_out, p23_out, p22_out, p21_out, p20_out, p19_out, p18_out, p17_out, p16_out, p15_out, p14_out, p13_out, p12_out, p11_out, p10_out, p9_out, p8_out, p7_out, p6_out, p5_out, p4_out, p3_out, p2_out, p1_out, p0_out} = p_out;


        always @(posedge C or posedge GSR)
         if (GSR)
            p_out = 36'b0;
         else
            if (R)
                p_out <= 36'b0;
            else if (CE)
                p_out <= #100 p_in;

endmodule

