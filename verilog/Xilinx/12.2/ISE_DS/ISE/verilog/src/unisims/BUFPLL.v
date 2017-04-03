///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2007 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Phase Locked Loop buffer for Spartan Series
// /___/   /\     Filename : BUFPLL.v
// \   \  /  \    Timestamp : Mon Jun  9 13:50:25 PDT 2008
//  \___\/\___\
//
// Revision:
//    06/09/08 - Initial version.
//    08/19/08 - IR 479918 -- added 100 ps latency to sequential paths.
//    02/10/09 - IR 505709 -- correlate SERDESSTROBE to GLCK
//    03/24/09 - CR 514119 -- sync output to LOCKED high signal 
//    06/16/09 - CR 525221 -- added ENABLE_SYNC attribute
// End Revision

`timescale  1 ps / 1 ps

module BUFPLL (IOCLK, LOCK, SERDESSTROBE, GCLK, LOCKED, PLLIN);



    parameter integer DIVIDE = 1;        // {1..8}
    parameter ENABLE_SYNC = "TRUE";


    output IOCLK;
    output LOCK;
    output SERDESSTROBE;

    input GCLK;
    input LOCKED;
    input PLLIN;


// Output signals 
    reg  ioclk_out = 0, lock_out = 0, serdesstrobe_out = 0;

// Counters and Flags
    reg [2:0] ce_count = 0;
    reg [2:0] edge_count = 0;
    reg [2:0] RisingEdgeCount = 0;
    reg [2:0] FallingEdgeCount = 0;
    reg TriggerOnRise = 0; 
    reg divclk_int;

    reg allEqual, RisingEdgeMatch, FallingEdgeMatch,  match, nmatch;

    reg lock_src_indepn_attr = 0, lock_src_0_attr = 0, lock_src_1_attr= 0;

    reg  enable_sync_strobe_out = 0, strobe_out = 0;

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
                      $display("Attribute Syntax Error : The attribute DIVIDE on BUFPLL instance %m is set to %d.  Legal values for this attribute are 1, 2, 3, 4, 5, 6, 7 or 8.", DIVIDE);
                      attr_err_flag = 1;
                      end
        endcase // (DIVIDE)

        //-------- ENABLE_SYNC

        case (ENABLE_SYNC)
            "TRUE", "FALSE" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute ENABLE_SYNC on BUFPLL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.",  ENABLE_SYNC);
               $finish;
            end
        endcase

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
    always @(posedge PLLIN) begin
       if(allEqual) 
           edge_count <= 3'b000;
        else
           edge_count <= edge_count + 1; 
     end 
          
//  Generate synchronous reset after DIVIDE number of counts
    always @(edge_count) 
        if (edge_count == ce_count) 
           allEqual = 1;
        else
          allEqual = 0;

// =======================================
// Generate SERDESSTROBE when ENABLE_SYNC 
// =======================================
    reg time_cal = 0;
    time clkin_edge = 0;
    time clkin_period = 0;
    time start_wait_time = 0;
    time end_wait_time = 0;

    always @(posedge PLLIN)
    begin
      if((time_cal == 0) && (LOCKED == 1'b1)) begin
        clkin_edge <= $time;
         if (clkin_edge != 0 ) begin
           clkin_period = $time - clkin_edge;
           time_cal <= 1;

           start_wait_time <= (clkin_period)* ((2.0 *(DIVIDE-1))/4.0);
           end_wait_time <= clkin_period;
         end
      end
    end

    generate
      case(DIVIDE)
        1: begin
             always @(posedge GCLK)
             begin
                 if(time_cal == 1) begin
                    #start_wait_time;
                   enable_sync_strobe_out <= 1'b1;
                 end
             end
           end

        2, 3, 4, 5, 6, 7, 8: begin
             always @(posedge GCLK)
             begin
                 if(time_cal == 1) begin
                    #start_wait_time;
                    enable_sync_strobe_out <= 1'b1;
                    #end_wait_time;
                    enable_sync_strobe_out <= 1'b0;
                 end
             end
           end
      endcase
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

    always @(posedge PLLIN)
       match <= RisingEdgeMatch | (match & ~FallingEdgeMatch);

    always @(negedge PLLIN)
       if(~TriggerOnRise) 
            nmatch <= match; 
         else 
            nmatch <= 0;   

    always@(match or nmatch) divclk_int = match | nmatch;

    always @(PLLIN)
         ioclk_out <= PLLIN;

// =====================
// Generate strobe_out 
// =====================
    always @(posedge PLLIN)
         strobe_out <= allEqual;

// =========================
// Generate serdesstrobe_out
// =========================

    always @(strobe_out or enable_sync_strobe_out)
         serdesstrobe_out = (ENABLE_SYNC == "TRUE")? enable_sync_strobe_out : strobe_out;

// =====================
// Generate LOCK 
// =====================
    always @(LOCKED)
         lock_out <= LOCKED;



    assign IOCLK = ioclk_out;
    assign LOCK  = lock_out;
    assign SERDESSTROBE = serdesstrobe_out;

    specify
        ( PLLIN => IOCLK) = (0, 0);
        ( PLLIN => LOCK)  = (0, 0);
        ( PLLIN => SERDESSTROBE) = (100, 100);
    endspecify

endmodule // BUFPLL

