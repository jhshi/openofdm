// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/blanc/EFUSE_USR.v,v 1.3 2009/08/21 23:55:39 harikr Exp $
///////////////////////////////////////////////////////
//  Copyright (c) 2009 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : 
//  /  /                      
// /__/   /\       Filename    : EFUSE_USR.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:		1.0
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module EFUSE_USR (
  EFUSEUSR
);

  parameter [31:0] SIM_EFUSE_VALUE = 32'h00000000;

  output [31:0] EFUSEUSR;

  assign EFUSEUSR = SIM_EFUSE_VALUE;

endmodule
