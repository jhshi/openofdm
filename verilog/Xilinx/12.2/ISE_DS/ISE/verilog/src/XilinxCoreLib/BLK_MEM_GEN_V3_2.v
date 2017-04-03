/******************************************************************************
-- (c) Copyright 2006 - 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
 *****************************************************************************
 *
 * Filename: BLK_MEM_GEN_V3_2.v
 *
 * Description:
 *   This file is the Verilog behvarial model for the
 *       Block Memory Generator Core.
 *
 *****************************************************************************
 * Author: Xilinx
 *
 * History: Jan 11, 2006 Initial revision
 *          Jun 11, 2007 Added independent register stages for 
 *                       Port A and Port B (IP1_Jm/v2.5)
 *          Aug 28, 2007 Added mux pipeline stages feature (IP2_Jm/v2.6)
 *          Mar 13, 2008 Behavioral model optimizations
 *          April 07, 2009  : Added support for Spartan-6 and Virtex-6
 *                            features, including the following:
 *                            (i)   error injection, detection and/or correction
 *                            (ii) reset priority
 *                            (iii)  special reset behavior
 *    
 *****************************************************************************/
`timescale 1ps/1ps

//*****************************************************************************
// Output Register Stage module
//
// This module builds the output register stages of the memory. This module is 
// instantiated in the main memory module (BLK_MEM_GEN_V3_2) which is
// declared/implemented further down in this file.
//*****************************************************************************

module BLK_MEM_GEN_V3_2_output_stage
  #(parameter C_FAMILY              = "virtex5",
    parameter C_XDEVICEFAMILY       = "virtex5",
    parameter C_RST_TYPE            = "SYNC",
    parameter C_HAS_RST             = 0,
    parameter C_RSTRAM              = 0,
    parameter C_RST_PRIORITY        = "CE",
    parameter C_INIT_VAL            = "0",
    parameter C_HAS_EN              = 0,
    parameter C_HAS_REGCE           = 0,
    parameter C_DATA_WIDTH          = 32,
    parameter C_ADDRB_WIDTH         = 10,
    parameter C_HAS_MEM_OUTPUT_REGS = 0,
    parameter C_USE_ECC             = 0,
    parameter NUM_STAGES            = 1,
    parameter FLOP_DELAY            = 100
  )
  (
   input                         CLK,
   input                         RST,
   input                         EN,
   input                         REGCE,
   input      [C_DATA_WIDTH-1:0] DIN,
   output reg [C_DATA_WIDTH-1:0] DOUT,
   input                         SBITERR_IN,
   input                         DBITERR_IN,
   output reg                    SBITERR,
   output reg                    DBITERR,
   input      [C_ADDRB_WIDTH-1:0]             RDADDRECC_IN,
   output reg [C_ADDRB_WIDTH-1:0]             RDADDRECC
);

//******************************
// Port and Generic Definitions
//******************************
  //-------------------------------------------------------------------------
  // Generic Definitions
  //-------------------------------------------------------------------------
  // C_FAMILY,C_XDEVICEFAMILY: Designates architecture targeted. The following
  //                           options are available - "spartan3", "spartan6", 
  //                           "virtex4", "virtex5" and "virtex6".
  // C_RST_TYPE              : Type of reset - Synchronous or Asynchronous
  // C_HAS_RST               : Determines the presence of the RST port
  // C_RSTRAM                : Determines if special reset behavior is used
  // C_RST_PRIORITY          : Determines the priority between CE and SR
  // C_INIT_VAL              : Initialization value
  // C_HAS_EN                : Determines the presence of the EN port
  // C_HAS_REGCE             : Determines the presence of the REGCE port
  // C_DATA_WIDTH            : Memory write/read width
  // C_ADDRB_WIDTH           : Width of the ADDRB input port
  // C_HAS_MEM_OUTPUT_REGS   : Designates the use of a register at the output 
  //                           of the RAM primitive
  // C_USE_ECC               : Determines if the ECC feature is used or
  //                           not. Only applicable for V5 and V6
  // NUM_STAGES              : Determines the number of output stages
  // FLOP_DELAY              : Constant delay for register assignments
  //-------------------------------------------------------------------------
  // Port Definitions
  //-------------------------------------------------------------------------
  // CLK    : Clock to synchronize all read and write operations
  // RST    : Reset input to reset memory outputs to a user-defined 
  //           reset state
  // EN     : Enable all read and write operations
  // REGCE  : Register Clock Enable to control each pipeline output
  //           register stages
  // DIN    : Data input to the Output stage.
  // DOUT   : Final Data output
  // SBITERR_IN    : SBITERR input signal to the Output stage.
  // SBITERR       : Final SBITERR Output signal.
  // DBITERR_IN    : DBITERR input signal to the Output stage.
  // DBITERR       : Final DBITERR Output signal.
  // RDADDRECC_IN  : RDADDRECC input signal to the Output stage.
  // RDADDRECC     : Final RDADDRECC Output signal.
  //-------------------------------------------------------------------------

//  Fix for CR-509792
//  localparam REG_STAGES  = (NUM_STAGES == 0) ? 0 : NUM_STAGES-1;
  localparam REG_STAGES  = (NUM_STAGES < 2) ? 1 : NUM_STAGES-1;

  // Declare the pipeline registers 
  // (includes mem output reg, mux pipeline stages, and mux output reg)
  reg [C_DATA_WIDTH*REG_STAGES-1:0] out_regs;
  reg [C_ADDRB_WIDTH*REG_STAGES-1:0] rdaddrecc_regs;
  reg [REG_STAGES-1:0] sbiterr_regs;
  reg [REG_STAGES-1:0] dbiterr_regs;

  reg [C_DATA_WIDTH*8-1:0]          init_str = C_INIT_VAL;
  reg [C_DATA_WIDTH-1:0]            init_val;

  //*********************************************
  // Wire off optional inputs based on parameters
  //*********************************************
  wire                              en_i;
  wire                              regce_i;
  wire                              rst_i;

  // Internal enable for output registers is tied to user EN or '1' depending
  // on parameters
  assign   en_i    = (C_HAS_EN==0 || EN);

  // Internal register enable for output registers is tied to user REGCE, EN or
  // '1' depending on parameters
  // For V4 ECC, REGCE is always 1
  // Virtex-4 ECC Not Yet Supported
  assign   regce_i = ((C_HAS_REGCE==1) && REGCE) ||
                     ((C_HAS_REGCE==0) && (C_HAS_EN==0 || EN));
  
  //Internal SRR is tied to user RST or '0' depending on parameters
  assign   rst_i   = (C_HAS_RST==1) && RST;

  //****************************************************
  // Power on: load up the output registers and latches
  //****************************************************
  initial begin
    if (!($sscanf(init_str, "%h", init_val))) begin
      init_val = 0;
    end
    DOUT = init_val;
    RDADDRECC = 0;
    SBITERR = 1'b0;
    DBITERR = 1'b0;
    // This will be one wider than need, but 0 is an error
    out_regs = {(REG_STAGES+1){init_val}};
    rdaddrecc_regs = 0;
    sbiterr_regs = {(REG_STAGES+1){1'b0}};
    dbiterr_regs = {(REG_STAGES+1){1'b0}};
  end

 //***********************************************
 // NUM_STAGES = 0 (No output registers. RAM only)
 //***********************************************
  generate if (NUM_STAGES == 0) begin : zero_stages
    always @* begin
      DOUT = DIN;
      RDADDRECC = RDADDRECC_IN;
      SBITERR = SBITERR_IN;
      DBITERR = DBITERR_IN;
    end
  end
  endgenerate

  //***********************************************
  // NUM_STAGES = 1 
  // (Mem Output Reg only or Mux Output Reg only)
  //***********************************************

  // Possible valid combinations: 
  // Note: C_HAS_MUX_OUTPUT_REGS_*=0 when (C_RSTRAM_*=1)
  //   +-----------------------------------------+
  //   |   C_RSTRAM_*   |  Reset Behavior        |
  //   +----------------+------------------------+
  //   |       0        |   Normal Behavior      |
  //   +----------------+------------------------+
  //   |       1        |  Special Behavior      |
  //   +----------------+------------------------+
  //
  // Normal = REGCE gates reset, as in the case of all families except S3ADSP.
  // Special = EN gates reset, as in the case of S3ADSP.

  generate if (NUM_STAGES == 1 && 
                 (C_RSTRAM == 0 || (C_RSTRAM == 1 && C_XDEVICEFAMILY != "spartan3adsp") ||
                  C_HAS_MEM_OUTPUT_REGS == 0 || C_HAS_RST == 0))
  begin : one_stages_norm
       //Asynchronous Reset
    if (C_FAMILY == "spartan6" && C_RST_TYPE == "ASYNC") begin
        if(C_RST_PRIORITY == "CE") begin //REGCE has priority
          always @ (*) begin
            if (rst_i && regce_i) DOUT    = init_val;
          end
          always @ (posedge CLK) begin
            if (!rst_i && regce_i) DOUT    <= #FLOP_DELAY DIN;
          end //CLK
        end else begin          //RST has priority
          always @ (*) begin
            if (rst_i) DOUT    = init_val;
          end
          always @ (posedge CLK) begin
            if (!rst_i && regce_i) DOUT    <= #FLOP_DELAY DIN;
          end //CLK
        end //end Priority conditions
       //Synchronous Reset
    end else begin
      always @(posedge CLK) begin
        if (C_RST_PRIORITY == "CE") begin //REGCE has priority
          if (regce_i && rst_i) begin
            DOUT    <= #FLOP_DELAY init_val;
            RDADDRECC <= #FLOP_DELAY 0;
            SBITERR <= #FLOP_DELAY 1'b0;
            DBITERR <= #FLOP_DELAY 1'b0;
          end else if (regce_i) begin
            DOUT    <= #FLOP_DELAY DIN;
            RDADDRECC <= #FLOP_DELAY RDADDRECC_IN;
            SBITERR <= #FLOP_DELAY SBITERR_IN;
            DBITERR <= #FLOP_DELAY DBITERR_IN;
          end //Output signal assignments
        end else begin             //RST has priority
          if (rst_i) begin
            DOUT    <= #FLOP_DELAY init_val;
            RDADDRECC <= #FLOP_DELAY RDADDRECC_IN;
            SBITERR <= #FLOP_DELAY 1'b0;
            DBITERR <= #FLOP_DELAY 1'b0;
          end else if (regce_i) begin
            DOUT    <= #FLOP_DELAY DIN;
            RDADDRECC <= #FLOP_DELAY RDADDRECC_IN;
            SBITERR <= #FLOP_DELAY SBITERR_IN;
            DBITERR <= #FLOP_DELAY DBITERR_IN;
          end //Output signal assignments
        end //end Priority conditions
      end //CLK
    end //end RST Type conditions
  end //end one_stages_norm generate statement
  endgenerate

  // Special Reset Behavior for S3ADSP
  generate if (NUM_STAGES == 1 && C_RSTRAM == 1 && C_XDEVICEFAMILY =="spartan3adsp")
  begin : one_stage_splbhv
    always @(posedge CLK) begin
      if (en_i && rst_i) begin
        DOUT <= #FLOP_DELAY init_val;
      end else if (regce_i && !rst_i) begin
        DOUT <= #FLOP_DELAY DIN;
      end //Output signal assignments
    end  //end CLK
  end //end one_stage_splbhv generate statement
  endgenerate

 //************************************************************
 // NUM_STAGES > 1 
 // Mem Output Reg + Mux Output Reg
 //              or 
 // Mem Output Reg + Mux Pipeline Stages (>0) + Mux Output Reg
 //              or 
 // Mux Pipeline Stages (>0) + Mux Output Reg
 //*************************************************************
 generate if (NUM_STAGES > 1) begin : multi_stage
       //Asynchronous Reset
    if (C_FAMILY == "spartan6" && C_RST_TYPE == "ASYNC") begin
        if(C_RST_PRIORITY == "CE") begin //REGCE has priority
          always @ (*) begin
            if (rst_i && regce_i) DOUT    = init_val;
          end
          always @ (posedge CLK) begin
            if (!rst_i && regce_i) 
              DOUT    <= #FLOP_DELAY out_regs[C_DATA_WIDTH*(NUM_STAGES-2)+:C_DATA_WIDTH];
          end //CLK
        end else begin          //RST has priority
          always @ (*) begin
            if (rst_i) DOUT    = init_val;
          end
          always @ (posedge CLK) begin
            if (!rst_i && regce_i) 
              DOUT    <= #FLOP_DELAY out_regs[C_DATA_WIDTH*(NUM_STAGES-2)+:C_DATA_WIDTH];
          end //CLK
        end //end Priority conditions
        always @ (posedge CLK) begin
          if (en_i) begin
            out_regs     <= (out_regs << C_DATA_WIDTH) | DIN;
          end
        end
       //Synchronous Reset
    end else begin
      always @(posedge CLK) begin
        if (C_RST_PRIORITY == "CE") begin  //REGCE has priority
          if (regce_i && rst_i) begin
            DOUT    <= #FLOP_DELAY init_val;
            RDADDRECC <= #FLOP_DELAY 0;
            SBITERR <= #FLOP_DELAY 1'b0;
            DBITERR <= #FLOP_DELAY 1'b0;
          end else if (regce_i) begin
            DOUT    <= #FLOP_DELAY
                          out_regs[C_DATA_WIDTH*(NUM_STAGES-2)+:C_DATA_WIDTH];
            RDADDRECC <= #FLOP_DELAY rdaddrecc_regs[C_ADDRB_WIDTH*(NUM_STAGES-2)+:C_ADDRB_WIDTH];
            SBITERR <= #FLOP_DELAY sbiterr_regs[NUM_STAGES-2];
            DBITERR <= #FLOP_DELAY dbiterr_regs[NUM_STAGES-2];
          end //Output signal assignments
        end else begin                     //RST has priority
          if (rst_i) begin
            DOUT    <= #FLOP_DELAY init_val;
            RDADDRECC <= #FLOP_DELAY 0;
            SBITERR <= #FLOP_DELAY 1'b0;
            DBITERR <= #FLOP_DELAY 1'b0;
          end else if (regce_i) begin
            DOUT    <= #FLOP_DELAY
                          out_regs[C_DATA_WIDTH*(NUM_STAGES-2)+:C_DATA_WIDTH];
            RDADDRECC <= #FLOP_DELAY rdaddrecc_regs[C_ADDRB_WIDTH*(NUM_STAGES-2)+:C_ADDRB_WIDTH];
            SBITERR <= #FLOP_DELAY sbiterr_regs[NUM_STAGES-2];
            DBITERR <= #FLOP_DELAY dbiterr_regs[NUM_STAGES-2];
          end //Output signal assignments
        end   //end Priority conditions
         // Shift the data through the output stages
         if (en_i) begin
           out_regs     <= #FLOP_DELAY (out_regs << C_DATA_WIDTH) | DIN;
           rdaddrecc_regs <= #FLOP_DELAY (rdaddrecc_regs << C_ADDRB_WIDTH) | RDADDRECC_IN;
           sbiterr_regs <= #FLOP_DELAY (sbiterr_regs << 1) | SBITERR_IN;
           dbiterr_regs <= #FLOP_DELAY (dbiterr_regs << 1) | DBITERR_IN;
         end
      end  //end CLK
    end //end RST Type conditions
  end //end multi_stage generate statement
  endgenerate
endmodule


//*****************************************************************************
// Main Memory module
//
// This module is the top-level behavioral model and this implements the RAM 
//*****************************************************************************
module BLK_MEM_GEN_V3_2
  #(parameter C_CORENAME                = "blk_mem_gen_v3_2",
    parameter C_FAMILY                  = "virtex6",
    parameter C_XDEVICEFAMILY           = "virtex6",
    parameter C_MEM_TYPE                = 2,
    parameter C_BYTE_SIZE               = 9,
    parameter C_ALGORITHM               = 1,
    parameter C_PRIM_TYPE               = 3,
    parameter C_LOAD_INIT_FILE          = 0,
    parameter C_INIT_FILE_NAME          = "",
    parameter C_USE_DEFAULT_DATA        = 0,
    parameter C_DEFAULT_DATA            = "0",
    parameter C_RST_TYPE                = "SYNC",
    parameter C_HAS_RSTA                = 0,
    parameter C_RST_PRIORITY_A          = "CE",
    parameter C_RSTRAM_A                = 0,
    parameter C_INITA_VAL               = "0",
    parameter C_HAS_ENA                 = 1,
    parameter C_HAS_REGCEA              = 0,
    parameter C_USE_BYTE_WEA            = 0,
    parameter C_WEA_WIDTH               = 1,
    parameter C_WRITE_MODE_A            = "WRITE_FIRST",
    parameter C_WRITE_WIDTH_A           = 32,
    parameter C_READ_WIDTH_A            = 32,
    parameter C_WRITE_DEPTH_A           = 64,
    parameter C_READ_DEPTH_A            = 64,
    parameter C_ADDRA_WIDTH             = 5,
    parameter C_HAS_RSTB                = 0,
    parameter C_RST_PRIORITY_B          = "CE",
    parameter C_RSTRAM_B                = 0,
    parameter C_INITB_VAL               = "0",
    parameter C_HAS_ENB                 = 1,
    parameter C_HAS_REGCEB              = 0,
    parameter C_USE_BYTE_WEB            = 0,
    parameter C_WEB_WIDTH               = 1,
    parameter C_WRITE_MODE_B            = "WRITE_FIRST",
    parameter C_WRITE_WIDTH_B           = 32,
    parameter C_READ_WIDTH_B            = 32,
    parameter C_WRITE_DEPTH_B           = 64,
    parameter C_READ_DEPTH_B            = 64,
    parameter C_ADDRB_WIDTH             = 5,
    parameter C_HAS_MEM_OUTPUT_REGS_A   = 0,
    parameter C_HAS_MEM_OUTPUT_REGS_B   = 0,
    parameter C_HAS_MUX_OUTPUT_REGS_A   = 0,
    parameter C_HAS_MUX_OUTPUT_REGS_B   = 0,
    parameter C_MUX_PIPELINE_STAGES     = 0,
    parameter C_USE_ECC                 = 0,
    parameter C_HAS_INJECTERR           = 0,
    parameter C_SIM_COLLISION_CHECK     = "NONE",
    parameter C_COMMON_CLK              = 1,
    parameter C_DISABLE_WARN_BHV_COLL   = 0,
    parameter C_DISABLE_WARN_BHV_RANGE  = 0
  )
  (input                       CLKA,
   input                       RSTA,
   input                       ENA,
   input                       REGCEA,
   input [C_WEA_WIDTH-1:0]     WEA,
   input [C_ADDRA_WIDTH-1:0]   ADDRA,
   input [C_WRITE_WIDTH_A-1:0] DINA,
   output [C_READ_WIDTH_A-1:0] DOUTA,
   input                       CLKB,
   input                       RSTB,
   input                       ENB,
   input                       REGCEB,
   input [C_WEB_WIDTH-1:0]     WEB,
   input [C_ADDRB_WIDTH-1:0]   ADDRB,
   input [C_WRITE_WIDTH_B-1:0] DINB,
   output [C_READ_WIDTH_B-1:0] DOUTB,
   input                       INJECTSBITERR,
   input                       INJECTDBITERR,
   output                      SBITERR,
   output                      DBITERR,
   output [C_ADDRB_WIDTH-1:0]  RDADDRECC
  );
//******************************
// Port and Generic Definitions
//******************************
  //-------------------------------------------------------------------------
  // Generic Definitions
  //-------------------------------------------------------------------------
  // C_CORENAME              : Instance name of the Block Memory Generator core
  // C_FAMILY,C_XDEVICEFAMILY: Designates architecture targeted. The following
  //                           options are available - "spartan3", "spartan6", 
  //                           "virtex4", "virtex5" and "virtex6".
  // C_MEM_TYPE              : Designates memory type.
  //                           It can be
  //                           0 - Single Port Memory
  //                           1 - Simple Dual Port Memory
  //                           2 - True Dual Port Memory
  //                           3 - Single Port Read Only Memory
  //                           4 - Dual Port Read Only Memory
  // C_BYTE_SIZE             : Size of a byte (8 or 9 bits)
  // C_ALGORITHM             : Designates the algorithm method used
  //                           for constructing the memory.
  //                           It can be Fixed_Primitives, Minimum_Area or 
  //                           Low_Power
  // C_PRIM_TYPE             : Designates the user selected primitive used to 
  //                           construct the memory.
  //
  // C_LOAD_INIT_FILE        : Designates the use of an initialization file to
  //                           initialize memory contents.
  // C_INIT_FILE_NAME        : Memory initialization file name.
  // C_USE_DEFAULT_DATA      : Designates whether to fill remaining
  //                           initialization space with default data
  // C_DEFAULT_DATA          : Default value of all memory locations
  //                           not initialized by the memory
  //                           initialization file.
  // C_RST_TYPE              : Type of reset - Synchronous or Asynchronous
  // C_HAS_RSTA              : Determines the presence of the RSTA port
  // C_RST_PRIORITY_A        : Determines the priority between CE and SR for 
  //                           Port A.
  // C_RSTRAM_A              : Determines if special reset behavior is used for
  //                           Port A
  // C_INITA_VAL             : The initialization value for Port A
  // C_HAS_ENA               : Determines the presence of the ENA port
  // C_HAS_REGCEA            : Determines the presence of the REGCEA port
  // C_USE_BYTE_WEA          : Determines if the Byte Write is used or not.
  // C_WEA_WIDTH             : The width of the WEA port
  // C_WRITE_MODE_A          : Configurable write mode for Port A. It can be
  //                           WRITE_FIRST, READ_FIRST or NO_CHANGE.
  // C_WRITE_WIDTH_A         : Memory write width for Port A.
  // C_READ_WIDTH_A          : Memory read width for Port A.
  // C_WRITE_DEPTH_A         : Memory write depth for Port A.
  // C_READ_DEPTH_A          : Memory read depth for Port A.
  // C_ADDRA_WIDTH           : Width of the ADDRA input port
  // C_HAS_RSTB              : Determines the presence of the RSTB port
  // C_RST_PRIORITY_B        : Determines the priority between CE and SR for 
  //                           Port B.
  // C_RSTRAM_B              : Determines if special reset behavior is used for
  //                           Port B
  // C_INITB_VAL             : The initialization value for Port B
  // C_HAS_ENB               : Determines the presence of the ENB port
  // C_HAS_REGCEB            : Determines the presence of the REGCEB port
  // C_USE_BYTE_WEB          : Determines if the Byte Write is used or not.
  // C_WEB_WIDTH             : The width of the WEB port
  // C_WRITE_MODE_B          : Configurable write mode for Port B. It can be
  //                           WRITE_FIRST, READ_FIRST or NO_CHANGE.
  // C_WRITE_WIDTH_B         : Memory write width for Port B.
  // C_READ_WIDTH_B          : Memory read width for Port B.
  // C_WRITE_DEPTH_B         : Memory write depth for Port B.
  // C_READ_DEPTH_B          : Memory read depth for Port B.
  // C_ADDRB_WIDTH           : Width of the ADDRB input port
  // C_HAS_MEM_OUTPUT_REGS_A : Designates the use of a register at the output 
  //                           of the RAM primitive for Port A.
  // C_HAS_MEM_OUTPUT_REGS_B : Designates the use of a register at the output 
  //                           of the RAM primitive for Port B.
  // C_HAS_MUX_OUTPUT_REGS_A : Designates the use of a register at the output
  //                           of the MUX for Port A.
  // C_HAS_MUX_OUTPUT_REGS_B : Designates the use of a register at the output
  //                           of the MUX for Port B.
  // C_MUX_PIPELINE_STAGES   : Designates the number of pipeline stages in 
  //                           between the muxes.
  // C_USE_ECC               : Determines if the ECC feature is used or
  //                           not. Only applicable for V5 and V6
  // C_HAS_INJECTERR         : Determines if the error injection pins
  //                           are present or not. If the ECC feature
  //                           is not used, this value is defaulted to
  //                           0, else the following are the allowed 
  //                           values:
  //                         0 : No INJECTSBITERR or INJECTDBITERR pins
  //                         1 : Only INJECTSBITERR pin exists
  //                         2 : Only INJECTDBITERR pin exists
  //                         3 : Both INJECTSBITERR and INJECTDBITERR pins exist
  // C_SIM_COLLISION_CHECK   : Controls the disabling of Unisim model collision
  //                           warnings. It can be "ALL", "NONE", 
  //                           "Warnings_Only" or "Generate_X_Only".
  // C_COMMON_CLK            : Determins if the core has a single CLK input.
  // C_DISABLE_WARN_BHV_COLL : Controls the Behavioral Model Collision warnings
  // C_DISABLE_WARN_BHV_RANGE: Controls the Behavioral Model Out of Range 
  //                           warnings
  //-------------------------------------------------------------------------
  // Port Definitions
  //-------------------------------------------------------------------------
  // CLKA    : Clock to synchronize all read and write operations of Port A.
  // RSTA    : Reset input to reset memory outputs to a user-defined 
  //           reset state for Port A.
  // ENA     : Enable all read and write operations of Port A.
  // REGCEA  : Register Clock Enable to control each pipeline output
  //           register stages for Port A.
  // WEA     : Write Enable to enable all write operations of Port A.
  // ADDRA   : Address of Port A.
  // DINA    : Data input of Port A.
  // DOUTA   : Data output of Port A.
  // CLKB    : Clock to synchronize all read and write operations of Port B.
  // RSTB    : Reset input to reset memory outputs to a user-defined 
  //           reset state for Port B.
  // ENB     : Enable all read and write operations of Port B.
  // REGCEB  : Register Clock Enable to control each pipeline output
  //           register stages for Port B.
  // WEB     : Write Enable to enable all write operations of Port B.
  // ADDRB   : Address of Port B.
  // DINB    : Data input of Port B.
  // DOUTB   : Data output of Port B.
  // INJECTSBITERR : Single Bit ECC Error Injection Pin.
  // INJECTDBITERR : Double Bit ECC Error Injection Pin.
  // SBITERR       : Output signal indicating that a Single Bit ECC Error has been
  //                 detected and corrected.
  // DBITERR       : Output signal indicating that a Double Bit ECC Error has been
  //                 detected.
  // RDADDRECC     : Read Address Output signal indicating address at which an
  //                 ECC error has occurred.
  //-------------------------------------------------------------------------


// Note: C_CORENAME parameter is hard-coded to "blk_mem_gen_v3_2" and it is
// only used by this module to print warning messages. It is neither passed 
// down from blk_mem_gen_v3_2_xst.v nor present in the instantiation template
// coregen generates
  
  //***************************************************************************
  // constants for the core behavior
  //***************************************************************************
  // file handles for logging
  //--------------------------------------------------
  localparam ADDRFILE           = 32'h8000_0001; //stdout for addr out of range
  localparam COLLFILE           = 32'h8000_0001; //stdout for coll detection
  localparam ERRFILE            = 32'h8000_0001; //stdout for file I/O errors

  // other constants
  //--------------------------------------------------
  localparam COLL_DELAY         = 2000;  // 2 ns

  // locally derived parameters to determine memory shape
  //-----------------------------------------------------
  localparam MIN_WIDTH_A = (C_WRITE_WIDTH_A < C_READ_WIDTH_A) ?
             C_WRITE_WIDTH_A : C_READ_WIDTH_A;
  localparam MIN_WIDTH_B = (C_WRITE_WIDTH_B < C_READ_WIDTH_B) ?
             C_WRITE_WIDTH_B : C_READ_WIDTH_B;
  localparam MIN_WIDTH = (MIN_WIDTH_A < MIN_WIDTH_B) ?
             MIN_WIDTH_A : MIN_WIDTH_B;

  localparam MAX_DEPTH_A = (C_WRITE_DEPTH_A > C_READ_DEPTH_A) ?
             C_WRITE_DEPTH_A : C_READ_DEPTH_A;
  localparam MAX_DEPTH_B = (C_WRITE_DEPTH_B > C_READ_DEPTH_B) ?
             C_WRITE_DEPTH_B : C_READ_DEPTH_B;
  localparam MAX_DEPTH = (MAX_DEPTH_A > MAX_DEPTH_B) ?
             MAX_DEPTH_A : MAX_DEPTH_B;


  // locally derived parameters to assist memory access
  //----------------------------------------------------
  // Calculate the width ratios of each port with respect to the narrowest
  // port
  localparam WRITE_WIDTH_RATIO_A = C_WRITE_WIDTH_A/MIN_WIDTH;
  localparam READ_WIDTH_RATIO_A  = C_READ_WIDTH_A/MIN_WIDTH;
  localparam WRITE_WIDTH_RATIO_B = C_WRITE_WIDTH_B/MIN_WIDTH;
  localparam READ_WIDTH_RATIO_B  = C_READ_WIDTH_B/MIN_WIDTH;

  // To modify the LSBs of the 'wider' data to the actual
  // address value
  //----------------------------------------------------
  localparam WRITE_ADDR_A_DIV  = C_WRITE_WIDTH_A/MIN_WIDTH_A;
  localparam READ_ADDR_A_DIV   = C_READ_WIDTH_A/MIN_WIDTH_A;
  localparam WRITE_ADDR_B_DIV  = C_WRITE_WIDTH_B/MIN_WIDTH_B;
  localparam READ_ADDR_B_DIV   = C_READ_WIDTH_B/MIN_WIDTH_B;

  // If byte writes aren't being used, make sure BYTE_SIZE is not
  // wider than the memory elements to avoid compilation warnings
  localparam BYTE_SIZE   = (C_BYTE_SIZE < MIN_WIDTH) ? C_BYTE_SIZE : MIN_WIDTH;

  // The memory
  reg [MIN_WIDTH-1:0]      memory [0:MAX_DEPTH-1];
  // ECC error arrays
  reg                      sbiterr_arr [0:MAX_DEPTH-1];
  reg                      dbiterr_arr [0:MAX_DEPTH-1];

  // Memory output 'latches'
  reg [C_READ_WIDTH_A-1:0] memory_out_a;
  reg [C_READ_WIDTH_B-1:0] memory_out_b;

  // ECC error inputs and outputs from output_stage module:
  reg                      sbiterr_in;
  wire                     sbiterr_sdp;
  reg                      dbiterr_in;
  wire                     dbiterr_sdp;

  reg [C_ADDRB_WIDTH-1:0]  rdaddrecc_in;
  wire [C_ADDRB_WIDTH-1:0]  rdaddrecc_sdp;

  // Reset values
  reg [C_READ_WIDTH_A-1:0] inita_val;
  reg [C_READ_WIDTH_B-1:0] initb_val;

  // Collision detect
  reg                      is_collision;
  reg                      is_collision_a, is_collision_delay_a;
  reg                      is_collision_b, is_collision_delay_b;

  // Temporary variables for initialization
  //---------------------------------------
  integer                  status;
  integer                  initfile;
  // data input buffer
  reg [C_WRITE_WIDTH_A-1:0]    mif_data;
  // string values in hex
  reg [C_READ_WIDTH_A*8-1:0]   inita_str       = C_INITA_VAL;
  reg [C_READ_WIDTH_B*8-1:0]   initb_str       = C_INITB_VAL;
  reg [C_WRITE_WIDTH_A*8-1:0]  default_data_str = C_DEFAULT_DATA;
  // initialization filename
  reg [1023*8-1:0]             init_file_str    = C_INIT_FILE_NAME;


  //Constants used to calculate the effective address widths for each of the 
  //four ports. 
  integer cnt = 1;
  integer write_addr_a_width, read_addr_a_width;
  integer write_addr_b_width, read_addr_b_width;


  // Internal configuration parameters
  //---------------------------------------------
  localparam FLOP_DELAY  = 100;  // 100 ps
  localparam SINGLE_PORT = (C_MEM_TYPE==0 || C_MEM_TYPE==3);
  localparam IS_ROM      = (C_MEM_TYPE==3 || C_MEM_TYPE==4);
  localparam HAS_A_WRITE = (!IS_ROM);
  localparam HAS_B_WRITE = (C_MEM_TYPE==2);
  localparam HAS_A_READ  = (C_MEM_TYPE!=1);
  localparam HAS_B_READ  = (!SINGLE_PORT);
  localparam HAS_B_PORT  = (HAS_B_READ || HAS_B_WRITE);

  // Calculate the mux pipeline register stages for Port A and Port B
  //------------------------------------------------------------------
  localparam MUX_PIPELINE_STAGES_A = (C_HAS_MUX_OUTPUT_REGS_A) ?
                             C_MUX_PIPELINE_STAGES : 0;
  localparam MUX_PIPELINE_STAGES_B = (C_HAS_MUX_OUTPUT_REGS_B) ?
                             C_MUX_PIPELINE_STAGES : 0;
  
  // Calculate total number of register stages in the core
  // -----------------------------------------------------
  localparam NUM_OUTPUT_STAGES_A = (C_HAS_MEM_OUTPUT_REGS_A+MUX_PIPELINE_STAGES_A+C_HAS_MUX_OUTPUT_REGS_A);

  localparam NUM_OUTPUT_STAGES_B = (C_HAS_MEM_OUTPUT_REGS_B+MUX_PIPELINE_STAGES_B+C_HAS_MUX_OUTPUT_REGS_B);

  wire                   ena_i;
  wire                   enb_i;
  wire                   reseta_i;
  wire                   resetb_i;
  wire [C_WEA_WIDTH-1:0] wea_i;
  wire [C_WEB_WIDTH-1:0] web_i;
  wire                   rea_i;
  wire                   reb_i;

  // ECC SBITERR/DBITERR Outputs
  //  The ECC Behavior is modeled by the behavioral models only for Virtex-6.
  //  For Virtex-5, these outputs will be tied to 0.
   assign SBITERR = (C_MEM_TYPE == 1 && C_USE_ECC == 1)?sbiterr_sdp:0;
   assign DBITERR = (C_MEM_TYPE == 1 && C_USE_ECC == 1)?dbiterr_sdp:0;
   assign RDADDRECC = (C_FAMILY == "virtex6" && C_MEM_TYPE == 1 && C_USE_ECC == 1)?rdaddrecc_sdp:0;


  // This effectively wires off optional inputs
  assign ena_i = (C_HAS_ENA==0) || ENA;
  assign enb_i = ((C_HAS_ENB==0) || ENB) && HAS_B_PORT;
  assign wea_i = (HAS_A_WRITE && ena_i) ? WEA : 'b0;
  assign web_i = (HAS_B_WRITE && enb_i) ? WEB : 'b0;
  assign rea_i = (HAS_A_READ)  ? ena_i : 'b0;
  assign reb_i = (HAS_B_READ)  ? enb_i : 'b0;

  // These signals reset the memory latches

  assign reseta_i = 
     ((C_HAS_RSTA==1 && RSTA && NUM_OUTPUT_STAGES_A==0) ||
      (C_HAS_RSTA==1 && RSTA && C_RSTRAM_A==1));

  assign resetb_i = 
     ((C_HAS_RSTB==1 && RSTB && NUM_OUTPUT_STAGES_B==0) ||
      (C_HAS_RSTB==1 && RSTB && C_RSTRAM_B==1));

  // Tasks to access the memory
  //---------------------------
  //**************
  // write_a
  //**************
  task write_a
    (input  reg [C_ADDRA_WIDTH-1:0]   addr,
     input  reg [C_WEA_WIDTH-1:0]     byte_en,
     input  reg [C_WRITE_WIDTH_A-1:0] data,
     input  inj_sbiterr,
     input  inj_dbiterr);
    reg [C_WRITE_WIDTH_A-1:0] current_contents;
    reg [C_ADDRA_WIDTH-1:0] address;
    integer i;
    begin
      // Shift the address by the ratio
      address = (addr/WRITE_ADDR_A_DIV);
      if (address >= C_WRITE_DEPTH_A) begin
        if (!C_DISABLE_WARN_BHV_RANGE) begin
          $fdisplay(ADDRFILE,
                    "%0s WARNING: Address %0h is outside range for A Write",
                    C_CORENAME, addr);
        end

      // valid address
      end else begin

        // Combine w/ byte writes
        if (C_USE_BYTE_WEA) begin

          // Get the current memory contents
          if (WRITE_WIDTH_RATIO_A == 1) begin
            // Workaround for IUS 5.5 part-select issue
            current_contents = memory[address];
          end else begin
            for (i = 0; i < WRITE_WIDTH_RATIO_A; i = i + 1) begin
              current_contents[MIN_WIDTH*i+:MIN_WIDTH]
                = memory[address*WRITE_WIDTH_RATIO_A + i];
            end
          end

          // Apply incoming bytes
          if (C_WEA_WIDTH == 1) begin
            // Workaround for IUS 5.5 part-select issue
            if (byte_en[0]) begin
              current_contents = data;
            end
          end else begin
            for (i = 0; i < C_WEA_WIDTH; i = i + 1) begin
              if (byte_en[i]) begin
                current_contents[BYTE_SIZE*i+:BYTE_SIZE]
                  = data[BYTE_SIZE*i+:BYTE_SIZE];
              end
            end
          end

        // No byte-writes, overwrite the whole word
        end else begin
          current_contents = data;
        end

        // Insert double bit errors:
        if (C_USE_ECC == 1) begin
          if ((C_HAS_INJECTERR == 2 || C_HAS_INJECTERR == 3) && inj_dbiterr == 1'b1) begin
            current_contents[0] = !(current_contents[0]);
            current_contents[1] = !(current_contents[1]);
          end
        end
    
        // Write data to memory
        if (WRITE_WIDTH_RATIO_A == 1) begin
          // Workaround for IUS 5.5 part-select issue
          memory[address*WRITE_WIDTH_RATIO_A] = current_contents;
        end else begin
          for (i = 0; i < WRITE_WIDTH_RATIO_A; i = i + 1) begin
            memory[address*WRITE_WIDTH_RATIO_A + i]
              = current_contents[MIN_WIDTH*i+:MIN_WIDTH];
          end
        end

        // Store the address at which error is injected:
        if (C_FAMILY == "virtex6" && C_USE_ECC == 1) begin
          if ((C_HAS_INJECTERR == 1 && inj_sbiterr == 1'b1) || 
            (C_HAS_INJECTERR == 3 && inj_sbiterr == 1'b1 && inj_dbiterr != 1'b1))
          begin
            sbiterr_arr[addr] = 1;
          end else begin
            sbiterr_arr[addr] = 0;
          end
  
          if ((C_HAS_INJECTERR == 2 || C_HAS_INJECTERR == 3) && inj_dbiterr == 1'b1) begin
            dbiterr_arr[addr] = 1;
          end else begin
            dbiterr_arr[addr] = 0;
          end
        end

      end
    end
  endtask

  //**************
  // write_b
  //**************
  task write_b
    (input  reg [C_ADDRB_WIDTH-1:0]   addr,
     input  reg [C_WEB_WIDTH-1:0]     byte_en,
     input  reg [C_WRITE_WIDTH_B-1:0] data);
    reg [C_WRITE_WIDTH_B-1:0] current_contents;
    reg [C_ADDRB_WIDTH-1:0]   address;
    integer i;
    begin
      // Shift the address by the ratio
      address = (addr/WRITE_ADDR_B_DIV);
      if (address >= C_WRITE_DEPTH_B) begin
        if (!C_DISABLE_WARN_BHV_RANGE) begin
          $fdisplay(ADDRFILE,
                    "%0s WARNING: Address %0h is outside range for B Write",
                    C_CORENAME, addr);
        end

      // valid address
      end else begin

        // Combine w/ byte writes
        if (C_USE_BYTE_WEB) begin

          // Get the current memory contents
          if (WRITE_WIDTH_RATIO_B == 1) begin
            // Workaround for IUS 5.5 part-select issue
            current_contents = memory[address];
          end else begin
            for (i = 0; i < WRITE_WIDTH_RATIO_B; i = i + 1) begin
              current_contents[MIN_WIDTH*i+:MIN_WIDTH]
                = memory[address*WRITE_WIDTH_RATIO_B + i];
            end
          end

          // Apply incoming bytes
          if (C_WEB_WIDTH == 1) begin
            // Workaround for IUS 5.5 part-select issue
            if (byte_en[0]) begin
              current_contents = data;
            end
          end else begin
            for (i = 0; i < C_WEB_WIDTH; i = i + 1) begin
              if (byte_en[i]) begin
                current_contents[BYTE_SIZE*i+:BYTE_SIZE]
                  = data[BYTE_SIZE*i+:BYTE_SIZE];
              end
            end
          end

        // No byte-writes, overwrite the whole word
        end else begin
          current_contents = data;
        end

        // Write data to memory
        if (WRITE_WIDTH_RATIO_B == 1) begin
          // Workaround for IUS 5.5 part-select issue
          memory[address*WRITE_WIDTH_RATIO_B] = current_contents;
        end else begin
          for (i = 0; i < WRITE_WIDTH_RATIO_B; i = i + 1) begin
            memory[address*WRITE_WIDTH_RATIO_B + i]
              = current_contents[MIN_WIDTH*i+:MIN_WIDTH];
          end
        end
      end
    end
  endtask

  //**************
  // read_a
  //**************
  task read_a
    (input reg [C_ADDRA_WIDTH-1:0] addr,
     input reg reset);
    reg [C_ADDRA_WIDTH-1:0] address;
    integer i;
  begin

    if (reset) begin
      memory_out_a <= #FLOP_DELAY inita_val;
    end else begin
      // Shift the address by the ratio
      address = (addr/READ_ADDR_A_DIV);
      if (address >= C_READ_DEPTH_A) begin
        if (!C_DISABLE_WARN_BHV_RANGE) begin
          $fdisplay(ADDRFILE,
                    "%0s WARNING: Address %0h is outside range for A Read",
                    C_CORENAME, addr);
        end
        memory_out_a <= #FLOP_DELAY 'bX;
      // valid address
      end else begin
        if (READ_WIDTH_RATIO_A==1) begin
          memory_out_a <= #FLOP_DELAY memory[address*READ_WIDTH_RATIO_A];
        end else begin
          // Increment through the 'partial' words in the memory
          for (i = 0; i < READ_WIDTH_RATIO_A; i = i + 1) begin
            memory_out_a[MIN_WIDTH*i+:MIN_WIDTH]
              <= #FLOP_DELAY memory[address*READ_WIDTH_RATIO_A + i];
          end
        end //end READ_WIDTH_RATIO_A==1 loop

      end //end valid address loop
    end //end reset-data assignment loops
  end
  endtask

  //**************
  // read_b
  //**************
  task read_b
    (input reg [C_ADDRB_WIDTH-1:0] addr,
     input reg reset);
    reg [C_ADDRB_WIDTH-1:0] address;
    integer i;
    begin

    if (reset) begin
      memory_out_b <= #FLOP_DELAY initb_val;
      sbiterr_in   <= #FLOP_DELAY 1'b0;
      dbiterr_in   <= #FLOP_DELAY 1'b0;
      rdaddrecc_in <= #FLOP_DELAY 0;
    end else begin
      // Shift the address
      address = (addr/READ_ADDR_B_DIV);
      if (address >= C_READ_DEPTH_B) begin
        if (!C_DISABLE_WARN_BHV_RANGE) begin
          $fdisplay(ADDRFILE,
                    "%0s WARNING: Address %0h is outside range for B Read",
                    C_CORENAME, addr);
        end
        memory_out_b <= #FLOP_DELAY 'bX;
        sbiterr_in <= #FLOP_DELAY 1'bX;
        dbiterr_in <= #FLOP_DELAY 1'bX;
        rdaddrecc_in <= #FLOP_DELAY 'bX;
        // valid address
      end else begin
        if (READ_WIDTH_RATIO_B==1) begin
          memory_out_b <= #FLOP_DELAY memory[address*READ_WIDTH_RATIO_B];
        end else begin
          // Increment through the 'partial' words in the memory
          for (i = 0; i < READ_WIDTH_RATIO_B; i = i + 1) begin
            memory_out_b[MIN_WIDTH*i+:MIN_WIDTH]
              <= #FLOP_DELAY memory[address*READ_WIDTH_RATIO_B + i];
          end
        end

        if (C_FAMILY == "virtex6" && C_USE_ECC == 1) begin
          rdaddrecc_in <= addr;
          if (sbiterr_arr[addr] == 1) begin
            sbiterr_in <= #FLOP_DELAY 1'b1;
          end else begin
            sbiterr_in <= #FLOP_DELAY 1'b0;
          end

          if (dbiterr_arr[addr] == 1) begin
            dbiterr_in <= #FLOP_DELAY 1'b1;
          end else begin
            dbiterr_in <= #FLOP_DELAY 1'b0;
          end
        end else begin
          rdaddrecc_in <= #FLOP_DELAY 0;
          dbiterr_in <= #FLOP_DELAY 1'b0;
          sbiterr_in <= #FLOP_DELAY 1'b0;
        end //end ECC Loop

      end //end Valid address loop
    end //end reset-data assignment loops
  end
  endtask

  //**************
  // reset_a
  //**************
  task reset_a (input reg reset);
  begin
    if (reset) memory_out_a <= #FLOP_DELAY inita_val;
  end
  endtask

  //**************
  // reset_b
  //**************
  task reset_b (input reg reset);
  begin
    if (reset) memory_out_b <= #FLOP_DELAY initb_val;
  end
  endtask

  //**************
  // init_memory
  //**************
  task init_memory;
    integer i, addr_step;
    integer status;
    reg [C_WRITE_WIDTH_A-1:0] default_data;
    begin
      default_data = 0;

      //Display output message indicating that the behavioral model is being 
      //initialized
      if (C_USE_DEFAULT_DATA || C_LOAD_INIT_FILE) $display(" Block Memory Generator CORE Generator module loading initial data...");

      // Convert the default to hex
      if (C_USE_DEFAULT_DATA) begin
        if (default_data_str == "") begin
         $fdisplay(ERRFILE, "%0s ERROR: C_DEFAULT_DATA is empty!", C_CORENAME);
          $finish;
        end else begin
          status = $sscanf(default_data_str, "%h", default_data);
          if (status == 0) begin
            $fdisplay(ERRFILE, {"%0s ERROR: Unsuccessful hexadecimal read",
                                "from C_DEFAULT_DATA: %0s"},
                      C_CORENAME, C_DEFAULT_DATA);
            $finish;
          end
        end
      end

      // Step by WRITE_ADDR_A_DIV through the memory via the
      // Port A write interface to hit every location once
      addr_step = WRITE_ADDR_A_DIV;

      // 'write' to every location with default (or 0)
      for (i = 0; i < C_WRITE_DEPTH_A*addr_step; i = i + addr_step) begin
        write_a(i, {C_WEA_WIDTH{1'b1}}, default_data, 1'b0, 1'b0);
      end

      // Get specialized data from the MIF file
      if (C_LOAD_INIT_FILE) begin
        if (init_file_str == "") begin
          $fdisplay(ERRFILE, "%0s ERROR: C_INIT_FILE_NAME is empty!",
                    C_CORENAME);
          $finish;
        end else begin
          initfile = $fopen(init_file_str, "r");
          if (initfile == 0) begin
            $fdisplay(ERRFILE, {"%0s, ERROR: Problem opening",
                                "C_INIT_FILE_NAME: %0s!"},
                      C_CORENAME, init_file_str);
            $finish;
          end else begin
            // loop through the mif file, loading in the data
            for (i = 0; i < C_WRITE_DEPTH_A*addr_step; i = i + addr_step) begin
              status = $fscanf(initfile, "%b", mif_data);
              if (status > 0) begin
                write_a(i, {C_WEA_WIDTH{1'b1}}, mif_data, 1'b0, 1'b0);
              end
            end
            $fclose(initfile);
          end //initfile
        end //init_file_str
      end //C_LOAD_INIT_FILE

      //Display output message indicating that the behavioral model is done 
      //initializing
      if (C_USE_DEFAULT_DATA || C_LOAD_INIT_FILE) 
          $display(" Block Memory Generator data initialization complete.");
    end
  endtask

  //**************
  // log2roundup
  //**************
  function integer log2roundup (input integer data_value);
      integer width;
      integer cnt;
      begin
         width = 0;

         if (data_value > 1) begin
            for(cnt=1 ; cnt < data_value ; cnt = cnt * 2) begin
               width = width + 1;
            end //loop
         end //if

         log2roundup = width;

      end //log2roundup
   endfunction


  //*******************
  // collision_check
  //*******************
  function integer collision_check (input reg [C_ADDRA_WIDTH-1:0] addr_a,
                                    input integer iswrite_a,
                                    input reg [C_ADDRB_WIDTH-1:0] addr_b,
                                    input integer iswrite_b);
    reg c_aw_bw, c_aw_br, c_ar_bw;
    integer scaled_addra_to_waddrb_width;
    integer scaled_addrb_to_waddrb_width;
    integer scaled_addra_to_waddra_width;
    integer scaled_addrb_to_waddra_width;
    integer scaled_addra_to_raddrb_width;
    integer scaled_addrb_to_raddrb_width;
    integer scaled_addra_to_raddra_width;
    integer scaled_addrb_to_raddra_width;



    begin

    c_aw_bw = 0;
    c_aw_br = 0;
    c_ar_bw = 0;

    //If write_addr_b_width is smaller, scale both addresses to that width for 
    //comparing write_addr_a and write_addr_b; addr_a starts as C_ADDRA_WIDTH,
    //scale it down to write_addr_b_width. addr_b starts as C_ADDRB_WIDTH,
    //scale it down to write_addr_b_width. Once both are scaled to 
    //write_addr_b_width, compare.
    scaled_addra_to_waddrb_width  = ((addr_a)/
                                        2**(C_ADDRA_WIDTH-write_addr_b_width));
    scaled_addrb_to_waddrb_width  = ((addr_b)/
                                        2**(C_ADDRB_WIDTH-write_addr_b_width));

    //If write_addr_a_width is smaller, scale both addresses to that width for 
    //comparing write_addr_a and write_addr_b; addr_a starts as C_ADDRA_WIDTH,
    //scale it down to write_addr_a_width. addr_b starts as C_ADDRB_WIDTH,
    //scale it down to write_addr_a_width. Once both are scaled to 
    //write_addr_a_width, compare.
    scaled_addra_to_waddra_width  = ((addr_a)/
                                        2**(C_ADDRA_WIDTH-write_addr_a_width));
    scaled_addrb_to_waddra_width  = ((addr_b)/
                                        2**(C_ADDRB_WIDTH-write_addr_a_width));

    //If read_addr_b_width is smaller, scale both addresses to that width for 
    //comparing write_addr_a and read_addr_b; addr_a starts as C_ADDRA_WIDTH,
    //scale it down to read_addr_b_width. addr_b starts as C_ADDRB_WIDTH,
    //scale it down to read_addr_b_width. Once both are scaled to 
    //read_addr_b_width, compare.
    scaled_addra_to_raddrb_width  = ((addr_a)/
                                         2**(C_ADDRA_WIDTH-read_addr_b_width));
    scaled_addrb_to_raddrb_width  = ((addr_b)/
                                         2**(C_ADDRB_WIDTH-read_addr_b_width));

    //If read_addr_a_width is smaller, scale both addresses to that width for 
    //comparing read_addr_a and write_addr_b; addr_a starts as C_ADDRA_WIDTH,
    //scale it down to read_addr_a_width. addr_b starts as C_ADDRB_WIDTH,
    //scale it down to read_addr_a_width. Once both are scaled to 
    //read_addr_a_width, compare.
    scaled_addra_to_raddra_width  = ((addr_a)/
                                         2**(C_ADDRA_WIDTH-read_addr_a_width));
    scaled_addrb_to_raddra_width  = ((addr_b)/
                                         2**(C_ADDRB_WIDTH-read_addr_a_width));

    //Look for a write-write collision. In order for a write-write
    //collision to exist, both ports must have a write transaction.
    if (iswrite_a && iswrite_b) begin
      if (write_addr_a_width > write_addr_b_width) begin
        if (scaled_addra_to_waddrb_width == scaled_addrb_to_waddrb_width) begin
          c_aw_bw = 1;
        end else begin
          c_aw_bw = 0;
        end
      end else begin
        if (scaled_addrb_to_waddra_width == scaled_addra_to_waddra_width) begin
          c_aw_bw = 1;
        end else begin
          c_aw_bw = 0;
        end
      end //width
    end //iswrite_a and iswrite_b

    //If the B port is reading (which means it is enabled - so could be
    //a TX_WRITE or TX_READ), then check for a write-read collision).
    //This could happen whether or not a write-write collision exists due
    //to asymmetric write/read ports.
    if (iswrite_a) begin
      if (write_addr_a_width > read_addr_b_width) begin
        if (scaled_addra_to_raddrb_width == scaled_addrb_to_raddrb_width) begin
          c_aw_br = 1;
        end else begin
          c_aw_br = 0;
        end
    end else begin
        if (scaled_addrb_to_waddra_width == scaled_addra_to_waddra_width) begin
          c_aw_br = 1;
        end else begin
          c_aw_br = 0;
        end
      end //width
    end //iswrite_a

    //If the A port is reading (which means it is enabled - so could be
    //  a TX_WRITE or TX_READ), then check for a write-read collision).
    //This could happen whether or not a write-write collision exists due
    //  to asymmetric write/read ports.
    if (iswrite_b) begin
      if (read_addr_a_width > write_addr_b_width) begin
        if (scaled_addra_to_waddrb_width == scaled_addrb_to_waddrb_width) begin
          c_ar_bw = 1;
        end else begin
          c_ar_bw = 0;
        end
      end else begin
        if (scaled_addrb_to_raddra_width == scaled_addra_to_raddra_width) begin
          c_ar_bw = 1;
        end else begin
          c_ar_bw = 0;
        end
      end //width
    end //iswrite_b



      collision_check = c_aw_bw | c_aw_br | c_ar_bw;

    end
  endfunction

  //*******************************
  // power on values
  //*******************************
  initial begin
    // Load up the memory
    init_memory;
    // Load up the output registers and latches
    if ($sscanf(inita_str, "%h", inita_val)) begin
      memory_out_a = inita_val;
    end else begin
      memory_out_a = 0;
    end
    if ($sscanf(initb_str, "%h", initb_val)) begin
      memory_out_b = initb_val;
    end else begin
      memory_out_b = 0;
    end

    sbiterr_in   = 1'b0;
    dbiterr_in   = 1'b0;
    rdaddrecc_in = 0;

    // Determine the effective address widths for each of the 4 ports
    write_addr_a_width = C_ADDRA_WIDTH - log2roundup(WRITE_ADDR_A_DIV);
    read_addr_a_width  = C_ADDRA_WIDTH - log2roundup(READ_ADDR_A_DIV);
    write_addr_b_width = C_ADDRB_WIDTH - log2roundup(WRITE_ADDR_B_DIV);
    read_addr_b_width  = C_ADDRB_WIDTH - log2roundup(READ_ADDR_B_DIV);

    $display("Block Memory Generator CORE Generator module %m is using a behavioral model for simulation which will not precisely model memory collision behavior.");

  end

  //*************************************************************************
  // Asynchronous reset of Port A and Port B are performed here
  // Note that the asynchronous reset feature is only supported in Spartan6
  // devices
  //*************************************************************************
  generate if(C_FAMILY=="spartan6" && C_RST_TYPE=="ASYNC") begin : async_rst
    if (C_RST_PRIORITY_A=="CE") begin
      always @ (*) begin
        if (rea_i) reset_a(reseta_i);
      end
    end 
    else begin
      always @ (*) begin
        reset_a(reseta_i);
      end
    end
    
    if (C_RST_PRIORITY_B=="CE") begin
      always @ (*) begin
        if (reb_i) reset_b(resetb_i);
      end
    end 
    else begin
      always @ (*) begin
        reset_b(resetb_i);
      end
    end
    
  end
  endgenerate
  
  //***************************************************************************
  // These are the main blocks which schedule read and write operations
  // Note that the reset priority feature at the latch stage is only supported
  // for Spartan-6. For other families, the default priority at the latch stage
  // is "CE"
  //***************************************************************************
      // Synchronous clocks: schedule port operations with respect to
      // both write operating modes
  generate
    if(C_COMMON_CLK && (C_WRITE_MODE_A == "WRITE_FIRST") && (C_WRITE_MODE_B ==
                    "WRITE_FIRST")) begin : com_clk_sched_wf_wf
      always @(posedge CLKA) begin
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i) read_a(ADDRA, reseta_i);
        end
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i) read_b(ADDRB, resetb_i);
        end
      end
    end
    else 
    if(C_COMMON_CLK && (C_WRITE_MODE_A == "READ_FIRST") && (C_WRITE_MODE_B ==
                    "WRITE_FIRST")) begin : com_clk_sched_rf_wf
      always @(posedge CLKA) begin
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i) read_b(ADDRB, resetb_i);
        end
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i) read_a(ADDRA, reseta_i);
        end
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
      end
    end
    else 
    if(C_COMMON_CLK && (C_WRITE_MODE_A == "WRITE_FIRST") && (C_WRITE_MODE_B ==
                    "READ_FIRST")) begin : com_clk_sched_wf_rf
      always @(posedge CLKA) begin
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i) read_a(ADDRA, reseta_i);
        end
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i) read_b(ADDRB, resetb_i);
        end
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
      end
    end
    else 
    if(C_COMMON_CLK && (C_WRITE_MODE_A == "READ_FIRST") && (C_WRITE_MODE_B ==
                    "READ_FIRST")) begin : com_clk_sched_rf_rf
      always @(posedge CLKA) begin
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i) read_a(ADDRA, reseta_i);
        end
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i) read_b(ADDRB, resetb_i);
        end
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
      end
    end
    else if(C_COMMON_CLK && (C_WRITE_MODE_A =="WRITE_FIRST") && (C_WRITE_MODE_B ==
                    "NO_CHANGE")) begin : com_clk_sched_wf_nc
      always @(posedge CLKA) begin
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i) read_a(ADDRA, reseta_i);
        end
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i && !web_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i && (!web_i || resetb_i)) read_b(ADDRB, resetb_i);
        end
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
      end
    end
    else if(C_COMMON_CLK && (C_WRITE_MODE_A =="READ_FIRST") && (C_WRITE_MODE_B ==
                    "NO_CHANGE")) begin : com_clk_sched_rf_nc
      always @(posedge CLKA) begin
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i) read_a(ADDRA, reseta_i);
        end
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i && !web_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i && (!web_i || resetb_i)) read_b(ADDRB, resetb_i);
        end
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
      end
    end
    else if(C_COMMON_CLK && (C_WRITE_MODE_A =="NO_CHANGE") && (C_WRITE_MODE_B ==
                    "WRITE_FIRST")) begin : com_clk_sched_nc_wf
      always @(posedge CLKA) begin
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i && !wea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i && (!wea_i || reseta_i)) read_a(ADDRA, reseta_i);
        end
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i) read_b(ADDRB, resetb_i);
        end
      end
    end
    else if(C_COMMON_CLK && (C_WRITE_MODE_A =="NO_CHANGE") && (C_WRITE_MODE_B == 
                    "READ_FIRST")) begin : com_clk_sched_nc_rf
      always @(posedge CLKA) begin
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i) read_b(ADDRB, resetb_i);
        end
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i && !wea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i && (!wea_i || reseta_i)) read_a(ADDRA, reseta_i);
        end
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
      end
    end
    else if(C_COMMON_CLK && (C_WRITE_MODE_A =="NO_CHANGE") && (C_WRITE_MODE_B ==
                    "NO_CHANGE")) begin : com_clk_sched_nc_nc
      always @(posedge CLKA) begin
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i && !wea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i && (!wea_i || reseta_i)) read_a(ADDRA, reseta_i);
        end
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i && !web_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i && (!web_i || resetb_i)) read_b(ADDRB, resetb_i);
        end
      end
    end
    else if(C_COMMON_CLK) begin: com_clk_sched_default
      always @(posedge CLKA) begin
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i) read_a(ADDRA, reseta_i);
        end
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i) read_b(ADDRB, resetb_i);
        end
      end
    end
  endgenerate

      // Asynchronous clocks: port operation is independent

  generate
    if((!C_COMMON_CLK) && (C_WRITE_MODE_A == "WRITE_FIRST")) begin : async_clk_sched_clka_wf
      always @(posedge CLKA) begin
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i) read_a(ADDRA, reseta_i);
       end
      end
    end
    else if((!C_COMMON_CLK) && (C_WRITE_MODE_A == "READ_FIRST")) begin : async_clk_sched_clka_rf
      always @(posedge CLKA) begin
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i) read_a(ADDRA, reseta_i);
        end else begin
          if (rea_i) read_a(ADDRA, reseta_i);
       end
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
      end
    end
    else if((!C_COMMON_CLK) && (C_WRITE_MODE_A == "NO_CHANGE")) begin : async_clk_sched_clka_nc
      always @(posedge CLKA) begin
        //Write A
        if (wea_i) write_a(ADDRA, wea_i, DINA, INJECTSBITERR, INJECTDBITERR);
        //Read A
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_A=="SR") begin
          if (reseta_i) reset_a(reseta_i);
          else if (rea_i && !wea_i) read_a(ADDRA, reseta_i);
        end else begin
         if (rea_i && (!wea_i || reseta_i)) read_a(ADDRA, reseta_i);
       end
      end
    end
  endgenerate

  generate 
    if ((!C_COMMON_CLK) && (C_WRITE_MODE_B == "WRITE_FIRST")) begin: async_clk_sched_clkb_wf
      always @(posedge CLKB) begin
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i) read_b(ADDRB, resetb_i);
        end
      end
    end
    else if ((!C_COMMON_CLK) && (C_WRITE_MODE_B == "READ_FIRST")) begin: async_clk_sched_clkb_rf
      always @(posedge CLKB) begin
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i) read_b(ADDRB, resetb_i);
        end
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
      end
    end
    else if ((!C_COMMON_CLK) && (C_WRITE_MODE_B == "NO_CHANGE")) begin: async_clk_sched_clkb_nc
      always @(posedge CLKB) begin
        //Write B
        if (web_i) write_b(ADDRB, web_i, DINB);
        //Read B
        if (C_FAMILY=="spartan6" && C_RST_PRIORITY_B=="SR") begin
          if (resetb_i) reset_b(resetb_i);
          else if (reb_i && !web_i) read_b(ADDRB, resetb_i);
        end else begin
          if (reb_i && (!web_i || resetb_i)) read_b(ADDRB, resetb_i);
        end
      end
    end
  endgenerate

  
  //***************************************************************
  //  Instantiate the variable depth output register stage module
  //***************************************************************
  // Port A
  BLK_MEM_GEN_V3_2_output_stage
    #(.C_FAMILY                 (C_FAMILY),
      .C_XDEVICEFAMILY          (C_XDEVICEFAMILY),
      .C_RST_TYPE               (C_RST_TYPE),
      .C_HAS_RST                (C_HAS_RSTA),
      .C_RSTRAM                 (C_RSTRAM_A),
      .C_RST_PRIORITY           (C_RST_PRIORITY_A),
      .C_INIT_VAL               (C_INITA_VAL),
      .C_HAS_EN                 (C_HAS_ENA),
      .C_HAS_REGCE              (C_HAS_REGCEA),
      .C_DATA_WIDTH             (C_READ_WIDTH_A),
      .C_ADDRB_WIDTH            (C_ADDRB_WIDTH),
      .C_HAS_MEM_OUTPUT_REGS    (C_HAS_MEM_OUTPUT_REGS_A),
      .C_USE_ECC                (C_USE_ECC),
      .NUM_STAGES               (NUM_OUTPUT_STAGES_A),
      .FLOP_DELAY               (FLOP_DELAY))
      reg_a
        (.CLK         (CLKA),
         .RST         (RSTA),
         .EN          (ENA),
         .REGCE       (REGCEA),
         .DIN         (memory_out_a),
         .DOUT        (DOUTA),
         .SBITERR_IN  (1'b0),
         .DBITERR_IN  (1'b0),
         .SBITERR     (),
         .DBITERR     (),
         .RDADDRECC_IN ({C_ADDRB_WIDTH{1'b0}}),
         .RDADDRECC   ()
        );

  // Port B 
  BLK_MEM_GEN_V3_2_output_stage
    #(.C_FAMILY                 (C_FAMILY),
      .C_XDEVICEFAMILY          (C_XDEVICEFAMILY),
      .C_RST_TYPE               (C_RST_TYPE),
      .C_HAS_RST                (C_HAS_RSTB),
      .C_RSTRAM                 (C_RSTRAM_B),
      .C_RST_PRIORITY           (C_RST_PRIORITY_B),
      .C_INIT_VAL               (C_INITB_VAL),
      .C_HAS_EN                 (C_HAS_ENB),
      .C_HAS_REGCE              (C_HAS_REGCEB),
      .C_DATA_WIDTH             (C_READ_WIDTH_B),
      .C_ADDRB_WIDTH            (C_ADDRB_WIDTH),
      .C_HAS_MEM_OUTPUT_REGS    (C_HAS_MEM_OUTPUT_REGS_B),
      .C_USE_ECC                (C_USE_ECC),
      .NUM_STAGES               (NUM_OUTPUT_STAGES_B),
      .FLOP_DELAY               (FLOP_DELAY))
      reg_b
        (.CLK         (CLKB),
         .RST         (RSTB),
         .EN          (ENB),
         .REGCE       (REGCEB),
         .DIN         (memory_out_b),
         .DOUT        (DOUTB),
         .SBITERR_IN  (sbiterr_in),
         .DBITERR_IN  (dbiterr_in),
         .SBITERR     (sbiterr_sdp),
         .DBITERR     (dbiterr_sdp),
         .RDADDRECC_IN (rdaddrecc_in),
         .RDADDRECC   (rdaddrecc_sdp)
        );

  //****************************************************
  // Synchronous collision checks
  //****************************************************
  generate if (!C_DISABLE_WARN_BHV_COLL && C_COMMON_CLK) begin : sync_coll
    always @(posedge CLKA) begin
      // Possible collision if both are enabled and the addresses match
      if (ena_i && enb_i) begin
        if (wea_i || web_i) begin
          is_collision <= collision_check(ADDRA, wea_i, ADDRB, web_i);
        end else begin
          is_collision <= 0;
        end
      end else begin
          is_collision <= 0;
      end

      // If the write port is in READ_FIRST mode, there is no collision
      if (C_WRITE_MODE_A=="READ_FIRST" && wea_i && !web_i) begin
        is_collision <= 0;
      end
      if (C_WRITE_MODE_B=="READ_FIRST" && web_i && !wea_i) begin
        is_collision <= 0;
      end

      // Only flag if one of the accesses is a write
      if (is_collision && (wea_i || web_i)) begin
        $fwrite(COLLFILE, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(COLLFILE, "A %0s address: %0h, B %0s address: %0h\n",
                wea_i ? "write" : "read", ADDRA,
                web_i ? "write" : "read", ADDRB);
      end
    end

  //****************************************************
  // Asynchronous collision checks
  //****************************************************
  end else if (!C_DISABLE_WARN_BHV_COLL && !C_COMMON_CLK) begin : async_coll

    // Delay A and B addresses in order to mimic setup/hold times
    wire [C_ADDRA_WIDTH-1:0]  #COLL_DELAY addra_delay = ADDRA;
    wire [0:0]                #COLL_DELAY wea_delay   = wea_i;
    wire                      #COLL_DELAY ena_delay   = ena_i;
    wire [C_ADDRB_WIDTH-1:0]  #COLL_DELAY addrb_delay = ADDRB;
    wire [0:0]                #COLL_DELAY web_delay   = web_i;
    wire                      #COLL_DELAY enb_delay   = enb_i;

    // Do the checks w/rt A
    always @(posedge CLKA) begin
      // Possible collision if both are enabled and the addresses match
      if (ena_i && enb_i) begin
        if (wea_i || web_i) begin
          is_collision_a <= collision_check(ADDRA, wea_i, ADDRB, web_i);
        end else begin
          is_collision_a <= 0;
        end
      end else begin
        is_collision_a <= 0;
      end

      if (ena_i && enb_delay) begin
        if(wea_i || web_delay) begin
          is_collision_delay_a <= collision_check(ADDRA, wea_i, addrb_delay,
                                                                    web_delay);
        end else begin
          is_collision_delay_a <= 0;
        end
      end else begin
        is_collision_delay_a <= 0;
      end


      // Only flag if B access is a write
      if (is_collision_a && web_i) begin
        $fwrite(COLLFILE, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(COLLFILE, "A %0s address: %0h, B write address: %0h\n",
                wea_i ? "write" : "read", ADDRA, ADDRB);

      end else if (is_collision_delay_a && web_delay) begin
        $fwrite(COLLFILE, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(COLLFILE, "A %0s address: %0h, B write address: %0h\n",
                wea_i ? "write" : "read", ADDRA, addrb_delay);
      end

    end

    // Do the checks w/rt B
    always @(posedge CLKB) begin

      // Possible collision if both are enabled and the addresses match
      if (ena_i && enb_i) begin
        if (wea_i || web_i) begin
          is_collision_b <= collision_check(ADDRA, wea_i, ADDRB, web_i);
        end else begin
          is_collision_b <= 0;
        end
      end else begin
        is_collision_b <= 0;
      end

      if (ena_delay && enb_i) begin
        if (wea_delay || web_i) begin
          is_collision_delay_b <= collision_check(addra_delay, wea_delay, ADDRB,
                                                                        web_i);
        end else begin
          is_collision_delay_b <= 0;
        end
      end else begin
        is_collision_delay_b <= 0;
      end


      // Only flag if A access is a write
      if (is_collision_b && wea_i) begin
        $fwrite(COLLFILE, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(COLLFILE, "A write address: %0h, B %s address: %0h\n",
                ADDRA, web_i ? "write" : "read", ADDRB);

      end else if (is_collision_delay_b && wea_delay) begin
        $fwrite(COLLFILE, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(COLLFILE, "A write address: %0h, B %s address: %0h\n",
                addra_delay, web_i ? "write" : "read", ADDRB);
      end

    end
  end
  endgenerate

endmodule
