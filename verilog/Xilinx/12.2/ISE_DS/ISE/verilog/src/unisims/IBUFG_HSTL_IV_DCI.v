// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IBUFG_HSTL_IV_DCI.v,v 1.6 2007/05/23 21:43:34 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Input Clock Buffer with HSTL_IV_DCI I/O Standard
// /___/   /\     Filename : IBUFG_HSTL_IV_DCI.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:28 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.

`timescale  1 ps / 1 ps


module IBUFG_HSTL_IV_DCI (O, I);

    output O;

    input  I;

	buf B1 (O, I);


endmodule

