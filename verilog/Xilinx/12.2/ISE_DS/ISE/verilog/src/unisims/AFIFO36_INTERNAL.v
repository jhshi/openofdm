// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/rainier/AFIFO36_INTERNAL.v,v 1.20 2009/09/10 19:45:20 wloo Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : This is not an user primitive.
//  /   /                  Xilinx Functional Simulation Library Component 36K-Bit FIFO.
// /___/   /\     Filename : AFIFO36_INTERNAL.v
// \   \  /  \    Timestamp : Tues July 26 16:44:06 PST 2005
//  \___\/\___\
//
// Revision:
//    07/26/05 - Initial version.
//    12/16/05 - Added independent read and write ecc features.
//    08/16/06 - Fixed the faulty deassign for invalid rst (CR 234092).
//    10/16/06 - Fixed the unused bits of wrcount and rdcount to match the hardware (CR 426347).
//    01/24/07 - Removed DRC warning for RST in ECC mode (CR 432367).
//    06/01/07 - Added wire declaration for internal signals.
//    06/14/07 - Implemented high performace version of the model.
//    10/26/07 - Changed wren_in to wren_reg to fix FULL flag (CR 452554).
//    11/06/08 - Added DRC for invalid input parity for ECC (CR 482976).
//    03/25/09 - Implemented DRC check for ALMOST_EMPTY_OFFSET (CR 511589).
//    09/10/09 - No ALMOST_EMPTY_OFFSET check when RST is high (CR 531946).
// End Revision

