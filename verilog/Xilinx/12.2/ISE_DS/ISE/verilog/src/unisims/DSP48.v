// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/DSP48.v,v 1.15 2008/08/20 23:54:41 fphillip Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  18X18 Signed Multiplier Followed by Three-Input Adder with Pipeline Registers
// /___/   /\     Filename : DSP48.v
// \   \  /  \    Timestamp : Thu Mar 11 16:43:44 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/11/05 - Initialized outpus.
//    08/21/06 - CR 232521 -- fixed DRC check to allow "0010101_11"
//    05/29/07 - Added wire declaration for internal signals
//    02/06/08 - CR 455601 -- DRC relax for OPMODEREG/CARRYINSELREG
//    08/20/08 - CR 479833 -- DRC relax for OPMODEREG/CARRYINSELREG
// End Revision

`timescale  1 ps / 1 ps

module DSP48 (BCOUT, P, PCOUT, A, B, BCIN, C, CARRYIN, CARRYINSEL, CEA, CEB, CEC, CECARRYIN, CECINSUB, CECTRL, CEM, CEP, CLK, OPMODE, PCIN, RSTA, RSTB, RSTC, RSTCARRYIN, RSTCTRL, RSTM, RSTP, SUBTRACT); 

    output [17:0] BCOUT; 
    output [47:0] P; 
    output [47:0] PCOUT;

    input [17:0] A;
    input [17:0] B;
    input [17:0] BCIN;
    input [47:0] C;
    input CARRYIN;
    input [1:0] CARRYINSEL;
    input CEA;
    input CEB;
    input CEC;
    input CECARRYIN;
    input CECINSUB;
    input CECTRL;
    input CEM;
    input CEP;
    input CLK;
    tri0 GSR = glbl.GSR;
    input [6:0] OPMODE;
    input [47:0] PCIN;
    input RSTA;
    input RSTB;
    input RSTC;
    input RSTCARRYIN;
    input RSTCTRL;
    input RSTM;  
    input RSTP;
    input SUBTRACT; 

    parameter integer AREG = 1;
    parameter integer BREG = 1;
    parameter B_INPUT = "DIRECT";
    parameter integer CARRYINREG = 1;
    parameter integer CARRYINSELREG = 1;
    parameter integer CREG = 1;
    parameter LEGACY_MODE = "MULT18X18S";
    parameter integer MREG = 1;
    parameter integer OPMODEREG = 1;
    parameter integer PREG = 1;
    parameter integer SUBTRACTREG = 1;

    reg [17:0] a_in_int;
    reg [17:0] b_o_mux, qb_o_mux = 18'b0, qb_o_reg1, qb_o_reg2;
    reg [17:0] qa_o_mux, qa_o_reg1, qa_o_reg2;
    reg [1:0] qcarryinsel_o_mux, qcarryinsel_o_reg1;
    reg [35:0] qmult_o_mux, qmult_o_reg1;
    reg [47:0] qc_o_mux, qc_o_reg1;
    reg [47:0] qp_o_mux = 48'b0, qp_o_reg1;
    reg [47:0] qx_o_mux, qy_o_mux, qz_o_mux;
    reg [6:0]  qopmode_o_mux, qopmode_o_reg1;
    reg carryin_o_mux2, carryin_o_mux4, qcarryin_o_mux1, qcarryin_o_reg3;
    reg qcarryin_o_mux, qcarryin_o_reg1;
    reg qsubtract_o_mux, qsubtract_o_reg1;
    reg invalid_opmode, add_flag;
    reg [47:0] add_o;
    
    wire [17:0] bcin_in, a_in, b_in;
    wire [1:0] carryinsel_in;
    wire [35:0] mult_o;
    wire [47:0] pcin_in, c_in;
    wire [6:0] opmode_in;
    wire qb_o_mux0, qb_o_mux1, qb_o_mux2, qb_o_mux3, qb_o_mux4, qb_o_mux5, qb_o_mux6, qb_o_mux7, qb_o_mux8, qb_o_mux9, qb_o_mux10, qb_o_mux11, qb_o_mux12, qb_o_mux13, qb_o_mux14, qb_o_mux15, qb_o_mux16, qb_o_mux17;
    wire qp_o_mux0, qp_o_mux1, qp_o_mux2, qp_o_mux3, qp_o_mux4, qp_o_mux5, qp_o_mux6, qp_o_mux7, qp_o_mux8, qp_o_mux9, qp_o_mux10, qp_o_mux11, qp_o_mux12, qp_o_mux13, qp_o_mux14, qp_o_mux15, qp_o_mux16, qp_o_mux17, qp_o_mux18, qp_o_mux19, qp_o_mux20, qp_o_mux21, qp_o_mux22, qp_o_mux23, qp_o_mux24, qp_o_mux25, qp_o_mux26, qp_o_mux27, qp_o_mux28, qp_o_mux29, qp_o_mux30, qp_o_mux31, qp_o_mux32, qp_o_mux33, qp_o_mux34, qp_o_mux35, qp_o_mux36, qp_o_mux37, qp_o_mux38, qp_o_mux39, qp_o_mux40, qp_o_mux41, qp_o_mux42, qp_o_mux43, qp_o_mux44, qp_o_mux45, qp_o_mux46, qp_o_mux47;
    wire selp47;   

    wire carryin_in;
    wire cea_in;
    wire ceb_in;
    wire cec_in;
    wire cecarryin_in;
    wire cecinsub_in;
    wire cectrl_in;
    wire cem_in;
    wire cep_in;
    wire clk_in;
    wire gsr_in;

    wire rsta_in;
    wire rstb_in;
    wire rstcarryin_in;
    wire rstc_in;
    wire rstctrl_in;
    wire rstm_in;
    wire rstp_in;
    wire subtract_in;

    buf b_qp_o_mux_0 (qp_o_mux0, qp_o_mux[0]);
    buf b_qp_o_mux_1 (qp_o_mux1, qp_o_mux[1]);
    buf b_qp_o_mux_2 (qp_o_mux2, qp_o_mux[2]);
    buf b_qp_o_mux_3 (qp_o_mux3, qp_o_mux[3]);
    buf b_qp_o_mux_4 (qp_o_mux4, qp_o_mux[4]);
    buf b_qp_o_mux_5 (qp_o_mux5, qp_o_mux[5]);
    buf b_qp_o_mux_6 (qp_o_mux6, qp_o_mux[6]);
    buf b_qp_o_mux_7 (qp_o_mux7, qp_o_mux[7]);
    buf b_qp_o_mux_8 (qp_o_mux8, qp_o_mux[8]);
    buf b_qp_o_mux_9 (qp_o_mux9, qp_o_mux[9]);
    buf b_qp_o_mux_10 (qp_o_mux10, qp_o_mux[10]);
    buf b_qp_o_mux_11 (qp_o_mux11, qp_o_mux[11]);
    buf b_qp_o_mux_12 (qp_o_mux12, qp_o_mux[12]);
    buf b_qp_o_mux_13 (qp_o_mux13, qp_o_mux[13]);
    buf b_qp_o_mux_14 (qp_o_mux14, qp_o_mux[14]);
    buf b_qp_o_mux_15 (qp_o_mux15, qp_o_mux[15]);
    buf b_qp_o_mux_16 (qp_o_mux16, qp_o_mux[16]);
    buf b_qp_o_mux_17 (qp_o_mux17, qp_o_mux[17]);
    buf b_qp_o_mux_18 (qp_o_mux18, qp_o_mux[18]);
    buf b_qp_o_mux_19 (qp_o_mux19, qp_o_mux[19]);
    buf b_qp_o_mux_20 (qp_o_mux20, qp_o_mux[20]);
    buf b_qp_o_mux_21 (qp_o_mux21, qp_o_mux[21]);
    buf b_qp_o_mux_22 (qp_o_mux22, qp_o_mux[22]);
    buf b_qp_o_mux_23 (qp_o_mux23, qp_o_mux[23]);
    buf b_qp_o_mux_24 (qp_o_mux24, qp_o_mux[24]);
    buf b_qp_o_mux_25 (qp_o_mux25, qp_o_mux[25]);
    buf b_qp_o_mux_26 (qp_o_mux26, qp_o_mux[26]);
    buf b_qp_o_mux_27 (qp_o_mux27, qp_o_mux[27]);
    buf b_qp_o_mux_28 (qp_o_mux28, qp_o_mux[28]);
    buf b_qp_o_mux_29 (qp_o_mux29, qp_o_mux[29]);
    buf b_qp_o_mux_30 (qp_o_mux30, qp_o_mux[30]);
    buf b_qp_o_mux_31 (qp_o_mux31, qp_o_mux[31]);
    buf b_qp_o_mux_32 (qp_o_mux32, qp_o_mux[32]);
    buf b_qp_o_mux_33 (qp_o_mux33, qp_o_mux[33]);
    buf b_qp_o_mux_34 (qp_o_mux34, qp_o_mux[34]);
    buf b_qp_o_mux_35 (qp_o_mux35, qp_o_mux[35]);
    buf b_qp_o_mux_36 (qp_o_mux36, qp_o_mux[36]);
    buf b_qp_o_mux_37 (qp_o_mux37, qp_o_mux[37]);
    buf b_qp_o_mux_38 (qp_o_mux38, qp_o_mux[38]);
    buf b_qp_o_mux_39 (qp_o_mux39, qp_o_mux[39]);
    buf b_qp_o_mux_40 (qp_o_mux40, qp_o_mux[40]);
    buf b_qp_o_mux_41 (qp_o_mux41, qp_o_mux[41]);
    buf b_qp_o_mux_42 (qp_o_mux42, qp_o_mux[42]);
    buf b_qp_o_mux_43 (qp_o_mux43, qp_o_mux[43]);
    buf b_qp_o_mux_44 (qp_o_mux44, qp_o_mux[44]);
    buf b_qp_o_mux_45 (qp_o_mux45, qp_o_mux[45]);
    buf b_qp_o_mux_46 (qp_o_mux46, qp_o_mux[46]);
    buf b_qp_o_mux_47 (qp_o_mux47, qp_o_mux[47]);

    buf b_p_o_0 (P[0], qp_o_mux0);
    buf b_p_o_1 (P[1], qp_o_mux1);
    buf b_p_o_2 (P[2], qp_o_mux2);
    buf b_p_o_3 (P[3], qp_o_mux3);
    buf b_p_o_4 (P[4], qp_o_mux4);
    buf b_p_o_5 (P[5], qp_o_mux5);
    buf b_p_o_6 (P[6], qp_o_mux6);
    buf b_p_o_7 (P[7], qp_o_mux7);
    buf b_p_o_8 (P[8], qp_o_mux8);
    buf b_p_o_9 (P[9], qp_o_mux9);
    buf b_p_o_10 (P[10], qp_o_mux10);
    buf b_p_o_11 (P[11], qp_o_mux11);
    buf b_p_o_12 (P[12], qp_o_mux12);
    buf b_p_o_13 (P[13], qp_o_mux13);
    buf b_p_o_14 (P[14], qp_o_mux14);
    buf b_p_o_15 (P[15], qp_o_mux15);
    buf b_p_o_16 (P[16], qp_o_mux16);
    buf b_p_o_17 (P[17], qp_o_mux17);
    buf b_p_o_18 (P[18], qp_o_mux18);
    buf b_p_o_19 (P[19], qp_o_mux19);
    buf b_p_o_20 (P[20], qp_o_mux20);
    buf b_p_o_21 (P[21], qp_o_mux21);
    buf b_p_o_22 (P[22], qp_o_mux22);
    buf b_p_o_23 (P[23], qp_o_mux23);
    buf b_p_o_24 (P[24], qp_o_mux24);
    buf b_p_o_25 (P[25], qp_o_mux25);
    buf b_p_o_26 (P[26], qp_o_mux26);
    buf b_p_o_27 (P[27], qp_o_mux27);
    buf b_p_o_28 (P[28], qp_o_mux28);
    buf b_p_o_29 (P[29], qp_o_mux29);
    buf b_p_o_30 (P[30], qp_o_mux30);
    buf b_p_o_31 (P[31], qp_o_mux31);
    buf b_p_o_32 (P[32], qp_o_mux32);
    buf b_p_o_33 (P[33], qp_o_mux33);
    buf b_p_o_34 (P[34], qp_o_mux34);
    buf b_p_o_35 (P[35], qp_o_mux35);
    buf b_p_o_36 (P[36], qp_o_mux36);
    buf b_p_o_37 (P[37], qp_o_mux37);
    buf b_p_o_38 (P[38], qp_o_mux38);
    buf b_p_o_39 (P[39], qp_o_mux39);
    buf b_p_o_40 (P[40], qp_o_mux40);
    buf b_p_o_41 (P[41], qp_o_mux41);
    buf b_p_o_42 (P[42], qp_o_mux42);
    buf b_p_o_43 (P[43], qp_o_mux43);
    buf b_p_o_44 (P[44], qp_o_mux44);
    buf b_p_o_45 (P[45], qp_o_mux45);
    buf b_p_o_46 (P[46], qp_o_mux46);
    buf b_p_o_47 (P[47], qp_o_mux47);

    buf b_pcout_out_0 (PCOUT[0], qp_o_mux0);
    buf b_pcout_out_1 (PCOUT[1], qp_o_mux1);
    buf b_pcout_out_2 (PCOUT[2], qp_o_mux2);
    buf b_pcout_out_3 (PCOUT[3], qp_o_mux3);
    buf b_pcout_out_4 (PCOUT[4], qp_o_mux4);
    buf b_pcout_out_5 (PCOUT[5], qp_o_mux5);
    buf b_pcout_out_6 (PCOUT[6], qp_o_mux6);
    buf b_pcout_out_7 (PCOUT[7], qp_o_mux7);
    buf b_pcout_out_8 (PCOUT[8], qp_o_mux8);
    buf b_pcout_out_9 (PCOUT[9], qp_o_mux9);
    buf b_pcout_out_10 (PCOUT[10], qp_o_mux10);
    buf b_pcout_out_11 (PCOUT[11], qp_o_mux11);
    buf b_pcout_out_12 (PCOUT[12], qp_o_mux12);
    buf b_pcout_out_13 (PCOUT[13], qp_o_mux13);
    buf b_pcout_out_14 (PCOUT[14], qp_o_mux14);
    buf b_pcout_out_15 (PCOUT[15], qp_o_mux15);
    buf b_pcout_out_16 (PCOUT[16], qp_o_mux16);
    buf b_pcout_out_17 (PCOUT[17], qp_o_mux17);
    buf b_pcout_out_18 (PCOUT[18], qp_o_mux18);
    buf b_pcout_out_19 (PCOUT[19], qp_o_mux19);
    buf b_pcout_out_20 (PCOUT[20], qp_o_mux20);
    buf b_pcout_out_21 (PCOUT[21], qp_o_mux21);
    buf b_pcout_out_22 (PCOUT[22], qp_o_mux22);
    buf b_pcout_out_23 (PCOUT[23], qp_o_mux23);
    buf b_pcout_out_24 (PCOUT[24], qp_o_mux24);
    buf b_pcout_out_25 (PCOUT[25], qp_o_mux25);
    buf b_pcout_out_26 (PCOUT[26], qp_o_mux26);
    buf b_pcout_out_27 (PCOUT[27], qp_o_mux27);
    buf b_pcout_out_28 (PCOUT[28], qp_o_mux28);
    buf b_pcout_out_29 (PCOUT[29], qp_o_mux29);
    buf b_pcout_out_30 (PCOUT[30], qp_o_mux30);
    buf b_pcout_out_31 (PCOUT[31], qp_o_mux31);
    buf b_pcout_out_32 (PCOUT[32], qp_o_mux32);
    buf b_pcout_out_33 (PCOUT[33], qp_o_mux33);
    buf b_pcout_out_34 (PCOUT[34], qp_o_mux34);
    buf b_pcout_out_35 (PCOUT[35], qp_o_mux35);
    buf b_pcout_out_36 (PCOUT[36], qp_o_mux36);
    buf b_pcout_out_37 (PCOUT[37], qp_o_mux37);
    buf b_pcout_out_38 (PCOUT[38], qp_o_mux38);
    buf b_pcout_out_39 (PCOUT[39], qp_o_mux39);
    buf b_pcout_out_40 (PCOUT[40], qp_o_mux40);
    buf b_pcout_out_41 (PCOUT[41], qp_o_mux41);
    buf b_pcout_out_42 (PCOUT[42], qp_o_mux42);
    buf b_pcout_out_43 (PCOUT[43], qp_o_mux43);
    buf b_pcout_out_44 (PCOUT[44], qp_o_mux44);
    buf b_pcout_out_45 (PCOUT[45], qp_o_mux45);
    buf b_pcout_out_46 (PCOUT[46], qp_o_mux46);
    buf b_pcout_out_47 (PCOUT[47], qp_o_mux47);

    buf b_qb_o_mux_0 (qb_o_mux0, qb_o_mux[0]);
    buf b_qb_o_mux_1 (qb_o_mux1, qb_o_mux[1]);
    buf b_qb_o_mux_2 (qb_o_mux2, qb_o_mux[2]);
    buf b_qb_o_mux_3 (qb_o_mux3, qb_o_mux[3]);
    buf b_qb_o_mux_4 (qb_o_mux4, qb_o_mux[4]);
    buf b_qb_o_mux_5 (qb_o_mux5, qb_o_mux[5]);
    buf b_qb_o_mux_6 (qb_o_mux6, qb_o_mux[6]);
    buf b_qb_o_mux_7 (qb_o_mux7, qb_o_mux[7]);
    buf b_qb_o_mux_8 (qb_o_mux8, qb_o_mux[8]);
    buf b_qb_o_mux_9 (qb_o_mux9, qb_o_mux[9]);
    buf b_qb_o_mux_10 (qb_o_mux10, qb_o_mux[10]);
    buf b_qb_o_mux_11 (qb_o_mux11, qb_o_mux[11]);
    buf b_qb_o_mux_12 (qb_o_mux12, qb_o_mux[12]);
    buf b_qb_o_mux_13 (qb_o_mux13, qb_o_mux[13]);
    buf b_qb_o_mux_14 (qb_o_mux14, qb_o_mux[14]);
    buf b_qb_o_mux_15 (qb_o_mux15, qb_o_mux[15]);
    buf b_qb_o_mux_16 (qb_o_mux16, qb_o_mux[16]);
    buf b_qb_o_mux_17 (qb_o_mux17, qb_o_mux[17]);

    buf b_bcout_0 (BCOUT[0], qb_o_mux0);
    buf b_bcout_1 (BCOUT[1], qb_o_mux1);
    buf b_bcout_2 (BCOUT[2], qb_o_mux2);
    buf b_bcout_3 (BCOUT[3], qb_o_mux3);
    buf b_bcout_4 (BCOUT[4], qb_o_mux4);
    buf b_bcout_5 (BCOUT[5], qb_o_mux5);
    buf b_bcout_6 (BCOUT[6], qb_o_mux6);
    buf b_bcout_7 (BCOUT[7], qb_o_mux7);
    buf b_bcout_8 (BCOUT[8], qb_o_mux8);
    buf b_bcout_9 (BCOUT[9], qb_o_mux9);
    buf b_bcout_10 (BCOUT[10], qb_o_mux10);
    buf b_bcout_11 (BCOUT[11], qb_o_mux11);
    buf b_bcout_12 (BCOUT[12], qb_o_mux12);
    buf b_bcout_13 (BCOUT[13], qb_o_mux13);
    buf b_bcout_14 (BCOUT[14], qb_o_mux14);
    buf b_bcout_15 (BCOUT[15], qb_o_mux15);
    buf b_bcout_16 (BCOUT[16], qb_o_mux16);
    buf b_bcout_17 (BCOUT[17], qb_o_mux17);

    buf b_carryin (carryin_in, CARRYIN);
    buf b_carryinsel_0 (carryinsel_in[0], CARRYINSEL[0]);
    buf b_carryinsel_1 (carryinsel_in[1], CARRYINSEL[1]);
    buf b_cep (cep_in, CEP);
    buf b_cea (cea_in, CEA);
    buf b_ceb (ceb_in, CEB);
    buf b_cec (cec_in, CEC);
    buf b_cecarryin (cecarryin_in, CECARRYIN);
    buf b_cecinsub (cecinsub_in, CECINSUB);
    buf b_cectrl (cectrl_in, CECTRL);
    buf b_cem (cem_in, CEM);
    buf b_clk (clk_in, CLK);
    buf b_gsr (gsr_in, GSR);

    buf b_pcin_0 (pcin_in[0], PCIN[0]);
    buf b_pcin_1 (pcin_in[1], PCIN[1]);
    buf b_pcin_2 (pcin_in[2], PCIN[2]);
    buf b_pcin_3 (pcin_in[3], PCIN[3]);
    buf b_pcin_4 (pcin_in[4], PCIN[4]);
    buf b_pcin_5 (pcin_in[5], PCIN[5]);
    buf b_pcin_6 (pcin_in[6], PCIN[6]);
    buf b_pcin_7 (pcin_in[7], PCIN[7]);
    buf b_pcin_8 (pcin_in[8], PCIN[8]);
    buf b_pcin_9 (pcin_in[9], PCIN[9]);
    buf b_pcin_10 (pcin_in[10], PCIN[10]);
    buf b_pcin_11 (pcin_in[11], PCIN[11]);
    buf b_pcin_12 (pcin_in[12], PCIN[12]);
    buf b_pcin_13 (pcin_in[13], PCIN[13]);
    buf b_pcin_14 (pcin_in[14], PCIN[14]);
    buf b_pcin_15 (pcin_in[15], PCIN[15]);
    buf b_pcin_16 (pcin_in[16], PCIN[16]);
    buf b_pcin_17 (pcin_in[17], PCIN[17]);
    buf b_pcin_18 (pcin_in[18], PCIN[18]);
    buf b_pcin_19 (pcin_in[19], PCIN[19]);
    buf b_pcin_20 (pcin_in[20], PCIN[20]);
    buf b_pcin_21 (pcin_in[21], PCIN[21]);
    buf b_pcin_22 (pcin_in[22], PCIN[22]);
    buf b_pcin_23 (pcin_in[23], PCIN[23]);
    buf b_pcin_24 (pcin_in[24], PCIN[24]);
    buf b_pcin_25 (pcin_in[25], PCIN[25]);
    buf b_pcin_26 (pcin_in[26], PCIN[26]);
    buf b_pcin_27 (pcin_in[27], PCIN[27]);
    buf b_pcin_28 (pcin_in[28], PCIN[28]);
    buf b_pcin_29 (pcin_in[29], PCIN[29]);
    buf b_pcin_30 (pcin_in[30], PCIN[30]);
    buf b_pcin_31 (pcin_in[31], PCIN[31]);
    buf b_pcin_32 (pcin_in[32], PCIN[32]);
    buf b_pcin_33 (pcin_in[33], PCIN[33]);
    buf b_pcin_34 (pcin_in[34], PCIN[34]);
    buf b_pcin_35 (pcin_in[35], PCIN[35]);
    buf b_pcin_36 (pcin_in[36], PCIN[36]);
    buf b_pcin_37 (pcin_in[37], PCIN[37]);
    buf b_pcin_38 (pcin_in[38], PCIN[38]);
    buf b_pcin_39 (pcin_in[39], PCIN[39]);
    buf b_pcin_40 (pcin_in[40], PCIN[40]);
    buf b_pcin_41 (pcin_in[41], PCIN[41]);
    buf b_pcin_42 (pcin_in[42], PCIN[42]);
    buf b_pcin_43 (pcin_in[43], PCIN[43]);
    buf b_pcin_44 (pcin_in[44], PCIN[44]);
    buf b_pcin_45 (pcin_in[45], PCIN[45]);
    buf b_pcin_46 (pcin_in[46], PCIN[46]);
    buf b_pcin_47 (pcin_in[47], PCIN[47]);

    buf b_opmode_0 (opmode_in[0], OPMODE[0]);
    buf b_opmode_1 (opmode_in[1], OPMODE[1]);
    buf b_opmode_2 (opmode_in[2], OPMODE[2]);
    buf b_opmode_3 (opmode_in[3], OPMODE[3]);
    buf b_opmode_4 (opmode_in[4], OPMODE[4]);
    buf b_opmode_5 (opmode_in[5], OPMODE[5]);
    buf b_opmode_6 (opmode_in[6], OPMODE[6]);

    buf b_rstp (rstp_in, RSTP);
    buf b_rsta (rsta_in, RSTA);
    buf b_rstb (rstb_in, RSTB);
    buf b_rstcarryin (rstcarryin_in, RSTCARRYIN);
    buf b_rstc (rstc_in, RSTC);
    buf b_rstctrl (rstctrl_in, RSTCTRL);
    buf b_rstm (rstm_in, RSTM);

    buf b_bcin_0 (bcin_in[0], BCIN[0]);
    buf b_bcin_1 (bcin_in[1], BCIN[1]);
    buf b_bcin_2 (bcin_in[2], BCIN[2]);
    buf b_bcin_3 (bcin_in[3], BCIN[3]);
    buf b_bcin_4 (bcin_in[4], BCIN[4]);
    buf b_bcin_5 (bcin_in[5], BCIN[5]);
    buf b_bcin_6 (bcin_in[6], BCIN[6]);
    buf b_bcin_7 (bcin_in[7], BCIN[7]);
    buf b_bcin_8 (bcin_in[8], BCIN[8]);
    buf b_bcin_9 (bcin_in[9], BCIN[9]);
    buf b_bcin_10 (bcin_in[10], BCIN[10]);
    buf b_bcin_11 (bcin_in[11], BCIN[11]);
    buf b_bcin_12 (bcin_in[12], BCIN[12]);
    buf b_bcin_13 (bcin_in[13], BCIN[13]);
    buf b_bcin_14 (bcin_in[14], BCIN[14]);
    buf b_bcin_15 (bcin_in[15], BCIN[15]);
    buf b_bcin_16 (bcin_in[16], BCIN[16]);
    buf b_bcin_17 (bcin_in[17], BCIN[17]);

    buf b_subtract (subtract_in, SUBTRACT);

    buf b_a_0 (a_in[0], A[0]);
    buf b_a_1 (a_in[1], A[1]);
    buf b_a_2 (a_in[2], A[2]);
    buf b_a_3 (a_in[3], A[3]);
    buf b_a_4 (a_in[4], A[4]);
    buf b_a_5 (a_in[5], A[5]);
    buf b_a_6 (a_in[6], A[6]);
    buf b_a_7 (a_in[7], A[7]);
    buf b_a_8 (a_in[8], A[8]);
    buf b_a_9 (a_in[9], A[9]);
    buf b_a_10 (a_in[10], A[10]);
    buf b_a_11 (a_in[11], A[11]);
    buf b_a_12 (a_in[12], A[12]);
    buf b_a_13 (a_in[13], A[13]);
    buf b_a_14 (a_in[14], A[14]);
    buf b_a_15 (a_in[15], A[15]);
    buf b_a_16 (a_in[16], A[16]);
    buf b_a_17 (a_in[17], A[17]);

    buf b_b_0 (b_in[0], B[0]);
    buf b_b_1 (b_in[1], B[1]);
    buf b_b_2 (b_in[2], B[2]);
    buf b_b_3 (b_in[3], B[3]);
    buf b_b_4 (b_in[4], B[4]);
    buf b_b_5 (b_in[5], B[5]);
    buf b_b_6 (b_in[6], B[6]);
    buf b_b_7 (b_in[7], B[7]);
    buf b_b_8 (b_in[8], B[8]);
    buf b_b_9 (b_in[9], B[9]);
    buf b_b_10 (b_in[10], B[10]);
    buf b_b_11 (b_in[11], B[11]);
    buf b_b_12 (b_in[12], B[12]);
    buf b_b_13 (b_in[13], B[13]);
    buf b_b_14 (b_in[14], B[14]);
    buf b_b_15 (b_in[15], B[15]);
    buf b_b_16 (b_in[16], B[16]);
    buf b_b_17 (b_in[17], B[17]);

    buf b_c_0 (c_in[0], C[0]);
    buf b_c_1 (c_in[1], C[1]);
    buf b_c_2 (c_in[2], C[2]);
    buf b_c_3 (c_in[3], C[3]);
    buf b_c_4 (c_in[4], C[4]);
    buf b_c_5 (c_in[5], C[5]);
    buf b_c_6 (c_in[6], C[6]);
    buf b_c_7 (c_in[7], C[7]);
    buf b_c_8 (c_in[8], C[8]);
    buf b_c_9 (c_in[9], C[9]);
    buf b_c_10 (c_in[10], C[10]);
    buf b_c_11 (c_in[11], C[11]);
    buf b_c_12 (c_in[12], C[12]);
    buf b_c_13 (c_in[13], C[13]);
    buf b_c_14 (c_in[14], C[14]);
    buf b_c_15 (c_in[15], C[15]);
    buf b_c_16 (c_in[16], C[16]);
    buf b_c_17 (c_in[17], C[17]);
    buf b_c_18 (c_in[18], C[18]);
    buf b_c_19 (c_in[19], C[19]);
    buf b_c_20 (c_in[20], C[20]);
    buf b_c_21 (c_in[21], C[21]);
    buf b_c_22 (c_in[22], C[22]);
    buf b_c_23 (c_in[23], C[23]);
    buf b_c_24 (c_in[24], C[24]);
    buf b_c_25 (c_in[25], C[25]);
    buf b_c_26 (c_in[26], C[26]);
    buf b_c_27 (c_in[27], C[27]);
    buf b_c_28 (c_in[28], C[28]);
    buf b_c_29 (c_in[29], C[29]);
    buf b_c_30 (c_in[30], C[30]);
    buf b_c_31 (c_in[31], C[31]);
    buf b_c_32 (c_in[32], C[32]);
    buf b_c_33 (c_in[33], C[33]);
    buf b_c_34 (c_in[34], C[34]);
    buf b_c_35 (c_in[35], C[35]);
    buf b_c_36 (c_in[36], C[36]);
    buf b_c_37 (c_in[37], C[37]);
    buf b_c_38 (c_in[38], C[38]);
    buf b_c_39 (c_in[39], C[39]);
    buf b_c_40 (c_in[40], C[40]);
    buf b_c_41 (c_in[41], C[41]);
    buf b_c_42 (c_in[42], C[42]);
    buf b_c_43 (c_in[43], C[43]);
    buf b_c_44 (c_in[44], C[44]);
    buf b_c_45 (c_in[45], C[45]);
    buf b_c_46 (c_in[46], C[46]);
    buf b_c_47 (c_in[47], C[47]);



//*** GSR pin
    always @(gsr_in) begin
	if (gsr_in) begin
            assign qcarryin_o_reg1 = 1'b0;
            assign qcarryinsel_o_reg1 = 2'b0;
            assign qopmode_o_reg1 = 7'b0;
            assign qa_o_reg1 = 18'b0;
            assign qa_o_reg2 = 18'b0;
            assign qb_o_reg1 = 18'b0;
            assign qb_o_reg2 = 18'b0;
            assign qc_o_reg1 = 48'b0;
            assign qp_o_reg1 = 48'b0;
	    assign qmult_o_reg1 = 36'b0;
            assign qsubtract_o_reg1 = 1'b0;
	end
	else begin
            deassign qcarryin_o_reg1;
            deassign qcarryinsel_o_reg1;
            deassign qopmode_o_reg1;
            deassign qa_o_reg1;
            deassign qa_o_reg2;
            deassign qb_o_reg1;
            deassign qb_o_reg2;
            deassign qc_o_reg1;
            deassign qp_o_reg1;
	    deassign qmult_o_reg1;
            deassign qsubtract_o_reg1;
	end
    end


    initial begin

	add_flag <= 1;
	invalid_opmode <= 1;

	case (LEGACY_MODE)

	    "NONE", "MULT18X18" : ;
            "MULT18X18S" : if (MREG == 0) begin
			       $display("Attribute Syntax Error : The attribute LEGACY_MODE on DSP48 instance %m is set to %s.  This requires attribute MREG to be set to 1.", LEGACY_MODE);
			       $finish;
	                   end
	    default : begin
		          $display("Attribute Syntax Error : The attribute LEGACY_MODE on DSP48 instance %m is set to %s.  Legal values for this attribute are NONE, MULT18X18 or MULT18X18S.", LEGACY_MODE);
		          $finish;
	              end

	endcase
    end
    
    
//*** Input register C with 1 level deep of register

    always @(posedge clk_in) begin
	if (rstc_in)
            qc_o_reg1 <= 48'b0;
	else if (cec_in)
            qc_o_reg1 <= c_in;
    end

    always @(c_in or qc_o_reg1) begin
	case (CREG)
                  0 : qc_o_mux <= c_in;
                  1 : qc_o_mux <= qc_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CREG on DSP48 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", CREG);
	                  $finish;
	              end
	endcase
    end


//*** Input register B with 2 level deep of registers

    always @(bcin_in or b_in) begin
	case (B_INPUT)
             "DIRECT" : b_o_mux <= b_in;
            "CASCADE" : b_o_mux <= bcin_in;
              default : begin
	       	            $display("Attribute Syntax Error : The attribute B_INPUT on DSP48 instance %m is set to %s.  Legal values for this attribute are DIRECT or CASCADE.", B_INPUT);
		            $finish;
                        end
	endcase
    end

    always @(posedge clk_in) begin
	if (rstb_in) begin
            qb_o_reg1 <= 18'b0;
            qb_o_reg2 <= 18'b0;
        end
	else if (ceb_in) begin
            qb_o_reg1 <= b_o_mux;
            qb_o_reg2 <= qb_o_reg1;
        end
    end

    always @(b_o_mux or qb_o_reg1 or qb_o_reg2) begin
	case (BREG)
                  0 : qb_o_mux <= b_o_mux;
                  1 : qb_o_mux <= qb_o_reg1;
                  2 : qb_o_mux <= qb_o_reg2;
            default : begin
	                  $display("Attribute Syntax Error : The attribute BREG on DSP48 instance %m is set to %d.  Legal values for this attribute are 0, 1 or 2.", BREG);
	                  $finish;
	              end
	endcase
    end


//*** Input register A with 2 level deep of registers

    always @(posedge clk_in) begin
	if (rsta_in) begin
            qa_o_reg1 <= 18'b0;
            qa_o_reg2 <= 18'b0;
	end
	else if (cea_in) begin
            qa_o_reg1 <= a_in;
            qa_o_reg2 <= qa_o_reg1;
	end
    end

    always @(a_in or qa_o_reg1 or qa_o_reg2) begin
	case (AREG)
                  0 : qa_o_mux <= a_in;
                  1 : qa_o_mux <= qa_o_reg1;
                  2 : qa_o_mux <= qa_o_reg2;
            default : begin
	                  $display("Attribute Syntax Error : The attribute AREG on DSP48 instance %m is set to %d.  Legal values for this attribute are 0, 1 or 2.", AREG);
	                  $finish;
	              end
	endcase
    end


//*** 18x18 Multiplier
    assign mult_o = {{18{qa_o_mux[17]}}, qa_o_mux} * {{18{qb_o_mux[17]}}, qb_o_mux};

    always @(posedge clk_in) begin
	if (rstm_in) begin
            qmult_o_reg1 <= 36'b0;
	end
	else if (cem_in) begin
            qmult_o_reg1 <= mult_o;
	end
    end

    always @(mult_o or qmult_o_reg1) begin
	case (MREG)
                  0 : qmult_o_mux <= mult_o;
                  1 : qmult_o_mux <= qmult_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute MREG on DSP48 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", MREG);
	                  $finish;
	              end
	endcase
    end


//*** X mux
    
    always @(qp_o_mux or qa_o_mux or qb_o_mux or qmult_o_mux or qopmode_o_mux) begin
	case (qopmode_o_mux[1:0])
              2'b00 : qx_o_mux <= 48'b0;
              2'b01 : qx_o_mux <= {{12{qmult_o_mux[35]}}, qmult_o_mux};
              2'b10 : qx_o_mux <= qp_o_mux;
              2'b11 : qx_o_mux <= {{12{qa_o_mux[17]}}, qa_o_mux[17:0], qb_o_mux[17:0]};
            default : begin
	              end
	endcase
    end


//*** Y mux

    always @(qc_o_mux or qopmode_o_mux) begin
	case (qopmode_o_mux[3:2])
              2'b00 : qy_o_mux <= 48'b0;
              2'b01 : qy_o_mux <= 48'b0;
              2'b11 : qy_o_mux <= qc_o_mux;
            default : begin
	              end
	endcase
    end


//*** Z mux

    always @(qp_o_mux or qc_o_mux or pcin_in or qopmode_o_mux) begin
	case (qopmode_o_mux[6:4])
             3'b000 : qz_o_mux <= 48'b0;
             3'b001 : qz_o_mux <= pcin_in;
             3'b010 : qz_o_mux <= qp_o_mux;
             3'b011 : qz_o_mux <= qc_o_mux;
             3'b101 : qz_o_mux <= {{17{pcin_in[47]}}, pcin_in[47:17]};
             3'b110 : qz_o_mux <= {{17{qp_o_mux[47]}}, qp_o_mux[47:17]};
            default : begin
	              end
	endcase
    end



//*** CarryInSel and OpMode with 1 level of register
    always @(posedge clk_in) begin
	if (rstctrl_in) begin
            qcarryinsel_o_reg1 <= 2'b0;
            qopmode_o_reg1 <= 7'b0;
	end  
	else if (cectrl_in) begin
            qcarryinsel_o_reg1 <= carryinsel_in;
            qopmode_o_reg1 <= opmode_in;
	end
    end


    always @(carryinsel_in or qcarryinsel_o_reg1) begin
	case (CARRYINSELREG)
                  0 : qcarryinsel_o_mux <= carryinsel_in;
                  1 : qcarryinsel_o_mux <= qcarryinsel_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CARRYINSELREG on DSP48 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", CARRYINSELREG);
	                  $finish;
	              end
	endcase
    end


    always @(opmode_in or qopmode_o_reg1) begin
	case (OPMODEREG)
                  0 : qopmode_o_mux <= opmode_in;
                  1 : qopmode_o_mux <= qopmode_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute OPMODEREG on DSP48 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", OPMODEREG);
	                  $finish;
	              end
	endcase
    end



//*** Subtract with 1 level of register
    always @(posedge clk_in) begin
	if (rstctrl_in)
            qsubtract_o_reg1 <= 1'b0;
	else if (cecinsub_in)
            qsubtract_o_reg1 <= subtract_in;
    end


    always @(subtract_in or qsubtract_o_reg1) begin
	case (SUBTRACTREG)
                  0 : qsubtract_o_mux <= subtract_in;
                  1 : qsubtract_o_mux <= qsubtract_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute SUBTRACTREG on DSP48 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", SUBTRACTREG);
	                  $finish;
	              end
	endcase
    end

    
//*** DRC for OPMODE

    always @(qopmode_o_mux or qcarryinsel_o_mux or qsubtract_o_mux or qz_o_mux or qx_o_mux or qy_o_mux or qcarryin_o_mux) begin

	if ($time > 100000) begin  // no check at first 100ns
	
	    case ({qopmode_o_mux, qcarryinsel_o_mux}) 
		
		9'b000000000 : deassign_xyz_mux;
		9'b000001000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
// CR 455601 eased the following drc
		9'b000001001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
//

		9'b000001100 : deassign_xyz_mux;
		9'b000010100 : deassign_xyz_mux;
		9'b000110000 : deassign_xyz_mux;
		9'b000111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b000111001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b000111100 : deassign_xyz_mux;
		9'b000111110 : deassign_xyz_mux;
// CR 479833 eased the following drc
		9'b000111111 : deassign_xyz_mux;
//
		9'b001000000 : deassign_xyz_mux;
		9'b001001000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b001001001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b001001100 : deassign_xyz_mux;
		9'b001001101 : deassign_xyz_mux;
		9'b001001110 : deassign_xyz_mux;
		9'b001010100 : deassign_xyz_mux;
		9'b001010101 : deassign_xyz_mux;
		9'b001010110 : deassign_xyz_mux;
		9'b001010111 : deassign_xyz_mux;
		9'b001110000 : deassign_xyz_mux;
		9'b001110001 : deassign_xyz_mux;
		9'b001111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b001111001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b001111100 : deassign_xyz_mux;
		9'b001111101 : deassign_xyz_mux;
		9'b001111110 : deassign_xyz_mux;
		9'b010000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010001000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010001100 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010001101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010010100 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010110001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010111001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010111100 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010111101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b010111110 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b011000000 : deassign_xyz_mux;
		9'b011001000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b011001001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b011001100 : deassign_xyz_mux;
		9'b011001110 : deassign_xyz_mux;
		9'b011010100 : deassign_xyz_mux;
       		9'b011010110 : if (MREG != 0) display_invalid_opmode_no_mreg; else deassign_xyz_mux;
		9'b011010111 : if (MREG != 1) display_invalid_opmode_mreg; else deassign_xyz_mux;
		9'b011110000 : deassign_xyz_mux;
		9'b011111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b011111100 : deassign_xyz_mux;
		9'b011111101 : deassign_xyz_mux;
		9'b101000000 : deassign_xyz_mux;
		9'b101001000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b101001100 : deassign_xyz_mux;
		9'b101001101 : deassign_xyz_mux;
		9'b101001110 : deassign_xyz_mux;
		9'b101010100 : deassign_xyz_mux;
		9'b101010101 : deassign_xyz_mux;
		9'b101010110 : if (MREG != 0) display_invalid_opmode_no_mreg; else deassign_xyz_mux;
		9'b101010111 : if (MREG != 1) display_invalid_opmode_mreg; else deassign_xyz_mux;
		9'b101110000 : deassign_xyz_mux;
		9'b101110001 : deassign_xyz_mux;
		9'b101111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b101111001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b101111100 : deassign_xyz_mux;
		9'b101111101 : deassign_xyz_mux;
		9'b101111110 : deassign_xyz_mux;
		9'b110000000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110001000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110001100 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110001101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110010100 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110010101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110110000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110110001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110111000 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110111001 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110111100 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110111101 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		9'b110111110 : if (PREG != 1) display_invalid_opmode; else deassign_xyz_mux;
		default : begin
		              if (invalid_opmode) begin

				  add_flag = 0;
			          invalid_opmode = 0;
				  assign qx_o_mux = 48'bx;
				  assign qy_o_mux = 48'bx;
				  assign qz_o_mux = 48'bx;
				  assign add_o = 48'bx;
				  $display("OPMODE Input Warning : The OPMODE %b to DSP48 instance %m is either invalid or the CARRYINSEL %b for that specific OPMODE is invalid at %.3f ns.", qopmode_o_mux, qcarryinsel_o_mux, $time/1000.0);

			      end
	                  end
		
	    endcase // case(opmode_in)
	    
	end // if ($time > 100000)

// ***  Adder
	if (add_flag) begin
	    
	    if (qsubtract_o_mux == 1'b1)
		
		add_o = qz_o_mux - (qx_o_mux + qy_o_mux + qcarryin_o_mux);
	    
	    else if (qsubtract_o_mux == 1'b0)
		
		add_o = qz_o_mux + (qx_o_mux + qy_o_mux + qcarryin_o_mux);

	end // if (add_flag = 1)
    
    end // always @ (qopmode_o_mux)
    
    task deassign_xyz_mux;
	begin
	    add_flag = 1;
	    invalid_opmode = 1;  // reset invalid opmode
	    deassign qx_o_mux;
	    deassign qy_o_mux;
	    deassign qz_o_mux;
	    deassign add_o;
	end
    endtask // deassign_xyz_mux

    task display_invalid_opmode_no_mreg;
	begin
	    if (invalid_opmode) begin
		
		add_flag = 0;
		invalid_opmode = 0;
		assign qx_o_mux = 48'bx;
		assign qy_o_mux = 48'bx;
		assign qz_o_mux = 48'bx;
		assign add_o = 48'bx;
		$display("OPMODE Input Warning : The OPMODE %b with CARRYINSEL %b to DSP48 instance %m at %.3f ns requires attribute MREG set to 0.", qopmode_o_mux, qcarryinsel_o_mux, $time/1000.0);
	    end
	end
    endtask // display_invalid_opmode_no_mreg

    task display_invalid_opmode_mreg;
	begin
	    if (invalid_opmode) begin
		add_flag = 0;
		invalid_opmode = 0;
		assign qx_o_mux = 48'bx;
		assign qy_o_mux = 48'bx;
		assign qz_o_mux = 48'bx;
		assign add_o = 48'bx;
		$display("OPMODE Input Warning : The OPMODE %b with CARRYINSEL %b to DSP48 instance %m at %.3f ns requires attribute MREG set to 1.", qopmode_o_mux, qcarryinsel_o_mux, $time/1000.0);
	    end
	end
    endtask // display_invalid_opmode_mreg
    
    task display_invalid_opmode;
	begin
	    if (invalid_opmode) begin
		add_flag = 0;
		invalid_opmode = 0;
		assign qx_o_mux = 48'bx;
		assign qy_o_mux = 48'bx;
		assign qz_o_mux = 48'bx;
		assign add_o = 48'bx;
		$display("OPMODE Input Warning : The OPMODE %b to DSP48 instance %m at %.3f ns requires attribute PREG set to 1.", qopmode_o_mux, $time/1000.0);
	    end
	end
    endtask // display_invalid_opmode
    
    
//*** CarryIn Mux and Register
    always @(qa_o_mux[17] or qb_o_mux[17] or qopmode_o_mux[0] or qopmode_o_mux[1]) begin
	case (qopmode_o_mux[0] && qopmode_o_mux[1])
                  1'b0 : carryin_o_mux2 <= qa_o_mux[17] ~^ qb_o_mux[17];  // xnor
                  1'b1 : carryin_o_mux2 <= ~qa_o_mux[17];
            default : begin
	              end
	endcase
    end

    always @(carryin_in or qcarryin_o_reg1) begin
	case (CARRYINREG)
                  0 : qcarryin_o_mux1 <= carryin_in;
                  1 : qcarryin_o_mux1 <= qcarryin_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CARRYINREG on DSP48 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", CARRYINREG);
	                  $finish;
	              end
	endcase
    end

    always @(posedge clk_in) begin
	if (rstcarryin_in)
            qcarryin_o_reg1 <= 1'b0;
	else if (cecinsub_in)
            qcarryin_o_reg1 <= carryin_in;
    end

    always @(posedge clk_in) begin
	if (rstcarryin_in) begin
            qcarryin_o_reg3 <= 1'b0;
	end  
	else if (cecarryin_in) begin
            qcarryin_o_reg3 <= carryin_o_mux2;
	end
    end

    assign selp47 = (qopmode_o_mux[1] & ~qopmode_o_mux[0]) | qopmode_o_mux[5] | ~(qopmode_o_mux[6] | qopmode_o_mux[4]);

    always @(qp_o_mux[47] or pcin_in[47] or selp47) begin
	case (selp47)
                  1'b0 : carryin_o_mux4 <= ~pcin_in[47];
                  1'b1 : carryin_o_mux4 <= ~qp_o_mux[47];
            default : begin
	              end
	endcase
    end
   

    always @(qcarryin_o_mux1 or carryin_o_mux2 or qcarryin_o_reg3 or carryin_o_mux4 or qcarryinsel_o_mux) begin
	case (qcarryinsel_o_mux)
              2'b00 : qcarryin_o_mux <= qcarryin_o_mux1;
              2'b01 : qcarryin_o_mux <= carryin_o_mux4;
              2'b10 : qcarryin_o_mux <= carryin_o_mux2;
              2'b11 : qcarryin_o_mux <= qcarryin_o_reg3;
            default : begin
	              end
	endcase
    end


//*** Output register P with 1 level of register
    always @(posedge clk_in) begin
	if (rstp_in)
            qp_o_reg1 <= 48'b0;
	else if (cep_in)
            qp_o_reg1 <= add_o;
    end
 
    always @(qp_o_reg1 or add_o) begin
	case (PREG)
                  0 : qp_o_mux <= add_o;
                  1 : qp_o_mux <= qp_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute PREG on DSP48 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", PREG);
	                  $finish;
	              end
	endcase
    end


    specify

        (CLK *> P) = (100, 100);
        (CLK *> PCOUT) = (100, 100);
        (CLK *> BCOUT) = (100, 100);
	specparam PATHPULSE$ = 0;

    endspecify

endmodule // DSP48
