/* $Id: C_ACCUM_V5_0.v,v 1.17 2008/09/08 20:05:55 akennedy Exp $
--
-- Filename - C_ACCUM_V5_0.v
-- Author - Xilinx
-- Creation - 15 July 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_ACCUM_V5_0 module
*/

`timescale 1 ns/10 ps

`define c_set 0
`define c_clear 1
`define c_override 0
`define c_no_override 1
`define c_add 0
`define c_sub 1
`define c_add_sub 2
`define c_signed 0
`define c_unsigned 1
`define c_pin 2
`define allUKs {(C_HIGH_BIT-C_LOW_BIT)+1{1'bx}}

module C_ACCUM_V5_0 (B, CLK, ADD, C_IN, B_IN, CE, BYPASS, ACLR, ASET, AINIT,
					  SCLR, SSET, SINIT, B_SIGNED, OVFL, C_OUT, B_OUT,
					  Q_OVFL, Q_C_OUT, Q_B_OUT, S, Q);

	parameter C_ADD_MODE 		= `c_add;
	parameter C_AINIT_VAL 		= "0000000000000000";
	parameter C_BYPASS_ENABLE 	= `c_override;
	parameter C_BYPASS_LOW 		= 0;
	parameter C_B_CONSTANT 		= 0;
	parameter C_B_TYPE 			= `c_unsigned;
	parameter C_B_VALUE 		= "0000000000000000";
	parameter C_B_WIDTH 		= 16;
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_HAS_ACLR 		= 1;
	parameter C_HAS_ADD 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_BYPASS 		= 0;
	parameter C_HAS_BYPASS_WITH_CIN = 0;
    parameter C_HAS_B_IN 		= 1;
	parameter C_HAS_B_OUT 		= 0;
	parameter C_HAS_B_SIGNED 	= 0;
	parameter C_HAS_CE 			= 1;
	parameter C_HAS_C_IN 		= 1;
	parameter C_HAS_C_OUT 		= 0;
	parameter C_HAS_OVFL 		= 0;
	parameter C_HAS_Q_B_OUT 	= 0;
	parameter C_HAS_Q_C_OUT 	= 0;
	parameter C_HAS_Q_OVFL 		= 0;
	parameter C_HAS_S 			= 1; 
	parameter C_HAS_SCLR 		= 1;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 0;
	parameter C_HIGH_BIT 		= 15;
	parameter C_LOW_BIT 		= 0;
	parameter C_OUT_WIDTH 		= 16;
	parameter C_PIPE_STAGES 	= 1;
	parameter C_SATURATE		= 0;
	parameter C_SCALE			= 1;
	parameter C_SINIT_VAL 		= "0000000000000000";
	parameter C_SYNC_ENABLE 	= `c_override;
	parameter C_SYNC_PRIORITY 	= `c_clear;
	
	// Only for internal consumption (prob with MTI otherwise)
	parameter outwidth_min_one = C_OUT_WIDTH-1;
	parameter bwidth_min_one = C_B_WIDTH-1;

    parameter tempSyncEnable = ((C_SYNC_ENABLE == 0 && C_HAS_CE == 1 && (C_HAS_SSET == 1 || C_HAS_SCLR == 1) && C_SATURATE == 1) ? 1 : C_SYNC_ENABLE);   
	
	input [C_B_WIDTH-1 : 0] B;
	input CLK;
	input ADD;
	input C_IN;
	input B_IN;
	input CE;
	input BYPASS;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	input B_SIGNED;
	output OVFL;
	output C_OUT;
	output B_OUT;
	output Q_OVFL;
	output Q_C_OUT;
	output Q_B_OUT;
	output [C_HIGH_BIT : C_LOW_BIT] S;
	output [C_HIGH_BIT : C_LOW_BIT] Q;
	
	 
	// Internal values to drive signals when input is missing
	wire [C_OUT_WIDTH-1 : 0] intS;
	wire [C_OUT_WIDTH-1 : 0] intS_sat0;
	wire [C_OUT_WIDTH-1 : 0] intS_unsat1;
	wire [C_OUT_WIDTH-1 : 0] intS_sinsat1;
	wire [C_OUT_WIDTH-1 : 0] intFB;
	wire [C_OUT_WIDTH-1 : 0] intFBq;
	wire [C_OUT_WIDTH-1 : 0] intFBq_sat0;
	wire [C_OUT_WIDTH-1 : 0] intFBq_unsat1;
	wire [C_OUT_WIDTH-1 : 0] intFBq_sinsat1;
	wire intSCLR;
	wire intSSET;
	wire intSCLR_TO_ADDER;
	wire intSSET_TO_ADDER;
	wire intSCLR_TO_MSB;
	wire intSSET_TO_MSB;
	wire intSCLR_TO_REST;
	wire intSSET_TO_REST;
	wire intB_SIGNED;
	wire intBYPASSbar;
	wire intC_OUT;
	wire intB_OUT;
	wire Q_C_OUT;
	wire Q_B_OUT;
	wire OVFL;
	wire Q_OVFL;
	wire intC_OUT_sat0;
	wire intB_OUT_sat0;
	wire Q_C_OUT_sat0;
	wire Q_B_OUT_sat0;
	wire OVFL_sat0;
	wire Q_OVFL_sat0;
	wire intC_OUT_unsat1;
	wire intB_OUT_unsat1;
	wire Q_C_OUT_unsat1;
	wire Q_B_OUT_unsat1;
	wire OVFL_unsat1;
	wire Q_OVFL_unsat1;
	wire intC_OUT_sinsat1;
	wire intB_OUT_sinsat1;
	wire Q_C_OUT_sinsat1;
	wire Q_B_OUT_sinsat1;
	wire OVFL_sinsat1;
	wire Q_OVFL_sinsat1;
    wire intBYPASS_WITH_CIN; // New signal for bypass with Cin mode
	wire tempCE;

	
	wire tmpsetsatlogic_un00;
	wire tmpsetsatlogic_un01;
	wire tmpsetsatlogic_un10;
	wire tmpsetsatlogic_un11c;
	wire tmpsetsatlogic_un11s;
	
	wire tmpclrsatlogic_un00;
	wire tmpclrsatlogic_un01;
	wire tmpclrsatlogic_un10;
	wire tmpclrsatlogic_un11c;
	wire tmpclrsatlogic_un11s;
	
	wire tmpsetsatlogicmsb_sg00;
	wire tmpsetsatlogicmsb_sg01;
	wire tmpsetsatlogicmsb_sg10;
	wire tmpsetsatlogicmsb_sg11c;
	wire tmpsetsatlogicmsb_sg11s;
	
	wire tmpsetsatlogicrest_sg00;
	wire tmpsetsatlogicrest_sg01;
	wire tmpsetsatlogicrest_sg10;
	wire tmpsetsatlogicrest_sg11c;
	wire tmpsetsatlogicrest_sg11s;
	
	wire tmpclrsatlogicmsb_sg00;
	wire tmpclrsatlogicmsb_sg01;
	wire tmpclrsatlogicmsb_sg10;
	wire tmpclrsatlogicmsb_sg11c;
	wire tmpclrsatlogicmsb_sg11s;
	
	wire tmpclrsatlogicrest_sg00;
	wire tmpclrsatlogicrest_sg01;
	wire tmpclrsatlogicrest_sg10;
	wire tmpclrsatlogicrest_sg11c;
	wire tmpclrsatlogicrest_sg11s;

    wire addsetBaseSig ;
	wire subsetBaseSig ;
	wire addsubsetBaseSig ;
	wire addclrBaseSig ;
	wire subclrBaseSig ;
	wire addsubclrBaseSig ;

	wire addsetBasePin ;
	wire subsetBasePin ;
	wire addsubsetBasePin ;
	wire addclrBasePin ;
	wire subclrBasePin ;
	wire addsubclrBasePin ;

	wire addsetBase ;
	wire subsetBase ;
	wire addsubsetBase ;
	wire addclrBase ;
	wire subclrBase ;
	wire addsubclrBase ;

	wire intCE ;
	wire intB ;
    wire [C_B_WIDTH : 0] intBconst;
    
	wire [C_HIGH_BIT : C_LOW_BIT] Q = intFBq;
	wire [C_HIGH_BIT : C_LOW_BIT] S = (C_HAS_S == 1 ? intS : `allUKs);
	wire C_OUT = (C_HAS_C_OUT == 1 ? intC_OUT : 1'bx);
	wire B_OUT = (C_HAS_B_OUT == 1 ? intB_OUT : 1'bx);
	
	
	// Sort out default values for missing ports
	
	assign intB_SIGNED = defval(B_SIGNED, C_HAS_B_SIGNED, 0);
	assign intBYPASSbar = (C_BYPASS_LOW == 1 ? BYPASS : ~BYPASS);
	assign intSCLR = defval(SCLR, C_HAS_SCLR, 0);
	assign intSSET = defval(SSET, C_HAS_SSET, 0);
    assign intBYPASS_WITH_CIN = C_HAS_BYPASS_WITH_CIN; //assign new c_has_bypass_with_cin parameter to internal wire
    assign intBconst = (C_B_CONSTANT === 1) ? to_bitsB(C_B_VALUE) : B;
	
    // Now make up the design from other baseblox
	// An addsub for when no saturation logic is required...
	C_ADDSUB_V5_0 #(C_ADD_MODE, 
					C_AINIT_VAL, 
					(C_B_TYPE == `c_pin )? `c_signed : C_B_TYPE, 
					C_OUT_WIDTH,
					C_BYPASS_ENABLE,
					C_BYPASS_LOW, 
					C_B_CONSTANT,
					C_B_TYPE,
					C_B_VALUE,
					C_B_WIDTH,
					C_ENABLE_RLOCS,
					C_HAS_ACLR,
					C_HAS_ADD,
					C_HAS_AINIT,
					C_HAS_ASET,
					C_HAS_B_SIGNED,
					C_HAS_BYPASS,
                    C_HAS_BYPASS_WITH_CIN,
                    C_HAS_B_IN,
					C_HAS_B_OUT,
					C_HAS_B_SIGNED,
					C_HAS_CE,
					C_HAS_C_IN,
					C_HAS_C_OUT,
					C_HAS_OVFL,
					1,
					C_HAS_Q_B_OUT,
					C_HAS_Q_C_OUT,
					C_HAS_Q_OVFL,
					C_HAS_S,
					C_HAS_SCLR,
					C_HAS_SINIT,
					C_HAS_SSET,
					outwidth_min_one,
			                1,
					0,
					C_OUT_WIDTH,
					C_PIPE_STAGES,
					C_SINIT_VAL,
					C_SYNC_ENABLE,
					C_SYNC_PRIORITY)
		sat0_addsub(.A(intFB), .B(B), .CLK(CLK), .ADD(ADD),
					.C_IN(C_IN), .B_IN(B_IN), .CE(CE), .BYPASS(BYPASS),
					.ACLR(ACLR), .ASET(ASET), .AINIT(AINIT),
					.SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
					.A_SIGNED(B_SIGNED), .B_SIGNED(B_SIGNED),
					.OVFL(OVFL_sat0), .C_OUT(intC_OUT_sat0), 
					.B_OUT(intB_OUT_sat0), .Q_OVFL(Q_OVFL_sat0),
					.Q_C_OUT(Q_C_OUT_sat0), .Q_B_OUT(Q_B_OUT_sat0),
					.S(intS_sat0), .Q(intFBq_sat0));
					
					
	// Another addsub for when saturation logic IS required, but only for unsigned data				
	C_ADDSUB_V5_0 #(C_ADD_MODE, 
					C_AINIT_VAL, 
					C_B_TYPE, 
					C_OUT_WIDTH,
					C_BYPASS_ENABLE,
					C_BYPASS_LOW, 
					C_B_CONSTANT,
					C_B_TYPE,
					C_B_VALUE,
					C_B_WIDTH,
					C_ENABLE_RLOCS,
					0,
					C_HAS_ADD,
					0,
					0,
					C_HAS_B_SIGNED,
					C_HAS_BYPASS,
                    C_HAS_BYPASS_WITH_CIN,
					C_HAS_B_IN,
					1,
					C_HAS_B_SIGNED,
					C_HAS_CE,
					C_HAS_C_IN,
					1,
					C_HAS_OVFL,
					1,
					C_HAS_Q_B_OUT,
					C_HAS_Q_C_OUT,
					C_HAS_Q_OVFL,
					C_HAS_S,
					1,
					0,
					1,
					outwidth_min_one,
			                1,
					0,
					C_OUT_WIDTH,
					C_PIPE_STAGES,
					C_SINIT_VAL,
					tempSyncEnable,
					C_SYNC_PRIORITY)
		unsat1_addsub(.A(intFB), .B(B), .CLK(CLK), .ADD(ADD),
					.C_IN(C_IN), .B_IN(B_IN), .CE(intCE), .BYPASS(BYPASS),
					.ACLR(ACLR), .ASET(ASET), .AINIT(AINIT),
					.SCLR(intSCLR_TO_ADDER), .SSET(intSSET_TO_ADDER), .SINIT(SINIT),
					.A_SIGNED(B_SIGNED), .B_SIGNED(B_SIGNED),
					.OVFL(OVFL_unsat1), .C_OUT(intC_OUT_unsat1), 
					.B_OUT(intB_OUT_unsat1), .Q_OVFL(Q_OVFL_unsat1),
					.Q_C_OUT(Q_C_OUT_unsat1), .Q_B_OUT(Q_B_OUT_unsat1),
					.S(intS_unsat1), .Q(intFBq_unsat1));
					
	// Another addsub for when saturation logic IS required, but for signed data				
	C_ADDSUB_V5_0 #(C_ADD_MODE, 
					C_AINIT_VAL, 
					C_B_TYPE, 
					C_OUT_WIDTH,
					C_BYPASS_ENABLE,
					C_BYPASS_LOW, 
					C_B_CONSTANT,
					C_B_TYPE,
					C_B_VALUE,
					C_B_WIDTH,
					C_ENABLE_RLOCS,
					C_HAS_ACLR,
					C_HAS_ADD,
					C_HAS_AINIT,
					C_HAS_ASET,
					C_HAS_B_SIGNED,
					C_HAS_BYPASS,
                    C_HAS_BYPASS_WITH_CIN,
					C_HAS_B_IN,
					1,
					C_HAS_B_SIGNED,
					C_HAS_CE,
					C_HAS_C_IN,
					1,
					C_HAS_OVFL,
					0,
					C_HAS_Q_B_OUT,
					C_HAS_Q_C_OUT,
					C_HAS_Q_OVFL,
					1,
					C_HAS_SCLR,
					C_HAS_SINIT,
					C_HAS_SSET,
					outwidth_min_one,
			        1,
					0,
					C_OUT_WIDTH,
					C_PIPE_STAGES,
					C_SINIT_VAL,
					tempSyncEnable, // wasC_SYNC_ENABLE,
					C_SYNC_PRIORITY)
		sinsat1_addsub(.A(intFB), .B(B), .CLK(CLK), .ADD(ADD),
					.C_IN(C_IN), .B_IN(B_IN), .CE(intCE), .BYPASS(BYPASS),
					.ACLR(ACLR), .ASET(ASET), .AINIT(AINIT),
					.SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
					.A_SIGNED(B_SIGNED), .B_SIGNED(B_SIGNED),
					.OVFL(OVFL_sinsat1), .C_OUT(intC_OUT_sinsat1), 
					.B_OUT(intB_OUT_sinsat1), .Q_OVFL(Q_OVFL_sinsat1),
					.Q_C_OUT(Q_C_OUT_sinsat1), .Q_B_OUT(Q_B_OUT_sinsat1),
					.S(intS_sinsat1), .Q());
					
	// Registers for output of the last addsub
	C_REG_FD_V5_0 #(C_AINIT_VAL[(C_OUT_WIDTH*8)-1 : (C_OUT_WIDTH-1)*8],
					C_ENABLE_RLOCS,
					0,
					0,
					0,
					C_HAS_CE,
					1,
					0,
					1,
					C_SINIT_VAL[(C_OUT_WIDTH*8)-1 : (C_OUT_WIDTH-1)*8],
					C_SYNC_ENABLE,
					C_SYNC_PRIORITY,
					1)
			msb_reg(.D(intS_sinsat1[outwidth_min_one]), .CLK(CLK),
					.CE(intCE), .ACLR(ACLR), .ASET(ASET), .AINIT(AINIT),
					.SCLR(intSCLR_TO_MSB), .SSET(intSSET_TO_MSB),
					.SINIT(SINIT), .Q(intFBq_sinsat1[outwidth_min_one]));
						
	// Need the ?: on the value of C_B_WIDTH in case it == 1
	C_REG_FD_V5_0 #(C_AINIT_VAL[(((C_OUT_WIDTH == 1 ? 2 : C_OUT_WIDTH)-1)*8)-1 : 0],
					C_ENABLE_RLOCS,
					0,
					0,
					0,
					C_HAS_CE,
					1,
					0,
					1,
					C_SINIT_VAL[(((C_OUT_WIDTH == 1 ? 2 : C_OUT_WIDTH)-1)*8)-1 : 0],
					C_SYNC_ENABLE,
					C_SYNC_PRIORITY,
					(C_OUT_WIDTH == 1 ? 2 : C_OUT_WIDTH)-1)
			rest_reg(.D(intS_sinsat1[(C_OUT_WIDTH == 1 ? 2 : C_OUT_WIDTH)-2 : 0]), .CLK(CLK),
					 .CE(intCE), .ACLR(ACLR), .ASET(ASET), .AINIT(AINIT),
					 .SCLR((C_B_WIDTH == 1 ? intSCLR_TO_MSB : intSCLR_TO_REST)), .SSET((C_B_WIDTH == 1 ? intSSET_TO_MSB : intSSET_TO_REST)),
					 .SINIT(SINIT), .Q(intFBq_sinsat1[(C_OUT_WIDTH == 1 ? 2 : C_OUT_WIDTH)-2 : 0]));
						
	
	// Sort out the choices from all these output signals...
	assign tempCE = ((C_SYNC_ENABLE == 0 && C_HAS_CE == 1 && (C_HAS_SSET == 1 || C_HAS_SCLR == 1) && C_SATURATE == 1) ? (CE | intSSET | intSCLR) : CE);
    assign intCE = (C_SATURATE == 0 ? CE : (((C_HAS_BYPASS == 1)&&(C_BYPASS_LOW == 1)) ? ((C_BYPASS_ENABLE == `c_override) ?  (~BYPASS | tempCE) : tempCE) : (((C_HAS_BYPASS == 1)&&(C_BYPASS_LOW == 0)) ? ((C_BYPASS_ENABLE == `c_override) ? (BYPASS | tempCE) : tempCE) : tempCE))) ;
    
	assign intC_OUT = (C_SATURATE == 0 ? intC_OUT_sat0 : (C_B_TYPE == `c_unsigned ? intC_OUT_unsat1 : intC_OUT_sinsat1));	
	assign intB_OUT = (C_SATURATE == 0 ? intB_OUT_sat0 : (C_B_TYPE == `c_unsigned ? intB_OUT_unsat1 : intB_OUT_sinsat1));	
	assign OVFL = (C_SATURATE == 0 ? OVFL_sat0 : (C_B_TYPE == `c_unsigned ? OVFL_unsat1 : OVFL_sinsat1));
	assign Q_C_OUT = (C_SATURATE == 0 ? Q_C_OUT_sat0 : (C_B_TYPE == `c_unsigned ? Q_C_OUT_unsat1 : Q_C_OUT_sinsat1));	
	assign Q_B_OUT = (C_SATURATE == 0 ? Q_B_OUT_sat0 : (C_B_TYPE == `c_unsigned ? Q_B_OUT_unsat1 : Q_B_OUT_sinsat1));	
	assign Q_OVFL = (C_SATURATE == 0 ? Q_OVFL_sat0 : (C_B_TYPE == `c_unsigned ? Q_OVFL_unsat1 : Q_OVFL_sinsat1));
	assign intS = (C_SATURATE == 0 ? intS_sat0 : (C_B_TYPE == `c_unsigned ? intS_unsat1 : intS_sinsat1));
	assign intFBq = (C_SATURATE == 0 ? intFBq_sat0 : (C_B_TYPE == `c_unsigned ? intFBq_unsat1 : intFBq_sinsat1));
	

	// COMPLEX decisions on what to feed to the local control sigs...
	// The signal name suffices denote: un = unsigned, sg = signed, 00 = has neither sset nor sclr, 01 = has sclr only etc
	// 11c = has bot sset and sclr and sclr dominates, 11s = sset dominates, etc
	
	// Unsigned version first
	assign tmpsetsatlogic_un00 = (C_ADD_MODE == `c_add ? intC_OUT : (C_ADD_MODE == `c_sub ? intSSET : (intC_OUT & ADD)));
	assign tmpsetsatlogic_un01 = (C_ADD_MODE == `c_add ? (intC_OUT & ~intSCLR) : (C_ADD_MODE == `c_sub ? intSSET : (intC_OUT & ~intSCLR & ADD)));
	assign tmpsetsatlogic_un10 = (C_ADD_MODE == `c_add ? (intC_OUT | intSSET) : (C_ADD_MODE == `c_sub ? intSSET : ((intC_OUT & ADD) | intSSET)));
	assign tmpsetsatlogic_un11c = (C_ADD_MODE == `c_add ? (~intSCLR & (intC_OUT | intSSET)) : (C_ADD_MODE == `c_sub ? (~intSCLR & intSSET) : ((~intSCLR & intC_OUT & ADD) | (intSSET & ~intSCLR))));
	assign tmpsetsatlogic_un11s = (C_ADD_MODE == `c_add ? ((~intSCLR && intC_OUT) | intSSET) : (C_ADD_MODE == `c_sub ? intSSET : ((~intSCLR & intC_OUT & ADD) | intSSET)));
	
