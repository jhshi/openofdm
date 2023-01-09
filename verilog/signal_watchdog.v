// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

module signal_watchdog
#(
    parameter integer IQ_DATA_WIDTH	= 16,
    parameter LOG2_SUM_LEN = 6
)
(
    input clk,
    input rstn,
    input enable,

    input signed [(IQ_DATA_WIDTH-1):0] i_data,
    input signed [(IQ_DATA_WIDTH-1):0] q_data,
    input iq_valid,

    input power_trigger,

    input [15:0] signal_len,
    input sig_valid,

    input [15:0] min_signal_len_th,
    input [15:0] max_signal_len_th,
    input signed [(LOG2_SUM_LEN+2-1):0] dc_running_sum_th,

    output receiver_rst
);
    wire signed [1:0] i_sign;
    wire signed [1:0] q_sign;
    reg  signed [1:0] fake_non_dc_in_case_all_zero;
    wire signed [(LOG2_SUM_LEN+2-1):0] running_sum_result_i;
    wire signed [(LOG2_SUM_LEN+2-1):0] running_sum_result_q;
    wire signed [(LOG2_SUM_LEN+2-1):0] running_sum_result_i_abs;
    wire signed [(LOG2_SUM_LEN+2-1):0] running_sum_result_q_abs;

    wire receiver_rst_internal;
    reg receiver_rst_reg;
    wire receiver_rst_pulse;

    assign i_sign = (i_data == 0? fake_non_dc_in_case_all_zero : (i_data[(IQ_DATA_WIDTH-1)] ? -1 : 1) );
    assign q_sign = (q_data == 0? fake_non_dc_in_case_all_zero : (q_data[(IQ_DATA_WIDTH-1)] ? -1 : 1) );

    assign running_sum_result_i_abs = (running_sum_result_i[LOG2_SUM_LEN+2-1]?(-running_sum_result_i):running_sum_result_i);
    assign running_sum_result_q_abs = (running_sum_result_q[LOG2_SUM_LEN+2-1]?(-running_sum_result_q):running_sum_result_q);

    assign receiver_rst_internal = (enable&(running_sum_result_i_abs>=dc_running_sum_th || running_sum_result_q_abs>=dc_running_sum_th));

    assign receiver_rst_pulse = (receiver_rst_internal&&(~receiver_rst_reg));

    assign receiver_rst = ( power_trigger & ( receiver_rst_reg | (sig_valid && (signal_len<min_signal_len_th || signal_len>max_signal_len_th)) ) );

    always @(posedge clk) begin
        if (~rstn) begin
            receiver_rst_reg <= 0;
            fake_non_dc_in_case_all_zero <= 1;
        end else begin
            receiver_rst_reg <= receiver_rst_internal;
            if (iq_valid) begin
                if (fake_non_dc_in_case_all_zero == 1) begin
                    fake_non_dc_in_case_all_zero <= -1;
                end else begin
                    fake_non_dc_in_case_all_zero <= 1;
                end
            end
        end
    end

    running_sum_dual_ch #(.DATA_WIDTH0(2), .DATA_WIDTH1(2), .LOG2_SUM_LEN(LOG2_SUM_LEN)) signal_watchdog_running_sum_inst (
        .clk(clk),
        .rstn(rstn),

        .data_in0(i_sign),
        .data_in1(q_sign),
        .data_in_valid(iq_valid),
        .running_sum_result0(running_sum_result_i),
        .running_sum_result1(running_sum_result_q),
        .data_out_valid()
    );

endmodule
