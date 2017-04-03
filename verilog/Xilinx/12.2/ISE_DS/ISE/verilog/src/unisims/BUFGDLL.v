// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/BUFGDLL.v,v 1.5 2007/05/23 21:43:33 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Clock Delay Locked Loop Buffer
// /___/   /\     Filename : BUFGDLL.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:14 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.

`timescale  1 ps / 1 ps


module BUFGDLL (O, I);

    output O;
    input  I;

    parameter DUTY_CYCLE_CORRECTION = "TRUE";

    wire clkin_int;
    wire clk0_out, clk180_out, clk270_out, clk2x_out;
    wire clk90_out, clkdv_out, locked_out;

    CLKDLL clkdll_inst (.CLK0(clk0_out), .CLK180(clk180_out), .CLK270(clk270_out), .CLK2X(clk2x_out), .CLK90(clk90_out), .CLKDV(clkdv_out), .LOCKED(locked_out), .CLKFB(O), .CLKIN(clkin_int), .RST(1'b0));
    defparam clkdll_inst.DUTY_CYCLE_CORRECTION = DUTY_CYCLE_CORRECTION;

    IBUFG ibufg_inst (.O(clkin_int), .I(I));

    BUFG bufg_inst (.O(O), .I(clk0_out));

endmodule

