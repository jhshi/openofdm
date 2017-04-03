///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Source Synchronous Output Serializer
// /___/   /\     Filename : OSERDESE1.v
// \   \  /  \    Timestamp : Tue Sep 16 15:30:44 PDT 2008
//  \___\/\___\
//
// Revision:
//    09/16/08 - Initial version.
//    12/05/08 - IR 495397.
//    01/13/09 - IR 503429.
//    01/15/09 - IR 503783 CLKPERF is not inverted for OFB/ofb_out.
//    02/06/09 - CR 507373 Removed IOCLKGLITCH and CLKB
//    02/26/09 - CR 510489 fixed SHIFTIN2_in
//    03/16/09 - CR 512140 and 512139 -- sdf load errors
//    01/27/10 - CR 546419 Updated specify block
//    04/12/10 - CR 551953 Enabled TRISTATE_WIDTH to be 1 in DDR mode.
// End Revision

`timescale  1 ps / 1 ps

module OSERDESE1 (OCBEXTEND, OFB, OQ, SHIFTOUT1, SHIFTOUT2, TFB, TQ,
                    CLK, CLKDIV, CLKPERF, CLKPERFDELAY, D1, D2, D3, D4, D5, D6, OCE, ODV, RST, SHIFTIN1, SHIFTIN2, T1, T2, T3, T4, TCE, WC);



    parameter DATA_RATE_OQ = "DDR";
    parameter DATA_RATE_TQ = "DDR";
    parameter integer DATA_WIDTH = 4;
    parameter integer DDR3_DATA = 1;
    parameter INIT_OQ = 1'b0;
    parameter INIT_TQ = 1'b0;
    parameter INTERFACE_TYPE = "DEFAULT";
    parameter integer ODELAY_USED = 0;
    parameter SERDES_MODE = "MASTER";
    parameter SRVAL_OQ = 1'b0;
    parameter SRVAL_TQ = 1'b0;
    parameter integer TRISTATE_WIDTH = 4;


//-------------------------------------------------------------
//   Outputs:
//-------------------------------------------------------------
//      OQ: Data output
//      TQ: Output of tristate mux
//      SHIFTOUT1: Carry out data 1 for slave
//      SHIFTOUT2: Carry out data 2 for slave
//      OFB: O Feedback output
//      TFB: T Feedback output
//       

//
//-------------------------------------------------------------
//   Inputs:
//-------------------------------------------------------------
//
//   Inputs:
//      CLK:  High speed clock from DCM
//      CLKB: Inverted High speed clock from DCM
//      CLKDIV: Low speed divided clock from DCM
//      CLKPERF: Performance Path clock 
//      CLKPERFDELAY: delayed Performance Path clock
//      D1, D2, D3, D4, D5, D6 : Data inputs
//      OCE: Clock enable for output data flops
//      ODV: ODELAY value > 140 degrees
//      RST: Reset control
//      T1, T2, T3, T4: tristate inputs
//      SHIFTIN1: Carry in data 1 for master from slave
//      SHIFTIN2: Carry in data 2 for master from slave
//      TCE: Tristate clock enable
//      WC: Write command given by memory controller

    output OCBEXTEND;
    output OFB;
    output OQ;
    output SHIFTOUT1;
    output SHIFTOUT2;
    output TFB;
    output TQ;

    input CLK;
    input CLKDIV;
    input CLKPERF;
    input CLKPERFDELAY;
    input D1;
    input D2;
    input D3;
    input D4;
    input D5;
    input D6;
    input OCE;
    input ODV;
    input RST;
    input SHIFTIN1;
    input SHIFTIN2;
    input T1;
    input T2;
    input T3;
    input T4;
    input TCE;
    input WC;


//
    wire SERDES, DDR_CLK_EDGE;
    wire    [5:0]   SRTYPE;
    wire            WC_DELAY;
    wire    [4:0]   SELFHEAL;
   
    
    wire            load;
    wire            qmux1, qmux, tmux1, tmux2;
    wire            data1, data2, triin1, triin2;
    wire            d2rnk2;
    wire            CLKD;
    wire            CLKDIVD;
    wire            iodelay_state;

// attribute
    reg data_rate_int; 
    reg [3:0] data_width_int;
    reg [1:0] tristate_width_int;
    reg data_rate_oq_int;
    reg [1:0] data_rate_tq_int;
    reg ddr3_data_int;
    reg interface_type_int;
    reg odelay_used_int;
    reg serdes_mode_int;

// Output signals
    wire ioclkglitch_out, ocbextend_out, ofb_out, oq_out, tq_out, shiftout1_out, shiftout2_out;

// Other signals
    tri0  GSR = glbl.GSR;

    

    wire CLK_in;
    wire CLKDIV_in;
    wire CLKPERF_in;
    wire CLKPERFDELAY_in;
    wire D1_in;
    wire D2_in;
    wire D3_in;
    wire D4_in;
    wire D5_in;
    wire D6_in;
    wire OCE_in;
    wire ODV_in;
    wire RST_in;
    wire SHIFTIN1_in;
    wire SHIFTIN2_in;
    wire T1_in;
    wire T2_in;
    wire T3_in;
    wire T4_in;
    wire TCE_in;
    wire WC_in;



    assign CLK_in = CLK;
    assign CLKDIV_in = CLKDIV;
    assign D1_in = D1;
    assign D2_in = D2;
    assign D3_in = D3;
    assign D4_in = D4;
    assign D5_in = D5;
    assign D6_in = D6;
    assign OCE_in = OCE;
    assign T1_in = T1;
    assign T2_in = T2;
    assign T3_in = T3;
    assign T4_in = T4;
    assign TCE_in = TCE;
    assign WC_in = WC;


    assign CLKPERF_in = CLKPERF;
//  assign CLKPERFDELAY_in = CLKPERFDELAY;
// IR 495397 & IR 499954 
//    assign CLKPERFDELAY_in = (CLKPERFDELAY === 1'bx)? 1'b0 : CLKPERFDELAY; 
    generate
       case (ODELAY_USED)
          0: assign CLKPERFDELAY_in = CLKPERF; 
          1: assign CLKPERFDELAY_in = (CLKPERFDELAY === 1'bx)? 1'b0 : CLKPERFDELAY;
       endcase
    endgenerate

    assign SHIFTIN1_in = SHIFTIN1;
    assign SHIFTIN2_in = SHIFTIN2;
    assign ODV_in = ODV;
    assign RST_in = RST;


    initial begin

//-------------------------------------------------
//----- DATA_RATE_OQ check
//-------------------------------------------------
        case (DATA_RATE_OQ)
            "SDR" : data_rate_oq_int <= 1'b1;
            "DDR" : data_rate_oq_int <= 1'b0;
            default : begin
                          $display("Attribute Syntax Error : The attribute DATA_RATE_OQ on OSERDESE1 instance %m is set to %s.  Legal values for this attribute are SDR or DDR", DATA_RATE_OQ);
                          $finish;
                      end
        endcase // case(DATA_RATE_OQ)

//-------------------------------------------------
//----- DATA_RATE_TQ check
//-------------------------------------------------
       case (DATA_RATE_TQ)

            "BUF" : data_rate_tq_int <= 2'b00;
            "SDR" : data_rate_tq_int <= 2'b01;
            "DDR" : data_rate_tq_int <= 2'b10;
            default : begin
                          $display("Attribute Syntax Error : The attribute DATA_RATE_TQ on OSERDESE1 instance %m is set to %s.  Legal values for this attribute are BUF, SDR or DDR", DATA_RATE_TQ);
                          $finish;
                      end

        endcase // case(DATA_RATE_TQ)

//-------------------------------------------------
//----- DATA_WIDTH check
//-------------------------------------------------
        case (DATA_WIDTH)

            2, 3, 4, 5, 6, 7, 8, 10 : data_width_int = DATA_WIDTH;
            default : begin
                          $display("Attribute Syntax Error : The attribute DATA_WIDTH on OSERDESE1 instance %m is set to %d.  Legal values for this attribute are 2, 3, 4, 5, 6, 7, 8, or 10", DATA_WIDTH);
                          $finish;
                      end
        endcase // case(DATA_WIDTH)

//-------------------------------------------------
//----- DDR3_DATA check
//-------------------------------------------------
        case (DDR3_DATA)
            0 : ddr3_data_int <= 1'b0;
            1 : ddr3_data_int <= 1'b1;
            default : begin 
                          $display("Attribute Syntax Error : The attribute DDR3_DATA on OSERDESE1 instance %m is set to %d.  Legal values for this attribute are 0 or 1", DDR3_DATA);
                          $finish;
                      end
        endcase // case(DDR3_DATA)

//-------------------------------------------------
//----- INTERFACE_TYPE check
//-------------------------------------------------
        case (INTERFACE_TYPE)
               "DEFAULT" : interface_type_int <= 1'b0;
               "MEMORY_DDR3" : interface_type_int <= 1'b1;
               default : begin
                          $display("Attribute Syntax Error : The attribute INTERFACE_TYPE on OSERDESE1 instance %m is set to %s.  Legal values for this attribute are DEFAULT, or MEMORY_DDR3", INTERFACE_TYPE);
                          $finish;
                         end
        endcase // INTERFACE_TYPE

                          
//-------------------------------------------------
//----- ODELAY_USED check
//-------------------------------------------------
        case (ODELAY_USED)

//            "FALSE" : odelay_used_int <= 1'b0;
//            "TRUE"  : odelay_used_int <= 1'b1;
            0 : odelay_used_int <= 1'b0;
            1 : odelay_used_int <= 1'b1;
            default : begin
                          $display("Attribute Syntax Error : The attribute ODELAY_USED on OSERDESE1 instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE", ODELAY_USED);
                          $finish;
                      end

        endcase // case(ODELAY_USED)

//-------------------------------------------------
//----- SERDES_MODE check
//-------------------------------------------------
        case (SERDES_MODE)

            "MASTER" : serdes_mode_int <= 1'b0;
            "SLAVE"  : serdes_mode_int <= 1'b1;
            default  : begin
                          $display("Attribute Syntax Error : The attribute SERDES_MODE on OSERDESE1 instance %m is set to %s.  Legal values for this attribute are MASTER or SLAVE", SERDES_MODE);
                          $finish;
                      end

        endcase // case(SERDES_MODE)

//-------------------------------------------------
//----- TRISTATE_WIDTH check
//-------------------------------------------------
        case (TRISTATE_WIDTH)

            1 : tristate_width_int <= 2'b00;
            2 : tristate_width_int <= 2'b01;
            4 : tristate_width_int <= 2'b10;
            default : begin
                          $display("Attribute Syntax Error : The attribute TRISTATE_WIDTH on OSERDESE1 instance %m is set to %d.  Legal values for this attribute are 1, 2 or 4", TRISTATE_WIDTH);
                          $finish;
                      end

        endcase // case(TRISTATE_WIDTH)

//-------------------------------------------------
    end  // initial begin

//-------------------------------------------------

    assign SERDES = 1'b1;
    assign SRTYPE = 6'b111111;
    assign DDR_CLK_EDGE = 1'b1;
    assign WC_DELAY = 1'b0;
    assign SELFHEAL = 5'b00000;

    assign #0 CLKD = CLK;
    assign #0 CLKDIVD = CLKDIV;


    assign #10 ofb_out = (ODELAY_USED == 1)? CLKPERF : oq_out;
    assign #10 tfb_out = iodelay_state;


/////////////////////////////////////////////////////////
//
//  Delay assignments
//
/////////////////////////////////////////////////////////

// Data output delays
defparam        dfront.FFD = 1; // clock to out delay for flip flops
//                                driven by clk
defparam        datao.FFD = 1; // clock to out delay for flip flops
//                                driven by clk
defparam        dfront.FFCD = 1; // clock to out delay for flip flops
//                                driven by clkdiv
defparam        dfront.MXD = 1; // mux delay

defparam        dfront.MXR1 = 1; // mux before 2nd rank of flops

// Programmable load generator
defparam dfront.ldgen.ffdcnt = 1;
defparam dfront.ldgen.mxdcnt = 1;
defparam dfront.ldgen.FFRST = 145; // clock to out delay for flop in PLSG

// Tristate output delays
defparam        tfront.ffd = 1; // clock to out delay for flip flops
defparam        tfront.mxd = 1; // mux delay

defparam        trio.ffd = 1; // clock to out delay for flip flops
defparam        trio.mxd = 1; // mux delay

//------------------------------------------------------------------
// Instantiate output data section
//------------------------------------------------------------------

rank12d_oserdese1_vlog dfront (.D1(D1_in), .D2(D2_in), .D3(D3_in), .D4(D4_in), .D5(D5_in), .D6(D6_in),
                .d2rnk2(d2rnk2),
                .SHIFTIN1(SHIFTIN1_in), .SHIFTIN2(SHIFTIN2_in),
                .C(CLK_in), .CLKDIV(CLKDIV_in), .SR(RST_in), .OCE(OCE_in),
                .data1(data1), .data2(data2), .SHIFTOUT1(shiftout1_out), .SHIFTOUT2(shiftout2_out),
                .DATA_RATE_OQ(data_rate_oq_int), .DATA_WIDTH(data_width_int),
                .SERDES_MODE(serdes_mode_int), .load(load),
                .IOCLK_GLITCH(ioclkglitch_out),
                .INIT_OQ(INIT_OQ), .SRVAL_OQ(SRVAL_OQ));


trif_oserdese1_vlog tfront (.T1(T1_in), .T2(T2_in), .T3(T3_in), .T4(T4_in), .load(load),
                .C(CLK_in), .CLKDIV(CLKDIV_in), .SR(RST_in), .TCE(TCE_in),
                .DATA_RATE_TQ(data_rate_tq_int), .TRISTATE_WIDTH(tristate_width_int),
                .INIT_TQ(INIT_TQ), .SRVAL_TQ(SRVAL_TQ),
                .data1(triin1), .data2(triin2));


txbuffer_oserdese1_vlog DDR3FIFO (.iodelay_state(iodelay_state), .qmux1(qmux1), .qmux2(qmux2), .tmux1(tmux1), .tmux2(tmux2),
                 .d1(data1), .d2(data2), .t1(triin1), .t2(triin2), .trif(tq_out),
                 .WC(WC_in), .ODV(ODV_in), .extra(ocbextend_out),
                 .clk(CLK_in), .clkdiv(CLKDIV_in), .bufo(CLKPERFDELAY_in), .bufop(CLKPERF_in), .rst(RST_in),
                 .ODELAY_USED(odelay_used_int), .DDR3_DATA(ddr3_data_int),
                 .DDR3_MODE(interface_type_int));

dout_oserdese1_vlog datao (.data1(qmux1), .data2(qmux2),
                .CLK(CLK_in), .BUFO(CLKPERFDELAY_in), .SR(RST_in), .OCE(OCE_in),
                .OQ(oq_out), .d2rnk2(d2rnk2),
                .DATA_RATE_OQ(data_rate_oq_int),
                .INIT_OQ(INIT_OQ), .SRVAL_OQ(SRVAL_OQ),
                .DDR3_MODE(interface_type_int));

tout_oserdese1_vlog trio (.data1(tmux1), .data2(tmux2),
                .CLK(CLK_in), .BUFO(CLKPERFDELAY_in), .SR(RST_in), .TCE(TCE_in),
                .DATA_RATE_TQ(data_rate_tq_int), .TRISTATE_WIDTH(tristate_width_int),
                .INIT_TQ(INIT_TQ), .SRVAL_TQ(SRVAL_TQ),
                .TQ(tq_out), .DDR3_MODE(interface_type_int));

      assign OCBEXTEND   = ocbextend_out;
      assign OFB         = ofb_out;
      assign OQ          = oq_out;
      assign SHIFTOUT1   = shiftout1_out;
      assign SHIFTOUT2   = shiftout2_out;
      assign TFB         = tfb_out;
      assign TQ          = tq_out;

    specify
        ( CLK => OQ)          = (100, 100);
        ( CLK => TQ)          = (100, 100);
        ( CLKPERF => OQ)      = (100, 100);
        ( CLKPERF => TQ)      = (100, 100);
        ( CLKPERFDELAY => OQ) = (100, 100);
        ( CLKPERFDELAY => TQ) = (100, 100);
        ( T1 => TQ) = (0, 0);

        specparam PATHPULSE$ = 0;

    endspecify

endmodule // OSERDESE1

`timescale 1ps/1ps
/////////////////////////////////////////////////////////
//
//       module selfheal_oserdese1_vlog
//
///////////////////////////////////////////////////////
//
// Self healing circuit  for Mt Blanc
//	This model ONLY works for SERDES operation!!
//	
//
//
////////////////////////////////////////////////////////
//
//
//
/////////////////////////////////////////////////////////
//
//   Inputs: 
//	dq3 - dq0: Data from load counter
//	CLKDIV: Divided clock from PLL
//	srint: RESET from load generator
//	rst: Set/Reset control
//				
//
//
//   Outputs:	
//	SHO: Data output
//
//
//
//   Programmable Points
//	SELFHEAL: String of 5 bits.  1 as enable and 4 as compare
//		  Test attributes in model
//	
//
//
//
//
////////////////////////////////////////////////////////////////////////////////
//

