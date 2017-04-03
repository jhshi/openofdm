// Copyright(C) 2002 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.


/* $Id: C_REG_LD_V6_0.v,v 1.16 2008/09/08 20:06:05 akennedy Exp $
--
-- Filename - C_REG_LD_V6_0.v
-- Author - Xilinx
-- Creation - 21 Oct 1998
--
-- Description - This file contains the Verilog behavior for the baseblocks C_REG_LD_V6_0 module
*/

`timescale 1ns/10ps

`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1

`define all1s {C_WIDTH{1'b1}}
`define all0s 'b0
`define allXs {C_WIDTH{1'bx}}

module C_REG_LD_V6_0 (D, G, GE, ACLR, ASET, AINIT, SCLR, SSET, SINIT, Q);

	parameter C_AINIT_VAL 		= "";
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_GE 			= 0;
	parameter C_HAS_SCLR 		= 0;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 0;
	parameter C_SINIT_VAL 		= "";
	parameter C_SYNC_ENABLE 	= `c_override;	
	parameter C_SYNC_PRIORITY 	= `c_clear;	
	parameter C_WIDTH 			= 16; 		
	

	input [C_WIDTH-1 : 0] D;
	input G;
	input GE;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	output [C_WIDTH-1 : 0] Q;
	 
	reg [C_WIDTH-1 : 0] data;
	reg [C_WIDTH-1 : 0] datatmp;
	// Internal values to drive signals when input is missing
	wire intGE;
	wire intACLR;
	wire intASET;
	wire intAINIT;
	wire intSCLR;
	wire intSSET;
	wire intSINIT;
	 
	wire [C_WIDTH-1 : 0] #1 Q = data;

	// Sort out default values for missing ports
	
	assign intACLR = defval(ACLR, C_HAS_ACLR, 0);
	assign intASET = defval(ASET, C_HAS_ASET, 0);
	assign intAINIT = defval(AINIT, C_HAS_AINIT, 0);
	assign intSCLR = defval(SCLR, C_HAS_SCLR, 0);
	assign intSSET = defval(SSET, C_HAS_SSET, 0);
	assign intSINIT = defval(SINIT, C_HAS_SINIT, 0);
	assign intGE = ((C_HAS_SCLR == 1 || C_HAS_SSET == 1 || C_HAS_SINIT == 1) &&
					(C_HAS_GE == 1) && (C_SYNC_ENABLE == `c_override) ? 
						(GE | intSCLR | intSSET | intSINIT) : ((C_HAS_GE == 1) ? GE : 1'b1));
	
	reg lastintACLR;
	reg lastintASET;
	
	reg [C_WIDTH-1 : 0] AIV;
	reg [C_WIDTH-1 : 0] SIV;
	
	
	integer i;
	integer ASYNC_CTRL;
	
	initial 
	begin
		ASYNC_CTRL = 1;
		lastintACLR = 1'b0;
		lastintASET = 1'b0;
		AIV = to_bits(C_AINIT_VAL);
		SIV = to_bits(C_SINIT_VAL);
		if(C_HAS_ACLR === 1)
			#1 data = `all0s;
		else if(C_HAS_ASET === 1)
			#1 data = `all1s;
		else if(C_HAS_AINIT === 1)
		    #1 data = AIV;
//		else if(C_HAS_SCLR === 1)
//			#1 data = `all0s;
//		else if(C_HAS_SSET === 1)
//			#1 data = `all1s;
//		else if(C_HAS_SINIT === 1)
//			#1 data = SIV;
		else
			#1 data = AIV;			
	end
	
	always@(G or intGE or intACLR or intASET or intAINIT or intSCLR or intSSET or intSINIT or D)
	begin
		datatmp = data;
		
//		for(i = 0; i < C_WIDTH; i = i + 1)
//		begin
			if(intACLR === 1'b1)
//				datatmp[i] = 1'b0;
				datatmp = `all0s;
			else if(intACLR === 1'b0 && intASET === 1'b1)
//				datatmp[i] = 1'b1;
				datatmp = `all1s;
			else if(intAINIT === 1'b1)
//				datatmp[i] = AIV[i];
				datatmp = AIV;
			else if(intACLR === 1'bx && intASET !== 1'b0)
//				datatmp[i] = 1'bx;
				datatmp = `allXs;
			else if(intACLR != lastintACLR && lastintASET != intASET 
						&& lastintACLR === 1'b1 && lastintASET === 1'b1
						&& intACLR === 1'b0 && intASET === 1'b0)
//				datatmp[i] = 1'bx;
				datatmp = `allXs;
			else 
			begin
				ASYNC_CTRL = 0;
				if(G === 1'b1)
				begin
					if((intGE !== 1'b0 || C_SYNC_ENABLE === 0) &&
						(C_SYNC_PRIORITY == 0 && intSSET === 1'bx && intSCLR !== 1'b0))
					begin
//						datatmp[i] = 1'bx;
						datatmp = `allXs;
						ASYNC_CTRL = 1;
					end
					if((intGE !== 1'b0 || C_SYNC_ENABLE === 0) &&
					(C_SYNC_PRIORITY == 1 && intSSET !== 1'b0 && intSCLR === 1'bx))
					begin
//						datatmp[i] = 1'bx;
						datatmp = `allXs;
						ASYNC_CTRL = 1;
					end
					if(intGE === 1'b1 && intSCLR !== 1'b1 && intSSET !== 1'b1 && intSINIT !== 1'b1 && ASYNC_CTRL == 0)
//						datatmp[i] = D[i];
						datatmp = D;
//					else if(intGE === 1'bx && datatmp[i] !== D[i] && intSCLR !== 1'b1 && intSSET !== 1'b1 && intSINIT !== 1'b1 && ASYNC_CTRL == 0)
					else if(intGE === 1'bx && intSCLR !== 1'b1 && intSSET !== 1'b1 && intSINIT !== 1'b1 && ASYNC_CTRL == 0)
//						datatmp[i] = 1'bx;
						datatmp = ~((~(datatmp ^ D) | `allXs) ^ datatmp);

					if(intSINIT === 1'b1 && (intGE === 1'b1 || C_SYNC_ENABLE == 0) && ASYNC_CTRL == 0)
//						datatmp[i] = SIV[i];
						datatmp = SIV;
//					else if(intSINIT === 1'b1 && (intGE === 1'bx && C_SYNC_ENABLE == 1) && datatmp[i] !== SIV[i])
					else if(intSINIT === 1'b1 && (intGE === 1'bx && C_SYNC_ENABLE == 1))
//						datatmp[i] = 1'bx;
						datatmp = ~((~(datatmp ^ SIV) | `allXs) ^ datatmp);
//					else if(intSINIT === 1'bx && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && datatmp[i] !== SIV[i])
					else if(intSINIT === 1'bx && (intGE !== 1'b0 || C_SYNC_ENABLE == 0))
//						datatmp[i] = 1'bx;
						datatmp = ~((~(datatmp ^ SIV) | `allXs) ^ datatmp);

					if(intSCLR === 1'b1 && (intGE === 1'b1 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 1 || intSSET === 1'b0) && ASYNC_CTRL == 0)
//						datatmp[i] = 1'b0;
						datatmp = `all0s;
//					else if(intSCLR === 1'b1 && (intGE === 1'bx && C_SYNC_ENABLE == 1) && datatmp[i] !== 1'b0 && (C_SYNC_PRIORITY == 1 || intSSET === 1'b0))
					else if(intSCLR === 1'b1 && (intGE === 1'bx && C_SYNC_ENABLE == 1) && (C_SYNC_PRIORITY == 1 || intSSET === 1'b0))
//						datatmp[i] = 1'bx;
						datatmp = ~(~datatmp | `allXs);
//					else if(intSCLR === 1'bx && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && datatmp[i] !== 1'b0 && (C_SYNC_PRIORITY == 1 || intSSET === 1'b0))
					else if(intSCLR === 1'bx && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 1 || intSSET === 1'b0))
//						datatmp[i] = 1'bx;
						datatmp = ~(~datatmp | `allXs);
						
					if(intSSET === 1'b1 && (intGE === 1'b1 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 0 || intSCLR === 1'b0) && ASYNC_CTRL == 0)
//						datatmp[i] = 1'b1;
						datatmp = `all1s;
//					else if(intSSET === 1'b1 && (intGE === 1'bx && C_SYNC_ENABLE == 1) && datatmp[i] !== 1'b1 && (C_SYNC_PRIORITY == 0 || intSCLR === 1'b0))
					else if(intSSET === 1'b1 && (intGE === 1'bx && C_SYNC_ENABLE == 1) && (C_SYNC_PRIORITY == 0 || intSCLR === 1'b0))
//						datatmp[i] = 1'bx;
						datatmp = datatmp | `allXs;
//					else if(intSSET === 1'bx && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && datatmp[i] !== 1'b1 && (C_SYNC_PRIORITY == 0 || intSCLR === 1'b0))
					else if(intSSET === 1'bx && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 0 || intSCLR === 1'b0))
//						datatmp[i] = 1'bx;
						datatmp = datatmp | `allXs;
				end
				else if(G === 1'bx)							
				begin
					if((intGE !== 1'b0 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 0 && intSSET === 1'bx && intSCLR !== 1'b0))
//						datatmp[i] = 1'bx;
						datatmp = `allXs;
					else if((intGE !== 1'b0 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 1 && intSSET !== 1'b0 && intSCLR === 1'bx))
//						datatmp[i] = 1'bx;
						datatmp = `allXs;
					
//					if((intGE !== 1'b0 || (C_SYNC_ENABLE == 0 && (intSCLR !== 1'b0 || intSSET !== 1'b0 || intSINIT !== 1'b0))) && intSCLR !== 1'b1 && intSSET !== 1'b1 && intSINIT !== 1'b1 && datatmp[i] !== D[i])
					if((intGE !== 1'b0 || (C_SYNC_ENABLE == 0 && (intSCLR !== 1'b0 || intSSET !== 1'b0 || intSINIT !== 1'b0))) && intSCLR !== 1'b1 && intSSET !== 1'b1 && intSINIT !== 1'b1)
//						datatmp[i] = 1'bx;
						datatmp = ~((~(datatmp ^ D) | `allXs) ^ datatmp);
						
//					if(intSINIT !== 1'b0 && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && datatmp[i] !== SIV[i])
					if(intSINIT !== 1'b0 && (intGE !== 1'b0 || C_SYNC_ENABLE == 0))
//						datatmp[i] = 1'bx;
						datatmp = ~((~(datatmp ^ SIV) | `allXs) ^ datatmp);
						
//					if(intSCLR !== 1'b0 && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 1 || intSSET === 1'b0) && datatmp[i] !== 1'b0)
					if(intSCLR !== 1'b0 && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 1 || intSSET === 1'b0))
//						datatmp[i] = 1'bx;
						datatmp = ~(~datatmp | `allXs);
						
//					if(intSSET !== 1'b0 && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 0 || intSCLR === 1'b0) && datatmp[i] !== 1'b1)
					if(intSSET !== 1'b0 && (intGE !== 1'b0 || C_SYNC_ENABLE == 0) && (C_SYNC_PRIORITY == 0 || intSCLR === 1'b0))
//						datatmp[i] = 1'bx;
						datatmp = datatmp | `allXs;
				end

				if(intACLR === 1'b0 && intASET === 1'bx)
				begin
/*					if(datatmp[i] !== 1'b1)
					begin
						datatmp[i] = 1'bx;
						ASYNC_CTRL = 1;
					end*/
					ASYNC_CTRL = |(~datatmp) ? 1 : 0;
                                        datatmp = datatmp | `allXs;
				end
				else if(intACLR === 1'bx && intASET === 1'b0)
				begin
/*					if(datatmp[i] !== 1'b0)
					begin
						datatmp[i] = 1'bx;
						ASYNC_CTRL = 1;
					end*/
                                        ASYNC_CTRL = |datatmp ? 1 : 0;
					datatmp = datatmp & `allXs;
				end
				else if(intAINIT === 1'bx)
				begin
/*					if(datatmp[i] !== AIV[i])
					begin
						datatmp[i] = 1'bx;
						ASYNC_CTRL = 1;
					end*/
					ASYNC_CTRL = |(datatmp ^ AIV) ? 1 : 0;
					datatmp = ~((~(datatmp ^ AIV) | `allXs) ^ datatmp);
				end
			end
//		end
		
		data <= datatmp;
	end	
							
	
	always@(intACLR or intASET)
	begin
		lastintACLR <= intACLR;
		lastintASET <= intASET;
		if($time != 0)
			if(intACLR === 1'b0 && intASET === 1'b0 && lastintACLR !== 1'b0 && lastintASET !== 1'b0) // RACE
				data <= `allXs;
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
					$display("Error in %m at time %d ns: non-binary digit in string \"%s\"\nExiting simulation...", $time, instring);
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

`undef all1s
`undef all0s
`undef allXs
