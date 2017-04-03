module rand_gen_tb;

reg clock;
reg reset;
reg enable;

wire [7:0] rnd;

integer fd;

rand_gen inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .rnd(rnd)
);


initial begin
    clock = 0;
    reset = 1;
    enable = 0;

    fd = $fopen("./sim_out/rand_gen.txt", "w");

    # 10 reset = 0;
    enable = 1;

    # 10000000 $finish;
end


always begin
    #1 clock <= ~clock;
end

always @(posedge clock) begin
    if (enable) begin
        $fwrite(fd, "%d\n", rnd);
    end
end

endmodule
