// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/stan/OSERDES2.v,v 1.18 2009/08/21 23:55:41 harikr Exp $
//////////////////////////////////////////////////////
//  Copyright (c) 2008 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : Xilinx Functional Simulation Library Component
//  /  /                         Source Synchronous Output Serializer 
// /__/   /\       Filename    : OSERDES2.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:      Date:  Comment
//       1.0:  12/12/07:  Initial version.
//       1.1:  02/29/08:  Changed name to OSERDES2
//                        removed mc_ from signal names
//       1.2:  11/13/08:  IR495203 Gate behavior with OCE, TCE.
//                        Fix specify block
//       1.3:  12/11/08:  delay internal ioce by 1 ioclk
//       1.4:  01/30/09:  CR504529 add BYPASS_GCLK_FF attribute
//       1.5:  02/11/09:  CR507848 add missing MODULE_NAME localparam
//       1.6:  03/05/09:  CR511015 VHDL - VER sync
//       1.7:  03/19/09:  CR513780 x -> 0 rst sensitivity
//       1.8:  04/02/09:  CR513901 unisim-simprim mismatch, always -> assign
//       1.9:  07/07/09:  CR524403 Add NONE to valid serdes_mode values
// End Revision
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module OSERDES2 (
  OQ,
  SHIFTOUT1,
  SHIFTOUT2,
  SHIFTOUT3,
  SHIFTOUT4,
  TQ,
  CLK0,
  CLK1,
  CLKDIV,
  D1,
  D2,
  D3,
  D4,
  IOCE,
  OCE,
  RST,
  SHIFTIN1,
  SHIFTIN2,
  SHIFTIN3,
  SHIFTIN4,
  T1,
  T2,
  T3,
  T4,
  TCE,
  TRAIN
);

   parameter BYPASS_GCLK_FF = "FALSE"; // TRUE, FALSE
   parameter DATA_RATE_OQ = "DDR"; // SDR, DDR      | Data Rate setting
   parameter DATA_RATE_OT = "DDR"; // SDR, DDR, BUF | Tristate Rate setting.
   parameter integer DATA_WIDTH =   2; // {1..8} 
   parameter OUTPUT_MODE = "SINGLE_ENDED";  // SINGLE_ENDED, DIFFERENTIAL
   parameter SERDES_MODE = "NONE"; // NONE, MASTER, SLAVE
   parameter integer TRAIN_PATTERN =  0; // {0..15}             

   localparam in_delay = 1;
   localparam out_delay = 1;
   localparam inclk_delay = 0;
   localparam outclk_delay = 0;
   localparam MODULE_NAME = "OSERDES2";


   output OQ;
   output SHIFTOUT1;
   output SHIFTOUT2;
   output SHIFTOUT3;
   output SHIFTOUT4;
   output TQ;

   input  CLK0;
   input  CLK1;
   input  CLKDIV;
   input  D1;
   input  D2;
   input  D3;
   input  D4;
   input  IOCE;
   input  OCE;
   input  RST;
   input  SHIFTIN1;
   input  SHIFTIN2;
   input  SHIFTIN3;
   input  SHIFTIN4;
   input  T1;
   input  T2;
   input  T3;
   input  T4;
   input  TCE;
   input  TRAIN;
// Output signals 
    wire  oq_out, tq_out;
    wire  shiftout1_out, shiftout2_out, shiftout3_out, shiftout4_out;

    wire  oq_outdelay, tq_outdelay;
    wire  shiftout1_outdelay, shiftout2_outdelay, shiftout3_outdelay, shiftout4_outdelay;

// FF outputs
    reg [3:0] tgff, toff, dgff, doff;
    wire [3:0] tdata, ddata;
    wire tlsb, dlsb, tpre, dpre;
    reg Tff = 1'b0, Dff = 1'b0;
    reg Tpf = 1'b0, Dpf = 1'b0;
    reg one_shot_TCE = 1'b1, one_shot_OCE = 1'b1;
    reg ioce_int = 1'b0;

