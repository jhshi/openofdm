//////////////////////////////////////////////////////
//  Copyright (c) 2010 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : Xilinx Functional Simulation Library Component
//  /  /                       : Gigabit Transceiver
// /__/   /\       Filename    : GTXE1.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:		1.0
//  10/24/08 - CR495047 - Initial version
//  11/04/08 - CR495046 - replace case with if for parameter type integer - writer enhancement
//  11/05/08 - CR494078 - SIM_VERSION real to string
//  11/05/08 - CR495047 - Add DRC checks to unisim wrapper
//  11/19/08 - CR497301 - YML update for parameter default value
//  01/27/09 - CR505569 - parameter checks if to case statement - writer bug
//  02/11/09 - CR507680 - GTXE1 Attribute default changes
//  03/11/09 - CR511750 - Update attribute value to upper case
//  03/24/09 - CR514739 - PMA attribute default update
//  05/05/09 - CR520565 - Update specify block from 100ps to 0ps
//  05/13/09 - CR521563 - Attribute POWER_SAVE default change
//  07/28/09 - CR528324 - Default Attribute YML updates
//  09/21/09 - CR532191 - YML update to add RXPRBSERR_LOOPBACK, SIM_VERSION updated to "2.0", add input RXDLYALIGNMONENB/TXDLYALIGNMONENB
//  03/04/10 - CR552249 - Attribute updates - YML & RTL updated
//  03/16/10 - CR552250 - Additional DRC checks added
//  05/11/10 - CR552250 - DRC check bug fixed
/////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module GTXE1 (
  COMFINISH,
  COMINITDET,
  COMSASDET,
  COMWAKEDET,
  DFECLKDLYADJMON,
  DFEEYEDACMON,
  DFESENSCAL,
  DFETAP1MONITOR,
  DFETAP2MONITOR,
  DFETAP3MONITOR,
  DFETAP4MONITOR,
  DRDY,
  DRPDO,
  MGTREFCLKFAB,
  PHYSTATUS,
  RXBUFSTATUS,
  RXBYTEISALIGNED,
  RXBYTEREALIGN,
  RXCHANBONDSEQ,
  RXCHANISALIGNED,
  RXCHANREALIGN,
  RXCHARISCOMMA,
  RXCHARISK,
  RXCHBONDO,
  RXCLKCORCNT,
  RXCOMMADET,
  RXDATA,
  RXDATAVALID,
  RXDISPERR,
  RXDLYALIGNMONITOR,
  RXELECIDLE,
  RXHEADER,
  RXHEADERVALID,
  RXLOSSOFSYNC,
  RXNOTINTABLE,
  RXOVERSAMPLEERR,
  RXPLLLKDET,
  RXPRBSERR,
  RXRATEDONE,
  RXRECCLK,
  RXRECCLKPCS,
  RXRESETDONE,
  RXRUNDISP,
  RXSTARTOFSEQ,
  RXSTATUS,
  RXVALID,
  TSTOUT,
  TXBUFSTATUS,
  TXDLYALIGNMONITOR,
  TXGEARBOXREADY,
  TXKERR,
  TXN,
  TXOUTCLK,
  TXOUTCLKPCS,
  TXP,
  TXPLLLKDET,
  TXRATEDONE,
  TXRESETDONE,
  TXRUNDISP,
  DADDR,
  DCLK,
  DEN,
  DFECLKDLYADJ,
  DFEDLYOVRD,
  DFETAP1,
  DFETAP2,
  DFETAP3,
  DFETAP4,
  DFETAPOVRD,
  DI,
  DWE,
  GATERXELECIDLE,
  GREFCLKRX,
  GREFCLKTX,
  GTXRXRESET,
  GTXTEST,
  GTXTXRESET,
  IGNORESIGDET,
  LOOPBACK,
  MGTREFCLKRX,
  MGTREFCLKTX,
  NORTHREFCLKRX,
  NORTHREFCLKTX,
  PERFCLKRX,
  PERFCLKTX,
  PLLRXRESET,
  PLLTXRESET,
  PRBSCNTRESET,
  RXBUFRESET,
  RXCDRRESET,
  RXCHBONDI,
  RXCHBONDLEVEL,
  RXCHBONDMASTER,
  RXCHBONDSLAVE,
  RXCOMMADETUSE,
  RXDEC8B10BUSE,
  RXDLYALIGNDISABLE,
  RXDLYALIGNMONENB,	      
  RXDLYALIGNOVERRIDE,
  RXDLYALIGNRESET,
  RXDLYALIGNSWPPRECURB,
  RXDLYALIGNUPDSW,
  RXENCHANSYNC,
  RXENMCOMMAALIGN,
  RXENPCOMMAALIGN,
  RXENPMAPHASEALIGN,
  RXENPRBSTST,
  RXENSAMPLEALIGN,
  RXEQMIX,
  RXGEARBOXSLIP,
  RXN,
  RXP,
  RXPLLLKDETEN,
  RXPLLPOWERDOWN,
  RXPLLREFSELDY,
  RXPMASETPHASE,
  RXPOLARITY,
  RXPOWERDOWN,
  RXRATE,
  RXRESET,
  RXSLIDE,
  RXUSRCLK,
  RXUSRCLK2,
  SOUTHREFCLKRX,
  SOUTHREFCLKTX,
  TSTCLK0,
  TSTCLK1,
  TSTIN,
  TXBUFDIFFCTRL,
  TXBYPASS8B10B,
  TXCHARDISPMODE,
  TXCHARDISPVAL,
  TXCHARISK,
  TXCOMINIT,
  TXCOMSAS,
  TXCOMWAKE,
  TXDATA,
  TXDEEMPH,
  TXDETECTRX,
  TXDIFFCTRL,
  TXDLYALIGNDISABLE,
  TXDLYALIGNMONENB,    
  TXDLYALIGNOVERRIDE,
  TXDLYALIGNRESET,
  TXDLYALIGNUPDSW,
  TXELECIDLE,
  TXENC8B10BUSE,
  TXENPMAPHASEALIGN,
  TXENPRBSTST,
  TXHEADER,
  TXINHIBIT,
  TXMARGIN,
  TXPDOWNASYNCH,
  TXPLLLKDETEN,
  TXPLLPOWERDOWN,
  TXPLLREFSELDY,
  TXPMASETPHASE,
  TXPOLARITY,
  TXPOSTEMPHASIS,
  TXPOWERDOWN,
  TXPRBSFORCEERR,
  TXPREEMPHASIS,
  TXRATE,
  TXRESET,
  TXSEQUENCE,
  TXSTARTSEQ,
  TXSWING,
  TXUSRCLK,
  TXUSRCLK2,
  USRCODEERR
);

  parameter AC_CAP_DIS = "TRUE";
  parameter integer ALIGN_COMMA_WORD = 1;
  parameter [1:0] BGTEST_CFG = 2'b00;
  parameter [16:0] BIAS_CFG = 17'h00000;
  parameter [4:0] CDR_PH_ADJ_TIME = 5'b10100;
  parameter integer CHAN_BOND_1_MAX_SKEW = 7;
  parameter integer CHAN_BOND_2_MAX_SKEW = 1;
  parameter CHAN_BOND_KEEP_ALIGN = "FALSE";
  parameter [9:0] CHAN_BOND_SEQ_1_1 = 10'b0101111100;
  parameter [9:0] CHAN_BOND_SEQ_1_2 = 10'b0001001010;
  parameter [9:0] CHAN_BOND_SEQ_1_3 = 10'b0001001010;
  parameter [9:0] CHAN_BOND_SEQ_1_4 = 10'b0110111100;
  parameter [3:0] CHAN_BOND_SEQ_1_ENABLE = 4'b1111;
  parameter [9:0] CHAN_BOND_SEQ_2_1 = 10'b0100111100;
  parameter [9:0] CHAN_BOND_SEQ_2_2 = 10'b0100111100;
  parameter [9:0] CHAN_BOND_SEQ_2_3 = 10'b0110111100;
  parameter [9:0] CHAN_BOND_SEQ_2_4 = 10'b0100111100;
  parameter [4:0] CHAN_BOND_SEQ_2_CFG = 5'b00000;
  parameter [3:0] CHAN_BOND_SEQ_2_ENABLE = 4'b1111;
  parameter CHAN_BOND_SEQ_2_USE = "FALSE";
  parameter integer CHAN_BOND_SEQ_LEN = 1;
  parameter CLK_CORRECT_USE = "TRUE";
  parameter integer CLK_COR_ADJ_LEN = 1;
  parameter integer CLK_COR_DET_LEN = 1;
  parameter CLK_COR_INSERT_IDLE_FLAG = "FALSE";
  parameter CLK_COR_KEEP_IDLE = "FALSE";
  parameter integer CLK_COR_MAX_LAT = 20;
  parameter integer CLK_COR_MIN_LAT = 18;
  parameter CLK_COR_PRECEDENCE = "TRUE";
  parameter integer CLK_COR_REPEAT_WAIT = 0;
  parameter [9:0] CLK_COR_SEQ_1_1 = 10'b0100011100;
  parameter [9:0] CLK_COR_SEQ_1_2 = 10'b0000000000;
  parameter [9:0] CLK_COR_SEQ_1_3 = 10'b0000000000;
  parameter [9:0] CLK_COR_SEQ_1_4 = 10'b0000000000;
  parameter [3:0] CLK_COR_SEQ_1_ENABLE = 4'b1111;
  parameter [9:0] CLK_COR_SEQ_2_1 = 10'b0000000000;
  parameter [9:0] CLK_COR_SEQ_2_2 = 10'b0000000000;
  parameter [9:0] CLK_COR_SEQ_2_3 = 10'b0000000000;
  parameter [9:0] CLK_COR_SEQ_2_4 = 10'b0000000000;
  parameter [3:0] CLK_COR_SEQ_2_ENABLE = 4'b1111;
  parameter CLK_COR_SEQ_2_USE = "FALSE";
  parameter [1:0] CM_TRIM = 2'b01;
  parameter [9:0] COMMA_10B_ENABLE = 10'b1111111111;
  parameter COMMA_DOUBLE = "FALSE";
  parameter [3:0] COM_BURST_VAL = 4'b1111;
  parameter DEC_MCOMMA_DETECT = "TRUE";
  parameter DEC_PCOMMA_DETECT = "TRUE";
  parameter DEC_VALID_COMMA_ONLY = "TRUE";
  parameter [4:0] DFE_CAL_TIME = 5'b01100;
  parameter [7:0] DFE_CFG = 8'b00011011;
  parameter [2:0] GEARBOX_ENDEC = 3'b000;
  parameter GEN_RXUSRCLK = "TRUE";
  parameter GEN_TXUSRCLK = "TRUE";
  parameter GTX_CFG_PWRUP = "TRUE";
  parameter [9:0] MCOMMA_10B_VALUE = 10'b1010000011;
  parameter MCOMMA_DETECT = "TRUE";
  parameter [2:0] OOBDETECT_THRESHOLD = 3'b011;
  parameter PCI_EXPRESS_MODE = "FALSE";
  parameter [9:0] PCOMMA_10B_VALUE = 10'b0101111100;
  parameter PCOMMA_DETECT = "TRUE";
  parameter PMA_CAS_CLK_EN = "FALSE";
  parameter [26:0] PMA_CDR_SCAN = 27'h640404C;
  parameter [75:0] PMA_CFG = 76'h0040000040000000003;
  parameter [6:0] PMA_RXSYNC_CFG = 7'h00;
  parameter [24:0] PMA_RX_CFG = 25'h05CE048;
  parameter [19:0] PMA_TX_CFG = 20'h00082;
  parameter [9:0] POWER_SAVE = 10'b0000110100;
  parameter RCV_TERM_GND = "FALSE";
  parameter RCV_TERM_VTTRX = "TRUE";
  parameter RXGEARBOX_USE = "FALSE";
  parameter [23:0] RXPLL_COM_CFG = 24'h21680A;
  parameter [7:0] RXPLL_CP_CFG = 8'h00;
  parameter integer RXPLL_DIVSEL45_FB = 5;
  parameter integer RXPLL_DIVSEL_FB = 2;
  parameter integer RXPLL_DIVSEL_OUT = 1;
  parameter integer RXPLL_DIVSEL_REF = 1;
  parameter [2:0] RXPLL_LKDET_CFG = 3'b111;
  parameter [0:0] RXPRBSERR_LOOPBACK = 1'b0;
  parameter RXRECCLK_CTRL = "RXRECCLKPCS";
  parameter [9:0] RXRECCLK_DLY = 10'b0000000000;
  parameter [15:0] RXUSRCLK_DLY = 16'h0000;
  parameter RX_BUFFER_USE = "TRUE";
  parameter integer RX_CLK25_DIVIDER = 6;
  parameter integer RX_DATA_WIDTH = 20;
  parameter RX_DECODE_SEQ_MATCH = "TRUE";
  parameter [3:0] RX_DLYALIGN_CTRINC = 4'b0100;
  parameter [4:0] RX_DLYALIGN_EDGESET = 5'b00110;
  parameter [3:0] RX_DLYALIGN_LPFINC = 4'b0111;
  parameter [2:0] RX_DLYALIGN_MONSEL = 3'b000;
  parameter [7:0] RX_DLYALIGN_OVRDSETTING = 8'b00000000;
  parameter RX_EN_IDLE_HOLD_CDR = "FALSE";
  parameter RX_EN_IDLE_HOLD_DFE = "TRUE";
  parameter RX_EN_IDLE_RESET_BUF = "TRUE";
  parameter RX_EN_IDLE_RESET_FR = "TRUE";
  parameter RX_EN_IDLE_RESET_PH = "TRUE";
  parameter RX_EN_MODE_RESET_BUF = "TRUE";
  parameter RX_EN_RATE_RESET_BUF = "TRUE";
  parameter RX_EN_REALIGN_RESET_BUF = "FALSE";
  parameter RX_EN_REALIGN_RESET_BUF2 = "FALSE";
  parameter [7:0] RX_EYE_OFFSET = 8'h4C;
  parameter [1:0] RX_EYE_SCANMODE = 2'b00;
  parameter RX_FIFO_ADDR_MODE = "FULL";
  parameter [3:0] RX_IDLE_HI_CNT = 4'b1000;
  parameter [3:0] RX_IDLE_LO_CNT = 4'b0000;
  parameter RX_LOSS_OF_SYNC_FSM = "FALSE";
  parameter integer RX_LOS_INVALID_INCR = 1;
  parameter integer RX_LOS_THRESHOLD = 4;
  parameter RX_OVERSAMPLE_MODE = "FALSE";
  parameter integer RX_SLIDE_AUTO_WAIT = 5;
  parameter RX_SLIDE_MODE = "OFF";
  parameter RX_XCLK_SEL = "RXREC";
  parameter integer SAS_MAX_COMSAS = 52;
  parameter integer SAS_MIN_COMSAS = 40;
  parameter [2:0] SATA_BURST_VAL = 3'b100;
  parameter [2:0] SATA_IDLE_VAL = 3'b100;
  parameter integer SATA_MAX_BURST = 7;
  parameter integer SATA_MAX_INIT = 22;
  parameter integer SATA_MAX_WAKE = 7;
  parameter integer SATA_MIN_BURST = 4;
  parameter integer SATA_MIN_INIT = 12;
  parameter integer SATA_MIN_WAKE = 4;
  parameter SHOW_REALIGN_COMMA = "TRUE";
  parameter integer SIM_GTXRESET_SPEEDUP = 1;
  parameter SIM_RECEIVER_DETECT_PASS = "TRUE";
  parameter [2:0] SIM_RXREFCLK_SOURCE = 3'b000;
  parameter [2:0] SIM_TXREFCLK_SOURCE = 3'b000;
  parameter SIM_TX_ELEC_IDLE_LEVEL = "X";
  parameter SIM_VERSION = "2.0";
  parameter [4:0] TERMINATION_CTRL = 5'b10100;
  parameter TERMINATION_OVRD = "FALSE";
  parameter [11:0] TRANS_TIME_FROM_P2 = 12'h03C;
  parameter [7:0] TRANS_TIME_NON_P2 = 8'h19;
  parameter [7:0] TRANS_TIME_RATE = 8'h0E;
  parameter [9:0] TRANS_TIME_TO_P2 = 10'h064;
  parameter [31:0] TST_ATTR = 32'h00000000;
  parameter TXDRIVE_LOOPBACK_HIZ = "FALSE";
  parameter TXDRIVE_LOOPBACK_PD = "FALSE";
  parameter TXGEARBOX_USE = "FALSE";
  parameter TXOUTCLK_CTRL = "TXOUTCLKPCS";
  parameter [9:0] TXOUTCLK_DLY = 10'b0000000000;
  parameter [23:0] TXPLL_COM_CFG = 24'h21680A;
  parameter [7:0] TXPLL_CP_CFG = 8'h00;
  parameter integer TXPLL_DIVSEL45_FB = 5;
  parameter integer TXPLL_DIVSEL_FB = 2;
  parameter integer TXPLL_DIVSEL_OUT = 1;
  parameter integer TXPLL_DIVSEL_REF = 1;
  parameter [2:0] TXPLL_LKDET_CFG = 3'b111;
  parameter [1:0] TXPLL_SATA = 2'b00;
  parameter TX_BUFFER_USE = "TRUE";
  parameter [5:0] TX_BYTECLK_CFG = 6'h00;
  parameter integer TX_CLK25_DIVIDER = 6;
  parameter TX_CLK_SOURCE = "RXPLL";
  parameter integer TX_DATA_WIDTH = 20;
  parameter [4:0] TX_DEEMPH_0 = 5'b11010;
  parameter [4:0] TX_DEEMPH_1 = 5'b10000;
  parameter [13:0] TX_DETECT_RX_CFG = 14'h1832;
  parameter [3:0] TX_DLYALIGN_CTRINC = 4'b0100;
  parameter [3:0] TX_DLYALIGN_LPFINC = 4'b0110;
  parameter [2:0] TX_DLYALIGN_MONSEL = 3'b000;
  parameter [7:0] TX_DLYALIGN_OVRDSETTING = 8'b10000000;
  parameter TX_DRIVE_MODE = "DIRECT";
  parameter TX_EN_RATE_RESET_BUF = "TRUE";
  parameter [2:0] TX_IDLE_ASSERT_DELAY = 3'b100;
  parameter [2:0] TX_IDLE_DEASSERT_DELAY = 3'b010;
  parameter [6:0] TX_MARGIN_FULL_0 = 7'b1001110;
  parameter [6:0] TX_MARGIN_FULL_1 = 7'b1001001;
  parameter [6:0] TX_MARGIN_FULL_2 = 7'b1000101;
  parameter [6:0] TX_MARGIN_FULL_3 = 7'b1000010;
  parameter [6:0] TX_MARGIN_FULL_4 = 7'b1000000;
  parameter [6:0] TX_MARGIN_LOW_0 = 7'b1000110;
  parameter [6:0] TX_MARGIN_LOW_1 = 7'b1000100;
  parameter [6:0] TX_MARGIN_LOW_2 = 7'b1000010;
  parameter [6:0] TX_MARGIN_LOW_3 = 7'b1000000;
  parameter [6:0] TX_MARGIN_LOW_4 = 7'b1000000;
  parameter TX_OVERSAMPLE_MODE = "FALSE";
  parameter [0:0] TX_PMADATA_OPT = 1'b0;
  parameter [1:0] TX_TDCC_CFG = 2'b11;
  parameter [5:0] TX_USRCLK_CFG = 6'h00;
  parameter TX_XCLK_SEL = "TXUSR";
  
  localparam in_delay = 0;
  localparam out_delay = 0;
  localparam INCLK_DELAY = 0;
  localparam OUTCLK_DELAY = 0;

  output COMFINISH;
  output COMINITDET;
  output COMSASDET;
  output COMWAKEDET;
  output DRDY;
  output PHYSTATUS;
  output RXBYTEISALIGNED;
  output RXBYTEREALIGN;
  output RXCHANBONDSEQ;
  output RXCHANISALIGNED;
  output RXCHANREALIGN;
  output RXCOMMADET;
  output RXDATAVALID;
  output RXELECIDLE;
  output RXHEADERVALID;
  output RXOVERSAMPLEERR;
  output RXPLLLKDET;
  output RXPRBSERR;
  output RXRATEDONE;
  output RXRECCLK;
  output RXRECCLKPCS;
  output RXRESETDONE;
  output RXSTARTOFSEQ;
  output RXVALID;
  output TXGEARBOXREADY;
  output TXN;
  output TXOUTCLK;
  output TXOUTCLKPCS;
  output TXP;
  output TXPLLLKDET;
  output TXRATEDONE;
  output TXRESETDONE;
  output [15:0] DRPDO;
  output [1:0] MGTREFCLKFAB;
  output [1:0] RXLOSSOFSYNC;
  output [1:0] TXBUFSTATUS;
  output [2:0] DFESENSCAL;
  output [2:0] RXBUFSTATUS;
  output [2:0] RXCLKCORCNT;
  output [2:0] RXHEADER;
  output [2:0] RXSTATUS;
  output [31:0] RXDATA;
  output [3:0] DFETAP3MONITOR;
  output [3:0] DFETAP4MONITOR;
  output [3:0] RXCHARISCOMMA;
  output [3:0] RXCHARISK;
  output [3:0] RXCHBONDO;
  output [3:0] RXDISPERR;
  output [3:0] RXNOTINTABLE;
  output [3:0] RXRUNDISP;
  output [3:0] TXKERR;
  output [3:0] TXRUNDISP;
  output [4:0] DFEEYEDACMON;
  output [4:0] DFETAP1MONITOR;
  output [4:0] DFETAP2MONITOR;
  output [5:0] DFECLKDLYADJMON;
  output [7:0] RXDLYALIGNMONITOR;
  output [7:0] TXDLYALIGNMONITOR;
  output [9:0] TSTOUT;

  input DCLK;
  input DEN;
  input DFEDLYOVRD;
  input DFETAPOVRD;
  input DWE;
  input GATERXELECIDLE;
  input GREFCLKRX;
  input GREFCLKTX;
  input GTXRXRESET;
  input GTXTXRESET;
  input IGNORESIGDET;
  input PERFCLKRX;
  input PERFCLKTX;
  input PLLRXRESET;
  input PLLTXRESET;
  input PRBSCNTRESET;
  input RXBUFRESET;
  input RXCDRRESET;
  input RXCHBONDMASTER;
  input RXCHBONDSLAVE;
  input RXCOMMADETUSE;
  input RXDEC8B10BUSE;
  input RXDLYALIGNDISABLE;
  input RXDLYALIGNMONENB;
  input RXDLYALIGNOVERRIDE;
  input RXDLYALIGNRESET;
  input RXDLYALIGNSWPPRECURB;
  input RXDLYALIGNUPDSW;
  input RXENCHANSYNC;
  input RXENMCOMMAALIGN;
  input RXENPCOMMAALIGN;
  input RXENPMAPHASEALIGN;
  input RXENSAMPLEALIGN;
  input RXGEARBOXSLIP;
  input RXN;
  input RXP;
  input RXPLLLKDETEN;
  input RXPLLPOWERDOWN;
  input RXPMASETPHASE;
  input RXPOLARITY;
  input RXRESET;
  input RXSLIDE;
  input RXUSRCLK2;
  input RXUSRCLK;
  input TSTCLK0;
  input TSTCLK1;
  input TXCOMINIT;
  input TXCOMSAS;
  input TXCOMWAKE;
  input TXDEEMPH;
  input TXDETECTRX;
  input TXDLYALIGNDISABLE;
  input TXDLYALIGNMONENB;
  input TXDLYALIGNOVERRIDE;
  input TXDLYALIGNRESET;
  input TXDLYALIGNUPDSW;
  input TXELECIDLE;
  input TXENC8B10BUSE;
  input TXENPMAPHASEALIGN;
  input TXINHIBIT;
  input TXPDOWNASYNCH;
  input TXPLLLKDETEN;
  input TXPLLPOWERDOWN;
  input TXPMASETPHASE;
  input TXPOLARITY;
  input TXPRBSFORCEERR;
  input TXRESET;
  input TXSTARTSEQ;
  input TXSWING;
  input TXUSRCLK2;
  input TXUSRCLK;
  input USRCODEERR;
  input [12:0] GTXTEST;
  input [15:0] DI;
  input [19:0] TSTIN;
  input [1:0] MGTREFCLKRX;
  input [1:0] MGTREFCLKTX;
  input [1:0] NORTHREFCLKRX;
  input [1:0] NORTHREFCLKTX;
  input [1:0] RXPOWERDOWN;
  input [1:0] RXRATE;
  input [1:0] SOUTHREFCLKRX;
  input [1:0] SOUTHREFCLKTX;
  input [1:0] TXPOWERDOWN;
  input [1:0] TXRATE;
  input [2:0] LOOPBACK;
  input [2:0] RXCHBONDLEVEL;
  input [2:0] RXENPRBSTST;
  input [2:0] RXPLLREFSELDY;
  input [2:0] TXBUFDIFFCTRL;
  input [2:0] TXENPRBSTST;
  input [2:0] TXHEADER;
  input [2:0] TXMARGIN;
  input [2:0] TXPLLREFSELDY;
  input [31:0] TXDATA;
  input [3:0] DFETAP3;
  input [3:0] DFETAP4;
  input [3:0] RXCHBONDI;
  input [3:0] TXBYPASS8B10B;
  input [3:0] TXCHARDISPMODE;
  input [3:0] TXCHARDISPVAL;
  input [3:0] TXCHARISK;
  input [3:0] TXDIFFCTRL;
  input [3:0] TXPREEMPHASIS;
  input [4:0] DFETAP1;
  input [4:0] DFETAP2;
  input [4:0] TXPOSTEMPHASIS;
  input [5:0] DFECLKDLYADJ;
  input [6:0] TXSEQUENCE;
  input [7:0] DADDR;
  input [9:0] RXEQMIX;

  reg AC_CAP_DIS_BINARY;
  reg ALIGN_COMMA_WORD_BINARY;
  reg CHAN_BOND_KEEP_ALIGN_BINARY;
  reg CHAN_BOND_SEQ_2_USE_BINARY;
  reg CLK_CORRECT_USE_BINARY;
  reg CLK_COR_INSERT_IDLE_FLAG_BINARY;
  reg CLK_COR_KEEP_IDLE_BINARY;
  reg CLK_COR_PRECEDENCE_BINARY;
  reg CLK_COR_SEQ_2_USE_BINARY;
  reg COMMA_DOUBLE_BINARY;
  reg DEC_MCOMMA_DETECT_BINARY;
  reg DEC_PCOMMA_DETECT_BINARY;
  reg DEC_VALID_COMMA_ONLY_BINARY;
  reg GEN_RXUSRCLK_BINARY;
  reg GEN_TXUSRCLK_BINARY;
  reg GTX_CFG_PWRUP_BINARY;
  reg MCOMMA_DETECT_BINARY;
  reg PCI_EXPRESS_MODE_BINARY;
  reg PCOMMA_DETECT_BINARY;
  reg PMA_CAS_CLK_EN_BINARY;
  reg RCV_TERM_GND_BINARY;
  reg RCV_TERM_VTTRX_BINARY;
  reg RXGEARBOX_USE_BINARY;
  reg RXPLL_DIVSEL45_FB_BINARY;
  reg RXPRBSERR_LOOPBACK_BINARY;
  reg RX_BUFFER_USE_BINARY;
  reg RX_DECODE_SEQ_MATCH_BINARY;
  reg RX_EN_IDLE_HOLD_CDR_BINARY;
  reg RX_EN_IDLE_HOLD_DFE_BINARY;
  reg RX_EN_IDLE_RESET_BUF_BINARY;
  reg RX_EN_IDLE_RESET_FR_BINARY;
  reg RX_EN_IDLE_RESET_PH_BINARY;
  reg RX_EN_MODE_RESET_BUF_BINARY;
  reg RX_EN_RATE_RESET_BUF_BINARY;
  reg RX_EN_REALIGN_RESET_BUF2_BINARY;
  reg RX_EN_REALIGN_RESET_BUF_BINARY;
  reg RX_FIFO_ADDR_MODE_BINARY;
  reg RX_LOSS_OF_SYNC_FSM_BINARY;
  reg RX_OVERSAMPLE_MODE_BINARY;
  reg RX_XCLK_SEL_BINARY;
  reg SHOW_REALIGN_COMMA_BINARY;
  reg SIM_GTXRESET_SPEEDUP_BINARY;
  reg SIM_RECEIVER_DETECT_PASS_BINARY;
  reg SIM_TX_ELEC_IDLE_LEVEL_BINARY;
  reg SIM_VERSION_BINARY;
  reg TERMINATION_OVRD_BINARY;
  reg TXDRIVE_LOOPBACK_HIZ_BINARY;
  reg TXDRIVE_LOOPBACK_PD_BINARY;
  reg TXGEARBOX_USE_BINARY;
  reg TXPLL_DIVSEL45_FB_BINARY;
  reg TX_BUFFER_USE_BINARY;
  reg TX_CLK_SOURCE_BINARY;
  reg TX_DRIVE_MODE_BINARY;
  reg TX_EN_RATE_RESET_BUF_BINARY;
  reg TX_OVERSAMPLE_MODE_BINARY;
  reg TX_PMADATA_OPT_BINARY;
  reg TX_XCLK_SEL_BINARY;
  reg [1:0] BGTEST_CFG_BINARY;
  reg [1:0] CHAN_BOND_SEQ_LEN_BINARY;
  reg [1:0] CLK_COR_ADJ_LEN_BINARY;
  reg [1:0] CLK_COR_DET_LEN_BINARY;
  reg [1:0] CM_TRIM_BINARY;
  reg [1:0] RXPLL_DIVSEL_OUT_BINARY;
  reg [1:0] RX_EYE_SCANMODE_BINARY;
  reg [1:0] RX_SLIDE_MODE_BINARY;
  reg [1:0] TXPLL_DIVSEL_OUT_BINARY;
  reg [1:0] TXPLL_SATA_BINARY;
  reg [1:0] TX_TDCC_CFG_BINARY;
  reg [2:0] GEARBOX_ENDEC_BINARY;
  reg [2:0] OOBDETECT_THRESHOLD_BINARY;
  reg [2:0] RXPLL_LKDET_CFG_BINARY;
  reg [2:0] RXRECCLK_CTRL_BINARY;
  reg [2:0] RX_DATA_WIDTH_BINARY;
  reg [2:0] RX_DLYALIGN_MONSEL_BINARY;
  reg [2:0] RX_LOS_INVALID_INCR_BINARY;
  reg [2:0] RX_LOS_THRESHOLD_BINARY;
  reg [2:0] SATA_BURST_VAL_BINARY;
  reg [2:0] SATA_IDLE_VAL_BINARY;
  reg [2:0] SIM_RXREFCLK_SOURCE_BINARY;
  reg [2:0] SIM_TXREFCLK_SOURCE_BINARY;
  reg [2:0] TXOUTCLK_CTRL_BINARY;
  reg [2:0] TXPLL_LKDET_CFG_BINARY;
  reg [2:0] TX_DATA_WIDTH_BINARY;
  reg [2:0] TX_DLYALIGN_MONSEL_BINARY;
  reg [2:0] TX_IDLE_ASSERT_DELAY_BINARY;
  reg [2:0] TX_IDLE_DEASSERT_DELAY_BINARY;
  reg [3:0] CHAN_BOND_1_MAX_SKEW_BINARY;
  reg [3:0] CHAN_BOND_2_MAX_SKEW_BINARY;
  reg [3:0] CHAN_BOND_SEQ_1_ENABLE_BINARY;
  reg [3:0] CHAN_BOND_SEQ_2_ENABLE_BINARY;
  reg [3:0] CLK_COR_SEQ_1_ENABLE_BINARY;
  reg [3:0] CLK_COR_SEQ_2_ENABLE_BINARY;
  reg [3:0] COM_BURST_VAL_BINARY;
  reg [3:0] RX_DLYALIGN_CTRINC_BINARY;
  reg [3:0] RX_DLYALIGN_LPFINC_BINARY;
  reg [3:0] RX_IDLE_HI_CNT_BINARY;
  reg [3:0] RX_IDLE_LO_CNT_BINARY;
  reg [3:0] RX_SLIDE_AUTO_WAIT_BINARY;
  reg [3:0] TX_DLYALIGN_CTRINC_BINARY;
  reg [3:0] TX_DLYALIGN_LPFINC_BINARY;
  reg [4:0] CDR_PH_ADJ_TIME_BINARY;
  reg [4:0] CHAN_BOND_SEQ_2_CFG_BINARY;
  reg [4:0] CLK_COR_REPEAT_WAIT_BINARY;
  reg [4:0] DFE_CAL_TIME_BINARY;
  reg [4:0] RXPLL_DIVSEL_FB_BINARY;
  reg [4:0] RXPLL_DIVSEL_REF_BINARY;
  reg [4:0] RX_CLK25_DIVIDER_BINARY;
  reg [4:0] RX_DLYALIGN_EDGESET_BINARY;
  reg [4:0] TERMINATION_CTRL_BINARY;
  reg [4:0] TXPLL_DIVSEL_FB_BINARY;
  reg [4:0] TXPLL_DIVSEL_REF_BINARY;
  reg [4:0] TX_CLK25_DIVIDER_BINARY;
  reg [4:0] TX_DEEMPH_0_BINARY;
  reg [4:0] TX_DEEMPH_1_BINARY;
  reg [5:0] CLK_COR_MAX_LAT_BINARY;
  reg [5:0] CLK_COR_MIN_LAT_BINARY;
  reg [5:0] SAS_MAX_COMSAS_BINARY;
  reg [5:0] SAS_MIN_COMSAS_BINARY;
  reg [5:0] SATA_MAX_BURST_BINARY;
  reg [5:0] SATA_MAX_INIT_BINARY;
  reg [5:0] SATA_MAX_WAKE_BINARY;
  reg [5:0] SATA_MIN_BURST_BINARY;
  reg [5:0] SATA_MIN_INIT_BINARY;
  reg [5:0] SATA_MIN_WAKE_BINARY;
  reg [6:0] TX_MARGIN_FULL_0_BINARY;
  reg [6:0] TX_MARGIN_FULL_1_BINARY;
  reg [6:0] TX_MARGIN_FULL_2_BINARY;
  reg [6:0] TX_MARGIN_FULL_3_BINARY;
  reg [6:0] TX_MARGIN_FULL_4_BINARY;
  reg [6:0] TX_MARGIN_LOW_0_BINARY;
  reg [6:0] TX_MARGIN_LOW_1_BINARY;
  reg [6:0] TX_MARGIN_LOW_2_BINARY;
  reg [6:0] TX_MARGIN_LOW_3_BINARY;
  reg [6:0] TX_MARGIN_LOW_4_BINARY;
  reg [7:0] DFE_CFG_BINARY;
  reg [7:0] RX_DLYALIGN_OVRDSETTING_BINARY;
  reg [7:0] TX_DLYALIGN_OVRDSETTING_BINARY;
  reg [9:0] CHAN_BOND_SEQ_1_1_BINARY;
  reg [9:0] CHAN_BOND_SEQ_1_2_BINARY;
  reg [9:0] CHAN_BOND_SEQ_1_3_BINARY;
  reg [9:0] CHAN_BOND_SEQ_1_4_BINARY;
  reg [9:0] CHAN_BOND_SEQ_2_1_BINARY;
  reg [9:0] CHAN_BOND_SEQ_2_2_BINARY;
  reg [9:0] CHAN_BOND_SEQ_2_3_BINARY;
  reg [9:0] CHAN_BOND_SEQ_2_4_BINARY;
  reg [9:0] CLK_COR_SEQ_1_1_BINARY;
  reg [9:0] CLK_COR_SEQ_1_2_BINARY;
  reg [9:0] CLK_COR_SEQ_1_3_BINARY;
  reg [9:0] CLK_COR_SEQ_1_4_BINARY;
  reg [9:0] CLK_COR_SEQ_2_1_BINARY;
  reg [9:0] CLK_COR_SEQ_2_2_BINARY;
  reg [9:0] CLK_COR_SEQ_2_3_BINARY;
  reg [9:0] CLK_COR_SEQ_2_4_BINARY;
  reg [9:0] COMMA_10B_ENABLE_BINARY;
  reg [9:0] MCOMMA_10B_VALUE_BINARY;
  reg [9:0] PCOMMA_10B_VALUE_BINARY;
  reg [9:0] POWER_SAVE_BINARY;
  reg [9:0] RXRECCLK_DLY_BINARY;
  reg [9:0] TXOUTCLK_DLY_BINARY;

  tri0 GSR = glbl.GSR;

  initial begin

    // Start DRC checks

     if (CHAN_BOND_2_MAX_SKEW > CHAN_BOND_1_MAX_SKEW) begin
	$display("DRC Error : The value of CHAN_BOND_2_MAX_SKEW is set to %d. This value must be less than or equal to the value of CHAN_BOND_1_MAX_SKEW %d for instance %m of GTXE1.",CHAN_BOND_2_MAX_SKEW, CHAN_BOND_1_MAX_SKEW);
	    $finish;
     end
     
     if (CLK_COR_MIN_LAT > CLK_COR_MAX_LAT) begin
	    $display("DRC Error :  The value of CLK_COR_MIN_LAT is set to %d. This value must be less than or equal to the value of CLK_COR_MAX_LAT %d for instance %m of GTXE1.",CLK_COR_MIN_LAT, CLK_COR_MAX_LAT);
	    $finish;
     end

     if (SATA_MIN_BURST > SATA_MAX_BURST) begin
	    $display("DRC Error : The value of SATA_MIN_BURST is set to %d. This value must be less than or equal to the value of SATA_MAX_BURST %d for instance %m of GTXE1.",SATA_MIN_BURST, SATA_MAX_BURST);
	    $finish;
     end

     if (SATA_MIN_INIT > SATA_MAX_INIT) begin
	    $display("DRC Error : The value of SATA_MIN_INIT is set to %d. This value must be less than or equal to the value of SATA_MAX_INIT %d for instance %m of GTXE1.",SATA_MIN_INIT, SATA_MAX_INIT);
	    $finish;
     end
     
     if (SATA_MIN_WAKE > SATA_MAX_WAKE) begin
	    $display("DRC Error : The value of SATA_MIN_WAKE is set to %d. This value must be less than or equal to the value of SATA_MAX_WAKE %d for instance %m of GTXE1.",SATA_MIN_WAKE, SATA_MAX_WAKE);
	    $finish;
     end

     if (SAS_MIN_COMSAS > SAS_MAX_COMSAS) begin
	    $display("DRC Error : The value of SAS_MIN_COMSAS is set to %d. This value must be less than or equal to the value of SAS_MAX_COMSAS %d for instance %m of GTXE1.",SAS_MIN_COMSAS, SAS_MAX_COMSAS);
	    $finish;
     end

     if ((RX_DATA_WIDTH == 16 &&  GEN_RXUSRCLK == "FALSE") || (RX_DATA_WIDTH == 20 &&  GEN_RXUSRCLK == "FALSE")) begin
	    $display("DRC Error : The following attribute condition must be satisfied for instance %m of GTXE1 : If RX_DATA_WIDTH is 8 or 10 (and channel bonding is not used) or if RX_DATA_WIDTH is 16 or 20 then set GEN_RXUSRCLK to TRUE.");
	    $finish;
     end
     
     if ((RX_DATA_WIDTH == 32 &&  GEN_RXUSRCLK == "TRUE") || (RX_DATA_WIDTH == 40 &&  GEN_RXUSRCLK == "TRUE")) begin
	    $display("DRC Error : The following attribute condition must be satisfied for instance %m of GTXE1 : If RX_DATA_WIDTH is 32 or 40 then set GEN_RXUSRCLK to FALSE.");
	    $finish;
     end

     if ((TX_DATA_WIDTH == 16 &&  GEN_TXUSRCLK == "FALSE") || (TX_DATA_WIDTH == 20 &&  GEN_TXUSRCLK == "FALSE")) begin
	    $display("DRC Error : The following attribute condition must be satisfied for instance %m of GTXE1 : If TX_DATA_WIDTH is 8 or 10 (and channel bonding is not used) or if TX_DATA_WIDTH is 16 or 20 then set GEN_TXUSRCLK to TRUE.");
	    $finish;
     end
     
     if ((TX_DATA_WIDTH == 32 &&  GEN_TXUSRCLK == "TRUE") || (TX_DATA_WIDTH == 40 &&  GEN_TXUSRCLK == "TRUE")) begin
	    $display("DRC Error : The following attribute condition must be satisfied for instance %m of GTXE1 : If TX_DATA_WIDTH is 32 or 40 then set GEN_TXUSRCLK to FALSE.");
	    $finish;
     end

     if (CLK_CORRECT_USE == "TRUE" && RX_FIFO_ADDR_MODE == "FAST") begin
	    $display("DRC Error : The following attribute condition must be satisfied for instance %m of GTXE1 : If CLK_CORRECT_USE is TRUE then set RX_FIFO_ADDR_MODE to FULL.");
	    $finish;
     end

     if ((RX_SLIDE_MODE == "PMA" && SHOW_REALIGN_COMMA == "TRUE") || (RX_SLIDE_MODE == "AUTO" && SHOW_REALIGN_COMMA == "TRUE")) begin
	    $display("DRC Error : The following attribute condition must be satisfied for instance %m of GTXE1 : If RX_SLIDE_MODE is PMA or AUTO then set SHOW_REALIGN_COMMA to FALSE.");
	    $finish;
     end

     if (TXOUTCLK_CTRL == "CLKTESTSIG0") begin
          $display("DRC Error : TXOUTCLK_CTRL cannot be set to %s for instance %m of GTXE1.", TXOUTCLK_CTRL);
	$finish;
     end

     if (RXRECCLK_CTRL == "CLKTESTSIG1") begin
	 $display("DRC Error :RXRECCLK_CTRL cannot be set to %s for instance %m of GTXE1.", RXRECCLK_CTRL);
	$finish;
     end
     
     if (TXOUTCLK_CTRL == "OFF_LOW") begin
          $display("DRC Error : TXOUTCLK_CTRL cannot be set to %s for instance %m of GTXE1.", TXOUTCLK_CTRL);
	$finish;
     end

     if (RXRECCLK_CTRL == "OFF_LOW") begin
	 $display("DRC Error :RXRECCLK_CTRL cannot be set to %s for instance %m of GTXE1.", RXRECCLK_CTRL);
	$finish;
     end

     if (TXOUTCLK_CTRL == "OFF_HIGH") begin
          $display("DRC Error : TXOUTCLK_CTRL cannot be set to %s for instance %m of GTXE1.", TXOUTCLK_CTRL);
	$finish;
     end

     if (RXRECCLK_CTRL == "OFF_HIGH") begin
	 $display("DRC Error :RXRECCLK_CTRL cannot be set to %s for instance %m of GTXE1.", RXRECCLK_CTRL);
	$finish;
     end
     
     if ((TX_BUFFER_USE == "TRUE") && (POWER_SAVE[4] != 1)) begin
	$display("DRC Error : If value of TX_BUFFER_USE is set to %s then value of POWER_SAVE[4] has to be set to 1 for instance %m of GTXE1.", TX_BUFFER_USE, POWER_SAVE);
	$finish;
     end

     if ((TX_BUFFER_USE == "FALSE") && (POWER_SAVE[4] != 0)) begin
	$display("DRC Error : If value of TX_BUFFER_USE is set to %s then value of POWER_SAVE[4] has to be set to 0 for instance %m of GTXE1.", TX_BUFFER_USE, POWER_SAVE);
	$finish;
     end

     if ((RX_BUFFER_USE == "TRUE") && (POWER_SAVE[5] != 1)) begin
	$display("DRC Error : If value of RX_BUFFER_USE is set to %s then value of POWER_SAVE[5] has to be set to 1 for instance %m of GTXE1.", RX_BUFFER_USE, POWER_SAVE);
	$finish;
     end

     if ((RX_BUFFER_USE == "FALSE") && (POWER_SAVE[5] != 0)) begin
	$display("DRC Error : If value of RX_BUFFER_USE is set to %s then value of POWER_SAVE[5] has to be set to 0 for instance %m of GTXE1.", RX_BUFFER_USE, POWER_SAVE);
	$finish;
     end   

    // End DRC checks

    case (AC_CAP_DIS)
      "FALSE" : AC_CAP_DIS_BINARY = 1'b0;
      "TRUE" : AC_CAP_DIS_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute AC_CAP_DIS on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", AC_CAP_DIS);
        $finish;
      end
    endcase

    case (ALIGN_COMMA_WORD)
      1 : ALIGN_COMMA_WORD_BINARY = 1'b0;
      2 : ALIGN_COMMA_WORD_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute ALIGN_COMMA_WORD on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 2.", ALIGN_COMMA_WORD, 1);
        $finish;
      end
    endcase

    case (CHAN_BOND_KEEP_ALIGN)
      "FALSE" : CHAN_BOND_KEEP_ALIGN_BINARY = 1'b0;
      "TRUE" : CHAN_BOND_KEEP_ALIGN_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute CHAN_BOND_KEEP_ALIGN on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CHAN_BOND_KEEP_ALIGN);
        $finish;
      end
    endcase

    case (CHAN_BOND_SEQ_2_USE)
      "FALSE" : CHAN_BOND_SEQ_2_USE_BINARY = 1'b0;
      "TRUE" : CHAN_BOND_SEQ_2_USE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_2_USE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CHAN_BOND_SEQ_2_USE);
        $finish;
      end
    endcase

    case (CHAN_BOND_SEQ_LEN)
      1 : CHAN_BOND_SEQ_LEN_BINARY = 2'b00;
      2 : CHAN_BOND_SEQ_LEN_BINARY = 2'b01;
      4 : CHAN_BOND_SEQ_LEN_BINARY = 2'b11;
      default : begin
        $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_LEN on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 4.", CHAN_BOND_SEQ_LEN, 1);
        $finish;
      end
    endcase

    case (CLK_CORRECT_USE)
      "FALSE" : CLK_CORRECT_USE_BINARY = 1'b0;
      "TRUE" : CLK_CORRECT_USE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLK_CORRECT_USE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_CORRECT_USE);
        $finish;
      end
    endcase

    case (CLK_COR_ADJ_LEN)
      1 : CLK_COR_ADJ_LEN_BINARY = 2'b00;
      2 : CLK_COR_ADJ_LEN_BINARY = 2'b01;
      4 : CLK_COR_ADJ_LEN_BINARY = 2'b11;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLK_COR_ADJ_LEN on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 4.", CLK_COR_ADJ_LEN, 1);
        $finish;
      end
    endcase

    case (CLK_COR_DET_LEN)
      1 : CLK_COR_DET_LEN_BINARY = 2'b00;
      2 : CLK_COR_DET_LEN_BINARY = 2'b01;
      4 : CLK_COR_DET_LEN_BINARY = 2'b11;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLK_COR_DET_LEN on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 4.", CLK_COR_DET_LEN, 1);
        $finish;
      end
    endcase

    case (CLK_COR_INSERT_IDLE_FLAG)
      "FALSE" : CLK_COR_INSERT_IDLE_FLAG_BINARY = 1'b0;
      "TRUE" : CLK_COR_INSERT_IDLE_FLAG_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLK_COR_INSERT_IDLE_FLAG on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_INSERT_IDLE_FLAG);
        $finish;
      end
    endcase

    case (CLK_COR_KEEP_IDLE)
      "FALSE" : CLK_COR_KEEP_IDLE_BINARY = 1'b0;
      "TRUE" : CLK_COR_KEEP_IDLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLK_COR_KEEP_IDLE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_KEEP_IDLE);
        $finish;
      end
    endcase

    case (CLK_COR_PRECEDENCE)
      "FALSE" : CLK_COR_PRECEDENCE_BINARY = 1'b0;
      "TRUE" : CLK_COR_PRECEDENCE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLK_COR_PRECEDENCE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_PRECEDENCE);
        $finish;
      end
    endcase

    case (CLK_COR_SEQ_2_USE)
      "FALSE" : CLK_COR_SEQ_2_USE_BINARY = 1'b0;
      "TRUE" : CLK_COR_SEQ_2_USE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_2_USE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_SEQ_2_USE);
        $finish;
      end
    endcase

    case (COMMA_DOUBLE)
      "FALSE" : COMMA_DOUBLE_BINARY = 1'b0;
      "TRUE" : COMMA_DOUBLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute COMMA_DOUBLE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", COMMA_DOUBLE);
        $finish;
      end
    endcase

    case (DEC_MCOMMA_DETECT)
      "FALSE" : DEC_MCOMMA_DETECT_BINARY = 1'b0;
      "TRUE" : DEC_MCOMMA_DETECT_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute DEC_MCOMMA_DETECT on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DEC_MCOMMA_DETECT);
        $finish;
      end
    endcase

    case (DEC_PCOMMA_DETECT)
      "FALSE" : DEC_PCOMMA_DETECT_BINARY = 1'b0;
      "TRUE" : DEC_PCOMMA_DETECT_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute DEC_PCOMMA_DETECT on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DEC_PCOMMA_DETECT);
        $finish;
      end
    endcase

    case (DEC_VALID_COMMA_ONLY)
      "FALSE" : DEC_VALID_COMMA_ONLY_BINARY = 1'b0;
      "TRUE" : DEC_VALID_COMMA_ONLY_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute DEC_VALID_COMMA_ONLY on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DEC_VALID_COMMA_ONLY);
        $finish;
      end
    endcase

    case (GEN_RXUSRCLK)
      "FALSE" : GEN_RXUSRCLK_BINARY = 1'b0;
      "TRUE" : GEN_RXUSRCLK_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute GEN_RXUSRCLK on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", GEN_RXUSRCLK);
        $finish;
      end
    endcase

    case (GEN_TXUSRCLK)
      "FALSE" : GEN_TXUSRCLK_BINARY = 1'b0;
      "TRUE" : GEN_TXUSRCLK_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute GEN_TXUSRCLK on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", GEN_TXUSRCLK);
        $finish;
      end
    endcase

    case (GTX_CFG_PWRUP)
      "FALSE" : GTX_CFG_PWRUP_BINARY = 1'b0;
      "TRUE" : GTX_CFG_PWRUP_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute GTX_CFG_PWRUP on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", GTX_CFG_PWRUP);
        $finish;
      end
    endcase

    case (MCOMMA_DETECT)
      "FALSE" : MCOMMA_DETECT_BINARY = 1'b0;
      "TRUE" : MCOMMA_DETECT_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute MCOMMA_DETECT on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MCOMMA_DETECT);
        $finish;
      end
    endcase

    case (PCI_EXPRESS_MODE)
      "FALSE" : PCI_EXPRESS_MODE_BINARY = 1'b0;
      "TRUE" : PCI_EXPRESS_MODE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute PCI_EXPRESS_MODE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PCI_EXPRESS_MODE);
        $finish;
      end
    endcase

    case (PCOMMA_DETECT)
      "FALSE" : PCOMMA_DETECT_BINARY = 1'b0;
      "TRUE" : PCOMMA_DETECT_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute PCOMMA_DETECT on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PCOMMA_DETECT);
        $finish;
      end
    endcase

    case (PMA_CAS_CLK_EN)
      "FALSE" : PMA_CAS_CLK_EN_BINARY = 1'b0;
      "TRUE" : PMA_CAS_CLK_EN_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute PMA_CAS_CLK_EN on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PMA_CAS_CLK_EN);
        $finish;
      end
    endcase

    case (RCV_TERM_GND)
      "FALSE" : RCV_TERM_GND_BINARY = 1'b0;
      "TRUE" : RCV_TERM_GND_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RCV_TERM_GND on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RCV_TERM_GND);
        $finish;
      end
    endcase

    case (RCV_TERM_VTTRX)
      "FALSE" : RCV_TERM_VTTRX_BINARY = 1'b0;
      "TRUE" : RCV_TERM_VTTRX_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RCV_TERM_VTTRX on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RCV_TERM_VTTRX);
        $finish;
      end
    endcase

    case (RXGEARBOX_USE)
      "FALSE" : RXGEARBOX_USE_BINARY = 1'b0;
      "TRUE" : RXGEARBOX_USE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RXGEARBOX_USE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RXGEARBOX_USE);
        $finish;
      end
    endcase

    case (RXPLL_DIVSEL45_FB)
      5 : RXPLL_DIVSEL45_FB_BINARY = 1'b1;
      4 : RXPLL_DIVSEL45_FB_BINARY = 1'b0;
      default : begin
        $display("Attribute Syntax Error : The Attribute RXPLL_DIVSEL45_FB on GTXE1 instance %m is set to %d.  Legal values for this attribute are 4 to 5.", RXPLL_DIVSEL45_FB, 5);
        $finish;
      end
    endcase

    case (RXPLL_DIVSEL_FB)
      2 : RXPLL_DIVSEL_FB_BINARY = 5'b00000;
      1 : RXPLL_DIVSEL_FB_BINARY = 5'b10000;
      3 : RXPLL_DIVSEL_FB_BINARY = 5'b00001;
      4 : RXPLL_DIVSEL_FB_BINARY = 5'b00010;
      5 : RXPLL_DIVSEL_FB_BINARY = 5'b00011;
      6 : RXPLL_DIVSEL_FB_BINARY = 5'b00101;
      8 : RXPLL_DIVSEL_FB_BINARY = 5'b00110;
      10 : RXPLL_DIVSEL_FB_BINARY = 5'b00111;
      12 : RXPLL_DIVSEL_FB_BINARY = 5'b01101;
      16 : RXPLL_DIVSEL_FB_BINARY = 5'b01110;
      20 : RXPLL_DIVSEL_FB_BINARY = 5'b01111;
      default : begin
        $display("Attribute Syntax Error : The Attribute RXPLL_DIVSEL_FB on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 20.", RXPLL_DIVSEL_FB, 2);
        $finish;
      end
    endcase

    case (RXPLL_DIVSEL_OUT)
      1 : RXPLL_DIVSEL_OUT_BINARY = 2'b00;
      2 : RXPLL_DIVSEL_OUT_BINARY = 2'b01;
      4 : RXPLL_DIVSEL_OUT_BINARY = 2'b10;
      default : begin
        $display("Attribute Syntax Error : The Attribute RXPLL_DIVSEL_OUT on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 4.", RXPLL_DIVSEL_OUT, 1);
        $finish;
      end
    endcase

    case (RXPLL_DIVSEL_REF)
      1 : RXPLL_DIVSEL_REF_BINARY = 5'b10000;
      2 : RXPLL_DIVSEL_REF_BINARY = 5'b00000;
      3 : RXPLL_DIVSEL_REF_BINARY = 5'b00001;
      4 : RXPLL_DIVSEL_REF_BINARY = 5'b00010;
      5 : RXPLL_DIVSEL_REF_BINARY = 5'b00011;
      6 : RXPLL_DIVSEL_REF_BINARY = 5'b00101;
      8 : RXPLL_DIVSEL_REF_BINARY = 5'b00110;
      10 : RXPLL_DIVSEL_REF_BINARY = 5'b00111;
      12 : RXPLL_DIVSEL_REF_BINARY = 5'b01101;
      16 : RXPLL_DIVSEL_REF_BINARY = 5'b01110;
      20 : RXPLL_DIVSEL_REF_BINARY = 5'b01111;
      default : begin
        $display("Attribute Syntax Error : The Attribute RXPLL_DIVSEL_REF on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 20.", RXPLL_DIVSEL_REF, 1);
        $finish;
      end
    endcase

    case (RXRECCLK_CTRL)
      "RXRECCLKPCS" : RXRECCLK_CTRL_BINARY = 3'b000;
      "RXPLLREFCLK_DIV1" : RXRECCLK_CTRL_BINARY = 3'b011;
      "RXPLLREFCLK_DIV2" : RXRECCLK_CTRL_BINARY = 3'b100;
      "RXRECCLKPMA_DIV1" : RXRECCLK_CTRL_BINARY = 3'b001;
      "RXRECCLKPMA_DIV2" : RXRECCLK_CTRL_BINARY = 3'b010;
      default : begin
        $display("Attribute Syntax Error : The Attribute RXRECCLK_CTRL on GTXE1 instance %m is set to %s.  Legal values for this attribute are RXRECCLKPCS, RXPLLREFCLK_DIV1, RXPLLREFCLK_DIV2, RXRECCLKPMA_DIV1, or RXRECCLKPMA_DIV2.", RXRECCLK_CTRL);
        $finish;
      end
    endcase

    case (RX_BUFFER_USE)
      "FALSE" : RX_BUFFER_USE_BINARY = 1'b0;
      "TRUE" : RX_BUFFER_USE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_BUFFER_USE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_BUFFER_USE);
        $finish;
      end
    endcase

    case (RX_CLK25_DIVIDER)
      6 : RX_CLK25_DIVIDER_BINARY = 5'b00101;
      1 : RX_CLK25_DIVIDER_BINARY = 5'b00000;
      2 : RX_CLK25_DIVIDER_BINARY = 5'b00001;
      3 : RX_CLK25_DIVIDER_BINARY = 5'b00010;
      4 : RX_CLK25_DIVIDER_BINARY = 5'b00011;
      5 : RX_CLK25_DIVIDER_BINARY = 5'b00100;
      7 : RX_CLK25_DIVIDER_BINARY = 5'b00110;
      8 : RX_CLK25_DIVIDER_BINARY = 5'b00111;
      9 : RX_CLK25_DIVIDER_BINARY = 5'b01000;
      10 : RX_CLK25_DIVIDER_BINARY = 5'b01001;
      11 : RX_CLK25_DIVIDER_BINARY = 5'b01010;
      12 : RX_CLK25_DIVIDER_BINARY = 5'b01011;
      13 : RX_CLK25_DIVIDER_BINARY = 5'b01100;
      14 : RX_CLK25_DIVIDER_BINARY = 5'b01101;
      15 : RX_CLK25_DIVIDER_BINARY = 5'b01110;
      16 : RX_CLK25_DIVIDER_BINARY = 5'b01111;
      17 : RX_CLK25_DIVIDER_BINARY = 5'b10000;
      18 : RX_CLK25_DIVIDER_BINARY = 5'b10001;
      19 : RX_CLK25_DIVIDER_BINARY = 5'b10010;
      20 : RX_CLK25_DIVIDER_BINARY = 5'b10011;
      21 : RX_CLK25_DIVIDER_BINARY = 5'b10100;
      22 : RX_CLK25_DIVIDER_BINARY = 5'b10101;
      23 : RX_CLK25_DIVIDER_BINARY = 5'b10110;
      24 : RX_CLK25_DIVIDER_BINARY = 5'b10111;
      25 : RX_CLK25_DIVIDER_BINARY = 5'b11000;
      26 : RX_CLK25_DIVIDER_BINARY = 5'b11001;
      27 : RX_CLK25_DIVIDER_BINARY = 5'b11010;
      28 : RX_CLK25_DIVIDER_BINARY = 5'b11011;
      29 : RX_CLK25_DIVIDER_BINARY = 5'b11100;
      30 : RX_CLK25_DIVIDER_BINARY = 5'b11101;
      31 : RX_CLK25_DIVIDER_BINARY = 5'b11110;
      32 : RX_CLK25_DIVIDER_BINARY = 5'b11111;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_CLK25_DIVIDER on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 32.", RX_CLK25_DIVIDER, 6);
        $finish;
      end
    endcase

    case (RX_DATA_WIDTH)
      20 : RX_DATA_WIDTH_BINARY = 3'b011;
      8 : RX_DATA_WIDTH_BINARY = 3'b000;
      10 : RX_DATA_WIDTH_BINARY = 3'b001;
      16 : RX_DATA_WIDTH_BINARY = 3'b010;
      32 : RX_DATA_WIDTH_BINARY = 3'b100;
      40 : RX_DATA_WIDTH_BINARY = 3'b101;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_DATA_WIDTH on GTXE1 instance %m is set to %d.  Legal values for this attribute are 8 to 40.", RX_DATA_WIDTH, 20);
        $finish;
      end
    endcase

    case (RX_DECODE_SEQ_MATCH)
      "FALSE" : RX_DECODE_SEQ_MATCH_BINARY = 1'b0;
      "TRUE" : RX_DECODE_SEQ_MATCH_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_DECODE_SEQ_MATCH on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_DECODE_SEQ_MATCH);
        $finish;
      end
    endcase

    case (RX_EN_IDLE_HOLD_CDR)
      "FALSE" : RX_EN_IDLE_HOLD_CDR_BINARY = 1'b0;
      "TRUE" : RX_EN_IDLE_HOLD_CDR_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_EN_IDLE_HOLD_CDR on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_HOLD_CDR);
        $finish;
      end
    endcase

    case (RX_EN_IDLE_HOLD_DFE)
      "FALSE" : RX_EN_IDLE_HOLD_DFE_BINARY = 1'b0;
      "TRUE" : RX_EN_IDLE_HOLD_DFE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_EN_IDLE_HOLD_DFE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_HOLD_DFE);
        $finish;
      end
    endcase

    case (RX_EN_IDLE_RESET_BUF)
      "FALSE" : RX_EN_IDLE_RESET_BUF_BINARY = 1'b0;
      "TRUE" : RX_EN_IDLE_RESET_BUF_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_EN_IDLE_RESET_BUF on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_RESET_BUF);
        $finish;
      end
    endcase

    case (RX_EN_IDLE_RESET_FR)
      "FALSE" : RX_EN_IDLE_RESET_FR_BINARY = 1'b0;
      "TRUE" : RX_EN_IDLE_RESET_FR_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_EN_IDLE_RESET_FR on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_RESET_FR);
        $finish;
      end
    endcase

    case (RX_EN_IDLE_RESET_PH)
      "FALSE" : RX_EN_IDLE_RESET_PH_BINARY = 1'b0;
      "TRUE" : RX_EN_IDLE_RESET_PH_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_EN_IDLE_RESET_PH on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_RESET_PH);
        $finish;
      end
    endcase

    case (RX_EN_MODE_RESET_BUF)
      "FALSE" : RX_EN_MODE_RESET_BUF_BINARY = 1'b0;
      "TRUE" : RX_EN_MODE_RESET_BUF_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_EN_MODE_RESET_BUF on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_MODE_RESET_BUF);
        $finish;
      end
    endcase

    case (RX_EN_RATE_RESET_BUF)
      "FALSE" : RX_EN_RATE_RESET_BUF_BINARY = 1'b0;
      "TRUE" : RX_EN_RATE_RESET_BUF_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_EN_RATE_RESET_BUF on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_RATE_RESET_BUF);
        $finish;
      end
    endcase

    case (RX_EN_REALIGN_RESET_BUF)
      "FALSE" : RX_EN_REALIGN_RESET_BUF_BINARY = 1'b0;
      "TRUE" : RX_EN_REALIGN_RESET_BUF_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_EN_REALIGN_RESET_BUF on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_REALIGN_RESET_BUF);
        $finish;
      end
    endcase

    case (RX_EN_REALIGN_RESET_BUF2)
      "FALSE" : RX_EN_REALIGN_RESET_BUF2_BINARY = 1'b0;
      "TRUE" : RX_EN_REALIGN_RESET_BUF2_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_EN_REALIGN_RESET_BUF2 on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_REALIGN_RESET_BUF2);
        $finish;
      end
    endcase

    case (RX_FIFO_ADDR_MODE)
      "FULL" : RX_FIFO_ADDR_MODE_BINARY = 1'b0;
      "FAST" : RX_FIFO_ADDR_MODE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_FIFO_ADDR_MODE on GTXE1 instance %m is set to %s.  Legal values for this attribute are FULL, or FAST.", RX_FIFO_ADDR_MODE);
        $finish;
      end
    endcase

    case (RX_LOSS_OF_SYNC_FSM)
      "FALSE" : RX_LOSS_OF_SYNC_FSM_BINARY = 1'b0;
      "TRUE" : RX_LOSS_OF_SYNC_FSM_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_LOSS_OF_SYNC_FSM on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_LOSS_OF_SYNC_FSM);
        $finish;
      end
    endcase

    case (RX_LOS_INVALID_INCR)
      1 : RX_LOS_INVALID_INCR_BINARY = 3'b000;
      2 : RX_LOS_INVALID_INCR_BINARY = 3'b001;
      4 : RX_LOS_INVALID_INCR_BINARY = 3'b010;
      8 : RX_LOS_INVALID_INCR_BINARY = 3'b011;
      16 : RX_LOS_INVALID_INCR_BINARY = 3'b100;
      32 : RX_LOS_INVALID_INCR_BINARY = 3'b101;
      64 : RX_LOS_INVALID_INCR_BINARY = 3'b110;
      128 : RX_LOS_INVALID_INCR_BINARY = 3'b111;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_LOS_INVALID_INCR on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 128.", RX_LOS_INVALID_INCR, 1);
        $finish;
      end
    endcase

    case (RX_LOS_THRESHOLD)
      4 : RX_LOS_THRESHOLD_BINARY = 3'b000;
      8 : RX_LOS_THRESHOLD_BINARY = 3'b001;
      16 : RX_LOS_THRESHOLD_BINARY = 3'b010;
      32 : RX_LOS_THRESHOLD_BINARY = 3'b011;
      64 : RX_LOS_THRESHOLD_BINARY = 3'b100;
      128 : RX_LOS_THRESHOLD_BINARY = 3'b101;
      256 : RX_LOS_THRESHOLD_BINARY = 3'b110;
      512 : RX_LOS_THRESHOLD_BINARY = 3'b111;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_LOS_THRESHOLD on GTXE1 instance %m is set to %d.  Legal values for this attribute are 4 to 512.", RX_LOS_THRESHOLD, 4);
        $finish;
      end
    endcase

    case (RX_OVERSAMPLE_MODE)
      "FALSE" : RX_OVERSAMPLE_MODE_BINARY = 1'b0;
      "TRUE" : RX_OVERSAMPLE_MODE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_OVERSAMPLE_MODE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_OVERSAMPLE_MODE);
        $finish;
      end
    endcase

    case (RX_SLIDE_MODE)
      "OFF" : RX_SLIDE_MODE_BINARY = 2'b00;
      "AUTO" : RX_SLIDE_MODE_BINARY = 2'b01;
      "PCS" : RX_SLIDE_MODE_BINARY = 2'b10;
      "PMA" : RX_SLIDE_MODE_BINARY = 2'b11;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_SLIDE_MODE on GTXE1 instance %m is set to %s.  Legal values for this attribute are OFF, AUTO, PCS, or PMA.", RX_SLIDE_MODE);
        $finish;
      end
    endcase

    case (RX_XCLK_SEL)
      "RXREC" : RX_XCLK_SEL_BINARY = 1'b0;
      "RXUSR" : RX_XCLK_SEL_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute RX_XCLK_SEL on GTXE1 instance %m is set to %s.  Legal values for this attribute are RXREC, or RXUSR.", RX_XCLK_SEL);
        $finish;
      end
    endcase

    case (SHOW_REALIGN_COMMA)
      "FALSE" : SHOW_REALIGN_COMMA_BINARY = 1'b0;
      "TRUE" : SHOW_REALIGN_COMMA_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute SHOW_REALIGN_COMMA on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", SHOW_REALIGN_COMMA);
        $finish;
      end
    endcase

    case (SIM_GTXRESET_SPEEDUP)
      1 : SIM_GTXRESET_SPEEDUP_BINARY =  1;
      0 : SIM_GTXRESET_SPEEDUP_BINARY =  0;
      default : begin
        $display("Attribute Syntax Error : The Attribute SIM_GTXRESET_SPEEDUP on GTXE1 instance %m is set to %d.  Legal values for this attribute are 0 to 1.", SIM_GTXRESET_SPEEDUP, 1);
        $finish;
      end
    endcase

    case (SIM_RECEIVER_DETECT_PASS)
      "FALSE" : SIM_RECEIVER_DETECT_PASS_BINARY = 1'b0;
      "TRUE" : SIM_RECEIVER_DETECT_PASS_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute SIM_RECEIVER_DETECT_PASS on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", SIM_RECEIVER_DETECT_PASS);
        $finish;
      end
    endcase

    case (TERMINATION_OVRD)
      "FALSE" : TERMINATION_OVRD_BINARY = 1'b0;
      "TRUE" : TERMINATION_OVRD_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TERMINATION_OVRD on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TERMINATION_OVRD);
        $finish;
      end
    endcase

    case (TXDRIVE_LOOPBACK_HIZ)
      "FALSE" : TXDRIVE_LOOPBACK_HIZ_BINARY = 1'b0;
      "TRUE" : TXDRIVE_LOOPBACK_HIZ_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TXDRIVE_LOOPBACK_HIZ on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TXDRIVE_LOOPBACK_HIZ);
        $finish;
      end
    endcase

    case (TXDRIVE_LOOPBACK_PD)
      "FALSE" : TXDRIVE_LOOPBACK_PD_BINARY = 1'b0;
      "TRUE" : TXDRIVE_LOOPBACK_PD_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TXDRIVE_LOOPBACK_PD on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TXDRIVE_LOOPBACK_PD);
        $finish;
      end
    endcase

    case (TXGEARBOX_USE)
      "FALSE" : TXGEARBOX_USE_BINARY = 1'b0;
      "TRUE" : TXGEARBOX_USE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TXGEARBOX_USE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TXGEARBOX_USE);
        $finish;
      end
    endcase

    case (TXOUTCLK_CTRL)
      "TXOUTCLKPCS" : TXOUTCLK_CTRL_BINARY = 3'b000;
      "TXOUTCLKPMA_DIV1" : TXOUTCLK_CTRL_BINARY = 3'b001;
      "TXOUTCLKPMA_DIV2" : TXOUTCLK_CTRL_BINARY = 3'b010;
      "TXPLLREFCLK_DIV1" : TXOUTCLK_CTRL_BINARY = 3'b011;
      "TXPLLREFCLK_DIV2" : TXOUTCLK_CTRL_BINARY = 3'b100;
      default : begin
        $display("Attribute Syntax Error : The Attribute TXOUTCLK_CTRL on GTXE1 instance %m is set to %s.  Legal values for this attribute are TXOUTCLKPCS, TXOUTCLKPMA_DIV1, TXOUTCLKPMA_DIV2, TXPLLREFCLK_DIV1, or TXPLLREFCLK_DIV2.", TXOUTCLK_CTRL);
        $finish;
      end
    endcase

    case (TXPLL_DIVSEL45_FB)
      5 : TXPLL_DIVSEL45_FB_BINARY = 1'b1;
      4 : TXPLL_DIVSEL45_FB_BINARY = 1'b0;
      default : begin
        $display("Attribute Syntax Error : The Attribute TXPLL_DIVSEL45_FB on GTXE1 instance %m is set to %d.  Legal values for this attribute are 4 to 5.", TXPLL_DIVSEL45_FB, 5);
        $finish;
      end
    endcase

    case (TXPLL_DIVSEL_FB)
      2 : TXPLL_DIVSEL_FB_BINARY = 5'b00000;
      1 : TXPLL_DIVSEL_FB_BINARY = 5'b10000;
      3 : TXPLL_DIVSEL_FB_BINARY = 5'b00001;
      4 : TXPLL_DIVSEL_FB_BINARY = 5'b00010;
      5 : TXPLL_DIVSEL_FB_BINARY = 5'b00011;
      6 : TXPLL_DIVSEL_FB_BINARY = 5'b00101;
      8 : TXPLL_DIVSEL_FB_BINARY = 5'b00110;
      10 : TXPLL_DIVSEL_FB_BINARY = 5'b00111;
      12 : TXPLL_DIVSEL_FB_BINARY = 5'b01101;
      16 : TXPLL_DIVSEL_FB_BINARY = 5'b01110;
      20 : TXPLL_DIVSEL_FB_BINARY = 5'b01111;
      default : begin
        $display("Attribute Syntax Error : The Attribute TXPLL_DIVSEL_FB on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 20.", TXPLL_DIVSEL_FB, 2);
        $finish;
      end
    endcase

    case (TXPLL_DIVSEL_OUT)
      1 : TXPLL_DIVSEL_OUT_BINARY = 2'b00;
      2 : TXPLL_DIVSEL_OUT_BINARY = 2'b01;
      4 : TXPLL_DIVSEL_OUT_BINARY = 2'b10;
      default : begin
        $display("Attribute Syntax Error : The Attribute TXPLL_DIVSEL_OUT on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 4.", TXPLL_DIVSEL_OUT, 1);
        $finish;
      end
    endcase

    case (TXPLL_DIVSEL_REF)
      1 : TXPLL_DIVSEL_REF_BINARY = 5'b10000;
      2 : TXPLL_DIVSEL_REF_BINARY = 5'b00000;
      3 : TXPLL_DIVSEL_REF_BINARY = 5'b00001;
      4 : TXPLL_DIVSEL_REF_BINARY = 5'b00010;
      5 : TXPLL_DIVSEL_REF_BINARY = 5'b00011;
      6 : TXPLL_DIVSEL_REF_BINARY = 5'b00101;
      8 : TXPLL_DIVSEL_REF_BINARY = 5'b00110;
      10 : TXPLL_DIVSEL_REF_BINARY = 5'b00111;
      12 : TXPLL_DIVSEL_REF_BINARY = 5'b01101;
      16 : TXPLL_DIVSEL_REF_BINARY = 5'b01110;
      20 : TXPLL_DIVSEL_REF_BINARY = 5'b01111;
      default : begin
        $display("Attribute Syntax Error : The Attribute TXPLL_DIVSEL_REF on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 20.", TXPLL_DIVSEL_REF, 1);
        $finish;
      end
    endcase

    case (TX_BUFFER_USE)
      "FALSE" : TX_BUFFER_USE_BINARY = 1'b0;
      "TRUE" : TX_BUFFER_USE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_BUFFER_USE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TX_BUFFER_USE);
        $finish;
      end
    endcase

    case (TX_CLK25_DIVIDER)
      6 : TX_CLK25_DIVIDER_BINARY = 5'b00101;
      1 : TX_CLK25_DIVIDER_BINARY = 5'b00000;
      2 : TX_CLK25_DIVIDER_BINARY = 5'b00001;
      3 : TX_CLK25_DIVIDER_BINARY = 5'b00010;
      4 : TX_CLK25_DIVIDER_BINARY = 5'b00011;
      5 : TX_CLK25_DIVIDER_BINARY = 5'b00100;
      7 : TX_CLK25_DIVIDER_BINARY = 5'b00110;
      8 : TX_CLK25_DIVIDER_BINARY = 5'b00111;
      9 : TX_CLK25_DIVIDER_BINARY = 5'b01000;
      10 : TX_CLK25_DIVIDER_BINARY = 5'b01001;
      11 : TX_CLK25_DIVIDER_BINARY = 5'b01010;
      12 : TX_CLK25_DIVIDER_BINARY = 5'b01011;
      13 : TX_CLK25_DIVIDER_BINARY = 5'b01100;
      14 : TX_CLK25_DIVIDER_BINARY = 5'b01101;
      15 : TX_CLK25_DIVIDER_BINARY = 5'b01110;
      16 : TX_CLK25_DIVIDER_BINARY = 5'b01111;
      17 : TX_CLK25_DIVIDER_BINARY = 5'b10000;
      18 : TX_CLK25_DIVIDER_BINARY = 5'b10001;
      19 : TX_CLK25_DIVIDER_BINARY = 5'b10010;
      20 : TX_CLK25_DIVIDER_BINARY = 5'b10011;
      21 : TX_CLK25_DIVIDER_BINARY = 5'b10100;
      22 : TX_CLK25_DIVIDER_BINARY = 5'b10101;
      23 : TX_CLK25_DIVIDER_BINARY = 5'b10110;
      24 : TX_CLK25_DIVIDER_BINARY = 5'b10111;
      25 : TX_CLK25_DIVIDER_BINARY = 5'b11000;
      26 : TX_CLK25_DIVIDER_BINARY = 5'b11001;
      27 : TX_CLK25_DIVIDER_BINARY = 5'b11010;
      28 : TX_CLK25_DIVIDER_BINARY = 5'b11011;
      29 : TX_CLK25_DIVIDER_BINARY = 5'b11100;
      30 : TX_CLK25_DIVIDER_BINARY = 5'b11101;
      31 : TX_CLK25_DIVIDER_BINARY = 5'b11110;
      32 : TX_CLK25_DIVIDER_BINARY = 5'b11111;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_CLK25_DIVIDER on GTXE1 instance %m is set to %d.  Legal values for this attribute are 1 to 32.", TX_CLK25_DIVIDER, 6);
        $finish;
      end
    endcase

    case (TX_CLK_SOURCE)
      "RXPLL" : TX_CLK_SOURCE_BINARY = 1'b1;
      "TXPLL" : TX_CLK_SOURCE_BINARY = 1'b0;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_CLK_SOURCE on GTXE1 instance %m is set to %s.  Legal values for this attribute are RXPLL, or TXPLL.", TX_CLK_SOURCE);
        $finish;
      end
    endcase

    case (TX_DATA_WIDTH)
      20 : TX_DATA_WIDTH_BINARY = 3'b011;
      8 : TX_DATA_WIDTH_BINARY = 3'b000;
      10 : TX_DATA_WIDTH_BINARY = 3'b001;
      16 : TX_DATA_WIDTH_BINARY = 3'b010;
      32 : TX_DATA_WIDTH_BINARY = 3'b100;
      40 : TX_DATA_WIDTH_BINARY = 3'b101;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_DATA_WIDTH on GTXE1 instance %m is set to %d.  Legal values for this attribute are 8 to 40.", TX_DATA_WIDTH, 20);
        $finish;
      end
    endcase

    case (TX_DRIVE_MODE)
      "DIRECT" : TX_DRIVE_MODE_BINARY = 1'b0;
      "PIPE" : TX_DRIVE_MODE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_DRIVE_MODE on GTXE1 instance %m is set to %s.  Legal values for this attribute are DIRECT, or PIPE.", TX_DRIVE_MODE);
        $finish;
      end
    endcase

    case (TX_EN_RATE_RESET_BUF)
      "FALSE" : TX_EN_RATE_RESET_BUF_BINARY = 1'b0;
      "TRUE" : TX_EN_RATE_RESET_BUF_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_EN_RATE_RESET_BUF on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TX_EN_RATE_RESET_BUF);
        $finish;
      end
    endcase

    case (TX_OVERSAMPLE_MODE)
      "FALSE" : TX_OVERSAMPLE_MODE_BINARY = 1'b0;
      "TRUE" : TX_OVERSAMPLE_MODE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_OVERSAMPLE_MODE on GTXE1 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TX_OVERSAMPLE_MODE);
        $finish;
      end
    endcase

    case (TX_XCLK_SEL)
      "TXUSR" : TX_XCLK_SEL_BINARY = 1'b1;
      "TXOUT" : TX_XCLK_SEL_BINARY = 1'b0;
      default : begin
        $display("Attribute Syntax Error : The Attribute TX_XCLK_SEL on GTXE1 instance %m is set to %s.  Legal values for this attribute are TXUSR, or TXOUT.", TX_XCLK_SEL);
        $finish;
      end
    endcase

    if ((BGTEST_CFG >= 0) && (BGTEST_CFG <= 3))
      BGTEST_CFG_BINARY = BGTEST_CFG;
    else begin
      $display("Attribute Syntax Error : The Attribute BGTEST_CFG on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 3.", BGTEST_CFG);
      $finish;
    end

    if ((CDR_PH_ADJ_TIME >= 0) && (CDR_PH_ADJ_TIME <= 31))
      CDR_PH_ADJ_TIME_BINARY = CDR_PH_ADJ_TIME;
    else begin
      $display("Attribute Syntax Error : The Attribute CDR_PH_ADJ_TIME on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 31.", CDR_PH_ADJ_TIME);
      $finish;
    end

    if ((CHAN_BOND_1_MAX_SKEW >= 1) && (CHAN_BOND_1_MAX_SKEW <= 14))
      CHAN_BOND_1_MAX_SKEW_BINARY = CHAN_BOND_1_MAX_SKEW;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_1_MAX_SKEW on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 14.", CHAN_BOND_1_MAX_SKEW);
      $finish;
    end

    if ((CHAN_BOND_2_MAX_SKEW >= 1) && (CHAN_BOND_2_MAX_SKEW <= 14))
      CHAN_BOND_2_MAX_SKEW_BINARY = CHAN_BOND_2_MAX_SKEW;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_2_MAX_SKEW on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 14.", CHAN_BOND_2_MAX_SKEW);
      $finish;
    end

    if ((CHAN_BOND_SEQ_1_1 >= 0) && (CHAN_BOND_SEQ_1_1 <= 1023))
      CHAN_BOND_SEQ_1_1_BINARY = CHAN_BOND_SEQ_1_1;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_1_1 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CHAN_BOND_SEQ_1_1);
      $finish;
    end

    if ((CHAN_BOND_SEQ_1_2 >= 0) && (CHAN_BOND_SEQ_1_2 <= 1023))
      CHAN_BOND_SEQ_1_2_BINARY = CHAN_BOND_SEQ_1_2;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_1_2 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CHAN_BOND_SEQ_1_2);
      $finish;
    end

    if ((CHAN_BOND_SEQ_1_3 >= 0) && (CHAN_BOND_SEQ_1_3 <= 1023))
      CHAN_BOND_SEQ_1_3_BINARY = CHAN_BOND_SEQ_1_3;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_1_3 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CHAN_BOND_SEQ_1_3);
      $finish;
    end

    if ((CHAN_BOND_SEQ_1_4 >= 0) && (CHAN_BOND_SEQ_1_4 <= 1023))
      CHAN_BOND_SEQ_1_4_BINARY = CHAN_BOND_SEQ_1_4;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_1_4 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CHAN_BOND_SEQ_1_4);
      $finish;
    end

    if ((CHAN_BOND_SEQ_1_ENABLE >= 0) && (CHAN_BOND_SEQ_1_ENABLE <= 15))
      CHAN_BOND_SEQ_1_ENABLE_BINARY = CHAN_BOND_SEQ_1_ENABLE;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_1_ENABLE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", CHAN_BOND_SEQ_1_ENABLE);
      $finish;
    end

    if ((CHAN_BOND_SEQ_2_1 >= 0) && (CHAN_BOND_SEQ_2_1 <= 1023))
      CHAN_BOND_SEQ_2_1_BINARY = CHAN_BOND_SEQ_2_1;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_2_1 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CHAN_BOND_SEQ_2_1);
      $finish;
    end

    if ((CHAN_BOND_SEQ_2_2 >= 0) && (CHAN_BOND_SEQ_2_2 <= 1023))
      CHAN_BOND_SEQ_2_2_BINARY = CHAN_BOND_SEQ_2_2;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_2_2 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CHAN_BOND_SEQ_2_2);
      $finish;
    end

    if ((CHAN_BOND_SEQ_2_3 >= 0) && (CHAN_BOND_SEQ_2_3 <= 1023))
      CHAN_BOND_SEQ_2_3_BINARY = CHAN_BOND_SEQ_2_3;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_2_3 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CHAN_BOND_SEQ_2_3);
      $finish;
    end

    if ((CHAN_BOND_SEQ_2_4 >= 0) && (CHAN_BOND_SEQ_2_4 <= 1023))
      CHAN_BOND_SEQ_2_4_BINARY = CHAN_BOND_SEQ_2_4;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_2_4 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CHAN_BOND_SEQ_2_4);
      $finish;
    end

    if ((CHAN_BOND_SEQ_2_CFG >= 0) && (CHAN_BOND_SEQ_2_CFG <= 31))
      CHAN_BOND_SEQ_2_CFG_BINARY = CHAN_BOND_SEQ_2_CFG;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_2_CFG on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 31.", CHAN_BOND_SEQ_2_CFG);
      $finish;
    end

    if ((CHAN_BOND_SEQ_2_ENABLE >= 0) && (CHAN_BOND_SEQ_2_ENABLE <= 15))
      CHAN_BOND_SEQ_2_ENABLE_BINARY = CHAN_BOND_SEQ_2_ENABLE;
    else begin
      $display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_2_ENABLE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", CHAN_BOND_SEQ_2_ENABLE);
      $finish;
    end

    if ((CLK_COR_MAX_LAT >= 3) && (CLK_COR_MAX_LAT <= 48))
      CLK_COR_MAX_LAT_BINARY = CLK_COR_MAX_LAT;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_MAX_LAT on GTXE1 instance %m is set to %d.  Legal values for this attribute are  3 to 48.", CLK_COR_MAX_LAT);
      $finish;
    end

    if ((CLK_COR_MIN_LAT >= 3) && (CLK_COR_MIN_LAT <= 48))
      CLK_COR_MIN_LAT_BINARY = CLK_COR_MIN_LAT;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_MIN_LAT on GTXE1 instance %m is set to %d.  Legal values for this attribute are  3 to 48.", CLK_COR_MIN_LAT);
      $finish;
    end

    if ((CLK_COR_REPEAT_WAIT >= 0) && (CLK_COR_REPEAT_WAIT <= 31))
      CLK_COR_REPEAT_WAIT_BINARY = CLK_COR_REPEAT_WAIT;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_REPEAT_WAIT on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 31.", CLK_COR_REPEAT_WAIT);
      $finish;
    end

    if ((CLK_COR_SEQ_1_1 >= 0) && (CLK_COR_SEQ_1_1 <= 1023))
      CLK_COR_SEQ_1_1_BINARY = CLK_COR_SEQ_1_1;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_1_1 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CLK_COR_SEQ_1_1);
      $finish;
    end

    if ((CLK_COR_SEQ_1_2 >= 0) && (CLK_COR_SEQ_1_2 <= 1023))
      CLK_COR_SEQ_1_2_BINARY = CLK_COR_SEQ_1_2;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_1_2 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CLK_COR_SEQ_1_2);
      $finish;
    end

    if ((CLK_COR_SEQ_1_3 >= 0) && (CLK_COR_SEQ_1_3 <= 1023))
      CLK_COR_SEQ_1_3_BINARY = CLK_COR_SEQ_1_3;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_1_3 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CLK_COR_SEQ_1_3);
      $finish;
    end

    if ((CLK_COR_SEQ_1_4 >= 0) && (CLK_COR_SEQ_1_4 <= 1023))
      CLK_COR_SEQ_1_4_BINARY = CLK_COR_SEQ_1_4;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_1_4 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CLK_COR_SEQ_1_4);
      $finish;
    end

    if ((CLK_COR_SEQ_1_ENABLE >= 0) && (CLK_COR_SEQ_1_ENABLE <= 15))
      CLK_COR_SEQ_1_ENABLE_BINARY = CLK_COR_SEQ_1_ENABLE;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_1_ENABLE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", CLK_COR_SEQ_1_ENABLE);
      $finish;
    end

    if ((CLK_COR_SEQ_2_1 >= 0) && (CLK_COR_SEQ_2_1 <= 1023))
      CLK_COR_SEQ_2_1_BINARY = CLK_COR_SEQ_2_1;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_2_1 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CLK_COR_SEQ_2_1);
      $finish;
    end

    if ((CLK_COR_SEQ_2_2 >= 0) && (CLK_COR_SEQ_2_2 <= 1023))
      CLK_COR_SEQ_2_2_BINARY = CLK_COR_SEQ_2_2;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_2_2 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CLK_COR_SEQ_2_2);
      $finish;
    end

    if ((CLK_COR_SEQ_2_3 >= 0) && (CLK_COR_SEQ_2_3 <= 1023))
      CLK_COR_SEQ_2_3_BINARY = CLK_COR_SEQ_2_3;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_2_3 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CLK_COR_SEQ_2_3);
      $finish;
    end

    if ((CLK_COR_SEQ_2_4 >= 0) && (CLK_COR_SEQ_2_4 <= 1023))
      CLK_COR_SEQ_2_4_BINARY = CLK_COR_SEQ_2_4;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_2_4 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", CLK_COR_SEQ_2_4);
      $finish;
    end

    if ((CLK_COR_SEQ_2_ENABLE >= 0) && (CLK_COR_SEQ_2_ENABLE <= 15))
      CLK_COR_SEQ_2_ENABLE_BINARY = CLK_COR_SEQ_2_ENABLE;
    else begin
      $display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_2_ENABLE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", CLK_COR_SEQ_2_ENABLE);
      $finish;
    end

    if ((CM_TRIM >= 0) && (CM_TRIM <= 3))
      CM_TRIM_BINARY = CM_TRIM;
    else begin
      $display("Attribute Syntax Error : The Attribute CM_TRIM on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 3.", CM_TRIM);
      $finish;
    end

    if ((COMMA_10B_ENABLE >= 0) && (COMMA_10B_ENABLE <= 1023))
      COMMA_10B_ENABLE_BINARY = COMMA_10B_ENABLE;
    else begin
      $display("Attribute Syntax Error : The Attribute COMMA_10B_ENABLE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", COMMA_10B_ENABLE);
      $finish;
    end

    if ((COM_BURST_VAL >= 0) && (COM_BURST_VAL <= 15))
      COM_BURST_VAL_BINARY = COM_BURST_VAL;
    else begin
      $display("Attribute Syntax Error : The Attribute COM_BURST_VAL on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", COM_BURST_VAL);
      $finish;
    end

    if ((DFE_CAL_TIME >= 0) && (DFE_CAL_TIME <= 31))
      DFE_CAL_TIME_BINARY = DFE_CAL_TIME;
    else begin
      $display("Attribute Syntax Error : The Attribute DFE_CAL_TIME on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 31.", DFE_CAL_TIME);
      $finish;
    end

    if ((DFE_CFG >= 0) && (DFE_CFG <= 255))
      DFE_CFG_BINARY = DFE_CFG;
    else begin
      $display("Attribute Syntax Error : The Attribute DFE_CFG on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 255.", DFE_CFG);
      $finish;
    end

    if ((GEARBOX_ENDEC >= 0) && (GEARBOX_ENDEC <= 7))
      GEARBOX_ENDEC_BINARY = GEARBOX_ENDEC;
    else begin
      $display("Attribute Syntax Error : The Attribute GEARBOX_ENDEC on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", GEARBOX_ENDEC);
      $finish;
    end

    if ((MCOMMA_10B_VALUE >= 0) && (MCOMMA_10B_VALUE <= 1023))
      MCOMMA_10B_VALUE_BINARY = MCOMMA_10B_VALUE;
    else begin
      $display("Attribute Syntax Error : The Attribute MCOMMA_10B_VALUE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", MCOMMA_10B_VALUE);
      $finish;
    end

    if ((OOBDETECT_THRESHOLD >= 0) && (OOBDETECT_THRESHOLD <= 7))
      OOBDETECT_THRESHOLD_BINARY = OOBDETECT_THRESHOLD;
    else begin
      $display("Attribute Syntax Error : The Attribute OOBDETECT_THRESHOLD on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", OOBDETECT_THRESHOLD);
      $finish;
    end

    if ((PCOMMA_10B_VALUE >= 0) && (PCOMMA_10B_VALUE <= 1023))
      PCOMMA_10B_VALUE_BINARY = PCOMMA_10B_VALUE;
    else begin
      $display("Attribute Syntax Error : The Attribute PCOMMA_10B_VALUE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", PCOMMA_10B_VALUE);
      $finish;
    end

    if ((POWER_SAVE >= 0) && (POWER_SAVE <= 1023))
      POWER_SAVE_BINARY = POWER_SAVE;
    else begin
      $display("Attribute Syntax Error : The Attribute POWER_SAVE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", POWER_SAVE);
      $finish;
    end

    if ((RXPLL_LKDET_CFG >= 0) && (RXPLL_LKDET_CFG <= 7))
      RXPLL_LKDET_CFG_BINARY = RXPLL_LKDET_CFG;
    else begin
      $display("Attribute Syntax Error : The Attribute RXPLL_LKDET_CFG on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", RXPLL_LKDET_CFG);
      $finish;
    end
    
    if ((RXPRBSERR_LOOPBACK >= 0) && (RXPRBSERR_LOOPBACK <= 1))
      RXPRBSERR_LOOPBACK_BINARY = RXPRBSERR_LOOPBACK;
    else begin
      $display("Attribute Syntax Error : The Attribute RXPRBSERR_LOOPBACK on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1.", RXPRBSERR_LOOPBACK);
      $finish;
    end
     
    if ((RXRECCLK_DLY >= 0) && (RXRECCLK_DLY <= 1023))
      RXRECCLK_DLY_BINARY = RXRECCLK_DLY;
    else begin
      $display("Attribute Syntax Error : The Attribute RXRECCLK_DLY on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", RXRECCLK_DLY);
      $finish;
    end

    if ((RX_DLYALIGN_CTRINC >= 0) && (RX_DLYALIGN_CTRINC <= 15))
      RX_DLYALIGN_CTRINC_BINARY = RX_DLYALIGN_CTRINC;
    else begin
      $display("Attribute Syntax Error : The Attribute RX_DLYALIGN_CTRINC on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", RX_DLYALIGN_CTRINC);
      $finish;
    end

    if ((RX_DLYALIGN_EDGESET >= 0) && (RX_DLYALIGN_EDGESET <= 31))
      RX_DLYALIGN_EDGESET_BINARY = RX_DLYALIGN_EDGESET;
    else begin
      $display("Attribute Syntax Error : The Attribute RX_DLYALIGN_EDGESET on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 31.", RX_DLYALIGN_EDGESET);
      $finish;
    end

    if ((RX_DLYALIGN_LPFINC >= 0) && (RX_DLYALIGN_LPFINC <= 15))
      RX_DLYALIGN_LPFINC_BINARY = RX_DLYALIGN_LPFINC;
    else begin
      $display("Attribute Syntax Error : The Attribute RX_DLYALIGN_LPFINC on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", RX_DLYALIGN_LPFINC);
      $finish;
    end

    if ((RX_DLYALIGN_MONSEL >= 0) && (RX_DLYALIGN_MONSEL <= 7))
      RX_DLYALIGN_MONSEL_BINARY = RX_DLYALIGN_MONSEL;
    else begin
      $display("Attribute Syntax Error : The Attribute RX_DLYALIGN_MONSEL on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", RX_DLYALIGN_MONSEL);
      $finish;
    end

    if ((RX_DLYALIGN_OVRDSETTING >= 0) && (RX_DLYALIGN_OVRDSETTING <= 255))
      RX_DLYALIGN_OVRDSETTING_BINARY = RX_DLYALIGN_OVRDSETTING;
    else begin
      $display("Attribute Syntax Error : The Attribute RX_DLYALIGN_OVRDSETTING on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 255.", RX_DLYALIGN_OVRDSETTING);
      $finish;
    end

    if ((RX_EYE_SCANMODE >= 0) && (RX_EYE_SCANMODE <= 3))
      RX_EYE_SCANMODE_BINARY = RX_EYE_SCANMODE;
    else begin
      $display("Attribute Syntax Error : The Attribute RX_EYE_SCANMODE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 3.", RX_EYE_SCANMODE);
      $finish;
    end

    if ((RX_IDLE_HI_CNT >= 0) && (RX_IDLE_HI_CNT <= 15))
      RX_IDLE_HI_CNT_BINARY = RX_IDLE_HI_CNT;
    else begin
      $display("Attribute Syntax Error : The Attribute RX_IDLE_HI_CNT on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", RX_IDLE_HI_CNT);
      $finish;
    end

    if ((RX_IDLE_LO_CNT >= 0) && (RX_IDLE_LO_CNT <= 15))
      RX_IDLE_LO_CNT_BINARY = RX_IDLE_LO_CNT;
    else begin
      $display("Attribute Syntax Error : The Attribute RX_IDLE_LO_CNT on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", RX_IDLE_LO_CNT);
      $finish;
    end

    if ((RX_SLIDE_AUTO_WAIT >= 0) && (RX_SLIDE_AUTO_WAIT <= 15))
      RX_SLIDE_AUTO_WAIT_BINARY = RX_SLIDE_AUTO_WAIT;
    else begin
      $display("Attribute Syntax Error : The Attribute RX_SLIDE_AUTO_WAIT on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", RX_SLIDE_AUTO_WAIT);
      $finish;
    end

    if ((SAS_MAX_COMSAS >= 1) && (SAS_MAX_COMSAS <= 61))
      SAS_MAX_COMSAS_BINARY = SAS_MAX_COMSAS;
    else begin
      $display("Attribute Syntax Error : The Attribute SAS_MAX_COMSAS on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 61.", SAS_MAX_COMSAS);
      $finish;
    end

    if ((SAS_MIN_COMSAS >= 1) && (SAS_MIN_COMSAS <= 61))
      SAS_MIN_COMSAS_BINARY = SAS_MIN_COMSAS;
    else begin
      $display("Attribute Syntax Error : The Attribute SAS_MIN_COMSAS on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 61.", SAS_MIN_COMSAS);
      $finish;
    end

    if ((SATA_BURST_VAL >= 0) && (SATA_BURST_VAL <= 7))
      SATA_BURST_VAL_BINARY = SATA_BURST_VAL;
    else begin
      $display("Attribute Syntax Error : The Attribute SATA_BURST_VAL on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", SATA_BURST_VAL);
      $finish;
    end

    if ((SATA_IDLE_VAL >= 0) && (SATA_IDLE_VAL <= 7))
      SATA_IDLE_VAL_BINARY = SATA_IDLE_VAL;
    else begin
      $display("Attribute Syntax Error : The Attribute SATA_IDLE_VAL on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", SATA_IDLE_VAL);
      $finish;
    end

    if ((SATA_MAX_BURST >= 1) && (SATA_MAX_BURST <= 61))
      SATA_MAX_BURST_BINARY = SATA_MAX_BURST;
    else begin
      $display("Attribute Syntax Error : The Attribute SATA_MAX_BURST on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 61.", SATA_MAX_BURST);
      $finish;
    end

    if ((SATA_MAX_INIT >= 1) && (SATA_MAX_INIT <= 61))
      SATA_MAX_INIT_BINARY = SATA_MAX_INIT;
    else begin
      $display("Attribute Syntax Error : The Attribute SATA_MAX_INIT on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 61.", SATA_MAX_INIT);
      $finish;
    end

    if ((SATA_MAX_WAKE >= 1) && (SATA_MAX_WAKE <= 61))
      SATA_MAX_WAKE_BINARY = SATA_MAX_WAKE;
    else begin
      $display("Attribute Syntax Error : The Attribute SATA_MAX_WAKE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 61.", SATA_MAX_WAKE);
      $finish;
    end

    if ((SATA_MIN_BURST >= 1) && (SATA_MIN_BURST <= 61))
      SATA_MIN_BURST_BINARY = SATA_MIN_BURST;
    else begin
      $display("Attribute Syntax Error : The Attribute SATA_MIN_BURST on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 61.", SATA_MIN_BURST);
      $finish;
    end

    if ((SATA_MIN_INIT >= 1) && (SATA_MIN_INIT <= 61))
      SATA_MIN_INIT_BINARY = SATA_MIN_INIT;
    else begin
      $display("Attribute Syntax Error : The Attribute SATA_MIN_INIT on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 61.", SATA_MIN_INIT);
      $finish;
    end

    if ((SATA_MIN_WAKE >= 1) && (SATA_MIN_WAKE <= 61))
      SATA_MIN_WAKE_BINARY = SATA_MIN_WAKE;
    else begin
      $display("Attribute Syntax Error : The Attribute SATA_MIN_WAKE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  1 to 61.", SATA_MIN_WAKE);
      $finish;
    end

    if ((SIM_RXREFCLK_SOURCE >= 0) && (SIM_RXREFCLK_SOURCE <= 7))
      SIM_RXREFCLK_SOURCE_BINARY = SIM_RXREFCLK_SOURCE;
    else begin
      $display("Attribute Syntax Error : The Attribute SIM_RXREFCLK_SOURCE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", SIM_RXREFCLK_SOURCE);
      $finish;
    end

    if ((SIM_TXREFCLK_SOURCE >= 0) && (SIM_TXREFCLK_SOURCE <= 7))
      SIM_TXREFCLK_SOURCE_BINARY = SIM_TXREFCLK_SOURCE;
    else begin
      $display("Attribute Syntax Error : The Attribute SIM_TXREFCLK_SOURCE on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", SIM_TXREFCLK_SOURCE);
      $finish;
    end

    if ((TERMINATION_CTRL >= 0) && (TERMINATION_CTRL <= 31))
      TERMINATION_CTRL_BINARY = TERMINATION_CTRL;
    else begin
      $display("Attribute Syntax Error : The Attribute TERMINATION_CTRL on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 31.", TERMINATION_CTRL);
      $finish;
    end

    if ((TXOUTCLK_DLY >= 0) && (TXOUTCLK_DLY <= 1023))
      TXOUTCLK_DLY_BINARY = TXOUTCLK_DLY;
    else begin
      $display("Attribute Syntax Error : The Attribute TXOUTCLK_DLY on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1023.", TXOUTCLK_DLY);
      $finish;
    end

    if ((TXPLL_LKDET_CFG >= 0) && (TXPLL_LKDET_CFG <= 7))
      TXPLL_LKDET_CFG_BINARY = TXPLL_LKDET_CFG;
    else begin
      $display("Attribute Syntax Error : The Attribute TXPLL_LKDET_CFG on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", TXPLL_LKDET_CFG);
      $finish;
    end

    if ((TXPLL_SATA >= 0) && (TXPLL_SATA <= 3))
      TXPLL_SATA_BINARY = TXPLL_SATA;
    else begin
      $display("Attribute Syntax Error : The Attribute TXPLL_SATA on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 3.", TXPLL_SATA);
      $finish;
    end

    if ((TX_DEEMPH_0 >= 0) && (TX_DEEMPH_0 <= 31))
      TX_DEEMPH_0_BINARY = TX_DEEMPH_0;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_DEEMPH_0 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 31.", TX_DEEMPH_0);
      $finish;
    end

    if ((TX_DEEMPH_1 >= 0) && (TX_DEEMPH_1 <= 31))
      TX_DEEMPH_1_BINARY = TX_DEEMPH_1;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_DEEMPH_1 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 31.", TX_DEEMPH_1);
      $finish;
    end

    if ((TX_DLYALIGN_CTRINC >= 0) && (TX_DLYALIGN_CTRINC <= 15))
      TX_DLYALIGN_CTRINC_BINARY = TX_DLYALIGN_CTRINC;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_DLYALIGN_CTRINC on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", TX_DLYALIGN_CTRINC);
      $finish;
    end

    if ((TX_DLYALIGN_LPFINC >= 0) && (TX_DLYALIGN_LPFINC <= 15))
      TX_DLYALIGN_LPFINC_BINARY = TX_DLYALIGN_LPFINC;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_DLYALIGN_LPFINC on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 15.", TX_DLYALIGN_LPFINC);
      $finish;
    end

    if ((TX_DLYALIGN_MONSEL >= 0) && (TX_DLYALIGN_MONSEL <= 7))
      TX_DLYALIGN_MONSEL_BINARY = TX_DLYALIGN_MONSEL;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_DLYALIGN_MONSEL on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", TX_DLYALIGN_MONSEL);
      $finish;
    end

    if ((TX_DLYALIGN_OVRDSETTING >= 0) && (TX_DLYALIGN_OVRDSETTING <= 255))
      TX_DLYALIGN_OVRDSETTING_BINARY = TX_DLYALIGN_OVRDSETTING;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_DLYALIGN_OVRDSETTING on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 255.", TX_DLYALIGN_OVRDSETTING);
      $finish;
    end

    if ((TX_IDLE_ASSERT_DELAY >= 0) && (TX_IDLE_ASSERT_DELAY <= 7))
      TX_IDLE_ASSERT_DELAY_BINARY = TX_IDLE_ASSERT_DELAY;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_IDLE_ASSERT_DELAY on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", TX_IDLE_ASSERT_DELAY);
      $finish;
    end

    if ((TX_IDLE_DEASSERT_DELAY >= 0) && (TX_IDLE_DEASSERT_DELAY <= 7))
      TX_IDLE_DEASSERT_DELAY_BINARY = TX_IDLE_DEASSERT_DELAY;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_IDLE_DEASSERT_DELAY on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 7.", TX_IDLE_DEASSERT_DELAY);
      $finish;
    end

    if ((TX_MARGIN_FULL_0 >= 0) && (TX_MARGIN_FULL_0 <= 127))
      TX_MARGIN_FULL_0_BINARY = TX_MARGIN_FULL_0;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_FULL_0 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_FULL_0);
      $finish;
    end

    if ((TX_MARGIN_FULL_1 >= 0) && (TX_MARGIN_FULL_1 <= 127))
      TX_MARGIN_FULL_1_BINARY = TX_MARGIN_FULL_1;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_FULL_1 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_FULL_1);
      $finish;
    end

    if ((TX_MARGIN_FULL_2 >= 0) && (TX_MARGIN_FULL_2 <= 127))
      TX_MARGIN_FULL_2_BINARY = TX_MARGIN_FULL_2;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_FULL_2 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_FULL_2);
      $finish;
    end

    if ((TX_MARGIN_FULL_3 >= 0) && (TX_MARGIN_FULL_3 <= 127))
      TX_MARGIN_FULL_3_BINARY = TX_MARGIN_FULL_3;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_FULL_3 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_FULL_3);
      $finish;
    end

    if ((TX_MARGIN_FULL_4 >= 0) && (TX_MARGIN_FULL_4 <= 127))
      TX_MARGIN_FULL_4_BINARY = TX_MARGIN_FULL_4;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_FULL_4 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_FULL_4);
      $finish;
    end

    if ((TX_MARGIN_LOW_0 >= 0) && (TX_MARGIN_LOW_0 <= 127))
      TX_MARGIN_LOW_0_BINARY = TX_MARGIN_LOW_0;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_LOW_0 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_LOW_0);
      $finish;
    end

    if ((TX_MARGIN_LOW_1 >= 0) && (TX_MARGIN_LOW_1 <= 127))
      TX_MARGIN_LOW_1_BINARY = TX_MARGIN_LOW_1;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_LOW_1 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_LOW_1);
      $finish;
    end

    if ((TX_MARGIN_LOW_2 >= 0) && (TX_MARGIN_LOW_2 <= 127))
      TX_MARGIN_LOW_2_BINARY = TX_MARGIN_LOW_2;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_LOW_2 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_LOW_2);
      $finish;
    end

    if ((TX_MARGIN_LOW_3 >= 0) && (TX_MARGIN_LOW_3 <= 127))
      TX_MARGIN_LOW_3_BINARY = TX_MARGIN_LOW_3;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_LOW_3 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_LOW_3);
      $finish;
    end

    if ((TX_MARGIN_LOW_4 >= 0) && (TX_MARGIN_LOW_4 <= 127))
      TX_MARGIN_LOW_4_BINARY = TX_MARGIN_LOW_4;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_MARGIN_LOW_4 on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 127.", TX_MARGIN_LOW_4);
      $finish;
    end

    if ((TX_PMADATA_OPT >= 0) && (TX_PMADATA_OPT <= 1))
      TX_PMADATA_OPT_BINARY = TX_PMADATA_OPT;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_PMADATA_OPT on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 1.", TX_PMADATA_OPT);
      $finish;
    end

    if ((TX_TDCC_CFG >= 0) && (TX_TDCC_CFG <= 3))
      TX_TDCC_CFG_BINARY = TX_TDCC_CFG;
    else begin
      $display("Attribute Syntax Error : The Attribute TX_TDCC_CFG on GTXE1 instance %m is set to %d.  Legal values for this attribute are  0 to 3.", TX_TDCC_CFG);
      $finish;
    end

  end

  wire [15:0] delay_DRPDO;
  wire [1:0] delay_MGTREFCLKFAB;
  wire [1:0] delay_RXLOSSOFSYNC;
  wire [1:0] delay_TXBUFSTATUS;
  wire [2:0] delay_DFESENSCAL;
  wire [2:0] delay_RXBUFSTATUS;
  wire [2:0] delay_RXCLKCORCNT;
  wire [2:0] delay_RXHEADER;
  wire [2:0] delay_RXSTATUS;
  wire [31:0] delay_RXDATA;
  wire [3:0] delay_DFETAP3MONITOR;
  wire [3:0] delay_DFETAP4MONITOR;
  wire [3:0] delay_RXCHARISCOMMA;
  wire [3:0] delay_RXCHARISK;
  wire [3:0] delay_RXCHBONDO;
  wire [3:0] delay_RXDISPERR;
  wire [3:0] delay_RXNOTINTABLE;
  wire [3:0] delay_RXRUNDISP;
  wire [3:0] delay_TXKERR;
  wire [3:0] delay_TXRUNDISP;
  wire [4:0] delay_DFEEYEDACMON;
  wire [4:0] delay_DFETAP1MONITOR;
  wire [4:0] delay_DFETAP2MONITOR;
  wire [5:0] delay_DFECLKDLYADJMON;
  wire [7:0] delay_RXDLYALIGNMONITOR;
  wire [7:0] delay_TXDLYALIGNMONITOR;
  wire [9:0] delay_TSTOUT;
  wire delay_COMFINISH;
  wire delay_COMINITDET;
  wire delay_COMSASDET;
  wire delay_COMWAKEDET;
  wire delay_DRDY;
  wire delay_PHYSTATUS;
  wire delay_RXBYTEISALIGNED;
  wire delay_RXBYTEREALIGN;
  wire delay_RXCHANBONDSEQ;
  wire delay_RXCHANISALIGNED;
  wire delay_RXCHANREALIGN;
  wire delay_RXCOMMADET;
  wire delay_RXDATAVALID;
  wire delay_RXELECIDLE;
  wire delay_RXHEADERVALID;
  wire delay_RXOVERSAMPLEERR;
  wire delay_RXPLLLKDET;
  wire delay_RXPRBSERR;
  wire delay_RXRATEDONE;
  wire delay_RXRECCLK;
  wire delay_RXRECCLKPCS;
  wire delay_RXRESETDONE;
  wire delay_RXSTARTOFSEQ;
  wire delay_RXVALID;
  wire delay_TXGEARBOXREADY;
  wire delay_TXN;
  wire delay_TXOUTCLK;
  wire delay_TXOUTCLKPCS;
  wire delay_TXP;
  wire delay_TXPLLLKDET;
  wire delay_TXRATEDONE;
  wire delay_TXRESETDONE;

  wire [12:0] delay_GTXTEST;
  wire [15:0] delay_DI;
  wire [19:0] delay_TSTIN;
  wire [1:0] delay_MGTREFCLKRX;
  wire [1:0] delay_MGTREFCLKTX;
  wire [1:0] delay_NORTHREFCLKRX;
  wire [1:0] delay_NORTHREFCLKTX;
  wire [1:0] delay_RXPOWERDOWN;
  wire [1:0] delay_RXRATE;
  wire [1:0] delay_SOUTHREFCLKRX;
  wire [1:0] delay_SOUTHREFCLKTX;
  wire [1:0] delay_TXPOWERDOWN;
  wire [1:0] delay_TXRATE;
  wire [2:0] delay_LOOPBACK;
  wire [2:0] delay_RXCHBONDLEVEL;
  wire [2:0] delay_RXENPRBSTST;
  wire [2:0] delay_RXPLLREFSELDY;
  wire [2:0] delay_TXBUFDIFFCTRL;
  wire [2:0] delay_TXENPRBSTST;
  wire [2:0] delay_TXHEADER;
  wire [2:0] delay_TXMARGIN;
  wire [2:0] delay_TXPLLREFSELDY;
  wire [31:0] delay_TXDATA;
  wire [3:0] delay_DFETAP3;
  wire [3:0] delay_DFETAP4;
  wire [3:0] delay_RXCHBONDI;
  wire [3:0] delay_TXBYPASS8B10B;
  wire [3:0] delay_TXCHARDISPMODE;
  wire [3:0] delay_TXCHARDISPVAL;
  wire [3:0] delay_TXCHARISK;
  wire [3:0] delay_TXDIFFCTRL;
  wire [3:0] delay_TXPREEMPHASIS;
  wire [4:0] delay_DFETAP1;
  wire [4:0] delay_DFETAP2;
  wire [4:0] delay_TXPOSTEMPHASIS;
  wire [5:0] delay_DFECLKDLYADJ;
  wire [6:0] delay_TXSEQUENCE;
  wire [7:0] delay_DADDR;
  wire [9:0] delay_RXEQMIX;
  wire delay_DCLK;
  wire delay_DEN;
  wire delay_DFEDLYOVRD;
  wire delay_DFETAPOVRD;
  wire delay_DWE;
  wire delay_GATERXELECIDLE;
  wire delay_GREFCLKRX;
  wire delay_GREFCLKTX;
  wire delay_GTXRXRESET;
  wire delay_GTXTXRESET;
  wire delay_IGNORESIGDET;
  wire delay_PERFCLKRX;
  wire delay_PERFCLKTX;
  wire delay_PLLRXRESET;
  wire delay_PLLTXRESET;
  wire delay_PRBSCNTRESET;
  wire delay_RXBUFRESET;
  wire delay_RXCDRRESET;
  wire delay_RXCHBONDMASTER;
  wire delay_RXCHBONDSLAVE;
  wire delay_RXCOMMADETUSE;
  wire delay_RXDEC8B10BUSE;
  wire delay_RXDLYALIGNDISABLE;
  wire delay_RXDLYALIGNMONENB;
  wire delay_RXDLYALIGNOVERRIDE;
  wire delay_RXDLYALIGNRESET;
  wire delay_RXDLYALIGNSWPPRECURB;
  wire delay_RXDLYALIGNUPDSW;
  wire delay_RXENCHANSYNC;
  wire delay_RXENMCOMMAALIGN;
  wire delay_RXENPCOMMAALIGN;
  wire delay_RXENPMAPHASEALIGN;
  wire delay_RXENSAMPLEALIGN;
  wire delay_RXGEARBOXSLIP;
  wire delay_RXN;
  wire delay_RXP;
  wire delay_RXPLLLKDETEN;
  wire delay_RXPLLPOWERDOWN;
  wire delay_RXPMASETPHASE;
  wire delay_RXPOLARITY;
  wire delay_RXRESET;
  wire delay_RXSLIDE;
  wire delay_RXUSRCLK2;
  wire delay_RXUSRCLK;
  wire delay_TSTCLK0;
  wire delay_TSTCLK1;
  wire delay_TXCOMINIT;
  wire delay_TXCOMSAS;
  wire delay_TXCOMWAKE;
  wire delay_TXDEEMPH;
  wire delay_TXDETECTRX;
  wire delay_TXDLYALIGNDISABLE;
  wire delay_TXDLYALIGNMONENB;
  wire delay_TXDLYALIGNOVERRIDE;
  wire delay_TXDLYALIGNRESET;
  wire delay_TXDLYALIGNUPDSW;
  wire delay_TXELECIDLE;
  wire delay_TXENC8B10BUSE;
  wire delay_TXENPMAPHASEALIGN;
  wire delay_TXINHIBIT;
  wire delay_TXPDOWNASYNCH;
  wire delay_TXPLLLKDETEN;
  wire delay_TXPLLPOWERDOWN;
  wire delay_TXPMASETPHASE;
  wire delay_TXPOLARITY;
  wire delay_TXPRBSFORCEERR;
  wire delay_TXRESET;
  wire delay_TXSTARTSEQ;
  wire delay_TXSWING;
  wire delay_TXUSRCLK2;
  wire delay_TXUSRCLK;
  wire delay_USRCODEERR;

  assign #(OUTCLK_DELAY) MGTREFCLKFAB = delay_MGTREFCLKFAB;
  assign #(OUTCLK_DELAY) RXRECCLK = delay_RXRECCLK;
  assign #(OUTCLK_DELAY) RXRECCLKPCS = delay_RXRECCLKPCS;
  assign #(OUTCLK_DELAY) TXOUTCLK = delay_TXOUTCLK;
  assign #(OUTCLK_DELAY) TXOUTCLKPCS = delay_TXOUTCLKPCS;

  assign #(out_delay) COMFINISH = delay_COMFINISH;
  assign #(out_delay) COMINITDET = delay_COMINITDET;
  assign #(out_delay) COMSASDET = delay_COMSASDET;
  assign #(out_delay) COMWAKEDET = delay_COMWAKEDET;
  assign #(out_delay) DFECLKDLYADJMON = delay_DFECLKDLYADJMON;
  assign #(out_delay) DFEEYEDACMON = delay_DFEEYEDACMON;
  assign #(out_delay) DFESENSCAL = delay_DFESENSCAL;
  assign #(out_delay) DFETAP1MONITOR = delay_DFETAP1MONITOR;
  assign #(out_delay) DFETAP2MONITOR = delay_DFETAP2MONITOR;
  assign #(out_delay) DFETAP3MONITOR = delay_DFETAP3MONITOR;
  assign #(out_delay) DFETAP4MONITOR = delay_DFETAP4MONITOR;
  assign #(out_delay) DRDY = delay_DRDY;
  assign #(out_delay) DRPDO = delay_DRPDO;
  assign #(out_delay) PHYSTATUS = delay_PHYSTATUS;
  assign #(out_delay) RXBUFSTATUS = delay_RXBUFSTATUS;
  assign #(out_delay) RXBYTEISALIGNED = delay_RXBYTEISALIGNED;
  assign #(out_delay) RXBYTEREALIGN = delay_RXBYTEREALIGN;
  assign #(out_delay) RXCHANBONDSEQ = delay_RXCHANBONDSEQ;
  assign #(out_delay) RXCHANISALIGNED = delay_RXCHANISALIGNED;
  assign #(out_delay) RXCHANREALIGN = delay_RXCHANREALIGN;
  assign #(out_delay) RXCHARISCOMMA = delay_RXCHARISCOMMA;
  assign #(out_delay) RXCHARISK = delay_RXCHARISK;
  assign #(out_delay) RXCHBONDO = delay_RXCHBONDO;
  assign #(out_delay) RXCLKCORCNT = delay_RXCLKCORCNT;
  assign #(out_delay) RXCOMMADET = delay_RXCOMMADET;
  assign #(out_delay) RXDATA = delay_RXDATA;
  assign #(out_delay) RXDATAVALID = delay_RXDATAVALID;
  assign #(out_delay) RXDISPERR = delay_RXDISPERR;
  assign #(out_delay) RXDLYALIGNMONITOR = delay_RXDLYALIGNMONITOR;
  assign #(out_delay) RXELECIDLE = delay_RXELECIDLE;
  assign #(out_delay) RXHEADER = delay_RXHEADER;
  assign #(out_delay) RXHEADERVALID = delay_RXHEADERVALID;
  assign #(out_delay) RXLOSSOFSYNC = delay_RXLOSSOFSYNC;
  assign #(out_delay) RXNOTINTABLE = delay_RXNOTINTABLE;
  assign #(out_delay) RXOVERSAMPLEERR = delay_RXOVERSAMPLEERR;
  assign #(out_delay) RXPLLLKDET = delay_RXPLLLKDET;
  assign #(out_delay) RXPRBSERR = delay_RXPRBSERR;
  assign #(out_delay) RXRATEDONE = delay_RXRATEDONE;
  assign #(out_delay) RXRESETDONE = delay_RXRESETDONE;
  assign #(out_delay) RXRUNDISP = delay_RXRUNDISP;
  assign #(out_delay) RXSTARTOFSEQ = delay_RXSTARTOFSEQ;
  assign #(out_delay) RXSTATUS = delay_RXSTATUS;
  assign #(out_delay) RXVALID = delay_RXVALID;
  assign #(out_delay) TSTOUT = delay_TSTOUT;
  assign #(out_delay) TXBUFSTATUS = delay_TXBUFSTATUS;
  assign #(out_delay) TXDLYALIGNMONITOR = delay_TXDLYALIGNMONITOR;
  assign #(out_delay) TXGEARBOXREADY = delay_TXGEARBOXREADY;
  assign #(out_delay) TXKERR = delay_TXKERR;
  assign #(out_delay) TXN = delay_TXN;
  assign #(out_delay) TXP = delay_TXP;
  assign #(out_delay) TXPLLLKDET = delay_TXPLLLKDET;
  assign #(out_delay) TXRATEDONE = delay_TXRATEDONE;
  assign #(out_delay) TXRESETDONE = delay_TXRESETDONE;
  assign #(out_delay) TXRUNDISP = delay_TXRUNDISP;

  assign #(INCLK_DELAY) delay_DCLK = DCLK;
  assign #(INCLK_DELAY) delay_GREFCLKRX = GREFCLKRX;
  assign #(INCLK_DELAY) delay_GREFCLKTX = GREFCLKTX;
  assign #(INCLK_DELAY) delay_MGTREFCLKRX = MGTREFCLKRX;
  assign #(INCLK_DELAY) delay_MGTREFCLKTX = MGTREFCLKTX;
  assign #(INCLK_DELAY) delay_NORTHREFCLKRX = NORTHREFCLKRX;
  assign #(INCLK_DELAY) delay_NORTHREFCLKTX = NORTHREFCLKTX;
  assign #(INCLK_DELAY) delay_PERFCLKRX = PERFCLKRX;
  assign #(INCLK_DELAY) delay_PERFCLKTX = PERFCLKTX;
  assign #(INCLK_DELAY) delay_RXUSRCLK = RXUSRCLK;
  assign #(INCLK_DELAY) delay_RXUSRCLK2 = RXUSRCLK2;
  assign #(INCLK_DELAY) delay_SOUTHREFCLKRX = SOUTHREFCLKRX;
  assign #(INCLK_DELAY) delay_SOUTHREFCLKTX = SOUTHREFCLKTX;
  assign #(INCLK_DELAY) delay_TSTCLK0 = TSTCLK0;
  assign #(INCLK_DELAY) delay_TSTCLK1 = TSTCLK1;
  assign #(INCLK_DELAY) delay_TXUSRCLK = TXUSRCLK;
  assign #(INCLK_DELAY) delay_TXUSRCLK2 = TXUSRCLK2;

  assign #(in_delay) delay_DADDR = DADDR;
  assign #(in_delay) delay_DEN = DEN;
  assign #(in_delay) delay_DFECLKDLYADJ = DFECLKDLYADJ;
  assign #(in_delay) delay_DFEDLYOVRD = DFEDLYOVRD;
  assign #(in_delay) delay_DFETAP1 = DFETAP1;
  assign #(in_delay) delay_DFETAP2 = DFETAP2;
  assign #(in_delay) delay_DFETAP3 = DFETAP3;
  assign #(in_delay) delay_DFETAP4 = DFETAP4;
  assign #(in_delay) delay_DFETAPOVRD = DFETAPOVRD;
  assign #(in_delay) delay_DI = DI;
  assign #(in_delay) delay_DWE = DWE;
  assign #(in_delay) delay_GATERXELECIDLE = GATERXELECIDLE;
  assign #(in_delay) delay_GTXRXRESET = GTXRXRESET;
  assign #(in_delay) delay_GTXTEST = GTXTEST;
  assign #(in_delay) delay_GTXTXRESET = GTXTXRESET;
  assign #(in_delay) delay_IGNORESIGDET = IGNORESIGDET;
  assign #(in_delay) delay_LOOPBACK = LOOPBACK;
  assign #(in_delay) delay_PLLRXRESET = PLLRXRESET;
  assign #(in_delay) delay_PLLTXRESET = PLLTXRESET;
  assign #(in_delay) delay_PRBSCNTRESET = PRBSCNTRESET;
  assign #(in_delay) delay_RXBUFRESET = RXBUFRESET;
  assign #(in_delay) delay_RXCDRRESET = RXCDRRESET;
  assign #(in_delay) delay_RXCHBONDI = RXCHBONDI;
  assign #(in_delay) delay_RXCHBONDLEVEL = RXCHBONDLEVEL;
  assign #(in_delay) delay_RXCHBONDMASTER = RXCHBONDMASTER;
  assign #(in_delay) delay_RXCHBONDSLAVE = RXCHBONDSLAVE;
  assign #(in_delay) delay_RXCOMMADETUSE = RXCOMMADETUSE;
  assign #(in_delay) delay_RXDEC8B10BUSE = RXDEC8B10BUSE;
  assign #(in_delay) delay_RXDLYALIGNDISABLE = RXDLYALIGNDISABLE;
  assign #(in_delay) delay_RXDLYALIGNMONENB = RXDLYALIGNMONENB;
  assign #(in_delay) delay_RXDLYALIGNOVERRIDE = RXDLYALIGNOVERRIDE;
  assign #(in_delay) delay_RXDLYALIGNRESET = RXDLYALIGNRESET;
  assign #(in_delay) delay_RXDLYALIGNSWPPRECURB = RXDLYALIGNSWPPRECURB;
  assign #(in_delay) delay_RXDLYALIGNUPDSW = RXDLYALIGNUPDSW;
  assign #(in_delay) delay_RXENCHANSYNC = RXENCHANSYNC;
  assign #(in_delay) delay_RXENMCOMMAALIGN = RXENMCOMMAALIGN;
  assign #(in_delay) delay_RXENPCOMMAALIGN = RXENPCOMMAALIGN;
  assign #(in_delay) delay_RXENPMAPHASEALIGN = RXENPMAPHASEALIGN;
  assign #(in_delay) delay_RXENPRBSTST = RXENPRBSTST;
  assign #(in_delay) delay_RXENSAMPLEALIGN = RXENSAMPLEALIGN;
  assign #(in_delay) delay_RXEQMIX = RXEQMIX;
  assign #(in_delay) delay_RXGEARBOXSLIP = RXGEARBOXSLIP;
  assign #(in_delay) delay_RXN = RXN;
  assign #(in_delay) delay_RXP = RXP;
  assign #(in_delay) delay_RXPLLLKDETEN = RXPLLLKDETEN;
  assign #(in_delay) delay_RXPLLPOWERDOWN = RXPLLPOWERDOWN;
  assign #(in_delay) delay_RXPLLREFSELDY = RXPLLREFSELDY;
  assign #(in_delay) delay_RXPMASETPHASE = RXPMASETPHASE;
  assign #(in_delay) delay_RXPOLARITY = RXPOLARITY;
  assign #(in_delay) delay_RXPOWERDOWN = RXPOWERDOWN;
  assign #(in_delay) delay_RXRATE = RXRATE;
  assign #(in_delay) delay_RXRESET = RXRESET;
  assign #(in_delay) delay_RXSLIDE = RXSLIDE;
  assign #(in_delay) delay_TSTIN = TSTIN;
  assign #(in_delay) delay_TXBUFDIFFCTRL = TXBUFDIFFCTRL;
  assign #(in_delay) delay_TXBYPASS8B10B = TXBYPASS8B10B;
  assign #(in_delay) delay_TXCHARDISPMODE = TXCHARDISPMODE;
  assign #(in_delay) delay_TXCHARDISPVAL = TXCHARDISPVAL;
  assign #(in_delay) delay_TXCHARISK = TXCHARISK;
  assign #(in_delay) delay_TXCOMINIT = TXCOMINIT;
  assign #(in_delay) delay_TXCOMSAS = TXCOMSAS;
  assign #(in_delay) delay_TXCOMWAKE = TXCOMWAKE;
  assign #(in_delay) delay_TXDATA = TXDATA;
  assign #(in_delay) delay_TXDEEMPH = TXDEEMPH;
  assign #(in_delay) delay_TXDETECTRX = TXDETECTRX;
  assign #(in_delay) delay_TXDIFFCTRL = TXDIFFCTRL;
  assign #(in_delay) delay_TXDLYALIGNDISABLE = TXDLYALIGNDISABLE;
  assign #(in_delay) delay_TXDLYALIGNMONENB = TXDLYALIGNMONENB;
  assign #(in_delay) delay_TXDLYALIGNOVERRIDE = TXDLYALIGNOVERRIDE;
  assign #(in_delay) delay_TXDLYALIGNRESET = TXDLYALIGNRESET;
  assign #(in_delay) delay_TXDLYALIGNUPDSW = TXDLYALIGNUPDSW;
  assign #(in_delay) delay_TXELECIDLE = TXELECIDLE;
  assign #(in_delay) delay_TXENC8B10BUSE = TXENC8B10BUSE;
  assign #(in_delay) delay_TXENPMAPHASEALIGN = TXENPMAPHASEALIGN;
  assign #(in_delay) delay_TXENPRBSTST = TXENPRBSTST;
  assign #(in_delay) delay_TXHEADER = TXHEADER;
  assign #(in_delay) delay_TXINHIBIT = TXINHIBIT;
  assign #(in_delay) delay_TXMARGIN = TXMARGIN;
  assign #(in_delay) delay_TXPDOWNASYNCH = TXPDOWNASYNCH;
  assign #(in_delay) delay_TXPLLLKDETEN = TXPLLLKDETEN;
  assign #(in_delay) delay_TXPLLPOWERDOWN = TXPLLPOWERDOWN;
  assign #(in_delay) delay_TXPLLREFSELDY = TXPLLREFSELDY;
  assign #(in_delay) delay_TXPMASETPHASE = TXPMASETPHASE;
  assign #(in_delay) delay_TXPOLARITY = TXPOLARITY;
  assign #(in_delay) delay_TXPOSTEMPHASIS = TXPOSTEMPHASIS;
  assign #(in_delay) delay_TXPOWERDOWN = TXPOWERDOWN;
  assign #(in_delay) delay_TXPRBSFORCEERR = TXPRBSFORCEERR;
  assign #(in_delay) delay_TXPREEMPHASIS = TXPREEMPHASIS;
  assign #(in_delay) delay_TXRATE = TXRATE;
  assign #(in_delay) delay_TXRESET = TXRESET;
  assign #(in_delay) delay_TXSEQUENCE = TXSEQUENCE;
  assign #(in_delay) delay_TXSTARTSEQ = TXSTARTSEQ;
  assign #(in_delay) delay_TXSWING = TXSWING;
  assign #(in_delay) delay_USRCODEERR = USRCODEERR;

  B_GTXE1 #(
    .AC_CAP_DIS (AC_CAP_DIS),
    .ALIGN_COMMA_WORD (ALIGN_COMMA_WORD),
    .BGTEST_CFG (BGTEST_CFG),
    .BIAS_CFG (BIAS_CFG),
    .CDR_PH_ADJ_TIME (CDR_PH_ADJ_TIME),
    .CHAN_BOND_1_MAX_SKEW (CHAN_BOND_1_MAX_SKEW),
    .CHAN_BOND_2_MAX_SKEW (CHAN_BOND_2_MAX_SKEW),
    .CHAN_BOND_KEEP_ALIGN (CHAN_BOND_KEEP_ALIGN),
    .CHAN_BOND_SEQ_1_1 (CHAN_BOND_SEQ_1_1),
    .CHAN_BOND_SEQ_1_2 (CHAN_BOND_SEQ_1_2),
    .CHAN_BOND_SEQ_1_3 (CHAN_BOND_SEQ_1_3),
    .CHAN_BOND_SEQ_1_4 (CHAN_BOND_SEQ_1_4),
    .CHAN_BOND_SEQ_1_ENABLE (CHAN_BOND_SEQ_1_ENABLE),
    .CHAN_BOND_SEQ_2_1 (CHAN_BOND_SEQ_2_1),
    .CHAN_BOND_SEQ_2_2 (CHAN_BOND_SEQ_2_2),
    .CHAN_BOND_SEQ_2_3 (CHAN_BOND_SEQ_2_3),
    .CHAN_BOND_SEQ_2_4 (CHAN_BOND_SEQ_2_4),
    .CHAN_BOND_SEQ_2_CFG (CHAN_BOND_SEQ_2_CFG),
    .CHAN_BOND_SEQ_2_ENABLE (CHAN_BOND_SEQ_2_ENABLE),
    .CHAN_BOND_SEQ_2_USE (CHAN_BOND_SEQ_2_USE),
    .CHAN_BOND_SEQ_LEN (CHAN_BOND_SEQ_LEN),
    .CLK_CORRECT_USE (CLK_CORRECT_USE),
    .CLK_COR_ADJ_LEN (CLK_COR_ADJ_LEN),
    .CLK_COR_DET_LEN (CLK_COR_DET_LEN),
    .CLK_COR_INSERT_IDLE_FLAG (CLK_COR_INSERT_IDLE_FLAG),
    .CLK_COR_KEEP_IDLE (CLK_COR_KEEP_IDLE),
    .CLK_COR_MAX_LAT (CLK_COR_MAX_LAT),
    .CLK_COR_MIN_LAT (CLK_COR_MIN_LAT),
    .CLK_COR_PRECEDENCE (CLK_COR_PRECEDENCE),
    .CLK_COR_REPEAT_WAIT (CLK_COR_REPEAT_WAIT),
    .CLK_COR_SEQ_1_1 (CLK_COR_SEQ_1_1),
    .CLK_COR_SEQ_1_2 (CLK_COR_SEQ_1_2),
    .CLK_COR_SEQ_1_3 (CLK_COR_SEQ_1_3),
    .CLK_COR_SEQ_1_4 (CLK_COR_SEQ_1_4),
    .CLK_COR_SEQ_1_ENABLE (CLK_COR_SEQ_1_ENABLE),
    .CLK_COR_SEQ_2_1 (CLK_COR_SEQ_2_1),
    .CLK_COR_SEQ_2_2 (CLK_COR_SEQ_2_2),
    .CLK_COR_SEQ_2_3 (CLK_COR_SEQ_2_3),
    .CLK_COR_SEQ_2_4 (CLK_COR_SEQ_2_4),
    .CLK_COR_SEQ_2_ENABLE (CLK_COR_SEQ_2_ENABLE),
    .CLK_COR_SEQ_2_USE (CLK_COR_SEQ_2_USE),
    .CM_TRIM (CM_TRIM),
    .COMMA_10B_ENABLE (COMMA_10B_ENABLE),
    .COMMA_DOUBLE (COMMA_DOUBLE),
    .COM_BURST_VAL (COM_BURST_VAL),
    .DEC_MCOMMA_DETECT (DEC_MCOMMA_DETECT),
    .DEC_PCOMMA_DETECT (DEC_PCOMMA_DETECT),
    .DEC_VALID_COMMA_ONLY (DEC_VALID_COMMA_ONLY),
    .DFE_CAL_TIME (DFE_CAL_TIME),
    .DFE_CFG (DFE_CFG),
    .GEARBOX_ENDEC (GEARBOX_ENDEC),
    .GEN_RXUSRCLK (GEN_RXUSRCLK),
    .GEN_TXUSRCLK (GEN_TXUSRCLK),
    .GTX_CFG_PWRUP (GTX_CFG_PWRUP),
    .MCOMMA_10B_VALUE (MCOMMA_10B_VALUE),
    .MCOMMA_DETECT (MCOMMA_DETECT),
    .OOBDETECT_THRESHOLD (OOBDETECT_THRESHOLD),
    .PCI_EXPRESS_MODE (PCI_EXPRESS_MODE),
    .PCOMMA_10B_VALUE (PCOMMA_10B_VALUE),
    .PCOMMA_DETECT (PCOMMA_DETECT),
    .PMA_CAS_CLK_EN (PMA_CAS_CLK_EN),
    .PMA_CDR_SCAN (PMA_CDR_SCAN),
    .PMA_CFG (PMA_CFG),
    .PMA_RXSYNC_CFG (PMA_RXSYNC_CFG),
    .PMA_RX_CFG (PMA_RX_CFG),
    .PMA_TX_CFG (PMA_TX_CFG),
    .POWER_SAVE (POWER_SAVE),
    .RCV_TERM_GND (RCV_TERM_GND),
    .RCV_TERM_VTTRX (RCV_TERM_VTTRX),
    .RXGEARBOX_USE (RXGEARBOX_USE),
    .RXPLL_COM_CFG (RXPLL_COM_CFG),
    .RXPLL_CP_CFG (RXPLL_CP_CFG),
    .RXPLL_DIVSEL45_FB (RXPLL_DIVSEL45_FB),
    .RXPLL_DIVSEL_FB (RXPLL_DIVSEL_FB),
    .RXPLL_DIVSEL_OUT (RXPLL_DIVSEL_OUT),
    .RXPLL_DIVSEL_REF (RXPLL_DIVSEL_REF),
    .RXPLL_LKDET_CFG (RXPLL_LKDET_CFG),
    .RXPRBSERR_LOOPBACK (RXPRBSERR_LOOPBACK),
    .RXRECCLK_CTRL (RXRECCLK_CTRL),
    .RXRECCLK_DLY (RXRECCLK_DLY),
    .RXUSRCLK_DLY (RXUSRCLK_DLY),
    .RX_BUFFER_USE (RX_BUFFER_USE),
    .RX_CLK25_DIVIDER (RX_CLK25_DIVIDER),
    .RX_DATA_WIDTH (RX_DATA_WIDTH),
    .RX_DECODE_SEQ_MATCH (RX_DECODE_SEQ_MATCH),
    .RX_DLYALIGN_CTRINC (RX_DLYALIGN_CTRINC),
    .RX_DLYALIGN_EDGESET (RX_DLYALIGN_EDGESET),
    .RX_DLYALIGN_LPFINC (RX_DLYALIGN_LPFINC),
    .RX_DLYALIGN_MONSEL (RX_DLYALIGN_MONSEL),
    .RX_DLYALIGN_OVRDSETTING (RX_DLYALIGN_OVRDSETTING),
    .RX_EN_IDLE_HOLD_CDR (RX_EN_IDLE_HOLD_CDR),
    .RX_EN_IDLE_HOLD_DFE (RX_EN_IDLE_HOLD_DFE),
    .RX_EN_IDLE_RESET_BUF (RX_EN_IDLE_RESET_BUF),
    .RX_EN_IDLE_RESET_FR (RX_EN_IDLE_RESET_FR),
    .RX_EN_IDLE_RESET_PH (RX_EN_IDLE_RESET_PH),
    .RX_EN_MODE_RESET_BUF (RX_EN_MODE_RESET_BUF),
    .RX_EN_RATE_RESET_BUF (RX_EN_RATE_RESET_BUF),
    .RX_EN_REALIGN_RESET_BUF (RX_EN_REALIGN_RESET_BUF),
    .RX_EN_REALIGN_RESET_BUF2 (RX_EN_REALIGN_RESET_BUF2),
    .RX_EYE_OFFSET (RX_EYE_OFFSET),
    .RX_EYE_SCANMODE (RX_EYE_SCANMODE),
    .RX_FIFO_ADDR_MODE (RX_FIFO_ADDR_MODE),
    .RX_IDLE_HI_CNT (RX_IDLE_HI_CNT),
    .RX_IDLE_LO_CNT (RX_IDLE_LO_CNT),
    .RX_LOSS_OF_SYNC_FSM (RX_LOSS_OF_SYNC_FSM),
    .RX_LOS_INVALID_INCR (RX_LOS_INVALID_INCR),
    .RX_LOS_THRESHOLD (RX_LOS_THRESHOLD),
    .RX_OVERSAMPLE_MODE (RX_OVERSAMPLE_MODE),
    .RX_SLIDE_AUTO_WAIT (RX_SLIDE_AUTO_WAIT),
    .RX_SLIDE_MODE (RX_SLIDE_MODE),
    .RX_XCLK_SEL (RX_XCLK_SEL),
    .SAS_MAX_COMSAS (SAS_MAX_COMSAS),
    .SAS_MIN_COMSAS (SAS_MIN_COMSAS),
    .SATA_BURST_VAL (SATA_BURST_VAL),
    .SATA_IDLE_VAL (SATA_IDLE_VAL),
    .SATA_MAX_BURST (SATA_MAX_BURST),
    .SATA_MAX_INIT (SATA_MAX_INIT),
    .SATA_MAX_WAKE (SATA_MAX_WAKE),
    .SATA_MIN_BURST (SATA_MIN_BURST),
    .SATA_MIN_INIT (SATA_MIN_INIT),
    .SATA_MIN_WAKE (SATA_MIN_WAKE),
    .SHOW_REALIGN_COMMA (SHOW_REALIGN_COMMA),
    .SIM_GTXRESET_SPEEDUP (SIM_GTXRESET_SPEEDUP),
    .SIM_RECEIVER_DETECT_PASS (SIM_RECEIVER_DETECT_PASS),
    .SIM_RXREFCLK_SOURCE (SIM_RXREFCLK_SOURCE),
    .SIM_TXREFCLK_SOURCE (SIM_TXREFCLK_SOURCE),
    .SIM_TX_ELEC_IDLE_LEVEL (SIM_TX_ELEC_IDLE_LEVEL),
    .SIM_VERSION (SIM_VERSION),
    .TERMINATION_CTRL (TERMINATION_CTRL),
    .TERMINATION_OVRD (TERMINATION_OVRD),
    .TRANS_TIME_FROM_P2 (TRANS_TIME_FROM_P2),
    .TRANS_TIME_NON_P2 (TRANS_TIME_NON_P2),
    .TRANS_TIME_RATE (TRANS_TIME_RATE),
    .TRANS_TIME_TO_P2 (TRANS_TIME_TO_P2),
    .TST_ATTR (TST_ATTR),
    .TXDRIVE_LOOPBACK_HIZ (TXDRIVE_LOOPBACK_HIZ),
    .TXDRIVE_LOOPBACK_PD (TXDRIVE_LOOPBACK_PD),
    .TXGEARBOX_USE (TXGEARBOX_USE),
    .TXOUTCLK_CTRL (TXOUTCLK_CTRL),
    .TXOUTCLK_DLY (TXOUTCLK_DLY),
    .TXPLL_COM_CFG (TXPLL_COM_CFG),
    .TXPLL_CP_CFG (TXPLL_CP_CFG),
    .TXPLL_DIVSEL45_FB (TXPLL_DIVSEL45_FB),
    .TXPLL_DIVSEL_FB (TXPLL_DIVSEL_FB),
    .TXPLL_DIVSEL_OUT (TXPLL_DIVSEL_OUT),
    .TXPLL_DIVSEL_REF (TXPLL_DIVSEL_REF),
    .TXPLL_LKDET_CFG (TXPLL_LKDET_CFG),
    .TXPLL_SATA (TXPLL_SATA),
    .TX_BUFFER_USE (TX_BUFFER_USE),
    .TX_BYTECLK_CFG (TX_BYTECLK_CFG),
    .TX_CLK25_DIVIDER (TX_CLK25_DIVIDER),
    .TX_CLK_SOURCE (TX_CLK_SOURCE),
    .TX_DATA_WIDTH (TX_DATA_WIDTH),
    .TX_DEEMPH_0 (TX_DEEMPH_0),
    .TX_DEEMPH_1 (TX_DEEMPH_1),
    .TX_DETECT_RX_CFG (TX_DETECT_RX_CFG),
    .TX_DLYALIGN_CTRINC (TX_DLYALIGN_CTRINC),
    .TX_DLYALIGN_LPFINC (TX_DLYALIGN_LPFINC),
    .TX_DLYALIGN_MONSEL (TX_DLYALIGN_MONSEL),
    .TX_DLYALIGN_OVRDSETTING (TX_DLYALIGN_OVRDSETTING),
    .TX_DRIVE_MODE (TX_DRIVE_MODE),
    .TX_EN_RATE_RESET_BUF (TX_EN_RATE_RESET_BUF),
    .TX_IDLE_ASSERT_DELAY (TX_IDLE_ASSERT_DELAY),
    .TX_IDLE_DEASSERT_DELAY (TX_IDLE_DEASSERT_DELAY),
    .TX_MARGIN_FULL_0 (TX_MARGIN_FULL_0),
    .TX_MARGIN_FULL_1 (TX_MARGIN_FULL_1),
    .TX_MARGIN_FULL_2 (TX_MARGIN_FULL_2),
    .TX_MARGIN_FULL_3 (TX_MARGIN_FULL_3),
    .TX_MARGIN_FULL_4 (TX_MARGIN_FULL_4),
    .TX_MARGIN_LOW_0 (TX_MARGIN_LOW_0),
    .TX_MARGIN_LOW_1 (TX_MARGIN_LOW_1),
    .TX_MARGIN_LOW_2 (TX_MARGIN_LOW_2),
    .TX_MARGIN_LOW_3 (TX_MARGIN_LOW_3),
    .TX_MARGIN_LOW_4 (TX_MARGIN_LOW_4),
    .TX_OVERSAMPLE_MODE (TX_OVERSAMPLE_MODE),
    .TX_PMADATA_OPT (TX_PMADATA_OPT),
    .TX_TDCC_CFG (TX_TDCC_CFG),
    .TX_USRCLK_CFG (TX_USRCLK_CFG),
    .TX_XCLK_SEL (TX_XCLK_SEL))

   B_GTXE1_INST(
    .COMFINISH (delay_COMFINISH),
    .COMINITDET (delay_COMINITDET),
    .COMSASDET (delay_COMSASDET),
    .COMWAKEDET (delay_COMWAKEDET),
    .DFECLKDLYADJMON (delay_DFECLKDLYADJMON),
    .DFEEYEDACMON (delay_DFEEYEDACMON),
    .DFESENSCAL (delay_DFESENSCAL),
    .DFETAP1MONITOR (delay_DFETAP1MONITOR),
    .DFETAP2MONITOR (delay_DFETAP2MONITOR),
    .DFETAP3MONITOR (delay_DFETAP3MONITOR),
    .DFETAP4MONITOR (delay_DFETAP4MONITOR),
    .DRDY (delay_DRDY),
    .DRPDO (delay_DRPDO),
    .MGTREFCLKFAB (delay_MGTREFCLKFAB),
    .PHYSTATUS (delay_PHYSTATUS),
    .RXBUFSTATUS (delay_RXBUFSTATUS),
    .RXBYTEISALIGNED (delay_RXBYTEISALIGNED),
    .RXBYTEREALIGN (delay_RXBYTEREALIGN),
    .RXCHANBONDSEQ (delay_RXCHANBONDSEQ),
    .RXCHANISALIGNED (delay_RXCHANISALIGNED),
    .RXCHANREALIGN (delay_RXCHANREALIGN),
    .RXCHARISCOMMA (delay_RXCHARISCOMMA),
    .RXCHARISK (delay_RXCHARISK),
    .RXCHBONDO (delay_RXCHBONDO),
    .RXCLKCORCNT (delay_RXCLKCORCNT),
    .RXCOMMADET (delay_RXCOMMADET),
    .RXDATA (delay_RXDATA),
    .RXDATAVALID (delay_RXDATAVALID),
    .RXDISPERR (delay_RXDISPERR),
    .RXDLYALIGNMONITOR (delay_RXDLYALIGNMONITOR),
    .RXELECIDLE (delay_RXELECIDLE),
    .RXHEADER (delay_RXHEADER),
    .RXHEADERVALID (delay_RXHEADERVALID),
    .RXLOSSOFSYNC (delay_RXLOSSOFSYNC),
    .RXNOTINTABLE (delay_RXNOTINTABLE),
    .RXOVERSAMPLEERR (delay_RXOVERSAMPLEERR),
    .RXPLLLKDET (delay_RXPLLLKDET),
    .RXPRBSERR (delay_RXPRBSERR),
    .RXRATEDONE (delay_RXRATEDONE),
    .RXRECCLK (delay_RXRECCLK),
    .RXRECCLKPCS (delay_RXRECCLKPCS),
    .RXRESETDONE (delay_RXRESETDONE),
    .RXRUNDISP (delay_RXRUNDISP),
    .RXSTARTOFSEQ (delay_RXSTARTOFSEQ),
    .RXSTATUS (delay_RXSTATUS),
    .RXVALID (delay_RXVALID),
    .TSTOUT (delay_TSTOUT),
    .TXBUFSTATUS (delay_TXBUFSTATUS),
    .TXDLYALIGNMONITOR (delay_TXDLYALIGNMONITOR),
    .TXGEARBOXREADY (delay_TXGEARBOXREADY),
    .TXKERR (delay_TXKERR),
    .TXN (delay_TXN),
    .TXOUTCLK (delay_TXOUTCLK),
    .TXOUTCLKPCS (delay_TXOUTCLKPCS),
    .TXP (delay_TXP),
    .TXPLLLKDET (delay_TXPLLLKDET),
    .TXRATEDONE (delay_TXRATEDONE),
    .TXRESETDONE (delay_TXRESETDONE),
    .TXRUNDISP (delay_TXRUNDISP),
    .DADDR (delay_DADDR),
    .DCLK (delay_DCLK),
    .DEN (delay_DEN),
    .DFECLKDLYADJ (delay_DFECLKDLYADJ),
    .DFEDLYOVRD (delay_DFEDLYOVRD),
    .DFETAP1 (delay_DFETAP1),
    .DFETAP2 (delay_DFETAP2),
    .DFETAP3 (delay_DFETAP3),
    .DFETAP4 (delay_DFETAP4),
    .DFETAPOVRD (delay_DFETAPOVRD),
    .DI (delay_DI),
    .DWE (delay_DWE),
    .GATERXELECIDLE (delay_GATERXELECIDLE),
    .GREFCLKRX (delay_GREFCLKRX),
    .GREFCLKTX (delay_GREFCLKTX),
    .GTXRXRESET (delay_GTXRXRESET),
    .GTXTEST (delay_GTXTEST),
    .GTXTXRESET (delay_GTXTXRESET),
    .IGNORESIGDET (delay_IGNORESIGDET),
    .LOOPBACK (delay_LOOPBACK),
    .MGTREFCLKRX (delay_MGTREFCLKRX),
    .MGTREFCLKTX (delay_MGTREFCLKTX),
    .NORTHREFCLKRX (delay_NORTHREFCLKRX),
    .NORTHREFCLKTX (delay_NORTHREFCLKTX),
    .PERFCLKRX (delay_PERFCLKRX),
    .PERFCLKTX (delay_PERFCLKTX),
    .PLLRXRESET (delay_PLLRXRESET),
    .PLLTXRESET (delay_PLLTXRESET),
    .PRBSCNTRESET (delay_PRBSCNTRESET),
    .RXBUFRESET (delay_RXBUFRESET),
    .RXCDRRESET (delay_RXCDRRESET),
    .RXCHBONDI (delay_RXCHBONDI),
    .RXCHBONDLEVEL (delay_RXCHBONDLEVEL),
    .RXCHBONDMASTER (delay_RXCHBONDMASTER),
    .RXCHBONDSLAVE (delay_RXCHBONDSLAVE),
    .RXCOMMADETUSE (delay_RXCOMMADETUSE),
    .RXDEC8B10BUSE (delay_RXDEC8B10BUSE),
    .RXDLYALIGNDISABLE (delay_RXDLYALIGNDISABLE),
    .RXDLYALIGNMONENB (delay_RXDLYALIGNMONENB),	
    .RXDLYALIGNOVERRIDE (delay_RXDLYALIGNOVERRIDE),
    .RXDLYALIGNRESET (delay_RXDLYALIGNRESET),
    .RXDLYALIGNSWPPRECURB (delay_RXDLYALIGNSWPPRECURB),
    .RXDLYALIGNUPDSW (delay_RXDLYALIGNUPDSW),
    .RXENCHANSYNC (delay_RXENCHANSYNC),
    .RXENMCOMMAALIGN (delay_RXENMCOMMAALIGN),
    .RXENPCOMMAALIGN (delay_RXENPCOMMAALIGN),
    .RXENPMAPHASEALIGN (delay_RXENPMAPHASEALIGN),
    .RXENPRBSTST (delay_RXENPRBSTST),
    .RXENSAMPLEALIGN (delay_RXENSAMPLEALIGN),
    .RXEQMIX (delay_RXEQMIX),
    .RXGEARBOXSLIP (delay_RXGEARBOXSLIP),
    .RXN (delay_RXN),
    .RXP (delay_RXP),
    .RXPLLLKDETEN (delay_RXPLLLKDETEN),
    .RXPLLPOWERDOWN (delay_RXPLLPOWERDOWN),
    .RXPLLREFSELDY (delay_RXPLLREFSELDY),
    .RXPMASETPHASE (delay_RXPMASETPHASE),
    .RXPOLARITY (delay_RXPOLARITY),
    .RXPOWERDOWN (delay_RXPOWERDOWN),
    .RXRATE (delay_RXRATE),
    .RXRESET (delay_RXRESET),
    .RXSLIDE (delay_RXSLIDE),
    .RXUSRCLK (delay_RXUSRCLK),
    .RXUSRCLK2 (delay_RXUSRCLK2),
    .SOUTHREFCLKRX (delay_SOUTHREFCLKRX),
    .SOUTHREFCLKTX (delay_SOUTHREFCLKTX),
    .TSTCLK0 (delay_TSTCLK0),
    .TSTCLK1 (delay_TSTCLK1),
    .TSTIN (delay_TSTIN),
    .TXBUFDIFFCTRL (delay_TXBUFDIFFCTRL),
    .TXBYPASS8B10B (delay_TXBYPASS8B10B),
    .TXCHARDISPMODE (delay_TXCHARDISPMODE),
    .TXCHARDISPVAL (delay_TXCHARDISPVAL),
    .TXCHARISK (delay_TXCHARISK),
    .TXCOMINIT (delay_TXCOMINIT),
    .TXCOMSAS (delay_TXCOMSAS),
    .TXCOMWAKE (delay_TXCOMWAKE),
    .TXDATA (delay_TXDATA),
    .TXDEEMPH (delay_TXDEEMPH),
    .TXDETECTRX (delay_TXDETECTRX),
    .TXDIFFCTRL (delay_TXDIFFCTRL),
    .TXDLYALIGNDISABLE (delay_TXDLYALIGNDISABLE),
    .TXDLYALIGNMONENB (delay_TXDLYALIGNMONENB),	
    .TXDLYALIGNOVERRIDE (delay_TXDLYALIGNOVERRIDE),
    .TXDLYALIGNRESET (delay_TXDLYALIGNRESET),
    .TXDLYALIGNUPDSW (delay_TXDLYALIGNUPDSW),
    .TXELECIDLE (delay_TXELECIDLE),
    .TXENC8B10BUSE (delay_TXENC8B10BUSE),
    .TXENPMAPHASEALIGN (delay_TXENPMAPHASEALIGN),
    .TXENPRBSTST (delay_TXENPRBSTST),
    .TXHEADER (delay_TXHEADER),
    .TXINHIBIT (delay_TXINHIBIT),
    .TXMARGIN (delay_TXMARGIN),
    .TXPDOWNASYNCH (delay_TXPDOWNASYNCH),
    .TXPLLLKDETEN (delay_TXPLLLKDETEN),
    .TXPLLPOWERDOWN (delay_TXPLLPOWERDOWN),
    .TXPLLREFSELDY (delay_TXPLLREFSELDY),
    .TXPMASETPHASE (delay_TXPMASETPHASE),
    .TXPOLARITY (delay_TXPOLARITY),
    .TXPOSTEMPHASIS (delay_TXPOSTEMPHASIS),
    .TXPOWERDOWN (delay_TXPOWERDOWN),
    .TXPRBSFORCEERR (delay_TXPRBSFORCEERR),
    .TXPREEMPHASIS (delay_TXPREEMPHASIS),
    .TXRATE (delay_TXRATE),
    .TXRESET (delay_TXRESET),
    .TXSEQUENCE (delay_TXSEQUENCE),
    .TXSTARTSEQ (delay_TXSTARTSEQ),
    .TXSWING (delay_TXSWING),
    .TXUSRCLK (delay_TXUSRCLK),
    .TXUSRCLK2 (delay_TXUSRCLK2),
    .USRCODEERR (delay_USRCODEERR),
    .GSR(GSR)
  );

  specify
    ( DCLK => DRDY) = (0, 0);
    ( DCLK => DRPDO[0]) = (0, 0);
    ( DCLK => DRPDO[10]) = (0, 0);
    ( DCLK => DRPDO[11]) = (0, 0);
    ( DCLK => DRPDO[12]) = (0, 0);
    ( DCLK => DRPDO[13]) = (0, 0);
    ( DCLK => DRPDO[14]) = (0, 0);
    ( DCLK => DRPDO[15]) = (0, 0);
    ( DCLK => DRPDO[1]) = (0, 0);
    ( DCLK => DRPDO[2]) = (0, 0);
    ( DCLK => DRPDO[3]) = (0, 0);
    ( DCLK => DRPDO[4]) = (0, 0);
    ( DCLK => DRPDO[5]) = (0, 0);
    ( DCLK => DRPDO[6]) = (0, 0);
    ( DCLK => DRPDO[7]) = (0, 0);
    ( DCLK => DRPDO[8]) = (0, 0);
    ( DCLK => DRPDO[9]) = (0, 0);
    ( MGTREFCLKRX[0] => MGTREFCLKFAB[0]) = (0, 0);
    ( MGTREFCLKRX[0] => MGTREFCLKFAB[1]) = (0, 0);
    ( MGTREFCLKRX[1] => MGTREFCLKFAB[0]) = (0, 0);
    ( MGTREFCLKRX[1] => MGTREFCLKFAB[1]) = (0, 0);
    ( MGTREFCLKTX[0] => MGTREFCLKFAB[0]) = (0, 0);
    ( MGTREFCLKTX[0] => MGTREFCLKFAB[1]) = (0, 0);
    ( MGTREFCLKTX[1] => MGTREFCLKFAB[0]) = (0, 0);
    ( MGTREFCLKTX[1] => MGTREFCLKFAB[1]) = (0, 0);
    ( NORTHREFCLKRX[0] => MGTREFCLKFAB[0]) = (0, 0);
    ( NORTHREFCLKRX[0] => MGTREFCLKFAB[1]) = (0, 0);
    ( NORTHREFCLKRX[1] => MGTREFCLKFAB[0]) = (0, 0);
    ( NORTHREFCLKRX[1] => MGTREFCLKFAB[1]) = (0, 0);
    ( NORTHREFCLKTX[0] => MGTREFCLKFAB[0]) = (0, 0);
    ( NORTHREFCLKTX[0] => MGTREFCLKFAB[1]) = (0, 0);
    ( NORTHREFCLKTX[1] => MGTREFCLKFAB[0]) = (0, 0);
    ( NORTHREFCLKTX[1] => MGTREFCLKFAB[1]) = (0, 0);
    ( RXUSRCLK => RXCHBONDO[0]) = (0, 0);
    ( RXUSRCLK => RXCHBONDO[1]) = (0, 0);
    ( RXUSRCLK => RXCHBONDO[2]) = (0, 0);
    ( RXUSRCLK => RXCHBONDO[3]) = (0, 0);
    ( RXUSRCLK2 => COMINITDET) = (0, 0);
    ( RXUSRCLK2 => COMSASDET) = (0, 0);
    ( RXUSRCLK2 => COMWAKEDET) = (0, 0);
    ( RXUSRCLK2 => DFECLKDLYADJMON[0]) = (0, 0);
    ( RXUSRCLK2 => DFECLKDLYADJMON[1]) = (0, 0);
    ( RXUSRCLK2 => DFECLKDLYADJMON[2]) = (0, 0);
    ( RXUSRCLK2 => DFECLKDLYADJMON[3]) = (0, 0);
    ( RXUSRCLK2 => DFECLKDLYADJMON[4]) = (0, 0);
    ( RXUSRCLK2 => DFECLKDLYADJMON[5]) = (0, 0);
    ( RXUSRCLK2 => DFEEYEDACMON[0]) = (0, 0);
    ( RXUSRCLK2 => DFEEYEDACMON[1]) = (0, 0);
    ( RXUSRCLK2 => DFEEYEDACMON[2]) = (0, 0);
    ( RXUSRCLK2 => DFEEYEDACMON[3]) = (0, 0);
    ( RXUSRCLK2 => DFEEYEDACMON[4]) = (0, 0);
    ( RXUSRCLK2 => DFESENSCAL[0]) = (0, 0);
    ( RXUSRCLK2 => DFESENSCAL[1]) = (0, 0);
    ( RXUSRCLK2 => DFESENSCAL[2]) = (0, 0);
    ( RXUSRCLK2 => DFETAP1MONITOR[0]) = (0, 0);
    ( RXUSRCLK2 => DFETAP1MONITOR[1]) = (0, 0);
    ( RXUSRCLK2 => DFETAP1MONITOR[2]) = (0, 0);
    ( RXUSRCLK2 => DFETAP1MONITOR[3]) = (0, 0);
    ( RXUSRCLK2 => DFETAP1MONITOR[4]) = (0, 0);
    ( RXUSRCLK2 => DFETAP2MONITOR[0]) = (0, 0);
    ( RXUSRCLK2 => DFETAP2MONITOR[1]) = (0, 0);
    ( RXUSRCLK2 => DFETAP2MONITOR[2]) = (0, 0);
    ( RXUSRCLK2 => DFETAP2MONITOR[3]) = (0, 0);
    ( RXUSRCLK2 => DFETAP2MONITOR[4]) = (0, 0);
    ( RXUSRCLK2 => DFETAP3MONITOR[0]) = (0, 0);
    ( RXUSRCLK2 => DFETAP3MONITOR[1]) = (0, 0);
    ( RXUSRCLK2 => DFETAP3MONITOR[2]) = (0, 0);
    ( RXUSRCLK2 => DFETAP3MONITOR[3]) = (0, 0);
    ( RXUSRCLK2 => DFETAP4MONITOR[0]) = (0, 0);
    ( RXUSRCLK2 => DFETAP4MONITOR[1]) = (0, 0);
    ( RXUSRCLK2 => DFETAP4MONITOR[2]) = (0, 0);
    ( RXUSRCLK2 => DFETAP4MONITOR[3]) = (0, 0);
    ( RXUSRCLK2 => PHYSTATUS) = (0, 0);
    ( RXUSRCLK2 => RXBUFSTATUS[0]) = (0, 0);
    ( RXUSRCLK2 => RXBUFSTATUS[1]) = (0, 0);
    ( RXUSRCLK2 => RXBUFSTATUS[2]) = (0, 0);
    ( RXUSRCLK2 => RXBYTEISALIGNED) = (0, 0);
    ( RXUSRCLK2 => RXBYTEREALIGN) = (0, 0);
    ( RXUSRCLK2 => RXCHANBONDSEQ) = (0, 0);
    ( RXUSRCLK2 => RXCHANISALIGNED) = (0, 0);
    ( RXUSRCLK2 => RXCHANREALIGN) = (0, 0);
    ( RXUSRCLK2 => RXCHARISCOMMA[0]) = (0, 0);
    ( RXUSRCLK2 => RXCHARISCOMMA[1]) = (0, 0);
    ( RXUSRCLK2 => RXCHARISCOMMA[2]) = (0, 0);
    ( RXUSRCLK2 => RXCHARISCOMMA[3]) = (0, 0);
    ( RXUSRCLK2 => RXCHARISK[0]) = (0, 0);
    ( RXUSRCLK2 => RXCHARISK[1]) = (0, 0);
    ( RXUSRCLK2 => RXCHARISK[2]) = (0, 0);
    ( RXUSRCLK2 => RXCHARISK[3]) = (0, 0);
    ( RXUSRCLK2 => RXCHBONDO[0]) = (0, 0);
    ( RXUSRCLK2 => RXCHBONDO[1]) = (0, 0);
    ( RXUSRCLK2 => RXCHBONDO[2]) = (0, 0);
    ( RXUSRCLK2 => RXCHBONDO[3]) = (0, 0);
    ( RXUSRCLK2 => RXCLKCORCNT[0]) = (0, 0);
    ( RXUSRCLK2 => RXCLKCORCNT[1]) = (0, 0);
    ( RXUSRCLK2 => RXCLKCORCNT[2]) = (0, 0);
    ( RXUSRCLK2 => RXCOMMADET) = (0, 0);
    ( RXUSRCLK2 => RXDATAVALID) = (0, 0);
    ( RXUSRCLK2 => RXDATA[0]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[10]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[11]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[12]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[13]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[14]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[15]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[16]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[17]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[18]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[19]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[1]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[20]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[21]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[22]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[23]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[24]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[25]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[26]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[27]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[28]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[29]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[2]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[30]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[31]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[3]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[4]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[5]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[6]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[7]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[8]) = (0, 0);
    ( RXUSRCLK2 => RXDATA[9]) = (0, 0);
    ( RXUSRCLK2 => RXDISPERR[0]) = (0, 0);
    ( RXUSRCLK2 => RXDISPERR[1]) = (0, 0);
    ( RXUSRCLK2 => RXDISPERR[2]) = (0, 0);
    ( RXUSRCLK2 => RXDISPERR[3]) = (0, 0);
    ( RXUSRCLK2 => RXHEADERVALID) = (0, 0);
    ( RXUSRCLK2 => RXHEADER[0]) = (0, 0);
    ( RXUSRCLK2 => RXHEADER[1]) = (0, 0);
    ( RXUSRCLK2 => RXHEADER[2]) = (0, 0);
    ( RXUSRCLK2 => RXLOSSOFSYNC[0]) = (0, 0);
    ( RXUSRCLK2 => RXLOSSOFSYNC[1]) = (0, 0);
    ( RXUSRCLK2 => RXNOTINTABLE[0]) = (0, 0);
    ( RXUSRCLK2 => RXNOTINTABLE[1]) = (0, 0);
    ( RXUSRCLK2 => RXNOTINTABLE[2]) = (0, 0);
    ( RXUSRCLK2 => RXNOTINTABLE[3]) = (0, 0);
    ( RXUSRCLK2 => RXOVERSAMPLEERR) = (0, 0);
    ( RXUSRCLK2 => RXPRBSERR) = (0, 0);
    ( RXUSRCLK2 => RXRATEDONE) = (0, 0);
    ( RXUSRCLK2 => RXRESETDONE) = (0, 0);
    ( RXUSRCLK2 => RXRUNDISP[0]) = (0, 0);
    ( RXUSRCLK2 => RXRUNDISP[1]) = (0, 0);
    ( RXUSRCLK2 => RXRUNDISP[2]) = (0, 0);
    ( RXUSRCLK2 => RXRUNDISP[3]) = (0, 0);
    ( RXUSRCLK2 => RXSTARTOFSEQ) = (0, 0);
    ( RXUSRCLK2 => RXSTATUS[0]) = (0, 0);
    ( RXUSRCLK2 => RXSTATUS[1]) = (0, 0);
    ( RXUSRCLK2 => RXSTATUS[2]) = (0, 0);
    ( RXUSRCLK2 => RXVALID) = (0, 0);
    ( SOUTHREFCLKRX[0] => MGTREFCLKFAB[0]) = (0, 0);
    ( SOUTHREFCLKRX[0] => MGTREFCLKFAB[1]) = (0, 0);
    ( SOUTHREFCLKRX[1] => MGTREFCLKFAB[0]) = (0, 0);
    ( SOUTHREFCLKRX[1] => MGTREFCLKFAB[1]) = (0, 0);
    ( SOUTHREFCLKTX[0] => MGTREFCLKFAB[0]) = (0, 0);
    ( SOUTHREFCLKTX[0] => MGTREFCLKFAB[1]) = (0, 0);
    ( SOUTHREFCLKTX[1] => MGTREFCLKFAB[0]) = (0, 0);
    ( SOUTHREFCLKTX[1] => MGTREFCLKFAB[1]) = (0, 0);
    ( TXUSRCLK2 => COMFINISH) = (0, 0);
    ( TXUSRCLK2 => TXBUFSTATUS[0]) = (0, 0);
    ( TXUSRCLK2 => TXBUFSTATUS[1]) = (0, 0);
    ( TXUSRCLK2 => TXGEARBOXREADY) = (0, 0);
    ( TXUSRCLK2 => TXKERR[0]) = (0, 0);
    ( TXUSRCLK2 => TXKERR[1]) = (0, 0);
    ( TXUSRCLK2 => TXKERR[2]) = (0, 0);
    ( TXUSRCLK2 => TXKERR[3]) = (0, 0);
    ( TXUSRCLK2 => TXRATEDONE) = (0, 0);
    ( TXUSRCLK2 => TXRESETDONE) = (0, 0);
    ( TXUSRCLK2 => TXRUNDISP[0]) = (0, 0);
    ( TXUSRCLK2 => TXRUNDISP[1]) = (0, 0);
    ( TXUSRCLK2 => TXRUNDISP[2]) = (0, 0);
    ( TXUSRCLK2 => TXRUNDISP[3]) = (0, 0);

    specparam PATHPULSE$ = 0;
  endspecify
endmodule
