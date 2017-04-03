///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2007 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                   Differential Signaling Input Buffer for GTs
// /___/   /\     Filename : IBUFDS_GTXE1.v
// \   \  /  \    Timestamp : Wed Sep  3 23:37:39 PDT 2008
//  \___\/\___\
//
// Revision:
//    09/03/08 - Initial version.
// End Revision

`timescale  1 ps / 1 ps

module IBUFDS_GTXE1 (O, ODIV2, CEB, I, IB);


    parameter CLKCM_CFG = "TRUE";
    parameter CLKRCV_TRST = "TRUE";
    parameter [9:0] REFCLKOUT_DLY = 10'b0000000000;

    output O; 
    output ODIV2; 

    input CEB; 
    input I; 
    input IB; 

// Output signals 
    reg  O_out=0, ODIV2_out=0;
    

// Counters and Flags
    reg [2:0] ce_count = 1;
    reg [2:0] edge_count = 0;

    reg allEqual;

// Attribute settings

// Other signals
    reg clkcm_cfg_int = 0;
    reg clkrcv_trst_int = 0;
 
    reg attr_err_flag = 0;
    tri0  GSR = glbl.GSR;


    initial begin
        allEqual = 0;

//-------------------------------------------------
//----- CLKCM_CFG check
//-------------------------------------------------
        case (CLKCM_CFG)

            "FALSE" : clkcm_cfg_int <= 1'b0;
            "TRUE"  : clkcm_cfg_int <= 1'b1;
            default : begin
                          $display("Attribute Syntax Error : The attribute CLKCM_CFG on IBUFDS_GTXE1 instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE", CLKCM_CFG);
                          $finish;
                      end

        endcase // case(CLKCM_CFG)

//-------------------------------------------------
//----- CLKRCV_TRST check
//-------------------------------------------------
        case (CLKRCV_TRST)

            "FALSE" : clkrcv_trst_int <= 1'b0;
            "TRUE"  : clkrcv_trst_int <= 1'b1;
            default : begin
                          $display("Attribute Syntax Error : The attribute CLKRCV_TRST on IBUFDS_GTXE1 instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE", CLKRCV_TRST);
                          $finish;
                      end

        endcase // case(CLKRCV_TRST)

    end  // initial begin


//-----------------------------------------------------------------------------------
// =====================
// Count the rising edges of the clk
// =====================
    always @(posedge I) begin
         if(allEqual) 
             edge_count <= 3'b000;
          else
             if (CEB == 1'b0)  
                 edge_count <= edge_count + 1; 
     end 
          
//  Generate synchronous reset after DIVIDE number of counts
    always @(edge_count) 
        if (edge_count == ce_count) 
           allEqual = 1;
        else
          allEqual = 0;

// =====================
// Generate ODIV2
// =====================
    always @(posedge I)
        ODIV2_out <= allEqual;
 
// =====================
// Generate O
// =====================
    always @(I)
        O_out <= I & ~CEB;
 



    assign O  = O_out;
    assign ODIV2   = ODIV2_out;

    specify
       ( I => O) = (100, 100);
       ( I => ODIV2) = (100, 100);
       ( IB => O) = (100, 100);
       ( IB => ODIV2) = (100, 100);

       specparam PATHPULSE$ = 0;
    endspecify

endmodule // IBUFDS_GTXE1

