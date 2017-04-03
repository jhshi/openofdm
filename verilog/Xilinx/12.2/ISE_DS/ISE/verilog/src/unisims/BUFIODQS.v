///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2007 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  
// /___/   /\     Filename : BUFIODQS.v
// \   \  /  \    Timestamp : Mon Jul 14 13:48:38 PDT 2008
//  \___\/\___\
//
// Revision:
//    07/14/08 - Initial version.
//    03/20/09 - CR 513938 remove DELAY_BYPASS
//    05/12/09 - CR 521124 changed functionality as specified by hw.
//    09/01/09 - CR 532419 Changed default value of DQSMASK_ENABLE
// End Revision

`timescale  1 ps / 1 ps

module BUFIODQS (O, DQSMASK, I);

    parameter DQSMASK_ENABLE = "FALSE";      // TRUE, FALSE

    output O; 
    input DQSMASK; 
    input I; 

    reg delay_bypass_attr;
    reg dqsmask_enable_attr;

    wire o_out;

// Other signals
    reg attr_err_flag = 0;
    
//----------------------------------------------------------------------
//------------------------  Output Ports  ------------------------------
//----------------------------------------------------------------------
    buf buf_o(O, o_out);

    initial begin

//-------------------------------------------------
//----- DQSMASK_ENABLE  Check
//-------------------------------------------------
        case (DQSMASK_ENABLE)
            "TRUE" : dqsmask_enable_attr <= 1'b1;
            "FALSE" :dqsmask_enable_attr <= 1'b0;
            default : begin
                      $display("Attribute Syntax Error : The attribute DQSMASK_ENABLE on BUFIODQS instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE", DQSMASK_ENABLE);
                      attr_err_flag = 1;
                      end
        endcase // (DQSMASK_ENABLE)

    if (attr_err_flag)
       begin
       #1;
       $finish;
       end

    end  // initial begin

    reg q1, q2;
    wire clk, dglitch_en;

    assign clk = (dglitch_en == 1'b1) ? I : 1'b0;

    always @(DQSMASK or clk) begin
        if (DQSMASK == 1'b1) q1 = 0;
        else #(300) if (clk == 1) q1 = 1;
    end

    always @(DQSMASK or clk) begin
         if (DQSMASK == 1'b1) q2 = 0;
        else #(400) if (clk == 0) q2 = q1;
    end

    assign dglitch_en = (~q2 | DQSMASK);

    assign o_out = (DQSMASK_ENABLE == "TRUE") ?  clk : I;


endmodule // BUFIODQS
