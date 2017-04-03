///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2006 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Cyclic Redundancy Check 64-bit Input Simulation Model
// /___/   /\     Filename : CRC64.v
// \   \  /  \    Timestamp : Fri Jun 18 10:57:01 PDT 2004
//  \___\/\___\
//
// Revision:
//    10/04/05 - Initial version.
//    12/06/05 - Added functionality
//    01/09/06 - Added Timing
//    08/18/06 - CR#421781 - CRCOUT initialized to 0 when GSR is high
//    09/14/06 - CR#423918 - CRCRESET is high, CRCOUT is INIT
//    09/27/06 - CR#425422 - added CRCIN in CRC_GEN process to match vhdl
//    07/24/07 - CR#442758 - Use CRCCLK instead of crcclk_int in always block
//    08/16/07 - CR#446564 - Add data_width as part of always block sensitivity list
//    10/22/07 - CR#452418 - Add all to sensitivity list
// End Revision
///////////////////////////////////////////////////////

`timescale  1 ps / 1 ps

`define POLYNOMIAL 32'h04C11DB7	// 00000100 11000001 00011101 10110111

module CRC64 (
	      CRCOUT,
	      CRCCLK,
	      CRCDATAVALID,
	      CRCDATAWIDTH,
	      CRCIN,
	      CRCRESET
	      );
   
   parameter CRC_INIT = 32'hFFFFFFFF;
   
   output [31:0] CRCOUT;
   reg [31:0] crcout_out = 32'h00000000;
   
   input 	 CRCCLK;
   input 	 CRCDATAVALID;
   input [2:0] 	 CRCDATAWIDTH;
   input [63:0]  CRCIN;
   input 	 CRCRESET;

   tri0 	 GSR = glbl.GSR;
   wire 	 gsr_in;
   
   reg [7:0] 	 data_in_32, data_in_24, data_in_16, data_in_8;
   reg [7:0] 	 data_in_64, data_in_56, data_in_48, data_in_40;
   
   reg [2:0] 	 data_width;
   reg 		 data_valid;
   
   reg [31:0] 	 crcd, crcreg;
   reg [72:0] 	 msg;
   reg [63:0] 	 i;
   
   reg [31:0] 	 crcgen_out_32, crcgen_out_24, crcgen_out_16, crcgen_out_8; 
   reg [31:0] 	 crcgen_out_64, crcgen_out_56, crcgen_out_48, crcgen_out_40;
   
//   wire 	 crcclk_int;
   wire 	 crcreset_int;
   
   buf b_gsr (gsr_in, GSR);
   buf b_crcout[31:0] (CRCOUT, crcout_out);
   

   always @(gsr_in, crcreg)
     begin
	if (gsr_in)
	  begin
	     assign crcout_out = 32'h00000000;
	  end
	else 
 	  begin
	     assign crcout_out = {!crcreg[24],!crcreg[25],!crcreg[26],
		    !crcreg[27],!crcreg[28],!crcreg[29],!crcreg[30],
		    !crcreg[31],!crcreg[16],!crcreg[17],!crcreg[18],
		    !crcreg[19],!crcreg[20],!crcreg[21],!crcreg[22],
		    !crcreg[23],
		    !crcreg[8],!crcreg[9],!crcreg[10],!crcreg[11],
		    !crcreg[12],!crcreg[13],!crcreg[14],!crcreg[15],
		    !crcreg[0],!crcreg[1],!crcreg[2],!crcreg[3],
		    !crcreg[4],!crcreg[5],!crcreg[6],!crcreg[7]};
	  end 
     end 
   
   
   
   // Optional inverters for clocks and reset
   assign 	 crcreset_int = CRCRESET;
   
