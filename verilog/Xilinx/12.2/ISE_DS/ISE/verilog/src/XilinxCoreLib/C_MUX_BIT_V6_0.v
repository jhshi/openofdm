// Copyright(C) 2002 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.


/* $Id: C_MUX_BIT_V6_0.v,v 1.16 2008/09/08 20:06:04 akennedy Exp $
--
-- Filename - C_MUX_BIT_V6_0.v
-- Author - Xilinx
-- Creation - 21 Oct 1998
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_MUX_BIT_V6_0 module
*/

`timescale 1ns/10ps

`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1

module C_MUX_BIT_V6_0 (M, S, CLK, CE, ACLR, ASET, AINIT, SCLR, SSET, SINIT, O, Q);

	parameter C_AINIT_VAL 		= "";
	parameter C_ENABLE_RLOCS	= 1;
    parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_CE 	        = 0;
	parameter C_HAS_O 	        = 0;
	parameter C_HAS_Q           = 1;
	parameter C_HAS_SCLR 		= 0;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 0;
    parameter C_HEIGHT          = 0;   
	parameter C_INPUTS          = 2;
    parameter C_LATENCY         = 0;
	parameter C_PIPE_STAGES     = 0;
	parameter C_SEL_WIDTH 		= 1; 			
	parameter C_SINIT_VAL 		= "";
	parameter C_SYNC_ENABLE 	= `c_override;		
	parameter C_SYNC_PRIORITY 	= `c_clear;

        // Parameters used to drive additional registers for pipelining.

        parameter PIPE_HAS_ACLR = (C_LATENCY == 1 ? C_HAS_ACLR : 1'b0);
        parameter PIPE_HAS_AINIT = (C_LATENCY == 1 ? C_HAS_AINIT : 1'b0);
	    parameter PIPE_HAS_ASET = (C_LATENCY == 1 ? C_HAS_ASET : 1'b0);
        parameter PIPE_HAS_SSET = (C_LATENCY == 1 ? C_HAS_SSET : 1'b0);
        parameter PIPE_HAS_SINIT = (C_LATENCY == 1 ? C_HAS_SINIT : 1'b0);

        parameter PIPE2_HAS_ACLR = (C_LATENCY == 2 ? C_HAS_ACLR : 1'b0);
        parameter PIPE2_HAS_AINIT = (C_LATENCY == 2 ? C_HAS_AINIT : 1'b0);
	    parameter PIPE2_HAS_ASET = (C_LATENCY == 2 ? C_HAS_ASET : 1'b0);
        parameter PIPE2_HAS_SSET = (C_LATENCY == 2 ? C_HAS_SSET : 1'b0);
        parameter PIPE2_HAS_SINIT = (C_LATENCY == 2 ? C_HAS_SINIT : 1'b0);


	input [C_INPUTS-1 : 0] M;
	input [C_SEL_WIDTH-1 : 0] S;
	input CLK;
	input CE;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	output O;
	output Q;
	 
	// Internal values to drive signals when input is missing

	reg intO;
	reg intQ;
//	reg lastCLK;

        wire STAGE1;
        wire STAGE2;
        wire STAGE3;	
	 
	wire Q = (C_HAS_Q == 1 ? intQ : 1'bx);
	wire O = (C_HAS_O == 1 ? intO : 1'bx);
	
	// Sort out default values for missing ports		
	
	integer j, k;
	integer m, unknown;
	
	// Register on output by default 
	
	C_REG_FD_V6_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, PIPE_HAS_ACLR, PIPE_HAS_AINIT, PIPE_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, PIPE_HAS_SINIT, PIPE_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
		reg1 (.D(intO), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(STAGE1)); 			   
			  

	C_REG_FD_V6_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, PIPE2_HAS_ACLR, PIPE2_HAS_AINIT, PIPE2_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, PIPE2_HAS_SINIT, PIPE2_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
		reg2 (.D(STAGE1), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(STAGE2));       		   


	/* These two register could be used if full options were desired for internal
	pipelining registers...

		C_REG_FD_V6_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
		reg1 (.D(intO), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(STAGE1));

        C_REG_FD_V6_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
		reg2 (.D(STAGE1), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(STAGE2));		 */



        C_REG_FD_V6_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
		reg3 (.D(STAGE2), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(STAGE3));

	initial 
	begin

		#1;

		k = 1;
		m = 1; 
		unknown = 0;
		for(j = 0; j < C_SEL_WIDTH; j = j + 1)
		begin
			if(S[j] === 1)
				k = k + m;
			else if(S[j] === 1'bz || S[j] === 1'bx)
				unknown = 1;
			m = m * 2;
		end
		
		if(unknown == 1)
			intO <= 1'bx;
		else
			intO <= M[k-1];
			
	end
	
//	always @(CLK)
//  		lastCLK <= CLK;

	always@(M or S)
	begin
		k = 1;
		m = 1; 
		unknown = 0;
		for(j = 0; j < C_SEL_WIDTH; j = j + 1)
		begin
			if(S[j] === 1)
				k = k + m;
			else if(S[j] === 1'bz || S[j] === 1'bx)
				unknown = 1;
			m = m * 2;
		end
		
		if(unknown == 1)
			intO <= #1 1'bx;
		else
			intO <= #1 M[k-1];
	end


        // Register Output Settings
        always
        begin
           //------------------------------
           //-- REGISTER CLOCKED OUTPUTS --
           //------------------------------
              if (C_LATENCY === 1)
                 intQ = STAGE1;
              
              else if (C_LATENCY === 2)
                 intQ = STAGE2;
              
              else
                 intQ = STAGE3;

              @(STAGE1 or STAGE2 or STAGE3);
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
	
endmodule

`undef c_set
`undef c_clear
`undef c_override
`undef c_no_override
