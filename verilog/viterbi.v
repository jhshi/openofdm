/*
* A wrapper of Xilinx Viterbi IP core
* Added strobe signal.
*/
module viterbi
(
    input clock,
    input enable,
    input reset,

    input [2:0] sym0,
    input [2:0] sym1,
    input [1:0] erase,
    input input_strobe,

    output out_bit,
    output output_strobe
);

viterbi_v7_0 viterbi_inst (
    .clk(clock),
    .ce(reset | (enable & input_strobe)),
    .sclr(reset),
    .data_in0(sym0),
    .data_in1(sym1),
    .erase(erase),
    .rdy(output_strobe),
    .data_out(out_bit)
);

endmodule
