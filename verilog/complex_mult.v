module complex_mult
(
    input clock,
    input enable,
    input reset,

    input [15:0] a_i,
    input [15:0] a_q,
    input [15:0] b_i,
    input [15:0] b_q,
    input input_strobe,

    output reg [31:0] p_i,
    output reg [31:0] p_q,
    output output_strobe
);

localparam DELAY = 4;
reg [DELAY-1:0] delay;

reg [15:0] ar;
reg [15:0] ai;
reg [15:0] br;
reg [15:0] bi;

wire [31:0] prod_i;
wire [31:0] prod_q;

complex_multiplier mult_inst (
    .clk(clock),
    .ar(ar),
    .ai(ai),
    .br(br),
    .bi(bi),
    .pr(prod_i),
    .pi(prod_q)
);

delayT #(.DATA_WIDTH(1), .DELAY(5)) stb_delay_inst (
    .clock(clock),
    .reset(reset),

    .data_in(input_strobe),
    .data_out(output_strobe)
);

always @(posedge clock) begin
    if (reset) begin
        ar <= 0;
        ai <= 0;
        br <= 0;
        bi <= 0;
        p_i <= 0;
        p_q <= 0;
        delay <= 0;
    end else if (enable) begin
        ar <= a_i;
        ai <= a_q;
        br <= b_i;
        bi <= b_q;

        p_i <= prod_i;
        p_q <= prod_q;
    end
end

endmodule
