///////////////////////////////////////////////////////////
//  Copyright (c) 1995/2006 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /    Vendor      : Xilinx 
// \  \    \/     Version : 10.1
//  \  \          Description : 
//  /  /                      
// /__/   /\      Filename    : GTX_DUAL.v
// \  \  /  \     Timestamp   : Tue Jan  9 10:05:14 2007
//  \__\/\__ \                    
//                                 
//  Revision:
//  09/12/06 - CR#423671 - Initial version.
//  12/05/06 - CR#426138 - J.31 spreadsheet update
//  01/23/07 - CR#430426 - J.32 pinTime added
//  02/20/07 - CR#434096 - Parameter default value update PLL_RXDIVSEL_OUT_0/1
//  06/18/07 - CR#441601 - BT1445 - Test attributes made visible 
//  06/18/07 - CR#441576 - BT1488 - Add STEPPING attribute
//  10/05/07 - CR#451343 - BT1514 - Add ES1 (ES1 mapped to 0) as STEPPING value
//  11/05/07 - CR#452590 - BT1514 - Remove STEPPING attribute from unisim/simprim wrapper
//  02/05/08 - CR#459742 - Attribute default changes 
//  03/14/08 - CR#468285 - Updated timing checks
//  03/17/08 - CR#467692 - Add SIM_MODE attribute with values LEGACY & FAST model
//  04/24/08 - CR#472011 - OOBDETECT_THRESHOLD_0/1 default from 001 to 110, range changes from 000-111 to 110-111
//  05/13/08 - CR#472931 - OOBDETECT_THRESHOLD_0/1 case statement updates
//  05/19/08 - CR#472395 - Remove GTX_DUAL LEGACY model
//  05/27/08 - CR#472395 - Set SIM_MODE to FAST, Add DRC checks
/////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module GTX_DUAL (
	DFECLKDLYADJMONITOR0,
	DFECLKDLYADJMONITOR1,
	DFEEYEDACMONITOR0,
	DFEEYEDACMONITOR1,
	DFESENSCAL0,
	DFESENSCAL1,
	DFETAP1MONITOR0,
	DFETAP1MONITOR1,
	DFETAP2MONITOR0,
	DFETAP2MONITOR1,
	DFETAP3MONITOR0,
	DFETAP3MONITOR1,
	DFETAP4MONITOR0,
	DFETAP4MONITOR1,
	DO,
	DRDY,
	PHYSTATUS0,
	PHYSTATUS1,
	PLLLKDET,
	REFCLKOUT,
	RESETDONE0,
	RESETDONE1,
	RXBUFSTATUS0,
	RXBUFSTATUS1,
	RXBYTEISALIGNED0,
	RXBYTEISALIGNED1,
	RXBYTEREALIGN0,
	RXBYTEREALIGN1,
	RXCHANBONDSEQ0,
	RXCHANBONDSEQ1,
	RXCHANISALIGNED0,
	RXCHANISALIGNED1,
	RXCHANREALIGN0,
	RXCHANREALIGN1,
	RXCHARISCOMMA0,
	RXCHARISCOMMA1,
	RXCHARISK0,
	RXCHARISK1,
	RXCHBONDO0,
	RXCHBONDO1,
	RXCLKCORCNT0,
	RXCLKCORCNT1,
	RXCOMMADET0,
	RXCOMMADET1,
	RXDATA0,
	RXDATA1,
	RXDATAVALID0,
	RXDATAVALID1,
	RXDISPERR0,
	RXDISPERR1,
	RXELECIDLE0,
	RXELECIDLE1,
	RXHEADER0,
	RXHEADER1,
	RXHEADERVALID0,
	RXHEADERVALID1,
	RXLOSSOFSYNC0,
	RXLOSSOFSYNC1,
	RXNOTINTABLE0,
	RXNOTINTABLE1,
	RXOVERSAMPLEERR0,
	RXOVERSAMPLEERR1,
	RXPRBSERR0,
	RXPRBSERR1,
	RXRECCLK0,
	RXRECCLK1,
	RXRUNDISP0,
	RXRUNDISP1,
	RXSTARTOFSEQ0,
	RXSTARTOFSEQ1,
	RXSTATUS0,
	RXSTATUS1,
	RXVALID0,
	RXVALID1,
	TXBUFSTATUS0,
	TXBUFSTATUS1,
	TXGEARBOXREADY0,
	TXGEARBOXREADY1,
	TXKERR0,
	TXKERR1,
	TXN0,
	TXN1,
	TXOUTCLK0,
	TXOUTCLK1,
	TXP0,
	TXP1,
	TXRUNDISP0,
	TXRUNDISP1,

	CLKIN,
	DADDR,
	DCLK,
	DEN,
	DFECLKDLYADJ0,
	DFECLKDLYADJ1,
	DFETAP10,
	DFETAP11,
	DFETAP20,
	DFETAP21,
	DFETAP30,
	DFETAP31,
	DFETAP40,
	DFETAP41,
	DI,
	DWE,
	GTXRESET,
	GTXTEST,
	INTDATAWIDTH,
	LOOPBACK0,
	LOOPBACK1,
	PLLLKDETEN,
	PLLPOWERDOWN,
	PRBSCNTRESET0,
	PRBSCNTRESET1,
	REFCLKPWRDNB,
	RXBUFRESET0,
	RXBUFRESET1,
	RXCDRRESET0,
	RXCDRRESET1,
	RXCHBONDI0,
	RXCHBONDI1,
	RXCOMMADETUSE0,
	RXCOMMADETUSE1,
	RXDATAWIDTH0,
	RXDATAWIDTH1,
	RXDEC8B10BUSE0,
	RXDEC8B10BUSE1,
	RXENCHANSYNC0,
	RXENCHANSYNC1,
	RXENEQB0,
	RXENEQB1,
	RXENMCOMMAALIGN0,
	RXENMCOMMAALIGN1,
	RXENPCOMMAALIGN0,
	RXENPCOMMAALIGN1,
	RXENPMAPHASEALIGN0,
	RXENPMAPHASEALIGN1,
	RXENPRBSTST0,
	RXENPRBSTST1,
	RXENSAMPLEALIGN0,
	RXENSAMPLEALIGN1,
	RXEQMIX0,
	RXEQMIX1,
	RXEQPOLE0,
	RXEQPOLE1,
	RXGEARBOXSLIP0,
	RXGEARBOXSLIP1,
	RXN0,
	RXN1,
	RXP0,
	RXP1,
	RXPMASETPHASE0,
	RXPMASETPHASE1,
	RXPOLARITY0,
	RXPOLARITY1,
	RXPOWERDOWN0,
	RXPOWERDOWN1,
	RXRESET0,
	RXRESET1,
	RXSLIDE0,
	RXSLIDE1,
	RXUSRCLK0,
	RXUSRCLK1,
	RXUSRCLK20,
	RXUSRCLK21,
	TXBUFDIFFCTRL0,
	TXBUFDIFFCTRL1,
	TXBYPASS8B10B0,
	TXBYPASS8B10B1,
	TXCHARDISPMODE0,
	TXCHARDISPMODE1,
	TXCHARDISPVAL0,
	TXCHARDISPVAL1,
	TXCHARISK0,
	TXCHARISK1,
	TXCOMSTART0,
	TXCOMSTART1,
	TXCOMTYPE0,
	TXCOMTYPE1,
	TXDATA0,
	TXDATA1,
	TXDATAWIDTH0,
	TXDATAWIDTH1,
	TXDETECTRX0,
	TXDETECTRX1,
	TXDIFFCTRL0,
	TXDIFFCTRL1,
	TXELECIDLE0,
	TXELECIDLE1,
	TXENC8B10BUSE0,
	TXENC8B10BUSE1,
	TXENPMAPHASEALIGN0,
	TXENPMAPHASEALIGN1,
	TXENPRBSTST0,
	TXENPRBSTST1,
	TXHEADER0,
	TXHEADER1,
	TXINHIBIT0,
	TXINHIBIT1,
	TXPMASETPHASE0,
	TXPMASETPHASE1,
	TXPOLARITY0,
	TXPOLARITY1,
	TXPOWERDOWN0,
	TXPOWERDOWN1,
	TXPREEMPHASIS0,
	TXPREEMPHASIS1,
	TXRESET0,
	TXRESET1,
	TXSEQUENCE0,
	TXSEQUENCE1,
	TXSTARTSEQ0,
	TXSTARTSEQ1,
	TXUSRCLK0,
	TXUSRCLK1,
	TXUSRCLK20,
	TXUSRCLK21

);

parameter AC_CAP_DIS_0 = "TRUE";
parameter AC_CAP_DIS_1 = "TRUE";
parameter CHAN_BOND_KEEP_ALIGN_0 = "FALSE";
parameter CHAN_BOND_KEEP_ALIGN_1 = "FALSE";
parameter CHAN_BOND_MODE_0 = "OFF";
parameter CHAN_BOND_MODE_1 = "OFF";
parameter CHAN_BOND_SEQ_2_USE_0 = "FALSE";
parameter CHAN_BOND_SEQ_2_USE_1 = "FALSE";
parameter CLKINDC_B = "TRUE";
parameter CLKRCV_TRST = "TRUE";
parameter CLK_CORRECT_USE_0 = "TRUE";
parameter CLK_CORRECT_USE_1 = "TRUE";
parameter CLK_COR_INSERT_IDLE_FLAG_0 = "FALSE";
parameter CLK_COR_INSERT_IDLE_FLAG_1 = "FALSE";
parameter CLK_COR_KEEP_IDLE_0 = "FALSE";
parameter CLK_COR_KEEP_IDLE_1 = "FALSE";
parameter CLK_COR_PRECEDENCE_0 = "TRUE";
parameter CLK_COR_PRECEDENCE_1 = "TRUE";
parameter CLK_COR_SEQ_2_USE_0 = "FALSE";
parameter CLK_COR_SEQ_2_USE_1 = "FALSE";
parameter COMMA_DOUBLE_0 = "FALSE";
parameter COMMA_DOUBLE_1 = "FALSE";
parameter DEC_MCOMMA_DETECT_0 = "TRUE";
parameter DEC_MCOMMA_DETECT_1 = "TRUE";
parameter DEC_PCOMMA_DETECT_0 = "TRUE";
parameter DEC_PCOMMA_DETECT_1 = "TRUE";
parameter DEC_VALID_COMMA_ONLY_0 = "TRUE";
parameter DEC_VALID_COMMA_ONLY_1 = "TRUE";
parameter MCOMMA_DETECT_0 = "TRUE";
parameter MCOMMA_DETECT_1 = "TRUE";
parameter OVERSAMPLE_MODE = "FALSE";
parameter PCI_EXPRESS_MODE_0 = "FALSE";
parameter PCI_EXPRESS_MODE_1 = "FALSE";
parameter PCOMMA_DETECT_0 = "TRUE";
parameter PCOMMA_DETECT_1 = "TRUE";
parameter PLL_FB_DCCEN = "FALSE";
parameter PLL_SATA_0 = "FALSE";
parameter PLL_SATA_1 = "FALSE";
parameter RCV_TERM_GND_0 = "FALSE";
parameter RCV_TERM_GND_1 = "FALSE";
parameter RCV_TERM_VTTRX_0 = "FALSE";
parameter RCV_TERM_VTTRX_1 = "FALSE";
parameter RXGEARBOX_USE_0 = "FALSE";
parameter RXGEARBOX_USE_1 = "FALSE";
parameter RX_BUFFER_USE_0 = "TRUE";
parameter RX_BUFFER_USE_1 = "TRUE";
parameter RX_DECODE_SEQ_MATCH_0 = "TRUE";
parameter RX_DECODE_SEQ_MATCH_1 = "TRUE";
parameter RX_EN_IDLE_HOLD_CDR = "FALSE";
parameter RX_EN_IDLE_HOLD_DFE_0 = "TRUE";
parameter RX_EN_IDLE_HOLD_DFE_1 = "TRUE";
parameter RX_EN_IDLE_RESET_BUF_0 = "TRUE";
parameter RX_EN_IDLE_RESET_BUF_1 = "TRUE";
parameter RX_EN_IDLE_RESET_FR = "TRUE";
parameter RX_EN_IDLE_RESET_PH = "TRUE";
parameter RX_LOSS_OF_SYNC_FSM_0 = "FALSE";
parameter RX_LOSS_OF_SYNC_FSM_1 = "FALSE";
parameter RX_SLIDE_MODE_0 = "PCS";
parameter RX_SLIDE_MODE_1 = "PCS";
parameter RX_STATUS_FMT_0 = "PCIE";
parameter RX_STATUS_FMT_1 = "PCIE";
parameter RX_XCLK_SEL_0 = "RXREC";
parameter RX_XCLK_SEL_1 = "RXREC";
parameter SIM_MODE = "FAST";
parameter SIM_PLL_PERDIV2 = 9'h140;
parameter SIM_RECEIVER_DETECT_PASS_0 = "TRUE";
parameter SIM_RECEIVER_DETECT_PASS_1 = "TRUE";
parameter TERMINATION_OVRD = "FALSE";
parameter TXGEARBOX_USE_0 = "FALSE";
parameter TXGEARBOX_USE_1 = "FALSE";
parameter TX_BUFFER_USE_0 = "TRUE";
parameter TX_BUFFER_USE_1 = "TRUE";
parameter TX_XCLK_SEL_0 = "TXOUT";
parameter TX_XCLK_SEL_1 = "TXOUT";
parameter [11:0] TRANS_TIME_FROM_P2_0 = 12'h03c;
parameter [11:0] TRANS_TIME_FROM_P2_1 = 12'h03c;
parameter [13:0] TX_DETECT_RX_CFG_0 = 14'h1832;
parameter [13:0] TX_DETECT_RX_CFG_1 = 14'h1832;
parameter [19:0] PMA_TX_CFG_0 = 20'h80082;
parameter [19:0] PMA_TX_CFG_1 = 20'h80082;
parameter [1:0] CM_TRIM_0 = 2'b10;
parameter [1:0] CM_TRIM_1 = 2'b10;
parameter [23:0] PLL_COM_CFG = 24'h21680a;
parameter [24:0] PMA_RX_CFG_0 = 25'h0f44089;
parameter [24:0] PMA_RX_CFG_1 = 25'h0f44089;
parameter [26:0] PMA_CDR_SCAN_0 = 27'h6404035;
parameter [26:0] PMA_CDR_SCAN_1 = 27'h6404035;
parameter [2:0] GEARBOX_ENDEC_0 = 3'b000;
parameter [2:0] GEARBOX_ENDEC_1 = 3'b000;
parameter [2:0] OOBDETECT_THRESHOLD_0 = 3'b110;
parameter [2:0] OOBDETECT_THRESHOLD_1 = 3'b110;
parameter [2:0] PLL_LKDET_CFG = 3'b101;
parameter [2:0] PLL_TDCC_CFG = 3'b000;
parameter [2:0] SATA_BURST_VAL_0 = 3'b100;
parameter [2:0] SATA_BURST_VAL_1 = 3'b100;
parameter [2:0] SATA_IDLE_VAL_0 = 3'b100;
parameter [2:0] SATA_IDLE_VAL_1 = 3'b100;
parameter [2:0] TXRX_INVERT_0 = 3'b011;
parameter [2:0] TXRX_INVERT_1 = 3'b011;
parameter [2:0] TX_IDLE_DELAY_0 = 3'b010;
parameter [2:0] TX_IDLE_DELAY_1 = 3'b010;
parameter [31:0] PRBS_ERR_THRESHOLD_0 = 32'h00000001;
parameter [31:0] PRBS_ERR_THRESHOLD_1 = 32'h00000001;
parameter [3:0] CHAN_BOND_SEQ_1_ENABLE_0 = 4'b0001;
parameter [3:0] CHAN_BOND_SEQ_1_ENABLE_1 = 4'b0001;
parameter [3:0] CHAN_BOND_SEQ_2_ENABLE_0 = 4'b0000;
parameter [3:0] CHAN_BOND_SEQ_2_ENABLE_1 = 4'b0000;
parameter [3:0] CLK_COR_SEQ_1_ENABLE_0 = 4'b0001;
parameter [3:0] CLK_COR_SEQ_1_ENABLE_1 = 4'b0001;
parameter [3:0] CLK_COR_SEQ_2_ENABLE_0 = 4'b0000;
parameter [3:0] CLK_COR_SEQ_2_ENABLE_1 = 4'b0000;
parameter [3:0] COM_BURST_VAL_0 = 4'b1111;
parameter [3:0] COM_BURST_VAL_1 = 4'b1111;
parameter [3:0] RX_IDLE_HI_CNT_0 = 4'b1000;
parameter [3:0] RX_IDLE_HI_CNT_1 = 4'b1000;
parameter [3:0] RX_IDLE_LO_CNT_0 = 4'b0000;
parameter [3:0] RX_IDLE_LO_CNT_1 = 4'b0000;
parameter [4:0] CDR_PH_ADJ_TIME = 5'b01010;
parameter [4:0] DFE_CAL_TIME = 5'b00110;
parameter [4:0] TERMINATION_CTRL = 5'b10100;
parameter [68:0] PMA_COM_CFG = 69'h0;
parameter [6:0] PMA_RXSYNC_CFG_0 = 7'h0;
parameter [6:0] PMA_RXSYNC_CFG_1 = 7'h0;
parameter [7:0] PLL_CP_CFG = 8'h00;
parameter [7:0] TRANS_TIME_NON_P2_0 = 8'h19;
parameter [7:0] TRANS_TIME_NON_P2_1 = 8'h19;
parameter [9:0] CHAN_BOND_SEQ_1_1_0 = 10'b0101111100;
parameter [9:0] CHAN_BOND_SEQ_1_1_1 = 10'b0101111100;
parameter [9:0] CHAN_BOND_SEQ_1_2_0 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_1_2_1 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_1_3_0 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_1_3_1 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_1_4_0 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_1_4_1 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_2_1_0 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_2_1_1 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_2_2_0 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_2_2_1 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_2_3_0 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_2_3_1 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_2_4_0 = 10'b0000000000;
parameter [9:0] CHAN_BOND_SEQ_2_4_1 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_1_1_0 = 10'b0100011100;
parameter [9:0] CLK_COR_SEQ_1_1_1 = 10'b0100011100;
parameter [9:0] CLK_COR_SEQ_1_2_0 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_1_2_1 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_1_3_0 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_1_3_1 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_1_4_0 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_1_4_1 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_2_1_0 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_2_1_1 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_2_2_0 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_2_2_1 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_2_3_0 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_2_3_1 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_2_4_0 = 10'b0000000000;
parameter [9:0] CLK_COR_SEQ_2_4_1 = 10'b0000000000;
parameter [9:0] COMMA_10B_ENABLE_0 = 10'b0001111111;
parameter [9:0] COMMA_10B_ENABLE_1 = 10'b0001111111;
parameter [9:0] DFE_CFG_0 = 10'b1101111011;
parameter [9:0] DFE_CFG_1 = 10'b1101111011;
parameter [9:0] MCOMMA_10B_VALUE_0 = 10'b1010000011;
parameter [9:0] MCOMMA_10B_VALUE_1 = 10'b1010000011;
parameter [9:0] PCOMMA_10B_VALUE_0 = 10'b0101111100;
parameter [9:0] PCOMMA_10B_VALUE_1 = 10'b0101111100;
parameter [9:0] TRANS_TIME_TO_P2_0 = 10'h064;
parameter [9:0] TRANS_TIME_TO_P2_1 = 10'h064;
parameter integer ALIGN_COMMA_WORD_0 = 1;
parameter integer ALIGN_COMMA_WORD_1 = 1;
parameter integer CB2_INH_CC_PERIOD_0 = 8;
parameter integer CB2_INH_CC_PERIOD_1 = 8;
parameter integer CHAN_BOND_1_MAX_SKEW_0 = 7;
parameter integer CHAN_BOND_1_MAX_SKEW_1 = 7;
parameter integer CHAN_BOND_2_MAX_SKEW_0 = 7;
parameter integer CHAN_BOND_2_MAX_SKEW_1 = 7;
parameter integer CHAN_BOND_LEVEL_0 = 0;
parameter integer CHAN_BOND_LEVEL_1 = 0;
parameter integer CHAN_BOND_SEQ_LEN_0 = 1;
parameter integer CHAN_BOND_SEQ_LEN_1 = 1;
parameter integer CLK25_DIVIDER = 10;
parameter integer CLK_COR_ADJ_LEN_0 = 1;
parameter integer CLK_COR_ADJ_LEN_1 = 1;
parameter integer CLK_COR_DET_LEN_0 = 1;
parameter integer CLK_COR_DET_LEN_1 = 1;
parameter integer CLK_COR_MAX_LAT_0 = 20;
parameter integer CLK_COR_MAX_LAT_1 = 20;
parameter integer CLK_COR_MIN_LAT_0 = 18;
parameter integer CLK_COR_MIN_LAT_1 = 18;
parameter integer CLK_COR_REPEAT_WAIT_0 = 0;
parameter integer CLK_COR_REPEAT_WAIT_1 = 0;
parameter integer OOB_CLK_DIVIDER = 6;
parameter integer PLL_DIVSEL_FB = 2;
parameter integer PLL_DIVSEL_REF = 1;
parameter integer PLL_RXDIVSEL_OUT_0 = 1;
parameter integer PLL_RXDIVSEL_OUT_1 = 1;
parameter integer PLL_TXDIVSEL_OUT_0 = 1;
parameter integer PLL_TXDIVSEL_OUT_1 = 1;
parameter integer RX_LOS_INVALID_INCR_0 = 1;
parameter integer RX_LOS_INVALID_INCR_1 = 1;
parameter integer RX_LOS_THRESHOLD_0 = 4;
parameter integer RX_LOS_THRESHOLD_1 = 4;
parameter integer SATA_MAX_BURST_0 = 7;
parameter integer SATA_MAX_BURST_1 = 7;
parameter integer SATA_MAX_INIT_0 = 22;
parameter integer SATA_MAX_INIT_1 = 22;
parameter integer SATA_MAX_WAKE_0 = 7;
parameter integer SATA_MAX_WAKE_1 = 7;
parameter integer SATA_MIN_BURST_0 = 4;
parameter integer SATA_MIN_BURST_1 = 4;
parameter integer SATA_MIN_INIT_0 = 12;
parameter integer SATA_MIN_INIT_1 = 12;
parameter integer SATA_MIN_WAKE_0 = 4;
parameter integer SATA_MIN_WAKE_1 = 4;
parameter integer SIM_GTXRESET_SPEEDUP = 1;
parameter integer TERMINATION_IMP_0 = 50;
parameter integer TERMINATION_IMP_1 = 50;


localparam in_delay =  0;
localparam out_delay = 0;
localparam CLK_DELAY = 0;

output DRDY;
output PHYSTATUS0;
output PHYSTATUS1;
output PLLLKDET;
output REFCLKOUT;
output RESETDONE0;
output RESETDONE1;
output RXBYTEISALIGNED0;
output RXBYTEISALIGNED1;
output RXBYTEREALIGN0;
output RXBYTEREALIGN1;
output RXCHANBONDSEQ0;
output RXCHANBONDSEQ1;
output RXCHANISALIGNED0;
output RXCHANISALIGNED1;
output RXCHANREALIGN0;
output RXCHANREALIGN1;
output RXCOMMADET0;
output RXCOMMADET1;
output RXDATAVALID0;
output RXDATAVALID1;
output RXELECIDLE0;
output RXELECIDLE1;
output RXHEADERVALID0;
output RXHEADERVALID1;
output RXOVERSAMPLEERR0;
output RXOVERSAMPLEERR1;
output RXPRBSERR0;
output RXPRBSERR1;
output RXRECCLK0;
output RXRECCLK1;
output RXSTARTOFSEQ0;
output RXSTARTOFSEQ1;
output RXVALID0;
output RXVALID1;
output TXGEARBOXREADY0;
output TXGEARBOXREADY1;
output TXN0;
output TXN1;
output TXOUTCLK0;
output TXOUTCLK1;
output TXP0;
output TXP1;
output [15:0] DO;
output [1:0] RXLOSSOFSYNC0;
output [1:0] RXLOSSOFSYNC1;
output [1:0] TXBUFSTATUS0;
output [1:0] TXBUFSTATUS1;
output [2:0] DFESENSCAL0;
output [2:0] DFESENSCAL1;
output [2:0] RXBUFSTATUS0;
output [2:0] RXBUFSTATUS1;
output [2:0] RXCLKCORCNT0;
output [2:0] RXCLKCORCNT1;
output [2:0] RXHEADER0;
output [2:0] RXHEADER1;
output [2:0] RXSTATUS0;
output [2:0] RXSTATUS1;
output [31:0] RXDATA0;
output [31:0] RXDATA1;
output [3:0] DFETAP3MONITOR0;
output [3:0] DFETAP3MONITOR1;
output [3:0] DFETAP4MONITOR0;
output [3:0] DFETAP4MONITOR1;
output [3:0] RXCHARISCOMMA0;
output [3:0] RXCHARISCOMMA1;
output [3:0] RXCHARISK0;
output [3:0] RXCHARISK1;
output [3:0] RXCHBONDO0;
output [3:0] RXCHBONDO1;
output [3:0] RXDISPERR0;
output [3:0] RXDISPERR1;
output [3:0] RXNOTINTABLE0;
output [3:0] RXNOTINTABLE1;
output [3:0] RXRUNDISP0;
output [3:0] RXRUNDISP1;
output [3:0] TXKERR0;
output [3:0] TXKERR1;
output [3:0] TXRUNDISP0;
output [3:0] TXRUNDISP1;
output [4:0] DFEEYEDACMONITOR0;
output [4:0] DFEEYEDACMONITOR1;
output [4:0] DFETAP1MONITOR0;
output [4:0] DFETAP1MONITOR1;
output [4:0] DFETAP2MONITOR0;
output [4:0] DFETAP2MONITOR1;
output [5:0] DFECLKDLYADJMONITOR0;
output [5:0] DFECLKDLYADJMONITOR1;

input CLKIN;
input DCLK;
input DEN;
input DWE;
input GTXRESET;
input INTDATAWIDTH;
input PLLLKDETEN;
input PLLPOWERDOWN;
input PRBSCNTRESET0;
input PRBSCNTRESET1;
input REFCLKPWRDNB;
input RXBUFRESET0;
input RXBUFRESET1;
input RXCDRRESET0;
input RXCDRRESET1;
input RXCOMMADETUSE0;
input RXCOMMADETUSE1;
input RXDEC8B10BUSE0;
input RXDEC8B10BUSE1;
input RXENCHANSYNC0;
input RXENCHANSYNC1;
input RXENEQB0;
input RXENEQB1;
input RXENMCOMMAALIGN0;
input RXENMCOMMAALIGN1;
input RXENPCOMMAALIGN0;
input RXENPCOMMAALIGN1;
input RXENPMAPHASEALIGN0;
input RXENPMAPHASEALIGN1;
input RXENSAMPLEALIGN0;
input RXENSAMPLEALIGN1;
input RXGEARBOXSLIP0;
input RXGEARBOXSLIP1;
input RXN0;
input RXN1;
input RXP0;
input RXP1;
input RXPMASETPHASE0;
input RXPMASETPHASE1;
input RXPOLARITY0;
input RXPOLARITY1;
input RXRESET0;
input RXRESET1;
input RXSLIDE0;
input RXSLIDE1;
input RXUSRCLK0;
input RXUSRCLK1;
input RXUSRCLK20;
input RXUSRCLK21;
input TXCOMSTART0;
input TXCOMSTART1;
input TXCOMTYPE0;
input TXCOMTYPE1;
input TXDETECTRX0;
input TXDETECTRX1;
input TXELECIDLE0;
input TXELECIDLE1;
input TXENC8B10BUSE0;
input TXENC8B10BUSE1;
input TXENPMAPHASEALIGN0;
input TXENPMAPHASEALIGN1;
input TXINHIBIT0;
input TXINHIBIT1;
input TXPMASETPHASE0;
input TXPMASETPHASE1;
input TXPOLARITY0;
input TXPOLARITY1;
input TXRESET0;
input TXRESET1;
input TXSTARTSEQ0;
input TXSTARTSEQ1;
input TXUSRCLK0;
input TXUSRCLK1;
input TXUSRCLK20;
input TXUSRCLK21;
input [13:0] GTXTEST;
input [15:0] DI;
input [1:0] RXDATAWIDTH0;
input [1:0] RXDATAWIDTH1;
input [1:0] RXENPRBSTST0;
input [1:0] RXENPRBSTST1;
input [1:0] RXEQMIX0;
input [1:0] RXEQMIX1;
input [1:0] RXPOWERDOWN0;
input [1:0] RXPOWERDOWN1;
input [1:0] TXDATAWIDTH0;
input [1:0] TXDATAWIDTH1;
input [1:0] TXENPRBSTST0;
input [1:0] TXENPRBSTST1;
input [1:0] TXPOWERDOWN0;
input [1:0] TXPOWERDOWN1;
input [2:0] LOOPBACK0;
input [2:0] LOOPBACK1;
input [2:0] TXBUFDIFFCTRL0;
input [2:0] TXBUFDIFFCTRL1;
input [2:0] TXDIFFCTRL0;
input [2:0] TXDIFFCTRL1;
input [2:0] TXHEADER0;
input [2:0] TXHEADER1;
input [31:0] TXDATA0;
input [31:0] TXDATA1;
input [3:0] DFETAP30;
input [3:0] DFETAP31;
input [3:0] DFETAP40;
input [3:0] DFETAP41;
input [3:0] RXCHBONDI0;
input [3:0] RXCHBONDI1;
input [3:0] RXEQPOLE0;
input [3:0] RXEQPOLE1;
input [3:0] TXBYPASS8B10B0;
input [3:0] TXBYPASS8B10B1;
input [3:0] TXCHARDISPMODE0;
input [3:0] TXCHARDISPMODE1;
input [3:0] TXCHARDISPVAL0;
input [3:0] TXCHARDISPVAL1;
input [3:0] TXCHARISK0;
input [3:0] TXCHARISK1;
input [3:0] TXPREEMPHASIS0;
input [3:0] TXPREEMPHASIS1;
input [4:0] DFETAP10;
input [4:0] DFETAP11;
input [4:0] DFETAP20;
input [4:0] DFETAP21;
input [5:0] DFECLKDLYADJ0;
input [5:0] DFECLKDLYADJ1;
input [6:0] DADDR;
input [6:0] TXSEQUENCE0;
input [6:0] TXSEQUENCE1;

