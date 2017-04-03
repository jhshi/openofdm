// Copyright(C) 2003 by Xilinx, Inc. All rights reserved. 
// This text/file contains proprietary, confidential 
// information of Xilinx, Inc., is distributed under license 
// from Xilinx, Inc., and may be used, copied and/or 
// disclosed only pursuant to the terms of a valid license 
// agreement with Xilinx, Inc. Xilinx hereby grants you 
// a license to use this text/file solely for design, simulation, 
// implementation and creation of design files limited 
// to Xilinx devices or technologies. Use with non-Xilinx 
// devices or technologies is expressly prohibited and 
// immediately terminates your license unless covered by 
// a separate agreement. 
// 
// Xilinx is providing this design, code, or information 
// "as is" solely for use in developing programs and 
// solutions for Xilinx devices. By providing this design, 
// code, or information as one possible implementation of 
// this feature, application or standard, Xilinx is making no 
// representation that this implementation is free from any 
// claims of infringement. You are responsible for 
// obtaining any rights you may require for your implementation. 
// Xilinx expressly disclaims any warranty whatsoever with 
// respect to the adequacy of the implementation, including 
// but not limited to any warranties or representations that this 
// implementation is free from claims of infringement, implied 
// warranties of merchantability or fitness for a particular 
// purpose. 
// 
// Xilinx products are not intended for use in life support 
// appliances, devices, or systems. Use in such applications are 
// expressly prohibited. 
// 
// This copyright and support notice must be retained as part 
// of this text at all times. (c) Copyright 1995-2003 Xilinx, Inc. 
// All rights reserved.



/* $Revision: 1.13 $ $Date: 2008/09/08 20:06:53 $
--
-- Filename - C_DIST_MEM_V7_0.v
-- Author - Xilinx
-- Creation - 24 Mar 1999
--
-- Description
--  Distributed RAM Simulation Model
*/


