module complex_to_mag
#(
    parameter DATA_WIDTH = 16
)
(
    input clock,
    input enable,
    input reset,

    input signed [DATA_WIDTH-1:0] i,
    input signed [DATA_WIDTH-1:0] q,
    input input_strobe,

    output reg [DATA_WIDTH-1:0] mag,
    output reg mag_stb
);

reg stage1;
reg stage2;

reg [DATA_WIDTH-1:0] abs_i;
reg [DATA_WIDTH-1:0] abs_q;

reg [DATA_WIDTH-1:0] max;
reg[ DATA_WIDTH-1:0] min;

// http://dspguru.com/dsp/tricks/magnitude-estimator
// alpha = 1, beta = 1/4
// avg err 0.006
always @(posedge clock) begin
    if (reset) begin
        mag <= 0;
        mag_stb <=0;
        abs_i <= 0;
        abs_q <= 0;
        max <= 0;
        min <= 0;
        stage1 <= 0;
        stage2 <= 0;
    end else if (enable) begin
        stage1 <= input_strobe;
        abs_i <= i[DATA_WIDTH-1]? (~i+1): i;
        abs_q <= q[DATA_WIDTH-1]? (~q+1): q;

        stage2 <= stage1;
        max <= abs_i > abs_q? abs_i: abs_q;
        min <= abs_i > abs_q? abs_q: abs_i;

        mag <= max + (min>>2);
        mag_stb <= stage2;
    end else begin
        mag_stb <= 0;
    end
end

endmodule
