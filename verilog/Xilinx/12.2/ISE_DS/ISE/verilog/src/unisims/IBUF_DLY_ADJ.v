///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Dynamically Adjustable Input Delay Buffer
// /___/   /\     Filename : IBUF_DLY_ADJ.v
// \   \  /  \    Timestamp : Thu Feb 17 16:44:07 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/05 - Initial version.
//    05/29/07 - Added wire declaration for internal signals
//    08/08/07 - CR 439320 -- Simprim fix -- Added attributes SIM_DELAY0, ... SIM_DELAY16 to fix timing issues
//    09/11/07 - CR 447604 -- When S[2:0]=0, it should correlate to 1 tap 
//    03/28/08 - CR 469907 -- Corrected bus path of S[2:0] in the specify block elaboration
// End Revision

`timescale  1 ps / 1 ps

module IBUF_DLY_ADJ (O, I, S);

    output O;

    input I;
    input [2:0] S;


    parameter DELAY_OFFSET = "OFF";
    parameter IOSTANDARD = "DEFAULT";    

// xilinx_internal_parameter on
    // WARNING !!!: This model may not work properly if the 
    // following parameter is changed.
    localparam SIM_TAPDELAY_VALUE = 200;
    localparam SPECTRUM_OFFSET_DELAY = 1600;
    
// xilinx_internal_parameter off

        
    reg o_out;

    wire [2:0] s_in;
    integer delay_count;

    wire delay_chain_0,  delay_chain_1,  delay_chain_2,  delay_chain_3,
         delay_chain_4,  delay_chain_5,  delay_chain_6,  delay_chain_7;

    wire i_in;
    
    buf buf_o (O, o_out);

    buf buf_i (i_in, I);
    buf buf_s[2:0] (s_in, S);
   
//    buf buf_gsr (gsr_in, GSR); 

    time INITIAL_DELAY = 0;
    time FINAL_DELAY   = 0;
   
    

    initial begin
	if (DELAY_OFFSET != "ON" && DELAY_OFFSET != "OFF") begin

	    $display("Attribute Syntax Error : The attribute DELAY_OFFSET on IBUF_DLY_ADJ instance %m is set to %s.  Legal values for this attribute are ON or OFF", DELAY_OFFSET);
	    $finish;

        end
        
        if(DELAY_OFFSET == "ON")
// CR 447604
//          INITIAL_DELAY = SPECTRUM_OFFSET_DELAY; 
          INITIAL_DELAY = SPECTRUM_OFFSET_DELAY + SIM_TAPDELAY_VALUE; 
        else
//          INITIAL_DELAY =  0; 
          INITIAL_DELAY =  SIM_TAPDELAY_VALUE; 
	
    end // initial begin
    
    
//------------------------------------------------------------    
//--------------------------- GSR ----------------------------    
//------------------------------------------------------------    
//    always @(gsr_in)
//	if (gsr_in == 1'b1)
//		assign delay_count = 0;
//	else if (gsr_in == 1'b0)
//	    deassign delay_count;

//------------------------------------------------------------    
//----------------------- S input ----------------------------    
//------------------------------------------------------------    
    always@s_in
// #FINAL_DELAY = s_in * SIM_TAP_DELAY_VALUE + INITIAL_DELAY;
	delay_count = s_in;
    

//------------------------------------------------------------    
//---------------------- delay the chain  --------------------    
//------------------------------------------------------------    
    assign #INITIAL_DELAY      delay_chain_0  = i_in;
    assign #SIM_TAPDELAY_VALUE delay_chain_1  = delay_chain_0;
    assign #SIM_TAPDELAY_VALUE delay_chain_2  = delay_chain_1;
    assign #SIM_TAPDELAY_VALUE delay_chain_3  = delay_chain_2;
    assign #SIM_TAPDELAY_VALUE delay_chain_4  = delay_chain_3;
    assign #SIM_TAPDELAY_VALUE delay_chain_5  = delay_chain_4;
    assign #SIM_TAPDELAY_VALUE delay_chain_6  = delay_chain_5;
    assign #SIM_TAPDELAY_VALUE delay_chain_7  = delay_chain_6;

//------------------------------------------------------------    
//---------------------- Assign to output  -------------------    
//------------------------------------------------------------    
    always @(delay_count) begin

	case (delay_count)
            0:  assign o_out = delay_chain_0;
            1:  assign o_out = delay_chain_1;
            2:  assign o_out = delay_chain_2;
            3:  assign o_out = delay_chain_3;
            4:  assign o_out = delay_chain_4;
            5:  assign o_out = delay_chain_5;
            6:  assign o_out = delay_chain_6;
            7:  assign o_out = delay_chain_7;
            default:
		assign o_out = delay_chain_0;

	endcase
    end // always @ (s_in)
    


endmodule // IBUF_DLY_ADJ