// Other nodes
    wire tcasc_in, dcasc_in;
    reg  tinit = 0;
    reg [3:0] trainp;

// Internal Clock
    reg clk0_int = 0;
    reg clk1_int = 0;
    wire clk_int;

// Attribute settings
    reg encasc;    // 1 = enable cascade input
    reg isslave;   // 1 = slave mode
    reg endiffop;  // 1 = enable pseudo diff output
    reg enTCE;     // 1 = enable the tristate path
    reg bypassTFF; // 1 = direct out

// Other signals
    reg BYPASS_GCLK_FF_err_flag = 0;
    reg data_rate_oq_err_flag = 0;
    reg data_rate_tq_err_flag = 0;
    reg data_width_err_flag = 0;
    reg output_mode_err_flag = 0;
    reg serdes_mode_err_flag = 0;
    reg train_pattern_err_flag = 0;
    reg attr_err_flag = 0;
    reg BYPASS_GCLK_FF_BINARY = 0;
    reg [7:0] DATA_WIDTH_BINARY = 2'h2;
    tri0  GSR = glbl.GSR;

    wire OQ;
    wire SHIFTOUT1;
    wire SHIFTOUT2;
    wire SHIFTOUT3;
    wire SHIFTOUT4;
    wire TQ;
    wire CLK0_IN;
    wire CLK1_IN;
    wire CLKDIV_IN;
    wire D1_IN;
    wire D2_IN;
    wire D3_IN;
    wire D4_IN;
    wire GSR_IN;
    wire IOCE_IN;
    wire OCE_IN;
    wire SHIFTIN1_IN;
    wire SHIFTIN2_IN;
    wire SHIFTIN3_IN;
    wire SHIFTIN4_IN;
    wire RST_IN;
    wire T1_IN;
    wire T2_IN;
    wire T3_IN;
    wire T4_IN;
    wire TCE_IN;
    wire TRAIN_IN;

    wire CLK0_INDELAY;
    wire CLK1_INDELAY;
    wire CLKDIV_INDELAY;
    wire D1_INDELAY;
    wire D2_INDELAY;
    wire D3_INDELAY;
    wire D4_INDELAY;
    wire GSR_INDELAY;
    wire IOCE_INDELAY;
    wire OCE_INDELAY;
    wire SHIFTIN1_INDELAY;
    wire SHIFTIN2_INDELAY;
    wire SHIFTIN3_INDELAY;
    wire SHIFTIN4_INDELAY;
    wire RST_INDELAY;
    wire T1_INDELAY;
    wire T2_INDELAY;
    wire T3_INDELAY;
    wire T4_INDELAY;
    wire TCE_INDELAY;
    wire TRAIN_INDELAY;
    reg notifier=0;

    assign #(inclk_delay) CLK0_INDELAY = CLK0_IN;
//    assign #(inclk_delay) CLK1_INDELAY = (DATA_RATE_OQ == "DDR") ? CLK1_IN : 1'b0;
    assign #(inclk_delay) CLK1_INDELAY = CLK1_IN;
    assign #(inclk_delay) CLKDIV_INDELAY = CLKDIV_IN;
    assign #(in_delay) D1_INDELAY = D1_IN;
    assign #(in_delay) D2_INDELAY = D2_IN;
    assign #(in_delay) D3_INDELAY = D3_IN;
    assign #(in_delay) D4_INDELAY = D4_IN;
    assign #(in_delay) GSR_INDELAY = GSR_IN;
    assign #(in_delay) IOCE_INDELAY = IOCE_IN;
    assign #(in_delay) OCE_INDELAY = OCE_IN;
    assign #(in_delay) SHIFTIN1_INDELAY = SHIFTIN1_IN;
    assign #(in_delay) SHIFTIN2_INDELAY = SHIFTIN2_IN;
    assign #(in_delay) SHIFTIN3_INDELAY = SHIFTIN3_IN;
    assign #(in_delay) SHIFTIN4_INDELAY = SHIFTIN4_IN;
    assign #(in_delay) RST_INDELAY = RST_IN;
    assign #(in_delay) T1_INDELAY = T1_IN;
    assign #(in_delay) T2_INDELAY = T2_IN;
    assign #(in_delay) T3_INDELAY = T3_IN;
    assign #(in_delay) T4_INDELAY = T4_IN;
    assign #(in_delay) TCE_INDELAY = TCE_IN;
    assign #(in_delay) TRAIN_INDELAY = TRAIN_IN;

    assign #(out_delay) oq_outdelay = oq_out;
    assign #(out_delay) tq_outdelay = tq_out;
    assign #(out_delay) shiftout1_outdelay = shiftout1_out;
    assign #(out_delay) shiftout2_outdelay = shiftout2_out;
    assign #(out_delay) shiftout3_outdelay = shiftout3_out;
    assign #(out_delay) shiftout4_outdelay = shiftout4_out;

