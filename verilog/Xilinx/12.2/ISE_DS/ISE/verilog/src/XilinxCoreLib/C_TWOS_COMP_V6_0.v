// Copyright(C) 2002 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.


/* $Id: C_TWOS_COMP_V6_0.v,v 1.16 2008/09/08 20:06:05 akennedy Exp $
--
-- Filename - C_TWOS_COMP_V6_0.v
-- Author - Xilinx
-- Creation - 3 Feb 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_TWOS_COMP_V6_0 module
*/

`timescale 1ns/10ps

`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1

module C_TWOS_COMP_V6_0 (A, BYPASS, CLK, CE, ACLR, ASET, AINIT, SCLR, SSET, SINIT, S, Q);

	parameter C_AINIT_VAL 		= "";
	parameter C_BYPASS_ENABLE 	= `c_override;
	parameter C_BYPASS_LOW 		= 0;
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_BYPASS 		= 0;
	parameter C_HAS_CE 			= 0;
	parameter C_HAS_Q 			= 1;
	parameter C_HAS_S 			= 0;
	parameter C_HAS_SCLR 		= 0;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 0;
	parameter C_PIPE_STAGES 	= 0; 
	parameter C_SINIT_VAL 		= "";
	parameter C_SYNC_ENABLE 	= `c_override;	
	parameter C_SYNC_PRIORITY 	= `c_clear;		
	parameter C_WIDTH 			= 16; 			
	

	input [C_WIDTH-1 : 0] A;
	input BYPASS;
	input CLK;
	input CE;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	output [C_WIDTH : 0] S;
	output [C_WIDTH : 0] Q;
	 
	// Internal values to drive signals when input is missing
	wire intBYPASS;
	wire intCE;
	wire intQCE;
	reg [C_WIDTH : 0] intS;
	reg [C_WIDTH : 0] tmpS;
	wire [C_WIDTH : 0] intQ;
	reg lastCLK;
	
	reg [C_WIDTH : 0] intQpipe [C_PIPE_STAGES+2 : 0];
	reg [C_WIDTH : 0] intQpipeend;
	reg [C_WIDTH : 0] tmp_pipe1;
	reg [C_WIDTH : 0] tmp_pipe2;
	 
	wire [C_WIDTH : 0] Q = (C_HAS_Q == 1 ? intQ : {C_WIDTH{1'bx}});
	wire [C_WIDTH : 0] S = (C_HAS_S == 1 ? intS : {C_WIDTH{1'bx}});
	
	// Sort out default values for missing ports
	
	assign intBYPASS = (C_HAS_BYPASS === 1) ? ((C_BYPASS_LOW === 1) ? !BYPASS : BYPASS) : 0;
	assign intCE = defval(CE, C_HAS_CE, 1);
	assign intQCE = (C_HAS_CE === 1 ? (C_HAS_BYPASS === 1 ? (C_BYPASS_ENABLE === `c_override ? CE || intBYPASS : CE) : CE) : 1'b1);
	
	integer j;
	integer pipe, pipe1;
	
	// Register on output by default
	C_REG_FD_V6_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, C_WIDTH + 1)
		reg1 (.D(intQpipeend), .CLK(CLK), .CE(intQCE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(intQ)); 

	initial 
	begin
		#1;
		if(intBYPASS == 1)
		begin
			intS[C_WIDTH-1 : 0] = A;
			intS[C_WIDTH] = A[C_WIDTH-1];
		end
		else if(intBYPASS === 1'bx || is_X(A) == 1'bx)
			intS = 'bx;
		else
		begin
			tmpS[C_WIDTH-1 : 0] = ~A;
			tmpS[C_WIDTH] = ~A[C_WIDTH-1];
			intS = (tmpS + 1);
		end
		
			
		if(C_PIPE_STAGES < 2) // No pipeline
			intQpipeend = intS;
		else // Pipeline stages required
		begin
			intQpipeend = intQpipe[2];
		end
	end
	
	always @(CLK)
  		lastCLK <= CLK;

	always@(A or intBYPASS)
	begin
		if(intBYPASS == 1)
		begin
			intS[C_WIDTH-1 : 0] <= #1 A;
			intS[C_WIDTH] <= #1 A[C_WIDTH-1];
		end
		else if(intBYPASS === 1'bx || is_X(A) == 1'bx)
			intS <= #1 'bx;
		else
		begin
			tmpS[C_WIDTH-1 : 0] = ~A;
			tmpS[C_WIDTH] = ~A[C_WIDTH-1];
			intS <= #1 (tmpS + 1);
		end
	end
	
	always@(posedge CLK)
	begin
		if(CLK === 1'b1 && lastCLK === 1'b0 && intCE === 1'b1) // OK! Update pipelines!
		begin
			for(pipe = 2; pipe <= C_PIPE_STAGES-1; pipe = pipe + 1)
			begin
				intQpipe[pipe] <= intQpipe[pipe+1];
			end
			intQpipe[C_PIPE_STAGES] <= intS;
		end
		else if((CLK === 1'bx && lastCLK === 1'b0) || (CLK === 1'b1 && lastCLK === 1'bx) || intCE === 1'bx) // POSSIBLY Update pipelines!
		begin
			for(pipe = 2; pipe <= C_PIPE_STAGES-1; pipe = pipe + 1)
			begin
				tmp_pipe1 = intQpipe[pipe];
				tmp_pipe2 = intQpipe[pipe+1];
				for(pipe1 = 0; pipe1 < C_WIDTH; pipe1 = pipe1 + 1)
				begin
					if(tmp_pipe1[pipe1] !== tmp_pipe2[pipe1])
						tmp_pipe1[pipe1] = 1'bx;
				end
				intQpipe[pipe] <= tmp_pipe1;
			end
			tmp_pipe1 = intQpipe[C_PIPE_STAGES];
			for(pipe1 = 0; pipe1 < C_WIDTH; pipe1 = pipe1 + 1)
			begin
				if(tmp_pipe1[pipe1] !== intS[pipe1])
					tmp_pipe1[pipe1] = 1'bx;
			end
			intQpipe[C_PIPE_STAGES] <= tmp_pipe1;
		end
	end
	
	always@(intS or intQpipe[2])
	begin
		if(C_PIPE_STAGES < 2) // No pipeline
			intQpipeend <= intS;
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
	
	function is_X;
	input [C_WIDTH-1 : 0] i;
	begin
		is_X = 1'b0;
		for(j = 0; j < C_WIDTH; j = j + 1)
		begin
			if(i[j] === 1'bx) 
				is_X = 1'b1;
		end // loop
	end
	endfunction
	
endmodule

`undef c_set
`undef c_clear
`undef c_override
`undef c_no_override

