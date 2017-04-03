// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/IOBUFDS_BLVDS_25.v,v 1.8 2008/05/15 21:26:52 fphillip Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  3-State Differential Signaling I/O Buffer with BLVDS_25 I/O Standard
// /___/   /\     Filename : IOBUFDS_BLVDS_25.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:37 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.
//    05/23/07 - Added wire declaration for internal signals.
//    05/13/08 - CR 458290 -- Added else condition to handle x case.
// End Revision


`timescale  1 ps / 1 ps


module IOBUFDS_BLVDS_25 (O, IO, IOB, I, T);
    
    output O;
    inout IO, IOB;
    input I, T;

    wire ts;
    
    tri0 GTS = glbl.GTS;

    reg O;
    
    or O1 (ts, GTS, T);
    bufif0 B1 (IO, I, ts);
    notif0 N1 (IOB, I, ts);
    
    always @(IO or IOB) begin
        if (IO == 1'b1 && IOB == 1'b0)
            O <= IO;
        else if (IO == 1'b0 && IOB == 1'b1)
            O <= IO;
        else if (IO == 1'bx || IOB == 1'bx)
            O <= 1'bx;

    end

endmodule
