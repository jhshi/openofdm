// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/FIFO36_EXP.v,v 1.12 2007/06/15 20:58:41 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  36K-Bit FIFO
// /___/   /\     Filename : FIFO36_EXP.v
// \   \  /  \    Timestamp : Tues July 26 16:44:06 PST 2005
//  \___\/\___\
//
// Revision:
//    07/26/05 - Initial version.
//    06/14/07 - Implemented high performace version of the model.
// End Revision

`timescale 1 ps/1 ps

module FIFO36_EXP (ALMOSTEMPTY, ALMOSTFULL, DO, DOP, EMPTY, FULL, RDCOUNT, RDERR, WRCOUNT, WRERR,
	       DI, DIP, RDCLKL, RDCLKU, RDEN, RDRCLKL, RDRCLKU, RST, WRCLKL, WRCLKU, WREN);

    parameter ALMOST_EMPTY_OFFSET = 13'h0080;
    parameter ALMOST_FULL_OFFSET = 13'h0080;
    parameter integer DATA_WIDTH = 4;
    parameter integer DO_REG = 1;
    parameter EN_SYN = "FALSE";
    parameter FIRST_WORD_FALL_THROUGH = "FALSE";
    parameter SIM_MODE = "SAFE";
 
    output ALMOSTEMPTY;
    output ALMOSTFULL;
    output [31:0] DO;
    output [3:0] DOP;
    output EMPTY;
    output FULL;
    output [12:0] RDCOUNT;
    output RDERR;
    output [12:0] WRCOUNT;
    output WRERR;

    input [31:0] DI;
    input [3:0] DIP;
    input RDCLKL;
    input RDCLKU;
    input RDEN;
    input RDRCLKL;
    input RDRCLKU;
    input RST;
    input WRCLKL;
    input WRCLKU;
    input WREN;

    tri0 GSR = glbl.GSR;

    wire [31:0] dangle_out32;
    wire [3:0] dangle_out4;
    wire [7:0] dangle_out8;
    wire dangle_out;
    
    AFIFO36_INTERNAL INT_FIFO (.ALMOSTEMPTY(ALMOSTEMPTY), .ALMOSTFULL(ALMOSTFULL), .DBITERR(dangle_out), .DO({dangle_out32,DO}), .DOP({dangle_out4,DOP}), .ECCPARITY(dangle_out8), .EMPTY(EMPTY), .FULL(FULL), .RDCOUNT(RDCOUNT), .RDERR(RDERR), .SBITERR(dangle_out), .WRCOUNT(WRCOUNT), .WRERR(WRERR),
			      .DI({32'b0,DI}), .DIP({4'b0,DIP}), .RDCLK(RDCLKL), .RDEN(RDEN), .RDRCLK(RDRCLKL), .RST(RST), .WRCLK(WRCLKL), .WREN(WREN));

    defparam INT_FIFO.ALMOST_EMPTY_OFFSET = ALMOST_EMPTY_OFFSET;
    defparam INT_FIFO.ALMOST_FULL_OFFSET = ALMOST_FULL_OFFSET;
    defparam INT_FIFO.DATA_WIDTH = DATA_WIDTH;
    defparam INT_FIFO.DO_REG = DO_REG;
    defparam INT_FIFO.EN_SYN = EN_SYN;
    defparam INT_FIFO.FIRST_WORD_FALL_THROUGH = FIRST_WORD_FALL_THROUGH;
    defparam INT_FIFO.SIM_MODE = SIM_MODE;
    
    specify

	(RDCLKL => ALMOSTEMPTY) = (100, 100);
	(RDCLKL => DOP[0]) = (100, 100);
	(RDCLKL => DOP[1]) = (100, 100);
	(RDCLKL => DOP[2]) = (100, 100);
	(RDCLKL => DOP[3]) = (100, 100);
	(RDCLKL => DO[0]) = (100, 100);
	(RDCLKL => DO[10]) = (100, 100);
	(RDCLKL => DO[11]) = (100, 100);
	(RDCLKL => DO[12]) = (100, 100);
	(RDCLKL => DO[13]) = (100, 100);
	(RDCLKL => DO[14]) = (100, 100);
	(RDCLKL => DO[15]) = (100, 100);
	(RDCLKL => DO[16]) = (100, 100);
	(RDCLKL => DO[17]) = (100, 100);
	(RDCLKL => DO[18]) = (100, 100);
	(RDCLKL => DO[19]) = (100, 100);
	(RDCLKL => DO[1]) = (100, 100);
	(RDCLKL => DO[20]) = (100, 100);
	(RDCLKL => DO[21]) = (100, 100);
	(RDCLKL => DO[22]) = (100, 100);
	(RDCLKL => DO[23]) = (100, 100);
	(RDCLKL => DO[24]) = (100, 100);
	(RDCLKL => DO[25]) = (100, 100);
	(RDCLKL => DO[26]) = (100, 100);
	(RDCLKL => DO[27]) = (100, 100);
	(RDCLKL => DO[28]) = (100, 100);
	(RDCLKL => DO[29]) = (100, 100);
	(RDCLKL => DO[2]) = (100, 100);
	(RDCLKL => DO[30]) = (100, 100);
	(RDCLKL => DO[31]) = (100, 100);
	(RDCLKL => DO[3]) = (100, 100);
	(RDCLKL => DO[4]) = (100, 100);
	(RDCLKL => DO[5]) = (100, 100);
	(RDCLKL => DO[6]) = (100, 100);
	(RDCLKL => DO[7]) = (100, 100);
	(RDCLKL => DO[8]) = (100, 100);
	(RDCLKL => DO[9]) = (100, 100);
	(RDCLKL => EMPTY) = (100, 100);
	(RDCLKL => RDCOUNT[0]) = (100, 100);
	(RDCLKL => RDCOUNT[10]) = (100, 100);
	(RDCLKL => RDCOUNT[11]) = (100, 100);
	(RDCLKL => RDCOUNT[12]) = (100, 100);
	(RDCLKL => RDCOUNT[1]) = (100, 100);
	(RDCLKL => RDCOUNT[2]) = (100, 100);
	(RDCLKL => RDCOUNT[3]) = (100, 100);
	(RDCLKL => RDCOUNT[4]) = (100, 100);
	(RDCLKL => RDCOUNT[5]) = (100, 100);
	(RDCLKL => RDCOUNT[6]) = (100, 100);
	(RDCLKL => RDCOUNT[7]) = (100, 100);
	(RDCLKL => RDCOUNT[8]) = (100, 100);
	(RDCLKL => RDCOUNT[9]) = (100, 100);
	(RDCLKL => RDERR) = (100, 100);

	(RDRCLKL => ALMOSTEMPTY) = (100, 100);
	(RDRCLKL => DOP[0]) = (100, 100);
	(RDRCLKL => DOP[1]) = (100, 100);
	(RDRCLKL => DOP[2]) = (100, 100);
	(RDRCLKL => DOP[3]) = (100, 100);
	(RDRCLKL => DO[0]) = (100, 100);
	(RDRCLKL => DO[10]) = (100, 100);
	(RDRCLKL => DO[11]) = (100, 100);
	(RDRCLKL => DO[12]) = (100, 100);
	(RDRCLKL => DO[13]) = (100, 100);
	(RDRCLKL => DO[14]) = (100, 100);
	(RDRCLKL => DO[15]) = (100, 100);
	(RDRCLKL => DO[16]) = (100, 100);
	(RDRCLKL => DO[17]) = (100, 100);
	(RDRCLKL => DO[18]) = (100, 100);
	(RDRCLKL => DO[19]) = (100, 100);
	(RDRCLKL => DO[1]) = (100, 100);
	(RDRCLKL => DO[20]) = (100, 100);
	(RDRCLKL => DO[21]) = (100, 100);
	(RDRCLKL => DO[22]) = (100, 100);
	(RDRCLKL => DO[23]) = (100, 100);
	(RDRCLKL => DO[24]) = (100, 100);
	(RDRCLKL => DO[25]) = (100, 100);
	(RDRCLKL => DO[26]) = (100, 100);
	(RDRCLKL => DO[27]) = (100, 100);
	(RDRCLKL => DO[28]) = (100, 100);
	(RDRCLKL => DO[29]) = (100, 100);
	(RDRCLKL => DO[2]) = (100, 100);
	(RDRCLKL => DO[30]) = (100, 100);
	(RDRCLKL => DO[31]) = (100, 100);
	(RDRCLKL => DO[3]) = (100, 100);
	(RDRCLKL => DO[4]) = (100, 100);
	(RDRCLKL => DO[5]) = (100, 100);
	(RDRCLKL => DO[6]) = (100, 100);
	(RDRCLKL => DO[7]) = (100, 100);
	(RDRCLKL => DO[8]) = (100, 100);
	(RDRCLKL => DO[9]) = (100, 100);
	(RDRCLKL => EMPTY) = (100, 100);
	(RDRCLKL => RDCOUNT[0]) = (100, 100);
	(RDRCLKL => RDCOUNT[10]) = (100, 100);
	(RDRCLKL => RDCOUNT[11]) = (100, 100);
	(RDRCLKL => RDCOUNT[12]) = (100, 100);
	(RDRCLKL => RDCOUNT[1]) = (100, 100);
	(RDRCLKL => RDCOUNT[2]) = (100, 100);
	(RDRCLKL => RDCOUNT[3]) = (100, 100);
	(RDRCLKL => RDCOUNT[4]) = (100, 100);
	(RDRCLKL => RDCOUNT[5]) = (100, 100);
	(RDRCLKL => RDCOUNT[6]) = (100, 100);
	(RDRCLKL => RDCOUNT[7]) = (100, 100);
	(RDRCLKL => RDCOUNT[8]) = (100, 100);
	(RDRCLKL => RDCOUNT[9]) = (100, 100);
	(RDRCLKL => RDERR) = (100, 100);
	
	(WRCLKL => ALMOSTFULL) = (100, 100);
	(WRCLKL => FULL) = (100, 100);
	(WRCLKL => WRCOUNT[0]) = (100, 100);
	(WRCLKL => WRCOUNT[10]) = (100, 100);
	(WRCLKL => WRCOUNT[11]) = (100, 100);
	(WRCLKL => WRCOUNT[12]) = (100, 100);
	(WRCLKL => WRCOUNT[1]) = (100, 100);
	(WRCLKL => WRCOUNT[2]) = (100, 100);
	(WRCLKL => WRCOUNT[3]) = (100, 100);
	(WRCLKL => WRCOUNT[4]) = (100, 100);
	(WRCLKL => WRCOUNT[5]) = (100, 100);
	(WRCLKL => WRCOUNT[6]) = (100, 100);
	(WRCLKL => WRCOUNT[7]) = (100, 100);
	(WRCLKL => WRCOUNT[8]) = (100, 100);
	(WRCLKL => WRCOUNT[9]) = (100, 100);
	(WRCLKL => WRERR) = (100, 100);

	(RDCLKU => ALMOSTEMPTY) = (100, 100);
	(RDCLKU => DOP[0]) = (100, 100);
	(RDCLKU => DOP[1]) = (100, 100);
	(RDCLKU => DOP[2]) = (100, 100);
	(RDCLKU => DOP[3]) = (100, 100);
	(RDCLKU => DO[0]) = (100, 100);
	(RDCLKU => DO[10]) = (100, 100);
	(RDCLKU => DO[11]) = (100, 100);
	(RDCLKU => DO[12]) = (100, 100);
	(RDCLKU => DO[13]) = (100, 100);
	(RDCLKU => DO[14]) = (100, 100);
	(RDCLKU => DO[15]) = (100, 100);
	(RDCLKU => DO[16]) = (100, 100);
	(RDCLKU => DO[17]) = (100, 100);
	(RDCLKU => DO[18]) = (100, 100);
	(RDCLKU => DO[19]) = (100, 100);
	(RDCLKU => DO[1]) = (100, 100);
	(RDCLKU => DO[20]) = (100, 100);
	(RDCLKU => DO[21]) = (100, 100);
	(RDCLKU => DO[22]) = (100, 100);
	(RDCLKU => DO[23]) = (100, 100);
	(RDCLKU => DO[24]) = (100, 100);
	(RDCLKU => DO[25]) = (100, 100);
	(RDCLKU => DO[26]) = (100, 100);
	(RDCLKU => DO[27]) = (100, 100);
	(RDCLKU => DO[28]) = (100, 100);
	(RDCLKU => DO[29]) = (100, 100);
	(RDCLKU => DO[2]) = (100, 100);
	(RDCLKU => DO[30]) = (100, 100);
	(RDCLKU => DO[31]) = (100, 100);
	(RDCLKU => DO[3]) = (100, 100);
	(RDCLKU => DO[4]) = (100, 100);
	(RDCLKU => DO[5]) = (100, 100);
	(RDCLKU => DO[6]) = (100, 100);
	(RDCLKU => DO[7]) = (100, 100);
	(RDCLKU => DO[8]) = (100, 100);
	(RDCLKU => DO[9]) = (100, 100);
	(RDCLKU => EMPTY) = (100, 100);
	(RDCLKU => RDCOUNT[0]) = (100, 100);
	(RDCLKU => RDCOUNT[10]) = (100, 100);
	(RDCLKU => RDCOUNT[11]) = (100, 100);
	(RDCLKU => RDCOUNT[12]) = (100, 100);
	(RDCLKU => RDCOUNT[1]) = (100, 100);
	(RDCLKU => RDCOUNT[2]) = (100, 100);
	(RDCLKU => RDCOUNT[3]) = (100, 100);
	(RDCLKU => RDCOUNT[4]) = (100, 100);
	(RDCLKU => RDCOUNT[5]) = (100, 100);
	(RDCLKU => RDCOUNT[6]) = (100, 100);
	(RDCLKU => RDCOUNT[7]) = (100, 100);
	(RDCLKU => RDCOUNT[8]) = (100, 100);
	(RDCLKU => RDCOUNT[9]) = (100, 100);
	(RDCLKU => RDERR) = (100, 100);

	(RDRCLKU => ALMOSTEMPTY) = (100, 100);
	(RDRCLKU => DOP[0]) = (100, 100);
	(RDRCLKU => DOP[1]) = (100, 100);
	(RDRCLKU => DOP[2]) = (100, 100);
	(RDRCLKU => DOP[3]) = (100, 100);
	(RDRCLKU => DO[0]) = (100, 100);
	(RDRCLKU => DO[10]) = (100, 100);
	(RDRCLKU => DO[11]) = (100, 100);
	(RDRCLKU => DO[12]) = (100, 100);
	(RDRCLKU => DO[13]) = (100, 100);
	(RDRCLKU => DO[14]) = (100, 100);
	(RDRCLKU => DO[15]) = (100, 100);
	(RDRCLKU => DO[16]) = (100, 100);
	(RDRCLKU => DO[17]) = (100, 100);
	(RDRCLKU => DO[18]) = (100, 100);
	(RDRCLKU => DO[19]) = (100, 100);
	(RDRCLKU => DO[1]) = (100, 100);
	(RDRCLKU => DO[20]) = (100, 100);
	(RDRCLKU => DO[21]) = (100, 100);
	(RDRCLKU => DO[22]) = (100, 100);
	(RDRCLKU => DO[23]) = (100, 100);
	(RDRCLKU => DO[24]) = (100, 100);
	(RDRCLKU => DO[25]) = (100, 100);
	(RDRCLKU => DO[26]) = (100, 100);
	(RDRCLKU => DO[27]) = (100, 100);
	(RDRCLKU => DO[28]) = (100, 100);
	(RDRCLKU => DO[29]) = (100, 100);
	(RDRCLKU => DO[2]) = (100, 100);
	(RDRCLKU => DO[30]) = (100, 100);
	(RDRCLKU => DO[31]) = (100, 100);
	(RDRCLKU => DO[3]) = (100, 100);
	(RDRCLKU => DO[4]) = (100, 100);
	(RDRCLKU => DO[5]) = (100, 100);
	(RDRCLKU => DO[6]) = (100, 100);
	(RDRCLKU => DO[7]) = (100, 100);
	(RDRCLKU => DO[8]) = (100, 100);
	(RDRCLKU => DO[9]) = (100, 100);
	(RDRCLKU => EMPTY) = (100, 100);
	(RDRCLKU => RDCOUNT[0]) = (100, 100);
	(RDRCLKU => RDCOUNT[10]) = (100, 100);
	(RDRCLKU => RDCOUNT[11]) = (100, 100);
	(RDRCLKU => RDCOUNT[12]) = (100, 100);
	(RDRCLKU => RDCOUNT[1]) = (100, 100);
	(RDRCLKU => RDCOUNT[2]) = (100, 100);
	(RDRCLKU => RDCOUNT[3]) = (100, 100);
	(RDRCLKU => RDCOUNT[4]) = (100, 100);
	(RDRCLKU => RDCOUNT[5]) = (100, 100);
	(RDRCLKU => RDCOUNT[6]) = (100, 100);
	(RDRCLKU => RDCOUNT[7]) = (100, 100);
	(RDRCLKU => RDCOUNT[8]) = (100, 100);
	(RDRCLKU => RDCOUNT[9]) = (100, 100);
	(RDRCLKU => RDERR) = (100, 100);
	
	(WRCLKU => ALMOSTFULL) = (100, 100);
	(WRCLKU => FULL) = (100, 100);
	(WRCLKU => WRCOUNT[0]) = (100, 100);
	(WRCLKU => WRCOUNT[10]) = (100, 100);
	(WRCLKU => WRCOUNT[11]) = (100, 100);
	(WRCLKU => WRCOUNT[12]) = (100, 100);
	(WRCLKU => WRCOUNT[1]) = (100, 100);
	(WRCLKU => WRCOUNT[2]) = (100, 100);
	(WRCLKU => WRCOUNT[3]) = (100, 100);
	(WRCLKU => WRCOUNT[4]) = (100, 100);
	(WRCLKU => WRCOUNT[5]) = (100, 100);
	(WRCLKU => WRCOUNT[6]) = (100, 100);
	(WRCLKU => WRCOUNT[7]) = (100, 100);
	(WRCLKU => WRCOUNT[8]) = (100, 100);
	(WRCLKU => WRCOUNT[9]) = (100, 100);
	(WRCLKU => WRERR) = (100, 100);
	
	specparam PATHPULSE$ = 0;

    endspecify
    
endmodule // FIFO36_EXP
