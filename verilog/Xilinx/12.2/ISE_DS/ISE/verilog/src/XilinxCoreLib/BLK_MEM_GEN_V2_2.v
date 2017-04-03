/******************************************************************************
 *
 * Block Memory Generator Core - Block Memory Behavioral Model
 *
 * Copyright(C) 2005 by Xilinx, Inc. All rights reserved.
 * This text/file contains proprietary, confidential
 * information of Xilinx, Inc., is distributed under
 * license from Xilinx, Inc., and may be used, copied
 * and/or disclosed only pursuant to the terms of a valid
 * license agreement with Xilinx, Inc. Xilinx hereby
 * grants you a license to use this text/file solely for
 * design, simulation, implementation and creation of
 * design files limited to Xilinx devices or technologies.
 * Use with non-Xilinx devices or technologies is expressly
 * prohibited and immediately terminates your license unless
 * covered by a separate agreement.
 *
 * Xilinx is providing this design, code, or information
 * "as-is" solely for use in developing programs and
 * solutions for Xilinx devices, with no obligation on the
 * part of Xilinx to provide support. By providing this design,
 * code, or information as one possible implementation of
 * this feature, application or standard, Xilinx is making no
 * representation that this implementation is free from any
 * claims of infringement. You are responsible for obtaining
 * any rights you may require for your implementation.
 * Xilinx expressly disclaims any warranty whatsoever with
 * respect to the adequacy of the implementation, including
 * but not limited to any warranties or representations that this
 * implementation is free from claims of infringement, implied
 * warranties of merchantability or fitness for a particular
 * purpose.
 *
 * Xilinx products are not intended for use in life support
 * appliances, devices, or systems. Use in such applications is
 * expressly prohibited.
 *
 * Any modifications that are made to the Source Code are
 * done at the user's sole risk and will be unsupported.
 * The Xilinx Support Hotline does not have access to source
 * code and therefore cannot answer specific questions related
 * to source HDL. The Xilinx Hotline support of original source
 * code IP shall only address issues and questions related
 * to the standard Netlist version of the core (and thus
 * indirectly, the original core source).
 *
 * This copyright and support notice must be retained as part
 * of this text at all times. (c) Copyright 1995-2005 Xilinx, Inc.
 * All rights reserved.
 *
 *****************************************************************************
 *
 * Filename: BLK_MEM_GEN_V2_2.v
 *
 * Description:
 *   This file is the Verilog behvarial model for the
 *       Block Memory Generator Core.
 *
 *****************************************************************************
 * Author: Xilinx
 *
 * History: January 11, 2006 Initial revision
 *****************************************************************************/
