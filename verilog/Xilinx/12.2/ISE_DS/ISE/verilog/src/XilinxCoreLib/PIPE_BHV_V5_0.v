// Copyright(C) 2004 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.

// $Revision: 1.12 $ $Date: 2008/09/08 20:09:48 $

`timescale 1ns/10ps

`define allXs {C_WIDTH{1'bx}}
`define all1s {C_WIDTH{1'b1}}

module PIPE_BHV_V5_0 (D, CLK, CE, ACLR, SCLR, Q);
	
	parameter C_HAS_ACLR      = 0;
	parameter C_HAS_CE        = 0;
	parameter C_HAS_SCLR      = 1;
	parameter C_PIPE_STAGES   = 2;
	parameter C_WIDTH         = 16; 		
	
	
	input [C_WIDTH-1 : 0] D;
	input CLK;
	input CE;
	input ACLR;
	input SCLR;
	output [C_WIDTH-1 : 0] Q;
	
	reg [C_WIDTH-1 : 0] pipeliner [0 : C_PIPE_STAGES-1];
	reg [C_WIDTH-1 : 0] intQ;
	// Internal values to drive signals when input is missing
	wire intCE;
	wire intACLR;
	wire intSCLR;
	
	wire [C_WIDTH-1 : 0] #1 Q = intQ;
	
	// Sort out default values for missing ports
	
	assign intCE    = defval(CE,    C_HAS_CE,    1);
	assign intACLR  = defval(ACLR,  C_HAS_ACLR,  0);
	assign intSCLR  = defval(SCLR,  C_HAS_SCLR,  0);
	
	reg lastCLK;
	reg lastintACLR;
	
	integer i;
	
	initial 
		begin
			lastCLK     = 1'b0;
			lastintACLR = 1'b0;
			for(i = 0; i < C_PIPE_STAGES; i = i + 1)
				pipeliner[i] = 'b0;
			if(C_PIPE_STAGES != 0)
				begin
					if(C_HAS_ACLR === 1)
						pipeliner[C_PIPE_STAGES-1] = 'b0;
					else if(C_HAS_SCLR === 1)
						pipeliner[C_PIPE_STAGES-1] = 'b0;
					intQ = pipeliner[C_PIPE_STAGES-1];
				end
			else
				assign intQ = D;
		end
	
	always@(posedge CLK or intACLR)
		begin
			// Do not do anything if there is no pipeline
			if(C_PIPE_STAGES > 0)
				begin
					// deal with synchronous events first
					if (CLK !== lastCLK && CLK !== 1'bx && lastCLK !== 1'bx)
						begin
							// First the pipeline
							if(intCE === 1'bx)
								for(i = 0; i < C_PIPE_STAGES; i = i + 1)
									pipeliner[i] = `allXs;
							else if(intCE === 1'b1)
								for(i = C_PIPE_STAGES-1; i > 0; i = i - 1)
									pipeliner[i] = pipeliner[i-1];
							
							// Unqualified behaviour
							if(intCE === 1'b1)
								pipeliner[0] = D;
							
							// Synchronous controls
							if(intSCLR === 1'bx)
								pipeliner[0] = `allXs;
							else if(intSCLR === 1'b1) //Synchronous clear
								for(i = 0; i < C_PIPE_STAGES; i = i + 1)
									pipeliner[i] = 'b0;
						end
					else if(CLK !== lastCLK && (CLK === 1'bx || lastCLK === 1'bx))
						begin
							if(intCE !== 1'b0)
								for(i = 0; i < C_PIPE_STAGES; i = i + 1)
									pipeliner[i] = `allXs;
						end
					
					//Asynchronous Controls - over ride synchronous effects
					if(intACLR === 1'bx)
						pipeliner[C_PIPE_STAGES-1] = `allXs;
					else if(intACLR === 1'b1)
						for(i = 0; i < C_PIPE_STAGES; i = i + 1)
							pipeliner[i] = 'b0;
					
					intQ <= pipeliner[C_PIPE_STAGES-1];
				end
		end
	
	always@(intACLR)
		begin
			lastintACLR <= intACLR;
			
		end
	
	always@(CLK)
		lastCLK <= CLK;
	
	
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

`undef allXs 
`undef all1s


