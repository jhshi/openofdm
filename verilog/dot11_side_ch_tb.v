`include "openofdm_rx_pre_def.v"

`timescale 1ns/1ps

module dot11_side_ch_tb;
`include "common_params.v"

localparam integer TSF_TIMER_WIDTH = 64; // according to 802.11 standard

localparam integer GPIO_STATUS_WIDTH = 8;
localparam integer RSSI_HALF_DB_WIDTH = 11;

localparam integer ADC_PACK_DATA_WIDTH	= 64;
localparam integer IQ_DATA_WIDTH	=     16;
localparam integer RSSI_DATA_WIDTH	=     10;
		
localparam integer C_S00_AXI_DATA_WIDTH	= 32;
localparam integer C_S00_AXI_ADDR_WIDTH	= 7;

localparam integer C_S00_AXIS_TDATA_WIDTH	= 64;
localparam integer C_M00_AXIS_TDATA_WIDTH	= 64;
		
localparam integer WAIT_COUNT_BITS = 5;
localparam integer MAX_NUM_DMA_SYMBOL = 8192; // the fifo depth inside m_axis

function integer clogb2 (input integer bit_depth);                                   
    begin                                                                              
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
        bit_depth = bit_depth >> 1;                                                    
    end                                                                                
endfunction   

localparam integer MAX_BIT_NUM_DMA_SYMBOL  = clogb2(MAX_NUM_DMA_SYMBOL);

reg clock;
reg reset;
reg enable;

reg [10:0] rssi_half_db;
reg[31:0] sample_in;
reg sample_in_strobe;
reg [15:0] clk_count;

wire [31:0] sync_short_metric;
wire short_preamble_detected;
wire power_trigger;

wire [31:0] sync_long_out;
wire sync_long_out_strobe;
wire [31:0] sync_long_metric;
wire sync_long_metric_stb;
wire long_preamble_detected;

wire [31:0] phase_offset_taken;
wire [31:0] equalizer_out;
wire equalizer_out_strobe;

wire [5:0] demod_out;
wire demod_out_strobe;

wire [7:0] deinterleave_erase_out;
wire deinterleave_erase_out_strobe;

wire conv_decoder_out;
wire conv_decoder_out_stb;

wire descramble_out;
wire descramble_out_strobe;

wire [3:0] legacy_rate;
wire legacy_sig_rsvd;
wire [11:0] legacy_len;
wire legacy_sig_parity;
wire [5:0] legacy_sig_tail;
wire legacy_sig_stb;
reg signal_done;

wire [3:0] dot11_state;

wire pkt_header_valid;
wire pkt_header_valid_strobe;
wire [7:0] byte_out;
wire byte_out_strobe;
wire [15:0] byte_count_total;
wire [15:0] byte_count;
wire [15:0] pkt_len_total;
wire [15:0] pkt_len;
// wire [63:0] word_out;
// wire word_out_strobe;

wire demod_is_ongoing;
wire ofdm_symbol_eq_out_pulse;
wire ht_unsupport;
wire [7:0] pkt_rate;
wire [(32-1):0] csi;
wire csi_valid;

wire [31:0] FC_DI;
wire FC_DI_valid;
        
wire [47:0] addr1;
wire addr1_valid;
wire [47:0] addr2;
wire addr2_valid;
wire [47:0] addr3;
wire addr3_valid;

wire m_axis_start_1trans;
wire [63:0] data_to_ps;
wire data_to_ps_valid;
wire [(MAX_BIT_NUM_DMA_SYMBOL-1):0] m_axis_data_count;
wire fulln_to_pl;
wire M_AXIS_TVALID;
wire M_AXIS_TLAST;

reg slv_reg_wren_signal;
reg [4:0] axi_awaddr_core;

reg [3:0] num_eq;

// iq capture configuration
reg iq_capture;
reg [3:0] iq_trigger_select;
reg signed [(RSSI_HALF_DB_WIDTH-1):0] rssi_th;
reg [(GPIO_STATUS_WIDTH-2):0] gain_th;
reg [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] pre_trigger_len;
reg [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] iq_len_target;

reg set_stb;
reg [7:0] set_addr;
reg [31:0] set_data;

wire fcs_out_strobe, fcs_ok;

integer addr;

integer bb_sample_fd;
integer power_trigger_fd;
integer short_preamble_detected_fd;

integer long_preamble_detected_fd;
integer sync_long_metric_fd;
integer sync_long_out_fd;

integer equalizer_out_fd;

integer demod_out_fd;
integer deinterleave_erase_out_fd;
integer conv_out_fd;
integer descramble_out_fd;

integer signal_fd;

integer byte_out_fd;

integer file_i, file_q, file_rssi_half_db, iq_sample_file;

`define SPEED_100M // remove this to use 200M

