// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/ARAMB36_INTERNAL.v,v 1.37 2010/01/21 19:36:41 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : This is not an user primitive.
//  /   /                  Xilinx Functional Simulation Library Component 32K-Bit Data and 4K-Bit Parity Dual Port Block RAM.
// /___/   /\     Filename : ARAMB36_INTERNAL.v
// \   \  /  \    Timestamp : Tues July 26 16:43:59 PST 2005
//  \___\/\___\
//
// Revision:
//    07/26/05 - Initial version.
//    12/14/05 - Cleaned up parameter checking.
//    02/09/06 - Added collision support.
//    06/15/06 - Fixed clock edge detection (CR 232994).
//    06/27/06 - Added 2 dimensional memory array support for Virtex 4 block ram.
//    09/14/06 - Fixed collision (CR 422406).
//    10/09/06 - Fixed collision case when READ_WIDTH_A/B = 16 (CR 424558).
//    11/01/06 - Fixed collision (CR 427720).
//    12/06/06 - Added DRC to disable EN_ECC_SCRUB feature (CR 427875).
//    12/07/06 - Updated functional warning for Virtex 4 byte write feature (CR 428207).
//    01/02/07 - Fixed parity bit for Virtex 4 byte write feature (CR 431583).
//    01/04/07 - Added support of memory file to initialize memory and parity (CR 431584).
//    03/13/07 - Removed attribute INITP_FILE (CR 436003).
//    03/28/07 - Disabled V4 byte write warning when READ_WIDTH_* = 0 (CR 429400).
//    04/03/07 - Changed INIT_FILE = "NONE" as default (CR 436812).
//    06/01/07 - Added wire declaration for internal signals.
//    06/13/07 - Implemented high performace version of the model.
//    06/20/07 - Fixed collision address when cascaded block rams (CR 440250).
//    08/15/07 - Updated SSR as not supported feature in output register mode for ramb16 (CR 445314).
//    08/17/07 - Supported new memory file format (SLIB_M2.3).
//    09/18/07 - Fixed DRC check for V4 ramb16 (CR 448739).
//    10/01/07 - Added conditional statement for SSRA in cascade mode (CR 449340).
//    02/20/08 - Updated collison address when cascaded block rams (CR 451722).
//    11/04/08 - Fixed incorrect output during first clock cycle (CR 470964). 
//    11/06/08 - Added DRC for invalid input parity for ECC (CR 482976).
//    04/24/09 - Implemented X's in sbiterr and dbiterr outputs during collision in ECC mode (CR 508071).
//    08/21/09 - Fixed address checking for collision (CR 529759).
//    11/17/09 - Implemented DRC for ADDR[15] in non-cascade mode (CR 535882).
//    11/18/09 - Define tasks and functions before calling (CR 532610).
//    11/24/09 - Undo CR 535882, bitgen or map is going to tie off ADDR[15] instead.
//    12/16/09 - Enhanced memory initialization (CR 540764).
//    01/21/10 - Fixed duplicated task and function names (CR 541993).
// End Revision

