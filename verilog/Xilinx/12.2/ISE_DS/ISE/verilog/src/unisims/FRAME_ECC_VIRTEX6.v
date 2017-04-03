// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/blanc/FRAME_ECC_VIRTEX6.v,v 1.4 2010/02/10 23:34:59 yanx Exp $
///////////////////////////////////////////////////////
//  Copyright (c) 2009 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version : 10.1
//  \  \           Description : 
//  /  /                      
// /__/   /\       Filename    : FRAME_ECC_VIRTEX6.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:		1.0
///////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

module FRAME_ECC_VIRTEX6 (
  CRCERROR,
  ECCERROR,
  ECCERRORSINGLE,
  FAR,
  SYNBIT,
  SYNDROME,
  SYNDROMEVALID,
  SYNWORD
);


  parameter FARSRC = "EFAR";
  parameter FRAME_RBT_IN_FILENAME = "frame_rbt_v6.txt";
  localparam FRAME_ECC_OUT_RBT_FILENAME = "frame_rbt_out_v6.txt";
  localparam FRAME_ECC_OUT_ECC_FILENAME = "frame_ecc_out_v6.txt";

  output CRCERROR;
  output ECCERROR;
  output ECCERRORSINGLE;
  output SYNDROMEVALID;
  output [12:0] SYNDROME;
  output [23:0] FAR;
  output [4:0] SYNBIT;
  output [6:0] SYNWORD;

  reg clk_osc = 0;
  integer rbt_fd;
  integer ecc_ecc_out_fd;
  integer ecc_rbt_out_fd;
  reg [31:0]  rb_data = 32'b0;
  reg [31:0] data_rbt; 
  reg [31:0] tmpwd1;
  reg [31:0] tmpwd2;
  reg sim_file_flag = 0;
  reg [31:0] frame_data_bak[255:174];
  reg [31:0] frame_data[255:174];
  integer   frame_addr_i;
  reg [31:0] frame_addr;
  reg [31:0] rb_crc_rbt;
  reg [31:0] crc_curr = 32'b0;
  reg [31:0] crc_new = 32'b0;
  reg [36:0] crc_input = 32'b0;
  reg rbcrc_err = 0;
  reg rd_rbt_hold = 0;
  reg rd_rbt_hold1 = 0;
  reg rd_rbt_hold2 = 0;
  reg [6:0] ecc_wadr;
  reg [4:0] ecc_badr;
  reg [31:0] corr_wd;
  reg [31:0] corr_wd1; 
  reg rb_data_en = 0;
  reg end_rbt = 0;
  reg rd_rbt_en = 0;
  reg hamming_rst = 0;
  integer i = 0;
  integer bi = 174;
  integer nbi = 174;
  integer n = 174;
  
  reg ecc_run = 0;
  reg calc_syndrome = 1;
  wire [12:0]   new_S;
  wire [12:0]   next_S;
  reg  [12:0]   S = 13'd0;         
  reg           S_valid = 0;
  reg           S_valid_ungated = 0;
  reg  [31:0]   ecc_corr_mask = 32'b0;
  reg           ecc_error = 0;
  reg           ecc_error_single = 0;
  reg           ecc_error_ungated = 0;
  reg  [4:0]    ecc_synbit = 5'b0;
  reg  [6:0]    ecc_synword = 7'b0;
  reg  [4:0]    ecc_synbit_next = 5'b0;
  reg  [6:0]    ecc_synword_next = 7'b0;
  reg           efar_save = 0;
  reg   [11:5]  hiaddr = 7'd46; 
  wire  [11:5]  hiaddrp1;
  wire          hiaddr63;
  wire          hiaddr127;
  wire          hclk;
  wire          xorall;
  wire          overall;
  wire          S_valid_next;
  wire          S_valid_ungated_next;
  wire          next_error;
  wire [12:0]   new_S_xor_S;
  wire [6:0]    ecc_synword_next_not_par;
  reg [160:0] tmps1;
  reg [160:0] tmps2;
  reg [160:0] tmps3;


  initial begin
    case (FARSRC)
      "EFAR" : ;
      "FAR" : ;
      default : begin
        $display("Attribute Syntax Error : The Attribute FARSRC on FRAME_ECC_VIRTEX6 instance %m is set to %s.  Legal values for this attribute are EFAR, or FAR.", FARSRC);
        $finish;
      end
    endcase

    sim_file_flag = 0;
    if (FRAME_RBT_IN_FILENAME == "NONE") 
       $display(" Error: The configuration frame data file for FRAME_ECC_VIRTEX6 instance %m was not found. Use X_ICAP_VIRTEX6 to generate frame data file and then use the FRAME_RBT_IN_FILENAME parameter to pass the file name.\n");
    else begin
      rbt_fd = $fopen(FRAME_RBT_IN_FILENAME, "r");
      ecc_ecc_out_fd = $fopen(FRAME_ECC_OUT_ECC_FILENAME, "w");
      ecc_rbt_out_fd = $fopen(FRAME_ECC_OUT_RBT_FILENAME, "w");
      if  (rbt_fd == 0)
       $display(" Error: The configuration frame data file %s for FRAME_ECC_VIRTEX6 instance %m was not found. Use X_ICAP_VIRTEX6 to generate frame data file and then use the FRAME_RBT_IN_FILENAME parameter to pass the file name.\n", FRAME_RBT_IN_FILENAME);
      else
        if ($fscanf(rbt_fd, "%s\t%s\t%s", tmps1, tmps2, tmps3) != -1)
           rd_rbt_en <= #1 1;

      if  (ecc_ecc_out_fd == 0)
       $display(" Error: The ecc frame data out file frame_ecc_out_v6.txt for FRAME_ECC_VIRTEX6 instance %m can not created.\n");
      if  (ecc_rbt_out_fd == 0)
       $display(" Error: The rbt frame data out file frame_rbt_out_v6.txt for FRAME_ECC_VIRTEX6 instance %m can not created.\n");
      if (rbt_fd !=0 && ecc_ecc_out_fd != 0 && ecc_rbt_out_fd != 0 )
         sim_file_flag = 1;
    end
  end
 
  assign CRCERROR = rbcrc_err;
  assign ECCERROR = ecc_error;
  assign ECCERRORSINGLE = ecc_error_single;
  assign SYNDROMEVALID = S_valid;
  assign SYNDROME = S;
  assign FAR = frame_addr[23:0];
  assign  SYNBIT = ecc_synbit;
  assign  SYNWORD = ecc_synword;


  always
        #2000 clk_osc <= ~clk_osc;

  always @(negedge clk_osc )
    if (sim_file_flag == 1 && rd_rbt_en == 1 && rd_rbt_hold1 == 0 ) begin
      if ( $fscanf(rbt_fd, "%d\t%b\t%b", frame_addr_i, data_rbt, rb_crc_rbt) != -1) begin
        rb_data_en <= 1;
        frame_addr <= frame_addr_i;
        rb_data <= data_rbt;
        crc_input[36:0] =  {5'b00011, data_rbt};
        crc_new[31:0] = bcc_next(crc_curr, crc_input);
        crc_curr[31:0] <= crc_new;
        if (n <= 255) begin
          frame_data[n] <= data_rbt[31:0];
          if (n == 255) 
            n <= 174;
          else if (n==191)
            n <= 193;
          else
            n <= n+ 1;
        end
      end
      else begin
        rb_data_en <= 0;
        end_rbt <= 1;
        n <= 173;
        if ( crc_new != rb_crc_rbt)
           rbcrc_err <= 1;
        else
           rbcrc_err <= 0;
        $fclose(rbt_fd);
      end
    end

    always @(negedge clk_osc)
      if (rb_data_en == 1) begin
         if ( rd_rbt_hold1 == 1 && rd_rbt_hold == 1 && rd_rbt_hold2 == 0) begin
           for (bi = 174; bi<= 255; bi=bi+1)
           frame_data_bak[bi] = frame_data[bi];
           if (ecc_error_single == 1) begin
             ecc_wadr[6:0] = SYNDROME[11:5];
             ecc_badr[4:0] = SYNDROME[4:0];
             corr_wd = frame_data[ecc_wadr];
             corr_wd1 = frame_data[ecc_wadr];
             corr_wd[ecc_badr] = ~corr_wd1[ecc_badr];
             frame_data_bak[ecc_wadr] = corr_wd;
           end
           for (nbi = 174; nbi<= 255; nbi=nbi+1) begin
             if (nbi != 192) begin
               tmpwd1 = frame_data[nbi];
               tmpwd2 = frame_data_bak[nbi];
               $fwriteb(ecc_rbt_out_fd,  tmpwd1); 
               $fwriteb(ecc_rbt_out_fd, "\n"); 
               $fwriteb(ecc_ecc_out_fd, tmpwd2); 
               $fwriteb(ecc_ecc_out_fd, "\n"); 
             end
           end
         end
      end
      else if (end_rbt ==1) begin
            $fclose(ecc_ecc_out_fd);
            $fclose(ecc_rbt_out_fd);
      end 
   
     always @(posedge clk_osc) 
       if (rb_data_en == 1) begin
         if (n == 255) 
            rd_rbt_hold <= 1;
         rd_rbt_hold2 <= rd_rbt_hold1;
         rd_rbt_hold1 <= rd_rbt_hold;
         if (rd_rbt_hold2 ==1) begin
            rd_rbt_hold <= 0;
            rd_rbt_hold1 <= 0;
            rd_rbt_hold2 <= 0;
         end
       end
       else if ( end_rbt == 1)  begin
          rd_rbt_hold <= 1;
          rd_rbt_hold1 <=  1;
          rd_rbt_hold2 <=  1;
       end

     always @(negedge clk_osc)
        if (rd_rbt_hold2 == 1 && hamming_rst == 0)
           hamming_rst <= 1;
        else
           hamming_rst <= 0;

    assign  S_valid_next = rb_data_en & hiaddr127 & ~ecc_run;
    assign  S_valid_ungated_next = rb_data_en & hiaddr127;
    assign  next_error = (| next_S);
    assign  hiaddrp1 = hiaddr + 1;
    assign  hiaddr63 = & hiaddr[10:5];    
    assign  hiaddr127 = & hiaddr[11:5]; 
    assign  hclk = ( hiaddr == 7'd87 ) ? 1 : 0;

    always @( posedge clk_osc or posedge hamming_rst)
      if (hamming_rst == 1)
            hiaddr <=  7'd46;
      else if ( rb_data_en == 1 ) begin
            if ( hiaddr127 )    
                hiaddr <=  7'd46;
            else 
                hiaddr <=  { hiaddrp1[11:6], ( hiaddr63 | hiaddrp1[5] ) };
      end
            
    assign xorall  = ( ^ rb_data[31:13] ) ^ ( ( ~ hclk )  & ( ^ rb_data[12:0] ) );
    assign overall = ( ^ rb_data[31:13] ) ^ ( ~(hclk & calc_syndrome) & ( ^ rb_data[12:0] ) );

    assign new_S[12] =  overall;

    assign new_S[4] = rb_data[31] ^ rb_data[30] ^ rb_data[29] ^ rb_data[28] ^
                      rb_data[27] ^ rb_data[26] ^ rb_data[25] ^ rb_data[24] ^
                      rb_data[23] ^ rb_data[22] ^ rb_data[21] ^ rb_data[20] ^
                       rb_data[19] ^ rb_data[18] ^ rb_data[17] ^ rb_data[16] ^
                       ( hclk & ~calc_syndrome & rb_data[4]  );
    assign new_S[3] = rb_data[31] ^ rb_data[30] ^ rb_data[29] ^ rb_data[28] ^
                      rb_data[27] ^ rb_data[26] ^ rb_data[25] ^ rb_data[24] ^
                      rb_data[15] ^ rb_data[14] ^ rb_data[13] ^
                       ( hclk  ? ~calc_syndrome & rb_data[3]  : 
                       ( rb_data[12] ^ rb_data[11] ^ rb_data[10] ^ rb_data[9] ^ rb_data[8]) );
    assign new_S[2] = rb_data[31] ^ rb_data[30] ^ rb_data[29] ^ rb_data[28] ^
                       rb_data[23] ^ rb_data[22] ^ rb_data[21] ^ rb_data[20] ^
                       rb_data[15] ^ rb_data[14] ^ rb_data[13] ^
                       ( hclk  ? ~calc_syndrome & rb_data[2] : 
                       ( rb_data[12] ^ rb_data[7] ^ rb_data[6] ^ rb_data[5] ^ rb_data[4] ) );
    assign new_S[1] = rb_data[31] ^ rb_data[30] ^ rb_data[27] ^ rb_data[26] ^
                        rb_data[23] ^ rb_data[22] ^ rb_data[19] ^ rb_data[18] ^
                        rb_data[15] ^ rb_data[14] ^
                        ( hclk  ? ~calc_syndrome & rb_data[1]  : 
                        ( rb_data[11] ^ rb_data[10] ^ rb_data[7] ^ rb_data[6] ^ rb_data[3] ^ rb_data[2] ));
    assign new_S[0] = rb_data[31] ^ rb_data[29] ^ rb_data[27] ^ rb_data[25] ^
                        rb_data[23] ^ rb_data[21] ^ rb_data[19] ^ rb_data[17] ^
                        rb_data[15] ^ rb_data[13] ^
                        ( hclk  ? ~calc_syndrome & rb_data[0]  : 
                        ( rb_data[11] ^ rb_data[9] ^ rb_data[7] ^ rb_data[5] ^ rb_data[3] ^ rb_data[1] ) );

    assign new_S[11:5] = ( hiaddr & { 7 { xorall } } ) ^
                           ( { 7 { hclk & ~calc_syndrome } } &
                             { rb_data[11], rb_data[10], rb_data[9], rb_data[8],
                              rb_data[7],  rb_data[6], rb_data[5] } );

    assign new_S_xor_S = S ^ new_S;
    assign next_S = (hiaddr127 & calc_syndrome) ? {(^new_S_xor_S), new_S_xor_S[11:0]} :
                    (hiaddr == 7'd46) ? new_S : new_S_xor_S;

    assign ecc_synword_next_not_par = new_S_xor_S[11:5] - 7'd46 - {6'b0, new_S_xor_S[11]};

    always @(ecc_synword_next_not_par, new_S_xor_S) begin
       if (!new_S_xor_S[12]) begin
             ecc_synword_next = 7'd0;
             ecc_synbit_next  = 5'd0;
       end else begin
          case (new_S_xor_S[11:0])
            12'h000 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd12;
            end
            12'h001 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd0;
            end
            12'h002 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd1;
            end
            12'h004 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd2;
            end
            12'h008 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd3;
            end
            12'h010 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd4;
            end
            12'h020 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd5;
            end
            12'h040 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd6;
            end
            12'h080 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd7;
            end
            12'h100 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd8;
            end
            12'h200 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd9;
            end
             12'h400 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd10;
            end
             12'h800 : begin
               ecc_synword_next = 7'd40;
               ecc_synbit_next  = 5'd11;
            end
            default : begin
               ecc_synword_next = ecc_synword_next_not_par;
               ecc_synbit_next  = new_S_xor_S[4:0];
            end
          endcase 
       end
    end

    always @( posedge clk_osc or posedge hamming_rst) begin
      if ( hamming_rst == 1 ) begin
            S_valid         <= 0;
            S_valid_ungated <= 0;
            S               <=  13'd0;
      end  
      else if ( rb_data_en == 1 ) begin
            S_valid_ungated <=  S_valid_ungated_next;
            S_valid         <=  S_valid_next;
            S               <=  next_S;
      end else begin      
            S_valid_ungated <= 0;
            S_valid         <= 0;
      end
  
      if (hamming_rst == 1 ) begin
            ecc_synword    <= 7'd0;
            ecc_synbit     <= 5'd0;
      end
      else if ( S_valid_next & ~efar_save ) begin
            ecc_synword    <=  ecc_synword_next;
            ecc_synbit     <=  ecc_synbit_next;
      end

      if (hamming_rst == 1) begin
          ecc_error <= 0;
          ecc_error_single <= 0;
      end
      else if (S_valid_next == 1) begin
           ecc_error <=  next_error;
           ecc_error_single <= next_S[12];
      end

      if (hamming_rst == 1) 
           ecc_error_ungated <= 0;
      else if (S_valid_ungated_next == 1) 
           ecc_error_ungated <= next_error;
 
      if (hamming_rst == 1)
            efar_save  <= 0;
      else if (ecc_error == 1 | ((S_valid_ungated_next & next_error) == 1))
            efar_save  <= 1;
   
    end


  function [31:0] bcc_next;
    input [31:0] bcc;
    input [36:0] in;
    reg [31:0] x;
    reg [36:0] m;
  begin
     m = in;
     x = in[31:0] ^ bcc;

     bcc_next[31] = m[32]^m[36]^x[31]^x[30]^x[29]^x[28]^x[27]^x[24]^x[20]^x[19]^x[18]^x[15]^x[13]^x[11]^x[10]^x[9]^x[8]^x[6]^x[5]^x[1]^x[0];
     bcc_next[30] = m[35]^x[31]^x[30]^x[29]^x[28]^x[27]^x[26]^x[23]^x[19]^x[18]^x[17]^x[14]^x[12]^x[10]^x[9]^x[8]^x[7]^x[5]^x[4]^x[0];
     bcc_next[29] = m[34]^x[30]^x[29]^x[28]^x[27]^x[26]^x[25]^x[22]^x[18]^x[17]^x[16]^x[13]^x[11]^x[9]^x[8]^x[7]^x[6]^x[4]^x[3];
     bcc_next[28] = m[33]^x[29]^x[28]^x[27]^x[26]^x[25]^x[24]^x[21]^x[17]^x[16]^x[15]^x[12]^x[10]^x[8]^x[7]^x[6]^x[5]^x[3]^x[2];
     bcc_next[27] = m[32]^x[28]^x[27]^x[26]^x[25]^x[24]^x[23]^x[20]^x[16]^x[15]^x[14]^x[11]^x[9]^x[7]^x[6]^x[5]^x[4]^x[2]^x[1];
     bcc_next[26] = x[31]^x[27]^x[26]^x[25]^x[24]^x[23]^x[22]^x[19]^x[15]^x[14]^x[13]^x[10]^x[8]^x[6]^x[5]^x[4]^x[3]^x[1]^x[0];
     bcc_next[25] = m[32]^m[36]^x[31]^x[29]^x[28]^x[27]^x[26]^x[25]^x[23]^x[22]^x[21]^x[20]^x[19]^x[15]^x[14]^x[12]^x[11]^x[10]^x[8]^x[7]^x[6]^x[4]^x[3]^x[2]^x[1];
     bcc_next[24] = m[35]^x[31]^x[30]^x[28]^x[27]^x[26]^x[25]^x[24]^x[22]^x[21]^x[20]^x[19]^x[18]^x[14]^x[13]^x[11]^x[10]^x[9]^x[7]^x[6]^x[5]^x[3]^x[2]^x[1]^x[0];
     bcc_next[23] = m[32]^m[34]^m[36]^x[31]^x[28]^x[26]^x[25]^x[23]^x[21]^x[17]^x[15]^x[12]^x[11]^x[4]^x[2];
     bcc_next[22] = m[32]^m[33]^m[35]^m[36]^x[29]^x[28]^x[25]^x[22]^x[19]^x[18]^x[16]^x[15]^x[14]^x[13]^x[9]^x[8]^x[6]^x[5]^x[3]^x[0];
     bcc_next[21] = m[34]^m[35]^m[36]^x[30]^x[29]^x[21]^x[20]^x[19]^x[17]^x[14]^x[12]^x[11]^x[10]^x[9]^x[7]^x[6]^x[4]^x[2]^x[1]^x[0];
     bcc_next[20] = m[32]^m[33]^m[34]^m[35]^m[36]^x[31]^x[30]^x[27]^x[24]^x[16]^x[15]^x[3];
     bcc_next[19] = m[32]^m[33]^m[34]^m[35]^x[31]^x[30]^x[29]^x[26]^x[23]^x[15]^x[14]^x[2];
     bcc_next[18] = m[33]^m[34]^m[36]^x[27]^x[25]^x[24]^x[22]^x[20]^x[19]^x[18]^x[15]^x[14]^x[11]^x[10]^x[9]^x[8]^x[6]^x[5]^x[0];
     bcc_next[17] = m[33]^m[35]^m[36]^x[31]^x[30]^x[29]^x[28]^x[27]^x[26]^x[23]^x[21]^x[20]^x[17]^x[15]^x[14]^x[11]^x[7]^x[6]^x[4]^x[1]^x[0];
     bcc_next[16] = m[32]^m[34]^m[35]^x[30]^x[29]^x[28]^x[27]^x[26]^x[25]^x[22]^x[20]^x[19]^x[16]^x[14]^x[13]^x[10]^x[6]^x[5]^x[3]^x[0];
     bcc_next[15] = m[33]^m[34]^x[31]^x[29]^x[28]^x[27]^x[26]^x[25]^x[24]^x[21]^x[19]^x[18]^x[15]^x[13]^x[12]^x[9]^x[5]^x[4]^x[2];
     bcc_next[14] = m[32]^m[33]^x[30]^x[28]^x[27]^x[26]^x[25]^x[24]^x[23]^x[20]^x[18]^x[17]^x[14]^x[12]^x[11]^x[8]^x[4]^x[3]^x[1];
     bcc_next[13] = m[36]^x[30]^x[28]^x[26]^x[25]^x[23]^x[22]^x[20]^x[18]^x[17]^x[16]^x[15]^x[9]^x[8]^x[7]^x[6]^x[5]^x[3]^x[2]^x[1];
     bcc_next[12] = m[32]^m[35]^m[36]^x[31]^x[30]^x[28]^x[25]^x[22]^x[21]^x[20]^x[18]^x[17]^x[16]^x[14]^x[13]^x[11]^x[10]^x[9]^x[7]^x[4]^x[2];
     bcc_next[11] = m[32]^m[34]^m[35]^m[36]^x[28]^x[21]^x[18]^x[17]^x[16]^x[12]^x[11]^x[5]^x[3]^x[0];
     bcc_next[10] = m[33]^m[34]^m[35]^x[31]^x[27]^x[20]^x[17]^x[16]^x[15]^x[11]^x[10]^x[4]^x[2];
     bcc_next[9] = m[33]^m[34]^m[36]^x[31]^x[29]^x[28]^x[27]^x[26]^x[24]^x[20]^x[18]^x[16]^x[14]^x[13]^x[11]^x[8]^x[6]^x[5]^x[3]^x[0];
     bcc_next[8] = m[33]^m[35]^m[36]^x[31]^x[29]^x[26]^x[25]^x[24]^x[23]^x[20]^x[18]^x[17]^x[12]^x[11]^x[9]^x[8]^x[7]^x[6]^x[4]^x[2]^x[1]^x[0];
     bcc_next[7] = m[32]^m[34]^m[35]^x[30]^x[28]^x[25]^x[24]^x[23]^x[22]^x[19]^x[17]^x[16]^x[11]^x[10]^x[8]^x[7]^x[6]^x[5]^x[3]^x[1]^x[0];
     bcc_next[6] = m[32]^m[33]^m[34]^m[36]^x[30]^x[28]^x[23]^x[22]^x[21]^x[20]^x[19]^x[16]^x[13]^x[11]^x[8]^x[7]^x[4]^x[2]^x[1];
     bcc_next[5] = m[33]^m[35]^m[36]^x[30]^x[28]^x[24]^x[22]^x[21]^x[13]^x[12]^x[11]^x[9]^x[8]^x[7]^x[5]^x[3];
     bcc_next[4] = m[34]^m[35]^m[36]^x[31]^x[30]^x[28]^x[24]^x[23]^x[21]^x[19]^x[18]^x[15]^x[13]^x[12]^x[9]^x[7]^x[5]^x[4]^x[2]^x[1]^x[0];
     bcc_next[3] = m[32]^m[33]^m[34]^m[35]^m[36]^x[31]^x[28]^x[24]^x[23]^x[22]^x[19]^x[17]^x[15]^x[14]^x[13]^x[12]^x[10]^x[9]^x[5]^x[4]^x[3];
     bcc_next[2] = m[32]^m[33]^m[34]^m[35]^x[31]^x[30]^x[27]^x[23]^x[22]^x[21]^x[18]^x[16]^x[14]^x[13]^x[12]^x[11]^x[9]^x[8]^x[4]^x[3]^x[2];
     bcc_next[1] = m[32]^m[33]^m[34]^x[31]^x[30]^x[29]^x[26]^x[22]^x[21]^x[20]^x[17]^x[15]^x[13]^x[12]^x[11]^x[10]^x[8]^x[7]^x[3]^x[2]^x[1];
     bcc_next[0] = m[32]^m[33]^x[31]^x[30]^x[29]^x[28]^x[25]^x[21]^x[20]^x[19]^x[16]^x[14]^x[12]^x[11]^x[10]^x[9]^x[7]^x[6]^x[2]^x[1]^x[0];
  end
  endfunction

endmodule 
