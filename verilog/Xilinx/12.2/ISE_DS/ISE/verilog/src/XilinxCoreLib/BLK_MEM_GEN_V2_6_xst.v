/******************************************************************************
 *
 * Block Memory Generator Core - Block Memory Behavioral Model
 *
 * Copyright(C) 2005 by Xilinx, Inc. All rights reserved.
 * This text/file contains proprietary, confidential
 * information of Xilinx, Inc., is distributed under
 * license from Xilinx, Inc., and may be used, copied
 * and/or disclosed only pursuant to the terms of a valid
 * license agreement with Xilinx, Inc. Xilinx hereby
 * grants you a license to use this text/file solely for
 * design, simulation, implementation and creation of
 * design files limited to Xilinx devices or technologies.
 * Use with non-Xilinx devices or technologies is expressly
 * prohibited and immediately terminates your license unless
 * covered by a separate agreement.
 *
 * Xilinx is providing this design, code, or information
 * "as-is" solely for use in developing programs and
 * solutions for Xilinx devices, with no obligation on the
 * part of Xilinx to provide support. By providing this design,
 * code, or information as one possible implementation of
 * this feature, application or standard, Xilinx is making no
 * representation that this implementation is free from any
 * claims of infringement. You are responsible for obtaining
 * any rights you may require for your implementation.
 * Xilinx expressly disclaims any warranty whatsoever with
 * respect to the adequacy of the implementation, including
 * but not limited to any warranties or representations that this
 * implementation is free from claims of infringement, implied
 * warranties of merchantability or fitness for a particular
 * purpose.
 *
 * Xilinx products are not intended for use in life support
 * appliances, devices, or systems. Use in such applications is
 * expressly prohibited.
 *
 * Any modifications that are made to the Source Code are
 * done at the user's sole risk and will be unsupported.
 * The Xilinx Support Hotline does not have access to source
 * code and therefore cannot answer specific questions related
 * to source HDL. The Xilinx Hotline support of original source
 * code IP shall only address issues and questions related
 * to the standard Netlist version of the core (and thus
 * indirectly, the original core source).
 *
 * This copyright and support notice must be retained as part
 * of this text at all times. (c) Copyright 1995-2005 Xilinx, Inc.
 * All rights reserved.
 *
 *****************************************************************************
 *
 * Filename: BLK_MEM_GEN_V2_6.v
 *
 * Description:
 *   This file is the Verilog behvarial model for the
 *       Block Memory Generator Core.
 *
 *****************************************************************************
 * Author: Xilinx
 *
 * History: September 6, 2005 Initial revision
 *****************************************************************************/