module selfheal_oserdese1_vlog (dq3, dq2, dq1, dq0,
		CLKDIV, srint, rst,
                SHO);

input		dq3, dq2, dq1, dq0;

input		CLKDIV, srint, rst;

output		SHO;


reg		shr;

reg		SHO;


wire		clkint;

wire error;

wire rst_in, rst_self_heal;


// Programmable Points

wire    [4:0]   SELFHEAL;
assign SELFHEAL = 5'b00000;



//////////////////////////////////////////////////
// Delay values
//
parameter     	FFD = 10; // clock to out delay for flip flops
//                            driven by clk
parameter	FFCD = 10; // clock to out delay for flip flops
//                               driven by clkdiv
parameter	MXD = 10; // 60 ps mux delay

parameter	MXR1 = 10;



/////////////////////////////////////////


assign	clkint = CLKDIV & SELFHEAL[4];

assign error = (((~SELFHEAL[4] ^ SELFHEAL[3]) ^  dq3) | ((~SELFHEAL[4] ^ SELFHEAL[2]) ^  dq2) | ((~SELFHEAL[4] ^ SELFHEAL[1]) ^  dq1) | ((~SELFHEAL[4] ^ SELFHEAL[0]) ^  dq0));

assign rst_in = (~SELFHEAL[4] | ~srint);

assign rst_self_heal = (rst | ~shr);

/////////////////////////////////////////
// Reset Flop
////////////////////////////////////////

always @ (posedge clkint or posedge rst)
begin
	begin
	if (rst)
		begin
			shr <= # FFD 1'b0;
		end
        else begin
		shr <= #FFD rst_in;
 	end
	end
end

// Self heal flop
always @ (posedge clkint or posedge rst_self_heal)
begin
	begin

	if (rst_self_heal)
		begin
			SHO <= 1'b0;
		end
	else 
		begin
			SHO <= # FFD error;
		end
	end
end




