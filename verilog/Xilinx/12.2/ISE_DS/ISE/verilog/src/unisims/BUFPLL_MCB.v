///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2007 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Double Phase Locked Loop buffers for Spartan Series
// /___/   /\     Filename : BUFPLL_MCB.v
// \   \  /  \    Timestamp : Mon Jun  9 13:50:25 PDT 2008
//  \___\/\___\
//
// Revision:
//    08/12/08 - Initial version.
//    08/19/08 - IR 479918 fix ... added 100 ps latency to sequential paths.
//    03/25/09 - CR 516636  -- Fixed output clocks in simprim  
//    04/07/09 - CR 517605  -- Removed 100 ps path delays in simprims IOCLK{0/1}
//    11/04/09 - CR 537806  -- Removed extra timing arcs 
//    06/02/10 - CR 563356  -- Added  ports GCLK, LOCKED and LOCK
// End Revision

`timescale  1 ps / 1 ps

module BUFPLL_MCB (
  IOCLK0,
  IOCLK1,
  LOCK,
  SERDESSTROBE0,
  SERDESSTROBE1,

  GCLK,
  LOCKED,
  PLLIN0,
  PLLIN1
);



    parameter integer DIVIDE = 2;        // {1..8}
    parameter LOCK_SRC = "LOCK_TO_0";


    output IOCLK0;
    output IOCLK1;
    output LOCK;
    output SERDESSTROBE0;
    output SERDESSTROBE1;

    input GCLK;
    input LOCKED;
    input PLLIN0;
    input PLLIN1;


// Output signals 
    reg  ioclk0_out = 0, ioclk1_out = 0, lock_out = 0, serdesstrobe0_out = 0, serdesstrobe1_out = 0;

// Counters and Flags
    reg [2:0] ce_count = 0;
    reg [2:0] edge_count = 0;
    reg [2:0] RisingEdgeCount = 0;
    reg [2:0] FallingEdgeCount = 0;
    reg TriggerOnRise = 0;
    reg divclk_int;

    reg allEqual, RisingEdgeMatch, FallingEdgeMatch,  match, nmatch;

    reg lock_src_0_attr = 0, lock_src_1_attr= 0;

// Attribute settings

// Other signals
    reg attr_err_flag = 0;
    tri0  GSR = glbl.GSR;
    


    


    initial begin
        //--- clk 
        allEqual = 0;
        ce_count = DIVIDE - 1;
        match = 0;
        nmatch = 0;

//-------------------------------------------------
//----- DIVIDE check
//-------------------------------------------------
        case (DIVIDE)
            1 : begin
                  RisingEdgeCount = 3'b000;
                  FallingEdgeCount = 3'b000;
                  TriggerOnRise = 1; 
                end   

	    2 : begin
                  RisingEdgeCount  = 3'b001;
                  FallingEdgeCount = 3'b000;
                  TriggerOnRise = 1; 
                end

            3 : begin
                  RisingEdgeCount  = 3'b010;
                  FallingEdgeCount = 3'b000;
                  TriggerOnRise = 0; 
                end   

            4 : begin
                  RisingEdgeCount  = 3'b011;
                  FallingEdgeCount = 3'b001;
                  TriggerOnRise = 1; 
                end   

            5 : begin
                  RisingEdgeCount  = 3'b100;
                  FallingEdgeCount = 3'b001;
                  TriggerOnRise = 0; 
                end   

            6 : begin
                  RisingEdgeCount  = 3'b101;
                  FallingEdgeCount = 3'b010;
                  TriggerOnRise = 1; 
                end   

            7 : begin
                  RisingEdgeCount  = 3'b110;
                  FallingEdgeCount = 3'b010;
                  TriggerOnRise = 0; 
                end   

            8 : begin
                  RisingEdgeCount  = 3'b111;
                  FallingEdgeCount = 3'b011;
                  TriggerOnRise = 1; 
                end   

            default : begin
                      $display("Attribute Syntax Error : The attribute DIVIDE on BUFPLL_MCB instance %m is set to %d.  Legal values for this attribute are 1, 2, 3, 4, 5, 6, 7 or 8.", DIVIDE);
                      attr_err_flag = 1;
                      end
        endcase // (DIVIDE)

//-------------------------------------------------
//----- LOCK_SRC check
//-------------------------------------------------
        case (LOCK_SRC)
            "LOCK_TO_0"   : lock_src_0_attr  <= 1'b1;
            "LOCK_TO_1"   : lock_src_1_attr  <= 1'b1;
            default : begin
                      $display("Attribute Syntax Error : The attribute LOCK_SRC on BUFPLL_MCB instance %m is set to %s.  Legal values for this attribute are LOCK_TO_0 or LOCK_TO_1", LOCK_SRC);
                      attr_err_flag = 1;
                      end
        endcase // (LOCK_SRC)


//-------------------------------------------------
//------        Other Initializations      --------
//-------------------------------------------------

    if (attr_err_flag)
       begin
       #1;
       $finish;
       end


    end  // initial begin


// =====================
// Count the rising edges of the clk
// =====================
    generate if (LOCK_SRC == "LOCK_TO_0") 
       begin 
          always @(posedge PLLIN0) 
             if(allEqual) 
                 edge_count <= 3'b000;
              else
                 edge_count <= edge_count + 1; 
       end 
    else 
       begin 
          always @(posedge PLLIN1)
             if(allEqual) 
                 edge_count <= 3'b000;
              else
                 edge_count <= edge_count + 1; 
       end 
    endgenerate
          
//  Generate synchronous reset after DIVIDE number of counts
    always @(edge_count) 
        if (edge_count == ce_count) 
           allEqual = 1;
        else
          allEqual = 0;

// =====================
// Generate SERDESSTROBE 
// =====================
    generate if(LOCK_SRC == "LOCK_TO_0") 
     begin 
       always @(posedge PLLIN0)
           serdesstrobe0_out <= allEqual;
       always @(posedge PLLIN1)
           serdesstrobe1_out <= serdesstrobe0_out;
     end
    else 
     begin 
       always @(posedge PLLIN1)
           serdesstrobe1_out <= allEqual;
       always @(posedge PLLIN0)
           serdesstrobe0_out <= serdesstrobe1_out;
     end
    endgenerate
 
// =====================
// Generate divided clk 
// =====================
    always @(edge_count)
       if (edge_count == RisingEdgeCount)
           RisingEdgeMatch = 1;
       else
           RisingEdgeMatch = 0;

    always @(edge_count)
       if (edge_count == FallingEdgeCount)
           FallingEdgeMatch = 1;
       else
           FallingEdgeMatch = 0;

    generate if(LOCK_SRC == "LOCK_TO_0") 
       begin 
          always @(posedge PLLIN0)
             match <= RisingEdgeMatch | (match & ~FallingEdgeMatch);

          always @(negedge PLLIN0)
             if(~TriggerOnRise) 
                  nmatch <= match; 
               else 
                  nmatch <= 0;   
       end 
    else 
       begin 
          always @(posedge PLLIN1)
             match <= RisingEdgeMatch | (match & ~FallingEdgeMatch);

          always @(negedge PLLIN1)
             if(~TriggerOnRise) 
                  nmatch <= match; 
               else 
                  nmatch <= 0;   
       end 
    endgenerate

    always@(match or nmatch) divclk_int = match | nmatch;
// =====================
// Generate IOCLKs 
// =====================

    always @(PLLIN0)
         ioclk0_out = PLLIN0;

    always @(PLLIN1)
         ioclk1_out = PLLIN1;

// =====================
// Generate LOCK
// =====================
    always @(LOCKED)
         lock_out <= LOCKED;


    assign IOCLK0 = ioclk0_out;
    assign IOCLK1 = ioclk1_out;
    assign LOCK   = lock_out;
    assign SERDESSTROBE0 = serdesstrobe0_out;
    assign SERDESSTROBE1 = serdesstrobe1_out;

    specify
        ( PLLIN0 => IOCLK0) = (0, 0);
        ( PLLIN0 => IOCLK1) = (0, 0);
        ( PLLIN0 => LOCK)   = (0, 0);
        ( PLLIN0 => SERDESSTROBE0) = (100, 100);
        ( PLLIN0 => SERDESSTROBE1) = (100, 100);
        ( PLLIN1 => IOCLK0) = (0, 0);
        ( PLLIN1 => IOCLK1) = (0, 0);
        ( PLLIN1 => SERDESSTROBE0) = (100, 100);
        ( PLLIN1 => SERDESSTROBE1) = (100, 100);
    endspecify

endmodule // BUFPLL_MCB

