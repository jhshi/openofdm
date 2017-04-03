/****************************************************************************
 * $RCSfile: CAM_V6_1.v,v $ $Revision: 1.2 $ $Date: 2008/09/09 20:23:02 $
 * **************************************************************************
 * 
 * Content Addressable Memory - Verilog Behavioral Model
 * 
 * Filename: CAM_V6_1.v
 * 
 * Description:
 *  The behavioral model for the Content Addressable Memory core
 * 
 * *************************************************************************/

//  Copyright(C) 2004 by Xilinx, Inc. All rights reserved.
//  This text/file contains proprietary, confidential
//  information of Xilinx, Inc., is distributed under license
//  from Xilinx, Inc., and may be used, copied and/or
//  disclosed only pursuant to the terms of a valid license
//  agreement with Xilinx, Inc.  Xilinx hereby grants you
//  a license to use this text/file solely for design, simulation,
//  implementation and creation of design files limited
//  to Xilinx devices or technologies. Use with non-Xilinx
//  devices or technologies is expressly prohibited and
//  immediately terminates your license unless covered by
//  a separate agreement.
//
//  Xilinx is providing this design, code, or information
//  "as is" solely for use in developing programs and
//  solutions for Xilinx devices.  By providing this design,
//  code, or information as one possible implementation of
//  this feature, application or standard, Xilinx is making no
//  representation that this implementation is free from any
//  claims of infringement.  You are responsible for
//  obtaining any rights you may require for your implementation.
//  Xilinx expressly disclaims any warranty whatsoever with
//  respect to the adequacy of the implementation, including
//  but not limited to any warranties or representations that this
//  implementation is free from claims of infringement, implied
//  warranties of merchantability or fitness for a particular
//  purpose.
//
//  Xilinx products are not intended for use in life support
//  appliances, devices, or systems. Use in such applications are
//  expressly prohibited.
//
//  This copyright and support notice must be retained as part
//  of this text at all times. (c) Copyright 1995-2004 Xilinx, Inc.
//  All rights reserved.


 /*************************************************************************
 * Set the timescale value for this core
 *************************************************************************/
