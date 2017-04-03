// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/RAMB32_S64_ECC.v,v 1.8 2006/03/15 01:54:06 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  RAMB32_S64_ECC
// /___/   /\     Filename : RAMB32_S64_ECC.v
// \   \  /  \    Timestamp : Tue Mar  1 14:57:54 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/04/05 - Add generic DO_REG and SIM_COLLISION_CHECK to pass to RAMB16.
//               Add register to output for the latency. (CR 204569)
//    03/16/05 - Set WRITE_MODE_A and WRITE_MODE_B parameter of RAMB16 to READ_FIRST.
// End Revision


`timescale 1 ps / 1 ps

module RAMB32_S64_ECC (
 DO,
 STATUS,

 DI,
 RDADDR,
 RDCLK,
 RDEN,
 SSR,
 WRADDR,
 WRCLK,
 WREN
);

parameter integer DO_REG = 0;
parameter SIM_COLLISION_CHECK = "ALL";

output [1:0] STATUS;
output [63:0] DO;

input RDCLK;
input RDEN;
input SSR;
input WRCLK;
input WREN;
input [63:0] DI;
input [8:0]  RDADDR;
input [8:0]  WRADDR;

reg [63:0]   DO;
wire [31:0]  do_ram16low;
wire [31:0]  do_ram16up;
wire [3:0]   dopa_ram16low;
wire [3:0]   dopa_ram16up;

reg [31:0]   DIB_up;
reg [31:0]   DIB_low;
reg [3:0]    DIPB_up;
reg [3:0]    DIPB_low;

wire [31:0]  DOB_low_open;
wire [3:0]   DOPB_low_open;
wire         CASCADEOUTA_low_open;
wire         CASCADEOUTB_low_open;
wire [31:0]  DOB_up_open;
wire [3:0]   DOPB_up_open;
wire         CASCADEOUTA_up_open;
wire         CASCADEOUTB_up_open;

initial
   DO <= 64'b0;

always @(posedge RDCLK )
  begin
     DO[13:0] <= do_ram16low[13:0];
     DO[14] <= dopa_ram16low[1];
     DO[15] <= dopa_ram16low[3];
     DO[29:16] <= do_ram16low[29:16];
     DO[30] <= dopa_ram16low[0];
     DO[31] <= dopa_ram16low[2];

     DO[32] <= dopa_ram16up[0];
     DO[33] <= dopa_ram16up[2];
     DO[47:34] <= do_ram16up[15:2];
     DO[48] <= dopa_ram16up[1];
     DO[49] <= dopa_ram16up[3];
     DO[63:50] <= do_ram16up[31:18];
  end

always @(DI)
  begin
     DIB_low [13:0] <=  DI[13:0];
     DIB_low [15:14] <= 2'b00;
     DIPB_low[1]    <=  DI[14];
     DIPB_low[3]    <=  DI[15];
     DIB_low[29:16] <=  DI[29:16];
     DIB_low[31:30] <= 2'b00;
     DIPB_low[0]    <=  DI[30];
     DIPB_low[2]    <=  DI[31];

     DIPB_up[0]     <=  DI[32];
     DIPB_up[2]     <=  DI[33];
     DIB_up[15:2]   <=  DI[47:34];
     DIB_up[1:0]     <= 2'b00;
     DIPB_up[1]     <=  DI[48];
     DIPB_up[3]     <=  DI[49];
     DIB_up[17:16]  <= 2'b00;
     DIB_up[31:18]  <=  DI[63:50];
  end


  assign STATUS = 2'b00;

  RAMB16      RAMB16_LOWER (
    .ADDRA ({1'b1, RDADDR, 5'b00000}),
    .ADDRB ({1'b1, WRADDR, 5'b00000}),
    .DIA   (32'b0),
    .DIB   (DIB_low),
    .DIPA  (4'b0),
    .DIPB  (DIPB_low),
    .ENA   (RDEN),
    .ENB   (WREN),
    .WEA   (4'b0),
    .WEB   (4'b1111),
    .SSRA  (SSR),
    .SSRB  (1'b0),
    .CLKA  (RDCLK),
    .CLKB  (WRCLK),
    .REGCEA (1'b1),
    .REGCEB (1'b0),
    .CASCADEINA (1'b0),
    .CASCADEINB (1'b0),
    .DOA   (do_ram16low),
    .DOB   (DOB_low_open),
    .DOPA  (dopa_ram16low),
    .DOPB  (DOPB_low_open),
    .CASCADEOUTA (CASCADEOUTA_low_open),
    .CASCADEOUTB (CASCADEOUTB_low_open)
    );

defparam RAMB16_LOWER.READ_WIDTH_A = 36;
defparam RAMB16_LOWER.WRITE_WIDTH_A = 36;
defparam RAMB16_LOWER.READ_WIDTH_B = 36;
defparam RAMB16_LOWER.WRITE_WIDTH_B = 36;
defparam RAMB16_LOWER.WRITE_MODE_A = "READ_FIRST";
defparam RAMB16_LOWER.WRITE_MODE_B = "READ_FIRST";
defparam RAMB16_LOWER.INIT_A = 36'b0;
defparam RAMB16_LOWER.SRVAL_A = 36'b0;
defparam RAMB16_LOWER.INIT_B = 36'b0;
defparam RAMB16_LOWER.SRVAL_B = 36'b0;
defparam RAMB16_LOWER.DOA_REG = DO_REG;
defparam RAMB16_LOWER.DOB_REG = 0;
defparam RAMB16_LOWER.INVERT_CLK_DOA_REG = "FALSE";
defparam RAMB16_LOWER.INVERT_CLK_DOB_REG = "FALSE";
defparam RAMB16_LOWER.RAM_EXTENSION_A = "NONE";
defparam RAMB16_LOWER.RAM_EXTENSION_B = "NONE";
defparam RAMB16_LOWER.SIM_COLLISION_CHECK = SIM_COLLISION_CHECK;

  RAMB16      RAMB16_UPPER (
    .ADDRA ({1'b1, RDADDR, 5'b00000}),
    .ADDRB ({1'b1, WRADDR, 5'b00000}),
    .DIA   (32'b0),
    .DIB   (DIB_up),
    .DIPA  (4'b0),
    .DIPB  (DIPB_up),
    .ENA   (RDEN),
    .ENB   (WREN),
    .WEA   (4'b0),
    .WEB   (4'b1111),
    .SSRA  (SSR),
    .SSRB  (1'b0),
    .CLKA  (RDCLK),
    .CLKB  (WRCLK),
    .REGCEA (1'b1),
    .REGCEB (1'b0),
    .CASCADEINA (1'b0),
    .CASCADEINB (1'b0),
    .DOA   (do_ram16up),
    .DOB   (DOB_up_open),
    .DOPA  (dopa_ram16up),
    .DOPB  (DOPB_up_open),
    .CASCADEOUTA (CASCADEOUTA_up_open),
    .CASCADEOUTB (CASCADEOUTB_up_open)

    );

defparam RAMB16_UPPER.READ_WIDTH_A = 36;
defparam RAMB16_UPPER.WRITE_WIDTH_A = 36;
defparam RAMB16_UPPER.READ_WIDTH_B = 36;
defparam RAMB16_UPPER.WRITE_WIDTH_B = 36;
defparam RAMB16_UPPER.WRITE_MODE_A = "READ_FIRST";
defparam RAMB16_UPPER.WRITE_MODE_B = "READ_FIRST";
defparam RAMB16_UPPER.INIT_A = 36'b0;
defparam RAMB16_UPPER.SRVAL_A = 36'b0;
defparam RAMB16_UPPER.INIT_B = 36'b0;
defparam RAMB16_UPPER.SRVAL_B = 36'b0;
defparam RAMB16_UPPER.DOA_REG = DO_REG;
defparam RAMB16_UPPER.DOB_REG = 0;
defparam RAMB16_UPPER.INVERT_CLK_DOA_REG = "FALSE";
defparam RAMB16_UPPER.INVERT_CLK_DOB_REG = "FALSE";
defparam RAMB16_UPPER.RAM_EXTENSION_A = "NONE";
defparam RAMB16_UPPER.RAM_EXTENSION_B = "NONE";
defparam RAMB16_UPPER.SIM_COLLISION_CHECK = SIM_COLLISION_CHECK;
endmodule