reg AC_CAP_DIS_0_BINARY;
reg AC_CAP_DIS_1_BINARY;
reg ALIGN_COMMA_WORD_0_BINARY;
reg ALIGN_COMMA_WORD_1_BINARY;
reg CHAN_BOND_KEEP_ALIGN_0_BINARY;
reg CHAN_BOND_KEEP_ALIGN_1_BINARY;
reg [1:0] CHAN_BOND_MODE_0_BINARY;
reg [1:0] CHAN_BOND_MODE_1_BINARY;
reg CHAN_BOND_SEQ_2_USE_0_BINARY;
reg CHAN_BOND_SEQ_2_USE_1_BINARY;
reg CLKINDC_B_BINARY;
reg CLKRCV_TRST_BINARY;
reg CLK_CORRECT_USE_0_BINARY;
reg CLK_CORRECT_USE_1_BINARY;
reg CLK_COR_INSERT_IDLE_FLAG_0_BINARY;
reg CLK_COR_INSERT_IDLE_FLAG_1_BINARY;
reg CLK_COR_KEEP_IDLE_0_BINARY;
reg CLK_COR_KEEP_IDLE_1_BINARY;
reg CLK_COR_PRECEDENCE_0_BINARY;
reg CLK_COR_PRECEDENCE_1_BINARY;
reg CLK_COR_SEQ_2_USE_0_BINARY;
reg CLK_COR_SEQ_2_USE_1_BINARY;
reg COMMA_DOUBLE_0_BINARY;
reg COMMA_DOUBLE_1_BINARY;
reg DEC_MCOMMA_DETECT_0_BINARY;
reg DEC_MCOMMA_DETECT_1_BINARY;
reg DEC_PCOMMA_DETECT_0_BINARY;
reg DEC_PCOMMA_DETECT_1_BINARY;
reg DEC_VALID_COMMA_ONLY_0_BINARY;
reg DEC_VALID_COMMA_ONLY_1_BINARY;
reg MCOMMA_DETECT_0_BINARY;
reg MCOMMA_DETECT_1_BINARY;
reg OVERSAMPLE_MODE_BINARY;
reg PCI_EXPRESS_MODE_0_BINARY;
reg PCI_EXPRESS_MODE_1_BINARY;
reg PCOMMA_DETECT_0_BINARY;
reg PCOMMA_DETECT_1_BINARY;
reg PLL_FB_DCCEN_BINARY;
reg PLL_SATA_0_BINARY;
reg PLL_SATA_1_BINARY;
reg RCV_TERM_GND_0_BINARY;
reg RCV_TERM_GND_1_BINARY;
reg RCV_TERM_VTTRX_0_BINARY;
reg RCV_TERM_VTTRX_1_BINARY;
reg RXGEARBOX_USE_0_BINARY;
reg RXGEARBOX_USE_1_BINARY;
reg RX_BUFFER_USE_0_BINARY;
reg RX_BUFFER_USE_1_BINARY;
reg RX_DECODE_SEQ_MATCH_0_BINARY;
reg RX_DECODE_SEQ_MATCH_1_BINARY;
reg RX_EN_IDLE_HOLD_CDR_BINARY;
reg RX_EN_IDLE_HOLD_DFE_0_BINARY;
reg RX_EN_IDLE_HOLD_DFE_1_BINARY;
reg RX_EN_IDLE_RESET_BUF_0_BINARY;
reg RX_EN_IDLE_RESET_BUF_1_BINARY;
reg RX_EN_IDLE_RESET_FR_BINARY;
reg RX_EN_IDLE_RESET_PH_BINARY;
reg RX_LOSS_OF_SYNC_FSM_0_BINARY;
reg RX_LOSS_OF_SYNC_FSM_1_BINARY;
reg RX_SLIDE_MODE_0_BINARY;
reg RX_SLIDE_MODE_1_BINARY;
reg RX_STATUS_FMT_0_BINARY;
reg RX_STATUS_FMT_1_BINARY;
reg RX_XCLK_SEL_0_BINARY;
reg RX_XCLK_SEL_1_BINARY;
reg SIM_GTXRESET_SPEEDUP_BINARY;
reg SIM_MODE_BINARY;
reg SIM_RECEIVER_DETECT_PASS_0_BINARY;
reg SIM_RECEIVER_DETECT_PASS_1_BINARY;
reg TERMINATION_IMP_0_BINARY;
reg TERMINATION_IMP_1_BINARY;
reg TERMINATION_OVRD_BINARY;
reg TXGEARBOX_USE_0_BINARY;
reg TXGEARBOX_USE_1_BINARY;
reg TX_BUFFER_USE_0_BINARY;
reg TX_BUFFER_USE_1_BINARY;
reg TX_XCLK_SEL_0_BINARY;
reg TX_XCLK_SEL_1_BINARY;
reg [1:0] CHAN_BOND_SEQ_LEN_0_BINARY;
reg [1:0] CHAN_BOND_SEQ_LEN_1_BINARY;
reg [1:0] CLK_COR_ADJ_LEN_0_BINARY;
reg [1:0] CLK_COR_ADJ_LEN_1_BINARY;
reg [1:0] CLK_COR_DET_LEN_0_BINARY;
reg [1:0] CLK_COR_DET_LEN_1_BINARY;
reg [1:0] PLL_RXDIVSEL_OUT_0_BINARY;
reg [1:0] PLL_RXDIVSEL_OUT_1_BINARY;
reg [1:0] PLL_TXDIVSEL_OUT_0_BINARY;
reg [1:0] PLL_TXDIVSEL_OUT_1_BINARY;
reg [2:0] CHAN_BOND_LEVEL_0_BINARY;
reg [2:0] CHAN_BOND_LEVEL_1_BINARY;
reg [2:0] CLK25_DIVIDER_BINARY;
reg [2:0] OOB_CLK_DIVIDER_BINARY;
reg [2:0] OOBDETECT_THRESHOLD_0_BINARY;
reg [2:0] OOBDETECT_THRESHOLD_1_BINARY;
reg [2:0] RX_LOS_INVALID_INCR_0_BINARY;
reg [2:0] RX_LOS_INVALID_INCR_1_BINARY;
reg [2:0] RX_LOS_THRESHOLD_0_BINARY;
reg [2:0] RX_LOS_THRESHOLD_1_BINARY;
reg [3:0] CB2_INH_CC_PERIOD_0_BINARY;
reg [3:0] CB2_INH_CC_PERIOD_1_BINARY;
reg [3:0] CHAN_BOND_1_MAX_SKEW_0_BINARY;
reg [3:0] CHAN_BOND_1_MAX_SKEW_1_BINARY;
reg [3:0] CHAN_BOND_2_MAX_SKEW_0_BINARY;
reg [3:0] CHAN_BOND_2_MAX_SKEW_1_BINARY;
reg [4:0] CLK_COR_REPEAT_WAIT_0_BINARY;
reg [4:0] CLK_COR_REPEAT_WAIT_1_BINARY;
reg [4:0] PLL_DIVSEL_FB_BINARY;
reg [5:0] CLK_COR_MAX_LAT_0_BINARY;
reg [5:0] CLK_COR_MAX_LAT_1_BINARY;
reg [5:0] CLK_COR_MIN_LAT_0_BINARY;
reg [5:0] CLK_COR_MIN_LAT_1_BINARY;
reg [5:0] PLL_DIVSEL_REF_BINARY;
reg [5:0] SATA_MAX_BURST_0_BINARY;
reg [5:0] SATA_MAX_BURST_1_BINARY;
reg [5:0] SATA_MAX_INIT_0_BINARY;
reg [5:0] SATA_MAX_INIT_1_BINARY;
reg [5:0] SATA_MAX_WAKE_0_BINARY;
reg [5:0] SATA_MAX_WAKE_1_BINARY;
reg [5:0] SATA_MIN_BURST_0_BINARY;
reg [5:0] SATA_MIN_BURST_1_BINARY;
reg [5:0] SATA_MIN_INIT_0_BINARY;
reg [5:0] SATA_MIN_INIT_1_BINARY;
reg [5:0] SATA_MIN_WAKE_0_BINARY;
reg [5:0] SATA_MIN_WAKE_1_BINARY;

tri0 GSR = glbl.GSR;