//----------------------------------------------------------------------
//------------------------  Output Ports  ------------------------------
//----------------------------------------------------------------------
    assign OQ = oq_outdelay;
    assign TQ = tq_outdelay;
    assign SHIFTOUT1 = shiftout1_outdelay;
    assign SHIFTOUT2 = shiftout2_outdelay;
    assign SHIFTOUT3 = shiftout3_outdelay;
    assign SHIFTOUT4 = shiftout4_outdelay;

//----------------------------------------------------------------------
//------------------------   Input Ports  ------------------------------
//----------------------------------------------------------------------

    assign CLK0_IN = CLK0;
    assign CLK1_IN = CLK1;
    assign CLKDIV_IN = CLKDIV;
    assign D1_IN = D1;
    assign D2_IN = D2;
    assign D3_IN = D3;
    assign D4_IN = D4;
    assign GSR_IN = GSR;
    assign IOCE_IN = IOCE;
    assign OCE_IN = OCE;
    assign SHIFTIN1_IN = SHIFTIN1;
    assign SHIFTIN2_IN = SHIFTIN2;
    assign SHIFTIN3_IN = SHIFTIN3;
    assign SHIFTIN4_IN = SHIFTIN4;
    assign RST_IN = RST;
    assign T1_IN = T1;
    assign T2_IN = T2;
    assign T3_IN = T3;
    assign T4_IN = T4;
    assign TCE_IN = TCE;
    assign TRAIN_IN = TRAIN;


// =======================
//  Top of shift register
// =======================
   assign dcasc_in = encasc & SHIFTIN1_INDELAY;
   assign tcasc_in = encasc & SHIFTIN2_INDELAY;

    initial begin
//-------------------------------------------------
//------ BYPASS_GCLK_FF Check
//-------------------------------------------------
      if      (BYPASS_GCLK_FF == "TRUE")  BYPASS_GCLK_FF_BINARY <= 1'b1;
      else if (BYPASS_GCLK_FF == "FALSE") BYPASS_GCLK_FF_BINARY <= 1'b0;
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute BYPASS_GCLK_FF on %s instance %m is set to %s. \n Legal values for this attribute are TRUE or FALSE.\n", MODULE_NAME,  BYPASS_GCLK_FF);
         BYPASS_GCLK_FF_err_flag = 1;
         end


//-------------------------------------------------
//----- DATA_RATE_OQ  Check
//-------------------------------------------------
       if ((DATA_RATE_OQ != "SDR") && (DATA_RATE_OQ != "DDR")) begin
          #1;
          $display("Attribute Syntax Error : The attribute DATA_RATE_OQ on %s instance %m is set to %s.  \nLegal values for this attribute are SDR or DDR.\n", MODULE_NAME, DATA_RATE_OQ);
          data_rate_oq_err_flag = 1;
          end