endmodule
`timescale 1ps/1ps
////////////////////////////////////////////////////////
//
//       module plg_oserdese1_vlog
//
////////////////////////////////////////////////////////
//
// Programmable Load Generator (PLG)
// 	Divide by 2-8 counter with load enable output
//
//
/////////////////////////////////////////////////////////
//
//   Inputs:	
//		c23: Selects between divide by 2 or 3
//		c45: Selects between divide by 4 or 5
//		c67: Selects between divide by 6 or 7
//		sel: Selects which divide function is chosen
//			00:2 or 3, 01:4 or 5, 10:6 or 7, 11:8
//		clk: High speed clock from DCM
//		clkdiv: Low speed clock from DCM
//		rst: Reset
//				
//
//
//   Outputs:	
//	
//		load: Loads serdes register at terminal count
//
//
//   Test attributes:
//	INIT_LOADCNT: 4-bits to init counter
//	      SRTYPE: 1-bit to control synchronous or asynchronous operation
//	    SELFHEAL: 5-bits to control self healing feature
//
//
//
////////////////////////////////////////////////////////////////////////////////
//

module plg_oserdese1_vlog (c23, c45, c67, sel, 
			clk, clkdiv, rst,
		load, IOCLK_GLITCH);

input		 c23, c45, c67;

input	[1:0]	sel;

input		clk, clkdiv, rst;

output		load;

output		IOCLK_GLITCH;

wire		SRTYPE;
wire	[3:0]	INIT_LOADCNT;
wire	[4:0]	SELFHEAL;
assign SRTYPE = 1'b1;
assign INIT_LOADCNT = 4'b0000;
assign SELFHEAL = 5'b00000;

reg		q0, q1, q2, q3;

reg		qhr, qlr;

reg		load, mux;

wire		cntrrst;


assign cntrrst = IOCLK_GLITCH | rst;



// Parameters for gate delays
parameter ffdcnt = 1;
parameter mxdcnt = 1;
parameter FFRST = 145; // clock to out delay for flop in PLSG



//////////////////////////////////////////////////

tri0 GSR = glbl.GSR;

always @(GSR)
begin
	if (GSR) 
		begin
			assign q3 = INIT_LOADCNT[3];
			assign q2 = INIT_LOADCNT[2];
			assign q1 = INIT_LOADCNT[1];
			assign q0 = INIT_LOADCNT[0];
		end
	else 
		begin
			deassign q3;
			deassign q2;
			deassign q1;
			deassign q0;
		end
end







// flops for counter
// asynchronous reset
always @ (posedge qhr or posedge clk)
begin
	if (qhr & !SRTYPE)
		begin
			q0 <= # ffdcnt 1'b0;
			q1 <= # ffdcnt 1'b0;
			q2 <= # ffdcnt 1'b0;
			q3 <= # ffdcnt 1'b0;
		end
	else if (!SRTYPE)
		begin
			q3 <= # ffdcnt q2;
			q2 <= # ffdcnt (!(!q0 & !q2) & q1);
			q1 <= # ffdcnt q0;
			q0 <= # ffdcnt mux;
		end
end
// synchronous reset
always @ (posedge clk)
begin
	if (qhr & SRTYPE)
		begin
			q0 <= # ffdcnt 1'b0;
			q1 <= # ffdcnt 1'b0;
			q2 <= # ffdcnt 1'b0;
			q3 <= # ffdcnt 1'b0;
		end
	else if (SRTYPE)
		begin
			q3 <= # ffdcnt q2;
			q2 <= # ffdcnt (!(!q0 & !q2) & q1);
			q1 <= # ffdcnt q0;
			q0 <= # ffdcnt mux;
		end
end


// mux settings for counter
always @ (sel or c23 or c45 or c67 or q0 or q1 or q2 or q3)
	begin
		case (sel)
		2'b00: mux <= # mxdcnt (!q0 & !(c23 & q1));
		2'b01: mux <= # mxdcnt (!q1 & !(c45 & q2));
		2'b10: mux <= # mxdcnt (!q2 & !(c67 & q3));
		2'b11: mux <= # mxdcnt !q3;
		default: mux <= # mxdcnt 1'b0;
		endcase
	end


// mux decoding for load signal
always @ (sel or c23 or c45 or c67 or q0 or q1 or q2 or q3)
	begin
		case (sel)
		2'b00: load <= # mxdcnt q0;
		2'b01: load <= # mxdcnt q0 & q1;
		2'b10: load <= # mxdcnt q0 & q2;
		2'b11: load <= # mxdcnt q0 & q3;
		default: load <= # mxdcnt 1'b0;
		endcase
	end

// flops to reset counter

// Low speed flop
// asynchronous reset
always @ (posedge cntrrst or posedge clkdiv)
	begin
	if (cntrrst & !SRTYPE)
		begin
			qlr <= # FFRST 1'b1;
		end
	else if (!SRTYPE)
		begin
			qlr <= # FFRST 1'b0;
		end
	end
// synchronous reset
always @ (posedge clkdiv)
	begin
	if (cntrrst & SRTYPE)
		begin
			qlr <= # FFRST 1'b1;
		end
	else if (SRTYPE)
		begin
			qlr <= # FFRST 1'b0;
		end
	end



// High speed flop
// asynchronous reset
always @ (posedge cntrrst or posedge clk)
	begin
	if (cntrrst & !SRTYPE)
		begin
			qhr <= # ffdcnt 1'b1;
		end
	else if (!SRTYPE)
		begin
			qhr <= # ffdcnt qlr;
		end
	end
// synchronous reset
always @ (posedge clk)
	begin
	if (cntrrst & SRTYPE)
		begin
			qhr <= # ffdcnt 1'b1;
		end
	else if (SRTYPE)
		begin
			qhr <= # ffdcnt qlr;
		end
	end

selfheal_oserdese1_vlog fixcntr (.dq3(q3), .dq2(q2), .dq1(q1), .dq0(q0),
		.CLKDIV(clkdiv), .srint(qlr), .rst(rst),
		.SHO(IOCLK_GLITCH));
endmodule
`timescale 1ps/1ps
////////////////////////////////////////////////////////
//
//       module rank12d_oserdese1_vlog
//
//
//	This model ONLY works for SERDES operation!!
//	Does not include tristate circuit
//
//
////////////////////////////////////////////////////////
//
//   Inputs: 
//	D1: Data input 1
//	D2: Data input 2
//	D3: Data input 3
//	D4: Data input 4
//	D5: Data input 5
//	D6: Data input 6
//	C: High speed clock from DCM
//	OCE: Clock enable for output data flops
//	SR: Set/Reset control.  For the last 3 flops in OQ
//	     (d1rnk2, d2rnk2 and d2nrnk2) this function is 
//	     controlled bythe attributes SRVAL_OQ.  In SERDES mode,
//	     SR is a RESET ONLY for all other flops!  The flops will
//	     still be RESET even if SR is programmed to a SET!
//	CLKDIV: Low speed divided clock from DCM
//	SHIFTIN1: Carry in data 1 for master from slave
//	SHIFTIN2: Carry in data 2 for master from slave
//				
//
//
//   Outputs:	
//	data1: Data output mux for top flop
//	data2: Data output mux for bottom flop
//	SHIFTOUT1: Carry out data 1 for slave
//	SHIFTOUT2: Carry out data 2 for slave
//	load: Used for the tristate when combined into a single model
//
//
//
//   Programmable Points
//	DATA_RATE_OQ: Rate control for data output, 1-bit
//			sdr (1), ddr (0)
//	DATA_WIDTH: Input data width, 
//		4-bits, values can be from 2 to 10
//	SERDES_MODE: Denotes master (0) or slave (1)
//	SIM_X_INPUT: This attribute is NOT SUPPORTED in this model!!!
//	
//
//
//  Programmable points for Test model
//	SRTYPE: This is a 4-bit field  Sets asynchronous (0) or synchronous (1) set/reset
//		1st bit (msb) sets rank1 flops, 2nd bit sets 4 flops in rank 2,
//		3rd bit sets "3 legacy flops, and 4th (lsb) bit sets the counter
//	INIT_ORANK1: Init value for 6 registers in 1st rank (6-bits)
//	INIT_ORANK2_PARTIAL: Init value for bottom 4 registers in the 2nd rank (4-bits)
//	INIT_LOADCNT: Init value for the load counter (4-bits)
//		The other 2 registers in the load counter have init bits, but are
//		not supported in this model
//	SERDES: Indicates that SERDES mode is chosen
//	SLEFHEAL: 5-bit to set self heal circuit
//
//
////////////////////////////////////////////////////////////////////////////////
//

module rank12d_oserdese1_vlog (D1, D2, D3, D4, D5, D6, d2rnk2,
		SHIFTIN1, SHIFTIN2,
		C, CLKDIV, SR, OCE,
		data1, data2, SHIFTOUT1, SHIFTOUT2,
		DATA_RATE_OQ, DATA_WIDTH, 
		SERDES_MODE, load,
		IOCLK_GLITCH,
		INIT_OQ, SRVAL_OQ);

input		D1, D2, D3, D4, D5, D6;

input		d2rnk2;

input		SHIFTIN1, SHIFTIN2;

input		C, CLKDIV, SR, OCE;

input		INIT_OQ, SRVAL_OQ;

output		data1, data2; 

output		SHIFTOUT1, SHIFTOUT2;

output		load;

output		IOCLK_GLITCH;

// Programmable Points

input		DATA_RATE_OQ;

input	[3:0]	DATA_WIDTH;

input		SERDES_MODE;

wire		DDR_CLK_EDGE, SERDES;
wire	[3:0]	SRTYPE;
wire	[4:0]	SELFHEAL;

wire	[3:0]	INIT_ORANK2_PARTIAL;
wire 	[5:0]	INIT_ORANK1;

assign DDR_CLK_EDGE = 1'b1;
assign SERDES = 1'b1;
assign SRTYPE = 4'b1111;
assign SELFHEAL = 5'b00000;

assign INIT_ORANK2_PARTIAL = 4'b0000;
assign INIT_ORANK1 = 6'b000000;

reg		d1r, d2r, d3r, d4r, d5r, d6r;

reg		d3rnk2, d4rnk2, d5rnk2, d6rnk2;

reg		data1, data2, data3, data4, data5, data6;

reg		ddr_data, odata_edge, sdata_edge;

reg		c23, c45, c67;

reg	[1:0]	sel;

wire		C2p, C3;

wire		loadint;

wire	[3:0]	seloq;

wire		oqsr, oqrev;

wire	[2:0]	sel1_4;

wire	[3:0]	sel5_6;

wire	[4:0]	plgcnt;

assign C2p = (C & DDR_CLK_EDGE) | (!C & !DDR_CLK_EDGE);

assign C3 = !C2p;

assign plgcnt = {DATA_RATE_OQ,DATA_WIDTH};

assign sel1_4 = {SERDES,loadint,DATA_RATE_OQ};
	       
assign sel5_6 = {SERDES,SERDES_MODE,loadint,DATA_RATE_OQ};

assign load = loadint;

assign seloq = {OCE,DATA_RATE_OQ,oqsr,oqrev};

assign oqsr =  !SRTYPE[1] & SR & !SRVAL_OQ;

assign oqrev = !SRTYPE[1] & SR & SRVAL_OQ;



//////////////////////////////////////////////////
// Delay values
//
parameter     	FFD = 1; // clock to out delay for flip flops
//                            driven by clk
parameter	FFCD = 1; // clock to out delay for flip flops
//                               driven by clkdiv
parameter	MXD = 1; // 60 ps mux delay

parameter	MXR1 = 1;

////////////////////////////////////////////
// Initialization of flops with GSR for test model
///////////////////////////////////////////

tri0 GSR = glbl.GSR;

always @(GSR)
begin
	if (GSR) 
		begin
			assign d6rnk2 = INIT_ORANK2_PARTIAL[3];
			assign d5rnk2 = INIT_ORANK2_PARTIAL[2];
			assign d4rnk2 = INIT_ORANK2_PARTIAL[1];
			assign d3rnk2 = INIT_ORANK2_PARTIAL[0];

			assign d6r = INIT_ORANK1[5];
			assign d5r = INIT_ORANK1[4];
			assign d4r = INIT_ORANK1[3];
			assign d3r = INIT_ORANK1[2];
			assign d2r = INIT_ORANK1[1];
			assign d1r = INIT_ORANK1[0];
		end
	else 
		begin
			deassign d6rnk2;
			deassign d5rnk2;
			deassign d4rnk2;
			deassign d3rnk2;
			deassign d6r;
			deassign d5r;
			deassign d4r;
			deassign d3r;
			deassign d2r;
			deassign d1r;
		end
end

/////////////////////////////////////////



// Assign shiftout1 and shiftout2

assign SHIFTOUT1 = d3rnk2 & SERDES_MODE;

assign SHIFTOUT2 = d4rnk2 & SERDES_MODE;






// last 4 flops which only have reset and init
// asynchronous operation
always @ (posedge C or posedge SR)
begin
	begin
	if (SR & !SRTYPE[2])
		begin
			d3rnk2 <= # FFD 1'b0;
			d4rnk2 <= # FFD 1'b0;
			d5rnk2 <= # FFD 1'b0;
			d6rnk2 <= # FFD 1'b0;
		end	  
	else if (!SRTYPE[2])
		begin
			d3rnk2 <= # FFD data3;
			d4rnk2 <= # FFD data4;
			d5rnk2 <= # FFD data5;
			d6rnk2 <= # FFD data6;

		end
	end
end
// synchronous operation
always @ (posedge C)
begin
	begin
	if (SR & SRTYPE[2])
		begin
			d3rnk2 <= # FFD 1'b0;
			d4rnk2 <= # FFD 1'b0;
			d5rnk2 <= # FFD 1'b0;
			d6rnk2 <= # FFD 1'b0;
		end	  
	else if (SRTYPE[2])
		begin
			d3rnk2 <= # FFD data3;
			d4rnk2 <= # FFD data4;
			d5rnk2 <= # FFD data5;
			d6rnk2 <= # FFD data6;

		end
	end
end







///////////////////////////////////////////////////
// First rank of flops for input data
//////////////////////////////////////////////////

// asynchronous operation
always @ (posedge CLKDIV or posedge SR)
begin
	begin
	if (SR & !SRTYPE[3])
		begin
			d1r <= # FFCD 1'b0;
			d2r <= # FFCD 1'b0;
			d3r <= # FFCD 1'b0;
			d4r <= # FFCD 1'b0;
			d5r <= # FFCD 1'b0;
			d6r <= # FFCD 1'b0;
		end
	else if (!SRTYPE[3])
		begin
			d1r <= # FFCD D1;
			d2r <= # FFCD D2;
			d3r <= # FFCD D3;
			d4r <= # FFCD D4;
			d5r <= # FFCD D5;
			d6r <= # FFCD D6;

		end
	end
end
// synchronous operation
always @ (posedge CLKDIV)
begin
	begin
	if (SR & SRTYPE[3])
		begin
			d1r <= # FFCD 1'b0;
			d2r <= # FFCD 1'b0;
			d3r <= # FFCD 1'b0;
			d4r <= # FFCD 1'b0;
			d5r <= # FFCD 1'b0;
			d6r <= # FFCD 1'b0;
		end
	else if (SRTYPE[3])
		begin
			d1r <= # FFCD D1;
			d2r <= # FFCD D2;
			d3r <= # FFCD D3;
			d4r <= # FFCD D4;
			d5r <= # FFCD D5;
			d6r <= # FFCD D6;

		end
	end
end

// Muxs for 2nd rank of flops
always @ (sel1_4 or d1r or d2rnk2 or d3rnk2)
	begin

		casex (sel1_4)
		3'b100: data1 <= # MXR1 d3rnk2;
		3'b110: data1 <= # MXR1 d1r;
		3'b101: data1 <= # MXR1 d2rnk2;
		3'b111: data1 <= # MXR1 d1r;
		default: data1 <= # MXR1 d3rnk2;
		endcase
	end	      
		      