//   assign 	 crcclk_int = (CRCCLK);
   
   // Register input data

   always @ (posedge CRCCLK)
     begin
	data_in_8  <= CRCIN[63:56];
	data_in_16 <= CRCIN[55:48];
	data_in_24 <= CRCIN[47:40];
	data_in_32 <= CRCIN[39:32];
	data_in_40 <= CRCIN[31:24];
	data_in_48 <= CRCIN[23:16];
	data_in_56 <= CRCIN[15:8];
	data_in_64 <= CRCIN[7:0];
	data_valid <= CRCDATAVALID;
	data_width <= CRCDATAWIDTH;
     end 
   

   
   
   // Select between 8-bit, 16-bit, 24-bit, 32-bit, 40-bit, 48-bit, 56-bit and 64-bit based on CRCDATAWIDTH
   
   always @ (crcgen_out_8 or  crcgen_out_16 or crcgen_out_24 or crcgen_out_32 or 
	     crcgen_out_40 or  crcgen_out_48 or crcgen_out_56 or crcgen_out_64 or 
	     crcd or data_width)
     begin
	casex (data_width)
	  3'b000: crcd <= crcgen_out_8;
	  3'b001: crcd <= crcgen_out_16;
	  3'b010: crcd <= crcgen_out_24;
	  3'b011: crcd <= crcgen_out_32;
	  3'b100: crcd <= crcgen_out_40;
	  3'b101: crcd <= crcgen_out_48;
	  3'b110: crcd <= crcgen_out_56;
	  3'b111: crcd <= crcgen_out_64;
	  default: crcd <= crcgen_out_8;
	endcase
     end
   
   // 32-bit CRC internal register
   
   always @ (posedge CRCCLK)
     begin
	
	if (crcreset_int)
	  begin
	     crcreg <= CRC_INIT;
	  end
	else if (!data_valid)
	  begin
	     crcreg <= crcreg;
	  end
	else
	  begin
	     crcreg <= crcd;
	  end
     end
   
   
   //CRC Generator Logic
   
   always @(crcreg or CRCIN or data_width or data_in_8 or data_in_16 or data_in_24 or data_in_32 or data_in_40 or data_in_48 or data_in_56 or data_in_64)

     begin
	
	//CRC-8
	
	if (data_width == 3'b000) begin 
	   msg = {crcreg, 32'h0} ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7],56'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 8; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[72] == 1'b1) begin
		 msg[71:40] = msg[71:40] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_8 = msg[71:40];
	end // if (data_width == 3'b000)
	
	//CRC-16
	
	else if (data_width ==3'b001) begin 
	   msg = {crcreg, 32'h0} ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7],data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], 48'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 16; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[72] == 1'b1) begin
		 msg[71:40] = msg[71:40] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_16 = msg[71:40];
	end
	
	//CRC-24
	
	else if (data_width == 3'b010) begin 
	   msg = {crcreg, 32'h0} ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7], data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], data_in_24[0], data_in_24[1], data_in_24[2], data_in_24[3], data_in_24[4], data_in_24[5], data_in_24[6], data_in_24[7],40'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 24; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[72] == 1'b1) begin
		 msg[71:40] = msg[71:40] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_24 = msg[71:40];
	   
	end // if (data_width == 3'b010)
	
	//CRC-32
	
	else if (data_width == 3'b011) begin 
	   msg = {crcreg, 32'h0} ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7], data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], data_in_24[0], data_in_24[1], data_in_24[2], data_in_24[3], data_in_24[4], data_in_24[5], data_in_24[6], data_in_24[7], data_in_32[0], data_in_32[1], data_in_32[2], data_in_32[3], data_in_32[4], data_in_32[5], data_in_32[6], data_in_32[7], 32'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 32; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[72] == 1'b1) begin
		 msg[71:40] = msg[71:40] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_32 = msg[71:40];
	   
	end // if (data_width == 3'b011)
	
	//CRC-40
	
	else if (data_width == 3'b100) begin 
	   msg = {crcreg, 32'h0} ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7], data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], data_in_24[0], data_in_24[1], data_in_24[2], data_in_24[3], data_in_24[4], data_in_24[5], data_in_24[6], data_in_24[7], data_in_32[0], data_in_32[1], data_in_32[2], data_in_32[3], data_in_32[4], data_in_32[5], data_in_32[6], data_in_32[7], data_in_40[0], data_in_40[1], data_in_40[2], data_in_40[3], data_in_40[4], data_in_40[5], data_in_40[6], data_in_40[7], 24'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 40; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[72] == 1'b1) begin
		 msg[71:40] = msg[71:40] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_40 = msg[71:40];
	   
	end // if (data_width == 3'b100)
	
	//CRC-48
	
	else if (data_width == 3'b101) begin 
	   msg = {crcreg, 32'h0} ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7], data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], data_in_24[0], data_in_24[1], data_in_24[2], data_in_24[3], data_in_24[4], data_in_24[5], data_in_24[6], data_in_24[7], data_in_32[0], data_in_32[1], data_in_32[2], data_in_32[3], data_in_32[4], data_in_32[5], data_in_32[6], data_in_32[7], data_in_40[0], data_in_40[1], data_in_40[2], data_in_40[3], data_in_40[4], data_in_40[5], data_in_40[6], data_in_40[7], data_in_48[0], data_in_48[1], data_in_48[2], data_in_48[3], data_in_48[4], data_in_48[5], data_in_48[6], data_in_48[7], 16'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 48; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[72] == 1'b1) begin
		 msg[71:40] = msg[71:40] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_48 = msg[71:40];
	   
	end // if (data_width == 3'b101)
	
	//CRC-56
	
	else if (data_width == 3'b110) begin 
	   msg = {crcreg, 32'h0} ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7], data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], data_in_24[0], data_in_24[1], data_in_24[2], data_in_24[3], data_in_24[4], data_in_24[5], data_in_24[6], data_in_24[7], data_in_32[0], data_in_32[1], data_in_32[2], data_in_32[3], data_in_32[4], data_in_32[5], data_in_32[6], data_in_32[7], data_in_40[0], data_in_40[1], data_in_40[2], data_in_40[3], data_in_40[4], data_in_40[5], data_in_40[6], data_in_40[7], data_in_48[0], data_in_48[1], data_in_48[2], data_in_48[3], data_in_48[4], data_in_48[5], data_in_48[6], data_in_48[7], data_in_56[0], data_in_56[1], data_in_56[2], data_in_56[3], data_in_56[4], data_in_56[5], data_in_56[6], data_in_56[7], 8'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 56; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[72] == 1'b1) begin
		 msg[71:40] = msg[71:40] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_56 = msg[71:40];
	   
	end // if (data_width == 3'b110)

	//CRC-64
	
	else if (data_width == 3'b111) begin 
	   msg = {crcreg, 32'h0} ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7], data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], data_in_24[0], data_in_24[1], data_in_24[2], data_in_24[3], data_in_24[4], data_in_24[5], data_in_24[6], data_in_24[7], data_in_32[0], data_in_32[1], data_in_32[2], data_in_32[3], data_in_32[4], data_in_32[5], data_in_32[6], data_in_32[7], data_in_40[0], data_in_40[1], data_in_40[2], data_in_40[3], data_in_40[4], data_in_40[5], data_in_40[6], data_in_40[7], data_in_48[0], data_in_48[1], data_in_48[2], data_in_48[3], data_in_48[4], data_in_48[5], data_in_48[6], data_in_48[7], data_in_56[0], data_in_56[1], data_in_56[2], data_in_56[3], data_in_56[4], data_in_56[5], data_in_56[6], data_in_56[7], data_in_64[0], data_in_64[1], data_in_64[2], data_in_64[3], data_in_64[4], data_in_64[5], data_in_64[6], data_in_64[7]};
	   msg = msg << 8;
	   
	   for (i = 0; i < 64; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[72] == 1'b1) begin
		 msg[71:40] = msg[71:40] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_64 = msg[71:40];
	   
	end // if (data_width == 3'b111)
     end // always @ (crcreg)
 
   specify
      (CRCCLK => CRCOUT) = (100, 100);
      specparam PATHPULSE$ = 0;
   endspecify
   
endmodule 


