/********************************************************           
    * An interface to assemble bytes into 64 bits.         *   
    *                                                      *   
    * Author:  Wei Liu                                     *     
    ********************************************************/  
module intf_64bit (
    input clock,
    input reset,
    input enable,
    input wire [15:0] pkt_len,
    input wire [31:0] byte_index,
    input wire [7:0] byte_in,
    input wire byte_strobe,

    output reg [63:0] data_out,
    output reg output_strobe
);


    reg byte_strobe_delay ;
    reg [63:0] dout ; 
    always @ (posedge clock)
    begin
        byte_strobe_delay <= byte_strobe ;
        //data_out <= dout ;
    end
    
    always @ (posedge clock)
    begin
        if(reset) begin
            dout <= 64'h0 ;
            data_out <= 64'h0;
            output_strobe <= 1'b0 ;
        end  
        else if(enable) begin
            output_strobe <= 1'b0 ;
            data_out <= dout ;
            if(byte_strobe) begin
                dout <= {byte_in, dout[63:8]} ;
            end
            if(byte_strobe_delay) begin
                if(byte_index[2:0] == 3'b0 && byte_index[31:3] > 0 )
                    output_strobe <= 1'b1 ;
                else if (pkt_len == byte_index) begin
                    output_strobe <= 1'b1 ;
                    case (pkt_len[2:0])
                        3'b000: data_out <= dout;
                        3'b001: begin data_out <= {56'b0,dout[63:56]}; dout <= {56'b0,dout[63:56]}; end
                        3'b010: begin data_out <= {48'b0,dout[63:48]}; dout <= {48'b0,dout[63:48]}; end
                        3'b011: begin data_out <= {40'b0,dout[63:40]}; dout <= {40'b0,dout[63:40]}; end
                        3'b100: begin data_out <= {32'b0,dout[63:32]}; dout <= {32'b0,dout[63:32]}; end
                        3'b101: begin data_out <= {24'b0,dout[63:24]}; dout <= {24'b0,dout[63:24]}; end
                        3'b110: begin data_out <= {16'b0,dout[63:16]}; dout <= {16'b0,dout[63:16]}; end
                        3'b111: begin data_out <= {8'b0,dout[63:8]};   dout <= {8'b0,dout[63:8]};   end  
                        default: data_out <= dout;
                    
                    endcase
                
                end
                  
            end
        
        end
    
    end

endmodule
