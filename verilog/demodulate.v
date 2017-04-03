`include "common_defs.v"

module demodulate (
    input clock,
    input enable,
    input reset,

    input [7:0] rate,
    input [15:0] cons_i,
    input [15:0] cons_q,
    input input_strobe,

    output reg [5:0] bits,
    output output_strobe
);

localparam MAX = 1<<`CONS_SCALE_SHIFT;

localparam QAM_16_DIV = MAX*2/3;

localparam QAM_64_DIV_0 = MAX*2/7;
localparam QAM_64_DIV_1 = MAX*4/7;
localparam QAM_64_DIV_2 = MAX*6/7;

localparam BPSK = 1;
localparam QPSK = 2;
localparam QAM_16 = 3;
localparam QAM_64 = 4;

reg [15:0] cons_i_delayed;
reg [15:0] cons_q_delayed;
reg [15:0] abs_cons_i;
reg [15:0] abs_cons_q;

reg [2:0] mod;


delayT #(.DATA_WIDTH(1), .DELAY(2)) stb_delay_inst (
    .clock(clock),
    .reset(reset),

    .data_in(input_strobe),
    .data_out(output_strobe)
);


always @(posedge clock) begin
    if (reset) begin
        bits <= 0;
        abs_cons_i <= 0;
        abs_cons_q <= 0;
        cons_i_delayed <= 0;
        cons_q_delayed <= 0;
        mod <= 0;
    end else if (enable) begin
        abs_cons_i <= cons_i[15]? ~cons_i+1: cons_i;
        abs_cons_q <= cons_q[15]? ~cons_q+1: cons_q;
        cons_i_delayed <= cons_i;
        cons_q_delayed <= cons_q;

        case({rate[7], rate[3:0]})
            // 802.11a rates
            5'b01011: begin mod <= BPSK;    end
            5'b01111: begin mod <= BPSK;    end
            5'b01010: begin mod <= QPSK;    end
            5'b01110: begin mod <= QPSK;    end
            5'b01001: begin mod <= QAM_16;  end
            5'b01101: begin mod <= QAM_16;  end
            5'b01000: begin mod <= QAM_64;  end
            5'b01100: begin mod <= QAM_64;  end

            // 802.11n rates
            5'b10000: begin mod <= BPSK;    end
            5'b10001: begin mod <= QPSK;    end
            5'b10010: begin mod <= QPSK;    end
            5'b10011: begin mod <= QAM_16;  end
            5'b10100: begin mod <= QAM_16;  end
            5'b10101: begin mod <= QAM_64;  end
            5'b10110: begin mod <= QAM_64;  end
            5'b10111: begin mod <= QAM_64;  end

            default: begin mod <= BPSK; end
        endcase

        case(mod)
            BPSK: begin
                bits[0] <= ~cons_i_delayed[15];
                bits[5:1] <= 0;
            end
            QPSK: begin
                bits[0] <= ~cons_i_delayed[15];
                bits[1] <= ~cons_q_delayed[15];
                bits[5:2] <= 0;
            end
            QAM_16: begin
                bits[0] <= ~cons_i_delayed[15];
                bits[1] <= abs_cons_i < QAM_16_DIV? 1: 0;
                bits[2] <= ~cons_q_delayed[15];
                bits[3] <= abs_cons_q < QAM_16_DIV? 1: 0;
                bits[5:4] <= 0;
            end
            QAM_64: begin
                bits[0] <= ~cons_i_delayed[15];
                bits[1] <= abs_cons_i < QAM_64_DIV_1? 1: 0;
                bits[2] <= abs_cons_i > QAM_64_DIV_0 &&
                    abs_cons_i < QAM_64_DIV_2? 1: 0;
                bits[3] <= ~cons_q_delayed[15];
                bits[4] <= abs_cons_q < QAM_64_DIV_1? 1: 0;
                bits[5] <= abs_cons_q > QAM_64_DIV_0 &&
                    abs_cons_q < QAM_64_DIV_2? 1: 0;
            end
        endcase
    end
end

endmodule