`timescale 1ns/10ps
 

 /*************************************************************************
 * Declare top-level module
 *************************************************************************/
module CAM_V6_1
  (
   CLK,
   CMP_DATA_MASK,
   CMP_DIN,
   DATA_MASK,
   DIN,
   EN,
   WE,
   WR_ADDR,
   BUSY,
   MATCH,
   MATCH_ADDR,
   MULTIPLE_MATCH,
   READ_WARNING,
   SINGLE_MATCH
  );


/*************************************************************************
 * Parameter Declarations (external)
 *************************************************************************/
parameter c_addr_type             = 2;
parameter c_cmp_data_mask_width   = 4;
parameter c_cmp_din_width         = 4;
parameter c_data_mask_width       = 4;
parameter c_depth                 = 16;
parameter c_din_width             = 4;
parameter c_family                = "";
parameter c_has_cmp_data_mask     = 0;
parameter c_has_cmp_din           = 0;
parameter c_has_data_mask         = 0;
parameter c_has_en                = 0;
parameter c_has_multiple_match    = 0;
parameter c_has_read_warning      = 0;
parameter c_has_single_match      = 0;
parameter c_has_we                = 1;
parameter c_has_wr_addr           = 1;
parameter c_match_addr_width      = 16;
parameter c_match_resolution_type = 0;
parameter c_mem_init              = 0;
parameter c_mem_init_file         = "";
parameter c_mem_type              = 0;
parameter c_read_cycles           = 1;
parameter c_reg_outputs           = 0;
parameter c_ternary_mode          = 0;
parameter c_width                 = 1;
parameter c_wr_addr_width         = 4;
   

/****************************************************************************
 * Definition of Generics:
 ****************************************************************************
 *  c_addr_type             : Determines format of MATCH_ADDR output
 *                              0 = Binary Encoded
 *                              1 = Single Match Unencoded (one*hot)
 *                              2 = Multi*match unencoded (shows all matches)
 *  c_cmp_data_mask_width   : Width of the cmp_data_mask port
 *                              (should be the same as c_width)
 *  c_cmp_din_width         : Width of the cmp_din port
 *                              (should be the same as c_width)
 *  c_data_mask_width       : Width of the data_mask port
 *                              (should be the same as c_width)
 *  c_depth                 : Depth of the CAM
 *                              (Must be > 2)
 *  c_din_width             : Width of the din port
 *                              (should be the same as c_width)
 *  c_family                : Architecture (not used in behavioral model)
 *  c_has_cmp_data_mask     : 1 if cmp_data_mask input port present
 *  c_has_cmp_din           : 1 if cmp_din input port present
 *  c_has_data_mask         : 1 if data_mask input port present
 *  c_has_en                : 1 if en input port present
 *  c_has_multiple_match    : 1 if multiple_match output port present
 *  c_has_read_warning      : 1 if read_warning output port present
 *  c_has_single_match      : 1 if single_match output port present
 *  c_has_we                : 1 if we input port present
 *  c_has_wr_addr           : 1 if wr_addr input port present
 *  c_match_addr_width      : Width of the match_addr port
 *                              log2roundup(c_depth) if c_addr_type=0
 *                              c_depth if c_addr_type = 1 or 2
 *  c_match_resolution_type : When c_addr_type=0 or 1, only one match can
 *                              be output.
 *                              0 = Output lowest matching address
 *                              1 = Output highest matching address
 *  c_mem_init              :   0 = Do not initialize CAM
 *                              1 = Initialize CAM
 *  c_mem_init_file         : Filename of .mif file for initializing CAM
 *  c_mem_type              :   0 = SRL16E implementation
 *                              1 = Block Memory implementation
 *  c_read_cycles           : Always fixed as 1 in CAM version 3.0
 *  c_reg_outputs           : For use with Block Memory ONLY.
 *                              0 = Do not add extra output registers.
 *                              1 = Add output registers
 *  c_ternary_mode          :   0 = Binary CAM
 *                              1 = Ternary CAM (can store X's)
 *  c_width                 : Data Width of the CAM
 *  c_wr_addr_width         : Width of wr_addr port = log2roundup(c_depth)
 ***************************************************************************/


   
/*************************************************************************
 * Input and Output Declarations
 *************************************************************************/
input CLK;
input [c_cmp_data_mask_width-1:0] CMP_DATA_MASK;
input [c_cmp_din_width-1:0] CMP_DIN;
input [c_data_mask_width-1:0] DATA_MASK;
input [c_din_width-1:0] DIN;
input EN;
input WE;
input [c_wr_addr_width-1:0] WR_ADDR;
output BUSY;
output MATCH;
output [c_match_addr_width-1:0] MATCH_ADDR;
output MULTIPLE_MATCH;
output READ_WARNING;
output SINGLE_MATCH;
   
reg MATCH;
reg [c_match_addr_width-1:0] MATCH_ADDR;
reg MULTIPLE_MATCH;
reg READ_WARNING;
reg SINGLE_MATCH;

/****************************************************************************
 * Definition of Ports
 ****************************************************************************
 *  CLK            : IN  : Clock
 *  CMP_DATA_MASK  : IN  : Data mask for CMP_DIN port
 *  CMP_DIN        : IN  : Compare port - Data input (CAM read/search operation)
 *  DATA_MASK      : IN  : Data mask for DIN port
 *  DIN            : IN  : Data input (CAM Write operation, and CAM read/search)
 *  EN             : IN  : CAM enable (active high)
 *  WE             : IN  : CAM write enable (active high)
 *  WR_ADDR        : IN  : CAM write address
 *  BUSY           : OUT : High state indicates that user can not start a new
 *                         write operation
 *  MATCH          : OUT : High state indicates one or more matches found
 *  MATCH_ADDR     : OUT : Address (or addresses) of matches found (if any)
 *  MULTIPLE_MATCH : OUT : High state indicates MORE than one match found 
 *  READ_WARNING   : OUT : High state indicates that the match operation may
 *                         have returned misleading results because the data
 *                         was being modified by a simultanous write operation
 *  SINGLE_MATCH   : OUT : High state indicates ONLY one match found
 ***************************************************************************/

   
   
/*************************************************************************
 * Internal wires and regs for each port
 *************************************************************************/
wire [c_width-1:0] rd_din;
wire [c_width-1:0] rd_data_mask;
wire [c_width-1:0] data_mask_i;
wire [c_width-1:0] din_i;
wire en_i;
wire we_i;
wire [c_wr_addr_width-1:0] wr_addr_i;
reg busy_i;

   
/*************************************************************************
 * registered copies of inputs
 *************************************************************************/
reg [c_width-1:0] data_mask_q;
reg [c_width-1:0] din_q;
reg [c_wr_addr_width-1:0] wr_addr_q;
//[c_width-1:0] wr_data_mask_q;
//[c_width-1:0] wr_din_q;

   
/*************************************************************************
 * non-registered versions of output ports
 *************************************************************************/
reg match_i;
reg [c_match_addr_width-1:0] match_addr_i;
reg multiple_match_i;
reg read_warning_i;
reg single_match_i;

   
/*************************************************************************
 * registered versions of output ports
 *************************************************************************/
reg match_q;
reg [c_match_addr_width-1:0] match_addr_q;
reg multiple_match_q;
reg read_warning_q;
reg single_match_q;


/*************************************************************************
 * internal signals, not connected to ports
 *************************************************************************/
reg [c_wr_addr_width-1:0] wr_addr_int;
reg [c_width-1:0] wr_din;
reg [c_width-1:0] wr_data_mask;

integer write_counter;
wire wren;

reg RESET;
   

/*************************************************************************
 * internal signals used in the match always block
 *************************************************************************/
reg [c_depth-1:0] m_match_addr_i;
integer m_matches;
integer  i, j, initcntw, initcntd;
reg [c_depth-1:0] tmp_m_match_addr_i;
   
   
/*************************************************************************
 * Data type for internal cam data storage
 *************************************************************************/
reg [c_width-1:0] cam_data[0:c_depth-1];

/*************************************************************************
 * Data type for internal cam mask storage
 *************************************************************************/
reg [c_width-1:0] cam_mask[0:c_depth-1];
   
/*************************************************************************
 * Data type for internal cam initialization
 *************************************************************************/
reg [c_width-1:0] cam_init[0:c_depth-1];

/*************************************************************************
 * Initialzation value for cam_data and cam_mask elements
 *************************************************************************/
reg [c_width-1:0] init_word;
reg [c_width-1:0] data_word;
reg [c_width-1:0] mask_word;
reg [c_width-1:0] zees;
reg [c_width-1:0] zeros;

/*************************************************************************
 * Internal Constants
 *************************************************************************/

parameter const_srl_mem   = 0;  //Constant for c_mem_type= SRL16
parameter const_block_mem = 1;  //Constant for c_mem_type= Block Memory
parameter const_dist_mem  = 2;  //Constant for c_mem_type= Distributed Memory

parameter const_bin_encoded  = 0;  //Constant for c_addr_type= Binary Encoded
parameter const_sm_unencoded = 1;  //Constant for c_addr_type= Single-Match Unencoded
parameter const_mm_unencoded = 2;  //Constant for c_addr_type= Multiple-Match Unencoded

parameter const_lowest_match  = 0;  //Constant for c_resolution_type= Lowest Match
parameter const_highest_match = 1;  //Constant for c_resolution_type= Highest Match

parameter const_ternary_off = 0;  //Constant for c_ternary_mode = None
parameter const_ternary_std = 1;  //Constant for c_ternary_mode = Standard
parameter const_ternary_enh = 2;  //Constant for c_ternary_mode = XY
   

/************States for the CAM's internal state machine ****************/  
parameter READ_MODE            = 1;
parameter START_WRITE_MODE     = 2;
parameter END_BLK_WR_MODE      = 3;
parameter BUSY_SRL_WR_MODE     = 4;
parameter NEAR_SRL_END_WR_MODE = 5;
parameter END_SRL_WR_MODE      = 6;

integer CAM_MODE;
   
   

   
/*************************************************************************
 * CAM Functions
 *************************************************************************/




/*************************************************************************
 * FUNCTION: binary_match_encoder
 * 
 * DESCRIPTION:
 *  This is the binary encoder which converts a one-hot match value into
 *  the binary match value
 * 
 *  An input of all-zeros produces a zero output
 * 
 * INPUT:
 *   vector = one-hot encoded vector
 * 
 * OUTPUT:
 *   binary encoded equivalent of the one-hot input
 *************************************************************************/
   function [c_match_addr_width-1:0] binary_match_encoder;
      
     input [c_depth-1:0] vector;
      integer i;
      begin
	 binary_match_encoder=0;
	 for (i=0; i<=c_depth; i=i+1)
	   if (vector[i]==1'b1)
	     binary_match_encoder=i;
      end
   endfunction


   
/*************************************************************************
 * FUNCTION: one_hot
 * 
 * DESCRIPTION:
 *     This function converts a binary value into a one-hot encoded
 *    value of width one_hot_size.
 * 
 * INPUT:
 *   matchlocation = binary vector
 * 
 * OUTPUT:
 *   one-hot encoded equivalent of binary value
 *************************************************************************/
   function [c_depth-1:0] one_hot_match;
      input [c_wr_addr_width-1:0] matchlocation;
      integer i;
      begin
	 for (i=0;i<=c_depth-1;i=i+1)
	   if (i==matchlocation)
	     one_hot_match[i] = 1'b1;
	   else
	     one_hot_match[i] = 1'b0;
      end
   endfunction


/*************************************************************************
 * FUNCTION: set_bit
 * 
 * DESCRIPTION:
 *    This function sets the bit bit_to_set of the input binary value. It
 *    returns the modified std_logic_vector of that binary value.
 * 
 * INPUT:
 *   bit_to_set = value indicating which bit to set
 *   initialvalue = bit vector
 * 
 * OUTPUT:
 *   initialvalue, with the bit_to_set bit set to '1'
 *************************************************************************/
   function [c_depth-1:0] set_bit;
      input [c_wr_addr_width-1:0] bit_to_set;
      input [c_depth-1:0] initialvalue;
      begin
	 set_bit = initialvalue;
	 set_bit[bit_to_set] = 1'b1;
      end
   endfunction


/*************************************************************************
 * FUNCTION: ternary_value 
 * 
 * WARNING: THIS FUNCTION DOES NOT WORK FOR VERILOG 
 * 
 * DESCRIPTION:
 *   This function converts a mask and data vector into a single
 *   std_logic_vector using 1's 0's and X's.
 * 
 * INPUT:
 *    mask : mask for data, if bit is '1', bit is considered an 'X'
 *    data : data
 * 
 * OUTPUT:
 *    the data and mask combined into a single std_logic_vector, where
 *    any bit masked out is assigned the value 'X'.
 *************************************************************************/
//   function [c_width-1:0] ternary_value;
//      input [c_width-1:0] mask;
//     input [c_width-1:0] data;
//      integer i;
//      begin
//	 for (i=0; i<=c_width-1; i=i+1)
//	   if (mask[i]==1'b1)
//	     ternary_value[i] = 1'bx;
//	   else
//	     ternary_value[i] = data[i];
//     end
//   endfunction
   

/*************************************************************************
 * FUNCTION: ternary_compare
 * 
 * DESCRIPTION:
 *  This function compares two ternary values which are described using
 *  a combination of mask and data. When the mask bit = '1', the bit
 *  is considered an X, and will match either a 0 or a 1 bit.
 * INPUTS:
 *    maska = mask for dataa, a bit of '1' indicates an 'X' value
 *    dataa = first data input
 *    maskb = mask for datab, a bit of '1' indicates an 'X' value
 *    datab = second data input
 *
 * OUTPUT:
 *    1 if A matches B. X's (mask 1's) are considered "don't cares".
 *    0 otherwise.
 *************************************************************************/
   function ternary_compare;
      input [c_width-1:0] maska;
      input [c_width-1:0] dataa;
      input [c_width-1:0] maskb;
      input [c_width-1:0] datab;
      integer i;
      integer equal;
      begin
	 equal = 1;
	 for (i=0; i<=c_width-1; i=i+1)
	   begin
	      if (dataa[i]===1'bz || datab[i]===1'bz)
		equal = 0;
	      if (maska[i]==1'b0 && maskb[i]==1'b0)
		begin
		   if (dataa[i]===1'b1 && datab[i]===1'b0)
		     equal = 0;
		   if (dataa[i]===1'b0 && datab[i]===1'b1)
		     equal = 0;
		end
	   end

	 ternary_compare = equal;
	 
      end
   endfunction

   function ternary_compare_xy;
      input [c_width-1:0] maska;
      input [c_width-1:0] dataa;
      input [c_width-1:0] maskb;
      input [c_width-1:0] datab;
      integer i;
      integer equal;
      begin
	 equal = 1;
	 for (i=0; i<=c_width-1; i=i+1)
	   begin
	      if (dataa[i]===1'bz || datab[i]===1'bz)
		equal = 0;
	      if (maska[i]==1'b1 || maskb[i]==1'b1)
	       begin
		if (dataa[i]===1'b1 || datab[i]===1'b1)
		 equal = 0;
	       end
	   end

	 ternary_compare_xy = equal;
	 
      end
   endfunction


/*************************************************************************
 * FUNCTION: ternary_compareX
 * 
 * WARNING: THIS FUNCTION DOES NOT WORK FOR VERILOG 
 * 
 * DESCRIPTION:
 *  This function compares two std_logic_vectors which can include X's.
 *  Here, an X is considered to match both 1 and 0.
 *  A U matches nothing.
 *
 * INPUTS:
 *    dataa = first data input (can include X's)
 *    datab = second data input (can include X's)
 *
 * OUTPUT:
 *    1 if A matches B. X's are considered "don't cares".
 *    0 otherwise.
 *************************************************************************/
//   function ternary_compareX;
//      input [c_width-1:0] dataa;
//      input [c_width-1:0] datab;
//      integer i;
//      integer equal;
//      begin
//	 equal = 1;
//	 for (i=0; i<=c_width-1; i=i+1)
//	   begin
//	      if (dataa[i]==1'bz || datab[i]==1'bz)
//		equal = 0;
//	      if (dataa[i]==1'b1 && datab[i]==1'b0)
//		equal = 0;
//	      if (dataa[i]==1'b0 && datab[i]==1'b1)
//		equal = 0;
//	   end
//	 ternary_compareX = equal;
//     end
//   endfunction


/*************************************************************************
 * FUNCTION: binary_compare
 * 
 * DESCRIPTION:
 *  This function compares two std_logic_vectors (dataa and datab).
 *  It returns true if they are identical, false otherwise.
 *  If any bit is 'Z', the vectors are considered to not match.
 *
 * INPUTS:
 *    dataa = first data input (binary format)
 *    datab = second data input (binary format)
 *    
 * OUTPUT:
 *    1 if the binary values match exactly,
 *    0 otherwise
 *************************************************************************/
   function binary_compare;
      input [c_width-1:0] dataa;
      input [c_width-1:0] datab;
      integer i;
      integer equal;
      begin
	 equal = 1;
	 for (i=0; i<=c_width-1; i=i+1)
	   begin
	      if (dataa[i]===1'bz || datab[i]===1'bz)
		equal = 0;
	      if (dataa[i]===1'b1 && datab[i]===1'b0)
		equal = 0;
	      if (dataa[i]===1'b0 && datab[i]===1'b1)
		equal = 0;
	   end

	 binary_compare = equal;
	 
    end      
endfunction
	      



/*************************************************************************
 * Establish initial values
 *************************************************************************/
initial
  begin
     //Initialize internal signals to 0
     RESET = 1'b0;
     
     busy_i = 1'b0;
     read_warning_i = 1'b0;

     match_i = 1'b0;
     multiple_match_i = 1'b0;
     single_match_i = 1'b0;
     
     m_match_addr_i = 0;
     
     //Initialize registered outputs to 0
     // (they won't be updated until 2nd clock cycle)
     data_mask_q = 0;
     din_q = 0;
     wr_addr_q = 0;
     match_q = 1'b0;
     match_addr_q = 0;
     multiple_match_q = 1'b0;
     read_warning_q = 1'b0;
     single_match_q = 1'b0;

     //Initialize outputs to 0
     // (they won't be set until match transitions)
     MATCH = 0;
     if (c_addr_type == const_bin_encoded &&
	 c_match_resolution_type == const_lowest_match) 
      MATCH_ADDR = c_depth;
     else
      MATCH_ADDR = 0;
     if (c_has_multiple_match)
       MULTIPLE_MATCH = multiple_match_q;
     if (c_has_read_warning)
       READ_WARNING = read_warning_q;
     if (c_has_single_match)
       SINGLE_MATCH = single_match_q;   

     //Initialize internal write signals to 0 
     // (since they are registered and don't get updated immediately)
     wr_addr_int = 0;
     wr_din = 0;
     wr_data_mask = 0;
     
     write_counter = 0;
     
     CAM_MODE = READ_MODE;
     
     //Initializing the CAM

     // Set up temporary values for storing z's and 0's
     for (initcntw=0; initcntw<=c_width-1; initcntw = initcntw+1)
     begin
       zees[initcntw]=1'bz;
       zeros[initcntw]=1'b0;
     end

     //Initialize the cam_init array so that each element is all-Zs
     for (initcntd=0; initcntd<=c_depth-1; initcntd = initcntd+1)
       cam_init[initcntd]=zees;
     
     //When initialization option is not selected,
     //  initialize data to Zs, and mask to 0s.
     if (c_mem_init == 0)     
         for (initcntd=0; initcntd<=c_depth-1; initcntd = initcntd+1)
         begin
           cam_data[initcntd]=zees;
           cam_mask[initcntd]=zeros;
         end

     //if Initialization option is selected     
     else
       begin
	 //Read cam_init array from the .mif file
         $readmemb(c_mem_init_file, cam_init);    

	 //Set data and mask arrays based on .mif data
         for (initcntd=0; initcntd<=c_depth-1; initcntd = initcntd+1)
         begin
            init_word = cam_init[initcntd];
            for (initcntw=0; initcntw<=c_width-1; initcntw = initcntw+1)
            begin
              if (init_word[initcntw] == 1'b0)
              begin
                 data_word[initcntw] = 1'b0;
                 mask_word[initcntw] = 1'b0;
              end
              else if (init_word[initcntw] == 1'b1)
              begin
                 data_word[initcntw] = 1'b1;
                 mask_word[initcntw] = 1'b0;
              end
	      //Standard Ternary Mode (init_word=x)
              else if (init_word[initcntw] === 1'bx)
              begin
                 data_word[initcntw] = 1'b0;
                 mask_word[initcntw] = 1'b1;
              end
              //Uninitialized case (cam_init array was initialized to z earlier
	      //in this code.
              else
              begin
                 data_word[initcntw] = 1'bz;
                 mask_word[initcntw] = 1'b0;
              end
	    end 
            cam_data[initcntd] = data_word;
            cam_mask[initcntd] = mask_word;
         end        
       end
  
  end // initial begin
   

   

   
/*************************************************************************
 * Connect ports to internal signals
 *************************************************************************/

   //Data input bus (write data)
   assign din_i = DIN;

   //Write Enable
   assign we_i = c_has_we ? WE : 1'b0;

   //Write Address
   assign wr_addr_i = c_has_wr_addr ? WR_ADDR : 0;

   //Busy flag
   assign BUSY = busy_i;

   //Match flags, Match Address, Read Warning flag
   always @(match_i or match_q or match_addr_i or match_addr_q or multiple_match_i or multiple_match_q or read_warning_i or read_warning_q or single_match_i or single_match_q)
     begin
	if (c_reg_outputs==1)
	  begin
	     MATCH = match_q;
	     MATCH_ADDR = match_addr_q;
	     if (c_has_multiple_match)
	       MULTIPLE_MATCH = multiple_match_q;
	     if (c_has_read_warning)
	       READ_WARNING = read_warning_q;
	     if (c_has_single_match)
	       SINGLE_MATCH = single_match_q;
      	  end
	else
	 begin
	     MATCH = match_i;
	     MATCH_ADDR = match_addr_i;
	     if (c_has_multiple_match)
	       MULTIPLE_MATCH = multiple_match_i;
	     if (c_has_read_warning)
	       READ_WARNING = read_warning_i;
	     if (c_has_single_match)
	       SINGLE_MATCH = single_match_i;
	  end
     end // always @ (match_i, match_q, match_addr_i, match_addr_q)

   //Data mask for din port (write data)
   assign data_mask_i = c_has_data_mask ? DATA_MASK : 0;

   //Read data input
   assign rd_din = c_has_cmp_din ? CMP_DIN : DIN;

   //Data mask for read data input
   //assign rd_data_mask = c_has_cmp_data_mask ? (c_has_cmp_din ? CMP_DATA_MASK : (c_has_data_mask ? DATA_MASK : 0)) : 0;
   assign rd_data_mask = c_has_cmp_data_mask ? CMP_DATA_MASK : ((c_has_data_mask ? DATA_MASK : 0));


   //Internal enable signal
   assign en_i = c_has_en ? EN : 1;
   

/*************************************************************************
 * Registered Outputs
 *************************************************************************/
always @(posedge CLK or posedge RESET)
  begin
     if (c_reg_outputs==1)
       begin
	  if (RESET)
	    begin
	       match_q <= 0;
	       match_addr_q <= 0;
	       multiple_match_q <= 0;
	       read_warning_q <= 0;
	       single_match_q <= 0;
	    end
	  else
	    if (en_i)
  	       begin
	          match_q <= match_i;
	          match_addr_q <= match_addr_i;
	          multiple_match_q <= multiple_match_i;
	          read_warning_q <= read_warning_i;
	          single_match_q <= single_match_i;
	       end // if en_i
       end // if ((c_reg_outputs==1) || (c_addr_type==const_bin_encoded))
  end // always @ (posedge CLK, posedge RESET)



 /*************************************************************************
 * PROCESS:   mode_proc
 *
 * DESCRIPTION:
 * This always block determines the current state of the CAM.
 *  It implements a state machine. On the rising edge of the clock, this
 *  process determines the next state based on the current state and any
 *  relevant inputs (we_i, write_counter, or c_mem_type).
 *************************************************************************/

   always @(posedge CLK)
	if (en_i)
	     case (CAM_MODE)

	       READ_MODE:
		 if (we_i)
		   CAM_MODE <= START_WRITE_MODE;
	         else //we_i=1
		   CAM_MODE <= READ_MODE;

	       START_WRITE_MODE:
		 if (c_mem_type==const_block_mem)
		   CAM_MODE <= END_BLK_WR_MODE;
	         else //c_mem_type=srl16
		   CAM_MODE <= BUSY_SRL_WR_MODE;

	       END_BLK_WR_MODE:
		 if (we_i)
		   CAM_MODE <= START_WRITE_MODE;
	         else //we_i=1
		   CAM_MODE <= READ_MODE;

	       BUSY_SRL_WR_MODE:
		 if (write_counter < 14)
		   CAM_MODE <= BUSY_SRL_WR_MODE;
	         else //write_counter >= 14
		   CAM_MODE <= NEAR_SRL_END_WR_MODE;

	       NEAR_SRL_END_WR_MODE:
		 CAM_MODE <= END_SRL_WR_MODE;

	       END_SRL_WR_MODE:
		 if (we_i)
		   CAM_MODE <= START_WRITE_MODE;
	         else //we_i=1
		   CAM_MODE <= READ_MODE;

	       default:
		 CAM_MODE <= READ_MODE;

	     endcase // case(CAM_MODE)





/*************************************************************************
 * PROCESS:   match_proc
 *
 * DESCRIPTION:
 * This process provides the logic used to determine if there is a match,
 * how many matches are present, and the ideal state of the various output
 * signals associated with the match logic.
 * (Note: these outputs might be overridden under certain conditions)
 *************************************************************************
 * On the rising clock edge, the m_ (match_) internal signals are calculated.
 * These m_ signals are later connected to the appropriate outputs.
 *************************************************************************/
  always @(posedge CLK)
   if (en_i)
     begin
	//set defaults
	tmp_m_match_addr_i = 0;
	single_match_i   <= 1'b0;
	multiple_match_i <= 1'b0;
	match_i          <= 1'b0;
	m_matches          = 0;
        
	for (i=0; i<=c_depth-1; i=i+1)
	  begin
	     if (c_match_resolution_type==const_highest_match)
	       //loop the other way if resolution_type changes
	       j = c_depth-1-i; 
	     else
	       j = i;
	     
	     //determine if a match for the data is found in location i
	     // (either direct match, or a ternary match)
	     if ((c_ternary_mode == const_ternary_off && binary_compare(rd_din, cam_data[j])) 
		 || (c_ternary_mode == const_ternary_std 
		     && ternary_compare(rd_data_mask, rd_din, cam_mask[j], cam_data[j])) 
		 || (c_ternary_mode == const_ternary_enh 
		     && ternary_compare_xy(rd_data_mask, rd_din, cam_mask[j], cam_data[j])))
	       
	       //If during a write, we are reading and writing to the same address
	       if (j == wr_addr_int && wren == 1)
                 ; //Then do nothing (don't count this match)
	       else
		 begin  
		    //Otherwise, count the match
		    
		    
		    /********************************************************
		     * Calculate once for Read
		     *******************************************************/
		    //if one or more matches have already been found, 
		    // update signals to reflect multiple matches
		    if (m_matches > 0)
		      begin
			 single_match_i   <= 1'b0;
			 multiple_match_i <= 1'b1;
			 match_i          <= 1'b1;
			 if (c_addr_type == const_mm_unencoded)
			   tmp_m_match_addr_i = set_bit(j, tmp_m_match_addr_i);
		      end
		    
		    
		    //if no matches have been found yet, then update signals
		    //  to reflect a single match
		    if (m_matches == 0)
		      begin
			 single_match_i   <= 1'b1;
			 multiple_match_i <= 1'b0;
			 match_i          <= 1'b1;
			 tmp_m_match_addr_i = one_hot_match(j);
			 m_matches          = m_matches + 1;
		      end
		    
		 end
	  end
	
	m_match_addr_i <= tmp_m_match_addr_i;
	
     end


   
/*************************************************************************
 * Match Address Output (optional binary encoding)
 *************************************************************************/
 always @(m_match_addr_i)
   if (c_addr_type==const_bin_encoded)  
     match_addr_i = binary_match_encoder(m_match_addr_i);
   else
     match_addr_i = m_match_addr_i;
   
   

/*************************************************************************
 * The internal write values (wr_data_mask and wr_din) are set asynchronously
 *  when din_i and data_mask_i changes, but once a write operation starts, 
 *  they are connected to their registered values, to hold the data valid
 *  until the write operation is complete.
 *************************************************************************/

always @(din_i or din_q or data_mask_i or data_mask_q or wr_addr_i or wr_addr_q or we_i or busy_i)
     if (we_i==1 && busy_i==0)
       begin
	  wr_data_mask <= data_mask_i;
	  wr_din       <= din_i;
	  wr_addr_int  <= wr_addr_i;
       end
     else
       begin
	  wr_data_mask <= data_mask_q;
	  wr_din       <= din_q;
	  wr_addr_int  <= wr_addr_q;
       end // else: !if(we_i==1 && busy_i==0)


assign wren = we_i | busy_i;
   

/*************************************************************************
 * PROCESS: proc_inputs
 * 
 * DESCRIPTION:
 *   Register the input values to hold them during processing.
 *************************************************************************/
always @(posedge CLK)
  begin
     if (en_i==1 && we_i==1 && busy_i==0)
       begin
	  data_mask_q <= data_mask_i;
	  din_q       <= din_i;
	  wr_addr_q   <= wr_addr_i;
       end
  end


   

/*************************************************************************
 * PROCESS:   main
 *
 * DESCRIPTION:
 * This process, on the rising edge of the clock, uses a case statement
 * to identify the current state.
 * In these blocks, the outputs for that CAM state are calculated.
 * This implements a MEALY machine, where the outputs are set on each state
 * transition according to the current state and the inputs.
 *************************************************************************/

always @(posedge CLK)
  begin
     if (en_i)
       case (CAM_MODE)
	 
         /****************************************************************
          * READ MODE - CAM's normal state, searching for matches
          ***************************************************************/
	 READ_MODE:
	   if (we_i == 0)
             // IF continuing to read
	     begin
		busy_i <= 1'b0;
		read_warning_i <= 1'b0;
		write_counter <= 0;
	     end
	   else
             // ELSE starting a write
	     begin
		if ((c_ternary_mode == const_ternary_off && binary_compare(wr_din, rd_din)) 
		    || (c_ternary_mode == const_ternary_std 
			&& ternary_compare(wr_data_mask, wr_din, rd_data_mask, rd_din)) 
		    || (c_ternary_mode == const_ternary_enh 
			&& ternary_compare_xy(wr_data_mask, wr_din, rd_data_mask, rd_din)))
		  
		  //IF read and write data match, flag a read warning
		  read_warning_i <= 1'b1;
		else
		  read_warning_i <= 1'b0;
		
		busy_i <= 1'b1; //Set busy while writing
		write_counter <= write_counter+1; //Start counting the clock
		                                  //cycles for the write
	     end
	 
	 
	 
	 
         //*************************************************************
         // START WRITE MODE - A write operation has been initiated
         //*************************************************************
	 START_WRITE_MODE:
	   if (c_mem_type == const_block_mem)
	     
             // IF block memory implementation
	     begin
		busy_i <= 0;
		write_counter <= write_counter+1;
		if ((c_ternary_mode == const_ternary_off && binary_compare(wr_din, rd_din)) 
		    || (c_ternary_mode == const_ternary_std 
			&& ternary_compare(wr_data_mask, wr_din, rd_data_mask, rd_din)) 
		    || (c_ternary_mode == const_ternary_enh 
			&& ternary_compare_xy(wr_data_mask, wr_din, rd_data_mask, rd_din)))
		  //IF read and write data match, flag a read warning
		  read_warning_i <= 1;
		else
		  read_warning_i <= 0;
		
		// Update the contents of the CAM with the value being written
		if (c_ternary_mode)
                begin
		  cam_data[wr_addr_int] <= wr_din;
		  cam_mask[wr_addr_int] <= wr_data_mask;
                end
		else
		  cam_data[wr_addr_int] <= wr_din;
	     end
	 
	   else //c_mem_type=const_srl16
	     
             // ELSE srl16 implementation
	     begin
		if ((c_ternary_mode == const_ternary_off && binary_compare(wr_din, rd_din)) 
		    || (c_ternary_mode == const_ternary_std 
			&& ternary_compare(wr_data_mask, wr_din, rd_data_mask, rd_din)) 
		    || (c_ternary_mode == const_ternary_enh 
			&& ternary_compare_xy(wr_data_mask, wr_din, rd_data_mask, rd_din)))
		  //IF read and write data match, flag a read warning
		  read_warning_i <= 1;
		else
		  read_warning_i <= 0;
		
		busy_i <= 1;//Set busy while writing
		write_counter <= write_counter+1;// Count clock cyles for the
		                                 // write
	     end
	 
	 
         //*************************************************************
         // END BLK WR MODE - Last cycle of a block-memory write operation
         //*************************************************************
	 END_BLK_WR_MODE:
	   if (we_i == 0)
             // IF ending the write operation and going into read_mode
	     begin
		busy_i <= 0;
		read_warning_i <= 0;
		write_counter <= 0;
	     end
	   else
             // ELSE starting another write operation immediately
	     begin
		if ((c_ternary_mode == const_ternary_off && binary_compare(wr_din, rd_din)) 
		    || (c_ternary_mode == const_ternary_std 
			&& ternary_compare(wr_data_mask, wr_din, rd_data_mask, rd_din)) 
		    ||  (c_ternary_mode == const_ternary_enh 
			 && ternary_compare_xy(wr_data_mask, wr_din, rd_data_mask, rd_din)))

		  //IF read and write data match, flag a read warning
		  read_warning_i <= 1;
		else
		  read_warning_i <= 0;
		
		busy_i <= 1;//Set busy while writing 
		write_counter <= 1;
	     end // else: !ifwe_i
	 

	 
	 
	 
         //*************************************************************
         // BUSY_SRL_WR_MODE - Middle of a SRL16 write operation
         //*************************************************************
	 BUSY_SRL_WR_MODE:
	   begin
	      if ((c_ternary_mode == const_ternary_off && binary_compare(wr_din, rd_din)) 
		  || (c_ternary_mode == const_ternary_std 
		      && ternary_compare(wr_data_mask, wr_din, rd_data_mask, rd_din)) 
		  || (c_ternary_mode == const_ternary_enh
		      && ternary_compare_xy(wr_data_mask, wr_din, rd_data_mask, rd_din)))
		//IF read and write data match, flag a read warning
		read_warning_i <= 1;
	      else
		read_warning_i <= 0;
	      
	      busy_i <= 1;//Set busy while writing
	      write_counter <= write_counter+1;// Count clock cyles for the
	                                       // write
	   end // case: BUSY_SRL_WR_MODE
	 
	 
	 
	 
         //*************************************************************
         // NEAR_SRL_END_WR_MODE - Next-to-last clock cycle for an SRL16 write
         //*************************************************************
	 NEAR_SRL_END_WR_MODE:
	   begin
	      if ((c_ternary_mode == const_ternary_off && binary_compare(wr_din, rd_din)) 
		  || (c_ternary_mode == const_ternary_std 
		      && ternary_compare(wr_data_mask, wr_din, rd_data_mask, rd_din)) 
		  || (c_ternary_mode == const_ternary_enh 
		      && ternary_compare_xy(wr_data_mask, wr_din, rd_data_mask, rd_din)))
		//IF read and write data match, flag a read warning
		read_warning_i <= 1;
	      else
		read_warning_i <= 0;
	      
	      busy_i <= 0;
	      write_counter <= write_counter+1;
	      
	      // Update the contents of the CAM with the value being written
	      if (c_ternary_mode != const_ternary_off)
              begin
		cam_data[wr_addr_int] <= wr_din;
		cam_mask[wr_addr_int] <= wr_data_mask;
              end
	      else
		cam_data[wr_addr_int] <= wr_din;
	      
	   end
	 
	 
	 
         //*************************************************************
         // END_SRL_WR_MODE - Last cycle of a SRL16 write operation
         //*************************************************************
	 END_SRL_WR_MODE:
	   if (we_i == 0)
             // IF ending the write operation and going into read_mode
	     begin
		busy_i <= 0;
		read_warning_i <= 0;
		write_counter <= 0;
	     end
	   else
             // ELSE starting another write operation immediately
	     begin
		if ((c_ternary_mode == const_ternary_off && binary_compare(wr_din, rd_din)) 
		    || (c_ternary_mode == const_ternary_std 
			&& ternary_compare(wr_data_mask, wr_din, rd_data_mask, rd_din)) 
		    || (c_ternary_mode == const_ternary_enh 
			&& ternary_compare_xy(wr_data_mask, wr_din, rd_data_mask, rd_din)))
		  //IF read and write data match, flag a read warning
		  read_warning_i <= 1;
		else
		  read_warning_i <= 0;
		
		busy_i <= 1;//Set busy while writing
		write_counter <= 1;
	     end
	 
	 
       endcase // case(CAM_MODE)

  end // always @ (posedge CLK)





   
endmodule // CAM_V6_1

   
