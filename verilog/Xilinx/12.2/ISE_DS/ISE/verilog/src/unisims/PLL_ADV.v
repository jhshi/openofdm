// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/PLL_ADV.v,v 1.70.8.1 2010/05/20 20:38:47 yanx Exp $
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
// /___/   /\     Filename : PLL_ADV.v
// \   \  /  \    Timestamp : Thu Mar 25 16:44:07 PST 2004
//  \___\/\___\
//
// Revision:
//    10/02/08 - Initial version.
//    10/24/08 - Using internal clock to detect clkin and clkfb stopped (CR493444)
//    11/18/08 - Add timing check.
//    12/02/08 - Fix bug of Duty cycle calculation (CR498696)
//    12/04/08 - make clkfb_tst at least 1 ns wide (CR499318)
//    12/05/08 - change pll_res according to hardware spreadsheet (CR496137)
//    01/09/09 - Make pll_res same for BANDWIDTH=HIGH and OPTIMIZED (CR496137)
//    02/11/09 - Change VCO_FREQ_MAX and MIN to 1441 and 399 to cover the rounded
//               error (CR507969)
//    05/13/09 - Use period_avg for clkvco_delay calculation (CR521120)
//    06/11/09 - When calculate clk0_div1, set clk0_nocnt to 1 if CLKOUT0 as feedback (CR524704)
//    09/02/09 - Add SIM_DEVICE attribute (CR532327)
//    09/09/09 - Add DRP support for Spartan6 (CR532327)
//    10/08/09 - Change  CLKIN_FREQ MAX & MIN, CLKPFD_FREQ
//               MAX & MIN to parameter (CR535828)
//    10/14/09 - Add clkin_chk_t1 and clkin_chk_t2 to handle check (CR535662)
//    12/02/09 - not stop clkvco_lk when jitter (CR538717)
//    02/09/10 - Divide clk0 when CLKOUT0 as feedback (CR548329)
//             - Add global PLL_LOCKG (CR547918)
//    05/07/10 - Use period_vco_half_rm1 to reduce jitter (CR558966)
//             - Support CLK_FEEDBACK=CLKOUT0 and CLKOUT0_PHASE set(CR559360)
// End Revision


`timescale  1 ps / 1 ps


module PLL_ADV (
        CLKFBDCM,
        CLKFBOUT,
        CLKOUT0,
        CLKOUT1,
        CLKOUT2,
        CLKOUT3,
        CLKOUT4,
        CLKOUT5,
        CLKOUTDCM0,
        CLKOUTDCM1,
        CLKOUTDCM2,
        CLKOUTDCM3,
        CLKOUTDCM4,
        CLKOUTDCM5,
        DO,
        DRDY,
        LOCKED,
        CLKFBIN,
        CLKIN1,
        CLKIN2,
        CLKINSEL,
        DADDR,
        DCLK,
        DEN,
        DI,
        DWE,
        REL,
        RST
);

parameter BANDWIDTH = "OPTIMIZED";
parameter CLK_FEEDBACK = "CLKFBOUT";
parameter CLKFBOUT_DESKEW_ADJUST = "NONE";
parameter CLKOUT0_DESKEW_ADJUST = "NONE";
parameter CLKOUT1_DESKEW_ADJUST = "NONE";
parameter CLKOUT2_DESKEW_ADJUST = "NONE";
parameter CLKOUT3_DESKEW_ADJUST = "NONE";
parameter CLKOUT4_DESKEW_ADJUST = "NONE";
parameter CLKOUT5_DESKEW_ADJUST = "NONE";
parameter integer CLKFBOUT_MULT = 1;
parameter real CLKFBOUT_PHASE = 0.0;
parameter real CLKIN1_PERIOD = 0.000;
parameter real CLKIN2_PERIOD = 0.000;
parameter integer CLKOUT0_DIVIDE = 1;
parameter real CLKOUT0_DUTY_CYCLE = 0.5;
parameter real CLKOUT0_PHASE = 0.0;
parameter integer CLKOUT1_DIVIDE = 1;
parameter real CLKOUT1_DUTY_CYCLE = 0.5;
parameter real CLKOUT1_PHASE = 0.0;
parameter integer CLKOUT2_DIVIDE = 1;
parameter real CLKOUT2_DUTY_CYCLE = 0.5;
parameter real CLKOUT2_PHASE = 0.0;
parameter integer CLKOUT3_DIVIDE = 1;
parameter real CLKOUT3_DUTY_CYCLE = 0.5;
parameter real CLKOUT3_PHASE = 0.0;
parameter integer CLKOUT4_DIVIDE = 1;
parameter real CLKOUT4_DUTY_CYCLE = 0.5;
parameter real CLKOUT4_PHASE = 0.0;
parameter integer CLKOUT5_DIVIDE = 1;
parameter real CLKOUT5_DUTY_CYCLE = 0.5;
parameter real CLKOUT5_PHASE = 0.0;
parameter COMPENSATION = "SYSTEM_SYNCHRONOUS";
parameter integer DIVCLK_DIVIDE = 1;
parameter EN_REL = "FALSE";
parameter PLL_PMCD_MODE = "FALSE";
parameter real REF_JITTER = 0.100;
parameter RESET_ON_LOSS_OF_LOCK = "FALSE";
parameter RST_DEASSERT_CLK = "CLKIN1";
parameter SIM_DEVICE = "VIRTEX5";
parameter real VCOCLK_FREQ_MAX = 1440.0;
parameter real VCOCLK_FREQ_MIN = 400.0;
parameter real CLKIN_FREQ_MAX = 710.0;
parameter real CLKIN_FREQ_MIN = 19.0;  
parameter real CLKPFD_FREQ_MAX = 550.0;
parameter real CLKPFD_FREQ_MIN = 19.0; 

//  `ifdef XIL_TIMING



//  `endif

output CLKFBDCM;
output CLKFBOUT;
output CLKOUT0;
output CLKOUT1;
output CLKOUT2;
output CLKOUT3;
output CLKOUT4;
output CLKOUT5;
output CLKOUTDCM0;
output CLKOUTDCM1;
output CLKOUTDCM2;
output CLKOUTDCM3;
output CLKOUTDCM4;
output CLKOUTDCM5;
output DRDY;
output LOCKED;
output [15:0] DO;

input CLKFBIN;
input CLKIN1;
input CLKIN2;
input CLKINSEL;
input DCLK;
input DEN;
input DWE;
input REL;
input RST;
input [15:0] DI;
input [4:0] DADDR;

localparam VCOCLK_FREQ_TARGET = 800;
localparam M_MIN = 1;
localparam M_MAX = 74;
localparam D_MIN = 1;
localparam D_MAX = 52;
localparam O_MIN = 1;
localparam O_MAX = 128;
localparam O_MAX_HT_LT = 64;
localparam REF_CLK_JITTER_MAX = 1000;
localparam REF_CLK_JITTER_SCALE = 0.1;
localparam MAX_FEEDBACK_DELAY = 10.0;
localparam MAX_FEEDBACK_DELAY_SCALE = 1.0;
localparam PLL_LOCK_TIME = 7;
localparam OSC_P2 = 250;

tri0 GSR = glbl.GSR;
tri1 p_up;

wire  delay_CLKIN1;
wire  delay_CLKIN2;
wire  delay_CLKINSEL;
wire  delay_DCLK;
wire  delay_DEN;
wire  delay_DWE;
wire  delay_REL;
wire  [15:0] delay_DI;
wire  [4:0] delay_DADDR;

reg [4:0] daddr_lat;
reg valid_daddr;
reg drdy_out = 0;
reg drdy_out1 = 0;
reg drp_lock, drp_lock1;
reg [15:0] dr_sram [31:0];
reg [160:0] tmp_string;

wire CLKFBIN, CLKIN1, CLKIN2, CLKINSEL ;
wire rst_in, RST, orig_rst_in ;
wire locked_out;
reg  locked_out1 = 0;
wire clkvco_lk_rst;
reg pwron_int;

reg clk_osc, clkin_p, clkfb_p;
reg clk0_out, clk1_out, clk2_out, clk3_out, clk4_out, clk5_out;
reg clkfb_out, clkfbm1_out;
reg clkout_en, clkout_en1, clkout_en0, clkout_en0_tmp;
integer clkout_cnt, clkin_cnt, clkin_lock_cnt;
integer clkout_en_time, locked_en_time, lock_cnt_max;
reg clkvco_lk, clkvco_free, clkvco;
integer clkfb_mult_tl;
real clkout0_ps_tmp;
reg fbclk_tmp, clkfb_src;

reg rst_in1, rst_unlock, rst_on_loss;
time rst_edge, rst_ht;

reg fb_delay_found, fb_delay_found_tmp;
reg clkfb_tst;
real fb_delay_max;
time fb_delay, clkvco_delay, val_tmp, dly_tmp,  fbm1_comp_delay;
time clkin_edge, delay_edge;

real     period_clkin, clkin_period_tmp;
integer  clkin_period [4:0];
integer  period_vco, period_vco_half, period_vco_half1, period_vco_half_rm;
integer  period_vco_half_rm1, period_vco_half_rm2;
integer  period_vco_rm, period_vco_cmp_cnt, clkvco_rm_cnt;
integer  period_vco_cmp_flag;
integer  period_vco_max, period_vco_min;
integer  period_vco1, period_vco2, period_vco3, period_vco4;
integer  period_vco5, period_vco6, period_vco7;
integer  period_vco_target, period_vco_target_half;
integer  period_fb, period_avg;

real    clkvco_freq_init_chk, clkfbm1pm_rl;
real    tmp_real;
integer i, j, i1, i2;
integer md_product, m_product, m_product2, period_vco_rm2;
integer clkin_lost_val, clkfb_lost_val;

time pll_locked_delay, clkin_dly_t, clkfb_dly_t;
reg clkpll_dly, clkfbin_dly;
wire pll_unlock;
reg pll_locked_tmp1, pll_locked_tmp2;
reg lock_period;
reg pll_locked_tm, unlock_recover;
reg clkin_stopped, clkfb_stopped;
reg clkpll_jitter_unlock;
integer clkin_lost_cnt, clkfb_lost_cnt;
integer  clkin_jit, REF_CLK_JITTER_MAX_tmp;

wire REL, DWE, DEN, DCLK, rel_o_mux_clk_tmp, clka1_in, clkb1_in;
wire init_trig, clkpll_tmp, clkpll, clk0in, clk1in, clk2in, clk3in, clk4in, clk5in;
wire clkfbm1in, clkfbm1ps_en;


reg clkout0_out;
reg clkout1_out;
reg clkout2_out;
reg clkout3_out;
reg clkout4_out;
reg clkout5_out;

reg clka1_out, clkb1_out, clka1d2_out, clka1d4_out, clka1d8_out;
reg clkdiv_rel_rst, qrel_o_reg1, qrel_o_reg2, qrel_o_reg3, rel_o_mux_sel;
reg pmcd_mode;
reg chk_ok;
reg sim_d;

wire rel_rst_o, rel_o_mux_clk;
wire clk0ps_en, clk1ps_en, clk2ps_en, clk3ps_en, clk4ps_en, clk5ps_en;

