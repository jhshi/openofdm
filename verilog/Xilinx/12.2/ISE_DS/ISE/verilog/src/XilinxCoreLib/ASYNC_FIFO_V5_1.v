/******************************************************************************
 *
 * $RCSfile: ASYNC_FIFO_V5_1.v,v $ $Revision: 1.15 $ $Date: 2008/09/08 20:05:11 $
 *
 ******************************************************************************
 *
 * Asynchronous FIFO V5_1 - Verilog Behavioral Model
 *
 ******************************************************************************
 *
 * Filename: ASYNC_FIFO_V5_1.v
 *
 * Description: 
 *  The behavioral model for the asynchronous fifo.
 *                      
 ******************************************************************************/

//  Copyright(C) 2003 by Xilinx, Inc. All rights reserved.
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
//  of this text at all times. (c) Copyright 1995-2003 Xilinx, Inc.
//  All rights reserved.


`timescale 1ns/10ps


/******************************************************************************
 * Declare top-level module 
 ******************************************************************************/
module ASYNC_FIFO_V5_1 (DIN, WR_EN, WR_CLK, RD_EN, RD_CLK, AINIT, DOUT, 
                        FULL, EMPTY, ALMOST_FULL, ALMOST_EMPTY, 
                        WR_COUNT, RD_COUNT, RD_ACK, RD_ERR, WR_ACK, WR_ERR);


/*************************************************************************
 * Definition of Ports
 * DIN         : Input data bus for the fifo.
 * DOUT        : Output data bus for the fifo.
 * AINIT       : Asynchronous Reset for the fifo.
 * WR_EN       : Write enable signal.
 * WR_CLK      : Write Clock.
 * FULL        : Indicates a full condition in the FIFO. Full is asserted 
 *               when no more words can be written into the FIFO.
 * ALMOST_FULL : Indicates that the FIFO only has room for one additional
 *               word to be written before it is full.
 * WR_ACK      : Acknowledgement of a successful write on the 
 *               previous clock edge
 * WR_ERR      : The write operation on the previous clock edge was
 *               unsuccessful due to an overflow condition
 * WR_COUNT    : Number of data words in fifo(synchronous to WR_CLK)
 *               This is only the MSBs of the count value.
 * RD_EN       : Read enable signal.
 * RD_CLK      : Read Clock.
 * EMPTY       : Indicates an empty condition in the FIFO. Empty is
 *               asserted when no more words can be read from the FIFO.
 * ALMOST_EMPTY: Indicates that the FIFO only has one word remaining 
 *               in the FIFO. One additional read will cause an 
 *               EMPTY condition.
 * RD_ACK      : Acknowledgement of a successful read on the 
 *               previous clock edge
 * RD_ERR      : The read operation on the previous clock edge was
 *               unsuccessful due to an underflow condition
 * RD_COUNT    : Number of data words in fifo(synchronous to RD_CLK)
 *               This is only the MSBs of the count value.
 *************************************************************************/


//Declare user parameters and their defaults
parameter C_DATA_WIDTH		= 8;
parameter C_ENABLE_RLOCS	= 0;
parameter C_FIFO_DEPTH 		= 511;
parameter C_HAS_ALMOST_EMPTY	= 1;
parameter C_HAS_ALMOST_FULL 	= 1;
parameter C_HAS_RD_ACK	        = 1;
parameter C_HAS_RD_COUNT        = 1;
parameter C_HAS_RD_ERR	        = 1;
parameter C_HAS_WR_ACK	        = 1;
parameter C_HAS_WR_COUNT        = 1;
parameter C_HAS_WR_ERR	        = 1;
parameter C_RD_ACK_LOW	        = 0;
parameter C_RD_COUNT_WIDTH      = 2;
parameter C_RD_ERR_LOW	        = 0;
parameter C_USE_BLOCKMEM        = 1;
parameter C_WR_ACK_LOW	        = 0;
parameter C_WR_COUNT_WIDTH      = 2;
parameter C_WR_ERR_LOW	        = 0;

//Declare input and output ports
input  [C_DATA_WIDTH-1 : 0] DIN;
input  WR_EN;
input  WR_CLK;
input  RD_EN;
input  RD_CLK;
input  AINIT;
output [C_DATA_WIDTH-1 : 0] DOUT;		
output FULL;
output EMPTY;
output ALMOST_FULL;
output ALMOST_EMPTY;
output [C_WR_COUNT_WIDTH-1 : 0] WR_COUNT;
output [C_RD_COUNT_WIDTH-1 : 0] RD_COUNT;
output RD_ACK;
output RD_ERR;
output WR_ACK;
output WR_ERR;

/*************************************************************************
 * Parameters used as constants
 *************************************************************************/
//length of the linked list which will simulate a FIFO
parameter listlength = C_FIFO_DEPTH*(C_DATA_WIDTH+1);   

/*************************************************************************
  * Internal regs (for always blocks) and wires (for assign statements)
 *************************************************************************/

//Linked list to be used as an ideal FIFO
reg [listlength:0] list;

   
//pulse asserted at posedge of WR_CLK
reg wr_pulse;
   
//pulse asserted at posedge of RD_CLK
reg rd_pulse;                  

   
//pulse asserted at conclusion of write operation
reg wr_pulse_ack;                
  
//pulse asserted at conclusion of read operation
reg rd_pulse_ack;                
  

//Special ideal FIFO signals
reg [C_DATA_WIDTH-1:0] ideal_dout;
reg ideal_wr_ack;
reg ideal_rd_ack;
reg ideal_wr_err;
reg ideal_rd_err;
reg ideal_full;
reg ideal_empty;
reg ideal_almost_full;
reg ideal_almost_empty;
   

//Integer value for the number of words in the FIFO
reg [31 : 0] ideal_wr_count_tmp;
reg [31 : 0] ideal_rd_count_tmp;
   
//Integer value representing the MSBs of the counts
reg [31 : 0] ideal_wr_count_int;
reg [31 : 0] ideal_rd_count_int;
   
//MSBs of the counts
reg [C_WR_COUNT_WIDTH-1 : 0] ideal_wr_count;
reg [C_RD_COUNT_WIDTH-1 : 0] ideal_rd_count;

   
/*************************************************************************
 * binary :
 *  Calculates how many bits are needed to represent the input number
 *************************************************************************/
  function [31:0] binary;
    input [31:0] inval;
    integer power;
    integer bits;
  begin  
    power = 1;
    bits  = 0;
    while (power <= inval)
    begin
      power = power * 2;
      bits  = bits + 1;      
    end //while
    binary = bits;
  end
  endfunction //binary
  
/************************************************************************
 * listsize:
 * Returns number of entries in the linked list
 *************************************************************************/
  function [31:0] listsize;
    input [((C_DATA_WIDTH+1)*C_FIFO_DEPTH):0] inarray;
    reg condition;
    integer i;
    integer j;
  begin
    condition = 1'b0;
    i = 0;
    j = 0;
    while (condition == 1'b0)
    begin
      j = (C_DATA_WIDTH+1)*i;
      if(inarray[j] == 1'b0)
        condition  = 1'b1;
      i = i + 1;
    end //while
    listsize = (i-1);
  end
  endfunction //listsize
      
/************************************************************************
 * addlist :
 * Add an entry to the end of the linked list
 *************************************************************************/
  function [((C_DATA_WIDTH+1)*C_FIFO_DEPTH):0] addlist;
    input [((C_DATA_WIDTH+1)*C_FIFO_DEPTH):0] inarray;
    input [C_DATA_WIDTH-1:0] inword;
    reg [((C_DATA_WIDTH+1)*C_FIFO_DEPTH):0] temp;
    integer i;
    integer j;
  begin
    temp = 1'b0;
    i = listsize(inarray);
    j = (i*(C_DATA_WIDTH+1));
    temp[C_DATA_WIDTH:0] = {inword, 1'b1};
    temp = temp << j; 
    addlist = temp | inarray;
  end
  endfunction //addlist

/************************************************************************
 * readlist :
 * Non-destructive read from the head of the linked list
 *************************************************************************/
  function [C_DATA_WIDTH-1:0] readlist;
    input [((C_DATA_WIDTH+1)*C_FIFO_DEPTH):0] inarray;
  begin
    readlist = inarray[C_DATA_WIDTH:1];
  end
  endfunction //readlist  

/************************************************************************
 * removelist :
 * Remove/Delete entry from head of the linked list
 *************************************************************************/
  function [((C_DATA_WIDTH+1)*C_FIFO_DEPTH):0] removelist;
    input [((C_DATA_WIDTH+1)*C_FIFO_DEPTH):0] inarray;
  begin
    removelist = inarray >> (C_DATA_WIDTH+1);
  end
  endfunction //removelist
    

/*************************************************************************
 * Initialize Signals
 *************************************************************************/
  initial
  begin
   list     = 0;
   wr_pulse = 1'b0;
   rd_pulse = 1'b0;
   wr_pulse_ack = 1'b0;
   rd_pulse_ack = 1'b0;

   ideal_dout   = 0;
   ideal_wr_ack = 1'b0;
   ideal_rd_ack = 1'b0;
   ideal_wr_err = 1'b0;
   ideal_rd_err = 1'b0;
   ideal_full   = 1'b1;
   ideal_empty  = 1'b1;
   ideal_almost_full  = 1'b1;
   ideal_almost_empty = 1'b1;
   ideal_wr_count = 0;
   ideal_rd_count = 0;
  end


/*************************************************************************
 * Assign Internal ideal signals to output ports
 *************************************************************************/
assign DOUT         = ideal_dout;
assign FULL         = ideal_full;
assign EMPTY        = ideal_empty;
assign ALMOST_FULL  = ideal_almost_full;
assign ALMOST_EMPTY = ideal_almost_empty;
assign WR_COUNT     = ideal_wr_count;
assign RD_COUNT     = ideal_rd_count;

//Handshaking signals can be active low, depending on _LOW parameters
assign WR_ACK       = ideal_wr_ack ? !C_WR_ACK_LOW : C_WR_ACK_LOW;
assign WR_ERR       = ideal_wr_err ? !C_WR_ERR_LOW : C_WR_ERR_LOW;
assign RD_ACK       = ideal_rd_ack ? !C_RD_ACK_LOW : C_RD_ACK_LOW;
assign RD_ERR       = ideal_rd_err ? !C_RD_ERR_LOW : C_RD_ERR_LOW;

   
/*************************************************************************
 * Generate read and write pulse signals
 * 
 * These pulses are instantaneous pulses which occur only in delta-time,
 * and are never active for any amount of simulation time.
 * 
 * The pulses handshake with each other and the wr_pulse_ack and rd_pulse_ack
 * signals to guarantee that they can never occur at the same time, and
 * to guarantee that a write or read operation completes before the other
 * can begin.
 *************************************************************************/

/********wr_pulse generator*************/
  always @(posedge WR_CLK)
  begin : gen_wr_pulse
    //Wait until rd_pulse is 0 before setting the wr_pulse
    // to make sure that they can't BOTH be active simultaneously.
    wait (!rd_pulse && !rd_pulse_ack) 
      wr_pulse = 1'b1;
    
    //Wait until read/write always block replies before clearing wr_pulse
    wait (wr_pulse_ack) 
      wr_pulse = 1'b0;

  end // wr_pulse generator

   
/********rd_pulse generator*************/
  always @(posedge RD_CLK)
  begin : gen_rd_pulse
    //Wait until wr_pulse is 0 before setting the rd_pulse
    // to make sure that they can't BOTH be active simultaneously.
    wait (!wr_pulse && !wr_pulse_ack) 
      rd_pulse = 1'b1;

    //Wait until read/write always block replies before clearing rd_pulse
    wait (rd_pulse_ack) 
      rd_pulse = 1'b0;

  end // rd_pulse generator


   
/*************************************************************************
 * Read and Write from FIFO (FIFO is implemented by a linked list)
 * 
 * The following are the possible scenarios for the FIFO:
 *
 * 1) AINIT=1, in which case a reset condition occurs, all outputs and
 *    internal states are cleared, and the triggering pulse is cleared.
 * 
 * 2) This process was triggered with ONLY a wr_pulse, rd_pulse is 0.
 *    This is a normal case. Only a write operation is performed.
 * 
 * 3) This process was triggered with ONLY a rd_pulse, wr_pulse is 0.
 *    This is a normal case. Only a read operation is performed.
 * 
 * 4) This process was triggered with ONLY a wr_pulse, but rd_pulse is also 1.
 *    The pulse generator processes (above) require that one pulse be cleared
 *    before the other can be activated. This should prevent this case from 
 *    occurring.
 * 
 * 5) This process was triggered with ONLY a rd_pulse, but wr_pulse is also 1.
 *    The pulse generator processes (above) require that one pulse be cleared
 *    before the other can be activated. This should prevent this case from 
 *    occurring.
 * 
 * 6) This process was triggered with BOTH a wr_pulse and a rd_pulse
 *    simultaneously, and was only triggerred once. It was found through
 *    experimentation that this case is actually possible.
 *    This case is handled explicitly below as an error.
 *    Handshaking between pulse generation processes, and the requirement
 *    that a rd_pulse_ack or wr_pulse_ack must be asserted before continuing
 *    should prevent this from occuring.
 *************************************************************************/
   
   always @(posedge wr_pulse or posedge rd_pulse or posedge AINIT)
     begin : gen_fifo
	
	/****** Reset fifo (case 1)***************************************/
	if (AINIT == 1'b1)
	  begin
	     list   <= 0;
	     ideal_dout <= 0;
	     ideal_wr_ack <= 1'b0;
	     ideal_rd_ack <= 1'b0;
	     ideal_wr_err <= 1'b0;
	     ideal_rd_err <= 1'b0;
	     ideal_full <= 1'b1;
	     ideal_almost_full <= 1'b1;
	     ideal_empty <= 1'b1;
	     ideal_almost_empty <= 1'b1;
	     ideal_wr_count <= 0;
	     ideal_rd_count <= 0;
	     
	     //If either pulse is set, acknowledge and clear it
	     if ((wr_pulse == 1'b1) && (rd_pulse == 1'b1))
	       $display ("ERROR: Illegal operation internal to async_fifo_v5_1 Verilog model.");
	     
	     if (wr_pulse == 1'b1)
	       begin
		  wr_pulse_ack = 1'b1;
		  wait (!wr_pulse) 
                    wr_pulse_ack = 1'b0;
	       end
	     
	     if (rd_pulse == 1'b1)
	       begin
		  rd_pulse_ack = 1'b1;
		  wait (!rd_pulse) 
                    rd_pulse_ack = 1'b0;
	       end
	     
	     
	  end // if (AINIT == 1'b1)
	
	
	else  //AINIT == 1'b0
	  
	  begin
	     
	     /*********** Error: read AND write to the fifo (case 5) ********/
	     if ((wr_pulse == 1'b1) && (rd_pulse == 1'b1))
	       $display ("ERROR: Illegal operation internal to async_fifo_v5_1 Verilog model.");
	     
	     /****** Write operation (case 2) *******************************/
	     if (wr_pulse == 1'b1)
	       begin
		  //If this is a write, handle the write by adding the value
		  // to the linked list, and updating all outputs appropriately
		  if (WR_EN == 1'b1)
		    begin
		       
		       //If the FIFO is completely empty, but we are 
		       // successfully  writing to it
		       if (listsize(list) == 0)
			 begin
			    //Add value on DIN port to linked list
			    list         = addlist(list,DIN);
			    //Write successful, so issue acknowledge
			    // and no error
			    ideal_wr_ack = 1'b1;
			    ideal_wr_err = 1'b0;
			    //Not even close to full.
			    ideal_full   = 1'b0;
			    ideal_almost_full  = 1'b0;
			    //Writing, so not empty.
			    ideal_empty  = 1'b0;
			    // Will still be almost empty after 1 write
			    ideal_almost_empty = 1'b1;
			    
			    ideal_wr_count_tmp = listsize(list);
			    ideal_wr_count_int = (listsize(list) << C_WR_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_wr_count     = ideal_wr_count_int[C_WR_COUNT_WIDTH-1:0];
			 end //(listsize(list) == 0)
		       
		       //If the FIFO is not close to being full, and not empty
		       else if ((listsize(list) < C_FIFO_DEPTH-2) && (listsize(list)>=1))
			 begin
			    //Add value on DIN port to linked list
			    list         = addlist(list,DIN);
			    //Write successful, so issue acknowledge
			    // and no error
			    ideal_wr_ack = 1'b1;
			    ideal_wr_err = 1'b0;
			    //Not even close to full.
			    ideal_full   = 1'b0;
			    ideal_almost_full  = 1'b0;
			    //not close to empty
			    ideal_empty  = 1'b0;
			    //Was not empty, so this write will make FIFO 
			    // no longer almost_empty
			    ideal_almost_empty = 1'b0;
			    
			    ideal_wr_count_tmp = listsize(list);
			    ideal_wr_count_int = (listsize(list) << C_WR_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_wr_count     = ideal_wr_count_int[C_WR_COUNT_WIDTH-1:0];
			 end // if
		       
		       //If the FIFO is 2 from full
		       else if (listsize(list) == C_FIFO_DEPTH-2)
			 begin
			    //Add value on DIN port to linked list
		            list         = addlist(list,DIN);
			    //Write successful, so issue acknowledge
			    // and no error
			    ideal_wr_ack = 1'b1;
			    ideal_wr_err = 1'b0;
			    //Still 2 from full
			    ideal_full   = 1'b0;
			    //2 from full, and writing, so set almost_full
			    ideal_almost_full  = 1'b1;
			    //not even close to empty
			    ideal_empty  = 1'b0;
			    ideal_almost_empty = 1'b0;
			    
			    ideal_wr_count_tmp = listsize(list);
			    ideal_wr_count_int = (listsize(list) << C_WR_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_wr_count     = ideal_wr_count_int[C_WR_COUNT_WIDTH-1:0];
			 end // if (listsize(list) == C_FIFO_DEPTH-2)
		       
		       //If the FIFO is one from full
		       else if (listsize(list) == C_FIFO_DEPTH-1)
			 begin
			    //Add value on DIN port to linked list
		            list         = addlist(list,DIN);
			    //Write successful, so issue acknowledge
			    // and no error
			    ideal_wr_ack = 1'b1;
			    ideal_wr_err = 1'b0;
			    //This write is CAUSING the FIFO to go full
			    ideal_full   = 1'b1;
			    ideal_almost_full  = 1'b1;
			    //Not even close to empty
			    ideal_empty  = 1'b0;
			    ideal_almost_empty = 1'b0;
			    
			    ideal_wr_count_tmp = listsize(list);
			    ideal_wr_count_int = (listsize(list) << C_WR_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_wr_count     = ideal_wr_count_int[C_WR_COUNT_WIDTH-1:0];
			 end // if (listsize(list) == C_FIFO_DEPTH-1)
		       
 		       //If the FIFO is full, do NOT perform the write, 
		       // update flags accordingly
		       else if (listsize(list) >= C_FIFO_DEPTH)
			 begin
			    //write unsuccessful - do not change contents
		            list         = list;
			    //Do not acknowledge the write
			    ideal_wr_ack = 1'b0;
			    //throw an overflow error
			    ideal_wr_err = 1'b1;
			    //Reminder that FIFO is still full
			    ideal_full   = 1'b1;
			    ideal_almost_full   = 1'b1;
			    //Not even close to empty
 			    ideal_empty  = 1'b0;
			    ideal_almost_empty  = 1'b0;
			    
			    ideal_wr_count_tmp = listsize(list);
			    ideal_wr_count_int = (listsize(list) << C_WR_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_wr_count = ideal_wr_count_int[C_WR_COUNT_WIDTH-1:0];
			 end
		    end //(WR_EN == 1'b1)
		  
		  else //if (WR_EN == 1'b0)
		    begin
		       //If user did not attempt a write, then do not 
		       // give ack or err
		       ideal_wr_ack = 1'b0; 
		       ideal_wr_err = 1'b0;
		       
		       //Implied statements:
		       //ideal_empty = ideal_empty;
		       //ideal_almost_empty = ideal_almost_empty;
		       
		       //Check for full
		       if (listsize(list) > C_FIFO_DEPTH-1)      
			 ideal_full = 1'b1;
		       else
			 ideal_full  = 1'b0;
		       
		       //Check for almost_full
		       if (listsize(list) > C_FIFO_DEPTH-2)      
			 ideal_almost_full  = 1'b1;
		       else
			 ideal_almost_full  = 1'b0;
		       
		       
		       ideal_wr_count_tmp = listsize(list);
		       ideal_wr_count_int = (listsize(list) << C_WR_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
		       ideal_wr_count = ideal_wr_count_int[C_WR_COUNT_WIDTH-1:0];
		    end
		  
		  
		  //Whether it was a write or not, clear the pulse
		  wr_pulse_ack = 1'b1;
		  wait (!wr_pulse) 
                    wr_pulse_ack = 1'b0;
               end
	     
	     
	     /****** Read operation (case 3) **********************************/
	     if (rd_pulse == 1'b1) 
	       begin
		  //If this is a read, handle the read by popping the value off the linked list
		  if (RD_EN == 1'b1) 
		    begin
		       
		       //If the FIFO is completely empty
		       if (listsize(list) <= 0)
			 begin
			    //Do not change the contents of the FIFO
			    list         = list;
			    //Read nothing (0) from the empty FIFO
			    ideal_dout   = 0;
                            //Do not acknowledge the read from empty FIFO
			    ideal_rd_ack = 1'b0;
			    //Throw an underflow error
			    ideal_rd_err = 1'b1;
			    //Not even close to full
			    ideal_full   = 1'b0;
			    ideal_almost_full = 1'b0;
			    //Reminder that FIFO is still empty
			    ideal_empty  = 1'b1; 
			    ideal_almost_empty = 1'b1;
			    
			    ideal_rd_count_tmp = listsize(list);
			    ideal_rd_count_int = (listsize(list) << C_RD_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_rd_count = ideal_rd_count_int[C_RD_COUNT_WIDTH-1:0];
			 end // if (listsize(list) <= 0)
		       
		       //If the FIFO is one from empty
		       else if (listsize(list) == 1)
			 begin
			    //Read top value from the FIFO
			    ideal_dout   = readlist(list);
			    //Pop single value off of linked list
			    list         = removelist(list);
			    //Acknowledge the read from the FIFO, no error
			    ideal_rd_ack = 1'b1;
			    ideal_rd_err = 1'b0;
			    //Not even close to full
 			    ideal_full   = 1'b0;
			    ideal_almost_full = 1'b0;
			    //Note that FIFO is GOING empty
			    ideal_empty  = 1'b1; 
			    ideal_almost_empty = 1'b1; 
			    
			    ideal_rd_count_tmp = listsize(list);
			    ideal_rd_count_int = (listsize(list) << C_RD_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_rd_count = ideal_rd_count_int[C_RD_COUNT_WIDTH-1:0];
			 end // if (listsize(list) == 1)
		       
		       //If the FIFO is two from empty
		       else if (listsize(list) == 2)
			 begin
			    //Read top value from the FIFO
			    ideal_dout   = readlist(list);
			    //Pop single value off of linked list
			    list         = removelist(list);
			    //Acknowledge the read from the FIFO, no error
			    ideal_rd_ack = 1'b1; 
			    ideal_rd_err = 1'b0;
			    //Not even close to full
 			    ideal_full   = 1'b0;
			    ideal_almost_full = 1'b0;
			    //Fifo is not yet empty
			    ideal_empty  = 1'b0;
			    //2 from empty and reading, so going almost_empty
			    ideal_almost_empty = 1'b1; 
			    
			    ideal_rd_count_tmp = listsize(list);
			    ideal_rd_count_int = (listsize(list) << C_RD_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_rd_count = ideal_rd_count_int[C_RD_COUNT_WIDTH-1:0];
			 end // if (listsize(list) == 2)
		       
		       //If the FIFO is not close to being empty
		       else if ((listsize(list) > 2) && (listsize(list)<=C_FIFO_DEPTH-1))
			 begin
			    //Read top value from the FIFO
			    ideal_dout   = readlist(list);
			    //Pop single value off of linked list
			    list         = removelist(list);
			    //Acknowledge the read from the FIFO, no error
			    ideal_rd_ack = 1'b1; 
			    ideal_rd_err = 1'b0;
			    //Reading, so not FULL
 			    ideal_full   = 1'b0;
			    //At least one from full AND reading, so no longer almost_full
			    ideal_almost_full = 1'b0;
			    //Not close to empty
			    ideal_empty  = 1'b0;
			    ideal_almost_empty = 1'b0;
			    
			    ideal_rd_count_tmp = listsize(list);
			    ideal_rd_count_int = (listsize(list) << C_RD_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_rd_count = ideal_rd_count_int[C_RD_COUNT_WIDTH-1:0];
			 end // if ((listsize(list) > 2) && (listsize(list)<=C_FIFO_DEPTH-1))
		       
		       //If the FIFO is completely full, and we are successfully reading from it
		       else if (listsize(list) == C_FIFO_DEPTH)
			 begin
			    //Read top value from the FIFO
			    ideal_dout   = readlist(list);
			    //Pop single value off of linked list
			    list         = removelist(list);
			    //Acknowledge the read from the FIFO, no error
			    ideal_rd_ack = 1'b1; 
			    ideal_rd_err = 1'b0;
			    //Reading, so not FULL
 			    ideal_full   = 1'b0;
			    //Was just full, and this is only the first read
			    ideal_almost_full = 1'b1;
			    //Not close to empty
			    ideal_empty  = 1'b0;
			    ideal_almost_empty = 1'b0;
			    
			    ideal_rd_count_tmp = listsize(list);
			    ideal_rd_count_int = (listsize(list) << C_RD_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
			    ideal_rd_count = ideal_rd_count_int[C_RD_COUNT_WIDTH-1:0];
			 end // if (listsize(list) == C_FIFO_DEPTH)
		       
 		    end //(RD_EN == 1'b1)
		  
		  else //if (RD_EN == 1'b0)
		    begin
		       //If user did not attempt a read, do not give an ack or err
		       ideal_rd_ack = 1'b0;
		       ideal_rd_err = 1'b0;
		       
		       //Check for empty
		       if (listsize(list) < 1)      
			 ideal_empty  = 1'b1;
		       else
			 ideal_empty  = 1'b0;
		       
		       //Check for almost_empty
		       if (listsize(list) < 2)      
			 ideal_almost_empty  = 1'b1;
		       else
			 ideal_almost_empty  = 1'b0;
		       
		       //Implied statements:
		       //ideal_full = ideal_full;
		       //ideal_almost_full  =ideal_almost_full;
		       
		       
		       ideal_rd_count_tmp = listsize(list);
		       ideal_rd_count_int = (listsize(list) << C_RD_COUNT_WIDTH) / (C_FIFO_DEPTH + 1);
		       ideal_rd_count = ideal_rd_count_int[C_RD_COUNT_WIDTH-1:0];
		    end // else: !if(RD_EN == 1'b1)
		  		  
		  
		  //Whether it was a read or not, clear the pulse
		  rd_pulse_ack = 1'b1;
		  wait (!rd_pulse) 
                    rd_pulse_ack = 1'b0;
               end // if (rd_pulse == 1'b1)
	     
	  end // else: !if(AINIT == 1'b1)
     end // block: gen_fifo
   
endmodule // ASYNC_FIFO_V5_1
