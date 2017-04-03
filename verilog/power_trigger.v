module power_trigger
(
    input clock,
    input enable,
    input reset,

    input set_stb,
    input [7:0] set_addr,
    input [31:0] set_data,

    input [31:0] sample_in,
    input sample_in_strobe,

    output reg trigger
);
`include "common_params.v"

localparam S_SKIP =             0;
localparam S_IDLE =             1;
localparam S_PACKET =           2;
reg [1:0] state;

wire [15:0] power_thres;
wire [15:0] window_size;
wire [31:0] num_sample_to_skip;
wire num_sample_changed;


reg [31:0] sample_count;

wire [15:0] input_i = sample_in[31:16];
reg [15:0] abs_i;

// threshold to claim a power trigger. 
setting_reg #(.my_addr(SR_POWER_THRES), .width(16), .at_reset(100)) sr_0 (
    .clk(clock), .rst(reset), .strobe(set_stb), .addr(set_addr), .in(set_data),
    .out(power_thres), .changed());

// power trigger window
setting_reg #(.my_addr(SR_POWER_WINDOW), .width(16), .at_reset(80)) sr_1 (
    .clk(clock), .rst(reset), .strobe(set_stb), .addr(set_addr), .in(set_data),
    .out(window_size), .changed());

// num samples to skip initially
setting_reg #(.my_addr(SR_SKIP_SAMPLE), .width(32), .at_reset(5000000)) sr_2 (
    .clk(clock), .rst(reset), .strobe(set_stb), .addr(set_addr), .in(set_data),
    .out(num_sample_to_skip), .changed(num_sample_changed));


always @(posedge clock) begin
    if (reset) begin
        sample_count <= 0;
        trigger <= 0;
        abs_i <= 0;
        state <= S_SKIP;
    end else if (enable & sample_in_strobe) begin
        abs_i <= input_i[15]? ~input_i+1: input_i;
        case(state)
            S_SKIP: begin
                if(sample_count > num_sample_to_skip) begin
                    state <= S_IDLE;
                end else begin
                    sample_count <= sample_count + 1;
                end
            end

            S_IDLE: begin
                if (num_sample_changed) begin
                    sample_count <= 0;
                    state <= S_SKIP;
                end else if (abs_i > power_thres) begin
                    // trigger on any significant signal 
                    trigger <= 1;
                    sample_count <= 0;
                    state <= S_PACKET;
                end
            end

            S_PACKET: begin
                if (num_sample_changed) begin
                    sample_count <= 0;
                    state <= S_SKIP;
                end else if (abs_i < power_thres) begin
                    // go back to idle for N consecutive low signals
                    if (sample_count > window_size) begin
                        trigger <= 0;
                        state <= S_IDLE;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end else begin
                    sample_count <= 0;
                end
            end
        endcase
    end
end
endmodule