reg [7:0] clkout_mux;
reg [2:0] clk0pm_sel, clk1pm_sel, clk2pm_sel, clk3pm_sel, clk4pm_sel, clk5pm_sel;
reg [2:0] clkfbm1pm_sel, clkfbm2pm_sel, clkfbmpm_sel;
reg clk0_edge, clk1_edge, clk2_edge, clk3_edge, clk4_edge, clk5_edge;
reg clkfbm1_edge, clkfbm2_edge, clkind_edge;
reg clk0_nocnt, clk1_nocnt, clk2_nocnt, clk3_nocnt, clk4_nocnt, clk5_nocnt;
reg clkfbm1_nocnt, clkfbm2_nocnt, clkind_nocnt;
reg clkind_edgei, clkind_nocnti; 
reg [5:0] clk0_dly_cnt, clkout0_dly;
reg [5:0] clk1_dly_cnt, clkout1_dly;
reg [5:0] clk2_dly_cnt, clkout2_dly;
reg [5:0] clk3_dly_cnt, clkout3_dly;
reg [5:0] clk4_dly_cnt, clkout4_dly;
reg [5:0] clk5_dly_cnt, clkout5_dly;
reg [6:0] clk0_ht, clk0_lt;
reg [6:0] clk1_ht, clk1_lt;
reg [6:0] clk2_ht, clk2_lt;
reg [6:0] clk3_ht, clk3_lt;
reg [6:0] clk4_ht, clk4_lt;
reg [6:0] clk5_ht, clk5_lt;
reg [5:0] clkfbm1_dly_cnt, clkfbm1_dly;
reg [5:0] clkfbm2_dly_cnt, clkfbm2_dly;
reg [5:0] clkfbm_dly;
reg [6:0] clkfbm1_ht, clkfbm1_lt;
reg [6:0] clkfbm2_ht, clkfbm2_lt;
reg [7:0] clkind_ht = 8'b00000001;
reg [7:0] clkind_lt = 8'b00000001;
reg [7:0] clkind_hti, clkind_lti;
reg [7:0] clk0_ht1, clk0_cnt, clk0_div, clk0_div1;
reg [7:0] clk1_ht1, clk1_cnt, clk1_div, clk1_div1;
reg [7:0] clk2_ht1, clk2_cnt, clk2_div, clk2_div1;
reg [7:0] clk3_ht1, clk3_cnt, clk3_div, clk3_div1;
reg [7:0] clk4_ht1, clk4_cnt, clk4_div, clk4_div1;
reg [7:0] clk5_ht1, clk5_cnt, clk5_div, clk5_div1;
reg [7:0] clkfbm1_ht1, clkfbm1_cnt, clkfbm1_div, clkfbm1_div1;
reg [7:0] clkfbm2_ht1, clkfbm2_cnt, clkfbm2_div, clkfbm2_div1;
reg [7:0] clkfbm_div;
reg [7:0]  clkind_div, clkind_divi;
reg [3:0] pll_cp, pll_res;
reg [1:0] pll_lfhf;
reg [1:0] pll_cpres = 2'b01;
wire  clkinsel_tmp;
real  clkin_chk_t1, clkin_chk_t2;

reg notifier;
wire [15:0] do_out, di_in;
wire clkin1_in, clkin2_in, clkfb_in, clkinsel_in, dwe_in, den_in, dclk_in;
wire [4:0] daddr_in;
wire rel_in, gsr_in, rst_input;

//  `ifndef XIL_TIMING

      assign LOCKED = locked_out1;
      assign DRDY = drdy_out1;
      assign DO = do_out;
      assign clkin1_in = CLKIN1;
      assign clkin2_in = CLKIN2;
      assign clkfb_in = CLKFBIN;
      assign clkinsel_in = CLKINSEL;
      assign rst_input = RST;
      assign daddr_in = DADDR;
      assign di_in = DI;
      assign dwe_in = DWE;
      assign den_in = DEN;
      assign dclk_in = DCLK;
      assign rel_in = REL;

      always @(locked_out)
        locked_out1 <= #100 locked_out;

      always @(drdy_out)
        drdy_out1 <= #100 drdy_out;


//  `endif  `ifdef XIL_TIMING

initial begin
    #1;
    if ($realtime == 0) begin
	$display ("Simulator Resolution Error : Simulator resolution is set to a value greater than 1 ps.");
	$display ("In order to simulate the PLL_ADV, the simulator resolution must be set to 1ps or smaller.");
	$finish;
    end
end

initial begin

        case (SIM_DEVICE)
                "VIRTEX5" : sim_d = 0;
                "SPARTAN6" : sim_d = 1 ;
                default : begin
                        sim_d = 0;
                        $display("Attribute Syntax Error : The Attribute SIM_DEVICE on PLL_ADV instance %m is set to %s.  Legal values for this attribute are VIRTEX5 or SPARTAN6.", SIM_DEVICE);
                        $finish;
                end
        endcase

        case (COMPENSATION)
                "SYSTEM_SYNCHRONOUS" : ;
                "SOURCE_SYNCHRONOUS" : ;
                "INTERNAL" : ;
                "EXTERNAL" : ;
                "DCM2PLL" : ;
                "PLL2DCM" : ;
                default : begin
                        $display("Attribute Syntax Error : The Attribute COMPENSATION on PLL_ADV instance %m is set to %s.  Legal values for this attribute are SYSTEM_SYNCHRONOUS, SOURCE_SYNCHRONOUS, INTERNAL, EXTERNAL, DCM2PLL or PLL2DCM.", COMPENSATION);
                        $finish;
                end
        endcase

        case (BANDWIDTH)
                "HIGH" : ;
                "LOW" : ;
                "OPTIMIZED" : ;
                default : begin
                        $display("Attribute Syntax Error : The Attribute BANDWIDTH on PLL_ADV instance %m is set to %s.  Legal values for this attribute are HIGH, LOW or OPTIMIZED.", BANDWIDTH);
                        $finish;
                end
        endcase

         case (CLK_FEEDBACK)
                 "CLKFBOUT" : begin
                              clkfb_src = 0;
                              clkfb_mult_tl = CLKFBOUT_MULT;
                              end
                 "CLKOUT0" : begin
                               clkfb_src = 1;
                               clkfb_mult_tl = CLKFBOUT_MULT * CLKOUT0_DIVIDE;
                             end
                 default : begin
                         $display("Attribute Syntax Error : The Attribute CLK_FEEDBACK on PLL_ADV instance %m is set to %s.  The valid values are CLKFBOUT or CLKOUT0.", CLK_FEEDBACK);
                         $finish;
                 end
         endcase


        case (CLKOUT0_DESKEW_ADJUST)
                "NONE" : ; 
                "PPC" : ;
                default : begin
                        $display("Attribute Syntax Error : The Attribute CLKOUT0_DESKEW_ADJUST on PLL_ADV instance %m is set to %s.  Legal values for this attribute are NONE or PPC.", CLKOUT0_DESKEW_ADJUST);
                        $finish;
                end
        endcase

        case (CLKOUT1_DESKEW_ADJUST)
                "NONE" : ; 
                "PPC" : ;
                 default : begin
                         $display("Attribute Syntax Error : The Attribute CLKOUT1_DESKEW_ADJUST on PLL_ADV instance %m is set to %s.  Legal values for this attribute are NONE or PPC .", CLKOUT1_DESKEW_ADJUST);
                        $finish;
                end
        endcase

        case (CLKOUT2_DESKEW_ADJUST)
                "NONE" : ; 
                "PPC" : ;
                 default : begin
                         $display("Attribute Syntax Error : The Attribute CLKOUT2_DESKEW_ADJUST on PLL_ADV instance %m is set to %s.  Legal values for this attribute are NONE or PPC.", CLKOUT2_DESKEW_ADJUST);
                        $finish;
                end
        endcase

        case (CLKOUT3_DESKEW_ADJUST)
                "NONE" : ; 
                "PPC" : ;
                 default : begin
                         $display("Attribute Syntax Error : The Attribute CLKOUT3_DESKEW_ADJUST on PLL_ADV instance %m is set to %s.  Legal values for this attribute are NONE or PPC.", CLKOUT3_DESKEW_ADJUST);
                        $finish;
                end
        endcase

        case (CLKOUT4_DESKEW_ADJUST)
                "NONE" : ; 
                "PPC" : ;
                 default : begin
                         $display("Attribute Syntax Error : The Attribute CLKOUT4_DESKEW_ADJUST on PLL_ADV instance %m is set to %s.  Legal values for this attribute are NONE or PPC.", CLKOUT4_DESKEW_ADJUST);
                        $finish;
                end
        endcase

        case (CLKOUT5_DESKEW_ADJUST)
                "NONE" : ; 
                "PPC" : ;
                 default : begin
                         $display("Attribute Syntax Error : The Attribute CLKOUT5_DESKEW_ADJUST on PLL_ADV instance %m is set to %s.  Legal values for this attribute are NONE or PPC.", CLKOUT5_DESKEW_ADJUST);
                        $finish;
                end
        endcase

        case (CLKFBOUT_DESKEW_ADJUST)
                "NONE" : ; 
                "PPC" : ;
                 default : begin
                         $display("Attribute Syntax Error : The Attribute CLKFBOUT_DESKEW_ADJUST on PLL_ADV instance %m is set to %s.  Legal values for this attribute are NONE or PPC.", CLKFBOUT_DESKEW_ADJUST);
                        $finish;
                end
        endcase


        case (PLL_PMCD_MODE)
             "TRUE" : pmcd_mode = 1'b1;
             "FALSE" : pmcd_mode = 1'b0;
                default : begin
                        $display("Attribute Syntax Error : The Attribute PLL_PMCD_MODE on PLL_ADV instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE.", PLL_PMCD_MODE);
                        $finish;
                end
        endcase

        tmp_string = "CLKOUT0_DIVIDE"; 
        chk_ok = para_int_pmcd_chk(CLKOUT0_DIVIDE, tmp_string, 1, 128, pmcd_mode, 8);
        tmp_string = "CLKOUT0_PHASE";
        chk_ok = para_real_pmcd_chk(CLKOUT0_PHASE, tmp_string, -360.0, 360.0, pmcd_mode, 0.0);
        tmp_string = "CLKOUT0_DUTY_CYCLE";
        chk_ok = para_real_pmcd_chk(CLKOUT0_DUTY_CYCLE, tmp_string, 0.0, 1.0, pmcd_mode, 0.5);

        tmp_string = "CLKOUT1_DIVIDE";
        chk_ok = para_int_pmcd_chk(CLKOUT1_DIVIDE, tmp_string, 1, 128, pmcd_mode, 4);
        tmp_string = "CLKOUT1_PHASE";
        chk_ok = para_real_pmcd_chk(CLKOUT1_PHASE, tmp_string, -360.0, 360.0, pmcd_mode, 0.0);
        tmp_string = "CLKOUT1_DUTY_CYCLE";
        chk_ok = para_real_pmcd_chk(CLKOUT1_DUTY_CYCLE, tmp_string, 0.0, 1.0, pmcd_mode, 0.5);

        tmp_string = "CLKOUT2_DIVIDE";
        chk_ok = para_int_pmcd_chk(CLKOUT2_DIVIDE, tmp_string, 1, 128, pmcd_mode, 2);
        tmp_string = "CLKOUT2_PHASE";
        chk_ok = para_real_pmcd_chk(CLKOUT2_PHASE, tmp_string, -360.0, 360.0, pmcd_mode, 0.0);
        tmp_string = "CLKOUT2_DUTY_CYCLE";
        chk_ok = para_real_pmcd_chk(CLKOUT2_DUTY_CYCLE, tmp_string, 0.0, 1.0, pmcd_mode, 0.5);

        tmp_string = "CLKOUT3_DIVIDE";
        chk_ok = para_int_pmcd_chk(CLKOUT3_DIVIDE, tmp_string, 1, 128, pmcd_mode, 1);
        tmp_string = "CLKOUT3_PHASE";
        chk_ok = para_real_pmcd_chk(CLKOUT3_PHASE, tmp_string, -360.0, 360.0, pmcd_mode, 0.0);
        tmp_string = "CLKOUT3_DUTY_CYCLE";
        chk_ok = para_real_pmcd_chk(CLKOUT3_DUTY_CYCLE, tmp_string, 0.0, 1.0, pmcd_mode, 0.5);

        tmp_string = "CLKOUT4_DIVIDE";
        chk_ok = para_int_range_chk(CLKOUT4_DIVIDE, tmp_string,  1, 128);
        tmp_string = "CLKOUT4_PHASE";
        chk_ok = para_real_range_chk(CLKOUT4_PHASE, tmp_string,  -360.0, 360.0);
        tmp_string = "CLKOUT4_DUTY_CYCLE";
        chk_ok = para_real_range_chk(CLKOUT4_DUTY_CYCLE, tmp_string,  0.0, 1.0);

        tmp_string = "CLKOUT5_DIVIDE";
        chk_ok = para_int_range_chk (CLKOUT5_DIVIDE, tmp_string, 1, 128);
        tmp_string = "CLKOUT5_PHASE";
        chk_ok = para_real_range_chk(CLKOUT5_PHASE, tmp_string, -360.0, 360.0);
        tmp_string = "CLKOUT5_DUTY_CYCLE";
        chk_ok = para_real_range_chk (CLKOUT5_DUTY_CYCLE, tmp_string,  0.0, 1.0);

        tmp_string = "CLKFBOUT_MULT";
        chk_ok = para_int_pmcd_chk(CLKFBOUT_MULT, tmp_string, 1, 74, pmcd_mode, 1);
         if (clkfb_src == 1)  begin
            if (CLKFBOUT_PHASE > 0.001 || CLKFBOUT_PHASE < - 0.001)
               $display("Attribute Syntax Error : The Attribute CLKFBOUT_PHASE on PLL_ADV instance %m is set to %f.  This attribute should be set to 0.0 when attribute CLKFB_FEEDBACK set to CLKOUT0.", CLKFBOUT_PHASE);
         end
         else begin
            tmp_string = "CLKFBOUT_PHASE";
            chk_ok = para_real_pmcd_chk(CLKFBOUT_PHASE, tmp_string, -360.0, 360.0, pmcd_mode, 0.0);
        end
        tmp_string = "DIVCLK_DIVIDE";
        chk_ok = para_int_range_chk (DIVCLK_DIVIDE, tmp_string, 1, 52);

        tmp_string = "REF_JITTER";
        chk_ok = para_real_range_chk (REF_JITTER, tmp_string, 0.0, 0.999);
        clkin_period_tmp = CLKIN1_PERIOD;
        if (((clkin_period_tmp < 1.0) || (clkin_period_tmp > 52.630)) && (pmcd_mode == 0) && (clkinsel_in == 1)) begin
            $display("Attribute Syntax Error : CLKIN1_PERIOD is not in range 1.0 ... 52.630.");
        end 
        clkin_period_tmp = CLKIN2_PERIOD;
          if (((clkin_period_tmp < 1.0) || (clkin_period_tmp > 52.630)) && (pmcd_mode == 0) && (clkinsel_in == 0)) begin
            $display("Attribute Syntax Error : CLKIN2_PERIOD is not in range 1.0 ... 52.630.");
         end 


        case (RESET_ON_LOSS_OF_LOCK)
                "FALSE" : rst_on_loss = 1'b0;
