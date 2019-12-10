module power_trigger
(
    input clock,
    input enable,
    input reset,

    input [31:0] sample_in,
    input sample_in_strobe,
    input [15:0] power_thres,
    input [15:0] window_size,
    input [31:0] num_sample_to_skip,
    input num_sample_changed,

    output [1:0] pw_state_spy,
    output reg trigger
);
`include "common_params.v"

localparam S_SKIP =             0;
localparam S_IDLE =             1;
localparam S_PACKET =           2;
(* mark_debug = "true" *) reg [1:0] state;

(* mark_debug = "true" *) wire [15:0] power_thres;
(* mark_debug = "true" *) wire [15:0] window_size;
(* mark_debug = "true" *) wire [31:0] num_sample_to_skip;
(* mark_debug = "true" *) wire num_sample_changed;
(* mark_debug = "true" *) wire sample_in_strobe_dbg;
assign sample_in_strobe_dbg = sample_in_strobe ;

reg [31:0] sample_count;

(* mark_debug = "true" *) wire [15:0] input_i = sample_in[31:16];
reg [15:0] abs_i;
assign pw_state_spy = state ;

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
