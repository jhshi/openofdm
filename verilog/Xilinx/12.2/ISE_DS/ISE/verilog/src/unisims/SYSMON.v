///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Function Simulation Library Component
//  /   /                 System Monitor 
// /___/   /\     Filename  : SYSMON.v
// \   \  /  \    Timestamp :
//  \___\/\___\
//
// Revision:
//    06/15/04 - Initial version.
//    09/16/05 - Updated according to HW Usage Documents.
//    01/06/06 - Modified to match HW waveform for HW test cases.
//    03/08/06 - Add intial to internal signals. (BT1044)
//               - add parameter type (CR 226003)
//    05/19/06 - align with vhdl model. (CR231777). 
//    08/30/06 - GSR only reset DRP port (CR 422678).
//    09/06/06 - Add internal 1 ns reset at time 0 (CR422678).
//    09/14/06 - Match vhdl model (CR 424061).
//    09/26/06 - Update error messages; Make unipolar same as bipolar for external channels;
//             - extend file reader one_line register to 600 characters etc. (CR426629).
//    10/30/06 - Match HW timing (CR 428185)
//    12/13/06 - Reset eoc_out_temp1 when calibration channel (CR430923)
//               Change INIT_42 to 0800h (CR 429642).
//    06/04/07 - Add wire declaration to internal signal.
//    07/17/07 - Add SIM_DEVICE attribute allow clock divider lower to 2 for MBLANC.
//    04/01/08 - Remove setup/hold check for CONVST. (CR470708)
//    04/15/08 - DEN need toggled and can not just pull high (CR471205).
//    05/07/08 - Add negative setup/hold support (CR468872)
//    05/26/08 - Add vector range to parameter align with yaml.
//    09/02/08 - Change MBLANC to VIRTEX6.
//    10/09/08 - Change OT temperature max from 120 degree to 125 degree. (CR491781)
//    02/12/09 - Add V6 changes.
//    05/21/09 - Remove alarm bits from status_reg (CR522721)
// End Revision


`timescale 1ps / 1ps
//`define EOFile -1

module SYSMON (
        ALM,
        BUSY,
        CHANNEL,
        DO,
        DRDY,
        EOC,
        EOS,
        JTAGBUSY,
        JTAGLOCKED,
        JTAGMODIFIED,
        OT,
        CONVST,
        CONVSTCLK,
        DADDR,
        DCLK,
        DEN,
        DI,
        DWE,
        RESET,
        VAUXN,
        VAUXP,
        VN,
        VP

);

output BUSY;
output DRDY;
output EOC;
output EOS;
output JTAGBUSY;
output JTAGLOCKED;
output JTAGMODIFIED;
output OT;
output [15:0] DO;
output [2:0] ALM;
output [4:0] CHANNEL;

input CONVST;
input CONVSTCLK;
input DCLK;
input DEN;
input DWE;
input RESET;
input VN;
input VP;
input [15:0] DI;
input [15:0] VAUXN;
input [15:0] VAUXP;
input [6:0] DADDR;

    parameter  [15:0] INIT_40 = 16'h0;
    parameter  [15:0] INIT_41 = 16'h0;
    parameter  [15:0] INIT_42 = 16'h0800;
    parameter  [15:0] INIT_43 = 16'h0;
    parameter  [15:0] INIT_44 = 16'h0;
    parameter  [15:0] INIT_45 = 16'h0;
    parameter  [15:0] INIT_46 = 16'h0;
    parameter  [15:0] INIT_47 = 16'h0;
    parameter  [15:0] INIT_48 = 16'h0;
    parameter  [15:0] INIT_49 = 16'h0;
    parameter  [15:0] INIT_4A = 16'h0;
    parameter  [15:0] INIT_4B = 16'h0;
    parameter  [15:0] INIT_4C = 16'h0;
    parameter  [15:0] INIT_4D = 16'h0;
    parameter  [15:0] INIT_4E = 16'h0;
    parameter  [15:0] INIT_4F = 16'h0;
    parameter  [15:0] INIT_50 = 16'h0;
    parameter  [15:0] INIT_51 = 16'h0;
    parameter  [15:0] INIT_52 = 16'h0;
    parameter  [15:0] INIT_53 = 16'h0;
    parameter  [15:0] INIT_54 = 16'h0;
    parameter  [15:0] INIT_55 = 16'h0;
    parameter  [15:0] INIT_56 = 16'h0;
    parameter  [15:0] INIT_57 = 16'h0;
    parameter SIM_DEVICE = "VIRTEX5";
    parameter SIM_MONITOR_FILE = "design.txt";
    

    localparam  INIT_STATE = 0,
                SINGLE_SEQ_STATE = 1,
                ACQ_STATE = 2,
                CONV_STATE = 3,
                END_STATE = 5,
                RST_STATE = 6;

    time time_out, prev_time_out;
    
    integer temperature_index = -1, time_index = -1, vccaux_index = -1;
    integer vccint_index = -1, vn_index = -1, vp_index = -1;
    integer vauxp_idx0 = -1, vauxn_idx0 = -1;
    integer vauxp_idx1 = -1, vauxn_idx1 = -1;
    integer vauxp_idx2 = -1, vauxn_idx2 = -1;
    integer vauxp_idx3 = -1, vauxn_idx3 = -1;
    integer vauxp_idx4 = -1, vauxn_idx4 = -1;
    integer vauxp_idx5 = -1, vauxn_idx5 = -1;
    integer vauxp_idx6 = -1, vauxn_idx6 = -1;
    integer vauxp_idx7 = -1, vauxn_idx7 = -1;
    integer vauxp_idx8 = -1, vauxn_idx8 = -1;
    integer vauxp_idx9 = -1, vauxn_idx9 = -1;
    integer vauxp_idx10 = -1, vauxn_idx10 = -1;
    integer vauxp_idx11 = -1, vauxn_idx11 = -1;
    integer vauxp_idx12 = -1, vauxn_idx12 = -1;
    integer vauxp_idx13 = -1, vauxn_idx13 = -1;
    integer vauxp_idx14 = -1, vauxn_idx14 = -1;
    integer vauxp_idx15 = -1, vauxn_idx15 = -1;
    integer char_1, char_2, fs, fd;
    integer num_arg, num_val;
    integer clk_count, seq_count;
    integer seq_status_avg, acq_count;
    integer conv_avg_count [31:0];
    integer conv_acc [31:0];
    integer conv_result_int;
    integer conv_time, conv_count, conv_time_cal, conv_time_cal_1;
    integer h, i, j, k, l, m, n, p;
    integer file_line;

// string    
    reg [8*12:1] label0, label1, label2, label3, label4, label5, label6, label7, label8, label9, label10, label11, label12, label13, label14, label15, label16, label17, label18, label19, label20, label21, label22, label23, label24, label25, label26, label27, label28, label29, label30, label31, label32, label33, label34, label35, label36, label37, label38, label39;
    reg [8*600:1] one_line;
    reg [8*12:1] label [40:0];
    reg [8*12:1] tmp_label;
    reg end_of_file;
    
    real column_real0, column_real1, column_real2, column_real3, column_real4, column_real5, column_real6, column_real7, column_real8, column_real9, column_real10, column_real11, column_real12, column_real13, column_real14, column_real15, column_real16, column_real17, column_real18, column_real19, column_real20, column_real21, column_real22, column_real23, column_real24, column_real25, column_real26, column_real27, column_real28, column_real29, column_real30, column_real31, column_real32, column_real33, column_real34, column_real35, column_real36, column_real37, column_real38, column_real39;

