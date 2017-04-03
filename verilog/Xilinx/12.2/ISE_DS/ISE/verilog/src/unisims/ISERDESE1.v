///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2007 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Source Synchronous Input Deserializer for Virtex6
// /___/   /\     Filename : ISERDESE1.v
// \   \  /  \    Timestamp : Tue Aug 19 13:56:05 PDT 2008
//  \___\/\___\
//
// Revision:
//    08/19/08 - Initial version.
//    02/06/09 - CR 507371 removed OCLKB 
//    02/18/09 - CR 509177 DYNCLKSEL inverts the clock when it is low
//    04/15/09 - CR 518368 Removed DYNOCLKSEL pin and DYN_OCLK_INV_EN attribute
//    04/27/09 - CR 519644 Removed DYN_OCLK_INV_EN attribute
//    06/04/09 - CR 523086 When ((DYN_CLK_INV_EN = TRUE) and (DYNCLKSEL = '0')), swap  CLK and CLKB signals
//    10/09/09 - CR 535789 incorrect assignment to O port
//    12/15/09 - CR 541284/541285 Enabled OverSampling
//    01/18/10 - CR 545277 Updated CLK to Q timing due OverSampling
//    02/23/10 - CR 550912  Fixed OVERSAMPLE issues
// End Revision

`timescale  1 ps / 1 ps

module ISERDESE1 (O, Q1, Q2, Q3, Q4, Q5, Q6, SHIFTOUT1, SHIFTOUT2,
                  BITSLIP, CE1, CE2, CLK, CLKB, CLKDIV, D, DDLY, DYNCLKDIVSEL, DYNCLKSEL, OCLK, OFB, RST, SHIFTIN1, SHIFTIN2);




    parameter DATA_RATE = "DDR";
    parameter integer DATA_WIDTH = 4;
    parameter DYN_CLKDIV_INV_EN = "FALSE";
    parameter DYN_CLK_INV_EN = "FALSE";
    parameter INIT_Q1 = 1'b0;
    parameter INIT_Q2 = 1'b0;
    parameter INIT_Q3 = 1'b0;
    parameter INIT_Q4 = 1'b0;
    parameter INTERFACE_TYPE = "MEMORY";
    parameter integer NUM_CE = 2;
    parameter IOBDELAY = "NONE";
    parameter OFB_USED = "FALSE";
    parameter SERDES_MODE = "MASTER";
    parameter SRVAL_Q1 = 1'b0;
    parameter SRVAL_Q2 = 1'b0;
    parameter SRVAL_Q3 = 1'b0;
    parameter SRVAL_Q4 = 1'b0;


//-------------------------------------------------------------
//   Outputs:
//-------------------------------------------------------------
//      Q1: q1 output
//      Q2: q2 output
//      Q3: q3 output
//      Q4: q4 output
//      Q5: q5 output
//      Q6: q6 output
//      SHIFTOUT1: carry out data
//      SHIFTOUT2: carry out data
//
//-------------------------------------------------------------
//   Inputs:
//-------------------------------------------------------------
//      D: Input from pad
//      CE1: main clock enable input
//      CE2: 2nd clock enable input for serdes
//      BITSLIP: Manage bitslip controller
//      SHIFTIN1: Carry in data
//      SHIFTIN2: Carry in data
//      CLK: High speed clock or strobe
//      CLKB: High speed inverted clock or strobe
//              Primary use is QDR
//      CLKDIV: Divided clock from H clock row or OCLKDIV for memory applications
//      OCLK: High speed output clock
//      OCLKB: High speed inverted output clock
//               Primary use is oversampling
//      RST: Set/Reset control.
//      CLKDIV: Low speed clock to drive counter for delay element
//
//      DYNCLKSEL: Dynamically change polarity of CLK
//      DYNCLKDIVSEL: Dynamically change polarity of CLKDIV
//      DYNOCLKSEL: Dynamically change polarity of OCLK
//      OFB: Feedback input from the OQ portion of the output
//
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
    input CLKB;
    input CLKDIV;
    input D;
    input DDLY;
    input DYNCLKDIVSEL;
    input DYNCLKSEL;
    input OCLK;
    input OFB;
    input RST;
    input SHIFTIN1;
    input SHIFTIN2;


//
    wire [1:0]   SRTYPE, DDR_CLK_EDGE;
    wire SERDES;
    wire TFB;
// CR 541284    wire OVERSAMPLE, RANK12_DLY, RANK23_DLY;
    wire RANK12_DLY, RANK23_DLY;
    wire D_EMU;
    assign SRTYPE = 2'b00;
    assign SERDES = 1'b1;
    assign DDR_CLK_EDGE = 2'b11;
    assign TFB = 1'b0;
//  CR 541284 assign OVERSAMPLE = 1'b0;
    reg OVERSAMPLE = 1'b0;
    assign RANK12_DLY = 1'b0;
    assign RANK23_DLY = 1'b0;
    assign D_EMU = 1'b0;

// Output signals 
    reg o_out = 0, q1_out = 0, q2_out = 0, q3_out = 0, q4_out = 0, q5_out = 0, q6_out = 0;
    wire shiftout1_out, shiftout2_out;

    reg q1rnk1, q2nrnk1, q1prnk1, q2prnk1, q3rnk1;
    reg q4rnk1, q5rnk1, q6rnk1, q6prnk1;
    reg q1rnk2, q2rnk2, q3rnk2, q4rnk2, q5rnk2, q6rnk2;
    reg q1rnk3, q2rnk3, q3rnk3, q4rnk3, q5rnk3, q6rnk3;

    reg dataq3rnk1, dataq4rnk1, dataq5rnk1, dataq6rnk1;
    reg dataq1rnk2, dataq2rnk2, dataq3rnk2;
    reg dataq4rnk2, dataq5rnk2, dataq6rnk2; 

    reg memmux, q2pmux;

    reg clkmux1, clkmux2, clkmux3, clkmux4;

    reg clkoimux, oclkoimux, clkdivoimux;
    reg clkboimux, oclkboimux = 0, clkdivboimux;


    reg clkdivmux1, clkdivmux2;

    reg ddr3clkmux;

    reg rank3clkmux;

    reg c23, c45, c67;

    reg [1:0] sel;

    wire [3:0] selrnk3;

    wire [4:0] cntr;

    wire [1:0] sel1;

    wire [3:0] bsmux;

    wire ice;

    wire muxc;

    wire clkdiv_int;

    wire [1:0] clkdivsel;

    wire bitslip_en;

    wire int_typ;

    wire [1:0] os_en;

    wire [2:0] rank2_cksel;

    reg data_in;
    reg o_out_pre_fb = 0, o_delay_pre_fb = 0;


    reg data_rate_int;
    reg [3:0] data_width_int;
    reg dyn_clkdiv_inv_int, dyn_clk_inv_int, dyn_oclk_inv_int;
    reg ofb_used_int, num_ce_int, serdes_mode_int; 
    reg [1:0] interface_type_int;

    
    
// Other signals
    tri0  GSR = glbl.GSR;

    assign bitslip_in      = BITSLIP;  
    assign ce1_in          = CE1;  
    assign ce2_in          = CE2;  
    assign clk_in          = CLK;  
    assign clkb_in         = CLKB;  
    assign clkdiv_in       = CLKDIV;  
    assign d_in            = D;  
    assign ddly_in         = DDLY;  
    assign dynclkdivsel_in = DYNCLKDIVSEL;  
    assign dynclksel_in    = DYNCLKSEL;  
// CR 518368
//  assign dynoclksel_in   = DYNOCLKSEL;  
    assign oclk_in         = OCLK;  
// CR 507371
//  assign oclkb_in        = OCLKB;  
    assign ofb_in          = OFB;  
    assign rst_in          = RST;  
    assign shiftin1_in     = SHIFTIN1;  
    assign shiftin2_in     = SHIFTIN2;  


    task INTERFACE_TYPE_msg;
         begin
            $display("DRC  Warning : The combination of INTERFACE_TYPE, DATA_RATE and DATA_WIDTH values on instance %m is not recommended.\n");
            $display("The current settings are : INTERFACE_TYPE = %s, DATA_RATE = %s and DATA_WIDTH = %d\n", INTERFACE_TYPE, DATA_RATE, DATA_WIDTH);
            $display("The recommended combinations of values are :\n");
            $display("NETWORKING SDR 2, 3, 4, 5, 6, 7, 8\n");
            $display("NETWORKING DDR 4, 6, 8, 10\n");
            $display("MEMORY SDR None\n");
            $display("MEMORY DDR 4\n");
         end
    endtask // INTERFACE_TYPE_msg

// CR 541284
    task OVERSAMPLE_DDR_SDR_msg;
         begin
            $display("DRC  Warning : The combination of INTERFACE_TYPE, DATA_RATE and DATA_WIDTH values on instance %m is not recommended.\n");
            $display("The current settings are : INTERFACE_TYPE = %s, DATA_RATE = %s and DATA_WIDTH = %d\n", INTERFACE_TYPE, DATA_RATE, DATA_WIDTH);
            $display("The recommended combinations of values are :\n");
            $display("OVERSAMPLE DDR 4\n");
         end
    endtask // OVERSAMPLE_DDR_SDR_msg

    initial begin
//-------------------------------------------------
//----- DATA_RATE check
//-------------------------------------------------
        case (DATA_RATE)
            "SDR" : data_rate_int <= 1'b1;
            "DDR" : data_rate_int <= 1'b0;
            default : begin
                          $display("Attribute Syntax Error : The attribute DATA_RATE on ISERDESE1 instance %m is set to %s.  Legal values for this attribute are SDR or DDR", DATA_RATE);
                          $finish;
                      end
        endcase // case(DATA_RATE)

//-------------------------------------------------
//----- DATA_WIDTH check
//-------------------------------------------------
        case (DATA_WIDTH)

            2, 3, 4, 5, 6, 7, 8, 10 : data_width_int = DATA_WIDTH[3:0];
            default : begin
                          $display("Attribute Syntax Error : The attribute DATA_WIDTH on ISERDESE1 instance %m is set to %d.  Legal values for this attribute are 2, 3, 4, 5, 6, 7, 8, or 10", DATA_WIDTH);
                          $finish;
                      end
        endcase // case(DATA_WIDTH)


//-------------------------------------------------
//----- DYN_CLKDIV_INV_EN check
//-------------------------------------------------
        case (DYN_CLKDIV_INV_EN)

            "FALSE" : dyn_clkdiv_inv_int <= 1'b0;
            "TRUE"  : dyn_clkdiv_inv_int <= 1'b1;
            default : begin
                          $display("Attribute Syntax Error : The attribute DYN_CLKDIV_INV_EN on ISERDESE1 instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE", DYN_CLKDIV_INV_EN);
                          $finish;
                      end

        endcase // case(DYN_CLKDIV_INV_EN)

//-------------------------------------------------
//----- DYN_CLK_INV_EN check
//-------------------------------------------------
        case (DYN_CLK_INV_EN)

            "FALSE" : dyn_clk_inv_int <= 1'b0;
            "TRUE"  : dyn_clk_inv_int <= 1'b1;
            default : begin
                          $display("Attribute Syntax Error : The attribute DYN_CLK_INV_EN on ISERDESE1 instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE", DYN_CLK_INV_EN);
                          $finish;
                      end

        endcase // case(DYN_CLK_INV_EN)

//-------------------------------------------------
//----- OFB_USED check
//-------------------------------------------------
        case (OFB_USED)

            "FALSE" : ofb_used_int <= 1'b0;
            "TRUE"  : ofb_used_int <= 1'b1;
            default : begin
                          $display("Attribute Syntax Error : The attribute OFB_USED on ISERDESE1 instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE", OFB_USED);
                          $finish;
                      end

        endcase // case(OFB_USED)
//-------------------------------------------------
//----- NUM_CE check
//-------------------------------------------------
        case (NUM_CE)

            1 : num_ce_int <= 1'b0;
            2 : num_ce_int <= 1'b1;
            default : begin
                          $display("Attribute Syntax Error : The attribute NUM_CE on ISERDESE1 instance %m is set to %d.  Legal values for this attribute are 1 or 2", NUM_CE);
                          $finish;
                      end

        endcase // case(NUM_CE)


//-------------------------------------------------
//----- INTERFACE_TYPE check
//-------------------------------------------------
        case (INTERFACE_TYPE)
               "MEMORY" : begin
                        interface_type_int <= 2'b00; 
                        case(DATA_RATE)
                             "DDR" :
                                   case(DATA_WIDTH)
                                       4 : ;
                                       default :   INTERFACE_TYPE_msg;
                                   endcase // DATA_WIDTH
                             default :  INTERFACE_TYPE_msg;
                        endcase // DATA_RATE
               end
               "NETWORKING" : begin
                        interface_type_int <= 2'b01; 
                        case(DATA_RATE)
                             "SDR" :
                                   case(DATA_WIDTH)
                                       2, 3, 4, 5, 6, 7, 8 : ;
                                       default :  INTERFACE_TYPE_msg;
                                   endcase // DATA_WIDTH
                             "DDR" :
                                   case(DATA_WIDTH)
                                       4, 6, 8, 10 : ;
                                       default :   INTERFACE_TYPE_msg;
                                   endcase // DATA_WIDTH
                             default :  ;
                        endcase // DATA_RATE
               end  
               "MEMORY_QDR" :
                        interface_type_int <= 2'b10; 
               "MEMORY_DDR3" :
                        interface_type_int <= 2'b11; 
// CR 541284
              "OVERSAMPLE" : begin
                        OVERSAMPLE <= 1'b1;
                        interface_type_int <= 2'b01;
                        case(DATA_RATE)
                             "SDR" : OVERSAMPLE_DDR_SDR_msg;
                             "DDR" :
                                   case(DATA_WIDTH)
                                       4 : ;
                                       default :   OVERSAMPLE_DDR_SDR_msg;
                                   endcase // DATA_WIDTH
                             default :  ;
                        endcase // DATA_RATE
               end

               default : begin
                          $display("Attribute Syntax Error : The attribute INTERFACE_TYPE on ISERDESE1 instance %m is set to %s.  Legal values for this attribute are MEMORY, NETWORKING, MEMORY_QDR, MEMORY_DDR3 or OVERSAMPLE", INTERFACE_TYPE);
                          $finish;
                         end
        endcase // INTERFACE_TYPE

//-------------------------------------------------
//----- SERDES_MODE check
//-------------------------------------------------
        case (SERDES_MODE)
                "MASTER" : serdes_mode_int <= 1'b0;
                "SLAVE"  : serdes_mode_int <= 1'b1;
                default  : begin
                          $display("Attribute Syntax Error : The attribute SERDES_MODE on ISERDESE1 instance %m is set to %s.  Legal values for this attribute are MASTER or SLAVE", SERDES_MODE);
                          $finish;
                          end
         endcase // case(SERDES_MODE)

//-------------------------------------------------
    end  // initial begin

//-------------------------------------------------
assign int_typ = interface_type_int[1] | interface_type_int[0];

assign bitslip_en = interface_type_int[0];

// CR 541284
assign os_en = {int_typ, OVERSAMPLE};  // {int_typ, OVERSAMPLE};    
 
assign sel1 = {serdes_mode_int, data_rate_int}; // {SERDES_MODE,DATA_RATE};

// CR 541284
assign rank2_cksel = {interface_type_int, OVERSAMPLE}; // {interface_type_int, OVERSAMPLE};

assign selrnk3 = {1'b1, bitslip_en, 2'b11}; // {SERDES,bitslip_en, DDR_CLK_EDGE};

// CR 541284
assign bsmux = {bitslip_en, data_rate_int, muxc, OVERSAMPLE}; // {bitslip_en,DATA_RATE,muxc, OVERSAMPLE};

assign cntr = {data_rate_int, data_width_int}; // {DATA_RATE,DATA_WIDTH};

// Parameter declarations for delays

    localparam ffinp = 300;
    localparam mxinp1 = 60;
    localparam mxinp2 = 120;

// Delay parameters
    localparam ht0 = 800;
    localparam fftco = 300;
    localparam mxdly = 60;
    localparam cnstdly = 80;


// GSR

    always @(GSR) begin
       if (GSR == 1'b1) begin
           assign q1rnk1  = INIT_Q1;
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
           assign ddr3clkmux = 1'b1;
       end
       else if (GSR == 1'b0) begin

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
           deassign ddr3clkmux;

       end // if (GSR == 1'b0)
    end // always @ (GSR)

//-------------------------------------------------
//   Input to ISERDES
//-------------------------------------------------

    always @(d_in or ddly_in) begin

        case (IOBDELAY)

            "NONE" : begin
                         o_out_pre_fb   <= d_in;
                         o_delay_pre_fb <= d_in;

                     end
            "IBUF" : begin
                         o_out_pre_fb   <= ddly_in;
                         o_delay_pre_fb <= d_in;
                     end
            "IFD"  : begin
                         o_out_pre_fb <= d_in;
                         o_delay_pre_fb <= ddly_in;
                     end
            "BOTH" : begin
                         o_out_pre_fb   <= ddly_in;
                         o_delay_pre_fb <= ddly_in;
                     end
            default : begin
                          $display("Attribute Syntax Error : The attribute IOBDELAY on ISERDESE1 instance %m is set to %s.  Legal values for this attribute are NONE, IBUF, IFD or BOTH", IOBDELAY);
                          $finish;
                      end

        endcase // case(IOBDELAY)

    end // always @ (d_in or ddly_in)

    generate
      case (OFB_USED)
         "TRUE"  : always @(ofb_in)
                      begin
                         o_out   <= ofb_in;
                         data_in <= ofb_in;
                       end
         "FALSE" : begin
                      always @(o_out_pre_fb)    o_out   <= o_out_pre_fb;
                      always @(o_delay_pre_fb)  data_in <= o_delay_pre_fb;
                   end
      endcase
    endgenerate

//------------------------------------------------------
//   High Speed  Clock Generation and Polarity Control
//------------------------------------------------------

// Optional inverter for clk
    generate
      case (DYN_CLK_INV_EN)
         "FALSE" : always @(clk_in)  clkoimux <= clk_in;
         "TRUE"  : 
// CR 523086
                   always @ (dynclksel_in or clk_in or clkb_in) begin 
                      case (dynclksel_in)
                         1'b0: clkoimux <= clkb_in;
                         1'b1: clkoimux <= clk_in;
                      endcase
                   end
      endcase
    endgenerate

// Optional inverter for clkb
    generate
      case (DYN_CLK_INV_EN)
         "FALSE" : always @(clkb_in)  clkboimux <= clkb_in;
         "TRUE"  : 
// CR 523086
                   always @ (dynclksel_in or clkb_in or clk_in) begin 
                      case (dynclksel_in)
                         1'b0: clkboimux <= clk_in;
                         1'b1: clkboimux <= clkb_in;
                      endcase
                   end
      endcase
    endgenerate

// CR 518368
// Optional inverter for oclk
/*
    generate
      case (DYN_OCLK_INV_EN)
         "FALSE" : always @(oclk_in)  oclkoimux <= oclk_in;
         "TRUE"  : 
                   always @ (dynoclksel_in or oclk_in) begin 
                      case (dynoclksel_in)
                         1'b0: oclkoimux <= oclk_in;
                         1'b1: oclkoimux <= ~oclk_in;
                      endcase
                   end
      endcase
    endgenerate
*/

  always @(oclk_in)  oclkoimux <= oclk_in;

//CR 507371
// Optional inverter for oclkb
/*
    generate
      case (DYN_OCLK_INV_EN)
         "FALSE" : always @(oclkb_in)  oclkboimux <= oclkb_in;
         "TRUE"  : 
                   always @ (dynoclksel_in or oclkb_in) begin 
                      case (dynoclksel_in)
                         1'b0: oclkboimux <= oclkb_in;
                         1'b1: oclkboimux <= ~oclkb_in;
                      endcase
                   end
      endcase
    endgenerate
*/

// Optional inverter for clkdiv
    generate
      case (DYN_CLKDIV_INV_EN)
         "FALSE" : always @(clkdiv_in)  clkdivoimux <= clkdiv_in;
         "TRUE"  : 
                   always @ (dynclkdivsel_in or clkdiv_in) begin 
                      case (dynclkdivsel_in)
                         1'b0: clkdivoimux <= clkdiv_in;
                         1'b1: clkdivoimux <= ~clkdiv_in;
                      endcase
                   end
      endcase
    endgenerate

// clkmux for 2nd flop in rank1
    generate
      case (INTERFACE_TYPE)
         "MEMORY"      : always @(clkboimux)  clkmux2 <= clkboimux;
         "NETWORKING"  : always @(clkboimux)  clkmux2 <= clkboimux;
         "MEMORY_QDR"  : always @(clkboimux)  clkmux2 <= clkboimux;
         "MEMORY_DDR3" : always @(clkboimux)  clkmux2 <= clkboimux;
         "OVERSAMPLE" : always @(clkboimux)  clkmux2 <= clkboimux; // need for OVERSAMPLE CR fix 02/23/10
      endcase
    endgenerate

// clkmux for 3rd flop in rank1
    always @ (os_en or oclkoimux or clkoimux) begin
      case (os_en)
         2'b00: clkmux3 <= oclkoimux;
         2'b01: clkmux3 <= oclkoimux;
         2'b10: clkmux3 <= clkoimux;
         2'b11: clkmux3 <= oclkoimux;
      endcase
    end

//clkmux for 4th flop in rank1
    always @ (os_en or oclkoimux or clkoimux or oclkboimux) begin
      case(os_en)
         2'b00: clkmux4 <= ~oclkoimux;
         2'b01: clkmux4 <= ~oclkoimux;
         2'b10: clkmux4 <= clkoimux;
         2'b11: clkmux4 <= ~oclkoimux;  // changed from grounded oclkboimux to ~oclkoimux -- need for OVERSAMPLE CR fix 02/23/10
         default: clkmux4 <= ~oclkoimux;
      endcase
    end

// Rest of clock muxs in first rank
    always @ (int_typ or oclkoimux or clkoimux) begin
      case (int_typ)
         1'b0: memmux <= # mxinp1 oclkoimux;
         1'b1: memmux <= # mxinp1 clkoimux;
         default: memmux <= # mxinp1 oclkoimux;
      endcase
    end

//-------------------------------------------------
//   1st rank of registers -- Synchronous Operation
//-------------------------------------------------
//  Uses the positive edge of CLK
//  This includes the 1st, 6th, 7th and 8th flops in rank 1
//  These flops are designated as q1rnk1, q5rnk1, q6rnk1
//  and q6prnk1. q1rnk1 is full featured. 
//  q5rnk1, q6rnk1 and q6prnk1 are not. 

    always @ (posedge clkoimux) begin
       if(rst_in == 1'b1) begin 
            q1rnk1  <=  # ffinp SRVAL_Q1;
       end 
       else if (ice == 1'b1) begin
            q1rnk1  <= # ffinp data_in;
       end

       if(rst_in == 1'b1) begin 
            q5rnk1  <= # ffinp 1'b0;
            q6rnk1  <= # ffinp 1'b0;
            q6prnk1 <= # ffinp 1'b0;
       end 
       else  begin
            q5rnk1  <= # ffinp dataq5rnk1;
            q6rnk1  <= # ffinp dataq6rnk1;
            q6prnk1 <= # ffinp q6rnk1;
       end
    end // always @ (posedge clkoimux)

// 2nd flop in rank 1, designated q2nrnk1, that is full featured
//      and operates only on the negative edge of CLK or positive
//      edge of CLKB

    always @ (posedge clkmux2) begin
       if(rst_in == 1'b1)
            q2nrnk1  <=  # ffinp SRVAL_Q2;
       else if (ice == 1'b1)
            q2nrnk1  <= # ffinp data_in;
    end // always @ (posedge clkmux2)

// 3rd, 4th, 5th and 6th flops in rank1
// The 3rd and 4th flops are full featured while
// The 5th and 6th flops only have reset.  The flops are
// designated as q1prnk1, q2prnk1, q3rnk1 and q4rnk1.
// These 4 flops can be driven from CLK or OCLK.  This
// function is implemented by the clk mux called
// "memmux".  Flops q1prnk1, q3rnk1 and q4rnk1 are
// driven of the positive edge of memmux.  Flop q2prnk1
// is further driven by the optional inverter mux named
// "q2pmux" that allows it to be driven off either the
// positive or negative edge of memmux.
//

    always @ (posedge clkmux3) begin
       if(rst_in == 1'b1)
            q1prnk1 <=  # ffinp SRVAL_Q3;
       else if (ice == 1'b1)
//            q1prnk1  <= # ffinp q1rnk1;
             q1prnk1  <= # ffinp (OVERSAMPLE? data_in : q1rnk1);
    end // always @ (posedge clkmux3)

// 5th and 6th flops in rank 1 which are not full featured but can be clocked
//  by either clk or oclk

    always @ (posedge memmux) begin
       if(rst_in == 1'b1) begin
            q3rnk1 <= # ffinp 1'b0;
            q4rnk1 <= # ffinp 1'b0;
       end  
       else begin
            q3rnk1 <= # ffinp dataq3rnk1;
            q4rnk1 <= # ffinp dataq4rnk1;
       end
    end // always @ (posedge clkmux2)

// 4th flop in rank 1 (q2prnk1).  This is a full featured flop
// that for memory is clocked on the negative edge of OCLK
// and for networking is clocked on the positive edge of CLK


    always @ (posedge clkmux4) begin
       if(rst_in == 1'b1)
            q2prnk1 <=  # ffinp SRVAL_Q4;
       else if (ice == 1'b1)
//            q2prnk1  <= # ffinp q2nrnk1;
             q2prnk1  <= # ffinp (OVERSAMPLE? data_in : q2nrnk1);
    end // always @ (posedge clkmux4)

//-------------------------------------------------
// Mux elements for the 1st rank
//-------------------------------------------------

// data input mux for q3, q4, q5 and q6

    always @ (sel1 or q1prnk1 or shiftin1_in or shiftin2_in) begin
        case (sel1)
           2'b00: dataq3rnk1 <= # mxinp1 q1prnk1;
           2'b01: dataq3rnk1 <= # mxinp1 q1prnk1;
           2'b10: dataq3rnk1 <= # mxinp1 shiftin2_in;
           2'b11: dataq3rnk1 <= # mxinp1 shiftin1_in;
           default: dataq3rnk1 <= # mxinp1 q1prnk1;
        endcase // case(sel1)
    end // always @ (sel1 or q1prnk1 or shiftin1_in or shiftin2_in)

    always @ (sel1 or q2prnk1 or q3rnk1 or shiftin1_in) begin
        case (sel1)
           2'b00: dataq4rnk1 <= # mxinp1 q2prnk1;
           2'b01: dataq4rnk1 <= # mxinp1 q3rnk1;
           2'b10: dataq4rnk1 <= # mxinp1 shiftin1_in;
           2'b11: dataq4rnk1 <= # mxinp1 q3rnk1;
           default: dataq4rnk1 <= # mxinp1 q2prnk1;
        endcase // case(sel1)
    end // always @ (sel1 or q2prnk1 or q3rnk1 or shiftin1_in)

    always @ (data_rate_int or q3rnk1 or q4rnk1) begin
        case (data_rate_int)
           1'b0: dataq5rnk1 <= # mxinp1 q3rnk1;
           1'b1: dataq5rnk1 <= # mxinp1 q4rnk1;
           default: dataq5rnk1 <= # mxinp1 q4rnk1;
        endcase // case(data_rate_int)
    end // always @ (data_rate_int or q3rnk1 or q4rnk1)

    always @ (data_rate_int or q4rnk1 or q5rnk1) begin
        case (data_rate_int)
           1'b0: dataq6rnk1 <= # mxinp1 q4rnk1;
           1'b1: dataq6rnk1 <= # mxinp1 q5rnk1;
           default: dataq6rnk1 <= # mxinp1 q5rnk1;
        endcase // case(data_rate_int)
    end // always @ (data_rate_int or q4rnk1 or q5rnk1)

//-------------------------------------------------
//   2nd rank of registers -- Synchronous Operation
//-------------------------------------------------


// DDR3 Divide By 2 CKT

    always @ (negedge clkoimux) begin
        if(rst_in)
           ddr3clkmux <= 1'b0;
        else if (INTERFACE_TYPE == "MEMORY_DDR3")
               ddr3clkmux <= ~ddr3clkmux;
             else
               ddr3clkmux <= ddr3clkmux;
    end //  always @ (negedge clkoimux)

// clkdivmuxs to pass clkdiv_int or CLKDIV to rank 2
    always @ (rank2_cksel or clkdiv_int or clkdivoimux or clkoimux or cntr) begin
        case (rank2_cksel)
            3'b000: clkdivmux1 <= # mxinp1 clkdivoimux;
            3'b010: begin 
                        case (cntr)
                                5'b00100: clkdivmux1 <= # mxinp1 ~clkdiv_int;
                                5'b10010: clkdivmux1 <= # mxinp1 ~clkdiv_int;
                                default: clkdivmux1 <= # mxinp1 clkdiv_int;
                        endcase
                    end
            3'b100: clkdivmux1 <= # mxinp1 clkdivoimux;
            3'b110: #1 clkdivmux1 <= # mxinp1 ddr3clkmux;
            3'b011: clkdivmux1 <= # mxinp1 clkoimux;
//            default: $display("INTERFACE_TYPE %b and OVERSAMPLE %b at %t is an illegal value", INTERFACE_TYPE, OVERSAMPLE, $time);
        endcase // case (rank2_cksel)
    end //  always @ (rank2_cksel or clkdiv_int or clkdivoimux or clkoimux or cntr)


// clkdivmuxs to pass clkdiv_int or CLKDIV to rank 2
    always @ (rank2_cksel or clkdiv_int or clkdivoimux or clkoimux or oclkoimux or cntr) begin 
        case (rank2_cksel)
           3'b000: clkdivmux2 <= # mxinp1 clkdivoimux;
           3'b010: begin
                        case (cntr)
                                5'b00100: clkdivmux2 <= # mxinp1 ~clkdiv_int;
                                5'b10010: clkdivmux2 <= # mxinp1 ~clkdiv_int;
                                default:  clkdivmux2 <= # mxinp1 clkdiv_int;
                        endcase
                   end
           3'b100: clkdivmux2 <= # mxinp1 clkdivoimux;
           3'b110: #1 clkdivmux2 <= #mxinp1 ddr3clkmux;
           3'b011: clkdivmux2 <= # mxinp1 oclkoimux;
//           default: $display("INTERFACE_TYPE %b and OVERSAMPLE %b at %t is an illegal value", INTERFACE_TYPE, OVERSAMPLE, $time);
        endcase // case (rank2_cksel)
    end // always @ (rank2_cksel or clkdiv_int or clkdivoimux or clkoimux) 

// Synchronous Operation
    always @ (posedge clkdivmux1) begin
       if(rst_in == 1'b1) begin
            q1rnk2 <= # ffinp 1'b0;
            q3rnk2 <= # ffinp 1'b0;
            q5rnk2 <= # ffinp 1'b0;
            q6rnk2 <= # ffinp 1'b0;
       end  
       else begin
            q1rnk2 <= # ffinp dataq1rnk2;
            q3rnk2 <= # ffinp dataq3rnk2;
            q5rnk2 <= # ffinp dataq5rnk2;
            q6rnk2 <= # ffinp dataq6rnk2;
       end
    end // always @ (posedge clkdivmux1)


    always @ (posedge clkdivmux2) begin
       if(rst_in == 1'b1) begin
            q2rnk2 <= # ffinp 1'b0;
            q4rnk2 <= # ffinp 1'b0;
       end  
       else begin
            q2rnk2 <= # ffinp dataq2rnk2;
            q4rnk2 <= # ffinp dataq4rnk2;
       end
    end // always @ (posedge clkdivmux2)


// Data mux for 2nd rank of flops
// Delay for mux set to 120

    always @ (bsmux or q1rnk1 or q1prnk1 or q2prnk1) begin
        casex (bsmux)
           4'b00X0: dataq1rnk2 <= # mxinp2 q2prnk1;
           4'b1000: dataq1rnk2 <= # mxinp2 q2prnk1;
           4'b1010: dataq1rnk2 <= # mxinp2 q1prnk1;
           4'bX1X0: dataq1rnk2 <= # mxinp2 q1rnk1;
           4'bXXX1: dataq1rnk2 <= # mxinp2 q1rnk1;
           default: dataq1rnk2 <= # mxinp2 q2prnk1;
        endcase // casex (bsmux)
    end // always @ (bsmux or q1rnk1 or q1prnk1 or q2prnk1)

    always @ (bsmux or q1prnk1 or q4rnk1 or q2nrnk1) begin
        casex (bsmux)
           4'b00X0: dataq2rnk2 <= # mxinp2 q1prnk1;
           4'b1000: dataq2rnk2 <= # mxinp2 q1prnk1;
           4'b1010: dataq2rnk2 <= # mxinp2 q4rnk1;
           4'bX1X0: dataq2rnk2 <= # mxinp2 q1prnk1;
           4'bXXX1: dataq2rnk2 <= # mxinp2 q2nrnk1;
           default: dataq2rnk2 <= # mxinp2 q1prnk1;
        endcase // casex (bsmux)
    end // always @ (bsmux or q1prnk1 or q4rnk1 or q2nrnk1)

    always @ (bsmux or q3rnk1 or q4rnk1 or q1prnk1) begin 
        casex (bsmux)
           4'b00X0: dataq3rnk2 <= # mxinp2 q4rnk1;
           4'b1000: dataq3rnk2 <= # mxinp2 q4rnk1;
           4'b1010: dataq3rnk2 <= # mxinp2 q3rnk1;
           4'bX1X0: dataq3rnk2 <= # mxinp2 q3rnk1;
           4'bXXX1: dataq3rnk2 <= # mxinp2 q1prnk1;
           default: dataq3rnk2 <= # mxinp2 q4rnk1;
        endcase // casex (bsmux)
    end // always @ (bsmux or q3rnk1 or q4rnk1 or q1prnk1)

    always @ (bsmux or q3rnk1 or q4rnk1 or q6rnk1 or q2prnk1) begin
        casex (bsmux)
           4'b00X0: dataq4rnk2 <= # mxinp2 q3rnk1;
           4'b1000: dataq4rnk2 <= # mxinp2 q3rnk1;
           4'b1010: dataq4rnk2 <= # mxinp2 q6rnk1;
           4'bX1X0: dataq4rnk2 <= # mxinp2 q4rnk1;
           4'bXXX1: dataq4rnk2 <= # mxinp2 q2prnk1;
           default: dataq4rnk2 <= # mxinp2 q3rnk1;
        endcase // casex (bsmux)
    end // always @ (bsmux or q3rnk1 or q4rnk1 or q6rnk1 or q2prnk1)

    always @ (bsmux or q5rnk1 or q6rnk1) begin
        casex (bsmux)
           4'b00X0: dataq5rnk2 <= # mxinp2 q6rnk1;
           4'b1000: dataq5rnk2 <= # mxinp2 q6rnk1;
           4'b1010: dataq5rnk2 <= # mxinp2 q5rnk1;
           4'bX1X0: dataq5rnk2 <= # mxinp2 q5rnk1;
           default: dataq5rnk2 <= # mxinp2 q6rnk1;
        endcase // casex (bsmux)
    end // always @ (bsmux or q5rnk1 or q6rnk1)

    always @ (bsmux or q5rnk1 or q6rnk1 or q6prnk1) begin
        casex (bsmux)
           4'b00X0: dataq6rnk2 <= # mxinp2 q5rnk1;
           4'b1000: dataq6rnk2 <= # mxinp2 q5rnk1;
           4'b1010: dataq6rnk2 <= # mxinp2 q6prnk1;
           4'bX1X0: dataq6rnk2 <= # mxinp2 q6rnk1;
           default: dataq6rnk2 <= # mxinp2 q5rnk1;
        endcase // casex (bsmux)
    end // always @ (bsmux or q5rnk1 or q6rnk1 or q6prnk1)



//-------------------------------------------------
//   3rd rank of registers -- Synchronous Operation
//-------------------------------------------------


// clkdivmuxs to pass CLK or CLKDIV to rank 3
    always @ (OVERSAMPLE or clkdivoimux or clkoimux) begin
        case (OVERSAMPLE)
           1'b0: rank3clkmux <= # mxinp1 clkdivoimux;
           1'b1: rank3clkmux <= # mxinp1 clkoimux;
           default: rank3clkmux <= # mxinp1 clkdivoimux;
        endcase // case (OVERSAMPLE)
    end // always @ (OVERSAMPLE or clkdivoimux or clkoimux)

// Synchronous Operation

    always @ (posedge rank3clkmux) begin
       if(rst_in == 1'b1) begin
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
    end // always @ (posedge rank3clkmux)

//-------------------------------------------------
//   Outputs
//-------------------------------------------------

    assign shiftout1_out = q6rnk1;
    assign shiftout2_out = q5rnk1;

    always @ (selrnk3 or q1rnk1 or q1prnk1 or q1rnk2 or q1rnk3) begin
        casex (selrnk3)
           4'b0X00: q1_out <= # mxinp1 q1prnk1;
           4'b0X01: q1_out <= # mxinp1 q1rnk1;
           4'b0X10: q1_out <= # mxinp1 q1rnk1;
           4'b10XX: q1_out <= # mxinp1 q1rnk2;
           4'b11XX: q1_out <= # mxinp1 q1rnk3;
           default: q1_out <= # mxinp1 q1rnk2;
        endcase
    end

    always @ (selrnk3 or q2nrnk1 or q2prnk1 or q2rnk2 or q2rnk3) begin
        casex (selrnk3)
           4'b0X00: q2_out <= # mxinp1 q2prnk1;
           4'b0X01: q2_out <= # mxinp1 q2prnk1;
           4'b0X10: q2_out <= # mxinp1 q2nrnk1;
           4'b10XX: q2_out <= # mxinp1 q2rnk2;
           4'b11XX: q2_out <= # mxinp1 q2rnk3;
           default: q2_out <= # mxinp1 q2rnk2;
        endcase
    end

    always @ (bitslip_en or q3rnk2 or q3rnk3) begin
        case (bitslip_en)
           1'b0: q3_out <= # mxinp1 q3rnk2;
           1'b1: q3_out <= # mxinp1 q3rnk3;
           default: q3_out <= # mxinp1 q3rnk2;
        endcase
    end

    always @ (bitslip_en or q4rnk2 or q4rnk3) begin
        casex (bitslip_en)
           1'b0: q4_out <= # mxinp1 q4rnk2;
           1'b1: q4_out <= # mxinp1 q4rnk3;
           default: q4_out <= # mxinp1 q4rnk2;
        endcase
    end

    always @ (bitslip_en or q5rnk2 or q5rnk3) begin
        casex (bitslip_en)
           1'b0: q5_out <= # mxinp1 q5rnk2;
           1'b1: q5_out <= # mxinp1 q5rnk3;
           default: q5_out <= # mxinp1 q5rnk2;
        endcase
    end

    always @ (bitslip_en or q6rnk2 or q6rnk3) begin
        casex (bitslip_en)
           1'b0: q6_out <= # mxinp1 q6rnk2;
           1'b1: q6_out <= # mxinp1 q6rnk3;
           default: q6_out <= # mxinp1 q6rnk2;
        endcase
    end

// Instantiate Bitslip controller
bscntrl_iserdese1_vlog bsc (.c23(c23), .c45(c45), .c67(c67), .sel(sel),
                .DATA_RATE(data_rate_int), .bitslip(bitslip_in),
                .clk(!clkoimux), .clkdiv(clkdivoimux), .r(rst_in),
                .clkdiv_int(clkdiv_int), .muxc(muxc)
        );

// Set value of counter in bitslip controller
always @ (cntr or c23 or c45 or c67 or sel)
begin
        casex (cntr)
        5'b00100: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b00; end
        5'b00110: begin c23=1'b1; c45=1'b0; c67=1'b0; sel=2'b00; end
        5'b01000: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b01; end
        5'b01010: begin c23=1'b0; c45=1'b1; c67=1'b0; sel=2'b01; end
        5'b10010: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b00; end
        5'b10011: begin c23=1'b1; c45=1'b0; c67=1'b0; sel=2'b00; end
        5'b10100: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b01; end
        5'b10101: begin c23=1'b0; c45=1'b1; c67=1'b0; sel=2'b01; end
        5'b10110: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b10; end
        5'b10111: begin c23=1'b0; c45=1'b0; c67=1'b1; sel=2'b10; end
        5'b11000: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b11; end
        default: $display("DATA_WIDTH %b and DATA_RATE %b at %t is an illegal value", DATA_WIDTH, DATA_RATE, $time);
        endcase

end


// Instantiate clock enable circuit
ice_iserdese1_vlog cec (.ce1(ce1_in), .ce2(ce2_in), .NUM_CE(num_ce_int),
                .clkdiv(rank3clkmux), .r(rst_in), .ice(ice)
        );

      assign O =  o_out;
      assign Q1 = q1_out;
      assign Q2 = q2_out;
      assign Q3 = q3_out;
      assign Q4 = q4_out;
      assign Q5 = q5_out;
      assign Q6 = q6_out;
      assign SHIFTOUT1 = shiftout1_out;
      assign SHIFTOUT2 = shiftout2_out;

    specify

        (CLK => Q1) = (100:100:100, 100:100:100);
        (CLK => Q2) = (100:100:100, 100:100:100);
        (CLK => Q3) = (100:100:100, 100:100:100);
        (CLK => Q4) = (100:100:100, 100:100:100);
        (CLK => Q5) = (100:100:100, 100:100:100);
        (CLK => Q6) = (100:100:100, 100:100:100);

        (CLKDIV => Q1) = (100:100:100, 100:100:100);
        (CLKDIV => Q2) = (100:100:100, 100:100:100);
        (CLKDIV => Q3) = (100:100:100, 100:100:100);
        (CLKDIV => Q4) = (100:100:100, 100:100:100);
        (CLKDIV => Q5) = (100:100:100, 100:100:100);
        (CLKDIV => Q6) = (100:100:100, 100:100:100);
        (D => O)    = (0, 0);
        (DDLY => O) = (0, 0);
        (OFB => O)  = (0, 0);


        specparam PATHPULSE$ = 0;

    endspecify

endmodule // ISERDESE1

`timescale 1ps/1ps
///////////////////////////////////////////////////////
//
// Bit slip controller
//
//
////////////////////////////////////////////////////////
//
//
//
/////////////////////////////////////////////////////////
//
//   Inputs:	
//		bitslip: Activates bitslip controller
//		clk: High speed forwarded clock
//		clkdiv: Low speed from clock divider in H clock row
//		r: Generates resest for flops
//				
//
//   Outputs:	
//		clkdiv_int: Generates clock same frequency as clkdiv
//		muxc: Controls mux in 2nd rank for DDR bitslip
//
//
//   Programmable options
//
//	DATA_RATE: Selects between sdr "1" and ddr "0" operation
//		c23: Selector between divide by 2 and divide by 3
//		c45: Selector between divide by 4 and divide by 5
//		c67: Selector between divide by 6 and divide by 7
//		sel: Mux selector with following table:
//			00: Divide by 2 or 3
//			01: Divide by 4 or 5
//			10: Divide by 6 or 7
//			11: Divide by 8
//
////////////////////////////////////////////////////////////////////////////////
//