`timescale 1 ps/1 ps

module ARAMB36_INTERNAL (CASCADEOUTLATA, CASCADEOUTLATB, CASCADEOUTREGA, CASCADEOUTREGB, DBITERR, DOA, DOB, DOPA, DOPB, ECCPARITY, SBITERR, 
			 ADDRA, ADDRB, CASCADEINLATA, CASCADEINLATB, CASCADEINREGA, CASCADEINREGB, CLKA, CLKB, DIA, DIB, DIPA, DIPB, ENA, ENB, GSR, REGCEA, REGCEB, REGCLKA, REGCLKB, SSRA, SSRB, WEA, WEB);

    output CASCADEOUTLATA, CASCADEOUTREGA;
    output CASCADEOUTLATB, CASCADEOUTREGB;
    output SBITERR, DBITERR;
    output [63:0] DOA;
    output [31:0] DOB;
    output [7:0] DOPA;
    output [3:0] DOPB;
    output [7:0] ECCPARITY;
    
    input ENA, CLKA, REGCLKA, SSRA, CASCADEINLATA, CASCADEINREGA, REGCEA;
    input ENB, CLKB, REGCLKB, SSRB, CASCADEINLATB, CASCADEINREGB, REGCEB;
    input GSR;
    input [15:0] ADDRA;
    input [15:0] ADDRB;
    input [63:0] DIA;
    input [63:0] DIB;
    input [3:0] DIPA;
    input [7:0] DIPB;
    input [7:0] WEA;
    input [7:0] WEB;

    parameter DOA_REG = 0;
    parameter DOB_REG = 0;
    parameter EN_ECC_READ = "FALSE";
    parameter EN_ECC_SCRUB = "FALSE";
    parameter EN_ECC_WRITE = "FALSE";
    parameter INIT_A = 72'h0;
    parameter INIT_B = 72'h0;
    parameter RAM_EXTENSION_A = "NONE";
    parameter RAM_EXTENSION_B = "NONE";
    parameter READ_WIDTH_A = 0;
    parameter READ_WIDTH_B = 0;
    parameter SETUP_ALL = 1000;
    parameter SETUP_READ_FIRST = 3000;
    parameter SIM_COLLISION_CHECK = "ALL";
    parameter SRVAL_A = 72'h0;
    parameter SRVAL_B = 72'h0;
    parameter WRITE_MODE_A = "WRITE_FIRST";
    parameter WRITE_MODE_B = "WRITE_FIRST";
    parameter WRITE_WIDTH_A = 0;
    parameter WRITE_WIDTH_B = 0;
    parameter INIT_FILE = "NONE";
    parameter SIM_MODE = "SAFE";
    
    parameter INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_40 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_41 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_42 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_43 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_44 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_45 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_46 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_47 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_48 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_49 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_50 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_51 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_52 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_53 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_54 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_55 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_56 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_57 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_58 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_59 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_60 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_61 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_62 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_63 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_64 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_65 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_66 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_67 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_68 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_69 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_70 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_71 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_72 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_73 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_74 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_75 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_76 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_77 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_78 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_79 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

// xilinx_internal_parameter on
    // WARNING !!!: This model may not work properly if the following parameters are changed.
    parameter BRAM_MODE = "TRUE_DUAL_PORT";
    parameter BRAM_SIZE = 36;
// xilinx_internal_parameter off

    localparam widest_width = (WRITE_WIDTH_A >= WRITE_WIDTH_B && WRITE_WIDTH_A >= READ_WIDTH_A && 
			       WRITE_WIDTH_A >= READ_WIDTH_B) ? WRITE_WIDTH_A : 
			      (WRITE_WIDTH_B >= WRITE_WIDTH_A && WRITE_WIDTH_B >= READ_WIDTH_A && 
			       WRITE_WIDTH_B >= READ_WIDTH_B) ? WRITE_WIDTH_B :
			      (READ_WIDTH_A >= WRITE_WIDTH_A && READ_WIDTH_A >= WRITE_WIDTH_B && 
			       READ_WIDTH_A >= READ_WIDTH_B) ? READ_WIDTH_A :
			      (READ_WIDTH_B >= WRITE_WIDTH_A && READ_WIDTH_B >= WRITE_WIDTH_B && 
			       READ_WIDTH_B >= READ_WIDTH_A) ? READ_WIDTH_B : 64;

    localparam wa_width = (WRITE_WIDTH_A == 1) ? 1 : (WRITE_WIDTH_A == 2) ? 2 : (WRITE_WIDTH_A == 4) ? 4 :
			  (WRITE_WIDTH_A == 9) ? 8 : (WRITE_WIDTH_A == 18) ? 16 : (WRITE_WIDTH_A == 36) ? 32 :
			  (WRITE_WIDTH_A == 72) ? 64 : 64;
    
    localparam wb_width = (WRITE_WIDTH_B == 1) ? 1 : (WRITE_WIDTH_B == 2) ? 2 : (WRITE_WIDTH_B == 4) ? 4 :
			  (WRITE_WIDTH_B == 9) ? 8 : (WRITE_WIDTH_B == 18) ? 16 : (WRITE_WIDTH_B == 36) ? 32 :
			  (WRITE_WIDTH_B == 72) ? 64 : 64;


    localparam wa_widthp = (WRITE_WIDTH_A == 9) ? 1 : (WRITE_WIDTH_A == 18) ? 2 : (WRITE_WIDTH_A == 36) ? 4 :
			   (WRITE_WIDTH_A == 72) ? 8 : 8;
    
    localparam wb_widthp = (WRITE_WIDTH_B == 9) ? 1 : (WRITE_WIDTH_B == 18) ? 2 : (WRITE_WIDTH_B == 36) ? 4 :
			   (WRITE_WIDTH_B == 72) ? 8 : 8;

    
    localparam ra_width = (READ_WIDTH_A == 1) ? 1 : (READ_WIDTH_A == 2) ? 2 : (READ_WIDTH_A == 4) ? 4 :
			  (READ_WIDTH_A == 9) ? 8 : (READ_WIDTH_A == 18) ? 16 : (READ_WIDTH_A == 36) ? 32 :
			  (READ_WIDTH_A == 72) ? 64 : 64;
    
    localparam rb_width = (READ_WIDTH_B == 1) ? 1 : (READ_WIDTH_B == 2) ? 2 : (READ_WIDTH_B == 4) ? 4 :
			  (READ_WIDTH_B == 9) ? 8 : (READ_WIDTH_B == 18) ? 16 : (READ_WIDTH_B == 36) ? 32 :
			  (READ_WIDTH_B == 72) ? 64 : 64;


    localparam ra_widthp = (READ_WIDTH_A == 9) ? 1 : (READ_WIDTH_A == 18) ? 2 : (READ_WIDTH_A == 36) ? 4 :
			   (READ_WIDTH_A == 72) ? 8 : 8;
    
    localparam rb_widthp = (READ_WIDTH_B == 9) ? 1 : (READ_WIDTH_B == 18) ? 2 : (READ_WIDTH_B == 36) ? 4 :
			   (READ_WIDTH_B == 72) ? 8 : 8;
    
    localparam col_addr_lsb = (widest_width == 1) ? 0 : (widest_width == 2) ? 1 : (widest_width == 4) ? 2 :
			      (widest_width == 9) ? 3 : (widest_width == 18) ? 4 : (widest_width == 36) ? 5 :
			      (widest_width == 72) ? 6 : 0;
    
    localparam width = (widest_width == 1) ? 1 : (widest_width == 2) ? 2 : (widest_width == 4) ? 4 :
		       (widest_width == 9) ? 8 : (widest_width == 18) ? 16 : (widest_width == 36) ? 32 :
		       (widest_width == 72) ? 64 : 64;    

    localparam widthp = (widest_width == 9) ? 1 : (widest_width == 18) ? 2 : (widest_width == 36) ? 4 :
			(widest_width == 72) ? 8 : 8;


    localparam r_addra_lbit_124 = (READ_WIDTH_A == 1) ? 0 : (READ_WIDTH_A == 2) ? 1 : 
			       (READ_WIDTH_A == 4) ? 2 : (READ_WIDTH_A == 9) ? 3 : 
			       (READ_WIDTH_A == 18) ? 4 : (READ_WIDTH_A == 36) ? 5 : 
			       (READ_WIDTH_A == 72) ? 6 : 10;
    
    localparam r_addrb_lbit_124 = (READ_WIDTH_B == 1) ? 0 : (READ_WIDTH_B == 2) ? 1 : 
			       (READ_WIDTH_B == 4) ? 2 : (READ_WIDTH_B == 9) ? 3 : 
			       (READ_WIDTH_B == 18) ? 4 : (READ_WIDTH_B == 36) ? 5 : 
			       (READ_WIDTH_B == 72) ? 6 : 10;

    localparam addra_lbit_124 = (WRITE_WIDTH_A == 1) ? 0 : (WRITE_WIDTH_A == 2) ? 1 : 
			       (WRITE_WIDTH_A == 4) ? 2 : (WRITE_WIDTH_A == 9) ? 3 : 
			       (WRITE_WIDTH_A == 18) ? 4 : (WRITE_WIDTH_A == 36) ? 5 : 
			       (WRITE_WIDTH_A == 72) ? 6 : 10;
    
    localparam addrb_lbit_124 = (WRITE_WIDTH_B == 1) ? 0 : (WRITE_WIDTH_B == 2) ? 1 : 
			       (WRITE_WIDTH_B == 4) ? 2 : (WRITE_WIDTH_B == 9) ? 3 : 
			       (WRITE_WIDTH_B == 18) ? 4 : (WRITE_WIDTH_B == 36) ? 5 : 
			       (WRITE_WIDTH_B == 72) ? 6 : 10;
			       
    localparam addra_bit_124 = (WRITE_WIDTH_A == 1 && widest_width == 2) ? 0 : (WRITE_WIDTH_A == 1 && widest_width == 4) ? 1 : 
			      (WRITE_WIDTH_A == 1 && widest_width == 9) ? 2 : (WRITE_WIDTH_A == 1 && widest_width == 18) ? 3 :
			      (WRITE_WIDTH_A == 1 && widest_width == 36) ? 4 : (WRITE_WIDTH_A == 1 && widest_width == 72) ? 5 :
			      (WRITE_WIDTH_A == 2 && widest_width == 4) ? 1 : (WRITE_WIDTH_A == 2 && widest_width == 9) ? 2 : 
			      (WRITE_WIDTH_A == 2 && widest_width == 18) ? 3 : (WRITE_WIDTH_A == 2 && widest_width == 36) ? 4 :
			      (WRITE_WIDTH_A == 2 && widest_width == 72) ? 5 : (WRITE_WIDTH_A == 4 && widest_width == 9) ? 2 :
			      (WRITE_WIDTH_A == 4 && widest_width == 18) ? 3 : (WRITE_WIDTH_A == 4 && widest_width == 36) ? 4 : 
			      (WRITE_WIDTH_A == 4 && widest_width == 72) ? 5 : 10;
    
    localparam r_addra_bit_124 = (READ_WIDTH_A == 1 && widest_width == 2) ? 0 : (READ_WIDTH_A == 1 && widest_width == 4) ? 1 : 
			      (READ_WIDTH_A == 1 && widest_width == 9) ? 2 : (READ_WIDTH_A == 1 && widest_width == 18) ? 3 :
			      (READ_WIDTH_A == 1 && widest_width == 36) ? 4 : (READ_WIDTH_A == 1 && widest_width == 72) ? 5 :
			      (READ_WIDTH_A == 2 && widest_width == 4) ? 1 : (READ_WIDTH_A == 2 && widest_width == 9) ? 2 : 
			      (READ_WIDTH_A == 2 && widest_width == 18) ? 3 : (READ_WIDTH_A == 2 && widest_width == 36) ? 4 :
			      (READ_WIDTH_A == 2 && widest_width == 72) ? 5 : (READ_WIDTH_A == 4 && widest_width == 9) ? 2 :
			      (READ_WIDTH_A == 4 && widest_width == 18) ? 3 : (READ_WIDTH_A == 4 && widest_width == 36) ? 4 : 
			      (READ_WIDTH_A == 4 && widest_width == 72) ? 5 : 10;

    localparam addrb_bit_124 = (WRITE_WIDTH_B == 1 && widest_width == 2) ? 0 : (WRITE_WIDTH_B == 1 && widest_width == 4) ? 1 : 
			      (WRITE_WIDTH_B == 1 && widest_width == 9) ? 2 : (WRITE_WIDTH_B == 1 && widest_width == 18) ? 3 :
			      (WRITE_WIDTH_B == 1 && widest_width == 36) ? 4 : (WRITE_WIDTH_B == 1 && widest_width == 72) ? 5 :
			      (WRITE_WIDTH_B == 2 && widest_width == 4) ? 1 : (WRITE_WIDTH_B == 2 && widest_width == 9) ? 2 : 
			      (WRITE_WIDTH_B == 2 && widest_width == 18) ? 3 : (WRITE_WIDTH_B == 2 && widest_width == 36) ? 4 :
			      (WRITE_WIDTH_B == 2 && widest_width == 72) ? 5 : (WRITE_WIDTH_B == 4 && widest_width == 9) ? 2 :
			      (WRITE_WIDTH_B == 4 && widest_width == 18) ? 3 : (WRITE_WIDTH_B == 4 && widest_width == 36) ? 4 : 
			      (WRITE_WIDTH_B == 4 && widest_width == 72) ? 5 : 10;
    
    localparam r_addrb_bit_124 = (READ_WIDTH_B == 1 && widest_width == 2) ? 0 : (READ_WIDTH_B == 1 && widest_width == 4) ? 1 : 
			      (READ_WIDTH_B == 1 && widest_width == 9) ? 2 : (READ_WIDTH_B == 1 && widest_width == 18) ? 3 :
			      (READ_WIDTH_B == 1 && widest_width == 36) ? 4 : (READ_WIDTH_B == 1 && widest_width == 72) ? 5 :
			      (READ_WIDTH_B == 2 && widest_width == 4) ? 1 : (READ_WIDTH_B == 2 && widest_width == 9) ? 2 : 
			      (READ_WIDTH_B == 2 && widest_width == 18) ? 3 : (READ_WIDTH_B == 2 && widest_width == 36) ? 4 :
			      (READ_WIDTH_B == 2 && widest_width == 72) ? 5 : (READ_WIDTH_B == 4 && widest_width == 9) ? 2 :
			      (READ_WIDTH_B == 4 && widest_width == 18) ? 3 : (READ_WIDTH_B == 4 && widest_width == 36) ? 4 : 
			      (READ_WIDTH_B == 4 && widest_width == 72) ? 5 : 10;

    localparam addra_bit_8 = (WRITE_WIDTH_A == 9 && widest_width == 18) ? 3 : (WRITE_WIDTH_A == 9 && widest_width == 36) ? 4 :
			    (WRITE_WIDTH_A == 9 && widest_width == 72) ? 5 : 10;
    
    localparam addra_bit_16 = (WRITE_WIDTH_A == 18 && widest_width == 36) ? 4 : (WRITE_WIDTH_A == 18 && widest_width == 72) ? 5 : 10;

    localparam addra_bit_32 = (WRITE_WIDTH_A == 36 && widest_width == 72) ? 5 : 10;
    

    localparam r_addra_bit_8 = (READ_WIDTH_A == 9 && widest_width == 18) ? 3 : (READ_WIDTH_A == 9 && widest_width == 36) ? 4 :
			    (READ_WIDTH_A == 9 && widest_width == 72) ? 5 : 10;
    
    localparam r_addra_bit_16 = (READ_WIDTH_A == 18 && widest_width == 36) ? 4 : (READ_WIDTH_A == 18 && widest_width == 72) ? 5 : 10;

    localparam r_addra_bit_32 = (READ_WIDTH_A == 36 && widest_width == 72) ? 5 : 10;

    localparam addrb_bit_8 = (WRITE_WIDTH_B == 9 && widest_width == 18) ? 3 : (WRITE_WIDTH_B == 9 && widest_width == 36) ? 4 :
			    (WRITE_WIDTH_B == 9 && widest_width == 72) ? 5 : 10;
    
    localparam addrb_bit_16 = (WRITE_WIDTH_B == 18 && widest_width == 36) ? 4 : (WRITE_WIDTH_B == 18 && widest_width == 72) ? 5 : 10;

    localparam addrb_bit_32 = (WRITE_WIDTH_B == 36 && widest_width == 72) ? 5 : 10;
    

    localparam r_addrb_bit_8 = (READ_WIDTH_B == 9 && widest_width == 18) ? 3 : (READ_WIDTH_B == 9 && widest_width == 36) ? 4 :
			    (READ_WIDTH_B == 9 && widest_width == 72) ? 5 : 10;
    
    localparam r_addrb_bit_16 = (READ_WIDTH_B == 18 && widest_width == 36) ? 4 : (READ_WIDTH_B == 18 && widest_width == 72) ? 5 : 10;

    localparam r_addrb_bit_32 = (READ_WIDTH_B == 36 && widest_width == 72) ? 5 : 10;

    localparam mem_size1 = (BRAM_SIZE == 18) ? 16384 : (BRAM_SIZE == 36) ? 32768 : 32768;
    localparam mem_size2 = (BRAM_SIZE == 18) ? 8192 : (BRAM_SIZE == 36) ? 16384 : 16384;
    localparam mem_size4 = (BRAM_SIZE == 18) ? 4096 : (BRAM_SIZE == 36) ? 8192 : 8192;
    localparam mem_size9 = (BRAM_SIZE == 18) ? 2048 : (BRAM_SIZE == 36) ? 4096 : 4096;
    localparam mem_size18 = (BRAM_SIZE == 18) ? 1024 : (BRAM_SIZE == 36) ? 2048 : 2048;
    localparam mem_size36 = (BRAM_SIZE == 18) ? 512 : (BRAM_SIZE == 36) ? 1024 : 1024;
    localparam mem_size72 = (BRAM_SIZE == 18) ? 0 : (BRAM_SIZE == 36) ? 512 : 512;
    
    localparam mem_depth = (widest_width == 1) ? mem_size1 : (widest_width == 2) ? mem_size2 : (widest_width == 4) ? mem_size4 : 
			   (widest_width == 9) ? mem_size9 :(widest_width == 18) ? mem_size18 : (widest_width == 36) ? mem_size36 : 
			   (widest_width == 72) ? mem_size72 : 32768;
		
    localparam memp_depth = (widest_width == 9) ? mem_size9 :(widest_width == 18) ? mem_size18 : (widest_width == 36) ? mem_size36 : 
			    (widest_width == 72) ? mem_size72 : 4096;

    reg [widest_width-1:0] tmp_mem [mem_depth-1:0];
    
    reg [width-1:0] mem [mem_depth-1:0];
    reg [widthp-1:0] memp [memp_depth-1:0];

    integer count, countp, init_mult, initp_mult, large_width;
    integer count1, countp1, i, i1, i_p, i_mem, init_offset, initp_offset;

    reg addra_in_15_reg_bram, addrb_in_15_reg_bram;
    reg addra_in_15_reg, addrb_in_15_reg;
    reg addra_in_15_reg1, addrb_in_15_reg1;
    reg junk1;
    reg [1:0] wr_mode_a, wr_mode_b, cascade_a, cascade_b;
    reg [63:0] doa_out = 64'b0, doa_buf = 64'b0, doa_outreg = 64'b0, doa_out_out = 64'b0;
    reg [31:0] dob_out = 32'b0, dob_buf = 32'b0, dob_outreg = 32'b0, dob_out_out = 32'b0;
    reg [3:0] dopb_out = 4'b0, dopb_buf = 4'b0, dopb_outreg = 4'b0, dopb_out_out = 4'b0;
    reg [7:0] dopa_out = 8'b0, dopa_buf = 8'b0, dopa_outreg = 8'b0, dopa_out_out = 8'b0;
    reg [63:0] doa_out_mux = 64'b0, doa_outreg_mux = 64'b0;
    reg [7:0]  dopa_out_mux = 8'b0, dopa_outreg_mux = 8'b0;
    reg [63:0] dob_out_mux = 64'b0, dob_outreg_mux = 64'b0;
    reg [7:0]  dopb_out_mux = 8'b0, dopb_outreg_mux = 8'b0;
    
    reg [7:0] eccparity_out;
    reg [7:0] dopr_ecc, syndrome = 8'b0;
    reg [7:0] dipb_in_ecc;
    reg [71:0] ecc_bit_position;
    reg [7:0] dip_ecc, dip_ecc_col, dipa_in_ecc_corrected;
    reg [63:0] dia_in_ecc_corrected, di_x = 64'bx;
    reg dbiterr_out = 0, sbiterr_out = 0;
    reg dbiterr_outreg = 0, sbiterr_outreg = 0;
    reg dbiterr_out_out = 0, sbiterr_out_out = 0;

    reg [7:0] wea_reg;
    reg enb_reg;
    reg [7:0] out_a = 8'b0, out_b = 8'b0, junk, web_reg, web_tmp;
    reg outp_a = 1'b0, outp_b = 1'b0, junkp;
    reg rising_clka = 1'b0, rising_clkb = 1'b0;
    reg [15:0] addra_reg, addrb_reg, addra_tmp, addrb_tmp;

    reg [63:0] dia_reg, dib_reg;
    reg [3:0] dipa_reg;
    reg [7:0] dipb_reg;
    reg [1:0] viol_type = 2'b00, seq = 2'b00;
    reg [15:0] addr_tmp;
    reg [7:0] we_tmp;
    integer viol_time = 0;
    reg col_wr_wr_msg = 1, col_wra_rdb_msg = 1, col_wrb_rda_msg = 1;
    reg [7:0] no_col = 8'b0;
    reg addr_col = 0;
    
    time curr_time, prev_time;

    wire [63:0] dib_in;
    wire [63:0] dia_in;
    wire [15:0] addra_in, addrb_in;
    wire clka_in, clkb_in, regclka_in, regclkb_in;
    wire [7:0] dipb_in;
    wire [3:0] dipa_in;
    wire ena_in, enb_in, gsr_in, regcea_in, regceb_in, ssra_in, ssrb_in;
    wire [7:0] wea_in;
    wire [7:0] web_in;
    wire cascadeinlata_in, cascadeinlatb_in;
    wire cascadeinrega_in, cascadeinregb_in;
    wire temp_wire;  // trigger NCsim at initial time
    assign temp_wire = 1;
    
 
    initial begin

	if (INIT_FILE == "NONE") begin

	    init_mult = 256/width;
	    
	    for (count = 0; count < init_mult; count = count + 1) begin
		
		init_offset = count * width;
		
		mem[count] = INIT_00[init_offset +:width];
		mem[count + (init_mult * 1)] = INIT_01[init_offset +:width];
		mem[count + (init_mult * 2)] = INIT_02[init_offset +:width];
		mem[count + (init_mult * 3)] = INIT_03[init_offset +:width];
		mem[count + (init_mult * 4)] = INIT_04[init_offset +:width];
		mem[count + (init_mult * 5)] = INIT_05[init_offset +:width];
		mem[count + (init_mult * 6)] = INIT_06[init_offset +:width];
		mem[count + (init_mult * 7)] = INIT_07[init_offset +:width];
		mem[count + (init_mult * 8)] = INIT_08[init_offset +:width];
		mem[count + (init_mult * 9)] = INIT_09[init_offset +:width];
		mem[count + (init_mult * 10)] = INIT_0A[init_offset +:width];
		mem[count + (init_mult * 11)] = INIT_0B[init_offset +:width];
		mem[count + (init_mult * 12)] = INIT_0C[init_offset +:width];
		mem[count + (init_mult * 13)] = INIT_0D[init_offset +:width];
		mem[count + (init_mult * 14)] = INIT_0E[init_offset +:width];
		mem[count + (init_mult * 15)] = INIT_0F[init_offset +:width];
		mem[count + (init_mult * 16)] = INIT_10[init_offset +:width];
		mem[count + (init_mult * 17)] = INIT_11[init_offset +:width];
		mem[count + (init_mult * 18)] = INIT_12[init_offset +:width];
		mem[count + (init_mult * 19)] = INIT_13[init_offset +:width];
		mem[count + (init_mult * 20)] = INIT_14[init_offset +:width];
		mem[count + (init_mult * 21)] = INIT_15[init_offset +:width];
		mem[count + (init_mult * 22)] = INIT_16[init_offset +:width];
		mem[count + (init_mult * 23)] = INIT_17[init_offset +:width];
		mem[count + (init_mult * 24)] = INIT_18[init_offset +:width];
		mem[count + (init_mult * 25)] = INIT_19[init_offset +:width];
		mem[count + (init_mult * 26)] = INIT_1A[init_offset +:width];
		mem[count + (init_mult * 27)] = INIT_1B[init_offset +:width];
		mem[count + (init_mult * 28)] = INIT_1C[init_offset +:width];
		mem[count + (init_mult * 29)] = INIT_1D[init_offset +:width];
		mem[count + (init_mult * 30)] = INIT_1E[init_offset +:width];
		mem[count + (init_mult * 31)] = INIT_1F[init_offset +:width];
		mem[count + (init_mult * 32)] = INIT_20[init_offset +:width];
		mem[count + (init_mult * 33)] = INIT_21[init_offset +:width];
		mem[count + (init_mult * 34)] = INIT_22[init_offset +:width];
		mem[count + (init_mult * 35)] = INIT_23[init_offset +:width];
		mem[count + (init_mult * 36)] = INIT_24[init_offset +:width];
		mem[count + (init_mult * 37)] = INIT_25[init_offset +:width];
		mem[count + (init_mult * 38)] = INIT_26[init_offset +:width];
		mem[count + (init_mult * 39)] = INIT_27[init_offset +:width];
		mem[count + (init_mult * 40)] = INIT_28[init_offset +:width];
		mem[count + (init_mult * 41)] = INIT_29[init_offset +:width];
		mem[count + (init_mult * 42)] = INIT_2A[init_offset +:width];
		mem[count + (init_mult * 43)] = INIT_2B[init_offset +:width];
		mem[count + (init_mult * 44)] = INIT_2C[init_offset +:width];
		mem[count + (init_mult * 45)] = INIT_2D[init_offset +:width];
		mem[count + (init_mult * 46)] = INIT_2E[init_offset +:width];
		mem[count + (init_mult * 47)] = INIT_2F[init_offset +:width];
		mem[count + (init_mult * 48)] = INIT_30[init_offset +:width];
		mem[count + (init_mult * 49)] = INIT_31[init_offset +:width];
		mem[count + (init_mult * 50)] = INIT_32[init_offset +:width];
		mem[count + (init_mult * 51)] = INIT_33[init_offset +:width];
		mem[count + (init_mult * 52)] = INIT_34[init_offset +:width];
		mem[count + (init_mult * 53)] = INIT_35[init_offset +:width];
		mem[count + (init_mult * 54)] = INIT_36[init_offset +:width];
		mem[count + (init_mult * 55)] = INIT_37[init_offset +:width];
		mem[count + (init_mult * 56)] = INIT_38[init_offset +:width];
		mem[count + (init_mult * 57)] = INIT_39[init_offset +:width];
		mem[count + (init_mult * 58)] = INIT_3A[init_offset +:width];
		mem[count + (init_mult * 59)] = INIT_3B[init_offset +:width];
		mem[count + (init_mult * 60)] = INIT_3C[init_offset +:width];
		mem[count + (init_mult * 61)] = INIT_3D[init_offset +:width];
		mem[count + (init_mult * 62)] = INIT_3E[init_offset +:width];
		mem[count + (init_mult * 63)] = INIT_3F[init_offset +:width];

		if (BRAM_SIZE == 36) begin
		    mem[count + (init_mult * 64)] = INIT_40[init_offset +:width];
		    mem[count + (init_mult * 65)] = INIT_41[init_offset +:width];
		    mem[count + (init_mult * 66)] = INIT_42[init_offset +:width];
		    mem[count + (init_mult * 67)] = INIT_43[init_offset +:width];
		    mem[count + (init_mult * 68)] = INIT_44[init_offset +:width];
		    mem[count + (init_mult * 69)] = INIT_45[init_offset +:width];
		    mem[count + (init_mult * 70)] = INIT_46[init_offset +:width];
		    mem[count + (init_mult * 71)] = INIT_47[init_offset +:width];
		    mem[count + (init_mult * 72)] = INIT_48[init_offset +:width];
		    mem[count + (init_mult * 73)] = INIT_49[init_offset +:width];
		    mem[count + (init_mult * 74)] = INIT_4A[init_offset +:width];
		    mem[count + (init_mult * 75)] = INIT_4B[init_offset +:width];
		    mem[count + (init_mult * 76)] = INIT_4C[init_offset +:width];
		    mem[count + (init_mult * 77)] = INIT_4D[init_offset +:width];
		    mem[count + (init_mult * 78)] = INIT_4E[init_offset +:width];
		    mem[count + (init_mult * 79)] = INIT_4F[init_offset +:width];
		    mem[count + (init_mult * 80)] = INIT_50[init_offset +:width];
		    mem[count + (init_mult * 81)] = INIT_51[init_offset +:width];
		    mem[count + (init_mult * 82)] = INIT_52[init_offset +:width];
		    mem[count + (init_mult * 83)] = INIT_53[init_offset +:width];
		    mem[count + (init_mult * 84)] = INIT_54[init_offset +:width];
		    mem[count + (init_mult * 85)] = INIT_55[init_offset +:width];
		    mem[count + (init_mult * 86)] = INIT_56[init_offset +:width];
		    mem[count + (init_mult * 87)] = INIT_57[init_offset +:width];
		    mem[count + (init_mult * 88)] = INIT_58[init_offset +:width];
		    mem[count + (init_mult * 89)] = INIT_59[init_offset +:width];
		    mem[count + (init_mult * 90)] = INIT_5A[init_offset +:width];
		    mem[count + (init_mult * 91)] = INIT_5B[init_offset +:width];
		    mem[count + (init_mult * 92)] = INIT_5C[init_offset +:width];
		    mem[count + (init_mult * 93)] = INIT_5D[init_offset +:width];
		    mem[count + (init_mult * 94)] = INIT_5E[init_offset +:width];
		    mem[count + (init_mult * 95)] = INIT_5F[init_offset +:width];
		    mem[count + (init_mult * 96)] = INIT_60[init_offset +:width];
		    mem[count + (init_mult * 97)] = INIT_61[init_offset +:width];
		    mem[count + (init_mult * 98)] = INIT_62[init_offset +:width];
		    mem[count + (init_mult * 99)] = INIT_63[init_offset +:width];
		    mem[count + (init_mult * 100)] = INIT_64[init_offset +:width];
		    mem[count + (init_mult * 101)] = INIT_65[init_offset +:width];
		    mem[count + (init_mult * 102)] = INIT_66[init_offset +:width];
		    mem[count + (init_mult * 103)] = INIT_67[init_offset +:width];
		    mem[count + (init_mult * 104)] = INIT_68[init_offset +:width];
		    mem[count + (init_mult * 105)] = INIT_69[init_offset +:width];
		    mem[count + (init_mult * 106)] = INIT_6A[init_offset +:width];
		    mem[count + (init_mult * 107)] = INIT_6B[init_offset +:width];
		    mem[count + (init_mult * 108)] = INIT_6C[init_offset +:width];
		    mem[count + (init_mult * 109)] = INIT_6D[init_offset +:width];
		    mem[count + (init_mult * 110)] = INIT_6E[init_offset +:width];
		    mem[count + (init_mult * 111)] = INIT_6F[init_offset +:width];
		    mem[count + (init_mult * 112)] = INIT_70[init_offset +:width];
		    mem[count + (init_mult * 113)] = INIT_71[init_offset +:width];
		    mem[count + (init_mult * 114)] = INIT_72[init_offset +:width];
		    mem[count + (init_mult * 115)] = INIT_73[init_offset +:width];
		    mem[count + (init_mult * 116)] = INIT_74[init_offset +:width];
		    mem[count + (init_mult * 117)] = INIT_75[init_offset +:width];
		    mem[count + (init_mult * 118)] = INIT_76[init_offset +:width];
		    mem[count + (init_mult * 119)] = INIT_77[init_offset +:width];
		    mem[count + (init_mult * 120)] = INIT_78[init_offset +:width];
		    mem[count + (init_mult * 121)] = INIT_79[init_offset +:width];
		    mem[count + (init_mult * 122)] = INIT_7A[init_offset +:width];
		    mem[count + (init_mult * 123)] = INIT_7B[init_offset +:width];
		    mem[count + (init_mult * 124)] = INIT_7C[init_offset +:width];
		    mem[count + (init_mult * 125)] = INIT_7D[init_offset +:width];
		    mem[count + (init_mult * 126)] = INIT_7E[init_offset +:width];
		    mem[count + (init_mult * 127)] = INIT_7F[init_offset +:width];
		end // if (BRAM_SIZE == 36)
	    end // for (count = 0; count < init_mult; count = count + 1)
	    
		
	    
	    if (width >= 8) begin
	    	
		initp_mult = 256/widthp;
		
		for (countp = 0; countp < initp_mult; countp = countp + 1) begin

		    initp_offset = countp * widthp;

		    memp[countp]                    = INITP_00[initp_offset +:widthp];
		    memp[countp + (initp_mult * 1)] = INITP_01[initp_offset +:widthp];
		    memp[countp + (initp_mult * 2)] = INITP_02[initp_offset +:widthp];
		    memp[countp + (initp_mult * 3)] = INITP_03[initp_offset +:widthp];
		    memp[countp + (initp_mult * 4)] = INITP_04[initp_offset +:widthp];
		    memp[countp + (initp_mult * 5)] = INITP_05[initp_offset +:widthp];
		    memp[countp + (initp_mult * 6)] = INITP_06[initp_offset +:widthp];
		    memp[countp + (initp_mult * 7)] = INITP_07[initp_offset +:widthp];
		    
		    if (BRAM_SIZE == 36) begin
			memp[countp + (initp_mult * 8)] = INITP_08[initp_offset +:widthp];
			memp[countp + (initp_mult * 9)] = INITP_09[initp_offset +:widthp];
			memp[countp + (initp_mult * 10)] = INITP_0A[initp_offset +:widthp];
			memp[countp + (initp_mult * 11)] = INITP_0B[initp_offset +:widthp];
			memp[countp + (initp_mult * 12)] = INITP_0C[initp_offset +:widthp];
			memp[countp + (initp_mult * 13)] = INITP_0D[initp_offset +:widthp];
			memp[countp + (initp_mult * 14)] = INITP_0E[initp_offset +:widthp];
			memp[countp + (initp_mult * 15)] = INITP_0F[initp_offset +:widthp];
		    end
		end // for (countp = 0; countp < initp_mult; countp = countp + 1)
	    end // if (width >= 8)

	end // if (INIT_FILE == "NONE")
	else begin

	    $readmemh (INIT_FILE, tmp_mem);

	    case (widest_width)

		1, 2, 4 : for (i_mem = 0; i_mem <= mem_depth; i_mem = i_mem + 1)
		              mem[i_mem] = tmp_mem [i_mem];
		
		9 : for (i_mem = 0; i_mem <= mem_depth; i_mem = i_mem + 1) begin
		        mem[i_mem] = tmp_mem[i_mem][0 +: 8];
		        memp[i_mem] = tmp_mem[i_mem][8 +: 1];
	            end

		18 : for (i_mem = 0; i_mem <= mem_depth; i_mem = i_mem + 1) begin
		         mem[i_mem] = tmp_mem[i_mem][0 +: 16];
		         memp[i_mem] = tmp_mem[i_mem][16 +: 2];
	             end
	    
		36 : for (i_mem = 0; i_mem <= mem_depth; i_mem = i_mem + 1) begin
		         mem[i_mem] = tmp_mem[i_mem][0 +: 32];
		         memp[i_mem] = tmp_mem[i_mem][32 +: 4];
	             end

		72 : for (i_mem = 0; i_mem <= mem_depth; i_mem = i_mem + 1) begin
		         mem[i_mem] = tmp_mem[i_mem][0 +: 64];
		         memp[i_mem] = tmp_mem[i_mem][64 +: 8];
	             end

	    endcase // case(widest_width)

	end // else: !if(INIT_FILE == "NONE")
	

	if ((SIM_MODE != "FAST") && (SIM_MODE != "SAFE")) begin
	    $display("Attribute Syntax Error : The attribute SIM_MODE on ARAMB36_INTERNAL instance %m is set to %s.  Legal values for this attribute are FAST or SAFE.", SIM_MODE);
	    $finish;
	end
    end // initial begin
    
    
    /********************* SAFE mode **************************/
    generate if (SIM_MODE == "SAFE") begin

/******************************************** task and function **************************************/
	
    task task_ram;

	input we;
	input [7:0] di;
	input dip;
	inout [7:0] mem_task;
	inout memp_task;

	begin

	    if (we == 1'b1) begin

		mem_task = di;
		
		if (width >= 8)
		    memp_task = dip;
	    end
	end

    endtask // task_ram

    
    task task_ram_col;

	input we_o;
	input we;
	input [7:0] di;
	input dip;
	inout [7:0] mem_task;
	inout memp_task;
	integer i;
	
	begin

	    if (we == 1'b1) begin

		for (i = 0; i < 8; i = i + 1)
		    if (mem_task[i] !== 1'bx || !(we === we_o && we === 1'b1))
			mem_task[i] = di[i];
		
		if (width >= 8 && (memp_task !== 1'bx || !(we === we_o && we === 1'b1)))
		    memp_task = dip;
		
	    end
	end

    endtask // task_ram_col
    

    task task_x_buf;
	input [1:0] wr_rd_mode;
	input integer do_uindex;
	input integer do_lindex;
	input integer dop_index;	
	input [63:0] do_ltmp;
	inout [63:0] do_tmp;
	input [7:0] dop_ltmp;
	inout [7:0] dop_tmp;
	integer i;

	begin

	    if (wr_rd_mode == 2'b01) begin
		for (i = do_lindex; i <= do_uindex; i = i + 1) begin
		    if (do_ltmp[i] === 1'bx)
			do_tmp[i] = 1'bx;
		end
		
		if (dop_ltmp[dop_index] === 1'bx)
		    dop_tmp[dop_index] = 1'bx;
		
	    end // if (wr_rd_mode == 2'b01)
	    else begin
		do_tmp[do_lindex +: 8] = do_ltmp[do_lindex +: 8];
		dop_tmp[dop_index] = dop_ltmp[dop_index];

	    end // else: !if(wr_rd_mode == 2'b01)
	end
	
    endtask // task_x_buf
    
    
    task task_col_wr_ram_a;

	input [1:0] seq;
	input [7:0] web_tmp;
	input [7:0] wea_tmp;
	input [63:0] dia_tmp;
	input [7:0] dipa_tmp;
	input [15:0] addrb_tmp;
	input [15:0] addra_tmp;

	begin
	    
	    case (wa_width)

		1, 2, 4 : begin
		              if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wa_width > wb_width) || seq == 2'b10) begin				  
				  if (wa_width >= width)
				      task_ram_col (web_tmp[0], wea_tmp[0], dia_tmp[wa_width-1:0], 1'b0, mem[addra_tmp[14:addra_lbit_124]], junk1);
				  else
				      task_ram_col (web_tmp[0], wea_tmp[0], dia_tmp[wa_width-1:0], 1'b0, mem[addra_tmp[14:addra_bit_124+1]][(addra_tmp[addra_bit_124:addra_lbit_124] * wa_width) +: wa_width], junk1);				      

				  if (seq == 2'b00)
				      chk_for_col_msg (wea_tmp[0], web_tmp[0], addra_tmp, addrb_tmp);
		  
			      end // if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wa_width > wb_width) || seq == 2'b10)
		          end // case: 1, 2, 4
		8 : begin
		        if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wa_width > wb_width) || seq == 2'b10) begin				  
			    if (wa_width >= width)
				task_ram_col (web_tmp[0], wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:3]], memp[addra_tmp[14:3]]);
			    else
				task_ram_col (web_tmp[0], wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:addra_bit_8+1]][(addra_tmp[addra_bit_8:3] * 8) +: 8], memp[addra_tmp[14:addra_bit_8+1]][(addra_tmp[addra_bit_8:3] * 1) +: 1]);
			    
			    if (seq == 2'b00)
				chk_for_col_msg (wea_tmp[0], web_tmp[0], addra_tmp, addrb_tmp);
				
			end // if (wa_width <= wb_width)
		     end // case: 8
		16 : begin
		         if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wa_width > wb_width) || seq == 2'b10) begin				  
			     if (wa_width >= width)
				 task_ram_col (web_tmp[0], wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:4]][0 +: 8], memp[addra_tmp[14:4]][0]);
			     else
				 task_ram_col (web_tmp[0], wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:addra_bit_16+1]][(addra_tmp[addra_bit_16:4] * 16) +: 8], memp[addra_tmp[14:addra_bit_16+1]][(addra_tmp[addra_bit_16:4] * 2) +: 1]);				     
			     
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[0], web_tmp[0], addra_tmp, addrb_tmp);

			     if (wa_width >= width)
				     task_ram_col (web_tmp[1], wea_tmp[1], dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:4]][8 +: 8], memp[addra_tmp[14:4]][1]);
			     else
				 task_ram_col (web_tmp[1], wea_tmp[1], dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:addra_bit_16+1]][((addra_tmp[addra_bit_16:4] * 16) + 8) +: 8], memp[addra_tmp[14:addra_bit_16+1]][((addra_tmp[addra_bit_16:4] * 2) + 1) +: 1]);

			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[1], web_tmp[1], addra_tmp, addrb_tmp);
			     
			 end // if (wa_width <= wb_width)
		     end // case: 16
		32 : begin
		         if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wa_width > wb_width) || seq == 2'b10) begin				  
			     task_ram_col (web_tmp[0], wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:5]][0 +: 8], memp[addra_tmp[14:5]][0]);
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[0], web_tmp[0], addra_tmp, addrb_tmp);
			     
			     task_ram_col (web_tmp[1], wea_tmp[1], dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:5]][8 +: 8], memp[addra_tmp[14:5]][1]);
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[1], web_tmp[1], addra_tmp, addrb_tmp);

			     task_ram_col (web_tmp[2], wea_tmp[2], dia_tmp[23:16], dipa_tmp[2], mem[addra_tmp[14:5]][16 +: 8], memp[addra_tmp[14:5]][2]);
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[2], web_tmp[2], addra_tmp, addrb_tmp);
			     
			     task_ram_col (web_tmp[3], wea_tmp[3], dia_tmp[31:24], dipa_tmp[3], mem[addra_tmp[14:5]][24 +: 8], memp[addra_tmp[14:5]][3]);
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[3], web_tmp[3], addra_tmp, addrb_tmp);
			     
			 end // if (wa_width <= wb_width)
		     end // case: 32
		64 : ;
		
	    endcase // case(wa_width)

	end
	
    endtask // task_col_wr_ram_a

    
    task task_col_wr_ram_b;

	input [1:0] seq;
	input [7:0] wea_tmp;
	input [7:0] web_tmp;
	input [63:0] dib_tmp;
	input [7:0] dipb_tmp;
	input [15:0] addra_tmp;
	input [15:0] addrb_tmp;

	begin

	    case (wb_width)

		1, 2, 4 : begin
		              if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wb_width > wa_width) || seq == 2'b10) begin				  
				  if (wb_width >= width)
				      task_ram_col (wea_tmp[0], web_tmp[0], dib_tmp[wb_width-1:0], 1'b0, mem[addrb_tmp[14:addrb_lbit_124]], junk1);
				  else
				      task_ram_col (wea_tmp[0], web_tmp[0], dib_tmp[wb_width-1:0], 1'b0, mem[addrb_tmp[14:addrb_bit_124+1]][(addrb_tmp[addrb_bit_124:addrb_lbit_124] * wb_width) +: wb_width], junk1);				      
				  
				  if (seq == 2'b00)
				      chk_for_col_msg (wea_tmp[0], web_tmp[0], addra_tmp, addrb_tmp);
		    
			      end // if (wb_width <= wa_width)
		          end // case: 1, 2, 4
		8 : begin
       	                if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wb_width > wa_width) || seq == 2'b10) begin				  
			    if (wb_width >= width)
				task_ram_col (wea_tmp[0], web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:3]], memp[addrb_tmp[14:3]]);
			    else
				task_ram_col (wea_tmp[0], web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:addrb_bit_8+1]][(addrb_tmp[addrb_bit_8:3] * 8) +: 8], memp[addrb_tmp[14:addrb_bit_8+1]][(addrb_tmp[addrb_bit_8:3] * 1) +: 1]);
			    
			    if (seq == 2'b00)
				chk_for_col_msg (wea_tmp[0], web_tmp[0], addra_tmp, addrb_tmp);
				
			end // if (wb_width <= wa_width)
		     end // case: 8
		16 : begin
	                 if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wb_width > wa_width) || seq == 2'b10) begin				  
			     if (wb_width >= width)
				 task_ram_col (wea_tmp[0], web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:4]][0 +: 8], memp[addrb_tmp[14:4]][0:0]);
			     else
				 task_ram_col (wea_tmp[0], web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:addrb_bit_16+1]][(addrb_tmp[addrb_bit_16:4] * 16) +: 8], memp[addrb_tmp[14:addrb_bit_16+1]][(addrb_tmp[addrb_bit_16:4] * 2) +: 1]);				     
			     
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[0], web_tmp[0], addra_tmp, addrb_tmp);


			     if (wb_width >= width)
				 task_ram_col (wea_tmp[1], web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:4]][8 +: 8], memp[addrb_tmp[14:4]][1:1]);
			     else
				 task_ram_col (wea_tmp[1], web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:addrb_bit_16+1]][((addrb_tmp[addrb_bit_16:4] * 16) + 8) +: 8], memp[addrb_tmp[14:addrb_bit_16+1]][((addrb_tmp[addrb_bit_16:4] * 2) + 1) +: 1]);
			     
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[1], web_tmp[1], addra_tmp, addrb_tmp);

			 end // if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wb_width > wa_width) || seq == 2'b10)
		     end // case: 16
		32 : begin
		         if (!(wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b1 && wb_width > wa_width) || seq == 2'b10) begin				  
			     task_ram_col (wea_tmp[0], web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:5]][0 +: 8], memp[addrb_tmp[14:5]][0:0]);
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[0], web_tmp[0], addra_tmp, addrb_tmp);

			     task_ram_col (wea_tmp[1], web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:5]][8 +: 8], memp[addrb_tmp[14:5]][1:1]);
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[1], web_tmp[1], addra_tmp, addrb_tmp);

			     task_ram_col (wea_tmp[2], web_tmp[2], dib_tmp[23:16], dipb_tmp[2], mem[addrb_tmp[14:5]][16 +: 8], memp[addrb_tmp[14:5]][2:2]);
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[2], web_tmp[2], addra_tmp, addrb_tmp);

			     task_ram_col (wea_tmp[3], web_tmp[3], dib_tmp[31:24], dipb_tmp[3], mem[addrb_tmp[14:5]][24 +: 8], memp[addrb_tmp[14:5]][3:3]);
			     if (seq == 2'b00)
				 chk_for_col_msg (wea_tmp[3], web_tmp[3], addra_tmp, addrb_tmp);
			     
			 end // if (wb_width <= wa_width)
		     end // case: 32
		64 : begin

				 task_ram_col (wea_tmp[0], web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:6]][0 +: 8], memp[addrb_tmp[14:6]][0:0]);
		                 if (seq == 2'b00)
				     chk_for_col_msg (wea_tmp[0], web_tmp[0], addra_tmp, addrb_tmp);

				 task_ram_col (wea_tmp[1], web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:6]][8 +: 8], memp[addrb_tmp[14:6]][1:1]);
				 if (seq == 2'b00)
				     chk_for_col_msg (wea_tmp[1], web_tmp[1], addra_tmp, addrb_tmp);

				 task_ram_col (wea_tmp[2], web_tmp[2], dib_tmp[23:16], dipb_tmp[2], mem[addrb_tmp[14:6]][16 +: 8], memp[addrb_tmp[14:6]][2:2]);
				 if (seq == 2'b00)
				     chk_for_col_msg (wea_tmp[2], web_tmp[2], addra_tmp, addrb_tmp);

				 task_ram_col (wea_tmp[3], web_tmp[3], dib_tmp[31:24], dipb_tmp[3], mem[addrb_tmp[14:6]][24 +: 8], memp[addrb_tmp[14:6]][3:3]);
				 if (seq == 2'b00)
				     chk_for_col_msg (wea_tmp[3], web_tmp[3], addra_tmp, addrb_tmp);

				 task_ram_col (wea_tmp[4], web_tmp[4], dib_tmp[39:32], dipb_tmp[4], mem[addrb_tmp[14:6]][32 +: 8], memp[addrb_tmp[14:6]][4:4]);
				 if (seq == 2'b00)
				     chk_for_col_msg (wea_tmp[4], web_tmp[4], addra_tmp, addrb_tmp);

				 task_ram_col (wea_tmp[5], web_tmp[5], dib_tmp[47:40], dipb_tmp[5], mem[addrb_tmp[14:6]][40 +: 8], memp[addrb_tmp[14:6]][5:5]);
				 if (seq == 2'b00)
				     chk_for_col_msg (wea_tmp[5], web_tmp[5], addra_tmp, addrb_tmp);

				 task_ram_col (wea_tmp[6], web_tmp[6], dib_tmp[55:48], dipb_tmp[6], mem[addrb_tmp[14:6]][48 +: 8], memp[addrb_tmp[14:6]][6:6]);
				 if (seq == 2'b00)
				     chk_for_col_msg (wea_tmp[6], web_tmp[6], addra_tmp, addrb_tmp);

				 task_ram_col (wea_tmp[7], web_tmp[7], dib_tmp[63:56], dipb_tmp[7], mem[addrb_tmp[14:6]][56 +: 8], memp[addrb_tmp[14:6]][7:7]);
				 if (seq == 2'b00)
				     chk_for_col_msg (wea_tmp[7], web_tmp[7], addra_tmp, addrb_tmp);
			     
		     end // case: 64
		
	    endcase // case(wb_width)

	end
	
    endtask // task_col_wr_ram_b

    
    task task_wr_ram_a;

	input [7:0] wea_tmp;
	input [63:0] dia_tmp;
	input [7:0] dipa_tmp;
	input [15:0] addra_tmp;

	begin
	    
	    case (wa_width)

		1, 2, 4 : begin

		              if (wa_width >= width)
				  task_ram (wea_tmp[0], dia_tmp[wa_width-1:0], 1'b0, mem[addra_tmp[14:addra_lbit_124]], junk1);
			      else
				  task_ram (wea_tmp[0], dia_tmp[wa_width-1:0], 1'b0, mem[addra_tmp[14:addra_bit_124+1]][(addra_tmp[addra_bit_124:addra_lbit_124] * wa_width) +: wa_width], junk1);

		          end
		8 : begin

		        if (wa_width >= width)
			    task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:3]], memp[addra_tmp[14:3]]);
			else
			    task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:addra_bit_8+1]][(addra_tmp[addra_bit_8:3] * 8) +: 8], memp[addra_tmp[14:addra_bit_8+1]][(addra_tmp[addra_bit_8:3] * 1) +: 1]);

		    end
		16 : begin

		         if (wa_width >= width) begin
				 task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:4]][0 +: 8], memp[addra_tmp[14:4]][0:0]);
				 task_ram (wea_tmp[1], dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:4]][8 +: 8], memp[addra_tmp[14:4]][1:1]);
			 end 
			 else begin
				 task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:addra_bit_16+1]][(addra_tmp[addra_bit_16:4] * 16) +: 8], memp[addra_tmp[14:addra_bit_16+1]][(addra_tmp[addra_bit_16:4] * 2) +: 1]);
				 task_ram (wea_tmp[1], dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:addra_bit_16+1]][((addra_tmp[addra_bit_16:4] * 16) + 8) +: 8], memp[addra_tmp[14:addra_bit_16+1]][((addra_tmp[addra_bit_16:4] * 2) + 1) +: 1]);
			 end // else: !if(wa_width >= wb_width)

		    end // case: 16
		32 : begin

		         task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:5]][0 +: 8], memp[addra_tmp[14:5]][0:0]);
		         task_ram (wea_tmp[1], dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:5]][8 +: 8], memp[addra_tmp[14:5]][1:1]);
		         task_ram (wea_tmp[2], dia_tmp[23:16], dipa_tmp[2], mem[addra_tmp[14:5]][16 +: 8], memp[addra_tmp[14:5]][2:2]);
		         task_ram (wea_tmp[3], dia_tmp[31:24], dipa_tmp[3], mem[addra_tmp[14:5]][24 +: 8], memp[addra_tmp[14:5]][3:3]);
		    
		     end // case: 32
		64 : begin  // only valid with ECC single bit correction for 64 bits

		         if (syndrome !== 0 && syndrome[7] === 1 && EN_ECC_SCRUB == "TRUE") begin // if ecc corrected
			     task_ram (1'b1, dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:6]][0 +: 8], memp[addra_tmp[14:6]][0:0]);
			     task_ram (1'b1, dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:6]][8 +: 8], memp[addra_tmp[14:6]][1:1]);
			     task_ram (1'b1, dia_tmp[23:16], dipa_tmp[2], mem[addra_tmp[14:6]][16 +: 8], memp[addra_tmp[14:6]][2:2]);
			     task_ram (1'b1, dia_tmp[31:24], dipa_tmp[3], mem[addra_tmp[14:6]][24 +: 8], memp[addra_tmp[14:6]][3:3]);
			     task_ram (1'b1, dia_tmp[39:32], dipa_tmp[4], mem[addra_tmp[14:6]][32 +: 8], memp[addra_tmp[14:6]][4:4]);
			     task_ram (1'b1, dia_tmp[47:40], dipa_tmp[5], mem[addra_tmp[14:6]][40 +: 8], memp[addra_tmp[14:6]][5:5]);
			     task_ram (1'b1, dia_tmp[55:48], dipa_tmp[6], mem[addra_tmp[14:6]][48 +: 8], memp[addra_tmp[14:6]][6:6]);
			     task_ram (1'b1, dia_tmp[63:56], dipa_tmp[7], mem[addra_tmp[14:6]][56 +: 8], memp[addra_tmp[14:6]][7:7]);
			 end
		    
		     end // case: 64
	    endcase // case(wa_width)
	end
	
    endtask // task_wr_ram_a
    
    
    task task_wr_ram_b;

	input [7:0] web_tmp;
	input [63:0] dib_tmp;
	input [7:0] dipb_tmp;
	input [15:0] addrb_tmp;

	begin
	    
	    case (wb_width)

		1, 2, 4 : begin

		              if (wb_width >= width)
				  task_ram (web_tmp[0], dib_tmp[wb_width-1:0], 1'b0, mem[addrb_tmp[14:addrb_lbit_124]], junk1);
			      else
				  task_ram (web_tmp[0], dib_tmp[wb_width-1:0], 1'b0, mem[addrb_tmp[14:addrb_bit_124+1]][(addrb_tmp[addrb_bit_124:addrb_lbit_124] * wb_width) +: wb_width], junk1);
		          end
		8 : begin

		        if (wb_width >= width)
			    task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:3]], memp[addrb_tmp[14:3]]);
			else
			    task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:addrb_bit_8+1]][(addrb_tmp[addrb_bit_8:3] * 8) +: 8], memp[addrb_tmp[14:addrb_bit_8+1]][(addrb_tmp[addrb_bit_8:3] * 1) +: 1]);

		    end
		16 : begin

		         if (wb_width >= width) begin
			     task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:4]][0 +: 8], memp[addrb_tmp[14:4]][0:0]);
			     task_ram (web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:4]][8 +: 8], memp[addrb_tmp[14:4]][1:1]);
			 end 
			 else begin
			     task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:addrb_bit_16+1]][(addrb_tmp[addrb_bit_16:4] * 16) +: 8], memp[addrb_tmp[14:addrb_bit_16+1]][(addrb_tmp[addrb_bit_16:4] * 2) +: 1]);
			     task_ram (web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:addrb_bit_16+1]][((addrb_tmp[addrb_bit_16:4] * 16) + 8) +: 8], memp[addrb_tmp[14:addrb_bit_16+1]][((addrb_tmp[addrb_bit_16:4] * 2) + 1) +: 1]);
			 end

 		     end // case: 16
		32 : begin

		         task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:5]][0 +: 8], memp[addrb_tmp[14:5]][0:0]);
		         task_ram (web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:5]][8 +: 8], memp[addrb_tmp[14:5]][1:1]);
		         task_ram (web_tmp[2], dib_tmp[23:16], dipb_tmp[2], mem[addrb_tmp[14:5]][16 +: 8], memp[addrb_tmp[14:5]][2:2]);
		         task_ram (web_tmp[3], dib_tmp[31:24], dipb_tmp[3], mem[addrb_tmp[14:5]][24 +: 8], memp[addrb_tmp[14:5]][3:3]);
		    
		     end // case: 32
		64 : begin  // only valid with ECC single bit correction for 64 bits

			     task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:6]][0 +: 8], memp[addrb_tmp[14:6]][0:0]);
			     task_ram (web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:6]][8 +: 8], memp[addrb_tmp[14:6]][1:1]);
			     task_ram (web_tmp[2], dib_tmp[23:16], dipb_tmp[2], mem[addrb_tmp[14:6]][16 +: 8], memp[addrb_tmp[14:6]][2:2]);
			     task_ram (web_tmp[3], dib_tmp[31:24], dipb_tmp[3], mem[addrb_tmp[14:6]][24 +: 8], memp[addrb_tmp[14:6]][3:3]);
			     task_ram (web_tmp[4], dib_tmp[39:32], dipb_tmp[4], mem[addrb_tmp[14:6]][32 +: 8], memp[addrb_tmp[14:6]][4:4]);
			     task_ram (web_tmp[5], dib_tmp[47:40], dipb_tmp[5], mem[addrb_tmp[14:6]][40 +: 8], memp[addrb_tmp[14:6]][5:5]);
			     task_ram (web_tmp[6], dib_tmp[55:48], dipb_tmp[6], mem[addrb_tmp[14:6]][48 +: 8], memp[addrb_tmp[14:6]][6:6]);
			     task_ram (web_tmp[7], dib_tmp[63:56], dipb_tmp[7], mem[addrb_tmp[14:6]][56 +: 8], memp[addrb_tmp[14:6]][7:7]);
			     
		     end // case: 64
	    endcase // case(wb_width)
	end
	
    endtask // task_wr_ram_b

    
    task task_col_rd_ram_a;

	input [1:0] seq;   // 1 is bypass
	input [7:0] web_tmp;
	input [7:0] wea_tmp;
	input [15:0] addra_tmp;
	inout [63:0] doa_tmp;
	inout [7:0] dopa_tmp;
	reg [63:0] doa_ltmp;
	reg [7:0] dopa_ltmp;
	
	begin

	    doa_ltmp= 64'b0;
	    dopa_ltmp= 8'b0;
	    
	    case (ra_width)
		1, 2, 4 : begin

		              if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[0] !== 1'b1)) begin
				  if (ra_width >= width)
				      doa_ltmp = mem[addra_tmp[14:r_addra_lbit_124]];
				  else
				      doa_ltmp = mem[addra_tmp[14:r_addra_bit_124+1]][(addra_tmp[r_addra_bit_124:r_addra_lbit_124] * ra_width) +: ra_width];
				  task_x_buf (wr_mode_a, 3, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);			  
			      end
 		          end // case: 1, 2, 4
		8 : begin

		        if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[0] !== 1'b1)) begin
		            if (ra_width >= width) begin
				doa_ltmp = mem[addra_tmp[14:3]];
				dopa_ltmp =  memp[addra_tmp[14:3]];
			    end
			    else begin
				doa_ltmp = mem[addra_tmp[14:r_addra_bit_8+1]][(addra_tmp[r_addra_bit_8:3] * 8) +: 8];
				dopa_ltmp = memp[addra_tmp[14:r_addra_bit_8+1]][(addra_tmp[r_addra_bit_8:3] * 1) +: 1];
			    end
			    
			    task_x_buf (wr_mode_a, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);			  

			end
		     end // case: 8
		16 : begin

		         if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[0] !== 1'b1)) begin
		             if (ra_width >= width) begin
				 doa_ltmp[7:0] = mem[addra_tmp[14:4]][7:0];
				 dopa_ltmp[0:0] = memp[addra_tmp[14:4]][0:0];
			     end
			     else begin
				 doa_ltmp[7:0] = mem[addra_tmp[14:r_addra_bit_16+1]][(addra_tmp[r_addra_bit_16:4] * 16) +: 8];
				 dopa_ltmp[0:0] = memp[addra_tmp[14:r_addra_bit_16+1]][(addra_tmp[r_addra_bit_16:4] * 2) +: 1];
			     end
			     task_x_buf (wr_mode_a, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end

		         if ((web_tmp[1] === 1'b1 && wea_tmp[1] === 1'b1) || (seq == 2'b01 && web_tmp[1] === 1'b1 && wea_tmp[1] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[1] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[1] !== 1'b1)) begin
			     if (ra_width >= width) begin
				 doa_ltmp[15:8] = mem[addra_tmp[14:4]][15:8];
				 dopa_ltmp[1:1] = memp[addra_tmp[14:4]][1:1];
			     end 
			     else begin
				 doa_ltmp[15:8] = mem[addra_tmp[14:r_addra_bit_16+1]][((addra_tmp[r_addra_bit_16:4] * 16) + 8) +: 8];
				 dopa_ltmp[1:1] = memp[addra_tmp[14:r_addra_bit_16+1]][((addra_tmp[r_addra_bit_16:4] * 2) + 1) +: 1];
			     end
			     task_x_buf (wr_mode_a, 15, 8, 1, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end
		    
		     end
		32 : begin
		         if (ra_width >= width) begin

			     if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[0] !== 1'b1)) begin
				 doa_ltmp[7:0] = mem[addra_tmp[14:5]][7:0];
				 dopa_ltmp[0:0] = memp[addra_tmp[14:5]][0:0];
				 task_x_buf (wr_mode_a, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			     end

			     if ((web_tmp[1] === 1'b1 && wea_tmp[1] === 1'b1) || (seq == 2'b01 && web_tmp[1] === 1'b1 && wea_tmp[1] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[1] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[1] !== 1'b1)) begin
				 doa_ltmp[15:8] = mem[addra_tmp[14:5]][15:8];
				 dopa_ltmp[1:1] = memp[addra_tmp[14:5]][1:1];
				 task_x_buf (wr_mode_a, 15, 8, 1, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			     end

			     if ((web_tmp[2] === 1'b1 && wea_tmp[2] === 1'b1) || (seq == 2'b01 && web_tmp[2] === 1'b1 && wea_tmp[2] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[2] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[2] !== 1'b1)) begin
				 doa_ltmp[23:16] = mem[addra_tmp[14:5]][23:16];
				 dopa_ltmp[2:2] = memp[addra_tmp[14:5]][2:2];
				 task_x_buf (wr_mode_a, 23, 16, 2, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			     end

			     if ((web_tmp[3] === 1'b1 && wea_tmp[3] === 1'b1) || (seq == 2'b01 && web_tmp[3] === 1'b1 && wea_tmp[3] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[3] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[3] !== 1'b1)) begin
				 doa_ltmp[31:24] = mem[addra_tmp[14:5]][31:24];
				 dopa_ltmp[3:3] = memp[addra_tmp[14:5]][3:3];
				 task_x_buf (wr_mode_a, 31, 24, 3, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			     end

			 end // if (ra_width >= width)
		     end
		64 : begin

		         if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[0] !== 1'b1)) begin
			     doa_ltmp[7:0] = mem[addra_tmp[14:6]][7:0];
			     dopa_ltmp[0:0] = memp[addra_tmp[14:6]][0:0];
			     task_x_buf (wr_mode_a, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end
			     
		         if ((web_tmp[1] === 1'b1 && wea_tmp[1] === 1'b1) || (seq == 2'b01 && web_tmp[1] === 1'b1 && wea_tmp[1] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[1] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[1] !== 1'b1)) begin
			     doa_ltmp[15:8] = mem[addra_tmp[14:6]][15:8];
			     dopa_ltmp[1:1] = memp[addra_tmp[14:6]][1:1];
			     task_x_buf (wr_mode_a, 15, 8, 1, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end
		    
		         if ((web_tmp[2] === 1'b1 && wea_tmp[2] === 1'b1) || (seq == 2'b01 && web_tmp[2] === 1'b1 && wea_tmp[2] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[2] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[2] !== 1'b1)) begin
			     doa_ltmp[23:16] = mem[addra_tmp[14:6]][23:16];
			     dopa_ltmp[2:2] = memp[addra_tmp[14:6]][2:2];
			     task_x_buf (wr_mode_a, 23, 16, 2, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end
		    
		         if ((web_tmp[3] === 1'b1 && wea_tmp[3] === 1'b1) || (seq == 2'b01 && web_tmp[3] === 1'b1 && wea_tmp[3] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[3] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[3] !== 1'b1)) begin
			     doa_ltmp[31:24] = mem[addra_tmp[14:6]][31:24];
			     dopa_ltmp[3:3] = memp[addra_tmp[14:6]][3:3];
			     task_x_buf (wr_mode_a, 31, 24, 3, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end

		         if ((web_tmp[4] === 1'b1 && wea_tmp[4] === 1'b1) || (seq == 2'b01 && web_tmp[4] === 1'b1 && wea_tmp[4] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[4] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[4] !== 1'b1)) begin
			     doa_ltmp[39:32] = mem[addra_tmp[14:6]][39:32];
			     dopa_ltmp[4:4] = memp[addra_tmp[14:6]][4:4];
			     task_x_buf (wr_mode_a, 39, 32, 4, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end
			     
		         if ((web_tmp[5] === 1'b1 && wea_tmp[5] === 1'b1) || (seq == 2'b01 && web_tmp[5] === 1'b1 && wea_tmp[5] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[5] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[5] !== 1'b1)) begin
			     doa_ltmp[47:40] = mem[addra_tmp[14:6]][47:40];
			     dopa_ltmp[5:5] = memp[addra_tmp[14:6]][5:5];
			     task_x_buf (wr_mode_a, 47, 40, 5, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end
		    
		         if ((web_tmp[6] === 1'b1 && wea_tmp[6] === 1'b1) || (seq == 2'b01 && web_tmp[6] === 1'b1 && wea_tmp[6] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[6] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[6] !== 1'b1)) begin
			     doa_ltmp[55:48] = mem[addra_tmp[14:6]][55:48];
			     dopa_ltmp[6:6] = memp[addra_tmp[14:6]][6:6];
			     task_x_buf (wr_mode_a, 55, 48, 6, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end
		    
		         if ((web_tmp[7] === 1'b1 && wea_tmp[7] === 1'b1) || (seq == 2'b01 && web_tmp[7] === 1'b1 && wea_tmp[7] === 1'b0 && viol_type == 2'b10) || (seq == 2'b01 && wr_mode_a != 2'b01 && wr_mode_b != 2'b01) || (seq == 2'b01 && wr_mode_a == 2'b01 && wr_mode_b != 2'b01 && web_tmp[7] === 1'b1) || (seq == 2'b11 && wr_mode_a == 2'b00 && web_tmp[7] !== 1'b1)) begin
			     doa_ltmp[63:56] = mem[addra_tmp[14:6]][63:56];
			     dopa_ltmp[7:7] = memp[addra_tmp[14:6]][7:7];
			     task_x_buf (wr_mode_a, 63, 56, 7, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
			 end

		     end
	    endcase // case(ra_width)
	end
    endtask // task_col_rd_ram_a


    task task_col_rd_ram_b;

	input [1:0] seq;   // 1 is bypass
	input [7:0] wea_tmp;
	input [7:0] web_tmp;
	input [15:0] addrb_tmp;
	inout [63:0] dob_tmp;
	inout [7:0] dopb_tmp;
	reg [63:0] dob_ltmp;
	reg [7:0] dopb_ltmp;
	
	begin

	    dob_ltmp= 64'b0;
	    dopb_ltmp= 8'b0;
	    
	    case (rb_width)
		1, 2, 4 : begin

		              if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[0] !== 1'b1)) begin
				  if (rb_width >= width)
				      dob_ltmp = mem[addrb_tmp[14:r_addrb_lbit_124]];
				  else
				      dob_ltmp = mem[addrb_tmp[14:r_addrb_bit_124+1]][(addrb_tmp[r_addrb_bit_124:r_addrb_lbit_124] * rb_width) +: rb_width];

				  task_x_buf (wr_mode_b, 3, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

			      end
		          end // case: 1, 2, 4
		8 : begin

		        if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[0] !== 1'b1)) begin
		    
		            if (rb_width >= width) begin
				dob_ltmp = mem[addrb_tmp[14:3]];
				dopb_ltmp =  memp[addrb_tmp[14:3]];
			    end
			    else begin
				dob_ltmp = mem[addrb_tmp[14:r_addrb_bit_8+1]][(addrb_tmp[r_addrb_bit_8:3] * 8) +: 8];
				dopb_ltmp = memp[addrb_tmp[14:r_addrb_bit_8+1]][(addrb_tmp[r_addrb_bit_8:3] * 1) +: 1];
			    end
			    
			    task_x_buf (wr_mode_b, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

			end
		     end // case: 8
		16 : begin
		    
		         if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[0] !== 1'b1)) begin
		             if (rb_width >= width) begin
				 dob_ltmp[7:0] = mem[addrb_tmp[14:4]][7:0];
				 dopb_ltmp[0:0] = memp[addrb_tmp[14:4]][0:0];
			     end
			     else begin
				 dob_ltmp[7:0] = mem[addrb_tmp[14:r_addrb_bit_16+1]][(addrb_tmp[r_addrb_bit_16:4] * 16) +: 8];
				 dopb_ltmp[0:0] = memp[addrb_tmp[14:r_addrb_bit_16+1]][(addrb_tmp[r_addrb_bit_16:4] * 2) +: 1];
			     end
			     task_x_buf (wr_mode_b, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end
		    

		         if ((web_tmp[1] === 1'b1 && wea_tmp[1] === 1'b1) || (seq == 2'b01 && wea_tmp[1] === 1'b1 && web_tmp[1] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[1] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[1] !== 1'b1)) begin	    

		             if (rb_width >= width) begin
				 dob_ltmp[15:8] = mem[addrb_tmp[14:4]][15:8];
				 dopb_ltmp[1:1] = memp[addrb_tmp[14:4]][1:1];
			     end 
			     else begin
				 dob_ltmp[15:8] = mem[addrb_tmp[14:r_addrb_bit_16+1]][((addrb_tmp[r_addrb_bit_16:4] * 16) + 8) +: 8];
				 dopb_ltmp[1:1] = memp[addrb_tmp[14:r_addrb_bit_16+1]][((addrb_tmp[r_addrb_bit_16:4] * 2) + 1) +: 1];
			     end
			     task_x_buf (wr_mode_b, 15, 8, 1, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end

		     end
		32 : begin
		         if (rb_width >= width) begin
			     
		             if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[0] !== 1'b1)) begin
				 dob_ltmp[7:0] = mem[addrb_tmp[14:5]][7:0];
				 dopb_ltmp[0:0] = memp[addrb_tmp[14:5]][0:0];
				 task_x_buf (wr_mode_b, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			     end
			     
			     if ((web_tmp[1] === 1'b1 && wea_tmp[1] === 1'b1) || (seq == 2'b01 && wea_tmp[1] === 1'b1 && web_tmp[1] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[1] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[1] !== 1'b1)) begin		    
				 dob_ltmp[15:8] = mem[addrb_tmp[14:5]][15:8];
				 dopb_ltmp[1:1] = memp[addrb_tmp[14:5]][1:1];
				 task_x_buf (wr_mode_b, 15, 8, 1, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			     end

			     if ((web_tmp[2] === 1'b1 && wea_tmp[2] === 1'b1) || (seq == 2'b01 && wea_tmp[2] === 1'b1 && web_tmp[2] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[2] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[2] !== 1'b1)) begin		    
				 dob_ltmp[23:16] = mem[addrb_tmp[14:5]][23:16];
				 dopb_ltmp[2:2] = memp[addrb_tmp[14:5]][2:2];
				 task_x_buf (wr_mode_b, 23, 16, 2, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			     end

			     if ((web_tmp[3] === 1'b1 && wea_tmp[3] === 1'b1) || (seq == 2'b01 && wea_tmp[3] === 1'b1 && web_tmp[3] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[3] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[3] !== 1'b1)) begin		    
				 dob_ltmp[31:24] = mem[addrb_tmp[14:5]][31:24];
				 dopb_ltmp[3:3] = memp[addrb_tmp[14:5]][3:3];
				 task_x_buf (wr_mode_b, 31, 24, 3, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			     end

			 end // if (rb_width >= width)
		     end
		64 : begin

		         if ((web_tmp[0] === 1'b1 && wea_tmp[0] === 1'b1) || (seq == 2'b01 && wea_tmp[0] === 1'b1 && web_tmp[0] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[0] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[0] !== 1'b1)) begin
			     dob_ltmp[7:0] = mem[addrb_tmp[14:6]][7:0];
			     dopb_ltmp[0:0] = memp[addrb_tmp[14:6]][0:0];
			     task_x_buf (wr_mode_b, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end
			     
			 if ((web_tmp[1] === 1'b1 && wea_tmp[1] === 1'b1) || (seq == 2'b01 && wea_tmp[1] === 1'b1 && web_tmp[1] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[1] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[1] !== 1'b1)) begin		    
			     dob_ltmp[15:8] = mem[addrb_tmp[14:6]][15:8];
			     dopb_ltmp[1:1] = memp[addrb_tmp[14:6]][1:1];
			     task_x_buf (wr_mode_b, 15, 8, 1, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end
		    
			 if ((web_tmp[2] === 1'b1 && wea_tmp[2] === 1'b1) || (seq == 2'b01 && wea_tmp[2] === 1'b1 && web_tmp[2] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[2] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[2] !== 1'b1)) begin		    
			     dob_ltmp[23:16] = mem[addrb_tmp[14:6]][23:16];
			     dopb_ltmp[2:2] = memp[addrb_tmp[14:6]][2:2];
			     task_x_buf (wr_mode_b, 23, 16, 2, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end
		    
			 if ((web_tmp[3] === 1'b1 && wea_tmp[3] === 1'b1) || (seq == 2'b01 && wea_tmp[3] === 1'b1 && web_tmp[3] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[3] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[3] !== 1'b1)) begin		    
			     dob_ltmp[31:24] = mem[addrb_tmp[14:6]][31:24];
			     dopb_ltmp[3:3] = memp[addrb_tmp[14:6]][3:3];
			     task_x_buf (wr_mode_b, 31, 24, 3, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end

			 if ((web_tmp[4] === 1'b1 && wea_tmp[4] === 1'b1) || (seq == 2'b01 && wea_tmp[4] === 1'b1 && web_tmp[4] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[4] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[4] !== 1'b1)) begin		    
			     dob_ltmp[39:32] = mem[addrb_tmp[14:6]][39:32];
			     dopb_ltmp[4:4] = memp[addrb_tmp[14:6]][4:4];
			     task_x_buf (wr_mode_b, 39, 32, 4, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end
			     
			 if ((web_tmp[5] === 1'b1 && wea_tmp[5] === 1'b1) || (seq == 2'b01 && wea_tmp[5] === 1'b1 && web_tmp[5] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[5] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[5] !== 1'b1)) begin		    
			     dob_ltmp[47:40] = mem[addrb_tmp[14:6]][47:40];
			     dopb_ltmp[5:5] = memp[addrb_tmp[14:6]][5:5];
			     task_x_buf (wr_mode_b, 47, 40, 5, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end
		    
			 if ((web_tmp[6] === 1'b1 && wea_tmp[6] === 1'b1) || (seq == 2'b01 && wea_tmp[6] === 1'b1 && web_tmp[6] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[6] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[6] !== 1'b1)) begin		    
			     dob_ltmp[55:48] = mem[addrb_tmp[14:6]][55:48];
			     dopb_ltmp[6:6] = memp[addrb_tmp[14:6]][6:6];
			     task_x_buf (wr_mode_b, 55, 48, 6, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end
		    
			 if ((web_tmp[7] === 1'b1 && wea_tmp[7] === 1'b1) || (seq == 2'b01 && wea_tmp[7] === 1'b1 && web_tmp[7] === 1'b0 && viol_type == 2'b11) || (seq == 2'b01 && wr_mode_b != 2'b01 && wr_mode_a != 2'b01) || (seq == 2'b01 && wr_mode_b == 2'b01 && wr_mode_a != 2'b01 && wea_tmp[7] === 1'b1) || (seq == 2'b11 && wr_mode_b == 2'b00 && wea_tmp[7] !== 1'b1)) begin		    
			     dob_ltmp[63:56] = mem[addrb_tmp[14:6]][63:56];
			     dopb_ltmp[7:7] = memp[addrb_tmp[14:6]][7:7];
			     task_x_buf (wr_mode_b, 63, 56, 7, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);
			 end

		     end
	    endcase // case(rb_width)
	end
    endtask // task_col_rd_ram_b

    
    task task_rd_ram_a;

	input [15:0] addra_tmp;
	inout [63:0] doa_tmp;
	inout [7:0] dopa_tmp;

	begin

	    case (ra_width)
		1, 2, 4 : begin
		              if (ra_width >= width)
				  doa_tmp = mem[addra_tmp[14:r_addra_lbit_124]];

			      else
				  doa_tmp = mem[addra_tmp[14:r_addra_bit_124+1]][(addra_tmp[r_addra_bit_124:r_addra_lbit_124] * ra_width) +: ra_width];
		          end
		8 : begin
		        if (ra_width >= width) begin
			    doa_tmp = mem[addra_tmp[14:3]];
			    dopa_tmp =  memp[addra_tmp[14:3]];
			end
			else begin
			    doa_tmp = mem[addra_tmp[14:r_addra_bit_8+1]][(addra_tmp[r_addra_bit_8:3] * 8) +: 8];
			    dopa_tmp = memp[addra_tmp[14:r_addra_bit_8+1]][(addra_tmp[r_addra_bit_8:3] * 1) +: 1];
			end
		    end
		16 : begin
		         if (ra_width >= width) begin
			     doa_tmp = mem[addra_tmp[14:4]];
			     dopa_tmp = memp[addra_tmp[14:4]];
			 end 
			 else begin
			     doa_tmp = mem[addra_tmp[14:r_addra_bit_16+1]][(addra_tmp[r_addra_bit_16:4] * 16) +: 16];
			     dopa_tmp = memp[addra_tmp[14:r_addra_bit_16+1]][(addra_tmp[r_addra_bit_16:4] * 2) +: 2];
			 end
		     end
		32 : begin
		         if (ra_width >= width) begin
			     doa_tmp = mem[addra_tmp[14:5]];
			     dopa_tmp = memp[addra_tmp[14:5]];
			 end 
		     end
		64 : begin
		         if (ra_width >= width) begin
			     doa_tmp = mem[addra_tmp[14:6]];
			     dopa_tmp = memp[addra_tmp[14:6]];
			 end 
		     end				 
	    endcase // case(ra_width)

	end
    endtask // task_rd_ram_a
    

    task task_rd_ram_b;

	input [15:0] addrb_tmp;
	inout [31:0] dob_tmp;
	inout [3:0] dopb_tmp;

	begin
	    
	    case (rb_width)
		1, 2, 4 : begin
		              if (rb_width >= width)
				  dob_tmp = mem[addrb_tmp[14:r_addrb_lbit_124]];
			      else
				  dob_tmp = mem[addrb_tmp[14:r_addrb_bit_124+1]][(addrb_tmp[r_addrb_bit_124:r_addrb_lbit_124] * rb_width) +: rb_width];
               	          end
		8 : begin
		        if (rb_width >= width) begin
			    dob_tmp = mem[addrb_tmp[14:3]];
			    dopb_tmp =  memp[addrb_tmp[14:3]];
			end
			else begin
			    dob_tmp = mem[addrb_tmp[14:r_addrb_bit_8+1]][(addrb_tmp[r_addrb_bit_8:3] * 8) +: 8];
			    dopb_tmp = memp[addrb_tmp[14:r_addrb_bit_8+1]][(addrb_tmp[r_addrb_bit_8:3] * 1) +: 1];
			end
		    end
		16 : begin
		         if (rb_width >= width) begin
			     dob_tmp = mem[addrb_tmp[14:4]];
			     dopb_tmp = memp[addrb_tmp[14:4]];
			 end 
			 else begin
			     dob_tmp = mem[addrb_tmp[14:r_addrb_bit_16+1]][(addrb_tmp[r_addrb_bit_16:4] * 16) +: 16];
			     dopb_tmp = memp[addrb_tmp[14:r_addrb_bit_16+1]][(addrb_tmp[r_addrb_bit_16:4] * 2) +: 2];
			 end
		      end
		32 : begin
		         dob_tmp = mem[addrb_tmp[14:5]];
		         dopb_tmp = memp[addrb_tmp[14:5]];
		     end
		
	    endcase
	end
    endtask // task_rd_ram_b    


    task chk_for_col_msg;

	input wea_tmp;
	input web_tmp;
	input [15:0] addra_tmp;
	input [15:0] addrb_tmp;
	
	begin

	    if ((SIM_COLLISION_CHECK == "ALL" || SIM_COLLISION_CHECK == "WARNING_ONLY") && !(((wr_mode_b == 2'b01 && web_tmp === 1'b1 && wea_tmp === 1'b0) && !(rising_clka && !rising_clkb)) || ((wr_mode_a == 2'b01 && wea_tmp === 1'b1 && web_tmp === 1'b0) && !(rising_clkb && !rising_clka))))
		
		if (wea_tmp === 1'b1 && web_tmp === 1'b1 && col_wr_wr_msg == 1) begin
		    $display("Memory Collision Error on ARAMB36_INTERNAL : %m at simulation time %.3f ns.\nA write was requested to the same address simultaneously at both port A and port B of the RAM. The contents written to the RAM at address location %h (hex) of port A and address location %h (hex) of port B are unknown.", $time/1000.0, addra_tmp, addrb_tmp);
		    col_wr_wr_msg = 0;
		end
	    
		else if (wea_tmp === 1'b1 && web_tmp === 1'b0 && col_wra_rdb_msg == 1) begin
		    $display("Memory Collision Error on ARAMB36_INTERNAL : %m at simulation time %.3f ns.\nA read was performed on address %h (hex) of port B while a write was requested to the same address on port A. The write will be successful however the read value on port B is unknown until the next CLKB cycle.", $time/1000.0, addrb_tmp);
		    col_wra_rdb_msg = 0;
		end
	    
		else if (wea_tmp === 1'b0 && web_tmp === 1'b1 && col_wrb_rda_msg == 1) begin
		    $display("Memory Collision Error on ARAMB36_INTERNAL : %m at simulation time %.3f ns.\nA read was performed on address %h (hex) of port A while a write was requested to the same address on port B. The write will be successful however the read value on port A is unknown until the next CLKA cycle.", $time/1000.0, addra_tmp);
		    col_wrb_rda_msg = 0;
		end
	    
	end

    endtask // chk_for_col_msg


    task task_col_ecc_read;

    inout [63:0] do_tmp;
    inout [7:0] dop_tmp;
    input [15:0] addr_tmp;
	
    reg [71:0] task_ecc_bit_position;
    reg [7:0] task_dopr_ecc, task_syndrome;
    reg [63:0] task_di_in_ecc_corrected;
    reg [7:0] task_dip_in_ecc_corrected;
    
    begin

	if (|do_tmp === 1'bx) begin // if there is collision
	    dbiterr_out <= 1'bx;
	    sbiterr_out <= 1'bx;
	end
	else begin

	    task_dopr_ecc = fn_dip_ecc(1'b0, do_tmp, dop_tmp);
	
	    task_syndrome = task_dopr_ecc ^ dop_tmp;
	    
	    if (task_syndrome !== 0) begin
		
		if (task_syndrome[7]) begin  // dectect single bit error
		
		    task_ecc_bit_position = {do_tmp[63:57], dop_tmp[6], do_tmp[56:26], dop_tmp[5], do_tmp[25:11], dop_tmp[4], do_tmp[10:4], dop_tmp[3], do_tmp[3:1], dop_tmp[2], do_tmp[0], dop_tmp[1:0], dop_tmp[7]};
		    
		    if (task_syndrome[6:0] > 71) begin
			$display ("DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code.");
			$finish;
		    end
		    
		    task_ecc_bit_position[task_syndrome[6:0]] = ~task_ecc_bit_position[task_syndrome[6:0]]; // correct single bit error in the output 
		    
		    task_di_in_ecc_corrected = {task_ecc_bit_position[71:65], task_ecc_bit_position[63:33], task_ecc_bit_position[31:17], task_ecc_bit_position[15:9], task_ecc_bit_position[7:5], task_ecc_bit_position[3]}; // correct single bit error in the memory
		    
		    do_tmp = task_di_in_ecc_corrected;
		    
		    task_dip_in_ecc_corrected = {task_ecc_bit_position[0], task_ecc_bit_position[64], task_ecc_bit_position[32], task_ecc_bit_position[16], task_ecc_bit_position[8], task_ecc_bit_position[4], task_ecc_bit_position[2:1]}; // correct single bit error in the parity memory
		    
		    dop_tmp = task_dip_in_ecc_corrected;
		    
		    dbiterr_out <= 0;
		    sbiterr_out <= 1;
		    
		end
		else if (!task_syndrome[7]) begin  // double bit error
		    sbiterr_out <= 0;
		    dbiterr_out <= 1;
		    
		end
	    end // if (task_syndrome !== 0)
	    else begin
		dbiterr_out <= 0;
		sbiterr_out <= 0;
		
	    end // else: !if(task_syndrome !== 0)
	    
	    if (ssra_in == 1'b1) begin
		dbiterr_out <= 0;
		sbiterr_out <= 0;
	    end
	    
	    if (task_syndrome !== 0 && task_syndrome[7] === 1 && EN_ECC_SCRUB == "TRUE")
		task_wr_ram_a (8'hff, task_di_in_ecc_corrected, task_dip_in_ecc_corrected, addr_tmp);

	end // else: !if(|do_tmp === 1'bx)
    end
	
    endtask // task_col_ecc_read
    
    
    function [7:0] fn_dip_ecc;

	input encode;
	input [63:0] di_in;
	input [7:0] dip_in;

	begin

	    fn_dip_ecc[0] = di_in[0]^di_in[1]^di_in[3]^di_in[4]^di_in[6]^di_in[8]
		     ^di_in[10]^di_in[11]^di_in[13]^di_in[15]^di_in[17]^di_in[19]
		     ^di_in[21]^di_in[23]^di_in[25]^di_in[26]^di_in[28]
            	     ^di_in[30]^di_in[32]^di_in[34]^di_in[36]^di_in[38]
		     ^di_in[40]^di_in[42]^di_in[44]^di_in[46]^di_in[48]
		     ^di_in[50]^di_in[52]^di_in[54]^di_in[56]^di_in[57]^di_in[59]
		     ^di_in[61]^di_in[63];

	    fn_dip_ecc[1] = di_in[0]^di_in[2]^di_in[3]^di_in[5]^di_in[6]^di_in[9]
                     ^di_in[10]^di_in[12]^di_in[13]^di_in[16]^di_in[17]
                     ^di_in[20]^di_in[21]^di_in[24]^di_in[25]^di_in[27]^di_in[28]
                     ^di_in[31]^di_in[32]^di_in[35]^di_in[36]^di_in[39]
                     ^di_in[40]^di_in[43]^di_in[44]^di_in[47]^di_in[48]
                     ^di_in[51]^di_in[52]^di_in[55]^di_in[56]^di_in[58]^di_in[59]
                     ^di_in[62]^di_in[63];

	    fn_dip_ecc[2] = di_in[1]^di_in[2]^di_in[3]^di_in[7]^di_in[8]^di_in[9]
                     ^di_in[10]^di_in[14]^di_in[15]^di_in[16]^di_in[17]
                     ^di_in[22]^di_in[23]^di_in[24]^di_in[25]^di_in[29]
                     ^di_in[30]^di_in[31]^di_in[32]^di_in[37]^di_in[38]^di_in[39]
                     ^di_in[40]^di_in[45]^di_in[46]^di_in[47]^di_in[48]
                     ^di_in[53]^di_in[54]^di_in[55]^di_in[56]
                     ^di_in[60]^di_in[61]^di_in[62]^di_in[63];
	
	    fn_dip_ecc[3] = di_in[4]^di_in[5]^di_in[6]^di_in[7]^di_in[8]^di_in[9]
		     ^di_in[10]^di_in[18]^di_in[19]
                     ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]
                     ^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                     ^di_in[40]^di_in[49]
                     ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56];

	    fn_dip_ecc[4] = di_in[11]^di_in[12]^di_in[13]^di_in[14]^di_in[15]^di_in[16]^di_in[17]^di_in[18]^di_in[19]
                     ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]
                     ^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                     ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56];


	    fn_dip_ecc[5] = di_in[26]^di_in[27]^di_in[28]^di_in[29]
                     ^di_in[30]^di_in[31]^di_in[32]^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                     ^di_in[40]^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                     ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56];

	    fn_dip_ecc[6] = di_in[57]^di_in[58]^di_in[59]
                     ^di_in[60]^di_in[61]^di_in[62]^di_in[63];

	    if (encode == 1'b1)
		
		fn_dip_ecc[7] = fn_dip_ecc[0]^fn_dip_ecc[1]^fn_dip_ecc[2]^fn_dip_ecc[3]^fn_dip_ecc[4]^fn_dip_ecc[5]^fn_dip_ecc[6]
                     ^di_in[0]^di_in[1]^di_in[2]^di_in[3]^di_in[4]^di_in[5]^di_in[6]^di_in[7]^di_in[8]^di_in[9]
                     ^di_in[10]^di_in[11]^di_in[12]^di_in[13]^di_in[14]^di_in[15]^di_in[16]^di_in[17]^di_in[18]^di_in[19]
                     ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]^di_in[26]^di_in[27]^di_in[28]^di_in[29]
                     ^di_in[30]^di_in[31]^di_in[32]^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                     ^di_in[40]^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                     ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56]^di_in[57]^di_in[58]^di_in[59]
                     ^di_in[60]^di_in[61]^di_in[62]^di_in[63];
	    else
		fn_dip_ecc[7] = dip_in[0]^dip_in[1]^dip_in[2]^dip_in[3]^dip_in[4]^dip_in[5]^dip_in[6]
                     ^di_in[0]^di_in[1]^di_in[2]^di_in[3]^di_in[4]^di_in[5]^di_in[6]^di_in[7]^di_in[8]^di_in[9]
                     ^di_in[10]^di_in[11]^di_in[12]^di_in[13]^di_in[14]^di_in[15]^di_in[16]^di_in[17]^di_in[18]^di_in[19]
                     ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]^di_in[26]^di_in[27]^di_in[28]^di_in[29]
                     ^di_in[30]^di_in[31]^di_in[32]^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                     ^di_in[40]^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                     ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56]^di_in[57]^di_in[58]^di_in[59]
                     ^di_in[60]^di_in[61]^di_in[62]^di_in[63];
	    
	end
	
    endfunction // fn_dip_ecc

/******************************************** END task and function **************************************/
	  
    buf b_addra[15:0] (addra_in, ADDRA);
    buf b_addrb[15:0] (addrb_in, ADDRB);
    buf b_clka (clka_in, CLKA);
    buf b_clkb (clkb_in, CLKB);
    buf b_regclka (regclka_in, REGCLKA);
    buf b_regclkb (regclkb_in, REGCLKB);
    
    buf b_dia[63:0] (dia_in, DIA);
    buf b_dib[63:0] (dib_in, DIB);
    buf b_dipa[3:0] (dipa_in, DIPA);
    buf b_dipb[7:0] (dipb_in, DIPB);
    buf b_doa[63:0] (DOA, doa_out_out);
    buf b_dopa[7:0] (DOPA, dopa_out_out);
    buf b_dob[31:0] (DOB, dob_out_out);
    buf b_dopb[3:0] (DOPB, dopb_out_out);

    buf b_ena (ena_in, ENA);
    buf b_enb (enb_in, ENB);
    buf b_gsr (gsr_in, GSR);
    buf b_regcea (regcea_in, REGCEA);
    buf b_regceb (regceb_in, REGCEB);
    buf b_ssra (ssra_in, SSRA);
    buf b_ssrb (ssrb_in, SSRB);
    buf b_wea[7:0] (wea_in, WEA);
    buf b_web[7:0] (web_in, WEB);
    buf b_cascadeinlata (cascadeinlata_in, CASCADEINLATA);
    buf b_cascadeinlatb (cascadeinlatb_in, CASCADEINLATB);
    buf b_cascadeoutlata (CASCADEOUTLATA, doa_out[0]);
    buf b_cascadeoutlatb (CASCADEOUTLATB, dob_out[0]);
    buf b_cascadeinrega (cascadeinrega_in, CASCADEINREGA);
    buf b_cascadeinregb (cascadeinregb_in, CASCADEINREGB);
    buf b_cascadeoutrega (CASCADEOUTREGA, doa_outreg[0]);
    buf b_cascadeoutregb (CASCADEOUTREGB, dob_outreg[0]);
    buf b_sbiterr (SBITERR, sbiterr_out_out);
    buf b_dbiterr (DBITERR, dbiterr_out_out);
    buf b_eccparity[7:0] (ECCPARITY, eccparity_out);


    initial begin
	    
	case (WRITE_WIDTH_A)

	    0, 1, 2, 4, 9, 18 : ;
	    36 : begin 
		     if (BRAM_SIZE == 18 && BRAM_MODE == "TRUE_DUAL_PORT") begin
			 $display("Attribute Syntax Error : The attribute WRITE_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", WRITE_WIDTH_A);
			 $finish;
		     end
		 end
	    72 : begin
		     if (BRAM_SIZE == 18) begin
			 $display("Attribute Syntax Error : The attribute WRITE_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", WRITE_WIDTH_A);
			 $finish;
		     end
		     else if ((BRAM_SIZE == 16 || BRAM_SIZE == 36) && BRAM_MODE == "TRUE_DUAL_PORT") begin // BRAM_SIZE == 16 - Virtex 4
			 $display("Attribute Syntax Error : The attribute WRITE_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9, 18 or 36.", WRITE_WIDTH_A);
			 $finish;
		     end
	         end
	    default : begin
		          if (BRAM_SIZE == 18) begin
			      $display("Attribute Syntax Error : The attribute WRITE_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", WRITE_WIDTH_A);
			      $finish;
			  end
			  else if (BRAM_SIZE == 16 || BRAM_SIZE == 36) begin
			      $display("Attribute Syntax Error : The attribute WRITE_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9, 18 or 36.", WRITE_WIDTH_A);
			      $finish;
			  end
	               end

	endcase // case(WRITE_WIDTH_A)


    	case (WRITE_WIDTH_B)

	    0, 1, 2, 4, 9, 18 : ;
	    36 : begin 
		     if (BRAM_SIZE == 18 && BRAM_MODE == "TRUE_DUAL_PORT") begin
			 $display("Attribute Syntax Error : The attribute WRITE_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", WRITE_WIDTH_B);
			 $finish;
		     end
		 end
	    72 : begin
		     if (BRAM_SIZE == 18) begin
			 $display("Attribute Syntax Error : The attribute WRITE_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", WRITE_WIDTH_B);
			 $finish;
		     end
		     else if ((BRAM_SIZE == 16 || BRAM_SIZE == 36) && BRAM_MODE == "TRUE_DUAL_PORT") begin
			 $display("Attribute Syntax Error : The attribute WRITE_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9, 18 or 36.", WRITE_WIDTH_B);
			 $finish;
		     end
	         end
	    default : begin
		          if (BRAM_SIZE == 18) begin
			      $display("Attribute Syntax Error : The attribute WRITE_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", WRITE_WIDTH_B);
			      $finish;
			  end
			  else if (BRAM_SIZE == 16 || BRAM_SIZE == 36) begin
			      $display("Attribute Syntax Error : The attribute WRITE_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9, 18 or 36.", WRITE_WIDTH_B);
			      $finish;
			  end
	               end

	endcase // case(WRITE_WIDTH_B)

	
	case (READ_WIDTH_A)

	    0, 1, 2, 4, 9, 18 : ;
	    36 : begin 
		     if (BRAM_SIZE == 18 && BRAM_MODE == "TRUE_DUAL_PORT") begin
			 $display("Attribute Syntax Error : The attribute READ_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", READ_WIDTH_A);
			 $finish;
		     end
		 end
	    72 : begin
		     if (BRAM_SIZE == 18) begin
			 $display("Attribute Syntax Error : The attribute READ_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", READ_WIDTH_A);
			 $finish;
		     end
		     else if ((BRAM_SIZE == 16 || BRAM_SIZE == 36) && BRAM_MODE == "TRUE_DUAL_PORT") begin
			 $display("Attribute Syntax Error : The attribute READ_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9, 18 or 36.", READ_WIDTH_A);
			 $finish;
		     end
	         end
	    default : begin
		          if (BRAM_SIZE == 18) begin
			      $display("Attribute Syntax Error : The attribute READ_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", READ_WIDTH_A);
			      $finish;
			  end
			  else if (BRAM_SIZE == 16 || BRAM_SIZE == 36) begin
			      $display("Attribute Syntax Error : The attribute READ_WIDTH_A on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9, 18 or 36.", READ_WIDTH_A);
			      $finish;
			  end
	               end

	endcase // case(READ_WIDTH_A)


    	case (READ_WIDTH_B)

	    0, 1, 2, 4, 9, 18 : ;
	    36 : begin 
		     if (BRAM_SIZE == 18 && BRAM_MODE == "TRUE_DUAL_PORT") begin
			 $display("Attribute Syntax Error : The attribute READ_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", READ_WIDTH_B);
			 $finish;
		     end
		 end
	    72 : begin
		     if (BRAM_SIZE == 18) begin
			 $display("Attribute Syntax Error : The attribute READ_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", READ_WIDTH_B);
			 $finish;
		     end
		     else if ((BRAM_SIZE == 16 || BRAM_SIZE == 36) && BRAM_MODE == "TRUE_DUAL_PORT") begin
			 $display("Attribute Syntax Error : The attribute READ_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9, 18 or 36.", READ_WIDTH_B);
			 $finish;
		     end
	         end
	    default : begin
		          if (BRAM_SIZE == 18) begin
			      $display("Attribute Syntax Error : The attribute READ_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9 or 18.", READ_WIDTH_B);
			      $finish;
			  end
			  else if (BRAM_SIZE == 16 || BRAM_SIZE == 36) begin
			      $display("Attribute Syntax Error : The attribute READ_WIDTH_B on ARAMB36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 0, 1, 2, 4, 9, 18 or 36.", READ_WIDTH_B);
			      $finish;
			  end
	               end

	endcase // case(READ_WIDTH_B)

	
	if ((RAM_EXTENSION_A == "LOWER" || RAM_EXTENSION_A == "UPPER") && READ_WIDTH_A != 1) begin
	    $display("Attribute Syntax Error : If attribute RAM_EXTENSION_A on ARAMB36_INTERNAL instance %m is set to either LOWER or UPPER, then READ_WIDTH_A has to be set to 1.");
	    $finish;
	end

	
	if ((RAM_EXTENSION_A == "LOWER" || RAM_EXTENSION_A == "UPPER") && WRITE_WIDTH_A != 1) begin
	    $display("Attribute Syntax Error : If attribute RAM_EXTENSION_A on ARAMB36_INTERNAL instance %m is set to either LOWER or UPPER, then WRITE_WIDTH_A has to be set to 1.");
	    $finish;
	end


	 if ((RAM_EXTENSION_B == "LOWER" || RAM_EXTENSION_B == "UPPER") && READ_WIDTH_B != 1) begin
	    $display("Attribute Syntax Error : If attribute RAM_EXTENSION_B on ARAMB36_INTERNAL instance %m is set to either LOWER or UPPER, then READ_WIDTH_B has to be set to 1.");
	    $finish;
	end


	if ((RAM_EXTENSION_B == "LOWER" || RAM_EXTENSION_B == "UPPER") && WRITE_WIDTH_B != 1) begin
	    $display("Attribute Syntax Error : If attribute RAM_EXTENSION_B on ARAMB36_INTERNAL instance %m is set to either LOWER or UPPER, then WRITE_WIDTH_B has to be set to 1.");
	    $finish;
	end


	if (READ_WIDTH_A == 0 && READ_WIDTH_B == 0) begin
	    $display("Attribute Syntax Error : Attributes READ_WIDTH_A and READ_WIDTH_B on ARAMB36_INTERNAL instance %m, both can not be 0.");
	    $finish;
	end

	       
	case (WRITE_MODE_A)
	    "WRITE_FIRST" : wr_mode_a <= 2'b00;
	    "READ_FIRST"  : wr_mode_a <= 2'b01;
	    "NO_CHANGE"   : wr_mode_a <= 2'b10;
	    default       : begin
				$display("Attribute Syntax Error : The Attribute WRITE_MODE_A on ARAMB36_INTERNAL instance %m is set to %s.  Legal values for this attribute are WRITE_FIRST, READ_FIRST or NO_CHANGE.", WRITE_MODE_A);
				$finish;
			    end
	endcase


	case (WRITE_MODE_B)
	    "WRITE_FIRST" : wr_mode_b <= 2'b00;
	    "READ_FIRST"  : wr_mode_b <= 2'b01;
	    "NO_CHANGE"   : wr_mode_b <= 2'b10;
	    default       : begin
				$display("Attribute Syntax Error : The Attribute WRITE_MODE_B on ARAMB36_INTERNAL instance %m is set to %s.  Legal values for this attribute are WRITE_FIRST, READ_FIRST or NO_CHANGE.", WRITE_MODE_B);
				$finish;
			    end
	endcase

	case (RAM_EXTENSION_A)
	    "UPPER" : cascade_a <= 2'b11;
	    "LOWER" : cascade_a <= 2'b01;
	    "NONE"  : cascade_a <= 2'b00;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute RAM_EXTENSION_A on ARAMB36_INTERNAL instance %m is set to %s.  Legal values for this attribute are LOWER, NONE or UPPER.", RAM_EXTENSION_A);
		          $finish;
		      end
	endcase


	case (RAM_EXTENSION_B)
	    "UPPER" : cascade_b <= 2'b11;
	    "LOWER" : cascade_b <= 2'b01;
	    "NONE"  : cascade_b <= 2'b00;
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute RAM_EXTENSION_B on ARAMB36_INTERNAL instance %m is set to %s.  Legal values for this attribute are LOWER, NONE or UPPER.", RAM_EXTENSION_B);
		          $finish;
		      end
	endcase


	if (!(EN_ECC_WRITE == "TRUE" || EN_ECC_WRITE == "FALSE")) begin
	    $display("Attribute Syntax Error : The attribute EN_ECC_WRITE on ARAMB36_INTERNAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EN_ECC_WRITE);
	    $finish;
	end

	
	if (!(EN_ECC_READ == "TRUE" || EN_ECC_READ == "FALSE")) begin
	    $display("Attribute Syntax Error : The attribute EN_ECC_READ on ARAMB36_INTERNAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EN_ECC_READ);
	    $finish;
	end

	if (EN_ECC_SCRUB == "TRUE") begin
	    $display("DRC Error : The attribute EN_ECC_SCRUB = TRUE is not supported on ARAMB36_INTERNAL instance %m.");
	    $finish;
	end
	
	if (!(EN_ECC_SCRUB == "TRUE" || EN_ECC_SCRUB == "FALSE")) begin
	    $display("Attribute Syntax Error : The attribute EN_ECC_SCRUB on ARAMB36_INTERNAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EN_ECC_SCRUB);
	    $finish;
	end

	
	if (EN_ECC_READ == "FALSE" && EN_ECC_SCRUB == "TRUE") begin
	    $display("DRC Error : The attribute EN_ECC_SCRUB = TRUE is vaild only if the attribute EN_ECC_READ set to TRUE on ARAMB36_INTERNAL instance %m.");
	    $finish;
	end

	
	if ((SIM_COLLISION_CHECK != "ALL") && (SIM_COLLISION_CHECK != "NONE") && (SIM_COLLISION_CHECK != "WARNING_ONLY") && (SIM_COLLISION_CHECK != "GENERATE_X_ONLY")) begin
	    
	    $display("Attribute Syntax Error : The attribute SIM_COLLISION_CHECK on ARAMB36_INTERNAL instance %m is set to %s.  Legal values for this attribute are ALL, NONE, WARNING_ONLY or GENERATE_X_ONLY.", SIM_COLLISION_CHECK);
	    $finish;

	end
	
    end // initial begin


    always @(gsr_in)
	if (gsr_in) begin
	    
	    assign doa_out_out = INIT_A[0 +: ra_width];
	    assign doa_out = INIT_A[0 +: ra_width];
		
	    if (ra_width >= 8) begin
		assign dopa_out_out = INIT_A[ra_width +: ra_widthp];
		assign dopa_out = INIT_A[ra_width +: ra_widthp];
	    end

	    assign dob_out_out = INIT_B[0 +: rb_width];
	    assign dob_out = INIT_B[0 +: rb_width];
		
	    if (rb_width >= 8) begin
		assign dopb_out_out = INIT_B[rb_width +: rb_widthp];
		assign dopb_out = INIT_B[rb_width +: rb_widthp];
	    end

	    assign dbiterr_out = 0;
	    assign sbiterr_out = 0;
	    
	end
	else begin
	    deassign doa_out_out;
	    deassign dopa_out_out;
	    deassign dob_out_out;
	    deassign dopb_out_out;
	    deassign doa_out;
	    deassign dopa_out;
	    deassign dob_out;
	    deassign dopb_out;
	    deassign dbiterr_out;
	    deassign sbiterr_out;
	end


    always @(posedge clka_in) begin

	rising_clka = 1;
	
	if (ena_in === 1'b1) begin
	    prev_time = curr_time;
	    curr_time = $time;
	    addra_reg = addra_in;
	    wea_reg = wea_in;
	    dia_reg = dia_in;
	    dipa_reg = dipa_in;
	end

    end

    always @(posedge clkb_in) begin

	rising_clkb = 1;
	
	if (enb_in === 1'b1) begin
	    prev_time = curr_time;
	    curr_time = $time;
	    addrb_reg = addrb_in;
	    web_reg = web_in;
	    enb_reg = enb_in;
	    dib_reg = dib_in;
	    dipb_reg = dipb_in;
	end

    end // always @ (posedge clkb_in)
    

    always @(posedge rising_clka or posedge rising_clkb) begin

	if (rising_clka)
	    if (cascade_a[1])
		addra_in_15_reg_bram = ~addra_in[15];
	    else
		addra_in_15_reg_bram = addra_in[15];

	if (rising_clkb)
	    if (cascade_b[1])
		addrb_in_15_reg_bram = ~addrb_in[15];
	    else
		addrb_in_15_reg_bram = addrb_in[15];
	
	if ((cascade_a == 2'b00 || (addra_in_15_reg_bram == 1'b0 && cascade_a != 2'b00)) && (cascade_b == 2'b00 || (addrb_in_15_reg_bram == 1'b0 && cascade_b != 2'b00)))  begin

/************************************* Collision starts *****************************************/

	  if (SIM_COLLISION_CHECK != "NONE") begin
	    
	    if (gsr_in === 1'b0) begin
		if (curr_time - prev_time == 0) begin
		    viol_time = 1;
		end
		else if (curr_time - prev_time <= SETUP_READ_FIRST) begin
		    viol_time = 2;
		end

		
		if (ena_in === 1'b0 || enb_in === 1'b0)
		    viol_time = 0;

		
		if ((WRITE_WIDTH_A <= 9 && wea_in[0] === 1'b0) || (WRITE_WIDTH_A == 18 && wea_in[1:0] === 2'b00) || ((WRITE_WIDTH_A == 36 || WRITE_WIDTH_A == 72) && wea_in[3:0] === 4'b0000))
		    if ((WRITE_WIDTH_B <= 9 && web_in[0] === 1'b0) || (WRITE_WIDTH_B == 18 && web_in[1:0] === 2'b00) || (WRITE_WIDTH_B == 36 && web_in[3:0] === 4'b0000) || (WRITE_WIDTH_B == 72 && web_in[7:0] === 8'h00))
			viol_time = 0;
		 
		
		if (viol_time != 0) begin

		    if (rising_clka && rising_clkb) begin

			if (cascade_a[0] || cascade_b[0] == 1) begin
			    if (addra_in[15:col_addr_lsb] === addrb_in[15:col_addr_lsb])
				addr_col = 1;
			    else
				addr_col = 0;
			end
			else begin
			    if (addra_in[14:col_addr_lsb] === addrb_in[14:col_addr_lsb])
				addr_col = 1;
			    else
				addr_col = 0;
			end // else: !if(cascade_a[0] || cascade_b[0] == 1)

			
			if (addr_col) begin
			    
			    viol_type = 2'b01;

			    task_rd_ram_a (addra_in, doa_buf, dopa_buf);
			    task_rd_ram_b (addrb_in, dob_buf, dopb_buf);

			    task_col_wr_ram_a (2'b00, web_in, wea_in, di_x, di_x[7:0], addrb_in, addra_in);
			    task_col_wr_ram_b (2'b00, wea_in, web_in, di_x, di_x[7:0], addra_in, addrb_in);

			    task_col_rd_ram_a (2'b01, web_in, wea_in, addra_in, doa_buf, dopa_buf);
			    task_col_rd_ram_b (2'b01, wea_in, web_in, addrb_in, dob_buf, dopb_buf);

			    task_col_wr_ram_a (2'b10, web_in, wea_in, dia_in, dipa_in, addrb_in, addra_in);

			    
			    if (BRAM_MODE == "ECC" && EN_ECC_WRITE == "TRUE" && enb_in === 1'b1) begin

				dip_ecc_col = fn_dip_ecc(1'b1, dib_in, dipb_in);				
				eccparity_out = dip_ecc_col;
				task_col_wr_ram_b (2'b10, wea_in, web_in, dib_in, dip_ecc_col, addra_in, addrb_in);

			    end
			    else
				task_col_wr_ram_b (2'b10, wea_in, web_in, dib_in, dipb_in, addra_in, addrb_in);

			    
			    if (wr_mode_a != 2'b01)
				task_col_rd_ram_a (2'b11, web_in, wea_in, addra_in, doa_buf, dopa_buf);
			    if (wr_mode_b != 2'b01)
				task_col_rd_ram_b (2'b11, wea_in, web_in, addrb_in, dob_buf, dopb_buf);


			    if (BRAM_MODE == "ECC" && EN_ECC_READ == "TRUE")
				task_col_ecc_read (doa_buf, dopa_buf, addra_in);
				
			    
			end // if (addr_col)
			else
			    viol_time = 0;
			
		    end
		    else if (rising_clka && !rising_clkb) begin
		
			if (cascade_a[0] || cascade_b[0] == 1) begin
			    if (addra_in[15:col_addr_lsb] === addrb_reg[15:col_addr_lsb])
				addr_col = 1;
			    else
				addr_col = 0;
			end
			else begin
			    if (addra_in[14:col_addr_lsb] === addrb_reg[14:col_addr_lsb])
				addr_col = 1;
			    else
				addr_col = 0;
			end // else: !if(cascade_a[0] || cascade_b[0] == 1)


			if (addr_col) begin
			    
			    viol_type = 2'b10;

			    task_rd_ram_a (addra_in, doa_buf, dopa_buf);
			    
			    task_col_wr_ram_a (2'b00, web_reg, wea_in, di_x, di_x[7:0], addrb_reg, addra_in);
			    task_col_wr_ram_b (2'b00, wea_in, web_reg, di_x, di_x[7:0], addra_in, addrb_reg);
			    
			    task_col_rd_ram_a (2'b01, web_reg, wea_in, addra_in, doa_buf, dopa_buf);
			    task_col_rd_ram_b (2'b01, wea_in, web_reg, addrb_reg, dob_buf, dopb_buf);
			    
			    task_col_wr_ram_a (2'b10, web_reg, wea_in, dia_in, dipa_in, addrb_reg, addra_in);

			    
			    if (BRAM_MODE == "ECC" && EN_ECC_WRITE == "TRUE" && enb_reg === 1'b1) begin

				dip_ecc_col = fn_dip_ecc(1'b1, dib_reg, dipb_reg);				
				eccparity_out = dip_ecc_col;
				task_col_wr_ram_b (2'b10, wea_in, web_reg, dib_reg, dip_ecc_col, addra_in, addrb_reg);

			    end
			    else
				task_col_wr_ram_b (2'b10, wea_in, web_reg, dib_reg, dipb_reg, addra_in, addrb_reg);
			    

			    if (wr_mode_a != 2'b01)
				task_col_rd_ram_a (2'b11, web_reg, wea_in, addra_in, doa_buf, dopa_buf);
			    if (wr_mode_b != 2'b01)
				task_col_rd_ram_b (2'b11, wea_in, web_reg, addrb_reg, dob_buf, dopb_buf);

			    if (BRAM_MODE == "ECC" && EN_ECC_READ == "TRUE")
				task_col_ecc_read (doa_buf, dopa_buf, addra_in);

			    
			end // if (addr_col)
			else
			    viol_time = 0;
			
		    end
		    else if (!rising_clka && rising_clkb) begin

			if (cascade_a[0] || cascade_b[0] == 1) begin
			    if (addra_reg[15:col_addr_lsb] === addrb_in[15:col_addr_lsb])
				addr_col = 1;
			    else
				addr_col = 0;
			end
			else begin
			    if (addra_reg[14:col_addr_lsb] === addrb_in[14:col_addr_lsb])
				addr_col = 1;
			    else
				addr_col = 0;
			end // else: !if(cascade_a[0] || cascade_b[0] == 1)
			

			if (addr_col) begin
			    
			    viol_type = 2'b11;

			    task_rd_ram_b (addrb_in, dob_buf, dopb_buf);

			    task_col_wr_ram_a (2'b00, web_in, wea_reg, di_x, di_x[7:0], addrb_in, addra_reg);
			    task_col_wr_ram_b (2'b00, wea_reg, web_in, di_x, di_x[7:0], addra_reg, addrb_in);
			    
			    task_col_rd_ram_a (2'b01, web_in, wea_reg, addra_reg, doa_buf, dopa_buf);
			    task_col_rd_ram_b (2'b01, wea_reg, web_in, addrb_in, dob_buf, dopb_buf);

			    task_col_wr_ram_a (2'b10, web_in, wea_reg, dia_reg, dipa_reg, addrb_in, addra_reg);


			    if (BRAM_MODE == "ECC" && EN_ECC_WRITE == "TRUE" && enb_in === 1'b1) begin

				dip_ecc_col = fn_dip_ecc(1'b1, dib_in, dipb_in);				
				eccparity_out = dip_ecc_col;
				task_col_wr_ram_b (2'b10, wea_reg, web_in, dib_in, dip_ecc_col, addra_reg, addrb_in);

			    end
			    else
				task_col_wr_ram_b (2'b10, wea_reg, web_in, dib_in, dipb_in, addra_reg, addrb_in);
			    

			    if (wr_mode_a != 2'b01)			    
				task_col_rd_ram_a (2'b11, web_in, wea_reg, addra_reg, doa_buf, dopa_buf);
			    if (wr_mode_b != 2'b01)
				task_col_rd_ram_b (2'b11, wea_reg, web_in, addrb_in, dob_buf, dopb_buf);
			    
			    if (BRAM_MODE == "ECC" && EN_ECC_READ == "TRUE")
				task_col_ecc_read (doa_buf, dopa_buf, addra_reg);

			    
			end // if (addr_col)
			else
			    viol_time = 0;
			
		    end
		    
		end // if (viol_time != 0)
	    end // if (gsr_in === 1'b0)
	      
	    if (SIM_COLLISION_CHECK == "WARNING_ONLY")
		viol_time = 0;
	    
	  end // if (SIM_COLLISION_CHECK != "NONE")

	
/*************************************** end collision ********************************/

	end // if ((cascade_a == 2'b00 || (addra_in_15_reg_bram == 1'b0 && cascade_a != 2'b00)) && (cascade_b == 2'b00 || (addrb_in_15_reg_bram == 1'b0 && cascade_b != 2'b00)))
	
	
/**************************** Port A ****************************************/
	if (rising_clka) begin

	    // DRC
	    if (ssra_in === 1 && BRAM_MODE == "ECC")
		$display("DRC Warning : SET/RESET (SSR) is not supported in ECC mode on ARAMB36_INTERNAL instance %m.");

	    if (ssra_in === 1 && BRAM_SIZE == 16 && DOA_REG == 1) begin
		$display("DRC Error : SET/RESET (SSR) is not supported when optional output registers are used on ARAMB36_INTERNAL instance %m.");
		$finish;
	    end
	    
	    
	    
	    // registering addra_in[15] the second time
	    if (regcea_in)
		addra_in_15_reg1 = addra_in_15_reg;   
	    
	
	    if (ena_in && (wr_mode_a != 2'b10 || wea_in[0] == 0 || ssra_in == 1'b1))
		if (cascade_a[1])
		    addra_in_15_reg = ~addra_in[15];
		else
		    addra_in_15_reg = addra_in[15];
	
	
	    if (gsr_in == 1'b0 && ena_in == 1'b1 && (cascade_a == 2'b00 || (addra_in_15_reg_bram == 1'b0 && cascade_a != 2'b00))) begin
		
		if (ssra_in == 1'b1 && DOA_REG == 0) begin
		    doa_buf = SRVAL_A[0 +: ra_width];
		    doa_out = SRVAL_A[0 +: ra_width];
		    
		    if (ra_width >= 8) begin
			dopa_buf = SRVAL_A[ra_width +: ra_widthp];
			dopa_out = SRVAL_A[ra_width +: ra_widthp];
		    end
		end
		

		if (viol_time == 0) begin

		    if ((wr_mode_a == 2'b01 && (ssra_in === 1'b0 || DOA_REG == 1)) || (BRAM_MODE == "ECC" && EN_ECC_READ == "TRUE")) begin
			task_rd_ram_a (addra_in, doa_buf, dopa_buf);
		      
		
			if (BRAM_MODE == "ECC" && EN_ECC_READ == "TRUE") begin
	  
			    dopr_ecc = fn_dip_ecc(1'b0, doa_buf, dopa_buf);

			    syndrome = dopr_ecc ^ dopa_buf;
		    
			    if (syndrome !== 0) begin
			
				if (syndrome[7]) begin  // dectect single bit error

				    ecc_bit_position = {doa_buf[63:57], dopa_buf[6], doa_buf[56:26], dopa_buf[5], doa_buf[25:11], dopa_buf[4], doa_buf[10:4], dopa_buf[3], doa_buf[3:1], dopa_buf[2], doa_buf[0], dopa_buf[1:0], dopa_buf[7]};

				    if (syndrome[6:0] > 71) begin
					$display ("DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code.");
					$finish;
				    end
				    
				    ecc_bit_position[syndrome[6:0]] = ~ecc_bit_position[syndrome[6:0]]; // correct single bit error in the output 
				    
				    dia_in_ecc_corrected = {ecc_bit_position[71:65], ecc_bit_position[63:33], ecc_bit_position[31:17], ecc_bit_position[15:9], ecc_bit_position[7:5], ecc_bit_position[3]}; // correct single bit error in the memory
				    
				    doa_buf = dia_in_ecc_corrected;
				    
				    dipa_in_ecc_corrected = {ecc_bit_position[0], ecc_bit_position[64], ecc_bit_position[32], ecc_bit_position[16], ecc_bit_position[8], ecc_bit_position[4], ecc_bit_position[2:1]}; // correct single bit error in the parity memory
				    
				    dopa_buf = dipa_in_ecc_corrected;
				    
				    dbiterr_out <= 0;
				    sbiterr_out <= 1;
				    
				end
				else if (!syndrome[7]) begin  // double bit error
				    sbiterr_out <= 0;
				    dbiterr_out <= 1;
				    
				end
			    end // if (syndrome !== 0)
			    else begin
				dbiterr_out <= 0;
				sbiterr_out <= 0;
				
			    end // else: !if(syndrome !== 0)
			    
			    if (ssra_in == 1'b1) begin
				dbiterr_out <= 0;
				sbiterr_out <= 0;
			    end
			    
			end // if (BRAM_MODE == "ECC" && EN_ECC_READ == "TRUE")
		    end // if (((wr_mode_a == 2'b01) && (ssra_in === 1'b0 || DOA_REG == 1)) || (BRAM_MODE == "ECC" && EN_ECC_READ == "TRUE"))
	    
		    if (syndrome !== 0 && syndrome[7] === 1 && EN_ECC_SCRUB == "TRUE")
			task_wr_ram_a (8'hff, dia_in_ecc_corrected, dipa_in_ecc_corrected, addra_in);
		    else
			task_wr_ram_a (wea_in, dia_in, dipa_in, addra_in);
		    
		    
		    if ((wr_mode_a != 2'b01 && (ssra_in === 1'b0 || DOA_REG == 1)) && !(BRAM_MODE == "ECC" && EN_ECC_READ == "TRUE"))
			task_rd_ram_a (addra_in, doa_buf, dopa_buf);
		    
		end // if (viol_time == 0)
	
	    end // if (gsr_in == 1'b0 && ena_in == 1'b1 && (cascade_a == 2'b00 || (addra_in_15_reg_bram == 1'b0 && cascade_a != 2'b00)))
	
	end // if (rising_clka)
	// end of port A


/************************************** port B ***************************************************************/	
	if (rising_clkb) begin

	    // DRC
	    if (ssrb_in === 1 && BRAM_MODE == "ECC")
		$display("DRC Warning : SET/RESET (SSR) is not supported in ECC mode on ARAMB36_INTERNAL instance %m.");
	    
	    if (ssrb_in === 1 && BRAM_SIZE == 16 && DOB_REG == 1) begin
		$display("DRC Error : SET/RESET (SSR) is not supported when optional output registers are used on ARAMB36_INTERNAL instance %m.");
		$finish;
	    end
 
	    if (regceb_in)
		addrb_in_15_reg1 = addrb_in_15_reg;   
	    
	    
	    if (enb_in && (wr_mode_b != 2'b10 || web_in[0] == 0 || ssrb_in == 1'b1))
		if (cascade_b[1])
		    addrb_in_15_reg = ~addrb_in[15];
		else
		    addrb_in_15_reg = addrb_in[15];
	    
	
	    if (gsr_in == 1'b0 && enb_in == 1'b1 && (cascade_b == 2'b00 || (addrb_in_15_reg_bram == 1'b0 && cascade_b != 2'b00))) begin
		if (ssrb_in == 1'b1 && DOB_REG == 0) begin
		    
		    dob_buf = SRVAL_B[0 +: rb_width];
		    dob_out = SRVAL_B[0 +: rb_width];
		    
		    if (rb_width >= 8) begin
			dopb_buf = SRVAL_B[rb_width +: rb_widthp];
			dopb_out = SRVAL_B[rb_width +: rb_widthp];
		    end
		    
		end


		dip_ecc = fn_dip_ecc(1'b1, dib_in, dipb_in);

		eccparity_out = dip_ecc;
		

		if (BRAM_MODE == "ECC" && EN_ECC_WRITE == "TRUE")
		    dipb_in_ecc = dip_ecc;
		else
		    dipb_in_ecc = dipb_in;
		    

		if (viol_time == 0) begin

		    if (wr_mode_b == 2'b01 && (ssrb_in === 1'b0 || DOB_REG == 1))
			task_rd_ram_b (addrb_in, dob_buf, dopb_buf);		
			    
		    
		    if (BRAM_MODE == "ECC" && EN_ECC_WRITE == "TRUE")
			task_wr_ram_b (web_in, dib_in, dipb_in_ecc, addrb_in);
		    else
			task_wr_ram_b (web_in, dib_in, dipb_in, addrb_in);
		    
			
		    if (wr_mode_b != 2'b01 && (ssrb_in === 1'b0 || DOB_REG == 1))
			task_rd_ram_b (addrb_in, dob_buf, dopb_buf);
		
		end // if (viol_time == 0)
		
	    
	    end // if (gsr_in == 1'b0 && enb_in == 1'b1 && (cascade_b == 2'b00 || addrb_in_15_reg_bram == 1'b0))
	    
	end // if (rising_clkb)
	// end of port B
	
	
	// writing outputs of port A	
	if (ena_in && (rising_clka || viol_time != 0)) begin
	    
	    if ((ssra_in === 1'b0 || DOA_REG == 1) && (wr_mode_a != 2'b10 || (WRITE_WIDTH_A <= 9 && wea_in[0] === 1'b0) || (WRITE_WIDTH_A == 18 && wea_in[1:0] === 2'b00) || ((WRITE_WIDTH_A == 36 || WRITE_WIDTH_A == 72) && wea_in[3:0] === 4'b0000))) begin

		// Virtex4 feature
		if (wr_mode_a == 2'b00 && BRAM_SIZE == 16) begin
		    
		    if ((WRITE_WIDTH_A == 18 && !(wea_in[1:0] === 2'b00 || wea_in[1:0] === 2'b11)) || (WRITE_WIDTH_A == 36 && !(wea_in[3:0] === 4'b0000 || wea_in[3:0] === 4'b1111))) begin
			
			if (WRITE_WIDTH_A != READ_WIDTH_A) begin
			    
			    doa_buf[ra_width-1:0] = di_x[ra_width-1:0];
			    
			    if (READ_WIDTH_A >= 9)
				dopa_buf[ra_widthp-1:0] = di_x[ra_widthp-1:0];

			    if (READ_WIDTH_A != 0)
				$display("Functional warning at simulation time (%.3f ns) : ARAMB36_INTERNAL (%m) port A is in WRITE_FIRST mode with parameter WRITE_WIDTH_A = %d, which is different from READ_WIDTH_A = %d. The write will be successful however the read value of all bits on port A is unknown until the next CLKA cycle and all bits of WEA is set to all 1s or 0s.", $time/1000.0, WRITE_WIDTH_A, READ_WIDTH_A);
			    
			end
			else if (WRITE_WIDTH_A == 18) begin
			    for (i = 0; i <= 1; i = i + 1) begin
				
				if (wea_in[i] === 1'b0) begin
				    for (i1 = (8 * i); i1 < (8 * (i + 1)); i1 = i1 + 1)
					doa_buf[i1] = di_x[i1];
				    
				    for (i_p = i; i_p < (i + 1); i_p = i_p + 1)
					dopa_buf[i_p] = di_x[i_p];
				    
				end
				
			    end // for (i = 0; i <= 1; i = i + 1)

			    if (READ_WIDTH_A != 0)
				$display("Functional warning at simulation time (%.3f ns) : ARAMB36_INTERNAL (%m) port A is in WRITE_FIRST mode. The write will be successful, however DOA shows only the enabled newly written byte(s). The other byte values on DOA are unknown until the next CLKA cycle and all bits of WEA is set to all 1s or 0s.", $time/1000.0);
			    
			end // if (WRITE_WIDTH_A == 18)
			else if (WRITE_WIDTH_A == 36) begin
			    for (i = 0; i <= 3; i = i + 1) begin
				
				if (wea_in[i] === 1'b0) begin
				    for (i1 = (8 * i); i1 < (8 * (i + 1)); i1 = i1 + 1)
					doa_buf[i1] = di_x[i1];
					    
				    for (i_p = i; i_p < (i + 1); i_p = i_p + 1)
					dopa_buf[i_p] = di_x[i_p];
				    
				end
				
			    end // for (i = 0; i <= 3; i = i + 1)

			    if (READ_WIDTH_A != 0)
				$display("Functional warning at simulation time (%.3f ns) : ARAMB36_INTERNAL (%m) port A is in WRITE_FIRST mode. The write will be successful, however DOA shows only the enabled newly written byte(s). The other byte values on DOA are unknown until the next CLKA cycle and all bits of WEA is set to all 1s or 0s.", $time/1000.0);
			    
			end // if (WRITE_WIDTH_A == 36)
			
		    end // if ((WRITE_WIDTH_A == 18 && !(wea_in[1:0] === 2'b00 || wea_in[1:0] === 2'b11)) || (WRITE_WIDTH_A == 36 && !(wea_in[3:0] === 4'b0000 || wea_in[3:0] === 4'b1111)))
		end // if (wr_mode_a == 2'b00 && BRAM_SIZE == 16)
		
		doa_out <= doa_buf;
		dopa_out <= dopa_buf;

	    end

	end
	

	// writing outputs of port B	
	if (enb_in && (rising_clkb || viol_time != 0)) begin

	    if ((ssrb_in === 1'b0 || DOB_REG == 1) && (wr_mode_b != 2'b10 || (WRITE_WIDTH_B <= 9 && web_in[0] === 1'b0) || (WRITE_WIDTH_B == 18 && web_in[1:0] === 2'b00) || (WRITE_WIDTH_B == 36 && web_in[3:0] === 4'b0000) || (WRITE_WIDTH_B == 72 && web_in[7:0] === 8'h00))) begin
		
		// Virtex4 feature
		if (wr_mode_b == 2'b00 && BRAM_SIZE == 16) begin
		    
		    if ((WRITE_WIDTH_B == 18 && !(web_in[1:0] === 2'b00 || web_in[1:0] === 2'b11)) || (WRITE_WIDTH_B == 36 && !(web_in[3:0] === 4'b0000 || web_in[3:0] === 4'b1111))) begin
			
			if (WRITE_WIDTH_B != READ_WIDTH_B) begin
			    
			    dob_buf[rb_width-1:0] = di_x[rb_width-1:0];
			    
			    if (READ_WIDTH_B >= 9)
				dopb_buf[rb_widthp-1:0] = di_x[rb_widthp-1:0];

			    if (READ_WIDTH_B != 0)
				$display("Functional warning at simulation time (%.3f ns) : ARAMB36_INTERNAL (%m) port B is in WRITE_FIRST mode with parameter WRITE_WIDTH_B = %d, which is different from READ_WIDTH_B = %d. The write will be successful however the read value of all bits on port B is unknown until the next CLKB cycle and all bits of WEB is set to all 1s or 0s.", $time/1000.0, WRITE_WIDTH_B, READ_WIDTH_B);    

			end
			else if (WRITE_WIDTH_B == 18) begin
			    for (i = 0; i <= 1; i = i + 1) begin
				
				if (web_in[i] === 1'b0) begin
				    for (i1 = (8 * i); i1 < (8 * (i + 1)); i1 = i1 + 1)
					dob_buf[i1] = di_x[i1];
				    
				    for (i_p = i; i_p < (i + 1); i_p = i_p + 1)
					dopb_buf[i_p] = di_x[i_p];
				    
				end
				
			    end // for (i = 0; i <= 1; i = i + 1)

			    if (READ_WIDTH_B != 0)
				$display("Functional warning at simulation time (%.3f ns) : ARAMB36_INTERNAL (%m) port B is in WRITE_FIRST mode. The write will be successful, however DOB shows only the enabled newly written byte(s). The other byte values on DOB are unknown until the next CLKB cycle and all bits of WEB is set to all 1s or 0s.", $time/1000.0);
			    
			end // if (WRITE_WIDTH_B == 18)
			else if (WRITE_WIDTH_B == 36) begin
			    for (i = 0; i <= 3; i = i + 1) begin
				
				if (web_in[i] === 1'b0) begin
				    for (i1 = (8 * i); i1 < (8 * (i + 1)); i1 = i1 + 1)
					dob_buf[i1] = di_x[i1];
				    
				    for (i_p = i; i_p < (i + 1); i_p = i_p + 1)
					dopb_buf[i_p] = di_x[i_p];
				    
				end
				
			    end // for (i = 0; i <= 3; i = i + 1)

			    if (READ_WIDTH_B != 0)
				$display("Functional warning at simulation time (%.3f ns) : ARAMB36_INTERNAL (%m) port B is in WRITE_FIRST mode. The write will be successful, however DOB shows only the enabled newly written byte(s). The other byte values on DOB are unknown until the next CLKB cycle and all bits of WEB is set to all 1s or 0s.", $time/1000.0);
			    
			end // if (WRITE_WIDTH_B == 36)

		    end // if ((WRITE_WIDTH_B == 18 && !(web_in[1:0] === 2'b00 || web_in[1:0] === 2'b11)) || (WRITE_WIDTH_B == 36 && !(web_in[3:0] === 4'b0000 || web_in[3:0] === 4'b1111)))
		end // if (wr_mode_b == 2'b00 && BRAM_SIZE == 16)
		
		dob_out <= dob_buf;
		dopb_out <= dopb_buf;

	    end
	    
	end

	
	viol_time = 0;
	rising_clka = 0;
	rising_clkb = 0;
	viol_type = 2'b00;
	col_wr_wr_msg = 1;
	col_wra_rdb_msg = 1;
	col_wrb_rda_msg = 1;

    end // always @ (posedge rising_clka or posedge rising_clkb)


    // ********* Cascade  Port A ********
    always @(posedge clka_in or cascadeinlata_in or addra_in_15_reg or doa_out or dopa_out) begin

	if (cascade_a[1] == 1'b1 && addra_in_15_reg == 1'b1) begin
	    doa_out_mux[0] = cascadeinlata_in;
	end
	else begin
	    doa_out_mux = doa_out;
	    dopa_out_mux = dopa_out;
	end
	
    end

    
    always @(posedge regclka_in or cascadeinrega_in or addra_in_15_reg1 or doa_outreg or dopa_outreg) begin

	if (cascade_a[1] == 1'b1 && addra_in_15_reg1 == 1'b1) begin
	    doa_outreg_mux[0] = cascadeinrega_in;
	end
	else begin
	    doa_outreg_mux = doa_outreg;
	    dopa_outreg_mux = dopa_outreg;
	end

    end

    
    // ********* Cascade  Port B ********
    always @(posedge clkb_in or cascadeinlatb_in or addrb_in_15_reg or dob_out or dopb_out) begin

	if (cascade_b[1] == 1'b1 && addrb_in_15_reg == 1'b1) begin
	    dob_out_mux[0] = cascadeinlatb_in;
	end
	else begin
	    dob_out_mux = dob_out;
	    dopb_out_mux = dopb_out;
	end
	
    end

    
    always @(posedge regclkb_in or cascadeinregb_in or addrb_in_15_reg1 or dob_outreg or dopb_outreg) begin

	if (cascade_b[1] == 1'b1 && addrb_in_15_reg1 == 1'b1) begin
	    dob_outreg_mux[0] = cascadeinregb_in;
	end
	else begin
	    dob_outreg_mux = dob_outreg;
	    dopb_outreg_mux = dopb_outreg;
	end

    end

    
    // ***** Output Registers **** Port A *****
    always @(posedge regclka_in or posedge gsr_in) begin
	
	if (DOA_REG == 1) begin

	    if (gsr_in == 1'b1) begin
		
		dbiterr_outreg <= 0;
		sbiterr_outreg <= 0;
		doa_outreg <= INIT_A[0 +: ra_width];

		if (ra_width >= 8)
		    dopa_outreg <= INIT_A[ra_width +: ra_widthp];
		
	    end
	    else if (gsr_in == 1'b0) begin

		dbiterr_outreg <= dbiterr_out;
		sbiterr_outreg <= sbiterr_out;
		
		if (regcea_in == 1'b1) begin
 		    if (ssra_in == 1'b1) begin

			doa_outreg <= SRVAL_A[0 +: ra_width];

			if (ra_width >= 8)
			    dopa_outreg <= SRVAL_A[ra_width +: ra_widthp];
			
		    end
		    else if (ssra_in == 1'b0) begin

			doa_outreg <= doa_out;
			dopa_outreg <= dopa_out;
		    
		    end
		end // if (regcea_in == 1'b1)

	    end // if (gsr_in == 1'b0)

	end // if (DOA_REG == 1)

    end // always @ (posedge clka_in or posedge gsr_in)
    

    always @(temp_wire or doa_out_mux or dopa_out_mux or doa_outreg_mux or dopa_outreg_mux or dbiterr_out or dbiterr_outreg or sbiterr_out or sbiterr_outreg) begin

	case (DOA_REG)

	    0 : begin
		    dbiterr_out_out = dbiterr_out;
		    sbiterr_out_out = sbiterr_out;
	            doa_out_out = doa_out_mux;
		    dopa_out_out = dopa_out_mux;
	        end
	    1 : begin
		    dbiterr_out_out = dbiterr_outreg;
		    sbiterr_out_out = sbiterr_outreg;
	            doa_out_out = doa_outreg_mux;
	            dopa_out_out = dopa_outreg_mux;
	        end
	    default : begin
	                  $display("Attribute Syntax Error : The attribute DOA_REG on ARAMB36_INTERNAL instance %m is set to %2d.  Legal values for this attribute are 0 or 1.", DOA_REG);
	                  $finish;
	              end

	endcase

    end // always @ (doa_out_mux or dopa_out_mux or doa_outreg_mux or dopa_outreg_mux or dbiterr_out or dbiterr_outreg or sbiterr_out or sbiterr_outreg)
    

// ***** Output Registers **** Port B *****
    always @(posedge regclkb_in or posedge gsr_in) begin

	if (DOB_REG == 1) begin
	
	    if (gsr_in == 1'b1) begin

		dob_outreg <= INIT_B[0 +: rb_width];
		
		if (rb_width >= 8)
		    dopb_outreg <= INIT_B[rb_width +: rb_widthp];
		
	    end
	    else if (gsr_in == 1'b0) begin
		
		if (regceb_in == 1'b1) begin
 		    if (ssrb_in == 1'b1) begin
			
			dob_outreg <= SRVAL_B[0 +: rb_width];
			
			if (rb_width >= 8)
			    dopb_outreg <= SRVAL_B[rb_width +: rb_widthp];
			
		    end
		    else if (ssrb_in == 1'b0) begin
	
			dob_outreg <= dob_out;
			dopb_outreg <= dopb_out;
		   
		    end
		end // if (regceb_in == 1'b1)

	    end // if (gsr_in == 1'b0)

	end // if (DOB_REG == 1)

    end // always @ (posedge clkb_in or posedge gsr_in)
    

    always @(temp_wire or dob_out_mux or dopb_out_mux or dob_outreg_mux or dopb_outreg_mux) begin

	case (DOB_REG)
	    
	    0 : begin
                    dob_out_out = dob_out_mux;
		    dopb_out_out = dopb_out_mux;
	        end
	    1 : begin
	            dob_out_out = dob_outreg_mux;
	            dopb_out_out = dopb_outreg_mux;
	        end
	    default : begin
	                  $display("Attribute Syntax Error : The attribute DOB_REG on ARAMB36_INTERNAL instance %m is set to %2d.  Legal values for this attribute are 0 or 1.", DOB_REG);
	                  $finish;
	              end

	endcase

    end // always @ (dob_out_mux or dopb_out_mux or dob_outreg_mux or dopb_outreg_mux)
    
    
    end
    endgenerate
    // end SAFE mode


/*************************** FAST mode *********************************/
    generate if (SIM_MODE == "FAST") begin

    assign DOA = doa_out_out;
    assign DOB = dob_out_out;
    assign DOPA = dopa_out_out;
    assign DOPB = dopb_out_out;
    assign CASCADEOUTLATA = doa_out[0];
    assign CASCADEOUTLATB = dob_out[0];
    assign CASCADEOUTREGA = doa_outreg[0];
    assign CASCADEOUTREGB = dob_outreg[0];
     

/******************************************** task and function **************************************/
	
    task task_ram;

	input we;
	input [7:0] di;
	input dip;
	inout [7:0] mem_task;
	inout memp_task;

	begin

	    if (we == 1'b1) begin

		mem_task = di;
		
		if (width >= 8)
		    memp_task = dip;
	    end
	end

    endtask // task_ram

    
    task task_wr_ram_a;

	input [7:0] wea_tmp;
	input [63:0] dia_tmp;
	input [7:0] dipa_tmp;
	input [15:0] addra_tmp;

	begin
	    
	    case (wa_width)

		1, 2, 4 : begin

		              if (wa_width >= width)
				  task_ram (wea_tmp[0], dia_tmp[wa_width-1:0], 1'b0, mem[addra_tmp[14:addra_lbit_124]], junk1);
			      else
				  task_ram (wea_tmp[0], dia_tmp[wa_width-1:0], 1'b0, mem[addra_tmp[14:addra_bit_124+1]][(addra_tmp[addra_bit_124:addra_lbit_124] * wa_width) +: wa_width], junk1);

		          end
		8 : begin

		        if (wa_width >= width)
			    task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:3]], memp[addra_tmp[14:3]]);
			else
			    task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:addra_bit_8+1]][(addra_tmp[addra_bit_8:3] * 8) +: 8], memp[addra_tmp[14:addra_bit_8+1]][(addra_tmp[addra_bit_8:3] * 1) +: 1]);

		    end
		16 : begin

		         if (wa_width >= width) begin
				 task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:4]][0 +: 8], memp[addra_tmp[14:4]][0]);
				 task_ram (wea_tmp[1], dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:4]][8 +: 8], memp[addra_tmp[14:4]][1]);
			 end 
			 else begin
				 task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:addra_bit_16+1]][(addra_tmp[addra_bit_16:4] * 16) +: 8], memp[addra_tmp[14:addra_bit_16+1]][(addra_tmp[addra_bit_16:4] * 2) +: 1]);
				 task_ram (wea_tmp[1], dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:addra_bit_16+1]][((addra_tmp[addra_bit_16:4] * 16) + 8) +: 8], memp[addra_tmp[14:addra_bit_16+1]][((addra_tmp[addra_bit_16:4] * 2) + 1) +: 1]);
			 end // else: !if(wa_width >= wb_width)

		    end // case: 16
		32 : begin

		         task_ram (wea_tmp[0], dia_tmp[7:0], dipa_tmp[0], mem[addra_tmp[14:5]][0 +: 8], memp[addra_tmp[14:5]][0]);
		         task_ram (wea_tmp[1], dia_tmp[15:8], dipa_tmp[1], mem[addra_tmp[14:5]][8 +: 8], memp[addra_tmp[14:5]][1]);
		         task_ram (wea_tmp[2], dia_tmp[23:16], dipa_tmp[2], mem[addra_tmp[14:5]][16 +: 8], memp[addra_tmp[14:5]][2]);
		         task_ram (wea_tmp[3], dia_tmp[31:24], dipa_tmp[3], mem[addra_tmp[14:5]][24 +: 8], memp[addra_tmp[14:5]][3]);
		    
		     end // case: 32
	    endcase // case(wa_width)
	end
	
    endtask // task_wr_ram_a
    
    
    task task_wr_ram_b;

	input [7:0] web_tmp;
	input [63:0] dib_tmp;
	input [7:0] dipb_tmp;
	input [15:0] addrb_tmp;

	begin
	    
	    case (wb_width)

		1, 2, 4 : begin

		              if (wb_width >= width)
				  task_ram (web_tmp[0], dib_tmp[wb_width-1:0], 1'b0, mem[addrb_tmp[14:addrb_lbit_124]], junk1);
			      else
				  task_ram (web_tmp[0], dib_tmp[wb_width-1:0], 1'b0, mem[addrb_tmp[14:addrb_bit_124+1]][(addrb_tmp[addrb_bit_124:addrb_lbit_124] * wb_width) +: wb_width], junk1);
		          end
		8 : begin

		        if (wb_width >= width)
			    task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:3]], memp[addrb_tmp[14:3]]);
			else
			    task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:addrb_bit_8+1]][(addrb_tmp[addrb_bit_8:3] * 8) +: 8], memp[addrb_tmp[14:addrb_bit_8+1]][(addrb_tmp[addrb_bit_8:3] * 1) +: 1]);

		    end
		16 : begin

		         if (wb_width >= width) begin
			     task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:4]][0 +: 8], memp[addrb_tmp[14:4]][0]);
			     task_ram (web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:4]][8 +: 8], memp[addrb_tmp[14:4]][1]);
			 end 
			 else begin
			     task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:addrb_bit_16+1]][(addrb_tmp[addrb_bit_16:4] * 16) +: 8], memp[addrb_tmp[14:addrb_bit_16+1]][(addrb_tmp[addrb_bit_16:4] * 2) +: 1]);
			     task_ram (web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:addrb_bit_16+1]][((addrb_tmp[addrb_bit_16:4] * 16) + 8) +: 8], memp[addrb_tmp[14:addrb_bit_16+1]][((addrb_tmp[addrb_bit_16:4] * 2) + 1) +: 1]);
			 end

 		     end // case: 16
		32 : begin

		         task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:5]][0 +: 8], memp[addrb_tmp[14:5]][0]);
		         task_ram (web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:5]][8 +: 8], memp[addrb_tmp[14:5]][1]);
		         task_ram (web_tmp[2], dib_tmp[23:16], dipb_tmp[2], mem[addrb_tmp[14:5]][16 +: 8], memp[addrb_tmp[14:5]][2]);
		         task_ram (web_tmp[3], dib_tmp[31:24], dipb_tmp[3], mem[addrb_tmp[14:5]][24 +: 8], memp[addrb_tmp[14:5]][3]);
		    
		     end // case: 32
		64 : begin

			     task_ram (web_tmp[0], dib_tmp[7:0], dipb_tmp[0], mem[addrb_tmp[14:6]][0 +: 8], memp[addrb_tmp[14:6]][0]);
			     task_ram (web_tmp[1], dib_tmp[15:8], dipb_tmp[1], mem[addrb_tmp[14:6]][8 +: 8], memp[addrb_tmp[14:6]][1]);
			     task_ram (web_tmp[2], dib_tmp[23:16], dipb_tmp[2], mem[addrb_tmp[14:6]][16 +: 8], memp[addrb_tmp[14:6]][2]);
			     task_ram (web_tmp[3], dib_tmp[31:24], dipb_tmp[3], mem[addrb_tmp[14:6]][24 +: 8], memp[addrb_tmp[14:6]][3]);
			     task_ram (web_tmp[4], dib_tmp[39:32], dipb_tmp[4], mem[addrb_tmp[14:6]][32 +: 8], memp[addrb_tmp[14:6]][4]);
			     task_ram (web_tmp[5], dib_tmp[47:40], dipb_tmp[5], mem[addrb_tmp[14:6]][40 +: 8], memp[addrb_tmp[14:6]][5]);
			     task_ram (web_tmp[6], dib_tmp[55:48], dipb_tmp[6], mem[addrb_tmp[14:6]][48 +: 8], memp[addrb_tmp[14:6]][6]);
			     task_ram (web_tmp[7], dib_tmp[63:56], dipb_tmp[7], mem[addrb_tmp[14:6]][56 +: 8], memp[addrb_tmp[14:6]][7]);
			     
		     end // case: 64
	    endcase // case(wb_width)
	end
	
    endtask // task_wr_ram_b

    
    task task_rd_ram_a;

	input [15:0] addra_tmp;
	inout [63:0] doa_tmp;
	inout [7:0] dopa_tmp;

	begin

	    case (ra_width)
		1, 2, 4 : begin
		              if (ra_width >= width)
				  doa_tmp = mem[addra_tmp[14:r_addra_lbit_124]];

			      else
				  doa_tmp = mem[addra_tmp[14:r_addra_bit_124+1]][(addra_tmp[r_addra_bit_124:r_addra_lbit_124] * ra_width) +: ra_width];
		          end
		8 : begin
		        if (ra_width >= width) begin
			    doa_tmp = mem[addra_tmp[14:3]];
			    dopa_tmp =  memp[addra_tmp[14:3]];
			end
			else begin
			    doa_tmp = mem[addra_tmp[14:r_addra_bit_8+1]][(addra_tmp[r_addra_bit_8:3] * 8) +: 8];
			    dopa_tmp = memp[addra_tmp[14:r_addra_bit_8+1]][(addra_tmp[r_addra_bit_8:3] * 1) +: 1];
			end
		    end
		16 : begin
		         if (ra_width >= width) begin
			     doa_tmp = mem[addra_tmp[14:4]];
			     dopa_tmp = memp[addra_tmp[14:4]];
			 end 
			 else begin
			     doa_tmp = mem[addra_tmp[14:r_addra_bit_16+1]][(addra_tmp[r_addra_bit_16:4] * 16) +: 16];
			     dopa_tmp = memp[addra_tmp[14:r_addra_bit_16+1]][(addra_tmp[r_addra_bit_16:4] * 2) +: 2];
			 end
		     end
		32 : begin
		         if (ra_width >= width) begin
			     doa_tmp = mem[addra_tmp[14:5]];
			     dopa_tmp = memp[addra_tmp[14:5]];
			 end 
		     end
		64 : begin
		         if (ra_width >= width) begin
			     doa_tmp = mem[addra_tmp[14:6]];
			     dopa_tmp = memp[addra_tmp[14:6]];
			 end 
		     end				 
	    endcase // case(ra_width)

	end
    endtask // task_rd_ram_a
    

    task task_rd_ram_b;

	input [15:0] addrb_tmp;
	inout [31:0] dob_tmp;
	inout [3:0] dopb_tmp;

	begin
	    
	    case (rb_width)
		1, 2, 4 : begin
		              if (rb_width >= width)
				  dob_tmp = mem[addrb_tmp[14:r_addrb_lbit_124]];
			      else
				  dob_tmp = mem[addrb_tmp[14:r_addrb_bit_124+1]][(addrb_tmp[r_addrb_bit_124:r_addrb_lbit_124] * rb_width) +: rb_width];
               	          end
		8 : begin
		        if (rb_width >= width) begin
			    dob_tmp = mem[addrb_tmp[14:3]];
			    dopb_tmp =  memp[addrb_tmp[14:3]];
			end
			else begin
			    dob_tmp = mem[addrb_tmp[14:r_addrb_bit_8+1]][(addrb_tmp[r_addrb_bit_8:3] * 8) +: 8];
			    dopb_tmp = memp[addrb_tmp[14:r_addrb_bit_8+1]][(addrb_tmp[r_addrb_bit_8:3] * 1) +: 1];
			end
		    end
		16 : begin
		         if (rb_width >= width) begin
			     dob_tmp = mem[addrb_tmp[14:4]];
			     dopb_tmp = memp[addrb_tmp[14:4]];
			 end 
			 else begin
			     dob_tmp = mem[addrb_tmp[14:r_addrb_bit_16+1]][(addrb_tmp[r_addrb_bit_16:4] * 16) +: 16];
			     dopb_tmp = memp[addrb_tmp[14:r_addrb_bit_16+1]][(addrb_tmp[r_addrb_bit_16:4] * 2) +: 2];
			 end
		      end
		32 : begin
		         dob_tmp = mem[addrb_tmp[14:5]];
		         dopb_tmp = memp[addrb_tmp[14:5]];
		     end
		
	    endcase
	end
    endtask // task_rd_ram_b

/******************************************** END task and function **************************************/	


    initial begin

	case (WRITE_MODE_A)
	    "WRITE_FIRST" : wr_mode_a <= 2'b00;
	    "READ_FIRST"  : wr_mode_a <= 2'b01;
	    "NO_CHANGE"   : wr_mode_a <= 2'b10;
	endcase


	case (WRITE_MODE_B)
	    "WRITE_FIRST" : wr_mode_b <= 2'b00;
	    "READ_FIRST"  : wr_mode_b <= 2'b01;
	    "NO_CHANGE"   : wr_mode_b <= 2'b10;
	endcase

    end // initial begin

    
    always @(GSR)
	if (GSR) begin
	    
	    assign doa_out_out = INIT_A[0 +: ra_width];
	    assign doa_out = INIT_A[0 +: ra_width];
		
	    if (ra_width >= 8) begin
		assign dopa_out_out = INIT_A[ra_width +: ra_widthp];
		assign dopa_out = INIT_A[ra_width +: ra_widthp];
	    end

	    assign dob_out_out = INIT_B[0 +: rb_width];
	    assign dob_out = INIT_B[0 +: rb_width];
		
	    if (rb_width >= 8) begin
		assign dopb_out_out = INIT_B[rb_width +: rb_widthp];
		assign dopb_out = INIT_B[rb_width +: rb_widthp];
	    end

	    assign dbiterr_out = 0;
	    assign sbiterr_out = 0;
	    
	end
	else begin
	    deassign doa_out_out;
	    deassign dopa_out_out;
	    deassign dob_out_out;
	    deassign dopb_out_out;
	    deassign doa_out;
	    deassign dopa_out;
	    deassign dob_out;
	    deassign dopb_out;
	    deassign dbiterr_out;
	    deassign sbiterr_out;
	end // else: !if(GSR)

    
/**************************** Port A ****************************************/
	always @(posedge CLKA) begin

	    if (GSR == 1'b0 && ENA == 1'b1) begin
		
		if (SSRA == 1'b1 && DOA_REG == 0) begin
		    doa_buf = SRVAL_A[0 +: ra_width];
		    doa_out = SRVAL_A[0 +: ra_width];
		    
		    if (ra_width >= 8) begin
			dopa_buf = SRVAL_A[ra_width +: ra_widthp];
			dopa_out = SRVAL_A[ra_width +: ra_widthp];
		    end
		end

		if ((wr_mode_a == 2'b01 && (SSRA === 1'b0 || DOA_REG == 1))) begin
		    task_rd_ram_a (ADDRA, doa_buf, dopa_buf);
		end
		
	    
		task_wr_ram_a (WEA, DIA, DIPA, ADDRA);
		    
		    
		if ((wr_mode_a != 2'b01 && (SSRA === 1'b0 || DOA_REG == 1)))
		    task_rd_ram_a (ADDRA, doa_buf, dopa_buf);
		
    
		if ((SSRA === 1'b0 || DOA_REG == 1) && (wr_mode_a != 2'b10 || (WRITE_WIDTH_A <= 9 && WEA[0] === 1'b0) || (WRITE_WIDTH_A == 18 && WEA[1:0] === 2'b00) || ((WRITE_WIDTH_A == 36 || WRITE_WIDTH_A == 72) && WEA[3:0] === 4'b0000))) begin

		    doa_out <= doa_buf;
		    dopa_out <= dopa_buf;

		end
	
	    end // if (ENA == 1'b1)
	
	end // always @ (posedge CLKA)
	// end of port A


/************************************** port B ***************************************************************/	
    always @(posedge CLKB) begin
	    
	if (GSR == 1'b0 && ENB == 1'b1) begin
	    if (SSRB == 1'b1 && DOB_REG == 0) begin
		    
		    dob_buf = SRVAL_B[0 +: rb_width];
		    dob_out = SRVAL_B[0 +: rb_width];
		    
		    if (rb_width >= 8) begin
			dopb_buf = SRVAL_B[rb_width +: rb_widthp];
			dopb_out = SRVAL_B[rb_width +: rb_widthp];
		    end
		    
	    end


	    if (wr_mode_b == 2'b01 && (SSRB === 1'b0 || DOB_REG == 1))
		task_rd_ram_b (ADDRB, dob_buf, dopb_buf);		
			    
		    
	    task_wr_ram_b (WEB, DIB, DIPB, ADDRB);
		    
			
	    if (wr_mode_b != 2'b01 && (SSRB === 1'b0 || DOB_REG == 1))
		task_rd_ram_b (ADDRB, dob_buf, dopb_buf);
		
	    
	    if ((SSRB === 1'b0 || DOB_REG == 1) && (wr_mode_b != 2'b10 || (WRITE_WIDTH_B <= 9 && WEB[0] === 1'b0) || (WRITE_WIDTH_B == 18 && WEB[1:0] === 2'b00) || (WRITE_WIDTH_B == 36 && WEB[3:0] === 4'b0000) || (WRITE_WIDTH_B == 72 && WEB[7:0] === 8'h00))) begin
		
		dob_out <= dob_buf;
		dopb_out <= dopb_buf;

	    end // if ((SSRB === 1'b0 || DOB_REG == 1) && (wr_mode_b != 2'b10 || (WRITE_WIDTH_B <= 9 && WEB[0] === 1'b0) || (WRITE_WIDTH_B == 18 && WEB[1:0] === 2'b00) || (WRITE_WIDTH_B == 36 && WEB[3:0] === 4'b0000) || (WRITE_WIDTH_B == 72 && WEB[7:0] === 8'h00)))
		
	end // if (ENB == 1'b1)
	    
    end // always @ (posedge CLKB)
    // end of port B
	
	
    // ***** Output Registers **** Port A *****
    always @(posedge REGCLKA or posedge GSR) begin
	
	if (DOA_REG == 1) begin

	    if (GSR == 1'b1) begin
		
		dbiterr_outreg <= 0;
		sbiterr_outreg <= 0;
		doa_outreg <= INIT_A[0 +: ra_width];

		if (ra_width >= 8)
		    dopa_outreg <= INIT_A[ra_width +: ra_widthp];
		
	    end
	    else if (GSR == 1'b0) begin

		if (REGCEA == 1'b1) begin
 		    if (SSRA == 1'b1) begin

			doa_outreg <= SRVAL_A[0 +: ra_width];

			if (ra_width >= 8)
			    dopa_outreg <= SRVAL_A[ra_width +: ra_widthp];
			
		    end
		    else if (SSRA == 1'b0) begin

			doa_outreg <= doa_out;
			dopa_outreg <= dopa_out;
		    
		    end

		end // if (REGCEA == 1'b1)

	    end // if (GSR == 1'b0)

	end // if (DOA_REG == 1)

    end // always @ (posedge REGCLKA or posedge GSR)
    

    always @(doa_out or dopa_out or doa_outreg or dopa_outreg) begin

	case (DOA_REG)

	    0 : begin
	            doa_out_out = doa_out;
		    dopa_out_out = dopa_out;
	        end
	    1 : begin
	            doa_out_out = doa_outreg;
	            dopa_out_out = dopa_outreg;
	        end

	endcase

    end // always @ (doa_out or dopa_out or doa_outreg or dopa_outreg)

        
// ***** Output Registers **** Port B *****
    always @(posedge REGCLKB or posedge GSR) begin

	if (DOB_REG == 1) begin
	
	    if (GSR == 1'b1) begin

		dob_outreg <= INIT_B[0 +: rb_width];
		
		if (rb_width >= 8)
		    dopb_outreg <= INIT_B[rb_width +: rb_widthp];
		
	    end
	    else if (GSR == 1'b0) begin
		
		if (REGCEB == 1'b1) begin
 		    if (SSRB == 1'b1) begin
			
			dob_outreg <= SRVAL_B[0 +: rb_width];
			
			if (rb_width >= 8)
			    dopb_outreg <= SRVAL_B[rb_width +: rb_widthp];
			
		    end
		    else if (SSRB == 1'b0) begin
	
			dob_outreg <= dob_out;
			dopb_outreg <= dopb_out;
		   
		    end

		end // if (REGCEB == 1'b1)

	    end // if (GSR == 1'b0)

	end // if (DOB_REG == 1)

    end // always @ (posedge REGCLKB or posedge GSR)
    

    always @(dob_out or dopb_out or dob_outreg or dopb_outreg) begin

	case (DOB_REG)
	    
	    0 : begin
                    dob_out_out = dob_out;
		    dopb_out_out = dopb_out;
	        end
	    1 : begin
	            dob_out_out = dob_outreg;
	            dopb_out_out = dopb_outreg;
	        end

	endcase

    end // always @ (dob_out or dopb_out or dob_outreg or dopb_outreg)

    
    end
    endgenerate
    // end FAST mode
    
endmodule // ARAMB36_INTERNAL
