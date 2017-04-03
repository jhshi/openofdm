/*
 *******************************************************************************
 *
 * (c) Copyright 1995 - 2009 Xilinx, Inc. All rights reserved.
 *
 * This file contains confidential and proprietary information
 * of Xilinx, Inc. and is protected under U.S. and
 * international copyright and other intellectual property
 * laws.
 *
 * DISCLAIMER
 * This disclaimer is not a license and does not grant any
 * rights to the materials distributed herewith. Except as
 * otherwise provided in a valid license issued to you by
 * Xilinx, and to the maximum extent permitted by applicable
 * law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
 * WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
 * AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
 * BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
 * INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
 * (2) Xilinx shall not be liable (whether in contract or tort,
 * including negligence, or under any other theory of
 * liability) for any loss or damage of any kind or nature
 * related to, arising under or in connection with these
 * materials, including for any direct, or any indirect,
 * special, incidental, or consequential loss or damage
 * (including loss of data, profits, goodwill, or any type of
 * loss or damage suffered as a result of any action brought
 * by a third party) even if such damage or loss was
 * reasonably foreseeable or Xilinx had been advised of the
 * possibility of the same.
 *
 * CRITICAL APPLICATIONS
 * Xilinx products are not designed or intended to be fail-
 * safe, or for use in any application requiring fail-safe
 * performance, such as life-support or safety devices or
 * systems, Class III medical devices, nuclear facilities,
 * applications related to the deployment of airbags, or any
 * other applications that could lead to death, personal
 * injury, or severe property or environmental damage
 * (individually and collectively, "Critical
 * Applications"). Customer assumes the sole risk and
 * liability of any use of Xilinx products in Critical
 * Applications, subject only to applicable laws and
 * regulations governing limitations on product liability.
 *
 * THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
 * PART OF THIS FILE AT ALL TIMES.
 *
 *******************************************************************************
 *******************************************************************************
 */


`timescale 1ps/1ps

module DIST_MEM_GEN_V5_1_XST 
#(
   parameter C_FAMILY             = "virtex5",
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
   parameter C_WIDTH              = 16,
   parameter C_PARSER_TYPE        = 1
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

   DIST_MEM_GEN_V5_1
   #(
      .C_FAMILY            (C_FAMILY),
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
      .C_WIDTH             (C_WIDTH),
      .C_PARSER_TYPE       (C_PARSER_TYPE)
    ) dist_mem_gen_v5_1_dut 
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
 
 
 
