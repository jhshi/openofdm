///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                       Device DNA Data Access Port
// /___/   /\     Filename : DNA_PORT.v
// \   \  /  \    Timestamp : Mon Oct 10 14:55:34 PDT 2005
//  \___\/\___\
//
// Revision:
//    10/10/05 - Initial version.
//    05/29/07 - Added wire declaration for internal signals
//    04/07/08 - CR 469973 -- Header Description fix
//    06/04/08 - CR 472697 -- added check for SIM_DNA_VALUE[56:55] 
//    09/18/08 - CR 488646 -- added period check for simprim 
//    10/28/08 - IR 494079 -- Shifting of dna_value is corrected to MSB first out
// End Revision

`timescale  1 ps / 1 ps

module DNA_PORT (DOUT, CLK, DIN, READ, SHIFT);

    parameter SIM_DNA_VALUE = 57'h0;

    output DOUT;

    input  CLK, DIN, READ, SHIFT;

    tri0  GSR = glbl.GSR;

    localparam MAX_DNA_BITS = 57;
    localparam MSB_DNA_BITS = MAX_DNA_BITS - 1;

    reg [MSB_DNA_BITS:0] dna_val = SIM_DNA_VALUE;
    reg dout_out;
    

    wire clk_in, din_in, gsr_in, read_in, shift_in;

    buf b_dout  (DOUT, dout_out);
    buf b_clk   (clk_in, CLK);
    buf b_din   (din_in, DIN);
    buf buf_gsr (gsr_in, GSR);
    buf b_read  (read_in, READ);
    buf b_shift (shift_in, SHIFT);

    initial begin
       dna_val = SIM_DNA_VALUE;
       if(dna_val[MSB_DNA_BITS : (MSB_DNA_BITS -1)] != 2'b10) begin
           $display("Attribute Syntax Warning : SIM_DNA_VALUE bits [56:55] on instance %m do not match the expected value \"10\". The simulation will not exactly model the hardware behavior, as detailed in the Spartan-3 Generation FPGA User Guide");
       end

    end

//  GSR has no effect
    
    always @(posedge clk_in) begin
       if(read_in == 1'b1) begin
          dna_val = SIM_DNA_VALUE;
          dout_out = 1'b1;
       end // read_in == 1'b1
       else if(read_in == 1'b0)
               if(shift_in == 1'b1) begin
// IR 494079
//                   dna_val = {din_in, dna_val[MSB_DNA_BITS :1]};
                   dna_val = {dna_val[MSB_DNA_BITS-1 : 0], din_in};
                   dout_out = dna_val[MSB_DNA_BITS];
               end  // shift_in == 1'b1
    end // always @ (posedge clk_in)


    specify

        (CLK => DOUT) = (100, 100);
        specparam PATHPULSE$ = 0;

    endspecify

endmodule // DNA_PORT
