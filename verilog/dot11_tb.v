`include "openofdm_rx_pre_def.v"

`timescale 1ns/1ps

module dot11_tb;
`include "common_params.v"

reg clock;
reg reset;
reg enable;

reg [10:0] rssi_half_db;
reg[31:0] sample_in;
reg sample_in_strobe;
reg [15:0] clk_count;

reg signal_done;

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

reg set_stb;
reg [7:0] set_addr;
reg [31:0] set_data;

wire fcs_out_strobe, fcs_ok;
wire demod_is_ongoing;
wire receiver_rst;

wire sig_valid = (pkt_header_valid_strobe&pkt_header_valid);

integer addr;

// file descriptors 
integer sample_file_name_fd;

integer bb_sample_fd;
integer power_trigger_fd;
integer short_preamble_detected_fd;

integer long_preamble_detected_fd;
integer sync_long_metric_fd;
integer sync_long_out_fd;

integer demod_out_fd;
integer demod_soft_bits_fd;
integer demod_soft_bits_pos_fd;
integer deinterleave_erase_out_fd;
integer conv_out_fd;
integer descramble_out_fd;

integer signal_fd;

integer byte_out_fd;

// sync_short 
integer mag_sq_fd;
integer mag_sq_avg_fd;
integer prod_fd;
integer prod_avg_fd;
integer phase_in_fd;
integer phase_out_fd;
integer delay_prod_avg_mag_fd;

// sync_long
integer sum_fd;
integer metric_fd;
integer phase_correction_fd;
integer next_phase_correction_fd;
integer fft_in_fd;
integer fft_out_fd;

// equalizer
integer new_lts_fd;
integer phase_offset_pilot_input_fd;
integer phase_offset_lts_input_fd;
integer phase_offset_pilot_fd;
integer phase_offset_pilot_sum_fd;
integer phase_offset_phase_out_fd;
integer rot_in_fd;
integer rot_out_fd;
integer equalizer_prod_fd;
integer equalizer_prod_scaled_fd;
integer equalizer_mag_sq_fd;
integer equalizer_out_fd;

// ONLY allow 100(low FPGA), 200(high FPGA), 240(ultra_scal FPGA) and 400(test)
// do NOT turn on more than one of them
`define CLK_SPEED_100M
//`define CLK_SPEED_200M
//`define CLK_SPEED_240M  
//`define CLK_SPEED_400M

//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/iq_11n_mcs7_gi0_100B_ht_unsupport_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/iq_11n_mcs7_gi0_100B_wrong_ht_sig_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/iq_11n_mcs7_gi0_100B_wrong_sig_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/iq_11n_mcs7_gi0_100B_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11n_6.5mbps_98_5f_d3_c7_06_27_e8_de_27_90_6e_42_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11n_52mbps_98_5f_d3_c7_06_27_e8_de_27_90_6e_42_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/radiated/dot11n_19.5mbps_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11n_58.5mbps_98_5f_d3_c7_06_27_e8_de_27_90_6e_42_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11n_65mbps_98_5f_d3_c7_06_27_e8_de_27_90_6e_42_openwifi.txt" 
//`define SAMPLE_FILE "../../../../../testing_inputs/conducted/dot11a_48mbps_qos_data_e4_90_7e_15_2a_16_e8_de_27_90_6e_42_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/radiated/ack-ok-openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/conducted/fake-demod-0.txt"

//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs7_gi1_aggr0_len14_pre100_post200_openwifi.txt"
`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs7_gi1_aggr0_len1537_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs7_gi1_aggr0_len4000_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs7_gi0_aggr0_len14_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs7_gi0_aggr0_len1537_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs7_gi0_aggr0_len4000_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs0_gi1_aggr0_len14_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs0_gi1_aggr0_len1537_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs0_gi1_aggr0_len4000_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs0_gi0_aggr0_len14_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs0_gi0_aggr0_len1537_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ht_mcs0_gi0_aggr0_len4000_pre100_post200_openwifi.txt"

//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ag_54M_len14_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ag_54M_len1537_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ag_54M_len4000_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ag_6M_len14_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ag_6M_len1537_pre100_post200_openwifi.txt"
//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/ag_6M_len4000_pre100_post200_openwifi.txt"

`define NUM_SAMPLE 118560

