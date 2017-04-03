///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Internal Configuration Access Port for Spartan3a
// /___/   /\     Filename : ICAP_SPARTAN3A.v
// \   \  /  \    Timestamp : Wed Jul  6 18:29:19 PDT 2005
//  \___\/\___\
//
// Revision:
//    07/06/05 - Initial version.

`timescale  1 ps / 1 ps


module ICAP_SPARTAN3A (BUSY, O, CE, CLK, I, WRITE);

    output BUSY;
    output [7:0] O;

    input  CE, CLK, WRITE;
    input  [7:0] I; 
    
endmodule