always @ (sel1_4 or d2r or d3rnk2 or d4rnk2)
	begin	      
		casex (sel1_4)
		3'b100: data2 <= # MXR1 d4rnk2;
		3'b110: data2 <= # MXR1 d2r;
		3'b101: data2 <= # MXR1 d3rnk2;
		3'b111: data2 <= # MXR1 d2r;
		default:  data2 <= # MXR1 d4rnk2;
		endcase
	end

//Note: To stop data rate of 00 from being illegal, register data is fed to mux
always @ (sel1_4 or d3r or d4rnk2 or d5rnk2)
	begin
		casex (sel1_4)
		3'b100: data3 <= # MXR1 d5rnk2;
		3'b110: data3 <= # MXR1 d3r;
		3'b101: data3 <= # MXR1 d4rnk2;
		3'b111: data3 <= # MXR1 d3r;
		default: data3 <= # MXR1 d5rnk2;
		endcase
	end

always @ (sel1_4 or d4r or d5rnk2 or d6rnk2)
	begin
		casex (sel1_4)
		3'b100: data4 <= # MXR1 d6rnk2;
		3'b110: data4 <= # MXR1 d4r;
		3'b101: data4 <= # MXR1 d5rnk2;
		3'b111: data4 <= # MXR1 d4r;
		default:  data4 <= # MXR1 d6rnk2;
		endcase
	end

always @ (sel5_6 or d5r or d6rnk2 or SHIFTIN1)
	begin
		casex (sel5_6)
		4'b1000: data5 <= # MXR1 SHIFTIN1;
		4'b1010: data5 <= # MXR1 d5r;
		4'b1001: data5 <= # MXR1 d6rnk2;
		4'b1011: data5 <= # MXR1 d5r;
		4'b1100: data5 <= # MXR1 1'b0;
		4'b1110: data5 <= # MXR1 d5r;
		4'b1101: data5 <= # MXR1 d6rnk2;
		4'b1111: data5 <= # MXR1 d5r;
		default: data5 <= # MXR1 SHIFTIN1;
		endcase
	end

always @ (sel5_6 or D6 or d6r or SHIFTIN1 or SHIFTIN2)
	begin
		casex (sel5_6)
		4'b1000: data6 <= # MXR1 SHIFTIN2;
		4'b1010: data6 <= # MXR1 d6r;
		4'b1001: data6 <= # MXR1 SHIFTIN1;
		4'b1011: data6 <= # MXR1 d6r;
		4'b1100: data6 <= # MXR1 1'b0;
		4'b1110: data6 <= # MXR1 d6r;
		4'b1101: data6 <= # MXR1 1'b0;
		4'b1111: data6 <= # MXR1 d6r;
		default: data6 <= # MXR1 SHIFTIN2;
		endcase
	end




// instantiate programmable load generator
plg_oserdese1_vlog ldgen (.c23(c23), .c45(c45), .c67(c67), .sel(sel), 
			.clk(C), .clkdiv(CLKDIV), .rst(SR),
		.load(loadint), .IOCLK_GLITCH(IOCLK_GLITCH));

// Set value of counter in programmable load generator
always @ (plgcnt or c23 or c45 or c67 or sel)
begin
	casex (plgcnt)
	5'b00100: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b00; end
	5'b00110: begin c23=1'b1; c45=1'b0; c67=1'b0; sel=2'b00; end
	5'b01000: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b01; end
	5'b01010: begin c23=1'b0; c45=1'b1; c67=1'b0; sel=2'b01; end
	5'b10010: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b00; end
	5'b10011: begin c23=1'b1; c45=1'b0; c67=1'b0; sel=2'b00; end
	5'b10100: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b01; end
	5'b10101: begin c23=1'b0; c45=1'b1; c67=1'b0; sel=2'b01; end
	5'b10110: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b10; end
	5'b10111: begin c23=1'b0; c45=1'b0; c67=1'b1; sel=2'b10; end
	5'b11000: begin c23=1'b0; c45=1'b0; c67=1'b0; sel=2'b11; end
	default: $display("DATA_WIDTH %b and DATA_RATE_OQ %b at %t is an illegal value", DATA_WIDTH, DATA_RATE_OQ, $time);
	endcase
end

endmodule
`timescale 1ps/1ps
//////////////////////////////////////////////////////////
//
//       module trif_oserdese1_vlog
//
/////////////////////////////////////////////////////////
//
//   Inputs:
//	
//	T1, T2, T3, T4: tristate inputs
//	load: Programmable load generator output
//	TCE: Tristate clock enable
//	SR: Set/Reset control.  For the last 3 flops in TQ
//	     (qt1, qt2 and qt2n) this function is 
//	     controlled bythe attributes SRVAL_TQ.  In SERDES mode,
//	     SR is a RESET ONLY for all other flops!  The flops will
//	     still be RESET even if SR is programmed to a SET!
//	C, C2: High speed clocks
//	C2 drives 2nd latch and C3 (inverse of C2) drives 
//			3rd latch in output section
//	CLKDIV: Low speed clock
//
//				
//
//
//   Outputs:
//
//	TQ: Output of tristate mux
//
//
//   Programmable Options:
//
//	DATA_RATE_TQ: 2-bit field for types of operaiton
//		0 (buf from T1), 1 (registered output from T1), 2 (ddr)
//	TRISTATE_WIDTH: 2-bit field for input width
//		0 (width 1), 1 (width 2), 2 (width 4)
//	INIT_TQ: Init TQ output (0,1)
//	SRVAL_TQ: This bit to controls value of SR input.
//		    Only the last 3 flops (qt1, qt2 and qt2n) are 
//		    affected by this bit.For SERDES mode, this bit 
//		    should be set to '0' making SR a reset.  This is the 
//		    desired state since all other flops only
//		    respond to this pin as a reset.  Their function 
//		    cannot be changed.  SR is 'O' for SET and '1' for RESET.
//
//
//  Programmable Test Options:
//	SRTYPE: Control S and R as asynchronous (0) or synchronous (1)
//		2-bit value.  1st bit (msb) controls the 4 input flops
//		and the 2nd bit (lsb) controls the "3 legacy flops"
//	DDR_CLK_EDGE: Same or opposite edge operation
//		  
//
//
////////////////////////////////////////////////////////////////////////////////
//

module trif_oserdese1_vlog (T1, T2, T3, T4, load, 
		C, CLKDIV, SR, TCE, 
		DATA_RATE_TQ, TRISTATE_WIDTH, 
		INIT_TQ, SRVAL_TQ, 
		data1, data2);

input		T1, T2, T3, T4, load;

input		C, CLKDIV, SR, TCE;

input	[1:0]	TRISTATE_WIDTH;

input	[1:0]	DATA_RATE_TQ;

input		INIT_TQ, SRVAL_TQ;

output		data1, data2;

wire		DDR_CLK_EDGE;
wire	[3:0]	INIT_TRANK1;
wire	[1:0]	SRTYPE;
assign SRTYPE = 2'b11;
assign DDR_CLK_EDGE = 1'b1;
assign INIT_TRANK1 = 4'b0000;

reg		t1r, t2r, t3r, t4r;

reg		qt1, qt2, qt2n;

reg		data1, data2;

reg		sdata_edge, odata_edge, ddr_data;

wire		C2p, C3;

wire		load;

wire	[6:0]	tqsel;

wire	[4:0]	sel;

assign sel = {load,DATA_RATE_TQ,TRISTATE_WIDTH};





//////////////////////////////////////////////////


// Parameters for gate delays
parameter ffd = 1;
parameter mxd = 1;


/////////////////////////////
// Initialization of Flops
////////////////////////////

tri0 GSR = glbl.GSR;

always @(GSR)
begin
	if (GSR) 
		begin
			assign t1r = INIT_TRANK1[0];
			assign t2r = INIT_TRANK1[1];
			assign t3r = INIT_TRANK1[2];
			assign t4r = INIT_TRANK1[3];

		end
	else 
		begin
			deassign t1r;
			deassign t2r;
			deassign t3r;
			deassign t4r;
		end
end




// First rank of flops
// asynchronous reset operation
always @ (posedge CLKDIV or posedge SR)
begin
	begin
	if (SR & !SRTYPE[1])
		begin
			t1r <= # ffd 1'b0;
			t2r <= # ffd 1'b0;
			t3r <= # ffd 1'b0;
			t4r <= # ffd 1'b0;
		end  
	else if (!SRTYPE[1])
		begin
			t1r <= # ffd T1;
			t2r <= # ffd T2;
			t3r <= # ffd T3;
			t4r <= # ffd T4;
		end
	end
end

// synchronous reset operation
always @ (posedge CLKDIV)
begin
	begin
	if (SR & SRTYPE[1])
		begin
			t1r <= # ffd 1'b0;
			t2r <= # ffd 1'b0;
			t3r <= # ffd 1'b0;
			t4r <= # ffd 1'b0;
		end  
	else if (SRTYPE[1])
		begin
			t1r <= # ffd T1;
			t2r <= # ffd T2;
			t3r <= # ffd T3;
			t4r <= # ffd T4;
		end
	end
end





// Data Muxs for tristate otuput signals
always @ (sel or T1 or t1r or t3r)
	begin

		casex (sel)
		5'b00000: data1 <= # mxd T1;
		5'b10000: data1 <= # mxd T1;
		5'bX0000: data1 <= # mxd T1;
		5'b00100: data1 <= # mxd T1;
		5'b10100: data1 <= # mxd T1;
		5'bX0100: data1 <= # mxd T1;
		5'b01001: data1 <= # mxd T1;
		5'b11001: data1 <= # mxd T1;
		5'b01010: data1 <= # mxd t3r;
		5'b11010: data1 <= # mxd t1r;
// CR 551953 --  enabled TRISTATE_WIDTH to be 1 in DDR mode. No func change, but removed warnings
                5'b01000: ;
                5'b11000: ;
                5'bX1000: ;

		default: $display("DATA_RATE_TQ %b and/or TRISTATE_WIDTH %b at time %t are not supported by OSERDES", DATA_RATE_TQ,TRISTATE_WIDTH,$time);
		endcase
	end
// For data 2, width of 1 is inserted as acceptable for buf and sdr
//  The capability exists in the device if the feature is added
always @ (sel or T2 or t2r or t4r)
	begin
		casex (sel)
		5'b00000: data2 <= # mxd T2;
		5'b00100: data2 <= # mxd T2;
		5'b10000: data2 <= # mxd T2;
		5'b10100: data2 <= # mxd T2;
		5'bX0000: data2 <= # mxd T2;
		5'bX0100: data2 <= # mxd T2;
		5'b00X00: data2 <= # mxd T2;
		5'b10X00: data2 <= # mxd T2;
		5'bX0X00: data2 <= # mxd T2;
		5'b01001: data2 <= # mxd T2;
		5'b11001: data2 <= # mxd T2;
		5'bX1001: data2 <= # mxd T2;
		5'b01010: data2 <= # mxd t4r;
		5'b11010: data2 <= # mxd t2r;
// CR 551953 --  enabled TRISTATE_WIDTH to be 1 in DDR mode. No func change, but removed warnings
                5'b01000: ;
                5'b11000: ;
                5'bX1000: ;

		default: $display("DATA_RATE_TQ %b and/or TRISTATE_WIDTH %b at time %t are not supported by OSERDES", DATA_RATE_TQ,TRISTATE_WIDTH,$time);
		endcase
	end


endmodule
`timescale 1ps/1ps
//////////////////////////////////////////////////////////
//
//       module txbuffer_oserdese1_vlog
//
/////////////////////////////////////////////////////////
//
// FIFO and Control circuit for OSERDES