//-------------------------------------------------
//----- DATA_RATE_OT  Check
//-------------------------------------------------
       if (DATA_RATE_OT == "SDR") begin
          tinit = 1;
          enTCE = 1;
          bypassTFF = 0;
          if (DATA_RATE_OQ !== "SDR") begin
             #1;
             $display("Attribute Syntax Error : The attribute DATA_RATE_OT on %s instance %m is set to %s and the attribute DATA_RATE_OQ is set to %s. \nThese two values must match for SDR and DDR.\n", MODULE_NAME, DATA_RATE_OT, DATA_RATE_OQ);
             data_rate_tq_err_flag = 1;
             end
          end
       else if (DATA_RATE_OT == "DDR") begin
          tinit = 1;
          enTCE = 1;
          bypassTFF = 0;
          if (DATA_RATE_OQ !== "DDR") begin
             #1;
             $display("Attribute Syntax Error : The attribute DATA_RATE_OT on %s instance %m is set to %s and the attribute DATA_RATE_OQ is set to %s. \nThese two values must match for SDR and DDR.\n", MODULE_NAME, DATA_RATE_OT, DATA_RATE_OQ);
             data_rate_tq_err_flag = 1;
             end
          end
       else if (DATA_RATE_OT == "BUF") begin
          tinit = 0;
          enTCE = 0;
          bypassTFF = 1;
          end
       else begin
          #1;
          $display("Attribute Syntax Error : The attribute DATA_RATE_OT on %s instance %m is set to %s.  \nLegal values for this attribute are SDR, DDR or BUF.\n", MODULE_NAME, DATA_RATE_OT);
          data_rate_tq_err_flag = 1;
          end

//-------------------------------------------------
//----- DATA_WIDTH check
//-------------------------------------------------
      if ((DATA_WIDTH == 1) || (DATA_WIDTH == 2) || (DATA_WIDTH == 3) ||
          (DATA_WIDTH == 4) || (DATA_WIDTH == 5) || (DATA_WIDTH == 6) ||
          (DATA_WIDTH == 7) || (DATA_WIDTH == 8)) begin
         DATA_WIDTH_BINARY = DATA_WIDTH;
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute DATA_WIDTH on %s instance %m is set to %d.  \nLegal values for this attribute are 1, 2, 3, 4, 5, 6, 7 or 8.\n", MODULE_NAME, DATA_WIDTH);
         data_width_err_flag = 1;
         end

//-------------------------------------------------
//------ SERDES_MODE Check
//-------------------------------------------------
      if (SERDES_MODE == "NONE") begin
         isslave = 1'b0;
         encasc = 1'b0;
         end
      else if (SERDES_MODE == "MASTER") begin
         isslave = 1'b0;
         encasc = 1'b0;
         end
      else if (SERDES_MODE == "SLAVE") begin
         isslave = 1'b1;
         if (DATA_WIDTH > 4)
            encasc = 1'b1;
         else
            encasc = 1'b0;
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute SERDES_MODE on %s instance %m is set to %s.  \nLegal values for this attribute are NONE, MASTER or SLAVE.\n", MODULE_NAME, SERDES_MODE);
         serdes_mode_err_flag = 1;
         end

//-------------------------------------------------
//------ OUTPUT_MODE Check
//-------------------------------------------------
      if (OUTPUT_MODE == "DIFFERENTIAL") begin
         endiffop = 1'b1;
         end
      else if (OUTPUT_MODE == "SINGLE_ENDED") begin
         if ((SERDES_MODE == "SLAVE") || (DATA_WIDTH < 5))
            endiffop = 1'b0;
         else
            endiffop = 1'b1;
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute OUTPUT_MODE on %s instance %m is set to %s.  \nLegal values for this attribute are DIFFERENTIAL or SINGLE_ENDED.\n", MODULE_NAME, OUTPUT_MODE);
         output_mode_err_flag = 1;
         end

//-------------------------------------------------
//----- TRAIN_PATTERN check
//-------------------------------------------------
      if ((TRAIN_PATTERN >= 0) && (TRAIN_PATTERN < 16)) begin
         trainp   = TRAIN_PATTERN;
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute TRAIN_PATTERN on %s instance %m is set to %d.  \nLegal values for this attribute are 0, 1, 2, ... 13, 14, 15.\n", MODULE_NAME, TRAIN_PATTERN);
         train_pattern_err_flag = 1;
         end

