module stage_mult
(
    input clock,
    input enable,
    input reset,

    input signed [31:0] X0,
    input signed [31:0] X1,
    input signed [31:0] X2,
    input signed [31:0] X3,
    input signed [31:0] X4,
    input signed [31:0] X5,
    input signed [31:0] X6,
    input signed [31:0] X7,

    input signed [31:0] Y0,
    input signed [31:0] Y1,
    input signed [31:0] Y2,
    input signed [31:0] Y3,
    input signed [31:0] Y4,
    input signed [31:0] Y5,
    input signed [31:0] Y6,
    input signed [31:0] Y7,

    input input_strobe,

    output reg [63:0] sum,
    output output_strobe
);

wire signed [15:0] X0_q = X0[31:16];
wire signed [15:0] X0_i = X0[15:0];
wire signed [15:0] X1_q = X1[31:16];
wire signed [15:0] X1_i = X1[15:0];
wire signed [15:0] X2_q = X2[31:16];
wire signed [15:0] X2_i = X2[15:0];
wire signed [15:0] X3_q = X3[31:16];
wire signed [15:0] X3_i = X3[15:0];
wire signed [15:0] X4_q = X4[31:16];
wire signed [15:0] X4_i = X4[15:0];
wire signed [15:0] X5_q = X5[31:16];
wire signed [15:0] X5_i = X5[15:0];
wire signed [15:0] X6_q = X6[31:16];
wire signed [15:0] X6_i = X6[15:0];
wire signed [15:0] X7_q = X7[31:16];
wire signed [15:0] X7_i = X7[15:0];

wire signed [15:0] Y0_q = Y0[31:16];
wire signed [15:0] Y0_i = Y0[15:0];
wire signed [15:0] Y1_q = Y1[31:16];
wire signed [15:0] Y1_i = Y1[15:0];
wire signed [15:0] Y2_q = Y2[31:16];
wire signed [15:0] Y2_i = Y2[15:0];
wire signed [15:0] Y3_q = Y3[31:16];
wire signed [15:0] Y3_i = Y3[15:0];
wire signed [15:0] Y4_q = Y4[31:16];
wire signed [15:0] Y4_i = Y4[15:0];
wire signed [15:0] Y5_q = Y5[31:16];
wire signed [15:0] Y5_i = Y5[15:0];
wire signed [15:0] Y6_q = Y6[31:16];
wire signed [15:0] Y6_i = Y6[15:0];
wire signed [15:0] Y7_q = Y7[31:16];
wire signed [15:0] Y7_i = Y7[15:0];

wire signed [31:0] prod_0_i;
wire signed [31:0] prod_0_q;
wire signed [31:0] prod_1_i;
wire signed [31:0] prod_1_q;
wire signed [31:0] prod_2_i;
wire signed [31:0] prod_2_q;
wire signed [31:0] prod_3_i;
wire signed [31:0] prod_3_q;
wire signed [31:0] prod_4_i;
wire signed [31:0] prod_4_q;
wire signed [31:0] prod_5_i;
wire signed [31:0] prod_5_q;
wire signed [31:0] prod_6_i;
wire signed [31:0] prod_6_q;
wire signed [31:0] prod_7_i;
wire signed [31:0] prod_7_q;

complex_multiplier mult_inst1 (
  .aclk(clock),
  .s_axis_a_tvalid(input_strobe),
  .s_axis_a_tdata({X0_i,X0_q}),
  .s_axis_b_tvalid(input_strobe),
  .s_axis_b_tdata({Y0_i,Y0_q}),
  .m_axis_dout_tvalid(),
  .m_axis_dout_tdata({prod_0_q,prod_0_i})
);

complex_multiplier mult_inst2 (
  .aclk(clock),
  .s_axis_a_tvalid(input_strobe),
  .s_axis_a_tdata({X1_i,X1_q}),
  .s_axis_b_tvalid(input_strobe),
  .s_axis_b_tdata({Y1_i,Y1_q}),
  .m_axis_dout_tvalid(),
  .m_axis_dout_tdata({prod_1_q,prod_1_i})
);

