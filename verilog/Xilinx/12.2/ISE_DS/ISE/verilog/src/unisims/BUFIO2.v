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
// /___/   /\     Filename : BUFIO2.v
// \   \  /  \    Timestamp : Tue Feb 12 16:34:29 PST 2008
//  \___\/\___\
//
// Revision:
//    02/12/08 - Initial version.
//    08/19/08 - IR 479918 fix ... added 100 ps latency to unisim sequential paths.
//    10/16/08 - Added default timing to simprims
//    01/22/09 - Added attribute I_INVERT
//    02/03/09 - CR 506731 -- Add attribute USE_DOUBLER
//    02/06/09 - IR 507303 -- Removed 100 ps delay from DIVCLK
//    02/15/09 - CR 508344 -- Fixed USE_DOUBLER effects
//    02/25/09 - CR 508344 -- Rework DIVCLK when DIVIDE=1 and USE_DOUBLER=TRUE
//                         -- Fixed IOCLK to be the same as I.
//    02/25/09 - CR 509386 -- Added 100 ps delay to DIVCLK output
//    03/10/09 - CR 511512 -- Ingored x->1 transition at time=0 -- Verilog fix only
//    03/12/09 - CR 511597 -- DRC check for invalid combination -- USE_DOUBLER=TRUE and DIVIDE=1
//    07/07/09 - CR 526436 -- DRC check for DIVIDE_BYPASS{TRUE}/DIVIDE{2...8} combinations
//    09/09/09 - CR 531517 -- DRC check for invalid combination -- USE_DOUBLER=TRUE and I_INVERT=TRUE
//    12/07/09 - CR 540087 -- Aligned serdesstrobe to the falling edge of the divclk
//    02/18/10 - Reverted back the above CR
//    05/25/09 - CR 561858 -- when DDR/DIVIDE=even #s, DIVCLK/SERDESSTROBE should rise 1/2 period sooner than the current version 
// End Revision

