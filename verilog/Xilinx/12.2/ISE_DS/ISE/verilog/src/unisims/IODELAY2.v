// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/stan/IODELAY2.v,v 1.25 2010/01/28 19:46:31 robh Exp $
///////////////////////////////////////////////////////
//  Copyright (c) 2008 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : Xilinx Functional Simulation Library Component
//  /  /                         Input and/or Output Fixed or Variable Delay Element.
// /__/   /\       Filename    : IODELAY2.v
// \  \  /  \ 
//  \__\/\__ \                      
//                                   
//  Revision:      Date:  Comment
//       1.0:  01/16/08:  Initial version.
//       1.1:  08/21/08:  CR479980 fix T polarity.
//       1.2:  09/05/08:  CR480001 fix calibration.
//       1.3:  09/19/08:  CR480004 fix phase detector mode.
//       1.4:  09/30/08:  Add DATA_RATE attribute
//                        Add clock doubler
//                        Change RDY to BUSY
//       1.5   11/05/2008 I/O, structure change
//       1.6   11/19/2008 Change SIM_TAP_DELAY to SIM_TAPDELAY_VALUE
//       1.7   01/29/2009 IR504942, 504805, 504692 sync to data
//       1.8   02/04/2009 CR480001 Diff phase detector changes
//             02/04/2009 CR506027 sync_to_data off
//       1.9   02/12/2009 CR1016 update DOUT to match HW
//       1.10  03/05/2009 CR511015 VHDL - VER sync
//                        CR511054 Output at time 0 fix
//       1.11: 04/09/2009 CR480001 fix calibration.
//       1.12: 04/22/2009 CR518721 ODELAY value fix at time 0
//       1.13: 05/19/2009 CR522171 Missing else in if-else-else. delay values
//       1.14: 07/23/2009 CR527208 Race condition in cal sig
//       1.15: 08/07/2009 CR511054 Time 0 output initialization
//                        CR529368 Input bypass ouput when delay line idle
//       1.16: 09/01/2009 CR531995 sync_to_data on
//       1.17: 11/04/2009 CR538116 fix calibrate_done when cal_delay saturates
//       1.18: 11/30/2009 CR538638 add parameter SIM_IDATAIN_INDELAY and SIM_ODATAIN_INDELAY
//       1.19: 01/28/2010 CR544661 transport (always@) SIM_*_INDELAY in case delay > period
//  End Revision
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module IODELAY2 (
  BUSY,
  DATAOUT,
  DATAOUT2,
  DOUT,
  TOUT,
  CAL,
  CE,
  CLK,
  IDATAIN,
  INC,
  IOCLK0,
  IOCLK1,
  ODATAIN,
  RST,
  T
);

  parameter COUNTER_WRAPAROUND = "WRAPAROUND"; // "WRAPAROUND", "STAY_AT_LIMIT"
  parameter DATA_RATE = "SDR";       // "SDR", "DDR"
  parameter DELAY_SRC = "IO";        // "IO", "IDATAIN", "ODATAIN"
  parameter integer IDELAY2_VALUE = 0;  // 0 to 255 inclusive
  parameter IDELAY_MODE = "NORMAL";  // "NORMAL", "PCI"
  parameter IDELAY_TYPE = "DEFAULT";    // "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
  parameter integer IDELAY_VALUE = 0;   // 0 to 255 inclusive
  parameter integer ODELAY_VALUE = 0;   // 0 to 255 inclusive
  parameter SERDES_MODE = "NONE";       // "NONE", "MASTER", "SLAVE"
  parameter integer SIM_TAPDELAY_VALUE = 75; // 10 to 90 inclusive

  localparam integer SIM_IDATAIN_INDELAY = 110; 
  localparam integer SIM_ODATAIN_INDELAY = 110; 
  localparam WRAPAROUND = 1'b0;
  localparam STAY_AT_LIMIT = 1'b1;
  localparam SDR = 1'b1;
  localparam DDR = 1'b0;
  localparam IO = 2'b00;
  localparam I = 2'b01;
  localparam O = 2'b11;
  localparam PCI = 1'b0;
  localparam NORMAL = 1'b1;
  localparam DEFAULT = 4'b1001;
  localparam FIXED = 4'b1000;
  localparam VAR = 4'b1100;
  localparam DIFF_PHASE_DETECTOR = 4'b1111;
  localparam NONE = 1'b1;
  localparam MASTER = 1'b1;
  localparam SLAVE = 1'b0;

  output BUSY;
  output DATAOUT2;
  output DATAOUT;
  output DOUT;
  output TOUT;

  input CAL;
  input CE;
  input CLK;
  input IDATAIN;
  input INC;
  input IOCLK0;
  input IOCLK1;
  input ODATAIN;
  input RST;
  input T;


  reg COUNTER_WRAPAROUND_BINARY = WRAPAROUND;
  reg DATA_RATE_BINARY = SDR;
  reg [1:0] DELAY_SRC_BINARY = IO;
  reg [7:0] IDELAY2_VALUE_BINARY = 0;
  reg IDELAY_MODE_BINARY = NORMAL;
  reg [3:0] IDELAY_TYPE_BINARY = DEFAULT;
  reg SERDES_MODE_BINARY = NONE;
  reg [6:0] SIM_TAPDELAY_VALUE_BINARY = 75;
  reg [7:0] IDELAY_VALUE_BINARY = 0;
  reg [7:0] ODELAY_VALUE_BINARY = 0;

  tri0 GSR = glbl.GSR;

  wire BUSY_OUT;
  wire DATAOUT2_OUT;
  wire DATAOUT_OUT;
  wire DOUT_OUT;
  wire TOUT_OUT;
  wire BUSY_OUTDELAY;
  wire DATAOUT2_OUTDELAY;
  wire DATAOUT_OUTDELAY;
  wire DOUT_OUTDELAY;
  wire TOUT_OUTDELAY;

  wire CAL_IN;
  wire CE_IN;
  wire CLK_IN;
  wire IDATAIN_IN;
  wire INC_IN;
  wire IOCLK0_IN;
  wire IOCLK1_IN;
  wire ODATAIN_IN;
  wire RST_IN;
  wire T_IN;
  wire GSR_IN;
  wire CAL_INDELAY;
  wire CE_INDELAY;
  wire CLK_INDELAY;
  reg IDATAIN_INDELAY;
  wire INC_INDELAY;
  wire IOCLK0_INDELAY;
  wire IOCLK1_INDELAY;
  reg ODATAIN_INDELAY;
  wire RST_INDELAY;
  wire T_INDELAY;
  wire GSR_INDELAY;
