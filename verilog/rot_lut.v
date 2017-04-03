`include "common_defs.v"

module rot_lut (
    input clka,
    input [`ROTATE_LUT_LEN_SHIFT-1:0] addra,
    output reg [31:0] douta
);

reg [31:0] ram [0:(1<<`ROTATE_LUT_LEN_SHIFT)-1];
initial begin
    $readmemb("./rot_lut.mif", ram);
end

always @(posedge clka) begin
    douta <= ram[addra];
end
endmodule
