// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/blanc/MMCM_ADV.v,v 1.45.2.3 2010/05/20 20:41:23 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2010 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Function Simulation Library Component
//  /   /                  Phase Lock Loop Clock
// /___/   /\     Filename : MMCM_ADV.v
// \   \  /  \    Timestamp : 
//  \___\/\___\
//
// Revision:
//    07/07/08 - Initial version.
//    09/19/08 - Change CLKFBOUT_MULT to CLKFBOUT_MULT_F
//                      CLKOUT0_DIVIDE to CLKOUT0_DIVIDE_F
//    10/03/08 - Initial all signals.
//    10/30/08 - Clock source switching without reset (CR492263).
//    11/18/08 - Add timing check for DADDR[6:5].
//    12/02/08 - Fix bug of Duty cycle calculation (CR498696)
//    12/05/08 - change pll_res according to hardware spreadsheet (CR496137)
//    12/09/08 - Enable output at CLKFBOUT_MULT_F*8 for fraction mode (CR499322)
//    01/08/09 - Add phase and duty cycle checks for fraction divide (CR501181)
//    01/09/09 - make pll_res same for BANDWIDTH=HIGH and OPTIMIZED (CR496137)
//    01/14/09 - Fine phase shift wrap around to 0 after 56 times;
//             - PSEN to PSDONE change to 12 PSCLK; RST minpusle to 5ns;
//             - add pulldown to PWRDWN pin. (CR503425)
//    01/14/09 - increase clkout_en_time for fraction mode (CR499322)
//    01/21/09 - align CLKFBOUT to CLKIN for fraction mode (CR504602)
//    01/27/09 - update DRP register address (CR505271)
//    01/28/09 - assign clkout_en0 and clkout_en1 to 0 when RST=1 (CR505767)
//    02/03/09 - Fix bug in clkfb fine phase shift. 
//             - Add delay to clkout_en0_tmp (CR506530).
//    02/05/09 - Add ps_in_ps calculation to clkvco_delay when clkfb_fps_en=1.
//             - round clk_ht clk_lt for duty_cycle (CR506531)
//    02/11/09 - Change VCO_FREQ_MAX and MIN to 1601 and 399 to cover the rounded
//               error (CR507969)
//    02/25/09 - round clk_ht clk_lt for duty_cycle (509386)
//    02/26/09 - Fix for clkin and clkfbin stop case (CR503425)
//    03/04/09 - Fix for CLOCK_HOLD (CR510820).
//    03/27/09 - set default 1 to CLKINSEL pin (CR516951)
//    04/13/09 - Check vco reange when CLKINSEL not connected (CR516951)
//    04/22/09 - Add reset to clkinstopped related signals (CR519102)
//    04/27/09 - Make duty cycle of fraction mode 50/50 (CR519505)
//    05/13/09 - Use period_avg for clkvco_delay calculation (CR521120)
//    07/23/09 - fix bug in clkout0_dly (CR527643)
//    07/27/09 - Do divide when period_avg > 0 (CR528090)
//             - Change DIVCLK_DIVIDE to 80 (CR525904)
//             - Add initial lock setting (CR524523)
//             - Update RES CP setting (CR524522)
//   07/31/09  - Add if else to handle the fracion and nonfraction for clkout_en.
//   08/10/09  - Calculate clkin_lost_val after lock_period=1 (CR528520).
//   08/15/09 - Update LFHF (CR524522)
//   08/19/09 - Set clkfb_lost_val initial value (CR531354)
//   08/28/09 - add clkin_period_tmp_t to handle period_avg calculation
//              when clkin has jitter (CR528520)
//   09/11/09 - Change CLKIN_FREQ_MIN to 10 Mhz (CR532774)
//   10/01/09 - Change CLKIN_FREQ_MAX to 800Mhz (CR535076)
//              Add reset check for clock switchover (CR534900)
//    10/08/09 - Change CLKIN_FREQ MAX & MIN, CLKPFD_FREQ
//               MAX & MIN to parameter (CR535828)
//    10/14/09 - Add clkin_chk_t1 and clkin_chk_t2 to handle check (CR535662)
//   10/22/09 - Add period_vco_mf for clkvco_delay calculation (CR536951)
//              Add cmpvco to compensate period_vco rounded error (CR537073)
//   12/02/09 - not stop clkvco_lk when jitter (CR538717)
//   01/08/10 - Change minimum RST pulse width from 5 ns to 1.5 ns
//              Add 1 ns delay to locked_out_tmp when RST=1 (CR543857)
//   01/19/10 - make change to clkvoc_lk_tmp to handle M=1 case (CR544970)
//   02/09/10 - Add global PLL_LOCKG (CR547918)
//   02/23/10 - Not use edge for locked_out_tmp (CR549667)
//   03/04/10 - Change CLKFBOUT_MULT_F range to 5-64 (CR551618)
//   03/22/10 - Change CLKFBOUT_MULT_F default to 5 (554618)
//   03/24/10 - Add SIM_DEVICE attribute
//   04/07/10 - Generate clkvco_ps_tmp2_en correctly when ps_lock_dly rising
//              and clkout_ps=1 case; increase lock_period time to 10 (CR556468)
//   05/07/10 - Use period_vco_half_rm1 to reduce jitter (CR558966)
// End Revision