module txbuffer_oserdese1_vlog (iodelay_state, qmux1, qmux2, tmux1, tmux2,
		 d1, d2, t1, t2, trif,
		 WC, ODV, extra, 
		 clk, clkdiv, bufo, bufop, rst,
		 ODELAY_USED, DDR3_DATA,
		 DDR3_MODE);

input		d1, d2, t1, t2;

input		trif;

input		WC, ODV;

input		rst;

input		clk, clkdiv, bufo, bufop;

input		ODELAY_USED, DDR3_DATA;

input		DDR3_MODE;

output		iodelay_state, extra;

output		qmux1, qmux2, tmux1, tmux2;

wire		WC_DELAY;
assign WC_DELAY = 1'b0;

wire		rd_gap1;

wire		rst_bufo_p, rst_bufg_p;


wire		rst_bufo_rc, rst_bufg_wc, rst_cntr, rst_bufop_rc;

wire	[1:0]	qwc, qrd;

wire		bufo_out;


fifo_tdpipe_oserdese1_vlog data1 (.muxout(inv_qmux1), .din(~d1), .qwc(qwc), .qrd(qrd),
		.rd_gap1(rd_gap1),
		.bufg_clk(clk), .bufo_clk(bufo), .rst_bufo_p(rst_bufo_p), .rst_bufg_p(rst_bufg_p),
		.DDR3_DATA(DDR3_DATA), .extra(extra), .ODV(ODV), .DDR3_MODE(DDR3_MODE)
		
		);

fifo_tdpipe_oserdese1_vlog data2 (.muxout(inv_qmux2), .din(~d2), .qwc(qwc), .qrd(qrd),
		.rd_gap1(rd_gap1),
		.bufg_clk(clk), .bufo_clk(bufo), .rst_bufo_p(rst_bufo_p), .rst_bufg_p(rst_bufg_p),
		.DDR3_DATA(DDR3_DATA), .extra(extra), .ODV(ODV), .DDR3_MODE(DDR3_MODE)
		
		);

fifo_tdpipe_oserdese1_vlog tris1 (.muxout(inv_tmux1), .din(~t1), .qwc(qwc), .qrd(qrd),
		.rd_gap1(rd_gap1),
		.bufg_clk(clk), .bufo_clk(bufo), .rst_bufo_p(rst_bufo_p), .rst_bufg_p(rst_bufg_p),
		.DDR3_DATA(DDR3_DATA), .extra(extra), .ODV(ODV), .DDR3_MODE(DDR3_MODE)
		
		);

fifo_tdpipe_oserdese1_vlog tris2 (.muxout(inv_tmux2), .din(~t2), .qwc(qwc), .qrd(qrd),
		.rd_gap1(rd_gap1),
		.bufg_clk(clk), .bufo_clk(bufo), .rst_bufo_p(rst_bufo_p), .rst_bufg_p(rst_bufg_p),
		.DDR3_DATA(DDR3_DATA), .extra(extra), .ODV(ODV), .DDR3_MODE(DDR3_MODE)
		
		);

wire qmux1 = ~inv_qmux1;
wire qmux2 = ~inv_qmux2;
wire tmux1 = ~inv_tmux1;
wire tmux2 = ~inv_tmux2;

fifo_reset_oserdese1_vlog rstckt (.rst_bufo_p(rst_bufo_p), .rst_bufo_rc(rst_bufo_rc), 
			.rst_bufg_p(rst_bufg_p), .rst_bufg_wc(rst_bufg_wc),
			.rst_cntr(rst_cntr),
			.bufg_clk(clk), .bufo_clk(bufo), .clkdiv(clkdiv), .rst(rst),
			.divide_2(WC_DELAY), .bufop_clk(bufop), .rst_bufop_rc(rst_bufop_rc)
		
		);




fifo_addr_oserdese1_vlog addcntr (.qwc(qwc), .qrd(qrd), .rd_gap1(rd_gap1), .rst_bufg_wc(rst_bufg_wc), .rst_bufo_rc(rst_bufo_rc), .bufg_clk(clk), .bufo_clk(bufo),
			.data(DDR3_DATA), .extra(extra), .rst_bufop_rc(rst_bufop_rc), .bufop_clk(bufop)
		
		);



iodlyctrl_npre_oserdese1_vlog idlyctrl (.iodelay_state(iodelay_state), .bufo_out(bufo_out), .rst_cntr(rst_cntr),
			.wc(WC), .trif(trif),
			.rst(rst_bufg_p), .bufg_clk(clk), .bufo_clk(bufo), .bufg_clkdiv(clkdiv),
			.ddr3_dimm(ODELAY_USED), .wl6(WC_DELAY)
		);

endmodule
`timescale 1ps/1ps
////////////////////////////////////////////////////////
//
//       module fifo_tdpipe_oserdese1_vlog
//
////////////////////////////////////////////////////////

// FIFO for write path

module fifo_tdpipe_oserdese1_vlog (muxout, din, qwc, qrd, 
		rd_gap1,
		bufg_clk, bufo_clk, rst_bufo_p, rst_bufg_p,
		DDR3_DATA, extra, ODV, DDR3_MODE
		
		);


input		din;

input	[1:0]	qwc, qrd;

input		rd_gap1;

input		rst_bufo_p, rst_bufg_p;

input		bufg_clk, bufo_clk;

input		DDR3_DATA, ODV;

input		extra;

input		DDR3_MODE;

output		muxout;


reg		muxout;

reg		qout1, qout2;

reg		qout_int, qout_int2;

reg	[4:1]	fifo;

reg		cin1;

reg		omux;

wire	[2:0]	sel;

reg		pipe1, pipe2;

wire		selqoi, selqoi2;

wire	[2:0]	selmuxout;






// 4 flops that make up the basic FIFO.  They are all clocked
//  off of fast BUFG.  The first flop is the top flop in the chain.
//  The CE input is used to mux the inputs.  If the flop is selected,
//   CE is high and it takes data from the output of the mux.  If the
//   flop is not selected, it retains its data.

always @ (posedge bufg_clk or posedge rst_bufg_p)
	begin
	if (rst_bufg_p)
		begin
			fifo <= #10 4'b0000;
		end
	else if (!qwc[1] & !qwc[0])
		begin
			fifo <= #10 {fifo[4:2],din};
		end
	else if (!qwc[1] & qwc[0])
		begin
			fifo <= #10 {fifo[4:3],din,fifo[1]};
		end
	else if (qwc[1] & qwc[0])
		begin
			fifo <= #10 {fifo[4],din,fifo[2:1]};
		end
	else if (qwc[1] & !qwc[0])
		begin
			fifo <= #10 {din,fifo[3:1]};
		end
	end



// Capture stage top
// This is the top flop of the "3 flops" for ODDR.  This flop, along with the read
//  counter will be clocked off of bufo.  A 4:1 mux wil decode the outputs of the 
//  read counter and load the write data.  A subsequent 2:1 mux will decode between 
//  the fifo and the legacy operation


// OMUX

always @ (qrd or fifo)
	begin
	case (qrd)
	2'b00: omux <= #10 fifo[1];
	2'b01: omux <= #10 fifo[2];
	2'b10: omux <= #10 fifo[4];
	2'b11: omux <= #10 fifo[3];
	default: omux <= #10 fifo[1];
	endcase
	end


always @ (posedge bufo_clk or posedge rst_bufo_p)
	begin
	if (rst_bufo_p)
		begin
			qout_int <= #10 1'b0;
			qout_int2 <= #10 1'b0;
		end
	else
		begin
			qout_int <= #10 omux;
			qout_int2 <= #10 qout_int;
		end
	end

assign #10 selqoi = ODV | rd_gap1;


always @ (selqoi or qout_int or omux)
	begin
	case(selqoi)
	1'b0: qout1 <= #10 omux;
	1'b1: qout1 <= #10 qout_int;
	default: qout1 <= #10 omux;
	endcase
	end

assign #10 selqoi2 = ODV & rd_gap1;

always @ (selqoi2 or qout_int2 or qout_int)
	begin
	case(selqoi2)
	1'b0: qout2 <= #10 qout_int;
	1'b1: qout2 <= #10 qout_int2;
	default qout2 <= #10 qout_int;
	endcase
	end


assign #14 selmuxout = {DDR3_MODE,DDR3_DATA,extra};


always @ (selmuxout or din or omux or qout1 or qout2)
	begin
	case (selmuxout)
	3'b000: muxout = #1 din;
	3'b001: muxout = #1 din;
	3'b010: muxout = #1 din;
	3'b011: muxout = #1 din;
	3'b100: muxout = #1 omux;
	3'b101: muxout = #1 omux;
	3'b110: muxout = #1 qout1;
	3'b111: muxout = #1 qout2;
	default: muxout = #10 din;
	endcase
	end



endmodule
`timescale 1ps/1ps
////////////////////////////////////////////////////////
//
//       module fifo_reset_oserdese1_vlog
//
////////////////////////////////////////////////////////
//
// TX FIFO reset 
//
// This design performs 2 functions.  One function is to reset all the
//  flops in the TX FIFO.  The other function is to respond to the signal
//  rst_cntr.  This signal comes from iodlyctrl and will be used to initiate an
//  orderly transition to switch the DQ/DQS I/O from and read to a write.  
//  This process is required only for DDR3 DIMM support because the IODELAY
//  is used for both the inputs and the outputs.  The signal from the
//  squelch circuit is a present fabric output.  An additional input 
//  indicating that a write command was issued will be 
//  required for all I/O to support this signal.
//
// This design uses an asynchronous reset to reset all flops.  After the
//  reset is disabled, a 0 is propagated through the pipe stages to terminate
//  the reset.  The first 2 flops run off of the clkdiv domain.  Their output
//  feeds a latch to cross between the clkdiv and bufg_clk domain.  The pipe
//  stage for the bufg_clk domain is 3 deep, where the last flop is the
//  reset signal for the bufg_clk domain.  The 2nd flop of the bufg_clk pipe
//  is fed to 2 flops that are in the bufo_clk domain.  The 2 flops are 
//  to resolve metastability between the 2 clock domains.
//
// The circuit to enable an orderly transition from read to write uses the 
//  PREAMBLE_SYNCHED output of a portion of the squelch circuit.  This pulse
//  will initiate the reset sequence and also generate an enable which will
//  switch the IODELAY from an IDELAY to an ODELAY.  Timing is as specified in
//  the "State of the Union" presentation.
//
//


module fifo_reset_oserdese1_vlog (rst_bufo_p, rst_bufo_rc, 
			rst_bufg_p, rst_bufg_wc,
			rst_cntr,
			bufg_clk, bufo_clk, clkdiv, rst,
			divide_2, bufop_clk, rst_bufop_rc
		
		);


input		rst_cntr;

input		rst;

input		bufg_clk, bufo_clk, clkdiv;

input		bufop_clk;


// Memory cell input to support divide by 1 operation
input		divide_2;


output		rst_bufo_p, rst_bufo_rc;
output		rst_bufg_p, rst_bufg_wc;

output		rst_bufop_rc;


reg	[1:0]	clkdiv_pipe;

reg		bufg_pipe;

reg		rst_cntr_reg;

reg	[2:0]	bufo_rst_p, bufo_rst_rc;

reg	[1:0]	bufop_rst_rc;

reg	[1:0]	bufg_rst_p, bufg_rst_wc;

wire		bufg_clkdiv_latch, ltint1, ltint2, ltint3;

wire		latch_in;







// 2 stage pipe for clkdiv domain to allow user to properly
//  time everything


always @ (posedge bufg_clk or posedge rst)
	begin
	if (rst)
		begin
			rst_cntr_reg <= #10 1'b0;
		end
	else
		begin
			rst_cntr_reg <= #10 rst_cntr;
		end
	end


