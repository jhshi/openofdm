// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Function Simulation Library Component
//  /   /                  Configuration Simulation Model
// /___/   /\     Filename : SIM_CONFIG_S6_SERIAL.v
// \   \  /  \    Timestamp : 
//  \___\/\___\
//
// Revision:
//    03/22/09 - Initial version of serial configuration simulation model for
//               Spartann6.
//    11/25/09 - Fix CRC (CR538766)
//    02/24/10 - Change Tprog to 500 ns (CR550552)
//    03/03/10 - set mode_sample_flag to 0 when mode pin set wrong (CR552316)
// End Revision
////////////////////////////////////////////////////////////////////////////////

`timescale  1 ps / 1 ps

module SIM_CONFIG_S6_SERIAL (
                   DONE,
                   CCLK,
                   DIN,
                   INITB,
                   M,
                   PROGB
                   );

  inout  DONE;
  input  CCLK;
  input  DIN;
  inout  INITB;
  input  [1:0] M;
  input  PROGB;

  parameter DEVICE_ID = 32'h0;

  localparam cfg_Tprog = 500000;   // min PROG must be low, 300 ns
  localparam cfg_Tpl =   100000;  // max program latency us.
  localparam STARTUP_PH0 = 3'b000;
  localparam STARTUP_PH1 = 3'b001;
  localparam STARTUP_PH2 = 3'b010;
  localparam STARTUP_PH3 = 3'b011;
  localparam STARTUP_PH4 = 3'b100;
  localparam STARTUP_PH5 = 3'b101;
  localparam STARTUP_PH6 = 3'b110;
  localparam STARTUP_PH7 = 3'b111;

  wire GSR, GTS, GWE;
  wire cclk_in;
  wire init_b_in;
  wire prog_b_in;
  wire crc_err_flag_tot;
  reg crc_err_flag_reg = 0;
  reg mode_sample_flag = 0;
  reg init_b_p = 1;
  reg done_o = 0;
  tri1 p_up;

  triand (weak1, strong0) INITB=(mode_sample_flag) ? ~crc_err_flag_tot : init_b_p;
  triand (weak1, strong0) DONE=done_o;

  assign DONE = p_up;
  assign INITB = p_up;

  wire done_in;
  reg por_b;
  wire [1:0] m_in;
  reg [2:0]  mode_pin_in = 3'b0;
  wire [15:0] d_in;
  wire [15:0] d_out;

  assign glbl.GSR = GSR;
  assign glbl.GTS = GTS;
//  assign glbl.GWE = GWE;
  wire d_out_en;
  wire init_b_t;
  wire prog_b_t;
  wire crc_rst;
 
  buf buf_cclk (cclk_in, CCLK);

  buf buf_din (ds_in, DIN);
//  buf buf_dout (DOUT, ds_out);
  buf buf_init (init_b_in, INITB);
  buf buf_m_0  (m_in[0], M[0]);
  buf buf_m_1  (m_in[1], M[1]);
  buf buf_prog (prog_b_in, PROGB);

  time  prog_pulse_low_edge = 0;
  time  prog_pulse_low = 0;
  integer  wr_cnt  = 0;
  reg  [4:0]   csbo_cnt = 5'b0;
  reg csbo_flag = 0;
  reg dcm_locked = 1;
  reg [4:0] conti_data_cnt = 5'b0;
  reg [5:0] rd_data_cnt = 6'b0;
  reg [15:0]  pack_in_reg  = 16'b0;
  reg  [5:0] reg_addr;
  reg  [5:0] rd_reg_addr;
  reg  new_data_in_flag  = 0;
  reg  wr_flag  = 1;
  reg  rd_flag  = 0;
  reg  cmd_wr_flag  = 0;
  reg  cmd_rd_flag  = 0;
  reg  bus_sync_flag = 0;
  reg  [1:0] buswidth = 2'b00;
  reg  rd_sw_en = 0;
  reg  conti_data_flag = 0;
  reg  conti_data_flag_set = 0;
  reg  [2:0] st_state = STARTUP_PH0;
  reg  startup_begin_flag = 0;
  reg  startup_end_flag = 0;
  reg  cmd_reg_new_flag = 0;
  reg  far_maj_min_flag = 0;
  reg  crc_reset = 0;
  reg  crc_ck = 0;
  reg  crc_err_flag = 0;
  wire crc_en, desync_flag;
  reg  [21:0] crc_curr = 22'b0;
  reg  [21:0] crc_new = 22'b0;
  reg  [21:0] crc_input = 22'b0;
  reg  gwe_out = 0;
  reg  gts_out = 1;
  reg  reboot_set = 0;
  reg  gsr_set = 0;
  reg  gts_usr_b = 1;
  reg  done_pin_drv = 0;
  reg  crc_bypass = 0;
  reg  reset_on_err = 0;
  reg  sync_timeout = 0;
  reg  [31:0] crc_reg, idcode_reg, idcode_tmp;
  reg  [15:0] far_maj_reg;
  reg  [15:0] far_min_reg;
  reg  [15:0]  fdri_reg;
  reg  [15:0]  fdro_reg;
  reg  [15:0]  cwdt_reg; 
  reg  [15:0] ctl_reg = 8'b10000001;
  reg  [4:0] cmd_reg;
  reg  [15:0]  general1_reg;
  reg  [15:0] mask_reg = 8'b0;
  reg  [15:0] lout_reg, flr_reg;
  reg  [15:0] cor1_reg = 16'b0x11011100000000;
  reg  [15:0] cor2_reg = 16'b0000100111101110;
  reg  [15:0] pwrdn_reg = 16'bx00010001000x001;
  reg  [15:0] snowplow_reg;
  reg  [15:0]  hc_opt_reg;
  reg  [15:0]  csbo_reg;
  reg  [15:0]  general2_reg;
  reg  [15:0]  mode_reg;
  reg  [15:0] general3_reg;
  reg  [15:0]  general4_reg;
  reg  [15:0]  general5_reg;
  reg  [15:0] eye_mask_reg;
  reg  [15:0]  cbc_reg;
  reg  [15:0]  seu_reg;
  reg  [15:0]  bootsts_reg;
  reg  [15:0] pu_gwe_reg;
  reg  [15:0]  pu_gts_reg;
  reg  [15:0]  mfwr_reg;
  reg  [15:0]  cclk_freq_reg;
  reg  [15:0]  seu_opt_reg;
  reg  [31:0] exp_sign_reg;
  reg  [15:0]  rdbk_sign_reg;

  reg  shutdown_set = 0;
  reg  desynch_set = 0;
  reg  [2:0] done_cycle_reg = 3'b100;
  reg  [2:0] gts_cycle_reg = 3'b101;
  reg  [2:0] gwe_cycle_reg=3'b110;
  reg  [2:0] nx_st_state  = 3'b000;
  reg  ghigh_b = 0;
  reg  eos_startup = 0;
  reg  startup_set = 0;
  reg  [1:0] startup_set_pulse = 2'b0;
  reg  [7:0] tmp_byte;
  reg  [7:0] tmp_byte1;
  reg  [7:0] tmp_byte2;
  reg  [7:0] tmp_byte3;
  reg  [7:0] tmp_byte4;
  reg  [7:0] tmp_byte5;
  reg  [7:0] tmp_byte6;
  reg  [7:0] tmp_byte7;
  reg  [15:0] tmp_word;
  reg  [7:0] ctl_reg_tmp;
  reg  id_error_flag = 0;
  reg  iprog_b = 1;
  reg  persist_en = 0;
  reg  rst_sync = 0;
  reg  [2:0] lock_cycle_reg = 3'b0;
  reg  rbcrc_no_pin = 0;
  reg  gsr_st_out = 1; 
  reg  gsr_cmd_out = 0;
  wire  [15:0] stat_reg;
  wire rst_intl;
  wire rw_en;
  wire gsr_out;
  wire cfgerr_b_flag;
  reg  [27:0] downcont = 28'b0;
  reg  type2_flag = 0;
  reg  rst_en=1, prog_b_a=1;
  reg [31:0] tmp_dword1;
  reg [31:0] tmp_dword2;
  integer wr_bit_addr;

  initial begin
    if (DEVICE_ID == 32'h0) begin
      $display("Attribute Error : The attribute DEVICE_ID on  SIM_CONFIG_S6_SERIAL instance %m is not set.");
     end
   end
 

   assign GSR = gsr_out;
   assign GTS = gts_out;
   assign GWE = gwe_out;
   assign cfgerr_b_flag = rw_en & ~crc_err_flag_tot;
   assign crc_err_flag_tot = id_error_flag | crc_err_flag_reg;
   assign crc_en =  1;
   assign done_in = DONE;

  assign init_b_t = init_b_in;

  always @( negedge prog_b_in) begin
         rst_en = 0;
         rst_en <= #cfg_Tprog 1;
  end

  always @( posedge rst_en or posedge prog_b_in ) 
   if (rst_en == 1) begin
     if (prog_b_in == 0 )
         init_b_p <= 0;
     else
         init_b_p <= #(cfg_Tpl) 1;
   end

  always @( rst_en or prog_b_in or prog_pulse_low)
    if (rst_en == 1) begin
       if (prog_pulse_low == cfg_Tprog) begin
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

  assign prog_b_t = prog_b_a  & iprog_b   & por_b;

  assign rst_intl = (prog_b_t == 0 ) ? 0 : 1;


  always @( init_b_t or  prog_b_t)
    if (prog_b_t == 0)
         mode_sample_flag <= 0;
    else if (init_b_t && mode_sample_flag == 0) begin
       if (prog_b_t == 1)  begin
          mode_pin_in <= m_in;
          if (m_in != 2'b11) begin
             mode_sample_flag <=  0;
             $display("Error: input M is %h. Only Slave Serial mode M=11 supported on SIM_CONFIG_S6_SERIAL instance %m.", m_in);
          end
          else
             mode_sample_flag <= #1 1;
       end
     end

  always @(posedge init_b_t )
       if (prog_b_t != 1)  begin
            if ($time != 0 )
       $display("Error: PROGB is not high when INITB goes high on SIM_CONFIG_S6_SERIAL instance %m at time %t.", $time);
    end

  always @(m_in)
    if (mode_sample_flag == 1 && persist_en == 1)
       $display("Error : Mode pine M[2:0] changed after rising edge of INITB on SIM_CONFIG_S6_SERIAL instance %m at time %t.", $time);
  
  always @(posedge prog_b_in or negedge prog_b_in)
    if (prog_b_in == 0) 
        prog_pulse_low_edge <= $time;
    else if (prog_b_in == 1 && $time > 0) begin
       prog_pulse_low = $time - prog_pulse_low_edge;
       if (prog_pulse_low < cfg_Tprog )
        $display("Error: Low time of PROGB is less than required minimum Tprogram time %d on SIM_CONFIG_S6_SERIAL instance %m at time %t.", cfg_Tprog, $time);
    end

    assign rw_en = (mode_sample_flag == 1 &&  done_o === 0) ? 1 : 0;
    assign desync_flag = ~rst_intl | desynch_set | crc_err_flag | id_error_flag;

    always @(posedge cclk_in or  posedge desync_flag)
      if (desync_flag == 1) begin
          pack_in_reg <= 16'b0;
          new_data_in_flag <= 0;
          bus_sync_flag <= 0;
          wr_cnt <= 0;
          wr_flag <= 1;
          tmp_dword1 <= 32'b0;
          tmp_dword2 <= 32'b0;
      end
      else begin
       if (rw_en == 1 ) begin
          if (bus_sync_flag == 0) begin
               tmp_dword1 = { tmp_dword2[30:0], ds_in};
               if (tmp_dword1[31:0] == 32'hAA995566) begin
                          bus_sync_flag <= 1;
                          new_data_in_flag <= 0;
                          tmp_dword2 <= 32'b0;
                          pack_in_reg <= 16'b0;
                          wr_cnt <= 0;
                end
                else begin
                      tmp_dword2 <= tmp_dword1;
                end
           end
          else begin
                pack_in_reg <= {pack_in_reg[14:0], ds_in};
                if (wr_cnt == 15) begin
                     new_data_in_flag <= 1;
                     wr_cnt <=  0;
                end
                else  begin
                     new_data_in_flag <= 0;
                     wr_cnt <= wr_cnt + 1;
                 end
          end
     end
     else begin  //rw_en = 0
            new_data_in_flag <= 0;
     end
    end

     always @(negedge cclk_in or negedge rst_intl)
      if (rst_intl == 0) begin
         conti_data_flag <= 0;
         conti_data_cnt <= 5'b0;
         cmd_wr_flag <= 0;
         cmd_rd_flag <= 0;
         id_error_flag <= 0;
         far_maj_min_flag <= 0;
         cmd_reg_new_flag <= 0;
         crc_curr <= 22'b0;
         crc_ck <= 0;
         csbo_cnt <= 0;
         csbo_flag <= 0;
         downcont <= 28'b0;
         rd_data_cnt <= 0;
      end
      else begin
        if (crc_reset == 1 ) begin
            crc_reg <= 32'b0;
            exp_sign_reg <= 32'b0;
            crc_ck <= 0;
            crc_curr <= 22'b0;
        end
        if (desynch_set == 1 || crc_err_flag==1) begin
           conti_data_flag <= 0;
           conti_data_cnt <= 5'b0;
           cmd_wr_flag <= 0;
           cmd_rd_flag <= 0;
           far_maj_min_flag <= 0;
           cmd_reg_new_flag <= 0;
           crc_ck <= 0;
           csbo_cnt <= 0;
           csbo_flag <= 0;
           downcont <= 28'b0;
           rd_data_cnt <= 0;
        end

        if (new_data_in_flag == 1 && wr_flag == 1) begin
           if (conti_data_flag == 1 ) begin
             if (type2_flag == 0) begin
               case (reg_addr)
               6'b000000 : if (conti_data_cnt == 5'b00001) begin
                             crc_reg[15:0] <= pack_in_reg;
                             crc_ck <= 1;
                           end
                          else if (conti_data_cnt == 5'b00010) begin
                             crc_reg[31:16] <= pack_in_reg;
                             crc_ck <= 0;
                          end
               6'b000001 : if (conti_data_cnt == 5'b00010) begin
                              far_maj_reg <= pack_in_reg;
                              far_maj_min_flag <=1;
                            end
                           else if (conti_data_cnt == 5'b00001) begin
                               if (far_maj_min_flag ==1) begin
                                  far_min_reg <= pack_in_reg;
                                  far_maj_min_flag <= 0;
                               end
                               else
                                  far_maj_reg <= pack_in_reg;
                           end
               6'b000010 : far_min_reg <= pack_in_reg;
               6'b000011 : fdri_reg <= pack_in_reg;
               6'b000101 : cmd_reg <= pack_in_reg[4:0];
               6'b000110 : begin
                             ctl_reg_tmp = (pack_in_reg & ~mask_reg) | (ctl_reg & mask_reg);
                             ctl_reg <= {8'b0, ctl_reg_tmp[7:0]};
                           end
               6'b000111 : mask_reg <= pack_in_reg;
               6'b001001 : lout_reg <= pack_in_reg;
               6'b001010 : cor1_reg <= pack_in_reg;
               6'b001011 : cor2_reg <= pack_in_reg;
               6'b001100 : pwrdn_reg <= pack_in_reg;
               6'b001101 : flr_reg <= pack_in_reg;
               6'b001110 : 
                          if (conti_data_cnt == 5'b00001) begin
                             idcode_reg[15:0] <= pack_in_reg;
                             idcode_tmp = {idcode_reg[31:16], pack_in_reg}; 
                             if (idcode_tmp[27:0] != DEVICE_ID[27:0]) begin
                                id_error_flag <= 1;
                                $display("Error :  written value to IDCODE register is %h which does not match DEVICE ID %h on SIM_CONFIG_S6_SERIAL instance %m at time %t.", idcode_tmp, DEVICE_ID, $time);
                             end 
                             else
                             id_error_flag <= 0;
                          end
                          else if (conti_data_cnt == 5'b00010)
                             idcode_reg[31:16] <= pack_in_reg;
                          
               6'b001111 : cwdt_reg <= pack_in_reg;
               6'b010000 : hc_opt_reg[6:0] <= pack_in_reg[6:0];
               6'b010011 : general1_reg <= pack_in_reg;
               6'b010100 : general2_reg <= pack_in_reg;
               6'b010101 : general3_reg <= pack_in_reg;
               6'b010110 : general4_reg <= pack_in_reg;
               6'b010111 : general5_reg <= pack_in_reg;
               6'b011000 : mode_reg <= pack_in_reg;
               6'b011001 : pu_gwe_reg <= pack_in_reg;
               6'b011010 : pu_gts_reg <= pack_in_reg;
               6'b011011 : mfwr_reg <= pack_in_reg;
               6'b011100 : cclk_freq_reg <= pack_in_reg;
               6'b011101 : seu_opt_reg <= pack_in_reg;
               6'b011110 : if (conti_data_cnt == 5'b00001)
                            exp_sign_reg[15:0] <= pack_in_reg;
                          else if (conti_data_cnt == 5'b00010)
                            exp_sign_reg[31:16] <= pack_in_reg;
               6'b011111 : if (conti_data_cnt == 5'b00001)
                            rdbk_sign_reg[15:0] <= pack_in_reg;
                          else if (conti_data_cnt == 5'b00010)
                            rdbk_sign_reg[31:16] <= pack_in_reg;
               6'b100001 : eye_mask_reg <= pack_in_reg;
               6'b100010 : cbc_reg <= pack_in_reg;
               endcase

             if (reg_addr == 6'b000101)
                 cmd_reg_new_flag <= 1;
             else
                 cmd_reg_new_flag <= 0;

             if (crc_en == 1) begin 
               if (reg_addr == 6'h05 && pack_in_reg[4:0] == 5'b00111)
                   crc_curr[21:0] = 22'b0;
               else begin
                  if (reg_addr != 6'h04 && reg_addr != 6'h08 && reg_addr != 6'h09 &&
                    reg_addr != 6'h12 && reg_addr != 6'h1f &&
                    reg_addr != 6'h20 &&  reg_addr != 6'h00) begin

                     crc_input[21:0] = {reg_addr[5:0], pack_in_reg}; 
                     crc_new[21:0] = crc_next(crc_curr, crc_input);
                     crc_curr[21:0] <= crc_new;
                   end
               end
             end
            end
            else  begin    // type2_flag
                if (conti_data_cnt == 2)
                   downcont[27:16] <= pack_in_reg[11:0];
                else if (conti_data_cnt ==1) 
                   downcont[15:0] <= pack_in_reg;
            end

             if (conti_data_cnt <= 5'b00001) begin
                conti_data_cnt <= 5'b0;
                type2_flag <= 0;
             end
             else
                conti_data_cnt <= conti_data_cnt - 1;
           end
           else begin //if (conti_data_flag == 0 )
             if ( downcont >= 1) begin
                   if (crc_en == 1) begin
                     crc_input[21:0] = {6'b000011, pack_in_reg};  //FDRI address plus data
                     crc_new[21:0] = crc_next(crc_curr, crc_input);
                     crc_curr[21:0] <= crc_new;
                   end
             end

             if (pack_in_reg[15:13] == 3'b010 && downcont == 0 ) begin
//                $display("Warning :  only Type 1 Packet supported on SIM_CONFIG_S6_SERIAL instance %m at time %t.", $time);
                cmd_wr_flag <= 0;
                type2_flag <= 1;
                conti_data_flag <= 1;
                conti_data_cnt <= 5'b00010;
             end
             else  if (pack_in_reg[15:13] == 3'b001 ) begin
                if (pack_in_reg[12:11] == 2'b01 && downcont == 0) begin
                    if (pack_in_reg[4:0] != 5'b0) begin
                       cmd_rd_flag <= 1;
                       cmd_wr_flag <= 0;
//                       rd_data_cnt <= {pack_in_reg[4:0], 1'b0};
                          rd_data_cnt <= 6'b000100;
                       conti_data_cnt <= 5'b0;
                       conti_data_flag = 0;
                       rd_reg_addr <= pack_in_reg[10:5];
                    end
                end
                else if (pack_in_reg[12:11] == 2'b10 && downcont == 0) begin
                    if (pack_in_reg[15:5] == 11'b00110010010) begin  // csbo reg
                           csbo_reg <= pack_in_reg;
                           csbo_cnt = pack_in_reg[4:0];
                           csbo_flag <= 1;
                           conti_data_flag = 0;
                           reg_addr <= pack_in_reg[10:5];
                           cmd_wr_flag <= 1;
                           conti_data_cnt <= 5'b0;
                    end
                    else if (pack_in_reg[4:0] != 5'b0 ) begin
                       cmd_wr_flag <= 1;
                       conti_data_flag <= 1;
                       conti_data_cnt <= pack_in_reg[4:0];
                       reg_addr <= pack_in_reg[10:5];
                    end
                end
                else begin
                    cmd_wr_flag <= 0;
                    conti_data_flag <= 0;
                    conti_data_cnt <= 5'b0;
                end
             end
             cmd_reg_new_flag <= 0;
          crc_ck <= 0;
          end // if (conti_data_flag == 0 )

          if (csbo_cnt != 0 ) begin
             if (csbo_flag)
              csbo_cnt <= csbo_cnt - 1;
          end
          else
              csbo_flag <= 0;

          if (conti_data_cnt == 5'b00001 ) 
                conti_data_flag <= 0;
          
      end

      if (rw_en == 1) begin
         if (rd_data_cnt == 1) begin
            rd_data_cnt <= 0;
         end
         else if (rd_data_cnt == 0 && rd_flag == 1)
               cmd_rd_flag <= 0;
         else if (cmd_rd_flag == 1 && rd_flag == 1)
             rd_data_cnt <= rd_data_cnt - 1;
 
         if (downcont >= 1 && conti_data_flag == 0 && new_data_in_flag == 1 && wr_flag == 1)
              downcont <= downcont - 1;
     end
     if (crc_ck == 1)
        crc_ck <= 0;
   end

    assign crc_rst = crc_reset | ~rst_intl;

    always @(posedge cclk_in or posedge crc_rst )
     if (crc_rst == 1)
         crc_err_flag <= 0;
     else
        if (crc_ck == 1) begin
          if (crc_bypass == 1) begin
             if (crc_reg[31:0] != 32'h9876defc) 
                 crc_err_flag <= 1;
             else
                 crc_err_flag <= 0;
           end
          else begin
            if (crc_curr[21:0] != crc_reg[21:0]) 
                crc_err_flag <= 1;
            else
                 crc_err_flag <= 0;
          end
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
         gsr_set <= 0;
         shutdown_set <= 0;
         desynch_set <= 0;
         reboot_set <= 0;
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
              gsr_set <= 1;
         if (cmd_reg == 5'b01011)
              shutdown_set <= 1;
         if (cmd_reg == 5'b01101)
              desynch_set <= 1;
         if (cmd_reg == 5'b01110) 
             reboot_set <= 1;
      end
      else  begin 
             startup_set <= 0;
              crc_reset <= 0;
              gsr_set <= 0;
              shutdown_set <= 0;
              desynch_set <= 0;
             reboot_set <= 0;
      end
    end


   always @(posedge startup_set or posedge desynch_set or negedge  rw_en )
    if (rw_en == 0)
       startup_set_pulse <= 2'b0;
    else begin
      if (startup_set_pulse == 2'b00 && startup_set ==1)
           startup_set_pulse <= 2'b01;
      else if (desynch_set == 1 && startup_set_pulse == 2'b01) begin
           startup_set_pulse <= 2'b11;
           @(posedge cclk_in )
             startup_set_pulse <= 2'b00;
      end
    end
    always @(ctl_reg) begin
      if (ctl_reg[3] == 1)
         persist_en = 1;
      else
         persist_en = 0;

      if (ctl_reg[0] == 1)
         gts_usr_b = 1;
      else
         gts_usr_b = 0;
    end

    always @(cor1_reg)
    begin
      if (cor1_reg[2] ==1)
         done_pin_drv = 1;
      else
         done_pin_drv = 0;

      if (cor1_reg[4] == 1)
         crc_bypass = 1;
      else
         crc_bypass = 0;
    end
    
    always @(cor2_reg) begin
      if (cor2_reg[15] ==1)
        reset_on_err = 1;
      else
        reset_on_err = 0;

      done_cycle_reg = cor2_reg[11:9];
      lock_cycle_reg = cor2_reg[8:6];
      gts_cycle_reg = cor2_reg[5:3];
      gwe_cycle_reg = cor2_reg[2:0];
    end


    assign stat_reg[15] = sync_timeout;
    assign stat_reg[14] = 0;
    assign stat_reg[13] = DONE;
    assign stat_reg[12] = INITB;
    assign stat_reg[11:9] = {1'b0, mode_pin_in};
    assign stat_reg[8:6] = 3'b0;
    assign stat_reg[5] = ghigh_b;
    assign stat_reg[4] = gwe_out;
    assign stat_reg[3] = gts_out;
    assign stat_reg[2] = 1'bx;
    assign stat_reg[1] = id_error_flag;
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
           if  (lock_cycle_reg == 3'b111 || dcm_locked == 1 || st_state != lock_cycle_reg) begin
                st_state <= nx_st_state;
           end
           else
              st_state <= st_state;
      end

    always @(st_state or startup_set_pulse or DONE ) 
    if (( st_state == done_cycle_reg) && (DONE != 0) || ( st_state != done_cycle_reg))
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

    always @(posedge cclk_in or negedge rst_intl )
      if (rst_intl == 0) begin
          gwe_out <= 0;
          gts_out <= 1;
          eos_startup <= 0;
          gsr_st_out <= 1;
          done_o <= 0;
      end
      else begin

         if ((nx_st_state == done_cycle_reg) || (st_state == done_cycle_reg))
            if (DONE != 0 || done_pin_drv == 1)
               done_o <= 1'b1;
            else
               done_o <= 1'bz;

         if (nx_st_state == gwe_cycle_reg)  begin
             gwe_out <= 1;
         end

         if (nx_st_state == gts_cycle_reg) begin
             gts_out <= 0;
         end

         if (nx_st_state == STARTUP_PH6)
             gsr_st_out <= 0;

         if (nx_st_state == STARTUP_PH7)
            eos_startup <= 1;

      end


     assign gsr_out = gsr_st_out | gsr_cmd_out;
     
function [21:0] crc_next;
  input [21:0] crc_curr;
  input [21:0] crc_input;
  integer i_crc;
  begin         
    for(i_crc = 21; i_crc > 15; i_crc=i_crc -1)
       crc_next[i_crc] = crc_curr[i_crc-1] ^ crc_input[i_crc];

    crc_next[15] = crc_curr[14] ^ crc_input[15] ^ crc_curr[21]; 

   for(i_crc = 14; i_crc > 12; i_crc=i_crc -1) 
       crc_next[i_crc] = crc_curr[i_crc-1] ^ crc_input[i_crc];

   crc_next[12] = crc_curr[11] ^ crc_input[12] ^ crc_curr[21];

   for(i_crc = 11; i_crc > 7; i_crc=i_crc -1) 
       crc_next[i_crc] = crc_curr[i_crc-1] ^ crc_input[i_crc];

   crc_next[7] = crc_curr[6] ^ crc_input[7] ^ crc_curr[21];

   for(i_crc = 6; i_crc > 0; i_crc=i_crc -1) 
       crc_next[i_crc] = crc_curr[i_crc-1] ^ crc_input[i_crc];

   crc_next[0] =  crc_input[0] ^ crc_curr[21];
 
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



endmodule
