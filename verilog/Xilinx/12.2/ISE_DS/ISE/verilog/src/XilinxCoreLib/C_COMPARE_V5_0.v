/* $Id: C_COMPARE_V5_0.v,v 1.17 2008/09/08 20:05:55 akennedy Exp $
--
-- Filename - C_COMPARE_V5_0.v
-- Author - Xilinx
-- Creation - 28 Jan 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_COMPARE_V5_0 module
*/

`timescale 1ns/10ps

`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1
`define c_signed 0
`define c_unsigned 1

module C_COMPARE_V5_0 (A, B, CLK, CE, ACLR, ASET, SCLR, SSET,
				  A_EQ_B, A_NE_B, A_LT_B, A_GT_B, A_LE_B, A_GE_B,
				  QA_EQ_B, QA_NE_B, QA_LT_B, QA_GT_B, QA_LE_B, QA_GE_B);

	parameter C_AINIT_VAL 		= ""; 
	parameter C_B_CONSTANT 		= 0; 
	parameter C_B_VALUE 		= "";   
	parameter C_DATA_TYPE 		= `c_unsigned;
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_A_EQ_B 		= 1;
	parameter C_HAS_A_GE_B 		= 0;
	parameter C_HAS_A_GT_B 		= 0;
	parameter C_HAS_A_LE_B 		= 0;
	parameter C_HAS_A_LT_B 		= 0;
	parameter C_HAS_A_NE_B 		= 0;
	parameter C_HAS_CE 			= 0;
	parameter C_HAS_QA_EQ_B 	= 0;
	parameter C_HAS_QA_GE_B 	= 0;
	parameter C_HAS_QA_GT_B 	= 0;
	parameter C_HAS_QA_LE_B 	= 0;
	parameter C_HAS_QA_LT_B 	= 0;
	parameter C_HAS_QA_NE_B 	= 0;
	parameter C_HAS_SCLR 		= 0;
	parameter C_HAS_SSET 		= 0;
	parameter C_PIPE_STAGES		= 1;
	parameter C_SYNC_ENABLE 	= `c_override;	
	parameter C_SYNC_PRIORITY 	= `c_clear;	
	parameter C_WIDTH 			= 16; 					
	

	input [C_WIDTH-1 : 0] A;
	input [C_WIDTH-1 : 0] B;
	input CLK;
	input CE;
	input ACLR;
	input ASET;
	input SCLR;
	input SSET;
	output A_EQ_B;
	output A_NE_B;
	output A_LT_B;
	output A_GT_B;
	output A_LE_B;
	output A_GE_B;
	output QA_EQ_B;
	output QA_NE_B;
	output QA_LT_B;
	output QA_GT_B;
	output QA_LE_B;
	output QA_GE_B;
	 
	// Internal values to drive signals when input is missing
	reg [C_WIDTH-1 : 0] intB;
	reg intCE;
	reg intACLR;
	reg intASET;
	reg intSCLR;
	reg intSSET;
	reg intA_EQ_B;
	reg intA_NE_B;
	reg intA_LT_B;
	reg intA_GT_B;
	reg intA_LE_B;
	reg intA_GE_B;
	wire intQA_EQ_B;
	wire intQA_NE_B;
	wire intQA_LT_B;
	wire intQA_GT_B;
	wire intQA_LE_B;
	wire intQA_GE_B;
	reg lastCLK;
		 
	reg [C_PIPE_STAGES+2 : 0] intQA_EQ_Bpipe;
	reg intQA_EQ_Bpipeend;
	reg [C_PIPE_STAGES+2 : 0] intQA_NE_Bpipe;
	reg intQA_NE_Bpipeend;
	reg [C_PIPE_STAGES+2 : 0] intQA_LT_Bpipe;
	reg intQA_LT_Bpipeend;
	reg [C_PIPE_STAGES+2 : 0] intQA_GT_Bpipe;
	reg intQA_GT_Bpipeend;
	reg [C_PIPE_STAGES+2 : 0] intQA_LE_Bpipe;
	reg intQA_LE_Bpipeend;
	reg [C_PIPE_STAGES+2 : 0] intQA_GE_Bpipe;
	reg intQA_GE_Bpipeend;
	 
	wire AINIT;
	wire SINIT;

	wire A_EQ_B = (C_HAS_A_EQ_B == 1 ? intA_EQ_B : 1'bx);
	wire A_NE_B = (C_HAS_A_NE_B == 1 ? intA_NE_B : 1'bx);
	wire A_LT_B = (C_HAS_A_LT_B == 1 ? intA_LT_B : 1'bx);
	wire A_GT_B = (C_HAS_A_GT_B == 1 ? intA_GT_B : 1'bx);
	wire A_LE_B = (C_HAS_A_LE_B == 1 ? intA_LE_B : 1'bx);
	wire A_GE_B = (C_HAS_A_GE_B == 1 ? intA_GE_B : 1'bx);
	wire QA_EQ_B = (C_HAS_QA_EQ_B == 1 ? intQA_EQ_B : 1'bx);
	wire QA_NE_B = (C_HAS_QA_NE_B == 1 ? intQA_NE_B : 1'bx);
	wire QA_LT_B = (C_HAS_QA_LT_B == 1 ? intQA_LT_B : 1'bx);
	wire QA_GT_B = (C_HAS_QA_GT_B == 1 ? intQA_GT_B : 1'bx);
	wire QA_LE_B = (C_HAS_QA_LE_B == 1 ? intQA_LE_B : 1'bx);
	wire QA_GE_B = (C_HAS_QA_GE_B == 1 ? intQA_GE_B : 1'bx);
	
	integer pipe, notdone, i;
		
	reg aeqb, aneb, altb, agtb, aleb, ageb;
	reg [C_WIDTH-1:0] a_low;
	reg [C_WIDTH-1:0] a_high;
	reg [C_WIDTH-1:0] b_low;
	reg [C_WIDTH-1:0] b_high;
		
	// Instance the required output regs
		C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, 0, C_HAS_ASET,
				   C_HAS_CE, C_HAS_SCLR, 0, C_HAS_SSET,
				   "0", C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
			regaeqb (.D(intQA_EQ_Bpipeend), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
				  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
				  .Q(intQA_EQ_B)); 

		C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, 0, C_HAS_ASET,
				   C_HAS_CE, C_HAS_SCLR, 0, C_HAS_SSET,
				   "0", C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
			reganeb (.D(intQA_NE_Bpipeend), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
				  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
				  .Q(intQA_NE_B)); 

		C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, 0, C_HAS_ASET,
				   C_HAS_CE, C_HAS_SCLR, 0, C_HAS_SSET,
				   "0", C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
			regaltb (.D(intQA_LT_Bpipeend), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
				  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
				  .Q(intQA_LT_B)); 

		C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, 0, C_HAS_ASET,
				   C_HAS_CE, C_HAS_SCLR, 0, C_HAS_SSET,
				   "0", C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
			regagtb (.D(intQA_GT_Bpipeend), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
				  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
				  .Q(intQA_GT_B)); 

		C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, 0, C_HAS_ASET,
				   C_HAS_CE, C_HAS_SCLR, 0, C_HAS_SSET,
				   "0", C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
			regaleb (.D(intQA_LE_Bpipeend), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
				  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
				  .Q(intQA_LE_B)); 

		C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, 0, C_HAS_ASET,
				   C_HAS_CE, C_HAS_SCLR, 0, C_HAS_SSET,
				   "0", C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
			regageb (.D(intQA_GE_Bpipeend), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
				  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
				  .Q(intQA_GE_B)); 

	initial 
	begin
		#1;
		intCE = defval(CE, C_HAS_CE, 1);
		intB = defvecval(B, (C_B_CONSTANT == 1) ? 0 : 1, to_bits(C_B_VALUE));
		
		intQA_EQ_Bpipe = 'b0;
		intQA_NE_Bpipe = 'b0;
		intQA_LT_Bpipe = 'b0;
		intQA_GT_Bpipe = 'b0;
		intQA_LE_Bpipe = 'b0;
		intQA_GE_Bpipe = 'b0;
		
		if(is_X(A) == 1 || is_X(intB) == 1)
		begin
			notdone = 1;
			if((is_X(A) && A === {C_WIDTH{1'bx}}) && (is_X(intB) && intB === {C_WIDTH{1'bx}}))
			begin
				aeqb <= 1'bx;
				aneb <= 1'bx;
				altb <= 1'bx;
				agtb <= 1'bx;
				aleb <= 1'bx;
				ageb <= 1'bx;
				notdone = 0;
			end
			else if(C_DATA_TYPE == `c_signed)
			begin