//	assign tmpclrsatlogic_un00 = (C_ADD_MODE == `c_add ? intSCLR : (C_ADD_MODE == `c_sub ? ~intB_OUT : (~intC_OUT & ~ADD)));
    assign tmpclrsatlogic_un00 = (C_ADD_MODE == `c_add ? intSCLR : (C_ADD_MODE == `c_sub ? (C_HAS_BYPASS == 1 ? (C_BYPASS_LOW == 1 ? (~intB_OUT & BYPASS) : (~intB_OUT & ~BYPASS)): ~intB_OUT) : (C_HAS_BYPASS == 1 ? (C_BYPASS_LOW ==1  ? ((~intC_OUT & ~ADD) & BYPASS) : ((~intC_OUT & ~ADD) & ~BYPASS)) : (~intC_OUT & ~ADD))));
//  assign tmpclrsatlogic_un01 = (C_ADD_MODE == `c_add ? intSCLR : (C_ADD_MODE == `c_sub ? (~intB_OUT | intSCLR) : (intSCLR | (~intC_OUT & ~ADD))));
	assign tmpclrsatlogic_un01 = (C_ADD_MODE == `c_add ? intSCLR : (C_ADD_MODE == `c_sub ? (C_HAS_BYPASS == 1 ? (C_BYPASS_LOW == 1 ? ((~intB_OUT & BYPASS) | intSCLR) : ((~intB_OUT & ~BYPASS) | intSCLR)) : (~intB_OUT | intSCLR)) : (C_HAS_BYPASS == 1 ? (C_BYPASS_LOW ==1  ? (intSCLR | ((~intC_OUT & ~ADD) & BYPASS)) : (intSCLR | ((~intC_OUT & ~ADD) & ~BYPASS))) : (intSCLR | (~intC_OUT & ~ADD)))));
