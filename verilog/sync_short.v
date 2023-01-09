`include "common_defs.v"

module sync_short (
    input clock,
    input reset,
    input enable,

    input [31:0] min_plateau,
    input threshold_scale,

    input [31:0] sample_in,
    input sample_in_strobe,

    input demod_is_ongoing,
    output reg short_preamble_detected,

    input [15:0] phase_out,
    input phase_out_stb,

    output [31:0] phase_in_i,
    output [31:0] phase_in_q,
    output phase_in_stb,

    output reg signed [15:0] phase_offset
);
`include "common_params.v"

localparam WINDOW_SHIFT = 4;
localparam DELAY_SHIFT = 4;

reg reset_delay1;
reg reset_delay2;
reg reset_delay3;
reg reset_delay4;

wire [31:0] mag_sq;
wire mag_sq_stb;

wire [31:0] mag_sq_avg;
wire mag_sq_avg_stb;
reg [31:0] prod_thres;

wire [31:0] sample_delayed;
wire sample_delayed_stb;

reg [31:0] sample_delayed_conj;
reg sample_delayed_conj_stb;

wire [63:0] prod;
wire prod_stb;

wire [63:0] prod_avg;
wire prod_avg_stb;

reg [15:0] phase_out_neg;
reg [15:0] phase_offset_neg;

wire [31:0] delay_prod_avg_mag;
wire delay_prod_avg_mag_stb;

reg [31:0] plateau_count;

// this is to ensure that the short preambles contains both positive and
// negative in-phase, to avoid raise false positives when there is a constant
// power
reg [31:0] pos_count;
reg [31:0] min_pos;
reg has_pos;
reg [31:0] neg_count;
reg [31:0] min_neg;
reg has_neg;

//wire [31:0] min_plateau;

// minimal number of samples that has to exceed plateau threshold to claim
// a short preamble
/*setting_reg #(.my_addr(SR_MIN_PLATEAU), .width(32), .at_reset(100)) sr_0 (
    .clk(clock), .rst(reset), .strobe(set_stb), .addr(set_addr), .in(set_data),
    .out(min_plateau), .changed());*/

complex_to_mag_sq mag_sq_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .i(sample_in[31:16]),
    .q(sample_in[15:0]),
    .input_strobe(sample_in_strobe),

    .mag_sq(mag_sq),
    .mag_sq_strobe(mag_sq_stb)
);

// moving_avg #(.DATA_WIDTH(32), .WINDOW_SHIFT(WINDOW_SHIFT)) mag_sq_avg_inst (
//     .clock(clock),
//     .enable(enable),
//     .reset(reset),

//     .data_in(mag_sq),
//     .input_strobe(mag_sq_stb),
//     .data_out(mag_sq_avg),
//     .output_strobe(mag_sq_avg_stb)
// );
mv_avg #(.DATA_WIDTH(33), .LOG2_AVG_LEN(WINDOW_SHIFT)) mag_sq_avg_inst (
    .clk(clock),
    .rstn(~(reset|reset_delay1|reset_delay2|reset_delay3|reset_delay4)),
    // .rstn(~reset),

    .data_in({1'd0, mag_sq}),
    .data_in_valid(mag_sq_stb),
    .data_out(mag_sq_avg),
    .data_out_valid(mag_sq_avg_stb)
);

// delay_sample #(.DATA_WIDTH(32), .DELAY_SHIFT(DELAY_SHIFT)) sample_delayed_inst (
//     .clock(clock),
//     .enable(enable),
//     .reset(reset),

//     .data_in(sample_in),
//     .input_strobe(sample_in_strobe),
//     .data_out(sample_delayed),
//     .output_strobe(sample_delayed_stb)
// );

fifo_sample_delay # (.DATA_WIDTH(32), .LOG2_FIFO_DEPTH(5)) sample_delayed_inst (
    .clk(clock),
    .rst(reset|reset_delay1|reset_delay2|reset_delay3|reset_delay4),
    .delay_ctl(16),
    .data_in(sample_in),
    .data_in_valid(sample_in_strobe),
    .data_out(sample_delayed),
    .data_out_valid(sample_delayed_stb)
);

complex_mult delay_prod_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .a_i(sample_in[31:16]),
    .a_q(sample_in[15:0]),
    .b_i(sample_delayed_conj[31:16]),
    .b_q(sample_delayed_conj[15:0]),
    .input_strobe(sample_delayed_conj_stb),

    .p_i(prod[63:32]),
    .p_q(prod[31:0]),
    .output_strobe(prod_stb)
);

// moving_avg #(.DATA_WIDTH(32), .WINDOW_SHIFT(WINDOW_SHIFT))
// delay_prod_avg_i_inst (
//     .clock(clock),
//     .enable(enable),
//     .reset(reset),
//     .data_in(prod[63:32]),
//     .input_strobe(prod_stb),
//     .data_out(prod_avg[63:32]),
//     .output_strobe(prod_avg_stb)
// );

