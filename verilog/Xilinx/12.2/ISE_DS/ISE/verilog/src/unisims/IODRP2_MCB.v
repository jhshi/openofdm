// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/stan/IODRP2_MCB.v,v 1.14 2009/11/05 16:59:56 robh Exp $
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
//  /  /                        IODELAY2 Dynamic Reconfiguration Port for MCB
// /__/   /\      Filename    : IODRP2_MCB.v
// \  \  /  \    
//  \__\/\__ \
//
//  Revision:      Date:  Comment
//       1.0:  09/30/08:  Initial version. From IODELAY2/IODRP2
//       1.1   11/05/2008 I/O, structure change
//                        Correct BKST functionality
//       1.2   11/19/2008 Change SIM_TAP_DELAY to SIM_TAPDELAY_VALUE
//       1.3   11/21/2008 Change AUX_SDO_OUTDELAY to AUXSDO_OUTDELAY
//       1.4   01/29/2009 IR504942, 504805, 504692 sync to data
//                        IR506027 DQSOUT's
//       1.5   02/04/2009 CR506027 IODRP state machine, sync_to_data off
//             02/04/2009 CR502236 lumped delay reg
//       1.6   02/12/2009 CR1016 update DOUT to match HW
//       1.7   03/05/2009 CR511015 VHDL - VER sync
//                        CR511054 Output at time 0 fix
//       1.8 : 04/09/2009 CR480001 fix calibration.
//       1.9 : 04/22/2009 CR518721 ODELAY value fix at time 0
//       1.10: 05/08/2009 CR521007 missing assign SDO_OUT to SDO
//       1.11: 05/19/2009 CR522171 Missing else in if-else-else. delay values
//       1.12: 07/23/2009 CR527208 Race condition in cal sig
//       1.13: 08/07/2009 CR511054 Time 0 output initialization
//                        CR529368 Input bypass ouput when delay line idle
//       1.14: 09/01/2009 CR531995 remove pci_ce_reg, byp_ts_ff_reg, byp_op_ff_reg from addr6
//       1.15: 11/04/2009 CR538116 fix calibrate_done when cal_delay saturates
// End Revision
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module IODRP2_MCB (
  AUXSDO,
  DATAOUT,
  DATAOUT2,
  DOUT,
  DQSOUTN,
  DQSOUTP,
  SDO,
  TOUT,
  ADD,
  AUXADDR,
  AUXSDOIN,
  BKST,
  CLK,
  CS,
  IDATAIN,
  IOCLK0,
  IOCLK1,
  MEMUPDATE,
  ODATAIN,
  SDI,
  T
);

  parameter DATA_RATE = "SDR";       // "SDR", "DDR"
  parameter integer IDELAY_VALUE = 0;   // 0 to 255 inclusive
  parameter integer MCB_ADDRESS = 0; // 0 to 15
  parameter integer ODELAY_VALUE = 0;   // 0 to 255 inclusive
  parameter SERDES_MODE = "NONE";       // "NONE", "MASTER", "SLAVE"
  parameter integer SIM_TAPDELAY_VALUE = 75; // 10 to 90 inclusive

  localparam IDELAY_MODE = "NORMAL";  // "NORMAL", "PCI"
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

  output AUXSDO;
  output DATAOUT2;
  output DATAOUT;
  output DOUT;
  output DQSOUTN;
  output DQSOUTP;
  output SDO;
  output TOUT;

  input ADD;
  input AUXSDOIN;
  input BKST;
  input CLK;
  input CS;
  input IDATAIN;
  input IOCLK0;
  input IOCLK1;
  input MEMUPDATE;
  input ODATAIN;
  input SDI;
  input T;
  input [4:0] AUXADDR;




  reg COUNTER_WRAPAROUND_BINARY = WRAPAROUND;
  reg DATA_RATE_BINARY = SDR;
  reg [7:0] IDELAY2_VALUE_BINARY = 0;
  reg IDELAY_MODE_BINARY = NORMAL;
  reg [3:0] IDELAY_TYPE_BINARY = VAR;
  reg SERDES_MODE_BINARY = NONE;
  reg [3:0] MCB_ADDRESS_BINARY = 4'b0;
  reg [6:0] SIM_TAPDELAY_VALUE_BINARY = 75;
  reg [7:0] IDELAY_VALUE_BINARY = 0;
  reg [7:0] ODELAY_VALUE_BINARY = 0;

  tri0 GSR = glbl.GSR;

  wire AUXSDO_OUT;
  wire DATAOUT2_OUT;
  wire DATAOUT_OUT;
  wire DOUT_OUT;
  wire DQSOUTN_OUT;
  wire DQSOUTP_OUT;
  wire SDO_OUT;
  wire TOUT_OUT;
  wire AUXSDO_OUTDELAY;
  wire DATAOUT2_OUTDELAY;
  wire DATAOUT_OUTDELAY;
  wire DOUT_OUTDELAY;
  wire DQSOUTN_OUTDELAY;
  wire DQSOUTP_OUTDELAY;
  wire SDO_OUTDELAY;
  wire TOUT_OUTDELAY;

  wire ADD_IN;
  wire AUXSDOIN_IN;
  wire BKST_IN;
  wire CLK_IN;
  wire CS_IN;
  wire IDATAIN_IN;
  wire IOCLK0_IN;
  wire IOCLK1_IN;
  wire MEMUPDATE_IN;
  wire ODATAIN_IN;
  wire SDI_IN;
  wire T_IN;
  wire [4:0] AUXADDR_IN;
  wire GSR_IN;
  wire ADD_INDELAY;
  wire AUXSDOIN_INDELAY;
  wire BKST_INDELAY;
  wire CLK_INDELAY;
  wire CS_INDELAY;
  wire IDATAIN_INDELAY;
  wire IOCLK0_INDELAY;
  wire IOCLK1_INDELAY;
  wire MEMUPDATE_INDELAY;
  wire ODATAIN_INDELAY;
  wire SDI_INDELAY;
  wire T_INDELAY;
  wire [4:0] AUXADDR_INDELAY;
  wire GSR_INDELAY;
