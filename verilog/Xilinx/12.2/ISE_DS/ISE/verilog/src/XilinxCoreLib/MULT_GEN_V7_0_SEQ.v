// Copyright(C) 2004 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.


/* $Id: MULT_GEN_V7_0_SEQ.v,v 1.13 2008/09/08 20:09:14 akennedy Exp $
--
-- Filename - MULT_GEN_V7_0.v
-- Author - Xilinx
-- Creation - 22 Mar 1999
--
-- Description - This file contains the Verilog behavior for the sequential part of the multiplier module
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

`define awidthall0s {C_A_WIDTH{1'b0}}
`define accumall0s {accum_width{1'b0}}
`define storeall0s {(C_BAAT*(number_clocks-1)){1'b0}}
`define aloadall0s {(C_BAAT*(number_clocks)){1'b0}}
`define accumpipeall0s {(C_LATENCY+1){1'b0}}
`define rfdpipeall0s {(number_clocks-C_REG_A_B_INPUTS){1'b0}}
`define multsignedpipeall0s {(C_REG_A_B_INPUTS+1-ccm_serial+temp_mult+mult_signed_pipe_rubbish+mult_signed_pipe_rubbish2){1'b0}}
`define accumsignpipeall0s {(C_LATENCY+accum_sign_pipe_rubbish2){1'b0}}
`define intrdypipeall0s {(rdy_delay+1){1'b0}}
`define accumcompall0s {(accum_width+accum_store_width){1'b0}}
`define outputall0s {C_OUT_WIDTH{1'b0}}
`define accumstoreall0s {accum_store_width{1'b0}}

module MULT_GEN_V7_0_SEQ (A, B, CLK, A_SIGNED, CE, ACLR,
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
	parameter C_REG_A_B_INPUTS  = 1;
	parameter C_SQM_TYPE		= 0;
	parameter C_STACK_ADDERS	= 0;
        parameter C_STANDALONE          = 0;
	parameter C_SYNC_ENABLE		= 0;
	parameter C_USE_LUTS		= 1;

	//Internal parameters

	//has ce selection for final output register
	parameter has_q_ce = ((C_HAS_CE == 1 || C_OUTPUT_HOLD == 1) ? 1 : 0);
	//has_a_signed selectionf for internal multiplier
	parameter mult_has_a_signed = (C_A_TYPE == `c_signed ? 1 : (C_HAS_A_SIGNED == 1 ? 1 : 0));
	//a_type for internal multiplier
	parameter mult_a_type = (C_A_TYPE == `c_signed ? `c_pin : (C_A_TYPE == `c_pin ? `c_pin : `c_unsigned));
	//output width for internal multiplier
	parameter mult_width = (C_B_TYPE == `c_signed ? C_BAAT + C_B_WIDTH : (C_B_WIDTH == 1 ? C_BAAT + mult_has_a_signed : C_BAAT + C_B_WIDTH + mult_has_a_signed));
	
	
	//***********************THIS SECTION CALCULATES INTERNAL MULTIPLIER LATENCY****************************************
	
	parameter incA = (((mult_has_a_signed == 1 || mult_a_type == `c_signed) && C_B_TYPE == `c_unsigned) ?  1 : 0) ;
	parameter incB = (C_B_TYPE == `c_signed ? 1 : 0) ;
	parameter inc = ((C_B_TYPE == `c_unsigned && mult_a_type == `c_unsigned) ? 0 : 1) ;
	parameter dec = ((C_B_TYPE == `c_unsigned && mult_a_type == `c_unsigned) ? 1 : 0) ;
	parameter inc_a_width = 0;
	parameter decrement = (mult_has_a_signed == 1 ? 1 : 0) ;

	//Parameters to calculate the latency for the parallel multiplier.
	parameter a_ext_width_par = (mult_has_a_signed == 1 ? C_BAAT+1 : C_BAAT) ;
	parameter a_ext_width_seq = ((mult_has_a_signed == 1 || mult_a_type == `c_signed) ? C_BAAT+1 : C_BAAT) ;
	parameter a_ext_width = a_ext_width_par;

        /* Compare the width of the A port, to the width of the B port
	 If the A port is smaller, then swap these over, otherwise leave
	 alone */

        parameter a_w = (C_BAAT < C_B_WIDTH ? C_B_WIDTH : a_ext_width);
        parameter a_t = (C_BAAT < C_B_WIDTH ? C_B_TYPE : mult_a_type);
        parameter b_w = (C_A_WIDTH < C_B_WIDTH ? a_ext_width : C_B_WIDTH);
        parameter b_t = (C_A_WIDTH < C_B_WIDTH ? mult_a_type : C_B_TYPE);

        // The mult18 parameter signifies if the final mult18x18 primitive is used
        // without having to pad with zeros, or sign extending - thus leading to
        // a more efficient implementation - e.g. a 35x35 (signed x signed) multiplier
        // mult18, is used in the calculation of a_prods and b_prods, which indicate
        // how many mult18x18 primitives are requred.
   
        parameter mult18 = (((a_t == `c_signed && a_w % 17 == 1) 
           && ((b_t == `c_signed && b_w <= a_w) || (b_t == `c_unsigned && b_w < a_w))) ? 1 : 0);   
   
	parameter a_prods = (a_ext_width-1)/(17 + mult18) + 1 ;
	parameter b_prods = (C_B_WIDTH-1)/(17 + mult18) + 1 ;
	parameter a_count = (a_ext_width+1)/2 ;
	parameter b_count = (C_B_WIDTH+1)/2 ;
	parameter parm_numAdders = (C_MULT_TYPE == 1 ? (a_prods*b_prods) : ((a_ext_width <= C_B_WIDTH) ? a_count : b_count)) ;

	//Parameters to calculate the latency for the constant coefficient multiplier.
	parameter rom_addr_width = (C_MEM_TYPE == `c_distributed ? 4 : BRAM_ADDR_WIDTH) ;
	parameter sig_addr_bits = (C_BAAT >= rom_addr_width ? rom_addr_width : C_BAAT) ;
	parameter effective_op_width = ((mult_has_a_signed == 0 || C_HAS_LOADB == 1) ? C_BAAT : C_BAAT+1) ;
	parameter a_input_width = ((effective_op_width % rom_addr_width == 0) ? effective_op_width : effective_op_width + rom_addr_width - (effective_op_width % rom_addr_width)) ;
	parameter mod = a_input_width % rom_addr_width ;
	parameter op_width = (mod == 0 ? a_input_width : (a_input_width + rom_addr_width) - mod) ;
	parameter a_width = op_width;
	parameter need_addsub = ((C_HAS_LOADB == 1 && (mult_a_type == `c_signed || mult_has_a_signed == 1)) ? 1 : 0) ;
	parameter ccm_numAdders_1 = (mod == 0 ? (a_input_width/rom_addr_width) : (a_input_width/rom_addr_width)+1) ;
	parameter need_0_minus_pp = ((need_addsub == 1 && ccm_numAdders_1 <= 1) ? 1 : 0) ;
	parameter ccm_numAdders = (need_0_minus_pp == 1 ? 1 : ccm_numAdders_1 - 1) ;
	parameter ccm_init1 = ((C_HAS_LOADB == 1 && C_MEM_TYPE == `c_dp_block) ? 1 : 0) ;
	parameter ccm_init2 = ((C_HAS_LOADB == 1 && (mult_a_type == `c_signed || mult_has_a_signed == 1) && C_PIPELINE == 1) ? 1 : 0) ;
	parameter ccm_init3 = (((ccm_numAdders > 0 || C_HAS_SWAPB == 1) && (C_PIPELINE == 1 || C_MEM_TYPE == `c_dp_block)) ? 1 : 0) ;
	parameter ccm_init4 = ((ccm_numAdders > 0 && C_HAS_SWAPB == 1 && C_PIPELINE == 1) ? 1 : 0) ;
	parameter ccm_initial_latency = ccm_init1 + ccm_init2 + ccm_init3 + ccm_init4 ;
	parameter add_one = 0 ; 
	parameter extra_cycles = 0 ; 

	//Latency calculation
	parameter numAdders = (C_MULT_TYPE < 2 ? parm_numAdders - 1 : ccm_numAdders) ;
	parameter log = (C_PIPELINE == 1 ? (numAdders < 2 ? 0 : (numAdders < 4 ? 1 : (numAdders < 8 ? 2 : (numAdders < 16 ? 3 : (numAdders < 32 ? 4 : (numAdders < 64 ? 5 : (numAdders < 128 ? 6 : 7))))))) : 0) ; 
	parameter C_LATENCY_sub = (C_MULT_TYPE < 2 ? (numAdders > 0 ? (extra_cycles + log + 1) : 0) : (numAdders > 0 ? (ccm_initial_latency + extra_cycles + log + add_one) : ccm_initial_latency)) ;
	parameter C_LATENCY_nonseq = (C_PIPELINE == 1 ? C_LATENCY_sub : (C_MULT_TYPE < 2 ? 0 : C_LATENCY_sub)) ; //+extra_latency : 0) ;
	parameter serial_adjust1 = (C_SQM_TYPE == 1 && C_MULT_TYPE > 1 ) ? 1 : 0 ; 
	parameter serial_adjust = (C_SQM_TYPE == 1 && C_MULT_TYPE > 1) ? 1 : 0 ;
	parameter blk_mem_adjust = ((C_MULT_TYPE > 1 && C_MEM_TYPE == `c_dp_block && C_PIPELINE == 0 && ccm_numAdders_1 == 1) ? 1 : 0) ; // && C_LATENCY_nonseq == 0) ? 1 : 0) ; 
	parameter slicer_adjust = 0; // && C_PIPELINE == 0)) ? 1 : 0) ;
	parameter reg_adjust = (C_SQM_TYPE == 0 && C_PIPELINE == 0 && C_LATENCY_nonseq == 0 ? 1 : 0) ;
	parameter pipe_adjust = ((C_SQM_TYPE == 1 && C_PIPELINE == 0 && serial_adjust == 0) ? 1 : 0) ;
	parameter C_LATENCY_seq = C_LATENCY_nonseq + slicer_adjust + blk_mem_adjust ; 
	parameter nd_adjust = (C_HAS_ND == 1 && C_LATENCY_nonseq > 1 ) ? 1 : 0 ; //&& ~(C_MEM_TYPE == `c_dp_block && C_HAS_LOADB == 1 && C_HAS_SWAPB == 1 && C_PIPELINE == 0)) ? 1 : 0 ;
	parameter desperation = C_PIPELINE ; 
	parameter C_LATENCY = (C_LATENCY_nonseq+C_PIPELINE+blk_mem_adjust);
		//**********************************************************************************************************

	//Parameters to calculate the number of cycles that the sequential mult takes to process the inputs.
	parameter div_cycle = (C_A_WIDTH/C_BAAT) ;
	parameter mod_cycle = (C_A_WIDTH - (C_BAAT*div_cycle)) ;
	parameter no_of_cycles = (mod_cycle == 0 ? div_cycle : div_cycle+1) ;
	parameter number_clocks = no_of_cycles;
	
	//Determine if the slicer is going to be avoided
	parameter ccm_serial = (C_SQM_TYPE == 1 ? (C_MULT_TYPE >= 2 ? 1 : 0) : 0);
	//Calculate pipeline delay for the accum_sign
	parameter accum_delay = C_LATENCY-ccm_serial;
	//Calculate is accum_sign is actually needed
	parameter accum_sign_needed = (C_B_TYPE == `c_signed ? 1 : (mult_has_a_signed == 1 ? 1 : 0));
	//Calculate size of mult_width + sign extension if needed
	parameter accum_mult_width = mult_width + accum_sign_needed;
	//Calculate pipeline delay for ready
	parameter rdy_delay = C_HAS_Q+C_REG_A_B_INPUTS+C_LATENCY-ccm_serial+2-C_OUTPUT_HOLD;
	//Calculate size of accumulator output
	parameter accum_width = mult_width+1;	//accum_mult_width+1;
	//Calculate size of accumulator storage bits
	parameter accum_store_width = (C_BAAT*(number_clocks-1));
	//Determine if internal multiplier has an rfd
	parameter mult_has_rfd = (C_HAS_SWAPB ? 0 : (C_HAS_LOADB ? 1 : 0));
	//Offsets to ensure that verilog does not complain about reverse logic unnecessarily
	parameter temp_offset = (C_A_WIDTH == (C_BAAT*number_clocks) ? 1 : 0);
	parameter temp_mult = (C_REG_A_B_INPUTS+1-ccm_serial <= 1 ? 2-C_REG_A_B_INPUTS+1-ccm_serial : 0);
	parameter temp_accum = 0; //(accum_store_width > C_BAAT ? 0 : C_BAAT);
	parameter temp_mult_out = (accum_mult_width > 1 ? 0 : 1);
	//Calculate predelay value for internal multiplier
	parameter predelay = (C_MULT_TYPE > 2 ? 1 + C_REG_A_B_INPUTS - C_SQM_TYPE : 0);
	parameter rubbish = (C_LATENCY == 0 ? 1 : 0);
	parameter accum_sign_pipe_rubbish = (C_LATENCY == 0 ? 1 : 0);
	parameter accum_sign_pipe_rubbish2 = (C_LATENCY < 2 ? 2 : 0);
	parameter mult_signed_pipe_rubbish = (C_REG_A_B_INPUTS+1-ccm_serial == 0 ? 1 : 0);
	parameter mult_signed_pipe_rubbish2 = (C_REG_A_B_INPUTS+1-ccm_serial < 2 ? 1 : 0);
	parameter intO_rubbish = (C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED-C_OUT_WIDTH > 0 ? C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED-C_OUT_WIDTH : 0);

    parameter ncelab_accum_complete_low = ((C_OUT_WIDTH <= C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED) ? (C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED-C_OUT_WIDTH) : 0);
	parameter ncelab_into_high          = ((C_OUT_WIDTH <= C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED) ? (C_OUT_WIDTH) : (C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED));

    parameter ncelab_rfd_pipe_select    = ((number_clocks-C_REG_A_B_INPUTS-1 > 0) ? number_clocks-C_REG_A_B_INPUTS-2 : 0);
    parameter ncelab_rfd_pipe_low       = ((number_clocks-C_REG_A_B_INPUTS > 1) ? 1 : 0);

    parameter ncelab_accum_store_low    = ((accum_store_width > C_BAAT) ? C_BAAT : 0);
	parameter ncelab_accum_store_high   = ((accum_store_width > C_BAAT) ? (accum_store_width-C_BAAT) : accum_store_width);
	
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
	 
	//Clock enable signal for q registers
	wire int_q_ce;
	//Held a_input
	reg [(C_BAAT*number_clocks)-1 : 0] a_load;
	wire [C_B_WIDTH-1 : 0] regB;
	wire [(C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE)) : 0] regA;
	wire [C_B_WIDTH-1 : 0] regBB;
	wire [(C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE)) : 0] regAA;
	wire intCE;
	reg intA_SIGNED;
	wire regA_SIGNED;
	wire intACLR;
	wire intSCLR;
	wire initial_intCLK;
	reg intCLK;
	reg last_clk;
	wire intLOADB;
	wire intSWAPB = (C_HAS_SWAPB ? SWAPB : 0);
	wire regND;
	wire intND ;
	reg intRFD;
	reg reg_rfd;
	wire intLOAD_DONE;
	reg [C_OUT_WIDTH-1 : 0 ] intO;
	wire [C_OUT_WIDTH-1 : 0] intQ;
	wire a_signed_held;
	reg accum_load;
	wire RDY;
	reg [C_LATENCY+1 : 0] accum_pipe;
	reg [number_clocks-C_REG_A_B_INPUTS-1 : 0] rfd_pipe;
	wire intSCLR_pure;
	wire a_slice_load;
	wire a_slice_load_sclr;
	wire [C_BAAT-1 : 0] a_slice;
	wire [C_B_WIDTH-1 : 0] b_held;
	wire [C_B_WIDTH-1 : 0] b_reg;
	wire [(C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE)) : 0] a_reg;
	wire a_signed_reg;
	wire slice_rfd;
	wire int_nd;
	reg [accum_width+accum_store_width-1 : 0] accum_complete;
	reg [accum_width-1 : 0] accum_out;
	reg [accum_store_width-1 : 0] accum_store;
	reg [accum_width-1 : 0] accum_feedback;
	wire int_sclr_loadb_swapb;
	wire int_a_signed;
	wire pipe_rfd;
	wire mult_signed;
	reg int_mult_signed1;
	reg int_mult_signed2;
	reg int_mult_signed3;
	wire pipe_mult_signed;
	reg [C_REG_A_B_INPUTS+1-ccm_serial+temp_mult+mult_signed_pipe_rubbish+mult_signed_pipe_rubbish2 : 0] mult_signed_pipe;
	reg [accum_mult_width-1 : 0] accum_in;
	wire [mult_width-1 : 0] mult_out;
	reg accum_sign;
	reg [C_LATENCY-1+accum_sign_pipe_rubbish2 : 0] accum_sign_pipe;
	reg int_rdy;
	reg int_rdy_op_hold;
	reg int_rfd_reg;
	wire accum_mult_out_msb;
	
	wire [C_OUT_WIDTH-1 : 0] Q = (C_HAS_Q == 1 ? intQ : `allUKs);
	wire [C_OUT_WIDTH-1 : 0] O = (C_HAS_O == 1 ? intO : `allUKs);
	wire RFD = (C_HAS_RFD == 1 ? intRFD : 1'bx);
	wire LOAD_DONE = (C_HAS_LOAD_DONE == 1 ? intLOAD_DONE : 1'bx);
	wire [mult_width-1 : 0] mult_o;
	wire [mult_width-1 : 0] mult_q;
	wire dummy;
	wire mult_rfd;
	reg [rdy_delay : 0] int_rdy_pipe;
	reg [C_B_WIDTH-1 : 0] initB_INPUT;

	integer i, b_width, shift_bits, real_latency, real_rdy_delay;
	
	assign intCE = (C_HAS_CE == 1 ? CE : 1);
	assign initial_intCLK = CLK;
	assign intACLR = (C_HAS_ACLR == 1 ? ACLR : 0) ;
	//Combine SCLR with CE where appropriate depending on C_SYNC_ENABLE
	assign intSCLR = (C_HAS_SCLR == 1 ? (C_HAS_CE == 1 ? (C_SYNC_ENABLE == 0 ? SCLR : SCLR & CE) : SCLR) : 0);
	assign intSCLR_pure = (C_HAS_SCLR == 1 ? SCLR : 0);

	assign int_nd = (C_HAS_ND == 1 ? (C_REG_A_B_INPUTS == 1 ? regND : ND) : 1);
	assign a_slice_load = intCE & int_nd & slice_rfd;
	//Combine a_slice_load with sclr and CE where appropriate depending on C_SYNC_ENABLE
	assign a_slice_load_sclr = (C_HAS_SCLR == 1 ? (C_SYNC_ENABLE == 1 ? a_slice_load | (intSCLR & intCE) : a_slice_load) : a_slice_load);
	assign a_slice = a_load[C_BAAT-1 : 0];
	assign b_held = (C_MULT_TYPE < 2 ? regBB : (C_MULT_TYPE > 2 ? B : b_reg));
	assign a_reg = (C_REG_A_B_INPUTS == 1 ? regA : A);
	assign b_reg = (C_REG_A_B_INPUTS == 1 ? regB : B);
	assign a_signed_reg = (C_REG_A_B_INPUTS == 1 ? regA_SIGNED : A_SIGNED);
	assign slice_rfd = (C_REG_A_B_INPUTS == 1 ? reg_rfd : intRFD);
	//Combine int_sclr, loadb and swapb, CE and mult_rfd to reset rfd as appropriate depending on C_SYNC_ENABLE
	assign int_sclr_loadb_swapb = (C_HAS_SWAPB == 1 ? ((C_SYNC_ENABLE == 1 && C_HAS_CE == 1) ? (intSCLR | (intSWAPB & intCE)) : intSCLR | intSWAPB) : (C_HAS_LOADB == 1 ? ((C_SYNC_ENABLE == 1 && C_HAS_CE == 1) ? (intSCLR | ((!mult_rfd) & intCE)) : intSCLR | (!mult_rfd)) : intSCLR));
	assign int_a_signed = (C_HAS_A_SIGNED == 1 ? a_signed_held : (C_A_TYPE == `c_signed && C_SQM_TYPE == 0 ? 1 : 0));
	assign pipe_rfd = (number_clocks-C_REG_A_B_INPUTS-1 > 0 ? rfd_pipe[ncelab_rfd_pipe_select] : a_slice_load_sclr);
	assign mult_signed = (C_HAS_A_SIGNED == 1 ? (C_REG_A_B_INPUTS+1-ccm_serial == 0 ? int_mult_signed1 : pipe_mult_signed) : pipe_mult_signed & a_slice[C_BAAT-1]);
	assign pipe_mult_signed = (C_REG_A_B_INPUTS+1-ccm_serial == 0 ? pipe_rfd : mult_signed_pipe[C_REG_A_B_INPUTS+1-ccm_serial-1+mult_signed_pipe_rubbish]);

	assign RDY = (C_HAS_RDY == 1 ? (C_OUTPUT_HOLD == 1 ? int_rdy_op_hold : int_rdy) : 1'bx);
	
	assign mult_out = (C_PIPELINE == 1 ? mult_q : (blk_mem_adjust == 1 ? mult_q : mult_o));
	assign int_q_ce = (C_OUTPUT_HOLD == 1 ? (intCE & int_rdy) : intCE);
	assign accum_mult_out_msb = accum_in[accum_mult_width-1];
	assign intLOADB = (C_HAS_LOADB == 1 ? LOADB : 1'b0);
	
	MULT_GEN_V7_0_NON_SEQ #(BRAM_ADDR_WIDTH, mult_a_type, C_BAAT, C_BAAT, C_B_CONSTANT, C_B_TYPE,
							C_B_VALUE, C_B_WIDTH, C_ENABLE_RLOCS, C_HAS_ACLR, mult_has_a_signed,
							C_HAS_B, C_HAS_CE, C_HAS_LOADB, C_HAS_LOAD_DONE, 0, 1,
							1, 0, mult_has_rfd, C_HAS_SCLR, C_HAS_SWAPB, C_MEM_INIT_PREFIX,
							C_MEM_TYPE, C_MULT_TYPE, 0, mult_width, C_PIPELINE, predelay, 0, 0, 1,
							0, C_SYNC_ENABLE, C_USE_LUTS)
		int_mult (.A(a_slice), .B(b_held), .CLK(intCLK), .A_SIGNED(mult_signed), .CE(intCE), .ACLR(intACLR),
					  .SCLR(intSCLR), .LOADB(intLOADB), .LOAD_DONE(intLOAD_DONE), .SWAPB(intSWAPB), .RFD(mult_rfd),
					  .ND(1'b0), .RDY(dummy), .O(mult_o), .Q(mult_q));
	
	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, (C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE))+1)
		rega (.D(A), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR_pure), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regA)); 

	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, C_B_WIDTH)
		regb (.D(B), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR_pure), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regB)); 

    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   1, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, C_B_WIDTH)
		regbb (.D(b_reg), .CLK(intCLK), .CE(a_slice_load_sclr), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR_pure), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regBB));

	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   has_q_ce, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, C_OUT_WIDTH)
		regq (.D(intO), .CLK(intCLK), .CE(int_q_ce), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR_pure), .SSET(1'b0), .SINIT(1'b0),
			  .Q(intQ));

    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regnd (.D(ND), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR_pure), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regND));

	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regasig (.D(A_SIGNED), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR_pure), .SSET(1'b0), .SINIT(1'b0),
			  .Q(regA_SIGNED));
			  
	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, 0, 0,
			   C_HAS_CE, C_HAS_SCLR, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		regmultmsb (.D(accum_mult_out_msb), .CLK(intCLK), .CE(intCE), .ACLR(intACLR), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(intSCLR_pure), .SSET(1'b0), .SINIT(1'b0),
			  .Q(accum_mult_out_msb_delayed));

	C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
			   1, 0, 0, 0,
			   "0", C_SYNC_ENABLE, 0, 1)
		latchasig (.D(a_signed_reg), .CLK(intCLK), .CE(a_slice_load_sclr), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
			  .Q(a_signed_held));		   

	initial
	begin
		intRFD = 1 ;
		int_rfd_reg = 1;
		int_rdy_pipe = `intrdypipeall0s;
		rfd_pipe = `rfdpipeall0s;
		reg_rfd = 0;

		int_rdy = 0;
		int_rdy_op_hold = 0;

		accum_out = `accumall0s;
		accum_store = `accumstoreall0s;

        //Calculate the shift bits
		initB_INPUT = (C_MULT_TYPE < 2) ? B : to_bitsB(C_B_VALUE);

        //Find the real b input width
		if (C_MULT_TYPE > 1 && C_HAS_LOADB == 0)
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
		
		if (C_MULT_TYPE != 2) 
		begin
			shift_bits = 0 ;
		end
		else
		begin
			shift_bits = 0 ;
			for(i = C_B_WIDTH-1; i >= 0; i = i - 1)
			begin
				if (initB_INPUT[i] == 1)
					shift_bits = i ;
			end
		end

		if ((C_B_TYPE == `c_unsigned && (b_width-shift_bits) == 1 && C_HAS_LOADB == 0) || (C_HAS_LOADB == 0 && b_width == 0))
		begin
			real_latency = C_PIPELINE+blk_mem_adjust ;
		end
		else
		begin
			real_latency = C_LATENCY ;
		end

        real_rdy_delay = C_HAS_Q+C_REG_A_B_INPUTS+real_latency-ccm_serial+2-C_OUTPUT_HOLD;
	
	end

	always@(initial_intCLK)
	begin
		last_clk <= intCLK ;
		intCLK <= initial_intCLK ;
	end

	always@(accum_pipe or a_slice_load_sclr)
	begin
	   if ((real_latency-ccm_serial) >= 0)
	     accum_load = accum_pipe[real_latency-ccm_serial];
	   else
	     accum_load = a_slice_load_sclr;
	end

	always@(accum_sign_pipe or mult_signed)
	begin
	  if (real_latency > 0)
	    accum_sign = accum_sign_pipe[real_latency+accum_sign_pipe_rubbish-1];
	  else
	    accum_sign = mult_signed;
	end

	always@(int_rdy_pipe)
	begin
	  if (real_rdy_delay > 0)
	  begin
	    int_rdy = int_rdy_pipe[real_rdy_delay-1];
		int_rdy_op_hold = int_rdy_pipe[real_rdy_delay];
	  end
	  else
	  begin
	    int_rdy = int_rdy_pipe[0];
		int_rdy_op_hold = int_rdy_pipe[0];
	  end
	end

	//Process to calculate output when the clears go high.
	//In addition action on the SWAPB and LOADB pins also cause the sequential multiplier to 
	//de-assert RFD.
	always@(intACLR or intSCLR or int_sclr_loadb_swapb or int_rfd_reg)
	begin
		if (intACLR == 1 || int_sclr_loadb_swapb == 1)
			intRFD = 0 ;
		else
			intRFD = int_rfd_reg;
	end

	//Register rfd for serial parallel type
	always@(posedge intCLK)
	begin
		if (int_sclr_loadb_swapb == 1)
			reg_rfd <= 0;
		else 
		begin
			if (intCE == 1 && intACLR != 1)
				reg_rfd <= intRFD;
		end
	end

	//int_rfd_reg
	always@(posedge intCLK)
	begin
		if (int_sclr_loadb_swapb == 1)
			int_rfd_reg <= 1;
		else 
		begin
			if (intCE == 1 && intACLR != 1)
			begin
				if (C_HAS_ND == 1)
					int_rfd_reg <= (pipe_rfd && !intRFD) || (intRFD && !ND);
				else
					int_rfd_reg <= pipe_rfd && !intRFD;
			end
		end
	end
	
	//mult_sign serial
	always@(pipe_rfd or a_signed_reg or a_signed_held)
	begin
		if (C_HAS_A_SIGNED == 1 && C_REG_A_B_INPUTS+1-ccm_serial == 0)
		begin
			if (number_clocks-C_REG_A_B_INPUTS == 1)
				int_mult_signed1 <= pipe_rfd & a_signed_reg;
			else
				int_mult_signed1 <= pipe_rfd & a_signed_held;
		end
	end
	
	//int_mult_signed
	always@(pipe_rfd or a_signed_reg or a_signed_held or pipe_mult_signed or a_slice)
	begin
		if (C_HAS_A_SIGNED == 1)
		begin
			if (number_clocks-C_REG_A_B_INPUTS == 1)
				int_mult_signed2 <= pipe_rfd & a_signed_reg;
			else
				int_mult_signed2 <= pipe_rfd & a_signed_held;
		end
		else
			int_mult_signed2 <= pipe_rfd;
	end

	//int_rdy
	always@(posedge intCLK)
	begin
		if (intSCLR == 1)
			int_rdy_pipe <= `intrdypipeall0s;
		else if (intCE == 1 && intACLR == 0)
		begin
			if (rdy_delay > 0)
				int_rdy_pipe[rdy_delay : 1] <= int_rdy_pipe[rdy_delay-1 : 0];
			int_rdy_pipe[0] <= pipe_rfd;
		end
	end

	
	//For a serial, CCM type, we don't need any slicing
	always@(a_reg)
	begin
		if (C_SQM_TYPE == 1 && C_MULT_TYPE >= 2)
			a_load <= a_reg;
	end

	//Aclr all registers
	always@(intACLR)
	begin
		if (intACLR == 1)
		begin
			if (C_SQM_TYPE != 1 || C_MULT_TYPE < 2)
				a_load = `aloadall0s;
			accum_out = `accumall0s;
			accum_store = `storeall0s;
			if (real_latency >= 0)
				accum_pipe = `accumpipeall0s;
			rfd_pipe = `rfdpipeall0s;
			reg_rfd = 0;
			int_rfd_reg = 1;
			if (C_REG_A_B_INPUTS+1-ccm_serial > 0)
				mult_signed_pipe[C_REG_A_B_INPUTS+1-ccm_serial+mult_signed_pipe_rubbish+mult_signed_pipe_rubbish2-1 : 0] <= `multsignedpipeall0s;
			int_mult_signed2 = 0;
			if (real_latency > 0)
				accum_sign_pipe <= `accumsignpipeall0s;
			int_rdy_pipe <= `intrdypipeall0s;
		end
	end

	//Pipelines
	always@(posedge intCLK)
	begin
		if (intSCLR == 1)
		begin
			if (real_latency >= 0)
				accum_pipe <= `accumpipeall0s;
			if (C_REG_A_B_INPUTS+1-ccm_serial > 0)
				mult_signed_pipe[C_REG_A_B_INPUTS+1-ccm_serial+mult_signed_pipe_rubbish+mult_signed_pipe_rubbish2-1 : 0] <= `multsignedpipeall0s;
		end
		else if (intCE == 1 && intACLR == 0)
		begin
			if (C_LATENCY > 0)
				accum_pipe[C_LATENCY+rubbish : 1] <= accum_pipe[C_LATENCY+rubbish-1 : 0];
			if (real_latency >= 0)
				accum_pipe[0] <= a_slice_load_sclr;
			if (C_REG_A_B_INPUTS+1-ccm_serial > 1)
				mult_signed_pipe[C_REG_A_B_INPUTS+1-ccm_serial-1+temp_mult+mult_signed_pipe_rubbish+mult_signed_pipe_rubbish2 : 1] <= mult_signed_pipe[C_REG_A_B_INPUTS+1-ccm_serial-2+temp_mult+mult_signed_pipe_rubbish+mult_signed_pipe_rubbish2 : 0];
			if (C_REG_A_B_INPUTS+1-ccm_serial+temp_mult > 0)
				mult_signed_pipe[0] <= int_mult_signed2;
		end
	end

	//rfd pipeline
	always@(posedge intCLK)
	begin
		if (int_sclr_loadb_swapb == 1)
			rfd_pipe <= `rfdpipeall0s;
		else 
		begin
			if (intCE == 1 && intACLR == 0)
			begin
				if (number_clocks-C_REG_A_B_INPUTS > 1)
					rfd_pipe[number_clocks-C_REG_A_B_INPUTS-1 : ncelab_rfd_pipe_low] <= rfd_pipe[ncelab_rfd_pipe_select : 0];
				rfd_pipe[0] <= a_slice_load_sclr;
			end
		end
	end

	//Slice the A input
	always@(posedge intCLK)
	begin
		if (intSCLR == 1)
		begin
			if (C_SQM_TYPE != 1 || C_MULT_TYPE < 2)
				a_load <= `aloadall0s;
		end
		else if (intCE == 1 && intACLR != 1)
		begin
			if (C_SQM_TYPE == 0)	//need to slice
			begin
				if (a_slice_load == 1)
				begin
					a_load[C_A_WIDTH-1 : 0] <= a_reg;
					for (i = 0; i < (C_BAAT*number_clocks)-C_A_WIDTH; i = i + 1)	//sign extend as required
					begin
						if (C_HAS_A_SIGNED == 1)
						begin
							if (a_signed_reg == 1)
								a_load[(C_BAAT*number_clocks)+temp_offset-1-i] <= a_reg[C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE)];
							else
								a_load[(C_BAAT*number_clocks)+temp_offset-1-i] <= 0;
						end
						else if (C_A_TYPE == `c_signed)
							a_load[(C_BAAT*number_clocks)+temp_offset-1-i] <= a_reg[C_A_WIDTH-1-((C_A_WIDTH-1)*C_SQM_TYPE)];
						else
							a_load[(C_BAAT*number_clocks)+temp_offset-1-i] <= 0;
					end
				end
				else
				begin
					a_load[(C_BAAT*(number_clocks-1))-1 : 0] <= a_load[(C_BAAT*number_clocks)-1 : C_BAAT];
					for (i = 0; i < C_BAAT; i = i + 1)
					begin
						if (int_a_signed == 1)
							a_load[(C_BAAT*number_clocks)-1-i] <= a_load[(C_BAAT*number_clocks)-1];
						else
							a_load[(C_BAAT*number_clocks)-1-i] <= 0;
					end
				end
			end
			else	//need to pipeline balance if parm
			begin
				if (C_MULT_TYPE < 2)
				begin
					if ((intCE == 1 && slice_rfd == 0) || a_slice_load == 1)
						a_load <= a_reg;
				end
			end
		end
	end

	//Accumulate result
	always@(posedge intCLK)
	begin
		if (intSCLR == 1)
		begin
			accum_out <= `accumall0s;
			accum_store <= `storeall0s;
		end
		else if (intCE == 1 && intACLR != 1)
		begin
			if (accum_store_width > C_BAAT)
				//accum_store[accum_store_width-1-C_BAAT+temp_accum : 0] <= accum_store[accum_store_width-1+temp_accum : C_BAAT];
				accum_store[ncelab_accum_store_high-1 : 0] <= accum_store[accum_store_width-1+temp_accum : ncelab_accum_store_low];
			accum_store[accum_store_width-1 : accum_store_width-C_BAAT] <= accum_out[C_BAAT-1 : 0];
			if (accum_load == 1)
				accum_out <= accum_in;
			else
				accum_out <= accum_in + accum_feedback;
		end
	end

	//Feedback accumulator output
	always@(accum_out)
	begin
		accum_feedback[accum_width-C_BAAT-1 : 0] <= accum_out[accum_width-1 : C_BAAT];
		if (C_B_TYPE == `c_signed)
		begin
			for(i = 0; i < C_BAAT; i = i + 1)
				accum_feedback[accum_width-1-i] <= accum_out[accum_width-1];
		end
		else
		begin
			for(i = 0; i < C_BAAT; i = i + 1)
				accum_feedback[accum_width-1-i] <= 0;
		end
	end

	//accum_in
	always@(mult_out or accum_sign)
	begin
		if (accum_sign_needed == 1)
		begin
			if (C_B_TYPE == `c_signed)
				accum_in[accum_mult_width-1] = mult_out[accum_mult_width-2+temp_mult_out];
			else if (mult_has_a_signed == 1)
				accum_in[accum_mult_width-1] = accum_sign & mult_out[accum_mult_width-2+temp_mult_out];
		end
		else
			accum_in[accum_mult_width-1] = mult_out[mult_width-1];
	end

	always@(mult_out)
	begin
		if (accum_mult_width > 1)
			accum_in[accum_mult_width-2+temp_mult_out : 0] = mult_out[accum_mult_width-2+temp_mult_out :0];
	end

	//accum_sign
	always@(posedge intCLK)
	begin
		if (intSCLR == 1)
		begin
			if (real_latency > 0)
				accum_sign_pipe <= `accumsignpipeall0s;
		end
		else if (intCE == 1 && intACLR != 1)
		begin
			if (real_latency > 1)
				accum_sign_pipe[C_LATENCY-1+(accum_sign_pipe_rubbish2) : 1] <= accum_sign_pipe[C_LATENCY-2+(accum_sign_pipe_rubbish2) : 0];
			if (real_latency > 0)
				accum_sign_pipe[0] <= mult_signed;
		end
	end

	//accum_complete
	always@(accum_out or accum_store)
	begin
		accum_complete[accum_width+accum_store_width-1 : accum_store_width] = accum_out[accum_width-1 : 0];	//removed padding
		accum_complete[accum_store_width-1 : 0] = accum_store;
	end
   
   //O generation
	always@(accum_complete or accum_mult_out_msb_delayed)
	begin
		if (C_OUT_WIDTH <= C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED)	//accum_width+accum_store_width-padding)
			//intO <= accum_complete[C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED-1 : C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED-C_OUT_WIDTH];
			intO[ncelab_into_high-1:0] <= accum_complete[C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED-1 : ncelab_accum_complete_low];
		else 
		begin
			intO[C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED-1-intO_rubbish : 0] <= accum_complete[C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED-1-intO_rubbish : 0];
			if (accum_sign_needed == 1)
			begin
				if (C_B_TYPE == `c_signed)
				begin
					for (i = 0; i < (C_OUT_WIDTH-(C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED)); i = i+1)
						intO[C_OUT_WIDTH-1-i] <= accum_complete[accum_width+accum_store_width-1];	//C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED-1];
				end
				else
				begin
					for (i = 0; i < (C_OUT_WIDTH-(C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED)); i = i+1)
						intO[C_OUT_WIDTH-1-i] <= accum_mult_out_msb_delayed;
				end
			end
			else
			begin
				for (i = 0; i < (C_OUT_WIDTH-(C_A_WIDTH+C_B_WIDTH+C_HAS_A_SIGNED)); i = i+1)
					intO[C_OUT_WIDTH-1-i] <= 0;
			end
		end
	end

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
`undef c_distributed
`undef c_dp_block
`undef awidthall0s
`undef accumall0s 
`undef storeall0s 
`undef aloadall0s 
`undef accumpipeall0s
`undef rfdpipeall0s 
`undef multsignedpipeall0s
`undef accumsignpipeall0s 
`undef intrdypipeall0s
`undef allUKs
`undef accumcompall0s
`undef outputall0s
`undef accumstoreall0s






























