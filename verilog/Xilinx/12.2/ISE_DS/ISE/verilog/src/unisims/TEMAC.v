///////////////////////////////////////////////////////////
//  Copyright (c) 1995/2006 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /    Vendor      : Xilinx 
// \  \    \/     Version : 10.1
//  \  \          Description : Xilinx Functional Simulation Library Component
//  /  /                        Tri-Mode Ethernet MAC
// /__/   /\      Filename    : TEMAC.v
// \  \  /  \     Timestamp   : Thu Dec 8 2005    
//  \__\/\__ \                    
//                                 
//  Revision:
//    12/08/05 - Initial version.
//    01/09/06 - Added case statement, specify block
//    02/06/06 - pinTime updates
//    02/23/06 - Updated Header
//    03/27/06 - Updated TEMAC smartmodel to version number 00.002 for following changes
//			CR#224695 - 
//				1. TEMAC smartmodel 16 bit client interface problem.
//				2. Compiled smartmodel with `delay_mode_zero directive
//			CR#226083 - 
//				1. Loopback attributes don't work in Verilog TEMAC smartmodel.
//			CR#224695 - 
//				1 . Added 50 ps input delay to all inputs(except clocks) going into temac swift model			
//    04/11/06 - CR#228762 - Added some missing path delays to timing block.
//    04/27/06 - CR#230105 - Fixed connectivity for CLK
//    05/23/06 - CR#231962 - Add buffers for connectivity
//    06/22/06 - CR#233879 - Add parameter bus range
//    09/15/06 - CR#423162 - Timing updates
//    10/26/06 -           - replaced zero_delay with CLK_DELAY to be consistent with writers (PPC440 update)
//    06/08/07 - CR#440717 - Add localparam EMAC0MIITXCLK_DELAY & EMAC1MIITXCLK_DELAY
//    08/28/07 - CR#447575 - Path Delay updates due to pinDev/pinTime updates
//  End Revision
///////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module TEMAC (
	DCRHOSTDONEIR,
	EMAC0CLIENTANINTERRUPT,
	EMAC0CLIENTRXBADFRAME,
	EMAC0CLIENTRXCLIENTCLKOUT,
	EMAC0CLIENTRXD,
	EMAC0CLIENTRXDVLD,
	EMAC0CLIENTRXDVLDMSW,
	EMAC0CLIENTRXFRAMEDROP,
	EMAC0CLIENTRXGOODFRAME,
	EMAC0CLIENTRXSTATS,
	EMAC0CLIENTRXSTATSBYTEVLD,
	EMAC0CLIENTRXSTATSVLD,
	EMAC0CLIENTTXACK,
	EMAC0CLIENTTXCLIENTCLKOUT,
	EMAC0CLIENTTXCOLLISION,
	EMAC0CLIENTTXRETRANSMIT,
	EMAC0CLIENTTXSTATS,
	EMAC0CLIENTTXSTATSBYTEVLD,
	EMAC0CLIENTTXSTATSVLD,
	EMAC0PHYENCOMMAALIGN,
	EMAC0PHYLOOPBACKMSB,
	EMAC0PHYMCLKOUT,
	EMAC0PHYMDOUT,
	EMAC0PHYMDTRI,
	EMAC0PHYMGTRXRESET,
	EMAC0PHYMGTTXRESET,
	EMAC0PHYPOWERDOWN,
	EMAC0PHYSYNCACQSTATUS,
	EMAC0PHYTXCHARDISPMODE,
	EMAC0PHYTXCHARDISPVAL,
	EMAC0PHYTXCHARISK,
	EMAC0PHYTXCLK,
	EMAC0PHYTXD,
	EMAC0PHYTXEN,
	EMAC0PHYTXER,
	EMAC0PHYTXGMIIMIICLKOUT,
	EMAC0SPEEDIS10100,
	EMAC1CLIENTANINTERRUPT,
	EMAC1CLIENTRXBADFRAME,
	EMAC1CLIENTRXCLIENTCLKOUT,
	EMAC1CLIENTRXD,
	EMAC1CLIENTRXDVLD,
	EMAC1CLIENTRXDVLDMSW,
	EMAC1CLIENTRXFRAMEDROP,
	EMAC1CLIENTRXGOODFRAME,
	EMAC1CLIENTRXSTATS,
	EMAC1CLIENTRXSTATSBYTEVLD,
	EMAC1CLIENTRXSTATSVLD,
	EMAC1CLIENTTXACK,
	EMAC1CLIENTTXCLIENTCLKOUT,
	EMAC1CLIENTTXCOLLISION,
	EMAC1CLIENTTXRETRANSMIT,
	EMAC1CLIENTTXSTATS,
	EMAC1CLIENTTXSTATSBYTEVLD,
	EMAC1CLIENTTXSTATSVLD,
	EMAC1PHYENCOMMAALIGN,
	EMAC1PHYLOOPBACKMSB,
	EMAC1PHYMCLKOUT,
	EMAC1PHYMDOUT,
	EMAC1PHYMDTRI,
	EMAC1PHYMGTRXRESET,
	EMAC1PHYMGTTXRESET,
	EMAC1PHYPOWERDOWN,
	EMAC1PHYSYNCACQSTATUS,
	EMAC1PHYTXCHARDISPMODE,
	EMAC1PHYTXCHARDISPVAL,
	EMAC1PHYTXCHARISK,
	EMAC1PHYTXCLK,
	EMAC1PHYTXD,
	EMAC1PHYTXEN,
	EMAC1PHYTXER,
	EMAC1PHYTXGMIIMIICLKOUT,
	EMAC1SPEEDIS10100,
	EMACDCRACK,
	EMACDCRDBUS,
	HOSTMIIMRDY,
	HOSTRDDATA,

	CLIENTEMAC0DCMLOCKED,
	CLIENTEMAC0PAUSEREQ,
	CLIENTEMAC0PAUSEVAL,
	CLIENTEMAC0RXCLIENTCLKIN,
	CLIENTEMAC0TXCLIENTCLKIN,
	CLIENTEMAC0TXD,
	CLIENTEMAC0TXDVLD,
	CLIENTEMAC0TXDVLDMSW,
	CLIENTEMAC0TXFIRSTBYTE,
	CLIENTEMAC0TXIFGDELAY,
	CLIENTEMAC0TXUNDERRUN,
	CLIENTEMAC1DCMLOCKED,
	CLIENTEMAC1PAUSEREQ,
	CLIENTEMAC1PAUSEVAL,
	CLIENTEMAC1RXCLIENTCLKIN,
	CLIENTEMAC1TXCLIENTCLKIN,
	CLIENTEMAC1TXD,
	CLIENTEMAC1TXDVLD,
	CLIENTEMAC1TXDVLDMSW,
	CLIENTEMAC1TXFIRSTBYTE,
	CLIENTEMAC1TXIFGDELAY,
	CLIENTEMAC1TXUNDERRUN,
	DCREMACABUS,
	DCREMACCLK,
	DCREMACDBUS,
	DCREMACENABLE,
	DCREMACREAD,
	DCREMACWRITE,
	HOSTADDR,
	HOSTCLK,
	HOSTEMAC1SEL,
	HOSTMIIMSEL,
	HOSTOPCODE,
	HOSTREQ,
	HOSTWRDATA,
	PHYEMAC0COL,
	PHYEMAC0CRS,
	PHYEMAC0GTXCLK,
	PHYEMAC0MCLKIN,
	PHYEMAC0MDIN,
	PHYEMAC0MIITXCLK,
	PHYEMAC0PHYAD,
	PHYEMAC0RXBUFERR,
	PHYEMAC0RXBUFSTATUS,
	PHYEMAC0RXCHARISCOMMA,
	PHYEMAC0RXCHARISK,
	PHYEMAC0RXCHECKINGCRC,
	PHYEMAC0RXCLK,
	PHYEMAC0RXCLKCORCNT,
	PHYEMAC0RXCOMMADET,
	PHYEMAC0RXD,
	PHYEMAC0RXDISPERR,
	PHYEMAC0RXDV,
	PHYEMAC0RXER,
	PHYEMAC0RXLOSSOFSYNC,
	PHYEMAC0RXNOTINTABLE,
	PHYEMAC0RXRUNDISP,
	PHYEMAC0SIGNALDET,
	PHYEMAC0TXBUFERR,
	PHYEMAC0TXGMIIMIICLKIN,
	PHYEMAC1COL,
	PHYEMAC1CRS,
	PHYEMAC1GTXCLK,
	PHYEMAC1MCLKIN,
	PHYEMAC1MDIN,
	PHYEMAC1MIITXCLK,
	PHYEMAC1PHYAD,
	PHYEMAC1RXBUFERR,
	PHYEMAC1RXBUFSTATUS,
	PHYEMAC1RXCHARISCOMMA,
	PHYEMAC1RXCHARISK,
	PHYEMAC1RXCHECKINGCRC,
	PHYEMAC1RXCLK,
	PHYEMAC1RXCLKCORCNT,
	PHYEMAC1RXCOMMADET,
	PHYEMAC1RXD,
	PHYEMAC1RXDISPERR,
	PHYEMAC1RXDV,
	PHYEMAC1RXER,
	PHYEMAC1RXLOSSOFSYNC,
	PHYEMAC1RXNOTINTABLE,
	PHYEMAC1RXRUNDISP,
	PHYEMAC1SIGNALDET,
	PHYEMAC1TXBUFERR,
	PHYEMAC1TXGMIIMIICLKIN,
	RESET

);


parameter EMAC0_1000BASEX_ENABLE = "FALSE";
parameter EMAC0_ADDRFILTER_ENABLE = "FALSE";
parameter EMAC0_BYTEPHY = "FALSE";
parameter EMAC0_CONFIGVEC_79 = "FALSE";
parameter EMAC0_GTLOOPBACK = "FALSE";
parameter EMAC0_HOST_ENABLE = "FALSE";
parameter EMAC0_LTCHECK_DISABLE = "FALSE";
parameter EMAC0_MDIO_ENABLE = "FALSE";
parameter EMAC0_PHYINITAUTONEG_ENABLE = "FALSE";
parameter EMAC0_PHYISOLATE = "FALSE";
parameter EMAC0_PHYLOOPBACKMSB = "FALSE";
parameter EMAC0_PHYPOWERDOWN = "FALSE";
parameter EMAC0_PHYRESET = "FALSE";
parameter EMAC0_RGMII_ENABLE = "FALSE";
parameter EMAC0_RX16BITCLIENT_ENABLE = "FALSE";
parameter EMAC0_RXFLOWCTRL_ENABLE = "FALSE";
parameter EMAC0_RXHALFDUPLEX = "FALSE";
parameter EMAC0_RXINBANDFCS_ENABLE = "FALSE";
parameter EMAC0_RXJUMBOFRAME_ENABLE = "FALSE";
parameter EMAC0_RXRESET = "FALSE";
parameter EMAC0_RXVLAN_ENABLE = "FALSE";
parameter EMAC0_RX_ENABLE = "FALSE";
parameter EMAC0_SGMII_ENABLE = "FALSE";
parameter EMAC0_SPEED_LSB = "FALSE";
parameter EMAC0_SPEED_MSB = "FALSE";
parameter EMAC0_TX16BITCLIENT_ENABLE = "FALSE";
parameter EMAC0_TXFLOWCTRL_ENABLE = "FALSE";
parameter EMAC0_TXHALFDUPLEX = "FALSE";
parameter EMAC0_TXIFGADJUST_ENABLE = "FALSE";
parameter EMAC0_TXINBANDFCS_ENABLE = "FALSE";
parameter EMAC0_TXJUMBOFRAME_ENABLE = "FALSE";
parameter EMAC0_TXRESET = "FALSE";
parameter EMAC0_TXVLAN_ENABLE = "FALSE";
parameter EMAC0_TX_ENABLE = "FALSE";
parameter EMAC0_UNIDIRECTION_ENABLE = "FALSE";
parameter EMAC0_USECLKEN = "FALSE";
parameter EMAC1_1000BASEX_ENABLE = "FALSE";
parameter EMAC1_ADDRFILTER_ENABLE = "FALSE";
parameter EMAC1_BYTEPHY = "FALSE";
parameter EMAC1_CONFIGVEC_79 = "FALSE";
parameter EMAC1_GTLOOPBACK = "FALSE";
parameter EMAC1_HOST_ENABLE = "FALSE";
parameter EMAC1_LTCHECK_DISABLE = "FALSE";
parameter EMAC1_MDIO_ENABLE = "FALSE";
parameter EMAC1_PHYINITAUTONEG_ENABLE = "FALSE";
parameter EMAC1_PHYISOLATE = "FALSE";
parameter EMAC1_PHYLOOPBACKMSB = "FALSE";
parameter EMAC1_PHYPOWERDOWN = "FALSE";
parameter EMAC1_PHYRESET = "FALSE";
parameter EMAC1_RGMII_ENABLE = "FALSE";
parameter EMAC1_RX16BITCLIENT_ENABLE = "FALSE";
parameter EMAC1_RXFLOWCTRL_ENABLE = "FALSE";
parameter EMAC1_RXHALFDUPLEX = "FALSE";
parameter EMAC1_RXINBANDFCS_ENABLE = "FALSE";
parameter EMAC1_RXJUMBOFRAME_ENABLE = "FALSE";
parameter EMAC1_RXRESET = "FALSE";
parameter EMAC1_RXVLAN_ENABLE = "FALSE";
parameter EMAC1_RX_ENABLE = "FALSE";
parameter EMAC1_SGMII_ENABLE = "FALSE";
parameter EMAC1_SPEED_LSB = "FALSE";
parameter EMAC1_SPEED_MSB = "FALSE";
parameter EMAC1_TX16BITCLIENT_ENABLE = "FALSE";
parameter EMAC1_TXFLOWCTRL_ENABLE = "FALSE";
parameter EMAC1_TXHALFDUPLEX = "FALSE";
parameter EMAC1_TXIFGADJUST_ENABLE = "FALSE";
parameter EMAC1_TXINBANDFCS_ENABLE = "FALSE";
parameter EMAC1_TXJUMBOFRAME_ENABLE = "FALSE";
parameter EMAC1_TXRESET = "FALSE";
parameter EMAC1_TXVLAN_ENABLE = "FALSE";
parameter EMAC1_TX_ENABLE = "FALSE";
parameter EMAC1_UNIDIRECTION_ENABLE = "FALSE";
parameter EMAC1_USECLKEN = "FALSE";
parameter [0:7] EMAC0_DCRBASEADDR = 8'h00;
parameter [0:7] EMAC1_DCRBASEADDR = 8'h00;
parameter [47:0] EMAC0_PAUSEADDR = 48'h000000000000;
parameter [47:0] EMAC0_UNICASTADDR = 48'h000000000000;
parameter [47:0] EMAC1_PAUSEADDR = 48'h000000000000;
parameter [47:0] EMAC1_UNICASTADDR = 48'h000000000000;
parameter [8:0] EMAC0_LINKTIMERVAL = 9'h000;
parameter [8:0] EMAC1_LINKTIMERVAL = 9'h000;

