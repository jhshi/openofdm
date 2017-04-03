///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2007 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  I/O Clock Buffer/Divider for the Spartan Series
// /___/   /\     Filename : BUFIO2_2CLK.v
// \   \  /  \    Timestamp : Tue Feb 12 16:34:29 PST 2008
//  \___\/\___\
//
// Revision:
//    02/12/08 - Initial version.
//    08/19/08 - IR 479918 fix ... added 100 ps latency to sequential paths.
//    08/19/08 - IR 491038 fix ...  IOCLK is forwarded single clk
//    10/16/08 - DIVCLK needs to get doubled input clock
//    12/01/08 - IR 497760 fix
//    02/25/09 - CR 509386 -- Added 100 ps delay to DIVCLK output
//    03/10/09 - CR 511512 -- Ingored x->1 transition at time=0 -- Verilog fix only 
//    03/18/09 - CR 511597 -- Disallow DIVIDE=1 
//    04/29/09 - CR 512001 -- Matched the hw latency at startup for various DIVIDEs 
//    09/09/09 - CR 531517 -- Added I_INVERT support feature -- Simprim Only
//    12/08/09 - CR 540087 -- Aligned serdesstrobe to the falling edge of the divclk
//    02/18/10 - Revert above CR
// End Revision

`timescale  1 ps / 1 ps

module BUFIO2_2CLK (DIVCLK, IOCLK, SERDESSTROBE, I, IB);



  parameter integer DIVIDE = 2;        // {2..8}


    output DIVCLK; 
    output IOCLK; 
    output SERDESSTROBE; 

    input I; 
    input IB; 

// Output signals 
    reg  divclk_out=0, ioclk_out=0, serdesstrobe_out=0;

// Counters and Flags
    reg [2:0] ce_count = 0;
    reg [2:0] edge_count = 0;
    reg [2:0] RisingEdgeCount = 0;
    reg [2:0] FallingEdgeCount = 0;
    reg TriggerOnRise; // FP

    reg allEqual=0, RisingEdgeMatch=0, FallingEdgeMatch=0,  match=0, nmatch=0;

    reg divclk_int=0;
    reg i1_int=0, i2_int=0;

// Attribute settings

// Other signals
    reg attr_err_flag = 0;
    tri0  GSR = glbl.GSR;


    initial begin
        ce_count = DIVIDE - 1;
        allEqual = 0;
        match = 0;
        nmatch = 0;
// FP        #1;
//-------------------------------------------------
//----- DIVIDE check
//-------------------------------------------------
        case (DIVIDE)
//            1 : begin
//                  RisingEdgeCount  = 3'b000;
//                  FallingEdgeCount = 3'b000;
//                  TriggerOnRise = 1; 
//                end   

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
                      $display("Attribute Syntax Error : The attribute DIVIDE on BUFIO2_2CLK instance %m is set to %d.  Legal values for this attribute are 2, 3, 4, 5, 6, 7 or 8.", DIVIDE);
                      attr_err_flag = 1;
                      end
        endcase // (DIVIDE)

//-------------------------------------------------
//------        Other Initializations      --------
//-------------------------------------------------

    if (attr_err_flag)
       begin
       #1;
       $finish;
       end


    end  // initial begin


//-----------------------------------------------------------------------------------

// =====================
// clock doubler
// =====================
    always @(posedge I) begin
        i1_int = 1;
        #100 i1_int = 0;
    end

    always @(posedge IB) begin
        i2_int = 1;
        #100  i2_int = 0;
    end

    assign doubled_clk_int = i1_int | i2_int;


// =====================
// Count the rising edges of the clk
// =====================
// CR 512001  -- for various DIVIDE widths, the count is set differently to match the hw startup      
   generate
      case(DIVIDE)
         2,4,6,8 : begin

                    always @(posedge doubled_clk_int) begin
                       if($time < 1 )
                            edge_count <= DIVIDE-1;   //001  for 5 and 7
                       else if (allEqual)
                            edge_count <= 3'b000;
                       else
                            edge_count <= edge_count + 1;
                    end
         end
         3,5,7 : begin
               //for 1, 3, 5 and 7 below

                    always @(posedge doubled_clk_int) begin
                       if($time < 1 )
                            edge_count <= 3'b001;   //001  for 5 and 7
                       else if (allEqual)
                            edge_count <= 3'b000;
                       else
                            edge_count <= edge_count + 1;
                    end
        end
      endcase
    endgenerate
 
//  Generate synchronous reset after DIVIDE number of counts
    always @(edge_count) 
        if (edge_count == ce_count) 
           allEqual = 1;
        else
          allEqual = 0;

// =====================
// Generate IOCE
// =====================
    always @(posedge doubled_clk_int)
        serdesstrobe_out <= allEqual;
 
// =====================
// Generate IOCLK
// =====================
    always @(I)
        ioclk_out <= I;
 
// =====================
// Generate Divided Clock
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

    always @(posedge doubled_clk_int)
//       if (GSR == 1'b0) 
          match <= RisingEdgeMatch | (match & ~FallingEdgeMatch);

    always @(negedge doubled_clk_int)
//       if (GSR == 1'b0) 
         if(~TriggerOnRise) 
            nmatch <= match; 
         else 
            nmatch <= 0;   

    always@(match or nmatch) divclk_int = match | nmatch;

// IR 497760 fix
    always @(divclk_int or doubled_clk_int)
         divclk_out = (DIVIDE == 1)? ioclk_out : divclk_int;




    assign DIVCLK  = divclk_out;
    assign IOCLK   = ioclk_out;
    assign SERDESSTROBE = serdesstrobe_out;
    specify

        (I *> DIVCLK) = (100, 100);
        (I *> IOCLK) =  (0, 0);
        (I *> SERDESSTROBE) = (100, 100);
        (IB *> DIVCLK) = (100, 100);
        (IB *> IOCLK) =  (0, 0);
        (IB *> SERDESSTROBE) = (100, 100);
    endspecify

endmodule // BUFIO2_2CLK

