///////////////////////////////////////////////////////
//  Copyright (c) 1995/2006 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : 
//  /  /                      
// /__/   /\       Filename    : STARTUP_SPARTAN6.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:		1.0
//    10/30/09 - CR 537641 -- Added CFGMCLK functionality.
// End Revision

`timescale 1 ps / 1 ps 

module STARTUP_SPARTAN6 (
  CFGCLK,
  CFGMCLK,
  EOS,
  CLK,
  GSR,
  GTS,
  KEYCLEARB
);

  output CFGCLK;
  output CFGMCLK;
  output EOS;

  input CLK;
  input GSR;
  input GTS;
  input KEYCLEARB;

  tri0 GSR, GTS;

  time CFGMCLK_PERIOD = 20000;
  reg cfgmclk_out;

  initial begin
      cfgmclk_out = 0;
      forever #(CFGMCLK_PERIOD/2.0) cfgmclk_out = !cfgmclk_out;
  end

  assign CFGMCLK = cfgmclk_out;

  assign glbl.GSR = GSR;
  assign glbl.GTS = GTS;

  specify
        specparam PATHPULSE$ = 0;
  endspecify


endmodule
