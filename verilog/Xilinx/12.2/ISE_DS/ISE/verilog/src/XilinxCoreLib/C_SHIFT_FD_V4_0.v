/* $Id: C_SHIFT_FD_V4_0.v,v 1.11 2008/09/08 20:05:46 akennedy Exp $
--
-- Filename - C_SHIFT_FD_V4_0.v
-- Author - Xilinx
-- Creation - 29 June 1999
--
-- Description - This file contains the Verilog behavior for the baseblocks C_SHIFT_FD_V4_0 module
*/





`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1
`define c_zeros 0
`define c_ones 1
`define c_lsb 2
`define c_msb 3
`define c_wrap 4
`define c_sdin 5
`define c_lsb_to_msb 0
`define c_msb_to_lsb 1
`define c_bidirectional 2


`define all1s {C_WIDTH{1'b1}}
`define all0s 'b0
`define allXs {C_WIDTH{1'bx}}

module C_SHIFT_FD_V4_0 (LSB_2_MSB, SDIN, D, P_LOAD, CLK, CE, ACLR, ASET, AINIT, SCLR, SSET, SINIT, SDOUT, Q);

	parameter C_AINIT_VAL 		= "";
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_FILL_DATA		= `c_sdin;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_CE 			= 0;
	parameter C_HAS_D			= 0;
	parameter C_HAS_LSB_2_MSB	= 0;
	parameter C_HAS_Q			= 1;
	parameter C_HAS_SCLR 		= 0;
	parameter C_HAS_SDIN 		= 1;
	parameter C_HAS_SDOUT 		= 0;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 0;
	parameter C_SHIFT_TYPE 		= `c_lsb_to_msb;
	parameter C_SINIT_VAL 		= "";
	parameter C_SYNC_ENABLE 	= `c_override;	
	parameter C_SYNC_PRIORITY 	= `c_clear;	
	parameter C_WIDTH		 	= 16;	
	
	//san 13/12/99
	parameter MUX_BUS_INIT_VAL     = {C_WIDTH-(C_WIDTH>2?2:0){"0"}};
	
	input LSB_2_MSB;
	input SDIN;
	input [C_WIDTH-1 : 0] D;
	input P_LOAD;
	input CLK;
	input CE;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	output SDOUT;
	output [C_WIDTH-1 : 0] Q;
	 
	// Internal values to drive signals when input is missing
	wire intLSB_2_MSB;
	wire intSDIN;
	wire [C_WIDTH-1 : 0] intD;
	wire intP_LOAD;
	wire intCE;
	wire intACLR;
	wire intASET;
	wire intAINIT;
	wire intSCLR;
	wire intSSET;
	wire intSINIT;
	wire intSDOUT;
	wire [C_WIDTH-1 : 0] intQ;
	 
	wire [C_WIDTH-1 : 0] Q = (C_HAS_Q == 1 ? intQ : `allXs);
	wire SDOUT = (C_HAS_SDOUT == 1 ? intSDOUT : 1'bx);

	wire [C_WIDTH-1 : 0] regsin;
	wire [C_WIDTH-1 : 0] regsout;
	wire [3 : 0] MSBmuxi;
	wire [3 : 0] LSBmuxi;
	wire [1 : 0] muxc;
	
	wire MSBmuxo;
	wire LSBmuxo;
	wire [C_WIDTH-(C_WIDTH>2?2:0) : 1] shmuxo;

	wire [C_WIDTH-(C_WIDTH>2?2:0) : 1] shmuxi0;
	wire [C_WIDTH-(C_WIDTH>2?2:0) : 1] shmuxi1;
	wire [C_WIDTH-(C_WIDTH>2?2:0) : 1] shmuxi2;
	wire [C_WIDTH-(C_WIDTH>2?2:0) : 1] shmuxi3;
	// Sort out default values for missing ports
	
	assign intLSB_2_MSB = (C_SHIFT_TYPE == `c_bidirectional ? (C_HAS_LSB_2_MSB == 1 ? (C_WIDTH == 1 ? 1'b1 : LSB_2_MSB) : 1'bx) : (C_SHIFT_TYPE == `c_lsb_to_msb ? 1'b1 : (C_WIDTH == 1 ? 1'b1 :1'b0)));
	assign intSDIN = (C_HAS_SDIN == 1 ? SDIN : (C_FILL_DATA == `c_zeros ? 1'b0 : (C_FILL_DATA == `c_ones ? 1'b1 : (C_FILL_DATA == `c_lsb ? regsout[0] : (C_FILL_DATA == `c_msb ? regsout[C_WIDTH-1] : (C_FILL_DATA == `c_wrap ? (intLSB_2_MSB === 1'b0 ? regsout[0] : regsout[C_WIDTH-1]) : 1'bx))))));
	assign intD = (C_HAS_D == 1 ? D : `allXs);
	assign intP_LOAD = (C_HAS_D == 1 ? P_LOAD : 1'b0);
	assign intCE = defval(CE, C_HAS_CE, 1);
	assign intACLR = defval(ACLR, C_HAS_ACLR, 0);
	assign intASET = defval(ASET, C_HAS_ASET, 0);
	assign intAINIT = defval(AINIT, C_HAS_AINIT, 0);
	assign intSCLR = defval(SCLR, C_HAS_SCLR, 0);
	assign intSSET = defval(SSET, C_HAS_SSET, 0);
	assign intSINIT = defval(SINIT, C_HAS_SINIT, 0);

	assign intSDOUT = (C_SHIFT_TYPE == `c_lsb_to_msb || C_SHIFT_TYPE == `c_bidirectional ? regsout[C_WIDTH-1] : regsout[0]);
	assign intQ = (C_HAS_Q == 1 ? regsout : `allXs);

	assign LSBmuxi[0] = regsout[(C_WIDTH>1?1:0)];
	assign LSBmuxi[1] = intSDIN;
	assign LSBmuxi[2] = intD[0];
	assign LSBmuxi[3] = intD[0];

	assign MSBmuxi[0] = intSDIN;
	assign MSBmuxi[1] = regsout[C_WIDTH-(C_WIDTH>1?2:1)];
	assign MSBmuxi[2] = intD[C_WIDTH-1];
	assign MSBmuxi[3] = intD[C_WIDTH-1];
	
	assign shmuxi0 = regsout[C_WIDTH-1 : (C_WIDTH>2?2:0)];
	assign shmuxi1 = regsout[C_WIDTH-(C_WIDTH>2?3:1) : 0];
	assign shmuxi2 = intD[C_WIDTH-(C_WIDTH>2?2:1) : (C_WIDTH>2?1:0)];
	assign shmuxi3 = intD[C_WIDTH-(C_WIDTH>2?2:1) : (C_WIDTH>2?1:0)];

	assign muxc[0] = intLSB_2_MSB;
	assign muxc[1] = intP_LOAD;
	
	assign regsin[0] = LSBmuxo;
	assign regsin[C_WIDTH-1] = (C_WIDTH == 1 ? LSBmuxo : MSBmuxo);
	assign regsin[C_WIDTH-(C_WIDTH>2?2:1) : (C_WIDTH>2?1:0)] = (C_WIDTH == 1 ? LSBmuxo : (C_WIDTH == 2 ? {MSBmuxo, LSBmuxo} : shmuxo));

	integer i, j, k;
	integer m, unknown;
	
	// Register implements SR
	C_REG_FD_V4_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, C_WIDTH)
		shreg (.D(regsin), .CLK(CLK), .CE(intCE), .ACLR(intACLR), .ASET(intASET),
			  .AINIT(intAINIT), .SCLR(intSCLR), .SSET(intSSET), .SINIT(intSINIT),
			  .Q(regsout)); 

	// Muxes to steer data
	C_MUX_BIT_V4_0 #("0000", 1, 0, 0, 0,
					 0, 1, 0, 0, 0, 0,
					 4, 0, 0, 2, "0000", 0, 0)
			MSBmux (.M(MSBmuxi), .S(muxc), .O(MSBmuxo)); // Feeds regsin[C_WIDTH-1]

	C_MUX_BIT_V4_0 #("0000", 1, 0, 0, 0,
					 0, 1, 0, 0, 0, 0,
					 4, 0, 0, 2, "0000", 0, 0)
			LSBmux(.M(LSBmuxi), .S(muxc), .O(LSBmuxo)); // Feeds regsin[0];
			
	//Edited SAN 13/12/99 //Added extra latency parameter, nritchie 15/9/00
	C_MUX_BUS_V4_0 #(MUX_BUS_INIT_VAL, 1, 0, 0, 0,
			   0, 0, 1, 0, 0, 0, 0,
			   4, 0, 0, 2, MUX_BUS_INIT_VAL, 0, 0, C_WIDTH-(C_WIDTH>2?2:0))
			shmux (.MA(shmuxi0), .MB(shmuxi1), .MC(shmuxi2), .MD(shmuxi3), .S(muxc), .O(shmuxo)); // Feeds regsin[C_WIDTH-2 : 1]

	
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
`undef c_zeros 
`undef c_ones 
`undef c_lsb 
`undef c_msb 
`undef c_wrap 
`undef c_sdin 
`undef c_lsb_to_msb 
`undef c_msb_to_lsb 
`undef c_bidirectional 

`undef all1s
`undef all0s
`undef allXs