localparam integer IQ_CAPTURE = 1; //0 -- CSI; 1 -- IQ
localparam integer IQ_TRIGGER_SELECT = 6;
localparam integer PRE_TRIGGER_LEN = 3;
localparam integer IQ_LEN_TARGET = 7;

//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/iq_11n_mcs7_gi0_100B_ht_unsupport_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/iq_11n_mcs7_gi0_100B_wrong_ht_sig_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/iq_11n_mcs7_gi0_100B_wrong_sig_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/iq_11n_mcs7_gi0_100B_openwifi.txt"
// `define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11n_6.5mbps_98_5f_d3_c7_06_27_e8_de_27_90_6e_42_openwifi.txt"
// `define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11n_52mbps_98_5f_d3_c7_06_27_e8_de_27_90_6e_42_openwifi.txt"
// `define SAMPLE_FILE "../../../../../testing_inputs/radiated/dot11n_19.5mbps_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11n_58.5mbps_98_5f_d3_c7_06_27_e8_de_27_90_6e_42_openwifi.txt"
// `define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11n_65mbps_98_5f_d3_c7_06_27_e8_de_27_90_6e_42_openwifi.txt" 
// `define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11a_48mbps_qos_data_e4_90_7e_15_2a_16_e8_de_27_90_6e_42_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/radiated/ack-ok-openwifi.txt"
`define SAMPLE_FILE "../../../../../testing_inputs/simulated/iq_mixed_for_side_ch_openwifi.txt"

`define NUM_SAMPLE 18560

//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/openofdm_tx/PL_100Bytes/54Mbps.txt"
//`define NUM_SAMPLE 2048

initial begin
    $dumpfile("dot11.vcd");
    $dumpvars;

    slv_reg_wren_signal = 0;
    axi_awaddr_core = 0;

    iq_capture = IQ_CAPTURE;
    iq_trigger_select = IQ_TRIGGER_SELECT;
    rssi_th = 0;
    gain_th = 0;
    pre_trigger_len = PRE_TRIGGER_LEN;
    iq_len_target = IQ_LEN_TARGET;

    clock = 0;
    reset = 1;
    enable = 0;
    signal_done <= 0;

    # 20 reset = 0;
    enable = 1;

    set_stb = 1;

    # 20
    // do not skip sample
    set_addr = SR_SKIP_SAMPLE;
    set_data = 0;

    # 20 set_stb = 0;
end