//-----------------------------------------------------------------------------
//------------------- constants -----------------------------------------------
//-----------------------------------------------------------------------------
  localparam in_delay = 110;
  localparam out_delay = 0;
  localparam clk_delay = 1;
  localparam MODULE_NAME = "IODELAY2";

  wire output_delay_off;
  wire input_delay_off;
  wire [7:0] idelay_val_pe_reg;
  reg [7:0] idelay_val_pe_m_reg = 0;
  reg [7:0] idelay_val_pe_s_reg = 0;
  wire [7:0] idelay_val_ne_reg;
  reg [7:0] idelay_val_ne_m_reg = 0;
  reg [7:0] idelay_val_ne_s_reg = 0;
  reg sat_at_max_reg = WRAPAROUND;
  reg rst_to_half_reg = 0;
  reg ignore_rst = 0;
  reg force_rx_reg = 0;
  reg force_dly_dir_reg = 0;
  reg [7:0] default_value = 8'ha5;

  wire rst_sig;
  wire ce_sig;
  wire inc_sig;
  wire cal_sig;
  reg ioclk0_int = 0;
  reg ioclk1_int = 0;
  wire ioclk_int;
  reg first_edge = 0;
  wire delay1_out_sig;
  reg delay1_out = 0;
  reg delay2_out = 0;
  reg delay1_out_dly = 0;
  reg tout_out_int = 0;
  reg busy_out_int = 1;
  reg busy_out_dly = 1;
  reg busy_out_dly1 = 1;

// Error flags
  reg counter_wraparound_err_flag = 0;
  reg data_rate_err_flag = 0;
  reg serdes_mode_err_flag = 0;
  reg odelay_value_err_flag = 0;
  reg idelay_value_err_flag = 0;
  reg sim_tap_delay_err_flag = 0;
  reg idelay_type_err_flag = 0;
  reg idelay_mode_err_flag = 0;
  reg delay_src_err_flag = 0;
  reg idelay2_value_err_flag = 0;
  reg attr_err_flag = 0; 
// internal logic
  reg [4:0] cal_count = 5'b10010;
  reg [7:0] cal_delay = 8'h00;
  reg [7:0] max_delay = 8'h00;
  reg [7:0] half_max = 8'h00;
  reg [7:0] delay_val_pe_1 = 0;
  reg [7:0] delay_val_ne_1 = 0;
  wire delay_val_pe_clk;
  wire delay_val_ne_clk;
  wire delay1_reached;
  reg delay1_reached_1 = 0;
  reg delay1_reached_2 = 0;
  wire delay1_working;
  reg delay1_working_1 = 0;
  reg delay1_working_2 = 0;
  reg delay1_ignore = 0;
  reg [7:0] delay_val_pe_2 = 0;
  reg [7:0] delay_val_ne_2 = 0;
  reg [7:0] odelay_val_pe_reg = 0;
  reg [7:0] odelay_val_ne_reg = 0;
  wire delay2_reached;
  reg delay2_reached_1 = 0;
  reg delay2_reached_2 = 0;
  wire delay2_working;
  reg delay2_working_1 = 0;
  reg delay2_working_2 = 0;
  reg delay2_ignore = 0;
  reg delay1_in = 0;
  reg delay2_in = 0;
  reg calibrate = 0;
  reg calibrate_done = 0;
  reg sync_to_data_reg = 1;
  reg pci_ce_reg = 0;

