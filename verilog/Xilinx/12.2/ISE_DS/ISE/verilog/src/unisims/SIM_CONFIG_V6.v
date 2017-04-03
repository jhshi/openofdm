//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Function Simulation Library Component
//  /   /                  Configuration Simulation Model
// /___/   /\     Filename : SIM_CONFIG_V6.v
// \   \  /  \    Timestamp : 
//  \___\/\___\
//
// Revision:
//    12/16/08 - Registers update and readback timing change from V5 version.
//    04/09/09 - Add ICAP support.
//    09/17/09 - Remove DCMLOCK pin (CR530867)
//    10/02/09 - Not write to frame out file after icap_init_done=1 (CR535320)
//    11/25/09 - Fix CRC (CR538766)
//    12/17/09 - Allow ICAP use without RBT file (CR537437)
//    01/04/10 - Remove cbc_reg from readback (543490).
//    01/12/10 - Reverse bits for readback (CR544212)
//    01/22/10 - Check abort condition with clock edge (CR545788)
//    02/04/10 - Support MMCM lock wait function (CR547918)
//    03/03/10 - set mode_sample_flag to 0 when mode pin set wrong (CR552316)
//    03/10/10 - Not check crc when icap initial time (CR553387)
//    05/19/10 - Not reset startup_set_pulse when rw_en=0 (CR559852)
// End Revision
////////////////////////////////////////////////////////////////////////////////

