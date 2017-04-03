///////////////////////////////////////////////////////
//  Copyright (c) 2010 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : Xilinx Functional Simulation Library Component
//  /  /                         Gigabit Transceiver
// /__/   /\       Filename    : GTHE1_QUAD.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:		1.0
//  05/29/09 - CR523112 - Initial version
//  06/16/09 - CR523112 - Parameter update in YML
//  06/24/09 - CR523112 - YML update
//  07/07/09 - CR526271 - secureip publish
//  07/14/09 - CR527136 - specify block update
//  10/01/09 - CR534680 - YML Attribute updates
//  01/26/10 - CR546178 - YML new output pins & parameter default update
//  02/10/10 - CR543263 - Add new output pin connections in B_GTHE1_QUAD_INST
//  03/22/10 - CR552516 - DRC checks added
/////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module GTHE1_QUAD (
  DRDY,
  DRPDO,
  GTHINITDONE,
  MGMTPCSRDACK,
  MGMTPCSRDDATA,
  RXCODEERR0,
  RXCODEERR1,
  RXCODEERR2,
  RXCODEERR3,
  RXCTRL0,
  RXCTRL1,
  RXCTRL2,
  RXCTRL3,
  RXCTRLACK0,
  RXCTRLACK1,
  RXCTRLACK2,
  RXCTRLACK3,
  RXDATA0,
  RXDATA1,
  RXDATA2,
  RXDATA3,
  RXDATATAP0,
  RXDATATAP1,
  RXDATATAP2,
  RXDATATAP3,
  RXDISPERR0,
  RXDISPERR1,
  RXDISPERR2,
  RXDISPERR3,
  RXPCSCLKSMPL0,
  RXPCSCLKSMPL1,
  RXPCSCLKSMPL2,
  RXPCSCLKSMPL3,
  RXUSERCLKOUT0,
  RXUSERCLKOUT1,
  RXUSERCLKOUT2,
  RXUSERCLKOUT3,
  RXVALID0,
  RXVALID1,
  RXVALID2,
  RXVALID3,
  TSTPATH,
  TSTREFCLKFAB,
  TSTREFCLKOUT,
  TXCTRLACK0,
  TXCTRLACK1,
  TXCTRLACK2,
  TXCTRLACK3,
  TXDATATAP10,
  TXDATATAP11,
  TXDATATAP12,
  TXDATATAP13,
  TXDATATAP20,
  TXDATATAP21,
  TXDATATAP22,
  TXDATATAP23,
  TXN0,
  TXN1,
  TXN2,
  TXN3,
  TXP0,
  TXP1,
  TXP2,
  TXP3,
  TXPCSCLKSMPL0,
  TXPCSCLKSMPL1,
  TXPCSCLKSMPL2,
  TXPCSCLKSMPL3,
  TXUSERCLKOUT0,
  TXUSERCLKOUT1,
  TXUSERCLKOUT2,
  TXUSERCLKOUT3,
  DADDR,
  DCLK,
  DEN,
  DFETRAINCTRL0,
  DFETRAINCTRL1,
  DFETRAINCTRL2,
  DFETRAINCTRL3,
  DI,
  DISABLEDRP,
  DWE,
  GTHINIT,
  GTHRESET,
  GTHX2LANE01,
  GTHX2LANE23,
  GTHX4LANE,
  MGMTPCSLANESEL,
  MGMTPCSMMDADDR,
  MGMTPCSREGADDR,
  MGMTPCSREGRD,
  MGMTPCSREGWR,
  MGMTPCSWRDATA,
  PLLPCSCLKDIV,
  PLLREFCLKSEL,
  POWERDOWN0,
  POWERDOWN1,
  POWERDOWN2,
  POWERDOWN3,
  REFCLK,
  RXBUFRESET0,
  RXBUFRESET1,
  RXBUFRESET2,
  RXBUFRESET3,
  RXENCOMMADET0,
  RXENCOMMADET1,
  RXENCOMMADET2,
  RXENCOMMADET3,
  RXN0,
  RXN1,
  RXN2,
  RXN3,
  RXP0,
  RXP1,
  RXP2,
  RXP3,
  RXPOLARITY0,
  RXPOLARITY1,
  RXPOLARITY2,
  RXPOLARITY3,
  RXPOWERDOWN0,
  RXPOWERDOWN1,
  RXPOWERDOWN2,
  RXPOWERDOWN3,
  RXRATE0,
  RXRATE1,
  RXRATE2,
  RXRATE3,
  RXSLIP0,
  RXSLIP1,
  RXSLIP2,
  RXSLIP3,
  RXUSERCLKIN0,
  RXUSERCLKIN1,
  RXUSERCLKIN2,
  RXUSERCLKIN3,
  SAMPLERATE0,
  SAMPLERATE1,
  SAMPLERATE2,
  SAMPLERATE3,
  TXBUFRESET0,
  TXBUFRESET1,
  TXBUFRESET2,
  TXBUFRESET3,
  TXCTRL0,
  TXCTRL1,
  TXCTRL2,
  TXCTRL3,
  TXDATA0,
  TXDATA1,
  TXDATA2,
  TXDATA3,
  TXDATAMSB0,
  TXDATAMSB1,
  TXDATAMSB2,
  TXDATAMSB3,
  TXDEEMPH0,
  TXDEEMPH1,
  TXDEEMPH2,
  TXDEEMPH3,
  TXMARGIN0,
  TXMARGIN1,
  TXMARGIN2,
  TXMARGIN3,
  TXPOWERDOWN0,
  TXPOWERDOWN1,
  TXPOWERDOWN2,
  TXPOWERDOWN3,
  TXRATE0,
  TXRATE1,
  TXRATE2,
  TXRATE3,
  TXUSERCLKIN0,
  TXUSERCLKIN1,
  TXUSERCLKIN2,
  TXUSERCLKIN3
);

  parameter [15:0] BER_CONST_PTRN0 = 16'h0000;
  parameter [15:0] BER_CONST_PTRN1 = 16'h0000;
  parameter [15:0] BUFFER_CONFIG_LANE0 = 16'h4004;
  parameter [15:0] BUFFER_CONFIG_LANE1 = 16'h4004;
  parameter [15:0] BUFFER_CONFIG_LANE2 = 16'h4004;
  parameter [15:0] BUFFER_CONFIG_LANE3 = 16'h4004;
  parameter [15:0] DFE_TRAIN_CTRL_LANE0 = 16'h0000;
  parameter [15:0] DFE_TRAIN_CTRL_LANE1 = 16'h0000;
  parameter [15:0] DFE_TRAIN_CTRL_LANE2 = 16'h0000;
  parameter [15:0] DFE_TRAIN_CTRL_LANE3 = 16'h0000;
  parameter [15:0] DLL_CFG0 = 16'h4201;
  parameter [15:0] DLL_CFG1 = 16'h0000;
  parameter [15:0] E10GBASEKR_LD_COEFF_UPD_LANE0 = 16'h0000;
  parameter [15:0] E10GBASEKR_LD_COEFF_UPD_LANE1 = 16'h0000;
  parameter [15:0] E10GBASEKR_LD_COEFF_UPD_LANE2 = 16'h0000;
  parameter [15:0] E10GBASEKR_LD_COEFF_UPD_LANE3 = 16'h0000;
  parameter [15:0] E10GBASEKR_LP_COEFF_UPD_LANE0 = 16'h0000;
  parameter [15:0] E10GBASEKR_LP_COEFF_UPD_LANE1 = 16'h0000;
  parameter [15:0] E10GBASEKR_LP_COEFF_UPD_LANE2 = 16'h0000;
  parameter [15:0] E10GBASEKR_LP_COEFF_UPD_LANE3 = 16'h0000;
  parameter [15:0] E10GBASEKR_PMA_CTRL_LANE0 = 16'h0002;
  parameter [15:0] E10GBASEKR_PMA_CTRL_LANE1 = 16'h0002;
  parameter [15:0] E10GBASEKR_PMA_CTRL_LANE2 = 16'h0002;
  parameter [15:0] E10GBASEKR_PMA_CTRL_LANE3 = 16'h0002;
  parameter [15:0] E10GBASEKX_CTRL_LANE0 = 16'h0000;
  parameter [15:0] E10GBASEKX_CTRL_LANE1 = 16'h0000;
  parameter [15:0] E10GBASEKX_CTRL_LANE2 = 16'h0000;
  parameter [15:0] E10GBASEKX_CTRL_LANE3 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_CFG_LANE0 = 16'h070C;
  parameter [15:0] E10GBASER_PCS_CFG_LANE1 = 16'h070C;
  parameter [15:0] E10GBASER_PCS_CFG_LANE2 = 16'h070C;
  parameter [15:0] E10GBASER_PCS_CFG_LANE3 = 16'h070C;
  parameter [15:0] E10GBASER_PCS_SEEDA0_LANE0 = 16'h0001;
  parameter [15:0] E10GBASER_PCS_SEEDA0_LANE1 = 16'h0001;
  parameter [15:0] E10GBASER_PCS_SEEDA0_LANE2 = 16'h0001;
  parameter [15:0] E10GBASER_PCS_SEEDA0_LANE3 = 16'h0001;
  parameter [15:0] E10GBASER_PCS_SEEDA1_LANE0 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA1_LANE1 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA1_LANE2 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA1_LANE3 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA2_LANE0 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA2_LANE1 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA2_LANE2 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA2_LANE3 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA3_LANE0 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA3_LANE1 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA3_LANE2 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDA3_LANE3 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB0_LANE0 = 16'h0001;
  parameter [15:0] E10GBASER_PCS_SEEDB0_LANE1 = 16'h0001;
  parameter [15:0] E10GBASER_PCS_SEEDB0_LANE2 = 16'h0001;
  parameter [15:0] E10GBASER_PCS_SEEDB0_LANE3 = 16'h0001;
  parameter [15:0] E10GBASER_PCS_SEEDB1_LANE0 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB1_LANE1 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB1_LANE2 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB1_LANE3 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB2_LANE0 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB2_LANE1 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB2_LANE2 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB2_LANE3 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB3_LANE0 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB3_LANE1 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB3_LANE2 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_SEEDB3_LANE3 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_TEST_CTRL_LANE0 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_TEST_CTRL_LANE1 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_TEST_CTRL_LANE2 = 16'h0000;
  parameter [15:0] E10GBASER_PCS_TEST_CTRL_LANE3 = 16'h0000;
  parameter [15:0] E10GBASEX_PCS_TSTCTRL_LANE0 = 16'h0000;
  parameter [15:0] E10GBASEX_PCS_TSTCTRL_LANE1 = 16'h0000;
  parameter [15:0] E10GBASEX_PCS_TSTCTRL_LANE2 = 16'h0000;
  parameter [15:0] E10GBASEX_PCS_TSTCTRL_LANE3 = 16'h0000;
  parameter [15:0] GLBL0_NOISE_CTRL = 16'hF0B8;
  parameter [15:0] GLBL_AMON_SEL = 16'h0000;
  parameter [15:0] GLBL_DMON_SEL = 16'h0200;
  parameter [15:0] GLBL_PWR_CTRL = 16'h0000;
  parameter [0:0] GTH_CFG_PWRUP_LANE0 = 1'b1;
  parameter [0:0] GTH_CFG_PWRUP_LANE1 = 1'b1;
  parameter [0:0] GTH_CFG_PWRUP_LANE2 = 1'b1;
  parameter [0:0] GTH_CFG_PWRUP_LANE3 = 1'b1;
  parameter [15:0] LANE_AMON_SEL = 16'h00F0;
  parameter [15:0] LANE_DMON_SEL = 16'h0000;
  parameter [15:0] LANE_LNK_CFGOVRD = 16'h0000;
  parameter [15:0] LANE_PWR_CTRL_LANE0 = 16'h0400;
  parameter [15:0] LANE_PWR_CTRL_LANE1 = 16'h0400;
  parameter [15:0] LANE_PWR_CTRL_LANE2 = 16'h0400;
  parameter [15:0] LANE_PWR_CTRL_LANE3 = 16'h0400;
  parameter [15:0] LNK_TRN_CFG_LANE0 = 16'h0000;
  parameter [15:0] LNK_TRN_CFG_LANE1 = 16'h0000;
  parameter [15:0] LNK_TRN_CFG_LANE2 = 16'h0000;
  parameter [15:0] LNK_TRN_CFG_LANE3 = 16'h0000;
  parameter [15:0] LNK_TRN_COEFF_REQ_LANE0 = 16'h0000;
  parameter [15:0] LNK_TRN_COEFF_REQ_LANE1 = 16'h0000;
  parameter [15:0] LNK_TRN_COEFF_REQ_LANE2 = 16'h0000;
  parameter [15:0] LNK_TRN_COEFF_REQ_LANE3 = 16'h0000;
  parameter [15:0] MISC_CFG = 16'h0004;
  parameter [15:0] MODE_CFG1 = 16'h0000;
  parameter [15:0] MODE_CFG2 = 16'h0000;
  parameter [15:0] MODE_CFG3 = 16'h0000;
  parameter [15:0] MODE_CFG4 = 16'h0000;
  parameter [15:0] MODE_CFG5 = 16'h0000;
  parameter [15:0] MODE_CFG6 = 16'h0000;
  parameter [15:0] MODE_CFG7 = 16'h0000;
  parameter [15:0] PCS_ABILITY_LANE0 = 16'h0010;
  parameter [15:0] PCS_ABILITY_LANE1 = 16'h0010;
  parameter [15:0] PCS_ABILITY_LANE2 = 16'h0010;
  parameter [15:0] PCS_ABILITY_LANE3 = 16'h0010;
  parameter [15:0] PCS_CTRL1_LANE0 = 16'h2040;
  parameter [15:0] PCS_CTRL1_LANE1 = 16'h2040;
  parameter [15:0] PCS_CTRL1_LANE2 = 16'h2040;
  parameter [15:0] PCS_CTRL1_LANE3 = 16'h2040;
  parameter [15:0] PCS_CTRL2_LANE0 = 16'h0000;
  parameter [15:0] PCS_CTRL2_LANE1 = 16'h0000;
  parameter [15:0] PCS_CTRL2_LANE2 = 16'h0000;
  parameter [15:0] PCS_CTRL2_LANE3 = 16'h0000;
  parameter [15:0] PCS_MISC_CFG_0_LANE0 = 16'h1117;
  parameter [15:0] PCS_MISC_CFG_0_LANE1 = 16'h1117;
  parameter [15:0] PCS_MISC_CFG_0_LANE2 = 16'h1117;
  parameter [15:0] PCS_MISC_CFG_0_LANE3 = 16'h1117;
  parameter [15:0] PCS_MISC_CFG_1_LANE0 = 16'h0000;
  parameter [15:0] PCS_MISC_CFG_1_LANE1 = 16'h0000;
  parameter [15:0] PCS_MISC_CFG_1_LANE2 = 16'h0000;
  parameter [15:0] PCS_MISC_CFG_1_LANE3 = 16'h0000;
  parameter [15:0] PCS_MODE_LANE0 = 16'h0000;
  parameter [15:0] PCS_MODE_LANE1 = 16'h0000;
  parameter [15:0] PCS_MODE_LANE2 = 16'h0000;
  parameter [15:0] PCS_MODE_LANE3 = 16'h0000;
  parameter [15:0] PCS_RESET_1_LANE0 = 16'h0002;
  parameter [15:0] PCS_RESET_1_LANE1 = 16'h0002;
  parameter [15:0] PCS_RESET_1_LANE2 = 16'h0002;
  parameter [15:0] PCS_RESET_1_LANE3 = 16'h0002;
  parameter [15:0] PCS_RESET_LANE0 = 16'h0000;
  parameter [15:0] PCS_RESET_LANE1 = 16'h0000;
  parameter [15:0] PCS_RESET_LANE2 = 16'h0000;
  parameter [15:0] PCS_RESET_LANE3 = 16'h0000;
  parameter [15:0] PCS_TYPE_LANE0 = 16'h002C;
  parameter [15:0] PCS_TYPE_LANE1 = 16'h002C;
  parameter [15:0] PCS_TYPE_LANE2 = 16'h002C;
  parameter [15:0] PCS_TYPE_LANE3 = 16'h002C;
  parameter [15:0] PLL_CFG0 = 16'h58C0;
  parameter [15:0] PLL_CFG1 = 16'h8440;
  parameter [15:0] PLL_CFG2 = 16'h0424;
  parameter [15:0] PMA_CTRL1_LANE0 = 16'h0000;
  parameter [15:0] PMA_CTRL1_LANE1 = 16'h0000;
  parameter [15:0] PMA_CTRL1_LANE2 = 16'h0000;
  parameter [15:0] PMA_CTRL1_LANE3 = 16'h0000;
  parameter [15:0] PMA_CTRL2_LANE0 = 16'h000B;
  parameter [15:0] PMA_CTRL2_LANE1 = 16'h000B;
  parameter [15:0] PMA_CTRL2_LANE2 = 16'h000B;
  parameter [15:0] PMA_CTRL2_LANE3 = 16'h000B;
  parameter [15:0] PMA_LPBK_CTRL_LANE0 = 16'h0004;
  parameter [15:0] PMA_LPBK_CTRL_LANE1 = 16'h0004;
  parameter [15:0] PMA_LPBK_CTRL_LANE2 = 16'h0004;
  parameter [15:0] PMA_LPBK_CTRL_LANE3 = 16'h0004;
  parameter [15:0] PRBS_BER_CFG0_LANE0 = 16'h0000;
  parameter [15:0] PRBS_BER_CFG0_LANE1 = 16'h0000;
  parameter [15:0] PRBS_BER_CFG0_LANE2 = 16'h0000;
  parameter [15:0] PRBS_BER_CFG0_LANE3 = 16'h0000;
  parameter [15:0] PRBS_BER_CFG1_LANE0 = 16'h0000;
  parameter [15:0] PRBS_BER_CFG1_LANE1 = 16'h0000;
  parameter [15:0] PRBS_BER_CFG1_LANE2 = 16'h0000;
  parameter [15:0] PRBS_BER_CFG1_LANE3 = 16'h0000;
  parameter [15:0] PRBS_CFG_LANE0 = 16'h000A;
  parameter [15:0] PRBS_CFG_LANE1 = 16'h000A;
  parameter [15:0] PRBS_CFG_LANE2 = 16'h000A;
  parameter [15:0] PRBS_CFG_LANE3 = 16'h000A;
  parameter [15:0] PTRN_CFG0_LSB = 16'h5555;
  parameter [15:0] PTRN_CFG0_MSB = 16'h5555;
  parameter [15:0] PTRN_LEN_CFG = 16'h001F;
  parameter [15:0] PWRUP_DLY = 16'h0000;
  parameter [15:0] RX_AEQ_VAL0_LANE0 = 16'h0100;
  parameter [15:0] RX_AEQ_VAL0_LANE1 = 16'h0100;
  parameter [15:0] RX_AEQ_VAL0_LANE2 = 16'h0100;
  parameter [15:0] RX_AEQ_VAL0_LANE3 = 16'h0100;
  parameter [15:0] RX_AEQ_VAL1_LANE0 = 16'h0000;
  parameter [15:0] RX_AEQ_VAL1_LANE1 = 16'h0000;
  parameter [15:0] RX_AEQ_VAL1_LANE2 = 16'h0000;
  parameter [15:0] RX_AEQ_VAL1_LANE3 = 16'h0000;
  parameter [15:0] RX_AGC_CTRL_LANE0 = 16'h0000;
  parameter [15:0] RX_AGC_CTRL_LANE1 = 16'h0000;
  parameter [15:0] RX_AGC_CTRL_LANE2 = 16'h0000;
  parameter [15:0] RX_AGC_CTRL_LANE3 = 16'h0000;
  parameter [15:0] RX_CDR_CTRL0_LANE0 = 16'h0005;
  parameter [15:0] RX_CDR_CTRL0_LANE1 = 16'h0005;
  parameter [15:0] RX_CDR_CTRL0_LANE2 = 16'h0005;
  parameter [15:0] RX_CDR_CTRL0_LANE3 = 16'h0005;
  parameter [15:0] RX_CDR_CTRL1_LANE0 = 16'h4300;
  parameter [15:0] RX_CDR_CTRL1_LANE1 = 16'h4300;
  parameter [15:0] RX_CDR_CTRL1_LANE2 = 16'h4300;
  parameter [15:0] RX_CDR_CTRL1_LANE3 = 16'h4300;
  parameter [15:0] RX_CDR_CTRL2_LANE0 = 16'h2000;
  parameter [15:0] RX_CDR_CTRL2_LANE1 = 16'h2000;
  parameter [15:0] RX_CDR_CTRL2_LANE2 = 16'h2000;
  parameter [15:0] RX_CDR_CTRL2_LANE3 = 16'h2000;
  parameter [15:0] RX_CFG0_LANE0 = 16'h0B06;
  parameter [15:0] RX_CFG0_LANE1 = 16'h0B06;
  parameter [15:0] RX_CFG0_LANE2 = 16'h0B06;
  parameter [15:0] RX_CFG0_LANE3 = 16'h0B06;
  parameter [15:0] RX_CFG1_LANE0 = 16'h817F;
  parameter [15:0] RX_CFG1_LANE1 = 16'h817F;
  parameter [15:0] RX_CFG1_LANE2 = 16'h817F;
  parameter [15:0] RX_CFG1_LANE3 = 16'h817F;
  parameter [15:0] RX_CFG2_LANE0 = 16'h1000;
  parameter [15:0] RX_CFG2_LANE1 = 16'h1000;
  parameter [15:0] RX_CFG2_LANE2 = 16'h1000;
  parameter [15:0] RX_CFG2_LANE3 = 16'h1000;
  parameter [15:0] RX_CTLE_CTRL_LANE0 = 16'h007F;
  parameter [15:0] RX_CTLE_CTRL_LANE1 = 16'h007F;
  parameter [15:0] RX_CTLE_CTRL_LANE2 = 16'h007F;
  parameter [15:0] RX_CTLE_CTRL_LANE3 = 16'h007F;
  parameter [15:0] RX_CTRL_OVRD_LANE0 = 16'h000C;
  parameter [15:0] RX_CTRL_OVRD_LANE1 = 16'h000C;
  parameter [15:0] RX_CTRL_OVRD_LANE2 = 16'h000C;
  parameter [15:0] RX_CTRL_OVRD_LANE3 = 16'h000C;
  parameter integer RX_FABRIC_WIDTH0 = 6466;
  parameter integer RX_FABRIC_WIDTH1 = 6466;
  parameter integer RX_FABRIC_WIDTH2 = 6466;
  parameter integer RX_FABRIC_WIDTH3 = 6466;
  parameter [15:0] RX_LOOP_CTRL_LANE0 = 16'h0070;
  parameter [15:0] RX_LOOP_CTRL_LANE1 = 16'h0070;
  parameter [15:0] RX_LOOP_CTRL_LANE2 = 16'h0070;
  parameter [15:0] RX_LOOP_CTRL_LANE3 = 16'h0070;
  parameter [15:0] RX_MVAL0_LANE0 = 16'h0000;
  parameter [15:0] RX_MVAL0_LANE1 = 16'h0000;
  parameter [15:0] RX_MVAL0_LANE2 = 16'h0000;
  parameter [15:0] RX_MVAL0_LANE3 = 16'h0000;
  parameter [15:0] RX_MVAL1_LANE0 = 16'h0000;
  parameter [15:0] RX_MVAL1_LANE1 = 16'h0000;
  parameter [15:0] RX_MVAL1_LANE2 = 16'h0000;
  parameter [15:0] RX_MVAL1_LANE3 = 16'h0000;
  parameter [15:0] RX_P0S_CTRL = 16'h1206;
  parameter [15:0] RX_P0_CTRL = 16'h11F0;
  parameter [15:0] RX_P1_CTRL = 16'h120F;
  parameter [15:0] RX_P2_CTRL = 16'h0E0F;
  parameter [15:0] RX_PI_CTRL0 = 16'hB2F2;
  parameter [15:0] RX_PI_CTRL1 = 16'h0080;
  parameter integer SIM_GTHRESET_SPEEDUP = 1;
  parameter SIM_VERSION = "1.0";
  parameter [15:0] SLICE_CFG = 16'h0000;
  parameter [15:0] SLICE_NOISE_CTRL_0_LANE01 = 16'h0000;
  parameter [15:0] SLICE_NOISE_CTRL_0_LANE23 = 16'h0000;
  parameter [15:0] SLICE_NOISE_CTRL_1_LANE01 = 16'h0000;
  parameter [15:0] SLICE_NOISE_CTRL_1_LANE23 = 16'h0000;
  parameter [15:0] SLICE_NOISE_CTRL_2_LANE01 = 16'hEFFF;
  parameter [15:0] SLICE_NOISE_CTRL_2_LANE23 = 16'hEFFF;
  parameter [15:0] SLICE_TX_RESET_LANE01 = 16'h0000;
  parameter [15:0] SLICE_TX_RESET_LANE23 = 16'h0000;
  parameter [15:0] TERM_CTRL_LANE0 = 16'h0000;
  parameter [15:0] TERM_CTRL_LANE1 = 16'h0000;
  parameter [15:0] TERM_CTRL_LANE2 = 16'h0000;
  parameter [15:0] TERM_CTRL_LANE3 = 16'h0000;
  parameter [15:0] TX_CFG0_LANE0 = 16'h203D;
  parameter [15:0] TX_CFG0_LANE1 = 16'h203D;
  parameter [15:0] TX_CFG0_LANE2 = 16'h203D;
  parameter [15:0] TX_CFG0_LANE3 = 16'h203D;
  parameter [15:0] TX_CFG1_LANE0 = 16'h0C83;
  parameter [15:0] TX_CFG1_LANE1 = 16'h0C83;
  parameter [15:0] TX_CFG1_LANE2 = 16'h0C83;
  parameter [15:0] TX_CFG1_LANE3 = 16'h0C83;
  parameter [15:0] TX_CFG2_LANE0 = 16'h0001;
  parameter [15:0] TX_CFG2_LANE1 = 16'h0001;
  parameter [15:0] TX_CFG2_LANE2 = 16'h0001;
  parameter [15:0] TX_CFG2_LANE3 = 16'h0001;
  parameter [15:0] TX_CLK_SEL0_LANE0 = 16'h2F2F;
  parameter [15:0] TX_CLK_SEL0_LANE1 = 16'h2F2F;
  parameter [15:0] TX_CLK_SEL0_LANE2 = 16'h2F2F;
  parameter [15:0] TX_CLK_SEL0_LANE3 = 16'h2F2F;
  parameter [15:0] TX_CLK_SEL1_LANE0 = 16'h2F2F;
  parameter [15:0] TX_CLK_SEL1_LANE1 = 16'h2F2F;
  parameter [15:0] TX_CLK_SEL1_LANE2 = 16'h2F2F;
  parameter [15:0] TX_CLK_SEL1_LANE3 = 16'h2F2F;
  parameter [15:0] TX_DISABLE_LANE0 = 16'h0000;
  parameter [15:0] TX_DISABLE_LANE1 = 16'h0000;
  parameter [15:0] TX_DISABLE_LANE2 = 16'h0000;
  parameter [15:0] TX_DISABLE_LANE3 = 16'h0000;
  parameter integer TX_FABRIC_WIDTH0 = 6466;
  parameter integer TX_FABRIC_WIDTH1 = 6466;
  parameter integer TX_FABRIC_WIDTH2 = 6466;
  parameter integer TX_FABRIC_WIDTH3 = 6466;
  parameter [15:0] TX_P0P0S_CTRL = 16'h060C;
  parameter [15:0] TX_P1P2_CTRL = 16'h0C39;
  parameter [15:0] TX_PREEMPH_LANE0 = 16'hA0F0;
  parameter [15:0] TX_PREEMPH_LANE1 = 16'hA0F0;
  parameter [15:0] TX_PREEMPH_LANE2 = 16'hA0F0;
  parameter [15:0] TX_PREEMPH_LANE3 = 16'hA0F0;
  parameter [15:0] TX_PWR_RATE_OVRD_LANE0 = 16'h0060;
  parameter [15:0] TX_PWR_RATE_OVRD_LANE1 = 16'h0060;
  parameter [15:0] TX_PWR_RATE_OVRD_LANE2 = 16'h0060;
  parameter [15:0] TX_PWR_RATE_OVRD_LANE3 = 16'h0060;
  
  localparam in_delay = 0;
  localparam out_delay = 0;
  localparam INCLK_DELAY = 0;
  localparam OUTCLK_DELAY = 0;

  output DRDY;
  output GTHINITDONE;
  output MGMTPCSRDACK;
  output RXCTRLACK0;
  output RXCTRLACK1;
  output RXCTRLACK2;
  output RXCTRLACK3;
  output RXDATATAP0;
  output RXDATATAP1;
  output RXDATATAP2;
  output RXDATATAP3;
  output RXPCSCLKSMPL0;
  output RXPCSCLKSMPL1;
  output RXPCSCLKSMPL2;
  output RXPCSCLKSMPL3;
  output RXUSERCLKOUT0;
  output RXUSERCLKOUT1;
  output RXUSERCLKOUT2;
  output RXUSERCLKOUT3;
  output TSTPATH;
  output TSTREFCLKFAB;
  output TSTREFCLKOUT;
  output TXCTRLACK0;
  output TXCTRLACK1;
  output TXCTRLACK2;
  output TXCTRLACK3;
  output TXDATATAP10;
  output TXDATATAP11;
  output TXDATATAP12;
  output TXDATATAP13;
  output TXDATATAP20;
  output TXDATATAP21;
  output TXDATATAP22;
  output TXDATATAP23;
  output TXN0;
  output TXN1;
  output TXN2;
  output TXN3;
  output TXP0;
  output TXP1;
  output TXP2;
  output TXP3;
  output TXPCSCLKSMPL0;
  output TXPCSCLKSMPL1;
  output TXPCSCLKSMPL2;
  output TXPCSCLKSMPL3;
  output TXUSERCLKOUT0;
  output TXUSERCLKOUT1;
  output TXUSERCLKOUT2;
  output TXUSERCLKOUT3;
  output [15:0] DRPDO;
  output [15:0] MGMTPCSRDDATA;
  output [63:0] RXDATA0;
  output [63:0] RXDATA1;
  output [63:0] RXDATA2;
  output [63:0] RXDATA3;
  output [7:0] RXCODEERR0;
  output [7:0] RXCODEERR1;
  output [7:0] RXCODEERR2;
  output [7:0] RXCODEERR3;
  output [7:0] RXCTRL0;
  output [7:0] RXCTRL1;
  output [7:0] RXCTRL2;
  output [7:0] RXCTRL3;
  output [7:0] RXDISPERR0;
  output [7:0] RXDISPERR1;
  output [7:0] RXDISPERR2;
  output [7:0] RXDISPERR3;
  output [7:0] RXVALID0;
  output [7:0] RXVALID1;
  output [7:0] RXVALID2;
  output [7:0] RXVALID3;

  input DCLK;
  input DEN;
  input DFETRAINCTRL0;
  input DFETRAINCTRL1;
  input DFETRAINCTRL2;
  input DFETRAINCTRL3;
  input DISABLEDRP;
  input DWE;
  input GTHINIT;
  input GTHRESET;
  input GTHX2LANE01;
  input GTHX2LANE23;
  input GTHX4LANE;
  input MGMTPCSREGRD;
  input MGMTPCSREGWR;
  input POWERDOWN0;
  input POWERDOWN1;
  input POWERDOWN2;
  input POWERDOWN3;
  input REFCLK;
  input RXBUFRESET0;
  input RXBUFRESET1;
  input RXBUFRESET2;
  input RXBUFRESET3;
  input RXENCOMMADET0;
  input RXENCOMMADET1;
  input RXENCOMMADET2;
  input RXENCOMMADET3;
  input RXN0;
  input RXN1;
  input RXN2;
  input RXN3;
  input RXP0;
  input RXP1;
  input RXP2;
  input RXP3;
  input RXPOLARITY0;
  input RXPOLARITY1;
  input RXPOLARITY2;
  input RXPOLARITY3;
  input RXSLIP0;
  input RXSLIP1;
  input RXSLIP2;
  input RXSLIP3;
  input RXUSERCLKIN0;
  input RXUSERCLKIN1;
  input RXUSERCLKIN2;
  input RXUSERCLKIN3;
  input TXBUFRESET0;
  input TXBUFRESET1;
  input TXBUFRESET2;
  input TXBUFRESET3;
  input TXDEEMPH0;
  input TXDEEMPH1;
  input TXDEEMPH2;
  input TXDEEMPH3;
  input TXUSERCLKIN0;
  input TXUSERCLKIN1;
  input TXUSERCLKIN2;
  input TXUSERCLKIN3;
  input [15:0] DADDR;
  input [15:0] DI;
  input [15:0] MGMTPCSREGADDR;
  input [15:0] MGMTPCSWRDATA;
  input [1:0] RXPOWERDOWN0;
  input [1:0] RXPOWERDOWN1;
  input [1:0] RXPOWERDOWN2;
  input [1:0] RXPOWERDOWN3;
  input [1:0] RXRATE0;
  input [1:0] RXRATE1;
  input [1:0] RXRATE2;
  input [1:0] RXRATE3;
  input [1:0] TXPOWERDOWN0;
  input [1:0] TXPOWERDOWN1;
  input [1:0] TXPOWERDOWN2;
  input [1:0] TXPOWERDOWN3;
  input [1:0] TXRATE0;
  input [1:0] TXRATE1;
  input [1:0] TXRATE2;
  input [1:0] TXRATE3;
  input [2:0] PLLREFCLKSEL;
  input [2:0] SAMPLERATE0;
  input [2:0] SAMPLERATE1;
  input [2:0] SAMPLERATE2;
  input [2:0] SAMPLERATE3;
  input [2:0] TXMARGIN0;
  input [2:0] TXMARGIN1;
  input [2:0] TXMARGIN2;
  input [2:0] TXMARGIN3;
  input [3:0] MGMTPCSLANESEL;
  input [4:0] MGMTPCSMMDADDR;
  input [5:0] PLLPCSCLKDIV;
  input [63:0] TXDATA0;
  input [63:0] TXDATA1;
  input [63:0] TXDATA2;
  input [63:0] TXDATA3;
  input [7:0] TXCTRL0;
  input [7:0] TXCTRL1;
  input [7:0] TXCTRL2;
  input [7:0] TXCTRL3;
  input [7:0] TXDATAMSB0;
  input [7:0] TXDATAMSB1;
  input [7:0] TXDATAMSB2;
  input [7:0] TXDATAMSB3;

  reg GTH_CFG_PWRUP_LANE0_BINARY;
  reg GTH_CFG_PWRUP_LANE1_BINARY;
  reg GTH_CFG_PWRUP_LANE2_BINARY;
  reg GTH_CFG_PWRUP_LANE3_BINARY;
  reg SIM_GTHRESET_SPEEDUP_BINARY;
  reg SIM_VERSION_BINARY;
  reg [2:0] RX_FABRIC_WIDTH0_BINARY;
  reg [2:0] RX_FABRIC_WIDTH1_BINARY;
  reg [2:0] RX_FABRIC_WIDTH2_BINARY;
  reg [2:0] RX_FABRIC_WIDTH3_BINARY;
  reg [2:0] TX_FABRIC_WIDTH0_BINARY;
  reg [2:0] TX_FABRIC_WIDTH1_BINARY;
  reg [2:0] TX_FABRIC_WIDTH2_BINARY;
  reg [2:0] TX_FABRIC_WIDTH3_BINARY;

  tri0 GSR = glbl.GSR;

 // Start DRC checks
   
   always @(PLLPCSCLKDIV) begin

      // DRC Checks SET 1 - DRC Error for PLLPCSCLKDIV = 6'b32

      if (((PLLPCSCLKDIV == 6'd32) || (PLLPCSCLKDIV == 6'b100000)) && ((PCS_MODE_LANE0[7:4] != 4'b0001) || (RX_FABRIC_WIDTH0 != 6466))) begin
	 $display("DRC Error: When PLLPCSCLKDIV is set to 6'b32, PCS_MODE_LANE0[7:4] %b or RX_FABRIC_WIDTH0 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE0[7:4], RX_FABRIC_WIDTH0);
	 $finish;
      end
      if (((PLLPCSCLKDIV == 6'd32) || (PLLPCSCLKDIV == 6'b100000)) && ((PCS_MODE_LANE0[3:0] != 4'b0001) || (TX_FABRIC_WIDTH0 != 6466))) begin
   	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b32, PCS_MODE_LANE0[3:0] %b or TX_FABRIC_WIDTH0 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE0[3:0], TX_FABRIC_WIDTH0);
	 $finish;
      end
      if (((PLLPCSCLKDIV == 6'd32) || (PLLPCSCLKDIV == 6'b100000)) && ((PCS_MODE_LANE1[7:4] != 4'b0001) || (RX_FABRIC_WIDTH1 != 6466))) begin
    	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b32, PCS_MODE_LANE1[7:4] %b or RX_FABRIC_WIDTH1 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE1[7:4], RX_FABRIC_WIDTH1);
	 $finish;
      end
      if (((PLLPCSCLKDIV == 6'd32) || (PLLPCSCLKDIV == 6'b100000)) && ((PCS_MODE_LANE1[3:0] != 4'b0001) || (TX_FABRIC_WIDTH1 != 6466))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b32, PCS_MODE_LANE1[3:0] %b or TX_FABRIC_WIDTH1 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE1[3:0], TX_FABRIC_WIDTH1);
	 $finish;
      end
      if (((PLLPCSCLKDIV == 6'd32) || (PLLPCSCLKDIV == 6'b100000)) && ((PCS_MODE_LANE2[7:4] != 4'b0001) || (RX_FABRIC_WIDTH2 != 6466))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b32, PCS_MODE_LANE2[7:4] %b or RX_FABRIC_WIDTH2 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE2[7:4], RX_FABRIC_WIDTH2);
	 $finish;
      end
      if (((PLLPCSCLKDIV == 6'd32) || (PLLPCSCLKDIV == 6'b100000)) && ((PCS_MODE_LANE2[3:0] != 4'b0001) || (TX_FABRIC_WIDTH2 != 6466))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b32, PCS_MODE_LANE2[3:0] %b or TX_FABRIC_WIDTH2 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE2[3:0], TX_FABRIC_WIDTH2);
	 $finish;
      end
      if (((PLLPCSCLKDIV == 6'd32) || (PLLPCSCLKDIV == 6'b100000)) && ((PCS_MODE_LANE3[7:4] != 4'b0001) || (RX_FABRIC_WIDTH3 != 6466))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b32, PCS_MODE_LANE3[7:4] %b or RX_FABRIC_WIDTH3 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE3[7:4], RX_FABRIC_WIDTH3);
	 $finish;
      end
      if (((PLLPCSCLKDIV == 6'd32) || (PLLPCSCLKDIV == 6'b100000)) && ((PCS_MODE_LANE3[3:0] != 4'b0001) || (TX_FABRIC_WIDTH3 != 6466))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b32, PCS_MODE_LANE3[3:0] %b or TX_FABRIC_WIDTH3 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE3[3:0], TX_FABRIC_WIDTH3);
	 $finish;
      end
      
      // DRC Checks SET 2 - DRC Error for PLLPCSCLKDIV = 6'b7
      
      if (((PLLPCSCLKDIV == 6'd7) || (PLLPCSCLKDIV == 6'b000111)) && !((PCS_MODE_LANE0[7:4] == 4'b1100) ||((PCS_MODE_LANE0[7:4] == 4'b1000) && (RX_FABRIC_WIDTH0 == 8 ||RX_FABRIC_WIDTH0 ==16 ||RX_FABRIC_WIDTH0==32 || RX_FABRIC_WIDTH0 ==64)) ||   ((PCS_MODE_LANE0[7:4] == 4'b1010) && (RX_FABRIC_WIDTH0 ==16 ||RX_FABRIC_WIDTH0==32 ||RX_FABRIC_WIDTH0 ==64 )))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b7, PCS_MODE_LANE0[7:4] %b and RX_FABRIC_WIDTH0 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE0[7:4], RX_FABRIC_WIDTH0);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd7) || (PLLPCSCLKDIV == 6'b000111)) && !((PCS_MODE_LANE0[3:0] == 4'b1100) ||((PCS_MODE_LANE0[3:0] == 4'b1000) && (TX_FABRIC_WIDTH0 == 8 ||TX_FABRIC_WIDTH0 ==16 ||TX_FABRIC_WIDTH0==32 || TX_FABRIC_WIDTH0 ==64)) ||   ((PCS_MODE_LANE0[3:0] == 4'b1010) && (TX_FABRIC_WIDTH0 ==16 ||TX_FABRIC_WIDTH0==32 ||TX_FABRIC_WIDTH0 ==64 )))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b7, PCS_MODE_LANE0[3:0] %b and TX_FABRIC_WIDTH0 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE0[3:0], TX_FABRIC_WIDTH0);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd7) || (PLLPCSCLKDIV == 6'b000111)) && !((PCS_MODE_LANE1[7:4] == 4'b1100) ||((PCS_MODE_LANE1[7:4] == 4'b1000) && (RX_FABRIC_WIDTH1 == 8 ||RX_FABRIC_WIDTH1 ==16 ||RX_FABRIC_WIDTH1==32 || RX_FABRIC_WIDTH1 ==64)) ||   ((PCS_MODE_LANE1[7:4] == 4'b1010) && (RX_FABRIC_WIDTH1 ==16 ||RX_FABRIC_WIDTH1==32 ||RX_FABRIC_WIDTH1 ==64 )))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b7, PCS_MODE_LANE1[7:4] %b and RX_FABRIC_WIDTH1 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE1[7:4], RX_FABRIC_WIDTH1);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd7) || (PLLPCSCLKDIV == 6'b000111)) && !((PCS_MODE_LANE1[3:0] == 4'b1100) ||((PCS_MODE_LANE1[3:0] == 4'b1000) && (TX_FABRIC_WIDTH1 == 8 ||TX_FABRIC_WIDTH1 ==16 ||TX_FABRIC_WIDTH1==32 || TX_FABRIC_WIDTH1 ==64)) ||   ((PCS_MODE_LANE1[3:0] == 4'b1010) && (TX_FABRIC_WIDTH1 ==16 ||TX_FABRIC_WIDTH1==32 ||TX_FABRIC_WIDTH1 ==64 )))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b7, PCS_MODE_LANE1[3:0] %b and TX_FABRIC_WIDTH1 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE1[3:0], TX_FABRIC_WIDTH1);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd7) || (PLLPCSCLKDIV == 6'b000111)) && !((PCS_MODE_LANE2[7:4] == 4'b1100) ||((PCS_MODE_LANE2[7:4] == 4'b1000) && (RX_FABRIC_WIDTH2 == 8 ||RX_FABRIC_WIDTH2 ==16 ||RX_FABRIC_WIDTH2==32 || RX_FABRIC_WIDTH2 ==64)) ||   ((PCS_MODE_LANE2[7:4] == 4'b1010) && (RX_FABRIC_WIDTH2 ==16 ||RX_FABRIC_WIDTH2==32 ||RX_FABRIC_WIDTH2 ==64 )))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b7, PCS_MODE_LANE2[7:4] %b and RX_FABRIC_WIDTH2 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE2[7:4], RX_FABRIC_WIDTH2);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd7) || (PLLPCSCLKDIV == 6'b000111)) && !((PCS_MODE_LANE2[3:0] == 4'b1100) ||((PCS_MODE_LANE2[3:0] == 4'b1000) && (TX_FABRIC_WIDTH2 == 8 ||TX_FABRIC_WIDTH2 ==16 ||TX_FABRIC_WIDTH2==32 || TX_FABRIC_WIDTH2 ==64)) ||   ((PCS_MODE_LANE2[3:0] == 4'b1010) && (TX_FABRIC_WIDTH2 ==16 ||TX_FABRIC_WIDTH2==32 ||TX_FABRIC_WIDTH2 ==64 )))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b7, PCS_MODE_LANE2[3:0] %b and TX_FABRIC_WIDTH2 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE2[3:0], TX_FABRIC_WIDTH2);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd7) || (PLLPCSCLKDIV == 6'b000111)) && !((PCS_MODE_LANE3[7:4] == 4'b1100) ||((PCS_MODE_LANE3[7:4] == 4'b1000) && (RX_FABRIC_WIDTH3 == 8 ||RX_FABRIC_WIDTH3 ==16 ||RX_FABRIC_WIDTH3==32 || RX_FABRIC_WIDTH3 ==64)) ||   ((PCS_MODE_LANE3[7:4] == 4'b1010) && (RX_FABRIC_WIDTH3 ==16 ||RX_FABRIC_WIDTH3==32 ||RX_FABRIC_WIDTH3 ==64 )))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b7, PCS_MODE_LANE3[7:4] %b and RX_FABRIC_WIDTH3 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE3[7:4], RX_FABRIC_WIDTH3);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd7) || (PLLPCSCLKDIV == 6'b000111)) && !((PCS_MODE_LANE3[3:0] == 4'b1100) ||((PCS_MODE_LANE3[3:0] == 4'b1000) && (TX_FABRIC_WIDTH3 == 8 ||TX_FABRIC_WIDTH3 ==16 ||TX_FABRIC_WIDTH3==32 || TX_FABRIC_WIDTH3 ==64)) ||   ((PCS_MODE_LANE3[3:0] == 4'b1010) && (TX_FABRIC_WIDTH3 ==16 ||TX_FABRIC_WIDTH3==32 ||TX_FABRIC_WIDTH3 ==64 )))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b7, PCS_MODE_LANE3[3:0] %b and TX_FABRIC_WIDTH3 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE3[3:0], TX_FABRIC_WIDTH3);
	 $finish;
      end

      //DRC Checks Set 3 -  DRC Error for PLLPCSCLKDIV = 6'b9
      
      if (((PLLPCSCLKDIV == 6'd9) || (PLLPCSCLKDIV ==  6'b001001)) && !((((PCS_MODE_LANE0[7:4] == 4'b1011) && (RX_FABRIC_WIDTH0==20 || RX_FABRIC_WIDTH0 ==40 || RX_FABRIC_WIDTH0 ==80)) ||   ((PCS_MODE_LANE0[7:4] == 4'b0111) && (RX_FABRIC_WIDTH0 ==16 ||RX_FABRIC_WIDTH0==32 ||RX_FABRIC_WIDTH0 ==64 ))))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b9, PCS_MODE_LANE0[7:4] %b and RX_FABRIC_WIDTH0 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE0[7:4], RX_FABRIC_WIDTH0);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd9) || (PLLPCSCLKDIV ==  6'b001001)) && !((((PCS_MODE_LANE0[3:0] == 4'b1011) && (TX_FABRIC_WIDTH0==20 || TX_FABRIC_WIDTH0 ==40 || TX_FABRIC_WIDTH0 ==80)) ||   ((PCS_MODE_LANE0[3:0] == 4'b0111) && (TX_FABRIC_WIDTH0 ==16 ||TX_FABRIC_WIDTH0==32 ||TX_FABRIC_WIDTH0 ==64 ))))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b9, PCS_MODE_LANE0[3:0] %b and TX_FABRIC_WIDTH0 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE0[3:0], TX_FABRIC_WIDTH0);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd9) || (PLLPCSCLKDIV ==  6'b001001)) && !((((PCS_MODE_LANE1[7:4] == 4'b1011) && (RX_FABRIC_WIDTH1==20 || RX_FABRIC_WIDTH1 ==40 || RX_FABRIC_WIDTH1 ==80)) ||   ((PCS_MODE_LANE1[7:4] == 4'b0111) && (RX_FABRIC_WIDTH1 ==16 ||RX_FABRIC_WIDTH1==32 ||RX_FABRIC_WIDTH1 ==64 ))))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b9, PCS_MODE_LANE1[7:4] %b and RX_FABRIC_WIDTH1 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE1[7:4], RX_FABRIC_WIDTH1);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd9) || (PLLPCSCLKDIV ==  6'b001001)) && !((((PCS_MODE_LANE1[3:0] == 4'b1011) && (TX_FABRIC_WIDTH1==20 || TX_FABRIC_WIDTH1 ==40 || TX_FABRIC_WIDTH1 ==80)) ||   ((PCS_MODE_LANE1[3:0] == 4'b0111) && (TX_FABRIC_WIDTH1 ==16 ||TX_FABRIC_WIDTH1==32 ||TX_FABRIC_WIDTH1 ==64 ))))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b9, PCS_MODE_LANE1[3:0] %b and TX_FABRIC_WIDTH1 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE1[3:0], TX_FABRIC_WIDTH1);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd9) || (PLLPCSCLKDIV ==  6'b001001)) && !((((PCS_MODE_LANE2[7:4] == 4'b1011) && (RX_FABRIC_WIDTH2==20 || RX_FABRIC_WIDTH2 ==40 || RX_FABRIC_WIDTH2 ==80)) ||   ((PCS_MODE_LANE2[7:4] == 4'b0111) && (RX_FABRIC_WIDTH2 ==16 ||RX_FABRIC_WIDTH2==32 ||RX_FABRIC_WIDTH2 ==64 ))))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b9, PCS_MODE_LANE2[7:4] %b and RX_FABRIC_WIDTH2 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE2[7:4], RX_FABRIC_WIDTH2);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd9) || (PLLPCSCLKDIV ==  6'b001001)) && !((((PCS_MODE_LANE2[3:0] == 4'b1011) && (TX_FABRIC_WIDTH2==20 || TX_FABRIC_WIDTH2 ==40 || TX_FABRIC_WIDTH2 ==80)) ||   ((PCS_MODE_LANE2[3:0] == 4'b0111) && (TX_FABRIC_WIDTH2 ==16 ||TX_FABRIC_WIDTH2==32 ||TX_FABRIC_WIDTH2 ==64 ))))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b9, PCS_MODE_LANE2[3:0] %b and TX_FABRIC_WIDTH2 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE2[3:0], TX_FABRIC_WIDTH2);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd9) || (PLLPCSCLKDIV ==  6'b001001)) && !((((PCS_MODE_LANE3[7:4] == 4'b1011) && (RX_FABRIC_WIDTH3==20 || RX_FABRIC_WIDTH3 ==40 || RX_FABRIC_WIDTH3 ==80)) ||   ((PCS_MODE_LANE3[7:4] == 4'b0111) && (RX_FABRIC_WIDTH3 ==16 ||RX_FABRIC_WIDTH3==32 ||RX_FABRIC_WIDTH3 ==64 ))))) begin
	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b9, PCS_MODE_LANE3[7:4] %b and RX_FABRIC_WIDTH3 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE3[7:4], RX_FABRIC_WIDTH3);
	 $finish;
      end
      
      if (((PLLPCSCLKDIV == 6'd9) || (PLLPCSCLKDIV ==  6'b001001)) && !((((PCS_MODE_LANE3[3:0] == 4'b1011) && (TX_FABRIC_WIDTH3==20 || TX_FABRIC_WIDTH3 ==40 || TX_FABRIC_WIDTH3 ==80)) ||   ((PCS_MODE_LANE3[3:0] == 4'b0111) && (TX_FABRIC_WIDTH3 ==16 ||TX_FABRIC_WIDTH3==32 ||TX_FABRIC_WIDTH3 ==64 ))))) begin
    	 $display("DRC Error : When PLLPCSCLKDIV is set to 6'b9, PCS_MODE_LANE3[3:0] %b and TX_FABRIC_WIDTH3 %d is not valid for instance %m of GTHE1_QUAD.", PCS_MODE_LANE3[3:0], TX_FABRIC_WIDTH3);
	 $finish;
      end
      
   end // always @ (PLLPCSCLKDIV)
   
   // End DRC checks
   
  initial begin

   case (RX_FABRIC_WIDTH0)
      6466 : RX_FABRIC_WIDTH0_BINARY = 3'b111;
      8 : RX_FABRIC_WIDTH0_BINARY = 3'b000;
      10 : RX_FABRIC_WIDTH0_BINARY = 3'b000;
      16 : RX_FABRIC_WIDTH0_BINARY = 3'b000;
      20 : RX_FABRIC_WIDTH0_BINARY = 3'b000;
      32 : RX_FABRIC_WIDTH0_BINARY = 3'b011;
      40 : RX_FABRIC_WIDTH0_BINARY = 3'b101;
      64 : RX_FABRIC_WIDTH0_BINARY = 3'b010;
      80 : RX_FABRIC_WIDTH0_BINARY = 3'b110;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_FABRIC_WIDTH0 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are 8 to 6466.", RX_FABRIC_WIDTH0, 6466);
        $finish;
      end
    endcase

    case (RX_FABRIC_WIDTH1)
      6466 : RX_FABRIC_WIDTH1_BINARY = 3'b111;
      8 : RX_FABRIC_WIDTH1_BINARY = 3'b000;
      10 : RX_FABRIC_WIDTH1_BINARY = 3'b000;
      16 : RX_FABRIC_WIDTH1_BINARY = 3'b000;
      20 : RX_FABRIC_WIDTH1_BINARY = 3'b000;
      32 : RX_FABRIC_WIDTH1_BINARY = 3'b011;
      40 : RX_FABRIC_WIDTH1_BINARY = 3'b101;
      64 : RX_FABRIC_WIDTH1_BINARY = 3'b010;
      80 : RX_FABRIC_WIDTH1_BINARY = 3'b110;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_FABRIC_WIDTH1 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are 8 to 6466.", RX_FABRIC_WIDTH1, 6466);
        $finish;
      end
    endcase

    case (RX_FABRIC_WIDTH2)
      6466 : RX_FABRIC_WIDTH2_BINARY = 3'b111;
      8 : RX_FABRIC_WIDTH2_BINARY = 3'b000;
      10 : RX_FABRIC_WIDTH2_BINARY = 3'b000;
      16 : RX_FABRIC_WIDTH2_BINARY = 3'b000;
      20 : RX_FABRIC_WIDTH2_BINARY = 3'b000;
      32 : RX_FABRIC_WIDTH2_BINARY = 3'b011;
      40 : RX_FABRIC_WIDTH2_BINARY = 3'b101;
      64 : RX_FABRIC_WIDTH2_BINARY = 3'b010;
      80 : RX_FABRIC_WIDTH2_BINARY = 3'b110;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_FABRIC_WIDTH2 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are 8 to 6466.", RX_FABRIC_WIDTH2, 6466);
        $finish;
      end
    endcase

    case (RX_FABRIC_WIDTH3)
      6466 : RX_FABRIC_WIDTH3_BINARY = 3'b111;
      8 : RX_FABRIC_WIDTH3_BINARY = 3'b000;
      10 : RX_FABRIC_WIDTH3_BINARY = 3'b000;
      16 : RX_FABRIC_WIDTH3_BINARY = 3'b000;
      20 : RX_FABRIC_WIDTH3_BINARY = 3'b000;
      32 : RX_FABRIC_WIDTH3_BINARY = 3'b011;
      40 : RX_FABRIC_WIDTH3_BINARY = 3'b101;
      64 : RX_FABRIC_WIDTH3_BINARY = 3'b010;
      80 : RX_FABRIC_WIDTH3_BINARY = 3'b110;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_FABRIC_WIDTH3 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are 8 to 6466.", RX_FABRIC_WIDTH3, 6466);
        $finish;
      end
    endcase

    case (SIM_GTHRESET_SPEEDUP)
      1 : SIM_GTHRESET_SPEEDUP_BINARY =  1;
      0 : SIM_GTHRESET_SPEEDUP_BINARY =  0;
      default : begin
        $display("Attribute Syntax Error : The Attribute SIM_GTHRESET_SPEEDUP on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are 0 to 1.", SIM_GTHRESET_SPEEDUP, 1);
        $finish;
      end
    endcase

    case (SIM_VERSION)
      "1.0" : SIM_VERSION_BINARY = 0;
      "0.0" : SIM_VERSION_BINARY = 0;
      "2.0" : SIM_VERSION_BINARY = 0;
      default : begin
        $display("Attribute Syntax Error : The Attribute SIM_VERSION on GTHE1_QUAD instance %m is set to %s.  Legal values for this attribute are 1.0, 0.0, or 2.0.", SIM_VERSION);
        $finish;
      end
    endcase
    case (TX_FABRIC_WIDTH0)
      6466 : TX_FABRIC_WIDTH0_BINARY = 3'b111;
      8 : TX_FABRIC_WIDTH0_BINARY = 3'b000;
      10 : TX_FABRIC_WIDTH0_BINARY = 3'b000;
      16 : TX_FABRIC_WIDTH0_BINARY = 3'b000;
      20 : TX_FABRIC_WIDTH0_BINARY = 3'b000;
      32 : TX_FABRIC_WIDTH0_BINARY = 3'b011;
      40 : TX_FABRIC_WIDTH0_BINARY = 3'b101;
      64 : TX_FABRIC_WIDTH0_BINARY = 3'b010;
      80 : TX_FABRIC_WIDTH0_BINARY = 3'b110;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_FABRIC_WIDTH0 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are 8 to 6466.", TX_FABRIC_WIDTH0, 6466);
        $finish;
      end
    endcase

    case (TX_FABRIC_WIDTH1)
      6466 : TX_FABRIC_WIDTH1_BINARY = 3'b111;
      8 : TX_FABRIC_WIDTH1_BINARY = 3'b000;
      10 : TX_FABRIC_WIDTH1_BINARY = 3'b000;
      16 : TX_FABRIC_WIDTH1_BINARY = 3'b000;
      20 : TX_FABRIC_WIDTH1_BINARY = 3'b000;
      32 : TX_FABRIC_WIDTH1_BINARY = 3'b011;
      40 : TX_FABRIC_WIDTH1_BINARY = 3'b101;
      64 : TX_FABRIC_WIDTH1_BINARY = 3'b010;
      80 : TX_FABRIC_WIDTH1_BINARY = 3'b110;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_FABRIC_WIDTH1 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are 8 to 6466.", TX_FABRIC_WIDTH1, 6466);
        $finish;
      end
    endcase

    case (TX_FABRIC_WIDTH2)
      6466 : TX_FABRIC_WIDTH2_BINARY = 3'b111;
      8 : TX_FABRIC_WIDTH2_BINARY = 3'b000;
      10 : TX_FABRIC_WIDTH2_BINARY = 3'b000;
      16 : TX_FABRIC_WIDTH2_BINARY = 3'b000;
      20 : TX_FABRIC_WIDTH2_BINARY = 3'b000;
      32 : TX_FABRIC_WIDTH2_BINARY = 3'b011;
      40 : TX_FABRIC_WIDTH2_BINARY = 3'b101;
      64 : TX_FABRIC_WIDTH2_BINARY = 3'b010;
      80 : TX_FABRIC_WIDTH2_BINARY = 3'b110;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_FABRIC_WIDTH2 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are 8 to 6466.", TX_FABRIC_WIDTH2, 6466);
        $finish;
      end
    endcase

    case (TX_FABRIC_WIDTH3)
      6466 : TX_FABRIC_WIDTH3_BINARY = 3'b111;
      8 : TX_FABRIC_WIDTH3_BINARY = 3'b000;
      10 : TX_FABRIC_WIDTH3_BINARY = 3'b000;
      16 : TX_FABRIC_WIDTH3_BINARY = 3'b000;
      20 : TX_FABRIC_WIDTH3_BINARY = 3'b000;
      32 : TX_FABRIC_WIDTH3_BINARY = 3'b011;
      40 : TX_FABRIC_WIDTH3_BINARY = 3'b101;
      64 : TX_FABRIC_WIDTH3_BINARY = 3'b010;
      80 : TX_FABRIC_WIDTH3_BINARY = 3'b110;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_FABRIC_WIDTH3 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are 8 to 6466.", TX_FABRIC_WIDTH3, 6466);
        $finish;
      end
    endcase

    if ((GTH_CFG_PWRUP_LANE0 >= 0) && (GTH_CFG_PWRUP_LANE0 <= 1))
      GTH_CFG_PWRUP_LANE0_BINARY = GTH_CFG_PWRUP_LANE0;
    else begin
      $display("Attribute Syntax Error : The Attribute GTH_CFG_PWRUP_LANE0 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are  0 to 1.", GTH_CFG_PWRUP_LANE0);
      $finish;
    end

    if ((GTH_CFG_PWRUP_LANE1 >= 0) && (GTH_CFG_PWRUP_LANE1 <= 1))
      GTH_CFG_PWRUP_LANE1_BINARY = GTH_CFG_PWRUP_LANE1;
    else begin
      $display("Attribute Syntax Error : The Attribute GTH_CFG_PWRUP_LANE1 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are  0 to 1.", GTH_CFG_PWRUP_LANE1);
      $finish;
    end

    if ((GTH_CFG_PWRUP_LANE2 >= 0) && (GTH_CFG_PWRUP_LANE2 <= 1))
      GTH_CFG_PWRUP_LANE2_BINARY = GTH_CFG_PWRUP_LANE2;
    else begin
      $display("Attribute Syntax Error : The Attribute GTH_CFG_PWRUP_LANE2 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are  0 to 1.", GTH_CFG_PWRUP_LANE2);
      $finish;
    end

    if ((GTH_CFG_PWRUP_LANE3 >= 0) && (GTH_CFG_PWRUP_LANE3 <= 1))
      GTH_CFG_PWRUP_LANE3_BINARY = GTH_CFG_PWRUP_LANE3;
    else begin
      $display("Attribute Syntax Error : The Attribute GTH_CFG_PWRUP_LANE3 on GTHE1_QUAD instance %m is set to %d.  Legal values for this attribute are  0 to 1.", GTH_CFG_PWRUP_LANE3);
      $finish;
    end

  end

  wire [15:0] delay_DRPDO;
  wire [15:0] delay_MGMTPCSRDDATA;
  wire [63:0] delay_RXDATA0;
  wire [63:0] delay_RXDATA1;
  wire [63:0] delay_RXDATA2;
  wire [63:0] delay_RXDATA3;
  wire [7:0] delay_RXCODEERR0;
  wire [7:0] delay_RXCODEERR1;
  wire [7:0] delay_RXCODEERR2;
  wire [7:0] delay_RXCODEERR3;
  wire [7:0] delay_RXCTRL0;
  wire [7:0] delay_RXCTRL1;
  wire [7:0] delay_RXCTRL2;
  wire [7:0] delay_RXCTRL3;
  wire [7:0] delay_RXDISPERR0;
  wire [7:0] delay_RXDISPERR1;
  wire [7:0] delay_RXDISPERR2;
  wire [7:0] delay_RXDISPERR3;
  wire [7:0] delay_RXVALID0;
  wire [7:0] delay_RXVALID1;
  wire [7:0] delay_RXVALID2;
  wire [7:0] delay_RXVALID3;
  wire delay_DRDY;
  wire delay_GTHINITDONE;
  wire delay_MGMTPCSRDACK;
  wire delay_RXCTRLACK0;
  wire delay_RXCTRLACK1;
  wire delay_RXCTRLACK2;
  wire delay_RXCTRLACK3;
  wire delay_RXDATATAP0;
  wire delay_RXDATATAP1;
  wire delay_RXDATATAP2;
  wire delay_RXDATATAP3;
  wire delay_RXPCSCLKSMPL0;
  wire delay_RXPCSCLKSMPL1;
  wire delay_RXPCSCLKSMPL2;
  wire delay_RXPCSCLKSMPL3;
  wire delay_RXUSERCLKOUT0;
  wire delay_RXUSERCLKOUT1;
  wire delay_RXUSERCLKOUT2;
  wire delay_RXUSERCLKOUT3;
  wire delay_TSTPATH;
  wire delay_TSTREFCLKFAB;
  wire delay_TSTREFCLKOUT;
  wire delay_TXCTRLACK0;
  wire delay_TXCTRLACK1;
  wire delay_TXCTRLACK2;
  wire delay_TXCTRLACK3;
  wire delay_TXDATATAP10;
  wire delay_TXDATATAP11;
  wire delay_TXDATATAP12;
  wire delay_TXDATATAP13;
  wire delay_TXDATATAP20;
  wire delay_TXDATATAP21;
  wire delay_TXDATATAP22;
  wire delay_TXDATATAP23;
  wire delay_TXN0;
  wire delay_TXN1;
  wire delay_TXN2;
  wire delay_TXN3;
  wire delay_TXP0;
  wire delay_TXP1;
  wire delay_TXP2;
  wire delay_TXP3;
  wire delay_TXPCSCLKSMPL0;
  wire delay_TXPCSCLKSMPL1;
  wire delay_TXPCSCLKSMPL2;
  wire delay_TXPCSCLKSMPL3;
  wire delay_TXUSERCLKOUT0;
  wire delay_TXUSERCLKOUT1;
  wire delay_TXUSERCLKOUT2;
  wire delay_TXUSERCLKOUT3;

  wire [15:0] delay_DADDR;
  wire [15:0] delay_DI;
  wire [15:0] delay_MGMTPCSREGADDR;
  wire [15:0] delay_MGMTPCSWRDATA;
  wire [1:0] delay_RXPOWERDOWN0;
  wire [1:0] delay_RXPOWERDOWN1;
  wire [1:0] delay_RXPOWERDOWN2;
  wire [1:0] delay_RXPOWERDOWN3;
  wire [1:0] delay_RXRATE0;
  wire [1:0] delay_RXRATE1;
  wire [1:0] delay_RXRATE2;
  wire [1:0] delay_RXRATE3;
  wire [1:0] delay_TXPOWERDOWN0;
  wire [1:0] delay_TXPOWERDOWN1;
  wire [1:0] delay_TXPOWERDOWN2;
  wire [1:0] delay_TXPOWERDOWN3;
  wire [1:0] delay_TXRATE0;
  wire [1:0] delay_TXRATE1;
  wire [1:0] delay_TXRATE2;
  wire [1:0] delay_TXRATE3;
  wire [2:0] delay_PLLREFCLKSEL;
  wire [2:0] delay_SAMPLERATE0;
  wire [2:0] delay_SAMPLERATE1;
  wire [2:0] delay_SAMPLERATE2;
  wire [2:0] delay_SAMPLERATE3;
  wire [2:0] delay_TXMARGIN0;
  wire [2:0] delay_TXMARGIN1;
  wire [2:0] delay_TXMARGIN2;
  wire [2:0] delay_TXMARGIN3;
  wire [3:0] delay_MGMTPCSLANESEL;
  wire [4:0] delay_MGMTPCSMMDADDR;
  wire [5:0] delay_PLLPCSCLKDIV;
  wire [63:0] delay_TXDATA0;
  wire [63:0] delay_TXDATA1;
  wire [63:0] delay_TXDATA2;
  wire [63:0] delay_TXDATA3;
  wire [7:0] delay_TXCTRL0;
  wire [7:0] delay_TXCTRL1;
  wire [7:0] delay_TXCTRL2;
  wire [7:0] delay_TXCTRL3;
  wire [7:0] delay_TXDATAMSB0;
  wire [7:0] delay_TXDATAMSB1;
  wire [7:0] delay_TXDATAMSB2;
  wire [7:0] delay_TXDATAMSB3;
  wire delay_DCLK;
  wire delay_DEN;
  wire delay_DFETRAINCTRL0;
  wire delay_DFETRAINCTRL1;
  wire delay_DFETRAINCTRL2;
  wire delay_DFETRAINCTRL3;
  wire delay_DISABLEDRP;
  wire delay_DWE;
  wire delay_GTHINIT;
  wire delay_GTHRESET;
  wire delay_GTHX2LANE01;
  wire delay_GTHX2LANE23;
  wire delay_GTHX4LANE;
  wire delay_MGMTPCSREGRD;
  wire delay_MGMTPCSREGWR;
  wire delay_POWERDOWN0;
  wire delay_POWERDOWN1;
  wire delay_POWERDOWN2;
  wire delay_POWERDOWN3;
  wire delay_REFCLK;
  wire delay_RXBUFRESET0;
  wire delay_RXBUFRESET1;
  wire delay_RXBUFRESET2;
  wire delay_RXBUFRESET3;
  wire delay_RXENCOMMADET0;
  wire delay_RXENCOMMADET1;
  wire delay_RXENCOMMADET2;
  wire delay_RXENCOMMADET3;
  wire delay_RXN0;
  wire delay_RXN1;
  wire delay_RXN2;
  wire delay_RXN3;
  wire delay_RXP0;
  wire delay_RXP1;
  wire delay_RXP2;
  wire delay_RXP3;
  wire delay_RXPOLARITY0;
  wire delay_RXPOLARITY1;
  wire delay_RXPOLARITY2;
  wire delay_RXPOLARITY3;
  wire delay_RXSLIP0;
  wire delay_RXSLIP1;
  wire delay_RXSLIP2;
  wire delay_RXSLIP3;
  wire delay_RXUSERCLKIN0;
  wire delay_RXUSERCLKIN1;
  wire delay_RXUSERCLKIN2;
  wire delay_RXUSERCLKIN3;
  wire delay_TXBUFRESET0;
  wire delay_TXBUFRESET1;
  wire delay_TXBUFRESET2;
  wire delay_TXBUFRESET3;
  wire delay_TXDEEMPH0;
  wire delay_TXDEEMPH1;
  wire delay_TXDEEMPH2;
  wire delay_TXDEEMPH3;
  wire delay_TXUSERCLKIN0;
  wire delay_TXUSERCLKIN1;
  wire delay_TXUSERCLKIN2;
  wire delay_TXUSERCLKIN3;

  assign #(OUTCLK_DELAY) RXUSERCLKOUT0 = delay_RXUSERCLKOUT0;
  assign #(OUTCLK_DELAY) RXUSERCLKOUT1 = delay_RXUSERCLKOUT1;
  assign #(OUTCLK_DELAY) RXUSERCLKOUT2 = delay_RXUSERCLKOUT2;
  assign #(OUTCLK_DELAY) RXUSERCLKOUT3 = delay_RXUSERCLKOUT3;
  assign #(OUTCLK_DELAY) TSTPATH = delay_TSTPATH;
  assign #(OUTCLK_DELAY) TSTREFCLKFAB = delay_TSTREFCLKFAB;
  assign #(OUTCLK_DELAY) TSTREFCLKOUT = delay_TSTREFCLKOUT;
  assign #(OUTCLK_DELAY) TXUSERCLKOUT0 = delay_TXUSERCLKOUT0;
  assign #(OUTCLK_DELAY) TXUSERCLKOUT1 = delay_TXUSERCLKOUT1;
  assign #(OUTCLK_DELAY) TXUSERCLKOUT2 = delay_TXUSERCLKOUT2;
  assign #(OUTCLK_DELAY) TXUSERCLKOUT3 = delay_TXUSERCLKOUT3;

  assign #(out_delay) DRDY = delay_DRDY;
  assign #(out_delay) DRPDO = delay_DRPDO;
  assign #(out_delay) GTHINITDONE = delay_GTHINITDONE;
  assign #(out_delay) MGMTPCSRDACK = delay_MGMTPCSRDACK;
  assign #(out_delay) MGMTPCSRDDATA = delay_MGMTPCSRDDATA;
  assign #(out_delay) RXCODEERR0 = delay_RXCODEERR0;
  assign #(out_delay) RXCODEERR1 = delay_RXCODEERR1;
  assign #(out_delay) RXCODEERR2 = delay_RXCODEERR2;
  assign #(out_delay) RXCODEERR3 = delay_RXCODEERR3;
  assign #(out_delay) RXCTRL0 = delay_RXCTRL0;
  assign #(out_delay) RXCTRL1 = delay_RXCTRL1;
  assign #(out_delay) RXCTRL2 = delay_RXCTRL2;
  assign #(out_delay) RXCTRL3 = delay_RXCTRL3;
  assign #(out_delay) RXCTRLACK0 = delay_RXCTRLACK0;
  assign #(out_delay) RXCTRLACK1 = delay_RXCTRLACK1;
  assign #(out_delay) RXCTRLACK2 = delay_RXCTRLACK2;
  assign #(out_delay) RXCTRLACK3 = delay_RXCTRLACK3;
  assign #(out_delay) RXDATA0 = delay_RXDATA0;
  assign #(out_delay) RXDATA1 = delay_RXDATA1;
  assign #(out_delay) RXDATA2 = delay_RXDATA2;
  assign #(out_delay) RXDATA3 = delay_RXDATA3;
  assign #(out_delay) RXDATATAP0 = delay_RXDATATAP0;
  assign #(out_delay) RXDATATAP1 = delay_RXDATATAP1;
  assign #(out_delay) RXDATATAP2 = delay_RXDATATAP2;
  assign #(out_delay) RXDATATAP3 = delay_RXDATATAP3;
  assign #(out_delay) RXDISPERR0 = delay_RXDISPERR0;
  assign #(out_delay) RXDISPERR1 = delay_RXDISPERR1;
  assign #(out_delay) RXDISPERR2 = delay_RXDISPERR2;
  assign #(out_delay) RXDISPERR3 = delay_RXDISPERR3;
  assign #(out_delay) RXPCSCLKSMPL0 = delay_RXPCSCLKSMPL0;
  assign #(out_delay) RXPCSCLKSMPL1 = delay_RXPCSCLKSMPL1;
  assign #(out_delay) RXPCSCLKSMPL2 = delay_RXPCSCLKSMPL2;
  assign #(out_delay) RXPCSCLKSMPL3 = delay_RXPCSCLKSMPL3;
  assign #(out_delay) RXVALID0 = delay_RXVALID0;
  assign #(out_delay) RXVALID1 = delay_RXVALID1;
  assign #(out_delay) RXVALID2 = delay_RXVALID2;
  assign #(out_delay) RXVALID3 = delay_RXVALID3;
  assign #(out_delay) TXCTRLACK0 = delay_TXCTRLACK0;
  assign #(out_delay) TXCTRLACK1 = delay_TXCTRLACK1;
  assign #(out_delay) TXCTRLACK2 = delay_TXCTRLACK2;
  assign #(out_delay) TXCTRLACK3 = delay_TXCTRLACK3;
  assign #(out_delay) TXDATATAP10 = delay_TXDATATAP10;
  assign #(out_delay) TXDATATAP11 = delay_TXDATATAP11;
  assign #(out_delay) TXDATATAP12 = delay_TXDATATAP12;
  assign #(out_delay) TXDATATAP13 = delay_TXDATATAP13;
  assign #(out_delay) TXDATATAP20 = delay_TXDATATAP20;
  assign #(out_delay) TXDATATAP21 = delay_TXDATATAP21;
  assign #(out_delay) TXDATATAP22 = delay_TXDATATAP22;
  assign #(out_delay) TXDATATAP23 = delay_TXDATATAP23;
  assign #(out_delay) TXN0 = delay_TXN0;
  assign #(out_delay) TXN1 = delay_TXN1;
  assign #(out_delay) TXN2 = delay_TXN2;
  assign #(out_delay) TXN3 = delay_TXN3;
  assign #(out_delay) TXP0 = delay_TXP0;
  assign #(out_delay) TXP1 = delay_TXP1;
  assign #(out_delay) TXP2 = delay_TXP2;
  assign #(out_delay) TXP3 = delay_TXP3;
  assign #(out_delay) TXPCSCLKSMPL0 = delay_TXPCSCLKSMPL0;
  assign #(out_delay) TXPCSCLKSMPL1 = delay_TXPCSCLKSMPL1;
  assign #(out_delay) TXPCSCLKSMPL2 = delay_TXPCSCLKSMPL2;
  assign #(out_delay) TXPCSCLKSMPL3 = delay_TXPCSCLKSMPL3;

  assign #(INCLK_DELAY) delay_DCLK = DCLK;
  assign #(INCLK_DELAY) delay_REFCLK = REFCLK;
  assign #(INCLK_DELAY) delay_RXUSERCLKIN0 = RXUSERCLKIN0;
  assign #(INCLK_DELAY) delay_RXUSERCLKIN1 = RXUSERCLKIN1;
  assign #(INCLK_DELAY) delay_RXUSERCLKIN2 = RXUSERCLKIN2;
  assign #(INCLK_DELAY) delay_RXUSERCLKIN3 = RXUSERCLKIN3;
  assign #(INCLK_DELAY) delay_TXUSERCLKIN0 = TXUSERCLKIN0;
  assign #(INCLK_DELAY) delay_TXUSERCLKIN1 = TXUSERCLKIN1;
  assign #(INCLK_DELAY) delay_TXUSERCLKIN2 = TXUSERCLKIN2;
  assign #(INCLK_DELAY) delay_TXUSERCLKIN3 = TXUSERCLKIN3;

  assign #(in_delay) delay_DADDR = DADDR;
  assign #(in_delay) delay_DEN = DEN;
  assign #(in_delay) delay_DFETRAINCTRL0 = DFETRAINCTRL0;
  assign #(in_delay) delay_DFETRAINCTRL1 = DFETRAINCTRL1;
  assign #(in_delay) delay_DFETRAINCTRL2 = DFETRAINCTRL2;
  assign #(in_delay) delay_DFETRAINCTRL3 = DFETRAINCTRL3;
  assign #(in_delay) delay_DI = DI;
  assign #(in_delay) delay_DISABLEDRP = DISABLEDRP;
  assign #(in_delay) delay_DWE = DWE;
  assign #(in_delay) delay_GTHINIT = GTHINIT;
  assign #(in_delay) delay_GTHRESET = GTHRESET;
  assign #(in_delay) delay_GTHX2LANE01 = GTHX2LANE01;
  assign #(in_delay) delay_GTHX2LANE23 = GTHX2LANE23;
  assign #(in_delay) delay_GTHX4LANE = GTHX4LANE;
  assign #(in_delay) delay_MGMTPCSLANESEL = MGMTPCSLANESEL;
  assign #(in_delay) delay_MGMTPCSMMDADDR = MGMTPCSMMDADDR;
  assign #(in_delay) delay_MGMTPCSREGADDR = MGMTPCSREGADDR;
  assign #(in_delay) delay_MGMTPCSREGRD = MGMTPCSREGRD;
  assign #(in_delay) delay_MGMTPCSREGWR = MGMTPCSREGWR;
  assign #(in_delay) delay_MGMTPCSWRDATA = MGMTPCSWRDATA;
  assign #(in_delay) delay_PLLPCSCLKDIV = PLLPCSCLKDIV;
  assign #(in_delay) delay_PLLREFCLKSEL = PLLREFCLKSEL;
  assign #(in_delay) delay_POWERDOWN0 = POWERDOWN0;
  assign #(in_delay) delay_POWERDOWN1 = POWERDOWN1;
  assign #(in_delay) delay_POWERDOWN2 = POWERDOWN2;
  assign #(in_delay) delay_POWERDOWN3 = POWERDOWN3;
  assign #(in_delay) delay_RXBUFRESET0 = RXBUFRESET0;
  assign #(in_delay) delay_RXBUFRESET1 = RXBUFRESET1;
  assign #(in_delay) delay_RXBUFRESET2 = RXBUFRESET2;
  assign #(in_delay) delay_RXBUFRESET3 = RXBUFRESET3;
  assign #(in_delay) delay_RXENCOMMADET0 = RXENCOMMADET0;
  assign #(in_delay) delay_RXENCOMMADET1 = RXENCOMMADET1;
  assign #(in_delay) delay_RXENCOMMADET2 = RXENCOMMADET2;
  assign #(in_delay) delay_RXENCOMMADET3 = RXENCOMMADET3;
  assign #(in_delay) delay_RXN0 = RXN0;
  assign #(in_delay) delay_RXN1 = RXN1;
  assign #(in_delay) delay_RXN2 = RXN2;
  assign #(in_delay) delay_RXN3 = RXN3;
  assign #(in_delay) delay_RXP0 = RXP0;
  assign #(in_delay) delay_RXP1 = RXP1;
  assign #(in_delay) delay_RXP2 = RXP2;
  assign #(in_delay) delay_RXP3 = RXP3;
  assign #(in_delay) delay_RXPOLARITY0 = RXPOLARITY0;
  assign #(in_delay) delay_RXPOLARITY1 = RXPOLARITY1;
  assign #(in_delay) delay_RXPOLARITY2 = RXPOLARITY2;
  assign #(in_delay) delay_RXPOLARITY3 = RXPOLARITY3;
  assign #(in_delay) delay_RXPOWERDOWN0 = RXPOWERDOWN0;
  assign #(in_delay) delay_RXPOWERDOWN1 = RXPOWERDOWN1;
  assign #(in_delay) delay_RXPOWERDOWN2 = RXPOWERDOWN2;
  assign #(in_delay) delay_RXPOWERDOWN3 = RXPOWERDOWN3;
  assign #(in_delay) delay_RXRATE0 = RXRATE0;
  assign #(in_delay) delay_RXRATE1 = RXRATE1;
  assign #(in_delay) delay_RXRATE2 = RXRATE2;
  assign #(in_delay) delay_RXRATE3 = RXRATE3;
  assign #(in_delay) delay_RXSLIP0 = RXSLIP0;
  assign #(in_delay) delay_RXSLIP1 = RXSLIP1;
  assign #(in_delay) delay_RXSLIP2 = RXSLIP2;
  assign #(in_delay) delay_RXSLIP3 = RXSLIP3;
  assign #(in_delay) delay_SAMPLERATE0 = SAMPLERATE0;
  assign #(in_delay) delay_SAMPLERATE1 = SAMPLERATE1;
  assign #(in_delay) delay_SAMPLERATE2 = SAMPLERATE2;
  assign #(in_delay) delay_SAMPLERATE3 = SAMPLERATE3;
  assign #(in_delay) delay_TXBUFRESET0 = TXBUFRESET0;
  assign #(in_delay) delay_TXBUFRESET1 = TXBUFRESET1;
  assign #(in_delay) delay_TXBUFRESET2 = TXBUFRESET2;
  assign #(in_delay) delay_TXBUFRESET3 = TXBUFRESET3;
  assign #(in_delay) delay_TXCTRL0 = TXCTRL0;
  assign #(in_delay) delay_TXCTRL1 = TXCTRL1;
  assign #(in_delay) delay_TXCTRL2 = TXCTRL2;
  assign #(in_delay) delay_TXCTRL3 = TXCTRL3;
  assign #(in_delay) delay_TXDATA0 = TXDATA0;
  assign #(in_delay) delay_TXDATA1 = TXDATA1;
  assign #(in_delay) delay_TXDATA2 = TXDATA2;
  assign #(in_delay) delay_TXDATA3 = TXDATA3;
  assign #(in_delay) delay_TXDATAMSB0 = TXDATAMSB0;
  assign #(in_delay) delay_TXDATAMSB1 = TXDATAMSB1;
  assign #(in_delay) delay_TXDATAMSB2 = TXDATAMSB2;
  assign #(in_delay) delay_TXDATAMSB3 = TXDATAMSB3;
  assign #(in_delay) delay_TXDEEMPH0 = TXDEEMPH0;
  assign #(in_delay) delay_TXDEEMPH1 = TXDEEMPH1;
  assign #(in_delay) delay_TXDEEMPH2 = TXDEEMPH2;
  assign #(in_delay) delay_TXDEEMPH3 = TXDEEMPH3;
  assign #(in_delay) delay_TXMARGIN0 = TXMARGIN0;
  assign #(in_delay) delay_TXMARGIN1 = TXMARGIN1;
  assign #(in_delay) delay_TXMARGIN2 = TXMARGIN2;
  assign #(in_delay) delay_TXMARGIN3 = TXMARGIN3;
  assign #(in_delay) delay_TXPOWERDOWN0 = TXPOWERDOWN0;
  assign #(in_delay) delay_TXPOWERDOWN1 = TXPOWERDOWN1;
  assign #(in_delay) delay_TXPOWERDOWN2 = TXPOWERDOWN2;
  assign #(in_delay) delay_TXPOWERDOWN3 = TXPOWERDOWN3;
  assign #(in_delay) delay_TXRATE0 = TXRATE0;
  assign #(in_delay) delay_TXRATE1 = TXRATE1;
  assign #(in_delay) delay_TXRATE2 = TXRATE2;
  assign #(in_delay) delay_TXRATE3 = TXRATE3;

  B_GTHE1_QUAD #(
    .BER_CONST_PTRN0 (BER_CONST_PTRN0),
    .BER_CONST_PTRN1 (BER_CONST_PTRN1),
    .BUFFER_CONFIG_LANE0 (BUFFER_CONFIG_LANE0),
    .BUFFER_CONFIG_LANE1 (BUFFER_CONFIG_LANE1),
    .BUFFER_CONFIG_LANE2 (BUFFER_CONFIG_LANE2),
    .BUFFER_CONFIG_LANE3 (BUFFER_CONFIG_LANE3),
    .DFE_TRAIN_CTRL_LANE0 (DFE_TRAIN_CTRL_LANE0),
    .DFE_TRAIN_CTRL_LANE1 (DFE_TRAIN_CTRL_LANE1),
    .DFE_TRAIN_CTRL_LANE2 (DFE_TRAIN_CTRL_LANE2),
    .DFE_TRAIN_CTRL_LANE3 (DFE_TRAIN_CTRL_LANE3),
    .DLL_CFG0 (DLL_CFG0),
    .DLL_CFG1 (DLL_CFG1),
    .E10GBASEKR_LD_COEFF_UPD_LANE0 (E10GBASEKR_LD_COEFF_UPD_LANE0),
    .E10GBASEKR_LD_COEFF_UPD_LANE1 (E10GBASEKR_LD_COEFF_UPD_LANE1),
    .E10GBASEKR_LD_COEFF_UPD_LANE2 (E10GBASEKR_LD_COEFF_UPD_LANE2),
    .E10GBASEKR_LD_COEFF_UPD_LANE3 (E10GBASEKR_LD_COEFF_UPD_LANE3),
    .E10GBASEKR_LP_COEFF_UPD_LANE0 (E10GBASEKR_LP_COEFF_UPD_LANE0),
    .E10GBASEKR_LP_COEFF_UPD_LANE1 (E10GBASEKR_LP_COEFF_UPD_LANE1),
    .E10GBASEKR_LP_COEFF_UPD_LANE2 (E10GBASEKR_LP_COEFF_UPD_LANE2),
    .E10GBASEKR_LP_COEFF_UPD_LANE3 (E10GBASEKR_LP_COEFF_UPD_LANE3),
    .E10GBASEKR_PMA_CTRL_LANE0 (E10GBASEKR_PMA_CTRL_LANE0),
    .E10GBASEKR_PMA_CTRL_LANE1 (E10GBASEKR_PMA_CTRL_LANE1),
    .E10GBASEKR_PMA_CTRL_LANE2 (E10GBASEKR_PMA_CTRL_LANE2),
    .E10GBASEKR_PMA_CTRL_LANE3 (E10GBASEKR_PMA_CTRL_LANE3),
    .E10GBASEKX_CTRL_LANE0 (E10GBASEKX_CTRL_LANE0),
    .E10GBASEKX_CTRL_LANE1 (E10GBASEKX_CTRL_LANE1),
    .E10GBASEKX_CTRL_LANE2 (E10GBASEKX_CTRL_LANE2),
    .E10GBASEKX_CTRL_LANE3 (E10GBASEKX_CTRL_LANE3),
    .E10GBASER_PCS_CFG_LANE0 (E10GBASER_PCS_CFG_LANE0),
    .E10GBASER_PCS_CFG_LANE1 (E10GBASER_PCS_CFG_LANE1),
    .E10GBASER_PCS_CFG_LANE2 (E10GBASER_PCS_CFG_LANE2),
    .E10GBASER_PCS_CFG_LANE3 (E10GBASER_PCS_CFG_LANE3),
    .E10GBASER_PCS_SEEDA0_LANE0 (E10GBASER_PCS_SEEDA0_LANE0),
    .E10GBASER_PCS_SEEDA0_LANE1 (E10GBASER_PCS_SEEDA0_LANE1),
    .E10GBASER_PCS_SEEDA0_LANE2 (E10GBASER_PCS_SEEDA0_LANE2),
    .E10GBASER_PCS_SEEDA0_LANE3 (E10GBASER_PCS_SEEDA0_LANE3),
    .E10GBASER_PCS_SEEDA1_LANE0 (E10GBASER_PCS_SEEDA1_LANE0),
    .E10GBASER_PCS_SEEDA1_LANE1 (E10GBASER_PCS_SEEDA1_LANE1),
    .E10GBASER_PCS_SEEDA1_LANE2 (E10GBASER_PCS_SEEDA1_LANE2),
    .E10GBASER_PCS_SEEDA1_LANE3 (E10GBASER_PCS_SEEDA1_LANE3),
    .E10GBASER_PCS_SEEDA2_LANE0 (E10GBASER_PCS_SEEDA2_LANE0),
    .E10GBASER_PCS_SEEDA2_LANE1 (E10GBASER_PCS_SEEDA2_LANE1),
    .E10GBASER_PCS_SEEDA2_LANE2 (E10GBASER_PCS_SEEDA2_LANE2),
    .E10GBASER_PCS_SEEDA2_LANE3 (E10GBASER_PCS_SEEDA2_LANE3),
    .E10GBASER_PCS_SEEDA3_LANE0 (E10GBASER_PCS_SEEDA3_LANE0),
    .E10GBASER_PCS_SEEDA3_LANE1 (E10GBASER_PCS_SEEDA3_LANE1),
    .E10GBASER_PCS_SEEDA3_LANE2 (E10GBASER_PCS_SEEDA3_LANE2),
    .E10GBASER_PCS_SEEDA3_LANE3 (E10GBASER_PCS_SEEDA3_LANE3),
    .E10GBASER_PCS_SEEDB0_LANE0 (E10GBASER_PCS_SEEDB0_LANE0),
    .E10GBASER_PCS_SEEDB0_LANE1 (E10GBASER_PCS_SEEDB0_LANE1),
    .E10GBASER_PCS_SEEDB0_LANE2 (E10GBASER_PCS_SEEDB0_LANE2),
    .E10GBASER_PCS_SEEDB0_LANE3 (E10GBASER_PCS_SEEDB0_LANE3),
    .E10GBASER_PCS_SEEDB1_LANE0 (E10GBASER_PCS_SEEDB1_LANE0),
    .E10GBASER_PCS_SEEDB1_LANE1 (E10GBASER_PCS_SEEDB1_LANE1),
    .E10GBASER_PCS_SEEDB1_LANE2 (E10GBASER_PCS_SEEDB1_LANE2),
    .E10GBASER_PCS_SEEDB1_LANE3 (E10GBASER_PCS_SEEDB1_LANE3),
    .E10GBASER_PCS_SEEDB2_LANE0 (E10GBASER_PCS_SEEDB2_LANE0),
    .E10GBASER_PCS_SEEDB2_LANE1 (E10GBASER_PCS_SEEDB2_LANE1),
    .E10GBASER_PCS_SEEDB2_LANE2 (E10GBASER_PCS_SEEDB2_LANE2),
    .E10GBASER_PCS_SEEDB2_LANE3 (E10GBASER_PCS_SEEDB2_LANE3),
    .E10GBASER_PCS_SEEDB3_LANE0 (E10GBASER_PCS_SEEDB3_LANE0),
    .E10GBASER_PCS_SEEDB3_LANE1 (E10GBASER_PCS_SEEDB3_LANE1),
    .E10GBASER_PCS_SEEDB3_LANE2 (E10GBASER_PCS_SEEDB3_LANE2),
    .E10GBASER_PCS_SEEDB3_LANE3 (E10GBASER_PCS_SEEDB3_LANE3),
    .E10GBASER_PCS_TEST_CTRL_LANE0 (E10GBASER_PCS_TEST_CTRL_LANE0),
    .E10GBASER_PCS_TEST_CTRL_LANE1 (E10GBASER_PCS_TEST_CTRL_LANE1),
    .E10GBASER_PCS_TEST_CTRL_LANE2 (E10GBASER_PCS_TEST_CTRL_LANE2),
    .E10GBASER_PCS_TEST_CTRL_LANE3 (E10GBASER_PCS_TEST_CTRL_LANE3),
    .E10GBASEX_PCS_TSTCTRL_LANE0 (E10GBASEX_PCS_TSTCTRL_LANE0),
    .E10GBASEX_PCS_TSTCTRL_LANE1 (E10GBASEX_PCS_TSTCTRL_LANE1),
    .E10GBASEX_PCS_TSTCTRL_LANE2 (E10GBASEX_PCS_TSTCTRL_LANE2),
    .E10GBASEX_PCS_TSTCTRL_LANE3 (E10GBASEX_PCS_TSTCTRL_LANE3),
    .GLBL0_NOISE_CTRL (GLBL0_NOISE_CTRL),
    .GLBL_AMON_SEL (GLBL_AMON_SEL),
    .GLBL_DMON_SEL (GLBL_DMON_SEL),
    .GLBL_PWR_CTRL (GLBL_PWR_CTRL),
    .GTH_CFG_PWRUP_LANE0 (GTH_CFG_PWRUP_LANE0),
    .GTH_CFG_PWRUP_LANE1 (GTH_CFG_PWRUP_LANE1),
    .GTH_CFG_PWRUP_LANE2 (GTH_CFG_PWRUP_LANE2),
    .GTH_CFG_PWRUP_LANE3 (GTH_CFG_PWRUP_LANE3),
    .LANE_AMON_SEL (LANE_AMON_SEL),
    .LANE_DMON_SEL (LANE_DMON_SEL),
    .LANE_LNK_CFGOVRD (LANE_LNK_CFGOVRD),
    .LANE_PWR_CTRL_LANE0 (LANE_PWR_CTRL_LANE0),
    .LANE_PWR_CTRL_LANE1 (LANE_PWR_CTRL_LANE1),
    .LANE_PWR_CTRL_LANE2 (LANE_PWR_CTRL_LANE2),
    .LANE_PWR_CTRL_LANE3 (LANE_PWR_CTRL_LANE3),
    .LNK_TRN_CFG_LANE0 (LNK_TRN_CFG_LANE0),
    .LNK_TRN_CFG_LANE1 (LNK_TRN_CFG_LANE1),
    .LNK_TRN_CFG_LANE2 (LNK_TRN_CFG_LANE2),
    .LNK_TRN_CFG_LANE3 (LNK_TRN_CFG_LANE3),
    .LNK_TRN_COEFF_REQ_LANE0 (LNK_TRN_COEFF_REQ_LANE0),
    .LNK_TRN_COEFF_REQ_LANE1 (LNK_TRN_COEFF_REQ_LANE1),
    .LNK_TRN_COEFF_REQ_LANE2 (LNK_TRN_COEFF_REQ_LANE2),
    .LNK_TRN_COEFF_REQ_LANE3 (LNK_TRN_COEFF_REQ_LANE3),
    .MISC_CFG (MISC_CFG),
    .MODE_CFG1 (MODE_CFG1),
    .MODE_CFG2 (MODE_CFG2),
    .MODE_CFG3 (MODE_CFG3),
    .MODE_CFG4 (MODE_CFG4),
    .MODE_CFG5 (MODE_CFG5),
    .MODE_CFG6 (MODE_CFG6),
    .MODE_CFG7 (MODE_CFG7),
    .PCS_ABILITY_LANE0 (PCS_ABILITY_LANE0),
    .PCS_ABILITY_LANE1 (PCS_ABILITY_LANE1),
    .PCS_ABILITY_LANE2 (PCS_ABILITY_LANE2),
    .PCS_ABILITY_LANE3 (PCS_ABILITY_LANE3),
    .PCS_CTRL1_LANE0 (PCS_CTRL1_LANE0),
    .PCS_CTRL1_LANE1 (PCS_CTRL1_LANE1),
    .PCS_CTRL1_LANE2 (PCS_CTRL1_LANE2),
    .PCS_CTRL1_LANE3 (PCS_CTRL1_LANE3),
    .PCS_CTRL2_LANE0 (PCS_CTRL2_LANE0),
    .PCS_CTRL2_LANE1 (PCS_CTRL2_LANE1),
    .PCS_CTRL2_LANE2 (PCS_CTRL2_LANE2),
    .PCS_CTRL2_LANE3 (PCS_CTRL2_LANE3),
    .PCS_MISC_CFG_0_LANE0 (PCS_MISC_CFG_0_LANE0),
    .PCS_MISC_CFG_0_LANE1 (PCS_MISC_CFG_0_LANE1),
    .PCS_MISC_CFG_0_LANE2 (PCS_MISC_CFG_0_LANE2),
    .PCS_MISC_CFG_0_LANE3 (PCS_MISC_CFG_0_LANE3),
    .PCS_MISC_CFG_1_LANE0 (PCS_MISC_CFG_1_LANE0),
    .PCS_MISC_CFG_1_LANE1 (PCS_MISC_CFG_1_LANE1),
    .PCS_MISC_CFG_1_LANE2 (PCS_MISC_CFG_1_LANE2),
    .PCS_MISC_CFG_1_LANE3 (PCS_MISC_CFG_1_LANE3),
    .PCS_MODE_LANE0 (PCS_MODE_LANE0),
    .PCS_MODE_LANE1 (PCS_MODE_LANE1),
    .PCS_MODE_LANE2 (PCS_MODE_LANE2),
    .PCS_MODE_LANE3 (PCS_MODE_LANE3),
    .PCS_RESET_1_LANE0 (PCS_RESET_1_LANE0),
    .PCS_RESET_1_LANE1 (PCS_RESET_1_LANE1),
    .PCS_RESET_1_LANE2 (PCS_RESET_1_LANE2),
    .PCS_RESET_1_LANE3 (PCS_RESET_1_LANE3),
    .PCS_RESET_LANE0 (PCS_RESET_LANE0),
    .PCS_RESET_LANE1 (PCS_RESET_LANE1),
    .PCS_RESET_LANE2 (PCS_RESET_LANE2),
    .PCS_RESET_LANE3 (PCS_RESET_LANE3),
    .PCS_TYPE_LANE0 (PCS_TYPE_LANE0),
    .PCS_TYPE_LANE1 (PCS_TYPE_LANE1),
    .PCS_TYPE_LANE2 (PCS_TYPE_LANE2),
    .PCS_TYPE_LANE3 (PCS_TYPE_LANE3),
    .PLL_CFG0 (PLL_CFG0),
    .PLL_CFG1 (PLL_CFG1),
    .PLL_CFG2 (PLL_CFG2),
    .PMA_CTRL1_LANE0 (PMA_CTRL1_LANE0),
    .PMA_CTRL1_LANE1 (PMA_CTRL1_LANE1),
    .PMA_CTRL1_LANE2 (PMA_CTRL1_LANE2),
    .PMA_CTRL1_LANE3 (PMA_CTRL1_LANE3),
    .PMA_CTRL2_LANE0 (PMA_CTRL2_LANE0),
    .PMA_CTRL2_LANE1 (PMA_CTRL2_LANE1),
    .PMA_CTRL2_LANE2 (PMA_CTRL2_LANE2),
    .PMA_CTRL2_LANE3 (PMA_CTRL2_LANE3),
    .PMA_LPBK_CTRL_LANE0 (PMA_LPBK_CTRL_LANE0),
    .PMA_LPBK_CTRL_LANE1 (PMA_LPBK_CTRL_LANE1),
    .PMA_LPBK_CTRL_LANE2 (PMA_LPBK_CTRL_LANE2),
    .PMA_LPBK_CTRL_LANE3 (PMA_LPBK_CTRL_LANE3),
    .PRBS_BER_CFG0_LANE0 (PRBS_BER_CFG0_LANE0),
    .PRBS_BER_CFG0_LANE1 (PRBS_BER_CFG0_LANE1),
    .PRBS_BER_CFG0_LANE2 (PRBS_BER_CFG0_LANE2),
    .PRBS_BER_CFG0_LANE3 (PRBS_BER_CFG0_LANE3),
    .PRBS_BER_CFG1_LANE0 (PRBS_BER_CFG1_LANE0),
    .PRBS_BER_CFG1_LANE1 (PRBS_BER_CFG1_LANE1),
    .PRBS_BER_CFG1_LANE2 (PRBS_BER_CFG1_LANE2),
    .PRBS_BER_CFG1_LANE3 (PRBS_BER_CFG1_LANE3),
    .PRBS_CFG_LANE0 (PRBS_CFG_LANE0),
    .PRBS_CFG_LANE1 (PRBS_CFG_LANE1),
    .PRBS_CFG_LANE2 (PRBS_CFG_LANE2),
    .PRBS_CFG_LANE3 (PRBS_CFG_LANE3),
    .PTRN_CFG0_LSB (PTRN_CFG0_LSB),
    .PTRN_CFG0_MSB (PTRN_CFG0_MSB),
    .PTRN_LEN_CFG (PTRN_LEN_CFG),
    .PWRUP_DLY (PWRUP_DLY),
    .RX_AEQ_VAL0_LANE0 (RX_AEQ_VAL0_LANE0),
    .RX_AEQ_VAL0_LANE1 (RX_AEQ_VAL0_LANE1),
    .RX_AEQ_VAL0_LANE2 (RX_AEQ_VAL0_LANE2),
    .RX_AEQ_VAL0_LANE3 (RX_AEQ_VAL0_LANE3),
    .RX_AEQ_VAL1_LANE0 (RX_AEQ_VAL1_LANE0),
    .RX_AEQ_VAL1_LANE1 (RX_AEQ_VAL1_LANE1),
    .RX_AEQ_VAL1_LANE2 (RX_AEQ_VAL1_LANE2),
    .RX_AEQ_VAL1_LANE3 (RX_AEQ_VAL1_LANE3),
    .RX_AGC_CTRL_LANE0 (RX_AGC_CTRL_LANE0),
    .RX_AGC_CTRL_LANE1 (RX_AGC_CTRL_LANE1),
    .RX_AGC_CTRL_LANE2 (RX_AGC_CTRL_LANE2),
    .RX_AGC_CTRL_LANE3 (RX_AGC_CTRL_LANE3),
    .RX_CDR_CTRL0_LANE0 (RX_CDR_CTRL0_LANE0),
    .RX_CDR_CTRL0_LANE1 (RX_CDR_CTRL0_LANE1),
    .RX_CDR_CTRL0_LANE2 (RX_CDR_CTRL0_LANE2),
    .RX_CDR_CTRL0_LANE3 (RX_CDR_CTRL0_LANE3),
    .RX_CDR_CTRL1_LANE0 (RX_CDR_CTRL1_LANE0),
    .RX_CDR_CTRL1_LANE1 (RX_CDR_CTRL1_LANE1),
    .RX_CDR_CTRL1_LANE2 (RX_CDR_CTRL1_LANE2),
    .RX_CDR_CTRL1_LANE3 (RX_CDR_CTRL1_LANE3),
    .RX_CDR_CTRL2_LANE0 (RX_CDR_CTRL2_LANE0),
    .RX_CDR_CTRL2_LANE1 (RX_CDR_CTRL2_LANE1),
    .RX_CDR_CTRL2_LANE2 (RX_CDR_CTRL2_LANE2),
    .RX_CDR_CTRL2_LANE3 (RX_CDR_CTRL2_LANE3),
    .RX_CFG0_LANE0 (RX_CFG0_LANE0),
    .RX_CFG0_LANE1 (RX_CFG0_LANE1),
    .RX_CFG0_LANE2 (RX_CFG0_LANE2),
    .RX_CFG0_LANE3 (RX_CFG0_LANE3),
    .RX_CFG1_LANE0 (RX_CFG1_LANE0),
    .RX_CFG1_LANE1 (RX_CFG1_LANE1),
    .RX_CFG1_LANE2 (RX_CFG1_LANE2),
    .RX_CFG1_LANE3 (RX_CFG1_LANE3),
    .RX_CFG2_LANE0 (RX_CFG2_LANE0),
    .RX_CFG2_LANE1 (RX_CFG2_LANE1),
    .RX_CFG2_LANE2 (RX_CFG2_LANE2),
    .RX_CFG2_LANE3 (RX_CFG2_LANE3),
    .RX_CTLE_CTRL_LANE0 (RX_CTLE_CTRL_LANE0),
    .RX_CTLE_CTRL_LANE1 (RX_CTLE_CTRL_LANE1),
    .RX_CTLE_CTRL_LANE2 (RX_CTLE_CTRL_LANE2),
    .RX_CTLE_CTRL_LANE3 (RX_CTLE_CTRL_LANE3),
    .RX_CTRL_OVRD_LANE0 (RX_CTRL_OVRD_LANE0),
    .RX_CTRL_OVRD_LANE1 (RX_CTRL_OVRD_LANE1),
    .RX_CTRL_OVRD_LANE2 (RX_CTRL_OVRD_LANE2),
    .RX_CTRL_OVRD_LANE3 (RX_CTRL_OVRD_LANE3),
    .RX_FABRIC_WIDTH0 (RX_FABRIC_WIDTH0),
    .RX_FABRIC_WIDTH1 (RX_FABRIC_WIDTH1),
    .RX_FABRIC_WIDTH2 (RX_FABRIC_WIDTH2),
    .RX_FABRIC_WIDTH3 (RX_FABRIC_WIDTH3),
    .RX_LOOP_CTRL_LANE0 (RX_LOOP_CTRL_LANE0),
    .RX_LOOP_CTRL_LANE1 (RX_LOOP_CTRL_LANE1),
    .RX_LOOP_CTRL_LANE2 (RX_LOOP_CTRL_LANE2),
    .RX_LOOP_CTRL_LANE3 (RX_LOOP_CTRL_LANE3),
    .RX_MVAL0_LANE0 (RX_MVAL0_LANE0),
    .RX_MVAL0_LANE1 (RX_MVAL0_LANE1),
    .RX_MVAL0_LANE2 (RX_MVAL0_LANE2),
    .RX_MVAL0_LANE3 (RX_MVAL0_LANE3),
    .RX_MVAL1_LANE0 (RX_MVAL1_LANE0),
    .RX_MVAL1_LANE1 (RX_MVAL1_LANE1),
    .RX_MVAL1_LANE2 (RX_MVAL1_LANE2),
    .RX_MVAL1_LANE3 (RX_MVAL1_LANE3),
    .RX_P0S_CTRL (RX_P0S_CTRL),
    .RX_P0_CTRL (RX_P0_CTRL),
    .RX_P1_CTRL (RX_P1_CTRL),
    .RX_P2_CTRL (RX_P2_CTRL),
    .RX_PI_CTRL0 (RX_PI_CTRL0),
    .RX_PI_CTRL1 (RX_PI_CTRL1),
    .SIM_GTHRESET_SPEEDUP (SIM_GTHRESET_SPEEDUP),
    .SIM_VERSION (SIM_VERSION),
    .SLICE_CFG (SLICE_CFG),
    .SLICE_NOISE_CTRL_0_LANE01 (SLICE_NOISE_CTRL_0_LANE01),
    .SLICE_NOISE_CTRL_0_LANE23 (SLICE_NOISE_CTRL_0_LANE23),
    .SLICE_NOISE_CTRL_1_LANE01 (SLICE_NOISE_CTRL_1_LANE01),
    .SLICE_NOISE_CTRL_1_LANE23 (SLICE_NOISE_CTRL_1_LANE23),
    .SLICE_NOISE_CTRL_2_LANE01 (SLICE_NOISE_CTRL_2_LANE01),
    .SLICE_NOISE_CTRL_2_LANE23 (SLICE_NOISE_CTRL_2_LANE23),
    .SLICE_TX_RESET_LANE01 (SLICE_TX_RESET_LANE01),
    .SLICE_TX_RESET_LANE23 (SLICE_TX_RESET_LANE23),
    .TERM_CTRL_LANE0 (TERM_CTRL_LANE0),
    .TERM_CTRL_LANE1 (TERM_CTRL_LANE1),
    .TERM_CTRL_LANE2 (TERM_CTRL_LANE2),
    .TERM_CTRL_LANE3 (TERM_CTRL_LANE3),
    .TX_CFG0_LANE0 (TX_CFG0_LANE0),
    .TX_CFG0_LANE1 (TX_CFG0_LANE1),
    .TX_CFG0_LANE2 (TX_CFG0_LANE2),
    .TX_CFG0_LANE3 (TX_CFG0_LANE3),
    .TX_CFG1_LANE0 (TX_CFG1_LANE0),
    .TX_CFG1_LANE1 (TX_CFG1_LANE1),
    .TX_CFG1_LANE2 (TX_CFG1_LANE2),
    .TX_CFG1_LANE3 (TX_CFG1_LANE3),
    .TX_CFG2_LANE0 (TX_CFG2_LANE0),
    .TX_CFG2_LANE1 (TX_CFG2_LANE1),
    .TX_CFG2_LANE2 (TX_CFG2_LANE2),
    .TX_CFG2_LANE3 (TX_CFG2_LANE3),
    .TX_CLK_SEL0_LANE0 (TX_CLK_SEL0_LANE0),
    .TX_CLK_SEL0_LANE1 (TX_CLK_SEL0_LANE1),
    .TX_CLK_SEL0_LANE2 (TX_CLK_SEL0_LANE2),
    .TX_CLK_SEL0_LANE3 (TX_CLK_SEL0_LANE3),
    .TX_CLK_SEL1_LANE0 (TX_CLK_SEL1_LANE0),
    .TX_CLK_SEL1_LANE1 (TX_CLK_SEL1_LANE1),
    .TX_CLK_SEL1_LANE2 (TX_CLK_SEL1_LANE2),
    .TX_CLK_SEL1_LANE3 (TX_CLK_SEL1_LANE3),
    .TX_DISABLE_LANE0 (TX_DISABLE_LANE0),
    .TX_DISABLE_LANE1 (TX_DISABLE_LANE1),
    .TX_DISABLE_LANE2 (TX_DISABLE_LANE2),
    .TX_DISABLE_LANE3 (TX_DISABLE_LANE3),
    .TX_FABRIC_WIDTH0 (TX_FABRIC_WIDTH0),
    .TX_FABRIC_WIDTH1 (TX_FABRIC_WIDTH1),
    .TX_FABRIC_WIDTH2 (TX_FABRIC_WIDTH2),
    .TX_FABRIC_WIDTH3 (TX_FABRIC_WIDTH3),
    .TX_P0P0S_CTRL (TX_P0P0S_CTRL),
    .TX_P1P2_CTRL (TX_P1P2_CTRL),
    .TX_PREEMPH_LANE0 (TX_PREEMPH_LANE0),
    .TX_PREEMPH_LANE1 (TX_PREEMPH_LANE1),
    .TX_PREEMPH_LANE2 (TX_PREEMPH_LANE2),
    .TX_PREEMPH_LANE3 (TX_PREEMPH_LANE3),
    .TX_PWR_RATE_OVRD_LANE0 (TX_PWR_RATE_OVRD_LANE0),
    .TX_PWR_RATE_OVRD_LANE1 (TX_PWR_RATE_OVRD_LANE1),
    .TX_PWR_RATE_OVRD_LANE2 (TX_PWR_RATE_OVRD_LANE2),
    .TX_PWR_RATE_OVRD_LANE3 (TX_PWR_RATE_OVRD_LANE3))

    B_GTHE1_QUAD_INST (
    .DRDY (delay_DRDY),
    .DRPDO (delay_DRPDO),
    .GTHINITDONE (delay_GTHINITDONE),
    .MGMTPCSRDACK (delay_MGMTPCSRDACK),
    .MGMTPCSRDDATA (delay_MGMTPCSRDDATA),
    .RXCODEERR0 (delay_RXCODEERR0),
    .RXCODEERR1 (delay_RXCODEERR1),
    .RXCODEERR2 (delay_RXCODEERR2),
    .RXCODEERR3 (delay_RXCODEERR3),
    .RXCTRL0 (delay_RXCTRL0),
    .RXCTRL1 (delay_RXCTRL1),
    .RXCTRL2 (delay_RXCTRL2),
    .RXCTRL3 (delay_RXCTRL3),
    .RXCTRLACK0 (delay_RXCTRLACK0),
    .RXCTRLACK1 (delay_RXCTRLACK1),
    .RXCTRLACK2 (delay_RXCTRLACK2),
    .RXCTRLACK3 (delay_RXCTRLACK3),
    .RXDATA0 (delay_RXDATA0),
    .RXDATA1 (delay_RXDATA1),
    .RXDATA2 (delay_RXDATA2),
    .RXDATA3 (delay_RXDATA3),
    .RXDATATAP0 (delay_RXDATATAP0),
    .RXDATATAP1 (delay_RXDATATAP1),
    .RXDATATAP2 (delay_RXDATATAP2),
    .RXDATATAP3 (delay_RXDATATAP3),
    .RXDISPERR0 (delay_RXDISPERR0),
    .RXDISPERR1 (delay_RXDISPERR1),
    .RXDISPERR2 (delay_RXDISPERR2),
    .RXDISPERR3 (delay_RXDISPERR3),
    .RXPCSCLKSMPL0 (delay_RXPCSCLKSMPL0),
    .RXPCSCLKSMPL1 (delay_RXPCSCLKSMPL1),
    .RXPCSCLKSMPL2 (delay_RXPCSCLKSMPL2),
    .RXPCSCLKSMPL3 (delay_RXPCSCLKSMPL3),
    .RXUSERCLKOUT0 (delay_RXUSERCLKOUT0),
    .RXUSERCLKOUT1 (delay_RXUSERCLKOUT1),
    .RXUSERCLKOUT2 (delay_RXUSERCLKOUT2),
    .RXUSERCLKOUT3 (delay_RXUSERCLKOUT3),
    .RXVALID0 (delay_RXVALID0),
    .RXVALID1 (delay_RXVALID1),
    .RXVALID2 (delay_RXVALID2),
    .RXVALID3 (delay_RXVALID3),
    .TSTPATH (delay_TSTPATH),
    .TSTREFCLKFAB (delay_TSTREFCLKFAB),
    .TSTREFCLKOUT (delay_TSTREFCLKOUT),
    .TXCTRLACK0 (delay_TXCTRLACK0),
    .TXCTRLACK1 (delay_TXCTRLACK1),
    .TXCTRLACK2 (delay_TXCTRLACK2),
    .TXCTRLACK3 (delay_TXCTRLACK3),
    .TXDATATAP10 (delay_TXDATATAP10),
    .TXDATATAP11 (delay_TXDATATAP11),
    .TXDATATAP12 (delay_TXDATATAP12),
    .TXDATATAP13 (delay_TXDATATAP13),
    .TXDATATAP20 (delay_TXDATATAP20),
    .TXDATATAP21 (delay_TXDATATAP21),
    .TXDATATAP22 (delay_TXDATATAP22),
    .TXDATATAP23 (delay_TXDATATAP23),
    .TXN0 (delay_TXN0),
    .TXN1 (delay_TXN1),
    .TXN2 (delay_TXN2),
    .TXN3 (delay_TXN3),
    .TXP0 (delay_TXP0),
    .TXP1 (delay_TXP1),
    .TXP2 (delay_TXP2),
    .TXP3 (delay_TXP3),
    .TXPCSCLKSMPL0 (delay_TXPCSCLKSMPL0),
    .TXPCSCLKSMPL1 (delay_TXPCSCLKSMPL1),
    .TXPCSCLKSMPL2 (delay_TXPCSCLKSMPL2),
    .TXPCSCLKSMPL3 (delay_TXPCSCLKSMPL3),
    .TXUSERCLKOUT0 (delay_TXUSERCLKOUT0),
    .TXUSERCLKOUT1 (delay_TXUSERCLKOUT1),
    .TXUSERCLKOUT2 (delay_TXUSERCLKOUT2),
    .TXUSERCLKOUT3 (delay_TXUSERCLKOUT3),
    .DADDR (delay_DADDR),
    .DCLK (delay_DCLK),
    .DEN (delay_DEN),
    .DFETRAINCTRL0 (delay_DFETRAINCTRL0),
    .DFETRAINCTRL1 (delay_DFETRAINCTRL1),
    .DFETRAINCTRL2 (delay_DFETRAINCTRL2),
    .DFETRAINCTRL3 (delay_DFETRAINCTRL3),
    .DI (delay_DI),
    .DISABLEDRP (delay_DISABLEDRP),
    .DWE (delay_DWE),
    .GTHINIT (delay_GTHINIT),
    .GTHRESET (delay_GTHRESET),
    .GTHX2LANE01 (delay_GTHX2LANE01),
    .GTHX2LANE23 (delay_GTHX2LANE23),
    .GTHX4LANE (delay_GTHX4LANE),
    .MGMTPCSLANESEL (delay_MGMTPCSLANESEL),
    .MGMTPCSMMDADDR (delay_MGMTPCSMMDADDR),
    .MGMTPCSREGADDR (delay_MGMTPCSREGADDR),
    .MGMTPCSREGRD (delay_MGMTPCSREGRD),
    .MGMTPCSREGWR (delay_MGMTPCSREGWR),
    .MGMTPCSWRDATA (delay_MGMTPCSWRDATA),
    .PLLPCSCLKDIV (delay_PLLPCSCLKDIV),
    .PLLREFCLKSEL (delay_PLLREFCLKSEL),
    .POWERDOWN0 (delay_POWERDOWN0),
    .POWERDOWN1 (delay_POWERDOWN1),
    .POWERDOWN2 (delay_POWERDOWN2),
    .POWERDOWN3 (delay_POWERDOWN3),
    .REFCLK (delay_REFCLK),
    .RXBUFRESET0 (delay_RXBUFRESET0),
    .RXBUFRESET1 (delay_RXBUFRESET1),
    .RXBUFRESET2 (delay_RXBUFRESET2),
    .RXBUFRESET3 (delay_RXBUFRESET3),
    .RXENCOMMADET0 (delay_RXENCOMMADET0),
    .RXENCOMMADET1 (delay_RXENCOMMADET1),
    .RXENCOMMADET2 (delay_RXENCOMMADET2),
    .RXENCOMMADET3 (delay_RXENCOMMADET3),
    .RXN0 (delay_RXN0),
    .RXN1 (delay_RXN1),
    .RXN2 (delay_RXN2),
    .RXN3 (delay_RXN3),
    .RXP0 (delay_RXP0),
    .RXP1 (delay_RXP1),
    .RXP2 (delay_RXP2),
    .RXP3 (delay_RXP3),
    .RXPOLARITY0 (delay_RXPOLARITY0),
    .RXPOLARITY1 (delay_RXPOLARITY1),
    .RXPOLARITY2 (delay_RXPOLARITY2),
    .RXPOLARITY3 (delay_RXPOLARITY3),
    .RXPOWERDOWN0 (delay_RXPOWERDOWN0),
    .RXPOWERDOWN1 (delay_RXPOWERDOWN1),
    .RXPOWERDOWN2 (delay_RXPOWERDOWN2),
    .RXPOWERDOWN3 (delay_RXPOWERDOWN3),
    .RXRATE0 (delay_RXRATE0),
    .RXRATE1 (delay_RXRATE1),
    .RXRATE2 (delay_RXRATE2),
    .RXRATE3 (delay_RXRATE3),
    .RXSLIP0 (delay_RXSLIP0),
    .RXSLIP1 (delay_RXSLIP1),
    .RXSLIP2 (delay_RXSLIP2),
    .RXSLIP3 (delay_RXSLIP3),
    .RXUSERCLKIN0 (delay_RXUSERCLKIN0),
    .RXUSERCLKIN1 (delay_RXUSERCLKIN1),
    .RXUSERCLKIN2 (delay_RXUSERCLKIN2),
    .RXUSERCLKIN3 (delay_RXUSERCLKIN3),
    .SAMPLERATE0 (delay_SAMPLERATE0),
    .SAMPLERATE1 (delay_SAMPLERATE1),
    .SAMPLERATE2 (delay_SAMPLERATE2),
    .SAMPLERATE3 (delay_SAMPLERATE3),
    .TXBUFRESET0 (delay_TXBUFRESET0),
    .TXBUFRESET1 (delay_TXBUFRESET1),
    .TXBUFRESET2 (delay_TXBUFRESET2),
    .TXBUFRESET3 (delay_TXBUFRESET3),
    .TXCTRL0 (delay_TXCTRL0),
    .TXCTRL1 (delay_TXCTRL1),
    .TXCTRL2 (delay_TXCTRL2),
    .TXCTRL3 (delay_TXCTRL3),
    .TXDATA0 (delay_TXDATA0),
    .TXDATA1 (delay_TXDATA1),
    .TXDATA2 (delay_TXDATA2),
    .TXDATA3 (delay_TXDATA3),
    .TXDATAMSB0 (delay_TXDATAMSB0),
    .TXDATAMSB1 (delay_TXDATAMSB1),
    .TXDATAMSB2 (delay_TXDATAMSB2),
    .TXDATAMSB3 (delay_TXDATAMSB3),
    .TXDEEMPH0 (delay_TXDEEMPH0),
    .TXDEEMPH1 (delay_TXDEEMPH1),
    .TXDEEMPH2 (delay_TXDEEMPH2),
    .TXDEEMPH3 (delay_TXDEEMPH3),
    .TXMARGIN0 (delay_TXMARGIN0),
    .TXMARGIN1 (delay_TXMARGIN1),
    .TXMARGIN2 (delay_TXMARGIN2),
    .TXMARGIN3 (delay_TXMARGIN3),
    .TXPOWERDOWN0 (delay_TXPOWERDOWN0),
    .TXPOWERDOWN1 (delay_TXPOWERDOWN1),
    .TXPOWERDOWN2 (delay_TXPOWERDOWN2),
    .TXPOWERDOWN3 (delay_TXPOWERDOWN3),
    .TXRATE0 (delay_TXRATE0),
    .TXRATE1 (delay_TXRATE1),
    .TXRATE2 (delay_TXRATE2),
    .TXRATE3 (delay_TXRATE3),
    .TXUSERCLKIN0 (delay_TXUSERCLKIN0),
    .TXUSERCLKIN1 (delay_TXUSERCLKIN1),
    .TXUSERCLKIN2 (delay_TXUSERCLKIN2),
    .TXUSERCLKIN3 (delay_TXUSERCLKIN3),
    .GSR(GSR)
  );

  specify
    ( DCLK => DRDY) = (100, 100);
    ( DCLK => DRPDO[0]) = (100, 100);
    ( DCLK => DRPDO[10]) = (100, 100);
    ( DCLK => DRPDO[11]) = (100, 100);
    ( DCLK => DRPDO[12]) = (100, 100);
    ( DCLK => DRPDO[13]) = (100, 100);
    ( DCLK => DRPDO[14]) = (100, 100);
    ( DCLK => DRPDO[15]) = (100, 100);
    ( DCLK => DRPDO[1]) = (100, 100);
    ( DCLK => DRPDO[2]) = (100, 100);
    ( DCLK => DRPDO[3]) = (100, 100);
    ( DCLK => DRPDO[4]) = (100, 100);
    ( DCLK => DRPDO[5]) = (100, 100);
    ( DCLK => DRPDO[6]) = (100, 100);
    ( DCLK => DRPDO[7]) = (100, 100);
    ( DCLK => DRPDO[8]) = (100, 100);
    ( DCLK => DRPDO[9]) = (100, 100);
    ( DCLK => GTHINITDONE) = (100, 100);
    ( DCLK => MGMTPCSRDACK) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[0]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[10]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[11]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[12]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[13]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[14]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[15]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[1]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[2]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[3]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[4]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[5]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[6]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[7]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[8]) = (100, 100);
    ( DCLK => MGMTPCSRDDATA[9]) = (100, 100);
    ( REFCLK => TSTREFCLKFAB) = (100, 100);
    ( REFCLK => TSTREFCLKOUT) = (100, 100);
    ( RXUSERCLKIN0 => RXCODEERR0[0]) = (100, 100);
    ( RXUSERCLKIN0 => RXCODEERR0[1]) = (100, 100);
    ( RXUSERCLKIN0 => RXCODEERR0[2]) = (100, 100);
    ( RXUSERCLKIN0 => RXCODEERR0[3]) = (100, 100);
    ( RXUSERCLKIN0 => RXCODEERR0[4]) = (100, 100);
    ( RXUSERCLKIN0 => RXCODEERR0[5]) = (100, 100);
    ( RXUSERCLKIN0 => RXCODEERR0[6]) = (100, 100);
    ( RXUSERCLKIN0 => RXCODEERR0[7]) = (100, 100);
    ( RXUSERCLKIN0 => RXCTRL0[0]) = (100, 100);
    ( RXUSERCLKIN0 => RXCTRL0[1]) = (100, 100);
    ( RXUSERCLKIN0 => RXCTRL0[2]) = (100, 100);
    ( RXUSERCLKIN0 => RXCTRL0[3]) = (100, 100);
    ( RXUSERCLKIN0 => RXCTRL0[4]) = (100, 100);
    ( RXUSERCLKIN0 => RXCTRL0[5]) = (100, 100);
    ( RXUSERCLKIN0 => RXCTRL0[6]) = (100, 100);
    ( RXUSERCLKIN0 => RXCTRL0[7]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[0]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[10]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[11]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[12]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[13]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[14]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[15]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[16]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[17]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[18]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[19]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[1]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[20]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[21]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[22]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[23]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[24]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[25]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[26]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[27]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[28]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[29]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[2]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[30]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[31]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[32]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[33]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[34]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[35]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[36]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[37]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[38]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[39]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[3]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[40]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[41]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[42]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[43]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[44]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[45]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[46]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[47]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[48]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[49]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[4]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[50]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[51]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[52]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[53]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[54]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[55]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[56]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[57]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[58]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[59]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[5]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[60]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[61]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[62]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[63]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[6]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[7]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[8]) = (100, 100);
    ( RXUSERCLKIN0 => RXDATA0[9]) = (100, 100);
    ( RXUSERCLKIN0 => RXDISPERR0[0]) = (100, 100);
    ( RXUSERCLKIN0 => RXDISPERR0[1]) = (100, 100);
    ( RXUSERCLKIN0 => RXDISPERR0[2]) = (100, 100);
    ( RXUSERCLKIN0 => RXDISPERR0[3]) = (100, 100);
    ( RXUSERCLKIN0 => RXDISPERR0[4]) = (100, 100);
    ( RXUSERCLKIN0 => RXDISPERR0[5]) = (100, 100);
    ( RXUSERCLKIN0 => RXDISPERR0[6]) = (100, 100);
    ( RXUSERCLKIN0 => RXDISPERR0[7]) = (100, 100);
    ( RXUSERCLKIN0 => RXVALID0[0]) = (100, 100);
    ( RXUSERCLKIN0 => RXVALID0[1]) = (100, 100);
    ( RXUSERCLKIN0 => RXVALID0[2]) = (100, 100);
    ( RXUSERCLKIN0 => RXVALID0[3]) = (100, 100);
    ( RXUSERCLKIN0 => RXVALID0[4]) = (100, 100);
    ( RXUSERCLKIN0 => RXVALID0[5]) = (100, 100);
    ( RXUSERCLKIN0 => RXVALID0[6]) = (100, 100);
    ( RXUSERCLKIN0 => RXVALID0[7]) = (100, 100);
    ( RXUSERCLKIN1 => RXCODEERR1[0]) = (100, 100);
    ( RXUSERCLKIN1 => RXCODEERR1[1]) = (100, 100);
    ( RXUSERCLKIN1 => RXCODEERR1[2]) = (100, 100);
    ( RXUSERCLKIN1 => RXCODEERR1[3]) = (100, 100);
    ( RXUSERCLKIN1 => RXCODEERR1[4]) = (100, 100);
    ( RXUSERCLKIN1 => RXCODEERR1[5]) = (100, 100);
    ( RXUSERCLKIN1 => RXCODEERR1[6]) = (100, 100);
    ( RXUSERCLKIN1 => RXCODEERR1[7]) = (100, 100);
    ( RXUSERCLKIN1 => RXCTRL1[0]) = (100, 100);
    ( RXUSERCLKIN1 => RXCTRL1[1]) = (100, 100);
    ( RXUSERCLKIN1 => RXCTRL1[2]) = (100, 100);
    ( RXUSERCLKIN1 => RXCTRL1[3]) = (100, 100);
    ( RXUSERCLKIN1 => RXCTRL1[4]) = (100, 100);
    ( RXUSERCLKIN1 => RXCTRL1[5]) = (100, 100);
    ( RXUSERCLKIN1 => RXCTRL1[6]) = (100, 100);
    ( RXUSERCLKIN1 => RXCTRL1[7]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[0]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[10]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[11]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[12]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[13]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[14]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[15]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[16]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[17]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[18]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[19]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[1]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[20]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[21]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[22]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[23]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[24]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[25]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[26]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[27]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[28]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[29]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[2]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[30]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[31]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[32]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[33]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[34]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[35]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[36]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[37]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[38]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[39]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[3]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[40]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[41]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[42]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[43]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[44]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[45]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[46]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[47]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[48]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[49]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[4]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[50]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[51]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[52]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[53]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[54]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[55]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[56]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[57]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[58]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[59]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[5]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[60]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[61]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[62]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[63]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[6]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[7]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[8]) = (100, 100);
    ( RXUSERCLKIN1 => RXDATA1[9]) = (100, 100);
    ( RXUSERCLKIN1 => RXDISPERR1[0]) = (100, 100);
    ( RXUSERCLKIN1 => RXDISPERR1[1]) = (100, 100);
    ( RXUSERCLKIN1 => RXDISPERR1[2]) = (100, 100);
    ( RXUSERCLKIN1 => RXDISPERR1[3]) = (100, 100);
    ( RXUSERCLKIN1 => RXDISPERR1[4]) = (100, 100);
    ( RXUSERCLKIN1 => RXDISPERR1[5]) = (100, 100);
    ( RXUSERCLKIN1 => RXDISPERR1[6]) = (100, 100);
    ( RXUSERCLKIN1 => RXDISPERR1[7]) = (100, 100);
    ( RXUSERCLKIN1 => RXVALID1[0]) = (100, 100);
    ( RXUSERCLKIN1 => RXVALID1[1]) = (100, 100);
    ( RXUSERCLKIN1 => RXVALID1[2]) = (100, 100);
    ( RXUSERCLKIN1 => RXVALID1[3]) = (100, 100);
    ( RXUSERCLKIN1 => RXVALID1[4]) = (100, 100);
    ( RXUSERCLKIN1 => RXVALID1[5]) = (100, 100);
    ( RXUSERCLKIN1 => RXVALID1[6]) = (100, 100);
    ( RXUSERCLKIN1 => RXVALID1[7]) = (100, 100);
    ( RXUSERCLKIN2 => RXCODEERR2[0]) = (100, 100);
    ( RXUSERCLKIN2 => RXCODEERR2[1]) = (100, 100);
    ( RXUSERCLKIN2 => RXCODEERR2[2]) = (100, 100);
    ( RXUSERCLKIN2 => RXCODEERR2[3]) = (100, 100);
    ( RXUSERCLKIN2 => RXCODEERR2[4]) = (100, 100);
    ( RXUSERCLKIN2 => RXCODEERR2[5]) = (100, 100);
    ( RXUSERCLKIN2 => RXCODEERR2[6]) = (100, 100);
    ( RXUSERCLKIN2 => RXCODEERR2[7]) = (100, 100);
    ( RXUSERCLKIN2 => RXCTRL2[0]) = (100, 100);
    ( RXUSERCLKIN2 => RXCTRL2[1]) = (100, 100);
    ( RXUSERCLKIN2 => RXCTRL2[2]) = (100, 100);
    ( RXUSERCLKIN2 => RXCTRL2[3]) = (100, 100);
    ( RXUSERCLKIN2 => RXCTRL2[4]) = (100, 100);
    ( RXUSERCLKIN2 => RXCTRL2[5]) = (100, 100);
    ( RXUSERCLKIN2 => RXCTRL2[6]) = (100, 100);
    ( RXUSERCLKIN2 => RXCTRL2[7]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[0]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[10]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[11]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[12]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[13]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[14]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[15]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[16]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[17]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[18]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[19]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[1]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[20]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[21]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[22]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[23]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[24]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[25]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[26]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[27]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[28]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[29]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[2]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[30]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[31]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[32]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[33]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[34]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[35]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[36]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[37]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[38]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[39]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[3]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[40]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[41]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[42]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[43]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[44]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[45]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[46]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[47]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[48]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[49]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[4]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[50]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[51]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[52]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[53]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[54]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[55]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[56]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[57]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[58]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[59]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[5]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[60]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[61]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[62]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[63]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[6]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[7]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[8]) = (100, 100);
    ( RXUSERCLKIN2 => RXDATA2[9]) = (100, 100);
    ( RXUSERCLKIN2 => RXDISPERR2[0]) = (100, 100);
    ( RXUSERCLKIN2 => RXDISPERR2[1]) = (100, 100);
    ( RXUSERCLKIN2 => RXDISPERR2[2]) = (100, 100);
    ( RXUSERCLKIN2 => RXDISPERR2[3]) = (100, 100);
    ( RXUSERCLKIN2 => RXDISPERR2[4]) = (100, 100);
    ( RXUSERCLKIN2 => RXDISPERR2[5]) = (100, 100);
    ( RXUSERCLKIN2 => RXDISPERR2[6]) = (100, 100);
    ( RXUSERCLKIN2 => RXDISPERR2[7]) = (100, 100);
    ( RXUSERCLKIN2 => RXVALID2[0]) = (100, 100);
    ( RXUSERCLKIN2 => RXVALID2[1]) = (100, 100);
    ( RXUSERCLKIN2 => RXVALID2[2]) = (100, 100);
    ( RXUSERCLKIN2 => RXVALID2[3]) = (100, 100);
    ( RXUSERCLKIN2 => RXVALID2[4]) = (100, 100);
    ( RXUSERCLKIN2 => RXVALID2[5]) = (100, 100);
    ( RXUSERCLKIN2 => RXVALID2[6]) = (100, 100);
    ( RXUSERCLKIN2 => RXVALID2[7]) = (100, 100);
    ( RXUSERCLKIN3 => RXCODEERR3[0]) = (100, 100);
    ( RXUSERCLKIN3 => RXCODEERR3[1]) = (100, 100);
    ( RXUSERCLKIN3 => RXCODEERR3[2]) = (100, 100);
    ( RXUSERCLKIN3 => RXCODEERR3[3]) = (100, 100);
    ( RXUSERCLKIN3 => RXCODEERR3[4]) = (100, 100);
    ( RXUSERCLKIN3 => RXCODEERR3[5]) = (100, 100);
    ( RXUSERCLKIN3 => RXCODEERR3[6]) = (100, 100);
    ( RXUSERCLKIN3 => RXCODEERR3[7]) = (100, 100);
    ( RXUSERCLKIN3 => RXCTRL3[0]) = (100, 100);
    ( RXUSERCLKIN3 => RXCTRL3[1]) = (100, 100);
    ( RXUSERCLKIN3 => RXCTRL3[2]) = (100, 100);
    ( RXUSERCLKIN3 => RXCTRL3[3]) = (100, 100);
    ( RXUSERCLKIN3 => RXCTRL3[4]) = (100, 100);
    ( RXUSERCLKIN3 => RXCTRL3[5]) = (100, 100);
    ( RXUSERCLKIN3 => RXCTRL3[6]) = (100, 100);
    ( RXUSERCLKIN3 => RXCTRL3[7]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[0]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[10]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[11]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[12]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[13]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[14]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[15]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[16]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[17]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[18]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[19]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[1]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[20]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[21]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[22]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[23]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[24]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[25]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[26]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[27]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[28]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[29]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[2]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[30]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[31]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[32]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[33]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[34]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[35]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[36]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[37]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[38]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[39]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[3]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[40]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[41]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[42]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[43]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[44]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[45]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[46]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[47]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[48]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[49]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[4]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[50]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[51]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[52]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[53]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[54]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[55]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[56]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[57]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[58]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[59]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[5]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[60]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[61]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[62]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[63]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[6]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[7]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[8]) = (100, 100);
    ( RXUSERCLKIN3 => RXDATA3[9]) = (100, 100);
    ( RXUSERCLKIN3 => RXDISPERR3[0]) = (100, 100);
    ( RXUSERCLKIN3 => RXDISPERR3[1]) = (100, 100);
    ( RXUSERCLKIN3 => RXDISPERR3[2]) = (100, 100);
    ( RXUSERCLKIN3 => RXDISPERR3[3]) = (100, 100);
    ( RXUSERCLKIN3 => RXDISPERR3[4]) = (100, 100);
    ( RXUSERCLKIN3 => RXDISPERR3[5]) = (100, 100);
    ( RXUSERCLKIN3 => RXDISPERR3[6]) = (100, 100);
    ( RXUSERCLKIN3 => RXDISPERR3[7]) = (100, 100);
    ( RXUSERCLKIN3 => RXVALID3[0]) = (100, 100);
    ( RXUSERCLKIN3 => RXVALID3[1]) = (100, 100);
    ( RXUSERCLKIN3 => RXVALID3[2]) = (100, 100);
    ( RXUSERCLKIN3 => RXVALID3[3]) = (100, 100);
    ( RXUSERCLKIN3 => RXVALID3[4]) = (100, 100);
    ( RXUSERCLKIN3 => RXVALID3[5]) = (100, 100);
    ( RXUSERCLKIN3 => RXVALID3[6]) = (100, 100);
    ( RXUSERCLKIN3 => RXVALID3[7]) = (100, 100);
    ( TXUSERCLKIN0 => RXCTRLACK0) = (100, 100);
    ( TXUSERCLKIN0 => TXCTRLACK0) = (100, 100);
    ( TXUSERCLKIN1 => RXCTRLACK1) = (100, 100);
    ( TXUSERCLKIN1 => TXCTRLACK1) = (100, 100);
    ( TXUSERCLKIN2 => RXCTRLACK2) = (100, 100);
    ( TXUSERCLKIN2 => TXCTRLACK2) = (100, 100);
    ( TXUSERCLKIN3 => RXCTRLACK3) = (100, 100);
    ( TXUSERCLKIN3 => TXCTRLACK3) = (100, 100);

    specparam PATHPULSE$ = 0;
  endspecify
endmodule
