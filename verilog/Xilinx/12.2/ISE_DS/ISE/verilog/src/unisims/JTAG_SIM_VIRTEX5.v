///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Timing Simulation Library Component
//  /   /                  Jtag TAP Controler
// /___/   /\     Filename : JTAG_SIM_VIRTEX5.v
// \   \  /  \    Timestamp : Tue Nov  1 14:38:19 PST 2005
//  \___\/\___\
//
// Revision:
//    11/01/05 - Initial version.
//    06/04/08 - CR 473578 fix. Made PartNames consistent by removing  "5V" from the prefix.
//    09/14/08 - CR 481520 -- added global TMS
//    02/17/09 - CR 508358 -- Added support for SXT, FXT and TXT devices 
// End Revision

`timescale 1 ps/1 ps

module JTAG_SIM_VIRTEX5( TDO, TCK, TDI, TMS );


  output TDO;

  input TCK, TDI, TMS;
   
  reg TDO;
  reg notifier;


  parameter PART_NAME = "LX30";

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
  localparam IRLengthMax = 14;
  localparam IDLength    = 32;

  reg [IRLengthMax-1:0] IR_CAPTURE_VAL	= 14'b11111111010001,
                      BYPASS_INSTR      = 14'b11111111111111,
                      IDCODE_INSTR      = 14'b11111111001001,
                      USER1_INSTR       = 14'b11111111000010,
                      USER2_INSTR       = 14'b11111111000011,
                      USER3_INSTR       = 14'b11111111100010,
                      USER4_INSTR       = 14'b11111111100011;
/*
  localparam IRLength = ((PART_NAME   == "LX30")  || (PART_NAME   == "lx30")  ||
        (PART_NAME   == "LX50")   || (PART_NAME   == "lx50")   ||
        (PART_NAME   == "LX85")   || (PART_NAME   == "lx85")   ||
        (PART_NAME   == "LX110")  || (PART_NAME   == "lx110")  ||
        (PART_NAME   == "LX220")  || (PART_NAME   == "lx220")  ||
        (PART_NAME   == "LX330")  || (PART_NAME   == "lx330")  ||
        (PART_NAME   == "LX30T")  || (PART_NAME   == "lx30t")  ||
        (PART_NAME   == "LX50T")  || (PART_NAME   == "lx50t")  ||
        (PART_NAME   == "LX85T")  || (PART_NAME   == "lx85t")  ||
        (PART_NAME   == "LX110T") || (PART_NAME   == "lx110t") ||
        (PART_NAME   == "LX220T") || (PART_NAME   == "lx220t") ||
        (PART_NAME   == "LX330T") || (PART_NAME   == "lx330t")) ? 10 : 14;
*/
  localparam IRLength = (
        (PART_NAME   == "FX30T")        || (PART_NAME   == "fx30t")     ||
        (PART_NAME   == "FX70T")        || (PART_NAME   == "fx70t")     ||
        (PART_NAME   == "LX110")        || (PART_NAME   == "lx110")     ||
        (PART_NAME   == "LX110T")       || (PART_NAME   == "lx110t")    ||
        (PART_NAME   == "LX155")        || (PART_NAME   == "lx155")     ||
        (PART_NAME   == "LX155T")       || (PART_NAME   == "lx155t")    ||
        (PART_NAME   == "LX20T")        || (PART_NAME   == "lx20t")     ||
        (PART_NAME   == "LX220")        || (PART_NAME   == "lx220")     ||
        (PART_NAME   == "LX220T")       || (PART_NAME   == "lx220t")    ||
        (PART_NAME   == "LX30")         || (PART_NAME   == "lx30")      ||
        (PART_NAME   == "LX30T")        || (PART_NAME   == "lx30t")     ||
        (PART_NAME   == "LX330")        || (PART_NAME   == "lx330")     ||
        (PART_NAME   == "LX330T")       || (PART_NAME   == "lx330t")    ||
        (PART_NAME   == "LX50")         || (PART_NAME   == "lx50")      ||
        (PART_NAME   == "LX50T")        || (PART_NAME   == "lx50t")     ||
        (PART_NAME   == "LX85")         || (PART_NAME   == "lx85")      ||
        (PART_NAME   == "LX85T")        || (PART_NAME   == "lx85t")     ||
        (PART_NAME   == "SX240T")       || (PART_NAME   == "sx240t")    ||
        (PART_NAME   == "SX35T")        || (PART_NAME   == "sx35t")     ||
        (PART_NAME   == "SX50T")        || (PART_NAME   == "sx50t")     ||
        (PART_NAME   == "SX95T")        || (PART_NAME   == "sx95t")     ||
        (PART_NAME   == "TX150T")       || (PART_NAME   == "tx150t")    ||
        (PART_NAME   == "TX240T")       || (PART_NAME   == "tx240t")) ? 10 : 14;

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

 //-------------------------------------------------------------
  reg [IRLength-1:0] NextIRreg; 
  reg [IRLength-1:0] ir_int; // = IR_CAPTURE_VAL[IRLength-1:0] ;
  reg [IDLength-1:0] IDreg;
 	
//####################################################################
//#####                     Initialize                           #####
//####################################################################
   initial begin
      case (PART_NAME)
                "FX100T",       "fx100t"        : IDCODEval_sig <= 32'h032d8093;
                "FX130T",       "fx130t"        : IDCODEval_sig <= 32'h03300093;
                "FX200T",       "fx200t"        : IDCODEval_sig <= 32'h03334093;
                "FX30T",        "fx30t"         : IDCODEval_sig <= 32'h03276093;
                "FX70T",        "fx70t"         : IDCODEval_sig <= 32'h032c6093;
                "LX110",        "lx110"         : IDCODEval_sig <= 32'h028d6093;
                "LX110T",       "lx110t"        : IDCODEval_sig <= 32'h02ad6093;
                "LX155",        "lx155"         : IDCODEval_sig <= 32'h028ec093;
                "LX155T",       "lx155t"        : IDCODEval_sig <= 32'h02aec093;
                "LX20T",        "lx20t"         : IDCODEval_sig <= 32'h02a56093;
                "LX220",        "lx220"         : IDCODEval_sig <= 32'h0290c093;
                "LX220T",       "lx220t"        : IDCODEval_sig <= 32'h02b0c093;
                "LX30",         "lx30"          : IDCODEval_sig <= 32'h0286e093;
                "LX30T",        "lx30t"         : IDCODEval_sig <= 32'h02a6e093;
                "LX330",        "lx330"         : IDCODEval_sig <= 32'h0295c093;
                "LX330T",       "lx330t"        : IDCODEval_sig <= 32'h02b5c093;
                "LX50",         "lx50"          : IDCODEval_sig <= 32'h02896093;
                "LX50T",        "lx50t"         : IDCODEval_sig <= 32'h02a96093;
                "LX85",         "lx85"          : IDCODEval_sig <= 32'h028ae093;
                "LX85T",        "lx85t"         : IDCODEval_sig <= 32'h02aae093;
                "SX240T",       "sx240t"        : IDCODEval_sig <= 32'h02f3e093;
                "SX35T",        "sx35t"         : IDCODEval_sig <= 32'h02e72093;
                "SX50T",        "sx50t"         : IDCODEval_sig <= 32'h02e9a093;
                "SX95T",        "sx95t"         : IDCODEval_sig <= 32'h02ece093;
                "TX150T",       "tx150t"        : IDCODEval_sig <= 32'h04502093;
                "TX240T",       "tx240t"        : IDCODEval_sig <= 32'h0453e093;
         default : begin
                        $display("Attribute Syntax Error : The attribute PART_NAME on JTAG_SIM_VIRTEX5 instance %m is set to %s. The legal values for this attributes are FX100T or FX130T or FX200T or FX30T or FX70T or LX110 or LX110T or LX155 or LX155T or LX20T or LX220 or LX220T or LX30 or LX30T or LX330 or LX330T or LX50 or LX50T or LX85 or LX85T or SX240T or SX35T or SX50T or SX95T or TX150T or TX240TT", PART_NAME);
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
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
            end
            CaptureDR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 1;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
            end
            ShiftDR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 1;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
            end
            UpdateDR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 1;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
            end
            CaptureIR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 0;
                  UpdateIR_sig  = #DELAY_SIG 0;
                  ClkIR_sig     = TCK;
            end
            ShiftIR:  begin 
                  Tlrst_sig     = #DELAY_SIG 0;
                  CaptureDR_sig = #DELAY_SIG 0;
                  ShiftDR_sig   = #DELAY_SIG 0;
                  UpdateDR_sig  = #DELAY_SIG 0;
                  ShiftIR_sig   = #DELAY_SIG 1;
                  UpdateIR_sig  = #DELAY_SIG 0;
                  ClkIR_sig     = TCK;
            end
            UpdateIR: begin 
                         Tlrst_sig     = #DELAY_SIG 0;
                         CaptureDR_sig = #DELAY_SIG 0;
                         ShiftDR_sig   = #DELAY_SIG 0;
                         UpdateDR_sig  = #DELAY_SIG 0;
                         ShiftIR_sig   = #DELAY_SIG 0;
                         UpdateIR_sig  = #DELAY_SIG 1;
                     end
            default: begin 
                         Tlrst_sig     = #DELAY_SIG 0;
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


// CR 211377  Reset should go high in State Tlrst
  always@(Tlrst_sig)
  begin
     glbl.JTAG_RESET_GLBL   <= Tlrst_sig;
  end

//-------------- TCK  NEGATIVE EDGE activities ----------
  always@(negedge TCK, negedge UpdateDR_sig)
  begin
     if(TCK == 0) begin
        glbl.JTAG_CAPTURE_GLBL <= CaptureDR_sig;
        // CR 211377  Reset should go high in State Tlrst
        // glbl.JTAG_RESET_GLBL   <= Tlrst_sig;
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

endmodule // JTAG_SIM_VIRTEX5