localparam in_delay = 50;
localparam out_delay = 0;
localparam CLK_DELAY = 0;
// Separate MIITXCLK delays are used to allow EMAC0/1 configuration to modes other than 16-bit client
localparam EMAC0MIITXCLK_DELAY = (EMAC0_TX16BITCLIENT_ENABLE == "TRUE") ? 25 : CLK_DELAY;
localparam EMAC1MIITXCLK_DELAY = (EMAC1_TX16BITCLIENT_ENABLE == "TRUE") ? 25 : CLK_DELAY;

output DCRHOSTDONEIR;
output EMAC0CLIENTANINTERRUPT;
output EMAC0CLIENTRXBADFRAME;
output EMAC0CLIENTRXCLIENTCLKOUT;
output EMAC0CLIENTRXDVLD;
output EMAC0CLIENTRXDVLDMSW;
output EMAC0CLIENTRXFRAMEDROP;
output EMAC0CLIENTRXGOODFRAME;
output EMAC0CLIENTRXSTATSBYTEVLD;
output EMAC0CLIENTRXSTATSVLD;
output EMAC0CLIENTTXACK;
output EMAC0CLIENTTXCLIENTCLKOUT;
output EMAC0CLIENTTXCOLLISION;
output EMAC0CLIENTTXRETRANSMIT;
output EMAC0CLIENTTXSTATS;
output EMAC0CLIENTTXSTATSBYTEVLD;
output EMAC0CLIENTTXSTATSVLD;
output EMAC0PHYENCOMMAALIGN;
output EMAC0PHYLOOPBACKMSB;
output EMAC0PHYMCLKOUT;
output EMAC0PHYMDOUT;
output EMAC0PHYMDTRI;
output EMAC0PHYMGTRXRESET;
output EMAC0PHYMGTTXRESET;
output EMAC0PHYPOWERDOWN;
output EMAC0PHYSYNCACQSTATUS;
output EMAC0PHYTXCHARDISPMODE;
output EMAC0PHYTXCHARDISPVAL;
output EMAC0PHYTXCHARISK;
output EMAC0PHYTXCLK;
output EMAC0PHYTXEN;
output EMAC0PHYTXER;
output EMAC0PHYTXGMIIMIICLKOUT;
output EMAC0SPEEDIS10100;
output EMAC1CLIENTANINTERRUPT;
output EMAC1CLIENTRXBADFRAME;
output EMAC1CLIENTRXCLIENTCLKOUT;
output EMAC1CLIENTRXDVLD;
output EMAC1CLIENTRXDVLDMSW;
output EMAC1CLIENTRXFRAMEDROP;
output EMAC1CLIENTRXGOODFRAME;
output EMAC1CLIENTRXSTATSBYTEVLD;
output EMAC1CLIENTRXSTATSVLD;
output EMAC1CLIENTTXACK;
output EMAC1CLIENTTXCLIENTCLKOUT;
output EMAC1CLIENTTXCOLLISION;
output EMAC1CLIENTTXRETRANSMIT;
output EMAC1CLIENTTXSTATS;
output EMAC1CLIENTTXSTATSBYTEVLD;
output EMAC1CLIENTTXSTATSVLD;
output EMAC1PHYENCOMMAALIGN;
output EMAC1PHYLOOPBACKMSB;
output EMAC1PHYMCLKOUT;
output EMAC1PHYMDOUT;
output EMAC1PHYMDTRI;
output EMAC1PHYMGTRXRESET;
output EMAC1PHYMGTTXRESET;
output EMAC1PHYPOWERDOWN;
output EMAC1PHYSYNCACQSTATUS;
output EMAC1PHYTXCHARDISPMODE;
output EMAC1PHYTXCHARDISPVAL;
output EMAC1PHYTXCHARISK;
output EMAC1PHYTXCLK;
output EMAC1PHYTXEN;
output EMAC1PHYTXER;
output EMAC1PHYTXGMIIMIICLKOUT;
output EMAC1SPEEDIS10100;
output EMACDCRACK;
output HOSTMIIMRDY;
output [0:31] EMACDCRDBUS;
output [15:0] EMAC0CLIENTRXD;
output [15:0] EMAC1CLIENTRXD;
output [31:0] HOSTRDDATA;
output [6:0] EMAC0CLIENTRXSTATS;
output [6:0] EMAC1CLIENTRXSTATS;
output [7:0] EMAC0PHYTXD;
output [7:0] EMAC1PHYTXD;

input CLIENTEMAC0DCMLOCKED;
input CLIENTEMAC0PAUSEREQ;
input CLIENTEMAC0RXCLIENTCLKIN;
input CLIENTEMAC0TXCLIENTCLKIN;
input CLIENTEMAC0TXDVLD;
input CLIENTEMAC0TXDVLDMSW;
input CLIENTEMAC0TXFIRSTBYTE;
input CLIENTEMAC0TXUNDERRUN;
input CLIENTEMAC1DCMLOCKED;
input CLIENTEMAC1PAUSEREQ;
input CLIENTEMAC1RXCLIENTCLKIN;
input CLIENTEMAC1TXCLIENTCLKIN;
input CLIENTEMAC1TXDVLD;
input CLIENTEMAC1TXDVLDMSW;
input CLIENTEMAC1TXFIRSTBYTE;
input CLIENTEMAC1TXUNDERRUN;
input DCREMACCLK;
input DCREMACENABLE;
input DCREMACREAD;
input DCREMACWRITE;
input HOSTCLK;
input HOSTEMAC1SEL;
input HOSTMIIMSEL;
input HOSTREQ;
input PHYEMAC0COL;
input PHYEMAC0CRS;
input PHYEMAC0GTXCLK;
input PHYEMAC0MCLKIN;
input PHYEMAC0MDIN;
input PHYEMAC0MIITXCLK;
input PHYEMAC0RXBUFERR;
input PHYEMAC0RXCHARISCOMMA;
input PHYEMAC0RXCHARISK;
input PHYEMAC0RXCHECKINGCRC;
input PHYEMAC0RXCLK;
input PHYEMAC0RXCOMMADET;
input PHYEMAC0RXDISPERR;
input PHYEMAC0RXDV;
input PHYEMAC0RXER;
input PHYEMAC0RXNOTINTABLE;
input PHYEMAC0RXRUNDISP;
input PHYEMAC0SIGNALDET;
input PHYEMAC0TXBUFERR;
input PHYEMAC0TXGMIIMIICLKIN;
input PHYEMAC1COL;
input PHYEMAC1CRS;
input PHYEMAC1GTXCLK;
input PHYEMAC1MCLKIN;
input PHYEMAC1MDIN;
input PHYEMAC1MIITXCLK;
input PHYEMAC1RXBUFERR;
input PHYEMAC1RXCHARISCOMMA;
input PHYEMAC1RXCHARISK;
input PHYEMAC1RXCHECKINGCRC;
input PHYEMAC1RXCLK;
input PHYEMAC1RXCOMMADET;
input PHYEMAC1RXDISPERR;
input PHYEMAC1RXDV;
input PHYEMAC1RXER;
input PHYEMAC1RXNOTINTABLE;
input PHYEMAC1RXRUNDISP;
input PHYEMAC1SIGNALDET;
input PHYEMAC1TXBUFERR;
input PHYEMAC1TXGMIIMIICLKIN;
input RESET;
input [0:31] DCREMACDBUS;
input [0:9] DCREMACABUS;
input [15:0] CLIENTEMAC0PAUSEVAL;
input [15:0] CLIENTEMAC0TXD;
input [15:0] CLIENTEMAC1PAUSEVAL;
input [15:0] CLIENTEMAC1TXD;
input [1:0] HOSTOPCODE;
input [1:0] PHYEMAC0RXBUFSTATUS;
input [1:0] PHYEMAC0RXLOSSOFSYNC;
input [1:0] PHYEMAC1RXBUFSTATUS;
input [1:0] PHYEMAC1RXLOSSOFSYNC;
input [2:0] PHYEMAC0RXCLKCORCNT;
input [2:0] PHYEMAC1RXCLKCORCNT;
input [31:0] HOSTWRDATA;
input [4:0] PHYEMAC0PHYAD;
input [4:0] PHYEMAC1PHYAD;
input [7:0] CLIENTEMAC0TXIFGDELAY;
input [7:0] CLIENTEMAC1TXIFGDELAY;
input [7:0] PHYEMAC0RXD;
input [7:0] PHYEMAC1RXD;
input [9:0] HOSTADDR;

