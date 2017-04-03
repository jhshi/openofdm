// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/stan/ISERDES2.v,v 1.25 2009/11/19 20:04:35 robh Exp $
//////////////////////////////////////////////////////
//  Copyright (c) 2008 Xilinx Inc.
//  All Right Reserved.
//////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : Xilinx Functional Simulation Library Component
//  /  /                         Source Synchronous Input Deserializer for the Spartan Series
// /__/   /\       Filename    : ISERDES2.v
// \  \  /  \                     
//  \__\/\__ \                   
//
//  Revision:      Date:  Comment
//       1.0:  10/10/07:  Initial version.
//       1.1:  02/29/08:  Changed name to ISERDES2
//                        removed mc_ from signal names
//       1.2:  08/15/08:  remove DQIP, DQIN per yml
//                        IR478802 force unused outputs 0 based on DATA_WIDTH
//                        IR478802 force outputs X for 1 clk after BITSLIP 
//       1.3:  08/22/08:  IR480003 Changed serialized input to DDLY by default
//                        add param to select D if desired
//       1.4:  08/27/08:  Remove DDLY, DDLY2, use D input per IO SOLN TEAM
//                        IR481178 - phase detector moved to master
//       1.5:  09/19/08:  Fix up Phase Detector
//       1.6:  09/30/08:  IR489891 Change ci_int reset
//       1.7:  10/13/08:  IR492154 Add CE0 as enable on FFs
//       1.8:  11/05/08:  add CE0 as enable on bitslip_counter
//                        fixup input/output delays
//       1.9:  11/13/08:  update specify block
//       1.10: 11/20/08:  Connect CFB0, CFB1, DFB
//       1.11: 12/11/08:  delay internal ioce by 1 ioclk
//       1.12: 01/06/09:  CR502438 sync bitslip couter to clk_int
//       1.13: 02/12/09:  CR507431 Input shift reg and bitslip changes to match HW
//       1.14: 02/26/09:  CR510115 Changes for verilog vhdl sim differences
//       1.15: 04/22/09:  CR519002 change to match HW phase detector function
//                        CR519029 change to match HW bitslip function
//       1.16: 06/03/09:  CR523941 update phase detector logic
//                        CR523212 simprim IO update and match unisim
//       1.17: 07/08/09:  CR524403 Add NONE to valid serdes_mode values
//       1.18: 11/16/09:  CR539199 Reset logic on bitslip counter. GSR vs RST.
// End Revision
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module ISERDES2 (
  CFB0,
  CFB1,
  DFB,
  FABRICOUT,
  INCDEC,
  Q1,
  Q2,
  Q3,
  Q4,
  SHIFTOUT,
  VALID,
  BITSLIP,
  CE0,
  CLK0,
  CLK1,
  CLKDIV,
  D,
  IOCE,
  RST,
  SHIFTIN
);

  parameter BITSLIP_ENABLE = "FALSE";      // TRUE, FALSE
  parameter DATA_RATE = "SDR";             // SDR, DDR      
  parameter integer DATA_WIDTH = 1;        // {1..8}
  parameter INTERFACE_TYPE = "NETWORKING"; // NETWORKING, NETWORKING_PIPELINED, RETIMED
  parameter SERDES_MODE = "NONE";        // NONE, MASTER, SLAVE 
  localparam in_delay =  1;
  localparam out_delay = 100;
  localparam clk_delay = 0;
  localparam MODULE_NAME = "ISERDES2";

  output CFB0;
  output CFB1;
  output DFB;
  output FABRICOUT;
  output INCDEC;
  output Q1;
  output Q2;
  output Q3;
  output Q4;
  output SHIFTOUT;
  output VALID;

  input BITSLIP;
  input CE0;
  input CLK0;
  input CLK1;
  input CLKDIV;
  input D;
  input IOCE;
  input RST;
  input SHIFTIN;

  pulldown( BITSLIP );
  pulldown( RST );
  pullup( CE0 );
  pullup( IOCE );

  reg BITSLIP_ENABLE_BINARY = 1'b0;
  reg DATA_RATE_BINARY = 1'b0;
  reg INTERFACE_TYPE_BINARY = 1'b0;
  reg SERDES_MODE_BINARY = 1'b0;
  reg [7:0] DATA_WIDTH_BINARY = 8'h00;

  tri0 GSR = glbl.GSR;

  reg [3:0] qout_en = 4'b0;