module bscntrl_iserdese1_vlog (c23, c45, c67, sel, DATA_RATE, 
		bitslip,
		clk, clkdiv, r,
		clkdiv_int,muxc
	);

// programmable points
input		c23, c45, c67, DATA_RATE;

input	[1:0]	sel;

// regular inputs

input		clk, r, clkdiv;

input		bitslip;

// Programmable Test Attributes
wire		SRTYPE;
assign SRTYPE = 1'b0;

// outputs
output		clkdiv_int, muxc;


reg		clkdiv_int;

reg		q1, q2, q3;

reg		mux;

reg		qhc1, qhc2, qlc1, qlc2;

reg		qr1, qr2;

reg		mux1, muxc;


//////////////////////////////////////////////////
//
//  Delay parameter assignment
//
/////////////////////////////////////////////////

localparam ffbsc = 300;
localparam mxbsc = 60;


////////////////////////////////////////////////////
//
// Initialization of flops through GSR
//
///////////////////////////////////////////////////

`ifdef SW_NO_ISERDES_TEST
`else
tri0 GSR = glbl.GSR;

always @(GSR)
begin
	if (GSR) 
		begin
			assign q3 = 1'b0;
			assign q2 = 1'b0;
			assign q1 = 1'b0;
			assign clkdiv_int = 1'b0;
		end
	else 
		begin
			deassign q3;
			deassign q2;
			deassign q1;
			deassign clkdiv_int;
		end