//`define SAMPLE_FILE "../../../../../testing_inputs/simulated/openofdm_tx/PL_100Bytes/54Mbps.txt"
//`define NUM_SAMPLE 2048

integer file_i, file_q, file_rssi_half_db, iq_sample_file;

initial begin
    $dumpfile("dot11.vcd");
    $dumpvars;
    sample_file_name_fd = $fopen("./sample_file_name.txt", "w");
    $fwrite(sample_file_name_fd, "%s", `SAMPLE_FILE); 
    $fflush(sample_file_name_fd);
    $fclose(sample_file_name_fd);

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

        demod_out_fd = $fopen("./demod_out.txt", "w");
        demod_soft_bits_fd = $fopen("./demod_soft_bits.txt", "w");
        demod_soft_bits_pos_fd = $fopen("./demod_soft_bits_pos.txt", "w");
        deinterleave_erase_out_fd = $fopen("./deinterleave_erase_out.txt", "w");
        conv_out_fd = $fopen("./conv_out.txt", "w");
        descramble_out_fd = $fopen("./descramble_out.txt", "w");

        signal_fd = $fopen("./signal_out.txt", "w");

        byte_out_fd = $fopen("./byte_out.txt", "w");

        // sync_short 
        mag_sq_fd = $fopen("./mag_sq.txt", "w");
        mag_sq_avg_fd = $fopen("./mag_sq_avg.txt", "w");
        prod_fd = $fopen("./prod.txt", "w");
        prod_avg_fd = $fopen("./prod_avg.txt", "w");
        phase_in_fd = $fopen("./phase_in.txt", "w");
        phase_out_fd = $fopen("./phase_out.txt", "w");
        delay_prod_avg_mag_fd = $fopen("./delay_prod_avg_mag.txt", "w");

        // sync_long
        sum_fd = $fopen("./sum.txt", "w");
        metric_fd = $fopen("./metric.txt", "w");
        phase_correction_fd = $fopen("./phase_correction.txt", "w");
        next_phase_correction_fd = $fopen("./next_phase_correction.txt", "w");
        fft_in_fd = $fopen("./fft_in.txt", "w");
        fft_out_fd = $fopen("./fft_out.txt", "w");

        // equalizer
        new_lts_fd = $fopen("./new_lts.txt", "w");
        phase_offset_pilot_input_fd = $fopen("./phase_offset_pilot_input.txt", "w");
        phase_offset_lts_input_fd = $fopen("./phase_offset_lts_input.txt", "w");
        phase_offset_pilot_fd = $fopen("./phase_offset_pilot.txt", "w");
        phase_offset_pilot_sum_fd = $fopen("./phase_offset_pilot_sum.txt", "w");
        phase_offset_phase_out_fd = $fopen("./phase_offset_phase_out.txt", "w");
        rot_in_fd = $fopen("./rot_in.txt", "w");
        rot_out_fd = $fopen("./rot_out.txt", "w");
        equalizer_prod_fd = $fopen("./equalizer_prod.txt", "w");
        equalizer_prod_scaled_fd = $fopen("./equalizer_prod_scaled.txt", "w");
        equalizer_mag_sq_fd = $fopen("./equalizer_mag_sq.txt", "w");
        equalizer_out_fd = $fopen("./equalizer_out.txt", "w");

    end
end

    always begin
`ifdef CLK_SPEED_100M
        #5 clock = !clock;
`elsif CLK_SPEED_200M
        #2.5 clock = !clock;
`elsif CLK_SPEED_240M
        #2.0833333333 clock = !clock;
`elsif CLK_SPEED_400M
        #1.25 clock = !clock;
`endif
    end

always @(posedge clock) begin
    if (reset) begin
        sample_in <= 0;
        clk_count <= 0;
        sample_in_strobe <= 0;
        addr <= 0;
    end else if (enable) begin
        `ifdef CLK_SPEED_100M
    	if (clk_count == 4) begin  // for 100M; 100/20 = 5
    	`elsif CLK_SPEED_200M
        if (clk_count == 9) begin // for 200M; 200/20 = 10
        `elsif CLK_SPEED_240M
        if (clk_count == 11) begin // for 200M; 240/20 = 12
        `elsif CLK_SPEED_400M
        if (clk_count == 19) begin // for 200M; 400/20 = 20
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

        if (dot11_inst.legacy_sig_stb) begin
        end

        //if (sample_in_strobe && power_trigger) begin
        if (sample_in_strobe) begin
            $fwrite(bb_sample_fd, "%d %d %d\n", $time/2, $signed(sample_in[31:16]), $signed(sample_in[15:0]));
            $fwrite(power_trigger_fd, "%d %d\n", $time/2, dot11_inst.power_trigger);
            $fwrite(short_preamble_detected_fd, "%d %d\n", $time/2, dot11_inst.short_preamble_detected);

            $fwrite(long_preamble_detected_fd, "%d %d\n", $time/2, dot11_inst.long_preamble_detected);

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
                $fclose(demod_soft_bits_fd);
                $fclose(demod_soft_bits_pos_fd);
                $fclose(deinterleave_erase_out_fd);
                $fclose(conv_out_fd);
                $fclose(descramble_out_fd);

                $fclose(signal_fd);
                $fclose(byte_out_fd);
    
                $finish;
            end
        end

        if (dot11_inst.sync_long_inst.metric_stb) begin
            $fwrite(sync_long_metric_fd, "%d %d\n", $time/2, dot11_inst.sync_long_inst.metric);
            $fflush(sync_long_metric_fd);
        end

        if (dot11_inst.sync_long_inst.sample_out_strobe) begin
            $fwrite(sync_long_out_fd, "%d %d\n", $signed(dot11_inst.sync_long_inst.sample_out[31:16]), $signed(dot11_inst.sync_long_inst.sample_out[15:0]));
            $fflush(sync_long_out_fd);
        end

        // if (dot11_inst.equalizer_inst.sample_out_strobe) begin
        //     $fwrite(equalizer_out_fd, "%d %d\n", $signed(dot11_inst.equalizer_inst.sample_out[31:16]), $signed(dot11_inst.equalizer_inst.sample_out[15:0]));
        //     $fflush(equalizer_out_fd);
        // end

        if (dot11_inst.legacy_sig_stb) begin
            signal_done <= 1;
            $fwrite(signal_fd, "%04b %b %012b %b %06b", dot11_inst.legacy_rate, dot11_inst.legacy_sig_rsvd, dot11_inst.legacy_len, dot11_inst.legacy_sig_parity, dot11_inst.legacy_sig_tail);
            $fflush(signal_fd);
        end

        if ((dot11_inst.state == S_MPDU_DELIM || dot11_inst.state == S_DECODE_DATA || dot11_inst.state == S_MPDU_PAD) && dot11_inst.ofdm_decoder_inst.demod_out_strobe) begin
            $fwrite(demod_out_fd, "%b %b %b %b %b %b\n",dot11_inst.ofdm_decoder_inst.demod_out[0],dot11_inst.ofdm_decoder_inst.demod_out[1],dot11_inst.ofdm_decoder_inst.demod_out[2],dot11_inst.ofdm_decoder_inst.demod_out[3],dot11_inst.ofdm_decoder_inst.demod_out[4],dot11_inst.ofdm_decoder_inst.demod_out[5]);
            $fwrite(demod_soft_bits_fd, "%b %b %b %b %b %b\n",dot11_inst.ofdm_decoder_inst.demod_soft_bits[0],dot11_inst.ofdm_decoder_inst.demod_soft_bits[1],dot11_inst.ofdm_decoder_inst.demod_soft_bits[2],dot11_inst.ofdm_decoder_inst.demod_soft_bits[3],dot11_inst.ofdm_decoder_inst.demod_soft_bits[4],dot11_inst.ofdm_decoder_inst.demod_soft_bits[5]);
            $fwrite(demod_soft_bits_pos_fd, "%b %b %b %b\n",dot11_inst.ofdm_decoder_inst.demod_soft_bits_pos[0],dot11_inst.ofdm_decoder_inst.demod_soft_bits_pos[1],dot11_inst.ofdm_decoder_inst.demod_soft_bits_pos[2],dot11_inst.ofdm_decoder_inst.demod_soft_bits_pos[3]);
            $fflush(demod_out_fd);
            $fflush(demod_soft_bits_fd);
            $fflush(demod_soft_bits_pos_fd);
        end

        if ((dot11_inst.state == S_MPDU_DELIM || dot11_inst.state == S_DECODE_DATA || dot11_inst.state == S_MPDU_PAD) && dot11_inst.deinterleave_erase_out_strobe) begin
            $fwrite(deinterleave_erase_out_fd, "%b %b %b %b %b %b %b %b\n", dot11_inst.deinterleave_erase_out[0], dot11_inst.deinterleave_erase_out[1], dot11_inst.deinterleave_erase_out[2], dot11_inst.deinterleave_erase_out[3], dot11_inst.deinterleave_erase_out[4], dot11_inst.deinterleave_erase_out[5], dot11_inst.deinterleave_erase_out[6],  dot11_inst.deinterleave_erase_out[7]);
            $fflush(deinterleave_erase_out_fd);
        end

        if ((dot11_inst.state == S_MPDU_DELIM || dot11_inst.state == S_DECODE_DATA || dot11_inst.state == S_MPDU_PAD) && dot11_inst.conv_decoder_out_stb) begin
            $fwrite(conv_out_fd, "%b\n", dot11_inst.conv_decoder_out);
            $fflush(conv_out_fd);
        end

        if ((dot11_inst.state == S_MPDU_DELIM || dot11_inst.state == S_DECODE_DATA || dot11_inst.state == S_MPDU_PAD) && dot11_inst.descramble_out_strobe) begin
            $fwrite(descramble_out_fd, "%b\n", dot11_inst.descramble_out);
            $fflush(descramble_out_fd);
        end

        if ((dot11_inst.state == S_MPDU_DELIM || dot11_inst.state == S_DECODE_DATA || dot11_inst.state == S_MPDU_PAD) && dot11_inst.byte_out_strobe) begin
            $fwrite(byte_out_fd, "%02x\n", dot11_inst.byte_out);
            $fflush(byte_out_fd);
        end

        // sync_short 
        if (dot11_inst.sync_short_inst.mag_sq_stb && dot11_inst.sync_short_inst.enable && ~dot11_inst.sync_short_inst.reset) begin
            $fwrite(mag_sq_fd, "%d\n", dot11_inst.sync_short_inst.mag_sq);
            $fflush(mag_sq_fd);
        end
        if (dot11_inst.sync_short_inst.mag_sq_avg_stb && dot11_inst.sync_short_inst.enable && ~dot11_inst.sync_short_inst.reset) begin
            $fwrite(mag_sq_avg_fd, "%d\n", dot11_inst.sync_short_inst.mag_sq_avg);
            $fflush(mag_sq_avg_fd);
        end
        if (dot11_inst.sync_short_inst.prod_stb && dot11_inst.sync_short_inst.enable && ~dot11_inst.sync_short_inst.reset) begin
            $fwrite(prod_fd, "%d %d\n", dot11_inst.sync_short_inst.prod[63:32], dot11_inst.sync_short_inst.prod[31:0]);
            $fflush(prod_fd);
        end
        if (dot11_inst.sync_short_inst.prod_avg_stb && dot11_inst.sync_short_inst.enable && ~dot11_inst.sync_short_inst.reset) begin
            $fwrite(prod_avg_fd, "%d %d\n", dot11_inst.sync_short_inst.prod_avg[63:32], dot11_inst.sync_short_inst.prod_avg[31:0]);
            $fflush(prod_avg_fd);
        end
        if (dot11_inst.sync_short_inst.phase_in_stb && dot11_inst.sync_short_inst.enable && ~dot11_inst.sync_short_inst.reset) begin
            $fwrite(phase_in_fd, "%d %d\n", dot11_inst.sync_short_inst.phase_in_i, dot11_inst.sync_short_inst.phase_in_q);
            $fflush(phase_in_fd);
        end
        if (dot11_inst.sync_short_inst.phase_out_stb && dot11_inst.sync_short_inst.enable && ~dot11_inst.sync_short_inst.reset) begin
            $fwrite(phase_out_fd, "%d\n", $signed(dot11_inst.sync_short_inst.phase_out));
            $fflush(phase_out_fd);
        end
        if (dot11_inst.sync_short_inst.delay_prod_avg_mag_stb && dot11_inst.sync_short_inst.enable && ~dot11_inst.sync_short_inst.reset) begin
            $fwrite(delay_prod_avg_mag_fd, "%d\n", dot11_inst.sync_short_inst.delay_prod_avg_mag);
            $fflush(delay_prod_avg_mag_fd);
        end

        // sync_long 
        if (dot11_inst.sync_long_inst.sum_stb && dot11_inst.sync_long_inst.enable && ~dot11_inst.sync_long_inst.reset) begin
            $fwrite(sum_fd, "%d %d\n", dot11_inst.sync_long_inst.sum_i, dot11_inst.sync_long_inst.sum_q);
            $fflush(sum_fd);
        end
        if (dot11_inst.sync_long_inst.metric_stb && dot11_inst.sync_long_inst.enable && ~dot11_inst.sync_long_inst.reset) begin
            $fwrite(metric_fd, "%d\n", dot11_inst.sync_long_inst.metric);
            $fflush(metric_fd);
        end
        if (dot11_inst.sync_long_inst.raw_stb && dot11_inst.sync_long_inst.enable && ~dot11_inst.sync_long_inst.reset) begin
            $fwrite(phase_correction_fd, "%d\n", dot11_inst.sync_long_inst.phase_correction);
            $fflush(phase_correction_fd);
            $fwrite(next_phase_correction_fd, "%d\n", dot11_inst.sync_long_inst.next_phase_correction);
            $fflush(next_phase_correction_fd);
        end
        if (dot11_inst.sync_long_inst.fft_in_stb && dot11_inst.sync_long_inst.enable && ~dot11_inst.sync_long_inst.reset) begin
            $fwrite(fft_in_fd, "%d %d\n", dot11_inst.sync_long_inst.fft_in_re, dot11_inst.sync_long_inst.fft_in_im);
            $fflush(fft_in_fd);
        end
        if (dot11_inst.sync_long_inst.fft_valid && dot11_inst.sync_long_inst.enable && ~dot11_inst.sync_long_inst.reset) begin
            $fwrite(fft_out_fd, "%d %d\n", $signed(dot11_inst.sync_long_inst.fft_out_re[22:7]), $signed(dot11_inst.sync_long_inst.fft_out_im[22:7]));
            $fflush(fft_out_fd);
        end

        // equalizer 
        if ((dot11_inst.equalizer_inst.num_ofdm_sym == 1 || (dot11_inst.equalizer_inst.pkt_ht==1 && dot11_inst.equalizer_inst.num_ofdm_sym==5)) && dot11_inst.equalizer_inst.state == dot11_inst.equalizer_inst.S_CALC_FREQ_OFFSET && dot11_inst.equalizer_inst.sample_in_strobe_dly == 1 && dot11_inst.equalizer_inst.enable && ~dot11_inst.equalizer_inst.reset) begin
            $fwrite(new_lts_fd, "%d %d\n", dot11_inst.equalizer_inst.lts_i_out, dot11_inst.equalizer_inst.lts_q_out);
            $fflush(new_lts_fd);
        end
        if (dot11_inst.equalizer_inst.pilot_in_stb && dot11_inst.equalizer_inst.enable && ~dot11_inst.equalizer_inst.reset) begin
            $fwrite(phase_offset_pilot_input_fd, "%d %d\n", dot11_inst.equalizer_inst.input_i, dot11_inst.equalizer_inst.input_q);
            $fflush(phase_offset_pilot_input_fd);
            $fwrite(phase_offset_lts_input_fd, "%d %d\n", dot11_inst.equalizer_inst.lts_i_out, dot11_inst.equalizer_inst.lts_q_out);
            $fflush(phase_offset_lts_input_fd);
        end
        if (dot11_inst.equalizer_inst.pilot_out_stb && dot11_inst.equalizer_inst.enable && ~dot11_inst.equalizer_inst.reset) begin
            $fwrite(phase_offset_pilot_fd, "%d %d\n", dot11_inst.equalizer_inst.pilot_i, dot11_inst.equalizer_inst.pilot_q);
            $fflush(phase_offset_pilot_fd);
        end
        if (dot11_inst.equalizer_inst.phase_in_stb && dot11_inst.equalizer_inst.enable && ~dot11_inst.equalizer_inst.reset) begin
            $fwrite(phase_offset_pilot_sum_fd, "%d %d\n", dot11_inst.equalizer_inst.pilot_sum_i, dot11_inst.equalizer_inst.pilot_sum_q);
            $fflush(phase_offset_pilot_sum_fd);
        end
        if (dot11_inst.equalizer_inst.phase_out_stb && dot11_inst.equalizer_inst.enable && ~dot11_inst.equalizer_inst.reset) begin
            $fwrite(phase_offset_phase_out_fd, "%d\n", $signed(dot11_inst.equalizer_inst.phase_out));
            $fflush(phase_offset_phase_out_fd);
        end
        if (dot11_inst.equalizer_inst.rot_in_stb && dot11_inst.equalizer_inst.enable && ~dot11_inst.equalizer_inst.reset) begin
            $fwrite(rot_in_fd, "%d %d %d\n", $signed(dot11_inst.equalizer_inst.buf_i_out), $signed(dot11_inst.equalizer_inst.buf_q_out), $signed(dot11_inst.equalizer_inst.sym_phase));
            $fflush(rot_in_fd);
        end
        if (dot11_inst.equalizer_inst.rot_out_stb && dot11_inst.equalizer_inst.enable && ~dot11_inst.equalizer_inst.reset) begin
            $fwrite(rot_out_fd, "%d %d\n", dot11_inst.equalizer_inst.rot_i, dot11_inst.equalizer_inst.rot_q);
            $fflush(rot_out_fd);
        end
        if (dot11_inst.equalizer_inst.prod_out_strobe && dot11_inst.equalizer_inst.enable && ~dot11_inst.equalizer_inst.reset) begin
            $fwrite(equalizer_prod_fd, "%d %d\n", $signed(dot11_inst.equalizer_inst.prod_i), $signed(dot11_inst.equalizer_inst.prod_q));
            $fflush(equalizer_prod_fd);
            $fwrite(equalizer_prod_scaled_fd, "%d %d\n", $signed(dot11_inst.equalizer_inst.prod_i_scaled), $signed(dot11_inst.equalizer_inst.prod_q_scaled));
            $fflush(equalizer_prod_scaled_fd);
            $fwrite(equalizer_mag_sq_fd, "%d\n", dot11_inst.equalizer_inst.mag_sq);
            $fflush(equalizer_mag_sq_fd);
        end
        if (dot11_inst.equalizer_inst.sample_out_strobe && dot11_inst.equalizer_inst.enable && ~dot11_inst.equalizer_inst.reset) begin
            $fwrite(equalizer_out_fd, "%d %d\n", $signed(dot11_inst.equalizer_inst.sample_out[31:16]), $signed(dot11_inst.equalizer_inst.sample_out[15:0]));
            $fflush(equalizer_out_fd);
        end

    end
end

signal_watchdog signal_watchdog_inst (
    .clk(clock),
    .rstn(~reset),
    .enable(~demod_is_ongoing),

    .i_data(sample_in[31:16]),
    .q_data(sample_in[15:0]),
    .iq_valid(sample_in_strobe),

    .signal_len(pkt_len),
    .sig_valid(sig_valid),

    .max_signal_len_th(4095),
    .dc_running_sum_th(64),

    .receiver_rst(receiver_rst)
);

dot11 dot11_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset|receiver_rst),

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
    .pkt_header_valid(pkt_header_valid),
    .pkt_header_valid_strobe(pkt_header_valid_strobe),
    .pkt_len(pkt_len)
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
