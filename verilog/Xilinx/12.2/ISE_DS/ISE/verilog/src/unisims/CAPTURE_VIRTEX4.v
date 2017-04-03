// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/CAPTURE_VIRTEX4.v,v 1.4 2007/06/06 22:14:07 fphillip Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Register State Capture for Bitstream Readback for VIRTEX4
// /___/   /\     Filename : CAPTURE_VIRTEX4.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:43 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    06/06/07 - Fixed timescale values
// End Revision


`timescale  1 ps / 1 ps


module CAPTURE_VIRTEX4 (CAP, CLK);

    input  CAP, CLK;

    parameter ONESHOT = "TRUE";
    
endmodule
