/* $Id: C_GATE_BUS_V5_0.v,v 1.17 2008/09/08 20:05:56 akennedy Exp $
--
-- Filename - C_GATE_BUS_V5_0.v
-- Author - Xilinx
-- Creation - 26 Jan 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_GATE_BUS_V5_0 module
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
`define c_inv 6
`define c_buf 7

module C_GATE_BUS_V5_0 (IA, IB, IC, ID, CLK, CE, ACLR, ASET, AINIT, SCLR, SSET, SINIT, O, Q);

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
	parameter C_INPUTS 			= 2; 	
	parameter C_INPUT_A_INV_MASK = "";
	parameter C_INPUT_B_INV_MASK = "";
	parameter C_INPUT_C_INV_MASK = "";
	parameter C_INPUT_D_INV_MASK = "";
	parameter C_SINIT_VAL 		= "";
	parameter C_SYNC_ENABLE 	= `c_override;
	parameter C_SYNC_PRIORITY 	= `c_clear;		
	parameter C_WIDTH 			= 16; 			
	

	input [C_WIDTH-1 : 0] IA;
	input [C_WIDTH-1 : 0] IB;
	input [C_WIDTH-1 : 0] IC;
	input [C_WIDTH-1 : 0] ID;
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
	 
	// Internal values to drive signals when input is missing
	reg [C_WIDTH-1 : 0] intIA;
	reg [C_WIDTH-1 : 0] intIB;
	reg [C_WIDTH-1 : 0] intIC;
	reg [C_WIDTH-1 : 0] intID;
	reg [C_WIDTH-1 : 0] intO;
	wire [C_WIDTH-1 : 0] intQ;
		 
	wire [C_WIDTH-1 : 0] Q = (C_HAS_Q == 1 ? intQ : {C_WIDTH{1'bx}});
	wire [C_WIDTH-1 : 0] O = (C_HAS_O == 1 ? intO : {C_WIDTH{1'bx}});
		
	
	integer j;
	
	reg [C_WIDTH-1 : 0] tmpres;
	
	// Output register
	C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, C_WIDTH)
		reg1 (.D(intO), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(intQ)); 

	initial 
	begin
	
		#1;
		
		if(C_INPUTS == 4) 
		begin
			intIA = IA ^ to_bits(C_INPUT_A_INV_MASK);
			intIB = IB ^ to_bits(C_INPUT_B_INV_MASK);
			intIC = IC ^ to_bits(C_INPUT_C_INV_MASK);
			intID = ID ^ to_bits(C_INPUT_D_INV_MASK);
		end
		else if(C_INPUTS == 3)
		begin
			intIA = IA ^ to_bits(C_INPUT_A_INV_MASK);
			intIB = IB ^ to_bits(C_INPUT_B_INV_MASK);
			intIC = IC ^ to_bits(C_INPUT_C_INV_MASK);
			if(C_GATE_TYPE == 0 || C_GATE_TYPE == 1) // AND or NAND gate!
				intID = {C_WIDTH{1'b1}};
			else
					intID = 'b0;
		end
		else if(C_INPUTS == 2)
		begin
			intIA = IA ^ to_bits(C_INPUT_A_INV_MASK);
			intIB = IB ^ to_bits(C_INPUT_B_INV_MASK);
			if(C_GATE_TYPE == 0 || C_GATE_TYPE == 1) // AND or NAND gate!
			begin
				intIC = {C_WIDTH{1'b1}};
				intID = {C_WIDTH{1'b1}};
			end
			else
			begin
				intIC = 'b0;
				intID = 'b0;
			end
		end	
		else // inv or buf gates
		begin
			intID = {C_WIDTH{1'b0}};
			intIC = {C_WIDTH{1'b0}};
			intIB = {C_WIDTH{1'b0}};
			intIA = IA;
		end
					
		for(j = 0; j < C_WIDTH; j = j + 1)
		begin
			if(intIA[j] === 1'bx || intIB[j] === 1'bx || intIC[j] === 1'bx || intID[j] === 1'bx)
			begin // Unknown's on at least one input
				if(C_GATE_TYPE == 0) // AND gate
				begin
					if(intIA[j] === 1'b0 || intIB[j] === 1'b0 || intIC[j] === 1'b0 || intID[j] === 1'b0)
						tmpres[j] = 1'b0;
					else
						tmpres[j] = 1'bx;
				end
				else if(C_GATE_TYPE == 1) // NAND gate
				begin
					if(intIA[j] === 1'b0 || intIB[j] === 1'b0 || intIC[j] === 1'b0 || intID[j] === 1'b0)
						tmpres[j] = 1'b1;
					else
						tmpres[j] = 1'bx;
				end
				else if(C_GATE_TYPE == 2) // OR gate
				begin
					if(intIA[j] === 1'b1 || intIB[j] === 1'b1 || intIC[j] === 1'b1 || intID[j] === 1'b1)
						tmpres[j] = 1'b1;
					else
						tmpres[j] = 1'bx;
				end
				else if(C_GATE_TYPE == 3) // NOR gate
				begin
					if(intIA[j] === 1'b1 || intIB[j] === 1'b1 || intIC[j] === 1'b1 || intID[j] === 1'b1)
						tmpres[j] = 1'b0;
					else
						tmpres[j] = 1'bx;
				end
				else if(C_GATE_TYPE > 3) // other gate
					tmpres[j] = 1'bx;
			end
			else
			begin // No unknowns in inputs
				if(C_GATE_TYPE == 0) // AND gate
					tmpres[j] = intIA[j] && intIB[j] && intIC[j] && intID[j];
				else if(C_GATE_TYPE == 1) // NAND gate
					tmpres[j] = ~(intIA[j] && intIB[j] && intIC[j] && intID[j]);
				else if(C_GATE_TYPE == 2) // OR gate
					tmpres[j] = intIA[j] || intIB[j] || intIC[j] || intID[j];
				else if(C_GATE_TYPE == 3) // NOR gate
					tmpres[j] = ~(intIA[j] || intIB[j] || intIC[j] || intID[j]);
				else if(C_GATE_TYPE == 4) // XOR gate
					tmpres[j] = intIA[j] ^ intIB[j] ^ intIC[j] ^ intID[j];
				else if(C_GATE_TYPE == 5) // XNOR gate
					tmpres[j] = ~(intIA[j] ^ intIB[j] ^ intIC[j] ^ intID[j]);
				else if(C_GATE_TYPE == 6) // INV gate
					tmpres[j] = ~(intIA[j]);
				else if(C_GATE_TYPE == 7) // BUF gate
					tmpres[j] = intIA[j];
			end
		end
		
		intO <= tmpres;
	end
	
	always@(IA or IB or IC or ID) 
	begin
		if(C_INPUTS == 4) 
		begin
			intIA = IA ^ to_bits(C_INPUT_A_INV_MASK);
			intIB = IB ^ to_bits(C_INPUT_B_INV_MASK);
			intIC = IC ^ to_bits(C_INPUT_C_INV_MASK);
			intID = ID ^ to_bits(C_INPUT_D_INV_MASK);
		end
		else if(C_INPUTS == 3)
		begin
			intIA = IA ^ to_bits(C_INPUT_A_INV_MASK);
			intIB = IB ^ to_bits(C_INPUT_B_INV_MASK);
			intIC = IC ^ to_bits(C_INPUT_C_INV_MASK);
			if(C_GATE_TYPE == 0 || C_GATE_TYPE == 1) // AND or NAND gate!
				intID = {C_WIDTH{1'b1}};
			else
				intID = 'b0;
		end
		else if(C_INPUTS == 2)
		begin
			intIA = IA ^ to_bits(C_INPUT_A_INV_MASK);
			intIB = IB ^ to_bits(C_INPUT_B_INV_MASK);
			if(C_GATE_TYPE == 0 || C_GATE_TYPE == 1) // AND or NAND gate!
				begin
				intIC = {C_WIDTH{1'b1}};
				intID = {C_WIDTH{1'b1}};
			end
			else
			begin
				intIC = 'b0;
				intID = 'b0;
			end
		end
		else // inv or buf gates
		begin
			intID = {C_WIDTH{1'b0}};
			intIC = {C_WIDTH{1'b0}};
			intIB = {C_WIDTH{1'b0}};
			intIA = IA;
		end
						
		for(j = 0; j < C_WIDTH; j = j + 1)
		begin
			if(intIA[j] === 1'bx || intIB[j] === 1'bx || intIC[j] === 1'bx || intID[j] === 1'bx)
			begin // Unknown's on at least one input
				if(C_GATE_TYPE == 0) // AND gate
				begin
					if(intIA[j] === 1'b0 || intIB[j] === 1'b0 || intIC[j] === 1'b0 || intID[j] === 1'b0)
						tmpres[j] = 1'b0;
					else
						tmpres[j] = 1'bx;
				end
				else if(C_GATE_TYPE == 1) // NAND gate
				begin
					if(intIA[j] === 1'b0 || intIB[j] === 1'b0 || intIC[j] === 1'b0 || intID[j] === 1'b0)
						tmpres[j] = 1'b1;
					else
						tmpres[j] = 1'bx;
				end
				else if(C_GATE_TYPE == 2) // OR gate
				begin
					if(intIA[j] === 1'b1 || intIB[j] === 1'b1 || intIC[j] === 1'b1 || intID[j] === 1'b1)
						tmpres[j] = 1'b1;
					else
						tmpres[j] = 1'bx;
				end
				else if(C_GATE_TYPE == 3) // NOR gate
				begin
					if(intIA[j] === 1'b1 || intIB[j] === 1'b1 || intIC[j] === 1'b1 || intID[j] === 1'b1)
						tmpres[j] = 1'b0;
					else
						tmpres[j] = 1'bx;
				end
				else if(C_GATE_TYPE > 3) // other gate
					tmpres[j] = 1'bx;
			end
			else
			begin
				if(C_GATE_TYPE == 0) // AND gate
					tmpres[j] = intIA[j] && intIB[j] && intIC[j] && intID[j];
				else if(C_GATE_TYPE == 1) // NAND gate
					tmpres[j] = ~(intIA[j] && intIB[j] && intIC[j] && intID[j]);
				else if(C_GATE_TYPE == 2) // OR gate
					tmpres[j] = intIA[j] || intIB[j] || intIC[j] || intID[j];
				else if(C_GATE_TYPE == 3) // NOR gate
					tmpres[j] = ~(intIA[j] || intIB[j] || intIC[j] || intID[j]);
				else if(C_GATE_TYPE == 4) // XOR gate
					tmpres[j] = intIA[j] ^ intIB[j] ^ intIC[j] ^ intID[j];
				else if(C_GATE_TYPE == 5) // XNOR gate
					tmpres[j] = ~(intIA[j] ^ intIB[j] ^ intIC[j] ^ intID[j]);
				else if(C_GATE_TYPE == 6) // INV gate
					tmpres[j] = ~(intIA[j]);
				else if(C_GATE_TYPE == 7) // BUF gate
					tmpres[j] = intIA[j];
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
`undef c_inv
`undef c_buf

