`timescale 1ns/1ps

module dot11_tb;
`include "common_params.v"

reg clock;
reg reset;
reg enable;

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


wire [31:0] equalizer_out;
wire equalizer_out_strobe;

wire [5:0] demod_out;
wire demod_out_strobe;

wire [1:0] deinterleave_out;
wire deinterleave_out_strobe;

wire conv_decoder_out;
wire conv_decoder_out_stb;

wire descramble_out;
wire descramble_out_strobe;

wire [3:0] data_rate;
wire signal_reserved;
wire [11:0] length;
wire parity;
wire [5:0] signal_tail;
wire signal_out_strobe;
reg signal_done;

wire [3:0] dot11_state;

wire [7:0] byte_out;
wire byte_out_strobe;


reg set_stb;
reg [7:0] set_addr;
reg [31:0] set_data;

localparam RAM_SIZE = 1<<25;

reg [31:0] ram [0:RAM_SIZE-1];
reg [31:0] addr;

integer bb_sample_fd;
integer power_trigger_fd;
integer short_preamble_detected_fd;

integer long_preamble_detected_fd;
integer sync_long_metric_fd;
integer sync_long_out_fd;

integer equalizer_out_fd;

integer demod_out_fd;
integer deinterleave_out_fd;
integer conv_out_fd;
integer descramble_out_fd;

integer signal_fd;

integer byte_out_fd;

`ifndef SAMPLE_FILE
`define SAMPLE_FILE "../testing_inputs/conducted/dot11a_24mbps_qos_data_e4_90_7e_15_2a_16_e8_de_27_90_6e_42.txt"
`endif

`ifndef NUM_SAMPLE
`define NUM_SAMPLE 1000
`endif

initial begin
    $dumpfile("dot11_decoder.vcd");
    $dumpvars;

    $display("Reading memory from...");
    $display(`SAMPLE_FILE);
    $readmemh(`SAMPLE_FILE, ram);
    $display("Done.");

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

    bb_sample_fd = $fopen("./sim_out/sample_in.txt", "w");
    power_trigger_fd = $fopen("./sim_out/power_trigger.txt", "w");
    short_preamble_detected_fd = $fopen("./sim_out/short_preamble_detected.txt", "w");

    sync_long_metric_fd = $fopen("./sim_out/sync_long_metric.txt", "w");
    long_preamble_detected_fd = $fopen("./sim_out/sync_long_frame_detected.txt", "w");
    sync_long_out_fd = $fopen("./sim_out/sync_long_out.txt", "w");

    equalizer_out_fd = $fopen("./sim_out/equalizer_out.txt", "w");

    demod_out_fd = $fopen("./sim_out/demod_out.txt", "w");
    deinterleave_out_fd = $fopen("./sim_out/deinterleave_out.txt", "w");
    conv_out_fd = $fopen("./sim_out/conv_out.txt", "w");
    descramble_out_fd = $fopen("./sim_out/descramble_out.txt", "w");

    signal_fd = $fopen("./sim_out/signal_out.txt", "w");

    byte_out_fd = $fopen("./sim_out/byte_out.txt", "w");
end


always begin
    #5 clock = !clock;
end

always @(posedge clock) begin
    if (reset) begin
        sample_in <= 0;
        clk_count <= 0;
        sample_in_strobe <= 0;
        addr <= 0;
    end else if (enable) begin
        if (clk_count == 4) begin
            sample_in_strobe <= 1;
            sample_in <= ram[addr];
            addr <= addr + 1;
            clk_count <= 0;
        end else begin
            sample_in_strobe <= 0;
            clk_count <= clk_count + 1;
        end

        if (signal_out_strobe) begin
        end

        if (sample_in_strobe && power_trigger) begin
            $fwrite(bb_sample_fd, "%d %d %d\n", $time/2, $signed(sample_in[31:16]), $signed(sample_in[15:0]));
            $fwrite(power_trigger_fd, "%d %d\n", $time/2, power_trigger);
            $fwrite(short_preamble_detected_fd, "%d %d\n", $time/2, short_preamble_detected);

            $fwrite(long_preamble_detected_fd, "%d %d\n", $time/2, long_preamble_detected);

            $fflush(bb_sample_fd);
            $fflush(power_trigger_fd);
            $fflush(short_preamble_detected_fd);

            $fflush(sync_long_metric_fd);
            $fflush(long_preamble_detected_fd);


            if ((addr % 100) == 0) begin
                $display("%d / %d", addr, RAM_SIZE);
            end

            if (addr == `NUM_SAMPLE) begin
                $finish;
            end
        end

        if (sync_long_metric_stb) begin
            $fwrite(sync_long_metric_fd, "%d %d\n", $time/2, sync_long_metric);
        end

        if (sync_long_out_strobe) begin
            $fwrite(sync_long_out_fd, "%d %d\n", $signed(sync_long_out[31:16]), $signed(sync_long_out[15:0]));
            $fflush(sync_long_out_fd);
        end

        if (equalizer_out_strobe) begin
            $fwrite(equalizer_out_fd, "%d %d\n", $signed(equalizer_out[31:16]), $signed(equalizer_out[15:0]));
            $fflush(equalizer_out_fd);
        end

        if (signal_out_strobe) begin
            signal_done <= 1;
            $fwrite(signal_fd, "%04b %b %012b %b %06b", data_rate, signal_reserved, length, parity, signal_tail);
            $fflush(signal_fd);
        end

        if (dot11_state == S_DECODE_DATA && demod_out_strobe) begin
            $fwrite(demod_out_fd, "%06b\n", demod_out);
            $fflush(demod_out_fd);
        end

        if (dot11_state == S_DECODE_DATA && deinterleave_out_strobe) begin
            $fwrite(deinterleave_out_fd, "%b%b\n", deinterleave_out[0], deinterleave_out[1]);
            $fflush(deinterleave_out_fd);
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

dot11 dot11_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),

    .set_addr(set_addr),
    .set_stb(set_stb),
    .set_data(set_data),

    .sample_in(sample_in),
    .sample_in_strobe(sample_in_strobe),

    .state(dot11_state),

    .power_trigger(power_trigger),
    .short_preamble_detected(short_preamble_detected),

    .sync_long_metric(sync_long_metric),
    .sync_long_metric_stb(sync_long_metric_stb),
    .long_preamble_detected(long_preamble_detected),

    .sync_long_out(sync_long_out),
    .sync_long_out_strobe(sync_long_out_strobe),

    .equalizer_out(equalizer_out),
    .equalizer_out_strobe(equalizer_out_strobe),

    .demod_out(demod_out),
    .demod_out_strobe(demod_out_strobe),

    .deinterleave_out(deinterleave_out),
    .deinterleave_out_strobe(deinterleave_out_strobe),

    .conv_decoder_out(conv_decoder_out),
    .conv_decoder_out_stb(conv_decoder_out_stb),

    .descramble_out(descramble_out),
    .descramble_out_strobe(descramble_out_strobe),

    .byte_out(byte_out),
    .byte_out_strobe(byte_out_strobe),

    .data_rate(data_rate),
    .signal_reserved(signal_reserved),
    .length(length),
    .parity(parity),
    .signal_tail(signal_tail),
    .signal_out_strobe(signal_out_strobe)
);

endmodule
