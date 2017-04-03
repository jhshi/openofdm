// Copyright(C) 2002 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.


/* $Id: C_DECODE_BINARY_V6_0.v,v 1.16 2008/09/08 20:06:04 akennedy Exp $
--
-- Filename - C_DECODE_BINARY_V6_0.v
-- Author - Xilinx
-- Creation - 21 May 1999
--
-- Description - This file contains the Verilog behavior for the baseblocks C_DECODE_BINARY_V6_0 module
*/

`timescale 1ns/10ps

`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1

`define alldb1s {C_OUT_WIDTH{1'b1}}
`define all0s 'b0
`define alldbXs {C_OUT_WIDTH{1'bx}}

module C_DECODE_BINARY_V6_0 (CLK, EN, CE, S, ACLR, ASET, AINIT, SCLR, SSET, SINIT, O, Q);

	parameter C_AINIT_VAL 		= "";
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_CE 			= 0;
	parameter C_HAS_EN			= 0;
	parameter C_HAS_O			= 0;
	parameter C_HAS_Q			= 1;
	parameter C_HAS_SCLR 		= 0;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 0;
	parameter C_HEIGHT          = 0;
	parameter C_OUT_HIGH		= 1;
	parameter C_OUT_WIDTH 		= 8;
	parameter C_PIPE_STAGES		= 1;
	parameter C_SEL_WIDTH		= 3;
	parameter C_SINIT_VAL 		= "";
	parameter C_SYNC_ENABLE 	= `c_override;	
	parameter C_SYNC_PRIORITY 	= `c_clear;	
	
	input [C_SEL_WIDTH-1 : 0] S;
	input CLK;
	input CE;
	input EN;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	output [C_OUT_WIDTH-1 : 0] O;
	output [C_OUT_WIDTH-1 : 0] Q;
	 
	reg [C_OUT_WIDTH-1 : 0] data;
	// Internal values to drive signals when input is missing
	wire intCE;
	wire intEN;
	wire intACLR;
	wire intASET;
	wire intAINIT;
	wire intSCLR;
	wire intSSET;
	wire intSINIT;
	reg [C_OUT_WIDTH-1 : 0] intO;
	reg [C_OUT_WIDTH-1 : 0] tmpO;
	wire [C_OUT_WIDTH-1 : 0] intQ;
	 
	reg [C_OUT_WIDTH-1 : 0] intQpipe [C_PIPE_STAGES+2 : 0];
	reg [C_OUT_WIDTH-1 : 0] intQpipeend;
	reg [C_OUT_WIDTH : 0] tmp_pipe1;
	reg [C_OUT_WIDTH : 0] tmp_pipe2;

	wire [C_OUT_WIDTH-1 : 0] Q = (C_HAS_Q == 1 ? intQ : `alldbXs);
	wire [C_OUT_WIDTH-1 : 0] O = (C_HAS_O == 1 ? intO : `alldbXs);
	reg lastCLK;

	// Sort out default values for missing ports
	
	assign intCE = defval(CE, C_HAS_CE, 1);
	assign intEN = defval(EN, C_HAS_EN, 1);

	integer i, j, k;
	integer m, unknown;
	integer pipe, pipe1;
	
	// Register on output by default
	C_REG_FD_V6_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, C_OUT_WIDTH)
		reg1 (.D(intQpipeend), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(intQ)); 

	initial 
	begin
		for(j = 0; j <= C_PIPE_STAGES - 1; j = j + 1)
			intQpipe[j] = 'b0;
		i = 0;
		k = 1;
		unknown = 0;

		for(j = 0; j < C_SEL_WIDTH; j = j + 1)
		begin
			if(S[j] === 1'b1)
				i = i + k;
			else if(S[j] === 1'bx || S[j] === 1'bz)
				unknown = 1;
			k = k * 2;	
		end
		
		if(unknown == 1 && intEN === 1'b1)
			tmpO = `alldbXs;
		else if(C_OUT_HIGH === 1'b1)
		begin
			tmpO = `all0s;	
			tmpO[i] = intEN;
		end
		else if(C_OUT_HIGH === 1'b0)
		begin
			tmpO = `alldb1s;
			tmpO[i] = ~(intEN);
		end
		else // C_OUT_HIGH unknown
			tmpO = `alldbXs;

		intO <= #1 tmpO;
		
		if(C_PIPE_STAGES < 2) // No pipeline
			intQpipeend = intO;
		else // Pipeline stages required
		begin
			intQpipeend = intQpipe[2];
		end
	end

	always @(CLK)
  		lastCLK <= CLK;

	always@(S or intEN)
	begin
		i = 0;
		k = 1;
		unknown = 0;

		for(j = 0; j < C_SEL_WIDTH; j = j + 1)
		begin
			if(S[j] === 1'b1)
				i = i + k;
			else if(S[j] === 1'bx || S[j] === 1'bz)
				unknown = 1;
			k = k * 2;	
		end
		
		if(unknown == 1 && intEN === 1'b1)
			tmpO = `alldbXs;
		else if(C_OUT_HIGH === 1'b1)
		begin
			tmpO = `all0s;	
			tmpO[i] = intEN;
		end
		else if(C_OUT_HIGH === 1'b0)
		begin
			tmpO = `alldb1s;
			tmpO[i] = ~(intEN);
		end
		else // C_OUT_HIGH unknown
			tmpO = `alldbXs;

		intO <= #1 tmpO;
	end		


	always@(posedge CLK)
	begin
		if(CLK === 1'b1 && lastCLK === 1'b0 && intCE === 1'b1) // OK! Update pipelines!
		begin
			for(pipe = 2; pipe <= C_PIPE_STAGES-1; pipe = pipe + 1)
			begin
				intQpipe[pipe] <= intQpipe[pipe+1];
			end
			intQpipe[C_PIPE_STAGES] <= intO;
		end
		else if((CLK === 1'bx && lastCLK === 1'b0) || (CLK === 1'b1 && lastCLK === 1'bx) || intCE === 1'bx) // POSSIBLY Update pipelines!
		begin
			for(pipe = 2; pipe <= C_PIPE_STAGES-1; pipe = pipe + 1)
			begin
				tmp_pipe1 = intQpipe[pipe];
				tmp_pipe2 = intQpipe[pipe+1];
				for(pipe1 = 0; pipe1 < C_OUT_WIDTH; pipe1 = pipe1 + 1)
				begin
					if(tmp_pipe1[pipe1] !== tmp_pipe2[pipe1])
						tmp_pipe1[pipe1] = 1'bx;
				end
				intQpipe[pipe] <= tmp_pipe1;
			end
			tmp_pipe1 = intQpipe[C_PIPE_STAGES];
			for(pipe1 = 0; pipe1 < C_OUT_WIDTH; pipe1 = pipe1 + 1)
			begin
				if(tmp_pipe1[pipe1] !== intO[pipe1])
					tmp_pipe1[pipe1] = 1'bx;
			end
			intQpipe[C_PIPE_STAGES] <= tmp_pipe1;
		end
	end
	
	always@(intO or intQpipe[2])
	begin
		if(C_PIPE_STAGES < 2) // No pipeline
			intQpipeend <= intO;
		else // Pipeline stages required
		begin
			intQpipeend <= intQpipe[2];
		end
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

`undef alldb1s
`undef all0s
`undef alldbXs