//                "TRUE" : if (pmcd_mode) rst_on_loss = 1'b0; else rst_on_loss = 1'b1;
                default : begin
                        $display("Attribute Syntax Error : The Attribute RESET_ON_LOSS_OF_LOCK on PLL_ADV instance %m is set to %s.  This attribute must always be set to FALSE for PLL_ADV to function correctly. Please correct the setting for the attribute and re-run the simulation.", RESET_ON_LOSS_OF_LOCK);
                        $finish;
                end
        endcase

         if (clkfb_src == 1 && clkfb_mult_tl > 64 ) begin
              $display("Attribute Syntax Error : The Attributes CLKFBOUT_MULT and CLKOUT0_DIVIDE on PLL_ADV instance %m are set to %d and %d.  The product of CLKFBOUT_MULT and CLKOUT0_DIVIDE is %d, which is over the 64 limit.", CLKFBOUT_MULT, CLKOUT0_DIVIDE, clkfb_mult_tl);
              $finish;
         end

   pll_lfhf = 2'b11;

   case (clkfb_mult_tl)
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


   tmp_string = "DIVCLK_DIVIDE";
   chk_ok = para_int_range_chk (DIVCLK_DIVIDE, tmp_string, D_MIN, D_MAX);

   tmp_string = "CLKFBOUT_MULT";
   chk_ok = para_int_range_chk (CLKFBOUT_MULT, tmp_string, M_MIN, M_MAX);

   tmp_string = "CLKOUT0_DUTY_CYCLE";
   chk_ok = clkout_duty_chk (CLKOUT0_DIVIDE, CLKOUT0_DUTY_CYCLE, tmp_string);
   tmp_string = "CLKOUT1_DUTY_CYCLE";
   chk_ok = clkout_duty_chk (CLKOUT1_DIVIDE, CLKOUT1_DUTY_CYCLE, tmp_string);
   tmp_string = "CLKOUT2_DUTY_CYCLE";
   chk_ok = clkout_duty_chk (CLKOUT2_DIVIDE, CLKOUT2_DUTY_CYCLE, tmp_string);
   tmp_string = "CLKOUT3_DUTY_CYCLE";
   chk_ok = clkout_duty_chk (CLKOUT3_DIVIDE, CLKOUT3_DUTY_CYCLE, tmp_string);
   tmp_string = "CLKOUT4_DUTY_CYCLE";
   chk_ok = clkout_duty_chk (CLKOUT4_DIVIDE, CLKOUT4_DUTY_CYCLE, tmp_string);
   tmp_string = "CLKOUT5_DUTY_CYCLE";
   chk_ok = clkout_duty_chk (CLKOUT5_DIVIDE, CLKOUT5_DUTY_CYCLE, tmp_string);

   period_vco_max = 1000000 / VCOCLK_FREQ_MIN;
   period_vco_min = 1000000 / VCOCLK_FREQ_MAX;
   period_vco_target = 1000000 / VCOCLK_FREQ_TARGET;
   period_vco_target_half = period_vco_target / 2;
   fb_delay_max = MAX_FEEDBACK_DELAY * MAX_FEEDBACK_DELAY_SCALE;