always @ (posedge clkdiv or posedge rst)
	begin
	if (rst)
		begin
			clkdiv_pipe <= #10 2'b11;
		end
	else
		begin
			clkdiv_pipe <= #10 {clkdiv_pipe[0],1'b0};
		end
	end

// Latch to compensate for clkdiv and bufg_clk clock skew
// Built of actual gates

assign #1 latch_in = clkdiv_pipe[1];

assign #1 bufg_clkdiv_latch = !(ltint1 && ltint3);
assign #1 ltint1 = !(latch_in && bufg_clk);
assign #1 ltint2 = !(ltint1 && bufg_clk);
assign #1 ltint3 = !(bufg_clkdiv_latch && ltint2);





// BUFG flop to register latch signal
always @ (posedge bufg_clk or posedge rst)
	begin
	if (rst)
		begin
			bufg_pipe <= #10 1'b1;
		end
	else
		begin
			bufg_pipe <= #10 bufg_clkdiv_latch;
		end
	end




// BUFG clock domain resests

always @ (posedge bufg_clk or posedge rst)
	begin
	if (rst)
		begin
			bufg_rst_p <= #10 2'b11;
		end
	else
		begin
			bufg_rst_p <= #10 {bufg_rst_p[0],bufg_pipe};
		end
	end


always @ (posedge bufg_clk or posedge rst_cntr or posedge rst)
	begin
	if (rst || rst_cntr)
		begin
			bufg_rst_wc <= #10 2'b11;
		end
	else
		begin
			bufg_rst_wc <= #10 {bufg_rst_wc[0],bufg_pipe};
		end
	end



// BUFO clock domain Resets
always @ (posedge bufo_clk or posedge rst)
	begin
	if (rst)
		begin
			bufo_rst_p <= #10 3'b111;
		end
	else
		begin
			bufo_rst_p <= #10 {bufo_rst_p[1:0],bufg_pipe};
		end
	end

always @ (posedge bufo_clk or posedge rst or posedge rst_cntr)
	begin
	if (rst || rst_cntr)
		begin
			bufo_rst_rc <= #10 3'b111;
		end
	else
		begin
			bufo_rst_rc <= #10 {bufo_rst_rc[1:0],bufg_pipe};
		end
	end



always @ (posedge bufop_clk or posedge rst or posedge rst_cntr)
	begin
	if (rst || rst_cntr)
		begin
			bufop_rst_rc <= #10 2'b11;
		end
	else
		begin
			bufop_rst_rc <= #10 {bufop_rst_rc[0],bufg_pipe};
		end
	end


// final reset assignments
assign rst_bufo_rc = bufo_rst_rc[1];

assign rst_bufo_p = bufo_rst_p[1];

assign rst_bufop_rc = bufop_rst_rc[1];

assign rst_bufg_wc = bufg_rst_wc[1];

assign rst_bufg_p = bufg_rst_p[1];


endmodule
`timescale 1ps/1ps
////////////////////////////////////////////////////////
//
//       module fifo_addr_oserdese1_vlog      
//
////////////////////////////////////////////////////////
// Read and Write address generators for TX FIFO
//
// This circuit contains 2 greycode read and write address generators
//  that will be used with the TX FIFO.  Both counters generate a 
//  count sequence of 00 -> 01 -> 11 -> 10 -> 00.



module fifo_addr_oserdese1_vlog (qwc, qrd, rd_gap1, rst_bufg_wc, rst_bufo_rc, bufg_clk, bufo_clk,
			data, extra, rst_bufop_rc, bufop_clk
		
		);


input		bufg_clk, bufo_clk;

input		rst_bufo_rc, rst_bufg_wc;

input		rst_bufop_rc;

input		data;  // mc to tell if I/O is DDR3 DQ or DQS

input		bufop_clk;

output		qwc, qrd;

output		rd_gap1, extra;




reg	[1:0]	qwc;

reg	[1:0]	qrd;


reg		stop_rd, rd_gap1, extra;

reg		rd_cor, rd_cor_cnt, rd_cor_cnt1;


wire		qwc0_latch, qwc1_latch;

wire		li01, li02, li03;

wire		li11, li12, li13;


wire		qwc0_latchn, qwc1_latchn;

wire		li01n, li02n, li03n;

wire		li11n, li12n, li13n;


reg		stop_rdn, rd_cor_cntn, rd_cor_cnt1n, stop_rc;




reg	[1:0]	qwcd;

reg	[1:0]	qrdd;


reg		stop_rdd, rd_gap1d, extrad;

reg		rd_cord, rd_cor_cntd, rd_cor_cnt1d;


wire		qwcd0_latch, qwcd1_latch;

wire		li01d, li02d, li03d;

wire		li11d, li12d, li13d;



// Write counter
//  The write counter uses 2 flops to create the grey code pattern of
//   00 -> 01 -> 11 -> 10 -> 00.  The write counter is initialized 
//   to 11 and the read counter will be initialized to 00.  This gives
//   a basic 2 clock separation to compensate for the phase differences.
//   The write counter is clocked off of the bufg clock

always @ (posedge bufg_clk or posedge rst_bufg_wc)
	begin
	if (rst_bufg_wc)
		begin
			qwc <= # 10 2'b11;
		end
	else if (qwc[1] ^ qwc[0])
		begin
			qwc[1] <= # 10 ~qwc[1];
			qwc[0] <= # 10 qwc[0];
		end
	else
		begin
			qwc[1] <= # 10 qwc[1];
			qwc[0] <= # 10 ~qwc[0];
		end
	end






// Read counter
//  The read counter uses 2 flops to create the grey code pattern of
//   00 -> 01 -> 11 -> 10 -> 00.  The read counter is initialized 
//   to 00 and the write counter will be initialized to 11.  This gives
//   a basic 2 clock separation to compensate for the phase differences.
//   The read counter is clocked off of the bufo clock

always @ (posedge bufo_clk or posedge rst_bufo_rc)

	begin
	if (rst_bufo_rc)
		begin
			qrd <= # 10 2'b00;
		end
	else if (stop_rd && !data)
		begin
			qrd <= #10 qrd;
		end
	else if (qrd[1] ^ qrd[0])
		begin
			qrd[1] <= # 10 ~qrd[1];
			qrd[0] <= # 10 qrd[0];
		end
	else
		begin
			qrd[1] <= # 10 qrd[1];
			qrd[0] <= # 10 ~qrd[0];
		end
	end

always @ (posedge bufo_clk or posedge rst_bufo_rc)

	begin
	if (rst_bufo_rc)
		begin
			rd_gap1 <= # 10 1'b0;
		end
//	else if ((qwc1_latch && qwc0_latch) && (qrd[0] ^ qrd[1]))
	else if ((qwc1_latch && qwc0_latch) && (qrd[0]))
		begin
			rd_gap1 <= # 10 1'b1;
		end
	else
		begin
			rd_gap1 <= # 10 rd_gap1;
		end
	end





// Looking for 11

assign #1 qwc0_latch = !(li01 & li03);
assign #1 li01 = !(qwc[0] & bufo_clk);
assign #1 li02 = !(li01 & bufo_clk);
assign #1 li03 = !(qwc0_latch & li02);


assign #1 qwc1_latch = !(li11 & li13);
assign #1 li11 = !(qwc[1] & bufo_clk);
assign #1 li12 = !(li11 & bufo_clk);
assign #1 li13 = !(qwc1_latch & li12);


// The following counter is to match the control counter to see if the
//  read counter did a hold  after reset.  This knowledge will enable the 
//  computation of the 'extra' output.  This in turn can add the 
//  proper number of pipe stages to the output. The circuit must use
//  the output of BUFO and not be modified by ODELAY.  This is because
//  the control pins PP clock was not modified by BUFO.  If the 
//  control pins PP clock was modified by BUFO, the reset must be done
//  with this in mind.

// Read counter
//  The read counter uses 2 flops to create the grey code pattern of
//   00 -> 01 -> 11 -> 10 -> 00.  The read counter is initialized 
//   to 00 and the write counter will be initialized to 11.  This gives
//   a basic 2 clock separation to compensate for the phase differences.
//   The read counter is clocked off of the bufo clock

always @ (posedge bufop_clk or posedge rst_bufop_rc)

	begin
	if (rst_bufop_rc)
		begin
			qrdd <= # 10 2'b00;
		end
	else if (qrdd[1] ^ qrdd[0])
		begin
			qrdd[1] <= # 10 ~qrdd[1];
			qrdd[0] <= # 10 qrdd[0];
		end
	else
		begin
			qrdd[1] <= # 10 qrdd[1];
			qrdd[0] <= # 10 ~qrdd[0];
		end
	end



// Looking for 11

assign #1 qwcd0_latch = !(li01d & li03d);
assign #1 li01d = !(qwc[0] & bufop_clk);
assign #1 li02d = !(li01d & bufop_clk);
assign #1 li03d = !(qwcd0_latch & li02d);


assign #1 qwcd1_latch = !(li11d & li13d);
assign #1 li11d = !(qwc[1] & bufop_clk);
assign #1 li12d = !(li11d & bufop_clk);
assign #1 li13d = !(qwcd1_latch & li12d);



// Circuit to fix read address counters in non data pins
always @ (posedge bufop_clk or posedge rst_bufo_rc)

	begin
	if (rst_bufop_rc)
		begin
			stop_rd <= # 10 1'b0;
 			rd_cor_cnt <= #10 1'b0;
 			rd_cor_cnt1 <= #10 1'b0;
		end
	else if (((qwcd1_latch && qwcd0_latch) && (qrdd[0] ^ qrdd[1]) && !rd_cor_cnt1))
		begin
			stop_rd <= #10 1'b1;
			rd_cor_cnt <= #10 1'b1;
 			rd_cor_cnt1 <= #10 rd_cor_cnt;
		end
	else
		begin
			stop_rd <= #10 1'b0;
			rd_cor_cnt <= #10 1'b1;
			rd_cor_cnt1 <= #10 rd_cor_cnt;
		end
	end

// Circuit to inform data if control counters habe been fixed

always @ (posedge bufop_clk or posedge rst_bufop_rc)
	begin
	if (rst_bufop_rc)
		begin
			extra <= #10 1'b0;
		end
	else if (stop_rd)
		begin
			extra <= #10 1'b1;
		end
	end

endmodule
`timescale 1ps/1ps
////////////////////////////////////////////////////////
//
//       module iodlyctrl_npre_oserdese1_vlog
//
////////////////////////////////////////////////////////
//
// Circuit to automatically switch IODELAY from IDELAY to ODELAY using knowledge 
//  of write command.  This circuit forces the user to wait 3 extra CLK/CLK# cycles
//  when performing a read to write turnaround.  The JEDEC DDR3 spec states that
//  the turnaround can be done in 2 clock cycles.  This circuit requires 5 clock
//  cycles.
// This circuit is only used for a DDR3 appplication that uses DIMMs



module iodlyctrl_npre_oserdese1_vlog (iodelay_state, bufo_out, rst_cntr,
			wc, trif,
			rst, bufg_clk, bufo_clk, bufg_clkdiv,
			ddr3_dimm, wl6
		);


input		wc;

input		trif;

input		rst;

input		bufo_clk, bufg_clk, bufg_clkdiv;

input		ddr3_dimm, wl6;

output		iodelay_state, rst_cntr;

output		bufo_out;


reg		qw0cd, qw1cd;

reg		turn, turn_p1;

reg		rst_cntr;

reg		w_to_w;

reg	[2:0]	wtw_cntr;

reg		cmd0, cmd0_n6, cmd0_6, cmd1;




wire		wr_cmd0;

wire		lt0int1, lt0int2, lt0int3;

