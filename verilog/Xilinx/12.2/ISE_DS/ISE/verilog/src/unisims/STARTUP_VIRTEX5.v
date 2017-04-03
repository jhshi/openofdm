///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  User Interface to Global Clock, Reset and 3-State Controls for VIRTEX5
// /___/   /\     Filename : STARTUP_VIRTEX5.v
// \   \  /  \    Timestamp : Thu Jul 21 13:42:30 PDT 2005
//  \___\/\___\
//
// Revision:
//    07/21/05 - Initial version.
//    10/30/09 - CR 537429 -- Added CFGMCLK functionality.
// End Revision

`timescale 1 ps / 1 ps 

module STARTUP_VIRTEX5 (
        CFGCLK,
        CFGMCLK,
        DINSPI,
	EOS,
        TCKSPI,
	CLK,
	GSR,
	GTS,
	USRCCLKO,
	USRCCLKTS,
	USRDONEO,
	USRDONETS
);

output CFGCLK;
output CFGMCLK;
output DINSPI;
output EOS;
output TCKSPI;

input CLK;
input GSR;
input GTS;
input USRCCLKO;
input USRCCLKTS;
input USRDONEO;
input USRDONETS;

tri0 GSR, GTS;
    
    assign glbl.GSR = GSR;
    assign glbl.GTS = GTS;

    time CFGMCLK_PERIOD = 10000;

    reg cfgmclk_out;

    initial begin
        cfgmclk_out = 0;
        forever #(CFGMCLK_PERIOD) cfgmclk_out = !cfgmclk_out;
     end 

     assign CFGMCLK = cfgmclk_out; 
specify
	specparam PATHPULSE$ = 0;
endspecify

endmodule
