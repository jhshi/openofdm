// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/blanc/AUTOBUF.v,v 1.3 2009/08/21 23:55:39 harikr Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Clock Buffer
// /___/   /\     Filename : AUTOBUF.v
// \   \  /  \    Timestamp : 
//  \___\/\___\
//
// Revision:
//    04/08/08 - Initial version.
//    07/23/09 - Add more attrute values (CR521811)
// End Revision

`timescale  1 ps / 1 ps


module AUTOBUF (O, I);

    parameter BUFFER_TYPE = "AUTO";

    output O;

    input  I;

    initial begin
    case (BUFFER_TYPE)
      "AUTO" : ;
      "BUF" : ;
      "BUFG" : ;
      "BUFGP" : ;
      "BUFH" : ;
      "BUFIO" : ;
      "BUFIO2" : ;
      "BUFIO2FB" : ;
      "BUFR" : ;
      "IBUF" : ;
      "IBUFG" : ;
      "NONE" : ;
      "OBUF" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute BUFFER_TYPE on AUTOBUF instance %m is set to %s.  Legal values for this attribute are AUTO, BUF, BUFG, BUFGP, BUFH, BUFIO, BUFIO2, BUFIO2FB, BUFR, IBUF, IBUFG, NONE, and OBUF.", BUFFER_TYPE);
      end
    endcase
    end

	buf B1 (O, I);


endmodule

