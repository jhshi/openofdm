// Copyright(C) 2002 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.


/* $Id: C_COUNTER_BINARY_V6_0.v,v 1.16 2008/09/08 20:06:04 akennedy Exp $
--
-- Filename - C_COUNTER_BINARY_V6_0.v
-- Author - Xilinx
-- Creation -14 July 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_COUNTER_BINARY_V6_0 module
*/

`timescale 1ns/10ps

`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1
`define c_signed 0
`define c_unsigned 1
`define c_pin 2
`define c_up 0
`define c_down 1
`define c_updown 2
`define allXs {C_WIDTH{1'bx}}

module C_COUNTER_BINARY_V6_0 (CLK, UP, CE, LOAD, L, IV, ACLR, ASET, AINIT, SCLR, SSET, SINIT, THRESH0, Q_THRESH0, THRESH1, Q_THRESH1, Q);

	parameter C_AINIT_VAL 		= "0";
	parameter C_COUNT_BY		= "";
	parameter C_COUNT_MODE		= `c_up;
	parameter C_COUNT_TO		= "1111111111111111";
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_CE 		= 0;
	parameter C_HAS_IV 		= 0;
	parameter C_HAS_L 		= 0;
	parameter C_HAS_LOAD		= 0;
	parameter C_HAS_Q_THRESH0	= 0;
	parameter C_HAS_Q_THRESH1	= 0;
	parameter C_HAS_SCLR 		= 0;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 0;
	parameter C_HAS_THRESH0		= 0;
	parameter C_HAS_THRESH1		= 0;
	parameter C_HAS_UP 		= 0;
	parameter C_LOAD_ENABLE 	= `c_no_override;
	parameter C_LOAD_LOW		= 0;
	parameter C_PIPE_STAGES 	= 0;    
	parameter C_RESTRICT_COUNT      = 0;
	parameter C_SINIT_VAL 		= "0";
	parameter C_SYNC_ENABLE 	= `c_override;	
	parameter C_SYNC_PRIORITY 	= `c_clear;		
	parameter C_THRESH0_VALUE       = "1111111111111111";
	parameter C_THRESH1_VALUE       = "1111111111111111";
	parameter C_THRESH_EARLY        = 1;
	parameter C_WIDTH		= 16;

	parameter C_OUT_TYPE            = `c_signed;
	parameter adder_HAS_SCLR = ((C_RESTRICT_COUNT == 1) || (C_HAS_SCLR == 1) ? 1 : 0);
	
	parameter iaxero = {62{"0"}};
	parameter iextendC_THRESH0_VALUE = {iaxero,C_THRESH0_VALUE};
	parameter iextendC_THRESH1_VALUE = {iaxero,C_THRESH1_VALUE};
	parameter iazero = {64{"0"}};
	parameter TH_TO_HAS_SCLR = ((C_HAS_SCLR == 1 || C_HAS_SSET == 1) ? 1 : 0);
	parameter TH_TO_HAS_ASET = ((C_HAS_AINIT && (C_AINIT_VAL == C_COUNT_TO)) ? 1 : 0);
	parameter TH_TO_HAS_ACLR = ((C_HAS_ACLR || (C_HAS_AINIT && (C_AINIT_VAL != C_COUNT_TO))) ? 1 : 0);
	parameter intC_HAS_SCLR0 = (iextendC_THRESH0_VALUE[0] == "0" ? (iextendC_THRESH0_VALUE[1] == "0" ? 
					(iextendC_THRESH0_VALUE[2] == "0" ? (iextendC_THRESH0_VALUE[3] == "0" ? 
					(iextendC_THRESH0_VALUE[4] == "0" ? (iextendC_THRESH0_VALUE[5] == "0" ? 
					(iextendC_THRESH0_VALUE[6] == "0" ? (iextendC_THRESH0_VALUE[7] == "0" ? 
					(iextendC_THRESH0_VALUE[8] == "0" ? (iextendC_THRESH0_VALUE[9] == "0" ? 
					(iextendC_THRESH0_VALUE[10] == "0" ? (iextendC_THRESH0_VALUE[11] == "0" ? 
					(iextendC_THRESH0_VALUE[12] == "0" ? (iextendC_THRESH0_VALUE[13] == "0" ? 
					(iextendC_THRESH0_VALUE[14] == "0" ? (iextendC_THRESH0_VALUE[15] == "0" ? 
					(iextendC_THRESH0_VALUE[16] == "0" ? (iextendC_THRESH0_VALUE[17] == "0" ? 
					(iextendC_THRESH0_VALUE[18] == "0" ? (iextendC_THRESH0_VALUE[19] == "0" ? 
					(iextendC_THRESH0_VALUE[20] == "0" ? (iextendC_THRESH0_VALUE[21] == "0" ? 
					(iextendC_THRESH0_VALUE[22] == "0" ? (iextendC_THRESH0_VALUE[23] == "0" ? 
					(iextendC_THRESH0_VALUE[24] == "0" ? (iextendC_THRESH0_VALUE[25] == "0" ? 
					(iextendC_THRESH0_VALUE[26] == "0" ? (iextendC_THRESH0_VALUE[27] == "0" ? 
					(iextendC_THRESH0_VALUE[28] == "0" ? (iextendC_THRESH0_VALUE[29] == "0" ? 
					(iextendC_THRESH0_VALUE[30] == "0" ? (iextendC_THRESH0_VALUE[31] == "0" ? 
					(iextendC_THRESH0_VALUE[32] == "0" ? (iextendC_THRESH0_VALUE[33] == "0" ? 
					(iextendC_THRESH0_VALUE[34] == "0" ? (iextendC_THRESH0_VALUE[35] == "0" ? 
					(iextendC_THRESH0_VALUE[36] == "0" ? (iextendC_THRESH0_VALUE[37] == "0" ? 
					(iextendC_THRESH0_VALUE[38] == "0" ? (iextendC_THRESH0_VALUE[39] == "0" ? 
					(iextendC_THRESH0_VALUE[40] == "0" ? (iextendC_THRESH0_VALUE[41] == "0" ? 
					(iextendC_THRESH0_VALUE[42] == "0" ? (iextendC_THRESH0_VALUE[43] == "0" ? 
					(iextendC_THRESH0_VALUE[44] == "0" ? (iextendC_THRESH0_VALUE[45] == "0" ? 
					(iextendC_THRESH0_VALUE[46] == "0" ? (iextendC_THRESH0_VALUE[47] == "0" ? 
					(iextendC_THRESH0_VALUE[48] == "0" ? (iextendC_THRESH0_VALUE[49] == "0" ? 
					(iextendC_THRESH0_VALUE[50] == "0" ? (iextendC_THRESH0_VALUE[51] == "0" ? 
					(iextendC_THRESH0_VALUE[52] == "0" ? (iextendC_THRESH0_VALUE[53] == "0" ? 
					(iextendC_THRESH0_VALUE[54] == "0" ? (iextendC_THRESH0_VALUE[55] == "0" ? 
					(iextendC_THRESH0_VALUE[56] == "0" ? (iextendC_THRESH0_VALUE[57] == "0" ? 
					(iextendC_THRESH0_VALUE[58] == "0" ? (iextendC_THRESH0_VALUE[59] == "0" ? 
					(iextendC_THRESH0_VALUE[60] == "0" ? (iextendC_THRESH0_VALUE[61] == "0" ? 
					(iextendC_THRESH0_VALUE[62] == "0" ? (iextendC_THRESH0_VALUE[63] == "0" ? 0
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0));
	parameter intC_HAS_SCLR1 = (iextendC_THRESH1_VALUE[0] == "0" ? (iextendC_THRESH1_VALUE[1] == "0" ? 
					(iextendC_THRESH1_VALUE[2] == "0" ? (iextendC_THRESH1_VALUE[3] == "0" ? 
					(iextendC_THRESH1_VALUE[4] == "0" ? (iextendC_THRESH1_VALUE[5] == "0" ? 
					(iextendC_THRESH1_VALUE[6] == "0" ? (iextendC_THRESH1_VALUE[7] == "0" ? 
					(iextendC_THRESH1_VALUE[8] == "0" ? (iextendC_THRESH1_VALUE[9] == "0" ? 
					(iextendC_THRESH1_VALUE[10] == "0" ? (iextendC_THRESH1_VALUE[11] == "0" ? 
					(iextendC_THRESH1_VALUE[12] == "0" ? (iextendC_THRESH1_VALUE[13] == "0" ? 
					(iextendC_THRESH1_VALUE[14] == "0" ? (iextendC_THRESH1_VALUE[15] == "0" ? 
					(iextendC_THRESH1_VALUE[16] == "0" ? (iextendC_THRESH1_VALUE[17] == "0" ? 
					(iextendC_THRESH1_VALUE[18] == "0" ? (iextendC_THRESH1_VALUE[19] == "0" ? 
					(iextendC_THRESH1_VALUE[20] == "0" ? (iextendC_THRESH1_VALUE[21] == "0" ? 
					(iextendC_THRESH1_VALUE[22] == "0" ? (iextendC_THRESH1_VALUE[23] == "0" ? 
					(iextendC_THRESH1_VALUE[24] == "0" ? (iextendC_THRESH1_VALUE[25] == "0" ? 
					(iextendC_THRESH1_VALUE[26] == "0" ? (iextendC_THRESH1_VALUE[27] == "0" ? 
					(iextendC_THRESH1_VALUE[28] == "0" ? (iextendC_THRESH1_VALUE[29] == "0" ? 
					(iextendC_THRESH1_VALUE[30] == "0" ? (iextendC_THRESH1_VALUE[31] == "0" ? 
					(iextendC_THRESH1_VALUE[32] == "0" ? (iextendC_THRESH1_VALUE[33] == "0" ? 
					(iextendC_THRESH1_VALUE[34] == "0" ? (iextendC_THRESH1_VALUE[35] == "0" ? 
					(iextendC_THRESH1_VALUE[36] == "0" ? (iextendC_THRESH1_VALUE[37] == "0" ? 
					(iextendC_THRESH1_VALUE[38] == "0" ? (iextendC_THRESH1_VALUE[39] == "0" ? 
					(iextendC_THRESH1_VALUE[40] == "0" ? (iextendC_THRESH1_VALUE[41] == "0" ? 
					(iextendC_THRESH1_VALUE[42] == "0" ? (iextendC_THRESH1_VALUE[43] == "0" ? 
					(iextendC_THRESH1_VALUE[44] == "0" ? (iextendC_THRESH1_VALUE[45] == "0" ? 
					(iextendC_THRESH1_VALUE[46] == "0" ? (iextendC_THRESH1_VALUE[47] == "0" ? 
					(iextendC_THRESH1_VALUE[48] == "0" ? (iextendC_THRESH1_VALUE[49] == "0" ? 
					(iextendC_THRESH1_VALUE[50] == "0" ? (iextendC_THRESH1_VALUE[51] == "0" ? 
					(iextendC_THRESH1_VALUE[52] == "0" ? (iextendC_THRESH1_VALUE[53] == "0" ? 
					(iextendC_THRESH1_VALUE[54] == "0" ? (iextendC_THRESH1_VALUE[55] == "0" ? 
					(iextendC_THRESH1_VALUE[56] == "0" ? (iextendC_THRESH1_VALUE[57] == "0" ? 
					(iextendC_THRESH1_VALUE[58] == "0" ? (iextendC_THRESH1_VALUE[59] == "0" ? 
					(iextendC_THRESH1_VALUE[60] == "0" ? (iextendC_THRESH1_VALUE[61] == "0" ? 
					(iextendC_THRESH1_VALUE[62] == "0" ? (iextendC_THRESH1_VALUE[63] == "0" ? 0
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0)) : (C_HAS_SCLR == 1 ? 1 : 0))
					: (C_HAS_SCLR == 1 ? 1 : 0));
	
	
	
			

	input CLK;
	input UP;
	input CE;
	input LOAD;
	input [C_WIDTH-1 : 0] L;
	input [C_WIDTH-1 : 0] IV;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	output THRESH0;
	output Q_THRESH0;
	output THRESH1;
	output Q_THRESH1;
	output [C_WIDTH-1 : 0] Q;
	 
	// Internal values to drive signals when input is missing
	wire intUP;
	wire intUPbar = ~intUP;
	wire intCE;
	wire intLOAD;
	wire [C_WIDTH-1 : 0] intL;
	wire [C_WIDTH-1 : 0] intB;
	wire [C_WIDTH-1 : 0] all_zeros = {C_WIDTH{1'b0}};
	wire intSCLR;
	wire intCount_to_reached;
	reg intTHRESH0;
	reg intTHRESH1;
	wire intQ_THRESH0;
	wire intQ_THRESH1;
	wire [C_WIDTH-1 : 0] intFBq;
	wire [C_WIDTH-1 : 0] intFBs;
	wire [C_WIDTH-1 : 0] intQ = intFBq;
	wire [C_WIDTH-1 : 0] intFBq_or_zero;
	wire [C_WIDTH-1 : 0] intFBs_or_q;
	wire [C_WIDTH-1 : 0] intCount_by = to_bits(C_COUNT_BY);
	wire [C_WIDTH-1 : 0] intB_or_load;
	wire [C_WIDTH-1 : 0] tmpintB_or_load;
	
	wire Q_THRESH0 = (C_HAS_Q_THRESH0 == 1 ? intQ_THRESH0 : 1'bx);
	wire Q_THRESH1 = (C_HAS_Q_THRESH1 == 1 ? intQ_THRESH1 : 1'bx);
	wire [C_WIDTH-1 : 0] Q = intQ;
	
	wire [C_WIDTH-1 : 0] intXLOADMUX;
	wire [C_WIDTH-1 : 0] intSINITVAL = to_bits(C_SINIT_VAL);
	wire [C_WIDTH-1 : 0] intXL;
	wire intXLOAD;
	wire intXXLOAD;
	wire #5 intSCLR_RESET = (intSCLR || (intCount_to_reached && intCE && C_RESTRICT_COUNT == 1)) && ~intXXLOAD;
	wire #5 intSCLR_RESET_for_thresh = intSCLR; //((intSCLR && intCE) || (intCount_to_reached && intCE && C_RESTRICT_COUNT == 1)) && ~intXXLOAD;

    wire intSCLR_for_th_to;
	wire ACLR_for_th_to;
	wire ASET_for_th_to;
	
	// Sort out default values for missing ports
	
	assign intUP = (C_HAS_UP == 1 ? UP : (C_COUNT_MODE == `c_up ? 1'b1 : 1'b0));
	assign intCE = defval(CE, C_HAS_CE, 1);
	assign intL = (C_HAS_L == 1 ? L : {C_WIDTH{1'b0}});
	assign intB = (C_HAS_IV == 1 ? IV : intCount_by);
	assign intXL = (C_RESTRICT_COUNT == 1 ? (C_HAS_SINIT == 1 ? (C_HAS_LOAD == 1 ? intXLOADMUX : intSINITVAL) : intL) : intL);
	assign intLOAD = (C_LOAD_LOW == 1 ? ~LOAD : LOAD );
	assign intXLOAD = (C_RESTRICT_COUNT == 1 ? (C_HAS_SINIT == 1 ? (C_HAS_LOAD == 1 ? (C_HAS_CE == 1 ? (C_SYNC_ENABLE != C_LOAD_ENABLE ? (C_SYNC_ENABLE == 0 ? (C_LOAD_LOW == 1 ? (((~SINIT) && (~CE)) || ((~SINIT) && LOAD && CE)) : (SINIT || (LOAD && CE))) : (C_LOAD_LOW == 1 ? ((LOAD && (~CE)) || ((~SINIT) && LOAD && CE)) : (LOAD || (SINIT && CE)))) : (C_LOAD_LOW == 1 ? LOAD && ~SINIT : LOAD || SINIT)) : (C_LOAD_LOW == 1 ? LOAD && ~SINIT : LOAD || SINIT)) : (C_LOAD_LOW ? ~SINIT : SINIT)) : (C_HAS_LOAD == 1 ? LOAD : 1'b0)) : (C_HAS_LOAD == 1 ? LOAD : 1'b0));
	assign intXXLOAD = (C_RESTRICT_COUNT == 1 ? (C_HAS_SINIT == 1 ? (C_HAS_LOAD == 1 ? (C_LOAD_LOW == 1 ? ~intXLOAD : intXLOAD) : (C_LOAD_LOW == 1 ? ~intXLOAD : intXLOAD)) : (C_HAS_LOAD == 1 ? intLOAD : 1'b0)) : (C_HAS_LOAD == 1 ? intLOAD : 1'b0));
	assign intSCLR = defval(SCLR, C_HAS_SCLR, 0);
	assign intB_or_load = (C_HAS_LOAD == 1 ? tmpintB_or_load : (C_RESTRICT_COUNT == 1 ? (C_HAS_SINIT == 1 ? tmpintB_or_load : intB) : intB));
	assign intFBs_or_q = (C_THRESH_EARLY == 1 ? intFBs : intFBq);

    assign intSCLR_for_th_to = ((C_HAS_SCLR == 1 && C_HAS_SSET == 1) ? (SCLR | SSET) :
	                            (C_HAS_SCLR == 1 && C_HAS_SSET == 0) ? SCLR :
								(C_HAS_SCLR == 0 && C_HAS_SSET == 1) ? SSET :
								0);
    assign ACLR_for_th_to = ((C_HAS_ACLR == 1 && (C_HAS_AINIT == 1 && C_COUNT_TO != C_AINIT_VAL)) 
                          ? (ACLR | AINIT) 
	                      : ((C_HAS_AINIT == 1 && C_COUNT_TO != C_AINIT_VAL) 
						  ? AINIT 
						  : (C_HAS_ACLR == 1 ? ACLR : 0)));
	assign ASET_for_th_to = ((C_HAS_AINIT == 1 && C_COUNT_TO == C_AINIT_VAL) 
                          ? AINIT 
	                      : 0);
	
	
	// The addsub on which this is based...
	
	C_ADDSUB_V6_0 #(C_COUNT_MODE, 
					C_AINIT_VAL, 
					C_OUT_TYPE, 
					C_WIDTH, 
					(((~(C_HAS_LOAD===1)) || C_LOAD_ENABLE) && (C_SYNC_ENABLE || ~(C_RESTRICT_COUNT && C_HAS_SINIT))),
					C_LOAD_LOW,	// DLUNN CHANGED FROM 0, 
					0, 
					C_OUT_TYPE, 
					"0000000000000000", 
					C_WIDTH, 
					C_ENABLE_RLOCS, 
					C_HAS_ACLR, 
					C_HAS_UP, 
					C_HAS_AINIT, 
					C_HAS_ASET,
					0, 
					C_HAS_LOAD || (C_RESTRICT_COUNT == 1 && C_HAS_SINIT == 1),	// DLUNN CHANGED FROM 1, 
					0,
                    0, 
					0, 
					0, 
					C_HAS_CE, 
					1, 
					0, 
					0, 
					1, 
					0, 
					0, 
					0, 
					1, 
					adder_HAS_SCLR,
					C_HAS_SINIT && ~(C_RESTRICT_COUNT === 1), 
					C_HAS_SSET, 
					C_WIDTH-1,
			                1,
					0, 
					C_WIDTH,
					C_PIPE_STAGES, 
					C_SINIT_VAL, 
					C_SYNC_ENABLE, 
					C_SYNC_PRIORITY)
		the_addsub (.A(intFBq_or_zero), .B(intB_or_load), .CLK(CLK), .ADD(intUP),
					.C_IN(intUPbar), .B_IN(), .CE(CE), .BYPASS(intXLOAD),
					.ACLR(ACLR), .ASET(ASET), .AINIT(AINIT),
					.SCLR(intSCLR_RESET), .SSET(SSET), .SINIT(SINIT),
					.A_SIGNED(), .B_SIGNED(), .OVFL(), .C_OUT(), .B_OUT(),
					.Q_OVFL(), .Q_C_OUT(), .Q_B_OUT(),
					.S(intFBs), .Q(intFBq)); 
					
	// The Restrict Count/Sinit LOAD mux
	
	C_MUX_BUS_V6_0 #("", C_ENABLE_RLOCS, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 
					 0, 0, 1, "", 0, 0, C_WIDTH)
			mxRCSL(.MA(intSINITVAL), .MB(intL), .MC(), .MD(), .ME(), .MF(), .MG(), .MH(),
				   .MAA(), .MAB(), .MAC(), .MAD(), .MAE(), .MAF(), .MAG(), .MAH(),
				   .MBA(), .MBB(), .MBC(), .MBD(), .MBE(), .MBF(), .MBG(), .MBH(),
				   .MCA(), .MCB(), .MCC(), .MCD(), .MCE(), .MCF(), .MCG(), .MCH(),
			       .S(intLOAD), .CLK(), .CE(), .EN(), .ACLR(), .ASET(), .AINIT(),
				   .SCLR(), .SSET(), .SINIT(),
			       .O(intXLOADMUX), .Q());
			  
	// The feedback mux
	
	C_MUX_BUS_V6_0 #("", C_ENABLE_RLOCS, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 
					 0, 0, 1, "", 0, 0, C_WIDTH)
			mxfb(.MA(intFBq), .MB(all_zeros), .MC(), .MD(), .ME(), .MF(), .MG(), .MH(),
				 .MAA(), .MAB(), .MAC(), .MAD(), .MAE(), .MAF(), .MAG(), .MAH(),
				 .MBA(), .MBB(), .MBC(), .MBD(), .MBE(), .MBF(), .MBG(), .MBH(),
				 .MCA(), .MCB(), .MCC(), .MCD(), .MCE(), .MCF(), .MCG(), .MCH(),
			     .S(intXXLOAD), .CLK(), .CE(), .EN(), .ACLR(), .ASET(), .AINIT(),
				 .SCLR(), .SSET(), .SINIT(),
			     .O(intFBq_or_zero), .Q());
			
	// The LOAD mux
	
	C_MUX_BUS_V6_0 #("", C_ENABLE_RLOCS, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 
					 0, 0, 1, "", 0, 0, C_WIDTH)
			mx1(.MA(intB), .MB(intXL), .MC(), .MD(), .ME(), .MF(), .MG(), .MH(),
				.MAA(), .MAB(), .MAC(), .MAD(), .MAE(), .MAF(), .MAG(), .MAH(),
				.MBA(), .MBB(), .MBC(), .MBD(), .MBE(), .MBF(), .MBG(), .MBH(),
				.MCA(), .MCB(), .MCC(), .MCD(), .MCE(), .MCF(), .MCG(), .MCH(),
			    .S(intXXLOAD), .CLK(), .CE(), .EN(), .ACLR(), .ASET(), .AINIT(),
				 .SCLR(), .SSET(), .SINIT(),
			    .O(tmpintB_or_load), .Q());
			  
	// The Threshhold comparators
	
	C_COMPARE_V6_0 #("0", 1, C_THRESH0_VALUE, C_OUT_TYPE, C_ENABLE_RLOCS, C_HAS_ACLR, 0, 
					 C_HAS_THRESH0, 0, 0, 0, 0, 0, C_HAS_CE, C_HAS_Q_THRESH0,
					 0, 0, 0, 0, 0, intC_HAS_SCLR0, 0, 0, 1, 0, C_WIDTH)
			th0(.A(intFBs_or_q), .B(), .CLK(CLK), .CE(CE), 
			    .ACLR(ACLR), .ASET(),
			    .SCLR(intSCLR_RESET_for_thresh), .SSET(),
  			    .A_EQ_B(THRESH0), .A_NE_B(), .A_LT_B(), .A_GT_B(), .A_LE_B(), .A_GE_B(),
  			    .QA_EQ_B(Q_THRESH0), .QA_NE_B(), .QA_LT_B(), .QA_GT_B(), .QA_LE_B(), .QA_GE_B());
				
	C_COMPARE_V6_0 #("0", 1, C_THRESH1_VALUE, C_OUT_TYPE, C_ENABLE_RLOCS, C_HAS_ACLR, 0, 
					 C_HAS_THRESH1, 0, 0, 0, 0, 0, C_HAS_CE, C_HAS_Q_THRESH1,
					 0, 0, 0, 0, 0, intC_HAS_SCLR1, 0, 0, 1, 0, C_WIDTH)
			th1(.A(intFBs_or_q), .B(), .CLK(CLK), .CE(CE), 
			    .ACLR(ACLR), .ASET(),
			    .SCLR(intSCLR_RESET_for_thresh), .SSET(),
			    .A_EQ_B(THRESH1), .A_NE_B(), .A_LT_B(), .A_GT_B(), .A_LE_B(), .A_GE_B(),
			    .QA_EQ_B(Q_THRESH1), .QA_NE_B(), .QA_LT_B(), .QA_GT_B(), .QA_LE_B(), .QA_GE_B());
				
	C_COMPARE_V6_0 #("0", 1, C_COUNT_TO, C_OUT_TYPE, C_ENABLE_RLOCS, TH_TO_HAS_ACLR, TH_TO_HAS_ASET, 
					 0, 0, 0, 0, 0, 0, C_HAS_CE, 1,
					 0, 0, 0, 0, 0, TH_TO_HAS_SCLR, 0, 0, C_SYNC_ENABLE, 0, C_WIDTH)
			th_to(.A(intFBs), .B(), .CLK(CLK), .CE(CE), 
			.ACLR(ACLR_for_th_to), .ASET(ASET_for_th_to),
			.SCLR(intSCLR_for_th_to), .SSET(),
			.A_EQ_B(), .A_NE_B(), .A_LT_B(), .A_GT_B(), .A_LE_B(), .A_GE_B(),
			.QA_EQ_B(intCount_to_reached), .QA_NE_B(), .QA_LT_B(), .QA_GT_B(), .QA_LE_B(), .QA_GE_B());
				
	initial 
	begin
	
		#1;
	
	
	end
	
	function defval;
	input i;
	input hassig;
	input val;
		begin
			if(hassig == 1)
				defval = i;
			else
				defval = val;
		end
	endfunction
	
	function [C_WIDTH - 1 : 0] to_bits;
	input [C_WIDTH*8 : 1] instring;
	integer i;
	begin
		for(i = C_WIDTH; i > 0; i = i - 1)
		begin // Is this character a '0'? (ASCII = 48 = 00110000)
			if(instring[(i*8)] == 0 && 
				instring[(i*8)-1] == 0 && 
				instring[(i*8)-2] == 1 && 
				instring[(i*8)-3] == 1 && 
				instring[(i*8)-4] == 0 && 
				instring[(i*8)-5] == 0 && 
				instring[(i*8)-6] == 0 && 
				instring[(i*8)-7] == 0)
					to_bits[i-1] = 0;
			  // Or is it a '1'? 
			else if(instring[(i*8)] == 0 && 
				instring[(i*8)-1] == 0 && 
				instring[(i*8)-2] == 1 && 
				instring[(i*8)-3] == 1 && 
				instring[(i*8)-4] == 0 && 
				instring[(i*8)-5] == 0 && 
				instring[(i*8)-6] == 0 && 
				instring[(i*8)-7] == 1)

					to_bits[i-1] = 1;
				  // Or is it a ' '? (a null char - in which case insert a '0')
				else if(instring[(i*8)] == 0 && 
					instring[(i*8)-1] == 0 && 
					instring[(i*8)-2] == 0 && 
					instring[(i*8)-3] == 0 && 
					instring[(i*8)-4] == 0 && 
					instring[(i*8)-5] == 0 && 
					instring[(i*8)-6] == 0 && 
					instring[(i*8)-7] == 0)		
						to_bits[i-1] = 0;
			else 
			begin
				$display("Error in %m at time %d ns : non-binary digit in string \"%s\"\nExiting simulation...", $time, instring);
				$finish;
			end
		end 
	end
	endfunction


	
endmodule

`undef c_set
`undef c_clear
`undef c_override
`undef c_no_override
`undef c_signed
`undef c_unsigned
`undef c_pin
`undef c_up
`undef c_down
`undef c_updown
`undef allXs
