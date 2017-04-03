///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Input and/or Output Fixed or Variable Delay Element.
// /___/   /\     Filename : IODELAY.v
// \   \  /  \    Timestamp : Thu Jul 28 15:58:12 PDT 2005
//  \___\/\___\
//
// Revision:
//    07/28/05 - Initial version.
//    01/11/06 - Changed Equation for CALC_TAPDELAY --FP
//    02/28/06 - CR 226003 -- Added Parameter Types (integer/real) --FP
//    03/10/06 - CR 227041 -- Added path delays --FP
//    06/04/06 - Made the model independent of T pin (except in DELAY_SRC=IO mode) --FP
//    07/21/06 - CR 234556 fix. Added SIM_DELAY_D to Simprims --FP
//    01/03/07 - For simprims, the fixed Delay value is taken from the sdf.
//    03/26/07 - CR 436199 , changed default value of HIGH_PERFORMANCE_MODE -- FP
//    03/26/07 - CR 436765 -- FP
//    05/03/07 - CR 438921 SIGNAL_PATTERN  -- FP
//    07/07/07 - Added wire declarations
//    08/29/07 - CR 445561 -- Replaced D_IOBDELAY_OFFSET with D_IODELAY_OFFSET
// End Revision

`timescale  1 ps / 1 ps

module IODELAY (DATAOUT, C, CE, DATAIN, IDATAIN, INC, ODATAIN, RST, T);

    parameter DELAY_SRC    = "I";
    parameter HIGH_PERFORMANCE_MODE    = "TRUE";
    parameter IDELAY_TYPE  = "DEFAULT";
    parameter integer IDELAY_VALUE = 0;
    parameter integer ODELAY_VALUE = 0;
    parameter real REFCLK_FREQUENCY = 200.0;
    parameter SIGNAL_PATTERN    = "DATA";

    output DATAOUT;

    input C;
    input CE;
    input DATAIN;
    input IDATAIN;
    input INC;
    input ODATAIN;
    input RST;
    input T ;


    localparam ILEAK_ADJUST = 1.0;
    localparam D_IODELAY_OFFSET = 0.0;

    tri0  GSR = glbl.GSR;

//------------------- constants ------------------------------------

    localparam MAX_IDELAY_COUNT = 63; 
    localparam MIN_IDELAY_COUNT = 0; 
    localparam MAX_ODELAY_COUNT = 63; 
    localparam MIN_ODELAY_COUNT = 0; 

    localparam MAX_REFCLK_FREQUENCY = 225.0;
    localparam MIN_REFCLK_FREQUENCY = 175.0;

//------------------- variable declaration -------------------------

    integer idelay_count, odelay_count;

    

    reg data_mux = 0;
    reg tap_out   = 0;

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
    wire datain_in;
    wire gsr_in;
    wire idatain_in;
    wire inc_in;
    wire odatain_in;
    wire rst_in;
    wire t_in;

    real CALC_TAPDELAY = 0.0; 
//----------------------------------------------------------------------
//------------------------  Output buffering  ------------------------------
//----------------------------------------------------------------------
    buf buf_odataout (DATAOUT, tap_out);

//-----------------------------------------------------
//-----------   Input buffering  --------------------------------
//-----------------------------------------------------

    buf buf_c (c_in, C);
    buf buf_ce (ce_in, CE);
    buf buf_ (datain_in, DATAIN);
    buf buf_gsr (gsr_in, GSR);
    buf buf_i (idatain_in, IDATAIN);
    buf buf_inc (inc_in, INC);
    buf buf_o (odatain_in, ODATAIN);
    buf buf_rst (rst_in, RST);
    buf buf_t (t_in, T);


//*** GLOBAL hidden GSR pin
    always @(gsr_in) begin
	if (gsr_in == 1'b1) begin

            assign odelay_count = ODELAY_VALUE;

            if (IDELAY_TYPE == "DEFAULT")
                assign idelay_count = 0;
            else
                assign idelay_count = IDELAY_VALUE;
            end
	else if (gsr_in == 1'b0) begin
	    deassign idelay_count;
	    deassign odelay_count;
	end
    end


    initial begin

        //-------- SIGNAL_PATTERN check

        case (SIGNAL_PATTERN)
            "CLOCK", "DATA" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute SIGNAL_PATTERN on IODELAY instance %m is set to %s.  Legal values for this attribute are DATA or CLOCK.",  SIGNAL_PATTERN);
               $finish;
            end
        endcase

        //-------- HIGH_PERFORMANCE_MODE check

        case (HIGH_PERFORMANCE_MODE)
            "TRUE", "FALSE" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute HIGH_PERFORMANCE_MODE on IODELAY instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.",  HIGH_PERFORMANCE_MODE);
               $finish;
            end
        endcase


        //-------- IDELAY_TYPE check

        if (IDELAY_TYPE != "DEFAULT" && IDELAY_TYPE != "FIXED" && IDELAY_TYPE != "VARIABLE") begin

            $display("Attribute Syntax Error : The attribute IDELAY_TYPE on IODELAY instance %m is set to %s.  Legal values for this attribute are DEFAULT, FIXED or VARIABLE", IDELAY_TYPE);
            $finish;

        end


        //-------- IDELAY_VALUE check

        if (IDELAY_VALUE < MIN_IDELAY_COUNT || IDELAY_VALUE > MAX_IDELAY_COUNT) begin
            $display("Attribute Syntax Error : The attribute IDELAY_VALUE on IODELAY instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 3, .... or 63", IDELAY_VALUE);
            $finish;

        end


        //-------- ODELAY_VALUE check

        if (ODELAY_VALUE < MIN_ODELAY_COUNT || ODELAY_VALUE > MAX_ODELAY_COUNT) begin
            $display("Attribute Syntax Error : The attribute ODELAY_VALUE on IODELAY instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 3, .... or 63", ODELAY_VALUE);
            $finish;

        end

        //-------- REFCLK_FREQUENCY check

        if (REFCLK_FREQUENCY < MIN_REFCLK_FREQUENCY || REFCLK_FREQUENCY > MAX_REFCLK_FREQUENCY) begin
            $display("Attribute Syntax Error : The attribute REFCLK_FREQUENCY on IODELAY instance %m is set to %f.  Legal values for this attribute are 175.0 to 225.0", REFCLK_FREQUENCY);
            $finish;

        end

        //-------- CALC_TAPDELAY check

        CALC_TAPDELAY = ((1.0/REFCLK_FREQUENCY) * (1.0/64) * ILEAK_ADJUST * 1000000) + D_IODELAY_OFFSET ;

    end // initial begin
    
//*********************************************************
//*** IDELAY_COUNT
//*********************************************************

    always @(posedge c_in) begin

        if (IDELAY_TYPE == "VARIABLE") begin
            if (rst_in == 1'b1)
                idelay_count = IDELAY_VALUE;
            else if (rst_in == 1'b0 && ce_in == 1'b1) begin
                if (inc_in == 1'b1) begin
                    if (idelay_count < MAX_IDELAY_COUNT)
                        idelay_count = idelay_count + 1;
                    else if (idelay_count == MAX_IDELAY_COUNT)
                        idelay_count = MIN_IDELAY_COUNT;
                end
                else if (inc_in == 1'b0) begin
                    if (idelay_count > MIN_IDELAY_COUNT)
                        idelay_count = idelay_count - 1;
                    else if (idelay_count == MIN_IDELAY_COUNT)
                        idelay_count = MAX_IDELAY_COUNT;
                end
            end
        end // if (IDELAY_TYPE == "VARIABLE")

    end // always @ (posedge c_in)

//*********************************************************
//*** ODELAY_COUNT
//*********************************************************
// is FIXED
   
//*********************************************************
//*** SELECT IDATA signal
//*********************************************************

    always @(datain_in or idatain_in, odatain_in, t_in ) begin

        case (DELAY_SRC)

            "I" : begin
                         data_mux <= idatain_in;
                  end
            "O" : begin
                         data_mux <= odatain_in;
                  end
            "IO" : begin
                         data_mux <= ((idatain_in) & t_in ) | ((odatain_in) & ~t_in);
                   end
            "DATAIN" : begin
                         data_mux <= datain_in;
                     end
            default : begin
                          $display("Attribute Syntax Error : The attribute DELAY_SRC on IODELAY instance %m is set to %s.  Legal values for this attribute are I, O, IO or DATAIN", DELAY_SRC);
                          $finish;
                      end

        endcase // case(DELAY_SRC)

    end // always @ (data_in or idatain_in or odatain_in or t_in)


//*********************************************************
//*** DELAY IDATA signal
//*********************************************************
    assign                delay_chain_0  = data_mux;
    assign #CALC_TAPDELAY delay_chain_1  = delay_chain_0;
    assign #CALC_TAPDELAY delay_chain_2  = delay_chain_1;
    assign #CALC_TAPDELAY delay_chain_3  = delay_chain_2;
    assign #CALC_TAPDELAY delay_chain_4  = delay_chain_3;
    assign #CALC_TAPDELAY delay_chain_5  = delay_chain_4;
    assign #CALC_TAPDELAY delay_chain_6  = delay_chain_5;
    assign #CALC_TAPDELAY delay_chain_7  = delay_chain_6;
    assign #CALC_TAPDELAY delay_chain_8  = delay_chain_7;
    assign #CALC_TAPDELAY delay_chain_9  = delay_chain_8;
    assign #CALC_TAPDELAY delay_chain_10 = delay_chain_9;
    assign #CALC_TAPDELAY delay_chain_11 = delay_chain_10;
    assign #CALC_TAPDELAY delay_chain_12 = delay_chain_11;
    assign #CALC_TAPDELAY delay_chain_13 = delay_chain_12;
    assign #CALC_TAPDELAY delay_chain_14 = delay_chain_13;
    assign #CALC_TAPDELAY delay_chain_15 = delay_chain_14;
    assign #CALC_TAPDELAY delay_chain_16 = delay_chain_15;
    assign #CALC_TAPDELAY delay_chain_17 = delay_chain_16;
    assign #CALC_TAPDELAY delay_chain_18 = delay_chain_17;
    assign #CALC_TAPDELAY delay_chain_19 = delay_chain_18;
    assign #CALC_TAPDELAY delay_chain_20 = delay_chain_19;
    assign #CALC_TAPDELAY delay_chain_21 = delay_chain_20;
    assign #CALC_TAPDELAY delay_chain_22 = delay_chain_21;
    assign #CALC_TAPDELAY delay_chain_23 = delay_chain_22;
    assign #CALC_TAPDELAY delay_chain_24 = delay_chain_23;
    assign #CALC_TAPDELAY delay_chain_25 = delay_chain_24;
    assign #CALC_TAPDELAY delay_chain_26 = delay_chain_25;
    assign #CALC_TAPDELAY delay_chain_27 = delay_chain_26;
    assign #CALC_TAPDELAY delay_chain_28 = delay_chain_27;
    assign #CALC_TAPDELAY delay_chain_29 = delay_chain_28;
    assign #CALC_TAPDELAY delay_chain_30 = delay_chain_29;
    assign #CALC_TAPDELAY delay_chain_31 = delay_chain_30;
    assign #CALC_TAPDELAY delay_chain_32 = delay_chain_31;
    assign #CALC_TAPDELAY delay_chain_33 = delay_chain_32;
    assign #CALC_TAPDELAY delay_chain_34 = delay_chain_33;
    assign #CALC_TAPDELAY delay_chain_35 = delay_chain_34;
    assign #CALC_TAPDELAY delay_chain_36 = delay_chain_35;
    assign #CALC_TAPDELAY delay_chain_37 = delay_chain_36;
    assign #CALC_TAPDELAY delay_chain_38 = delay_chain_37;
    assign #CALC_TAPDELAY delay_chain_39 = delay_chain_38;
    assign #CALC_TAPDELAY delay_chain_40 = delay_chain_39;
    assign #CALC_TAPDELAY delay_chain_41 = delay_chain_40;
    assign #CALC_TAPDELAY delay_chain_42 = delay_chain_41;
    assign #CALC_TAPDELAY delay_chain_43 = delay_chain_42;
    assign #CALC_TAPDELAY delay_chain_44 = delay_chain_43;
    assign #CALC_TAPDELAY delay_chain_45 = delay_chain_44;
    assign #CALC_TAPDELAY delay_chain_46 = delay_chain_45;
    assign #CALC_TAPDELAY delay_chain_47 = delay_chain_46;
    assign #CALC_TAPDELAY delay_chain_48 = delay_chain_47;
    assign #CALC_TAPDELAY delay_chain_49 = delay_chain_48;
    assign #CALC_TAPDELAY delay_chain_50 = delay_chain_49;
    assign #CALC_TAPDELAY delay_chain_51 = delay_chain_50;
    assign #CALC_TAPDELAY delay_chain_52 = delay_chain_51;
    assign #CALC_TAPDELAY delay_chain_53 = delay_chain_52;
    assign #CALC_TAPDELAY delay_chain_54 = delay_chain_53;
    assign #CALC_TAPDELAY delay_chain_55 = delay_chain_54;
    assign #CALC_TAPDELAY delay_chain_56 = delay_chain_55;
    assign #CALC_TAPDELAY delay_chain_57 = delay_chain_56;
    assign #CALC_TAPDELAY delay_chain_58 = delay_chain_57;
    assign #CALC_TAPDELAY delay_chain_59 = delay_chain_58;
    assign #CALC_TAPDELAY delay_chain_60 = delay_chain_59;
    assign #CALC_TAPDELAY delay_chain_61 = delay_chain_60;
    assign #CALC_TAPDELAY delay_chain_62 = delay_chain_61;
    assign #CALC_TAPDELAY delay_chain_63 = delay_chain_62;

//*********************************************************
//*** assign delay
//*********************************************************
    always @(idelay_count, odelay_count, t_in) begin
      if(DELAY_SRC == "IO") begin
        if (t_in == 1'b1) 
           case (idelay_count)
              0:  assign tap_out = delay_chain_0;
              1:  assign tap_out = delay_chain_1;
              2:  assign tap_out = delay_chain_2;
              3:  assign tap_out = delay_chain_3;
              4:  assign tap_out = delay_chain_4;
              5:  assign tap_out = delay_chain_5;
              6:  assign tap_out = delay_chain_6;
              7:  assign tap_out = delay_chain_7;
              8:  assign tap_out = delay_chain_8;
              9:  assign tap_out = delay_chain_9;
              10: assign tap_out = delay_chain_10;
              11: assign tap_out = delay_chain_11;
              12: assign tap_out = delay_chain_12;
              13: assign tap_out = delay_chain_13;
              14: assign tap_out = delay_chain_14;
              15: assign tap_out = delay_chain_15;
              16: assign tap_out = delay_chain_16;
              17: assign tap_out = delay_chain_17;
              18: assign tap_out = delay_chain_18;
              19: assign tap_out = delay_chain_19;
              20: assign tap_out = delay_chain_20;
              21: assign tap_out = delay_chain_21;
              22: assign tap_out = delay_chain_22;
              23: assign tap_out = delay_chain_23;
              24: assign tap_out = delay_chain_24;
              25: assign tap_out = delay_chain_25;
              26: assign tap_out = delay_chain_26;
              27: assign tap_out = delay_chain_27;
              28: assign tap_out = delay_chain_28;
              29: assign tap_out = delay_chain_29;
              30: assign tap_out = delay_chain_30;
              31: assign tap_out = delay_chain_31;
              32: assign tap_out = delay_chain_32;
              33: assign tap_out = delay_chain_33;
              34: assign tap_out = delay_chain_34;
              35: assign tap_out = delay_chain_35;
              36: assign tap_out = delay_chain_36;
              37: assign tap_out = delay_chain_37;
              38: assign tap_out = delay_chain_38;
              39: assign tap_out = delay_chain_39;
              40: assign tap_out = delay_chain_40;
              41: assign tap_out = delay_chain_41;
              42: assign tap_out = delay_chain_42;
              43: assign tap_out = delay_chain_43;
              44: assign tap_out = delay_chain_44;
              45: assign tap_out = delay_chain_45;
              46: assign tap_out = delay_chain_46;
              47: assign tap_out = delay_chain_47;
              48: assign tap_out = delay_chain_48;
              49: assign tap_out = delay_chain_49;
              50: assign tap_out = delay_chain_50;
              51: assign tap_out = delay_chain_51;
              52: assign tap_out = delay_chain_52;
              53: assign tap_out = delay_chain_53;
              54: assign tap_out = delay_chain_54;
              55: assign tap_out = delay_chain_55;
              56: assign tap_out = delay_chain_56;
              57: assign tap_out = delay_chain_57;
              58: assign tap_out = delay_chain_58;
              59: assign tap_out = delay_chain_59;
              60: assign tap_out = delay_chain_60;
              61: assign tap_out = delay_chain_61;
              62: assign tap_out = delay_chain_62;
              63: assign tap_out = delay_chain_63;
              default:
                  assign tap_out = delay_chain_0;
           endcase
        else if (t_in == 1'b0) 
           case (odelay_count)
              0:  assign tap_out = delay_chain_0;
              1:  assign tap_out = delay_chain_1;
              2:  assign tap_out = delay_chain_2;
              3:  assign tap_out = delay_chain_3;
              4:  assign tap_out = delay_chain_4;
              5:  assign tap_out = delay_chain_5;
              6:  assign tap_out = delay_chain_6;
              7:  assign tap_out = delay_chain_7;
              8:  assign tap_out = delay_chain_8;
              9:  assign tap_out = delay_chain_9;
              10: assign tap_out = delay_chain_10;
              11: assign tap_out = delay_chain_11;
              12: assign tap_out = delay_chain_12;
              13: assign tap_out = delay_chain_13;
              14: assign tap_out = delay_chain_14;
              15: assign tap_out = delay_chain_15;
              16: assign tap_out = delay_chain_16;
              17: assign tap_out = delay_chain_17;
              18: assign tap_out = delay_chain_18;
              19: assign tap_out = delay_chain_19;
              20: assign tap_out = delay_chain_20;
              21: assign tap_out = delay_chain_21;
              22: assign tap_out = delay_chain_22;
              23: assign tap_out = delay_chain_23;
              24: assign tap_out = delay_chain_24;
              25: assign tap_out = delay_chain_25;
              26: assign tap_out = delay_chain_26;
              27: assign tap_out = delay_chain_27;
              28: assign tap_out = delay_chain_28;
              29: assign tap_out = delay_chain_29;
              30: assign tap_out = delay_chain_30;
              31: assign tap_out = delay_chain_31;
              32: assign tap_out = delay_chain_32;
              33: assign tap_out = delay_chain_33;
              34: assign tap_out = delay_chain_34;
              35: assign tap_out = delay_chain_35;
              36: assign tap_out = delay_chain_36;
              37: assign tap_out = delay_chain_37;
              38: assign tap_out = delay_chain_38;
              39: assign tap_out = delay_chain_39;
              40: assign tap_out = delay_chain_40;
              41: assign tap_out = delay_chain_41;
              42: assign tap_out = delay_chain_42;
              43: assign tap_out = delay_chain_43;
              44: assign tap_out = delay_chain_44;
              45: assign tap_out = delay_chain_45;
              46: assign tap_out = delay_chain_46;
              47: assign tap_out = delay_chain_47;
              48: assign tap_out = delay_chain_48;
              49: assign tap_out = delay_chain_49;
              50: assign tap_out = delay_chain_50;
              51: assign tap_out = delay_chain_51;
              52: assign tap_out = delay_chain_52;
              53: assign tap_out = delay_chain_53;
              54: assign tap_out = delay_chain_54;
              55: assign tap_out = delay_chain_55;
              56: assign tap_out = delay_chain_56;
              57: assign tap_out = delay_chain_57;
              58: assign tap_out = delay_chain_58;
              59: assign tap_out = delay_chain_59;
              60: assign tap_out = delay_chain_60;
              61: assign tap_out = delay_chain_61;
              62: assign tap_out = delay_chain_62;
              63: assign tap_out = delay_chain_63;
              default:
                  assign tap_out = delay_chain_0;
           endcase
      end // DELAY_SRC == "IO"
      else if(DELAY_SRC == "O") begin
           case (odelay_count)
              0:  assign tap_out = delay_chain_0;
              1:  assign tap_out = delay_chain_1;
              2:  assign tap_out = delay_chain_2;
              3:  assign tap_out = delay_chain_3;
              4:  assign tap_out = delay_chain_4;
              5:  assign tap_out = delay_chain_5;
              6:  assign tap_out = delay_chain_6;
              7:  assign tap_out = delay_chain_7;
              8:  assign tap_out = delay_chain_8;
              9:  assign tap_out = delay_chain_9;
              10: assign tap_out = delay_chain_10;
              11: assign tap_out = delay_chain_11;
              12: assign tap_out = delay_chain_12;
              13: assign tap_out = delay_chain_13;
              14: assign tap_out = delay_chain_14;
              15: assign tap_out = delay_chain_15;
              16: assign tap_out = delay_chain_16;
              17: assign tap_out = delay_chain_17;
              18: assign tap_out = delay_chain_18;
              19: assign tap_out = delay_chain_19;
              20: assign tap_out = delay_chain_20;
              21: assign tap_out = delay_chain_21;
              22: assign tap_out = delay_chain_22;
              23: assign tap_out = delay_chain_23;
              24: assign tap_out = delay_chain_24;
              25: assign tap_out = delay_chain_25;
              26: assign tap_out = delay_chain_26;
              27: assign tap_out = delay_chain_27;
              28: assign tap_out = delay_chain_28;
              29: assign tap_out = delay_chain_29;
              30: assign tap_out = delay_chain_30;
              31: assign tap_out = delay_chain_31;
              32: assign tap_out = delay_chain_32;
              33: assign tap_out = delay_chain_33;
              34: assign tap_out = delay_chain_34;
              35: assign tap_out = delay_chain_35;
              36: assign tap_out = delay_chain_36;
              37: assign tap_out = delay_chain_37;
              38: assign tap_out = delay_chain_38;
              39: assign tap_out = delay_chain_39;
              40: assign tap_out = delay_chain_40;
              41: assign tap_out = delay_chain_41;
              42: assign tap_out = delay_chain_42;
              43: assign tap_out = delay_chain_43;
              44: assign tap_out = delay_chain_44;
              45: assign tap_out = delay_chain_45;
              46: assign tap_out = delay_chain_46;
              47: assign tap_out = delay_chain_47;
              48: assign tap_out = delay_chain_48;
              49: assign tap_out = delay_chain_49;
              50: assign tap_out = delay_chain_50;
              51: assign tap_out = delay_chain_51;
              52: assign tap_out = delay_chain_52;
              53: assign tap_out = delay_chain_53;
              54: assign tap_out = delay_chain_54;
              55: assign tap_out = delay_chain_55;
              56: assign tap_out = delay_chain_56;
              57: assign tap_out = delay_chain_57;
              58: assign tap_out = delay_chain_58;
              59: assign tap_out = delay_chain_59;
              60: assign tap_out = delay_chain_60;
              61: assign tap_out = delay_chain_61;
              62: assign tap_out = delay_chain_62;
              63: assign tap_out = delay_chain_63;
              default:
                  assign tap_out = delay_chain_0;
           endcase
      end // DELAY_SRC == "O"
      else begin
           case (idelay_count)
              0:  assign tap_out = delay_chain_0;
              1:  assign tap_out = delay_chain_1;
              2:  assign tap_out = delay_chain_2;
              3:  assign tap_out = delay_chain_3;
              4:  assign tap_out = delay_chain_4;
              5:  assign tap_out = delay_chain_5;
              6:  assign tap_out = delay_chain_6;
              7:  assign tap_out = delay_chain_7;
              8:  assign tap_out = delay_chain_8;
              9:  assign tap_out = delay_chain_9;
              10: assign tap_out = delay_chain_10;
              11: assign tap_out = delay_chain_11;
              12: assign tap_out = delay_chain_12;
              13: assign tap_out = delay_chain_13;
              14: assign tap_out = delay_chain_14;
              15: assign tap_out = delay_chain_15;
              16: assign tap_out = delay_chain_16;
              17: assign tap_out = delay_chain_17;
              18: assign tap_out = delay_chain_18;
              19: assign tap_out = delay_chain_19;
              20: assign tap_out = delay_chain_20;
              21: assign tap_out = delay_chain_21;
              22: assign tap_out = delay_chain_22;
              23: assign tap_out = delay_chain_23;
              24: assign tap_out = delay_chain_24;
              25: assign tap_out = delay_chain_25;
              26: assign tap_out = delay_chain_26;
              27: assign tap_out = delay_chain_27;
              28: assign tap_out = delay_chain_28;
              29: assign tap_out = delay_chain_29;
              30: assign tap_out = delay_chain_30;
              31: assign tap_out = delay_chain_31;
              32: assign tap_out = delay_chain_32;
              33: assign tap_out = delay_chain_33;
              34: assign tap_out = delay_chain_34;
              35: assign tap_out = delay_chain_35;
              36: assign tap_out = delay_chain_36;
              37: assign tap_out = delay_chain_37;
              38: assign tap_out = delay_chain_38;
              39: assign tap_out = delay_chain_39;
              40: assign tap_out = delay_chain_40;
              41: assign tap_out = delay_chain_41;
              42: assign tap_out = delay_chain_42;
              43: assign tap_out = delay_chain_43;
              44: assign tap_out = delay_chain_44;
              45: assign tap_out = delay_chain_45;
              46: assign tap_out = delay_chain_46;
              47: assign tap_out = delay_chain_47;
              48: assign tap_out = delay_chain_48;
              49: assign tap_out = delay_chain_49;
              50: assign tap_out = delay_chain_50;
              51: assign tap_out = delay_chain_51;
              52: assign tap_out = delay_chain_52;
              53: assign tap_out = delay_chain_53;
              54: assign tap_out = delay_chain_54;
              55: assign tap_out = delay_chain_55;
              56: assign tap_out = delay_chain_56;
              57: assign tap_out = delay_chain_57;
              58: assign tap_out = delay_chain_58;
              59: assign tap_out = delay_chain_59;
              60: assign tap_out = delay_chain_60;
              61: assign tap_out = delay_chain_61;
              62: assign tap_out = delay_chain_62;
              63: assign tap_out = delay_chain_63;
              default:
                  assign tap_out = delay_chain_0;
           endcase
        end // DELAY_SRC = REST
   end // always @ (idelay_count, odelay_count, t_in)

    specify

        specparam PATHPULSE$ = 0;

    endspecify

endmodule // IODELAY