reg EMAC0_1000BASEX_ENABLE_BINARY;
reg EMAC0_ADDRFILTER_ENABLE_BINARY;
reg EMAC0_BYTEPHY_BINARY;
reg EMAC0_CONFIGVEC_79_BINARY;
reg EMAC0_GTLOOPBACK_BINARY;
reg EMAC0_HOST_ENABLE_BINARY;
reg EMAC0_LTCHECK_DISABLE_BINARY;
reg EMAC0_MDIO_ENABLE_BINARY;
reg EMAC0_PHYINITAUTONEG_ENABLE_BINARY;
reg EMAC0_PHYISOLATE_BINARY;
reg EMAC0_PHYLOOPBACKMSB_BINARY;
reg EMAC0_PHYPOWERDOWN_BINARY;
reg EMAC0_PHYRESET_BINARY;
reg EMAC0_RGMII_ENABLE_BINARY;
reg EMAC0_RX16BITCLIENT_ENABLE_BINARY;
reg EMAC0_RXFLOWCTRL_ENABLE_BINARY;
reg EMAC0_RXHALFDUPLEX_BINARY;
reg EMAC0_RXINBANDFCS_ENABLE_BINARY;
reg EMAC0_RXJUMBOFRAME_ENABLE_BINARY;
reg EMAC0_RXRESET_BINARY;
reg EMAC0_RXVLAN_ENABLE_BINARY;
reg EMAC0_RX_ENABLE_BINARY;
reg EMAC0_SGMII_ENABLE_BINARY;
reg EMAC0_SPEED_LSB_BINARY;
reg EMAC0_SPEED_MSB_BINARY;
reg EMAC0_TX16BITCLIENT_ENABLE_BINARY;
reg EMAC0_TXFLOWCTRL_ENABLE_BINARY;
reg EMAC0_TXHALFDUPLEX_BINARY;
reg EMAC0_TXIFGADJUST_ENABLE_BINARY;
reg EMAC0_TXINBANDFCS_ENABLE_BINARY;
reg EMAC0_TXJUMBOFRAME_ENABLE_BINARY;
reg EMAC0_TXRESET_BINARY;
reg EMAC0_TXVLAN_ENABLE_BINARY;
reg EMAC0_TX_ENABLE_BINARY;
reg EMAC0_UNIDIRECTION_ENABLE_BINARY;
reg EMAC0_USECLKEN_BINARY;
reg EMAC1_1000BASEX_ENABLE_BINARY;
reg EMAC1_ADDRFILTER_ENABLE_BINARY;
reg EMAC1_BYTEPHY_BINARY;
reg EMAC1_CONFIGVEC_79_BINARY;
reg EMAC1_GTLOOPBACK_BINARY;
reg EMAC1_HOST_ENABLE_BINARY;
reg EMAC1_LTCHECK_DISABLE_BINARY;
reg EMAC1_MDIO_ENABLE_BINARY;
reg EMAC1_PHYINITAUTONEG_ENABLE_BINARY;
reg EMAC1_PHYISOLATE_BINARY;
reg EMAC1_PHYLOOPBACKMSB_BINARY;
reg EMAC1_PHYPOWERDOWN_BINARY;
reg EMAC1_PHYRESET_BINARY;
reg EMAC1_RGMII_ENABLE_BINARY;
reg EMAC1_RX16BITCLIENT_ENABLE_BINARY;
reg EMAC1_RXFLOWCTRL_ENABLE_BINARY;
reg EMAC1_RXHALFDUPLEX_BINARY;
reg EMAC1_RXINBANDFCS_ENABLE_BINARY;
reg EMAC1_RXJUMBOFRAME_ENABLE_BINARY;
reg EMAC1_RXRESET_BINARY;
reg EMAC1_RXVLAN_ENABLE_BINARY;
reg EMAC1_RX_ENABLE_BINARY;
reg EMAC1_SGMII_ENABLE_BINARY;
reg EMAC1_SPEED_LSB_BINARY;
reg EMAC1_SPEED_MSB_BINARY;
reg EMAC1_TX16BITCLIENT_ENABLE_BINARY;
reg EMAC1_TXFLOWCTRL_ENABLE_BINARY;
reg EMAC1_TXHALFDUPLEX_BINARY;
reg EMAC1_TXIFGADJUST_ENABLE_BINARY;
reg EMAC1_TXINBANDFCS_ENABLE_BINARY;
reg EMAC1_TXJUMBOFRAME_ENABLE_BINARY;
reg EMAC1_TXRESET_BINARY;
reg EMAC1_TXVLAN_ENABLE_BINARY;
reg EMAC1_TX_ENABLE_BINARY;
reg EMAC1_UNIDIRECTION_ENABLE_BINARY;
reg EMAC1_USECLKEN_BINARY;

