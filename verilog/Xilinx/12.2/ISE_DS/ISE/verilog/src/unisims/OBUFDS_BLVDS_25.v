// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/OBUFDS_BLVDS_25.v,v 1.6 2007/05/23 21:43:40 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Differential Signaling Output Buffer with BLVDS_25 I/O Standard
// /___/   /\     Filename : OBUFDS_BLVDS_25.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:00 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.

`timescale  1 ps / 1 ps


module OBUFDS_BLVDS_25 (O, OB, I);

    output O, OB;

    input  I;

    tri0 GTS = glbl.GTS;

	bufif0 B1 (O, I, GTS);
	notif0 N1 (OB, I, GTS);


endmodule


