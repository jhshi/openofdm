// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/USR_ACCESS_VIRTEX4.v,v 1.4 2007/06/06 22:14:07 fphillip Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  
// /___/   /\     Filename : USR_ACCESS_VIRTEX4.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:52 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    06/06/07 - Fixed timescale values
// End Revision

`timescale  100 ps / 10 ps

module USR_ACCESS_VIRTEX4 (DATA, DATAVALID);

    output [31:0] DATA;
    output DATAVALID;

endmodule // USR_ACCESS_VIRTEX4
