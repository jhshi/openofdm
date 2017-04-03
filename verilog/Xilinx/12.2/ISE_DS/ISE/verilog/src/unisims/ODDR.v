// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/ODDR.v,v 1.9 2009/08/21 23:55:43 harikr Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Dual Data Rate Output D Flip-Flop
// /___/   /\     Filename : ODDR.v
// \   \  /  \    Timestamp : Thu Mar 11 16:43:52 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/11/05 - Initialized outpus.
//    05/29/07 - Added wire declaration for internal signals
//    12/03/08 - CR 498674 added pulldown on R/S.
//    07/28/09 - CR 527698 According to holistic, CE has to be high for both rise/fall CLK
//             - If CE is low on the rising edge, it has an effect of no change in the falling CLK.
// End Revision

`timescale 1 ps / 1 ps

module ODDR (Q, C, CE, D1, D2, R, S);
    
    output Q;
    
    input C;
    input CE;
    input D1;
    input D2;    
    tri0 GSR = glbl.GSR;
    input R;
    input S;

    parameter DDR_CLK_EDGE = "OPPOSITE_EDGE";    
    parameter INIT = 1'b0;
    parameter SRTYPE = "SYNC";

    pulldown P1 (R);
    pulldown P2 (S);

    reg q_out = INIT, qd2_posedge_int;    

    wire c_in;
    wire ce_in;
    wire d1_in;
    wire d2_in;
    wire gsr_in;
    wire r_in;
    wire s_in;

    
    buf buf_c (c_in, C);
    buf buf_ce (ce_in, CE);
    buf buf_d1 (d1_in, D1);
    buf buf_d2 (d2_in, D2);    
    buf buf_gsr (gsr_in, GSR);
    buf buf_q (Q, q_out);
    buf buf_r (r_in, R);
    buf buf_s (s_in, S);    


    initial begin

	if ((INIT != 0) && (INIT != 1)) begin
	    $display("Attribute Syntax Error : The attribute INIT on ODDR instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT);
	    $finish;
	end
	
    	if ((DDR_CLK_EDGE != "OPPOSITE_EDGE") && (DDR_CLK_EDGE != "SAME_EDGE")) begin
	    $display("Attribute Syntax Error : The attribute DDR_CLK_EDGE on ODDR instance %m is set to %s.  Legal values for this attribute are OPPOSITE_EDGE or SAME_EDGE.", DDR_CLK_EDGE);
	    $finish;
	end
	
	if ((SRTYPE != "ASYNC") && (SRTYPE != "SYNC")) begin
	    $display("Attribute Syntax Error : The attribute SRTYPE on ODDR instance %m is set to %s.  Legal values for this attribute are ASYNC or SYNC.", SRTYPE);
	    $finish;
	end

    end // initial begin
    

    always @(gsr_in or r_in or s_in) begin
	if (gsr_in == 1'b1) begin
	    assign q_out = INIT;
	    assign qd2_posedge_int = INIT;
	end
	else if (gsr_in == 1'b0) begin
	    if (r_in == 1'b1 && SRTYPE == "ASYNC") begin
		assign q_out = 1'b0;
		assign qd2_posedge_int = 1'b0;
	    end
	    else if (r_in == 1'b0 && s_in == 1'b1 && SRTYPE == "ASYNC") begin
		assign q_out = 1'b1;
		assign qd2_posedge_int = 1'b1;
	    end
	    else if ((r_in == 1'b1 || s_in == 1'b1) && SRTYPE == "SYNC") begin
		deassign q_out;
		deassign qd2_posedge_int;
	    end	    
	    else if (r_in == 1'b0 && s_in == 1'b0) begin
		deassign q_out;
		deassign qd2_posedge_int;
	    end
	end // if (gsr_in == 1'b0)
    end // always @ (gsr_in or r_in or s_in)

	    
    always @(posedge c_in) begin
 	if (r_in == 1'b1) begin
	    q_out <= 1'b0;
	    qd2_posedge_int <= 1'b0;
	end
	else if (r_in == 1'b0 && s_in == 1'b1) begin
	    q_out <= 1'b1;
	    qd2_posedge_int <= 1'b1;
	end
	else if (ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0) begin
	    q_out <= d1_in;
	    qd2_posedge_int <= d2_in;
	end
// CR 527698
        else if (ce_in == 1'b0 && r_in == 1'b0 && s_in == 1'b0) begin
            qd2_posedge_int <= q_out;
        end
    end // always @ (posedge c_in)
    
	
    always @(negedge c_in) begin
	if (r_in == 1'b1)
	    q_out <= 1'b0;
	else if (r_in == 1'b0 && s_in == 1'b1)
	    q_out <= 1'b1;
	else if (ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0) begin
	    if (DDR_CLK_EDGE == "SAME_EDGE")
		q_out <= qd2_posedge_int;
	    else if (DDR_CLK_EDGE == "OPPOSITE_EDGE")
		q_out <= d2_in;
	end
    end // always @ (negedge c_in)
    
    
    specify

	(C => Q) = (100, 100);
	specparam PATHPULSE$ = 0;

    endspecify

endmodule // ODDR