`timescale  1 ps / 1 ps


module MMCM_ADV (
  CLKFBOUT,
  CLKFBOUTB,
  CLKFBSTOPPED,
  CLKINSTOPPED,
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
  DO,
  DRDY,
  LOCKED,
  PSDONE,
  CLKFBIN,
  CLKIN1,
  CLKIN2,
  CLKINSEL,
  DADDR,
  DCLK,
  DEN,
  DI,
  DWE,
  PSCLK,
  PSEN,
  PSINCDEC,
  PWRDWN,
  RST
);
  parameter BANDWIDTH = "OPTIMIZED";
  parameter CLKFBOUT_USE_FINE_PS = "FALSE";
  parameter CLKOUT0_USE_FINE_PS = "FALSE";
  parameter CLKOUT1_USE_FINE_PS = "FALSE";
  parameter CLKOUT2_USE_FINE_PS = "FALSE";
  parameter CLKOUT3_USE_FINE_PS = "FALSE";
  parameter CLKOUT4_CASCADE = "FALSE";
  parameter CLKOUT4_USE_FINE_PS = "FALSE";
  parameter CLKOUT5_USE_FINE_PS = "FALSE";
  parameter CLKOUT6_USE_FINE_PS = "FALSE";
  parameter CLOCK_HOLD = "FALSE";
  parameter COMPENSATION = "ZHOLD";
  parameter SIM_DEVICE = "VIRTEX6";
  parameter STARTUP_WAIT = "FALSE";
  parameter integer CLKOUT1_DIVIDE = 1;
  parameter integer CLKOUT2_DIVIDE = 1;
  parameter integer CLKOUT3_DIVIDE = 1;
  parameter integer CLKOUT4_DIVIDE = 1;
  parameter integer CLKOUT5_DIVIDE = 1;
  parameter integer CLKOUT6_DIVIDE = 1;
  parameter integer DIVCLK_DIVIDE = 1;
  parameter real CLKFBOUT_MULT_F = 5.000;
  parameter real CLKFBOUT_PHASE = 0.000;
  parameter real CLKIN1_PERIOD = 0.000;
  parameter real CLKIN2_PERIOD = 0.000;
  parameter real CLKOUT0_DIVIDE_F = 1.000;
  parameter real CLKOUT0_DUTY_CYCLE = 0.500;
  parameter real CLKOUT0_PHASE = 0.000;
  parameter real CLKOUT1_DUTY_CYCLE = 0.500;
  parameter real CLKOUT1_PHASE = 0.000;
  parameter real CLKOUT2_DUTY_CYCLE = 0.500;
  parameter real CLKOUT2_PHASE = 0.000;
  parameter real CLKOUT3_DUTY_CYCLE = 0.500;
  parameter real CLKOUT3_PHASE = 0.000;
  parameter real CLKOUT4_DUTY_CYCLE = 0.500;
  parameter real CLKOUT4_PHASE = 0.000;
  parameter real CLKOUT5_DUTY_CYCLE = 0.500;
  parameter real CLKOUT5_PHASE = 0.000;
  parameter real CLKOUT6_DUTY_CYCLE = 0.500;
  parameter real CLKOUT6_PHASE = 0.000;
  parameter real REF_JITTER1 = 0.010;
  parameter real REF_JITTER2 = 0.010;
  parameter real VCOCLK_FREQ_MAX = 1600.0;
  parameter real VCOCLK_FREQ_MIN = 600.0;
  parameter real CLKIN_FREQ_MAX = 800.0;
  parameter real CLKIN_FREQ_MIN = 10.0;    
  parameter real CLKPFD_FREQ_MAX = 550.0;
  parameter real CLKPFD_FREQ_MIN = 10.0;  

  

  output CLKFBOUT;
  output CLKFBOUTB;
  output CLKFBSTOPPED;
  output CLKINSTOPPED;
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
  output DRDY;
  output LOCKED;
  output PSDONE;
  output [15:0] DO;
                                                                                  
  input CLKFBIN;
  input CLKIN1;
  input CLKIN2;
  input CLKINSEL;
  input DCLK;
  input DEN;
  input DWE;
  input PSCLK;
  input PSEN;
  input PSINCDEC;
  input PWRDWN;
  input RST;
  input [15:0] DI;
  input [6:0] DADDR;

  localparam VCOCLK_FREQ_TARGET = 800;
  localparam M_MIN = 5.000;
  localparam M_MAX = 64.000;
  localparam D_MIN = 1;
  localparam D_MAX = 80;
  localparam O_MIN = 1;
  localparam O_MAX = 128;
  localparam O_MAX_HT_LT = 64;
  localparam REF_CLK_JITTER_MAX = 1000;
  localparam REF_CLK_JITTER_SCALE = 0.1;
  localparam MAX_FEEDBACK_DELAY = 10.0;
  localparam MAX_FEEDBACK_DELAY_SCALE = 1.0;
  localparam ps_max = 55;
  localparam OSC_P2 = 250;

  tri0 GSR = glbl.GSR;
  tri1 p_up;
  wire glock; 

  integer clkfb_div_frac_int, clk0_div_frac_int, clkfb_div_fint, clk0_div_fint;
  integer clkfb_div_fint_tmp1, clkfb_div_fint_odd;
  integer clk0_div_fint_tmp1, clk0_div_fint_odd;
  real clkfb_div_frac, clk0_div_frac;
  reg clk0_frac_out, clkfbm1_frac_out;
  reg clk0_nf_out, clkfbm1_nf_out;
  integer  clk0_frac_en;
  integer  clkfb_frac_en;
  integer ps_in_init;
  reg psdone_out, psdone_out1;
  integer clk0_fps_en, clk1_fps_en, clk2_fps_en, clk3_fps_en, clk4_fps_en;
  integer clk5_fps_en, clk6_fps_en, clkfb_fps_en, fps_en;
  reg clkinstopped_out,  clkin_hold_f;
  reg clkinstopped_out_dly = 0;
  reg clkinstopped_out1 = 0;
  reg clkfbstopped_out1 = 0;
  reg clkfb_stop_tmp, clkfbstopped_out, clkin_stop_tmp;
  reg rst_clkinstopped = 0, rst_clkfbstopped = 0, rst_clkinstopped_tm = 0;
  reg rst_clkinstopped_rc = 0;
  reg rst_clkinstopped_lk, rst_clkfbstopped_lk;
  integer clkin_lost_cnt, clkfb_lost_cnt;
  wire  clkinstopped_hold;
  integer ps_in_ps, ps_cnt;
  integer ps_in_ps_neg, ps_cnt_neg;
  reg clkout_ps, clkout_ps_tmp1, clkout_ps_tmp2;
  time clkout_ps_eg = 0;
  time clkout_ps_peg = 0;
  time clkout_ps_w = 0;
  reg clkvco_ps_tmp1, clkvco_ps_tmp2;
  reg  clkvco_ps_tmp2_en;
  integer clkout4_cascade_int;
  reg [6:0] daddr_lat;
  reg valid_daddr;
  reg drdy_out, drdy_out1;
  reg drp_lock, drp_lock1;
  reg [15:0] dr_sram [127:0];
  reg [160:0] tmp_string;
  reg rst_in;
  reg pwron_int;
  wire orig_rst_in,rst_in_o;
  wire locked_out;
  reg locked_out1;
  reg locked_out_tmp;
  wire clk0_out, clkfbm1_out;
  reg  clk1_out, clk2_out, clk3_out, clk4_out, clk5_out;
  reg clkfb_out;
  reg clkout_en, clkout_en1, clkout_en0, clkout_en0_tmp, clkout_en0_tmp1;
  integer clkout_en_val, clkout_en_t;
  integer  clkin_lock_cnt;
  integer clkout_en_time, locked_en_time, lock_cnt_max;
  integer pll_lock_time, lock_period_time;
  reg clkvco_lk_osc,  clkvco, clkvco_lk_tmp, clkvco_lk_tmp_en;
  reg clkvco_ps_tmp2_pg;
  reg clkvco_lk_dly_tmp;
  reg clkvco_lk_en;
  reg clkvco_lk;
  reg fbclk_tmp;
  reg clk_osc, clkin_p, clkfb_p;
  reg clkinstopped_vco_f;
  time rst_edge, rst_ht;
  reg fb_delay_found, fb_delay_found_tmp;
  reg clkfb_tst;
  real fb_delay_max;
  time fb_delay, clkvco_delay, val_tmp, dly_tmp, fbm1_comp_delay, fbm1_comp_delay_tmp;
  time dly_tmp1, tmp_ps_val2;
  integer dly_tmp_int, tmp_ps_val1;
  time clkin_edge, delay_edge;
  real     period_clkin, clkin_period_tmp;
  integer  clkin_period_tmp_t;
  integer  clkin_period [4:0];
  integer  period_vco, period_vco_half, period_vco_half1, period_vco_half_rm;
  integer  period_vco_half_rm1, period_vco_half_rm2;
  real     cmpvco = 0.0;
  real     clkvco_pdrm;
  integer  period_vco_mf;
  integer  period_vco_tmp;
  integer  period_vco_rm, period_vco_cmp_cnt, clkvco_rm_cnt;
  integer  period_vco_cmp_flag;
  integer  period_vco_max, period_vco_min;
  integer  period_vco1, period_vco2, period_vco3, period_vco4;
  integer  period_vco5, period_vco6, period_vco7;
  integer  period_vco_target, period_vco_target_half;
  integer  period_fb, period_avg;
  integer  clk0_frac_lt, clk0_frac_ht;
  integer  clkfb_frac_lt, clkfb_frac_ht;
  integer period_ps, period_ps_old;
  reg  ps_lock, ps_lock_dly;
  real    clkvco_freq_init_chk, clkfbm1pm_rl;
  real    tmp_real;
  integer ik0, ik1, ik2, ik3, ik4, ib, i, j;
  integer md_product, m_product, m_product2,  clkin_stop_max, clkfb_stop_max;
  integer mf_product, clk0f_product;
  integer clkin_lost_val, clkfb_lost_val, clkin_lost_val_lk;
  time pll_locked_delay, clkin_dly_t, clkfb_dly_t;
  wire pll_unlock, pll_unlock1;
  reg pll_locked_tmp1, pll_locked_tmp2;
  reg lock_period;
  reg pll_locked_tm, unlock_recover;
  reg clkpll_jitter_unlock;
  integer  clkin_jit, REF_CLK_JITTER_MAX_tmp;
  wire init_trig,  clkpll_r, clk0in, clk1in, clk2in, clk3in, clk4in, clk5in, clk6in;
  reg clkpll_tmp1, clkpll;
  wire clkfbm1in, clkfbm1ps_en;
  reg chk_ok;
  wire clk0ps_en, clk1ps_en, clk2ps_en, clk3ps_en, clk4ps_en, clk5ps_en, clk6ps_en;
  reg [7:0] clkout_mux, clkout_ps_mux;
  reg [2:0] clk0pm_sel, clk1pm_sel, clk2pm_sel, clk3pm_sel, clk4pm_sel, clk5pm_sel;
  wire [2:0] clk0pm_sel1, clk5pm_sel1, clk6pm_sel1, clkfbm1pm_sel1;
  reg [2:0] clk6pm_sel, clkfbm1pm_sel;
  integer clk0pm_sel_int, clkfbm1pm_sel_int;
  reg clk0_edge, clk1_edge, clk2_edge, clk3_edge, clk4_edge, clk5_edge, clk6_edge;
  reg clkfbm1_edge, clkfbm2_edge, clkind_edge;
  reg clk0_nocnt, clk1_nocnt, clk2_nocnt, clk3_nocnt, clk4_nocnt, clk5_nocnt;
  reg clk6_nocnt, clkfbm1_nocnt, clkfbm2_nocnt, clkind_nocnt;
  reg clkfbtmp_nocnti;
  reg clkind_edgei, clkind_nocnti; 
  reg [5:0] clk0_dly_cnt, clkout0_dly;
  reg [5:0] clk1_dly_cnt, clkout1_dly;
  reg [5:0] clk2_dly_cnt, clkout2_dly;
  reg [5:0] clk3_dly_cnt, clkout3_dly;
  reg [5:0] clk4_dly_cnt, clkout4_dly;
  reg [5:0] clk5_dly_cnt, clkout5_dly;
  reg [5:0] clk6_dly_cnt, clkout6_dly;
  reg [6:0] clk0_ht, clk0_lt;
  reg [6:0] clk1_ht, clk1_lt;
  reg [6:0] clk2_ht, clk2_lt;
  reg [6:0] clk3_ht, clk3_lt;
  reg [6:0] clk4_ht, clk4_lt;
  reg [6:0] clk5_ht, clk5_lt;
  reg [6:0] clk6_ht, clk6_lt;
  reg [5:0] clkfbm1_dly_cnt, clkfbm1_dly;
  reg [6:0] clkfbm1_ht, clkfbm1_lt;
  reg [6:0] clkfbm2_ht, clkfbm2_lt;
  reg [7:0] clkind_ht, clkind_lt;
  reg [7:0] clkind_hti, clkind_lti;
  reg [7:0] clk0_ht1, clk0_cnt, clk0_div, clk0_div1;
  reg [7:0] clk1_ht1, clk1_cnt, clk1_div, clk1_div1;
  reg [7:0] clk2_ht1, clk2_cnt, clk2_div, clk2_div1;
  reg [7:0] clk3_ht1, clk3_cnt, clk3_div, clk3_div1;
  reg [7:0] clk4_ht1, clk4_cnt, clk4_div, clk4_div1;
  reg [7:0] clk5_ht1, clk5_cnt, clk5_div, clk5_div1;
  reg [7:0] clk6_ht1, clk6_cnt, clk6_div, clk6_div1;
  reg [7:0] clkfbm1_ht1, clkfbm1_cnt, clkfbm1_div, clkfbm1_div1;
  real  clkfbm1_f_div, clkfbm1_div_t;
  integer clkfbm1_div_t_int;
  reg [7:0] clkfbtmp_divi, clkfbtmp_hti, clkfbtmp_lti;
  reg [7:0] clkfbm2_ht1, clkfbm2_cnt, clkfbm2_div, clkfbm2_div1;
  reg [7:0]  clkind_div, clkind_divi, clkind_div1, clkind_cnt, clkind_ht1;
  reg       clkind_out, clkind_out_tmp;
  reg [3:0] pll_cp, pll_res;
  reg [1:0] pll_lfhf;
  reg [1:0] pll_cpres = 2'b01;
  reg [4:0] drp_lock_ref_dly;
  reg [4:0] drp_lock_fb_dly;
  reg [9:0] drp_lock_cnt; 
  reg [9:0] drp_unlock_cnt; 
  reg [9:0] drp_lock_sat_high; 
  wire  clkinsel_tmp;
  real  clkin_chk_t1, clkin_chk_t2;
  reg init_chk;
  reg rst_clkinsel_flag = 0;
  reg clkout0_out, clkout1_out, clkout2_out, clkout3_out, clkout4_out;
  reg clkout5_out, clkout6_out;
  reg clkfbm2_out, clkfbm2_out_tmp, clk6_out;
  reg notifier;
  wire [15:0] do_out, di_in;
  reg [15:0] do_out1;
  wire clkin1_in, clkin2_in, clkfb_in, clkinsel_in, dwe_in, den_in, dclk_in;
  wire clkinsel_in1;
  wire psen_in, psclk_in, psincdec_in, pwrdwn_in;
  wire pwrdwn_in1;
  reg pwrdwn_in1_h = 0;
  reg rst_input_r_h = 0;
  reg pchk_clr = 0;
  reg psincdec_chg = 0;
  reg psincdec_chg_tmp = 0;
  wire [6:0] daddr_in;
  wire rst_input;
  wire rst_input_r;
  reg startup_wait_sig;
  wire delay_PSINCDEC, delay_PSEN, delay_PSCLK, delay_DCLK, delay_DWE;
  wire delay_DEN;
  wire [15:0] delay_DI;
  wire [6:0] delay_DADDR;


  assign CLKINSTOPPED = clkinstopped_out1;
  assign CLKFBSTOPPED = clkfbstopped_out1;
  assign clkin1_in = CLKIN1;
  assign clkin2_in = CLKIN2;
  assign clkfb_in = CLKFBIN;
  assign clkinsel_in = (CLKINSEL === 0) ? 0 : 1;
  assign rst_input_r = RST;
  assign daddr_in = DADDR;
  assign di_in = DI;
  assign dwe_in = DWE;
  assign den_in = DEN;
  assign dclk_in = DCLK;
  assign psclk_in = PSCLK;
  assign psen_in = PSEN;
  assign psincdec_in = PSINCDEC;
  assign pwrdwn_in = PWRDWN;
  assign LOCKED = locked_out1;
  assign DRDY = drdy_out1;
  assign DO = do_out1;
  assign PSDONE = psdone_out1;

  always @(locked_out_tmp)
    locked_out1 = #100 locked_out_tmp;
  always @(drdy_out)
    drdy_out1 = #100 drdy_out;
  always @(do_out)
    do_out1 = #100 do_out;
  always @(psdone_out)
    psdone_out1 = #100 psdone_out;

  initial begin
    #1;
    if ($realtime == 0) begin
      $display ("Simulator Resolution Error : Simulator resolution is set to a value greater than 1 ps.");
	   $display ("In order to simulate the MMCM_ADV, the simulator resolution must be set to 1ps or smaller.");
	   $finish;
    end
  end

  initial begin
    case (STARTUP_WAIT)
      "FALSE" : startup_wait_sig = 0;
      "TRUE" : startup_wait_sig = 1;
      default : begin
        $display("Attribute Syntax Error : The Attribute STARTUP_WAIT on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE.", STARTUP_WAIT);
        $finish;
      end
    endcase

    case (BANDWIDTH)
      "OPTIMIZED" : ;
      "HIGH" : ;
      "LOW" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute BANDWIDTH on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are OPTIMIZED, HIGH, or LOW.", BANDWIDTH);
        $finish;
      end
    endcase

    case (CLKFBOUT_USE_FINE_PS)
      "FALSE" : ;
      "TRUE" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKFBOUT_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKFBOUT_USE_FINE_PS);
        $finish;
      end
    endcase

    case (CLKOUT0_USE_FINE_PS)
      "FALSE" : ;
      "TRUE" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKOUT0_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKOUT0_USE_FINE_PS);
        $finish;
      end
    endcase

    case (CLKOUT1_USE_FINE_PS)
      "FALSE" : ;
      "TRUE" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKOUT1_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKOUT1_USE_FINE_PS);
        $finish;
      end
    endcase

    case (CLKOUT2_USE_FINE_PS)
      "FALSE" : ;
      "TRUE" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKOUT2_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKOUT2_USE_FINE_PS);
        $finish;
      end
    endcase

    case (CLKOUT3_USE_FINE_PS)
      "FALSE" : ;
      "TRUE" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKOUT3_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKOUT3_USE_FINE_PS);
        $finish;
      end
    endcase

    case (CLKOUT4_USE_FINE_PS)
      "FALSE" : ;
      "TRUE" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKOUT4_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKOUT4_USE_FINE_PS);
        $finish;
      end
    endcase

    case (CLKOUT5_USE_FINE_PS)
      "FALSE" : ;
      "TRUE" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKOUT5_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKOUT5_USE_FINE_PS);
        $finish;
      end
    endcase

    case (CLKOUT6_USE_FINE_PS)
      "FALSE" : ;
      "TRUE" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKOUT6_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKOUT6_USE_FINE_PS);
        $finish;
      end
    endcase

    case (CLOCK_HOLD)
      "FALSE" : clkin_hold_f = 0;
      "TRUE" : clkin_hold_f = 1;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLOCK_HOLD on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLOCK_HOLD);
        $finish;
      end
    endcase

    case (CLKOUT4_CASCADE)
      "FALSE" : clkout4_cascade_int = 0;
      "TRUE" : clkout4_cascade_int = 1;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKOUT4_CASCADE on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", CLKOUT4_CASCADE);
        $finish;
      end
    endcase

    case (COMPENSATION)
      "ZHOLD" : ;
      "BUF_IN" : ;
      "CASCADE" : ;
      "EXTERNAL" : ;
      "INTERNAL" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute COMPENSATION on MMCM_ADV instance %m is set to %s.  Legal values for this attribute are ZHOLD, BUF_IN, CASCADE, EXTERNAL, or INTERNAL.", COMPENSATION);
        $finish;
      end
    endcase

    clkfbm1_f_div = CLKFBOUT_MULT_F;
    clkfb_div_fint = $rtoi(CLKFBOUT_MULT_F);
    clkfb_div_frac = CLKFBOUT_MULT_F - clkfb_div_fint;
    if (clkfb_div_frac > 0.000) begin
         clkfb_frac_en = 1;
         clkfb_div_frac_int = $rtoi(clkfb_div_frac * 8);
         clkfb_div_fint_tmp1 = clkfb_div_fint / 2;
         clkfb_div_fint_odd = clkfb_div_fint - clkfb_div_fint_tmp1 -clkfb_div_fint_tmp1;
    end
    else begin
         clkfb_frac_en = 0;
         clkfb_div_frac_int = 0;
    end
//    mf_product = clkfb_div_fint * 8 + clkfb_div_frac_int;
    clk0_div_fint = $rtoi(CLKOUT0_DIVIDE_F);
    clk0_div_frac = CLKOUT0_DIVIDE_F - clk0_div_fint;
    if (clk0_div_frac > 0.000) begin
         clk0_frac_en = 1;
         clk0_div_frac_int = $rtoi(clk0_div_frac * 8);
         clk0_div_fint_tmp1 = clk0_div_fint / 2;
         clk0_div_fint_odd = clk0_div_fint - clk0_div_fint_tmp1 -clk0_div_fint_tmp1;
    end
    else begin
         clk0_frac_en = 0;
         clk0_div_frac_int = 0;
        end
    ps_in_init = 0;
    ps_in_ps = ps_in_init;
    ps_cnt = 0;
        
    if (CLKFBOUT_USE_FINE_PS == "TRUE") begin
      if (clkfb_frac_en == 1) begin
        $display("Attribute Syntax Error : The Attribute CLKFBOUT_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  This attribute should be set to FALSE when CLKFBOUT_MULT_F has fraction part.", CLKFBOUT_USE_FINE_PS);
        $finish;
      end
    else
        clkfb_fps_en = 1;
    end
    else
        clkfb_fps_en = 0;

    if (CLKOUT0_USE_FINE_PS == "TRUE") begin
      if (clk0_frac_en == 1) begin
        $display("Attribute Syntax Error : The Attribute CLKOUT0_USE_FINE_PS on MMCM_ADV instance %m is set to %s.  This attribute should be set to FALSE when CLKOUT0_DIVIDE has fraction part.", CLKOUT0_USE_FINE_PS);
        $finish;
      end
      else
        clk0_fps_en = 1;
    end
    else 
        clk0_fps_en = 0;

    if (CLKOUT1_USE_FINE_PS == "TRUE")
        clk1_fps_en = 1;
    else
        clk1_fps_en = 0;

    if (CLKOUT2_USE_FINE_PS == "TRUE")
        clk2_fps_en = 1;
    else
        clk2_fps_en = 0;

    if (CLKOUT3_USE_FINE_PS == "TRUE")
        clk3_fps_en = 1;
    else
        clk3_fps_en = 0;

    if (CLKOUT4_USE_FINE_PS == "TRUE")
        clk4_fps_en = 1;
    else
        clk4_fps_en = 0;

    if (CLKOUT5_USE_FINE_PS == "TRUE")
        clk5_fps_en = 1;
    else
        clk5_fps_en = 0;

    if (CLKOUT6_USE_FINE_PS == "TRUE")
        clk6_fps_en = 1;
    else
        clk6_fps_en = 0;


    fps_en = clk0_fps_en || clk1_fps_en || clk2_fps_en || clk3_fps_en
             || clk4_fps_en || clk5_fps_en || clk6_fps_en || clkfb_fps_en;

    tmp_string = "CLKOUT0_DIVIDE_F"; 
    chk_ok = para_real_range_chk(CLKOUT0_DIVIDE_F, tmp_string, 1.000, 128.000);
    tmp_string = "CLKOUT0_PHASE";
    if (clk0_frac_en == 0)
      chk_ok = para_real_range_chk(CLKOUT0_PHASE, tmp_string, -360.0, 360.0);
    else 
       if (CLKOUT0_PHASE != 0.0) begin
        $display("Attribute Syntax Error : The Attribute CLKOUT0_PHASE on MMCM_ADV instance %m is set to %f.  This attribute should be set to 0.0 when CLKOUT0_DIVIDE_F has fraction part.", CLKOUT0_PHASE);
        $finish;
       end
    tmp_string = "CLKOUT0_DUTY_CYCLE";
    if (clk0_frac_en == 0)
       chk_ok = para_real_range_chk(CLKOUT0_DUTY_CYCLE, tmp_string, 0.001, 0.999);
    else
       if (CLKOUT0_DUTY_CYCLE != 0.5) begin
        $display("Attribute Syntax Error : The Attribute CLKOUT0_DUTY_CYCLE on MMCM_ADV instance %m is set to %f.  This attribute should be set to 0.5 when CLKOUT0_DIVIDE_F has fraction part.", CLKOUT0_DUTY_CYCLE);
        $finish;
       end
    tmp_string = "CLKOUT1_DIVIDE";
    chk_ok = para_int_range_chk(CLKOUT1_DIVIDE, tmp_string, 1, 128);
    tmp_string = "CLKOUT1_PHASE";
    chk_ok = para_real_range_chk(CLKOUT1_PHASE, tmp_string, -360.0, 360.0);
    tmp_string = "CLKOUT1_DUTY_CYCLE";
    chk_ok = para_real_range_chk(CLKOUT1_DUTY_CYCLE, tmp_string, 0.001, 0.999);
    tmp_string = "CLKOUT2_DIVIDE";
    chk_ok = para_int_range_chk(CLKOUT2_DIVIDE, tmp_string, 1, 128);
    tmp_string = "CLKOUT2_PHASE";
    chk_ok = para_real_range_chk(CLKOUT2_PHASE, tmp_string, -360.0, 360.0);
    tmp_string = "CLKOUT2_DUTY_CYCLE";
    chk_ok = para_real_range_chk(CLKOUT2_DUTY_CYCLE, tmp_string, 0.001, 0.999);
    tmp_string = "CLKOUT3_DIVIDE";
    chk_ok = para_int_range_chk(CLKOUT3_DIVIDE, tmp_string, 1, 128);
    tmp_string = "CLKOUT3_PHASE";
    chk_ok = para_real_range_chk(CLKOUT3_PHASE, tmp_string, -360.0, 360.0);
    tmp_string = "CLKOUT3_DUTY_CYCLE";
    chk_ok = para_real_range_chk(CLKOUT3_DUTY_CYCLE, tmp_string, 0.001, 0.999);
    tmp_string = "CLKOUT4_DIVIDE";
    chk_ok = para_int_range_chk(CLKOUT4_DIVIDE, tmp_string,  1, 128);
    tmp_string = "CLKOUT4_PHASE";
    chk_ok = para_real_range_chk(CLKOUT4_PHASE, tmp_string,  -360.0, 360.0);
    tmp_string = "CLKOUT4_DUTY_CYCLE";
    chk_ok = para_real_range_chk(CLKOUT4_DUTY_CYCLE, tmp_string,  0.001, 0.999);
    if (clk0_frac_en == 0) begin
      tmp_string = "CLKOUT5_DIVIDE";
      chk_ok = para_int_range_chk (CLKOUT5_DIVIDE, tmp_string, 1, 128);
      tmp_string = "CLKOUT5_PHASE";
      chk_ok = para_real_range_chk(CLKOUT5_PHASE, tmp_string, -360.0, 360.0);
      tmp_string = "CLKOUT5_DUTY_CYCLE";
      chk_ok = para_real_range_chk (CLKOUT5_DUTY_CYCLE, tmp_string,  0.001, 0.999);
    end
    if (clkfb_frac_en == 0) begin
      tmp_string = "CLKOUT6_DIVIDE";
      chk_ok = para_int_range_chk (CLKOUT6_DIVIDE, tmp_string, 1, 128);
      tmp_string = "CLKOUT6_PHASE";
      chk_ok = para_real_range_chk(CLKOUT6_PHASE, tmp_string, -360.0, 360.0);
      tmp_string = "CLKOUT6_DUTY_CYCLE";
      chk_ok = para_real_range_chk (CLKOUT6_DUTY_CYCLE, tmp_string,  0.001, 0.999);
    end
    tmp_string = "CLKFBOUT_MULT_F";
//    chk_ok = para_real_range_chk(CLKFBOUT_MULT_F, tmp_string, 1.000, 64.000);
    if (SIM_DEVICE == "VIRTEX6")
      chk_ok = para_real_range_chk(CLKFBOUT_MULT_F, tmp_string, 5.000, 64.000);
    else
      chk_ok = para_real_range_chk(CLKFBOUT_MULT_F, tmp_string, 2.000, 64.000);
    tmp_string = "CLKFBOUT_PHASE";
    if (clkfb_frac_en == 0)
      chk_ok = para_real_range_chk(CLKFBOUT_PHASE, tmp_string, -360.0, 360.0);
    else
      if (CLKFBOUT_PHASE != 0.0) begin
        $display("Attribute Syntax Error : The Attribute CLKFBOUT_PHASE on MMCM_ADV instance %m is set to %f.  This attribute should be set to 0.0 when CLKFBOUT_MULT_F has fraction part.", CLKFBOUT_PHASE);
        $finish;
      end
    tmp_string = "DIVCLK_DIVIDE";
    chk_ok = para_int_range_chk (DIVCLK_DIVIDE, tmp_string, 1, D_MAX);
    tmp_string = "REF_JITTER1";
    chk_ok = para_real_range_chk (REF_JITTER1, tmp_string, 0.000, 0.999);
    tmp_string = "REF_JITTER2";
    chk_ok = para_real_range_chk (REF_JITTER2, tmp_string, 0.000, 0.999);

  if (BANDWIDTH === "LOW")
    pll_lfhf = 2'b11;
  else
    pll_lfhf = 2'b00;

  if (BANDWIDTH === "LOW")
    case (clkfb_div_fint)
       1 :  begin pll_cp = 4'b0001; pll_res = 4'b0111; end
       2 :  begin pll_cp = 4'b0001; pll_res = 4'b0101; end
       3 :  begin pll_cp = 4'b0001; pll_res = 4'b1110; end
       4 :  begin pll_cp = 4'b0001; pll_res = 4'b0110; end
       5 :  begin pll_cp = 4'b0001; pll_res = 4'b1010; end
       6 :  begin pll_cp = 4'b0001; pll_res = 4'b1100; end
       7 :  begin pll_cp = 4'b0001; pll_res = 4'b1100; end
       8 :  begin pll_cp = 4'b0001; pll_res = 4'b1100; end
       9 :  begin pll_cp = 4'b0001; pll_res = 4'b1100; end
       10 :  begin pll_cp = 4'b0001; pll_res = 4'b0010; end
       11 :  begin pll_cp = 4'b0001; pll_res = 4'b0010; end
       12 :  begin pll_cp = 4'b0001; pll_res = 4'b0010; end
       13 :  begin pll_cp = 4'b0010; pll_res = 4'b1100; end
       14 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       15 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       16 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       17 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       18 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       19 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       20 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       21 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       22 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       23 :  begin pll_cp = 4'b0001; pll_res = 4'b0100; end
       24 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       25 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       26 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       27 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       28 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       29 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       30 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       31 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       32 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       33 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       34 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       35 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       36 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       37 :  begin pll_cp = 4'b0001; pll_res = 4'b1000; end
       38 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       39 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       40 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       41 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       42 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       43 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       44 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       45 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       46 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       47 :  begin pll_cp = 4'b0010; pll_res = 4'b0100; end
       48 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       49 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       50 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       51 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       52 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       53 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       54 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       55 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       56 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       57 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       58 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       59 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       60 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       61 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       62 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       63 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
       64 :  begin pll_cp = 4'b0010; pll_res = 4'b1000; end
    endcase
  else if (BANDWIDTH === "HIGH")
    case (clkfb_div_fint)
      1 :  begin pll_cp = 4'b0101; pll_res = 4'b1111; end
      2 :  begin pll_cp = 4'b1111; pll_res = 4'b1111; end
      3 :  begin pll_cp = 4'b1111; pll_res = 4'b1101; end
      4 :  begin pll_cp = 4'b1111; pll_res = 4'b1001; end
      5 :  begin pll_cp = 4'b1111; pll_res = 4'b1110; end
      6 :  begin pll_cp = 4'b1111; pll_res = 4'b0001; end
      7 :  begin pll_cp = 4'b1111; pll_res = 4'b0001; end
      8 :  begin pll_cp = 4'b1111; pll_res = 4'b0110; end
      9 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      10 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      11 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      12 :  begin pll_cp = 4'b1110; pll_res = 4'b1100; end
      13 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      14 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      15 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      16 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      17 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      18 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      19 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      20 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      21 :  begin pll_cp = 4'b1110; pll_res = 4'b1100; end
      22 :  begin pll_cp = 4'b1110; pll_res = 4'b1100; end
      23 :  begin pll_cp = 4'b1110; pll_res = 4'b1100; end
      24 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      25 :  begin pll_cp = 4'b1101; pll_res = 4'b1100; end
      26 :  begin pll_cp = 4'b1100; pll_res = 4'b0010; end
      27 :  begin pll_cp = 4'b1101; pll_res = 4'b1100; end
      28 :  begin pll_cp = 4'b1101; pll_res = 4'b1100; end
      29 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      30 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      31 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      32 :  begin pll_cp = 4'b0111; pll_res = 4'b0010; end
      33 :  begin pll_cp = 4'b1100; pll_res = 4'b1100; end
      34 :  begin pll_cp = 4'b1100; pll_res = 4'b1100; end
      35 :  begin pll_cp = 4'b1110; pll_res = 4'b1010; end
      36 :  begin pll_cp = 4'b0110; pll_res = 4'b0010; end
      37 :  begin pll_cp = 4'b0110; pll_res = 4'b0010; end
      38 :  begin pll_cp = 4'b0110; pll_res = 4'b0010; end
      39 :  begin pll_cp = 4'b0111; pll_res = 4'b1100; end
      40 :  begin pll_cp = 4'b0110; pll_res = 4'b0010; end
      41 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      42 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      43 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      44 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      45 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      46 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      47 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      48 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      49 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      50 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      51 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      52 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      53 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      54 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      55 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      56 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      57 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      58 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      59 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      60 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      61 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      62 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      63 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      64 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
    endcase
  else if (BANDWIDTH === "OPTIMIZED")
    case (clkfb_div_fint)
      1 :  begin pll_cp = 4'b0101; pll_res = 4'b1111; end
      2 :  begin pll_cp = 4'b1111; pll_res = 4'b1111; end
      3 :  begin pll_cp = 4'b1111; pll_res = 4'b1101; end
      4 :  begin pll_cp = 4'b1111; pll_res = 4'b1001; end
      5 :  begin pll_cp = 4'b1111; pll_res = 4'b1110; end
      6 :  begin pll_cp = 4'b1111; pll_res = 4'b0001; end
      7 :  begin pll_cp = 4'b1111; pll_res = 4'b0001; end
      8 :  begin pll_cp = 4'b1111; pll_res = 4'b0110; end
      9 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      10 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      11 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      12 :  begin pll_cp = 4'b1110; pll_res = 4'b1100; end
      13 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      14 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      15 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      16 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      17 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      18 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      19 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      20 :  begin pll_cp = 4'b1111; pll_res = 4'b1100; end
      21 :  begin pll_cp = 4'b1110; pll_res = 4'b1100; end
      22 :  begin pll_cp = 4'b1110; pll_res = 4'b1100; end
      23 :  begin pll_cp = 4'b1110; pll_res = 4'b1100; end
      24 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      25 :  begin pll_cp = 4'b1101; pll_res = 4'b1100; end
      26 :  begin pll_cp = 4'b1100; pll_res = 4'b0010; end
      27 :  begin pll_cp = 4'b1101; pll_res = 4'b1100; end
      28 :  begin pll_cp = 4'b1101; pll_res = 4'b1100; end
      29 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      30 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      31 :  begin pll_cp = 4'b1111; pll_res = 4'b1010; end
      32 :  begin pll_cp = 4'b0111; pll_res = 4'b0010; end
      33 :  begin pll_cp = 4'b1100; pll_res = 4'b1100; end
      34 :  begin pll_cp = 4'b1100; pll_res = 4'b1100; end
      35 :  begin pll_cp = 4'b1110; pll_res = 4'b1010; end
      36 :  begin pll_cp = 4'b0110; pll_res = 4'b0010; end
      37 :  begin pll_cp = 4'b0110; pll_res = 4'b0010; end
      38 :  begin pll_cp = 4'b0110; pll_res = 4'b0010; end
      39 :  begin pll_cp = 4'b0111; pll_res = 4'b1100; end
      40 :  begin pll_cp = 4'b0110; pll_res = 4'b0010; end
      41 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      42 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      43 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      44 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      45 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      46 :  begin pll_cp = 4'b0100; pll_res = 4'b0100; end
      47 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      48 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      49 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      50 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      51 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      52 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      53 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      54 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      55 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      56 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      57 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      58 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      59 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      60 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      61 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      62 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      63 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
      64 :  begin pll_cp = 4'b0011; pll_res = 4'b1000; end
    endcase
/*
    case (clkfb_div_fint)
1 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0010; pll_res = 4'b1011; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1101; end
2 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0101; pll_res = 4'b1111; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1110; end
3 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1100; pll_res = 4'b1111; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0110; end
4 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1111; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1010; end
5 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b0111; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1100; end
6 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1101; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1100; end
7 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b0011; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1100; end
8 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b0101; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0010; end
9 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1001; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0010; end
10 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1110; pll_res = 4'b1110; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0100; end
11 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1110; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0100; end
12 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1110; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0100; end
13 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b0001; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0100; end
14 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b0001; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0100; end
15 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b0001; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0100; end
16 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1110; pll_res = 4'b0110; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0100; end
17 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1110; pll_res = 4'b0110; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0100; end
18 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b0110; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b0100; end
19 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1110; pll_res = 4'b1010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
20 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1110; pll_res = 4'b1010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
21 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
22 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
23 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
24 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
25 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
26 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
27 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1101; pll_res = 4'b1100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
28 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1101; pll_res = 4'b1100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
29 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1101; pll_res = 4'b1100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
30 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1110; pll_res = 4'b1100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0001; pll_res = 4'b1000; end
31 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1101; pll_res = 4'b1100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b0100; end
32 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1100; pll_res = 4'b0010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b0100; end
33 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b1111; pll_res = 4'b1010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b0100; end
34 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0111; pll_res = 4'b0010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b0100; end
35 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0111; pll_res = 4'b0010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b0100; end
36 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0111; pll_res = 4'b0010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b0100; end
37 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0110; pll_res = 4'b0010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b0100; end
38 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0110; pll_res = 4'b0010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
39 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0110; pll_res = 4'b0010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
40 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0110; pll_res = 4'b0010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
41 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0110; pll_res = 4'b0010; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
42 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0100; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
43 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0100; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
44 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0100; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
45 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
46 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
47 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
48 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
49 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
50 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
51 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
52 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
53 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
54 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
55 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
56 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0011; pll_res = 4'b0100; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
57 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
58 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
59 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
60 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
61 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
62 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
63 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
64 : if (BANDWIDTH === "HIGH" || BANDWIDTH === "OPTIMIZED") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
 else if (BANDWIDTH === "LOW") begin pll_cp = 4'b0010; pll_res = 4'b1000; end
    endcase
*/

  case (clkfb_div_fint)
     1 :  begin drp_lock_ref_dly = 5'b00110;
           drp_lock_fb_dly = 5'b00110;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     2 :  begin drp_lock_ref_dly = 5'b00110;
           drp_lock_fb_dly = 5'b00110;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     3 :  begin drp_lock_ref_dly = 5'b01000;
           drp_lock_fb_dly = 5'b01000;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     4 :  begin drp_lock_ref_dly = 5'b01011;
           drp_lock_fb_dly = 5'b01011;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     5 :  begin drp_lock_ref_dly = 5'b01110;
           drp_lock_fb_dly = 5'b01110;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     6 :  begin drp_lock_ref_dly = 5'b10001;
           drp_lock_fb_dly = 5'b10001;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     7 :  begin drp_lock_ref_dly = 5'b10011;
           drp_lock_fb_dly = 5'b10011;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     8 :  begin drp_lock_ref_dly = 5'b10110;
           drp_lock_fb_dly = 5'b10110;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     9 :  begin drp_lock_ref_dly = 5'b11001;
           drp_lock_fb_dly = 5'b11001;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     10 :  begin drp_lock_ref_dly = 5'b11100;
           drp_lock_fb_dly = 5'b11100;
           drp_lock_cnt = 10'b1111101000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     11 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b1110000100;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     12 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b1100111001;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     13 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b1011101110;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     14 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b1010111100;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     15 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b1010001010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     16 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b1001110001;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     17 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b1000111111;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     18 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b1000100110;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     19 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b1000001101;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     20 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0111110100;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     21 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0111011011;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     22 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0111000010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     23 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0110101001;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     24 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0110010000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     25 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0110010000;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     26 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0101110111;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     27 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0101011110;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     28 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0101011110;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     29 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0101000101;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     30 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0101000101;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     31 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0100101100;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     32 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0100101100;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     33 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0100101100;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     34 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0100010011;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     35 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0100010011;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     36 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0100010011;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     37 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     38 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     39 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     40 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     41 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     42 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     43 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     44 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     45 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     46 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     47 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     48 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     49 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     50 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     51 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     52 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     53 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     54 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     55 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     56 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     57 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     58 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     59 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     60 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     61 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     62 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     63 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
     64 :  begin drp_lock_ref_dly = 5'b11111;
           drp_lock_fb_dly = 5'b11111;
           drp_lock_cnt = 10'b0011111010;
           drp_lock_sat_high = 10'b1111101001;
           drp_unlock_cnt = 10'b0000000001; end
    endcase

    tmp_string = "DIVCLK_DIVIDE";
    chk_ok = para_int_range_chk (DIVCLK_DIVIDE, tmp_string, D_MIN, D_MAX);
    if(clkfb_frac_en == 0) begin
      tmp_string = "CLKFBOUT_MULT_F";
      chk_ok = para_real_range_chk (CLKFBOUT_MULT_F, tmp_string, M_MIN, M_MAX);
      tmp_string = "CLKOUT6_DUTY_CYCLE";
      chk_ok = clkout_duty_chk (CLKOUT6_DIVIDE, CLKOUT6_DUTY_CYCLE, tmp_string);
    end
    if(clk0_frac_en == 0) begin
      tmp_string = "CLKOUT0_DUTY_CYCLE";
      chk_ok = clkout_duty_chk (CLKOUT0_DIVIDE_F, CLKOUT0_DUTY_CYCLE, tmp_string);
      tmp_string = "CLKOUT5_DUTY_CYCLE";
      chk_ok = clkout_duty_chk (CLKOUT5_DIVIDE, CLKOUT5_DUTY_CYCLE, tmp_string);
    end
    tmp_string = "CLKOUT1_DUTY_CYCLE";
    chk_ok = clkout_duty_chk (CLKOUT1_DIVIDE, CLKOUT1_DUTY_CYCLE, tmp_string);
    tmp_string = "CLKOUT2_DUTY_CYCLE";
    chk_ok = clkout_duty_chk (CLKOUT2_DIVIDE, CLKOUT2_DUTY_CYCLE, tmp_string);
    tmp_string = "CLKOUT3_DUTY_CYCLE";
    chk_ok = clkout_duty_chk (CLKOUT3_DIVIDE, CLKOUT3_DUTY_CYCLE, tmp_string);
    tmp_string = "CLKOUT4_DUTY_CYCLE";
    chk_ok = clkout_duty_chk (CLKOUT4_DIVIDE, CLKOUT4_DUTY_CYCLE, tmp_string);
    period_vco_max = 1000000 / VCOCLK_FREQ_MIN;
    period_vco_min = 1000000 / VCOCLK_FREQ_MAX;
    period_vco_target = 1000000 / VCOCLK_FREQ_TARGET;
    period_vco_target_half = period_vco_target / 2;
    fb_delay_max = MAX_FEEDBACK_DELAY * MAX_FEEDBACK_DELAY_SCALE;
    clk0f_product = CLKOUT0_DIVIDE_F * 8;
    pll_lock_time = 12;
    lock_period_time = 10;
    if (clkfb_frac_en == 1) begin
      md_product = clkfb_div_fint * DIVCLK_DIVIDE;
      m_product = clkfb_div_fint;
      mf_product = CLKFBOUT_MULT_F * 8;
      clkout_en_val = mf_product - 2;
      m_product2 = clkfb_div_fint / 2;
      clkout_en_time = mf_product + 4 + pll_lock_time;
      locked_en_time = md_product +  clkout_en_time + 2;
      lock_cnt_max = locked_en_time + 16;
    end
    else begin
      md_product = clkfb_div_fint * DIVCLK_DIVIDE;
      m_product = clkfb_div_fint;
      mf_product = CLKFBOUT_MULT_F * 8;
      m_product2 = clkfb_div_fint / 2;
      clkout_en_val = m_product;
      clkout_en_time = md_product + pll_lock_time; 
      locked_en_time = md_product +  clkout_en_time + 2;  
      lock_cnt_max = locked_en_time + 16;
    end
    clkfb_stop_max = 3;
    clkin_stop_max = DIVCLK_DIVIDE + 1;
    REF_CLK_JITTER_MAX_tmp = REF_CLK_JITTER_MAX;
    clk_out_para_cal (clk1_ht, clk1_lt, clk1_nocnt, clk1_edge, CLKOUT1_DIVIDE, CLKOUT1_DUTY_CYCLE);
    clk_out_para_cal (clk2_ht, clk2_lt, clk2_nocnt, clk2_edge, CLKOUT2_DIVIDE, CLKOUT2_DUTY_CYCLE);
    clk_out_para_cal (clk3_ht, clk3_lt, clk3_nocnt, clk3_edge, CLKOUT3_DIVIDE, CLKOUT3_DUTY_CYCLE);
    clk_out_para_cal (clk4_ht, clk4_lt, clk4_nocnt, clk4_edge, CLKOUT4_DIVIDE, CLKOUT4_DUTY_CYCLE);
    clk_out_para_cal (clkind_ht, clkind_lt, clkind_nocnt, clkind_edge, DIVCLK_DIVIDE, 0.50);
    tmp_string = "CLKOUT1_PHASE";
    clkout_dly_cal (clkout1_dly, clk1pm_sel, CLKOUT1_DIVIDE, CLKOUT1_PHASE, tmp_string);
    tmp_string = "CLKOUT2_PHASE";
    clkout_dly_cal (clkout2_dly, clk2pm_sel, CLKOUT2_DIVIDE, CLKOUT2_PHASE, tmp_string);
    tmp_string = "CLKOUT3_PHASE";
    clkout_dly_cal (clkout3_dly, clk3pm_sel, CLKOUT3_DIVIDE, CLKOUT3_PHASE, tmp_string);
    tmp_string = "CLKOUT4_PHASE";
    clkout_dly_cal (clkout4_dly, clk4pm_sel, CLKOUT4_DIVIDE, CLKOUT4_PHASE, tmp_string);
    if (clkfb_frac_en == 1) begin
      clkfbm1_dly = clkfb_div_fint /2;
      clkout6_dly = clkfb_div_fint /2;
      if (clkfb_div_fint_odd > 0) begin
        clk6pm_sel = (8 + clkfb_div_frac_int) / 2;
        clkfbm1pm_sel = 8 + clkfb_div_frac_int - (8 + clkfb_div_frac_int) / 2 ;     
        clkfbm1pm_sel_int = 8 + clkfb_div_frac_int - (8 + clkfb_div_frac_int) / 2 ;
      end
      else begin
         clkfbm1pm_sel = clkfb_div_frac_int - clkfb_div_frac_int / 2;
         clkfbm1pm_sel_int = clkfb_div_frac_int - clkfb_div_frac_int / 2;
         clk6pm_sel = clkfb_div_frac_int / 2;
      end
    end
    else begin
      tmp_string = "CLKOUT6_PHASE";
      clkout_dly_cal (clkout6_dly, clk6pm_sel, CLKOUT6_DIVIDE, CLKOUT6_PHASE, tmp_string);
      tmp_string = "CLKFBOUT_PHASE";
      clkout_dly_cal (clkfbm1_dly, clkfbm1pm_sel, clkfb_div_fint, CLKFBOUT_PHASE, tmp_string);
    end
    if (clk0_frac_en == 1) begin
      clkout0_dly = clk0_div_fint /2;
      clkout5_dly = clk0_div_fint /2;
      if (clk0_div_fint_odd > 0) begin
        clk5pm_sel = (8 + clk0_div_frac_int) / 2;     
        clk0pm_sel = 8 + clk0_div_frac_int - (8 + clk0_div_frac_int) / 2;     
        clk0pm_sel_int = 8 + clk0_div_frac_int - (8 + clk0_div_frac_int) / 2;
      end
      else begin
         clk0pm_sel = clk0_div_frac_int - clk0_div_frac_int / 2;
         clk0pm_sel_int = clk0_div_frac_int - clk0_div_frac_int / 2;
         clk5pm_sel = clk0_div_frac_int / 2;
      end
    end
    else begin
      tmp_string = "CLKOUT0_PHASE";
      clkout_dly_cal (clkout0_dly, clk0pm_sel, clk0_div_fint, CLKOUT0_PHASE, tmp_string);
      tmp_string = "CLKOUT5_PHASE";
      clkout_dly_cal (clkout5_dly, clk5pm_sel, CLKOUT5_DIVIDE, CLKOUT5_PHASE, tmp_string);
    end
    if (clk0_frac_en == 1) begin
    end
    else begin
      clk_out_para_cal (clk0_ht, clk0_lt, clk0_nocnt, clk0_edge, clk0_div_fint, CLKOUT0_DUTY_CYCLE);
      clk_out_para_cal (clk5_ht, clk5_lt, clk5_nocnt, clk5_edge, CLKOUT5_DIVIDE, CLKOUT5_DUTY_CYCLE);
    end
    if (clkfb_frac_en == 1) begin
    end
    else begin
      clk_out_para_cal (clkfbm1_ht, clkfbm1_lt, clkfbm1_nocnt, clkfbm1_edge, clkfb_div_fint, 0.50);
      clk_out_para_cal (clk6_ht, clk6_lt, clk6_nocnt, clk6_edge, CLKOUT6_DIVIDE, CLKOUT6_DUTY_CYCLE);
    end
    clk_out_para_cal (clkfbm2_ht, clkfbm2_lt, clkfbm2_nocnt, clkfbm2_edge, 1, 0.50);
    clkind_div = DIVCLK_DIVIDE;

    dr_sram[6] = {clk5pm_sel[2:0], 1'b1, clk5_ht[5:0], clk5_lt[5:0]};
    dr_sram[7] = {5'bx, 3'b0, clk5_edge, clk5_nocnt, clkout5_dly[5:0]};
    dr_sram[8] = {clk0pm_sel[2:0], 1'b1, clk0_ht[5:0], clk0_lt[5:0]};
    dr_sram[9] = {8'b0, clk0_edge, clk0_nocnt, clkout0_dly[5:0]};
    dr_sram[10] = {clk1pm_sel[2:0], 1'b1, clk1_ht[5:0], clk1_lt[5:0]};
    dr_sram[11] = {6'bx, 2'b0, clk1_edge, clk1_nocnt, clkout1_dly[5:0]};
    dr_sram[12] = {clk2pm_sel[2:0], 1'b1, clk2_ht[5:0], clk2_lt[5:0]};
    dr_sram[13] = {6'bx, 2'b0, clk2_edge, clk2_nocnt, clkout2_dly[5:0]};
    dr_sram[14] = {clk3pm_sel[2:0], 1'b1, clk3_ht[5:0], clk3_lt[5:0]};
    dr_sram[15] = {6'bx, 2'b0, clk3_edge, clk3_nocnt, clkout3_dly[5:0]};
    dr_sram[16] = {clk4pm_sel[2:0], 1'b1, clk4_ht[5:0], clk4_lt[5:0]};
    dr_sram[17] = {5'bx, 3'b0, clk4_edge, clk4_nocnt, clkout4_dly[5:0]};
    dr_sram[18] = {clk6pm_sel[2:0], 1'b1, clk6_ht[5:0], clk6_lt[5:0]};
    dr_sram[19] = {6'bx, 2'b0, clk6_edge, clk6_nocnt, clkout6_dly[5:0]};
    dr_sram[20] = {clkfbm1pm_sel[2:0], 1'b1, clkfbm1_ht[5:0], clkfbm1_lt[5:0]};
    dr_sram[21] = {1'bx, 7'b0, clkfbm1_edge, clkfbm1_nocnt, clkfbm1_dly[5:0]};
    dr_sram[22] = {2'bx, clkind_edge, clkind_nocnt, clkind_ht[5:0], clkind_lt[5:0]};
    dr_sram[24] = {6'bx, drp_lock_cnt};
    dr_sram[25] = {1'bx, drp_lock_fb_dly, drp_unlock_cnt};
    dr_sram[26] = {1'bx, drp_lock_ref_dly, drp_lock_sat_high};
    dr_sram[40] = {1'b1, 2'bx, 2'b11, 2'bx, 2'b11, 2'bx, 2'b11, 2'bx, 1'b1};
    dr_sram[78] = {pll_cp[3], 2'bx, pll_cp[2:1], 2'bx, pll_cp[0], 1'b0, 2'bx, pll_cpres, 3'bx};
    dr_sram[79] = {pll_res[3], 2'bx, pll_res[2:1], 2'bx, pll_res[0], pll_lfhf[1], 2'bx, pll_lfhf[0], 4'bx};
    dr_sram[116] = {5'bx, 6'b0, 5'b00001};
  end

  initial begin
    clkpll_jitter_unlock = 0;
    clkinstopped_vco_f = 0;
    rst_clkfbstopped = 0;
    rst_clkinstopped  = 0;
    rst_clkfbstopped_lk = 0;
    rst_clkinstopped_lk  = 0;
    clkfb_stop_tmp = 0;
    clkin_stop_tmp = 0;
    clkout_ps = 0;
    clkout_ps_tmp1 = 0;
    clkout_ps_tmp2 = 0;
    clkvco_ps_tmp1 = 0;
    clkvco_ps_tmp2 = 0;
    clkvco_ps_tmp2_en = 0;
    clkvco_lk_osc = 0;
    clkvco_lk_en = 0;
    clkvco_lk_tmp = 0;
    clkvco_lk_dly_tmp = 0;
    clk_osc = 0;
    clkin_p = 0;
    clkfb_p = 0;
    clkind_edgei = 0;
    clkind_nocnti = 0;
    clkind_hti = 0;
    clkind_lti = 0;
    clkind_divi = 1;
    drp_lock1 = 0;
    ps_lock = 0;
    ps_lock_dly = 0;
    psdone_out = 0;
    psdone_out1 = 0;
    rst_in = 0;
    clkinstopped_out = 0;
    clkfbstopped_out = 0;
    clkin_period[0] = 0;
    clkin_period[1] = 0;
    clkin_period[2] = 0;
    clkin_period[3] = 0;
    clkin_period[4] = 0;
    clkin_period_tmp_t = 0;
    period_avg = 0;
    period_fb = 0;
    clkin_lost_val = 500;
    clkfb_lost_val = 500;
    clkin_lost_val_lk = 500;
    fb_delay = 0;
    clkfbm1_div = 1;
    clkfbm2_div = 1;
    clkfbm1_div1 = 0;
    clkfbm2_div1 = 0;
    clkvco_delay = 0;
    val_tmp = 0;
    dly_tmp = 0;
    fbm1_comp_delay = 0;
    clkfbm1pm_rl = 0;
    period_vco = 0;
    period_vco1 = 0;
    period_vco2 = 0;
    period_vco3 = 0;
    period_vco4 = 0;
    period_vco5 = 0;
    period_vco6 = 0;
    period_vco7 = 0;
    period_vco_half = 0;
    period_vco_half1 = 0;
    period_vco_half_rm = 0;
    period_vco_half_rm1 = 0;
    period_vco_half_rm2 = 0;
    period_vco_rm = 0;
    period_vco_cmp_cnt = 0;
    period_vco_cmp_flag = 0;
    period_ps = 0;
    period_ps_old = 0;
    clkfb_frac_ht = 0;
    clkfb_frac_lt = 0;
    clk0_frac_ht = 0;
    clk0_frac_lt = 0;
    clkvco_rm_cnt = 0;
    fb_delay_found = 0;
    fb_delay_found_tmp = 0;
    clkin_edge = 0;
    delay_edge = 0;
    fbclk_tmp = 0;
    clkfb_tst = 0;
    clkout_en = 0;
    clkout_en0 = 0;
    clkout_en_t = 0;
    clkout_en0_tmp = 0;
    clkout_en1 = 0;
    pll_locked_tmp1  = 0;
    pll_locked_tmp2  = 0;
    pll_locked_tm = 0;
    pll_locked_delay = 0;
    clkout_mux = 8'b0;
    clkout_ps_mux = 8'b0;
    unlock_recover = 0;
    clkin_jit = 0;
    clkin_lock_cnt = 0;
    lock_period = 0;
    rst_edge = 0;
    rst_ht = 0;
    drdy_out = 0;
    drdy_out1 = 0;
    locked_out1 = 0;
    locked_out_tmp = 0;
    do_out1 = 16'b0;
    drp_lock = 0;
    clkout0_out = 0;
    clk0_dly_cnt = 6'b0;
    clk1_dly_cnt = 6'b0;
    clk2_dly_cnt = 6'b0;
    clk3_dly_cnt = 6'b0;
    clk4_dly_cnt = 6'b0;
    clk5_dly_cnt = 6'b0;
    clk6_dly_cnt = 6'b0;
    clkfbm1_dly_cnt = 6'b0;
    clk0_cnt = 8'b0;
    clk1_cnt = 8'b0;
    clk2_cnt = 8'b0;
    clk3_cnt = 8'b0;
    clk4_cnt = 8'b0;
    clk5_cnt = 8'b0;
    clk6_cnt = 8'b0;
    clkfbm1_cnt = 8'b0;
    clkfbm2_cnt = 8'b0;
    clkind_cnt = 8'b0;
    clkout0_out = 0;
    clkout1_out = 0;
    clkout2_out = 0;
    clkout3_out = 0;
    clkout4_out = 0;
    clkout5_out = 0;
    clkout6_out = 0;
    clk0_nf_out = 0;
    clk0_frac_out = 0;
    clk1_out = 0;
    clk2_out = 0;
    clk3_out = 0;
    clk4_out = 0;
    clk5_out = 0;
    clk6_out = 0;
    clkfb_out = 0;
    clkfbm1_nf_out = 0;
    clkfbm1_frac_out = 0;
    clkfbm2_out = 0;
    clkfbm2_out_tmp = 0;
    clkind_out = 0;
    clkind_out_tmp = 0;
    clk_osc = 0;
    clkin_p = 0;
    clkfb_p = 0;
    pwron_int = 1;
    #100000 pwron_int = 0;
  end

  assign CLKOUT6 =  clkout6_out;
  assign CLKOUT5 =  clkout5_out;
  assign CLKOUT4 =  clkout4_out;
  assign CLKOUT3 =  clkout3_out;
  assign CLKOUT2 =  clkout2_out;
  assign CLKOUT1 =  clkout1_out;
  assign CLKOUT0 =  clkout0_out;
  assign CLKFBOUT = clkfb_out;
  assign CLKOUT3B =  ~clkout3_out;
  assign CLKOUT2B =  ~clkout2_out;
  assign CLKOUT1B =  ~clkout1_out;
  assign CLKOUT0B =  ~clkout0_out;
  assign CLKFBOUTB = ~clkfb_out;

  assign #1 clkinsel_tmp = clkinsel_in;

  assign  glock = (startup_wait_sig) ? locked_out_tmp : 1;
  assign (weak1, strong0) glbl.PLL_LOCKG = (glock == 0) ? 0 : p_up;

  initial begin
    init_chk = 0;
    #1;
    init_chk = 1;
  end

  always @(clkinsel_in or posedge init_chk ) begin
  if ($time > 1 && rst_in === 0 && (clkinsel_tmp === 0 || clkinsel_tmp === 1)) begin
      $display("Input Error : Input clock can only be switched when RST=1. CLKINSEL on MMCM_ADV instance %m at time %t changed when RST low, which should change at RST high.", $time);
      $finish;
  end
   if (SIM_DEVICE == "VIRTEX6") begin
    clkin_chk_t1 = 1000.0 / CLKIN_FREQ_MIN;
    clkin_chk_t2 = 1000.0 / CLKIN_FREQ_MAX;
   end
   else begin
    clkin_chk_t1 = 100.0;
    clkin_chk_t2 = 0.938;
   end

    if (clkinsel_in === 1 && $time > 1 || clkinsel_in !== 0 && init_chk == 1) begin
      if (CLKIN1_PERIOD > clkin_chk_t1 || CLKIN1_PERIOD < clkin_chk_t2) begin
        $display (" Attribute Syntax Error : The attribute CLKIN1_PERIOD is set to %f ns and out the allowed range %f ns to %f ns.", CLKIN1_PERIOD, clkin_chk_t2, clkin_chk_t1);

        $finish;
      end
    end 
    else if (clkinsel_in ===0 && $time > 1 || init_chk == 1 && clkinsel_tmp === 0 ) begin
      if (CLKIN2_PERIOD > clkin_chk_t1 || CLKIN2_PERIOD < clkin_chk_t2) begin
        $display (" Attribute Syntax Error : The attribute CLKIN2_PERIOD is set to %f ns and out the allowed range %f ns to %f ns.", CLKIN2_PERIOD, clkin_chk_t2, clkin_chk_t1);
        $finish;
      end
    end
    period_clkin =  (clkinsel_in === 0) ? CLKIN2_PERIOD : CLKIN1_PERIOD;
    clkvco_freq_init_chk =  (1000.0 * CLKFBOUT_MULT_F) / (period_clkin * DIVCLK_DIVIDE);
    if (clkvco_freq_init_chk > VCOCLK_FREQ_MAX || clkvco_freq_init_chk < VCOCLK_FREQ_MIN) begin
     if (clkinsel_tmp === 0 && $time > 1 || clkinsel_tmp === 0 && init_chk === 1) begin
      $display (" Attribute Syntax Error : The calculation of VCO frequency=%f Mhz. This exceeds the permitted VCO frequency range of %f Mhz to %f Mhz. The VCO frequency is calculated with formula: VCO frequency =  CLKFBOUT_MULT_F / (DIVCLK_DIVIDE * CLKIN2_PERIOD). Please adjust the attributes to the permitted VCO frequency range.", clkvco_freq_init_chk, VCOCLK_FREQ_MIN, VCOCLK_FREQ_MAX);
      $finish;
    end
    else if (clkinsel_tmp === 1 && $time > 1 || clkinsel_tmp !== 0 && init_chk === 1) begin
      $display (" Attribute Syntax Error : The calculation of VCO frequency=%f Mhz. This exceeds the permitted VCO frequency range of %f Mhz to %f Mhz. The VCO frequency is calculated with formula: VCO frequency =  CLKFBOUT_MULT_F / (DIVCLK_DIVIDE * CLKIN1_PERIOD). Please adjust the attributes to the permitted VCO frequency range.", clkvco_freq_init_chk, VCOCLK_FREQ_MIN, VCOCLK_FREQ_MAX);
      $finish;
    end
   end
  end

  assign  init_trig = 1;
  assign clkpll_r = (clkinsel_in) ? clkin1_in : clkin2_in;
  assign pwrdwn_in1 =  (pwrdwn_in === 1) ? 1 : 0; 
  assign rst_input  =  rst_input_r | pwrdwn_in1; 

  always @(posedge clkpll_r or posedge rst_input)
    if (rst_input)
       rst_in <= 1;
    else
       rst_in <= rst_input ;

  assign rst_in_o = (rst_in || rst_clkfbstopped || rst_clkinstopped);


  //
  // DRP port read and write
  //

  assign do_out = dr_sram[daddr_lat];

  always @(posedge dclk_in or posedge GSR)
    if (GSR == 1) begin
       drp_lock <= 0;
    end
    else begin
      if (den_in == 1) begin
        valid_daddr = addr_is_valid(daddr_in);
        if (drp_lock == 1) begin
          $display(" Warning : DEN is high at MMCM_ADV instance %m at time %t. Need wait for DRDY signal before next read/write operation through DRP. ", $time);
        end
        else begin
          drp_lock <= 1;
          daddr_lat <= daddr_in;
        end
        if (valid_daddr && ( daddr_in == 7'b1110100 || daddr_in == 7'b1001111 ||
          daddr_in == 7'b1001110 || daddr_in == 7'b0101000 || 
          (daddr_in >= 7'b0011000 && daddr_in <= 7'b0011010) ||
          (daddr_in >= 7'b0000110 && daddr_in <= 7'b0010110))) begin
        end
        else begin
          $display(" Warning : Address DADDR=%b is unsupported at MMCM_ADV instance %m at time %t.  ",  DADDR, $time);
        end

        if (dwe_in == 1) begin          // write process
          if (rst_input == 1) begin
            if (valid_daddr && ( daddr_in == 7'b1110100 || daddr_in == 7'b1001111 ||
          daddr_in == 7'b1001110 || daddr_in == 7'b0101000 || 
          (daddr_in >= 7'b0011000 && daddr_in <= 7'b0011010) ||
          (daddr_in >= 7'b0000110 && daddr_in <= 7'b0010110))) begin
                  dr_sram[daddr_in] <= di_in;
             end
             if (daddr_in == 7'b0001001) 
               clkout_delay_para_drp (clkout0_dly, clk0_nocnt, clk0_edge, di_in, daddr_in);
             if (daddr_in == 7'b0001000)
               clkout_hl_para_drp (clk0_lt, clk0_ht, clk0pm_sel, di_in, daddr_in);
             if (daddr_in == 7'b0001011) 
               clkout_delay_para_drp (clkout1_dly, clk1_nocnt, clk1_edge, di_in, daddr_in);
             if (daddr_in == 7'b0001010)
               clkout_hl_para_drp (clk1_lt, clk1_ht, clk1pm_sel, di_in, daddr_in);
             if (daddr_in == 7'b0001101) 
               clkout_delay_para_drp (clkout2_dly, clk2_nocnt, clk2_edge, di_in, daddr_in);
             if (daddr_in == 7'b0001100)
               clkout_hl_para_drp (clk2_lt, clk2_ht, clk2pm_sel, di_in, daddr_in);
             if (daddr_in == 7'b0001111)
               clkout_delay_para_drp (clkout3_dly, clk3_nocnt, clk3_edge, di_in, daddr_in);
             if (daddr_in == 7'b0001110)
               clkout_hl_para_drp (clk3_lt, clk3_ht, clk3pm_sel, di_in, daddr_in);
             if (daddr_in == 7'b0010001) 
               clkout_delay_para_drp (clkout4_dly, clk4_nocnt, clk4_edge, di_in, daddr_in);
             if (daddr_in == 7'b0010000)
               clkout_hl_para_drp (clk4_lt, clk4_ht, clk4pm_sel, di_in, daddr_in);
             if (daddr_in == 7'b0010011) 
               clkout_delay_para_drp (clkout6_dly, clk6_nocnt, clk6_edge, di_in, daddr_in);
             if (daddr_in == 7'b0010010)
               clkout_hl_para_drp (clk6_lt, clk6_ht, clk6pm_sel, di_in, daddr_in);
             if (daddr_in == 7'b0000111) 
               clkout_delay_para_drp (clkout5_dly, clk5_nocnt, clk5_edge, di_in, daddr_in);
             if (daddr_in == 7'b0000110)
               clkout_hl_para_drp (clk5_lt, clk5_ht, clk5pm_sel, di_in, daddr_in);
             if (daddr_in == 7'b0010101) begin 
               clkout_delay_para_drp (clkfbm1_dly, clkfbm1_nocnt, clkfbm1_edge, di_in, daddr_in);
               clkfbtmp_nocnti = di_in[12];
             end
             if (daddr_in == 7'b0010100) begin
               clkout_hl_para_drp (clkfbm1_lt, clkfbm1_ht, clkfbm1pm_sel, di_in, daddr_in);
               clkfbtmp_lti = {2'b00, di_in[5:0]};
               clkfbtmp_hti = {2'b00, di_in[11:6]};
               if (clkfbtmp_nocnti == 1)
                      clkfbtmp_divi = 8'b00000001;
               else if (di_in[5:0] == 6'b0 && di_in[11:6] == 6'b0)
                      clkfbtmp_divi = 8'b10000000;
               else if (di_in[5:0] == 6'b0)
                      clkfbtmp_divi = 64 + clkfbtmp_hti;
               else if (di_in[11:6] == 6'b0)
                      clkfbtmp_divi = 64 + clkfbtmp_lti;
               else
                      clkfbtmp_divi = clkfbtmp_hti + clkfbtmp_lti;
               if (SIM_DEVICE == "VIRTEX6") begin
                 if (clkfbtmp_divi > 64 || (clkfbtmp_divi < 5))
                  $display(" Input Error : DI at Address DADDR=%b is %h at MMCM_ADV instance %m at time %t. The sum of DI[11:6] and DI[5:0] is %b and over the range of %d to %d.",  daddr_in, di_in, clkfbtmp_divi, $time, 5, 64);
               end
               else begin
                 if (clkfbtmp_divi > 64 || (clkfbtmp_divi < 2))
                  $display(" Input Error : DI at Address DADDR=%b is %h at MMCM_ADV instance %m at time %t. The sum of DI[11:6] and DI[5:0] is %d and over the range of %d to %d.",  daddr_in, di_in, clkfbtmp_divi, $time, 2, 64);
               end
            end

             if (daddr_in == 7'b0010110) begin
               clkind_lti = {2'b00, di_in[5:0]};
               clkind_hti = {2'b00, di_in[11:6]};
               clkind_lt <= clkind_lti;
               clkind_ht <= clkind_hti;
               clkind_nocnt <= di_in[12];
               clkind_nocnti = di_in[12];
               clkind_edgei = di_in[13];
               clkind_edge <= di_in[13];
               if (di_in[12] == 1)
                      clkind_divi = 8'b00000001;
               else if (di_in[5:0] == 6'b0 && di_in[11:6] == 6'b0)
                      clkind_divi = 8'b10000000;
               else if (di_in[5:0] == 6'b0)
                      clkind_divi = 64 + clkind_hti;
               else if (di_in[11:6] == 6'b0)
                      clkind_divi = 64 + clkind_lti;
               else
                      clkind_divi = clkind_hti + clkind_lti;

               clkind_div <= clkind_divi;
               if (clkind_divi > D_MAX || (clkind_divi < 1 && clkind_nocnti == 0))
                  $display(" Input Error : DI at Address DADDR=%b is %h at MMCM_ADV instance %m at time %t. The sum of DI[11:6] and DI[5:0] is %d and over the range of 1 to %d.",  daddr_in, di_in, clkind_divi, $time, D_MAX);
            end
          end
          else begin
                  $display(" Error : RST is low at MMCM_ADV instance %m at time %t. RST need to be high when change MMCM_ADV paramters through DRP. ", $time);
          end
        end //DWE
    end  //DEN
    if ( drp_lock == 1) begin
          drp_lock <= 0;
          drp_lock1 <= 1;
    end
    if (drp_lock1 == 1) begin
         drp_lock1 <= 0;
         drdy_out <= 1;
    end 
    if (drdy_out == 1)
        drdy_out <= 0;
  end

  function addr_is_valid;
  input [6:0] daddr_funcin;
  begin
    addr_is_valid = 1;
    for (i=0; i<=6; i=i+1)
      if ( daddr_funcin[i] != 0 && daddr_funcin[i] != 1)
         addr_is_valid = 0;
  end
  endfunction

  // end process drp;

  //
  // determine clock period
  //

  always @(posedge clkpll_r or posedge rst_in or posedge rst_clkinsel_flag)
    if (rst_in || rst_clkinsel_flag)
    begin
      clkin_period[0] <= period_vco_target;
      clkin_period[1] <= period_vco_target;
      clkin_period[2] <= period_vco_target;
      clkin_period[3] <= period_vco_target;
      clkin_period[4] <= period_vco_target;
      clkin_jit <= 0;
      clkin_lock_cnt <= 0;
      pll_locked_tm <= 0;
      lock_period <= 0;
      pll_locked_tmp1 <= 0;
      clkout_en0_tmp <= 0;
      unlock_recover <= 0;
      clkin_edge <= 0;
    end
    else begin
      clkin_edge <= $time;
      clkin_period[4] <= clkin_period[3];
      clkin_period[3] <= clkin_period[2];
      clkin_period[2] <= clkin_period[1];
      clkin_period[1] <= clkin_period[0];
      if (clkin_edge != 0 && clkinstopped_out == 0 && rst_clkinsel_flag == 0) begin 
         clkin_period[0] <= $time - clkin_edge;
      end
         
      if (pll_unlock == 0)
         clkin_jit <=  $time - clkin_edge - clkin_period[0];
      else
         clkin_jit <= 0;
      if ( (clkin_lock_cnt < lock_cnt_max) && fb_delay_found && pll_unlock1 == 0)
         clkin_lock_cnt <= clkin_lock_cnt + 1;
      else if (pll_unlock1 == 1 && pll_locked_tmp1 ==1 ) begin
         clkin_lock_cnt <= lock_cnt_max - 6;
         unlock_recover <= 1;
      end
      if ( clkin_lock_cnt >= pll_lock_time && pll_unlock1 == 0)
         pll_locked_tm <= 1;
      if ( clkin_lock_cnt == lock_period_time )
         lock_period <= 1;
      if (clkin_lock_cnt >= clkout_en_time && pll_locked_tm == 1) begin
         clkout_en0_tmp <= 1;
      end
      if (clkin_lock_cnt >= locked_en_time && clkout_en == 1)
         pll_locked_tmp1 <= 1;
      if (unlock_recover ==1 && clkin_lock_cnt  >= lock_cnt_max)
         unlock_recover <= 0;
    end

  always @(m_product or mf_product or clkfb_frac_en)
    if (clkfb_frac_en == 0)
      clkout_en_val = m_product;
    else 
      clkout_en_val = mf_product - 2;

  always @(clkout_en0_tmp)
    clkout_en0_tmp1 <= #1 clkout_en0_tmp;

  always @(clkout_en0_tmp1 or clkout_en_t or clkout_en0_tmp )
    if (clkout_en0_tmp==0 )
      clkout_en0 = 0;
    else begin
     if (clkfb_frac_en == 1) begin 
       if (clkout_en_t > clkout_en_val && clkout_en0_tmp1 == 1)
          clkout_en0 <= #period_vco6 clkout_en0_tmp1;
     end
     else begin
       if (clkout_en_t == clkout_en_val && clkout_en0_tmp1 == 1)
          clkout_en0 <= #period_vco6 clkout_en0_tmp1;
     end 
   end

  always @(clkout_en0 )
    clkout_en1 <= #(clkvco_delay) clkout_en0;

  always @(clkout_en1 or rst_in_o )
  if (rst_in_o)
    clkout_en = 0;
  else
    clkout_en =  clkout_en1;

  always @(pll_locked_tmp1 )
    if (pll_locked_tmp1==0)
      pll_locked_tmp2 =  pll_locked_tmp1;
    else begin
      pll_locked_tmp2 <= #pll_locked_delay  pll_locked_tmp1;
    end

  always @(rst_in)
    if (rst_in) begin
      assign pll_locked_tmp2 = 0;
      assign clkout_en0 = 0;
      assign clkout_en1 = 0;
    end
    else begin
      deassign pll_locked_tmp2;
      deassign clkout_en0;
      deassign clkout_en1;
    end
    
  assign locked_out = (pll_locked_tm && pll_locked_tmp2 && ~pll_unlock && !unlock_recover) ? 1 : 0;

  always @(rst_in or locked_out)
     if (rst_in == 1) 
           locked_out_tmp <=  0;
     else
        locked_out_tmp <= locked_out;

  always @(clkin_period[0] or clkin_period[1] or clkin_period[2] or 
           clkin_period[3] or clkin_period[4] or period_avg ) begin
    if (clkin_period[0] > clkin_period[1])
        clkin_period_tmp_t = clkin_period[0] - clkin_period[1];
    else
        clkin_period_tmp_t = clkin_period[1] - clkin_period[0];

    if ( (clkin_period[0] != period_avg) && (clkin_period[0] < 1.5 * period_avg || clkin_period_tmp_t <= 300) ) 
      period_avg = (clkin_period[0] + clkin_period[1] + clkin_period[2] 
                 + clkin_period[3] + clkin_period[4])/5;
  end

  assign  clkinstopped_hold = (clkin_hold_f == 1) ? clkinstopped_out : 0;

  always @(period_avg or lock_period or clkind_div) 
   if (period_avg > 500 && lock_period == 1)  begin
    clkin_lost_val = ((period_avg * 1.5) / 500) - 1;
    clkfb_lost_val = ((period_avg * 1.5 * clkind_div) / 500) - 1;
  end

  always @(clkfb_frac_en or clkfbm1_f_div or  clkfbm1_div)
    if (clkfb_frac_en)
        clkfbm1_div_t = clkfbm1_f_div;
    else
        clkfbm1_div_t = clkfbm1_div;

  always @(period_avg or clkind_div or clkfbm1_div_t or clkinstopped_hold or posedge rst_clkinstopped_rc) 
  if (period_avg > 0 ) begin
    md_product = clkind_div * clkfbm1_div_t;
    m_product = clkfbm1_div_t;
    m_product2 = clkfbm1_div_t / 2;
    period_fb = period_avg * clkind_div;
    period_vco_tmp = period_fb / clkfbm1_div_t;
    clkvco_pdrm =  (period_avg * clkind_div / clkfbm1_div_t) - period_vco_tmp;
    period_vco_mf = period_avg * 8;
    if (clkinstopped_hold == 1)
        period_vco = (20000 * period_vco_tmp) / (20000 - period_vco_tmp);
    else
        period_vco = period_vco_tmp;
    clkfbm1_div_t_int = $rtoi(clkfbm1_div_t);
    period_vco_rm = period_fb % clkfbm1_div_t_int;
    if (period_vco_rm > 1) begin
      if (period_vco_rm > m_product2)  begin
          period_vco_cmp_cnt = m_product / (m_product - period_vco_rm) - 1;
          period_vco_cmp_flag = 2;
      end
      else begin
         period_vco_cmp_cnt = (m_product / period_vco_rm) - 1; 
         period_vco_cmp_flag = 1;
      end
    end  
    else begin
      period_vco_cmp_cnt = 0;
      period_vco_cmp_flag = 0;
    end
    period_vco_half = period_vco /2;
    period_vco_half_rm = period_vco - period_vco_half;
    period_vco_half_rm1 = period_vco_half_rm + 1;
    period_vco_half_rm2 = period_vco_half_rm - 1;
    period_vco_half1 = period_vco - period_vco_half + 1;
    pll_locked_delay = period_fb * clkfbm1_div_t;
    clkin_dly_t =  period_avg * (clkind_div + 1.25);
    clkfb_dly_t = period_fb * 2.25 ;
    period_vco1 = period_vco / 8;
    period_vco2 = period_vco / 4;
    period_vco3 = period_vco * 3/ 8;
    period_vco4 = period_vco / 2;
    period_vco5 = period_vco * 5 / 8;
    period_vco6 = period_vco *3 / 4;
    period_vco7 = period_vco * 7 / 8;
    clk0_frac_ht = period_vco * clkout0_dly + (period_vco * clk0pm_sel_int) / 8;
    clk0_frac_lt = period_vco * clkout5_dly + (period_vco * clk5pm_sel) / 8;
    clkfb_frac_ht = period_vco * clkfbm1_dly + (period_vco * clkfbm1pm_sel_int) / 8;
    clkfb_frac_lt = period_vco * clkout6_dly + (period_vco * clk6pm_sel) / 8;
  end

  always @(period_vco or ps_in_ps) 
  if (fps_en == 1) begin
    period_ps_old = period_ps;
    if (ps_in_ps < 0)
      period_ps = period_vco + ps_in_ps * period_vco / 56.0;
    else if ((ps_in_ps == 0) && psincdec_in == 0)
      period_ps = period_vco;
    else
      period_ps = ps_in_ps * period_vco / 56.0;
  end
 

  always @( clkpll_r ) 
    clkpll_tmp1 <= #(period_avg) clkpll_r;

  always @(clkpll_tmp1) 
    clkpll <= #(period_avg) clkpll_tmp1;

  always @(posedge clkinstopped_out ) begin
      clkinstopped_vco_f <= 1;
    @(posedge clkpll);
    @(posedge clkpll)
      clkinstopped_vco_f <= 0;
   end
   
  always @(posedge clkinstopped_out or posedge rst_in) 
    if (rst_in)
      clkinstopped_out1 <= 0;
    else begin
     clkinstopped_out1 <= 1;
     @(posedge locked_out or posedge rst_in)
       clkinstopped_out1 <= 0;
    end

  always @(posedge clkfbstopped_out) begin
     clkfbstopped_out1 <= 1;
     @(posedge locked_out)
       clkfbstopped_out1 <= 0;
  end

  always @(clkout_en_t)
    if (clkout_en_t >= clkout_en_val -3 && clkout_en_t < clkout_en_val)
        rst_clkinstopped_tm = 1;
    else
        rst_clkinstopped_tm =  0;

  always @(negedge clkinstopped_out or posedge rst_in) 
    if (rst_in)
      rst_clkinstopped <= 0;
    else 
     if (rst_clkinstopped_lk == 0) begin
       @(posedge rst_clkinstopped_tm)
         rst_clkinstopped <= #period_vco3 1;
       @(negedge rst_clkinstopped_tm ) begin
         rst_clkinstopped <=  #period_vco5 0;
         rst_clkinstopped_rc <=  #period_vco6 1;
         rst_clkinstopped_rc <=  #period_vco7 0;
       end  
      end

  always @(posedge clkinstopped_out or posedge rst_in) 
    if (rst_in)
      clkinstopped_out_dly <= 0;
    else begin
       clkinstopped_out_dly <= 1;
       @(negedge rst_clkinstopped_rc or posedge rst_in)
         clkinstopped_out_dly <= 0;
    end

  always @(negedge rst_clkinstopped) begin
      rst_clkinstopped_lk <= 1;
      @(posedge locked_out)
        rst_clkinstopped_lk <= 0;
  end

  
  always @(clkinstopped_vco_f or  clkvco_lk or clkvco_lk_tmp or rst_in) 
   if (rst_in)
     clkvco_lk  = 0;
   else begin
    if (clkinstopped_vco_f == 1 && period_vco_half > 0) 
       clkvco_lk <= #(period_vco_half) !clkvco_lk;
    else 
      clkvco_lk  = clkvco_lk_tmp;
   end

  always @(posedge clkpll) 
    if (clkfb_frac_en == 1) begin
      if (pll_locked_tm ==1 ) begin
        clkvco_lk_tmp <= 1;
        cmpvco = 0.0;
          for (ik1=1; ik1 < mf_product; ik1=ik1+1) begin
               #(period_vco_half) clkvco_lk_tmp <= 0;
               if ( cmpvco >= 1.0 ) begin
                  #(period_vco_half_rm1) clkvco_lk_tmp <= 1;
                  cmpvco <= cmpvco - 1.0 + clkvco_pdrm;
               end
               else if ( cmpvco <= -1.0 ) begin
                  #(period_vco_half_rm2) clkvco_lk_tmp <= 1;
                  cmpvco <= cmpvco + 1.0 + clkvco_pdrm;
               end
               else begin
                  #(period_vco_half_rm) clkvco_lk_tmp <= 1;
                  cmpvco <= cmpvco + clkvco_pdrm;
               end
               clkout_en_t <= ik1;
          end
               clkout_en_t <= ik1;
          #(period_vco_half) clkvco_lk_tmp <= 0;
      end
    end
    else begin
      if (pll_locked_tm ==1) begin
        clkvco_lk_tmp <= 1;
        clkvco_rm_cnt = 0;
        clkout_en_t <= 0;
        if ( period_vco_cmp_flag == 1)  begin
          for (ik2=1; ik2 < m_product; ik2=ik2+1) begin
               clkout_en_t <= ik2;
               #(period_vco_half) clkvco_lk_tmp <= 0;
               if ( clkvco_rm_cnt == 1)
//                   #(period_vco_half1) clkvco_lk_tmp <= 1;
                   #(period_vco_half_rm1) clkvco_lk_tmp <= 1;
               else
                   #(period_vco_half_rm) clkvco_lk_tmp <= 1;

               if ( clkvco_rm_cnt == period_vco_cmp_cnt) 
                  clkvco_rm_cnt <= 0;
               else
                   clkvco_rm_cnt <= clkvco_rm_cnt + 1;
          end
               clkout_en_t <= ik2;
       end
       else if ( period_vco_cmp_flag == 2 ) begin
          for (ik3=1; ik3 < m_product; ik3=ik3+1) begin
               clkout_en_t <= ik3;
               #(period_vco_half) clkvco_lk_tmp <= 0;
               if ( clkvco_rm_cnt == 1)
                   #(period_vco_half_rm) clkvco_lk_tmp <= 1;
               else
                   #(period_vco_half_rm1) clkvco_lk_tmp <= 1;

               if ( clkvco_rm_cnt == period_vco_cmp_cnt)
                  clkvco_rm_cnt <= 0;
               else
                   clkvco_rm_cnt <= clkvco_rm_cnt + 1;
          end
               clkout_en_t <= ik3;
        end
       else begin
          for (ik4=1; ik4 < m_product; ik4=ik4+1) begin
               clkout_en_t <= ik4;
               #(period_vco_half) clkvco_lk_tmp <= 0;
               #(period_vco_half_rm) clkvco_lk_tmp <= 1;
          end
               clkout_en_t <= ik4;
       end

       #(period_vco_half) clkvco_lk_tmp <= 0;

//       if (clkpll == 1) begin
       if (clkpll == 1 && m_product > 1) begin
          for (ik4=1; ik4 < m_product; ik4=ik4+1) begin
               clkout_en_t <= ik4;
               #(period_vco_half) clkvco_lk_tmp <= 0;
               #(period_vco_half_rm) clkvco_lk_tmp <= 1;
          end
               clkout_en_t <= ik4;
          #(period_vco_half) clkvco_lk_tmp <= 0;
       end

    end
  end

  always @(fb_delay or period_vco or period_vco_mf or clkfbm1_dly or clkfbm1pm_rl
         or lock_period or ps_in_ps )
   if (lock_period == 1) begin
     if (clkfb_frac_en == 1) begin
        fbm1_comp_delay = 0;
//        val_tmp = period_vco * mf_product ;
          val_tmp = period_vco_mf;
     end
     else begin
        val_tmp = period_avg * DIVCLK_DIVIDE;
        fbm1_comp_delay = period_vco * (clkfbm1_dly  + clkfbm1pm_rl);
      end
    dly_tmp1 = fb_delay + fbm1_comp_delay;
    dly_tmp_int = 1;
    if (clkfb_fps_en == 1) begin 
        if (ps_in_ps < 0) begin
           tmp_ps_val1 = -1 * ps_in_ps;
           tmp_ps_val2 = tmp_ps_val1 * period_vco / 56.0;
           if (tmp_ps_val2 > dly_tmp1 ) begin
             dly_tmp_int = -1;
             dly_tmp = tmp_ps_val2 - dly_tmp1;
           end
           else if (tmp_ps_val2 ==  dly_tmp1 ) begin
             dly_tmp_int = 0;
             dly_tmp = 0;
           end
           else begin
             dly_tmp_int = 1;
             dly_tmp =  dly_tmp1 - tmp_ps_val2;
           end
        end
        else
            dly_tmp = dly_tmp1 + ps_in_ps * period_vco / 56.0;
    end
    else 
        dly_tmp = dly_tmp1;

    if (dly_tmp_int < 0) 
      clkvco_delay = dly_tmp;
    else begin
       if (clkfb_frac_en == 1 && dly_tmp == 0)
          clkvco_delay = 0;
       else if ( dly_tmp < val_tmp)
          clkvco_delay = val_tmp - dly_tmp;
       else
          clkvco_delay = val_tmp - dly_tmp % val_tmp ;
    end
  end

  always @(period_vco or ps_in_ps ) 
  if (fps_en == 1) begin
   if (ps_in_ps < 0)
     period_ps = period_vco + ps_in_ps * period_vco / 56.0;
   else if ((ps_in_ps == 0) && psincdec_in == 0)
     period_ps = period_vco;
   else
     period_ps = ps_in_ps * period_vco / 56.0;
  end

  always @(clkfbm1pm_sel)
    case (clkfbm1pm_sel)
      3'b000 : clkfbm1pm_rl = 0.0;
      3'b001 : clkfbm1pm_rl = 0.125;
      3'b010 : clkfbm1pm_rl = 0.25;
      3'b011 : clkfbm1pm_rl = 0.375;
      3'b100 : clkfbm1pm_rl = 0.50;
      3'b101 : clkfbm1pm_rl = 0.625;
      3'b110 : clkfbm1pm_rl = 0.75;
      3'b111 : clkfbm1pm_rl = 0.875;
    endcase

  
  always @(clkvco_lk)
        clkvco_lk_dly_tmp <= #clkvco_delay clkvco_lk;

  always @(clkvco_lk_dly_tmp or clkvco_lk  or pll_locked_tm)
    if ( pll_locked_tm) begin
      if (dly_tmp == 0)
         clkvco = clkvco_lk;
      else
         clkvco =  clkvco_lk_dly_tmp;
    end
    else
       clkvco = 0;

  always @(clk0_ht or clk0_lt or clk0_nocnt or init_trig or clk0_edge)
    clkout_pm_cal(clk0_ht1, clk0_div, clk0_div1, clk0_ht, clk0_lt, clk0_nocnt, clk0_edge);
  always @(clk1_ht or clk1_lt or clk1_nocnt or init_trig  or clk1_edge)
    clkout_pm_cal(clk1_ht1, clk1_div, clk1_div1, clk1_ht, clk1_lt, clk1_nocnt, clk1_edge);
  always @(clk2_ht or clk2_lt or clk2_nocnt or init_trig  or clk2_edge)
    clkout_pm_cal(clk2_ht1, clk2_div, clk2_div1, clk2_ht, clk2_lt, clk2_nocnt, clk2_edge);
  always @(clk3_ht or clk3_lt or clk3_nocnt or init_trig  or clk3_edge)
    clkout_pm_cal(clk3_ht1, clk3_div, clk3_div1, clk3_ht, clk3_lt, clk3_nocnt, clk3_edge);
  always @(clk4_ht or clk4_lt or clk4_nocnt or init_trig  or clk4_edge)
    clkout_pm_cal(clk4_ht1, clk4_div, clk4_div1, clk4_ht, clk4_lt, clk4_nocnt, clk4_edge);
  always @(clk5_ht or clk5_lt or clk5_nocnt or init_trig  or clk5_edge)
    clkout_pm_cal(clk5_ht1, clk5_div, clk5_div1, clk5_ht, clk5_lt, clk5_nocnt, clk5_edge);
  always @(clk6_ht or clk6_lt or clk6_nocnt or init_trig  or clk6_edge)
    clkout_pm_cal(clk6_ht1, clk6_div, clk6_div1, clk6_ht, clk6_lt, clk6_nocnt, clk6_edge);
  always @(clkfbm1_ht or clkfbm1_lt or clkfbm1_nocnt or init_trig  or clkfbm1_edge)
    if (clkfb_frac_en) begin
      clkfbm1_div = CLKFBOUT_MULT_F;
    end
    else
      clkout_pm_cal(clkfbm1_ht1, clkfbm1_div, clkfbm1_div1, clkfbm1_ht, clkfbm1_lt, clkfbm1_nocnt, clkfbm1_edge);
  always @(clkfbm2_ht or clkfbm2_lt or clkfbm2_nocnt or init_trig  or clkfbm2_edge)
    clkout_pm_cal(clkfbm2_ht1, clkfbm2_div, clkfbm2_div1, clkfbm2_ht, clkfbm2_lt, clkfbm2_nocnt, clkfbm2_edge);
  always @(clkind_ht or clkind_lt or clkind_nocnt or init_trig  or clkind_edge)
    clkout_pm_cal(clkind_ht1, clkind_div, clkind_div1, clkind_ht, clkind_lt, clkind_nocnt, clkind_edge);

  always @(posedge psclk_in or posedge rst_in)
    if (rst_in) begin
      ps_in_ps <= ps_in_init;
      ps_cnt <= 0;
    end
    else if (fps_en == 1) begin
     if (psen_in) begin
       if (ps_lock == 1) 
        $display(" Warning : Please wait for PSDONE signal before adjusting the Phase Shift.");
       else if (psincdec_in == 1) begin
           if (ps_cnt < ps_max) 
              ps_cnt <= ps_cnt + 1;
           else
              ps_cnt <= 0;

           if (ps_in_ps < ps_max) 
              ps_in_ps <= ps_in_ps + 1;
           else 
              ps_in_ps <= 0;

           ps_lock <= 1;
       end
       else if (psincdec_in == 0) begin
           ps_cnt_neg = (-1) * ps_cnt;
           ps_in_ps_neg = (-1) * ps_in_ps;
           if (ps_cnt_neg < ps_max) 
              ps_cnt <= ps_cnt - 1;
           else
              ps_cnt <= 0;

           if (ps_in_ps_neg < ps_max) 
              ps_in_ps <= ps_in_ps - 1;
           else 
              ps_in_ps <= 0;

           ps_lock <= 1;
       end
     end
     if ( psdone_out == 1)
            ps_lock <= 0;
  end

  always @(posedge ps_lock  )
    if (fps_en == 1) begin
        @(posedge psclk_in)
        @(posedge psclk_in)
        @(posedge psclk_in)
        @(posedge psclk_in)
        @(posedge psclk_in)
        @(posedge psclk_in)
        @(posedge psclk_in)
        @(posedge psclk_in)
        @(posedge psclk_in)
        @(posedge psclk_in)
        @(posedge psclk_in)
          begin
            psdone_out = 1;
            @(posedge psclk_in);
               psdone_out = 0;
          end
  end

  always @(rst_in_o)
    if (rst_in_o) begin
      assign clkout_mux = 8'b0;
      assign clkout_ps_mux = 8'b0;
      assign clkout_ps = 0;
      assign clkout_ps_tmp1 = 0;
      assign clkout_ps_tmp2 = 0;
      assign clk0_frac_out = 0;
      assign clkfbm1_frac_out = 0;
    end
    else begin
      deassign clkout_mux;
      deassign clkout_ps_mux;
      deassign clkout_ps;
      deassign clkout_ps_tmp1;
      deassign clkout_ps_tmp2;
      deassign clk0_frac_out;
      deassign clkfbm1_frac_out;
    end

    always @(rst_clkinstopped) 
    if (rst_clkinstopped) begin
      assign clkfb_frac_ht = 50;
      assign clkfb_frac_lt = 50;
    end
    else begin
      deassign clkfb_frac_ht;
      deassign clkfb_frac_lt;
    end 

  always @(clkvco or clkout_en ) 
    if (clkout_en) begin
      clkout_mux[0] = clkvco;
      clkout_mux[1] <= #(period_vco1) clkvco;
      clkout_mux[2] <= #(period_vco2) clkvco;
      clkout_mux[3] <= #(period_vco3) clkvco;
      clkout_mux[4] <= #(period_vco4) clkvco;
      clkout_mux[5] <= #(period_vco5) clkvco;
      clkout_mux[6] <= #(period_vco6) clkvco;
      clkout_mux[7] <= #(period_vco7) clkvco;
    end
   
  always @(clkout_ps or clkout_en ) 
    if (clkout_en) begin
      clkout_ps_mux[0] = clkout_ps;
      clkout_ps_mux[1] <= #(period_vco1) clkout_ps;
      clkout_ps_mux[2] <= #(period_vco2) clkout_ps;
      clkout_ps_mux[3] <= #(period_vco3) clkout_ps;
      clkout_ps_mux[4] <= #(period_vco4) clkout_ps;
      clkout_ps_mux[5] <= #(period_vco5) clkout_ps;
      clkout_ps_mux[6] <= #(period_vco6) clkout_ps;
      clkout_ps_mux[7] <= #(period_vco7) clkout_ps;
    end
   
  always @(clkvco or clkout_en ) 
    if ( fps_en == 1)  begin
      clkvco_ps_tmp1 <= #(period_ps) clkvco;
      clkvco_ps_tmp2 <= #(period_ps_old) clkvco;
    end

   always @(negedge clkout_ps)
      clkout_ps_eg <= $time;

   always @(posedge clkout_ps)
      clkout_ps_peg <= $time;

   always @(ps_lock)
     ps_lock_dly <= #1 ps_lock;

   always @(posedge ps_lock_dly) 
    if ((period_ps - period_ps_old) > period_vco_half ) begin
      if (clkout_ps == 0) begin
        if (clkvco_ps_tmp2 == 1) begin
           clkout_ps_w = $time - clkout_ps_eg;
           if (clkout_ps_w > period_vco3) 
              clkvco_ps_tmp2_en <= 1;
           else begin
            @(negedge clkvco_ps_tmp2)
              clkvco_ps_tmp2_en <= 1;
           end
        end
        else
           clkvco_ps_tmp2_en <= 1;
      end
      else begin
        if (clkvco_ps_tmp2 == 0) begin
           clkout_ps_w = $time - clkout_ps_peg;
           if (clkout_ps_w > period_vco3)
              clkvco_ps_tmp2_en <= 1;
           else begin
            @(posedge clkvco_ps_tmp2)
              clkvco_ps_tmp2_en <= 1;
           end
        end
        else
           clkvco_ps_tmp2_en <= 1;
      end
      @(posedge clkvco_ps_tmp2);
      @(negedge clkvco_ps_tmp2)
        if (clkvco_ps_tmp1 == 0)
          clkvco_ps_tmp2_en <= 0;
        else
          @(negedge clkvco_ps_tmp1)
            clkvco_ps_tmp2_en <= 0;
   end


   always @(clkvco or clkvco_ps_tmp1 or clkvco_ps_tmp2 or clkvco_ps_tmp2_en )
   if (fps_en == 1)  begin
     if (ps_in_ps == 0 )
        clkout_ps  = clkvco;
     else if (clkvco_ps_tmp2_en == 1)
        clkout_ps  = clkvco_ps_tmp2;
     else
        clkout_ps  = clkvco_ps_tmp1;
   end


  assign clk0in = (clk0_fps_en == 1) ? clkout_ps_mux[clk0pm_sel] : clkout_mux[clk0pm_sel1];
  assign clk1in = (clk1_fps_en == 1) ? clkout_ps_mux[clk1pm_sel] : clkout_mux[clk1pm_sel];
  assign clk2in = (clk2_fps_en == 1) ? clkout_ps_mux[clk2pm_sel] : clkout_mux[clk2pm_sel];
  assign clk3in = (clk3_fps_en == 1) ? clkout_ps_mux[clk3pm_sel] : clkout_mux[clk3pm_sel];
  assign clk4in = (clk4_fps_en == 1) ? clkout_ps_mux[clk4pm_sel] : ((clkout4_cascade_int == 1) ? clk6_out : clkout_mux[clk4pm_sel]);
  assign clk5in = (clk5_fps_en == 1) ? clkout_ps_mux[clk5pm_sel] : clkout_mux[clk5pm_sel1];
  assign clk6in = (clk6_fps_en == 1) ? clkout_ps_mux[clk6pm_sel] : clkout_mux[clk6pm_sel1];
  assign clkfbm1in = (clkfb_fps_en == 1) ? clkout_ps_mux[clkfbm1pm_sel] : clkout_mux[clkfbm1pm_sel1];
  
  assign clkfbm1pm_sel1 = (clkfb_frac_en) ? 3'b0 : clkfbm1pm_sel;
  assign clk6pm_sel1 = (clkfb_frac_en) ? 3'b0 : clk6pm_sel;
  assign clk0pm_sel1 = (clk0_frac_en) ? 3'b0 : clk0pm_sel;
  assign clk5pm_sel1 = (clk0_frac_en) ? 3'b0 : clk5pm_sel;

  assign clk0ps_en = (clk0_dly_cnt == clkout0_dly) ? clkout_en : 0;
  assign clk1ps_en = (clk1_dly_cnt == clkout1_dly) ? clkout_en : 0;
  assign clk2ps_en = (clk2_dly_cnt == clkout2_dly) ? clkout_en : 0;
  assign clk3ps_en = (clk3_dly_cnt == clkout3_dly) ? clkout_en : 0;
  assign clk4ps_en = (clk4_dly_cnt == clkout4_dly) ? clkout_en : 0;
  assign clk5ps_en = (clk5_dly_cnt == clkout5_dly) ? clkout_en : 0;
  assign clk6ps_en = (clk6_dly_cnt == clkout6_dly) ? clkout_en : 0;
  assign clkfbm1ps_en = (clkfbm1_dly_cnt == clkfbm1_dly) ? clkout_en : 0;

  always @(posedge clk0in) 
    if (clkout_en && clk0_frac_en) begin
        clk0_frac_out <= 1;
          for (ik0=1; ik0 < 8; ik0=ik0+1) begin
               #(clk0_frac_ht) clk0_frac_out <= 0;
               #(clk0_frac_lt) clk0_frac_out <= 1;
          end
          #(clk0_frac_ht) clk0_frac_out <= 0;
//          #(clk0_frac_lt - 50);
          #(clk0_frac_lt - period_vco1);
      end

  always @(posedge clkfbm1in) 
    if (clkout_en && clkfb_frac_en) begin
        clkfbm1_frac_out <= 1;
          for (ib=1; ib < 8; ib=ib+1) begin
               #(clkfb_frac_ht) clkfbm1_frac_out <= 0;
               #(clkfb_frac_lt) clkfbm1_frac_out <= 1;
          end
          #(clkfb_frac_ht) clkfbm1_frac_out <= 0;
          #(clkfb_frac_lt - period_vco1);
    end
    else
       clkfbm1_frac_out <= 0;

 always  @(negedge clk0in or posedge rst_in_o)
   if (rst_in_o) 
     clk0_dly_cnt <= 6'b0;
   else if (clkout_en == 1 && clk0_frac_en == 0) begin
     if (clk0_dly_cnt < clkout0_dly)
       clk0_dly_cnt <= clk0_dly_cnt + 1;
   end

  always  @(negedge clk1in or posedge rst_in_o)
    if (rst_in_o)
      clk1_dly_cnt <= 6'b0;
    else
      if (clk1_dly_cnt < clkout1_dly && clkout_en ==1)
        clk1_dly_cnt <= clk1_dly_cnt + 1;

  always  @(negedge clk2in or posedge rst_in_o)
    if (rst_in_o)
      clk2_dly_cnt <= 6'b0;
    else
      if (clk2_dly_cnt < clkout2_dly && clkout_en ==1)
        clk2_dly_cnt <= clk2_dly_cnt + 1;

  always  @(negedge clk3in or posedge rst_in_o)
    if (rst_in_o)
      clk3_dly_cnt <= 6'b0;
    else
      if (clk3_dly_cnt < clkout3_dly && clkout_en ==1)
        clk3_dly_cnt <= clk3_dly_cnt + 1;

  always  @(negedge clk4in or posedge rst_in_o)
    if (rst_in_o)
        clk4_dly_cnt <= 6'b0;
    else
       if (clk4_dly_cnt < clkout4_dly && clkout_en ==1)
          clk4_dly_cnt <= clk4_dly_cnt + 1;

  always  @(negedge clk5in or posedge rst_in_o)
    if (rst_in_o) 
        clk5_dly_cnt <= 6'b0;
    else if (clkout_en == 1 && clk0_frac_en == 0) begin
       if (clk5_dly_cnt < clkout5_dly)
          clk5_dly_cnt <= clk5_dly_cnt + 1;
    end

  always  @(negedge clk6in or posedge rst_in_o)
    if (rst_in_o) 
        clk6_dly_cnt <= 6'b0;
    else if (clkout_en == 1 && clkfb_frac_en == 0) begin
       if (clk6_dly_cnt < clkout6_dly)
          clk6_dly_cnt <= clk6_dly_cnt + 1;
    end

  always  @(negedge clkfbm1in or posedge rst_in_o)
    if (rst_in_o) 
        clkfbm1_dly_cnt <= 6'b0;
    else if (clkout_en == 1 && clkfb_frac_en == 0) begin
       if (clkfbm1_dly_cnt < clkfbm1_dly)
          clkfbm1_dly_cnt <= clkfbm1_dly_cnt + 1;
    end

  always @(posedge clk0in or negedge clk0in or posedge rst_in_o)
    if (rst_in_o) begin
        clk0_cnt <= 8'b0;
        clk0_nf_out <= 0;
    end
    else if (clk0ps_en && clk0_frac_en == 0) begin
      if (clk0_cnt < clk0_div1)
         clk0_cnt <= clk0_cnt + 1;
      else
         clk0_cnt <= 8'b0; 
      if (clk0_cnt < clk0_ht1)
         clk0_nf_out <= 1;
      else
         clk0_nf_out <= 0;
    end
    else begin
         clk0_cnt <= 8'b0;
         clk0_nf_out <= 0;
    end

  assign clk0_out = (clk0_frac_en) ? clk0_frac_out : clk0_nf_out;

  always @(posedge clk1in or negedge clk1in or posedge rst_in_o)
    if (rst_in_o) begin
        clk1_cnt <= 8'b0;
        clk1_out <= 0;
    end
    else if (clk1ps_en) begin
          if (clk1_cnt < clk1_div1)
                clk1_cnt <= clk1_cnt + 1;
          else
                clk1_cnt <= 8'b0;
          if (clk1_cnt < clk1_ht1)
                clk1_out <= 1;
          else
                clk1_out <= 0;
    end
    else begin
        clk1_cnt <= 8'b0;
        clk1_out <= 0;
    end

  always @(posedge clk2in or negedge clk2in or posedge rst_in_o)
    if (rst_in_o) begin
        clk2_cnt <= 8'b0;
        clk2_out <= 0;
    end
    else if (clk2ps_en) begin
          if (clk2_cnt < clk2_div1)
                clk2_cnt <= clk2_cnt + 1;
          else
                clk2_cnt <= 8'b0;
          if (clk2_cnt < clk2_ht1)
                clk2_out <= 1;
           else
                clk2_out <= 0;
     end
     else begin
        clk2_cnt <= 8'b0;
        clk2_out <= 0;
     end

  always @(posedge clk3in or negedge clk3in or posedge rst_in_o)
    if (rst_in_o) begin
        clk3_cnt <= 8'b0;
        clk3_out <= 0;
    end
    else if (clk3ps_en) begin
          if (clk3_cnt < clk3_div1)
                clk3_cnt <= clk3_cnt + 1;
          else
                clk3_cnt <= 8'b0;
          if (clk3_cnt < clk3_ht1)
                clk3_out <= 1;
          else
                clk3_out <= 0;
    end
    else begin
        clk3_cnt <= 8'b0;
        clk3_out <= 0;
    end


  always @(posedge clk4in or negedge clk4in or posedge rst_in_o)
    if (rst_in_o) begin
        clk4_cnt <= 8'b0;
        clk4_out <= 0;
    end
    else if (clk4ps_en) begin
          if (clk4_cnt < clk4_div1)
                clk4_cnt <= clk4_cnt + 1;
          else
                clk4_cnt <= 8'b0;
          if (clk4_cnt < clk4_ht1)
                clk4_out <= 1;
          else
                clk4_out <= 0;
    end
    else begin
        clk4_cnt <= 8'b0;
        clk4_out <= 0;
    end

  always @(posedge clk5in or negedge clk5in or posedge rst_in_o)
    if (rst_in_o) begin
        clk5_cnt <= 8'b0;
        clk5_out <= 0;
    end
    else if (clk5ps_en && clk0_frac_en == 0) begin
          if (clk5_cnt < clk5_div1)
                clk5_cnt <= clk5_cnt + 1;
          else
                clk5_cnt <= 8'b0;
          if (clk5_cnt < clk5_ht1)
                clk5_out <= 1;
          else
                clk5_out <= 0;
    end
    else begin
        clk5_cnt <= 8'b0;
        clk5_out <= 0;
    end

  always @(posedge clk6in or negedge clk6in or posedge rst_in_o)
    if (rst_in_o) begin
        clk6_cnt <= 8'b0;
        clk6_out <= 0;
    end
    else if (clk6ps_en && clkfb_frac_en == 0) begin
          if (clk6_cnt < clk6_div1)
                clk6_cnt <= clk6_cnt + 1;
          else
                clk6_cnt <= 8'b0;
          if (clk6_cnt < clk6_ht1)
                clk6_out <= 1;
          else
                clk6_out <= 0;
    end
    else begin
        clk6_cnt <= 8'b0;
        clk6_out <= 0;
    end

  always @(posedge clkfbm1in or negedge clkfbm1in or posedge rst_in_o)
    if (rst_in_o) begin
        clkfbm1_cnt <= 8'b0;
        clkfbm1_nf_out <= 0;
    end
    else if (clkfbm1ps_en && clkfb_frac_en == 0) begin
          if (clkfbm1_cnt < clkfbm1_div1)
                clkfbm1_cnt <= clkfbm1_cnt + 1;
          else
                clkfbm1_cnt <= 8'b0;
          if (clkfbm1_cnt < clkfbm1_ht1)
                clkfbm1_nf_out <= 1;
          else
                clkfbm1_nf_out <= 0;
    end
    else begin
        clkfbm1_cnt <= 8'b0;
        clkfbm1_nf_out <= 0;
    end

  assign clkfbm1_out = (clkfb_frac_en) ? clkfbm1_frac_out : clkfbm1_nf_out;

  always @(posedge clkfb_in or negedge clkfb_in or posedge rst_in)
    if (rst_in) begin
        clkfbm2_cnt <= 8'b0;
        clkfbm2_out <= 0;
    end
    else if (clkout_en)  begin
          if (clkfbm2_cnt < clkfbm2_div1)
                clkfbm2_cnt <= clkfbm2_cnt + 1;
          else
                clkfbm2_cnt <= 8'b0;
          if (clkfbm2_cnt < clkfbm2_ht1)
                clkfbm2_out <= 1;
          else
                clkfbm2_out <= 0;
    end
    else begin
        clkfbm2_cnt <= 8'b0;
        clkfbm2_out <= 0;
    end

  always @(posedge clkpll_r or negedge clkpll_r or posedge rst_in)
    if (rst_in) begin
        clkind_cnt <= 8'b0;
        clkind_out <= 0;
    end
    else if (clkout_en) begin
          if (clkind_cnt < clkind_div1)
                clkind_cnt <= clkind_cnt + 1;
          else
                clkind_cnt <= 8'b0;
          if (clkind_cnt < clkind_ht1)
                clkind_out <= 1;
          else
                clkind_out <= 0;
    end
    else begin
        clkind_cnt <= 8'b0;
        clkind_out <= 0;
    end

   always @(clk0_out or clkfb_tst or fb_delay_found)
     if (fb_delay_found == 1)
          clkout0_out =  clk0_out;
     else
          clkout0_out = clkfb_tst;

   always @(clk1_out or clkfb_tst or fb_delay_found)
     if (fb_delay_found == 1)
          clkout1_out =  clk1_out;
     else
          clkout1_out = clkfb_tst;

   always @(clk2_out or clkfb_tst or fb_delay_found)
     if (fb_delay_found == 1)
          clkout2_out =  clk2_out;
     else
          clkout2_out = clkfb_tst;

   always @(clk3_out or clkfb_tst or fb_delay_found)
     if (fb_delay_found == 1)
          clkout3_out =  clk3_out;
     else
          clkout3_out = clkfb_tst;

   always @(clk4_out or clkfb_tst or fb_delay_found)
     if (fb_delay_found == 1)
          clkout4_out =  clk4_out;
     else
          clkout4_out = clkfb_tst;

   always @(clk5_out or clkfb_tst or fb_delay_found)
     if (fb_delay_found == 1)
          clkout5_out =  clk5_out;
     else
          clkout5_out = clkfb_tst;

   always @(clk6_out or clkfb_tst or fb_delay_found)
     if (fb_delay_found == 1)
          clkout6_out =  clk6_out;
     else
          clkout6_out = clkfb_tst;

   always @(clkfbm1_out or clkfb_tst or fb_delay_found)
     if (fb_delay_found == 1)
          clkfb_out =  clkfbm1_out;
     else
          clkfb_out = clkfb_tst;

  //
  // determine feedback delay
  //

//  always @(rst_in)
//    if (rst_in)
//      assign clkfb_tst = 0;
//    else
//      deassign clkfb_tst;

  always @(posedge clkpll_r )
    if (fb_delay_found_tmp == 0 && pwron_int == 0 && rst_in == 0) begin
         clkfb_tst <=  1'b1;
    end
    else
         clkfb_tst <=  1'b0;
  
  always @( posedge clkfb_tst or posedge rst_in )
    if (rst_in)
      delay_edge  <= 0;
    else 
      delay_edge <= $time;

  always @(posedge clkfb_in or posedge rst_in ) 
    if (rst_in) begin
      fb_delay  <= 0;
      fb_delay_found_tmp <= 0;
    end
    else 
      if (fb_delay_found_tmp ==0 ) begin
        if ( delay_edge != 0)
          fb_delay <= ($time - delay_edge);
        else
          fb_delay <= 0;
        fb_delay_found_tmp <=  1;
      end

  always @(rst_in)
    if (rst_in)
       assign fb_delay_found = 0;
    else
       deassign fb_delay_found;

  always @(fb_delay_found_tmp or clkvco_delay )
    if (clkvco_delay == 0) 
       fb_delay_found <= #1000 fb_delay_found_tmp;
    else
       fb_delay_found <= #(clkvco_delay) fb_delay_found_tmp;

  always @(fb_delay)
    if (rst_in==0 && (fb_delay/1000.0 > fb_delay_max)) begin
      $display("Warning : The feedback delay on MMCM_ADV instance %m at time %t is %f ns. It is over the maximun value %f ns.", $time, fb_delay / 1000.0, fb_delay_max);
    end

  //
  // generate unlock signal
  //

  always @(clk_osc or rst_in)
     if (rst_in)
       clk_osc <= 0;
     else
       clk_osc <= #OSC_P2 ~clk_osc;

  always @(posedge clkpll_r or negedge clkpll_r) begin
      clkin_p <= 1;
      clkin_p <= #100 0;
  end
  
  always @(posedge clkfb_in or negedge clkfb_in) begin
      clkfb_p <= 1;
      clkfb_p <= #100 0;
  end


  always @(posedge clk_osc or posedge rst_in or posedge clkin_p)
      if (rst_in == 1 || clkin_p == 1) begin
        clkinstopped_out <= 0;
        clkin_lost_cnt <= 0;
      end
      else if (lock_period) begin
        if (clkin_lost_cnt < clkin_lost_val) begin
           clkin_lost_cnt <= clkin_lost_cnt + 1;
           clkinstopped_out <= 0;
        end
        else
           clkinstopped_out <= 1;
      end
                                                                                   
  always @(posedge clk_osc or posedge rst_in or posedge clkfb_p)
      if (rst_in == 1 || clkfb_p == 1) begin
        clkfbstopped_out <= 0;
        clkfb_lost_cnt <= 0;
      end
      else if (clkout_en) begin
        if (clkfb_lost_cnt < clkfb_lost_val) begin
           clkfb_lost_cnt <= clkfb_lost_cnt + 1;
           clkfbstopped_out <= 0;
        end
        else
           clkfbstopped_out <= 1;
      end
      

  always @(clkin_jit or rst_in )
    if (rst_in)
       clkpll_jitter_unlock = 0;
    else
      if (pll_locked_tmp2 && clkfbstopped_out == 0 && clkinstopped_out == 0) begin
        if ((clkin_jit > REF_CLK_JITTER_MAX_tmp && clkin_jit < period_avg) ||
             (clkin_jit < -REF_CLK_JITTER_MAX_tmp && clkin_jit > -period_avg ))
          clkpll_jitter_unlock = 1;
        else
          clkpll_jitter_unlock = 0;
      end
      else
          clkpll_jitter_unlock = 0;
      
  assign pll_unlock1 = (clkinstopped_out_dly ==1 || clkfbstopped_out==1 || clkpll_jitter_unlock == 1) ? 1 : 0; 
  assign pll_unlock = (clkinstopped_out_dly ==1 || clkfbstopped_out==1 || clkpll_jitter_unlock == 1 || unlock_recover == 1) ? 1 : 0; 

  // tasks

  task clkout_dly_cal;
  output [5:0] clkout_dly;
  output [2:0] clkpm_sel;
  input  clkdiv;
  input  clk_ps;
  input reg [160:0] clk_ps_name;
  integer clkdiv;
  real clk_ps;
  real clk_ps_rl;
  real clk_dly_rl, clk_dly_rem;
  integer clkout_dly_tmp;
  begin
    if (clk_ps < 0.0)
      clk_dly_rl = (360.0 + clk_ps) * clkdiv / 360.0; 
    else
      clk_dly_rl = clk_ps * clkdiv / 360.0;
  
    clkout_dly_tmp =  $rtoi(clk_dly_rl);

    if (clkout_dly_tmp > 63) begin
      $display(" Warning : Attribute %s of MMCM_ADV on instance %m is set to %f. Required phase shifting can not be reached since it is over the maximum phase shifting ability of MMCM_ADV", clk_ps_name, clk_ps);
      clkout_dly = 6'b111111;
    end
    else
      clkout_dly = clkout_dly_tmp;

    clk_dly_rem = clk_dly_rl - clkout_dly;

    if (clk_dly_rem < 0.125)
        clkpm_sel =  0;
    else if (clk_dly_rem >=  0.125 && clk_dly_rem < 0.25)
        clkpm_sel =  1;
    else if (clk_dly_rem >=  0.25 && clk_dly_rem < 0.375)
        clkpm_sel =  2;
    else if (clk_dly_rem >=  0.375 && clk_dly_rem < 0.5)
        clkpm_sel =  3;
    else if (clk_dly_rem >=  0.5 && clk_dly_rem < 0.625)
        clkpm_sel =  4;
    else if (clk_dly_rem >=  0.625 && clk_dly_rem < 0.75)
        clkpm_sel =  5;
    else if (clk_dly_rem >=  0.75 && clk_dly_rem < 0.875)
        clkpm_sel =  6;
    else if (clk_dly_rem >=  0.875 )
        clkpm_sel =  7;

    if (clk_ps < 0.0)
       clk_ps_rl = (clkout_dly + 0.125 * clkpm_sel)* 360.0 / clkdiv - 360.0;
    else
       clk_ps_rl = (clkout_dly + 0.125 * clkpm_sel) * 360.0 / clkdiv;

    if (((clk_ps_rl- clk_ps) > 0.001) || ((clk_ps_rl- clk_ps) < -0.001))
      $display(" Warning : Attribute %s of MMCM_ADV on instance %m is set to %f. Real phase shifting is %f. Required phase shifting can not be reached.", clk_ps_name, clk_ps, clk_ps_rl);

  end
  endtask

  task   clk_out_para_cal;
  output [6:0] clk_ht;
  output [6:0] clk_lt; 
  output clk_nocnt;
  output clk_edge; 
  input  CLKOUT_DIVIDE;
  input  CLKOUT_DUTY_CYCLE;
  integer CLKOUT_DIVIDE;
  real  CLKOUT_DUTY_CYCLE;
  real  tmp_value, tmp_value0, tmp_value_rm;
  integer tmp_value1, tmp_value_r;
  real tmp_value2;
  real tmp_value_rm1, tmp_value_r1;
  integer tmp_value_r2;
  begin

     tmp_value0 = CLKOUT_DIVIDE * CLKOUT_DUTY_CYCLE;
     tmp_value_r = $rtoi(tmp_value0);
     tmp_value_rm = tmp_value0 - tmp_value_r;
     if (tmp_value_rm < 0.1)
       tmp_value = tmp_value_r * 1.0;
     else if (tmp_value_rm > 0.9)
       tmp_value = 1.0 * tmp_value_r + 1.0;
     else begin
       tmp_value_r1 = tmp_value0 * 2.0;
       tmp_value_r2 = $rtoi(tmp_value_r1);
       tmp_value_rm1 = tmp_value_r1 - tmp_value_r2;
       if (tmp_value_rm1 > 0.995)
          tmp_value = tmp_value0 + 0.002;
       else
          tmp_value = tmp_value0;
     end
     tmp_value1 =  $rtoi(tmp_value * 2.0) % 2;
     tmp_value2 = CLKOUT_DIVIDE - tmp_value;
   

     if ((tmp_value2) >= O_MAX_HT_LT) begin
       clk_lt = 7'b1000000;
     end
     else begin
       if  (tmp_value2 < 1.0)
          clk_lt = 1;
       else  
          if ( tmp_value1  != 0)
             clk_lt = $rtoi(tmp_value2) + 1; 
          else
             clk_lt = $rtoi(tmp_value2);
     end

     if ( (CLKOUT_DIVIDE -  clk_lt) >= O_MAX_HT_LT)
       clk_ht = 7'b1000000;
     else 
       clk_ht =  CLKOUT_DIVIDE -  clk_lt;

     clk_nocnt = (CLKOUT_DIVIDE ==1) ? 1 : 0;
     if ( tmp_value < 1.0)
       clk_edge = 1;
     else if (tmp_value1 != 0)
       clk_edge = 1;
     else
       clk_edge = 0;
  end
  endtask

  function  clkout_duty_chk;
  input  CLKOUT_DIVIDE;
  input  CLKOUT_DUTY_CYCLE;
  input reg [160:0] CLKOUT_DUTY_CYCLE_N; 
  integer CLKOUT_DIVIDE, step_tmp;
  real CLKOUT_DUTY_CYCLE;
  real CLK_DUTY_CYCLE_MIN, CLK_DUTY_CYCLE_MAX, CLK_DUTY_CYCLE_STEP;
  real CLK_DUTY_CYCLE_MIN_rnd;
  reg clk_duty_tmp_int;
  begin
    if (CLKOUT_DIVIDE > O_MAX_HT_LT) begin
      CLK_DUTY_CYCLE_MIN = (CLKOUT_DIVIDE - O_MAX_HT_LT)/CLKOUT_DIVIDE;
      CLK_DUTY_CYCLE_MAX = (O_MAX_HT_LT + 0.5)/CLKOUT_DIVIDE;
      CLK_DUTY_CYCLE_MIN_rnd = CLK_DUTY_CYCLE_MIN;
    end
    else begin
      if (CLKOUT_DIVIDE == 1) begin
        CLK_DUTY_CYCLE_MIN = 0.0;
        CLK_DUTY_CYCLE_MIN_rnd = 0.0;
      end
      else begin
        step_tmp = 1000 / CLKOUT_DIVIDE;
        CLK_DUTY_CYCLE_MIN_rnd = step_tmp / 1000.0;
        CLK_DUTY_CYCLE_MIN = 1.0 /CLKOUT_DIVIDE;
      end
      CLK_DUTY_CYCLE_MAX = 1.0;
    end

    if (CLKOUT_DUTY_CYCLE > CLK_DUTY_CYCLE_MAX || CLKOUT_DUTY_CYCLE < CLK_DUTY_CYCLE_MIN_rnd) begin
      $display(" Attribute Syntax Warning : %s is set to %f on instance %m and is not in the allowed range %f to %f.", CLKOUT_DUTY_CYCLE_N, CLKOUT_DUTY_CYCLE, CLK_DUTY_CYCLE_MIN, CLK_DUTY_CYCLE_MAX );
    end

    clk_duty_tmp_int = 0;
    CLK_DUTY_CYCLE_STEP = 0.5 / CLKOUT_DIVIDE;
    for (j = 0; j < (2 * CLKOUT_DIVIDE - CLK_DUTY_CYCLE_MIN/CLK_DUTY_CYCLE_STEP); j = j + 1)
        if (((CLK_DUTY_CYCLE_MIN + CLK_DUTY_CYCLE_STEP * j) - CLKOUT_DUTY_CYCLE) > -0.001 && 
             ((CLK_DUTY_CYCLE_MIN + CLK_DUTY_CYCLE_STEP * j) - CLKOUT_DUTY_CYCLE) < 0.001)
            clk_duty_tmp_int = 1;

    if ( clk_duty_tmp_int != 1) begin
      $display(" Attribute Syntax Warning : %s is set to %f on instance %m and is  not an allowed value. Allowed values are:",  CLKOUT_DUTY_CYCLE_N, CLKOUT_DUTY_CYCLE);
      for (j = 0; j < (2 * CLKOUT_DIVIDE - CLK_DUTY_CYCLE_MIN/CLK_DUTY_CYCLE_STEP); j = j + 1)
       $display("%f", CLK_DUTY_CYCLE_MIN + CLK_DUTY_CYCLE_STEP * j);
    end

    clkout_duty_chk = 1'b1;
  end
  endfunction

  function  para_int_range_chk;
  input  para_in; 
  input reg [160:0] para_name;
  input  range_low;
  input  range_high;
  integer para_in;
  integer range_low;
  integer  range_high;
  begin
    if ( para_in < range_low || para_in > range_high) begin
      $display("Attribute Syntax Error : The Attribute %s on MMCM_ADV instance %m is set to %d.  Legal values for this attribute are %d to %d.", para_name, para_in, range_low, range_high);
      $finish;
    end
    para_int_range_chk = 1'b1;
  end
  endfunction

  function  para_real_range_chk;
  input  para_in;
  input reg [160:0] para_name;
  input  range_low;
  input  range_high;
  real para_in;
  real range_low;
  real range_high;
  begin
    if ( para_in < range_low || para_in > range_high) begin
      $display("Attribute Syntax Error : The Attribute %s on MMCM_ADV instance %m is set to %f.  Legal values for this attribute are %f to %f.", para_name, para_in, range_low, range_high);
      $finish;
    end
    para_real_range_chk = 1'b0;
  end
  endfunction

  task clkout_pm_cal;
  output [7:0] clk_ht1;
  output [7:0] clk_div;
  output [7:0] clk_div1;
  input [6:0] clk_ht;
  input [6:0] clk_lt;
  input clk_nocnt;
  input clk_edge;
  begin
    if (clk_nocnt ==1) begin
        clk_div = 8'b00000001;
        clk_div1 = 8'b00000001;
        clk_ht1 = 8'b00000001;
    end
    else begin
      if ( clk_edge == 1)
        clk_ht1 = 2 * clk_ht + 1;
      else
        clk_ht1 = 2 * clk_ht;
      clk_div = clk_ht  + clk_lt ;
      clk_div1 = 2 * clk_div -1;
    end
  end
  endtask

  task clkout_delay_para_drp;
  output [5:0] clkout_dly;
  output clk_nocnt;
  output clk_edge;
  input [15:0]  di_in;
  input [6:0] daddr_in;
  begin
     clkout_dly = di_in[5:0];
     clk_nocnt = di_in[6];
     clk_edge = di_in[7];
  end
  endtask

  task clkout_hl_para_drp;
  output  [6:0] clk_lt;
  output  [6:0] clk_ht;
  output  [2:0] clkpm_sel;
  input [15:0] di_in_tmp;
  input [6:0] daddr_in_tmp;
  begin
    if (di_in_tmp[12] != 1) begin
      $display(" Error : MMCM_ADV on instance %m input DI is %h at address DADDR=%b at time %t. The bit 12 need to be set to 1 .", di_in_tmp, daddr_in_tmp, $time); 
    end
    if ( di_in_tmp[5:0] == 6'b0)
       clk_lt = 7'b1000000;
    else
       clk_lt = { 1'b0, di_in_tmp[5:0]};
    if (di_in_tmp[11:6] == 6'b0)
       clk_ht = 7'b1000000;
    else
       clk_ht = { 1'b0, di_in_tmp[11:6]};
    clkpm_sel = di_in_tmp[15:13];
  end
  endtask


endmodule