end
`endif
//////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


///////////////////////////////
//
// Divide by 2 - 8 counter
//
////////////////////////////////

// Asynchronous Operation
always @ (posedge qr2 or posedge clk)
begin
	if (qr2 & SRTYPE)
		begin
			clkdiv_int <= # ffbsc 1'b0;
			q1 <= # ffbsc 1'b0;
			q2 <= # ffbsc 1'b0;
			q3 <= # ffbsc 1'b0;
		end
	else if (qhc1 & SRTYPE)
		begin
			clkdiv_int <= # ffbsc clkdiv_int;
			q1 <= # ffbsc q1;
			q2 <= # ffbsc q2;
			q3 <= # ffbsc q3;
		end
	else if (SRTYPE)
		begin
			q3 <= # ffbsc q2;
			q2 <= # ffbsc (!(!clkdiv_int & !q2) & q1);
			q1 <= # ffbsc clkdiv_int;
			clkdiv_int <= # ffbsc mux;
		end
end
// Synchronous Operation
always @ (posedge clk)
begin
	if (qr2 & !SRTYPE)
		begin
			clkdiv_int <= # ffbsc 1'b0;
			q1 <= # ffbsc 1'b0;
			q2 <= # ffbsc 1'b0;
			q3 <= # ffbsc 1'b0;
		end
	else if (qhc1 & !SRTYPE)
		begin
			clkdiv_int <= # ffbsc clkdiv_int;
			q1 <= # ffbsc q1;
			q2 <= # ffbsc q2;
			q3 <= # ffbsc q3;
		end
	else if (!SRTYPE)
		begin
			q3 <= # ffbsc q2;
			q2 <= # ffbsc (!(!clkdiv_int & !q2) & q1);
			q1 <= # ffbsc clkdiv_int;
			clkdiv_int <= # ffbsc mux;
		end
end



//////////////////////////////////////////
// 4:1 selector mux and divider selections
//////////////////////////////////////////
always @ (sel or c23 or c45 or c67 or clkdiv_int or q1 or q2 or q3)
	begin
		case (sel)
		2'b00: mux <= # mxbsc !(clkdiv_int |  (c23 & q1));
		2'b01: mux <= # mxbsc !(q1 | (c45 & q2));
		2'b10: mux <= # mxbsc !(q2 | (c67 & q3));
		2'b11: mux <= # mxbsc !q3;
		default: mux <= # mxbsc !(clkdiv_int |  (c23 & q1));
		endcase
	end

///////////////////////////////////
//
// Bitslip control logic
//
///////////////////////////////////


/////////////////////
// Low speed control flop
///////////////////////

// Asynchronous Operation
always @ (posedge qr1 or posedge clkdiv)
begin
	begin
	if (qr1 & SRTYPE)
		begin
			qlc1 <= # ffbsc 1'b0;
			qlc2 <= # ffbsc 1'b0;
		end
	else if (!bitslip & SRTYPE)
		begin
			qlc1 <= # ffbsc qlc1;
			qlc2 <= # ffbsc 1'b0;
		end
	else if (SRTYPE)
		begin
			qlc1 <= # ffbsc !qlc1;
			qlc2 <= # ffbsc (bitslip & mux1);
		end
	end
end
// Synchronous Operation
always @ (posedge clkdiv)
begin
	begin
	if (qr1 & !SRTYPE)
		begin
			qlc1 <= # ffbsc 1'b0;
			qlc2 <= # ffbsc 1'b0;
		end
	else if (!bitslip & !SRTYPE)
		begin
			qlc1 <= # ffbsc qlc1;
			qlc2 <= # ffbsc 1'b0;
		end
	else if (!SRTYPE)
		begin
			qlc1 <= # ffbsc !qlc1;
			qlc2 <= # ffbsc (bitslip & mux1);
		end
	end
end


/////////////////////////////////////////////
// Mux to select between sdr "1" and ddr "0"
/////////////////////////////////////////////
always @ (qlc1 or DATA_RATE)
	begin
		case (DATA_RATE)
		1'b0: mux1 <= # mxbsc qlc1;
		1'b1: mux1 <= # mxbsc 1'b1;

		endcase
	end

/////////////////////////
// High speed control flop
/////////////////////////

// Asynchronous Operation
always @ (posedge qr2 or posedge clk)
begin
	begin
	if (qr2 & SRTYPE)
		begin
			qhc1 <= # ffbsc 1'b0;
			qhc2 <= # ffbsc 1'b0;
		end
	else if (SRTYPE)
		begin
			qhc1 <= # ffbsc (qlc2 & !qhc2);
			qhc2 <= # ffbsc qlc2;
		end
	end
end
// Synchronous Operation
always @ (posedge clk)
begin
	begin
	if (qr2 & !SRTYPE)
		begin
			qhc1 <= # ffbsc 1'b0;
			qhc2 <= # ffbsc 1'b0;
		end
	else if (!SRTYPE)
		begin
			qhc1 <= # ffbsc (qlc2 & !qhc2);
			qhc2 <= # ffbsc qlc2;
		end
	end
end



/////////////////////////////////////////////
// Mux that drives control line of mux in front 
//	of 2nd rank of flops
//////////////////////////////////////////
always @ (mux1 or DATA_RATE)
begin
	case (DATA_RATE)
	1'b0 : muxc <= # mxbsc mux1;
	1'b1 : muxc <= # mxbsc 1'b0;
	endcase
end

/////////////////////////////
// Asynchronous set flops
/////////////////////////////

/////////////////////
// Low speed reset flop
///////////////////////

// Asynchronous Operation
always @ (posedge r or posedge clkdiv)
	begin
	if (r & SRTYPE)
		begin
			qr1 <= # ffbsc 1'b1;
		end
	else if (SRTYPE)
		begin
			qr1 <= # ffbsc 1'b0;
		end
	end
// Synchronous Operation
always @ (posedge clkdiv)
	begin
	if (r & !SRTYPE)
		begin
			qr1 <= # ffbsc 1'b1;
		end
	else if (!SRTYPE)
		begin
			qr1 <= # ffbsc 1'b0;
		end
	end

/////////////////////
// High speed reset flop
///////////////////////
// Asynchronous Operation
always @ (posedge r or posedge clk)
	begin
	if (r & SRTYPE)
		begin
			qr2 <= # ffbsc 1'b1;
		end
	else if (SRTYPE)
		begin
			qr2 <= # ffbsc qr1;
		end
	end
// Synchronous Operation
always @ (posedge clk)
	begin
	if (r & !SRTYPE)
		begin
			qr2 <= # ffbsc 1'b1;
		end
	else if (!SRTYPE)
		begin
			qr2 <= # ffbsc qr1;
		end
	end


///////////////////////

endmodule



`timescale 1ps/1ps
//
///////////////////////////////////////////////////////
//
//  Input Clock Enable Circuit
//
//
////////////////////////////////////////////////////////
//
//
//
/////////////////////////////////////////////////////////
//
//   Inputs:	ce1: 1st and default clock enable
//		ce2: 2nd clock enable used for serdes memory cases
//		r: Synchronous reset
//		clkdiv: Low speed output clock generated off the DCM
//				
//
//
//   Outputs:	intce: Clock enable
//
//
//   Programmable options
//
//	NUM_CE: 0: ce1 only, 1: ce1 and ce2
//
//   
//
////////////////////////////////////////////////////////////////////////////////
//

