// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/spartan4/STARTUP_SPARTAN3E.v,v 1.4 2004/09/04 00:05:53 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  User Interface to Global Clock, Reset and 3-State Controls for SPARTAN3E
// /___/   /\     Filename : STARTUP_SPARTAN3E.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:41 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.

`timescale  1 ns / 1 ps

module STARTUP_SPARTAN3E (CLK, GSR, GTS, MBT);

    input  CLK, GSR, GTS, MBT;

    tri0 GSR, GTS;

    reg  disable_mbt = 0;
    time init_time, min_time;
    
    assign glbl.GSR = GSR;
    assign glbl.GTS = GTS;

    // only the first valid active low MBT ( > 300ns) will put out the message
    always @(MBT) begin

	if (!disable_mbt) begin

	    if (MBT == 1'b0) begin
		if ($time != 0)
		    init_time = $time;
	    end
	    else if (MBT == 1'b1) begin
		min_time = $time - init_time;
		if (min_time >= 300) begin
		    $display ("Soft Boot has been initiated.");
		    disable_mbt = 1;
		end
	    end

	end // if (!disable_mbt)
	
    end // always @ (MBT)
    
endmodule

