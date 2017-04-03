/* $Id: C_ADDSUB_V4_0.v,v 1.12 2008/09/08 20:05:45 akennedy Exp $
--
-- Filename - C_ADDSUB_V4_0.v
-- Author - Xilinx
-- Creation - 22 Mar 1999
--
-- Description - This file contains the Verilog behavior for the Baseblocks C_ADDSUB_V4_0 module
*/



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

module C_ADDSUB_V4_0 (A, B, CLK, ADD, C_IN, B_IN, CE, BYPASS, ACLR, ASET, AINIT,
					  SCLR, SSET, SINIT, A_SIGNED, B_SIGNED, OVFL, C_OUT, B_OUT,
					  Q_OVFL, Q_C_OUT, Q_B_OUT, S, Q);

	parameter C_ADD_MODE 		= `c_add;
	parameter C_AINIT_VAL 		= "";
	parameter C_A_TYPE 			= `c_unsigned;
	parameter C_A_WIDTH 		= 16;
	parameter C_BYPASS_ENABLE 	= `c_override;
	parameter C_BYPASS_LOW 		= 0;
	parameter C_B_CONSTANT 		= 0;
	parameter C_B_TYPE 			= `c_unsigned;
	parameter C_B_VALUE 		= "";
	parameter C_B_WIDTH 		= 16;
	parameter C_ENABLE_RLOCS	= 1;
	parameter C_HAS_ACLR 		= 0;
	parameter C_HAS_ADD 		= 0;
	parameter C_HAS_AINIT 		= 0;
	parameter C_HAS_ASET 		= 0;
	parameter C_HAS_A_SIGNED 	= 0;
	parameter C_HAS_BYPASS 		= 0;
	parameter C_HAS_B_IN 		= 1;
	parameter C_HAS_B_OUT 		= 0;
	parameter C_HAS_B_SIGNED 	= 0;
	parameter C_HAS_CE 			= 0;
	parameter C_HAS_C_IN 		= 1;
	parameter C_HAS_C_OUT 		= 0;
	parameter C_HAS_OVFL 		= 0;
	parameter C_HAS_Q 			= 1;
	parameter C_HAS_Q_B_OUT 	= 0;
	parameter C_HAS_Q_C_OUT 	= 0;
	parameter C_HAS_Q_OVFL 		= 0;
	parameter C_HAS_S 			= 0; 
	parameter C_HAS_SCLR 		= 0;
	parameter C_HAS_SINIT 		= 0;
	parameter C_HAS_SSET 		= 0;
	parameter C_HIGH_BIT 		= 15;
	parameter C_LATENCY	       	= 1;
	parameter C_LOW_BIT 		= 0;
	parameter C_OUT_WIDTH 		= 16;
	parameter C_PIPE_STAGES 	= 1;
	parameter C_SINIT_VAL 		= "";
	parameter C_SYNC_ENABLE 	= `c_override;
	parameter C_SYNC_PRIORITY 	= `c_clear;
	
	// internal parameters (not to be set from instanciation)
	parameter tmpWidth = (C_A_WIDTH > C_B_WIDTH) ? C_A_WIDTH + 2 : C_B_WIDTH + 2;
	parameter output_reg_width = C_HIGH_BIT-C_LOW_BIT+1;

	input [C_A_WIDTH-1 : 0] A;
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
	input A_SIGNED;
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
	wire [C_B_WIDTH-1 : 0] intBconst;
	wire [C_B_WIDTH-1 : 0] intB;
	wire intADD;
	wire intBYPASS;
	wire intC_IN;
	wire intB_IN;
	wire intCE;
	wire intQCE;
	wire intA_SIGNED;
	wire intB_SIGNED;
	reg intC_OUT;
	reg intB_OUT;
	reg intOVFL;
	wire intQ_C_OUT;
	wire intQ_B_OUT;
	wire intQ_OVFL;
	reg [C_HIGH_BIT : C_LOW_BIT ] intS;
	wire [C_HIGH_BIT : C_LOW_BIT ] intQ;
	wire intACLR;
	wire intASET;
	wire intAINIT;
	wire intSCLR;
	wire intSSET;
	wire intSINIT;
	wire intACLR_INIT;
	wire intSCLR_INIT;
	reg lastCLK;
	reg lastADD;
	
	reg [C_HIGH_BIT : C_LOW_BIT] intQpipe [C_LATENCY+2 : 0]; 
	reg [C_LATENCY+2 : 0] intQ_C_OUTpipe; 
	reg [C_LATENCY+2 : 0] intQ_B_OUTpipe; 
	reg [C_LATENCY : 0] intQ_OVFLpipe; 

	reg [C_HIGH_BIT : C_LOW_BIT] intQpipeend;
	reg intQ_C_OUTpipeend;
	reg intQ_B_OUTpipeend;
	reg intQ_OVFLpipeend;
	reg [C_HIGH_BIT : C_LOW_BIT] tmp_pipe1;
	reg [C_HIGH_BIT : C_LOW_BIT] tmp_pipe2;
	
	 
	wire [C_HIGH_BIT : C_LOW_BIT] Q = (C_HAS_Q == 1 ? intQ : `allUKs);
	wire Q_C_OUT = (C_HAS_Q_C_OUT == 1 ? intQ_C_OUT : 1'bx);
	wire Q_B_OUT = (C_HAS_Q_B_OUT == 1 ? intQ_B_OUT : 1'bx);
	wire Q_OVFL = (C_HAS_Q_OVFL == 1 ? intQ_OVFL : 1'bx);
	wire [C_HIGH_BIT : C_LOW_BIT] S = (C_HAS_S == 1 ? intS : `allUKs);
	wire C_OUT = (C_HAS_C_OUT == 1 ? intC_OUT : 1'bx);
	wire B_OUT = (C_HAS_B_OUT == 1 ? intB_OUT : 1'bx);
	wire OVFL = (C_HAS_OVFL == 1 ? intOVFL : 1'bx);
	
	// Sort out default values for missing ports
	
	assign intCE = defval(CE, C_HAS_CE, 1);
	assign intACLR = defval(ACLR, C_HAS_ACLR, 0);
	assign intASET = defval(ASET, C_HAS_ASET, 0);
	assign intAINIT = defval(AINIT, C_HAS_AINIT, 0);
	assign intSCLR = defval(SCLR, C_HAS_SCLR, 0);
	assign intSSET = defval(SSET, C_HAS_SSET, 0);
	assign intSINIT = defval(SINIT, C_HAS_SINIT, 0);
	assign intACLR_INIT = (intACLR || intAINIT);
	assign intSCLR_INIT = (intSCLR || intSINIT);
	
	assign intBconst = (C_B_CONSTANT === 1) ? to_bitsB(C_B_VALUE) : B;
	assign intADD = (C_HAS_ADD === 1) ? ADD : ((C_ADD_MODE === `c_add) ? 1 : ((C_ADD_MODE === `c_sub) ? 0 : 3)); // 3 is an illegal value since this is an illegal option!	
	assign intBYPASS = (C_HAS_BYPASS === 1) ? ((C_BYPASS_LOW === 1) ? !BYPASS : BYPASS) : 0;
	assign intC_IN = ((C_HAS_C_IN === 1) ? C_IN : ((C_HAS_ADD === 1) ? ~intADD : 0));
	assign intB_IN = defval(B_IN, C_HAS_B_IN, 1);
	assign intA_SIGNED = defval(A_SIGNED, C_HAS_A_SIGNED, 0);
	//assign intB_SIGNED = defval(B_SIGNED, C_HAS_B_SIGNED, 0);
	assign intB_SIGNED = ((C_HAS_B_SIGNED === 0) ? 0 : (((C_HAS_B_SIGNED === 1) && ~((C_B_CONSTANT === 1) && (C_HAS_BYPASS === 0) && (C_B_VALUE[((C_B_WIDTH*8)-1):((C_B_WIDTH-1)*8)] === "0")) ? B_SIGNED : 0))) ;
	assign intB = (intBYPASS === 0 ? intBconst : B);
	assign intQCE = (C_HAS_CE === 1 ? (C_HAS_BYPASS === 1 ? (C_BYPASS_ENABLE === `c_override ? CE || intBYPASS : CE) : CE) : 1'b1);
	
	integer j, k;
	integer pipe, pipe1;
	integer i;
	
	reg [tmpWidth-1 : 0] tmpA;
	reg [tmpWidth-1 : 0] tmpB;
	reg [tmpWidth-1 : 0] tmpC;
	reg [tmpWidth-1 : 0] tmpBC;
	reg [tmpWidth-1 : 0] tmpABC;
	reg [tmpWidth-2 : 0] tmpD;
	reg [tmpWidth-2 : 0] tmpE;
	reg [tmpWidth-2 : 0] tmpF;
	
	// Registers on outputs by default
	C_REG_FD_V4_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, output_reg_width)
		regq (.D(intQpipeend), .CLK(CLK), .CE(intQCE), .ACLR(ACLR), .ASET(ASET),
			  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
			  .Q(intQ)); 

	C_REG_FD_V4_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   "0", C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
		regcout (.D(intQ_C_OUTpipeend), .CLK(CLK), .CE(intQCE), .ACLR(intACLR_INIT),
			  .AINIT(AINIT), .ASET(ASET), .SCLR(intSCLR_INIT), .SINIT(SINIT), .SSET(SSET),
			  .Q(intQ_C_OUT)); 

	C_REG_FD_V4_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   "0", C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
		regbout (.D(intQ_B_OUTpipeend), .CLK(CLK), .CE(intQCE), .ACLR(intACLR_INIT),
			  .AINIT(AINIT), .ASET(ASET), .SCLR(intSCLR_INIT), .SINIT(SINIT), .SSET(SSET),
			  .Q(intQ_B_OUT)); 

	C_REG_FD_V4_0 #("0", C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
			   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
			   "0", C_SYNC_ENABLE, C_SYNC_PRIORITY, 1)
		regovfl (.D(intQ_OVFLpipeend), .CLK(CLK), .CE(intQCE), .ACLR(intACLR_INIT),
			  .AINIT(AINIT), .ASET(ASET), .SCLR(intSCLR_INIT), .SINIT(SINIT), .SSET(SSET),
			  .Q(intQ_OVFL)); 
	
	initial
	begin
	 	#1;
		for(i = 0; i <= C_LATENCY+2; i = i + 1)
		begin
			intQpipe[i] = 'bx;
			intQ_C_OUTpipe[i] = 1'bx;
			intQ_B_OUTpipe[i] = 1'bx;
			intQ_OVFLpipe[i] = 1'bx;
		end
		intQpipeend = `allUKs;
		intQ_C_OUTpipeend = 0;
		intQ_B_OUTpipeend = 0;
		intQ_OVFLpipeend = 0;
		intS = `allUKs;
		intC_OUT = 0;
		intB_OUT = 0;
		intOVFL = 0;
	end
	
	always@(A or intB or intADD or intBYPASS or intC_IN or intB_IN or intA_SIGNED or intB_SIGNED)
	begin
		tmpC = 0;
		if(intC_IN !== 1'b0)
		begin
			if((C_ADD_MODE == `c_add_sub && intADD == 1) || C_ADD_MODE == `c_add)
			begin
				tmpC = intC_IN;
			end
		end
		else if(intC_IN !== 1'b1 && C_ADD_MODE == `c_add_sub && intADD === 1'b0)
		begin
			tmpC[0] = ~intC_IN;
		end
		else if(intB_IN !== 1'b1 && C_ADD_MODE == `c_sub)
		begin
			tmpC[0] = ~intB_IN;
		end
		
		if(C_A_TYPE == `c_signed || (C_A_TYPE == `c_pin && intA_SIGNED === 1))
		begin
			for(j = tmpWidth-1; j >= C_A_WIDTH; j = j - 1)
			begin
				tmpA[j] = A[C_A_WIDTH-1];
			end
		end
		else if(C_A_TYPE == `c_unsigned || (C_A_TYPE == `c_pin && intA_SIGNED === 0))
		begin
			for(j = tmpWidth-1; j >= C_A_WIDTH; j = j - 1)
			begin
				tmpA[j] = 0;
			end
		end
		
		tmpA[C_A_WIDTH-1 : 0] = A;
		
		if(C_B_TYPE == `c_signed || (C_B_TYPE == `c_pin && intB_SIGNED === 1))
		begin
			for(j = tmpWidth-1; j >= C_B_WIDTH; j = j - 1)
			begin
				tmpB[j] = intB[C_B_WIDTH-1];
			end
		end
		else if(C_B_TYPE == `c_unsigned || (C_B_TYPE == `c_pin && intB_SIGNED === 0))
		begin
			for(j = tmpWidth-1; j >= C_B_WIDTH; j = j - 1)
			begin
				tmpB[j] = 0;
			end
		end
		
		tmpB[C_B_WIDTH-1 : 0] = intB;
		
		if(intBYPASS == 1)
		begin
			intS <= #1 tmpB[C_HIGH_BIT : C_LOW_BIT];
			if (is_X(tmpB) && C_LATENCY >1)
			begin
				intC_OUT <= #1 1'bx;
				intB_OUT <= #1 1'bx;
				intOVFL <= #1 1'bx;
			end
			else
			begin
				intC_OUT <= #1 1'b0;
				intB_OUT <= #1 1'b0;
				intOVFL <= #1 1'b0;
			end
		end
		else if(is_X(tmpA) || is_X(tmpB) || is_X(tmpC) || intBYPASS === 1'bx || intADD === 1'bx)
		begin
			intS <= #1 {C_HIGH_BIT-C_LOW_BIT+1{1'bx}};
			intC_OUT <= #1 1'bx;
			intB_OUT <= #1 1'bx;
			intOVFL <= #1 1'bx;
		end
		else
		begin
			if((C_ADD_MODE == `c_add_sub && intADD == 1) || C_ADD_MODE == `c_add)
			begin
				tmpBC = add(tmpB, tmpC);
			end
			else if((C_ADD_MODE == `c_add_sub && intADD == 0) || C_ADD_MODE == `c_sub)
			begin
				tmpBC = add(tmpB, tmpC);
			end
			
			if((C_ADD_MODE == `c_add_sub && intADD == 1) || C_ADD_MODE == `c_add)
			begin
				tmpABC = add(tmpA, tmpBC);
			end
			else if((C_ADD_MODE == `c_add_sub && intADD == 0) || C_ADD_MODE == `c_sub)
			begin
				tmpABC = sub(tmpA, tmpBC);
			end
			
			intS <= #1 tmpABC[C_HIGH_BIT : C_LOW_BIT];
			
			if(C_HAS_C_OUT == 1 || C_HAS_Q_C_OUT == 1)
			begin
				if((C_ADD_MODE == `c_add_sub && intADD === 1'b1) || C_ADD_MODE == `c_add)
					intC_OUT <= #1 tmpABC[tmpWidth-2];
				else if(C_ADD_MODE == `c_add_sub && intADD === 1'b0)
					intC_OUT <= #1 ~tmpABC[tmpWidth-2];
			end
			
			if(C_HAS_B_OUT == 1 || C_HAS_Q_B_OUT == 1)
			begin
				intB_OUT <= #1 !tmpABC[tmpWidth-2];
			end
			
			if(C_HAS_OVFL == 1 || C_HAS_Q_OVFL == 1)
			begin
				tmpD[tmpWidth-3 : 0] = tmpA[tmpWidth-3 : 0];
				if(C_A_TYPE == `c_signed || (C_A_TYPE == `c_pin && intA_SIGNED == 1)) 
					tmpD[tmpWidth-2] = tmpA[tmpWidth-1];
				else
					tmpD[tmpWidth-2] = 1'b0;
				tmpE[tmpWidth-3 : 0] = tmpBC[tmpWidth-3 : 0];
				if(C_B_TYPE == `c_signed || (C_B_TYPE == `c_pin && intB_SIGNED == 1)) 
					tmpE[tmpWidth-2] = tmpBC[tmpWidth-1];
				else
					tmpE[tmpWidth-2] = 1'b0;
				if((C_ADD_MODE == `c_add_sub && intADD == 1) || C_ADD_MODE == `c_add)
				begin
					tmpF = sm_add(tmpD, tmpE);
				end
				else if((C_ADD_MODE == `c_add_sub && intADD == 0) || C_ADD_MODE == `c_sub)
				begin
					tmpF = sm_sub(tmpD, tmpE);
				end
				
				intOVFL <= #1 tmpF[tmpWidth-3] ^ tmpABC[tmpWidth-2];
			end
		end			
	end
	
	always@(posedge CLK)
		lastADD <= intADD;
	
	always@(posedge CLK)
	begin
		if(CLK === 1'b1 && lastCLK === 1'b0 && intCE === 1'b1) // OK! Update pipelines!
		begin
			if (lastADD === intADD) // is pipeline data valid?
			begin
				for(pipe = 2; pipe <= C_LATENCY-1; pipe = pipe + 1)
				begin
					intQpipe[pipe] <= intQpipe[pipe+1];
					intQ_C_OUTpipe[pipe] <= intQ_C_OUTpipe[pipe+1];
					intQ_B_OUTpipe[pipe] <= intQ_B_OUTpipe[pipe+1];
					intQ_OVFLpipe[pipe] <= intQ_OVFLpipe[pipe+1];
				end
			end
			else
			begin
				for(pipe = 2; pipe <= C_LATENCY-1; pipe = pipe + 1)
				begin
					intQpipe[pipe] <= 'bx;
					intQ_C_OUTpipe[pipe] <= 1'bx;
					intQ_B_OUTpipe[pipe] <= 1'bx;
					intQ_OVFLpipe[pipe] <= 1'bx;
				end
			end
			intQpipe[C_LATENCY] <= intS;
			intQ_C_OUTpipe[C_LATENCY] <= intC_OUT;
			intQ_B_OUTpipe[C_LATENCY] <= intB_OUT;
			intQ_OVFLpipe[C_LATENCY] <= intOVFL;
		end
		else if((CLK === 1'bx && lastCLK === 1'b0) || (CLK === 1'b1 && lastCLK === 1'bx) || intCE === 1'bx) // POSSIBLY Update pipelines!
		begin
			for(pipe = 2; pipe <= C_LATENCY-1; pipe = pipe + 1)
			begin
				if(intQ_C_OUTpipe[pipe] !== intQ_C_OUTpipe[pipe+1])
					intQ_C_OUTpipe[pipe] <= 1'bx;
				if(intQ_B_OUTpipe[pipe] !== intQ_B_OUTpipe[pipe+1])
					intQ_B_OUTpipe[pipe] <= 1'bx;
				if(intQ_OVFLpipe[pipe] !== intQ_OVFLpipe[pipe+1])
					intQ_OVFLpipe[pipe] <= 1'bx;
				tmp_pipe1 = intQpipe[pipe];
				tmp_pipe2 = intQpipe[pipe+1];
				for(pipe1 = C_LOW_BIT; pipe1 < C_HIGH_BIT+1; pipe1 = pipe1 + 1)
				begin
					if(tmp_pipe1[pipe1] !== tmp_pipe2[pipe1])
						tmp_pipe1[pipe1] = 1'bx;
				end
				intQpipe[pipe] <= tmp_pipe1;
			end
			if(intQ_C_OUTpipe[C_LATENCY] !== intC_OUT)
				intQ_C_OUTpipe[C_LATENCY] <= 1'bx;
			if(intQ_B_OUTpipe[C_LATENCY] !== intB_OUT)
				intQ_B_OUTpipe[C_LATENCY] <= 1'bx;
			if(intQ_OVFLpipe[C_LATENCY] !== intOVFL)
				intQ_OVFLpipe[C_LATENCY] <= 1'bx;
			for(pipe1 = C_LOW_BIT; pipe1 < C_HIGH_BIT+1; pipe1 = pipe1 + 1)
			begin
				if(tmp_pipe1[pipe1] !== intS[pipe1])
					tmp_pipe1[pipe1] = 1'bx;
			end
			intQpipe[C_LATENCY] <= tmp_pipe1;
		end
	end
	
	always@(intS or intQpipe[2] or intADD or lastADD)
	begin
		if(C_LATENCY < 2) // No pipeline
			intQpipeend <= intS;
		else if (lastADD === intADD)
			// Pipeline stages required
			intQpipeend <= intQpipe[2];
		else
			// pipeline data invalid
			intQpipeend <= 'bx;
	end
	
	always@(intC_OUT or intQ_C_OUTpipe[2] or intADD or lastADD)
	begin
		if(C_LATENCY < 2) // No pipeline
			intQ_C_OUTpipeend <= intC_OUT;
		else if (lastADD === intADD)
			// Pipeline stages required
			intQ_C_OUTpipeend <= intQ_C_OUTpipe[2];
		else
			// Pipeline data invalid
			intQ_C_OUTpipeend <= 1'bx;
	end
	
	always@(intB_OUT or intQ_B_OUTpipe[2] or intADD or lastADD)
	begin
		if(C_LATENCY < 2) // No pipeline
			intQ_B_OUTpipeend <= intB_OUT;
		else if (lastADD === intADD)
			// Pipeline stages required
			intQ_B_OUTpipeend <= intQ_B_OUTpipe[2];
		else
			intQ_B_OUTpipeend <= 1'bx;
	end
	
	always@(intOVFL or intQ_OVFLpipe[2] or intADD or lastADD)
	begin
		if(C_LATENCY < 2) // No pipeline
			intQ_OVFLpipeend <= intOVFL;
		else if (lastADD === intADD)
			// Pipeline stages required 
			intQ_OVFLpipeend <= intQ_OVFLpipe[2];
		else
			intQ_OVFLpipeend <= 1'bx;
	end

	always@(CLK)
		lastCLK <= CLK;
	
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
					$display("Error: non-binary digit in string \"%s\"\nExiting simulation...", instring);
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
	
	function is_X;
	input [tmpWidth-1 : 0] i;
	begin
		is_X = 1'b0;
		for(j = 0; j < tmpWidth; j = j + 1)
		begin
			if(i[j] === 1'bx) 
				is_X = 1'b1;
		end // loop
	end
	endfunction
	
	function [tmpWidth-1 : 0] add;
	input [tmpWidth-1 : 0] i1;
	input [tmpWidth-1 : 0] i2;
	integer bit_index;
	integer carryin, carryout;
	begin
		carryin = 0;
		carryout = 0;
		for(bit_index=0; bit_index < tmpWidth; bit_index = bit_index + 1)
		begin
			add[bit_index] = i1[bit_index] ^ i2[bit_index] ^ carryin;
			carryout = (i1[bit_index] && i2[bit_index]) || (carryin && (i1[bit_index] || i2[bit_index]));
			carryin = carryout;
		end
	end
	endfunction
	
	function [tmpWidth-1 : 0] sub;
	input [tmpWidth-1 : 0] i1;
	input [tmpWidth-1 : 0] i2;
	begin
		i2 = add(~i2, 1);
		sub = add(i1, i2);
	end
	endfunction
	
	function [tmpWidth-2 : 0] sm_add;
	input [tmpWidth-2 : 0] i1;
	input [tmpWidth-2 : 0] i2;
	integer bit_index;
	integer carryin, carryout;
	begin
		carryin = 0;
		carryout = 0;
		for(bit_index=0; bit_index < tmpWidth-1; bit_index = bit_index + 1)
		begin
			sm_add[bit_index] = i1[bit_index] ^ i2[bit_index] ^ carryin;
			carryout = (i1[bit_index] && i2[bit_index]) || (carryin && (i1[bit_index] || i2[bit_index]));
			carryin = carryout;
		end
	end
	endfunction
	
	function [tmpWidth-2 : 0] sm_sub;
	input [tmpWidth-2 : 0] i1;
	input [tmpWidth-2 : 0] i2;
	begin
		i2 = sm_add(~i2, 1);
		sm_sub = sm_add(i1, i2);
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

