///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Source Synchronous Input Deserializer
// /___/   /\     Filename : ISERDES.v
// \   \  /  \    Timestamp : Thu Mar 11 16:43:51 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/11/05 - Initialized outpus.
//    03/18/05 - Changed SIM_TAPDELAY_VALUE to 75 from 78.
//    10/13/06 - Fixed CR 426606
//    06/06/07 - Added wire declaration for internal signals
//    09/10/07 - CR 447760 Added Strict DRC for BITSLIP and INTERFACE_TYPE combinations
//    01/27/09 - CR 504307 removed glitches from the tap  
// End Revision

`timescale  1 ps / 1 ps

module ISERDES (O, Q1, Q2, Q3, Q4, Q5, Q6, SHIFTOUT1, SHIFTOUT2,
		  BITSLIP, CE1, CE2, CLK, CLKDIV, D, DLYCE, DLYINC, DLYRST, OCLK, REV, SHIFTIN1, SHIFTIN2, SR);
    output O;
    output Q1;
    output Q2;
    output Q3;
    output Q4;
    output Q5;
    output Q6;
    output SHIFTOUT1;
    output SHIFTOUT2;

    input BITSLIP;
    input CE1;
    input CE2;
    input CLK;
    input CLKDIV;
    input D;
    input DLYCE;
    input DLYINC;
    input DLYRST;
    tri0 GSR = glbl.GSR;
    input OCLK;
    input REV;
    input SHIFTIN1;
    input SHIFTIN2;
    input SR;
    
    parameter BITSLIP_ENABLE = "FALSE";
    parameter DATA_RATE = "DDR";
    parameter integer DATA_WIDTH = 4;
    parameter INIT_Q1 = 1'b0;
    parameter INIT_Q2 = 1'b0;
    parameter INIT_Q3 = 1'b0;
    parameter INIT_Q4 = 1'b0;
    parameter INTERFACE_TYPE = "MEMORY";
    parameter IOBDELAY = "NONE";
    parameter IOBDELAY_TYPE = "DEFAULT";
    parameter integer IOBDELAY_VALUE = 0;
    parameter integer NUM_CE = 2;
    parameter SERDES_MODE = "MASTER";
    parameter SRVAL_Q1 = 1'b0;
    parameter SRVAL_Q2 = 1'b0;
    parameter SRVAL_Q3 = 1'b0;
    parameter SRVAL_Q4 = 1'b0;    

    integer   delay_count, delay_count_int;

    reg [1:0] sel;
    reg [3:0] data_width_int;
    reg bts_q1, bts_q2, bts_q3;
    reg c23, c45, c67;
    reg ce1r, ce2r;
    reg dataq1rnk2, dataq2rnk2, dataq3rnk2;
    reg dataq3rnk1, dataq4rnk1, dataq5rnk1, dataq6rnk1;
    reg dataq4rnk2, dataq5rnk2, dataq6rnk2;
    reg ice, memmux, q2pmux;    
    reg mux, mux1, muxc;
    reg clkdiv_int, clkdivmux;
    reg o_out = 0, q1_out = 0, q2_out = 0, q3_out = 0, q4_out = 0, q5_out = 0, q6_out = 0;
    reg q1rnk2, q2rnk2, q3rnk2, q4rnk2, q5rnk2, q6rnk2;
    reg q1rnk3, q2rnk3, q3rnk3, q4rnk3, q5rnk3, q6rnk3;
    reg q4rnk1, q5rnk1, q6rnk1, q6prnk1;
    reg num_ce_int;
    reg qr1, qr2, qhc1, qhc2, qlc1, qlc2;
    reg shiftn2_in, shiftn1_in;
    reg	q1rnk1, q2nrnk1, q1prnk1, q2prnk1, q3rnk1;
    reg serdes_mode_int, data_rate_int, bitslip_enable_int;
    reg d_delay, o_delay;

    wire shiftout1_out, shiftout2_out;
    wire [1:0] sel1;
    wire [2:0] bsmux;
    wire [3:0] selrnk3;
    wire delay_chain_0,  delay_chain_1,  delay_chain_2,  delay_chain_3,
         delay_chain_4,  delay_chain_5,  delay_chain_6,  delay_chain_7,
         delay_chain_8,  delay_chain_9,  delay_chain_10, delay_chain_11,
         delay_chain_12, delay_chain_13, delay_chain_14, delay_chain_15,
         delay_chain_16, delay_chain_17, delay_chain_18, delay_chain_19,
         delay_chain_20, delay_chain_21, delay_chain_22, delay_chain_23,
         delay_chain_24, delay_chain_25, delay_chain_26, delay_chain_27,
         delay_chain_28, delay_chain_29, delay_chain_30, delay_chain_31,
         delay_chain_32, delay_chain_33, delay_chain_34, delay_chain_35,
         delay_chain_36, delay_chain_37, delay_chain_38, delay_chain_39,
         delay_chain_40, delay_chain_41, delay_chain_42, delay_chain_43,
         delay_chain_44, delay_chain_45, delay_chain_46, delay_chain_47,
         delay_chain_48, delay_chain_49, delay_chain_50, delay_chain_51,
         delay_chain_52, delay_chain_53, delay_chain_54, delay_chain_55,
         delay_chain_56, delay_chain_57, delay_chain_58, delay_chain_59,
         delay_chain_60, delay_chain_61, delay_chain_62, delay_chain_63;
    
    wire bitslip_in;
    wire ce1_in;
    wire ce2_in;
    wire clk_in;
    wire clkdiv_in;
    wire d_in;
    wire dlyce_in;
    wire dlyinc_in;
    wire dlyrst_in;
    wire gsr_in;
    wire oclk_in;
    wire rev_in;
    wire sr_in;
    wire shiftin1_in;
    wire shiftin2_in;

    buf b_o (O, o_out);
    buf b_q1 (Q1, q1_out);
    buf b_q2 (Q2, q2_out);
    buf b_q3 (Q3, q3_out);
    buf b_q4 (Q4, q4_out);
    buf b_q5 (Q5, q5_out);
    buf b_q6 (Q6, q6_out);
    buf b_shiftout1 (SHIFTOUT1, shiftout1_out);
    buf b_shiftout2 (SHIFTOUT2, shiftout2_out);    

    buf b_bitslip (bitslip_in, BITSLIP);
    buf b_ce1 (ce1_in, CE1);
    buf b_ce2 (ce2_in, CE2);
    buf b_clk (clk_in, CLK);
    buf b_clkdiv (clkdiv_in, CLKDIV);
    buf b_d (d_in, D);
    buf b_dlyce (dlyce_in, DLYCE);
    buf b_dlyinc (dlyinc_in, DLYINC);
    buf b_dlyrst (dlyrst_in, DLYRST);
    buf b_gsr (gsr_in, GSR);
    buf b_oclk (oclk_in, OCLK);
    buf b_rev (rev_in, REV);
    buf b_sr (sr_in, SR);
    buf b_shiftin1 (shiftin1_in, SHIFTIN1);
    buf b_shiftin2 (shiftin2_in, SHIFTIN2);

    // workaround for XSIM
    wire rev_in_AND_NOT_sr_in = rev_in & !sr_in;
    wire NOT_rev_in_AND_sr_in = !rev_in & sr_in;

    localparam SIM_TAPDELAY_VALUE = 75;

// Parameter declarations for delays
    localparam ffinp = 300;
    localparam mxinp1 = 60;
    localparam mxinp2 = 120;

// Delay parameters

    localparam ffice = 300;
    localparam mxice = 60;
    
//  Delay parameter assignment

    localparam ffbsc = 300;
    localparam mxbsc = 60;
    
    localparam mxinp1_my = 0;

    
    initial begin

// --------CR 447760  DRC -- BITSLIP - INTERFACE_TYPE combination  ------------------

      if((INTERFACE_TYPE == "MEMORY") && (BITSLIP_ENABLE == "TRUE")) begin
          $display("Attribute Syntax Error: BITSLIP_ENABLE is currently set to TRUE when INTERFACE_TYPE is set to MEMORY. This is an invalid configuration.");
          $finish;
          end
     else if((INTERFACE_TYPE == "NETWORKING") && (BITSLIP_ENABLE == "FALSE")) begin
        $display ("Attribute Syntax Error: BITSLIP_ENABLE is currently set to FALSE when INTERFACE_TYPE is set to NETWORKING. If BITSLIP is not intended to be used, please set BITSLIP_ENABLE to TRUE and tie the BITSLIP port to ground.");
          $finish;
          end

// ---------------------------------------------------------------------------------

	if (IOBDELAY_VALUE < 0 || IOBDELAY_VALUE > 63) begin

	    $display("Attribute Syntax Error : The attribute IOBDELAY_VALUE on ISERDES instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 3, .... or 63", IOBDELAY_VALUE);
	    $finish;

        end
	
	
	if (IOBDELAY_TYPE != "DEFAULT" && IOBDELAY_TYPE != "FIXED" && IOBDELAY_TYPE != "VARIABLE") begin

	    $display("Attribute Syntax Error : The attribute IOBDELAY_TYPE on ISERDES instance %m is set to %s.  Legal values for this attribute are DEFAULT, FIXED or VARIABLE", IOBDELAY_TYPE);
	    $finish;

        end

	case (SERDES_MODE)
	    "MASTER" : serdes_mode_int <= 1'b0;
	    "SLAVE" : serdes_mode_int <= 1'b1;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute SERDES_MODE on ISERDES instance %m is set to %s.  Legal values for this attribute are MASTER or SLAVE", SERDES_MODE);
		          $finish;
                      end
	endcase // case(SERDES_MODE)
	
	
	case (DATA_RATE)
	    "SDR" : data_rate_int <= 1'b1;
	    "DDR" : data_rate_int <= 1'b0;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute DATA_RATE on ISERDES instance %m is set to %s.  Legal values for this attribute are SDR or DDR", DATA_RATE);
		          $finish;
                      end
	endcase // case(DATA_RATE)	


	case (BITSLIP_ENABLE)

	    "FALSE" : bitslip_enable_int <= 1'b0;
	    "TRUE" : bitslip_enable_int <= 1'b1;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute BITSLIP_ENABLE on ISERDES instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE", BITSLIP_ENABLE);
		          $finish;
                      end

	endcase // case(BITSLIP_ENABLE)


	case (DATA_WIDTH)

	    2, 3, 4, 5, 6, 7, 8, 10 : data_width_int = DATA_WIDTH[3:0];
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute DATA_WIDTH on ISERDES instance %m is set to %d.  Legal values for this attribute are 2, 3, 4, 5, 6, 7, 8, or 10", DATA_WIDTH);
		          $finish;
                      end
	endcase // case(DATA_WIDTH)

	
	case (NUM_CE)

	    1 : num_ce_int <= 1'b0;
	    2 : num_ce_int <= 1'b1;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute NUM_CE on ISERDES instance %m is set to %d.  Legal values for this attribute are 1 or 2", NUM_CE);
		          $finish;
                      end

	endcase // case(NUM_CE)	
	
    end // initial begin

    
    assign sel1 = {serdes_mode_int, data_rate_int};

    assign selrnk3 = {1'b1, bitslip_enable_int, 2'b00};
    
    assign bsmux = {bitslip_enable_int, data_rate_int, muxc};


    
// GSR
    always @(gsr_in) begin
	
	if (gsr_in == 1'b1) begin
	
	    if (IOBDELAY_TYPE == "DEFAULT")

		assign delay_count = 0;

	    else

		assign delay_count = IOBDELAY_VALUE;
	    
	    assign bts_q3 = 1'b0;
	    assign bts_q2 = 1'b0;
	    assign bts_q1 = 1'b0;
	    assign clkdiv_int = 1'b0;

	    assign ce1r = 1'b0;
	    assign ce2r = 1'b0;

	    assign q1rnk1 = INIT_Q1;
	    assign q2nrnk1 = INIT_Q2;
	    assign q1prnk1 = INIT_Q3;
	    assign q2prnk1 = INIT_Q4;
	    
	    assign q3rnk1 = 1'b0;
	    assign q4rnk1 = 1'b0;
	    assign q5rnk1 = 1'b0;
	    assign q6rnk1 = 1'b0;
	    assign q6prnk1 = 1'b0;
	    
	    assign q6rnk2 = 1'b0;
	    assign q5rnk2 = 1'b0;
	    assign q4rnk2 = 1'b0;
	    assign q3rnk2 = 1'b0;
	    assign q2rnk2 = 1'b0;
	    assign q1rnk2 = 1'b0;
	    
	    assign q6rnk3 = 1'b0;
	    assign q5rnk3 = 1'b0;
	    assign q4rnk3 = 1'b0;
	    assign q3rnk3 = 1'b0;
	    assign q2rnk3 = 1'b0;
	    assign q1rnk3 = 1'b0;
	    
	end    
	else if (gsr_in == 1'b0) begin

	    deassign delay_count;

	    deassign bts_q3;
	    deassign bts_q2;
	    deassign bts_q1;
	    deassign clkdiv_int;

	    deassign ce1r;
	    deassign ce2r;

	    deassign q1rnk1;
	    deassign q2nrnk1;
	    deassign q1prnk1;
	    deassign q2prnk1;
	    
	    deassign q3rnk1;
	    deassign q4rnk1;
	    deassign q5rnk1;
	    deassign q6rnk1;
	    deassign q6prnk1;
	    
	    deassign q6rnk2;
	    deassign q5rnk2;
	    deassign q4rnk2;
	    deassign q3rnk2;
	    deassign q2rnk2;
	    deassign q1rnk2;

	    deassign q6rnk3;
	    deassign q5rnk3;
	    deassign q4rnk3;
	    deassign q3rnk3;
	    deassign q2rnk3;
	    deassign q1rnk3;

	end // if (gsr_in == 1'b0)
    end // always @ (gsr_in)
    

    
// IDELAY    
    always @(posedge clkdiv_in) begin

	if (IOBDELAY_TYPE == "VARIABLE") begin
    
	    if (dlyrst_in == 1'b1) begin

		delay_count = IOBDELAY_VALUE;

	    end
    	    else if (dlyrst_in == 1'b0 && dlyce_in == 1'b1) begin

		if (dlyinc_in == 1'b1) begin
    
		    if (delay_count < 63)

			delay_count = delay_count + 1;

		    else if (delay_count == 63)

			delay_count = 0;
		    
		end	
		else if (dlyinc_in == 1'b0) begin
		    
		    if (delay_count > 0)
		    
			delay_count = delay_count - 1;

		    else if (delay_count == 0)

			delay_count = 63;
		end
		
	    end

	end // if (IOBDELAY_TYPE == "VARIABLE")

    end // always @ (posedge clkdiv_in)


// delay chain
    assign                     delay_chain_0  = d_in;
    assign #SIM_TAPDELAY_VALUE delay_chain_1  = delay_chain_0;
    assign #SIM_TAPDELAY_VALUE delay_chain_2  = delay_chain_1;
    assign #SIM_TAPDELAY_VALUE delay_chain_3  = delay_chain_2;
    assign #SIM_TAPDELAY_VALUE delay_chain_4  = delay_chain_3;
    assign #SIM_TAPDELAY_VALUE delay_chain_5  = delay_chain_4;
    assign #SIM_TAPDELAY_VALUE delay_chain_6  = delay_chain_5;
    assign #SIM_TAPDELAY_VALUE delay_chain_7  = delay_chain_6;
    assign #SIM_TAPDELAY_VALUE delay_chain_8  = delay_chain_7;
    assign #SIM_TAPDELAY_VALUE delay_chain_9  = delay_chain_8;
    assign #SIM_TAPDELAY_VALUE delay_chain_10 = delay_chain_9;
    assign #SIM_TAPDELAY_VALUE delay_chain_11 = delay_chain_10;
    assign #SIM_TAPDELAY_VALUE delay_chain_12 = delay_chain_11;
    assign #SIM_TAPDELAY_VALUE delay_chain_13 = delay_chain_12;
    assign #SIM_TAPDELAY_VALUE delay_chain_14 = delay_chain_13;
    assign #SIM_TAPDELAY_VALUE delay_chain_15 = delay_chain_14;
    assign #SIM_TAPDELAY_VALUE delay_chain_16 = delay_chain_15;
    assign #SIM_TAPDELAY_VALUE delay_chain_17 = delay_chain_16;
    assign #SIM_TAPDELAY_VALUE delay_chain_18 = delay_chain_17;
    assign #SIM_TAPDELAY_VALUE delay_chain_19 = delay_chain_18;
    assign #SIM_TAPDELAY_VALUE delay_chain_20 = delay_chain_19;
    assign #SIM_TAPDELAY_VALUE delay_chain_21 = delay_chain_20;
    assign #SIM_TAPDELAY_VALUE delay_chain_22 = delay_chain_21;
    assign #SIM_TAPDELAY_VALUE delay_chain_23 = delay_chain_22;
    assign #SIM_TAPDELAY_VALUE delay_chain_24 = delay_chain_23;
    assign #SIM_TAPDELAY_VALUE delay_chain_25 = delay_chain_24;
    assign #SIM_TAPDELAY_VALUE delay_chain_26 = delay_chain_25;
    assign #SIM_TAPDELAY_VALUE delay_chain_27 = delay_chain_26;
    assign #SIM_TAPDELAY_VALUE delay_chain_28 = delay_chain_27;
    assign #SIM_TAPDELAY_VALUE delay_chain_29 = delay_chain_28;
    assign #SIM_TAPDELAY_VALUE delay_chain_30 = delay_chain_29;
    assign #SIM_TAPDELAY_VALUE delay_chain_31 = delay_chain_30;
    assign #SIM_TAPDELAY_VALUE delay_chain_32 = delay_chain_31;
    assign #SIM_TAPDELAY_VALUE delay_chain_33 = delay_chain_32;
    assign #SIM_TAPDELAY_VALUE delay_chain_34 = delay_chain_33;
    assign #SIM_TAPDELAY_VALUE delay_chain_35 = delay_chain_34;
    assign #SIM_TAPDELAY_VALUE delay_chain_36 = delay_chain_35;
    assign #SIM_TAPDELAY_VALUE delay_chain_37 = delay_chain_36;
    assign #SIM_TAPDELAY_VALUE delay_chain_38 = delay_chain_37;
    assign #SIM_TAPDELAY_VALUE delay_chain_39 = delay_chain_38;
    assign #SIM_TAPDELAY_VALUE delay_chain_40 = delay_chain_39;
    assign #SIM_TAPDELAY_VALUE delay_chain_41 = delay_chain_40;
    assign #SIM_TAPDELAY_VALUE delay_chain_42 = delay_chain_41;
    assign #SIM_TAPDELAY_VALUE delay_chain_43 = delay_chain_42;
    assign #SIM_TAPDELAY_VALUE delay_chain_44 = delay_chain_43;
    assign #SIM_TAPDELAY_VALUE delay_chain_45 = delay_chain_44;
    assign #SIM_TAPDELAY_VALUE delay_chain_46 = delay_chain_45;
    assign #SIM_TAPDELAY_VALUE delay_chain_47 = delay_chain_46;
    assign #SIM_TAPDELAY_VALUE delay_chain_48 = delay_chain_47;
    assign #SIM_TAPDELAY_VALUE delay_chain_49 = delay_chain_48;
    assign #SIM_TAPDELAY_VALUE delay_chain_50 = delay_chain_49;
    assign #SIM_TAPDELAY_VALUE delay_chain_51 = delay_chain_50;
    assign #SIM_TAPDELAY_VALUE delay_chain_52 = delay_chain_51;
    assign #SIM_TAPDELAY_VALUE delay_chain_53 = delay_chain_52;
    assign #SIM_TAPDELAY_VALUE delay_chain_54 = delay_chain_53;
    assign #SIM_TAPDELAY_VALUE delay_chain_55 = delay_chain_54;
    assign #SIM_TAPDELAY_VALUE delay_chain_56 = delay_chain_55;
    assign #SIM_TAPDELAY_VALUE delay_chain_57 = delay_chain_56;
    assign #SIM_TAPDELAY_VALUE delay_chain_58 = delay_chain_57;
    assign #SIM_TAPDELAY_VALUE delay_chain_59 = delay_chain_58;
    assign #SIM_TAPDELAY_VALUE delay_chain_60 = delay_chain_59;
    assign #SIM_TAPDELAY_VALUE delay_chain_61 = delay_chain_60;
    assign #SIM_TAPDELAY_VALUE delay_chain_62 = delay_chain_61;
    assign #SIM_TAPDELAY_VALUE delay_chain_63 = delay_chain_62;

    
// assign delay    
    always @(delay_count_int) begin

	case (delay_count_int)
            0:  assign d_delay = delay_chain_0;
            1:  assign d_delay = delay_chain_1;
            2:  assign d_delay = delay_chain_2;
            3:  assign d_delay = delay_chain_3;
            4:  assign d_delay = delay_chain_4;
            5:  assign d_delay = delay_chain_5;
            6:  assign d_delay = delay_chain_6;
            7:  assign d_delay = delay_chain_7;
            8:  assign d_delay = delay_chain_8;
            9:  assign d_delay = delay_chain_9;
            10: assign d_delay = delay_chain_10;
            11: assign d_delay = delay_chain_11;
            12: assign d_delay = delay_chain_12;
            13: assign d_delay = delay_chain_13;
            14: assign d_delay = delay_chain_14;
            15: assign d_delay = delay_chain_15;
            16: assign d_delay = delay_chain_16;
            17: assign d_delay = delay_chain_17;
            18: assign d_delay = delay_chain_18;
            19: assign d_delay = delay_chain_19;
            20: assign d_delay = delay_chain_20;
            21: assign d_delay = delay_chain_21;
            22: assign d_delay = delay_chain_22;
            23: assign d_delay = delay_chain_23;
            24: assign d_delay = delay_chain_24;
            25: assign d_delay = delay_chain_25;
            26: assign d_delay = delay_chain_26;
            27: assign d_delay = delay_chain_27;
            28: assign d_delay = delay_chain_28;
            29: assign d_delay = delay_chain_29;
            30: assign d_delay = delay_chain_30;
            31: assign d_delay = delay_chain_31;
            32: assign d_delay = delay_chain_32;
            33: assign d_delay = delay_chain_33;
            34: assign d_delay = delay_chain_34;
            35: assign d_delay = delay_chain_35;
            36: assign d_delay = delay_chain_36;
            37: assign d_delay = delay_chain_37;
            38: assign d_delay = delay_chain_38;
            39: assign d_delay = delay_chain_39;
            40: assign d_delay = delay_chain_40;
            41: assign d_delay = delay_chain_41;
            42: assign d_delay = delay_chain_42;
            43: assign d_delay = delay_chain_43;
            44: assign d_delay = delay_chain_44;
            45: assign d_delay = delay_chain_45;
            46: assign d_delay = delay_chain_46;
            47: assign d_delay = delay_chain_47;
            48: assign d_delay = delay_chain_48;
            49: assign d_delay = delay_chain_49;
            50: assign d_delay = delay_chain_50;
            51: assign d_delay = delay_chain_51;
            52: assign d_delay = delay_chain_52;
            53: assign d_delay = delay_chain_53;
            54: assign d_delay = delay_chain_54;
            55: assign d_delay = delay_chain_55;
            56: assign d_delay = delay_chain_56;
            57: assign d_delay = delay_chain_57;
            58: assign d_delay = delay_chain_58;
            59: assign d_delay = delay_chain_59;
            60: assign d_delay = delay_chain_60;
            61: assign d_delay = delay_chain_61;
            62: assign d_delay = delay_chain_62;
            63: assign d_delay = delay_chain_63;
            default:
		assign d_delay = delay_chain_0;

	endcase
    end // always @ (delay_count_int)

    
// to workaround the glitches generated by mux of assign delay above
    always @(delay_count)
// CR 504307	delay_count_int <= #0 delay_count;
	delay_count_int <= #SIM_TAPDELAY_VALUE delay_count;

    
// Mux to O and o_delay
    always @(d_in or d_delay) begin

	case (IOBDELAY)

	    "NONE" : begin 
		         o_delay <= d_in; 
		         o_out <= d_in; 
	             end
	    "IBUF" : begin 
		         o_delay <= d_in; 
		         o_out <= d_delay; 
	             end		
	    "IFD"  : begin 
		         o_delay <= d_delay; 
		         o_out <= d_in; 
	             end
	    "BOTH" : begin 
		         o_delay <= d_delay; 
		         o_out <= d_delay; 
	             end
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute IOBDELAY on ISERDES instance %m is set to %s.  Legal values for this attribute are NONE, IBUF, IFD or BOTH", IOBDELAY);
		          $finish;
                      end

	endcase // case(IOBDELAY)

    end // always @ (d_in or d_delay)

    
// 1st rank of registers

// Asynchronous Operation
    always @(posedge clk_in or posedge rev_in or posedge sr_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin
// 1st flop in rank 1 that is full featured

	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_Q1 == 1'b1))
	    
	    q1rnk1 <= # ffinp SRVAL_Q1;
	
	else if (rev_in == 1'b1)
	    
	    q1rnk1 <= # ffinp !SRVAL_Q1;
	
	else if (ice == 1'b1)
	    
	    q1rnk1 <= # ffinp o_delay;

    end // always @ (posedge clk_in or posedge rev_in or posedge sr_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
        
    
    always @(posedge clk_in or posedge sr_in) begin
// rest of flops which are not full featured and don't have clock options

	if (sr_in == 1'b1) begin
	    
	    q5rnk1 <= # ffinp 1'b0;
	    q6rnk1 <= # ffinp 1'b0;
	    q6prnk1 <= # ffinp 1'b0;
	    
	end
	else begin
	    
	    q5rnk1 <= # ffinp dataq5rnk1;
	    q6rnk1 <= # ffinp dataq6rnk1;
	    q6prnk1 <= # ffinp q6rnk1;
	    
	end
    
    end // always @ (posedge clk_in or sr_in)
    
    
// 2nd flop in rank 1

// Asynchronous Operation
    always @(negedge clk_in or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin

	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_Q2 == 1'b1))
	    
	    q2nrnk1 <= # ffinp SRVAL_Q2;
	
	else if (rev_in == 1'b1)
	    
	    q2nrnk1 <= # ffinp !SRVAL_Q2;
	
	else if (ice == 1'b1)
	    
	    q2nrnk1 <= # ffinp o_delay;
	
    end // always @ (negedge clk_in or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
            
    
// 4th flop in rank 1 operating on the posedge for networking
// Asynchronous Operation
    always @(posedge q2pmux or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin
	
	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_Q4 == 1'b1))
	    
	    q2prnk1 <= # ffinp SRVAL_Q4;
	
	else if (rev_in == 1'b1)
	    
	    q2prnk1 <= # ffinp !SRVAL_Q4;
	
	else if (ice == 1'b1)
	    
	    q2prnk1 <= # ffinp q2nrnk1;
	
    end // always @ (posedge q2pmux or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
        
    
// 3rd flop in 2nd rank which is full featured and has 
//   a choice of being clocked by oclk or clk

// Asynchronous Operation
    always @(posedge memmux or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in) begin

	if (sr_in == 1'b1 & !(rev_in == 1'b1 & SRVAL_Q3 == 1'b1))
	    
	    q1prnk1 <= # ffinp SRVAL_Q3;
	
	else if (rev_in == 1'b1)
	    
	    q1prnk1 <= # ffinp !SRVAL_Q3;
	
	else if (ice == 1'b1)
	    
	    q1prnk1 <= # ffinp q1rnk1;
	
    end // always @ (posedge memmux or posedge sr_in or posedge rev_in or posedge rev_in_AND_NOT_sr_in or posedge NOT_rev_in_AND_sr_in)
    
    
// 5th and 6th flops in rank 1 which are not full featured but can be clocked
//  by either clk or oclk
    always @(posedge memmux or posedge sr_in) begin

	if (sr_in == 1'b1) begin
	    
	    q3rnk1 <= # ffinp 1'b0;
	    q4rnk1 <= # ffinp 1'b0;
	    
	end
	else begin
	    
	    q3rnk1 <= # ffinp dataq3rnk1;
	    q4rnk1 <= # ffinp dataq4rnk1;
	    
	end
	
    end // always @ (posedge memmux or posedge sr_in)
    
    
//////////////////////////////////////////
// Mux elements for the 1st rank
////////////////////////////////////////

// Optional inverter for q2p (4th flop in rank1)
    always @ (memmux) begin

	case (INTERFACE_TYPE)

	    "MEMORY" : q2pmux <= # mxinp1 !memmux;
	    "NETWORKING" : q2pmux <= # mxinp1 memmux;
	    default: q2pmux <= # mxinp1 !memmux;
	    
	endcase

    end // always @ (memmux)
    
    
// 4 clock muxs in first rank
    always @(clk_in or oclk_in) begin

	case (INTERFACE_TYPE)

	    "MEMORY" : memmux <= # mxinp1 oclk_in;
	    "NETWORKING" : memmux <= # mxinp1 clk_in;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute INTERFACE_TYPE on ISERDES instance %m is set to %s.  Legal values for this attribute are MEMORY or NETWORKING", INTERFACE_TYPE);
		          $finish;
                      end

	endcase // case(INTERFACE_TYPE)
	
    end // always @(clk_in or oclk_in)

    

    
// data input mux for q3, q4, q5 and q6
    always @(sel1 or q1prnk1 or shiftin1_in or shiftin2_in) begin

	case (sel1)

	    2'b00 : dataq3rnk1 <= # mxinp1 q1prnk1;
	    2'b01 : dataq3rnk1 <= # mxinp1 q1prnk1;
	    2'b10 : dataq3rnk1 <= # mxinp1 shiftin2_in;
	    2'b11 : dataq3rnk1 <= # mxinp1 shiftin1_in;
	    default : dataq3rnk1 <= # mxinp1 q1prnk1;

	endcase // case(sel1)

    end // always @(sel1 or q1prnk1 or SHIFTIN1 or SHIFTIN2)
    

    always @(sel1 or q2prnk1 or q3rnk1 or shiftin1_in) begin

	case (sel1)

	    2'b00 : dataq4rnk1 <= # mxinp1 q2prnk1;
	    2'b01 : dataq4rnk1 <= # mxinp1 q3rnk1;
	    2'b10 : dataq4rnk1 <= # mxinp1 shiftin1_in;
	    2'b11 : dataq4rnk1 <= # mxinp1 q3rnk1;
	    default : dataq4rnk1 <= # mxinp1 q2prnk1;
		
	endcase // case(sel1)
	
    end // always @(sel1 or q2prnk1 or q3rnk1 or SHIFTIN1)
    

    always @(data_rate_int or q3rnk1 or q4rnk1) begin

	case (data_rate_int)

	    1'b0 : dataq5rnk1 <= # mxinp1 q3rnk1;
	    1'b1 : dataq5rnk1 <= # mxinp1 q4rnk1;
	    default : dataq5rnk1 <= # mxinp1 q4rnk1;

	endcase // case(DATA_RATE)

    end
    
    
    always @(data_rate_int or q4rnk1 or q5rnk1) begin

	case (data_rate_int)

	    1'b0 : dataq6rnk1 <= # mxinp1 q4rnk1;
	    1'b1 : dataq6rnk1 <= # mxinp1 q5rnk1;
	    default : dataq6rnk1 <= # mxinp1 q5rnk1;
		
	endcase // case(DATA_RATE)

    end
    

// 2nd rank of registers

// clkdivmux to pass clkdiv_int or CLKDIV to rank 2
    always @(bitslip_enable_int or clkdiv_int or clkdiv_in) begin

	case (bitslip_enable_int)
	    
	    1'b0 : clkdivmux <= # mxinp1 clkdiv_in;
	    1'b1 : clkdivmux <= # mxinp1 clkdiv_int;
	    default : clkdivmux <= # mxinp1 clkdiv_in;

	endcase // case(BITSLIP_ENABLE)
	
    end // always @(clkdiv_int or clkdiv_in)
    


// Asynchronous Operation
    always @(posedge clkdivmux or posedge sr_in) begin
	
	if (sr_in == 1'b1) begin
	    
	    q1rnk2 <= # ffinp 1'b0;
	    q2rnk2 <= # ffinp 1'b0;
	    q3rnk2 <= # ffinp 1'b0;
	    q4rnk2 <= # ffinp 1'b0;
	    q5rnk2 <= # ffinp 1'b0;
	    q6rnk2 <= # ffinp 1'b0;
	    
	end
	else begin
	    
	    q1rnk2 <= # ffinp dataq1rnk2;
	    q2rnk2 <= # ffinp dataq2rnk2;
	    q3rnk2 <= # ffinp dataq3rnk2;
	    q4rnk2 <= # ffinp dataq4rnk2;
	    q5rnk2 <= # ffinp dataq5rnk2;
	    q6rnk2 <= # ffinp dataq6rnk2;
	    
	end
	
    end // always @ (posedge clkdivmux or sr_in)
    
	
// Data mux for 2nd rank of flops
// Delay for mux set to 120 
    always @(bsmux or q1rnk1 or q1prnk1 or q2prnk1) begin

	casex (bsmux)
	    
	    3'b00X : dataq1rnk2 <= # mxinp2 q2prnk1;
	    3'b100 : dataq1rnk2 <= # mxinp2 q2prnk1;
	    3'b101 : dataq1rnk2 <= # mxinp2 q1prnk1;
	    3'bX1X : dataq1rnk2 <= # mxinp2 q1rnk1;
	    default : dataq1rnk2 <= # mxinp2 q2prnk1;

	endcase // casex(bsmux)
	
    end // always @(bsmux or q1rnk1 or q1prnk1 or q2prnk1)

    
    always @(bsmux or q1prnk1 or q4rnk1) begin

	casex (bsmux)

	    3'b00X : dataq2rnk2 <= # mxinp2 q1prnk1;
	    3'b100 : dataq2rnk2 <= # mxinp2 q1prnk1;
	    3'b101 : dataq2rnk2 <= # mxinp2 q4rnk1;
	    3'bX1X : dataq2rnk2 <= # mxinp2 q1prnk1;
	    default : dataq2rnk2 <= # mxinp2 q1prnk1;

	endcase // casex(bsmux)

    end // always @(bsmux or q1prnk1 or q4rnk1)
    
	    
    always @(bsmux or q3rnk1 or q4rnk1) begin

	casex (bsmux)
	    
	    3'b00X : dataq3rnk2 <= # mxinp2 q4rnk1;
	    3'b100 : dataq3rnk2 <= # mxinp2 q4rnk1;
	    3'b101 : dataq3rnk2 <= # mxinp2 q3rnk1;
	    3'bX1X : dataq3rnk2 <= # mxinp2 q3rnk1;
	    default : dataq3rnk2 <= # mxinp2 q4rnk1;

	endcase // casex(bsmux)

    end // always @(bsmux or q3rnk1 or q4rnk1)

    
    always @(bsmux or q3rnk1 or q4rnk1 or q6rnk1) begin

	casex (bsmux)

	    3'b00X : dataq4rnk2 <= # mxinp2 q3rnk1;
	    3'b100 : dataq4rnk2 <= # mxinp2 q3rnk1;
	    3'b101 : dataq4rnk2 <= # mxinp2 q6rnk1;
	    3'bX1X : dataq4rnk2 <= # mxinp2 q4rnk1;
	    default : dataq4rnk2 <= # mxinp2 q3rnk1;

	endcase // casex(bsmux)

    end // always @(bsmux or q3rnk1 or q4rnk1 or q6rnk1)

    
    always @(bsmux or q5rnk1 or q6rnk1) begin

	casex (bsmux)

	    3'b00X : dataq5rnk2 <= # mxinp2 q6rnk1;
	    3'b100 : dataq5rnk2 <= # mxinp2 q6rnk1;
	    3'b101 : dataq5rnk2 <= # mxinp2 q5rnk1;
	    3'bX1X : dataq5rnk2 <= # mxinp2 q5rnk1;
	    default : dataq5rnk2 <= # mxinp2 q6rnk1;

	endcase // casex(bsmux)

    end // always @(bsmux or q5rnk1 or q6rnk1)

    
    always @(bsmux or q5rnk1 or q6rnk1 or q6prnk1) begin

	casex (bsmux)
	
	    3'b00X : dataq6rnk2 <= # mxinp2 q5rnk1;
	    3'b100 : dataq6rnk2 <= # mxinp2 q5rnk1;
	    3'b101 : dataq6rnk2 <= # mxinp2 q6prnk1;
	    3'bX1X : dataq6rnk2 <= # mxinp2 q6rnk1;
	    default : dataq6rnk2 <= # mxinp2 q5rnk1;

	endcase // casex(bsmux)

    end // always @(bsmux or q5rnk1 or q6rnk1 or q6prnk1)



// 3rd rank of registers

// Asynchronous Operation
    always @(posedge clkdiv_in or posedge sr_in) begin

	if (sr_in == 1'b1) begin
	    
	    q1rnk3 <= # ffinp 1'b0;
	    q2rnk3 <= # ffinp 1'b0;
	    q3rnk3 <= # ffinp 1'b0;
	    q4rnk3 <= # ffinp 1'b0;
	    q5rnk3 <= # ffinp 1'b0;
	    q6rnk3 <= # ffinp 1'b0;
	    
	end
	else begin
	    
	    q1rnk3 <= # ffinp q1rnk2;
	    q2rnk3 <= # ffinp q2rnk2;
	    q3rnk3 <= # ffinp q3rnk2;
	    q4rnk3 <= # ffinp q4rnk2;
	    q5rnk3 <= # ffinp q5rnk2;
	    q6rnk3 <= # ffinp q6rnk2;
	    
	end
	
    end // always @ (posedge clkdiv_in or posedge sr_in)
    
    
// Outputs

    assign shiftout2_out = q5rnk1;
    
    assign shiftout1_out = q6rnk1;

    
    always @(selrnk3 or q1rnk1 or q1prnk1 or q1rnk2 or q1rnk3) begin

	casex (selrnk3)

		4'b0X00 : q1_out <= # mxinp1_my q1prnk1;
		4'b0X01 : q1_out <= # mxinp1_my q1rnk1;
		4'b0X10 : q1_out <= # mxinp1_my q1rnk1;
		4'b10XX : q1_out <= # mxinp1_my q1rnk2;
		4'b11XX : q1_out <= # mxinp1_my q1rnk3;
		default : q1_out <= # mxinp1_my q1rnk2;

	endcase // casex(selrnk3)
	
    end // always @(selrnk3 or q1rnk1 or q1prnk1 or q1rnk2 or q1rnk3)
    

    always @(selrnk3 or q2nrnk1 or q2prnk1 or q2rnk2 or q2rnk3) begin

	casex (selrnk3)

	    4'b0X00 : q2_out <= # mxinp1_my q2prnk1;
	    4'b0X01 : q2_out <= # mxinp1_my q2prnk1;
	    4'b0X10 : q2_out <= # mxinp1_my q2nrnk1;
	    4'b10XX : q2_out <= # mxinp1_my q2rnk2;
	    4'b11XX : q2_out <= # mxinp1_my q2rnk3;
	    default : q2_out <= # mxinp1_my q2rnk2;

	endcase // casex(selrnk3)

    end // always @(selrnk3 or q2nrnk1 or q2prnk1 or q2rnk2 or q2rnk3)
    
    
    always @(bitslip_enable_int or q3rnk2 or q3rnk3) begin

	case (bitslip_enable_int)

	    1'b0 : q3_out <= # mxinp1_my q3rnk2;
	    1'b1 : q3_out <= # mxinp1_my q3rnk3;

	endcase // case(BITSLIP_ENABLE)

    end // always @ (q3rnk2 or q3rnk3)
    
    

    
    always @(bitslip_enable_int or q4rnk2 or q4rnk3) begin

	casex (bitslip_enable_int)

	    1'b0 : q4_out <= # mxinp1_my q4rnk2;
	    1'b1 : q4_out <= # mxinp1_my q4rnk3;

	endcase // casex(BITSLIP_ENABLE)
	
    end // always @ (q4rnk2 or q4rnk3)
        

    always @(bitslip_enable_int or q5rnk2 or q5rnk3) begin

	casex (bitslip_enable_int)

	    1'b0 : q5_out <= # mxinp1_my q5rnk2;
	    1'b1 : q5_out <= # mxinp1_my q5rnk3;

	endcase // casex(BITSLIP_ENABLE)
	
    end // always @ (q5rnk2 or q5rnk3)    

    
    always @(bitslip_enable_int or q6rnk2 or q6rnk3) begin

	casex (bitslip_enable_int)

	    1'b0 : q6_out <= # mxinp1_my q6rnk2;
	    1'b1 : q6_out <= # mxinp1_my q6rnk3;

	endcase // casex(BITSLIP_ENABLE)
	
    end // always @ (q6rnk2 or q6rnk3)
    


    
       
// Set value of counter in bitslip controller
    always @(data_rate_int or data_width_int) begin

	casex ({data_rate_int, data_width_int})

	    5'b00100 : begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b00; end
	    5'b00110 : begin c23=1'b1; c45=1'b0; c67=1'b0; sel=2'b00; end
	    5'b01000 : begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b01; end
	    5'b01010 : begin c23=1'b0; c45=1'b1; c67=1'b0; sel=2'b01; end
	    5'b10010 : begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b00; end
	    5'b10011 : begin c23=1'b1; c45=1'b0; c67=1'b0; sel=2'b00; end
	    5'b10100 : begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b01; end
	    5'b10101 : begin c23=1'b0; c45=1'b1; c67=1'b0; sel=2'b01; end
	    5'b10110 : begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b10; end
	    5'b10111 : begin c23=1'b0; c45=1'b0; c67=1'b1; sel=2'b10; end
	    5'b11000 : begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b11; end
	    default : begin
		          $display("DATA_WIDTH %d and DATA_RATE %s at %t is an illegal value", DATA_WIDTH, DATA_RATE, $time);
		          $finish;
	    end
	    
	endcase

    end // always @ (data_rate_int or data_width_int)
    
    
    


///////////////////////////////////////////
// Bit slip controler
///////////////////////////////////////////


// Divide by 2 - 8 counter

// Asynchronous Operation
    always @ (posedge qr2 or negedge clk_in) begin

	if (qr2 == 1'b1) begin
	    
	    clkdiv_int <= # ffbsc 1'b0;
	    bts_q1 <= # ffbsc 1'b0;
	    bts_q2 <= # ffbsc 1'b0;
	    bts_q3 <= # ffbsc 1'b0;
	    
	end
	else if (qhc1 == 1'b0) begin
	    
	    bts_q3 <= # ffbsc bts_q2;
	    bts_q2 <= # ffbsc (!(!clkdiv_int & !bts_q2) & bts_q1);
	    bts_q1 <= # ffbsc clkdiv_int;
	    clkdiv_int <= # ffbsc mux;
	    
	end
	
    end // always @ (posedge qr2 or negedge clk_in)

    
// Synchronous Operation
    always @ (negedge clk_in) begin

	if (qr2 == 1'b1) begin
	    
	    clkdiv_int <= # ffbsc 1'b0;
	    bts_q1 <= # ffbsc 1'b0;
	    bts_q2 <= # ffbsc 1'b0;
	    bts_q3 <= # ffbsc 1'b0;
	    
	end
	else if (qhc1 == 1'b1) begin
	    
	    clkdiv_int <= # ffbsc clkdiv_int;
	    bts_q1 <= # ffbsc bts_q1;
	    bts_q2 <= # ffbsc bts_q2;
	    bts_q3 <= # ffbsc bts_q3;
	    
	end
	else begin
	    
	    bts_q3 <= # ffbsc bts_q2;
	    bts_q2 <= # ffbsc (!(!clkdiv_int & !bts_q2) & bts_q1);
	    bts_q1 <= # ffbsc clkdiv_int;
	    clkdiv_int <= # ffbsc mux;
	    
	end

    end // always @ (negedge clk_in)
    
    
// 4:1 selector mux and divider selections
    always @ (sel or c23 or c45 or c67 or clkdiv_int or bts_q1 or bts_q2 or bts_q3) begin

	case (sel)

	    2'b00 : mux <= # mxbsc !(clkdiv_int |  (c23 & bts_q1));
	    2'b01 : mux <= # mxbsc !(bts_q1 | (c45 & bts_q2));
	    2'b10 : mux <= # mxbsc !(bts_q2 | (c67 & bts_q3));
	    2'b11 : mux <= # mxbsc !bts_q3;
	    default : mux <= # mxbsc !(clkdiv_int |  (c23 & bts_q1));

	endcase
	
    end // always @ (sel or c23 or c45 or c67 or clkdiv_int or bts_q1 or bts_q2 or bts_q3)
    


// Bitslip control logic
// Low speed control flop

// Asynchronous Operation
    always @ (posedge qr1 or posedge clkdiv_in) begin

	if (qr1 == 1'b1) begin
	    
	    qlc1 <= # ffbsc 1'b0;
	    qlc2 <= # ffbsc 1'b0;
	    
	end
	else if (bitslip_in == 1'b0) begin
	    
	    qlc1 <= # ffbsc qlc1;
	    qlc2 <= # ffbsc 1'b0;
		
	end
	else begin
	    
	    qlc1 <= # ffbsc !qlc1;
	    qlc2 <= # ffbsc (bitslip_in & mux1);
	    
	end
	
    end // always @ (posedge qr1 or posedge clkdiv_in)
    

// Mux to select between sdr "1" and ddr "0"

    always @ (data_rate_int or qlc1) begin

	case (data_rate_int)

	    1'b0 : mux1 <= # mxbsc qlc1;
	    1'b1 : mux1 <= # mxbsc 1'b1;

	endcase

    end



// High speed control flop

// Asynchronous Operation
    always @ (posedge qr2 or negedge clk_in) begin

	if (qr2 == 1'b1) begin
	    
	    qhc1 <= # ffbsc 1'b0;
	    qhc2 <= # ffbsc 1'b0;
	    
	end
	else begin
	    
	    qhc1 <= # ffbsc (qlc2 & !qhc2);
		qhc2 <= # ffbsc qlc2;
	    
	end
	
    end // always @ (posedge qr2 or negedge clk_in)
    
    
// Mux that drives control line of mux in front 
//	of 2nd rank of flops

    always @ (data_rate_int or mux1) begin

	case (data_rate_int)

	    1'b0 : muxc <= # mxbsc mux1;
	    1'b1 : muxc <= # mxbsc 1'b0;

	endcase

    end


// Asynchronous set flops

// Low speed reset flop

// Asynchronous Operation
    always @ (posedge sr_in or posedge clkdiv_in) begin

	if (sr_in == 1'b1)
	    
	    qr1 <= # ffbsc 1'b1;
	
	else
	    
	    qr1 <= # ffbsc 1'b0;
	
    end // always @ (posedge sr_in or posedge clkdiv_in)
        
    
// High speed reset flop

// Asynchronous Operation
    always @ (posedge sr_in or negedge clk_in) begin

	if (sr_in == 1'b1)
	    
	    qr2 <= # ffbsc 1'b1;
	
	else
	    
	    qr2 <= # ffbsc qr1;
	
    end // always @ (posedge sr_in or negedge clk_in)
	

/////////////////////////////////////////////    
// ICE
///////////////////////////////////////////


// Asynchronous Operation
    always @ (posedge clkdiv_in or posedge sr_in) begin

	if (sr_in == 1'b1) begin
	    
	    ce1r <= # ffice 1'b0;
	    ce2r <= # ffice 1'b0;
	    
	end
	else begin
	    
	    ce1r <= # ffice ce1_in;
	    ce2r <= # ffice ce2_in;
	    
	end
	
    end // always @ (posedge clkdiv_in or posedge sr_in)

    
    // Output mux ice
    always @ (num_ce_int or clkdiv_in or ce1_in or ce1r or ce2r) begin
	case ({num_ce_int, clkdiv_in})
	    2'b00 : ice <= # mxice ce1_in;
	    2'b01 : ice <= # mxice ce1_in;
// 426606
	    2'b10 : ice <= # mxice ce2r;
	    2'b11 : ice <= # mxice ce1r;
	    default : ice <= # mxice ce1_in;
	endcase
    end

    specify

	(CLKDIV => Q1) = (100, 100);
	(CLKDIV => Q2) = (100, 100);
	(CLKDIV => Q3) = (100, 100);
	(CLKDIV => Q4) = (100, 100);
	(CLKDIV => Q5) = (100, 100);
	(CLKDIV => Q6) = (100, 100);
	specparam PATHPULSE$ = 0;
    
    endspecify

endmodule // ISERDES
