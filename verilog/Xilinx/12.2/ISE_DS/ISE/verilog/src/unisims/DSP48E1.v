///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  18X18 Signed Multiplier Followed by Three-Input Adder plus ALU with Pipeline Registers
// /___/   /\     Filename : DSP48E1.v
// \   \  /  \    Timestamp : Mon Sep 17 15:06:46 PDT 2007
//  \___\/\___\
//
// Revision:
//    09/17/07 - Initial version.
//    04/15/08 - CR 468871 Negative SetupHold fix
//    05/19/08 - IR 473330 Fix for qa/qb_o_reg1 when AREG/BREG = 1
//    06/06/08 - IR 474312 fix
//    07/08/08 - CR 473297 and 475997 fix -- removed input buffers that were causing NCSIM failures when sdf was backannotated 
//    07/12/08 - IR 472222 Removed SIM_MODE attribute
//    07/18/08 - IR 477318 Overflow/Underflow generate statment issue
//    07/31/08 - IR 478377 Fixed qcarryin_o_mux7
//    08/06/08 - IR 478378 Fixed mult sign extension
//    10/02/08 - IR 491365 Fixed timing constructs
//    03/02/09 - CR 510304 Carryout should output "X" during multiply
//    06/02/09 - CR 523600 Carryout "X"ed out before the register
//    07/07/09 - CR 525163 DRC checks for USE_MULT/OPMODE combinations
//    09/23/09 - CR 532623 Initalized interal registers
//    10/12/09 - CR 535687 Initalized d and ad registers
//    02/17/10 - CR 548358 Updated DRC check warning message 
// End Revision

