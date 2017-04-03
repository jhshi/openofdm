// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAMB4_S2_S16.v,v 1.9 2007/02/22 01:58:06 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  4K-Bit Data Dual Port Block RAM
// /___/   /\     Filename : RAMB4_S2_S16.v
// \   \  /  \    Timestamp : Thu Mar 10 16:43:38 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`ifdef legacy_model

`timescale  1 ps / 1 ps

module RAMB4_S2_S16 (DOA, DOB, ADDRA, ADDRB, CLKA, CLKB, DIA, DIB, ENA, ENB, RSTA, RSTB, WEA, WEB);

    parameter SIM_COLLISION_CHECK = "ALL";
    localparam SETUP_ALL = 100;

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

    output [1:0] DOA;
    reg [1:0] doa_out;
    wire doa_out0, doa_out1;

    input [10:0] ADDRA;
    input [1:0] DIA;
    input ENA, CLKA, WEA, RSTA;

    output [15:0] DOB;
    reg [15:0] dob_out;
    wire dob_out0, dob_out1, dob_out2, dob_out3, dob_out4, dob_out5, dob_out6, dob_out7, dob_out8, dob_out9, dob_out10, dob_out11, dob_out12, dob_out13, dob_out14, dob_out15;

    input [7:0] ADDRB;
    input [15:0] DIB;
    input ENB, CLKB, WEB, RSTB;

    reg [4095:0] mem;
    reg [8:0] count;

    reg [5:0] mi, mj, ai, aj, bi, bj, ci, cj, di, dj, ei, ej, fi, fj;

    wire [10:0] addra_int;
    reg [10:0] addra_reg;
    wire [1:0] dia_int;
    wire ena_int, clka_int, wea_int, rsta_int;
    reg ena_reg, wea_reg, rsta_reg;
    wire [7:0] addrb_int;
    reg [7:0] addrb_reg;
    wire [15:0] dib_int;
    wire enb_int, clkb_int, web_int, rstb_int;
    reg enb_reg, web_reg, rstb_reg;

    time time_clka, time_clkb;
    time time_clka_clkb;
    time time_clkb_clka;

    reg setup_all_a_b;
    reg setup_all_b_a;
    reg setup_zero;
    reg [1:0] data_collision, data_collision_a_b, data_collision_b_a;
    reg memory_collision, memory_collision_a_b, memory_collision_b_a;
    reg address_collision, address_collision_a_b, address_collision_b_a;
    reg change_clka;
    reg change_clkb;

    wire [11:0] mem_addra_int;
    wire [11:0] mem_addra_reg;
    wire [11:0] mem_addrb_int;
    wire [11:0] mem_addrb_reg;

    tri0 GSR = glbl.GSR;

    always @(GSR)
	if (GSR) begin
	    assign doa_out = 0;
	end
	else begin
	    deassign doa_out;
	end

    always @(GSR)
	if (GSR) begin
	    assign dob_out = 0;
	end
	else begin
	    deassign dob_out;
	end

    buf b_doa_out0 (doa_out0, doa_out[0]);
    buf b_doa_out1 (doa_out1, doa_out[1]);
    buf b_dob_out0 (dob_out0, dob_out[0]);
    buf b_dob_out1 (dob_out1, dob_out[1]);
    buf b_dob_out2 (dob_out2, dob_out[2]);
    buf b_dob_out3 (dob_out3, dob_out[3]);
    buf b_dob_out4 (dob_out4, dob_out[4]);
    buf b_dob_out5 (dob_out5, dob_out[5]);
    buf b_dob_out6 (dob_out6, dob_out[6]);
    buf b_dob_out7 (dob_out7, dob_out[7]);
    buf b_dob_out8 (dob_out8, dob_out[8]);
    buf b_dob_out9 (dob_out9, dob_out[9]);
    buf b_dob_out10 (dob_out10, dob_out[10]);
    buf b_dob_out11 (dob_out11, dob_out[11]);
    buf b_dob_out12 (dob_out12, dob_out[12]);
    buf b_dob_out13 (dob_out13, dob_out[13]);
    buf b_dob_out14 (dob_out14, dob_out[14]);
    buf b_dob_out15 (dob_out15, dob_out[15]);
    buf b_doa0 (DOA[0], doa_out0);
    buf b_doa1 (DOA[1], doa_out1);
    buf b_dob0 (DOB[0], dob_out0);
    buf b_dob1 (DOB[1], dob_out1);
    buf b_dob2 (DOB[2], dob_out2);
    buf b_dob3 (DOB[3], dob_out3);
    buf b_dob4 (DOB[4], dob_out4);
    buf b_dob5 (DOB[5], dob_out5);
    buf b_dob6 (DOB[6], dob_out6);
    buf b_dob7 (DOB[7], dob_out7);
    buf b_dob8 (DOB[8], dob_out8);
    buf b_dob9 (DOB[9], dob_out9);
    buf b_dob10 (DOB[10], dob_out10);
    buf b_dob11 (DOB[11], dob_out11);
    buf b_dob12 (DOB[12], dob_out12);
    buf b_dob13 (DOB[13], dob_out13);
    buf b_dob14 (DOB[14], dob_out14);
    buf b_dob15 (DOB[15], dob_out15);
    buf b_addra_0 (addra_int[0], ADDRA[0]);
    buf b_addra_1 (addra_int[1], ADDRA[1]);
    buf b_addra_2 (addra_int[2], ADDRA[2]);
    buf b_addra_3 (addra_int[3], ADDRA[3]);
    buf b_addra_4 (addra_int[4], ADDRA[4]);
    buf b_addra_5 (addra_int[5], ADDRA[5]);
    buf b_addra_6 (addra_int[6], ADDRA[6]);
    buf b_addra_7 (addra_int[7], ADDRA[7]);
    buf b_addra_8 (addra_int[8], ADDRA[8]);
    buf b_addra_9 (addra_int[9], ADDRA[9]);
    buf b_addra_10 (addra_int[10], ADDRA[10]);
    buf b_dia_0 (dia_int[0], DIA[0]);
    buf b_dia_1 (dia_int[1], DIA[1]);
    buf b_clka (clka_int, CLKA);
    buf b_ena (ena_int, ENA);
    buf b_rsta (rsta_int, RSTA);
    buf b_wea (wea_int, WEA);
    buf b_addrb_0 (addrb_int[0], ADDRB[0]);
    buf b_addrb_1 (addrb_int[1], ADDRB[1]);
    buf b_addrb_2 (addrb_int[2], ADDRB[2]);
    buf b_addrb_3 (addrb_int[3], ADDRB[3]);
    buf b_addrb_4 (addrb_int[4], ADDRB[4]);
    buf b_addrb_5 (addrb_int[5], ADDRB[5]);
    buf b_addrb_6 (addrb_int[6], ADDRB[6]);
    buf b_addrb_7 (addrb_int[7], ADDRB[7]);
    buf b_dib_0 (dib_int[0], DIB[0]);
    buf b_dib_1 (dib_int[1], DIB[1]);
    buf b_dib_2 (dib_int[2], DIB[2]);
    buf b_dib_3 (dib_int[3], DIB[3]);
    buf b_dib_4 (dib_int[4], DIB[4]);
    buf b_dib_5 (dib_int[5], DIB[5]);
    buf b_dib_6 (dib_int[6], DIB[6]);
    buf b_dib_7 (dib_int[7], DIB[7]);
    buf b_dib_8 (dib_int[8], DIB[8]);
    buf b_dib_9 (dib_int[9], DIB[9]);
    buf b_dib_10 (dib_int[10], DIB[10]);
    buf b_dib_11 (dib_int[11], DIB[11]);
    buf b_dib_12 (dib_int[12], DIB[12]);
    buf b_dib_13 (dib_int[13], DIB[13]);
    buf b_dib_14 (dib_int[14], DIB[14]);
    buf b_dib_15 (dib_int[15], DIB[15]);
    buf b_clkb (clkb_int, CLKB);
    buf b_enb (enb_int, ENB);
    buf b_rstb (rstb_int, RSTB);
    buf b_web (web_int, WEB);

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
	end
	address_collision <= 0;
	address_collision_a_b <= 0;
	address_collision_b_a <= 0;
	change_clka <= 0;
	change_clkb <= 0;
	data_collision <= 0;
	data_collision_a_b <= 0;
	data_collision_b_a <= 0;
	memory_collision <= 0;
	memory_collision_a_b <= 0;
	memory_collision_b_a <= 0;
	setup_all_a_b <= 0;
	setup_all_b_a <= 0;
	setup_zero <= 0;
    end

    assign mem_addra_int = addra_int * 2;
    assign mem_addra_reg = addra_reg * 2;
    assign mem_addrb_int = addrb_int * 16;
    assign mem_addrb_reg = addrb_reg * 16;


    initial begin

	case (SIM_COLLISION_CHECK)

	    "NONE" : begin
		         assign setup_all_a_b = 1'b0;
	                 assign setup_all_b_a = 1'b0;
	                 assign setup_zero = 1'b0;
			 assign address_collision = 1'b0;
			 assign address_collision_a_b = 1'b0;
			 assign address_collision_b_a = 1'b0;
	             end
	    "WARNING_ONLY" : begin
		                 assign data_collision = 2'b00;
	                         assign data_collision_a_b = 2'b00;
	                         assign data_collision_b_a = 2'b00;
	                         assign memory_collision = 1'b0;
	                         assign memory_collision_a_b = 1'b0;
	                         assign memory_collision_b_a = 1'b0;
	                     end
	    "GENERATE_X_ONLY" : begin
		                    assign address_collision = 1'b0;
		                    assign address_collision_a_b = 1'b0;
		                    assign address_collision_b_a = 1'b0;
	                        end
	    "ALL" : ;
	    default : begin
		          $display("Attribute Syntax Error : The Attribute SIM_COLLISION_CHECK on RAMB4_S2_S16 instance %m is set to %s.  Legal values for this attribute are ALL, NONE, WARNING_ONLY or GENERATE_X_ONLY.", SIM_COLLISION_CHECK);
		          $finish;
	              end

	endcase // case(SIM_COLLISION_CHECK)

    end // initial begin


    always @(posedge clka_int) begin
	time_clka = $time;
	#0 time_clkb_clka = time_clka - time_clkb;
	change_clka = ~change_clka;
    end

    always @(posedge clkb_int) begin
	time_clkb = $time;
	#0 time_clka_clkb = time_clkb - time_clka;
	change_clkb = ~change_clkb;
    end

    always @(change_clkb) begin
	if ((0 < time_clka_clkb) && (time_clka_clkb < SETUP_ALL))
	    setup_all_a_b = 1;
    end

    always @(change_clka) begin
	if ((0 < time_clkb_clka) && (time_clkb_clka < SETUP_ALL))
	    setup_all_b_a = 1;
    end

    always @(change_clkb or change_clka) begin
	if ((time_clkb_clka == 0) && (time_clka_clkb == 0))
	    setup_zero = 1;
    end

    always @(posedge setup_zero) begin
	if ((ena_int == 1) && (wea_int == 1) &&
	    (enb_int == 1) && (web_int == 1))
	    memory_collision <= 1;
    end

    always @(posedge setup_all_a_b) begin
	if ((ena_reg == 1) && (enb_int == 1)) begin
	    case ({wea_reg, web_int})
		6'b11 : begin data_collision_a_b <= 2'b11; display_all_a_b; end
		6'b01 : begin data_collision_a_b <= 2'b10; display_all_a_b; end
		6'b10 : begin data_collision_a_b <= 2'b01; display_all_a_b; end
	    endcase
	end
	setup_all_a_b <= 0;
    end

    task display_all_a_b;
    begin
	address_collision_a_b = 1'b0;
	for (ci = 0; ci < 16; ci = ci + 2) begin
	    if ((mem_addra_reg) == (mem_addrb_int + ci)) begin
		address_collision_a_b = 1'b1;
	    end
	end
	if (address_collision_a_b == 1'b1)

            if (({wea_reg, web_int}) == 2'b11)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA write was requested to the same address simultaneously at both Port A and Port B of the RAM. The contents written to the RAM at address location %h (hex) of Port A and address location %h (hex) of Port B are unknown.", $time/1000.0, addra_int, addrb_int);

            else if (({wea_reg, web_int}) == 2'b01)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port A while a write was requested to the same address on Port B. The write will be successful however the read value on Port A is unknown until the next CLKA cycle.", $time/1000.0, addra_int);

            else if (({wea_reg, web_int}) == 2'b10)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port B while a write was requested to the same address on Port A. The write will be successful however the read value on Port B is unknown until the next CLKB cycle.", $time/1000.0, addrb_int);

    end
    endtask

    always @(posedge setup_all_b_a) begin
	if ((ena_int == 1) && (enb_reg == 1)) begin
	    case ({wea_int, web_reg})
		6'b11 : begin data_collision_b_a <= 2'b11; display_all_b_a; end
		6'b01 : begin data_collision_b_a <= 2'b10; display_all_b_a; end
		6'b10 : begin data_collision_b_a <= 2'b01; display_all_b_a; end
	    endcase
	end
	setup_all_b_a <= 0;
    end

    task display_all_b_a;
    begin
	address_collision_b_a = 1'b0;
	for (ci = 0; ci < 16; ci = ci + 2) begin
	    if ((mem_addra_int) == (mem_addrb_reg + ci)) begin
		address_collision_b_a = 1'b1;
	    end
	end
	if (address_collision_b_a == 1'b1)

            if (({wea_int, web_reg}) == 2'b11)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA write was requested to the same address simultaneously at both Port A and Port B of the RAM. The contents written to the RAM at address location %h (hex) of Port A and address location %h (hex) of Port B are unknown.", $time/1000.0, addra_int, addrb_int);

            else if (({wea_int, web_reg}) == 2'b01)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port A while a write was requested to the same address on Port B. The write will be successful however the read value on Port A is unknown until the next CLKA cycle.", $time/1000.0, addra_int);

            else if (({wea_int, web_reg}) == 2'b10)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port B while a write was requested to the same address on Port A. The write will be successful however the read value on Port B is unknown until the next CLKB cycle.", $time/1000.0, addrb_int);

    end
    endtask

    always @(posedge setup_zero) begin
	if ((ena_int == 1) && (enb_int == 1)) begin
	    case ({wea_int, web_int})
		6'b11 : begin data_collision <= 2'b11; display_zero; end
		6'b01 : begin data_collision <= 2'b10; display_zero; end
		6'b10 : begin data_collision <= 2'b01; display_zero; end
	    endcase
	end
	setup_zero <= 0;
    end

    task display_zero;
    begin
	address_collision = 1'b0;
	for (ci = 0; ci < 16; ci = ci + 2) begin
	    if ((mem_addra_int) == (mem_addrb_int + ci)) begin
		address_collision = 1'b1;
	    end
	end
	if (address_collision == 1'b1)

            if (({wea_int, web_int}) == 2'b11)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA write was requested to the same address simultaneously at both Port A and Port B of the RAM. The contents written to the RAM at address location %h (hex) of Port A and address location %h (hex) of Port B are unknown.", $time/1000.0, addra_int, addrb_int);

            else if (({wea_int, web_int}) == 2'b01)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port A while a write was requested to the same address on Port B. The write will be successful however the read value on Port A is unknown until the next CLKA cycle.", $time/1000.0, addra_int);

            else if (({wea_int, web_int}) == 2'b10)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port B while a write was requested to the same address on Port A. The write will be successful however the read value on Port B is unknown until the next CLKB cycle.", $time/1000.0, addrb_int);

    end
    endtask

    always @(posedge clka_int) begin
	addra_reg <= addra_int;
	ena_reg <= ena_int;
	rsta_reg <= rsta_int;
	wea_reg <= wea_int;
    end

    always @(posedge clkb_int) begin
	addrb_reg <= addrb_int;
	enb_reg <= enb_int;
	rstb_reg <= rstb_int;
	web_reg <= web_int;
    end

    // Data
    always @(posedge memory_collision) begin
	for (mi = 0; mi < 16; mi = mi + 2) begin
	    if ((mem_addra_int) == (mem_addrb_int + mi)) begin
		for (mj = 0; mj < 2; mj = mj + 1) begin
		    mem[mem_addrb_int + mi + mj] <= 1'bX;
		end
	    end
	end
	memory_collision <= 0;
    end

    always @(posedge memory_collision_a_b) begin
	for (mi = 0; mi < 16; mi = mi + 2) begin
	    if ((mem_addra_reg) == (mem_addrb_int + mi)) begin
		for (mj = 0; mj < 2; mj = mj + 1) begin
		    mem[mem_addrb_int + mi + mj] <= 1'bX;
		end
	    end
	end
	memory_collision_a_b <= 0;
    end

    always @(posedge memory_collision_b_a) begin
	for (mi = 0; mi < 16; mi = mi + 2) begin
	    if ((mem_addra_int) == (mem_addrb_reg + mi)) begin
		for (mj = 0; mj < 2; mj = mj + 1) begin
		    mem[mem_addrb_reg + mi + mj] <= 1'bX;
		end
	    end
	end
	memory_collision_b_a <= 0;
    end

    always @(posedge data_collision[1]) begin
	if (rsta_int == 0) begin
	    for (ai = 0; ai < 16; ai = ai + 2) begin
		if ((mem_addra_int) == (mem_addrb_int + ai)) begin
		    doa_out <= 2'bX;
		end
	    end
	end
	data_collision[1] <= 0;
    end

    always @(posedge data_collision[0]) begin
	if (rstb_int == 0) begin
	    for (bi = 0; bi < 16; bi = bi + 2) begin
		if ((mem_addra_int) == (mem_addrb_int + bi)) begin
		    for (bj = 0; bj < 2; bj = bj + 1) begin
			dob_out[bi + bj] <= 1'bX;
		    end
		end
	    end
	end
	data_collision[0] <= 0;
    end

    always @(posedge data_collision_a_b[1]) begin
	if (rsta_reg == 0) begin
	    for (ai = 0; ai < 16; ai = ai + 2) begin
		if ((mem_addra_reg) == (mem_addrb_int + ai)) begin
		    doa_out <= 2'bX;
		end
	    end
	end
	data_collision_a_b[1] <= 0;
    end

    always @(posedge data_collision_a_b[0]) begin
	if (rstb_int == 0) begin
	    for (bi = 0; bi < 16; bi = bi + 2) begin
		if ((mem_addra_reg) == (mem_addrb_int + bi)) begin
		    for (bj = 0; bj < 2; bj = bj + 1) begin
			dob_out[bi + bj] <= 1'bX;
		    end
		end
	    end
	end
	data_collision_a_b[0] <= 0;
    end

    always @(posedge data_collision_b_a[1]) begin
	if (rsta_int == 0) begin
	    for (ai = 0; ai < 16; ai = ai + 2) begin
		if ((mem_addra_int) == (mem_addrb_reg + ai)) begin
		    doa_out <= 2'bX;
		end
	    end
	end
	data_collision_b_a[1] <= 0;
    end

    always @(posedge data_collision_b_a[0]) begin
	if (rstb_reg == 0) begin
	    for (bi = 0; bi < 16; bi = bi + 2) begin
		if ((mem_addra_int) == (mem_addrb_reg + bi)) begin
		    for (bj = 0; bj < 2; bj = bj + 1) begin
			dob_out[bi + bj] <= 1'bX;
		    end
		end
	    end
	end
	data_collision_b_a[0] <= 0;
    end


    always @(posedge clka_int) begin
	if (ena_int == 1'b1) begin
	    if (rsta_int == 1'b1) begin
		doa_out <= 2'b0;
	    end
	    else if (wea_int == 0) begin
		doa_out[0] <= mem[mem_addra_int + 0];
		doa_out[1] <= mem[mem_addra_int + 1];
	    end
	    else begin
		doa_out <= dia_int;
	    end
	end
    end

    always @(posedge clka_int) begin
	if (ena_int == 1'b1 && wea_int == 1'b1) begin
	    mem[mem_addra_int + 0] <= dia_int[0];
	    mem[mem_addra_int + 1] <= dia_int[1];
	end
    end

    always @(posedge clkb_int) begin
	if (enb_int == 1'b1) begin
	    if (rstb_int == 1'b1) begin
		dob_out <= 16'b0;
	    end
	    else if (web_int == 0) begin
		dob_out[0] <= mem[mem_addrb_int + 0];
		dob_out[1] <= mem[mem_addrb_int + 1];
		dob_out[2] <= mem[mem_addrb_int + 2];
		dob_out[3] <= mem[mem_addrb_int + 3];
		dob_out[4] <= mem[mem_addrb_int + 4];
		dob_out[5] <= mem[mem_addrb_int + 5];
		dob_out[6] <= mem[mem_addrb_int + 6];
		dob_out[7] <= mem[mem_addrb_int + 7];
		dob_out[8] <= mem[mem_addrb_int + 8];
		dob_out[9] <= mem[mem_addrb_int + 9];
		dob_out[10] <= mem[mem_addrb_int + 10];
		dob_out[11] <= mem[mem_addrb_int + 11];
		dob_out[12] <= mem[mem_addrb_int + 12];
		dob_out[13] <= mem[mem_addrb_int + 13];
		dob_out[14] <= mem[mem_addrb_int + 14];
		dob_out[15] <= mem[mem_addrb_int + 15];
	    end
	    else begin
		dob_out <= dib_int;
	    end
	end
    end

    always @(posedge clkb_int) begin
	if (enb_int == 1'b1 && web_int == 1'b1) begin
	    mem[mem_addrb_int + 0] <= dib_int[0];
	    mem[mem_addrb_int + 1] <= dib_int[1];
	    mem[mem_addrb_int + 2] <= dib_int[2];
	    mem[mem_addrb_int + 3] <= dib_int[3];
	    mem[mem_addrb_int + 4] <= dib_int[4];
	    mem[mem_addrb_int + 5] <= dib_int[5];
	    mem[mem_addrb_int + 6] <= dib_int[6];
	    mem[mem_addrb_int + 7] <= dib_int[7];
	    mem[mem_addrb_int + 8] <= dib_int[8];
	    mem[mem_addrb_int + 9] <= dib_int[9];
	    mem[mem_addrb_int + 10] <= dib_int[10];
	    mem[mem_addrb_int + 11] <= dib_int[11];
	    mem[mem_addrb_int + 12] <= dib_int[12];
	    mem[mem_addrb_int + 13] <= dib_int[13];
	    mem[mem_addrb_int + 14] <= dib_int[14];
	    mem[mem_addrb_int + 15] <= dib_int[15];
	end
    end

    specify
	(CLKA *> DOA) = (100, 100);
	(CLKB *> DOB) = (100, 100);
    endspecify

endmodule

`else

// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/RAMB4_S2_S16.v,v 1.9 2007/02/22 01:58:06 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Timing Simulation Library Component
//  /   /                  16K-Bit Data and 2K-Bit Parity Dual Port Block RAM
// /___/   /\     Filename : RAMB4_S2_S16.v
// \   \  /  \    Timestamp : Thu Mar 10 16:44:01 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/10/05 - Initialized outputs.
//    02/21/07 - Fixed parameter SIM_COLLISION_CHECK (CR 433281).
// End Revision

`timescale 1 ps/1 ps

module RAMB4_S2_S16 (DOA, DOB, ADDRA, ADDRB, CLKA, CLKB, DIA, DIB, ENA, ENB, RSTA, RSTB, WEA, WEB);

    parameter SIM_COLLISION_CHECK = "ALL";
    localparam SETUP_ALL = 100;
    
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

    output [1:0] DOA;
    output [15:0] DOB;

    input [10:0] ADDRA;
    input [1:0] DIA;
    input ENA, CLKA, WEA, RSTA;
    input [7:0] ADDRB;
    input [15:0] DIB;
    input ENB, CLKB, WEB, RSTB;

    reg [1:0] doa_out = 0;
    reg [15:0] dob_out = 0;
    
    reg [15:0] mem [255:0];
    
    reg [8:0] count;

    reg [5:0] mi, ai, bi, bj, ci;

    wire [10:0] addra_int;
    reg [10:0] addra_reg;
    wire [1:0] dia_int;
    wire ena_int, clka_int, wea_int, rsta_int;
    reg ena_reg, wea_reg, rsta_reg;
    wire [7:0] addrb_int;
    reg [7:0] addrb_reg;
    wire [15:0] dib_int;
    wire enb_int, clkb_int, web_int, rstb_int;
    reg display_flag, output_flag;
    reg enb_reg, web_reg, rstb_reg;

    time time_clka, time_clkb;
    time time_clka_clkb;
    time time_clkb_clka;

    reg setup_all_a_b;
    reg setup_all_b_a;
    reg setup_zero;
    reg [1:0] data_collision, data_collision_a_b, data_collision_b_a;
    reg memory_collision, memory_collision_a_b, memory_collision_b_a;
    reg address_collision, address_collision_a_b, address_collision_b_a;
    reg change_clka;
    reg change_clkb;

    wire [11:0] mem_addra_int;
    wire [11:0] mem_addra_reg;
    wire [11:0] mem_addrb_int;
    wire [11:0] mem_addrb_reg;
    
    wire dia_enable = ena_int && wea_int;
    wire dib_enable = enb_int && web_int;

    tri0 GSR = glbl.GSR;
    wire gsr_int;

    buf b_gsr (gsr_int, GSR);

    buf b_doa [1:0] (DOA, doa_out);
    buf b_addra [10:0] (addra_int, ADDRA);
    buf b_dia [1:0] (dia_int, DIA);
    buf b_ena (ena_int, ENA);
    buf b_clka (clka_int, CLKA);
    buf b_rsta (rsta_int, RSTA);
    buf b_wea (wea_int, WEA);

    buf b_dob [15:0] (DOB, dob_out);
    buf b_addrb [7:0] (addrb_int, ADDRB);
    buf b_dib [15:0] (dib_int, DIB);
    buf b_enb (enb_int, ENB);
    buf b_clkb (clkb_int, CLKB);
    buf b_rstb (rstb_int, RSTB);
    buf b_web (web_int, WEB);

    
    always @(gsr_int)
	if (gsr_int) begin
	    assign doa_out = 0;
	    assign dob_out = 0;
	end
	else begin
	    deassign doa_out;
	    deassign dob_out;
	end

    
    initial begin

	for (count = 0; count < 16; count = count + 1) begin
	    mem[count]          = INIT_00[(count * 16) +: 16];
	    mem[16 * 1 + count]  = INIT_01[(count * 16) +: 16];
	    mem[16 * 2 + count]  = INIT_02[(count * 16) +: 16];
	    mem[16 * 3 + count]  = INIT_03[(count * 16) +: 16];
	    mem[16 * 4 + count]  = INIT_04[(count * 16) +: 16];
	    mem[16 * 5 + count]  = INIT_05[(count * 16) +: 16];
	    mem[16 * 6 + count]  = INIT_06[(count * 16) +: 16];
	    mem[16 * 7 + count]  = INIT_07[(count * 16) +: 16];
	    mem[16 * 8 + count]  = INIT_08[(count * 16) +: 16];
	    mem[16 * 9 + count]  = INIT_09[(count * 16) +: 16];
	    mem[16 * 10 + count] = INIT_0A[(count * 16) +: 16];
	    mem[16 * 11 + count] = INIT_0B[(count * 16) +: 16];
	    mem[16 * 12 + count] = INIT_0C[(count * 16) +: 16];
	    mem[16 * 13 + count] = INIT_0D[(count * 16) +: 16];
	    mem[16 * 14 + count] = INIT_0E[(count * 16) +: 16];
	    mem[16 * 15 + count] = INIT_0F[(count * 16) +: 16];
	end

	change_clka <= 0;
	change_clkb <= 0;
	data_collision <= 0;
	data_collision_a_b <= 0;
	data_collision_b_a <= 0;
	memory_collision <= 0;
	memory_collision_a_b <= 0;
	memory_collision_b_a <= 0;
	setup_all_a_b <= 0;
	setup_all_b_a <= 0;
	setup_zero <= 0;
    end

    assign mem_addra_int = addra_int * 2;
    assign mem_addra_reg = addra_reg * 2;
    assign mem_addrb_int = addrb_int * 16;
    assign mem_addrb_reg = addrb_reg * 16;

    
    initial begin

	display_flag = 1;
	output_flag = 1;
	
	case (SIM_COLLISION_CHECK)

	    "NONE" : begin
		         output_flag = 0;
	                 display_flag = 0;
	             end
	    "WARNING_ONLY" : output_flag = 0;
	    "GENERATE_X_ONLY" : display_flag = 0;
	    "ALL" : ;

	    default : begin
		          $display("Attribute Syntax Error : The Attribute SIM_COLLISION_CHECK on RAMB4_S2_S16 instance %m is set to %s.  Legal values for this attribute are ALL, NONE, WARNING_ONLY or GENERATE_X_ONLY.", SIM_COLLISION_CHECK);
		          $finish;
	              end

	endcase // case(SIM_COLLISION_CHECK)

    end // initial begin

    
    always @(posedge clka_int) begin
	if ((output_flag || display_flag)) begin
	    time_clka = $time;
	    #0 time_clkb_clka = time_clka - time_clkb;
	    change_clka = ~change_clka;
	end
    end
    
    always @(posedge clkb_int) begin
	if ((output_flag || display_flag)) begin
	    time_clkb = $time;
	    #0 time_clka_clkb = time_clkb - time_clka;
	    change_clkb = ~change_clkb;
	end
    end
    
    always @(change_clkb) begin
	if ((0 < time_clka_clkb) && (time_clka_clkb < SETUP_ALL))
	    setup_all_a_b = 1;
    end

    always @(change_clka) begin
	if ((0 < time_clkb_clka) && (time_clkb_clka < SETUP_ALL))
	    setup_all_b_a = 1;
    end

    always @(change_clkb or change_clka) begin
	if ((time_clkb_clka == 0) && (time_clka_clkb == 0))
	    setup_zero = 1;
    end

    always @(posedge setup_zero) begin
	if ((ena_int == 1) && (wea_int == 1) &&
	    (enb_int == 1) && (web_int == 1))
	    memory_collision <= 1;
    end

    always @(posedge setup_all_a_b) begin
	if ((ena_reg == 1) && (enb_int == 1)) begin
	    case ({wea_reg, web_int})
		6'b11 : begin data_collision_a_b <= 2'b11; display_all_a_b; end
		6'b01 : begin data_collision_a_b <= 2'b10; display_all_a_b; end
		6'b10 : begin data_collision_a_b <= 2'b01; display_all_a_b; end
	    endcase
	end
	setup_all_a_b <= 0;
    end

    task display_all_a_b;
    begin
	address_collision_a_b = 1'b0;
	for (ci = 0; ci < 16; ci = ci + 2) begin
	    if ((mem_addra_reg) == (mem_addrb_int + ci)) begin
		address_collision_a_b = 1'b1;
	    end
	end
	if (address_collision_a_b == 1'b1 && display_flag)

            if (({wea_reg, web_int}) == 2'b11)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA write was requested to the same address simultaneously at both Port A and Port B of the RAM. The contents written to the RAM at address location %h (hex) of Port A and address location %h (hex) of Port B are unknown.", $time/1000.0, addra_int, addrb_int);

            else if (({wea_reg, web_int}) == 2'b01)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port A while a write was requested to the same address on Port B. The write will be successful however the read value on Port A is unknown until the next CLKA cycle.", $time/1000.0, addra_int);

            else if (({wea_reg, web_int}) == 2'b10)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port B while a write was requested to the same address on Port A. The write will be successful however the read value on Port B is unknown until the next CLKB cycle.", $time/1000.0, addrb_int);

    end
    endtask

    always @(posedge setup_all_b_a) begin
	if ((ena_int == 1) && (enb_reg == 1)) begin
	    case ({wea_int, web_reg})
		6'b11 : begin data_collision_b_a <= 2'b11; display_all_b_a; end
		6'b01 : begin data_collision_b_a <= 2'b10; display_all_b_a; end
		6'b10 : begin data_collision_b_a <= 2'b01; display_all_b_a; end
	    endcase
	end
	setup_all_b_a <= 0;
    end

    task display_all_b_a;
    begin
	address_collision_b_a = 1'b0;
	for (ci = 0; ci < 16; ci = ci + 2) begin
	    if ((mem_addra_int) == (mem_addrb_reg + ci)) begin
		address_collision_b_a = 1'b1;
	    end
	end
	if (address_collision_b_a == 1'b1 && display_flag)

            if (({wea_int, web_reg}) == 2'b11)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA write was requested to the same address simultaneously at both Port A and Port B of the RAM. The contents written to the RAM at address location %h (hex) of Port A and address location %h (hex) of Port B are unknown.", $time/1000.0, addra_int, addrb_int);

            else if (({wea_int, web_reg}) == 2'b01)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port A while a write was requested to the same address on Port B. The write will be successful however the read value on Port A is unknown until the next CLKA cycle.", $time/1000.0, addra_int);

            else if (({wea_int, web_reg}) == 2'b10)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port B while a write was requested to the same address on Port A. The write will be successful however the read value on Port B is unknown until the next CLKB cycle.", $time/1000.0, addrb_int);

    end
    endtask

    always @(posedge setup_zero) begin
	if ((ena_int == 1) && (enb_int == 1)) begin
	    case ({wea_int, web_int})
		6'b11 : begin data_collision <= 2'b11; display_zero; end
		6'b01 : begin data_collision <= 2'b10; display_zero; end
		6'b10 : begin data_collision <= 2'b01; display_zero; end
	    endcase
	end
	setup_zero <= 0;
    end

    task display_zero;
    begin
	address_collision = 1'b0;
	for (ci = 0; ci < 16; ci = ci + 2) begin
	    if ((mem_addra_int) == (mem_addrb_int + ci)) begin
		address_collision = 1'b1;
	    end
	end
	if (address_collision == 1'b1 && display_flag)

            if (({wea_int, web_int}) == 2'b11)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA write was requested to the same address simultaneously at both Port A and Port B of the RAM. The contents written to the RAM at address location %h (hex) of Port A and address location %h (hex) of Port B are unknown.", $time/1000.0, addra_int, addrb_int);

            else if (({wea_int, web_int}) == 2'b01)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port A while a write was requested to the same address on Port B. The write will be successful however the read value on Port A is unknown until the next CLKA cycle.", $time/1000.0, addra_int);

            else if (({wea_int, web_int}) == 2'b10)
                $display("Memory Collision Error on RAMB4_S2_S16:%m at simulation time %.3f ns\nA read was performed on address %h (hex) of Port B while a write was requested to the same address on Port A. The write will be successful however the read value on Port B is unknown until the next CLKB cycle.", $time/1000.0, addrb_int);

    end
    endtask

    always @(posedge clka_int) begin
	if ((output_flag || display_flag)) begin
	    addra_reg <= addra_int;
	    ena_reg <= ena_int;
	    rsta_reg <= rsta_int;
	    wea_reg <= wea_int;
	end
    end
    
    always @(posedge clkb_int) begin
	if ((output_flag || display_flag)) begin
	    addrb_reg <= addrb_int;
	    enb_reg <= enb_int;
	    rstb_reg <= rstb_int;
	    web_reg <= web_int;
	end
    end
    
	    
    // Data
    always @(posedge memory_collision) begin
	if ((output_flag || display_flag)) begin
	    for (mi = 0; mi < 16; mi = mi + 2) begin
		if ((mem_addra_int) == (mem_addrb_int + mi)) begin
		    mem[addra_int[10:3]][addra_int[2:0] * 2 +: 2] <= 2'bx;
		end
	    end
	    memory_collision <= 0;
	end
    end

    always @(posedge memory_collision_a_b) begin
	if ((output_flag || display_flag)) begin
	    for (mi = 0; mi < 16; mi = mi + 2) begin
		if ((mem_addra_reg) == (mem_addrb_int + mi)) begin
		    mem[addra_reg[10:3]][addra_reg[2:0] * 2 +: 2] <= 2'bx;
		end
	    end
	    memory_collision_a_b <= 0;
	end
    end
    
    always @(posedge memory_collision_b_a) begin
	if ((output_flag || display_flag)) begin
	    for (mi = 0; mi < 16; mi = mi + 2) begin
		if ((mem_addra_int) == (mem_addrb_reg + mi)) begin
		    mem[addra_int[10:3]][addra_int[2:0] * 2 +: 2] <= 2'bx;
		end
	    end
	    memory_collision_b_a <= 0;
	end
    end

    always @(posedge data_collision[1]) begin
	if (rsta_int == 0 && output_flag) begin
	    for (ai = 0; ai < 16; ai = ai + 2) begin
		if ((mem_addra_int) == (mem_addrb_int + ai)) begin
		    doa_out <= #100 2'bX;
		end
	    end
	end
	data_collision[1] <= 0;
    end

    always @(posedge data_collision[0]) begin
	if (rstb_int == 0 && output_flag) begin
	    for (bi = 0; bi < 16; bi = bi + 2) begin
		if ((mem_addra_int) == (mem_addrb_int + bi)) begin
		    for (bj = 0; bj < 2; bj = bj + 1) begin
			dob_out[bi + bj] <= #100 1'bX;
		    end
		end
	    end
	end
	data_collision[0] <= 0;
    end

    always @(posedge data_collision_a_b[1]) begin
	if (rsta_reg == 0 && output_flag) begin
	    for (ai = 0; ai < 16; ai = ai + 2) begin
		if ((mem_addra_reg) == (mem_addrb_int + ai)) begin
		    doa_out <= #100 2'bX;
		end
	    end
	end
	data_collision_a_b[1] <= 0;
    end

    always @(posedge data_collision_a_b[0]) begin
	if (rstb_int == 0 && output_flag) begin
	    for (bi = 0; bi < 16; bi = bi + 2) begin
		if ((mem_addra_reg) == (mem_addrb_int + bi)) begin
		    for (bj = 0; bj < 2; bj = bj + 1) begin
			dob_out[bi + bj] <= #100 1'bX;
		    end
		end
	    end
	end
	data_collision_a_b[0] <= 0;
    end

    always @(posedge data_collision_b_a[1]) begin
	if (rsta_int == 0 && output_flag) begin
	    for (ai = 0; ai < 16; ai = ai + 2) begin
		if ((mem_addra_int) == (mem_addrb_reg + ai)) begin
		    doa_out <= #100 2'bX;
		end
	    end
	end
	data_collision_b_a[1] <= 0;
    end

    always @(posedge data_collision_b_a[0]) begin
	if (rstb_reg == 0 && output_flag) begin
	    for (bi = 0; bi < 16; bi = bi + 2) begin
		if ((mem_addra_int) == (mem_addrb_reg + bi)) begin
		    for (bj = 0; bj < 2; bj = bj + 1) begin
			dob_out[bi + bj] <= #100 1'bX;
		    end
		end
	    end
	end
	data_collision_b_a[0] <= 0;
    end


    // Port A
    always @(posedge clka_int) begin

	if (ena_int == 1'b1) begin

	    if (rsta_int == 1'b1) begin
		doa_out <= #100 0;
	    end
	    else begin
		if (wea_int == 1'b1)
		    doa_out <= #100 dia_int;
		else
		    doa_out <= #100 mem[addra_int[10:3]][addra_int[2:0] * 2 +: 2];
	    end

	    // memory
	    if (wea_int == 1'b1) begin
		mem[addra_int[10:3]][addra_int[2:0] * 2 +: 2] <= dia_int;
	    end
	    
	end
    end


    // Port B
    always @(posedge clkb_int) begin

	if (enb_int == 1'b1) begin

	    if (rstb_int == 1'b1) begin
		dob_out <= #100 0;
	    end
	    else begin
		if (web_int == 1'b1)
		    dob_out <= #100 dib_int;
		else
		    dob_out <= #100 mem[addrb_int];
	    end

	    // memory
	    if (web_int == 1'b1) begin
		mem[addrb_int] <= dib_int;
	    end

	end
    end


endmodule

`endif