integer file_open_trigger = 0;
always @(posedge clock) begin
    file_open_trigger = file_open_trigger + 1;
    if (file_open_trigger==1) begin
        iq_sample_file = $fopen(`SAMPLE_FILE, "r");

        bb_sample_fd = $fopen("./sample_in.txt", "w");
        power_trigger_fd = $fopen("./power_trigger.txt", "w");
        short_preamble_detected_fd = $fopen("./short_preamble_detected.txt", "w");

        sync_long_metric_fd = $fopen("./sync_long_metric.txt", "w");
        long_preamble_detected_fd = $fopen("./sync_long_frame_detected.txt", "w");
        sync_long_out_fd = $fopen("./sync_long_out.txt", "w");

        equalizer_out_fd = $fopen("./equalizer_out.txt", "w");

        demod_out_fd = $fopen("./demod_out.txt", "w");
        deinterleave_erase_out_fd = $fopen("./deinterleave_erase_out.txt", "w");
        conv_out_fd = $fopen("./conv_out.txt", "w");
        descramble_out_fd = $fopen("./descramble_out.txt", "w");

        signal_fd = $fopen("./signal_out.txt", "w");

        byte_out_fd = $fopen("./byte_out.txt", "w");
    end
end

`ifdef SPEED_100M
    always begin //100MHz
        #5 clock = !clock;
    end
`else
    always begin //200MHz
        #2.5 clock = !clock;
    end
`endif

always @(posedge clock) begin
    if (reset) begin
        sample_in <= 0;
        clk_count <= 0;
        sample_in_strobe <= 0;
        addr <= 0;
        
        num_eq <= 5;
    end else if (enable) begin
        `ifdef SPEED_100M
    	if (clk_count == 4) begin  // for 100M; 100/20 = 5
    	`else
        if (clk_count == 9) begin // for 200M; 200/20 = 10
        `endif
            sample_in_strobe <= 1;
            //$fscanf(iq_sample_file, "%d %d %d", file_i, file_q, file_rssi_half_db);
            $fscanf(iq_sample_file, "%d %d", file_i, file_q);
            sample_in[15:0] <= file_q;
            sample_in[31:16]<= file_i;
            //rssi_half_db <= file_rssi_half_db;
            rssi_half_db <= 0;
            addr <= addr + 1;
            clk_count <= 0;
        end else begin
            sample_in_strobe <= 0;
            clk_count <= clk_count + 1;
        end

        if (short_preamble_detected) begin
            num_eq <= num_eq + 3;
        end
        
        if (legacy_sig_stb) begin
        end

        //if (sample_in_strobe && power_trigger) begin
        if (sample_in_strobe) begin
            $fwrite(bb_sample_fd, "%d %d %d\n", $time/2, $signed(sample_in[31:16]), $signed(sample_in[15:0]));
            $fwrite(power_trigger_fd, "%d %d\n", $time/2, power_trigger);
            $fwrite(short_preamble_detected_fd, "%d %d\n", $time/2, short_preamble_detected);

            $fwrite(long_preamble_detected_fd, "%d %d\n", $time/2, long_preamble_detected);

            $fflush(bb_sample_fd);
            $fflush(power_trigger_fd);
            $fflush(short_preamble_detected_fd);
            $fflush(long_preamble_detected_fd);


            if ((addr % 100) == 0) begin
                $display("%d", addr);
            end

            if (addr == `NUM_SAMPLE) begin
                $fclose(iq_sample_file);

                $fclose(bb_sample_fd);
                $fclose(power_trigger_fd);
                $fclose(short_preamble_detected_fd);

                $fclose(sync_long_metric_fd);
                $fclose(long_preamble_detected_fd);
                $fclose(sync_long_out_fd);

                $fclose(equalizer_out_fd);

                $fclose(demod_out_fd);
                $fclose(deinterleave_erase_out_fd);
                $fclose(conv_out_fd);
                $fclose(descramble_out_fd);

                $fclose(signal_fd);
                $fclose(byte_out_fd);
    
                $finish;
            end
        end

        if (sync_long_metric_stb) begin
            $fwrite(sync_long_metric_fd, "%d %d\n", $time/2, sync_long_metric);
            $fflush(sync_long_metric_fd);
        end

        if (sync_long_out_strobe) begin
            $fwrite(sync_long_out_fd, "%d %d\n", $signed(sync_long_out[31:16]), $signed(sync_long_out[15:0]));
            $fflush(sync_long_out_fd);
        end

        if (equalizer_out_strobe) begin
            $fwrite(equalizer_out_fd, "%d %d\n", $signed(equalizer_out[31:16]), $signed(equalizer_out[15:0]));
            $fflush(equalizer_out_fd);
        end

        if (legacy_sig_stb) begin
            signal_done <= 1;
            $fwrite(signal_fd, "%04b %b %012b %b %06b", legacy_rate, legacy_sig_rsvd, legacy_len, legacy_sig_parity, legacy_sig_tail);
            $fflush(signal_fd);
        end

        if (dot11_state == S_DECODE_DATA && demod_out_strobe) begin
            $fwrite(demod_out_fd, "%b %b %b %b %b %b\n",demod_out[0],demod_out[1],demod_out[2],demod_out[3],demod_out[4],demod_out[5]);
            $fflush(demod_out_fd);
        end

        if (dot11_state == S_DECODE_DATA && deinterleave_erase_out_strobe) begin
            $fwrite(deinterleave_erase_out_fd, "%b %b %b %b %b %b %b %b\n", deinterleave_erase_out[0], deinterleave_erase_out[1], deinterleave_erase_out[2],  deinterleave_erase_out[3], deinterleave_erase_out[4], deinterleave_erase_out[5], deinterleave_erase_out[6],  deinterleave_erase_out[7]);
            $fflush(deinterleave_erase_out_fd);
        end

        if (dot11_state == S_DECODE_DATA && conv_decoder_out_stb) begin
            $fwrite(conv_out_fd, "%b\n", conv_decoder_out);
            $fflush(conv_out_fd);
        end

        if (dot11_state == S_DECODE_DATA && descramble_out_strobe) begin
            $fwrite(descramble_out_fd, "%b\n", descramble_out);
            $fflush(descramble_out_fd);
        end

        if (dot11_state == S_DECODE_DATA && byte_out_strobe) begin
            $fwrite(byte_out_fd, "%02x\n", byte_out);
            $fflush(byte_out_fd);
        end

    end
end