// moving_avg #(.DATA_WIDTH(32), .WINDOW_SHIFT(WINDOW_SHIFT)) 
// delay_prod_avg_q_inst (
//     .clock(clock),
//     .enable(enable),
//     .reset(reset),
//     .data_in(prod[31:0]),
//     .input_strobe(prod_stb),
//     .data_out(prod_avg[31:0])
// );

mv_avg_dual_ch #(.DATA_WIDTH0(32), .DATA_WIDTH1(32), .LOG2_AVG_LEN(WINDOW_SHIFT)) delay_prod_avg_inst (
    .clk(clock),
    .rstn(~(reset|reset_delay1|reset_delay2|reset_delay3|reset_delay4)),
    // .rstn(~reset),

    .data_in0(prod[63:32]),
    .data_in1(prod[31:0]),
    .data_in_valid(prod_stb),

    .data_out0(prod_avg[63:32]),
    .data_out1(prod_avg[31:0]),
    .data_out_valid(prod_avg_stb)
);

mv_avg_dual_ch #(.DATA_WIDTH0(32), .DATA_WIDTH1(32), .LOG2_AVG_LEN(6)) freq_offset_inst (
    .clk(clock),
    .rstn(~(reset|reset_delay1|reset_delay2|reset_delay3|reset_delay4)),
    // .rstn(~reset),
    
    .data_in0(prod[63:32]),
    .data_in1(prod[31:0]),
    .data_in_valid(prod_stb),

    .data_out0(phase_in_i),
    .data_out1(phase_in_q),
    .data_out_valid(phase_in_stb)
);

complex_to_mag #(.DATA_WIDTH(32)) delay_prod_avg_mag_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),

    .i(prod_avg[63:32]),
    .q(prod_avg[31:0]),
    .input_strobe(prod_avg_stb),
    .mag(delay_prod_avg_mag),
    .mag_stb(delay_prod_avg_mag_stb)
);

always @(posedge clock) begin
    if (reset) begin
        reset_delay1 <= reset;
        reset_delay2 <= reset;
        reset_delay3 <= reset;
        reset_delay4 <= reset;

        sample_delayed_conj <= 0;
        sample_delayed_conj_stb <= 0;

        pos_count <= 0;
        min_pos <= 0;
        has_pos <= 0;

        neg_count <= 0;
        min_neg <= 0;
        has_neg <= 0;

        prod_thres <= 0;

        plateau_count <= 0;
        short_preamble_detected <= 0;
        phase_offset <= phase_offset; // do not clear it. sync short will reset soon after stf detected, but sync long still needs it.
    end else if (enable) begin
        reset_delay4 <= reset_delay3;
        reset_delay3 <= reset_delay2;
        reset_delay2 <= reset_delay1;
        reset_delay1 <= reset;

        sample_delayed_conj_stb <= sample_delayed_stb;
        sample_delayed_conj[31:16] <= sample_delayed[31:16];
        sample_delayed_conj[15:0] <= ~sample_delayed[15:0]+1;

        min_pos <= min_plateau>>2;
        min_neg <= min_plateau>>2;
        has_pos <= pos_count > min_pos;
        has_neg <= neg_count > min_neg;

        phase_out_neg <= ~phase_out + 1;
        phase_offset_neg <= {{4{phase_out[15]}}, phase_out[15:4]};

        prod_thres <= ( threshold_scale? ({2'b0, mag_sq_avg[31:2]} + {3'b0, mag_sq_avg[31:3]}):({1'b0, mag_sq_avg[31:1]} + {2'b0, mag_sq_avg[31:2]}) );
        
        if (delay_prod_avg_mag_stb) begin
            if (delay_prod_avg_mag > prod_thres) begin
                if (sample_in[31]) begin
                    neg_count <= neg_count + 1;
                end else begin
                    pos_count <= pos_count + 1;
                end
                if (plateau_count > min_plateau) begin
                    plateau_count <= 0;
                    pos_count <= 0;
                    neg_count <= 0;
                    short_preamble_detected <= has_pos & has_neg;
                    if (has_pos && has_neg && demod_is_ongoing==0) begin // only update and lock phase_offset to new value when short_preamble_detected and not start demod yet
                        if(phase_out_neg[3] == 0)  // E.g. 131/16 = 8.1875 -> 8, -138/16 = -8.625 -> -9
                            phase_offset <= {{4{phase_out_neg[15]}}, phase_out_neg[15:4]};
                        else  // E.g. -131/16 = -8.1875 -> -8, 138/16 = 8.625 -> 9
                            phase_offset <= ~phase_offset_neg + 1;
                    end
                end else begin
                    plateau_count <= plateau_count + 1;
                    short_preamble_detected <= 0;
                end
            end else begin
                plateau_count <= 0;
                pos_count <= 0;
                neg_count <= 0;
                short_preamble_detected <= 0;
            end
        end else begin
            short_preamble_detected <= 0;
        end
    end else begin
        short_preamble_detected <= 0;
    end
end

endmodule