wire		lt1int1, lt1int2, lt1int3;

wire		latch_in;

reg		qwcd;





assign bufo_out = bufo_clk;


// create turn signal for IODELAY
assign iodelay_state = (trif && ~w_to_w) & ((~turn && ~turn_p1) || ~ddr3_dimm);



// Registers to detect write command

// Registers using bufg clkdiv
always @ (posedge bufg_clkdiv)
begin
        if (rst)
        begin
                qwcd <= #10 0;
        end
        else
	begin
		qwcd <= #10 wc;
	end
end



// Latch to allow skew between CLK and CLKDIV from BUFGs
assign #1 wr_cmd0 = !(lt0int1 && lt0int3);
assign #1 lt0int1  = !(qwcd && bufg_clk);
assign #1 lt0int2  = !(lt0int1 && bufg_clk);
assign #1 lt0int3  = !(wr_cmd0 && lt0int2);

always @ (posedge bufg_clk)
	begin
	if (rst)
		begin
			cmd0_n6 <= #10 1'b0;
			cmd0_6 <= #10 1'b0;
		end
	else
		begin
			cmd0_n6 <= #10 wr_cmd0;
			cmd0_6 <= #10 cmd0_n6;
		end
	end



// mux to add extra pipe stage for WL = 6
always @ (cmd0_n6 or wl6 or cmd0_6)
	begin
	case (wl6)
	1'b0: cmd0 <= #10 cmd0_n6;
	1'b1: cmd0 <= #10 cmd0_6;
	default: cmd0 <= #10 cmd0_n6;
	endcase
	end
		

// Turn IODELAY and reset FIFO read/write counters
//always @ (posedge bufg_clk)
//	begin
//	if (rst)
//
//		begin
//			turn <= #10 1'b0;
//			rst_cntr <= #10 1'b0;
//		end
//	else if (w_to_w)
//		begin
//			turn <= #10 1'b1;
//			rst_cntr <= #10 1'b0;
//		end
//	else if (cmd0 && !turn)
//		begin
//			turn <= #10 1'b1;
//			rst_cntr <= #10 1'b1;
//		end
//	else if (~trif)
//		begin
//			turn <= #10 1'b0;
//			rst_cntr <= #10 1'b0;
//		end
//	else if (turn)
//		begin
//			turn <= #10 1'b1;
//			rst_cntr <= #10 1'b0;
//		end
//	else
//		begin
//			turn <= #10 1'b0;
//			rst_cntr <= #10 1'b0;
//		end
//	end



always @ (posedge bufg_clk)
begin
	begin
	if (rst)
		begin
			turn <= #10 1'b0;
		end
	else
		begin
			turn <= #10 (w_to_w || (cmd0 && ~turn) || 
				(~wtw_cntr[2] && turn));
		end

	end

	begin
	if (rst)
		begin
			rst_cntr <= #10 1'b0;
		end
	else
		begin
			rst_cntr <= #10 (~w_to_w && (cmd0 && ~turn));
		end
	end
end




always @ (posedge bufg_clk)
	begin
	if (rst)
		begin
			turn_p1 <= #10 1'b0;
		end
	else
		begin
			turn_p1 <= #10 turn;
		end
	end




// Detect multiple write commands and don"t turn IODELAY
//always @ (posedge bufg_clk)
//	begin
//	if (rst)
//		begin
//			w_to_w <= #10 1'b0;
//			wtw_cntr <= #10 3'b000;
//		end
//	else if (cmd0 && turn_p1)
//		begin
//			w_to_w <= #10 1'b1;
//			wtw_cntr <= #10 3'b000;
//		end
//	else if (wtw_cntr == 3'b101)
//		begin
//			w_to_w <= #10 1'b0;
//			wtw_cntr <= #10 3'b000;
//		end
//	else if (w_to_w)
//		begin
//			w_to_w <= #10 1'b1;
//			wtw_cntr <= #10 wtw_cntr + 1;
//		end
//	end


always @ (posedge bufg_clk)
begin
	begin
	if (rst)
		begin
			w_to_w <= #10 1'b0;
		end
	else
		begin
			w_to_w <= #10 ((cmd0 && turn_p1) || 
			   (w_to_w && (~wtw_cntr[2] || ~wtw_cntr[1])));
		end
	end
end


always @ (posedge bufg_clk)

	begin
	if (!(w_to_w || turn) || (cmd0 && turn_p1))
		begin
			wtw_cntr <= #10 3'b000;
		end
	else if (w_to_w || turn_p1)
		begin
			wtw_cntr <= #10 wtw_cntr + 1;
		end
	end

endmodule
`timescale 1ps/1ps
////////////////////////////////////////////////////////
//
//      MODULE dout_oserdese1_vlog
//
//	This model ONLY works for SERDES operation!!
//	Does not include tristate circuit
//
/////////////////////////////////////////////////////////
//
//   Inputs: 
//	data1: Data from FIFO
//	data2: Data input FIFO
//	CLK: High speed clock from DCM
//	BUFO: Clock from performance path
//	OCE: Clock enable for output data flops
//	SR: Set/Reset control.  For the last 3 flops in OQ
//	     (d1rnk2, d2rnk2 and d2nrnk2) this function is 
//	     controlled bythe attributes SRVAL_OQ.  In SERDES mode,
//	     SR is a RESET ONLY for all other flops!  The flops will
//	     still be RESET even if SR is programmed to a SET!
//				
//
//
//   Outputs:	
//	OQ: Data output
//
//
//
//   Programmable Points
//	DATA_RATE_OQ: Rate control for data output, 1-bit
//			sdr (1), ddr (0)
//	INIT_OQ: Init OQ output "flop"
//	SRVAL_OQ: This bit to controls value of SR input.
//		    Only the last 3 flops (d1rnk2, d2rnk2 and d2nrnk2)
//		    are affected by this bit.For SERDES mode, this bit 
//		    should be set to '0' making SR a reset.  This is the 
//		    desired state since all other flops only respond to 
//		    this pin as a reset.  Their function cannot be
//		    changed.  SR is '1' for SET and '0' for RESET.
//	
//
//
//  Programmable points for Test model
//	SRTYPE: This is a 4-bit field  Sets asynchronous (0) or synchronous (1) set/reset
//		1st bit (msb) sets rank1 flops, 2nd bit sets 4 flops in rank 2,
//		3rd bit sets "3 legacy flops, and 4th (lsb) bit sets the counter
//	DDR_CLK_EDGE: Controls use of 2 or 3 flops for single case.  Default to 1 for
//			SERDES operation
//
//
///////////////////////////////////////////////////////////////////////////////
//

module dout_oserdese1_vlog (data1, data2,
		CLK, BUFO, SR, OCE,
		OQ, d2rnk2,
		DATA_RATE_OQ,
		INIT_OQ, SRVAL_OQ,
		DDR3_MODE);

input		data1, data2;

input		CLK, SR, OCE;

input		BUFO;

input		INIT_OQ, SRVAL_OQ;

input		DDR3_MODE;

output		OQ;

output		d2rnk2;


// Programmable Points

input		DATA_RATE_OQ;

wire		DDR_CLK_EDGE;
wire	[3:0]	SRTYPE;
assign DDR_CLK_EDGE = 1'b1;
assign SRTYPE = 4'b1111;
reg		d1rnk2, d2rnk2, d2nrnk2;

reg		OQ;

reg		ddr_data, odata_edge, sdata_edge;

reg		c23, c45, c67;

wire		C;

wire		C2p, C3;

wire	[3:0]	seloq;

wire		oqsr, oqrev;

assign C = (BUFO & DDR3_MODE) | (CLK & !DDR3_MODE);

assign C2p = (C & DDR_CLK_EDGE) | (!C & !DDR_CLK_EDGE);

assign C3 = !C2p;

assign seloq = {OCE,DATA_RATE_OQ,oqsr,oqrev};

assign oqsr =  !SRTYPE[1] & SR & !SRVAL_OQ;

assign oqrev = !SRTYPE[1] & SR & SRVAL_OQ;



//////////////////////////////////////////////////
// Delay values
//
parameter     	FFD = 1; // clock to out delay for flip flops
//                            driven by clk
parameter	FFCD = 1; // clock to out delay for flip flops
//                               driven by clkdiv
parameter	MXD = 1; // 60 ps mux delay

parameter	MXR1 = 1;

////////////////////////////////////////////
// Initialization of flops with GSR for test model
///////////////////////////////////////////

tri0 GSR = glbl.GSR;

always @(GSR)
begin
	if (GSR) 
		begin
			assign OQ = INIT_OQ;
			assign d1rnk2 = INIT_OQ;
			assign d2rnk2 = INIT_OQ;
			assign d2nrnk2 = INIT_OQ;
		end
	else 
		begin
			deassign OQ;
			deassign d1rnk2;
			deassign d2rnk2;
			deassign d2nrnk2;
		end
end

/////////////////////////////////////////






/////////////////////////////////////////
// 3 flops to create DDR operations of 4 latches
////////////////////////////////////////

// Representation of top latch
// asynchronous operation
always @ (posedge C or posedge SR)
begin
	begin
	if (SR & !SRVAL_OQ & !SRTYPE[1])
		begin
			d1rnk2 <= # FFD 1'b0;
		end
	else if (SR & SRVAL_OQ & !SRTYPE[1])
		begin
			d1rnk2 <= # FFD 1'b1;
		end
	else if (!OCE & !SRTYPE[1])
		begin
			d1rnk2 <= # FFD OQ;
		end
	else if (!SRTYPE[1])
		begin
			d1rnk2 <= # FFD data1;
		end
	end
end

// synchronous operation
always @ (posedge C)
begin
	begin

	if (SR & !SRVAL_OQ & SRTYPE[1])
		begin
			d1rnk2 <= # FFD 1'b0;
		end
	else if (SR & SRVAL_OQ & SRTYPE[1])
		begin
			d1rnk2 <= # FFD 1'b1;
		end
	else if (!OCE & SRTYPE[1])
		begin
			d1rnk2 <= # FFD OQ;
		end
	else if (SRTYPE[1])
		begin
			d1rnk2 <= # FFD data1;
		end
	end
end




// Representation of 2nd latch
// asynchronous operation
always @ (posedge C2p or posedge SR)
begin
	begin
	if (SR & !SRVAL_OQ & !SRTYPE[1])
		begin
			d2rnk2 <= # FFD 1'b0;
		end
	else if (SR & SRVAL_OQ & !SRTYPE[1])
		begin
			d2rnk2 <= # FFD 1'b1;
		end
	else if (!OCE & !SRTYPE[1])
		begin
			d2rnk2 <= # FFD OQ;
		end
	else if (!SRTYPE[1])
		begin
			d2rnk2 <= # FFD data2;
		end
	end
end

// synchronous operation
always @ (posedge C2p)
begin
	begin

	if (SR & !SRVAL_OQ & SRTYPE[1])
		begin
			d2rnk2 <= # FFD 1'b0;
		end
	else if (SR & SRVAL_OQ & SRTYPE[1])
		begin
			d2rnk2 <= # FFD 1'b1;
		end
	else if (!OCE & SRTYPE[1])
		begin
			d2rnk2 <= # FFD OQ;
		end
	else if (SRTYPE[1])
		begin
			d2rnk2 <= # FFD data2;
		end
	end
end




// Representation of 3rd flop ( latch and output latch)
// asynchronous operation
always @ (posedge C3 or posedge SR)
begin
	begin
	if (SR & !SRVAL_OQ & !SRTYPE[1])
		begin
			d2nrnk2 <= # FFD 1'b0;
		end
	else if (SR & SRVAL_OQ & !SRTYPE[1])
		begin
			d2nrnk2 <= # FFD 1'b1;
		end
	else if (!OCE & !SRTYPE[1])
		begin
			d2nrnk2 <= # FFD OQ;
		end
	else if (!SRTYPE[1])
		begin
			d2nrnk2 <= # FFD d2rnk2;
		end
	end
end

// synchronous operation
always @ (posedge C3)
begin

	begin
	if (SR & !SRVAL_OQ & SRTYPE[1])
		begin
			d2nrnk2 <= # FFD 1'b0;
		end
	else if (SR & SRVAL_OQ & SRTYPE[1])
		begin
			d2nrnk2 <= # FFD 1'b1;
		end
	else if (!OCE & SRTYPE[1])
		begin
			d2nrnk2 <= # FFD OQ;
		end
	else if (SRTYPE[1])
		begin
			d2nrnk2 <= # FFD d2rnk2;
		end
	end
end


// Logic to generate same edge data from d1rnk2 and d2nrnk2;
always @ (C or C3 or d1rnk2 or d2nrnk2)
	begin
		sdata_edge <= # MXD (d1rnk2 & C) | (d2nrnk2 & C3);
	end

// Mux to create opposite edge DDR data from d1rnk2 and d2rnk2
always @ (C or d1rnk2 or d2rnk2)
	begin
		case (C)
		1'b0: odata_edge <= # MXD d2rnk2;
		1'b1: odata_edge <= # MXD d1rnk2;
		default: odata_edge <= # MXD d1rnk2;
		endcase
	end

// Logic to same edge and opposite data into just ddr data
always @ (ddr_data or sdata_edge or odata_edge or DDR_CLK_EDGE)
	begin
		ddr_data <= # MXD (odata_edge & !DDR_CLK_EDGE) | (sdata_edge & DDR_CLK_EDGE);
	end


// Output mux to generate OQ
always @ (seloq or d1rnk2 or ddr_data or OQ)
	begin
		casex (seloq)
                4'bXX01: OQ <= # MXD 1'b1;
                4'bXX10: OQ <= # MXD 1'b0;
                4'bXX11: OQ <= # MXD 1'b0;
                4'bX000: OQ <= # MXD ddr_data;
                4'bX100: OQ <= # MXD d1rnk2;
                default: OQ <= # MXD ddr_data;
		endcase
	end


endmodule
`timescale 1ps/1ps
//////////////////////////////////////////////////////////
//
//       module tout_oserdese1_vlog
//
//       Tristate Output cell for Mt Blanc
//
//
////////////////////////////////////////////////////////
//
//
//
/////////////////////////////////////////////////////////
//
//   Inputs:
//	
//	data1, data2: tristate inputs
//	TCE: Tristate clock enable
//	SR: Set/Reset control.  For the last 3 flops in TQ
//	     (qt1, qt2 and qt2n) this function is 
//	     controlled bythe attributes SRVAL_TQ.  In SERDES mode,
//	     SR is a RESET ONLY for all other flops!  The flops will
//	     still be RESET even if SR is programmed to a SET!
//	CLK: High speed clocks
//	C2 drives 2nd latch and C3 (inverse of C2) drives 
//			3rd latch in output section
//	BUFO: Performance path clock
//
//				
//
//
//   Outputs:
//
//	TQ: Output of tristate mux
//
//
//   Programmable Options:
//
//	DATA_RATE_TQ: 2-bit field for types of operaiton
//		0 (buf from T1), 1 (registered output from T1), 2 (ddr)
//	TRISTATE_WIDTH: 2-bit field for input width
//		0 (width 1), 1 (width 2), 2 (width 4)
//	INIT_TQ: Init TQ output (0,1)
//	SRVAL_TQ: This bit to controls value of SR input.
//		    Only the last 3 flops (qt1, qt2 and qt2n) are 
//		    affected by this bit.For SERDES mode, this bit 
//		    should be set to '0' making SR a reset.  This is the 
//		    desired state since all other flops only
//		    respond to this pin as a reset.  Their function 
//		    cannot be changed.  SR is 'O' for SET and '1' for RESET.
//
//
//  Programmable Test Options:
//	SRTYPE: Control S and R as asynchronous (0) or synchronous (1)
//		2-bit value.  1st bit (msb) controls the 4 input flops
//		and the 2nd bit (lsb) controls the "3 legacy flops"
//	DDR_CLK_EDGE: Same or opposite edge operation
//		  
//
//
////////////////////////////////////////////////////////////////////////////////
//

