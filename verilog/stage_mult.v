module stage_mult
(
    input clock,
    input enable,
    input reset,

    input signed [15:0] X0,
    input signed [15:0] X1,
    input signed [15:0] X2,
    input signed [15:0] X3,
    input signed [15:0] X4,
    input signed [15:0] X5,
    input signed [15:0] X6,
    input signed [15:0] X7,


    input signed [15:0] Y0,
    input signed [15:0] Y1,
    input signed [15:0] Y2,
    input signed [15:0] Y3,
    input signed [15:0] Y4,
    input signed [15:0] Y5,
    input signed [15:0] Y6,
    input signed [15:0] Y7,

    input input_strobe,

    output reg [63:0] sum,
    output output_strobe
);

wire signed [31:0] prod_0_i;
wire signed [31:0] prod_0_q;
wire signed [31:0] prod_1_i;
wire signed [31:0] prod_1_q;
wire signed [31:0] prod_2_i;
wire signed [31:0] prod_2_q;
wire signed [31:0] prod_3_i;
wire signed [31:0] prod_3_q;

complex_multiplier mult_inst1 (
    .clk(clock),
    .ar(X0),
    .ai(X1),
    .br(Y0),
    .bi(Y1),
    .pr(prod_0_i),
    .pi(prod_0_q)
);

complex_multiplier mult_inst2 (
    .clk(clock),
    .ar(X2),
    .ai(X3),
    .br(Y2),
    .bi(Y3),
    .pr(prod_1_i),
    .pi(prod_1_q)
);

complex_multiplier mult_inst3 (
    .clk(clock),
    .ar(X4),
    .ai(X5),
    .br(Y4),
    .bi(Y5),
    .pr(prod_2_i),
    .pi(prod_2_q)
);

complex_multiplier mult_inst4 (
    .clk(clock),
    .ar(X6),
    .ai(X7),
    .br(Y6),
    .bi(Y7),
    .pr(prod_3_i),
    .pi(prod_3_q)
);

reg signed [31:0] sum_i1;
reg signed [31:0] sum_i2;
reg signed [31:0] sum_q1;
reg signed [31:0] sum_q2;

delayT #(.DATA_WIDTH(1), .DELAY(5)) sum_delay_inst (
    .clock(clock),
    .reset(reset),

    .data_in(input_strobe),
    .data_out(output_strobe)
);

always @(posedge clock) begin
    if (reset) begin
        sum <= 0;
        sum_i1 <= 0;
        sum_i2 <= 0;
        sum_q1 <= 0;
        sum_q2 <= 0;
    end else if (enable) begin
        sum_i1 <= prod_0_i + prod_1_i;
        sum_i2 <= prod_2_i + prod_3_i;
        sum_q1 <= prod_0_q + prod_1_q;
        sum_q2 <= prod_2_q + prod_3_q;

        sum[63:32] <= sum_i1 + sum_i2;
        sum[31:0] <= sum_q1 + sum_q2;
    end
end

endmodule