`timescale  1 ps / 1 ps

module DSP48E1 (ACOUT, BCOUT, CARRYCASCOUT, CARRYOUT, MULTSIGNOUT, OVERFLOW, P, PATTERNBDETECT, PATTERNDETECT, PCOUT, UNDERFLOW, A, ACIN, ALUMODE, B, BCIN, C, CARRYCASCIN, CARRYIN, CARRYINSEL, CEA1, CEA2, CEAD, CEALUMODE, CEB1, CEB2, CEC, CECARRYIN, CECTRL, CED, CEINMODE, CEM, CEP, CLK, D, INMODE, MULTSIGNIN, OPMODE, PCIN, RSTA, RSTALLCARRYIN, RSTALUMODE, RSTB, RSTC, RSTCTRL, RSTD, RSTINMODE, RSTM, RSTP); 


    parameter integer ACASCREG = 1;
    parameter integer ADREG = 1;
    parameter integer ALUMODEREG = 1;
    parameter integer AREG = 1;
    parameter AUTORESET_PATDET = "NO_RESET";  // {NO_RESET, RESET_MATCH, RESET_NOT_MATCH}
    parameter A_INPUT = "DIRECT";
    parameter integer BCASCREG = 1;
    parameter integer BREG = 1;
    parameter B_INPUT = "DIRECT";
    parameter integer CARRYINREG = 1;
    parameter integer CARRYINSELREG = 1;
    parameter integer CREG = 1;
    parameter integer DREG = 1;
    parameter integer INMODEREG = 1;
    parameter MASK =  48'h3FFFFFFFFFFF;
    parameter integer MREG = 1;
    parameter integer OPMODEREG = 1;
    parameter PATTERN =  48'h000000000000;
    parameter integer PREG = 1;
    parameter SEL_MASK = "MASK";
    parameter SEL_PATTERN = "PATTERN";
    parameter USE_DPORT = "FALSE";
    parameter USE_MULT = "MULTIPLY";
    parameter USE_PATTERN_DETECT = "NO_PATDET";
    parameter USE_SIMD = "ONE48";

    output [29:0] ACOUT; 
    output [17:0] BCOUT; 
    output CARRYCASCOUT;
    output [3:0] CARRYOUT;
    output MULTSIGNOUT;
    output OVERFLOW;
    output [47:0] P; 
    output PATTERNBDETECT;
    output PATTERNDETECT;
    output [47:0] PCOUT;
    output UNDERFLOW;

    input [29:0] A;
    input [29:0] ACIN;
    input [3:0] ALUMODE;
    input [17:0] B;
    input [17:0] BCIN;
    input [47:0] C;
    input CARRYCASCIN;
    input CARRYIN;
    input [2:0] CARRYINSEL;
    input CEA1;
    input CEA2;
    input CEAD;         // new
    input CEALUMODE;
    input CEB1;
    input CEB2;
    input CEC;
    input CECARRYIN;
    input CECTRL;
    input CED;          // new
    input CEINMODE;     // new
    input CEM; 
    input CEP;
    input CLK;
    input [24:0] D; // new
    input [4:0] INMODE; // new
    input MULTSIGNIN;
    input [6:0] OPMODE;
    input [47:0] PCIN;
    input RSTA;
    input RSTALLCARRYIN;
    input RSTALUMODE;
    input RSTB;
    input RSTC;
    input RSTCTRL;
    input RSTD;          // new
    input RSTINMODE;     // new 
    input RSTM;  
    input RSTP;

    tri0  GSR = glbl.GSR;

//------------------- constants -------------------------
   localparam MAX_ACOUT      = 30;
   localparam MAX_BCOUT      = 18;
   localparam MAX_CARRYOUT   = 4;
   localparam MAX_P          = 48;
   localparam MAX_PCOUT      = 48;

   localparam MAX_A          = 30;
   localparam MAX_ACIN       = 30;
   localparam MAX_ALUMODE    = 4;
   localparam MAX_A_MULT     = 25;
   localparam MAX_B          = 18;
   localparam MAX_B_MULT     = 18;
   localparam MAX_BCIN       = 18;
   localparam MAX_C          = 48;
   localparam MAX_CARRYINSEL = 3;
   localparam MAX_D          = 25;
   localparam MAX_INMODE     = 5;
   localparam MAX_OPMODE     = 7;
   localparam MAX_PCIN       = 48;

   localparam MAX_ALU_FULL   = 48;
   localparam MAX_ALU_HALF   = 24;
   localparam MAX_ALU_QUART  = 12;

   localparam MSB_ACOUT      = MAX_ACOUT - 1;
   localparam MSB_BCOUT      = MAX_BCOUT - 1;
   localparam MSB_CARRYOUT   = MAX_CARRYOUT - 1;
   localparam MSB_P          = MAX_P - 1;
   localparam MSB_PCOUT      = MAX_PCOUT - 1;
 
   localparam MSB_A          = MAX_A - 1;
   localparam MSB_ACIN       = MAX_ACIN - 1;
   localparam MSB_ALUMODE    = MAX_ALUMODE - 1;
   localparam MSB_A_MULT     = MAX_A_MULT - 1;
   localparam MSB_B          = MAX_B - 1;
   localparam MSB_B_MULT     = MAX_B_MULT - 1;
   localparam MSB_BCIN       = MAX_BCIN - 1;
   localparam MSB_C          = MAX_C - 1;
   localparam MSB_CARRYINSEL = MAX_CARRYINSEL - 1;
   localparam MSB_D          = MAX_D - 1;
   localparam MSB_INMODE     = MAX_INMODE - 1;
   localparam MSB_OPMODE     = MAX_OPMODE - 1;
   localparam MSB_PCIN       = MAX_PCIN - 1;

   localparam MSB_ALU_FULL   = MAX_ALU_FULL  - 1;
   localparam MSB_ALU_HALF   = MAX_ALU_HALF  - 1;
   localparam MSB_ALU_QUART  = MAX_ALU_QUART - 1;

   localparam SHIFT_MUXZ     = 17;

    reg [29:0] a_o_mux, qa_o_mux, qa_o_reg1, qa_o_reg2, qacout_o_mux;

// new
    reg [4:0]  qinmode_o_mux, qinmode_o_reg;
// new
    wire [24:0] a_preaddsub;

    reg [17:0] b_o_mux, qb_o_mux, qb_o_reg1, qb_o_reg2, qbcout_o_mux;
    reg [2:0] qcarryinsel_o_mux, qcarryinsel_o_reg1;

// new  
    reg [MSB_D:0] d_o_mux, qd_o_mux, qd_o_reg1;

    reg [(MSB_A_MULT+MSB_B_MULT+1):0] qmult_o_mux, qmult_o_reg;
    reg [47:0] qc_o_mux, qc_o_reg1;
    reg [47:0] qp_o_mux, qp_o_reg1;
    reg [47:0] qx_o_mux, qy_o_mux, qz_o_mux;
    reg [6:0]  qopmode_o_mux, qopmode_o_reg1;

    

    reg qcarryin_o_mux0, qcarryin_o_reg0, qcarryin_o_mux7, qcarryin_o_reg7;
    reg qcarryin_o_mux, qcarryin_o_reg;

    reg [3:0]  qalumode_o_mux, qalumode_o_reg1;

    reg invalid_opmode, opmode_valid_flag, ping_opmode_drc_check = 0;

//    reg [47:0] alu_o;
    wire [47:0] alu_o;

    reg qmultsignout_o_reg, multsignout_o_mux; 
    wire multsignout_o_opmode;

    reg [MAX_ALU_FULL:0]  alu_full_tmp;
    reg [MAX_ALU_HALF:0]  alu_hlf1_tmp, alu_hlf2_tmp;
    reg [MAX_ALU_QUART:0] alu_qrt1_tmp,  alu_qrt2_tmp, alu_qrt3_tmp, alu_qrt4_tmp;
    
    wire pdet_o_mux, pdetb_o_mux;

    wire [47:0] the_pattern; 
    reg [47:0] the_mask = 0;
    wire carrycascout_o;
    reg carrycascout_o_reg = 0;
    reg carrycascout_o_mux = 0;

//    reg [3:0] carryout_o = 0;
    reg [3:0] carryout_o_reg = 0;
    reg [3:0] carryout_o_mux = 0;
    wire [3:0] carryout_x_o;

    wire pdet_o, pdetb_o;
    reg  pdet_o_reg1, pdet_o_reg2, pdetb_o_reg1, pdetb_o_reg2;
    wire overflow_o, underflow_o;

    wire [(MSB_A_MULT+MSB_B_MULT+1):0] mult_o;
// new 
    wire [MSB_A_MULT:0] ad_addsub, ad_mult;
    reg  [MSB_A_MULT:0] qad_o_reg1, qad_o_mux;
    wire [MSB_B_MULT:0] b_mult;


//*** GLOBAL hidden GSR pin
    always @(GSR) begin
	if (GSR) begin
            assign qcarryin_o_reg0 = 1'b0;
            assign qcarryinsel_o_reg1 = 3'b0;
            assign qopmode_o_reg1 = 7'b0;
            assign qalumode_o_reg1 = 4'b0;
            assign qa_o_reg1 = 30'b0;
            assign qa_o_reg2 = 30'b0;
            assign qb_o_reg1 = 18'b0;
            assign qb_o_reg2 = 18'b0;
            assign qc_o_reg1 = 48'b0;
            assign qp_o_reg1 = 48'b0;
	    assign qmult_o_reg = 36'b0;
            assign pdet_o_reg1 = 1'b0;
            assign pdet_o_reg2 = 1'b0;
            assign pdetb_o_reg1 = 1'b0;
            assign pdetb_o_reg2 = 1'b0;

            assign carryout_o_reg = 4'b0;
            assign carrycascout_o_reg = 1'b0;

	    assign qmultsignout_o_reg = 1'b0;

            assign qd_o_reg1 = 25'b0;
            assign qad_o_reg1 = 25'b0;
            assign qinmode_o_reg = 5'b0;
	end
	else begin
            deassign qcarryin_o_reg0;
            deassign qcarryinsel_o_reg1;
            deassign qopmode_o_reg1;
            deassign qalumode_o_reg1;
            deassign qa_o_reg1;
            deassign qa_o_reg2;
            deassign qb_o_reg1;
            deassign qb_o_reg2;
            deassign qc_o_reg1;
            deassign qp_o_reg1;
	    deassign qmult_o_reg;

            deassign pdet_o_reg1;
            deassign pdet_o_reg2;
            deassign pdetb_o_reg1;
            deassign pdetb_o_reg2;

            deassign carryout_o_reg;
            deassign carrycascout_o_reg;

	    deassign qmultsignout_o_reg;

            deassign qd_o_reg1;
            deassign qad_o_reg1;
            deassign qinmode_o_reg;
	end
    end


    initial begin
	opmode_valid_flag <= 1;
	invalid_opmode <= 1;

        //-------- A_INPUT check

	case (A_INPUT)
             "DIRECT", "CASCADE" : ;
              default : begin
	       	            $display("Attribute Syntax Error : The attribute A_INPUT on DSP48E1 instance %m is set to %s.  Legal values for this attribute are DIRECT or CASCADE.", A_INPUT);
		            $finish;
                        end
	endcase

        //-------- ALUMODEREG check

	case (ALUMODEREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute ALUMODEREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1.", ALUMODEREG);
	                  $finish;
	              end
	endcase

        //-------- AREG check

	case (AREG)
            0, 1, 2 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute AREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1 or 2.", AREG);
	                  $finish;
	              end
	endcase

        //-------- (ACASCREG) and (ACASCREG vs AREG) check

	case (AREG)
            0 : if(AREG != ACASCREG) begin
                    $display("Attribute Syntax Error : The attribute ACASCREG  on DSP48E1 instance %m is set to %d.  ACASCREG has to be set to 0 when attribute AREG = 0.", ACASCREG);
                    $finish;
                end
            1 : if(AREG != ACASCREG) begin
                    $display("Attribute Syntax Error : The attribute ACASCREG  on DSP48E1 instance %m is set to %d.  ACASCREG has to be set to 1 when attribute AREG = 1.", ACASCREG);
                    $finish;
                end
            2 : if((AREG != ACASCREG) && ((AREG-1) != ACASCREG)) begin
                    $display("Attribute Syntax Error : The attribute ACASCREG  on DSP48E1 instance %m is set to %d.  ACASCREG has to be set to either 2 or 1 when attribute AREG = 2.", ACASCREG);
                    $finish;
                end
            default : ;
	endcase

        //-------- B_INPUT check

	case (B_INPUT)
             "DIRECT", "CASCADE" : ;
              default : begin
	       	            $display("Attribute Syntax Error : The attribute B_INPUT on DSP48E1 instance %m is set to %s.  Legal values for this attribute are DIRECT or CASCADE.", B_INPUT);
		            $finish;
                        end
	endcase


        //-------- BREG check

	case (BREG)
            0, 1, 2 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute BREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1 or 2.", BREG);
	                  $finish;
	              end
	endcase

        //-------- (BCASCREG) and (BCASCREG vs BREG) check

	case (BREG)
            0 : if(BREG != BCASCREG) begin
                    $display("Attribute Syntax Error : The attribute BCASCREG  on DSP48E1 instance %m is set to %d.  BCASCREG has to be set to 0 when attribute BREG = 0.", BCASCREG);
                    $finish;
                end
            1 : if(BREG != BCASCREG) begin
                    $display("Attribute Syntax Error : The attribute BCASCREG  on DSP48E1 instance %m is set to %d.  BCASCREG has to be set to 1 when attribute BREG = 1.", BCASCREG);
                    $finish;
                end
            2 : if((BREG != BCASCREG) && ((BREG-1) != BCASCREG)) begin
                    $display("Attribute Syntax Error : The attribute BCASCREG  on DSP48E1 instance %m is set to %d.  BCASCREG has to be set to either 2 or 1 when attribute BREG = 2.", BCASCREG);
                    $finish;
                end
            default : ;
	endcase

        //-------- CARRYINREG check

	case (CARRYINREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CARRYINREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1.", CARRYINREG);
	                  $finish;
	              end
	endcase

        //-------- CARRYINSELREG check

	case (CARRYINSELREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CARRYINSELREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1.", CARRYINSELREG);
	                  $finish;
	              end
	endcase

        //-------- CREG check

	case (CREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, or 1.", CREG);
	                  $finish;
	              end
	endcase


        //-------- OPMODEREG check

	case (OPMODEREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute OPMODEREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1.", OPMODEREG);
	                  $finish;
	              end
	endcase

        //-------- USE_MULT

        case (USE_MULT)
            "NONE", "MULTIPLY", "DYNAMIC" : ;
            default : begin
                          $display("Attribute Syntax Error : The attribute USE_MULT on DSP48E1 instance %m is set to %s. Legal values for this attribute are MULTIPLY, DYNAMIC or NONE.", USE_MULT);
                          $finish;
                     end
/*
            "MULT" : if (MREG != 0) begin
                               $display("Attribute Syntax Error : The attribute USE_MULT on DSP48E1 instance %m is set to %s. This requires attribute MREG to be set to 0.", USE_MULT);
                               $finish;
                        end
            "MULT_S" : if (MREG != 1) begin
                               $display("Attribute Syntax Error : The attribute USE_MULT on DSP48E1 instance %m is set to %s. This requires attribute MREG to be set to 1.", USE_MULT);
                               $finish;
                        end
            default : begin
                          $display("Attribute Syntax Error : The attribute USE_MULT on DSP48E1 instance %m is set to %s. Legal values for this attribute are NONE, MULT or MULT_S.", USE_MULT);
                          $finish;
                     end
*/
        endcase

        //-------- USE_PATTERN_DETECT

        case (USE_PATTERN_DETECT)
            "PATDET", "NO_PATDET" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute USE_PATTERN_DETECT on DSP48E1 instance %m is set to %s.  Legal values for this attribute are PATDET or NO_PATDET.",  USE_PATTERN_DETECT);
               $finish;
            end
        endcase

        //-------- AUTORESET_PATDET check

        case (AUTORESET_PATDET)
            "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute AUTORESET_PATDET on DSP48E1 instance %m is set to %s.  Legal values for this attribute are  NO_RESET or RESET_MATCH or RESET_NOT_MATCH.",  AUTORESET_PATDET);
               $finish;
            end
        endcase

        //-------- SEL_PATTERN check

        case(SEL_PATTERN)
           "PATTERN", "C" : ;
            default : begin
                         $display("Attribute Syntax Error : The attribute SEL_PATTERN on DSP48E1 instance %m is set to %s.  Legal values for this attribute are PATTERN or C.", SEL_PATTERN);
                         $finish;
                      end
	endcase

        //-------- SEL_MASK check

        case(SEL_MASK)
            "MASK", "C", "ROUNDING_MODE1", "ROUNDING_MODE2" : ;
             default : begin
                         $display("Attribute Syntax Error : The attribute SEL_MASK on DSP48E1 instance %m is set to %s.  Legal values for this attribute are MASK or C or ROUNDING_MODE1 or ROUNDING_MODE2.", SEL_MASK);
                          $finish;
                       end
	endcase

        //-------- MREG check

	case (MREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute MREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1.", MREG);
	                  $finish;
	              end
	endcase


        //-------- PREG check

	case (PREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute PREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1.", PREG);
	                  $finish;
	              end
	endcase


        #100010 ping_opmode_drc_check <= 1;

    
//*********************************************************
//*** ADDITIONAL DRC  
//*********************************************************
// CR 219407  --  (1)
// old ask vicv
/*
    if((AUTORESET_PATTERN_DETECT == "TRUE") && (USE_PATTERN_DETECT == "NO_PATDET")) begin
         $display("Attribute Syntax Error : The attribute USE_PATTERN_DETECT on DSP48E1 instance %m must be set to PATDET in order to use AUTORESET_PATTERN_DETECT equals TRUE. Failure to do so could make timing reports inaccurate. ");
     end
*/
//*********************************************************
//***  new attribute DRC
//*********************************************************

        //-------- ADREG check

	case (ADREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute ADREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1.", ADREG);
	                  $finish;
	              end
	endcase

        //-------- DREG check

	case (DREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute DREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1.", DREG);
	                  $finish;
	              end
	endcase

        //-------- INMODEREG check

	case (INMODEREG)
            0, 1 : ;
            default : begin
	                  $display("Attribute Syntax Error : The attribute INMODEREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0, 1.", INMODEREG);
	                  $finish;
	              end
	endcase

        //-------- USE_DPORT

        case (USE_DPORT)
            "TRUE", "FALSE" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute USE_DPORT on DSP48E1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.",  USE_DPORT);
               $finish;
            end
        endcase
      // New Additional DRCs for Power Saving -- Warning Only

       //------------- USE_DPORT

       if(((DREG == 1) || (ADREG == 1 )) && (USE_DPORT == "FALSE"))
               $display("DRC Warning : Since D port is not used, please set DREG and ADREG to 0 to save power");


       //------------- USE_MULT

       if(((DREG == 1) || (ADREG == 1 )) && (USE_MULT == "NONE"))
               $display("DRC Warning : Since Multiplier is not used, please set DREG and ADREG to 0 to save power");

       if((MREG == 1) && (USE_MULT == "NONE"))
               $display("DRC Warning : Since Multiplier is not used, please set MREG to 0 to save power");

    end


//*********************************************************
//**********  INMODE signal registering        ************
//*********************************************************
// new 
    always @(posedge CLK) begin
       if (RSTINMODE)
          qinmode_o_reg <= 5'b0;
       else if (CEINMODE)
          qinmode_o_reg <= INMODE;
    end

    generate 
       case (INMODEREG)
          0: begin 
             always @(INMODE)
                qinmode_o_mux <= INMODE;
	  end

          1: begin 
             always @(qinmode_o_reg)
                qinmode_o_mux <= qinmode_o_reg;
	  end
       endcase
    endgenerate 

//*********************************************************
//*** Input register A with 2 level deep of registers
//*********************************************************

    generate 
       case (A_INPUT)
          "DIRECT"  : always @(A)    a_o_mux <= A;
          "CASCADE" : always @(ACIN) a_o_mux <= ACIN;
       endcase
    endgenerate 

    generate 
       case (AREG)
          1 : begin
              always @(posedge CLK) begin
	         if (RSTA) begin
                    qa_o_reg1 <= 30'b0;
                    qa_o_reg2 <= 30'b0;
                 end
                 else begin
                      if (CEA1)
                          qa_o_reg1 <= a_o_mux;
                      if (CEA2)
                          qa_o_reg2 <= a_o_mux;
                 end
              end
          end

          2 : begin
              always @(posedge CLK) begin
	         if (RSTA) begin
                    qa_o_reg1 <= 30'b0;
                    qa_o_reg2 <= 30'b0;
                 end
                 else begin
                      if (CEA1)
                          qa_o_reg1 <= a_o_mux;
                      if (CEA2)
                          qa_o_reg2 <= qa_o_reg1;
                 end
              end
          end
       endcase
    endgenerate 

    generate 
       case (AREG)
          0: always @(a_o_mux) qa_o_mux <= a_o_mux;
          1,2 : always @(qa_o_reg2) qa_o_mux <= qa_o_reg2;
       endcase
    endgenerate 

    generate 
       case (ACASCREG)
          1: always @(qa_o_mux or qa_o_reg1) begin
                 if(AREG == 2)
                    qacout_o_mux <= qa_o_reg1;
                 else
                    qacout_o_mux <= qa_o_mux;
             end
          0,2 : always @(qa_o_mux) qacout_o_mux <= qa_o_mux;
       endcase
    endgenerate 

// new  
    
   assign a_preaddsub = qinmode_o_mux[1]? 25'b0:(qinmode_o_mux[0]?qa_o_reg1[24:0]:qa_o_mux[24:0]);

//*********************************************************
//*** Input register B with 2 level deep of registers
//*********************************************************

    generate 
       case (B_INPUT)
          "DIRECT"  : always @(B)    b_o_mux <= B;
          "CASCADE" : always @(BCIN) b_o_mux <= BCIN;
       endcase
    endgenerate 

    generate 
       case (BREG)
          1 : begin
              always @(posedge CLK) begin
	         if (RSTB) begin
                      qb_o_reg1 <= 18'b0;
                      qb_o_reg2 <= 18'b0;
                 end
                 else begin
                      if (CEB1)
                          qb_o_reg1 <= b_o_mux;
                      if (CEB2)
                          qb_o_reg2 <= b_o_mux;
                 end
              end
          end

          2 : begin
              always @(posedge CLK) begin
	         if (RSTB) begin
                    qb_o_reg1 <= 18'b0;
                    qb_o_reg2 <= 18'b0;
                 end
                 else begin
                      if (CEB1)
                          qb_o_reg1 <= b_o_mux;
                      if (CEB2)
                          qb_o_reg2 <= qb_o_reg1;
                 end
              end
          end
       endcase
    endgenerate 

    generate 
       case (BREG)
          0: always @(b_o_mux) qb_o_mux <= b_o_mux;
          1,2 : always @(qb_o_reg2) qb_o_mux <= qb_o_reg2;
       endcase
    endgenerate 

    generate
       case (BCASCREG)
          1: always @(qb_o_mux or qb_o_reg1) begin
                 if(BREG == 2)
                    qbcout_o_mux <= qb_o_reg1;
                 else
                    qbcout_o_mux <= qb_o_mux;
             end
          0,2 : always @(qb_o_mux) qbcout_o_mux <= qb_o_mux;
       endcase
    endgenerate


// new
    
   assign b_mult = qinmode_o_mux[4]?qb_o_reg1:qb_o_mux;

//*********************************************************
//*** Input register C with 1 level deep of register
//*********************************************************

    always @(posedge CLK) begin
	if (RSTC)
            qc_o_reg1 <= 48'b0;
	else if (CEC)
            qc_o_reg1 <= C;
    end


    generate
       case (CREG)
          0 : always @(C) qc_o_mux <= C;
          1 : always @(qc_o_reg1) qc_o_mux <= qc_o_reg1;
       endcase
    endgenerate


// new

//*********************************************************
//*** Input register D with 1 level deep of register
//*********************************************************
    always @(posedge CLK) begin
	if (RSTD)
            qd_o_reg1 <= 25'b0;
	else if (CED)
            qd_o_reg1 <= D;
    end

    generate
       case (DREG)
          0 : always @(D) qd_o_mux <= D;
          1 : always @(qd_o_reg1) qd_o_mux <= qd_o_reg1;
       endcase
    endgenerate




//*********************************************************
//*** Preaddsub AD register with 1 level deep of register
//*********************************************************
// new  
      assign ad_addsub = qinmode_o_mux[3]?(-a_preaddsub + (qinmode_o_mux[2]?qd_o_mux:25'b0)):(a_preaddsub + (qinmode_o_mux[2]?qd_o_mux:25'b0));

    always @(posedge CLK) begin
	if (RSTD)
            qad_o_reg1 <= 25'b0;
	else if (CEAD)
            qad_o_reg1 <= ad_addsub;
    end

    generate
       case (ADREG)
          0 : always @(ad_addsub) qad_o_mux <= ad_addsub;
          1 : always @(qad_o_reg1) qad_o_mux <= qad_o_reg1;
       endcase
    endgenerate

/*------------------------------------------------- */
/*------------------------------------------------- */

   assign ad_mult = (USE_DPORT=="TRUE")? qad_o_mux : a_preaddsub;
//*********************************************************

//*********************************************************
//***************      25x18 Multiplier     ***************
//*********************************************************
// 05/26/05 -- FP -- Added warning for invalid mult when USE_MULT=NONE
// SIMD=FOUR12 and SIMD=TWO24
// Made mult_o to be "X"

    always @(qopmode_o_mux) begin
       if(qopmode_o_mux[3:0] == 4'b0101)
          if((USE_MULT == "NONE") || (USE_SIMD == "TWO24") || (USE_SIMD == "FOUR12")) 
               $display("OPMODE Input Warning : The OPMODE[3:0] %b to DSP48E1 instance %m is invalid when using attributes USE_MULT = NONE, or USE_SIMD = TWO24 or FOUR12 at %.3f ns.", qopmode_o_mux[3:0], $time/1000.0);
    end

    assign mult_o = ((USE_MULT == "NONE") || (USE_SIMD == "TWO24") || (USE_SIMD == "FOUR12"))? 43'b0 : {{18{ad_mult[24]}}, ad_mult[24:0]} * {{25{b_mult[17]}}, b_mult};

    always @(posedge CLK) begin
	if (RSTM) begin
            qmult_o_reg <= 18'b0;
	end
	else if (CEM) begin
            qmult_o_reg <= mult_o;
	end
    end

    generate
       case (MREG)
          0 : always @(mult_o) qmult_o_mux <= mult_o;
          1 : always @(qmult_o_reg) qmult_o_mux <= qmult_o_reg;
       endcase
    endgenerate


//*** X mux
// ask jmt

    always @(qp_o_mux or qa_o_mux or qb_o_mux or qmult_o_mux or qopmode_o_mux[1:0] or qcarryinsel_o_mux) begin
	case (qopmode_o_mux[1:0])
              2'b00 : qx_o_mux <= 48'b0;
              2'b01 : qx_o_mux <= {{5{qmult_o_mux[MSB_A_MULT + MSB_B_MULT + 1]}}, qmult_o_mux};
              2'b10 : qx_o_mux <= qp_o_mux;
// new DRC 
              2'b11 : begin
                         if((USE_MULT == "MULTIPLY") && (
                                  (AREG==0 && BREG==0 && MREG==0) ||
                                  (AREG==0 && BREG==0 && PREG==0) ||
                                  (MREG==0 && PREG==0)))
                               $display("OPMODE Input Warning : The OPMODE[1:0] %b to DSP48E1 instance %m is invalid when using attributes USE_MULT = MULTIPLY at %.3f ns. Please set USE_MULT to either NONE or DYNAMIC.", qopmode_o_mux[1:0], $time/1000.0);
	                 else
                            qx_o_mux <=  {qa_o_mux[MSB_A:0], qb_o_mux[MSB_B:0]};
	              end

            default : begin
	              end
	endcase
    end


//*** Y mux

// 08-06-08  
// IR 478378
    wire [47:0] y_mac_cascd = (qopmode_o_mux[6:4] == 3'b100) ? {48{MULTSIGNIN}} : {48{1'b1}};

    always @(qc_o_mux or qopmode_o_mux[3:2] or qcarryinsel_o_mux or y_mac_cascd) begin
	case (qopmode_o_mux[3:2])
              2'b00 : qy_o_mux <= 48'b0;
              2'b01 : qy_o_mux <= 48'b0;
// 08-06-08  
              2'b10 : qy_o_mux <= y_mac_cascd;                // choose all ones or mult-sign-extend
              2'b11 : qy_o_mux <= qc_o_mux;
            default : begin
	              end
	endcase
    end


//*** Z mux

    always @(qp_o_mux or qc_o_mux or PCIN or qopmode_o_mux[6:4] or qcarryinsel_o_mux) begin
// ask jmt
	casex (qopmode_o_mux[6:4])
             3'b000 : qz_o_mux <= 48'b0;
             3'b001 : qz_o_mux <= PCIN;
             3'b010 : qz_o_mux <= qp_o_mux;
             3'b011 : qz_o_mux <= qc_o_mux;
             3'b100 : qz_o_mux <= qp_o_mux;
             3'b101 : qz_o_mux <= {{17{PCIN[47]}}, PCIN[47:17]};
// ask jmt 
             3'b11x : qz_o_mux <= {{17{qp_o_mux[47]}}, qp_o_mux[47:17]};
            default : begin
	              end
	endcase
    end



//*** CarryInSel and OpMode with 1 level of register
    always @(posedge CLK) begin
	if (RSTCTRL) begin
            qcarryinsel_o_reg1 <= 3'b0;
            qopmode_o_reg1 <= 7'b0;
	end  
	else if (CECTRL) begin
            qcarryinsel_o_reg1 <= CARRYINSEL;
            qopmode_o_reg1 <= OPMODE;
	end
    end

    generate
       case (CARRYINSELREG)
          0 : always @(CARRYINSEL) qcarryinsel_o_mux <= CARRYINSEL;
          1 : always @(qcarryinsel_o_reg1) qcarryinsel_o_mux <= qcarryinsel_o_reg1;
       endcase
    endgenerate


//CR 219047 (3) 

//    always @(qcarryinsel_o_mux or MULTSIGNIN or qopmode_o_mux) begin
//    always @(CARRYCASCIN or MULTSIGNIN or qopmode_o_mux) begin
    always @(qcarryinsel_o_mux or CARRYCASCIN or MULTSIGNIN or qopmode_o_mux) begin
        if(qcarryinsel_o_mux == 3'b010) begin 
           if(!((MULTSIGNIN === 1'bx) || ((qopmode_o_mux == 7'b1001000) && !(MULTSIGNIN === 1'bx)) 
                                 || ((MULTSIGNIN == 1'b0) && (CARRYCASCIN == 1'b0)))) begin
	      $display("DRC warning : CARRYCASCIN can only be used in the current DSP48E1 instance %m if the previous DSP48E1 is performing a two input ADD operation, or the current DSP48E1 is configured in the MAC extend opmode 7'b1001000 at %.3f ns.", $time);
            end  
        end  
    end 
/*
// old
// ask jmt
//CR 219047 (4) 
    always @(qcarryinsel_o_mux) begin
       if((qcarryinsel_o_mux == 3'b110) && (MULTCARRYINREG != MREG)) begin
	  $display("Attribute Syntax Warning : It is recommended that MREG and MULTCARRYINREG on DSP48E1 instance %m be set to the same value when using CARRYINSEL = 110 for multiply rounding.");
       end
    end
*/

    generate
       case (OPMODEREG)
          0 : always @(OPMODE) qopmode_o_mux <= OPMODE;
          1 : always @(qopmode_o_reg1) qopmode_o_mux <= qopmode_o_reg1;
       endcase
    endgenerate


//*** ALUMODE with 1 level of register
    always @(posedge CLK) begin
	if (RSTALUMODE)
            qalumode_o_reg1 <= 4'b0;
	else if (CEALUMODE)
            qalumode_o_reg1 <= ALUMODE;
    end


    generate
       case (ALUMODEREG)
          0 : always @(ALUMODE) qalumode_o_mux <= ALUMODE;
          1 : always @(qalumode_o_reg1) qalumode_o_mux <= qalumode_o_reg1;
       endcase
    endgenerate

//------------------------------------------------------------------
//*** DRC for OPMODE
//------------------------------------------------------------------

    task deassign_xyz_mux;
        begin
            opmode_valid_flag = 1;
            invalid_opmode = 1;  // reset invalid opmode
        end
    endtask // deassign_xyz_mux

    
    task display_invalid_opmode;
        begin
            if (invalid_opmode) begin
                opmode_valid_flag = 0;
                invalid_opmode = 0;
                $display("OPMODE Input Warning : The OPMODE %b to DSP48E1 instance %m at %.3f ns requires attribute PREG set to 1.", qopmode_o_mux, $time/1000.0);
            end
        end
    endtask // display_invalid_opmode

    always @(ping_opmode_drc_check or qalumode_o_mux or qopmode_o_mux or qcarryinsel_o_mux ) begin

      if ($time > 100000) begin  // no check at first 100ns
        case (qalumode_o_mux[3:2]) 
          2'b00 :
          //-- ARITHMETIC MODES DRC
            case ({qopmode_o_mux, qcarryinsel_o_mux})
                10'b0000000000 : deassign_xyz_mux;
                10'b0000010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0000010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0000011000 : deassign_xyz_mux;
                10'b0000011010 : deassign_xyz_mux;
                10'b0000011100 : deassign_xyz_mux;
                10'b0000101000 : deassign_xyz_mux;
                10'b0001000000 : deassign_xyz_mux;
                10'b0001010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001011000 : deassign_xyz_mux;
                10'b0001011010 : deassign_xyz_mux;
                10'b0001011100 : deassign_xyz_mux;
                10'b0001100000 : deassign_xyz_mux;
                10'b0001100010 : deassign_xyz_mux;
                10'b0001100100 : deassign_xyz_mux;
                10'b0001110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001110010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0001111000 : deassign_xyz_mux;
                10'b0001111010 : deassign_xyz_mux;
                10'b0001111100 : deassign_xyz_mux;
                10'b0010000000 : deassign_xyz_mux;
                10'b0010010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0010010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0010010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0010011000 : deassign_xyz_mux;
                10'b0010011001 : deassign_xyz_mux;
                10'b0010011011 : deassign_xyz_mux;
                10'b0010101000 : deassign_xyz_mux;
                10'b0010101001 : deassign_xyz_mux;
                10'b0010101011 : deassign_xyz_mux;
                10'b0010101110 : deassign_xyz_mux;
                10'b0011000000 : deassign_xyz_mux;
                10'b0011010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011011000 : deassign_xyz_mux;
                10'b0011011001 : deassign_xyz_mux;
                10'b0011011011 : deassign_xyz_mux;
                10'b0011100000 : deassign_xyz_mux;
                10'b0011100001 : deassign_xyz_mux;
                10'b0011100011 : deassign_xyz_mux;
                10'b0011110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011110001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011110011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0011111000 : deassign_xyz_mux;
                10'b0011111001 : deassign_xyz_mux;
                10'b0011111011 : deassign_xyz_mux;
                10'b0100000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100000010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100011000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100011010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100011101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100011111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100101000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100101101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0100101111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101000010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101011000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101011101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101011111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101100000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101100010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101100101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101100111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101111101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0101111111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110000000 : deassign_xyz_mux;
                10'b0110000010 : deassign_xyz_mux;
                10'b0110000100 : deassign_xyz_mux;
                10'b0110010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0110011000 : deassign_xyz_mux;
                10'b0110011010 : deassign_xyz_mux;
                10'b0110011100 : deassign_xyz_mux;
                10'b0110101000 : deassign_xyz_mux;
                10'b0110101110 : deassign_xyz_mux;
                10'b0111000000 : deassign_xyz_mux;
                10'b0111000010 : deassign_xyz_mux;
                10'b0111000100 : deassign_xyz_mux;
                10'b0111010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0111010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0111010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0111011000 : deassign_xyz_mux;
                10'b0111100000 : deassign_xyz_mux;
                10'b0111100010 : deassign_xyz_mux;
                10'b0111110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b0111111000 : deassign_xyz_mux;
                10'b1001000010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1010000000 : deassign_xyz_mux;
                10'b1010010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1010010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1010010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1010011000 : deassign_xyz_mux;
                10'b1010011001 : deassign_xyz_mux;
                10'b1010011011 : deassign_xyz_mux;
                10'b1010101000 : deassign_xyz_mux;
                10'b1010101001 : deassign_xyz_mux;
                10'b1010101011 : deassign_xyz_mux;
                10'b1010101110 : deassign_xyz_mux;
                10'b1011000000 : deassign_xyz_mux;
                10'b1011010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011010111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011011000 : deassign_xyz_mux;
                10'b1011011001 : deassign_xyz_mux;
                10'b1011011011 : deassign_xyz_mux;
                10'b1011100000 : deassign_xyz_mux;
                10'b1011100001 : deassign_xyz_mux;
                10'b1011100011 : deassign_xyz_mux;
                10'b1011110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011110001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011110011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1011111000 : deassign_xyz_mux;
                10'b1011111001 : deassign_xyz_mux;
                10'b1011111011 : deassign_xyz_mux;
                10'b1100000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100011000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100011101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100011111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100101000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100101101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1100101111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101010000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101011000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101011101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101011111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101100000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101100101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101100111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101110101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101110111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101111101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                10'b1101111111 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                default : begin
                              if (invalid_opmode) begin

                                  opmode_valid_flag = 0;
                                  invalid_opmode = 0;
// CR 444150
                                  if( ({qopmode_o_mux, qcarryinsel_o_mux} ==  10'b0000000010) && ((OPMODEREG==1) && (CARRYINSELREG ==0)) )
                                     $display("DRC warning : The attribute CARRYINSELREG on DSP48E1 instance %m is set to %d. It is required to have CARRYINSELREG be set to 1 to match OPMODEREG, in order to ensure that the simulation model will match the hardware behavior in all use cases.", CARRYINSELREG);

                                                 

                                  $display("OPMODE Input Warning : The OPMODE %b to DSP48E1 instance %m is either invalid or the CARRYINSEL %b for that specific OPMODE is invalid at %.3f ns. This warning may be due to a mismatch in the OPMODEREG and CARRYINSELREG attribute settings. It is recommended that OPMODEREG and CARRYINSELREG always be set to the same value. ", qopmode_o_mux, qcarryinsel_o_mux, $time/1000.0);

                              end
                          end

            endcase // case(OPMODE)

          2'b01, 2'b11 :
          //-- LOGIC MODES DRC
             case (qopmode_o_mux)
                7'b0000000 : deassign_xyz_mux;
                7'b0000010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0000011 : deassign_xyz_mux;
                7'b0010000 : deassign_xyz_mux;
                7'b0010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0010011 : deassign_xyz_mux;
                7'b0100000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0100010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0100011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0110000 : deassign_xyz_mux;
                7'b0110010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0110011 : deassign_xyz_mux;
                7'b1010000 : deassign_xyz_mux;
                7'b1010010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1010011 : deassign_xyz_mux;
                7'b1100000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1100010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1100011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0001000 : deassign_xyz_mux;
                7'b0001010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0001011 : deassign_xyz_mux;
                7'b0011000 : deassign_xyz_mux;
                7'b0011010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0011011 : deassign_xyz_mux;
                7'b0101000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0101010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0101011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0111000 : deassign_xyz_mux;
                7'b0111010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b0111011 : deassign_xyz_mux;
                7'b1011000 : deassign_xyz_mux;
                7'b1011010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1011011 : deassign_xyz_mux;
                7'b1101000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1101010 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
                7'b1101011 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
              default : begin
                 if (invalid_opmode) begin

                    opmode_valid_flag = 0;
                    invalid_opmode = 0;
                    $display("OPMODE Input Warning : The OPMODE %b to DSP48E1 instance %m is invalid for LOGIC MODES at %.3f ns.", qopmode_o_mux, $time/1000.0);

                 end
              end

            endcase // case(OPMODE)

        endcase // case(qalumode_o_mux)

     end // if ($time > 100000)

    end // always @ (qopmode_o_mux)


//--####################################################################
//--#####                         ALU                              #####
//--####################################################################

  wire mult_cout = ~qp_o_mux[42];
  reg  [MSB_ALU_FULL:0] co;
  reg  [MSB_ALU_FULL:0] s;
  wire [MSB_ALU_FULL:0] comux,smux;
  wire [MSB_CARRYOUT:0] carryout_o_hw;
  wire [MSB_CARRYOUT:0] carryout_o;
  wire tmp_carrycascout_in;

  always @ (qx_o_mux or qy_o_mux or qz_o_mux or qalumode_o_mux[0]) begin
    if (qalumode_o_mux[0]) begin
       co = ((qx_o_mux & qy_o_mux)|((~qz_o_mux) & qy_o_mux)|(qx_o_mux & (~qz_o_mux)));
       s  = (~qz_o_mux) ^ qx_o_mux ^ qy_o_mux;
    end
    else begin
       co = ((qx_o_mux & qy_o_mux)|(qz_o_mux & qy_o_mux)|(qx_o_mux & qz_o_mux));
       s  =  qz_o_mux ^ qx_o_mux ^ qy_o_mux;
    end
  end

  assign comux = qalumode_o_mux[2] ? 0 : co;
  assign smux = qalumode_o_mux[3] ? co : s;

  // FINAL ADDER
  wire [12:0] s0 = {comux[10:0],qcarryin_o_mux}+smux[11:0];
  wire cout0 = (comux[11] + s0[12]);
  assign carryout_o_hw[0] = (qalumode_o_mux[0] & qalumode_o_mux[1]) ? ~cout0 : cout0;
  wire C1 = (USE_SIMD == "FOUR12") ? 1'b0 : s0[12];

  wire co11_lsb = (USE_SIMD == "FOUR12") ? 1'b0 : comux[11];
  wire [12:0] s1 = {comux[22:12],co11_lsb}+smux[23:12]+C1;
  wire cout1 = (comux[23] + s1[12]);
  assign carryout_o_hw[1] = (qalumode_o_mux[0] & qalumode_o_mux[1]) ? ~cout1 : cout1;
  wire C2 = ((USE_SIMD == "TWO24") || (USE_SIMD == "FOUR12")) ? 1'b0 : s1[12];

  wire co23_lsb = ((USE_SIMD == "TWO24") || (USE_SIMD == "FOUR12")) ? 
       1'b0 : comux[23];

  wire [12:0] s2 = {comux[34:24],co23_lsb}+smux[35:24]+C2;
  wire cout2 = (comux[35] + s2[12]);
  assign carryout_o_hw[2] = (qalumode_o_mux[0] & qalumode_o_mux[1]) ? ~cout2 : cout2;
  wire C3 = (USE_SIMD == "FOUR12") ? 1'b0 : s2[12];

  wire co35_lsb = (USE_SIMD == "FOUR12") ? 1'b0 : comux[35];
  wire [13:0] s3 = {comux[47:36],co35_lsb}+smux[47:36]+C3;
  wire cout3 = s3[12];

  assign carryout_o_hw[3] = (qalumode_o_mux[0] & qalumode_o_mux[1]) ? ~cout3 : cout3;

  wire   cout4 = s3[13];
//  assign carryout_o_hw[4] = (qalumode_o_mux[0] & qalumode_o_mux[1]) ? ~cout4 : cout4;

  assign alu_o  = qalumode_o_mux[1] ? ~{s3[11:0],s2[11:0],s1[11:0],s0[11:0]} :
                                {s3[11:0],s2[11:0],s1[11:0],s0[11:0]};
  // COMPUTE CARRYCASCOUT
  assign carrycascout_o = cout3;
  
  // COMPUTE MULTSIGNOUT
  // 08-06-08  assign  multsignout_o_opmode = (qopmode_o_mux[3:0] === 4'b100) ? MULTSIGNIN  : ~qp_o_mux[42];
  // IR 478378 
  assign  multsignout_o_opmode = (qopmode_o_mux[6:4] === 3'b100) ? MULTSIGNIN  : qmult_o_mux[42];

  // CR 523600 -- "X" carryout for multiply and logic operations
    assign carryout_o[3] = ((qopmode_o_mux[3:0] == 4'b0101) || (qalumode_o_mux[3:2] != 2'b00))? 1'bx : carryout_o_hw[3];
    assign carryout_o[2] = ((qopmode_o_mux[3:0] == 4'b0101) || (qalumode_o_mux[3:2] != 2'b00))? 1'bx : (USE_SIMD == "FOUR12") ? carryout_o_hw[2] : 1'bx;
    assign carryout_o[1] = ((qopmode_o_mux[3:0] == 4'b0101) || (qalumode_o_mux[3:2] != 2'b00))? 1'bx : ((USE_SIMD == "TWO24") ||  (USE_SIMD == "FOUR12")) ? carryout_o_hw[1] : 1'bx;
    assign carryout_o[0] = ((qopmode_o_mux[3:0] == 4'b0101) || (qalumode_o_mux[3:2] != 2'b00))? 1'bx : (USE_SIMD == "FOUR12") ? carryout_o_hw[0] : 1'bx;

//--########################### END ALU ################################
 
    
//*** CarryIn Mux and Register

//-------  input 0
    always @(posedge CLK) begin
	if (RSTALLCARRYIN)
            qcarryin_o_reg0 <= 1'b0;
	else if (CECARRYIN)
            qcarryin_o_reg0 <= CARRYIN;
    end

    generate
       case (CARRYINREG)
          0 : always @(CARRYIN) qcarryin_o_mux0 <= CARRYIN;
          1 : always @(qcarryin_o_reg0) qcarryin_o_mux0 <= qcarryin_o_reg0;
       endcase
    endgenerate

//-------  input 7
    always @(posedge CLK) begin
	if (RSTALLCARRYIN)
            qcarryin_o_reg7 <= 1'b0;
// old	else if (CEMULTCARRYIN)
// new
	else if (CEM)
// IR 478377 
            qcarryin_o_reg7 <=  ad_mult[24] ~^ b_mult[17];  // xnor
    end

//    always @(qa_o_mux[24] or qb_o_mux[17] or qcarryin_o_reg7) begin
    always @(ad_mult[24] or b_mult[17] or qcarryin_o_reg7) begin
// old	case (MULTCARRYINREG)
// new 
	case (MREG)
// IR 478377 
                  0 : qcarryin_o_mux7 <= ad_mult[24] ~^ b_mult[17];
                  1 : qcarryin_o_mux7 <= qcarryin_o_reg7;
            default : begin
	                  $display("Attribute Syntax Error : The attribute MREG on DSP48E1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", MREG);
	                  $finish;
	              end
	endcase
    end
   
    reg qcarryin_o_mux_tmp;
    always @(qcarryin_o_mux0 or PCIN[47] or CARRYCASCIN or carrycascout_o_mux or qp_o_mux[47] or qcarryin_o_mux7 or qcarryinsel_o_mux) begin
	case (qcarryinsel_o_mux)
              3'b000 : qcarryin_o_mux_tmp <= qcarryin_o_mux0;
              3'b001 : qcarryin_o_mux_tmp <= ~PCIN[47];
              3'b010 : qcarryin_o_mux_tmp <= CARRYCASCIN;
              3'b011 : qcarryin_o_mux_tmp <= PCIN[47];
              3'b100 : qcarryin_o_mux_tmp <= carrycascout_o_mux;
              3'b101 : qcarryin_o_mux_tmp <= ~qp_o_mux[47];
              3'b110 : qcarryin_o_mux_tmp <= qcarryin_o_mux7;
              3'b111 : qcarryin_o_mux_tmp <= qp_o_mux[47];
            default : begin
	              end
	endcase
    end
    // disable carryin when performing logic operation
    always @(qcarryin_o_mux_tmp or qalumode_o_mux[3:2]) begin
      qcarryin_o_mux <= (qalumode_o_mux[3] || qalumode_o_mux[2]) ? 1'b0 : qcarryin_o_mux_tmp;
    end
 

//--####################################################################
//--#####                     AUTORESET_PATDET                     #####
//--####################################################################
    assign the_auto_reset_patdet = ((AUTORESET_PATDET == "RESET_MATCH") &&  pdet_o_reg1) 
                                                   ||
                                   ((AUTORESET_PATDET == "RESET_NOT_MATCH") &&  (pdet_o_reg2 && !pdet_o_reg1));
//--####################################################################
//--#####      CARRYOUT, CARRYCASCOUT. MULTSIGNOUT and PCOUT      ###### 
//--####################################################################
//*** register with 1 level of register
    always @(posedge CLK) begin
        if(RSTP || the_auto_reset_patdet)
             begin
               carryout_o_reg     <= 4'b0;
               carrycascout_o_reg <= 1'b0;
               qmultsignout_o_reg <= 1'b0;
               qp_o_reg1 <= 48'b0;
             end
        else if (CEP) begin
                   carryout_o_reg     <= carryout_o;
                   carrycascout_o_reg <= carrycascout_o;
                   qmultsignout_o_reg <= multsignout_o_opmode;
                   qp_o_reg1 <= alu_o;
             end
    end

    generate 
       case (PREG)
          0: begin 
             always @(carryout_o)
                carryout_o_mux <= carryout_o;
             always @(carrycascout_o)
                carrycascout_o_mux <= carrycascout_o;
             always @(multsignout_o_opmode)
                 multsignout_o_mux <= multsignout_o_opmode;
             always @(alu_o)
                 qp_o_mux <= alu_o;
	  end

          1: begin 
             always @(carryout_o_reg)
                carryout_o_mux <= carryout_o_reg;
             always @(carrycascout_o_reg)
                carrycascout_o_mux <= carrycascout_o_reg;
             always @(qmultsignout_o_reg)
                 multsignout_o_mux <= qmultsignout_o_reg;
             always @(qp_o_reg1)
                 qp_o_mux <= qp_o_reg1;
	  end
       endcase
    endgenerate



//CR 219047 (2)
// ask jmt whether i should comment this out 
/*
    always @(qmult_o_mux[(MSB_A_MULT+MSB_B_MULT+1)] or qopmode_o_mux[3:0]) begin
        if(qopmode_o_mux[3:0] == 4'b0101)
           multsignout_o_opmode = qmult_o_mux[(MSB_A_MULT+MSB_B_MULT+1)];
        else
           multsignout_o_opmode = 1'bx;
    end 
*/



//    assign carryout_x_o[4] =  carryout_o_mux[4];
// CR 510304 output X during multiply operation

    assign carryout_x_o[3] =  carryout_o_mux[3];
    assign carryout_x_o[2] =  (USE_SIMD == "FOUR12") ? carryout_o_mux[2] : 1'bx;
    assign carryout_x_o[1] =  ((USE_SIMD == "TWO24") ||  (USE_SIMD == "FOUR12")) ? carryout_o_mux[1] : 1'bx;
    assign carryout_x_o[0] =  (USE_SIMD == "FOUR12") ? carryout_o_mux[0] : 1'bx;


//--####################################################################
//--#####                    Pattern Detector                      #####
//--####################################################################


// new
    // selet pattern
    assign the_pattern = (SEL_PATTERN == "PATTERN") ? PATTERN : qc_o_mux; 

    // selet mask
    always @(qc_o_mux) begin
        case(SEL_MASK)
              "MASK" : the_mask <= MASK;
              "C"    : the_mask <= qc_o_mux;
              "ROUNDING_MODE1" :  the_mask     <=   ~qc_o_mux << 1;
              "ROUNDING_MODE2" :  the_mask     <=   ~qc_o_mux << 2;
               default : ;
        endcase
    end

    //--  now do the pattern detection
       
    assign pdet_o = &(~(the_pattern ^ alu_o) | the_mask);  
    assign pdetb_o = &((the_pattern ^ alu_o) | the_mask);  

    assign pdet_o_mux  = (~opmode_valid_flag) ? 1'bx : (PREG == 1) ? pdet_o_reg1 : pdet_o;
    assign pdetb_o_mux = (~opmode_valid_flag) ? 1'bx : (PREG == 1) ? pdetb_o_reg1 : pdetb_o;

//*** Output register PATTERN DETECT and UNDERFLOW / OVERFLOW 

    always @(posedge CLK) begin
        if((RSTP) || the_auto_reset_patdet) 
          begin 
            pdet_o_reg1  <= 1'b0;
            pdet_o_reg2  <= 1'b0;
            pdetb_o_reg1 <= 1'b0;
            pdetb_o_reg2 <= 1'b0;
          end
	else if(CEP)
               begin
                 //-- the previous values are used in Underflow/Overflow
                 pdet_o_reg2  <= pdet_o_reg1;
                 pdet_o_reg1  <= pdet_o;
                 pdetb_o_reg2 <= pdetb_o_reg1;
                 pdetb_o_reg1 <= pdetb_o;
               end
    end

 
//--####################################################################
//--#####                    Underflow / Overflow                  #####
//--####################################################################
    generate if ((USE_PATTERN_DETECT == "PATDET") || (PREG == 1))
       begin         
          assign  overflow_o  = pdet_o_reg2 & !pdet_o_reg1 & !pdetb_o_reg1;
          assign  underflow_o = pdetb_o_reg2  & !pdet_o_reg1 & !pdetb_o_reg1;
       end
    else
       begin         
           assign overflow_o  = 1'bx;
           assign underflow_o = 1'bx;
       end
    endgenerate




    assign ACOUT = qacout_o_mux;
    assign BCOUT = qbcout_o_mux;
    assign CARRYCASCOUT = carrycascout_o_mux;
    assign CARRYOUT     = carryout_x_o;
    assign MULTSIGNOUT  = multsignout_o_mux;
    assign OVERFLOW     = overflow_o;
    assign P            = qp_o_mux;
    assign PCOUT        = qp_o_mux;
    assign PATTERNDETECT = pdet_o_mux;
    assign PATTERNBDETECT = pdetb_o_mux;
    assign UNDERFLOW     = underflow_o;
    specify

        (CLK *> ACOUT) = (100, 100);
        (CLK *> BCOUT) = (100, 100);
        (CLK *> CARRYCASCOUT)      = (100, 100);
        (CLK *> CARRYOUT)       = (100, 100);
        (CLK *> MULTSIGNOUT)       = (100, 100);
        (CLK *> OVERFLOW)       = (100, 100);
        (CLK *> P) = (100, 100);
        (CLK *> PATTERNBDETECT) = (100, 100);
        (CLK *> PATTERNDETECT)  = (100, 100);
        (CLK *> PCOUT) = (100, 100);
        (CLK *> UNDERFLOW)      = (100, 100);

        specparam PATHPULSE$ = 0;

    endspecify

endmodule // DSP48E1