`timescale 1ps/1ps

module BLK_MEM_GEN_V2_2_output_stage
  #(parameter C_DATA_WIDTH       = 32,
    parameter C_HAS_SSR          = 1,
    parameter C_SINIT_VAL        = "0",
    parameter C_HAS_REGCE        = 1,
    parameter C_HAS_EN           = 1,
    parameter C_FAMILY           = "virtex5",
    parameter num_stages         = 1,
    parameter flop_delay         = 100)
  (input                         CLK,
   input                         SSR,
   input                         REGCE,
   input                         EN,
   input      [C_DATA_WIDTH-1:0] DIN,
   output reg [C_DATA_WIDTH-1:0] DOUT);

  localparam reg_stages  = (num_stages == 0) ? 0 : num_stages-1;
  reg [C_DATA_WIDTH*reg_stages-1:0] out_regs;
  reg [C_DATA_WIDTH*8-1:0]          sinit_str = C_SINIT_VAL;
  reg [C_DATA_WIDTH-1:0]            sinit_val;

  // Wire off optional inputs based on parameters
  //---------------------------------------------
  wire                              en_i;
  wire                              regce_i;
  wire                              ssr_i;
  assign   en_i    = (C_HAS_EN==0 || EN);
  assign   regce_i = ((C_HAS_REGCE==1) && REGCE) ||
                     ((C_HAS_REGCE==0) && (C_HAS_EN==0 || EN));
  assign   ssr_i   = (C_HAS_SSR==1) && SSR;

  initial begin
    // Power on: load up the output registers and latches
    if (!($sscanf(sinit_str, "%h", sinit_val))) begin
      sinit_val = 0;
    end
    DOUT = sinit_val;
    // This will be one wider than need, but 0 is an error
    out_regs = {(reg_stages+1){sinit_val}};
  end

  generate if (num_stages == 0) begin : zero_stages
    always @* begin
      DOUT = DIN;
    end
  end
  endgenerate

 generate if (num_stages == 1) begin : one_stages
    always @(posedge CLK) begin
        if (regce_i && ssr_i) begin
           DOUT <= #flop_delay sinit_val;
        end else if (regce_i) begin
           DOUT <= #flop_delay DIN;
        end
    end
    end
  endgenerate

 generate if (num_stages > 1) begin : multi_stage
    always @(posedge CLK) begin
        if (regce_i && ssr_i) begin
            DOUT           <= #flop_delay sinit_val;
        end else if (regce_i) begin
           DOUT         <= #flop_delay
                        out_regs[C_DATA_WIDTH*(num_stages-2)+:C_DATA_WIDTH];
        end

      if (en_i) begin
        out_regs <= #flop_delay
                    (out_regs << C_DATA_WIDTH) | DIN;
      end
    end
  end
  endgenerate
endmodule

module BLK_MEM_GEN_V2_2
  #(parameter C_ADDRA_WIDTH             = 5,
    parameter C_ADDRB_WIDTH             = 5,
    parameter C_ALGORITHM               = 2,
    parameter C_BYTE_SIZE               = 8,
    parameter C_COMMON_CLK              = 1,
    parameter C_DEFAULT_DATA            = "0",
    parameter C_DISABLE_WARN_BHV_COLL   = 0,
    parameter C_DISABLE_WARN_BHV_RANGE  = 0,
    parameter C_FAMILY                  = "virtex4",
    parameter C_HAS_ENA                 = 1,
    parameter C_HAS_ENB                 = 1,
    parameter C_HAS_MEM_OUTPUT_REGS     = 0,
    parameter C_HAS_MUX_OUTPUT_REGS     = 0,
    parameter C_HAS_REGCEA              = 0,
    parameter C_HAS_REGCEB              = 0,
    parameter C_HAS_SSRA                = 0,
    parameter C_HAS_SSRB                = 0,
    parameter C_INIT_FILE_NAME          = "",
    parameter C_LOAD_INIT_FILE          = 0,
    parameter C_MEM_TYPE                = 2,
    parameter C_PRIM_TYPE               = 3,
    parameter C_READ_DEPTH_A            = 64,
    parameter C_READ_DEPTH_B            = 64,
    parameter C_READ_WIDTH_A            = 32,
    parameter C_READ_WIDTH_B            = 32,
    parameter C_SIM_COLLISION_CHECK     = "NONE",
    parameter C_SINITA_VAL              = "0",
    parameter C_SINITB_VAL              = "0",
    parameter C_USE_BYTE_WEA            = 0,
    parameter C_USE_BYTE_WEB            = 0,
    parameter C_USE_DEFAULT_DATA        = 0,
    parameter C_USE_ECC                 = 0,
    parameter C_WEA_WIDTH               = 1,
    parameter C_WEB_WIDTH               = 1,
    parameter C_WRITE_DEPTH_A           = 64,
    parameter C_WRITE_DEPTH_B           = 64,
    parameter C_WRITE_MODE_A            = "WRITE_FIRST",
    parameter C_WRITE_MODE_B            = "WRITE_FIRST",
    parameter C_WRITE_WIDTH_A           = 32,
    parameter C_WRITE_WIDTH_B           = 32,
    parameter C_CORENAME                = "blk_mem_gen_v2_2")
  (input                       CLKA,
   input [C_WRITE_WIDTH_A-1:0] DINA,
   input [C_ADDRA_WIDTH-1:0]   ADDRA,
   input                       ENA,
   input                       REGCEA,
   input [C_WEA_WIDTH-1:0]     WEA,
   input                       SSRA,
   output [C_READ_WIDTH_A-1:0] DOUTA,
   input                       CLKB,
   input [C_WRITE_WIDTH_B-1:0] DINB,
   input [C_ADDRB_WIDTH-1:0]   ADDRB,
   input                       ENB,
   input                       REGCEB,
   input [C_WEB_WIDTH-1:0]     WEB,
   input                       SSRB,
   output [C_READ_WIDTH_B-1:0] DOUTB,
   output                      DBITERR,
   output                      SBITERR
  );

  // constants for the core behavior
  //================================
  // file handles for logging
  //------------------------------------------------------
  localparam addrfile           = 32'h8000_0001; // stdout for addr out of range
  localparam collfile           = 32'h8000_0001; // stdout for coll detection
  localparam errfile            = 32'h8000_0001; // stdout for file I/O errors

  // other constants
  //------------------------------------------------------
  localparam coll_delay         = 2000;  // 2 ns

  // locally derived parameters to determine memory shape
  //-----------------------------------------------------
  localparam min_width_a = (C_WRITE_WIDTH_A < C_READ_WIDTH_A) ?
             C_WRITE_WIDTH_A : C_READ_WIDTH_A;
  localparam min_width_b = (C_WRITE_WIDTH_B < C_READ_WIDTH_B) ?
             C_WRITE_WIDTH_B : C_READ_WIDTH_B;
  localparam min_width = (min_width_a < min_width_b) ?
             min_width_a : min_width_b;

  localparam max_width_a = (C_WRITE_WIDTH_A > C_READ_WIDTH_A) ?
             C_WRITE_WIDTH_A : C_READ_WIDTH_A;
  localparam max_width_b = (C_WRITE_WIDTH_B > C_READ_WIDTH_B) ?
             C_WRITE_WIDTH_B : C_READ_WIDTH_B;
  localparam max_width = (max_width_a > max_width_b) ?
             max_width_a : max_width_b;

  localparam max_depth_a = (C_WRITE_DEPTH_A > C_READ_DEPTH_A) ?
             C_WRITE_DEPTH_A : C_READ_DEPTH_A;
  localparam max_depth_b = (C_WRITE_DEPTH_B > C_READ_DEPTH_B) ?
             C_WRITE_DEPTH_B : C_READ_DEPTH_B;
  localparam max_depth = (max_depth_a > max_depth_b) ?
             max_depth_a : max_depth_b;


  // locally derived parameters to assist memory access
  //----------------------------------------------------
  localparam write_width_ratio_a = C_WRITE_WIDTH_A/min_width;
  localparam read_width_ratio_a  = C_READ_WIDTH_A/min_width;
  localparam write_width_ratio_b = C_WRITE_WIDTH_B/min_width;
  localparam read_width_ratio_b  = C_READ_WIDTH_B/min_width;

  // To modify the LSBs of the 'wider' data to the actual
  //    address value
  //----------------------------------------------------
  localparam write_addr_a_div  = C_WRITE_WIDTH_A/min_width_a;
  localparam read_addr_a_div   = C_READ_WIDTH_A/min_width_a;
  localparam write_addr_b_div  = C_WRITE_WIDTH_B/min_width_b;
  localparam read_addr_b_div   = C_READ_WIDTH_B/min_width_b;

  // If byte writes aren't being used, make sure byte_size is not
  // wider than the memory elements to avoid compilation warnings
  localparam byte_size   = (C_BYTE_SIZE < min_width) ? C_BYTE_SIZE : min_width;

  // the memory
  reg [min_width-1:0]      memory [0:max_depth-1];
  // memory output 'latches'
  reg [C_READ_WIDTH_A-1:0] memory_out_a;
  reg [C_READ_WIDTH_B-1:0] memory_out_b;
  // reset values
  reg [C_READ_WIDTH_A-1:0] sinita_val;
  reg [C_READ_WIDTH_B-1:0] sinitb_val;

  // collision detect
  reg                      is_collision;
  reg                      is_collision_a, is_collision_delay_a;
  reg                      is_collision_b, is_collision_delay_b;

  // temporary variables for initialization
  //---------------------------------------
  integer                  status;
  reg [639:0]              err_str;
  integer                  initfile;
  // data input buffer
  reg [C_WRITE_WIDTH_A-1:0]    mif_data;
  // string values in hex
  reg [C_READ_WIDTH_A*8-1:0]   sinita_str       = C_SINITA_VAL;
  reg [C_READ_WIDTH_B*8-1:0]   sinitb_str       = C_SINITB_VAL;
  reg [C_WRITE_WIDTH_A*8-1:0]  default_data_str = C_DEFAULT_DATA;
  // initialization filename
  reg [1023*8-1:0]             init_file_str    = C_INIT_FILE_NAME;

  // internal configuration parameters
  //---------------------------------------------
  localparam flop_delay  = 100;  // 100 ps
  localparam single_port = (C_MEM_TYPE==0 || C_MEM_TYPE==3);
  localparam is_rom      = (C_MEM_TYPE==3 || C_MEM_TYPE==4);
  localparam has_a_write = (!is_rom);
  localparam has_b_write = (C_MEM_TYPE==2);
  localparam has_a_read  = (C_MEM_TYPE!=1);
  localparam has_b_read  = (!single_port);
  localparam has_b_port  = (has_b_read || has_b_write);
  localparam num_output_stages = C_HAS_MEM_OUTPUT_REGS +
                                 C_HAS_MUX_OUTPUT_REGS;

  wire                   ena_i;
  wire                   enb_i;
  wire                   reseta_i;
  wire                   resetb_i;
  wire [C_WEA_WIDTH-1:0] wea_i;
  wire [C_WEB_WIDTH-1:0] web_i;
  wire                   rea_i;
  wire                   reb_i;
  assign ena_i  = (C_HAS_ENA==0) || ENA;
  assign enb_i  = ((C_HAS_ENB==0) || ENB) && has_b_port;
  assign reseta_i = (C_HAS_SSRA==1) && SSRA && ena_i &&
                    (num_output_stages==0);
  assign resetb_i = (C_HAS_SSRB==1) && SSRB && enb_i &&
                    (num_output_stages==0);
  assign wea_i = (has_a_write && ena_i) ? WEA : 'b0;
  assign web_i = (has_b_write && enb_i) ? WEB : 'b0;
  assign rea_i = (has_a_read)  ? ena_i : 'b0;
  assign reb_i = (has_b_read)  ? enb_i : 'b0;

  // tasks to access the memory
  //---------------------------
  task write_a
    (input  reg [C_ADDRA_WIDTH-1:0]   addr,
     input  reg [C_WEA_WIDTH-1:0]     byte_en,
     input  reg [C_WRITE_WIDTH_A-1:0] data);
    reg [C_WRITE_WIDTH_A-1:0] current_contents;
    reg [C_ADDRA_WIDTH-1:0] address;
    integer i;
    begin
      // Shift the address by the ratio
      address = (addr/write_addr_a_div);
      if (address >= C_WRITE_DEPTH_A) begin
        if (!C_DISABLE_WARN_BHV_RANGE) begin
          $fdisplay(addrfile,
                    "%0s WARNING: Address %0h is outside range for A Write",
                    C_CORENAME, addr);
        end

      // valid address
      end else begin

        // Combine w/ byte writes
        if (C_USE_BYTE_WEA) begin

          // Get the current memory contents
          if (write_width_ratio_a == 1) begin
            // Workaround for IUS 5.5 part-select issue
            current_contents = memory[address];
          end else begin
            for (i = 0; i < write_width_ratio_a; i = i + 1) begin
              current_contents[min_width*i+:min_width]
                = memory[address*write_width_ratio_a + i];
            end
          end

          // Apply incoming bytes
          if (C_WEA_WIDTH == 1) begin
            // Workaround for IUS 5.5 part-select issue
            if (byte_en[0]) begin
              current_contents = data;
            end
          end else begin
            for (i = 0; i < C_WEA_WIDTH; i = i + 1) begin
              if (byte_en[i]) begin
                current_contents[byte_size*i+:byte_size]
                  = data[byte_size*i+:byte_size];
              end
            end
          end

        // No byte-writes, overwrite the whole word
        end else begin
          current_contents = data;
        end

        // Write data to memory
        if (write_width_ratio_a == 1) begin
          // Workaround for IUS 5.5 part-select issue
          memory[address*write_width_ratio_a] = current_contents;
        end else begin
          for (i = 0; i < write_width_ratio_a; i = i + 1) begin
            memory[address*write_width_ratio_a + i]
              = current_contents[min_width*i+:min_width];
          end
        end

      end
    end
  endtask

  task write_b
    (input  reg [C_ADDRB_WIDTH-1:0]   addr,
     input  reg [C_WEB_WIDTH-1:0]     byte_en,
     input  reg [C_WRITE_WIDTH_B-1:0] data);
    reg [C_WRITE_WIDTH_B-1:0] current_contents;
    reg [C_ADDRB_WIDTH-1:0]   address;
    integer i;
    begin
      // Shift the address by the ratio
      address = (addr/write_addr_b_div);
      if (address >= C_WRITE_DEPTH_B) begin
        if (!C_DISABLE_WARN_BHV_RANGE) begin
          $fdisplay(addrfile,
                    "%0s WARNING: Address %0h is outside range for B Write",
                    C_CORENAME, addr);
        end

      // valid address
      end else begin

        // Combine w/ byte writes
        if (C_USE_BYTE_WEB) begin

          // Get the current memory contents
          if (write_width_ratio_b == 1) begin
            // Workaround for IUS 5.5 part-select issue
            current_contents = memory[address];
          end else begin
            for (i = 0; i < write_width_ratio_b; i = i + 1) begin
              current_contents[min_width*i+:min_width]
                = memory[address*write_width_ratio_b + i];
            end
          end

          // Apply incoming bytes
          if (C_WEB_WIDTH == 1) begin
            // Workaround for IUS 5.5 part-select issue
            if (byte_en[0]) begin
              current_contents = data;
            end
          end else begin
            for (i = 0; i < C_WEB_WIDTH; i = i + 1) begin
              if (byte_en[i]) begin
                current_contents[byte_size*i+:byte_size]
                  = data[byte_size*i+:byte_size];
              end
            end
          end

        // No byte-writes, overwrite the whole word
        end else begin
          current_contents = data;
        end

        // Write data to memory
        if (write_width_ratio_b == 1) begin
          // Workaround for IUS 5.5 part-select issue
          memory[address*write_width_ratio_b] = current_contents;
        end else begin
          for (i = 0; i < write_width_ratio_b; i = i + 1) begin
            memory[address*write_width_ratio_b + i]
              = current_contents[min_width*i+:min_width];
          end
        end
      end
    end
  endtask

  task read_a
    (input reg [C_ADDRA_WIDTH-1:0] addr,
     input reg reset);
    reg [C_ADDRA_WIDTH-1:0] address;
    integer i;
    begin

      if (reset) begin
        memory_out_a <= #flop_delay sinita_val;
      end else begin
        // Shift the address by the ratio
        address = (addr/read_addr_a_div);
        if (address >= C_READ_DEPTH_A) begin
          if (!C_DISABLE_WARN_BHV_RANGE) begin
            $fdisplay(addrfile,
                      "%0s WARNING: Address %0h is outside range for A Read",
                      C_CORENAME, addr);
          end

          // valid address
        end else begin

          if (read_width_ratio_a==1) begin
            memory_out_a <= #flop_delay memory[address*read_width_ratio_a];
          end else begin
            // Increment through the 'partial' words in the memory
            for (i = 0; i < read_width_ratio_a; i = i + 1) begin
              memory_out_a[min_width*i+:min_width]
                <= #flop_delay memory[address*read_width_ratio_a + i];
            end
          end

        end
      end
    end
  endtask

  task read_b
    (input reg [C_ADDRB_WIDTH-1:0] addr,
     input reg reset);
    reg [C_ADDRB_WIDTH-1:0] address;
    integer i;
    begin

      if (reset) begin
        memory_out_b <= #flop_delay sinitb_val;
      end else begin
        // Shift the address
        address = (addr/read_addr_b_div);
        if (address >= C_READ_DEPTH_B) begin
          if (!C_DISABLE_WARN_BHV_RANGE) begin
            $fdisplay(addrfile,
                      "%0s WARNING: Address %0h is outside range for B Read",
                      C_CORENAME, addr);
          end

          // valid address
        end else begin

          if (read_width_ratio_b==1) begin
            memory_out_b <= #flop_delay memory[address*read_width_ratio_b];
          end else begin
            // Increment through the 'partial' words in the memory
            for (i = 0; i < read_width_ratio_b; i = i + 1) begin
              memory_out_b[min_width*i+:min_width]
                <= #flop_delay memory[address*read_width_ratio_b + i];
            end
          end

        end
      end
    end
  endtask

  task init_memory;
    integer i, addr_step;
    integer status;
    reg [C_WRITE_WIDTH_A-1:0] default_data;
    begin
      default_data = 0;

      // Convert the default to hex
      if (C_USE_DEFAULT_DATA) begin
        if (default_data_str == "") begin
          $fdisplay(errfile, "%0s ERROR: C_DEFAULT_DATA is empty!", C_CORENAME);
          $finish;
        end else begin
          status = $sscanf(default_data_str, "%h", default_data);
          if (status == 0) begin
            $fdisplay(errfile, {"%0s ERROR: Unsuccessful hexadecimal read",
                                "from C_DEFAULT_DATA: %0s"},
                      C_CORENAME, C_DEFAULT_DATA);
            $finish;
          end
        end
      end

      // Step by write_addr_a_div through the memory via the
      // Port A write interface to hit every location once
      addr_step = write_addr_a_div;

      // 'write' to every location with default (or 0)
      for (i = 0; i < C_WRITE_DEPTH_A*addr_step; i = i + addr_step) begin
        write_a(i, {C_WEA_WIDTH{1'b1}}, default_data);
      end

      // Get specialized data from the MIF file
      if (C_LOAD_INIT_FILE) begin
        if (init_file_str == "") begin
          $fdisplay(errfile, "%0s ERROR: C_INIT_FILE_NAME is empty!",
                    C_CORENAME);
          $finish;
        end else begin
          initfile = $fopen(init_file_str, "r");
          if (initfile == 0) begin
            $fdisplay(errfile, {"%0s, ERROR: Problem opening",
                                "C_INIT_FILE_NAME: %0s!"},
                      C_CORENAME, init_file_str);
            $finish;
          end else begin
            // loop through the mif file, loading in the data
            for (i = 0; i < C_WRITE_DEPTH_A*addr_step; i = i + addr_step) begin
              status = $fscanf(initfile, "%b", mif_data);
              if (status > 0) begin
                write_a(i, {C_WEA_WIDTH{1'b1}}, mif_data);
              end
            end
            $fclose(initfile);
          end
        end
      end
    end
  endtask

   function integer log2roundup (input integer data_value);
      integer width;
      integer cnt;
      begin
         width = 0;

         if (data_value > 1) begin
            for(cnt=1 ; cnt < data_value ; cnt = cnt * 2) begin
               width = width + 1;
            end //loop
         end //if

         log2roundup = width;

      end //log2roundup
   endfunction



  function integer collision_check (input reg [C_ADDRA_WIDTH-1:0] addr_a,
                                    input integer iswrite_a,
                                    input reg [C_ADDRB_WIDTH-1:0] addr_b,
                                    input integer iswrite_b);
    reg [C_ADDRA_WIDTH-1:0] base_addr_a;
    reg [C_ADDRB_WIDTH-1:0] base_addr_b;
    integer ratio_a, ratio_b;
    integer lo_addr_wider,  hi_addr_wider;
    integer lo_addr_narrow, hi_addr_narrow;
    reg c_aw_bw, c_aw_br, c_ar_bw;
    integer write_addr_a_width, read_addr_a_width;
    integer write_addr_b_width, read_addr_b_width;

    begin

    c_aw_bw = 0;
    c_aw_br = 0;
    c_ar_bw = 0;

    // Determine the effective address widths for each of the 4 ports
    write_addr_a_width = C_ADDRA_WIDTH-log2roundup(write_addr_a_div);
    read_addr_a_width  = C_ADDRA_WIDTH-log2roundup(read_addr_a_div);
    write_addr_b_width = C_ADDRB_WIDTH-log2roundup(write_addr_b_div);
    read_addr_b_width  = C_ADDRB_WIDTH-log2roundup(read_addr_b_div);


    //Look for a write-write collision. In order for a write-write
    //collision to exist, both ports must have a write transaction.
    if (iswrite_a && iswrite_b) begin
      if (write_addr_a_width > write_addr_b_width) begin
        //write_addr_b_width is smaller, so scale both addresses to that
        // width for comparing write_addr_a and write_addr_b
        //addr_a starts as C_ADDRA_WIDTH,
        // scale it down to write_addr_b_width
        //addr_b starts as C_ADDRB_WIDTH,
        // scale it down to write_addr_b_width
        //Once both are scaled to write_addr_b_width, compare.
        if (((addr_a)/2**(C_ADDRA_WIDTH-write_addr_b_width)) == ((addr_b)/2**(C_ADDRB_WIDTH-write_addr_b_width))) begin
          c_aw_bw = 1;
        end else begin
          c_aw_bw = 0;
        end
      end else begin
        //write_addr_a_width is smaller, so scale both addresses to that
        // width for comparing write_addr_a and write_addr_b
        //addr_a starts as C_ADDRA_WIDTH,
        // scale it down to write_addr_a_width
        //addr_b starts as C_ADDRB_WIDTH,
        // scale it down to write_addr_a_width
        //Once both are scaled to write_addr_a_width, compare.
        if (((addr_b)/2**(C_ADDRB_WIDTH-write_addr_a_width)) == ((addr_a)/2**(C_ADDRA_WIDTH-write_addr_a_width))) begin
          c_aw_bw = 1;
        end else begin
          c_aw_bw = 0;
        end
      end //width
    end //iswrite_a and iswrite_b

    //If the B port is reading (which means it is enabled - so could be
    // a TX_WRITE or TX_READ), then check for a write-read collision).
    //This could happen whether or not a write-write collision exists due
    //  to asymmetric write/read ports.
    if (iswrite_a) begin
      if (write_addr_a_width > read_addr_b_width) begin
        //read_addr_b_width is smaller, so scale both addresses to that
        //  width for comparing write_addr_a and read_addr_b
        //addr_a starts as C_ADDRA_WIDTH,
        //  scale it down to read_addr_b_width
        //addr_b starts as C_ADDRB_WIDTH,
        //  scale it down to read_addr_b_width
        //Once both are scaled to read_addr_b_width, compare.
        if (((addr_a)/2**(C_ADDRA_WIDTH-read_addr_b_width)) == ((addr_b)/2**(C_ADDRB_WIDTH-read_addr_b_width))) begin
          c_aw_br = 1;
        end else begin
          c_aw_br = 0;
        end
    end else begin
        //write_addr_a_width is smaller, so scale both addresses to that
        //  width for comparing write_addr_a and read_addr_b
        //addr_a starts as C_ADDRA_WIDTH,
        //  scale it down to write_addr_a_width
        //addr_b starts as C_ADDRB_WIDTH,
        //  scale it down to write_addr_a_width
        //Once both are scaled to write_addr_a_width, compare.
        if (((addr_b)/2**(C_ADDRB_WIDTH-write_addr_a_width)) == ((addr_a)/2**(C_ADDRA_WIDTH-write_addr_a_width))) begin
          c_aw_br = 1;
        end else begin
          c_aw_br = 0;
        end
      end //width
    end //iswrite_a

    //If the A port is reading (which means it is enabled - so could be
    //  a TX_WRITE or TX_READ), then check for a write-read collision).
    //This could happen whether or not a write-write collision exists due
    //  to asymmetric write/read ports.
    if (iswrite_b) begin
      if (read_addr_a_width > write_addr_b_width) begin
        //write_addr_b_width is smaller, so scale both addresses to that
        //  width for comparing read_addr_a and write_addr_b
        //addr_a starts as C_ADDRA_WIDTH,
        //  scale it down to write_addr_b_width
        //addr_b starts as C_ADDRB_WIDTH,
        //  scale it down to write_addr_b_width
        //Once both are scaled to write_addr_b_width, compare.
        if (((addr_a)/2**(C_ADDRA_WIDTH-write_addr_b_width)) == ((addr_b)/2**(C_ADDRB_WIDTH-write_addr_b_width))) begin
          c_ar_bw = 1;
        end else begin
          c_ar_bw = 0;
        end
      end else begin
        //read_addr_a_width is smaller, so scale both addresses to that
        //  width for comparing read_addr_a and write_addr_b
        //addr_a starts as C_ADDRA_WIDTH,
        //  scale it down to read_addr_a_width
        //addr_b starts as C_ADDRB_WIDTH,
        //  scale it down to read_addr_a_width
        //Once both are scaled to read_addr_a_width, compare.
        if (((addr_b)/2**(C_ADDRB_WIDTH-read_addr_a_width)) == ((addr_a)/2**(C_ADDRA_WIDTH-read_addr_a_width))) begin
          c_ar_bw = 1;
        end else begin
          c_ar_bw = 0;
        end
      end //width
    end //iswrite_b


      // Convert the input addresses in base and offsets for our
      //   memory array. Ignore LSBs for asymmetric ports
      if (iswrite_a) begin
        base_addr_a = (addr_a/write_addr_a_div) * write_addr_a_div;
        ratio_a     = write_width_ratio_a;
      end else begin
        base_addr_a = (addr_a/read_addr_a_div) *  read_addr_a_div;
        ratio_a     = read_width_ratio_a;
      end
      if (iswrite_b) begin
        base_addr_b = (addr_b/write_addr_b_div) * write_addr_b_div;
        ratio_b     = write_width_ratio_b;
      end else begin
        base_addr_b = (addr_b/read_addr_b_div) *  read_addr_b_div;
        ratio_b     = read_width_ratio_b;
      end

      // Determine the wider port, and normalized ranges
      if (ratio_a >= ratio_b) begin
        lo_addr_wider  = base_addr_a * ratio_a;
        hi_addr_wider  = lo_addr_wider  + ratio_a;
        lo_addr_narrow = base_addr_b * ratio_b;
        hi_addr_narrow = lo_addr_narrow + ratio_b;
      end else begin
        lo_addr_wider  = base_addr_b * ratio_b;
        hi_addr_wider  = lo_addr_wider  + ratio_b;
        lo_addr_narrow = base_addr_a * ratio_a;
        hi_addr_narrow = lo_addr_narrow + ratio_a;
      end

      // compare the two ranges of address (narrow inside wider)
      //if ((lo_addr_narrow >= lo_addr_wider) &&
      //    (hi_addr_narrow <= hi_addr_wider)) begin
      //  collision_check = 1;
      //end else begin
      //  collision_check = 0;
      //end

      collision_check = c_aw_bw | c_aw_br | c_ar_bw;

    end
  endfunction

  // power on values
  //-----------------------------
  initial begin
    // Load up the memory
    init_memory;
    // Load up the output registers and latches
    if ($sscanf(sinita_str, "%h", sinita_val)) begin
      memory_out_a = sinita_val;
    end else begin
      memory_out_a = 0;
    end
    if ($sscanf(sinitb_str, "%h", sinitb_val)) begin
      memory_out_b = sinitb_val;
    end else begin
      memory_out_b = 0;
    end

    $display("Block Memory Generator CORE Generator module %m is using a behavioral model for simulation which will not precisely model memory collision behavior.");

  end

  //-------------------------------------------------------------------------
  // These are the main blocks which schedule read and write operations
  //-------------------------------------------------------------------------

  generate if (C_COMMON_CLK) begin : common_clk_scheduling
      // Synchronous clocks: schedule port operations with respect to
      // both write operating modes
      always @(posedge CLKA) begin
        case ({C_WRITE_MODE_A, C_WRITE_MODE_B})
          {"WRITE_FIRST","WRITE_FIRST"}: begin
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (web_i) write_b(ADDRB, web_i, DINB);
            if (rea_i) read_a(ADDRA, reseta_i);
            if (reb_i) read_b(ADDRB, resetb_i);
          end
          {"READ_FIRST", "WRITE_FIRST"}: begin
            if (web_i) write_b(ADDRB, web_i, DINB);
            if (reb_i) read_b(ADDRB, resetb_i);
            if (rea_i) read_a(ADDRA, reseta_i);
            if (wea_i) write_a(ADDRA, wea_i, DINA);
          end
          {"WRITE_FIRST","READ_FIRST"}: begin
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (rea_i) read_a(ADDRA, reseta_i);
            if (reb_i) read_b(ADDRB, resetb_i);
            if (web_i) write_b(ADDRB, web_i, DINB);
          end
          {"READ_FIRST", "READ_FIRST"}: begin
            if (rea_i) read_a(ADDRA, reseta_i);
            if (reb_i) read_b(ADDRB, resetb_i);
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (web_i) write_b(ADDRB, web_i, DINB);
          end
          {"WRITE_FIRST","NO_CHANGE"}: begin
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (rea_i) read_a(ADDRA, reseta_i);
            if ((reb_i && !web_i) || resetb_i) read_b(ADDRB, resetb_i);
            if (web_i) write_b(ADDRB, web_i, DINB);
          end
          {"READ_FIRST", "NO_CHANGE"}: begin
            if (rea_i) read_a(ADDRA, reseta_i);
            if ((reb_i && !web_i) || resetb_i) read_b(ADDRB, resetb_i);
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (web_i) write_b(ADDRB, web_i, DINB);
          end
          {"NO_CHANGE",  "WRITE_FIRST"}: begin
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (web_i) write_b(ADDRB, web_i, DINB);
            if ((rea_i && !wea_i) || reseta_i) read_a(ADDRA, reseta_i);
            if (reb_i) read_b(ADDRB, resetb_i);
          end
          {"NO_CHANGE",  "READ_FIRST"}: begin
            if (reb_i) read_b(ADDRB, resetb_i);
            if ((rea_i && !wea_i) || reseta_i) read_a(ADDRA, reseta_i);
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (web_i) write_b(ADDRB, web_i, DINB);
          end
          {"NO_CHANGE",  "NO_CHANGE"}: begin
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (web_i) write_b(ADDRB, web_i, DINB);
            if ((rea_i && !wea_i) || reseta_i) read_a(ADDRA, reseta_i);
            if ((reb_i && !web_i) || resetb_i) read_b(ADDRB, resetb_i);
          end
          default: begin
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (web_i) write_b(ADDRB, web_i, DINB);
            if (rea_i) read_a(ADDRA, reseta_i);
            if (reb_i) read_b(ADDRB, resetb_i);
          end
        endcase
      end

  end else begin : asynch_clk_scheduling
      // Asynchronous clocks: port operation is independent
      always @(posedge CLKA) begin
        case (C_WRITE_MODE_A)
          "WRITE_FIRST": begin
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if (rea_i) read_a(ADDRA, reseta_i);
          end
          "READ_FIRST": begin
            if (rea_i) read_a(ADDRA, reseta_i);
            if (wea_i) write_a(ADDRA, wea_i, DINA);
          end
          "NO_CHANGE": begin
            if (wea_i) write_a(ADDRA, wea_i, DINA);
            if ((rea_i && !wea_i) || reseta_i) read_a(ADDRA, reseta_i);
          end
        endcase
      end

      always @(posedge CLKB) begin
        case (C_WRITE_MODE_B)
          "WRITE_FIRST": begin
            if (web_i) write_b(ADDRB, web_i, DINB);
            if (reb_i) read_b(ADDRB, resetb_i);
          end
          "READ_FIRST": begin
            if (reb_i) read_b(ADDRB, resetb_i);
            if (web_i) write_b(ADDRB, web_i, DINB);
          end
          "NO_CHANGE": begin
            if (web_i) write_b(ADDRB, web_i, DINB);
            if ((reb_i && !web_i) || resetb_i) read_b(ADDRB, resetb_i);
          end
        endcase
      end
  end
  endgenerate

  // Variable depth output stage
  BLK_MEM_GEN_V2_2_output_stage
    #(.C_DATA_WIDTH (C_READ_WIDTH_A),
      .C_HAS_SSR    (C_HAS_SSRA),
      .C_SINIT_VAL  (C_SINITA_VAL),
      .C_HAS_REGCE  (C_HAS_REGCEA),
      .C_HAS_EN     (C_HAS_ENA),
      .C_FAMILY     (C_FAMILY),
      .num_stages   (num_output_stages),
      .flop_delay   (flop_delay))
      reg_a
        (.CLK   (CLKA),
         .SSR   (SSRA),
         .REGCE (REGCEA),
         .EN    (ENA),
         .DIN   (memory_out_a),
         .DOUT  (DOUTA));

  BLK_MEM_GEN_V2_2_output_stage
    #(.C_DATA_WIDTH (C_READ_WIDTH_B),
      .C_HAS_SSR    (C_HAS_SSRB),
      .C_SINIT_VAL  (C_SINITB_VAL),
      .C_HAS_REGCE  (C_HAS_REGCEB),
      .C_HAS_EN     (C_HAS_ENB),
      .C_FAMILY     (C_FAMILY),
      .num_stages   (num_output_stages),
      .flop_delay   (flop_delay))
      reg_b
        (.CLK   (CLKB),
         .SSR   (SSRB),
         .REGCE (REGCEB),
         .EN    (ENB),
         .DIN   (memory_out_b),
         .DOUT  (DOUTB));

  // Synchronous collision checks
  generate if (!C_DISABLE_WARN_BHV_COLL && C_COMMON_CLK) begin : sync_coll
    always @(posedge CLKA) begin
      // Possible collision if both are enabled and the addresses match
      if (ena_i && enb_i) begin
        is_collision = collision_check(ADDRA, wea_i, ADDRB, web_i);
      end else begin
        is_collision = 0;
      end

      // If the write port is in READ_FIRST mode, there is no collision
      if (C_WRITE_MODE_A=="READ_FIRST" && wea_i && !web_i) begin
        is_collision = 0;
      end
      if (C_WRITE_MODE_B=="READ_FIRST" && web_i && !wea_i) begin
        is_collision = 0;
      end

      // Only flag if one of the accesses is a write
      if (is_collision && (wea_i || web_i)) begin
        $fwrite(collfile, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(collfile, "A %0s address: %0h, B %0s address: %0h\n",
                wea_i ? "write" : "read", ADDRA,
                web_i ? "write" : "read", ADDRB);
      end
    end

  // Asynchronous collision checks
  end else if (!C_DISABLE_WARN_BHV_COLL && !C_COMMON_CLK) begin : async_coll

    // Delay A and B addresses in order to mimic setup/hold times
    wire [C_ADDRA_WIDTH-1:0]  #coll_delay addra_delay = ADDRA;
    wire [0:0]                #coll_delay wea_delay   = wea_i;
    wire                      #coll_delay ena_delay   = ena_i;
    wire [C_ADDRB_WIDTH-1:0]  #coll_delay addrb_delay = ADDRB;
    wire [0:0]                #coll_delay web_delay   = web_i;
    wire                      #coll_delay enb_delay   = enb_i;

    // Do the checks w/rt A
    always @(posedge CLKA) begin
      // Possible collision if both are enabled and the addresses match
      if (ena_i && enb_i) begin
        is_collision_a = collision_check(ADDRA, wea_i, ADDRB, web_i);
      end else begin
        is_collision_a = 0;
      end
      if (ena_i && enb_delay) begin
        is_collision_delay_a = collision_check(ADDRA, wea_i,
                                               addrb_delay, web_delay);
      end else begin
        is_collision_delay_a = 0;
      end


      // Only flag if B access is a write
      if (is_collision_a && web_i) begin
        $fwrite(collfile, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(collfile, "A %0s address: %0h, B write address: %0h\n",
                wea_i ? "write" : "read", ADDRA, ADDRB);

      end else if (is_collision_delay_a && web_delay) begin
        $fwrite(collfile, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(collfile, "A %0s address: %0h, B write address: %0h\n",
                wea_i ? "write" : "read", ADDRA, addrb_delay);
      end

    end

    // Do the checks w/rt B
    always @(posedge CLKB) begin

      // Possible collision if both are enabled and the addresses match
      if (ena_i && enb_i) begin
        is_collision_b = collision_check(ADDRA, wea_i, ADDRB, web_i);
      end else begin
        is_collision_b = 0;
      end
      if (ena_delay && enb_i) begin
        is_collision_delay_b = collision_check(addra_delay, wea_delay,
                                               ADDRB, web_i);
      end else begin
        is_collision_delay_b = 0;
      end


      // Only flag if A access is a write
      if (is_collision_b && wea_i) begin
        $fwrite(collfile, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(collfile, "A write address: %0h, B %s address: %0h\n",
                ADDRA, web_i ? "write" : "read", ADDRB);

      end else if (is_collision_delay_b && wea_delay) begin
        $fwrite(collfile, "%0s collision detected at time: %0d, ",
                C_CORENAME, $time);
        $fwrite(collfile, "A write address: %0h, B %s address: %0h\n",
                addra_delay, web_i ? "write" : "read", ADDRB);
      end

    end
  end
  endgenerate

endmodule