//-----------------------------------------------------------------------------
//------------------- constants -----------------------------------------------
//-----------------------------------------------------------------------------
  localparam in_delay = 110;
  localparam out_delay = 0;
  localparam clk_delay = 1;
  localparam MODULE_NAME = "IODRP2_MCB";
  localparam IDLE = 0,
             ADDR_ACTIVE = 1,
             DATA_ACTIVE = 2;

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
  wire cs_sig;
  wire snapback_sig;
  wire half_sig;
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
  reg mcb_address_err_flag = 0;
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
  reg sync_to_data_reg = 0;
  reg pci_ce_reg = 0;

  reg [7:0] data_reg = 8'h00;
  reg [7:0] addr_reg = 8'h80;
  reg mem_updated = 1'b1;
  reg [7:0] shift_out = 8'h00;
  reg [7:0] mask = 8'h00;
  reg [7:0] mc_iob [0:8];
  reg [7:0] mc_iob_mask [0:8];
  reg [2:0] if_state = IDLE;
  reg cal_reg = 0;
  reg snapback_reg = 0;
  reg half_reg = 0;
  reg inc_reg = 0;
  reg ce_reg = 0;
  reg rst_reg = 0;
  reg direct_in_reg = 0;
  reg [1:0] event_sel_m_reg = 2'b0;
  reg plus1_s_reg = 1'b0;
  reg [3:0] lumped_delay_select_reg = 4'h0;
  reg lumped_delay_reg = 0;


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
task write_to_ioi;
begin
   case (addr_reg[6:0])
      7'h01: begin
                {cal_reg, snapback_reg, half_reg, inc_reg, ce_reg, rst_reg} <= data_reg[5:0];
                shift_out <= 8'h0;
             end
      7'h02: begin
                idelay_val_pe_m_reg <= data_reg;
                idelay_val_pe_s_reg <= data_reg;
                shift_out <= data_reg;
             end
      7'h03: begin
                idelay_val_ne_m_reg <= data_reg;
                idelay_val_ne_s_reg <= data_reg;
                shift_out <= data_reg;
             end
      7'h04: begin
                odelay_val_pe_reg <= data_reg;
                shift_out <= data_reg;
             end
      7'h05: begin
                odelay_val_ne_reg <= data_reg;
                shift_out <= data_reg;
             end
      7'h06: begin
               if (SERDES_MODE_BINARY == SLAVE) begin
                  {direct_in_reg, force_rx_reg, force_dly_dir_reg} <= data_reg[4:2];
                  plus1_s_reg <= data_reg[0];
                  shift_out <= {3'b0, data_reg[4:2], 1'b0, data_reg[0]};
                  end
               else begin
                  {direct_in_reg, force_rx_reg, force_dly_dir_reg, event_sel_m_reg} <= data_reg[4:0];
                   shift_out <= {3'b0, data_reg[4:0]};
                  end
            end
      7'h07: begin
                {lumped_delay_select_reg, lumped_delay_reg, sync_to_data_reg, sat_at_max_reg, rst_to_half_reg} <= data_reg;
                shift_out <= data_reg;
             end
      7'h08: begin
             max_delay <= data_reg;
             half_max  <= data_reg >> 1;
             shift_out <= data_reg;
             end
      default: ;
   endcase
   end
endtask

task read_from_ioi;
begin
   case (addr_reg[6:0])
      7'h00: shift_out <= 8'h0;
      7'h01: shift_out <= 8'h0; // w/o {2'b0, cal_reg, snapback_reg, half_reg, inc_reg, ce_reg, rst_reg};
      7'h02: begin
             if (SERDES_MODE_BINARY == SLAVE)
               shift_out <= idelay_val_pe_s_reg;
             else
               shift_out <= idelay_val_pe_m_reg;
             end
      7'h03: begin
             if (SERDES_MODE_BINARY == SLAVE)
               shift_out <= idelay_val_ne_s_reg;
             else
               shift_out <= idelay_val_ne_m_reg;
             end
      7'h04: shift_out <= odelay_val_pe_reg;
      7'h05: shift_out <= odelay_val_ne_reg;
      7'h06: begin
            if (SERDES_MODE_BINARY == MASTER)
               shift_out <= {3'b0, direct_in_reg, force_rx_reg, force_dly_dir_reg, event_sel_m_reg};
            else
               shift_out <= {3'b0, direct_in_reg, force_rx_reg, force_dly_dir_reg, 1'b0, plus1_s_reg};
            end
      7'h07: shift_out <= {lumped_delay_select_reg, lumped_delay_reg, sync_to_data_reg, sat_at_max_reg, rst_to_half_reg};
      7'h08: shift_out <= max_delay;
      default: shift_out <= 8'h0;
   endcase
   end
endtask

  assign rst_sig = rst_reg;
  assign cal_sig = cal_reg;
  assign inc_sig = inc_reg;
  assign ce_sig = ce_reg;
  assign snapback_sig = snapback_reg;
  assign half_sig = half_reg;
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
//----------------- MCB_ADDRESS  Check ----------------------------------------
//-----------------------------------------------------------------------------
      if ((MCB_ADDRESS >= 0) && (MCB_ADDRESS <= 15)) begin
         MCB_ADDRESS_BINARY = MCB_ADDRESS;
         end
      else begin
         #1;
         $display("Attribute Syntax Error : The Attribute MCB_ADDRESS on %s instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, ... 13, 14, 15.\n", MODULE_NAME, MCB_ADDRESS);
         mcb_address_err_flag = 1;
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

   if ( serdes_mode_err_flag || odelay_value_err_flag ||
        idelay_value_err_flag || sim_tap_delay_err_flag) begin
      attr_err_flag = 1; 
      #1;
      $display("Attribute Errors detected in %s instance %m: Simulation cannot continue. Exiting. \n", MODULE_NAME);
      $finish;
      end

   end //initial begin parameter check

//-----------------------------------------------------------------------------
//-------------------- Input / Output -----------------------------------------
//-----------------------------------------------------------------------------
   assign #(out_delay) AUXSDO_OUTDELAY = AUXSDO_OUT;
   assign #(out_delay) DATAOUT_OUTDELAY = DATAOUT_OUT;
   assign #(out_delay) DATAOUT2_OUTDELAY = DATAOUT2_OUT;
   assign #(out_delay) DOUT_OUTDELAY = DOUT_OUT;
   assign #(out_delay) DQSOUTN_OUTDELAY = DQSOUTN_OUT;
   assign #(out_delay) DQSOUTP_OUTDELAY = DQSOUTP_OUT;
   assign #(out_delay) SDO_OUTDELAY = SDO_OUT;
   assign #(out_delay) TOUT_OUTDELAY = TOUT_OUT;

   assign #(in_delay)  ADD_INDELAY = ADD_IN;
   assign #(in_delay)  AUXADDR_INDELAY = AUXADDR_IN;
   assign #(in_delay)  AUXSDOIN_INDELAY = AUXSDOIN_IN;
   assign #(in_delay)  BKST_INDELAY = BKST_IN;
   assign #(clk_delay) CLK_INDELAY = CLK_IN;
   assign #(in_delay)  CS_INDELAY = CS_IN;
   assign #(in_delay)  IDATAIN_INDELAY = IDATAIN_IN;
   assign #(clk_delay) IOCLK0_INDELAY = IOCLK0_IN;
   assign #(clk_delay) IOCLK1_INDELAY = IOCLK1_IN;
   assign #(in_delay)  MEMUPDATE_INDELAY = MEMUPDATE_IN;
   assign #(in_delay)  ODATAIN_INDELAY = ODATAIN_IN;
   assign #(in_delay)  SDI_INDELAY = SDI_IN;
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
   assign #(SIM_TAPDELAY_VALUE) DOUT_OUT = (~output_delay_off && (~T_INDELAY || input_delay_off)) ?  delay1_in : 1'b0;
   assign DQSOUTN_OUT = ~delay1_out_sig;
   assign DQSOUTP_OUT =  delay1_out_sig;
   assign cs_sig = ((CS_INDELAY === 1'b1) && ((AUXADDR_INDELAY === {MCB_ADDRESS_BINARY,SERDES_MODE_BINARY}) || (BKST_INDELAY === 1'b1))) ? 1'b1 : 1'b0;
   assign AUXSDO_OUT   = cs_sig ? shift_out[0] : AUXSDOIN_INDELAY;
   assign SDO_OUT   = shift_out[0];

   initial begin
   first_edge <= #150 1;
   wait (GSR_INDELAY === 1'b0);
      mc_iob_mask     [0] = 8'h3f;
      mc_iob_mask     [1] = 8'hbf;
      mc_iob_mask     [2] = 8'h7f;
      mc_iob_mask     [3] = 8'hff;
      mc_iob_mask     [4] = 8'hff;
      mc_iob_mask     [5] = 8'hff;
      mc_iob_mask     [6] = 8'hff;
      mc_iob_mask     [7] = 8'hff;
      mc_iob_mask     [8] = 8'h7f;
      mc_iob          [0] = 8'h00;
      mc_iob          [1] = 8'h00;
      mc_iob          [2] = 8'h00;
      mc_iob          [3] = 8'h00;
      mc_iob          [4] = 8'h00;
      mc_iob          [5] = 8'h00;
      mc_iob          [6] = 8'h00;
      mc_iob          [7] = 8'h00;
      mc_iob          [8] = 8'h00;
      end //initial begin other initializations

//-----------------------------------------------------------------------------
//----------------- GLOBAL hidden GSR pin -------------------------------------
//-----------------------------------------------------------------------------


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
//----------------- Interface State Machine------------------------------------
//-----------------------------------------------------------------------------
   always @(posedge CLK_INDELAY) begin
      if (GSR_INDELAY || rst_sig) begin
         if_state  <= IDLE;
         shift_out <= 8'h00;
         addr_reg  <= 8'h80;
         data_reg  <= 8'h00;
         mem_updated <= 1'b1;
         cal_reg <= 0;
         snapback_reg <= 0;
         half_reg <= 0;
         inc_reg <= 0;
         ce_reg <= 0;
         rst_reg <= 0;
         end
      else begin
         if (cal_reg == 1)  cal_reg <= 0;
         if (snapback_reg == 1) snapback_reg <= 0;
         if (half_reg == 1) half_reg <= 0;
         if (inc_reg == 1) inc_reg <= 0;
         if (ce_reg == 1) ce_reg <= 0;
         case (if_state)
            IDLE: begin
               if (cs_sig && ADD_INDELAY) begin
                  if_state <= ADDR_ACTIVE;
                  addr_reg <= {SDI_INDELAY, addr_reg[7:1]};
                  shift_out <= {1'b0, shift_out[7:1]};
                  end
               else if (cs_sig && ~ADD_INDELAY ) begin
                  if_state <= DATA_ACTIVE;
                  data_reg <= {SDI_INDELAY, data_reg[7:1]};
                  shift_out <= {1'b0, shift_out[7:1]};
                  end
               else begin
                  if_state <= IDLE;
                  if (~addr_reg[7]) read_from_ioi;
                  else shift_out <= mc_iob[addr_reg[3:0]];
                  end
               end
            ADDR_ACTIVE: begin
               if (cs_sig && ADD_INDELAY) begin
                  if_state <= ADDR_ACTIVE;
                  addr_reg <= {SDI_INDELAY, addr_reg[7:1]};
                  shift_out <= {1'b0, shift_out[7:1]};
                  end
               else if (~cs_sig && ~ADD_INDELAY) begin
                  if_state <= IDLE;
                  if (~addr_reg[7]) read_from_ioi;
                  else shift_out <= mc_iob[addr_reg[3:0]];
                  end
               else begin
                  if_state <= IDLE;
                  $display("Illegal interface state transition on %s instance %m at time %t: ADDR_ACTIVE state - ADD [%d]  and CS [%d] must both be low for one clk to advance.\n", MODULE_NAME, $time, ADD_INDELAY, cs_sig);
                  end
               end
            DATA_ACTIVE: begin
               if (cs_sig && ~ADD_INDELAY) begin
                  if_state <= DATA_ACTIVE;
                  data_reg <= {SDI_INDELAY, data_reg[7:1]};
                  shift_out <= {1'b0, shift_out[7:1]};
                  end
               else if (~cs_sig && ~ADD_INDELAY ) begin
                  if_state <= IDLE;
                  if (addr_reg[7] == 1'b0) begin
                     if (MEMUPDATE_INDELAY == 1'b1) write_to_ioi;
                     else mem_updated <= 1'b0;
                     end
                  else begin
                     if (MEMUPDATE_INDELAY == 1'b1) begin
                        mc_iob[addr_reg[3:0]] <= data_reg & mc_iob_mask[addr_reg[3:0]];
                        shift_out             <= data_reg & mc_iob_mask[addr_reg[3:0]];
                        end
                     else begin
                        mem_updated <= 1'b0;
                        end
                     end
                  end
               else begin
                  if_state <= IDLE;
                  $display("Illegal interface state transition on %s instance %m at time %t: DATA_ACTIVE state - ADD [%d] must stay low\n", MODULE_NAME, $time, ADD_INDELAY);
                  end
               end
            default: begin
               if_state <= IDLE;
                  $display("Illegal state entered on %s instance %m at time %t: state %3b\n", MODULE_NAME, $time, if_state);
               end
         endcase
         end

      if ((mem_updated == 1'b0) && (MEMUPDATE_INDELAY == 1'b1)) begin
         if (addr_reg[7] == 1'b0) begin
             write_to_ioi;
             mem_updated <= 1'b1;
             end
         else begin
             mc_iob[addr_reg[3:0]] <= data_reg & mc_iob_mask[addr_reg[3:0]];
             mem_updated <= 1'b1;
             end
         end

      inc_dec;

      if (calibrate_done) begin
         max_delay <= cal_delay;
         half_max  <= cal_delay >> 1;
         end

      end

   assign  AUXSDO = AUXSDO_OUTDELAY;
   assign  DATAOUT = DATAOUT_OUTDELAY;
   assign  DATAOUT2 = DATAOUT2_OUTDELAY;
   assign  DOUT = DOUT_OUTDELAY;
   assign  DQSOUTN = DQSOUTN_OUTDELAY;
   assign  DQSOUTP = DQSOUTP_OUTDELAY;
   assign  SDO = SDO_OUTDELAY;
   assign  TOUT = TOUT_OUTDELAY;

   assign ADD_IN = ADD;
   assign AUXADDR_IN = AUXADDR;
   assign AUXSDOIN_IN = AUXSDOIN;
   assign BKST_IN = BKST;
   assign  CLK_IN = CLK;
   assign CS_IN = CS;
   assign IDATAIN_IN = IDATAIN;
   assign  IOCLK0_IN = IOCLK0;
   assign  IOCLK1_IN = IOCLK1;
   assign MEMUPDATE_IN = MEMUPDATE;
   assign ODATAIN_IN = ODATAIN;
   assign SDI_IN = SDI;
   assign T_IN = T;
   assign GSR_IN = GSR;
  specify
    ( CLK => SDO) = (0, 0);
    ( IDATAIN => DATAOUT) = (0, 0);
    ( IDATAIN => DATAOUT2) = (0, 0);
    ( ODATAIN => DOUT) = (0, 0);
    ( T => TOUT) = (0, 0);

    specparam PATHPULSE$ = 0;
  endspecify
endmodule // IODRP2_MCB