/*				if(A[C_WIDTH-1] === 1'bx && intB[C_WIDTH-1] === 1'bx)
				// Don't know the sign of EITHER data => ALL X's
				begin
					aeqb <= 1'bx;
					aneb <= 1'bx;
					altb <= 1'bx;
					agtb <= 1'bx;
					aleb <= 1'bx;
					ageb <= 1'bx;
					notdone = 0;
				end
				else if (A[C_WIDTH-1] !== 1'bx && intB[C_WIDTH-1] !== 1'bx)
*/				if (A[C_WIDTH-1] !== 1'bx && intB[C_WIDTH-1] !== 1'bx)
				begin 
				// The sign bits are both known
					if (A[C_WIDTH-1] !== intB[C_WIDTH-1])
					begin
					// different signs!
						if (A[C_WIDTH-1] === 1'b1)
						begin 
						// A is negative and B is positive
							aeqb <= 0;
							aneb <= 1;
							altb <= 1;
							agtb <= 0;
							aleb <= 1;
							ageb <= 0;
							notdone = 0;
						end 
						else // A is +ve and B is -ve
						begin 
							aeqb <= 0;
							aneb <= 1;
							altb <= 0;
							agtb <= 1;
							aleb <= 0;
							ageb <= 1;
							notdone = 0;
						end 
					end
				end
			end
		    if (notdone == 1) // check further	
			begin		
			// Make copies of A and B with all X's substituted with 0's and 1's
				a_low = A;
				a_high = A;
				b_low = intB;
				b_high = intB;
				for (i=C_WIDTH-2; i >= 0; i = i - 1)
				begin
					if (a_low[i] === 1'bx)
					begin 
						a_low[i] = 0;
						a_high[i] = 1;
					end
					if (b_low[i] === 1'bx)
					begin 
						b_low[i] = 0;
						b_high[i] = 1;
					end
				end 
				// we now (almost - need to check possible sign bits) have worst-case values which must agree on the comparison result 
				// if that result is not to be unknown...
				if (C_DATA_TYPE == `c_signed)
				begin
					// Set the sign bits of the range values to 0 since
					// the sign of the values will be treated separately
					a_low[C_WIDTH-1] = 0;
					a_high[C_WIDTH-1] = 0;
					b_low[C_WIDTH-1] = 0;
					b_high[C_WIDTH-1] = 0;
					
					if((A[C_WIDTH-1] === 1'b1 && intB[C_WIDTH-1] === 1'bx) 
							|| (intB[C_WIDTH-1] === 1'b0 && A[C_WIDTH-1] === 1'bx)) 
					begin // Sign of A is -ve and sign of B is unknown OR
						  // sign of B is +ve and sign of A is unknown
						// Is A always < B?
						if (a_high < b_low)
						begin
						// A is definitely < than B
							aeqb <= 0;
							aneb <= 1;
							altb <= 1;
							agtb <= 0;
							aleb <= 1;
							ageb <= 0;
						end
						else if (a_high == b_low)
						begin
						// A is <= than B
							aeqb <= 1'bx;
							aneb <= 1'bx;
							altb <= 1'bx;
							agtb <= 0;
							aleb <= 1;
							ageb <= 1'bx;
						end
						else if (a_low != b_low && a_low !== b_high && a_high !== b_low && a_high !== b_high && !(intB === {C_WIDTH{1'bx}} || A === {C_WIDTH{1'bx}}))
						begin // Definitely not equal!
							aeqb <= 1'b0;
							aneb <= 1'b1;
							altb <= 1'bx;
							agtb <= 1'bx;
							aleb <= 1'bx;
							ageb <= 1'bx;
						end
						else // There is > 1 overlap between the ranges so all X's
						begin
							aeqb <= 1'bx;
							aneb <= 1'bx;
							altb <= 1'bx;
							agtb <= 1'bx;
							aleb <= 1'bx;
							ageb <= 1'bx;
						end
					end
					else if((A[C_WIDTH-1] === 1'b0 && intB[C_WIDTH-1] === 1'bx)
							|| (intB[C_WIDTH-1] === 1'b1 && A[C_WIDTH-1] === 1'bx))
					begin // Sign of A is +ve and sign of B is unknown OR
						  // sign of B is -ve and sign of A is unknown
						// Is B always < A?
						if (b_high < a_low)
						begin
						// B is definitely < than A
							aeqb <= 0;
							aneb <= 1;
							altb <= 0;
							agtb <= 1;
							aleb <= 0;
							ageb <= 1;
						end
						else if (b_high == a_low)
						begin
						// B is <= than A
							aeqb <= 1'bx;
							aneb <= 1'bx;
							altb <= 0;
							agtb <= 1'bx;
							aleb <= 1'bx;
							ageb <= 1;
						end
						else if (a_low != b_low && a_low !== b_high && a_high !== b_low && a_high !== b_high && !(intB === {C_WIDTH{1'bx}} || A === {C_WIDTH{1'bx}}))
						begin // Definitely not equal!
							aeqb <= 1'b0;
							aneb <= 1'b1;
							altb <= 1'bx;
							agtb <= 1'bx;
							aleb <= 1'bx;
							ageb <= 1'bx;
						end
						else // There is > 1 overlap between the ranges so all X's
						begin
							aeqb <= 1'bx;
							aneb <= 1'bx;
							altb <= 1'bx;
							agtb <= 1'bx;
							aleb <= 1'bx;
							ageb <= 1'bx;
						end
					end
					else // Sign bits on A and B are identical and both are known
					begin
						if (a_high < b_low)
						begin
						// A is definitely < than B
							aeqb <= 0;
							aneb <= 1;
							altb <= 1;
							agtb <= 0;
							aleb <= 1;
							ageb <= 0;
						end
						else if (a_low > b_high)
						begin
						// A is definitely > than B
							aeqb <= 0;
							aneb <= 1;
							altb <= 0;
							agtb <= 1;
							aleb <= 0;
							ageb <= 1;
						end
						else if (a_high == b_low)
						begin
						// A is <= than B
							aeqb <= 1'bx;
							aneb <= 1'bx;
							altb <= 1'bx;
							agtb <= 0;
							aleb <= 1;
							ageb <= 1'bx;
						end
						else if (a_low == b_high)
						begin
						// A is >= than B
							aeqb <= 1'bx;
							aneb <= 1'bx;
							altb <= 0;
							agtb <= 1'bx;
							aleb <= 1'bx;
							ageb <= 1;
						end
						else if (a_low != b_low && a_low !== b_high && a_high !== b_low && a_high !== b_high && !(intB === {C_WIDTH{1'bx}} || A === {C_WIDTH{1'bx}}))
						begin // Definitely not equal!
							aeqb <= 1'b0;
							aneb <= 1'b1;
							altb <= 1'bx;
							agtb <= 1'bx;
							aleb <= 1'bx;
							ageb <= 1'bx;
						end
						else // There is > 1 overlap between the ranges so all X's
						begin
							aeqb <= 1'bx;
							aneb <= 1'bx;
							altb <= 1'bx;
							agtb <= 1'bx;
							aleb <= 1'bx;
							ageb <= 1'bx;
						end
					end
				end
				else // unsigned data
				begin
					if (a_low[C_WIDTH-1] === 1'bx)
					begin
						a_low[C_WIDTH-1] = 0;
						a_high[C_WIDTH-1] = 1;
					end
					if (b_low[C_WIDTH-1] === 1'bx)
					begin
						b_low[C_WIDTH-1] = 0;
						b_high[C_WIDTH-1] = 1;
					end
					if (a_high < b_low)
					begin
					// A is definitely < than B
						aeqb <= 0;
						aneb <= 1;
						altb <= 1;
						agtb <= 0;
						aleb <= 1;
						ageb <= 0;
					end
					else if (a_low > b_high)
					begin
					// A is definitely > than B	
						aeqb <= 0;
						aneb <= 1;
						altb <= 0;
						agtb <= 1;
						aleb <= 0;
						ageb <= 1;
					end
					else if (a_high == b_low)
					begin
					// A is <= B
						aeqb <= 1'bx;
						aneb <= 1'bx;
						altb <= 1'bx;
						agtb <= 0;
						aleb <= 1;
						ageb <= 1'bx;
					end
					else if (a_low == b_high)
					begin
					// A is >= B
						aeqb <= 1'bx;
						aneb <= 1'bx;
						altb <= 0;
						agtb <= 1'bx;
						aleb <= 1'bx;
						ageb <= 1;
					end
						else if (a_low != b_low && a_low !== b_high && a_high !== b_low && a_high !== b_high && !(intB === {C_WIDTH{1'bx}} || A === {C_WIDTH{1'bx}}))
						begin // Definitely not equal!
							aeqb <= 1'b0;
							aneb <= 1'b1;
							altb <= 1'bx;
							agtb <= 1'bx;
							aleb <= 1'bx;
							ageb <= 1'bx;
						end
					else // There is > 1 overlap between the ranges so all X's
					begin
						aeqb <= 1'bx;
						aneb <= 1'bx;
						altb <= 1'bx;
						agtb <= 1'bx;
						aleb <= 1'bx;
						ageb <= 1'bx;
					end
				end
			end				
		end
		else if (C_DATA_TYPE == `c_signed)
		begin
			// Signed data so examine MSB and rest separately in some cases
			if(A == intB)
			begin
				aeqb <= 1;
				aneb <= 0;
				altb <= 0;
				agtb <= 0;
			end
			else if(A[C_WIDTH-1] == intB[C_WIDTH-1]) // Both numbers are -ve or both are +ve
			begin
				if(A < intB) 
				begin
					aeqb <= 0;
					aneb <= 1;
					altb <= 1;
					agtb <= 0;
				end
				if(A > intB)
				begin
					aeqb <= 0;
					aneb <= 1;
					altb <= 0;
					agtb <= 1;
				end
			end
			else if(A[C_WIDTH-1] == 1 && intB[C_WIDTH-1] == 0) // A is -ve, B is +ve
			begin
				aeqb <= 0;
				aneb <= 1;
				altb <= 1;
				agtb <= 0;
			end
			else if(A[C_WIDTH-1] == 0 && intB[C_WIDTH-1] == 1) // A is +ve, B is -ve
			begin
				aeqb <= 0;
				aneb <= 1;
				altb <= 0;
				agtb <= 1;
			end
			if(aeqb == 1 || altb == 1)
				aleb <= 1;
			else 
				aleb <= 0;
			if(aeqb == 1 || agtb == 1)
				ageb <= 1;
			else 
				ageb <= 0;
		end
		else // Data is unsigned
		begin
			if(A == intB)
			begin
				aeqb <= 1;
				aneb <= 0;
				altb <= 0;
				agtb <= 0;
			end
			if(A < intB)
			begin
				aeqb <= 0;
				aneb <= 1;
				altb <= 1;
				agtb <= 0;
			end
			if(A > intB)
			begin
				aeqb <= 0;
				aneb <= 1;
				altb <= 0;
				agtb <= 1;
			end
			if(aeqb == 1 || altb == 1)
				aleb <= 1;
			else 
				aleb <= 0;
			if(aeqb == 1 || agtb == 1)
				ageb <= 1;
			else 
				ageb <= 0;
		end
		
		intA_EQ_B <= #1 aeqb;
		intA_NE_B <= #1 aneb;
		intA_LT_B <= #1 altb;
		intA_GT_B <= #1 agtb;
		intA_LE_B <= #1 aleb;
		intA_GE_B <= #1 ageb;

	end
	
	always @(CLK)
  		lastCLK <= CLK;
 
	always @(A or B or CE or ACLR or ASET or SCLR or SSET) 
	begin
		intCE = defval(CE, C_HAS_CE, 1);
		intB = defvecval(B, (C_B_CONSTANT == 1) ? 0 : 1, to_bits(C_B_VALUE));
	
		if(is_X(A) == 1 || is_X(intB) == 1)
		begin
			notdone = 1;
			if((is_X(A) && A === {C_WIDTH{1'bx}}) && (is_X(intB) && intB === {C_WIDTH{1'bx}}))
			begin
				aeqb = 1'bx;
				aneb = 1'bx;
				altb = 1'bx;
				agtb = 1'bx;
				aleb = 1'bx;
				ageb = 1'bx;
				notdone = 0;
			end
			else if(C_DATA_TYPE == `c_signed)
			begin
/*				if(A[C_WIDTH-1] === 1'bx && intB[C_WIDTH-1] === 1'bx)
				// Don't know the sign of EITHER data => ALL X's
				begin
					aeqb = 1'bx;
					aneb = 1'bx;
					altb = 1'bx;
					agtb = 1'bx;
					aleb = 1'bx;
					ageb = 1'bx;
					notdone = 0;
				end
				else if (A[C_WIDTH-1] !== 1'bx && intB[C_WIDTH-1] !== 1'bx)
*/				if (A[C_WIDTH-1] !== 1'bx && intB[C_WIDTH-1] !== 1'bx)
				begin 
				// The sign bits are both known
					if (A[C_WIDTH-1] !== intB[C_WIDTH-1])
					begin
					// different signs!
						if (A[C_WIDTH-1] === 1'b1)
						begin 
						// A is negative and B is positive
							aeqb = 0;
							aneb = 1;
							altb = 1;
							agtb = 0;
							aleb = 1;
							ageb = 0;
							notdone = 0;
						end 
						else // A is +ve and B is -ve
						begin 
							aeqb = 0;
							aneb = 1;
							altb = 0;
							agtb = 1;
							aleb = 0;
							ageb = 1;
							notdone = 0;
						end 
					end
				end
			end
		    if (notdone == 1) // check further	
			begin		
			// Make copies of A and B with all X's substituted with 0's and 1's
				a_low = A;
				a_high = A;
				b_low = intB;
				b_high = intB;
				for (i=C_WIDTH-2; i >= 0; i = i - 1)
				begin
					if (a_low[i] === 1'bx)
					begin 
						a_low[i] = 0;
						a_high[i] = 1;
					end
					if (b_low[i] === 1'bx)
					begin 
						b_low[i] = 0;
						b_high[i] = 1;
					end
				end 
				// we now (almost - need to check possible sign bits) have worst-case values which must agree on the comparison result 
				// if that result is not to be unknown...
				if (C_DATA_TYPE == `c_signed)
				begin
					// Set the sign bits of the range values to 0 since
					// the sign of the values will be treated separately
					a_low[C_WIDTH-1] = 0;
					a_high[C_WIDTH-1] = 0;
					b_low[C_WIDTH-1] = 0;
					b_high[C_WIDTH-1] = 0;
					
					if((A[C_WIDTH-1] === 1'b1 && intB[C_WIDTH-1] === 1'bx) 
							|| (intB[C_WIDTH-1] === 1'b0 && A[C_WIDTH-1] === 1'bx)) 
					begin // Sign of A is -ve and sign of B is unknown OR
						  // sign of B is +ve and sign of A is unknown
						// Is A always < B?
						if (a_high < b_low)
						begin
						// A is definitely < than B
							aeqb = 0;
							aneb = 1;
							altb = 1;
							agtb = 0;
							aleb = 1;
							ageb = 0;
						end
						else if (a_high == b_low)
						begin
						// A is <= than B
							aeqb = 1'bx;
							aneb = 1'bx;
							altb = 1'bx;
							agtb = 0;
							aleb = 1;
							ageb = 1'bx;
						end
						else if (a_low != b_low && a_low !== b_high && a_high !== b_low && a_high !== b_high && !(intB === {C_WIDTH{1'bx}} || A === {C_WIDTH{1'bx}}))
						begin // Definitely not equal!
							aeqb = 1'b0;
							aneb = 1'b1;
							altb = 1'bx;
							agtb = 1'bx;
							aleb = 1'bx;
							ageb = 1'bx;
						end
						else // There is > 1 overlap between the ranges so all X's
						begin
							aeqb = 1'bx;
							aneb = 1'bx;
							altb = 1'bx;
							agtb = 1'bx;
							aleb = 1'bx;
							ageb = 1'bx;
						end
					end
					else if((A[C_WIDTH-1] === 1'b0 && intB[C_WIDTH-1] === 1'bx)
							|| (intB[C_WIDTH-1] === 1'b1 && A[C_WIDTH-1] === 1'bx))
					begin // Sign of A is +ve and sign of B is unknown OR
						  // sign of B is -ve and sign of A is unknown
						// Is B always < A?
						if (b_high < a_low)
						begin
						// B is definitely < than A
							aeqb = 0;
							aneb = 1;
							altb = 0;
							agtb = 1;
							aleb = 0;
							ageb = 1;
						end
						else if (b_high == a_low)
						begin
						// B is <= than A
							aeqb = 1'bx;
							aneb = 1'bx;
							altb = 0;
							agtb = 1'bx;
							aleb = 1'bx;
							ageb = 1;
						end
						else if (a_low != b_low && a_low !== b_high && a_high !== b_low && a_high !== b_high && !(intB === {C_WIDTH{1'bx}} || A === {C_WIDTH{1'bx}}))
						begin // Definitely not equal!
							aeqb = 1'b0;
							aneb = 1'b1;
							altb = 1'bx;
							agtb = 1'bx;
							aleb = 1'bx;
							ageb = 1'bx;
						end
						else // There is > 1 overlap between the ranges so all X's
						begin
							aeqb = 1'bx;
							aneb = 1'bx;
							altb = 1'bx;
							agtb = 1'bx;
							aleb = 1'bx;
							ageb = 1'bx;
						end
					end
					else // Sign bits on A and B are identical and both are known
					begin
						if (a_high < b_low)
						begin
						// A is definitely < than B
							aeqb = 0;
							aneb = 1;
							altb = 1;
							agtb = 0;
							aleb = 1;
							ageb = 0;
						end
						else if (a_low > b_high)
						begin
						// A is definitely > than B
							aeqb = 0;
							aneb = 1;
							altb = 0;
							agtb = 1;
							aleb = 0;
							ageb = 1;
						end
						else if (a_high == b_low)
						begin
						// A is <= than B
							aeqb = 1'bx;
							aneb = 1'bx;
							altb = 1'bx;
							agtb = 0;
							aleb = 1;
							ageb = 1'bx;
						end
						else if (a_low == b_high)
						begin
						// A is >= than B
							aeqb = 1'bx;
							aneb = 1'bx;
							altb = 0;
							agtb = 1'bx;
							aleb = 1'bx;
							ageb = 1;
						end
						else if (a_low != b_low && a_low !== b_high && a_high !== b_low && a_high !== b_high && !(intB === {C_WIDTH{1'bx}} || A === {C_WIDTH{1'bx}}))
						begin // Definitely not equal!
							aeqb = 1'b0;
							aneb = 1'b1;
							altb = 1'bx;
							agtb = 1'bx;
							aleb = 1'bx;
							ageb = 1'bx;
						end
						else // There is > 1 overlap between the ranges so all X's
						begin
							aeqb = 1'bx;
							aneb = 1'bx;
							altb = 1'bx;
							agtb = 1'bx;
							aleb = 1'bx;
							ageb = 1'bx;
						end
					end
				end
				else // unsigned data
				begin
					if (a_low[C_WIDTH-1] === 1'bx)
					begin
						a_low[C_WIDTH-1] = 0;
						a_high[C_WIDTH-1] = 1;
					end
					if (b_low[C_WIDTH-1] === 1'bx)
					begin
						b_low[C_WIDTH-1] = 0;
						b_high[C_WIDTH-1] = 1;
					end
					if (a_high < b_low)
					begin
					// A is definitely < than B
						aeqb = 0;
						aneb = 1;
						altb = 1;
						agtb = 0;
						aleb = 1;
						ageb = 0;
					end
					else if (a_low > b_high)
					begin
					// A is definitely > than B	
						aeqb = 0;
						aneb = 1;
						altb = 0;
						agtb = 1;
						aleb = 0;
						ageb = 1;
					end
					else if (a_high == b_low)
					begin
					// A is <= B
						aeqb = 1'bx;
						aneb = 1'bx;
						altb = 1'bx;
						agtb = 0;
						aleb = 1;
						ageb = 1'bx;
					end
					else if (a_low == b_high)
					begin
					// A is >= B
						aeqb = 1'bx;
						aneb = 1'bx;
						altb = 0;
						agtb = 1'bx;
						aleb = 1'bx;
						ageb = 1;
					end
						else if (a_low != b_low && a_low !== b_high && a_high !== b_low && a_high !== b_high && !(intB === {C_WIDTH{1'bx}} || A === {C_WIDTH{1'bx}}))
						begin // Definitely not equal!
							aeqb = 1'b0;
							aneb = 1'b1;
							altb = 1'bx;
							agtb = 1'bx;
							aleb = 1'bx;
							ageb = 1'bx;
						end
					else // There is > 1 overlap between the ranges so all X's
					begin
						aeqb = 1'bx;
						aneb = 1'bx;
						altb = 1'bx;
						agtb = 1'bx;
						aleb = 1'bx;
						ageb = 1'bx;
					end
				end
			end				
		end
		else if (C_DATA_TYPE == `c_signed)
		begin
			// Signed data so examine MSB and rest separately in some cases
			if(A == intB)
			begin
				aeqb = 1;
				aneb = 0;
				altb = 0;
				agtb = 0;
			end
			else if(A[C_WIDTH-1] == intB[C_WIDTH-1]) // Both numbers are -ve or both are +ve
			begin
				if(A < intB) 
				begin
					aeqb = 0;
					aneb = 1;
					altb = 1;
					agtb = 0;
				end
				if(A > intB)
				begin
					aeqb = 0;
					aneb = 1;
					altb = 0;
					agtb = 1;
				end
			end
			else if(A[C_WIDTH-1] == 1 && intB[C_WIDTH-1] == 0) // A is -ve, B is +ve
			begin
				aeqb = 0;
				aneb = 1;
				altb = 1;
				agtb = 0;
			end
			else if(A[C_WIDTH-1] == 0 && intB[C_WIDTH-1] == 1) // A is +ve, B is -ve
			begin
				aeqb = 0;
				aneb = 1;
				altb = 0;
				agtb = 1;
			end
			if(aeqb == 1 || altb == 1)
				aleb = 1;
			else 
				aleb = 0;
			if(aeqb == 1 || agtb == 1)
				ageb = 1;
			else 
				ageb = 0;
		end
		else // Data is unsigned
		begin
			if(A == intB)
			begin
				aeqb = 1;
				aneb = 0;
				altb = 0;
				agtb = 0;
			end
			if(A < intB)
			begin
				aeqb = 0;
				aneb = 1;
				altb = 1;
				agtb = 0;
			end
			if(A > intB)
			begin
				aeqb = 0;
				aneb = 1;
				altb = 0;
				agtb = 1;
			end
			if(aeqb == 1 || altb == 1)
				aleb = 1;
			else 
				aleb = 0;
			if(aeqb == 1 || agtb == 1)
				ageb = 1;
			else 
				ageb = 0;
		end
		
		intA_EQ_B <= #1 aeqb;
		intA_NE_B <= #1 aneb;
		intA_LT_B <= #1 altb;
		intA_GT_B <= #1 agtb;
		intA_LE_B <= #1 aleb;
		intA_GE_B <= #1 ageb;
	end
	
	always@(posedge CLK)
	begin
		if(CLK === 1'b1 && lastCLK === 1'b0 && intCE === 1'b1) // OK! Update pipelines!
		begin
			for(pipe = 2; pipe <= C_PIPE_STAGES-1; pipe = pipe + 1)
			begin
				intQA_EQ_Bpipe[pipe] <= intQA_EQ_Bpipe[pipe+1];
				intQA_NE_Bpipe[pipe] <= intQA_NE_Bpipe[pipe+1];
				intQA_LT_Bpipe[pipe] <= intQA_LT_Bpipe[pipe+1];
				intQA_GT_Bpipe[pipe] <= intQA_GT_Bpipe[pipe+1];
				intQA_LE_Bpipe[pipe] <= intQA_LE_Bpipe[pipe+1];
				intQA_GE_Bpipe[pipe] <= intQA_GE_Bpipe[pipe+1];
			end
			intQA_EQ_Bpipe[C_PIPE_STAGES] <= intA_EQ_B;
			intQA_NE_Bpipe[C_PIPE_STAGES] <= intA_NE_B;
			intQA_LT_Bpipe[C_PIPE_STAGES] <= intA_LT_B;
			intQA_GT_Bpipe[C_PIPE_STAGES] <= intA_GT_B;
			intQA_LE_Bpipe[C_PIPE_STAGES] <= intA_LE_B;
			intQA_GE_Bpipe[C_PIPE_STAGES] <= intA_GE_B;
		end
		else if((CLK === 1'bx && lastCLK === 1'b0) || (CLK === 1'b1 && lastCLK === 1'bx) || intCE === 1'bx) // POSSIBLY Update pipelines!
		begin
			for(pipe = 2; pipe <= C_PIPE_STAGES-1; pipe = pipe + 1)
			begin
				if(intQA_EQ_Bpipe[pipe] !== intQA_EQ_Bpipe[pipe+1])
					intQA_EQ_Bpipe[pipe] <= 1'bx;
				if(intQA_NE_Bpipe[pipe] !== intQA_NE_Bpipe[pipe+1])
					intQA_NE_Bpipe[pipe] <= 1'bx;
				if(intQA_LT_Bpipe[pipe] !== intQA_LT_Bpipe[pipe+1])
					intQA_LT_Bpipe[pipe] <= 1'bx;
				if(intQA_GT_Bpipe[pipe] !== intQA_GT_Bpipe[pipe+1])
					intQA_GT_Bpipe[pipe] <= 1'bx;
				if(intQA_LE_Bpipe[pipe] !== intQA_LE_Bpipe[pipe+1])
					intQA_LE_Bpipe[pipe] <= 1'bx;
				if(intQA_GE_Bpipe[pipe] !== intQA_GE_Bpipe[pipe+1])
					intQA_GE_Bpipe[pipe] <= 1'bx;
			end
			if(intQA_EQ_Bpipe[C_PIPE_STAGES] !== intA_EQ_B)
				intQA_EQ_Bpipe[C_PIPE_STAGES] <= 1'bx;
			if(intQA_NE_Bpipe[C_PIPE_STAGES] !== intA_NE_B)
				intQA_NE_Bpipe[C_PIPE_STAGES] <= 1'bx;
			if(intQA_LT_Bpipe[C_PIPE_STAGES] !== intA_LT_B)
				intQA_LT_Bpipe[C_PIPE_STAGES] <= 1'bx;
			if(intQA_GT_Bpipe[C_PIPE_STAGES] !== intA_GT_B)
				intQA_GT_Bpipe[C_PIPE_STAGES] <= 1'bx;
			if(intQA_LE_Bpipe[C_PIPE_STAGES] !== intA_LE_B)
				intQA_LE_Bpipe[C_PIPE_STAGES] <= 1'bx;
			if(intQA_GE_Bpipe[C_PIPE_STAGES] !== intA_GE_B)
				intQA_GE_Bpipe[C_PIPE_STAGES] <= 1'bx;
		end
	end
	
	always@(intA_EQ_B or intQA_EQ_Bpipe[2])
	begin
		if(C_PIPE_STAGES < 2) // No pipeline
			intQA_EQ_Bpipeend <= intA_EQ_B;
		else // Pipeline stages required
		begin
			intQA_EQ_Bpipeend <= intQA_EQ_Bpipe[2];
		end
	end
	always@(intA_NE_B or intQA_NE_Bpipe[2])
	begin
		if(C_PIPE_STAGES < 2) // No pipeline
			intQA_NE_Bpipeend <= intA_NE_B;
		else // Pipeline stages required
		begin
			intQA_NE_Bpipeend <= intQA_NE_Bpipe[2];
		end
	end
	always@(intA_LT_B or intQA_LT_Bpipe[2])
	begin
		if(C_PIPE_STAGES < 2) // No pipeline
			intQA_LT_Bpipeend <= intA_LT_B;
		else // Pipeline stages required
		begin
			intQA_LT_Bpipeend <= intQA_LT_Bpipe[2];
		end
	end
	always@(intA_GT_B or intQA_GT_Bpipe[2])
	begin
		if(C_PIPE_STAGES < 2) // No pipeline
			intQA_GT_Bpipeend <= intA_GT_B;
		else // Pipeline stages required
		begin
			intQA_GT_Bpipeend <= intQA_GT_Bpipe[2];
		end
	end
	always@(intA_LE_B or intQA_LE_Bpipe[2])
	begin
		if(C_PIPE_STAGES < 2) // No pipeline
			intQA_LE_Bpipeend <= intA_LE_B;
		else // Pipeline stages required
		begin
			intQA_LE_Bpipeend <= intQA_LE_Bpipe[2];
		end
	end
	always@(intA_GE_B or intQA_GE_Bpipe[2])
	begin
		if(C_PIPE_STAGES < 2) // No pipeline
			intQA_GE_Bpipeend <= intA_GE_B;
		else // Pipeline stages required
		begin
			intQA_GE_Bpipeend <= intQA_GE_Bpipe[2];
		end
	end

	function is_X;
	input [C_WIDTH-1 : 0] i;
	integer j;
		begin
			is_X = 0;
			for(j = 0; j < C_WIDTH; j = j + 1)
				if(i[j] === 1'bx)
					is_X = 1;
		end
	endfunction
	
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
	
	function [C_WIDTH - 1 : 0] defvecval;
	input [C_WIDTH-1 : 0] i;
	input hassig;
	input [C_WIDTH-1 : 0] val;
		begin
			if(hassig == 1)
				defvecval = i;
			else
				defvecval = val;
		end
	endfunction
	
	function [C_WIDTH - 1 : 0] to_bits;
	input [C_WIDTH*8 : 1] instring;
	integer i;
	integer non_null_string;
	begin
		non_null_string = 0;
		for(i = C_WIDTH; i > 0; i = i - 1)
		begin // Is the string empty?
			if(instring[(i*8)] == 0 && 
				instring[(i*8)-1] == 0 && 
				instring[(i*8)-2] == 0 && 
				instring[(i*8)-3] == 0 && 
				instring[(i*8)-4] == 0 && 
				instring[(i*8)-5] == 0 && 
				instring[(i*8)-6] == 0 && 
				instring[(i*8)-7] == 0 &&
				non_null_string == 0)
					non_null_string = 0; // Use the return value to flag a non-empty string
			else
					non_null_string = 1; // Non-null character!
		end
		if(non_null_string == 0) // String IS empty! Just return the value to be all '0's
		begin
			for(i = C_WIDTH; i > 0; i = i - 1)
				to_bits[i-1] = 0;
		end
		else
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
					$display("Error in  %m at time %d ns: non-binary digit in string \"%s\"\nExiting simulation...", $time, instring);
					$finish;
				end
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

