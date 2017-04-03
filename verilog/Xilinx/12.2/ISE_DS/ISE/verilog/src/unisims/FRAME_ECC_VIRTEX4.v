// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/FRAME_ECC_VIRTEX4.v,v 1.3 2004/03/31 22:39:42 patrickp Exp $
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
// /___/   /\     Filename : FRAME_ECC_VIRTEX4.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:44 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.

`timescale  1 ps / 1 ps

module FRAME_ECC_VIRTEX4 (ERROR, SYNDROME, SYNDROMEVALID);

    output ERROR;
    output [11:0] SYNDROME;
    output SYNDROMEVALID;
    
endmodule // FRAME_ECC_VIRTEX4

