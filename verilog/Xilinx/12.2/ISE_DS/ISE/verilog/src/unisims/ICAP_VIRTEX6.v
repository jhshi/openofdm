///////////////////////////////////////////////////////
//  Copyright (c) 1995/2006 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : 
//  /  /                      
// /__/   /\       Filename    : ICAP_VIRTEX6.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:		
//  04/22/09 - Initial version.
//  07/08/09 - Set BUSY to 1 during icap initial (CR525847)
//  09/17/09 - Remove DCMLOCK pin for SIM_CONFIG (CR530867)
//  10/09/09 - Add initialzion message and check (CR525847)
//  12/17/09 - Allow ICAP use without RBT file (CR537437)
//  03/02/10 - Support desync when icap initial done (CR551856)
//  03/17/10 - Create internal clock for icap initializtion to 
//             reduce initializtion time (CR554252)
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module ICAP_VIRTEX6 (
  BUSY,
  O,
  CLK,
  CSB,
  I,
  RDWRB
);
  parameter [31:0] DEVICE_ID = 32'h04244093;

  parameter ICAP_WIDTH = "X8";
  parameter SIM_CFG_FILE_NAME = "NONE";

  output BUSY;
  output [31:0] O;

  input CLK;
  input CSB;
  input RDWRB;
  input [31:0] I;

  wire cso_b;
  reg  prog_b;
  reg  init_b;
  reg [3:0] bw = 4'b0000;
  wire busy_out;
  reg cs_bi = 0, rdwr_bi = 0;
  wire cs_b_t;
  wire clk_in;
  wire rdwr_b_t;
  wire [31:0] dix;
  reg [31:0] di;
  reg [31:0] data_rbt;
  reg [7:0] tmp_byte0;
  reg [7:0] tmp_byte1;
  reg [7:0] tmp_byte2;
  reg [7:0] tmp_byte3;
  reg icap_idone = 0;
  reg clk_osc = 0;
  reg sim_file_flag;
  integer icap_fd;
  reg notifier;
  wire CLK;
  wire CSB;
  wire RDWRB;
  
  tri1 p_up; 
  tri init_tri = (icap_idone == 0) ? init_b : p_up;
  tri (weak1, strong0) done_o = p_up;
  tri (pull1, supply0) [31:0] di_t = (icap_idone == 1 && RDWRB == 1)? 32'bz : dix;
 
  assign dix = (icap_idone == 1) ? I : di;
  assign BUSY = (icap_idone == 1) ? busy_out : 1;
  assign cs_b_t = (icap_idone == 1) ? CSB : cs_bi;
  assign clk_in = (icap_idone == 1) ? CLK : clk_osc;
  assign rdwr_b_t = (icap_idone == 1) ? RDWRB : rdwr_bi;
  assign O = (icap_idone == 1 && RDWRB == 1) ? di_t : 32'b0;

  always 