`timescale 1ps/1ps

module BLK_MEM_GEN_V2_6_xst
  #(parameter C_ADDRA_WIDTH             = 5,
    parameter C_ADDRB_WIDTH             = 5,
    parameter C_ALGORITHM               = 1,
    parameter C_BYTE_SIZE               = 9,
    parameter C_COMMON_CLK              = 1,
    parameter C_DEFAULT_DATA            = "0",
    parameter C_DISABLE_WARN_BHV_COLL   = 0,
    parameter C_DISABLE_WARN_BHV_RANGE  = 0,
    parameter C_FAMILY           = "virtex5",
    parameter C_HAS_ENA                 = 1,
    parameter C_HAS_ENB                 = 1,
    parameter C_HAS_MEM_OUTPUT_REGS_A   = 0,
    parameter C_HAS_MEM_OUTPUT_REGS_B   = 0,
    parameter C_HAS_MUX_OUTPUT_REGS_A   = 0,
    parameter C_HAS_MUX_OUTPUT_REGS_B   = 0,
    parameter C_MUX_PIPELINE_STAGES     = 0,
    parameter C_HAS_REGCEA              = 0,
    parameter C_HAS_REGCEB              = 0,
    parameter C_HAS_SSRA                = 0,
    parameter C_HAS_SSRB                = 0,
    parameter C_INIT_FILE_NAME          = "",
    parameter C_LOAD_INIT_FILE          = 0,
    parameter C_MEM_TYPE                = 2,
    parameter C_PRIM_TYPE               = 3,
    parameter C_READ_DEPTH_A            = 64,
    parameter C_READ_DEPTH_B            = 64,
    parameter C_READ_WIDTH_A            = 32,
    parameter C_READ_WIDTH_B            = 32,
    parameter C_SIM_COLLISION_CHECK     = "NONE",
    parameter C_SINITA_VAL              = "0",
    parameter C_SINITB_VAL              = "0",
    parameter C_USE_BYTE_WEA            = 0,
    parameter C_USE_BYTE_WEB            = 0,
    parameter C_USE_DEFAULT_DATA        = 0,
    parameter C_USE_ECC                 = 0,
    parameter C_USE_RAMB16BWER_RST_BHV  = 0,
    parameter C_WEA_WIDTH               = 1,
    parameter C_WEB_WIDTH               = 1,
    parameter C_WRITE_DEPTH_A           = 64,
    parameter C_WRITE_DEPTH_B           = 64,
    parameter C_WRITE_MODE_A            = "WRITE_FIRST",
    parameter C_WRITE_MODE_B            = "WRITE_FIRST",
    parameter C_WRITE_WIDTH_A           = 32,
    parameter C_WRITE_WIDTH_B           = 32,
    parameter C_XDEVICEFAMILY           = "virtex5"
)
  (input                       CLKA,
   input [C_WRITE_WIDTH_A-1:0] DINA,
   input [C_ADDRA_WIDTH-1:0]   ADDRA,
   input                       ENA,
   input                       REGCEA,
   input [C_WEA_WIDTH-1:0]     WEA,
   input                       SSRA,
   output [C_READ_WIDTH_A-1:0] DOUTA,
   input                       CLKB,
   input [C_WRITE_WIDTH_B-1:0] DINB,
   input [C_ADDRB_WIDTH-1:0]   ADDRB,
   input                       ENB,
   input                       REGCEB,
   input [C_WEB_WIDTH-1:0]     WEB,
   input                       SSRB,
   output [C_READ_WIDTH_B-1:0] DOUTB,
   output                      DBITERR,
   output                      SBITERR);

  BLK_MEM_GEN_V2_6
  #(
    .C_ADDRA_WIDTH             (C_ADDRA_WIDTH),
    .C_ADDRB_WIDTH             (C_ADDRB_WIDTH),
    .C_ALGORITHM               (C_ALGORITHM),
    .C_BYTE_SIZE               (C_BYTE_SIZE),
    .C_COMMON_CLK              (C_COMMON_CLK),
    .C_DEFAULT_DATA            (C_DEFAULT_DATA),
    .C_DISABLE_WARN_BHV_COLL   (C_DISABLE_WARN_BHV_COLL),
    .C_DISABLE_WARN_BHV_RANGE  (C_DISABLE_WARN_BHV_RANGE),
    .C_FAMILY                  (C_FAMILY),
    .C_HAS_ENA                 (C_HAS_ENA),
    .C_HAS_ENB                 (C_HAS_ENB),
    .C_HAS_MEM_OUTPUT_REGS_A   (C_HAS_MEM_OUTPUT_REGS_A),
    .C_HAS_MEM_OUTPUT_REGS_B   (C_HAS_MEM_OUTPUT_REGS_B),
    .C_HAS_MUX_OUTPUT_REGS_A   (C_HAS_MUX_OUTPUT_REGS_A),
    .C_HAS_MUX_OUTPUT_REGS_B   (C_HAS_MUX_OUTPUT_REGS_B),
    .C_MUX_PIPELINE_STAGES     (C_MUX_PIPELINE_STAGES),
    .C_HAS_REGCEA              (C_HAS_REGCEA),
    .C_HAS_REGCEB              (C_HAS_REGCEB),
    .C_HAS_SSRA                (C_HAS_SSRA),
    .C_HAS_SSRB                (C_HAS_SSRB),
    .C_INIT_FILE_NAME          (C_INIT_FILE_NAME),
    .C_LOAD_INIT_FILE          (C_LOAD_INIT_FILE),
    .C_MEM_TYPE                (C_MEM_TYPE),
    .C_PRIM_TYPE               (C_PRIM_TYPE),
    .C_READ_DEPTH_A            (C_READ_DEPTH_A),
    .C_READ_DEPTH_B            (C_READ_DEPTH_B),
    .C_READ_WIDTH_A            (C_READ_WIDTH_A),
    .C_READ_WIDTH_B            (C_READ_WIDTH_B),
    .C_SIM_COLLISION_CHECK     (C_SIM_COLLISION_CHECK),
    .C_SINITA_VAL              (C_SINITA_VAL),
    .C_SINITB_VAL              (C_SINITB_VAL),
    .C_USE_BYTE_WEA            (C_USE_BYTE_WEA),
    .C_USE_BYTE_WEB            (C_USE_BYTE_WEB),
    .C_USE_DEFAULT_DATA        (C_USE_DEFAULT_DATA),
    .C_USE_ECC                 (C_USE_ECC),
    .C_USE_RAMB16BWER_RST_BHV  (C_USE_RAMB16BWER_RST_BHV),
    .C_WEA_WIDTH               (C_WEA_WIDTH),
    .C_WEB_WIDTH               (C_WEB_WIDTH),
    .C_WRITE_DEPTH_A           (C_WRITE_DEPTH_A),
    .C_WRITE_DEPTH_B           (C_WRITE_DEPTH_B),
    .C_WRITE_MODE_A            (C_WRITE_MODE_A),
    .C_WRITE_MODE_B            (C_WRITE_MODE_B),
    .C_WRITE_WIDTH_A           (C_WRITE_WIDTH_A),
    .C_WRITE_WIDTH_B           (C_WRITE_WIDTH_B),
    .C_XDEVICEFAMILY           (C_XDEVICEFAMILY)
    ) blk_mem_gen_v2_6_dut (
    .DINA       (DINA),
    .DINB       (DINB),
    .ADDRA      (ADDRA),
    .ADDRB      (ADDRB),
    .ENA        (ENA),
    .ENB        (ENB),
    .REGCEA     (REGCEA),
    .REGCEB     (REGCEB),
    .WEA        (WEA),
    .WEB        (WEB),
    .SSRA       (SSRA),
    .SSRB       (SSRB),
    .CLKA       (CLKA),
    .CLKB       (CLKB),
    .DOUTA      (DOUTA),
    .DOUTB      (DOUTB),
    .DBITERR    (DBITERR),
    .SBITERR    (SBITERR)
);

endmodule

