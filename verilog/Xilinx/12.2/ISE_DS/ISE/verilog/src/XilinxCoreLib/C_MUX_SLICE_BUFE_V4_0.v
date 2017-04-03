/* $Id: C_MUX_SLICE_BUFE_V4_0.v,v 1.11 2008/09/08 20:05:46 akennedy Exp $
--
-- Filename - C_MUX_SLICE_BUFE_V4_0.v
-- Author - Xilinx
-- Creation - 4 Feb 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_MUX_SLICE_BUFE_V4_0 module
*/


`define allXs {C_WIDTH{1'bx}}
`define allZs {C_WIDTH{1'bz}}

module C_MUX_SLICE_BUFE_V4_0 (I, OE, O);

	parameter C_WIDTH = 16;						/* Width of the single input */	

	input [C_WIDTH-1 : 0] I;
	input OE;
	output [C_WIDTH-1 : 0] O;
	 
	reg [C_WIDTH-1 : 0] intO;

	wire [C_WIDTH-1 : 0] #1 O = intO;
	
	initial 
	begin

		if (OE == 1) 
			intO = I;
		else if (OE == 0) 
			intO = `allZs;
		else
			intO = `allXs;			
	end
	
	always@(I or OE)
	begin
		if (OE == 1) 
			intO <= I;
		else if (OE == 0) 
			intO <= `allZs;
		else
			intO <= `allXs;			
	end
		
endmodule

`undef allXs
`undef allZs

