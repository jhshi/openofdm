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
// /__/   /\       Filename    : ICAP_SPARTAN6.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:		1.0
//  07/08/09 - Set BUSY to 1 during icap initial (CR525847)
//  09/17/09 - Remove DCMLOCK pin for SIM_CONFIG (CR530867)
//  10/09/09 - Add initialzion message and check (CR525847)
//  12/17/09 - Allow ICAP use without RBT file (CR537437)
//  03/02/10 - Support desync when icap initial done (CR551856)
//  03/17/10 - Create internal clock for icap initializtion to
//             reduce initializtion time (CR554252)
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module ICAP_SPARTAN6 (
  BUSY,
  O,
  CE,
  CLK,
  I,
  WRITE
);
  parameter DEVICE_ID = 32'h02000093;

  parameter SIM_CFG_FILE_NAME = "NONE";

  output BUSY;
  output [15:0] O;

  input CLK;
  input CE;
  input WRITE;
  input [15:0] I;

  wire cso_b;
  reg  prog_b;
  reg  init_b;
  wire busy_out;
  reg  cs_bi = 0;
  reg  rdwr_bi = 0;
  wire cs_b_t;
  wire clk_in;
  wire rdwr_b_t;
  wire [15:0] dix;
  reg [7:0] tmp_byte0;
  reg [7:0] tmp_byte1;
  reg [15:0] di;
  reg [15:0] data_rbt;
  reg [800:0] data_rbt_s;
  reg icap_idone = 0;
  reg clk_osc = 0;
  reg sim_file_flag;
  wire csi_b_in;
  integer icap_fd;
  reg lcnt;
  reg notifier;
  wire CLK;
  wire WRITE;
  wire CE;
  
  tri1 p_up; 
  tri (weak1, strong0) done_o = p_up;
  tri (pull1, supply0) [15:0] di_t = (icap_idone == 1 && WRITE == 1)? 16'bz : dix;
 
  assign csi_b_in = CE;
  assign dix = (icap_idone == 1) ? I : di;
  assign BUSY = (icap_idone  == 1) ? busy_out : 1;
  assign cs_b_t = (icap_idone == 1) ? csi_b_in : cs_bi;
  assign clk_in = (icap_idone == 1) ? CLK : clk_osc;
  assign rdwr_b_t = (icap_idone  == 1) ? WRITE : rdwr_bi;
  assign O = (icap_idone  == 1 && WRITE == 1) ? di_t : 16'b0;

  always
//    if (icap_idone == 0)
       #1000 clk_osc <= ~clk_osc;

  always @(CE or WRITE) 
    if ($time > 1 && icap_idone == 0) begin
          $display (" Warning : ICAP_SPARTAN6 on instance %m at time %t has not finished initialization. A message will be printed after the initialization. User need start read/write operation after that.", $time);
    end 

  SIM_CONFIG_S6 #(
      .DEVICE_ID(DEVICE_ID),
      .ICAP_SUPPORT("TRUE")
    )
    SIM_CONFIG_S6_INST (
      .BUSY(busy_out), 
      .CSOB(cso_b),
      .DONE(done_o),
      .CCLK(clk_in),
      .CSIB(cs_b_t),
      .D(di_t),
      .INITB(init_tri),
      .M(2'b10),
      .PROGB(prog_b),
      .RDWRB(rdwr_b_t)
  );

  initial begin
    icap_idone = 0;
    sim_file_flag = 0;
    if (SIM_CFG_FILE_NAME == "NONE") begin
 //      $display(" Error: The configure rbt data file for ICAP_SPARTAN6 instance %m was not found. Use the SIM_CFG_FILE_NAME parameter to pass the file name.\n");
       sim_file_flag = 1;
    end
    else begin
      icap_fd = $fopen(SIM_CFG_FILE_NAME, "r");
      if  (icap_fd == 0)
      begin
         $display(" Error: The configure rbt data file %s for ICAP_SPARTAN6 instance %m was not found. Use the SIM_CFG_FILE_NAME parameter to pass the file name.\n", SIM_CFG_FILE_NAME);
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
//       lcnt = $fgets(data_rbt_s, icap_fd); 
//       lcnt = $fgets(data_rbt_s, icap_fd); 
//       lcnt = $fgets(data_rbt_s, icap_fd); 
//       lcnt = $fgets(data_rbt_s, icap_fd); 
//       lcnt = $fgets(data_rbt_s, icap_fd); 
//       lcnt = $fgets(data_rbt_s, icap_fd); 
//       lcnt = $fgets(data_rbt_s, icap_fd); 
      while ($fscanf(icap_fd, "%b", data_rbt) != -1) begin
        if (done_o == 0) begin
          tmp_byte1 = bit_revers8(data_rbt[15:8]);
          tmp_byte0 = bit_revers8(data_rbt[7:0]);
          @(negedge clk_in)
            di = {tmp_byte1, tmp_byte0};
         end
         else begin
          @(negedge clk_in);
          di = 16'hFFFF;
          @(negedge clk_in);
          @(negedge clk_in);
          @(negedge clk_in);
          @(negedge clk_in);
          @(negedge clk_in);
          if (icap_idone == 0) begin
            $display (" Message: ICAP_SPARTAN6 on instance %m at time %t has finished initialization. User can start read/write operation.", $time);
            icap_idone = 1;
          end
        end
      end
      $fclose(icap_fd);
      #1000; 
    end
    else begin
       @(negedge clk_in)
          di = 16'hFFFF;
       @(negedge clk_in)
          di = 16'hFFFF;
       @(negedge clk_in)
          di = 16'hFFFF;
       @(negedge clk_in)
          di = 16'hFFFF;
       @(negedge clk_in)
          di = 16'h5599; // AA99
       @(negedge clk_in)
          di = 16'hAA66; // 5566
       @(negedge clk_in)
          di = 16'hFFFF;
       @(negedge clk_in)
          di = 16'hFFFF;
       @(negedge clk_in)
          di = 16'h0C85;
       @(negedge clk_in)
          di = 16'h00A0;
       @(negedge clk_in);
       @(negedge clk_in);
       @(negedge clk_in);
       @(negedge clk_in);
       @(negedge clk_in);
       @(negedge clk_in);
       if (icap_idone == 0) begin
            $display (" Message: ICAP_SPARTAN6 on instance %m at time %t has finished initialization. User can start read/write operation.", $time);
          icap_idone = 1;
       end
      #1000; 
      end     
  end

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