//-----------------------------------------------------------------------------
//----------------- tasks / function      -------------------------------------
//-----------------------------------------------------------------------------
task inc_dec;
begin
   if (GSR_INDELAY) begin
      idelay_val_pe_m_reg <= IDELAY_VALUE_BINARY;
      idelay_val_pe_s_reg <= IDELAY_VALUE_BINARY;
         if (pci_ce_reg == 1) begin // PCI
            idelay_val_ne_m_reg <= IDELAY2_VALUE_BINARY;
            idelay_val_ne_s_reg <= IDELAY2_VALUE_BINARY;
            end
         else begin
            idelay_val_ne_m_reg <= IDELAY_VALUE_BINARY;
            idelay_val_ne_s_reg <= IDELAY_VALUE_BINARY;
            end
      end
   else if (rst_sig) begin
      if (rst_to_half_reg == 1'b1) begin
         // rst to half
         if (SERDES_MODE_BINARY == SLAVE) begin
            if ((ignore_rst == 1'b0) && (IDELAY_TYPE_BINARY != DIFF_PHASE_DETECTOR)) begin
            // all non diff phase detector slave rst
               idelay_val_pe_s_reg <= half_max;
               idelay_val_ne_s_reg <= half_max;
               end
            else if (ignore_rst == 1'b0) begin
            // slave phase detector first rst
               idelay_val_pe_m_reg <= half_max;
               idelay_val_ne_m_reg <= half_max;
               idelay_val_pe_s_reg <= half_max << 1;
               idelay_val_ne_s_reg <= half_max << 1;
               ignore_rst <= 1'b1;
               end
            else begin
            // slave phase det second or more rst
               if ((idelay_val_pe_m_reg + half_max) > max_delay) begin
                  idelay_val_pe_s_reg <= idelay_val_pe_m_reg + half_max - max_delay - 1;
                  idelay_val_ne_s_reg <= idelay_val_ne_m_reg + half_max - max_delay - 1;
                  end
               else begin
                  idelay_val_pe_s_reg <= idelay_val_pe_m_reg + half_max;
                  idelay_val_ne_s_reg <= idelay_val_ne_m_reg + half_max;
                  end
               end
            end
         else if ((ignore_rst == 1'b0) || (IDELAY_TYPE_BINARY != DIFF_PHASE_DETECTOR)) begin
         // master or none, first diff phase rst or all others
            idelay_val_pe_m_reg <= half_max;
            idelay_val_ne_m_reg <= half_max;
            ignore_rst <= 1'b1;
            end
         end
      else begin
      // rst to 0
         idelay_val_pe_m_reg <= 0;
         idelay_val_ne_m_reg <= 0;
         idelay_val_pe_s_reg <= 0;
         idelay_val_ne_s_reg <= 0;
         end
      end
   else if ( ~busy_out_int && ce_sig && ~rst_sig &&
            ((IDELAY_TYPE_BINARY == VAR) ||
             (IDELAY_TYPE_BINARY == DIFF_PHASE_DETECTOR)) ) begin //variable
      if (inc_sig) begin // inc
         // MASTER or NONE
         // (lt max_delay inc m)
         if (idelay_val_pe_m_reg < max_delay) begin
            idelay_val_pe_m_reg <= idelay_val_pe_m_reg + 1;
            end
         // wrap to 0 wrap (gte max_delay and wrap to 0)
         else if (sat_at_max_reg == WRAPAROUND) begin
            idelay_val_pe_m_reg <= 8'h00;
            end
         // stay at max (gte max_delay and stay at max)
         else begin
            idelay_val_pe_m_reg <= max_delay;
            end
         // SLAVE
         // (lt max_delay inc s)
         if (idelay_val_pe_s_reg < max_delay) begin
            idelay_val_pe_s_reg <= idelay_val_pe_s_reg + 1;
            end
         // wrap to 0 wrap (gte max_delay and wrap to 0)
         else if (sat_at_max_reg == WRAPAROUND) begin
            idelay_val_pe_s_reg <= 8'h00;
            end
         // stay at max (gte max_delay and stay at max)
         else begin
            idelay_val_pe_s_reg <= max_delay;
            end
         // MASTER or NONE
         // (lt max_delay inc)
         if (idelay_val_ne_m_reg < max_delay) begin
            idelay_val_ne_m_reg <= idelay_val_ne_m_reg + 1;
            end
         // wrap to 0 wrap (gte max_delay and wrap to 0)
         else if (sat_at_max_reg == WRAPAROUND) begin
            idelay_val_ne_m_reg <= 8'h00;
            end
         // stay at max (gte max_delay and stay at max)
         else begin
            idelay_val_ne_m_reg <= max_delay;
            end
         // SLAVE
         // (lt max_delay inc)
         if (idelay_val_ne_s_reg < max_delay) begin
            idelay_val_ne_s_reg <= idelay_val_ne_s_reg + 1;
            end
         // wrap to 0 wrap (gte max_delay and wrap to 0)
         else if (sat_at_max_reg == WRAPAROUND) begin
            idelay_val_ne_s_reg <= 8'h00;
            end
         // stay at max (gte max_delay and stay at max)
         else begin
            idelay_val_ne_s_reg <= max_delay;
            end
         end
      else begin // dec
         // MASTER or NONE
         // (between 0 and max_delay dec)
         if ((idelay_val_pe_m_reg > 8'h00) && 
             (idelay_val_pe_m_reg <= max_delay)) begin
            idelay_val_pe_m_reg <= idelay_val_pe_m_reg - 1;
            end
         // stay at max (0) (eq 0 and stay at max/min)
         else if ((sat_at_max_reg == STAY_AT_LIMIT) && (idelay_val_pe_m_reg == 0)) begin
            idelay_val_pe_m_reg <= 8'h00;
            end
         // wrap to 0 wrap (gte max_delay or (eq 0 and wrap to max))
         else begin
            idelay_val_pe_m_reg <= max_delay;
            end
         // SLAVE
         // (between 0 and max_delay dec)
         if ((idelay_val_pe_s_reg > 8'h00) && 
             (idelay_val_pe_s_reg <= max_delay)) begin
            idelay_val_pe_s_reg <= idelay_val_pe_s_reg - 1;
            end
         // stay at max (0) (eq 0 and stay at max/min)
         else if ((sat_at_max_reg == STAY_AT_LIMIT) && (idelay_val_pe_s_reg == 0)) begin
            idelay_val_pe_s_reg <= 8'h00;
            end
         // wrap to 0 wrap (gte max_delay or (eq 0 and wrap to max))
         else begin
            idelay_val_pe_s_reg <= max_delay;
            end
         // MASTER or NONE
         // (between 0 and max_delay dec)
         if ((idelay_val_ne_m_reg > 8'h00) && 
             (idelay_val_ne_m_reg <= max_delay)) begin
            idelay_val_ne_m_reg <= idelay_val_ne_m_reg - 1;
            end
         // stay at max (0) (eq 0 and stay at max/min)
         else if ((sat_at_max_reg == STAY_AT_LIMIT) && (idelay_val_ne_m_reg == 0)) begin
            idelay_val_ne_m_reg <= 8'h00;
            end
         // wrap to 0 wrap (gte max_delay or (eq 0 and wrap to max))
         else begin
            idelay_val_ne_m_reg <= max_delay;
            end
         // SLAVE
         // (between 0 and max_delay dec)
         if ((idelay_val_ne_s_reg > 8'h00) && 
             (idelay_val_ne_s_reg <= max_delay)) begin
            idelay_val_ne_s_reg <= idelay_val_ne_s_reg - 1;
            end
         // stay at max (0) (eq 0 and stay at max/min)
         else if ((sat_at_max_reg == STAY_AT_LIMIT) && (idelay_val_ne_s_reg == 0)) begin
            idelay_val_ne_s_reg <= 8'h00;
            end
         // wrap to 0 wrap (gte max_delay or (eq 0 and wrap to max))
         else begin
            idelay_val_ne_s_reg <= max_delay;
            end
         end
      end
   end
endtask
  assign BUSY_OUT = busy_out_dly;
  assign rst_sig = RST_INDELAY;
  assign ce_sig = CE_INDELAY;
  assign inc_sig = INC_INDELAY;
  assign cal_sig = CAL_INDELAY;
  assign output_delay_off = force_dly_dir_reg && force_rx_reg;
  assign input_delay_off = force_dly_dir_reg && ~force_rx_reg;
  assign idelay_val_pe_reg = (SERDES_MODE_BINARY == SLAVE) ?  idelay_val_pe_s_reg : idelay_val_pe_m_reg;
  assign idelay_val_ne_reg = (SERDES_MODE_BINARY == SLAVE) ?  idelay_val_ne_s_reg : idelay_val_ne_m_reg;
  assign delay1_reached = delay1_reached_1 || delay1_reached_2;
  assign delay2_reached = delay2_reached_1 || delay2_reached_2;
  assign delay1_working = delay1_working_1 || delay1_working_2;
  assign delay2_working = delay2_working_1 || delay2_working_2;

  initial begin
//-----------------------------------------------------------------------------
//----------------- COUNTER_WRAPAROUND Check ----------------------------------
//-----------------------------------------------------------------------------
      if (COUNTER_WRAPAROUND == "WRAPAROUND") begin
         COUNTER_WRAPAROUND_BINARY = WRAPAROUND;
         sat_at_max_reg = WRAPAROUND;    // wrap to 0
         end
      else if (COUNTER_WRAPAROUND == "STAY_AT_LIMIT") begin
         COUNTER_WRAPAROUND_BINARY = STAY_AT_LIMIT;
         sat_at_max_reg = STAY_AT_LIMIT;    // stay at max
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The Attribute COUNTER_WRAPAROUND on %s instance %m is set to %s.  Legal values for this attribute are WRAPAROUND or STAY_AT_LIMIT.\n", MODULE_NAME, COUNTER_WRAPAROUND);
         counter_wraparound_err_flag = 1;
         end

//-----------------------------------------------------------------------------
//----------------- DATA_RATE  Check ------------------------------------------
//-----------------------------------------------------------------------------
      if      (DATA_RATE == "SDR") DATA_RATE_BINARY <= SDR;
      else if (DATA_RATE == "DDR") DATA_RATE_BINARY <= DDR;
      else begin
         #1;
         $display("Attribute Syntax Error : The attribute DATA_RATE on %s instance %m is set to %s.  Legal values for this attribute are SDR or DDR\n", MODULE_NAME, DATA_RATE);
         data_rate_err_flag = 1;
         end

//-----------------------------------------------------------------------------
//----------------- DELAY_SRC  Check ------------------------------------------
//-----------------------------------------------------------------------------
      if (DELAY_SRC == "IO") begin
         DELAY_SRC_BINARY = IO;
         force_rx_reg = 0;
         force_dly_dir_reg = 0;
         end
      else if (DELAY_SRC == "IDATAIN") begin
         DELAY_SRC_BINARY = I;
         force_rx_reg = 1;
         force_dly_dir_reg = 1;
         end
      else if (DELAY_SRC == "ODATAIN") begin
         DELAY_SRC_BINARY = O;
         force_rx_reg = 0;
         force_dly_dir_reg = 1;
         end
      else  begin
         #1;
         $display("Attribute Syntax Error : The Attribute DELAY_SRC on %s instance %m is set to %s.  Legal values for this attribute are IO, IDATAIN or ODATAIN.\n", MODULE_NAME, DELAY_SRC);
         delay_src_err_flag = 1;
         end

//-----------------------------------------------------------------------------
//----------------- IDELAY2_VALUE Check ---------------------------------------
//-----------------------------------------------------------------------------
      if ((IDELAY2_VALUE >= 0) && (IDELAY2_VALUE <= 255)) begin
         IDELAY2_VALUE_BINARY = IDELAY2_VALUE;
         if (IDELAY_MODE == "PCI") begin
                                   idelay_val_ne_m_reg   = IDELAY2_VALUE;
                                   idelay_val_ne_s_reg   = IDELAY2_VALUE;
                                   end
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The Attribute IDELAY2_VALUE on %s instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, ... 253, 254, 255.\n", MODULE_NAME, IDELAY2_VALUE);
         idelay2_value_err_flag = 1;
         end

//-----------------------------------------------------------------------------
//----------------- IDELAY_MODE Check -----------------------------------------
//-----------------------------------------------------------------------------
      if (IDELAY_MODE == "NORMAL") begin
         IDELAY_MODE_BINARY = NORMAL;
         pci_ce_reg = 0;
         end
      else if (IDELAY_MODE == "PCI") begin
         IDELAY_MODE_BINARY = PCI;
         pci_ce_reg = 1;
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The Attribute IDELAY_MODE on %s instance %m is set to %s.  Legal values for this attribute are NORMAL or PCI.\n", MODULE_NAME, IDELAY_MODE);
         idelay_mode_err_flag = 1;
         end

//-----------------------------------------------------------------------------
//----------------- IDELAY_TYPE Check -----------------------------------------
//-----------------------------------------------------------------------------
      if (IDELAY_TYPE == "DEFAULT") begin
         IDELAY_TYPE_BINARY = DEFAULT;
         end
      else if (IDELAY_TYPE == "DIFF_PHASE_DETECTOR") begin
         IDELAY_TYPE_BINARY = DIFF_PHASE_DETECTOR;
         sat_at_max_reg = WRAPAROUND;
         rst_to_half_reg = 1;
         if (DELAY_SRC != "IDATAIN") begin
            #1;
            $display("Attribute Syntax Error : The Attribute IDELAY_TYPE on %s instance %m is set to %s and the attribute DELAY_SRC is set to %s. DELAY_SRC must be set to IDATAIN when IDELAY_TYPE is set to %s.\n", MODULE_NAME, IDELAY_TYPE, DELAY_SRC, IDELAY_TYPE);
            idelay_type_err_flag = 1;
            end
         if (IDELAY_MODE != "NORMAL") begin
            #1;
            $display("Attribute Syntax Error : The Attribute IDELAY_TYPE on %s instance %m is set to %s and the attribute IDELAY_MODE is set to %s. IDELAY_MODE must be set to NORMAL when IDELAY_TYPE is set to %s.\n", MODULE_NAME, IDELAY_TYPE, IDELAY_MODE, IDELAY_TYPE);
            idelay_type_err_flag = 1;
            end
         if ((SERDES_MODE != "MASTER") && (SERDES_MODE != "SLAVE")) begin
            #1;
            $display("Attribute Syntax Error : The Attribute IDELAY_TYPE on %s instance %m is set to %s and the attribute SERDES_MODE is set to %s. SERDES_MODE must be set to MASTER or SLAVE when IDELAY_TYPE is set to %s.\n", MODULE_NAME, IDELAY_TYPE, SERDES_MODE, IDELAY_TYPE);
            idelay_type_err_flag = 1;
            end
         if (COUNTER_WRAPAROUND != "WRAPAROUND") begin
            #1;
            $display("Attribute Syntax Error : The Attribute IDELAY_TYPE on %s instance %m is set to %s and the attribute COUNTER_WRAPAROUND is set to %s. COUNTER_WRAPAROUND must be set to WRAPAROUND when IDELAY_TYPE is set to %s.\n", MODULE_NAME, IDELAY_TYPE, COUNTER_WRAPAROUND, IDELAY_TYPE);
            idelay_type_err_flag = 1;
            end
         end
      else if (IDELAY_TYPE == "FIXED") begin
         IDELAY_TYPE_BINARY = FIXED;
         end
      else if (IDELAY_TYPE == "VARIABLE_FROM_HALF_MAX") begin
         IDELAY_TYPE_BINARY = VAR;
         rst_to_half_reg = 1;   // variable from half max
         end
      else if (IDELAY_TYPE == "VARIABLE_FROM_ZERO") begin
         IDELAY_TYPE_BINARY = VAR;
         rst_to_half_reg = 0;   // variable from zero
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The Attribute IDELAY_TYPE on %s instance %m is set to %s.  Legal values for this attribute are DEFAULT, DIFF_PHASE_DETECTOR, FIXED, VARIABLE_FROM_HALF_MAX, or VARIABLE_FROM_ZERO.\n", MODULE_NAME, IDELAY_TYPE);
         idelay_type_err_flag = 1;
         end

//-----------------------------------------------------------------------------
//----------------- IDELAY_VALUE Check ----------------------------------------
//-----------------------------------------------------------------------------
      if ((IDELAY_VALUE >= 0) && (IDELAY_VALUE <= 255)) begin
         IDELAY_VALUE_BINARY = IDELAY_VALUE;
         idelay_val_pe_m_reg   = IDELAY_VALUE;
         idelay_val_pe_s_reg   = IDELAY_VALUE;
         if (IDELAY_MODE != "PCI") begin
                                   idelay_val_ne_m_reg   = IDELAY_VALUE;
                                   idelay_val_ne_s_reg   = IDELAY_VALUE;
                                   end
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The Attribute IDELAY_VALUE on %s instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, ... 253, 254, 255.\n", MODULE_NAME, IDELAY_VALUE);
         idelay_value_err_flag = 1;
         end

//-----------------------------------------------------------------------------
//----------------- ODELAY_VALUE Check ----------------------------------------
//-----------------------------------------------------------------------------
      if ((ODELAY_VALUE >= 0) && (ODELAY_VALUE <= 255)) begin
         ODELAY_VALUE_BINARY = ODELAY_VALUE;
         odelay_val_pe_reg   = ODELAY_VALUE;
         odelay_val_ne_reg   = ODELAY_VALUE;
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The Attribute ODELAY_VALUE on %s instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, ... 253, 254, 255.\n", MODULE_NAME, ODELAY_VALUE);
         odelay_value_err_flag = 1;
         end

//-----------------------------------------------------------------------------
//----------------- SERDES_MODE Check -----------------------------------------
//-----------------------------------------------------------------------------
      if (SERDES_MODE == "NONE") begin
         SERDES_MODE_BINARY = NONE;
         end
      else if (SERDES_MODE == "MASTER") begin
         SERDES_MODE_BINARY = MASTER;
         end
      else if (SERDES_MODE == "SLAVE") begin
         SERDES_MODE_BINARY = SLAVE;
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The Attribute SERDES_MODE on %s instance %m is set to %s.  Legal values for this attribute are NONE, MASTER, or SLAVE.\n", MODULE_NAME, SERDES_MODE);
         serdes_mode_err_flag = 1;
      end
//-----------------------------------------------------------------------------
//----------------- SIM_TAPDELAY_VALUE Check ----------------------------------
//-----------------------------------------------------------------------------
      if ((SIM_TAPDELAY_VALUE >= 10) && (SIM_TAPDELAY_VALUE <= 90)) begin
         SIM_TAPDELAY_VALUE_BINARY = SIM_TAPDELAY_VALUE;
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The Attribute SIM_TAPDELAY_VALUE on %s instance %m is set to %d.  Legal values for this attribute are between 10 and 90 ps inclusive.\n", MODULE_NAME, SIM_TAPDELAY_VALUE);
         sim_tap_delay_err_flag = 1;
         end

   if ( counter_wraparound_err_flag || serdes_mode_err_flag ||
        odelay_value_err_flag || idelay_value_err_flag ||
        idelay_type_err_flag || idelay_mode_err_flag ||
        delay_src_err_flag || idelay2_value_err_flag ||
        sim_tap_delay_err_flag || data_rate_err_flag) begin
      attr_err_flag = 1; 
      #1;
      $display("Attribute Errors detected in %s instance %m: Simulation cannot continue. Exiting. \n", MODULE_NAME);
      $finish;
      end

   end //initial begin parameter check

//-----------------------------------------------------------------------------
//-------------------- Input / Output -----------------------------------------
//-----------------------------------------------------------------------------
   assign #(out_delay) BUSY_OUTDELAY = BUSY_OUT;
   assign #(out_delay) DATAOUT_OUTDELAY = DATAOUT_OUT;
   assign #(out_delay) DATAOUT2_OUTDELAY = DATAOUT2_OUT;
   assign #(out_delay) DOUT_OUTDELAY = DOUT_OUT;
   assign #(out_delay) TOUT_OUTDELAY = TOUT_OUT;

   assign #(in_delay)  CAL_INDELAY = CAL_IN;
   assign #(in_delay)  CE_INDELAY = CE_IN;
   assign #(clk_delay) CLK_INDELAY = CLK_IN;
   assign #(in_delay)  INC_INDELAY = INC_IN;
   assign #(clk_delay) IOCLK0_INDELAY = IOCLK0_IN;
   assign #(clk_delay) IOCLK1_INDELAY = IOCLK1_IN;
   assign #(in_delay)  RST_INDELAY = RST_IN;
   assign #(in_delay)  T_INDELAY = T_IN;
   assign #(in_delay)  GSR_INDELAY = GSR_IN;

//-----------------------------------------------------------------------------
//----------------- I/O Assignments / Mux -------------------------------------
//-----------------------------------------------------------------------------
   // input delay paths
   assign DATAOUT_OUT = delay1_out_sig;
   assign DATAOUT2_OUT = (pci_ce_reg == 0) ? delay1_out_sig : delay2_out;
   assign TOUT_OUT = (~output_delay_off && (~T_INDELAY || input_delay_off)) ?
               tout_out_int : T_INDELAY;

   assign delay1_out_sig = ((IDELAY_TYPE_BINARY == DIFF_PHASE_DETECTOR) &&
                            (SERDES_MODE_BINARY == SLAVE) &&
                            (delay_val_pe_1 < half_max) ) ?
                           delay1_out_dly : delay1_out;
// output delay paths
   assign DOUT_OUT = (~output_delay_off && (~T_INDELAY || input_delay_off)) ?  delay1_out : 1'b0;
   initial begin
   first_edge <= #150 1;
   wait (GSR_INDELAY === 1'b0);
      end //initial begin other initializations

//-----------------------------------------------------------------------------
//----------------- GLOBAL hidden GSR pin -------------------------------------
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
//----------------- Bulk Input/Output Delay -----------------------------------
//-----------------------------------------------------------------------------
    always @(IDATAIN_IN) IDATAIN_INDELAY <= #(SIM_IDATAIN_INDELAY) IDATAIN_IN;
    always @(ODATAIN_IN) ODATAIN_INDELAY <= #(SIM_ODATAIN_INDELAY) ODATAIN_IN;

//-----------------------------------------------------------------------------
//----------------- DDR Doubler       -----------------------------------------
//-----------------------------------------------------------------------------
    always @(posedge IOCLK0_INDELAY) begin
       if (first_edge == 1) begin
          ioclk0_int <= 1;
          ioclk0_int <= #100 0;
          end
       end

    generate if(DATA_RATE == "DDR")
       always @(posedge IOCLK1_INDELAY) begin
          if (first_edge== 1) begin
             ioclk1_int <= 1;
             ioclk1_int <= #100 0;
             end
          end
    endgenerate

    assign ioclk_int = ioclk0_int | ioclk1_int;

//-----------------------------------------------------------------------------
//----------------- Delay Line Inputs -----------------------------------------
//-----------------------------------------------------------------------------
   always @(posedge ioclk_int) begin
     delay1_out_dly <= delay1_out;
   end

// delay line 1 input
   always @(IDATAIN_INDELAY or DATAOUT_OUT or T_INDELAY or ODATAIN_INDELAY or GSR_INDELAY) begin
      if ((T_INDELAY || output_delay_off) && ~input_delay_off) begin // input delay
         if   (pci_ce_reg == 0 ) delay1_in <= IDATAIN_INDELAY; // NORMAL
         else                    delay1_in <= IDATAIN_INDELAY ^ DATAOUT_OUT; // PCI
         end
      else begin                   // output delay
         if (output_delay_off)   delay1_in <= 0;
         else                    delay1_in <= ODATAIN_INDELAY;
         end
      end

// delay line 2 input
   always @(IDATAIN_INDELAY or DATAOUT2_OUT or T_INDELAY or ODATAIN_INDELAY or GSR_INDELAY) begin
      if ((T_INDELAY || output_delay_off) && ~input_delay_off) begin // input delay
         if   (pci_ce_reg == 0 ) delay2_in <= ~IDATAIN_INDELAY; // NORMAL
         else                    delay2_in <=  IDATAIN_INDELAY ^ DATAOUT2_OUT; // PCI
         end
      else begin          // output delay
         if (output_delay_off)   delay2_in <= 0;
         else                    delay2_in <= ~ODATAIN_INDELAY;
         end
      end

//-----------------------------------------------------------------------------
//----------------- Delay Lines -----------------------------------------------
//-----------------------------------------------------------------------------
   always @(delay1_in or GSR_INDELAY) begin
      if (GSR_INDELAY) begin
         delay1_reached_1 <= 1'b0;
         delay1_reached_2 <= 1'b0;
         delay1_working_1 <= 1'b0;
         delay1_working_2 <= 1'b0;
         delay1_ignore  <= delay1_in;
         end
      else if (delay1_in) begin
         if (~delay1_working || delay1_reached) begin
            if (delay1_working_1 == 1'b0) delay1_working_1  <= 1'b1;
            else delay1_working_2  <= 1'b1;
            if ((T_INDELAY || output_delay_off) && ~input_delay_off) begin // input delay
               if (IDATAIN_INDELAY) begin // positive edge
                  if (delay1_reached_1 == 1'b0)
                      delay1_reached_1 <= #(SIM_TAPDELAY_VALUE*delay_val_pe_1) 1'b1;
                  else
                      delay1_reached_2 <= #(SIM_TAPDELAY_VALUE*delay_val_pe_1) 1'b1;
                  end
               else begin // negative edge
                  if (delay1_reached_1 == 1'b0)
                      delay1_reached_1 <= #(SIM_TAPDELAY_VALUE*delay_val_ne_1) 1'b1;
                  else
                      delay1_reached_2 <= #(SIM_TAPDELAY_VALUE*delay_val_ne_1) 1'b1;
                  end
               end
            else begin // output delay
               if (ODATAIN_INDELAY) begin // positive edge
                  if (delay1_reached_1 == 1'b0)
                      delay1_reached_1 <= #(SIM_TAPDELAY_VALUE*delay_val_pe_1) 1'b1;
                  else
                      delay1_reached_2 <= #(SIM_TAPDELAY_VALUE*delay_val_pe_1) 1'b1;
                  end
               else begin // negative edge
                  if (delay1_reached_1 == 1'b0)
                      delay1_reached_1 <= #(SIM_TAPDELAY_VALUE*delay_val_ne_1) 1'b1;
                  else
                      delay1_reached_2 <= #(SIM_TAPDELAY_VALUE*delay_val_ne_1) 1'b1;
                  end
               end
            end
         else begin
            delay1_ignore <= 1'b1;
            end
         end
      end

   always @(delay2_in or GSR_INDELAY) begin
      if (GSR_INDELAY) begin
         delay2_reached_1 <= 1'b0;
         delay2_reached_2 <= 1'b0;
         delay2_working_1 <= 1'b0;
         delay2_working_2 <= 1'b0;
         delay2_ignore  <= delay2_in;
         end
      else if (delay2_in) begin
         if (~delay2_working || delay2_reached) begin
            if (delay2_working_1 == 1'b0) delay2_working_1  <= 1'b1;
            else delay2_working_2  <= 1'b1;
            if ((T_INDELAY || output_delay_off) && ~input_delay_off) begin // input delay
               if (IDATAIN_INDELAY) begin // positive edge
                  if (delay2_reached_1 == 1'b0)
                      delay2_reached_1 <= #(SIM_TAPDELAY_VALUE*delay_val_pe_2) 1'b1;
                  else
                      delay2_reached_2 <= #(SIM_TAPDELAY_VALUE*delay_val_pe_2) 1'b1;
                  end
               else begin // negative edge
                  if (delay2_reached_1 == 1'b0)
                      delay2_reached_1 <= #(SIM_TAPDELAY_VALUE*delay_val_ne_2) 1'b1;
                  else
                      delay2_reached_2 <= #(SIM_TAPDELAY_VALUE*delay_val_ne_2) 1'b1;
                  end
               end
            else begin // output delay
               if (ODATAIN_INDELAY) begin // positive edge
                  if (delay2_reached_1 == 1'b0)
                      delay2_reached_1 <= #(SIM_TAPDELAY_VALUE*delay_val_pe_2) 1'b1;
                  else
                      delay2_reached_2 <= #(SIM_TAPDELAY_VALUE*delay_val_pe_2) 1'b1;
                  end
               else begin // negative edge
                  if (delay2_reached_1 == 1'b0)
                      delay2_reached_1 <= #(SIM_TAPDELAY_VALUE*delay_val_ne_2) 1'b1;
                  else
                      delay2_reached_2 <= #(SIM_TAPDELAY_VALUE*delay_val_ne_2) 1'b1;
                  end
               end
            end
         else begin
            delay2_ignore <= 1'b1;
            end
         end
      end

   always @(posedge delay1_reached) begin
      delay1_ignore  <= #1 1'b0;
      end

   always @(posedge delay1_reached_1) begin
      delay1_working_1 <= #1 1'b0;
      delay1_reached_1 <= #1 1'b0;
      end

   always @(posedge delay1_reached_2) begin
      delay1_working_2 <= #1 1'b0;
      delay1_reached_2 <= #1 1'b0;
      end

   always @(posedge delay2_reached) begin
      delay2_ignore  <= #1 1'b0;
      end

   always @(posedge delay2_reached_1) begin
      delay2_working_1 <= #1 1'b0;
      delay2_reached_1 <= #1 1'b0;
      end

   always @(posedge delay2_reached_2) begin
      delay2_working_2 <= #1 1'b0;
      delay2_reached_2 <= #1 1'b0;
      end

//-----------------------------------------------------------------------------
//----------------- Output FF -------------------------------------------------
//-----------------------------------------------------------------------------
   always @(posedge delay1_reached or posedge delay2_reached or delay1_working or delay2_working or posedge delay1_ignore or posedge delay2_ignore or T_INDELAY or GSR_INDELAY) begin
      if ((pci_ce_reg == 0) || (~T_INDELAY && ~output_delay_off) ||
          input_delay_off) begin //NORMAL in or output
         if (GSR_INDELAY || ~first_edge || (~delay1_working && ~delay2_working)) begin
            delay1_out <= delay1_in;
            end
         else if ( (delay1_reached && ~delay1_ignore) ||
              (delay1_ignore && ~delay1_out) ) begin
            delay1_out <= 1'b1;
            end
         else if ( (delay2_reached && ~delay2_ignore) ||
              (delay2_ignore &&  delay1_out) ) begin
            delay1_out <= 1'b0;
            end
         delay2_out <= 1'b0;
         end
      else begin // PCI in
         if (GSR_INDELAY || delay1_reached) begin
            delay1_out <= IDATAIN_INDELAY;
            end
         if (GSR_INDELAY || delay2_reached) begin
            delay2_out <= IDATAIN_INDELAY;
            end
         end
      end
//-----------------------------------------------------------------------------
//----------------- TOUT delay ------------------------------------------------
//-----------------------------------------------------------------------------
   always @(T_INDELAY) begin
      #(SIM_TAPDELAY_VALUE);
      tout_out_int <= T_INDELAY;
      end

//-----------------------------------------------------------------------------
//----------------- Delay Preset Values ---------------------------------------
//-----------------------------------------------------------------------------
   assign delay_val_pe_clk = sync_to_data_reg ? delay1_in : ioclk_int;
   assign delay_val_ne_clk = sync_to_data_reg ? delay2_in : ioclk_int;

   always @(posedge delay_val_pe_clk or posedge rst_sig or posedge busy_out_int) begin
      if ((rst_sig == 1'b1) || (busy_out_int == 1'b1)) begin
         busy_out_dly <= 1'b1;
         busy_out_dly1 <= 1'b1;
         end
      else begin
         busy_out_dly <= busy_out_dly1;
         busy_out_dly1 <= busy_out_int;
         end
      end


   always @(posedge delay_val_pe_clk or rst_sig) begin
      if ((~T_INDELAY && ~output_delay_off) || input_delay_off) begin // output
            delay_val_pe_1 <= odelay_val_pe_reg;
            delay_val_pe_2 <= odelay_val_pe_reg;
            end
      // input delays
      else if (IDELAY_TYPE_BINARY == DEFAULT) begin
         delay_val_pe_1 <= default_value;
         delay_val_pe_2 <= default_value;
         end
      else if (IDELAY_TYPE_BINARY == FIXED) begin
         if (pci_ce_reg == 1) begin // PCI
            delay_val_pe_1 <= IDELAY_VALUE_BINARY[7:0];
            delay_val_pe_2 <= IDELAY2_VALUE_BINARY[7:0];
            end
         else begin // normal
            delay_val_pe_1 <= IDELAY_VALUE_BINARY[7:0];
            delay_val_pe_2 <= IDELAY_VALUE_BINARY[7:0];
            end
         end
      else if (IDELAY_TYPE_BINARY == VAR) begin
         if (pci_ce_reg == 1) begin // PCI
            delay_val_pe_1 <= idelay_val_pe_reg;
            delay_val_pe_2 <= idelay_val_ne_reg;
            end
         else begin // normal
            delay_val_pe_1 <= idelay_val_pe_reg;
            delay_val_pe_2 <= idelay_val_ne_reg;
            end
         end
      else if (IDELAY_TYPE_BINARY == DIFF_PHASE_DETECTOR) begin
         delay_val_pe_1 <= idelay_val_pe_reg;
         delay_val_pe_2 <= idelay_val_ne_reg;
         end
      else begin // default
         delay_val_pe_1 <= default_value;
         delay_val_pe_2 <= default_value;
         end
      end

   always @(posedge delay_val_ne_clk or rst_sig) begin
      if ((~T_INDELAY && ~output_delay_off) || input_delay_off) begin // output
         delay_val_ne_1 <= odelay_val_ne_reg;
         delay_val_ne_2 <= odelay_val_ne_reg;
         end
      //input delays
      else if (IDELAY_TYPE_BINARY == DEFAULT) begin
         delay_val_ne_1 <= default_value;
         delay_val_ne_2 <= default_value;
         end
      else if (IDELAY_TYPE_BINARY == FIXED) begin
         if (pci_ce_reg == 1) begin // PCI
            delay_val_ne_1 <= IDELAY_VALUE_BINARY[7:0];
            delay_val_ne_2 <= IDELAY2_VALUE_BINARY[7:0];
            end
         else begin // normal
            delay_val_ne_1 <= IDELAY_VALUE_BINARY[7:0];
            delay_val_ne_2 <= IDELAY_VALUE_BINARY[7:0];
            end
         end
      else if (IDELAY_TYPE_BINARY == VAR) begin
         if (pci_ce_reg == 1) begin // PCI
            delay_val_ne_1 <= idelay_val_pe_reg;
            delay_val_ne_2 <= idelay_val_ne_reg;
            end
         else begin // normal
            delay_val_ne_1 <= idelay_val_pe_reg;
            delay_val_ne_2 <= idelay_val_ne_reg;
            end
         end
      else if (IDELAY_TYPE_BINARY == DIFF_PHASE_DETECTOR) begin
         delay_val_ne_1 <= idelay_val_pe_reg;
         delay_val_ne_2 <= idelay_val_ne_reg;
         end
      else begin // default
         delay_val_ne_1 <= default_value;
         delay_val_ne_2 <= default_value;
         end
      end

//-----------------------------------------------------------------------------
//----------------- Max Count CAL ---------------------------------------------
//-----------------------------------------------------------------------------

   always @(posedge CLK_INDELAY or posedge GSR_INDELAY) begin
      if (GSR_INDELAY) begin
         cal_count <= 5'b10010;
         busy_out_int <= 1'b1; // reset
         end
      else if (cal_sig && ~busy_out_int) begin
         cal_count <= 5'b00000;
         busy_out_int <= 1'b1; // begin cal
         end
      else if (ce_sig && ~busy_out_int) begin
         cal_count <= 5'b10010;
         busy_out_int <= 1'b1; // inc (busy high 2 clocks)
         end
      else if (busy_out_int && (cal_count < 5'b10011) ) begin
         cal_count <= cal_count + 1;
         busy_out_int <= 1'b1; // continue
         end
      else begin
         busy_out_int <= 1'b0; // done
         end
      end

   always @(posedge ioclk_int) begin
      if (~calibrate & ~calibrate_done && busy_out_int && (cal_count == 5'b01000) )
         calibrate <= 1'b1;
      else
         calibrate <= 1'b0;
      end

   always @(cal_delay or calibrate or GSR_INDELAY or cal_sig or busy_out_int) begin
      if ((GSR_INDELAY) || (cal_sig && ~busy_out_int)) begin
         cal_delay <= 8'h00;
         calibrate_done <= 1'b0;
         end
      else if (calibrate && (cal_delay !== 8'hff)) begin
         #(SIM_TAPDELAY_VALUE);
         if (calibrate) begin
            cal_delay <= cal_delay + 1;
            end
         else begin 
            if ((pci_ce_reg == 1) && (DATA_RATE_BINARY == SDR)) begin
               cal_delay <= cal_delay >> 1;
               end
            calibrate_done <= 1'b1;
            end
         end
      else if (calibrate && (cal_delay == 8'hff)) begin
         calibrate_done <= 1'b1;
         end
      else begin
         #(SIM_TAPDELAY_VALUE);
         calibrate_done <= 1'b0;
         end
      end

//-----------------------------------------------------------------------------
//----------------- Delay Value Registers (INC/DEC) ---------------------------
//-----------------------------------------------------------------------------
   always @(posedge CLK_INDELAY or rst_sig or GSR_INDELAY) begin
      inc_dec;
      end

   always @(calibrate_done) begin
      if (calibrate_done) begin
         max_delay <= cal_delay;
         half_max  <= cal_delay >> 1;
         end
      end

   assign  BUSY = BUSY_OUTDELAY;
   assign  DATAOUT = DATAOUT_OUTDELAY;
   assign  DATAOUT2 = DATAOUT2_OUTDELAY;
   assign  DOUT = DOUT_OUTDELAY;
   assign  TOUT = TOUT_OUTDELAY;

   assign CAL_IN = CAL;
   assign CE_IN = CE;
   assign  CLK_IN = CLK;
   assign IDATAIN_IN = IDATAIN;
   assign INC_IN = INC;
   assign  IOCLK0_IN = IOCLK0;
   assign  IOCLK1_IN = IOCLK1;
   assign ODATAIN_IN = ODATAIN;
   assign RST_IN = RST;
   assign T_IN = T;
   assign GSR_IN = GSR;
  specify
    ( CLK => BUSY) = (100, 100);
    ( T => TOUT) = (0, 0);

    specparam PATHPULSE$ = 0;
  endspecify
endmodule // IODELAY2
