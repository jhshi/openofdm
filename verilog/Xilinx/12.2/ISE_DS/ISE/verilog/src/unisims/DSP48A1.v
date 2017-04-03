///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2006 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Multifunctional, Cascadable, 48-bit Output Arithmetic Block
// /___/   /\     Filename : DSP48A1.v
// \   \  /  \    Timestamp : Thu Aug 16 14:46:39 PDT 2007
//  \___\/\___\
//
// Revision:
//    08/16/07 - Initial version.
//    05/07/08 - IR # 467568, pulldown CARRYIN, BCIN and PCIN -- both unisim and simprim 
//    07/08/08 - CR 473297 and 475997 fix -- removed input buffers that were causing NCSIM failures when sdf was backannotated
//    10/28/08 - IR 493742 initialized CARRYOUTs
//    02/09/09 - CR 503828 -- VCS compile warnings 
// End Revision

`timescale  1 ps / 1 ps

module DSP48A1 (BCOUT, CARRYOUT, CARRYOUTF, M, P, PCOUT, A, B, C, CARRYIN, CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, CLK, D, OPMODE, PCIN, RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP); 

    parameter integer A0REG = 0;
    parameter integer A1REG = 1;
    parameter integer B0REG = 0;
    parameter integer B1REG = 1;
    parameter integer CARRYINREG = 1;
    parameter integer CARRYOUTREG = 1;
    parameter CARRYINSEL = "OPMODE5";
    parameter integer CREG = 1;
    parameter integer DREG = 1;
    parameter integer MREG = 1;
    parameter integer OPMODEREG = 1;
    parameter integer PREG = 1;
    parameter RSTTYPE = "SYNC";


    output [17:0] BCOUT; 
    output CARRYOUT; 
    output CARRYOUTF; 
    output [35:0] M; 
    output [47:0] P; 
    output [47:0] PCOUT;

    input [17:0] A;
    input [17:0] B;

    input [47:0] C;
    input CARRYIN;
    input CEA;
    input CEB;
    input CEC;
    input CECARRYIN;
    input CED;
    input CEM;
    input CEOPMODE;
    input CEP;
    input CLK;
    input [17:0] D;
    input [7:0] OPMODE;
    input [47:0] PCIN;
    input RSTA;
    input RSTB;
    input RSTC;
    input RSTCARRYIN;
    input RSTD;
    input RSTM;  
    input RSTOPMODE;
    input RSTP;

    pulldown BCIN_tmp[17:0] (BCIN);
    pulldown(CARRYIN);
    pulldown PCIN_tmp[47:0] (PCIN);

    tri0  GSR = glbl.GSR;

//------------------- constants -------------------------
    localparam MAX_BCOUT      = 18;
    localparam MAX_P          = 48;
    localparam MAX_PCOUT      = 48;
 
    localparam MAX_A          = 18;
    localparam MAX_B          = 18;
    localparam MAX_BCIN       = 18;
    localparam MAX_C          = 48;
    localparam MAX_D          = 18;
    localparam MAX_OPMODE     = 8;
    localparam MAX_PCIN       = 48;


    localparam MAX_MULT_A     = 18;
    localparam MAX_MULT_B     = 18;
    localparam MAX_MULT_AB    = 36;
    localparam MAX_MUX_XZ     = 48;

    localparam MSB_BCOUT      = MAX_BCOUT - 1;
    localparam MSB_P          = MAX_P - 1;
    localparam MSB_M          = MAX_MULT_AB - 1;
    localparam MSB_PCOUT      = MAX_PCOUT - 1;

    localparam MSB_A          = MAX_A - 1;
    localparam MSB_B          = MAX_B - 1;
    localparam MSB_BCIN       = MAX_BCIN - 1;
    localparam MSB_C          = MAX_C - 1;
    localparam MSB_D          = MAX_D - 1;
    localparam MSB_OPMODE     = MAX_OPMODE - 1;
    localparam MSB_PCIN       = MAX_PCIN - 1;

    localparam MSB_MULT_A     = MAX_MULT_A - 1;
    localparam MSB_MULT_B     = MAX_MULT_B - 1;

    localparam MSB_MULT_AB    = MAX_MULT_AB - 1;
//--------------------------------------------------------------
    reg [MSB_A:0] qa_o_mux, qa_o_reg1, qa_o_reg2;
    reg [MSB_B:0] b_o_mux, qb_o_mux0 = 18'b0, qb_o_mux = 18'b0, qb_o_reg1, qb_o_reg2, preadd, mux_preadd;
    reg [MSB_C:0] qc_o_mux, qc_o_reg1;
    reg carryinsel_attr, carryinsel_o_mux;
    reg qcarryin_o_mux, qcarryin_o_reg1;
    reg carryout_o = 1'b0;
    reg qcarryout_o_mux = 1'b0; 
    reg qcarryout_o_reg1 = 1'b0;

    reg [MSB_MULT_AB:0] qmult_o_mux, qmult_o_reg1;

    reg [MSB_D:0] qd_o_mux, qd_o_reg1;

    reg [MSB_P:0] qp_o_mux = 48'b0, qp_o_reg1;

    reg [(MAX_MUX_XZ-1):0] qx_o_mux, qz_o_mux;
    reg [MSB_OPMODE:0]  qopmode_o_mux, qopmode_o_reg1;

    
    reg invalid_opmode, add_flag, rst_async_flag = 0;

    reg B_INPUT_flag;

    reg [(MAX_MUX_XZ-1):0] add_o;

    wire [MSB_MULT_AB:0] mult_o;

    wire carryout_x_o;


//*** GSR pin
    always @(GSR) begin
	if (GSR) begin
            assign qa_o_reg1 = 18'b0;
            assign qa_o_reg2 = 18'b0;
            assign qb_o_reg1 = 18'b0;
            assign qb_o_reg2 = 18'b0;
            assign qc_o_reg1 = 48'b0;
            assign qd_o_reg1 = 18'b0;
	    assign qmult_o_reg1 = 36'b0;
            assign qopmode_o_reg1 = 8'b0;
            assign qcarryin_o_reg1 = 1'b0;
            assign qp_o_reg1 = 48'b0;

	end
	else begin
            deassign qa_o_reg1;
            deassign qa_o_reg2;
            deassign qb_o_reg1;
            deassign qb_o_reg2;
            deassign qc_o_reg1;
            deassign qd_o_reg1;
	    deassign qmult_o_reg1;
            deassign qopmode_o_reg1;
            deassign qcarryin_o_reg1;
            deassign qp_o_reg1;
	end
    end

//---------------------------------------------------- 
//*** Initialization
//---------------------------------------------------- 



    initial begin

//-------- A0REG/A1REG  & B0REG/B1REG ------

        if ((A0REG != 0) && (A0REG != 1))
        begin 
	  $display("Attribute Syntax Error : The attribute A0REG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", A0REG);
	  $finish;
        end    

        if ((A1REG != 0) && (A1REG != 1))
        begin 
	  $display("Attribute Syntax Error : The attribute A1REG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", A1REG);
	  $finish;
        end    

        if ((B0REG != 0) && (B0REG != 1))
        begin 
	  $display("Attribute Syntax Error : The attribute B0REG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", B0REG);
	  $finish;
        end    

        if ((B1REG != 0) && (B1REG != 1))
        begin 
	  $display("Attribute Syntax Error : The attribute B1REG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", B1REG);
	  $finish;
        end    

//-------- RSTTYPE ------

	case (RSTTYPE)
	  "SYNC": rst_async_flag = 0;
          "ASYNC": rst_async_flag = 1;
	  default : begin
		          $display("Attribute Syntax Error : The attribute RSTTYPE on DSP48A1 instance %m is set to %s.  Legal values for this attribute are SYNC or ASYNC.", RSTTYPE);
		          $finish;
	              end
	endcase

//-------- CARRYINSEL ------

        case (CARRYINSEL)
                  "CARRYIN" : carryinsel_attr <= 1'b0;
                  "OPMODE5" : carryinsel_attr <= 1'b1;
            default : begin
                          $display("Attribute Syntax Error : The attribute CARRYINSEL on DSP48A1 instance %m is set to %s.  Legal valuesfor this attribute are CARRYIN or OPMODE5.", CARRYINSEL);
                          $finish;
                      end
        endcase

        add_flag <= 1;
        invalid_opmode <= 1;

    end
 

    
//---------------------------------------------------- 
//*** Input register A with 2 level deep of registers
//---------------------------------------------------- 
// Asynchronous Operation
    always @(posedge CLK, posedge RSTA) begin
      if(rst_async_flag) begin
         if(RSTA) begin
            qa_o_reg1 <= 18'b0;
            qa_o_reg2 <= 18'b0;
         end // if RSTA
         else if(CEA) begin
            qa_o_reg1 <= A;
            qa_o_reg2 <= qa_o_reg1;
         end // CEA 
      end // if rst_async_flg
    end // always

// Synchronous Operation
    always @(posedge CLK) begin
      if(!rst_async_flag) begin
         if(RSTA) begin
            qa_o_reg1 <= 18'b0;
            qa_o_reg2 <= 18'b0;
         end // if RSTA
         else if(CEA) begin
            qa_o_reg1 <= A;
            qa_o_reg2 <= qa_o_reg1;
         end // CEA 
      end // if rst_async_flg
    end // always

    always @(A or qa_o_reg1 or qa_o_reg2) begin
        if((A0REG==0) && (A1REG==0))
            qa_o_mux <= A;
        else if(((A0REG==0) && (A1REG==1)) || ((A0REG==1) && (A1REG==0)))
            qa_o_mux <= qa_o_reg1;
        else if((A0REG==1) && (A1REG==1))
            qa_o_mux <= qa_o_reg2;  
    end


//---------------------------------------------------- 
//*** Input register B with 2 level deep of registers
//---------------------------------------------------- 
// Asynchronous Operation 
    always @(posedge CLK, posedge RSTB) begin
      if(rst_async_flag) begin
         if(RSTB) begin
            qb_o_reg1 <= 18'b0;
            qb_o_reg2 <= 18'b0;
         end // if RSTB
         else if(CEB) begin
            qb_o_reg1 <= B;
            qb_o_reg2 <= mux_preadd;
         end // CEB 
      end // if rst_async_flg
    end // always

// Synchronous Operation
    always @(posedge CLK) begin
      if(!rst_async_flag) begin
         if(RSTB) begin
            qb_o_reg1 <= 18'b0;
            qb_o_reg2 <= 18'b0;
         end // if RSTB
         else if(CEB) begin
            qb_o_reg1 <= B;
            qb_o_reg2 <= mux_preadd;
         end // CEB 
      end // if rst_async_flg
    end // always

   
//*** PRE_ADD 
    always @(qopmode_o_mux, B, qd_o_mux, qb_o_reg1) begin
       if(((B0REG==0) && (B1REG==0)) || ((B0REG==0) && (B1REG==1))) begin
          qb_o_mux0 = B; 
          if(qopmode_o_mux[6] == 0) 
               preadd = (qd_o_mux + B);
          else if(qopmode_o_mux[6] == 1) 
               preadd = (qd_o_mux - B);
       end
       else if(((B0REG==1) && (B1REG==1)) || ((B0REG==1) && (B1REG==0))) begin
          qb_o_mux0 = qb_o_reg1; 
          if(qopmode_o_mux[6] == 0) 
               preadd = (qd_o_mux + qb_o_reg1);
          else if(qopmode_o_mux[6] == 1) 
                preadd = (qd_o_mux - qb_o_reg1);
       end
    end
                             
    always @(qopmode_o_mux[4], preadd, qb_o_mux0) begin
       if(qopmode_o_mux[4] == 1) 
           mux_preadd = preadd;
       else if(qopmode_o_mux[4] == 0)
           mux_preadd = qb_o_mux0;
    end
   
    always @(mux_preadd, qb_o_reg2) begin
       if(((B0REG==0) && (B1REG==0)) || ((B0REG==1) && (B1REG==0)))
           qb_o_mux = mux_preadd;
       else if(((B0REG==1) && (B1REG==1)) || ((B0REG==0) && (B1REG==1)))
           qb_o_mux = qb_o_reg2;
    end


//---------------------------------------------------- 
//*** Input register C with 1 level deep of registers
//---------------------------------------------------- 
// Asynchronous Operation
    always @(posedge CLK, posedge RSTC) begin
      if(rst_async_flag) begin
         if(RSTC) begin
            qc_o_reg1 <= 18'b0;
         end // if RSTC
         else if(CEC) begin
            qc_o_reg1 <= C;
         end // CEC 
      end // if rst_async_flg
    end // always

// Synchronous Operation
    always @(posedge CLK) begin
      if(!rst_async_flag) begin
         if(RSTC) begin
            qc_o_reg1 <= 18'b0;
         end // if RSTC
         else if(CEC) begin
            qc_o_reg1 <= C;
         end // CEC 
      end // if rst_async_flg
    end // always

    always @(C or qc_o_reg1) begin
	case (CREG)
                  0 : qc_o_mux <= C;
                  1 : qc_o_mux <= qc_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CREG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", CREG);
	                  $finish;
	              end
	endcase
    end

//---------------------------------------------------- 
//*** Input register D with 1 level deep of registers
//---------------------------------------------------- 
// Asynchronous Operation
    always @(posedge CLK, posedge RSTD) begin
      if(rst_async_flag) begin
         if(RSTD) begin
            qd_o_reg1 <= 18'b0;
         end // if RSTD
         else if(CED) begin
            qd_o_reg1 <= D;
         end // CED 
      end // if rst_async_flg
    end // always

// Synchronous Operation
    always @(posedge CLK) begin
      if(!rst_async_flag) begin
         if(RSTD) begin
            qd_o_reg1 <= 18'b0;
         end // if RSTD
         else if(CED) begin
            qd_o_reg1 <= D;
         end // CED 
      end // if rst_async_flg
    end // always

    always @(D or qd_o_reg1) begin
	case (DREG)
                  0 : qd_o_mux <= D;
                  1 : qd_o_mux <= qd_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute DREG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", DREG);
	                  $finish;
	              end
	endcase
    end


//---------------------------------------------------- 
//*** 18x18 Multiplier
//---------------------------------------------------- 
    assign mult_o = {{MAX_MULT_A{qa_o_mux[MSB_MULT_A]}}, qa_o_mux} * {{MAX_MULT_B{qb_o_mux[MSB_MULT_B]}}, qb_o_mux};

// Asynchronous Operation
    always @(posedge CLK, posedge RSTM) begin
      if(rst_async_flag) begin
         if(RSTM) begin
            qmult_o_reg1 <= 36'b0;
         end // if RSTM
         else if(CEM) begin
            qmult_o_reg1 <= mult_o;
         end // CEM 
      end // if rst_async_flg
    end // always

// Synchronous Operation
    always @(posedge CLK) begin
      if(!rst_async_flag) begin
         if(RSTM) begin
            qmult_o_reg1 <= 36'b0;
         end // if RSTM
         else if(CEM) begin
            qmult_o_reg1 <= mult_o;
         end // CEM 
      end // if rst_async_flg
    end // always

    always @(mult_o or qmult_o_reg1) begin
	case (MREG)
                  0 : qmult_o_mux <= mult_o;
                  1 : qmult_o_mux <= qmult_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute MREG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", MREG);
	                  $finish;
	              end
	endcase
    end


//*** X mux
    
    always @(qp_o_mux or qa_o_mux or qd_o_mux or qb_o_mux or qmult_o_mux or qopmode_o_mux) begin
	case (qopmode_o_mux[1:0])
              2'b00 : qx_o_mux <= 48'b0;
              2'b01 : qx_o_mux <= {{12{qmult_o_mux[MSB_MULT_AB]}}, qmult_o_mux};
              2'b10 : qx_o_mux <= qp_o_mux;
              2'b11 : qx_o_mux <= {qd_o_mux[11:0], qa_o_mux[17:0], qb_o_mux[17:0]};
            default : begin
	              end
	endcase
    end


//*** Z mux

    always @(qp_o_mux or qc_o_mux or PCIN or qopmode_o_mux) begin
	case (qopmode_o_mux[3:2])
             3'b00 : qz_o_mux <= 48'b0;
             3'b01 : qz_o_mux <= PCIN;
             3'b10 : qz_o_mux <= qp_o_mux;
             3'b11 : qz_o_mux <= qc_o_mux;
            default : begin
	              end
	endcase
    end


//---------------------------------------------------- 
//*** CarryIn 1 level of register
//---------------------------------------------------- 
    always @(qopmode_o_mux[5], CARRYIN) begin
	case (CARRYINSEL)
                  "CARRYIN" : carryinsel_o_mux <= CARRYIN;
                  "OPMODE5" : carryinsel_o_mux <= qopmode_o_mux[5];
            default : begin
	                  $display("Attribute Syntax Error : The attribute CARRYINSEL on DSP48A1 instance %m is set to %s.  Legal values for this attribute are CARRYIN or OPMODE5.", CARRYINSEL);
	                  $finish;
	              end
	endcase
    end

// Asynchronous Operation
    always @(posedge CLK, posedge RSTCARRYIN) begin
      if(rst_async_flag) begin
         if(RSTCARRYIN) begin
            qcarryin_o_reg1  <= 1'b0;
            qcarryout_o_reg1 <= 1'b0;
         end // if RSTCARRYIN
         else if(CECARRYIN) begin
            qcarryin_o_reg1  <= carryinsel_o_mux;
            qcarryout_o_reg1 <= carryout_o;
         end // CECARRYIN 
      end // if rst_async_flg
    end // always

// Synchronous Operation
    always @(posedge CLK) begin
	if (RSTCARRYIN) begin
            qcarryin_o_reg1  <= 1'b0;
            qcarryout_o_reg1 <= 1'b0;
	end  
	else if (CECARRYIN) begin
            qcarryin_o_reg1  <= carryinsel_o_mux;
            qcarryout_o_reg1 <= carryout_o;
	end
    end


    always @(carryinsel_o_mux or qcarryin_o_reg1) begin
	case (CARRYINREG)
                  0 : qcarryin_o_mux <= carryinsel_o_mux;
                  1 : qcarryin_o_mux <= qcarryin_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CARRYINREG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", CARRYINREG);
	                  $finish;
	              end
	endcase
    end


//---------------------------------------------------- 
//*** Opmode 1 level of register
//---------------------------------------------------- 
// Asynchronous Operation
    always @(posedge CLK, posedge RSTOPMODE) begin
      if(rst_async_flag) begin
         if(RSTOPMODE) begin
            qopmode_o_reg1 <= 8'b0;
         end // if RSTOPMODE
         else if(CEOPMODE) begin
            qopmode_o_reg1 <= OPMODE;
         end // CEOPMODE 
      end // if rst_async_flg
    end // always

// Synchronous Operation
    always @(posedge CLK) begin
	if (RSTOPMODE) begin
            qopmode_o_reg1 <= 8'b0;
	end  
	else if (CEOPMODE) begin
            qopmode_o_reg1 <= OPMODE;
	end
    end


    always @(OPMODE or qopmode_o_reg1) begin
	case (OPMODEREG)
                  0 : qopmode_o_mux <= OPMODE;
                  1 : qopmode_o_mux <= qopmode_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute OPMODEREG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", OPMODEREG);
	                  $finish;
	              end
	endcase
    end



//---------------------------------------------------- 
//*** CarryOut/CarryOutF 1 level of register
//---------------------------------------------------- 

    always @(carryout_o or qcarryout_o_reg1) begin
	case (CARRYOUTREG)
                  0 : qcarryout_o_mux <= carryout_o;
                  1 : qcarryout_o_mux <= qcarryout_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute CARRYOUTREG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", OPMODEREG);
	                  $finish;
	              end
	endcase
    end
//---------------------------------------------------- 
//*** DRC for OPMODE
//---------------------------------------------------- 

    always @(qopmode_o_mux or carryinsel_attr or qz_o_mux or qx_o_mux or qcarryin_o_mux) begin

        if ($time > 100000) begin  // no check at first 100ns

            case ({qopmode_o_mux, carryinsel_attr})

                9'b000000000 : deassign_xz_mux;
                9'b000100000 : deassign_xz_mux;
                9'b001000000 : deassign_xz_mux;
                9'b001100000 : deassign_xz_mux;
                9'b010000000 : deassign_xz_mux;
                9'b010100000 : deassign_xz_mux;
                9'b011000000 : deassign_xz_mux;
                9'b011100000 : deassign_xz_mux;
                9'b100000000 : deassign_xz_mux;
                9'b100100000 : deassign_xz_mux;
                9'b101000000 : deassign_xz_mux;
                9'b101100000 : deassign_xz_mux;
                9'b110000000 : deassign_xz_mux;
                9'b110100000 : deassign_xz_mux;
                9'b111000000 : deassign_xz_mux;
                9'b111100000 : deassign_xz_mux;
                9'b000000001 : deassign_xz_mux;
                9'b000100001 : deassign_xz_mux;
                9'b001000001 : deassign_xz_mux;
                9'b001100001 : deassign_xz_mux;
                9'b010000001 : deassign_xz_mux;
                9'b010100001 : deassign_xz_mux;
                9'b011000001 : deassign_xz_mux;
                9'b011100001 : deassign_xz_mux;
                9'b100000001 : deassign_xz_mux;
                9'b100100001 : deassign_xz_mux;
                9'b101000001 : deassign_xz_mux;
                9'b101100001 : deassign_xz_mux;
                9'b110000001 : deassign_xz_mux;
                9'b110100001 : deassign_xz_mux;
                9'b111000001 : deassign_xz_mux;
                9'b111100001 : deassign_xz_mux;
                9'b000000100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000000101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000100100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000100101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001000100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001000101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001100100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001100101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010000100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010000101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010100100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010100101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011000100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011000101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011100100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011100101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100000100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100000101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100100100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100100101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101000100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101000101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101100100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101100101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110000100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110000101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110100100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110100101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111000100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111000101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111100100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111100101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000000110 : deassign_xz_mux;
                9'b000000111 : deassign_xz_mux;
                9'b001000110 : deassign_xz_mux;
                9'b001000111 : deassign_xz_mux;
                9'b010000110 : deassign_xz_mux;
                9'b010000111 : deassign_xz_mux;
                9'b011000110 : deassign_xz_mux;
                9'b011000111 : deassign_xz_mux;
                9'b100000110 : deassign_xz_mux;
                9'b100000111 : deassign_xz_mux;
                9'b101000110 : deassign_xz_mux;
                9'b101000111 : deassign_xz_mux;
                9'b110000110 : deassign_xz_mux;
                9'b110000111 : deassign_xz_mux;
                9'b111000110 : deassign_xz_mux;
                9'b111000111 : deassign_xz_mux;
                9'b000100110 : deassign_xz_mux;
                9'b000100111 : deassign_xz_mux;
                9'b001100110 : deassign_xz_mux;
                9'b001100111 : deassign_xz_mux;
                9'b010100110 : deassign_xz_mux;
                9'b010100111 : deassign_xz_mux;
                9'b011100110 : deassign_xz_mux;
                9'b011100111 : deassign_xz_mux;
                9'b100100110 : deassign_xz_mux;
                9'b100100111 : deassign_xz_mux;
                9'b101100110 : deassign_xz_mux;
                9'b101100111 : deassign_xz_mux;
                9'b110100110 : deassign_xz_mux;
                9'b110100111 : deassign_xz_mux;
                9'b111100110 : deassign_xz_mux;
                9'b111100111 : deassign_xz_mux;
                9'b000000010 : deassign_xz_mux;
                9'b000000011 : deassign_xz_mux;
                9'b001000010 : deassign_xz_mux;
                9'b001000011 : deassign_xz_mux;
                9'b010000010 : deassign_xz_mux;
                9'b010000011 : deassign_xz_mux;
                9'b011000010 : deassign_xz_mux;
                9'b011000011 : deassign_xz_mux;
                9'b100000010 : deassign_xz_mux;
                9'b100000011 : deassign_xz_mux;
                9'b101000010 : deassign_xz_mux;
                9'b101000011 : deassign_xz_mux;
                9'b110000010 : deassign_xz_mux;
                9'b110000011 : deassign_xz_mux;
                9'b111000010 : deassign_xz_mux;
                9'b111000011 : deassign_xz_mux;
                9'b000100010 : deassign_xz_mux;
                9'b000100011 : deassign_xz_mux;
                9'b001100010 : deassign_xz_mux;
                9'b001100011 : deassign_xz_mux;
                9'b100100010 : deassign_xz_mux;
                9'b100100011 : deassign_xz_mux;
                9'b101100010 : deassign_xz_mux;
                9'b101100011 : deassign_xz_mux;
                9'b010100010 : deassign_xz_mux;
                9'b010100011 : deassign_xz_mux;
                9'b011100010 : deassign_xz_mux;
                9'b011100011 : deassign_xz_mux;
                9'b110100010 : deassign_xz_mux;
                9'b110100011 : deassign_xz_mux;
                9'b111100010 : deassign_xz_mux;
                9'b111100011 : deassign_xz_mux;
                9'b000001000 : deassign_xz_mux;
                9'b000001001 : deassign_xz_mux;
                9'b000101000 : deassign_xz_mux;
                9'b000101001 : deassign_xz_mux;
                9'b001001000 : deassign_xz_mux;
                9'b001001001 : deassign_xz_mux;
                9'b001101000 : deassign_xz_mux;
                9'b001101001 : deassign_xz_mux;
                9'b010001000 : deassign_xz_mux;
                9'b010001001 : deassign_xz_mux;
                9'b010101000 : deassign_xz_mux;
                9'b010101001 : deassign_xz_mux;
                9'b011001000 : deassign_xz_mux;
                9'b011001001 : deassign_xz_mux;
                9'b011101000 : deassign_xz_mux;
                9'b011101001 : deassign_xz_mux;
                9'b100001000 : deassign_xz_mux;
                9'b100001001 : deassign_xz_mux;
                9'b100101000 : deassign_xz_mux;
                9'b100101001 : deassign_xz_mux;
                9'b101001000 : deassign_xz_mux;
                9'b101001001 : deassign_xz_mux;
                9'b101101000 : deassign_xz_mux;
                9'b101101001 : deassign_xz_mux;
                9'b110001000 : deassign_xz_mux;
                9'b110001001 : deassign_xz_mux;
                9'b110101000 : deassign_xz_mux;
                9'b110101001 : deassign_xz_mux;
                9'b111001000 : deassign_xz_mux;
                9'b111001001 : deassign_xz_mux;
                9'b111101000 : deassign_xz_mux;
                9'b111101001 : deassign_xz_mux;
                9'b000001100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000001101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000101100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000101101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001001100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001001101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001101100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001101101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010001100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010001101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010101100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010101101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011001100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011001101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011101100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011101101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100001100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100001101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100101100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100101101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101001100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101001101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101101100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101101101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110001100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110001101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110101100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110101101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111001100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111001101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111101100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111101101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000001110 : deassign_xz_mux;
                9'b000001111 : deassign_xz_mux;
                9'b001001110 : deassign_xz_mux;
                9'b001001111 : deassign_xz_mux;
                9'b010001110 : deassign_xz_mux;
                9'b010001111 : deassign_xz_mux;
                9'b011001110 : deassign_xz_mux;
                9'b011001111 : deassign_xz_mux;
                9'b100001110 : deassign_xz_mux;
                9'b100001111 : deassign_xz_mux;
                9'b101001110 : deassign_xz_mux;
                9'b101001111 : deassign_xz_mux;
                9'b110001110 : deassign_xz_mux;
                9'b110001111 : deassign_xz_mux;
                9'b111001110 : deassign_xz_mux;
                9'b111001111 : deassign_xz_mux;
                9'b000101110 : deassign_xz_mux;
                9'b000101111 : deassign_xz_mux;
                9'b001101110 : deassign_xz_mux;
                9'b001101111 : deassign_xz_mux;
                9'b010101110 : deassign_xz_mux;
                9'b010101111 : deassign_xz_mux;
                9'b011101110 : deassign_xz_mux;
                9'b011101111 : deassign_xz_mux;
                9'b100101110 : deassign_xz_mux;
                9'b100101111 : deassign_xz_mux;
                9'b101101110 : deassign_xz_mux;
                9'b101101111 : deassign_xz_mux;
                9'b110101110 : deassign_xz_mux;
                9'b110101111 : deassign_xz_mux;
                9'b111101110 : deassign_xz_mux;
                9'b111101111 : deassign_xz_mux;
                9'b000001010 : deassign_xz_mux;
                9'b000001011 : deassign_xz_mux;
                9'b001001010 : deassign_xz_mux;
                9'b001001011 : deassign_xz_mux;
                9'b010001010 : deassign_xz_mux;
                9'b010001011 : deassign_xz_mux;
                9'b011001010 : deassign_xz_mux;
                9'b011001011 : deassign_xz_mux;
                9'b100001010 : deassign_xz_mux;
                9'b100001011 : deassign_xz_mux;
                9'b101001010 : deassign_xz_mux;
                9'b101001011 : deassign_xz_mux;
                9'b110001010 : deassign_xz_mux;
                9'b110001011 : deassign_xz_mux;
                9'b111001010 : deassign_xz_mux;
                9'b111001011 : deassign_xz_mux;
                9'b000101010 : deassign_xz_mux;
                9'b000101011 : deassign_xz_mux;
                9'b001101010 : deassign_xz_mux;
                9'b001101011 : deassign_xz_mux;
                9'b100101010 : deassign_xz_mux;
                9'b100101011 : deassign_xz_mux;
                9'b101101010 : deassign_xz_mux;
                9'b101101011 : deassign_xz_mux;
                9'b010101010 : deassign_xz_mux;
                9'b010101011 : deassign_xz_mux;
                9'b011101010 : deassign_xz_mux;
                9'b011101011 : deassign_xz_mux;
                9'b110101010 : deassign_xz_mux;
                9'b110101011 : deassign_xz_mux;
                9'b111101010 : deassign_xz_mux;
                9'b111101011 : deassign_xz_mux;
                9'b000010000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000010001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000110000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000110001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001010000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001010001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001110000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001110001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010010000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010010001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010110000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010110001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011010000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011010001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011110000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011110001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100010000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100010001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100110000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100110001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101010000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101010001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101110000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101110001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110010000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110010001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110110000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110110001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111010000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111010001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111110000 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111110001 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000010100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000010101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000110100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000110101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001010100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001010101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001110100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001110101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010010100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010010101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010110100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010110101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011010100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011010101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011110100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011110101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100010100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100010101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100110100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100110101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101010100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101010101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101110100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101110101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110010100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110010101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110110100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110110101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111010100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111010101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111110100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111110101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000010110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000010111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001010110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001010111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010010110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010010111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011010110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011010111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100010110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100010111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101010110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101010111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110010110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110010111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111010110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111010111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000110110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000110111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001110110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001110111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010110110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010110111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011110110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011110111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100110110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100110111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101110110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101110111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110110110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110110111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111110110 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111110111 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000010010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000010011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001010010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001010011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010010010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010010011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011010010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011010011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100010010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100010011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101010010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101010011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110010010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110010011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111010010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111010011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000110010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000110011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001110010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001110011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100110010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100110011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101110010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101110011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010110010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010110011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011110010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011110011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110110010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110110011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111110010 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111110011 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000011000 : deassign_xz_mux;
                9'b000011001 : deassign_xz_mux;
                9'b000111000 : deassign_xz_mux;
                9'b000111001 : deassign_xz_mux;
                9'b001011000 : deassign_xz_mux;
                9'b001011001 : deassign_xz_mux;
                9'b001111000 : deassign_xz_mux;
                9'b001111001 : deassign_xz_mux;
                9'b010011000 : deassign_xz_mux;
                9'b010011001 : deassign_xz_mux;
                9'b010111000 : deassign_xz_mux;
                9'b010111001 : deassign_xz_mux;
                9'b011011000 : deassign_xz_mux;
                9'b011011001 : deassign_xz_mux;
                9'b011111000 : deassign_xz_mux;
                9'b011111001 : deassign_xz_mux;
                9'b100011000 : deassign_xz_mux;
                9'b100011001 : deassign_xz_mux;
                9'b100111000 : deassign_xz_mux;
                9'b100111001 : deassign_xz_mux;
                9'b101011000 : deassign_xz_mux;
                9'b101011001 : deassign_xz_mux;
                9'b101111000 : deassign_xz_mux;
                9'b101111001 : deassign_xz_mux;
                9'b110011000 : deassign_xz_mux;
                9'b110011001 : deassign_xz_mux;
                9'b110111000 : deassign_xz_mux;
                9'b110111001 : deassign_xz_mux;
                9'b111011000 : deassign_xz_mux;
                9'b111011001 : deassign_xz_mux;
                9'b111111000 : deassign_xz_mux;
                9'b111111001 : deassign_xz_mux;
                9'b000011100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000011101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000111100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000111101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001011100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001011101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001111100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b001111101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010011100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010011101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010111100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b010111101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011011100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011011101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011111100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b011111101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100011100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100011101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100111100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b100111101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101011100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101011101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101111100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b101111101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110011100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110011101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110111100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b110111101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111011100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111011101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111111100 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b111111101 : if (PREG != 1) display_invalid_opmode; else deassign_xz_mux;
                9'b000011110 : deassign_xz_mux;
                9'b000011111 : deassign_xz_mux;
                9'b001011110 : deassign_xz_mux;
                9'b001011111 : deassign_xz_mux;
                9'b010011110 : deassign_xz_mux;
                9'b010011111 : deassign_xz_mux;
                9'b011011110 : deassign_xz_mux;
                9'b011011111 : deassign_xz_mux;
                9'b100011110 : deassign_xz_mux;
                9'b100011111 : deassign_xz_mux;
                9'b101011110 : deassign_xz_mux;
                9'b101011111 : deassign_xz_mux;
                9'b110011110 : deassign_xz_mux;
                9'b110011111 : deassign_xz_mux;
                9'b111011110 : deassign_xz_mux;
                9'b111011111 : deassign_xz_mux;
                9'b000011010 : deassign_xz_mux;
                9'b000011011 : deassign_xz_mux;
                9'b001011010 : deassign_xz_mux;
                9'b001011011 : deassign_xz_mux;
                9'b010011010 : deassign_xz_mux;
                9'b010011011 : deassign_xz_mux;
                9'b011011010 : deassign_xz_mux;
                9'b011011011 : deassign_xz_mux;
                9'b100011010 : deassign_xz_mux;
                9'b100011011 : deassign_xz_mux;
                9'b101011010 : deassign_xz_mux;
                9'b101011011 : deassign_xz_mux;
                9'b110011010 : deassign_xz_mux;
                9'b110011011 : deassign_xz_mux;
                9'b111011010 : deassign_xz_mux;
                9'b111011011 : deassign_xz_mux;
                9'b000111010 : deassign_xz_mux;
                9'b000111011 : deassign_xz_mux;
                9'b001111010 : deassign_xz_mux;
                9'b001111011 : deassign_xz_mux;
                9'b100111010 : deassign_xz_mux;
                9'b100111011 : deassign_xz_mux;
                9'b101111010 : deassign_xz_mux;
                9'b101111011 : deassign_xz_mux;
                9'b010111010 : deassign_xz_mux;
                9'b010111011 : deassign_xz_mux;
                9'b011111010 : deassign_xz_mux;
                9'b011111011 : deassign_xz_mux;
                9'b110111010 : deassign_xz_mux;
                9'b110111011 : deassign_xz_mux;
                9'b111111010 : deassign_xz_mux;
                9'b111111011 : deassign_xz_mux;
                9'b000111110 : deassign_xz_mux;
                9'b000111111 : deassign_xz_mux;
                9'b001111110 : deassign_xz_mux;
                9'b001111111 : deassign_xz_mux;
                9'b010111110 : deassign_xz_mux;
                9'b010111111 : deassign_xz_mux;
                9'b011111110 : deassign_xz_mux;
                9'b011111111 : deassign_xz_mux;
                9'b100111110 : deassign_xz_mux;
                9'b100111111 : deassign_xz_mux;
                9'b101111110 : deassign_xz_mux;
                9'b101111111 : deassign_xz_mux;
                9'b110111110 : deassign_xz_mux;
                9'b110111111 : deassign_xz_mux;
                9'b111111110 : deassign_xz_mux;
                9'b111111111 : deassign_xz_mux;
                default : begin
                              if (invalid_opmode) begin

                                  invalid_opmode = 0;
                                  assign qx_o_mux = 48'bx;
                                  assign qz_o_mux = 48'bx;
                                  assign add_o    = 48'bx;
                                  $display("OPMODE Input Warning : The OPMODE %b to DSP48A1 instance %m is either invalid or the CARRYINSEL %b for that specific OPMODE at %.3f ns.", qopmode_o_mux, carryinsel_attr, $time/1000.0);

                              end
                          end

            endcase // case(OPMODE)

        end // if ($time > 100000)

// ***  Add/Subtract
        if (add_flag) begin
            if (qopmode_o_mux[7] == 1'b1)
                {carryout_o, add_o} = qz_o_mux - qx_o_mux - qcarryin_o_mux;
            else if (qopmode_o_mux[7] == 1'b0)
                {carryout_o, add_o} = qz_o_mux + qx_o_mux  + qcarryin_o_mux;
        end // if (add_flag = 1)

    end // always @ (qopmode_o_mux)

//----------------------------------------------------

    task deassign_xz_mux;
	begin
	    add_flag = 1;
	    invalid_opmode = 1;  // reset invalid opmode
	    deassign qx_o_mux;
	    deassign qz_o_mux;
	    deassign add_o;
	end
    endtask // deassign_xz_mux

    task display_invalid_opmode_no_mreg;
	begin
	    if (invalid_opmode) begin
		
		add_flag = 0;
		invalid_opmode = 0;
		assign qx_o_mux = 48'bx;
		assign qz_o_mux = 48'bx;
		assign add_o = 48'bx;
		$display("OPMODE Input Warning : The OPMODE %b with CARRYINSEL %b to DSP48A1 instance %m at %.3f ns requires attribute MREG set to 0.", qopmode_o_mux, carryinsel_attr, $time/1000.0);
	    end
	end
    endtask // display_invalid_opmode_no_mreg

    task display_invalid_opmode_mreg;
	begin
	    if (invalid_opmode) begin
		add_flag = 0;
		invalid_opmode = 0;
		assign qx_o_mux = 48'bx;
		assign qz_o_mux = 48'bx;
		assign add_o = 48'bx;
		$display("OPMODE Input Warning : The OPMODE %b with CARRYINSEL %b to DSP48A1 instance %m at %.3f ns requires attribute MREG set to 1.", qopmode_o_mux, carryinsel_attr, $time/1000.0);
	    end
	end
    endtask // display_invalid_opmode_mreg
    
    task display_invalid_opmode;
	begin
	    if (invalid_opmode) begin
		add_flag = 0;
		invalid_opmode = 0;
		assign qx_o_mux = 48'bx;
		assign qz_o_mux = 48'bx;
		assign add_o = 48'bx;
		$display("OPMODE Input Warning : The OPMODE %b to DSP48A1 instance %m at %.3f ns requires attribute PREG set to 1.", qopmode_o_mux, $time/1000.0);
	    end
	end
    endtask // display_invalid_opmode
    
//---------------------------------------------------- 
//*** Output register P with 1 level of register
//---------------------------------------------------- 
// Asynchronous Operation
    always @(posedge CLK, posedge RSTP) begin
      if(rst_async_flag) begin
         if(RSTP) begin
            qp_o_reg1 <= 48'b0;
         end // if RSTP
         else if(CEP) begin
            qp_o_reg1 <= add_o;
         end // CEP 
      end // if rst_async_flg
    end

// Synchronous Operation
    always @(posedge CLK) begin
	if (RSTP)
            qp_o_reg1 <= 48'b0;
	else if (CEP)
            qp_o_reg1 <= add_o;
    end
 
    always @(qp_o_reg1 or add_o) begin
	case (PREG)
                  0 : qp_o_mux <= add_o;
                  1 : qp_o_mux <= qp_o_reg1;
            default : begin
	                  $display("Attribute Syntax Error : The attribute PREG on DSP48A1 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", PREG);
	                  $finish;
	              end
	endcase
    end

//---------------------------------------------------- 
//*** CARRYOUT
//---------------------------------------------------- 
assign carryout_x_o = qcarryout_o_mux;



    assign BCOUT     = qb_o_mux;
    assign CARRYOUT  = carryout_x_o;
    assign CARRYOUTF = carryout_x_o;
    assign M         = qmult_o_mux;
    assign P         = qp_o_mux;
    assign PCOUT     = qp_o_mux;

    specify

        (A *> CARRYOUT) = (0:0:0, 0:0:0);
        (A *> CARRYOUTF) = (0:0:0, 0:0:0);
        (A *> M) = (0:0:0, 0:0:0);
        (A *> P) = (0:0:0, 0:0:0);
        (A *> PCOUT) = (0:0:0, 0:0:0);

        (B *> BCOUT) = (0:0:0, 0:0:0);
        (B *> CARRYOUT) = (0:0:0, 0:0:0);
        (B *> CARRYOUTF) = (0:0:0, 0:0:0);
        (B *> M) = (0:0:0, 0:0:0);
        (B *> P) = (0:0:0, 0:0:0);
        (B *> PCOUT) = (0:0:0, 0:0:0);

//        (BCIN *> BCOUT) = (0:0:0, 0:0:0);
//        (BCIN *> CARRYOUT) = (0:0:0, 0:0:0);
//        (BCIN *> P) = (0:0:0, 0:0:0);
//        (BCIN *> PCOUT) = (0:0:0, 0:0:0);

        (C *> CARRYOUT) = (0:0:0, 0:0:0);
        (C *> CARRYOUTF) = (0:0:0, 0:0:0);
        (C *> M) = (0:0:0, 0:0:0);
        (C *> P) = (0:0:0, 0:0:0);
        (C *> PCOUT) = (0:0:0, 0:0:0);

        (D *> BCOUT) = (0:0:0, 0:0:0);
        (D *> CARRYOUT) = (0:0:0, 0:0:0);
        (D *> CARRYOUTF) = (0:0:0, 0:0:0);
        (D *> M) = (0:0:0, 0:0:0);
        (D *> P) = (0:0:0, 0:0:0);
        (D *> PCOUT) = (0:0:0, 0:0:0);

        (CARRYIN *> CARRYOUT) = (0:0:0, 0:0:0);
        (CARRYIN *> CARRYOUTF) = (0:0:0, 0:0:0);
	(CARRYIN *> M) = (0:0:0, 0:0:0);
	(CARRYIN *> P) = (0:0:0, 0:0:0);
        (CARRYIN *> PCOUT) = (0:0:0, 0:0:0);

        (CLK *> BCOUT) = (100:100:100, 100:100:100);
        (CLK *> CARRYOUT) = (100:100:100, 100:100:100);
        (CLK *> CARRYOUTF) = (100:100:100, 100:100:100);
        (CLK *> M) = (100:100:100, 100:100:100);
        (CLK *> P) = (100:100:100, 100:100:100);
        (CLK *> PCOUT) = (100:100:100, 100:100:100);

        (OPMODE *> BCOUT) = (0:0:0, 0:0:0);
        (OPMODE *> CARRYOUT) = (0:0:0, 0:0:0);
        (OPMODE *> CARRYOUTF) = (0:0:0, 0:0:0);
        (OPMODE *> M) = (0:0:0, 0:0:0);
        (OPMODE *> P) = (0:0:0, 0:0:0);
        (OPMODE *> PCOUT) = (0:0:0, 0:0:0);

        (PCIN *> CARRYOUT) = (0:0:0, 0:0:0);
        (PCIN *> CARRYOUTF) = (0:0:0, 0:0:0);
        (PCIN *> M) = (0:0:0, 0:0:0);
        (PCIN *> P) = (0:0:0, 0:0:0);
        (PCIN *> PCOUT) = (0:0:0, 0:0:0);
// Asynchronous
        (RSTA *> CARRYOUT) = (0:0:0, 0:0:0);
        (RSTA *> CARRYOUTF) = (0:0:0, 0:0:0);
        (RSTA *> M) = (0:0:0, 0:0:0);
        (RSTA *> P) = (0:0:0, 0:0:0);
        (RSTA *> PCOUT) = (0:0:0, 0:0:0);

        (RSTB *> CARRYOUT) = (0:0:0, 0:0:0);
        (RSTB *> CARRYOUTF) = (0:0:0, 0:0:0);
        (RSTB *> BCOUT) = (0:0:0, 0:0:0);
        (RSTB *> M) = (0:0:0, 0:0:0);
        (RSTB *> P) = (0:0:0, 0:0:0);
        (RSTB *> PCOUT) = (0:0:0, 0:0:0);

        (RSTC *> CARRYOUT) = (0:0:0, 0:0:0);
        (RSTC *> CARRYOUTF) = (0:0:0, 0:0:0);
        (RSTC *> M) = (0:0:0, 0:0:0);
        (RSTC *> P) = (0:0:0, 0:0:0);
        (RSTC *> PCOUT) = (0:0:0, 0:0:0);

        (RSTCARRYIN *> CARRYOUT) = (0:0:0, 0:0:0);
        (RSTCARRYIN *> CARRYOUTF) = (0:0:0, 0:0:0);
        (RSTCARRYIN *> M) = (0:0:0, 0:0:0);
        (RSTCARRYIN *> P) = (0:0:0, 0:0:0);
        (RSTCARRYIN *> PCOUT) = (0:0:0, 0:0:0);

        (RSTD *> BCOUT) = (0:0:0, 0:0:0);
        (RSTD *> CARRYOUT) = (0:0:0, 0:0:0);
        (RSTD *> CARRYOUTF) = (0:0:0, 0:0:0);
        (RSTD *> M) = (0:0:0, 0:0:0);
        (RSTD *> P) = (0:0:0, 0:0:0);
        (RSTD *> PCOUT) = (0:0:0, 0:0:0);

        (RSTM *> CARRYOUT) = (0:0:0, 0:0:0);
        (RSTM *> CARRYOUTF) = (0:0:0, 0:0:0);
        (RSTM *> M) = (0:0:0, 0:0:0);
        (RSTM *> P) = (0:0:0, 0:0:0);
        (RSTM *> PCOUT) = (0:0:0, 0:0:0);

        (RSTOPMODE *> BCOUT) = (0:0:0, 0:0:0);
        (RSTOPMODE *> CARRYOUT) = (0:0:0, 0:0:0);
        (RSTOPMODE *> CARRYOUTF) = (0:0:0, 0:0:0);
        (RSTOPMODE *> M) = (0:0:0, 0:0:0);
        (RSTOPMODE *> P) = (0:0:0, 0:0:0);
        (RSTOPMODE *> PCOUT) = (0:0:0, 0:0:0);

        (RSTP *> P) = (0:0:0, 0:0:0);
        (RSTP *> PCOUT) = (0:0:0, 0:0:0);

        specparam PATHPULSE$ = 0;

    endspecify

endmodule // DSP48A1