module tout_oserdese1_vlog (data1, data2,
		CLK, BUFO, SR, TCE, 
		DATA_RATE_TQ, TRISTATE_WIDTH,
		INIT_TQ, SRVAL_TQ, 
		TQ, DDR3_MODE);

input		data1, data2;

input		CLK, BUFO, SR, TCE;

input	[1:0]	DATA_RATE_TQ, TRISTATE_WIDTH;

input		INIT_TQ, SRVAL_TQ;

input		DDR3_MODE;

output		TQ;

wire		DDR_CLK_EDGE;
wire	[1:0]	SRTYPE;
assign SRTYPE = 2'b11;
assign DDR_CLK_EDGE = 1'b1;

reg		TQ;

reg		t1r, t2r, t3r, t4r;

reg		qt1, qt2, qt2n;

reg		sdata_edge, odata_edge, ddr_data;

wire		C;

wire		C2p, C3;

wire		load;

wire	[5:0]	tqsel;

wire		tqsr, tqrev;

wire	[4:0]	sel;

assign C = (BUFO & DDR3_MODE) | (CLK & !DDR3_MODE);

assign C2p = (C & DDR_CLK_EDGE) | (!C & !DDR_CLK_EDGE);

assign C3 = !C2p;

assign tqsr =  (!SRTYPE[0] & SR & !SRVAL_TQ) | (!SRTYPE[0] & SRVAL_TQ);

assign tqrev = (!SRTYPE[0] & SR &  SRVAL_TQ) | (!SRTYPE[0] & !SRVAL_TQ);

assign tqsel = {TCE,DATA_RATE_TQ,TRISTATE_WIDTH,tqsr};





//////////////////////////////////////////////////


// Parameters for gate delays
parameter ffd = 1;
parameter mxd = 1;


/////////////////////////////
// Initialization of Flops
////////////////////////////

tri0 GSR = glbl.GSR;

always @(GSR)
begin
	if (GSR) 
		begin
			assign TQ = INIT_TQ;
			assign qt1 = INIT_TQ;
			assign qt2 = INIT_TQ;
			assign qt2n = INIT_TQ;
		end
	else 
		begin
			deassign TQ;
			deassign qt1;
			deassign qt2;
			deassign qt2n;
		end
end



/////////////////////////////////////////
// 3 flops to create DDR operations of 4 latches
////////////////////////////////////////

// Representation of top latch
// asynchronous operation
always @ (posedge C or posedge SR)
begin
	begin
	if (SR & !SRVAL_TQ & !SRTYPE[0])
		begin
			qt1 <= # ffd 1'b0;
		end
	else if (SR & SRVAL_TQ & !SRTYPE[0])
		begin
			qt1 <= # ffd 1'b1;
		end
	else if (!TCE & !SRTYPE[0])
		begin
			qt1 <= # ffd TQ;
		end
	else if (!SRTYPE[0])
		begin
			qt1 <= # ffd data1;
		end
	end
end

// synchronous operation
always @ (posedge C)
begin
	begin

	if (SR & !SRVAL_TQ & SRTYPE[0])
		begin
			qt1 <= # ffd 1'b0;
		end
	else if (SR & SRVAL_TQ & SRTYPE[0])
		begin
			qt1 <= # ffd 1'b1;
		end
	else if (!TCE & SRTYPE[0])
		begin
			qt1 <= # ffd TQ;
		end
	else if (SRTYPE[0])
		begin
			qt1 <= # ffd data1;
		end
	end
end




// Representation of 2nd latch
// asynchronous operation
always @ (posedge C2p or posedge SR)
begin
	begin
	if (SR & !SRVAL_TQ & !SRTYPE[0])
		begin
			qt2 <= # ffd 1'b0;
		end
	else if (SR & SRVAL_TQ & !SRTYPE[0])
		begin
			qt2 <= # ffd 1'b1;
		end
	else if (!TCE & !SRTYPE[0])
		begin
			qt2 <= # ffd TQ;
		end
	else if (!SRTYPE[0])
		begin
			qt2 <= # ffd data2;
		end
	end
end

// synchronous operation
always @ (posedge C2p)
begin
	begin
	if (SR & !SRVAL_TQ & SRTYPE[0])
		begin
			qt2 <= # ffd 1'b0;
		end
	else if (SR & SRVAL_TQ & SRTYPE[0])
		begin
			qt2 <= # ffd 1'b1;
		end
	else if (!TCE & SRTYPE[0])
		begin
			qt2 <= # ffd TQ;
		end
	else if (SRTYPE[0])
		begin
			qt2 <= # ffd data2;
		end
	end
end




// Representation of 3rd flop ( latch and output latch)
// asynchronous operation
always @ (posedge C3 or posedge SR)
begin
	begin
	if (SR & !SRVAL_TQ & !SRTYPE[0])
		begin
			qt2n <= # ffd 1'b0;
		end
	else if (SR & SRVAL_TQ & !SRTYPE[0])
		begin
			qt2n <= # ffd 1'b1;
		end
	else if (!TCE & !SRTYPE[0])
		begin
			qt2n <= # ffd TQ;
		end
	else if (!SRTYPE[0])
		begin
			qt2n <= # ffd qt2;
		end
	end
end

// synchronous operation
always @ (posedge C3)
begin

	begin
	if (SR & !SRVAL_TQ & SRTYPE[0])
		begin
			qt2n <= # ffd 1'b0;
		end
	else if (SR & SRVAL_TQ & SRTYPE[0])
		begin
			qt2n <= # ffd 1'b1;
		end
	else if (!TCE & SRTYPE[0])
		begin
			qt2n <= # ffd TQ;
		end
	else if (SRTYPE[0])
		begin
			qt2n <= # ffd qt2;
		end
	end
end


// Logic to generate same edge data from qt1, qt3;
always @ (C or C3 or qt1 or qt2n)
	begin
		sdata_edge <= # mxd (qt1 & C) | (qt2n & C3);
	end

// Mux to create opposite edge DDR function
always @ (C or qt1 or qt2)
	begin
		case (C)
		1'b0: odata_edge <= # mxd qt2;
		1'b1: odata_edge <= # mxd qt1;
		default: odata_edge <= 1'b0;
		endcase
	end

// Logic to same edge and opposite data into just ddr data
always @ (ddr_data or sdata_edge or odata_edge or DDR_CLK_EDGE)
	begin
		ddr_data <= # mxd (odata_edge & !DDR_CLK_EDGE) | (sdata_edge & DDR_CLK_EDGE);
	end

// Output mux to generate TQ
// Note that the TQ mux can also support T2 combinatorial or
//  registered outputs.
always @ (tqsel or data1 or ddr_data or qt1 or TQ)
	begin
		casex (tqsel)
                6'bX01XX1: TQ <= # mxd 1'b0;
                6'bX10XX1: TQ <= # mxd 1'b0;
                6'bX01XX1: TQ <= # mxd 1'b0;
                6'bX10XX1: TQ <= # mxd 1'b0;
                6'bX0000X: TQ <= # mxd data1;
        //      6'b001000: TQ <= # mxd TQ;
        //      6'b010010: TQ <= # mxd TQ;
        //      6'b010100: TQ <= # mxd TQ;
                6'bX01000: TQ <= # mxd qt1;
                6'bX10010: TQ <= # mxd ddr_data;
                6'bX10100: TQ <= # mxd ddr_data;
		default: TQ <= # mxd ddr_data;
		endcase
	end


endmodule

