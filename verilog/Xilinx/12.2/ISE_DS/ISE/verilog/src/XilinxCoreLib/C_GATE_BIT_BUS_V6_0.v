// Copyright(C) 2002 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.


/* $Id: C_GATE_BIT_BUS_V6_0.v,v 1.16 2008/09/08 20:06:04 akennedy Exp $
--
-- Filename - C_GATE_BIT_BUS_V6_0.v
-- Author - Xilinx
-- Creation - 25 Jan 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_GATE_BIT_BUS_V6_0 module
*/

`timescale 1ns/10ps

`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1
`define c_and 0
`define c_nand 1
`define c_or 2
`define c_nor 3
`define c_xor 4
`define c_xnor 5

module C_GATE_BIT_BUS_V6_0 (I, CTRL, CLK, CE, ACLR, ASET, AINIT, SCLR, SSET, SINIT, O, Q);

	parameter C_AINIT_VAL 		= "";
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_GATE_TYPE 		= `c_and;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_CE 			= 0;
	parameter C_HAS_O 			= 0;
	parameter C_HAS_Q 			= 1;
	parameter C_HAS_SCLR 		= 0;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 0;
	parameter C_INPUT_INV_MASK 	= "";
	parameter C_SINIT_VAL 		= "";
	parameter C_SYNC_ENABLE 	= `c_override;	
	parameter C_SYNC_PRIORITY 	= `c_clear;		
	parameter C_WIDTH 			= 16; 			
	

	input [C_WIDTH-1 : 0] I;
	input CTRL;
	input CLK;
	input CE;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	output [C_WIDTH-1 : 0] O;
	output [C_WIDTH-1 : 0] Q;
	 
	reg [C_WIDTH-1 : 0] intO;
	wire [C_WIDTH-1 : 0] intQ;
	
	wire [C_WIDTH-1 : 0] Q = (C_HAS_Q == 1 ? intQ : {C_WIDTH{1'bx}});
	wire [C_WIDTH-1 : 0] O = (C_HAS_O == 1 ? intO : {C_WIDTH{1'bx}});
	
	
	integer j;
	
	reg [C_WIDTH-1 : 0] tmpsig;
	reg [C_WIDTH-1 : 0] tmpres;
	
	// Output register
	C_REG_FD_V6_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, C_WIDTH)
		reg1 (.D(intO), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(intQ)); 

	initial 
	begin
		#1;
		
		tmpsig = to_bits(C_INPUT_INV_MASK);
		if(CTRL === 1'bx)
		begin
			for(j = 0; j < C_WIDTH; j = j + 1)
			begin
				if(tmpsig[j] == 1) // Inversion of input bit
				begin
					if(C_GATE_TYPE == 0) // AND gate
					begin
						if(I[j] === 1'b1)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 1) // NAND gate
					begin
						if(I[j] === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 2) // OR gate
					begin
						if(I[j] === 1'b0)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 3) // NOR gate
					begin
						if(I[j] === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 4) // XOR gate
						tmpres[j] = 1'bx;
					else if(C_GATE_TYPE == 5) // XNOR gate
						tmpres[j] = 1'bx;
				end
				else // No input inversion on bit j of input	
				begin
					if(C_GATE_TYPE == 0) // AND gate
					begin
						if(I[j] === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 1) // NAND gate
					begin
						if(I[j] === 1'b0)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 2) // OR gate
					begin
						if(I[j] === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 3) // NOR gate
					begin
						if(I[j] === 1'b1)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 4) // XOR gate
						tmpres[j] = 1'bx;
					else if(C_GATE_TYPE == 5) // XNOR gate
						tmpres[j] = 1'bx;
				end
			end
		end
		else // CTRL is not unknown
		begin
			for(j = 0; j < C_WIDTH; j = j + 1)
			begin
				if(tmpsig[j] == 1)
				begin
					if(C_GATE_TYPE == 0) // AND gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL & ~I[j];
						else if(CTRL === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 1) // NAND gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL & ~I[j]);
						else if(CTRL === 1'b0)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 2) // OR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL | ~I[j];
						else if(CTRL === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 3) // NOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL | ~I[j]);
						else if(CTRL === 1'b1)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 4) // XOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL ^ ~I[j];
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 5) // XNOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL ^ ~I[j]);
						else
							tmpres[j] = 1'bx;
					end
				end
				else // No input inversion on bit j of input	
				begin
					if(C_GATE_TYPE == 0) // AND gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL & I[j];
						else if(CTRL === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 1) // NAND gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL & I[j]);
						else if(CTRL === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 2) // OR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL | I[j];
						else if(CTRL === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 3) // NOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL | I[j]);
						else if(CTRL === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 4) // XOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL ^ I[j];
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 5) // XNOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL ^ I[j]);
						else
							tmpres[j] = 1'bx;
					end
				end
			end
		end
					
		intO <= tmpres;
	end
	
	always@(I or CTRL) 
	begin
		
		if(CTRL === 1'bx)
		begin
			for(j = 0; j < C_WIDTH; j = j + 1)
			begin
				if(tmpsig[j] == 1) // Inversion of input bit
				begin
					if(C_GATE_TYPE == 0) // AND gate
					begin
						if(I[j] === 1'b1)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 1) // NAND gate
					begin
						if(I[j] === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 2) // OR gate
					begin
						if(I[j] === 1'b0)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 3) // NOR gate
					begin
						if(I[j] === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 4) // XOR gate
						tmpres[j] = 1'bx;
					else if(C_GATE_TYPE == 5) // XNOR gate
						tmpres[j] = 1'bx;
				end
				else // No input inversion on bit j of input	
				begin
					if(C_GATE_TYPE == 0) // AND gate
					begin
						if(I[j] === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 1) // NAND gate
					begin
						if(I[j] === 1'b0)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 2) // OR gate
					begin
						if(I[j] === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 3) // NOR gate
					begin
						if(I[j] === 1'b1)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 4) // XOR gate
						tmpres[j] = 1'bx;
					else if(C_GATE_TYPE == 5) // XNOR gate
						tmpres[j] = 1'bx;
				end
			end
		end
		else // CTRL is not unknown
		begin
			for(j = 0; j < C_WIDTH; j = j + 1)
			begin
				if(tmpsig[j] == 1)
				begin
					if(C_GATE_TYPE == 0) // AND gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL & ~I[j];
						else if(CTRL === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 1) // NAND gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL & ~I[j]);
						else if(CTRL === 1'b0)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 2) // OR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL | ~I[j];
						else if(CTRL === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 3) // NOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL | ~I[j]);
						else if(CTRL === 1'b1)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 4) // XOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL ^ ~I[j];
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 5) // XNOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL ^ ~I[j]);
						else
							tmpres[j] = 1'bx;
					end
				end
				else // No input inversion on bit j of input	
				begin
					if(C_GATE_TYPE == 0) // AND gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL & I[j];
						else if(CTRL === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 1) // NAND gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL & I[j]);
						else if(CTRL === 1'b0)
							tmpres[j] = 1'b0;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 2) // OR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL | I[j];
						else if(CTRL === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 3) // NOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL | I[j]);
						else if(CTRL === 1'b1)
							tmpres[j] = 1'b1;
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 4) // XOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = CTRL ^ I[j];
						else
							tmpres[j] = 1'bx;
					end
					else if(C_GATE_TYPE == 5) // XNOR gate
					begin
						if(I[j] !== 1'bx)
							tmpres[j] = ~(CTRL ^ I[j]);
						else
							tmpres[j] = 1'bx;
					end
				end
			end
		end
					
		intO <= #1 tmpres;
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
				$display("Error in %m at time %d ns: non-binary digit in string \"%s\"\nExiting simulation...", $time, instring);
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
`undef c_and
`undef c_nand
`undef c_or
`undef c_nor
`undef c_xor
`undef c_xnor