// FF outputs
  reg [3:0] qs, qc, qt, qg;

// CE signals
  wire ci_int;
  reg ci_int_m=0;
  reg ci_int_s=0;
  reg ci_int_m_sync=0;
  reg ci_int_s_sync=0;
  reg ioce_int=0;
  reg [6:0] io_ce_dly = 7'b0;
  reg [2:0] bitslip_counter = 8 - DATA_WIDTH + 1;

// Phase detector signals;
  reg sample = 0;
  reg  E3 = 0;
  reg  event_occured = 0, incdec_reg = 0, valid_capture = 0, incdec_capture = 0;
  reg[3:0] edge_counter = 4'h0;
  reg [1:0] drp_event = 2'b10;  // input from DRP
  reg plus1 = 1'b0;            // input from DRP
  reg gvalid = 1'b1;           // input from DRP
  reg pre_event;
  reg en_lower_baud = 1'b0;   // where ever this is coming from
  reg e3_f;
  reg incr_d;
  reg incdec_latch;       // it is a full reg, just the same name as schematic


// Attribute settings
  reg cascade_in_int = 0;
  reg [1:0] qmuxSel_int = 0;

// Internal Clock
  reg clk0_int = 0;
  reg clk1_int = 0;
  wire clk_int;

// Other signals
  reg attr_err_flag = 0;
  reg SERDES_MODE_err_flag = 0;
  reg DATA_WIDTH_err_flag = 0;
  reg DATA_RATE_err_flag = 0;
  reg BITSLIP_ENABLE_err_flag = 0;
  reg INTERFACE_TYPE_err_flag = 0;

  wire CFB0_OUTDELAY;
  wire CFB1_OUTDELAY;
  wire DFB_OUTDELAY;
  wire FABRICOUT_OUTDELAY;
  wire INCDEC_OUTDELAY;
  wire Q1_OUTDELAY;
  wire Q2_OUTDELAY;
  wire Q3_OUTDELAY;
  wire Q4_OUTDELAY;
  wire SHIFTOUT_OUTDELAY;
  wire VALID_OUTDELAY;

  wire BITSLIP_INDELAY;
  wire CE0_INDELAY;
  wire CLK0_INDELAY;
  wire CLK1_INDELAY;
  wire CLKDIV_INDELAY;
  wire D_INDELAY;
  wire GSR_INDELAY;
  wire IOCE_INDELAY;
  wire RST_INDELAY;
  wire SHIFTIN_INDELAY;
    
  wire CFB0_OUT;
  wire CFB1_OUT;
  wire DFB_OUT;
  reg FABRICOUT_OUT=0;
  reg INCDEC_OUT=0;
  reg Q1_OUT=0;
  reg Q2_OUT=0;
  reg Q3_OUT=0;
  reg Q4_OUT=0;
  reg SHIFTOUT_OUT=0;
  reg VALID_OUT=0;

  wire BITSLIP_IN;
  wire CE0_IN;
  wire CLK0_IN;
  wire CLK1_IN;
  wire CLKDIV_IN;
  wire D_IN;
  wire GSR_IN;
  wire IOCE_IN;
  wire RST_IN;
  wire SHIFTIN_IN;
    
//----------------------------------------------------------------------
//------------------------  Output Ports  ------------------------------
//----------------------------------------------------------------------
  assign #(out_delay) CFB0_OUTDELAY = CFB0_OUT;
  assign #(out_delay) CFB1_OUTDELAY = CFB1_OUT;
  assign #(out_delay) DFB_OUTDELAY = DFB_OUT;
  assign #(out_delay) FABRICOUT_OUTDELAY = FABRICOUT_OUT;
  assign #(out_delay) INCDEC_OUTDELAY = INCDEC_OUT;
  assign #(out_delay) Q1_OUTDELAY = Q1_OUT;
  assign #(out_delay) Q2_OUTDELAY = Q2_OUT;
  assign #(out_delay) Q3_OUTDELAY = Q3_OUT;
  assign #(out_delay) Q4_OUTDELAY = Q4_OUT;
  assign #(out_delay) SHIFTOUT_OUTDELAY = SHIFTOUT_OUT;
  assign #(out_delay) VALID_OUTDELAY = VALID_OUT;
  assign CFB0 = CFB0_OUTDELAY;
  assign CFB1 = CFB1_OUTDELAY;
  assign DFB = DFB_OUTDELAY;
  assign FABRICOUT = FABRICOUT_OUTDELAY;
  assign INCDEC = INCDEC_OUTDELAY;
  assign Q1 = Q1_OUTDELAY;
  assign Q2 = Q2_OUTDELAY;
  assign Q3 = Q3_OUTDELAY;
  assign Q4 = Q4_OUTDELAY;
  assign SHIFTOUT = SHIFTOUT_OUTDELAY;
  assign VALID = VALID_OUTDELAY;