//	assign tmpclrsatlogic_un10 = (C_ADD_MODE == `c_add ? intSCLR : (C_ADD_MODE == `c_sub ? (~intB_OUT & ~intSSET) : (~intSSET & ~intC_OUT & ~ADD)));
  	assign tmpclrsatlogic_un10 = (C_ADD_MODE == `c_add ? intSCLR : (C_ADD_MODE == `c_sub ? (C_HAS_BYPASS == 1 ? (C_BYPASS_LOW == 1 ? ((~intB_OUT & BYPASS) & ~intSSET) : ((~intB_OUT & ~BYPASS) & ~intSSET)): (~intB_OUT & ~intSSET)) : ((C_HAS_BYPASS == 1 ? (C_BYPASS_LOW ==1 ? (~intSSET & (~intC_OUT & ~ADD) & BYPASS) : (~intSSET & ((~intC_OUT & ~ADD) & ~BYPASS))) : (~intSSET & ~intC_OUT & ~ADD)))));
//	assign tmpclrsatlogic_un11c = (C_ADD_MODE == `c_add ? intSCLR : (C_ADD_MODE == `c_sub ? (intSCLR | (~intB_OUT & ~intSSET)) : (intSCLR | (~intSSET & ~intC_OUT & ~ADD))));
	assign tmpclrsatlogic_un11c = (C_ADD_MODE == `c_add ? intSCLR : (C_ADD_MODE == `c_sub ? (C_HAS_BYPASS == 1 ? (C_BYPASS_LOW == 1 ? (intSCLR | ((~intB_OUT & BYPASS) & ~intSSET)) : (intSCLR | ((~intB_OUT & ~BYPASS) & ~intSSET))) : (intSCLR | (~intB_OUT & ~intSSET))) : ((C_HAS_BYPASS == 1 ? (C_BYPASS_LOW ==1 ? (intSCLR | ((~intSSET & ~intC_OUT & ~ADD) & BYPASS)) : (intSCLR | ((~intSSET & ~intC_OUT & ~ADD) & ~BYPASS))) : (intSCLR | (~intSSET & ~intC_OUT & ~ADD))))));
