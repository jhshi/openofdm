// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/OSERDES.v,v 1.11 2008/02/09 00:37:36 fphillip Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Timing Simulation Library Component
//  /   /                  Source Synchronous Output Serializer
// /___/   /\     Filename : OSERDES.v
// \   \  /  \    Timestamp : Thu Mar 11 16:44:07 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/11/05 - Initialized outpus.
//    06/06/07 - Fixed timescale values
//    01/08/08 - CR 458156 -- enabled TRISTATE_WIDTH to be 1 in DDR mode.
// End Revision

`timescale  1 ps / 1 ps

module OSERDES (OQ, SHIFTOUT1, SHIFTOUT2, TQ,
		  CLK, CLKDIV, D1, D2, D3, D4, D5, D6, OCE, REV, SHIFTIN1, SHIFTIN2, SR, T1, T2, T3, T4, TCE);

    parameter DATA_RATE_OQ = "DDR";
    parameter DATA_RATE_TQ = "DDR";
    parameter integer DATA_WIDTH = 4;
    parameter INIT_OQ = 1'b0;
    parameter INIT_TQ = 1'b0;
    parameter SERDES_MODE = "MASTER";
    parameter SRVAL_OQ = 1'b0;
    parameter SRVAL_TQ = 1'b0;
    parameter integer TRISTATE_WIDTH = 4;
    
    output OQ;
    output SHIFTOUT1;
    output SHIFTOUT2;
    output TQ;
    
    input CLK;
    input CLKDIV;
    input D1;
    input D2;
    input D3;
    input D4;
    input D5;
    input D6;
    tri0 GSR = glbl.GSR;
    input OCE;
    input REV;
    input SHIFTIN1;
    input SHIFTIN2;
    input SR;
    input T1;
    input T2;
    input T3;
    input T4;
    input TCE;

    reg c23, c45, c67;
    reg t1r, t2r, t3r, t4r;
    reg io_sdata_edge, io_odata_edge, io_ddr_data;
    reg iot_sdata_edge, iot_odata_edge, iot_ddr_data;
    reg data1, data2, data3, data4, data5, data6;
    reg serdes_mode_int, serdes_int;
    reg data_rate_oq_int, ddr_clk_edge_int;
    reg [1:0] data_rate_tq_int, tristate_width_int;
    reg [1:0] sel;
    reg d1r, d2r, d3r, d4r, d5r, d6r;
    reg q0, q1, q2, q3;
    reg d1rnk2, d2rnk2, d2nrnk2, d3rnk2, d4rnk2, d5rnk2, d6rnk2;
    reg qt1, qt2, qt2n;
    reg load, qhr, qlr, mux;
    reg data1t, data2t;
    reg oq_out = INIT_OQ, tq_out = INIT_TQ;
    reg [3:0] data_width_int;

    wire oqsr, oqrev;
    wire tqsr, tqrev;
    wire c2p, c3;
    wire [2:0] sel1_4;    
    wire [3:0] sel5_6;
    wire [4:0] sel_tri;
    wire [6:0] seltq;
    wire [3:0] seloq;
    
    wire shiftout1_out;
    wire shiftout2_out;

    wire clk_in;
    wire clkdiv_in;
    wire d1_in;
    wire d2_in;
    wire d3_in;
    wire d4_in;
    wire d5_in;
    wire d6_in;
    wire gsr_in;
    wire oce_in;
    wire sr_in;
    wire rev_in;
    wire shiftin1_in;
    wire shiftin2_in;
    wire t1_in;
    wire t2_in;
    wire t3_in;
    wire t4_in;
    wire tce_in;

    buf b_oq (OQ, oq_out);
    buf b_shiftout1 (SHIFTOUT1, shiftout1_out);
    buf b_shiftout2 (SHIFTOUT2, shiftout2_out);
    buf b_tq (TQ, tq_out);
    
    buf b_clk (clk_in, CLK);
    buf b_clkdiv (clkdiv_in, CLKDIV);
    buf b_d1 (d1_in, D1);
    buf b_d2 (d2_in, D2);
    buf b_d3 (d3_in, D3);
    buf b_d4 (d4_in, D4);
    buf b_d5 (d5_in, D5);
    buf b_d6 (d6_in, D6);
    buf b_gsr (gsr_in, GSR);
    buf b_oce (oce_in, OCE);
    buf b_r (sr_in, SR);
    buf b_s (rev_in, REV);
    buf b_shiftin1 (shiftin1_in, SHIFTIN1);
    buf b_shiftin2 (shiftin2_in, SHIFTIN2);
    buf b_t1 (t1_in, T1);
    buf b_t2 (t2_in, T2);
    buf b_t3 (t3_in, T3);
    buf b_t4 (t4_in, T4);
    buf b_tce (tce_in, TCE);

    // workaround for XSIM
    wire rev_in_AND_NOT_sr_in = rev_in & !sr_in;
    wire NOT_rev_in_AND_sr_in = !rev_in & sr_in;
    
/////////////////////////////////////////////////////////
//
//  Delay assignments
//
/////////////////////////////////////////////////////////

// Data output delays

    localparam io_ffd = 1; // clock to out delay for flip flops driven by clk
    localparam io_ffcd = 1; // clock to out delay for flip flops driven by clkdiv
    localparam io_mxd = 1; // 60 ps mux delay
    localparam io_mxr1 = 1; //  mux before 2nd rank of flops

    // Programmable load generator
    localparam ffdcnt = 1;
    localparam mxdcnt = 1;
    localparam ffrst = 145; // clock to out delay for flop in PLSG
    
    // Tristate output delays
    localparam iot_ffd = 1;
    localparam iot_mxd = 1;
/////////////////////////////////////////////////////////////

    
    always @(gsr_in)

	if (gsr_in) begin
	    
	    assign oq_out = INIT_OQ;
	    assign d1rnk2 = INIT_OQ;
	    assign d2rnk2 = INIT_OQ;
	    assign d2nrnk2 = INIT_OQ;
	    assign d6rnk2 = 1'b0;
	    assign d5rnk2 = 1'b0;
	    assign d4rnk2 = 1'b0;
	    assign d3rnk2 = 1'b0;
	    
	    assign d6r = 1'b0;
	    assign d5r = 1'b0;
	    assign d4r = 1'b0;
	    assign d3r = 1'b0;
	    assign d2r = 1'b0;
	    assign d1r = 1'b0;

// PLG
	    assign q3 = 1'b0;
	    assign q2 = 1'b0;
	    assign q1 = 1'b0;
	    assign q0 = 1'b0;

// Tristate output
	    assign tq_out = INIT_TQ;
	    assign qt1 = INIT_TQ;
	    assign qt2 = INIT_TQ;
	    assign qt2n = INIT_TQ;
	    assign t4r = 1'b0;
	    assign t3r = 1'b0;
	    assign t2r = 1'b0;
	    assign t1r = 1'b0;
	    
	end
	else begin

	    deassign oq_out;
	    deassign d1rnk2;
	    deassign d2rnk2;
	    deassign d2nrnk2;
	    deassign d6rnk2;
	    deassign d5rnk2;
	    deassign d4rnk2;
	    deassign d3rnk2;
	    deassign d6r;
	    deassign d5r;
	    deassign d4r;
	    deassign d3r;
	    deassign d2r;
	    deassign d1r;

// PLG
	    deassign q3;
	    deassign q2;
	    deassign q1;
	    deassign q0;

// Tristate output
	    deassign tq_out;
	    deassign qt1;
	    deassign qt2;
	    deassign qt2n;
	    deassign t4r;
	    deassign t3r;
	    deassign t2r;
	    deassign t1r;
	    
	end

    
    initial begin

	case (SERDES_MODE)

	    "MASTER" : serdes_mode_int <= 1'b0;
	    "SLAVE" : serdes_mode_int <= 1'b1;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute SERDES_MODE on OSERDES instance %m is set to %s.  Legal values for this attribute are MASTER or SLAVE", SERDES_MODE);
		          $finish;
                      end

	endcase // case(SERDES_MODE)

	
	serdes_int <= 1'b1; // SERDES = TRUE

	ddr_clk_edge_int <= 1'b1; // DDR_CLK_EDGE = SAME_EDGE

	
	case (DATA_RATE_OQ)

	    "SDR" : data_rate_oq_int <= 1'b1;
	    "DDR" : data_rate_oq_int <= 1'b0;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute DATA_RATE_OQ on OSERDES instance %m is set to %s.  Legal values for this attribute are SDR or DDR", DATA_RATE_OQ);
		          $finish;
                      end

	endcase // case(DATA_RATE_OQ)
	

	case (DATA_WIDTH)

	    2, 3, 4, 5, 6, 7, 8, 10 : data_width_int = DATA_WIDTH[3:0];
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute DATA_WIDTH on OSERDES instance %m is set to %d.  Legal values for this attribute are 2, 3, 4, 5, 6, 7, 8, or 10", DATA_WIDTH);
		          $finish;
                      end

	endcase // case(DATA_WIDTH)

	
	case (DATA_RATE_TQ)

	    "BUF" : data_rate_tq_int <= 2'b00;
	    "SDR" : data_rate_tq_int <= 2'b01;
	    "DDR" : data_rate_tq_int <= 2'b10;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute DATA_RATE_TQ on OSERDES instance %m is set to %s.  Legal values for this attribute are BUF, SDR or DDR", DATA_RATE_TQ);
		          $finish;
                      end

	endcase // case(DATA_RATE_TQ)

	
	case (TRISTATE_WIDTH)

	    1 : tristate_width_int <= 2'b00;
	    2 : tristate_width_int <= 2'b01;
	    4 : tristate_width_int <= 2'b10;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute TRISTATE_WIDTH on OSERDES instance %m is set to %d.  Legal values for this attribute are 1, 2 or 4", TRISTATE_WIDTH);
		          $finish;
                      end

	endcase // case(TRISTATE_WIDTH)
	

    end // initial begin
    

    assign shiftout1_out = d3rnk2 & serdes_mode_int;
    
    assign shiftout2_out = d4rnk2 & serdes_mode_int;

    assign c2p = (clk_in & ddr_clk_edge_int) | (!clk_in & !ddr_clk_edge_int);

    assign c3 = !c2p;

    assign sel1_4 = {serdes_int, load, data_rate_oq_int};
    
    assign sel5_6 = {serdes_int, serdes_mode_int, load, data_rate_oq_int};

// Tristate output
    assign sel_tri = {load, data_rate_tq_int, tristate_width_int};

    assign seloq = {oce_in, data_rate_oq_int, oqsr, oqrev};

    assign seltq = {tce_in, data_rate_tq_int, tristate_width_int, tqsr, tqrev};

    assign oqsr =  (sr_in & !SRVAL_OQ) | (rev_in & SRVAL_OQ);

    assign oqrev = (sr_in & SRVAL_OQ) | (rev_in & !SRVAL_OQ);

    assign tqsr = (sr_in & !SRVAL_TQ) | (rev_in & SRVAL_TQ);
    
    assign tqrev = (sr_in & SRVAL_TQ) | (rev_in & !SRVAL_TQ);
    
// 3 flops to create DDR operations of 4 latches
// asynchronous operation
    always @ (posedge clk_in or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin

	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_OQ == 1'b1))
	    
	    d1rnk2 <= # io_ffd SRVAL_OQ;
	
	else if (rev_in == 1'b1)
	    
	    d1rnk2 <= # io_ffd !SRVAL_OQ;
	
	else if (oce_in == 1'b1)
	    
	    d1rnk2 <= # io_ffd data1;
	
	else if (oce_in == 1'b0)  // to match with HW
	    
	    d1rnk2 <= # io_ffd oq_out;

    end // always @ (posedge clk_in or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
        

// Representation of 2nd latch
// asynchronous operation
    always @ (posedge c2p or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin

	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_OQ == 1'b1))
	    
	    d2rnk2 <= # io_ffd SRVAL_OQ;
	
	else if (rev_in == 1'b1)
	    
	    d2rnk2 <= # io_ffd !SRVAL_OQ;
	
	else if (oce_in == 1'b1)
	    
	    d2rnk2 <= # io_ffd data2;
	
	else if (oce_in == 1'b0)  // to match with HW
	    
	    d2rnk2 <= # io_ffd oq_out;
	
    end // always @ (posedge c2p or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
            

// Representation of 3rd flop ( latch and output latch)
// asynchronous operation
    always @ (posedge c3 or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin

	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_OQ == 1'b1))
	    
	    d2nrnk2 <= # io_ffd SRVAL_OQ;
	
	else if (rev_in == 1'b1)
	    
	    d2nrnk2 <= # io_ffd !SRVAL_OQ;
	
	else if (oce_in == 1'b1)
	    
	    d2nrnk2 <= # io_ffd d2rnk2;
	
	else if (oce_in == 1'b0)  // to match with HW
	    
	    d2nrnk2 <= # io_ffd oq_out;
	
    end // always @ (posedge c3 or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
        

// last 4 flops which only have reset and init
// asynchronous operation
    always @ (posedge clk_in or posedge sr_in) begin

	if (sr_in == 1'b1) begin
	    
	    d3rnk2 <= # io_ffd 1'b0;
	    d4rnk2 <= # io_ffd 1'b0;
	    d5rnk2 <= # io_ffd 1'b0;
	    d6rnk2 <= # io_ffd 1'b0;
	    
	end	  
	else begin
	    
	    d3rnk2 <= # io_ffd data3;
	    d4rnk2 <= # io_ffd data4;
	    d5rnk2 <= # io_ffd data5;
	    d6rnk2 <= # io_ffd data6;
	    
	end

    end // always @ (posedge clk_in or posedge sr_in)
    
    
// First rank of flops for input data
// asynchronous operation
    always @ (posedge clkdiv_in or posedge sr_in) begin

	if (sr_in == 1'b1) begin
	    
	    d1r <= # io_ffcd 1'b0;
	    d2r <= # io_ffcd 1'b0;
	    d3r <= # io_ffcd 1'b0;
	    d4r <= # io_ffcd 1'b0;
	    d5r <= # io_ffcd 1'b0;
	    d6r <= # io_ffcd 1'b0;
	    
	end
	else begin
	    
	    d1r <= # io_ffcd d1_in;
	    d2r <= # io_ffcd d2_in;
	    d3r <= # io_ffcd d3_in;
	    d4r <= # io_ffcd d4_in;
	    d5r <= # io_ffcd d5_in;
	    d6r <= # io_ffcd d6_in;
	    
	end

    end // always @ (posedge clkdiv_in or posedge sr_in)
    
    
// Muxs for 2nd rank of flops
    always @ (sel1_4 or d1r or d2rnk2 or d3rnk2) begin

	casex (sel1_4)
		    
	    3'b100: data1 <= # io_mxr1 d3rnk2;
	    3'b110: data1 <= # io_mxr1 d1r;
	    3'b101: data1 <= # io_mxr1 d2rnk2;
	    3'b111: data1 <= # io_mxr1 d1r;
	    default: data1 <= # io_mxr1 d3rnk2;

	endcase

    end	      
	
	      
    always @ (sel1_4 or d2r or d3rnk2 or d4rnk2) begin	      

	casex (sel1_4)

	    3'b100: data2 <= # io_mxr1 d4rnk2;
	    3'b110: data2 <= # io_mxr1 d2r;
	    3'b101: data2 <= # io_mxr1 d3rnk2;
	    3'b111: data2 <= # io_mxr1 d2r;
	    default:  data2 <= # io_mxr1 d4rnk2;
	
	endcase
	
    end

    
//Note: To stop data rate of 00 from being illegal, register data is fed to mux
    always @ (sel1_4 or d3r or d4rnk2 or d5rnk2) begin

	casex (sel1_4)

	    3'b100: data3 <= # io_mxr1 d5rnk2;
	    3'b110: data3 <= # io_mxr1 d3r;
	    3'b101: data3 <= # io_mxr1 d4rnk2;
	    3'b111: data3 <= # io_mxr1 d3r;
	    default: data3 <= # io_mxr1 d5rnk2;

	endcase

    end

    
    always @ (sel1_4 or d4r or d5rnk2 or d6rnk2) begin

	casex (sel1_4)

	    3'b100: data4 <= # io_mxr1 d6rnk2;
	    3'b110: data4 <= # io_mxr1 d4r;
	    3'b101: data4 <= # io_mxr1 d5rnk2;
	    3'b111: data4 <= # io_mxr1 d4r;
	    default:  data4 <= # io_mxr1 d6rnk2;

	endcase
	
    end

    
    always @ (sel5_6 or d5r or d6rnk2 or shiftin1_in) begin

	casex (sel5_6)

	    4'b1000: data5 <= # io_mxr1 shiftin1_in;
	    4'b1010: data5 <= # io_mxr1 d5r;
	    4'b1001: data5 <= # io_mxr1 d6rnk2;
	    4'b1011: data5 <= # io_mxr1 d5r;
	    4'b1100: data5 <= # io_mxr1 1'b0;
	    4'b1110: data5 <= # io_mxr1 d5r;
	    4'b1101: data5 <= # io_mxr1 d6rnk2;
	    4'b1111: data5 <= # io_mxr1 d5r;
	    default: data5 <= # io_mxr1 shiftin1_in;

	endcase

    end

    
    always @ (sel5_6 or D6 or d6r or shiftin1_in or shiftin2_in) begin

	casex (sel5_6)

	    4'b1000: data6 <= # io_mxr1 shiftin2_in;
	    4'b1010: data6 <= # io_mxr1 d6r;
	    4'b1001: data6 <= # io_mxr1 shiftin1_in;
	    4'b1011: data6 <= # io_mxr1 d6r;
	    4'b1100: data6 <= # io_mxr1 1'b0;
	    4'b1110: data6 <= # io_mxr1 d6r;
	    4'b1101: data6 <= # io_mxr1 1'b0;
	    4'b1111: data6 <= # io_mxr1 d6r;
	    default: data6 <= # io_mxr1 shiftin2_in;

	endcase

    end

    
// Logic to generate same edge data from d1rnk2 and d2nrnk2;
    always @ (clk_in or c3 or d1rnk2 or d2nrnk2) begin

	io_sdata_edge <= # io_mxd (d1rnk2 & clk_in) | (d2nrnk2 & c3);

    end

// Mux to create opposite edge DDR data from d1rnk2 and d2rnk2
    always @(clk_in or d1rnk2 or d2rnk2) begin

	case (clk_in)

	    1'b0: io_odata_edge <= # io_mxd d2rnk2;
	    1'b1: io_odata_edge <= # io_mxd d1rnk2;
	    default: io_odata_edge <= # io_mxd d1rnk2;

	endcase

    end

    
// Logic to same edge and opposite data into just ddr data
    always @(io_sdata_edge or io_odata_edge or ddr_clk_edge_int) begin

	io_ddr_data <= # io_mxd (io_odata_edge & !ddr_clk_edge_int) | (io_sdata_edge & ddr_clk_edge_int);

    end


// Output mux to generate OQ
    always @ (seloq or d1rnk2 or io_ddr_data or oq_out) begin

	casex (seloq)
	    
	    4'bXX01: oq_out <= # io_mxd 1'b1;
	    4'bXX10: oq_out <= # io_mxd 1'b0;
	    4'bXX11: oq_out <= # io_mxd 1'b0;
	    4'b0000: oq_out <= # io_mxd oq_out;
	    4'b0100: oq_out <= # io_mxd oq_out;
	    4'b1000: oq_out <= # io_mxd io_ddr_data;
	    4'b1100: oq_out <= # io_mxd d1rnk2;
	    default: oq_out <= # io_mxd io_ddr_data;

	endcase

    end

    
// Set value of counter in bitslip controller
    always @ (data_rate_oq_int or data_width_int) begin

	casex ({data_rate_oq_int, data_width_int})

	    5'b00100: begin c23 <= 1'b0; c45 <= 1'b0; c67 <= 1'b0; sel <= 2'b00; end
	    5'b00110: begin c23 <= 1'b1; c45 <= 1'b0; c67 <= 1'b0; sel <= 2'b00; end
	    5'b01000: begin c23 <= 1'b0; c45 <= 1'b0; c67 <= 1'b0; sel <= 2'b01; end
	    5'b01010: begin c23 <= 1'b0; c45 <= 1'b1; c67 <= 1'b0; sel <= 2'b01; end
	    5'b10010: begin c23 <= 1'b0; c45 <= 1'b0; c67 <= 1'b0; sel <= 2'b00; end
	    5'b10011: begin c23 <= 1'b1; c45 <= 1'b0; c67 <= 1'b0; sel <= 2'b00; end
	    5'b10100: begin c23 <= 1'b0; c45 <= 1'b0; c67 <= 1'b0; sel <= 2'b01; end
	    5'b10101: begin c23 <= 1'b0; c45 <= 1'b1; c67 <= 1'b0; sel <= 2'b01; end
	    5'b10110: begin c23 <= 1'b0; c45 <= 1'b0; c67 <= 1'b0; sel <= 2'b10; end
	    5'b10111: begin c23 <= 1'b0; c45 <= 1'b0; c67 <= 1'b1; sel <= 2'b10; end
	    5'b11000: begin c23 <= 1'b0; c45 <= 1'b0; c67 <= 1'b0; sel <= 2'b11; end

	    default: begin
		         $display("DATA_WIDTH %d and DATA_RATE_OQ %s at time %t ns are illegal.", DATA_WIDTH, DATA_RATE_OQ, $time/1000.0);
	                 $finish;
	             end
	    
	endcase

    end // always @ (data_rate_oq_int or data_width_int)
    



///////////////////////////////////////////////////////////////
// Programmable Load Generator (PLG)
// 	Divide by 2-8 counter with load enable output
//////////////////////////////////////////////////////////////////
    
// flops for counter
// asynchronous reset
    always @ (posedge qhr or posedge clk_in) begin

	if (qhr) begin
	    
	    q0 <= # ffdcnt 1'b0;
	    q1 <= # ffdcnt 1'b0;
	    q2 <= # ffdcnt 1'b0;
	    q3 <= # ffdcnt 1'b0;
	    
	end
	else begin
	    
	    q3 <= # ffdcnt q2;
	    q2 <= # ffdcnt (!(!q0 & !q2) & q1);
	    q1 <= # ffdcnt q0;
	    q0 <= # ffdcnt mux;
	    
	end
	
    end // always @ (posedge qhr or posedge clk_in)

    
// mux settings for counter
    always @ (sel or c23 or c45 or c67 or q0 or q1 or q2 or q3) begin

	case (sel)

	    2'b00: mux <= # mxdcnt (!q0 & !(c23 & q1));
	    2'b01: mux <= # mxdcnt (!q1 & !(c45 & q2));
	    2'b10: mux <= # mxdcnt (!q2 & !(c67 & q3));
	    2'b11: mux <= # mxdcnt !q3;
	    default: mux <= # mxdcnt 1'b0;

	endcase

    end


// mux decoding for load signal
    always @ (sel or c23 or c45 or c67 or q0 or q1 or q2 or q3) begin

	case (sel)

	    2'b00: load <= # mxdcnt q0;
	    2'b01: load <= # mxdcnt q0 & q1;
	    2'b10: load <= # mxdcnt q0 & q2;
	    2'b11: load <= # mxdcnt q0 & q3;
	    default: load <= # mxdcnt 1'b0;

	endcase

    end


// flops to reset counter
// Low speed flop
// asynchronous reset
    always @ (posedge sr_in or posedge clkdiv_in) begin

	if (sr_in == 1'b1)
	    
	    qlr <= # ffrst 1'b1;
	
	else
	    
	    qlr <= # ffrst 1'b0;
	
    end // always @ (posedge sr_in or posedge clkdiv_in)

	
// High speed flop
// asynchronous reset
    always @ (posedge sr_in or posedge clk_in) begin

	if (sr_in == 1'b1)
	    
	    qhr <= # ffdcnt 1'b1;
	
	else
	    
	    qhr <= # ffdcnt qlr;
	
    end // always @ (posedge sr_in or posedge clk_in)

    
    
///////////////////////////////////////////////////////
//
// Tristate Output cell
//
////////////////////////////////////////////////////////
    
// 3 flops to create DDR operations of 4 latches
// Representation of top latch
// asynchronous operation
    always @ (posedge clk_in or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin

	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_TQ == 1'b1))
	    
	    qt1 <= # iot_ffd SRVAL_TQ;
	
	else if (rev_in == 1'b1)
	    
	    qt1 <= # iot_ffd !SRVAL_TQ;
	
	else if (tce_in == 1'b1)
	    
	    qt1 <= # iot_ffd data1t;
	
	else if (tce_in == 1'b0)
	    
	    qt1 <= # iot_ffd tq_out;
	
    end // always @ (posedge clk_in or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
        
    
// Representation of 2nd latch
// asynchronous operation
    always @ (posedge c2p or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin

	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_TQ == 1'b1))
	    
	    qt2 <= # iot_ffd SRVAL_TQ;
	
	else if (rev_in == 1'b1)
	    
	    qt2 <= # iot_ffd !SRVAL_TQ;
	
	else if (tce_in == 1'b1)
	    
	    qt2 <= # iot_ffd data2t;
	
	else if (tce_in == 1'b0)
	    
	    qt2 <= # iot_ffd tq_out;
	
    end // always @ (posedge c2p or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
        

// Representation of 3rd flop ( latch and output latch)
// asynchronous operation
    always @ (posedge c3 or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin

	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_TQ == 1'b1))
	    
	    qt2n <= # iot_ffd SRVAL_TQ;
	
	else if (rev_in == 1'b1)
	    
	    qt2n <= # iot_ffd !SRVAL_TQ;
	
	else if (tce_in == 1'b1)
		
	    qt2n <= # iot_ffd qt2;
	
	else if (tce_in == 1'b0)
	    
	    qt2n <= # iot_ffd tq_out;
	
    end // always @ (posedge c3 or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
    
    
// First rank of flops
// asynchronous reset operation
    always @ (posedge clkdiv_in or posedge sr_in) begin

	if (sr_in == 1'b1) begin
	    
	    t1r <= # iot_ffd 1'b0;
	    t2r <= # iot_ffd 1'b0;
	    t3r <= # iot_ffd 1'b0;
	    t4r <= # iot_ffd 1'b0;
	    
	end  
	else begin
	    
	    t1r <= # iot_ffd t1_in;
	    t2r <= # iot_ffd t2_in;
	    t3r <= # iot_ffd t3_in;
	    t4r <= # iot_ffd t4_in;
		
	end
	
    end // always @ (posedge clkdiv_in or posedge sr_in)
    	
    
// Data Muxs for tristate otuput signals
    always @ (sel_tri or t1_in or t1r or t3r) begin

	casex (sel_tri)

	    5'b00000: data1t <= # iot_mxd t1_in;
	    5'b10000: data1t <= # iot_mxd t1_in;
	    5'bX0000: data1t <= # iot_mxd t1_in;
	    5'b00100: data1t <= # iot_mxd t1_in;
	    5'b10100: data1t <= # iot_mxd t1_in;
	    5'bX0100: data1t <= # iot_mxd t1_in;
	    5'b01001: data1t <= # iot_mxd t1_in;
	    5'b11001: data1t <= # iot_mxd t1_in;
	    5'b01010: data1t <= # iot_mxd t3r;
	    5'b11010: data1t <= # iot_mxd t1r;
// CR 458156 -- allow/enabled TRISTATE_WIDTH to be 1 in DDR mode. No func change, but removed warnings
            5'b01000: ;
            5'b11000: ;
            5'bX1000: ;
	    default: begin
		         $display("DATA_RATE_TQ %s and/or TRISTATE_WIDTH %d at time %t ns are not supported by OSERDES", DATA_RATE_TQ, TRISTATE_WIDTH, $time/1000.0);
	                 $finish;
	             end
	    
	endcase

    end

// For data 2, width of 1 is inserted as acceptable for buf and sdr
//  The capability exists in the device if the feature is added
    always @ (sel_tri or t2_in or t2r or t4r) begin

	casex (sel_tri)

	    5'b00000: data2t <= # iot_mxd t2_in;
	    5'b00100: data2t <= # iot_mxd t2_in;
	    5'b10000: data2t <= # iot_mxd t2_in;
	    5'b10100: data2t <= # iot_mxd t2_in;
	    5'bX0000: data2t <= # iot_mxd t2_in;
	    5'bX0100: data2t <= # iot_mxd t2_in;
	    5'b00X00: data2t <= # iot_mxd t2_in;
	    5'b10X00: data2t <= # iot_mxd t2_in;
	    5'bX0X00: data2t <= # iot_mxd t2_in;
	    5'b01001: data2t <= # iot_mxd t2_in;
	    5'b11001: data2t <= # iot_mxd t2_in;
	    5'bX1001: data2t <= # iot_mxd t2_in;
	    5'b01010: data2t <= # iot_mxd t4r;
	    5'b11010: data2t <= # iot_mxd t2r;
// CR 458156 -- allow/enabled TRISTATE_WIDTH to be 1 in DDR mode. No func change, but removed warnings
            5'b01000: ;
            5'b11000: ;
            5'bX1000: ;
	    default: begin
		         $display("DATA_RATE_TQ %s and/or TRISTATE_WIDTH %d at time %t ns are not supported by OSERDES", DATA_RATE_TQ, TRISTATE_WIDTH, $time/1000.0);
	                 $finish;
	             end
	    
	endcase
	
    end


// Logic to generate same edge data from qt1, qt3;
    always @ (clk_in or c3 or qt1 or qt2n) begin

	iot_sdata_edge <= # iot_mxd (qt1 & clk_in) | (qt2n & c3);

    end

    
// Mux to create opposite edge DDR function
    always @ (clk_in or qt1 or qt2) begin

	case (clk_in)

	    1'b0: iot_odata_edge <= # iot_mxd qt2;
	    1'b1: iot_odata_edge <= # iot_mxd qt1;
	    default: iot_odata_edge <= 1'b0;

	endcase
    
    end

    
// Logic to same edge and opposite data into just ddr data
    always @ (iot_sdata_edge or iot_odata_edge or ddr_clk_edge_int) begin

	iot_ddr_data <= # iot_mxd (iot_odata_edge & !ddr_clk_edge_int) | (iot_sdata_edge & ddr_clk_edge_int);

    end

// Output mux to generate TQ
// Note that the TQ mux can also support T2 combinatorial or
//  registered outputs.  Those modes are not support in this model.
    always @ (seltq or data1t or iot_ddr_data or qt1 or tq_out) begin

	casex (seltq)

	    7'bX01XX01: tq_out <= # iot_mxd 1'b1;
	    7'bX10XX01: tq_out <= # iot_mxd 1'b1;
	    7'bX01XX10: tq_out <= # iot_mxd 1'b0;
	    7'bX10XX10: tq_out <= # iot_mxd 1'b0;
	    7'bX01XX11: tq_out <= # iot_mxd 1'b0;
	    7'bX10XX11: tq_out <= # iot_mxd 1'b0;
	    7'bX0000XX: tq_out <= # iot_mxd data1t;
	    7'b0010000: tq_out <= # iot_mxd tq_out;
	    7'b0100100: tq_out <= # iot_mxd tq_out;
	    7'b0101000: tq_out <= # iot_mxd tq_out;
	    7'b1010000: tq_out <= # iot_mxd qt1;
	    7'b1100100: tq_out <= # iot_mxd iot_ddr_data;
	    7'b1101000: tq_out <= # iot_mxd iot_ddr_data;
	    default: tq_out <= # iot_mxd iot_ddr_data;

	endcase

    end

    specify

	(CLK => OQ) = (100, 100);
	(CLK => TQ) = (100, 100);
	specparam PATHPULSE$ = 0;
    
    endspecify

endmodule // OSERDES