complex_multiplier mult_inst3 (
  .aclk(clock),
  .s_axis_a_tvalid(input_strobe),
  .s_axis_a_tdata({X2_i,X2_q}),
  .s_axis_b_tvalid(input_strobe),
  .s_axis_b_tdata({Y2_i,Y2_q}),
  .m_axis_dout_tvalid(),
  .m_axis_dout_tdata({prod_2_q,prod_2_i})
);

complex_multiplier mult_inst4 (
  .aclk(clock),
  .s_axis_a_tvalid(input_strobe),
  .s_axis_a_tdata({X3_i,X3_q}),
  .s_axis_b_tvalid(input_strobe),
  .s_axis_b_tdata({Y3_i,Y3_q}),
  .m_axis_dout_tvalid(),
  .m_axis_dout_tdata({prod_3_q,prod_3_i})
);

complex_multiplier mult_inst5 (
  .aclk(clock),
  .s_axis_a_tvalid(input_strobe),
  .s_axis_a_tdata({X4_i,X4_q}),
  .s_axis_b_tvalid(input_strobe),
  .s_axis_b_tdata({Y4_i,Y4_q}),
  .m_axis_dout_tvalid(),
  .m_axis_dout_tdata({prod_4_q,prod_4_i})
);

complex_multiplier mult_inst6 (
  .aclk(clock),
  .s_axis_a_tvalid(input_strobe),
  .s_axis_a_tdata({X5_i,X5_q}),
  .s_axis_b_tvalid(input_strobe),
  .s_axis_b_tdata({Y5_i,Y5_q}),
  .m_axis_dout_tvalid(),
  .m_axis_dout_tdata({prod_5_q,prod_5_i})
);

complex_multiplier mult_inst7 (
  .aclk(clock),
  .s_axis_a_tvalid(input_strobe),
  .s_axis_a_tdata({X6_i,X6_q}),
  .s_axis_b_tvalid(input_strobe),
  .s_axis_b_tdata({Y6_i,Y6_q}),
  .m_axis_dout_tvalid(),
  .m_axis_dout_tdata({prod_6_q,prod_6_i})
);

complex_multiplier mult_inst8 (
  .aclk(clock),
  .s_axis_a_tvalid(input_strobe),
  .s_axis_a_tdata({X7_i,X7_q}),
  .s_axis_b_tvalid(input_strobe),
  .s_axis_b_tdata({Y7_i,Y7_q}),
  .m_axis_dout_tvalid(),
  .m_axis_dout_tdata({prod_7_q,prod_7_i})
);

reg signed [31:0] sum_i1;
reg signed [31:0] sum_i2;
reg signed [31:0] sum_i3;
reg signed [31:0] sum_i4;
reg signed [31:0] sum_q1;
reg signed [31:0] sum_q2;
reg signed [31:0] sum_q3;
reg signed [31:0] sum_q4;

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
        sum_i3 <= 0;
        sum_i4 <= 0;
        sum_q1 <= 0;
        sum_q2 <= 0;
        sum_q3 <= 0;
        sum_q4 <= 0;
    end else if (enable) begin
        sum_i1 <= prod_0_i + prod_1_i;
        sum_i2 <= prod_2_i + prod_3_i;
        sum_i3 <= prod_4_i + prod_5_i;
        sum_i4 <= prod_6_i + prod_7_i;
        sum_q1 <= prod_0_q + prod_1_q;
        sum_q2 <= prod_2_q + prod_3_q;
        sum_q3 <= prod_4_q + prod_5_q;
        sum_q4 <= prod_6_q + prod_7_q;

        sum[63:32] <= sum_i1 + sum_i2 + sum_i3 + sum_i4;
        sum[31:0]  <= sum_q1 + sum_q2 + sum_q3 + sum_q4;
    end
end

endmodule
