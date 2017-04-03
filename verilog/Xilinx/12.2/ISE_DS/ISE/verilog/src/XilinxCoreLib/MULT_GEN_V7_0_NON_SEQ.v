// Copyright(C) 2004 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.


/* $Id:
--
-- Filename - MULT_GEN_V7_0_NON_SEQ.v
-- Author - Xilinx
-- Creation - 22 Mar 1999
--
-- Description - This file contains the Verilog behavior for the 
-- non-sequential multiplier module
*/

`timescale 1ns/10ps

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
`define c_distributed 0
`define c_dp_block 2
`define allUKs {(C_OUT_WIDTH)+1{1'bx}}
`define all0s {(C_OUT_WIDTH)+1{1'b0}}
`define ball0s {(C_B_WIDTH)+1{1'b0}}
`define ballxs {(C_B_WIDTH)+1{1'bx}}
`define aall0s {(C_BAAT+C_HAS_A_SIGNED)+1{1'b0}}
`define aall1s {(C_BAAT+C_HAS_A_SIGNED)+1{1'b1}}
`define aallxs {(C_BAAT+C_HAS_A_SIGNED)+1{1'bx}}
`define inall0s {(C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE))+1{1'b0}}
`define baatall0s {(C_BAAT)+1{1'b0}}
`define baatall1s {(C_BAAT)+1{1'b1}}
`define baatallxs {(C_BAAT)+1{1'bx}}

module MULT_GEN_V7_0_NON_SEQ (A, B, CLK, A_SIGNED, CE, ACLR,
					  SCLR, LOADB, LOAD_DONE, SWAPB, RFD,
					  ND, RDY, O, Q);

	parameter BRAM_ADDR_WIDTH   = 8;
	parameter C_A_TYPE 			= `c_signed;
	parameter C_A_WIDTH 		= 16;
	parameter C_BAAT			= 2;
	parameter C_B_CONSTANT 		= `c_signed;
	parameter C_B_TYPE 			= `c_signed;
	parameter C_B_VALUE 		= "0000000000000001";
	parameter C_B_WIDTH 		= 16;
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_A_SIGNED 	= 0;
	parameter C_HAS_B			= 1;
	parameter C_HAS_CE 			= 0;
	parameter C_HAS_LOADB		= 0;
	parameter C_HAS_LOAD_DONE	= 0;
	parameter C_HAS_ND			= 0;
	parameter C_HAS_O			= 0;
	parameter C_HAS_Q 			= 1;
	parameter C_HAS_RDY			= 0;
	parameter C_HAS_RFD			= 0;
	parameter C_HAS_SCLR		= 0;
	parameter C_HAS_SWAPB		= 0;
	parameter C_MEM_INIT_PREFIX	= "mem";
	parameter C_MEM_TYPE    	= 0;
	parameter C_MULT_TYPE	 	= 0;
	parameter C_OUTPUT_HOLD		= 0;
	parameter C_OUT_WIDTH		= 16;
	parameter C_PIPELINE 		= 0;
	parameter C_PRE_DELAY       = 0;
	parameter C_REG_A_B_INPUTS  = 1;
	parameter C_SQM_TYPE		= 0;
	parameter C_STACK_ADDERS	= 0;
        parameter C_STANDALONE          = 0;
	parameter C_SYNC_ENABLE		= 0;
	parameter C_USE_LUTS		= 1;

	//Internal parameters

	parameter incA = (((C_HAS_A_SIGNED == 1 || C_A_TYPE == `c_signed) && C_B_TYPE == `c_unsigned) ?  1 : 0) ;
	parameter incB = (C_B_TYPE == `c_signed ? 1 : 0) ;
	parameter inc = ((C_B_TYPE == `c_unsigned && C_A_TYPE == `c_unsigned) ? 0 : 1) ;
	parameter dec = ((C_B_TYPE == `c_unsigned && C_A_TYPE == `c_unsigned) ? 1 : 0) ;
	parameter inc_a_width = ((C_BAAT < C_A_WIDTH && (C_HAS_A_SIGNED == 1 || C_A_TYPE == `c_signed) && C_HAS_LOADB == 0) ? 1 : 0) ;
	parameter decrement = ((C_HAS_A_SIGNED == 1 || (C_A_TYPE == `c_signed && C_BAAT < C_A_WIDTH)) ? 1 : 0) ;

	//Parameters to calculate the latency for the parallel multiplier.
	parameter a_ext_width_par = (C_HAS_A_SIGNED == 1 ? C_BAAT+1 : C_BAAT) ;
	parameter a_ext_width_seq = ((C_HAS_A_SIGNED == 1 || C_A_TYPE == `c_signed) ? C_BAAT+1 : C_BAAT) ;
	parameter a_ext_width = (C_BAAT < C_A_WIDTH ? a_ext_width_seq : a_ext_width_par) ;

    /* Compare the width of the A port, to the width of the B port
	If the A port is smaller, then swap these over, otherwise leave
	alone */

    parameter a_t_2 = (C_A_TYPE == `c_pin ? `c_signed : C_A_TYPE);

    parameter a_w = (C_A_WIDTH < C_B_WIDTH ? C_B_WIDTH : a_ext_width);
    parameter a_t = (C_A_WIDTH < C_B_WIDTH ? C_B_TYPE : a_t_2);
    parameter b_w = (C_A_WIDTH < C_B_WIDTH ? a_ext_width : C_B_WIDTH);
    parameter b_t = (C_A_WIDTH < C_B_WIDTH ? a_t_2 : C_B_TYPE);

    // The mult18 parameter signifies if the final mult18x18 primitive is used
    // without having to pad with zeros, or sign extending - thus leading to
    // a more efficient implementation - e.g. a 35x35 (signed x signed) multiplier
    // mult18, is used in the calculation of a_prods and b_prods, which indicate
    // how many mult18x18 primitives are requred.
   
    //parameter mult18 = (((a_t == `c_signed && a_w % 17 == 1) 
    //       && ((b_t == `c_signed && b_w <= a_w) || (b_t == `c_unsigned && b_w < a_w)) && (b_w % 18 != 0)) ? 1 : 0);   
	parameter mult18a = (a_t == `c_signed && a_w % 17 == 1);
	parameter mult18b = (b_t == `c_signed && b_w % 17 == 1);
   
	parameter a_prods = ((a_w-1)/(17+mult18a)) + 1; //(a_ext_width-1)/(17 + mult18a) + 1 ;
	parameter b_prods = ((b_w-1)/(17+mult18b)) + 1; //(C_B_WIDTH-1)/(17 + mult18b) + 1 ;
	parameter a_count = (a_ext_width+1)/2 ;
	parameter b_count = (C_B_WIDTH+1)/2 ;
	parameter parm_numAdders = ((C_MULT_TYPE == 1 || C_MULT_TYPE == 5) ? (a_prods*b_prods) : ((a_ext_width <= C_B_WIDTH) ? a_count : b_count)) ;
	parameter ignore_nd = ((C_HAS_ND == 0 || (C_HAS_ND == 1 && C_REG_A_B_INPUTS == 0 && C_HAS_Q == 0 && (C_PIPELINE == 0 || parm_numAdders == 1))) ? 1 : 0);
	parameter true_ce = (C_HAS_CE == 1 ? 1 : (ignore_nd == 1 ? 0 : 1));
	parameter mult18s = (C_MULT_TYPE == 5 ? 1 : (C_MULT_TYPE != 1 ? 0 : ((C_HAS_ACLR == 0 && (~(C_SYNC_ENABLE == 1 && C_HAS_SCLR == 1 && true_ce == 1))) ? 1 : 0)));

	//Parameters to calculate the latency for the constant coefficient multiplier.
	parameter rom_addr_width = (C_MEM_TYPE == `c_distributed ? 4 : BRAM_ADDR_WIDTH) ;
	parameter sig_addr_bits = (C_BAAT >= rom_addr_width ? rom_addr_width : C_BAAT) ;
	parameter effective_op_width = ((C_BAAT == C_A_WIDTH && (C_HAS_A_SIGNED == 0 || C_HAS_LOADB == 1)) ? C_BAAT : ((C_BAAT == C_A_WIDTH) ? C_BAAT+1 : (C_BAAT < C_A_WIDTH ? C_BAAT+inc_a_width : C_BAAT+1))) ;
	parameter a_input_width = ((effective_op_width % rom_addr_width == 0) ? effective_op_width : effective_op_width + rom_addr_width - (effective_op_width % rom_addr_width)) ;
	parameter mod = a_input_width % rom_addr_width ;
	parameter op_width = (mod == 0 ? a_input_width : (a_input_width + rom_addr_width) - mod) ;
	parameter a_width = (C_BAAT < C_A_WIDTH ? C_A_WIDTH : op_width) ;
	parameter need_addsub = ((C_HAS_LOADB == 1 && (C_A_TYPE == `c_signed || C_HAS_A_SIGNED == 1)) ? 1 : 0) ;
	parameter ccm_numAdders_1 = (mod == 0 ? (a_input_width/rom_addr_width) : (a_input_width/rom_addr_width)+1) ;
	parameter need_0_minus_pp = ((need_addsub == 1 && ccm_numAdders_1 <= 1) ? 1 : 0) ;
	parameter ccm_numAdders = (need_0_minus_pp == 1 ? 1 : ccm_numAdders_1 - 1) ;
	parameter ccm_init1 = ((C_HAS_LOADB == 1 && C_MEM_TYPE == `c_dp_block) ? 1 : 0) ;
	parameter ccm_init2 = ((C_HAS_LOADB == 1 && (C_A_TYPE == `c_signed || C_HAS_A_SIGNED == 1) && C_PIPELINE == 1) ? 1 : 0) ;
	parameter ccm_init3 = (((ccm_numAdders > 0 || C_HAS_SWAPB == 1) && (C_PIPELINE == 1 || C_MEM_TYPE == `c_dp_block)) ? 1 : 0) ;
	parameter ccm_init4 = ((ccm_numAdders > 0 && C_HAS_SWAPB == 1 && C_PIPELINE == 1) ? 1 : 0) ;
	parameter ccm_initial_latency = ccm_init1 + ccm_init2 + ccm_init3 + ccm_init4 ;

	//Latency calculation
	parameter numAdders = ((C_MULT_TYPE < 2 || C_MULT_TYPE == 5) ? parm_numAdders - 1 : ccm_numAdders) ;
	parameter log = (C_PIPELINE == 1 ? (numAdders < 2 ? 0 : (numAdders < 4 ? 1 : (numAdders < 8 ? 2 : (numAdders < 16 ? 3 : (numAdders < 32 ? 4 : (numAdders < 64 ? 5 : (numAdders < 128 ? 6 : 7))))))) : 0) ; 
	parameter C_LATENCY_sub1 = (C_MULT_TYPE < 2 ? (numAdders > 0 ? (mult18s + log + 1) : (C_PIPELINE == 1 ? mult18s : 0)) : (numAdders > 0 ? (ccm_initial_latency + log) : ccm_initial_latency)) ;
	parameter C_LATENCY_V4 = (C_PIPELINE == 1 ? (parm_numAdders + 1) : 0);
	parameter C_LATENCY_sub = (C_MULT_TYPE == 5 ? C_LATENCY_V4 : C_LATENCY_sub1);
	parameter C_LATENCY = (C_PIPELINE == 1 ? C_LATENCY_sub : (C_MULT_TYPE < 2 ? 0 : C_LATENCY_sub)) ;

    parameter MULT_TYPE = (C_MULT_TYPE == 5 ? 1 : C_MULT_TYPE);
    parameter c_pipe = (C_PIPELINE == 1 || C_LATENCY > 0) ? 1 : 0 ;

	parameter multWidth = C_A_WIDTH+C_B_WIDTH+decrement+1 ;
    parameter rfd_stages = 1; 

    parameter no_aclr = (MULT_TYPE == 2 && (C_HAS_Q == 0 || (numAdders == 0 && C_MEM_TYPE == 2)) && 
                         C_REG_A_B_INPUTS == 0 && C_HAS_RFD == 0 &&
                        (C_LATENCY == 0 || (numAdders == 1 && C_MEM_TYPE == 2) || (C_LATENCY == 1 && 
                         C_PIPELINE == 0 && C_MEM_TYPE == 2 && MULT_TYPE == 2)) && 
                        ~(C_B_WIDTH == 1 && MULT_TYPE == 2 && C_HAS_Q == 1 && C_MEM_TYPE == 2) ? 1 : 0); 

    parameter ncelab_inta_high = ((C_A_WIDTH == C_BAAT) ? C_A_WIDTH : (C_SQM_TYPE == 0 ? C_A_WIDTH : 1));

	`define mall0s {(multWidth)+1{1'b0}}
	`define mallUKs {(multWidth)+1{1'bx}}

	input [(C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE)) : 0] A;
	input [C_B_WIDTH-1 : 0] B;
	input CLK;
	input CE;
	input A_SIGNED;
	input LOADB;
	input SWAPB;
	input ND;
	input ACLR;
	input SCLR;
	output RFD;
	output RDY;
	output LOAD_DONE;
	output [C_OUT_WIDTH-1 : 0] O;
	output [C_OUT_WIDTH-1 : 0] Q;
	 
	// Internal values to drive signals when input is missing
	wire [C_B_WIDTH-1 : 0] intBconst;
	reg [C_B_WIDTH-1 : 0] intB;
	reg [(C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE)) : 0] intA;
	wire [C_B_WIDTH-1 : 0] regB;
	wire [C_B_WIDTH-1 : 0] regB_cased;
	wire [(C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE)) : 0] regA;
	wire [C_B_WIDTH-1 : 0] B_DLY_1;
	wire [C_B_WIDTH-1 : 0] B_DLY_2;
	wire LOADB_DLY_1;
	wire LOADB_DLY_2;
	wire SWAPB_DLY_1;
	wire SWAPB_DLY_2;
	reg [C_B_WIDTH-1 : 0] b_const0;
	reg [C_B_WIDTH-1 : 0] b_const1;
	reg [C_B_WIDTH-1 : 0] loadb_value ;
	reg [C_B_WIDTH-1 : 0] B_INPUT;

	wire intCE;
	wire intCE_cased;
	reg  intA_SIGNED;
	wire regA_SIGNED;
	reg  intACLR;
	reg  intSCLR;
	wire ND_I;
	wire [(C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE)) : 0] A_I;
	wire [C_B_WIDTH-1 : 0] B_I;
	wire LOADB_I;
	wire SWAPB_I;
	wire initial_intCLK;
	reg  intCLK;
	reg  last_clk;
	wire intLOADB;
	wire intLOADB_no_predelay;
	reg  loaded;
	wire intSWAPB;
	reg  regND_nonseq;
	wire regND_ccm;
	wire regND_parm;
	wire regND;
	wire intND ;
	wire intRDY;
	reg  intRDY_rl;
	wire intRDY_rl_pre_reg;
	reg  intRFD;
	reg  intRFD_rel;
	reg  regRFD ;
	reg  regRDY ;
	reg  intLOAD_DONE;
	reg  [C_OUT_WIDTH-1 : 0 ] O_I;
	reg  [C_OUT_WIDTH-1 : 0 ] Q_I;
	reg  RDY_I;
	reg  [C_OUT_WIDTH-1 : 0 ] intO;
	reg  lastCLK;
	reg  [C_BAAT-1 : 0] max_a_val ;
    reg  power_2;
    
	reg  [multWidth-1 : 0] a_value ;
	reg  [multWidth-1 : 0] b_value ;
	reg  [multWidth-1 : 0] max_result ;
    reg  [multWidth : 0] max_result1 ;
    reg  [multWidth : 0] max_result2 ;
	
	reg  [C_OUT_WIDTH-1 : 0] intQpipe [C_LATENCY+1 : 0]; 
	reg  [C_LATENCY : 0] intRDYpipe;

    // Output ports.
    wire [C_OUT_WIDTH-1 : 0] Q;
	wire [C_OUT_WIDTH-1 : 0] O;
	wire RDY;
	wire RFD;
	wire LOAD_DONE;

	// Assign values to the output ports after a delay.
    assign #1 Q = (C_HAS_Q == 1 ? Q_I : `allUKs);
	assign #1 O = (C_HAS_O == 1 ? O_I : `allUKs);
	assign #1 RDY = (C_HAS_RDY == 1 ? (C_HAS_ND == 1 ? (C_HAS_Q == 1 ? regRDY : RDY_I) : 1) : 1'bx);
	assign #1 RFD = (C_HAS_RFD == 1 ? intRFD : 1'bx);
	assign #1 LOAD_DONE = (C_HAS_LOAD_DONE == 1 ? intLOAD_DONE : 1'bx);
	
	// Sort out default values for missing ports
	assign regND = regND_nonseq; 
	assign intCE = (C_HAS_CE == 1 ? CE : 1);
	assign intCE_cased = ((C_HAS_CE == 1 && C_HAS_ND == 1) ? 
	                      (C_SYNC_ENABLE == 1 ? ((~intLOAD_DONE) | (intCE & ND_I)) 
	                                          : ((~intLOAD_DONE) | (intCE & ND_I) | intSCLR)) 
	                    : (C_HAS_ND == 1 ? 
	                      (C_SYNC_ENABLE == 1 ? ((~intLOAD_DONE) | ND_I) 
	                                          : ((~intLOAD_DONE) | ND_I | intSCLR)) 
	                    : 1'b1));
	assign initial_intCLK = CLK;
	assign intND = ((C_HAS_ND == 1 && ND !== 1'bz) ? ND : 1);

	assign intLOADB = ((C_HAS_LOADB == 1 && MULT_TYPE > 2) ? LOADB_I : 0) ;
	assign intLOADB_no_predelay = ((C_HAS_LOADB == 1 && MULT_TYPE > 2) ? LOADB : 0);
	assign intSWAPB = ((C_HAS_SWAPB == 1 && MULT_TYPE > 2) ? SWAPB_I : 0) ;

	//assign intSCLR = (C_HAS_SCLR == 1 ? SCLR : 0);
	assign ND_I = ((C_HAS_ND == 1 && ND !== 1'bz) ? ND : 1);
	assign A_I = A; 
	assign B_I = (C_PRE_DELAY == 0 ? B : (C_PRE_DELAY == 1 ? B_DLY_1 : B_DLY_2));
	assign SWAPB_I = (C_PRE_DELAY == 0 ? SWAPB : (C_PRE_DELAY == 1 ? SWAPB_DLY_1 : SWAPB_DLY_2));
	assign LOADB_I = (C_PRE_DELAY == 0 ? LOADB : (C_PRE_DELAY == 1 ? LOADB_DLY_1 : LOADB_DLY_2));

    assign intRDY_rl_pre_reg = intND & intLOAD_DONE;
	assign intRDY = (MULT_TYPE == 3 ? (C_REG_A_B_INPUTS == 0 ? ND_I & intLOAD_DONE : intRDY_rl) 
                  : (MULT_TYPE > 1 ? (C_REG_A_B_INPUTS == 0 ? ND_I : regND) 
                  : ((C_LATENCY+C_REG_A_B_INPUTS == 0 || (C_LATENCY == 1 && C_REG_A_B_INPUTS == 0 && C_HAS_Q == 0)) ? ND_I & intCE 
                  : ((C_LATENCY == 0 && C_REG_A_B_INPUTS == 1 && C_HAS_Q == 0) ? regND_ccm : regND & intCE))));

	integer j, k, test1, msb;
	integer pipe, pipe1;
	integer i;
	integer cycle, loadb_count, loadb_count_no_predelay, loadb_count_dly, loadb_count_dly_int, out_width, tmp_out_width, b_is_negative, b_width, new_data_present;
	integer stay_x, bank_sel, bank_sel_pre, loadb_delay, pre_delay_comp ;
	integer shift_bits, real_latency ;
	integer loading, cycle_discarded, b_is_zero, b_is_one, a_negative, b_negative ;
	
	reg  [C_B_WIDTH-1 : 0] initB_INPUT;
	reg  [multWidth-1 : 0] tmpA;
	reg  [multWidth-1 : 0] tmpB;
	reg  [multWidth-1 : 0] tmpAB;
	reg  tmpA_SIGNED ;

	reg  [multWidth-1 : 0] one;
	reg  [multWidth-1 : 0] zero ;
	reg  cleared;

	reg  [multWidth-1 : 0] product ;
	reg  [multWidth-1 : 0] product_delayed ;
	reg  [C_LATENCY : 0] intPRODUCTpipe [multWidth-1 : 0] ;

    //Input registers.
	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, (C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE))+1)
		rega (.D(A_I), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regA)); 

    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, C_B_WIDTH)
		regad1 (.D(B), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(B_DLY_1));

    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, C_B_WIDTH)
		regad2 (.D(B_DLY_1), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(B_DLY_2));

    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regswapb1 (.D(SWAPB), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(SWAPB_DLY_1));

    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regswapb2 (.D(SWAPB_DLY_1), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(SWAPB_DLY_2));

    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regloadb1 (.D(LOADB), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(LOADB_DLY_1));

    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regloadb2 (.D(LOADB_DLY_1), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(LOADB_DLY_2));

	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, C_B_WIDTH)
		regb (.D(B_INPUT), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regB)); 

    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   1, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, C_B_WIDTH)
		regb_cased (.D(B_INPUT), .CLK(intCLK), .CE(intCE_cased), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regB_cased));

	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regnd (.D(ND), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regND_ccm)); 

	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   0, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regndparm (.D(ND), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regND_parm));

	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regasig (.D(A_SIGNED), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regA_SIGNED)); 

	initial
	begin
	  B_INPUT = (MULT_TYPE < 2) ? B : to_bitsB(C_B_VALUE);
	  if (MULT_TYPE > 2 && C_B_TYPE == `c_signed)
	  begin
		j = 0 ;
		msb = 0 ;
		//Find the length of the C_B_VALUE string
		for(i = 0; i < (C_B_WIDTH*8); i = i + 1)
		begin
          if(C_B_VALUE[i] == 0 || C_B_VALUE[i] == 1)
			msb = i/8 ;
		  end
		  //Pad it with 1's if it is signed and negative.
		  for(i = msb; i < C_B_WIDTH; i = i + 1)
		  begin
			B_INPUT[i] = B_INPUT[msb];
		  end
		end
		//Initialise all the signals that need to be initialised at start up.
		intRFD = 1 ;
		regRFD = 1 ;
		loading = 0 ;
		intRFD_rel = 1;

		if (C_HAS_ND == 1 && C_BAAT == C_A_WIDTH)
		begin
		  regRDY = 0;
		  RDY_I = 0;
		  intRDY_rl = 0;
		end
		else
		begin
		  regRDY = 1;
		  RDY_I = 1;
		  intRDY_rl = 1;
		end

		O_I = `all0s;
		bank_sel = 0 ;
		bank_sel_pre = 0;
		b_const0 = B_INPUT ;
		b_const1 = B_INPUT ;
		loadb_value = B_INPUT ;
		intB = B_INPUT ;
		tmpB = B_INPUT ;
		intLOAD_DONE = 1 ;
		loadb_count = -1 ;
		loadb_count_no_predelay = -1;
		loaded = 0 ;
		stay_x = 0;
		tmpA = `aallxs;
		//tmpAB = `mall0s;
		intACLR = 0;
		intSCLR = 0;
		cleared = 0;

		if (C_HAS_ND == 0)
		begin
		  for(k = 0 ; k <= C_LATENCY; k = k + 1)
		  begin
			intRDYpipe[k] = 1 ;
		  end
		end
		else if (C_HAS_ND == 1)
		begin
		  for(k = 0 ; k <= C_LATENCY; k = k + 1)
		  begin
			intRDYpipe[k] = 0 ;
  		  end
		end
		initB_INPUT = (MULT_TYPE < 2) ? B : to_bitsB(C_B_VALUE);
		new_data_present = 0 ;

		//Clear the pipeline and the inputs if there are registers involved.
		for(j = 0; j < multWidth; j = j + 1)
		begin
		  if (C_REG_A_B_INPUTS == 1)
		  begin
			intA[j] = 0 ;
			tmpA[j] = 0 ;
			if(MULT_TYPE < 2)
			begin
			  intB[j] = 0 ;
			  tmpB[j] = 0 ;
	  	    end
		  end
		end
		for (j = 0; j <= C_LATENCY; j = j + 1)
		begin
 		  intQpipe[j] = `all0s ;
	    end

		for(i = 0; i < multWidth; i = i + 1)
		begin
		  if (i > 0)
		  begin
			one[i] = 0 ;
			zero[i] = 0 ;
	  	  end
		  else
		  begin
			one[i] = 1 ;
			zero[i] = 0 ;
		  end
		end
		
		if (MULT_TYPE > 2)
		begin
		  loadb_delay = 1 ;
		  for(i = 0; i < sig_addr_bits; i = i + 1)
		  begin
			loadb_delay = 2*loadb_delay ;
	  	  end
		  loadb_delay = loadb_delay-1 ;
		  if (C_PRE_DELAY == 0)
			pre_delay_comp = 0;
	      else if (C_PRE_DELAY == 1)
			pre_delay_comp = 1;
		  else if (C_PRE_DELAY == 2 && loadb_delay > 1)
			pre_delay_comp = 2;
		  else
			pre_delay_comp = loadb_delay;
		end

		//Find the real b input width
		if (MULT_TYPE > 1 && C_HAS_LOADB == 0)
		begin
		  b_width = 0 ;
		  for(i = 0; i < C_B_WIDTH; i = i + 1)
		  begin
		    if(initB_INPUT[i] == 1)
			  b_width = i+1 ;
		  end 
		end
		else
		begin
		  b_width = C_B_WIDTH ;
		end

		//Calculate the output width of the multiplier.
		a_negative = 0 ;
		b_negative = 0 ;
		
        power_2 = 1'b1; 
        for (i = 0; i < C_B_WIDTH; i = i + 1) 
        begin 
          if ((initB_INPUT[i] == 1) && (i!=C_B_WIDTH-1))
            power_2 = 1'b0;
        end
              
        if (C_A_TYPE == `c_signed)
		begin
		  a_negative = 1 ;
		  max_a_val = `aall0s ;
          max_a_val[C_BAAT-1] = 1;
		end
		else
		begin
		  max_a_val = `aall1s ;
		end

        if ((initB_INPUT[b_width-1] == 1) && (C_B_TYPE == `c_signed))
		  b_negative = 1 ;

		for (i = 0; i < b_width; i = i + 1)
		begin
	 	  if ((initB_INPUT[b_width-1] == 1) && (C_B_TYPE == `c_signed))
		  begin
			b_value[i] = ~initB_INPUT[i] ;
		  end
		  else
		  begin
			b_value[i] = initB_INPUT[i] ;
		  end
		end
        
		for (i = 0; i < C_BAAT; i = i + 1)
		begin
		  a_value[i] = max_a_val[i] ;
		end
		for (i = C_BAAT; i < multWidth; i = i + 1)
		begin
		  if(a_negative == 1 && power_2 ==1 )
			a_value[i] = 1 ;
          else
            a_value[i] = 0 ;
		end

		for (i = b_width; i < multWidth; i = i + 1)
		begin
		  if (C_B_TYPE == `c_signed && b_value[b_width-1] == 1)
		  begin
		    b_value[i] = 1 ;
		  end
		  else
		  begin
			b_value[i] = 0 ;
		  end
		end

		if ((initB_INPUT[b_width-1] == 1) && (C_B_TYPE == `c_signed))
		begin
		  b_value = add(b_value, one) ;
		end

		for (i = b_width; i < multWidth; i = i + 1)
		begin
		  if (C_B_TYPE == `c_signed && b_value[b_width-1] == 1)
		  begin
			b_value[i] = 1 ;
		  end
		  else
		  begin
			b_value[i] = 0 ;
		  end
		end

		max_result = a_value * b_value ;

		j = 0 ;
		if ((max_result[multWidth-1] == 1) && (C_B_TYPE == `c_signed || C_A_TYPE == `c_signed || C_HAS_A_SIGNED == 1))
		  j = 1 ;

		if (MULT_TYPE > 1 && C_HAS_LOADB == 0)
		begin                                                                                              
		  if (C_A_WIDTH == 1)
		  begin
			if (C_A_TYPE == `c_signed || C_A_TYPE == `c_pin)
			begin
			  out_width = C_B_WIDTH+1;
			end
			else
			begin
			  out_width = C_B_WIDTH;
			end
		  end
		  else
		  begin
			for(i = 0; i < multWidth; i = i + 1)
			begin
			  if(max_result[i] == 1)
			    out_width = i+1 ;
			end
			tmp_out_width = out_width ;
			if (a_negative == 1 && b_negative == 1)
		      out_width = out_width+1 ;
			else if ((a_negative == 1 && b_negative == 0) || (a_negative == 0 && b_negative == 1))
			begin
		      max_result1 = max_result;
              if (power_2 == 1)
              begin
                max_result1[multWidth] = 1;
				
 		      for(i = 0; i <= multWidth; i = i + 1)
	   	   	  begin
			    if(max_result1[i] == 1)
	   		   	  tmp_out_width = i+1 ;
	  		  end
			  for(i = 0; i <= tmp_out_width; i = i + 1)
			  begin
			    if(max_result1[i] == 0)
			   	  out_width = i+2 ;
			  end
		    end
            else if ((power_2 !=1))
            begin   
              for (i = 0; i <= multWidth; i = i + 1)
			  begin
			  	max_result[i] = ~max_result[i] ;
			  end
			  max_result = add(max_result, one) ;
	   		  for(i = 0; i <= multWidth; i = i + 1)
	   		  begin
			    if(max_result[i] == 1)
	   		   	  tmp_out_width = i+1 ;
	  		  end
			  for(i = 0; i < tmp_out_width; i = i + 1)
			  begin
			    if(max_result[i] == 0)
			      out_width = i+2 ;
			  end
            end       
          end    
			
		  if (C_HAS_A_SIGNED == 1 && C_B_TYPE == `c_unsigned)
		    out_width = out_width + 1 ;
		end
	  end
	  else
	  begin
		if (MULT_TYPE > 2 && C_B_WIDTH == 1)
		begin
		  if (C_HAS_A_SIGNED == 1 && C_B_TYPE == `c_unsigned)
			out_width = C_A_WIDTH + 1 ;
		  else
			out_width = C_A_WIDTH ;
		end
		else if (MULT_TYPE > 2 && C_A_WIDTH == 1)
		begin
		  if (C_HAS_A_SIGNED == 1 && C_B_TYPE == `c_unsigned)
		    out_width = C_B_WIDTH + 1 ;
		  else
			out_width = C_B_WIDTH ;
		  end
		  else
		  begin
			if (C_HAS_A_SIGNED == 1 && C_B_TYPE == `c_unsigned)
			  out_width = C_A_WIDTH + C_B_WIDTH + 1 ;
			else
			  out_width = C_A_WIDTH + C_B_WIDTH ;
		  end
		end

		//Calculate the shift bits
		if (MULT_TYPE != 2) 
		begin
		  shift_bits = 0 ;
		end
		else
		begin
		  shift_bits = 0 ;
		  for(i = C_B_WIDTH-1; i >= 0; i = i - 1)
		  begin
			if (b_value[i] == 1)
			  shift_bits = i ;
		  end
		end

		if (MULT_TYPE == 2 && ((C_B_TYPE == `c_unsigned && (b_width-shift_bits) == 1 && C_HAS_LOADB == 0) || (C_HAS_LOADB == 0 && b_width == 0)))
		begin
		  if(C_BAAT == C_A_WIDTH)
		  begin
			real_latency = 0 ;
			if(MULT_TYPE == 2 &&
				B_INPUT[0] == 0 &&
		   		b_width == 0)
			begin
		 	  b_is_zero = 1 ;
			  b_is_one = 0 ;
			end
			else if(((MULT_TYPE == 2 &&
				B_INPUT[0] == 1 &&
		  		b_width == 1) || power_2 === 1'b1) && C_B_TYPE == `c_unsigned)
			begin
			  b_is_zero = 0 ;
			  b_is_one = 1 ;
			end
			else
			begin
			  b_is_zero = 0 ;
			  b_is_one = 0 ;
			end
		  end
		  else
		  begin
			real_latency = C_LATENCY ;
			b_is_zero = 0 ;
			b_is_one = 0 ;
		  end
		end
		else
		begin
		  real_latency = C_LATENCY ;
		  b_is_zero = 0 ;
		  b_is_one = 0 ;
		end

        if (MULT_TYPE < 3 && C_REG_A_B_INPUTS == 1)
		begin
		  tmpA <= `aall0s;
		  tmpAB <= `mall0s;
		end
	    //if (MULT_TYPE < 3)
		//begin
	    intO <= `all0s;
		intQpipe[0] <= `all0s;
		//end
        for (j = 0; j <= real_latency; j = j + 1)
		begin
			intQpipe[j] = `all0s ;
		end

        //O_I = `all0s;
		Q_I = `all0s;

	end

    always@(initial_intCLK)
	begin
		last_clk <= intCLK ;
		intCLK <= initial_intCLK ;
	end

    always@(ACLR)
	begin
	  if (C_HAS_ACLR == 1 && ACLR === 1'bz)
	    intACLR = 1'b0;
	  else if (C_HAS_ACLR == 1 && real_latency == 0 && C_REG_A_B_INPUTS == 0 
	      && MULT_TYPE < 3 && C_HAS_Q == 0)
	    intACLR = 1'b0;
	  else if (C_HAS_ACLR == 1)
	    intACLR = ACLR;
	  else
	    intACLR = 1'b0;
	end

    always@(SCLR)
	begin
	  if (C_HAS_SCLR == 1 && real_latency == 0 && C_REG_A_B_INPUTS == 0 
	      && MULT_TYPE < 3 && C_HAS_Q == 0)
	    intSCLR = 1'b0;
	  else if (C_HAS_SCLR == 1) //&& ~(MULT_TYPE == 3 && loadb_count != -1))
	    intSCLR = SCLR;
	  else
	    intSCLR = 1'b0;
	end

    //Choose between regND_ccm and regND_parm depending on the type of multiplier
	//that has been instantiated.
	always@(regND_ccm or regND_parm)
	begin
	   if (C_HAS_ND == 1)
	   begin
		 if (MULT_TYPE < 2 && C_BAAT == C_A_WIDTH)
	     begin
	       regND_nonseq = regND_parm;
	     end
	     else
	     begin
	       regND_nonseq = regND_ccm;
	     end
	   end
	   else //no ND
	   begin
	     regND_nonseq = 1;
	   end
	end

    //Calculate the RFD output for the non-sequential multiplier.
	//The effect of reloading on the RFD is taken into account later on.
	always@(intACLR or intSCLR or intRFD_rel)
	begin
	  if (intACLR === 1'b1 || intSCLR === 1'b1 || intRFD_rel === 1'b0)
	  begin
	    intRFD = 0;
	  end
	  else if (intACLR === 1'bx || intSCLR === 1'bx || intRFD_rel === 1'bx)
	  begin
		intRFD = 1'bx;
	  end
	  else
	  begin
	    intRFD = 1;
	  end
	end

    // Multiplication processes for the non-sequential multiplier.
	// The following occurs asynchronously to the clock. It helps us set 
	// up the inputs to the multiplication stage.
	always@(regA or regB or A_I or B_INPUT or A_SIGNED or regA_SIGNED or intACLR or intND)
	begin
	  if (C_BAAT == C_A_WIDTH)
	  begin
	    if (C_REG_A_B_INPUTS == 1 && MULT_TYPE < 3)
		begin
		  if (C_HAS_ND == 1 && ((C_HAS_Q == 1 && C_HAS_O == 0 && MULT_TYPE == 2) || real_latency > 0))
		  begin
		    intA        = regA;
			intB        = regB;
			intA_SIGNED = regA_SIGNED;
		  end
		  else if (C_HAS_ND == 1)
		  begin
		    if (intACLR === 1'b1) 
			begin
			  intA        = `aall0s;
              intB        = `ball0s;
			  intA_SIGNED = 0;
			end
			else if (intACLR === 1'bx) 
			begin
			  intA        = `aallxs;
              intB        = `ballxs;
			  intA_SIGNED = 1'bx;
			end
		  end
		  else // no ND
		  begin
		    intA        = regA;
			intB        = regB;
			intA_SIGNED = regA_SIGNED;
		  end
	    end
		else if (MULT_TYPE >= 3 && C_REG_A_B_INPUTS == 1)
		begin
		  if (C_HAS_ND == 1) 
		  begin
		    if (intACLR === 1'b1)
			begin
			  intA        = `aall0s;
			  intA_SIGNED = 0;
			end
			else if (intACLR === 1'bx)
			begin
			  intA        = `aallxs;
			  intA_SIGNED = 1'bx;
			end
		  end
		  else // no ND
		  begin
		    intA        = regA;
			intA_SIGNED = regA_SIGNED;
		  end
		  if (MULT_TYPE == 3 && real_latency == 0 && C_HAS_O == 1 && C_HAS_ND == 1)
		  begin
			intB = regB_cased;
		  end
		  else if (C_HAS_LOADB == 1 && C_HAS_SWAPB == 0)
		  begin
		    intB = B_INPUT;
		  end
		  else
		  begin
		    intB = regB;
		  end
		end
		else //C_REG_A_B_INPUTS = 0
		begin
		  if (MULT_TYPE < 3 || real_latency == 0) 
		  begin
		    intA        = A_I;
			intA_SIGNED = A_SIGNED;
		  end
		  else 
		  begin
		    if (intACLR === 1'b1) 
			begin
			  intA        = `aall0s;
			  intA_SIGNED = 0;
			end
			else if (intACLR === 1'bx) 
			begin
			  intA        = `aallxs;
			  intA_SIGNED = 1'bx;
			end
		  end
		  if (real_latency == 0 && MULT_TYPE == 3 
		     && C_HAS_ND == 1 && intND === 1'b1 && (intCE === 1'b1 || C_HAS_CE == 0))
		  begin
		    intB = B_INPUT;
	      end
		  else if (~(MULT_TYPE == 3 && C_HAS_ND == 1))
		  begin
		    intB = B_INPUT;
		  end
		end
	  end
	end

    //Also have to perform the input processing that occurs synchronously to the clock.
	always@(posedge intCLK)
	begin 
	  if (C_BAAT == C_A_WIDTH)
	  begin
	    if (C_REG_A_B_INPUTS == 1 && MULT_TYPE < 3)
	    begin
	      if (C_HAS_ND == 1 && ~((C_HAS_Q == 1 && C_HAS_O == 0 && MULT_TYPE == 2) || real_latency > 0)) //MULT_TYPE == 2 is Change 51101a.
	      begin
	        if (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'b0 && intACLR === 1'b0)
		    begin
		      if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		      begin
		        intA        <= `aall0s;
			    intB        <= `ball0s;
			    intA_SIGNED <= 0;
			  end
			  else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		      begin
		        intA        <= `aallxs;
			    intB        <= `ballxs;
			    intA_SIGNED <= 1'bx;
			  end
			  else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
		      begin
		        intA        <= `aallxs;
			    intB        <= `ballxs;
			    intA_SIGNED <= 1'bx;
			  end
			  else if (ND_I === 1'b1 && intCE === 1'b1) 
			  begin
			    intA        <= A_I;
			    intB        <= B_INPUT;
			    intA_SIGNED <= A_SIGNED;
			  end
			  else if (ND_I === 1'bx || intCE === 1'bx) 
			  begin
			    intA        <= `aallxs;
			    intB        <= `ballxs;
			    intA_SIGNED <= 1'bx;
			  end
		    end
		  end
        end
	    else if (MULT_TYPE >= 3 && C_REG_A_B_INPUTS == 1)
	    begin
	      if (C_HAS_ND == 1)
		  begin
		    if (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'b0 && intACLR === 1'b0)
		    begin
		      if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
			  begin
			    intA        <= `aall0s;
			    intA_SIGNED <= 0;
			  end
			  else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
			  begin
			    intA        <= `aallxs;
			    intA_SIGNED <= 1'bx;
			  end
			  else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
			  begin
			    intA        <= `aallxs;
			    intA_SIGNED <= 1'bx;
			  end
			  else if (intND === 1'b1 && intCE === 1'b1)
			  begin
			    intA        <= A_I;
			    intA_SIGNED <= A_SIGNED;
              end
			  else if (intND === 1'bx || intCE === 1'bx)
			  begin
			    intA        <= `aallxs;
			    intA_SIGNED <= 1'bx;
              end
		    end
		  end
	    end
	    else // C_REG_A_B_INPUTS = 0
	    begin
	      if (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'b0 && intACLR === 1'b0) // && ~(MULT_TYPE < 3 || C_LATENCY == 0)) 
		  begin
		    if (MULT_TYPE == 3 && C_HAS_ND == 1) 
		    begin
		      //if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
			  //begin
			  //  intB = `ball0s;
			  //end
			  //else if (intLOAD_DONE === 1'b0 || (intND === 1'b1 && (intCE === 1'b1 || C_HAS_CE == 0)))
			if (intLOAD_DONE === 1'b0 || (intND === 1'b1 && (intCE === 1'b1 || C_HAS_CE == 0)))
			  begin
		        intB = B_INPUT;
			  end
		    end
			if (~(MULT_TYPE < 3 || C_LATENCY == 0))
			begin
		    if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		    begin
		      intA        <= `aall0s;
			  intA_SIGNED <= 0;
		    end
			else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		    begin
		      intA        <= `aallxs;
			  intA_SIGNED <= 1'bx;
		    end
			else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
		    begin
		      intA        <= `aallxs;
			  intA_SIGNED <= 1'bx;
		    end
		    else if (intCE === 1'b1 && (((intND === 1'b1 && C_HAS_ND == 1) || C_HAS_ND == 0) ||
			  (MULT_TYPE == 4 && real_latency == 1 && C_MEM_TYPE == 0 && 
			    C_HAS_Q == 0 && C_HAS_SWAPB == 1)))
			begin
			  intA        <= A_I;
			  intA_SIGNED <= A_SIGNED;
			end
			else if ((intCE === 1'bx || (intND === 1'bx && C_HAS_ND == 1)) || (intCE === 1'bx && C_HAS_ND == 0))
			begin
			  intA        <= `aallxs;
			  intA_SIGNED <= 1'bx;
			end
			end
		  end
		  else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	            (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
	            (intACLR === 1'b0 && ~(MULT_TYPE < 3 || C_LATENCY == 0)))
	      begin
		    if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		    begin
		      intA <= `aallxs;
			  intA_SIGNED <= 1'bx;
		    end
		    else if (intCE !== 1'b0 && intSCLR !== 1'b1)
		    begin
		      intA <= `aallxs;
			  intA_SIGNED <= 1'bx;
		    end
		    else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		    begin
			  intA <= `aallxs;
			  intA_SIGNED <= 1'bx;
		    end
	      end
		end
	  end
	end

    // Now do the actual multiplication.
    always@(intA or intB or intA_SIGNED or loadb_count or loadb_count_dly_int)
	begin
	 if (C_BAAT == C_A_WIDTH)
	 begin
	   //Sign extend the A input.
	   if ((C_A_TYPE == `c_signed && C_HAS_A_SIGNED == 0) || (C_HAS_A_SIGNED == 1 && intA_SIGNED === 1'b1))
       begin
         for(j = multWidth-1; j >= C_A_WIDTH; j = j - 1)
	     begin
		   //tmpA[j] = intA[C_A_WIDTH-1];
		   tmpA[j] = intA[ncelab_inta_high-1];
         end
	   end
	   else if(C_HAS_A_SIGNED == 1 && intA_SIGNED === 1'bx)
	   begin
	     for(j = multWidth-1; j >= C_A_WIDTH; j = j - 1)
		 begin
	       tmpA[j] = 1'bx;
   	     end
	   end
	   else if((C_A_TYPE == `c_unsigned && C_HAS_A_SIGNED == 0) || (C_HAS_A_SIGNED == 1 && intA_SIGNED == 0))
	   begin
	     for(j = multWidth-1; j >= C_A_WIDTH; j = j - 1)
		 begin
	       tmpA[j] = 0;
		 end
	   end
	   tmpA[C_A_WIDTH-1 : 0] = intA;
	   tmpA_SIGNED = intA_SIGNED ;

	   //Sign extend the B input.
	   if (C_B_TYPE == `c_signed)
	   begin
	     for(j = multWidth-1; j >= 0; j = j - 1)
		 begin
		   if (j >= b_width)
		     tmpB[j] = intB[b_width-1];
		   else
			 tmpB[j] = intB[j] ;
		 end
	   end
	   else if(C_B_TYPE == `c_unsigned)
	   begin
		 for(j = multWidth-1; j >= 0; j = j - 1)
		 begin
		   if (j >= b_width)
	         tmpB[j] = 0;
		   else
			 tmpB[j] = intB[j] ;
		 end
	   end
	   if (C_HAS_LOADB == 1 && C_HAS_SWAPB == 0 && real_latency == 0 && loadb_count != -1 && loaded == 1)
	   begin
	     for (i = 0; i < multWidth; i = i + 1)
		 begin
		   tmpAB[i] = 1'bx ;
		 end
       end
       else if (C_HAS_LOADB == 1 && C_HAS_SWAPB == 0 && real_latency != 0 && (loadb_count != -1 || loadb_count_dly_int != -1) && loaded == 1)
	   begin
	     for (i = 0; i < multWidth; i = i + 1)
		 begin
		   tmpAB[i] = 1'bx ;
		 end
       end
	   else if (is_X(tmpA) || is_X(tmpB))
	   begin
	       tmpAB = `mallUKs;
	   end
	   else
	   begin
	       tmpAB = tmpA * tmpB;
	   end
	 end
    end

    // Add intRDY_rl. The ready for the reloadable multiplier.
	always@(intACLR)
	begin
	  if (intACLR === 1'b1)
	  begin
	    intRDY_rl = 0;
	  end
	  else if (intACLR === 1'bx && intRDY_rl !== 1'b0)
	  begin
	    intRDY_rl = 1'bx;
	  end
	end

    always@(posedge intCLK)
	begin
	  if (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'b0 && 
	     (intACLR === 1'b0 || (intACLR === 1'bx && intRDY_rl === 1'b0)))
	  begin
	    if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  intRDY_rl <= 0;
		end
		else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  if (intRDY_rl_pre_reg !== 1'b0)
		    intRDY_rl <= 1'bx;
		  else
		    intRDY_rl <= 1'b0;
		end
		else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
		begin
		  if (intRDY_rl !== 1'b0)
		    intRDY_rl <= 1'bx;
		  else
		    intRDY_rl <= 1'b0;
		end
		else if (intCE === 1'b1)
		begin
		  intRDY_rl <= intRDY_rl_pre_reg;
		end
		else if (intCE === 1'bx && intRDY_rl !== intRDY_rl_pre_reg)
		begin
		  intRDY_rl <= 1'bx;
		end
	  end
	  else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	            (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
	            (intACLR === 1'b0 || (intACLR === 1'bx && intRDY_rl === 1'b0)))
	  begin
		if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		begin
		  intRDY_rl <= 1'bx;
		end
		else if (intCE !== 1'b0 && intSCLR !== 1'b1 && intRDY_rl !== intRDY_rl_pre_reg)
		begin
		  intRDY_rl <= 1'bx;
		end
		else if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intRDY_rl !== 1'b0)
		begin
		  intRDY_rl <= 1'bx;
		end
	  end
	end

    //The rccm can have undefined outputs after an ACLR. The cleared signal helps us model
	//this.
	always@(intACLR)
	begin
	  if (intACLR === 1'b0)
	    cleared = 0;
	end

    always@(posedge intCLK)
	begin
	  if (last_clk != intCLK && intCLK === 1'b1 && last_clk === 1'b0 && intACLR === 1'b1 && intCE === 1'b1)
	    cleared <= 1;
	end

    //Model the pipeline for the non sequential multiplier.
	//Firstly do the asynchronous stuff.
	always@(tmpAB or intACLR or loadb_count or loadb_count_no_predelay)
	begin
	  if (C_BAAT == C_A_WIDTH)
	  begin
	    //if ((loadb_count != -1 || loadb_count_no_predelay != -1) && C_HAS_SWAPB == 0)
		//if (loadb_count == -2 && MULT_TYPE == 3)
		//begin
		//  intO = `allUKs;
		//end
	    //else if (MULT_TYPE > 2 && real_latency > 0 && C_REG_A_B_INPUTS == 0)
		if (MULT_TYPE > 2 && real_latency > 0 && C_REG_A_B_INPUTS == 0)
		begin
		  intO = mult_convert(tmpAB);
		end
		else if (C_REG_A_B_INPUTS == 1)
		begin
		  if (C_HAS_Q == 0 && real_latency == 0)
		  begin
		    intO = mult_convert(tmpAB);
		  end
		  else // Some registers after the input stage.
		  begin
		    if (intACLR === 1'b1 && (MULT_TYPE < 2 || C_MEM_TYPE == 0 || b_is_one == 1))
			begin
			  intO = `all0s;
			end
			else if (intACLR === 1'bx && (MULT_TYPE < 2 || C_MEM_TYPE == 0 || b_is_one == 1))
			begin
			  intO = `allUKs;
			end
		  end
		end
  	    else //C_REG_A_B_INPUTS = 0
	    begin
	      if (real_latency == 0 && C_HAS_Q == 0)
		  begin
		    intO = mult_convert(tmpAB);
		  end
		  else if (C_HAS_ND == 0 && ~(MULT_TYPE == 2 && real_latency >= 1 && C_MEM_TYPE == 2))
		  // No ACLR for the block memory.
		  begin
		    if (~(MULT_TYPE >= 2 && C_MEM_TYPE == 2 && b_is_one == 0))
			begin
		      if (intACLR === 1'b1)
		      begin
		        intO = `all0s;
		      end
			  else if (intACLR === 1'bx)
		      begin
		        intO = `allUKs;
		      end
			end
		  end
	      else if (C_HAS_ND == 1 && (MULT_TYPE < 2 && ~(real_latency == 1 && C_HAS_O == 1)) 
	          && ~(MULT_TYPE == 2 && real_latency >= 1 && C_MEM_TYPE == 2))
		  begin
		    if (intACLR === 1'b1)
		    begin
		      intO = `all0s;
		    end
			else if (intACLR === 1'bx)
		    begin
		      intO = `allUKs;
		    end
		  end
		  else if (~(MULT_TYPE == 2 && real_latency >= 1 && C_MEM_TYPE == 2)) //C_HAS_ND = 1
		  begin
            if (intACLR == 1'b1 && (MULT_TYPE < 2 || C_MEM_TYPE == 0 || b_is_one == 1))
		    begin
		      intO = `all0s;
		    end
			else if (intACLR === 1'bx)
		    begin
		      intO = `allUKs;
		    end
		  end
		end
		// Clear intO whenever we clear sub_product(0) in the vhdl.
		if ((intACLR === 1'b1))
		begin
		  if (C_MEM_TYPE == 2 && MULT_TYPE > 2 && real_latency > 1) 
		  begin
		    if (cleared == 0)
			begin
			  for (j = 1; j <= real_latency; j = j + 1)
			  begin
			    intO = `allUKs;
		 	  end
			end
		  end
		end
	  end
	end

    //Now change the intO output on the clock.
	always@(posedge intCLK)
	begin
	  if (C_BAAT == C_A_WIDTH)
	  begin
	    if (C_REG_A_B_INPUTS == 1) // && (~(loadb_count != -1 && C_HAS_SWAPB == 0))) 
		begin
		  if (~(C_HAS_Q == 0 && real_latency == 0))
		  begin
		    if (last_clk !== intCLK && intCLK === 1'b1 && last_clk ===  1'b0 && (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
			begin
			  if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0) &&
			      ~(MULT_TYPE == 3 && loadb_count != -1))
			  begin
			    intO <= `all0s;
			  end
			  else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
			  begin
			    intO <= `allUKs;
			  end
			  else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
			  begin
			    intO <= `allUKs;
			  end
			  // Ignore the ND in these cases.
			  else if ((MULT_TYPE < 2 && real_latency == 0) ||
			           (C_HAS_SWAPB == 1 || C_HAS_ND == 0))
			  begin
			    if (intCE === 1'b1)
				begin
				  intO <= mult_convert(tmpAB);
				end
				else if (intCE === 1'bx)
				begin
				  intO <= `allUKs;
				end
			  end
			  // Otherwise wait for the ND to appear before clocking the 
			  // result into the pipeline.
			  else if ((regND === 1'b1 || (MULT_TYPE == 3 && loadb_count != -1))
			             && intCE === 1'b1)
			  begin
			    intO <= mult_convert(tmpAB);
			  end
			  else if (regND === 1'bx || intCE === 1'bx)
			  begin
			    intO <= `allUKs;
			  end
			end
			else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	                  (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
					  (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
	        begin
		      if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		      begin
		        intO <= `allUKs;
		      end
		      else if (intCE !== 1'b0  && intSCLR !== 1'b1)
		      begin
		        intO <= `allUKs;
		      end
		      else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		      begin
		        intO <= `allUKs;
		      end
			end
		  end
		end
		//else if ((~(loadb_count != -1 && C_HAS_SWAPB == 0)) && 
		//    (~(MULT_TYPE > 2 && real_latency > 0 && C_REG_A_B_INPUTS == 0)))
		else if (MULT_TYPE > 2 && real_latency > 0 && C_REG_A_B_INPUTS == 0)
		begin
		  intO = mult_convert(tmpAB);
		end
		else if (~(MULT_TYPE > 2 && real_latency > 0 && C_REG_A_B_INPUTS == 0))
		begin
		//C_REG_A_B_INPUTS = 0
		  if ((~(real_latency == 0 && C_HAS_Q == 0)) && C_HAS_ND == 0)
		  begin
		    if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
			begin
			  if ((intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
			    && ~(MULT_TYPE == 3 && loadb_count != -1))
			  begin
			    intO <= `all0s;
			  end
			  else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
			  begin
			    intO <= `allUKs;
			  end
			  else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
			  begin
			    intO <= `allUKs;
			  end
			  else if (intCE === 1'b1)
			  begin
			    intO <= mult_convert(tmpAB);
			  end
			  else if (intCE === 1'bx)
			  begin
			    intO <= `allUKs;
			  end
			end
			else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	                  (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
					  (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
	        begin
		      if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		      begin
		        intO <= `allUKs;
		      end
		      else if (intCE !== 1'b0 && intSCLR !== 1'b1)
		      begin
		        intO <= `allUKs;
		      end
		      else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		      begin
		        intO <= `allUKs;
		      end
			end
		  end
		  else if ((~(real_latency == 0 && C_HAS_Q == 0)) 
		        && (C_HAS_ND == 1 && MULT_TYPE < 2 && ~(real_latency == 1 && C_HAS_O == 1)))
		  begin
		    if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
			begin
			  if ((intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
			    && ~(MULT_TYPE == 3 && loadb_count != -1))
			  begin
			    intO <= `all0s;
			  end
			  else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
			  begin
			    intO <= `allUKs;
			  end
			  else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
			  begin
			    intO <= `allUKs;
			  end
			  else if ((intCE === 1'b1 && real_latency == 0 && C_HAS_Q == 1 && intND === 1'b1)
			        || (intCE === 1'b1 && ~(real_latency == 0 && C_HAS_Q == 1)))
			  begin
			    intO <= mult_convert(tmpAB);
			  end
			  else if (intCE === 1'bx)
			  begin
			    intO <= `allUKs;
			  end
			end
			else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	                  (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
					  (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
	        begin
		      if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		      begin
		        intO <= `allUKs;
		      end
		      else if (intCE !== 1'b0 && intSCLR !== 1'b1)
		      begin
		        intO <= `allUKs;
		      end
		      else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		      begin
		        intO <= `allUKs;
		      end
			end
		  end
		  else if (~(real_latency == 0 && C_HAS_Q == 0)) //C_HAS_ND = 1
		  begin
		    if (real_latency == 0)
			begin
			  if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
			  begin
			    if ((intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
				  && ~(MULT_TYPE == 3 && loadb_count != -1))
				begin
				  intO <= `all0s;
				end
				else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
				begin
				  intO <= `allUKs;
				end
				else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
				begin
				  intO <= `allUKs;
				end
				else if ((ND_I === 1'b1 || (MULT_TYPE == 3 && loadb_count != -1)) 
				        && intCE === 1'b1)
				begin
				  intO <= mult_convert(tmpAB);
				end
				else if (ND_I === 1'bx || intCE === 1'bx)
				begin
				  intO <= `allUKs;
				end
			  end
			  else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	                  (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
					  (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
	          begin
		        if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		        begin
		          intO <= `allUKs;
		        end
		        else if (intCE !== 1'b0 && intSCLR !== 1'b1)
		        begin
		          intO <= `allUKs;
		        end
		        else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		        begin
		          intO <= `allUKs;
		        end
			  end
			end
			else //latency > 0
			begin
			  if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
			  begin
			    if ((intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
				  && ~(MULT_TYPE == 3 && loadb_count != -1))
				begin
				  intO <= `all0s;
				end
				else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
				begin
				  intO <= `allUKs;
				end
				else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
				begin
				  intO <= `allUKs;
				end
			    else if (intCE === 1'b1 && ((ND_I === 1'b1 
			              || (MULT_TYPE == 3 && loadb_count != -1)) 
			              || intSWAPB === 1'b1))
				begin
				  intO <= mult_convert(tmpAB);
				end
				else if (intCE === 1'bx || (ND_I === 1'bx && intSWAPB !== 1'b0)
				     || (ND_I !== 1'b0 && intSWAPB === 1'bx))
				begin
				  intO <= `allUKs;
				end
			  end
			  else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	                  (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
					  (intACLR === 1'b0 || (MULT_TYPE > 1 && C_MEM_TYPE == 2 && b_is_one == 0)))
	          begin
		        if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		        begin
		          intO <= `allUKs;
		        end
		        else if (intCE !== 1'b0 && intSCLR !== 1'b1)
		        begin
		          intO <= `allUKs;
		        end
		        else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		        begin
		          intO <= `allUKs;
		        end
			  end
			end
		  end
		end
		// Clear intO when we clear intQpipe[0].
		//if ((last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1) && 
		//   (~(loadb_count != -1 && C_HAS_SWAPB == 0)))
		if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1) 
	    begin
		  if (intACLR == 1'b1)
		  begin
		    if (C_MEM_TYPE == 2 && MULT_TYPE > 2 && (real_latency > 1 || (MULT_TYPE == 3 && C_MEM_TYPE == 2 && real_latency == 1))) 
		    begin
		      if (cleared == 0)
		  	  begin
		  	    intO = `allUKs;
		  	  end
			end
		  end
	      else if ((intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		    && ~(MULT_TYPE == 3 && loadb_count != -1))
		  begin
		    if (loadb_count == -1 && (C_MEM_TYPE == 0 || MULT_TYPE < 2 || C_SYNC_ENABLE == 1 || intCE === 1'b1))
		    begin
			  intO <= `all0s;
		    end
		  end
		  else if (intSCLR === 1'b1 && (intCE === 1'bx || C_SYNC_ENABLE == 0))
		  begin
		    intO <= `allUKs;
	 	  end
		  else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		  begin
			intO <= `allUKs;
	 	  end
		end
		else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	              (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
		          (intACLR === 1'b0 || (C_MEM_TYPE == 2 && MULT_TYPE > 2 && real_latency > 1 && intCE === 1'b1)))
	    begin
		  if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		  begin
			intO <= `allUKs;
		  end
		  else if (intCE !== 1'b0 && intSCLR !== 1'b1)
		  begin
			intO <= `allUKs;
		  end
		  else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		  begin
			intO <= `allUKs;
		  end
		end
	  end
	end

    //Load intO into the pipeline
	always@(intACLR or intO)
	begin
	  if ((intSCLR === 1'b1 && loadb_count == -1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0)) &&
	      (C_MEM_TYPE == 0 || MULT_TYPE < 2 || C_SYNC_ENABLE == 1 || intCE === 1'b1) &&
		  (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && 
		  (intACLR === 1'b0 || (C_MEM_TYPE == 2 && MULT_TYPE > 2 
		  && (real_latency > 1 || (C_MEM_TYPE == 2 && MULT_TYPE == 3 && real_latency == 1)) && intCE === 1'b1))))
	  begin
	    intQpipe[0] = `all0s;
	  end
	  else if ((intACLR === 1'b1 && C_MEM_TYPE == 2 && MULT_TYPE > 2 && (real_latency > 1 || (MULT_TYPE == 3 && C_MEM_TYPE == 2 && real_latency == 1)) 
	    && intCE === 1'b1) &&
	           (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1))
	  begin
		intQpipe[0] = `all0s;
	  end
	  else
	  begin
	    intQpipe[0] = intO;
	  end
	end

    //Load the pipleine.
    always@(posedge intCLK)
	begin
	  if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && intSCLR === 1'b0 && intACLR === 1'b0)
	    intQpipe[0] <= intO;
	end

    //This process clears the pipeline for the non-sequential multiplier.
	always@(intACLR)
	begin
	  if (C_BAAT == C_A_WIDTH)
	  begin
	    if (intACLR === 1'b1) 
		begin
		  if (C_MEM_TYPE == 2 && MULT_TYPE > 2 && (real_latency > 1 || (MULT_TYPE == 3 && C_MEM_TYPE == 2 && real_latency == 1))) 
		  begin
	        if (cleared == 0)
		  	begin
		  	  for (j = 1; j <= real_latency; j = j + 1)
		  	  begin
		  	    intQpipe[j] = `allUKs;
		  	  end
		  	end
		  end
		  else if (real_latency > 0 && (MULT_TYPE < 3 || C_MEM_TYPE == 0))
		  begin
		    for (j = 1; j <= real_latency; j = j + 1)
			begin
			  intQpipe[j] = `all0s;
			end
		  end
		end
		else if (intACLR === 1'bx) 
		begin
		  if (C_MEM_TYPE == 2 && MULT_TYPE > 2 && real_latency > 1) 
		  begin
		    if (cleared == 0)
			begin
			  for (j = 1; j <= real_latency; j = j + 1)
			  begin
			    intQpipe[j] = `allUKs;
		 	  end
			end
		  end
		  else if (real_latency > 0)
		  begin
		    for (j = 1; j <= real_latency; j = j + 1)
			begin
			  intQpipe[j] = `allUKs;
			end
		  end
		end
	  end
	end

    //This process updates the pipeline for the non-sequential multiplier.
	always@(posedge intCLK)
	begin
	  if (C_BAAT == C_A_WIDTH)
	  begin
	    if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 )
	    begin
		  if (intACLR == 1'b1 && C_MEM_TYPE == 2 && MULT_TYPE > 2 
		  && (real_latency > 1 || (MULT_TYPE == 3 && C_MEM_TYPE == 2 && real_latency == 1)) 
		  && intCE === 1'b1)
		  begin
	        if (cleared == 0)
		  	begin
			  intQpipe[real_latency] = `all0s;
		  	end
		  end
		  else if ((intACLR === 1'b0))
		  begin
	        if ((intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
			  && ~(MULT_TYPE == 3 && loadb_count != -1 && (C_MEM_TYPE == 2 || real_latency < 3)))
		    begin
		      if (C_MEM_TYPE == 0 || MULT_TYPE < 2 || C_SYNC_ENABLE == 1 || intCE === 1'b1)
		      begin
			    if (MULT_TYPE > 2 && C_MEM_TYPE == 2 && C_HAS_LOADB == 1 && C_HAS_SWAPB == 0 && real_latency > 1 && loadb_count != -1)
				begin
		          for(j = real_latency-1; j <= real_latency; j = j + 1)
			      begin
			        intQpipe[j] <= `all0s;
			      end
				end
				else if (real_latency >= 1)
				begin
				  for(j = 1; j <= real_latency; j = j + 1)
			      begin
			        intQpipe[j] <= `all0s;
			      end
				end
		      end
		      else if (real_latency > 0) 
		      begin
			    if (MULT_TYPE > 2 && C_MEM_TYPE == 2 && C_HAS_LOADB == 1 && C_HAS_SWAPB == 0 && real_latency > 1 && loadb_count != - 1)
				begin
		          for(j = real_latency-1; j <= real_latency; j = j + 1)
			      begin
			        intQpipe[j] <= `all0s;
			      end
				end
				else
				begin
		          for(j = 1; j <= real_latency; j = j + 1)
			      begin
			        intQpipe[j] <= `all0s;
			      end
				end
		      end
	 	    end
		    else if (intSCLR === 1'b1 && (intCE === 1'bx || C_SYNC_ENABLE == 0))
		    begin
		      for(j = 0; j <= real_latency; j = j + 1)
			  begin
			    intQpipe[j] <= `allUKs;
			  end
	 	    end
		    else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		    begin
		      for(j = 0; j <= real_latency; j = j + 1)
			  begin
			    intQpipe[j] <= `allUKs;
			  end
	 	    end
	        else if (intCE === 1'b1)
		    begin
		      if (C_REG_A_B_INPUTS == 1 || C_HAS_ND == 0 || 
		         (MULT_TYPE > 1 || (MULT_TYPE < 2 && real_latency == 1 && C_HAS_O == 1)) || 
		          C_PIPELINE == 0)
		      begin
			    for(j = real_latency; j >= 1; j = j - 1)
			    begin
			      intQpipe[j] <= intQpipe[j-1];
			    end
		      end
		      else
		      begin
		        if (real_latency > 1)
			    begin
				  for(j = real_latency; j >= 2; j = j - 1)
			      begin
			        intQpipe[j] <= intQpipe[j-1];
			      end
			    end
			    if (real_latency > 0)
			    begin
			      if (regND_nonseq === 1'b1)
			        intQpipe[1] <= intQpipe[0];
				  else if (regND_nonseq === 1'bx)
			        intQpipe[1] <= `allUKs;
			    end
			  end
		    end
		    else if (intCE === 1'bx)
		    begin
		      if (C_REG_A_B_INPUTS == 1 || C_HAS_ND == 0 || 
		         (MULT_TYPE > 1 || (MULT_TYPE < 2 && real_latency == 1 && C_HAS_O == 1)) || 
		          C_PIPELINE == 0)
		      begin
			    for(j = real_latency; j >= 1; j = j - 1)
			    begin
			      intQpipe[j] <= `allUKs;
			    end
		      end
		      else
		      begin
		        if (real_latency > 0)
			    begin
				  for(j = real_latency; j >= 0; j = j - 1)
			      begin
			        intQpipe[j] <= `allUKs;
			      end
			    end
			  end
		    end
		  end
		end
		else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	              (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
		          (intACLR === 1'b0 || (C_MEM_TYPE == 2 && MULT_TYPE > 2 && real_latency > 1 
					&& intCE === 1'b1)))
	    begin
		  if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		  begin
		    for(j = real_latency; j >= 0; j = j - 1)
			begin
			  intQpipe[j] <= `allUKs;
			end
		  end
		  else if (intCE !== 1'b0 && intSCLR !== 1'b1)
		  begin
		    for(j = real_latency; j >= 0; j = j - 1)
			begin
			  intQpipe[j] <= `allUKs;
			end
		  end
		  else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		  begin
		    for(j = real_latency; j >= 0; j = j - 1)
			begin
			  intQpipe[j] <= `allUKs;
			end
		  end
		end
	  end
	end

    //Model the ready output pipeline. First do the asynchronous updates.
	always@(intACLR or intRDY)
	begin
	  if (C_BAAT == C_A_WIDTH)
	  begin
	    if (intACLR === 1'b0 || intACLR === 1'bx || real_latency == 0)
		begin
		  intRDYpipe[0] = intRDY;
		end
		else if (intACLR === 1'b1)
		begin
		  for(j = 0; j <= real_latency; j = j + 1)
		  begin
		    intRDYpipe[j] = 0;
		  end
		end
		else if (intACLR === 1'bx)
		begin
		  for(j = 0; j <= real_latency; j = j + 1)
		  begin
		    if (intRDYpipe[j] !== 1'b0)
			begin
		      intRDYpipe[j] = 1'bx;
			end
		  end
		end
	  end
	end

    //Model the synchronous part of the ready pipeline.
	always@(posedge intCLK)
	begin
	  if (C_BAAT == C_A_WIDTH)
	  begin
	    if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && intACLR !== 1'b1)
		begin
		  if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		  begin
			for(j = real_latency; j >= 0; j = j - 1)
			begin
			  intRDYpipe[j] <= 0;
			end
		  end
		  else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		  begin
			for(j = real_latency; j >= 1; j = j - 1)
			begin
			  if (intRDYpipe[j-1] !== 1'b0)
			  begin
			    intRDYpipe[j] <= 1'bx;
			  end
			  else
			  begin
			    intRDYpipe[j] <= 1'b0;
			  end
			end
		  end
		  else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
		  begin
			for(j = real_latency; j >= 0; j = j - 1)
			begin
			  if (intRDYpipe[j] !== 1'b0)
			    intRDYpipe[j] <= 1'bx;
			  else
			    intRDYpipe[j] <= 1'b0;
			end
		  end
		  else if (intCE === 1'b1 && intACLR === 1'b0)
		  begin
			for(j = real_latency; j >= 1; j = j - 1)
			begin
			  intRDYpipe[j] <= intRDYpipe[j-1];
			end
		  end
		  else if (intCE === 1'b1 && intACLR === 1'bx)
		  begin
			for(j = real_latency; j >= 1; j = j - 1)
			begin
			  if (intRDYpipe[j-1] === 1'b0)
			    intRDYpipe[j] <= intRDYpipe[j-1];
			  else
			    intRDYpipe[j] <= 1'bx;
			end
		  end
		  else if (intCE === 1'bx)
		  begin
			for(j = real_latency; j >= 1; j = j - 1)
			begin
			  if (intRDYpipe[j] !== intRDYpipe[j-1])
			  begin
			    intRDYpipe[j] <= 1'bx;
			  end
			end
		  end
		end
        else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	              (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
		          (intACLR !== 1'b1)) 
	    begin
		  if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
		  begin
		    for(j = real_latency; j >= 1; j = j - 1)
			begin
			  intRDYpipe[j] <= 1'bx;
			end
		  end
		  else if (intCE !== 1'b0 && intSCLR !== 1'b1)
		  begin
		    for(j = real_latency; j >= 1; j = j - 1)
			begin
			  if (intRDYpipe[j] !== intRDYpipe[j-1])
			    intRDYpipe[j] <= 1'bx;
			end
		  end
		  else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		  begin
		    for(j = real_latency; j >= 1; j = j - 1)
			begin
			  if (intRDYpipe[j] !== 1'b0)
			    intQpipe[j] <= 1'bx;
			end
		  end
		end
	  end
	end

    //Now drive the internal versions of the O, Q and RDY outputs.
	//Again do the asynchronous updates first.
	always@(intO or tmpAB or intQpipe[real_latency] or intQpipe[0] or intQpipe[real_latency-1] or intRDYpipe or intACLR or intSCLR or intCE or intCLK or ND_I)
	begin
	  if (C_BAAT == C_A_WIDTH)
	  begin
	    if (real_latency == 0)
		begin
		  // Assign O Output.
		  O_I = mult_convert(tmpAB);
          // Assign Q Output.
		  if (b_is_zero == 1)
		  begin
		    Q_I = `all0s;
		  end
		  else if (C_MEM_TYPE == 0 || MULT_TYPE < 2)
		  begin
		    if (intACLR === 1'b1)
		      Q_I = `all0s;
		    else if (intACLR === 1'bx)
		      Q_I = `allUKs;
		    else
		      Q_I   = intQpipe[0];
		  end
		  else
		  begin
		    Q_I = intQpipe[0];
		  end

          // Assign RDY Output.
		  if (C_HAS_ND == 1)
		  begin
		    if (b_is_zero == 1)
			  RDY_I = ND_I;
			else
		      RDY_I = intRDYpipe[0];
		  end
		  else
		  begin
		    RDY_I = 1;
		  end

		end
		else
		begin
		  if (C_MEM_TYPE == 2 && MULT_TYPE > 2 && real_latency > 2 && (C_PIPELINE == 0 || real_latency > 3))
		  begin
		    if (intACLR === 1'b1)
		    begin
			  O_I   = `all0s;
			  Q_I   = `all0s;
		    end
		    else if (intACLR === 1'bx)
		    begin
			  O_I   = `allUKs;
			  Q_I   = `allUKs;
		    end
		    else
		    begin
			  O_I   = intQpipe[real_latency-1];
			  Q_I   = intQpipe[real_latency];
		    end
		  end
		  else if (C_MEM_TYPE == 2 && MULT_TYPE > 2 && (real_latency == 2 || (C_PIPELINE == 1 && real_latency > 1)))
		  begin
		    O_I = intQpipe[real_latency-1];
			if (intACLR === 1'b1)
			begin
			  Q_I = `all0s;
			end
			else if (intACLR === 1'bx)
			begin
			  Q_I = `allUKs;
			end
			else
			begin
			  Q_I = intQpipe[real_latency];
			end
		  end
		  else
		  begin
		    O_I = intQpipe[real_latency-1];
			Q_I = intQpipe[real_latency];
		  end
		  if (C_HAS_ND == 1)
			if (C_REG_A_B_INPUTS == 1 || MULT_TYPE > 1 || C_PIPELINE == 0 || C_LATENCY < 1 ||
			    (C_PIPELINE == 1 && C_HAS_ND == 1 && MULT_TYPE < 2 && real_latency == 1 && 
			      C_REG_A_B_INPUTS == 0 && C_HAS_Q == 0))
           
		      RDY_I = intRDYpipe[real_latency];
			else
			  RDY_I = intRDYpipe[real_latency-1];
		  else
		    RDY_I = 1;
		end
	  end
	end

    //Register the RFD and RDY signals.
	//Asynchronous clear.
	always@(intACLR)
	begin
	  if (intACLR === 1'b1)
	  begin
	    if (b_is_zero == 0)
		begin
	      regRFD = 0;
		  regRDY = 0;
		end
		else
		begin 
		  regRFD = 0;
		end
	  end
	  else if (intACLR === 1'bx && regRDY !== 1'b0 && b_is_zero == 0)
	  begin
	    regRDY = 1'bx;
	  end
	  else if (intACLR === 1'bx && regRFD !== 1'b0)
	  begin
		regRFD = 1'bx;
	  end
	end

    always@(ND_I)
	begin
	  if (b_is_zero == 1)
	  begin
	    regRDY = ND_I;
	  end
	end

    //Synchronous clear and registered output.
	always@(posedge intCLK)
	begin
      if (b_is_zero == 0 && last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && intACLR !== 1'b1)
	  begin
	    if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  regRFD <= 0;
		  regRDY <= 0;
		end
		else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  if (intRFD !== 1'b0)
		    regRFD <= 1'bx;
		  else 
		    regRFD <= 1'b0;
		  if (RDY_I !== 1'b0)
		    regRDY <= 1'bx;
		  else 
		    regRDY <= 1'b0;
		end
		else if (intSCLR === 1'b1 && (intCE === 1'bx && C_SYNC_ENABLE == 1))
		begin
		  if (regRFD !== 1'b0)
		    regRFD <= 1'bx;
		  else
		    regRFD <= 1'b0;
		  if (regRDY !== 1'b0)
		    regRDY <= 1'bx;
		  else
		    regRDY <= 1'b0;
		end
		else if (intCE === 1'b1 && intACLR === 1'b0)
		begin
		  regRFD <= intRFD;
		  regRDY <= RDY_I;
		end
		else if (intCE === 1'b1 && intACLR === 1'bx)
		begin
		  if (intRFD === 1'b0)
		    regRFD <= intRFD;
		  else
		    regRFD <= 1'bx;
		  if (RDY_I === 1'b0)
		    regRDY <= RDY_I;
		  else
		    regRDY <= 1'bx;
		end
		else if (intCE === 1'bx)
		begin
		  if (regRFD !== intRFD)
		    regRFD <= 1'bx;
		  if (regRDY !== RDY_I)
		    regRDY <= 1'bx;
		end
	  end
	  else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	              (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
		          (intACLR !== 1'b1)) 
	  begin
	    if ((intCE !== 1'b0 || C_SYNC_ENABLE == 0) && intSCLR !== 1'b0)
	    begin
		  regRDY <= 1'bx;
		  regRFD <= 1'bx;
	    end
		else if (intCE !== 1'b0 && intSCLR !== 1'b1)
		begin
		  if (regRFD !== intRFD)
			regRFD <= 1'bx;
		  if (regRDY !== RDY_I)
		    regRDY <= 1'bx;
		end
		else if (intCE !== 1'b0 || C_SYNC_ENABLE == 0)
		begin
		  if (regRFD !== 1'b0)
		    regRFD <= 1'bx;
		  if (regRDY !== 1'b0)
		    regRDY <= 1'bx;
		end
	  end
	end

    //Model the reloading process for a reloadable constant coefficient multiplier.
	//This is a synchronous process but we must deal with the asynchronous clear first.
	always@(intACLR)
	begin
      if (C_HAS_LOADB == 1)
	  begin
	    if (intACLR === 1'b1)
		begin
		  if (loadb_count != -1 && loadb_count != -2) // -1 = Load finished
		  begin
		    loadb_count = -2;    // -2 = Load interrupted by clear.
			loadb_count_no_predelay = -2;
		  end
		  intLOAD_DONE = 1;
		  intRFD_rel   = 1;
		end
		else if (intACLR === 1'bx)
		begin
		  if (loadb_count != -1 && loadb_count != -2)
		  begin
		    loadb_count = -3;   // -3 = Undefined.
			intLOAD_DONE = 1'bx;
			if (C_HAS_SWAPB == 0)
		      intRFD_rel   = 1'bx;
			else
			  intRFD_rel   = 1'b1;
		  end
		end
	  end
	end

    //Now do the synchronous update on the rising clock edge.
	always@(posedge intCLK)
	begin
	  if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && C_HAS_LOADB == 1 && intACLR !== 1'b1 && intLOADB === 1'bx && intCE !== 1'b0)
	  begin
	    loadb_count  = -3;
	    if (C_HAS_SWAPB == 1 && bank_sel === 1'bx )
		begin
	      b_const0 <= `ballxs;
	      b_const1 <= `ballxs;
		end
		else if (C_HAS_SWAPB == 1 && bank_sel === 1'b0)
		begin
		  b_const1 <= `ballxs;
		end
		else
		begin
		  b_const0 <= `ballxs;
		end
	  end
	  else if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && C_HAS_LOADB == 1 && intACLR === 1'b0)
	  begin
	    if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  if (loadb_count != -1 && loadb_count != -2)
		  begin
		    loadb_count <= -2;
		  end
		end
		else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  if (loadb_count != -1 && loadb_count != -2)
		  begin
		    loadb_count <= -2-sig_addr_bits;
		  end
		end
		else if (intCE === 1'b1)
		begin
		  if (intLOADB === 1'b1)
		  begin
		    if (C_REG_A_B_INPUTS == 1 || C_HAS_A_SIGNED == 1 || C_A_TYPE == `c_signed)
			begin
		      loadb_count  <= loadb_delay+1+C_REG_A_B_INPUTS;
			end
			else
			begin
			  loadb_count  <= loadb_delay;
			end
			loadb_value  <= B_I;
			loaded       <= 1;
		  end
		  else //loadb == 0.
		  begin
		    if (C_HAS_O == 1 && MULT_TYPE == 3 && C_HAS_SWAPB == 0 && 
		        loadb_count == 2 && loadb_delay > 2 && C_HAS_ND == 1)
			//Load early in this case.
			begin
			  b_const0 <= loadb_value;
			  loadb_count <= loadb_count - 1;
			end
		    else if (loadb_count > 0)
			begin
			  loadb_count <= loadb_count - 1;
			end
			else if (loadb_count <= -3) //Undefined state
			begin
			  if (loadb_count != -2-sig_addr_bits && C_REG_A_B_INPUTS == 0 && real_latency == 0)
			  // Wait for sig_addr_bits cycles before setting the op
			  // to undefined.
			  begin
			    loadb_count <= loadb_count - 1;
			  end
			end
			else if (loadb_count == 0)
			begin
			  if (C_HAS_SWAPB == 1 && bank_sel === 1'b0)
			    b_const1 <= loadb_value;
			  else
			    b_const0 <= loadb_value;
			  //if (ND_I === 1'b1 || (C_HAS_SWAPB == 1 || C_HAS_ND == 0 || C_REG_A_B_INPUTS == 1))
			  //begin
			    loadb_count <= -1;
			  //end
              loaded       <= 1;
			end
			else if (loadb_count == -2) //Load has been interrupted by a clear.
			begin
			  if (C_HAS_SWAPB == 1 && bank_sel == 0)
			    b_const1 <= `ballxs;
			  else
			    b_const0 <= `ballxs;
			  loaded       <= 1;
			end
		  end
		end
		else if (intCE === 1'bx)
		begin
		  if (loadb_count != -1 && loadb_count != -2 && (loadb_count != -2-sig_addr_bits && C_REG_A_B_INPUTS == 0 && real_latency == 0))
		  begin
		    if (loadb_count > 0)
              loadb_count  <= -3;
			else
			  loadb_count  <= loadb_count-1;
		  end
		  else if (loadb_count == -2-sig_addr_bits || (loadb_count != -1 && loadb_count != -2 && (C_REG_A_B_INPUTS == 1 || real_latency > 0)))
		  // Propogate the 'X' through when the TC from the load engines
		  // counter goes to 'X' or if the inputs are registered.
		  begin
		    if (C_REG_A_B_INPUTS == 1 || real_latency > 0)
		      loadb_count <= -3;
		  end
		end
	  end
	end

    // The load done and RFD outputs don't depend on the C_PREDELAY parameter.
    always@(posedge intCLK)
	begin
	  if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && C_HAS_LOADB == 1 && intACLR !== 1'b1 && intLOADB_no_predelay === 1'bx && intCE !== 1'b0)
	  begin
	    loadb_count_no_predelay = -3;
	    intLOAD_DONE <= 1'bx;
		if (C_HAS_SWAPB == 0)
	      intRFD_rel   <= 1'bx;
		else
		  intRFD_rel   <= 1'b1;
	  end
	  else if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && C_HAS_LOADB == 1 && intACLR === 1'b0)
	  begin
	    if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  intLOAD_DONE <= 1;
		  intRFD_rel   <= 1;
		  if (loadb_count != -1 && loadb_count != -2)
		  begin
		    loadb_count_no_predelay <= -2;
		  end
		end
		else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  if (loadb_count != -1 && loadb_count != -2)
		  begin
		    intLOAD_DONE <= 1'bx;
			if (C_HAS_SWAPB == 0)
		      intRFD_rel   <= 1'bx;
			else
			  intRFD_rel   <= 1'b1;
		    loadb_count_no_predelay <= -2-sig_addr_bits;
		  end
		end
		else if (intCE === 1'b1)
		begin
		  if (intLOADB_no_predelay === 1'b1)
		  begin
		    loadb_count_no_predelay  <= loadb_delay;
		    intLOAD_DONE <= 0;
			if (C_HAS_SWAPB == 0) 
			  intRFD_rel <= 0;
			else
			  intRFD_rel <= 1;

            //If the load comes when the load_done is undefined in the following 
			//cases then the load_done signal goes to 'X' during the load.
			if (C_HAS_SWAPB == 1 && loadb_count == -3 && (real_latency > 0 || C_REG_A_B_INPUTS == 1))
			  stay_x <= 1;
			else
			  stay_x <= 0;

		  end
		  else //loadb == 0.
		  begin
		    if (loadb_count_no_predelay > 0)
			begin
			  if (loadb_count_no_predelay > 0)
			  begin
			    loadb_count_no_predelay <= loadb_count_no_predelay - 1;
			  end
			  if (stay_x == 1)
			    intLOAD_DONE <= 1'bx;
			  else
			    intLOAD_DONE <= 1'b0;
			end
			else if (loadb_count_no_predelay <= -3)
			begin
			  if (~(loadb_count != -2-sig_addr_bits && C_REG_A_B_INPUTS == 0 && real_latency == 0))
			  // Wait for sig_addr_bits cycles before setting the op
			  // to undefined.
			  begin
			    if (C_HAS_SWAPB == 0)
			      intRFD_rel <= 1'bx;
			    else
			      intRFD_rel <= 1'b1;
			    intLOAD_DONE <= 1'bx;
			  end
			end
			else if (loadb_count_no_predelay == 0)
			begin
			  intLOAD_DONE <= 1;
			  intRFD_rel   <= 1;
			  stay_x       <= 0;
			  if (ND_I === 1'b1 || (C_HAS_SWAPB == 1 || C_HAS_ND == 0 || C_REG_A_B_INPUTS == 1))
			  begin
			    loadb_count_no_predelay <= -1;
			  end
			end
			else if (loadb_count_no_predelay == -2)
			begin
			  intLOAD_DONE <= 1;
			  intRFD_rel   <= 1;
			end
		  end
		end
		else if (intCE === 1'bx)
		begin
		  if (loadb_count != -1 && loadb_count != -2 && (loadb_count != -2-sig_addr_bits && C_REG_A_B_INPUTS == 0 && real_latency == 0))
		  begin
		  end
		  else if (loadb_count == -2-sig_addr_bits || (loadb_count != -1 && loadb_count != -2 && (C_REG_A_B_INPUTS == 1 || real_latency > 0)))
		  // Propogate the 'X' through when the TC from the load engines
		  // counter goes to 'X' or if the inputs are registered.
		  begin
		    intLOAD_DONE <= 1'bx;
			if (C_HAS_SWAPB == 0)
			  intRFD_rel <= 1'bx;
			else
			  intRFD_rel <= 1'b1;
		  end
		end
	  end
	end

    //Loadb_count_dly will mask out the first reult after a load. This is 
	//necessary in some cases.
	always@(intACLR)
	begin
	  if (intACLR === 1'b1)
	    loadb_count_dly = -1;
		loadb_count_dly_int = -1;
	end

    always@(posedge intCLK)
	begin
	  if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && intCE === 1'b1 && intACLR === 1'b0)
	  begin
	    loadb_count_dly_int <= loadb_count;
		//if (ND_I === 1'b1 || (C_HAS_SWAPB == 1 || C_HAS_ND == 0 || C_REG_A_B_INPUTS == 1))
		//begin
	      loadb_count_dly <= loadb_count_dly_int;
		//end
	  end
	end

    //Do the B input calculation. This can be an input, a constant or a reloadable constant.
	always@(B or b_const0 or b_const1 or intLOAD_DONE or ND_I or bank_sel or posedge intCLK)
	begin
	  if (MULT_TYPE < 2)
	  begin
	    B_INPUT = B;
	  end
	  else if (~((MULT_TYPE < 3) || (loaded == 0 && intLOADB === 1'b0)))
	  begin
	    //if (intLOAD_DONE === 1'b1 || C_HAS_SWAPB == 1)
		if (loadb_count == -1 || C_HAS_SWAPB == 1)
		begin
		  if (bank_sel == 0 && MULT_TYPE > 2 && loaded == 1)
		  begin
		    if ((C_HAS_ND == 0) || (C_HAS_SWAPB == 1 && loadb_count < 0))
			begin
			  B_INPUT = b_const0;
			end
			else if (C_HAS_ND == 1 && C_HAS_SWAPB == 0 && ND_I == 1)
			begin
			  B_INPUT = b_const0;
			end
		  end
		  else if (bank_sel == 1 && MULT_TYPE > 2 && loaded == 1 && loadb_count < 0)
		  begin
		    B_INPUT = b_const1;
		  end
		  else if (bank_sel == 2 && MULT_TYPE > 2 && loaded == 1 && loadb_count < 0)
		  begin
		    B_INPUT = `ballxs;
		  end
		end
		else
		begin
		  B_INPUT = `ballxs;
		end
	  end
	end

    //Swap between the two banks of memory if the core has a SWAPB pin.
	always@(intACLR)
	begin
	  if (C_HAS_SWAPB == 1)
	  begin
	    if (intACLR === 1'b1)
		begin
		  bank_sel = 0;
		  bank_sel_pre = 0;
		end
		else if (intACLR === 1'bx)
		begin
		  if (bank_sel != 0)
		    bank_sel = 2;
			bank_sel_pre = 2;
		end
	  end
	end

    always@(posedge intCLK)
	begin
	  if (last_clk !== intCLK && last_clk === 1'b0 && intCLK === 1'b1 && intACLR === 1'b0)
	  begin
	    if (intSCLR === 1'b1 && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  bank_sel <= 0;
		  bank_sel_pre <= 0;
		end
		else if (intSCLR === 1'bx && (intCE === 1'b1 || C_SYNC_ENABLE == 0))
		begin
		  if (bank_sel != 0)
		    bank_sel <= 2;
			bank_sel_pre <= 2;
		end
		else if (intSCLR === 1'b1 && (intCE === 1'bx || C_SYNC_ENABLE == 0))
		begin
		  if (bank_sel != 0)
		    bank_sel <= 2;
			bank_sel_pre <= 2;
		end
		else if (intCE === 1'b1)
		begin
		  if (C_REG_A_B_INPUTS == 0 && real_latency > 0 && C_HAS_SWAPB == 1) 
		  begin
		     bank_sel <= bank_sel_pre;
		  end

		  if ((C_REG_A_B_INPUTS == 1 || real_latency == 0) && C_HAS_SWAPB == 1 && intSWAPB === 1'b1 && loadb_count < 0)
		  begin
		    if (bank_sel == 0)
			  bank_sel <= 1 ;
			else
			  bank_sel <= 0 ;
		  end
		  else if ((C_REG_A_B_INPUTS == 1 || real_latency == 0) && C_HAS_SWAPB == 1 && intSWAPB === 1'bx && loadb_count < 0)
		  begin
			bank_sel <= 2 ;
		  end
		  else if (C_REG_A_B_INPUTS == 0 && real_latency > 0 && C_HAS_SWAPB == 1 && intSWAPB === 1'b1 && loadb_count < 0)
		  begin
		    if (bank_sel_pre == 0)
			  bank_sel_pre <= 1 ;
			else
			  bank_sel_pre <= 0 ;
		  end
		  else if (C_REG_A_B_INPUTS == 0 && real_latency > 0 && C_HAS_SWAPB == 1 && intSWAPB === 1'bx && loadb_count < 0)
		  begin
			bank_sel_pre <= 2 ;
		  end
		end
		else if (intCE === 1'bx)
		begin
		  if ((C_REG_A_B_INPUTS == 1 || real_latency == 0) && C_HAS_SWAPB == 1 && intSWAPB !== 1'b0)
		  begin
			bank_sel <= 2 ;
		  end
		  else if (C_REG_A_B_INPUTS == 0 && real_latency > 0 && C_HAS_SWAPB == 1 && intSWAPB !== 1'b0)
		  begin
			bank_sel_pre <= 2 ;
		  end
		end
	  end
	  else if (((last_clk !== intCLK && intCLK === 1'bx && last_clk === 1'b0) ||
	            (last_clk !== intCLK && intCLK === 1'b1 && last_clk === 1'bx)) &&
		        (intACLR !== 1'b1)) 
	  begin
	    if ((C_REG_A_B_INPUTS == 1 || real_latency == 0) && C_HAS_SWAPB == 1 && intSWAPB !== 1'b0)
		begin
		  bank_sel <= 2 ;
		end
		else if (C_REG_A_B_INPUTS == 0 && real_latency > 0 && C_HAS_SWAPB == 1 && intSWAPB !== 1'b0)
		begin
		  bank_sel_pre <= 2 ;
		end
	  end
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

	function findB_width;
	input [C_B_WIDTH-1 : 0] b_input;
	integer i;
	begin
		for(i = C_B_WIDTH-1; i > 0; i = i - 1)
		begin
			if(b_input[i] == 1)
				findB_width = i ;
			else
				findB_width = findB_width ;
		end 
	end
	endfunction

	function modulus;
	input a ;
	input b ;
	integer divide ;
	begin
		divide = (a < b ? 0 : (a / b)) ;
		modulus = a - (b*divide) ;
	end
	endfunction
	
	function max;
	input a;
	input b;
	begin
		max = (a > b) ? a : b;
	end
	endfunction
	
	function is_X;
	input [multWidth-1 : 0] i;
	begin
		is_X = 1'b0;
		for(j = 0; j < multWidth; j = j + 1)
		begin
			if(i[j] === 1'bx) 
				is_X = 1'b1;
		end // loop
	end
	endfunction

    function [C_OUT_WIDTH-1 : 0] mult_convert;
	input [multWidth-1 : 0] in_sum;
	integer bit_index;
	begin
	  for(bit_index = C_OUT_WIDTH-1; bit_index >= 0; bit_index = bit_index - 1)
	  begin
		if (out_width > C_OUT_WIDTH)
		begin
	      mult_convert[bit_index] = in_sum[(out_width-C_OUT_WIDTH)+bit_index] ;
		end
	    else
		begin
		  if (bit_index <= out_width)
		  begin
			mult_convert[bit_index] = in_sum[bit_index];
	      end
		  else if (C_A_TYPE == `c_signed || (C_A_TYPE == `c_pin && tmpA_SIGNED == 1) 
			    || C_B_TYPE == `c_signed)
		  begin
		    if (MULT_TYPE > 2 && C_HAS_LOADB == 1 && C_A_WIDTH == 1 && C_A_TYPE == `c_pin 
	            && C_HAS_A_SIGNED == 1 && C_B_TYPE == `c_signed)
			  mult_convert[bit_index] = in_sum[out_width];
			else
			  mult_convert[bit_index] = in_sum[out_width-1];
		  end
	      else
		  begin
		    if (is_X(in_sum))
			  mult_convert[bit_index] = 1'bx;
			else
			  mult_convert[bit_index] = 0;
		  end
	    end
	  end
	end
	endfunction

    function [multWidth-1 : 0] add;
	input [multWidth-1 : 0] i1;
	input [multWidth-1 : 0] i2;
	integer bit_index;
	integer carryin, carryout;
	begin
		carryin = 0;
		carryout = 0;
		for(bit_index=0; bit_index < multWidth; bit_index = bit_index + 1)
		begin
			if (i1[bit_index] === 1'bx || i2[bit_index] === 1'bx)
			begin
				add[bit_index] = 1'bx ;
				carryout = 1'bx ;
				carryin = carryout ;
			end
			else if (carryin === 1'bx)
			begin
				add[bit_index] = 1'bx ;
				carryout = 0 ;
				carryin = carryout ;
			end
			else
			begin
				add[bit_index] = i1[bit_index] ^ i2[bit_index] ^ carryin;
				carryout = (i1[bit_index] && i2[bit_index]) || (carryin && (i1[bit_index] || i2[bit_index]));
				carryin = carryout;
			end
		end
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
`undef all0s
`undef ball0s
`undef ballxs
`undef aall0s
`undef aallxs
`undef baatall0s
`undef baatall1s
`undef baatallxs
`undef c_distributed
`undef c_dp_block
`undef mall0s
`undef mallUKs
`undef inall0s
