//----------------------------------------------------------------------
//------------------------   Input Ports  ------------------------------
//----------------------------------------------------------------------
  assign #(clk_delay) CLK0_INDELAY = CLK0_IN;
  assign #(clk_delay) CLK1_INDELAY = CLK1_IN;
  assign #(clk_delay) CLKDIV_INDELAY = CLKDIV_IN;
  assign #(in_delay) BITSLIP_INDELAY = BITSLIP_IN;
  assign #(in_delay) CE0_INDELAY = CE0_IN;
  assign #(in_delay) D_INDELAY = D_IN;
  assign #(in_delay) IOCE_INDELAY = IOCE_IN;
  assign #(in_delay) RST_INDELAY = RST_IN;
  assign #(in_delay) GSR_INDELAY = GSR_IN;
  assign #(in_delay) SHIFTIN_INDELAY = SHIFTIN_IN;
  assign CLK0_IN = CLK0;
  assign CLK1_IN = CLK1;
  assign CLKDIV_IN = CLKDIV;
  assign BITSLIP_IN = BITSLIP;
  assign CE0_IN = CE0;
  assign D_IN = D;
  assign IOCE_IN = IOCE;
  assign RST_IN = RST;
  assign GSR_IN = GSR;
  assign SHIFTIN_IN = SHIFTIN;

  initial begin
//-------------------------------------------------
//------ INTERFACE_TYPE Check
//-------------------------------------------------
    if      (INTERFACE_TYPE == "NETWORKING")           qmuxSel_int <= 2'b01;
    else if (INTERFACE_TYPE == "NETWORKING_PIPELINED") qmuxSel_int <= 2'b10;
    else if (INTERFACE_TYPE == "RETIMED")              qmuxSel_int <= 2'b11;
    else begin
       #1;
       $display("Attribute Syntax Error : The attribute INTERFACE_TYPE on %s instance %m is set to %s.  Legal values for this attribute are NETWORKING, NETWORKING_PIPELINED or RETIMED", MODULE_NAME, INTERFACE_TYPE);
       INTERFACE_TYPE_err_flag = 1;
       end

//-------------------------------------------------
//------ BITSLIP_ENABLE Check
//-------------------------------------------------
      if      (BITSLIP_ENABLE == "TRUE")  BITSLIP_ENABLE_BINARY <= 1'b1;
      else if (BITSLIP_ENABLE == "FALSE") BITSLIP_ENABLE_BINARY <= 1'b0;
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute BITSLIP_ENABLE on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME,  BITSLIP_ENABLE);
         BITSLIP_ENABLE_err_flag = 1;
         end

//-------------------------------------------------
//----- DATA_RATE  Check
//-------------------------------------------------
      if      (DATA_RATE == "SDR") DATA_RATE_BINARY <= 1'b1;
      else if (DATA_RATE == "DDR") DATA_RATE_BINARY <= 1'b0;
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute DATA_RATE on %s instance %m is set to %s.  Legal values for this attribute are SDR or DDR", MODULE_NAME, DATA_RATE);
         DATA_RATE_err_flag = 1;
         end

