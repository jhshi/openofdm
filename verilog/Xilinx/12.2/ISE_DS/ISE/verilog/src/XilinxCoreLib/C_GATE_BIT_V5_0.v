/* $Id: C_GATE_BIT_V5_0.v,v 1.17 2008/09/08 20:05:56 akennedy Exp $
--
-- Filename - C_GATE_BIT_V5_0.v
-- Author - Xilinx
-- Creation - 25 Jan 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_GATE_BIT_V5_0 module
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

module C_GATE_BIT_V5_0 (I, CLK, CE, ACLR, ASET, AINIT, SCLR, SSET, SINIT, T, EN, O, Q);

	parameter C_AINIT_VAL 		= "0";
	parameter C_ENABLE_RLOCS	= 0;
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
	parameter C_INPUT_INV_MASK 	= "";
	parameter C_PIPE_STAGES 	= 0;    
	parameter C_SINIT_VAL 		= "0";
	parameter C_SYNC_ENABLE 	= `c_override;	
	parameter C_SYNC_PRIORITY 	= `c_clear;		
	

	input [C_INPUTS-1 : 0] I;
	input CLK;
	input CE;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	input T;
	input EN;
	output O;
	output Q;
	 
	// Internal values to drive signals when input is missing
	wire intCE;
	reg intO;
	wire intQ;
	reg lastCLK;
	
	reg [C_PIPE_STAGES+2 : 0] intQpipe; 
	reg intQpipeend;
	 
	wire Q = (C_HAS_Q == 1 ? intQ : 1'bx);
	wire O = (C_HAS_O == 1 ? intO : 1'bx);
	
	// Sort out default values for missing ports
	
	assign intCE = defval(CE, C_HAS_CE, 1);
	
	integer j;
	integer pipe;

	reg [C_INPUTS-1 : 0] tmpsig;
	reg tmpres;
	
	// Output register
	C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
		reg1 (.D(intQpipeend), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(intQ)); 
			  
	initial 
	begin
	
		#1;
	
		intQpipe = 'b0;
		
		if(C_GATE_TYPE == 0 || C_GATE_TYPE == 1) // AND or NAND gate?
			tmpres = 1;
		else
			tmpres = 0;
			
		tmpsig = to_bits(C_INPUT_INV_MASK);
		
		for(j = 0; j < C_INPUTS; j = j + 1)
		begin
			if(tmpsig[j] == 1)
			begin
				if(C_GATE_TYPE == 0) // AND gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres & ~I[j];
					else if(tmpres === 1'b1)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 1) // NAND gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres & ~I[j];
					else if(tmpres === 1'b1)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 2) // OR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres | ~I[j];
					else if(tmpres === 1'b0)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 3) // NOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres | ~I[j];
					else if(tmpres === 1'b0)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 4) // XOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres ^ ~I[j];
					else 
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 5) // XNOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres ^ ~I[j];
					else 
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 7) // Buffer
				begin
					if(I[j] !== 1'bx)
						tmpres = ~I[j];
					else 
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 8) // BUFT
				begin
					if(I[j] !== 1'bx)
						tmpres = ~I[j];
					else 
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 9) // BUFE
				begin
					if(I[j] !== 1'bx)
						tmpres = ~I[j];
					else 
						tmpres = 1'bx;
				end
                else  // INV gate
				begin
					if(I[j] !== 1'bx)
						tmpres = ~I[j];
					else 
						tmpres = 1'bx;
				end
			end
			else // No input inversion on bit j of input	
			begin
				if(C_GATE_TYPE == 0) // AND gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres & I[j];
					else if(tmpres === 1'b1)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 1) // NAND gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres & I[j];
					else if(tmpres === 1'b1)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 2) // OR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres | I[j];
					else if(tmpres === 1'b0)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 3) // NOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres | I[j];
					else if(tmpres === 1'b0)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 4) // XOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres ^ I[j];
					else
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 5) // XNOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres ^ I[j];
					else
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 7) // Buffer
				begin
					if(I[j] !== 1'bx)
						tmpres = I[j];
					else 
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 8) // BUFT
				begin
					if(I[j] !== 1'bx)
                        if (T == 0)
    						tmpres = I[j];
                        else
                            tmpres = 1'b1;
					else 
						tmpres = 1'b1;
				end
                else if(C_GATE_TYPE == 9) // BUFE
				begin
					if(I[j] !== 1'bx)
                        if (EN == 0)
    						tmpres = I[j];
                        else
                            tmpres = 1'b1;
					else 
						tmpres = 1'b1;
				end
                else  // INV gate
				begin
					if(I[j] !== 1'bx)
						tmpres = I[j];
					else 
						tmpres = 1'bx;
				end
			end
		end
		
		if(C_GATE_TYPE == 1 || C_GATE_TYPE == 3 || C_GATE_TYPE == 5 || C_GATE_TYPE == 6)
			tmpres = ~tmpres;
		
		intO <= tmpres;

		if(C_PIPE_STAGES < 2) // No pipeline
			intQpipeend = intO;
		else // Pipeline stages required
		begin
			intQpipeend = intQpipe[2];
		end
	end
	
	always @(CLK)
  		lastCLK <= CLK;

	always@(I or T or EN) 
	begin
		if(C_GATE_TYPE == 0 || C_GATE_TYPE == 1) // AND or NAND gate?
			tmpres = 1;
		else
			tmpres = 0;
		for(j = 0; j < C_INPUTS; j = j + 1)
		begin
			if(tmpsig[j] == 1)
			begin
				if(C_GATE_TYPE == 0) // AND gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres & ~I[j];
					else if(tmpres === 1'b1)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 1) // NAND gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres & ~I[j];
					else if(tmpres === 1'b1)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 2) // OR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres | ~I[j];
					else if(tmpres === 1'b0)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 3) // NOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres | ~I[j];
					else if(tmpres === 1'b0)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 4) // XOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres ^ ~I[j];
					else 
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 5) // XNOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres ^ ~I[j];
					else 
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 7 ) // Buffer
				begin
					if(I[j] !== 1'bx)
						tmpres = ~I[j];
					else 
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 8) // BUFT
				begin
					if(I[j] !== 1'bx)
                        if (T == 0)
    						tmpres = ~I[j];
                        else 
                            tmpres = 1'b1;
                    else 
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 9) // BUFE
				begin
					if(I[j] !==  1'bx)
                        if (EN == 0)
						tmpres = ~I[j];
                        else 
                        tmpres = 1'b1;
					else 
						tmpres = 1'bx;
                end
                else  // INV gate
				begin
					if(I[j] !== 1'bx)
						tmpres = ~I[j];
					else 
						tmpres = 1'bx;
				end
			end
			else // No input inversion on bit j of input	
			begin
				if(C_GATE_TYPE == 0) // AND gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres & I[j];
					else if(tmpres === 1'b1)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 1) // NAND gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres & I[j];
					else if(tmpres === 1'b1)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 2) // OR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres | I[j];
					else if(tmpres === 1'b0)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 3) // NOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres | I[j];
					else if(tmpres === 1'b0)
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 4) // XOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres ^ I[j];
					else
						tmpres = 1'bx;
				end
				else if(C_GATE_TYPE == 5) // XNOR gate
				begin
					if(I[j] !== 1'bx)
						tmpres = tmpres ^ I[j];
					else
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 7) // Buffer
				begin
					if(I[j] !== 1'bx)
						tmpres = I[j];
					else 
						tmpres = 1'bx;
				end
                else if(C_GATE_TYPE == 8) // BUFT
				begin
					if(I[j] !== 1'bx)
                        if (T == 0)
       						tmpres = I[j];
	                    else 
	                        tmpres = 1'b1;
    				else 
						tmpres = 1'b1;
				end
                else if(C_GATE_TYPE == 9) // BUFE
				begin
					if(I[j] !== 1'bx)
                        if (EN == 0)
       						tmpres = I[j];
	                    else 
	                        tmpres = 1'b1;
    				else 
						tmpres = 1'b1;
				end

                else  // INV gate
				begin
					if(I[j] !== 1'bx)
						tmpres = I[j];
					else 
						tmpres = 1'bx;
				end
			end
		end
		
		if(C_GATE_TYPE == 1 || C_GATE_TYPE == 3 || C_GATE_TYPE == 5 || C_GATE_TYPE == 6)
			tmpres = ~tmpres;
		
		intO <= #1 tmpres;
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
				if(intQpipe[pipe] !== intQpipe[pipe+1])
					intQpipe[pipe] <= 1'bx;
			end
			if(intQpipe[C_PIPE_STAGES] !== intO)
				intQpipe[C_PIPE_STAGES] <= 1'bx;
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
	
	function [C_INPUTS - 1 : 0] to_bits;
	input [C_INPUTS*8 : 1] instring;
	integer i;
	begin
		for(i = C_INPUTS; i > 0; i = i - 1)
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