initial begin
        
	case (PLL_TXDIVSEL_OUT_0)
		1 : PLL_TXDIVSEL_OUT_0_BINARY = 2'b00;
		2 : PLL_TXDIVSEL_OUT_0_BINARY = 2'b01;
		4 : PLL_TXDIVSEL_OUT_0_BINARY = 2'b10;
		default : begin
			$display("Attribute Syntax Error : The Attribute PLL_TXDIVSEL_OUT_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2 or 4.", PLL_TXDIVSEL_OUT_0);
			$finish;
		end
	endcase

	case (PLL_RXDIVSEL_OUT_0)
		1 : PLL_RXDIVSEL_OUT_0_BINARY = 2'b00;
		2 : PLL_RXDIVSEL_OUT_0_BINARY = 2'b01;
		4 : PLL_RXDIVSEL_OUT_0_BINARY = 2'b10;
		default : begin
			$display("Attribute Syntax Error : The Attribute PLL_RXDIVSEL_OUT_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2 or 4.", PLL_RXDIVSEL_OUT_0);
			$finish;
		end
	endcase

	case (PLL_TXDIVSEL_OUT_1)
		1 : PLL_TXDIVSEL_OUT_1_BINARY = 2'b00;
		2 : PLL_TXDIVSEL_OUT_1_BINARY = 2'b01;
		4 : PLL_TXDIVSEL_OUT_1_BINARY = 2'b10;
		default : begin
			$display("Attribute Syntax Error : The Attribute PLL_TXDIVSEL_OUT_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2 or 4.", PLL_TXDIVSEL_OUT_1);
			$finish;
		end
	endcase

	case (PLL_RXDIVSEL_OUT_1)
		1 : PLL_RXDIVSEL_OUT_1_BINARY = 2'b00;
		2 : PLL_RXDIVSEL_OUT_1_BINARY = 2'b01;
		4 : PLL_RXDIVSEL_OUT_1_BINARY = 2'b10;
		default : begin
			$display("Attribute Syntax Error : The Attribute PLL_RXDIVSEL_OUT_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2 or 4.", PLL_RXDIVSEL_OUT_1);
			$finish;
		end
	endcase

	case (PLL_DIVSEL_FB)
		1 : PLL_DIVSEL_FB_BINARY = 5'b10000;
		2 : PLL_DIVSEL_FB_BINARY = 5'b00000;
		3 : PLL_DIVSEL_FB_BINARY = 5'b00001;
		4 : PLL_DIVSEL_FB_BINARY = 5'b00010;
		5 : PLL_DIVSEL_FB_BINARY = 5'b00011;
		8 : PLL_DIVSEL_FB_BINARY = 5'b00110;
		10 : PLL_DIVSEL_FB_BINARY = 5'b00111;
		default : begin
			$display("Attribute Syntax Error : The Attribute PLL_DIVSEL_FB on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3, 4, 5, 8 or 10.", PLL_DIVSEL_FB);
			$finish;
		end
	endcase

	case (PLL_DIVSEL_REF)
		1 : PLL_DIVSEL_REF_BINARY = 6'b010000;
		2 : PLL_DIVSEL_REF_BINARY = 6'b000000;
		3 : PLL_DIVSEL_REF_BINARY = 6'b000001;
		4 : PLL_DIVSEL_REF_BINARY = 6'b000010;
		5 : PLL_DIVSEL_REF_BINARY = 6'b000011;
		6 : PLL_DIVSEL_REF_BINARY = 6'b000101;
		8 : PLL_DIVSEL_REF_BINARY = 6'b000110;
		10 : PLL_DIVSEL_REF_BINARY = 6'b000111;
		12 : PLL_DIVSEL_REF_BINARY = 6'b001101;
		16 : PLL_DIVSEL_REF_BINARY = 6'b001110;
		20 : PLL_DIVSEL_REF_BINARY = 6'b001111;
		default : begin
			$display("Attribute Syntax Error : The Attribute PLL_DIVSEL_REF on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3, 4, 5, 6, 8, 10, 12, 16 or 20.", PLL_DIVSEL_REF);
			$finish;
		end
	endcase

	case (PLL_SATA_0)
		"FALSE" : PLL_SATA_0_BINARY = 1'b0;
		"TRUE" : PLL_SATA_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute PLL_SATA_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PLL_SATA_0);
			$finish;
		end
	endcase

	case (PLL_SATA_1)
		"FALSE" : PLL_SATA_1_BINARY = 1'b0;
		"TRUE" : PLL_SATA_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute PLL_SATA_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PLL_SATA_1);
			$finish;
		end
	endcase

	case (OOB_CLK_DIVIDER)
		1 : OOB_CLK_DIVIDER_BINARY = 3'b000;
		2 : OOB_CLK_DIVIDER_BINARY = 3'b001;
		4 : OOB_CLK_DIVIDER_BINARY = 3'b010;
		6 : OOB_CLK_DIVIDER_BINARY = 3'b011;
		8 : OOB_CLK_DIVIDER_BINARY = 3'b100;
		10 : OOB_CLK_DIVIDER_BINARY = 3'b101;
		12 : OOB_CLK_DIVIDER_BINARY = 3'b110;
		14 : OOB_CLK_DIVIDER_BINARY = 3'b111;
		default : begin
			$display("Attribute Syntax Error : The Attribute OOB_CLK_DIVIDER on GTX_DUAL instance %m is set to %b.  Legal values for this attribute are 1, 2, 4, 6, 8, 10, 12 or 14.", OOB_CLK_DIVIDER);
			$finish;
		end
	endcase

        case (OOBDETECT_THRESHOLD_0)
	        3'b110 : OOBDETECT_THRESHOLD_0_BINARY  = 3'b110;
		3'b111 : OOBDETECT_THRESHOLD_0_BINARY  = 3'b111;
		default : begin
			$display("Attribute Syntax Warning : The Attribute OOBDETECT_THRESHOLD_0 on GTX_DUAL instance %m is set to %b.  Legal values for this attribute are 110 or 111.", OOBDETECT_THRESHOLD_0);
			//$finish;
		end
        endcase 

        case (OOBDETECT_THRESHOLD_1)
	        3'b110 : OOBDETECT_THRESHOLD_1_BINARY  = 3'b110;
		3'b111 : OOBDETECT_THRESHOLD_1_BINARY  = 3'b111;
		default : begin
			$display("Attribute Syntax Warning : The Attribute OOBDETECT_THRESHOLD_1 on GTX_DUAL instance %m is set to %b.  Legal values for this attribute are 110 or 111.", OOBDETECT_THRESHOLD_1);
			//$finish;
		end
        endcase 

	case (AC_CAP_DIS_0)
		"FALSE" : AC_CAP_DIS_0_BINARY = 1'b0;
		"TRUE" : AC_CAP_DIS_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute AC_CAP_DIS_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", AC_CAP_DIS_0);
			$finish;
		end
	endcase

	case (AC_CAP_DIS_1)
		"FALSE" : AC_CAP_DIS_1_BINARY = 1'b0;
		"TRUE" : AC_CAP_DIS_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute AC_CAP_DIS_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", AC_CAP_DIS_1);
			$finish;
		end
	endcase

	case (RCV_TERM_GND_0)
		"FALSE" : RCV_TERM_GND_0_BINARY = 1'b0;
		"TRUE" : RCV_TERM_GND_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RCV_TERM_GND_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RCV_TERM_GND_0);
			$finish;
		end
	endcase

	case (RCV_TERM_GND_1)
		"FALSE" : RCV_TERM_GND_1_BINARY = 1'b0;
		"TRUE" : RCV_TERM_GND_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RCV_TERM_GND_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RCV_TERM_GND_1);
			$finish;
		end
	endcase

	case (TERMINATION_IMP_0)
		50 : TERMINATION_IMP_0_BINARY = 1'b0;
		75 : TERMINATION_IMP_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute TERMINATION_IMP_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are  50 or 75.", TERMINATION_IMP_0);
			$finish;
		end
	endcase

	case (TERMINATION_IMP_1)
		50 : TERMINATION_IMP_1_BINARY = 1'b0;
		75 : TERMINATION_IMP_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute TERMINATION_IMP_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are  50 or 75.", TERMINATION_IMP_1);
			$finish;
		end
	endcase

	case (TERMINATION_OVRD)
		"FALSE" : TERMINATION_OVRD_BINARY = 1'b0;
		"TRUE" : TERMINATION_OVRD_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute TERMINATION_OVRD on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TERMINATION_OVRD);
			$finish;
		end
	endcase

	case (RCV_TERM_VTTRX_0)
		"FALSE" : RCV_TERM_VTTRX_0_BINARY = 1'b0;
		"TRUE" : RCV_TERM_VTTRX_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RCV_TERM_VTTRX_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RCV_TERM_VTTRX_0);
			$finish;
		end
	endcase

	case (RCV_TERM_VTTRX_1)
		"FALSE" : RCV_TERM_VTTRX_1_BINARY = 1'b0;
		"TRUE" : RCV_TERM_VTTRX_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RCV_TERM_VTTRX_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RCV_TERM_VTTRX_1);
			$finish;
		end
	endcase

	case (CLKINDC_B)
		"FALSE" : CLKINDC_B_BINARY = 1'b0;
		"TRUE" : CLKINDC_B_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLKINDC_B on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKINDC_B);
			$finish;
		end
	endcase

	case (PCOMMA_DETECT_0)
		"FALSE" : PCOMMA_DETECT_0_BINARY = 1'b0;
		"TRUE" : PCOMMA_DETECT_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute PCOMMA_DETECT_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PCOMMA_DETECT_0);
			$finish;
		end
	endcase

	case (MCOMMA_DETECT_0)
		"FALSE" : MCOMMA_DETECT_0_BINARY = 1'b0;
		"TRUE" : MCOMMA_DETECT_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute MCOMMA_DETECT_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MCOMMA_DETECT_0);
			$finish;
		end
	endcase

	case (COMMA_DOUBLE_0)
		"FALSE" : COMMA_DOUBLE_0_BINARY = 1'b0;
		"TRUE" : COMMA_DOUBLE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute COMMA_DOUBLE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", COMMA_DOUBLE_0);
			$finish;
		end
	endcase

	case (ALIGN_COMMA_WORD_0)
		1 : ALIGN_COMMA_WORD_0_BINARY = 1'b0;
		2 : ALIGN_COMMA_WORD_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute ALIGN_COMMA_WORD_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are  1 or 2.", ALIGN_COMMA_WORD_0);
			$finish;
		end
	endcase

	case (DEC_PCOMMA_DETECT_0)
		"FALSE" : DEC_PCOMMA_DETECT_0_BINARY = 1'b0;
		"TRUE" : DEC_PCOMMA_DETECT_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute DEC_PCOMMA_DETECT_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DEC_PCOMMA_DETECT_0);
			$finish;
		end
	endcase

	case (DEC_MCOMMA_DETECT_0)
		"FALSE" : DEC_MCOMMA_DETECT_0_BINARY = 1'b0;
		"TRUE" : DEC_MCOMMA_DETECT_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute DEC_MCOMMA_DETECT_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DEC_MCOMMA_DETECT_0);
			$finish;
		end
	endcase

	case (DEC_VALID_COMMA_ONLY_0)
		"FALSE" : DEC_VALID_COMMA_ONLY_0_BINARY = 1'b0;
		"TRUE" : DEC_VALID_COMMA_ONLY_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute DEC_VALID_COMMA_ONLY_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DEC_VALID_COMMA_ONLY_0);
			$finish;
		end
	endcase

	case (PCOMMA_DETECT_1)
		"FALSE" : PCOMMA_DETECT_1_BINARY = 1'b0;
		"TRUE" : PCOMMA_DETECT_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute PCOMMA_DETECT_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PCOMMA_DETECT_1);
			$finish;
		end
	endcase

	case (MCOMMA_DETECT_1)
		"FALSE" : MCOMMA_DETECT_1_BINARY = 1'b0;
		"TRUE" : MCOMMA_DETECT_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute MCOMMA_DETECT_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MCOMMA_DETECT_1);
			$finish;
		end
	endcase

	case (COMMA_DOUBLE_1)
		"FALSE" : COMMA_DOUBLE_1_BINARY = 1'b0;
		"TRUE" : COMMA_DOUBLE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute COMMA_DOUBLE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", COMMA_DOUBLE_1);
			$finish;
		end
	endcase

	case (ALIGN_COMMA_WORD_1)
		1 : ALIGN_COMMA_WORD_1_BINARY = 1'b0;
		2 : ALIGN_COMMA_WORD_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute ALIGN_COMMA_WORD_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are  1 or 2.", ALIGN_COMMA_WORD_1);
			$finish;
		end
	endcase

	case (DEC_PCOMMA_DETECT_1)
		"FALSE" : DEC_PCOMMA_DETECT_1_BINARY = 1'b0;
		"TRUE" : DEC_PCOMMA_DETECT_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute DEC_PCOMMA_DETECT_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DEC_PCOMMA_DETECT_1);
			$finish;
		end
	endcase

	case (DEC_MCOMMA_DETECT_1)
		"FALSE" : DEC_MCOMMA_DETECT_1_BINARY = 1'b0;
		"TRUE" : DEC_MCOMMA_DETECT_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute DEC_MCOMMA_DETECT_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DEC_MCOMMA_DETECT_1);
			$finish;
		end
	endcase

	case (DEC_VALID_COMMA_ONLY_1)
		"FALSE" : DEC_VALID_COMMA_ONLY_1_BINARY = 1'b0;
		"TRUE" : DEC_VALID_COMMA_ONLY_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute DEC_VALID_COMMA_ONLY_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DEC_VALID_COMMA_ONLY_1);
			$finish;
		end
	endcase

	case (RX_LOSS_OF_SYNC_FSM_0)
		"FALSE" : RX_LOSS_OF_SYNC_FSM_0_BINARY = 1'b0;
		"TRUE" : RX_LOSS_OF_SYNC_FSM_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_LOSS_OF_SYNC_FSM_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_LOSS_OF_SYNC_FSM_0);
			$finish;
		end
	endcase

	case (RX_LOS_INVALID_INCR_0)
		1 : RX_LOS_INVALID_INCR_0_BINARY = 3'b000;
		2 : RX_LOS_INVALID_INCR_0_BINARY = 3'b001;
		4 : RX_LOS_INVALID_INCR_0_BINARY = 3'b010;
		8 : RX_LOS_INVALID_INCR_0_BINARY = 3'b011;
		16 : RX_LOS_INVALID_INCR_0_BINARY = 3'b100;
		32 : RX_LOS_INVALID_INCR_0_BINARY = 3'b101;
		64 : RX_LOS_INVALID_INCR_0_BINARY = 3'b110;
		128 : RX_LOS_INVALID_INCR_0_BINARY = 3'b111;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_LOS_INVALID_INCR_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 4, 8, 16, 32, 64 or 128.", RX_LOS_INVALID_INCR_0);
			$finish;
		end
	endcase

	case (RX_LOS_THRESHOLD_0)
		4 : RX_LOS_THRESHOLD_0_BINARY = 3'b000;
		8 : RX_LOS_THRESHOLD_0_BINARY = 3'b001;
		16 : RX_LOS_THRESHOLD_0_BINARY = 3'b010;
		32 : RX_LOS_THRESHOLD_0_BINARY = 3'b011;
		64 : RX_LOS_THRESHOLD_0_BINARY = 3'b100;
		128 : RX_LOS_THRESHOLD_0_BINARY = 3'b101;
		256 : RX_LOS_THRESHOLD_0_BINARY = 3'b110;
		512 : RX_LOS_THRESHOLD_0_BINARY = 3'b111;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_LOS_THRESHOLD_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 4, 8, 16, 32, 64, 128, 256 or 512.", RX_LOS_THRESHOLD_0);
			$finish;
		end
	endcase

	case (RX_LOSS_OF_SYNC_FSM_1)
		"FALSE" : RX_LOSS_OF_SYNC_FSM_1_BINARY = 1'b0;
		"TRUE" : RX_LOSS_OF_SYNC_FSM_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_LOSS_OF_SYNC_FSM_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_LOSS_OF_SYNC_FSM_1);
			$finish;
		end
	endcase

	case (RX_LOS_INVALID_INCR_1)
		1 : RX_LOS_INVALID_INCR_1_BINARY = 3'b000;
		2 : RX_LOS_INVALID_INCR_1_BINARY = 3'b001;
		4 : RX_LOS_INVALID_INCR_1_BINARY = 3'b010;
		8 : RX_LOS_INVALID_INCR_1_BINARY = 3'b011;
		16 : RX_LOS_INVALID_INCR_1_BINARY = 3'b100;
		32 : RX_LOS_INVALID_INCR_1_BINARY = 3'b101;
		64 : RX_LOS_INVALID_INCR_1_BINARY = 3'b110;
		128 : RX_LOS_INVALID_INCR_1_BINARY = 3'b111;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_LOS_INVALID_INCR_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 4, 8, 16, 32, 64 or 128.", RX_LOS_INVALID_INCR_1);
			$finish;
		end
	endcase

	case (RX_LOS_THRESHOLD_1)
		4 : RX_LOS_THRESHOLD_1_BINARY = 3'b000;
		8 : RX_LOS_THRESHOLD_1_BINARY = 3'b001;
		16 : RX_LOS_THRESHOLD_1_BINARY = 3'b010;
		32 : RX_LOS_THRESHOLD_1_BINARY = 3'b011;
		64 : RX_LOS_THRESHOLD_1_BINARY = 3'b100;
		128 : RX_LOS_THRESHOLD_1_BINARY = 3'b101;
		256 : RX_LOS_THRESHOLD_1_BINARY = 3'b110;
		512 : RX_LOS_THRESHOLD_1_BINARY = 3'b111;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_LOS_THRESHOLD_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 4, 8, 16, 32, 64, 128, 256 or 512.", RX_LOS_THRESHOLD_1);
			$finish;
		end
	endcase

	case (RX_BUFFER_USE_0)
		"FALSE" : RX_BUFFER_USE_0_BINARY = 1'b0;
		"TRUE" : RX_BUFFER_USE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_BUFFER_USE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_BUFFER_USE_0);
			$finish;
		end
	endcase

	case (RX_DECODE_SEQ_MATCH_0)
		"FALSE" : RX_DECODE_SEQ_MATCH_0_BINARY = 1'b0;
		"TRUE" : RX_DECODE_SEQ_MATCH_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_DECODE_SEQ_MATCH_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_DECODE_SEQ_MATCH_0);
			$finish;
		end
	endcase

	case (RX_BUFFER_USE_1)
		"FALSE" : RX_BUFFER_USE_1_BINARY = 1'b0;
		"TRUE" : RX_BUFFER_USE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_BUFFER_USE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_BUFFER_USE_1);
			$finish;
		end
	endcase

	case (RX_DECODE_SEQ_MATCH_1)
		"FALSE" : RX_DECODE_SEQ_MATCH_1_BINARY = 1'b0;
		"TRUE" : RX_DECODE_SEQ_MATCH_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_DECODE_SEQ_MATCH_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_DECODE_SEQ_MATCH_1);
			$finish;
		end
	endcase

	case (CLK_COR_MIN_LAT_0)
		3 : CLK_COR_MIN_LAT_0_BINARY = 6'b000011;
		4 : CLK_COR_MIN_LAT_0_BINARY = 6'b000100;
		5 : CLK_COR_MIN_LAT_0_BINARY = 6'b000101;
		6 : CLK_COR_MIN_LAT_0_BINARY = 6'b000110;
		7 : CLK_COR_MIN_LAT_0_BINARY = 6'b000111;
		8 : CLK_COR_MIN_LAT_0_BINARY = 6'b001000;
		9 : CLK_COR_MIN_LAT_0_BINARY = 6'b001001;
		10 : CLK_COR_MIN_LAT_0_BINARY = 6'b001010;
		11 : CLK_COR_MIN_LAT_0_BINARY = 6'b001011;
		12 : CLK_COR_MIN_LAT_0_BINARY = 6'b001100;
		13 : CLK_COR_MIN_LAT_0_BINARY = 6'b001101;
		14 : CLK_COR_MIN_LAT_0_BINARY = 6'b001110;
		15 : CLK_COR_MIN_LAT_0_BINARY = 6'b001111;
		16 : CLK_COR_MIN_LAT_0_BINARY = 6'b010000;
		17 : CLK_COR_MIN_LAT_0_BINARY = 6'b010001;
		18 : CLK_COR_MIN_LAT_0_BINARY = 6'b010010;
		19 : CLK_COR_MIN_LAT_0_BINARY = 6'b010011;
		20 : CLK_COR_MIN_LAT_0_BINARY = 6'b010100;
		21 : CLK_COR_MIN_LAT_0_BINARY = 6'b010101;
		22 : CLK_COR_MIN_LAT_0_BINARY = 6'b010110;
		23 : CLK_COR_MIN_LAT_0_BINARY = 6'b010111;
		24 : CLK_COR_MIN_LAT_0_BINARY = 6'b011000;
		25 : CLK_COR_MIN_LAT_0_BINARY = 6'b011001;
		26 : CLK_COR_MIN_LAT_0_BINARY = 6'b011010;
		27 : CLK_COR_MIN_LAT_0_BINARY = 6'b011011;
		28 : CLK_COR_MIN_LAT_0_BINARY = 6'b011100;
		29 : CLK_COR_MIN_LAT_0_BINARY = 6'b011101;
		30 : CLK_COR_MIN_LAT_0_BINARY = 6'b011110;
		31 : CLK_COR_MIN_LAT_0_BINARY = 6'b011111;
		32 : CLK_COR_MIN_LAT_0_BINARY = 6'b100000;
		33 : CLK_COR_MIN_LAT_0_BINARY = 6'b100001;
		34 : CLK_COR_MIN_LAT_0_BINARY = 6'b100010;
		35 : CLK_COR_MIN_LAT_0_BINARY = 6'b100011;
		36 : CLK_COR_MIN_LAT_0_BINARY = 6'b100100;
		37 : CLK_COR_MIN_LAT_0_BINARY = 6'b100101;
		38 : CLK_COR_MIN_LAT_0_BINARY = 6'b100110;
		39 : CLK_COR_MIN_LAT_0_BINARY = 6'b100111;
		40 : CLK_COR_MIN_LAT_0_BINARY = 6'b101000;
		41 : CLK_COR_MIN_LAT_0_BINARY = 6'b101001;
		42 : CLK_COR_MIN_LAT_0_BINARY = 6'b101010;
		43 : CLK_COR_MIN_LAT_0_BINARY = 6'b101011;
		44 : CLK_COR_MIN_LAT_0_BINARY = 6'b101100;
		45 : CLK_COR_MIN_LAT_0_BINARY = 6'b101101;
		46 : CLK_COR_MIN_LAT_0_BINARY = 6'b101110;
		47 : CLK_COR_MIN_LAT_0_BINARY = 6'b101111;
		48 : CLK_COR_MIN_LAT_0_BINARY = 6'b110000;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_MIN_LAT_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 3 to 48.", CLK_COR_MIN_LAT_0);
			$finish;
		end
	endcase

	case (CLK_COR_MAX_LAT_0)
		3 : CLK_COR_MAX_LAT_0_BINARY = 6'b000011;
		4 : CLK_COR_MAX_LAT_0_BINARY = 6'b000100;
		5 : CLK_COR_MAX_LAT_0_BINARY = 6'b000101;
		6 : CLK_COR_MAX_LAT_0_BINARY = 6'b000110;
		7 : CLK_COR_MAX_LAT_0_BINARY = 6'b000111;
		8 : CLK_COR_MAX_LAT_0_BINARY = 6'b001000;
		9 : CLK_COR_MAX_LAT_0_BINARY = 6'b001001;
		10 : CLK_COR_MAX_LAT_0_BINARY = 6'b001010;
		11 : CLK_COR_MAX_LAT_0_BINARY = 6'b001011;
		12 : CLK_COR_MAX_LAT_0_BINARY = 6'b001100;
		13 : CLK_COR_MAX_LAT_0_BINARY = 6'b001101;
		14 : CLK_COR_MAX_LAT_0_BINARY = 6'b001110;
		15 : CLK_COR_MAX_LAT_0_BINARY = 6'b001111;
		16 : CLK_COR_MAX_LAT_0_BINARY = 6'b010000;
		17 : CLK_COR_MAX_LAT_0_BINARY = 6'b010001;
		18 : CLK_COR_MAX_LAT_0_BINARY = 6'b010010;
		19 : CLK_COR_MAX_LAT_0_BINARY = 6'b010011;
		20 : CLK_COR_MAX_LAT_0_BINARY = 6'b010100;
		21 : CLK_COR_MAX_LAT_0_BINARY = 6'b010101;
		22 : CLK_COR_MAX_LAT_0_BINARY = 6'b010110;
		23 : CLK_COR_MAX_LAT_0_BINARY = 6'b010111;
		24 : CLK_COR_MAX_LAT_0_BINARY = 6'b011000;
		25 : CLK_COR_MAX_LAT_0_BINARY = 6'b011001;
		26 : CLK_COR_MAX_LAT_0_BINARY = 6'b011010;
		27 : CLK_COR_MAX_LAT_0_BINARY = 6'b011011;
		28 : CLK_COR_MAX_LAT_0_BINARY = 6'b011100;
		29 : CLK_COR_MAX_LAT_0_BINARY = 6'b011101;
		30 : CLK_COR_MAX_LAT_0_BINARY = 6'b011110;
		31 : CLK_COR_MAX_LAT_0_BINARY = 6'b011111;
		32 : CLK_COR_MAX_LAT_0_BINARY = 6'b100000;
		33 : CLK_COR_MAX_LAT_0_BINARY = 6'b100001;
		34 : CLK_COR_MAX_LAT_0_BINARY = 6'b100010;
		35 : CLK_COR_MAX_LAT_0_BINARY = 6'b100011;
		36 : CLK_COR_MAX_LAT_0_BINARY = 6'b100100;
		37 : CLK_COR_MAX_LAT_0_BINARY = 6'b100101;
		38 : CLK_COR_MAX_LAT_0_BINARY = 6'b100110;
		39 : CLK_COR_MAX_LAT_0_BINARY = 6'b100111;
		40 : CLK_COR_MAX_LAT_0_BINARY = 6'b101000;
		41 : CLK_COR_MAX_LAT_0_BINARY = 6'b101001;
		42 : CLK_COR_MAX_LAT_0_BINARY = 6'b101010;
		43 : CLK_COR_MAX_LAT_0_BINARY = 6'b101011;
		44 : CLK_COR_MAX_LAT_0_BINARY = 6'b101100;
		45 : CLK_COR_MAX_LAT_0_BINARY = 6'b101101;
		46 : CLK_COR_MAX_LAT_0_BINARY = 6'b101110;
		47 : CLK_COR_MAX_LAT_0_BINARY = 6'b101111;
		48 : CLK_COR_MAX_LAT_0_BINARY = 6'b110000;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_MAX_LAT_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 3 to 48.", CLK_COR_MAX_LAT_0);
			$finish;
		end
	endcase

	case (CLK_CORRECT_USE_0)
		"FALSE" : CLK_CORRECT_USE_0_BINARY = 1'b0;
		"TRUE" : CLK_CORRECT_USE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_CORRECT_USE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_CORRECT_USE_0);
			$finish;
		end
	endcase

	case (CLK_COR_PRECEDENCE_0)
		"FALSE" : CLK_COR_PRECEDENCE_0_BINARY = 1'b0;
		"TRUE" : CLK_COR_PRECEDENCE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_PRECEDENCE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_PRECEDENCE_0);
			$finish;
		end
	endcase

	case (CLK_COR_DET_LEN_0)
		1 : CLK_COR_DET_LEN_0_BINARY = 2'b00;
		2 : CLK_COR_DET_LEN_0_BINARY = 2'b01;
		3 : CLK_COR_DET_LEN_0_BINARY = 2'b10;
		4 : CLK_COR_DET_LEN_0_BINARY = 2'b11;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_DET_LEN_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3 or 4.", CLK_COR_DET_LEN_0);
			$finish;
		end
	endcase

	case (CLK_COR_ADJ_LEN_0)
		1 : CLK_COR_ADJ_LEN_0_BINARY = 2'b00;
		2 : CLK_COR_ADJ_LEN_0_BINARY = 2'b01;
		3 : CLK_COR_ADJ_LEN_0_BINARY = 2'b10;
		4 : CLK_COR_ADJ_LEN_0_BINARY = 2'b11;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_ADJ_LEN_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3 or 4.", CLK_COR_ADJ_LEN_0);
			$finish;
		end
	endcase

	case (CLK_COR_KEEP_IDLE_0)
		"FALSE" : CLK_COR_KEEP_IDLE_0_BINARY = 1'b0;
		"TRUE" : CLK_COR_KEEP_IDLE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_KEEP_IDLE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_KEEP_IDLE_0);
			$finish;
		end
	endcase

	case (CLK_COR_INSERT_IDLE_FLAG_0)
		"FALSE" : CLK_COR_INSERT_IDLE_FLAG_0_BINARY = 1'b0;
		"TRUE" : CLK_COR_INSERT_IDLE_FLAG_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_INSERT_IDLE_FLAG_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_INSERT_IDLE_FLAG_0);
			$finish;
		end
	endcase

	case (CLK_COR_REPEAT_WAIT_0)
		0 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b00000;
		1 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b00001;
		2 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b00010;
		3 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b00011;
		4 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b00100;
		5 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b00101;
		6 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b00110;
		7 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b00111;
		8 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b01000;
		9 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b01001;
		10 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b01010;
		11 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b01011;
		12 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b01100;
		13 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b01101;
		14 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b01110;
		15 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b01111;
		16 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b10000;
		17 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b10001;
		18 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b10010;
		19 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b10011;
		20 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b10100;
		21 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b10101;
		22 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b10110;
		23 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b10111;
		24 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b11000;
		25 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b11001;
		26 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b11010;
		27 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b11011;
		28 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b11100;
		29 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b11101;
		30 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b11110;
		31 : CLK_COR_REPEAT_WAIT_0_BINARY = 5'b11111;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_REPEAT_WAIT_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 0 to 31.", CLK_COR_REPEAT_WAIT_0);
			$finish;
		end
	endcase

	case (CLK_COR_SEQ_2_USE_0)
		"FALSE" : CLK_COR_SEQ_2_USE_0_BINARY = 1'b0;
		"TRUE" : CLK_COR_SEQ_2_USE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_2_USE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_SEQ_2_USE_0);
			$finish;
		end
	endcase

	case (CLK_COR_MIN_LAT_1)
		3 : CLK_COR_MIN_LAT_1_BINARY = 6'b000011;
		4 : CLK_COR_MIN_LAT_1_BINARY = 6'b000100;
		5 : CLK_COR_MIN_LAT_1_BINARY = 6'b000101;
		6 : CLK_COR_MIN_LAT_1_BINARY = 6'b000110;
		7 : CLK_COR_MIN_LAT_1_BINARY = 6'b000111;
		8 : CLK_COR_MIN_LAT_1_BINARY = 6'b001000;
		9 : CLK_COR_MIN_LAT_1_BINARY = 6'b001001;
		10 : CLK_COR_MIN_LAT_1_BINARY = 6'b001010;
		11 : CLK_COR_MIN_LAT_1_BINARY = 6'b001011;
		12 : CLK_COR_MIN_LAT_1_BINARY = 6'b001100;
		13 : CLK_COR_MIN_LAT_1_BINARY = 6'b001101;
		14 : CLK_COR_MIN_LAT_1_BINARY = 6'b001110;
		15 : CLK_COR_MIN_LAT_1_BINARY = 6'b001111;
		16 : CLK_COR_MIN_LAT_1_BINARY = 6'b010000;
		17 : CLK_COR_MIN_LAT_1_BINARY = 6'b010001;
		18 : CLK_COR_MIN_LAT_1_BINARY = 6'b010010;
		19 : CLK_COR_MIN_LAT_1_BINARY = 6'b010011;
		20 : CLK_COR_MIN_LAT_1_BINARY = 6'b010100;
		21 : CLK_COR_MIN_LAT_1_BINARY = 6'b010101;
		22 : CLK_COR_MIN_LAT_1_BINARY = 6'b010110;
		23 : CLK_COR_MIN_LAT_1_BINARY = 6'b010111;
		24 : CLK_COR_MIN_LAT_1_BINARY = 6'b011000;
		25 : CLK_COR_MIN_LAT_1_BINARY = 6'b011001;
		26 : CLK_COR_MIN_LAT_1_BINARY = 6'b011010;
		27 : CLK_COR_MIN_LAT_1_BINARY = 6'b011011;
		28 : CLK_COR_MIN_LAT_1_BINARY = 6'b011100;
		29 : CLK_COR_MIN_LAT_1_BINARY = 6'b011101;
		30 : CLK_COR_MIN_LAT_1_BINARY = 6'b011110;
		31 : CLK_COR_MIN_LAT_1_BINARY = 6'b011111;
		32 : CLK_COR_MIN_LAT_1_BINARY = 6'b100000;
		33 : CLK_COR_MIN_LAT_1_BINARY = 6'b100001;
		34 : CLK_COR_MIN_LAT_1_BINARY = 6'b100010;
		35 : CLK_COR_MIN_LAT_1_BINARY = 6'b100011;
		36 : CLK_COR_MIN_LAT_1_BINARY = 6'b100100;
		37 : CLK_COR_MIN_LAT_1_BINARY = 6'b100101;
		38 : CLK_COR_MIN_LAT_1_BINARY = 6'b100110;
		39 : CLK_COR_MIN_LAT_1_BINARY = 6'b100111;
		40 : CLK_COR_MIN_LAT_1_BINARY = 6'b101000;
		41 : CLK_COR_MIN_LAT_1_BINARY = 6'b101001;
		42 : CLK_COR_MIN_LAT_1_BINARY = 6'b101010;
		43 : CLK_COR_MIN_LAT_1_BINARY = 6'b101011;
		44 : CLK_COR_MIN_LAT_1_BINARY = 6'b101100;
		45 : CLK_COR_MIN_LAT_1_BINARY = 6'b101101;
		46 : CLK_COR_MIN_LAT_1_BINARY = 6'b101110;
		47 : CLK_COR_MIN_LAT_1_BINARY = 6'b101111;
		48 : CLK_COR_MIN_LAT_1_BINARY = 6'b110000;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_MIN_LAT_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 3 to 48.", CLK_COR_MIN_LAT_1);
			$finish;
		end
	endcase

	case (CLK_COR_MAX_LAT_1)
		3 : CLK_COR_MAX_LAT_1_BINARY = 6'b000011;
		4 : CLK_COR_MAX_LAT_1_BINARY = 6'b000100;
		5 : CLK_COR_MAX_LAT_1_BINARY = 6'b000101;
		6 : CLK_COR_MAX_LAT_1_BINARY = 6'b000110;
		7 : CLK_COR_MAX_LAT_1_BINARY = 6'b000111;
		8 : CLK_COR_MAX_LAT_1_BINARY = 6'b001000;
		9 : CLK_COR_MAX_LAT_1_BINARY = 6'b001001;
		10 : CLK_COR_MAX_LAT_1_BINARY = 6'b001010;
		11 : CLK_COR_MAX_LAT_1_BINARY = 6'b001011;
		12 : CLK_COR_MAX_LAT_1_BINARY = 6'b001100;
		13 : CLK_COR_MAX_LAT_1_BINARY = 6'b001101;
		14 : CLK_COR_MAX_LAT_1_BINARY = 6'b001110;
		15 : CLK_COR_MAX_LAT_1_BINARY = 6'b001111;
		16 : CLK_COR_MAX_LAT_1_BINARY = 6'b010000;
		17 : CLK_COR_MAX_LAT_1_BINARY = 6'b010001;
		18 : CLK_COR_MAX_LAT_1_BINARY = 6'b010010;
		19 : CLK_COR_MAX_LAT_1_BINARY = 6'b010011;
		20 : CLK_COR_MAX_LAT_1_BINARY = 6'b010100;
		21 : CLK_COR_MAX_LAT_1_BINARY = 6'b010101;
		22 : CLK_COR_MAX_LAT_1_BINARY = 6'b010110;
		23 : CLK_COR_MAX_LAT_1_BINARY = 6'b010111;
		24 : CLK_COR_MAX_LAT_1_BINARY = 6'b011000;
		25 : CLK_COR_MAX_LAT_1_BINARY = 6'b011001;
		26 : CLK_COR_MAX_LAT_1_BINARY = 6'b011010;
		27 : CLK_COR_MAX_LAT_1_BINARY = 6'b011011;
		28 : CLK_COR_MAX_LAT_1_BINARY = 6'b011100;
		29 : CLK_COR_MAX_LAT_1_BINARY = 6'b011101;
		30 : CLK_COR_MAX_LAT_1_BINARY = 6'b011110;
		31 : CLK_COR_MAX_LAT_1_BINARY = 6'b011111;
		32 : CLK_COR_MAX_LAT_1_BINARY = 6'b100000;
		33 : CLK_COR_MAX_LAT_1_BINARY = 6'b100001;
		34 : CLK_COR_MAX_LAT_1_BINARY = 6'b100010;
		35 : CLK_COR_MAX_LAT_1_BINARY = 6'b100011;
		36 : CLK_COR_MAX_LAT_1_BINARY = 6'b100100;
		37 : CLK_COR_MAX_LAT_1_BINARY = 6'b100101;
		38 : CLK_COR_MAX_LAT_1_BINARY = 6'b100110;
		39 : CLK_COR_MAX_LAT_1_BINARY = 6'b100111;
		40 : CLK_COR_MAX_LAT_1_BINARY = 6'b101000;
		41 : CLK_COR_MAX_LAT_1_BINARY = 6'b101001;
		42 : CLK_COR_MAX_LAT_1_BINARY = 6'b101010;
		43 : CLK_COR_MAX_LAT_1_BINARY = 6'b101011;
		44 : CLK_COR_MAX_LAT_1_BINARY = 6'b101100;
		45 : CLK_COR_MAX_LAT_1_BINARY = 6'b101101;
		46 : CLK_COR_MAX_LAT_1_BINARY = 6'b101110;
		47 : CLK_COR_MAX_LAT_1_BINARY = 6'b101111;
		48 : CLK_COR_MAX_LAT_1_BINARY = 6'b110000;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_MAX_LAT_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 3 to 48.", CLK_COR_MAX_LAT_1);
			$finish;
		end
	endcase

	case (CLK_CORRECT_USE_1)
		"FALSE" : CLK_CORRECT_USE_1_BINARY = 1'b0;
		"TRUE" : CLK_CORRECT_USE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_CORRECT_USE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_CORRECT_USE_1);
			$finish;
		end
	endcase

	case (CLK_COR_PRECEDENCE_1)
		"FALSE" : CLK_COR_PRECEDENCE_1_BINARY = 1'b0;
		"TRUE" : CLK_COR_PRECEDENCE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_PRECEDENCE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_PRECEDENCE_1);
			$finish;
		end
	endcase

	case (CLK_COR_DET_LEN_1)
		1 : CLK_COR_DET_LEN_1_BINARY = 2'b00;
		2 : CLK_COR_DET_LEN_1_BINARY = 2'b01;
		3 : CLK_COR_DET_LEN_1_BINARY = 2'b10;
		4 : CLK_COR_DET_LEN_1_BINARY = 2'b11;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_DET_LEN_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3 or 4.", CLK_COR_DET_LEN_1);
			$finish;
		end
	endcase

	case (CLK_COR_ADJ_LEN_1)
		1 : CLK_COR_ADJ_LEN_1_BINARY = 2'b00;
		2 : CLK_COR_ADJ_LEN_1_BINARY = 2'b01;
		3 : CLK_COR_ADJ_LEN_1_BINARY = 2'b10;
		4 : CLK_COR_ADJ_LEN_1_BINARY = 2'b11;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_ADJ_LEN_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3 or 4.", CLK_COR_ADJ_LEN_1);
			$finish;
		end
	endcase

	case (CLK_COR_KEEP_IDLE_1)
		"FALSE" : CLK_COR_KEEP_IDLE_1_BINARY = 1'b0;
		"TRUE" : CLK_COR_KEEP_IDLE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_KEEP_IDLE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_KEEP_IDLE_1);
			$finish;
		end
	endcase

	case (CLK_COR_INSERT_IDLE_FLAG_1)
		"FALSE" : CLK_COR_INSERT_IDLE_FLAG_1_BINARY = 1'b0;
		"TRUE" : CLK_COR_INSERT_IDLE_FLAG_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_INSERT_IDLE_FLAG_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_INSERT_IDLE_FLAG_1);
			$finish;
		end
	endcase

	case (CLK_COR_REPEAT_WAIT_1)
		0 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b00000;
		1 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b00001;
		2 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b00010;
		3 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b00011;
		4 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b00100;
		5 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b00101;
		6 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b00110;
		7 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b00111;
		8 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b01000;
		9 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b01001;
		10 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b01010;
		11 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b01011;
		12 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b01100;
		13 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b01101;
		14 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b01110;
		15 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b01111;
		16 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b10000;
		17 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b10001;
		18 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b10010;
		19 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b10011;
		20 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b10100;
		21 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b10101;
		22 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b10110;
		23 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b10111;
		24 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b11000;
		25 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b11001;
		26 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b11010;
		27 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b11011;
		28 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b11100;
		29 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b11101;
		30 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b11110;
		31 : CLK_COR_REPEAT_WAIT_1_BINARY = 5'b11111;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_REPEAT_WAIT_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 0 to 31.", CLK_COR_REPEAT_WAIT_1);
			$finish;
		end
	endcase

	case (CLK_COR_SEQ_2_USE_1)
		"FALSE" : CLK_COR_SEQ_2_USE_1_BINARY = 1'b0;
		"TRUE" : CLK_COR_SEQ_2_USE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK_COR_SEQ_2_USE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLK_COR_SEQ_2_USE_1);
			$finish;
		end
	endcase

	case (CHAN_BOND_MODE_0)
		"OFF" : CHAN_BOND_MODE_0_BINARY = 2'b00;
		"MASTER" : CHAN_BOND_MODE_0_BINARY = 2'b01;
		"SLAVE" : CHAN_BOND_MODE_0_BINARY = 2'b10;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_MODE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are OFF, MASTER or SLAVE.", CHAN_BOND_MODE_0);
			$finish;
		end
	endcase

	case (CHAN_BOND_LEVEL_0)
		0 : CHAN_BOND_LEVEL_0_BINARY = 3'b000;
		1 : CHAN_BOND_LEVEL_0_BINARY = 3'b001;
		2 : CHAN_BOND_LEVEL_0_BINARY = 3'b010;
		3 : CHAN_BOND_LEVEL_0_BINARY = 3'b011;
		4 : CHAN_BOND_LEVEL_0_BINARY = 3'b100;
		5 : CHAN_BOND_LEVEL_0_BINARY = 3'b101;
		6 : CHAN_BOND_LEVEL_0_BINARY = 3'b110;
		7 : CHAN_BOND_LEVEL_0_BINARY = 3'b111;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_LEVEL_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 0 to 7.", CHAN_BOND_LEVEL_0);
			$finish;
		end
	endcase

	case (CHAN_BOND_SEQ_LEN_0)
		1 : CHAN_BOND_SEQ_LEN_0_BINARY = 2'b00;
		2 : CHAN_BOND_SEQ_LEN_0_BINARY = 2'b01;
		3 : CHAN_BOND_SEQ_LEN_0_BINARY = 2'b10;
		4 : CHAN_BOND_SEQ_LEN_0_BINARY = 2'b11;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_LEN_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3 or 4.", CHAN_BOND_SEQ_LEN_0);
			$finish;
		end
	endcase

	case (CHAN_BOND_SEQ_2_USE_0)
		"FALSE" : CHAN_BOND_SEQ_2_USE_0_BINARY = 1'b0;
		"TRUE" : CHAN_BOND_SEQ_2_USE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_2_USE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CHAN_BOND_SEQ_2_USE_0);
			$finish;
		end
	endcase

	case (CHAN_BOND_1_MAX_SKEW_0)
		1 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b0001;
		2 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b0010;
		3 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b0011;
		4 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b0100;
		5 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b0101;
		6 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b0110;
		7 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b0111;
		8 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b1000;
		9 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b1001;
		10 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b1010;
		11 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b1011;
		12 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b1100;
		13 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b1101;
		14 : CHAN_BOND_1_MAX_SKEW_0_BINARY = 4'b1110;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_1_MAX_SKEW_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 14.", CHAN_BOND_1_MAX_SKEW_0);
			$finish;
		end
	endcase

	case (CHAN_BOND_2_MAX_SKEW_0)
		1 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b0001;
		2 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b0010;
		3 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b0011;
		4 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b0100;
		5 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b0101;
		6 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b0110;
		7 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b0111;
		8 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b1000;
		9 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b1001;
		10 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b1010;
		11 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b1011;
		12 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b1100;
		13 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b1101;
		14 : CHAN_BOND_2_MAX_SKEW_0_BINARY = 4'b1110;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_2_MAX_SKEW_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 14.", CHAN_BOND_2_MAX_SKEW_0);
			$finish;
		end
	endcase

	case (CHAN_BOND_KEEP_ALIGN_0)
		"FALSE" : CHAN_BOND_KEEP_ALIGN_0_BINARY = 1'b0;
		"TRUE" : CHAN_BOND_KEEP_ALIGN_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_KEEP_ALIGN_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CHAN_BOND_KEEP_ALIGN_0);
			$finish;
		end
	endcase

	case (CB2_INH_CC_PERIOD_0)
		0 : CB2_INH_CC_PERIOD_0_BINARY = 4'b0000;
		1 : CB2_INH_CC_PERIOD_0_BINARY = 4'b0001;
		2 : CB2_INH_CC_PERIOD_0_BINARY = 4'b0010;
		3 : CB2_INH_CC_PERIOD_0_BINARY = 4'b0011;
		4 : CB2_INH_CC_PERIOD_0_BINARY = 4'b0100;
		5 : CB2_INH_CC_PERIOD_0_BINARY = 4'b0101;
		6 : CB2_INH_CC_PERIOD_0_BINARY = 4'b0110;
		7 : CB2_INH_CC_PERIOD_0_BINARY = 4'b0111;
		8 : CB2_INH_CC_PERIOD_0_BINARY = 4'b1000;
		9 : CB2_INH_CC_PERIOD_0_BINARY = 4'b1001;
		10 : CB2_INH_CC_PERIOD_0_BINARY = 4'b1010;
		11 : CB2_INH_CC_PERIOD_0_BINARY = 4'b1011;
		12 : CB2_INH_CC_PERIOD_0_BINARY = 4'b1100;
		13 : CB2_INH_CC_PERIOD_0_BINARY = 4'b1101;
		14 : CB2_INH_CC_PERIOD_0_BINARY = 4'b1110;
		15 : CB2_INH_CC_PERIOD_0_BINARY = 4'b1111;
		default : begin
			$display("Attribute Syntax Error : The Attribute CB2_INH_CC_PERIOD_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 0 to 15.", CB2_INH_CC_PERIOD_0);
			$finish;
		end
	endcase

	case (CHAN_BOND_MODE_1)
		"OFF" : CHAN_BOND_MODE_1_BINARY = 2'b00;
		"MASTER" : CHAN_BOND_MODE_1_BINARY = 2'b01;
		"SLAVE" : CHAN_BOND_MODE_1_BINARY = 2'b10;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_MODE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are OFF, MASTER or SLAVE.", CHAN_BOND_MODE_1);
			$finish;
		end
	endcase

	case (CHAN_BOND_LEVEL_1)
		0 : CHAN_BOND_LEVEL_1_BINARY = 3'b000;
		1 : CHAN_BOND_LEVEL_1_BINARY = 3'b001;
		2 : CHAN_BOND_LEVEL_1_BINARY = 3'b010;
		3 : CHAN_BOND_LEVEL_1_BINARY = 3'b011;
		4 : CHAN_BOND_LEVEL_1_BINARY = 3'b100;
		5 : CHAN_BOND_LEVEL_1_BINARY = 3'b101;
		6 : CHAN_BOND_LEVEL_1_BINARY = 3'b110;
		7 : CHAN_BOND_LEVEL_1_BINARY = 3'b111;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_LEVEL_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 0 to 7.", CHAN_BOND_LEVEL_1);
			$finish;
		end
	endcase

	case (CHAN_BOND_SEQ_LEN_1)
		1 : CHAN_BOND_SEQ_LEN_1_BINARY = 2'b00;
		2 : CHAN_BOND_SEQ_LEN_1_BINARY = 2'b01;
		3 : CHAN_BOND_SEQ_LEN_1_BINARY = 2'b10;
		4 : CHAN_BOND_SEQ_LEN_1_BINARY = 2'b11;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_LEN_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3 or 4.", CHAN_BOND_SEQ_LEN_1);
			$finish;
		end
	endcase

	case (CHAN_BOND_SEQ_2_USE_1)
		"FALSE" : CHAN_BOND_SEQ_2_USE_1_BINARY = 1'b0;
		"TRUE" : CHAN_BOND_SEQ_2_USE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_SEQ_2_USE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CHAN_BOND_SEQ_2_USE_1);
			$finish;
		end
	endcase

	case (CHAN_BOND_1_MAX_SKEW_1)
		1 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b0001;
		2 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b0010;
		3 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b0011;
		4 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b0100;
		5 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b0101;
		6 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b0110;
		7 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b0111;
		8 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b1000;
		9 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b1001;
		10 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b1010;
		11 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b1011;
		12 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b1100;
		13 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b1101;
		14 : CHAN_BOND_1_MAX_SKEW_1_BINARY = 4'b1110;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_1_MAX_SKEW_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 14.", CHAN_BOND_1_MAX_SKEW_1);
			$finish;
		end
	endcase

	case (CHAN_BOND_2_MAX_SKEW_1)
		1 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b0001;
		2 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b0010;
		3 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b0011;
		4 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b0100;
		5 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b0101;
		6 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b0110;
		7 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b0111;
		8 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b1000;
		9 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b1001;
		10 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b1010;
		11 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b1011;
		12 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b1100;
		13 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b1101;
		14 : CHAN_BOND_2_MAX_SKEW_1_BINARY = 4'b1110;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_2_MAX_SKEW_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 14.", CHAN_BOND_2_MAX_SKEW_1);
			$finish;
		end
	endcase

	case (CHAN_BOND_KEEP_ALIGN_1)
		"FALSE" : CHAN_BOND_KEEP_ALIGN_1_BINARY = 1'b0;
		"TRUE" : CHAN_BOND_KEEP_ALIGN_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CHAN_BOND_KEEP_ALIGN_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CHAN_BOND_KEEP_ALIGN_1);
			$finish;
		end
	endcase

	case (CB2_INH_CC_PERIOD_1)
		0 : CB2_INH_CC_PERIOD_1_BINARY = 4'b0000;
		1 : CB2_INH_CC_PERIOD_1_BINARY = 4'b0001;
		2 : CB2_INH_CC_PERIOD_1_BINARY = 4'b0010;
		3 : CB2_INH_CC_PERIOD_1_BINARY = 4'b0011;
		4 : CB2_INH_CC_PERIOD_1_BINARY = 4'b0100;
		5 : CB2_INH_CC_PERIOD_1_BINARY = 4'b0101;
		6 : CB2_INH_CC_PERIOD_1_BINARY = 4'b0110;
		7 : CB2_INH_CC_PERIOD_1_BINARY = 4'b0111;
		8 : CB2_INH_CC_PERIOD_1_BINARY = 4'b1000;
		9 : CB2_INH_CC_PERIOD_1_BINARY = 4'b1001;
		10 : CB2_INH_CC_PERIOD_1_BINARY = 4'b1010;
		11 : CB2_INH_CC_PERIOD_1_BINARY = 4'b1011;
		12 : CB2_INH_CC_PERIOD_1_BINARY = 4'b1100;
		13 : CB2_INH_CC_PERIOD_1_BINARY = 4'b1101;
		14 : CB2_INH_CC_PERIOD_1_BINARY = 4'b1110;
		15 : CB2_INH_CC_PERIOD_1_BINARY = 4'b1111;
		default : begin
			$display("Attribute Syntax Error : The Attribute CB2_INH_CC_PERIOD_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 0 to 15.", CB2_INH_CC_PERIOD_1);
			$finish;
		end
	endcase

	case (PCI_EXPRESS_MODE_0)
		"FALSE" : PCI_EXPRESS_MODE_0_BINARY = 1'b0;
		"TRUE" : PCI_EXPRESS_MODE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute PCI_EXPRESS_MODE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PCI_EXPRESS_MODE_0);
			$finish;
		end
	endcase

	case (PCI_EXPRESS_MODE_1)
		"FALSE" : PCI_EXPRESS_MODE_1_BINARY = 1'b0;
		"TRUE" : PCI_EXPRESS_MODE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute PCI_EXPRESS_MODE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PCI_EXPRESS_MODE_1);
			$finish;
		end
	endcase

	case (RX_STATUS_FMT_0)
		"PCIE" : RX_STATUS_FMT_0_BINARY = 1'b0;
		"SATA" : RX_STATUS_FMT_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_STATUS_FMT_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are PCIE or SATA.", RX_STATUS_FMT_0);
			$finish;
		end
	endcase

	case (TX_BUFFER_USE_0)
		"FALSE" : TX_BUFFER_USE_0_BINARY = 1'b0;
		"TRUE" : TX_BUFFER_USE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute TX_BUFFER_USE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TX_BUFFER_USE_0);
			$finish;
		end
	endcase

	case (TX_XCLK_SEL_0)
		"TXUSR" : TX_XCLK_SEL_0_BINARY = 1'b1;
		"TXOUT" : TX_XCLK_SEL_0_BINARY = 1'b0;
		default : begin
			$display("Attribute Syntax Error : The Attribute TX_XCLK_SEL_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TXUSR or TXOUT.", TX_XCLK_SEL_0);
			$finish;
		end
	endcase

	case (RX_XCLK_SEL_0)
		"RXREC" : RX_XCLK_SEL_0_BINARY = 1'b0;
		"RXUSR" : RX_XCLK_SEL_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_XCLK_SEL_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are RXREC or RXUSR.", RX_XCLK_SEL_0);
			$finish;
		end
	endcase

	case (RX_STATUS_FMT_1)
		"PCIE" : RX_STATUS_FMT_1_BINARY = 1'b0;
		"SATA" : RX_STATUS_FMT_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_STATUS_FMT_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are PCIE or SATA.", RX_STATUS_FMT_1);
			$finish;
		end
	endcase

	case (TX_BUFFER_USE_1)
		"FALSE" : TX_BUFFER_USE_1_BINARY = 1'b0;
		"TRUE" : TX_BUFFER_USE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute TX_BUFFER_USE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TX_BUFFER_USE_1);
			$finish;
		end
	endcase

	case (TX_XCLK_SEL_1)
		"TXUSR" : TX_XCLK_SEL_1_BINARY = 1'b1;
		"TXOUT" : TX_XCLK_SEL_1_BINARY = 1'b0;
		default : begin
			$display("Attribute Syntax Error : The Attribute TX_XCLK_SEL_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TXUSR or TXOUT.", TX_XCLK_SEL_1);
			$finish;
		end
	endcase

	case (RX_XCLK_SEL_1)
		"RXREC" : RX_XCLK_SEL_1_BINARY = 1'b0;
		"RXUSR" : RX_XCLK_SEL_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_XCLK_SEL_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are RXREC or RXUSR.", RX_XCLK_SEL_1);
			$finish;
		end
	endcase

	case (RX_SLIDE_MODE_0)
		"PCS" : RX_SLIDE_MODE_0_BINARY = 1'b0;
		"PMA" : RX_SLIDE_MODE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_SLIDE_MODE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are PCS or PMA.", RX_SLIDE_MODE_0);
			$finish;
		end
	endcase

	case (RX_SLIDE_MODE_1)
		"PCS" : RX_SLIDE_MODE_1_BINARY = 1'b0;
		"PMA" : RX_SLIDE_MODE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_SLIDE_MODE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are PCS or PMA.", RX_SLIDE_MODE_1);
			$finish;
		end
	endcase

	case (SATA_MIN_BURST_0)
		1 : SATA_MIN_BURST_0_BINARY = 6'b000001;
		2 : SATA_MIN_BURST_0_BINARY = 6'b000010;
		3 : SATA_MIN_BURST_0_BINARY = 6'b000011;
		4 : SATA_MIN_BURST_0_BINARY = 6'b000100;
		5 : SATA_MIN_BURST_0_BINARY = 6'b000101;
		6 : SATA_MIN_BURST_0_BINARY = 6'b000110;
		7 : SATA_MIN_BURST_0_BINARY = 6'b000111;
		8 : SATA_MIN_BURST_0_BINARY = 6'b001000;
		9 : SATA_MIN_BURST_0_BINARY = 6'b001001;
		10 : SATA_MIN_BURST_0_BINARY = 6'b001010;
		11 : SATA_MIN_BURST_0_BINARY = 6'b001011;
		12 : SATA_MIN_BURST_0_BINARY = 6'b001100;
		13 : SATA_MIN_BURST_0_BINARY = 6'b001101;
		14 : SATA_MIN_BURST_0_BINARY = 6'b001110;
		15 : SATA_MIN_BURST_0_BINARY = 6'b001111;
		16 : SATA_MIN_BURST_0_BINARY = 6'b010000;
		17 : SATA_MIN_BURST_0_BINARY = 6'b010001;
		18 : SATA_MIN_BURST_0_BINARY = 6'b010010;
		19 : SATA_MIN_BURST_0_BINARY = 6'b010011;
		20 : SATA_MIN_BURST_0_BINARY = 6'b010100;
		21 : SATA_MIN_BURST_0_BINARY = 6'b010101;
		22 : SATA_MIN_BURST_0_BINARY = 6'b010110;
		23 : SATA_MIN_BURST_0_BINARY = 6'b010111;
		24 : SATA_MIN_BURST_0_BINARY = 6'b011000;
		25 : SATA_MIN_BURST_0_BINARY = 6'b011001;
		26 : SATA_MIN_BURST_0_BINARY = 6'b011010;
		27 : SATA_MIN_BURST_0_BINARY = 6'b011011;
		28 : SATA_MIN_BURST_0_BINARY = 6'b011100;
		29 : SATA_MIN_BURST_0_BINARY = 6'b011101;
		30 : SATA_MIN_BURST_0_BINARY = 6'b011110;
		31 : SATA_MIN_BURST_0_BINARY = 6'b011111;
		32 : SATA_MIN_BURST_0_BINARY = 6'b100000;
		33 : SATA_MIN_BURST_0_BINARY = 6'b100001;
		34 : SATA_MIN_BURST_0_BINARY = 6'b100010;
		35 : SATA_MIN_BURST_0_BINARY = 6'b100011;
		36 : SATA_MIN_BURST_0_BINARY = 6'b100100;
		37 : SATA_MIN_BURST_0_BINARY = 6'b100101;
		38 : SATA_MIN_BURST_0_BINARY = 6'b100110;
		39 : SATA_MIN_BURST_0_BINARY = 6'b100111;
		40 : SATA_MIN_BURST_0_BINARY = 6'b101000;
		41 : SATA_MIN_BURST_0_BINARY = 6'b101001;
		42 : SATA_MIN_BURST_0_BINARY = 6'b101010;
		43 : SATA_MIN_BURST_0_BINARY = 6'b101011;
		44 : SATA_MIN_BURST_0_BINARY = 6'b101100;
		45 : SATA_MIN_BURST_0_BINARY = 6'b101101;
		46 : SATA_MIN_BURST_0_BINARY = 6'b101110;
		47 : SATA_MIN_BURST_0_BINARY = 6'b101111;
		48 : SATA_MIN_BURST_0_BINARY = 6'b110000;
		49 : SATA_MIN_BURST_0_BINARY = 6'b110001;
		50 : SATA_MIN_BURST_0_BINARY = 6'b110010;
		51 : SATA_MIN_BURST_0_BINARY = 6'b110011;
		52 : SATA_MIN_BURST_0_BINARY = 6'b110100;
		53 : SATA_MIN_BURST_0_BINARY = 6'b110101;
		54 : SATA_MIN_BURST_0_BINARY = 6'b110110;
		55 : SATA_MIN_BURST_0_BINARY = 6'b110111;
		56 : SATA_MIN_BURST_0_BINARY = 6'b111000;
		57 : SATA_MIN_BURST_0_BINARY = 6'b111001;
		58 : SATA_MIN_BURST_0_BINARY = 6'b111010;
		59 : SATA_MIN_BURST_0_BINARY = 6'b111011;
		60 : SATA_MIN_BURST_0_BINARY = 6'b111100;
		61 : SATA_MIN_BURST_0_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MIN_BURST_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MIN_BURST_0);
			$finish;
		end
	endcase

	case (SATA_MAX_BURST_0)
		1 : SATA_MAX_BURST_0_BINARY = 6'b000001;
		2 : SATA_MAX_BURST_0_BINARY = 6'b000010;
		3 : SATA_MAX_BURST_0_BINARY = 6'b000011;
		4 : SATA_MAX_BURST_0_BINARY = 6'b000100;
		5 : SATA_MAX_BURST_0_BINARY = 6'b000101;
		6 : SATA_MAX_BURST_0_BINARY = 6'b000110;
		7 : SATA_MAX_BURST_0_BINARY = 6'b000111;
		8 : SATA_MAX_BURST_0_BINARY = 6'b001000;
		9 : SATA_MAX_BURST_0_BINARY = 6'b001001;
		10 : SATA_MAX_BURST_0_BINARY = 6'b001010;
		11 : SATA_MAX_BURST_0_BINARY = 6'b001011;
		12 : SATA_MAX_BURST_0_BINARY = 6'b001100;
		13 : SATA_MAX_BURST_0_BINARY = 6'b001101;
		14 : SATA_MAX_BURST_0_BINARY = 6'b001110;
		15 : SATA_MAX_BURST_0_BINARY = 6'b001111;
		16 : SATA_MAX_BURST_0_BINARY = 6'b010000;
		17 : SATA_MAX_BURST_0_BINARY = 6'b010001;
		18 : SATA_MAX_BURST_0_BINARY = 6'b010010;
		19 : SATA_MAX_BURST_0_BINARY = 6'b010011;
		20 : SATA_MAX_BURST_0_BINARY = 6'b010100;
		21 : SATA_MAX_BURST_0_BINARY = 6'b010101;
		22 : SATA_MAX_BURST_0_BINARY = 6'b010110;
		23 : SATA_MAX_BURST_0_BINARY = 6'b010111;
		24 : SATA_MAX_BURST_0_BINARY = 6'b011000;
		25 : SATA_MAX_BURST_0_BINARY = 6'b011001;
		26 : SATA_MAX_BURST_0_BINARY = 6'b011010;
		27 : SATA_MAX_BURST_0_BINARY = 6'b011011;
		28 : SATA_MAX_BURST_0_BINARY = 6'b011100;
		29 : SATA_MAX_BURST_0_BINARY = 6'b011101;
		30 : SATA_MAX_BURST_0_BINARY = 6'b011110;
		31 : SATA_MAX_BURST_0_BINARY = 6'b011111;
		32 : SATA_MAX_BURST_0_BINARY = 6'b100000;
		33 : SATA_MAX_BURST_0_BINARY = 6'b100001;
		34 : SATA_MAX_BURST_0_BINARY = 6'b100010;
		35 : SATA_MAX_BURST_0_BINARY = 6'b100011;
		36 : SATA_MAX_BURST_0_BINARY = 6'b100100;
		37 : SATA_MAX_BURST_0_BINARY = 6'b100101;
		38 : SATA_MAX_BURST_0_BINARY = 6'b100110;
		39 : SATA_MAX_BURST_0_BINARY = 6'b100111;
		40 : SATA_MAX_BURST_0_BINARY = 6'b101000;
		41 : SATA_MAX_BURST_0_BINARY = 6'b101001;
		42 : SATA_MAX_BURST_0_BINARY = 6'b101010;
		43 : SATA_MAX_BURST_0_BINARY = 6'b101011;
		44 : SATA_MAX_BURST_0_BINARY = 6'b101100;
		45 : SATA_MAX_BURST_0_BINARY = 6'b101101;
		46 : SATA_MAX_BURST_0_BINARY = 6'b101110;
		47 : SATA_MAX_BURST_0_BINARY = 6'b101111;
		48 : SATA_MAX_BURST_0_BINARY = 6'b110000;
		49 : SATA_MAX_BURST_0_BINARY = 6'b110001;
		50 : SATA_MAX_BURST_0_BINARY = 6'b110010;
		51 : SATA_MAX_BURST_0_BINARY = 6'b110011;
		52 : SATA_MAX_BURST_0_BINARY = 6'b110100;
		53 : SATA_MAX_BURST_0_BINARY = 6'b110101;
		54 : SATA_MAX_BURST_0_BINARY = 6'b110110;
		55 : SATA_MAX_BURST_0_BINARY = 6'b110111;
		56 : SATA_MAX_BURST_0_BINARY = 6'b111000;
		57 : SATA_MAX_BURST_0_BINARY = 6'b111001;
		58 : SATA_MAX_BURST_0_BINARY = 6'b111010;
		59 : SATA_MAX_BURST_0_BINARY = 6'b111011;
		60 : SATA_MAX_BURST_0_BINARY = 6'b111100;
		61 : SATA_MAX_BURST_0_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MAX_BURST_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MAX_BURST_0);
			$finish;
		end
	endcase

	case (SATA_MIN_INIT_0)
		1 : SATA_MIN_INIT_0_BINARY = 6'b000001;
		2 : SATA_MIN_INIT_0_BINARY = 6'b000010;
		3 : SATA_MIN_INIT_0_BINARY = 6'b000011;
		4 : SATA_MIN_INIT_0_BINARY = 6'b000100;
		5 : SATA_MIN_INIT_0_BINARY = 6'b000101;
		6 : SATA_MIN_INIT_0_BINARY = 6'b000110;
		7 : SATA_MIN_INIT_0_BINARY = 6'b000111;
		8 : SATA_MIN_INIT_0_BINARY = 6'b001000;
		9 : SATA_MIN_INIT_0_BINARY = 6'b001001;
		10 : SATA_MIN_INIT_0_BINARY = 6'b001010;
		11 : SATA_MIN_INIT_0_BINARY = 6'b001011;
		12 : SATA_MIN_INIT_0_BINARY = 6'b001100;
		13 : SATA_MIN_INIT_0_BINARY = 6'b001101;
		14 : SATA_MIN_INIT_0_BINARY = 6'b001110;
		15 : SATA_MIN_INIT_0_BINARY = 6'b001111;
		16 : SATA_MIN_INIT_0_BINARY = 6'b010000;
		17 : SATA_MIN_INIT_0_BINARY = 6'b010001;
		18 : SATA_MIN_INIT_0_BINARY = 6'b010010;
		19 : SATA_MIN_INIT_0_BINARY = 6'b010011;
		20 : SATA_MIN_INIT_0_BINARY = 6'b010100;
		21 : SATA_MIN_INIT_0_BINARY = 6'b010101;
		22 : SATA_MIN_INIT_0_BINARY = 6'b010110;
		23 : SATA_MIN_INIT_0_BINARY = 6'b010111;
		24 : SATA_MIN_INIT_0_BINARY = 6'b011000;
		25 : SATA_MIN_INIT_0_BINARY = 6'b011001;
		26 : SATA_MIN_INIT_0_BINARY = 6'b011010;
		27 : SATA_MIN_INIT_0_BINARY = 6'b011011;
		28 : SATA_MIN_INIT_0_BINARY = 6'b011100;
		29 : SATA_MIN_INIT_0_BINARY = 6'b011101;
		30 : SATA_MIN_INIT_0_BINARY = 6'b011110;
		31 : SATA_MIN_INIT_0_BINARY = 6'b011111;
		32 : SATA_MIN_INIT_0_BINARY = 6'b100000;
		33 : SATA_MIN_INIT_0_BINARY = 6'b100001;
		34 : SATA_MIN_INIT_0_BINARY = 6'b100010;
		35 : SATA_MIN_INIT_0_BINARY = 6'b100011;
		36 : SATA_MIN_INIT_0_BINARY = 6'b100100;
		37 : SATA_MIN_INIT_0_BINARY = 6'b100101;
		38 : SATA_MIN_INIT_0_BINARY = 6'b100110;
		39 : SATA_MIN_INIT_0_BINARY = 6'b100111;
		40 : SATA_MIN_INIT_0_BINARY = 6'b101000;
		41 : SATA_MIN_INIT_0_BINARY = 6'b101001;
		42 : SATA_MIN_INIT_0_BINARY = 6'b101010;
		43 : SATA_MIN_INIT_0_BINARY = 6'b101011;
		44 : SATA_MIN_INIT_0_BINARY = 6'b101100;
		45 : SATA_MIN_INIT_0_BINARY = 6'b101101;
		46 : SATA_MIN_INIT_0_BINARY = 6'b101110;
		47 : SATA_MIN_INIT_0_BINARY = 6'b101111;
		48 : SATA_MIN_INIT_0_BINARY = 6'b110000;
		49 : SATA_MIN_INIT_0_BINARY = 6'b110001;
		50 : SATA_MIN_INIT_0_BINARY = 6'b110010;
		51 : SATA_MIN_INIT_0_BINARY = 6'b110011;
		52 : SATA_MIN_INIT_0_BINARY = 6'b110100;
		53 : SATA_MIN_INIT_0_BINARY = 6'b110101;
		54 : SATA_MIN_INIT_0_BINARY = 6'b110110;
		55 : SATA_MIN_INIT_0_BINARY = 6'b110111;
		56 : SATA_MIN_INIT_0_BINARY = 6'b111000;
		57 : SATA_MIN_INIT_0_BINARY = 6'b111001;
		58 : SATA_MIN_INIT_0_BINARY = 6'b111010;
		59 : SATA_MIN_INIT_0_BINARY = 6'b111011;
		60 : SATA_MIN_INIT_0_BINARY = 6'b111100;
		61 : SATA_MIN_INIT_0_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MIN_INIT_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MIN_INIT_0);
			$finish;
		end
	endcase

	case (SATA_MAX_INIT_0)
		1 : SATA_MAX_INIT_0_BINARY = 6'b000001;
		2 : SATA_MAX_INIT_0_BINARY = 6'b000010;
		3 : SATA_MAX_INIT_0_BINARY = 6'b000011;
		4 : SATA_MAX_INIT_0_BINARY = 6'b000100;
		5 : SATA_MAX_INIT_0_BINARY = 6'b000101;
		6 : SATA_MAX_INIT_0_BINARY = 6'b000110;
		7 : SATA_MAX_INIT_0_BINARY = 6'b000111;
		8 : SATA_MAX_INIT_0_BINARY = 6'b001000;
		9 : SATA_MAX_INIT_0_BINARY = 6'b001001;
		10 : SATA_MAX_INIT_0_BINARY = 6'b001010;
		11 : SATA_MAX_INIT_0_BINARY = 6'b001011;
		12 : SATA_MAX_INIT_0_BINARY = 6'b001100;
		13 : SATA_MAX_INIT_0_BINARY = 6'b001101;
		14 : SATA_MAX_INIT_0_BINARY = 6'b001110;
		15 : SATA_MAX_INIT_0_BINARY = 6'b001111;
		16 : SATA_MAX_INIT_0_BINARY = 6'b010000;
		17 : SATA_MAX_INIT_0_BINARY = 6'b010001;
		18 : SATA_MAX_INIT_0_BINARY = 6'b010010;
		19 : SATA_MAX_INIT_0_BINARY = 6'b010011;
		20 : SATA_MAX_INIT_0_BINARY = 6'b010100;
		21 : SATA_MAX_INIT_0_BINARY = 6'b010101;
		22 : SATA_MAX_INIT_0_BINARY = 6'b010110;
		23 : SATA_MAX_INIT_0_BINARY = 6'b010111;
		24 : SATA_MAX_INIT_0_BINARY = 6'b011000;
		25 : SATA_MAX_INIT_0_BINARY = 6'b011001;
		26 : SATA_MAX_INIT_0_BINARY = 6'b011010;
		27 : SATA_MAX_INIT_0_BINARY = 6'b011011;
		28 : SATA_MAX_INIT_0_BINARY = 6'b011100;
		29 : SATA_MAX_INIT_0_BINARY = 6'b011101;
		30 : SATA_MAX_INIT_0_BINARY = 6'b011110;
		31 : SATA_MAX_INIT_0_BINARY = 6'b011111;
		32 : SATA_MAX_INIT_0_BINARY = 6'b100000;
		33 : SATA_MAX_INIT_0_BINARY = 6'b100001;
		34 : SATA_MAX_INIT_0_BINARY = 6'b100010;
		35 : SATA_MAX_INIT_0_BINARY = 6'b100011;
		36 : SATA_MAX_INIT_0_BINARY = 6'b100100;
		37 : SATA_MAX_INIT_0_BINARY = 6'b100101;
		38 : SATA_MAX_INIT_0_BINARY = 6'b100110;
		39 : SATA_MAX_INIT_0_BINARY = 6'b100111;
		40 : SATA_MAX_INIT_0_BINARY = 6'b101000;
		41 : SATA_MAX_INIT_0_BINARY = 6'b101001;
		42 : SATA_MAX_INIT_0_BINARY = 6'b101010;
		43 : SATA_MAX_INIT_0_BINARY = 6'b101011;
		44 : SATA_MAX_INIT_0_BINARY = 6'b101100;
		45 : SATA_MAX_INIT_0_BINARY = 6'b101101;
		46 : SATA_MAX_INIT_0_BINARY = 6'b101110;
		47 : SATA_MAX_INIT_0_BINARY = 6'b101111;
		48 : SATA_MAX_INIT_0_BINARY = 6'b110000;
		49 : SATA_MAX_INIT_0_BINARY = 6'b110001;
		50 : SATA_MAX_INIT_0_BINARY = 6'b110010;
		51 : SATA_MAX_INIT_0_BINARY = 6'b110011;
		52 : SATA_MAX_INIT_0_BINARY = 6'b110100;
		53 : SATA_MAX_INIT_0_BINARY = 6'b110101;
		54 : SATA_MAX_INIT_0_BINARY = 6'b110110;
		55 : SATA_MAX_INIT_0_BINARY = 6'b110111;
		56 : SATA_MAX_INIT_0_BINARY = 6'b111000;
		57 : SATA_MAX_INIT_0_BINARY = 6'b111001;
		58 : SATA_MAX_INIT_0_BINARY = 6'b111010;
		59 : SATA_MAX_INIT_0_BINARY = 6'b111011;
		60 : SATA_MAX_INIT_0_BINARY = 6'b111100;
		61 : SATA_MAX_INIT_0_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MAX_INIT_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MAX_INIT_0);
			$finish;
		end
	endcase

	case (SATA_MIN_WAKE_0)
		1 : SATA_MIN_WAKE_0_BINARY = 6'b000001;
		2 : SATA_MIN_WAKE_0_BINARY = 6'b000010;
		3 : SATA_MIN_WAKE_0_BINARY = 6'b000011;
		4 : SATA_MIN_WAKE_0_BINARY = 6'b000100;
		5 : SATA_MIN_WAKE_0_BINARY = 6'b000101;
		6 : SATA_MIN_WAKE_0_BINARY = 6'b000110;
		7 : SATA_MIN_WAKE_0_BINARY = 6'b000111;
		8 : SATA_MIN_WAKE_0_BINARY = 6'b001000;
		9 : SATA_MIN_WAKE_0_BINARY = 6'b001001;
		10 : SATA_MIN_WAKE_0_BINARY = 6'b001010;
		11 : SATA_MIN_WAKE_0_BINARY = 6'b001011;
		12 : SATA_MIN_WAKE_0_BINARY = 6'b001100;
		13 : SATA_MIN_WAKE_0_BINARY = 6'b001101;
		14 : SATA_MIN_WAKE_0_BINARY = 6'b001110;
		15 : SATA_MIN_WAKE_0_BINARY = 6'b001111;
		16 : SATA_MIN_WAKE_0_BINARY = 6'b010000;
		17 : SATA_MIN_WAKE_0_BINARY = 6'b010001;
		18 : SATA_MIN_WAKE_0_BINARY = 6'b010010;
		19 : SATA_MIN_WAKE_0_BINARY = 6'b010011;
		20 : SATA_MIN_WAKE_0_BINARY = 6'b010100;
		21 : SATA_MIN_WAKE_0_BINARY = 6'b010101;
		22 : SATA_MIN_WAKE_0_BINARY = 6'b010110;
		23 : SATA_MIN_WAKE_0_BINARY = 6'b010111;
		24 : SATA_MIN_WAKE_0_BINARY = 6'b011000;
		25 : SATA_MIN_WAKE_0_BINARY = 6'b011001;
		26 : SATA_MIN_WAKE_0_BINARY = 6'b011010;
		27 : SATA_MIN_WAKE_0_BINARY = 6'b011011;
		28 : SATA_MIN_WAKE_0_BINARY = 6'b011100;
		29 : SATA_MIN_WAKE_0_BINARY = 6'b011101;
		30 : SATA_MIN_WAKE_0_BINARY = 6'b011110;
		31 : SATA_MIN_WAKE_0_BINARY = 6'b011111;
		32 : SATA_MIN_WAKE_0_BINARY = 6'b100000;
		33 : SATA_MIN_WAKE_0_BINARY = 6'b100001;
		34 : SATA_MIN_WAKE_0_BINARY = 6'b100010;
		35 : SATA_MIN_WAKE_0_BINARY = 6'b100011;
		36 : SATA_MIN_WAKE_0_BINARY = 6'b100100;
		37 : SATA_MIN_WAKE_0_BINARY = 6'b100101;
		38 : SATA_MIN_WAKE_0_BINARY = 6'b100110;
		39 : SATA_MIN_WAKE_0_BINARY = 6'b100111;
		40 : SATA_MIN_WAKE_0_BINARY = 6'b101000;
		41 : SATA_MIN_WAKE_0_BINARY = 6'b101001;
		42 : SATA_MIN_WAKE_0_BINARY = 6'b101010;
		43 : SATA_MIN_WAKE_0_BINARY = 6'b101011;
		44 : SATA_MIN_WAKE_0_BINARY = 6'b101100;
		45 : SATA_MIN_WAKE_0_BINARY = 6'b101101;
		46 : SATA_MIN_WAKE_0_BINARY = 6'b101110;
		47 : SATA_MIN_WAKE_0_BINARY = 6'b101111;
		48 : SATA_MIN_WAKE_0_BINARY = 6'b110000;
		49 : SATA_MIN_WAKE_0_BINARY = 6'b110001;
		50 : SATA_MIN_WAKE_0_BINARY = 6'b110010;
		51 : SATA_MIN_WAKE_0_BINARY = 6'b110011;
		52 : SATA_MIN_WAKE_0_BINARY = 6'b110100;
		53 : SATA_MIN_WAKE_0_BINARY = 6'b110101;
		54 : SATA_MIN_WAKE_0_BINARY = 6'b110110;
		55 : SATA_MIN_WAKE_0_BINARY = 6'b110111;
		56 : SATA_MIN_WAKE_0_BINARY = 6'b111000;
		57 : SATA_MIN_WAKE_0_BINARY = 6'b111001;
		58 : SATA_MIN_WAKE_0_BINARY = 6'b111010;
		59 : SATA_MIN_WAKE_0_BINARY = 6'b111011;
		60 : SATA_MIN_WAKE_0_BINARY = 6'b111100;
		61 : SATA_MIN_WAKE_0_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MIN_WAKE_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MIN_WAKE_0);
			$finish;
		end
	endcase

	case (SATA_MAX_WAKE_0)
		1 : SATA_MAX_WAKE_0_BINARY = 6'b000001;
		2 : SATA_MAX_WAKE_0_BINARY = 6'b000010;
		3 : SATA_MAX_WAKE_0_BINARY = 6'b000011;
		4 : SATA_MAX_WAKE_0_BINARY = 6'b000100;
		5 : SATA_MAX_WAKE_0_BINARY = 6'b000101;
		6 : SATA_MAX_WAKE_0_BINARY = 6'b000110;
		7 : SATA_MAX_WAKE_0_BINARY = 6'b000111;
		8 : SATA_MAX_WAKE_0_BINARY = 6'b001000;
		9 : SATA_MAX_WAKE_0_BINARY = 6'b001001;
		10 : SATA_MAX_WAKE_0_BINARY = 6'b001010;
		11 : SATA_MAX_WAKE_0_BINARY = 6'b001011;
		12 : SATA_MAX_WAKE_0_BINARY = 6'b001100;
		13 : SATA_MAX_WAKE_0_BINARY = 6'b001101;
		14 : SATA_MAX_WAKE_0_BINARY = 6'b001110;
		15 : SATA_MAX_WAKE_0_BINARY = 6'b001111;
		16 : SATA_MAX_WAKE_0_BINARY = 6'b010000;
		17 : SATA_MAX_WAKE_0_BINARY = 6'b010001;
		18 : SATA_MAX_WAKE_0_BINARY = 6'b010010;
		19 : SATA_MAX_WAKE_0_BINARY = 6'b010011;
		20 : SATA_MAX_WAKE_0_BINARY = 6'b010100;
		21 : SATA_MAX_WAKE_0_BINARY = 6'b010101;
		22 : SATA_MAX_WAKE_0_BINARY = 6'b010110;
		23 : SATA_MAX_WAKE_0_BINARY = 6'b010111;
		24 : SATA_MAX_WAKE_0_BINARY = 6'b011000;
		25 : SATA_MAX_WAKE_0_BINARY = 6'b011001;
		26 : SATA_MAX_WAKE_0_BINARY = 6'b011010;
		27 : SATA_MAX_WAKE_0_BINARY = 6'b011011;
		28 : SATA_MAX_WAKE_0_BINARY = 6'b011100;
		29 : SATA_MAX_WAKE_0_BINARY = 6'b011101;
		30 : SATA_MAX_WAKE_0_BINARY = 6'b011110;
		31 : SATA_MAX_WAKE_0_BINARY = 6'b011111;
		32 : SATA_MAX_WAKE_0_BINARY = 6'b100000;
		33 : SATA_MAX_WAKE_0_BINARY = 6'b100001;
		34 : SATA_MAX_WAKE_0_BINARY = 6'b100010;
		35 : SATA_MAX_WAKE_0_BINARY = 6'b100011;
		36 : SATA_MAX_WAKE_0_BINARY = 6'b100100;
		37 : SATA_MAX_WAKE_0_BINARY = 6'b100101;
		38 : SATA_MAX_WAKE_0_BINARY = 6'b100110;
		39 : SATA_MAX_WAKE_0_BINARY = 6'b100111;
		40 : SATA_MAX_WAKE_0_BINARY = 6'b101000;
		41 : SATA_MAX_WAKE_0_BINARY = 6'b101001;
		42 : SATA_MAX_WAKE_0_BINARY = 6'b101010;
		43 : SATA_MAX_WAKE_0_BINARY = 6'b101011;
		44 : SATA_MAX_WAKE_0_BINARY = 6'b101100;
		45 : SATA_MAX_WAKE_0_BINARY = 6'b101101;
		46 : SATA_MAX_WAKE_0_BINARY = 6'b101110;
		47 : SATA_MAX_WAKE_0_BINARY = 6'b101111;
		48 : SATA_MAX_WAKE_0_BINARY = 6'b110000;
		49 : SATA_MAX_WAKE_0_BINARY = 6'b110001;
		50 : SATA_MAX_WAKE_0_BINARY = 6'b110010;
		51 : SATA_MAX_WAKE_0_BINARY = 6'b110011;
		52 : SATA_MAX_WAKE_0_BINARY = 6'b110100;
		53 : SATA_MAX_WAKE_0_BINARY = 6'b110101;
		54 : SATA_MAX_WAKE_0_BINARY = 6'b110110;
		55 : SATA_MAX_WAKE_0_BINARY = 6'b110111;
		56 : SATA_MAX_WAKE_0_BINARY = 6'b111000;
		57 : SATA_MAX_WAKE_0_BINARY = 6'b111001;
		58 : SATA_MAX_WAKE_0_BINARY = 6'b111010;
		59 : SATA_MAX_WAKE_0_BINARY = 6'b111011;
		60 : SATA_MAX_WAKE_0_BINARY = 6'b111100;
		61 : SATA_MAX_WAKE_0_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MAX_WAKE_0 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MAX_WAKE_0);
			$finish;
		end
	endcase

	case (SATA_MIN_BURST_1)
		1 : SATA_MIN_BURST_1_BINARY = 6'b000001;
		2 : SATA_MIN_BURST_1_BINARY = 6'b000010;
		3 : SATA_MIN_BURST_1_BINARY = 6'b000011;
		4 : SATA_MIN_BURST_1_BINARY = 6'b000100;
		5 : SATA_MIN_BURST_1_BINARY = 6'b000101;
		6 : SATA_MIN_BURST_1_BINARY = 6'b000110;
		7 : SATA_MIN_BURST_1_BINARY = 6'b000111;
		8 : SATA_MIN_BURST_1_BINARY = 6'b001000;
		9 : SATA_MIN_BURST_1_BINARY = 6'b001001;
		10 : SATA_MIN_BURST_1_BINARY = 6'b001010;
		11 : SATA_MIN_BURST_1_BINARY = 6'b001011;
		12 : SATA_MIN_BURST_1_BINARY = 6'b001100;
		13 : SATA_MIN_BURST_1_BINARY = 6'b001101;
		14 : SATA_MIN_BURST_1_BINARY = 6'b001110;
		15 : SATA_MIN_BURST_1_BINARY = 6'b001111;
		16 : SATA_MIN_BURST_1_BINARY = 6'b010000;
		17 : SATA_MIN_BURST_1_BINARY = 6'b010001;
		18 : SATA_MIN_BURST_1_BINARY = 6'b010010;
		19 : SATA_MIN_BURST_1_BINARY = 6'b010011;
		20 : SATA_MIN_BURST_1_BINARY = 6'b010100;
		21 : SATA_MIN_BURST_1_BINARY = 6'b010101;
		22 : SATA_MIN_BURST_1_BINARY = 6'b010110;
		23 : SATA_MIN_BURST_1_BINARY = 6'b010111;
		24 : SATA_MIN_BURST_1_BINARY = 6'b011000;
		25 : SATA_MIN_BURST_1_BINARY = 6'b011001;
		26 : SATA_MIN_BURST_1_BINARY = 6'b011010;
		27 : SATA_MIN_BURST_1_BINARY = 6'b011011;
		28 : SATA_MIN_BURST_1_BINARY = 6'b011100;
		29 : SATA_MIN_BURST_1_BINARY = 6'b011101;
		30 : SATA_MIN_BURST_1_BINARY = 6'b011110;
		31 : SATA_MIN_BURST_1_BINARY = 6'b011111;
		32 : SATA_MIN_BURST_1_BINARY = 6'b100000;
		33 : SATA_MIN_BURST_1_BINARY = 6'b100001;
		34 : SATA_MIN_BURST_1_BINARY = 6'b100010;
		35 : SATA_MIN_BURST_1_BINARY = 6'b100011;
		36 : SATA_MIN_BURST_1_BINARY = 6'b100100;
		37 : SATA_MIN_BURST_1_BINARY = 6'b100101;
		38 : SATA_MIN_BURST_1_BINARY = 6'b100110;
		39 : SATA_MIN_BURST_1_BINARY = 6'b100111;
		40 : SATA_MIN_BURST_1_BINARY = 6'b101000;
		41 : SATA_MIN_BURST_1_BINARY = 6'b101001;
		42 : SATA_MIN_BURST_1_BINARY = 6'b101010;
		43 : SATA_MIN_BURST_1_BINARY = 6'b101011;
		44 : SATA_MIN_BURST_1_BINARY = 6'b101100;
		45 : SATA_MIN_BURST_1_BINARY = 6'b101101;
		46 : SATA_MIN_BURST_1_BINARY = 6'b101110;
		47 : SATA_MIN_BURST_1_BINARY = 6'b101111;
		48 : SATA_MIN_BURST_1_BINARY = 6'b110000;
		49 : SATA_MIN_BURST_1_BINARY = 6'b110001;
		50 : SATA_MIN_BURST_1_BINARY = 6'b110010;
		51 : SATA_MIN_BURST_1_BINARY = 6'b110011;
		52 : SATA_MIN_BURST_1_BINARY = 6'b110100;
		53 : SATA_MIN_BURST_1_BINARY = 6'b110101;
		54 : SATA_MIN_BURST_1_BINARY = 6'b110110;
		55 : SATA_MIN_BURST_1_BINARY = 6'b110111;
		56 : SATA_MIN_BURST_1_BINARY = 6'b111000;
		57 : SATA_MIN_BURST_1_BINARY = 6'b111001;
		58 : SATA_MIN_BURST_1_BINARY = 6'b111010;
		59 : SATA_MIN_BURST_1_BINARY = 6'b111011;
		60 : SATA_MIN_BURST_1_BINARY = 6'b111100;
		61 : SATA_MIN_BURST_1_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MIN_BURST_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MIN_BURST_1);
			$finish;
		end
	endcase

	case (SATA_MAX_BURST_1)
		1 : SATA_MAX_BURST_1_BINARY = 6'b000001;
		2 : SATA_MAX_BURST_1_BINARY = 6'b000010;
		3 : SATA_MAX_BURST_1_BINARY = 6'b000011;
		4 : SATA_MAX_BURST_1_BINARY = 6'b000100;
		5 : SATA_MAX_BURST_1_BINARY = 6'b000101;
		6 : SATA_MAX_BURST_1_BINARY = 6'b000110;
		7 : SATA_MAX_BURST_1_BINARY = 6'b000111;
		8 : SATA_MAX_BURST_1_BINARY = 6'b001000;
		9 : SATA_MAX_BURST_1_BINARY = 6'b001001;
		10 : SATA_MAX_BURST_1_BINARY = 6'b001010;
		11 : SATA_MAX_BURST_1_BINARY = 6'b001011;
		12 : SATA_MAX_BURST_1_BINARY = 6'b001100;
		13 : SATA_MAX_BURST_1_BINARY = 6'b001101;
		14 : SATA_MAX_BURST_1_BINARY = 6'b001110;
		15 : SATA_MAX_BURST_1_BINARY = 6'b001111;
		16 : SATA_MAX_BURST_1_BINARY = 6'b010000;
		17 : SATA_MAX_BURST_1_BINARY = 6'b010001;
		18 : SATA_MAX_BURST_1_BINARY = 6'b010010;
		19 : SATA_MAX_BURST_1_BINARY = 6'b010011;
		20 : SATA_MAX_BURST_1_BINARY = 6'b010100;
		21 : SATA_MAX_BURST_1_BINARY = 6'b010101;
		22 : SATA_MAX_BURST_1_BINARY = 6'b010110;
		23 : SATA_MAX_BURST_1_BINARY = 6'b010111;
		24 : SATA_MAX_BURST_1_BINARY = 6'b011000;
		25 : SATA_MAX_BURST_1_BINARY = 6'b011001;
		26 : SATA_MAX_BURST_1_BINARY = 6'b011010;
		27 : SATA_MAX_BURST_1_BINARY = 6'b011011;
		28 : SATA_MAX_BURST_1_BINARY = 6'b011100;
		29 : SATA_MAX_BURST_1_BINARY = 6'b011101;
		30 : SATA_MAX_BURST_1_BINARY = 6'b011110;
		31 : SATA_MAX_BURST_1_BINARY = 6'b011111;
		32 : SATA_MAX_BURST_1_BINARY = 6'b100000;
		33 : SATA_MAX_BURST_1_BINARY = 6'b100001;
		34 : SATA_MAX_BURST_1_BINARY = 6'b100010;
		35 : SATA_MAX_BURST_1_BINARY = 6'b100011;
		36 : SATA_MAX_BURST_1_BINARY = 6'b100100;
		37 : SATA_MAX_BURST_1_BINARY = 6'b100101;
		38 : SATA_MAX_BURST_1_BINARY = 6'b100110;
		39 : SATA_MAX_BURST_1_BINARY = 6'b100111;
		40 : SATA_MAX_BURST_1_BINARY = 6'b101000;
		41 : SATA_MAX_BURST_1_BINARY = 6'b101001;
		42 : SATA_MAX_BURST_1_BINARY = 6'b101010;
		43 : SATA_MAX_BURST_1_BINARY = 6'b101011;
		44 : SATA_MAX_BURST_1_BINARY = 6'b101100;
		45 : SATA_MAX_BURST_1_BINARY = 6'b101101;
		46 : SATA_MAX_BURST_1_BINARY = 6'b101110;
		47 : SATA_MAX_BURST_1_BINARY = 6'b101111;
		48 : SATA_MAX_BURST_1_BINARY = 6'b110000;
		49 : SATA_MAX_BURST_1_BINARY = 6'b110001;
		50 : SATA_MAX_BURST_1_BINARY = 6'b110010;
		51 : SATA_MAX_BURST_1_BINARY = 6'b110011;
		52 : SATA_MAX_BURST_1_BINARY = 6'b110100;
		53 : SATA_MAX_BURST_1_BINARY = 6'b110101;
		54 : SATA_MAX_BURST_1_BINARY = 6'b110110;
		55 : SATA_MAX_BURST_1_BINARY = 6'b110111;
		56 : SATA_MAX_BURST_1_BINARY = 6'b111000;
		57 : SATA_MAX_BURST_1_BINARY = 6'b111001;
		58 : SATA_MAX_BURST_1_BINARY = 6'b111010;
		59 : SATA_MAX_BURST_1_BINARY = 6'b111011;
		60 : SATA_MAX_BURST_1_BINARY = 6'b111100;
		61 : SATA_MAX_BURST_1_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MAX_BURST_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MAX_BURST_1);
			$finish;
		end
	endcase

	case (SATA_MIN_INIT_1)
		1 : SATA_MIN_INIT_1_BINARY = 6'b000001;
		2 : SATA_MIN_INIT_1_BINARY = 6'b000010;
		3 : SATA_MIN_INIT_1_BINARY = 6'b000011;
		4 : SATA_MIN_INIT_1_BINARY = 6'b000100;
		5 : SATA_MIN_INIT_1_BINARY = 6'b000101;
		6 : SATA_MIN_INIT_1_BINARY = 6'b000110;
		7 : SATA_MIN_INIT_1_BINARY = 6'b000111;
		8 : SATA_MIN_INIT_1_BINARY = 6'b001000;
		9 : SATA_MIN_INIT_1_BINARY = 6'b001001;
		10 : SATA_MIN_INIT_1_BINARY = 6'b001010;
		11 : SATA_MIN_INIT_1_BINARY = 6'b001011;
		12 : SATA_MIN_INIT_1_BINARY = 6'b001100;
		13 : SATA_MIN_INIT_1_BINARY = 6'b001101;
		14 : SATA_MIN_INIT_1_BINARY = 6'b001110;
		15 : SATA_MIN_INIT_1_BINARY = 6'b001111;
		16 : SATA_MIN_INIT_1_BINARY = 6'b010000;
		17 : SATA_MIN_INIT_1_BINARY = 6'b010001;
		18 : SATA_MIN_INIT_1_BINARY = 6'b010010;
		19 : SATA_MIN_INIT_1_BINARY = 6'b010011;
		20 : SATA_MIN_INIT_1_BINARY = 6'b010100;
		21 : SATA_MIN_INIT_1_BINARY = 6'b010101;
		22 : SATA_MIN_INIT_1_BINARY = 6'b010110;
		23 : SATA_MIN_INIT_1_BINARY = 6'b010111;
		24 : SATA_MIN_INIT_1_BINARY = 6'b011000;
		25 : SATA_MIN_INIT_1_BINARY = 6'b011001;
		26 : SATA_MIN_INIT_1_BINARY = 6'b011010;
		27 : SATA_MIN_INIT_1_BINARY = 6'b011011;
		28 : SATA_MIN_INIT_1_BINARY = 6'b011100;
		29 : SATA_MIN_INIT_1_BINARY = 6'b011101;
		30 : SATA_MIN_INIT_1_BINARY = 6'b011110;
		31 : SATA_MIN_INIT_1_BINARY = 6'b011111;
		32 : SATA_MIN_INIT_1_BINARY = 6'b100000;
		33 : SATA_MIN_INIT_1_BINARY = 6'b100001;
		34 : SATA_MIN_INIT_1_BINARY = 6'b100010;
		35 : SATA_MIN_INIT_1_BINARY = 6'b100011;
		36 : SATA_MIN_INIT_1_BINARY = 6'b100100;
		37 : SATA_MIN_INIT_1_BINARY = 6'b100101;
		38 : SATA_MIN_INIT_1_BINARY = 6'b100110;
		39 : SATA_MIN_INIT_1_BINARY = 6'b100111;
		40 : SATA_MIN_INIT_1_BINARY = 6'b101000;
		41 : SATA_MIN_INIT_1_BINARY = 6'b101001;
		42 : SATA_MIN_INIT_1_BINARY = 6'b101010;
		43 : SATA_MIN_INIT_1_BINARY = 6'b101011;
		44 : SATA_MIN_INIT_1_BINARY = 6'b101100;
		45 : SATA_MIN_INIT_1_BINARY = 6'b101101;
		46 : SATA_MIN_INIT_1_BINARY = 6'b101110;
		47 : SATA_MIN_INIT_1_BINARY = 6'b101111;
		48 : SATA_MIN_INIT_1_BINARY = 6'b110000;
		49 : SATA_MIN_INIT_1_BINARY = 6'b110001;
		50 : SATA_MIN_INIT_1_BINARY = 6'b110010;
		51 : SATA_MIN_INIT_1_BINARY = 6'b110011;
		52 : SATA_MIN_INIT_1_BINARY = 6'b110100;
		53 : SATA_MIN_INIT_1_BINARY = 6'b110101;
		54 : SATA_MIN_INIT_1_BINARY = 6'b110110;
		55 : SATA_MIN_INIT_1_BINARY = 6'b110111;
		56 : SATA_MIN_INIT_1_BINARY = 6'b111000;
		57 : SATA_MIN_INIT_1_BINARY = 6'b111001;
		58 : SATA_MIN_INIT_1_BINARY = 6'b111010;
		59 : SATA_MIN_INIT_1_BINARY = 6'b111011;
		60 : SATA_MIN_INIT_1_BINARY = 6'b111100;
		61 : SATA_MIN_INIT_1_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MIN_INIT_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MIN_INIT_1);
			$finish;
		end
	endcase

	case (SATA_MAX_INIT_1)
		1 : SATA_MAX_INIT_1_BINARY = 6'b000001;
		2 : SATA_MAX_INIT_1_BINARY = 6'b000010;
		3 : SATA_MAX_INIT_1_BINARY = 6'b000011;
		4 : SATA_MAX_INIT_1_BINARY = 6'b000100;
		5 : SATA_MAX_INIT_1_BINARY = 6'b000101;
		6 : SATA_MAX_INIT_1_BINARY = 6'b000110;
		7 : SATA_MAX_INIT_1_BINARY = 6'b000111;
		8 : SATA_MAX_INIT_1_BINARY = 6'b001000;
		9 : SATA_MAX_INIT_1_BINARY = 6'b001001;
		10 : SATA_MAX_INIT_1_BINARY = 6'b001010;
		11 : SATA_MAX_INIT_1_BINARY = 6'b001011;
		12 : SATA_MAX_INIT_1_BINARY = 6'b001100;
		13 : SATA_MAX_INIT_1_BINARY = 6'b001101;
		14 : SATA_MAX_INIT_1_BINARY = 6'b001110;
		15 : SATA_MAX_INIT_1_BINARY = 6'b001111;
		16 : SATA_MAX_INIT_1_BINARY = 6'b010000;
		17 : SATA_MAX_INIT_1_BINARY = 6'b010001;
		18 : SATA_MAX_INIT_1_BINARY = 6'b010010;
		19 : SATA_MAX_INIT_1_BINARY = 6'b010011;
		20 : SATA_MAX_INIT_1_BINARY = 6'b010100;
		21 : SATA_MAX_INIT_1_BINARY = 6'b010101;
		22 : SATA_MAX_INIT_1_BINARY = 6'b010110;
		23 : SATA_MAX_INIT_1_BINARY = 6'b010111;
		24 : SATA_MAX_INIT_1_BINARY = 6'b011000;
		25 : SATA_MAX_INIT_1_BINARY = 6'b011001;
		26 : SATA_MAX_INIT_1_BINARY = 6'b011010;
		27 : SATA_MAX_INIT_1_BINARY = 6'b011011;
		28 : SATA_MAX_INIT_1_BINARY = 6'b011100;
		29 : SATA_MAX_INIT_1_BINARY = 6'b011101;
		30 : SATA_MAX_INIT_1_BINARY = 6'b011110;
		31 : SATA_MAX_INIT_1_BINARY = 6'b011111;
		32 : SATA_MAX_INIT_1_BINARY = 6'b100000;
		33 : SATA_MAX_INIT_1_BINARY = 6'b100001;
		34 : SATA_MAX_INIT_1_BINARY = 6'b100010;
		35 : SATA_MAX_INIT_1_BINARY = 6'b100011;
		36 : SATA_MAX_INIT_1_BINARY = 6'b100100;
		37 : SATA_MAX_INIT_1_BINARY = 6'b100101;
		38 : SATA_MAX_INIT_1_BINARY = 6'b100110;
		39 : SATA_MAX_INIT_1_BINARY = 6'b100111;
		40 : SATA_MAX_INIT_1_BINARY = 6'b101000;
		41 : SATA_MAX_INIT_1_BINARY = 6'b101001;
		42 : SATA_MAX_INIT_1_BINARY = 6'b101010;
		43 : SATA_MAX_INIT_1_BINARY = 6'b101011;
		44 : SATA_MAX_INIT_1_BINARY = 6'b101100;
		45 : SATA_MAX_INIT_1_BINARY = 6'b101101;
		46 : SATA_MAX_INIT_1_BINARY = 6'b101110;
		47 : SATA_MAX_INIT_1_BINARY = 6'b101111;
		48 : SATA_MAX_INIT_1_BINARY = 6'b110000;
		49 : SATA_MAX_INIT_1_BINARY = 6'b110001;
		50 : SATA_MAX_INIT_1_BINARY = 6'b110010;
		51 : SATA_MAX_INIT_1_BINARY = 6'b110011;
		52 : SATA_MAX_INIT_1_BINARY = 6'b110100;
		53 : SATA_MAX_INIT_1_BINARY = 6'b110101;
		54 : SATA_MAX_INIT_1_BINARY = 6'b110110;
		55 : SATA_MAX_INIT_1_BINARY = 6'b110111;
		56 : SATA_MAX_INIT_1_BINARY = 6'b111000;
		57 : SATA_MAX_INIT_1_BINARY = 6'b111001;
		58 : SATA_MAX_INIT_1_BINARY = 6'b111010;
		59 : SATA_MAX_INIT_1_BINARY = 6'b111011;
		60 : SATA_MAX_INIT_1_BINARY = 6'b111100;
		61 : SATA_MAX_INIT_1_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MAX_INIT_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MAX_INIT_1);
			$finish;
		end
	endcase

	case (SATA_MIN_WAKE_1)
		1 : SATA_MIN_WAKE_1_BINARY = 6'b000001;
		2 : SATA_MIN_WAKE_1_BINARY = 6'b000010;
		3 : SATA_MIN_WAKE_1_BINARY = 6'b000011;
		4 : SATA_MIN_WAKE_1_BINARY = 6'b000100;
		5 : SATA_MIN_WAKE_1_BINARY = 6'b000101;
		6 : SATA_MIN_WAKE_1_BINARY = 6'b000110;
		7 : SATA_MIN_WAKE_1_BINARY = 6'b000111;
		8 : SATA_MIN_WAKE_1_BINARY = 6'b001000;
		9 : SATA_MIN_WAKE_1_BINARY = 6'b001001;
		10 : SATA_MIN_WAKE_1_BINARY = 6'b001010;
		11 : SATA_MIN_WAKE_1_BINARY = 6'b001011;
		12 : SATA_MIN_WAKE_1_BINARY = 6'b001100;
		13 : SATA_MIN_WAKE_1_BINARY = 6'b001101;
		14 : SATA_MIN_WAKE_1_BINARY = 6'b001110;
		15 : SATA_MIN_WAKE_1_BINARY = 6'b001111;
		16 : SATA_MIN_WAKE_1_BINARY = 6'b010000;
		17 : SATA_MIN_WAKE_1_BINARY = 6'b010001;
		18 : SATA_MIN_WAKE_1_BINARY = 6'b010010;
		19 : SATA_MIN_WAKE_1_BINARY = 6'b010011;
		20 : SATA_MIN_WAKE_1_BINARY = 6'b010100;
		21 : SATA_MIN_WAKE_1_BINARY = 6'b010101;
		22 : SATA_MIN_WAKE_1_BINARY = 6'b010110;
		23 : SATA_MIN_WAKE_1_BINARY = 6'b010111;
		24 : SATA_MIN_WAKE_1_BINARY = 6'b011000;
		25 : SATA_MIN_WAKE_1_BINARY = 6'b011001;
		26 : SATA_MIN_WAKE_1_BINARY = 6'b011010;
		27 : SATA_MIN_WAKE_1_BINARY = 6'b011011;
		28 : SATA_MIN_WAKE_1_BINARY = 6'b011100;
		29 : SATA_MIN_WAKE_1_BINARY = 6'b011101;
		30 : SATA_MIN_WAKE_1_BINARY = 6'b011110;
		31 : SATA_MIN_WAKE_1_BINARY = 6'b011111;
		32 : SATA_MIN_WAKE_1_BINARY = 6'b100000;
		33 : SATA_MIN_WAKE_1_BINARY = 6'b100001;
		34 : SATA_MIN_WAKE_1_BINARY = 6'b100010;
		35 : SATA_MIN_WAKE_1_BINARY = 6'b100011;
		36 : SATA_MIN_WAKE_1_BINARY = 6'b100100;
		37 : SATA_MIN_WAKE_1_BINARY = 6'b100101;
		38 : SATA_MIN_WAKE_1_BINARY = 6'b100110;
		39 : SATA_MIN_WAKE_1_BINARY = 6'b100111;
		40 : SATA_MIN_WAKE_1_BINARY = 6'b101000;
		41 : SATA_MIN_WAKE_1_BINARY = 6'b101001;
		42 : SATA_MIN_WAKE_1_BINARY = 6'b101010;
		43 : SATA_MIN_WAKE_1_BINARY = 6'b101011;
		44 : SATA_MIN_WAKE_1_BINARY = 6'b101100;
		45 : SATA_MIN_WAKE_1_BINARY = 6'b101101;
		46 : SATA_MIN_WAKE_1_BINARY = 6'b101110;
		47 : SATA_MIN_WAKE_1_BINARY = 6'b101111;
		48 : SATA_MIN_WAKE_1_BINARY = 6'b110000;
		49 : SATA_MIN_WAKE_1_BINARY = 6'b110001;
		50 : SATA_MIN_WAKE_1_BINARY = 6'b110010;
		51 : SATA_MIN_WAKE_1_BINARY = 6'b110011;
		52 : SATA_MIN_WAKE_1_BINARY = 6'b110100;
		53 : SATA_MIN_WAKE_1_BINARY = 6'b110101;
		54 : SATA_MIN_WAKE_1_BINARY = 6'b110110;
		55 : SATA_MIN_WAKE_1_BINARY = 6'b110111;
		56 : SATA_MIN_WAKE_1_BINARY = 6'b111000;
		57 : SATA_MIN_WAKE_1_BINARY = 6'b111001;
		58 : SATA_MIN_WAKE_1_BINARY = 6'b111010;
		59 : SATA_MIN_WAKE_1_BINARY = 6'b111011;
		60 : SATA_MIN_WAKE_1_BINARY = 6'b111100;
		61 : SATA_MIN_WAKE_1_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MIN_WAKE_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MIN_WAKE_1);
			$finish;
		end
	endcase

	case (SATA_MAX_WAKE_1)
		1 : SATA_MAX_WAKE_1_BINARY = 6'b000001;
		2 : SATA_MAX_WAKE_1_BINARY = 6'b000010;
		3 : SATA_MAX_WAKE_1_BINARY = 6'b000011;
		4 : SATA_MAX_WAKE_1_BINARY = 6'b000100;
		5 : SATA_MAX_WAKE_1_BINARY = 6'b000101;
		6 : SATA_MAX_WAKE_1_BINARY = 6'b000110;
		7 : SATA_MAX_WAKE_1_BINARY = 6'b000111;
		8 : SATA_MAX_WAKE_1_BINARY = 6'b001000;
		9 : SATA_MAX_WAKE_1_BINARY = 6'b001001;
		10 : SATA_MAX_WAKE_1_BINARY = 6'b001010;
		11 : SATA_MAX_WAKE_1_BINARY = 6'b001011;
		12 : SATA_MAX_WAKE_1_BINARY = 6'b001100;
		13 : SATA_MAX_WAKE_1_BINARY = 6'b001101;
		14 : SATA_MAX_WAKE_1_BINARY = 6'b001110;
		15 : SATA_MAX_WAKE_1_BINARY = 6'b001111;
		16 : SATA_MAX_WAKE_1_BINARY = 6'b010000;
		17 : SATA_MAX_WAKE_1_BINARY = 6'b010001;
		18 : SATA_MAX_WAKE_1_BINARY = 6'b010010;
		19 : SATA_MAX_WAKE_1_BINARY = 6'b010011;
		20 : SATA_MAX_WAKE_1_BINARY = 6'b010100;
		21 : SATA_MAX_WAKE_1_BINARY = 6'b010101;
		22 : SATA_MAX_WAKE_1_BINARY = 6'b010110;
		23 : SATA_MAX_WAKE_1_BINARY = 6'b010111;
		24 : SATA_MAX_WAKE_1_BINARY = 6'b011000;
		25 : SATA_MAX_WAKE_1_BINARY = 6'b011001;
		26 : SATA_MAX_WAKE_1_BINARY = 6'b011010;
		27 : SATA_MAX_WAKE_1_BINARY = 6'b011011;
		28 : SATA_MAX_WAKE_1_BINARY = 6'b011100;
		29 : SATA_MAX_WAKE_1_BINARY = 6'b011101;
		30 : SATA_MAX_WAKE_1_BINARY = 6'b011110;
		31 : SATA_MAX_WAKE_1_BINARY = 6'b011111;
		32 : SATA_MAX_WAKE_1_BINARY = 6'b100000;
		33 : SATA_MAX_WAKE_1_BINARY = 6'b100001;
		34 : SATA_MAX_WAKE_1_BINARY = 6'b100010;
		35 : SATA_MAX_WAKE_1_BINARY = 6'b100011;
		36 : SATA_MAX_WAKE_1_BINARY = 6'b100100;
		37 : SATA_MAX_WAKE_1_BINARY = 6'b100101;
		38 : SATA_MAX_WAKE_1_BINARY = 6'b100110;
		39 : SATA_MAX_WAKE_1_BINARY = 6'b100111;
		40 : SATA_MAX_WAKE_1_BINARY = 6'b101000;
		41 : SATA_MAX_WAKE_1_BINARY = 6'b101001;
		42 : SATA_MAX_WAKE_1_BINARY = 6'b101010;
		43 : SATA_MAX_WAKE_1_BINARY = 6'b101011;
		44 : SATA_MAX_WAKE_1_BINARY = 6'b101100;
		45 : SATA_MAX_WAKE_1_BINARY = 6'b101101;
		46 : SATA_MAX_WAKE_1_BINARY = 6'b101110;
		47 : SATA_MAX_WAKE_1_BINARY = 6'b101111;
		48 : SATA_MAX_WAKE_1_BINARY = 6'b110000;
		49 : SATA_MAX_WAKE_1_BINARY = 6'b110001;
		50 : SATA_MAX_WAKE_1_BINARY = 6'b110010;
		51 : SATA_MAX_WAKE_1_BINARY = 6'b110011;
		52 : SATA_MAX_WAKE_1_BINARY = 6'b110100;
		53 : SATA_MAX_WAKE_1_BINARY = 6'b110101;
		54 : SATA_MAX_WAKE_1_BINARY = 6'b110110;
		55 : SATA_MAX_WAKE_1_BINARY = 6'b110111;
		56 : SATA_MAX_WAKE_1_BINARY = 6'b111000;
		57 : SATA_MAX_WAKE_1_BINARY = 6'b111001;
		58 : SATA_MAX_WAKE_1_BINARY = 6'b111010;
		59 : SATA_MAX_WAKE_1_BINARY = 6'b111011;
		60 : SATA_MAX_WAKE_1_BINARY = 6'b111100;
		61 : SATA_MAX_WAKE_1_BINARY = 6'b111101;
		default : begin
			$display("Attribute Syntax Error : The Attribute SATA_MAX_WAKE_1 on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1 to 61.", SATA_MAX_WAKE_1);
			$finish;
		end
	endcase

	case (CLK25_DIVIDER)
		1 : CLK25_DIVIDER_BINARY = 3'b000;
		2 : CLK25_DIVIDER_BINARY = 3'b001;
		3 : CLK25_DIVIDER_BINARY = 3'b010;
		4 : CLK25_DIVIDER_BINARY = 3'b011;
		5 : CLK25_DIVIDER_BINARY = 3'b100;
		6 : CLK25_DIVIDER_BINARY = 3'b101;
		10 : CLK25_DIVIDER_BINARY = 3'b110;
		12 : CLK25_DIVIDER_BINARY = 3'b111;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLK25_DIVIDER on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3, 4, 5, 6, 10 or 12.", CLK25_DIVIDER);
			$finish;
		end
	endcase

	case (OVERSAMPLE_MODE)
		"FALSE" : OVERSAMPLE_MODE_BINARY = 1'b0;
		"TRUE" : OVERSAMPLE_MODE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute OVERSAMPLE_MODE on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", OVERSAMPLE_MODE);
			$finish;
		end
	endcase

	case (TXGEARBOX_USE_0)
		"FALSE" : TXGEARBOX_USE_0_BINARY = 1'b0;
		"TRUE" : TXGEARBOX_USE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute TXGEARBOX_USE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TXGEARBOX_USE_0);
			$finish;
		end
	endcase

	case (RXGEARBOX_USE_0)
		"FALSE" : RXGEARBOX_USE_0_BINARY = 1'b0;
		"TRUE" : RXGEARBOX_USE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RXGEARBOX_USE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RXGEARBOX_USE_0);
			$finish;
		end
	endcase

	case (TXGEARBOX_USE_1)
		"FALSE" : TXGEARBOX_USE_1_BINARY = 1'b0;
		"TRUE" : TXGEARBOX_USE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute TXGEARBOX_USE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", TXGEARBOX_USE_1);
			$finish;
		end
	endcase

	case (RXGEARBOX_USE_1)
		"FALSE" : RXGEARBOX_USE_1_BINARY = 1'b0;
		"TRUE" : RXGEARBOX_USE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RXGEARBOX_USE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RXGEARBOX_USE_1);
			$finish;
		end
	endcase

	case (PLL_FB_DCCEN)
		"FALSE" : PLL_FB_DCCEN_BINARY = 1'b0;
		"TRUE" : PLL_FB_DCCEN_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute PLL_FB_DCCEN on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PLL_FB_DCCEN);
			$finish;
		end
	endcase

	case (CLKRCV_TRST)
		"FALSE" : CLKRCV_TRST_BINARY = 1'b0;
		"TRUE" : CLKRCV_TRST_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute CLKRCV_TRST on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKRCV_TRST);
			$finish;
		end
	endcase

	case (RX_EN_IDLE_HOLD_DFE_0)
		"FALSE" : RX_EN_IDLE_HOLD_DFE_0_BINARY = 1'b0;
		"TRUE" : RX_EN_IDLE_HOLD_DFE_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_EN_IDLE_HOLD_DFE_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_HOLD_DFE_0);
			$finish;
		end
	endcase

	case (RX_EN_IDLE_RESET_BUF_0)
		"FALSE" : RX_EN_IDLE_RESET_BUF_0_BINARY = 1'b0;
		"TRUE" : RX_EN_IDLE_RESET_BUF_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_EN_IDLE_RESET_BUF_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_RESET_BUF_0);
			$finish;
		end
	endcase

	case (RX_EN_IDLE_HOLD_DFE_1)
		"FALSE" : RX_EN_IDLE_HOLD_DFE_1_BINARY = 1'b0;
		"TRUE" : RX_EN_IDLE_HOLD_DFE_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_EN_IDLE_HOLD_DFE_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_HOLD_DFE_1);
			$finish;
		end
	endcase

	case (RX_EN_IDLE_RESET_BUF_1)
		"FALSE" : RX_EN_IDLE_RESET_BUF_1_BINARY = 1'b0;
		"TRUE" : RX_EN_IDLE_RESET_BUF_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_EN_IDLE_RESET_BUF_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_RESET_BUF_1);
			$finish;
		end
	endcase

	case (RX_EN_IDLE_HOLD_CDR)
		"FALSE" : RX_EN_IDLE_HOLD_CDR_BINARY = 1'b0;
		"TRUE" : RX_EN_IDLE_HOLD_CDR_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_EN_IDLE_HOLD_CDR on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_HOLD_CDR);
			$finish;
		end
	endcase

	case (RX_EN_IDLE_RESET_PH)
		"FALSE" : RX_EN_IDLE_RESET_PH_BINARY = 1'b0;
		"TRUE" : RX_EN_IDLE_RESET_PH_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_EN_IDLE_RESET_PH on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_RESET_PH);
			$finish;
		end
	endcase

	case (RX_EN_IDLE_RESET_FR)
		"FALSE" : RX_EN_IDLE_RESET_FR_BINARY = 1'b0;
		"TRUE" : RX_EN_IDLE_RESET_FR_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute RX_EN_IDLE_RESET_FR on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", RX_EN_IDLE_RESET_FR);
			$finish;
		end
	endcase

	case (SIM_GTXRESET_SPEEDUP)
		0 : SIM_GTXRESET_SPEEDUP_BINARY = 0;
		1 : SIM_GTXRESET_SPEEDUP_BINARY = 1;
		default : begin
			$display("Attribute Syntax Error : The Attribute SIM_GTXRESET_SPEEDUP on GTX_DUAL instance %m is set to %d.  Legal values for this attribute are  0 or 1.", SIM_GTXRESET_SPEEDUP);
			$finish;
		end
	endcase

        case (SIM_MODE)
       	      "FAST"   : SIM_MODE_BINARY = 1'b1;
              "LEGACY" : begin
			$display("Attribute Syntax Warning : The Attribute SIM_MODE on GTX_DUAL instance %m is set to %s. The Legacy model is not supported from ISE 11.1 onwards. GTX_DUAL defaults to FAST model. There are no functionality differences between GTX_DUAL LEGACY and GTX_DUAL FAST simulation models. Although, if you want to use the GTX_DUAL LEGACY model, please use an earlier ISE build", SIM_MODE);
		  //$finish;
	       end
	      default : begin
		   $display("Attribute Syntax Warning : The Attribute SIM_MODE on GTX_DUAL instance %m is set to %s.  Legal value for this attribute is FAST.", SIM_MODE);
		   //$finish;
		end
        endcase 
   
	case (SIM_RECEIVER_DETECT_PASS_0)
		"FALSE" : SIM_RECEIVER_DETECT_PASS_0_BINARY = 1'b0;
		"TRUE" : SIM_RECEIVER_DETECT_PASS_0_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute SIM_RECEIVER_DETECT_PASS_0 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", SIM_RECEIVER_DETECT_PASS_0);
			$finish;
		end
	endcase

	case (SIM_RECEIVER_DETECT_PASS_1)
		"FALSE" : SIM_RECEIVER_DETECT_PASS_1_BINARY = 1'b0;
		"TRUE" : SIM_RECEIVER_DETECT_PASS_1_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute SIM_RECEIVER_DETECT_PASS_1 on GTX_DUAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", SIM_RECEIVER_DETECT_PASS_1);
			$finish;
		end
	endcase
   
