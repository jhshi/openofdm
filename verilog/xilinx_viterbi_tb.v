module viterbi_tb;

reg clock;
reg reset;
reg enable;

localparam RAM_SIZE = 1<<25;
reg encoded_data [0:RAM_SIZE-1];
reg [31:0] encoded_data_addr;

reg decoded_data [0:RAM_SIZE-1];
reg [31:0] decoded_data_addr;

wire expected = decoded_data[decoded_data_addr];

reg [31:0] input_count;


localparam ENCODED_DATA_FILE = "./test_in/conv_encoded_data.txt";
localparam DECODED_DATA_FILE = "./test_in/conv_decoded_data.txt";

reg clr;
reg sym0;
reg sym1;

reg [31:0] error_count;

wire [15:0] ber;
wire ber_done;
wire data_out;
wire rdy;

viterbi_v7_0 viterbi_inst (
    .clk(clock),
    .ce(1),
    .sclr(clr),
    .data_in0(sym0),
    .data_in1(sym1),
    .rdy(rdy),
    .data_out(data_out)
);

initial begin
    $dumpfile("xilinx_viterbi_tb.vcd");
    $dumpvars;

    $display("Reading memory from %s ...", ENCODED_DATA_FILE);
    $readmemb(ENCODED_DATA_FILE, encoded_data);
    $readmemb(DECODED_DATA_FILE, decoded_data);
    $display("Done.");

    clock = 0;
    reset = 1;
    enable = 0;
    clr = 1;

    # 100 reset = 0;
    # 100 enable = 1;

    # 20000 $finish;
end


always begin
    #1 clock = !clock;
end

localparam S_INPUT = 0;
localparam S_FLUSH = 1;

reg [3:0] state;

localparam BITS_TO_DECODE = 48*6+48;


always @(posedge clock) begin
    if (reset) begin
        sym0 <= 0;
        sym1 <= 0;
        input_count <= 0;

        error_count <= 0;

        encoded_data_addr <= 0;
        decoded_data_addr <= 0;
        state <= S_INPUT;
    end else if (enable) begin
        clr <= 0;
        case(state)
            S_INPUT: begin
                if (input_count < BITS_TO_DECODE) begin
                    sym0 <= encoded_data[encoded_data_addr];
                    sym1 <= encoded_data[encoded_data_addr+1];
                    encoded_data_addr <= encoded_data_addr + 2;
                    input_count <= input_count + 2;
                end else begin
                    sym0 <= 0;
                    sym1 <= 0;
                    state <= S_FLUSH;
                end
            end

            S_FLUSH: begin
            end
        endcase

        if (rdy) begin
            $display("%d\t%d\t%d\t%d", decoded_data_addr, expected, data_out, error_count);
            if (data_out != expected) begin
                error_count <= error_count + 1;
                if (error_count > 500) begin
                    $display("too many errors.");
                    $finish;
                end
            end
            if (decoded_data_addr >= BITS_TO_DECODE/2) begin
                $finish;
            end else begin
                decoded_data_addr <= decoded_data_addr + 1;
            end
        end
    end
end

endmodule
