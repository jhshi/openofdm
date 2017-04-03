///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Timing Simulation Library Component
//  /   /                  Jtag TAP Controler for Spartan6
// /___/   /\     Filename : JTAG_SIM_SPARTAN6.v
// \   \  /  \    Timestamp : Fri Jan 16 14:13:44 PST 2009
//  \___\/\___\
//
// Revision:
//    01/16/09 - Initial version.
//    04/08/09 - CR 528894 -- PART_NAME default value fix for gencomp
//    08/26/09 - CR 530869 -- PART_NAME values updated and default value changed
// End Revision

`timescale 1 ps/1 ps

module JTAG_SIM_SPARTAN6( TDO, TCK, TDI, TMS);


  output TDO;

  input TCK, TDI, TMS;
   
  reg TDO;
  reg notifier;


  parameter PART_NAME = "LX4";

  localparam       TestLogicReset	= 4'h0,
                   RunTestIdle		= 4'h1,
                   SelectDRScan		= 4'h2,
                   CaptureDR		= 4'h3,
                   ShiftDR		= 4'h4,
                   Exit1DR		= 4'h5,
                   PauseDR		= 4'h6,
                   Exit2DR		= 4'h7,
                   UpdateDR		= 4'h8,
                   SelectIRScan		= 4'h9,
                   CaptureIR		= 4'ha,
                   ShiftIR		= 4'hb,
                   Exit1IR		= 4'hc,
                   PauseIR		= 4'hd,
                   Exit2IR		= 4'he,
                   UpdateIR		= 4'hf;

   localparam DELAY_SIG = 1;
   
   reg TRST = 0;

   reg [3:0]    CurrentState = TestLogicReset;
   reg [14*8:0] jtag_state_name = "TestLogicReset";
   reg [14*8:0] jtag_instruction_name = "IDCODE";


//-----------------  Virtex4 Specific Constants ---------
  localparam IRLengthMax = 6;
  localparam IDLength    = 32;

  reg [IRLengthMax-1:0] IR_CAPTURE_VAL	= 6'b010001,
                      BYPASS_INSTR      = 6'b111111,
                      IDCODE_INSTR      = 6'b001001,
                      USER1_INSTR       = 6'b000010,
                      USER2_INSTR       = 6'b000011,
                      USER3_INSTR       = 6'b011010,
                      USER4_INSTR       = 6'b011011;

  localparam IRLength = 6;

//----------------- local reg  -------------------------------
  reg CaptureDR_sig = 0, RESET_sig = 0, ShiftDR_sig = 0, UpdateDR_sig = 0; 

  reg ClkIR_active = 0, ClkIR_sig = 0, ClkID_sig = 0; 

  reg ShiftIR_sig, UpdateIR_sig, ClkUpdateIR_sig; 
  
  reg [IRLength-1:0] IRcontent_sig;

  reg [IDLength-1:0] IDCODEval_sig;

  reg  BypassReg = 0, BYPASS_sig = 0, IDCODE_sig = 0, 
       USER1_sig = 0, USER2_sig = 0,
       USER3_sig = 0, USER4_sig = 0;

  reg TDO_latch;

  reg Tlrst_sig = 1; 
  reg TlrstN_sig = 1; 

  reg IRegLastBit_sig = 0, IDregLastBit_sig = 0;

  reg Rti_sig = 0; 
 //-------------------------------------------------------------
  reg [IRLength-1:0] NextIRreg; 
  reg [IRLength-1:0] ir_int; // = IR_CAPTURE_VAL[IRLength-1:0] ;
  reg [IDLength-1:0] IDreg;
 	
//####################################################################
//#####                     Initialize                           #####
//####################################################################
   initial begin
      case (PART_NAME)
          "LX4",          "lx4"           : IDCODEval_sig <= 32'h04000093;
          "LX9",          "lx9"           : IDCODEval_sig <= 32'h04001093;
          "LX16",         "lx16"          : IDCODEval_sig <= 32'h04002093;
          "LX25",         "lx25"          : IDCODEval_sig <= 32'h04004093;
          "LX25T",        "lx25t"         : IDCODEval_sig <= 32'h04024093;
          "LX45",         "lx45"          : IDCODEval_sig <= 32'h04008093;
          "LX45T",        "lx45t"         : IDCODEval_sig <= 32'h04028093;
          "LX75",         "lx75"          : IDCODEval_sig <= 32'h0400e093;
          "LX75T",        "lx75t"         : IDCODEval_sig <= 32'h0402e093;
          "LX100",        "lx100"         : IDCODEval_sig <= 32'h04011093;
          "LX100T",       "lx100t"        : IDCODEval_sig <= 32'h04031093;
          "LX150",        "lx150"         : IDCODEval_sig <= 32'h0401d093;
          "LX150T",       "lx150t"        : IDCODEval_sig <= 32'h0403d093;

         default : begin
                        $display("Attribute Syntax Error : The attribute PART_NAME on JTAG_SIM_SPARTAN6 instance %m is set to %s. The legal values for this attributes are LX4 or LX9 or LX16 or LX25 or LX25T or LX45 or LX45T or LX75 or LX75T or LX100 or LX100T or LX150 or LX150T", PART_NAME);

         end
       endcase // case(PART_NAME)

       ir_int <= IR_CAPTURE_VAL[IRLength-1:0];

    end // initial begin
//####################################################################
//#####                      JtagTapSM                           #####
//####################################################################
  always@(posedge TCK or posedge TRST)
     begin
       if(TRST) begin
          CurrentState = TestLogicReset;
       end
       else begin
            case(CurrentState)
 
               TestLogicReset:
                 begin
                   if(TMS == 0) begin
                      CurrentState = RunTestIdle;
                      jtag_state_name = "RunTestIdle";
                   end
                 end

               RunTestIdle:
                 begin
                   if(TMS == 1) begin
                      CurrentState = SelectDRScan;
                      jtag_state_name = "SelectDRScan";
                   end
                 end
               //-------------------------------
               // ------  DR path ---------------
               // -------------------------------
               SelectDRScan:
                 begin
                   if(TMS == 0) begin
                      CurrentState = CaptureDR;
                      jtag_state_name = "CaptureDR";
                   end
                   else if(TMS == 1) begin
                      CurrentState = SelectIRScan;
                      jtag_state_name = "SelectIRScan";
                   end
                 end
 
               CaptureDR:
                 begin
                   if(TMS == 0) begin
                      CurrentState = ShiftDR;
                      jtag_state_name = "ShiftDR";
                   end
                   else if(TMS == 1) begin
                      CurrentState = Exit1DR;
                      jtag_state_name = "Exit1DR";
                   end
                 end
              
               ShiftDR:
                 begin
                   if(IRcontent_sig == BYPASS_INSTR[(IRLength - 1): 0]) 
                      BypassReg = TDI;

                   if(TMS == 1) begin
                      CurrentState = Exit1DR;
                      jtag_state_name = "Exit1DR";
                   end
                 end
              
               Exit1DR:
                 begin
                   if(TMS == 0) begin
                      CurrentState = PauseDR;
                      jtag_state_name = "PauseDR";
                   end
                   else if(TMS == 1) begin
                      CurrentState = UpdateDR;
                      jtag_state_name = "UpdateDR";
                   end
                 end
              
               PauseDR:
                 begin
                   if(TMS == 1) begin
                      CurrentState =  Exit2DR;
                      jtag_state_name = "Exit2DR";
                   end
                 end
            
               Exit2DR:
                 begin
                   if(TMS == 0) begin
                      CurrentState = ShiftDR;
                      jtag_state_name = "ShiftDR";
                   end
                   else if(TMS == 1) begin
                      CurrentState = UpdateDR;
                      jtag_state_name = "UpdateDR";
                   end
                 end
              
               UpdateDR:
                 begin
                   if(TMS == 0) begin
                      CurrentState = RunTestIdle;
                      jtag_state_name = "RunTestIdle";
                   end
                   else if(TMS == 1) begin
                      CurrentState = SelectDRScan;
                      jtag_state_name = "SelectDRScan";
                   end
                 end
               //-------------------------------
               // ------  IR path ---------------
               // -------------------------------
               SelectIRScan:
                 begin
                   if(TMS == 0) begin
                      CurrentState = CaptureIR;
                      jtag_state_name = "CaptureIR";
                   end
                   else if(TMS == 1) begin
                      CurrentState = TestLogicReset;
                      jtag_state_name = "TestLogicReset";
                   end
                 end
 
               CaptureIR:
                 begin
                   if(TMS == 0) begin
                      CurrentState = ShiftIR;
                      jtag_state_name = "ShiftIR";
                   end
                   else if(TMS == 1) begin
                      CurrentState = Exit1IR;
                      jtag_state_name = "Exit1IR";
                   end
                  end
              
               ShiftIR:
                 begin
//                   ClkIR_sig = 1;

                   if(TMS == 1) begin
                      CurrentState = Exit1IR;
                      jtag_state_name = "Exit1IR";
                   end
                 end
             
               Exit1IR:
                 begin
                   if(TMS == 0) begin
                      CurrentState = PauseIR;
                      jtag_state_name = "PauseIR";
                   end
                   else if(TMS == 1) begin
                      CurrentState = UpdateIR;
                      jtag_state_name = "UpdateIR";
                   end
                 end
              
               PauseIR:
                 begin
                   if(TMS == 1) begin
                      CurrentState =  Exit2IR;
                      jtag_state_name = "Exit2IR";
                   end
                 end
            
               Exit2IR:
                 begin
                   if(TMS == 0) begin
                      CurrentState = ShiftIR;
                      jtag_state_name = "ShiftIR";
                   end 
                   else if(TMS == 1) begin
                      CurrentState = UpdateIR;
                      jtag_state_name = "UpdateIR";
                   end
                 end
              
               UpdateIR:
                 begin
                  //-- FP
//                   ClkIR_sig = 1;

                   if(TMS == 0) begin
                      CurrentState = RunTestIdle;
                      jtag_state_name = "RunTestIdle";
                   end
                   else if(TMS == 1) begin
                      CurrentState = SelectDRScan;
                      jtag_state_name = "SelectDRScan";
                   end
                 end
             endcase // case(CurrentState)
       end // else

     end // always

//--------------------------------------------------------
  always@(CurrentState, TCK, TRST)
  begin
      ClkIR_sig = 1;

      if(TRST == 1 ) begin
            Tlrst_sig     = #DELAY_SIG 1;
            CaptureDR_sig = #DELAY_SIG 0;
            ShiftDR_sig   = #DELAY_SIG 0;
            UpdateDR_sig  = #DELAY_SIG 0;
            ShiftIR_sig   = #DELAY_SIG 0;
            UpdateIR_sig  = #DELAY_SIG 0;
      end
      else if(TRST == 0) begin
         
         case (CurrentState)
            TestLogicReset:  begin 
                  Tlrst_sig     = #DELAY_SIG 1;
                  Rti_sig       = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
            end
            RunTestIdle:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  Rti_sig       = #DELAY_SIG 1;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
            end
            CaptureDR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  Rti_sig       = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 1;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
            end
            ShiftDR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  Rti_sig       = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 1;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
            end
            UpdateDR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  Rti_sig       = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 1;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
            end
            CaptureIR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  Rti_sig       = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
                  ClkIR_sig     = TCK;
            end
            ShiftIR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  Rti_sig       = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 1;
                  UpdateIR_sig  = #DELAY_SIG 0;
                  ClkIR_sig     = TCK;
            end
            UpdateIR: begin 
                         Tlrst_sig     = #DELAY_SIG 0;
                         Rti_sig       = #DELAY_SIG 0;
                         CaptureDR_sig = #DELAY_SIG 0;
                         ShiftDR_sig   = #DELAY_SIG 0;
                         UpdateDR_sig  = #DELAY_SIG 0;
                         ShiftIR_sig   = #DELAY_SIG 0;
                         UpdateIR_sig  = #DELAY_SIG 1;
                     end
            default: begin 
                         Tlrst_sig     = #DELAY_SIG 0;
                         Rti_sig       = #DELAY_SIG 0;
                         CaptureDR_sig = #DELAY_SIG 0;
                         ShiftDR_sig   = #DELAY_SIG 0;
                         UpdateDR_sig  = #DELAY_SIG 0;
                         ShiftIR_sig   = #DELAY_SIG 0;
                         UpdateIR_sig  = #DELAY_SIG 0;
                     end
         endcase

      end

    end // always(CurrentState)
//-----------------------------------------------------
  always@(TCK)
  begin
//       ClkIR_sig = ShiftIR_sig & TCK;
       ClkUpdateIR_sig = UpdateIR_sig & ~TCK;
  end // always
   
  always@(TCK)
  begin
       ClkID_sig = IDCODE_sig & TCK;
  end // always

// RESET 
  always@(Tlrst_sig)
  begin
     glbl.JTAG_RESET_GLBL   <= Tlrst_sig;
  end

// RUNTEST
  always@(Rti_sig)
  begin
     glbl.JTAG_RUNTEST_GLBL   <= Rti_sig;
  end
//-------------- TCK  NEGATIVE EDGE activities ----------
  always@(negedge TCK, negedge UpdateDR_sig)
  begin
     if(TCK == 0) begin
        glbl.JTAG_CAPTURE_GLBL <= CaptureDR_sig;
        glbl.JTAG_SHIFT_GLBL   <= ShiftDR_sig;
        TlrstN_sig             <= Tlrst_sig;
     end

     glbl.JTAG_UPDATE_GLBL  <= UpdateDR_sig;

  end // always

//--####################################################################
//--#####                       JtagIR                             #####
//--####################################################################
   always@(posedge ClkIR_sig) begin
      NextIRreg = {TDI, ir_int[IRLength-1:1]};

      if ((TRST== 0) && (TlrstN_sig == 0)) begin
         if(ShiftIR_sig == 1) begin 
            ir_int = NextIRreg;
            IRegLastBit_sig = ir_int[0];
         end
         else begin
            ir_int = IR_CAPTURE_VAL; 
            IRegLastBit_sig = ir_int[0];
         end
      end
   end //always 
//--------------------------------------------------------
   always@(posedge ClkUpdateIR_sig or posedge TlrstN_sig or
           posedge TRST) begin
      if ((TRST== 1) || (TlrstN_sig == 1)) begin
         IRcontent_sig = IDCODE_INSTR[(IRLength - 1): 0]; // IDCODE instr is loaded..  must verify-- FP. 
         IRegLastBit_sig = ir_int[0];
      end
      else if( (TRST == 0) && (TlrstN_sig == 0)) begin 
               IRcontent_sig = ir_int;
      end
   end //always 
//--####################################################################
//--#####                       JtagDecodeIR                       #####
//--####################################################################
   always@(IRcontent_sig) begin

      case(IRcontent_sig)

//          IR_CAPTURE_VAL : begin
//               ;
//               jtag_instruction_name = "IR_CAPTURE";
//          end

          BYPASS_INSTR[(IRLength - 1): 0] : begin
             jtag_instruction_name = "BYPASS";
             // if BYPASS instruction, set BYPASS signal to 1
             BYPASS_sig <= 1;
             IDCODE_sig <= 0;
             USER1_sig  <= 0;
             USER2_sig  <= 0;
             USER3_sig  <= 0;
             USER4_sig  <= 0;
          end

          IDCODE_INSTR[(IRLength - 1): 0] : begin
             jtag_instruction_name = "IDCODE";
             // if IDCODE instruction, set IDCODE signal to 1
             BYPASS_sig <= 0;
             IDCODE_sig <= 1;
             USER1_sig  <= 0;
             USER2_sig  <= 0;
             USER3_sig  <= 0;
             USER4_sig  <= 0;
          end

          USER1_INSTR[(IRLength - 1): 0] : begin
             jtag_instruction_name = "USER1";
             // if USER1 instruction, set USER1 signal to 1 
             BYPASS_sig <= 0;
             IDCODE_sig <= 0;
             USER1_sig  <= 1;
             USER2_sig  <= 0;
             USER3_sig  <= 0;
             USER4_sig  <= 0;
          end

          USER2_INSTR[(IRLength - 1): 0] : begin
             jtag_instruction_name = "USER2";
             // if USER2 instruction, set USER2 signal to 1 
             BYPASS_sig <= 0;
             IDCODE_sig <= 0;
             USER1_sig  <= 0;
             USER2_sig  <= 1;
             USER3_sig  <= 0;
             USER4_sig  <= 0;
          end

          USER3_INSTR[(IRLength - 1): 0] : begin
             jtag_instruction_name = "USER3";
             // if USER3 instruction, set USER3 signal to 1 
             BYPASS_sig <= 0;
             USER1_sig  <= 0;
             USER2_sig  <= 0;
             IDCODE_sig <= 0;
             USER3_sig  <= 1;
             USER4_sig  <= 0;
           end

          USER4_INSTR[(IRLength - 1): 0] : begin
             jtag_instruction_name = "USER4";
             // if USER4 instruction, set USER4 signal to 1 
             BYPASS_sig <= 0;
             IDCODE_sig <= 0;
             USER1_sig  <= 0;
             USER2_sig  <= 0;
             USER3_sig  <= 0;
             USER4_sig  <= 1;
          end
          default : begin
             jtag_instruction_name = "UNKNOWN";
             // if UNKNOWN instruction, set all signals to 0 
             BYPASS_sig <= 0;
             IDCODE_sig <= 0;
             USER1_sig  <= 0;
             USER2_sig  <= 0;
             USER3_sig  <= 0;
             USER4_sig  <= 0;
          end

      endcase
   end //always
//--####################################################################
//--#####                       JtagIDCODE                         #####
//--####################################################################
   always@(posedge ClkID_sig) begin
//     reg [(IDLength -1) : 0] IDreg;
     if(ShiftDR_sig == 1) begin
        IDreg = IDreg >> 1;
        IDreg[IDLength -1] = TDI;
     end
     else
        IDreg = IDCODEval_sig;

     IDregLastBit_sig = IDreg[0];
   end // always

//--####################################################################
//--#####                    JtagSetGlobalSignals                  #####
//--####################################################################
   always@(ClkUpdateIR_sig, Tlrst_sig, USER1_sig, USER2_sig, USER3_sig, USER4_sig) begin
      if(Tlrst_sig == 1) begin 
         glbl.JTAG_SEL1_GLBL <= 0;
         glbl.JTAG_SEL2_GLBL <= 0;
         glbl.JTAG_SEL3_GLBL <= 0;
         glbl.JTAG_SEL4_GLBL <= 0;
      end
      else if(Tlrst_sig == 0) begin
              if(USER1_sig == 1) begin
                 glbl.JTAG_SEL1_GLBL <= USER1_sig;
                 glbl.JTAG_SEL2_GLBL <= 0;
                 glbl.JTAG_SEL3_GLBL <= 0;
                 glbl.JTAG_SEL4_GLBL <= 0;
              end
              else if(USER2_sig == 1) begin
                 glbl.JTAG_SEL1_GLBL <= 0;
                 glbl.JTAG_SEL2_GLBL <= 1;
                 glbl.JTAG_SEL3_GLBL <= 0;
                 glbl.JTAG_SEL4_GLBL <= 0;
              end
              else if(USER3_sig == 1) begin
                 glbl.JTAG_SEL1_GLBL <= 0;
                 glbl.JTAG_SEL2_GLBL <= 0;
                 glbl.JTAG_SEL3_GLBL <= 1;
                 glbl.JTAG_SEL4_GLBL <= 0;
              end
              else if(USER4_sig == 1) begin
                 glbl.JTAG_SEL1_GLBL <= 0;
                 glbl.JTAG_SEL2_GLBL <= 0;
                 glbl.JTAG_SEL3_GLBL <= 0;
                 glbl.JTAG_SEL4_GLBL <= 1;
              end
              else if(ClkUpdateIR_sig == 1) begin
                 glbl.JTAG_SEL1_GLBL <= 0;
                 glbl.JTAG_SEL2_GLBL <= 0;
                 glbl.JTAG_SEL3_GLBL <= 0;
                 glbl.JTAG_SEL4_GLBL <= 0;
              end

      end
       
   end //always

//--####################################################################
//--#####                         OUTPUT                           #####
//--####################################################################
  assign glbl.JTAG_TDI_GLBL = TDI;
  assign glbl.JTAG_TCK_GLBL = TCK;
  assign glbl.JTAG_TMS_GLBL = TMS;

  always@(CurrentState, IRcontent_sig, BypassReg,
          IRegLastBit_sig, IDregLastBit_sig,  glbl.JTAG_USER_TDO1_GLBL,
          glbl.JTAG_USER_TDO2_GLBL, glbl.JTAG_USER_TDO3_GLBL, 
          glbl.JTAG_USER_TDO4_GLBL) 
  begin
      case (CurrentState)
         ShiftIR:  begin
                      TDO_latch <= IRegLastBit_sig;
                   end 
         ShiftDR:  begin
                      if(IRcontent_sig == IDCODE_INSTR[(IRLength - 1): 0]) 
                          TDO_latch <= IDregLastBit_sig;
                      else if(IRcontent_sig == BYPASS_INSTR[(IRLength - 1): 0]) 
                          TDO_latch <= BypassReg; 
                      else if(IRcontent_sig == USER1_INSTR[(IRLength - 1): 0]) 
                          TDO_latch <= glbl.JTAG_USER_TDO1_GLBL; 
                      else if(IRcontent_sig == USER2_INSTR[(IRLength - 1): 0]) 
                          TDO_latch <= glbl.JTAG_USER_TDO2_GLBL; 
                      else if(IRcontent_sig == USER3_INSTR[(IRLength - 1): 0]) 
                          TDO_latch <= glbl.JTAG_USER_TDO3_GLBL; 
                      else if(IRcontent_sig == USER4_INSTR[(IRLength - 1): 0]) 
                          TDO_latch <= glbl.JTAG_USER_TDO4_GLBL; 
                      else
                          TDO_latch <= 1'bz;
                      end 
         default : begin
                          TDO_latch <= 1'bz;
                   end
      endcase // case(PART_NAME)
  end // always

  always@(negedge TCK)
  begin
// 213980 NCsim compile error fix
     TDO <= # 6000 TDO_latch;
  end // always
   
//--####################################################################
//--#####                         Timing                           #####
//--####################################################################

  specify
// 213980 NCsim compile error fix
//     (TCK => TDO) = (6000:6000:6000, 6000:6000:6000);
    
     $setuphold (posedge TCK, posedge TDI , 1000:1000:1000, 2000:2000:2000, notifier);
     $setuphold (posedge TCK, negedge TDI , 1000:1000:1000, 2000:2000:2000, notifier);

     $setuphold (posedge TCK, posedge TMS , 1000:1000:1000, 2000:2000:2000, notifier);
     $setuphold (posedge TCK, negedge TMS , 1000:1000:1000, 2000:2000:2000, notifier);
  endspecify

endmodule // JTAG_SIM_SPARTAN6