`timescale  1 ps / 1 ps

module BUFIO2 (DIVCLK, IOCLK, SERDESSTROBE, I);



  parameter DIVIDE_BYPASS = "TRUE";    // TRUE, FALSE
  parameter integer DIVIDE = 1;        // {1..8}
  parameter I_INVERT = "FALSE";        // TRUE, FALSE
  parameter USE_DOUBLER = "FALSE";     // TRUE, FALSE


    output DIVCLK; 
    output IOCLK; 
    output SERDESSTROBE; 

    input I; 

// Output signals 
    reg  divclk_out=0, ioclk_out=0, serdesstrobe_out=0;

// Counters and Flags
    reg [2:0] ce_count = 0;
    reg [2:0] edge_count = 0;
    reg [2:0] RisingEdgeCount = 0;
    reg [2:0] FallingEdgeCount = 0;
    reg TriggerOnRise; // FP

    reg allEqual=0, RisingEdgeMatch=0, FallingEdgeMatch=0,  match=0, nmatch=0;
    reg divclk_bypass_attr;
    reg Ivert_attr;
    reg use_doubler_attr;

    reg divclk_int=0;

    reg I_int;
    reg i1_int,  i2_int;
    wire doubled_clk_int;

    wire div1_clk; 

// Attribute settings

// Other signals
    reg attr_err_flag = 0;
    tri0  GSR = glbl.GSR;
    


// Optional inverter for I 
    generate
      case (I_INVERT)
         "FALSE" : always @(I)  I_int <= I;
         "TRUE"  : always @(I)  I_int <= ~I;
      endcase
    endgenerate


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
            1 : begin
                  RisingEdgeCount  = 3'b000;
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
                      $display("Attribute Syntax Error : The attribute DIVIDE on BUFIO2 instance %m is set to %d.  Legal values for this attribute are 1, 2, 3, 4, 5, 6, 7 or 8.", DIVIDE);
                      attr_err_flag = 1;
                      end
        endcase // (DIVIDE)
//-------------------------------------------------
//----- DIVIDE_BYPASS  Check
//-------------------------------------------------
        case (DIVIDE_BYPASS)
            "TRUE" : divclk_bypass_attr <= 1'b1;
            "FALSE" :divclk_bypass_attr <= 1'b0;
            default : begin
                      $display("Attribute Syntax Error : The attribute DIVIDE_BYPASS on BUFIO2 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE", DIVIDE_BYPASS);
                      attr_err_flag = 1;
                      end
        endcase // (DIVIDE_BYPASS)

//-------------------------------------------------
//----- I_INVERT  Check
//-------------------------------------------------
        case (I_INVERT)
            "TRUE" : Ivert_attr <= 1'b1;
            "FALSE" :Ivert_attr <= 1'b0;
            default : begin
                      $display("Attribute Syntax Error : The attribute I_INVERT on BUFIO2 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE", I_INVERT);
                      attr_err_flag = 1;
                      end
        endcase // (I_INVERT)

//-------------------------------------------------
//----- USE_DOUBLER Check
//-------------------------------------------------
        case (USE_DOUBLER)
            "TRUE"  : use_doubler_attr <= 1'b1;
            "FALSE" : use_doubler_attr <= 1'b0;
            default : begin
                      $display("Attribute Syntax Error : The attribute USE_DOUBLER on BUFIO2 instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE", USE_DOUBLER);
                      attr_err_flag = 1;
                      end
        endcase // (USE_DOUBLER)

//-------------------------------------------------------------------
//----- Invalid combination DRC check for USE_DOUBLER = TRUE and DIVIDE=1
//-------------------------------------------------------------------
        case (USE_DOUBLER)
            "TRUE"  : 
                      if(DIVIDE == 1) begin
                        $display("DRC Error : The attribute USE_DOUBLER on BUFIO2 instance %m is set to %s when DIVIDE is set to 1.\n Legal values for DIVIDE when USE_DOUBLER = TRUE are: 2, 4, 6 or 8", USE_DOUBLER);
                      attr_err_flag = 1;
                      end
        endcase // (USE_DOUBLER == "TRUE" and DIVIDE == 1)

//-------------------------------------------------------------------
//----- Invalid combination DRC check for DIVIDE_BYPASS = TRUE and DIVIDE={2..8}
//-------------------------------------------------------------------
        case (DIVIDE_BYPASS)
            "TRUE"  : 
                      if(DIVIDE != 1) begin
                        $display("DRC Error : The attribute DIVIDE_BYPASS on BUFIO2 instance %m is set to TRUE when DIVIDE is set to %d.\n The DIVIDE_BYPASS must be set to FALSE for any DIVIDE value other than 1", DIVIDE);
                      attr_err_flag = 1;
                      end
        endcase // (UDIVIDE_BYPASS == "TRUE" and DIVIDE == {2..8})

//-------------------------------------------------------------------
//----- Invalid combination DRC check for USE_DOUBLER = TRUE and I_INVERT = TRUE 
//-------------------------------------------------------------------
        case (USE_DOUBLER)
            "TRUE"  : 
                      if(I_INVERT == "TRUE") begin
                        $display("DRC Error : The attribute I_INVERT on BUFIO2 instance %m is set to %s when USE_DOUBLER is set to TRUE.\n I_INVERT must be set to FALSE when USE_DOUBLER = TRUE", I_INVERT);
                      attr_err_flag = 1;
                      end
        endcase // (USE_DOUBLER == "TRUE" and I_INVERT == "TRUE")

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

    generate if  (USE_DOUBLER == "TRUE")
       begin
      // =====================
      // clock doubler
      // =====================
          always @(posedge I_int) begin
              i1_int = 1;
              #100 i1_int = 0;
          end

          always @(negedge I_int) begin
              i2_int = 1;
              #100  i2_int = 0;
          end

          assign doubled_clk_int = i1_int | i2_int;
       end
     else 
       assign doubled_clk_int = I_int; 
     endgenerate

// CR 561858  -- for various DIVIDE widths, the count is set differently to match the BUFIO2_2CLK's CR 512001  
// =====================
// Count the rising edges of the clk
// =====================
//    always @(posedge doubled_clk_int) begin
//       if(allEqual || $time < 1) 
//           edge_count <= 3'b000;
//        else
//           edge_count <= edge_count + 1; 
//    end 
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
    always @(I_int)
        ioclk_out <= I_int;
 
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
          match <= RisingEdgeMatch | (match & ~FallingEdgeMatch);

    always @(negedge doubled_clk_int)
         if(~TriggerOnRise) 
            nmatch <= match; 
         else 
            nmatch <= 0;   

    always@(match or nmatch) divclk_int = match | nmatch;

    always @(divclk_int or I_int)
         divclk_out = (divclk_bypass_attr | (DIVIDE == 1))? I_int : divclk_int;



    assign DIVCLK  = divclk_out;
    assign IOCLK   = ioclk_out;
    assign SERDESSTROBE = serdesstrobe_out;

    specify
        (I => DIVCLK) = (100, 100);
        (I => IOCLK) =  (0, 0);
        (I => SERDESSTROBE) = (100, 100);
        specparam PATHPULSE$ = 0;
    endspecify

endmodule // BUFIO2

