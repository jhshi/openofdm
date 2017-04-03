// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/IDELAY.v,v 1.10 2007/06/08 01:59:04 fphillip Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Input Delay Line
// /___/   /\     Filename : IDELAY.v
// \   \  /  \    Timestamp : Thu Mar 11 16:43:51 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/11/05 - Initialized outpus.
//    03/18/05 - Changed SIM_TAPDELAY_VALUE to 75 from 78.
//    05/29/07 - Added wire declaration for internal signals
// End Revision

`timescale  1 ps / 1 ps

module IDELAY (O, C, CE, I, INC, RST);
    
    output O;

    input C;
    input CE;
    tri0 GSR = glbl.GSR;
    input I;
    input INC;
    input RST;

    parameter IOBDELAY_TYPE = "DEFAULT";    
    parameter integer IOBDELAY_VALUE = 0;
    
    reg o_out = 0;
    integer delay_count;

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

    wire c_in;
    wire ce_in;
    wire gsr_in;
    wire i_in;
    wire inc_in;
    wire rst_in;
    
    buf buf_c (c_in, C);
    buf buf_ce (ce_in, CE);
    buf buf_gsr (gsr_in, GSR);
    buf buf_i (i_in, I);
    buf buf_inc (inc_in, INC);    
    buf buf_rst (rst_in, RST);
    buf buf_o (O, o_out);
    
    localparam SIM_TAPDELAY_VALUE = 75;
    
// GSR
    always @(gsr_in)
	
	if (gsr_in == 1'b1) begin

	    if (IOBDELAY_TYPE == "DEFAULT")

		assign delay_count = 0;

	    else
		
		assign delay_count = IOBDELAY_VALUE;

	end    
	else if (gsr_in == 1'b0) begin

	    deassign delay_count;

	end

    

    initial begin

	if (IOBDELAY_VALUE < 0 || IOBDELAY_VALUE > 63) begin

	    $display("Attribute Syntax Error : The attribute IOBDELAY_VALUE on IDELAY instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 3, .... or 63", IOBDELAY_VALUE);
	    $finish;

        end
	
	
	if (IOBDELAY_TYPE != "DEFAULT" && IOBDELAY_TYPE != "FIXED" && IOBDELAY_TYPE != "VARIABLE") begin

	    $display("Attribute Syntax Error : The attribute IOBDELAY_TYPE on IDELAY instance %m is set to %s.  Legal values for this attribute are DEFAULT, FIXED or VARIABLE", IOBDELAY_TYPE);
	    $finish;

        end
	
    end // initial begin
    
    
    
    always @(posedge c_in) begin

	if (IOBDELAY_TYPE == "VARIABLE") begin
    
	    if (rst_in == 1'b1)
		delay_count = IOBDELAY_VALUE;

    	    else if (rst_in == 1'b0 && ce_in == 1'b1) begin	    

		if (inc_in == 1'b1) begin
    
		    if (delay_count < 63)

			delay_count = delay_count + 1;

		    else if (delay_count == 63)

			delay_count = 0;
		    
		end	
		else if (inc_in == 1'b0) begin
		    
		    if (delay_count > 0)
		    
			delay_count = delay_count - 1;

		    else if (delay_count == 0)

			delay_count = 63;
		end
		
	    end

	end // if (IOBDELAY_TYPE == "VARIABLE")

    end // always @ (posedge clkdiv_in)

    
// delay chain
    assign                     delay_chain_0  = i_in;
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
    always @(delay_count) begin

	case (delay_count)
            0:  assign o_out = delay_chain_0;
            1:  assign o_out = delay_chain_1;
            2:  assign o_out = delay_chain_2;
            3:  assign o_out = delay_chain_3;
            4:  assign o_out = delay_chain_4;
            5:  assign o_out = delay_chain_5;
            6:  assign o_out = delay_chain_6;
            7:  assign o_out = delay_chain_7;
            8:  assign o_out = delay_chain_8;
            9:  assign o_out = delay_chain_9;
            10: assign o_out = delay_chain_10;
            11: assign o_out = delay_chain_11;
            12: assign o_out = delay_chain_12;
            13: assign o_out = delay_chain_13;
            14: assign o_out = delay_chain_14;
            15: assign o_out = delay_chain_15;
            16: assign o_out = delay_chain_16;
            17: assign o_out = delay_chain_17;
            18: assign o_out = delay_chain_18;
            19: assign o_out = delay_chain_19;
            20: assign o_out = delay_chain_20;
            21: assign o_out = delay_chain_21;
            22: assign o_out = delay_chain_22;
            23: assign o_out = delay_chain_23;
            24: assign o_out = delay_chain_24;
            25: assign o_out = delay_chain_25;
            26: assign o_out = delay_chain_26;
            27: assign o_out = delay_chain_27;
            28: assign o_out = delay_chain_28;
            29: assign o_out = delay_chain_29;
            30: assign o_out = delay_chain_30;
            31: assign o_out = delay_chain_31;
            32: assign o_out = delay_chain_32;
            33: assign o_out = delay_chain_33;
            34: assign o_out = delay_chain_34;
            35: assign o_out = delay_chain_35;
            36: assign o_out = delay_chain_36;
            37: assign o_out = delay_chain_37;
            38: assign o_out = delay_chain_38;
            39: assign o_out = delay_chain_39;
            40: assign o_out = delay_chain_40;
            41: assign o_out = delay_chain_41;
            42: assign o_out = delay_chain_42;
            43: assign o_out = delay_chain_43;
            44: assign o_out = delay_chain_44;
            45: assign o_out = delay_chain_45;
            46: assign o_out = delay_chain_46;
            47: assign o_out = delay_chain_47;
            48: assign o_out = delay_chain_48;
            49: assign o_out = delay_chain_49;
            50: assign o_out = delay_chain_50;
            51: assign o_out = delay_chain_51;
            52: assign o_out = delay_chain_52;
            53: assign o_out = delay_chain_53;
            54: assign o_out = delay_chain_54;
            55: assign o_out = delay_chain_55;
            56: assign o_out = delay_chain_56;
            57: assign o_out = delay_chain_57;
            58: assign o_out = delay_chain_58;
            59: assign o_out = delay_chain_59;
            60: assign o_out = delay_chain_60;
            61: assign o_out = delay_chain_61;
            62: assign o_out = delay_chain_62;
            63: assign o_out = delay_chain_63;
            default:
		assign o_out = delay_chain_0;

	endcase
    end // always @ (delay_count)
    

    
endmodule // IDELAY



