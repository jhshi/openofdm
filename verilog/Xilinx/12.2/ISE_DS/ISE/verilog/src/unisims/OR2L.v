// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/blanc/OR2L.v,v 1.3 2008/10/08 21:02:10 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Latch used as 2-input OR Gate
// /___/   /\     Filename : OR2L.v
// \   \  /  \    Timestamp : Tue Feb 26 11:11:42 PST 2008
//  \___\/\___\
//
// Revision:
//    02/26/08 - Initial version.
//    04/01/08 - Add GSR.
// End Revision

`timescale  1 ps / 1 ps

module OR2L (O, DI, SRI);

    output O;

    input  SRI, DI;
    
    tri0 GSR = glbl.GSR;

    wire o_out;

    assign O = (GSR) ? 0 : o_out;
    or O1 (o_out, SRI, DI);

endmodule
