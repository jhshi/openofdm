//-- $ID:$
// ************************************************************************
// $Id: C_BIT_CORRELATOR_V3_0.V
// ************************************************************************
// Copyright 2000 - Xilinx Inc.
// All rights reserved.
// ************************************************************************
// Filename: C_BIT_CORRELATOR_V3_0.V 
// Creation : Nov. 1th, 2000
// Description: Verilog Behavioral Model for bit_correlator Model
// 
// Algorithm : Compares the bits of a sequence, with a pattern
//             which may/maynot have some bits masked. The sequence
//             can be from upto 8 possible channels, sequencing every
//             clock cycle. (currently supported for serial input)
// ************************************************************************
// ************************************************************************
// Last Change :
//
// ************************************************************************

`timescale 1ns/10ps 

// some definitions

`define true  1'b1
`define false 1'b0

`define c_enable_rlocs   0

`define c_serial 0
`define c_parallel_2_serial 1
`define c_parallel 2

`define c_no_reload 0
`define c_reload 1

module C_BIT_CORRELATOR_V3_0
  (CLK,                     // clock
   DIN,                     // Data INput
   LD_DIN, LD_WE, COEF_LD,  // unsupported reload ports for version 3.0
   ND,                      // qualifying signal for DIN, new data
   DOUT,                    // Data OUTput
   RDY, RFD,                //DOUT qualifier ReaDY, ND qualifier Ready_For_Data
   SEL_I, SEL_O);           // Input and Output channel indicator

  parameter C_CHANNELS          = 1;
  parameter C_DATA_WIDTH        = 1;
  // unsupported placement option for version 3.0
  parameter C_ENABLE_RLOCS      = `false;
  parameter C_HAS_MASK          = `false;
  parameter C_HAS_SEL_INDICATOR      = `false;
  parameter C_INPUT_TYPE        = `c_serial;
  parameter C_LATENCY           = 2; //latency in correlating,
                                     //doesn't include latency 
                                     //due to reading data 
  parameter C_MEM_INIT_FILE     = "bit_corr_16.mif";
  
  // unsupported reload options for version 3.0
  parameter C_RELOAD            = `c_no_reload; 
  parameter C_RELOAD_DELAY      = 0;
  parameter C_RELOAD_MEM_TYPE   = 0;

  // unsupported placement option for version 3.0
  parameter C_SHAPE             = 0;

  // number of taps of the bit correlator
  parameter C_TAPS              = 16;
  
  /******* number of bits needed to represent #channels ********/
  parameter channel_width = ((C_CHANNELS <=2) ? 1:
                            ((C_CHANNELS <=4) ? 2:
                            ((C_CHANNELS <=8) ? 3:4)));
  
  /*************************************************************
   using word 'score' to mean the #bits matching and score_width
   is the bit_width required to represent this number.
  *************************************************************/
  parameter score_width   = ((C_TAPS <    2) ? 1:
                            ((C_TAPS <    4) ? 2:
                            ((C_TAPS <    8) ? 3:
                            ((C_TAPS <   16) ? 4:
                            ((C_TAPS <   32) ? 5:
                            ((C_TAPS <   64) ? 6:
                            ((C_TAPS <  128) ? 7:
                            ((C_TAPS <  256) ? 8:
                            ((C_TAPS <  512) ? 9:
                            ((C_TAPS < 1024) ? 10:
                            ((C_TAPS < 2048) ? 11:
                            ((C_TAPS < 4096) ? 12:13))))))))))));
  parameter rfd_delay     = ((C_INPUT_TYPE == `c_parallel_2_serial) ? 
                                                             C_DATA_WIDTH : 1);
  parameter rdy_counter_max = rfd_delay;
  
  parameter rdy_latency   = C_LATENCY;
  
  parameter actual_input_width = ((C_INPUT_TYPE == `c_serial) ? 1:
                                 ((C_INPUT_TYPE == `c_parallel) ? C_TAPS :
                                          C_DATA_WIDTH));
  input CLK;
  input [actual_input_width - 1 : 0] DIN;
  input LD_DIN;   // not supported in version 3.0
  input LD_WE;    // not supported in version 3.0
  input COEF_LD;  // not supported in version 3.0
  input ND;
  
  output [score_width - 1 : 0] DOUT;
  output RDY;
  output RFD;
  output [channel_width - 1 : 0] SEL_I;
  output [channel_width - 1 : 0] SEL_O;

  reg [score_width - 1 : 0] DOUT;
  reg RDY;
  reg RFD;
  reg [channel_width - 1 : 0] SEL_I;
  reg [channel_width - 1 : 0] SEL_O;
  
  reg local_rdy;

  // registers for input storage
  reg [C_TAPS - 1        : 0] reg_din[C_CHANNELS - 1:0];
  reg [C_TAPS - 1        : 0] tmp_din;
  reg [C_TAPS - 1        : 0] tmp_reg_din;
  // registers for pattern and mask
  reg [C_TAPS - 1        : 0] pattern;
  reg [C_TAPS - 1        : 0] mask;

  reg [channel_width - 1 : 0] in_channel;
  reg [score_width - 1   : 0] count;
  //reg [C_DATA_WIDTH - 1  : 0] psc_din;
  reg [actual_input_width - 1  : 0] psc_din;  //hp, 30jul, trying to correct
                          //the VSS/VCS error messages for psc_bin(C_DATA_WIDTH-1:1) usage.
  reg [score_width       : 0] dout_array[ C_LATENCY - 1 :0];
  reg [score_width       : 0] sel_o_array[ C_LATENCY - 1:0];
  reg rdy_array[ rdy_latency : 0];
  
  reg input_buffer_empty;

  integer count_rfd, delay, count_rdy;
  integer i, bits;
  integer start_correlator; //integer value to start off the process

  integer load_counter;
  
  /************** shift new data into corresponding channel ***********/
  task shift_data;
  
  begin
    if (C_INPUT_TYPE == `c_parallel) 
    begin
      if ((ND == 1'b1) && (RFD == 1'b1))
        reg_din[0] = DIN;
    end
    else if(C_INPUT_TYPE == `c_serial)
    begin
      if((ND == 1'b1) && (RFD == 1'b1))
      begin
        tmp_din = reg_din[in_channel];
        if(C_TAPS > 1)
          tmp_din = {tmp_din[(C_TAPS - 2) : 0], DIN};
        else
          tmp_din = DIN;
        reg_din[in_channel] = tmp_din;
      end
    end
    else if(C_INPUT_TYPE == `c_parallel_2_serial)
    begin
      if((ND == 1'b1) && (RFD == 1'b1))
      begin
        psc_din = DIN;
        load_counter = 0;
      end

      else if ((load_counter < (actual_input_width-1)) && (actual_input_width> 1))
      begin
        for (i = 0; i <= actual_input_width - 1;i=i + 1)
        begin
          if(i== (actual_input_width - 1) )
            psc_din[actual_input_width - 1] = 1'b0;
          else 
            psc_din[i] = psc_din[i+1];
        end
         //psc_din = {1'b0, psc_din[(actual_input_width - 1): 1]};
        load_counter = load_counter + 1;
      end

      if((ND == 1'b0) && (RFD == 1'b1))
        input_buffer_empty = 1'b1;
      else
        input_buffer_empty = 1'b0;
        
  
      tmp_din = reg_din[in_channel];
      if (input_buffer_empty == 1'b0)
      begin
      if(C_TAPS > 1) 
        tmp_din = {tmp_din[(C_TAPS -2) : 0], psc_din[0]};
      else
        tmp_din = psc_din[0];
      end
      reg_din[in_channel] = tmp_din;
    end
  end
  endtask
  
  /************** read the file for pattern and mask bits ***********/
  task read_pattern_mask;
  
  reg[3:0] data_from_file[(C_TAPS -1) : 0];
  reg [3:0] tmp;
  
  begin
    // Reading the MIF file and assigning the bits to
    // pattern and mask variable
  
    $readmemh(C_MEM_INIT_FILE, data_from_file);
  
    for(i=0;i<C_TAPS;i=i+1)
    begin
      tmp = data_from_file[i]; 
      pattern[i] = tmp[0];       
      if(C_HAS_MASK)
        mask[i] = tmp[1];
      else
        mask[i] = 1'b1;
    end
  
  end 
  endtask //end task
  
  /***********************************************************************
   * Initializing various registers
  ***********************************************************************/
  initial

  begin
  
    //for (bits=0;bits <= C_TAPS - 1;bits=bits+1)
    //  tmp_din[bits] = 0;

    tmp_din = {C_TAPS{1'b0}};
    tmp_reg_din = {C_TAPS{1'b0}};
    //psc_din = {C_DATA_WIDTH{1'b0}};
    //hp, 30jul, trying to correct
    //the VSS/VCS error messages for psc_bin(C_DATA_WIDTH-1:1) usage.
    psc_din = {actual_input_width{1'b0}};

    for (i = 0;i < C_CHANNELS;i=i + 1)
      reg_din[i] = tmp_din;
  

  // Initializing the input_channel_select_indicator
       in_channel = 0;
      if((C_HAS_SEL_INDICATOR) && (C_INPUT_TYPE == `c_serial))
      begin
        SEL_I = in_channel;
      end
      else
      begin
        SEL_I = {channel_width{1'bx}};
      end

  // Initializing the output_channel_select_indicator
      if((C_HAS_SEL_INDICATOR) && (C_INPUT_TYPE == `c_serial))
      begin
        SEL_O = {channel_width{1'b0}};
      end
      else
        SEL_O = {channel_width{1'bx}};


    // Set the value for count_rfd, RFD, RDY
      count_rfd = rfd_delay - 2;
      
      RFD = 1;
      RDY = 0;
      local_rdy = 0;
      DOUT = 0;

      count_rdy = 0;
      count_rfd = 0;

      for (i = 0; i<= C_LATENCY - 1; i = i+1)
      begin
        sel_o_array[i] = 0;
        dout_array[i] = 0;
      end
      for (i = 0; i<= C_LATENCY - 1; i = i+1)
        rdy_array[i] = 0;
      
    // initialize the pattern
      read_pattern_mask;

      start_correlator = 0;

  end //initial

/*******************************************************************
 * Select the data dependent on the input type
 ******************************************************************/
  always @ (posedge CLK )
  begin
    if ((ND == 1'b1 ) && (RFD == 1'b1))
    begin

      /*******************  Incrementing channel counter *************/
      if (C_INPUT_TYPE == `c_serial) 
        in_channel = (in_channel >= C_CHANNELS -1 ) ? 0: in_channel + 1;

      start_correlator = 1; //basically waiting for 1st ND

    end // ND high

    shift_data;

/*******************  Counting the matched bits ************/
    if (start_correlator == 0)
      count = 0;
    else
    begin
      count = 0;
      tmp_reg_din = reg_din[in_channel];
      for(bits=0; bits <= (C_TAPS - 1) ; bits = bits + 1)
      begin
        if(mask[bits] == 1'b1)
        begin
          if(tmp_reg_din[bits] == pattern[bits])
          begin
            count = count + 1;
          end
        end
      end
    end
  
    // generate RFD
    //if((C_INPUT_TYPE == `c_parallel_2_serial) && (C_DATA_WIDTH > 1))

    //hp,30jul, trying to correct
    //the VSS/VCS error messages for psc_bin(C_DATA_WIDTH-1:1) usage.
    if((C_INPUT_TYPE == `c_parallel_2_serial) && (actual_input_width > 1))
    begin
      if((ND == 1) && (RFD == 1)) // also checking RFD to allow for ND
                                  // ND to remain high all time when
                                  // user has the input ready always
      begin
        count_rfd = rfd_delay - 2;
        RFD <= 1'b0;
      end
      else if(start_correlator == 1)
      begin
        if (count_rfd == 0)  // RFD is pulled high 1 clk cycle earlier
        begin                  // so that we donot waste one clock.
          RFD <=  1'b1;
        end
        else if (count_rfd > 0)
        begin
          RFD <=  1'b0;
          count_rfd =  (count_rfd - 1);
        end
        else
          $display( "%m,%dns Error: count_rfd < 0", $time);
      end
    end
    else
      RFD <= 1'b1;

    // local_rdy generation dependent on ND and C_DATA_WIDTH

    if (ND == 1)
    begin
      local_rdy = 1;
      count_rdy = rdy_counter_max - 1;
    end
    else
    begin
      if(count_rdy == 0)
      begin
        local_rdy = 0;
      end
      else
      begin
        count_rdy = count_rdy - 1;
        local_rdy = 1;
      end
    end
      
    // RDY generation
    if(rdy_latency == 1)
      RDY <= local_rdy;
    else
    begin
      RDY <= rdy_array[rdy_latency - 2];
      for (delay = rdy_latency -3 ;delay >= 0;delay = delay -1)
        rdy_array[delay +1] <= rdy_array[delay];
      rdy_array[0] <= local_rdy;
    end

    if (C_LATENCY == 1)
      DOUT <= count;
    else if (C_LATENCY >= 2)
    begin
      DOUT <= dout_array[C_LATENCY - 2];
      for ( delay = C_LATENCY - 3; delay >= 0; delay = delay - 1)
        dout_array[delay + 1] <= dout_array[delay];
      dout_array[0] <= count;
    end

    //generate SEL_O 
    if((C_HAS_SEL_INDICATOR) && (C_INPUT_TYPE == `c_serial))
    begin
        if (C_LATENCY >= 1) 
        begin
          SEL_O <= sel_o_array[C_LATENCY - 1];
          for (delay = C_LATENCY - 2;delay >= 0; delay = delay - 1) 
            sel_o_array[delay + 1] <= sel_o_array[delay];
          sel_o_array[0] <= in_channel;
        end

      //generating SEL_O
      SEL_I = in_channel; 
    end

  end //always

endmodule

`undef true
`undef false

`undef c_enable_rlocs

`undef c_serial
`undef c_parallel_2_serial
`undef c_parallel

`undef c_no_reload
`undef c_reload
