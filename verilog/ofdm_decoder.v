module ofdm_decoder
(
    input clock,
    input enable,
    input reset,

    input [31:0] sample_in,
    input sample_in_strobe,

    // decode instructions
    input [7:0] rate,
    input do_descramble,
    input [31:0] num_bits_to_decode,

    output [5:0] demod_out,
    output demod_out_strobe,

    output [1:0] deinterleave_out,
    output deinterleave_out_strobe,

    output conv_decoder_out,
    output conv_decoder_out_stb,

    output descramble_out,
    output descramble_out_strobe,

    output [7:0] byte_out,
    output byte_out_strobe
);

reg conv_in_stb;
reg [2:0] conv_in0;
reg [2:0] conv_in1;
reg [1:0] conv_erase;

wire [15:0] input_i = sample_in[31:16];
wire [15:0] input_q = sample_in[15:0];

wire vit_ce = reset | (enable & conv_in_stb);
wire vit_clr = reset;
wire vit_rdy;

wire [1:0] erase;

assign conv_decoder_out_stb = vit_ce & vit_rdy;

reg [3:0] skip_bit;
reg bit_in;
reg bit_in_stb;

reg [31:0] deinter_out_count;
reg flush;

demodulate demod_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),

    .rate(rate),
    .cons_i(input_i),
    .cons_q(input_q),
    .input_strobe(sample_in_strobe),
    .bits(demod_out),
    .output_strobe(demod_out_strobe)
);

deinterleave deinterleave_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),

    .rate(rate),
    .in_bits(demod_out),
    .input_strobe(demod_out_strobe),

    .out_bits(deinterleave_out),
    .output_strobe(deinterleave_out_strobe),
    .erase(erase)
);

viterbi_v7_0 viterbi_inst (
    .clk(clock),
    .ce(vit_ce),
    .sclr(vit_clr),
    .data_in0(conv_in0),
    .data_in1(conv_in1),
    .erase(conv_erase),
    .rdy(vit_rdy),
    .data_out(conv_decoder_out)
);


descramble decramble_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),
    
    .in_bit(conv_decoder_out),
    .input_strobe(conv_decoder_out_stb),

    .out_bit(descramble_out),
    .output_strobe(descramble_out_strobe)
);


bits_to_bytes byte_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .bit_in(bit_in),
    .input_strobe(bit_in_stb),

    .byte_out(byte_out),
    .output_strobe(byte_out_strobe)
);

always @(posedge clock) begin
    if (reset) begin
        conv_in_stb <= 0;
        conv_in0 <= 0;
        conv_in1 <= 0;
        conv_erase <= 0;

        bit_in <= 0;
        // skip the first 9 bits of descramble out (service bits)
        skip_bit <= 9;
        bit_in_stb <= 0;

        flush <= 0;
        deinter_out_count <= 0;
    end else if (enable) begin
        if (deinterleave_out_strobe) begin
            deinter_out_count <= deinter_out_count + 2;
        end else begin
            // wait for finishing deinterleaving current symbol
            // only do flush for non-DATA bits, such as SIG and HT-SIG, which
            // are not scrambled
            if (~do_descramble && deinter_out_count >= num_bits_to_decode) begin
                flush <= 1;
            end
        end
        if (!flush) begin
            conv_in_stb <= deinterleave_out_strobe;
            conv_in0 <= deinterleave_out[0]? 3'b111: 3'b011;
            conv_in1 <= deinterleave_out[1]? 3'b111: 3'b011;
            conv_erase <= erase;
        end else begin
            conv_in_stb <= 1;
            conv_in0 <= 3'b011;
            conv_in1 <= 3'b011;
            conv_erase <= 0;
        end

        if (deinter_out_count > 0) begin
            if (~do_descramble) begin
                bit_in <= conv_decoder_out;
                bit_in_stb <= conv_decoder_out_stb;
            end else begin
                bit_in <= descramble_out;
                if (descramble_out_strobe) begin
                    if (skip_bit > 0 ) begin
                        skip_bit <= skip_bit - 1;
                        bit_in_stb <= 0;
                    end else begin
                        bit_in_stb <= 1;
                    end
                end else begin
                    bit_in_stb <= 0;
                end
            end
        end
    end
end

endmodule
