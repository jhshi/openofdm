/*********************************************************************************
$RCSfile: SYNC_FIFO_V5_0.v,v $ $Revision: 1.12 $ $Date: 2008/09/08 20:09:59 $
**********************************************************************************
* Synchronous Fifo  - Verilog Behavioral Model
*****************************************************************************
*
* Filename:     sync_fifo_v5_0.v
*
* Description :  Synchronous FIFO behavioral model
*
*
***********************************************************************************/
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

`timescale 1ns/10ps

/**********************************************************************************
* Declare top-level module
**********************************************************************************/

module SYNC_FIFO_V5_0 (  CLK,
                      SINIT,
                      DIN,
                      WR_EN,
                      RD_EN,
                      DOUT,
                      FULL,
                      EMPTY,
                      RD_ACK,
                      WR_ACK,
                      RD_ERR,
                      WR_ERR,
                      DATA_COUNT 
                       );


/**********************************************************************************
* Parameter Declarations
**********************************************************************************/
  parameter  c_dcount_width          =  9 ; //  width of the dcount . Adjustable by customer
  parameter  c_enable_rlocs          =  0; // 
  parameter  c_has_dcount            =  1 ; // 
  parameter  c_has_rd_ack            =  1; // 
  parameter  c_has_rd_err            =  1; // 
  parameter  c_has_wr_ack            =  1; // 
  parameter  c_has_wr_err            =  1; // 
  parameter  c_memory_type           =  0; //
  parameter  c_ports_differ          =  0; //
  parameter  c_rd_ack_low            =  0; //
  parameter  c_rd_err_low            =  0  ; //   
  parameter  c_read_data_width       =  16  ; //  
  parameter  c_read_depth            =  0  ; //
  parameter  c_write_data_width      =  16 ; //
  parameter  c_write_depth           =  16 ;  //
  parameter  c_wr_ack_low            =  1 ; // 
  parameter  c_wr_err_low            =  1 ; // 




parameter addr_max      = (c_write_depth == 16 ? 4:
                          (c_write_depth == 32 ? 5:
                          (c_write_depth == 64 ? 6 :
                          (c_write_depth == 128 ? 7 :
                          (c_write_depth == 256 ? 8 :
                          (c_write_depth == 512 ? 9 :
                          (c_write_depth == 1024 ? 10 :
                          (c_write_depth == 2048 ? 11 :
                          (c_write_depth == 4096 ? 12 :
                          (c_write_depth == 8192 ? 13 :
                          (c_write_depth == 16384 ? 14 :
                          (c_write_depth == 32768 ? 15 :
                          (c_write_depth == 65536 ? 16 : 6)))))))))))));

/***********************************************************************************
* Input and Output Declarations
***********************************************************************************/
input                       CLK;      // CLK Signal.
input                       SINIT;    // High Asserted Reset signal.
input [(c_write_data_width-1):0]      DIN;  // Data Into FIFO.
input                       WR_EN;    // Write into FIFO Signal.
input                       RD_EN;    // Read From FIFO Signal.

output [(c_read_data_width-1):0]      DOUT;   // FIFO Data out.
output                      FULL;     // FIFO Full indicating signal.
output                      EMPTY;    // FIFO Empty indicating signal.
output                      RD_ACK ;  // Read Acknowledge signal
output                      WR_ACK ;  // Write Acknowledge signal
output                      RD_ERR ; // Rejection of RD_EN active on prior clock edge
output                      WR_ERR ; // Rejection of WR_EN active on prior clock edge
output [(c_dcount_width-1):0]        DATA_COUNT ;


reg                FULL;
reg                EMPTY;
wire               RD_ACK_internal ;
wire               WR_ACK_internal ;
wire               RD_ERR_internal ;
wire               WR_ERR_internal ;
wire [(c_dcount_width-1):0] DATA_COUNT_int ;
reg [(c_dcount_width-1):0] DATA_COUNT ;

integer k,j ;



reg                rd_ack_int ;
reg                rd_err_int ;
reg                wr_ack_int ;
reg                wr_err_int ;

integer            N ;

reg    [addr_max:0]       fcounter;    // counter indicates num of data in FIFO
reg    [addr_max:0]       fcounter_max ; // value of fcounter OR with MSB of fcounter       
reg    [(addr_max-1):0]   rd_ptr;      // current read pointer.
reg    [(addr_max-1):0]   wr_ptr;      // current write pointer.
wire   [(c_write_data_width-1):0]    memory_dataout; // Data Out from the  MemBlk
wire   [(c_write_data_width-1):0]    memory_datain ;  // Data into the  MemBlk

wire   write_allow = (WR_EN && (!FULL)) ;
wire   read_allow = (RD_EN && (!EMPTY)) ;

assign DOUT     = memory_dataout;  
assign memory_datain = DIN;

assign RD_ACK_internal = (c_rd_ack_low == 0 )  ? rd_ack_int : (!rd_ack_int) ;
assign WR_ACK_internal = (c_wr_ack_low == 0 )  ? wr_ack_int : (!wr_ack_int) ;
assign RD_ERR_internal = (c_rd_err_low == 0 )  ? rd_err_int : (!rd_err_int) ;
assign WR_ERR_internal = (c_wr_err_low == 0 )  ? wr_err_int : (!wr_err_int) ;

// assign DATA_COUNT = (c_has_dcount == 0 ) ? {c_dcount_width{1'bX}} : DATA_COUNT_int ;
assign RD_ACK     = (c_has_rd_ack == 0 ) ? 1'bX : RD_ACK_internal ;
assign WR_ACK     = (c_has_wr_ack == 0 ) ? 1'bX : WR_ACK_internal ;
assign RD_ERR     = (c_has_rd_err == 0 ) ? 1'bX : RD_ERR_internal ;
assign WR_ERR     = (c_has_wr_err == 0 ) ? 1'bX : WR_ERR_internal ;     


    MEM_BLK_V5_0 # (addr_max, c_write_data_width, c_write_depth)  memblk(.clk(CLK),
                                                                         .write_en(write_allow),
                                                                         .read_en(read_allow),
                                                                         .rd_addr(rd_ptr),
                                                                         .wr_addr(wr_ptr),
                                                                         .data_in(memory_datain),
                                                                         .data_out(memory_dataout),
                                                                         .rst(SINIT)
                                                                          ) ;

/***********************************************************************************
* Initialize the outputs for simulation purposes
***********************************************************************************/

    initial begin

        wr_ack_int = 0 ;

        rd_ack_int = 0 ;

        rd_err_int = 0 ; 

        wr_err_int = 0 ; 
        
        FULL = 0 ;
        EMPTY = 1 ;  

        for (k = 0; k < c_dcount_width; k = k + 1)
            DATA_COUNT[k] = 0 ;
    end

// DATA_COUNT assignment

always @(fcounter_max)
begin
  if  ((c_has_dcount == 1) && (c_dcount_width <= addr_max ) ) 
  begin
    for (j=(addr_max - c_dcount_width); j<addr_max; j=j+1 )
     DATA_COUNT[j-(addr_max - c_dcount_width)] = fcounter_max[j];
  end
end

always @(fcounter) 
begin 
  if ((c_has_dcount == 1) && (c_dcount_width ==  addr_max + 1 ))  
     DATA_COUNT = fcounter;
end 


/***********************************************************************************
* Handshaking signals
***********************************************************************************/
// Read Ack logic

always @(posedge CLK )
begin
    if (SINIT) 
        rd_ack_int <= 0 ;
    else
        rd_ack_int <= RD_EN && (! EMPTY);
end 

// Write Ack logic

always @(posedge CLK ) 
begin 
    if (SINIT)   
       wr_ack_int <= 0 ; 
    else 
       wr_ack_int <= WR_EN && (! FULL );
end 

// Read Error handshake signal logic

always @(posedge CLK )
begin
    if (SINIT)
       rd_err_int <= 0 ;
    else
       rd_err_int <= RD_EN &&  EMPTY;
end

// Write Error handshake signal logic 

always @(posedge CLK ) 
begin
    if (SINIT)
       wr_err_int <= 0 ; 
    else    
       wr_err_int <= WR_EN &&  FULL; 
end 

always @(fcounter)
begin

for (N = 0 ; N<= addr_max ; N = N + 1)
    fcounter_max[N] = fcounter[addr_max] || fcounter[N] ;


end 


/***********************************************************************************
 * Control circuitry for FIFO. If SINIT signal is asserted
 * all the counters are set to 0. IF write only the write counter
 * is incremented else if read only read counter is incremented
 * else if both, read and write counters are incremented.
 * fcounter indicates the num of items in the fifo. Write only
 * increments  the fcounter, read only decrements the counter and
 * read && write doen't change the counter value.
 ***********************************************************************************/

// Read Counter

always @(posedge CLK )
begin
   if (SINIT) 
      rd_ptr <= 0;
   else begin
      if (read_allow == 1'b1) begin
         if ( rd_ptr == (c_write_depth -1 ))  // Need to support any arbitrary depth
            rd_ptr <= 0 ;
         else
            rd_ptr <= rd_ptr + 1 ;
      end
   end
end

// Write Counter
 
always @(posedge CLK )
begin
   if (SINIT) 
      wr_ptr <= 0;
   else begin 
      if (write_allow == 1'b1) begin
         if  ( wr_ptr == (c_write_depth -1 )) // Need to support any arbitrary depth
             wr_ptr <= 0 ;
         else
             wr_ptr <= wr_ptr + 1 ;
      end 
   end   
end 

// Fifo Content Counter

always @(posedge CLK )
begin
   if (SINIT) 
      fcounter <= 0;
   else begin
      case ({write_allow, read_allow})
         2'b00 : fcounter <= fcounter ;
         2'b01 : fcounter <= fcounter - 1 ;
         2'b10 : fcounter <= fcounter + 1 ;
         2'b11 : fcounter <= fcounter ;
      endcase
   end
end 


 

/***********************************************************************************
 * EMPTY signal indicates FIFO Empty Status. When SINIT is active, EMPTY is   
 * asserted indicating the FIFO is empty. After the First Data is
 * put into the FIFO the signal is deasserted.
 **********************************************************************************/

always @(posedge CLK )
begin

  if (SINIT)
     EMPTY <= 1'b1;

  else begin

     if ( ( (fcounter==1) && RD_EN && (!WR_EN)) || ( (fcounter == 0) && (!WR_EN) ) )

          EMPTY <= 1'b1;
 
     else 

          EMPTY <= 1'b0;
  end
end
 


/***********************************************************************************
 * FULL Flag logic
 **********************************************************************************/

always @(posedge CLK )
begin
 
  if (SINIT)
 
    FULL <= 1'b0;
 
  else begin
 
    if (((fcounter == c_write_depth) && (!RD_EN) ) || ((fcounter == c_write_depth-1) && WR_EN && (!RD_EN)))
       
       FULL <= 1'b1;
 
    else 
    
       FULL <= 1'b0;
    
  end
end
       
endmodule




module MEM_BLK_V5_0( clk,
                     write_en,
                     read_en,
                     wr_addr,
                     rd_addr,
                     data_in,
                     data_out,
                     rst
                   );

parameter addr_value = 4  ;
parameter data_width = 16 ;
parameter mem_depth      = 16 ;


input                    clk;       // input clk.
input                    write_en;    // Write Signal to put datainto fifo.
input                    read_en ;
input  [(addr_value-1):0]  wr_addr;   // Write Address.
input  [(addr_value-1):0]  rd_addr;   // Read Address.
input  [(data_width-1):0]   data_in;   // DataIn in to Memory Block
input                    rst ;

output [(data_width-1):0]   data_out;  // Data Out from the Memory Block(FIFO)

reg  [(data_width-1):0] data_out;  

reg    [(data_width-1):0] FIFO[0:(mem_depth-1)];


initial begin
data_out = 0 ;
end




always @(posedge clk)
begin
   if (rst == 1'b1)
      data_out <= 0 ; 
   else
      begin
        if (read_en == 1'b1) 
          data_out  <= FIFO[rd_addr];
      end
end

always @(posedge clk)
begin
   if(write_en ==1'b1)
      FIFO[wr_addr] <= data_in;
end

endmodule


