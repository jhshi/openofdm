// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/BSCAN_VIRTEX4.v,v 1.5 2006/03/08 01:52:48 fphillip Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Boundary Scan Logic Control Circuit for VIRTEX4
// /___/   /\     Filename : BSCAN_VIRTEX4.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:43 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/28/06 - CR 225753 -- Removed Timing
//    02/28/06 - CR 226003 -- Added Parameter Types (integer/real).
// End Revision


`timescale  1 ps / 1 ps


module BSCAN_VIRTEX4 (CAPTURE, DRCK, RESET, SEL, SHIFT, TDI, UPDATE, TDO);

    output CAPTURE, DRCK, RESET, SEL, SHIFT, TDI, UPDATE;
    
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
            $display("Attribute Syntax Error : The attribute JTAG_CHAIN on BSCAN_VIRTEX4 instance %m is set to %d.  Legal values for this attribute are 1, 2, 3 or 4.", JTAG_CHAIN);
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

assign SHIFT   = glbl.JTAG_SHIFT_GLBL;
assign SEL     = SEL_zd;
assign TDI     = glbl.JTAG_TDI_GLBL;
assign UPDATE  = glbl.JTAG_UPDATE_GLBL; 
assign RESET   = glbl.JTAG_RESET_GLBL;

endmodule