end

wire DRDY_delay;
wire PHYSTATUS0_delay;
wire PHYSTATUS1_delay;
wire PLLLKDET_delay;
wire REFCLKOUT_delay;
wire RESETDONE0_delay;
wire RESETDONE1_delay;
wire RXBYTEISALIGNED0_delay;
wire RXBYTEISALIGNED1_delay;
wire RXBYTEREALIGN0_delay;
wire RXBYTEREALIGN1_delay;
wire RXCHANBONDSEQ0_delay;
wire RXCHANBONDSEQ1_delay;
wire RXCHANISALIGNED0_delay;
wire RXCHANISALIGNED1_delay;
wire RXCHANREALIGN0_delay;
wire RXCHANREALIGN1_delay;
wire RXCOMMADET0_delay;
wire RXCOMMADET1_delay;
wire RXDATAVALID0_delay;
wire RXDATAVALID1_delay;
wire RXELECIDLE0_delay;
wire RXELECIDLE1_delay;
wire RXHEADERVALID0_delay;
wire RXHEADERVALID1_delay;
wire RXOVERSAMPLEERR0_delay;
wire RXOVERSAMPLEERR1_delay;
wire RXPRBSERR0_delay;
wire RXPRBSERR1_delay;
wire RXRECCLK0_delay;
wire RXRECCLK1_delay;
wire RXSTARTOFSEQ0_delay;
wire RXSTARTOFSEQ1_delay;
wire RXVALID0_delay;
wire RXVALID1_delay;
wire TXGEARBOXREADY0_delay;
wire TXGEARBOXREADY1_delay;
wire TXN0_delay;
wire TXN1_delay;
wire TXOUTCLK0_delay;
wire TXOUTCLK1_delay;
wire TXP0_delay;
wire TXP1_delay;
wire [15:0] DO_delay;
wire [1:0] RXLOSSOFSYNC0_delay;
wire [1:0] RXLOSSOFSYNC1_delay;
wire [1:0] TXBUFSTATUS0_delay;
wire [1:0] TXBUFSTATUS1_delay;
wire [2:0] DFESENSCAL0_delay;
wire [2:0] DFESENSCAL1_delay;
wire [2:0] RXBUFSTATUS0_delay;
wire [2:0] RXBUFSTATUS1_delay;
wire [2:0] RXCLKCORCNT0_delay;
wire [2:0] RXCLKCORCNT1_delay;
wire [2:0] RXHEADER0_delay;
wire [2:0] RXHEADER1_delay;
wire [2:0] RXSTATUS0_delay;
wire [2:0] RXSTATUS1_delay;
wire [31:0] RXDATA0_delay;
wire [31:0] RXDATA1_delay;
wire [3:0] DFETAP3MONITOR0_delay;
wire [3:0] DFETAP3MONITOR1_delay;
wire [3:0] DFETAP4MONITOR0_delay;
wire [3:0] DFETAP4MONITOR1_delay;
wire [3:0] RXCHARISCOMMA0_delay;
wire [3:0] RXCHARISCOMMA1_delay;
wire [3:0] RXCHARISK0_delay;
wire [3:0] RXCHARISK1_delay;
wire [3:0] RXCHBONDO0_delay;
wire [3:0] RXCHBONDO1_delay;
wire [3:0] RXDISPERR0_delay;
wire [3:0] RXDISPERR1_delay;
wire [3:0] RXNOTINTABLE0_delay;
wire [3:0] RXNOTINTABLE1_delay;
wire [3:0] RXRUNDISP0_delay;
wire [3:0] RXRUNDISP1_delay;
wire [3:0] TXKERR0_delay;
wire [3:0] TXKERR1_delay;
wire [3:0] TXRUNDISP0_delay;
wire [3:0] TXRUNDISP1_delay;
wire [4:0] DFEEYEDACMONITOR0_delay;
wire [4:0] DFEEYEDACMONITOR1_delay;
wire [4:0] DFETAP1MONITOR0_delay;
wire [4:0] DFETAP1MONITOR1_delay;
wire [4:0] DFETAP2MONITOR0_delay;
wire [4:0] DFETAP2MONITOR1_delay;
wire [5:0] DFECLKDLYADJMONITOR0_delay;
wire [5:0] DFECLKDLYADJMONITOR1_delay;