//-------------------------------------------------
//----- DATA_WIDTH check
//-------------------------------------------------
      if      (DATA_WIDTH == 1) DATA_WIDTH_BINARY = 8'b10000000;
      else if (DATA_WIDTH == 2) DATA_WIDTH_BINARY = 8'b11000000;
      else if (DATA_WIDTH == 3) DATA_WIDTH_BINARY = 8'b11100000;
      else if (DATA_WIDTH == 4) DATA_WIDTH_BINARY = 8'b11110000;
      else if (DATA_WIDTH == 5) DATA_WIDTH_BINARY = 8'b11111000;
      else if (DATA_WIDTH == 6) DATA_WIDTH_BINARY = 8'b11111100;
      else if (DATA_WIDTH == 7) DATA_WIDTH_BINARY = 8'b11111110;
      else if (DATA_WIDTH == 8) DATA_WIDTH_BINARY = 8'b11111111;
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute DATA_WIDTH on %s instance %m is set to %d.  Legal values for this attribute are 1, 2, 3, 4, 5, 6, 7 or 8.", MODULE_NAME, DATA_WIDTH);
         DATA_WIDTH_err_flag = 1;
         end

//-------------------------------------------------
//------ SERDES_MODE Check
//-------------------------------------------------
      if      (SERDES_MODE == "NONE") SERDES_MODE_BINARY <= 1'b0;
      else if (SERDES_MODE == "MASTER") SERDES_MODE_BINARY <= 1'b0;
      else if (SERDES_MODE == "SLAVE")  SERDES_MODE_BINARY <= 1'b1;
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute SERDES_MODE on %s instance %m is set to %s.  Legal values for this attribute are NONE, MASTER or SLAVE", MODULE_NAME, SERDES_MODE);
         SERDES_MODE_err_flag = 1;
         end

//-------------------------------------------------
//------        Other Initializations      --------
//-------------------------------------------------
    if (DATA_WIDTH > 4 && SERDES_MODE == "SLAVE") 
        cascade_in_int <= 1;
    else
        cascade_in_int <= 0;

    if (SERDES_MODE == "SLAVE") 
       qout_en = DATA_WIDTH_BINARY[3:0];
    else
       qout_en = DATA_WIDTH_BINARY[7:4];

   if ( SERDES_MODE_err_flag || DATA_WIDTH_err_flag ||
        DATA_RATE_err_flag || BITSLIP_ENABLE_err_flag ||
        INTERFACE_TYPE_err_flag)
      begin
      attr_err_flag = 1;
      #1;
      $display("Attribute Errors detected : Simulation cannot continue. Exiting. \n");
      $finish;
      end

    end  // initial begin

//-----------------------------------------------------------------------------------
//*** GLOBAL hidden GSR pin
    always @(GSR_INDELAY or RST_INDELAY) begin
        if ((GSR_INDELAY == 1'b1) || (RST_INDELAY ==  1'b1)) begin
           assign qs = 4'b0;
           assign qc = 4'b0;
           assign qt = 4'b0;
           assign qg = 4'b0;
        end
        else if ((GSR_INDELAY == 1'b0) && (RST_INDELAY ==  1'b0)) begin
           deassign qs;
           deassign qc;
           deassign qt;
           deassign qg;
        end
    end
// =====================
// DDR doubler
// =====================
    always @(posedge CLK0_INDELAY) begin
            clk0_int = 1;
       #10 clk0_int = 0;
    end

    generate if(DATA_RATE == "DDR")
        always @(posedge CLK1_INDELAY) begin
                 clk1_int = 1;
           #10  clk1_int = 0;
        end
    endgenerate

    assign clk_int = clk0_int | clk1_int;

    assign CFB0_OUT = CLK0_INDELAY;
    assign CFB1_OUT = CLK1_INDELAY;
    assign DFB_OUT = D_INDELAY;

// =====================
// IOCE sample
// =====================
    always @(posedge clk_int)  begin
          ioce_int <= IOCE_INDELAY;
       end

