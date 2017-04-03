// Copyright(C) 2004-2006 by Xilinx, Inc. All rights reserved. 
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
// of this text at all times. (c) Copyright 1995-2006 Xilinx, Inc. 
// All rights reserved.



/* $RCSfile: DIST_MEM_GEN_V3_1.v,v $ $Revision: 1.8 $ $Date: 2008/09/08 19:37:01 $
--
-- Filename - DIST_MEM_GEN_V3_1.v
-- Author - Xilinx
-- Creation - 27 Nov 2004
--
-- Description
--  Distributed Memory Simulation Model
*/


`timescale 1ps/1ps

`define all0s {C_WIDTH{1'b0}}
`define allXs {C_WIDTH{1'bx}}
`define c_rom 0
`define c_sp_ram 1
`define c_dp_ram 2
`define c_srl16 3

module DIST_MEM_GEN_V3_1 (A, D, DPRA, SPRA, CLK, WE, I_CE, QSPO_CE, QDPO_CE, QDPO_CLK, QSPO_RST, QDPO_RST, QSPO_SRST, QDPO_SRST, SPO, DPO, QSPO, QDPO);

   parameter C_ADDR_WIDTH         = 6;
   parameter C_DEFAULT_DATA       = "0";
   parameter C_DEPTH              = 64;
   parameter C_HAS_CLK            = 1;
   parameter C_HAS_D              = 1;
   parameter C_HAS_DPO            = 0;
   parameter C_HAS_DPRA           = 0;
   parameter C_HAS_I_CE           = 0;
   parameter C_HAS_QDPO           = 0;
   parameter C_HAS_QDPO_CE        = 0;
   parameter C_HAS_QDPO_CLK       = 0;
   parameter C_HAS_QDPO_RST       = 0;
   parameter C_HAS_QDPO_SRST      = 0;
   parameter C_HAS_QSPO           = 0;
   parameter C_HAS_QSPO_CE        = 0;
   parameter C_HAS_QSPO_RST       = 0;
   parameter C_HAS_QSPO_SRST      = 0;
   parameter C_HAS_SPO            = 1;
   parameter C_HAS_SPRA           = 0;
   parameter C_HAS_WE             = 1;
   parameter C_MEM_INIT_FILE      = "null.mif";
   parameter C_MEM_TYPE           = 1;
   parameter C_QCE_JOINED         = 0;
   parameter C_QUALIFY_WE         = 0;
   parameter C_READ_MIF           = 0;
   parameter C_REG_A_D_INPUTS     = 0;
   parameter C_REG_DPRA_INPUT     = 0;
   parameter C_SYNC_ENABLE        = 0;
   parameter C_WIDTH              = 16;

     
   input  [C_ADDR_WIDTH-1 - (C_ADDR_WIDTH>4?(4*C_HAS_SPRA):0) : 0] A;
   input  [C_WIDTH-1 : 0] D;
   input  [C_ADDR_WIDTH-1 : 0] DPRA;
   input  [C_ADDR_WIDTH-1 : 0] SPRA;
   input  CLK;
   input  WE;
   input  I_CE;
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
   
   // Read Address connected to srl16 memory
   wire [C_ADDR_WIDTH - 1 : 0] spra_int;

   // Input data signal connected to memory
   wire [C_WIDTH - 1 : 0] d_int;

   // Internal Write Enable
   wire 		       we_int;

   // Internal QSPO Clock Enable
   wire 		       qspo_ce_int;

   // Internal QDPO Clock
   wire 		       qdpo_clk_int;

   // Internal Dual Port Read Address connected to memory
   wire [C_ADDR_WIDTH - 1 : 0] dpra_int;

   // Internal QDPO Clock Enable
   wire 		       qdpo_ce_int;

   // Registered Write Enable
   reg 			       we_reg;

   // Registered Address connected to memory
   reg [C_ADDR_WIDTH - 1 : 0]  a_reg;

   // Registered Read Address connected to srl16 memory
   reg [C_ADDR_WIDTH - 1 : 0]  spra_reg;

   // Registered data signal connected to memory
   reg [C_WIDTH-1 : 0] 	       d_reg;

   // Registered QSPO Clock Enable
   reg 			       qspo_ce_reg;

   // Registered Dual Port Read Address connected to memory
   reg [C_ADDR_WIDTH - 1 : 0]  dpra_reg;

   // Registered QDPO Clock Enable
   reg 			       qdpo_ce_reg;

   // Internal Single Port RAM output signal
   wire [C_WIDTH - 1 : 0]       spo_int;

   // Internal Dual Port RAM output signal
   wire [C_WIDTH - 1 : 0]       dpo_int;

   // Internal ROM/Single Port RAM/SRL16 RAM
   //  registered output
   reg [C_WIDTH - 1 : 0]       qspo_int;

   // Internal Dual Port RAM registered output
   reg [C_WIDTH - 1 : 0]       qdpo_int;
   
   reg [C_WIDTH-1 : 0] 	       ram_data [(2**C_ADDR_WIDTH)-1 : 0];
   reg [C_WIDTH-1 : 0] 	       ram_data_tmp[C_DEPTH-1 : 0];
   
  
   reg [C_WIDTH-1 : 0] 	       default_data;
   
   wire [C_WIDTH-1 : 0]        data_sp;  
   wire [C_WIDTH-1 : 0]        data_dp;
   wire [C_WIDTH-1 : 0]        data_srl;

   wire [C_WIDTH-1 : 0]        data_sp_over;  
   wire [C_WIDTH-1 : 0]        data_dp_over;
   wire [C_WIDTH-1 : 0]        data_srl_over;

   wire [C_ADDR_WIDTH - 1 : 0] a_over;
   wire [C_ADDR_WIDTH - 1 : 0] dpra_over;   
   wire [C_ADDR_WIDTH - 1 : 0] spra_over;

   wire 		       a_is_over;
   wire 		       dpra_is_over;
   wire 		       spra_is_over;
   
   reg [C_ADDR_WIDTH-1 : 0]    max_address;
   
   integer 		       i;
   integer 		       j;   
   integer 		       srl_start;
   integer 		       srl_end;

            
   // Initial block - initialise the memory,
   // and when appropriate write content into the given address.
   initial
     begin
	$display("WARNING: This core is supplied with a behavioral model. To model cycle-accurate behavior you must run timing simulation.");
	

	default_data = 'b0;
	default_data = binstr_conv(C_DEFAULT_DATA);       	
	
        // Assign that C_DEFAULT_DATA to each address in the memory.
        for (i = 0; i < C_DEPTH; i = i + 1)
	  begin
	     ram_data[i] = default_data;
	     ram_data_tmp[i] = default_data;
	  end	      

        //Read the MIF file, and use it to initialise the content of ram_data
        //if that is required.
        if (C_READ_MIF)
	  begin
	     $readmemb(C_MEM_INIT_FILE, ram_data_tmp, 0, C_DEPTH-1);
    
	     for (i = 0; i < C_DEPTH; i = i + 1)    
		  ram_data[i] = ram_data_tmp[i];

	  end
	
	if (C_DEPTH != (2**C_ADDR_WIDTH))
          begin
	     for (i = C_DEPTH; i < (2**C_ADDR_WIDTH); i = i + 1)
	       ram_data[i] = 'b0;	     
	  end

	a_reg       = 'b0;
	we_reg      = 1'b0;
	spra_reg    = 'b0;
	d_reg       = 'b0;
	qspo_ce_reg = 1'b0;
	dpra_reg    = 'b0;
	qdpo_ce_reg = 1'b0;

        qspo_int = default_data;
        qdpo_int = default_data;

        max_address = C_DEPTH-1;

        srl_start = 0;
	srl_end = 15;        
	
     end // initial begin  
   
   // Now look for writes to the memory (note that this means the
   // memory is not a ROM and that the Write Enable WE is active.
   always@(posedge CLK)
     begin
	if (C_MEM_TYPE != `c_rom && we_int)
	  begin
             if (C_MEM_TYPE == `c_srl16)
	       begin
		  if (C_ADDR_WIDTH > 4)
		    begin
		       srl_start = a_int * 16;
		       if (srl_start + 16 > C_DEPTH)
			 srl_end = C_DEPTH - 1;
		       else
			 srl_end = (a_int*16) + 15;
		    end
		  else
		    begin
		       srl_start = 0;
		       srl_end = 15;
		    end  
		  		  
		  for (i = srl_end; i > srl_start; i = i - 1)
		    ram_data[i] <= #100 ram_data[i-1];
	  
		  ram_data[srl_start] <= #100 d_int;
	       end
	     else if (a_is_over)
	       begin
		  $display("WARNING in %m at time %d ns", $time);
		  $write("Writing to out of range address. ");
		  $display("Max address in %m is %d", C_DEPTH-1);
		  $display("Write will be ignored.");
	       end
	     else
	       ram_data[a_int] <= #100 d_int;
	  end // if (C_MEM_TYPE != `c_rom && we_int)
     end // always@ (posedge CLK)
   	 
   // Model optional input registers, which operate in the CLK clock domain.
   always @(posedge CLK)
     begin
	if (!C_HAS_I_CE)
	  begin
	     we_reg <= #100 WE;
    	     a_reg  <= #100 A;
	     spra_reg <= #100 SPRA;
	     d_reg <= #100 D;
	  end
	else if (!C_QUALIFY_WE)
	  begin
	     we_reg <= #100 WE;
	     if (I_CE)
	       begin
		  a_reg <= #100 A;
		  spra_reg <= #100 SPRA;
		  d_reg <= #100 D;
	       end
	  end
	else if (C_QUALIFY_WE)
	  if (I_CE)
	    begin
	       we_reg <= #100 WE;
	       a_reg <= #100 A;
	       spra_reg <= #100 SPRA;
	       d_reg <= #100 D;
	    end

	qspo_ce_reg <= #100 QSPO_CE;
     end // always @ (posedge CLK)
   
      
   assign we_int      = (C_HAS_WE ? (C_REG_A_D_INPUTS ? we_reg : WE) : 1'b0);
   assign d_int       = (C_MEM_TYPE > 0 ? (C_REG_A_D_INPUTS ? d_reg : D) : 'b0);   
   assign a_int       = (C_REG_A_D_INPUTS ? a_reg : A);
   
   assign spra_int    = (C_MEM_TYPE == `c_srl16 ? (C_REG_A_D_INPUTS ? spra_reg : SPRA) : 'b0);   
   assign qspo_ce_int = (C_HAS_QSPO_CE ? (C_REG_A_D_INPUTS ? qspo_ce_reg : QSPO_CE) : 1'b0);   

   assign qdpo_clk_int = (C_MEM_TYPE == `c_dp_ram ? 
      (C_HAS_QDPO_CLK == 1 ? QDPO_CLK : CLK) : 1'b0);   
   
   always@(posedge qdpo_clk_int)
     begin
        if (C_QCE_JOINED)
	  begin
	     if (!C_HAS_QSPO_CE)
	       dpra_reg <= #100 DPRA;
	     else if (QSPO_CE)
	       dpra_reg <= #100 DPRA;
	  end
	else
	  begin
	     if (!C_HAS_QDPO_CE)
	       dpra_reg <= #100 DPRA;
	     else if (QDPO_CE)
	       dpra_reg <= #100 DPRA;
	  end // else: !if(C_QCE_JOINED)

	qdpo_ce_reg <= #100 QDPO_CE;

     end // always@ (posedge qdpo_clk_int)

   assign dpra_int    = (C_MEM_TYPE == `c_dp_ram ? 
      (C_REG_DPRA_INPUT == 1 ? dpra_reg : DPRA) : 1'b0);
     
   assign qdpo_ce_int = (C_MEM_TYPE == `c_dp_ram ? 
     (C_HAS_QDPO_CE ? (C_REG_DPRA_INPUT ? qdpo_ce_reg : QDPO_CE) : 1'b0) : 1'b0);
   
   always@(spra_is_over)
     begin
	if (C_MEM_TYPE == `c_srl16)
	  begin
	     $display("WARNING in %m at time %d ns: ", $time);
	     $write("Reading from out-of-range address. ");
	     $display("Max address in %m is %d", C_DEPTH-1);
	  end // if (C_MEM_TYPE == `c_srl16)
     end // always@ (spra_int or CLK)
  
   always@(a_is_over)
     begin
	if (C_MEM_TYPE != `c_srl16)
	  begin
	     $display("WARNING in %m at time %d ns: ", $time);
	     $write("Reading from out-of-range address. ");
	     $display("Max address in %m is %d", C_DEPTH-1);
	  end // if (C_MEM_TYPE != `c_srl16)
     end // always@ (a_int or posedge CLK)
   
   assign SPO = (C_HAS_SPO ? spo_int : `allXs);

   always@(dpra_is_over)
     begin
	if (C_MEM_TYPE == `c_dp_ram)
	  begin
	     $display("WARNING in %m at time %d ns: ", $time);
	     $write("Reading from out-of-range address. ");
	     $display("Max address in %m is %d", C_DEPTH-1);
	  end // if (C_MEM_TYPE == `c_dp_ram)
     end // always@ (dpra_int)

   assign spo_int = (C_MEM_TYPE == `c_srl16 ? (spra_is_over ? data_srl_over : data_srl) : 
                    (a_is_over ? data_sp_over : data_sp));
   
   assign dpo_int = (C_MEM_TYPE == `c_dp_ram ? (dpra_is_over ? data_dp_over : data_dp) : `allXs);	

   assign data_sp  = ram_data[a_int];
   assign data_dp  = ram_data[dpra_int];
   assign data_srl = ram_data[spra_int];

   assign a_is_over    = (a_int > max_address ? 1'b1 : 1'b0);
   assign dpra_is_over = (dpra_int > max_address ? 1'b1 : 1'b0);
   assign spra_is_over = (spra_int > max_address ? 1'b1 : 1'b0);   

   assign a_over    = a_int & max_address;
   assign dpra_over = dpra_int & max_address;
   assign spra_over = spra_int & max_address;

   assign data_sp_over = 'bx;
   assign data_dp_over = 'bx;
   assign data_srl_over = 'bx;   
      
   assign DPO = (C_HAS_DPO ? dpo_int : `allXs);

   always@(posedge CLK or posedge QSPO_RST)
     begin
	if (C_HAS_QSPO_RST && QSPO_RST)
	  qspo_int <= 'b0;
	
	else if (C_HAS_QSPO_SRST && QSPO_SRST)
	  begin
	     if (!C_HAS_QSPO_CE)
	       qspo_int <= #100 'b0;
	     
	     else if (!C_SYNC_ENABLE)
	       qspo_int <= #100 'b0;

	     else if (C_HAS_QSPO_CE && qspo_ce_int)
	       qspo_int <= #100 'b0;
	  end // if (C_HAS_QSPO_SRST && QSPO_SRST)

	else if (C_HAS_QSPO_CE && qspo_ce_int)
	  qspo_int <= #100 spo_int;

	else if (!C_HAS_QSPO_CE)
	  qspo_int <= #100 spo_int;
	
     end // always@ (posedge CLK or QSPO_RST)

   assign QSPO = (C_HAS_QSPO == 1 ? qspo_int : `allXs);   

   always@(posedge qdpo_clk_int or posedge QDPO_RST)
     begin
	if (C_HAS_QDPO_RST && QDPO_RST)
	  qdpo_int <= 'b0;

	else if (C_HAS_QDPO_SRST && QDPO_SRST)
	  begin
	     if (!C_SYNC_ENABLE)
	       qdpo_int <= #100 'b0;
	     
	     else if (!C_QCE_JOINED)
	       begin
		  if (!C_HAS_QDPO_CE)
		    qdpo_int <= #100 'b0;
		  
		  else if (C_HAS_QDPO_CE && qdpo_ce_int)
		    qdpo_int <= #100 'b0;
		  
	       end	     
	     else
	       begin
		  if (!C_HAS_QSPO_CE)
		    qdpo_int <= #100 'b0;
		  
		  else if (C_HAS_QSPO_CE && qspo_ce_int)
		    qdpo_int <= #100 'b0;
	  
	       end
	     
	  end // if (C_HAS_QDPO_SRST && QDPO_SRST)
	
	else if (!C_QCE_JOINED)
	  begin
	     if (!C_HAS_QDPO_CE)
	       qdpo_int <= #100 dpo_int;
	     
	     else if (C_HAS_QDPO_CE && qdpo_ce_int)
	       qdpo_int <= #100 dpo_int;	     
	  end

	else if (C_QCE_JOINED)
	  begin
	     if (C_HAS_QSPO_CE && qspo_ce_int)
	       qdpo_int <= #100 dpo_int;

	     else if (!C_HAS_QSPO_CE)
	       qdpo_int <= #100 dpo_int;
	  end
	
     end // always@ (qdpo_clk_int or QDPO_RST)

   assign QDPO = (C_HAS_QDPO == 1 ? qdpo_int : `allXs);

   function [C_WIDTH - 1 : 0] binstr_conv;
      input [(C_WIDTH * 8) - 1 : 0] def_data;
      integer index,i;
      begin
	 index = 0;
	 binstr_conv = 'b0;	 
	 
         for (i=C_WIDTH-1; i>=0; i=i-1)
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
	      endcase // case(def_data[7:0])

	      index = index + 1;
	      def_data = def_data >> 8;
	   end // for (i=C_WIDTH-1; i>=0; i=i-1)	 
	 
      end
   endfunction // binstr_conv      

endmodule // DIST_MEM_GEN_V1_1

`undef all0s
`undef allXs
`undef c_rom
`undef c_sp_ram
`undef c_dp_ram
`undef c_srl16