initial begin
	case (EMAC0_RXHALFDUPLEX)
		"FALSE" : EMAC0_RXHALFDUPLEX_BINARY = 1'b0;
		"TRUE" : EMAC0_RXHALFDUPLEX_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_RXHALFDUPLEX on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_RXHALFDUPLEX);
			$finish;
		end
	endcase

	case (EMAC0_RXVLAN_ENABLE)
		"FALSE" : EMAC0_RXVLAN_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_RXVLAN_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_RXVLAN_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_RXVLAN_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_RX_ENABLE)
		"FALSE" : EMAC0_RX_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_RX_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_RX_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_RX_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_RXINBANDFCS_ENABLE)
		"FALSE" : EMAC0_RXINBANDFCS_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_RXINBANDFCS_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_RXINBANDFCS_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_RXINBANDFCS_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_RXJUMBOFRAME_ENABLE)
		"FALSE" : EMAC0_RXJUMBOFRAME_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_RXJUMBOFRAME_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_RXJUMBOFRAME_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_RXJUMBOFRAME_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_RXRESET)
		"FALSE" : EMAC0_RXRESET_BINARY = 1'b0;
		"TRUE" : EMAC0_RXRESET_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_RXRESET on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_RXRESET);
			$finish;
		end
	endcase

	case (EMAC0_TXIFGADJUST_ENABLE)
		"FALSE" : EMAC0_TXIFGADJUST_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_TXIFGADJUST_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_TXIFGADJUST_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_TXIFGADJUST_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_TXHALFDUPLEX)
		"FALSE" : EMAC0_TXHALFDUPLEX_BINARY = 1'b0;
		"TRUE" : EMAC0_TXHALFDUPLEX_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_TXHALFDUPLEX on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_TXHALFDUPLEX);
			$finish;
		end
	endcase

	case (EMAC0_TXVLAN_ENABLE)
		"FALSE" : EMAC0_TXVLAN_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_TXVLAN_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_TXVLAN_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_TXVLAN_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_TX_ENABLE)
		"FALSE" : EMAC0_TX_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_TX_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_TX_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_TX_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_TXINBANDFCS_ENABLE)
		"FALSE" : EMAC0_TXINBANDFCS_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_TXINBANDFCS_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_TXINBANDFCS_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_TXINBANDFCS_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_TXJUMBOFRAME_ENABLE)
		"FALSE" : EMAC0_TXJUMBOFRAME_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_TXJUMBOFRAME_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_TXJUMBOFRAME_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_TXJUMBOFRAME_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_TXRESET)
		"FALSE" : EMAC0_TXRESET_BINARY = 1'b0;
		"TRUE" : EMAC0_TXRESET_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_TXRESET on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_TXRESET);
			$finish;
		end
	endcase

	case (EMAC0_TXFLOWCTRL_ENABLE)
		"FALSE" : EMAC0_TXFLOWCTRL_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_TXFLOWCTRL_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_TXFLOWCTRL_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_TXFLOWCTRL_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_RXFLOWCTRL_ENABLE)
		"FALSE" : EMAC0_RXFLOWCTRL_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_RXFLOWCTRL_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_RXFLOWCTRL_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_RXFLOWCTRL_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_LTCHECK_DISABLE)
		"FALSE" : EMAC0_LTCHECK_DISABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_LTCHECK_DISABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_LTCHECK_DISABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_LTCHECK_DISABLE);
			$finish;
		end
	endcase

	case (EMAC0_ADDRFILTER_ENABLE)
		"FALSE" : EMAC0_ADDRFILTER_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_ADDRFILTER_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_ADDRFILTER_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_ADDRFILTER_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_RX16BITCLIENT_ENABLE)
		"FALSE" : EMAC0_RX16BITCLIENT_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_RX16BITCLIENT_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_RX16BITCLIENT_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_RX16BITCLIENT_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_TX16BITCLIENT_ENABLE)
		"FALSE" : EMAC0_TX16BITCLIENT_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_TX16BITCLIENT_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_TX16BITCLIENT_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_TX16BITCLIENT_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_HOST_ENABLE)
		"FALSE" : EMAC0_HOST_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_HOST_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_HOST_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_HOST_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_1000BASEX_ENABLE)
		"FALSE" : EMAC0_1000BASEX_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_1000BASEX_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_1000BASEX_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_1000BASEX_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_SGMII_ENABLE)
		"FALSE" : EMAC0_SGMII_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_SGMII_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_SGMII_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_SGMII_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_RGMII_ENABLE)
		"FALSE" : EMAC0_RGMII_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_RGMII_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_RGMII_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_RGMII_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_SPEED_LSB)
		"FALSE" : EMAC0_SPEED_LSB_BINARY = 1'b0;
		"TRUE" : EMAC0_SPEED_LSB_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_SPEED_LSB on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_SPEED_LSB);
			$finish;
		end
	endcase

	case (EMAC0_SPEED_MSB)
		"FALSE" : EMAC0_SPEED_MSB_BINARY = 1'b0;
		"TRUE" : EMAC0_SPEED_MSB_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_SPEED_MSB on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_SPEED_MSB);
			$finish;
		end
	endcase

	case (EMAC0_MDIO_ENABLE)
		"FALSE" : EMAC0_MDIO_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_MDIO_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_MDIO_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_MDIO_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_PHYLOOPBACKMSB)
		"FALSE" : EMAC0_PHYLOOPBACKMSB_BINARY = 1'b0;
		"TRUE" : EMAC0_PHYLOOPBACKMSB_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_PHYLOOPBACKMSB on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_PHYLOOPBACKMSB);
			$finish;
		end
	endcase

	case (EMAC0_PHYPOWERDOWN)
		"FALSE" : EMAC0_PHYPOWERDOWN_BINARY = 1'b0;
		"TRUE" : EMAC0_PHYPOWERDOWN_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_PHYPOWERDOWN on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_PHYPOWERDOWN);
			$finish;
		end
	endcase

	case (EMAC0_PHYISOLATE)
		"FALSE" : EMAC0_PHYISOLATE_BINARY = 1'b0;
		"TRUE" : EMAC0_PHYISOLATE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_PHYISOLATE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_PHYISOLATE);
			$finish;
		end
	endcase

	case (EMAC0_PHYINITAUTONEG_ENABLE)
		"FALSE" : EMAC0_PHYINITAUTONEG_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_PHYINITAUTONEG_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_PHYINITAUTONEG_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_PHYINITAUTONEG_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_PHYRESET)
		"FALSE" : EMAC0_PHYRESET_BINARY = 1'b0;
		"TRUE" : EMAC0_PHYRESET_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_PHYRESET on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_PHYRESET);
			$finish;
		end
	endcase

	case (EMAC0_CONFIGVEC_79)
		"FALSE" : EMAC0_CONFIGVEC_79_BINARY = 1'b0;
		"TRUE" : EMAC0_CONFIGVEC_79_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_CONFIGVEC_79 on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_CONFIGVEC_79);
			$finish;
		end
	endcase

	case (EMAC0_UNIDIRECTION_ENABLE)
		"FALSE" : EMAC0_UNIDIRECTION_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC0_UNIDIRECTION_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_UNIDIRECTION_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_UNIDIRECTION_ENABLE);
			$finish;
		end
	endcase

	case (EMAC0_GTLOOPBACK)
		"FALSE" : EMAC0_GTLOOPBACK_BINARY = 1'b0;
		"TRUE" : EMAC0_GTLOOPBACK_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_GTLOOPBACK on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_GTLOOPBACK);
			$finish;
		end
	endcase

	case (EMAC0_BYTEPHY)
		"FALSE" : EMAC0_BYTEPHY_BINARY = 1'b0;
		"TRUE" : EMAC0_BYTEPHY_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_BYTEPHY on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_BYTEPHY);
			$finish;
		end
	endcase

	case (EMAC0_USECLKEN)
		"FALSE" : EMAC0_USECLKEN_BINARY = 1'b0;
		"TRUE" : EMAC0_USECLKEN_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC0_USECLKEN on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC0_USECLKEN);
			$finish;
		end
	endcase

	case (EMAC1_RXHALFDUPLEX)
		"FALSE" : EMAC1_RXHALFDUPLEX_BINARY = 1'b0;
		"TRUE" : EMAC1_RXHALFDUPLEX_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_RXHALFDUPLEX on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_RXHALFDUPLEX);
			$finish;
		end
	endcase

	case (EMAC1_RXVLAN_ENABLE)
		"FALSE" : EMAC1_RXVLAN_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_RXVLAN_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_RXVLAN_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_RXVLAN_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_RX_ENABLE)
		"FALSE" : EMAC1_RX_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_RX_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_RX_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_RX_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_RXINBANDFCS_ENABLE)
		"FALSE" : EMAC1_RXINBANDFCS_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_RXINBANDFCS_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_RXINBANDFCS_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_RXINBANDFCS_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_RXJUMBOFRAME_ENABLE)
		"FALSE" : EMAC1_RXJUMBOFRAME_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_RXJUMBOFRAME_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_RXJUMBOFRAME_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_RXJUMBOFRAME_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_RXRESET)
		"FALSE" : EMAC1_RXRESET_BINARY = 1'b0;
		"TRUE" : EMAC1_RXRESET_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_RXRESET on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_RXRESET);
			$finish;
		end
	endcase

	case (EMAC1_TXIFGADJUST_ENABLE)
		"FALSE" : EMAC1_TXIFGADJUST_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_TXIFGADJUST_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_TXIFGADJUST_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_TXIFGADJUST_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_TXHALFDUPLEX)
		"FALSE" : EMAC1_TXHALFDUPLEX_BINARY = 1'b0;
		"TRUE" : EMAC1_TXHALFDUPLEX_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_TXHALFDUPLEX on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_TXHALFDUPLEX);
			$finish;
		end
	endcase

	case (EMAC1_TXVLAN_ENABLE)
		"FALSE" : EMAC1_TXVLAN_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_TXVLAN_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_TXVLAN_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_TXVLAN_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_TX_ENABLE)
		"FALSE" : EMAC1_TX_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_TX_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_TX_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_TX_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_TXINBANDFCS_ENABLE)
		"FALSE" : EMAC1_TXINBANDFCS_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_TXINBANDFCS_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_TXINBANDFCS_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_TXINBANDFCS_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_TXJUMBOFRAME_ENABLE)
		"FALSE" : EMAC1_TXJUMBOFRAME_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_TXJUMBOFRAME_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_TXJUMBOFRAME_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_TXJUMBOFRAME_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_TXRESET)
		"FALSE" : EMAC1_TXRESET_BINARY = 1'b0;
		"TRUE" : EMAC1_TXRESET_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_TXRESET on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_TXRESET);
			$finish;
		end
	endcase

	case (EMAC1_TXFLOWCTRL_ENABLE)
		"FALSE" : EMAC1_TXFLOWCTRL_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_TXFLOWCTRL_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_TXFLOWCTRL_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_TXFLOWCTRL_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_RXFLOWCTRL_ENABLE)
		"FALSE" : EMAC1_RXFLOWCTRL_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_RXFLOWCTRL_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_RXFLOWCTRL_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_RXFLOWCTRL_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_LTCHECK_DISABLE)
		"FALSE" : EMAC1_LTCHECK_DISABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_LTCHECK_DISABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_LTCHECK_DISABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_LTCHECK_DISABLE);
			$finish;
		end
	endcase

	case (EMAC1_ADDRFILTER_ENABLE)
		"FALSE" : EMAC1_ADDRFILTER_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_ADDRFILTER_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_ADDRFILTER_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_ADDRFILTER_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_RX16BITCLIENT_ENABLE)
		"FALSE" : EMAC1_RX16BITCLIENT_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_RX16BITCLIENT_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_RX16BITCLIENT_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_RX16BITCLIENT_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_TX16BITCLIENT_ENABLE)
		"FALSE" : EMAC1_TX16BITCLIENT_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_TX16BITCLIENT_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_TX16BITCLIENT_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_TX16BITCLIENT_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_HOST_ENABLE)
		"FALSE" : EMAC1_HOST_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_HOST_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_HOST_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_HOST_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_1000BASEX_ENABLE)
		"FALSE" : EMAC1_1000BASEX_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_1000BASEX_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_1000BASEX_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_1000BASEX_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_SGMII_ENABLE)
		"FALSE" : EMAC1_SGMII_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_SGMII_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_SGMII_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_SGMII_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_RGMII_ENABLE)
		"FALSE" : EMAC1_RGMII_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_RGMII_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_RGMII_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_RGMII_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_SPEED_LSB)
		"FALSE" : EMAC1_SPEED_LSB_BINARY = 1'b0;
		"TRUE" : EMAC1_SPEED_LSB_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_SPEED_LSB on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_SPEED_LSB);
			$finish;
		end
	endcase

	case (EMAC1_SPEED_MSB)
		"FALSE" : EMAC1_SPEED_MSB_BINARY = 1'b0;
		"TRUE" : EMAC1_SPEED_MSB_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_SPEED_MSB on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_SPEED_MSB);
			$finish;
		end
	endcase

	case (EMAC1_MDIO_ENABLE)
		"FALSE" : EMAC1_MDIO_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_MDIO_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_MDIO_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_MDIO_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_PHYLOOPBACKMSB)
		"FALSE" : EMAC1_PHYLOOPBACKMSB_BINARY = 1'b0;
		"TRUE" : EMAC1_PHYLOOPBACKMSB_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_PHYLOOPBACKMSB on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_PHYLOOPBACKMSB);
			$finish;
		end
	endcase

	case (EMAC1_PHYPOWERDOWN)
		"FALSE" : EMAC1_PHYPOWERDOWN_BINARY = 1'b0;
		"TRUE" : EMAC1_PHYPOWERDOWN_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_PHYPOWERDOWN on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_PHYPOWERDOWN);
			$finish;
		end
	endcase

	case (EMAC1_PHYISOLATE)
		"FALSE" : EMAC1_PHYISOLATE_BINARY = 1'b0;
		"TRUE" : EMAC1_PHYISOLATE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_PHYISOLATE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_PHYISOLATE);
			$finish;
		end
	endcase

	case (EMAC1_PHYINITAUTONEG_ENABLE)
		"FALSE" : EMAC1_PHYINITAUTONEG_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_PHYINITAUTONEG_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_PHYINITAUTONEG_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_PHYINITAUTONEG_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_PHYRESET)
		"FALSE" : EMAC1_PHYRESET_BINARY = 1'b0;
		"TRUE" : EMAC1_PHYRESET_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_PHYRESET on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_PHYRESET);
			$finish;
		end
	endcase

	case (EMAC1_CONFIGVEC_79)
		"FALSE" : EMAC1_CONFIGVEC_79_BINARY = 1'b0;
		"TRUE" : EMAC1_CONFIGVEC_79_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_CONFIGVEC_79 on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_CONFIGVEC_79);
			$finish;
		end
	endcase

	case (EMAC1_UNIDIRECTION_ENABLE)
		"FALSE" : EMAC1_UNIDIRECTION_ENABLE_BINARY = 1'b0;
		"TRUE" : EMAC1_UNIDIRECTION_ENABLE_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_UNIDIRECTION_ENABLE on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_UNIDIRECTION_ENABLE);
			$finish;
		end
	endcase

	case (EMAC1_GTLOOPBACK)
		"FALSE" : EMAC1_GTLOOPBACK_BINARY = 1'b0;
		"TRUE" : EMAC1_GTLOOPBACK_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_GTLOOPBACK on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_GTLOOPBACK);
			$finish;
		end
	endcase

	case (EMAC1_BYTEPHY)
		"FALSE" : EMAC1_BYTEPHY_BINARY = 1'b0;
		"TRUE" : EMAC1_BYTEPHY_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_BYTEPHY on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_BYTEPHY);
			$finish;
		end
	endcase

	case (EMAC1_USECLKEN)
		"FALSE" : EMAC1_USECLKEN_BINARY = 1'b0;
		"TRUE" : EMAC1_USECLKEN_BINARY = 1'b1;
		default : begin
			$display("Attribute Syntax Error : The Attribute EMAC1_USECLKEN on TEMAC instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC1_USECLKEN);
			$finish;
		end
	endcase

end

wire DCRHOSTDONEIR_delay;
wire EMAC0CLIENTANINTERRUPT_delay;
wire EMAC0CLIENTRXBADFRAME_delay;
wire EMAC0CLIENTRXCLIENTCLKOUT_delay;
wire EMAC0CLIENTRXDVLDMSW_delay;
wire EMAC0CLIENTRXDVLD_delay;
wire EMAC0CLIENTRXFRAMEDROP_delay;
wire EMAC0CLIENTRXGOODFRAME_delay;
wire EMAC0CLIENTRXSTATSBYTEVLD_delay;
wire EMAC0CLIENTRXSTATSVLD_delay;
wire EMAC0CLIENTTXACK_delay;
wire EMAC0CLIENTTXCLIENTCLKOUT_delay;
wire EMAC0CLIENTTXCOLLISION_delay;
wire EMAC0CLIENTTXRETRANSMIT_delay;
wire EMAC0CLIENTTXSTATSBYTEVLD_delay;
wire EMAC0CLIENTTXSTATSVLD_delay;
wire EMAC0CLIENTTXSTATS_delay;
wire EMAC0PHYENCOMMAALIGN_delay;
wire EMAC0PHYLOOPBACKMSB_delay;
wire EMAC0PHYMCLKOUT_delay;
wire EMAC0PHYMDOUT_delay;
wire EMAC0PHYMDTRI_delay;
wire EMAC0PHYMGTRXRESET_delay;
wire EMAC0PHYMGTTXRESET_delay;
wire EMAC0PHYPOWERDOWN_delay;
wire EMAC0PHYSYNCACQSTATUS_delay;
wire EMAC0PHYTXCHARDISPMODE_delay;
wire EMAC0PHYTXCHARDISPVAL_delay;
wire EMAC0PHYTXCHARISK_delay;
wire EMAC0PHYTXCLK_delay;
wire EMAC0PHYTXEN_delay;
wire EMAC0PHYTXER_delay;
wire EMAC0PHYTXGMIIMIICLKOUT_delay;
wire EMAC0SPEEDIS10100_delay;
wire EMAC1CLIENTANINTERRUPT_delay;
wire EMAC1CLIENTRXBADFRAME_delay;
wire EMAC1CLIENTRXCLIENTCLKOUT_delay;
wire EMAC1CLIENTRXDVLDMSW_delay;
wire EMAC1CLIENTRXDVLD_delay;
wire EMAC1CLIENTRXFRAMEDROP_delay;
wire EMAC1CLIENTRXGOODFRAME_delay;
wire EMAC1CLIENTRXSTATSBYTEVLD_delay;
wire EMAC1CLIENTRXSTATSVLD_delay;
wire EMAC1CLIENTTXACK_delay;
wire EMAC1CLIENTTXCLIENTCLKOUT_delay;
wire EMAC1CLIENTTXCOLLISION_delay;
wire EMAC1CLIENTTXRETRANSMIT_delay;
wire EMAC1CLIENTTXSTATSBYTEVLD_delay;
wire EMAC1CLIENTTXSTATSVLD_delay;
wire EMAC1CLIENTTXSTATS_delay;
wire EMAC1PHYENCOMMAALIGN_delay;
wire EMAC1PHYLOOPBACKMSB_delay;
wire EMAC1PHYMCLKOUT_delay;
wire EMAC1PHYMDOUT_delay;
wire EMAC1PHYMDTRI_delay;
wire EMAC1PHYMGTRXRESET_delay;
wire EMAC1PHYMGTTXRESET_delay;
wire EMAC1PHYPOWERDOWN_delay;
wire EMAC1PHYSYNCACQSTATUS_delay;
wire EMAC1PHYTXCHARDISPMODE_delay;
wire EMAC1PHYTXCHARDISPVAL_delay;
wire EMAC1PHYTXCHARISK_delay;
wire EMAC1PHYTXCLK_delay;
wire EMAC1PHYTXEN_delay;
wire EMAC1PHYTXER_delay;
wire EMAC1PHYTXGMIIMIICLKOUT_delay;
wire EMAC1SPEEDIS10100_delay;
wire EMACDCRACK_delay;
wire HOSTMIIMRDY_delay;
wire [0:31] EMACDCRDBUS_delay;
wire [15:0] EMAC0CLIENTRXD_delay;
wire [15:0] EMAC1CLIENTRXD_delay;
wire [31:0] HOSTRDDATA_delay;
wire [6:0] EMAC0CLIENTRXSTATS_delay;
wire [6:0] EMAC1CLIENTRXSTATS_delay;
wire [7:0] EMAC0PHYTXD_delay;
wire [7:0] EMAC1PHYTXD_delay;

wire CLIENTEMAC0DCMLOCKED_delay;
wire CLIENTEMAC0PAUSEREQ_delay;
wire CLIENTEMAC0RXCLIENTCLKIN_delay;
wire CLIENTEMAC0TXCLIENTCLKIN_delay;
wire CLIENTEMAC0TXDVLDMSW_delay;
wire CLIENTEMAC0TXDVLD_delay;
wire CLIENTEMAC0TXFIRSTBYTE_delay;
wire CLIENTEMAC0TXUNDERRUN_delay;
wire CLIENTEMAC1DCMLOCKED_delay;
wire CLIENTEMAC1PAUSEREQ_delay;
wire CLIENTEMAC1RXCLIENTCLKIN_delay;
wire CLIENTEMAC1TXCLIENTCLKIN_delay;
wire CLIENTEMAC1TXDVLDMSW_delay;
wire CLIENTEMAC1TXDVLD_delay;
wire CLIENTEMAC1TXFIRSTBYTE_delay;
wire CLIENTEMAC1TXUNDERRUN_delay;
wire DCREMACCLK_delay;
wire DCREMACENABLE_delay;
wire DCREMACREAD_delay;
wire DCREMACWRITE_delay;
wire HOSTCLK_delay;
wire HOSTEMAC1SEL_delay;
wire HOSTMIIMSEL_delay;
wire HOSTREQ_delay;
wire PHYEMAC0COL_delay;
wire PHYEMAC0CRS_delay;
wire PHYEMAC0GTXCLK_delay;
wire PHYEMAC0MCLKIN_delay;
wire PHYEMAC0MDIN_delay;
wire PHYEMAC0MIITXCLK_delay;
wire PHYEMAC0RXBUFERR_delay;
wire PHYEMAC0RXCHARISCOMMA_delay;
wire PHYEMAC0RXCHARISK_delay;
wire PHYEMAC0RXCHECKINGCRC_delay;
wire PHYEMAC0RXCLK_delay;
wire PHYEMAC0RXCOMMADET_delay;
wire PHYEMAC0RXDISPERR_delay;
wire PHYEMAC0RXDV_delay;
wire PHYEMAC0RXER_delay;
wire PHYEMAC0RXNOTINTABLE_delay;
wire PHYEMAC0RXRUNDISP_delay;
wire PHYEMAC0SIGNALDET_delay;
wire PHYEMAC0TXBUFERR_delay;
wire PHYEMAC0TXGMIIMIICLKIN_delay;
wire PHYEMAC1COL_delay;
wire PHYEMAC1CRS_delay;
wire PHYEMAC1GTXCLK_delay;
wire PHYEMAC1MCLKIN_delay;
wire PHYEMAC1MDIN_delay;
wire PHYEMAC1MIITXCLK_delay;
wire PHYEMAC1RXBUFERR_delay;
wire PHYEMAC1RXCHARISCOMMA_delay;
wire PHYEMAC1RXCHARISK_delay;
wire PHYEMAC1RXCHECKINGCRC_delay;
wire PHYEMAC1RXCLK_delay;
wire PHYEMAC1RXCOMMADET_delay;
wire PHYEMAC1RXDISPERR_delay;
wire PHYEMAC1RXDV_delay;
wire PHYEMAC1RXER_delay;
wire PHYEMAC1RXNOTINTABLE_delay;
wire PHYEMAC1RXRUNDISP_delay;
wire PHYEMAC1SIGNALDET_delay;
wire PHYEMAC1TXBUFERR_delay;
wire PHYEMAC1TXGMIIMIICLKIN_delay;
wire RESET_delay;
wire [0:31] DCREMACDBUS_delay;
wire [0:9] DCREMACABUS_delay;
wire [15:0] CLIENTEMAC0PAUSEVAL_delay;
wire [15:0] CLIENTEMAC0TXD_delay;
wire [15:0] CLIENTEMAC1PAUSEVAL_delay;
wire [15:0] CLIENTEMAC1TXD_delay;
wire [1:0] HOSTOPCODE_delay;
wire [1:0] PHYEMAC0RXBUFSTATUS_delay;
wire [1:0] PHYEMAC0RXLOSSOFSYNC_delay;
wire [1:0] PHYEMAC1RXBUFSTATUS_delay;
wire [1:0] PHYEMAC1RXLOSSOFSYNC_delay;
wire [2:0] PHYEMAC0RXCLKCORCNT_delay;
wire [2:0] PHYEMAC1RXCLKCORCNT_delay;
wire [31:0] HOSTWRDATA_delay;
wire [4:0] PHYEMAC0PHYAD_delay;
wire [4:0] PHYEMAC1PHYAD_delay;
wire [7:0] CLIENTEMAC0TXIFGDELAY_delay;
wire [7:0] CLIENTEMAC1TXIFGDELAY_delay;
wire [7:0] PHYEMAC0RXD_delay;
wire [7:0] PHYEMAC1RXD_delay;
wire [9:0] HOSTADDR_delay;

assign #(CLK_DELAY) EMAC0CLIENTRXCLIENTCLKOUT = EMAC0CLIENTRXCLIENTCLKOUT_delay;
assign #(CLK_DELAY) EMAC0CLIENTTXCLIENTCLKOUT = EMAC0CLIENTTXCLIENTCLKOUT_delay;
assign #(CLK_DELAY) EMAC0PHYMCLKOUT = EMAC0PHYMCLKOUT_delay;
assign #(CLK_DELAY) EMAC0PHYTXCLK = EMAC0PHYTXCLK_delay;
assign #(CLK_DELAY) EMAC0PHYTXGMIIMIICLKOUT = EMAC0PHYTXGMIIMIICLKOUT_delay;
assign #(CLK_DELAY) EMAC1CLIENTRXCLIENTCLKOUT = EMAC1CLIENTRXCLIENTCLKOUT_delay;
assign #(CLK_DELAY) EMAC1CLIENTTXCLIENTCLKOUT = EMAC1CLIENTTXCLIENTCLKOUT_delay;
assign #(CLK_DELAY) EMAC1PHYMCLKOUT = EMAC1PHYMCLKOUT_delay;
assign #(CLK_DELAY) EMAC1PHYTXCLK = EMAC1PHYTXCLK_delay;
assign #(CLK_DELAY) EMAC1PHYTXGMIIMIICLKOUT = EMAC1PHYTXGMIIMIICLKOUT_delay;

assign #(out_delay) DCRHOSTDONEIR = DCRHOSTDONEIR_delay;
assign #(out_delay) EMAC0CLIENTANINTERRUPT = EMAC0CLIENTANINTERRUPT_delay;
assign #(out_delay) EMAC0CLIENTRXBADFRAME = EMAC0CLIENTRXBADFRAME_delay;
assign #(out_delay) EMAC0CLIENTRXD = EMAC0CLIENTRXD_delay;
assign #(out_delay) EMAC0CLIENTRXDVLD = EMAC0CLIENTRXDVLD_delay;
assign #(out_delay) EMAC0CLIENTRXDVLDMSW = EMAC0CLIENTRXDVLDMSW_delay;
assign #(out_delay) EMAC0CLIENTRXFRAMEDROP = EMAC0CLIENTRXFRAMEDROP_delay;
assign #(out_delay) EMAC0CLIENTRXGOODFRAME = EMAC0CLIENTRXGOODFRAME_delay;
assign #(out_delay) EMAC0CLIENTRXSTATS = EMAC0CLIENTRXSTATS_delay;
assign #(out_delay) EMAC0CLIENTRXSTATSBYTEVLD = EMAC0CLIENTRXSTATSBYTEVLD_delay;
assign #(out_delay) EMAC0CLIENTRXSTATSVLD = EMAC0CLIENTRXSTATSVLD_delay;
assign #(out_delay) EMAC0CLIENTTXACK = EMAC0CLIENTTXACK_delay;
assign #(out_delay) EMAC0CLIENTTXCOLLISION = EMAC0CLIENTTXCOLLISION_delay;
assign #(out_delay) EMAC0CLIENTTXRETRANSMIT = EMAC0CLIENTTXRETRANSMIT_delay;
assign #(out_delay) EMAC0CLIENTTXSTATS = EMAC0CLIENTTXSTATS_delay;
assign #(out_delay) EMAC0CLIENTTXSTATSBYTEVLD = EMAC0CLIENTTXSTATSBYTEVLD_delay;
assign #(out_delay) EMAC0CLIENTTXSTATSVLD = EMAC0CLIENTTXSTATSVLD_delay;
assign #(out_delay) EMAC0PHYENCOMMAALIGN = EMAC0PHYENCOMMAALIGN_delay;
assign #(out_delay) EMAC0PHYLOOPBACKMSB = EMAC0PHYLOOPBACKMSB_delay;
assign #(out_delay) EMAC0PHYMDOUT = EMAC0PHYMDOUT_delay;
assign #(out_delay) EMAC0PHYMDTRI = EMAC0PHYMDTRI_delay;
assign #(out_delay) EMAC0PHYMGTRXRESET = EMAC0PHYMGTRXRESET_delay;
assign #(out_delay) EMAC0PHYMGTTXRESET = EMAC0PHYMGTTXRESET_delay;
assign #(out_delay) EMAC0PHYPOWERDOWN = EMAC0PHYPOWERDOWN_delay;
assign #(out_delay) EMAC0PHYSYNCACQSTATUS = EMAC0PHYSYNCACQSTATUS_delay;
assign #(out_delay) EMAC0PHYTXCHARDISPMODE = EMAC0PHYTXCHARDISPMODE_delay;
assign #(out_delay) EMAC0PHYTXCHARDISPVAL = EMAC0PHYTXCHARDISPVAL_delay;
assign #(out_delay) EMAC0PHYTXCHARISK = EMAC0PHYTXCHARISK_delay;
assign #(out_delay) EMAC0PHYTXD = EMAC0PHYTXD_delay;
assign #(out_delay) EMAC0PHYTXEN = EMAC0PHYTXEN_delay;
assign #(out_delay) EMAC0PHYTXER = EMAC0PHYTXER_delay;
assign #(out_delay) EMAC0SPEEDIS10100 = EMAC0SPEEDIS10100_delay;
assign #(out_delay) EMAC1CLIENTANINTERRUPT = EMAC1CLIENTANINTERRUPT_delay;
assign #(out_delay) EMAC1CLIENTRXBADFRAME = EMAC1CLIENTRXBADFRAME_delay;
assign #(out_delay) EMAC1CLIENTRXD = EMAC1CLIENTRXD_delay;
assign #(out_delay) EMAC1CLIENTRXDVLD = EMAC1CLIENTRXDVLD_delay;
assign #(out_delay) EMAC1CLIENTRXDVLDMSW = EMAC1CLIENTRXDVLDMSW_delay;
assign #(out_delay) EMAC1CLIENTRXFRAMEDROP = EMAC1CLIENTRXFRAMEDROP_delay;
assign #(out_delay) EMAC1CLIENTRXGOODFRAME = EMAC1CLIENTRXGOODFRAME_delay;
assign #(out_delay) EMAC1CLIENTRXSTATS = EMAC1CLIENTRXSTATS_delay;
assign #(out_delay) EMAC1CLIENTRXSTATSBYTEVLD = EMAC1CLIENTRXSTATSBYTEVLD_delay;
assign #(out_delay) EMAC1CLIENTRXSTATSVLD = EMAC1CLIENTRXSTATSVLD_delay;
assign #(out_delay) EMAC1CLIENTTXACK = EMAC1CLIENTTXACK_delay;
assign #(out_delay) EMAC1CLIENTTXCOLLISION = EMAC1CLIENTTXCOLLISION_delay;
assign #(out_delay) EMAC1CLIENTTXRETRANSMIT = EMAC1CLIENTTXRETRANSMIT_delay;
assign #(out_delay) EMAC1CLIENTTXSTATS = EMAC1CLIENTTXSTATS_delay;
assign #(out_delay) EMAC1CLIENTTXSTATSBYTEVLD = EMAC1CLIENTTXSTATSBYTEVLD_delay;
assign #(out_delay) EMAC1CLIENTTXSTATSVLD = EMAC1CLIENTTXSTATSVLD_delay;
assign #(out_delay) EMAC1PHYENCOMMAALIGN = EMAC1PHYENCOMMAALIGN_delay;
assign #(out_delay) EMAC1PHYLOOPBACKMSB = EMAC1PHYLOOPBACKMSB_delay;
assign #(out_delay) EMAC1PHYMDOUT = EMAC1PHYMDOUT_delay;
assign #(out_delay) EMAC1PHYMDTRI = EMAC1PHYMDTRI_delay;
assign #(out_delay) EMAC1PHYMGTRXRESET = EMAC1PHYMGTRXRESET_delay;
assign #(out_delay) EMAC1PHYMGTTXRESET = EMAC1PHYMGTTXRESET_delay;
assign #(out_delay) EMAC1PHYPOWERDOWN = EMAC1PHYPOWERDOWN_delay;
assign #(out_delay) EMAC1PHYSYNCACQSTATUS = EMAC1PHYSYNCACQSTATUS_delay;
assign #(out_delay) EMAC1PHYTXCHARDISPMODE = EMAC1PHYTXCHARDISPMODE_delay;
assign #(out_delay) EMAC1PHYTXCHARDISPVAL = EMAC1PHYTXCHARDISPVAL_delay;
assign #(out_delay) EMAC1PHYTXCHARISK = EMAC1PHYTXCHARISK_delay;
assign #(out_delay) EMAC1PHYTXD = EMAC1PHYTXD_delay;
assign #(out_delay) EMAC1PHYTXEN = EMAC1PHYTXEN_delay;
assign #(out_delay) EMAC1PHYTXER = EMAC1PHYTXER_delay;
assign #(out_delay) EMAC1SPEEDIS10100 = EMAC1SPEEDIS10100_delay;
assign #(out_delay) EMACDCRACK = EMACDCRACK_delay;
assign #(out_delay) EMACDCRDBUS = EMACDCRDBUS_delay;
assign #(out_delay) HOSTMIIMRDY = HOSTMIIMRDY_delay;
assign #(out_delay) HOSTRDDATA = HOSTRDDATA_delay;

assign #(CLK_DELAY) CLIENTEMAC0RXCLIENTCLKIN_delay = CLIENTEMAC0RXCLIENTCLKIN;
assign #(CLK_DELAY) CLIENTEMAC0TXCLIENTCLKIN_delay = CLIENTEMAC0TXCLIENTCLKIN;
assign #(CLK_DELAY) CLIENTEMAC1RXCLIENTCLKIN_delay = CLIENTEMAC1RXCLIENTCLKIN;
assign #(CLK_DELAY) CLIENTEMAC1TXCLIENTCLKIN_delay = CLIENTEMAC1TXCLIENTCLKIN;
assign #(CLK_DELAY) DCREMACCLK_delay = DCREMACCLK;
assign #(CLK_DELAY) HOSTCLK_delay = HOSTCLK;
assign #(CLK_DELAY) PHYEMAC0GTXCLK_delay = PHYEMAC0GTXCLK;
assign #(CLK_DELAY) PHYEMAC0MCLKIN_delay = PHYEMAC0MCLKIN;
assign #(EMAC0MIITXCLK_DELAY) PHYEMAC0MIITXCLK_delay = PHYEMAC0MIITXCLK;
assign #(CLK_DELAY) PHYEMAC0RXCLK_delay = PHYEMAC0RXCLK;
assign #(CLK_DELAY) PHYEMAC0TXGMIIMIICLKIN_delay = PHYEMAC0TXGMIIMIICLKIN;
assign #(CLK_DELAY) PHYEMAC1GTXCLK_delay = PHYEMAC1GTXCLK;
assign #(CLK_DELAY) PHYEMAC1MCLKIN_delay = PHYEMAC1MCLKIN;
assign #(EMAC1MIITXCLK_DELAY) PHYEMAC1MIITXCLK_delay = PHYEMAC1MIITXCLK;
assign #(CLK_DELAY) PHYEMAC1RXCLK_delay = PHYEMAC1RXCLK;
assign #(CLK_DELAY) PHYEMAC1TXGMIIMIICLKIN_delay = PHYEMAC1TXGMIIMIICLKIN;

assign #(in_delay) CLIENTEMAC0DCMLOCKED_delay = CLIENTEMAC0DCMLOCKED;
assign #(in_delay) CLIENTEMAC0PAUSEREQ_delay = CLIENTEMAC0PAUSEREQ;
assign #(in_delay) CLIENTEMAC0PAUSEVAL_delay = CLIENTEMAC0PAUSEVAL;
assign #(in_delay) CLIENTEMAC0TXDVLDMSW_delay = CLIENTEMAC0TXDVLDMSW;
assign #(in_delay) CLIENTEMAC0TXDVLD_delay = CLIENTEMAC0TXDVLD;
assign #(in_delay) CLIENTEMAC0TXD_delay = CLIENTEMAC0TXD;
assign #(in_delay) CLIENTEMAC0TXFIRSTBYTE_delay = CLIENTEMAC0TXFIRSTBYTE;
assign #(in_delay) CLIENTEMAC0TXIFGDELAY_delay = CLIENTEMAC0TXIFGDELAY;
assign #(in_delay) CLIENTEMAC0TXUNDERRUN_delay = CLIENTEMAC0TXUNDERRUN;
assign #(in_delay) CLIENTEMAC1DCMLOCKED_delay = CLIENTEMAC1DCMLOCKED;
assign #(in_delay) CLIENTEMAC1PAUSEREQ_delay = CLIENTEMAC1PAUSEREQ;
assign #(in_delay) CLIENTEMAC1PAUSEVAL_delay = CLIENTEMAC1PAUSEVAL;
assign #(in_delay) CLIENTEMAC1TXDVLDMSW_delay = CLIENTEMAC1TXDVLDMSW;
assign #(in_delay) CLIENTEMAC1TXDVLD_delay = CLIENTEMAC1TXDVLD;
assign #(in_delay) CLIENTEMAC1TXD_delay = CLIENTEMAC1TXD;
assign #(in_delay) CLIENTEMAC1TXFIRSTBYTE_delay = CLIENTEMAC1TXFIRSTBYTE;
assign #(in_delay) CLIENTEMAC1TXIFGDELAY_delay = CLIENTEMAC1TXIFGDELAY;
assign #(in_delay) CLIENTEMAC1TXUNDERRUN_delay = CLIENTEMAC1TXUNDERRUN;
assign #(in_delay) DCREMACABUS_delay = DCREMACABUS;
assign #(in_delay) DCREMACDBUS_delay = DCREMACDBUS;
assign #(in_delay) DCREMACENABLE_delay = DCREMACENABLE;
assign #(in_delay) DCREMACREAD_delay = DCREMACREAD;
assign #(in_delay) DCREMACWRITE_delay = DCREMACWRITE;
assign #(in_delay) HOSTADDR_delay = HOSTADDR;
assign #(in_delay) HOSTEMAC1SEL_delay = HOSTEMAC1SEL;
assign #(in_delay) HOSTMIIMSEL_delay = HOSTMIIMSEL;
assign #(in_delay) HOSTOPCODE_delay = HOSTOPCODE;
assign #(in_delay) HOSTREQ_delay = HOSTREQ;
assign #(in_delay) HOSTWRDATA_delay = HOSTWRDATA;
assign #(in_delay) PHYEMAC0COL_delay = PHYEMAC0COL;
assign #(in_delay) PHYEMAC0CRS_delay = PHYEMAC0CRS;
assign #(in_delay) PHYEMAC0MDIN_delay = PHYEMAC0MDIN;
assign #(in_delay) PHYEMAC0PHYAD_delay = PHYEMAC0PHYAD;
assign #(in_delay) PHYEMAC0RXBUFERR_delay = PHYEMAC0RXBUFERR;
assign #(in_delay) PHYEMAC0RXBUFSTATUS_delay = PHYEMAC0RXBUFSTATUS;
assign #(in_delay) PHYEMAC0RXCHARISCOMMA_delay = PHYEMAC0RXCHARISCOMMA;
assign #(in_delay) PHYEMAC0RXCHARISK_delay = PHYEMAC0RXCHARISK;
assign #(in_delay) PHYEMAC0RXCHECKINGCRC_delay = PHYEMAC0RXCHECKINGCRC;
assign #(in_delay) PHYEMAC0RXCLKCORCNT_delay = PHYEMAC0RXCLKCORCNT;
assign #(in_delay) PHYEMAC0RXCOMMADET_delay = PHYEMAC0RXCOMMADET;
assign #(in_delay) PHYEMAC0RXDISPERR_delay = PHYEMAC0RXDISPERR;
assign #(in_delay) PHYEMAC0RXDV_delay = PHYEMAC0RXDV;
assign #(in_delay) PHYEMAC0RXD_delay = PHYEMAC0RXD;
assign #(in_delay) PHYEMAC0RXER_delay = PHYEMAC0RXER;
assign #(in_delay) PHYEMAC0RXLOSSOFSYNC_delay = PHYEMAC0RXLOSSOFSYNC;
assign #(in_delay) PHYEMAC0RXNOTINTABLE_delay = PHYEMAC0RXNOTINTABLE;
assign #(in_delay) PHYEMAC0RXRUNDISP_delay = PHYEMAC0RXRUNDISP;
assign #(in_delay) PHYEMAC0SIGNALDET_delay = PHYEMAC0SIGNALDET;
assign #(in_delay) PHYEMAC0TXBUFERR_delay = PHYEMAC0TXBUFERR;
assign #(in_delay) PHYEMAC1COL_delay = PHYEMAC1COL;
assign #(in_delay) PHYEMAC1CRS_delay = PHYEMAC1CRS;
assign #(in_delay) PHYEMAC1MDIN_delay = PHYEMAC1MDIN;
assign #(in_delay) PHYEMAC1PHYAD_delay = PHYEMAC1PHYAD;
assign #(in_delay) PHYEMAC1RXBUFERR_delay = PHYEMAC1RXBUFERR;
assign #(in_delay) PHYEMAC1RXBUFSTATUS_delay = PHYEMAC1RXBUFSTATUS;
assign #(in_delay) PHYEMAC1RXCHARISCOMMA_delay = PHYEMAC1RXCHARISCOMMA;
assign #(in_delay) PHYEMAC1RXCHARISK_delay = PHYEMAC1RXCHARISK;
assign #(in_delay) PHYEMAC1RXCHECKINGCRC_delay = PHYEMAC1RXCHECKINGCRC;
assign #(in_delay) PHYEMAC1RXCLKCORCNT_delay = PHYEMAC1RXCLKCORCNT;
assign #(in_delay) PHYEMAC1RXCOMMADET_delay = PHYEMAC1RXCOMMADET;
assign #(in_delay) PHYEMAC1RXDISPERR_delay = PHYEMAC1RXDISPERR;
assign #(in_delay) PHYEMAC1RXDV_delay = PHYEMAC1RXDV;
assign #(in_delay) PHYEMAC1RXD_delay = PHYEMAC1RXD;
assign #(in_delay) PHYEMAC1RXER_delay = PHYEMAC1RXER;
assign #(in_delay) PHYEMAC1RXLOSSOFSYNC_delay = PHYEMAC1RXLOSSOFSYNC;
assign #(in_delay) PHYEMAC1RXNOTINTABLE_delay = PHYEMAC1RXNOTINTABLE;
assign #(in_delay) PHYEMAC1RXRUNDISP_delay = PHYEMAC1RXRUNDISP;
assign #(in_delay) PHYEMAC1SIGNALDET_delay = PHYEMAC1SIGNALDET;
assign #(in_delay) PHYEMAC1TXBUFERR_delay = PHYEMAC1TXBUFERR;
assign #(in_delay) RESET_delay = RESET;

TEMAC_SWIFT temac_swift_1 (
	.EMAC0_1000BASEX_ENABLE (EMAC0_1000BASEX_ENABLE_BINARY),
	.EMAC0_ADDRFILTER_ENABLE (EMAC0_ADDRFILTER_ENABLE_BINARY),
	.EMAC0_BYTEPHY (EMAC0_BYTEPHY_BINARY),
	.EMAC0_CONFIGVEC_79 (EMAC0_CONFIGVEC_79_BINARY),
	.EMAC0_DCRBASEADDR (EMAC0_DCRBASEADDR),
	.EMAC0_GTLOOPBACK (EMAC0_GTLOOPBACK_BINARY),
	.EMAC0_HOST_ENABLE (EMAC0_HOST_ENABLE_BINARY),
	.EMAC0_LINKTIMERVAL (EMAC0_LINKTIMERVAL),
	.EMAC0_LTCHECK_DISABLE (EMAC0_LTCHECK_DISABLE_BINARY),
	.EMAC0_MDIO_ENABLE (EMAC0_MDIO_ENABLE_BINARY),
	.EMAC0_PAUSEADDR (EMAC0_PAUSEADDR),
	.EMAC0_PHYINITAUTONEG_ENABLE (EMAC0_PHYINITAUTONEG_ENABLE_BINARY),
	.EMAC0_PHYISOLATE (EMAC0_PHYISOLATE_BINARY),
	.EMAC0_PHYLOOPBACKMSB (EMAC0_PHYLOOPBACKMSB_BINARY),
	.EMAC0_PHYPOWERDOWN (EMAC0_PHYPOWERDOWN_BINARY),
	.EMAC0_PHYRESET (EMAC0_PHYRESET_BINARY),
	.EMAC0_RGMII_ENABLE (EMAC0_RGMII_ENABLE_BINARY),
	.EMAC0_RX16BITCLIENT_ENABLE (EMAC0_RX16BITCLIENT_ENABLE_BINARY),
	.EMAC0_RXFLOWCTRL_ENABLE (EMAC0_RXFLOWCTRL_ENABLE_BINARY),
	.EMAC0_RXHALFDUPLEX (EMAC0_RXHALFDUPLEX_BINARY),
	.EMAC0_RXINBANDFCS_ENABLE (EMAC0_RXINBANDFCS_ENABLE_BINARY),
	.EMAC0_RXJUMBOFRAME_ENABLE (EMAC0_RXJUMBOFRAME_ENABLE_BINARY),
	.EMAC0_RXRESET (EMAC0_RXRESET_BINARY),
	.EMAC0_RXVLAN_ENABLE (EMAC0_RXVLAN_ENABLE_BINARY),
	.EMAC0_RX_ENABLE (EMAC0_RX_ENABLE_BINARY),
	.EMAC0_SGMII_ENABLE (EMAC0_SGMII_ENABLE_BINARY),
	.EMAC0_SPEED_LSB (EMAC0_SPEED_LSB_BINARY),
	.EMAC0_SPEED_MSB (EMAC0_SPEED_MSB_BINARY),
	.EMAC0_TX16BITCLIENT_ENABLE (EMAC0_TX16BITCLIENT_ENABLE_BINARY),
	.EMAC0_TXFLOWCTRL_ENABLE (EMAC0_TXFLOWCTRL_ENABLE_BINARY),
	.EMAC0_TXHALFDUPLEX (EMAC0_TXHALFDUPLEX_BINARY),
	.EMAC0_TXIFGADJUST_ENABLE (EMAC0_TXIFGADJUST_ENABLE_BINARY),
	.EMAC0_TXINBANDFCS_ENABLE (EMAC0_TXINBANDFCS_ENABLE_BINARY),
	.EMAC0_TXJUMBOFRAME_ENABLE (EMAC0_TXJUMBOFRAME_ENABLE_BINARY),
	.EMAC0_TXRESET (EMAC0_TXRESET_BINARY),
	.EMAC0_TXVLAN_ENABLE (EMAC0_TXVLAN_ENABLE_BINARY),
	.EMAC0_TX_ENABLE (EMAC0_TX_ENABLE_BINARY),
	.EMAC0_UNICASTADDR (EMAC0_UNICASTADDR),
	.EMAC0_UNIDIRECTION_ENABLE (EMAC0_UNIDIRECTION_ENABLE_BINARY),
	.EMAC0_USECLKEN (EMAC0_USECLKEN_BINARY),
	.EMAC1_1000BASEX_ENABLE (EMAC1_1000BASEX_ENABLE_BINARY),
	.EMAC1_ADDRFILTER_ENABLE (EMAC1_ADDRFILTER_ENABLE_BINARY),
	.EMAC1_BYTEPHY (EMAC1_BYTEPHY_BINARY),
	.EMAC1_CONFIGVEC_79 (EMAC1_CONFIGVEC_79_BINARY),
	.EMAC1_DCRBASEADDR (EMAC1_DCRBASEADDR),
	.EMAC1_GTLOOPBACK (EMAC1_GTLOOPBACK_BINARY),
	.EMAC1_HOST_ENABLE (EMAC1_HOST_ENABLE_BINARY),
	.EMAC1_LINKTIMERVAL (EMAC1_LINKTIMERVAL),
	.EMAC1_LTCHECK_DISABLE (EMAC1_LTCHECK_DISABLE_BINARY),
	.EMAC1_MDIO_ENABLE (EMAC1_MDIO_ENABLE_BINARY),
	.EMAC1_PAUSEADDR (EMAC1_PAUSEADDR),
	.EMAC1_PHYINITAUTONEG_ENABLE (EMAC1_PHYINITAUTONEG_ENABLE_BINARY),
	.EMAC1_PHYISOLATE (EMAC1_PHYISOLATE_BINARY),
	.EMAC1_PHYLOOPBACKMSB (EMAC1_PHYLOOPBACKMSB_BINARY),
	.EMAC1_PHYPOWERDOWN (EMAC1_PHYPOWERDOWN_BINARY),
	.EMAC1_PHYRESET (EMAC1_PHYRESET_BINARY),
	.EMAC1_RGMII_ENABLE (EMAC1_RGMII_ENABLE_BINARY),
	.EMAC1_RX16BITCLIENT_ENABLE (EMAC1_RX16BITCLIENT_ENABLE_BINARY),
	.EMAC1_RXFLOWCTRL_ENABLE (EMAC1_RXFLOWCTRL_ENABLE_BINARY),
	.EMAC1_RXHALFDUPLEX (EMAC1_RXHALFDUPLEX_BINARY),
	.EMAC1_RXINBANDFCS_ENABLE (EMAC1_RXINBANDFCS_ENABLE_BINARY),
	.EMAC1_RXJUMBOFRAME_ENABLE (EMAC1_RXJUMBOFRAME_ENABLE_BINARY),
	.EMAC1_RXRESET (EMAC1_RXRESET_BINARY),
	.EMAC1_RXVLAN_ENABLE (EMAC1_RXVLAN_ENABLE_BINARY),
	.EMAC1_RX_ENABLE (EMAC1_RX_ENABLE_BINARY),
	.EMAC1_SGMII_ENABLE (EMAC1_SGMII_ENABLE_BINARY),
	.EMAC1_SPEED_LSB (EMAC1_SPEED_LSB_BINARY),
	.EMAC1_SPEED_MSB (EMAC1_SPEED_MSB_BINARY),
	.EMAC1_TX16BITCLIENT_ENABLE (EMAC1_TX16BITCLIENT_ENABLE_BINARY),
	.EMAC1_TXFLOWCTRL_ENABLE (EMAC1_TXFLOWCTRL_ENABLE_BINARY),
	.EMAC1_TXHALFDUPLEX (EMAC1_TXHALFDUPLEX_BINARY),
	.EMAC1_TXIFGADJUST_ENABLE (EMAC1_TXIFGADJUST_ENABLE_BINARY),
	.EMAC1_TXINBANDFCS_ENABLE (EMAC1_TXINBANDFCS_ENABLE_BINARY),
	.EMAC1_TXJUMBOFRAME_ENABLE (EMAC1_TXJUMBOFRAME_ENABLE_BINARY),
	.EMAC1_TXRESET (EMAC1_TXRESET_BINARY),
	.EMAC1_TXVLAN_ENABLE (EMAC1_TXVLAN_ENABLE_BINARY),
	.EMAC1_TX_ENABLE (EMAC1_TX_ENABLE_BINARY),
	.EMAC1_UNICASTADDR (EMAC1_UNICASTADDR),
	.EMAC1_UNIDIRECTION_ENABLE (EMAC1_UNIDIRECTION_ENABLE_BINARY),
	.EMAC1_USECLKEN (EMAC1_USECLKEN_BINARY),

	.DCRHOSTDONEIR (DCRHOSTDONEIR_delay),
	.EMAC0CLIENTANINTERRUPT (EMAC0CLIENTANINTERRUPT_delay),
	.EMAC0CLIENTRXBADFRAME (EMAC0CLIENTRXBADFRAME_delay),
	.EMAC0CLIENTRXCLIENTCLKOUT (EMAC0CLIENTRXCLIENTCLKOUT_delay),
	.EMAC0CLIENTRXD (EMAC0CLIENTRXD_delay),
	.EMAC0CLIENTRXDVLD (EMAC0CLIENTRXDVLD_delay),
	.EMAC0CLIENTRXDVLDMSW (EMAC0CLIENTRXDVLDMSW_delay),
	.EMAC0CLIENTRXFRAMEDROP (EMAC0CLIENTRXFRAMEDROP_delay),
	.EMAC0CLIENTRXGOODFRAME (EMAC0CLIENTRXGOODFRAME_delay),
	.EMAC0CLIENTRXSTATS (EMAC0CLIENTRXSTATS_delay),
	.EMAC0CLIENTRXSTATSBYTEVLD (EMAC0CLIENTRXSTATSBYTEVLD_delay),
	.EMAC0CLIENTRXSTATSVLD (EMAC0CLIENTRXSTATSVLD_delay),
	.EMAC0CLIENTTXACK (EMAC0CLIENTTXACK_delay),
	.EMAC0CLIENTTXCLIENTCLKOUT (EMAC0CLIENTTXCLIENTCLKOUT_delay),
	.EMAC0CLIENTTXCOLLISION (EMAC0CLIENTTXCOLLISION_delay),
	.EMAC0CLIENTTXRETRANSMIT (EMAC0CLIENTTXRETRANSMIT_delay),
	.EMAC0CLIENTTXSTATS (EMAC0CLIENTTXSTATS_delay),
	.EMAC0CLIENTTXSTATSBYTEVLD (EMAC0CLIENTTXSTATSBYTEVLD_delay),
	.EMAC0CLIENTTXSTATSVLD (EMAC0CLIENTTXSTATSVLD_delay),
	.EMAC0PHYENCOMMAALIGN (EMAC0PHYENCOMMAALIGN_delay),
	.EMAC0PHYLOOPBACKMSB (EMAC0PHYLOOPBACKMSB_delay),
	.EMAC0PHYMCLKOUT (EMAC0PHYMCLKOUT_delay),
	.EMAC0PHYMDOUT (EMAC0PHYMDOUT_delay),
	.EMAC0PHYMDTRI (EMAC0PHYMDTRI_delay),
	.EMAC0PHYMGTRXRESET (EMAC0PHYMGTRXRESET_delay),
	.EMAC0PHYMGTTXRESET (EMAC0PHYMGTTXRESET_delay),
	.EMAC0PHYPOWERDOWN (EMAC0PHYPOWERDOWN_delay),
	.EMAC0PHYSYNCACQSTATUS (EMAC0PHYSYNCACQSTATUS_delay),
	.EMAC0PHYTXCHARDISPMODE (EMAC0PHYTXCHARDISPMODE_delay),
	.EMAC0PHYTXCHARDISPVAL (EMAC0PHYTXCHARDISPVAL_delay),
	.EMAC0PHYTXCHARISK (EMAC0PHYTXCHARISK_delay),
	.EMAC0PHYTXCLK (EMAC0PHYTXCLK_delay),
	.EMAC0PHYTXD (EMAC0PHYTXD_delay),
	.EMAC0PHYTXEN (EMAC0PHYTXEN_delay),
	.EMAC0PHYTXER (EMAC0PHYTXER_delay),
	.EMAC0PHYTXGMIIMIICLKOUT (EMAC0PHYTXGMIIMIICLKOUT_delay),
	.EMAC0SPEEDIS10100 (EMAC0SPEEDIS10100_delay),
	.EMAC1CLIENTANINTERRUPT (EMAC1CLIENTANINTERRUPT_delay),
	.EMAC1CLIENTRXBADFRAME (EMAC1CLIENTRXBADFRAME_delay),
	.EMAC1CLIENTRXCLIENTCLKOUT (EMAC1CLIENTRXCLIENTCLKOUT_delay),
	.EMAC1CLIENTRXD (EMAC1CLIENTRXD_delay),
	.EMAC1CLIENTRXDVLD (EMAC1CLIENTRXDVLD_delay),
	.EMAC1CLIENTRXDVLDMSW (EMAC1CLIENTRXDVLDMSW_delay),
	.EMAC1CLIENTRXFRAMEDROP (EMAC1CLIENTRXFRAMEDROP_delay),
	.EMAC1CLIENTRXGOODFRAME (EMAC1CLIENTRXGOODFRAME_delay),
	.EMAC1CLIENTRXSTATS (EMAC1CLIENTRXSTATS_delay),
	.EMAC1CLIENTRXSTATSBYTEVLD (EMAC1CLIENTRXSTATSBYTEVLD_delay),
	.EMAC1CLIENTRXSTATSVLD (EMAC1CLIENTRXSTATSVLD_delay),
	.EMAC1CLIENTTXACK (EMAC1CLIENTTXACK_delay),
	.EMAC1CLIENTTXCLIENTCLKOUT (EMAC1CLIENTTXCLIENTCLKOUT_delay),
	.EMAC1CLIENTTXCOLLISION (EMAC1CLIENTTXCOLLISION_delay),
	.EMAC1CLIENTTXRETRANSMIT (EMAC1CLIENTTXRETRANSMIT_delay),
	.EMAC1CLIENTTXSTATS (EMAC1CLIENTTXSTATS_delay),
	.EMAC1CLIENTTXSTATSBYTEVLD (EMAC1CLIENTTXSTATSBYTEVLD_delay),
	.EMAC1CLIENTTXSTATSVLD (EMAC1CLIENTTXSTATSVLD_delay),
	.EMAC1PHYENCOMMAALIGN (EMAC1PHYENCOMMAALIGN_delay),
	.EMAC1PHYLOOPBACKMSB (EMAC1PHYLOOPBACKMSB_delay),
	.EMAC1PHYMCLKOUT (EMAC1PHYMCLKOUT_delay),
	.EMAC1PHYMDOUT (EMAC1PHYMDOUT_delay),
	.EMAC1PHYMDTRI (EMAC1PHYMDTRI_delay),
	.EMAC1PHYMGTRXRESET (EMAC1PHYMGTRXRESET_delay),
	.EMAC1PHYMGTTXRESET (EMAC1PHYMGTTXRESET_delay),
	.EMAC1PHYPOWERDOWN (EMAC1PHYPOWERDOWN_delay),
	.EMAC1PHYSYNCACQSTATUS (EMAC1PHYSYNCACQSTATUS_delay),
	.EMAC1PHYTXCHARDISPMODE (EMAC1PHYTXCHARDISPMODE_delay),
	.EMAC1PHYTXCHARDISPVAL (EMAC1PHYTXCHARDISPVAL_delay),
	.EMAC1PHYTXCHARISK (EMAC1PHYTXCHARISK_delay),
	.EMAC1PHYTXCLK (EMAC1PHYTXCLK_delay),
	.EMAC1PHYTXD (EMAC1PHYTXD_delay),
	.EMAC1PHYTXEN (EMAC1PHYTXEN_delay),
	.EMAC1PHYTXER (EMAC1PHYTXER_delay),
	.EMAC1PHYTXGMIIMIICLKOUT (EMAC1PHYTXGMIIMIICLKOUT_delay),
	.EMAC1SPEEDIS10100 (EMAC1SPEEDIS10100_delay),
	.EMACDCRACK (EMACDCRACK_delay),
	.EMACDCRDBUS (EMACDCRDBUS_delay),
	.HOSTMIIMRDY (HOSTMIIMRDY_delay),
	.HOSTRDDATA (HOSTRDDATA_delay),

	.CLIENTEMAC0DCMLOCKED (CLIENTEMAC0DCMLOCKED_delay),
	.CLIENTEMAC0PAUSEREQ (CLIENTEMAC0PAUSEREQ_delay),
	.CLIENTEMAC0PAUSEVAL (CLIENTEMAC0PAUSEVAL_delay),
	.CLIENTEMAC0RXCLIENTCLKIN (CLIENTEMAC0RXCLIENTCLKIN_delay),
	.CLIENTEMAC0TXCLIENTCLKIN (CLIENTEMAC0TXCLIENTCLKIN_delay),
	.CLIENTEMAC0TXD (CLIENTEMAC0TXD_delay),
	.CLIENTEMAC0TXDVLD (CLIENTEMAC0TXDVLD_delay),
	.CLIENTEMAC0TXDVLDMSW (CLIENTEMAC0TXDVLDMSW_delay),
	.CLIENTEMAC0TXFIRSTBYTE (CLIENTEMAC0TXFIRSTBYTE_delay),
	.CLIENTEMAC0TXIFGDELAY (CLIENTEMAC0TXIFGDELAY_delay),
	.CLIENTEMAC0TXUNDERRUN (CLIENTEMAC0TXUNDERRUN_delay),
	.CLIENTEMAC1DCMLOCKED (CLIENTEMAC1DCMLOCKED_delay),
	.CLIENTEMAC1PAUSEREQ (CLIENTEMAC1PAUSEREQ_delay),
	.CLIENTEMAC1PAUSEVAL (CLIENTEMAC1PAUSEVAL_delay),
	.CLIENTEMAC1RXCLIENTCLKIN (CLIENTEMAC1RXCLIENTCLKIN_delay),
	.CLIENTEMAC1TXCLIENTCLKIN (CLIENTEMAC1TXCLIENTCLKIN_delay),
	.CLIENTEMAC1TXD (CLIENTEMAC1TXD_delay),
	.CLIENTEMAC1TXDVLD (CLIENTEMAC1TXDVLD_delay),
	.CLIENTEMAC1TXDVLDMSW (CLIENTEMAC1TXDVLDMSW_delay),
	.CLIENTEMAC1TXFIRSTBYTE (CLIENTEMAC1TXFIRSTBYTE_delay),
	.CLIENTEMAC1TXIFGDELAY (CLIENTEMAC1TXIFGDELAY_delay),
	.CLIENTEMAC1TXUNDERRUN (CLIENTEMAC1TXUNDERRUN_delay),
	.DCREMACABUS (DCREMACABUS_delay),
	.DCREMACCLK (DCREMACCLK_delay),
	.DCREMACDBUS (DCREMACDBUS_delay),
	.DCREMACENABLE (DCREMACENABLE_delay),
	.DCREMACREAD (DCREMACREAD_delay),
	.DCREMACWRITE (DCREMACWRITE_delay),
	.HOSTADDR (HOSTADDR_delay),
	.HOSTCLK (HOSTCLK_delay),
	.HOSTEMAC1SEL (HOSTEMAC1SEL_delay),
	.HOSTMIIMSEL (HOSTMIIMSEL_delay),
	.HOSTOPCODE (HOSTOPCODE_delay),
	.HOSTREQ (HOSTREQ_delay),
	.HOSTWRDATA (HOSTWRDATA_delay),
	.PHYEMAC0COL (PHYEMAC0COL_delay),
	.PHYEMAC0CRS (PHYEMAC0CRS_delay),
	.PHYEMAC0GTXCLK (PHYEMAC0GTXCLK_delay),
	.PHYEMAC0MCLKIN (PHYEMAC0MCLKIN_delay),
	.PHYEMAC0MDIN (PHYEMAC0MDIN_delay),
	.PHYEMAC0MIITXCLK (PHYEMAC0MIITXCLK_delay),
	.PHYEMAC0PHYAD (PHYEMAC0PHYAD_delay),
	.PHYEMAC0RXBUFERR (PHYEMAC0RXBUFERR_delay),
	.PHYEMAC0RXBUFSTATUS (PHYEMAC0RXBUFSTATUS_delay),
	.PHYEMAC0RXCHARISCOMMA (PHYEMAC0RXCHARISCOMMA_delay),
	.PHYEMAC0RXCHARISK (PHYEMAC0RXCHARISK_delay),
	.PHYEMAC0RXCHECKINGCRC (PHYEMAC0RXCHECKINGCRC_delay),
	.PHYEMAC0RXCLK (PHYEMAC0RXCLK_delay),
	.PHYEMAC0RXCLKCORCNT (PHYEMAC0RXCLKCORCNT_delay),
	.PHYEMAC0RXCOMMADET (PHYEMAC0RXCOMMADET_delay),
	.PHYEMAC0RXD (PHYEMAC0RXD_delay),
	.PHYEMAC0RXDISPERR (PHYEMAC0RXDISPERR_delay),
	.PHYEMAC0RXDV (PHYEMAC0RXDV_delay),
	.PHYEMAC0RXER (PHYEMAC0RXER_delay),
	.PHYEMAC0RXLOSSOFSYNC (PHYEMAC0RXLOSSOFSYNC_delay),
	.PHYEMAC0RXNOTINTABLE (PHYEMAC0RXNOTINTABLE_delay),
	.PHYEMAC0RXRUNDISP (PHYEMAC0RXRUNDISP_delay),
	.PHYEMAC0SIGNALDET (PHYEMAC0SIGNALDET_delay),
	.PHYEMAC0TXBUFERR (PHYEMAC0TXBUFERR_delay),
	.PHYEMAC0TXGMIIMIICLKIN (PHYEMAC0TXGMIIMIICLKIN_delay),
	.PHYEMAC1COL (PHYEMAC1COL_delay),
	.PHYEMAC1CRS (PHYEMAC1CRS_delay),
	.PHYEMAC1GTXCLK (PHYEMAC1GTXCLK_delay),
	.PHYEMAC1MCLKIN (PHYEMAC1MCLKIN_delay),
	.PHYEMAC1MDIN (PHYEMAC1MDIN_delay),
	.PHYEMAC1MIITXCLK (PHYEMAC1MIITXCLK_delay),
	.PHYEMAC1PHYAD (PHYEMAC1PHYAD_delay),
	.PHYEMAC1RXBUFERR (PHYEMAC1RXBUFERR_delay),
	.PHYEMAC1RXBUFSTATUS (PHYEMAC1RXBUFSTATUS_delay),
	.PHYEMAC1RXCHARISCOMMA (PHYEMAC1RXCHARISCOMMA_delay),
	.PHYEMAC1RXCHARISK (PHYEMAC1RXCHARISK_delay),
	.PHYEMAC1RXCHECKINGCRC (PHYEMAC1RXCHECKINGCRC_delay),
	.PHYEMAC1RXCLK (PHYEMAC1RXCLK_delay),
	.PHYEMAC1RXCLKCORCNT (PHYEMAC1RXCLKCORCNT_delay),
	.PHYEMAC1RXCOMMADET (PHYEMAC1RXCOMMADET_delay),
	.PHYEMAC1RXD (PHYEMAC1RXD_delay),
	.PHYEMAC1RXDISPERR (PHYEMAC1RXDISPERR_delay),
	.PHYEMAC1RXDV (PHYEMAC1RXDV_delay),
	.PHYEMAC1RXER (PHYEMAC1RXER_delay),
	.PHYEMAC1RXLOSSOFSYNC (PHYEMAC1RXLOSSOFSYNC_delay),
	.PHYEMAC1RXNOTINTABLE (PHYEMAC1RXNOTINTABLE_delay),
	.PHYEMAC1RXRUNDISP (PHYEMAC1RXRUNDISP_delay),
	.PHYEMAC1SIGNALDET (PHYEMAC1SIGNALDET_delay),
	.PHYEMAC1TXBUFERR (PHYEMAC1TXBUFERR_delay),
	.PHYEMAC1TXGMIIMIICLKIN (PHYEMAC1TXGMIIMIICLKIN_delay),
	.RESET (RESET_delay)
);

specify
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXBADFRAME) = (100, 100);
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXCLIENTCLKOUT) = (100, 100);
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXD) = (100, 100);
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXDVLD) = (100, 100);
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXDVLDMSW) = (100, 100);
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXFRAMEDROP) = (100, 100);
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXGOODFRAME) = (100, 100);
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXSTATS) = (100, 100);
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXSTATSBYTEVLD) = (100, 100);
	(CLIENTEMAC0RXCLIENTCLKIN => EMAC0CLIENTRXSTATSVLD) = (100, 100);
	(CLIENTEMAC0TXCLIENTCLKIN => EMAC0CLIENTTXACK) = (100, 100);
	(CLIENTEMAC0TXCLIENTCLKIN => EMAC0CLIENTTXCOLLISION) = (100, 100);
	(CLIENTEMAC0TXCLIENTCLKIN => EMAC0CLIENTTXRETRANSMIT) = (100, 100);
	(CLIENTEMAC0TXCLIENTCLKIN => EMAC0CLIENTTXSTATS) = (100, 100);
	(CLIENTEMAC0TXCLIENTCLKIN => EMAC0CLIENTTXSTATSBYTEVLD) = (100, 100);
	(CLIENTEMAC0TXCLIENTCLKIN => EMAC0CLIENTTXSTATSVLD) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXBADFRAME) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXCLIENTCLKOUT) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXD) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXDVLD) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXDVLDMSW) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXFRAMEDROP) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXGOODFRAME) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXSTATS) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXSTATSBYTEVLD) = (100, 100);
	(CLIENTEMAC1RXCLIENTCLKIN => EMAC1CLIENTRXSTATSVLD) = (100, 100);
	(CLIENTEMAC1TXCLIENTCLKIN => EMAC1CLIENTTXACK) = (100, 100);
	(CLIENTEMAC1TXCLIENTCLKIN => EMAC1CLIENTTXCOLLISION) = (100, 100);
	(CLIENTEMAC1TXCLIENTCLKIN => EMAC1CLIENTTXRETRANSMIT) = (100, 100);
	(CLIENTEMAC1TXCLIENTCLKIN => EMAC1CLIENTTXSTATS) = (100, 100);
	(CLIENTEMAC1TXCLIENTCLKIN => EMAC1CLIENTTXSTATSBYTEVLD) = (100, 100);
	(CLIENTEMAC1TXCLIENTCLKIN => EMAC1CLIENTTXSTATSVLD) = (100, 100);
	(DCREMACCLK => EMACDCRACK) = (100, 100);
	(DCREMACCLK => EMACDCRDBUS) = (100, 100);
	(HOSTCLK => DCRHOSTDONEIR) = (100, 100);
	(HOSTCLK => EMAC0PHYMCLKOUT) = (100, 100);
	(HOSTCLK => EMAC0PHYMDOUT) = (100, 100);
	(HOSTCLK => EMAC0PHYMDTRI) = (100, 100);
	(HOSTCLK => EMAC0SPEEDIS10100) = (100, 100);
	(HOSTCLK => EMAC1PHYMCLKOUT) = (100, 100);
	(HOSTCLK => EMAC1PHYMDOUT) = (100, 100);
	(HOSTCLK => EMAC1PHYMDTRI) = (100, 100);
	(HOSTCLK => EMAC1SPEEDIS10100) = (100, 100);
	(HOSTCLK => HOSTMIIMRDY) = (100, 100);
	(HOSTCLK => HOSTRDDATA) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0CLIENTANINTERRUPT) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYENCOMMAALIGN) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYLOOPBACKMSB) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYMGTRXRESET) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYMGTTXRESET) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYPOWERDOWN) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYSYNCACQSTATUS) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYTXCHARDISPMODE) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYTXCHARDISPVAL) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYTXCHARISK) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYTXCLK) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYTXD) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYTXEN) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYTXER) = (100, 100);
	(PHYEMAC0GTXCLK => EMAC0PHYTXGMIIMIICLKOUT) = (100, 100);
	(PHYEMAC0TXGMIIMIICLKIN => EMAC0CLIENTTXCLIENTCLKOUT) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1CLIENTANINTERRUPT) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYENCOMMAALIGN) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYLOOPBACKMSB) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYMGTRXRESET) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYMGTTXRESET) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYPOWERDOWN) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYSYNCACQSTATUS) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYTXCHARDISPMODE) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYTXCHARDISPVAL) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYTXCHARISK) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYTXCLK) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYTXD) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYTXEN) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYTXER) = (100, 100);
	(PHYEMAC1GTXCLK => EMAC1PHYTXGMIIMIICLKOUT) = (100, 100);
	(PHYEMAC1TXGMIIMIICLKIN => EMAC1CLIENTTXCLIENTCLKOUT) = (100, 100);
	specparam PATHPULSE$ = 0;
endspecify
endmodule