`timescale 1ns/10ps
`define all0s 'b0
`define all1s {C_WIDTH{1'b1}}
`define allXs {C_WIDTH{1'bx}}
`define allZs {C_WIDTH{1'bz}}
`define addrallXs {C_ADDR_WIDTH{1'bx}}

`define c_rom 0
`define c_sp_ram 1
`define c_dp_ram 2
`define c_srl16 3

`define c_lut_based 0
`define c_buft_based 1

module C_DIST_MEM_V7_0 (A, D, DPRA, SPRA, CLK, WE, I_CE, RD_EN, QSPO_CE, QDPO_CE, QDPO_CLK, QSPO_RST, QDPO_RST, QSPO_SRST, QDPO_SRST, SPO, DPO, QSPO, QDPO);

  parameter C_ADDR_WIDTH     = 6;
  parameter C_DEFAULT_DATA   = "0";
  parameter C_DEFAULT_DATA_RADIX = 1;
  parameter C_DEPTH          = 64;
  parameter C_ENABLE_RLOCS   = 1;
  parameter C_GENERATE_MIF   = 0;
  parameter C_HAS_CLK        = 1;
  parameter C_HAS_D          = 1;
  parameter C_HAS_DPO        = 0;
  parameter C_HAS_DPRA       = 0;
  parameter C_HAS_I_CE       = 0;
  parameter C_HAS_QDPO       = 0;
  parameter C_HAS_QDPO_CE    = 0;
  parameter C_HAS_QDPO_CLK   = 0;
  parameter C_HAS_QDPO_RST   = 0;    // RSTB
  parameter C_HAS_QDPO_SRST  = 0;
  parameter C_HAS_QSPO       = 0;
  parameter C_HAS_QSPO_CE    = 0;
  parameter C_HAS_QSPO_RST   = 0;    // RSTA
  parameter C_HAS_QSPO_SRST  = 0;
  parameter C_HAS_RD_EN      = 0;
  parameter C_HAS_SPO        = 1;
  parameter C_HAS_SPRA       = 0;
  parameter C_HAS_WE         = 1;
  parameter C_LATENCY    = 0;
  parameter C_MEM_INIT_FILE  = "null.mif";
  parameter C_MEM_TYPE       = 1; // c_sp_ram
  parameter C_MUX_TYPE       = 0; // c_lut_based
  parameter C_QCE_JOINED     = 0;
  parameter C_QUALIFY_WE     = 0;
  parameter C_READ_MIF       = 0;
  parameter C_REG_A_D_INPUTS = 0;
  parameter C_REG_DPRA_INPUT = 0;
  parameter C_SYNC_ENABLE	 = 0;
  parameter C_WIDTH          = 16;
  parameter radix = C_DEFAULT_DATA_RADIX;
  parameter pipe_stages = C_LATENCY-C_REG_A_D_INPUTS;
  parameter dpo_pipe_stages = pipe_stages+1-C_HAS_QSPO;	// replaced C_HAS_QDPO for 1 as this parameter is only valid when C_HAS_QDPO anyway
  parameter C_RAM32_FIX      = 0;	// should not be passed in to simulation model

  parameter NCELAB_DPO_PIPE_CONSTANT = (dpo_pipe_stages < 2 ? 0 : 2);
  parameter NCELAB_SPO_PIPE_CONSTANT = (pipe_stages < 2 ? 0 : 2);

  input  [C_ADDR_WIDTH-1 - (C_ADDR_WIDTH>4?(4*C_HAS_SPRA):0) : 0] A;
  input  [C_WIDTH-1 : 0] D;
  input  [C_ADDR_WIDTH-1 : 0] DPRA;
  input  [C_ADDR_WIDTH-1 : 0] SPRA;
  input  CLK;
  input  WE;
  input  I_CE;
  input  RD_EN;
  input  QSPO_CE;
  input  QDPO_CE;
  input  QDPO_CLK;
  input  QSPO_RST;
  input  QDPO_RST;
  input  QSPO_SRST;
  input  QDPO_SRST;
  output [C_WIDTH-1 : 0] SPO;
  output [C_WIDTH-1 : 0] QSPO;
  output [C_WIDTH-1 : 0] DPO;
  output [C_WIDTH-1 : 0] QDPO;

	// Address signal connected to memory
	wire [C_ADDR_WIDTH - 1 : 0] a_int;
	// Read Address signal connected to srl16-based memory
	wire [C_ADDR_WIDTH - 1 : 0] spra_int;
	// Registered Address signal connected to memory
	wire [C_ADDR_WIDTH - 1 : 0] a_int1;
	// Registered Read Address signal connected to srl16-based memory
	wire [C_ADDR_WIDTH - 1 : 0] spra_int1;
	// DP port address signal connected to memory
	wire [C_ADDR_WIDTH - 1 : 0] dpra_int;
	// DP port address signal connected to memory
	wire [C_ADDR_WIDTH - 1 : 0] dpra_int1;
	// Input data signal connected to memory
	wire [C_WIDTH - 1 : 0] d_int;
	// Registered Input data signal connected to memory
	wire [C_WIDTH - 1 : 0] d_int1;
 	// DP output register clock
 	wire doclk;
    // Input data/address/WE register Clock Enable
	wire ice;
	// Special address register Clock Enable for ROMs
	wire a_reg_ice;
 	// DP read address port register clock enable
// 	wire dpra_ce;
	// WE wire connected to memory
	wire we_int;
	// Registered WE wire connected to memory
	wire we_int1;
	// Clock enable for the WE register
	wire wece;
	// Read Enable wire connected to BUFT-type output mux
	wire re_int;
	// Registered Read Enable wire connected to BUFT-type output mux
	wire re_int1;
	// unregistered version of qspo_ce
	wire qspo_ce_int;
	// possibly registered version of qspo_ce
	wire qspo_ce_reg;
	// registered version of qspo_ce
	wire qspo_ce_reg1;
	// unregistered version of qdpo_ce
	wire qdpo_ce_int;
	// possibly registered version of qdpo_ce
	wire qdpo_ce_reg;
	// registered version of qdpo_ce
	wire qdpo_ce_reg1;
	// possibly single port registered output reset
        wire qspo_rst_int;
        // possibly dual port registered output reset
        wire qdpo_rst_int;
	// possibly single port registered output sync reset
        wire qspo_srst_int;
        // possibly dual port registered output sync reset
        wire qdpo_srst_int;
	// Direct SP output from memory
	reg [C_WIDTH - 1 : 0] spo_async;
	// Direct DP output from memory
	reg [C_WIDTH - 1 : 0] dpo_async;
	// Possibly pipelined and/or registered SP output from memory
	wire [C_WIDTH - 1 : 0] intQSPO;
	// Possibly pipelined and/or registered DP output from memory
	wire [C_WIDTH - 1 : 0] intQDPO;
	// Pipeline signals
 	reg [C_WIDTH - 1 : 0] spo_pipe [pipe_stages+2 : 0];
 	reg [C_WIDTH - 1 : 0] dpo_pipe [dpo_pipe_stages+2 : 0];
	// Possibly pipelined SP output from memory
 	reg [C_WIDTH - 1 : 0] spo_pipeend;
	// Possibly pipelined DP output from memory
 	reg [C_WIDTH - 1 : 0] dpo_pipeend;
    // BUFT outputs
    wire [C_WIDTH - 1 : 0] spo_reg;
    wire [C_WIDTH - 1 : 0] dpo_reg;
    wire [C_WIDTH - 1 : 0] spo_reg_tmp;
    wire [C_WIDTH - 1 : 0] dpo_reg_tmp;

	integer pipe, pipe1, pipe2, pipe3, pipe4, i, j, srl_start, srl_end;
	
	// Array to hold ram data
	reg [C_WIDTH-1 : 0] ram_data [C_DEPTH-1 : 0];
	reg [C_WIDTH-1 : 0] tmp_data1;
	reg [C_WIDTH-1 : 0] tmp_data2;
		
	reg [C_WIDTH-1 : 0] default_data;
	reg [C_WIDTH-1 : 0] spo_tmp;
	reg [C_WIDTH-1 : 0] dpo_tmp;
	reg [C_WIDTH-1 : 0] tmp_pipe1;
	reg [C_WIDTH-1 : 0] tmp_pipe2;
	reg [C_WIDTH-1 : 0] tmp_pipe3;
	reg lastCLK;
	reg lastdoclk;

    reg start;
    
  function integer ADDR_IS_X;
    input [C_ADDR_WIDTH-1 : 0] value;
    integer i;
  begin
    ADDR_IS_X = 0;
    for(i = 0; i < C_ADDR_WIDTH; i = i + 1)
      if(value[i] === 1'bx)
        ADDR_IS_X = 1;
  end
  endfunction
  
  // Deal with the optional output signals...
  wire [C_WIDTH - 1 : 0] SPO = (C_HAS_SPO ? (C_MUX_TYPE == `c_lut_based ? spo_async : spo_reg) : `allXs);
  wire [C_WIDTH - 1 : 0] DPO = (C_HAS_DPO && C_MEM_TYPE == `c_dp_ram ? (C_MUX_TYPE == `c_lut_based ? dpo_async : dpo_reg) : `allXs);
  wire [C_WIDTH - 1 : 0] QSPO = (C_HAS_QSPO ? intQSPO : `allXs);
  wire [C_WIDTH - 1 : 0] QDPO = (C_HAS_QDPO ? intQDPO : `allXs);
  
  // Deal with the optional input signals...
  
  assign ice = (C_HAS_I_CE == 1 ? I_CE : 1'b1);
  assign a_reg_ice = (C_MEM_TYPE == `c_rom ? qspo_ce_int : ice);
  assign wece = (C_HAS_WE == 1 && C_REG_A_D_INPUTS == 1 && C_QUALIFY_WE == 1 ? ice : 1'b1);
//  assign dpra_ce = (C_HAS_QDPO_CE == 1  ? QDPO_CE : 1'b1);
  assign doclk = (C_HAS_QDPO_CLK == 1 ? QDPO_CLK : CLK);
  assign qspo_ce_int = (C_HAS_QSPO_CE == 1 ? QSPO_CE : 1'b1);
  assign qdpo_ce_int = (C_QCE_JOINED == 1 ? qspo_ce_int : (C_HAS_QDPO_CE == 1 ? QDPO_CE : ((C_HAS_QSPO == 1 && C_MEM_TYPE == `c_srl16) ? qspo_ce_int : 1'b1))); 
  assign qspo_rst_int = (C_HAS_QSPO_RST && C_HAS_QSPO ? QSPO_RST : 1'b0);
  assign qdpo_rst_int = (C_HAS_QDPO_RST && C_HAS_QDPO ? QDPO_RST : 1'b0);
  assign qspo_srst_int = (C_HAS_QSPO_SRST && C_HAS_QSPO ? QSPO_SRST : 1'b0);
  assign qdpo_srst_int = (C_HAS_QDPO_SRST && C_HAS_QDPO ? QDPO_SRST : 1'b0);
  
  // (Optional) registers on SP address and on optional data/we/qspo_ce signals
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           0, 0, 0, 0,
                           "0", 0, 0, 1)
                qspo1_reg (.D(qspo_ce_int), .CLK(CLK), .CE(1'b0), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
			  .Q(qspo_ce_reg1));
  
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           1, 0, 0, 0,
                           "0", 0, 0, (C_ADDR_WIDTH-(C_ADDR_WIDTH>4?(C_HAS_SPRA*4):0)))
                a_rega (.D(A[C_ADDR_WIDTH - 1-(C_ADDR_WIDTH>4?(4*C_HAS_SPRA):0) : 0]), .CLK(CLK), .CE(a_reg_ice), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
                          .Q(a_int1[C_ADDR_WIDTH - 1-(C_ADDR_WIDTH>4?(4*C_HAS_SPRA):0) : 0]));
  
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           1, 0, 0, 0,
                           "0", 0, 0, C_ADDR_WIDTH)
                spra_reg (.D(SPRA), .CLK(CLK), .CE(qspo_ce_int), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
                          .Q(spra_int1));
  
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           1, 0, 0, 0,
                           "0", 0, 0, 1)
                we_reg (.D(WE), .CLK(CLK), .CE(wece), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
                          .Q(we_int1));
  
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           0, 0, 0, 0,
                           "0", 0, 0, 1)
                re_reg (.D(RD_EN), .CLK(CLK),// .CE(qspo_ce_int),
                 .CE(1'b0), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
                          .Q(re_int1));                          
  
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           1, 0, 0, 0,
                           "0", 0, 0, C_WIDTH)
                	d_reg (.D(D), .CLK(CLK), .CE(ice), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
                           .Q(d_int1));                          
  
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           0, 0, 0, 0,
                           "0", 0, 0, C_WIDTH)
                	spo_reg1 (.D(spo_async), .CLK(CLK), .CE(1'b0), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
                           .Q(spo_reg_tmp));                          
  
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           0, 0, 0, 0,
                           "0", 0, 0, C_WIDTH)
                	dpo_reg1 (.D(dpo_async), .CLK(doclk), .CE(1'b0), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
                           .Q(dpo_reg_tmp));
						   
  // Deal with these optional registers
  assign qspo_ce_reg = (C_REG_A_D_INPUTS == 0 ? (C_HAS_QSPO_CE == 1 ? qspo_ce_int : 1'b1) : (C_HAS_QSPO_CE == 1 ? qspo_ce_reg1 : 1'b1));
  assign a_int = (C_REG_A_D_INPUTS == 0 ? (C_MEM_TYPE != `c_srl16 ? A : (C_ADDR_WIDTH>4 ? A[C_ADDR_WIDTH - 1 -(C_ADDR_WIDTH>4?(4*C_HAS_SPRA):0) : 0]<<4 : 0)) : 
  										  (C_MEM_TYPE != `c_srl16 ? a_int1 : (C_ADDR_WIDTH>4 ? a_int1[C_ADDR_WIDTH - 1 -(C_ADDR_WIDTH>4?(4*C_HAS_SPRA):0) : 0]<<4 : 0)));
  assign spra_int = (C_REG_A_D_INPUTS == 0 ? (C_MEM_TYPE != `c_srl16 ? A : SPRA) : 
                                          (C_MEM_TYPE != `c_srl16 ? a_int1 : spra_int1));
  assign we_int = (C_REG_A_D_INPUTS == 0 ? (C_HAS_WE == 1 ? WE : 1'b1) : (C_HAS_WE == 1 ? we_int1 : 1'b1));
  assign re_int = (C_REG_A_D_INPUTS == 0 ? (C_HAS_RD_EN == 1 ? RD_EN : 1'b1) : (C_HAS_RD_EN == 1 ? re_int1 : 1'b1));
  assign d_int = (C_REG_A_D_INPUTS == 0 ? (C_HAS_D == 1 ? D : `allXs) : (C_HAS_D == 1 ? d_int1 : `allXs));
  assign spo_reg = (pipe_stages == 1 ? spo_reg_tmp : spo_async);
  assign dpo_reg = (pipe_stages == 1 ? dpo_reg_tmp : dpo_async);
  
  // (Optional) DP Read Address and QDPO_CE registers
  
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           1, 0, 0, 0,
                           "0", 0, 0, C_ADDR_WIDTH)
                dpra_reg (.D(DPRA), .CLK(doclk), .CE(qdpo_ce_int), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
                          .Q(dpra_int1));
  
  C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, 0, 0, 0,
                           0, 0, 0, 0,
                           "0", 0, 0, 1)
                qdpo1_reg (.D(qdpo_ce_int), .CLK(doclk), .CE(1'b0), .ACLR(1'b0), .ASET(1'b0),
			  .AINIT(1'b0), .SCLR(1'b0), .SSET(1'b0), .SINIT(1'b0),
                          .Q(qdpo_ce_reg1));
  
  // Deal with these optional registers
  assign qdpo_ce_reg = (C_REG_DPRA_INPUT == 0 ? (C_HAS_QDPO_CE == 1 ? qdpo_ce_int : (C_QCE_JOINED == 1 ? qdpo_ce_int : 1'b1)) : 
  												(C_HAS_QDPO_CE == 1 ? qdpo_ce_reg1 : (C_QCE_JOINED == 1 || C_MEM_TYPE == `c_srl16 ? qdpo_ce_reg1 : 1'b1)));
  assign dpra_int = (C_REG_DPRA_INPUT == 0 ? (C_HAS_DPRA == 1 ? DPRA : `allXs) : (C_HAS_DPRA == 1 ? dpra_int1 : `allXs));

  // (Optional) pipeline registers

	always@(posedge CLK)
	begin
		if(CLK === 1'b1 && lastCLK === 1'b0 && qspo_ce_reg === 1'b1) // OK! Update pipelines!
		begin
			for(pipe = 2; pipe <= pipe_stages-1; pipe = pipe + 1)
			begin
				spo_pipe[pipe] <= spo_pipe[pipe+1];
			end
			spo_pipe[pipe_stages] <= spo_async;
		end
		else if((CLK === 1'bx && lastCLK === 1'b0) || (CLK === 1'b1 && lastCLK === 1'bx) || qspo_ce_reg === 1'bx) // POSSIBLY Update pipelines!
		begin
			for(pipe = 2; pipe <= pipe_stages-1; pipe = pipe + 1)
			begin
				tmp_pipe1 = spo_pipe[pipe];
				tmp_pipe2 = spo_pipe[pipe+1];
				for(pipe1 = 0; pipe1 < C_WIDTH; pipe1 = pipe1 + 1)
				begin
					if(tmp_pipe1[pipe1] !== tmp_pipe2[pipe1])
						tmp_pipe1[pipe1] = 1'bx;
				end
				spo_pipe[pipe] <= tmp_pipe1;
			end
			tmp_pipe1 = spo_pipe[pipe_stages];
			for(pipe1 = 0; pipe1 < C_WIDTH; pipe1 = pipe1 + 1)
			begin
				if(tmp_pipe1[pipe1] !== spo_async[pipe1])
					tmp_pipe1[pipe1] = 1'bx;
			end
			spo_pipe[pipe_stages] <= tmp_pipe1;
		end
	end
  
	always@(spo_async or spo_pipe[NCELAB_SPO_PIPE_CONSTANT])	//2
	begin
		if(pipe_stages < 2) // No pipeline
			spo_pipeend <= spo_async;
		else // Pipeline stages required
		begin
			spo_pipeend <= spo_pipe[NCELAB_SPO_PIPE_CONSTANT];	//2
		end
	end
       
	always@(posedge doclk)
	begin
		if(doclk === 1'b1 && lastdoclk === 1'b0 && qdpo_ce_reg === 1'b1) // OK! Update pipelines!
		begin
			for(pipe3 = 2; pipe3 <= dpo_pipe_stages-1; pipe3 = pipe3 + 1)
			begin
				dpo_pipe[pipe3] <= dpo_pipe[pipe3+1];
			end
			dpo_pipe[dpo_pipe_stages] <= dpo_async;
		end
		else if((doclk === 1'bx && lastdoclk === 1'b0) || (doclk === 1'b1 && lastdoclk === 1'bx) || qdpo_ce_reg === 1'bx) // POSSIBLY Update pipelines!
		begin
			for(pipe4 = 2; pipe4 <= dpo_pipe_stages-1; pipe4 = pipe4 + 1)
			begin
				tmp_pipe3 = dpo_pipe[pipe4];
				tmp_pipe2 = dpo_pipe[pipe4+1];
				for(pipe1 = 0; pipe1 < C_WIDTH; pipe1 = pipe1 + 1)
				begin
					if(tmp_pipe3[pipe1] !== tmp_pipe2[pipe1])
						tmp_pipe3[pipe1] = 1'bx;
				end
				dpo_pipe[pipe4] <= tmp_pipe3;
			end
			tmp_pipe3 = dpo_pipe[dpo_pipe_stages];
			for(pipe2 = 0; pipe2 < C_WIDTH; pipe2 = pipe2 + 1)
			begin
				if(tmp_pipe3[pipe2] !== dpo_async[pipe2])
					tmp_pipe3[pipe2] = 1'bx;
			end
			dpo_pipe[dpo_pipe_stages] <= tmp_pipe3;
		end
	end
  
	always@(dpo_async or dpo_pipe[NCELAB_DPO_PIPE_CONSTANT])	//2
	begin
		if(dpo_pipe_stages < 2) // No pipeline
			dpo_pipeend <= dpo_async;
		else // Pipeline stages required
		begin
			dpo_pipeend <= dpo_pipe[NCELAB_DPO_PIPE_CONSTANT];	//2
		end
	end

	// (Optional) output registers at end of optional pipelines
	
    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_QSPO_RST, 0, 0,
                           1, C_HAS_QSPO_SRST, 0, 0,
                           "0", C_SYNC_ENABLE, 0, C_WIDTH)
                qspo_reg (.D(spo_pipeend), .CLK(CLK), .CE(qspo_ce_reg), .ASET(1'b0),
			  .AINIT(1'b0), .SSET(1'b0), .SINIT(1'b0),
                          .ACLR(qspo_rst_int), .SCLR(qspo_srst_int), .Q(intQSPO));
  
    C_REG_FD_V7_0 #("0", C_ENABLE_RLOCS, C_HAS_QDPO_RST, 0, 0,
                           1, C_HAS_QDPO_SRST, 0, 0,
                           "0", C_SYNC_ENABLE, 0, C_WIDTH)
                qdpo_reg (.D(dpo_pipeend), .CLK(doclk), .CE(qdpo_ce_reg), .ASET(1'b0),
			  .AINIT(1'b0), .SSET(1'b0), .SINIT(1'b0),
                          .ACLR(qdpo_rst_int), .SCLR(qdpo_srst_int), .Q(intQDPO));
  
	
       
  // Startup behaviour  
  initial
  begin
    default_data = 'b0;
    case (radix)
       3 : default_data = decstr_conv(C_DEFAULT_DATA);
       2 : default_data = binstr_conv(C_DEFAULT_DATA);
       1 : default_data = hexstr_conv(C_DEFAULT_DATA);
      default : $display("ERROR in %m at %d ns: BAD DATA RADIX - valid range 1 to 3", $time);
    endcase

    for(i = 0; i < C_DEPTH; i = i + 1)
      ram_data[i] = default_data;
    
    if(C_READ_MIF == 1)
    begin
      $readmemb(C_MEM_INIT_FILE, ram_data, 0 , C_DEPTH-1);
    end
    if (C_GENERATE_MIF == 1)
      write_meminit_file;
	  
	spo_tmp = 'b0;
	dpo_tmp = 'b0;
	lastCLK = 1'b0;
	lastdoclk = 1'b0;
	
	spo_async = spo_tmp;
	dpo_async = dpo_tmp;
	
	for(i = 0; i < pipe_stages+3; i = i + 1)
	begin
		spo_pipe[i] = `all0s;
	end
	for(i = 0; i < dpo_pipe_stages+3; i = i + 1)
	begin
		dpo_pipe[i] = `all0s;
	end
	if(pipe_stages < 2) // No pipeline
	begin
		spo_pipeend = spo_async;
	end
	else
	begin
		spo_pipeend = spo_pipe[NCELAB_SPO_PIPE_CONSTANT];	//2
	end
    if(dpo_pipe_stages < 2) // No pipeline
	begin
		dpo_pipeend = dpo_async;
	end
	else
	begin
		dpo_pipeend = dpo_pipe[NCELAB_DPO_PIPE_CONSTANT];	//2
	end

    start <= 0;
  end
  
  always @(CLK)
  	lastCLK <= CLK;
	
  always @(doclk)
  	lastdoclk <= doclk;

  always @(posedge CLK or a_int or we_int or spra_int or dpra_int or d_int or re_int or spo_async or dpo_async or start)
  begin
  	if ($realtime != 0 || start == 0)	// gets around race condition at startup (CR 171445)
	                                    // added start to ensure that this process is still run at startup
										// but after all the intials have completed to fix CR 175826
	begin
  	if(((CLK === 1'b1 && lastCLK === 1'b0) || C_HAS_CLK == 0) && C_MEM_TYPE != `c_rom)
	begin
		if(ADDR_IS_X(a_int) || a_int < C_DEPTH)
		begin
			if(we_int === 1'bx)
			begin
				if(ADDR_IS_X(a_int))
				begin
					for(i = 0; i < C_DEPTH; i = i + 1) 
						ram_data[i] = `allXs;
  				end
				else 
				begin
					if(C_MEM_TYPE == `c_srl16)
					begin
						srl_start = (a_int/16)*16; // Ignore lower 4 bits of a_int
						srl_end = srl_start+16;
						if(srl_end > C_DEPTH)
							srl_end = C_DEPTH;
						for(i = srl_end-1; i > srl_start; i = i - 1)
						begin // Shift data through the SRL16s
							tmp_data1 = ram_data[i];
							tmp_data2 = ram_data[i-1];
							for(j = 0; j < C_WIDTH; j = j + 1)
							begin
								if(tmp_data1[j] !== tmp_data2[j])
									tmp_data1[j] = 1'bx;
							end
							ram_data[i] = tmp_data1;
						end
						tmp_data1 = ram_data[srl_start];
						for(j = 0; j < C_WIDTH; j = j + 1)
						begin
							if(tmp_data1[j] !== d_int[j])
								tmp_data1[j] = 1'bx;
						end
						ram_data[srl_start] = tmp_data1;
					end
					else
					begin
						tmp_data1 = ram_data[a_int];
						for(j = 0; j < C_WIDTH; j = j + 1)
						begin
							if(tmp_data1[j] !== d_int[j])
								tmp_data1[j] = 1'bx;
						end
						ram_data[a_int] = tmp_data1;
					end
				end
			end
			else if(we_int === 1'b1)
			begin
				if(ADDR_IS_X(a_int))
				begin
					for(i = 0; i < C_DEPTH; i = i + 1) 
						ram_data[i] = `allXs;
  				end
				else 
				begin
					if(C_MEM_TYPE == `c_srl16)
					begin
						srl_start = (a_int/16)*16; // Ignore lower 4 bits of a_int
						srl_end = srl_start+16;
						if(srl_end > C_DEPTH)
							srl_end = C_DEPTH;
						for(i = srl_end-1; i > srl_start; i = i - 1)
						begin // Shift data through the SRL16s
							ram_data[i] = ram_data[i-1];
						end
						ram_data[srl_start] = d_int;
					end
					else
					begin 			
                        //if (C_MEM_TYPE == `c_dp_ram && a_int == dpra_int && we_int == 1 && qspo_ce_int == 1)
                        //begin
                        //    $display("WARNING in %m at time %d ns: Memory Hazard: Reading and Writing to same dual port address!", $time);
                        //end
						ram_data[a_int] = d_int;
					end
				end
			end
		end
		else if(a_int >= C_DEPTH)
			$display("WARNING in %m at time %d ns: Writing to out-of-range address!! - max address is %d", $time, C_DEPTH);
	end
	else if((C_HAS_CLK == 0 || ((CLK === 1'bx && lastCLK === 1'b0) || CLK === 1'b1 && lastCLK === 1'bx)) && C_MEM_TYPE != `c_rom)
	begin
		if(ADDR_IS_X(a_int) || a_int < C_DEPTH)
		begin
			if(we_int === 1'bx)
			begin
				if(ADDR_IS_X(a_int))
				begin
					for(i = 0; i < C_DEPTH; i = i + 1) 
						ram_data[i] = `allXs;
  				end
				else 
				begin
					if(C_MEM_TYPE == `c_srl16)
					begin
						srl_start = (a_int/16)*16; // Ignore lower 4 bits of a_int
						srl_end = srl_start+16;
						if(srl_end > C_DEPTH)
							srl_end = C_DEPTH;
						for(i = srl_end-1; i > srl_start; i = i - 1)
						begin // Shift data through the SRL16s
							tmp_data1 = ram_data[i];
							tmp_data2 = ram_data[i-1];
							for(j = 0; j < C_WIDTH; j = j + 1)
							begin
								if(tmp_data1[j] !== tmp_data2[j])
									tmp_data1[j] = 1'bx;
							end
							ram_data[i] = tmp_data1;
						end
						tmp_data1 = ram_data[srl_start];
						for(j = 0; j < C_WIDTH; j = j + 1)
						begin
							if(tmp_data1[j] !== d_int[j])
								tmp_data1[j] = 1'bx;
						end
						ram_data[srl_start] = tmp_data1;
					end
					else
					begin
						tmp_data1 = ram_data[a_int];
						for(j = 0; j < C_WIDTH; j = j + 1)
						begin
							if(tmp_data1[j] !== d_int[j])
								tmp_data1[j] = 1'bx;
						end
						ram_data[a_int] = tmp_data1;
					end
				end
			end
			else if(we_int === 1'b1)
			begin
				if(ADDR_IS_X(a_int))
				begin
					for(i = 0; i < C_DEPTH; i = i + 1) 
						ram_data[i] = `allXs;
  				end
				else 
				begin
					if(C_MEM_TYPE == `c_srl16)
					begin
						srl_start = (a_int/16)*16; // Ignore lower 4 bits of a_int
						srl_end = srl_start+16;
						if(srl_end > C_DEPTH)
							srl_end = C_DEPTH;
						for(i = srl_end-1; i > srl_start; i = i - 1)
						begin // Shift data through the SRL16s
							tmp_data1 = ram_data[i];
							tmp_data2 = ram_data[i-1];
							for(j = 0; j < C_WIDTH; j = j + 1)
							begin
								if(tmp_data1[j] !== tmp_data2[j])
									tmp_data1[j] = 1'bx;
							end
							ram_data[i] = tmp_data1;
						end
						tmp_data1 = ram_data[srl_start];
						for(j = 0; j < C_WIDTH; j = j + 1)
						begin
							if(tmp_data1[j] !== d_int[j])
								tmp_data1[j] = 1'bx;
						end
						ram_data[srl_start] = tmp_data1;
					end
					else
					begin 			
                        //if (C_MEM_TYPE == `c_dp_ram && a_int == dpra_int && we_int == 1 && qspo_ce_int == 1)
                        //begin
                        //    $display("WARNING in %m at time %d ns: Memory Hazard: Reading and Writing to same dual port address!", $time);
                        //end
						tmp_data1 = ram_data[a_int];
						for(j = 0; j < C_WIDTH; j = j + 1)
						begin
							if(tmp_data1[j] !== d_int[j])
								tmp_data1[j] = 1'bx;
						end
						ram_data[a_int] = tmp_data1;
					end
				end
			end
		end
		else if(a_int >= C_DEPTH)
			$display("WARNING in %m at time %d ns: Writing to out-of-range address!! - max address is %d", $time, C_DEPTH);
	end
	
  // Read behaviour
	
  	if(re_int === 1'bx)
	begin
		spo_tmp = `allXs;
		dpo_tmp = `allXs;
	end
	else if(re_int === 1'b1)
	begin
		if(ADDR_IS_X(spra_int))
			spo_tmp = `allXs;
		else
		begin
			if(spra_int < C_DEPTH)
				spo_tmp = ram_data[spra_int];
			else if(C_MUX_TYPE == `c_buft_based)
			begin
				$display("WARNING in %m at time %d ns: Reading from out-of-range address!! - max address is %d", $time, C_DEPTH);
			 	spo_tmp = `allZs;
			end
			else
			begin
				$display("WARNING in %m at time %d ns: Reading from out-of-range address!! - max address is %d", $time, C_DEPTH);
				spo_tmp = `all0s;
			end
		end
		
		if(ADDR_IS_X(dpra_int))
			dpo_tmp = `allXs;
		else
		begin
			if(dpra_int < C_DEPTH)
				dpo_tmp = ram_data[dpra_int];
			else if(C_MUX_TYPE == `c_buft_based)
			begin
				$display("WARNING in %m at time %d ns: Reading from out-of-range address!! - max address is %d", $time, C_DEPTH);
			 	dpo_tmp = `allZs;
			end
			else
			begin
				$display("WARNING in %m at time %d ns: Reading from out-of-range address!! - max address is %d", $time, C_DEPTH);
				dpo_tmp = `all0s;
			end
		end
	end
	else // re_int == 0
	begin
		spo_tmp = `all1s;
		dpo_tmp = `all1s;
	end
	
	spo_async <= spo_tmp;
	dpo_async <= dpo_tmp;  
	end
	
  end
  

  function [C_WIDTH-1:0] binstr_conv;
    input [(C_WIDTH*8)-1:0] def_data;

    integer index,i;

    begin
      index = 0;
      binstr_conv = 'b0;

      for( i=C_WIDTH-1; i>=0; i=i-1 )
      begin
        case (def_data[7:0])
          8'b00000000 : i = -1;
          8'b00110000 : binstr_conv[index] = 1'b0;
          8'b00110001 : binstr_conv[index] = 1'b1;
          default :
          begin
            $display("ERROR in %m at time %d ns: NOT A BINARY CHARACTER", $time);
            binstr_conv[index] = 1'bx;
          end
        endcase
        index = index + 1;
        def_data = def_data >> 8;
      end
    end
  endfunction

  function [C_WIDTH-1:0] hexstr_conv;
    input [(C_WIDTH*8)-1:0] def_data;

    integer index,i,j;
    reg [3:0] bin;

    begin
      index = 0;
      hexstr_conv = 'b0;
      for( i=C_WIDTH-1; i>=0; i=i-1 )
      begin
        case (def_data[7:0])
          8'b00000000 :
          begin
            bin = 4'b0000;
            i = -1;
          end
          8'b00110000 : bin = 4'b0000;
          8'b00110001 : bin = 4'b0001;
          8'b00110010 : bin = 4'b0010;
          8'b00110011 : bin = 4'b0011;
          8'b00110100 : bin = 4'b0100;
          8'b00110101 : bin = 4'b0101;
          8'b00110110 : bin = 4'b0110;
          8'b00110111 : bin = 4'b0111;
          8'b00111000 : bin = 4'b1000;
          8'b00111001 : bin = 4'b1001;
          8'b01000001 : bin = 4'b1010;
          8'b01000010 : bin = 4'b1011;
          8'b01000011 : bin = 4'b1100;
          8'b01000100 : bin = 4'b1101;
          8'b01000101 : bin = 4'b1110;
          8'b01000110 : bin = 4'b1111;
          8'b01100001 : bin = 4'b1010;
          8'b01100010 : bin = 4'b1011;
          8'b01100011 : bin = 4'b1100;
          8'b01100100 : bin = 4'b1101;
          8'b01100101 : bin = 4'b1110;
          8'b01100110 : bin = 4'b1111;
          default :
          begin
            $display("ERROR in %m at time %d ns: NOT A HEX CHARACTER", $time);
            bin = 4'bx;
          end
        endcase
        for( j=0; j<4; j=j+1)
        begin
          if ((index*4)+j < C_WIDTH)
          begin
            hexstr_conv[(index*4)+j] = bin[j];
          end
        end
        index = index + 1;
        def_data = def_data >> 8;
      end
    end
  endfunction

  function [C_WIDTH-1:0] decstr_conv;
    input [(C_WIDTH*8)-1:0] def_data;

    integer index,i,j,ten;
    reg [3:0] bin;
	reg [C_WIDTH-1:0] temp, result;

    begin
      index = 0;
      decstr_conv = 'b0;
	  result = 'b0;
      for( i=0; i<C_WIDTH; i=i+1 )
      begin
        case (def_data[7:0])
          8'b00000000 :
          begin
            bin = 4'b0000;
            i = C_WIDTH;
          end
          8'b00110000 : bin = 4'b0000;
          8'b00110001 : bin = 4'b0001;
          8'b00110010 : bin = 4'b0010;
          8'b00110011 : bin = 4'b0011;
          8'b00110100 : bin = 4'b0100;
          8'b00110101 : bin = 4'b0101;
          8'b00110110 : bin = 4'b0110;
          8'b00110111 : bin = 4'b0111;
          8'b00111000 : bin = 4'b1000;
          8'b00111001 : bin = 4'b1001;
          8'b01000001 : bin = 4'b1010;
          8'b01000010 : bin = 4'b1011;
          8'b01000011 : bin = 4'b1100;
          8'b01000100 : bin = 4'b1101;
          8'b01000101 : bin = 4'b1110;
          8'b01000110 : bin = 4'b1111;
          default :
          begin
            $display("ERROR in %m at time %d ns: NOT A DECIMAL CHARACTER", $time);
            bin = 4'bx;
          end
        endcase
        ten = 1;
		for (j= 0; j< index; j=j+1)
			ten = 10*ten;
		temp = bin * ten;
		result = result + temp;
		decstr_conv = result;
        index = index + 1;
        def_data = def_data >> 8;
      end
    end
  endfunction
  
  task write_meminit_file;
  
    integer addrs, outfile, bit_index;
    
    reg [C_WIDTH-1 : 0] conts;
    reg anyX;
    
    begin
      outfile = $fopen(C_MEM_INIT_FILE);
      for( addrs = 0; addrs < C_DEPTH; addrs=addrs+1)
      begin
        anyX = 1'b0;
        conts = ram_data[addrs];
        for(bit_index = 0; bit_index < C_WIDTH; bit_index=bit_index+1)
          if(conts[bit_index] === 1'bx) anyX = 1'b1;
        if(anyX == 1'b1)  
          $display("ERROR in %m at time %d ns: MEMORY CONTAINS UNKNOWNS", $time);
        $fdisplay(outfile,"%b",ram_data[addrs]);
      end
      $fclose(outfile);
    end
  endtask

endmodule

`undef all0s
`undef all1s
`undef allXs
`undef allZs
`undef addrallXs

`undef c_rom
`undef c_sp_ram
`undef c_dp_ram
`undef c_srl16

`undef c_lut_based
`undef c_buft_based

