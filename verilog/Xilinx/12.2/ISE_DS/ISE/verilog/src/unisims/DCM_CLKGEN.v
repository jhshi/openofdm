// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/stan/DCM_CLKGEN.v,v 1.15 2010/01/15 20:44:32 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Function Simulation Library Component
//  /   /                  Digital Clock Manager
// /___/   /\     Filename : DCM_CLKGEN.v
// \   \  /  \    Timestamp : 
//  \___\/\___\
//
// Revision:
//    01/08/06 - Initial version.
//    07/25/08 - Add attributes SPREAD_SPECTRUM, CLKIN_PERIOD. Remove CLK_SOURCE.
//    09/02/08 - Add STATUS[2:1] pin
//    09/23/08 - Change CLKFX_MULTIPLY range to 2 to 256 (CR490109).
//    11/20/08 - Update timeing check.
//    04/10/09 - Progdata pin loads M-1 and D-1. (CR518158)
//    05/15/09 - Remove DFS_BANDWIDTH & PROG_MD_BANDWIDTH attributes (CR521993)
//    06/18/09 - change SPREAD_SPECTRUM values (CR525436)
//    09/30/09 - Add spread sprectrum function. 
//    11/20/09 - Add STATUS[7:0] pin to simprim. (CR538362)
// End Revision


