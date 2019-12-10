
`timescale 1 ns / 1 ps

	module dot11zynq #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 7
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line
        input wire enable,
        input wire [31:0] sample_in,
        input wire sample_in_strobe,
        output wire trigger,
        
        output wire ofdm_byte_valid,
        output wire [7:0] ofdm_byte,
        output wire [63:0] data_out,
        output wire data_out_valid,
        output wire fcs_valid,
        output wire fcs_invalid,
        
        output wire sig_valid,
        output wire sig_invalid,
        output wire [2:0] mcs_io,
        output wire [11:0] pkt_len_io,
        
        output wire [6:0] ht_mcs_io,
        output wire [15:0] ht_pkt_len_io,
        output wire ht_sig_invalid,
        output wire ht_sig_valid,
        output wire ht_unsupported,
        
        
        // ports to interract with fifo
        input wire fifo_empty,
        output wire rd_en,
        output wire fifo_rst,
		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
	dot11zynq_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) dot11zynq_S00_AXI_inst (
	    // user ports
	        .enable(enable),
            .sample_in(sample_in),
            .sample_in_strobe(sample_in_strobe),
            .trigger(trigger),
            
            .ofdm_byte_valid(ofdm_byte_valid),
            .ofdm_byte(ofdm_byte),
            .data_out(data_out),
            .data_out_valid(data_out_valid),
            .fcs_valid(fcs_valid),
            .fcs_invalid(fcs_invalid),
            
            .sig_valid(sig_valid),
            .sig_invalid(sig_invalid),
            .mcs_io(mcs_io),
            .pkt_len_io(pkt_len_io),
            
            .ht_mcs_io(ht_mcs_io),
            .ht_pkt_len_io(ht_pkt_len_io),
            .ht_sig_invalid(ht_sig_invalid),
            .ht_sig_valid(ht_sig_valid),
            .ht_unsupported(ht_unsupported),
            
            .fifo_empty(fifo_empty),
            .rd_en(rd_en),
            .fifo_rst(fifo_rst),
        // user ports end
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