`timescale 1 ps/1 ps

module AFIFO36_INTERNAL (ALMOSTEMPTY, ALMOSTFULL, DBITERR, DO, DOP, ECCPARITY, EMPTY, FULL, RDCOUNT, RDERR, SBITERR, WRCOUNT, WRERR,
			DI, DIP, RDCLK, RDEN, RDRCLK, RST, WRCLK, WREN);
 
    output ALMOSTEMPTY;
    output ALMOSTFULL;
    output DBITERR;
    output [63:0] DO;
    output [7:0] DOP;
    output [7:0] ECCPARITY;
    output EMPTY;
    output FULL;
    output [12:0] RDCOUNT;
    output RDERR;
    output SBITERR;
    output [12:0] WRCOUNT;
    output WRERR;

    input [63:0] DI;
    input [7:0] DIP;
    input RDCLK;
    input RDEN;
    input RDRCLK;
    input RST;
    input WRCLK;
    input WREN;

    tri0 GSR = glbl.GSR;
    
    parameter integer DATA_WIDTH = 4;
    parameter integer DO_REG = 1;
    parameter EN_SYN = "FALSE";
    parameter FIRST_WORD_FALL_THROUGH = "FALSE";
    parameter ALMOST_EMPTY_OFFSET = 13'h0080;
    parameter ALMOST_FULL_OFFSET = 13'h0080;
    parameter EN_ECC_WRITE = "FALSE";
    parameter EN_ECC_READ = "FALSE";
    parameter SIM_MODE = "SAFE";
    
    reg [63:0] do_in = 64'b0;
    reg [63:0] do_out = 64'b0;
    reg [63:0] do_outreg = 64'b0;
    reg [63:0] do_out_mux = 64'b0;
    wire [63:0] do_out_out;
    reg [7:0] dop_in = 8'b0, dop_out = 8'b0;
    wire [7:0] dop_out_out;
    reg [7:0] dop_outreg = 8'b0, dop_out_mux = 8'b0;
    reg almostempty_out = 1'b1, almostfull_out = 1'b0, empty_out = 1'b1;
    reg full_out = 1'b0, rderr_out = 0, wrerr_out = 0;

    reg dbiterr_out = 0, sbiterr_out = 0;
    reg dbiterr_out_out = 0, sbiterr_out_out = 0;
    reg [71:0] ecc_bit_position;    
    reg [7:0] eccparity_out;
    reg [7:0] dopr_ecc, dop_buf, dip_ecc, dip_int;
    reg [63:0] do_buf, di_in_ecc_corrected;
    reg [7:0] syndrome, dip_in_ecc_corrected;

    wire [63:0] di_in;
    wire [7:0] dip_in;
    wire rdclk_in, rden_in, rst_in, wrclk_in, wren_in;
    wire rdrclk_in, gsr_in;
    
    reg rden_reg, wren_reg;
    reg [12:0] ae_empty, ae_full;
    reg fwft;

    integer addr_limit, rd_prefetch = 0;
    integer wr1_addr = 0;

    reg [12:0] rdcount_out = 13'b0, wr_addr = 0, rd_addr = 0;
    reg [12:0] rdcount_out_out = 13'h1fff, wr_addr_out = 13'h1fff;
    reg rd_flag = 0, rdcount_flag = 0, rdprefetch_flag = 0, wr_flag = 0;
    reg wr1_flag = 0, awr_flag = 0;
    reg [3:0] almostfull_int = 4'b0000, almostempty_int = 4'b1111;

    reg [3:0] full_int = 4'b0000;
    reg [3:0] empty_ram = 4'b1111;
    reg [8:0] i, j;
    reg rst_tmp1 = 0, rst_tmp2 = 0;
    reg [2:0] rst_rdckreg = 3'b0, rst_wrckreg = 3'b0;
    reg rst_rdclk_flag = 0, rst_wrclk_flag = 0;

    integer aempty_flag = 0, afull_flag = 0;
    time rise_rdclk, period_rdclk, rise_wrclk, period_wrclk;
    
// xilinx_internal_parameter on
    // WARNING !!!: This model may not work properly if the following parameter is changed.
    parameter integer FIFO_SIZE = 36;
// xilinx_internal_parameter off
    
    localparam mem_size4 = (FIFO_SIZE == 18) ? 4095 : (FIFO_SIZE == 36) ? 8191 : 0;
    localparam mem_size9 = (FIFO_SIZE == 18) ? 2047 : (FIFO_SIZE == 36) ? 4095 : 0;
    localparam mem_size18 = (FIFO_SIZE == 18) ? 1023 : (FIFO_SIZE == 36) ? 2047 : 0;
    localparam mem_size36 = (FIFO_SIZE == 18) ? 511 : (FIFO_SIZE == 36) ? 1023 : 0;
    localparam mem_size72 = (FIFO_SIZE == 18) ? 0 : (FIFO_SIZE == 36) ? 511 : 0;

    localparam mem_depth = (DATA_WIDTH == 4) ? mem_size4 : (DATA_WIDTH == 9) ? mem_size9 :
			   (DATA_WIDTH == 18) ? mem_size18 : (DATA_WIDTH == 36) ? mem_size36 : 
			   (DATA_WIDTH == 72) ? mem_size72 : 0;

    
    localparam mem_width = (DATA_WIDTH == 4) ? 3 : (DATA_WIDTH == 9) ? 7 :
			   (DATA_WIDTH == 18) ? 15 : (DATA_WIDTH == 36) ? 31 : (DATA_WIDTH == 72) ? 63 : 0;


    localparam memp_depth = (DATA_WIDTH == 4) ? 0 : (DATA_WIDTH == 9) ? mem_size9 :
			    (DATA_WIDTH == 18) ? mem_size18 : (DATA_WIDTH == 36) ? mem_size36 : 
			    (DATA_WIDTH == 72) ? mem_size72 : 0;

    
    localparam memp_width = (DATA_WIDTH == 4 || DATA_WIDTH == 9) ? 0 :
			    (DATA_WIDTH == 18) ? 1 : (DATA_WIDTH == 36) ? 3 : (DATA_WIDTH == 72) ? 7 : 0;

    reg [mem_width : 0] mem [mem_depth : 0];
    reg [memp_width : 0] memp [memp_depth : 0];
    reg sync;

    initial
	if ((SIM_MODE != "FAST") && (SIM_MODE != "SAFE")) begin
	    $display("Attribute Syntax Error : The attribute SIM_MODE on AFIFO36_INTERNAL instance %m is set to %s.  Legal values for this attribute are FAST or SAFE.", SIM_MODE);
	    $finish;
	    
	end


    
/********************* SAFE mode **************************/
    generate if (SIM_MODE == "SAFE") begin
	
    buf b_di[63:0] (di_in, DI);
    buf b_dip[7:0] (dip_in, DIP);
    buf b_do[63:0] (DO, do_out_out);
    buf b_dop[7:0] (DOP, dop_out_out);
    buf b_rdclk (rdclk_in, RDCLK);
    buf b_rdrclk (rdrclk_in, RDRCLK);
    buf b_rden (rden_in, RDEN);
    buf b_rst (rst_in, RST);
    buf b_wrclk (wrclk_in, WRCLK);
    buf b_wren (wren_in, WREN);
    buf b_in5 (gsr_in, GSR);

    buf b_out0 (ALMOSTEMPTY, almostempty_out);
    buf b_out1 (ALMOSTFULL, almostfull_out);
    buf b_empty (EMPTY, empty_out);
    buf b_full (FULL, full_out);
    buf b_rderr (RDERR, rderr_out);
    buf b_wrerr (WRERR, wrerr_out);    
    buf b_sbiterr (SBITERR, sbiterr_out_out);
    buf b_dbiterr (DBITERR, dbiterr_out_out);
    buf b_eccparity[7:0] (ECCPARITY, eccparity_out);
    buf b_rdcount[12:0] (RDCOUNT, rdcount_out_out);
    buf b_wrcount[12:0] (WRCOUNT, wr_addr_out);


    always @(gsr_in)
	if (gsr_in == 1'b1) begin
	    assign do_out = 64'b0;
	    assign dop_out = 8'b0;
	    assign do_outreg = 64'b0;
	    assign dop_outreg = 8'b0;
	end
	else if (gsr_in == 1'b0) begin
	    deassign do_out;
	    deassign dop_out;
	    deassign do_outreg;
	    deassign dop_outreg;
	end

    always @(gsr_in or rst_in)
	if (gsr_in == 1'b1 || rst_in == 1'b1) begin
	    assign almostempty_int = 4'b1111;
	    assign almostempty_out = 1'b1;
	    assign almostfull_int = 4'b0000;
	    assign almostfull_out = 1'b0;
	    assign do_in = 64'b00000000000000000000000000000000;
	    assign dop_in = 8'b0000;
	    assign empty_ram = 4'b1111;
	    assign empty_out = 1'b1;
	    assign full_int = 4'b0000;
	    assign full_out = 1'b0;
	    assign rdcount_out = 13'b0;
	    assign rdcount_out_out = 13'b0;
	    assign wr_addr_out = 13'b0;
	    assign rderr_out = 0;
	    assign wrerr_out = 0;
	    assign sbiterr_out_out = 1'b0;
	    assign dbiterr_out_out = 1'b0;
	    assign rd_addr = 0;
	    assign rd_prefetch = 0;
	    assign wr_addr = 0;
	    assign wr1_addr = 0;
	    assign rdcount_flag = 0;
	    assign rd_flag = 0;
	    assign rdprefetch_flag = 0;
	    assign wr_flag = 0;
	    assign wr1_flag = 0;
	    assign awr_flag = 0;
	end
	else if (gsr_in == 1'b0 && rst_in == 1'b0) begin
	    deassign almostempty_int;
	    deassign almostempty_out;
	    deassign almostfull_int;
	    deassign almostfull_out;
	    deassign do_in;
	    deassign dop_in;
	    deassign empty_ram;
	    deassign empty_out;
	    deassign full_int;
	    deassign full_out;
	    deassign rdcount_out;
	    deassign rdcount_out_out;
            deassign wr_addr_out;
	    deassign rderr_out;
	    deassign wrerr_out;
	    deassign sbiterr_out_out;
	    deassign dbiterr_out_out;
	    deassign rd_addr;
	    deassign rd_prefetch;
	    deassign wr_addr;
	    deassign wr1_addr;
	    deassign rdcount_flag;
	    deassign rd_flag;
	    deassign rdprefetch_flag;
	    deassign wr_flag;
	    deassign wr1_flag;
	    deassign awr_flag;	    
	end

    initial begin

	case (DATA_WIDTH)
	    4 : begin
		    if (FIFO_SIZE == 36)
			addr_limit = 8192;
		    else
			addr_limit = 4096;
		end
	    9 : begin
		    if (FIFO_SIZE == 36)
			addr_limit = 4096;
		    else
			addr_limit = 2048;
		end
	   18 : begin
	            if (FIFO_SIZE == 36)
			addr_limit = 2048;
		    else
			addr_limit = 1024;
		end
	   36 : begin
	            if (FIFO_SIZE == 36)
			addr_limit = 1024;
		    else
			addr_limit = 512;
		end
	   72 : begin
		    addr_limit = 512;
		end
	   default :
		begin
		    $display("Attribute Syntax Error : The attribute DATA_WIDTH on AFIFO36_INTERNAL instance %m is set to %d.  Legal values for this attribute are 4, 9, 18, 36 or 72.", DATA_WIDTH);
		    $finish;
		end
	endcase

	
	case (EN_SYN)
	    "FALSE" : sync = 0;
	    "TRUE" : sync = 1;
	    default : begin
		          $display("Attribute Syntax Error : The attribute EN_SYN on AFIFO36_INTERNAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EN_SYN);
		          $finish;
	              end
	endcase // case(EN_SYN)


	case (FIRST_WORD_FALL_THROUGH)
	    "FALSE" : begin
		          fwft = 0;
		          if (EN_SYN == "FALSE") begin
			      ae_empty = ALMOST_EMPTY_OFFSET - 1;
	                      ae_full = ALMOST_FULL_OFFSET;
			  end
			  else begin
			      ae_empty = ALMOST_EMPTY_OFFSET;
	                      ae_full = ALMOST_FULL_OFFSET;
			  end
		      end
	    "TRUE"  : begin
		          fwft = 1;
		          ae_empty = ALMOST_EMPTY_OFFSET - 2;
	                  ae_full = ALMOST_FULL_OFFSET;
	              end
	    default : begin
		$display("Attribute Syntax Error : The attribute FIRST_WORD_FALL_THROUGH on AFIFO36_INTERNAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", FIRST_WORD_FALL_THROUGH);
		$finish;
	      end
	endcase

	
	if (EN_SYN == "FALSE") begin

	    if (fwft == 1'b0) begin
	    
		if ((ALMOST_EMPTY_OFFSET < 5) || (ALMOST_EMPTY_OFFSET > addr_limit - 5)) begin
		    $display("Attribute Syntax Error : The attribute ALMOST_EMPTY_OFFSET on AFIFO36_INTERNAL instance %m is set to %d.  Legal values for this attribute are %d to %d", ALMOST_EMPTY_OFFSET, 5, addr_limit - 5);
		    $finish;
		end
		
		if ((ALMOST_FULL_OFFSET < 4) || (ALMOST_FULL_OFFSET > addr_limit - 5)) begin
		    $display("Attribute Syntax Error : The attribute ALMOST_FULL_OFFSET on AFIFO36_INTERNAL instance %m is set to %d.  Legal values for this attribute are %d to %d", ALMOST_FULL_OFFSET, 4, addr_limit - 5);
		    $finish;
		end
		
	    end // if (fwft == 1'b0)
	    else begin
		
		if ((ALMOST_EMPTY_OFFSET < 6) || (ALMOST_EMPTY_OFFSET > addr_limit - 4)) begin
		    $display("Attribute Syntax Error : The attribute ALMOST_EMPTY_OFFSET on AFIFO36_INTERNAL instance %m is set to %d.  Legal values for this attribute are %d to %d", ALMOST_EMPTY_OFFSET, 6, addr_limit - 4);
		    $finish;
		end
		
		if ((ALMOST_FULL_OFFSET < 4) || (ALMOST_FULL_OFFSET > addr_limit - 5)) begin
		    $display("Attribute Syntax Error : The attribute ALMOST_FULL_OFFSET on AFIFO36_INTERNAL instance %m is set to %d.  Legal values for this attribute are %d to %d", ALMOST_FULL_OFFSET, 4, addr_limit - 5);
		    $finish;
		end

	    end // else: !if(fwft == 1'b0)
	end
	else begin

	    if ((fwft == 1'b0) && ((ALMOST_EMPTY_OFFSET < 1) || (ALMOST_EMPTY_OFFSET > addr_limit - 2))) begin
		$display("Attribute Syntax Error : The attribute ALMOST_EMPTY_OFFSET on AFIFO36_INTERNAL instance %m is set to %d.  Legal values for this attribute are %d to %d", ALMOST_EMPTY_OFFSET, 1, addr_limit - 2);
		$finish;
	    end
	    
	    if ((fwft == 1'b0) && ((ALMOST_FULL_OFFSET < 1) || (ALMOST_FULL_OFFSET > addr_limit - 2))) begin
		$display("Attribute Syntax Error : The attribute ALMOST_FULL_OFFSET on AFIFO36_INTERNAL instance %m is set to %d.  Legal values for this attribute are %d to %d", ALMOST_FULL_OFFSET, 1, addr_limit - 2);
		$finish;
	    end

	end // else: !if(EN_SYN == "FALSE")
	
	
	// DRC for fwft in sync mode
	if (fwft == 1'b1 && EN_SYN == "TRUE") begin
	    $display("DRC Error : First word fall through is not supported in synchronous mode on AFIFO36_INTERNAL instance %m.");
	    $finish;
	end

	if (EN_SYN == "FALSE" && DO_REG == 0) begin
	    $display("DRC Error : DO_REG = 0 is invalid when EN_SYN is set to FALSE on AFIFO36_INTERNAL instance %m.");
	    $finish;
	end
	

	if (!(EN_ECC_WRITE == "TRUE" || EN_ECC_WRITE == "FALSE")) begin
	    $display("Attribute Syntax Error : The attribute EN_ECC_WRITE on AFIFO36_INTERNAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EN_ECC_WRITE);
	    $finish;
	end

	
	if (!(EN_ECC_READ == "TRUE" || EN_ECC_READ == "FALSE")) begin
	    $display("Attribute Syntax Error : The attribute EN_ECC_READ on AFIFO36_INTERNAL instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.", EN_ECC_READ);
	    $finish;
	end

	
	if ((EN_ECC_READ == "TRUE" || EN_ECC_WRITE == "TRUE") && DATA_WIDTH != 72) begin
	    $display("DRC Error : The attribute DATA_WIDTH must be set to 72 when AFIFO36_INTERNAL is configured in the ECC mode.");
	    $finish;
	end


    end // initial begin
    

    always @(rst_in or rden_in or wren_in) begin
        if (rst_in ==1 && rden_in==1 )
            $display("Warning : At time %t,  RDEN on AFIFO36_INTERNAL instance %m is high when RST is high. RDEN should be low during reset.", $stime);
        if (rst_in ==1 && wren_in ==1)
            $display("Warning : At time %t,  WREN on AFIFO36_INTERNAL instance %m is high when RST is high. WREN should be low during reset.", $stime);
    end

    always @(posedge rdclk_in) begin
          rst_rdckreg[0] <= rst_in;
          rst_rdckreg[1] <= rst_rdckreg[0] & rst_in;
          rst_rdckreg[2] <= rst_rdckreg[1] & rst_in;
    end

    always @(posedge wrclk_in) begin
          rst_wrckreg[0] <= rst_in ;
          rst_wrckreg[1] <= rst_wrckreg[0] & rst_in;
          rst_wrckreg[2] <= rst_wrckreg[1] & rst_in;
    end

    always @(rst_in)
    begin
       rst_tmp1 = rst_in;
       rst_rdclk_flag = 0;
       rst_wrclk_flag = 0;

	if (rst_tmp1 == 0 && rst_tmp2 == 1) begin
            if ((rst_rdckreg[2] & rst_rdckreg[1] & rst_rdckreg[0]) == 0) begin
		$display("Error : At time %t,  RST high on AFIFO36_INTERNAL instance %m is short than three RDCLK clock cycles. RST high need be more that three RDCLK clock cycles.", $stime);
		rst_rdclk_flag = 1;
	    end

            if ((rst_wrckreg[2] & rst_wrckreg[1] & rst_wrckreg[0]) == 0) begin
		$display("Error : At time %t,  RST high on AFIFO36_INTERNAL instance %m is short than three WRCLK clock cycles. RST high need be more that three WRCLK clock cycles.", $stime);
		rst_wrclk_flag = 1;
	    end
	   
	    if ((rst_rdclk_flag | rst_wrclk_flag) == 1) begin
	       assign do_out = 64'bx;
	       assign dop_out = 8'bx;
	       assign do_outreg = 64'bx;
	       assign dop_outreg = 8'bx;
	       assign full_out = 1'bX;
	       assign empty_out = 1'bX;
	       assign rderr_out = 1'bX;
	       assign wrerr_out = 1'bX;
	       assign sbiterr_out_out = 1'bx;
	       assign dbiterr_out_out = 1'bx;
	       assign eccparity_out = 8'bx;
	       assign rdcount_out = 13'bx;
	       assign rdcount_out_out = 13'bx;
	       assign wr_addr_out = 13'bx;
	       assign wr_addr = 13'bx;
	       assign wr1_addr = 0;
	       assign almostempty_int = 4'b1111;
	       assign almostempty_out = 1'bx;
	       assign almostfull_int = 4'b0000;
	       assign almostfull_out = 1'bx;
	       assign do_in = 64'b00000000000000000000000000000000;
	       assign dop_in = 8'b0000;
	       assign empty_ram = 4'b1111;
	       assign full_int = 4'b0000;
	       assign rd_addr = 0;
	       assign rd_prefetch = 0;
	       assign rdcount_flag = 0;
	       assign rd_flag = 0;
	       assign rdprefetch_flag = 0;
	       assign wr_flag = 0;
	       assign wr1_flag = 0;
	       assign awr_flag = 0;
	       
	   end
	   else if (gsr_in == 1'b0 && rst_in == 1'b0) begin
	       deassign do_out;
	       deassign dop_out;
	       deassign do_outreg;
	       deassign dop_outreg;
	       deassign full_out;
	       deassign empty_out;
	       deassign rderr_out;
	       deassign wrerr_out;
	       deassign sbiterr_out_out;
	       deassign dbiterr_out_out;
	       deassign eccparity_out;
	       deassign rdcount_out;
	       rdcount_out = 13'b0;
	       deassign wr_addr;
	       wr_addr = 13'b0;
	       deassign rdcount_out_out;
               deassign wr_addr_out;
	       deassign wr1_addr;
	       deassign almostempty_int;
	       deassign almostempty_out;
	       deassign almostfull_int;
	       deassign almostfull_out;
	       deassign do_in;
	       deassign dop_in;
	       deassign empty_ram;
	       deassign full_int;
	       deassign rd_addr;
	       deassign rd_prefetch;
	       deassign rdcount_flag;
	       deassign rd_flag;
	       deassign rdprefetch_flag;
	       deassign wr_flag;
	       deassign wr1_flag;
	       deassign awr_flag;
	   end
       end
       rst_tmp2 = rst_tmp1;

    end

    
    always @(posedge rdclk_in) begin

	if (rst_in == 1'b0) begin
	    if (fwft == 1 && $time > 100000 && aempty_flag < 2) begin
		
		if (aempty_flag == 0)
		    rise_rdclk = $time;
		else
		    period_rdclk = $time - rise_rdclk;
		
		aempty_flag = aempty_flag + 1;
		
	    end
	    
	    if (aempty_flag == 2 && afull_flag == 2) begin
		if (ALMOST_EMPTY_OFFSET <= 4 * (period_rdclk / period_wrclk)) begin  // in period
		    $display("DRC Error : The attribute ALMOST_EMPTY_OFFSET on AFIFO36_INTERNAL instance %m is set to %d. It must be set to a value greater than (4 * WRCLK frequency / RDCLK frequency) when AFIFO36_INTERNAL is configured in FIRST_WORD_FALL_THROUGH mode.", ALMOST_EMPTY_OFFSET);
		    $finish;
		    
		end
	    end
	end // if (rst_in == 1'b0)
	
	
	if (sync == 1'b1) begin

	    do_outreg = do_out;
	    dop_outreg = dop_out;

	    if (rden_in == 1'b1) begin

		if (empty_out == 1'b0) begin
		    
		    do_buf = mem[rdcount_out];
		    dop_buf = memp[rdcount_out];
		    
		    // ECC decode
		    if (EN_ECC_READ == "TRUE") begin
	  
			// regenerate parity
			dopr_ecc[0] = do_buf[0]^do_buf[1]^do_buf[3]^do_buf[4]^do_buf[6]^do_buf[8]
					  ^do_buf[10]^do_buf[11]^do_buf[13]^do_buf[15]^do_buf[17]^do_buf[19]
					  ^do_buf[21]^do_buf[23]^do_buf[25]^do_buf[26]^do_buf[28]
            				  ^do_buf[30]^do_buf[32]^do_buf[34]^do_buf[36]^do_buf[38]
 		                          ^do_buf[40]^do_buf[42]^do_buf[44]^do_buf[46]^do_buf[48]
		                          ^do_buf[50]^do_buf[52]^do_buf[54]^do_buf[56]^do_buf[57]^do_buf[59]
		                          ^do_buf[61]^do_buf[63];

			dopr_ecc[1] = do_buf[0]^do_buf[2]^do_buf[3]^do_buf[5]^do_buf[6]^do_buf[9]
                                          ^do_buf[10]^do_buf[12]^do_buf[13]^do_buf[16]^do_buf[17]
                                          ^do_buf[20]^do_buf[21]^do_buf[24]^do_buf[25]^do_buf[27]^do_buf[28]
                                          ^do_buf[31]^do_buf[32]^do_buf[35]^do_buf[36]^do_buf[39]
                                          ^do_buf[40]^do_buf[43]^do_buf[44]^do_buf[47]^do_buf[48]
                                          ^do_buf[51]^do_buf[52]^do_buf[55]^do_buf[56]^do_buf[58]^do_buf[59]
                                          ^do_buf[62]^do_buf[63];

			dopr_ecc[2] = do_buf[1]^do_buf[2]^do_buf[3]^do_buf[7]^do_buf[8]^do_buf[9]
                                          ^do_buf[10]^do_buf[14]^do_buf[15]^do_buf[16]^do_buf[17]
                                          ^do_buf[22]^do_buf[23]^do_buf[24]^do_buf[25]^do_buf[29]
                                          ^do_buf[30]^do_buf[31]^do_buf[32]^do_buf[37]^do_buf[38]^do_buf[39]
                                          ^do_buf[40]^do_buf[45]^do_buf[46]^do_buf[47]^do_buf[48]
                                          ^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56]
                                          ^do_buf[60]^do_buf[61]^do_buf[62]^do_buf[63];
	
			dopr_ecc[3] = do_buf[4]^do_buf[5]^do_buf[6]^do_buf[7]^do_buf[8]^do_buf[9]
		                          ^do_buf[10]^do_buf[18]^do_buf[19]
                                          ^do_buf[20]^do_buf[21]^do_buf[22]^do_buf[23]^do_buf[24]^do_buf[25]
                                          ^do_buf[33]^do_buf[34]^do_buf[35]^do_buf[36]^do_buf[37]^do_buf[38]
                                          ^do_buf[39]^do_buf[40]^do_buf[49]^do_buf[50]
                                          ^do_buf[51]^do_buf[52]^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56];

			dopr_ecc[4] = do_buf[11]^do_buf[12]^do_buf[13]^do_buf[14]^do_buf[15]^do_buf[16]
                                          ^do_buf[17]^do_buf[18]^do_buf[19]^do_buf[20]^do_buf[21]^do_buf[22]
				          ^do_buf[23]^do_buf[24]^do_buf[25]^do_buf[41]^do_buf[42]^do_buf[43]
				          ^do_buf[44]^do_buf[45]^do_buf[46]^do_buf[47]^do_buf[48]^do_buf[49]
				          ^do_buf[50]^do_buf[51]^do_buf[52]^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56];


			dopr_ecc[5] = do_buf[26]^do_buf[27]^do_buf[28]^do_buf[29]
				          ^do_buf[30]^do_buf[31]^do_buf[32]^do_buf[33]^do_buf[34]^do_buf[35]
				          ^do_buf[36]^do_buf[37]^do_buf[38]^do_buf[39]^do_buf[40]
				          ^do_buf[41]^do_buf[42]^do_buf[43]^do_buf[44]^do_buf[45]
				          ^do_buf[46]^do_buf[47]^do_buf[48]^do_buf[49]^do_buf[50]
				          ^do_buf[51]^do_buf[52]^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56];

			dopr_ecc[6] = do_buf[57]^do_buf[58]^do_buf[59]
				          ^do_buf[60]^do_buf[61]^do_buf[62]^do_buf[63];

			dopr_ecc[7] = dop_buf[0]^dop_buf[1]^dop_buf[2]^dop_buf[3]^dop_buf[4]^dop_buf[5]
				          ^dop_buf[6]^do_buf[0]^do_buf[1]^do_buf[2]^do_buf[3]^do_buf[4]
				          ^do_buf[5]^do_buf[6]^do_buf[7]^do_buf[8]^do_buf[9]^do_buf[10]
				          ^do_buf[11]^do_buf[12]^do_buf[13]^do_buf[14]^do_buf[15]^do_buf[16]
				          ^do_buf[17]^do_buf[18]^do_buf[19]^do_buf[20]^do_buf[21]^do_buf[22]
				          ^do_buf[23]^do_buf[24]^do_buf[25]^do_buf[26]^do_buf[27]^do_buf[28]
				          ^do_buf[29]^do_buf[30]^do_buf[31]^do_buf[32]^do_buf[33]^do_buf[34]
				          ^do_buf[35]^do_buf[36]^do_buf[37]^do_buf[38]^do_buf[39]^do_buf[40]
				          ^do_buf[41]^do_buf[42]^do_buf[43]^do_buf[44]^do_buf[45]^do_buf[46]
				          ^do_buf[47]^do_buf[48]^do_buf[49]^do_buf[50]^do_buf[51]^do_buf[52]
				          ^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56]^do_buf[57]^do_buf[58]
				          ^do_buf[59]^do_buf[60]^do_buf[61]^do_buf[62]^do_buf[63];
			    
			syndrome = dopr_ecc ^ dop_buf;
	  
			if (syndrome !== 0) begin

			    if (syndrome[7]) begin  // dectect single bit error

				ecc_bit_position = {do_buf[63:57], dop_buf[6], do_buf[56:26], dop_buf[5], do_buf[25:11], dop_buf[4], do_buf[10:4], dop_buf[3], do_buf[3:1], dop_buf[2], do_buf[0], dop_buf[1:0], dop_buf[7]};

				if (syndrome[6:0] > 71) begin
				    $display ("DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code.");
				    $finish;
				end
				
				ecc_bit_position[syndrome[6:0]] = ~ecc_bit_position[syndrome[6:0]]; // correct single bit error in the output 

				di_in_ecc_corrected = {ecc_bit_position[71:65], ecc_bit_position[63:33], ecc_bit_position[31:17], ecc_bit_position[15:9], ecc_bit_position[7:5], ecc_bit_position[3]}; // correct single bit error in the memory

				do_buf = di_in_ecc_corrected;
			
				dip_in_ecc_corrected = {ecc_bit_position[0], ecc_bit_position[64], ecc_bit_position[32], ecc_bit_position[16], ecc_bit_position[8], ecc_bit_position[4], ecc_bit_position[2:1]}; // correct single bit error in the parity memory
				
				dop_buf = dip_in_ecc_corrected;
				
				dbiterr_out_out = 0;  // latch out in sync mode
				sbiterr_out_out = 1;

			    end
			    else if (!syndrome[7]) begin  // double bit error
				sbiterr_out_out = 0;
				dbiterr_out_out = 1;
				    
			    end
			end // if (syndrome !== 0)
			else begin
			    dbiterr_out_out = 0;
			    sbiterr_out_out = 0;
				
			end // else: !if(syndrome !== 0)
			    
		    end // if (EN_ECC_READ == "TRUE")
		    // end ecc decode

		    do_out = do_buf;
		    dop_out = dop_buf;

		    rdcount_out = (rdcount_out + 1) % addr_limit;
		    
		    if (rdcount_out == 0)
			rdcount_flag = ~rdcount_flag;

		end
	    end 


	    rderr_out = (rden_in == 1'b1) && (empty_out == 1'b1);
	    
	    
	    if (wren_in == 1'b1) begin
		empty_out = 1'b0;
	    end
	    else if (rdcount_out == wr_addr && rdcount_flag == wr_flag)
		empty_out = 1'b1;

	    if ((((rdcount_out + ae_empty) >= wr_addr) && (rdcount_flag == wr_flag)) || (((rdcount_out + ae_empty) >= (wr_addr + addr_limit) && (rdcount_flag != wr_flag)))) begin
		almostempty_out = 1'b1;
	    end

	    if ((((rdcount_out + addr_limit) > (wr_addr + ae_full)) && (rdcount_flag == wr_flag)) || ((rdcount_out > (wr_addr + ae_full)) && (rdcount_flag != wr_flag))) begin
		if (wr_addr <= wr_addr + ae_full || rdcount_flag == wr_flag)
		    almostfull_out = 1'b0;
	    end

	end
	else if (sync == 1'b0) begin

	    dbiterr_out_out = dbiterr_out; // reg out in async mode
	    sbiterr_out_out = sbiterr_out;
	    
	    rden_reg = rden_in;
	    if (fwft == 1'b0) begin
		if ((rden_reg == 1'b1) && (rd_addr != rdcount_out)) begin
		    do_out = do_in;
		    if (DATA_WIDTH != 4) 
			dop_out = dop_in;
		    rd_addr = (rd_addr + 1) % addr_limit;
		    if (rd_addr == 0)
			rd_flag = ~rd_flag;
		end
		if (((rd_addr == rdcount_out) && (empty_ram[3] == 1'b0)) ||
		    ((rden_reg == 1'b1) && (empty_ram[1] == 1'b0))) begin

		    do_buf = mem[rdcount_out];
		    dop_buf = memp[rdcount_out];
		    
		// ECC decode
		    if (EN_ECC_READ == "TRUE") begin

			// regenerate parity
			dopr_ecc[0] = do_buf[0]^do_buf[1]^do_buf[3]^do_buf[4]^do_buf[6]^do_buf[8]
					  ^do_buf[10]^do_buf[11]^do_buf[13]^do_buf[15]^do_buf[17]^do_buf[19]
					  ^do_buf[21]^do_buf[23]^do_buf[25]^do_buf[26]^do_buf[28]
            				  ^do_buf[30]^do_buf[32]^do_buf[34]^do_buf[36]^do_buf[38]
		                          ^do_buf[40]^do_buf[42]^do_buf[44]^do_buf[46]^do_buf[48]
		                          ^do_buf[50]^do_buf[52]^do_buf[54]^do_buf[56]^do_buf[57]^do_buf[59]
		                          ^do_buf[61]^do_buf[63];

			dopr_ecc[1] = do_buf[0]^do_buf[2]^do_buf[3]^do_buf[5]^do_buf[6]^do_buf[9]
                                          ^do_buf[10]^do_buf[12]^do_buf[13]^do_buf[16]^do_buf[17]
                                          ^do_buf[20]^do_buf[21]^do_buf[24]^do_buf[25]^do_buf[27]^do_buf[28]
                                          ^do_buf[31]^do_buf[32]^do_buf[35]^do_buf[36]^do_buf[39]
                                          ^do_buf[40]^do_buf[43]^do_buf[44]^do_buf[47]^do_buf[48]
                                          ^do_buf[51]^do_buf[52]^do_buf[55]^do_buf[56]^do_buf[58]^do_buf[59]
                                          ^do_buf[62]^do_buf[63];

			dopr_ecc[2] = do_buf[1]^do_buf[2]^do_buf[3]^do_buf[7]^do_buf[8]^do_buf[9]
                                          ^do_buf[10]^do_buf[14]^do_buf[15]^do_buf[16]^do_buf[17]
                                          ^do_buf[22]^do_buf[23]^do_buf[24]^do_buf[25]^do_buf[29]
                                          ^do_buf[30]^do_buf[31]^do_buf[32]^do_buf[37]^do_buf[38]^do_buf[39]
                                          ^do_buf[40]^do_buf[45]^do_buf[46]^do_buf[47]^do_buf[48]
                                          ^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56]
                                          ^do_buf[60]^do_buf[61]^do_buf[62]^do_buf[63];
	
			dopr_ecc[3] = do_buf[4]^do_buf[5]^do_buf[6]^do_buf[7]^do_buf[8]^do_buf[9]
		                          ^do_buf[10]^do_buf[18]^do_buf[19]
                                          ^do_buf[20]^do_buf[21]^do_buf[22]^do_buf[23]^do_buf[24]^do_buf[25]
                                          ^do_buf[33]^do_buf[34]^do_buf[35]^do_buf[36]^do_buf[37]^do_buf[38]
                                          ^do_buf[39]^do_buf[40]^do_buf[49]^do_buf[50]
                                          ^do_buf[51]^do_buf[52]^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56];

			dopr_ecc[4] = do_buf[11]^do_buf[12]^do_buf[13]^do_buf[14]^do_buf[15]^do_buf[16]
                                          ^do_buf[17]^do_buf[18]^do_buf[19]^do_buf[20]^do_buf[21]^do_buf[22]
				          ^do_buf[23]^do_buf[24]^do_buf[25]^do_buf[41]^do_buf[42]^do_buf[43]
				          ^do_buf[44]^do_buf[45]^do_buf[46]^do_buf[47]^do_buf[48]^do_buf[49]
				          ^do_buf[50]^do_buf[51]^do_buf[52]^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56];


			dopr_ecc[5] = do_buf[26]^do_buf[27]^do_buf[28]^do_buf[29]
				          ^do_buf[30]^do_buf[31]^do_buf[32]^do_buf[33]^do_buf[34]^do_buf[35]
				          ^do_buf[36]^do_buf[37]^do_buf[38]^do_buf[39]^do_buf[40]
				          ^do_buf[41]^do_buf[42]^do_buf[43]^do_buf[44]^do_buf[45]
				          ^do_buf[46]^do_buf[47]^do_buf[48]^do_buf[49]^do_buf[50]
				          ^do_buf[51]^do_buf[52]^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56];

			dopr_ecc[6] = do_buf[57]^do_buf[58]^do_buf[59]
				          ^do_buf[60]^do_buf[61]^do_buf[62]^do_buf[63];

			dopr_ecc[7] = dop_buf[0]^dop_buf[1]^dop_buf[2]^dop_buf[3]^dop_buf[4]^dop_buf[5]
				          ^dop_buf[6]^do_buf[0]^do_buf[1]^do_buf[2]^do_buf[3]^do_buf[4]
				          ^do_buf[5]^do_buf[6]^do_buf[7]^do_buf[8]^do_buf[9]^do_buf[10]
				          ^do_buf[11]^do_buf[12]^do_buf[13]^do_buf[14]^do_buf[15]^do_buf[16]
				          ^do_buf[17]^do_buf[18]^do_buf[19]^do_buf[20]^do_buf[21]^do_buf[22]
				          ^do_buf[23]^do_buf[24]^do_buf[25]^do_buf[26]^do_buf[27]^do_buf[28]
				          ^do_buf[29]^do_buf[30]^do_buf[31]^do_buf[32]^do_buf[33]^do_buf[34]
				          ^do_buf[35]^do_buf[36]^do_buf[37]^do_buf[38]^do_buf[39]^do_buf[40]
				          ^do_buf[41]^do_buf[42]^do_buf[43]^do_buf[44]^do_buf[45]^do_buf[46]
				          ^do_buf[47]^do_buf[48]^do_buf[49]^do_buf[50]^do_buf[51]^do_buf[52]
				          ^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56]^do_buf[57]^do_buf[58]
				          ^do_buf[59]^do_buf[60]^do_buf[61]^do_buf[62]^do_buf[63];
			    
			syndrome = dopr_ecc ^ dop_buf;
	  
			if (syndrome !== 0) begin
			    
			    if (syndrome[7]) begin  // dectect single bit error
				
				ecc_bit_position = {do_buf[63:57], dop_buf[6], do_buf[56:26], dop_buf[5], do_buf[25:11], dop_buf[4], do_buf[10:4], dop_buf[3], do_buf[3:1], dop_buf[2], do_buf[0], dop_buf[1:0], dop_buf[7]};

				if (syndrome[6:0] > 71) begin
				    $display ("DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code.");
				    $finish;
				end
				
				ecc_bit_position[syndrome[6:0]] = ~ecc_bit_position[syndrome[6:0]]; // correct single bit error in the output 
				
				di_in_ecc_corrected = {ecc_bit_position[71:65], ecc_bit_position[63:33], ecc_bit_position[31:17], ecc_bit_position[15:9], ecc_bit_position[7:5], ecc_bit_position[3]}; // correct single bit error in the memory
				
				do_buf = di_in_ecc_corrected;
				
				dip_in_ecc_corrected = {ecc_bit_position[0], ecc_bit_position[64], ecc_bit_position[32], ecc_bit_position[16], ecc_bit_position[8], ecc_bit_position[4], ecc_bit_position[2:1]}; // correct single bit error in the parity memory

				dop_buf = dip_in_ecc_corrected;
				
				dbiterr_out = 0;
				sbiterr_out = 1;
				
			    end
			    else if (!syndrome[7]) begin  // double bit error
				sbiterr_out = 0;
				dbiterr_out = 1;
				
			    end
			end // if (syndrome !== 0)
			else begin
			    dbiterr_out = 0;
			    sbiterr_out = 0;
			    
			end // else: !if(syndrome !== 0)
			
		    end // if (EN_ECC_READ == "TRUE")
		    // end ecc decode
		    
		    do_in = do_buf;
		    dop_in = dop_buf;
		
		    #1;
		    rdcount_out = (rdcount_out + 1) % addr_limit;
		    if (rdcount_out == 0) begin
			rdcount_flag = ~rdcount_flag;
		    end
		end
	    end

	    if (fwft == 1'b1) begin

		if ((rden_reg == 1'b1) && (rd_addr != rd_prefetch)) begin
		    rd_prefetch = (rd_prefetch + 1) % addr_limit;
		    if (rd_prefetch == 0)
			rdprefetch_flag = ~rdprefetch_flag;
		end
		if ((rd_prefetch == rd_addr) && (rd_addr != rdcount_out)) begin
		    do_out = do_in;
		    if (DATA_WIDTH != 4) 
			dop_out = dop_in;
		    rd_addr = (rd_addr + 1) % addr_limit;
		    if (rd_addr == 0)
			rd_flag = ~rd_flag;
		end
		if (((rd_addr == rdcount_out) && (empty_ram[3] == 1'b0)) ||
		    ((rden_reg == 1'b1) && (empty_ram[1] == 1'b0)) ||
		    ((rden_reg == 1'b0) && (empty_ram[1] == 1'b0) && (rd_addr == rdcount_out))) begin
		    
		    do_buf = mem[rdcount_out];
		    dop_buf = memp[rdcount_out];
		
		    // ECC decode
		    if (EN_ECC_READ == "TRUE") begin
			
			// regenerate parity
			dopr_ecc[0] = do_buf[0]^do_buf[1]^do_buf[3]^do_buf[4]^do_buf[6]^do_buf[8]
					  ^do_buf[10]^do_buf[11]^do_buf[13]^do_buf[15]^do_buf[17]^do_buf[19]
					  ^do_buf[21]^do_buf[23]^do_buf[25]^do_buf[26]^do_buf[28]
            				  ^do_buf[30]^do_buf[32]^do_buf[34]^do_buf[36]^do_buf[38]
		                          ^do_buf[40]^do_buf[42]^do_buf[44]^do_buf[46]^do_buf[48]
		                          ^do_buf[50]^do_buf[52]^do_buf[54]^do_buf[56]^do_buf[57]^do_buf[59]
		                          ^do_buf[61]^do_buf[63];

			dopr_ecc[1] = do_buf[0]^do_buf[2]^do_buf[3]^do_buf[5]^do_buf[6]^do_buf[9]
                                          ^do_buf[10]^do_buf[12]^do_buf[13]^do_buf[16]^do_buf[17]
                                          ^do_buf[20]^do_buf[21]^do_buf[24]^do_buf[25]^do_buf[27]^do_buf[28]
                                          ^do_buf[31]^do_buf[32]^do_buf[35]^do_buf[36]^do_buf[39]
                                          ^do_buf[40]^do_buf[43]^do_buf[44]^do_buf[47]^do_buf[48]
                                          ^do_buf[51]^do_buf[52]^do_buf[55]^do_buf[56]^do_buf[58]^do_buf[59]
                                          ^do_buf[62]^do_buf[63];

			dopr_ecc[2] = do_buf[1]^do_buf[2]^do_buf[3]^do_buf[7]^do_buf[8]^do_buf[9]
                                          ^do_buf[10]^do_buf[14]^do_buf[15]^do_buf[16]^do_buf[17]
                                          ^do_buf[22]^do_buf[23]^do_buf[24]^do_buf[25]^do_buf[29]
                                          ^do_buf[30]^do_buf[31]^do_buf[32]^do_buf[37]^do_buf[38]^do_buf[39]
                                          ^do_buf[40]^do_buf[45]^do_buf[46]^do_buf[47]^do_buf[48]
                                          ^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56]
                                          ^do_buf[60]^do_buf[61]^do_buf[62]^do_buf[63];
	
			dopr_ecc[3] = do_buf[4]^do_buf[5]^do_buf[6]^do_buf[7]^do_buf[8]^do_buf[9]
		                          ^do_buf[10]^do_buf[18]^do_buf[19]
                                          ^do_buf[20]^do_buf[21]^do_buf[22]^do_buf[23]^do_buf[24]^do_buf[25]
                                          ^do_buf[33]^do_buf[34]^do_buf[35]^do_buf[36]^do_buf[37]^do_buf[38]
                                          ^do_buf[39]^do_buf[40]^do_buf[49]^do_buf[50]
                                          ^do_buf[51]^do_buf[52]^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56];

			dopr_ecc[4] = do_buf[11]^do_buf[12]^do_buf[13]^do_buf[14]^do_buf[15]^do_buf[16]
                                          ^do_buf[17]^do_buf[18]^do_buf[19]^do_buf[20]^do_buf[21]^do_buf[22]
				          ^do_buf[23]^do_buf[24]^do_buf[25]^do_buf[41]^do_buf[42]^do_buf[43]
				          ^do_buf[44]^do_buf[45]^do_buf[46]^do_buf[47]^do_buf[48]^do_buf[49]
				          ^do_buf[50]^do_buf[51]^do_buf[52]^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56];


			dopr_ecc[5] = do_buf[26]^do_buf[27]^do_buf[28]^do_buf[29]
				          ^do_buf[30]^do_buf[31]^do_buf[32]^do_buf[33]^do_buf[34]^do_buf[35]
				          ^do_buf[36]^do_buf[37]^do_buf[38]^do_buf[39]^do_buf[40]
				          ^do_buf[41]^do_buf[42]^do_buf[43]^do_buf[44]^do_buf[45]
				          ^do_buf[46]^do_buf[47]^do_buf[48]^do_buf[49]^do_buf[50]
				          ^do_buf[51]^do_buf[52]^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56];

			dopr_ecc[6] = do_buf[57]^do_buf[58]^do_buf[59]
				          ^do_buf[60]^do_buf[61]^do_buf[62]^do_buf[63];

			dopr_ecc[7] = dop_buf[0]^dop_buf[1]^dop_buf[2]^dop_buf[3]^dop_buf[4]^dop_buf[5]
				          ^dop_buf[6]^do_buf[0]^do_buf[1]^do_buf[2]^do_buf[3]^do_buf[4]
				          ^do_buf[5]^do_buf[6]^do_buf[7]^do_buf[8]^do_buf[9]^do_buf[10]
				          ^do_buf[11]^do_buf[12]^do_buf[13]^do_buf[14]^do_buf[15]^do_buf[16]
				          ^do_buf[17]^do_buf[18]^do_buf[19]^do_buf[20]^do_buf[21]^do_buf[22]
				          ^do_buf[23]^do_buf[24]^do_buf[25]^do_buf[26]^do_buf[27]^do_buf[28]
				          ^do_buf[29]^do_buf[30]^do_buf[31]^do_buf[32]^do_buf[33]^do_buf[34]
				          ^do_buf[35]^do_buf[36]^do_buf[37]^do_buf[38]^do_buf[39]^do_buf[40]
				          ^do_buf[41]^do_buf[42]^do_buf[43]^do_buf[44]^do_buf[45]^do_buf[46]
				          ^do_buf[47]^do_buf[48]^do_buf[49]^do_buf[50]^do_buf[51]^do_buf[52]
				          ^do_buf[53]^do_buf[54]^do_buf[55]^do_buf[56]^do_buf[57]^do_buf[58]
				          ^do_buf[59]^do_buf[60]^do_buf[61]^do_buf[62]^do_buf[63];
			    
			syndrome = dopr_ecc ^ dop_buf;
	  
			if (syndrome !== 0) begin
			    
			    if (syndrome[7]) begin  // dectect single bit error
				
				ecc_bit_position = {do_buf[63:57], dop_buf[6], do_buf[56:26], dop_buf[5], do_buf[25:11], dop_buf[4], do_buf[10:4], dop_buf[3], do_buf[3:1], dop_buf[2], do_buf[0], dop_buf[1:0], dop_buf[7]};

				if (syndrome[6:0] > 71) begin
				    $display ("DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code.");
				    $finish;
				end
				
				ecc_bit_position[syndrome[6:0]] = ~ecc_bit_position[syndrome[6:0]]; // correct single bit error in the output 
				
				di_in_ecc_corrected = {ecc_bit_position[71:65], ecc_bit_position[63:33], ecc_bit_position[31:17], ecc_bit_position[15:9], ecc_bit_position[7:5], ecc_bit_position[3]}; // correct single bit error in the memory
				
				do_buf = di_in_ecc_corrected;
				
				dip_in_ecc_corrected = {ecc_bit_position[0], ecc_bit_position[64], ecc_bit_position[32], ecc_bit_position[16], ecc_bit_position[8], ecc_bit_position[4], ecc_bit_position[2:1]}; // correct single bit error in the parity memory

				dop_buf = dip_in_ecc_corrected;

				dbiterr_out = 0;
				sbiterr_out = 1;
				
			    end
			    else if (!syndrome[7]) begin  // double bit error
				sbiterr_out = 0;
				dbiterr_out = 1;
				    
			    end
			end // if (syndrome !== 0)
			else begin
			    dbiterr_out = 0;
			    sbiterr_out = 0;
			    
			end // else: !if(syndrome !== 0)
			
		    end // if (EN_ECC_READ == "TRUE")
		    // end ecc decode
	   
		    do_in = do_buf;
		    dop_in = dop_buf;
		
		    #1;
		    rdcount_out = (rdcount_out + 1) % addr_limit;
		    if (rdcount_out == 0)
			rdcount_flag = ~rdcount_flag;
		end
	    end // if (fwft == 1'b1)
	    
	    
	    rderr_out = (rden_reg == 1'b1) && (empty_out == 1'b1);

	    almostempty_out = almostempty_int[3];

	    if ((((rdcount_out + ae_empty) >= wr_addr) && (rdcount_flag == awr_flag)) || (((rdcount_out + ae_empty) >= (wr_addr + addr_limit)) && (rdcount_flag != awr_flag))) begin
		almostempty_int[3] = 1'b1;
		almostempty_int[2] = 1'b1;
		almostempty_int[1] = 1'b1;
		almostempty_int[0] = 1'b1;
	    end
	    else if (almostempty_int[2] == 1'b0) begin

		if (rdcount_out <= rdcount_out + ae_empty || rdcount_flag != awr_flag) begin
		    almostempty_int[3] = almostempty_int[0];
		    almostempty_int[0] = 1'b0;
		    end
	    end
	    
	    if ((((rdcount_out + addr_limit) > (wr_addr + ae_full)) && (rdcount_flag == awr_flag)) || ((rdcount_out > (wr_addr + ae_full)) && (rdcount_flag != awr_flag))) begin

		if (((rden_reg == 1'b1) && (empty_out == 1'b0)) || ((((rd_addr + 1) % addr_limit) == rdcount_out) && (almostfull_int[1] == 1'b1))) begin
		    almostfull_int[2] = almostfull_int[1];
		    almostfull_int[1] = 1'b0;
		end
	    end
	    else begin
		almostfull_int[2] = 1'b1;
		almostfull_int[1] = 1'b1;
	    end

	    if (fwft == 1'b0) begin
		if ((rdcount_out == rd_addr) && (rdcount_flag == rd_flag)) begin
		    empty_out = 1'b1;
		end
		else begin
		    empty_out = 1'b0;
		end
	    end // if (fwft == 1'b0)
	    else if (fwft == 1'b1) begin
		if ((rd_prefetch == rd_addr) && (rdprefetch_flag == rd_flag)) begin
		    empty_out = 1'b1;
		end
		else begin
		    empty_out = 1'b0;
		end
	    end

	    if ((rdcount_out == wr_addr) && (rdcount_flag == awr_flag)) begin
		empty_ram[2] = 1'b1;
		empty_ram[1] = 1'b1;
		empty_ram[0] = 1'b1;
	    end
	    else begin
		empty_ram[2] = empty_ram[1];
		empty_ram[1] = empty_ram[0];
		empty_ram[0] = 1'b0;
	    end
	    
	    if ((rdcount_out == wr1_addr) && (rdcount_flag == wr1_flag)) begin
		empty_ram[3] = 1'b1;
	    end
	    else begin
		empty_ram[3] = 1'b0;
	    end

	    wr1_addr = wr_addr;
	    wr1_flag = awr_flag;

	end // if (sync == 1'b0)
    end // always @ (posedge rdclk_in)
    

    always @(posedge wrclk_in) begin

	if (rst_in == 1'b0) begin
	    if (fwft == 1 && $time > 100000 && afull_flag < 2) begin
		
		if (afull_flag == 0)
		    rise_wrclk = $time;
		else
		    period_wrclk = $time - rise_wrclk;
		
		afull_flag = afull_flag + 1;
		
	    end
	end // if (rst_in == 1'b0)
	
		
	if (sync == 1'b1) begin

	    if (wren_in == 1'b1) begin

		if (full_out == 1'b0) begin

		    // ECC encode
		    if (EN_ECC_WRITE == "TRUE") begin
	  
			dip_ecc[0] = di_in[0]^di_in[1]^di_in[3]^di_in[4]^di_in[6]^di_in[8]
		                 ^di_in[10]^di_in[11]^di_in[13]^di_in[15]^di_in[17]^di_in[19]
		                 ^di_in[21]^di_in[23]^di_in[25]^di_in[26]^di_in[28]
            	                 ^di_in[30]^di_in[32]^di_in[34]^di_in[36]^di_in[38]
		                 ^di_in[40]^di_in[42]^di_in[44]^di_in[46]^di_in[48]
		                 ^di_in[50]^di_in[52]^di_in[54]^di_in[56]^di_in[57]^di_in[59]
		                 ^di_in[61]^di_in[63];

			dip_ecc[1] = di_in[0]^di_in[2]^di_in[3]^di_in[5]^di_in[6]^di_in[9]
                                 ^di_in[10]^di_in[12]^di_in[13]^di_in[16]^di_in[17]
                                 ^di_in[20]^di_in[21]^di_in[24]^di_in[25]^di_in[27]^di_in[28]
                                 ^di_in[31]^di_in[32]^di_in[35]^di_in[36]^di_in[39]
                                 ^di_in[40]^di_in[43]^di_in[44]^di_in[47]^di_in[48]
                                 ^di_in[51]^di_in[52]^di_in[55]^di_in[56]^di_in[58]^di_in[59]
                                 ^di_in[62]^di_in[63];

			dip_ecc[2] = di_in[1]^di_in[2]^di_in[3]^di_in[7]^di_in[8]^di_in[9]
                                 ^di_in[10]^di_in[14]^di_in[15]^di_in[16]^di_in[17]
                                 ^di_in[22]^di_in[23]^di_in[24]^di_in[25]^di_in[29]
                                 ^di_in[30]^di_in[31]^di_in[32]^di_in[37]^di_in[38]^di_in[39]
                                 ^di_in[40]^di_in[45]^di_in[46]^di_in[47]^di_in[48]
                                 ^di_in[53]^di_in[54]^di_in[55]^di_in[56]
                                 ^di_in[60]^di_in[61]^di_in[62]^di_in[63];
	
			dip_ecc[3] = di_in[4]^di_in[5]^di_in[6]^di_in[7]^di_in[8]^di_in[9]
			         ^di_in[10]^di_in[18]^di_in[19]
                                 ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]
                                 ^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                                 ^di_in[40]^di_in[49]
                                 ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56];

			dip_ecc[4] = di_in[11]^di_in[12]^di_in[13]^di_in[14]^di_in[15]^di_in[16]^di_in[17]^di_in[18]^di_in[19]
                                 ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]
                                 ^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                                 ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56];


			dip_ecc[5] = di_in[26]^di_in[27]^di_in[28]^di_in[29]
                                 ^di_in[30]^di_in[31]^di_in[32]^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                                 ^di_in[40]^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                                 ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56];

			dip_ecc[6] = di_in[57]^di_in[58]^di_in[59]
			         ^di_in[60]^di_in[61]^di_in[62]^di_in[63];

			dip_ecc[7] = dip_ecc[0]^dip_ecc[1]^dip_ecc[2]^dip_ecc[3]^dip_ecc[4]^dip_ecc[5]^dip_ecc[6]
                                 ^di_in[0]^di_in[1]^di_in[2]^di_in[3]^di_in[4]^di_in[5]^di_in[6]^di_in[7]^di_in[8]^di_in[9]
                                 ^di_in[10]^di_in[11]^di_in[12]^di_in[13]^di_in[14]^di_in[15]^di_in[16]^di_in[17]^di_in[18]^di_in[19]
                                 ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]^di_in[26]^di_in[27]^di_in[28]^di_in[29]
                                 ^di_in[30]^di_in[31]^di_in[32]^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                                 ^di_in[40]^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                                 ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56]^di_in[57]^di_in[58]^di_in[59]
                                 ^di_in[60]^di_in[61]^di_in[62]^di_in[63];

			eccparity_out = dip_ecc;

			dip_int = dip_ecc;  // only 64 bits width
			
		    end // if (EN_ECC_WRITE == "TRUE")
		    else begin
			
			dip_int = dip_in; // only 64 bits width
			
		    end // else: !if(EN_ECC_WRITE == "TRUE")
		    // end ecc encode

		    mem[wr_addr] = di_in;
		    memp[wr_addr] = dip_int;
		    
		    wr_addr = (wr_addr + 1) % addr_limit;
		    if (wr_addr == 0)
			wr_flag = ~wr_flag;

		end		
	    end 


	    wrerr_out = (wren_in == 1'b1) && (full_out == 1'b1);
	    
	    
	    if (rden_in == 1'b1) begin
		full_out = 1'b0;
	    end
	    else if (rdcount_out == wr_addr && rdcount_flag != wr_flag)
		full_out = 1'b1;

	    if ((((rdcount_out + ae_empty) < wr_addr) && (rdcount_flag == wr_flag)) || (((rdcount_out + ae_empty) < (wr_addr + addr_limit) && (rdcount_flag != wr_flag)))) begin
		
		if (rdcount_out <= rdcount_out + ae_empty || rdcount_flag != wr_flag)
		    almostempty_out = 1'b0;

	    end

	    if ((((rdcount_out + addr_limit) <= (wr_addr + ae_full)) && (rdcount_flag == wr_flag)) || ((rdcount_out <= (wr_addr + ae_full)) && (rdcount_flag != wr_flag))) begin
		almostfull_out = 1'b1;
	    end
	    
	end
	else if (sync == 1'b0) begin

	    wren_reg = wren_in;

	    if (wren_reg == 1'b1 && (full_out == 1'b0)) begin		

		// ECC encode
		if (EN_ECC_WRITE == "TRUE") begin
		    
		    dip_ecc[0] = di_in[0]^di_in[1]^di_in[3]^di_in[4]^di_in[6]^di_in[8]
		                 ^di_in[10]^di_in[11]^di_in[13]^di_in[15]^di_in[17]^di_in[19]
		                 ^di_in[21]^di_in[23]^di_in[25]^di_in[26]^di_in[28]
            	                 ^di_in[30]^di_in[32]^di_in[34]^di_in[36]^di_in[38]
		                 ^di_in[40]^di_in[42]^di_in[44]^di_in[46]^di_in[48]
		                 ^di_in[50]^di_in[52]^di_in[54]^di_in[56]^di_in[57]^di_in[59]
		                 ^di_in[61]^di_in[63];

		    dip_ecc[1] = di_in[0]^di_in[2]^di_in[3]^di_in[5]^di_in[6]^di_in[9]
                                 ^di_in[10]^di_in[12]^di_in[13]^di_in[16]^di_in[17]
                                 ^di_in[20]^di_in[21]^di_in[24]^di_in[25]^di_in[27]^di_in[28]
                                 ^di_in[31]^di_in[32]^di_in[35]^di_in[36]^di_in[39]
                                 ^di_in[40]^di_in[43]^di_in[44]^di_in[47]^di_in[48]
                                 ^di_in[51]^di_in[52]^di_in[55]^di_in[56]^di_in[58]^di_in[59]
                                 ^di_in[62]^di_in[63];

		    dip_ecc[2] = di_in[1]^di_in[2]^di_in[3]^di_in[7]^di_in[8]^di_in[9]
                                 ^di_in[10]^di_in[14]^di_in[15]^di_in[16]^di_in[17]
                                 ^di_in[22]^di_in[23]^di_in[24]^di_in[25]^di_in[29]
                                 ^di_in[30]^di_in[31]^di_in[32]^di_in[37]^di_in[38]^di_in[39]
                                 ^di_in[40]^di_in[45]^di_in[46]^di_in[47]^di_in[48]
                                 ^di_in[53]^di_in[54]^di_in[55]^di_in[56]
                                 ^di_in[60]^di_in[61]^di_in[62]^di_in[63];
	
		    dip_ecc[3] = di_in[4]^di_in[5]^di_in[6]^di_in[7]^di_in[8]^di_in[9]
			         ^di_in[10]^di_in[18]^di_in[19]
                                 ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]
                                 ^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                                 ^di_in[40]^di_in[49]
                                 ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56];

		    dip_ecc[4] = di_in[11]^di_in[12]^di_in[13]^di_in[14]^di_in[15]^di_in[16]^di_in[17]^di_in[18]^di_in[19]
                                 ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]
                                 ^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                                 ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56];


		    dip_ecc[5] = di_in[26]^di_in[27]^di_in[28]^di_in[29]
                                 ^di_in[30]^di_in[31]^di_in[32]^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                                 ^di_in[40]^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                                 ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56];

		    dip_ecc[6] = di_in[57]^di_in[58]^di_in[59]
			         ^di_in[60]^di_in[61]^di_in[62]^di_in[63];

		    dip_ecc[7] = dip_ecc[0]^dip_ecc[1]^dip_ecc[2]^dip_ecc[3]^dip_ecc[4]^dip_ecc[5]^dip_ecc[6]
                                 ^di_in[0]^di_in[1]^di_in[2]^di_in[3]^di_in[4]^di_in[5]^di_in[6]^di_in[7]^di_in[8]^di_in[9]
                                 ^di_in[10]^di_in[11]^di_in[12]^di_in[13]^di_in[14]^di_in[15]^di_in[16]^di_in[17]^di_in[18]^di_in[19]
                                 ^di_in[20]^di_in[21]^di_in[22]^di_in[23]^di_in[24]^di_in[25]^di_in[26]^di_in[27]^di_in[28]^di_in[29]
                                 ^di_in[30]^di_in[31]^di_in[32]^di_in[33]^di_in[34]^di_in[35]^di_in[36]^di_in[37]^di_in[38]^di_in[39]
                                 ^di_in[40]^di_in[41]^di_in[42]^di_in[43]^di_in[44]^di_in[45]^di_in[46]^di_in[47]^di_in[48]^di_in[49]
                                 ^di_in[50]^di_in[51]^di_in[52]^di_in[53]^di_in[54]^di_in[55]^di_in[56]^di_in[57]^di_in[58]^di_in[59]
                                 ^di_in[60]^di_in[61]^di_in[62]^di_in[63];

		    eccparity_out = dip_ecc;

		    dip_int = dip_ecc;  // only 64 bits width
			
		end // if (EN_ECC_WRITE == "TRUE")
		else begin
		    
		    dip_int = dip_in; // only 64 bits width
		    
		end // else: !if(EN_ECC_WRITE == "TRUE")
		// end ecc encode

		mem[wr_addr] = di_in;
		memp[wr_addr] = dip_int;
		
		#1;
		wr_addr = (wr_addr + 1) % addr_limit;

		if (wr_addr == 0)
		    awr_flag = ~awr_flag;

		if (wr_addr == addr_limit - 1)
		    wr_flag = ~wr_flag;
	    end

	    wrerr_out = (wren_reg == 1'b1) && (full_out == 1'b1);

	    almostfull_out = almostfull_int[3];

	    if ((((rdcount_out + addr_limit) <= (wr_addr + ae_full)) && (rdcount_flag == awr_flag)) || ((rdcount_out <= (wr_addr + ae_full)) && (rdcount_flag != awr_flag))) begin
		almostfull_int[3] = 1'b1;
		almostfull_int[2] = 1'b1;
		almostfull_int[1] = 1'b1;
		almostfull_int[0] = 1'b1;
	    end
	    else if (almostfull_int[2] == 1'b0) begin

		if (wr_addr <= wr_addr + ae_full || rdcount_flag == awr_flag) begin
		    almostfull_int[3] = almostfull_int[0];
		    almostfull_int[0] = 1'b0;
		    end
	    end

	    if ((((rdcount_out + ae_empty) < wr_addr) && (rdcount_flag == awr_flag)) || (((rdcount_out + ae_empty) < (wr_addr + addr_limit)) && (rdcount_flag != awr_flag))) begin
		if (wren_reg == 1'b1) begin
		    almostempty_int[2] = almostempty_int[1];
		    almostempty_int[1] = 1'b0;
		end
	    end
	    else begin
		almostempty_int[2] = 1'b1;
		almostempty_int[1] = 1'b1;
	    end

	    if (wren_reg == 1'b1 || full_out == 1'b1)
		full_out = full_int[1];

	    if (((rdcount_out == wr_addr) || (rdcount_out - 1 == wr_addr || (rdcount_out + addr_limit - 1 == wr_addr))) && almostfull_out) begin
		full_int[1] = 1'b1;
		full_int[0] = 1'b1;
	    end
	    else begin
		full_int[1] = full_int[0];
		full_int[0] = 0;
	    end
	    
	end // if (sync == 1'b0)
    end // always @ (posedge wrclk_in)

    
    always @(do_out or dop_out or do_outreg or dop_outreg) begin

	if (sync == 1)
	    
	    case (DO_REG)

		0 : begin
	                do_out_mux = do_out;
		        dop_out_mux = dop_out;
	            end
		1 : begin
		        do_out_mux = do_outreg;
		        dop_out_mux = dop_outreg;
	            end
		default : begin
	                      $display("Attribute Syntax Error : The attribute DO_REG on AFIFO36_INTERNAL instance %m is set to %2d.  Legal values for this attribute are 0 or 1.", DO_REG);
	                      $finish;
	                  end
	    endcase

	else begin
	    do_out_mux = do_out;
	    dop_out_mux = dop_out;
	end // else: !if(sync == 1)
	
    end // always @ (do_out or dop_out or do_outreg or dop_outreg)

    
    // matching HW behavior to X the unused output bits
    assign do_out_out = (DATA_WIDTH == 4) ? {60'bx, do_out_mux[3:0]}
                      : (DATA_WIDTH == 9) ? {56'bx, do_out_mux[7:0]}
                      : (DATA_WIDTH == 18) ? {48'bx, do_out_mux[15:0]}
                      : (DATA_WIDTH == 36) ? {32'bx, do_out_mux[31:0]}
	              : (DATA_WIDTH == 72) ? do_out_mux
                      : do_out_mux;

    // matching HW behavior to X the unused output bits
    assign dop_out_out = (DATA_WIDTH ==  9) ? {7'bx, dop_out_mux[0:0]}
                       : (DATA_WIDTH == 18) ? {6'bx, dop_out_mux[1:0]}
		       : (DATA_WIDTH == 36) ? {4'bx, dop_out_mux[3:0]}
	               : (DATA_WIDTH == 72) ? dop_out_mux
                       : 8'bx;
    
    // matching HW behavior to pull up the unused output bits
    always @(wr_addr) begin 

	if (FIFO_SIZE == 18)
	    case (DATA_WIDTH)
		4 : wr_addr_out = {1'b1, wr_addr[11:0]};
		9 : wr_addr_out = {2'b11, wr_addr[10:0]};
		18 : wr_addr_out = {3'b111, wr_addr[9:0]};
		36 : wr_addr_out = {4'hf, wr_addr[8:0]};
		default : wr_addr_out = wr_addr;
	    endcase // case(DATA_WIDTH)
	else
	    case (DATA_WIDTH)
		4 : wr_addr_out = wr_addr;
		9 : wr_addr_out = {1'b1, wr_addr[11:0]};
		18 : wr_addr_out = {2'b11, wr_addr[10:0]};
		36 : wr_addr_out = {3'b111, wr_addr[9:0]};
		72 : wr_addr_out = {4'hf, wr_addr[8:0]};
		default : wr_addr_out = wr_addr;
	    endcase // case(DATA_WIDTH)

    end // always @ (wr_addr)
    
    
    // matching HW behavior to pull up the unused output bits
    always @(rdcount_out) begin 

	if (FIFO_SIZE == 18)
	    case (DATA_WIDTH)
		4 : rdcount_out_out = {1'b1, rdcount_out[11:0]};
		9 : rdcount_out_out = {2'b11, rdcount_out[10:0]};
		18 : rdcount_out_out = {3'b111, rdcount_out[9:0]};
		36 : rdcount_out_out = {4'hf, rdcount_out[8:0]};
		default : rdcount_out_out = rdcount_out;
	    endcase // case(DATA_WIDTH)
	else
	    case (DATA_WIDTH)
		4 : rdcount_out_out = rdcount_out;
		9 : rdcount_out_out = {1'b1, rdcount_out[11:0]};
		18 : rdcount_out_out = {2'b11, rdcount_out[10:0]};
		36 : rdcount_out_out = {3'b111, rdcount_out[9:0]};
		72 : rdcount_out_out = {4'hf, rdcount_out[8:0]};
		default : rdcount_out_out = rdcount_out;
	    endcase // case(DATA_WIDTH)
	
    end // always @ (rdcount_out)

    end // if (SIM_MODE == "SAFE")
    endgenerate
    // end SAFE mode


/*************************** FAST mode *********************************/
    generate if (SIM_MODE == "FAST") begin

    assign DO = do_out_mux;
    assign DOP = dop_out_mux;
    assign ALMOSTEMPTY = almostempty_out;
    assign ALMOSTFULL = almostfull_out;
    assign EMPTY = empty_out;
    assign FULL = full_out;
    assign RDERR = rderr_out;
    assign WRERR = wrerr_out;    
    assign SBITERR = sbiterr_out_out;
    assign DBITERR = dbiterr_out_out;
    assign ECCPARITY = eccparity_out;
    assign RDCOUNT = rdcount_out;
    assign WRCOUNT = wr_addr;

    always @(GSR)
	if (GSR == 1'b1) begin
	    assign do_out = 64'b0;
	    assign dop_out = 8'b0;
	    assign do_outreg = 64'b0;
	    assign dop_outreg = 8'b0;
	end
	else if (GSR == 1'b0) begin
	    deassign do_out;
	    deassign dop_out;
	    deassign do_outreg;
	    deassign dop_outreg;
	end

    always @(GSR or RST)
	if (GSR == 1'b1 || RST == 1'b1) begin
	    assign almostempty_int = 4'b1111;
	    assign almostempty_out = 1'b1;
	    assign almostfull_int = 4'b0000;
	    assign almostfull_out = 1'b0;
	    assign do_in = 64'b00000000000000000000000000000000;
	    assign dop_in = 8'b0000;
	    assign empty_ram = 4'b1111;
	    assign empty_out = 1'b1;
	    assign full_int = 4'b0000;
	    assign full_out = 1'b0;
	    assign rdcount_out = 13'b0;
	    assign rderr_out = 0;
	    assign wrerr_out = 0;
	    assign rd_addr = 0;
	    assign rd_prefetch = 0;
	    assign wr_addr = 0;
	    assign wr1_addr = 0;
	    assign rdcount_flag = 0;
	    assign rd_flag = 0;
	    assign rdprefetch_flag = 0;
	    assign wr_flag = 0;
	    assign wr1_flag = 0;
	    assign awr_flag = 0;
	end
	else if (GSR == 1'b0 || RST == 1'b0) begin
	    deassign almostempty_int;
	    deassign almostempty_out;
	    deassign almostfull_int;
	    deassign almostfull_out;
	    deassign do_in;
	    deassign dop_in;
	    deassign empty_ram;
	    deassign empty_out;
	    deassign full_int;
	    deassign full_out;
	    deassign rdcount_out;
	    deassign rderr_out;
	    deassign wrerr_out;
	    deassign rd_addr;
	    deassign rd_prefetch;
	    deassign wr_addr;
	    deassign wr1_addr;
	    deassign rdcount_flag;
	    deassign rd_flag;
	    deassign rdprefetch_flag;
	    deassign wr_flag;
	    deassign wr1_flag;
	    deassign awr_flag;	    
	end

    initial begin

	case (DATA_WIDTH)
	    4 : begin
		    if (FIFO_SIZE == 36)
			addr_limit = 8192;
		    else
			addr_limit = 4096;
		end
	    9 : begin
		    if (FIFO_SIZE == 36)
			addr_limit = 4096;
		    else
			addr_limit = 2048;
		end
	   18 : begin
	            if (FIFO_SIZE == 36)
			addr_limit = 2048;
		    else
			addr_limit = 1024;
		end
	   36 : begin
	            if (FIFO_SIZE == 36)
			addr_limit = 1024;
		    else
			addr_limit = 512;
		end
	   72 : begin
		    addr_limit = 512;
		end
	endcase

	
	case (EN_SYN)
	    "FALSE" : sync = 0;
	    "TRUE" : sync = 1;
	endcase // case(EN_SYN)


	case (FIRST_WORD_FALL_THROUGH)
	    "FALSE" : begin
		          fwft = 0;
		          if (EN_SYN == "FALSE") begin
			      ae_empty = ALMOST_EMPTY_OFFSET - 1;
	                      ae_full = ALMOST_FULL_OFFSET;
			  end
			  else begin
			      ae_empty = ALMOST_EMPTY_OFFSET;
	                      ae_full = ALMOST_FULL_OFFSET;
			  end
		      end
	    "TRUE"  : begin
		          fwft = 1;
		          ae_empty = ALMOST_EMPTY_OFFSET - 2;
	                  ae_full = ALMOST_FULL_OFFSET;
	              end

	endcase

	
    end // initial begin

    
    always @(posedge RDCLK) begin

	if (sync == 1'b1) begin

	    do_outreg = do_out;
	    dop_outreg = dop_out;

	    if (RDEN == 1'b1) begin

		if (empty_out == 1'b0) begin
		    
		    do_out = mem[rdcount_out];
		    dop_out = memp[rdcount_out];
		    
		    rdcount_out = (rdcount_out + 1) % addr_limit;
		    
		    if (rdcount_out == 0)
			rdcount_flag = ~rdcount_flag;

		end
	    end 


	    rderr_out = (RDEN == 1'b1) && (empty_out == 1'b1);
	    
	    
	    if (WREN == 1'b1) begin
		empty_out = 1'b0;
	    end
	    else if (rdcount_out == wr_addr && rdcount_flag == wr_flag)
		empty_out = 1'b1;

	    if ((((rdcount_out + ae_empty) >= wr_addr) && (rdcount_flag == wr_flag)) || (((rdcount_out + ae_empty) >= (wr_addr + addr_limit) && (rdcount_flag != wr_flag)))) begin
		almostempty_out = 1'b1;
	    end

	    if ((((rdcount_out + addr_limit) > (wr_addr + ae_full)) && (rdcount_flag == wr_flag)) || ((rdcount_out > (wr_addr + ae_full)) && (rdcount_flag != wr_flag))) begin
		if (wr_addr <= wr_addr + ae_full || rdcount_flag == wr_flag)
		    almostfull_out = 1'b0;
	    end

	end
	else if (sync == 1'b0) begin

	    rden_reg = RDEN;
	    if (fwft == 1'b0) begin
		if ((rden_reg == 1'b1) && (rd_addr != rdcount_out)) begin
		    do_out = do_in;
		    if (DATA_WIDTH != 4) 
			dop_out = dop_in;
		    rd_addr = (rd_addr + 1) % addr_limit;
		    if (rd_addr == 0)
			rd_flag = ~rd_flag;
		end
		if (((rd_addr == rdcount_out) && (empty_ram[3] == 1'b0)) ||
		    ((rden_reg == 1'b1) && (empty_ram[1] == 1'b0))) begin

		    do_in = mem[rdcount_out];
		    dop_in = memp[rdcount_out];
		    
		    #1;
		    rdcount_out = (rdcount_out + 1) % addr_limit;
		    if (rdcount_out == 0) begin
			rdcount_flag = ~rdcount_flag;
		    end
		end
	    end

	    if (fwft == 1'b1) begin

		if ((rden_reg == 1'b1) && (rd_addr != rd_prefetch)) begin
		    rd_prefetch = (rd_prefetch + 1) % addr_limit;
		    if (rd_prefetch == 0)
			rdprefetch_flag = ~rdprefetch_flag;
		end
		if ((rd_prefetch == rd_addr) && (rd_addr != rdcount_out)) begin
		    do_out = do_in;
		    if (DATA_WIDTH != 4) 
			dop_out = dop_in;
		    rd_addr = (rd_addr + 1) % addr_limit;
		    if (rd_addr == 0)
			rd_flag = ~rd_flag;
		end
		if (((rd_addr == rdcount_out) && (empty_ram[3] == 1'b0)) ||
		    ((rden_reg == 1'b1) && (empty_ram[1] == 1'b0)) ||
		    ((rden_reg == 1'b0) && (empty_ram[1] == 1'b0) && (rd_addr == rdcount_out))) begin
		    
		    do_in = mem[rdcount_out];
		    dop_in = memp[rdcount_out];
		
		    #1;
		    rdcount_out = (rdcount_out + 1) % addr_limit;
		    if (rdcount_out == 0)
			rdcount_flag = ~rdcount_flag;
		end
	    end // if (fwft == 1'b1)
	    
	    
	    rderr_out = (rden_reg == 1'b1) && (empty_out == 1'b1);

	    almostempty_out = almostempty_int[3];

	    if ((((rdcount_out + ae_empty) >= wr_addr) && (rdcount_flag == awr_flag)) || (((rdcount_out + ae_empty) >= (wr_addr + addr_limit)) && (rdcount_flag != awr_flag))) begin
		almostempty_int[3] = 1'b1;
		almostempty_int[2] = 1'b1;
		almostempty_int[1] = 1'b1;
		almostempty_int[0] = 1'b1;
	    end
	    else if (almostempty_int[2] == 1'b0) begin

		if (rdcount_out <= rdcount_out + ae_empty || rdcount_flag != awr_flag) begin
		    almostempty_int[3] = almostempty_int[0];
		    almostempty_int[0] = 1'b0;
		    end
	    end
	    
	    if ((((rdcount_out + addr_limit) > (wr_addr + ae_full)) && (rdcount_flag == awr_flag)) || ((rdcount_out > (wr_addr + ae_full)) && (rdcount_flag != awr_flag))) begin

		if (((rden_reg == 1'b1) && (empty_out == 1'b0)) || ((((rd_addr + 1) % addr_limit) == rdcount_out) && (almostfull_int[1] == 1'b1))) begin
		    almostfull_int[2] = almostfull_int[1];
		    almostfull_int[1] = 1'b0;
		end
	    end
	    else begin
		almostfull_int[2] = 1'b1;
		almostfull_int[1] = 1'b1;
	    end

	    if (fwft == 1'b0) begin
		if ((rdcount_out == rd_addr) && (rdcount_flag == rd_flag)) begin
		    empty_out = 1'b1;
		end
		else begin
		    empty_out = 1'b0;
		end
	    end // if (fwft == 1'b0)
	    else if (fwft == 1'b1) begin
		if ((rd_prefetch == rd_addr) && (rdprefetch_flag == rd_flag)) begin
		    empty_out = 1'b1;
		end
		else begin
		    empty_out = 1'b0;
		end
	    end

	    if ((rdcount_out == wr_addr) && (rdcount_flag == awr_flag)) begin
		empty_ram[2] = 1'b1;
		empty_ram[1] = 1'b1;
		empty_ram[0] = 1'b1;
	    end
	    else begin
		empty_ram[2] = empty_ram[1];
		empty_ram[1] = empty_ram[0];
		empty_ram[0] = 1'b0;
	    end
	    
	    if ((rdcount_out == wr1_addr) && (rdcount_flag == wr1_flag)) begin
		empty_ram[3] = 1'b1;
	    end
	    else begin
		empty_ram[3] = 1'b0;
	    end

	    wr1_addr = wr_addr;
	    wr1_flag = awr_flag;

	end // if (sync == 1'b0)
    end // always @ (posedge RDCLK)
    

    always @(posedge WRCLK) begin

	if (sync == 1'b1) begin

	    if (WREN == 1'b1) begin

		if (full_out == 1'b0) begin

		    mem[wr_addr] = DI;
		    memp[wr_addr] = DIP;
		    
		    wr_addr = (wr_addr + 1) % addr_limit;
		    if (wr_addr == 0)
			wr_flag = ~wr_flag;

		end		
	    end 


	    wrerr_out = (WREN == 1'b1) && (full_out == 1'b1);
	    
	    
	    if (RDEN == 1'b1) begin
		full_out = 1'b0;
	    end
	    else if (rdcount_out == wr_addr && rdcount_flag != wr_flag)
		full_out = 1'b1;

	    if ((((rdcount_out + ae_empty) < wr_addr) && (rdcount_flag == wr_flag)) || (((rdcount_out + ae_empty) < (wr_addr + addr_limit) && (rdcount_flag != wr_flag)))) begin
		
		if (rdcount_out <= rdcount_out + ae_empty || rdcount_flag != wr_flag)
		    almostempty_out = 1'b0;

	    end

	    if ((((rdcount_out + addr_limit) <= (wr_addr + ae_full)) && (rdcount_flag == wr_flag)) || ((rdcount_out <= (wr_addr + ae_full)) && (rdcount_flag != wr_flag))) begin
		almostfull_out = 1'b1;
	    end
	    
	end
	else if (sync == 1'b0) begin

	    wren_reg = WREN;

	    if (wren_reg == 1'b1 && (full_out == 1'b0)) begin		

		mem[wr_addr] = DI;
		memp[wr_addr] = DIP;
		
		#1;
		wr_addr = (wr_addr + 1) % addr_limit;

		if (wr_addr == 0)
		    awr_flag = ~awr_flag;

		if (wr_addr == addr_limit - 1)
		    wr_flag = ~wr_flag;
	    end

	    wrerr_out = (wren_reg == 1'b1) && (full_out == 1'b1);

	    almostfull_out = almostfull_int[3];

	    if ((((rdcount_out + addr_limit) <= (wr_addr + ae_full)) && (rdcount_flag == awr_flag)) || ((rdcount_out <= (wr_addr + ae_full)) && (rdcount_flag != awr_flag))) begin
		almostfull_int[3] = 1'b1;
		almostfull_int[2] = 1'b1;
		almostfull_int[1] = 1'b1;
		almostfull_int[0] = 1'b1;
	    end
	    else if (almostfull_int[2] == 1'b0) begin

		if (wr_addr <= wr_addr + ae_full || rdcount_flag == awr_flag) begin
		    almostfull_int[3] = almostfull_int[0];
		    almostfull_int[0] = 1'b0;
		    end
	    end

	    if ((((rdcount_out + ae_empty) < wr_addr) && (rdcount_flag == awr_flag)) || (((rdcount_out + ae_empty) < (wr_addr + addr_limit)) && (rdcount_flag != awr_flag))) begin
		if (wren_reg == 1'b1) begin
		    almostempty_int[2] = almostempty_int[1];
		    almostempty_int[1] = 1'b0;
		end
	    end
	    else begin
		almostempty_int[2] = 1'b1;
		almostempty_int[1] = 1'b1;
	    end

	    if (wren_reg == 1'b1 || full_out == 1'b1)
		full_out = full_int[1];

	    if (((rdcount_out == wr_addr) || (rdcount_out - 1 == wr_addr || (rdcount_out + addr_limit - 1 == wr_addr))) && almostfull_out) begin
		full_int[1] = 1'b1;
		full_int[0] = 1'b1;
	    end
	    else begin
		full_int[1] = full_int[0];
		full_int[0] = 0;
	    end
	    
	end // if (sync == 1'b0)
    end // always @ (posedge WRCLK)

    
    always @(do_out or dop_out or do_outreg or dop_outreg) begin

	if (sync == 1)
	    
	    case (DO_REG)

		0 : begin
	                do_out_mux = do_out;
		        dop_out_mux = dop_out;
	            end
		1 : begin
		        do_out_mux = do_outreg;
		        dop_out_mux = dop_outreg;
	            end
	    endcase

	else begin
	    do_out_mux = do_out;
	    dop_out_mux = dop_out;
	end // else: !if(sync == 1)
	
    end // always @ (do_out or dop_out or do_outreg or dop_outreg)	

    
    end // if (SIM_MODE == "FAST")
    endgenerate
    // end FAST mode

    
endmodule