`timescale  1 ps / 1 ps

module DCM_CLKGEN (
  CLKFX,
  CLKFX180,
  CLKFXDV,
  LOCKED,
  PROGDONE,
  STATUS,
  CLKIN,
  FREEZEDCM,
  PROGCLK,
  PROGDATA,
  PROGEN,
  RST
);
  parameter SPREAD_SPECTRUM = "NONE";
  parameter STARTUP_WAIT = "FALSE";
  parameter integer CLKFXDV_DIVIDE = 2;
  parameter integer CLKFX_DIVIDE = 1;
  parameter integer CLKFX_MULTIPLY = 4;
  parameter real CLKFX_MD_MAX = 0.0;
  parameter real CLKIN_PERIOD = 0.0;
  

  output CLKFX180;
  output CLKFX;
  output CLKFXDV;
  output LOCKED;
  output PROGDONE;
  output [2:1] STATUS;

  input CLKIN;
  input FREEZEDCM;
  input PROGCLK;
  input PROGDATA;
  input PROGEN;
  input RST;

  localparam OSC_P2 = 250;

  reg clkfx_out = 0;
  reg clkfx180_out = 0;
  reg clkfxdv_out = 0;
  wire clkfx_out1;
  wire  clkfx180_out1;
  wire clkfxdv_out1;
  reg rst_tmp1 = 0;
  reg rst_tmp2 = 0;
  reg [2:0] rst_reg = 3'b000;
  reg rst_prog = 0;
  reg locked_out = 0;
  reg locked_out_out_u = 0;
  reg progdone_out = 0;
  reg progdone_out_u = 0;
  reg lk_pd = 0;
  reg lk_pd1 = 0;
  reg lk_pd0 = 0;
  reg clkfx_clk = 0;
  reg clkin_ls_out = 0;
  reg clkfx_ls_out = 0;
  reg clk_osc = 0;
  reg clkin_p = 0;
  reg clkfx_p = 0;
  reg [9:0] pg_sf_reg;
  reg [7:0] pg_m_reg;
  reg [7:0] pg_d_reg;

  integer clkin_ls_val = 0;
  integer clkfx_ls_val = 0;
  integer clkin_ls_cnt = 0;
  integer clkfx_ls_cnt = 0;
  integer clkin_pd_init = 1000 * CLKIN_PERIOD;
  integer lk_cnt = 0;
  integer go_cmd = 0;
  integer dcm_en_prog = 0;
  integer pg_cnt = 0;
  integer bit0_flag = 0;
  integer first_time = 1;
  integer attr_err_flag = 0;
  integer period_sample = 0;

  integer clkdv_cnt = 0;
  integer fx_m = CLKFX_MULTIPLY;
  integer fx_mt = CLKFX_MULTIPLY;
  integer fx_d = CLKFX_DIVIDE;
  integer fx_dt = CLKFX_DIVIDE;
  real fx_n, fx_o;
  real    clkfx_md_ratio;
  time clkin_edge = 0;
  time clkin_pd = 0;
  time clkin_pd1 = 0;
  time lk_delay = 0;
  integer spa;
  integer fx_sn = 1024;
  integer fx_sn1 = 512;
  integer fx_sn2 = 512;
  integer fx_sn11 = 256;
  integer fx_sn12 = 256;
  integer fx_sn21 = 256;
  integer fx_sn22 = 256;
  integer spju = 0, spd = 0;
  real sps = 0.0;
  real spst = 0.0;
  real spst_tmp = 0.0;
  real spst_tmp1 = 0.0;
  reg spse = 0;
  reg spse0 = 0;
  reg spse1 = 0;
  integer pd_fx = 0;
  integer pd_fx_i = 0;
  integer pdhf_fx = 0;
  integer pdhf_fx1 = 0;
  integer pdh_fx = 0;
  integer pdh_fx_t = 0;
  real pdh_fx_r = 0.0;
  integer pdhfh_fx = 0;
  integer pdhfh_fx_t = 0;
  integer pdhfh_fx1 = 0;
  integer rm_fx = 0;
  integer rmh_fx = 0;
  integer fxdv_div1;
  integer fxdv_div_half;
  integer rst_flag = 0;
  time rst_pulse_wid = 0;
  time rst_pos_edge = 0;
  
  wire clkin_in;
  wire freezedcm_in;
  wire progclk_in;
  wire progen_in;
  wire progdata_in;
  wire rst_in;
  wire locked_out_out;
  wire rst_ms;
  wire locked_out_ms;
  wire locked_out_ms1;
  reg locked_out_ms2 = 0;
  wire  clkfx_ms_clk;

  reg notifier;

  wire  delay_CLKIN;
  wire  delay_FREEZEDCM;
  wire  delay_PROGCLK;
  wire  delay_PROGDATA;
  wire  delay_PROGEN;

  initial begin
    attr_err_flag = 0;

    case (CLKFXDV_DIVIDE)
      2 : ;
      4 : ;
      8 : ;
      16 : ;
      32 : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute CLKFXDV_DIVIDE on DCM_CLKGEN instance %m is set to %d.  Legal values for this attribute are 2, 4, 8, 16, or 32.", CLKFXDV_DIVIDE);
      attr_err_flag = 1;
      end
    endcase

    if (SPREAD_SPECTRUM == "NONE") begin
       if ((CLKFX_DIVIDE < 1) || (CLKFX_DIVIDE > 256))  begin
	$display("Attribute Syntax Error : The attribute CLKFX_DIVIDE on DCM_CLKGEN instance %m is set to %d.  Legal values for this attribute are 1 ... 256.", CLKFX_DIVIDE);
      attr_err_flag = 1;
       end
    end 
    else begin
       if ((CLKFX_DIVIDE < 1) || (CLKFX_DIVIDE > 4)) begin
	$display("Attribute Syntax Error : The attribute CLKFX_DIVIDE on DCM_CLKGEN instance %m is set to %d.  Legal values for this attribute are 1 ... 4 in spread spectrum mode.", CLKFX_DIVIDE);
      attr_err_flag = 1;
       end
    end

    clkfx_md_ratio = CLKFX_MULTIPLY / CLKFX_DIVIDE;
    if (CLKFX_MD_MAX > 0.0 && clkfx_md_ratio > CLKFX_MD_MAX) begin
        $display("Attribute Syntax Error : The ratio of  CLKFX_MULTIPLY / CLKFX_DIVIDE is %f on DCM_CLKGEN instance %m.  It is over the value %f of attribute CLKFX_MD_MAX.", clkfx_md_ratio, CLKFX_MD_MAX);
      attr_err_flag = 1;
      end

    if (SPREAD_SPECTRUM == "NONE") begin
      if ((CLKFX_MULTIPLY < 2) || (CLKFX_MULTIPLY > 256)) begin
	$display("Attribute Syntax Error : The attribute CLKFX_MULTIPLY on DCM_CLKGEN instance %m is set to %d.  Legal values for this attribute are 2 ... 256.", CLKFX_MULTIPLY);
      attr_err_flag = 1;
      end
    end
    else begin
       if ((CLKFX_MULTIPLY < 2) || (CLKFX_MULTIPLY > 32)) begin
	$display("Attribute Syntax Error : The attribute CLKFX_MULTIPLY on DCM_CLKGEN instance %m is set to %d.  Legal values for this attribute are 2 ... 32 in spread spectrum mode.", CLKFX_MULTIPLY);
      attr_err_flag = 1;
       end
    end

    case (SPREAD_SPECTRUM)
      "NONE" : spa = 0;
      "CENTER_HIGH_SPREAD" : spa = 1;
      "CENTER_LOW_SPREAD" :  spa = 2;
      "VIDEO_LINK_M0" :  spa = 3;
      "VIDEO_LINK_M1" :  spa = 4;
      "VIDEO_LINK_M2" :  spa = 5;
      default : begin
        $display("Attribute Syntax Error : The Attribute SPREAD_SPECTRUM on DCM_CLKGEN instance %m is set to %s.  Legal values for this attribute are NONE, CENTER_HIGH_SPREAD, CENTER_LOW_SPREAD, VIDEO_LINK_M0, VIDEO_LINK_M1, or VIDEO_LINK_M2.", SPREAD_SPECTRUM);
      end
    endcase


    case (STARTUP_WAIT)
      "FALSE" : ;
      "TRUE" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute STARTUP_WAIT on DCM_CLKGEN instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", STARTUP_WAIT);
      attr_err_flag = 1;
      end
    endcase

    #1;
    if ($realtime == 0) begin
	$display ("Simulator Resolution Error : Simulator resolution is set to a value greater than 1 ps.");
	$display ("In order to simulate the DCM_CLKGEN, the simulator resolution must be set to 1ps.");
      attr_err_flag = 1;
    end

   if (attr_err_flag == 1) begin
     #1;
     $finish;
   end

  end

  assign STATUS[1] = clkin_ls_out;
  assign STATUS[2] = clkfx_ls_out;
  assign clkin_in = CLKIN;
  assign freezedcm_in = FREEZEDCM;
  assign progclk_in = PROGCLK;
  assign progen_in = PROGEN;
  assign progdata_in = PROGDATA;
  assign rst_in = RST;
  assign LOCKED = locked_out_out_u;
  assign PROGDONE = progdone_out_u;
  
  always @(locked_out_out)
    locked_out_out_u <= #100 locked_out_out;

  always @(progdone_out)
    progdone_out_u <= #100 progdone_out;

  
    assign CLKFX = clkfx_out1;
    assign CLKFX180 = clkfx180_out1;
    assign CLKFXDV = clkfxdv_out1;

  initial begin
    fxdv_div1 = CLKFXDV_DIVIDE - 1;
    fxdv_div_half = CLKFXDV_DIVIDE/2;
    pg_sf_reg = 10'b0;
    pg_m_reg = fx_m - 1;
    pg_d_reg = fx_d - 1;
  end


// generate master reset signal
//

//  assign rst_ms =  rst_in | rst_prog;
  assign rst_ms =  rst_in;

  always @(posedge clkin_in) begin
   rst_reg[0] <= rst_in;
   rst_reg[1] <= rst_reg[0] & rst_in;
   rst_reg[2] <= rst_reg[1] & rst_reg[0] & rst_in;
  end

  always @(rst_in) begin
    if (rst_in == 1)
       rst_flag <= #1 0;

       rst_tmp1 = rst_in;
       if (rst_tmp1 == 0 && rst_tmp2 == 1) begin
          if ((rst_reg[2] & rst_reg[1] & rst_reg[0]) == 0) begin
             rst_flag = 1;
	    $display("Input Error : RST on DCM_CLKGEN instance %m at time %t must be asserted for 3 CLKIN clock cycles.", $time);
          end
       end
       rst_tmp2 = rst_tmp1; 
  end


// RST less than 3 cycles, lock = x

  assign locked_out_out = (rst_flag == 1) ? 1'bx : locked_out_ms1;


//
// CLKIN period calculation
//

  always @(posedge clkin_in  or posedge rst_in)
  if (rst_in == 1) begin
    clkin_pd <= clkin_pd_init;
    clkin_pd1 <= clkin_pd_init;
    clkin_edge <= 0;
    period_sample <= 0;
  end
  else begin
    if ( freezedcm_in == 0) begin
       clkin_edge <= $time;
       if (clkin_edge != 0) begin
          clkin_pd1 <= clkin_pd;
	       clkin_pd <= $time - clkin_edge;
          period_sample <= 1;
       end
     end
   end

  always @(negedge clkin_in or posedge rst_in) 
  if (rst_in == 1) begin
      lk_cnt <= 0;
      lk_pd0 <= 0;
  end
  else begin 
    if (lk_pd0 == 0) begin
      if (freezedcm_in == 0) begin
        lk_cnt <= lk_cnt + 1;
        if (lk_cnt >= 14) begin
           lk_pd0 <= 1;
           
        end 
      end
      else begin
        if (clkin_pd == clkin_pd1 && period_sample == 1)
           lk_pd0 <= 1;
      end
    end
  end

//
// generate lock signal
//

  always @(posedge lk_pd0 or posedge dcm_en_prog or posedge rst_ms) 
   if (rst_ms == 1) begin
       locked_out <= 0;
       lk_pd1 <= 0; 
       lk_pd <= 0; 
   end
   else begin
       locked_out <= #(lk_delay) lk_pd0;
       lk_pd1 <= #1 lk_pd0; 
       lk_pd <= #2 lk_pd0; 
   end
 
  
   assign locked_out_ms = locked_out;

   assign locked_out_ms1 =  (spa == 0 || (spa >= 3 && spa <= 5 && spse == 0)) ? locked_out : 0;

//
// generate fx clk from CLKIN period
//

  always @(lk_pd0 or clkin_pd or fx_d or fx_m) begin
    lk_delay = (clkin_pd / 2) - 1;
    if (lk_pd0 == 1  ) begin
  	   pd_fx = (clkin_pd * fx_d) / fx_m;
      if (spse0 == 0)
        pd_fx_i = pd_fx;
	   pdhf_fx = pd_fx / 2;
	   pdhf_fx1 = pdhf_fx - 1;
	   rm_fx = pd_fx - pdhf_fx;
      clkin_ls_val = (clkin_pd * 2) / 500;
      clkfx_ls_val = (pd_fx * 2) / 500;
      fx_sn = (fx_m * 1024) / fx_d;
      fx_sn1 = fx_sn / 2;
      fx_sn2 = fx_sn - fx_sn1;
      fx_sn11 = fx_sn1 /2;
      fx_sn12 = fx_sn1 - fx_sn11;
      fx_sn21 = fx_sn2 / 2;
      fx_sn22 =  fx_sn1 + fx_sn21;
      if (spa == 1) begin
         if (fx_d == 1)
             sps = 200.0 / fx_sn;
         else if (fx_d == 2)
             sps = 125.0 / fx_sn;
         else if (fx_d == 3)
             sps = 100.0 / fx_sn;
         else if (fx_d == 4)
             sps = 75.0 / fx_sn;
      end
      else if (spa == 2) begin
         if (fx_d == 1)
             sps = 125.0 / fx_sn;
         else if (fx_d == 2)
             sps = 75.0 / fx_sn;
         else if (fx_d == 3 )
             sps = 65.0 / fx_sn;
         else if (fx_d == 4)
             sps = 60.0 / fx_sn;
      end
      else if (spa == 3)
         sps = 5.4 / fx_m;
      else if (spa == 4)
         sps = 1.1 / fx_m;
      else if (spa == 5)
         sps = 0.3 / fx_m;
    end
  end

//  always @(negedge clkfx_clk or rst_ms or rst_prog or lk_pd1)
  always @(negedge clkfx_clk or rst_ms  or lk_pd1 or lk_pd or posedge spse1 )
    if (rst_ms == 1 ||  lk_pd1 == 0 ) begin
      spju = 0;
      spst = 0;
  	   pdh_fx = pd_fx;
      pdh_fx_t = pd_fx;
  	   pdh_fx_r = pd_fx;
      pdhfh_fx = pd_fx / 2;
      pdhfh_fx_t = pd_fx / 2;
      pdhfh_fx1 = pdhfh_fx - 1;
      rmh_fx = pd_fx - pdhfh_fx;
    end  
    else if (spse1 == 1) begin
      pdh_fx = pd_fx_i;
      pdh_fx_t = pd_fx_i;
      pdh_fx_r = pd_fx_i;
      pdhfh_fx = pd_fx_i / 2;
      pdhfh_fx_t = pd_fx_i / 2;
      pdhfh_fx1 = pdhfh_fx - 1;
      rmh_fx = pd_fx_i - pdhfh_fx;
      spst_tmp = 0.0;
      spst = 0.0;
      spst_tmp1 = 0.0;
    end 
    else begin
      if (lk_pd1 == 1) begin
       if (spa == 1 || spa == 2) begin
        if (spju >= fx_sn) 
          spju <= 0;
        else  
          spju <= spju + 1;

        if (spju == 0 || spju == fx_sn1) begin
            spst <= 0;
            pdh_fx_t = pd_fx;
        end
        else if ((spju > 0 && spju <= fx_sn11) || (spju > fx_sn22 && spju <= fx_sn)) begin
           spst <= spst + sps;
           pdh_fx_t = pd_fx + spst;
        end 
        else if (spju > fx_sn11  && spju <= fx_sn22)   begin
           spst <= spst - sps;
           pdh_fx_t = pd_fx + spst;
        end
      end
      else if (spa >= 3 && spa <= 5 && spse == 1) begin
        spst_tmp =  spst + sps;
        if (spst_tmp >= 1.0 ) begin
            spst_tmp1 =  $rtoi(spst_tmp);
            spst <=  spst_tmp - spst_tmp1;
        end
        else begin
            spst_tmp1 = 0.0;
            spst <= spst_tmp;
     
        end
        if (spd == 1) 
           pdh_fx_t = pdh_fx - spst_tmp1;
        else 
           pdh_fx_t = pdh_fx + spst_tmp1;
      end
           
      if (spa != 0) begin
          pdhfh_fx_t = pdh_fx_t / 2;
  	       pdh_fx <= pdh_fx_t;
          pdhfh_fx <= pdhfh_fx_t;
          pdhfh_fx1 <= pdhfh_fx_t - 1;
          rmh_fx <= pdh_fx_t - pdhfh_fx_t;
      end
     end
    end

  always @(clkfx_clk or posedge locked_out_ms or posedge rst_ms)
    if (rst_ms == 1)  begin
       clkfx_clk = 0;
       first_time <= 1;
    end
    else begin
       if (locked_out_ms == 1) begin
         if (first_time == 1) begin
             clkfx_clk <= 1;
             first_time <= 0;
         end
         else if (clkfx_clk == 1) begin
           if (spa == 0 || (spse == 0 && spa >= 3 && spa <= 5)) 
             clkfx_clk <= #(pdhf_fx) 0;
           else
             clkfx_clk <= #(pdhfh_fx) 0;
         end
         else if (clkfx_clk == 0) begin
           if (spa == 0 || (spse == 0 && spa >= 3 && spa <= 5)) 
             clkfx_clk <= #(rm_fx) 1;
           else
             clkfx_clk <= #(rmh_fx) 1;
         end
       end
    end
       

   always @(clk_osc or rst_ms)
   if (rst_ms)
     clk_osc <= 0;
   else
     clk_osc <= #OSC_P2 ~clk_osc;

  always @(posedge clkin_in or negedge clkin_in) begin
    clkin_p <= 1;
    clkin_p <= #100 0;
  end

  always @(posedge clkfx_out or negedge clkfx_out) begin
    clkfx_p <= 1;
    clkfx_p <= #100 0;
  end

  always @(posedge clk_osc or posedge rst_ms or posedge clkin_p)
    if (rst_ms == 1 || clkin_p == 1) begin
      clkin_ls_out <= 0;
      clkin_ls_cnt <= 0;
    end
    else if (locked_out && freezedcm_in == 0) begin
      if (clkin_ls_cnt < clkin_ls_val) begin
         clkin_ls_cnt <= clkin_ls_cnt + 1;
         clkin_ls_out <= 0;
      end
      else
         clkin_ls_out <= 1;
    end

  always @(posedge clk_osc or posedge rst_ms or posedge clkfx_p)
    if (rst_ms == 1 || clkfx_p == 1) begin
      clkfx_ls_out <= 0;
      clkfx_ls_cnt <= 0;
    end
    else if (locked_out && spa == 0) begin
      if (clkfx_ls_cnt < clkfx_ls_val) begin
         clkfx_ls_cnt <= clkfx_ls_cnt + 1;
         clkfx_ls_out <= 0;
      end
      else
         clkfx_ls_out <= 1;
    end

//
// generate all output signal
//

     assign clkfx_ms_clk = clkfx_clk;

  always @(locked_out_ms)
    locked_out_ms2 <= #1 locked_out_ms;
 
  assign clkfx_out1 = (locked_out_ms2) ? clkfx_out : 0;
  assign clkfx180_out1 = (locked_out_ms2) ? clkfx180_out : 0;
  assign clkfxdv_out1 = (locked_out_ms2) ? clkfxdv_out : 0;

  always @(posedge clkfx_ms_clk or negedge clkfx_ms_clk or  posedge rst_ms)
    if (rst_ms == 1) begin
       clkfx_out = 0;
       clkfx180_out = 0;
    end
    else  
      if (locked_out_ms == 1) begin
         clkfx_out <= clkfx_ms_clk;
         clkfx180_out <= !clkfx_ms_clk;
      end


  always @(posedge clkfx_ms_clk or  posedge rst_ms)
  if (rst_ms == 1) begin
       clkfxdv_out = 0;
       clkdv_cnt = 0;
  end
  else
    begin
      if (clkdv_cnt >= fxdv_div1)
           clkdv_cnt <= 0;
      else
           clkdv_cnt <= clkdv_cnt + 1;

      if (clkdv_cnt < fxdv_div_half )
          clkfxdv_out <= 1;
      else
          clkfxdv_out <= 0;
    end


//
//SPI for M/D dynamic change
//

  always @(posedge progclk_in or posedge rst_in) 
  if (rst_in == 1) begin
     progdone_out <= 1;
     bit0_flag <= 0;
     pg_cnt <= 0;
  end
  else begin
    if (progen_in == 1) begin
       if (bit0_flag == 0) begin
          if (progdata_in == 0) begin
             go_cmd <= 1;
          end
          else begin
            progdone_out <= 0;
            bit0_flag <= 1;
            pg_cnt <= 1;
            pg_sf_reg[9] <= progdata_in;
            pg_sf_reg[8:0] <=  9'b0;
          end
       end
       else begin
          progdone_out <= 0;
          if (pg_cnt >= 10) begin
             $display("Warning : PROGDATA over 10 bit limit on X_DCMCLK_GEN on instance %m at time %t.", $time);
          end
          pg_sf_reg[8:0] <=  pg_sf_reg[9:1];
          pg_sf_reg[9] <= progdata_in;
          pg_cnt <=  pg_cnt + 1;
       end
    end
    else begin
       bit0_flag <= 0;
       pg_cnt <= 0;
    end

    if (dcm_en_prog == 1)
        progdone_out <= 1;

    if (go_cmd ==1)
        go_cmd <= 0;
  end


  always @(negedge progen_in) 
    if ( pg_sf_reg[1:0] == 2'b11)
        pg_m_reg = pg_sf_reg[9:2];
    else if ( pg_sf_reg[1:0] == 2'b01)
        pg_d_reg = pg_sf_reg[9:2];


  always @(posedge go_cmd) begin
   @(negedge clkfx_out) begin
//      rst_prog <= #pdhf_fx1 1;
//      rst_prog <= #(pdhf_fx1 + pdhf_fx1) 0;
   end
   @(posedge clkin_in);
   @(posedge clkin_in);
   @(posedge clkin_in);
   @(posedge clkin_in);
   if (spa >= 3 && spa <= 5) begin
      spse0 <= 1;
   end
   @(posedge clkin_in) begin
       fx_mt = pg_m_reg + 1;
       fx_dt = pg_d_reg + 1;
       fx_n = fx_mt / fx_dt;
       fx_o = fx_m / fx_d;
       if (fx_n > fx_o)
          spd <= 1;
       else if (fx_n < fx_o)
          spd <= 0;
        
       fx_m <= pg_m_reg + 1;
       fx_d <= pg_d_reg + 1;
       if (spa >= 3 && spa <= 5) begin
         if (spse == 0) begin
            spse1 <= #1 1;
            spse1 <= #2 0;
            spse <= #2 1;
         end
       end
       else
            spse <= 0;
   end
   @(posedge clkin_in);
   clkfx_md_ratio = fx_m / fx_d;
   if (CLKFX_MD_MAX > 0.0 && clkfx_md_ratio > CLKFX_MD_MAX) begin
        $display("Error : The CLKFX MULTIPLIER and DIVIDER are programed to %d and %d on DCM_CLKGEN instance %m. The ratio of  CLKFX MULTIPLIER / CLKFX DIVIDER is %f.  It is over the value %f set by attribute CLKFX_MD_MAX.", fx_m, fx_d, clkfx_md_ratio, CLKFX_MD_MAX);
      end
   @(posedge clkin_in);
   @(posedge clkin_in)
   rst_prog <= 0;
   @(posedge clkin_in);
   @(posedge clkin_in);
   @(posedge clkin_in);
   @(posedge clkin_in);
   @(posedge clkin_in);
   @(posedge progclk_in)
   dcm_en_prog <= 1;
   @(posedge progclk_in)
   dcm_en_prog <=  0;
  end 



endmodule

