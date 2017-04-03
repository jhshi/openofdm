///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  11-Gigabit Transceiver MUX
// /___/   /\     Filename : GT11CLK_MGT.v
// \   \  /  \    Timestamp : Fri Jun 18 10:57:01 PDT 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.

`timescale 1 ps / 1 ps 

module GT11CLK_MGT (
	SYNCLK1OUT,
	SYNCLK2OUT,
	MGTCLKN,
	MGTCLKP
);

parameter SYNCLK1OUTEN = "ENABLE";
parameter SYNCLK2OUTEN = "DISABLE";


output SYNCLK1OUT;
output SYNCLK2OUT;

input MGTCLKN;
input MGTCLKP;

reg [0:0] SYNCLK1OUTEN_BINARY;
reg [0:0] SYNCLK2OUTEN_BINARY;

reg mgtclk_out;

initial begin
	case (SYNCLK1OUTEN)
		"ENABLE" : SYNCLK1OUTEN_BINARY <= 1'b1;
		"DISABLE" : SYNCLK1OUTEN_BINARY <= 1'b0;
		default : begin
			$display("Attribute Syntax Error : The Attribute SYNCLK1OUTEN on GT11CLK_MGT instance %m is set to %s.  Legal values for this attribute are ENABLE or DISABLE.", SYNCLK1OUTEN);
			$finish;
		end
	endcase

	case (SYNCLK2OUTEN)
		"ENABLE" : SYNCLK2OUTEN_BINARY <= 1'b1;
		"DISABLE" : SYNCLK2OUTEN_BINARY <= 1'b0;
		default : begin
			$display("Attribute Syntax Error : The Attribute SYNCLK2OUTEN on GT11CLK_MGT instance %m is set to %s.  Legal values for this attribute are ENABLE or DISABLE.", SYNCLK2OUTEN);
			$finish;
		end
	endcase

end

    always @(MGTCLKN or MGTCLKP) begin
	if (MGTCLKP == 1'b1 && MGTCLKN == 1'b0)
	    mgtclk_out <= MGTCLKP;
	else if (MGTCLKP == 1'b0 && MGTCLKN == 1'b1)
	    mgtclk_out <= MGTCLKP;	
    end

  bufif1 (SYNCLK1OUT, mgtclk_out, SYNCLK1OUTEN_BINARY);
  bufif1 (SYNCLK2OUT, mgtclk_out, SYNCLK2OUTEN_BINARY);
endmodule

