// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/BUFIO.v,v 1.4 2007/06/01 22:41:59 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Local Clock Buffer for I/O
// /___/   /\     Filename : BUFIO.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:43 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/30/07 - change timescale to 1ps/1ps.

`timescale  1 ps / 1 ps


module BUFIO (O, I);

    output O;
    
    input  I;
    
    buf B1 (O, I);

endmodule

