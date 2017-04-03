///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  3-State Diffential Signaling I/O Buffer
// /___/   /\     Filename : IOBUFDS_DIFF_OUT.v
// \   \  /  \    Timestamp : Mon Jan 19 10:23:13 PST 2009
//  \___\/\___\
//
// Revision:
//    01/19/09 - Initial version.
//    01/28/09 - Reflected RC's feedback.
//    06/02/09 - CR 523083 -- Added attribute IBUF_LOW_PWR.
// End Revision

`timescale  1 ps / 1 ps


module IOBUFDS_DIFF_OUT (O, OB, IO, IOB, I, TM, TS);

    parameter DIFF_TERM = "FALSE";
    parameter IBUF_LOW_PWR = "TRUE";
    parameter IOSTANDARD = "DEFAULT";

    output O;
    output OB;
    inout  IO;
    inout  IOB;
    input  I;
    input  TM;
    input  TS;

    wire t1, t2;

    tri0 GTS = glbl.GTS;

    reg O, OB;
    
    or O1 (t1, GTS, TM);
    bufif0 B1 (IO, I, t1);

    or O2 (t2, GTS, TS);
    notif0 N2 (IOB, I, t2);

    initial begin
	
        case (DIFF_TERM)

            "TRUE", "FALSE" : ;
            default : begin
                          $display("Attribute Syntax Error : The attribute DIFF_TERM on IOBUFDS_DIFF_OUT instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", DIFF_TERM);
                          $finish;
                      end

        endcase // case(DIFF_TERM)
        case (IBUF_LOW_PWR)

            "FALSE", "TRUE" : ;
            default : begin
                          $display("Attribute Syntax Error : The attribute IBUF_LOW_PWR on IOBUFDS_DIFF_OUT instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", IBUF_LOW_PWR);
                          $finish;
                      end

        endcase

    end


    always @(IO or IOB) begin
        if (IO == 1'b1 && IOB == 1'b0) begin
            O  = IO;
            OB = ~IO;
        end
        else if (IO == 1'b0 && IOB == 1'b1) begin
            O  = IO;
            OB = ~IO;
        end
        else begin
            O  = 1'bx;
            OB = 1'bx;
        end
    end
    
endmodule