//    if (icap_idone == 0) 
       #1000 clk_osc <= ~clk_osc;
  
  always @(CSB or RDWRB)
    if ($time > 1 && icap_idone == 0) begin
          $display (" Warning : ICAP_VIRTEX6 on instance %m at time %t has not finished initialization. A message will be printed after the initialization. User need start read/write operation after that.", $time);
    end


  SIM_CONFIG_V6 #(
      .DEVICE_ID(DEVICE_ID),
      .ICAP_SUPPORT("TRUE"),
      .ICAP_WIDTH(ICAP_WIDTH)
    )
    SIM_CONFIG_V6_INST (
      .BUSY(busy_out),
      .CSOB(cso_b),
      .DONE(done_o),
      .CCLK(clk_in),
      .CSB(cs_b_t),
      .D(di_t),
      .INITB(init_tri),
      .M(3'b110),
      .PROGB(prog_b),
      .RDWRB(rdwr_b_t)
  );


  initial begin

    case (ICAP_WIDTH)
      "X8" : bw = 4'b0000;
      "X16" : bw = 4'b0010;
      "X32" : bw = 4'b0011;
      default : begin
        $display("Attribute Syntax Error : The Attribute ICAP_WIDTH on ICAP_VIRTEX6 instance %m is set to %s.  Legal values for this attribute are X8, X16 or X32.", ICAP_WIDTH);
      end
    endcase
 
    icap_idone = 0;
    sim_file_flag = 0;
    if (SIM_CFG_FILE_NAME == "NONE") begin
//       $display(" Error: The configure rbt data file for ICAP_VIRTEX6 instance %m was not found. Use the SIM_CFG_FILE_NAME parameter to pass the file name.\n");
       sim_file_flag = 1;
    end
    else begin
      icap_fd = $fopen(SIM_CFG_FILE_NAME, "r");
      if  (icap_fd == 0)
      begin
         $display(" Error: The configure rbt data file %s for ICAP_VIRTEX6 instance %m was not found. Use the SIM_CFG_FILE_NAME parameter to pass the file name.\n", SIM_CFG_FILE_NAME);
         sim_file_flag = 1;
      end
    end

      init_b = 1;
      prog_b = 1;
      rdwr_bi = 0;
      cs_bi = 1;
      #600000;
      @(posedge clk_in)
       prog_b = 0;
      @(negedge clk_in)
       init_b = 0;
     #600000;
      @(posedge clk_in)
       prog_b = 1;
      @(negedge clk_in) begin
       init_b = 1;
       cs_bi = 0;
      end
      if (sim_file_flag == 0) begin
        while ($fscanf(icap_fd, "%b", data_rbt) != -1) begin
         if (done_o == 0) begin
          tmp_byte3 = bit_revers8(data_rbt[31:24]);
          tmp_byte2 = bit_revers8(data_rbt[23:16]);
          tmp_byte1 = bit_revers8(data_rbt[15:8]);
          tmp_byte0 = bit_revers8(data_rbt[7:0]);
          if (bw == 4'b0000) begin
            @(negedge clk_in)
               di = {24'b0, tmp_byte3};
            @(negedge clk_in)
               di = {24'b0, tmp_byte2};
            @(negedge clk_in)
               di = {24'b0, tmp_byte1};
            @(negedge clk_in)
               di = {24'b0, tmp_byte0};
           end
           else if (bw == 4'b0010) begin
            @(negedge clk_in)
               di = {16'b0, tmp_byte3, tmp_byte2};
            @(negedge clk_in)
               di = {16'b0, tmp_byte1, tmp_byte0};
           end
           else if (bw == 4'b0011) begin
            @(negedge clk_in)
               di = {tmp_byte3, tmp_byte2, tmp_byte1, tmp_byte0};
           end
        end
        else begin
          @(negedge clk_in);
          di = 32'hFFFFFFFF;
          @(negedge clk_in);
          @(negedge clk_in);
          @(negedge clk_in);
          if (icap_idone == 0) begin 
            $display (" Message: ICAP_VIRTEX6 on instance %m at time %t has finished initialization. User can start read/write operation.", $time);
            icap_idone = 1;
          end
        end
      end
      $fclose(icap_fd);
      #1000;
    end
    else begin
       @(negedge clk_in)
          di = 32'hFFFFFFFF;
       @(negedge clk_in)
          di = 32'hFFFFFFFF;
       @(negedge clk_in)
          di = 32'hFFFFFFFF;
       @(negedge clk_in)
          di = 32'hFFFFFFFF;
       @(negedge clk_in)
          di = 32'hFFFFFFFF;
       @(negedge clk_in)
          di = 32'hFFFFFFFF;
       @(negedge clk_in)
          di = 32'hFFFFFFFF;
       @(negedge clk_in)
          di = 32'hFFFFFFFF;
       @(negedge clk_in)
          di = 32'hFFFFFFFF;
       @(negedge clk_in)
          di = 32'h000000DD;
       @(negedge clk_in) begin
        if (bw == 4'b0000)
           di = 32'h00000088;
        else if (bw == 4'b0010)
           di = 32'h00000044;
        else if (bw == 4'b0011)
           di = 32'h00000022;
       end
      rbt_data_wr(32'hFFFFFFFF);
      rbt_data_wr(32'hFFFFFFFF);
      rbt_data_wr(32'hAA995566);
      rbt_data_wr(32'h30008001);
      rbt_data_wr(32'h00000005);
       @(negedge clk_in);
       @(negedge clk_in);
       @(negedge clk_in);
       @(negedge clk_in);
       @(negedge clk_in);
       @(negedge clk_in);
       if (icap_idone == 0) begin 
            $display (" Message: ICAP_VIRTEX6 on instance %m at time %t has finished initialization. User can start read/write operation.", $time);
          icap_idone = 1;
       end
      #1000;
      end
  end
  

  task rbt_data_wr;
    input [31:0] dat_rbt;
    reg [7:0] tp_byte3;
    reg [7:0] tp_byte2;
    reg [7:0] tp_byte1;
    reg [7:0] tp_byte0;
  begin
    tp_byte3 = bit_revers8(dat_rbt[31:24]);
    tp_byte2 = bit_revers8(dat_rbt[23:16]);
    tp_byte1 = bit_revers8(dat_rbt[15:8]);
    tp_byte0 = bit_revers8(dat_rbt[7:0]);
    if (bw == 4'b0000) begin
      @(negedge clk_in)
         di = {24'b0, tp_byte3};
      @(negedge clk_in)
         di = {24'b0, tp_byte2};
      @(negedge clk_in)
         di = {24'b0, tp_byte1};
      @(negedge clk_in)
         di = {24'b0, tp_byte0};
     end
     else if (bw == 4'b0010) begin
      @(negedge clk_in)
         di = {16'b0, tp_byte3, tp_byte2};
      @(negedge clk_in)
         di = {16'b0, tp_byte1, tp_byte0};
     end
     else if (bw == 4'b0011) begin
      @(negedge clk_in)
         di = {tp_byte3, tp_byte2, tp_byte1, tp_byte0};
     end
   end
   endtask

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
