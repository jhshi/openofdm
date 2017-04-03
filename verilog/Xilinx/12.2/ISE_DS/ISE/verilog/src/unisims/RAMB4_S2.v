// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAMB4_S2.v,v 1.6 2005/03/14 22:54:42 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  4K-Bit Data Single Port Block RAM
// /___/   /\     Filename : RAMB4_S2.v
// \   \  /  \    Timestamp : Thu Mar 10 16:43:38 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`ifdef legacy_model

`timescale  1 ps / 1 ps


module RAMB4_S2 (DO, ADDR, CLK, DI, EN, RST, WE);

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

    output [1:0] DO;
    reg d0_out, d1_out;

    input [10:0] ADDR;
    input [1:0] DI;
    input EN, CLK, WE, RST;

    reg [4095:0] mem;
    reg [8:0] count;

    wire [10:0] addr_int;
    wire [1:0] di_int;
    wire en_int, clk_int, we_int, rst_int;

    tri0 GSR = glbl.GSR;

    always @(GSR)
	if (GSR)
	    begin
		assign d0_out = 0;
		assign d1_out = 0;
	    end
	else
	    begin
		deassign d0_out;
		deassign d1_out;
	    end

    buf b_do_out0 (DO[0], d0_out);
    buf b_do_out1 (DO[1], d1_out);
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
    buf b_en (en_int, EN);
    buf b_clk (clk_int, CLK);
    buf b_we (we_int, WE);
    buf b_rst (rst_int, RST);

    initial
    begin
	for (count = 0; count < 256; count = count + 1)
	begin
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
	end
    end

    always @(posedge clk_int)
    begin
	if (en_int == 1'b1)
	    if (rst_int == 1'b1)
		begin
		    d0_out <= 0;
		    d1_out <= 0;
		end
	    else
		if (we_int == 1'b1)
		    begin
			d0_out <= di_int[0];
			d1_out <= di_int[1];
		    end
		else
		    begin
			d0_out <= mem[addr_int * 2];
			d1_out <= mem[addr_int * 2 + 1];
		    end
    end

    always @(posedge clk_int)
    begin
	if (en_int == 1'b1 && we_int == 1'b1)
	    begin
		mem[addr_int * 2] <= di_int[0];
		mem[addr_int * 2 + 1] <= di_int[1];
	    end
    end

    specify
	(CLK *> DO) = (100, 100);
    endspecify

endmodule

`else


// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAMB4_S2.v,v 1.6 2005/03/14 22:54:42 wloo Exp $
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
// /___/   /\     Filename : RAMB4_S2.v
// \   \  /  \    Timestamp : Thu Mar 10 16:44:01 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/10/05 - Initialized outputs.
// End Revision

`timescale 1 ps/1 ps

module RAMB4_S2 (DO, ADDR, CLK, DI, EN, RST, WE);

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
    
    output [1:0] DO;

    input [10:0] ADDR;
    input [1:0] DI;
    input EN, CLK, WE, RST;

    reg [1:0] do_out = 0;
    
    reg [1:0] mem [2047:0];
    
    reg [8:0] count;

    wire [10:0] addr_int;
    wire [1:0] di_int;
    wire en_int, clk_int, we_int, rst_int;

    wire di_enable = en_int && we_int;

    tri0 GSR = glbl.GSR;
    wire gsr_int;

    buf b_gsr (gsr_int, GSR);

    buf b_do [1:0] (DO, do_out);
    buf b_addr [10:0] (addr_int, ADDR);
    buf b_di [1:0] (di_int, DI);
    buf b_en (en_int, EN);
    buf b_clk (clk_int, CLK);
    buf b_rst (rst_int, RST);
    buf b_we (we_int, WE);

    
    always @(gsr_int)
	if (gsr_int) begin
	    assign do_out = 0;
	end
	else begin
	    deassign do_out;
	end

    
    initial begin

	for (count = 0; count < 128; count = count + 1) begin
	    mem[count]          = INIT_00[(count * 2) +: 2];
	    mem[128 * 1 + count]  = INIT_01[(count * 2) +: 2];
	    mem[128 * 2 + count]  = INIT_02[(count * 2) +: 2];
	    mem[128 * 3 + count]  = INIT_03[(count * 2) +: 2];
	    mem[128 * 4 + count]  = INIT_04[(count * 2) +: 2];
	    mem[128 * 5 + count]  = INIT_05[(count * 2) +: 2];
	    mem[128 * 6 + count]  = INIT_06[(count * 2) +: 2];
	    mem[128 * 7 + count]  = INIT_07[(count * 2) +: 2];
	    mem[128 * 8 + count]  = INIT_08[(count * 2) +: 2];
	    mem[128 * 9 + count]  = INIT_09[(count * 2) +: 2];
	    mem[128 * 10 + count] = INIT_0A[(count * 2) +: 2];
	    mem[128 * 11 + count] = INIT_0B[(count * 2) +: 2];
	    mem[128 * 12 + count] = INIT_0C[(count * 2) +: 2];
	    mem[128 * 13 + count] = INIT_0D[(count * 2) +: 2];
	    mem[128 * 14 + count] = INIT_0E[(count * 2) +: 2];
	    mem[128 * 15 + count] = INIT_0F[(count * 2) +: 2];
	end

    end // initial begin
	

    always @(posedge clk_int) begin

	if (en_int == 1'b1) begin

	    if (rst_int == 1'b1)
		do_out <= #100 0;
	    
	    else
		if (we_int == 1'b1)
		    do_out <= #100 di_int;
	    
		else
		    do_out <= #100 mem[addr_int];
	    
	    // memory
	    if (we_int == 1'b1)
		mem[addr_int] <= di_int;

	end
    end


endmodule

`endif