wire CLKIN_delay;
wire DCLK_delay;
wire DEN_delay;
wire DWE_delay;
wire GTXRESET_delay;
wire INTDATAWIDTH_delay;
wire PLLLKDETEN_delay;
wire PLLPOWERDOWN_delay;
wire PRBSCNTRESET0_delay;
wire PRBSCNTRESET1_delay;
wire REFCLKPWRDNB_delay;
wire RXBUFRESET0_delay;
wire RXBUFRESET1_delay;
wire RXCDRRESET0_delay;
wire RXCDRRESET1_delay;
wire RXCOMMADETUSE0_delay;
wire RXCOMMADETUSE1_delay;
wire RXDEC8B10BUSE0_delay;
wire RXDEC8B10BUSE1_delay;
wire RXENCHANSYNC0_delay;
wire RXENCHANSYNC1_delay;
wire RXENEQB0_delay;
wire RXENEQB1_delay;
wire RXENMCOMMAALIGN0_delay;
wire RXENMCOMMAALIGN1_delay;
wire RXENPCOMMAALIGN0_delay;
wire RXENPCOMMAALIGN1_delay;
wire RXENPMAPHASEALIGN0_delay;
wire RXENPMAPHASEALIGN1_delay;
wire RXENSAMPLEALIGN0_delay;
wire RXENSAMPLEALIGN1_delay;
wire RXGEARBOXSLIP0_delay;
wire RXGEARBOXSLIP1_delay;
wire RXN0_delay;
wire RXN1_delay;
wire RXP0_delay;
wire RXP1_delay;
wire RXPMASETPHASE0_delay;
wire RXPMASETPHASE1_delay;
wire RXPOLARITY0_delay;
wire RXPOLARITY1_delay;
wire RXRESET0_delay;
wire RXRESET1_delay;
wire RXSLIDE0_delay;
wire RXSLIDE1_delay;
wire RXUSRCLK0_delay;
wire RXUSRCLK1_delay;
wire RXUSRCLK20_delay;
wire RXUSRCLK21_delay;
wire TXCOMSTART0_delay;
wire TXCOMSTART1_delay;
wire TXCOMTYPE0_delay;
wire TXCOMTYPE1_delay;
wire TXDETECTRX0_delay;
wire TXDETECTRX1_delay;
wire TXELECIDLE0_delay;
wire TXELECIDLE1_delay;
wire TXENC8B10BUSE0_delay;
wire TXENC8B10BUSE1_delay;
wire TXENPMAPHASEALIGN0_delay;
wire TXENPMAPHASEALIGN1_delay;
wire TXINHIBIT0_delay;
wire TXINHIBIT1_delay;
wire TXPMASETPHASE0_delay;
wire TXPMASETPHASE1_delay;
wire TXPOLARITY0_delay;
wire TXPOLARITY1_delay;
wire TXRESET0_delay;
wire TXRESET1_delay;
wire TXSTARTSEQ0_delay;
wire TXSTARTSEQ1_delay;
wire TXUSRCLK0_delay;
wire TXUSRCLK1_delay;
wire TXUSRCLK20_delay;
wire TXUSRCLK21_delay;
wire [13:0] GTXTEST_delay;
wire [15:0] DI_delay;
wire [1:0] RXDATAWIDTH0_delay;
wire [1:0] RXDATAWIDTH1_delay;
wire [1:0] RXENPRBSTST0_delay;
wire [1:0] RXENPRBSTST1_delay;
wire [1:0] RXEQMIX0_delay;
wire [1:0] RXEQMIX1_delay;
wire [1:0] RXPOWERDOWN0_delay;
wire [1:0] RXPOWERDOWN1_delay;
wire [1:0] TXDATAWIDTH0_delay;
wire [1:0] TXDATAWIDTH1_delay;
wire [1:0] TXENPRBSTST0_delay;
wire [1:0] TXENPRBSTST1_delay;
wire [1:0] TXPOWERDOWN0_delay;
wire [1:0] TXPOWERDOWN1_delay;
wire [2:0] LOOPBACK0_delay;
wire [2:0] LOOPBACK1_delay;
wire [2:0] TXBUFDIFFCTRL0_delay;
wire [2:0] TXBUFDIFFCTRL1_delay;
wire [2:0] TXDIFFCTRL0_delay;
wire [2:0] TXDIFFCTRL1_delay;
wire [2:0] TXHEADER0_delay;
wire [2:0] TXHEADER1_delay;
wire [31:0] TXDATA0_delay;
wire [31:0] TXDATA1_delay;
wire [3:0] DFETAP30_delay;
wire [3:0] DFETAP31_delay;
wire [3:0] DFETAP40_delay;
wire [3:0] DFETAP41_delay;
wire [3:0] RXCHBONDI0_delay;
wire [3:0] RXCHBONDI1_delay;
wire [3:0] RXEQPOLE0_delay;
wire [3:0] RXEQPOLE1_delay;
wire [3:0] TXBYPASS8B10B0_delay;
wire [3:0] TXBYPASS8B10B1_delay;
wire [3:0] TXCHARDISPMODE0_delay;
wire [3:0] TXCHARDISPMODE1_delay;
wire [3:0] TXCHARDISPVAL0_delay;
wire [3:0] TXCHARDISPVAL1_delay;
wire [3:0] TXCHARISK0_delay;
wire [3:0] TXCHARISK1_delay;
wire [3:0] TXPREEMPHASIS0_delay;
wire [3:0] TXPREEMPHASIS1_delay;
wire [4:0] DFETAP10_delay;
wire [4:0] DFETAP11_delay;
wire [4:0] DFETAP20_delay;
wire [4:0] DFETAP21_delay;
wire [5:0] DFECLKDLYADJ0_delay;
wire [5:0] DFECLKDLYADJ1_delay;
wire [6:0] DADDR_delay;
wire [6:0] TXSEQUENCE0_delay;
wire [6:0] TXSEQUENCE1_delay;