//   md_product = CLKFBOUT_MULT * DIVCLK_DIVIDE;
//   m_product = CLKFBOUT_MULT;
//   m_product2 = CLKFBOUT_MULT / 2;
   md_product = clkfb_mult_tl * DIVCLK_DIVIDE;
   m_product = clkfb_mult_tl;
   m_product2 = clkfb_mult_tl / 2;
   clkout_en_time = PLL_LOCK_TIME + 2; 
   locked_en_time = md_product +  clkout_en_time + 2;  // for DCM 3 cycle reset requirement
   lock_cnt_max = locked_en_time + 10 + CLKFBOUT_MULT;
   REF_CLK_JITTER_MAX_tmp = REF_CLK_JITTER_MAX;

     clk_out_para_cal (clk0_ht, clk0_lt, clk0_nocnt, clk0_edge, CLKOUT0_DIVIDE, CLKOUT0_DUTY_CYCLE);
   clk_out_para_cal (clk1_ht, clk1_lt, clk1_nocnt, clk1_edge, CLKOUT1_DIVIDE, CLKOUT1_DUTY_CYCLE);
   clk_out_para_cal (clk2_ht, clk2_lt, clk2_nocnt, clk2_edge, CLKOUT2_DIVIDE, CLKOUT2_DUTY_CYCLE);
   clk_out_para_cal (clk3_ht, clk3_lt, clk3_nocnt, clk3_edge, CLKOUT3_DIVIDE, CLKOUT3_DUTY_CYCLE);
   clk_out_para_cal (clk4_ht, clk4_lt, clk4_nocnt, clk4_edge, CLKOUT4_DIVIDE, CLKOUT4_DUTY_CYCLE);
   clk_out_para_cal (clk5_ht, clk5_lt, clk5_nocnt, clk5_edge, CLKOUT5_DIVIDE, CLKOUT5_DUTY_CYCLE);
    if (clkfb_src ==1) begin
       clk_out_para_cal (clkfbm2_ht, clkfbm2_lt, clkfbm2_nocnt, clkfbm2_edge, CLKFBOUT_MULT, 0.50);
       clkout0_ps_tmp = CLKOUT0_PHASE;
       clkfbm1_ht = 6'b0;
       clkfbm1_lt = 6'b0;
       clkfbm1_nocnt = 1;
       clkfbm1_edge = 0;
    end
    else begin
   clk_out_para_cal (clkfbm1_ht, clkfbm1_lt, clkfbm1_nocnt, clkfbm1_edge, CLKFBOUT_MULT, 0.50);
       clkout0_ps_tmp = CLKOUT0_PHASE;
       clkfbm2_ht = 6'b0;
       clkfbm2_lt = 6'b0;
       clkfbm2_nocnt = 1;
       clkfbm2_edge = 0;
    end

   clk_out_para_cal (clkind_ht, clkind_lt, clkind_nocnt, clkind_edge, DIVCLK_DIVIDE, 0.50);
   tmp_string = "CLKOUT0_PHASE";
   clkout_dly_cal (clkout0_dly, clk0pm_sel, CLKOUT0_DIVIDE, clkout0_ps_tmp, tmp_string);
   tmp_string = "CLKOUT1_PHASE";
   clkout_dly_cal (clkout1_dly, clk1pm_sel, CLKOUT1_DIVIDE, CLKOUT1_PHASE, tmp_string);
   tmp_string = "CLKOUT2_PHASE";
   clkout_dly_cal (clkout2_dly, clk2pm_sel, CLKOUT2_DIVIDE, CLKOUT2_PHASE, tmp_string);
   tmp_string = "CLKOUT3_PHASE";
   clkout_dly_cal (clkout3_dly, clk3pm_sel, CLKOUT3_DIVIDE, CLKOUT3_PHASE, tmp_string);
   tmp_string = "CLKOUT4_PHASE";
   clkout_dly_cal (clkout4_dly, clk4pm_sel, CLKOUT4_DIVIDE, CLKOUT4_PHASE, tmp_string);
   tmp_string = "CLKOUT5_PHASE";
   clkout_dly_cal (clkout5_dly, clk5pm_sel, CLKOUT5_DIVIDE, CLKOUT5_PHASE, tmp_string);
   tmp_string = "CLKFBOUT_PHASE";
    if (clkfb_src == 1) begin
       clkfbm2_dly = 6'b0;
       clkfbm2pm_sel = 3'b0;
       clkfbm1_dly = 6'b0;
       clkfbm1pm_sel = 3'b0;
    end
    else begin
       clkout_dly_cal (clkfbm1_dly, clkfbm1pm_sel, CLKFBOUT_MULT, CLKFBOUT_PHASE, tmp_string);
       clkfbm2_dly = 6'b0;
       clkfbm2pm_sel = 3'b0;
    end

   clkind_div = DIVCLK_DIVIDE;

   if (sim_d == 1) begin
   dr_sram[5'b00101] = {clkout0_dly[5], 1'bx, clkout0_dly[4], 1'bx, clkout0_dly[2],
                        clkout0_dly[3], clkout0_dly[1], clkout0_dly[0], 8'bx};
   dr_sram[5'b00110] = {clk1_lt[4], clk1_lt[5], clk1_lt[3], clk1_nocnt, clk1_lt[1],
                       clk1_lt[2], clkout1_dly[5], 1'bx, clkout1_dly[3], clkout1_dly[2], 
                       clkout1_dly[0], clkout1_dly[1], 1'bx, clk0_edge, 2'bx};

   dr_sram[5'b00111] = {1'b1, 2'bx, clk1_ht[5], clk1_ht[3], clk1_ht[4], clk1_ht[2:0], clk1pm_sel[0], 1'bx, clk1_edge, 1'b1, 1'bx, clk1pm_sel[1], clk1pm_sel[2]};

   dr_sram[5'b01000] = {clk2pm_sel[2], 1'b1, clk2_lt[5], clk2pm_sel[1],clk2_nocnt,
                       clk2_lt[4], clk2_lt[3], clk2_lt[2], clk2_lt[0], 
                       clkout2_dly[5], clkout2_dly[3], clkout2_dly[4], 
                       clkout2_dly[1], clkout2_dly[2], clkout2_dly[0], 1'bx};

   dr_sram[5'b01001] = {clkout3_dly[0], clkout3_dly[1], clk0pm_sel[1], 
                       clk0pm_sel[2], 2'bx,  clk2_ht[4], 1'bx, clk2_ht[3], 
                       clk2_ht[2], clk2_ht[0], clk2_ht[1], clk2_edge,
                       clk2pm_sel[0], 2'bx};

   dr_sram[5'b01010] = {1'bx, clk3_edge, 1'b1, 1'bx, clk3pm_sel[1], 
                       clk3pm_sel[2], clk3_lt[5], clk3_lt[4], clk3_nocnt, 
                       clk3_lt[2], clk3_lt[0], clk3_lt[1], clkout3_dly[4], 
                       clkout3_dly[5], clkout3_dly[3], 1'bx};

   dr_sram[5'b01011] = {clk0_lt[5], clkout4_dly[5], clkout4_dly[0],
                       clkout4_dly[3], clkout4_dly[1], clkout4_dly[2],
                       clk0_lt[4], 1'bx, clk3_ht[5:3],  1'bx, clk3_ht[1],
                       clk3_ht[2], clk3pm_sel[0], clk3_ht[0]};

   dr_sram[5'b01100] = {clk4_ht[1], clk4_ht[2], clk4pm_sel[0], clk4_ht[0],
                       1'bx, clk4_edge, 1'bx, 1'b1, clk4pm_sel[2], clk4pm_sel[1],
                       clk4_lt[4], clk4_lt[5], clk4_lt[3], clk4_nocnt,
                       clk4_lt[1], clk4_lt[2]};

   dr_sram[5'b01101] = {clk5_lt[2], clk5_lt[3], clk5_lt[0], clk5_lt[1],
                        clkout5_dly[4], clkout5_dly[5], clkout5_dly[3],
                        clkout5_dly[2], clkout5_dly[1], clk0_lt[3], 
                        clk0_lt[0], clk0_lt[2], 1'bx, clk4_ht[5], 
                        clk4_ht[3], clk4_ht[4]};

   dr_sram[5'b01110] = {clk5_ht[4], clk5_ht[5], clk5_ht[2], clk5_ht[3],
                        clk5_ht[0], clk5_ht[1], clk5pm_sel[0], clk5_edge,
                        2'bx, clk5pm_sel[2], 1'b1, clk5_lt[5], clk5pm_sel[1],
                        clk5_nocnt, clk5_lt[4]};

   dr_sram[5'b01111] = {clkfbm1_lt[4], clkfbm1_lt[5], clkfbm1_lt[3], 
                       clkfbm1_nocnt, clkfbm1_lt[1], clkfbm1_lt[2], clkfbm1_lt[0],
                       clkfbm1_dly[5], clkfbm1_dly[4], clkfbm1_dly[3],
                       clkfbm1_dly[1], clkfbm1_dly[2], clk0_nocnt, clk0_lt[1], 2'bx};

   dr_sram[5'b10000] = {1'bx, clk0_ht[3], clk0_ht[5], clk0_ht[4], clkfbm1_ht[4],
                       clkfbm1_ht[5], clkfbm1_ht[3:0], clkfbm1_edge, 
                       clkfbm1pm_sel[0], 1'b1, 1'bx, clkfbm1pm_sel[1], clkfbm1pm_sel[2]};
   dr_sram[5'b10001] = {clkfbm2_lt[0], clkfbm2_dly[3], clkfbm2_ht[2], clkfbm2_ht[1],
                       clkfbm2_lt[1], clkfbm2_ht[4], clk3_lt[3], clkout3_dly[2], 
                       clk2_ht[5], clk2_lt[1], clkout1_dly[4], clk1_lt[0], 
                       clk0_ht[0], clk0pm_sel[0], clk0_ht[2], clk0_ht[1]};
   dr_sram[5'b10010] = {4'bx, clkout5_dly[0], clkfbm1_dly[0], clk4_lt[0], 
                       clkout4_dly[4], 4'bx, clkfbm2_nocnt, 1'bx, clkfbm2_dly[2],
                       clkfbm2_lt[4]};
   dr_sram[5'b10011] = {clkind_ht[5], clkfbm2_ht[3], clkind_ht[4], 1'bx, 
                       clkind_ht[1], clkind_ht[2], clkind_lt[0], 1'bx, 
                       clkind_lt[5], clkind_lt[2], 1'bx, clkind_edge, 4'bx};
  dr_sram[5'b10100] = {6'bx,  pll_res[1], pll_res[3], 
                       pll_res[0], pll_cpres[0], pll_cpres[1], clkfbm2_dly[1],
                       clkfbm2_lt[3], clkfbm2_ht[0], clkfbm2_dly[4], 
                       clkfbm2_dly[0], clkfbm2_dly[5], clkfbm2_ht[5]};
   dr_sram[5'b10101] = {1'bx, clkind_nocnt, 7'bx, clkfbm2_edge, clkfbm2_lt[5], 
                       clkfbm2_lt[2], 4'bx};
   dr_sram[5'b10110] = {4'bx, pll_lfhf[0], 2'bx, clkind_ht[3], clkind_lt[1], 
                       1'bx, clkind_ht[0], 1'bx, clkind_lt[3], 1'bx, 
                       clkind_lt[4], 1'bx};
   dr_sram[5'b10111] = {6'bx, pll_lfhf[1], 9'bx};
   dr_sram[5'b11000] = {pll_res[0], pll_res[1], pll_cp[0], 1'bx, pll_cp[2], pll_cp[1], pll_cp[0], pll_cp[3], pll_res[3], pll_res[2], 6'bx};

   end
   else begin
   dr_sram[5'b11100] = {8'bx, clk0_edge, clk0_nocnt, clkout0_dly[5:0]};
   dr_sram[5'b11011] = {clk0pm_sel[2:0], 1'b1, clk0_ht[5:0], clk0_lt[5:0]};
   dr_sram[5'b11010] = {8'bx, clk1_edge, clk1_nocnt, clkout1_dly[5:0]};
   dr_sram[5'b11001] = {clk1pm_sel[2:0], 1'b1, clk1_ht[5:0], clk1_lt[5:0]};
   dr_sram[5'b10111] = {8'bx, clk2_edge, clk2_nocnt, clkout2_dly[5:0]};
   dr_sram[5'b10110] = {clk2pm_sel[2:0], 1'b1, clk2_ht[5:0], clk2_lt[5:0]};
   dr_sram[5'b10101] = {8'bx, clk3_edge, clk3_nocnt, clkout3_dly[5:0]};
   dr_sram[5'b10100] = {clk3pm_sel[2:0], 1'b1, clk3_ht[5:0], clk3_lt[5:0]};
   dr_sram[5'b10011] = {8'bx, clk4_edge, clk4_nocnt, clkout4_dly[5:0]};
   dr_sram[5'b10010] = {clk4pm_sel[2:0], 1'b1, clk4_ht[5:0], clk4_lt[5:0]};
   dr_sram[5'b01111] = {8'bx, clk5_edge, clk5_nocnt, clkout5_dly[5:0]};
   dr_sram[5'b01110] = {clk5pm_sel[2:0], 1'b1, clk5_ht[5:0], clk5_lt[5:0]};
   dr_sram[5'b01101] = {8'bx, clkfbm1_edge, clkfbm1_nocnt, clkfbm1_dly[5:0]};
   dr_sram[5'b01100] = {clkfbm1pm_sel[2:0], 1'b1, clkfbm1_ht[5:0], clkfbm1_lt[5:0]};
   dr_sram[5'b01010] = {8'bx, clkfbm2_edge, clkfbm2_nocnt, clkfbm2_dly[5:0]};
   dr_sram[5'b01001] = {4'bx,  clkfbm2_ht[5:0], clkfbm2_lt[5:0]};

   dr_sram[5'b00110] = {2'bx, clkind_edge, clkind_nocnt, clkind_ht[5:0], clkind_lt[5:0]};
   dr_sram[5'b00001] = {8'bx, pll_lfhf, pll_cpres, pll_cp};
   dr_sram[5'b00000] = {6'bx, pll_res, 6'bx};
   end


// **** PMCD *******

//*** Clocks MUX

        case (RST_DEASSERT_CLK)
             "CLKIN1" : rel_o_mux_sel = 1'b1;
             "CLKFBIN" : rel_o_mux_sel = 1'b0;
            default : begin
                          $display("Attribute Syntax Error : The attribute RST_DEASSERT_CLK on PLL_ADV instance %m is set to %s.  Legal values for this attribute are CLKIN1 and CLKFBIN.", RST_DEASSERT_CLK);
                          $finish;
                      end
        endcase

//*** CLKDIV_RST
        case (EN_REL)
              "FALSE" : clkdiv_rel_rst = 1'b0;
              "TRUE" : clkdiv_rel_rst = 1'b1;
            default : begin
                          $display("Attribute Syntax Error : The attribute EN_REL on PLL_ADV instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EN_REL);
                          $finish;
                      end
        endcase


end

initial begin
  rst_in1 = 0;
  rst_unlock = 0;
  clkin_period[0] = 0;
  clkin_period[1] = 0;
  clkin_period[2] = 0;
  clkin_period[3] = 0;
  clkin_period[4] = 0;
  period_avg = 0;
  period_fb = 0;
  fb_delay = 0;
  clkfbm1_div = 1;
  clkfbm1_div1 = 0;
  clkfbm2_div = 1;
  clkfbm_div = 1;
  clkvco_delay = 0;
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
  clkvco_rm_cnt = 0;
  fb_delay_found = 0;
  fb_delay_found_tmp = 0;
  clkin_edge = 0;
  delay_edge = 0;
  clkvco_free = 0;
  clkvco_lk = 0;
  fbclk_tmp = 0;
  clkfb_tst = 0;
  clkout_cnt = 0;
  clkout_en = 0;
  clkout_en0 = 0;
  clkout_en0_tmp = 0;
  clkout_en1 = 0;
  pll_locked_tmp1  = 0;
  pll_locked_tmp2  = 0;
  pll_locked_tm = 0;
  pll_locked_delay = 0;
  clkout_mux = 3'b0;
  unlock_recover = 0;
  clkin_lost_val = 0;
  clkin_lost_val = 0;
  clk_osc = 0;
  clkin_p = 0;
  clkfb_p = 0;
  clkin_lost_cnt = 0;
  clkfb_lost_cnt = 0;
  clkin_stopped = 0;
  clkfb_stopped = 0;
  clkpll_jitter_unlock = 0;
  clkin_jit = 0;
  clkin_cnt = 0;
  clkin_lock_cnt = 0;
  clkpll_dly = 0;
  clkfbin_dly = 0;
  lock_period = 0;
  rst_edge = 0;
  rst_ht = 0;
  drdy_out = 0;
  drp_lock = 0;
  drp_lock1 = 0;
  clkout0_out = 0;
  clkout1_out = 0;
  clkout2_out = 0;
  clkout3_out = 0;
  clkout4_out = 0;
  clkout5_out = 0;
  clka1_out = 1'b0;
  clkb1_out = 1'b0;         
  clka1d2_out = 1'b0;
  clka1d4_out = 1'b0;
  clka1d8_out = 1'b0;
  qrel_o_reg1 = 1'b0;
  qrel_o_reg2 = 1'b0;
  qrel_o_reg3 = 1'b0;
  clk0_dly_cnt = 6'b0;
  clk1_dly_cnt = 6'b0;
  clk2_dly_cnt = 6'b0;
  clk3_dly_cnt = 6'b0;
  clk4_dly_cnt = 6'b0;
  clk5_dly_cnt = 6'b0;
  clkfbm1_dly_cnt = 6'b0;
  clk0_cnt = 8'b0;
  clk1_cnt = 8'b0;
  clk2_cnt = 8'b0;
  clk3_cnt = 8'b0;
  clk4_cnt = 8'b0;
  clk5_cnt = 8'b0;
  clkfbm1_cnt = 8'b0;
  clk0_out = 0;
  clk1_out = 0;
  clk2_out = 0;
  clk3_out = 0;
  clk4_out = 0;
  clk5_out = 0;
  clkfb_out = 0;
  clkfbm1_out = 0;
  pwron_int = 1;
  #100000 pwron_int = 0;
end

// PMCD function

//*** asyn RST
    always @(orig_rst_in) 
        if (orig_rst_in == 1'b1) begin
            assign qrel_o_reg1 = 1'b1;
            assign qrel_o_reg2 = 1'b1;
            assign qrel_o_reg3 = 1'b1;
        end
        else if (orig_rst_in == 1'b0) begin
            deassign qrel_o_reg1;
            deassign qrel_o_reg2;
            deassign qrel_o_reg3;
        end

//*** Clocks MUX

    assign rel_o_mux_clk_tmp = rel_o_mux_sel ? clkin1_in : clkfb_in;
    assign rel_o_mux_clk = (pmcd_mode) ? rel_o_mux_clk_tmp : 0;
    assign clka1_in = (pmcd_mode) ? clkin1_in : 0;
    assign clkb1_in = (pmcd_mode) ? clkfb_in : 0;


//*** Rel and Rst
    always @(posedge rel_o_mux_clk) 
        qrel_o_reg1 <= 1'b0;

    always @(negedge rel_o_mux_clk) 
        qrel_o_reg2 <= qrel_o_reg1;

    always @(posedge rel_in) 
        qrel_o_reg3 <= 1'b0;

    assign rel_rst_o = clkdiv_rel_rst ? (qrel_o_reg3 || qrel_o_reg1) : qrel_o_reg1;

//*** CLKA
    always @(clka1_in or qrel_o_reg2)
        if (qrel_o_reg2 == 1'b1)
            clka1_out <= 1'b0;
        else if (qrel_o_reg2 == 1'b0)
            clka1_out <= clka1_in;

//*** CLKB   
    always @(clkb1_in or qrel_o_reg2)
        if (qrel_o_reg2 == 1'b1)
            clkb1_out <= 1'b0;
        else if (qrel_o_reg2 == 1'b0)
            clkb1_out <= clkb1_in;


//*** Clock divider
    always @(posedge clka1_in or posedge rel_rst_o)
        if (rel_rst_o == 1'b1)
            clka1d2_out <= 1'b0;
        else if (rel_rst_o == 1'b0)
            clka1d2_out <= ~clka1d2_out;

    always @(posedge clka1d2_out or posedge rel_rst_o)
        if (rel_rst_o == 1'b1)
            clka1d4_out <= 1'b0;
        else if (rel_rst_o == 1'b0)
            clka1d4_out <= ~clka1d4_out;

    always @(posedge clka1d4_out or posedge rel_rst_o)
        if (rel_rst_o == 1'b1)
            clka1d8_out <= 1'b0;
        else if (rel_rst_o == 1'b0)
            clka1d8_out <= ~clka1d8_out;

   assign CLKOUT5 = (pmcd_mode) ? 0 : clkout5_out;
   assign CLKOUT4 = (pmcd_mode) ? 0 : clkout4_out;
   assign CLKOUT3 = (pmcd_mode) ? clka1_out : clkout3_out;
   assign CLKOUT2 = (pmcd_mode) ? clka1d2_out : clkout2_out;
   assign CLKOUT1 = (pmcd_mode) ? clka1d4_out : clkout1_out;
   assign CLKOUT0 = (pmcd_mode) ? clka1d8_out : clkout0_out;
   assign CLKFBOUT = (pmcd_mode) ? clkb1_out : clkfb_out;
   assign CLKOUTDCM5 = (pmcd_mode) ? 0 : clkout5_out;
   assign CLKOUTDCM4 = (pmcd_mode) ? 0 : clkout4_out;
   assign CLKOUTDCM3 = (pmcd_mode) ? clka1_out : clkout3_out;
   assign CLKOUTDCM2 = (pmcd_mode) ? clka1d2_out : clkout2_out;
   assign CLKOUTDCM1 = (pmcd_mode) ? clka1d4_out : clkout1_out;
   assign CLKOUTDCM0 = (pmcd_mode) ? clka1d8_out : clkout0_out;
   assign CLKFBDCM = (pmcd_mode) ? clkb1_out : clkfb_out;

// PLL  function

   assign #1 clkinsel_tmp = clkinsel_in;
   assign (weak1, strong0) glbl.PLL_LOCKG = (locked_out == 0) ? 0 : p_up;

always @(clkinsel_in ) 
 if (pmcd_mode != 1) begin
  if ($time > 1 && rst_in === 0 && (clkinsel_tmp === 0 || clkinsel_tmp === 1)) begin
      $display("Input Error : PLL input clock can only be switched when RST=1.  CLKINSEL on instance %m at time %t changed when RST low, should change at RST high.", $time);
      $finish;
  end

    clkin_chk_t1 = 1000.0 / CLKIN_FREQ_MIN;
    clkin_chk_t2 = 1000.0 / CLKIN_FREQ_MAX;

  if (clkinsel_in ==1) begin
    if (CLKIN1_PERIOD > clkin_chk_t1 || CLKIN1_PERIOD < clkin_chk_t2) begin
     $display (" Attribute Syntax Error : The attribute CLKIN1_PERIOD is set to %f ns and out the allowed range %f ns to %f ns.", CLKIN1_PERIOD, clkin_chk_t2, clkin_chk_t1);
     $finish;
   end
  end 
  else if (clkinsel_in ==0) begin
    if (CLKIN2_PERIOD > clkin_chk_t1 || CLKIN2_PERIOD < clkin_chk_t2) begin
     $display (" Attribute Syntax Error : The attribute CLKIN2_PERIOD is set to %f ns and out the allowed range %f ns to %f ns.", CLKIN2_PERIOD, clkin_chk_t2, clkin_chk_t1);
     $finish;
   end
  end

  period_clkin =  (clkinsel_in) ? CLKIN1_PERIOD : CLKIN2_PERIOD;
  if (clkfb_src == 1) 
     clkvco_freq_init_chk = ( 1000.0 * CLKFBOUT_MULT * CLKOUT0_DIVIDE) / (period_clkin  * DIVCLK_DIVIDE);
  else
     clkvco_freq_init_chk =  (1000.0 * CLKFBOUT_MULT) / (period_clkin  * DIVCLK_DIVIDE);

   if (clkvco_freq_init_chk > VCOCLK_FREQ_MAX || clkvco_freq_init_chk < VCOCLK_FREQ_MIN) begin
     if (clkfb_src == 1) begin
      $display (" Attribute Syntax Error : The calculation of VCO frequency=%f Mhz. This exceeds the permitted VCO frequency range of %f Mhz to %f Mhz. The VCO frequency is calculated with formula: VCO frequency =  CLKFBOUT_MULT * CLKOUT0_DIVIDE/ (DIVCLK_DIVIDE * CLKIN_PERIOD). Please adjust the attributes to the permitted VCO frequency range.", clkvco_freq_init_chk, VCOCLK_FREQ_MIN, VCOCLK_FREQ_MAX);
      $finish;
     end
     else begin
     $display (" Attribute Syntax Error : The calculation of VCO frequency=%f Mhz. This exceeds the permitted VCO frequency range of %f Mhz to %f Mhz. The VCO frequency is calculated with formula: VCO frequency =  CLKFBOUT_MULT / (DIVCLK_DIVIDE * CLKIN_PERIOD). Please adjust the attributes to the permitted VCO frequency range.", clkvco_freq_init_chk, VCOCLK_FREQ_MIN, VCOCLK_FREQ_MAX);
     $finish;
   end
 end

end

 assign  init_trig = 1;

   
  assign clkpll_tmp = (clkinsel_in) ? clkin1_in : clkin2_in;
  assign clkpll = (pmcd_mode) ? 0 : clkpll_tmp;

  assign orig_rst_in =  rst_input; 

always @(posedge clkpll or posedge orig_rst_in)
  if (orig_rst_in)
     rst_in1 <= 1;
  else
     rst_in1 <= orig_rst_in;

  assign rst_in = (rst_in1 || rst_unlock);
  
  always @(posedge pll_unlock)
  if (rst_on_loss ) begin
     rst_unlock <= 1'b1;
     rst_unlock <= #10000 1'b0;
  end

always @(rst_input )
  if (rst_input==1)
     rst_edge = $time;
  else if (rst_input==0 && rst_edge > 1) begin
     rst_ht = $time - rst_edge;
     if (rst_ht < 10000) 
        $display("Input Error : RST on instance %m at time %t must be asserted at least for 10 ns.", $time);
  end 

//
// DRP port read and write
//

  assign do_out = dr_sram[daddr_lat];

always @(posedge dclk_in or posedge gsr_in)
  if (gsr_in == 1) begin
       drp_lock <= 0;
       drp_lock1 <= 0;
       drdy_out <= 0;
    end
  else begin
    if (den_in == 1) begin
        valid_daddr = addr_is_valid(daddr_in);
        if (drp_lock == 1) begin
          $display(" Warning : DEN is high at PLL_ADV instance %m at time %t. Need wait for DRDY signal before next read/write operation through DRP. ", $time);
        end
        else begin
          drp_lock <= 1;
          daddr_lat <= daddr_in;
        end
 
       if (sim_d == 1) begin
        if (valid_daddr && ( daddr_in >= 5'b00101 && daddr_in <= 5'b11000))
          begin
          end
        else begin
                  $display(" Warning : Address DADDR=%b is unsupported at PLL_ADV instance %m at time %t.  ",  DADDR, $time);
        end
       end 
       else begin
        if (valid_daddr && ( daddr_in == 5'b00110 || daddr_in == 5'b00001 || daddr_in == 5'b00000 ||
                     daddr_in == 5'b01010 || daddr_in == 5'b01001  ||
                         (daddr_in >= 5'b01100 && daddr_in <= 5'b11100 && daddr_in != 5'b10000 && 
                                  daddr_in != 5'b10001 && daddr_in != 5'b11000 ))) begin
              end
        else begin
                  $display(" Warning : Address DADDR=%b is unsupported at PLL_ADV instance %m at time %t.  ",  DADDR, $time);
        end
  
       end


        if (dwe_in == 1) begin          // write process
          if (rst_input == 1) begin

            dr_sram[daddr_in] <= di_in;

            if (sim_d == 1) begin
              if (daddr_in == 5'b00101) begin
                clkout0_dly[5] = di_in[15];
                clkout0_dly[4] = di_in[13];
                clkout0_dly[2] = di_in[11];
                clkout0_dly[3] = di_in[10];
                clkout0_dly[1] = di_in[9];
                clkout0_dly[0] = di_in[8];
              end
              if (daddr_in == 5'b00110) begin
                clk1_lt[4] = di_in[15];
                clk1_lt[5] = di_in[14];
                clk1_lt[3] = di_in[13];
                clk1_nocnt = di_in[12];
                clk1_lt[1] = di_in[11];
                clk1_lt[2] = di_in[10];
                clkout1_dly[5] = di_in[9];
                clkout1_dly[3] = di_in[7];
                clkout1_dly[2] = di_in[6];
                clkout1_dly[0] = di_in[5];
                clkout1_dly[1] = di_in[4];
                clk0_edge = di_in[2];
              end
              if (daddr_in == 5'b00111) begin
                clk1_ht[5] = di_in[12];
                clk1_ht[3] = di_in[11];
                 clk1_ht[4] = di_in[10];
                clk1_ht[2:0] = di_in[9:7];
                clk1pm_sel[0] = di_in[6];
                clk1_edge = di_in[4];
                clk1pm_sel[1] = di_in[1];
                clk1pm_sel[2] = di_in[0];
              end
              if (daddr_in == 5'b01000) begin
                clk2pm_sel[2] = di_in[15];
                clk2_lt[5] = di_in[13];
                clk2pm_sel[1] = di_in[12];
                clk2_nocnt = di_in[11];
                clk2_lt[4] = di_in[10];
                clk2_lt[3] = di_in[9];
                clk2_lt[2] = di_in[8];
                clk2_lt[0] = di_in[7];
                clkout2_dly[5] = di_in[6];
                clkout2_dly[3] = di_in[5];
                clkout2_dly[4] = di_in[4];
                clkout2_dly[1] = di_in[3];
                clkout2_dly[2] = di_in[2];
                clkout2_dly[0] = di_in[1];
              end 
              if (daddr_in == 5'b01001) begin
                clkout3_dly[0] = di_in[15];
                clkout3_dly[1] = di_in[14];
                clk0pm_sel[1] = di_in[13];
                clk0pm_sel[2] = di_in[12];
                clk2_ht[4] = di_in[9];
                clk2_ht[3] = di_in[7];
                clk2_ht[2] = di_in[6];
                clk2_ht[0] = di_in[5];
                clk2_ht[1] = di_in[4];
                clk2_edge = di_in[3];
                clk2pm_sel[0] = di_in[2];
              end
              if (daddr_in == 5'b01010) begin
                clk3_edge = di_in[14];
                clk3pm_sel[1] = di_in[11];
                clk3pm_sel[2] = di_in[10];
                clk3_lt[5] = di_in[9];
                clk3_lt[4] = di_in[8];
                clk3_nocnt = di_in[7];
                clk3_lt[2] = di_in[6];
                clk3_lt[0] = di_in[5];
                clk3_lt[1] = di_in[4];
                clkout3_dly[4] = di_in[3];
                clkout3_dly[5] = di_in[2];
                clkout3_dly[3] = di_in[1];
              end
              if (daddr_in == 5'b01011) begin
                clk0_lt[5] = di_in[15];
                clkout4_dly[5] = di_in[14];
                clkout4_dly[0] = di_in[13];
                clkout4_dly[3] = di_in[12];
                clkout4_dly[1] = di_in[11];
                clkout4_dly[2] = di_in[10];
                clk0_lt[4] = di_in[9];
                clk3_ht[5:3] = di_in[7:5];
                clk3_ht[1] = di_in[3];
                clk3_ht[2] = di_in[2];
                clk3pm_sel[0] = di_in[1];
                clk3_ht[0]  = di_in[0];
              end
              if (daddr_in == 5'b01100) begin
                clk4_ht[1] = di_in[15];
                clk4_ht[2] = di_in[14];
                clk4pm_sel[0] = di_in[13];
                clk4_ht[0] = di_in[12];
                clk4_edge = di_in[10];
                clk4pm_sel[2] = di_in[7];
                clk4pm_sel[1] = di_in[6];
                clk4_lt[4] = di_in[5];
                clk4_lt[5] = di_in[4];
                clk4_lt[3] = di_in[3];
                clk4_nocnt = di_in[2];
                clk4_lt[1] = di_in[1];
                clk4_lt[2] = di_in[0];
              end
              if (daddr_in == 5'b01101) begin
                clk5_lt[2] = di_in[15];
                clk5_lt[3] = di_in[14];
                clk5_lt[0] = di_in[13];
                clk5_lt[1] = di_in[12];
                clkout5_dly[4] = di_in[11];
                clkout5_dly[5] = di_in[10];
                clkout5_dly[3] = di_in[9];
                clkout5_dly[2] = di_in[8];
                clkout5_dly[1] = di_in[7];
                clk0_lt[3] = di_in[6];
                clk0_lt[0] = di_in[5];
                clk0_lt[2] = di_in[4];
                clk4_ht[5] = di_in[2];
                clk4_ht[3] = di_in[1];
                clk4_ht[4] = di_in[0];
              end
              if (daddr_in == 5'b01110) begin
                clk5_ht[4] = di_in[15];
                clk5_ht[5] = di_in[14];
                clk5_ht[2] = di_in[13];
                clk5_ht[3] = di_in[12];
                clk5_ht[0] = di_in[11];
                clk5_ht[1] = di_in[10];
                clk5pm_sel[0] = di_in[9];
                clk5_edge = di_in[8];
                clk5pm_sel[2] = di_in[5];
                clk5_lt[5] = di_in[3];
                clk5pm_sel[1] = di_in[2];
                clk5_nocnt = di_in[1];
                clk5_lt[4] = di_in[0];
              end
              if (daddr_in == 5'b01111) begin
                clkfbm1_lt[4] = di_in[15];
                clkfbm1_lt[5] = di_in[14];
                clkfbm1_lt[3] = di_in[13];
                clkfbm1_nocnt = di_in[12];
                clkfbm1_lt[1] = di_in[11];
                clkfbm1_lt[2] = di_in[10];
                clkfbm1_lt[0] = di_in[9];
                clkfbm1_dly[5] = di_in[8];
                clkfbm1_dly[4] = di_in[7];
                clkfbm1_dly[3] = di_in[6];
                clkfbm1_dly[1] = di_in[5];
                clkfbm1_dly[2] = di_in[4];
                clk0_nocnt = di_in[3];
                clk0_lt[1] = di_in[2];
              end
              if (daddr_in == 5'b10000) begin
                clk0_ht[3] = di_in[14];
                clk0_ht[5] = di_in[13];
                clk0_ht[4] = di_in[12];
                clkfbm1_ht[4] = di_in[11];
                clkfbm1_ht[5] = di_in[10];
                clkfbm1_ht[3:0] = di_in[9:6];
                clkfbm1_edge = di_in[5];
                clkfbm1pm_sel[0] = di_in[4];
                clkfbm1pm_sel[1] = di_in[1];
                clkfbm1pm_sel[2] = di_in[0];
              end
              if (daddr_in == 5'b10001) begin
                clkfbm2_lt[0] = di_in[15];
                clkfbm2_dly[3] = di_in[14];
                clkfbm2_ht[2] = di_in[13];
                clkfbm2_ht[1] = di_in[12];
                clkfbm2_lt[1] = di_in[11];
                clkfbm2_ht[4] = di_in[10];
                clk3_lt[3] = di_in[9];
                clkout3_dly[2] = di_in[8];
                clk2_ht[5] = di_in[7];
                clk2_lt[1] = di_in[6];
                clkout1_dly[4] = di_in[5];
                clk1_lt[0] = di_in[4];
                clk0_ht[0] = di_in[3];
                clk0pm_sel[0] = di_in[2];
                clk0_ht[2] = di_in[1];
                clk0_ht[1] = di_in[0];
              end
              if (daddr_in == 5'b10010) begin
                clkout5_dly[0] = di_in[11];
                clkfbm1_dly[0] = di_in[10];
                clk4_lt[0] = di_in[9];
                clkout4_dly[4] = di_in[8];
                clkfbm2_nocnt = di_in[3];
                clkfbm2_dly[2] = di_in[1];
                clkfbm2_lt[4] = di_in[0];
              end
              if (daddr_in == 5'b10011) begin
                clkind_ht[5] = di_in[15];
                clkfbm2_ht[3] = di_in[14];
                clkind_ht[4] = di_in[13];
                clkind_ht[1] = di_in[11];
                clkind_ht[2] = di_in[10];
                clkind_lt[0] = di_in[9];
                clkind_lt[5] = di_in[7];
                clkind_lt[2] = di_in[6];
                clkind_edge = di_in[4];
                  if (clkind_nocnt == 1)
                       clkind_div = 8'b00000001;
                  else if (clkind_ht[5:0] == 6'b0 && clkind_lt[5:0] == 6'b0)
                       clkind_div = 8'b10000000;
                  else if (clkind_lt[5:0] == 6'b0)
                        clkind_div = 64 + clkind_ht;
                  else if (clkind_ht[5:0] == 6'b0)
                         clkind_div = 64 + clkind_lt;
                  else
                       clkind_div = clkind_ht + clkind_lt;

              end 
              if (daddr_in == 5'b10100) begin
                pll_cpres[0] = di_in[8];
                pll_cpres[1] = di_in[7];
                clkfbm2_dly[1] = di_in[6];
                clkfbm2_lt[3] = di_in[5];
                clkfbm2_ht[0] = di_in[4];
                clkfbm2_dly[4] = di_in[3];
                clkfbm2_dly[0] = di_in[2];
                clkfbm2_dly[5] = di_in[1];
                clkfbm2_ht[5] = di_in[0];
              end
              if (daddr_in == 5'b10101) begin 
                clkind_nocnt = di_in[14];
                clkfbm2_edge = di_in[6];
                clkfbm2_lt[5] = di_in[5];
                clkfbm2_lt[2] = di_in[4];
                  if (clkind_nocnt == 1)
                       clkind_div = 8'b00000001;
                  else if (clkind_ht[5:0] == 6'b0 && clkind_lt[5:0] == 6'b0)
                       clkind_div = 8'b10000000;
                  else if (clkind_lt[5:0] == 6'b0)
                        clkind_div = 64 + clkind_ht;
                  else if (clkind_ht[5:0] == 6'b0)
                         clkind_div = 64 + clkind_lt;
                  else
                       clkind_div = clkind_ht + clkind_lt;

              end
              if (daddr_in == 5'b10110) begin
                pll_lfhf[0] = di_in[11];
                clkind_ht[3] = di_in[8];
                clkind_lt[1] = di_in[7];
                clkind_ht[0] = di_in[5];
                clkind_lt[3] = di_in[3];
                clkind_lt[4] = di_in[1];
                  if (clkind_nocnt == 1)
                       clkind_div = 8'b00000001;
                  else if (clkind_ht[5:0] == 6'b0 && clkind_lt[5:0] == 6'b0)
                       clkind_div = 8'b10000000;
                  else if (clkind_lt[5:0] == 6'b0)
                        clkind_div = 64 + clkind_ht;
                  else if (clkind_ht[5:0] == 6'b0)
                         clkind_div = 64 + clkind_lt;
                  else
                       clkind_div = clkind_ht + clkind_lt;

              end
              if (daddr_in == 5'b10111) begin
                pll_lfhf[1] = di_in[9];
              end
              if (daddr_in == 5'b11000) begin
                pll_res[0] = di_in[15];
                pll_res[1] = di_in[14];
                pll_cp[0] = di_in[13];
                pll_cp[2] = di_in[11];
                pll_cp[1] = di_in[10];
                pll_cp[3] = di_in[9];
                pll_res[3] = di_in[8];
                pll_res[2] = di_in[7];
              end 
            end
            else begin

             if (daddr_in == 5'b11100) 
                 clkout_delay_para_drp (clkout0_dly, clk0_nocnt, clk0_edge, di_in, daddr_in);

             if (daddr_in == 5'b11011)
                 clkout_hl_para_drp (clk0_lt, clk0_ht, clk0pm_sel, di_in, daddr_in);

             if (daddr_in == 5'b11010) 
                 clkout_delay_para_drp (clkout1_dly, clk1_nocnt, clk1_edge, di_in, daddr_in);

             if (daddr_in == 5'b11001)
                 clkout_hl_para_drp (clk1_lt, clk1_ht, clk1pm_sel, di_in, daddr_in);

             if (daddr_in == 5'b10111) 
                 clkout_delay_para_drp (clkout2_dly, clk2_nocnt, clk2_edge, di_in, daddr_in);

             if (daddr_in == 5'b10110)
                 clkout_hl_para_drp (clk2_lt, clk2_ht, clk2pm_sel, di_in, daddr_in);

             if (daddr_in == 5'b10101) 
                 clkout_delay_para_drp (clkout3_dly, clk3_nocnt, clk3_edge, di_in, daddr_in);

             if (daddr_in == 5'b10100)
                 clkout_hl_para_drp (clk3_lt, clk3_ht, clk3pm_sel, di_in, daddr_in);

             if (daddr_in == 5'b10011) 
                 clkout_delay_para_drp (clkout4_dly, clk4_nocnt, clk4_edge, di_in, daddr_in);

             if (daddr_in == 5'b10010)
                 clkout_hl_para_drp (clk4_lt, clk4_ht, clk4pm_sel, di_in, daddr_in);

             if (daddr_in == 5'b01111) 
                 clkout_delay_para_drp (clkout5_dly, clk5_nocnt, clk5_edge, di_in, daddr_in);

             if (daddr_in == 5'b01110)
                 clkout_hl_para_drp (clk5_lt, clk5_ht, clk5pm_sel, di_in, daddr_in);

             if (daddr_in == 5'b01101) 
                 clkout_delay_para_drp (clkfbm1_dly, clkfbm1_nocnt, clkfbm1_edge, di_in, daddr_in);

             if (daddr_in == 5'b01100)
                 clkout_hl_para_drp (clkfbm1_lt, clkfbm1_ht, clkfbm1pm_sel, di_in, daddr_in);

              if (daddr_in == 5'b01010)
                  clkout_delay_para_drp (clkfbm2_dly, clkfbm2_nocnt, clkfbm2_edge, di_in, daddr_in);

              if (daddr_in == 5'b01001)
                  clkout_hl_para_drp (clkfbm2_lt, clkfbm2_ht, clkfbm2pm_sel, di_in, daddr_in);

             if (daddr_in == 5'b00110) begin
                  clkind_lti = {2'b00, di_in[5:0]};
                  clkind_hti = {2'b00, di_in[11:6]};
                  clkind_lt <= clkind_lti;
                  clkind_ht <= clkind_hti;
                  clkind_nocnt <= di_in[12];
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
                  if (clkind_divi > 52 || (clkind_divi < 1 && clkind_nocnti == 0))
                   $display(" Input Error : DI at Address DADDR=%b is %h at PLL_ADV instance %m at time %t. The sum of DI[11:6] and DI[5:0] is %d and over the range of 1 to 52.",  daddr_in, di_in, clkind_divi, $time);
                end
            end
          end  //rst_input
          else begin
                  $display(" Error : RST is low at PLL_ADV instance %m at time %t. RST need to be high when change PLL_ADV paramters through DRP. ", $time);
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

  always @(posedge clkpll or posedge rst_in)
   if (rst_in)
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
   else  begin
       clkin_edge <= $time;
       clkin_period[4] <= clkin_period[3];
       clkin_period[3] <= clkin_period[2];
       clkin_period[2] <= clkin_period[1];
       clkin_period[1] <= clkin_period[0];
       if (clkin_edge != 0 && clkin_stopped == 0) 
          clkin_period[0] <= $time - clkin_edge;
  
       if (pll_unlock == 0)
          clkin_jit <=  $time - clkin_edge - clkin_period[0];
       else
          clkin_jit <= 0;

      if ( (clkin_lock_cnt < lock_cnt_max) && fb_delay_found && pll_unlock == 0)
            clkin_lock_cnt <= clkin_lock_cnt + 1;
      else if (pll_unlock == 1 && rst_on_loss ==0 && pll_locked_tmp1 ==1 ) begin
            clkin_lock_cnt <= locked_en_time;
            unlock_recover <= 1;
      end

      if ( clkin_lock_cnt >= PLL_LOCK_TIME && pll_unlock == 0)
        pll_locked_tm <= 1;

      if ( clkin_lock_cnt == 6 )
        lock_period <= 1;

      if (clkin_lock_cnt >= clkout_en_time) begin
         clkout_en0_tmp <= 1;
      end

      if (clkin_lock_cnt >= locked_en_time)
        pll_locked_tmp1 <= 1;

      if (unlock_recover ==1 && clkin_lock_cnt  >= lock_cnt_max)
        unlock_recover <= 0;
  end

   always @(clkout_en0_tmp)
   if (clkout_en0_tmp==0)
        clkout_en0 = 0;
   else
      @(negedge clkpll)
        clkout_en0 <= #(clkin_period[0]/2) clkout_en0_tmp;

  always @(clkout_en0)
       clkout_en <= #(clkvco_delay) clkout_en0;

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
     assign clkout_en = 0;
  end
  else begin
    deassign pll_locked_tmp2;
    deassign clkout_en0;
    deassign clkout_en;
  end
    
  assign locked_out = (pll_locked_tm && pll_locked_tmp2 && ~pll_unlock && !unlock_recover) ? 1 : 0;


  always @(clkin_period[0] or clkin_period[1] or clkin_period[2] or 
                 clkin_period[3] or clkin_period[4] or period_avg)
    if ( clkin_period[0] != period_avg) 
          period_avg = (clkin_period[0] + clkin_period[1] + clkin_period[2] 
                       + clkin_period[3] + clkin_period[4])/5;

  always @(period_avg or clkind_div or clkfbm_div) begin
   md_product = clkind_div * clkfbm_div;
   m_product = clkfbm_div;
   m_product2 = clkfbm_div / 2;
   period_fb = period_avg * clkind_div;
   period_vco = period_fb / clkfbm_div;
   period_vco_rm = period_fb % clkfbm_div;
   clkin_lost_val = (period_avg * 2) / 500;
   clkfb_lost_val = (period_fb * 2) / 500;
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
   pll_locked_delay = period_fb * clkfbm_div;
   clkin_dly_t =  period_avg * (clkind_div + 1.25);
   clkfb_dly_t = period_fb * 2.25 ;
   period_vco1 = period_vco / 8;
   period_vco2 = period_vco / 4;
   period_vco3 = period_vco * 3/ 8;
   period_vco4 = period_vco / 2;
   period_vco5 = period_vco * 5 / 8;
   period_vco6 = period_vco *3 / 4;
   period_vco7 = period_vco * 7 / 8;
  end

  assign clkvco_lk_rst = ( rst_in == 1  ||  pll_unlock == 1 || pll_locked_tm == 0) ? 1 : 0;
  
  always @(clkvco_lk_rst)
   if (clkvco_lk_rst)
      assign  clkvco_lk = 0;
   else
      deassign clkvco_lk;


  always @(posedge clkpll) 
     if (pll_locked_tm ==1) begin
       clkvco_lk <= 1;
       clkvco_rm_cnt = 0;
       if ( period_vco_cmp_flag == 1) 
          for (i1=1; i1 < m_product; i1=i1+1) begin
               #(period_vco_half) clkvco_lk <= 0;
               if ( clkvco_rm_cnt == 1)
                   #(period_vco_half_rm1) clkvco_lk <= 1;
               else
                   #(period_vco_half_rm) clkvco_lk <= 1;

               if ( clkvco_rm_cnt == period_vco_cmp_cnt) 
                  clkvco_rm_cnt <= 0;
               else
                   clkvco_rm_cnt <= clkvco_rm_cnt + 1;
          end
       else if ( period_vco_cmp_flag == 2)
          for (i1=1; i1 < m_product; i1=i1+1) begin
               #(period_vco_half) clkvco_lk <= 0;
               if ( clkvco_rm_cnt == 1)
                   #(period_vco_half_rm) clkvco_lk <= 1;
               else
                   #(period_vco_half_rm1) clkvco_lk <= 1;

               if ( clkvco_rm_cnt == period_vco_cmp_cnt)
                  clkvco_rm_cnt <= 0;
               else
                   clkvco_rm_cnt <= clkvco_rm_cnt + 1;
          end
       else
          for (i1=1; i1 < m_product; i1=i1+1) begin
               #(period_vco_half) clkvco_lk <= 0;
               #(period_vco_half_rm) clkvco_lk <= 1;
          end

          #(period_vco_half) clkvco_lk <= 0;
       
       if (clkpll == 1) begin 
          for (i1=1; i1 < m_product; i1=i1+1) begin
               #(period_vco_half) clkvco_lk <= 0;
               #(period_vco_half_rm) clkvco_lk <= 1;
          end

           #(period_vco_half) clkvco_lk <= 0;
       end 
       
     end


//  always @(fb_delay or period_vco or clkfbm1_dly or clkfbm1pm_rl) 
  always @(fb_delay or period_vco or clkfbm_dly or clkfbm1pm_rl) 
    if (period_vco > 0) begin
//       val_tmp = period_vco * md_product;
       val_tmp = period_avg * DIVCLK_DIVIDE;
//       if (clkfb_src ==1)
//          fbm1_comp_delay = period_vco * clkfbm_dly;
//        else
          fbm1_comp_delay = period_vco *(clkfbm_dly  + clkfbm1pm_rl );
       dly_tmp = fb_delay + fbm1_comp_delay;
       if ( dly_tmp < val_tmp)
         clkvco_delay = val_tmp - dly_tmp;
       else
         clkvco_delay = val_tmp - dly_tmp % val_tmp ;
    end

  always @(clkfbmpm_sel)
   case (clkfbmpm_sel)
     3'b000 : clkfbm1pm_rl = 0.0;
     3'b001 : clkfbm1pm_rl = 0.125;
     3'b010 : clkfbm1pm_rl = 0.25;
     3'b011 : clkfbm1pm_rl = 0.375;
     3'b100 : clkfbm1pm_rl = 0.50;
     3'b101 : clkfbm1pm_rl = 0.625;
     3'b110 : clkfbm1pm_rl = 0.75;
     3'b111 : clkfbm1pm_rl = 0.875;
   endcase

  always @(clkvco_free )
    if (pmcd_mode != 1 && pll_locked_tm == 0)
      clkvco_free <= #period_vco_target_half ~clkvco_free;
  
  always @(clkvco_lk or clkvco_free or pll_locked_tm)
   if ( pll_locked_tm)
       clkvco <=  #clkvco_delay clkvco_lk;
   else
       clkvco <=  #clkvco_delay clkvco_free;

  always @(clk0_ht or clk0_lt or clk0_nocnt or init_trig or clk0_edge)
       clkout_pm_cal(clk0_ht1, clk0_div, clk0_div1, clk0_ht, clk0_lt, clk0_nocnt, clk0_edge);

  always @(clk1_ht or clk1_lt or clk1_nocnt or init_trig or clk1_edge)
   clkout_pm_cal(clk1_ht1, clk1_div, clk1_div1, clk1_ht, clk1_lt, clk1_nocnt, clk1_edge);

  always @(clk2_ht or clk2_lt or clk2_nocnt or init_trig or clk2_edge)
   clkout_pm_cal(clk2_ht1, clk2_div, clk2_div1, clk2_ht, clk2_lt, clk2_nocnt, clk2_edge);

  always @(clk3_ht or clk3_lt or clk3_nocnt or init_trig or clk3_edge)
   clkout_pm_cal(clk3_ht1, clk3_div, clk3_div1, clk3_ht, clk3_lt, clk3_nocnt, clk3_edge);

  always @(clk4_ht or clk4_lt or clk4_nocnt or init_trig or clk4_edge)
   clkout_pm_cal(clk4_ht1, clk4_div, clk4_div1, clk4_ht, clk4_lt, clk4_nocnt, clk4_edge);

  always @(clk5_ht or clk5_lt or clk5_nocnt or init_trig or clk5_edge)
   clkout_pm_cal(clk5_ht1, clk5_div, clk5_div1, clk5_ht, clk5_lt, clk5_nocnt, clk5_edge);

  always @(clkfbm1_ht or clkfbm1_lt or clkfbm1_nocnt or init_trig or clkfbm1_edge)
   clkout_pm_cal(clkfbm1_ht1, clkfbm1_div, clkfbm1_div1, clkfbm1_ht, clkfbm1_lt, clkfbm1_nocnt, clkfbm1_edge);

   always @(clkfbm2_ht or clkfbm2_lt or clkfbm2_nocnt or init_trig or clkfbm2_edge)
    clkout_pm_cal(clkfbm2_ht1, clkfbm2_div, clkfbm2_div1, clkfbm2_ht, clkfbm2_lt, clkfbm2_nocnt, clkfbm2_edge);

   always @( clkfbm1_div or clkfbm2_div or clk0_div or init_trig)
      if (clkfb_src ==1)
            clkfbm_div = clkfbm2_div * clk0_div;
      else
            clkfbm_div = clkfbm1_div;

   always @( clkfbm1_dly or  clkout0_dly or init_trig)
      if (clkfb_src ==1)
            clkfbm_dly = clkout0_dly;
      else
            clkfbm_dly = clkfbm1_dly;


  always @( clkfbm1pm_sel or clk0pm_sel or init_trig)
     if (clkfb_src ==1)
            clkfbmpm_sel = clk0pm_sel;
     else
            clkfbmpm_sel = clkfbm1pm_sel;

  always @(rst_in)
  if (rst_in)
    assign clkout_mux = 8'b0;
  else 
    deassign clkout_mux;

 always @(clkvco or clkout_en ) 
  if (clkout_en) begin
   clkout_mux[0] <= clkvco;
   clkout_mux[1] <= #(period_vco1) clkvco;
   clkout_mux[2] <= #(period_vco2) clkvco;
   clkout_mux[3] <= #(period_vco3) clkvco;
   clkout_mux[4] <= #(period_vco4) clkvco;
   clkout_mux[5] <= #(period_vco5) clkvco;
   clkout_mux[6] <= #(period_vco6) clkvco;
   clkout_mux[7] <= #(period_vco7) clkvco;
 end
   
 assign clk0in = clkout_mux[clk0pm_sel];
 assign clk1in = clkout_mux[clk1pm_sel];
 assign clk2in = clkout_mux[clk2pm_sel];
 assign clk3in = clkout_mux[clk3pm_sel];
 assign clk4in = clkout_mux[clk4pm_sel];
 assign clk5in = clkout_mux[clk5pm_sel];
 assign clkfbm1in = clkout_mux[clkfbm1pm_sel];

 assign clk0ps_en = (clk0_dly_cnt == clkout0_dly) ? clkout_en : 0;
 assign clk1ps_en = (clk1_dly_cnt == clkout1_dly) ? clkout_en : 0;
 assign clk2ps_en = (clk2_dly_cnt == clkout2_dly) ? clkout_en : 0;
 assign clk3ps_en = (clk3_dly_cnt == clkout3_dly) ? clkout_en : 0;
 assign clk4ps_en = (clk4_dly_cnt == clkout4_dly) ? clkout_en : 0;
 assign clk5ps_en = (clk5_dly_cnt == clkout5_dly) ? clkout_en : 0;
 assign clkfbm1ps_en = (clkfbm1_dly_cnt == clkfbm1_dly) ? clkout_en : 0;

 always  @(negedge clk0in or posedge rst_in) 
     if (rst_in)
        clk0_dly_cnt <= 6'b0;
     else
       if (clk0_dly_cnt < clkout0_dly && clkout_en ==1)
          clk0_dly_cnt <= clk0_dly_cnt + 1;

 always  @(negedge clk1in or posedge rst_in)
     if (rst_in)
        clk1_dly_cnt <= 6'b0;
     else
       if (clk1_dly_cnt < clkout1_dly && clkout_en ==1)
          clk1_dly_cnt <= clk1_dly_cnt + 1;

 always  @(negedge clk2in or posedge rst_in)
     if (rst_in)
        clk2_dly_cnt <= 6'b0;
     else
       if (clk2_dly_cnt < clkout2_dly && clkout_en ==1)
          clk2_dly_cnt <= clk2_dly_cnt + 1;

 always  @(negedge clk3in or posedge rst_in)
     if (rst_in)
        clk3_dly_cnt <= 6'b0;
     else
       if (clk3_dly_cnt < clkout3_dly && clkout_en ==1)
          clk3_dly_cnt <= clk3_dly_cnt + 1;

 always  @(negedge clk4in or posedge rst_in)
     if (rst_in)
        clk4_dly_cnt <= 6'b0;
     else
       if (clk4_dly_cnt < clkout4_dly && clkout_en ==1)
          clk4_dly_cnt <= clk4_dly_cnt + 1;

 always  @(negedge clk5in or posedge rst_in)
     if (rst_in)
        clk5_dly_cnt <= 6'b0;
     else
       if (clk5_dly_cnt < clkout5_dly && clkout_en ==1)
          clk5_dly_cnt <= clk5_dly_cnt + 1;

 always  @(negedge clkfbm1in or posedge rst_in)
     if (rst_in)
        clkfbm1_dly_cnt <= 6'b0;
     else
       if (clkfbm1_dly_cnt < clkfbm1_dly && clkout_en ==1)
          clkfbm1_dly_cnt <= clkfbm1_dly_cnt + 1;

  always @(posedge clk0in or negedge clk0in or posedge rst_in)
     if (rst_in) begin
        clk0_cnt <= 8'b0;
        clk0_out <= 0;
     end
     else if (clk0ps_en) begin
          if (clk0_cnt < clk0_div1)
                clk0_cnt <= clk0_cnt + 1;
             else
                clk0_cnt <= 8'b0; 

           if (clk0_cnt < clk0_ht1)
               clk0_out <= 1;
           else
               clk0_out <= 0;
     end
     else begin
        clk0_cnt <= 8'b0;
        clk0_out <= 0;
     end

  always @(posedge clk1in or negedge clk1in or posedge rst_in)
     if (rst_in) begin
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

  always @(posedge clk2in or negedge clk2in or posedge rst_in)
     if (rst_in) begin
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

  always @(posedge clk3in or negedge clk3in or posedge rst_in)
     if (rst_in) begin
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


  always @(posedge clk4in or negedge clk4in or posedge rst_in)
     if (rst_in) begin
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


  always @(posedge clk5in or negedge clk5in or posedge rst_in)
     if (rst_in) begin
        clk5_cnt <= 8'b0;
        clk5_out <= 0;
     end
     else if (clk5ps_en) begin
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


  always @(posedge clkfbm1in or negedge clkfbm1in or posedge rst_in)
     if (rst_in) begin
        clkfbm1_cnt <= 8'b0;
        clkfbm1_out <= 0;
     end
     else if (clkfbm1ps_en) begin
          if (clkfbm1_cnt < clkfbm1_div1)
                clkfbm1_cnt <= clkfbm1_cnt + 1;
             else
                clkfbm1_cnt <= 8'b0;

           if (clkfbm1_cnt < clkfbm1_ht1)
               clkfbm1_out <= 1;
           else
               clkfbm1_out <= 0;
     end
     else begin
        clkfbm1_cnt <= 8'b0;
        clkfbm1_out <= 0;
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

   always @(clkfbm1_out or clkfb_tst or fb_delay_found)
    if (fb_delay_found == 1)
          clkfb_out =  clkfbm1_out;
    else
          clkfb_out = clkfb_tst;

//
// determine feedback delay
//

//always @(rst_in1)
//  if (rst_in1)
//      assign clkfb_tst = 0;
//  else
//      deassign clkfb_tst;

always @(posedge clkpll )
    if (fb_delay_found_tmp == 0 && pwron_int == 0 && rst_in1 == 0) begin
         clkfb_tst <=  1'b1;
    end
    else
         clkfb_tst <=  1'b0;

  
always @( posedge clkfb_tst or posedge rst_in1 )
  if (rst_in1)
    delay_edge  <= 0;
  else 
    delay_edge <= $time;

always @(posedge clkfb_in or posedge rst_in1 ) 
  if (rst_in1) begin
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

always @(rst_in1)
  if (rst_in1)
     assign fb_delay_found = 0;
  else
     deassign fb_delay_found;

always @(fb_delay_found_tmp or clkvco_delay )
    if (clkvco_delay == 0)
       fb_delay_found <= #1000 fb_delay_found_tmp;
    else
        fb_delay_found <= #(clkvco_delay) fb_delay_found_tmp;


always @(fb_delay)
  if (rst_in1==0 && (fb_delay/1000.0 > fb_delay_max)) begin
            $display("Warning : The feedback delay on PLL_ADV instance %m at time %t is %f ns. It is over the maximun value %f ns.", $time, fb_delay / 1000.0, fb_delay_max);
        end

//
// generate unlock signal
//

always @(clk_osc or rst_in)
    if (rst_in)
      clk_osc <= 0;
    else
      clk_osc <= #OSC_P2 ~clk_osc;

always @(posedge clkpll or negedge clkpll) begin
    clkin_p <= 1;
    clkin_p <= #100 0;
end

always @(posedge clkfb_in or negedge clkfb_in) begin
    clkfb_p <= 1;
    clkfb_p <= #100 0;
end

always @(posedge clk_osc or posedge rst_in or posedge clkin_p)
    if (rst_in == 1 || clkin_p == 1) begin
      clkin_stopped <= 0;
      clkin_lost_cnt <= 0;
    end
    else if (locked_out && pmcd_mode == 0) begin
      if (clkin_lost_cnt < clkin_lost_val) begin
        clkin_lost_cnt <= clkin_lost_cnt + 1;
        clkin_stopped <= 0;
      end
      else
         clkin_stopped <= 1;
    end

always @(posedge clk_osc or posedge rst_in or posedge clkfb_p)
    if (rst_in == 1 || clkfb_p == 1) begin
      clkfb_stopped <= 0;
      clkfb_lost_cnt <= 0;
    end
    else if (locked_out && pmcd_mode == 0) begin
      if (clkfb_lost_cnt < clkfb_lost_val) begin
         clkfb_lost_cnt <= clkfb_lost_cnt + 1;
         clkfb_stopped <= 0;
      end
      else
         clkfb_stopped <= 1;
    end


always @(clkin_jit or rst_in )
  if (rst_in)
      clkpll_jitter_unlock = 0;
  else
   if (  pll_locked_tmp2 && clkfb_stopped == 0 && clkin_stopped == 0) begin
      if ((clkin_jit > REF_CLK_JITTER_MAX_tmp) || (clkin_jit < -REF_CLK_JITTER_MAX_tmp))
        clkpll_jitter_unlock = 1;
      else
         clkpll_jitter_unlock = 0;
   end
   else
         clkpll_jitter_unlock = 0;
      
  assign pll_unlock = (clkin_stopped || clkfb_stopped || clkpll_jitter_unlock) ? 1 : 0; 

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
    $display(" Warning : Attribute %s of PLL_ADV on instance %m is set to %f. Required phase shifting can not be reached since it is over the maximum phase shifting ability of PLL_ADV", clk_ps_name, clk_ps);
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
    $display(" Warning : Attribute %s of PLL_ADV on instance %m is set to %f. Real phase shifting is %f. Required phase shifting can not be reached.", clk_ps_name, clk_ps, clk_ps_rl);

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

real tmp_value;
integer tmp_value1;
real tmp_value2;

begin
   tmp_value = CLKOUT_DIVIDE * CLKOUT_DUTY_CYCLE;
   tmp_value1 = $rtoi(tmp_value * 2) % 2;
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


function  para_int_pmcd_chk;
   input  para_in;
   input reg [160:0] para_name;
   input  range_low;
   input  range_high;
   input  pmcd_mode;
   input  pmcd_value;

    integer para_in;
    integer range_low;
    integer range_high;
    integer pmcd_value;
begin

        if (para_in < range_low || para_in > range_high)
        begin
            $display("Attribute Syntax Error : The Attribute %s on PLL_ADV instance %m is set to %d.  Legal values for this attribute are %d to %d.", para_name, para_in, range_low, range_high);
            $finish;
        end
        else if (pmcd_mode == 1 && para_in != pmcd_value) begin
            $display("Attribute Syntax Error : The Attribute %s on PLL_ADV instance %m is set to %d when attribute PLL_PMCD_MODE is set to TRUE.  Legal values for this attribute is %d when PLL in PMCD MODE.", para_name, para_in, pmcd_value);
            $finish;
        end

   para_int_pmcd_chk = 1'b1;
end
endfunction

function  para_real_pmcd_chk;
   input  para_in;
   input reg [160:0] para_name;
   input  range_low;
   input  range_high;
   input  pmcd_mode;
   input  pmcd_value;

    real para_in;
    real range_low;
    real range_high;
    real pmcd_value;
begin

        if (para_in < range_low || para_in > range_high)
        begin
            $display("Attribute Syntax Error : The Attribute %s on PLL_ADV instance %m is set to %f.  Legal values for this attribute are %f to %f.", para_name, para_in, range_low, range_high);
            $finish;
        end
        else if (pmcd_mode == 1 && para_in != pmcd_value) begin
            $display("Attribute Syntax Error : The Attribute %s on PLL_ADV instance %m is set to %f when attribute PLL_PMCD_MODE is set to TRUE.  Legal values for this attribute is %f when PLL in PMCD MODE.", para_name, para_in, pmcd_value);
            $finish;
        end
 
    para_real_pmcd_chk = 1'b0;
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
           $display("Attribute Syntax Error : The Attribute %s on PLL_ADV instance %m is set to %d.  Legal values for this attribute are %d to %d.", para_name, para_in, range_low, range_high);
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
           $display("Attribute Syntax Error : The Attribute %s on PLL_ADV instance %m is set to %f.  Legal values for this attribute are %f to %f.", para_name, para_in, range_low, range_high);
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
//        clk_div = 8'b00000001;
         clk_div = clk_ht  + clk_lt ;
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
  input [4:0] daddr_in;
begin

//     if (di_in[15:8] != 8'h00) begin
//          $display(" Error : PLL_ADV on instance %m input DI[15:8] is set to %h and need to be set to 00h at address DADDR=%b at time %t.", di_in[15:8], daddr_in, $time); 
//          $finish;
//     end
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
  input [4:0] daddr_in_tmp;
begin
    if (di_in_tmp[12] != 1) begin
         $display(" Error : PLL_ADV on instance %m input DI is %h at address DADDR=%b at time %t. The bit 12 need to be set to 1 .", di_in_tmp, daddr_in_tmp, $time); 
//         $finish;
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
