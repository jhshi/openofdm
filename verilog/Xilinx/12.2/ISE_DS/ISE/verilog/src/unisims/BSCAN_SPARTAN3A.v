///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Boundary Scan Logic Control Circuit for SPARTAN3A
// /___/   /\     Filename : BSCAN_SPARTAN3A.v
// \   \  /  \    Timestamp : Tue Jul  5 09:41:40 PDT 2005
//  \___\/\___\
//
// Revision:
//    07/05/05 - Initial version.
//    01/24/06 - CR 224623, added TCK and TMS ports
// End Revision

`timescale  1 ps / 1 ps

module BSCAN_SPARTAN3A (CAPTURE, DRCK1, DRCK2, RESET, SEL1, SEL2, SHIFT, TCK, TDI, TMS, UPDATE, TDO1, TDO2);

    output CAPTURE, DRCK1, DRCK2, RESET, SEL1, SEL2, SHIFT, TCK, TDI, TMS, UPDATE;

    input TDO1, TDO2;



    pulldown (CAPTURE);
    pulldown (DRCK1);
    pulldown (DRCK2);
    pulldown (RESET);
    pulldown (SEL1);
    pulldown (SEL2);
    pulldown (SHIFT);
    pulldown (TCK);
    pulldown (TDI);
    pulldown (TMS);
    pulldown (UPDATE);

//--####################################################################
//--#####                            Output                          ###
//--####################################################################
	assign CAPTURE = glbl.JTAG_CAPTURE_GLBL;

	assign #1 DRCK1 = ((glbl.JTAG_SEL1_GLBL & !glbl.JTAG_SHIFT_GLBL  & !glbl.JTAG_CAPTURE_GLBL)
                                                 ||
		(glbl.JTAG_SEL1_GLBL & glbl.JTAG_SHIFT_GLBL   & glbl.JTAG_TCK_GLBL)
                                                 ||
		(glbl.JTAG_SEL1_GLBL & glbl.JTAG_CAPTURE_GLBL &  glbl.JTAG_TCK_GLBL));
	assign #1 DRCK2 = ((glbl.JTAG_SEL2_GLBL & !glbl.JTAG_SHIFT_GLBL  & !glbl.JTAG_CAPTURE_GLBL)
                                                 ||
		(glbl.JTAG_SEL2_GLBL & glbl.JTAG_SHIFT_GLBL   & glbl.JTAG_TCK_GLBL)
                                                 ||
		(glbl.JTAG_SEL2_GLBL & glbl.JTAG_CAPTURE_GLBL &  glbl.JTAG_TCK_GLBL));
	assign RESET  = glbl.JTAG_RESET_GLBL;
	assign SEL1   = glbl.JTAG_SEL1_GLBL;
	assign SEL2   = glbl.JTAG_SEL2_GLBL;
	assign SHIFT  = glbl.JTAG_SHIFT_GLBL;
	assign TCK    = glbl.JTAG_TCK_GLBL;
	assign TDI    = glbl.JTAG_TDI_GLBL;
	assign TMS    = glbl.JTAG_TMS_GLBL;
	assign UPDATE = glbl.JTAG_UPDATE_GLBL;

	always@(TDO1, TDO2) begin
		glbl.JTAG_USER_TDO1_GLBL <=  TDO1;
		glbl.JTAG_USER_TDO2_GLBL <=  TDO2;
	end


endmodule // BSCAN_SPARTAN3A