assign #(CLK_DELAY) DFECLKDLYADJMONITOR0 = DFECLKDLYADJMONITOR0_delay;
assign #(CLK_DELAY) DFECLKDLYADJMONITOR1 = DFECLKDLYADJMONITOR1_delay;
assign #(CLK_DELAY) REFCLKOUT = REFCLKOUT_delay;
assign #(CLK_DELAY) RXCLKCORCNT0 = RXCLKCORCNT0_delay;
assign #(CLK_DELAY) RXCLKCORCNT1 = RXCLKCORCNT1_delay;
assign #(CLK_DELAY) RXRECCLK0 = RXRECCLK0_delay;
assign #(CLK_DELAY) RXRECCLK1 = RXRECCLK1_delay;
assign #(CLK_DELAY) TXOUTCLK0 = TXOUTCLK0_delay;
assign #(CLK_DELAY) TXOUTCLK1 = TXOUTCLK1_delay;

assign #(out_delay) DFEEYEDACMONITOR0 = DFEEYEDACMONITOR0_delay;
assign #(out_delay) DFEEYEDACMONITOR1 = DFEEYEDACMONITOR1_delay;
assign #(out_delay) DFESENSCAL0 = DFESENSCAL0_delay;
assign #(out_delay) DFESENSCAL1 = DFESENSCAL1_delay;
assign #(out_delay) DFETAP1MONITOR0 = DFETAP1MONITOR0_delay;
assign #(out_delay) DFETAP1MONITOR1 = DFETAP1MONITOR1_delay;
assign #(out_delay) DFETAP2MONITOR0 = DFETAP2MONITOR0_delay;
assign #(out_delay) DFETAP2MONITOR1 = DFETAP2MONITOR1_delay;
assign #(out_delay) DFETAP3MONITOR0 = DFETAP3MONITOR0_delay;
assign #(out_delay) DFETAP3MONITOR1 = DFETAP3MONITOR1_delay;
assign #(out_delay) DFETAP4MONITOR0 = DFETAP4MONITOR0_delay;
assign #(out_delay) DFETAP4MONITOR1 = DFETAP4MONITOR1_delay;
assign #(out_delay) DO = DO_delay;
assign #(out_delay) DRDY = DRDY_delay;
assign #(out_delay) PHYSTATUS0 = PHYSTATUS0_delay;
assign #(out_delay) PHYSTATUS1 = PHYSTATUS1_delay;
assign #(out_delay) PLLLKDET = PLLLKDET_delay;
assign #(out_delay) RESETDONE0 = RESETDONE0_delay;
assign #(out_delay) RESETDONE1 = RESETDONE1_delay;
assign #(out_delay) RXBUFSTATUS0 = RXBUFSTATUS0_delay;
assign #(out_delay) RXBUFSTATUS1 = RXBUFSTATUS1_delay;
assign #(out_delay) RXBYTEISALIGNED0 = RXBYTEISALIGNED0_delay;
assign #(out_delay) RXBYTEISALIGNED1 = RXBYTEISALIGNED1_delay;
assign #(out_delay) RXBYTEREALIGN0 = RXBYTEREALIGN0_delay;
assign #(out_delay) RXBYTEREALIGN1 = RXBYTEREALIGN1_delay;
assign #(out_delay) RXCHANBONDSEQ0 = RXCHANBONDSEQ0_delay;
assign #(out_delay) RXCHANBONDSEQ1 = RXCHANBONDSEQ1_delay;
assign #(out_delay) RXCHANISALIGNED0 = RXCHANISALIGNED0_delay;
assign #(out_delay) RXCHANISALIGNED1 = RXCHANISALIGNED1_delay;
assign #(out_delay) RXCHANREALIGN0 = RXCHANREALIGN0_delay;
assign #(out_delay) RXCHANREALIGN1 = RXCHANREALIGN1_delay;
assign #(out_delay) RXCHARISCOMMA0 = RXCHARISCOMMA0_delay;
assign #(out_delay) RXCHARISCOMMA1 = RXCHARISCOMMA1_delay;
assign #(out_delay) RXCHARISK0 = RXCHARISK0_delay;
assign #(out_delay) RXCHARISK1 = RXCHARISK1_delay;
assign #(out_delay) RXCHBONDO0 = RXCHBONDO0_delay;
assign #(out_delay) RXCHBONDO1 = RXCHBONDO1_delay;
assign #(out_delay) RXCOMMADET0 = RXCOMMADET0_delay;
assign #(out_delay) RXCOMMADET1 = RXCOMMADET1_delay;
assign #(out_delay) RXDATA0 = RXDATA0_delay;
assign #(out_delay) RXDATA1 = RXDATA1_delay;
assign #(out_delay) RXDATAVALID0 = RXDATAVALID0_delay;
assign #(out_delay) RXDATAVALID1 = RXDATAVALID1_delay;
assign #(out_delay) RXDISPERR0 = RXDISPERR0_delay;
assign #(out_delay) RXDISPERR1 = RXDISPERR1_delay;
assign #(out_delay) RXELECIDLE0 = RXELECIDLE0_delay;
assign #(out_delay) RXELECIDLE1 = RXELECIDLE1_delay;
assign #(out_delay) RXHEADER0 = RXHEADER0_delay;
assign #(out_delay) RXHEADER1 = RXHEADER1_delay;
assign #(out_delay) RXHEADERVALID0 = RXHEADERVALID0_delay;
assign #(out_delay) RXHEADERVALID1 = RXHEADERVALID1_delay;
assign #(out_delay) RXLOSSOFSYNC0 = RXLOSSOFSYNC0_delay;
assign #(out_delay) RXLOSSOFSYNC1 = RXLOSSOFSYNC1_delay;
assign #(out_delay) RXNOTINTABLE0 = RXNOTINTABLE0_delay;
assign #(out_delay) RXNOTINTABLE1 = RXNOTINTABLE1_delay;
assign #(out_delay) RXOVERSAMPLEERR0 = RXOVERSAMPLEERR0_delay;
assign #(out_delay) RXOVERSAMPLEERR1 = RXOVERSAMPLEERR1_delay;
assign #(out_delay) RXPRBSERR0 = RXPRBSERR0_delay;
assign #(out_delay) RXPRBSERR1 = RXPRBSERR1_delay;
assign #(out_delay) RXRUNDISP0 = RXRUNDISP0_delay;
assign #(out_delay) RXRUNDISP1 = RXRUNDISP1_delay;
assign #(out_delay) RXSTARTOFSEQ0 = RXSTARTOFSEQ0_delay;
assign #(out_delay) RXSTARTOFSEQ1 = RXSTARTOFSEQ1_delay;
assign #(out_delay) RXSTATUS0 = RXSTATUS0_delay;
assign #(out_delay) RXSTATUS1 = RXSTATUS1_delay;
assign #(out_delay) RXVALID0 = RXVALID0_delay;
assign #(out_delay) RXVALID1 = RXVALID1_delay;
assign #(out_delay) TXBUFSTATUS0 = TXBUFSTATUS0_delay;
assign #(out_delay) TXBUFSTATUS1 = TXBUFSTATUS1_delay;
assign #(out_delay) TXGEARBOXREADY0 = TXGEARBOXREADY0_delay;
assign #(out_delay) TXGEARBOXREADY1 = TXGEARBOXREADY1_delay;
assign #(out_delay) TXKERR0 = TXKERR0_delay;
assign #(out_delay) TXKERR1 = TXKERR1_delay;
assign #(out_delay) TXN0 = TXN0_delay;
assign #(out_delay) TXN1 = TXN1_delay;
assign #(out_delay) TXP0 = TXP0_delay;
assign #(out_delay) TXP1 = TXP1_delay;
assign #(out_delay) TXRUNDISP0 = TXRUNDISP0_delay;
assign #(out_delay) TXRUNDISP1 = TXRUNDISP1_delay;

