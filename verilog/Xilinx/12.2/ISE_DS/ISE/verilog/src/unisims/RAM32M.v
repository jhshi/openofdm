// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/RAM32M.v,v 1.5 2010/01/14 00:42:01 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Function Simulation Library Component
//  /   /                 32-Deep by 8-bit Wide Multi Port RAM 
// /___/   /\     Filename : RAM32M.v
// \   \  /  \    Timestamp : 
//  \___\/\___\
//
// Revision:
//    03/21/06 - Initial version.
//    01/13/10 - Remove notifier block (CR544157)
// End Revision

`timescale 1 ps/1 ps

module RAM32M (DOA, DOB, DOC, DOD, ADDRA, ADDRB, ADDRC, ADDRD, DIA, DIB, DIC, DID, WCLK, WE);

  parameter  INIT_A = 64'h0000000000000000;
  parameter  INIT_B = 64'h0000000000000000;
  parameter  INIT_C = 64'h0000000000000000;
  parameter  INIT_D = 64'h0000000000000000;

  output [1:0] DOA;
  output [1:0] DOB;
  output [1:0] DOC;
  output [1:0] DOD;
  input [4:0] ADDRA;
  input [4:0] ADDRB;
  input [4:0] ADDRC;
  input [4:0] ADDRD;
  input [1:0] DIA;
  input [1:0] DIB;
  input [1:0] DIC;
  input [1:0] DID;
  input WCLK;
  input WE;

  reg [63:0] mem_a, mem_b, mem_c, mem_d;

  initial begin
    mem_a = INIT_A;
    mem_b = INIT_B;
    mem_c = INIT_C;
    mem_d = INIT_D;
  end

  always @(posedge WCLK)
    if (WE) begin
      mem_a[2*ADDRD] <= #100 DIA[0];
      mem_a[2*ADDRD + 1] <= #100 DIA[1];
      mem_b[2*ADDRD] <= #100 DIB[0];
      mem_b[2*ADDRD + 1] <= #100 DIB[1];
      mem_c[2*ADDRD] <= #100 DIC[0];
      mem_c[2*ADDRD + 1] <= #100 DIC[1];
      mem_d[2*ADDRD] <= #100 DID[0];
      mem_d[2*ADDRD + 1] <= #100 DID[1];
  end

   assign  DOA[0] = mem_a[2*ADDRA];
   assign  DOA[1] = mem_a[2*ADDRA + 1];
   assign  DOB[0] = mem_b[2*ADDRB];
   assign  DOB[1] = mem_b[2*ADDRB + 1];
   assign  DOC[0] = mem_c[2*ADDRC];
   assign  DOC[1] = mem_c[2*ADDRC + 1];
   assign  DOD[0] = mem_d[2*ADDRD];
   assign  DOD[1] = mem_d[2*ADDRD + 1];

endmodule
