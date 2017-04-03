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
// /__/   /\       Filename    : SUSPEND_SYNC.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module SUSPEND_SYNC (
  SREQ,
  CLK,
  SACK
);

  output SREQ;

  input CLK;
  input SACK;

endmodule