assign #(CLK_DELAY) DCLK_delay = DCLK;
assign #(CLK_DELAY) RXUSRCLK0_delay = RXUSRCLK0;
assign #(CLK_DELAY) RXUSRCLK1_delay = RXUSRCLK1;
assign #(CLK_DELAY) RXUSRCLK20_delay = RXUSRCLK20;
assign #(CLK_DELAY) RXUSRCLK21_delay = RXUSRCLK21;
assign #(CLK_DELAY) TXUSRCLK0_delay = TXUSRCLK0;
assign #(CLK_DELAY) TXUSRCLK1_delay = TXUSRCLK1;
assign #(CLK_DELAY) TXUSRCLK20_delay = TXUSRCLK20;
assign #(CLK_DELAY) TXUSRCLK21_delay = TXUSRCLK21;

assign #(in_delay) CLKIN_delay = CLKIN;
assign #(in_delay) DADDR_delay = DADDR;
assign #(in_delay) DEN_delay = DEN;
assign #(in_delay) DFECLKDLYADJ0_delay = DFECLKDLYADJ0;
assign #(in_delay) DFECLKDLYADJ1_delay = DFECLKDLYADJ1;
assign #(in_delay) DFETAP10_delay = DFETAP10;
assign #(in_delay) DFETAP11_delay = DFETAP11;
assign #(in_delay) DFETAP20_delay = DFETAP20;
assign #(in_delay) DFETAP21_delay = DFETAP21;
assign #(in_delay) DFETAP30_delay = DFETAP30;
assign #(in_delay) DFETAP31_delay = DFETAP31;
assign #(in_delay) DFETAP40_delay = DFETAP40;
assign #(in_delay) DFETAP41_delay = DFETAP41;
assign #(in_delay) DI_delay = DI;
assign #(in_delay) DWE_delay = DWE;
assign #(in_delay) GTXRESET_delay = GTXRESET;
assign #(in_delay) GTXTEST_delay = GTXTEST;
assign #(in_delay) INTDATAWIDTH_delay = INTDATAWIDTH;
assign #(in_delay) LOOPBACK0_delay = LOOPBACK0;
assign #(in_delay) LOOPBACK1_delay = LOOPBACK1;
assign #(in_delay) PLLLKDETEN_delay = PLLLKDETEN;
assign #(in_delay) PLLPOWERDOWN_delay = PLLPOWERDOWN;
assign #(in_delay) PRBSCNTRESET0_delay = PRBSCNTRESET0;
assign #(in_delay) PRBSCNTRESET1_delay = PRBSCNTRESET1;
assign #(in_delay) REFCLKPWRDNB_delay = REFCLKPWRDNB;
assign #(in_delay) RXBUFRESET0_delay = RXBUFRESET0;
assign #(in_delay) RXBUFRESET1_delay = RXBUFRESET1;
assign #(in_delay) RXCDRRESET0_delay = RXCDRRESET0;
assign #(in_delay) RXCDRRESET1_delay = RXCDRRESET1;
assign #(in_delay) RXCHBONDI0_delay = RXCHBONDI0;
assign #(in_delay) RXCHBONDI1_delay = RXCHBONDI1;
assign #(in_delay) RXCOMMADETUSE0_delay = RXCOMMADETUSE0;
assign #(in_delay) RXCOMMADETUSE1_delay = RXCOMMADETUSE1;
assign #(in_delay) RXDATAWIDTH0_delay = RXDATAWIDTH0;
assign #(in_delay) RXDATAWIDTH1_delay = RXDATAWIDTH1;
assign #(in_delay) RXDEC8B10BUSE0_delay = RXDEC8B10BUSE0;
assign #(in_delay) RXDEC8B10BUSE1_delay = RXDEC8B10BUSE1;
assign #(in_delay) RXENCHANSYNC0_delay = RXENCHANSYNC0;
assign #(in_delay) RXENCHANSYNC1_delay = RXENCHANSYNC1;
assign #(in_delay) RXENEQB0_delay = RXENEQB0;
assign #(in_delay) RXENEQB1_delay = RXENEQB1;
assign #(in_delay) RXENMCOMMAALIGN0_delay = RXENMCOMMAALIGN0;
assign #(in_delay) RXENMCOMMAALIGN1_delay = RXENMCOMMAALIGN1;
assign #(in_delay) RXENPCOMMAALIGN0_delay = RXENPCOMMAALIGN0;
assign #(in_delay) RXENPCOMMAALIGN1_delay = RXENPCOMMAALIGN1;
assign #(in_delay) RXENPMAPHASEALIGN0_delay = RXENPMAPHASEALIGN0;
assign #(in_delay) RXENPMAPHASEALIGN1_delay = RXENPMAPHASEALIGN1;
assign #(in_delay) RXENPRBSTST0_delay = RXENPRBSTST0;
assign #(in_delay) RXENPRBSTST1_delay = RXENPRBSTST1;
assign #(in_delay) RXENSAMPLEALIGN0_delay = RXENSAMPLEALIGN0;
assign #(in_delay) RXENSAMPLEALIGN1_delay = RXENSAMPLEALIGN1;
assign #(in_delay) RXEQMIX0_delay = RXEQMIX0;
assign #(in_delay) RXEQMIX1_delay = RXEQMIX1;
assign #(in_delay) RXEQPOLE0_delay = RXEQPOLE0;
assign #(in_delay) RXEQPOLE1_delay = RXEQPOLE1;
assign #(in_delay) RXGEARBOXSLIP0_delay = RXGEARBOXSLIP0;
assign #(in_delay) RXGEARBOXSLIP1_delay = RXGEARBOXSLIP1;
assign #(in_delay) RXN0_delay = RXN0;
assign #(in_delay) RXN1_delay = RXN1;
assign #(in_delay) RXP0_delay = RXP0;
assign #(in_delay) RXP1_delay = RXP1;
assign #(in_delay) RXPMASETPHASE0_delay = RXPMASETPHASE0;
assign #(in_delay) RXPMASETPHASE1_delay = RXPMASETPHASE1;
assign #(in_delay) RXPOLARITY0_delay = RXPOLARITY0;
assign #(in_delay) RXPOLARITY1_delay = RXPOLARITY1;
assign #(in_delay) RXPOWERDOWN0_delay = RXPOWERDOWN0;
assign #(in_delay) RXPOWERDOWN1_delay = RXPOWERDOWN1;
assign #(in_delay) RXRESET0_delay = RXRESET0;
assign #(in_delay) RXRESET1_delay = RXRESET1;
assign #(in_delay) RXSLIDE0_delay = RXSLIDE0;
assign #(in_delay) RXSLIDE1_delay = RXSLIDE1;
assign #(in_delay) TXBUFDIFFCTRL0_delay = TXBUFDIFFCTRL0;
assign #(in_delay) TXBUFDIFFCTRL1_delay = TXBUFDIFFCTRL1;
assign #(in_delay) TXBYPASS8B10B0_delay = TXBYPASS8B10B0;
assign #(in_delay) TXBYPASS8B10B1_delay = TXBYPASS8B10B1;
assign #(in_delay) TXCHARDISPMODE0_delay = TXCHARDISPMODE0;
assign #(in_delay) TXCHARDISPMODE1_delay = TXCHARDISPMODE1;
assign #(in_delay) TXCHARDISPVAL0_delay = TXCHARDISPVAL0;
assign #(in_delay) TXCHARDISPVAL1_delay = TXCHARDISPVAL1;
assign #(in_delay) TXCHARISK0_delay = TXCHARISK0;
assign #(in_delay) TXCHARISK1_delay = TXCHARISK1;
assign #(in_delay) TXCOMSTART0_delay = TXCOMSTART0;
assign #(in_delay) TXCOMSTART1_delay = TXCOMSTART1;
assign #(in_delay) TXCOMTYPE0_delay = TXCOMTYPE0;
assign #(in_delay) TXCOMTYPE1_delay = TXCOMTYPE1;
assign #(in_delay) TXDATA0_delay = TXDATA0;
assign #(in_delay) TXDATA1_delay = TXDATA1;
assign #(in_delay) TXDATAWIDTH0_delay = TXDATAWIDTH0;
assign #(in_delay) TXDATAWIDTH1_delay = TXDATAWIDTH1;
assign #(in_delay) TXDETECTRX0_delay = TXDETECTRX0;
assign #(in_delay) TXDETECTRX1_delay = TXDETECTRX1;
assign #(in_delay) TXDIFFCTRL0_delay = TXDIFFCTRL0;
assign #(in_delay) TXDIFFCTRL1_delay = TXDIFFCTRL1;
assign #(in_delay) TXELECIDLE0_delay = TXELECIDLE0;
assign #(in_delay) TXELECIDLE1_delay = TXELECIDLE1;
assign #(in_delay) TXENC8B10BUSE0_delay = TXENC8B10BUSE0;
assign #(in_delay) TXENC8B10BUSE1_delay = TXENC8B10BUSE1;
assign #(in_delay) TXENPMAPHASEALIGN0_delay = TXENPMAPHASEALIGN0;
assign #(in_delay) TXENPMAPHASEALIGN1_delay = TXENPMAPHASEALIGN1;
assign #(in_delay) TXENPRBSTST0_delay = TXENPRBSTST0;
assign #(in_delay) TXENPRBSTST1_delay = TXENPRBSTST1;
assign #(in_delay) TXHEADER0_delay = TXHEADER0;
assign #(in_delay) TXHEADER1_delay = TXHEADER1;
assign #(in_delay) TXINHIBIT0_delay = TXINHIBIT0;
assign #(in_delay) TXINHIBIT1_delay = TXINHIBIT1;
assign #(in_delay) TXPMASETPHASE0_delay = TXPMASETPHASE0;
assign #(in_delay) TXPMASETPHASE1_delay = TXPMASETPHASE1;
assign #(in_delay) TXPOLARITY0_delay = TXPOLARITY0;
assign #(in_delay) TXPOLARITY1_delay = TXPOLARITY1;
assign #(in_delay) TXPOWERDOWN0_delay = TXPOWERDOWN0;
assign #(in_delay) TXPOWERDOWN1_delay = TXPOWERDOWN1;
assign #(in_delay) TXPREEMPHASIS0_delay = TXPREEMPHASIS0;
assign #(in_delay) TXPREEMPHASIS1_delay = TXPREEMPHASIS1;
assign #(in_delay) TXRESET0_delay = TXRESET0;
assign #(in_delay) TXRESET1_delay = TXRESET1;
assign #(in_delay) TXSEQUENCE0_delay = TXSEQUENCE0;
assign #(in_delay) TXSEQUENCE1_delay = TXSEQUENCE1;
assign #(in_delay) TXSTARTSEQ0_delay = TXSTARTSEQ0;
assign #(in_delay) TXSTARTSEQ1_delay = TXSTARTSEQ1;

 GTX_DUAL_FAST gtx_dual_fast_1 (
        .AC_CAP_DIS_0 (AC_CAP_DIS_0_BINARY),
	.AC_CAP_DIS_1 (AC_CAP_DIS_1_BINARY),
	.ALIGN_COMMA_WORD_0 (ALIGN_COMMA_WORD_0_BINARY),
	.ALIGN_COMMA_WORD_1 (ALIGN_COMMA_WORD_1_BINARY),
	.CB2_INH_CC_PERIOD_0 (CB2_INH_CC_PERIOD_0_BINARY),
	.CB2_INH_CC_PERIOD_1 (CB2_INH_CC_PERIOD_1_BINARY),
	.CDR_PH_ADJ_TIME (CDR_PH_ADJ_TIME),
	.CHAN_BOND_1_MAX_SKEW_0 (CHAN_BOND_1_MAX_SKEW_0_BINARY),
	.CHAN_BOND_1_MAX_SKEW_1 (CHAN_BOND_1_MAX_SKEW_1_BINARY),
	.CHAN_BOND_2_MAX_SKEW_0 (CHAN_BOND_2_MAX_SKEW_0_BINARY),
	.CHAN_BOND_2_MAX_SKEW_1 (CHAN_BOND_2_MAX_SKEW_1_BINARY),
	.CHAN_BOND_KEEP_ALIGN_0 (CHAN_BOND_KEEP_ALIGN_0_BINARY),
	.CHAN_BOND_KEEP_ALIGN_1 (CHAN_BOND_KEEP_ALIGN_1_BINARY),
	.CHAN_BOND_LEVEL_0 (CHAN_BOND_LEVEL_0_BINARY),
	.CHAN_BOND_LEVEL_1 (CHAN_BOND_LEVEL_1_BINARY),
	.CHAN_BOND_MODE_0 (CHAN_BOND_MODE_0_BINARY),
	.CHAN_BOND_MODE_1 (CHAN_BOND_MODE_1_BINARY),
	.CHAN_BOND_SEQ_1_1_0 (CHAN_BOND_SEQ_1_1_0),
	.CHAN_BOND_SEQ_1_1_1 (CHAN_BOND_SEQ_1_1_1),
	.CHAN_BOND_SEQ_1_2_0 (CHAN_BOND_SEQ_1_2_0),
	.CHAN_BOND_SEQ_1_2_1 (CHAN_BOND_SEQ_1_2_1),
	.CHAN_BOND_SEQ_1_3_0 (CHAN_BOND_SEQ_1_3_0),
	.CHAN_BOND_SEQ_1_3_1 (CHAN_BOND_SEQ_1_3_1),
	.CHAN_BOND_SEQ_1_4_0 (CHAN_BOND_SEQ_1_4_0),
	.CHAN_BOND_SEQ_1_4_1 (CHAN_BOND_SEQ_1_4_1),
	.CHAN_BOND_SEQ_1_ENABLE_0 (CHAN_BOND_SEQ_1_ENABLE_0),
	.CHAN_BOND_SEQ_1_ENABLE_1 (CHAN_BOND_SEQ_1_ENABLE_1),
	.CHAN_BOND_SEQ_2_1_0 (CHAN_BOND_SEQ_2_1_0),
	.CHAN_BOND_SEQ_2_1_1 (CHAN_BOND_SEQ_2_1_1),
	.CHAN_BOND_SEQ_2_2_0 (CHAN_BOND_SEQ_2_2_0),
	.CHAN_BOND_SEQ_2_2_1 (CHAN_BOND_SEQ_2_2_1),
	.CHAN_BOND_SEQ_2_3_0 (CHAN_BOND_SEQ_2_3_0),
	.CHAN_BOND_SEQ_2_3_1 (CHAN_BOND_SEQ_2_3_1),
	.CHAN_BOND_SEQ_2_4_0 (CHAN_BOND_SEQ_2_4_0),
	.CHAN_BOND_SEQ_2_4_1 (CHAN_BOND_SEQ_2_4_1),
	.CHAN_BOND_SEQ_2_ENABLE_0 (CHAN_BOND_SEQ_2_ENABLE_0),
	.CHAN_BOND_SEQ_2_ENABLE_1 (CHAN_BOND_SEQ_2_ENABLE_1),
	.CHAN_BOND_SEQ_2_USE_0 (CHAN_BOND_SEQ_2_USE_0_BINARY),
	.CHAN_BOND_SEQ_2_USE_1 (CHAN_BOND_SEQ_2_USE_1_BINARY),
	.CHAN_BOND_SEQ_LEN_0 (CHAN_BOND_SEQ_LEN_0_BINARY),
	.CHAN_BOND_SEQ_LEN_1 (CHAN_BOND_SEQ_LEN_1_BINARY),
	.CLK25_DIVIDER (CLK25_DIVIDER_BINARY),
	.CLKINDC_B (CLKINDC_B_BINARY),
	.CLKRCV_TRST (CLKRCV_TRST_BINARY),
	.CLK_CORRECT_USE_0 (CLK_CORRECT_USE_0_BINARY),
	.CLK_CORRECT_USE_1 (CLK_CORRECT_USE_1_BINARY),
	.CLK_COR_ADJ_LEN_0 (CLK_COR_ADJ_LEN_0_BINARY),
	.CLK_COR_ADJ_LEN_1 (CLK_COR_ADJ_LEN_1_BINARY),
	.CLK_COR_DET_LEN_0 (CLK_COR_DET_LEN_0_BINARY),
	.CLK_COR_DET_LEN_1 (CLK_COR_DET_LEN_1_BINARY),
	.CLK_COR_INSERT_IDLE_FLAG_0 (CLK_COR_INSERT_IDLE_FLAG_0_BINARY),
	.CLK_COR_INSERT_IDLE_FLAG_1 (CLK_COR_INSERT_IDLE_FLAG_1_BINARY),
	.CLK_COR_KEEP_IDLE_0 (CLK_COR_KEEP_IDLE_0_BINARY),
	.CLK_COR_KEEP_IDLE_1 (CLK_COR_KEEP_IDLE_1_BINARY),
	.CLK_COR_MAX_LAT_0 (CLK_COR_MAX_LAT_0_BINARY),
	.CLK_COR_MAX_LAT_1 (CLK_COR_MAX_LAT_1_BINARY),
	.CLK_COR_MIN_LAT_0 (CLK_COR_MIN_LAT_0_BINARY),
	.CLK_COR_MIN_LAT_1 (CLK_COR_MIN_LAT_1_BINARY),
	.CLK_COR_PRECEDENCE_0 (CLK_COR_PRECEDENCE_0_BINARY),
	.CLK_COR_PRECEDENCE_1 (CLK_COR_PRECEDENCE_1_BINARY),
	.CLK_COR_REPEAT_WAIT_0 (CLK_COR_REPEAT_WAIT_0_BINARY),
	.CLK_COR_REPEAT_WAIT_1 (CLK_COR_REPEAT_WAIT_1_BINARY),
	.CLK_COR_SEQ_1_1_0 (CLK_COR_SEQ_1_1_0),
	.CLK_COR_SEQ_1_1_1 (CLK_COR_SEQ_1_1_1),
	.CLK_COR_SEQ_1_2_0 (CLK_COR_SEQ_1_2_0),
	.CLK_COR_SEQ_1_2_1 (CLK_COR_SEQ_1_2_1),
	.CLK_COR_SEQ_1_3_0 (CLK_COR_SEQ_1_3_0),
	.CLK_COR_SEQ_1_3_1 (CLK_COR_SEQ_1_3_1),
	.CLK_COR_SEQ_1_4_0 (CLK_COR_SEQ_1_4_0),
	.CLK_COR_SEQ_1_4_1 (CLK_COR_SEQ_1_4_1),
	.CLK_COR_SEQ_1_ENABLE_0 (CLK_COR_SEQ_1_ENABLE_0),
	.CLK_COR_SEQ_1_ENABLE_1 (CLK_COR_SEQ_1_ENABLE_1),
	.CLK_COR_SEQ_2_1_0 (CLK_COR_SEQ_2_1_0),
	.CLK_COR_SEQ_2_1_1 (CLK_COR_SEQ_2_1_1),
	.CLK_COR_SEQ_2_2_0 (CLK_COR_SEQ_2_2_0),
	.CLK_COR_SEQ_2_2_1 (CLK_COR_SEQ_2_2_1),
	.CLK_COR_SEQ_2_3_0 (CLK_COR_SEQ_2_3_0),
	.CLK_COR_SEQ_2_3_1 (CLK_COR_SEQ_2_3_1),
	.CLK_COR_SEQ_2_4_0 (CLK_COR_SEQ_2_4_0),
	.CLK_COR_SEQ_2_4_1 (CLK_COR_SEQ_2_4_1),
	.CLK_COR_SEQ_2_ENABLE_0 (CLK_COR_SEQ_2_ENABLE_0),
	.CLK_COR_SEQ_2_ENABLE_1 (CLK_COR_SEQ_2_ENABLE_1),
	.CLK_COR_SEQ_2_USE_0 (CLK_COR_SEQ_2_USE_0_BINARY),
	.CLK_COR_SEQ_2_USE_1 (CLK_COR_SEQ_2_USE_1_BINARY),
	.CM_TRIM_0 (CM_TRIM_0),
	.CM_TRIM_1 (CM_TRIM_1),
	.COMMA_10B_ENABLE_0 (COMMA_10B_ENABLE_0),
	.COMMA_10B_ENABLE_1 (COMMA_10B_ENABLE_1),
	.COMMA_DOUBLE_0 (COMMA_DOUBLE_0_BINARY),
	.COMMA_DOUBLE_1 (COMMA_DOUBLE_1_BINARY),
	.COM_BURST_VAL_0 (COM_BURST_VAL_0),
	.COM_BURST_VAL_1 (COM_BURST_VAL_1),
	.DEC_MCOMMA_DETECT_0 (DEC_MCOMMA_DETECT_0_BINARY),
	.DEC_MCOMMA_DETECT_1 (DEC_MCOMMA_DETECT_1_BINARY),
	.DEC_PCOMMA_DETECT_0 (DEC_PCOMMA_DETECT_0_BINARY),
	.DEC_PCOMMA_DETECT_1 (DEC_PCOMMA_DETECT_1_BINARY),
	.DEC_VALID_COMMA_ONLY_0 (DEC_VALID_COMMA_ONLY_0_BINARY),
	.DEC_VALID_COMMA_ONLY_1 (DEC_VALID_COMMA_ONLY_1_BINARY),
	.DFE_CAL_TIME (DFE_CAL_TIME),
	.DFE_CFG_0 (DFE_CFG_0),
	.DFE_CFG_1 (DFE_CFG_1),
	.GEARBOX_ENDEC_0 (GEARBOX_ENDEC_0),
	.GEARBOX_ENDEC_1 (GEARBOX_ENDEC_1),
	.MCOMMA_10B_VALUE_0 (MCOMMA_10B_VALUE_0),
	.MCOMMA_10B_VALUE_1 (MCOMMA_10B_VALUE_1),
	.MCOMMA_DETECT_0 (MCOMMA_DETECT_0_BINARY),
	.MCOMMA_DETECT_1 (MCOMMA_DETECT_1_BINARY),
	.OOBDETECT_THRESHOLD_0 (OOBDETECT_THRESHOLD_0_BINARY),
	.OOBDETECT_THRESHOLD_1 (OOBDETECT_THRESHOLD_1_BINARY),
	.OOB_CLK_DIVIDER (OOB_CLK_DIVIDER_BINARY),
	.OVERSAMPLE_MODE (OVERSAMPLE_MODE_BINARY),
	.PCI_EXPRESS_MODE_0 (PCI_EXPRESS_MODE_0_BINARY),
	.PCI_EXPRESS_MODE_1 (PCI_EXPRESS_MODE_1_BINARY),
	.PCOMMA_10B_VALUE_0 (PCOMMA_10B_VALUE_0),
	.PCOMMA_10B_VALUE_1 (PCOMMA_10B_VALUE_1),
	.PCOMMA_DETECT_0 (PCOMMA_DETECT_0_BINARY),
	.PCOMMA_DETECT_1 (PCOMMA_DETECT_1_BINARY),
	.PLL_COM_CFG (PLL_COM_CFG),
	.PLL_CP_CFG (PLL_CP_CFG),			 
	.PLL_DIVSEL_FB (PLL_DIVSEL_FB_BINARY),
	.PLL_DIVSEL_REF (PLL_DIVSEL_REF_BINARY),
	.PLL_FB_DCCEN (PLL_FB_DCCEN_BINARY),
	.PLL_LKDET_CFG (PLL_LKDET_CFG),		 
	.PLL_RXDIVSEL_OUT_0 (PLL_RXDIVSEL_OUT_0_BINARY),
	.PLL_RXDIVSEL_OUT_1 (PLL_RXDIVSEL_OUT_1_BINARY),
	.PLL_SATA_0 (PLL_SATA_0_BINARY),
	.PLL_SATA_1 (PLL_SATA_1_BINARY),
	.PLL_TDCC_CFG (PLL_TDCC_CFG),			 
	.PLL_TXDIVSEL_OUT_0 (PLL_TXDIVSEL_OUT_0_BINARY),
	.PLL_TXDIVSEL_OUT_1 (PLL_TXDIVSEL_OUT_1_BINARY),
	.PMA_CDR_SCAN_0 (PMA_CDR_SCAN_0),
	.PMA_CDR_SCAN_1 (PMA_CDR_SCAN_1),
	.PMA_COM_CFG (PMA_COM_CFG),		 
	.PMA_RXSYNC_CFG_0 (PMA_RXSYNC_CFG_0),
	.PMA_RXSYNC_CFG_1 (PMA_RXSYNC_CFG_1),
	.PMA_RX_CFG_0 (PMA_RX_CFG_0),
	.PMA_RX_CFG_1 (PMA_RX_CFG_1),
	.PMA_TX_CFG_0 (PMA_TX_CFG_0),
	.PMA_TX_CFG_1 (PMA_TX_CFG_1),
	.PRBS_ERR_THRESHOLD_0 (PRBS_ERR_THRESHOLD_0),
	.PRBS_ERR_THRESHOLD_1 (PRBS_ERR_THRESHOLD_1),
	.RCV_TERM_GND_0 (RCV_TERM_GND_0_BINARY),
	.RCV_TERM_GND_1 (RCV_TERM_GND_1_BINARY),
	.RCV_TERM_VTTRX_0 (RCV_TERM_VTTRX_0_BINARY),
	.RCV_TERM_VTTRX_1 (RCV_TERM_VTTRX_1_BINARY),
	.RXGEARBOX_USE_0 (RXGEARBOX_USE_0_BINARY),
	.RXGEARBOX_USE_1 (RXGEARBOX_USE_1_BINARY),
	.RX_BUFFER_USE_0 (RX_BUFFER_USE_0_BINARY),
	.RX_BUFFER_USE_1 (RX_BUFFER_USE_1_BINARY),
	.RX_DECODE_SEQ_MATCH_0 (RX_DECODE_SEQ_MATCH_0_BINARY),
	.RX_DECODE_SEQ_MATCH_1 (RX_DECODE_SEQ_MATCH_1_BINARY),
	.RX_EN_IDLE_HOLD_CDR (RX_EN_IDLE_HOLD_CDR_BINARY),
	.RX_EN_IDLE_HOLD_DFE_0 (RX_EN_IDLE_HOLD_DFE_0_BINARY),
	.RX_EN_IDLE_HOLD_DFE_1 (RX_EN_IDLE_HOLD_DFE_1_BINARY),
	.RX_EN_IDLE_RESET_BUF_0 (RX_EN_IDLE_RESET_BUF_0_BINARY),
	.RX_EN_IDLE_RESET_BUF_1 (RX_EN_IDLE_RESET_BUF_1_BINARY),
	.RX_EN_IDLE_RESET_FR (RX_EN_IDLE_RESET_FR_BINARY),
	.RX_EN_IDLE_RESET_PH (RX_EN_IDLE_RESET_PH_BINARY),
	.RX_IDLE_HI_CNT_0 (RX_IDLE_HI_CNT_0),
	.RX_IDLE_HI_CNT_1 (RX_IDLE_HI_CNT_1),
	.RX_IDLE_LO_CNT_0 (RX_IDLE_LO_CNT_0),
	.RX_IDLE_LO_CNT_1 (RX_IDLE_LO_CNT_1),
	.RX_LOSS_OF_SYNC_FSM_0 (RX_LOSS_OF_SYNC_FSM_0_BINARY),
	.RX_LOSS_OF_SYNC_FSM_1 (RX_LOSS_OF_SYNC_FSM_1_BINARY),
	.RX_LOS_INVALID_INCR_0 (RX_LOS_INVALID_INCR_0_BINARY),
	.RX_LOS_INVALID_INCR_1 (RX_LOS_INVALID_INCR_1_BINARY),
	.RX_LOS_THRESHOLD_0 (RX_LOS_THRESHOLD_0_BINARY),
	.RX_LOS_THRESHOLD_1 (RX_LOS_THRESHOLD_1_BINARY),
	.RX_SLIDE_MODE_0 (RX_SLIDE_MODE_0_BINARY),
	.RX_SLIDE_MODE_1 (RX_SLIDE_MODE_1_BINARY),
	.RX_STATUS_FMT_0 (RX_STATUS_FMT_0_BINARY),
	.RX_STATUS_FMT_1 (RX_STATUS_FMT_1_BINARY),
	.RX_XCLK_SEL_0 (RX_XCLK_SEL_0_BINARY),
	.RX_XCLK_SEL_1 (RX_XCLK_SEL_1_BINARY),
	.SATA_BURST_VAL_0 (SATA_BURST_VAL_0),
	.SATA_BURST_VAL_1 (SATA_BURST_VAL_1),
	.SATA_IDLE_VAL_0 (SATA_IDLE_VAL_0),
	.SATA_IDLE_VAL_1 (SATA_IDLE_VAL_1),
	.SATA_MAX_BURST_0 (SATA_MAX_BURST_0_BINARY),
	.SATA_MAX_BURST_1 (SATA_MAX_BURST_1_BINARY),
	.SATA_MAX_INIT_0 (SATA_MAX_INIT_0_BINARY),
	.SATA_MAX_INIT_1 (SATA_MAX_INIT_1_BINARY),
	.SATA_MAX_WAKE_0 (SATA_MAX_WAKE_0_BINARY),
	.SATA_MAX_WAKE_1 (SATA_MAX_WAKE_1_BINARY),
	.SATA_MIN_BURST_0 (SATA_MIN_BURST_0_BINARY),
	.SATA_MIN_BURST_1 (SATA_MIN_BURST_1_BINARY),
	.SATA_MIN_INIT_0 (SATA_MIN_INIT_0_BINARY),
	.SATA_MIN_INIT_1 (SATA_MIN_INIT_1_BINARY),
	.SATA_MIN_WAKE_0 (SATA_MIN_WAKE_0_BINARY),
	.SATA_MIN_WAKE_1 (SATA_MIN_WAKE_1_BINARY),
	.SIM_GTXRESET_SPEEDUP (SIM_GTXRESET_SPEEDUP_BINARY),
	.SIM_PLL_PERDIV2 (SIM_PLL_PERDIV2),
	.SIM_RECEIVER_DETECT_PASS_0 (SIM_RECEIVER_DETECT_PASS_0_BINARY),
	.SIM_RECEIVER_DETECT_PASS_1 (SIM_RECEIVER_DETECT_PASS_1_BINARY),
	.STEPPING (1'b0),			 
	.TERMINATION_CTRL (TERMINATION_CTRL),
	.TERMINATION_IMP_0 (TERMINATION_IMP_0_BINARY),
	.TERMINATION_IMP_1 (TERMINATION_IMP_1_BINARY),
	.TERMINATION_OVRD (TERMINATION_OVRD_BINARY),
	.TRANS_TIME_FROM_P2_0 (TRANS_TIME_FROM_P2_0),
	.TRANS_TIME_FROM_P2_1 (TRANS_TIME_FROM_P2_1),
	.TRANS_TIME_NON_P2_0 (TRANS_TIME_NON_P2_0),
	.TRANS_TIME_NON_P2_1 (TRANS_TIME_NON_P2_1),
	.TRANS_TIME_TO_P2_0 (TRANS_TIME_TO_P2_0),
	.TRANS_TIME_TO_P2_1 (TRANS_TIME_TO_P2_1),
	.TXGEARBOX_USE_0 (TXGEARBOX_USE_0_BINARY),
	.TXGEARBOX_USE_1 (TXGEARBOX_USE_1_BINARY),
	.TXRX_INVERT_0 (TXRX_INVERT_0),
	.TXRX_INVERT_1 (TXRX_INVERT_1),
	.TX_BUFFER_USE_0 (TX_BUFFER_USE_0_BINARY),
	.TX_BUFFER_USE_1 (TX_BUFFER_USE_1_BINARY),
	.TX_DETECT_RX_CFG_0 (TX_DETECT_RX_CFG_0),
	.TX_DETECT_RX_CFG_1 (TX_DETECT_RX_CFG_1),
	.TX_IDLE_DELAY_0 (TX_IDLE_DELAY_0),
	.TX_IDLE_DELAY_1 (TX_IDLE_DELAY_1),
	.TX_XCLK_SEL_0 (TX_XCLK_SEL_0_BINARY),
	.TX_XCLK_SEL_1 (TX_XCLK_SEL_1_BINARY),

	.DFECLKDLYADJMONITOR0 (DFECLKDLYADJMONITOR0_delay),
	.DFECLKDLYADJMONITOR1 (DFECLKDLYADJMONITOR1_delay),
	.DFEEYEDACMONITOR0 (DFEEYEDACMONITOR0_delay),
	.DFEEYEDACMONITOR1 (DFEEYEDACMONITOR1_delay),
	.DFESENSCAL0 (DFESENSCAL0_delay),
	.DFESENSCAL1 (DFESENSCAL1_delay),
	.DFETAP1MONITOR0 (DFETAP1MONITOR0_delay),
	.DFETAP1MONITOR1 (DFETAP1MONITOR1_delay),
	.DFETAP2MONITOR0 (DFETAP2MONITOR0_delay),
	.DFETAP2MONITOR1 (DFETAP2MONITOR1_delay),
	.DFETAP3MONITOR0 (DFETAP3MONITOR0_delay),
	.DFETAP3MONITOR1 (DFETAP3MONITOR1_delay),
	.DFETAP4MONITOR0 (DFETAP4MONITOR0_delay),
	.DFETAP4MONITOR1 (DFETAP4MONITOR1_delay),
	.DO (DO_delay),
	.DRDY (DRDY_delay),
	.PHYSTATUS0 (PHYSTATUS0_delay),
	.PHYSTATUS1 (PHYSTATUS1_delay),
	.PLLLKDET (PLLLKDET_delay),
	.REFCLKOUT (REFCLKOUT_delay),
	.RESETDONE0 (RESETDONE0_delay),
	.RESETDONE1 (RESETDONE1_delay),
	.RXBUFSTATUS0 (RXBUFSTATUS0_delay),
	.RXBUFSTATUS1 (RXBUFSTATUS1_delay),
	.RXBYTEISALIGNED0 (RXBYTEISALIGNED0_delay),
	.RXBYTEISALIGNED1 (RXBYTEISALIGNED1_delay),
	.RXBYTEREALIGN0 (RXBYTEREALIGN0_delay),
	.RXBYTEREALIGN1 (RXBYTEREALIGN1_delay),
	.RXCHANBONDSEQ0 (RXCHANBONDSEQ0_delay),
	.RXCHANBONDSEQ1 (RXCHANBONDSEQ1_delay),
	.RXCHANISALIGNED0 (RXCHANISALIGNED0_delay),
	.RXCHANISALIGNED1 (RXCHANISALIGNED1_delay),
	.RXCHANREALIGN0 (RXCHANREALIGN0_delay),
	.RXCHANREALIGN1 (RXCHANREALIGN1_delay),
	.RXCHARISCOMMA0 (RXCHARISCOMMA0_delay),
	.RXCHARISCOMMA1 (RXCHARISCOMMA1_delay),
	.RXCHARISK0 (RXCHARISK0_delay),
	.RXCHARISK1 (RXCHARISK1_delay),
	.RXCHBONDO0 (RXCHBONDO0_delay),
	.RXCHBONDO1 (RXCHBONDO1_delay),
	.RXCLKCORCNT0 (RXCLKCORCNT0_delay),
	.RXCLKCORCNT1 (RXCLKCORCNT1_delay),
	.RXCOMMADET0 (RXCOMMADET0_delay),
	.RXCOMMADET1 (RXCOMMADET1_delay),
	.RXDATA0 (RXDATA0_delay),
	.RXDATA1 (RXDATA1_delay),
	.RXDATAVALID0 (RXDATAVALID0_delay),
	.RXDATAVALID1 (RXDATAVALID1_delay),
	.RXDISPERR0 (RXDISPERR0_delay),
	.RXDISPERR1 (RXDISPERR1_delay),
	.RXELECIDLE0 (RXELECIDLE0_delay),
	.RXELECIDLE1 (RXELECIDLE1_delay),
	.RXHEADER0 (RXHEADER0_delay),
	.RXHEADER1 (RXHEADER1_delay),
	.RXHEADERVALID0 (RXHEADERVALID0_delay),
	.RXHEADERVALID1 (RXHEADERVALID1_delay),
	.RXLOSSOFSYNC0 (RXLOSSOFSYNC0_delay),
	.RXLOSSOFSYNC1 (RXLOSSOFSYNC1_delay),
	.RXNOTINTABLE0 (RXNOTINTABLE0_delay),
	.RXNOTINTABLE1 (RXNOTINTABLE1_delay),
	.RXOVERSAMPLEERR0 (RXOVERSAMPLEERR0_delay),
	.RXOVERSAMPLEERR1 (RXOVERSAMPLEERR1_delay),
	.RXPRBSERR0 (RXPRBSERR0_delay),
	.RXPRBSERR1 (RXPRBSERR1_delay),
	.RXRECCLK0 (RXRECCLK0_delay),
	.RXRECCLK1 (RXRECCLK1_delay),
	.RXRUNDISP0 (RXRUNDISP0_delay),
	.RXRUNDISP1 (RXRUNDISP1_delay),
	.RXSTARTOFSEQ0 (RXSTARTOFSEQ0_delay),
	.RXSTARTOFSEQ1 (RXSTARTOFSEQ1_delay),
	.RXSTATUS0 (RXSTATUS0_delay),
	.RXSTATUS1 (RXSTATUS1_delay),
	.RXVALID0 (RXVALID0_delay),
	.RXVALID1 (RXVALID1_delay),
	.TXBUFSTATUS0 (TXBUFSTATUS0_delay),
	.TXBUFSTATUS1 (TXBUFSTATUS1_delay),
	.TXGEARBOXREADY0 (TXGEARBOXREADY0_delay),
	.TXGEARBOXREADY1 (TXGEARBOXREADY1_delay),
	.TXKERR0 (TXKERR0_delay),
	.TXKERR1 (TXKERR1_delay),
	.TXN0 (TXN0_delay),
	.TXN1 (TXN1_delay),
	.TXOUTCLK0 (TXOUTCLK0_delay),
	.TXOUTCLK1 (TXOUTCLK1_delay),
	.TXP0 (TXP0_delay),
	.TXP1 (TXP1_delay),
	.TXRUNDISP0 (TXRUNDISP0_delay),
	.TXRUNDISP1 (TXRUNDISP1_delay),

	.CLKIN (CLKIN_delay),
	.DADDR (DADDR_delay),
	.DCLK (DCLK_delay),
	.DEN (DEN_delay),
	.DFECLKDLYADJ0 (DFECLKDLYADJ0_delay),
	.DFECLKDLYADJ1 (DFECLKDLYADJ1_delay),
	.DFETAP10 (DFETAP10_delay),
	.DFETAP11 (DFETAP11_delay),
	.DFETAP20 (DFETAP20_delay),
	.DFETAP21 (DFETAP21_delay),
	.DFETAP30 (DFETAP30_delay),
	.DFETAP31 (DFETAP31_delay),
	.DFETAP40 (DFETAP40_delay),
	.DFETAP41 (DFETAP41_delay),
	.DI (DI_delay),
	.DWE (DWE_delay),
	.GTXRESET (GTXRESET_delay),
	.GTXTEST (GTXTEST_delay),
	.INTDATAWIDTH (INTDATAWIDTH_delay),
	.LOOPBACK0 (LOOPBACK0_delay),
	.LOOPBACK1 (LOOPBACK1_delay),
	.PLLLKDETEN (PLLLKDETEN_delay),
	.PLLPOWERDOWN (PLLPOWERDOWN_delay),
	.PRBSCNTRESET0 (PRBSCNTRESET0_delay),
	.PRBSCNTRESET1 (PRBSCNTRESET1_delay),
	.REFCLKPWRDNB (REFCLKPWRDNB_delay),
	.RXBUFRESET0 (RXBUFRESET0_delay),
	.RXBUFRESET1 (RXBUFRESET1_delay),
	.RXCDRRESET0 (RXCDRRESET0_delay),
	.RXCDRRESET1 (RXCDRRESET1_delay),
	.RXCHBONDI0 (RXCHBONDI0_delay),
	.RXCHBONDI1 (RXCHBONDI1_delay),
	.RXCOMMADETUSE0 (RXCOMMADETUSE0_delay),
	.RXCOMMADETUSE1 (RXCOMMADETUSE1_delay),
	.RXDATAWIDTH0 (RXDATAWIDTH0_delay),
	.RXDATAWIDTH1 (RXDATAWIDTH1_delay),
	.RXDEC8B10BUSE0 (RXDEC8B10BUSE0_delay),
	.RXDEC8B10BUSE1 (RXDEC8B10BUSE1_delay),
	.RXENCHANSYNC0 (RXENCHANSYNC0_delay),
	.RXENCHANSYNC1 (RXENCHANSYNC1_delay),
	.RXENEQB0 (RXENEQB0_delay),
	.RXENEQB1 (RXENEQB1_delay),
	.RXENMCOMMAALIGN0 (RXENMCOMMAALIGN0_delay),
	.RXENMCOMMAALIGN1 (RXENMCOMMAALIGN1_delay),
	.RXENPCOMMAALIGN0 (RXENPCOMMAALIGN0_delay),
	.RXENPCOMMAALIGN1 (RXENPCOMMAALIGN1_delay),
	.RXENPMAPHASEALIGN0 (RXENPMAPHASEALIGN0_delay),
	.RXENPMAPHASEALIGN1 (RXENPMAPHASEALIGN1_delay),
	.RXENPRBSTST0 (RXENPRBSTST0_delay),
	.RXENPRBSTST1 (RXENPRBSTST1_delay),
	.RXENSAMPLEALIGN0 (RXENSAMPLEALIGN0_delay),
	.RXENSAMPLEALIGN1 (RXENSAMPLEALIGN1_delay),
	.RXEQMIX0 (RXEQMIX0_delay),
	.RXEQMIX1 (RXEQMIX1_delay),
	.RXEQPOLE0 (RXEQPOLE0_delay),
	.RXEQPOLE1 (RXEQPOLE1_delay),
	.RXGEARBOXSLIP0 (RXGEARBOXSLIP0_delay),
	.RXGEARBOXSLIP1 (RXGEARBOXSLIP1_delay),
	.RXN0 (RXN0_delay),
	.RXN1 (RXN1_delay),
	.RXP0 (RXP0_delay),
	.RXP1 (RXP1_delay),
	.RXPMASETPHASE0 (RXPMASETPHASE0_delay),
	.RXPMASETPHASE1 (RXPMASETPHASE1_delay),
	.RXPOLARITY0 (RXPOLARITY0_delay),
	.RXPOLARITY1 (RXPOLARITY1_delay),
	.RXPOWERDOWN0 (RXPOWERDOWN0_delay),
	.RXPOWERDOWN1 (RXPOWERDOWN1_delay),
	.RXRESET0 (RXRESET0_delay),
	.RXRESET1 (RXRESET1_delay),
	.RXSLIDE0 (RXSLIDE0_delay),
	.RXSLIDE1 (RXSLIDE1_delay),
	.RXUSRCLK0 (RXUSRCLK0_delay),
	.RXUSRCLK1 (RXUSRCLK1_delay),
	.RXUSRCLK20 (RXUSRCLK20_delay),
	.RXUSRCLK21 (RXUSRCLK21_delay),
	.TXBUFDIFFCTRL0 (TXBUFDIFFCTRL0_delay),
	.TXBUFDIFFCTRL1 (TXBUFDIFFCTRL1_delay),
	.TXBYPASS8B10B0 (TXBYPASS8B10B0_delay),
	.TXBYPASS8B10B1 (TXBYPASS8B10B1_delay),
	.TXCHARDISPMODE0 (TXCHARDISPMODE0_delay),
	.TXCHARDISPMODE1 (TXCHARDISPMODE1_delay),
	.TXCHARDISPVAL0 (TXCHARDISPVAL0_delay),
	.TXCHARDISPVAL1 (TXCHARDISPVAL1_delay),
	.TXCHARISK0 (TXCHARISK0_delay),
	.TXCHARISK1 (TXCHARISK1_delay),
	.TXCOMSTART0 (TXCOMSTART0_delay),
	.TXCOMSTART1 (TXCOMSTART1_delay),
	.TXCOMTYPE0 (TXCOMTYPE0_delay),
	.TXCOMTYPE1 (TXCOMTYPE1_delay),
	.TXDATA0 (TXDATA0_delay),
	.TXDATA1 (TXDATA1_delay),
	.TXDATAWIDTH0 (TXDATAWIDTH0_delay),
	.TXDATAWIDTH1 (TXDATAWIDTH1_delay),
	.TXDETECTRX0 (TXDETECTRX0_delay),
	.TXDETECTRX1 (TXDETECTRX1_delay),
	.TXDIFFCTRL0 (TXDIFFCTRL0_delay),
	.TXDIFFCTRL1 (TXDIFFCTRL1_delay),
	.TXELECIDLE0 (TXELECIDLE0_delay),
	.TXELECIDLE1 (TXELECIDLE1_delay),
	.TXENC8B10BUSE0 (TXENC8B10BUSE0_delay),
	.TXENC8B10BUSE1 (TXENC8B10BUSE1_delay),
	.TXENPMAPHASEALIGN0 (TXENPMAPHASEALIGN0_delay),
	.TXENPMAPHASEALIGN1 (TXENPMAPHASEALIGN1_delay),
	.TXENPRBSTST0 (TXENPRBSTST0_delay),
	.TXENPRBSTST1 (TXENPRBSTST1_delay),
	.TXHEADER0 (TXHEADER0_delay),
	.TXHEADER1 (TXHEADER1_delay),
	.TXINHIBIT0 (TXINHIBIT0_delay),
	.TXINHIBIT1 (TXINHIBIT1_delay),
	.TXPMASETPHASE0 (TXPMASETPHASE0_delay),
	.TXPMASETPHASE1 (TXPMASETPHASE1_delay),
	.TXPOLARITY0 (TXPOLARITY0_delay),
	.TXPOLARITY1 (TXPOLARITY1_delay),
	.TXPOWERDOWN0 (TXPOWERDOWN0_delay),
	.TXPOWERDOWN1 (TXPOWERDOWN1_delay),
	.TXPREEMPHASIS0 (TXPREEMPHASIS0_delay),
	.TXPREEMPHASIS1 (TXPREEMPHASIS1_delay),
	.TXRESET0 (TXRESET0_delay),
	.TXRESET1 (TXRESET1_delay),
	.TXSEQUENCE0 (TXSEQUENCE0_delay),
	.TXSEQUENCE1 (TXSEQUENCE1_delay),
	.TXSTARTSEQ0 (TXSTARTSEQ0_delay),
	.TXSTARTSEQ1 (TXSTARTSEQ1_delay),
	.TXUSRCLK0 (TXUSRCLK0_delay),
	.TXUSRCLK1 (TXUSRCLK1_delay),
	.TXUSRCLK20 (TXUSRCLK20_delay),
	.TXUSRCLK21 (TXUSRCLK21_delay),
        .GSR(GSR)
     );
   
specify
	(CLKIN => REFCLKOUT) = (100, 100);
	(DCLK => DO) = (100, 100);
	(DCLK => DRDY) = (100, 100);
	(RXUSRCLK0 => RXCHBONDO0) = (100, 100);
	(RXUSRCLK1 => RXCHBONDO1) = (100, 100);
	(RXUSRCLK20 => DFECLKDLYADJMONITOR0) = (100, 100);
	(RXUSRCLK20 => DFEEYEDACMONITOR0) = (100, 100);
	(RXUSRCLK20 => DFESENSCAL0) = (100, 100);
	(RXUSRCLK20 => DFETAP1MONITOR0) = (100, 100);
	(RXUSRCLK20 => DFETAP2MONITOR0) = (100, 100);
	(RXUSRCLK20 => DFETAP3MONITOR0) = (100, 100);
	(RXUSRCLK20 => DFETAP4MONITOR0) = (100, 100);
	(RXUSRCLK20 => PHYSTATUS0) = (100, 100);
	(RXUSRCLK20 => RXBUFSTATUS0) = (100, 100);
	(RXUSRCLK20 => RXBYTEISALIGNED0) = (100, 100);
	(RXUSRCLK20 => RXBYTEREALIGN0) = (100, 100);
	(RXUSRCLK20 => RXCHANBONDSEQ0) = (100, 100);
	(RXUSRCLK20 => RXCHANISALIGNED0) = (100, 100);
	(RXUSRCLK20 => RXCHANREALIGN0) = (100, 100);
	(RXUSRCLK20 => RXCHARISCOMMA0) = (100, 100);
	(RXUSRCLK20 => RXCHARISK0) = (100, 100);
	(RXUSRCLK20 => RXCLKCORCNT0) = (100, 100);
	(RXUSRCLK20 => RXCOMMADET0) = (100, 100);
	(RXUSRCLK20 => RXDATA0) = (100, 100);
	(RXUSRCLK20 => RXDATAVALID0) = (100, 100);
	(RXUSRCLK20 => RXDISPERR0) = (100, 100);
	(RXUSRCLK20 => RXHEADER0) = (100, 100);
	(RXUSRCLK20 => RXHEADERVALID0) = (100, 100);
	(RXUSRCLK20 => RXLOSSOFSYNC0) = (100, 100);
	(RXUSRCLK20 => RXNOTINTABLE0) = (100, 100);
	(RXUSRCLK20 => RXOVERSAMPLEERR0) = (100, 100);
	(RXUSRCLK20 => RXPRBSERR0) = (100, 100);
	(RXUSRCLK20 => RXRUNDISP0) = (100, 100);
	(RXUSRCLK20 => RXSTARTOFSEQ0) = (100, 100);
	(RXUSRCLK20 => RXSTATUS0) = (100, 100);
	(RXUSRCLK20 => RXVALID0) = (100, 100);
	(RXUSRCLK21 => DFECLKDLYADJMONITOR1) = (100, 100);
	(RXUSRCLK21 => DFEEYEDACMONITOR1) = (100, 100);
	(RXUSRCLK21 => DFESENSCAL1) = (100, 100);
	(RXUSRCLK21 => DFETAP1MONITOR1) = (100, 100);
	(RXUSRCLK21 => DFETAP2MONITOR1) = (100, 100);
	(RXUSRCLK21 => DFETAP3MONITOR1) = (100, 100);
	(RXUSRCLK21 => DFETAP4MONITOR1) = (100, 100);
	(RXUSRCLK21 => PHYSTATUS1) = (100, 100);
	(RXUSRCLK21 => RXBUFSTATUS1) = (100, 100);
	(RXUSRCLK21 => RXBYTEISALIGNED1) = (100, 100);
	(RXUSRCLK21 => RXBYTEREALIGN1) = (100, 100);
	(RXUSRCLK21 => RXCHANBONDSEQ1) = (100, 100);
	(RXUSRCLK21 => RXCHANISALIGNED1) = (100, 100);
	(RXUSRCLK21 => RXCHANREALIGN1) = (100, 100);
	(RXUSRCLK21 => RXCHARISCOMMA1) = (100, 100);
	(RXUSRCLK21 => RXCHARISK1) = (100, 100);
	(RXUSRCLK21 => RXCLKCORCNT1) = (100, 100);
	(RXUSRCLK21 => RXCOMMADET1) = (100, 100);
	(RXUSRCLK21 => RXDATA1) = (100, 100);
	(RXUSRCLK21 => RXDATAVALID1) = (100, 100);
	(RXUSRCLK21 => RXDISPERR1) = (100, 100);
	(RXUSRCLK21 => RXHEADER1) = (100, 100);
	(RXUSRCLK21 => RXHEADERVALID1) = (100, 100);
	(RXUSRCLK21 => RXLOSSOFSYNC1) = (100, 100);
	(RXUSRCLK21 => RXNOTINTABLE1) = (100, 100);
	(RXUSRCLK21 => RXOVERSAMPLEERR1) = (100, 100);
	(RXUSRCLK21 => RXPRBSERR1) = (100, 100);
	(RXUSRCLK21 => RXRUNDISP1) = (100, 100);
	(RXUSRCLK21 => RXSTARTOFSEQ1) = (100, 100);
	(RXUSRCLK21 => RXSTATUS1) = (100, 100);
	(RXUSRCLK21 => RXVALID1) = (100, 100);
	(TXUSRCLK20 => TXBUFSTATUS0) = (100, 100);
	(TXUSRCLK20 => TXGEARBOXREADY0) = (100, 100);
	(TXUSRCLK20 => TXKERR0) = (100, 100);
	(TXUSRCLK20 => TXRUNDISP0) = (100, 100);
	(TXUSRCLK21 => TXBUFSTATUS1) = (100, 100);
	(TXUSRCLK21 => TXGEARBOXREADY1) = (100, 100);
	(TXUSRCLK21 => TXKERR1) = (100, 100);
	(TXUSRCLK21 => TXRUNDISP1) = (100, 100);
	specparam PATHPULSE$ = 0;
endspecify
endmodule
 
