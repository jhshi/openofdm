// Copyright(C) 2007 by Xilinx, Inc. All rights reserved. 
// This text/file contains proprietary, confidential 
// information of Xilinx, Inc., is distributed under license 
// from Xilinx, Inc., and may be used, copied and/or 
// disclosed only pursuant to the terms of a valid license 
// agreement with Xilinx, Inc. Xilinx hereby grants you 
// a license to use this text/file solely for design, simulation, 
// implementation and creation of design files limited 
// to Xilinx devices or technologies. Use with non-Xilinx 
// devices or technologies is expressly prohibited and 
// immediately terminates your license unless covered by 
// a separate agreement. 
// 
// Xilinx is providing this design, code, or information 
// "as is" solely for use in developing programs and 
// solutions for Xilinx devices. By providing this design, 
// code, or information as one possible implementation of 
// this feature, application or standard, Xilinx is making no 
// representation that this implementation is free from any 
// claims of infringement. You are responsible for 
// obtaining any rights you may require for your implementation. 
// Xilinx expressly disclaims any warranty whatsoever with 
// respect to the adequacy of the implementation, including 
// but not limited to any warranties or representations that this 
// implementation is free from claims of infringement, implied 
// warranties of merchantability or fitness for a particular 
// purpose. 
// 
// Xilinx products are not intended for use in life support 
// appliances, devices, or systems. Use in such applications are 
// expressly prohibited. 
// 
// This copyright and support notice must be retained as part 
// of this text at all times. (c) Copyright 1995-2006 Xilinx, Inc. 
// All rights reserved.



/* $RCSfile: DIST_MEM_GEN_V3_4_XST.v,v $
--
-- Filename - DIST_MEM_GEN_V3_4_XST.v
-- Author - Xilinx
-- Creation - 14 Nov 2007
--
-- Description
--  Distributed Memory Simulation Model
*/


`timescale 1ps/1ps

module DIST_MEM_GEN_V3_4_XST 
#(
   parameter C_ADDR_WIDTH         = 6,
   parameter C_DEFAULT_DATA       = "0",
   parameter C_DEPTH              = 64,
   parameter C_HAS_CLK            = 1,
   parameter C_HAS_D              = 1,
   parameter C_HAS_DPO            = 0,
   parameter C_HAS_DPRA           = 0,
   parameter C_HAS_I_CE           = 0,
   parameter C_HAS_QDPO           = 0,
   parameter C_HAS_QDPO_CE        = 0,
   parameter C_HAS_QDPO_CLK       = 0,
   parameter C_HAS_QDPO_RST       = 0,
   parameter C_HAS_QDPO_SRST      = 0,
   parameter C_HAS_QSPO           = 0,
   parameter C_HAS_QSPO_CE        = 0,
   parameter C_HAS_QSPO_RST       = 0,
   parameter C_HAS_QSPO_SRST      = 0,
   parameter C_HAS_SPO            = 1,
   parameter C_HAS_SPRA           = 0,
   parameter C_HAS_WE             = 1,
   parameter C_MEM_INIT_FILE      = "null.mif",
   parameter C_ELABORATION_DIR    = "./",  
   parameter C_MEM_TYPE           = 1,
   parameter C_PIPELINE_STAGES    = 0,
   parameter C_QCE_JOINED         = 0,
   parameter C_QUALIFY_WE         = 0,
   parameter C_READ_MIF           = 0,
   parameter C_REG_A_D_INPUTS     = 0,
   parameter C_REG_DPRA_INPUT     = 0,
   parameter C_SYNC_ENABLE        = 0,
   parameter C_WIDTH              = 16
)
(
   input  [C_ADDR_WIDTH-1 - (C_ADDR_WIDTH>4?(4*C_HAS_SPRA):0) : 0] A,
   input  [C_WIDTH-1 : 0] D,
   input  [C_ADDR_WIDTH-1 : 0] DPRA,
   input  [C_ADDR_WIDTH-1 : 0] SPRA,
   input  CLK,
   input  WE,
   input  I_CE,
   input  QSPO_CE,
   input  QDPO_CE,
   input  QDPO_CLK,
   input  QSPO_RST,
   input  QDPO_RST,
   input  QSPO_SRST,
   input  QDPO_SRST,
   output [C_WIDTH-1 : 0] SPO,
   output [C_WIDTH-1 : 0] QSPO,
   output [C_WIDTH-1 : 0] DPO,
   output [C_WIDTH-1 : 0] QDPO
);

   DIST_MEM_GEN_V3_4
   #(
      .C_ADDR_WIDTH        (C_ADDR_WIDTH),
      .C_DEFAULT_DATA      (C_DEFAULT_DATA),
      .C_DEPTH             (C_DEPTH),
      .C_HAS_CLK           (C_HAS_CLK), 
      .C_HAS_D             (C_HAS_D),
      .C_HAS_DPO           (C_HAS_DPO),
      .C_HAS_DPRA          (C_HAS_DPRA),
      .C_HAS_I_CE          (C_HAS_I_CE),
      .C_HAS_QDPO          (C_HAS_QDPO),
      .C_HAS_QDPO_CE       (C_HAS_QDPO_CE),
      .C_HAS_QDPO_CLK      (C_HAS_QDPO_CLK),
      .C_HAS_QDPO_RST      (C_HAS_QDPO_RST),
      .C_HAS_QDPO_SRST     (C_HAS_QDPO_SRST),
      .C_HAS_QSPO          (C_HAS_QSPO),
      .C_HAS_QSPO_CE       (C_HAS_QSPO_CE),
      .C_HAS_QSPO_RST      (C_HAS_QSPO_RST),
      .C_HAS_QSPO_SRST     (C_HAS_QSPO_SRST),
      .C_HAS_SPO           (C_HAS_SPO),
      .C_HAS_SPRA          (C_HAS_SPRA),
      .C_HAS_WE            (C_HAS_WE),
      .C_MEM_INIT_FILE     (C_MEM_INIT_FILE),
      .C_ELABORATION_DIR   (C_ELABORATION_DIR),
      .C_MEM_TYPE          (C_MEM_TYPE),
      .C_PIPELINE_STAGES   (C_PIPELINE_STAGES),
      .C_QCE_JOINED        (C_QCE_JOINED),
      .C_QUALIFY_WE        (C_QUALIFY_WE), 
      .C_READ_MIF          (C_READ_MIF),
      .C_REG_A_D_INPUTS    (C_REG_A_D_INPUTS),
      .C_REG_DPRA_INPUT    (C_REG_DPRA_INPUT),
      .C_SYNC_ENABLE       (C_SYNC_ENABLE),
      .C_WIDTH             (C_WIDTH)
    ) dist_mem_gen_v3_4_dut 
    (
      .A                    (A), 
      .D                    (D), 
      .DPRA                 (DPRA), 
      .SPRA                 (SPRA), 
      .CLK                  (CLK), 
      .WE                   (WR), 
      .I_CE                 (I_CE), 
      .QSPO_CE              (QSPO_CE), 
      .QDPO_CE              (QDPO_CE), 
      .QDPO_CLK             (QDPO_CLK), 
      .QSPO_RST             (QSPO_RST), 
      .QDPO_RST             (QDPO_RST), 
      .QSPO_SRST            (QSPO_SRST ), 
      .QDPO_SRST            (QDPO_SRS), 
      .SPO                  (SPO), 
      .DPO                  (DPO), 
      .QSPO                 (QSPO), 
      .QDPO                 (QDPO)
    );
	
endmodule		     
 
 
 
