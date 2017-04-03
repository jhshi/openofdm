// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/blanc/BUFHCE.v,v 1.4 2008/10/21 20:28:29 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  H Clock Buffer with Active High Enable
// /___/   /\     Filename : BUFHCE.v
// \   \  /  \    Timestamp :
//  \___\/\___\
//
// Revision:
//    04/08/08 - Initial version.
//    09/19/08 - Add GSR.
//    10/19/08 - Recoding to same as BUFGCE according to hardware.
// End Revision

`timescale  1 ps / 1 ps


module BUFHCE (O, CE, I);

    parameter integer INIT_OUT = 0;

    output O;

    input  CE;
    input  I;

    wire   NCE, o_bufg_o, o_bufg1_o;
                                                                                  
    BUFGMUX B1 (.I0(I),
        .I1(1'b0),
        .O(o_bufg_o),
        .S(NCE));
                                                                                  
    INV I1 (.I(CE),
        .O(NCE));

    BUFGMUX_1 B2 (.I0(I),
        .I1(1'b1),
        .O(o_bufg1_o),
        .S(NCE));

    assign O = (INIT_OUT == 1) ? o_bufg1_o : o_bufg_o;

endmodule

