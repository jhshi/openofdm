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
// /___/   /\     Filename : IODELAYE1.v
// \   \  /  \    Timestamp : Sat Sep  6 14:21:08 PDT 2008
//  \___\/\___\
//
// Revision:
//    09/06/08 - Initial version.
//    02/02/09 - Fixed CNTVALUEOUT for when in DEFAULT/FIXED mode. 
//    02/11/09 - IR 507221 CNTVALUEOUT fix -- Removed T dependency for I and O.
//    04/22/09 - CR 519123 -- Changed HIGH_PERFORMANCE_MODE default to FALSE.
// End Revision

`timescale  1 ps / 1 ps

module IODELAYE1 (CNTVALUEOUT, DATAOUT, C, CE, CINVCTRL, CLKIN, CNTVALUEIN, DATAIN, IDATAIN, INC, ODATAIN, RST, T);

    parameter CINVCTRL_SEL = "FALSE";
    parameter DELAY_SRC    = "I";
    parameter HIGH_PERFORMANCE_MODE    = "FALSE";
    parameter IDELAY_TYPE  = "DEFAULT";
    parameter integer IDELAY_VALUE = 0;
    parameter ODELAY_TYPE  = "FIXED";
    parameter integer ODELAY_VALUE = 0;
    parameter real REFCLK_FREQUENCY = 200.0;
    parameter SIGNAL_PATTERN    = "DATA";

    output [4:0] CNTVALUEOUT;
    output DATAOUT;

    input C;
    input CE;
    input CINVCTRL;
    input CLKIN;
    input [4:0] CNTVALUEIN;
    input DATAIN;
    input IDATAIN;
    input INC;
    input ODATAIN;
    input RST;
    input T ;


    localparam ILEAK_ADJUST = 1.0;
    localparam D_IOBDELAY_OFFSET = 0.0;

    tri0  GSR = glbl.GSR;
    real  CALC_TAPDELAY ; 
    real  INIT_DELAY;

//------------------- constants ------------------------------------

    localparam MAX_DELAY_COUNT = 31; 
    localparam MIN_DELAY_COUNT = 0; 

    localparam MAX_REFCLK_FREQUENCYL = 210.0;
    localparam MIN_REFCLK_FREQUENCYL = 190.0;

    localparam MAX_REFCLK_FREQUENCYH = 310.0;
    localparam MIN_REFCLK_FREQUENCYH = 290.0;


//------------------- variable declaration -------------------------

    integer idelay_count, odelay_count;
    integer CNTVALUEIN_INTEGER;
    reg [4:0] cntvalueout_pre;

    

    reg data_mux = 0;
    reg tap_out   = 0;

    wire delay_chain_0,  delay_chain_1,  delay_chain_2,  delay_chain_3,
         delay_chain_4,  delay_chain_5,  delay_chain_6,  delay_chain_7,
         delay_chain_8,  delay_chain_9,  delay_chain_10, delay_chain_11,
         delay_chain_12, delay_chain_13, delay_chain_14, delay_chain_15,
         delay_chain_16, delay_chain_17, delay_chain_18, delay_chain_19,
         delay_chain_20, delay_chain_21, delay_chain_22, delay_chain_23,
         delay_chain_24, delay_chain_25, delay_chain_26, delay_chain_27,
         delay_chain_28, delay_chain_29, delay_chain_30, delay_chain_31;

    reg  c_in;
    wire ce_in;
    wire clkin_in;
    wire [4:0] cntvaluein_in;
    wire datain_in;
    wire gsr_in;
    wire idatain_in;
    wire inc_in;
    wire odatain_in;
    wire rst_in;
    wire t_in;

    wire c_in_pre;


//----------------------------------------------------------------------
//-------------------------------  Output ------------------------------
//----------------------------------------------------------------------
    assign #INIT_DELAY DATAOUT = tap_out;
    assign CNTVALUEOUT = cntvalueout_pre;

//----------------------------------------------------------------------
//-------------------------------  Input -------------------------------
//----------------------------------------------------------------------
    assign c_in_pre = C;
    assign ce_in = CE;
    assign cinvctrl_in = CINVCTRL;
    assign clkin_in = CLKIN;
    assign cntvaluein_in = CNTVALUEIN;
    assign datain_in = DATAIN;
    assign gsr_in = GSR;
    assign idatain_in = IDATAIN;
    assign inc_in = INC;
    assign odatain_in = ODATAIN;
    assign rst_in = RST;
    assign t_in = T;

//*** GLOBAL hidden GSR pin
    always @(gsr_in) begin
        if (gsr_in == 1'b1) begin
                case (IDELAY_TYPE)
                        "DEFAULT" : begin
                                        assign idelay_count = 0;
                                    end
                        "VAR_LOADABLE": assign idelay_count = 0;
                        "FIXED"   : assign idelay_count = IDELAY_VALUE;
                        "VARIABLE": assign idelay_count = IDELAY_VALUE;
                endcase
                case (ODELAY_TYPE)
                        "VAR_LOADABLE": assign odelay_count = 0;
                        "FIXED"   : assign odelay_count = ODELAY_VALUE;
                        "VARIABLE": assign odelay_count = ODELAY_VALUE;
                endcase
        end
        else if (gsr_in == 1'b0) begin
            deassign idelay_count;
            deassign odelay_count;
        end
    end

//----------------------------------------------------------------------
//------------------------ Dynamic clock inversion ---------------------
//----------------------------------------------------------------------

    always @(c_in_pre or cinvctrl_in) begin
        case (CINVCTRL_SEL)
                "TRUE" : c_in = (cinvctrl_in ? ~c_in_pre : c_in_pre);
                "FALSE" : c_in = c_in_pre;
        endcase
    end

//----------------------------------------------------------------------
//------------------------      CNTVALUEOUT        ---------------------
//----------------------------------------------------------------------
    generate 
       case(DELAY_SRC)
          "IO" :    

                  always @(idelay_count or odelay_count or t_in) begin
                      if (t_in == 1) begin
//    02/02/09 - Fixed CNTVALUEOUT for when in DEFAULT/FIXED mode. 
                            if((IDELAY_TYPE != "DEFAULT") && (IDELAY_TYPE != "FIXED"))
                                 assign cntvalueout_pre = idelay_count;
                             else
                                 assign cntvalueout_pre = IDELAY_VALUE;
                      end
                      else if(t_in == 0) begin
                            if(ODELAY_TYPE != "FIXED")
                                assign cntvalueout_pre = odelay_count;
                             else
                                 assign cntvalueout_pre = ODELAY_VALUE;
                      end
                  end
          "O" :    
                  always @(odelay_count) begin
//    02/02/09 - Fixed CNTVALUEOUT for when in DEFAULT/FIXED mode -- because of simprim. 
                            if(ODELAY_TYPE != "FIXED")
                                assign cntvalueout_pre = odelay_count;
                             else
                                 assign cntvalueout_pre = ODELAY_VALUE;
                   end
          default :    
                  always @(idelay_count) begin
//    02/02/09 - Fixed CNTVALUEOUT for when in DEFAULT/FIXED mode because of simprim. 
                            if((IDELAY_TYPE != "DEFAULT") && (IDELAY_TYPE != "FIXED"))
                                 assign cntvalueout_pre = idelay_count;
                             else
                                 assign cntvalueout_pre = IDELAY_VALUE;
                  end
       endcase
    endgenerate


    initial begin

        //-------- SIGNAL_PATTERN check

        case (SIGNAL_PATTERN)
            "CLOCK", "DATA" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute SIGNAL_PATTERN on IODELAYE1 instance %m is set to %s.  Legal values for this attribute are DATA or CLOCK.",  SIGNAL_PATTERN);
               $finish;
            end
        endcase

        //-------- HIGH_PERFORMANCE_MODE check

        case (HIGH_PERFORMANCE_MODE)
            "TRUE", "FALSE" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute HIGH_PERFORMANCE_MODE on IODELAYE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.",  HIGH_PERFORMANCE_MODE);
               $finish;
            end
        endcase


        //-------- IDELAY_TYPE check

        if (IDELAY_TYPE != "DEFAULT" && IDELAY_TYPE != "FIXED" && IDELAY_TYPE != "VARIABLE" && IDELAY_TYPE != "VAR_LOADABLE") begin

            $display("Attribute Syntax Error : The attribute IDELAY_TYPE on IODELAYE1 instance %m is set to %s.  Legal values for this attribute are DEFAULT, FIXED, VARIABLE or VAR_LOADABLE", IDELAY_TYPE);
            $finish;

        end

        //-------- ODELAY_TYPE check

        if (ODELAY_TYPE != "FIXED" && ODELAY_TYPE != "VARIABLE" && ODELAY_TYPE != "VAR_LOADABLE") begin

            $display("Attribute Syntax Error : The attribute ODELAY_TYPE on IODELAY instance is set to %s.  Legal values for this attribute are FIXED, VARIABLE, VAR_LOADABLE", ODELAY_TYPE);
            $finish;

        end

        //--------Bidirectional valid cases check

        if (DELAY_SRC == "IO") begin
                if ((IDELAY_TYPE == "FIXED" && ODELAY_TYPE == "FIXED") | (IDELAY_TYPE == "FIXED" && ODELAY_TYPE == "VARIABLE") | (IDELAY_TYPE == "VARIABLE" && ODELAY_TYPE == "FIXED") | (IDELAY_TYPE == "VAR_LOADABLE" && ODELAY_TYPE == "VAR_LOADABLE")) begin
                end
                else begin
                $display("Attribute Syntax Error : The attribute IDELAY_TYPE and ODELAY_TYPE during DELAY_SRC = \"IO\" on IODELAY instance is set to %s and %s respectively.  Legal values for these attributes are FIXED-FIXED, VARIABLE-FIXED, FIXED-VARIABLE, VAR_LOADABLE-VAR_LOADABLE", IDELAY_TYPE, ODELAY_TYPE);
                $finish;

                end
        end

        //-------- IDELAY_VALUE check

        if (IDELAY_VALUE < MIN_DELAY_COUNT || IDELAY_VALUE > MAX_DELAY_COUNT) begin
            $display("Attribute Syntax Error : The attribute IDELAY_VALUE on IODELAYE1 instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 3, .... or 31", IDELAY_VALUE);
            $finish;

        end


        //-------- ODELAY_VALUE check

        if (ODELAY_VALUE < MIN_DELAY_COUNT || ODELAY_VALUE > MAX_DELAY_COUNT) begin
            $display("Attribute Syntax Error : The attribute ODELAY_VALUE on IODELAYE1 instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 3, .... or 31", ODELAY_VALUE);
            $finish;

        end

        //-------- REFCLK_FREQUENCY check

        if (REFCLK_FREQUENCY < MIN_REFCLK_FREQUENCYL || REFCLK_FREQUENCY > MAX_REFCLK_FREQUENCYH) begin
            $display("Attribute Syntax Error : The attribute REFCLK_FREQUENCY on IODELAYE1 instance %m is set to %f.  Legal values for this attribute are 175.0 to 225.0", REFCLK_FREQUENCY);
            $finish;

        end

        //-------- CALC_TAPDELAY check

        //CALC_TAPDELAY = ((1.0/REFCLK_FREQUENCY) * (1.0/64) * ILEAK_ADJUST * 1000000) + D_IOBDELAY_OFFSET ;
        INIT_DELAY = 144;

    end // initial begin

    // CALC_TAPDELAY value
    initial begin
        if ((REFCLK_FREQUENCY <= MAX_REFCLK_FREQUENCYH) && (REFCLK_FREQUENCY >= MIN_REFCLK_FREQUENCYH))
                begin
                        CALC_TAPDELAY = 52;
                end
        else
                begin
                        CALC_TAPDELAY = 78;
                end
    end

//*********************************************************
//*** IDELAY_COUNT and ODELAY_COUNT
//*********************************************************
    always @(posedge c_in) begin

        if (IDELAY_TYPE == "VARIABLE" | IDELAY_TYPE == "VAR_LOADABLE" |ODELAY_TYPE == "VARIABLE" | ODELAY_TYPE == "VAR_LOADABLE") begin
            if (rst_in == 1'b1) begin
                case (ODELAY_TYPE)
                        "VARIABLE" : odelay_count = ODELAY_VALUE;
                        "VAR_LOADABLE" : odelay_count = CNTVALUEIN_INTEGER;
                endcase
                case (IDELAY_TYPE)
                        "VARIABLE" : idelay_count = IDELAY_VALUE;
                        "VAR_LOADABLE" : idelay_count = CNTVALUEIN_INTEGER;
                endcase
            end
            else if (rst_in == 1'b0 && ce_in == 1'b1) begin
                if (inc_in == 1'b1) begin
                    case (IDELAY_TYPE)
                        "VARIABLE" : begin
                                        if (idelay_count < MAX_DELAY_COUNT)
                                        idelay_count = idelay_count + 1;
                                        else if (idelay_count == MAX_DELAY_COUNT)
                                        idelay_count = MIN_DELAY_COUNT;
                                     end
                        "VAR_LOADABLE" : begin
                                        if (idelay_count < MAX_DELAY_COUNT)
                                        idelay_count = idelay_count + 1;
                                        else if (idelay_count == MAX_DELAY_COUNT)
                                        idelay_count = MIN_DELAY_COUNT;
                                     end
                    endcase
                    case (ODELAY_TYPE)
                        "VARIABLE" : begin
                                        if (odelay_count < MAX_DELAY_COUNT)
                                        odelay_count = odelay_count + 1;
                                        else if (odelay_count == MAX_DELAY_COUNT)
                                        odelay_count = MIN_DELAY_COUNT;
                                     end
                        "VAR_LOADABLE" : begin
                                        if (odelay_count < MAX_DELAY_COUNT)
                                        odelay_count = odelay_count + 1;
                                        else if (odelay_count == MAX_DELAY_COUNT)
                                        odelay_count = MIN_DELAY_COUNT;
                                     end
                    endcase
                end
                else if (inc_in == 1'b0) begin
                    case (IDELAY_TYPE)
                        "VARIABLE" : begin
                                        if (idelay_count >  MIN_DELAY_COUNT)
                                        idelay_count = idelay_count - 1;
                                        else if (idelay_count == MIN_DELAY_COUNT)
                                        idelay_count = MAX_DELAY_COUNT;
                                     end
                        "VAR_LOADABLE" : begin
                                        if (idelay_count >  MIN_DELAY_COUNT)
                                        idelay_count = idelay_count - 1;
                                        else if (idelay_count == MIN_DELAY_COUNT)
                                        idelay_count = MAX_DELAY_COUNT;
                                     end
                    endcase
                    case (ODELAY_TYPE)
                        "VARIABLE" : begin
                                        if (odelay_count >  MIN_DELAY_COUNT)
                                        odelay_count = odelay_count - 1;
                                        else if (odelay_count == MIN_DELAY_COUNT)
                                        odelay_count = MAX_DELAY_COUNT;
                                     end
                        "VAR_LOADABLE" : begin
                                        if (odelay_count >  MIN_DELAY_COUNT)
                                        odelay_count = odelay_count - 1;
                                        else if (odelay_count == MIN_DELAY_COUNT)
                                        odelay_count = MAX_DELAY_COUNT;
                                     end
                    endcase
                end
            end
        end //
    end // always @ (posedge c_in)
  
    always @(cntvaluein_in or gsr_in) begin
                case (cntvaluein_in)
                        5'b00000 : assign CNTVALUEIN_INTEGER = 0;
                        5'b00001 : assign CNTVALUEIN_INTEGER = 1;
                        5'b00010 : assign CNTVALUEIN_INTEGER = 2;
                        5'b00011 : assign CNTVALUEIN_INTEGER = 3;
                        5'b00100 : assign CNTVALUEIN_INTEGER = 4;
                        5'b00101 : assign CNTVALUEIN_INTEGER = 5;
                        5'b00110 : assign CNTVALUEIN_INTEGER = 6;
                        5'b00111 : assign CNTVALUEIN_INTEGER = 7;
                        5'b01000 : assign CNTVALUEIN_INTEGER = 8;
                        5'b01001 : assign CNTVALUEIN_INTEGER = 9;
                        5'b01010 : assign CNTVALUEIN_INTEGER = 10;
                        5'b01011 : assign CNTVALUEIN_INTEGER = 11;
                        5'b01100 : assign CNTVALUEIN_INTEGER = 12;
                        5'b01101 : assign CNTVALUEIN_INTEGER = 13;
                        5'b01110 : assign CNTVALUEIN_INTEGER = 14;
                        5'b01111 : assign CNTVALUEIN_INTEGER = 15;
                        5'b10000 : assign CNTVALUEIN_INTEGER = 16;
                        5'b10001 : assign CNTVALUEIN_INTEGER = 17;
                        5'b10010 : assign CNTVALUEIN_INTEGER = 18;
                        5'b10011 : assign CNTVALUEIN_INTEGER = 19;
                        5'b10100 : assign CNTVALUEIN_INTEGER = 20;
                        5'b10101 : assign CNTVALUEIN_INTEGER = 21;
                        5'b10110 : assign CNTVALUEIN_INTEGER = 22;
                        5'b10111 : assign CNTVALUEIN_INTEGER = 23;
                        5'b11000 : assign CNTVALUEIN_INTEGER = 24;
                        5'b11001 : assign CNTVALUEIN_INTEGER = 25;
                        5'b11010 : assign CNTVALUEIN_INTEGER = 26;
                        5'b11011 : assign CNTVALUEIN_INTEGER = 27;
                        5'b11100 : assign CNTVALUEIN_INTEGER = 28;
                        5'b11101 : assign CNTVALUEIN_INTEGER = 29;
                        5'b11110 : assign CNTVALUEIN_INTEGER = 30;
                        5'b11111 : assign CNTVALUEIN_INTEGER = 31;
                endcase
    end

 
//*********************************************************
//*** SELECT IDATA signal
//*********************************************************

    always @(datain_in or idatain_in, odatain_in, t_in, clkin_in ) begin

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
            "CLKIN"  : begin
                         data_mux <= clkin_in;
                       end
            default : begin
                          $display("Attribute Syntax Error : The attribute DELAY_SRC on IODELAYE1 instance %m is set to %s.  Legal values for this attribute are I, O, CLKIN, IO or DATAIN", DELAY_SRC);
                          $finish;
                      end

        endcase // case(DELAY_SRC)

    end // always @ (data_in or idatain_in or odatain_in or t_in, clkin_in)


//*********************************************************
//*** DELAY IDATA signal
//*********************************************************
//    assign #(DELAY_D + INIT_DELAY) delay_chain_0 = data_mux;
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
              default:
                  assign tap_out = delay_chain_0;
           endcase
        end // DELAY_SRC = REST
   end // always @ (idelay_count, odelay_count, t_in)


    specify
        ( C => CNTVALUEOUT[0]) = (100, 100);
        ( C => CNTVALUEOUT[1]) = (100, 100);
        ( C => CNTVALUEOUT[2]) = (100, 100);
        ( C => CNTVALUEOUT[3]) = (100, 100);
        ( C => CNTVALUEOUT[4]) = (100, 100);
        ( C => DATAOUT) = (0, 0);
        ( CINVCTRL => CNTVALUEOUT[0]) = (0, 0);
        ( CINVCTRL => CNTVALUEOUT[1]) = (0, 0);
        ( CINVCTRL => CNTVALUEOUT[2]) = (0, 0);
        ( CINVCTRL => CNTVALUEOUT[3]) = (0, 0);
        ( CINVCTRL => CNTVALUEOUT[4]) = (0, 0);
        ( CINVCTRL => DATAOUT) = (0, 0);
        ( CLKIN => DATAOUT) = (0, 0);
        ( DATAIN => DATAOUT) = (0, 0);
        ( IDATAIN => DATAOUT) = (0, 0);
        ( ODATAIN => DATAOUT) = (0, 0);
        ( T => CNTVALUEOUT[0]) = (0, 0);
        ( T => CNTVALUEOUT[1]) = (0, 0);
        ( T => CNTVALUEOUT[2]) = (0, 0);
        ( T => CNTVALUEOUT[3]) = (0, 0);
        ( T => CNTVALUEOUT[4]) = (0, 0);
        ( T => DATAOUT) = (0, 0);

        specparam PATHPULSE$ = 1;
    endspecify

endmodule // IODELAYE1