`timescale  1 ps / 1 ps

module SIM_CONFIG_V6 ( BUSY,
                   CSOB,
                   DONE,
                   CCLK,
                   CSB,
                   D,
                   INITB,
                   M,
                   PROGB,
                   RDWRB
                   );
 
  output BUSY;
  output CSOB;
  inout DONE;
  input  CCLK;
  input  CSB;
  inout  [31:0] D; 
  inout  INITB;
  input  [2:0] M;
  input  PROGB;
  input  RDWRB;

  parameter DEVICE_ID = 32'h0;
  parameter ICAP_SUPPORT = "FALSE";
  parameter ICAP_WIDTH = "X8";

  localparam FRAME_RBT_OUT_FILENAME = "frame_data_v6_rbt_out.txt";
  localparam cfg_Tprog = 300000;   // min PROG must be low, 300 ns
  localparam cfg_Tpl =   100000;  // max program latency us.
  localparam STARTUP_PH0 = 3'b000;
  localparam STARTUP_PH1 = 3'b001;
  localparam STARTUP_PH2 = 3'b010;
  localparam STARTUP_PH3 = 3'b011;
  localparam STARTUP_PH4 = 3'b100;
  localparam STARTUP_PH5 = 3'b101;
  localparam STARTUP_PH6 = 3'b110;
  localparam STARTUP_PH7 = 3'b111;

//  tri0 GSR, GTS, GWE;
  wire GSR;
  wire GTS;
  wire GWE;
  wire cclk_in;
  wire init_b_in;
  wire prog_b_in;
  wire rdwr_b_in;
  reg rdwr_b_in1;
  reg checka_en = 0;
  reg init_b_out = 1;
  reg done_o = 0;
  integer frame_data_fd;
  integer farn = 0;
  reg frame_data_wen = 0;
  
  tri1 p_up;

  reg por_b;
  wire [2:0] m_in;
  wire [31:0] d_in;
  wire [31:0] d_out;
  wire busy_out;
  wire cso_b_out;
  wire csi_b_in;
  wire d_out_en;
  wire pll_locked;
  reg  pll_lockwt;
  wire init_b_t;
  wire prog_b_t;
  wire bus_en;
  wire desync_flag;
  wire crc_rst;
  reg  crc_bypass = 0;
  reg icap_on = 0;
  reg icap_clr = 0;
  reg icap_sync = 0;
  reg icap_desynch = 0;
  reg icap_init_done = 0;
  reg icap_init_done_dly = 0;
  wire desynch_set1;
  reg [1:0] icap_bw = 2'b00;

  assign DONE = p_up;
  assign INITB = p_up;
  assign glbl.GSR = GSR;
  assign glbl.GTS = GTS;
  assign pll_locked =  (glbl.PLL_LOCKG === 0) ? 0 : 1;
  
  buf buf_busy (BUSY, busy_out);
  buf buf_cso (CSOB, cso_b_out);
  buf buf_cclk (cclk_in, CCLK);
  buf buf_cs (csi_b_in, CSB);

  buf buf_din[31:0] (d_in, D);
  bufif1 buf_dout[31:0] (D, d_out, d_out_en);
 
  buf buf_init (init_b_in, INITB);
  buf buf_m_0  (m_in[0], M[0]);
  buf buf_m_1  (m_in[1], M[1]);
  buf buf_m_2  (m_in[2], M[2]);
  buf buf_prog (prog_b_in, PROGB);
  buf buf_rw (rdwr_b_in, RDWRB);

  time  prog_pulse_low_edge = 0;
  time  prog_pulse_low = 0;
  reg  mode_sample_flag = 0;
  reg  buswid_flag_init = 0;
  reg  buswid_flag = 0;
  wire [1:0] buswidth;
  reg [1:0] buswidth_tmp = 2'b00;
  reg [31:0]  pack_in_reg  = 32'b0;
  reg  [4:0] reg_addr;
  reg  new_data_in_flag  = 0;
  reg  wr_flag  = 0;
  reg  rd_flag  = 0;
  reg  cmd_wr_flag  = 0;
  reg  cmd_reg_new_flag = 0;
  reg  cmd_rd_flag  = 0;
  reg  bus_sync_flag = 0;
  reg  conti_data_flag = 0;
  integer  wr_cnt  = 0;
  integer  conti_data_cnt = 0;
  integer  rd_data_cnt = 0;
  integer  abort_cnt = 0;
  reg  [2:0] st_state = STARTUP_PH0;
  reg  startup_begin_flag = 0;
  reg  startup_end_flag = 0;
  reg  crc_ck = 0;
  reg crc_err_flag = 0;
  wire crc_err_flag_tot;
  reg crc_err_flag_reg = 0;
  wire  crc_en;
  reg  [31:0] crc_curr = 32'b0;
  reg  [31:0] crc_new = 32'b0;
  reg  [36:0] crc_input = 32'b0;
  reg  [31:0] rbcrc_curr = 32'b0;
  reg  [31:0] rbcrc_new = 32'b0;
  reg  [36:0] rbcrc_input = 32'b0;
  reg  gwe_out = 0;
  reg  gts_out = 1;
  reg  [31:0] d_o = 32'h0;
  reg  [31:0] outbus = 32'h0;
  reg  [31:0] outbus_dly = 32'h0;
  reg  [31:0] outbus_dly1 = 32'h0;
  reg  busy_o = 0;
  reg [31:0] tmp_val1;
  reg [31:0] tmp_val2;
  reg  [31:0] crc_reg;
  reg  [31:0] far_reg;
  reg  [31:0] far_addr;
  reg  [31:0] fdri_reg;
  reg  [31:0] fdro_reg;
  reg  [4:0] cmd_reg;
  reg [31:0] ctl0_reg = 32'b000xxxxxxxxxxxxxx000000100000xx1;
  reg  [31:0] mask_reg;
  wire [31:0] stat_reg;
  reg  [31:0] lout_reg;
  reg [31:0] cor0_reg = 32'b00000000000000000011111111101100;
  reg  [31:0] mfwr_reg;
  reg  [31:0] cbc_reg;
  reg  [31:0] idcode_reg;
  reg  [31:0] axss_reg;
  reg [31:0] cor1_reg = 32'b0;
  reg  [31:0] csob_reg;
  reg [31:0] wbstar_reg = 32'b0;
  reg [31:0] timer_reg = 32'b0;
  reg [31:0] rbcrc_hw_reg;
  reg [31:0] rbcrc_sw_reg;
  reg [31:0] rbcrc_live_reg;
  reg [31:0] efar_reg;
  reg [31:0] bootsts_reg = 32'b0;
  reg  [31:0] ctl1_reg = 32'b0;
  reg  [2:0] mode_pin_in = 3'b0;
  reg  [2:0] mode_reg;
  reg  crc_reset = 0;
  reg  gsr_set = 0;
  reg  gts_usr_b = 1;
  reg  done_pin_drv = 0;
  
  reg  shutdown_set = 0;
  reg  desynch_set = 0;
  reg  [2:0] done_cycle_reg;
  reg  [2:0] gts_cycle_reg;
  reg  [2:0] gwe_cycle_reg;
  reg  init_pin;
  reg  init_rst = 0;
  reg  init_complete; 
  reg  [2:0] nx_st_state  = 3'b000;
  reg  ghigh_b = 0;
  reg  gts_cfg_b = 0;
  reg  eos_startup = 0;
  reg startup_set = 0;
  reg [1:0] startup_set_pulse = 2'b0;
  reg abort_out_en = 0;
  reg [31:0] tmp_dword;
  reg [15:0] tmp_word;
  reg [7:0] tmp_byte;
  reg id_error_flag = 0;
  reg iprog_b = 1;
  reg i_init_b_cmd = 1;
  reg i_init_b = 0;
  reg [7:0] abort_status = 8'b0;
  reg persist_en = 0;
  reg rst_sync = 0;
  reg abort_dis = 0;
  reg [2:0] lock_cycle_reg = 3'b0;
  reg rbcrc_no_pin = 0;
  reg abort_flag_rst = 0;
  reg gsr_st_out = 1; 
  reg gsr_cmd_out = 0;
  reg gsr_cmd_out_pulse = 0;
  reg d_o_en = 0;
  wire rst_intl;
  wire rw_en;
  wire gsr_out;
  wire cfgerr_b_flag;
  reg  abort_flag;
  integer downcont_cnt = 0;
//  reg rst_en = 1;
  reg rst_en = 0;
  reg prog_b_a = 1;
  reg csbo_flag = 0;
  reg rd_sw_en = 0;
  integer csbo_cnt = 0;
  reg [4:0] rd_reg_addr = 5'b0;
  reg done_release = 0;
  
  triand (weak1, strong0) INITB=(mode_sample_flag) ? ~crc_err_flag_tot : init_b_out;
  triand (weak1, strong0) DONE=  done_o;

  initial begin

    case (ICAP_SUPPORT)
        "FALSE" : icap_on = 0;
        "TRUE" : icap_on = 1;
        default : icap_on = 0;
    endcase

    if (DEVICE_ID == 32'h0 && icap_on == 0) begin
      $display("Attribute Error : The attribute DEVICE_ID on  SIM_CONFIG_V6 instance %m is not set.");
     end

     if (ICAP_SUPPORT == "TRUE") begin
       case (ICAP_WIDTH)
        "X8" : icap_bw = 2'b01;
        "X16" : icap_bw = 2'b10;
        "X32" : icap_bw = 2'b11;
        default : icap_bw = 2'b01;
       endcase 

       frame_data_fd = $fopen(FRAME_RBT_OUT_FILENAME, "w");
       if  (frame_data_fd != 0) begin
            frame_data_wen = 1;
            $fwriteh(frame_data_fd, "frame_address   frame_data  readback_crc_value\n");
       end
     end 
     else begin
        icap_bw = 2'b00;
        frame_data_wen = 0;
     end

      icap_sync = 0;
      
   end


   assign GSR = gsr_out;
   assign GTS = gts_out;
   assign GWE = gwe_out;
   assign busy_out = busy_o;
   assign cfgerr_b_flag = rw_en & ~crc_err_flag_tot;
   assign crc_err_flag_tot = id_error_flag | crc_err_flag_reg;
//   assign d_out[7:0] = (abort_out_en ) ? abort_status : outbus_dly[7:0];
   assign d_out[7:0] = (abort_out_en ) ? abort_status : outbus[7:0];
   assign d_out[31:8] = (abort_out_en ) ? 24'b0 : outbus_dly[31:8];
   assign d_out_en = d_o_en;
   assign cso_b_out = (csbo_flag== 1) ? 0 : 1;
   assign crc_en =   (icap_init_done) ? 0 : 1;


   always @(posedge cclk_in) begin
     outbus_dly <= outbus_dly1;
     outbus_dly1 <= outbus;
   end


   always @(csi_b_in or abort_flag) 
        if (csi_b_in == 1) 
           busy_o = 1'b1;
        else
          if (abort_flag == 1)
            busy_o = 1'b1;
          else begin
            @(posedge cclk_in);
            @(posedge cclk_in);
            @(posedge cclk_in)
               busy_o = 1'b0;
          end

   always @(abort_out_en or csi_b_in or rdwr_b_in && rd_flag )
    if (abort_out_en == 1)
       d_o_en = 1;
    else
       d_o_en = rdwr_b_in & ~csi_b_in & rd_flag;


  assign init_b_t = init_b_in & i_init_b_cmd;

  always @( negedge prog_b_in) begin
         rst_en = 0;
         rst_en <= #cfg_Tprog 1;
  end

  always @( rst_en or init_rst or prog_b_in or iprog_b )
  if (icap_on == 0) begin
   if (init_rst == 1)
       init_b_out <= 0;
   else begin
     if ((prog_b_in == 0 ) && (rst_en == 1) || (iprog_b == 0))
         init_b_out <= 0;
     else if ((prog_b_in == 1 ) && (rst_en == 1) || (iprog_b == 1))
         init_b_out <= #(cfg_Tpl) 1;
   end
  end

  always @(posedge id_error_flag) begin
      init_rst <= 1;
      init_rst <= #cfg_Tprog 0;
  end
  
  always @( rst_en or prog_b_in or prog_pulse_low)
    if (rst_en == 1) begin
       if (prog_pulse_low==cfg_Tprog) begin
           prog_b_a = 0;
           prog_b_a <= #500 1;
       end
       else
          prog_b_a = prog_b_in;
    end
    else 
          prog_b_a = 1;

  initial begin
    por_b = 0;
    por_b = #400000 1;
  end 

  assign prog_b_t = prog_b_a  & iprog_b & por_b;

  assign rst_intl = (prog_b_t==0 ) ? 0 : 1;

  always @( init_b_t or  prog_b_t) 
    if (prog_b_t == 0)
         mode_sample_flag <= 0;
    else if (init_b_t && mode_sample_flag == 0) begin
       if (prog_b_t == 1)  begin
          mode_pin_in <= m_in;
          if (m_in !== 3'b110) begin
             mode_sample_flag <=  0;
             if ( icap_on == 0) 
               $display("Error: input M is %h. Only Slave SelectMAP mode M=110 supported on SIM_CONFIG_V6 instance %m.", m_in);
          end
          else
             mode_sample_flag <= #1 1;
       end     
     end

  always @(posedge init_b_t ) 
       if (prog_b_t != 1)  begin
            if ($time != 0 && icap_on == 0)
       $display("Error: PROGB is not high when INITB goes high on SIM_CONFIG_V6 instance %m at time %t.", $time);
    end

  always @(m_in)
    if (mode_sample_flag == 1 && persist_en == 1 && icap_on == 0)
       $display("Error : Mode pine M[2:0] changed after rising edge of INITB on SIM_CONFIG_V6 instance %m at time %t.", $time);
  
  always @(posedge prog_b_in or negedge prog_b_in)
    if (prog_b_in == 0) 
        prog_pulse_low_edge <= $time;
    else if (prog_b_in == 1 && $time > 0) begin
       prog_pulse_low = $time - prog_pulse_low_edge;
       if (prog_pulse_low < cfg_Tprog  && icap_on == 0)
        $display("Error: Low time of PROGB is less than required minimum Tprogram time %d on SIM_CONFIG_V6 instance %m at time %t.", cfg_Tprog, $time);
    end

    assign bus_en = (mode_sample_flag == 1 &&  csi_b_in ==0) ? 1 : 0;

    always @(posedge cclk_in or negedge rst_intl or posedge desynch_set1)
      if (rst_intl == 0 || desynch_set1 == 1) begin
         buswid_flag_init <= 0;
         buswid_flag <= 0;
         buswidth_tmp <= 2'b00;
      end
      else
        if (buswid_flag == 0) begin
           if (bus_en == 1 && rdwr_b_in == 0)  begin
                 tmp_byte = bit_revers8(d_in[7:0]);
                 if (buswid_flag_init == 0) begin
                     if (tmp_byte == 8'hBB)
                         buswid_flag_init <= 1;
                  end
                  else begin
                     if (tmp_byte == 8'h11) begin
                         buswid_flag <= 1; 
                         buswidth_tmp <= 2'b01;
                     end
                     else if (tmp_byte == 8'h22) begin
                         buswid_flag <= 1; 
                         buswidth_tmp <= 2'b10;
                     end
                     else if (tmp_byte == 8'h44) begin
                         buswid_flag <= 1; 
                         buswidth_tmp <= 2'b11;
                     end
                     else begin
                         buswid_flag <= 0; 
                         buswidth_tmp <= 2'b00;
                         buswid_flag_init <= 0;
                         if (icap_on == 0) 
                         $display("Error : BUS Width Auto Dection did not find 0x11 or 0x22 or 0x44 on D[7:0] followed 0xBB on SIM_CONFIG_V6 instance %m at time %t.", $time);
                         else 
                         $display("Error : BUS Width Auto Dection did not find 0x11 or 0x22 or 0x44 on dix[7:0] followed 0xBB on ICAP_VIRTEX6 instance %m at time %t.", $time);
                         
                     end
                 end
            end
     end
 
    assign buswidth[1:0] = (icap_on == 1 && icap_init_done == 1) ? icap_bw[1:0] : buswidth_tmp[1:0];
    assign rw_en_tmp = (bus_en == 1 ) ?  1 : 0;
//    assign rw_en = (((icap_on == 0 || icap_init_done == 0) && buswid_flag == 1) || icap_init_done == 1) ? rw_en_tmp : 0;
    assign rw_en = ( buswid_flag == 1)  ? rw_en_tmp : 0;
    assign desynch_set1 = desynch_set | icap_desynch;
    assign desync_flag = ~rst_intl | desynch_set1 | crc_err_flag | id_error_flag;
    
    always @(posedge eos_startup) 
      if (icap_on == 1) begin
        $fclose(frame_data_fd);
        icap_init_done <= 1;
        @(posedge cclk_in); 
        @(posedge cclk_in)
         if (icap_init_done_dly == 0) 
            icap_desynch <= 1;
        @(posedge cclk_in);
        @(posedge cclk_in) begin
          icap_desynch <= 0;
          icap_init_done_dly <= 1;
        end
        @(posedge cclk_in);
        @(posedge cclk_in);
        @(posedge cclk_in);
      end
      else begin
        icap_clr <= 0;
        icap_desynch <= 0;
      end

    always @(posedge cclk_in or negedge rdwr_b_in)
     if (rdwr_b_in == 0)
       rd_sw_en <= 0;
     else begin
      if (csi_b_in == 1 && rdwr_b_in ==1)
          rd_sw_en <= 1;
     end

    always @(posedge cclk_in or posedge desync_flag or posedge csi_b_in)
      if (desync_flag == 1 ) begin
          pack_in_reg <= 32'b0;
          new_data_in_flag <= 0;
          bus_sync_flag <= 0;
          wr_cnt <= 0;
          wr_flag <= 0;
          rd_flag <= 0;
      end
      else if (icap_init_done == 1 && csi_b_in == 1 && rdwr_b_in == 0) begin
          pack_in_reg <= 32'b0;
          new_data_in_flag <= 0;
          wr_cnt <= 0;
      end
      else begin
       if (icap_clr == 1) begin
          pack_in_reg <= 32'b0;
          new_data_in_flag <= 0;
          wr_cnt <= 0;
          wr_flag <= 0;
          rd_flag <= 0;
       end
       else if (rw_en == 1 ) begin
         if (rdwr_b_in == 0) begin
           wr_flag <= 1;
           rd_flag <= 0;
           if (buswidth == 2'b01 || (icap_sync == 1 && bus_sync_flag == 0)) begin
               tmp_byte = bit_revers8(d_in[7:0]);
               if (bus_sync_flag == 0) begin
                  if (pack_in_reg[23:16] == 8'hAA && pack_in_reg[15:8] == 8'h99 
                      && pack_in_reg[7:0] == 8'h55 && tmp_byte == 8'h66) begin
                          bus_sync_flag <= 1;
                          new_data_in_flag <= 0;
                          wr_cnt <= 0;
                   end
                   else begin
                      pack_in_reg[31:24] <= pack_in_reg[23:16];
                      pack_in_reg[23:16] <= pack_in_reg[15:8];
                      pack_in_reg[15:8] <= pack_in_reg[7:0];
                      pack_in_reg[7:0] <= tmp_byte;
                   end
               end
               else begin
                 if (wr_cnt == 0) begin
                    pack_in_reg[31:24] <= tmp_byte;
                     new_data_in_flag <= 0;
                     wr_cnt <=  1;
                 end
                 else if (wr_cnt == 1) begin
                     pack_in_reg[23:16] <= tmp_byte;
                     new_data_in_flag <= 0;
                     wr_cnt <= 2;
                 end
                 else if (wr_cnt == 2) begin
                     pack_in_reg[15:8] <= tmp_byte;
                     new_data_in_flag <= 0;
                     wr_cnt <= 3;
                 end
                 else if (wr_cnt == 3) begin
                     pack_in_reg[7:0] <= tmp_byte;
                     new_data_in_flag <= 1;
                     wr_cnt <= 0;
                 end
             end
           end
           else if (buswidth == 2'b10) begin
             tmp_word = {bit_revers8(d_in[15:8]), bit_revers8(d_in[7:0])};
             if (bus_sync_flag == 0) begin
                if (pack_in_reg[15:0] == 16'hAA99 && tmp_word ==16'h5566) begin
                     wr_cnt <= 0;
                     bus_sync_flag <= 1;
                     new_data_in_flag <= 0;
                end
                else begin
                   pack_in_reg[31:16] <= pack_in_reg[15:0];
                   pack_in_reg[15:0] <= tmp_word;
                   new_data_in_flag <= 0;
                   wr_cnt <= 0;
                end
             end
             else begin
               if (wr_cnt == 0) begin
                   pack_in_reg[31:16] <= tmp_word;
                   new_data_in_flag <= 0;
                   wr_cnt <= 1;
               end
               else if (wr_cnt == 1) begin
                   pack_in_reg[15:0] <= tmp_word;
                   new_data_in_flag <= 1;
                   wr_cnt <= 0;
               end
             end
           end
           else if (buswidth == 2'b11 ) begin
             tmp_dword = {bit_revers8(d_in[31:24]), bit_revers8(d_in[23:16]), bit_revers8(d_in[15:8]),
                          bit_revers8(d_in[7:0])};
             pack_in_reg[31:0] <= tmp_dword;
             if (bus_sync_flag == 0) begin
                if (tmp_dword == 32'hAA995566) begin
                     bus_sync_flag <= 1;
                     new_data_in_flag <= 0;
                end
             end
             else begin
                pack_in_reg[31:0] <= tmp_dword;
                new_data_in_flag <= 1;
             end
           end
       end
       else begin
            wr_flag <= 0;
            new_data_in_flag <= 0;
            if (rd_sw_en ==1)
               rd_flag <= 1;
       end
     end
     else begin
            wr_flag <= 0;
            rd_flag <= 0;
            new_data_in_flag <= 0;
     end
   end
           
    always @(negedge cclk_in or negedge rst_intl)
      if (rst_intl == 0) begin
         conti_data_flag <= 0;
         conti_data_cnt <= 0;
         cmd_wr_flag <= 0;
         cmd_rd_flag <= 0;
         id_error_flag <= 0;
         crc_curr <= 32'b0;
         crc_ck <= 0;
         csbo_cnt <= 0;
         csbo_flag <= 0;
         downcont_cnt <= 0;
         rd_data_cnt <= 0;
      end
      else begin
        if (icap_clr == 1) begin
         conti_data_flag <= 0;
         conti_data_cnt <= 0;
         cmd_wr_flag <= 0;
         cmd_rd_flag <= 0;
         id_error_flag <= 0;
         crc_curr <= 32'b0;
         crc_ck <= 0;
         csbo_cnt <= 0;
         csbo_flag <= 0;
         downcont_cnt <= 0;
         rd_data_cnt <= 0;
        end
        if (crc_reset == 1 ) begin
            crc_reg <= 32'b0;
            crc_ck <= 0;
            crc_curr <= 32'b0;
        end
        if (crc_ck == 1)
             crc_curr <= 32'b0;

        if (desynch_set1 == 1 || crc_err_flag == 1) begin
           conti_data_flag <= 0;
           conti_data_cnt <= 0;
           cmd_wr_flag <= 0;
           cmd_rd_flag <= 0;
           cmd_reg_new_flag <= 0;
           crc_ck <= 0;
           csbo_cnt <= 0;
           csbo_flag <= 0;
           downcont_cnt <= 0;
           rd_data_cnt <= 0;
        end

        if (new_data_in_flag == 1 && wr_flag == 1) begin
           if (conti_data_flag == 1 ) begin
               case (reg_addr)
               5'b00000 : begin 
                             crc_reg <= pack_in_reg;
                             crc_ck <= 1;
                          end 
               5'b00001 : far_reg <= pack_in_reg;
               5'b00010 : fdri_reg <= pack_in_reg;
               5'b00100 : cmd_reg <= pack_in_reg[4:0];
               5'b00101 : ctl0_reg <= (pack_in_reg & mask_reg) | (ctl0_reg & ~mask_reg);
               5'b00110 : mask_reg <= pack_in_reg;
               5'b01000 : lout_reg <= pack_in_reg;
               5'b01001 : cor0_reg <= pack_in_reg;
               5'b01010 : mfwr_reg <= pack_in_reg;
               5'b01011 : cbc_reg <= pack_in_reg;
               5'b01100 : begin
                          idcode_reg <= pack_in_reg;
                          if (pack_in_reg[27:0] != DEVICE_ID[27:0]) begin
                             id_error_flag <= 1;
                             if (icap_on == 0)
                             $display("Error : written value to IDCODE register is %h which does not match DEVICE ID %h on SIM_CONFIG_V6 instance %m at time %t.", pack_in_reg, DEVICE_ID, $time);
                             else
                             $display("Error : written value to IDCODE register is %h which does not match DEVICE ID %h on ICAP_VIRTEX6 instance %m at time %t.", pack_in_reg, DEVICE_ID, $time);
                          end 
                          else
                             id_error_flag <= 0;
                          end
               5'b01101 : axss_reg <= pack_in_reg;
               5'b01110 : cor1_reg <= pack_in_reg;
               5'b01111 : csob_reg <= pack_in_reg;
               5'b10000 : wbstar_reg <= pack_in_reg;
               5'b10001 : timer_reg <= pack_in_reg;
               5'b10011 : rbcrc_sw_reg <= pack_in_reg;
               5'b11000 : ctl1_reg <= (pack_in_reg & mask_reg) | (ctl1_reg & ~mask_reg);
               endcase
   
             if (reg_addr != 5'b00000)
                crc_ck <= 0;

             if (reg_addr == 5'b00100)
                  cmd_reg_new_flag <= 1;
             else
                 cmd_reg_new_flag <= 0;

             if (crc_en == 1) begin 
               if (reg_addr == 5'h04 && pack_in_reg[4:0] == 5'b00111)
                   crc_curr[31:0] = 32'b0;
               else begin
                  if ( reg_addr != 5'h0f && reg_addr != 5'h12 && reg_addr != 5'h14 
                   && reg_addr != 5'h15 && reg_addr != 5'h16 && reg_addr != 5'h00) begin
                     crc_input[36:0] = {reg_addr, pack_in_reg}; 
                     crc_new[31:0] = bcc_next(crc_curr, crc_input);
                     crc_curr[31:0] <= crc_new;
                   end
               end
             end

             if (conti_data_cnt <= 1) begin
                  conti_data_cnt <= 0;
              end
             else 
                conti_data_cnt <= conti_data_cnt - 1;
        end
        else if (conti_data_flag == 0 ) begin
            if ( downcont_cnt >= 1) begin
                   if (crc_en == 1) begin
                     crc_input[36:0] =  {5'b00010, pack_in_reg}; 
                     crc_new[31:0] = bcc_next(crc_curr, crc_input);
                     crc_curr[31:0] <= crc_new;
                   end
                   if (farn <= 80)
                      farn <= farn + 1;
                   else begin
                      far_addr <= far_addr + 1;
                      farn <= 0;
                   end
                   if (frame_data_wen == 1 && icap_init_done == 0) begin
                     rbcrc_input[36:0] =  {5'b00011, pack_in_reg}; 
                     rbcrc_new[31:0] = bcc_next(rbcrc_curr, rbcrc_input);
                     rbcrc_curr[31:0] <= rbcrc_new;
                     $fwriteh(frame_data_fd, far_addr);
                     $fwriteh(frame_data_fd, "\t");
                     $fwriteh(frame_data_fd, pack_in_reg);
                     $fwriteh(frame_data_fd, "\t");
                     $fwriteh(frame_data_fd, rbcrc_new); 
                     $fwriteh(frame_data_fd, "\n");
                   end
             end

             if (pack_in_reg[31:29] == 3'b010 && downcont_cnt == 0  ) begin
                cmd_rd_flag <= 0;
                cmd_wr_flag <= 0;
                conti_data_flag <= 0;
                conti_data_cnt <= 0;
                downcont_cnt <= pack_in_reg[26:0];
                far_addr <= far_reg;
             end
             else if (pack_in_reg[31:29] == 3'b001) begin // type 1 package
                if (pack_in_reg[28:27] == 2'b01 && downcont_cnt == 0) begin
                    if (pack_in_reg[10:0] != 10'b0) begin
                       cmd_rd_flag <= 1;
                       cmd_wr_flag <= 0;
                       rd_data_cnt <= 4;
                       conti_data_cnt <= 0;
                       conti_data_flag <= 0;
                       rd_reg_addr <= pack_in_reg[17:13];
                    end
                end
                else if (pack_in_reg[28:27] == 2'b10 && downcont_cnt == 0) begin
                   if (pack_in_reg[17:13] == 5'b01111) begin  // csbo reg
                           csob_reg <= pack_in_reg;
                           csbo_cnt = pack_in_reg[10:0];
                           csbo_flag <= 1;
                           conti_data_flag = 0;
                           reg_addr <= pack_in_reg[17:13];
                           cmd_wr_flag <= 1;
                           conti_data_cnt <= 5'b0;
                    end
                    else  begin
                      if (pack_in_reg[10:0] != 10'b0) begin
                       cmd_rd_flag <= 0;
                       cmd_wr_flag <= 1;
                       conti_data_flag <= 1;
                       conti_data_cnt <= pack_in_reg[10:0];
                       reg_addr <= pack_in_reg[17:13];
                      end
                      else begin
                       cmd_rd_flag <= 0;
                       cmd_wr_flag <= 1;
                       conti_data_flag <= 0;
                       conti_data_cnt <= 0;
                       reg_addr <= pack_in_reg[17:13];
                      end
                    end
                end
                else begin
                    cmd_wr_flag <= 0;
                    conti_data_flag <= 0;
                    conti_data_cnt <= 0;
                end
             end
             cmd_reg_new_flag <= 0;
             crc_ck <= 0;
          end    // if (conti_data_flag == 0 ) 
          if (csbo_cnt != 0 ) begin
             if (csbo_flag == 1)
              csbo_cnt <= csbo_cnt - 1;
          end
          else
              csbo_flag <= 0;

          if (conti_data_cnt == 5'b00001 ) 
                conti_data_flag <= 0;

      end

      if (rw_en == 1) begin
         if (rd_data_cnt == 1 && rd_flag == 1) 
            rd_data_cnt <= 0;
         else if (rd_data_cnt == 0 && rd_flag == 1)
               cmd_rd_flag <= 0;
         else if (cmd_rd_flag ==1  && rd_flag == 1)
             rd_data_cnt <= rd_data_cnt - 1;

          if (downcont_cnt >= 1 && conti_data_flag == 0 && new_data_in_flag == 1 && wr_flag == 1)
              downcont_cnt <= downcont_cnt - 1;
      end

      if (crc_ck == 1 || icap_init_done == 0)
        crc_ck <= 0;
    end


   always @(posedge cclk_in or negedge rst_intl)
    if (rst_intl == 0) begin
         outbus <= 32'b0;
     end
    else begin
        if (cmd_rd_flag == 1 && rdwr_b_in == 1 && csi_b_in == 0) begin
               case (rd_reg_addr)
               5'b00000 : if (buswidth == 2'b01) 
                             rdbk_byte(crc_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(crc_reg);
                          else if (buswidth == 2'b11) 
                             rdbk_2wd(crc_reg);
               5'b00001 : if (buswidth == 2'b01)
                             rdbk_byte(far_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(far_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(far_reg);
               5'b00011 : if (buswidth == 2'b01)
                             rdbk_byte(fdro_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(fdro_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(fdro_reg);
               5'b00100 : if (buswidth == 2'b01)
                             rdbk_byte(cmd_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(cmd_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(cmd_reg);
               5'b00101 : if (buswidth == 2'b01)
                             rdbk_byte(ctl0_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(ctl0_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(ctl0_reg);
               5'b00110 : if (buswidth == 2'b01)
                             rdbk_byte(mask_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(mask_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(mask_reg);
               5'b00111 : if (buswidth == 2'b01)
                             rdbk_byte(stat_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(stat_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(stat_reg);
               5'b01001 : if (buswidth == 2'b01)
                             rdbk_byte(cor0_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(cor0_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(cor0_reg);
               5'b01100 : if (buswidth == 2'b01)
                             rdbk_byte(DEVICE_ID);
                          else if (buswidth == 2'b10)
                             rdbk_wd(DEVICE_ID);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(DEVICE_ID);
               5'b01101 : if (buswidth == 2'b01)
                             rdbk_byte(axss_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(axss_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(axss_reg);
               5'b01110 : if (buswidth == 2'b01)
                             rdbk_byte(cor1_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(cor1_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(cor1_reg);
               5'b10000 : if (buswidth == 2'b01)
                             rdbk_byte(wbstar_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(wbstar_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(wbstar_reg);
               5'b10001 : if (buswidth == 2'b01)
                             rdbk_byte(timer_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(timer_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(timer_reg);
               5'b10010 : if (buswidth == 2'b01)
                             rdbk_byte(rbcrc_hw_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(rbcrc_hw_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(rbcrc_hw_reg);
               5'b10011 : if (buswidth == 2'b01)
                             rdbk_byte(rbcrc_sw_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(rbcrc_sw_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(rbcrc_sw_reg);
               5'b10100 : if (buswidth == 2'b01)
                             rdbk_byte(rbcrc_live_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(rbcrc_live_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(rbcrc_live_reg);
               5'b10101 : if (buswidth == 2'b01)
                             rdbk_byte(efar_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(efar_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(efar_reg);
               5'b10110 : if (buswidth == 2'b01)
                             rdbk_byte(bootsts_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(bootsts_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(bootsts_reg);
               5'b11000 : if (buswidth == 2'b01)
                             rdbk_byte(ctl1_reg);
                          else if (buswidth == 2'b10)
                             rdbk_wd(ctl1_reg);
                          else if (buswidth == 2'b11)
                             rdbk_2wd(ctl1_reg);
               endcase
       end
       else
             outbus <= 32'b0;
   end

        

    assign crc_rst = crc_reset | ~rst_intl;

    always @(posedge cclk_in or posedge crc_rst )
     if (crc_rst == 1)
         crc_err_flag <= 0;
     else
       if (crc_ck == 1) begin
            if (crc_curr[31:0] != crc_reg[31:0]) 
                crc_err_flag <= 1;
            else
                 crc_err_flag <= 0;
       end
       else
           crc_err_flag <= 0;

    always @(posedge crc_err_flag or negedge rst_intl or posedge bus_sync_flag)
     if (rst_intl == 0)
         crc_err_flag_reg <= 0;
     else if (crc_err_flag == 1)
         crc_err_flag_reg <= 1;
     else
         crc_err_flag_reg <= 0;

    always @(posedge cclk_in or negedge rst_intl)
    if (rst_intl == 0) begin
         startup_set <= 0;
         crc_reset  <= 0;
         gsr_cmd_out <= 0;
         shutdown_set <= 0;
         desynch_set <= 0;
         ghigh_b <= 0;
    end
    else begin
    if (cmd_reg_new_flag == 1) begin
      if (cmd_reg == 5'b00011) 
          ghigh_b <= 1;
      else if (cmd_reg == 5'b01000)
           ghigh_b <= 0;

      if (cmd_reg == 5'b00101)
           startup_set <= 1;

      if (cmd_reg == 5'b00111) 
           crc_reset <= 1;

      if (cmd_reg == 5'b01010) 
           gsr_cmd_out <= 1;

      if (cmd_reg == 5'b01011)
           shutdown_set <= 1;

      if (cmd_reg == 5'b01101) 
           desynch_set <= 1;

      if (cmd_reg == 5'b01111) begin
          iprog_b <= 0;
          i_init_b_cmd <= 0;
          iprog_b <= #cfg_Tprog 1;
          i_init_b_cmd <=#(cfg_Tprog + cfg_Tpl) 1;
      end
    end
    else begin
             startup_set <= 0;
              crc_reset <= 0;
              gsr_cmd_out <= 0;
              shutdown_set <= 0;
              desynch_set <= 0;
      end
    end

   always @(posedge startup_set or posedge desynch_set or negedge  rw_en )
    if (rw_en == 1)
     begin
      if (startup_set_pulse == 2'b00 && startup_set ==1) begin
         if (icap_on == 0)
           startup_set_pulse <= 2'b01;
         else begin
           startup_set_pulse <= 2'b11;
           @(posedge cclk_in )
             startup_set_pulse <= 2'b00;
         end
       end
       else if (desynch_set == 1 && startup_set_pulse == 2'b01) begin
           startup_set_pulse <= 2'b11;
           @(posedge cclk_in )
             startup_set_pulse <= 2'b00;
      end
    end

   always @(posedge gsr_cmd_out or negedge  rw_en)
    if (rw_en == 1)
     begin
       gsr_cmd_out_pulse <= 1;
        @(posedge cclk_in );
          @(posedge cclk_in )
           gsr_cmd_out_pulse <=  0;
    end

    always @(ctl0_reg) begin
      if (ctl0_reg[9] == 1)
         abort_dis = 1;
      else
         abort_dis = 0;

      if (ctl0_reg[3] == 1)
         persist_en = 1;
      else
         persist_en = 0;
 
      if (ctl0_reg[0] == 1)
         gts_usr_b = 1;
      else
         gts_usr_b = 0;
    end

    always @(cor0_reg)
    begin
      done_cycle_reg = cor0_reg[14:12];
      lock_cycle_reg = cor0_reg[8:6];
      gts_cycle_reg = cor0_reg[5:3];
      gwe_cycle_reg = cor0_reg[2:0];

     if (cor0_reg[24] == 1'b1)
         done_pin_drv = 1;
      else
         done_pin_drv = 0;

      if (cor0_reg[28] == 1'b1)
         crc_bypass = 1;
      else
         crc_bypass = 0;
    end

    always @(cor1_reg)
       rbcrc_no_pin = cor1_reg[8];

    assign stat_reg[31:27] = 5'b000x0; 
    assign stat_reg[26:25] = buswidth;
    assign stat_reg[24:21] = 4'bxxx0;
    assign stat_reg[20:18] = st_state;
    assign stat_reg[17] = 1'b0;
    assign stat_reg[16] = 1'b0;
    assign stat_reg[15] = id_error_flag;
    assign stat_reg[14] = DONE;
    assign stat_reg[13] = (done_o !== 0) ? 1 : 0;
    assign stat_reg[12] = INITB;
    assign stat_reg[11] = mode_sample_flag;
    assign stat_reg[10:8] = mode_pin_in;
    assign stat_reg[7] = ghigh_b;
    assign stat_reg[6] = gwe_out;
    assign stat_reg[5] = gts_cfg_b;
    assign stat_reg[4] = eos_startup;
    assign stat_reg[3] = 1'b1;
    assign stat_reg[2] = pll_locked;
    assign stat_reg[1] = 1'b0;
    assign stat_reg[0] = crc_err_flag_reg; 


    always @(posedge cclk_in or negedge rst_intl)
      if (rst_intl == 0) begin
        st_state <= STARTUP_PH0;
        startup_begin_flag <= 0;
        startup_end_flag <= 0;
      end
      else begin
           if (nx_st_state == STARTUP_PH1) begin
              startup_begin_flag <= 1;
              startup_end_flag <= 0;
           end
           else if (st_state == STARTUP_PH7) begin
              startup_end_flag <= 1;
              startup_begin_flag <= 0;
           end
           if ((lock_cycle_reg == 3'b111) || (pll_locked == 1) || (pll_locked == 0 && st_state != lock_cycle_reg)) begin
                st_state <= nx_st_state;
           end
           else
              st_state <= st_state;
      end

    always @(st_state or startup_set_pulse or DONE ) begin

    if (((st_state == done_cycle_reg) && (DONE !== 0)) || (st_state != done_cycle_reg))
      case (st_state)
      STARTUP_PH0 : if (startup_set_pulse == 2'b11 ) 
                       nx_st_state = STARTUP_PH1;
                    else
                       nx_st_state = STARTUP_PH0;
      STARTUP_PH1 : nx_st_state = STARTUP_PH2;

      STARTUP_PH2 : nx_st_state = STARTUP_PH3;

      STARTUP_PH3 : nx_st_state = STARTUP_PH4;

      STARTUP_PH4 : nx_st_state = STARTUP_PH5;

      STARTUP_PH5 : nx_st_state = STARTUP_PH6;

      STARTUP_PH6 : nx_st_state = STARTUP_PH7;

      STARTUP_PH7 : nx_st_state = STARTUP_PH0;
      endcase
    end

    always @(posedge cclk_in or negedge rst_intl )
      if (rst_intl == 0) begin
          gwe_out <= 0;
          gts_out <= 1;
          eos_startup <= 0;
          gsr_st_out <= 1;
          done_o <= 0;
      end
      else  begin

         if (nx_st_state == done_cycle_reg || st_state == done_cycle_reg) begin
            if (DONE !== 0 || done_pin_drv == 1) 
                  done_o <= 1'b1;
             else 
                 done_o <= 1'bz;
         end
         
         if (st_state == gwe_cycle_reg)  
             gwe_out <= 1;
        
         if (st_state == gts_cycle_reg )  
             gts_out <= 0;
            
         if (st_state == STARTUP_PH6 )
             gsr_st_out <= 0;

         if (st_state == STARTUP_PH7 ) 
            eos_startup <= 1;
         
      end
      
     assign gsr_out = gsr_st_out | gsr_cmd_out;
     
    always @(posedge cclk_in  or negedge rst_intl or 
                posedge abort_flag_rst or posedge csi_b_in)
      if (rst_intl == 0 || abort_flag_rst == 1 || csi_b_in == 1) begin
          abort_flag <= 0;
          checka_en <= 0;
          rdwr_b_in1 <= rdwr_b_in;
      end
      else  begin
        if (  abort_dis == 0 && csi_b_in == 0) begin
             if ((rdwr_b_in1 != rdwr_b_in) && checka_en != 0) begin
               abort_flag <= 1;
               if (icap_on == 0)
               $display(" Warning : RDWRB changes when CSB low, which causes Configuration abort on SIM_CONFIG_V6 instance %m at time %t.", $time);
             end
        end
        else
           abort_flag <= 0;

        rdwr_b_in1 <= rdwr_b_in;
        checka_en <= 1;
      end

    always @(posedge abort_flag)
      begin
         abort_out_en <= 1;
         abort_status <= {cfgerr_b_flag, bus_sync_flag, 1'b0, 1'b1, 4'b1111};
         @(posedge cclk_in)
            abort_status <= {cfgerr_b_flag, 1'b1, 1'b0, 1'b0, 4'b1111};
         @(posedge cclk_in)
            abort_status <= {cfgerr_b_flag, 1'b0, 1'b0, 1'b0, 4'b1111};
         @(posedge cclk_in)
            abort_status <= {cfgerr_b_flag, 1'b0, 1'b0, 1'b1, 4'b1111};
         @(posedge cclk_in) begin
            abort_out_en <= 0;
            abort_flag_rst <= 1;
         end
         @(posedge cclk_in) 
            abort_flag_rst <= 0;
    end
         

function [31:0] bcc_next;
  input [31:0] bcc;
  input [36:0] in;
reg [31:0] x;
reg [36:0] m;
begin
 m = in;
 x = in[31:0] ^ bcc;

 bcc_next[31] = m[32]^m[36]^x[31]^x[30]^x[29]^x[28]^x[27]^x[24]^x[20]^x[19]^x[18]^x[15]^x[13]^x[11]^x[10]^x[9]^x[8]^x[6]^x[5]^x[1]^x[0];

 bcc_next[30] = m[35]^x[31]^x[30]^x[29]^x[28]^x[27]^x[26]^x[23]^x[19]^x[18]^x[17]^x[14]^x[12]^x[10]^x[9]^x[8]^x[7]^x[5]^x[4]^x[0];

 bcc_next[29] = m[34]^x[30]^x[29]^x[28]^x[27]^x[26]^x[25]^x[22]^x[18]^x[17]^x[16]^x[13]^x[11]^x[9]^x[8]^x[7]^x[6]^x[4]^x[3];

 bcc_next[28] = m[33]^x[29]^x[28]^x[27]^x[26]^x[25]^x[24]^x[21]^x[17]^x[16]^x[15]^x[12]^x[10]^x[8]^x[7]^x[6]^x[5]^x[3]^x[2];

 bcc_next[27] = m[32]^x[28]^x[27]^x[26]^x[25]^x[24]^x[23]^x[20]^x[16]^x[15]^x[14]^x[11]^x[9]^x[7]^x[6]^x[5]^x[4]^x[2]^x[1];

 bcc_next[26] = x[31]^x[27]^x[26]^x[25]^x[24]^x[23]^x[22]^x[19]^x[15]^x[14]^x[13]^x[10]^x[8]^x[6]^x[5]^x[4]^x[3]^x[1]^x[0];

 bcc_next[25] = m[32]^m[36]^x[31]^x[29]^x[28]^x[27]^x[26]^x[25]^x[23]^x[22]^x[21]^x[20]^x[19]^x[15]^x[14]^x[12]^x[11]^x[10]^x[8]^x[7]^x[6]^x[4]^x[3]^x[2]^x[1];

 bcc_next[24] = m[35]^x[31]^x[30]^x[28]^x[27]^x[26]^x[25]^x[24]^x[22]^x[21]^x[20]^x[19]^x[18]^x[14]^x[13]^x[11]^x[10]^x[9]^x[7]^x[6]^x[5]^x[3]^x[2]^x[1]^x[0];

 bcc_next[23] = m[32]^m[34]^m[36]^x[31]^x[28]^x[26]^x[25]^x[23]^x[21]^x[17]^x[15]^x[12]^x[11]^x[4]^x[2];

 bcc_next[22] = m[32]^m[33]^m[35]^m[36]^x[29]^x[28]^x[25]^x[22]^x[19]^x[18]^x[16]^x[15]^x[14]^x[13]^x[9]^x[8]^x[6]^x[5]^x[3]^x[0];

 bcc_next[21] = m[34]^m[35]^m[36]^x[30]^x[29]^x[21]^x[20]^x[19]^x[17]^x[14]^x[12]^x[11]^x[10]^x[9]^x[7]^x[6]^x[4]^x[2]^x[1]^x[0];

 bcc_next[20] = m[32]^m[33]^m[34]^m[35]^m[36]^x[31]^x[30]^x[27]^x[24]^x[16]^x[15]^x[3];

 bcc_next[19] = m[32]^m[33]^m[34]^m[35]^x[31]^x[30]^x[29]^x[26]^x[23]^x[15]^x[14]^x[2];

 bcc_next[18] = m[33]^m[34]^m[36]^x[27]^x[25]^x[24]^x[22]^x[20]^x[19]^x[18]^x[15]^x[14]^x[11]^x[10]^x[9]^x[8]^x[6]^x[5]^x[0];

 bcc_next[17] = m[33]^m[35]^m[36]^x[31]^x[30]^x[29]^x[28]^x[27]^x[26]^x[23]^x[21]^x[20]^x[17]^x[15]^x[14]^x[11]^x[7]^x[6]^x[4]^x[1]^x[0];

 bcc_next[16] = m[32]^m[34]^m[35]^x[30]^x[29]^x[28]^x[27]^x[26]^x[25]^x[22]^x[20]^x[19]^x[16]^x[14]^x[13]^x[10]^x[6]^x[5]^x[3]^x[0];

 bcc_next[15] = m[33]^m[34]^x[31]^x[29]^x[28]^x[27]^x[26]^x[25]^x[24]^x[21]^x[19]^x[18]^x[15]^x[13]^x[12]^x[9]^x[5]^x[4]^x[2];

 bcc_next[14] = m[32]^m[33]^x[30]^x[28]^x[27]^x[26]^x[25]^x[24]^x[23]^x[20]^x[18]^x[17]^x[14]^x[12]^x[11]^x[8]^x[4]^x[3]^x[1];

 bcc_next[13] = m[36]^x[30]^x[28]^x[26]^x[25]^x[23]^x[22]^x[20]^x[18]^x[17]^x[16]^x[15]^x[9]^x[8]^x[7]^x[6]^x[5]^x[3]^x[2]^x[1];

 bcc_next[12] = m[32]^m[35]^m[36]^x[31]^x[30]^x[28]^x[25]^x[22]^x[21]^x[20]^x[18]^x[17]^x[16]^x[14]^x[13]^x[11]^x[10]^x[9]^x[7]^x[4]^x[2];

 bcc_next[11] = m[32]^m[34]^m[35]^m[36]^x[28]^x[21]^x[18]^x[17]^x[16]^x[12]^x[11]^x[5]^x[3]^x[0];

 bcc_next[10] = m[33]^m[34]^m[35]^x[31]^x[27]^x[20]^x[17]^x[16]^x[15]^x[11]^x[10]^x[4]^x[2];

 bcc_next[9] = m[33]^m[34]^m[36]^x[31]^x[29]^x[28]^x[27]^x[26]^x[24]^x[20]^x[18]^x[16]^x[14]^x[13]^x[11]^x[8]^x[6]^x[5]^x[3]^x[0];

 bcc_next[8] = m[33]^m[35]^m[36]^x[31]^x[29]^x[26]^x[25]^x[24]^x[23]^x[20]^x[18]^x[17]^x[12]^x[11]^x[9]^x[8]^x[7]^x[6]^x[4]^x[2]^x[1]^x[0];

 bcc_next[7] = m[32]^m[34]^m[35]^x[30]^x[28]^x[25]^x[24]^x[23]^x[22]^x[19]^x[17]^x[16]^x[11]^x[10]^x[8]^x[7]^x[6]^x[5]^x[3]^x[1]^x[0];

 bcc_next[6] = m[32]^m[33]^m[34]^m[36]^x[30]^x[28]^x[23]^x[22]^x[21]^x[20]^x[19]^x[16]^x[13]^x[11]^x[8]^x[7]^x[4]^x[2]^x[1];

 bcc_next[5] = m[33]^m[35]^m[36]^x[30]^x[28]^x[24]^x[22]^x[21]^x[13]^x[12]^x[11]^x[9]^x[8]^x[7]^x[5]^x[3];

 bcc_next[4] = m[34]^m[35]^m[36]^x[31]^x[30]^x[28]^x[24]^x[23]^x[21]^x[19]^x[18]^x[15]^x[13]^x[12]^x[9]^x[7]^x[5]^x[4]^x[2]^x[1]^x[0];

 bcc_next[3] = m[32]^m[33]^m[34]^m[35]^m[36]^x[31]^x[28]^x[24]^x[23]^x[22]^x[19]^x[17]^x[15]^x[14]^x[13]^x[12]^x[10]^x[9]^x[5]^x[4]^x[3];

 bcc_next[2] = m[32]^m[33]^m[34]^m[35]^x[31]^x[30]^x[27]^x[23]^x[22]^x[21]^x[18]^x[16]^x[14]^x[13]^x[12]^x[11]^x[9]^x[8]^x[4]^x[3]^x[2];

 bcc_next[1] = m[32]^m[33]^m[34]^x[31]^x[30]^x[29]^x[26]^x[22]^x[21]^x[20]^x[17]^x[15]^x[13]^x[12]^x[11]^x[10]^x[8]^x[7]^x[3]^x[2]^x[1];

 bcc_next[0] = m[32]^m[33]^x[31]^x[30]^x[29]^x[28]^x[25]^x[21]^x[20]^x[19]^x[16]^x[14]^x[12]^x[11]^x[10]^x[9]^x[7]^x[6]^x[2]^x[1]^x[0];

end
endfunction

function [7:0] bit_revers8;
  input [7:0] din8;
  begin
      bit_revers8[0] = din8[7];
      bit_revers8[1] = din8[6];
      bit_revers8[2] = din8[5];
      bit_revers8[3] = din8[4];
      bit_revers8[4] = din8[3];
      bit_revers8[5] = din8[2];
      bit_revers8[6] = din8[1];
      bit_revers8[7] = din8[0];
  end
endfunction

task rdbk_byte;
  input [31:0] rdbk_reg;
  begin
    outbus[31:8] <= 24'b0;
   if (rd_data_cnt==1)
         outbus[7:0] <= bit_revers8(rdbk_reg[7:0]);
   else if (rd_data_cnt==2)
         outbus[7:0] <= bit_revers8(rdbk_reg[15:8]);
   else if (rd_data_cnt==3)
         outbus[7:0] <= bit_revers8(rdbk_reg[23:16]);
   else if (rd_data_cnt==4)
         outbus[7:0] <= bit_revers8(rdbk_reg[31:24]);
  end
endtask 

task rdbk_wd;
  input [31:0] rdbk_reg;
  begin
     outbus[31:16] <= 16'b0;
     if (rd_data_cnt==1)
         outbus[15:0] <= 16'b0;
     else if (rd_data_cnt==2)
         outbus[15:0] <= 16'b0;
     else if (rd_data_cnt==3) begin
         outbus[7:0] <= bit_revers8(rdbk_reg[7:0]);
         outbus[15:8] <= bit_revers8(rdbk_reg[15:8]);
     end
     else if (rd_data_cnt==4) begin
         outbus[7:0] <= bit_revers8(rdbk_reg[23:16]);
         outbus[15:8] <= bit_revers8(rdbk_reg[31:16]);
     end
  end
endtask
    
task rdbk_2wd;
  input [31:0] rdbk_reg;
  begin
     if (rd_data_cnt==1)
         outbus <= 32'b0;
     else if (rd_data_cnt==2)
         outbus <= 32'b0;
     else if (rd_data_cnt==3)
         outbus <= 32'b0;
     else if (rd_data_cnt==4) begin
         outbus[7:0] <= bit_revers8(rdbk_reg[7:0]);
         outbus[15:8] <= bit_revers8(rdbk_reg[15:8]);
         outbus[23:16] <= bit_revers8(rdbk_reg[23:16]);
         outbus[31:24] <= bit_revers8(rdbk_reg[31:24]);
     end
  end
endtask




endmodule
