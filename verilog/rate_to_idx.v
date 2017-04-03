// translate rate to idx
// rate format
// MSB = 0 --> 802.11a rates, rate[3:0] is the rate bits
// MSB = 1 --> 802.11n MCS, rate[6:0] is the MCS
module rate_to_idx
(
    input clock,
    input enable,
    input reset,

    input [7:0] rate,
    input input_strobe,

    output reg [7:0] idx,
    output reg output_strobe
);

always @(posedge clock) begin
    if (reset) begin
        idx <= 0;
        output_strobe <= 0;
    end else if (enable & input_strobe) begin
        case ({rate[7], rate[2:0]})
            4'b0011: begin
                // 6 mbps
                idx <= 0;
            end
            4'b0111: begin
                // 9 mbps
                idx <= 1;
            end
            4'b0010: begin
                // 12 mbps
                idx <= 2;
            end
            4'b0110: begin
                // 18 mbps
                idx <= 3;
            end
            4'b0001: begin
                // 24 mbps
                idx <= 4;
            end
            4'b0101: begin
                // 36 mbps
                idx <= 5;
            end
            4'b0000: begin
                // 48 mbps
                idx <= 6;
            end
            4'b0100: begin
                // 54 mbps
                idx <= 7;
            end
            default: begin
                // mcs
                idx <= {5'b0, rate[2:0]};
            end
        endcase
        output_strobe <= 1;
    end else begin
        output_strobe <= 0;
    end
end

endmodule
