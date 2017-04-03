// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IBUFG_LVDCI_DV2_15.v,v 1.6 2007/05/23 21:43:34 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Input Clock Buffer with LVDCI_DV2_15 I/O Standard
// /___/   /\     Filename : IBUFG_LVDCI_DV2_15.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:29 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.

`timescale  1 ps / 1 ps


module IBUFG_LVDCI_DV2_15 (O, I);

    output O;

    input  I;

	buf B1 (O, I);


endmodule

