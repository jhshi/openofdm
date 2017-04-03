`include "common_defs.v"

/*
* Output: atan(addr/1024.0)*2048
* Delay: 1 cycle
*/
module atan_lut (
    input clka,
    input [`ATAN_LUT_LEN_SHIFT-1:0] addra,
    output reg [`ATAN_LUT_SCALE_SHIFT-1:0] douta
);

reg [`ATAN_LUT_SCALE_SHIFT-1:0] ram [0:(1<<`ATAN_LUT_LEN_SHIFT)-1];
initial begin
    $readmemb("./atan_lut.mif", ram);
end

always @(posedge clka) begin
    douta <= ram[addra];
end
endmodule
