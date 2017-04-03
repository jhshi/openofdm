/*
 * $RDCfile: $ $Revision: 1.7 $ $Date: 2008/09/09 19:56:58 $
 *******************************************************************************
 *
 * FIFO Generator v3.3 - Verilog Behavioral Model
 *
 *******************************************************************************
 *
 * Copyright(C) 2006 by Xilinx, Inc. All rights reserved.
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
 * Xilinx is providing theis design, code, or information
 * "as-is" solely for use in developing programs and
 * solutions for Xilinx devices, with no obligation on the
 * part of Xilinx to provide support. By providing this design,
 * code, or information as one possible implementation of
 * this feature, application or standard. Xilinx is making no
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
 * This copyright and support notice must be retained as part
 * of this text at all times. (c)Copyright 1995-2006 Xilinx, Inc.
 * All rights reserved.
 *
 *******************************************************************************
 *
 * Filename: fifo_generator_v3_3_bhv.v
 *
 * Description:
 *  The verilog behavioral model for the FIFO generator core.
 *
 *******************************************************************************
 */

`timescale 1ps/1ps

/*******************************************************************************
 * Declaration of top-level module
 ******************************************************************************/
module FIFO_GENERATOR_V3_3_XST
  (
   BACKUP,
   BACKUP_MARKER,
   CLK,
   DIN,
   PROG_EMPTY_THRESH,
   PROG_EMPTY_THRESH_ASSERT,
   PROG_EMPTY_THRESH_NEGATE,
   PROG_FULL_THRESH,
   PROG_FULL_THRESH_ASSERT,
   PROG_FULL_THRESH_NEGATE,
   RD_CLK,
   RD_EN,
   RD_RST,
   RST,
   //Added Synchronous Reset feature for v3.2 (IP2_Im)
   SRST,
   WR_CLK,
   WR_EN,
   WR_RST,

   ALMOST_EMPTY,
   ALMOST_FULL,
   DATA_COUNT,
   DOUT,
   EMPTY,
   FULL,
   OVERFLOW,
   PROG_EMPTY,
   PROG_FULL,
   RD_DATA_COUNT,
   UNDERFLOW,
   VALID,
   WR_ACK,
   WR_DATA_COUNT,
   SBITERR,
   DBITERR
   );

/******************************************************************************
 * Definition of Ports
 *
 *
 *****************************************************************************
 * Definition of Parameters
 *
 *
 *****************************************************************************/

/******************************************************************************
 * Declare user parameters and their defaults
 *****************************************************************************/
 parameter  C_COMMON_CLOCK                 = 0;
 parameter  C_COUNT_TYPE                   = 0;
 parameter  C_DATA_COUNT_WIDTH             = 2;
 parameter  C_DEFAULT_VALUE                = "";
 parameter  C_DIN_WIDTH                    = 8;
 parameter  C_DOUT_RST_VAL                 = "";
 parameter  C_DOUT_WIDTH                   = 8;
 parameter  C_ENABLE_RLOCS                 = 0;
 parameter  C_FAMILY                       = "virtex2"; //Not allowed in Verilog model
 parameter  C_HAS_ALMOST_EMPTY             = 0;
 parameter  C_HAS_ALMOST_FULL              = 0;
 parameter  C_HAS_BACKUP                   = 0;
 parameter  C_HAS_DATA_COUNT               = 0;
 parameter  C_HAS_MEMINIT_FILE             = 0;
 parameter  C_HAS_OVERFLOW                 = 0;
 parameter  C_HAS_RD_DATA_COUNT            = 0;
 parameter  C_HAS_RD_RST                   = 0;
 parameter  C_HAS_RST                      = 0;
 //Added Synchronous Reset feature for v3.2 (IP2_Im)
 parameter  C_HAS_SRST                     = 0;
 parameter  C_HAS_UNDERFLOW                = 0;
 parameter  C_HAS_VALID                    = 0;
 parameter  C_HAS_WR_ACK                   = 0;
 parameter  C_HAS_WR_DATA_COUNT            = 0;
 parameter  C_HAS_WR_RST                   = 0;
 parameter  C_IMPLEMENTATION_TYPE          = 0;
 parameter  C_INIT_WR_PNTR_VAL             = 0;
 parameter  C_MEMORY_TYPE                  = 1;
 parameter  C_MIF_FILE_NAME                = "";
 parameter  C_OPTIMIZATION_MODE            = 0;
 parameter  C_OVERFLOW_LOW                 = 0;
 parameter  C_PRELOAD_LATENCY              = 1;
 parameter  C_PRELOAD_REGS                 = 0;
 parameter  C_PRIM_FIFO_TYPE               = 512;
 parameter  C_PROG_EMPTY_THRESH_ASSERT_VAL = 0;
 parameter  C_PROG_EMPTY_THRESH_NEGATE_VAL = 0;
 parameter  C_PROG_EMPTY_TYPE              = 0;
 parameter  C_PROG_FULL_THRESH_ASSERT_VAL  = 0;
 parameter  C_PROG_FULL_THRESH_NEGATE_VAL  = 0;
 parameter  C_PROG_FULL_TYPE               = 0;
 parameter  C_RD_DATA_COUNT_WIDTH          = 2;
 parameter  C_RD_DEPTH                     = 256;
 parameter  C_RD_FREQ                      = 1;
 parameter  C_RD_PNTR_WIDTH                = 8;
 parameter  C_UNDERFLOW_LOW                = 0;
 parameter  C_USE_FIFO16_FLAGS             = 0;
 parameter  C_VALID_LOW                    = 0;
 parameter  C_WR_ACK_LOW                   = 0;
 parameter  C_WR_DATA_COUNT_WIDTH          = 2;
 parameter  C_WR_DEPTH                     = 256;
 parameter  C_WR_FREQ                      = 1;
 parameter  C_WR_PNTR_WIDTH                = 8;
 parameter  C_WR_RESPONSE_LATENCY          = 1;
 parameter  C_USE_ECC                      = 0;

  /******************************************************************************
   * Declare Input and Output Ports
   *****************************************************************************/
  input                              CLK;
  input                              BACKUP;
  input                              BACKUP_MARKER;
  input [C_DIN_WIDTH-1:0]            DIN;
  input [C_RD_PNTR_WIDTH-1:0]        PROG_EMPTY_THRESH;
  input [C_RD_PNTR_WIDTH-1:0]        PROG_EMPTY_THRESH_ASSERT;
  input [C_RD_PNTR_WIDTH-1:0]        PROG_EMPTY_THRESH_NEGATE;
  input [C_WR_PNTR_WIDTH-1:0]        PROG_FULL_THRESH;
  input [C_WR_PNTR_WIDTH-1:0]        PROG_FULL_THRESH_ASSERT;
  input [C_WR_PNTR_WIDTH-1:0]        PROG_FULL_THRESH_NEGATE;
  input                              RD_CLK;
  input                              RD_EN;
  input                              RD_RST;
  input                              RST;
  //Added Synchronous Reset feature for v3.2 (IP2_Im)
  input                              SRST;
  input                              WR_CLK;
  input                              WR_EN;
  input                              WR_RST;

  output                             ALMOST_EMPTY;
  output                             ALMOST_FULL;
  output [C_DATA_COUNT_WIDTH-1:0]    DATA_COUNT;
  output [C_DOUT_WIDTH-1:0]          DOUT;
  output                             EMPTY;
  output                             FULL;
  output                             OVERFLOW;
  output                             PROG_EMPTY;
  output                             PROG_FULL;
  output                             VALID;
  output [C_RD_DATA_COUNT_WIDTH-1:0] RD_DATA_COUNT;
  output                             UNDERFLOW;
  output                             WR_ACK;
  output [C_WR_DATA_COUNT_WIDTH-1:0] WR_DATA_COUNT;
  output                             SBITERR;
  output                             DBITERR;

  //Fixed CRS:422807 in v3.2 //prasanna
  FIFO_GENERATOR_V3_3
  #(
    .C_COMMON_CLOCK 			(C_COMMON_CLOCK),
    .C_COUNT_TYPE			(C_COUNT_TYPE),
    .C_DATA_COUNT_WIDTH			(C_DATA_COUNT_WIDTH),
    .C_DEFAULT_VALUE			(C_DEFAULT_VALUE),
    .C_DIN_WIDTH			(C_DIN_WIDTH),
    .C_DOUT_RST_VAL			(C_DOUT_RST_VAL),
    .C_DOUT_WIDTH			(C_DOUT_WIDTH),
    .C_ENABLE_RLOCS			(C_ENABLE_RLOCS),
    .C_FAMILY				(C_FAMILY),//Not allowed in Verilog model
    .C_HAS_ALMOST_EMPTY			(C_HAS_ALMOST_EMPTY),
    .C_HAS_ALMOST_FULL			(C_HAS_ALMOST_FULL),
    .C_HAS_BACKUP			(C_HAS_BACKUP),
    .C_HAS_DATA_COUNT			(C_HAS_DATA_COUNT),
    .C_HAS_MEMINIT_FILE			(C_HAS_MEMINIT_FILE),
    .C_HAS_OVERFLOW			(C_HAS_OVERFLOW),
    .C_HAS_RD_DATA_COUNT		(C_HAS_RD_DATA_COUNT),
    .C_HAS_RD_RST			(C_HAS_RD_RST),
    .C_HAS_RST				(C_HAS_RST),
    //Added Synchronous Reset feature for v3.2 (IP2_Im)
    .C_HAS_SRST				(C_HAS_SRST),
    .C_HAS_UNDERFLOW			(C_HAS_UNDERFLOW),
    .C_HAS_VALID			(C_HAS_VALID),
    .C_HAS_WR_ACK			(C_HAS_WR_ACK),
    .C_HAS_WR_DATA_COUNT		(C_HAS_WR_DATA_COUNT),
    .C_HAS_WR_RST			(C_HAS_WR_RST),
    .C_IMPLEMENTATION_TYPE		(C_IMPLEMENTATION_TYPE),
    .C_INIT_WR_PNTR_VAL			(C_INIT_WR_PNTR_VAL),
    .C_MEMORY_TYPE			(C_MEMORY_TYPE),
    .C_MIF_FILE_NAME			(C_MIF_FILE_NAME),
    .C_OPTIMIZATION_MODE		(C_OPTIMIZATION_MODE),
    .C_OVERFLOW_LOW			(C_OVERFLOW_LOW),
    .C_PRELOAD_LATENCY			(C_PRELOAD_LATENCY),
    .C_PRELOAD_REGS			(C_PRELOAD_REGS),
    .C_PRIM_FIFO_TYPE			(C_PRIM_FIFO_TYPE),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL	(C_PROG_EMPTY_THRESH_ASSERT_VAL),
    .C_PROG_EMPTY_THRESH_NEGATE_VAL	(C_PROG_EMPTY_THRESH_NEGATE_VAL),
    .C_PROG_EMPTY_TYPE			(C_PROG_EMPTY_TYPE),
    .C_PROG_FULL_THRESH_ASSERT_VAL	(C_PROG_FULL_THRESH_ASSERT_VAL),
    .C_PROG_FULL_THRESH_NEGATE_VAL	(C_PROG_FULL_THRESH_NEGATE_VAL),
    .C_PROG_FULL_TYPE			(C_PROG_FULL_TYPE),
    .C_RD_DATA_COUNT_WIDTH		(C_RD_DATA_COUNT_WIDTH),
    .C_RD_DEPTH				(C_RD_DEPTH),
    .C_RD_FREQ				(C_RD_FREQ),
    .C_RD_PNTR_WIDTH			(C_RD_PNTR_WIDTH),
    .C_UNDERFLOW_LOW			(C_UNDERFLOW_LOW),
    .C_USE_FIFO16_FLAGS			(C_USE_FIFO16_FLAGS),
    .C_VALID_LOW			(C_VALID_LOW),
    .C_WR_ACK_LOW			(C_WR_ACK_LOW),
    .C_WR_DATA_COUNT_WIDTH		(C_WR_DATA_COUNT_WIDTH),
    .C_WR_DEPTH				(C_WR_DEPTH),
    .C_WR_FREQ				(C_WR_FREQ),
    .C_WR_PNTR_WIDTH			(C_WR_PNTR_WIDTH),
    .C_WR_RESPONSE_LATENCY		(C_WR_RESPONSE_LATENCY)
  )
  fifo_generator_v3_3_dut
  (
    .BACKUP                   (BACKUP),
    .BACKUP_MARKER            (BACKUP_MARKER),
    .CLK                      (CLK),
    .RST                      (RST),
    //Added Synchronous Reset feature for v3.2 (IP2_Im)
    .SRST                     (SRST),
    .WR_CLK                   (WR_CLK),
    .WR_RST                   (WR_RST),
    .RD_CLK                   (RD_CLK),
    .RD_RST                   (RD_RST),
    .DIN                      (DIN),
    .WR_EN                    (WR_EN),
    .RD_EN                    (RD_EN),
    .PROG_EMPTY_THRESH        (PROG_EMPTY_THRESH),
    .PROG_EMPTY_THRESH_ASSERT (PROG_EMPTY_THRESH_ASSERT),
    .PROG_EMPTY_THRESH_NEGATE (PROG_EMPTY_THRESH_NEGATE),
    .PROG_FULL_THRESH         (PROG_FULL_THRESH),
    .PROG_FULL_THRESH_ASSERT  (PROG_FULL_THRESH_ASSERT),
    .PROG_FULL_THRESH_NEGATE  (PROG_FULL_THRESH_NEGATE),
    .DOUT                     (DOUT),
    .FULL                     (FULL),
    .ALMOST_FULL              (ALMOST_FULL),
    .WR_ACK                   (WR_ACK),
    .OVERFLOW                 (OVERFLOW),
    .EMPTY                    (EMPTY),
    .ALMOST_EMPTY             (ALMOST_EMPTY),
    .VALID                    (VALID),
    .UNDERFLOW                (UNDERFLOW),
    .DATA_COUNT               (DATA_COUNT),
    .RD_DATA_COUNT            (RD_DATA_COUNT),
    .WR_DATA_COUNT            (WR_DATA_COUNT),
    .PROG_FULL                (PROG_FULL),
    .PROG_EMPTY               (PROG_EMPTY),
    .SBITERR                  (SBITERR),
    .DBITERR                  (DBITERR)
   );

endmodule
