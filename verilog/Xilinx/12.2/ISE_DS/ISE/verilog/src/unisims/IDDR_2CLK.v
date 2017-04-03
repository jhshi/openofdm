///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2006 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Input Dual Data-Rate Register with Dual Clock inputs
// /___/   /\     Filename : IDDR_2CLK.v
// \   \  /  \    Timestamp : Mon Jun 26 16:44:06 PST 2006
//  \___\/\___\
//
// Revision:
//    06/26/06 - Initial version.
//    05/29/07 - Added wire declaration for internal signals
//    04/15/08 - CR 468871 Negative SetupHold fix
//    02/17/10 - CR 548313 VCS Negative Setup check hangs when input buffers are present  
// End Revision

`timescale  1 ps / 1 ps

module IDDR_2CLK (Q1, Q2, C, CB, CE, D, R, S);

    parameter DDR_CLK_EDGE = "OPPOSITE_EDGE";    
    parameter INIT_Q1 = 1'b0;
    parameter INIT_Q2 = 1'b0;
    parameter SRTYPE = "SYNC";

    output Q1;
    output Q2;
    
    input C;
    input CB;
    input CE;
    input D;
    input R;
    input S;

    reg q1_out = INIT_Q1, q2_out = INIT_Q2;
    reg q1_out_int, q2_out_int;
    reg q1_out_pipelined, q2_out_same_edge_int;
    reg notifier, notifier1, notifier2;
    
    wire c_in;
    wire cb_in;
    wire ce_in;
    wire d_in;
    wire gsr_in;
    wire r_in;
    wire s_in;

    tri0 GSR = glbl.GSR;

    buf buf_q1 (Q1, q1_out);
    buf buf_q2 (Q2, q2_out);

    assign c_in   = C;
    assign cb_in  = CB;
    assign ce_in  = CE;
    assign d_in   = D;
    assign gsr_in = GSR;
    assign r_in   = R;
    assign s_in   = S;

    initial begin

	if ((INIT_Q1 != 0) && (INIT_Q1 != 1)) begin
	    $display("Attribute Syntax Error : The attribute INIT_Q1 on IDDR_2CLK instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT_Q1);
	    $finish;
	end
	
    	if ((INIT_Q2 != 0) && (INIT_Q2 != 1)) begin
	    $display("Attribute Syntax Error : The attribute INIT_Q1 on IDDR_2CLK instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT_Q2);
	    $finish;
	end

    	if ((DDR_CLK_EDGE != "OPPOSITE_EDGE") && (DDR_CLK_EDGE != "SAME_EDGE") && (DDR_CLK_EDGE != "SAME_EDGE_PIPELINED")) begin
	    $display("Attribute Syntax Error : The attribute DDR_CLK_EDGE on IDDR_2CLK instance %m is set to %s.  Legal values for this attribute are OPPOSITE_EDGE, SAME_EDGE or SAME_EDGE_PIPELINED.", DDR_CLK_EDGE);
	    $finish;
	end
	
	if ((SRTYPE != "ASYNC") && (SRTYPE != "SYNC")) begin
	    $display("Attribute Syntax Error : The attribute SRTYPE on IDDR_2CLK instance %m is set to %s.  Legal values for this attribute are ASYNC or SYNC.", SRTYPE);
	    $finish;
	end

    end // initial begin
    
      	
    always @(gsr_in or r_in or s_in) begin
	if (gsr_in == 1'b1) begin
	    assign q1_out_int = INIT_Q1;
	    assign q1_out_pipelined = INIT_Q1;
	    assign q2_out_same_edge_int = INIT_Q2;
	    assign q2_out_int = INIT_Q2;
	end
	else if (gsr_in == 1'b0) begin
	    if (r_in == 1'b1 && SRTYPE == "ASYNC") begin
		assign q1_out_int = 1'b0;
		assign q1_out_pipelined = 1'b0;
		assign q2_out_same_edge_int = 1'b0;
		assign q2_out_int = 1'b0;
	    end
            else if (r_in == 1'b0 && s_in == 1'b1 && SRTYPE == "ASYNC") begin
		assign q1_out_int = 1'b1;
		assign q1_out_pipelined = 1'b1;
		assign q2_out_same_edge_int = 1'b1;
		assign q2_out_int = 1'b1;
	    end
	    else if ((r_in == 1'b1 || s_in == 1'b1) && SRTYPE == "SYNC") begin
		deassign q1_out_int;
		deassign q1_out_pipelined;
		deassign q2_out_same_edge_int;
		deassign q2_out_int;
	    end	    
	    else if (r_in == 1'b0 && s_in == 1'b0) begin
		deassign q1_out_int;
		deassign q1_out_pipelined;
		deassign q2_out_same_edge_int;
		deassign q2_out_int;
	    end
	end // if (gsr_in == 1'b0)
    end // always @ (gsr_in or r_in or s_in)
    
	    
    always @(posedge c_in) begin
 	if (r_in == 1'b1) begin
	    q1_out_int <= 1'b0;
	    q1_out_pipelined <= 1'b0;
	    q2_out_same_edge_int <= 1'b0;
	end
	else if (r_in == 1'b0 && s_in == 1'b1) begin
	    q1_out_int <= 1'b1;
	    q1_out_pipelined <= 1'b1;
	    q2_out_same_edge_int <= 1'b1;
	end
	else if (ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0) begin
            q1_out_int <= d_in;
	    q1_out_pipelined <= q1_out_int;
	    q2_out_same_edge_int <= q2_out_int;
	end
    end // always @ (posedge c_in)
    
	
    always @(posedge cb_in) begin
	if (r_in == 1'b1)
	    q2_out_int <= 1'b0;
	else if (r_in == 1'b0 && s_in == 1'b1)
	    q2_out_int <= 1'b1;
	else if (ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0)
	    q2_out_int <= d_in;
    end // always @ (posedge cb_in)
    
    
    always @(posedge c_in or posedge cb_in, q1_out_int or q2_out_int or q2_out_same_edge_int or q1_out_pipelined) begin
	case (DDR_CLK_EDGE)
	    "OPPOSITE_EDGE" : begin
		                  q1_out <= q1_out_int;
		                  q2_out <= q2_out_int;
	                      end
	    "SAME_EDGE" : begin
	                      q1_out <= q1_out_int;
	                      q2_out <= q2_out_same_edge_int;
	                  end
	    "SAME_EDGE_PIPELINED" : begin
		                        q1_out <= q1_out_pipelined;
                          	        q2_out <= q2_out_same_edge_int;
	                            end
	    default : begin
	       	          $display("Attribute Syntax Error : The attribute DDR_CLK_EDGE on IDDR_2CLK instance %m is set to %s.  Legal values for this attribute are OPPOSITE_EDGE, SAME_EDGE or SAME_EDGE_PIPELINED.", DDR_CLK_EDGE);
		          $finish;
	    end
	endcase // case(DDR_CLK_EDGE)
    end // always @ (q1_out_int or q2_out_int or q2_out_same_edge_int or q1_out_pipelined or q2_out_pipelined)

    specify

        (C => Q1)  = (100, 100);
        (C => Q2)  = (100, 100);
        (CB => Q1) = (100, 100);
        (CB => Q2) = (100, 100);
        specparam PATHPULSE$ = 0;

    endspecify

endmodule // IDDR_2CLK
