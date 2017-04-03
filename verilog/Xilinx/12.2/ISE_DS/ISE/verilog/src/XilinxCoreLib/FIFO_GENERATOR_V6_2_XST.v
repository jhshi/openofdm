/*
 *******************************************************************************
 *
 * FIFO Generator - Verilog Behavioral Model
 *
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
 *
 * Filename: fifo_generator_v6_2_bhv.v
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
module FIFO_GENERATOR_V6_2_XST
  (
   BACKUP,
   BACKUP_MARKER,
   CLK,
   RST,
   SRST,
   WR_CLK,
   WR_RST,
   RD_CLK,
   RD_RST,
   DIN,
   WR_EN,
   RD_EN,
   PROG_EMPTY_THRESH,
   PROG_EMPTY_THRESH_ASSERT,
   PROG_EMPTY_THRESH_NEGATE,
   PROG_FULL_THRESH,
   PROG_FULL_THRESH_ASSERT,
   PROG_FULL_THRESH_NEGATE,
   INT_CLK,
   INJECTDBITERR,
   INJECTSBITERR,

   DOUT,
   FULL,
   ALMOST_FULL,
   WR_ACK,
   OVERFLOW,
   EMPTY,
   ALMOST_EMPTY,
   VALID,
   UNDERFLOW,
   DATA_COUNT,
   RD_DATA_COUNT,
   WR_DATA_COUNT,
   PROG_FULL,
   PROG_EMPTY,
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
 parameter  C_FULL_FLAGS_RST_VAL           = 1;
 parameter  C_HAS_ALMOST_EMPTY             = 0;
 parameter  C_HAS_ALMOST_FULL              = 0;
 parameter  C_HAS_BACKUP                   = 0;
 parameter  C_HAS_DATA_COUNT               = 0;
 parameter  C_HAS_INT_CLK                  = 0;
 parameter  C_HAS_MEMINIT_FILE             = 0;
 parameter  C_HAS_OVERFLOW                 = 0;
 parameter  C_HAS_RD_DATA_COUNT            = 0;
 parameter  C_HAS_RD_RST                   = 0;
 parameter  C_HAS_RST                      = 0;
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
 parameter  C_PRIM_FIFO_TYPE               = "";
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
 parameter  C_USE_DOUT_RST                 = 0;
 parameter  C_USE_ECC                      = 0;
 parameter  C_USE_EMBEDDED_REG             = 0;
 parameter  C_USE_FIFO16_FLAGS             = 0;
 parameter  C_USE_FWFT_DATA_COUNT          = 0;
 parameter  C_VALID_LOW                    = 0;
 parameter  C_WR_ACK_LOW                   = 0;
 parameter  C_WR_DATA_COUNT_WIDTH          = 2;
 parameter  C_WR_DEPTH                     = 256;
 parameter  C_WR_FREQ                      = 1;
 parameter  C_WR_PNTR_WIDTH                = 8;
 parameter  C_WR_RESPONSE_LATENCY          = 1;
 parameter  C_MSGON_VAL                    = 1;
 parameter  C_ENABLE_RST_SYNC              = 1;
 parameter  C_ERROR_INJECTION_TYPE         = 0;
 

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
  input                              SRST;
  input                              WR_CLK;
  input                              WR_EN;
  input                              WR_RST;
  input                              INT_CLK;
  input                              INJECTDBITERR;
  input                              INJECTSBITERR;

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

  FIFO_GENERATOR_V6_2
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
    .C_FULL_FLAGS_RST_VAL               (C_FULL_FLAGS_RST_VAL),
    .C_HAS_ALMOST_EMPTY			(C_HAS_ALMOST_EMPTY),
    .C_HAS_ALMOST_FULL			(C_HAS_ALMOST_FULL),
    .C_HAS_BACKUP			(C_HAS_BACKUP),
    .C_HAS_DATA_COUNT			(C_HAS_DATA_COUNT),
    .C_HAS_INT_CLK                      (C_HAS_INT_CLK),
    .C_HAS_MEMINIT_FILE			(C_HAS_MEMINIT_FILE),
    .C_HAS_OVERFLOW			(C_HAS_OVERFLOW),
    .C_HAS_RD_DATA_COUNT		(C_HAS_RD_DATA_COUNT),
    .C_HAS_RD_RST			(C_HAS_RD_RST),
    .C_HAS_RST				(C_HAS_RST),
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
    .C_USE_DOUT_RST                     (C_USE_DOUT_RST),
    .C_USE_ECC                          (C_USE_ECC),
    .C_USE_EMBEDDED_REG			(C_USE_EMBEDDED_REG),
    .C_USE_FIFO16_FLAGS			(C_USE_FIFO16_FLAGS),
    .C_USE_FWFT_DATA_COUNT		(C_USE_FWFT_DATA_COUNT),
    .C_VALID_LOW			(C_VALID_LOW),
    .C_WR_ACK_LOW			(C_WR_ACK_LOW),
    .C_WR_DATA_COUNT_WIDTH		(C_WR_DATA_COUNT_WIDTH),
    .C_WR_DEPTH				(C_WR_DEPTH),
    .C_WR_FREQ				(C_WR_FREQ),
    .C_WR_PNTR_WIDTH			(C_WR_PNTR_WIDTH),
    .C_WR_RESPONSE_LATENCY		(C_WR_RESPONSE_LATENCY),
    .C_MSGON_VAL                        (C_MSGON_VAL),
    .C_ENABLE_RST_SYNC                  (C_ENABLE_RST_SYNC),
    .C_ERROR_INJECTION_TYPE             (C_ERROR_INJECTION_TYPE)
  )
  fifo_generator_v6_2_dut
  (
    .BACKUP                   (BACKUP),
    .BACKUP_MARKER            (BACKUP_MARKER),
    .CLK                      (CLK),
    .RST                      (RST),
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
    .INT_CLK                  (INT_CLK),
    .INJECTDBITERR            (INJECTDBITERR), 
    .INJECTSBITERR            (INJECTSBITERR),

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
