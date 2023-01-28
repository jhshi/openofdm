// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

// Calculate PHY related info:
// n_ofdm_sym, n_bit_in_last_sym (for decoding latency prediction)

module phy_len_calculation
(
    input clock,
    input reset,
    input enable,

    input [4:0]   state,
    input [4:0]   old_state,
    input [19:0]  num_bits_to_decode,
    input [7:0]   pkt_rate,//bit [7] 1 means ht; 0 means non-ht
    
    output reg [14:0] n_ofdm_sym,//max 20166 = (22+65535*8)/26
    output reg [19:0] n_bit_in_last_sym,//max ht ndbps 260
    output reg        phy_len_valid
);

reg start_calculation;
reg   end_calculation;

reg [8:0] n_dbps;

// lookup table for N_DBPS (Number of data bits per OFDM symbol)
always @( pkt_rate[7],pkt_rate[3:0] )
begin
    case ({pkt_rate[7],pkt_rate[3:0]})
        5'b01011 : begin //non-ht 6Mbps
            n_dbps = 24;
            end
        5'b01111 : begin //non-ht 9Mbps
            n_dbps = 36;
            end
        5'b01010 : begin //non-ht 12Mbps
            n_dbps = 48;
            end
        5'b01110 : begin //non-ht 18Mbps
            n_dbps = 72;
            end
        5'b01001 :  begin //non-ht 24Mbps
            n_dbps = 96;
            end
        5'b01101 : begin //non-ht 36Mbps
            n_dbps = 144;
            end
        5'b01000  : begin //non-ht 48Mbps
            n_dbps = 192;
            end
        5'b01100 : begin //non-ht 54Mbps
            n_dbps = 216;
            end
        5'b10000 : begin //ht mcs 0
            n_dbps = 26;
            end
        5'b10001 : begin //ht mcs 1
            n_dbps = 52;
            end
        5'b10010 : begin //ht mcs 2
            n_dbps = 78;
            end
        5'b10011 : begin //ht mcs 3
            n_dbps = 104;
            end
        5'b10100 :  begin //ht mcs 4
            n_dbps = 156;
            end
        5'b10101 : begin //ht mcs 5
            n_dbps = 208;
            end
        5'b10110  : begin //ht mcs 6
            n_dbps = 234;
            end
        5'b10111 : begin //ht mcs 7
            n_dbps = 260;
            end
        default: begin
            n_dbps = 0;
            end
    endcase
end

`include "common_params.v"
always @(posedge clock) begin
if (reset) begin
    n_ofdm_sym <= 1;
    n_bit_in_last_sym <= 130; // half of max num bits to have a rough mid-point estimation in case no calculation happen
    phy_len_valid <= 0;
    start_calculation <= 0;
    end_calculation <= 0;
end else begin
    if ( (state != S_HT_SIG_ERROR && old_state == S_CHECK_HT_SIG) || ((state == S_DECODE_DATA && (old_state == S_CHECK_SIGNAL || old_state == S_DETECT_HT))) ) begin
        n_bit_in_last_sym <= num_bits_to_decode;
        if (num_bits_to_decode <= n_dbps) begin
            phy_len_valid <= 1;
            end_calculation <= 1;
        end else begin
            start_calculation <= 1;
        end
    end

    if (start_calculation == 1 && end_calculation != 1) begin
        if (n_bit_in_last_sym <= n_dbps) begin
            phy_len_valid <= 1;
            end_calculation <= 1;
        end else begin
            n_bit_in_last_sym <= n_bit_in_last_sym - n_dbps;
            n_ofdm_sym = n_ofdm_sym + 1;
        end
    end
end
end

endmodule