side_ch_control # (
    .TSF_TIMER_WIDTH(TSF_TIMER_WIDTH), // according to 802.11 standard
    .GPIO_STATUS_WIDTH(GPIO_STATUS_WIDTH),
    .RSSI_HALF_DB_WIDTH(RSSI_HALF_DB_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
    .IQ_DATA_WIDTH(IQ_DATA_WIDTH),
    .C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
    .MAX_NUM_DMA_SYMBOL(MAX_NUM_DMA_SYMBOL),
    .MAX_BIT_NUM_DMA_SYMBOL(MAX_BIT_NUM_DMA_SYMBOL)
) side_ch_control_i (
    .clk(clock),
    .rstn(~reset),

	// from pl
    .gpio_status(34),
	.rssi_half_db(54),
    .tsf_runtime_val(64'd123456),
    .iq(sample_in),
	.iq_strobe(sample_in_strobe),
    .demod_is_ongoing(demod_is_ongoing),
    .ofdm_symbol_eq_out_pulse(ofdm_symbol_eq_out_pulse),
    .long_preamble_detected(long_preamble_detected),
	.short_preamble_detected(short_preamble_detected),
    .ht_unsupport(ht_unsupport),
    .pkt_rate(pkt_rate),
    .pkt_len(pkt_len),
    .csi(csi),
    .csi_valid(csi_valid),
    .phase_offset_taken(phase_offset_taken),
    .equalizer(equalizer_out),
    .equalizer_valid(equalizer_out_strobe),

    .pkt_header_valid(pkt_header_valid),
    .pkt_header_valid_strobe(pkt_header_valid_strobe),
    .FC_DI(FC_DI),
    .FC_DI_valid(FC_DI_valid),
    .addr1(addr1),
    .addr1_valid(addr1_valid),
    .addr2(addr2),
    .addr2_valid(addr2_valid),
    .addr3(addr3),
    .addr3_valid(addr3_valid),

    .fcs_in_strobe(fcs_out_strobe),
    .fcs_ok(fcs_ok),
    .block_rx_dma_to_ps(),
    .block_rx_dma_to_ps_valid(),

	// from arm
    .slv_reg_wren_signal(slv_reg_wren_signal), // to capture m axis num dma symbol write, so that auto trigger start
    .axi_awaddr_core(axi_awaddr_core),
    .iq_capture(iq_capture),
    .iq_trigger_select(iq_trigger_select),
    .rssi_th(rssi_th),
    .gain_th(gain_th),
    .pre_trigger_len(pre_trigger_len),
    .iq_len_target(iq_len_target),
    .FC_target(16'd3243),
    .addr1_target(32'd23343),
    .addr2_target(32'd98765),
    .match_cfg(0),
    .num_eq({1'd0, num_eq[2:0]}),
    .m_axis_start_mode(1),
    .m_axis_start_ext_trigger(),

	// s_axis
    .data_to_pl(),
    .pl_ask_data(),
    .s_axis_data_count(),
    .emptyn_to_pl(),

    .S_AXIS_TVALID(),
    .S_AXIS_TLAST(),

	// m_axis
    .m_axis_start_1trans(m_axis_start_1trans),

    .data_to_ps(data_to_ps),
    .data_to_ps_valid(data_to_ps_valid),
    .m_axis_data_count(m_axis_data_count),
    .fulln_to_pl(fulln_to_pl),
        
    .M_AXIS_TVALID(M_AXIS_TVALID),
    .M_AXIS_TLAST(M_AXIS_TLAST)
);

side_ch_m_axis # (
    // .WAIT_COUNT_BITS(WAIT_COUNT_BITS),
    .MAX_NUM_DMA_SYMBOL(MAX_NUM_DMA_SYMBOL),
    .MAX_BIT_NUM_DMA_SYMBOL(MAX_BIT_NUM_DMA_SYMBOL),
    .C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
) side_ch_m_axis_i (
    .m_axis_endless_mode(0),
    .M_AXIS_NUM_DMA_SYMBOL(3222-1),

    .m_axis_start_1trans(m_axis_start_1trans),

    .data_to_ps(data_to_ps),
    .data_to_ps_valid(data_to_ps_valid),
    .m_axis_data_count(m_axis_data_count),
    .fulln_to_pl(fulln_to_pl),

    .M_AXIS_ACLK(clock),
    .M_AXIS_ARESETN( ~reset ),
    .M_AXIS_TVALID(M_AXIS_TVALID),
    .M_AXIS_TDATA(),
    .M_AXIS_TSTRB(),
    .M_AXIS_TLAST(M_AXIS_TLAST),
    .M_AXIS_TREADY(1)		
);

phy_rx_parse phy_rx_parse_inst (
    .clk(clock),
    .rstn( ~reset ),

    .ofdm_byte_index(byte_count),
    .ofdm_byte(byte_out),
    .ofdm_byte_valid(byte_out_strobe),

    .FC_DI(FC_DI),
    .FC_DI_valid(FC_DI_valid),
        
    .rx_addr(addr1),
    .rx_addr_valid(addr1_valid),
        
    .dst_addr(addr2),
    .dst_addr_valid(addr2_valid),
        
    .tx_addr(addr3),
    .tx_addr_valid(addr3_valid),
        
    .SC(),
    .SC_valid(),
        
    .src_addr(),
    .src_addr_valid()
);

dot11 dot11_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    //.set_stb(set_stb),
    //.set_addr(set_addr),
    //.set_data(set_data),

    .power_thres(11'd0),
    .min_plateau(32'd100),

    .rssi_half_db(rssi_half_db),
    .sample_in(sample_in),
    .sample_in_strobe(sample_in_strobe),
    .soft_decoding(1'b1),

    .demod_is_ongoing(demod_is_ongoing),
    .pkt_begin(pkt_begin),
    .pkt_ht(pkt_ht),
    .pkt_header_valid(pkt_header_valid),
    .pkt_header_valid_strobe(pkt_header_valid_strobe),
    .ht_unsupport(ht_unsupport),
    .pkt_rate(pkt_rate),
    .pkt_len(pkt_len),
    .pkt_len_total(pkt_len_total),
    .byte_out_strobe(byte_out_strobe),
    .byte_out(byte_out),
    .byte_count_total(byte_count_total),
    .byte_count(byte_count),
    .fcs_out_strobe(fcs_out_strobe),
    .fcs_ok(fcs_ok),

    .state(dot11_state),
    .status_code(status_code),
    .state_changed(state_changed),
    .state_history(state_history),

    .power_trigger(power_trigger),

    .short_preamble_detected(short_preamble_detected),
    .phase_offset(phase_offset),

    .sync_long_metric(sync_long_metric),
    .sync_long_metric_stb(sync_long_metric_stb),
    .long_preamble_detected(long_preamble_detected),
    .sync_long_out(sync_long_out),
    .sync_long_out_strobe(sync_long_out_strobe),
    .phase_offset_taken(phase_offset_taken),
    .sync_long_state(sync_long_state),

    .equalizer_out(equalizer_out),
    .equalizer_out_strobe(equalizer_out_strobe),
    .equalizer_state(equalizer_state),
    .ofdm_symbol_eq_out_pulse(ofdm_symbol_eq_out_pulse),

    .legacy_sig_stb(legacy_sig_stb),
    .legacy_rate(legacy_rate),
    .legacy_sig_rsvd(legacy_sig_rsvd),
    .legacy_len(legacy_len),
    .legacy_sig_parity(legacy_sig_parity),
    .legacy_sig_parity_ok(legacy_sig_parity_ok),
    .legacy_sig_tail(legacy_sig_tail),

    .ht_sig_stb(ht_sig_stb),
    .ht_mcs(ht_mcs),
    .ht_cbw(ht_cbw),
    .ht_len(ht_len),
    .ht_smoothing(ht_smoothing),
    .ht_not_sounding(ht_not_sounding),
    .ht_aggregation(ht_aggregation),
    .ht_stbc(ht_stbc),
    .ht_fec_coding(ht_fec_coding),
    .ht_sgi(ht_sgi),
    .ht_num_ext(ht_num_ext),
    .ht_sig_crc_ok(ht_sig_crc_ok),

    .demod_out(demod_out),
    .demod_out_strobe(demod_out_strobe),

    .deinterleave_erase_out(deinterleave_erase_out),
    .deinterleave_erase_out_strobe(deinterleave_erase_out_strobe),

    .conv_decoder_out(conv_decoder_out),
    .conv_decoder_out_stb(conv_decoder_out_stb),

    .csi(csi),
    .csi_valid(csi_valid),

    .descramble_out(descramble_out),
    .descramble_out_strobe(descramble_out_strobe)
);

/*
byte_to_word_fcs_sn_insert byte_to_word_fcs_sn_insert_inst (
    .clk(clock),
    .rstn((~reset)&(~pkt_header_valid_strobe)),

    .byte_in(byte_out),
    .byte_in_strobe(byte_out_strobe),
    .byte_count(byte_count),
    .num_byte(pkt_len),
    .fcs_in_strobe(fcs_out_strobe),
    .fcs_ok(fcs_ok),
    .rx_pkt_sn_plus_one(0),

    .word_out(word_out),
    .word_out_strobe(word_out_strobe)
);
*/

endmodule
