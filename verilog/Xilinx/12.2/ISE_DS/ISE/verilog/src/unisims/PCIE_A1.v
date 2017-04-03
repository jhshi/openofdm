// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/stan/PCIE_A1.v,v 1.9 2010/02/03 23:42:05 robh Exp $
///////////////////////////////////////////////////////
//  Copyright (c) 2009 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : PCI Express Secure IP Functional Wrapper
//  /  /                      
// /__/   /\       Filename    : PCIE_A1.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:      Date:  Comment
//       1.0:  08/21/08:  Initial version.
//       1.1:  11/24/08:  Updates to include secureip
//       1.2:  01/22/09:  Updates for NCSIM and VCS
//       1.3:  01/29/09:  CR503397 remove NCELAB work arounds
//       1.4:  02/03/10:  525925 add skew and period checks.
// End Revision
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module PCIE_A1 (
  CFGBUSNUMBER,
  CFGCOMMANDBUSMASTERENABLE,
  CFGCOMMANDINTERRUPTDISABLE,
  CFGCOMMANDIOENABLE,
  CFGCOMMANDMEMENABLE,
  CFGCOMMANDSERREN,
  CFGDEVCONTROLAUXPOWEREN,
  CFGDEVCONTROLCORRERRREPORTINGEN,
  CFGDEVCONTROLENABLERO,
  CFGDEVCONTROLEXTTAGEN,
  CFGDEVCONTROLFATALERRREPORTINGEN,
  CFGDEVCONTROLMAXPAYLOAD,
  CFGDEVCONTROLMAXREADREQ,
  CFGDEVCONTROLNONFATALREPORTINGEN,
  CFGDEVCONTROLNOSNOOPEN,
  CFGDEVCONTROLPHANTOMEN,
  CFGDEVCONTROLURERRREPORTINGEN,
  CFGDEVICENUMBER,
  CFGDEVSTATUSCORRERRDETECTED,
  CFGDEVSTATUSFATALERRDETECTED,
  CFGDEVSTATUSNONFATALERRDETECTED,
  CFGDEVSTATUSURDETECTED,
  CFGDO,
  CFGERRCPLRDYN,
  CFGFUNCTIONNUMBER,
  CFGINTERRUPTDO,
  CFGINTERRUPTMMENABLE,
  CFGINTERRUPTMSIENABLE,
  CFGINTERRUPTRDYN,
  CFGLINKCONTOLRCB,
  CFGLINKCONTROLASPMCONTROL,
  CFGLINKCONTROLCOMMONCLOCK,
  CFGLINKCONTROLEXTENDEDSYNC,
  CFGLTSSMSTATE,
  CFGPCIELINKSTATEN,
  CFGRDWRDONEN,
  CFGTOTURNOFFN,
  DBGBADDLLPSTATUS,
  DBGBADTLPLCRC,
  DBGBADTLPSEQNUM,
  DBGBADTLPSTATUS,
  DBGDLPROTOCOLSTATUS,
  DBGFCPROTOCOLERRSTATUS,
  DBGMLFRMDLENGTH,
  DBGMLFRMDMPS,
  DBGMLFRMDTCVC,
  DBGMLFRMDTLPSTATUS,
  DBGMLFRMDUNRECTYPE,
  DBGPOISTLPSTATUS,
  DBGRCVROVERFLOWSTATUS,
  DBGREGDETECTEDCORRECTABLE,
  DBGREGDETECTEDFATAL,
  DBGREGDETECTEDNONFATAL,
  DBGREGDETECTEDUNSUPPORTED,
  DBGRPLYROLLOVERSTATUS,
  DBGRPLYTIMEOUTSTATUS,
  DBGURNOBARHIT,
  DBGURPOISCFGWR,
  DBGURSTATUS,
  DBGURUNSUPMSG,
  MIMRXRADDR,
  MIMRXREN,
  MIMRXWADDR,
  MIMRXWDATA,
  MIMRXWEN,
  MIMTXRADDR,
  MIMTXREN,
  MIMTXWADDR,
  MIMTXWDATA,
  MIMTXWEN,
  PIPEGTPOWERDOWNA,
  PIPEGTPOWERDOWNB,
  PIPEGTTXELECIDLEA,
  PIPEGTTXELECIDLEB,
  PIPERXPOLARITYA,
  PIPERXPOLARITYB,
  PIPERXRESETA,
  PIPERXRESETB,
  PIPETXCHARDISPMODEA,
  PIPETXCHARDISPMODEB,
  PIPETXCHARDISPVALA,
  PIPETXCHARDISPVALB,
  PIPETXCHARISKA,
  PIPETXCHARISKB,
  PIPETXDATAA,
  PIPETXDATAB,
  PIPETXRCVRDETA,
  PIPETXRCVRDETB,
  RECEIVEDHOTRESET,
  TRNFCCPLD,
  TRNFCCPLH,
  TRNFCNPD,
  TRNFCNPH,
  TRNFCPD,
  TRNFCPH,
  TRNLNKUPN,
  TRNRBARHITN,
  TRNRD,
  TRNREOFN,
  TRNRERRFWDN,
  TRNRSOFN,
  TRNRSRCDSCN,
  TRNRSRCRDYN,
  TRNTBUFAV,
  TRNTCFGREQN,
  TRNTDSTRDYN,
  TRNTERRDROPN,
  USERRSTN,
  CFGDEVID,
  CFGDSN,
  CFGDWADDR,
  CFGERRCORN,
  CFGERRCPLABORTN,
  CFGERRCPLTIMEOUTN,
  CFGERRECRCN,
  CFGERRLOCKEDN,
  CFGERRPOSTEDN,
  CFGERRTLPCPLHEADER,
  CFGERRURN,
  CFGINTERRUPTASSERTN,
  CFGINTERRUPTDI,
  CFGINTERRUPTN,
  CFGPMWAKEN,
  CFGRDENN,
  CFGREVID,
  CFGSUBSYSID,
  CFGSUBSYSVENID,
  CFGTRNPENDINGN,
  CFGTURNOFFOKN,
  CFGVENID,
  CLOCKLOCKED,
  MGTCLK,
  MIMRXRDATA,
  MIMTXRDATA,
  PIPEGTRESETDONEA,
  PIPEGTRESETDONEB,
  PIPEPHYSTATUSA,
  PIPEPHYSTATUSB,
  PIPERXCHARISKA,
  PIPERXCHARISKB,
  PIPERXDATAA,
  PIPERXDATAB,
  PIPERXENTERELECIDLEA,
  PIPERXENTERELECIDLEB,
  PIPERXSTATUSA,
  PIPERXSTATUSB,
  SYSRESETN,
  TRNFCSEL,
  TRNRDSTRDYN,
  TRNRNPOKN,
  TRNTCFGGNTN,
  TRNTD,
  TRNTEOFN,
  TRNTERRFWDN,
  TRNTSOFN,
  TRNTSRCDSCN,
  TRNTSRCRDYN,
  TRNTSTRN,
  USERCLK
);

  parameter [31:0] BAR0 = 32'h00000000;
  parameter [31:0] BAR1 = 32'h00000000;
  parameter [31:0] BAR2 = 32'h00000000;
  parameter [31:0] BAR3 = 32'h00000000;
  parameter [31:0] BAR4 = 32'h00000000;
  parameter [31:0] BAR5 = 32'h00000000;
  parameter [31:0] CARDBUS_CIS_POINTER = 32'h00000000;
  parameter [23:0] CLASS_CODE = 24'h000000;
  parameter integer DEV_CAP_ENDPOINT_L0S_LATENCY = 7;
  parameter integer DEV_CAP_ENDPOINT_L1_LATENCY = 7;
  parameter DEV_CAP_EXT_TAG_SUPPORTED = "FALSE";
  parameter integer DEV_CAP_MAX_PAYLOAD_SUPPORTED = 2;
  parameter integer DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT = 0;
  parameter DEV_CAP_ROLE_BASED_ERROR = "TRUE";
  parameter DISABLE_BAR_FILTERING = "FALSE";
  parameter DISABLE_ID_CHECK = "FALSE";
  parameter DISABLE_SCRAMBLING = "FALSE";
  parameter ENABLE_RX_TD_ECRC_TRIM = "FALSE";
  parameter [21:0] EXPANSION_ROM = 22'h000000;
  parameter FAST_TRAIN = "FALSE";
  parameter integer GTP_SEL = 0;
  parameter integer LINK_CAP_ASPM_SUPPORT = 1;
  parameter integer LINK_CAP_L0S_EXIT_LATENCY = 7;
  parameter integer LINK_CAP_L1_EXIT_LATENCY = 7;
  parameter LINK_STATUS_SLOT_CLOCK_CONFIG = "FALSE";
  parameter [14:0] LL_ACK_TIMEOUT = 15'h0204;
  parameter LL_ACK_TIMEOUT_EN = "FALSE";
  parameter [14:0] LL_REPLAY_TIMEOUT = 15'h060D;
  parameter LL_REPLAY_TIMEOUT_EN = "FALSE";
  parameter integer MSI_CAP_MULTIMSGCAP = 0;
  parameter integer MSI_CAP_MULTIMSG_EXTENSION = 0;
  parameter [3:0] PCIE_CAP_CAPABILITY_VERSION = 4'h1;
  parameter [3:0] PCIE_CAP_DEVICE_PORT_TYPE = 4'h0;
  parameter [4:0] PCIE_CAP_INT_MSG_NUM = 5'b00000;
  parameter PCIE_CAP_SLOT_IMPLEMENTED = "FALSE";
  parameter [11:0] PCIE_GENERIC = 12'h000;
  parameter PLM_AUTO_CONFIG = "FALSE";
  parameter integer PM_CAP_AUXCURRENT = 0;
  parameter PM_CAP_D1SUPPORT = "TRUE";
  parameter PM_CAP_D2SUPPORT = "TRUE";
  parameter PM_CAP_DSI = "FALSE";
  parameter [4:0] PM_CAP_PMESUPPORT = 5'b01111;
  parameter PM_CAP_PME_CLOCK = "FALSE";
  parameter integer PM_CAP_VERSION = 3;
  parameter [7:0] PM_DATA0 = 8'h1E;
  parameter [7:0] PM_DATA1 = 8'h1E;
  parameter [7:0] PM_DATA2 = 8'h1E;
  parameter [7:0] PM_DATA3 = 8'h1E;
  parameter [7:0] PM_DATA4 = 8'h1E;
  parameter [7:0] PM_DATA5 = 8'h1E;
  parameter [7:0] PM_DATA6 = 8'h1E;
  parameter [7:0] PM_DATA7 = 8'h1E;
  parameter [1:0] PM_DATA_SCALE0 = 2'b01;
  parameter [1:0] PM_DATA_SCALE1 = 2'b01;
  parameter [1:0] PM_DATA_SCALE2 = 2'b01;
  parameter [1:0] PM_DATA_SCALE3 = 2'b01;
  parameter [1:0] PM_DATA_SCALE4 = 2'b01;
  parameter [1:0] PM_DATA_SCALE5 = 2'b01;
  parameter [1:0] PM_DATA_SCALE6 = 2'b01;
  parameter [1:0] PM_DATA_SCALE7 = 2'b01;
  parameter SIM_VERSION = "1.0";
  parameter SLOT_CAP_ATT_BUTTON_PRESENT = "FALSE";
  parameter SLOT_CAP_ATT_INDICATOR_PRESENT = "FALSE";
  parameter SLOT_CAP_POWER_INDICATOR_PRESENT = "FALSE";
  parameter integer TL_RX_RAM_RADDR_LATENCY = 1;
  parameter integer TL_RX_RAM_RDATA_LATENCY = 2;
  parameter integer TL_RX_RAM_WRITE_LATENCY = 0;
  parameter TL_TFC_DISABLE = "FALSE";
  parameter TL_TX_CHECKS_DISABLE = "FALSE";
  parameter integer TL_TX_RAM_RADDR_LATENCY = 0;
  parameter integer TL_TX_RAM_RDATA_LATENCY = 2;
  parameter USR_CFG = "FALSE";
  parameter USR_EXT_CFG = "FALSE";
  parameter VC0_CPL_INFINITE = "TRUE";
  parameter [11:0] VC0_RX_RAM_LIMIT = 12'h01E;
  parameter integer VC0_TOTAL_CREDITS_CD = 104;
  parameter integer VC0_TOTAL_CREDITS_CH = 36;
  parameter integer VC0_TOTAL_CREDITS_NPH = 8;
  parameter integer VC0_TOTAL_CREDITS_PD = 288;
  parameter integer VC0_TOTAL_CREDITS_PH = 32;
  parameter integer VC0_TX_LASTPACKET = 31;
  
  localparam in_delay = 0;
  localparam out_delay = 0;
  localparam INCLK_DELAY = 0;
  localparam OUTCLK_DELAY = 0;
  localparam MODULE_NAME = "PCIE_A1";

  output CFGCOMMANDBUSMASTERENABLE;
  output CFGCOMMANDINTERRUPTDISABLE;
  output CFGCOMMANDIOENABLE;
  output CFGCOMMANDMEMENABLE;
  output CFGCOMMANDSERREN;
  output CFGDEVCONTROLAUXPOWEREN;
  output CFGDEVCONTROLCORRERRREPORTINGEN;
  output CFGDEVCONTROLENABLERO;
  output CFGDEVCONTROLEXTTAGEN;
  output CFGDEVCONTROLFATALERRREPORTINGEN;
  output CFGDEVCONTROLNONFATALREPORTINGEN;
  output CFGDEVCONTROLNOSNOOPEN;
  output CFGDEVCONTROLPHANTOMEN;
  output CFGDEVCONTROLURERRREPORTINGEN;
  output CFGDEVSTATUSCORRERRDETECTED;
  output CFGDEVSTATUSFATALERRDETECTED;
  output CFGDEVSTATUSNONFATALERRDETECTED;
  output CFGDEVSTATUSURDETECTED;
  output CFGERRCPLRDYN;
  output CFGINTERRUPTMSIENABLE;
  output CFGINTERRUPTRDYN;
  output CFGLINKCONTOLRCB;
  output CFGLINKCONTROLCOMMONCLOCK;
  output CFGLINKCONTROLEXTENDEDSYNC;
  output CFGRDWRDONEN;
  output CFGTOTURNOFFN;
  output DBGBADDLLPSTATUS;
  output DBGBADTLPLCRC;
  output DBGBADTLPSEQNUM;
  output DBGBADTLPSTATUS;
  output DBGDLPROTOCOLSTATUS;
  output DBGFCPROTOCOLERRSTATUS;
  output DBGMLFRMDLENGTH;
  output DBGMLFRMDMPS;
  output DBGMLFRMDTCVC;
  output DBGMLFRMDTLPSTATUS;
  output DBGMLFRMDUNRECTYPE;
  output DBGPOISTLPSTATUS;
  output DBGRCVROVERFLOWSTATUS;
  output DBGREGDETECTEDCORRECTABLE;
  output DBGREGDETECTEDFATAL;
  output DBGREGDETECTEDNONFATAL;
  output DBGREGDETECTEDUNSUPPORTED;
  output DBGRPLYROLLOVERSTATUS;
  output DBGRPLYTIMEOUTSTATUS;
  output DBGURNOBARHIT;
  output DBGURPOISCFGWR;
  output DBGURSTATUS;
  output DBGURUNSUPMSG;
  output MIMRXREN;
  output MIMRXWEN;
  output MIMTXREN;
  output MIMTXWEN;
  output PIPEGTTXELECIDLEA;
  output PIPEGTTXELECIDLEB;
  output PIPERXPOLARITYA;
  output PIPERXPOLARITYB;
  output PIPERXRESETA;
  output PIPERXRESETB;
  output PIPETXRCVRDETA;
  output PIPETXRCVRDETB;
  output RECEIVEDHOTRESET;
  output TRNLNKUPN;
  output TRNREOFN;
  output TRNRERRFWDN;
  output TRNRSOFN;
  output TRNRSRCDSCN;
  output TRNRSRCRDYN;
  output TRNTCFGREQN;
  output TRNTDSTRDYN;
  output TRNTERRDROPN;
  output USERRSTN;
  output [11:0] MIMRXRADDR;
  output [11:0] MIMRXWADDR;
  output [11:0] MIMTXRADDR;
  output [11:0] MIMTXWADDR;
  output [11:0] TRNFCCPLD;
  output [11:0] TRNFCNPD;
  output [11:0] TRNFCPD;
  output [15:0] PIPETXDATAA;
  output [15:0] PIPETXDATAB;
  output [1:0] CFGLINKCONTROLASPMCONTROL;
  output [1:0] PIPEGTPOWERDOWNA;
  output [1:0] PIPEGTPOWERDOWNB;
  output [1:0] PIPETXCHARDISPMODEA;
  output [1:0] PIPETXCHARDISPMODEB;
  output [1:0] PIPETXCHARDISPVALA;
  output [1:0] PIPETXCHARDISPVALB;
  output [1:0] PIPETXCHARISKA;
  output [1:0] PIPETXCHARISKB;
  output [2:0] CFGDEVCONTROLMAXPAYLOAD;
  output [2:0] CFGDEVCONTROLMAXREADREQ;
  output [2:0] CFGFUNCTIONNUMBER;
  output [2:0] CFGINTERRUPTMMENABLE;
  output [2:0] CFGPCIELINKSTATEN;
  output [31:0] CFGDO;
  output [31:0] TRNRD;
  output [34:0] MIMRXWDATA;
  output [35:0] MIMTXWDATA;
  output [4:0] CFGDEVICENUMBER;
  output [4:0] CFGLTSSMSTATE;
  output [5:0] TRNTBUFAV;
  output [6:0] TRNRBARHITN;
  output [7:0] CFGBUSNUMBER;
  output [7:0] CFGINTERRUPTDO;
  output [7:0] TRNFCCPLH;
  output [7:0] TRNFCNPH;
  output [7:0] TRNFCPH;

  input CFGERRCORN;
  input CFGERRCPLABORTN;
  input CFGERRCPLTIMEOUTN;
  input CFGERRECRCN;
  input CFGERRLOCKEDN;
  input CFGERRPOSTEDN;
  input CFGERRURN;
  input CFGINTERRUPTASSERTN;
  input CFGINTERRUPTN;
  input CFGPMWAKEN;
  input CFGRDENN;
  input CFGTRNPENDINGN;
  input CFGTURNOFFOKN;
  input CLOCKLOCKED;
  input MGTCLK;
  input PIPEGTRESETDONEA;
  input PIPEGTRESETDONEB;
  input PIPEPHYSTATUSA;
  input PIPEPHYSTATUSB;
  input PIPERXENTERELECIDLEA;
  input PIPERXENTERELECIDLEB;
  input SYSRESETN;
  input TRNRDSTRDYN;
  input TRNRNPOKN;
  input TRNTCFGGNTN;
  input TRNTEOFN;
  input TRNTERRFWDN;
  input TRNTSOFN;
  input TRNTSRCDSCN;
  input TRNTSRCRDYN;
  input TRNTSTRN;
  input USERCLK;
  input [15:0] CFGDEVID;
  input [15:0] CFGSUBSYSID;
  input [15:0] CFGSUBSYSVENID;
  input [15:0] CFGVENID;
  input [15:0] PIPERXDATAA;
  input [15:0] PIPERXDATAB;
  input [1:0] PIPERXCHARISKA;
  input [1:0] PIPERXCHARISKB;
  input [2:0] PIPERXSTATUSA;
  input [2:0] PIPERXSTATUSB;
  input [2:0] TRNFCSEL;
  input [31:0] TRNTD;
  input [34:0] MIMRXRDATA;
  input [35:0] MIMTXRDATA;
  input [47:0] CFGERRTLPCPLHEADER;
  input [63:0] CFGDSN;
  input [7:0] CFGINTERRUPTDI;
  input [7:0] CFGREVID;
  input [9:0] CFGDWADDR;

  reg DEV_CAP_EXT_TAG_SUPPORTED_BINARY;
  reg DEV_CAP_ROLE_BASED_ERROR_BINARY;
  reg DISABLE_BAR_FILTERING_BINARY;
  reg DISABLE_ID_CHECK_BINARY;
  reg DISABLE_SCRAMBLING_BINARY;
  reg ENABLE_RX_TD_ECRC_TRIM_BINARY;
  reg FAST_TRAIN_BINARY;
  reg GTP_SEL_BINARY;
  reg LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY;
  reg LL_ACK_TIMEOUT_EN_BINARY;
  reg LL_REPLAY_TIMEOUT_EN_BINARY;
  reg MSI_CAP_MULTIMSG_EXTENSION_BINARY;
  reg PCIE_CAP_SLOT_IMPLEMENTED_BINARY;
  reg PLM_AUTO_CONFIG_BINARY;
  reg PM_CAP_D1SUPPORT_BINARY;
  reg PM_CAP_D2SUPPORT_BINARY;
  reg PM_CAP_DSI_BINARY;
  reg PM_CAP_PME_CLOCK_BINARY;
  reg SIM_VERSION_BINARY;
  reg SLOT_CAP_ATT_BUTTON_PRESENT_BINARY;
  reg SLOT_CAP_ATT_INDICATOR_PRESENT_BINARY;
  reg SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY;
  reg TL_RX_RAM_RADDR_LATENCY_BINARY;
  reg TL_RX_RAM_WRITE_LATENCY_BINARY;
  reg TL_TFC_DISABLE_BINARY;
  reg TL_TX_CHECKS_DISABLE_BINARY;
  reg TL_TX_RAM_RADDR_LATENCY_BINARY;
  reg USR_CFG_BINARY;
  reg USR_EXT_CFG_BINARY;
  reg VC0_CPL_INFINITE_BINARY;
  reg [10:0] VC0_TOTAL_CREDITS_CD_BINARY;
  reg [10:0] VC0_TOTAL_CREDITS_PD_BINARY;
  reg [1:0] DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT_BINARY;
  reg [1:0] LINK_CAP_ASPM_SUPPORT_BINARY;
  reg [1:0] PM_DATA_SCALE0_BINARY;
  reg [1:0] PM_DATA_SCALE1_BINARY;
  reg [1:0] PM_DATA_SCALE2_BINARY;
  reg [1:0] PM_DATA_SCALE3_BINARY;
  reg [1:0] PM_DATA_SCALE4_BINARY;
  reg [1:0] PM_DATA_SCALE5_BINARY;
  reg [1:0] PM_DATA_SCALE6_BINARY;
  reg [1:0] PM_DATA_SCALE7_BINARY;
  reg [1:0] TL_RX_RAM_RDATA_LATENCY_BINARY;
  reg [1:0] TL_TX_RAM_RDATA_LATENCY_BINARY;
  reg [2:0] DEV_CAP_ENDPOINT_L0S_LATENCY_BINARY;
  reg [2:0] DEV_CAP_ENDPOINT_L1_LATENCY_BINARY;
  reg [2:0] DEV_CAP_MAX_PAYLOAD_SUPPORTED_BINARY;
  reg [2:0] LINK_CAP_L0S_EXIT_LATENCY_BINARY;
  reg [2:0] LINK_CAP_L1_EXIT_LATENCY_BINARY;
  reg [2:0] MSI_CAP_MULTIMSGCAP_BINARY;
  reg [2:0] PM_CAP_AUXCURRENT_BINARY;
  reg [2:0] PM_CAP_VERSION_BINARY;
  reg [4:0] PCIE_CAP_INT_MSG_NUM_BINARY;
  reg [4:0] PM_CAP_PMESUPPORT_BINARY;
  reg [4:0] VC0_TX_LASTPACKET_BINARY;
  reg [6:0] VC0_TOTAL_CREDITS_CH_BINARY;
  reg [6:0] VC0_TOTAL_CREDITS_NPH_BINARY;
  reg [6:0] VC0_TOTAL_CREDITS_PH_BINARY;

  tri0 GSR = glbl.GSR;
  wire CFGCOMMANDBUSMASTERENABLE_OUT;
  wire CFGCOMMANDINTERRUPTDISABLE_OUT;
  wire CFGCOMMANDIOENABLE_OUT;
  wire CFGCOMMANDMEMENABLE_OUT;
  wire CFGCOMMANDSERREN_OUT;
  wire CFGDEVCONTROLAUXPOWEREN_OUT;
  wire CFGDEVCONTROLCORRERRREPORTINGEN_OUT;
  wire CFGDEVCONTROLENABLERO_OUT;
  wire CFGDEVCONTROLEXTTAGEN_OUT;
  wire CFGDEVCONTROLFATALERRREPORTINGEN_OUT;
  wire CFGDEVCONTROLNONFATALREPORTINGEN_OUT;
  wire CFGDEVCONTROLNOSNOOPEN_OUT;
  wire CFGDEVCONTROLPHANTOMEN_OUT;
  wire CFGDEVCONTROLURERRREPORTINGEN_OUT;
  wire CFGDEVSTATUSCORRERRDETECTED_OUT;
  wire CFGDEVSTATUSFATALERRDETECTED_OUT;
  wire CFGDEVSTATUSNONFATALERRDETECTED_OUT;
  wire CFGDEVSTATUSURDETECTED_OUT;
  wire CFGERRCPLRDYN_OUT;
  wire CFGINTERRUPTMSIENABLE_OUT;
  wire CFGINTERRUPTRDYN_OUT;
  wire CFGLINKCONTOLRCB_OUT;
  wire CFGLINKCONTROLCOMMONCLOCK_OUT;
  wire CFGLINKCONTROLEXTENDEDSYNC_OUT;
  wire CFGRDWRDONEN_OUT;
  wire CFGTOTURNOFFN_OUT;
  wire DBGBADDLLPSTATUS_OUT;
  wire DBGBADTLPLCRC_OUT;
  wire DBGBADTLPSEQNUM_OUT;
  wire DBGBADTLPSTATUS_OUT;
  wire DBGDLPROTOCOLSTATUS_OUT;
  wire DBGFCPROTOCOLERRSTATUS_OUT;
  wire DBGMLFRMDLENGTH_OUT;
  wire DBGMLFRMDMPS_OUT;
  wire DBGMLFRMDTCVC_OUT;
  wire DBGMLFRMDTLPSTATUS_OUT;
  wire DBGMLFRMDUNRECTYPE_OUT;
  wire DBGPOISTLPSTATUS_OUT;
  wire DBGRCVROVERFLOWSTATUS_OUT;
  wire DBGREGDETECTEDCORRECTABLE_OUT;
  wire DBGREGDETECTEDFATAL_OUT;
  wire DBGREGDETECTEDNONFATAL_OUT;
  wire DBGREGDETECTEDUNSUPPORTED_OUT;
  wire DBGRPLYROLLOVERSTATUS_OUT;
  wire DBGRPLYTIMEOUTSTATUS_OUT;
  wire DBGURNOBARHIT_OUT;
  wire DBGURPOISCFGWR_OUT;
  wire DBGURSTATUS_OUT;
  wire DBGURUNSUPMSG_OUT;
  wire MIMRXREN_OUT;
  wire MIMRXWEN_OUT;
  wire MIMTXREN_OUT;
  wire MIMTXWEN_OUT;
  wire PIPEGTTXELECIDLEA_OUT;
  wire PIPEGTTXELECIDLEB_OUT;
  wire PIPERXPOLARITYA_OUT;
  wire PIPERXPOLARITYB_OUT;
  wire PIPERXRESETA_OUT;
  wire PIPERXRESETB_OUT;
  wire PIPETXRCVRDETA_OUT;
  wire PIPETXRCVRDETB_OUT;
  wire RECEIVEDHOTRESET_OUT;
  wire TRNLNKUPN_OUT;
  wire TRNREOFN_OUT;
  wire TRNRERRFWDN_OUT;
  wire TRNRSOFN_OUT;
  wire TRNRSRCDSCN_OUT;
  wire TRNRSRCRDYN_OUT;
  wire TRNTCFGREQN_OUT;
  wire TRNTDSTRDYN_OUT;
  wire TRNTERRDROPN_OUT;
  wire USERRSTN_OUT;
  wire [11:0] MIMRXRADDR_OUT;
  wire [11:0] MIMRXWADDR_OUT;
  wire [11:0] MIMTXRADDR_OUT;
  wire [11:0] MIMTXWADDR_OUT;
  wire [11:0] TRNFCCPLD_OUT;
  wire [11:0] TRNFCNPD_OUT;
  wire [11:0] TRNFCPD_OUT;
  wire [15:0] PIPETXDATAA_OUT;
  wire [15:0] PIPETXDATAB_OUT;
  wire [1:0] CFGLINKCONTROLASPMCONTROL_OUT;
  wire [1:0] PIPEGTPOWERDOWNA_OUT;
  wire [1:0] PIPEGTPOWERDOWNB_OUT;
  wire [1:0] PIPETXCHARDISPMODEA_OUT;
  wire [1:0] PIPETXCHARDISPMODEB_OUT;
  wire [1:0] PIPETXCHARDISPVALA_OUT;
  wire [1:0] PIPETXCHARDISPVALB_OUT;
  wire [1:0] PIPETXCHARISKA_OUT;
  wire [1:0] PIPETXCHARISKB_OUT;
  wire [2:0] CFGDEVCONTROLMAXPAYLOAD_OUT;
  wire [2:0] CFGDEVCONTROLMAXREADREQ_OUT;
  wire [2:0] CFGFUNCTIONNUMBER_OUT;
  wire [2:0] CFGINTERRUPTMMENABLE_OUT;
  wire [2:0] CFGPCIELINKSTATEN_OUT;
  wire [31:0] CFGDO_OUT;
  wire [31:0] TRNRD_OUT;
  wire [34:0] MIMRXWDATA_OUT;
  wire [35:0] MIMTXWDATA_OUT;
  wire [4:0] CFGDEVICENUMBER_OUT;
  wire [4:0] CFGLTSSMSTATE_OUT;
  wire [5:0] TRNTBUFAV_OUT;
  wire [6:0] TRNRBARHITN_OUT;
  wire [7:0] CFGBUSNUMBER_OUT;
  wire [7:0] CFGINTERRUPTDO_OUT;
  wire [7:0] TRNFCCPLH_OUT;
  wire [7:0] TRNFCNPH_OUT;
  wire [7:0] TRNFCPH_OUT;

  wire CFGCOMMANDBUSMASTERENABLE_OUTDELAY;
  wire CFGCOMMANDINTERRUPTDISABLE_OUTDELAY;
  wire CFGCOMMANDIOENABLE_OUTDELAY;
  wire CFGCOMMANDMEMENABLE_OUTDELAY;
  wire CFGCOMMANDSERREN_OUTDELAY;
  wire CFGDEVCONTROLAUXPOWEREN_OUTDELAY;
  wire CFGDEVCONTROLCORRERRREPORTINGEN_OUTDELAY;
  wire CFGDEVCONTROLENABLERO_OUTDELAY;
  wire CFGDEVCONTROLEXTTAGEN_OUTDELAY;
  wire CFGDEVCONTROLFATALERRREPORTINGEN_OUTDELAY;
  wire CFGDEVCONTROLNONFATALREPORTINGEN_OUTDELAY;
  wire CFGDEVCONTROLNOSNOOPEN_OUTDELAY;
  wire CFGDEVCONTROLPHANTOMEN_OUTDELAY;
  wire CFGDEVCONTROLURERRREPORTINGEN_OUTDELAY;
  wire CFGDEVSTATUSCORRERRDETECTED_OUTDELAY;
  wire CFGDEVSTATUSFATALERRDETECTED_OUTDELAY;
  wire CFGDEVSTATUSNONFATALERRDETECTED_OUTDELAY;
  wire CFGDEVSTATUSURDETECTED_OUTDELAY;
  wire CFGERRCPLRDYN_OUTDELAY;
  wire CFGINTERRUPTMSIENABLE_OUTDELAY;
  wire CFGINTERRUPTRDYN_OUTDELAY;
  wire CFGLINKCONTOLRCB_OUTDELAY;
  wire CFGLINKCONTROLCOMMONCLOCK_OUTDELAY;
  wire CFGLINKCONTROLEXTENDEDSYNC_OUTDELAY;
  wire CFGRDWRDONEN_OUTDELAY;
  wire CFGTOTURNOFFN_OUTDELAY;
  wire DBGBADDLLPSTATUS_OUTDELAY;
  wire DBGBADTLPLCRC_OUTDELAY;
  wire DBGBADTLPSEQNUM_OUTDELAY;
  wire DBGBADTLPSTATUS_OUTDELAY;
  wire DBGDLPROTOCOLSTATUS_OUTDELAY;
  wire DBGFCPROTOCOLERRSTATUS_OUTDELAY;
  wire DBGMLFRMDLENGTH_OUTDELAY;
  wire DBGMLFRMDMPS_OUTDELAY;
  wire DBGMLFRMDTCVC_OUTDELAY;
  wire DBGMLFRMDTLPSTATUS_OUTDELAY;
  wire DBGMLFRMDUNRECTYPE_OUTDELAY;
  wire DBGPOISTLPSTATUS_OUTDELAY;
  wire DBGRCVROVERFLOWSTATUS_OUTDELAY;
  wire DBGREGDETECTEDCORRECTABLE_OUTDELAY;
  wire DBGREGDETECTEDFATAL_OUTDELAY;
  wire DBGREGDETECTEDNONFATAL_OUTDELAY;
  wire DBGREGDETECTEDUNSUPPORTED_OUTDELAY;
  wire DBGRPLYROLLOVERSTATUS_OUTDELAY;
  wire DBGRPLYTIMEOUTSTATUS_OUTDELAY;
  wire DBGURNOBARHIT_OUTDELAY;
  wire DBGURPOISCFGWR_OUTDELAY;
  wire DBGURSTATUS_OUTDELAY;
  wire DBGURUNSUPMSG_OUTDELAY;
  wire MIMRXREN_OUTDELAY;
  wire MIMRXWEN_OUTDELAY;
  wire MIMTXREN_OUTDELAY;
  wire MIMTXWEN_OUTDELAY;
  wire PIPEGTTXELECIDLEA_OUTDELAY;
  wire PIPEGTTXELECIDLEB_OUTDELAY;
  wire PIPERXPOLARITYA_OUTDELAY;
  wire PIPERXPOLARITYB_OUTDELAY;
  wire PIPERXRESETA_OUTDELAY;
  wire PIPERXRESETB_OUTDELAY;
  wire PIPETXRCVRDETA_OUTDELAY;
  wire PIPETXRCVRDETB_OUTDELAY;
  wire RECEIVEDHOTRESET_OUTDELAY;
  wire TRNLNKUPN_OUTDELAY;
  wire TRNREOFN_OUTDELAY;
  wire TRNRERRFWDN_OUTDELAY;
  wire TRNRSOFN_OUTDELAY;
  wire TRNRSRCDSCN_OUTDELAY;
  wire TRNRSRCRDYN_OUTDELAY;
  wire TRNTCFGREQN_OUTDELAY;
  wire TRNTDSTRDYN_OUTDELAY;
  wire TRNTERRDROPN_OUTDELAY;
  wire USERRSTN_OUTDELAY;
  wire [11:0] MIMRXRADDR_OUTDELAY;
  wire [11:0] MIMRXWADDR_OUTDELAY;
  wire [11:0] MIMTXRADDR_OUTDELAY;
  wire [11:0] MIMTXWADDR_OUTDELAY;
  wire [11:0] TRNFCCPLD_OUTDELAY;
  wire [11:0] TRNFCNPD_OUTDELAY;
  wire [11:0] TRNFCPD_OUTDELAY;
  wire [15:0] PIPETXDATAA_OUTDELAY;
  wire [15:0] PIPETXDATAB_OUTDELAY;
  wire [1:0] CFGLINKCONTROLASPMCONTROL_OUTDELAY;
  wire [1:0] PIPEGTPOWERDOWNA_OUTDELAY;
  wire [1:0] PIPEGTPOWERDOWNB_OUTDELAY;
  wire [1:0] PIPETXCHARDISPMODEA_OUTDELAY;
  wire [1:0] PIPETXCHARDISPMODEB_OUTDELAY;
  wire [1:0] PIPETXCHARDISPVALA_OUTDELAY;
  wire [1:0] PIPETXCHARDISPVALB_OUTDELAY;
  wire [1:0] PIPETXCHARISKA_OUTDELAY;
  wire [1:0] PIPETXCHARISKB_OUTDELAY;
  wire [2:0] CFGDEVCONTROLMAXPAYLOAD_OUTDELAY;
  wire [2:0] CFGDEVCONTROLMAXREADREQ_OUTDELAY;
  wire [2:0] CFGFUNCTIONNUMBER_OUTDELAY;
  wire [2:0] CFGINTERRUPTMMENABLE_OUTDELAY;
  wire [2:0] CFGPCIELINKSTATEN_OUTDELAY;
  wire [31:0] CFGDO_OUTDELAY;
  wire [31:0] TRNRD_OUTDELAY;
  wire [34:0] MIMRXWDATA_OUTDELAY;
  wire [35:0] MIMTXWDATA_OUTDELAY;
  wire [4:0] CFGDEVICENUMBER_OUTDELAY;
  wire [4:0] CFGLTSSMSTATE_OUTDELAY;
  wire [5:0] TRNTBUFAV_OUTDELAY;
  wire [6:0] TRNRBARHITN_OUTDELAY;
  wire [7:0] CFGBUSNUMBER_OUTDELAY;
  wire [7:0] CFGINTERRUPTDO_OUTDELAY;
  wire [7:0] TRNFCCPLH_OUTDELAY;
  wire [7:0] TRNFCNPH_OUTDELAY;
  wire [7:0] TRNFCPH_OUTDELAY;

  wire CFGERRCORN_IN;
  wire CFGERRCPLABORTN_IN;
  wire CFGERRCPLTIMEOUTN_IN;
  wire CFGERRECRCN_IN;
  wire CFGERRLOCKEDN_IN;
  wire CFGERRPOSTEDN_IN;
  wire CFGERRURN_IN;
  wire CFGINTERRUPTASSERTN_IN;
  wire CFGINTERRUPTN_IN;
  wire CFGPMWAKEN_IN;
  wire CFGRDENN_IN;
  wire CFGTRNPENDINGN_IN;
  wire CFGTURNOFFOKN_IN;
  wire CLOCKLOCKED_IN;
  wire MGTCLK_IN;
  wire PIPEGTRESETDONEA_IN;
  wire PIPEGTRESETDONEB_IN;
  wire PIPEPHYSTATUSA_IN;
  wire PIPEPHYSTATUSB_IN;
  wire PIPERXENTERELECIDLEA_IN;
  wire PIPERXENTERELECIDLEB_IN;
  wire SYSRESETN_IN;
  wire TRNRDSTRDYN_IN;
  wire TRNRNPOKN_IN;
  wire TRNTCFGGNTN_IN;
  wire TRNTEOFN_IN;
  wire TRNTERRFWDN_IN;
  wire TRNTSOFN_IN;
  wire TRNTSRCDSCN_IN;
  wire TRNTSRCRDYN_IN;
  wire TRNTSTRN_IN;
  wire USERCLK_IN;
  wire [15:0] CFGDEVID_IN;
  wire [15:0] CFGSUBSYSID_IN;
  wire [15:0] CFGSUBSYSVENID_IN;
  wire [15:0] CFGVENID_IN;
  wire [15:0] PIPERXDATAA_IN;
  wire [15:0] PIPERXDATAB_IN;
  wire [1:0] PIPERXCHARISKA_IN;
  wire [1:0] PIPERXCHARISKB_IN;
  wire [2:0] PIPERXSTATUSA_IN;
  wire [2:0] PIPERXSTATUSB_IN;
  wire [2:0] TRNFCSEL_IN;
  wire [31:0] TRNTD_IN;
  wire [34:0] MIMRXRDATA_IN;
  wire [35:0] MIMTXRDATA_IN;
  wire [47:0] CFGERRTLPCPLHEADER_IN;
  wire [63:0] CFGDSN_IN;
  wire [7:0] CFGINTERRUPTDI_IN;
  wire [7:0] CFGREVID_IN;
  wire [9:0] CFGDWADDR_IN;
  wire CFGERRCORN_INDELAY;
  wire CFGERRCPLABORTN_INDELAY;
  wire CFGERRCPLTIMEOUTN_INDELAY;
  wire CFGERRECRCN_INDELAY;
  wire CFGERRLOCKEDN_INDELAY;
  wire CFGERRPOSTEDN_INDELAY;
  wire CFGERRURN_INDELAY;
  wire CFGINTERRUPTASSERTN_INDELAY;
  wire CFGINTERRUPTN_INDELAY;
  wire CFGPMWAKEN_INDELAY;
  wire CFGRDENN_INDELAY;
  wire CFGTRNPENDINGN_INDELAY;
  wire CFGTURNOFFOKN_INDELAY;
  wire CLOCKLOCKED_INDELAY;
  wire MGTCLK_INDELAY;
  wire PIPEGTRESETDONEA_INDELAY;
  wire PIPEGTRESETDONEB_INDELAY;
  wire PIPEPHYSTATUSA_INDELAY;
  wire PIPEPHYSTATUSB_INDELAY;
  wire PIPERXENTERELECIDLEA_INDELAY;
  wire PIPERXENTERELECIDLEB_INDELAY;
  wire SYSRESETN_INDELAY;
  wire TRNRDSTRDYN_INDELAY;
  wire TRNRNPOKN_INDELAY;
  wire TRNTCFGGNTN_INDELAY;
  wire TRNTEOFN_INDELAY;
  wire TRNTERRFWDN_INDELAY;
  wire TRNTSOFN_INDELAY;
  wire TRNTSRCDSCN_INDELAY;
  wire TRNTSRCRDYN_INDELAY;
  wire TRNTSTRN_INDELAY;
  wire USERCLK_INDELAY;
  wire [15:0] CFGDEVID_INDELAY;
  wire [15:0] CFGSUBSYSID_INDELAY;
  wire [15:0] CFGSUBSYSVENID_INDELAY;
  wire [15:0] CFGVENID_INDELAY;
  wire [15:0] PIPERXDATAA_INDELAY;
  wire [15:0] PIPERXDATAB_INDELAY;
  wire [1:0] PIPERXCHARISKA_INDELAY;
  wire [1:0] PIPERXCHARISKB_INDELAY;
  wire [2:0] PIPERXSTATUSA_INDELAY;
  wire [2:0] PIPERXSTATUSB_INDELAY;
  wire [2:0] TRNFCSEL_INDELAY;
  wire [31:0] TRNTD_INDELAY;
  wire [34:0] MIMRXRDATA_INDELAY;
  wire [35:0] MIMTXRDATA_INDELAY;
  wire [47:0] CFGERRTLPCPLHEADER_INDELAY;
  wire [63:0] CFGDSN_INDELAY;
  wire [7:0] CFGINTERRUPTDI_INDELAY;
  wire [7:0] CFGREVID_INDELAY;
  wire [9:0] CFGDWADDR_INDELAY;

  initial begin
    case (DEV_CAP_EXT_TAG_SUPPORTED[31:0])
      "ALSE" : DEV_CAP_EXT_TAG_SUPPORTED_BINARY = 1'b0;
      "TRUE" : DEV_CAP_EXT_TAG_SUPPORTED_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute DEV_CAP_EXT_TAG_SUPPORTED on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, DEV_CAP_EXT_TAG_SUPPORTED);
        $finish;
      end
    endcase

    case (DEV_CAP_ROLE_BASED_ERROR[31:0])
      "ALSE" : DEV_CAP_ROLE_BASED_ERROR_BINARY = 1'b0;
      "TRUE" : DEV_CAP_ROLE_BASED_ERROR_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute DEV_CAP_ROLE_BASED_ERROR on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, DEV_CAP_ROLE_BASED_ERROR);
        $finish;
      end
    endcase

    case (DISABLE_BAR_FILTERING[31:0])
      "ALSE" : DISABLE_BAR_FILTERING_BINARY = 1'b0;
      "TRUE" : DISABLE_BAR_FILTERING_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute DISABLE_BAR_FILTERING on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, DISABLE_BAR_FILTERING);
        $finish;
      end
    endcase

    case (DISABLE_ID_CHECK[31:0])
      "ALSE" : DISABLE_ID_CHECK_BINARY = 1'b0;
      "TRUE" : DISABLE_ID_CHECK_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute DISABLE_ID_CHECK on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, DISABLE_ID_CHECK);
        $finish;
      end
    endcase

    case (DISABLE_SCRAMBLING[31:0])
      "ALSE" : DISABLE_SCRAMBLING_BINARY = 1'b0;
      "TRUE" : DISABLE_SCRAMBLING_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute DISABLE_SCRAMBLING on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, DISABLE_SCRAMBLING);
        $finish;
      end
    endcase

    case (ENABLE_RX_TD_ECRC_TRIM[31:0])
      "ALSE" : ENABLE_RX_TD_ECRC_TRIM_BINARY = 1'b0;
      "TRUE" : ENABLE_RX_TD_ECRC_TRIM_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute ENABLE_RX_TD_ECRC_TRIM on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, ENABLE_RX_TD_ECRC_TRIM);
        $finish;
      end
    endcase

    case (FAST_TRAIN[31:0])
      "ALSE" : FAST_TRAIN_BINARY = 1'b0;
      "TRUE" : FAST_TRAIN_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute FAST_TRAIN on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, FAST_TRAIN);
        $finish;
      end
    endcase

    case (LINK_STATUS_SLOT_CLOCK_CONFIG[31:0])
      "ALSE" : LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY = 1'b0;
      "TRUE" : LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute LINK_STATUS_SLOT_CLOCK_CONFIG on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, LINK_STATUS_SLOT_CLOCK_CONFIG);
        $finish;
      end
    endcase

    case (LL_ACK_TIMEOUT_EN[31:0])
      "ALSE" : LL_ACK_TIMEOUT_EN_BINARY = 1'b0;
      "TRUE" : LL_ACK_TIMEOUT_EN_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute LL_ACK_TIMEOUT_EN on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, LL_ACK_TIMEOUT_EN);
        $finish;
      end
    endcase

    case (LL_REPLAY_TIMEOUT_EN[31:0])
      "ALSE" : LL_REPLAY_TIMEOUT_EN_BINARY = 1'b0;
      "TRUE" : LL_REPLAY_TIMEOUT_EN_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute LL_REPLAY_TIMEOUT_EN on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, LL_REPLAY_TIMEOUT_EN);
        $finish;
      end
    endcase

    case (PCIE_CAP_SLOT_IMPLEMENTED[31:0])
      "ALSE" : PCIE_CAP_SLOT_IMPLEMENTED_BINARY = 1'b0;
      "TRUE" : PCIE_CAP_SLOT_IMPLEMENTED_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute PCIE_CAP_SLOT_IMPLEMENTED on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, PCIE_CAP_SLOT_IMPLEMENTED);
        $finish;
      end
    endcase

    case (PLM_AUTO_CONFIG[31:0])
      "ALSE" : PLM_AUTO_CONFIG_BINARY = 1'b0;
      "TRUE" : PLM_AUTO_CONFIG_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute PLM_AUTO_CONFIG on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, PLM_AUTO_CONFIG);
        $finish;
      end
    endcase

    case (PM_CAP_D1SUPPORT[31:0])
      "ALSE" : PM_CAP_D1SUPPORT_BINARY = 1'b0;
      "TRUE" : PM_CAP_D1SUPPORT_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute PM_CAP_D1SUPPORT on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, PM_CAP_D1SUPPORT);
        $finish;
      end
    endcase

    case (PM_CAP_D2SUPPORT[31:0])
      "ALSE" : PM_CAP_D2SUPPORT_BINARY = 1'b0;
      "TRUE" : PM_CAP_D2SUPPORT_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute PM_CAP_D2SUPPORT on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, PM_CAP_D2SUPPORT);
        $finish;
      end
    endcase

    case (PM_CAP_DSI[31:0])
      "ALSE" : PM_CAP_DSI_BINARY = 1'b0;
      "TRUE" : PM_CAP_DSI_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute PM_CAP_DSI on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, PM_CAP_DSI);
        $finish;
      end
    endcase

    case (PM_CAP_PME_CLOCK[31:0])
      "ALSE" : PM_CAP_PME_CLOCK_BINARY = 1'b0;
      "TRUE" : PM_CAP_PME_CLOCK_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute PM_CAP_PME_CLOCK on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, PM_CAP_PME_CLOCK);
        $finish;
      end
    endcase

    case (SIM_VERSION)
      "1.0" : SIM_VERSION_BINARY = 0;
      "2.0" : SIM_VERSION_BINARY = 0;
      "3.0" : SIM_VERSION_BINARY = 0;
      "4.0" : SIM_VERSION_BINARY = 0;
      "5.0" : SIM_VERSION_BINARY = 0;
      "6.0" : SIM_VERSION_BINARY = 0;
      default : begin
        $display("Attribute Syntax Error : The Attribute SIM_VERSION on %s instance %m is set to %s.  Legal values for this attribute are 1.0, 2.0, 3.0, 4.0, 5.0, or 6.0." ,MODULE_NAME, SIM_VERSION);
        $finish;
      end
    endcase

    case (SLOT_CAP_ATT_BUTTON_PRESENT[31:0])
      "ALSE" : SLOT_CAP_ATT_BUTTON_PRESENT_BINARY = 1'b0;
      "TRUE" : SLOT_CAP_ATT_BUTTON_PRESENT_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute SLOT_CAP_ATT_BUTTON_PRESENT on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, SLOT_CAP_ATT_BUTTON_PRESENT);
        $finish;
      end
    endcase

    case (SLOT_CAP_ATT_INDICATOR_PRESENT[31:0])
      "ALSE" : SLOT_CAP_ATT_INDICATOR_PRESENT_BINARY = 1'b0;
      "TRUE" : SLOT_CAP_ATT_INDICATOR_PRESENT_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute SLOT_CAP_ATT_INDICATOR_PRESENT on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, SLOT_CAP_ATT_INDICATOR_PRESENT);
        $finish;
      end
    endcase

    case (SLOT_CAP_POWER_INDICATOR_PRESENT[31:0])
      "ALSE" : SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY = 1'b0;
      "TRUE" : SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute SLOT_CAP_POWER_INDICATOR_PRESENT on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, SLOT_CAP_POWER_INDICATOR_PRESENT);
        $finish;
      end
    endcase

    case (TL_TFC_DISABLE[31:0])
      "ALSE" : TL_TFC_DISABLE_BINARY = 1'b0;
      "TRUE" : TL_TFC_DISABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TL_TFC_DISABLE on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, TL_TFC_DISABLE);
        $finish;
      end
    endcase

    case (TL_TX_CHECKS_DISABLE[31:0])
      "ALSE" : TL_TX_CHECKS_DISABLE_BINARY = 1'b0;
      "TRUE" : TL_TX_CHECKS_DISABLE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute TL_TX_CHECKS_DISABLE on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, TL_TX_CHECKS_DISABLE);
        $finish;
      end
    endcase

    case (USR_CFG[31:0])
      "ALSE" : USR_CFG_BINARY = 1'b0;
      "TRUE" : USR_CFG_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute USR_CFG on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, USR_CFG);
        $finish;
      end
    endcase

    case (USR_EXT_CFG[31:0])
      "ALSE" : USR_EXT_CFG_BINARY = 1'b0;
      "TRUE" : USR_EXT_CFG_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute USR_EXT_CFG on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, USR_EXT_CFG);
        $finish;
      end
    endcase

    case (VC0_CPL_INFINITE[31:0])
      "ALSE" : VC0_CPL_INFINITE_BINARY = 1'b0;
      "TRUE" : VC0_CPL_INFINITE_BINARY = 1'b1;
      default : begin
        $display("Attribute Syntax Error : The Attribute VC0_CPL_INFINITE on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", MODULE_NAME, VC0_CPL_INFINITE);
        $finish;
      end
    endcase

    if ((DEV_CAP_ENDPOINT_L0S_LATENCY >= 0) && (DEV_CAP_ENDPOINT_L0S_LATENCY <= 7))
      DEV_CAP_ENDPOINT_L0S_LATENCY_BINARY = DEV_CAP_ENDPOINT_L0S_LATENCY;
    else begin
      $display("Attribute Syntax Error : The Attribute DEV_CAP_ENDPOINT_L0S_LATENCY on %s instance %m is set to %d.  Legal values for this attribute are  0 to 7.", MODULE_NAME, DEV_CAP_ENDPOINT_L0S_LATENCY);
      $finish;
    end

    if ((DEV_CAP_ENDPOINT_L1_LATENCY >= 0) && (DEV_CAP_ENDPOINT_L1_LATENCY <= 7))
      DEV_CAP_ENDPOINT_L1_LATENCY_BINARY = DEV_CAP_ENDPOINT_L1_LATENCY;
    else begin
      $display("Attribute Syntax Error : The Attribute DEV_CAP_ENDPOINT_L1_LATENCY on %s instance %m is set to %d.  Legal values for this attribute are  0 to 7.", MODULE_NAME, DEV_CAP_ENDPOINT_L1_LATENCY);
      $finish;
    end

    if ((DEV_CAP_MAX_PAYLOAD_SUPPORTED >= 0) && (DEV_CAP_MAX_PAYLOAD_SUPPORTED <= 7))
      DEV_CAP_MAX_PAYLOAD_SUPPORTED_BINARY = DEV_CAP_MAX_PAYLOAD_SUPPORTED;
    else begin
      $display("Attribute Syntax Error : The Attribute DEV_CAP_MAX_PAYLOAD_SUPPORTED on %s instance %m is set to %d.  Legal values for this attribute are  0 to 7.", MODULE_NAME, DEV_CAP_MAX_PAYLOAD_SUPPORTED);
      $finish;
    end

    if ((DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT >= 0) && (DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT <= 3))
      DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT_BINARY = DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT;
    else begin
      $display("Attribute Syntax Error : The Attribute DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT);
      $finish;
    end

    if ((GTP_SEL >= 0) && (GTP_SEL <= 1))
      GTP_SEL_BINARY = GTP_SEL;
    else begin
      $display("Attribute Syntax Error : The Attribute GTP_SEL on %s instance %m is set to %d.  Legal values for this attribute are  0 to 1.", MODULE_NAME, GTP_SEL);
      $finish;
    end

    if ((LINK_CAP_ASPM_SUPPORT >= 0) && (LINK_CAP_ASPM_SUPPORT <= 3))
      LINK_CAP_ASPM_SUPPORT_BINARY = LINK_CAP_ASPM_SUPPORT;
    else begin
      $display("Attribute Syntax Error : The Attribute LINK_CAP_ASPM_SUPPORT on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, LINK_CAP_ASPM_SUPPORT);
      $finish;
    end

    if ((LINK_CAP_L0S_EXIT_LATENCY >= 0) && (LINK_CAP_L0S_EXIT_LATENCY <= 7))
      LINK_CAP_L0S_EXIT_LATENCY_BINARY = LINK_CAP_L0S_EXIT_LATENCY;
    else begin
      $display("Attribute Syntax Error : The Attribute LINK_CAP_L0S_EXIT_LATENCY on %s instance %m is set to %d.  Legal values for this attribute are  0 to 7.", MODULE_NAME, LINK_CAP_L0S_EXIT_LATENCY);
      $finish;
    end

    if ((LINK_CAP_L1_EXIT_LATENCY >= 0) && (LINK_CAP_L1_EXIT_LATENCY <= 7))
      LINK_CAP_L1_EXIT_LATENCY_BINARY = LINK_CAP_L1_EXIT_LATENCY;
    else begin
      $display("Attribute Syntax Error : The Attribute LINK_CAP_L1_EXIT_LATENCY on %s instance %m is set to %d.  Legal values for this attribute are  0 to 7.", MODULE_NAME, LINK_CAP_L1_EXIT_LATENCY);
      $finish;
    end

    if ((MSI_CAP_MULTIMSGCAP >= 0) && (MSI_CAP_MULTIMSGCAP <= 7))
      MSI_CAP_MULTIMSGCAP_BINARY = MSI_CAP_MULTIMSGCAP;
    else begin
      $display("Attribute Syntax Error : The Attribute MSI_CAP_MULTIMSGCAP on %s instance %m is set to %d.  Legal values for this attribute are  0 to 7.", MODULE_NAME, MSI_CAP_MULTIMSGCAP);
      $finish;
    end

    if ((MSI_CAP_MULTIMSG_EXTENSION >= 0) && (MSI_CAP_MULTIMSG_EXTENSION <= 1))
      MSI_CAP_MULTIMSG_EXTENSION_BINARY = MSI_CAP_MULTIMSG_EXTENSION;
    else begin
      $display("Attribute Syntax Error : The Attribute MSI_CAP_MULTIMSG_EXTENSION on %s instance %m is set to %d.  Legal values for this attribute are  0 to 1.", MODULE_NAME, MSI_CAP_MULTIMSG_EXTENSION);
      $finish;
    end

    if ((PCIE_CAP_INT_MSG_NUM >= 0) && (PCIE_CAP_INT_MSG_NUM <= 31))
      PCIE_CAP_INT_MSG_NUM_BINARY = PCIE_CAP_INT_MSG_NUM;
    else begin
      $display("Attribute Syntax Error : The Attribute PCIE_CAP_INT_MSG_NUM on %s instance %m is set to %d.  Legal values for this attribute are  0 to 31.", MODULE_NAME, PCIE_CAP_INT_MSG_NUM);
      $finish;
    end

    if ((PM_CAP_AUXCURRENT >= 0) && (PM_CAP_AUXCURRENT <= 7))
      PM_CAP_AUXCURRENT_BINARY = PM_CAP_AUXCURRENT;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_CAP_AUXCURRENT on %s instance %m is set to %d.  Legal values for this attribute are  0 to 7.", MODULE_NAME, PM_CAP_AUXCURRENT);
      $finish;
    end

    if ((PM_CAP_PMESUPPORT >= 0) && (PM_CAP_PMESUPPORT <= 31))
      PM_CAP_PMESUPPORT_BINARY = PM_CAP_PMESUPPORT;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_CAP_PMESUPPORT on %s instance %m is set to %d.  Legal values for this attribute are  0 to 31.", MODULE_NAME,PM_CAP_PMESUPPORT);
      $finish;
    end

    if ((PM_CAP_VERSION >= 0) && (PM_CAP_VERSION <= 7))
      PM_CAP_VERSION_BINARY = PM_CAP_VERSION;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_CAP_VERSION on %s instance %m is set to %d.  Legal values for this attribute are  0 to 7.", MODULE_NAME, PM_CAP_VERSION);
      $finish;
    end

    if ((PM_DATA_SCALE0 >= 0) && (PM_DATA_SCALE0 <= 3))
      PM_DATA_SCALE0_BINARY = PM_DATA_SCALE0;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_DATA_SCALE0 on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, PM_DATA_SCALE0);
      $finish;
    end

    if ((PM_DATA_SCALE1 >= 0) && (PM_DATA_SCALE1 <= 3))
      PM_DATA_SCALE1_BINARY = PM_DATA_SCALE1;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_DATA_SCALE1 on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, PM_DATA_SCALE1);
      $finish;
    end

    if ((PM_DATA_SCALE2 >= 0) && (PM_DATA_SCALE2 <= 3))
      PM_DATA_SCALE2_BINARY = PM_DATA_SCALE2;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_DATA_SCALE2 on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, PM_DATA_SCALE2);
      $finish;
    end

    if ((PM_DATA_SCALE3 >= 0) && (PM_DATA_SCALE3 <= 3))
      PM_DATA_SCALE3_BINARY = PM_DATA_SCALE3;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_DATA_SCALE3 on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, PM_DATA_SCALE3);
      $finish;
    end

    if ((PM_DATA_SCALE4 >= 0) && (PM_DATA_SCALE4 <= 3))
      PM_DATA_SCALE4_BINARY = PM_DATA_SCALE4;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_DATA_SCALE4 on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, PM_DATA_SCALE4);
      $finish;
    end

    if ((PM_DATA_SCALE5 >= 0) && (PM_DATA_SCALE5 <= 3))
      PM_DATA_SCALE5_BINARY = PM_DATA_SCALE5;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_DATA_SCALE5 on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, PM_DATA_SCALE5);
      $finish;
    end

    if ((PM_DATA_SCALE6 >= 0) && (PM_DATA_SCALE6 <= 3))
      PM_DATA_SCALE6_BINARY = PM_DATA_SCALE6;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_DATA_SCALE6 on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, PM_DATA_SCALE6);
      $finish;
    end

    if ((PM_DATA_SCALE7 >= 0) && (PM_DATA_SCALE7 <= 3))
      PM_DATA_SCALE7_BINARY = PM_DATA_SCALE7;
    else begin
      $display("Attribute Syntax Error : The Attribute PM_DATA_SCALE7 on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, PM_DATA_SCALE7);
      $finish;
    end

    if ((TL_RX_RAM_RADDR_LATENCY >= 0) && (TL_RX_RAM_RADDR_LATENCY <= 1))
      TL_RX_RAM_RADDR_LATENCY_BINARY = TL_RX_RAM_RADDR_LATENCY;
    else begin
      $display("Attribute Syntax Error : The Attribute TL_RX_RAM_RADDR_LATENCY on %s instance %m is set to %d.  Legal values for this attribute are  0 to 1.", MODULE_NAME, TL_RX_RAM_RADDR_LATENCY);
      $finish;
    end

    if ((TL_RX_RAM_RDATA_LATENCY >= 0) && (TL_RX_RAM_RDATA_LATENCY <= 3))
      TL_RX_RAM_RDATA_LATENCY_BINARY = TL_RX_RAM_RDATA_LATENCY;
    else begin
      $display("Attribute Syntax Error : The Attribute TL_RX_RAM_RDATA_LATENCY on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, TL_RX_RAM_RDATA_LATENCY);
      $finish;
    end

    if ((TL_RX_RAM_WRITE_LATENCY >= 0) && (TL_RX_RAM_WRITE_LATENCY <= 1))
      TL_RX_RAM_WRITE_LATENCY_BINARY = TL_RX_RAM_WRITE_LATENCY;
    else begin
      $display("Attribute Syntax Error : The Attribute TL_RX_RAM_WRITE_LATENCY on %s instance %m is set to %d.  Legal values for this attribute are  0 to 1.", MODULE_NAME, TL_RX_RAM_WRITE_LATENCY);
      $finish;
    end

    if ((TL_TX_RAM_RADDR_LATENCY >= 0) && (TL_TX_RAM_RADDR_LATENCY <= 1))
      TL_TX_RAM_RADDR_LATENCY_BINARY = TL_TX_RAM_RADDR_LATENCY;
    else begin
      $display("Attribute Syntax Error : The Attribute TL_TX_RAM_RADDR_LATENCY on %s instance %m is set to %d.  Legal values for this attribute are  0 to 1.", MODULE_NAME, TL_TX_RAM_RADDR_LATENCY);
      $finish;
    end

    if ((TL_TX_RAM_RDATA_LATENCY >= 0) && (TL_TX_RAM_RDATA_LATENCY <= 3))
      TL_TX_RAM_RDATA_LATENCY_BINARY = TL_TX_RAM_RDATA_LATENCY;
    else begin
      $display("Attribute Syntax Error : The Attribute TL_TX_RAM_RDATA_LATENCY on %s instance %m is set to %d.  Legal values for this attribute are  0 to 3.", MODULE_NAME, TL_TX_RAM_RDATA_LATENCY);
      $finish;
    end

    if ((VC0_TOTAL_CREDITS_CD >= 0) && (VC0_TOTAL_CREDITS_CD <= 2047))
      VC0_TOTAL_CREDITS_CD_BINARY = VC0_TOTAL_CREDITS_CD;
    else begin
      $display("Attribute Syntax Error : The Attribute VC0_TOTAL_CREDITS_CD on %s instance %m is set to %d.  Legal values for this attribute are  0 to 2047.", MODULE_NAME, VC0_TOTAL_CREDITS_CD);
      $finish;
    end

    if ((VC0_TOTAL_CREDITS_CH >= 0) && (VC0_TOTAL_CREDITS_CH <= 127))
      VC0_TOTAL_CREDITS_CH_BINARY = VC0_TOTAL_CREDITS_CH;
    else begin
      $display("Attribute Syntax Error : The Attribute VC0_TOTAL_CREDITS_CH on %s instance %m is set to %d.  Legal values for this attribute are  0 to 127.", MODULE_NAME, VC0_TOTAL_CREDITS_CH);
      $finish;
    end

    if ((VC0_TOTAL_CREDITS_NPH >= 0) && (VC0_TOTAL_CREDITS_NPH <= 127))
      VC0_TOTAL_CREDITS_NPH_BINARY = VC0_TOTAL_CREDITS_NPH;
    else begin
      $display("Attribute Syntax Error : The Attribute VC0_TOTAL_CREDITS_NPH on %s instance %m is set to %d.  Legal values for this attribute are  0 to 127.", MODULE_NAME, VC0_TOTAL_CREDITS_NPH);
      $finish;
    end

    if ((VC0_TOTAL_CREDITS_PD >= 0) && (VC0_TOTAL_CREDITS_PD <= 2047))
      VC0_TOTAL_CREDITS_PD_BINARY = VC0_TOTAL_CREDITS_PD;
    else begin
      $display("Attribute Syntax Error : The Attribute VC0_TOTAL_CREDITS_PD on %s instance %m is set to %d.  Legal values for this attribute are  0 to 2047.", MODULE_NAME, VC0_TOTAL_CREDITS_PD);
      $finish;
    end

    if ((VC0_TOTAL_CREDITS_PH >= 0) && (VC0_TOTAL_CREDITS_PH <= 127))
      VC0_TOTAL_CREDITS_PH_BINARY = VC0_TOTAL_CREDITS_PH;
    else begin
      $display("Attribute Syntax Error : The Attribute VC0_TOTAL_CREDITS_PH on %s instance %m is set to %d.  Legal values for this attribute are  0 to 127.", MODULE_NAME, VC0_TOTAL_CREDITS_PH);
      $finish;
    end

    if ((VC0_TX_LASTPACKET >= 0) && (VC0_TX_LASTPACKET <= 31))
      VC0_TX_LASTPACKET_BINARY = VC0_TX_LASTPACKET;
    else begin
      $display("Attribute Syntax Error : The Attribute VC0_TX_LASTPACKET on %s instance %m is set to %d.  Legal values for this attribute are  0 to 31.", MODULE_NAME, VC0_TX_LASTPACKET);
      $finish;
    end

  end


  assign CFGBUSNUMBER = CFGBUSNUMBER_OUTDELAY;
  assign CFGCOMMANDBUSMASTERENABLE = CFGCOMMANDBUSMASTERENABLE_OUTDELAY;
  assign CFGCOMMANDINTERRUPTDISABLE = CFGCOMMANDINTERRUPTDISABLE_OUTDELAY;
  assign CFGCOMMANDIOENABLE = CFGCOMMANDIOENABLE_OUTDELAY;
  assign CFGCOMMANDMEMENABLE = CFGCOMMANDMEMENABLE_OUTDELAY;
  assign CFGCOMMANDSERREN = CFGCOMMANDSERREN_OUTDELAY;
  assign CFGDEVCONTROLAUXPOWEREN = CFGDEVCONTROLAUXPOWEREN_OUTDELAY;
  assign CFGDEVCONTROLCORRERRREPORTINGEN = CFGDEVCONTROLCORRERRREPORTINGEN_OUTDELAY;
  assign CFGDEVCONTROLENABLERO = CFGDEVCONTROLENABLERO_OUTDELAY;
  assign CFGDEVCONTROLEXTTAGEN = CFGDEVCONTROLEXTTAGEN_OUTDELAY;
  assign CFGDEVCONTROLFATALERRREPORTINGEN = CFGDEVCONTROLFATALERRREPORTINGEN_OUTDELAY;
  assign CFGDEVCONTROLMAXPAYLOAD = CFGDEVCONTROLMAXPAYLOAD_OUTDELAY;
  assign CFGDEVCONTROLMAXREADREQ = CFGDEVCONTROLMAXREADREQ_OUTDELAY;
  assign CFGDEVCONTROLNONFATALREPORTINGEN = CFGDEVCONTROLNONFATALREPORTINGEN_OUTDELAY;
  assign CFGDEVCONTROLNOSNOOPEN = CFGDEVCONTROLNOSNOOPEN_OUTDELAY;
  assign CFGDEVCONTROLPHANTOMEN = CFGDEVCONTROLPHANTOMEN_OUTDELAY;
  assign CFGDEVCONTROLURERRREPORTINGEN = CFGDEVCONTROLURERRREPORTINGEN_OUTDELAY;
  assign CFGDEVICENUMBER = CFGDEVICENUMBER_OUTDELAY;
  assign CFGDEVSTATUSCORRERRDETECTED = CFGDEVSTATUSCORRERRDETECTED_OUTDELAY;
  assign CFGDEVSTATUSFATALERRDETECTED = CFGDEVSTATUSFATALERRDETECTED_OUTDELAY;
  assign CFGDEVSTATUSNONFATALERRDETECTED = CFGDEVSTATUSNONFATALERRDETECTED_OUTDELAY;
  assign CFGDEVSTATUSURDETECTED = CFGDEVSTATUSURDETECTED_OUTDELAY;
  assign CFGDO = CFGDO_OUTDELAY;
  assign CFGERRCPLRDYN = CFGERRCPLRDYN_OUTDELAY;
  assign CFGFUNCTIONNUMBER = CFGFUNCTIONNUMBER_OUTDELAY;
  assign CFGINTERRUPTDO = CFGINTERRUPTDO_OUTDELAY;
  assign CFGINTERRUPTMMENABLE = CFGINTERRUPTMMENABLE_OUTDELAY;
  assign CFGINTERRUPTMSIENABLE = CFGINTERRUPTMSIENABLE_OUTDELAY;
  assign CFGINTERRUPTRDYN = CFGINTERRUPTRDYN_OUTDELAY;
  assign CFGLINKCONTOLRCB = CFGLINKCONTOLRCB_OUTDELAY;
  assign CFGLINKCONTROLASPMCONTROL = CFGLINKCONTROLASPMCONTROL_OUTDELAY;
  assign CFGLINKCONTROLCOMMONCLOCK = CFGLINKCONTROLCOMMONCLOCK_OUTDELAY;
  assign CFGLINKCONTROLEXTENDEDSYNC = CFGLINKCONTROLEXTENDEDSYNC_OUTDELAY;
  assign CFGLTSSMSTATE = CFGLTSSMSTATE_OUTDELAY;
  assign CFGPCIELINKSTATEN = CFGPCIELINKSTATEN_OUTDELAY;
  assign CFGRDWRDONEN = CFGRDWRDONEN_OUTDELAY;
  assign CFGTOTURNOFFN = CFGTOTURNOFFN_OUTDELAY;
  assign DBGBADDLLPSTATUS = DBGBADDLLPSTATUS_OUTDELAY;
  assign DBGBADTLPLCRC = DBGBADTLPLCRC_OUTDELAY;
  assign DBGBADTLPSEQNUM = DBGBADTLPSEQNUM_OUTDELAY;
  assign DBGBADTLPSTATUS = DBGBADTLPSTATUS_OUTDELAY;
  assign DBGDLPROTOCOLSTATUS = DBGDLPROTOCOLSTATUS_OUTDELAY;
  assign DBGFCPROTOCOLERRSTATUS = DBGFCPROTOCOLERRSTATUS_OUTDELAY;
  assign DBGMLFRMDLENGTH = DBGMLFRMDLENGTH_OUTDELAY;
  assign DBGMLFRMDMPS = DBGMLFRMDMPS_OUTDELAY;
  assign DBGMLFRMDTCVC = DBGMLFRMDTCVC_OUTDELAY;
  assign DBGMLFRMDTLPSTATUS = DBGMLFRMDTLPSTATUS_OUTDELAY;
  assign DBGMLFRMDUNRECTYPE = DBGMLFRMDUNRECTYPE_OUTDELAY;
  assign DBGPOISTLPSTATUS = DBGPOISTLPSTATUS_OUTDELAY;
  assign DBGRCVROVERFLOWSTATUS = DBGRCVROVERFLOWSTATUS_OUTDELAY;
  assign DBGREGDETECTEDCORRECTABLE = DBGREGDETECTEDCORRECTABLE_OUTDELAY;
  assign DBGREGDETECTEDFATAL = DBGREGDETECTEDFATAL_OUTDELAY;
  assign DBGREGDETECTEDNONFATAL = DBGREGDETECTEDNONFATAL_OUTDELAY;
  assign DBGREGDETECTEDUNSUPPORTED = DBGREGDETECTEDUNSUPPORTED_OUTDELAY;
  assign DBGRPLYROLLOVERSTATUS = DBGRPLYROLLOVERSTATUS_OUTDELAY;
  assign DBGRPLYTIMEOUTSTATUS = DBGRPLYTIMEOUTSTATUS_OUTDELAY;
  assign DBGURNOBARHIT = DBGURNOBARHIT_OUTDELAY;
  assign DBGURPOISCFGWR = DBGURPOISCFGWR_OUTDELAY;
  assign DBGURSTATUS = DBGURSTATUS_OUTDELAY;
  assign DBGURUNSUPMSG = DBGURUNSUPMSG_OUTDELAY;
  assign MIMRXRADDR = MIMRXRADDR_OUTDELAY;
  assign MIMRXREN = MIMRXREN_OUTDELAY;
  assign MIMRXWADDR = MIMRXWADDR_OUTDELAY;
  assign MIMRXWDATA = MIMRXWDATA_OUTDELAY;
  assign MIMRXWEN = MIMRXWEN_OUTDELAY;
  assign MIMTXRADDR = MIMTXRADDR_OUTDELAY;
  assign MIMTXREN = MIMTXREN_OUTDELAY;
  assign MIMTXWADDR = MIMTXWADDR_OUTDELAY;
  assign MIMTXWDATA = MIMTXWDATA_OUTDELAY;
  assign MIMTXWEN = MIMTXWEN_OUTDELAY;
  assign PIPEGTPOWERDOWNA = PIPEGTPOWERDOWNA_OUTDELAY;
  assign PIPEGTPOWERDOWNB = PIPEGTPOWERDOWNB_OUTDELAY;
  assign PIPEGTTXELECIDLEA = PIPEGTTXELECIDLEA_OUTDELAY;
  assign PIPEGTTXELECIDLEB = PIPEGTTXELECIDLEB_OUTDELAY;
  assign PIPERXPOLARITYA = PIPERXPOLARITYA_OUTDELAY;
  assign PIPERXPOLARITYB = PIPERXPOLARITYB_OUTDELAY;
  assign PIPERXRESETA = PIPERXRESETA_OUTDELAY;
  assign PIPERXRESETB = PIPERXRESETB_OUTDELAY;
  assign PIPETXCHARDISPMODEA = PIPETXCHARDISPMODEA_OUTDELAY;
  assign PIPETXCHARDISPMODEB = PIPETXCHARDISPMODEB_OUTDELAY;
  assign PIPETXCHARDISPVALA = PIPETXCHARDISPVALA_OUTDELAY;
  assign PIPETXCHARDISPVALB = PIPETXCHARDISPVALB_OUTDELAY;
  assign PIPETXCHARISKA = PIPETXCHARISKA_OUTDELAY;
  assign PIPETXCHARISKB = PIPETXCHARISKB_OUTDELAY;
  assign PIPETXDATAA = PIPETXDATAA_OUTDELAY;
  assign PIPETXDATAB = PIPETXDATAB_OUTDELAY;
  assign PIPETXRCVRDETA = PIPETXRCVRDETA_OUTDELAY;
  assign PIPETXRCVRDETB = PIPETXRCVRDETB_OUTDELAY;
  assign RECEIVEDHOTRESET = RECEIVEDHOTRESET_OUTDELAY;
  assign TRNFCCPLD = TRNFCCPLD_OUTDELAY;
  assign TRNFCCPLH = TRNFCCPLH_OUTDELAY;
  assign TRNFCNPD = TRNFCNPD_OUTDELAY;
  assign TRNFCNPH = TRNFCNPH_OUTDELAY;
  assign TRNFCPD = TRNFCPD_OUTDELAY;
  assign TRNFCPH = TRNFCPH_OUTDELAY;
  assign TRNLNKUPN = TRNLNKUPN_OUTDELAY;
  assign TRNRBARHITN = TRNRBARHITN_OUTDELAY;
  assign TRNRD = TRNRD_OUTDELAY;
  assign TRNREOFN = TRNREOFN_OUTDELAY;
  assign TRNRERRFWDN = TRNRERRFWDN_OUTDELAY;
  assign TRNRSOFN = TRNRSOFN_OUTDELAY;
  assign TRNRSRCDSCN = TRNRSRCDSCN_OUTDELAY;
  assign TRNRSRCRDYN = TRNRSRCRDYN_OUTDELAY;
  assign TRNTBUFAV = TRNTBUFAV_OUTDELAY;
  assign TRNTCFGREQN = TRNTCFGREQN_OUTDELAY;
  assign TRNTDSTRDYN = TRNTDSTRDYN_OUTDELAY;
  assign TRNTERRDROPN = TRNTERRDROPN_OUTDELAY;
  assign USERRSTN = USERRSTN_OUTDELAY;

//----------------------------------------------------------------------
//------------------------  Input  Ports  ------------------------------
//----------------------------------------------------------------------
  assign MGTCLK_IN = MGTCLK;
  assign USERCLK_IN = USERCLK;

  assign CFGDEVID_IN = CFGDEVID;
  assign CFGDSN_IN = CFGDSN;
  assign CFGDWADDR_IN = CFGDWADDR;
  assign CFGERRCORN_IN = CFGERRCORN;
  assign CFGERRCPLABORTN_IN = CFGERRCPLABORTN;
  assign CFGERRCPLTIMEOUTN_IN = CFGERRCPLTIMEOUTN;
  assign CFGERRECRCN_IN = CFGERRECRCN;
  assign CFGERRLOCKEDN_IN = CFGERRLOCKEDN;
  assign CFGERRPOSTEDN_IN = CFGERRPOSTEDN;
  assign CFGERRTLPCPLHEADER_IN = CFGERRTLPCPLHEADER;
  assign CFGERRURN_IN = CFGERRURN;
  assign CFGINTERRUPTASSERTN_IN = CFGINTERRUPTASSERTN;
  assign CFGINTERRUPTDI_IN = CFGINTERRUPTDI;
  assign CFGINTERRUPTN_IN = CFGINTERRUPTN;
  assign CFGPMWAKEN_IN = CFGPMWAKEN;
  assign CFGRDENN_IN = CFGRDENN;
  assign CFGREVID_IN = CFGREVID;
  assign CFGSUBSYSID_IN = CFGSUBSYSID;
  assign CFGSUBSYSVENID_IN = CFGSUBSYSVENID;
  assign CFGTRNPENDINGN_IN = CFGTRNPENDINGN;
  assign CFGTURNOFFOKN_IN = CFGTURNOFFOKN;
  assign CFGVENID_IN = CFGVENID;
  assign CLOCKLOCKED_IN = CLOCKLOCKED;
  assign MIMRXRDATA_IN = MIMRXRDATA;
  assign MIMTXRDATA_IN = MIMTXRDATA;
  assign PIPEGTRESETDONEA_IN = PIPEGTRESETDONEA;
  assign PIPEGTRESETDONEB_IN = PIPEGTRESETDONEB;
  assign PIPEPHYSTATUSA_IN = PIPEPHYSTATUSA;
  assign PIPEPHYSTATUSB_IN = PIPEPHYSTATUSB;
  assign PIPERXCHARISKA_IN = PIPERXCHARISKA;
  assign PIPERXCHARISKB_IN = PIPERXCHARISKB;
  assign PIPERXDATAA_IN = PIPERXDATAA;
  assign PIPERXDATAB_IN = PIPERXDATAB;
  assign PIPERXENTERELECIDLEA_IN = PIPERXENTERELECIDLEA;
  assign PIPERXENTERELECIDLEB_IN = PIPERXENTERELECIDLEB;
  assign PIPERXSTATUSA_IN = PIPERXSTATUSA;
  assign PIPERXSTATUSB_IN = PIPERXSTATUSB;
  assign SYSRESETN_IN = SYSRESETN;
  assign TRNFCSEL_IN = TRNFCSEL;
  assign TRNRDSTRDYN_IN = TRNRDSTRDYN;
  assign TRNRNPOKN_IN = TRNRNPOKN;
  assign TRNTCFGGNTN_IN = TRNTCFGGNTN;
  assign TRNTD_IN = TRNTD;
  assign TRNTEOFN_IN = TRNTEOFN;
  assign TRNTERRFWDN_IN = TRNTERRFWDN;
  assign TRNTSOFN_IN = TRNTSOFN;
  assign TRNTSRCDSCN_IN = TRNTSRCDSCN;
  assign TRNTSRCRDYN_IN = TRNTSRCRDYN;
  assign TRNTSTRN_IN = TRNTSTRN;
  assign #(out_delay) CFGBUSNUMBER_OUTDELAY = CFGBUSNUMBER_OUT;
  assign #(out_delay) CFGCOMMANDBUSMASTERENABLE_OUTDELAY = CFGCOMMANDBUSMASTERENABLE_OUT;
  assign #(out_delay) CFGCOMMANDINTERRUPTDISABLE_OUTDELAY = CFGCOMMANDINTERRUPTDISABLE_OUT;
  assign #(out_delay) CFGCOMMANDIOENABLE_OUTDELAY = CFGCOMMANDIOENABLE_OUT;
  assign #(out_delay) CFGCOMMANDMEMENABLE_OUTDELAY = CFGCOMMANDMEMENABLE_OUT;
  assign #(out_delay) CFGCOMMANDSERREN_OUTDELAY = CFGCOMMANDSERREN_OUT;
  assign #(out_delay) CFGDEVCONTROLAUXPOWEREN_OUTDELAY = CFGDEVCONTROLAUXPOWEREN_OUT;
  assign #(out_delay) CFGDEVCONTROLCORRERRREPORTINGEN_OUTDELAY = CFGDEVCONTROLCORRERRREPORTINGEN_OUT;
  assign #(out_delay) CFGDEVCONTROLENABLERO_OUTDELAY = CFGDEVCONTROLENABLERO_OUT;
  assign #(out_delay) CFGDEVCONTROLEXTTAGEN_OUTDELAY = CFGDEVCONTROLEXTTAGEN_OUT;
  assign #(out_delay) CFGDEVCONTROLFATALERRREPORTINGEN_OUTDELAY = CFGDEVCONTROLFATALERRREPORTINGEN_OUT;
  assign #(out_delay) CFGDEVCONTROLMAXPAYLOAD_OUTDELAY = CFGDEVCONTROLMAXPAYLOAD_OUT;
  assign #(out_delay) CFGDEVCONTROLMAXREADREQ_OUTDELAY = CFGDEVCONTROLMAXREADREQ_OUT;
  assign #(out_delay) CFGDEVCONTROLNONFATALREPORTINGEN_OUTDELAY = CFGDEVCONTROLNONFATALREPORTINGEN_OUT;
  assign #(out_delay) CFGDEVCONTROLNOSNOOPEN_OUTDELAY = CFGDEVCONTROLNOSNOOPEN_OUT;
  assign #(out_delay) CFGDEVCONTROLPHANTOMEN_OUTDELAY = CFGDEVCONTROLPHANTOMEN_OUT;
  assign #(out_delay) CFGDEVCONTROLURERRREPORTINGEN_OUTDELAY = CFGDEVCONTROLURERRREPORTINGEN_OUT;
  assign #(out_delay) CFGDEVICENUMBER_OUTDELAY = CFGDEVICENUMBER_OUT;
  assign #(out_delay) CFGDEVSTATUSCORRERRDETECTED_OUTDELAY = CFGDEVSTATUSCORRERRDETECTED_OUT;
  assign #(out_delay) CFGDEVSTATUSFATALERRDETECTED_OUTDELAY = CFGDEVSTATUSFATALERRDETECTED_OUT;
  assign #(out_delay) CFGDEVSTATUSNONFATALERRDETECTED_OUTDELAY = CFGDEVSTATUSNONFATALERRDETECTED_OUT;
  assign #(out_delay) CFGDEVSTATUSURDETECTED_OUTDELAY = CFGDEVSTATUSURDETECTED_OUT;
  assign #(out_delay) CFGDO_OUTDELAY = CFGDO_OUT;
  assign #(out_delay) CFGERRCPLRDYN_OUTDELAY = CFGERRCPLRDYN_OUT;
  assign #(out_delay) CFGFUNCTIONNUMBER_OUTDELAY = CFGFUNCTIONNUMBER_OUT;
  assign #(out_delay) CFGINTERRUPTDO_OUTDELAY = CFGINTERRUPTDO_OUT;
  assign #(out_delay) CFGINTERRUPTMMENABLE_OUTDELAY = CFGINTERRUPTMMENABLE_OUT;
  assign #(out_delay) CFGINTERRUPTMSIENABLE_OUTDELAY = CFGINTERRUPTMSIENABLE_OUT;
  assign #(out_delay) CFGINTERRUPTRDYN_OUTDELAY = CFGINTERRUPTRDYN_OUT;
  assign #(out_delay) CFGLINKCONTOLRCB_OUTDELAY = CFGLINKCONTOLRCB_OUT;
  assign #(out_delay) CFGLINKCONTROLASPMCONTROL_OUTDELAY = CFGLINKCONTROLASPMCONTROL_OUT;
  assign #(out_delay) CFGLINKCONTROLCOMMONCLOCK_OUTDELAY = CFGLINKCONTROLCOMMONCLOCK_OUT;
  assign #(out_delay) CFGLINKCONTROLEXTENDEDSYNC_OUTDELAY = CFGLINKCONTROLEXTENDEDSYNC_OUT;
  assign #(out_delay) CFGLTSSMSTATE_OUTDELAY = CFGLTSSMSTATE_OUT;
  assign #(out_delay) CFGPCIELINKSTATEN_OUTDELAY = CFGPCIELINKSTATEN_OUT;
  assign #(out_delay) CFGRDWRDONEN_OUTDELAY = CFGRDWRDONEN_OUT;
  assign #(out_delay) CFGTOTURNOFFN_OUTDELAY = CFGTOTURNOFFN_OUT;
  assign #(out_delay) DBGBADDLLPSTATUS_OUTDELAY = DBGBADDLLPSTATUS_OUT;
  assign #(out_delay) DBGBADTLPLCRC_OUTDELAY = DBGBADTLPLCRC_OUT;
  assign #(out_delay) DBGBADTLPSEQNUM_OUTDELAY = DBGBADTLPSEQNUM_OUT;
  assign #(out_delay) DBGBADTLPSTATUS_OUTDELAY = DBGBADTLPSTATUS_OUT;
  assign #(out_delay) DBGDLPROTOCOLSTATUS_OUTDELAY = DBGDLPROTOCOLSTATUS_OUT;
  assign #(out_delay) DBGFCPROTOCOLERRSTATUS_OUTDELAY = DBGFCPROTOCOLERRSTATUS_OUT;
  assign #(out_delay) DBGMLFRMDLENGTH_OUTDELAY = DBGMLFRMDLENGTH_OUT;
  assign #(out_delay) DBGMLFRMDMPS_OUTDELAY = DBGMLFRMDMPS_OUT;
  assign #(out_delay) DBGMLFRMDTCVC_OUTDELAY = DBGMLFRMDTCVC_OUT;
  assign #(out_delay) DBGMLFRMDTLPSTATUS_OUTDELAY = DBGMLFRMDTLPSTATUS_OUT;
  assign #(out_delay) DBGMLFRMDUNRECTYPE_OUTDELAY = DBGMLFRMDUNRECTYPE_OUT;
  assign #(out_delay) DBGPOISTLPSTATUS_OUTDELAY = DBGPOISTLPSTATUS_OUT;
  assign #(out_delay) DBGRCVROVERFLOWSTATUS_OUTDELAY = DBGRCVROVERFLOWSTATUS_OUT;
  assign #(out_delay) DBGREGDETECTEDCORRECTABLE_OUTDELAY = DBGREGDETECTEDCORRECTABLE_OUT;
  assign #(out_delay) DBGREGDETECTEDFATAL_OUTDELAY = DBGREGDETECTEDFATAL_OUT;
  assign #(out_delay) DBGREGDETECTEDNONFATAL_OUTDELAY = DBGREGDETECTEDNONFATAL_OUT;
  assign #(out_delay) DBGREGDETECTEDUNSUPPORTED_OUTDELAY = DBGREGDETECTEDUNSUPPORTED_OUT;
  assign #(out_delay) DBGRPLYROLLOVERSTATUS_OUTDELAY = DBGRPLYROLLOVERSTATUS_OUT;
  assign #(out_delay) DBGRPLYTIMEOUTSTATUS_OUTDELAY = DBGRPLYTIMEOUTSTATUS_OUT;
  assign #(out_delay) DBGURNOBARHIT_OUTDELAY = DBGURNOBARHIT_OUT;
  assign #(out_delay) DBGURPOISCFGWR_OUTDELAY = DBGURPOISCFGWR_OUT;
  assign #(out_delay) DBGURSTATUS_OUTDELAY = DBGURSTATUS_OUT;
  assign #(out_delay) DBGURUNSUPMSG_OUTDELAY = DBGURUNSUPMSG_OUT;
  assign #(out_delay) MIMRXRADDR_OUTDELAY = MIMRXRADDR_OUT;
  assign #(out_delay) MIMRXREN_OUTDELAY = MIMRXREN_OUT;
  assign #(out_delay) MIMRXWADDR_OUTDELAY = MIMRXWADDR_OUT;
  assign #(out_delay) MIMRXWDATA_OUTDELAY = MIMRXWDATA_OUT;
  assign #(out_delay) MIMRXWEN_OUTDELAY = MIMRXWEN_OUT;
  assign #(out_delay) MIMTXRADDR_OUTDELAY = MIMTXRADDR_OUT;
  assign #(out_delay) MIMTXREN_OUTDELAY = MIMTXREN_OUT;
  assign #(out_delay) MIMTXWADDR_OUTDELAY = MIMTXWADDR_OUT;
  assign #(out_delay) MIMTXWDATA_OUTDELAY = MIMTXWDATA_OUT;
  assign #(out_delay) MIMTXWEN_OUTDELAY = MIMTXWEN_OUT;
  assign #(out_delay) PIPEGTPOWERDOWNA_OUTDELAY = PIPEGTPOWERDOWNA_OUT;
  assign #(out_delay) PIPEGTPOWERDOWNB_OUTDELAY = PIPEGTPOWERDOWNB_OUT;
  assign #(out_delay) PIPEGTTXELECIDLEA_OUTDELAY = PIPEGTTXELECIDLEA_OUT;
  assign #(out_delay) PIPEGTTXELECIDLEB_OUTDELAY = PIPEGTTXELECIDLEB_OUT;
  assign #(out_delay) PIPERXPOLARITYA_OUTDELAY = PIPERXPOLARITYA_OUT;
  assign #(out_delay) PIPERXPOLARITYB_OUTDELAY = PIPERXPOLARITYB_OUT;
  assign #(out_delay) PIPERXRESETA_OUTDELAY = PIPERXRESETA_OUT;
  assign #(out_delay) PIPERXRESETB_OUTDELAY = PIPERXRESETB_OUT;
  assign #(out_delay) PIPETXCHARDISPMODEA_OUTDELAY = PIPETXCHARDISPMODEA_OUT;
  assign #(out_delay) PIPETXCHARDISPMODEB_OUTDELAY = PIPETXCHARDISPMODEB_OUT;
  assign #(out_delay) PIPETXCHARDISPVALA_OUTDELAY = PIPETXCHARDISPVALA_OUT;
  assign #(out_delay) PIPETXCHARDISPVALB_OUTDELAY = PIPETXCHARDISPVALB_OUT;
  assign #(out_delay) PIPETXCHARISKA_OUTDELAY = PIPETXCHARISKA_OUT;
  assign #(out_delay) PIPETXCHARISKB_OUTDELAY = PIPETXCHARISKB_OUT;
  assign #(out_delay) PIPETXDATAA_OUTDELAY = PIPETXDATAA_OUT;
  assign #(out_delay) PIPETXDATAB_OUTDELAY = PIPETXDATAB_OUT;
  assign #(out_delay) PIPETXRCVRDETA_OUTDELAY = PIPETXRCVRDETA_OUT;
  assign #(out_delay) PIPETXRCVRDETB_OUTDELAY = PIPETXRCVRDETB_OUT;
  assign #(out_delay) RECEIVEDHOTRESET_OUTDELAY = RECEIVEDHOTRESET_OUT;
  assign #(out_delay) TRNFCCPLD_OUTDELAY = TRNFCCPLD_OUT;
  assign #(out_delay) TRNFCCPLH_OUTDELAY = TRNFCCPLH_OUT;
  assign #(out_delay) TRNFCNPD_OUTDELAY = TRNFCNPD_OUT;
  assign #(out_delay) TRNFCNPH_OUTDELAY = TRNFCNPH_OUT;
  assign #(out_delay) TRNFCPD_OUTDELAY = TRNFCPD_OUT;
  assign #(out_delay) TRNFCPH_OUTDELAY = TRNFCPH_OUT;
  assign #(out_delay) TRNLNKUPN_OUTDELAY = TRNLNKUPN_OUT;
  assign #(out_delay) TRNRBARHITN_OUTDELAY = TRNRBARHITN_OUT;
  assign #(out_delay) TRNRD_OUTDELAY = TRNRD_OUT;
  assign #(out_delay) TRNREOFN_OUTDELAY = TRNREOFN_OUT;
  assign #(out_delay) TRNRERRFWDN_OUTDELAY = TRNRERRFWDN_OUT;
  assign #(out_delay) TRNRSOFN_OUTDELAY = TRNRSOFN_OUT;
  assign #(out_delay) TRNRSRCDSCN_OUTDELAY = TRNRSRCDSCN_OUT;
  assign #(out_delay) TRNRSRCRDYN_OUTDELAY = TRNRSRCRDYN_OUT;
  assign #(out_delay) TRNTBUFAV_OUTDELAY = TRNTBUFAV_OUT;
  assign #(out_delay) TRNTCFGREQN_OUTDELAY = TRNTCFGREQN_OUT;
  assign #(out_delay) TRNTDSTRDYN_OUTDELAY = TRNTDSTRDYN_OUT;
  assign #(out_delay) TRNTERRDROPN_OUTDELAY = TRNTERRDROPN_OUT;
  assign #(out_delay) USERRSTN_OUTDELAY = USERRSTN_OUT;

  assign #(INCLK_DELAY) MGTCLK_INDELAY = MGTCLK_IN;
  assign #(INCLK_DELAY) USERCLK_INDELAY = USERCLK_IN;

  assign #(in_delay) CFGDEVID_INDELAY = CFGDEVID_IN;
  assign #(in_delay) CFGDSN_INDELAY = CFGDSN_IN;
  assign #(in_delay) CFGDWADDR_INDELAY = CFGDWADDR_IN;
  assign #(in_delay) CFGERRCORN_INDELAY = CFGERRCORN_IN;
  assign #(in_delay) CFGERRCPLABORTN_INDELAY = CFGERRCPLABORTN_IN;
  assign #(in_delay) CFGERRCPLTIMEOUTN_INDELAY = CFGERRCPLTIMEOUTN_IN;
  assign #(in_delay) CFGERRECRCN_INDELAY = CFGERRECRCN_IN;
  assign #(in_delay) CFGERRLOCKEDN_INDELAY = CFGERRLOCKEDN_IN;
  assign #(in_delay) CFGERRPOSTEDN_INDELAY = CFGERRPOSTEDN_IN;
  assign #(in_delay) CFGERRTLPCPLHEADER_INDELAY = CFGERRTLPCPLHEADER_IN;
  assign #(in_delay) CFGERRURN_INDELAY = CFGERRURN_IN;
  assign #(in_delay) CFGINTERRUPTASSERTN_INDELAY = CFGINTERRUPTASSERTN_IN;
  assign #(in_delay) CFGINTERRUPTDI_INDELAY = CFGINTERRUPTDI_IN;
  assign #(in_delay) CFGINTERRUPTN_INDELAY = CFGINTERRUPTN_IN;
  assign #(in_delay) CFGPMWAKEN_INDELAY = CFGPMWAKEN_IN;
  assign #(in_delay) CFGRDENN_INDELAY = CFGRDENN_IN;
  assign #(in_delay) CFGREVID_INDELAY = CFGREVID_IN;
  assign #(in_delay) CFGSUBSYSID_INDELAY = CFGSUBSYSID_IN;
  assign #(in_delay) CFGSUBSYSVENID_INDELAY = CFGSUBSYSVENID_IN;
  assign #(in_delay) CFGTRNPENDINGN_INDELAY = CFGTRNPENDINGN_IN;
  assign #(in_delay) CFGTURNOFFOKN_INDELAY = CFGTURNOFFOKN_IN;
  assign #(in_delay) CFGVENID_INDELAY = CFGVENID_IN;
  assign #(in_delay) CLOCKLOCKED_INDELAY = CLOCKLOCKED_IN;
  assign #(in_delay) MIMRXRDATA_INDELAY = MIMRXRDATA_IN;
  assign #(in_delay) MIMTXRDATA_INDELAY = MIMTXRDATA_IN;
  assign #(in_delay) PIPEGTRESETDONEA_INDELAY = PIPEGTRESETDONEA_IN;
  assign #(in_delay) PIPEGTRESETDONEB_INDELAY = PIPEGTRESETDONEB_IN;
  assign #(in_delay) PIPEPHYSTATUSA_INDELAY = PIPEPHYSTATUSA_IN;
  assign #(in_delay) PIPEPHYSTATUSB_INDELAY = PIPEPHYSTATUSB_IN;
  assign #(in_delay) PIPERXCHARISKA_INDELAY = PIPERXCHARISKA_IN;
  assign #(in_delay) PIPERXCHARISKB_INDELAY = PIPERXCHARISKB_IN;
  assign #(in_delay) PIPERXDATAA_INDELAY = PIPERXDATAA_IN;
  assign #(in_delay) PIPERXDATAB_INDELAY = PIPERXDATAB_IN;
  assign #(in_delay) PIPERXENTERELECIDLEA_INDELAY = PIPERXENTERELECIDLEA_IN;
  assign #(in_delay) PIPERXENTERELECIDLEB_INDELAY = PIPERXENTERELECIDLEB_IN;
  assign #(in_delay) PIPERXSTATUSA_INDELAY = PIPERXSTATUSA_IN;
  assign #(in_delay) PIPERXSTATUSB_INDELAY = PIPERXSTATUSB_IN;
  assign #(in_delay) SYSRESETN_INDELAY = SYSRESETN_IN;
  assign #(in_delay) TRNFCSEL_INDELAY = TRNFCSEL_IN;
  assign #(in_delay) TRNRDSTRDYN_INDELAY = TRNRDSTRDYN_IN;
  assign #(in_delay) TRNRNPOKN_INDELAY = TRNRNPOKN_IN;
  assign #(in_delay) TRNTCFGGNTN_INDELAY = TRNTCFGGNTN_IN;
  assign #(in_delay) TRNTD_INDELAY = TRNTD_IN;
  assign #(in_delay) TRNTEOFN_INDELAY = TRNTEOFN_IN;
  assign #(in_delay) TRNTERRFWDN_INDELAY = TRNTERRFWDN_IN;
  assign #(in_delay) TRNTSOFN_INDELAY = TRNTSOFN_IN;
  assign #(in_delay) TRNTSRCDSCN_INDELAY = TRNTSRCDSCN_IN;
  assign #(in_delay) TRNTSRCRDYN_INDELAY = TRNTSRCRDYN_IN;
  assign #(in_delay) TRNTSTRN_INDELAY = TRNTSTRN_IN;

  B_PCIE_A1 #(
    .BAR0 (BAR0),
    .BAR1 (BAR1),
    .BAR2 (BAR2),
    .BAR3 (BAR3),
    .BAR4 (BAR4),
    .BAR5 (BAR5),
    .CARDBUS_CIS_POINTER (CARDBUS_CIS_POINTER),
    .CLASS_CODE (CLASS_CODE),
    .DEV_CAP_ENDPOINT_L0S_LATENCY (DEV_CAP_ENDPOINT_L0S_LATENCY),
    .DEV_CAP_ENDPOINT_L1_LATENCY (DEV_CAP_ENDPOINT_L1_LATENCY),
    .DEV_CAP_EXT_TAG_SUPPORTED (DEV_CAP_EXT_TAG_SUPPORTED),
    .DEV_CAP_MAX_PAYLOAD_SUPPORTED (DEV_CAP_MAX_PAYLOAD_SUPPORTED),
    .DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT (DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT),
    .DEV_CAP_ROLE_BASED_ERROR (DEV_CAP_ROLE_BASED_ERROR),
    .DISABLE_BAR_FILTERING (DISABLE_BAR_FILTERING),
    .DISABLE_ID_CHECK (DISABLE_ID_CHECK),
    .DISABLE_SCRAMBLING (DISABLE_SCRAMBLING),
    .ENABLE_RX_TD_ECRC_TRIM (ENABLE_RX_TD_ECRC_TRIM),
    .EXPANSION_ROM (EXPANSION_ROM),
    .FAST_TRAIN (FAST_TRAIN),
    .GTP_SEL (GTP_SEL),
    .LINK_CAP_ASPM_SUPPORT (LINK_CAP_ASPM_SUPPORT),
    .LINK_CAP_L0S_EXIT_LATENCY (LINK_CAP_L0S_EXIT_LATENCY),
    .LINK_CAP_L1_EXIT_LATENCY (LINK_CAP_L1_EXIT_LATENCY),
    .LINK_STATUS_SLOT_CLOCK_CONFIG (LINK_STATUS_SLOT_CLOCK_CONFIG),
    .LL_ACK_TIMEOUT (LL_ACK_TIMEOUT),
    .LL_ACK_TIMEOUT_EN (LL_ACK_TIMEOUT_EN),
    .LL_REPLAY_TIMEOUT (LL_REPLAY_TIMEOUT),
    .LL_REPLAY_TIMEOUT_EN (LL_REPLAY_TIMEOUT_EN),
    .MSI_CAP_MULTIMSGCAP (MSI_CAP_MULTIMSGCAP),
    .MSI_CAP_MULTIMSG_EXTENSION (MSI_CAP_MULTIMSG_EXTENSION),
    .PCIE_CAP_CAPABILITY_VERSION (PCIE_CAP_CAPABILITY_VERSION),
    .PCIE_CAP_DEVICE_PORT_TYPE (PCIE_CAP_DEVICE_PORT_TYPE),
    .PCIE_CAP_INT_MSG_NUM (PCIE_CAP_INT_MSG_NUM),
    .PCIE_CAP_SLOT_IMPLEMENTED (PCIE_CAP_SLOT_IMPLEMENTED),
    .PCIE_GENERIC (PCIE_GENERIC),
    .PLM_AUTO_CONFIG (PLM_AUTO_CONFIG),
    .PM_CAP_AUXCURRENT (PM_CAP_AUXCURRENT),
    .PM_CAP_D1SUPPORT (PM_CAP_D1SUPPORT),
    .PM_CAP_D2SUPPORT (PM_CAP_D2SUPPORT),
    .PM_CAP_DSI (PM_CAP_DSI),
    .PM_CAP_PMESUPPORT (PM_CAP_PMESUPPORT),
    .PM_CAP_PME_CLOCK (PM_CAP_PME_CLOCK),
    .PM_CAP_VERSION (PM_CAP_VERSION),
    .PM_DATA0 (PM_DATA0),
    .PM_DATA1 (PM_DATA1),
    .PM_DATA2 (PM_DATA2),
    .PM_DATA3 (PM_DATA3),
    .PM_DATA4 (PM_DATA4),
    .PM_DATA5 (PM_DATA5),
    .PM_DATA6 (PM_DATA6),
    .PM_DATA7 (PM_DATA7),
    .PM_DATA_SCALE0 (PM_DATA_SCALE0),
    .PM_DATA_SCALE1 (PM_DATA_SCALE1),
    .PM_DATA_SCALE2 (PM_DATA_SCALE2),
    .PM_DATA_SCALE3 (PM_DATA_SCALE3),
    .PM_DATA_SCALE4 (PM_DATA_SCALE4),
    .PM_DATA_SCALE5 (PM_DATA_SCALE5),
    .PM_DATA_SCALE6 (PM_DATA_SCALE6),
    .PM_DATA_SCALE7 (PM_DATA_SCALE7),
    .SIM_VERSION (SIM_VERSION),
    .SLOT_CAP_ATT_BUTTON_PRESENT (SLOT_CAP_ATT_BUTTON_PRESENT),
    .SLOT_CAP_ATT_INDICATOR_PRESENT (SLOT_CAP_ATT_INDICATOR_PRESENT),
    .SLOT_CAP_POWER_INDICATOR_PRESENT (SLOT_CAP_POWER_INDICATOR_PRESENT),
    .TL_RX_RAM_RADDR_LATENCY (TL_RX_RAM_RADDR_LATENCY),
    .TL_RX_RAM_RDATA_LATENCY (TL_RX_RAM_RDATA_LATENCY),
    .TL_RX_RAM_WRITE_LATENCY (TL_RX_RAM_WRITE_LATENCY),
    .TL_TFC_DISABLE (TL_TFC_DISABLE),
    .TL_TX_CHECKS_DISABLE (TL_TX_CHECKS_DISABLE),
    .TL_TX_RAM_RADDR_LATENCY (TL_TX_RAM_RADDR_LATENCY),
    .TL_TX_RAM_RDATA_LATENCY (TL_TX_RAM_RDATA_LATENCY),
    .USR_CFG (USR_CFG),
    .USR_EXT_CFG (USR_EXT_CFG),
    .VC0_CPL_INFINITE (VC0_CPL_INFINITE),
    .VC0_RX_RAM_LIMIT (VC0_RX_RAM_LIMIT),
    .VC0_TOTAL_CREDITS_CD (VC0_TOTAL_CREDITS_CD),
    .VC0_TOTAL_CREDITS_CH (VC0_TOTAL_CREDITS_CH),
    .VC0_TOTAL_CREDITS_NPH (VC0_TOTAL_CREDITS_NPH),
    .VC0_TOTAL_CREDITS_PD (VC0_TOTAL_CREDITS_PD),
    .VC0_TOTAL_CREDITS_PH (VC0_TOTAL_CREDITS_PH),
    .VC0_TX_LASTPACKET (VC0_TX_LASTPACKET))

    B_PCIE_A1_INST (
    .GSR  (GSR),
    .CFGBUSNUMBER (CFGBUSNUMBER_OUT),
    .CFGCOMMANDBUSMASTERENABLE (CFGCOMMANDBUSMASTERENABLE_OUT),
    .CFGCOMMANDINTERRUPTDISABLE (CFGCOMMANDINTERRUPTDISABLE_OUT),
    .CFGCOMMANDIOENABLE (CFGCOMMANDIOENABLE_OUT),
    .CFGCOMMANDMEMENABLE (CFGCOMMANDMEMENABLE_OUT),
    .CFGCOMMANDSERREN (CFGCOMMANDSERREN_OUT),
    .CFGDEVCONTROLAUXPOWEREN (CFGDEVCONTROLAUXPOWEREN_OUT),
    .CFGDEVCONTROLCORRERRREPORTINGEN (CFGDEVCONTROLCORRERRREPORTINGEN_OUT),
    .CFGDEVCONTROLENABLERO (CFGDEVCONTROLENABLERO_OUT),
    .CFGDEVCONTROLEXTTAGEN (CFGDEVCONTROLEXTTAGEN_OUT),
    .CFGDEVCONTROLFATALERRREPORTINGEN (CFGDEVCONTROLFATALERRREPORTINGEN_OUT),
    .CFGDEVCONTROLMAXPAYLOAD (CFGDEVCONTROLMAXPAYLOAD_OUT),
    .CFGDEVCONTROLMAXREADREQ (CFGDEVCONTROLMAXREADREQ_OUT),
    .CFGDEVCONTROLNONFATALREPORTINGEN (CFGDEVCONTROLNONFATALREPORTINGEN_OUT),
    .CFGDEVCONTROLNOSNOOPEN (CFGDEVCONTROLNOSNOOPEN_OUT),
    .CFGDEVCONTROLPHANTOMEN (CFGDEVCONTROLPHANTOMEN_OUT),
    .CFGDEVCONTROLURERRREPORTINGEN (CFGDEVCONTROLURERRREPORTINGEN_OUT),
    .CFGDEVICENUMBER (CFGDEVICENUMBER_OUT),
    .CFGDEVSTATUSCORRERRDETECTED (CFGDEVSTATUSCORRERRDETECTED_OUT),
    .CFGDEVSTATUSFATALERRDETECTED (CFGDEVSTATUSFATALERRDETECTED_OUT),
    .CFGDEVSTATUSNONFATALERRDETECTED (CFGDEVSTATUSNONFATALERRDETECTED_OUT),
    .CFGDEVSTATUSURDETECTED (CFGDEVSTATUSURDETECTED_OUT),
    .CFGDO (CFGDO_OUT),
    .CFGERRCPLRDYN (CFGERRCPLRDYN_OUT),
    .CFGFUNCTIONNUMBER (CFGFUNCTIONNUMBER_OUT),
    .CFGINTERRUPTDO (CFGINTERRUPTDO_OUT),
    .CFGINTERRUPTMMENABLE (CFGINTERRUPTMMENABLE_OUT),
    .CFGINTERRUPTMSIENABLE (CFGINTERRUPTMSIENABLE_OUT),
    .CFGINTERRUPTRDYN (CFGINTERRUPTRDYN_OUT),
    .CFGLINKCONTOLRCB (CFGLINKCONTOLRCB_OUT),
    .CFGLINKCONTROLASPMCONTROL (CFGLINKCONTROLASPMCONTROL_OUT),
    .CFGLINKCONTROLCOMMONCLOCK (CFGLINKCONTROLCOMMONCLOCK_OUT),
    .CFGLINKCONTROLEXTENDEDSYNC (CFGLINKCONTROLEXTENDEDSYNC_OUT),
    .CFGLTSSMSTATE (CFGLTSSMSTATE_OUT),
    .CFGPCIELINKSTATEN (CFGPCIELINKSTATEN_OUT),
    .CFGRDWRDONEN (CFGRDWRDONEN_OUT),
    .CFGTOTURNOFFN (CFGTOTURNOFFN_OUT),
    .DBGBADDLLPSTATUS (DBGBADDLLPSTATUS_OUT),
    .DBGBADTLPLCRC (DBGBADTLPLCRC_OUT),
    .DBGBADTLPSEQNUM (DBGBADTLPSEQNUM_OUT),
    .DBGBADTLPSTATUS (DBGBADTLPSTATUS_OUT),
    .DBGDLPROTOCOLSTATUS (DBGDLPROTOCOLSTATUS_OUT),
    .DBGFCPROTOCOLERRSTATUS (DBGFCPROTOCOLERRSTATUS_OUT),
    .DBGMLFRMDLENGTH (DBGMLFRMDLENGTH_OUT),
    .DBGMLFRMDMPS (DBGMLFRMDMPS_OUT),
    .DBGMLFRMDTCVC (DBGMLFRMDTCVC_OUT),
    .DBGMLFRMDTLPSTATUS (DBGMLFRMDTLPSTATUS_OUT),
    .DBGMLFRMDUNRECTYPE (DBGMLFRMDUNRECTYPE_OUT),
    .DBGPOISTLPSTATUS (DBGPOISTLPSTATUS_OUT),
    .DBGRCVROVERFLOWSTATUS (DBGRCVROVERFLOWSTATUS_OUT),
    .DBGREGDETECTEDCORRECTABLE (DBGREGDETECTEDCORRECTABLE_OUT),
    .DBGREGDETECTEDFATAL (DBGREGDETECTEDFATAL_OUT),
    .DBGREGDETECTEDNONFATAL (DBGREGDETECTEDNONFATAL_OUT),
    .DBGREGDETECTEDUNSUPPORTED (DBGREGDETECTEDUNSUPPORTED_OUT),
    .DBGRPLYROLLOVERSTATUS (DBGRPLYROLLOVERSTATUS_OUT),
    .DBGRPLYTIMEOUTSTATUS (DBGRPLYTIMEOUTSTATUS_OUT),
    .DBGURNOBARHIT (DBGURNOBARHIT_OUT),
    .DBGURPOISCFGWR (DBGURPOISCFGWR_OUT),
    .DBGURSTATUS (DBGURSTATUS_OUT),
    .DBGURUNSUPMSG (DBGURUNSUPMSG_OUT),
    .MIMRXRADDR (MIMRXRADDR_OUT),
    .MIMRXREN (MIMRXREN_OUT),
    .MIMRXWADDR (MIMRXWADDR_OUT),
    .MIMRXWDATA (MIMRXWDATA_OUT),
    .MIMRXWEN (MIMRXWEN_OUT),
    .MIMTXRADDR (MIMTXRADDR_OUT),
    .MIMTXREN (MIMTXREN_OUT),
    .MIMTXWADDR (MIMTXWADDR_OUT),
    .MIMTXWDATA (MIMTXWDATA_OUT),
    .MIMTXWEN (MIMTXWEN_OUT),
    .PIPEGTPOWERDOWNA (PIPEGTPOWERDOWNA_OUT),
    .PIPEGTPOWERDOWNB (PIPEGTPOWERDOWNB_OUT),
    .PIPEGTTXELECIDLEA (PIPEGTTXELECIDLEA_OUT),
    .PIPEGTTXELECIDLEB (PIPEGTTXELECIDLEB_OUT),
    .PIPERXPOLARITYA (PIPERXPOLARITYA_OUT),
    .PIPERXPOLARITYB (PIPERXPOLARITYB_OUT),
    .PIPERXRESETA (PIPERXRESETA_OUT),
    .PIPERXRESETB (PIPERXRESETB_OUT),
    .PIPETXCHARDISPMODEA (PIPETXCHARDISPMODEA_OUT),
    .PIPETXCHARDISPMODEB (PIPETXCHARDISPMODEB_OUT),
    .PIPETXCHARDISPVALA (PIPETXCHARDISPVALA_OUT),
    .PIPETXCHARDISPVALB (PIPETXCHARDISPVALB_OUT),
    .PIPETXCHARISKA (PIPETXCHARISKA_OUT),
    .PIPETXCHARISKB (PIPETXCHARISKB_OUT),
    .PIPETXDATAA (PIPETXDATAA_OUT),
    .PIPETXDATAB (PIPETXDATAB_OUT),
    .PIPETXRCVRDETA (PIPETXRCVRDETA_OUT),
    .PIPETXRCVRDETB (PIPETXRCVRDETB_OUT),
    .RECEIVEDHOTRESET (RECEIVEDHOTRESET_OUT),
    .TRNFCCPLD (TRNFCCPLD_OUT),
    .TRNFCCPLH (TRNFCCPLH_OUT),
    .TRNFCNPD (TRNFCNPD_OUT),
    .TRNFCNPH (TRNFCNPH_OUT),
    .TRNFCPD (TRNFCPD_OUT),
    .TRNFCPH (TRNFCPH_OUT),
    .TRNLNKUPN (TRNLNKUPN_OUT),
    .TRNRBARHITN (TRNRBARHITN_OUT),
    .TRNRD (TRNRD_OUT),
    .TRNREOFN (TRNREOFN_OUT),
    .TRNRERRFWDN (TRNRERRFWDN_OUT),
    .TRNRSOFN (TRNRSOFN_OUT),
    .TRNRSRCDSCN (TRNRSRCDSCN_OUT),
    .TRNRSRCRDYN (TRNRSRCRDYN_OUT),
    .TRNTBUFAV (TRNTBUFAV_OUT),
    .TRNTCFGREQN (TRNTCFGREQN_OUT),
    .TRNTDSTRDYN (TRNTDSTRDYN_OUT),
    .TRNTERRDROPN (TRNTERRDROPN_OUT),
    .USERRSTN (USERRSTN_OUT),
    .CFGDEVID (CFGDEVID_INDELAY),
    .CFGDSN (CFGDSN_INDELAY),
    .CFGDWADDR (CFGDWADDR_INDELAY),
    .CFGERRCORN (CFGERRCORN_INDELAY),
    .CFGERRCPLABORTN (CFGERRCPLABORTN_INDELAY),
    .CFGERRCPLTIMEOUTN (CFGERRCPLTIMEOUTN_INDELAY),
    .CFGERRECRCN (CFGERRECRCN_INDELAY),
    .CFGERRLOCKEDN (CFGERRLOCKEDN_INDELAY),
    .CFGERRPOSTEDN (CFGERRPOSTEDN_INDELAY),
    .CFGERRTLPCPLHEADER (CFGERRTLPCPLHEADER_INDELAY),
    .CFGERRURN (CFGERRURN_INDELAY),
    .CFGINTERRUPTASSERTN (CFGINTERRUPTASSERTN_INDELAY),
    .CFGINTERRUPTDI (CFGINTERRUPTDI_INDELAY),
    .CFGINTERRUPTN (CFGINTERRUPTN_INDELAY),
    .CFGPMWAKEN (CFGPMWAKEN_INDELAY),
    .CFGRDENN (CFGRDENN_INDELAY),
    .CFGREVID (CFGREVID_INDELAY),
    .CFGSUBSYSID (CFGSUBSYSID_INDELAY),
    .CFGSUBSYSVENID (CFGSUBSYSVENID_INDELAY),
    .CFGTRNPENDINGN (CFGTRNPENDINGN_INDELAY),
    .CFGTURNOFFOKN (CFGTURNOFFOKN_INDELAY),
    .CFGVENID (CFGVENID_INDELAY),
    .CLOCKLOCKED (CLOCKLOCKED_INDELAY),
    .MGTCLK (MGTCLK_INDELAY),
    .MIMRXRDATA (MIMRXRDATA_INDELAY),
    .MIMTXRDATA (MIMTXRDATA_INDELAY),
    .PIPEGTRESETDONEA (PIPEGTRESETDONEA_INDELAY),
    .PIPEGTRESETDONEB (PIPEGTRESETDONEB_INDELAY),
    .PIPEPHYSTATUSA (PIPEPHYSTATUSA_INDELAY),
    .PIPEPHYSTATUSB (PIPEPHYSTATUSB_INDELAY),
    .PIPERXCHARISKA (PIPERXCHARISKA_INDELAY),
    .PIPERXCHARISKB (PIPERXCHARISKB_INDELAY),
    .PIPERXDATAA (PIPERXDATAA_INDELAY),
    .PIPERXDATAB (PIPERXDATAB_INDELAY),
    .PIPERXENTERELECIDLEA (PIPERXENTERELECIDLEA_INDELAY),
    .PIPERXENTERELECIDLEB (PIPERXENTERELECIDLEB_INDELAY),
    .PIPERXSTATUSA (PIPERXSTATUSA_INDELAY),
    .PIPERXSTATUSB (PIPERXSTATUSB_INDELAY),
    .SYSRESETN (SYSRESETN_INDELAY),
    .TRNFCSEL (TRNFCSEL_INDELAY),
    .TRNRDSTRDYN (TRNRDSTRDYN_INDELAY),
    .TRNRNPOKN (TRNRNPOKN_INDELAY),
    .TRNTCFGGNTN (TRNTCFGGNTN_INDELAY),
    .TRNTD (TRNTD_INDELAY),
    .TRNTEOFN (TRNTEOFN_INDELAY),
    .TRNTERRFWDN (TRNTERRFWDN_INDELAY),
    .TRNTSOFN (TRNTSOFN_INDELAY),
    .TRNTSRCDSCN (TRNTSRCDSCN_INDELAY),
    .TRNTSRCRDYN (TRNTSRCRDYN_INDELAY),
    .TRNTSTRN (TRNTSTRN_INDELAY),
    .USERCLK (USERCLK_INDELAY)
  );

//----------------------------------------------------------------------
//------------------------ Specify Block  ------------------------------
//----------------------------------------------------------------------
  specify
    ( MGTCLK => CFGLTSSMSTATE[0]) = (0, 0);
    ( MGTCLK => CFGLTSSMSTATE[1]) = (0, 0);
    ( MGTCLK => CFGLTSSMSTATE[2]) = (0, 0);
    ( MGTCLK => CFGLTSSMSTATE[3]) = (0, 0);
    ( MGTCLK => CFGLTSSMSTATE[4]) = (0, 0);
    ( MGTCLK => PIPEGTPOWERDOWNA[0]) = (0, 0);
    ( MGTCLK => PIPEGTPOWERDOWNA[1]) = (0, 0);
    ( MGTCLK => PIPEGTPOWERDOWNB[0]) = (0, 0);
    ( MGTCLK => PIPEGTPOWERDOWNB[1]) = (0, 0);
    ( MGTCLK => PIPEGTTXELECIDLEA) = (0, 0);
    ( MGTCLK => PIPEGTTXELECIDLEB) = (0, 0);
    ( MGTCLK => PIPERXPOLARITYA) = (0, 0);
    ( MGTCLK => PIPERXPOLARITYB) = (0, 0);
    ( MGTCLK => PIPERXRESETA) = (0, 0);
    ( MGTCLK => PIPERXRESETB) = (0, 0);
    ( MGTCLK => PIPETXCHARDISPMODEA[0]) = (0, 0);
    ( MGTCLK => PIPETXCHARDISPMODEA[1]) = (0, 0);
    ( MGTCLK => PIPETXCHARDISPMODEB[0]) = (0, 0);
    ( MGTCLK => PIPETXCHARDISPMODEB[1]) = (0, 0);
    ( MGTCLK => PIPETXCHARDISPVALA[0]) = (0, 0);
    ( MGTCLK => PIPETXCHARDISPVALA[1]) = (0, 0);
    ( MGTCLK => PIPETXCHARDISPVALB[0]) = (0, 0);
    ( MGTCLK => PIPETXCHARDISPVALB[1]) = (0, 0);
    ( MGTCLK => PIPETXCHARISKA[0]) = (0, 0);
    ( MGTCLK => PIPETXCHARISKA[1]) = (0, 0);
    ( MGTCLK => PIPETXCHARISKB[0]) = (0, 0);
    ( MGTCLK => PIPETXCHARISKB[1]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[0]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[10]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[11]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[12]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[13]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[14]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[15]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[1]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[2]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[3]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[4]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[5]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[6]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[7]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[8]) = (0, 0);
    ( MGTCLK => PIPETXDATAA[9]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[0]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[10]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[11]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[12]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[13]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[14]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[15]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[1]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[2]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[3]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[4]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[5]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[6]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[7]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[8]) = (0, 0);
    ( MGTCLK => PIPETXDATAB[9]) = (0, 0);
    ( MGTCLK => PIPETXRCVRDETA) = (0, 0);
    ( MGTCLK => PIPETXRCVRDETB) = (0, 0);
    ( USERCLK => CFGBUSNUMBER[0]) = (0, 0);
    ( USERCLK => CFGBUSNUMBER[1]) = (0, 0);
    ( USERCLK => CFGBUSNUMBER[2]) = (0, 0);
    ( USERCLK => CFGBUSNUMBER[3]) = (0, 0);
    ( USERCLK => CFGBUSNUMBER[4]) = (0, 0);
    ( USERCLK => CFGBUSNUMBER[5]) = (0, 0);
    ( USERCLK => CFGBUSNUMBER[6]) = (0, 0);
    ( USERCLK => CFGBUSNUMBER[7]) = (0, 0);
    ( USERCLK => CFGCOMMANDBUSMASTERENABLE) = (0, 0);
    ( USERCLK => CFGCOMMANDINTERRUPTDISABLE) = (0, 0);
    ( USERCLK => CFGCOMMANDIOENABLE) = (0, 0);
    ( USERCLK => CFGCOMMANDMEMENABLE) = (0, 0);
    ( USERCLK => CFGCOMMANDSERREN) = (0, 0);
    ( USERCLK => CFGDEVCONTROLAUXPOWEREN) = (0, 0);
    ( USERCLK => CFGDEVCONTROLCORRERRREPORTINGEN) = (0, 0);
    ( USERCLK => CFGDEVCONTROLENABLERO) = (0, 0);
    ( USERCLK => CFGDEVCONTROLEXTTAGEN) = (0, 0);
    ( USERCLK => CFGDEVCONTROLFATALERRREPORTINGEN) = (0, 0);
    ( USERCLK => CFGDEVCONTROLMAXPAYLOAD[0]) = (0, 0);
    ( USERCLK => CFGDEVCONTROLMAXPAYLOAD[1]) = (0, 0);
    ( USERCLK => CFGDEVCONTROLMAXPAYLOAD[2]) = (0, 0);
    ( USERCLK => CFGDEVCONTROLMAXREADREQ[0]) = (0, 0);
    ( USERCLK => CFGDEVCONTROLMAXREADREQ[1]) = (0, 0);
    ( USERCLK => CFGDEVCONTROLMAXREADREQ[2]) = (0, 0);
    ( USERCLK => CFGDEVCONTROLNONFATALREPORTINGEN) = (0, 0);
    ( USERCLK => CFGDEVCONTROLNOSNOOPEN) = (0, 0);
    ( USERCLK => CFGDEVCONTROLPHANTOMEN) = (0, 0);
    ( USERCLK => CFGDEVCONTROLURERRREPORTINGEN) = (0, 0);
    ( USERCLK => CFGDEVICENUMBER[0]) = (0, 0);
    ( USERCLK => CFGDEVICENUMBER[1]) = (0, 0);
    ( USERCLK => CFGDEVICENUMBER[2]) = (0, 0);
    ( USERCLK => CFGDEVICENUMBER[3]) = (0, 0);
    ( USERCLK => CFGDEVICENUMBER[4]) = (0, 0);
    ( USERCLK => CFGDEVSTATUSCORRERRDETECTED) = (0, 0);
    ( USERCLK => CFGDEVSTATUSFATALERRDETECTED) = (0, 0);
    ( USERCLK => CFGDEVSTATUSNONFATALERRDETECTED) = (0, 0);
    ( USERCLK => CFGDEVSTATUSURDETECTED) = (0, 0);
    ( USERCLK => CFGDO[0]) = (0, 0);
    ( USERCLK => CFGDO[10]) = (0, 0);
    ( USERCLK => CFGDO[11]) = (0, 0);
    ( USERCLK => CFGDO[12]) = (0, 0);
    ( USERCLK => CFGDO[13]) = (0, 0);
    ( USERCLK => CFGDO[14]) = (0, 0);
    ( USERCLK => CFGDO[15]) = (0, 0);
    ( USERCLK => CFGDO[16]) = (0, 0);
    ( USERCLK => CFGDO[17]) = (0, 0);
    ( USERCLK => CFGDO[18]) = (0, 0);
    ( USERCLK => CFGDO[19]) = (0, 0);
    ( USERCLK => CFGDO[1]) = (0, 0);
    ( USERCLK => CFGDO[20]) = (0, 0);
    ( USERCLK => CFGDO[21]) = (0, 0);
    ( USERCLK => CFGDO[22]) = (0, 0);
    ( USERCLK => CFGDO[23]) = (0, 0);
    ( USERCLK => CFGDO[24]) = (0, 0);
    ( USERCLK => CFGDO[25]) = (0, 0);
    ( USERCLK => CFGDO[26]) = (0, 0);
    ( USERCLK => CFGDO[27]) = (0, 0);
    ( USERCLK => CFGDO[28]) = (0, 0);
    ( USERCLK => CFGDO[29]) = (0, 0);
    ( USERCLK => CFGDO[2]) = (0, 0);
    ( USERCLK => CFGDO[30]) = (0, 0);
    ( USERCLK => CFGDO[31]) = (0, 0);
    ( USERCLK => CFGDO[3]) = (0, 0);
    ( USERCLK => CFGDO[4]) = (0, 0);
    ( USERCLK => CFGDO[5]) = (0, 0);
    ( USERCLK => CFGDO[6]) = (0, 0);
    ( USERCLK => CFGDO[7]) = (0, 0);
    ( USERCLK => CFGDO[8]) = (0, 0);
    ( USERCLK => CFGDO[9]) = (0, 0);
    ( USERCLK => CFGERRCPLRDYN) = (0, 0);
    ( USERCLK => CFGFUNCTIONNUMBER[0]) = (0, 0);
    ( USERCLK => CFGFUNCTIONNUMBER[1]) = (0, 0);
    ( USERCLK => CFGFUNCTIONNUMBER[2]) = (0, 0);
    ( USERCLK => CFGINTERRUPTDO[0]) = (0, 0);
    ( USERCLK => CFGINTERRUPTDO[1]) = (0, 0);
    ( USERCLK => CFGINTERRUPTDO[2]) = (0, 0);
    ( USERCLK => CFGINTERRUPTDO[3]) = (0, 0);
    ( USERCLK => CFGINTERRUPTDO[4]) = (0, 0);
    ( USERCLK => CFGINTERRUPTDO[5]) = (0, 0);
    ( USERCLK => CFGINTERRUPTDO[6]) = (0, 0);
    ( USERCLK => CFGINTERRUPTDO[7]) = (0, 0);
    ( USERCLK => CFGINTERRUPTMMENABLE[0]) = (0, 0);
    ( USERCLK => CFGINTERRUPTMMENABLE[1]) = (0, 0);
    ( USERCLK => CFGINTERRUPTMMENABLE[2]) = (0, 0);
    ( USERCLK => CFGINTERRUPTMSIENABLE) = (0, 0);
    ( USERCLK => CFGINTERRUPTRDYN) = (0, 0);
    ( USERCLK => CFGLINKCONTOLRCB) = (0, 0);
    ( USERCLK => CFGLINKCONTROLASPMCONTROL[0]) = (0, 0);
    ( USERCLK => CFGLINKCONTROLASPMCONTROL[1]) = (0, 0);
    ( USERCLK => CFGLINKCONTROLCOMMONCLOCK) = (0, 0);
    ( USERCLK => CFGLINKCONTROLEXTENDEDSYNC) = (0, 0);
    ( USERCLK => CFGPCIELINKSTATEN[0]) = (0, 0);
    ( USERCLK => CFGPCIELINKSTATEN[1]) = (0, 0);
    ( USERCLK => CFGPCIELINKSTATEN[2]) = (0, 0);
    ( USERCLK => CFGRDWRDONEN) = (0, 0);
    ( USERCLK => CFGTOTURNOFFN) = (0, 0);
    ( USERCLK => DBGBADDLLPSTATUS) = (0, 0);
    ( USERCLK => DBGBADTLPLCRC) = (0, 0);
    ( USERCLK => DBGBADTLPSEQNUM) = (0, 0);
    ( USERCLK => DBGBADTLPSTATUS) = (0, 0);
    ( USERCLK => DBGDLPROTOCOLSTATUS) = (0, 0);
    ( USERCLK => DBGFCPROTOCOLERRSTATUS) = (0, 0);
    ( USERCLK => DBGMLFRMDLENGTH) = (0, 0);
    ( USERCLK => DBGMLFRMDMPS) = (0, 0);
    ( USERCLK => DBGMLFRMDTCVC) = (0, 0);
    ( USERCLK => DBGMLFRMDTLPSTATUS) = (0, 0);
    ( USERCLK => DBGMLFRMDUNRECTYPE) = (0, 0);
    ( USERCLK => DBGPOISTLPSTATUS) = (0, 0);
    ( USERCLK => DBGRCVROVERFLOWSTATUS) = (0, 0);
    ( USERCLK => DBGREGDETECTEDCORRECTABLE) = (0, 0);
    ( USERCLK => DBGREGDETECTEDFATAL) = (0, 0);
    ( USERCLK => DBGREGDETECTEDNONFATAL) = (0, 0);
    ( USERCLK => DBGREGDETECTEDUNSUPPORTED) = (0, 0);
    ( USERCLK => DBGRPLYROLLOVERSTATUS) = (0, 0);
    ( USERCLK => DBGRPLYTIMEOUTSTATUS) = (0, 0);
    ( USERCLK => DBGURNOBARHIT) = (0, 0);
    ( USERCLK => DBGURPOISCFGWR) = (0, 0);
    ( USERCLK => DBGURSTATUS) = (0, 0);
    ( USERCLK => DBGURUNSUPMSG) = (0, 0);
    ( USERCLK => MIMRXRADDR[0]) = (0, 0);
    ( USERCLK => MIMRXRADDR[10]) = (0, 0);
    ( USERCLK => MIMRXRADDR[11]) = (0, 0);
    ( USERCLK => MIMRXRADDR[1]) = (0, 0);
    ( USERCLK => MIMRXRADDR[2]) = (0, 0);
    ( USERCLK => MIMRXRADDR[3]) = (0, 0);
    ( USERCLK => MIMRXRADDR[4]) = (0, 0);
    ( USERCLK => MIMRXRADDR[5]) = (0, 0);
    ( USERCLK => MIMRXRADDR[6]) = (0, 0);
    ( USERCLK => MIMRXRADDR[7]) = (0, 0);
    ( USERCLK => MIMRXRADDR[8]) = (0, 0);
    ( USERCLK => MIMRXRADDR[9]) = (0, 0);
    ( USERCLK => MIMRXREN) = (0, 0);
    ( USERCLK => MIMRXWADDR[0]) = (0, 0);
    ( USERCLK => MIMRXWADDR[10]) = (0, 0);
    ( USERCLK => MIMRXWADDR[11]) = (0, 0);
    ( USERCLK => MIMRXWADDR[1]) = (0, 0);
    ( USERCLK => MIMRXWADDR[2]) = (0, 0);
    ( USERCLK => MIMRXWADDR[3]) = (0, 0);
    ( USERCLK => MIMRXWADDR[4]) = (0, 0);
    ( USERCLK => MIMRXWADDR[5]) = (0, 0);
    ( USERCLK => MIMRXWADDR[6]) = (0, 0);
    ( USERCLK => MIMRXWADDR[7]) = (0, 0);
    ( USERCLK => MIMRXWADDR[8]) = (0, 0);
    ( USERCLK => MIMRXWADDR[9]) = (0, 0);
    ( USERCLK => MIMRXWDATA[0]) = (0, 0);
    ( USERCLK => MIMRXWDATA[10]) = (0, 0);
    ( USERCLK => MIMRXWDATA[11]) = (0, 0);
    ( USERCLK => MIMRXWDATA[12]) = (0, 0);
    ( USERCLK => MIMRXWDATA[13]) = (0, 0);
    ( USERCLK => MIMRXWDATA[14]) = (0, 0);
    ( USERCLK => MIMRXWDATA[15]) = (0, 0);
    ( USERCLK => MIMRXWDATA[16]) = (0, 0);
    ( USERCLK => MIMRXWDATA[17]) = (0, 0);
    ( USERCLK => MIMRXWDATA[18]) = (0, 0);
    ( USERCLK => MIMRXWDATA[19]) = (0, 0);
    ( USERCLK => MIMRXWDATA[1]) = (0, 0);
    ( USERCLK => MIMRXWDATA[20]) = (0, 0);
    ( USERCLK => MIMRXWDATA[21]) = (0, 0);
    ( USERCLK => MIMRXWDATA[22]) = (0, 0);
    ( USERCLK => MIMRXWDATA[23]) = (0, 0);
    ( USERCLK => MIMRXWDATA[24]) = (0, 0);
    ( USERCLK => MIMRXWDATA[25]) = (0, 0);
    ( USERCLK => MIMRXWDATA[26]) = (0, 0);
    ( USERCLK => MIMRXWDATA[27]) = (0, 0);
    ( USERCLK => MIMRXWDATA[28]) = (0, 0);
    ( USERCLK => MIMRXWDATA[29]) = (0, 0);
    ( USERCLK => MIMRXWDATA[2]) = (0, 0);
    ( USERCLK => MIMRXWDATA[30]) = (0, 0);
    ( USERCLK => MIMRXWDATA[31]) = (0, 0);
    ( USERCLK => MIMRXWDATA[32]) = (0, 0);
    ( USERCLK => MIMRXWDATA[33]) = (0, 0);
    ( USERCLK => MIMRXWDATA[34]) = (0, 0);
    ( USERCLK => MIMRXWDATA[3]) = (0, 0);
    ( USERCLK => MIMRXWDATA[4]) = (0, 0);
    ( USERCLK => MIMRXWDATA[5]) = (0, 0);
    ( USERCLK => MIMRXWDATA[6]) = (0, 0);
    ( USERCLK => MIMRXWDATA[7]) = (0, 0);
    ( USERCLK => MIMRXWDATA[8]) = (0, 0);
    ( USERCLK => MIMRXWDATA[9]) = (0, 0);
    ( USERCLK => MIMRXWEN) = (0, 0);
    ( USERCLK => MIMTXRADDR[0]) = (0, 0);
    ( USERCLK => MIMTXRADDR[10]) = (0, 0);
    ( USERCLK => MIMTXRADDR[11]) = (0, 0);
    ( USERCLK => MIMTXRADDR[1]) = (0, 0);
    ( USERCLK => MIMTXRADDR[2]) = (0, 0);
    ( USERCLK => MIMTXRADDR[3]) = (0, 0);
    ( USERCLK => MIMTXRADDR[4]) = (0, 0);
    ( USERCLK => MIMTXRADDR[5]) = (0, 0);
    ( USERCLK => MIMTXRADDR[6]) = (0, 0);
    ( USERCLK => MIMTXRADDR[7]) = (0, 0);
    ( USERCLK => MIMTXRADDR[8]) = (0, 0);
    ( USERCLK => MIMTXRADDR[9]) = (0, 0);
    ( USERCLK => MIMTXREN) = (0, 0);
    ( USERCLK => MIMTXWADDR[0]) = (0, 0);
    ( USERCLK => MIMTXWADDR[10]) = (0, 0);
    ( USERCLK => MIMTXWADDR[11]) = (0, 0);
    ( USERCLK => MIMTXWADDR[1]) = (0, 0);
    ( USERCLK => MIMTXWADDR[2]) = (0, 0);
    ( USERCLK => MIMTXWADDR[3]) = (0, 0);
    ( USERCLK => MIMTXWADDR[4]) = (0, 0);
    ( USERCLK => MIMTXWADDR[5]) = (0, 0);
    ( USERCLK => MIMTXWADDR[6]) = (0, 0);
    ( USERCLK => MIMTXWADDR[7]) = (0, 0);
    ( USERCLK => MIMTXWADDR[8]) = (0, 0);
    ( USERCLK => MIMTXWADDR[9]) = (0, 0);
    ( USERCLK => MIMTXWDATA[0]) = (0, 0);
    ( USERCLK => MIMTXWDATA[10]) = (0, 0);
    ( USERCLK => MIMTXWDATA[11]) = (0, 0);
    ( USERCLK => MIMTXWDATA[12]) = (0, 0);
    ( USERCLK => MIMTXWDATA[13]) = (0, 0);
    ( USERCLK => MIMTXWDATA[14]) = (0, 0);
    ( USERCLK => MIMTXWDATA[15]) = (0, 0);
    ( USERCLK => MIMTXWDATA[16]) = (0, 0);
    ( USERCLK => MIMTXWDATA[17]) = (0, 0);
    ( USERCLK => MIMTXWDATA[18]) = (0, 0);
    ( USERCLK => MIMTXWDATA[19]) = (0, 0);
    ( USERCLK => MIMTXWDATA[1]) = (0, 0);
    ( USERCLK => MIMTXWDATA[20]) = (0, 0);
    ( USERCLK => MIMTXWDATA[21]) = (0, 0);
    ( USERCLK => MIMTXWDATA[22]) = (0, 0);
    ( USERCLK => MIMTXWDATA[23]) = (0, 0);
    ( USERCLK => MIMTXWDATA[24]) = (0, 0);
    ( USERCLK => MIMTXWDATA[25]) = (0, 0);
    ( USERCLK => MIMTXWDATA[26]) = (0, 0);
    ( USERCLK => MIMTXWDATA[27]) = (0, 0);
    ( USERCLK => MIMTXWDATA[28]) = (0, 0);
    ( USERCLK => MIMTXWDATA[29]) = (0, 0);
    ( USERCLK => MIMTXWDATA[2]) = (0, 0);
    ( USERCLK => MIMTXWDATA[30]) = (0, 0);
    ( USERCLK => MIMTXWDATA[31]) = (0, 0);
    ( USERCLK => MIMTXWDATA[32]) = (0, 0);
    ( USERCLK => MIMTXWDATA[33]) = (0, 0);
    ( USERCLK => MIMTXWDATA[34]) = (0, 0);
    ( USERCLK => MIMTXWDATA[35]) = (0, 0);
    ( USERCLK => MIMTXWDATA[3]) = (0, 0);
    ( USERCLK => MIMTXWDATA[4]) = (0, 0);
    ( USERCLK => MIMTXWDATA[5]) = (0, 0);
    ( USERCLK => MIMTXWDATA[6]) = (0, 0);
    ( USERCLK => MIMTXWDATA[7]) = (0, 0);
    ( USERCLK => MIMTXWDATA[8]) = (0, 0);
    ( USERCLK => MIMTXWDATA[9]) = (0, 0);
    ( USERCLK => MIMTXWEN) = (0, 0);
    ( USERCLK => RECEIVEDHOTRESET) = (0, 0);
    ( USERCLK => TRNFCCPLD[0]) = (0, 0);
    ( USERCLK => TRNFCCPLD[10]) = (0, 0);
    ( USERCLK => TRNFCCPLD[11]) = (0, 0);
    ( USERCLK => TRNFCCPLD[1]) = (0, 0);
    ( USERCLK => TRNFCCPLD[2]) = (0, 0);
    ( USERCLK => TRNFCCPLD[3]) = (0, 0);
    ( USERCLK => TRNFCCPLD[4]) = (0, 0);
    ( USERCLK => TRNFCCPLD[5]) = (0, 0);
    ( USERCLK => TRNFCCPLD[6]) = (0, 0);
    ( USERCLK => TRNFCCPLD[7]) = (0, 0);
    ( USERCLK => TRNFCCPLD[8]) = (0, 0);
    ( USERCLK => TRNFCCPLD[9]) = (0, 0);
    ( USERCLK => TRNFCCPLH[0]) = (0, 0);
    ( USERCLK => TRNFCCPLH[1]) = (0, 0);
    ( USERCLK => TRNFCCPLH[2]) = (0, 0);
    ( USERCLK => TRNFCCPLH[3]) = (0, 0);
    ( USERCLK => TRNFCCPLH[4]) = (0, 0);
    ( USERCLK => TRNFCCPLH[5]) = (0, 0);
    ( USERCLK => TRNFCCPLH[6]) = (0, 0);
    ( USERCLK => TRNFCCPLH[7]) = (0, 0);
    ( USERCLK => TRNFCNPD[0]) = (0, 0);
    ( USERCLK => TRNFCNPD[10]) = (0, 0);
    ( USERCLK => TRNFCNPD[11]) = (0, 0);
    ( USERCLK => TRNFCNPD[1]) = (0, 0);
    ( USERCLK => TRNFCNPD[2]) = (0, 0);
    ( USERCLK => TRNFCNPD[3]) = (0, 0);
    ( USERCLK => TRNFCNPD[4]) = (0, 0);
    ( USERCLK => TRNFCNPD[5]) = (0, 0);
    ( USERCLK => TRNFCNPD[6]) = (0, 0);
    ( USERCLK => TRNFCNPD[7]) = (0, 0);
    ( USERCLK => TRNFCNPD[8]) = (0, 0);
    ( USERCLK => TRNFCNPD[9]) = (0, 0);
    ( USERCLK => TRNFCNPH[0]) = (0, 0);
    ( USERCLK => TRNFCNPH[1]) = (0, 0);
    ( USERCLK => TRNFCNPH[2]) = (0, 0);
    ( USERCLK => TRNFCNPH[3]) = (0, 0);
    ( USERCLK => TRNFCNPH[4]) = (0, 0);
    ( USERCLK => TRNFCNPH[5]) = (0, 0);
    ( USERCLK => TRNFCNPH[6]) = (0, 0);
    ( USERCLK => TRNFCNPH[7]) = (0, 0);
    ( USERCLK => TRNFCPD[0]) = (0, 0);
    ( USERCLK => TRNFCPD[10]) = (0, 0);
    ( USERCLK => TRNFCPD[11]) = (0, 0);
    ( USERCLK => TRNFCPD[1]) = (0, 0);
    ( USERCLK => TRNFCPD[2]) = (0, 0);
    ( USERCLK => TRNFCPD[3]) = (0, 0);
    ( USERCLK => TRNFCPD[4]) = (0, 0);
    ( USERCLK => TRNFCPD[5]) = (0, 0);
    ( USERCLK => TRNFCPD[6]) = (0, 0);
    ( USERCLK => TRNFCPD[7]) = (0, 0);
    ( USERCLK => TRNFCPD[8]) = (0, 0);
    ( USERCLK => TRNFCPD[9]) = (0, 0);
    ( USERCLK => TRNFCPH[0]) = (0, 0);
    ( USERCLK => TRNFCPH[1]) = (0, 0);
    ( USERCLK => TRNFCPH[2]) = (0, 0);
    ( USERCLK => TRNFCPH[3]) = (0, 0);
    ( USERCLK => TRNFCPH[4]) = (0, 0);
    ( USERCLK => TRNFCPH[5]) = (0, 0);
    ( USERCLK => TRNFCPH[6]) = (0, 0);
    ( USERCLK => TRNFCPH[7]) = (0, 0);
    ( USERCLK => TRNLNKUPN) = (0, 0);
    ( USERCLK => TRNRBARHITN[0]) = (0, 0);
    ( USERCLK => TRNRBARHITN[1]) = (0, 0);
    ( USERCLK => TRNRBARHITN[2]) = (0, 0);
    ( USERCLK => TRNRBARHITN[3]) = (0, 0);
    ( USERCLK => TRNRBARHITN[4]) = (0, 0);
    ( USERCLK => TRNRBARHITN[5]) = (0, 0);
    ( USERCLK => TRNRBARHITN[6]) = (0, 0);
    ( USERCLK => TRNRD[0]) = (0, 0);
    ( USERCLK => TRNRD[10]) = (0, 0);
    ( USERCLK => TRNRD[11]) = (0, 0);
    ( USERCLK => TRNRD[12]) = (0, 0);
    ( USERCLK => TRNRD[13]) = (0, 0);
    ( USERCLK => TRNRD[14]) = (0, 0);
    ( USERCLK => TRNRD[15]) = (0, 0);
    ( USERCLK => TRNRD[16]) = (0, 0);
    ( USERCLK => TRNRD[17]) = (0, 0);
    ( USERCLK => TRNRD[18]) = (0, 0);
    ( USERCLK => TRNRD[19]) = (0, 0);
    ( USERCLK => TRNRD[1]) = (0, 0);
    ( USERCLK => TRNRD[20]) = (0, 0);
    ( USERCLK => TRNRD[21]) = (0, 0);
    ( USERCLK => TRNRD[22]) = (0, 0);
    ( USERCLK => TRNRD[23]) = (0, 0);
    ( USERCLK => TRNRD[24]) = (0, 0);
    ( USERCLK => TRNRD[25]) = (0, 0);
    ( USERCLK => TRNRD[26]) = (0, 0);
    ( USERCLK => TRNRD[27]) = (0, 0);
    ( USERCLK => TRNRD[28]) = (0, 0);
    ( USERCLK => TRNRD[29]) = (0, 0);
    ( USERCLK => TRNRD[2]) = (0, 0);
    ( USERCLK => TRNRD[30]) = (0, 0);
    ( USERCLK => TRNRD[31]) = (0, 0);
    ( USERCLK => TRNRD[3]) = (0, 0);
    ( USERCLK => TRNRD[4]) = (0, 0);
    ( USERCLK => TRNRD[5]) = (0, 0);
    ( USERCLK => TRNRD[6]) = (0, 0);
    ( USERCLK => TRNRD[7]) = (0, 0);
    ( USERCLK => TRNRD[8]) = (0, 0);
    ( USERCLK => TRNRD[9]) = (0, 0);
    ( USERCLK => TRNREOFN) = (0, 0);
    ( USERCLK => TRNRERRFWDN) = (0, 0);
    ( USERCLK => TRNRSOFN) = (0, 0);
    ( USERCLK => TRNRSRCDSCN) = (0, 0);
    ( USERCLK => TRNRSRCRDYN) = (0, 0);
    ( USERCLK => TRNTBUFAV[0]) = (0, 0);
    ( USERCLK => TRNTBUFAV[1]) = (0, 0);
    ( USERCLK => TRNTBUFAV[2]) = (0, 0);
    ( USERCLK => TRNTBUFAV[3]) = (0, 0);
    ( USERCLK => TRNTBUFAV[4]) = (0, 0);
    ( USERCLK => TRNTBUFAV[5]) = (0, 0);
    ( USERCLK => TRNTCFGREQN) = (0, 0);
    ( USERCLK => TRNTDSTRDYN) = (0, 0);
    ( USERCLK => TRNTERRDROPN) = (0, 0);
    ( USERCLK => USERRSTN) = (0, 0);

    specparam PATHPULSE$ = 0;
  endspecify
endmodule // PCIE_A1
