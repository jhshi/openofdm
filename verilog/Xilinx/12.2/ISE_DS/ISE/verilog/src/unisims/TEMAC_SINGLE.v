///////////////////////////////////////////////////////
//  Copyright (c) 2009 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : Xilinx Functional Simulation Library Component
//  /  /                       : Tri-Mode Ethernet MAC
// /__/   /\       Filename    : TEMAC_SINGLE.v
// \  \  /  \      
//  \__\/\__ \                    
//                                 
//  Revision:
//  11/05/07 - CR453443 - Initial version.
//  05/30/08 - CR1014 - Added parameter
//  08/05/08 - CR1014 - EMAC_DCRBASEADDR updated from [7:0] to [0:7]
//  08/25/08 - CR1014 - SWIFT instantiation replaced by B_TEMAC_SINGLE. Added case statement, assign statement for buffers.
//  09/16/08 - CR1014 - Added specify block
//  09/23/08 - CR490337 - assign buffer updates _delay to delay_
//                      - specify block updates to bit & buses
//  10/13/08 - CR492334 - update TEMAC_SINGLE_INST to B_TEMAC_SINGLE_INST
//  11/11/08 - CR493972 - Add SIM_VERSION
//  01/27/09 - CR505569 - Writer update
//  04/03/09 - CR515882 - Fix for 16 bit client mode
//  09/01/09 - CR532335 - Delay YML update, specify block update
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module TEMAC_SINGLE (
  DCRHOSTDONEIR,
  EMACCLIENTANINTERRUPT,
  EMACCLIENTRXBADFRAME,
  EMACCLIENTRXCLIENTCLKOUT,
  EMACCLIENTRXD,
  EMACCLIENTRXDVLD,
  EMACCLIENTRXDVLDMSW,
  EMACCLIENTRXFRAMEDROP,
  EMACCLIENTRXGOODFRAME,
  EMACCLIENTRXSTATS,
  EMACCLIENTRXSTATSBYTEVLD,
  EMACCLIENTRXSTATSVLD,
  EMACCLIENTTXACK,
  EMACCLIENTTXCLIENTCLKOUT,
  EMACCLIENTTXCOLLISION,
  EMACCLIENTTXRETRANSMIT,
  EMACCLIENTTXSTATS,
  EMACCLIENTTXSTATSBYTEVLD,
  EMACCLIENTTXSTATSVLD,
  EMACDCRACK,
  EMACDCRDBUS,
  EMACPHYENCOMMAALIGN,
  EMACPHYLOOPBACKMSB,
  EMACPHYMCLKOUT,
  EMACPHYMDOUT,
  EMACPHYMDTRI,
  EMACPHYMGTRXRESET,
  EMACPHYMGTTXRESET,
  EMACPHYPOWERDOWN,
  EMACPHYSYNCACQSTATUS,
  EMACPHYTXCHARDISPMODE,
  EMACPHYTXCHARDISPVAL,
  EMACPHYTXCHARISK,
  EMACPHYTXCLK,
  EMACPHYTXD,
  EMACPHYTXEN,
  EMACPHYTXER,
  EMACPHYTXGMIIMIICLKOUT,
  EMACSPEEDIS10100,
  HOSTMIIMRDY,
  HOSTRDDATA,
  CLIENTEMACDCMLOCKED,
  CLIENTEMACPAUSEREQ,
  CLIENTEMACPAUSEVAL,
  CLIENTEMACRXCLIENTCLKIN,
  CLIENTEMACTXCLIENTCLKIN,
  CLIENTEMACTXD,
  CLIENTEMACTXDVLD,
  CLIENTEMACTXDVLDMSW,
  CLIENTEMACTXFIRSTBYTE,
  CLIENTEMACTXIFGDELAY,
  CLIENTEMACTXUNDERRUN,
  DCREMACABUS,
  DCREMACCLK,
  DCREMACDBUS,
  DCREMACENABLE,
  DCREMACREAD,
  DCREMACWRITE,
  HOSTADDR,
  HOSTCLK,
  HOSTMIIMSEL,
  HOSTOPCODE,
  HOSTREQ,
  HOSTWRDATA,
  PHYEMACCOL,
  PHYEMACCRS,
  PHYEMACGTXCLK,
  PHYEMACMCLKIN,
  PHYEMACMDIN,
  PHYEMACMIITXCLK,
  PHYEMACPHYAD,
  PHYEMACRXBUFSTATUS,
  PHYEMACRXCHARISCOMMA,
  PHYEMACRXCHARISK,
  PHYEMACRXCLK,
  PHYEMACRXCLKCORCNT,
  PHYEMACRXD,
  PHYEMACRXDISPERR,
  PHYEMACRXDV,
  PHYEMACRXER,
  PHYEMACRXNOTINTABLE,
  PHYEMACRXRUNDISP,
  PHYEMACSIGNALDET,
  PHYEMACTXBUFERR,
  PHYEMACTXGMIIMIICLKIN,
  RESET
);

  parameter EMAC_1000BASEX_ENABLE = "FALSE";
  parameter EMAC_ADDRFILTER_ENABLE = "FALSE";
  parameter EMAC_BYTEPHY = "FALSE";
  parameter EMAC_CTRLLENCHECK_DISABLE = "FALSE";
  parameter [0:7] EMAC_DCRBASEADDR = 8'h00;
  parameter EMAC_GTLOOPBACK = "FALSE";
  parameter EMAC_HOST_ENABLE = "FALSE";
  parameter [8:0] EMAC_LINKTIMERVAL = 9'h000;
  parameter EMAC_LTCHECK_DISABLE = "FALSE";
  parameter EMAC_MDIO_ENABLE = "FALSE";
  parameter EMAC_MDIO_IGNORE_PHYADZERO = "FALSE";
  parameter [47:0] EMAC_PAUSEADDR = 48'h000000000000;
  parameter EMAC_PHYINITAUTONEG_ENABLE = "FALSE";
  parameter EMAC_PHYISOLATE = "FALSE";
  parameter EMAC_PHYLOOPBACKMSB = "FALSE";
  parameter EMAC_PHYPOWERDOWN = "FALSE";
  parameter EMAC_PHYRESET = "FALSE";
  parameter EMAC_RGMII_ENABLE = "FALSE";
  parameter EMAC_RX16BITCLIENT_ENABLE = "FALSE";
  parameter EMAC_RXFLOWCTRL_ENABLE = "FALSE";
  parameter EMAC_RXHALFDUPLEX = "FALSE";
  parameter EMAC_RXINBANDFCS_ENABLE = "FALSE";
  parameter EMAC_RXJUMBOFRAME_ENABLE = "FALSE";
  parameter EMAC_RXRESET = "FALSE";
  parameter EMAC_RXVLAN_ENABLE = "FALSE";
  parameter EMAC_RX_ENABLE = "TRUE";
  parameter EMAC_SGMII_ENABLE = "FALSE";
  parameter EMAC_SPEED_LSB = "FALSE";
  parameter EMAC_SPEED_MSB = "FALSE";
  parameter EMAC_TX16BITCLIENT_ENABLE = "FALSE";
  parameter EMAC_TXFLOWCTRL_ENABLE = "FALSE";
  parameter EMAC_TXHALFDUPLEX = "FALSE";
  parameter EMAC_TXIFGADJUST_ENABLE = "FALSE";
  parameter EMAC_TXINBANDFCS_ENABLE = "FALSE";
  parameter EMAC_TXJUMBOFRAME_ENABLE = "FALSE";
  parameter EMAC_TXRESET = "FALSE";
  parameter EMAC_TXVLAN_ENABLE = "FALSE";
  parameter EMAC_TX_ENABLE = "TRUE";
  parameter [47:0] EMAC_UNICASTADDR = 48'h000000000000;
  parameter EMAC_UNIDIRECTION_ENABLE = "FALSE";
  parameter EMAC_USECLKEN = "FALSE";
  parameter SIM_VERSION = "1.0";

  localparam in_delay = 50;
  localparam out_delay = 0;
  localparam INCLK_DELAY = 0;
  localparam OUTCLK_DELAY = 0;

  localparam EMACMIITXCLK_DELAY = (EMAC_TX16BITCLIENT_ENABLE == "TRUE") ? 25: INCLK_DELAY;
   
  output DCRHOSTDONEIR;
  output EMACCLIENTANINTERRUPT;
  output EMACCLIENTRXBADFRAME;
  output EMACCLIENTRXCLIENTCLKOUT;
  output EMACCLIENTRXDVLD;
  output EMACCLIENTRXDVLDMSW;
  output EMACCLIENTRXFRAMEDROP;
  output EMACCLIENTRXGOODFRAME;
  output EMACCLIENTRXSTATSBYTEVLD;
  output EMACCLIENTRXSTATSVLD;
  output EMACCLIENTTXACK;
  output EMACCLIENTTXCLIENTCLKOUT;
  output EMACCLIENTTXCOLLISION;
  output EMACCLIENTTXRETRANSMIT;
  output EMACCLIENTTXSTATS;
  output EMACCLIENTTXSTATSBYTEVLD;
  output EMACCLIENTTXSTATSVLD;
  output EMACDCRACK;
  output EMACPHYENCOMMAALIGN;
  output EMACPHYLOOPBACKMSB;
  output EMACPHYMCLKOUT;
  output EMACPHYMDOUT;
  output EMACPHYMDTRI;
  output EMACPHYMGTRXRESET;
  output EMACPHYMGTTXRESET;
  output EMACPHYPOWERDOWN;
  output EMACPHYSYNCACQSTATUS;
  output EMACPHYTXCHARDISPMODE;
  output EMACPHYTXCHARDISPVAL;
  output EMACPHYTXCHARISK;
  output EMACPHYTXCLK;
  output EMACPHYTXEN;
  output EMACPHYTXER;
  output EMACPHYTXGMIIMIICLKOUT;
  output EMACSPEEDIS10100;
  output HOSTMIIMRDY;
  output [0:31] EMACDCRDBUS;
  output [15:0] EMACCLIENTRXD;
  output [31:0] HOSTRDDATA;
  output [6:0] EMACCLIENTRXSTATS;
  output [7:0] EMACPHYTXD;

  input CLIENTEMACDCMLOCKED;
  input CLIENTEMACPAUSEREQ;
  input CLIENTEMACRXCLIENTCLKIN;
  input CLIENTEMACTXCLIENTCLKIN;
  input CLIENTEMACTXDVLD;
  input CLIENTEMACTXDVLDMSW;
  input CLIENTEMACTXFIRSTBYTE;
  input CLIENTEMACTXUNDERRUN;
  input DCREMACCLK;
  input DCREMACENABLE;
  input DCREMACREAD;
  input DCREMACWRITE;
  input HOSTCLK;
  input HOSTMIIMSEL;
  input HOSTREQ;
  input PHYEMACCOL;
  input PHYEMACCRS;
  input PHYEMACGTXCLK;
  input PHYEMACMCLKIN;
  input PHYEMACMDIN;
  input PHYEMACMIITXCLK;
  input PHYEMACRXCHARISCOMMA;
  input PHYEMACRXCHARISK;
  input PHYEMACRXCLK;
  input PHYEMACRXDISPERR;
  input PHYEMACRXDV;
  input PHYEMACRXER;
  input PHYEMACRXNOTINTABLE;
  input PHYEMACRXRUNDISP;
  input PHYEMACSIGNALDET;
  input PHYEMACTXBUFERR;
  input PHYEMACTXGMIIMIICLKIN;
  input RESET;
  input [0:31] DCREMACDBUS;
  input [0:9] DCREMACABUS;
  input [15:0] CLIENTEMACPAUSEVAL;
  input [15:0] CLIENTEMACTXD;
  input [1:0] HOSTOPCODE;
  input [1:0] PHYEMACRXBUFSTATUS;
  input [2:0] PHYEMACRXCLKCORCNT;
  input [31:0] HOSTWRDATA;
  input [4:0] PHYEMACPHYAD;
  input [7:0] CLIENTEMACTXIFGDELAY;
  input [7:0] PHYEMACRXD;
  input [9:0] HOSTADDR;

  reg EMAC_1000BASEX_ENABLE_BINARY;
  reg EMAC_ADDRFILTER_ENABLE_BINARY;
  reg EMAC_BYTEPHY_BINARY;
  reg EMAC_CTRLLENCHECK_DISABLE_BINARY;
  reg EMAC_GTLOOPBACK_BINARY;
  reg EMAC_HOST_ENABLE_BINARY;
  reg EMAC_LTCHECK_DISABLE_BINARY;
  reg EMAC_MDIO_ENABLE_BINARY;
  reg EMAC_MDIO_IGNORE_PHYADZERO_BINARY;
  reg EMAC_PHYINITAUTONEG_ENABLE_BINARY;
  reg EMAC_PHYISOLATE_BINARY;
  reg EMAC_PHYLOOPBACKMSB_BINARY;
  reg EMAC_PHYPOWERDOWN_BINARY;
  reg EMAC_PHYRESET_BINARY;
  reg EMAC_RGMII_ENABLE_BINARY;
  reg EMAC_RX16BITCLIENT_ENABLE_BINARY;
  reg EMAC_RXFLOWCTRL_ENABLE_BINARY;
  reg EMAC_RXHALFDUPLEX_BINARY;
  reg EMAC_RXINBANDFCS_ENABLE_BINARY;
  reg EMAC_RXJUMBOFRAME_ENABLE_BINARY;
  reg EMAC_RXRESET_BINARY;
  reg EMAC_RXVLAN_ENABLE_BINARY;
  reg EMAC_RX_ENABLE_BINARY;
  reg EMAC_SGMII_ENABLE_BINARY;
  reg EMAC_SPEED_LSB_BINARY;
  reg EMAC_SPEED_MSB_BINARY;
  reg EMAC_TX16BITCLIENT_ENABLE_BINARY;
  reg EMAC_TXFLOWCTRL_ENABLE_BINARY;
  reg EMAC_TXHALFDUPLEX_BINARY;
  reg EMAC_TXIFGADJUST_ENABLE_BINARY;
  reg EMAC_TXINBANDFCS_ENABLE_BINARY;
  reg EMAC_TXJUMBOFRAME_ENABLE_BINARY;
  reg EMAC_TXRESET_BINARY;
  reg EMAC_TXVLAN_ENABLE_BINARY;
  reg EMAC_TX_ENABLE_BINARY;
  reg EMAC_UNIDIRECTION_ENABLE_BINARY;
  reg EMAC_USECLKEN_BINARY;
  reg SIM_VERSION_BINARY;
   
  tri0 GSR = glbl.GSR;

  initial begin
    case (EMAC_1000BASEX_ENABLE)
      "FALSE" : EMAC_1000BASEX_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_1000BASEX_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_1000BASEX_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_1000BASEX_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_ADDRFILTER_ENABLE)
      "FALSE" : EMAC_ADDRFILTER_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_ADDRFILTER_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_ADDRFILTER_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_ADDRFILTER_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_BYTEPHY)
      "FALSE" : EMAC_BYTEPHY_BINARY = 1'b0;
      "TRUE" : EMAC_BYTEPHY_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_BYTEPHY on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_BYTEPHY);
        $finish;
      end
    endcase

    case (EMAC_CTRLLENCHECK_DISABLE)
      "FALSE" : EMAC_CTRLLENCHECK_DISABLE_BINARY = 1'b0;
      "TRUE" : EMAC_CTRLLENCHECK_DISABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_CTRLLENCHECK_DISABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_CTRLLENCHECK_DISABLE);
        $finish;
      end
    endcase

    case (EMAC_GTLOOPBACK)
      "FALSE" : EMAC_GTLOOPBACK_BINARY = 1'b0;
      "TRUE" : EMAC_GTLOOPBACK_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_GTLOOPBACK on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_GTLOOPBACK);
        $finish;
      end
    endcase

    case (EMAC_HOST_ENABLE)
      "FALSE" : EMAC_HOST_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_HOST_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_HOST_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_HOST_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_LTCHECK_DISABLE)
      "FALSE" : EMAC_LTCHECK_DISABLE_BINARY = 1'b0;
      "TRUE" : EMAC_LTCHECK_DISABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_LTCHECK_DISABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_LTCHECK_DISABLE);
        $finish;
      end
    endcase

    case (EMAC_MDIO_ENABLE)
      "FALSE" : EMAC_MDIO_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_MDIO_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_MDIO_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_MDIO_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_MDIO_IGNORE_PHYADZERO)
      "FALSE" : EMAC_MDIO_IGNORE_PHYADZERO_BINARY = 1'b0;
      "TRUE" : EMAC_MDIO_IGNORE_PHYADZERO_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_MDIO_IGNORE_PHYADZERO on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_MDIO_IGNORE_PHYADZERO);
        $finish;
      end
    endcase

    case (EMAC_PHYINITAUTONEG_ENABLE)
      "FALSE" : EMAC_PHYINITAUTONEG_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_PHYINITAUTONEG_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_PHYINITAUTONEG_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_PHYINITAUTONEG_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_PHYISOLATE)
      "FALSE" : EMAC_PHYISOLATE_BINARY = 1'b0;
      "TRUE" : EMAC_PHYISOLATE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_PHYISOLATE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_PHYISOLATE);
        $finish;
      end
    endcase

    case (EMAC_PHYLOOPBACKMSB)
      "FALSE" : EMAC_PHYLOOPBACKMSB_BINARY = 1'b0;
      "TRUE" : EMAC_PHYLOOPBACKMSB_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_PHYLOOPBACKMSB on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_PHYLOOPBACKMSB);
        $finish;
      end
    endcase

    case (EMAC_PHYPOWERDOWN)
      "FALSE" : EMAC_PHYPOWERDOWN_BINARY = 1'b0;
      "TRUE" : EMAC_PHYPOWERDOWN_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_PHYPOWERDOWN on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_PHYPOWERDOWN);
        $finish;
      end
    endcase

    case (EMAC_PHYRESET)
      "FALSE" : EMAC_PHYRESET_BINARY = 1'b0;
      "TRUE" : EMAC_PHYRESET_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_PHYRESET on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_PHYRESET);
        $finish;
      end
    endcase

    case (EMAC_RGMII_ENABLE)
      "FALSE" : EMAC_RGMII_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_RGMII_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_RGMII_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_RGMII_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_RX16BITCLIENT_ENABLE)
      "FALSE" : EMAC_RX16BITCLIENT_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_RX16BITCLIENT_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_RX16BITCLIENT_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_RX16BITCLIENT_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_RXFLOWCTRL_ENABLE)
      "FALSE" : EMAC_RXFLOWCTRL_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_RXFLOWCTRL_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_RXFLOWCTRL_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_RXFLOWCTRL_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_RXHALFDUPLEX)
      "FALSE" : EMAC_RXHALFDUPLEX_BINARY = 1'b0;
      "TRUE" : EMAC_RXHALFDUPLEX_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_RXHALFDUPLEX on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_RXHALFDUPLEX);
        $finish;
      end
    endcase

    case (EMAC_RXINBANDFCS_ENABLE)
      "FALSE" : EMAC_RXINBANDFCS_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_RXINBANDFCS_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_RXINBANDFCS_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_RXINBANDFCS_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_RXJUMBOFRAME_ENABLE)
      "FALSE" : EMAC_RXJUMBOFRAME_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_RXJUMBOFRAME_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_RXJUMBOFRAME_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_RXJUMBOFRAME_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_RXRESET)
      "FALSE" : EMAC_RXRESET_BINARY = 1'b0;
      "TRUE" : EMAC_RXRESET_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_RXRESET on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_RXRESET);
        $finish;
      end
    endcase

    case (EMAC_RXVLAN_ENABLE)
      "FALSE" : EMAC_RXVLAN_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_RXVLAN_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_RXVLAN_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_RXVLAN_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_RX_ENABLE)
      "FALSE" : EMAC_RX_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_RX_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_RX_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_RX_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_SGMII_ENABLE)
      "FALSE" : EMAC_SGMII_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_SGMII_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_SGMII_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_SGMII_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_SPEED_LSB)
      "FALSE" : EMAC_SPEED_LSB_BINARY = 1'b0;
      "TRUE" : EMAC_SPEED_LSB_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_SPEED_LSB on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_SPEED_LSB);
        $finish;
      end
    endcase

    case (EMAC_SPEED_MSB)
      "FALSE" : EMAC_SPEED_MSB_BINARY = 1'b0;
      "TRUE" : EMAC_SPEED_MSB_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_SPEED_MSB on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_SPEED_MSB);
        $finish;
      end
    endcase

    case (EMAC_TX16BITCLIENT_ENABLE)
      "FALSE" : EMAC_TX16BITCLIENT_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_TX16BITCLIENT_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_TX16BITCLIENT_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_TX16BITCLIENT_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_TXFLOWCTRL_ENABLE)
      "FALSE" : EMAC_TXFLOWCTRL_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_TXFLOWCTRL_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_TXFLOWCTRL_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_TXFLOWCTRL_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_TXHALFDUPLEX)
      "FALSE" : EMAC_TXHALFDUPLEX_BINARY = 1'b0;
      "TRUE" : EMAC_TXHALFDUPLEX_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_TXHALFDUPLEX on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_TXHALFDUPLEX);
        $finish;
      end
    endcase

    case (EMAC_TXIFGADJUST_ENABLE)
      "FALSE" : EMAC_TXIFGADJUST_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_TXIFGADJUST_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_TXIFGADJUST_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_TXIFGADJUST_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_TXINBANDFCS_ENABLE)
      "FALSE" : EMAC_TXINBANDFCS_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_TXINBANDFCS_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_TXINBANDFCS_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_TXINBANDFCS_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_TXJUMBOFRAME_ENABLE)
      "FALSE" : EMAC_TXJUMBOFRAME_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_TXJUMBOFRAME_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_TXJUMBOFRAME_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_TXJUMBOFRAME_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_TXRESET)
      "FALSE" : EMAC_TXRESET_BINARY = 1'b0;
      "TRUE" : EMAC_TXRESET_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_TXRESET on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_TXRESET);
        $finish;
      end
    endcase

    case (EMAC_TXVLAN_ENABLE)
      "FALSE" : EMAC_TXVLAN_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_TXVLAN_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_TXVLAN_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_TXVLAN_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_TX_ENABLE)
      "FALSE" : EMAC_TX_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_TX_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_TX_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_TX_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_UNIDIRECTION_ENABLE)
      "FALSE" : EMAC_UNIDIRECTION_ENABLE_BINARY = 1'b0;
      "TRUE" : EMAC_UNIDIRECTION_ENABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_UNIDIRECTION_ENABLE on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_UNIDIRECTION_ENABLE);
        $finish;
      end
    endcase

    case (EMAC_USECLKEN)
      "FALSE" : EMAC_USECLKEN_BINARY = 1'b0;
      "TRUE" : EMAC_USECLKEN_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute EMAC_USECLKEN on TEMAC_SINGLE instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EMAC_USECLKEN);
        $finish;
      end
    endcase

  end

  wire [0:31] delay_EMACDCRDBUS;
  wire [15:0] delay_EMACCLIENTRXD;
  wire [31:0] delay_HOSTRDDATA;
  wire [6:0] delay_EMACCLIENTRXSTATS;
  wire [7:0] delay_EMACPHYTXD;
  wire delay_DCRHOSTDONEIR;
  wire delay_EMACCLIENTANINTERRUPT;
  wire delay_EMACCLIENTRXBADFRAME;
  wire delay_EMACCLIENTRXCLIENTCLKOUT;
  wire delay_EMACCLIENTRXDVLD;
  wire delay_EMACCLIENTRXDVLDMSW;
  wire delay_EMACCLIENTRXFRAMEDROP;
  wire delay_EMACCLIENTRXGOODFRAME;
  wire delay_EMACCLIENTRXSTATSBYTEVLD;
  wire delay_EMACCLIENTRXSTATSVLD;
  wire delay_EMACCLIENTTXACK;
  wire delay_EMACCLIENTTXCLIENTCLKOUT;
  wire delay_EMACCLIENTTXCOLLISION;
  wire delay_EMACCLIENTTXRETRANSMIT;
  wire delay_EMACCLIENTTXSTATS;
  wire delay_EMACCLIENTTXSTATSBYTEVLD;
  wire delay_EMACCLIENTTXSTATSVLD;
  wire delay_EMACDCRACK;
  wire delay_EMACPHYENCOMMAALIGN;
  wire delay_EMACPHYLOOPBACKMSB;
  wire delay_EMACPHYMCLKOUT;
  wire delay_EMACPHYMDOUT;
  wire delay_EMACPHYMDTRI;
  wire delay_EMACPHYMGTRXRESET;
  wire delay_EMACPHYMGTTXRESET;
  wire delay_EMACPHYPOWERDOWN;
  wire delay_EMACPHYSYNCACQSTATUS;
  wire delay_EMACPHYTXCHARDISPMODE;
  wire delay_EMACPHYTXCHARDISPVAL;
  wire delay_EMACPHYTXCHARISK;
  wire delay_EMACPHYTXCLK;
  wire delay_EMACPHYTXEN;
  wire delay_EMACPHYTXER;
  wire delay_EMACPHYTXGMIIMIICLKOUT;
  wire delay_EMACSPEEDIS10100;
  wire delay_HOSTMIIMRDY;

  wire [0:31] delay_DCREMACDBUS;
  wire [0:9] delay_DCREMACABUS;
  wire [15:0] delay_CLIENTEMACPAUSEVAL;
  wire [15:0] delay_CLIENTEMACTXD;
  wire [1:0] delay_HOSTOPCODE;
  wire [1:0] delay_PHYEMACRXBUFSTATUS;
  wire [2:0] delay_PHYEMACRXCLKCORCNT;
  wire [31:0] delay_HOSTWRDATA;
  wire [4:0] delay_PHYEMACPHYAD;
  wire [7:0] delay_CLIENTEMACTXIFGDELAY;
  wire [7:0] delay_PHYEMACRXD;
  wire [9:0] delay_HOSTADDR;
  wire delay_CLIENTEMACDCMLOCKED;
  wire delay_CLIENTEMACPAUSEREQ;
  wire delay_CLIENTEMACRXCLIENTCLKIN;
  wire delay_CLIENTEMACTXCLIENTCLKIN;
  wire delay_CLIENTEMACTXDVLD;
  wire delay_CLIENTEMACTXDVLDMSW;
  wire delay_CLIENTEMACTXFIRSTBYTE;
  wire delay_CLIENTEMACTXUNDERRUN;
  wire delay_DCREMACCLK;
  wire delay_DCREMACENABLE;
  wire delay_DCREMACREAD;
  wire delay_DCREMACWRITE;
  wire delay_HOSTCLK;
  wire delay_HOSTMIIMSEL;
  wire delay_HOSTREQ;
  wire delay_PHYEMACCOL;
  wire delay_PHYEMACCRS;
  wire delay_PHYEMACGTXCLK;
  wire delay_PHYEMACMCLKIN;
  wire delay_PHYEMACMDIN;
  wire delay_PHYEMACMIITXCLK;
  wire delay_PHYEMACRXCHARISCOMMA;
  wire delay_PHYEMACRXCHARISK;
  wire delay_PHYEMACRXCLK;
  wire delay_PHYEMACRXDISPERR;
  wire delay_PHYEMACRXDV;
  wire delay_PHYEMACRXER;
  wire delay_PHYEMACRXNOTINTABLE;
  wire delay_PHYEMACRXRUNDISP;
  wire delay_PHYEMACSIGNALDET;
  wire delay_PHYEMACTXBUFERR;
  wire delay_PHYEMACTXGMIIMIICLKIN;
  wire delay_RESET;


  assign #(out_delay) DCRHOSTDONEIR = delay_DCRHOSTDONEIR;
  assign #(out_delay) EMACCLIENTANINTERRUPT = delay_EMACCLIENTANINTERRUPT;
  assign #(out_delay) EMACCLIENTRXBADFRAME = delay_EMACCLIENTRXBADFRAME;
  assign #(out_delay) EMACCLIENTRXCLIENTCLKOUT = delay_EMACCLIENTRXCLIENTCLKOUT;
  assign #(out_delay) EMACCLIENTRXD = delay_EMACCLIENTRXD;
  assign #(out_delay) EMACCLIENTRXDVLD = delay_EMACCLIENTRXDVLD;
  assign #(out_delay) EMACCLIENTRXDVLDMSW = delay_EMACCLIENTRXDVLDMSW;
  assign #(out_delay) EMACCLIENTRXFRAMEDROP = delay_EMACCLIENTRXFRAMEDROP;
  assign #(out_delay) EMACCLIENTRXGOODFRAME = delay_EMACCLIENTRXGOODFRAME;
  assign #(out_delay) EMACCLIENTRXSTATS = delay_EMACCLIENTRXSTATS;
  assign #(out_delay) EMACCLIENTRXSTATSBYTEVLD = delay_EMACCLIENTRXSTATSBYTEVLD;
  assign #(out_delay) EMACCLIENTRXSTATSVLD = delay_EMACCLIENTRXSTATSVLD;
  assign #(out_delay) EMACCLIENTTXACK = delay_EMACCLIENTTXACK;
  assign #(out_delay) EMACCLIENTTXCLIENTCLKOUT = delay_EMACCLIENTTXCLIENTCLKOUT;
  assign #(out_delay) EMACCLIENTTXCOLLISION = delay_EMACCLIENTTXCOLLISION;
  assign #(out_delay) EMACCLIENTTXRETRANSMIT = delay_EMACCLIENTTXRETRANSMIT;
  assign #(out_delay) EMACCLIENTTXSTATS = delay_EMACCLIENTTXSTATS;
  assign #(out_delay) EMACCLIENTTXSTATSBYTEVLD = delay_EMACCLIENTTXSTATSBYTEVLD;
  assign #(out_delay) EMACCLIENTTXSTATSVLD = delay_EMACCLIENTTXSTATSVLD;
  assign #(out_delay) EMACDCRACK = delay_EMACDCRACK;
  assign #(out_delay) EMACDCRDBUS = delay_EMACDCRDBUS;
  assign #(out_delay) EMACPHYENCOMMAALIGN = delay_EMACPHYENCOMMAALIGN;
  assign #(out_delay) EMACPHYLOOPBACKMSB = delay_EMACPHYLOOPBACKMSB;
  assign #(out_delay) EMACPHYMCLKOUT = delay_EMACPHYMCLKOUT;
  assign #(out_delay) EMACPHYMDOUT = delay_EMACPHYMDOUT;
  assign #(out_delay) EMACPHYMDTRI = delay_EMACPHYMDTRI;
  assign #(out_delay) EMACPHYMGTRXRESET = delay_EMACPHYMGTRXRESET;
  assign #(out_delay) EMACPHYMGTTXRESET = delay_EMACPHYMGTTXRESET;
  assign #(out_delay) EMACPHYPOWERDOWN = delay_EMACPHYPOWERDOWN;
  assign #(out_delay) EMACPHYSYNCACQSTATUS = delay_EMACPHYSYNCACQSTATUS;
  assign #(out_delay) EMACPHYTXCHARDISPMODE = delay_EMACPHYTXCHARDISPMODE;
  assign #(out_delay) EMACPHYTXCHARDISPVAL = delay_EMACPHYTXCHARDISPVAL;
  assign #(out_delay) EMACPHYTXCHARISK = delay_EMACPHYTXCHARISK;
  assign #(out_delay) EMACPHYTXCLK = delay_EMACPHYTXCLK;
  assign #(out_delay) EMACPHYTXD = delay_EMACPHYTXD;
  assign #(out_delay) EMACPHYTXEN = delay_EMACPHYTXEN;
  assign #(out_delay) EMACPHYTXER = delay_EMACPHYTXER;
  assign #(out_delay) EMACPHYTXGMIIMIICLKOUT = delay_EMACPHYTXGMIIMIICLKOUT;
  assign #(out_delay) EMACSPEEDIS10100 = delay_EMACSPEEDIS10100;
  assign #(out_delay) HOSTMIIMRDY = delay_HOSTMIIMRDY;
  assign #(out_delay) HOSTRDDATA = delay_HOSTRDDATA;


  assign #(INCLK_DELAY) delay_CLIENTEMACRXCLIENTCLKIN = CLIENTEMACRXCLIENTCLKIN;
  assign #(INCLK_DELAY) delay_CLIENTEMACTXCLIENTCLKIN = CLIENTEMACTXCLIENTCLKIN;
  assign #(INCLK_DELAY) delay_DCREMACCLK = DCREMACCLK;
  assign #(INCLK_DELAY) delay_HOSTCLK = HOSTCLK;
  assign #(INCLK_DELAY) delay_PHYEMACGTXCLK = PHYEMACGTXCLK;
  assign #(INCLK_DELAY) delay_PHYEMACMCLKIN = PHYEMACMCLKIN;
  assign #(EMACMIITXCLK_DELAY) delay_PHYEMACMIITXCLK = PHYEMACMIITXCLK;
  assign #(INCLK_DELAY) delay_PHYEMACRXCLK = PHYEMACRXCLK;
  assign #(INCLK_DELAY) delay_PHYEMACTXGMIIMIICLKIN = PHYEMACTXGMIIMIICLKIN;

  assign #(in_delay) delay_CLIENTEMACDCMLOCKED = CLIENTEMACDCMLOCKED;
  assign #(in_delay) delay_CLIENTEMACPAUSEREQ = CLIENTEMACPAUSEREQ;
  assign #(in_delay) delay_CLIENTEMACPAUSEVAL = CLIENTEMACPAUSEVAL;
  assign #(in_delay) delay_CLIENTEMACTXD = CLIENTEMACTXD;
  assign #(in_delay) delay_CLIENTEMACTXDVLD = CLIENTEMACTXDVLD;
  assign #(in_delay) delay_CLIENTEMACTXDVLDMSW = CLIENTEMACTXDVLDMSW;
  assign #(in_delay) delay_CLIENTEMACTXFIRSTBYTE = CLIENTEMACTXFIRSTBYTE;
  assign #(in_delay) delay_CLIENTEMACTXIFGDELAY = CLIENTEMACTXIFGDELAY;
  assign #(in_delay) delay_CLIENTEMACTXUNDERRUN = CLIENTEMACTXUNDERRUN;
  assign #(in_delay) delay_DCREMACABUS = DCREMACABUS;
  assign #(in_delay) delay_DCREMACDBUS = DCREMACDBUS;
  assign #(in_delay) delay_DCREMACENABLE = DCREMACENABLE;
  assign #(in_delay) delay_DCREMACREAD = DCREMACREAD;
  assign #(in_delay) delay_DCREMACWRITE = DCREMACWRITE;
  assign #(in_delay) delay_HOSTADDR = HOSTADDR;
  assign #(in_delay) delay_HOSTMIIMSEL = HOSTMIIMSEL;
  assign #(in_delay) delay_HOSTOPCODE = HOSTOPCODE;
  assign #(in_delay) delay_HOSTREQ = HOSTREQ;
  assign #(in_delay) delay_HOSTWRDATA = HOSTWRDATA;
  assign #(in_delay) delay_PHYEMACCOL = PHYEMACCOL;
  assign #(in_delay) delay_PHYEMACCRS = PHYEMACCRS;
  assign #(in_delay) delay_PHYEMACMDIN = PHYEMACMDIN;
  assign #(in_delay) delay_PHYEMACPHYAD = PHYEMACPHYAD;
  assign #(in_delay) delay_PHYEMACRXBUFSTATUS = PHYEMACRXBUFSTATUS;
  assign #(in_delay) delay_PHYEMACRXCHARISCOMMA = PHYEMACRXCHARISCOMMA;
  assign #(in_delay) delay_PHYEMACRXCHARISK = PHYEMACRXCHARISK;
  assign #(in_delay) delay_PHYEMACRXCLKCORCNT = PHYEMACRXCLKCORCNT;
  assign #(in_delay) delay_PHYEMACRXD = PHYEMACRXD;
  assign #(in_delay) delay_PHYEMACRXDISPERR = PHYEMACRXDISPERR;
  assign #(in_delay) delay_PHYEMACRXDV = PHYEMACRXDV;
  assign #(in_delay) delay_PHYEMACRXER = PHYEMACRXER;
  assign #(in_delay) delay_PHYEMACRXNOTINTABLE = PHYEMACRXNOTINTABLE;
  assign #(in_delay) delay_PHYEMACRXRUNDISP = PHYEMACRXRUNDISP;
  assign #(in_delay) delay_PHYEMACSIGNALDET = PHYEMACSIGNALDET;
  assign #(in_delay) delay_PHYEMACTXBUFERR = PHYEMACTXBUFERR;
  assign #(in_delay) delay_RESET = RESET;

  B_TEMAC_SINGLE #(
    .EMAC_1000BASEX_ENABLE (EMAC_1000BASEX_ENABLE),
    .EMAC_ADDRFILTER_ENABLE (EMAC_ADDRFILTER_ENABLE),
    .EMAC_BYTEPHY (EMAC_BYTEPHY),
    .EMAC_CTRLLENCHECK_DISABLE (EMAC_CTRLLENCHECK_DISABLE),
    .EMAC_DCRBASEADDR (EMAC_DCRBASEADDR),
    .EMAC_GTLOOPBACK (EMAC_GTLOOPBACK),
    .EMAC_HOST_ENABLE (EMAC_HOST_ENABLE),
    .EMAC_LINKTIMERVAL (EMAC_LINKTIMERVAL),
    .EMAC_LTCHECK_DISABLE (EMAC_LTCHECK_DISABLE),
    .EMAC_MDIO_ENABLE (EMAC_MDIO_ENABLE),
    .EMAC_MDIO_IGNORE_PHYADZERO (EMAC_MDIO_IGNORE_PHYADZERO),
    .EMAC_PAUSEADDR (EMAC_PAUSEADDR),
    .EMAC_PHYINITAUTONEG_ENABLE (EMAC_PHYINITAUTONEG_ENABLE),
    .EMAC_PHYISOLATE (EMAC_PHYISOLATE),
    .EMAC_PHYLOOPBACKMSB (EMAC_PHYLOOPBACKMSB),
    .EMAC_PHYPOWERDOWN (EMAC_PHYPOWERDOWN),
    .EMAC_PHYRESET (EMAC_PHYRESET),
    .EMAC_RGMII_ENABLE (EMAC_RGMII_ENABLE),
    .EMAC_RX16BITCLIENT_ENABLE (EMAC_RX16BITCLIENT_ENABLE),
    .EMAC_RXFLOWCTRL_ENABLE (EMAC_RXFLOWCTRL_ENABLE),
    .EMAC_RXHALFDUPLEX (EMAC_RXHALFDUPLEX),
    .EMAC_RXINBANDFCS_ENABLE (EMAC_RXINBANDFCS_ENABLE),
    .EMAC_RXJUMBOFRAME_ENABLE (EMAC_RXJUMBOFRAME_ENABLE),
    .EMAC_RXRESET (EMAC_RXRESET),
    .EMAC_RXVLAN_ENABLE (EMAC_RXVLAN_ENABLE),
    .EMAC_RX_ENABLE (EMAC_RX_ENABLE),
    .EMAC_SGMII_ENABLE (EMAC_SGMII_ENABLE),
    .EMAC_SPEED_LSB (EMAC_SPEED_LSB),
    .EMAC_SPEED_MSB (EMAC_SPEED_MSB),
    .EMAC_TX16BITCLIENT_ENABLE (EMAC_TX16BITCLIENT_ENABLE),
    .EMAC_TXFLOWCTRL_ENABLE (EMAC_TXFLOWCTRL_ENABLE),
    .EMAC_TXHALFDUPLEX (EMAC_TXHALFDUPLEX),
    .EMAC_TXIFGADJUST_ENABLE (EMAC_TXIFGADJUST_ENABLE),
    .EMAC_TXINBANDFCS_ENABLE (EMAC_TXINBANDFCS_ENABLE),
    .EMAC_TXJUMBOFRAME_ENABLE (EMAC_TXJUMBOFRAME_ENABLE),
    .EMAC_TXRESET (EMAC_TXRESET),
    .EMAC_TXVLAN_ENABLE (EMAC_TXVLAN_ENABLE),
    .EMAC_TX_ENABLE (EMAC_TX_ENABLE),
    .EMAC_UNICASTADDR (EMAC_UNICASTADDR),
    .EMAC_UNIDIRECTION_ENABLE (EMAC_UNIDIRECTION_ENABLE),
    .EMAC_USECLKEN (EMAC_USECLKEN))


    B_TEMAC_SINGLE_INST(
    .DCRHOSTDONEIR (delay_DCRHOSTDONEIR),
    .EMACCLIENTANINTERRUPT (delay_EMACCLIENTANINTERRUPT),
    .EMACCLIENTRXBADFRAME (delay_EMACCLIENTRXBADFRAME),
    .EMACCLIENTRXCLIENTCLKOUT (delay_EMACCLIENTRXCLIENTCLKOUT),
    .EMACCLIENTRXD (delay_EMACCLIENTRXD),
    .EMACCLIENTRXDVLD (delay_EMACCLIENTRXDVLD),
    .EMACCLIENTRXDVLDMSW (delay_EMACCLIENTRXDVLDMSW),
    .EMACCLIENTRXFRAMEDROP (delay_EMACCLIENTRXFRAMEDROP),
    .EMACCLIENTRXGOODFRAME (delay_EMACCLIENTRXGOODFRAME),
    .EMACCLIENTRXSTATS (delay_EMACCLIENTRXSTATS),
    .EMACCLIENTRXSTATSBYTEVLD (delay_EMACCLIENTRXSTATSBYTEVLD),
    .EMACCLIENTRXSTATSVLD (delay_EMACCLIENTRXSTATSVLD),
    .EMACCLIENTTXACK (delay_EMACCLIENTTXACK),
    .EMACCLIENTTXCLIENTCLKOUT (delay_EMACCLIENTTXCLIENTCLKOUT),
    .EMACCLIENTTXCOLLISION (delay_EMACCLIENTTXCOLLISION),
    .EMACCLIENTTXRETRANSMIT (delay_EMACCLIENTTXRETRANSMIT),
    .EMACCLIENTTXSTATS (delay_EMACCLIENTTXSTATS),
    .EMACCLIENTTXSTATSBYTEVLD (delay_EMACCLIENTTXSTATSBYTEVLD),
    .EMACCLIENTTXSTATSVLD (delay_EMACCLIENTTXSTATSVLD),
    .EMACDCRACK (delay_EMACDCRACK),
    .EMACDCRDBUS (delay_EMACDCRDBUS),
    .EMACPHYENCOMMAALIGN (delay_EMACPHYENCOMMAALIGN),
    .EMACPHYLOOPBACKMSB (delay_EMACPHYLOOPBACKMSB),
    .EMACPHYMCLKOUT (delay_EMACPHYMCLKOUT),
    .EMACPHYMDOUT (delay_EMACPHYMDOUT),
    .EMACPHYMDTRI (delay_EMACPHYMDTRI),
    .EMACPHYMGTRXRESET (delay_EMACPHYMGTRXRESET),
    .EMACPHYMGTTXRESET (delay_EMACPHYMGTTXRESET),
    .EMACPHYPOWERDOWN (delay_EMACPHYPOWERDOWN),
    .EMACPHYSYNCACQSTATUS (delay_EMACPHYSYNCACQSTATUS),
    .EMACPHYTXCHARDISPMODE (delay_EMACPHYTXCHARDISPMODE),
    .EMACPHYTXCHARDISPVAL (delay_EMACPHYTXCHARDISPVAL),
    .EMACPHYTXCHARISK (delay_EMACPHYTXCHARISK),
    .EMACPHYTXCLK (delay_EMACPHYTXCLK),
    .EMACPHYTXD (delay_EMACPHYTXD),
    .EMACPHYTXEN (delay_EMACPHYTXEN),
    .EMACPHYTXER (delay_EMACPHYTXER),
    .EMACPHYTXGMIIMIICLKOUT (delay_EMACPHYTXGMIIMIICLKOUT),
    .EMACSPEEDIS10100 (delay_EMACSPEEDIS10100),
    .HOSTMIIMRDY (delay_HOSTMIIMRDY),
    .HOSTRDDATA (delay_HOSTRDDATA),
    .CLIENTEMACDCMLOCKED (delay_CLIENTEMACDCMLOCKED),
    .CLIENTEMACPAUSEREQ (delay_CLIENTEMACPAUSEREQ),
    .CLIENTEMACPAUSEVAL (delay_CLIENTEMACPAUSEVAL),
    .CLIENTEMACRXCLIENTCLKIN (delay_CLIENTEMACRXCLIENTCLKIN),
    .CLIENTEMACTXCLIENTCLKIN (delay_CLIENTEMACTXCLIENTCLKIN),
    .CLIENTEMACTXD (delay_CLIENTEMACTXD),
    .CLIENTEMACTXDVLD (delay_CLIENTEMACTXDVLD),
    .CLIENTEMACTXDVLDMSW (delay_CLIENTEMACTXDVLDMSW),
    .CLIENTEMACTXFIRSTBYTE (delay_CLIENTEMACTXFIRSTBYTE),
    .CLIENTEMACTXIFGDELAY (delay_CLIENTEMACTXIFGDELAY),
    .CLIENTEMACTXUNDERRUN (delay_CLIENTEMACTXUNDERRUN),
    .DCREMACABUS (delay_DCREMACABUS),
    .DCREMACCLK (delay_DCREMACCLK),
    .DCREMACDBUS (delay_DCREMACDBUS),
    .DCREMACENABLE (delay_DCREMACENABLE),
    .DCREMACREAD (delay_DCREMACREAD),
    .DCREMACWRITE (delay_DCREMACWRITE),
    .HOSTADDR (delay_HOSTADDR),
    .HOSTCLK (delay_HOSTCLK),
    .HOSTMIIMSEL (delay_HOSTMIIMSEL),
    .HOSTOPCODE (delay_HOSTOPCODE),
    .HOSTREQ (delay_HOSTREQ),
    .HOSTWRDATA (delay_HOSTWRDATA),
    .PHYEMACCOL (delay_PHYEMACCOL),
    .PHYEMACCRS (delay_PHYEMACCRS),
    .PHYEMACGTXCLK (delay_PHYEMACGTXCLK),
    .PHYEMACMCLKIN (delay_PHYEMACMCLKIN),
    .PHYEMACMDIN (delay_PHYEMACMDIN),
    .PHYEMACMIITXCLK (delay_PHYEMACMIITXCLK),
    .PHYEMACPHYAD (delay_PHYEMACPHYAD),
    .PHYEMACRXBUFSTATUS (delay_PHYEMACRXBUFSTATUS),
    .PHYEMACRXCHARISCOMMA (delay_PHYEMACRXCHARISCOMMA),
    .PHYEMACRXCHARISK (delay_PHYEMACRXCHARISK),
    .PHYEMACRXCLK (delay_PHYEMACRXCLK),
    .PHYEMACRXCLKCORCNT (delay_PHYEMACRXCLKCORCNT),
    .PHYEMACRXD (delay_PHYEMACRXD),
    .PHYEMACRXDISPERR (delay_PHYEMACRXDISPERR),
    .PHYEMACRXDV (delay_PHYEMACRXDV),
    .PHYEMACRXER (delay_PHYEMACRXER),
    .PHYEMACRXNOTINTABLE (delay_PHYEMACRXNOTINTABLE),
    .PHYEMACRXRUNDISP (delay_PHYEMACRXRUNDISP),
    .PHYEMACSIGNALDET (delay_PHYEMACSIGNALDET),
    .PHYEMACTXBUFERR (delay_PHYEMACTXBUFERR),
    .PHYEMACTXGMIIMIICLKIN (delay_PHYEMACTXGMIIMIICLKIN),
    .RESET (delay_RESET),
    .GSR(GSR)
  );

  specify
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXBADFRAME) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXCLIENTCLKOUT) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXDVLD) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXDVLDMSW) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[0]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[10]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[11]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[12]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[13]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[14]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[15]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[1]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[2]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[3]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[4]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[5]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[6]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[7]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[8]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXD[9]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXFRAMEDROP) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXGOODFRAME) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXSTATSBYTEVLD) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXSTATSVLD) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXSTATS[0]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXSTATS[1]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXSTATS[2]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXSTATS[3]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXSTATS[4]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXSTATS[5]) = (100, 100);
    ( CLIENTEMACRXCLIENTCLKIN => EMACCLIENTRXSTATS[6]) = (100, 100);
    ( CLIENTEMACTXCLIENTCLKIN => EMACCLIENTTXACK) = (100, 100);
    ( CLIENTEMACTXCLIENTCLKIN => EMACCLIENTTXCOLLISION) = (100, 100);
    ( CLIENTEMACTXCLIENTCLKIN => EMACCLIENTTXRETRANSMIT) = (100, 100);
    ( CLIENTEMACTXCLIENTCLKIN => EMACCLIENTTXSTATS) = (100, 100);
    ( CLIENTEMACTXCLIENTCLKIN => EMACCLIENTTXSTATSBYTEVLD) = (100, 100);
    ( CLIENTEMACTXCLIENTCLKIN => EMACCLIENTTXSTATSVLD) = (100, 100);
    ( DCREMACCLK => DCRHOSTDONEIR) = (100, 100);
    ( DCREMACCLK => EMACDCRACK) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[0]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[10]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[11]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[12]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[13]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[14]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[15]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[16]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[17]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[18]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[19]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[1]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[20]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[21]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[22]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[23]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[24]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[25]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[26]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[27]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[28]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[29]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[2]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[30]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[31]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[3]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[4]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[5]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[6]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[7]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[8]) = (100, 100);
    ( DCREMACCLK => EMACDCRDBUS[9]) = (100, 100);
    ( HOSTCLK => EMACPHYMCLKOUT) = (100, 100);
    ( HOSTCLK => EMACPHYMDOUT) = (100, 100);
    ( HOSTCLK => EMACPHYMDTRI) = (100, 100);
    ( HOSTCLK => EMACSPEEDIS10100) = (100, 100);
    ( HOSTCLK => HOSTMIIMRDY) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[0]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[10]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[11]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[12]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[13]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[14]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[15]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[16]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[17]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[18]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[19]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[1]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[20]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[21]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[22]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[23]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[24]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[25]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[26]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[27]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[28]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[29]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[2]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[30]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[31]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[3]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[4]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[5]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[6]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[7]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[8]) = (100, 100);
    ( HOSTCLK => HOSTRDDATA[9]) = (100, 100);
    ( PHYEMACGTXCLK => EMACCLIENTANINTERRUPT) = (100, 100);
    ( PHYEMACGTXCLK => EMACCLIENTRXCLIENTCLKOUT) = (100, 100);
    ( PHYEMACGTXCLK => EMACCLIENTTXCLIENTCLKOUT) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYENCOMMAALIGN) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYLOOPBACKMSB) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYMGTRXRESET) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYMGTTXRESET) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYPOWERDOWN) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYSYNCACQSTATUS) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXCHARDISPMODE) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXCHARDISPVAL) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXCHARISK) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXCLK) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXD[0]) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXD[1]) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXD[2]) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXD[3]) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXD[4]) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXD[5]) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXD[6]) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXD[7]) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXEN) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXER) = (100, 100);
    ( PHYEMACGTXCLK => EMACPHYTXGMIIMIICLKOUT) = (100, 100);
    ( PHYEMACMCLKIN => EMACPHYMCLKOUT) = (100, 100);
    ( PHYEMACMCLKIN => EMACPHYMDOUT) = (100, 100);
    ( PHYEMACMCLKIN => EMACPHYMDTRI) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXBADFRAME) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXCLIENTCLKOUT) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXDVLD) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXDVLDMSW) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[0]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[10]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[11]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[12]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[13]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[14]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[15]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[1]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[2]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[3]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[4]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[5]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[6]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[7]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[8]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXD[9]) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXFRAMEDROP) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTRXGOODFRAME) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTTXACK) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTTXCLIENTCLKOUT) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTTXCOLLISION) = (100, 100);
    ( PHYEMACMIITXCLK => EMACCLIENTTXRETRANSMIT) = (100, 100);
    ( PHYEMACMIITXCLK => EMACPHYTXGMIIMIICLKOUT) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXBADFRAME) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXCLIENTCLKOUT) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXDVLD) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXDVLDMSW) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[0]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[10]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[11]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[12]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[13]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[14]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[15]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[1]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[2]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[3]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[4]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[5]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[6]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[7]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[8]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXD[9]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXFRAMEDROP) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXGOODFRAME) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXSTATSBYTEVLD) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXSTATSVLD) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXSTATS[0]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXSTATS[1]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXSTATS[2]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXSTATS[3]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXSTATS[4]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXSTATS[5]) = (100, 100);
    ( PHYEMACRXCLK => EMACCLIENTRXSTATS[6]) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACCLIENTTXACK) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACCLIENTTXCLIENTCLKOUT) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACCLIENTTXCOLLISION) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACCLIENTTXRETRANSMIT) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACCLIENTTXSTATS) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACCLIENTTXSTATSBYTEVLD) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACCLIENTTXSTATSVLD) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYSYNCACQSTATUS) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXCHARDISPMODE) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXCHARDISPVAL) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXCHARISK) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXCLK) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXD[0]) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXD[1]) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXD[2]) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXD[3]) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXD[4]) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXD[5]) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXD[6]) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXD[7]) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXEN) = (100, 100);
    ( PHYEMACTXGMIIMIICLKIN => EMACPHYTXER) = (100, 100);

    specparam PATHPULSE$ = 0;
  endspecify
endmodule
