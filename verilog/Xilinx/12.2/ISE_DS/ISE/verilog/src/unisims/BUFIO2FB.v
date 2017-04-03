///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2007 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  I/O Clock Buffer/Divider with Feedback for the Spartan Series
// /___/   /\     Filename : BUFIO2FB.v
// \   \  /  \    Timestamp : Fri Mar 21 13:47:03 PDT 2008
//  \___\/\___\
//
// Revision:
//    03/21/08 - Initial version.
// End Revision

`timescale  1 ps / 1 ps

module BUFIO2FB (O, I);

    parameter DIVIDE_BYPASS = "TRUE";      // TRUE, FALSE

    output O; 
    input I; 

    reg divclk_bypass_attr;

// Other signals
    reg attr_err_flag = 0;

//----------------------------------------------------------------------
//------------------------  Output Ports  ------------------------------
//----------------------------------------------------------------------
    buf buf_o(O, I);

    initial begin
//-------------------------------------------------
//----- DIVIDE_BYPASS  Check
//-------------------------------------------------
        case (DIVIDE_BYPASS)
            "TRUE" : divclk_bypass_attr <= 1'b1;
            "FALSE" :divclk_bypass_attr <= 1'b0;
            default : begin
                      $display("Attribute Syntax Error : The attribute DIVIDE_BYPASS on BUFIO2FB instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE", DIVIDE_BYPASS);
                      attr_err_flag = 1;
                      end
        endcase // (DIVIDE_BYPASS)

    if (attr_err_flag)
       begin
       #1;
       $finish;
       end

    end  // initial begin

endmodule // BUFIO2FB
