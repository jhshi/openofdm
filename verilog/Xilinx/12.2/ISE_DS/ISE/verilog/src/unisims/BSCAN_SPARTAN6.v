///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Boundary Scan Logic Control Circuit for SPARTAN6
// /___/   /\     Filename : BSCAN_SPARTAN6.v
// \   \  /  \    Timestamp : Fri Jan 16 14:48:42 PST 2009
//  \___\/\___\
//
// Revision:
//    01/16/09 - Initial version.
// End Revision

`timescale  1 ps / 1 ps


module BSCAN_SPARTAN6 (CAPTURE, DRCK, RESET, RUNTEST, SEL, SHIFT, TCK, TDI, TMS, UPDATE, TDO);

    output CAPTURE, DRCK, RESET, RUNTEST, SEL, SHIFT, TCK, TDI, TMS, UPDATE;
    
    input TDO;

    reg SEL_zd;

    parameter integer JTAG_CHAIN = 1;
    
    pulldown (DRCK);
    pulldown (RESET);
    pulldown (SEL);
    pulldown (SHIFT);
    pulldown (TDI);
    pulldown (UPDATE);

//--####################################################################
//--#####                        Initialization                      ###
//--####################################################################
    initial begin
	if ((JTAG_CHAIN != 1) && (JTAG_CHAIN != 2) && (JTAG_CHAIN != 3) && (JTAG_CHAIN != 4)) begin
            $display("Attribute Syntax Error : The attribute JTAG_CHAIN on BSCAN_SPARTAN6 instance %m is set to %d.  Legal values for this attribute are 1, 2, 3 or 4.", JTAG_CHAIN);
            $finish;
        end
	
    end
//--####################################################################
//--#####                          Jtag_select                       ###
//--####################################################################
   always@(glbl.JTAG_SEL1_GLBL or glbl.JTAG_SEL2_GLBL or glbl.JTAG_SEL3_GLBL or glbl.JTAG_SEL4_GLBL) begin
      if (JTAG_CHAIN == 1)      SEL_zd = glbl.JTAG_SEL1_GLBL;
      else if (JTAG_CHAIN == 2) SEL_zd = glbl.JTAG_SEL2_GLBL;
      else if (JTAG_CHAIN == 3) SEL_zd = glbl.JTAG_SEL3_GLBL; 
      else if (JTAG_CHAIN == 4) SEL_zd = glbl.JTAG_SEL4_GLBL;
   end
//--####################################################################
//--#####                           USER_TDO                         ###
//--####################################################################
   always@(TDO) begin
      if (JTAG_CHAIN == 1)      glbl.JTAG_USER_TDO1_GLBL = TDO;
      else if (JTAG_CHAIN == 2) glbl.JTAG_USER_TDO2_GLBL = TDO;
      else if (JTAG_CHAIN == 3) glbl.JTAG_USER_TDO3_GLBL = TDO;
      else if (JTAG_CHAIN == 4) glbl.JTAG_USER_TDO4_GLBL = TDO;
   end
//--####################################################################
//--#####                            Output                          ###
//--####################################################################

assign CAPTURE = glbl.JTAG_CAPTURE_GLBL; 
assign #5 DRCK    = ((SEL_zd & !glbl.JTAG_SHIFT_GLBL & !glbl.JTAG_CAPTURE_GLBL)
                                           ||                            
                     (SEL_zd & glbl.JTAG_SHIFT_GLBL   & glbl.JTAG_TCK_GLBL)
                                           ||
                     (SEL_zd & glbl.JTAG_CAPTURE_GLBL &  glbl.JTAG_TCK_GLBL));

assign RESET   = glbl.JTAG_RESET_GLBL;
assign RUNTEST = glbl.JTAG_RUNTEST_GLBL;
assign SEL     = SEL_zd;
assign SHIFT   = glbl.JTAG_SHIFT_GLBL;
assign TDI     = glbl.JTAG_TDI_GLBL;
assign TCK     = glbl.JTAG_TCK_GLBL;
assign TMS     = glbl.JTAG_TMS_GLBL;
assign UPDATE  = glbl.JTAG_UPDATE_GLBL; 

endmodule
