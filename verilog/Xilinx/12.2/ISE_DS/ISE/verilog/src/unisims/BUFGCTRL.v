// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/virtex4/BUFGCTRL.v,v 1.9 2007/06/06 18:05:48 yanx Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Global Clock Mux Buffer
// /___/   /\     Filename : BUFGCTRL.v
// \   \  /  \    Timestamp : Thu Mar 11 16:43:43 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/11/05 - Initialized outpus.
//    05/31/07 - Add wire definition, remove buf.
// End Revision

`timescale 1 ps/1 ps

module BUFGCTRL (O, CE0, CE1, I0, I1, IGNORE0, IGNORE1, S0, S1);

    output O;
    input CE0;
    input CE1;
    tri0 GSR = glbl.GSR;
    input I0;
    input I1;
    input IGNORE0;
    input IGNORE1;
    input S0;
    input S1;

    parameter integer INIT_OUT = 0;
    parameter PRESELECT_I0 = "FALSE";
    parameter PRESELECT_I1 = "FALSE";

    reg O;
    reg q0, q1;
    reg q0_enable, q1_enable;
    reg preselect_i0, preselect_i1;
    reg task_input_ce0, task_input_ce1, task_input_i0;
    reg task_input_i1, task_input_ignore0, task_input_ignore1;
    reg task_input_gsr, task_input_s0, task_input_s1;

    wire I0t, I1t;



// *** parameter checking

	initial begin
	    case (PRESELECT_I0)
                  "TRUE"   : preselect_i0 = 1'b1;
                  "FALSE"  : preselect_i0 = 1'b0;
                  default : begin
                                $display("Attribute Syntax Error : The attribute PRESELECT_I0 on BUFGCTRL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PRESELECT_I0);
                                $finish;
                            end
	    endcase
	end

	initial begin
	    case (PRESELECT_I1)
                  "TRUE"   : preselect_i1 = 1'b1;
                  "FALSE"  : preselect_i1 = 1'b0;
                  default : begin
                                $display("Attribute Syntax Error : The attribute PRESELECT_I1 on BUFGCTRL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", PRESELECT_I1);
                                $finish;
                            end
	    endcase
	end


// *** both preselects can not be 1 simultaneously.
	initial begin
	    if (preselect_i0 && preselect_i1) begin
                $display("Attribute Syntax Error : The attributes PRESELECT_I0 and PRESELECT_I1 on BUFGCTRL instance %m should not be set to TRUE simultaneously.");
                $finish;
	    end
	end

	initial begin
	    if ((INIT_OUT != 0) && (INIT_OUT != 1)) begin
	        $display("Attribute Syntax Error : The attribute INIT_OUT on BUFGCTRL instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT_OUT);
	        $finish;
	    end
	end


// *** Start here
	assign I0t = INIT_OUT ? ~I0 : I0;
	assign I1t = INIT_OUT ? ~I1 : I1;

// *** Input enable for i1
	always @(IGNORE1 or I1t or S1 or GSR or q0) begin
	    if (GSR == 1)
                q1_enable <= preselect_i1;

	    else if (GSR == 0) begin
                if ((I1t == 0) && (IGNORE1 == 0))
                    q1_enable <= q1_enable;
	        else if ((I1t == 1) || (IGNORE1 == 1))
                    q1_enable <= (~q0 && S1);
	    end
	end

// *** Output q1 for i1
	always @(q1_enable or CE1 or I1t or IGNORE1 or GSR) begin
	    if (GSR == 1)
                q1 <= preselect_i1;

	    else if (GSR == 0) begin
	        if ((I1t == 1)&& (IGNORE1 == 0))
                    q1 <= q1;
	        else if ((I1t == 0) || (IGNORE1 == 1))
                    q1 <= (CE1 && q1_enable);
	    end
	end

// *** input enable for i0
	always @(IGNORE0 or I0t or S0 or GSR or q1) begin
	    if (GSR == 1)
                q0_enable <= preselect_i0;

	    else if (GSR == 0) begin
	        if ((I0t == 0) && (IGNORE0 == 0))
                    q0_enable <= q0_enable;
	        else if ((I0t == 1) || (IGNORE0 == 1))
                    q0_enable <= (~q1 && S0);
	    end
	end

// *** Output q0 for i0
	always @(q0_enable or CE0 or I0t or IGNORE0 or GSR) begin
	    if (GSR == 1)
                q0 <= preselect_i0;

	    else if (GSR == 0) begin 
	        if ((I0t == 1) && (IGNORE0 == 0))
                    q0 <= q0;
	        else if ((I0t == 0) || (IGNORE0 == 1))
                    q0 <= (CE0 && q0_enable);
	    end
	end


	always @(q0 or q1 or I0t or I1t) begin 
	    case ({q1, q0})
                2'b01: O = I0;
                2'b10: O = I1; 
                2'b00: O = INIT_OUT;
	        2'b11: begin
		           q0 = 1'bx;
		           q1 = 1'bx;
		           q0_enable = 1'bx;
		           q1_enable = 1'bx;
		           O = 1'bx;
		       end
            endcase
	end

endmodule