//-------------------------------------------------
//------        Error Flag                 --------
//-------------------------------------------------
    #1;
    if (data_rate_oq_err_flag || data_rate_tq_err_flag || data_width_err_flag ||        output_mode_err_flag || serdes_mode_err_flag || train_pattern_err_flag)
       begin
          attr_err_flag = 1;
          #1;
          $display("Attribute Errors detected : Simulation cannot continue. Exiting. \n");
          $finish;
       end

    end  // initial begin

//-----------------------------------------------------------------------------------
//*** GLOBAL hidden GSR pin
    always @(GSR_INDELAY) begin
        if (GSR_INDELAY == 1'b1) begin

           assign dgff      = 4'h0;
           assign doff      = 4'h0;

           assign tgff      = 4'h0;
           assign toff      = 4'h0;

//           assign Dff       = 1'b0;
           assign Dpf       = 1'b0;
//           assign Tff       = 1'b0;
           assign Tpf       = 1'b0;

        end
        else begin

           deassign dgff;
           deassign doff;

           deassign tgff;
           deassign toff;

//           deassign Dff;
           deassign Dpf;
//           deassign Tff;
           deassign Tpf;

        end
    end
// =====================
// DDR doubler
// =====================
    always @(posedge CLK0_INDELAY) begin
            clk0_int = 1;
       #100 clk0_int = 0;
    end

    generate if(DATA_RATE_OQ == "DDR")
        always @(posedge CLK1_INDELAY) begin
                 clk1_int = 1;
           #100  clk1_int = 0;
        end
    endgenerate

    assign clk_int = clk0_int | clk1_int;
//
// =====================
// IOCE sample
// =====================
//    always @(posedge CLK0_INDELAY or posedge CLK1_INDELAY or posedge RST_INDELAY) begin
    always @(posedge clk_int or posedge RST_INDELAY) begin
       if (RST_INDELAY == 1'b1)
          ioce_int <= 1'b0;
       else
          ioce_int <= IOCE_INDELAY;
       end

// ======================
//  GCLK Register Bank
// ======================

    always @(posedge CLKDIV_INDELAY or posedge RST_INDELAY) begin
       if (RST_INDELAY == 1'b1) begin
          dgff[3] <= 1'b0;
          dgff[2] <= 1'b0;
          dgff[1] <= 1'b0;
          dgff[0] <= 1'b0;
          end
       else if (OCE_INDELAY == 1'b1) begin
          dgff[3] <= #100 D4_INDELAY;
          dgff[2] <= #100 D3_INDELAY;
          dgff[1] <= #100 D2_INDELAY;
          dgff[0] <= #100 D1_INDELAY;
          end
       end

    always @(posedge CLKDIV_INDELAY or posedge RST_INDELAY) begin
       if (RST_INDELAY == 1'b1) begin
          tgff[3] <= 1'b0; // tinit?
          tgff[2] <= 1'b0; // tinit?
          tgff[1] <= 1'b0; // tinit?
          tgff[0] <= 1'b0; // tinit?
          end
       else if (TCE_INDELAY == 1'b1) begin
          tgff[3] <= #100 T4_INDELAY;
          tgff[2] <= #100 T3_INDELAY;
          tgff[1] <= #100 T2_INDELAY;
          tgff[0] <= #100 T1_INDELAY;
          end
       end

// ======================
//  Bypass Mux
// ======================
   assign ddata = TRAIN_INDELAY ? trainp : (BYPASS_GCLK_FF_BINARY ? {D4_INDELAY, D3_INDELAY, D2_INDELAY, D1_INDELAY} : dgff);

   assign tdata[3] = BYPASS_GCLK_FF_BINARY ? T4_INDELAY : tgff[3];
   assign tdata[2] = BYPASS_GCLK_FF_BINARY ? T3_INDELAY : tgff[2];
   assign tdata[1] = BYPASS_GCLK_FF_BINARY ? T2_INDELAY : tgff[1];
   assign tdata[0] = BYPASS_GCLK_FF_BINARY ? T1_INDELAY : tgff[0];

// =======================
//  Output Shift Register
// =======================
    always @(posedge clk_int or posedge RST_INDELAY) begin
//    always @(posedge CLK0_INDELAY or posedge CLK1_INDELAY or posedge RST_INDELAY) begin
       if (RST_INDELAY == 1'b1) begin
          doff <= 4'h0;
          toff <= 4'h0; // tinit?
          end
       else begin
          if (OCE_INDELAY == 1'b1) begin
             doff <= ioce_int ? ddata : {dcasc_in, doff[3:1]};
             end
          if (TCE_INDELAY == 1'b1) begin
             toff <= ioce_int ? tdata : {tcasc_in, toff[3:1]};
             end
          end
       end

// ==========================
//  Bottom of shift register
// ==========================
    assign shiftout1_out = doff[0];
    assign shiftout2_out = toff[0];
    assign shiftout3_out = dlsb;
    assign shiftout4_out = tlsb;

    assign dlsb =                           ioce_int ? ddata[0] : doff[1];
    assign tlsb = bypassTFF ? T1_INDELAY : (ioce_int ? tdata[0] : toff[1]);


    assign dpre = endiffop ? (isslave ? ~dlsb : SHIFTIN3_INDELAY) : dlsb;
    assign tpre = endiffop ? (isslave ?  tlsb : SHIFTIN4_INDELAY) : tlsb;


// =====================
//  Output Sampling FFs
// =====================
    always @(posedge clk_int or posedge RST_INDELAY) begin
//    always @(posedge CLK0_INDELAY or posedge CLK1_INDELAY or posedge RST_INDELAY) begin
       if (GSR_INDELAY == 1'b1) begin
          Dpf <= 1'b0;
          Tpf <= 1'b0;
          one_shot_OCE <= 1'b1;
          one_shot_TCE <= 1'b1;
          end
       else if (RST_INDELAY == 1'b1) begin
          Dpf <= isslave && endiffop; // 1'b0;
          Tpf <= 1'b0; // should be tinit
          one_shot_OCE <= 1'b1;
          one_shot_TCE <= 1'b1;
          end
       else if ((GSR_INDELAY === 1'b0) && (RST_INDELAY === 1'b0)) begin
          if (OCE_INDELAY == 1'b1) Dpf <= dpre;
          if (TCE_INDELAY == 1'b1) Tpf <= tpre;
          if (OCE_INDELAY == 1'b1) one_shot_OCE <= 1'b0;
          if (TCE_INDELAY == 1'b1) one_shot_TCE <= 1'b0;
          end
       end

//    always @(posedge CLK0_INDELAY or posedge CLK1_INDELAY or posedge RST_INDELAY) begin
    always @(posedge clk_int or posedge RST_INDELAY) begin 
       if (GSR_INDELAY == 1'b1) begin
          Dff <= 1'b0;
          Tff <= 1'b0;
          end
       else if (RST_INDELAY == 1'b1) begin
          Dff <= 1'b0;
          Tff <= tinit;
          end
       else if ((GSR_INDELAY === 1'b0) && (RST_INDELAY === 1'b0)) begin
          if (OCE_INDELAY == 1'b1) Dff <= one_shot_OCE ? Dpf : dpre;
          if (TCE_INDELAY == 1'b1) Tff <= one_shot_TCE ? Tpf : tpre;
          end
       end

// ==================
//  Final Output Mux
// ==================
    assign oq_out = Dff;
    assign tq_out = bypassTFF ? tpre : Tff;


  specify
    ( CLK0 => OQ) = (0, 0);
    ( CLK0 => TQ) = (0, 0);
    ( CLK1 => OQ) = (0, 0);
    ( CLK1 => TQ) = (0, 0);

    specparam PATHPULSE$ = 0;
  endspecify
endmodule // OSERDES2
