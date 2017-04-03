// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/FIFO18_36.v,v 1.12 2007/06/15 20:58:41 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  18K-Bit FIFO
// /___/   /\     Filename : FIFO18_36.v
// \   \  /  \    Timestamp : Tues July 26 16:44:06 PST 2005
//  \___\/\___\
//
// Revision:
//    07/26/05 - Initial version.
//    06/14/07 - Implemented high performace version of the model.
// End Revision

`timescale 1 ps/1 ps

module FIFO18_36 (ALMOSTEMPTY, ALMOSTFULL, DO, DOP, EMPTY, FULL, RDCOUNT, RDERR, WRCOUNT, WRERR,
		  DI, DIP, RDCLK, RDEN, RST, WRCLK, WREN);

    parameter ALMOST_EMPTY_OFFSET = 9'h080;
    parameter ALMOST_FULL_OFFSET = 9'h080;
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
    output [8:0] RDCOUNT;
    output RDERR;
    output [8:0] WRCOUNT;
    output WRERR;

    input [31:0] DI;
    input [3:0] DIP;
    input RDCLK;
    input RDEN;
    input RST;
    input WRCLK;
    input WREN;

    tri0 GSR = glbl.GSR;

    wire [31:0] dangle_out32;
    wire [3:0] dangle_out4;
    wire [7:0] dangle_out8;
    wire dangle_out;
    
    AFIFO36_INTERNAL INT_FIFO (.ALMOSTEMPTY(ALMOSTEMPTY), .ALMOSTFULL(ALMOSTFULL), .DBITERR(dangle_out), .DO({dangle_out32,DO}), .DOP({dangle_out4,DOP}), .ECCPARITY(dangle_out8), .EMPTY(EMPTY), .FULL(FULL), .RDCOUNT({dangle_out4,RDCOUNT}), .RDERR(RDERR), .SBITERR(dangle_out), .WRCOUNT({dangle_out4,WRCOUNT}), .WRERR(WRERR), .DI({32'b0,DI}), .DIP({4'b0,DIP}), .RDCLK(RDCLK), .RDEN(RDEN), .RDRCLK(RDCLK), .RST(RST), .WRCLK(WRCLK), .WREN(WREN));

    defparam INT_FIFO.FIFO_SIZE = 18;
    defparam INT_FIFO.ALMOST_EMPTY_OFFSET = ALMOST_EMPTY_OFFSET;
    defparam INT_FIFO.ALMOST_FULL_OFFSET = ALMOST_FULL_OFFSET;
    defparam INT_FIFO.DATA_WIDTH = 36;
    defparam INT_FIFO.DO_REG = DO_REG;
    defparam INT_FIFO.EN_SYN = EN_SYN;
    defparam INT_FIFO.FIRST_WORD_FALL_THROUGH = FIRST_WORD_FALL_THROUGH;
    defparam INT_FIFO.SIM_MODE = SIM_MODE;
    
    specify

        (RDCLK => DO[0]) = (100, 100);
        (RDCLK => DO[1]) = (100, 100);
        (RDCLK => DO[2]) = (100, 100);
        (RDCLK => DO[3]) = (100, 100);
        (RDCLK => DO[4]) = (100, 100);
        (RDCLK => DO[5]) = (100, 100);
        (RDCLK => DO[6]) = (100, 100);
        (RDCLK => DO[7]) = (100, 100);
        (RDCLK => DO[8]) = (100, 100);
        (RDCLK => DO[9]) = (100, 100);
        (RDCLK => DO[10]) = (100, 100);
        (RDCLK => DO[11]) = (100, 100);
        (RDCLK => DO[12]) = (100, 100);
        (RDCLK => DO[13]) = (100, 100);
        (RDCLK => DO[14]) = (100, 100);
        (RDCLK => DO[15]) = (100, 100);
        (RDCLK => DO[16]) = (100, 100);
        (RDCLK => DO[17]) = (100, 100);
        (RDCLK => DO[18]) = (100, 100);
        (RDCLK => DO[19]) = (100, 100);
        (RDCLK => DO[20]) = (100, 100);
        (RDCLK => DO[21]) = (100, 100);
        (RDCLK => DO[22]) = (100, 100);
        (RDCLK => DO[23]) = (100, 100);
        (RDCLK => DO[24]) = (100, 100);
        (RDCLK => DO[25]) = (100, 100);
        (RDCLK => DO[26]) = (100, 100);
        (RDCLK => DO[27]) = (100, 100);
        (RDCLK => DO[28]) = (100, 100);
        (RDCLK => DO[29]) = (100, 100);
        (RDCLK => DO[30]) = (100, 100);
        (RDCLK => DO[31]) = (100, 100);
        (RDCLK => DOP[0]) = (100, 100);
        (RDCLK => DOP[1]) = (100, 100);
        (RDCLK => DOP[2]) = (100, 100);
        (RDCLK => DOP[3]) = (100, 100);

	(RDCLK => ALMOSTEMPTY) = (100, 100);
	(RDCLK => EMPTY) = (100, 100);
	(RDCLK => RDCOUNT[0]) = (100, 100);
	(RDCLK => RDCOUNT[1]) = (100, 100);
	(RDCLK => RDCOUNT[2]) = (100, 100);
	(RDCLK => RDCOUNT[3]) = (100, 100);
	(RDCLK => RDCOUNT[4]) = (100, 100);
	(RDCLK => RDCOUNT[5]) = (100, 100);
	(RDCLK => RDCOUNT[6]) = (100, 100);
	(RDCLK => RDCOUNT[7]) = (100, 100);
	(RDCLK => RDCOUNT[8]) = (100, 100);
	(RDCLK => RDERR) = (100, 100);

	(WRCLK => ALMOSTFULL) = (100, 100);
	(WRCLK => FULL) = (100, 100);
	(WRCLK => WRCOUNT[0]) = (100, 100);
	(WRCLK => WRCOUNT[1]) = (100, 100);
	(WRCLK => WRCOUNT[2]) = (100, 100);
	(WRCLK => WRCOUNT[3]) = (100, 100);
	(WRCLK => WRCOUNT[4]) = (100, 100);
	(WRCLK => WRCOUNT[5]) = (100, 100);
	(WRCLK => WRCOUNT[6]) = (100, 100);
	(WRCLK => WRCOUNT[7]) = (100, 100);
	(WRCLK => WRCOUNT[8]) = (100, 100);
	(WRCLK => WRERR) = (100, 100);
	
	specparam PATHPULSE$ = 0;

    endspecify
    
endmodule // FIFO18_36
