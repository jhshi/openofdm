// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/PMCD.v,v 1.7 2008/04/04 00:30:50 fphillip Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Phase-Matched Clock Divider
// /___/   /\     Filename : PMCD.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:52 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    06/20/07 - generate clka1d2 clka1d4 clka1d8 in same always block to remove delta delay (CR440337)
//             - remove buf.
//    04/03/08 - CR 467565 -- Div clocks toggle before REL goes high when EN_REL=TRUE
// End Revision

`timescale  1 ps / 1 ps

module PMCD (CLKA1, CLKA1D2, CLKA1D4, CLKA1D8, CLKB1, CLKC1, CLKD1, CLKA, CLKB, CLKC, CLKD, REL, RST); 

    output CLKA1;
    output CLKA1D2;
    output CLKA1D4;
    output CLKA1D8;
    output CLKB1;
    output CLKC1;
    output CLKD1;
 
    input CLKA;
    input CLKB;
    input CLKC;
    input CLKD;
    input REL;
    input RST;
   
    parameter EN_REL = "FALSE";
    parameter RST_DEASSERT_CLK = "CLKA";

    reg CLKA1, CLKB1, CLKC1, CLKD1; 
    reg CLKA1D2, CLKA1D4, CLKA1D8;
    reg clkdiv_rel_rst;
    reg qrel_o_reg1, qrel_o_reg2, qrel_o_reg3;
    reg rel_o_mux;
    wire rel_rst_o;

    initial begin

	CLKA1 <= 1'b0;
	CLKB1 <= 1'b0;	   
	CLKC1 <= 1'b0;	   
	CLKD1 <= 1'b0;	   
        CLKA1D2 <= 1'b0;
        CLKA1D4 <= 1'b0;
        CLKA1D8 <= 1'b0;
	qrel_o_reg1 <= 1'b0;
	qrel_o_reg2 <= 1'b0;
	qrel_o_reg3 <= 1'b0;

    end

    
//*** asyn RST
    always @(RST) begin

	if (RST == 1'b1) begin

	    assign qrel_o_reg1 = 1'b1;
	    assign qrel_o_reg2 = 1'b1;
	    assign qrel_o_reg3 = 1'b1;

	end
	else if (RST == 1'b0) begin

	    deassign qrel_o_reg1;
	    deassign qrel_o_reg2;
	    deassign qrel_o_reg3;

	end
    end


//*** Clocks MUX

    always @(CLKA or CLKB or CLKC or CLKD) begin
	case (RST_DEASSERT_CLK)
             "CLKA" : rel_o_mux <= CLKA;
             "CLKB" : rel_o_mux <= CLKB;
             "CLKC" : rel_o_mux <= CLKC;
             "CLKD" : rel_o_mux <= CLKD;
            default : begin
	                  $display("Attribute Syntax Error : The attribute RST_DEASSERT_CLK on PMCD instance %m is set to %s.  Legal values for this attribute are CLKA, CLKB, CLKC or CLKD.", RST_DEASSERT_CLK);
	                  $finish;
	              end
	endcase
    end

//*** CLKDIV_RST
    initial begin
	case (EN_REL)
              "FALSE" : begin
                          clkdiv_rel_rst <= 1'b0;
                          qrel_o_reg3 <= 1'b0;
                        end
              "TRUE" : begin
                          clkdiv_rel_rst <= 1'b1;
                          qrel_o_reg3 <= 1'b1;
                       end
            default : begin
	                  $display("Attribute Syntax Error : The attribute EN_REL on PMCD instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EN_REL);
	                  $finish;
	              end
	endcase
    end


//*** Rel and Rst
    always @(posedge rel_o_mux) begin
	qrel_o_reg1 <= 1'b0;
    end

    always @(negedge rel_o_mux) begin
	qrel_o_reg2 <= qrel_o_reg1;
    end

    always @(posedge REL) begin
	qrel_o_reg3 <= 1'b0;
    end

    assign rel_rst_o = clkdiv_rel_rst ? (qrel_o_reg3 || qrel_o_reg1) : qrel_o_reg1;


//*** CLKA
    always @(CLKA or qrel_o_reg2)
	if (qrel_o_reg2 == 1'b1)
	    CLKA1 <= 1'b0;
	else if (qrel_o_reg2 == 1'b0)
	    CLKA1 <= CLKA;

//*** CLKB   
    always @(CLKB or qrel_o_reg2)
	if (qrel_o_reg2 == 1'b1)
	    CLKB1 <= 1'b0;
	else if (qrel_o_reg2 == 1'b0)
	    CLKB1 <= CLKB;

//*** CLKC
    always @(CLKC or qrel_o_reg2)
	if (qrel_o_reg2 == 1'b1)
	    CLKC1 <= 1'b0;
	else if (qrel_o_reg2 == 1'b0)
	    CLKC1 <= CLKC;

//*** CLKD   
    always @(CLKD or qrel_o_reg2)
	if (qrel_o_reg2 == 1'b1)
	    CLKD1 <= 1'b0;
	else if (qrel_o_reg2 == 1'b0)
	    CLKD1 <= CLKD;


//*** Clock divider

always @(posedge CLKA or posedge rel_rst_o)
  if (rel_rst_o == 1'b1)
  begin
     CLKA1D2 <= 1'b0;
     CLKA1D4 <= 1'b0;
     CLKA1D8 <= 1'b0;
  end 
 else if (rel_rst_o == 1'b0)
  begin
     CLKA1D2 <= ~CLKA1D2;
     if (!CLKA1D2)
      begin
         CLKA1D4 <= ~CLKA1D4;
         if (!CLKA1D4)
          CLKA1D8 <= ~CLKA1D8;
      end 
  end 

endmodule
