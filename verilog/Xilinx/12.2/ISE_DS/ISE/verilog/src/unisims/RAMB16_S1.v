// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAMB16_S1.v,v 1.7 2005/03/14 22:54:41 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  16K-Bit Data and 2K-Bit Parity Single Port Block RAM
// /___/   /\     Filename : RAMB16_S1.v
// \   \  /  \    Timestamp : Thu Mar 10 16:43:34 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`ifdef legacy_model

`timescale  1 ps / 1 ps

module RAMB16_S1 (DO, ADDR, CLK, DI, EN, SSR, WE);

    parameter INIT = 1'h0;
    parameter SRVAL = 1'h0;
    parameter WRITE_MODE = "WRITE_FIRST";

    parameter INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

    output [0:0] DO;
    reg do0_out;

    input [13:0] ADDR;
    input [0:0] DI;
    input EN, CLK, WE, SSR;

    reg [18431:0] mem;
    reg [8:0] count;
    reg [1:0] wr_mode;

    wire [13:0] addr_int;
    wire [0:0] di_int;
    wire en_int, clk_int, we_int, ssr_int;

    tri0 GSR = glbl.GSR;

    always @(GSR)
	if (GSR) begin
	    assign do0_out = INIT[0];
	end
	else begin
	    deassign do0_out;
	end

    buf b_do_out0 (DO[0], do0_out);
    buf b_addr_0 (addr_int[0], ADDR[0]);
    buf b_addr_1 (addr_int[1], ADDR[1]);
    buf b_addr_2 (addr_int[2], ADDR[2]);
    buf b_addr_3 (addr_int[3], ADDR[3]);
    buf b_addr_4 (addr_int[4], ADDR[4]);
    buf b_addr_5 (addr_int[5], ADDR[5]);
    buf b_addr_6 (addr_int[6], ADDR[6]);
    buf b_addr_7 (addr_int[7], ADDR[7]);
    buf b_addr_8 (addr_int[8], ADDR[8]);
    buf b_addr_9 (addr_int[9], ADDR[9]);
    buf b_addr_10 (addr_int[10], ADDR[10]);
    buf b_addr_11 (addr_int[11], ADDR[11]);
    buf b_addr_12 (addr_int[12], ADDR[12]);
    buf b_addr_13 (addr_int[13], ADDR[13]);
    buf b_di_0 (di_int[0], DI[0]);
    buf b_en (en_int, EN);
    buf b_clk (clk_int, CLK);
    buf b_we (we_int, WE);
    buf b_ssr (ssr_int, SSR);

    initial begin
	for (count = 0; count < 256; count = count + 1) begin
	    mem[count]		  <= INIT_00[count];
	    mem[256 * 1 + count]  <= INIT_01[count];
	    mem[256 * 2 + count]  <= INIT_02[count];
	    mem[256 * 3 + count]  <= INIT_03[count];
	    mem[256 * 4 + count]  <= INIT_04[count];
	    mem[256 * 5 + count]  <= INIT_05[count];
	    mem[256 * 6 + count]  <= INIT_06[count];
	    mem[256 * 7 + count]  <= INIT_07[count];
	    mem[256 * 8 + count]  <= INIT_08[count];
	    mem[256 * 9 + count]  <= INIT_09[count];
	    mem[256 * 10 + count] <= INIT_0A[count];
	    mem[256 * 11 + count] <= INIT_0B[count];
	    mem[256 * 12 + count] <= INIT_0C[count];
	    mem[256 * 13 + count] <= INIT_0D[count];
	    mem[256 * 14 + count] <= INIT_0E[count];
	    mem[256 * 15 + count] <= INIT_0F[count];
	    mem[256 * 16 + count] <= INIT_10[count];
	    mem[256 * 17 + count] <= INIT_11[count];
	    mem[256 * 18 + count] <= INIT_12[count];
	    mem[256 * 19 + count] <= INIT_13[count];
	    mem[256 * 20 + count] <= INIT_14[count];
	    mem[256 * 21 + count] <= INIT_15[count];
	    mem[256 * 22 + count] <= INIT_16[count];
	    mem[256 * 23 + count] <= INIT_17[count];
	    mem[256 * 24 + count] <= INIT_18[count];
	    mem[256 * 25 + count] <= INIT_19[count];
	    mem[256 * 26 + count] <= INIT_1A[count];
	    mem[256 * 27 + count] <= INIT_1B[count];
	    mem[256 * 28 + count] <= INIT_1C[count];
	    mem[256 * 29 + count] <= INIT_1D[count];
	    mem[256 * 30 + count] <= INIT_1E[count];
	    mem[256 * 31 + count] <= INIT_1F[count];
	    mem[256 * 32 + count] <= INIT_20[count];
	    mem[256 * 33 + count] <= INIT_21[count];
	    mem[256 * 34 + count] <= INIT_22[count];
	    mem[256 * 35 + count] <= INIT_23[count];
	    mem[256 * 36 + count] <= INIT_24[count];
	    mem[256 * 37 + count] <= INIT_25[count];
	    mem[256 * 38 + count] <= INIT_26[count];
	    mem[256 * 39 + count] <= INIT_27[count];
	    mem[256 * 40 + count] <= INIT_28[count];
	    mem[256 * 41 + count] <= INIT_29[count];
	    mem[256 * 42 + count] <= INIT_2A[count];
	    mem[256 * 43 + count] <= INIT_2B[count];
	    mem[256 * 44 + count] <= INIT_2C[count];
	    mem[256 * 45 + count] <= INIT_2D[count];
	    mem[256 * 46 + count] <= INIT_2E[count];
	    mem[256 * 47 + count] <= INIT_2F[count];
	    mem[256 * 48 + count] <= INIT_30[count];
	    mem[256 * 49 + count] <= INIT_31[count];
	    mem[256 * 50 + count] <= INIT_32[count];
	    mem[256 * 51 + count] <= INIT_33[count];
	    mem[256 * 52 + count] <= INIT_34[count];
	    mem[256 * 53 + count] <= INIT_35[count];
	    mem[256 * 54 + count] <= INIT_36[count];
	    mem[256 * 55 + count] <= INIT_37[count];
	    mem[256 * 56 + count] <= INIT_38[count];
	    mem[256 * 57 + count] <= INIT_39[count];
	    mem[256 * 58 + count] <= INIT_3A[count];
	    mem[256 * 59 + count] <= INIT_3B[count];
	    mem[256 * 60 + count] <= INIT_3C[count];
	    mem[256 * 61 + count] <= INIT_3D[count];
	    mem[256 * 62 + count] <= INIT_3E[count];
	    mem[256 * 63 + count] <= INIT_3F[count];
	end
    end

    initial begin
	case (WRITE_MODE)
	    "WRITE_FIRST" : wr_mode <= 2'b00;
	    "READ_FIRST"  : wr_mode <= 2'b01;
	    "NO_CHANGE"   : wr_mode <= 2'b10;
	    default       : begin
				$display("Attribute Syntax Error : The attribute WRITE_MODE on RAMB16_S1 instance %m is set to %s.  Legal values for this attribute are WRITE_FIRST, READ_FIRST or NO_CHANGE.", WRITE_MODE);
				$finish;
			    end
	endcase
    end

    always @(posedge clk_int) begin
	if (en_int == 1'b1) begin
	    if (ssr_int == 1'b1) begin
		do0_out <= SRVAL[0];
	    end
	    else begin
		if (we_int == 1'b1) begin
		    if (wr_mode == 2'b00) begin
			do0_out <= di_int[0];
		    end
		    else if (wr_mode == 2'b01) begin
			do0_out <= mem[addr_int * 1 + 0];
		    end
		    else begin
			do0_out <= do0_out;
		    end
		end
		else begin
		    do0_out <= mem[addr_int * 1 + 0];
		end
	    end
	end
    end

    always @(posedge clk_int) begin
	if (en_int == 1'b1 && we_int == 1'b1) begin
	    mem[addr_int * 1 + 0] <= di_int[0];
	end
    end

    specify
	(CLK *> DO) = (100, 100);
    endspecify

endmodule

`else

// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAMB16_S1.v,v 1.7 2005/03/14 22:54:41 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Timing Simulation Library Component
//  /   /                  16K-Bit Data and 2K-Bit Parity Single Port Block RAM
// /___/   /\     Filename : RAMB16_S1.v
// \   \  /  \    Timestamp : Thu Mar 10 16:44:01 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/10/05 - Initialized outputs.
// End Revision

`timescale 1 ps/1 ps

module RAMB16_S1 (DO, ADDR, CLK, DI, EN, SSR, WE);

    parameter INIT = 1'h0;
    parameter SRVAL = 1'h0;
    parameter WRITE_MODE = "WRITE_FIRST";

    parameter INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    
    output [0:0] DO;

    input [13:0] ADDR;
    input [0:0] DI;
    input EN, CLK, WE, SSR;

    reg [0:0] do_out = INIT[0:0];
    
    reg [0:0] mem [16383:0];
    
    reg [8:0] count, countp;
    reg [1:0] wr_mode;

    wire [13:0] addr_int;
    wire [0:0] di_int;
    wire en_int, clk_int, we_int, ssr_int;

    wire di_enable = en_int && we_int;
    
    tri0 GSR = glbl.GSR;
    wire gsr_int;

    buf b_gsr (gsr_int, GSR);

    buf b_do [0:0] (DO, do_out);
    buf b_addr [13:0] (addr_int, ADDR);
    buf b_di [0:0] (di_int, DI);
    buf b_en (en_int, EN);
    buf b_clk (clk_int, CLK);
    buf b_ssr (ssr_int, SSR);
    buf b_we (we_int, WE);

    
    always @(gsr_int)
	if (gsr_int) begin
	    assign {do_out} = INIT;
	end
	else begin
	    deassign do_out;
	end

    
    initial begin

	for (count = 0; count < 256; count = count + 1) begin
	    mem[count]          = INIT_00[(count * 1) +: 1];
	    mem[256 * 1 + count]  = INIT_01[(count * 1) +: 1];
	    mem[256 * 2 + count]  = INIT_02[(count * 1) +: 1];
	    mem[256 * 3 + count]  = INIT_03[(count * 1) +: 1];
	    mem[256 * 4 + count]  = INIT_04[(count * 1) +: 1];
	    mem[256 * 5 + count]  = INIT_05[(count * 1) +: 1];
	    mem[256 * 6 + count]  = INIT_06[(count * 1) +: 1];
	    mem[256 * 7 + count]  = INIT_07[(count * 1) +: 1];
	    mem[256 * 8 + count]  = INIT_08[(count * 1) +: 1];
	    mem[256 * 9 + count]  = INIT_09[(count * 1) +: 1];
	    mem[256 * 10 + count] = INIT_0A[(count * 1) +: 1];
	    mem[256 * 11 + count] = INIT_0B[(count * 1) +: 1];
	    mem[256 * 12 + count] = INIT_0C[(count * 1) +: 1];
	    mem[256 * 13 + count] = INIT_0D[(count * 1) +: 1];
	    mem[256 * 14 + count] = INIT_0E[(count * 1) +: 1];
	    mem[256 * 15 + count] = INIT_0F[(count * 1) +: 1];
	    mem[256 * 16 + count] = INIT_10[(count * 1) +: 1];
	    mem[256 * 17 + count] = INIT_11[(count * 1) +: 1];
	    mem[256 * 18 + count] = INIT_12[(count * 1) +: 1];
	    mem[256 * 19 + count] = INIT_13[(count * 1) +: 1];
	    mem[256 * 20 + count] = INIT_14[(count * 1) +: 1];
	    mem[256 * 21 + count] = INIT_15[(count * 1) +: 1];
	    mem[256 * 22 + count] = INIT_16[(count * 1) +: 1];
	    mem[256 * 23 + count] = INIT_17[(count * 1) +: 1];
	    mem[256 * 24 + count] = INIT_18[(count * 1) +: 1];
	    mem[256 * 25 + count] = INIT_19[(count * 1) +: 1];
	    mem[256 * 26 + count] = INIT_1A[(count * 1) +: 1];
	    mem[256 * 27 + count] = INIT_1B[(count * 1) +: 1];
	    mem[256 * 28 + count] = INIT_1C[(count * 1) +: 1];
	    mem[256 * 29 + count] = INIT_1D[(count * 1) +: 1];
	    mem[256 * 30 + count] = INIT_1E[(count * 1) +: 1];
	    mem[256 * 31 + count] = INIT_1F[(count * 1) +: 1];
	    mem[256 * 32 + count] = INIT_20[(count * 1) +: 1];
	    mem[256 * 33 + count] = INIT_21[(count * 1) +: 1];
	    mem[256 * 34 + count] = INIT_22[(count * 1) +: 1];
	    mem[256 * 35 + count] = INIT_23[(count * 1) +: 1];
	    mem[256 * 36 + count] = INIT_24[(count * 1) +: 1];
	    mem[256 * 37 + count] = INIT_25[(count * 1) +: 1];
	    mem[256 * 38 + count] = INIT_26[(count * 1) +: 1];
	    mem[256 * 39 + count] = INIT_27[(count * 1) +: 1];
	    mem[256 * 40 + count] = INIT_28[(count * 1) +: 1];
	    mem[256 * 41 + count] = INIT_29[(count * 1) +: 1];
	    mem[256 * 42 + count] = INIT_2A[(count * 1) +: 1];
	    mem[256 * 43 + count] = INIT_2B[(count * 1) +: 1];
	    mem[256 * 44 + count] = INIT_2C[(count * 1) +: 1];
	    mem[256 * 45 + count] = INIT_2D[(count * 1) +: 1];
	    mem[256 * 46 + count] = INIT_2E[(count * 1) +: 1];
	    mem[256 * 47 + count] = INIT_2F[(count * 1) +: 1];
	    mem[256 * 48 + count] = INIT_30[(count * 1) +: 1];
	    mem[256 * 49 + count] = INIT_31[(count * 1) +: 1];
	    mem[256 * 50 + count] = INIT_32[(count * 1) +: 1];
	    mem[256 * 51 + count] = INIT_33[(count * 1) +: 1];
	    mem[256 * 52 + count] = INIT_34[(count * 1) +: 1];
	    mem[256 * 53 + count] = INIT_35[(count * 1) +: 1];
	    mem[256 * 54 + count] = INIT_36[(count * 1) +: 1];
	    mem[256 * 55 + count] = INIT_37[(count * 1) +: 1];
	    mem[256 * 56 + count] = INIT_38[(count * 1) +: 1];
	    mem[256 * 57 + count] = INIT_39[(count * 1) +: 1];
	    mem[256 * 58 + count] = INIT_3A[(count * 1) +: 1];
	    mem[256 * 59 + count] = INIT_3B[(count * 1) +: 1];
	    mem[256 * 60 + count] = INIT_3C[(count * 1) +: 1];
	    mem[256 * 61 + count] = INIT_3D[(count * 1) +: 1];
	    mem[256 * 62 + count] = INIT_3E[(count * 1) +: 1];
	    mem[256 * 63 + count] = INIT_3F[(count * 1) +: 1];
	end

    end // initial begin
	

    initial begin
	case (WRITE_MODE)
	    "WRITE_FIRST" : wr_mode <= 2'b00;
	    "READ_FIRST"  : wr_mode <= 2'b01;
	    "NO_CHANGE"   : wr_mode <= 2'b10;
	    default       : begin
				$display("Attribute Syntax Error : The Attribute WRITE_MODE on RAMB16_S1 instance %m is set to %s.  Legal values for this attribute are WRITE_FIRST, READ_FIRST or NO_CHANGE.", WRITE_MODE);
				$finish;
			    end
	endcase
    end


    always @(posedge clk_int) begin

	if (en_int == 1'b1) begin

	    if (ssr_int == 1'b1) begin
		{do_out} <= #100 SRVAL;
	    end
	    else begin
		if (we_int == 1'b1) begin
		    if (wr_mode == 2'b00) begin
			do_out <= #100 di_int;
		    end
		    else if (wr_mode == 2'b01) begin
			do_out <= #100 mem[addr_int];
		    end
		end
		else begin
		    do_out <= #100 mem[addr_int];
		end
	    end

	    // memory
	    if (we_int == 1'b1) begin
		mem[addr_int] <= di_int;
	    end

	end
    end


endmodule

`endif