// ======================
//  Input Shift Register
// ======================

    always @(posedge clk_int) begin
       if (CE0_INDELAY) begin
          if (cascade_in_int == 1'b1) qs[3] <= SHIFTIN_INDELAY;
          else qs[3] <= D_INDELAY;
       end
       qs[2:0] <= qs[3:1];
    end

/*
    Output Input sample if this is the Slave (used by the Phase Detector in Master)
    Output S0 if this is the Master (used to cascade shift register in Slave)
*/
    generate
      case (SERDES_MODE)
         "NONE"   : always @(qs[0]) SHIFTOUT_OUT = qs[0];
         "MASTER" : always @(qs[0]) SHIFTOUT_OUT = qs[0];
         "SLAVE"  :  begin
                       always @(posedge clk_int or posedge RST_INDELAY) begin
                           if(RST)
                              sample = 0;
                           else if (CE0_INDELAY)
                              sample = #10 D_INDELAY;
                       end

                       always @(sample) SHIFTOUT_OUT = sample;
                     end
      endcase
    endgenerate

// ======================
//  Capture-In Registers
// ======================
    always @(posedge clk_int) begin
      if(ci_int && CE0_INDELAY) begin
         qc <= qs;
      end 
    end

// ===--===================
//  Transfer Out Registers
// ====--==================
    always @(posedge clk_int) begin
      if(ioce_int && CE0_INDELAY) begin
         qt <= qc;
      end 
    end

// ======================
//     GCLK Registers
// ======================
    always @(posedge CLKDIV_INDELAY) begin
      if(CE0_INDELAY) begin
         qg <= qt;
      end 
    end
// ==================================================================
//                     BITSLIP Function
// ==================================================================
    always @(posedge clk_int)  begin
       if (GSR_INDELAY)
          io_ce_dly <= 7'h00;
       else
          io_ce_dly <= {ioce_int, io_ce_dly[6:1]};
       end

    always @(posedge CLKDIV_INDELAY or posedge RST_INDELAY) begin
       if (GSR_INDELAY || RST_INDELAY)
           bitslip_counter <= 8 - DATA_WIDTH + 1;
       else if(BITSLIP_ENABLE_BINARY && BITSLIP_INDELAY) begin
          if(bitslip_counter == 3'b111) 
             bitslip_counter <= ~DATA_WIDTH + 1;
          else
             bitslip_counter <=  bitslip_counter + 1;
          end  
       end  
// ==================================================================
//                      Generate CaptureIn (CI) signal
// ==================================================================
    assign ci_int = bitslip_counter[2] ? ci_int_m_sync : ci_int_s_sync;
    always @(ioce_int or io_ce_dly or bitslip_counter)
      case(bitslip_counter[1:0])
          2'b00:  #0.5 ci_int_m = io_ce_dly[4];
          2'b01:  #0.5 ci_int_m = io_ce_dly[5];
          2'b10:  #0.5 ci_int_m = io_ce_dly[6];
          2'b11:  #0.5 ci_int_m = ioce_int;
      endcase

    always @(io_ce_dly or bitslip_counter)
      case(bitslip_counter[1:0])
          2'b00:  #0.5 ci_int_s = io_ce_dly[0];
          2'b01:  #0.5 ci_int_s = io_ce_dly[1];
          2'b10:  #0.5 ci_int_s = io_ce_dly[2];
          2'b11:  #0.5 ci_int_s = io_ce_dly[3];
      endcase

    always @(posedge clk_int) begin
      ci_int_m_sync <= ci_int_m;
      ci_int_s_sync <= ci_int_s;
      end

              
// ==================================================================
//                     Phase Detector Function
// ==================================================================

    generate if ((SERDES_MODE == "MASTER") || (SERDES_MODE == "NONE"))
    always @(SHIFTIN_INDELAY) E3 = SHIFTIN_INDELAY;
          
    always @(posedge clk_int or posedge RST_INDELAY) begin
       if(RST_INDELAY) begin
         event_occured  <= 0;
         incdec_reg     <= 0;
         edge_counter   <= 4'h0;
         valid_capture  <= 0;
         incdec_capture <= 0;
         pre_event      <= 1'b0;
         e3_f           <= 1'b0;
         incr_d         <= 1'b0;
         incdec_latch   <= 1'b0;
       end
       else if (CE0_INDELAY) begin
          e3_f <= E3;
          pre_event     <= drp_event[1] ? (qs[3] ^ qs[2]) : (drp_event[0] ? (!qs[3] & qs[2]) : (qs[3] & !qs[2]));
          event_occured <= pre_event & !((qs[3] ^ qs[2]) & en_lower_baud);

          incr_d        <= qs[3] ~^ (plus1 ? e3_f : E3);
          incdec_reg    <= incr_d;
          incdec_latch  <= ioce_int ? (event_occured & incdec_reg) :
                           ((event_occured & !edge_counter[0]) ? incdec_reg : incdec_latch);
          edge_counter  <= ioce_int ? {3'h0,event_occured} :
                           (event_occured ?
                            (!(edge_counter[0] & (incdec_reg ^ incdec_latch)) ? {edge_counter[2:0],1'b1} : {1'b0,edge_counter[3:1]})
                            : edge_counter);
          if(ioce_int) begin
              valid_capture  <= #100 edge_counter[0];
              incdec_capture <= #100 incdec_latch;
          end
       end
    end

//
// Re-time signals into GCLK domain
//

    always @(posedge CLKDIV_INDELAY or posedge RST_INDELAY) begin
       if(RST_INDELAY) begin
          VALID_OUT  = 0;
          INCDEC_OUT = 0;
       end
       else if (CE0_INDELAY) begin
          if (gvalid) VALID_OUT  = valid_capture;
          INCDEC_OUT = incdec_capture;
       end
    end
    endgenerate

// ==============
//  Output MUXES
// ==============
    always @(qs[3] or qc[3] or qt[3] or qg[3])
       if (qout_en[3] == 1'b0) Q4_OUT = 1'b0;
       else
       case(qmuxSel_int)
          2'b00:  Q4_OUT = qs[3];
          2'b01:  Q4_OUT = qc[3];
          2'b10:  Q4_OUT = qt[3];
          2'b11:  Q4_OUT = qg[3];
          default Q4_OUT = qs[3];
       endcase

    always @(qs[2] or qc[2] or qt[2] or qg[2])
       if (qout_en[2] == 1'b0) Q3_OUT = 1'b0;
       else
       case(qmuxSel_int)
          2'b00:  Q3_OUT = qs[2];
          2'b01:  Q3_OUT = qc[2];
          2'b10:  Q3_OUT = qt[2];
          2'b11:  Q3_OUT = qg[2];
          default Q3_OUT = qs[2];
       endcase

    always @(qs[1] or qc[1] or qt[1] or qg[1])
       if (qout_en[1] == 1'b0) Q2_OUT = 1'b0;
       else
       case(qmuxSel_int)
          2'b00:  Q2_OUT = qs[1];
          2'b01:  Q2_OUT = qc[1];
          2'b10:  Q2_OUT = qt[1];
          2'b11:  Q2_OUT = qg[1];
          default Q2_OUT = qs[1];
       endcase

    always @(qs[0] or qc[0] or qt[0] or qg[0])
       if (qout_en[0] == 1'b0) Q1_OUT = 1'b0;
       else
       case(qmuxSel_int)
          2'b00:  Q1_OUT = qs[0];
          2'b01:  Q1_OUT = qc[0];
          2'b10:  Q1_OUT = qt[0];
          2'b11:  Q1_OUT = qg[0];
          default Q1_OUT = qs[0];
       endcase

  specify
    ( CLK0 => CFB0) = (0, 0);
    ( CLK0 => Q1) = (0, 0);
    ( CLK0 => Q2) = (0, 0);
    ( CLK0 => Q3) = (0, 0);
    ( CLK0 => Q4) = (0, 0);
    ( CLK1 => CFB1) = (0, 0);
    ( CLK1 => Q1) = (0, 0);
    ( CLK1 => Q2) = (0, 0);
    ( CLK1 => Q3) = (0, 0);
    ( CLK1 => Q4) = (0, 0);
    ( CLKDIV => INCDEC) = (0, 0);
    ( CLKDIV => Q1) = (0, 0);
    ( CLKDIV => Q2) = (0, 0);
    ( CLKDIV => Q3) = (0, 0);
    ( CLKDIV => Q4) = (0, 0);
    ( CLKDIV => VALID) = (0, 0);
    ( D => DFB) = (0, 0);
    ( D => FABRICOUT) = (0, 0);
    ( RST => Q1) = (0, 0);
    ( RST => Q2) = (0, 0);
    ( RST => Q3) = (0, 0);
    ( RST => Q4) = (0, 0);

    specparam PATHPULSE$ = 0;
  endspecify
endmodule // ISERDES2