module ice_iserdese1_vlog (ce1, ce2, NUM_CE, 
		clkdiv, r,
		ice
		);


// regular inputs

input		ce1, ce2;

input		clkdiv, r;

// programmable points
input		NUM_CE;


// programmable test points
// Synchronus RST
wire		SRTYPE;
assign SRTYPE = 1'b0;

// output
output		ice;


reg		ce1r, ce2r, ice;

wire	[1:0]	cesel;

assign cesel = {NUM_CE,clkdiv};



//////////////////////////////////////////////////
//
// Delay parameters
//
/////////////////////

localparam ffice = 300;
localparam mxice = 60;


////////////////////////////////////////////////////
//
// Initialization of flops through GSR
//
///////////////////////////////////////////////////

tri0 GSR = glbl.GSR;

always @(GSR)
begin
	if (GSR) 
		begin
			assign ce1r = 1'b0;
			assign ce2r = 1'b0;
		end
	else 
		begin
			deassign ce1r;
			deassign ce2r;
		end
end
//////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////




// Asynchronous Operation
always @ (posedge clkdiv or posedge r)
	begin
	if (r & SRTYPE)
		begin
			ce1r <= # ffice 1'b0;
			ce2r <= # ffice 1'b0;
		end
	else if (SRTYPE)
		begin
			ce1r <= # ffice ce1;
			ce2r <= # ffice ce2;
		end
	end
// Synchronous Operation
always @ (posedge clkdiv)
	begin
	if (r & !SRTYPE)
		begin
			ce1r <= # ffice 1'b0;
			ce2r <= # ffice 1'b0;
		end
	else if (!SRTYPE)
		begin
			ce1r <= # ffice ce1;
			ce2r <= # ffice ce2;
		end
	end

// Output mux
always @ (cesel or ce1 or ce1r or ce2r)
	begin
		case (cesel)
		2'b00: ice <= # mxice ce1;
		2'b01: ice <= # mxice ce1;
		2'b10: ice <= # mxice ce2r;
		2'b11: ice <= # mxice ce1r;
		default: ice <= # mxice ce1;
		endcase
	end

///////////////////////

endmodule

