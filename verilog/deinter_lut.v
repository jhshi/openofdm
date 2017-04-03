module deinter_lut
#(
    parameter DWIDTH = 22,
    parameter AWIDTH = 11
)
(
    input clka,
    input [AWIDTH-1:0] addra,
    output reg [DWIDTH-1:0] douta
);

reg [DWIDTH-1:0] ram [0:(1<<AWIDTH)-1];

initial begin
    $readmemb("./deinter_lut.mif", ram);
end

always @(posedge clka) begin
    if (ena) begin
        douta <= ram[addra];
    end
end

endmodule
