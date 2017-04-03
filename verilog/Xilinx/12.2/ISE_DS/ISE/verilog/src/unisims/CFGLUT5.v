// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/CFGLUT5.v,v 1.1 2006/02/01 21:08:56 patrickp Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  5-input Dynamically Reconfigurable Look-Up-Table with Carry and Clock Enable
// /___/   /\     Filename : CFGLUT5.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:40 PST 2004
//  \___\/\___\
//
// Revision:
//    12/27/05 - Initial version.
// End Revision

`timescale  1 ps / 1 ps


module CFGLUT5 (CDO, O5, O6, CDI, CE, CLK, I0, I1, I2, I3, I4);

    parameter INIT = 32'h00000000;

    output CDO;
    output O5;
    output O6;

    input  I4, I3, I2, I1, I0;
    input  CDI, CE, CLK;

    reg  [31:0] data;


    assign  O6 = data[{I4, I3, I2, I1, I0}];
    assign  O5 = data[{I3, I2, I1, I0}];
    assign  CDO = data[31];

    initial
    begin
          assign  data = INIT;
          while (CLK === 1'b1 || CLK===1'bX) 
            #10; 
          deassign data;
    end

    always @(posedge CLK)
	if (CE == 1'b1) begin
	    data <= #100 {data[30:0], CDI};
        end


endmodule

