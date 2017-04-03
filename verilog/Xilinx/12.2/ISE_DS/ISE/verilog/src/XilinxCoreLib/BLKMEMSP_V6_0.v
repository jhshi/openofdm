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

/*****************************************************************************
 * $RCSfile: BLKMEMSP_V6_0.v,v $$Date: 2008/09/08 20:06:40 $
 *****************************************************************************
 * Block Memory Compiler - Verilog Behavioral Model
 *****************************************************************************
 *
 *
 *************************************************************************
 * Filename:   BLKMEMSP_V6_0.v
 *
 * Decsription: Single Port V2 BRAM behavioral model. Extendable depth/width.
 *              The behavior for EN = `X`, WE = `X`, and for CLK transitions to
 *              or from `X` is not considered.
 *
 **************************************************************************/
`timescale 1ns/10ps

`celldefine


`define c_sp_rom 0
`define c_sp_ram 1
`define c_write_first 0
`define c_read_first  1
`define c_no_change   2

module BLKMEMSP_V6_0(DOUT,  ADDR, DIN,  EN, CLK, WE, SINIT, ND, RFD, RDY);

  parameter  c_addr_width          =  9 ; // controls address width of memory
  parameter  c_default_data        = "0"; // indicates string of hex characters used to initialize memory
  parameter  c_depth               = 512 ; // controls depth of memory
  parameter  c_enable_rlocs        = 0 ; //  core includes placement constraints
  parameter  c_has_default_data    =  1; // initializes contents of memory to c_default_data
  parameter  c_has_din             = 1  ; // indicates memory has data input pins
  parameter  c_has_en              =  1 ; // indicates memory has a EN pin
  parameter  c_has_limit_data_pitch       = 0  ; //  
  parameter  c_has_nd              = 0  ; //  Memory has a new data pin
  parameter  c_has_rdy             = 0  ; //  Memory has result ready pin
  parameter  c_has_rfd             = 0  ; //  Memory has ready for data pin
  parameter  c_has_sinit           =  1 ; // indicates memory has a SINIT pin
  parameter  c_has_we              =  1 ; // indicates memory has a WE pin
  parameter  c_limit_data_pitch           = 18;
  parameter  c_mem_init_file       =  "null.mif";  // controls which .mif file used to initialize memory
  parameter  c_pipe_stages         =  1 ; // indicates the number of pipe stages needed in port A
  parameter  c_reg_inputs          = 0 ;  // indicates WE, ADDR, and DIN are registered
  parameter  c_sinit_value         = "0000"; // indicates string of hex used to initialize  output registers
  parameter  c_width               =  32 ; // controls data width of memory
  parameter  c_write_mode          =  2; // controls which write modes shall be used
   
  parameter  c_ybottom_addr        = "1024";
  parameter  c_yclk_is_rising      = 1;
  parameter  c_yen_is_high         = 1;
  parameter  c_yhierarchy          = "hierarchy1";
  parameter  c_ymake_bmm           = 1;
  parameter  c_yprimitive_type     = "4kx4";
  parameter  c_ysinit_is_high      = 1;
  parameter  c_ytop_addr           = "0";
  parameter  c_yuse_single_primitive = 0;
  parameter  c_ywe_is_high         = 1;
 parameter   c_yydisable_warnings  = 0;
 

// IO ports


  output [c_width-1:0] DOUT;
  input [c_addr_width-1:0] ADDR;
  input [c_width-1:0] DIN;
  input EN, CLK, WE, SINIT, ND;
  output RFD, RDY;

  reg RFD ;
  reg RDY ;

  reg [c_width-1:0] dout_int; // output of RAM
  reg [c_width-1:0] pipe_out ; // output of pipeline stage
  wire [c_width-1:0] DOUT = pipe_out ;
  reg [c_width-1:0] mem [0:c_depth-1];
  reg [24:0] count;
  reg [1:0] wr_mode;

  wire [c_addr_width-1:0] addr_i = ADDR;
  reg [c_addr_width-1:0] addr_int ;
  reg [c_width-1:0] di_int ;
  wire [c_width-1:0] di_i ;
  wire clk_int ;
  wire en_int ;
  reg we_int  ;
  wire we_i ;
  reg  we_q ;
  wire ssr_int  ;
  wire nd_int ;
  wire nd_i ;
  reg rfd_int ;
  reg rdy_int ;
  reg nd_q ;
  reg [c_width-1:0] di_q ;
  reg [c_addr_width-1:0] addr_q;
  reg new_data ;
  reg new_data_q ; // to track the synchronous PORT RAM output 

  reg [c_width-1:0] default_data ;
  reg [c_width-1:0] ram_temp [0:c_depth-1];
  reg [c_width-1:0] bitval;
  reg [c_width-1:0] sinit_value;

  reg [(c_width-1) : 0] pipeline [0 : c_pipe_stages];
  reg sub_rdy[0 : c_pipe_stages];
  reg [10:0] ci, cj ;
  reg [10:0] dmi, dmj, dni, dnj, doi, doj ;
  integer i, j, k, l, m;
  integer ai, aj, ak, al, am, an, ap ;


// Generate input control signals
// Combinational 

// Take care of ROM/RAM functionality

  assign clk_int = defval(CLK, 1, 1, c_yclk_is_rising);
  assign we_i = defval(WE, c_has_we, 0, c_ywe_is_high);  
  assign di_i  = (c_has_din == 1)?DIN:'b0;
  assign en_int  = defval(EN, c_has_en, 1, c_yen_is_high);
  assign ssr_int = defval(SINIT , c_has_sinit , 0, c_ysinit_is_high);
  assign nd_i = defval (ND, c_has_nd, 1, 1);


//    tri0 GSR = glbl.GSR;

  function defval;
    input i;
    input hassig;
    input val;  
    input active_high;
  begin
    if(hassig == 1)
    begin
      if (active_high == 1)
        defval = i;
      else
        defval = ~i;
    end
    else
      defval = val;
  end
  endfunction

  function max;
    input a;  
    input b;
  begin
    max = (a > b) ? a : b;
  end
  endfunction
 
  function a_is_X;
    input [c_width-1 : 0] i;
    integer j ;
  begin
    a_is_X = 1'b0;
    for(j = 0; j < c_width; j = j + 1)
    begin
      if(i[j] === 1'bx)
        a_is_X = 1'b1;
    end // loop
  end
  endfunction


  function [c_width-1:0] hexstr_conv;
    input [(c_width*8)-1:0] def_data;

    integer index,i,j;
    reg [3:0] bin;   

  begin
    index = 0; 
    hexstr_conv = 'b0; 
    for( i=c_width-1; i>=0; i=i-1 )
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
          if (c_yydisable_warnings == 0) begin
            $display("ERROR in %m at time %t : NOT A HEX CHARACTER",$time);
          end
          bin = 4'bx;
        end
      endcase
      for( j=0; j<4; j=j+1)
      begin
        if ((index*4)+j < c_width)
        begin
          hexstr_conv[(index*4)+j] = bin[j];
        end 
      end
      index = index + 1;
      def_data = def_data >> 8;
    end
  end
  endfunction

  initial begin
    sinit_value  = 'b0 ;
    default_data = hexstr_conv(c_default_data);
    if (c_has_sinit == 1 )
      sinit_value = hexstr_conv(c_sinit_value);
    for(i = 0; i < c_depth; i = i + 1)
      mem[i] = default_data;
    if (c_has_default_data == 0)
      $readmemb(c_mem_init_file, mem);
    for (k = 0; k <= c_pipe_stages; k = k + 1)
      pipeline[k] = sinit_value ;
    for (m = 0; m <= c_pipe_stages; m = m + 1)
      sub_rdy[m] = 0 ;
    dout_int = sinit_value ;
    nd_q = 0 ;
    new_data_q = 0 ;
    di_q = 0 ;
    addr_q = 0 ;
    we_q = 0 ;
    #1 pipe_out = sinit_value;
  end

//  Generate output control signals RFD and  RDY 
//  Combinational

    always @ ( rfd_int)
    begin
      if (c_has_rfd == 1) 
        RFD = rfd_int ;
      else
        RFD = 1'b0 ;
    end

    always @ (en_int )
    begin
      if (en_int == 1'b1)
        rfd_int = 1'b1 ;
      else
        rfd_int = 1'b0 ;
    end

    always @ (  rdy_int )
    begin
      if ((c_has_rdy == 1) && (c_has_nd == 1) && (c_has_rfd == 1) )
        RDY = rdy_int ;
      else
        RDY = 1'b0 ;
    end

    assign nd_int = en_int && nd_i ; // only pass nd through if en is 1 

// Register hanshaking inputs

    always @(posedge clk_int )
    begin
      if (en_int == 1'b1)
      begin
        if (ssr_int == 1'b1)
          nd_q <= 1'b0 ;
        else
          nd_q   <= nd_int;
        end
      else
        nd_q   <= nd_q ;
    end
// Register data / address / data inputs

  always @(posedge clk_int )
  begin
    if (en_int == 1'b1)
      begin
        di_q  <= di_i ;
        addr_q <= addr_i ;
        we_q <= we_i ;
      end
  end

// select registered or non-registered write enable

  always @( we_i or we_q)
  begin
    if (c_reg_inputs == 1 )
      we_int = we_q ;
     else
      we_int = we_i ;
  end

// select registered data/address/nd inputs

  always @( di_i or di_q)
  begin
    if ( c_reg_inputs == 1)
      di_int = di_q ;
    else
      di_int = di_i ;
  end

  always @( addr_i or addr_q or nd_q or nd_int or we_q or we_i)
  begin
    if (c_reg_inputs == 1)
      begin
        addr_int = addr_q;
        if ((we_q == 1'b1) && (c_write_mode == 2))
          new_data = 1'b0 ;
       	else     
          new_data = nd_q ;
      end
    else
      begin
        addr_int = addr_i ;
        if ((we_i == 1'b1) && (c_write_mode == 2))
          new_data = 1'b0 ;
       	else        
          new_data = nd_int ;
      end
  end

// Register the new_data signal to track the synchronous RAM output

  always @(posedge clk_int)
  begin
    if ( en_int == 1'b1 )
      begin
       if (ssr_int == 1'b1)
          new_data_q <= 0 ;
       else
          new_data_q <= new_data ;
      end
  end

   initial begin
     case (c_write_mode)
       `c_write_first : wr_mode <= 2'b00;
       `c_read_first  : wr_mode <= 2'b01;
       `c_no_change   : wr_mode <= 2'b10;
       default        : begin
         if (c_yydisable_warnings == 0) begin
	   $display("Error in %m at time %t: c_write_mode = %s is not WRITE_FIRST, READ_FIRST or NO_CHANGE.",$time , c_write_mode);
         end
	 $finish;
       end
     endcase
   end


    /***************************************************************
    *The following always block assigns the value for the DOUT bus
    ***************************************************************/   
   always @(posedge clk_int) begin
     if (en_int == 1'b1) begin
       if (ssr_int == 1'b1) begin
           dout_int <= sinit_value;
       end
       else begin
	 //The following IF block assigns the output for a write operation
         if (we_int == 1'b1) begin
           if (wr_mode == 2'b00) begin
             if (addr_int < c_depth) 
                 dout_int <= di_int;
             else
	       //Warning Condition (Error occurs on rising edge of CLK): 
	       //Write Mode Port is "Write First" and EN = 1 and SINIT = 0 and WE = 1 and ADDR out of the valid range
               if (c_yydisable_warnings == 0) begin
	         $display("Invalid Address Warning #1: Warning in %m at time %t: Block memory address %d (%b) invalid. Valid depth configured as 0 to %d",$time,addr_int,addr_int,c_depth-1);    
               end
           end
           else if (wr_mode == 2'b01) begin
             if (addr_int < c_depth) 
               dout_int <= mem[addr_int];
             else
	       //Warning Condition (Error occurs on rising edge of CLK): 
	       //Write Mode Port is "Read First" and EN = 1 and SINIT = 0 and WE = 1 and ADDR out of the valid range
              if (c_yydisable_warnings == 0) begin
	        $display("Invalid Address Warning #2: Warning in %m at time %t: Block memory address %d (%b) invalid. Valid depth configured as 0 to %d",$time,addr_int,addr_int,c_depth-1);
              end
           end
           else begin
             if (addr_int < c_depth) 
               dout_int <= dout_int ;
             else
	      //Warning Condition (Error occurs on rising edge of CLK): 
	       //Write Mode Port is "No Change" and EN = 1 and SINIT = 0 and WE = 1 and ADDR out of the valid range
              if (c_yydisable_warnings == 0) begin
	        $display("Invalid Address Warning #3: Warning in %m at time %t: Block memory address %d (%b) invalid. Valid depth configured as 0 to %d",$time,addr_int,addr_int,c_depth-1);
              end
           end
	 end
	 //The following ELSE block assigns the output for a read operation
	 else begin
           if (addr_int < c_depth) 
             dout_int <= mem[addr_int];
           else
             //Warning Condition (Error occurs on rising edge of CLK): 
	     //EN = 1 and SINIT = 0 and WE = 0 and ADDRA out of the valid range 
            if (c_yydisable_warnings == 0) begin
	      $display("Invalid Address Warning #4: Warning in %m at time %t: Block memory address %d (%b) invalid. Valid depth configured as 0 to %d",$time,addr_int,addr_int,c_depth-1);
            end
	 end
       end
     end
   end


// Write to memory contents
    /***************************************************************************************
    *The following always block assigns the DIN bus to the memory during a write operation
    ***************************************************************************************/ 
   always @(posedge clk_int) begin
     if (en_int == 1'b1 && we_int == 1'b1) begin
       if (addr_int < c_depth) 
         mem [addr_int] <= di_int ;
       else
	 //Warning Condition (Error occurs on rising edge of CLK): 
	 //EN = 1 and WE = 1 and ADDR out of the valid range
        if (c_yydisable_warnings == 0) begin
	  $display("Invalid Address Warning #5: Warning in %m at time %t: Block memory address %d (%b) invalid. Valid depth configured as 0 to %d",$time,addr_int,addr_int,c_depth-1);
        end
     end
   end

//  output pipelines 
 
   always @(posedge clk_int) begin
      if (en_int == 1'b1 && c_pipe_stages > 0)
	begin
           for (i = c_pipe_stages; i >= 1; i = i -1 )
             begin
		if (ssr_int == 1'b1 && en_int == 1'b1)
		  begin
		     pipeline[i] <= sinit_value ;
		     sub_rdy[i] <=  0 ;
		  end
		else
		  begin
                    // Do not update output register if no_change on write and
                    // WE = 1
                    if (!(c_write_mode == 2 && we_int == 1)) begin
                      if (i==1)
                        begin
                          pipeline[i] <= dout_int;
                        end
                      else
                        begin
                          pipeline[i] <= pipeline[i-1] ;
                        end
                    end // if (!(c_write_mode == 2 && we_int == 1))
                    if (i==1)
                      begin
                        sub_rdy[i]  <= new_data_q;
                      end
                    else
                      begin
                        sub_rdy[i]  <= sub_rdy[i-1] ;
                      end                    
                  end
             end
        end
    end

// Select pipelined data output or no-pipelined data output
 
   always @( pipeline[c_pipe_stages] or sub_rdy[c_pipe_stages] or new_data_q or dout_int) begin
     if (c_pipe_stages == 0 )
     begin
       pipe_out = dout_int ;
       rdy_int = new_data_q ;
     end
     else
     begin
       rdy_int = sub_rdy[c_pipe_stages];
       pipe_out = pipeline[c_pipe_stages];
     end
   end

endmodule

`endcelldefine
