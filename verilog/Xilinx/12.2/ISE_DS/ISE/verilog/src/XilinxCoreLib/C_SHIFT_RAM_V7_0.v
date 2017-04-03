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


/* $Revision: 1.13 $ $Date: 2008/09/08 20:06:14 $
--
-- Filename - C_SHIFT_RAM_V7_0.v
-- Author - Xilinx
-- Creation - 24 Mar 1999
--
-- Description
--  RAM based Shift Register Simulation Model
*/

`timescale 1ns/10ps

module C_SHIFT_RAM_V7_0 (A, D, CLK, CE, ACLR, ASET, AINIT, SCLR, SSET, SINIT, Q); 
    
	parameter C_ADDR_WIDTH    = 4;
	parameter C_AINIT_VAL     = "";
	parameter C_DEFAULT_DATA  = "0";
   parameter C_DEFAULT_DATA_RADIX = 1;
   parameter C_DEPTH         = 16;
	parameter C_ENABLE_RLOCS  = 1;
	parameter C_GENERATE_MIF  = 0;   // Unused by the behavioural model
   parameter C_HAS_A         = 0;
	parameter C_HAS_ACLR      = 0;
	parameter C_HAS_AINIT     = 0;
	parameter C_HAS_ASET      = 0;
	parameter C_HAS_CE        = 0;
	parameter C_HAS_SCLR      = 0;
	parameter C_HAS_SINIT     = 0;
	parameter C_HAS_SSET      = 0;
	parameter C_MEM_INIT_FILE = "null.mif";
	parameter C_MEM_INIT_RADIX = 1; // for backwards compatibility
   parameter C_READ_MIF      = 0;
   parameter C_REG_LAST_BIT  = 0;
	parameter C_SHIFT_TYPE    = 0; // c_fixed
	parameter C_SINIT_VAL     = "";
	parameter C_SYNC_ENABLE   = 0; // c_override
	parameter C_SYNC_PRIORITY = 1; // c_clear
   parameter C_WIDTH         = 16;

   parameter C_DEPTH_TEMP = (C_SHIFT_TYPE == 0 ? ((C_DEPTH-1/17)+1)*17 : ((C_DEPTH-1/16)+1)*16); // to enable vsim to work
   parameter radix = (C_DEFAULT_DATA_RADIX == 1 ? C_MEM_INIT_RADIX : C_DEFAULT_DATA_RADIX);

    input  [C_WIDTH-1 : 0] D;
    input  [C_ADDR_WIDTH-1 : 0] A;
    input  CLK;
    input  CE;
    input  ACLR;
    input  ASET;
    input  AINIT;
    input  SCLR;
    input  SSET;
    input  SINIT;
    output [C_WIDTH-1 : 0] Q;
   
	wire [C_WIDTH-1 : 0] shift_out;
	wire [C_WIDTH-1 : 0] shift_out_1;
	wire [C_WIDTH-1 : 0] shift_out_2;
	wire [C_WIDTH-1 : 0] reg_out;
	// Internal values to drive signals when input is missing
	wire [C_WIDTH-1 : 0] intQ;
	wire [C_WIDTH-1 : 0] #1 Q = intQ;
	wire intCE;
    
	reg lastCLK;
	wire [C_WIDTH-1 : 0] feedin;
   wire [C_ADDR_WIDTH-1 : 0] addtop;
   wire [3 : 0] addlow;
   wire [C_ADDR_WIDTH-1 : 0] intA;
	
	integer i;
	integer rdeep;
	
   reg [C_WIDTH-1 : 0] default_data;
	reg [C_WIDTH-1 : 0] ram_data [0 : C_DEPTH_TEMP];
//	reg [C_WIDTH-1 : 0] shifter [0 : ((C_SHIFT_TYPE === 0 || C_DEPTH%16 == 0)?C_DEPTH:C_DEPTH_TEMP)];
   reg [C_WIDTH-1 : 0] shifter [0 : C_DEPTH_TEMP];
   
    
   function integer ADDR_IS_X;
      input [C_ADDR_WIDTH-1 : 0] value;
      integer i;
   begin
      ADDR_IS_X = 0;
      for(i = 0; i < C_ADDR_WIDTH; i = i + 1)
         if(value[i] === 1'bX)
            ADDR_IS_X = 1;
   end
   endfunction

   // Sort out default values for missing ports    
   assign intQ  = (C_REG_LAST_BIT === 1)?reg_out:shift_out;
	assign intCE = defval(CE, C_HAS_CE, 1);
	assign intA  = (C_HAS_A ? A : C_DEPTH-1);
	assign addtop      = (C_ADDR_WIDTH > 4 ? intA[C_ADDR_WIDTH-1 : (C_ADDR_WIDTH>4?4:0)] : 0);

   // modified from intA[3:0]
 	assign addlow      = intA[(C_ADDR_WIDTH>3?3:(C_ADDR_WIDTH-1)) : 0];	

	// MODIFIED FINAL EXPRESSION FROM 0 FOR ILLEGAL ADDRESSING
   //assign shift_out_1 = (ADDR_IS_X(intA) ? {C_WIDTH{1'bx}} : (intA < rdeep ? shifter[intA] : 1'bx));
   assign shift_out_1 = (ADDR_IS_X(intA) ? {C_WIDTH{1'bx}} : (intA < rdeep+1 ? shifter[intA+1] : 1'bx));
	//assign shift_out_2 = (ADDR_IS_X(addlow) ? {C_WIDTH{1'bx}} : shifter[rdeep-16+addlow]);
   assign shift_out_2 = (ADDR_IS_X(addlow) ? {C_WIDTH{1'bx}} : shifter[rdeep-15+addlow]);

	assign shift_out = ((C_DEPTH == 1 && C_REG_LAST_BIT) ? D :      // modified from D[0]
//                       C_SHIFT_TYPE == 0 ? shifter[C_DEPTH-C_REG_LAST_BIT-1] : 
	                     C_SHIFT_TYPE == 0 ? shifter[C_DEPTH-C_REG_LAST_BIT] : 
 					        (C_SHIFT_TYPE == 1 ? shift_out_1 : shift_out_2));

   // MODIFIED FINAL EXPRESSION FROM 0 FOR ILLEGAL ADDRESSING
   assign feedin = (ADDR_IS_X(addtop) ? {C_WIDTH{1'bx}} : 
                   (addtop === 0 ? D : 
//                   (addtop < rdeep/16 ? shifter[(addtop*16)-1] :
                   (addtop < rdeep/16 ? shifter[(addtop*16)] :
                   {C_WIDTH{1'bx}})));
	   
	// Register on output by default
	C_REG_FD_V7_0 #(C_AINIT_VAL, C_ENABLE_RLOCS, C_HAS_ACLR, C_HAS_AINIT, C_HAS_ASET,
                   C_HAS_CE, C_HAS_SCLR, C_HAS_SINIT, C_HAS_SSET,
                   C_SINIT_VAL, C_SYNC_ENABLE, C_SYNC_PRIORITY, C_WIDTH)
       final_reg (.D(shift_out), .CLK(CLK), .CE(CE), .ACLR(ACLR), .ASET(ASET),
                  .AINIT(AINIT), .SCLR(SCLR), .SSET(SSET), .SINIT(SINIT),
                  .Q(reg_out)); 
   
    initial
    begin
	    #1;
       rdeep = (C_SHIFT_TYPE === 0 || C_DEPTH%16 == 0)?C_DEPTH:((C_DEPTH/16)+1)*16;
       //for(i = 0; i < rdeep; i = i + 1)
       for(i = 1; i < rdeep + 1; i = i + 1)
         shifter[i] = {C_WIDTH{1'b0}};
         
       default_data = 'b0;
    case (radix)
       3 : default_data = decstr_conv(C_DEFAULT_DATA);
       2 : default_data = binstr_conv(C_DEFAULT_DATA);
       1 : default_data = hexstr_conv(C_DEFAULT_DATA);
      default : $display("ERROR in %m at time %d ns : BAD DATA RADIX", $time);
    endcase

    for(i = 0; i < C_DEPTH_TEMP; i = i + 1)
      ram_data[i] = default_data;
    
    if(C_READ_MIF == 1)
    begin
      $readmemb(C_MEM_INIT_FILE, ram_data, 0, C_DEPTH_TEMP-1);
    end

/*    if(C_READ_MIF == 1 && C_SHIFT_TYPE == 0)
    begin
      $readmemb(C_MEM_INIT_FILE, ram_data, 0, C_DEPTH_TEMP2 - 1);
    end */
       
    if (C_GENERATE_MIF == 1)
      write_meminit_file;
	
    for(i = 0; i < C_DEPTH; i = i + 1)
      //shifter[i] = ram_data[i];
       shifter[i+1] = ram_data[i];       
    end
	
    always@(posedge CLK or intA)
    begin
      if(CLK !== lastCLK && (intCE === 1'b1 && CLK !== 1'bx && lastCLK !== 1'bx))
      begin
        if(C_SHIFT_TYPE === 2)
		  begin
           //for(i = rdeep-1; i > rdeep-16; i = i - 1)
           for(i=rdeep; i > rdeep-15; i = i - 1)
              shifter[i] <= shifter[i-1];

           //shifter[rdeep-16] <= feedin;
           shifter[rdeep-15] <= feedin;
         

           //for(i = rdeep-17; i > 0; i = i - 1)
           for(i = rdeep-16; i > 1; i = i - 1)
              shifter[i] <= shifter[i-1];
        end
		  else 
	        //for(i = rdeep-1; i > 0; i = i - 1)
           for(i = rdeep; i > 1; i = i - 1)
              shifter[i] <= shifter[i-1];
		
        //shifter[0] <= D;
        shifter[1] <= D;         
      end
      
      if(CLK !== lastCLK && (intCE === 1'bx || CLK === 1'bx || lastCLK === 1'bx))
         //for(i = 0; i < rdeep; i = i + 1)
         for(i = 1; i < rdeep + 1; i = i + 1)
            shifter[i] <= {C_WIDTH{1'bx}};
    end // end(CLK or intA)
      
  
	always@(CLK)
		lastCLK <= CLK;

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
            $display("ERROR in %m at time %d ns : NOT A HEX CHARACTER", $time);
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

    integer index,i,j;
    reg [3:0] bin;

    begin
      index = 0;
      decstr_conv = 'b0;
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
          default :
          begin
            $display("ERROR in %m at time %d ns : NOT A DECIMAL CHARACTER", $time);
            bin = 4'bx;
          end
        endcase
        for( j=0; j<4; j=j+1)
        begin
          if ((index*4)+j < C_WIDTH)
          begin
            decstr_conv[(index*4)+j] = bin[j];
          end
        end
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

endmodule // C_SHIFT_RAM_V7_0