// array of real numbers
//    real column_real [39:0];
    reg [63:0] column_real [39:0];
    reg [63:0] chan_val [31:0];
    reg [63:0] chan_val_tmp [31:0];
    reg [63:0] chan_valn [31:0];
    reg [63:0] chan_valn_tmp [31:0];
    reg [63:0] analog_in_diff [31:0];
    reg [63:0] analog_in_uni [31:0];
    reg [63:0] analog_comm_in [31:0];

    real chan_val_p_tmp, chan_val_n_tmp;
    real analog_mux_in, analog_in_tmp, analog_comm_in_tmp, analog_in_comm;
    real adc_temp_result, adc_intpwr_result;
    real adc_ext_result;

    reg sim_device_int;
    reg seq_reset, seq_reset_dly, seq_reset_flag, seq_reset_flag_dly;
    reg soft_reset = 0;
    reg en_data_flag;
    reg first_cal_chan;
    reg seq_en;
    reg seq_en_dly;
    wire [15:0] status_reg;
    reg [15:0] ot_limit_reg = 16'hCA00;
    reg [15:0]  ot_sf_limit_low_reg = 16'hAE40;
    reg [23:0] conv_acc_vec;
    reg [15:0] conv_result;
    reg [15:0] conv_result_reg, conv_acc_result;
    wire [7:0] curr_clkdiv_sel;
    reg [2:0]  alarm_out_reg;
    reg [4:0] curr_chan, curr_chan_lat;
    reg [2:0] adc_state, next_state;
    reg conv_start, conv_end;
    reg eos_en, eos_tmp_en;
    reg drdy_out, drdy_out_tmp1, drdy_out_tmp2, drdy_out_tmp3, drdy_out_tmp4;
    reg ot_out_reg;
    reg [15:0] do_out;
    reg [15:0] do_out_rdtmp;
    reg [15:0] data_reg [39:0];
    reg [15:0] dr_sram [111:64];
    reg sysclk, adcclk_tmp;
    wire adcclk;
    reg [1:0] curr_seq1_0, curr_seq1_0_lat;
    reg curr_e_c, curr_b_u, curr_acq;
    reg seq_count_en;
    reg [4:0] acq_chan;
    reg acq_b_u;
    reg adc_s1_flag, acq_acqsel;
    wire acq_e_c;
    reg acq_e_c_tmp5, acq_e_c_tmp6;
    reg [1:0] curr_avg_set;
    reg eoc_en, eoc_en_delay;
    reg eoc_out_tmp, eos_out_tmp;
    reg eoc_out_tmp1, eos_out_tmp1;
    reg eoc_out, eos_out;
    reg busy_r, busy_r_rst;
    reg busy_sync1, busy_sync2;
    wire busy_sync_fall, busy_sync_rise;
    reg notifier, notifier_do;
    reg [4:0] channel_out; 
    reg rst_lock, rst_lock_early;
    reg sim_file_flag;
    reg [6:0] daddr_in_lat;
    reg [15:0] init40h_tmp, init41h_tmp, init42h_tmp, init4eh_tmp;
    reg [2:0] alarm_out;
    reg       ot_out;
    reg [15:0] curr_seq;
    reg busy_out, busy_rst, busy_conv, busy_out_tmp, busy_seq_rst;
    reg [1:0] seq1_0, seq_bits;
    reg ot_en, alarm_update, drp_update, cal_chan_update;
    reg [2:0] alarm_en;
    reg [4:0] scon_tmp;
    wire [15:0] seq_chan_reg1, seq_chan_reg2, seq_acq_reg1, seq_acq_reg2;
    wire [15:0] seq_avg_reg1, seq_avg_reg2, seq_du_reg1, seq_du_reg2;
    reg [15:0] cfg_reg1_init;
 
    reg [4:0] seq_curr_i;
    integer busy_rst_cnt;
    integer si, seq_num;
    integer seq_mem [32:0];

    wire rst_in, adc_convst;
    wire [15:0] cfg_reg0;
    wire [15:0] cfg_reg1;
    wire [15:0] cfg_reg2;
    wire [15:0] di_in;
    wire [6:0] daddr_in;
    wire [15:0] tmp_data_reg_out, tmp_dr_sram_out;
    wire convst_in;
    wire rst_in_not_seq;
    wire adcclk_div1;
    wire gsr_in;
    wire convst_raw_in, convstclk_in, dclk_in, den_in, rst_input, dwe_in;
    wire DCLK_dly, DEN_dly, DWE_dly;
    wire [6:0] DADDR_dly;
    wire [15:0] DI_dly;
    
    tri0 GSR = glbl.GSR;

    assign #100 BUSY = busy_out;
    assign #100 DRDY = drdy_out;
    assign #100 EOC = eoc_out;
    assign #100 EOS = eos_out;
    assign #100 OT = ot_out;
    assign #100 DO = do_out;
    assign #100 CHANNEL = channel_out;
    assign #100 ALM = alarm_out;
    
    assign convst_raw_in = CONVST;
    assign convstclk_in = CONVSTCLK;
    assign dclk_in = DCLK;
    assign den_in = DEN;
    assign rst_input = RESET;
    assign dwe_in = DWE;
    assign di_in = DI; 
    assign daddr_in = DADDR;
    assign gsr_in = GSR;
    assign convst_in = (convst_raw_in===1 || convstclk_in===1) ? 1: 0;
    assign JTAGLOCKED = 0;
    assign JTAGMODIFIED = 0;
    assign JTAGBUSY = 0;

    initial begin

        init40h_tmp = INIT_40;
        init41h_tmp = INIT_41;
        init42h_tmp = INIT_42;
        init4eh_tmp = INIT_4E;

        if ((init41h_tmp[13:12]==2'b11) && (init40h_tmp[8]==1) && (init40h_tmp[4:0] != 5'b00011) && (init40h_tmp[4:0] < 5'b10000))
             $display(" Attribute Syntax warning : The attribute INIT_40 on SYSMON instance %m is set to %x.  Bit[8] of this attribute must be set to 0. Long acquistion mode is only allowed for external channels", INIT_40);

        if ((init41h_tmp[13:12]!=2'b11) && (init4eh_tmp[10:0]!=11'b0) && (init4eh_tmp[15:12]!=4'b0))
             $display(" Attribute Syntax warning : The attribute INIT_4E on SYSMON instance %m is set to %x.  Bit[15:12] and bit[10:0] of this attribute must be set to 0. Long acquistion mode is only allowed for external channels", INIT_4E);

        if ((init41h_tmp[13:12]==2'b11) && (init40h_tmp[9]==1) && (init40h_tmp[4:0] != 5'b00011) && (init40h_tmp[4:0] < 5'b10000))
             $display(" Attribute Syntax warning : The attribute INIT_40 on SYSMON instance %m is set to %x.  Bit[9] of this attribute must be set to 0. Event mode timing can only be used with external channels, and only in single channel mode.", INIT_40);

        if ((init41h_tmp[13:12]==2'b11) && (init40h_tmp[13:12]!=2'b00) && (INIT_48 != 16'h0000) &&  (INIT_49 != 16'h0000))
             $display(" Attribute Syntax warning : INIT_48 and INIT_49 are %x and %x on SYSMON instance %m. Those attributes must be set to 0000h in single channel mode and averaging enabled.", INIT_48, INIT_49);

        if (init42h_tmp[1:0] != 2'b00) 
             $display(" Attribute Syntax Error : The attribute INIT_42 on SYSMON instance %m is set to %x.  Bit[1:0] of this attribute must be set to 0h.", INIT_42);

        if (SIM_DEVICE == "VIRTEX6") begin
          sim_device_int = 1;
          if (init42h_tmp[15:8] < 8'b00000010) begin 
             $display(" Attribute Syntax Error : The attribute INIT_42 on SYSMON instance %m is set to %x.  Bit[15:8] of this attribute is the ADC Clock divider and must be equal or greater than 2. ", INIT_42);
           $finish;
          end
        end
        else begin
          sim_device_int = 0;
          if (init42h_tmp[15:8] < 8'b00001000) begin 
             $display(" Attribute Syntax Error : The attribute INIT_42 on SYSMON instance %m is set to %x.  Bit[15:8] of this attribute is the ADC Clock divider and must be equal or greater than 8. ", INIT_42);
           $finish;
           end
        end
        
        if (INIT_43 != 16'h0) 
             $display(" Warning : The attribute INIT_43 on SYSMON instance %m is set to %x.  This must be set to 0000h.", INIT_43);
             
        if (INIT_44 != 16'h0) 
             $display(" Warning : The attribute INIT_44 on SYSMON instance %m is set to %x. This must be set to  0000h.", INIT_44);

        if (INIT_45 != 16'h0) 
             $display(" Warning : The attribute INIT_45 on SYSMON instance %m is set to %x.  This must be set to 0000h.", INIT_45);

        if (INIT_46 != 16'h0) 
             $display(" Warning : The attribute INIT_46 on SYSMON instance %m is set to %x.  This must be set to  0000h.", INIT_46);

        if (INIT_47 != 16'h0) 
             $display(" Warning : The attribute INIT_47 on SYSMON instance %m is set to %x.  This must be set to 0000h.", INIT_47);

    end

    initial begin
	dr_sram[7'h40] = INIT_40;
	dr_sram[7'h41] = INIT_41;
	dr_sram[7'h42] = INIT_42;
	dr_sram[7'h43] = INIT_43;
	dr_sram[7'h44] = INIT_44;
	dr_sram[7'h45] = INIT_45;
	dr_sram[7'h46] = INIT_46;
	dr_sram[7'h47] = INIT_47;
	dr_sram[7'h48] = INIT_48;
	dr_sram[7'h49] = INIT_49;
	dr_sram[7'h4A] = INIT_4A;
	dr_sram[7'h4B] = INIT_4B;
	dr_sram[7'h4C] = INIT_4C;
	dr_sram[7'h4D] = INIT_4D;
	dr_sram[7'h4E] = INIT_4E;
	dr_sram[7'h4F] = INIT_4F;
	dr_sram[7'h50] = INIT_50;
	dr_sram[7'h51] = INIT_51;
	dr_sram[7'h52] = INIT_52;
	dr_sram[7'h53] = INIT_53;
	dr_sram[7'h54] = INIT_54;
	dr_sram[7'h55] = INIT_55;
	dr_sram[7'h56] = INIT_56;
	dr_sram[7'h57] = INIT_57;


    end // initial begin

// read input file
    initial begin
	char_1 = 0;
	char_2 = 0;
        time_out = 0;
        sim_file_flag = 0;
        file_line = -1;
        end_of_file = 0;
	fd = $fopen(SIM_MONITOR_FILE, "r"); 
	if  (fd == 0)
        begin
          $display(" *** Warning: The analog data file %s for SYSMON instance %m was not found. Use the SIM_MONITOR_FILE parameter to specify the analog data file name or use the default name: design.txt.\n", SIM_MONITOR_FILE);
          sim_file_flag = 1;
        end
	
      if (sim_file_flag == 0) begin
         while (end_of_file==0) begin
            file_line = file_line + 1;
	    char_1 = $fgetc (fd);
	    char_2 = $fgetc (fd);
//             if(char_2==`EOFile) 
             if(char_2== -1) 
                 end_of_file = 1;
             else begin
	    
	    // Ignore Comments
	    if ((char_1 == "/" & char_2 == "/") | char_1 == "#" | (char_1 == "-" & char_2 == "-")) begin

		fs = $ungetc (char_2, fd);
		fs = $ungetc (char_1, fd);
		fs = $fgets (one_line, fd);

	    end
	    // Getting labels
	    else if ((char_1 == "T" & char_2 == "I" ) ||
                    (char_1 == "T" & char_2 == "i" )  ||
                      (char_1 == "t" & char_2 == "i" ) || (char_1 == "t" & char_2 == "I" ))  begin
		
		fs = $ungetc (char_2, fd);
		fs = $ungetc (char_1, fd);
		fs = $fgets (one_line, fd);

		num_arg = $sscanf (one_line, "%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s", label0, label1, label2, label3, label4, label5, label6, label7, label8, label9, label10, label11, label12, label13, label14, label15, label16, label17, label18, label19, label20, label21, label22, label23, label24, label25, label26, label27, label28, label29, label30,label31, label32, label33, label34, label35, label36, label37, label38, label39);
		
 		label[0] = label0;
		label[1] = label1;
		label[2] = label2;
		label[3] = label3;
		label[4] = label4;
		label[5] = label5;
		label[6] = label6;
		label[7] = label7;
		label[8] = label8;
		label[9] = label9;
 		label[10] = label10;
		label[11] = label11;
		label[12] = label12;
		label[13] = label13;
		label[14] = label14;
		label[15] = label15;
		label[16] = label16;
		label[17] = label17;
		label[18] = label18;
		label[19] = label19;
		label[20] = label20;
		label[21] = label21;
                label[22] = label22;
                label[23] = label23;
                label[24] = label24;
                label[25] = label25;
                label[26] = label26;
                label[27] = label27;
                label[28] = label28;
                label[29] = label29;
                label[30] = label30;
                label[31] = label31;
                label[32] = label32;
                label[33] = label33;
                label[34] = label34;
                label[35] = label35;
                label[36] = label36;
                label[37] = label37;
                label[38] = label38;
                label[39] = label39;
		
		for (m = 0; m < num_arg; m = m +1) begin
                    tmp_label = 96'b0;
                    tmp_label = to_upcase_label(label[m]);
		    case (tmp_label)
			
			"TEMP" : temperature_index = m; 
			"TIME" : time_index = m;
			"VCCAUX" : vccaux_index = m;
			"VCCINT" : vccint_index = m;
			"VN" : vn_index = m;
                        "VAUXN[0]" : vauxn_idx0 = m;
                        "VAUXN[1]" : vauxn_idx1 = m;
                        "VAUXN[2]" : vauxn_idx2 = m;
                        "VAUXN[3]" : vauxn_idx3 = m;
                        "VAUXN[4]" : vauxn_idx4 = m;
                        "VAUXN[5]" : vauxn_idx5 = m;
                        "VAUXN[6]" : vauxn_idx6 = m;
                        "VAUXN[7]" : vauxn_idx7 = m;
                        "VAUXN[8]" : vauxn_idx8 = m;
                        "VAUXN[9]" : vauxn_idx9 = m;
                        "VAUXN[10]" : vauxn_idx10 = m;
                        "VAUXN[11]" : vauxn_idx11 = m;
                        "VAUXN[12]" : vauxn_idx12 = m;
                        "VAUXN[13]" : vauxn_idx13 = m;
                        "VAUXN[14]" : vauxn_idx14 = m;
                        "VAUXN[15]" : vauxn_idx15 = m;
			"VP" : vp_index = m;
                        "VAUXP[0]" : vauxp_idx0 = m;
                        "VAUXP[1]" : vauxp_idx1 = m;
                        "VAUXP[2]" : vauxp_idx2 = m;
                        "VAUXP[3]" : vauxp_idx3 = m;
                        "VAUXP[4]" : vauxp_idx4 = m;
                        "VAUXP[5]" : vauxp_idx5 = m;
                        "VAUXP[6]" : vauxp_idx6 = m;
                        "VAUXP[7]" : vauxp_idx7 = m;
                        "VAUXP[8]" : vauxp_idx8 = m;
                        "VAUXP[9]" : vauxp_idx9 = m;
                        "VAUXP[10]" : vauxp_idx10 = m;
                        "VAUXP[11]" : vauxp_idx11 = m;
                        "VAUXP[12]" : vauxp_idx12 = m;
                        "VAUXP[13]" : vauxp_idx13 = m;
                        "VAUXP[14]" : vauxp_idx14 = m;
                        "VAUXP[15]" : vauxp_idx15 = m;
			default : begin
	              $display("Analog Data File Error : The channel name %s is invalid in the input file for SYSMON instance %m.", tmp_label);
                                      infile_format;
 			          end
		    endcase

		end // for (m = 0; m < num_arg; m = m +1)
		    
	    end
	    // Getting column values
	    else if (char_1 == "0" | char_1 == "1" | char_1 == "2" | char_1 == "3" | char_1 == "4" | char_1 == "5" | char_1 == "6" | char_1 == "7" | char_1 == "8" | char_1 == "9") begin
		
		fs = $ungetc (char_2, fd);
		fs = $ungetc (char_1, fd);
		fs = $fgets (one_line, fd);

		column_real0 = 0.0;
		column_real1 = 0.0;
		column_real2 = 0.0;
		column_real3 = 0.0;
		column_real4 = 0.0;
		column_real5 = 0.0;
		column_real6 = 0.0;
		column_real7 = 0.0;
		column_real8 = 0.0;
		column_real9 = 0.0;
		column_real10 = 0.0;
		column_real11 = 0.0;
		column_real12 = 0.0;
		column_real13 = 0.0;
		column_real14 = 0.0;
		column_real15 = 0.0;
		column_real16 = 0.0;
		column_real17 = 0.0;
		column_real18 = 0.0;
		column_real19 = 0.0;
		column_real20 = 0.0;
		column_real21 = 0.0;
                column_real22 = 0.0;
                column_real23 = 0.0;
                column_real24 = 0.0;
                column_real25 = 0.0;
                column_real26 = 0.0;
                column_real27 = 0.0;
                column_real28 = 0.0;
                column_real29 = 0.0;
                column_real30 = 0.0;
                column_real31 = 0.0;
                column_real32 = 0.0;
                column_real33 = 0.0;
                column_real34 = 0.0;
                column_real35 = 0.0;
                column_real36 = 0.0;
                column_real37 = 0.0;
                column_real38 = 0.0;
                column_real39 = 0.0;
		
		num_val = $sscanf (one_line, "%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f", column_real0, column_real1, column_real2, column_real3, column_real4, column_real5, column_real6, column_real7, column_real8, column_real9, column_real10, column_real11, column_real12, column_real13, column_real14, column_real15, column_real16, column_real17, column_real18, column_real19, column_real20, column_real21, column_real22, column_real23, column_real24, column_real25, column_real26, column_real27, column_real28, column_real29, column_real30, column_real31, column_real32, column_real33, column_real34, column_real35, column_real36, column_real37, column_real38, column_real39);

 		column_real[0] = $realtobits(column_real0);
		column_real[1] = $realtobits(column_real1);
		column_real[2] = $realtobits(column_real2);
		column_real[3] = $realtobits(column_real3);
		column_real[4] = $realtobits(column_real4);
		column_real[5] = $realtobits(column_real5);
		column_real[6] = $realtobits(column_real6);
		column_real[7] = $realtobits(column_real7);
		column_real[8] = $realtobits(column_real8);
		column_real[9] = $realtobits(column_real9);
 		column_real[10] = $realtobits(column_real10);
		column_real[11] = $realtobits(column_real11);
		column_real[12] = $realtobits(column_real12);
		column_real[13] = $realtobits(column_real13);
		column_real[14] = $realtobits(column_real14);
		column_real[15] = $realtobits(column_real15);
		column_real[16] = $realtobits(column_real16);
		column_real[17] = $realtobits(column_real17);
		column_real[18] = $realtobits(column_real18);
		column_real[19] = $realtobits(column_real19);
		column_real[20] = $realtobits(column_real20);
		column_real[21] = $realtobits(column_real21);
                column_real[22] = $realtobits(column_real22);
                column_real[23] = $realtobits(column_real23);
                column_real[24] = $realtobits(column_real24);
                column_real[25] = $realtobits(column_real25);
                column_real[26] = $realtobits(column_real26);
                column_real[27] = $realtobits(column_real27);
                column_real[28] = $realtobits(column_real28);
                column_real[29] = $realtobits(column_real29);
                column_real[30] = $realtobits(column_real30);
                column_real[31] = $realtobits(column_real31);
                column_real[32] = $realtobits(column_real32);
                column_real[33] = $realtobits(column_real33);
                column_real[34] = $realtobits(column_real34);
                column_real[35] = $realtobits(column_real35);
                column_real[36] = $realtobits(column_real36);
                column_real[37] = $realtobits(column_real37);
                column_real[38] = $realtobits(column_real38);
                column_real[39] = $realtobits(column_real39);
		
		chan_val[0] = column_real[temperature_index];
		chan_val[1] = column_real[vccint_index];
		chan_val[2] = column_real[vccaux_index];
		chan_val[3] = column_real[vp_index];
		chan_val[16] = column_real[vauxp_idx0];
		chan_val[17] = column_real[vauxp_idx1];
		chan_val[18] = column_real[vauxp_idx2];
		chan_val[19] = column_real[vauxp_idx3];
		chan_val[20] = column_real[vauxp_idx4];
		chan_val[21] = column_real[vauxp_idx5];
		chan_val[22] = column_real[vauxp_idx6];
		chan_val[23] = column_real[vauxp_idx7];
		chan_val[24] = column_real[vauxp_idx8];
		chan_val[25] = column_real[vauxp_idx9];
		chan_val[26] = column_real[vauxp_idx10];
		chan_val[27] = column_real[vauxp_idx11];
		chan_val[28] = column_real[vauxp_idx12];
		chan_val[29] = column_real[vauxp_idx13];
		chan_val[30] = column_real[vauxp_idx14];
		chan_val[31] = column_real[vauxp_idx15];
		
		chan_valn[3] = column_real[vn_index];
                chan_valn[16] = column_real[vauxn_idx0];
                chan_valn[17] = column_real[vauxn_idx1];
                chan_valn[18] = column_real[vauxn_idx2];
                chan_valn[19] = column_real[vauxn_idx3];
                chan_valn[20] = column_real[vauxn_idx4];
                chan_valn[21] = column_real[vauxn_idx5];
                chan_valn[22] = column_real[vauxn_idx6];
                chan_valn[23] = column_real[vauxn_idx7];
                chan_valn[24] = column_real[vauxn_idx8];
                chan_valn[25] = column_real[vauxn_idx9];
                chan_valn[26] = column_real[vauxn_idx10];
                chan_valn[27] = column_real[vauxn_idx11];
                chan_valn[28] = column_real[vauxn_idx12];
                chan_valn[29] = column_real[vauxn_idx13];
                chan_valn[30] = column_real[vauxn_idx14];
                chan_valn[31] = column_real[vauxn_idx15];

		
		// identify columns
		if (time_index != -1) begin

		    prev_time_out = time_out;
		    time_out = $bitstoreal(column_real[time_index]);
		    
		    if (prev_time_out > time_out) begin
			
			$display("Analog Data File Error : Time value %f is invalid in the input file for SYSMON instance %m. Time value should increase.", time_out);
                        infile_format;
		    end
		    
		end		
		else begin

		    $display("Analog Data File Error : No TIME label is found in the analog data file for SYSMON instance %m.");
                    infile_format;
		    $finish;
		end

		# ((time_out - prev_time_out) * 1000);

		for (p = 0; p < 32; p = p + 1) begin
		    // assign to real before minus - to work around a bug in modelsim
		    chan_val_tmp[p] = chan_val[p];
		    chan_valn_tmp[p] = chan_valn[p];
                    analog_in_tmp = $bitstoreal(chan_val[p])  - $bitstoreal(chan_valn[p]);
		    analog_in_diff[p] = $realtobits(analog_in_tmp);
		    analog_in_uni[p] = chan_val[p];

		end

	    end // if (char_1 == "0" | char_1 == "9")
	    // Ignore any non-comment, label
	    else begin

		fs = $ungetc (char_2, fd);
		fs = $ungetc (char_1, fd);
		fs = $fgets (one_line, fd);    

	    end
	    
	end 
       end // while (end_file == 0)
      end // if (sim_file_flag == 0)
    end // initial begin

    task infile_format;
    begin
    $display("\n***** SYSMON Simulation Analog Data File Format *****\n");
    $display("NAME: design.txt or user file name passed with parameter/generic SIM_MONITOR_FILE\n");
    $display("FORMAT: First line is header line. Valid column name are: TIME TEMP VCCINT VCCAUX VP VN VAUXP[0] VAUXN[0] ..... \n");
    $display("TIME must be in first column.\n");
    $display("Time value need to be integer in ns scale.\n");
    $display("Analog  value need to be real and must contain a decimal point '.' ,  e.g. 0.0, 3.0\n");
    $display("Each line including header line can not have extra space after the last character/digit.\n");
    $display("Each data line must have same number of columns as the header line.\n");
    $display("Comment line start with -- or //\n");
    $display("Example:\n");
    $display("TIME TEMP VCCINT  VP VN VAUXP[0] VAUXN[0]\n");
    $display("000  125.6  1.0  0.7  0.4  0.3  0.6\n");
    $display("200  25.6   0.8  0.5  0.3  0.8  0.2\n");
    end
    endtask  //task infile_format

    function [12*8:1] to_upcase_label;
       input  [12*8:1] in_label;
       reg [8:1] tmp_reg;
    begin

        for (i=0; i< 12; i=i+1) begin

           for (j=1; j<=8; j= j+1)
                tmp_reg[j] = in_label[i*8+j];

           if ((tmp_reg >96) && (tmp_reg<123))
                tmp_reg = tmp_reg -32;

           for (j=1; j<=8; j= j+1)
                to_upcase_label[i*8+j] = tmp_reg[j];

        end
    end
    endfunction

// end read input file

// Check if (Vp+Vn)/2 = 0.5 +/- 100 mv,  unipolar only
    always @( posedge busy_r )
    begin
      if (acq_b_u == 0 && rst_in == 0 && ((acq_chan == 3) || (acq_chan >= 16 && acq_chan <= 31))) begin  
            chan_val_p_tmp = $bitstoreal(chan_val_tmp[acq_chan]);
            chan_val_n_tmp = $bitstoreal(chan_valn_tmp[acq_chan]);

            if ( chan_val_n_tmp > chan_val_p_tmp)
            $display("Input File Warning: The N input for external channel %x must be smaller than P input when in unipolar mode (P=%0.2f N=%0.2f) for SYSMON instance %m at %.3f ns.", acq_chan, chan_val_p_tmp, chan_val_n_tmp, $time/1000.0);
            if ( chan_val_n_tmp > 0.5 || chan_val_n_tmp < 0.0)
            $display("Input File Warning: The range of N input for external channel %x should be between 0V to 0.5V when in unipolar mode (N=%0.2f) for SYSMON instance %m at %.3f ns.", acq_chan, chan_val_n_tmp, $time/1000.0);
      end
    end

  reg seq_reset_busy_out = 0;
  wire rst_in_out;

  always @(posedge dclk_in or posedge rst_in_out)
   if (rst_in_out) begin
      busy_rst <= 1;
      rst_lock <= 1;
      rst_lock_early <= 1;
      busy_rst_cnt <= 0;
   end
   else begin
    if (rst_lock == 1) begin
        if (busy_rst_cnt < 29) begin
           busy_rst_cnt <= busy_rst_cnt + 1;
           if ( busy_rst_cnt == 26)
                 rst_lock_early <= 0;
        end
        else begin
           busy_rst <= 0;
           rst_lock = 0;
        end
     end
   end
  
  initial begin
   busy_out = 0;
   busy_rst = 0;
   busy_conv = 0;
   busy_seq_rst = 0;
   busy_out_tmp = 0;
  end 

   always @(busy_rst or busy_conv or rst_lock)
     if (rst_lock)
         busy_out = busy_rst;
     else
         busy_out = busy_conv;

   always @(posedge dclk_in or posedge rst_in)
     if (rst_in) begin
            busy_conv <= 0;
            cal_chan_update <= 0;
     end
     else begin
        if (seq_reset_flag == 1 && curr_clkdiv_sel <= 8'h03) begin
             busy_conv <= busy_seq_rst; 
         end
         else if (busy_sync_fall)
            busy_conv <= 0;
         else if (busy_sync_rise)
            busy_conv <= 1;
   
         if (conv_count == 21 && curr_chan == 5'b01000)
              cal_chan_update  <= 1;
         else
              cal_chan_update  <= 0;
     end

  always @(posedge dclk_in or rst_lock)
     if (rst_lock) begin
        busy_sync1 <= 0;
        busy_sync2 <= 0;
     end
     else begin
         busy_sync1 <= busy_r;
         busy_sync2 <= busy_sync1;
     end 

  assign busy_sync_fall = (busy_r == 0 && busy_sync1 == 1) ? 1 : 0;
  assign busy_sync_rise = (busy_sync1 == 1 && busy_sync2 == 0 ) ? 1 : 0;

  always @(negedge busy_out or posedge busy_r)
     if (seq_reset_flag == 1 && seq1_0 == 2'b00 && curr_clkdiv_sel <= 8'h03) begin
         @(posedge dclk_in);
         @(posedge dclk_in);
         @(posedge dclk_in);
         @(posedge dclk_in);
         @(posedge dclk_in)
           busy_seq_rst <= 1;
      end
      else if (seq_reset_flag == 1 && seq1_0 != 2'b00 && curr_clkdiv_sel <= 8'h03) begin
         @(posedge dclk_in);
         @(posedge dclk_in);
         @(posedge dclk_in);
         @(posedge dclk_in);
         @(posedge dclk_in)
         @(posedge dclk_in)
         @(posedge dclk_in)
           busy_seq_rst <= 1;
      end
      else
        busy_seq_rst <= 0;


  always @(negedge busy_out or posedge busy_out or posedge rst_in_out or posedge cal_chan_update)
   if (rst_in_out)
         channel_out <= 5'b0;
   else if (busy_out ==1 && (cal_chan_update == 1) )
         channel_out <= 5'b01000;
   else if (busy_out == 0) begin
         channel_out <= curr_chan;  
         curr_chan_lat <= curr_chan;
   end


// START double latch rst_in
    
    reg rst_in1_tmp5;
    reg rst_in2_tmp5;
    reg rst_in1_tmp6;
    reg rst_in2_tmp6;
    reg int_rst;
    wire rst_input_t;
    wire rst_in2;

    initial begin
       int_rst = 1;
       @(posedge dclk_in)
       @(posedge dclk_in)
           int_rst <= 0;
    end

    initial begin
           rst_in1_tmp5 = 0;
           rst_in2_tmp5 = 0;
           rst_in1_tmp6 = 0;
           rst_in2_tmp6 = 0;
    end

    assign #1 rst_input_t = rst_input | int_rst | soft_reset;

    always@(posedge dclk_in or posedge rst_input_t)
      if (sim_device_int == 0) begin
           if (rst_input_t) begin
                   rst_in2_tmp5 <= 1;
                   rst_in1_tmp5 <= 1;
           end
           else begin
                   rst_in2_tmp5 <= rst_in1_tmp5;
                   rst_in1_tmp5 <= rst_input_t;
           end
      end

    
    always@(posedge adcclk or posedge rst_input_t)
      if (sim_device_int == 1) begin
           if (rst_input_t) begin
                   rst_in2_tmp6 <= 1;
                   rst_in1_tmp6 <= 1;
           end
           else begin
                   rst_in2_tmp6 <= rst_in1_tmp6;
                   rst_in1_tmp6 <= rst_input_t;
           end
       end

    
    assign rst_in2 = (sim_device_int == 1) ? rst_in2_tmp6 : rst_in2_tmp5;
    assign #10 rst_in_not_seq = rst_in2;
    assign  rst_in = rst_in_not_seq | seq_reset_dly;
    assign rst_in_out = rst_in_not_seq | seq_reset_busy_out;


    always @(posedge seq_reset) begin
      @(posedge dclk_in);
      @(posedge dclk_in)
       seq_reset_dly <= 1;
      @(posedge dclk_in);
      @(negedge dclk_in)
          seq_reset_busy_out <= 1;
      @(posedge dclk_in)
      @(posedge dclk_in)
      @(posedge dclk_in) begin
        seq_reset_dly <= 0;
          seq_reset_busy_out <= 0;
       end
    end
      
    always @(posedge seq_reset_dly or posedge busy_r)
      if (seq_reset_dly)
          seq_reset_flag <= 1;
      else
         seq_reset_flag <= 0; 

      always @(posedge seq_reset_flag or posedge busy_out)
      if (seq_reset_flag)
          seq_reset_flag_dly <= 1;
      else
         seq_reset_flag_dly <= 0;

      always @(posedge busy_out )
      if (seq_reset_flag_dly == 1 && acq_chan == 5'b01000 && seq1_0 == 2'b00)
         first_cal_chan <= 1;
      else
         first_cal_chan <= 0;
         


    initial begin
       conv_time = 18;   //minus 3
       conv_time_cal_1 = 70;
       conv_time_cal = 70;
       sysclk = 0;
       adcclk_tmp = 0;
       seq_count = 1;
       eos_en = 0;
       eos_tmp_en = 0;
       clk_count = -1;
       acq_acqsel = 0;
       acq_e_c_tmp6 = 0;
       acq_e_c_tmp5 = 0;
       eoc_en = 0;
       eoc_en_delay = 0;
       rst_lock = 0;
       rst_lock_early = 0;
       alarm_update = 0;
       drp_update = 0;
       cal_chan_update = 0;
       adc_state = CONV_STATE;
       scon_tmp = 5'b0;
       busy_r = 0;
       busy_r_rst = 0;
        busy_sync1 = 0;
        busy_sync2 = 0;
       conv_count = 0;
       conv_end = 0;
       seq_status_avg = 0;
       for (i = 0; i <=20; i = i +1)
       begin
            conv_avg_count[i] = 0;   
            conv_acc[j] = 0;
       end
       adc_s1_flag = 0;
       for (k = 0; k <= 31; k = k + 1) 
          data_reg[k] = 16'b0;
       
       seq_count_en = 0;
       eos_out_tmp = 0;
       eoc_out_tmp = 0;
       eos_out_tmp1 = 0;
       eoc_out_tmp1 = 0;
       eos_out = 0;
       eoc_out = 0;
       curr_avg_set = 2'b0;
       curr_e_c = 0;
       curr_b_u = 0;
       curr_acq = 0;
       curr_seq1_0 = 2'b0;
       curr_seq1_0_lat = 2'b0;
       seq1_0 = 2'b0;
       daddr_in_lat = 7'b0;
       data_reg[32] = 16'b0;
       data_reg[33] = 16'b0;
       data_reg[34] = 16'b0;
       data_reg[35] = 16'b0;
       data_reg[36] = 16'b1111111111111111;
       data_reg[37] = 16'b1111111111111111;
       data_reg[38] = 16'b1111111111111111;
       data_reg[39] = 16'b1111111111111111;
       ot_out_reg = 0;
       ot_out = 0;
       alarm_out_reg = 3'b0;
       alarm_out = 3'b0;
       curr_chan =  5'b0;
       curr_chan_lat =  5'b0;
       busy_out = 0;
       busy_out_tmp = 0;
       curr_seq = 16'b0;
       seq_num = 0;
       seq_reset_flag_dly = 0;
       seq_reset_flag = 0;
       seq_reset_dly = 0;
       ot_en = 1;
       alarm_en = 3'b111;
       do_out_rdtmp = 16'b0;
       acq_chan = 5'b0;
       acq_b_u = 0;
       conv_result_int = 0;
       conv_result = 0;
       conv_result_reg = 0;
    end


// state machine
    always @(posedge adcclk or posedge rst_in or sim_file_flag) begin
        if (sim_file_flag == 1'b1)
            adc_state <= INIT_STATE; 
	else if (rst_in == 1'b1 || rst_lock_early == 1)
	    adc_state <= INIT_STATE;
	else if (rst_in == 1'b0)
	    adc_state <= next_state;
    end
    
    always @(adc_state or eos_en or conv_start or conv_end or curr_seq1_0_lat) begin

	case (adc_state)
	    INIT_STATE : next_state = ACQ_STATE;

	    ACQ_STATE : if (conv_start)
				  next_state = CONV_STATE;
		              else
				  next_state = ACQ_STATE;

	    CONV_STATE : if (conv_end)
				   next_state = END_STATE;
			       else
                                   next_state = CONV_STATE;

	    END_STATE : if (curr_seq1_0_lat == 2'b01) begin
				if (eos_en)
				    next_state = SINGLE_SEQ_STATE;
		                else
				    next_state = ACQ_STATE;
			    end
		            else
				next_state = ACQ_STATE;
		        
	    SINGLE_SEQ_STATE : next_state = INIT_STATE;

	    default : next_state = INIT_STATE;

	endcase // case(adc_state)

    end 
    
// end state machine    
    

// DRPORT - SRAM

    initial begin
        drdy_out = 0;
        drdy_out_tmp1 = 0;
        drdy_out_tmp2 = 0;
        drdy_out_tmp3 = 0;
        drdy_out_tmp4 = 0;
        en_data_flag = 0;
        do_out = 16'b0;
        seq_reset = 0;
        cfg_reg1_init = INIT_41;
        seq_en = 0; 
        seq_en_dly = 0;
        seq_en <= #20 (cfg_reg1_init[13:12] != 2'b11 ) ? 1 : 0;
        seq_en <= #150 0;
    end

    always @(posedge drdy_out_tmp3 or posedge gsr_in) 
    if (gsr_in == 1) 
         drdy_out <= 0;
    else begin
      @(posedge dclk_in)
         drdy_out  <= 1;
      @(posedge dclk_in)
         drdy_out <= 0;
    end

    always @(posedge dclk_in or posedge gsr_in) 

     if (gsr_in == 1) begin
         drdy_out <= 0;
         daddr_in_lat  <= 7'b0;
         do_out <= 16'b0;
     end
     else  begin
        if (den_in == 1) begin
          if (drdy_out_tmp1 == 0) begin
             drdy_out_tmp1 <= 1'b1;
             en_data_flag = 1;
             daddr_in_lat  <= daddr_in;
          end
          else begin
             if (daddr_in != daddr_in_lat) 
             $display("Warning : input pin DEN on SYSMON instance %m at time %.3f ns can not continue set to high. Need wait DRDY high and then set DEN high again.", $time/1000.0);  
          end
        end
        else
           drdy_out_tmp1 <= 0;

        drdy_out_tmp2 <= drdy_out_tmp1;
        drdy_out_tmp3 <= drdy_out_tmp2;
        drdy_out_tmp4 <= drdy_out_tmp3;

        if (drdy_out_tmp1 == 1)
            en_data_flag = 0;

        if (drdy_out_tmp3 == 1) 
            do_out <= do_out_rdtmp;

        if (sim_device_int == 1) begin
           if (den_in == 1 && (daddr_in >7'h58 || (daddr_in >= 7'h27 && daddr_in < 7'h3F)))
        $display("Invalid Input Warning : The DADDR %x to SYSMON instance %m at time %.3f ns is accessing an undefined location. The data in this location is invalid.", daddr_in, $time/1000.0);
        end
        else begin
           if (den_in == 1 && (daddr_in >7'h58 || (daddr_in >= 7'h0d && daddr_in <= 7'h0f)
                || (daddr_in >= 7'h27 && daddr_in <= 7'h3F)))
        $display("Invalid Input Warning : The DADDR %x to SYSMON instance %m at time %.3f ns is accessing an undefined location. The data in this location is invalid.", daddr_in, $time/1000.0);
        end
    
// write  all available daddr addresses

        if (dwe_in == 1'b1 && en_data_flag == 1) begin

          dr_sram[daddr_in] <= di_in;
        
          if (sim_device_int == 1) begin
            if (daddr_in == 7'h03)
                 soft_reset <= 1;

            if ( daddr_in == 7'h53) begin
                 if (di_in[3:0] == 4'b0011)
                    ot_limit_reg[15:4] <= di_in[15:4];
                 else
                    ot_limit_reg <= 16'hCA00;
             end
          end

          if (sim_device_int == 1) begin
            if ( daddr_in == 7'h42 && (di_in[2:0] !=3'b000)) 
                $display(" Invalid Input Error : The DI bit[2:0] %x at DADDR %x on SYSMON instance %m at %.3f ns is invalid. These must be set to 000.", di_in[2:0], daddr_in, $time/1000.0);
          end
          else begin
            if ( daddr_in == 7'h42 && (di_in[1:0] !=2'b00)) 
                $display(" Invalid Input Error : The DI bit[1:0] %x at DADDR %x on SYSMON instance %m at %.3f ns is invalid. These must be set to 00.", di_in[1:0], daddr_in, $time/1000.0);
          end

          if (sim_device_int == 0) begin
            if (daddr_in == 7'h42 && (di_in[15:8] < 8'b00001000)) begin
             $display(" Invalid Input Error : The  DI bit[15:8] %x at DADDR %x on SYSMON instance %m  at %.3f ns is invalid. Bit[15:8] of Control Register 42h is the ADC Clock divider and must be equal or greater than 8. ", di_in[15:8], daddr_in, $time/1000.0);
               $finish;
             end
           end

          if ( daddr_in >= 7'h43 && daddr_in <= 7'h47 && (di_in[15:0] != 16'h0000)) 
		$display(" Invalid Input Error : The DI value %x at DADDR %x of SYSMON instance %m at %.3f ns is invalid. These must be set to 0000h.", di_in, daddr_in, $time/1000.0);

          if ((daddr_in == 7'h40) && (di_in[4:0] == 5'b00110  || di_in[4:0] == 5'b00111
                         || (di_in[4:0] >= 5'b01010 && di_in[4:0] <= 5'b01111))) 
		$display("Invalid Input Warning : The DI bit4:0] at address DADDR %x to SYSMON instance %m at %.3f ns is %h, which is invalid analog channel.", daddr_in, $time/1000.0, di_in[4:0]);

          if (daddr_in == 7'h40) begin
            if ((cfg_reg1[13:12]==2'b11) && (di_in[8]==1) && (di_in[4:0] != 5'b00011) && (di_in[4:0] < 5'b10000))
             $display(" Invalid Input warning : The DI value is %x at DADDR %x on SYSMON instance %m at %.3f ns.  Bit[8] of DI must be set to 0. Long acquistion mode is only allowed for external channels", di_in, daddr_in, $time/1000.0);

          if ((cfg_reg1[13:12]==2'b11) && (di_in[9]==1) && (di_in[4:0] != 5'b00011) && (di_in[4:0] < 5'b10000))
             $display(" Invalid Input warning : The DI value is %x at DADDR %x on SYSMON instance %m at %.3f ns.  Bit[9] of DI must be set to 0. Event mode timing can only be used with external channels", di_in, daddr_in, $time/1000.0);

          if ((cfg_reg1[13:12]==2'b11) && (di_in[13:12]!=2'b00) && (seq_chan_reg1 != 16'h0000) &&  (seq_chan_reg2 != 16'h0000))
             $display(" Invalid Input warning : The  Control Regiter 48h and 49h are %x and %x on SYSMON instance %m at %.3f ns. Those registers should be set to 0000h in single channel mode and averaging enabled.", seq_chan_reg1, seq_chan_reg2, $time/1000.0);

         end

         if (daddr_in == 7'h41 && en_data_flag == 1) begin
           if ((di_in[13:12]==2'b11) && (cfg_reg0[8]==1) && (cfg_reg0[4:0] != 5'b00011) && (cfg_reg0[4:0] < 5'b10000))
             $display(" Invalid Input warning : The  Control Regiter 40h value is %x on SYSMON instance %m at %.3f ns.  Bit[8] of Control Regiter 40h  must be set to 0. Long acquistion mode is only allowed for external channels", cfg_reg0, $time/1000.0);

           if ((di_in[13:12]==2'b11) && (cfg_reg0[9]==1) && (cfg_reg0[4:0] != 5'b00011) && (cfg_reg0[4:0] < 5'b10000))
             $display(" Invalid Input warning : The  Control Regiter 40h value is %x on SYSMON instance %m at %.3f ns.  Bit[9] of Control Regiter 40h  must be set to 0. Event mode timing can only be used with external channels", cfg_reg0, $time/1000.0);

           if ((di_in[13:12]!=2'b11) && (seq_acq_reg1[10:0]!=11'b0) && (seq_acq_reg1[15:12]!=4'b0))
             $display(" Invalid Input warning : The Control Regiter 4Eh value is %x on SYSMON instance %m at %.3f ns.  Bit[15:12] and bit[10:0] of this register must be set to 0. Long acquistion mode is only allowed for external channels", seq_acq_reg1, $time/1000.0);

           if ((di_in[13:12]==2'b11) && (cfg_reg0[13:12]!=2'b00) && (seq_chan_reg1 != 16'h0000) &&  (seq_chan_reg2 != 16'h0000))
             $display(" Invalid Input warning : The  Control Regiter 48h and 49h are %x and %x on SYSMON instance %m at %.3f ns. Those registers should be set to 0000h in single channel mode and averaging enabled.", seq_chan_reg1, seq_chan_reg2, $time/1000.0);

      end
		
      if (daddr_in == 7'h41  && en_data_flag == 1) begin
	     if (den_in == 1'b1 && dwe_in == 1'b1) begin
          if (di_in[13:12] != cfg_reg1[13:12])
			    seq_reset <= 1'b1;
		    else
			    seq_reset <= 1'b0;

		    if (di_in[13:12] != 2'b11 )
			    seq_en <= 1'b1;
		    else
			    seq_en <= 1'b0;
	     end
        else  begin
			 seq_reset <= 1'b0;
			 seq_en <= 1'b0;
	     end
      end
//	   else  begin
//	     seq_reset <= 0;
//	     seq_en <= 0;
//	   end // if (daddr_in == 7'h41)
     end // dwe ==1			

     if (seq_en == 1) 
         seq_en <= 1'b0;
     if (seq_reset == 1)
			seq_reset <= 1'b0;
     if (soft_reset == 1)
         soft_reset <= 0;

   end // if (gsr == 1)
		

// DO bus data out


   assign  tmp_dr_sram_out = ( daddr_in_lat >= 7'h40 && daddr_in_lat <= 7'h57) ? 
                                                      dr_sram[daddr_in_lat] : 16'b0;

//   assign status_reg = {12'b0, ot_out, alarm_out[2:0]};
   assign status_reg = {12'b0, ot_out, 3'b000};

   assign tmp_data_reg_out = (daddr_in_lat >= 7'h00 && daddr_in_lat <= 7'h26) ?
                                                      data_reg[daddr_in_lat] : 16'b0;

   always @( daddr_in_lat or  tmp_data_reg_out or tmp_dr_sram_out or status_reg ) begin
     if ((daddr_in_lat >7'h58 || (daddr_in_lat>= 7'h0d && daddr_in_lat <= 7'h0f)
                || (daddr_in_lat >= 7'h27 && daddr_in_lat < 7'h3F))) begin
		   do_out_rdtmp = 16'bx;
     end
   
     if (daddr_in_lat == 7'h3F) begin
       if (sim_device_int == 1)
            do_out_rdtmp = status_reg;
        else
            do_out_rdtmp = 16'bx;
     end

     if ((daddr_in_lat >= 7'h00 && daddr_in_lat <= 7'h0C) || 
           (daddr_in_lat >= 7'h10 && daddr_in_lat <= 7'h26)) 
	   	do_out_rdtmp = tmp_data_reg_out;
	  else if (daddr_in_lat >= 7'h40 && daddr_in_lat <= 7'h57)
	      do_out_rdtmp = tmp_dr_sram_out;
   end

// end DRP RAM

    
     assign cfg_reg0 = dr_sram[7'h40];
     assign cfg_reg1 = dr_sram[7'h41];
     assign cfg_reg2 = dr_sram[7'h42];
     assign seq_chan_reg1 = dr_sram[7'h48];
     assign seq_chan_reg2 = dr_sram[7'h49];
     assign seq_avg_reg1 = dr_sram[7'h4A];
     assign seq_avg_reg2 = dr_sram[7'h4B];
     assign seq_du_reg1 = dr_sram[7'h4C];
     assign seq_du_reg2 = dr_sram[7'h4D];
     assign seq_acq_reg1 = dr_sram[7'h4E];
     assign seq_acq_reg2 = dr_sram[7'h4F];
 
    always @(cfg_reg1)
        seq1_0 = cfg_reg1[13:12];

    always @(posedge drp_update or posedge rst_in) 
    begin
      if (rst_in) begin
           @(posedge dclk_in)
           @(posedge dclk_in)
               seq_bits = seq1_0;
       end
       else
           seq_bits = curr_seq1_0;
  
      if (seq_bits == 2'b00) begin
         alarm_en <= 3'b000;
         ot_en <= 1;
      end
      else begin
         ot_en  <= ~cfg_reg1[0];
         alarm_en <= ~cfg_reg1[3:1];
      end
   end

// end DRPORT - sram    
    
// Clock divider, generate  and adcclk

    always @(posedge dclk_in)
      sysclk <= ~sysclk;

   always @(posedge dclk_in) 
	if (curr_clkdiv_sel > 8'b00000010 ) begin
	    if (clk_count >= curr_clkdiv_sel - 1) 
		    clk_count = 0;
        else 
		    clk_count = clk_count + 1;

	    if (clk_count > (curr_clkdiv_sel/2) - 1)
               adcclk_tmp <= 1;
            else
               adcclk_tmp <= 0;
	end 
   else 
             adcclk_tmp <= ~adcclk_tmp;

       assign curr_clkdiv_sel = cfg_reg2[15:8];
       assign adcclk_div1 = (curr_clkdiv_sel > 8'b00000010) ? 0 : 1;
       assign adcclk = (adcclk_div1) ? ~sysclk : adcclk_tmp;

// end clock divider	
	  
// latch configuration registers
  wire [15:0] cfg_reg0_seq, cfg_reg0_adc;
  reg [15:0] cfg_reg0_seq_tmp5, cfg_reg0_adc_tmp5;
  reg [15:0] cfg_reg0_seq_tmp6, cfg_reg0_adc_tmp6;
  reg [1:0]  acq_avg;

  always @( seq1_0 or adc_s1_flag or curr_seq or cfg_reg0_adc or rst_in) begin
    if ((seq1_0 == 2'b01 && adc_s1_flag == 0) || seq1_0 == 2'b10) begin
		acq_acqsel = curr_seq[8];
    end
    else if (seq1_0 == 2'b11) begin
                acq_acqsel = cfg_reg0_adc [8];
    end
    else begin
//                acq_e_c = 0;
                acq_acqsel = 0;
    end

    if (rst_in == 0) begin
        if (seq1_0 != 2'b11 && adc_s1_flag == 0) begin
            acq_avg  = curr_seq[13:12];
            acq_chan = curr_seq[4:0];
            acq_b_u = curr_seq[10];
        end
        else begin
            acq_avg  = cfg_reg0_adc[13:12];
            acq_chan = cfg_reg0_adc[4:0];
            acq_b_u = cfg_reg0_adc[10];
        end
     end
   end

    reg single_chan_conv_end;
    reg [3:0] conv_end_reg_read;
    reg busy_reg_read;
    reg first_after_reset_tmp5;
    reg first_after_reset_tmp6;

    always@(posedge adcclk or posedge rst_in)
        begin
            if(rst_in) conv_end_reg_read <= 4'b0;
            else       conv_end_reg_read <= {conv_end_reg_read[2:0], single_chan_conv_end | conv_end};
        end
        
    always@(posedge DCLK or posedge rst_in)
        begin
                if(rst_in) busy_reg_read <= 1;
                else       busy_reg_read <= ~conv_end_reg_read[2];
        end

    assign cfg_reg0_adc = (sim_device_int == 1) ? cfg_reg0_adc_tmp6 : cfg_reg0_adc_tmp5;
    assign cfg_reg0_seq = (sim_device_int == 1) ? cfg_reg0_seq_tmp6 : cfg_reg0_seq_tmp5;
    assign acq_e_c = (sim_device_int == 1) ? acq_e_c_tmp6 : acq_e_c_tmp5;

    always @(negedge busy_reg_read or rst_in)
      if (sim_device_int == 0) begin
           if(rst_in) begin
                        cfg_reg0_seq_tmp5 <= 16'b0;
                        cfg_reg0_adc_tmp5 <= 16'b0;
                        acq_e_c_tmp5 <= 0;
                        first_after_reset_tmp5 <= 1;
            end
            else begin
                        repeat(3) @(posedge DCLK);
                        if(first_after_reset_tmp5) begin
                           first_after_reset_tmp5<=0;
                           cfg_reg0_adc_tmp5 <= cfg_reg0;
                           cfg_reg0_seq_tmp5 <= cfg_reg0;
                        end
                        else begin
                           cfg_reg0_adc_tmp5 <= cfg_reg0_seq;
                           cfg_reg0_seq_tmp5 <= cfg_reg0;
                        end
                        acq_e_c_tmp5      <= cfg_reg0[9];
              end
       end

    always @(negedge busy_out or rst_in)
       if (sim_device_int == 1) begin
           if(rst_in) begin
                        cfg_reg0_seq_tmp6 <= 16'b0;
                        cfg_reg0_adc_tmp6 <= 16'b0;
                        acq_e_c_tmp6 <= 0;
                        first_after_reset_tmp6 <= 1;
            end
            else begin
                        repeat(3) @(posedge DCLK);
                        if(first_after_reset_tmp6) begin
                           first_after_reset_tmp6<=0;
                           cfg_reg0_adc_tmp6 <= cfg_reg0;
                           cfg_reg0_seq_tmp6 <= cfg_reg0;
                        end
                        else begin
                           cfg_reg0_adc_tmp6 <= cfg_reg0_seq;
                           cfg_reg0_seq_tmp6 <= cfg_reg0;
                        end
                        acq_e_c_tmp6      <= cfg_reg0[9];
              end
       end

    always @(posedge conv_start or  posedge busy_r_rst or posedge rst_in) 
         if (rst_in ==1)
            busy_r <= 0;
         else if (conv_start && rst_lock == 0)
            busy_r <= 1;
         else if (busy_r_rst)
           busy_r <= 0;
   
    always @(negedge busy_out )
            if (adc_s1_flag == 1)
                curr_seq1_0 <= 2'b00;
            else
                curr_seq1_0 <= seq1_0;

   always @(posedge conv_start or posedge rst_in ) begin
	if (rst_in == 1) begin
	    analog_mux_in <= 0.0;
            curr_chan <= 5'b0;
	end
	else  begin
            if ((acq_chan == 5'b00011) || (acq_chan >= 5'b10000 && acq_chan <= 5'b11111)) 
	    analog_mux_in <= $bitstoreal(analog_in_diff[acq_chan]); 
            else
              analog_mux_in <= $bitstoreal(analog_in_uni[acq_chan]);

            curr_chan <= acq_chan;
            curr_seq1_0_lat <= curr_seq1_0;

	    
	    if (acq_chan == 5'b00110 || acq_chan == 5'b00111  || (acq_chan >= 5'b01010 && acq_chan <= 5'b01111))
		$display("Invalid Input Warning : The analog channel %x to SYSMON instance %m at %.3f ns is invalid.", acq_chan, $time/1000.0);
	
	    
	    if ((seq1_0 == 2'b01 && adc_s1_flag == 0) || seq1_0 == 2'b10 || seq1_0 == 2'b00) begin
		
                curr_avg_set <= curr_seq[13:12];
                curr_b_u <= curr_seq[10];
                curr_e_c <= 0;
                curr_acq <= curr_seq[8];
	    end
            else  begin
                curr_avg_set <= acq_avg;
                curr_b_u <= acq_b_u;
		curr_e_c <= cfg_reg0[9];
		curr_acq <= cfg_reg0[8];
            end

	end // if (rst_in == 0)

   end // always @ (posedge conv_start or posedge rst_in)
    
	
// end latch configuration registers
    
// sequence control

    always @(seq_en )
          seq_en_dly <= #1 seq_en;


    always @(posedge  seq_en_dly) 
    if (seq1_0  == 2'b01 || seq1_0 == 2'b10) begin
       seq_num = 0;
       for (si=0; si<= 15; si=si+1) begin
           if (seq_chan_reg1[si] ==1)  begin
                seq_num = seq_num + 1;
                  seq_mem[seq_num] = si;
           end
       end
       for (si=16; si<= 31; si=si+1) begin
           if (seq_chan_reg2[si-16] ==1) begin
                seq_num = seq_num + 1;
                seq_mem[seq_num] = si;
           end
       end
    end
    else if (seq1_0  == 2'b00) begin
      seq_num = 4;
      seq_mem[1] = 0;
      seq_mem[2] = 8;
      seq_mem[3] = 9;
      seq_mem[4] = 10;
    end
              

    always @( seq_count  or negedge seq_en_dly) begin
        seq_curr_i = seq_mem[seq_count];
         curr_seq = 16'b0;
        if (seq_curr_i >= 0 && seq_curr_i <= 15) begin
           curr_seq [2:0] =  seq_curr_i[2:0];
           curr_seq [4:3] = 2'b01;
           curr_seq [8] = seq_acq_reg1[seq_curr_i];
           curr_seq [10] = seq_du_reg1[seq_curr_i];

           if (seq1_0 == 2'b00)
              curr_seq [13:12] = 2'b01;
           else if (seq_avg_reg1[seq_curr_i] == 1)
              curr_seq [13:12] = cfg_reg0[13:12];
           else
              curr_seq [13:12] = 2'b00;

           if (seq_curr_i >= 0 && seq_curr_i <=7) 
              curr_seq [4:3] = 2'b01;
           else
              curr_seq [4:3] = 2'b00;
        end
        else if (seq_curr_i >= 16 && seq_curr_i <= 31) begin
           curr_seq [4:0] = seq_curr_i;
           curr_seq [8] = seq_acq_reg2[seq_curr_i - 16];
           curr_seq [10] = seq_du_reg2[seq_curr_i - 16];
           if (seq_avg_reg2[seq_curr_i - 16] == 1)
              curr_seq [13:12] = cfg_reg0[13:12];
           else
              curr_seq [13:12] = 2'b00;
        end
    end

   always @(posedge adcclk or posedge rst_in) 
	if (rst_in == 1) begin
	    seq_count <= 1;
	    eos_en <= 0;
	end
	else  begin
	    if ((seq_count == seq_num  ) && (adc_state == CONV_STATE && next_state == END_STATE) && (curr_seq1_0_lat != 2'b11) && rst_lock == 0)
		eos_tmp_en <= 1;
	    else
		eos_tmp_en <= 0;

            if (eos_tmp_en == 1 && seq_status_avg == 0 ) // delay by 1 adcclk
                eos_en <= 1;
            else
                eos_en <= 0;


	    if (eos_tmp_en == 1 || curr_seq1_0_lat == 2'b11  )
		seq_count <= 1;
	    else if (seq_count_en == 1) begin
               if (seq_count >= 32)
                 seq_count <= 1;
               else
		seq_count <= seq_count +1;
            end
		
	end // else: !if(rst_in == 1)
    
// end sequence control
    
// Acquisition
       reg first_acq;
       reg shorten_acq;
       wire busy_out_dly;

       assign #10 busy_out_dly = busy_out;

        always @(adc_state or posedge rst_in or first_acq) 
        begin
                if(rst_in) shorten_acq = 0;
                else if(busy_out_dly==0 && adc_state==ACQ_STATE && first_acq==1)
                        shorten_acq = 1;
                else
                        shorten_acq = 0;
        end


   always @(posedge adcclk or posedge rst_in)
	if (rst_in == 1) begin
	    acq_count <= 1;
            first_acq <=1;
        end
	else  begin 
	    if (adc_state == ACQ_STATE && rst_lock == 0 && (acq_e_c==0)) begin
                first_acq <= 0;

		if (acq_acqsel == 1) begin
		    if (acq_count <= 11)
			acq_count <= acq_count + 1 + shorten_acq;
		end
		else begin
		    if (acq_count <= 4)
			acq_count <= acq_count + 1 + shorten_acq;
		end // else: !if(acq_acqsel == 1)
             
		if (next_state == CONV_STATE)
		    if ((acq_acqsel == 1 && acq_count < 10) || (acq_acqsel == 0 && acq_count < 4))
			$display ("Warning: Acquisition time is not long enough for SYSMON instance %m at time %t.", $time);
	    end // if (adc_state == ACQ_STATE)
	    else
		acq_count <=  (first_acq) ? 1 : 0;

	end // if (rst_in == 0)

// continuous mode
   reg  conv_start_cont;
   wire reset_conv_start;
   wire conv_start_sel;

   always @(adc_state or acq_acqsel or acq_count)
        if (adc_state == ACQ_STATE) begin
        if (rst_lock == 0) begin
                if (    ((seq_reset_flag == 0 || (seq_reset_flag == 1 && curr_clkdiv_sel > 8'h03))
             && ( (acq_acqsel == 1 && acq_count > 10) || (acq_acqsel == 0 && acq_count > 4)) ) )
                    conv_start_cont = 1;
                else
                    conv_start_cont = 0;
        end
        end // if (adc_state == ACQ_STATE)
        else
            conv_start_cont = 0;

        assign conv_start_sel = (acq_e_c) ? convst_in : conv_start_cont;

        assign reset_conv_start = rst_in | (conv_count==2);

        always@(posedge conv_start_sel or posedge reset_conv_start)
        begin
                if(reset_conv_start) conv_start <= 0;
                else                 conv_start <= 1;
        end


// end acquisition    
    
// Conversion
   always @(adc_state or next_state or curr_chan  or analog_mux_in or curr_b_u) begin

	if ((adc_state == CONV_STATE && next_state == END_STATE) ||  adc_state == END_STATE) begin
	    if (curr_chan == 0) begin    // temperature conversion
		    adc_temp_result = (analog_mux_in + 273.0) * 0.001984226*65536;
		    if (adc_temp_result >= 65535.0)
			conv_result_int = 65535;
		    else if (adc_temp_result < 0.0)
			conv_result_int = 0;
		    else begin
			conv_result_int = $rtoi(adc_temp_result);
			if (adc_temp_result - conv_result_int > 0.9999)
			    conv_result_int = conv_result_int + 1;
		    end
	    end
	    else if (curr_chan == 1 || curr_chan == 2) begin     // internal power conversion
		    adc_intpwr_result = analog_mux_in * 65536.0 / 3.0;
		    if (adc_intpwr_result >= 65535.0)
			conv_result_int = 65535;
		    else if (adc_intpwr_result < 0.0)
			conv_result_int = 0;
		    else begin
			conv_result_int = $rtoi(adc_intpwr_result);
			if (adc_intpwr_result - conv_result_int > 0.9999)
			    conv_result_int = conv_result_int + 1;
		    end
	    end
	    else if (curr_chan == 3 || (curr_chan >=16 && curr_chan <= 31)) begin

                    adc_ext_result =  (analog_mux_in) * 65536.0;
		    if (curr_b_u == 1) begin
                        if (adc_ext_result > 32767.0)
                             conv_result_int = 32767;
                        else if (adc_ext_result < -32768.0)
                             conv_result_int = -32768;
                        else begin
                             conv_result_int = $rtoi(adc_ext_result);
                             if (adc_ext_result - conv_result_int > 0.9999)
                                conv_result_int = conv_result_int + 1;
                        end
                    end
                    else begin
                       if (adc_ext_result > 65535.0)
                             conv_result_int = 65535;
                        else if (adc_ext_result < 0.0)
                             conv_result_int = 0;
                        else begin
                             conv_result_int = $rtoi(adc_ext_result);
                             if (adc_ext_result - conv_result_int > 0.9999)
                                conv_result_int = conv_result_int + 1;
                        end
                    end
            end
            else begin
                conv_result_int = 0;
            end
	end 

        conv_result = conv_result_int;
	
    end // always @ ( adc_state or curr_chan or analog_mux_in, curr_b_u)
    
    reg busy_r_rst_done;
    
   always @(posedge adcclk or  posedge rst_in) 
	if (rst_in == 1) begin
	    conv_count <= 6;
	    conv_end <= 0;
	    seq_status_avg <= 0;
                busy_r_rst <= 0;        
                busy_r_rst_done <= 0;
	    for (i = 0; i <=31; i = i +1)
		conv_avg_count[i] <= 0;     // array of integer
            single_chan_conv_end <= 0;
	end
	else  begin
               if(adc_state == ACQ_STATE)
                begin
                        if(busy_r_rst_done == 0) busy_r_rst <= 1;
                else                             busy_r_rst <= 0;
                        busy_r_rst_done <= 1;
                end

	    if (adc_state == ACQ_STATE && conv_start == 1) begin
		conv_count <= 0;
		conv_end <= 0;
	    end
	    else if (adc_state == CONV_STATE ) begin
                busy_r_rst_done <= 0;
                
		conv_count = conv_count + 1;
               
		if ((curr_chan != 5'b01000 ) && (conv_count == conv_time ) ||
              (curr_chan == 5'b01000 ) && (conv_count == conv_time_cal_1 ) && (first_cal_chan==1)
              || (curr_chan == 5'b01000 ) && (conv_count == conv_time_cal) && (first_cal_chan == 0))
		    conv_end <= 1;
		else
		    conv_end <= 0;
	    end
	    else begin
		conv_end <= 0;
		conv_count <= 0;
	    end
                // jmcgrath - to model the behaviour correctly when a cal chanel is being converted
                // an signal to signify the conversion has ended must be produced - this is for single channel mode
                single_chan_conv_end <= 0;
                if( (conv_count == conv_time) || (conv_count == 44))
                        single_chan_conv_end <= 1;


	    if (adc_state == CONV_STATE && next_state == END_STATE && rst_lock == 0) begin
		case (curr_avg_set)
		    2'b00 : begin
			        eoc_en <= 1;
			        conv_avg_count[curr_chan] <= 0;
			    end
		    2'b01 : begin
			        if (conv_avg_count[curr_chan] == 15) begin
			            eoc_en <= 1;
			            conv_avg_count[curr_chan] <= 0;
				    seq_status_avg <= seq_status_avg - 1;
				end
			        else begin
				    eoc_en <= 0;
				    if (conv_avg_count[curr_chan] == 0)
					seq_status_avg <= seq_status_avg + 1;
				    
				    conv_avg_count[curr_chan] <= conv_avg_count[curr_chan] + 1;
				end
		            end
		    2'b10 : begin
			        if (conv_avg_count[curr_chan] == 63) begin
			            eoc_en <= 1;
			            conv_avg_count[curr_chan] <= 0;
				    seq_status_avg <= seq_status_avg - 1;
				end
			        else begin
				    eoc_en <= 0;
				    if (conv_avg_count[curr_chan] == 0)
					seq_status_avg <= seq_status_avg + 1;
				    
				    conv_avg_count[curr_chan] <= conv_avg_count[curr_chan] + 1;
				end
		             end
		    2'b11 : begin
			        if (conv_avg_count[curr_chan] == 255) begin
			            eoc_en <= 1;
			            conv_avg_count[curr_chan] <= 0;
				    seq_status_avg <= seq_status_avg - 1;
				end
			        else begin
				    eoc_en <= 0;
				    if (conv_avg_count[curr_chan] == 0)
					seq_status_avg <= seq_status_avg + 1;
				    
				    conv_avg_count[curr_chan] <= conv_avg_count[curr_chan] + 1;
				end
		             end
		    default : eoc_en <= 0;
		endcase // case(curr_avg_set)
	    end // if (adc_state == CONV_STATE && next_state == END_STATE)
	    else 
		eoc_en <= 0;
	    
	    if (adc_state == END_STATE)
		   conv_result_reg <= conv_result;

	end // if (rst_in == 0)
    
// end conversion

    
// average
   always @(adc_state or conv_acc[curr_chan]) 
	if (adc_state == END_STATE ) 
	    // no signed or unsigned differences for bit vector conv_acc_vec
	    conv_acc_vec = conv_acc[curr_chan];
	else
	    conv_acc_vec = 24'b00000000000000000000;


    always @(posedge adcclk or posedge rst_in) 
	if (rst_in == 1) begin
	    for (j = 0; j <= 31; j = j + 1)
		conv_acc[j] <= 0;
	    conv_acc_result <= 16'b0000000000000000;
	end
	else  begin
	    if (adc_state == CONV_STATE && next_state == END_STATE) begin
		if (curr_avg_set != 2'b00 && rst_lock != 1)
                    conv_acc[curr_chan] <= conv_acc[curr_chan] + conv_result_int;
		else
		    conv_acc[curr_chan] <= 0;
	    end
	    else if (eoc_en == 1) begin
		case (curr_avg_set)
                    2'b00 : conv_acc_result <= 16'b0000000000000000;
                    2'b01 : conv_acc_result <= conv_acc_vec[19:4];
                    2'b10 : conv_acc_result <= conv_acc_vec[21:6];
                    2'b11 : conv_acc_result <= conv_acc_vec[23:8];
		endcase // case(curr_avg_set)

		conv_acc[curr_chan] <= 0;

	    end // if (eoc_en == 1)
	end // if (rst_in == 0)
        
// end average    
		
// single sequence
    always @(posedge adcclk or posedge rst_in) 
	if (rst_in == 1)
	    adc_s1_flag <= 0;
	else  
	    if (adc_state == SINGLE_SEQ_STATE)
		adc_s1_flag <= 1;

//  end state    
    always @(posedge adcclk or posedge rst_in)
	if (rst_in == 1) begin
	    seq_count_en <= 0;
	    eos_out_tmp <= 0;
	    eoc_out_tmp <= 0;
	end 
	else  begin
	    if ((adc_state == CONV_STATE && next_state == END_STATE) && (curr_seq1_0_lat != 2'b11) && (rst_lock == 0))
		seq_count_en <= 1;
	    else
		seq_count_en <= 0;
	    
            if (rst_lock == 0) begin
	         eos_out_tmp <= eos_en;
	         eoc_en_delay <= eoc_en;
	         eoc_out_tmp <= eoc_en_delay;
            end 
            else begin
                 eos_out_tmp <= 0;
                 eoc_en_delay <= 0;
                 eoc_out_tmp <= 0;
            end
        end

    always @(posedge eoc_out or posedge rst_in_not_seq) 
	if (rst_in_not_seq == 1) begin
	    for (k = 32; k <= 39; k = k + 1)
		if (k >= 36)
		    data_reg[k] <= 16'b1111111111111111;
		else
		    data_reg[k] <= 16'b0000000000000000;
	end 
	else 
	    if ( rst_lock == 0) begin
		if ((curr_chan >= 0 && curr_chan <= 3)  || (curr_chan >= 16 && curr_chan <= 31)) begin
		    if (curr_avg_set == 2'b00)
			data_reg[curr_chan] <= conv_result_reg;
		    else
			data_reg[curr_chan] <= conv_acc_result;
		end
                if (curr_chan == 4)
                        data_reg[curr_chan] <= 16'hD555;
                if (curr_chan == 5)
                        data_reg[curr_chan] <= 16'h0000;
               
		if (curr_chan == 0 || curr_chan == 1 || curr_chan == 2) begin
		    if (curr_avg_set == 2'b00) begin
			if (conv_result_reg > data_reg[32 + curr_chan])
			    data_reg[32 + curr_chan] <= conv_result_reg;
			if (conv_result_reg < data_reg[36 + curr_chan])
			    data_reg[36 + curr_chan] <= conv_result_reg;
		    end
		    else begin
			if (conv_acc_result > data_reg[32 + curr_chan])
			    data_reg[32 + curr_chan] <= conv_acc_result;
			if (conv_acc_result < data_reg[36 + curr_chan])
			    data_reg[36 + curr_chan] <= conv_acc_result;
	            end	
	        end 
	   end 

   reg [15:0] data_written;
   always @(negedge busy_r or posedge rst_in_not_seq)
        if (rst_in_not_seq)
            data_written <= 16'b0;
        else begin
           if (curr_avg_set == 2'b00) data_written <= conv_result_reg;
           else                               data_written <= conv_acc_result;
        end


    reg [3:0] op_count=15;
    reg       busy_out_sync;
    wire      busy_out_low_edge;
    
// eos and eoc

    always @( posedge eoc_out_tmp or posedge eoc_out or posedge rst_in)
           if (rst_in ==1)
              eoc_out_tmp1 <= 0;
           else if ( eoc_out ==1)
               eoc_out_tmp1 <= 0;
           else if ( eoc_out_tmp == 1) begin
               if (curr_chan != 5'b01000)    
                  eoc_out_tmp1 <= 1; 
               else
                  eoc_out_tmp1 <= 0;
           end

    always @( posedge eos_out_tmp or posedge eos_out or posedge rst_in)
           if (rst_in ==1)
              eos_out_tmp1 <= 0;
           else if ( eos_out ==1)
               eos_out_tmp1 <= 0;
           else if ( eos_out_tmp == 1)
               eos_out_tmp1 <= 1; 

    assign busy_out_low_edge = (busy_out==0 && busy_out_sync==1) ? 1 : 0;

    always @( posedge dclk_in or posedge rst_in)
    begin
               
               if (rst_in) begin
                    op_count <= 15;
                    busy_out_sync <= 0;
                end

               drp_update   <= 0;
                alarm_update <= 0;
                eoc_out      <= 0;
                eos_out      <= 0;
                if(rst_in==0)
                begin
                    busy_out_sync <= busy_out;
                        if(op_count==3)                    drp_update <= 1;
                        if(op_count==5 && eoc_out_tmp1==1) alarm_update <=1;
                        if(op_count==9 )       eoc_out <= eoc_out_tmp1;
                        if(op_count==9)                   eos_out <= eos_out_tmp1;
                        if (busy_out_low_edge==1 )
                            op_count <= 0;
                        else if(op_count < 15)              op_count <= op_count +1;
                end
        end

// end eos and eoc

// alarm

    always @( posedge alarm_update or posedge rst_in_not_seq ) 
     if (rst_in_not_seq == 1) begin
        ot_out_reg <= 0;
        alarm_out_reg <= 3'b0;
     end
     else 
       if (rst_lock == 0) begin
          
          if (curr_chan_lat == 0) begin
	    if (data_written >= ot_limit_reg)
		ot_out_reg <= 1;
	    else if (((data_written < dr_sram[7'h57]) && curr_seq1_0_lat != 2'b00) || 
                           (curr_seq1_0_lat ==2'b00 && (data_written < ot_sf_limit_low_reg)))
		ot_out_reg <= 0;

            if (data_written > dr_sram[7'h50])  
	             alarm_out_reg[0] <= 1;
	           else if (data_written < dr_sram[7'h54])
	             alarm_out_reg[0] <= 0;
          end
	
          if (curr_chan_lat == 1) begin
	     if (data_written > dr_sram[7'h51] || data_written < dr_sram[7'h55])
		      alarm_out_reg[1] <= 1;
	     else
		      alarm_out_reg[1] <= 0;
          end

          if (curr_chan_lat == 2) begin
	      if (data_written > dr_sram[7'h52] || data_written < dr_sram[7'h56])
		      alarm_out_reg[2] <= 1;
	         else
		      alarm_out_reg[2] <= 0;
          end
    end // always 

    always @(ot_out_reg or ot_en or alarm_out_reg or alarm_en)
       begin
             ot_out = ot_out_reg & ot_en;
             alarm_out = alarm_out_reg & alarm_en;
      end

// end alarm


endmodule 