//	assign tmpclrsatlogic_un11s = (C_ADD_MODE == `c_add ? (intSCLR & ~intSSET) : (C_ADD_MODE == `c_sub ? (~intSSET & (intSCLR | ~intB_OUT)) : ((intSCLR & ~intSSET) | (~intSSET & ~intC_OUT & ~ADD))));
	assign tmpclrsatlogic_un11s = (C_ADD_MODE == `c_add ? (intSCLR & ~intSSET) : (C_ADD_MODE == `c_sub ? (C_HAS_BYPASS == 1 ? (C_BYPASS_LOW == 1 ? (~intSSET & (intSCLR | (~intB_OUT & BYPASS))) : (~intSSET & (intSCLR | (~intB_OUT & ~BYPASS)))) : (~intSSET & (intSCLR | ~intB_OUT))) : (C_HAS_BYPASS == 1 ? (C_BYPASS_LOW ==1 ? ((intSCLR & ~intSSET) | (~intSSET & ((~intC_OUT & ~ADD) & BYPASS))):  ((intSCLR & ~intSSET) | (~intSSET & ((~intC_OUT & ~ADD) & ~BYPASS)))) : ((intSCLR & ~intSSET) | (~intSSET & ~intC_OUT & ~ADD)))));
	
	assign intSSET_TO_ADDER = (C_HAS_SSET == 0 ? (C_HAS_SCLR == 0 ? tmpsetsatlogic_un00 : tmpsetsatlogic_un01) :
									(C_HAS_SCLR == 0 ? tmpsetsatlogic_un10 : 
										(C_SYNC_PRIORITY == `c_clear ? tmpsetsatlogic_un11c : tmpsetsatlogic_un11s)));
										
	assign intSCLR_TO_ADDER = (C_HAS_SSET == 0 ? (C_HAS_SCLR == 0 ? tmpclrsatlogic_un00 : tmpclrsatlogic_un01) :
									(C_HAS_SCLR == 0 ? tmpclrsatlogic_un10 : 
										(C_SYNC_PRIORITY == `c_clear ? tmpclrsatlogic_un11c : tmpclrsatlogic_un11s)));
										
	// Now all the signals for the signed version
	 assign intB = intBconst[C_B_WIDTH-1];
    //assign intB = (C_B_CONSTANT == 1 ? (C_B_VALUE[(C_B_WIDTH*8)-1 : (C_B_WIDTH-1)*8] == "0" ? 1'b0 : 1'b1) : B[C_B_WIDTH-1]) ;

	assign addclrBaseSig = (intS[C_HIGH_BIT] & ~(intFBq[C_HIGH_BIT]) & ~(intB)) ;
	assign addsetBaseSig = (~(intS[C_HIGH_BIT]) & intFBq[C_HIGH_BIT] & intB) ;
	assign subclrBaseSig = (intS[C_HIGH_BIT] & ~(intFBq[C_HIGH_BIT]) & intB) ;
	assign subsetBaseSig = (~(intS[C_HIGH_BIT]) & intFBq[C_HIGH_BIT] & ~(intB)) ;
	assign addsubclrBaseSig = ((~ADD & (intS[C_HIGH_BIT] & ~(intFBq[C_HIGH_BIT]) & intB)) | (ADD & (intS[C_HIGH_BIT] & ~(intFBq[C_HIGH_BIT]) & ~(intB)))) ;
	assign addsubsetBaseSig = ((~ADD & (~(intS[C_HIGH_BIT]) & intFBq[C_HIGH_BIT] & ~(intB))) | (ADD & (~(intS[C_HIGH_BIT]) & intFBq[C_HIGH_BIT] & intB))) ;

	assign addclrBasePin = (~(intB_SIGNED) & ~(intFBq[C_HIGH_BIT]) & intS[C_HIGH_BIT]) | (intB_SIGNED & ~(intFBq[C_HIGH_BIT]) & intS[C_HIGH_BIT] & ~(intB));
	assign addsetBasePin = (intB_SIGNED & intFBq[C_HIGH_BIT] & ~(intS[C_HIGH_BIT]) & intB) ;
	assign subclrBasePin = (intB_SIGNED & ~(intFBq[C_HIGH_BIT]) & intS[C_HIGH_BIT] & intB);
	assign subsetBasePin = (~(intB_SIGNED) & intFBq[C_HIGH_BIT] & ~(intS[C_HIGH_BIT])) | (intB_SIGNED & intFBq[C_HIGH_BIT] & ~(intS[C_HIGH_BIT]) & ~(intB));
	assign addsubclrBasePin = (~(ADD) & (intB_SIGNED & ~(intFBq[C_HIGH_BIT]) & intS[C_HIGH_BIT] & intB)) | (ADD & ((~(intB_SIGNED) & ~(intFBq[C_HIGH_BIT]) & intS[C_HIGH_BIT]) | (intB_SIGNED & ~(intFBq[C_HIGH_BIT]) & intS[C_HIGH_BIT] & ~(intB)))) ;
	assign addsubsetBasePin = (~(ADD) & ((~intB_SIGNED & intFBq[C_HIGH_BIT] & ~(intS[C_HIGH_BIT])) | (intB_SIGNED & intFBq[C_HIGH_BIT] & ~intS[C_HIGH_BIT] & ~intB))) | (ADD & intB_SIGNED & intFBq[C_HIGH_BIT] & ~intS[C_HIGH_BIT] & intB) ;

    assign addclrBase = (C_HAS_B_SIGNED == 0 ? addclrBaseSig : addclrBasePin);
	assign addsetBase = (C_HAS_B_SIGNED == 0 ? addsetBaseSig : addsetBasePin);
	assign subclrBase = (C_HAS_B_SIGNED == 0 ? subclrBaseSig : subclrBasePin);
	assign subsetBase = (C_HAS_B_SIGNED == 0 ? subsetBaseSig : subsetBasePin);
	assign addsubclrBase = (C_HAS_B_SIGNED == 0 ? addsubclrBaseSig : addsubclrBasePin);
	assign addsubsetBase = (C_HAS_B_SIGNED == 0 ? addsubsetBaseSig : addsubsetBasePin);

	assign tmpsetsatlogicmsb_sg00 = (C_ADD_MODE == `c_add ? (C_HAS_BYPASS == 1 ? addsetBase & intBYPASSbar : addsetBase) : (C_ADD_MODE == `c_sub ? (C_HAS_BYPASS == 1 ? subsetBase & intBYPASSbar : subsetBase) : (C_HAS_BYPASS == 1 ? addsubsetBase & intBYPASSbar : addsubsetBase) ));							 
	assign tmpsetsatlogicmsb_sg01 = tmpsetsatlogicmsb_sg00 & ~intSCLR ;							 
	assign tmpsetsatlogicmsb_sg10 = tmpsetsatlogicmsb_sg00 | intSSET ;								 
	assign tmpsetsatlogicmsb_sg11c = (tmpsetsatlogicmsb_sg00 | intSSET) & ~intSCLR ;
	assign tmpsetsatlogicmsb_sg11s = tmpsetsatlogicmsb_sg00 | intSSET ;
	
	assign tmpsetsatlogicrest_sg00 = (C_ADD_MODE == `c_add ? (C_HAS_BYPASS == 1 ? addclrBase & intBYPASSbar : addclrBase) : (C_ADD_MODE == `c_sub ? (C_HAS_BYPASS == 1 ? subclrBase & intBYPASSbar : subclrBase) : (C_HAS_BYPASS == 1 ? addsubclrBase & intBYPASSbar : addsubclrBase) ));									 
	assign tmpsetsatlogicrest_sg01 = tmpsetsatlogicrest_sg00 & ~intSCLR ;							 
	assign tmpsetsatlogicrest_sg10 = tmpsetsatlogicrest_sg00 | intSSET ;							 
	assign tmpsetsatlogicrest_sg11c = (tmpsetsatlogicrest_sg00 | intSSET) & ~intSCLR ;  						  
	assign tmpsetsatlogicrest_sg11s = tmpsetsatlogicrest_sg00 | intSSET ;  						  
	
	assign tmpclrsatlogicmsb_sg00 = tmpsetsatlogicrest_sg00 ;							 
	assign tmpclrsatlogicmsb_sg01 = tmpsetsatlogicrest_sg00 | intSCLR ;							 
	assign tmpclrsatlogicmsb_sg10 = tmpsetsatlogicrest_sg00 & ~intSSET ;							 
	assign tmpclrsatlogicmsb_sg11c = tmpsetsatlogicrest_sg00 | intSCLR ; 						  
	assign tmpclrsatlogicmsb_sg11s = (tmpsetsatlogicrest_sg00 | intSCLR) & ~intSSET ;  						  
	
	assign tmpclrsatlogicrest_sg00 = tmpsetsatlogicmsb_sg00 ;							 
	assign tmpclrsatlogicrest_sg01 = tmpsetsatlogicmsb_sg00 | intSCLR ;							 
	assign tmpclrsatlogicrest_sg10 = tmpsetsatlogicmsb_sg00 & ~intSSET ;							 
	assign tmpclrsatlogicrest_sg11c = tmpsetsatlogicmsb_sg00 | intSCLR ;							 
	assign tmpclrsatlogicrest_sg11s = (tmpsetsatlogicmsb_sg00 | intSCLR) & ~intSSET ;					 
	
	assign intSSET_TO_MSB = (C_HAS_SSET == 0 ? (C_HAS_SCLR == 0 ? tmpsetsatlogicmsb_sg00 : tmpsetsatlogicmsb_sg01) :
									(C_HAS_SCLR == 0 ? tmpsetsatlogicmsb_sg10 : 
										(C_SYNC_PRIORITY == `c_clear ? tmpsetsatlogicmsb_sg11c : tmpsetsatlogicmsb_sg11s)));
										
	assign intSCLR_TO_MSB = (C_HAS_SSET == 0 ? (C_HAS_SCLR == 0 ? tmpclrsatlogicmsb_sg00 : tmpclrsatlogicmsb_sg01) :
									(C_HAS_SCLR == 0 ? tmpclrsatlogicmsb_sg10 : 
										(C_SYNC_PRIORITY == `c_clear ? tmpclrsatlogicmsb_sg11c : tmpclrsatlogicmsb_sg11s)));
										
	assign intSSET_TO_REST = (C_HAS_SSET == 0 ? (C_HAS_SCLR == 0 ? tmpsetsatlogicrest_sg00 : tmpsetsatlogicrest_sg01) :
									(C_HAS_SCLR == 0 ? tmpsetsatlogicrest_sg10 : 
										(C_SYNC_PRIORITY == `c_clear ? tmpsetsatlogicrest_sg11c : tmpsetsatlogicrest_sg11s)));
										
	assign intSCLR_TO_REST = (C_HAS_SSET == 0 ? (C_HAS_SCLR == 0 ? tmpclrsatlogicrest_sg00 : tmpclrsatlogicrest_sg01) :
									(C_HAS_SCLR == 0 ? tmpclrsatlogicrest_sg10 : 
										(C_SYNC_PRIORITY == `c_clear ? tmpclrsatlogicrest_sg11c : tmpclrsatlogicrest_sg11s)));

	// Finally we are ready to scale the feedback signal...
	// If the scaling factor results in NO bits being fed back to the input then we need to handle this!
	// This is the case if C_SCALE >= C_OUT_WIDTH
	assign intFB[C_OUT_WIDTH-1-(C_SCALE >= C_OUT_WIDTH ? 0 : C_SCALE) : 0] = (C_SCALE >= C_OUT_WIDTH ? {C_OUT_WIDTH{1'b0}} : intFBq[C_OUT_WIDTH-1 : (C_SCALE >= C_OUT_WIDTH ? 0 : C_SCALE)]);
	//assign intFB[C_OUT_WIDTH-1 : C_OUT_WIDTH-(C_SCALE == 0 ? 1 : C_SCALE)] = (C_SCALE == 0 ? intFBq[C_OUT_WIDTH-1] : (C_SCALE < C_OUT_WIDTH && (C_B_TYPE == `c_signed || (C_B_TYPE == `c_pin && intB_SIGNED === 1'b1)) ?
	//						{C_SCALE{intFBq[C_OUT_WIDTH-1]}} : {C_SCALE{1'b0}}));
	assign intFB[C_OUT_WIDTH-1 : C_OUT_WIDTH-(C_SCALE == 0 ? 1 : C_SCALE)] = (C_SCALE == 0 ? intFBq[C_OUT_WIDTH-1] : (C_SCALE < C_OUT_WIDTH && (C_B_TYPE == `c_signed || C_B_TYPE == `c_pin) ?
							{C_SCALE{intFBq[C_OUT_WIDTH-1]}} : {C_SCALE{1'b0}}));

							
	
											
	initial
	begin
		#1;
	end
				
/* helper functions */
	
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
		
	function [C_B_WIDTH - 1 : 0] to_bitsB;
	input [C_B_WIDTH*8 : 1] instring;
	integer i;
	integer non_null_string;
	begin
		non_null_string = 0;
		for(i = C_B_WIDTH; i > 0; i = i - 1)
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
			for(i = C_B_WIDTH; i > 0; i = i - 1)
				to_bitsB[i-1] = 0;
		end
		else
		begin
			for(i = C_B_WIDTH; i > 0; i = i - 1)
			begin // Is this character a '0'? (ASCII = 48 = 00110000)
				if(instring[(i*8)] == 0 && 
					instring[(i*8)-1] == 0 && 
					instring[(i*8)-2] == 1 && 
					instring[(i*8)-3] == 1 && 
					instring[(i*8)-4] == 0 && 
					instring[(i*8)-5] == 0 && 
					instring[(i*8)-6] == 0 && 
					instring[(i*8)-7] == 0)
						to_bitsB[i-1] = 0;
				  // Or is it a '1'? 
				else if(instring[(i*8)] == 0 && 
					instring[(i*8)-1] == 0 && 
					instring[(i*8)-2] == 1 && 
					instring[(i*8)-3] == 1 && 
					instring[(i*8)-4] == 0 && 
					instring[(i*8)-5] == 0 && 
					instring[(i*8)-6] == 0 && 
					instring[(i*8)-7] == 1)		
						to_bitsB[i-1] = 1;
				  // Or is it a ' '? (a null char - in which case insert a '0')
				else if(instring[(i*8)] == 0 && 
					instring[(i*8)-1] == 0 && 
					instring[(i*8)-2] == 0 && 
					instring[(i*8)-3] == 0 && 
					instring[(i*8)-4] == 0 && 
					instring[(i*8)-5] == 0 && 
					instring[(i*8)-6] == 0 && 
					instring[(i*8)-7] == 0)		
						to_bitsB[i-1] = 0;
				else
				begin
					$display("Error in %m at time %d ns: non-binary digit in string \"%s\"\nExiting simulation...",$time, instring);
					$finish;
				end
			end
		end 
	end
	endfunction
	
	function max;
	input a;
	input b;
	begin
		max = (a > b) ? a : b;
	end
	endfunction
		
endmodule

`undef c_set
`undef c_clear
`undef c_override
`undef c_no_override
`undef c_add
`undef c_sub
`undef c_add_sub
`undef c_signed
`undef c_unsigned
`undef c_pin
`undef allUKs







