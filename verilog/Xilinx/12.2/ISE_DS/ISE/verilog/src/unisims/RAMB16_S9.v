// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAMB16_S9.v,v 1.6 2005/03/14 22:54:41 wloo Exp $
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
// /___/   /\     Filename : RAMB16_S9.v
// \   \  /  \    Timestamp : Thu Mar 10 16:43:37 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`ifdef legacy_model

`timescale  1 ps / 1 ps

module RAMB16_S9 (DO, DOP, ADDR, CLK, DI, DIP, EN, SSR, WE);

    parameter INIT = 9'h0;
    parameter SRVAL = 9'h0;
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
    parameter INITP_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;

    output [7:0] DO;
    output [0:0] DOP;
    reg do0_out, do1_out, do2_out, do3_out, do4_out, do5_out, do6_out, do7_out;
    reg dop0_out;

    input [10:0] ADDR;
    input [7:0] DI;
    input [0:0] DIP;
    input EN, CLK, WE, SSR;

    reg [18431:0] mem;
    reg [8:0] count;
    reg [1:0] wr_mode;

    wire [10:0] addr_int;
    wire [7:0] di_int;
    wire [0:0] dip_int;
    wire en_int, clk_int, we_int, ssr_int;

    tri0 GSR = glbl.GSR;

    always @(GSR)
	if (GSR) begin
	    assign do0_out = INIT[0];
	    assign do1_out = INIT[1];
	    assign do2_out = INIT[2];
	    assign do3_out = INIT[3];
	    assign do4_out = INIT[4];
	    assign do5_out = INIT[5];
	    assign do6_out = INIT[6];
	    assign do7_out = INIT[7];
	    assign dop0_out = INIT[8];
	end
	else begin
	    deassign do0_out;
	    deassign do1_out;
	    deassign do2_out;
	    deassign do3_out;
	    deassign do4_out;
	    deassign do5_out;
	    deassign do6_out;
	    deassign do7_out;
	    deassign dop0_out;
	end

    buf b_do_out0 (DO[0], do0_out);
    buf b_do_out1 (DO[1], do1_out);
    buf b_do_out2 (DO[2], do2_out);
    buf b_do_out3 (DO[3], do3_out);
    buf b_do_out4 (DO[4], do4_out);
    buf b_do_out5 (DO[5], do5_out);
    buf b_do_out6 (DO[6], do6_out);
    buf b_do_out7 (DO[7], do7_out);
    buf b_dop_out0 (DOP[0], dop0_out);
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
    buf b_di_0 (di_int[0], DI[0]);
    buf b_di_1 (di_int[1], DI[1]);
    buf b_di_2 (di_int[2], DI[2]);
    buf b_di_3 (di_int[3], DI[3]);
    buf b_di_4 (di_int[4], DI[4]);
    buf b_di_5 (di_int[5], DI[5]);
    buf b_di_6 (di_int[6], DI[6]);
    buf b_di_7 (di_int[7], DI[7]);
    buf b_dip_0 (dip_int[0], DIP[0]);
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
	    mem[256 * 64 + count] <= INITP_00[count];
	    mem[256 * 65 + count] <= INITP_01[count];
	    mem[256 * 66 + count] <= INITP_02[count];
	    mem[256 * 67 + count] <= INITP_03[count];
	    mem[256 * 68 + count] <= INITP_04[count];
	    mem[256 * 69 + count] <= INITP_05[count];
	    mem[256 * 70 + count] <= INITP_06[count];
	    mem[256 * 71 + count] <= INITP_07[count];
	end
    end

    initial begin
	case (WRITE_MODE)
	    "WRITE_FIRST" : wr_mode <= 2'b00;
	    "READ_FIRST"  : wr_mode <= 2'b01;
	    "NO_CHANGE"   : wr_mode <= 2'b10;
	    default       : begin
				$display("Attribute Syntax Error : The attribute WRITE_MODE on RAMB16_S9 instance %m is set to %s.  The legal values for this attribute are WRITE_FIRST, READ_FIRST or NO_CHANGE.", WRITE_MODE);
				$finish;
			    end
	endcase
    end

    always @(posedge clk_int) begin
	if (en_int == 1'b1) begin
	    if (ssr_int == 1'b1) begin
		do0_out <= SRVAL[0];
		do1_out <= SRVAL[1];
		do2_out <= SRVAL[2];
		do3_out <= SRVAL[3];
		do4_out <= SRVAL[4];
		do5_out <= SRVAL[5];
		do6_out <= SRVAL[6];
		do7_out <= SRVAL[7];
		dop0_out <= SRVAL[8];
	    end
	    else begin
		if (we_int == 1'b1) begin
		    if (wr_mode == 2'b00) begin
			do0_out <= di_int[0];
			do1_out <= di_int[1];
			do2_out <= di_int[2];
			do3_out <= di_int[3];
			do4_out <= di_int[4];
			do5_out <= di_int[5];
			do6_out <= di_int[6];
			do7_out <= di_int[7];
			dop0_out <= dip_int[0];
		    end
		    else if (wr_mode == 2'b01) begin
			do0_out <= mem[addr_int * 8 + 0];
			do1_out <= mem[addr_int * 8 + 1];
			do2_out <= mem[addr_int * 8 + 2];
			do3_out <= mem[addr_int * 8 + 3];
			do4_out <= mem[addr_int * 8 + 4];
			do5_out <= mem[addr_int * 8 + 5];
			do6_out <= mem[addr_int * 8 + 6];
			do7_out <= mem[addr_int * 8 + 7];
			dop0_out <= mem[16384 + addr_int * 1 + 0];
		    end
		    else begin
			do0_out <= do0_out;
			do1_out <= do1_out;
			do2_out <= do2_out;
			do3_out <= do3_out;
			do4_out <= do4_out;
			do5_out <= do5_out;
			do6_out <= do6_out;
			do7_out <= do7_out;
			dop0_out <= dop0_out;
		    end
		end
		else begin
		    do0_out <= mem[addr_int * 8 + 0];
		    do1_out <= mem[addr_int * 8 + 1];
		    do2_out <= mem[addr_int * 8 + 2];
		    do3_out <= mem[addr_int * 8 + 3];
		    do4_out <= mem[addr_int * 8 + 4];
		    do5_out <= mem[addr_int * 8 + 5];
		    do6_out <= mem[addr_int * 8 + 6];
		    do7_out <= mem[addr_int * 8 + 7];
		    dop0_out <= mem[16384 + addr_int * 1 + 0];
		end
	    end
	end
    end

    always @(posedge clk_int) begin
	if (en_int == 1'b1 && we_int == 1'b1) begin
	    mem[addr_int * 8 + 0] <= di_int[0];
	    mem[addr_int * 8 + 1] <= di_int[1];
	    mem[addr_int * 8 + 2] <= di_int[2];
	    mem[addr_int * 8 + 3] <= di_int[3];
	    mem[addr_int * 8 + 4] <= di_int[4];
	    mem[addr_int * 8 + 5] <= di_int[5];
	    mem[addr_int * 8 + 6] <= di_int[6];
	    mem[addr_int * 8 + 7] <= di_int[7];
	    mem[16384 + addr_int * 1 + 0] <= dip_int[0];
	end
    end

    specify
	(CLK *> DO) = (100, 100);
	(CLK *> DOP) = (100, 100);
    endspecify

endmodule

`else

// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAMB16_S9.v,v 1.6 2005/03/14 22:54:41 wloo Exp $
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
// /___/   /\     Filename : RAMB16_S9.v
// \   \  /  \    Timestamp : Thu Mar 10 16:44:01 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/10/05 - Initialized outputs.
// End Revision

`timescale 1 ps/1 ps

module RAMB16_S9 (DO, DOP, ADDR, CLK, DI, DIP, EN, SSR, WE);

    parameter INIT = 9'h0;
    parameter SRVAL = 9'h0;
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
    parameter INITP_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    
    output [7:0] DO;
    output [0:0] DOP;

    input [10:0] ADDR;
    input [7:0] DI;
    input [0:0] DIP;
    input EN, CLK, WE, SSR;

    reg [7:0] do_out = INIT[7:0];
    reg [0:0] dop_out = INIT[8:8];
    
    reg [7:0] mem [2047:0];
    reg [0:0] memp [2047:0];
    
    reg [8:0] count, countp;
    reg [1:0] wr_mode;

    wire [10:0] addr_int;
    wire [7:0] di_int;
    wire [0:0] dip_int;
    wire en_int, clk_int, we_int, ssr_int;

    wire di_enable = en_int && we_int;
    
    tri0 GSR = glbl.GSR;
    wire gsr_int;

    buf b_gsr (gsr_int, GSR);

    buf b_do [7:0] (DO, do_out);
    buf b_dop [0:0] (DOP, dop_out);
    buf b_addr [10:0] (addr_int, ADDR);
    buf b_di [7:0] (di_int, DI);
    buf b_dip [0:0] (dip_int, DIP);
    buf b_en (en_int, EN);
    buf b_clk (clk_int, CLK);
    buf b_ssr (ssr_int, SSR);
    buf b_we (we_int, WE);

    
    always @(gsr_int)
	if (gsr_int) begin
	    assign {dop_out, do_out} = INIT;
	end
	else begin
	    deassign do_out;
	    deassign dop_out;
	end

    
    initial begin

	for (count = 0; count < 32; count = count + 1) begin
	    mem[count]          = INIT_00[(count * 8) +: 8];
	    mem[32 * 1 + count]  = INIT_01[(count * 8) +: 8];
	    mem[32 * 2 + count]  = INIT_02[(count * 8) +: 8];
	    mem[32 * 3 + count]  = INIT_03[(count * 8) +: 8];
	    mem[32 * 4 + count]  = INIT_04[(count * 8) +: 8];
	    mem[32 * 5 + count]  = INIT_05[(count * 8) +: 8];
	    mem[32 * 6 + count]  = INIT_06[(count * 8) +: 8];
	    mem[32 * 7 + count]  = INIT_07[(count * 8) +: 8];
	    mem[32 * 8 + count]  = INIT_08[(count * 8) +: 8];
	    mem[32 * 9 + count]  = INIT_09[(count * 8) +: 8];
	    mem[32 * 10 + count] = INIT_0A[(count * 8) +: 8];
	    mem[32 * 11 + count] = INIT_0B[(count * 8) +: 8];
	    mem[32 * 12 + count] = INIT_0C[(count * 8) +: 8];
	    mem[32 * 13 + count] = INIT_0D[(count * 8) +: 8];
	    mem[32 * 14 + count] = INIT_0E[(count * 8) +: 8];
	    mem[32 * 15 + count] = INIT_0F[(count * 8) +: 8];
	    mem[32 * 16 + count] = INIT_10[(count * 8) +: 8];
	    mem[32 * 17 + count] = INIT_11[(count * 8) +: 8];
	    mem[32 * 18 + count] = INIT_12[(count * 8) +: 8];
	    mem[32 * 19 + count] = INIT_13[(count * 8) +: 8];
	    mem[32 * 20 + count] = INIT_14[(count * 8) +: 8];
	    mem[32 * 21 + count] = INIT_15[(count * 8) +: 8];
	    mem[32 * 22 + count] = INIT_16[(count * 8) +: 8];
	    mem[32 * 23 + count] = INIT_17[(count * 8) +: 8];
	    mem[32 * 24 + count] = INIT_18[(count * 8) +: 8];
	    mem[32 * 25 + count] = INIT_19[(count * 8) +: 8];
	    mem[32 * 26 + count] = INIT_1A[(count * 8) +: 8];
	    mem[32 * 27 + count] = INIT_1B[(count * 8) +: 8];
	    mem[32 * 28 + count] = INIT_1C[(count * 8) +: 8];
	    mem[32 * 29 + count] = INIT_1D[(count * 8) +: 8];
	    mem[32 * 30 + count] = INIT_1E[(count * 8) +: 8];
	    mem[32 * 31 + count] = INIT_1F[(count * 8) +: 8];
	    mem[32 * 32 + count] = INIT_20[(count * 8) +: 8];
	    mem[32 * 33 + count] = INIT_21[(count * 8) +: 8];
	    mem[32 * 34 + count] = INIT_22[(count * 8) +: 8];
	    mem[32 * 35 + count] = INIT_23[(count * 8) +: 8];
	    mem[32 * 36 + count] = INIT_24[(count * 8) +: 8];
	    mem[32 * 37 + count] = INIT_25[(count * 8) +: 8];
	    mem[32 * 38 + count] = INIT_26[(count * 8) +: 8];
	    mem[32 * 39 + count] = INIT_27[(count * 8) +: 8];
	    mem[32 * 40 + count] = INIT_28[(count * 8) +: 8];
	    mem[32 * 41 + count] = INIT_29[(count * 8) +: 8];
	    mem[32 * 42 + count] = INIT_2A[(count * 8) +: 8];
	    mem[32 * 43 + count] = INIT_2B[(count * 8) +: 8];
	    mem[32 * 44 + count] = INIT_2C[(count * 8) +: 8];
	    mem[32 * 45 + count] = INIT_2D[(count * 8) +: 8];
	    mem[32 * 46 + count] = INIT_2E[(count * 8) +: 8];
	    mem[32 * 47 + count] = INIT_2F[(count * 8) +: 8];
	    mem[32 * 48 + count] = INIT_30[(count * 8) +: 8];
	    mem[32 * 49 + count] = INIT_31[(count * 8) +: 8];
	    mem[32 * 50 + count] = INIT_32[(count * 8) +: 8];
	    mem[32 * 51 + count] = INIT_33[(count * 8) +: 8];
	    mem[32 * 52 + count] = INIT_34[(count * 8) +: 8];
	    mem[32 * 53 + count] = INIT_35[(count * 8) +: 8];
	    mem[32 * 54 + count] = INIT_36[(count * 8) +: 8];
	    mem[32 * 55 + count] = INIT_37[(count * 8) +: 8];
	    mem[32 * 56 + count] = INIT_38[(count * 8) +: 8];
	    mem[32 * 57 + count] = INIT_39[(count * 8) +: 8];
	    mem[32 * 58 + count] = INIT_3A[(count * 8) +: 8];
	    mem[32 * 59 + count] = INIT_3B[(count * 8) +: 8];
	    mem[32 * 60 + count] = INIT_3C[(count * 8) +: 8];
	    mem[32 * 61 + count] = INIT_3D[(count * 8) +: 8];
	    mem[32 * 62 + count] = INIT_3E[(count * 8) +: 8];
	    mem[32 * 63 + count] = INIT_3F[(count * 8) +: 8];
	end

// initiate parity start
	for (countp = 0; countp < 256; countp = countp + 1) begin
	    memp[countp]          = INITP_00[(countp * 1) +: 1];
	    memp[256 * 1 + countp] = INITP_01[(countp * 1) +: 1];
	    memp[256 * 2 + countp] = INITP_02[(countp * 1) +: 1];
	    memp[256 * 3 + countp] = INITP_03[(countp * 1) +: 1];
	    memp[256 * 4 + countp] = INITP_04[(countp * 1) +: 1];
	    memp[256 * 5 + countp] = INITP_05[(countp * 1) +: 1];
	    memp[256 * 6 + countp] = INITP_06[(countp * 1) +: 1];
	    memp[256 * 7 + countp] = INITP_07[(countp * 1) +: 1];
	end
// initiate parity end
    end // initial begin
	

    initial begin
	case (WRITE_MODE)
	    "WRITE_FIRST" : wr_mode <= 2'b00;
	    "READ_FIRST"  : wr_mode <= 2'b01;
	    "NO_CHANGE"   : wr_mode <= 2'b10;
	    default       : begin
				$display("Attribute Syntax Error : The Attribute WRITE_MODE on RAMB16_S9 instance %m is set to %s.  Legal values for this attribute are WRITE_FIRST, READ_FIRST or NO_CHANGE.", WRITE_MODE);
				$finish;
			    end
	endcase
    end


    always @(posedge clk_int) begin

	if (en_int == 1'b1) begin

	    if (ssr_int == 1'b1) begin
		{dop_out, do_out} <= #100 SRVAL;
	    end
	    else begin
		if (we_int == 1'b1) begin
		    if (wr_mode == 2'b00) begin
			do_out <= #100 di_int;
			dop_out <= #100 dip_int;
		    end
		    else if (wr_mode == 2'b01) begin
			do_out <= #100 mem[addr_int];
			dop_out <= #100 memp[addr_int];
		    end
		end
		else begin
		    do_out <= #100 mem[addr_int];
		    dop_out <= #100 memp[addr_int];
		end
	    end

	    // memory
	    if (we_int == 1'b1) begin
		mem[addr_int] <= di_int;
		memp[addr_int] <= dip_int;
	    end

	end
    end


endmodule

`endif
