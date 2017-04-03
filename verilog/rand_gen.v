module rand_gen
(
    input clock,
    input enable,
    input reset,

    output reg [7:0] rnd
);

localparam LFSR_LEN = 128;

reg [LFSR_LEN-1:0] random;
wire feedback = random[127] ^ random[125] ^ random[100] ^ random[98];
reg [2:0] bit_idx;

always @(posedge clock) begin
    if (reset) begin
        random <= {LFSR_LEN{4'b0101}};
        bit_idx <= 0;
        rnd <= 0;
    end else if (enable) begin
        random <= {random[LFSR_LEN-2:0], feedback};
        rnd[bit_idx] <= feedback;
        bit_idx <= bit_idx + 1;
    end
end

endmodule
