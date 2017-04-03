// Copyright(C) 2004 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.


/* $Id: MULT_GEN_V7_0.v,v 1.13 2008/09/08 20:09:14 akennedy Exp $
--
-- Filename - MULT_GEN_V7_0.v
-- Author - Xilinx
-- Creation - 22 Mar 1999
--
-- Description - This file contains the Verilog behavior for the multiplier module
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

module MULT_GEN_V7_0 (A, B, CLK, A_SIGNED, CE, ACLR,
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
        parameter C_V2_SPEED            = 1;

    parameter non_seq_cawidth   = (C_BAAT == C_A_WIDTH ? (C_BAAT == 1 ? C_A_WIDTH+1 : C_A_WIDTH) : C_A_WIDTH);
	parameter non_seq_cbaat     = (C_BAAT == C_A_WIDTH ? 1 : C_BAAT);
	parameter ser_seq_cawidth   = (C_BAAT == C_A_WIDTH ? (C_BAAT == 1 ? C_A_WIDTH+1 : C_A_WIDTH) : (C_SQM_TYPE == 0 ? C_A_WIDTH : 1));
	parameter non_seq_cbwidth   = (C_BAAT == C_A_WIDTH ? (C_B_WIDTH == 1 ? 2 : C_B_WIDTH) : C_B_WIDTH);
	parameter non_seq_out_width = (C_BAAT == C_A_WIDTH ? 1 : C_OUT_WIDTH);

    parameter INT_C_SYNC_ENABLE = (C_HAS_CE == 1 ? C_SYNC_ENABLE : 0);

    parameter NEW_TYPE = C_MULT_TYPE; //(C_MULT_TYPE == 5 ? 1 : C_MULT_TYPE);

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

    wire RFD_seq;
	wire RFD_non_seq;
	wire RDY_seq;
	wire RDY_non_seq;
	wire LOAD_DONE_seq;
	wire LOAD_DONE_non_seq;
    wire [non_seq_out_width-1 : 0] O_seq;
	wire [C_OUT_WIDTH-1 : 0] O_non_seq;
	wire [non_seq_out_width-1 : 0] Q_seq;
	wire [C_OUT_WIDTH-1 : 0] Q_non_seq;

    wire [(2*C_A_WIDTH)-1:0] dummyA = A + A;
    wire [ser_seq_cawidth-1:0] seqA = (C_BAAT == C_A_WIDTH ? (C_BAAT == 1 ? dummyA : A) : A);

    wire [(2*C_B_WIDTH)-1:0] dummyB = B + B;
	wire [non_seq_cbwidth-1:0] seqB = (C_BAAT == C_A_WIDTH ? (C_B_WIDTH == 1 ? dummyB : B) : B);

    wire intLOADB = ((C_HAS_LOADB == 1 && C_MULT_TYPE > 2 && C_MULT_TYPE < 5) ? LOADB : 0);
	wire intSWAPB = ((C_HAS_SWAPB == 1 && C_MULT_TYPE == 4) ? SWAPB : 0);

    wire RFD = (C_HAS_RFD == 1 ? (C_BAAT == C_A_WIDTH ? RFD_non_seq : RFD_seq) : 1'bx); 
	wire RDY = (C_HAS_RDY == 1 ? (C_BAAT == C_A_WIDTH ? RDY_non_seq : RDY_seq) : 1'bx);
	wire LOAD_DONE = (C_HAS_LOAD_DONE == 1 ? (C_BAAT == C_A_WIDTH ? LOAD_DONE_non_seq : LOAD_DONE_seq) : 1'bx);
	wire [C_OUT_WIDTH-1 : 0] O = (C_HAS_O == 1 ? (C_BAAT == C_A_WIDTH ? O_non_seq : O_seq) : 1'bx);
	wire [C_OUT_WIDTH-1 : 0] Q = (C_HAS_Q == 1 ? (C_BAAT == C_A_WIDTH ? Q_non_seq : Q_seq) : 1'bx);

    MULT_GEN_V7_0_NON_SEQ #(BRAM_ADDR_WIDTH, C_A_TYPE, C_A_WIDTH, C_BAAT, C_B_CONSTANT,
	                        C_B_TYPE, C_B_VALUE, C_B_WIDTH, C_ENABLE_RLOCS, C_HAS_ACLR,
							C_HAS_A_SIGNED, C_HAS_B, C_HAS_CE, C_HAS_LOADB, C_HAS_LOAD_DONE,
							C_HAS_ND, C_HAS_O, C_HAS_Q, C_HAS_RDY, C_HAS_RFD, C_HAS_SCLR,
							C_HAS_SWAPB, C_MEM_INIT_PREFIX, C_MEM_TYPE, NEW_TYPE, C_OUTPUT_HOLD, 
							C_OUT_WIDTH, C_PIPELINE, 0, C_REG_A_B_INPUTS, C_SQM_TYPE, 
							C_STACK_ADDERS, C_STANDALONE, INT_C_SYNC_ENABLE, C_USE_LUTS, C_V2_SPEED)
       non_seq_mult (.A(A), .B(B), .CLK(CLK), .A_SIGNED(A_SIGNED), .CE(CE), 
                     .ACLR(ACLR), .SCLR(SCLR), .LOADB(intLOADB), 
	                 .LOAD_DONE(LOAD_DONE_non_seq), .SWAPB(intSWAPB), .RFD(RFD_non_seq),
					 .ND(ND), .RDY(RDY_non_seq), .O(O_non_seq),
					 .Q(Q_non_seq));
    
	MULT_GEN_V7_0_SEQ #(BRAM_ADDR_WIDTH, C_A_TYPE, non_seq_cawidth, non_seq_cbaat, C_B_CONSTANT,
	                    C_B_TYPE, C_B_VALUE, non_seq_cbwidth, C_ENABLE_RLOCS, C_HAS_ACLR,
  					    C_HAS_A_SIGNED, C_HAS_B, C_HAS_CE, C_HAS_LOADB, C_HAS_LOAD_DONE,
						C_HAS_ND, C_HAS_O, C_HAS_Q, C_HAS_RDY, C_HAS_RFD, C_HAS_SCLR,
						C_HAS_SWAPB, C_MEM_INIT_PREFIX, C_MEM_TYPE, NEW_TYPE, C_OUTPUT_HOLD, 
						non_seq_out_width, C_PIPELINE, C_REG_A_B_INPUTS, C_SQM_TYPE, 
						C_STACK_ADDERS, C_STANDALONE, INT_C_SYNC_ENABLE, C_USE_LUTS)
       seq_mult (.A(seqA), .B(seqB), .CLK(CLK), .A_SIGNED(A_SIGNED), .CE(CE), 
                     .ACLR(ACLR), .SCLR(SCLR), .LOADB(intLOADB),
	                 .LOAD_DONE(LOAD_DONE_seq), .SWAPB(intSWAPB), .RFD(RFD_seq), .ND(ND), 
					 .RDY(RDY_seq),  .O(O_seq),
					 .Q(Q_seq));

    initial
	begin

    end

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

