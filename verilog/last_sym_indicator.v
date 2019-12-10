/*
* track ofdm symbol and give indication of end of all ofdm symbol
*/
module last_sym_indicator
(
    input clock,
    input reset,
    input enable,

    input ofdm_sym_valid,
    input [7:0] pkt_rate,//bit [7] 1 means ht; 0 means non-ht
    input [15:0] pkt_len,
    input ht_correction,

    output reg last_sym_flag
);

localparam S_WAIT_FOR_ALL_SYM = 0;
localparam S_ALL_SYM_RECEIVED = 1;

reg state;
reg ofdm_sym_valid_reg;

reg [8:0] n_dbps;
reg [7:0] n_ofdm_sym;
wire [16:0] n_bit;
wire [16:0] n_bit_target;

assign n_bit = n_dbps*(n_ofdm_sym+ht_correction);
assign n_bit_target = (({1'b0,pkt_len}<<3) + 16 + 6);

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

always @(posedge clock) begin
    if (reset) begin
        ofdm_sym_valid_reg <= 0;
    end else begin
        ofdm_sym_valid_reg <= ofdm_sym_valid;
    end
end

always @(posedge clock) begin
    if (reset) begin
        n_ofdm_sym <= 0;
        last_sym_flag <= 0;
        state <= S_WAIT_FOR_ALL_SYM;
    end else if (ofdm_sym_valid==0 && ofdm_sym_valid_reg==1) begin //falling edge means that current deinterleaving is finished, then we can start flush to speedup finishing work.
        n_ofdm_sym <= n_ofdm_sym + 1;
        if (enable) begin
            case(state)
                S_WAIT_FOR_ALL_SYM: begin
                    if ( (n_bit_target-n_bit)<=n_dbps ) begin
                        last_sym_flag <= 0;
                        state <= S_ALL_SYM_RECEIVED;
                    end
                end

                S_ALL_SYM_RECEIVED: begin
                    last_sym_flag <= 1;
                    state <= S_ALL_SYM_RECEIVED;
                end
                default: begin
                end
            endcase
        end
    end
end

endmodule
