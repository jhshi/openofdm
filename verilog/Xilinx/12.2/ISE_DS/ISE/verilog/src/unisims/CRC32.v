///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2006 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Cyclic Redundancy Check 32-bit Input Simulation Model
// /___/   /\     Filename : CRC32.v
// \   \  /  \    Timestamp : Fri Jun 18 10:57:01 PDT 2004
//  \___\/\___\
//
// Revision:
//    10/04/05 - Initial version.
//    12/04/05 - Added functionality
//    01/09/06 - Added Timing
//    08/18/06 - CR#421781 - CRCOUT initialized to 0 when GSR is high
//    09/14/06 - CR#423918 - CRCRESET is high, CRCOUT is INIT
//    07/24/07 - CR#442758 - Use CRCCLK instead of crcclk_int in always block
//    08/16/07 - CR#446564 - Add data_width as part of always block sensitivity list
//    10/22/07 - CR#452418 - Add all to sensitivity list
// End Revision
////////////////////////////////////////////////////////////////////////////////

`timescale  1 ps / 1 ps

`define POLYNOMIAL 32'h04C11DB7	// 00000100 11000001 00011101 10110111

module CRC32 (CRCOUT,
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
   input [31:0]  CRCIN;
   input 	 CRCRESET;
   
   tri0 GSR = glbl.GSR;
   
   wire gsr_in;
   
   reg [7:0] data_in_32, data_in_24, data_in_16, data_in_8;
   reg [2:0] data_width;
   reg 	     data_valid;
   
   reg [31:0] 	 crcd, crcreg;
   reg [40:0] 	 msg;
   reg [63:0] 	 i;
   
   reg [31:0] 	 crcgen_out_32, crcgen_out_24, crcgen_out_16, crcgen_out_8;
   wire [31:0] 	 crcgen_in_32, crcgen_in_24, crcgen_in_16, crcgen_in_8;
   
   //wire 	 crcclk_int;
   wire 	 crcreset_int;

   buf b_gsr (gsr_in, GSR);
   buf b_crcout[31:0] (CRCOUT, crcout_out);

   always @(gsr_in, crcreg)
     begin
	if (gsr_in == 1'b1)
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
	  end // if (gsr_in == 1'b0)
     end
   
   
	
	
   
   // Optional inverters for clocks and reset
   
   assign 	 crcreset_int = CRCRESET;
   
   //assign 	 crcclk_int = (CRCCLK);
   

   // Register input data 
   
   always @ (posedge CRCCLK)
     begin
	data_in_8  <= CRCIN[31:24];
	data_in_16 <= CRCIN[23:16];
	data_in_24 <= CRCIN[15:8];
	data_in_32 <= CRCIN[7:0];
	data_valid <= CRCDATAVALID;
	data_width <= CRCDATAWIDTH;
     end
   
   
   // Select between CRC8, CRC16, CRC24, CRC32 based on CRCDATAWIDTH
   
   always @ (crcgen_out_8 or  crcgen_out_16 or crcgen_out_24 or crcgen_out_32 or crcd or data_width)
     begin
	casex (data_width)
	  3'b000: crcd <= crcgen_out_8;
	  3'b001: crcd <= crcgen_out_16;
	  3'b010: crcd <= crcgen_out_24;
	  3'b011: crcd <= crcgen_out_32;
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
   

   // CRC Generator Logic
   
   always @(crcreg or CRCIN or data_width or data_in_8 or data_in_16 or data_in_24 or data_in_32)

     begin

	// CRC-8
	
	if (data_width == 3'b000) begin 
	   msg = crcreg ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7],24'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 8; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[40] == 1'b1) begin
		 msg[39:8] = msg[39:8] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_8 = msg[39:8];
	end 

	// CRC-16
	
	else if (data_width == 3'b001) begin 
	   msg = crcreg ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7],data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], 16'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 16; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[40] == 1'b1) begin
		 msg[39:8] = msg[39:8] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_16 = msg[39:8];
	end 
	
	//CRC-24
	
	else if (data_width == 3'b010) begin 
	   msg = crcreg ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7], data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], data_in_24[0], data_in_24[1], data_in_24[2], data_in_24[3], data_in_24[4], data_in_24[5], data_in_24[6], data_in_24[7],8'h0};
	   msg = msg << 8;
	   
	   for (i = 0; i < 24; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[40] == 1'b1) begin
		 msg[39:8] = msg[39:8] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_24 = msg[39:8];
	   
	end 
	
	//CRC-32
	
	else if (data_width == 3'b011) begin 
	   msg = crcreg ^ {data_in_8[0], data_in_8[1], data_in_8[2], data_in_8[3], data_in_8[4], data_in_8[5], data_in_8[6], data_in_8[7], data_in_16[0], data_in_16[1], data_in_16[2], data_in_16[3], data_in_16[4], data_in_16[5], data_in_16[6], data_in_16[7], data_in_24[0], data_in_24[1], data_in_24[2], data_in_24[3], data_in_24[4], data_in_24[5], data_in_24[6], data_in_24[7], data_in_32[0], data_in_32[1], data_in_32[2], data_in_32[3], data_in_32[4], data_in_32[5], data_in_32[6], data_in_32[7]};
	   msg = msg << 8;
	   
	   for (i = 0; i < 32; i = i + 1) begin
	      msg = msg << 1;
	      if (msg[40] == 1'b1) begin
		 msg[39:8] = msg[39:8] ^ `POLYNOMIAL;
	      end
	   end
	   crcgen_out_32 = msg[39:8];
	   
	end 
	
     end // always @ (crcreg)
   
   
   specify
      (CRCCLK => CRCOUT) = (100, 100);
      specparam PATHPULSE$ = 0;
   endspecify
   
endmodule 

