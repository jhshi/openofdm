/* $Id: C_MUX_BUS_V5_0.v,v 1.17 2008/09/08 20:05:56 akennedy Exp $
--
-- Filename - C_MUX_BUS_V5_0.v
-- Author - Xilinx
-- Creation - 4 Feb 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_MUX_BUS_V5_0 module
*/

`timescale 1ns/10ps

`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1
`define c_lut_based 0
`define c_buft_based 1



`define allmyXs {C_WIDTH{1'bx}}
`define allmyZs {C_WIDTH{1'bz}}

module C_MUX_BUS_V5_0 (MA, MB, MC, MD, ME, MF, MG, MH, 
                       MAA, MAB, MAC, MAD, MAE, MAF, MAG, MAH,
                       MBA, MBB, MBC, MBD, MBE, MBF, MBG, MBH, 
                       MCA, MCB, MCC, MCD, MCE, MCF, MCG, MCH, 
                       S, CLK, CE, EN, ACLR, ASET, AINIT, 
                       SCLR, SSET, SINIT, O, Q);

	parameter C_AINIT_VAL 		= "";
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_CE 		= 0;
	parameter C_HAS_EN 		= 0;
	parameter C_HAS_O 		= 0;
	parameter C_HAS_Q 		= 1;
	parameter C_HAS_SCLR 		= 1;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 1;
	parameter C_INPUTS 		= 2;
        parameter C_LATENCY             = 1; 				
	parameter C_MUX_TYPE 		= `c_lut_based;
	parameter C_SEL_WIDTH 		= 1; 				
	parameter C_SINIT_VAL 		= "";
	parameter C_SYNC_ENABLE 	= `c_override;	
	parameter C_SYNC_PRIORITY 	= `c_clear;	
	parameter C_WIDTH 			= 2;

    // Parameters, used to drive additional register, for pipelining.
    parameter PIPE_HAS_ACLR  = (C_LATENCY == 1 ? C_HAS_ACLR  : 1'b0);
    parameter PIPE_HAS_AINIT = (C_LATENCY == 1 ? C_HAS_AINIT : 1'b0);
    parameter PIPE_HAS_ASET  = (C_LATENCY == 1 ? C_HAS_ASET  : 1'b0);
    parameter PIPE_HAS_SSET  = (C_LATENCY == 1 ? C_HAS_SSET  : 1'b0);
    parameter PIPE_HAS_SINIT = (C_LATENCY == 1 ? C_HAS_SINIT : 1'b0);


	input [C_WIDTH-1 : 0] MA;
	input [C_WIDTH-1 : 0] MB;
	input [C_WIDTH-1 : 0] MC;
	input [C_WIDTH-1 : 0] MD;
	input [C_WIDTH-1 : 0] ME;
	input [C_WIDTH-1 : 0] MF;
	input [C_WIDTH-1 : 0] MG;
	input [C_WIDTH-1 : 0] MH;
        input [C_WIDTH-1 : 0] MAA;
	input [C_WIDTH-1 : 0] MAB;
	input [C_WIDTH-1 : 0] MAC;
	input [C_WIDTH-1 : 0] MAD;
	input [C_WIDTH-1 : 0] MAE;
	input [C_WIDTH-1 : 0] MAF;
	input [C_WIDTH-1 : 0] MAG;
	input [C_WIDTH-1 : 0] MAH;
        input [C_WIDTH-1 : 0] MBA;
	input [C_WIDTH-1 : 0] MBB;
	input [C_WIDTH-1 : 0] MBC;
	input [C_WIDTH-1 : 0] MBD;
	input [C_WIDTH-1 : 0] MBE;
	input [C_WIDTH-1 : 0] MBF;
	input [C_WIDTH-1 : 0] MBG;
	input [C_WIDTH-1 : 0] MBH;
        input [C_WIDTH-1 : 0] MCA;
	input [C_WIDTH-1 : 0] MCB;
	input [C_WIDTH-1 : 0] MCC;
	input [C_WIDTH-1 : 0] MCD;
	input [C_WIDTH-1 : 0] MCE;
	input [C_WIDTH-1 : 0] MCF;
	input [C_WIDTH-1 : 0] MCG;
	input [C_WIDTH-1 : 0] MCH;
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
	output [C_WIDTH-1 : 0] O;
	output [C_WIDTH-1 : 0] Q;
	 
	// Internal values to drive signals when input is missing
	wire [C_WIDTH-1 : 0] intMA = MA;
	wire [C_WIDTH-1 : 0] intMB = MB;
	wire [C_WIDTH-1 : 0] intMC = (C_INPUTS > 2 ? MC : `allmyXs);
	wire [C_WIDTH-1 : 0] intMD = (C_INPUTS > 3 ? MD : `allmyXs);
	wire [C_WIDTH-1 : 0] intME = (C_INPUTS > 4 ? ME : `allmyXs);
	wire [C_WIDTH-1 : 0] intMF = (C_INPUTS > 5 ? MF : `allmyXs);
	wire [C_WIDTH-1 : 0] intMG = (C_INPUTS > 6 ? MG : `allmyXs);
	wire [C_WIDTH-1 : 0] intMH = (C_INPUTS > 7 ? MH : `allmyXs);
	wire [C_WIDTH-1 : 0] intMAA = (C_INPUTS > 8 ? MAA : `allmyXs);
	wire [C_WIDTH-1 : 0] intMAB = (C_INPUTS > 9 ? MAB : `allmyXs);
	wire [C_WIDTH-1 : 0] intMAC = (C_INPUTS > 10 ? MAC : `allmyXs);
	wire [C_WIDTH-1 : 0] intMAD = (C_INPUTS > 11 ? MAD : `allmyXs);
	wire [C_WIDTH-1 : 0] intMAE = (C_INPUTS > 12 ? MAE : `allmyXs);
	wire [C_WIDTH-1 : 0] intMAF = (C_INPUTS > 13 ? MAF : `allmyXs);
	wire [C_WIDTH-1 : 0] intMAG = (C_INPUTS > 14 ? MAG : `allmyXs);
	wire [C_WIDTH-1 : 0] intMAH = (C_INPUTS > 15 ? MAH : `allmyXs);
        wire [C_WIDTH-1 : 0] intMBA = (C_INPUTS > 16 ? MBA : `allmyXs);
	wire [C_WIDTH-1 : 0] intMBB = (C_INPUTS > 17 ? MBB : `allmyXs);
	wire [C_WIDTH-1 : 0] intMBC = (C_INPUTS > 18 ? MBC : `allmyXs);
	wire [C_WIDTH-1 : 0] intMBD = (C_INPUTS > 19 ? MBD : `allmyXs);
	wire [C_WIDTH-1 : 0] intMBE = (C_INPUTS > 20 ? MBE : `allmyXs);
	wire [C_WIDTH-1 : 0] intMBF = (C_INPUTS > 21 ? MBF : `allmyXs);
	wire [C_WIDTH-1 : 0] intMBG = (C_INPUTS > 22 ? MBG : `allmyXs);
	wire [C_WIDTH-1 : 0] intMBH = (C_INPUTS > 23 ? MBH : `allmyXs);
        wire [C_WIDTH-1 : 0] intMCA = (C_INPUTS > 24 ? MCA : `allmyXs);
	wire [C_WIDTH-1 : 0] intMCB = (C_INPUTS > 25 ? MCB : `allmyXs);
	wire [C_WIDTH-1 : 0] intMCC = (C_INPUTS > 26 ? MCC : `allmyXs);
	wire [C_WIDTH-1 : 0] intMCD = (C_INPUTS > 27 ? MCD : `allmyXs);
	wire [C_WIDTH-1 : 0] intMCE = (C_INPUTS > 28 ? MCE : `allmyXs);
	wire [C_WIDTH-1 : 0] intMCF = (C_INPUTS > 29 ? MCF : `allmyXs);
	wire [C_WIDTH-1 : 0] intMCG = (C_INPUTS > 30 ? MCG : `allmyXs);
	wire [C_WIDTH-1 : 0] intMCH = (C_INPUTS > 31 ? MCH : `allmyXs);

	reg  [C_WIDTH-1 : 0] intO;
	reg [C_WIDTH-1 : 0] intQ;

        wire [C_WIDTH-1 : 0] STAGE1;
	wire [C_WIDTH-1 : 0] STAGE2;
	wire [C_SEL_WIDTH-1 : 0] intS = S;	 
	wire [C_WIDTH-1 : 0] Q = (C_HAS_Q == 1 ? intQ : `allmyXs);
	wire [C_WIDTH-1 : 0] O = (C_HAS_O == 1 ? intO : `allmyXs);
	wire intEN;
	

	assign intEN = defval(EN, C_HAS_EN, 1);


	integer j, k, j1, k1;
	integer m, unknown, m1, unknown1;
	
	// Register on output by default

        C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, PIPE_HAS_ACLR, PIPE_HAS_AINIT, PIPE_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, PIPE_HAS_SINIT, PIPE_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, C_WIDTH)
	      REG1 (.D(intO), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT), 
			  .Q(STAGE1)); 
        
        
        C_REG_FD_V5_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, C_WIDTH)
		  REG2 (.D(STAGE1), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(STAGE2)); 


	initial 
	begin

		#1;
		k = 1;
		m = 1; 
		unknown = 0;
		for(j = 0; j < C_SEL_WIDTH; j = j + 1)
		begin
			if(intS[j] === 1)
				k = k + m;
			else if(intS[j] === 1'bz || intS[j] === 1'bx)
				unknown = 1;
			m = m * 2;
		end

		if(intEN === 1'b0)
			intO <= #1 `allmyZs;
		else if(intEN === 1'bx)
			intO <= #1 `allmyXs;
		else if(unknown == 1)
			intO <= #1 `allmyXs;
		else if (k == 1) 
			intO <= #1 intMA;
		else if (k == 2) 
			intO <= #1 intMB;
		else if (k == 3) 
			intO <= #1 intMC;
		else if (k == 4) 
			intO <= #1 intMD;
		else if (k == 5) 
			intO <= #1 intME;
		else if (k == 6) 
			intO <= #1 intMF;
		else if (k == 7) 
			intO <= #1 intMG;
		else if (k == 8) 
			intO <= #1 intMH;
                 else if (k == 9) 
			intO <= #1 intMAA;
		else if (k == 10) 
			intO <= #1 intMAB;
		else if (k == 11) 
			intO <= #1 intMAC;
		else if (k == 12) 
			intO <= #1 intMAD;
		else if (k == 13) 
			intO <= #1 intMAE;
		else if (k == 14) 
			intO <= #1 intMAF;
		else if (k == 15) 
			intO <= #1 intMAG;
		else if (k == 16) 
			intO <= #1 intMAH;
		else if (k == 17) 
			intO <= #1 intMBA;
		else if (k == 18) 
			intO <= #1 intMBB;
		else if (k == 19) 
			intO <= #1 intMBC;
		else if (k == 20) 
			intO <= #1 intMBD;
		else if (k == 21) 
			intO <= #1 intMBE;
		else if (k == 22) 
			intO <= #1 intMBF;
		else if (k == 23) 
			intO <= #1 intMBG;
		else if (k == 24) 
			intO <= #1 intMBH;
		else if (k == 25) 
			intO <= #1 intMCA;
		else if (k == 26) 
			intO <= #1 intMCB;
		else if (k == 27) 
			intO <= #1 intMCC;
		else if (k == 28) 
			intO <= #1 intMCD;
		else if (k == 29) 
			intO <= #1 intMCE;
		else if (k == 30) 
			intO <= #1 intMCF;
		else if (k == 31) 
			intO <= #1 intMCG;
		else if (k == 32) 
			intO <= #1 intMCH;
		else
			intO <= #1 `allmyXs;

	end
	
	always@(intMA or intMB or intMC or intMD or intME or intMF or intMG or intMH or 
	        intMAA or intMAB or intMAC or intMAD or intMAE or intMAF or intMAG or intMAH or
                intMBA or intMBB or intMBC or intMBD or intMBE or intMBF or intMBG or intMBH or
                intMCA or intMCB or intMCC or intMCD or intMCE or intMCF or intMCG or intMCH or
	        intEN or intS)
	begin
		
		k1 = 1;
		m1 = 1; 
		unknown1 = 0;
		for(j1 = 0; j1 < C_SEL_WIDTH; j1 = j1 + 1)
		begin
			if(intS[j1] === 1)
				k1 = k1 + m1;
			else if(intS[j1] === 1'bz || intS[j1] === 1'bx)
				unknown1 = 1;
			m1 = m1 * 2;
		end

		
		if(intEN === 1'b0)
			intO = #1 `allmyZs;
		else if(intEN === 1'bx)
			intO = #1 `allmyXs;
		else if(unknown1 == 1)
			intO <= #1 `allmyXs;
		else if (k1 == 1) 
			intO <= #1 intMA;
		else if (k1 == 2) 
			intO <= #1 intMB;
		else if (k1 == 3) 
			intO <= #1 intMC;
		else if (k1 == 4) 
			intO <= #1 intMD;
		else if (k1 == 5) 
			intO <= #1 intME;
		else if (k1 == 6) 
			intO <= #1 intMF;
		else if (k1 == 7) 
			intO <= #1 intMG;
		else if (k1 == 8) 
			intO <= #1 intMH;
		else if (k1 == 9) 
			intO <= #1 intMAA;
		else if (k1 == 10) 
			intO <= #1 intMAB;
		else if (k1 == 11) 
			intO <= #1 intMAC;
		else if (k1 == 12) 
			intO <= #1 intMAD;
		else if (k1 == 13) 
			intO <= #1 intMAE;
		else if (k1 == 14) 
			intO <= #1 intMAF;
		else if (k1 == 15) 
			intO <= #1 intMAG;
		else if (k1 == 16) 
			intO <= #1 intMAH;
		else if (k1 == 17) 
			intO <= #1 intMBA;
		else if (k1 == 18) 
			intO <= #1 intMBB;
		else if (k1 == 19) 
			intO <= #1 intMBC;
		else if (k1 == 20) 
			intO <= #1 intMBD;
		else if (k1 == 21) 
			intO <= #1 intMBE;
		else if (k1 == 22) 
			intO <= #1 intMBF;
		else if (k1 == 23) 
			intO <= #1 intMBG;
		else if (k1 == 24) 
			intO <= #1 intMBH;
		else if (k1 == 25) 
			intO <= #1 intMCA;
		else if (k1 == 26) 
			intO <= #1 intMCB;
		else if (k1 == 27) 
			intO <= #1 intMCC;
		else if (k1 == 28) 
			intO <= #1 intMCD;
		else if (k1 == 29) 
			intO <= #1 intMCE;
		else if (k1 == 30) 
			intO <= #1 intMCF;
		else if (k1 == 31) 
			intO <= #1 intMCG;
		else if (k1 == 32) 
			intO <= #1 intMCH;
		else
			intO <= #1 `allmyXs;  
                           
	end
	
// Register output settings       
always   
begin
     //------------------------------
     //-- REGISTER CLOCKED OUTPUTS --
     //------------------------------
        if (C_LATENCY === 1)
             intQ = STAGE1;
            else
             intQ = STAGE2; 
        @(STAGE1 or STAGE2);       
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
`undef c_lut_based
`undef c_buft_based

`undef allmyXs
`undef allmyZs
