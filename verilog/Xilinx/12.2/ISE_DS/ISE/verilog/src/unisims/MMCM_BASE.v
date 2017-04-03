///////////////////////////////////////////////////////
//  Copyright (c) 2008 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : 
//  /  /                      
// /__/   /\       Filename    : MMCM_BASE.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:		1.0
//    01/06/09 Change CLKIN to CLKIN1 (CR502299)
//    09/02/09 - update REF_JITTER1 value to 0.010.
//   03/22/10 - Change CLKFBOUT_MULT_F default to 5 (554618)
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module MMCM_BASE (
  CLKFBOUT,
  CLKFBOUTB,
  CLKOUT0,
  CLKOUT0B,
  CLKOUT1,
  CLKOUT1B,
  CLKOUT2,
  CLKOUT2B,
  CLKOUT3,
  CLKOUT3B,
  CLKOUT4,
  CLKOUT5,
  CLKOUT6,
  LOCKED,
  CLKFBIN,
  CLKIN1,
  PWRDWN,
  RST
);

  parameter BANDWIDTH = "OPTIMIZED";
  parameter real CLKFBOUT_MULT_F = 5.000;
  parameter real CLKFBOUT_PHASE = 0.000;
  parameter real CLKIN1_PERIOD = 0.000;
  parameter real CLKOUT0_DIVIDE_F = 1.000;
  parameter real CLKOUT0_DUTY_CYCLE = 0.500;
  parameter real CLKOUT0_PHASE = 0.000;
  parameter integer CLKOUT1_DIVIDE = 1;
  parameter real CLKOUT1_DUTY_CYCLE = 0.500;
  parameter real CLKOUT1_PHASE = 0.000;
  parameter integer CLKOUT2_DIVIDE = 1;
  parameter real CLKOUT2_DUTY_CYCLE = 0.500;
  parameter real CLKOUT2_PHASE = 0.000;
  parameter integer CLKOUT3_DIVIDE = 1;
  parameter real CLKOUT3_DUTY_CYCLE = 0.500;
  parameter real CLKOUT3_PHASE = 0.000;
  parameter CLKOUT4_CASCADE = "FALSE";
  parameter integer CLKOUT4_DIVIDE = 1;
  parameter real CLKOUT4_DUTY_CYCLE = 0.500;
  parameter real CLKOUT4_PHASE = 0.000;
  parameter integer CLKOUT5_DIVIDE = 1;
  parameter real CLKOUT5_DUTY_CYCLE = 0.500;
  parameter real CLKOUT5_PHASE = 0.000;
  parameter integer CLKOUT6_DIVIDE = 1;
  parameter real CLKOUT6_DUTY_CYCLE = 0.500;
  parameter real CLKOUT6_PHASE = 0.000;
  parameter CLOCK_HOLD = "FALSE";
  parameter integer DIVCLK_DIVIDE = 1;
  parameter real REF_JITTER1 = 0.010;
  parameter STARTUP_WAIT = "FALSE";

  output CLKFBOUT;
  output CLKFBOUTB;
  output CLKOUT0;
  output CLKOUT0B;
  output CLKOUT1;
  output CLKOUT1B;
  output CLKOUT2;
  output CLKOUT2B;
  output CLKOUT3;
  output CLKOUT3B;
  output CLKOUT4;
  output CLKOUT5;
  output CLKOUT6;
  output LOCKED;

  input CLKFBIN;
  input CLKIN1;
  input PWRDWN;
  input RST;

  wire OPEN_DRDY;
  wire OPEN_PSDONE;
  wire OPEN_FBS;
  wire OPEN_INS;
  wire [15:0] OPEN_DO;

  MMCM_ADV #(
            .BANDWIDTH(BANDWIDTH),
            .CLKOUT4_CASCADE(CLKOUT4_CASCADE),
            .CLOCK_HOLD(CLOCK_HOLD),
            .STARTUP_WAIT(STARTUP_WAIT),
            .CLKOUT1_DIVIDE(CLKOUT1_DIVIDE),
            .CLKOUT2_DIVIDE(CLKOUT2_DIVIDE),
            .CLKOUT3_DIVIDE(CLKOUT3_DIVIDE),
            .CLKOUT4_DIVIDE(CLKOUT4_DIVIDE),
            .CLKOUT5_DIVIDE(CLKOUT5_DIVIDE),
            .CLKOUT6_DIVIDE(CLKOUT6_DIVIDE),
            .DIVCLK_DIVIDE(DIVCLK_DIVIDE),
            .CLKFBOUT_MULT_F(CLKFBOUT_MULT_F),
            .CLKFBOUT_PHASE(CLKFBOUT_PHASE),
            .CLKIN1_PERIOD(CLKIN1_PERIOD),
            .CLKIN2_PERIOD(10),
            .CLKOUT0_DIVIDE_F(CLKOUT0_DIVIDE_F),
            .CLKOUT0_DUTY_CYCLE(CLKOUT0_DUTY_CYCLE),
            .CLKOUT0_PHASE(CLKOUT0_PHASE),
            .CLKOUT1_DUTY_CYCLE(CLKOUT1_DUTY_CYCLE),
            .CLKOUT1_PHASE(CLKOUT1_PHASE),
            .CLKOUT2_DUTY_CYCLE(CLKOUT2_DUTY_CYCLE),
            .CLKOUT2_PHASE(CLKOUT2_PHASE),
            .CLKOUT3_DUTY_CYCLE(CLKOUT3_DUTY_CYCLE),
            .CLKOUT3_PHASE(CLKOUT3_PHASE),
            .CLKOUT4_DUTY_CYCLE(CLKOUT4_DUTY_CYCLE),
            .CLKOUT4_PHASE(CLKOUT4_PHASE),
            .CLKOUT5_DUTY_CYCLE(CLKOUT5_DUTY_CYCLE),
            .CLKOUT5_PHASE(CLKOUT5_PHASE),
            .CLKOUT6_DUTY_CYCLE(CLKOUT6_DUTY_CYCLE),
            .CLKOUT6_PHASE(CLKOUT6_PHASE),
            .REF_JITTER1(REF_JITTER1) 
      )
      mmcm_adv_1 (
        .CLKFBIN (CLKFBIN),
        .CLKFBOUT (CLKFBOUT),
        .CLKFBOUTB (CLKFBOUTB),
        .CLKIN1 (CLKIN1),
        .CLKIN2 (1'b0),
        .CLKOUT0 (CLKOUT0),
        .CLKOUT0B (CLKOUT0B),
        .CLKOUT1 (CLKOUT1),
        .CLKOUT1B (CLKOUT1B),
        .CLKOUT2 (CLKOUT2),
        .CLKOUT2B (CLKOUT2B),
        .CLKOUT3 (CLKOUT3),
        .CLKOUT3B (CLKOUT3B),
        .CLKOUT4 (CLKOUT4),
        .CLKOUT5 (CLKOUT5),
        .CLKOUT6 (CLKOUT6),
        .DADDR (7'b0),
        .DCLK (1'b0),
        .DEN (1'b0),
        .DI (16'b0),
        .DO (OPEN_DO),
        .DRDY (OPEN_DRDY),
        .DWE (1'b0),
        .LOCKED (LOCKED),
        .CLKINSEL(1'b1),
        .CLKFBSTOPPED(OPEN_FBS),
        .CLKINSTOPPED(OPEN_INS),
        .PSDONE(OPEN_PSDONE),
        .PSCLK(1'b0),
        .PSEN(1'b0),
        .PSINCDEC(1'b0),
        .PWRDWN(PWRDWN),
        .RST (RST)
    );

endmodule
