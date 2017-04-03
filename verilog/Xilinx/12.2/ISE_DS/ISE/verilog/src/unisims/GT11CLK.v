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
// /___/   /\     Filename : GT11CLK.v
// \   \  /  \    Timestamp : Fri Jun 18 10:57:01 PDT 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.


`timescale 1 ps / 1 ps 

module GT11CLK (
	SYNCLK1OUT,
	SYNCLK2OUT,
	MGTCLKN,
	MGTCLKP,
	REFCLK,
	RXBCLK,
	SYNCLK1IN,
	SYNCLK2IN
);

parameter REFCLKSEL = "MGTCLK";
parameter SYNCLK1OUTEN = "ENABLE";
parameter SYNCLK2OUTEN = "DISABLE";


output SYNCLK1OUT;
output SYNCLK2OUT;

input MGTCLKN;
input MGTCLKP;
input REFCLK;
input RXBCLK;
input SYNCLK1IN;
input SYNCLK2IN;

reg [0:0] SYNCLK1OUTEN_BINARY;
reg [0:0] SYNCLK2OUTEN_BINARY;
reg [3:0] REFCLKSEL_BINARY;

reg notifier;

reg mgtclk_out;
reg mux_out;	


initial begin
	case (REFCLKSEL)
		"MGTCLK" : REFCLKSEL_BINARY <= 4'b1111;
		"SYNCLK1IN" : REFCLKSEL_BINARY <= 4'b0010;
		"SYNCLK2IN" : REFCLKSEL_BINARY <= 4'b0100;
		"REFCLK" : REFCLKSEL_BINARY <= 4'b0110;
		"RXBCLK" : REFCLKSEL_BINARY <= 4'b0000;
		default : begin
			$display("Attribute Syntax Error : The Attribute REFCLKSEL on GT11CLK instance %m is set to %s.  Legal values for this attribute are MGTCLK, SYNCLK1IN, SYNCLK2IN, REFCLK or RXBCLK.", REFCLKSEL);
			$finish;
		end
	endcase

	case (SYNCLK1OUTEN)
		"ENABLE" : SYNCLK1OUTEN_BINARY <= 1'b1;
		"DISABLE" : SYNCLK1OUTEN_BINARY <= 1'b0;
		default : begin
			$display("Attribute Syntax Error : The Attribute SYNCLK1OUTEN on GT11CLK instance %m is set to %s.  Legal values for this attribute are ENABLE or DISABLE.", SYNCLK1OUTEN);
			$finish;
		end
	endcase

	case (SYNCLK2OUTEN)
		"ENABLE" : SYNCLK2OUTEN_BINARY <= 1'b1;
		"DISABLE" : SYNCLK2OUTEN_BINARY <= 1'b0;
		default : begin
			$display("Attribute Syntax Error : The Attribute SYNCLK2OUTEN on GT11CLK instance %m is set to %s.  Legal values for this attribute are ENABLE or DISABLE.", SYNCLK2OUTEN);
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

    always @(REFCLK) begin
    	if (REFCLKSEL == "REFCLK")
            mux_out <= REFCLK;
    end

    always @(mgtclk_out) begin
    	if (REFCLKSEL == "MGTCLK") 
      	    mux_out <= mgtclk_out;
    end

    always @(RXBCLK) begin
        if (REFCLKSEL == "RXBCLK")
            mux_out <= RXBCLK;
    end

    always @(SYNCLK1IN) begin
    	if (REFCLKSEL == "SYNCLK1IN") 
	    mux_out <= SYNCLK1IN;
    end

    always @(SYNCLK2IN) begin
    	if (REFCLKSEL == "SYNCLK2IN") 
	    mux_out <= SYNCLK2IN;
    end


  bufif1 (SYNCLK1OUT, mux_out, SYNCLK1OUTEN_BINARY);
  bufif1 (SYNCLK2OUT, mux_out, SYNCLK2OUTEN_BINARY);

endmodule
