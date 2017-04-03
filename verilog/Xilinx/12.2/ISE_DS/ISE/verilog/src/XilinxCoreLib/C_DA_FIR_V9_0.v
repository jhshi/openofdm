/*
-- $Revision: 1.12 $ $Date: 2008/09/08 20:07:46 $
----------------------------------------------------------------------
-- This file is owned and controlled by Xilinx and must be used     --
-- solely for design, simulation, implementation and creation of    --
-- design files limited to Xilinx devices or technologies. Use      --
-- with non-Xilinx devices or technologies is expressly prohibited  --
-- and immediately terminates your license.                         --
--                                                                  --
-- Xilinx products are not intended for use in life support         --
-- appliances, devices, or systems. Use in such applications are    --
-- expressly prohibited.                                            --
--                                                                  --
-- Copyright (C) 2004, Xilinx, Inc.  All Rights Reserved.           --
----------------------------------------------------------------------
--
--  Description:
--    DA FIR filter behavioral model
--
*/

`timescale 1 ns/10 ps

// !!! undef at the end if we add to this

`define true 1'b1
`define false 1'b0
`define TRUE 1'b1
`define FALSE 1'b0

`define c_signed 0
`define c_unsigned 1
`define c_nrz 2

`define c_symmetric 0
`define c_non_symmetric 1
`define c_neg_symmetric 2

`define c_single_rate_fir 0
`define c_polyphase_interpolating 1
`define c_polyphase_decimating 2
`define c_hilbert_transform 3
`define c_interpolated_fir 4
`define c_half_band 5
`define c_decimating_half_band 6
`define c_interpolating_half_band 7

`define c_no_reload 0
`define c_stop_during_reload 1


//**********************************************************
// This line is used in the ActiveHDL testbench
// module Verilog_Model   
  
// This line is used in the SVG testbench 
module C_DA_FIR_V9_0
//**********************************************************  

    (
      DIN, ND, 
      CLK,
      RST,
      COEF_LD,
      LD_DIN,
      LD_WE,
      DOUT,
      DOUT_I, DOUT_Q,
      RDY, RFD, 
      SEL_I, SEL_O,
      CAS_F_IN, CAS_R_IN, CAS_F_OUT, CAS_R_OUT
   );


   // NOTE: These parameters MUST be in ALPHABETICAL order  
   //**** Parameters modified to match CONSTANT declarations in testbench file *****
   parameter C_BAAT               = 16; 
   parameter C_CHANNELS           = 1;
   parameter C_COEFF_TYPE         = `c_signed;
   parameter C_COEFF_WIDTH        = 16;
   parameter C_DATA_TYPE          = `c_signed;
   parameter C_DATA_WIDTH         = 16;
   parameter C_ENABLE_RLOCS       = 0;      
   parameter C_FILTER_TYPE        = `c_single_rate_fir;     
   parameter C_HAS_RESET          = 0;
   parameter C_HAS_SEL_I          = 0; 
   parameter C_HAS_SEL_O          = 0;
   parameter C_HAS_SIN_F          = 0; 
   parameter C_HAS_SIN_R          = 0; 
   parameter C_HAS_SOUT_F         = 0; 
   parameter C_HAS_SOUT_R         = 0; 
   parameter C_LATENCY            = 9;  
   parameter C_MEM_INIT_FILE      = "std_12_coef.mif";
   parameter C_OPTIMIZE           = 0;      
   parameter C_POLYPHASE_FACTOR   = 1;
   parameter C_REG_OUTPUT         = 1;
   parameter C_RELOAD             = `c_no_reload; 
   parameter C_RELOAD_DELAY       = 0;
   parameter C_RELOAD_MEM_TYPE    = 0; // ignored
   parameter C_RESPONSE           = `c_non_symmetric;
   parameter C_RESULT_WIDTH       = 36;      
   parameter C_SATURATE           = 0; // not supported      
   parameter C_SHAPE              = 0;      
   parameter C_TAPS               = 12;
   parameter C_USE_MODEL_FUNC     = 0; // if 1 then use latency function otherwise use C_LATENCY
   parameter C_ZPF                = 1;

   // bits need to represent channel   
   parameter channel_width = ((C_CHANNELS <=2) ? 1:
                             ((C_CHANNELS <=4) ? 2: 
                             ((C_CHANNELS <=8) ? 3:4))); 
      

   // Interpolated filter: number of taps including zero packing factor
   parameter zpf_taps = C_TAPS*C_ZPF;   

   // input ports
   input [C_DATA_WIDTH - 1 :0] DIN;
   input ND;  
   input RST;
   input [C_BAAT - 1:0] CAS_R_IN;   
   input [C_BAAT - 1:0] CAS_F_IN;   
   input CLK;     
   input COEF_LD;      
   input [C_COEFF_WIDTH - 1 : 0] LD_DIN;
   input LD_WE;

   // output ports
   output [C_RESULT_WIDTH - 1 :0] DOUT;    
   output [C_DATA_WIDTH - 1 :0] DOUT_I;    
   output [C_RESULT_WIDTH - 1 :0] DOUT_Q;    
   output RDY;    
   output RFD;    
   output [channel_width - 1 :0] SEL_I;
   output [channel_width - 1 :0] SEL_O; 
   output [C_BAAT - 1:0] CAS_R_OUT; 
   output [C_BAAT - 1:0] CAS_F_OUT;  

// coefficients intialized from memory file
// or coefficient input
reg [C_COEFF_WIDTH - 1 : 0] c_data [0 : C_TAPS - 1];
reg [C_COEFF_WIDTH - 1 : 0] tmp_c_data;
reg [C_COEFF_WIDTH - 1 : 0] c_int_data [0 : C_TAPS - 1]; // absolute value of coefficients
reg c_data_sign [0 : C_TAPS - 1];                      // coefficient sign

// temp variable for incoming data
reg [C_DATA_WIDTH - 1 : 0] tmp_x_data;
// integer array of filter data
reg [C_DATA_WIDTH - 1 : 0]  x_int_data [0 : C_CHANNELS*C_TAPS - 1];   // absolute value of sample data
reg [C_DATA_WIDTH - 1 : 0]  x_zpf_data [0 : C_CHANNELS*zpf_taps - 1];   // absolute value of interpolated filter data (with zeros inserted)
reg  x_data_sign [0 : C_CHANNELS*C_TAPS - 1];  // sample data sign
reg  x_zpf_data_sign [0 : C_CHANNELS*zpf_taps - 1]; // sample data sign for interpolated filters

//   maxm number of results PER CHANNEL that may need to be saved until they can be output on DOUT 
parameter back_data_per_channel = (C_USE_MODEL_FUNC == 1) ? 50 :
                                  (C_POLYPHASE_FACTOR < 1) ? 2 * (C_LATENCY+1) :
                                                               2 * (C_LATENCY+1)*C_POLYPHASE_FACTOR;      

// maxm number of results that may need to be saved until they can be output on DOUT
parameter back_data = (C_USE_MODEL_FUNC == 1) ? 50 :
                      (C_POLYPHASE_FACTOR < 1) ? 2 * (C_LATENCY+1) :
                                                 2 * (C_LATENCY+1)*C_POLYPHASE_FACTOR*C_CHANNELS;
reg [C_RESULT_WIDTH - 1 :0] tmpDOUT [0 : back_data - 1];
// variable to hold the I component of the Hilbert output
reg [C_DATA_WIDTH - 1 : 0] x_hilbert[0 : back_data - 1];
// number of cycles before each saved result can be output, and RDY asserted
integer count_rdy[0 : back_data - 1];

// output regs
reg [C_RESULT_WIDTH - 1 :0] DOUT;
reg [C_DATA_WIDTH - 1 :0] DOUT_I;
reg [C_RESULT_WIDTH - 1 :0] DOUT_Q;
reg RFD;
reg RDY;
reg prevRDY;   
   
reg [channel_width - 1 : 0]SEL_I;   
reg [channel_width - 1 : 0]SEL_O;

reg [C_BAAT - 1:0] CAS_F_OUT;
reg [C_BAAT - 1:0] CAS_R_OUT;
reg [C_DATA_WIDTH - 1:0] cascade_data_f;
reg [C_DATA_WIDTH - 1:0] cascade_data_r;
reg delay1ND;
reg delay2ND;


`define all1s {C_RESULT_WIDTH{1'b1}}
`define all0s {C_RESULT_WIDTH{1'b0}}
`define allXs {C_RESULT_WIDTH{1'bx}}
`define MAX_NUMBER_SAMPLES 8          // Maximum number of samples that can be stored in the last input FIFO  

// number of coefs that must be provided during reloading
parameter num_reload_coefs   = (C_RESPONSE == `c_non_symmetric) ? (C_TAPS) : (C_TAPS+1)/2;
// cascade data defaults
parameter cascade_num_cycles = (C_DATA_WIDTH != C_BAAT && C_RESPONSE != `c_non_symmetric) ?
                                 (C_DATA_WIDTH + 1 + C_BAAT - 1)/C_BAAT :
                                 (C_DATA_WIDTH + C_BAAT - 1)/C_BAAT; 
parameter extwidth           = cascade_num_cycles * C_BAAT;  

reg [extwidth - 1:0] save_casc_f, save_casc_r; 
   
integer i,j;
integer c_taps_2;
integer sel_i,sel_o; 
integer prev_sel_i;
integer load_counter; 
integer count_rfd_non_decimating;          //  replicates functionality of 'count_rfd' in original model (SJZ 2/1B) 
integer new_data[0 : C_CHANNELS - 1];      //  made integer an array 
integer count_rfd[0 : C_CHANNELS - 1];    //  made integer an array   
integer rdy_counter;                      //  tracks clocks between when RDY can go active 
integer data_output_rdy;                  //  indicates that one channel has data available to be output
integer data_output_channel;              //  indicates the channel that has data available
integer next_data_output_channel;          //  tracks which channel will be next to have data available 
integer subfilter_number;                  //  tracks which subfilter the input data is being written to 
integer subfilter_number_delayed;
integer subfilter_num_samples_buffer[0 : C_POLYPHASE_FACTOR - 1];      //  number of samples stored in each subfilter's input buffer 
integer compute_channel_select;            //  tracks which channel is performing a computation  
integer read_buffer_to_rfd_counter;        //  counts clocks between RDY going active and RFD being asserted 
integer delay_first_read_flag;            // Holds up read of data out input buffers until one clock after last subfilters buffer has first data sample written into it
integer c_pipe_stages; 
integer cascade_out_cycle_number, cascade_in_cycle_number;  
integer do_compute_result;
integer rfd_latency;             // number of cycles after ND that RFD can be asserted again
integer reloading;               // true if the filter is in the process of reloading
integer reloading_one_cycle;     // true if it is one cycle since COEF_LD was asserted

integer prev_reset; // to track if there was a reset in the previous clock
                      // cycle, and has been removed now.
//---------------------------------------------------------
// initialise
//---------------------------------------------------------

  initial
  begin
    if(C_USE_MODEL_FUNC == 1)
    begin
      $display("%m,%dns ERROR: This model has not been set up to compute latency.  Please call Xilinx Support.", $time);
      $stop;
    end
    else
       c_pipe_stages = C_LATENCY - 1;   // Subtract one since the model doesn't count the first rising edge
    rfd_latency = compute_rfd_latency(C_FILTER_TYPE);
    if (C_HAS_SIN_F || C_HAS_SOUT_F) // cascaded  
       c_pipe_stages = c_pipe_stages - 1; // We Wait for a cycle before storing it
       
    // coefficient checks
    if(C_FILTER_TYPE == `c_half_band)
       if(C_TAPS % 2 == 0)
       begin
          $display("%m,%dns ERROR: for halfband filters the number of taps must be odd", $time);
          $display("%m,%dns -- No of taps is set to %d  \n Exiting simulation...", $time, C_TAPS);
         $stop;
       end
    
    // read coefficients from the MIF file
    $readmemh(C_MEM_INIT_FILE, c_data);         
    c_taps_2 = C_TAPS/2;   

    // Allocate to absolute value array and set the sign of each coefficient
    // Convert NRZ coefficients to signed
    for (i=0;i < C_TAPS; i= i+1)
    begin
      tmp_c_data = c_data[i];
      if( C_COEFF_TYPE == `c_signed && tmp_c_data[C_COEFF_WIDTH - 1] === 1'b1)
      begin
        c_int_data[i] = ~tmp_c_data +1;
        c_data_sign[i] = 1;
      end 
      else if (C_COEFF_TYPE == `c_nrz)
      begin
        if (tmp_c_data[0] === 1'b0)
          c_data_sign[i] = 0;
        else
          c_data_sign[i] = 1;
        c_int_data[i] = 1'b1;
      end
      else
      begin
        c_int_data[i] = tmp_c_data;
        c_data_sign[i] = 0;
      end
    end

    RFD = 1;
    reloading = `false;
    reloading_one_cycle = `false;

    sel_i = 0;
    if(C_HAS_SEL_I)
       SEL_I <= 1'b0;
       
    sel_o = 0;      
    if(C_HAS_SEL_O)
       SEL_O <= 1'b0;
       
    // do all initialization common to startup and to reloading
    do_initialize;

    prev_reset = 0;

  end //initial  

   
//---------------------------------------------------------
// always on posedge of clock
//---------------------------------------------------------

  always@ (posedge CLK)
  begin
    // Reset DOUT if RST input is active 
    if (C_HAS_RESET && RST === 1'b1)
    begin
      //DOUT <= `all0s;
      do_initialize;
      RFD <= 1'b0;
      prev_reset = 1;

      sel_i = 0;
      if(C_HAS_SEL_I)
         SEL_I <= 1'b0;
 
      if(C_HAS_SEL_O)
       begin
         sel_o = 0;
         SEL_O <= 1'b0;
       end
       if (C_RELOAD != `c_no_reload)
       begin
         reloading = `false;
         reloading_one_cycle = `false;
       end

       if(reloading == `true)
       begin
          $display("%m,%dns WARNING: Coefficient reloading was already in progress when RST occured.  So stopping the reload process midway. Start the reloading again to get valid results at the output.", $time);
       end
    end
    else 
    begin
      if(prev_reset == 1)
      begin
        RFD <= 1'b1;
        prev_reset = 0;
      end 
      
     // handle the load coefficients
    if (C_RELOAD == `c_stop_during_reload && COEF_LD === 1'b1 )
    begin
      if (reloading == `true)
      begin
        $display("%m,%dns ERROR: Reloading is already in progress.  Please assert COEF_LD only after the current reload has been completed", $time);
        $stop;
      end  
      
      reloading = `true;

      sel_i = 0;
      if(C_HAS_SEL_I)
        SEL_I <= 1'b0;
       
      if(C_HAS_SEL_O)
      begin
        sel_o = 0;
        SEL_O <= 1'b0;
      end

    /*  if(RDY === 1'b1)
      begin
        if(C_HAS_SEL_O == 1)
        begin
          sel_o = (sel_o >= C_CHANNELS - 1)? 0: sel_o+1;
          SEL_O <= sel_o;
        end
      end  
      */

      // do all initialization common to startup and to reloading
      do_initialize;  
      
      if (LD_WE === 1'b1)
      begin
        $display("%m,%dns ERROR: LD_WE must only be asserted the cycle after COEF_LD is asserted.", $time);
        $stop;
      end
      RFD = 0;
    end  // Stop during reload AND COEF_LD = 1
  
    if (C_RELOAD == `c_stop_during_reload && LD_WE === 1'b1 )
    begin
      if (reloading == `false)
      begin
        $display("%m,%dns Warning: LD_WE must only be asserted when the filter is in the process of reloading.  Please assert COEF_LD to start the reload process.", $time);
      end
      if (load_counter >= num_reload_coefs)
      begin
        $display("%m,%dns Warning: The required number of coefficients have already been provided.  LD_WE and LD_DIN will be ignored.", $time);
      end
      
      tmp_c_data = LD_DIN;
      // Save the absolute value of the coefficient as well as its sign
      if( C_COEFF_TYPE == `c_signed && tmp_c_data[C_COEFF_WIDTH - 1] === 1'b1)
      begin
        c_int_data[load_counter] = ~tmp_c_data +1;
        c_data_sign[load_counter] = 1;
      end 
      
      // Convert NRZ coefficients to signed
      else if (C_COEFF_TYPE == `c_nrz)
      begin
        if (tmp_c_data[0] === 1'b0)
          c_data_sign[load_counter] = 0;
        else
          c_data_sign[load_counter] = 1;
        c_int_data[load_counter] = 1'b1;
      end
      else
      begin
        c_int_data[load_counter] = tmp_c_data;
        c_data_sign[load_counter] = 0;
      end
      
      // For symmetric or negative symmetric coefficients, update the coefficient 
      // mirror posn, and update the sign accordingly
      if (C_RESPONSE == `c_symmetric)
      begin
        c_int_data[C_TAPS-load_counter - 1] = c_int_data[load_counter];
        c_data_sign[C_TAPS-load_counter - 1] = c_data_sign[load_counter];
      end
      else if (C_RESPONSE == `c_neg_symmetric && (C_TAPS % 2 == 0 || load_counter < (C_TAPS - 1)/2))
      begin
        c_int_data[C_TAPS-load_counter - 1] = c_int_data[load_counter];
        c_data_sign[C_TAPS-load_counter - 1] = (c_data_sign[load_counter]+1)%2;
      end
      
      load_counter = load_counter + 1;
      // All coefficients have been supplied.  RFD will be asserted in C_RELOAD_DELAY cycles
      if ((load_counter) >= num_reload_coefs )
        count_rfd_non_decimating = C_RELOAD_DELAY;
        
    end    // Stop during reload AND LD_WE = 1

    if (reloading == `true)
    begin
      if (count_rfd_non_decimating > 0)
      begin
        count_rfd_non_decimating = count_rfd_non_decimating - 1;
        
          // Filter reloading has completed, and the filter is ready to assert RFD
        if (count_rfd_non_decimating == 0)
        begin
          reloading = `false;
          reloading_one_cycle = `false;
        end
      end
    end
  
    // Filter is NOT in the process of reloading the coefficients
    else
    begin  
      // For all results waiting to be output, decrement the number of cycles before RDY should be asserted
      for(j = 0; j<C_CHANNELS; j=j+1)  
        for(i = 0; i< new_data[j]; i=i+1)
          count_rdy[(j*back_data_per_channel + i)] = (count_rdy[(j*back_data_per_channel + i)] < 1) ? 0 :count_rdy[(j*back_data_per_channel + i)] - 1;  

      // Decrement the number of cycles before RFD should be asserted
      count_rfd[next_data_output_channel] = (count_rfd[next_data_output_channel] < 1) ? 0 : count_rfd[next_data_output_channel] - 1;      
      count_rfd_non_decimating = (count_rfd_non_decimating < 1) ? 0 : count_rfd_non_decimating - 1;
      read_buffer_to_rfd_counter = (read_buffer_to_rfd_counter < 1) ? 0 : read_buffer_to_rfd_counter - 1;  
      rdy_counter = (rdy_counter < 1) ? 0 : rdy_counter - 1;
       
      //-----------------------------------------------------------------------------------------
      // Store any new data coming in the DIN port
      //-----------------------------------------------------------------------------------------
      if(ND === 1'b1 && RFD === 1'b1)
        if (!C_HAS_SIN_F && !C_HAS_SOUT_F)     // Not cascaded          
          shift_data(DIN);                    // shift the new data into data memory & update "subfilter_num_samples_buffer[]"

      //-----------------------------------------------------------------------------------------
      // Determine if the filter should begin a computation & whether RFD should be enabled. 
      //-----------------------------------------------------------------------------------------
      if (C_FILTER_TYPE == `c_polyphase_decimating || C_FILTER_TYPE == `c_decimating_half_band) // decimating filter
      begin  
        do_compute_result = `false;  
        
        //-----------------------------------------------------------------------------------------
        // Single channel Decimating filters
        //-----------------------------------------------------------------------------------------
        if (C_CHANNELS == 1)
        begin
          // No input buffers are created for single channel filters, only registers are used. 
           if (subfilter_num_samples_buffer[C_POLYPHASE_FACTOR - 1] == 1)
          begin
            if (count_rfd[0] > 0)   // A previous computation has not yet completed
              do_compute_result = `false;
            else
            begin
              do_compute_result = `true;
              count_rfd[0] = rfd_latency;
            end
          end  
          
          if (do_compute_result)
            if (subfilter_num_samples_buffer[C_POLYPHASE_FACTOR - 1] > 0)
              // Each subfilter has one sample read out from the input buffer for each computation 
              for (i = 0; i < C_POLYPHASE_FACTOR; i = i + 1)
                subfilter_num_samples_buffer[i] = subfilter_num_samples_buffer[i] - 1;                      

              
          // Determine if RFD should be enabled  by checking if the last register has data 
           if (subfilter_num_samples_buffer[C_POLYPHASE_FACTOR - 1] == 0)      
            RFD <= 1;
          else if (subfilter_num_samples_buffer[C_POLYPHASE_FACTOR - 1] == 1)
            if (do_compute_result)    // A computation will be started and a sample will be read from each subfilter 
              RFD <= 1;
            else                
              if (count_rfd[0] == 0)  // No computation is busy being performed
                RFD <= 1;
              else           // The input buffer cannot except any more samples even though samples will be read out of the buffer  
                RFD <= 0;  
          // Cannot accept any more samples because the register is full and a new computation is not ready to begin 
          else
            RFD <= 0;
            
        end    // Single channel Decimating filters 
        
        //-----------------------------------------------------------------------------------------
        // Multi-channel Decimating filters
        //-----------------------------------------------------------------------------------------
        else
        begin
          // Compute a result every time "C_POLYPHASE_FACTOR" samples have been received and there is no
          //  prior computation being performed.
           if (subfilter_num_samples_buffer[C_POLYPHASE_FACTOR - 1] >= 1)
          begin  
            // A previous computation has not yet completed
            if ( (subfilter_number_delayed == C_POLYPHASE_FACTOR - 1) && (ND == 1'b1) && (RFD === 1'b1) )   
            begin
              do_compute_result = `true;
              count_rfd[compute_channel_select] = rfd_latency;   
            end
            else
              do_compute_result = `false;
          end  
          
          // Update number of samples left in the each subfilter buffer after data has been read out of the buffer 
          if (subfilter_num_samples_buffer[C_POLYPHASE_FACTOR - 1] > 0)
          begin
            if (delay_first_read_flag)
            begin
              if (read_buffer_to_rfd_counter == 0)
              begin
                read_buffer_to_rfd_counter = rfd_latency;
  
                // Each subfilter has one sample read out from the input buffer for each computation 
                for (i = 0; i < C_POLYPHASE_FACTOR; i = i + 1)
                  subfilter_num_samples_buffer[i] = subfilter_num_samples_buffer[i] - 1;                      
              end  
            end          
            
            // Set flag indicating that the first data sample has been written into the last subfilter
            //  input buffer.  This is needed so that the "read_buffer_to_rfd_counter" does NOT start 
            //  until one clock after the first sample has been written to the last subfilter buffer.
            delay_first_read_flag = 1;
            
          end
          // The last subfilter's input buffer is empty 
          else
            delay_first_read_flag = 0;
      
          // Input FIFOs are created for multi-channel filters.  Once the last FIFO has been filled with
          //  "MAX_NUMBER_SAMPLES" samples, no more inputs will be accepted.
          // Determine if RFD should be enabled  by looking at input FIFO of the LAST channel only. 
          if (subfilter_num_samples_buffer[C_POLYPHASE_FACTOR - 1] < `MAX_NUMBER_SAMPLES) 
            if (RFD === 1'b1)
              RFD <= 1;
            // Allow new data to be received after data has been output and data has been read from the input buffers  
            else if ( read_buffer_to_rfd_counter == rfd_latency )
              RFD <= 1;
            else
              RFD <= 0;
          // The last subfilter's input buffer is full 
          else
            RFD <= 0;  
            
        end    // Multiple channel implementation 
      end    // Decimating filter 
      
      // NOT a decimating filter
      else if (count_rfd_non_decimating > 0)
        RFD <= 0;
      else
        RFD <= 1;         

      //-----------------------------------------------------------------------------------------
      // Update the SEL_I port and other signals (for Non-Decimating filters)
      //-----------------------------------------------------------------------------------------
      if (ND === 1'b1 && RFD === 1'b1)
      begin
        // NOT a Decimating filter 
        if (C_FILTER_TYPE != `c_polyphase_decimating && C_FILTER_TYPE != `c_decimating_half_band) 
        begin
          count_rfd_non_decimating = rfd_latency;
          if (count_rfd_non_decimating > 0)
            RFD <= 0;
            
          do_compute_result = `true;
        end
        
        if (!C_HAS_SIN_F && !C_HAS_SOUT_F) // Not cascaded
        begin        
          prev_sel_i = sel_i;
          sel_i = (sel_i >= C_CHANNELS - 1) ? 0 : sel_i+1;
          if(C_HAS_SEL_I)
            SEL_I <= sel_i;            
        end    // Not cascaded
      end   // ND high and RFD high  
      
      else
        // NOT a Decimating filter 
        if (C_FILTER_TYPE != `c_polyphase_decimating && C_FILTER_TYPE != `c_decimating_half_band) 
          do_compute_result = `false;  

      //-----------------------------------------------------------------------------------------  
      // Compute a new result 
      //-----------------------------------------------------------------------------------------
      if (do_compute_result)
      begin
        compute_result(c_pipe_stages);  
  
        // for interpolating filters, stuff zeros into data memory, and compute the new results
        if (C_FILTER_TYPE == `c_polyphase_interpolating || C_FILTER_TYPE == `c_interpolating_half_band)
        begin
          for (i=1; i<C_POLYPHASE_FACTOR; i=i+1)
          begin
            shift_data({C_DATA_WIDTH{1'b0}});
            compute_result(c_pipe_stages+i);
          end
        end
      end    
            
      // Cascading has not been updated for NRZ or for reloading
      if (C_HAS_SIN_F || C_HAS_SOUT_F) // cascaded
        handle_cascading;

       //-----------------------------------------------------------------------------------------------
       // Check the next channel to see if any data is ready to be output.  
      //-----------------------------------------------------------------------------------------------  
       data_output_rdy = 0;    // Clear signal that indicates that a channel has data available      
       
      // Check if the next channel has a result is ready to be output   
      if (rdy_counter == 0)
        if( (count_rdy[(next_data_output_channel * back_data_per_channel)] == 0) && (new_data[next_data_output_channel] > 0) )
        begin
          new_data[next_data_output_channel] = new_data[next_data_output_channel] - 1;
          for(j = 0; j < new_data[next_data_output_channel]; j=j+1)
            count_rdy[(next_data_output_channel * back_data_per_channel + j)] = count_rdy[(next_data_output_channel * back_data_per_channel + j+1)];  
              
          data_output_channel = next_data_output_channel;
          next_data_output_channel = (next_data_output_channel == (C_CHANNELS - 1)) ? 0 : next_data_output_channel + 1; 
          data_output_rdy = 1;    // Set signal that indicates that a channel has data available 
        end

      prevRDY = RDY;   
      if (data_output_rdy == 1)
      begin
        if (C_FILTER_TYPE == `c_polyphase_interpolating || C_FILTER_TYPE == `c_interpolating_half_band)
          rdy_counter = 0;
        else
          rdy_counter = rfd_latency;  
          
        RDY <= 1;  

        // place output on DOUT
        if(C_FILTER_TYPE != `c_hilbert_transform)
          DOUT <= tmpDOUT[(data_output_channel*back_data_per_channel + new_data[data_output_channel])];         
        else
        begin
          DOUT_I <= x_hilbert[(data_output_channel*back_data_per_channel + new_data[data_output_channel])];
          DOUT_Q <= tmpDOUT[(data_output_channel*back_data_per_channel + new_data[data_output_channel])];                 
        end            
      end   
      else    // No data is available to be output
      begin            
        prevRDY = RDY;
        RDY <= 0;  
        // If outputs are not registered, and RDY is low, set DOUT (or DOUT_I and DOUT_Q) to Xs
        if(C_REG_OUTPUT == 0)
        begin      
          if(C_FILTER_TYPE != `c_hilbert_transform)
            DOUT <= `allXs;
          else
          begin               
            DOUT_I <= {C_DATA_WIDTH{1'bx}};
            DOUT_Q <= `allXs;
          end   
        end
      end            

      // Update SEL_O the cycle after RDY is asserted
      if (prevRDY === 1'b1)
      begin
        if (C_HAS_SEL_O == 1)
        begin
          sel_o = (sel_o >= C_CHANNELS - 1)? 0: sel_o+1;
          SEL_O <= sel_o;
        end
      end
    end   // reloading
  end  //reset else block
  end //always

  // cascade init. Cascading has not been updated for reloading or NRZ
  initial
  begin
    cascade_in_cycle_number = cascade_num_cycles+1;
    cascade_out_cycle_number = cascade_num_cycles+1;
    delay1ND = 1'b0;
    delay2ND = 1'b0;
    save_casc_f = {extwidth{1'b0}};
    save_casc_r = {extwidth{1'b0}};
  end // initial

  // Handle cascading.  Cascading has not been updated for reloading or NRZ
  task handle_cascading;
  reg [C_DATA_WIDTH - 1:0] saved_din, new_f_data, new_r_data, saved_int_data;
  reg [extwidth - 1:0] save_casc_f_out, save_casc_r_out; 
  begin

  if (ND === 1'b1 && RFD === 1'b1)
  begin
    if (!C_HAS_SIN_F)
      saved_din <= DIN;
  end
  else if (delay2ND === 1'b1) 
  begin
    save_casc_f = {extwidth{1'b0}};
    save_casc_r = {extwidth{1'b0}};
    cascade_in_cycle_number = 1;
  end

    // if we are reading in data, finish doing so
    if (cascade_in_cycle_number <= cascade_num_cycles && C_DATA_WIDTH != C_BAAT)
    begin
      if (C_HAS_SIN_F)
        save_casc_f = save_casc_f | (CAS_F_IN << ((cascade_in_cycle_number - 1)*C_BAAT));
      if (C_HAS_SIN_R)
        save_casc_r = save_casc_r | (CAS_R_IN << ((cascade_in_cycle_number - 1)*C_BAAT));
      cascade_in_cycle_number = cascade_in_cycle_number + 1;
    end

    if (delay1ND === 1'b1)
    begin
      if (!C_HAS_SIN_F)
        new_f_data = saved_din;
      else if (C_BAAT == C_DATA_WIDTH) // pda
        new_f_data = CAS_F_IN;
      else
        new_f_data = save_casc_f[C_DATA_WIDTH - 1:0];

      if (C_HAS_SIN_R)
        if (C_BAAT == C_DATA_WIDTH) // pda
          new_r_data = CAS_R_IN;
        else
          new_r_data = save_casc_r[C_DATA_WIDTH - 1:0];

     shift_cascaded_data(new_f_data, new_r_data); // shift in the new data
     compute_result(c_pipe_stages); 
     
     if (C_HAS_SOUT_F || C_HAS_SOUT_R)
     begin
       saved_int_data = x_int_data[sel_i*C_TAPS]; 
       if (C_DATA_TYPE == `c_signed && saved_int_data[C_DATA_WIDTH - 1] === 1'b1)
         save_casc_r_out = {{extwidth-C_DATA_WIDTH{1'b1}}, saved_int_data}; // sign extend
       else
         save_casc_r_out = saved_int_data;
       if (C_RESPONSE == `c_non_symmetric)
         save_casc_f_out = save_casc_r_out;
       else
       begin
         saved_int_data = x_int_data[sel_i*C_TAPS + C_TAPS/2];
         if (C_DATA_TYPE == `c_signed && saved_int_data[C_DATA_WIDTH - 1] === 1'b1)          
           save_casc_f_out = {{extwidth-C_DATA_WIDTH{1'b1}}, saved_int_data}; // sign extend 
         else
           save_casc_f_out = saved_int_data;
        end
       cascade_out_cycle_number = 1;
     end    
   end // delay1ND === 1'b1
  // if we were writing out data, finish doing so
  if (cascade_out_cycle_number <= cascade_num_cycles)
  begin
    if (C_HAS_SOUT_F)
    begin
      CAS_F_OUT <= #1 save_casc_f_out[C_BAAT - 1:0];
      save_casc_f_out = save_casc_f_out >> C_BAAT;
    end
    if (C_HAS_SOUT_R)     
    begin
      CAS_R_OUT <= #1 save_casc_r_out[C_BAAT - 1:0];
      save_casc_r_out = save_casc_r_out >> C_BAAT;
    end
    cascade_out_cycle_number = cascade_out_cycle_number + 1;
  end
  else if (cascade_out_cycle_number == cascade_num_cycles+1 && C_BAAT != C_DATA_WIDTH)
  begin
    if (C_HAS_SOUT_F)
      if (C_RESPONSE == `c_non_symmetric)
        if (C_TAPS == 1)
          CAS_F_OUT <= #1 save_casc_f[C_BAAT - 1:0];
        else
          CAS_F_OUT <= #1 x_int_data[sel_i*C_TAPS+1];
      else
        if (C_TAPS == 2)
          CAS_F_OUT <= #1 save_casc_f[C_BAAT - 1:0];
        else
          CAS_F_OUT <= #1 x_int_data[sel_i*C_TAPS + 1 + C_TAPS/2];
    if (C_HAS_SOUT_R)
      if (C_TAPS == 2 || (C_HAS_SIN_F && C_HAS_SOUT_F && C_TAPS == 3))
        CAS_R_OUT <= #1 save_casc_r[C_BAAT - 1:0];
      else
        CAS_R_OUT <= #1 x_int_data[sel_i*C_TAPS + 1];
    cascade_out_cycle_number = cascade_out_cycle_number + 1;
  end

  delay2ND = delay1ND;
  delay1ND = ND;
end
endtask

  // shift in the new input data
  task shift_data;
  input [C_DATA_WIDTH - 1:0] datain;
  begin
    // Increment the count of the number of samples stored in the input buffer (for decimating filters).  Each
    //  subfilter holds multiple samples for every channel.  For multi-channel operation, each new sample
    //  is the data for the next sequential channel.  Once every channel has gotten a sample, the subsequent
    //  N samples (N = number of channels) are written to the next subfilter.  A new computation is started
    //  once a channel has at least one sample in every subfilter.
    if (C_FILTER_TYPE == `c_polyphase_decimating || C_FILTER_TYPE == `c_decimating_half_band)
    begin   
      subfilter_num_samples_buffer[subfilter_number] = subfilter_num_samples_buffer[subfilter_number] + 1;
      
      // This variable is used to control when a new computation can is started.
      subfilter_number_delayed = subfilter_number;
      
      // After each channel has received a sample, subsequent data will be written to the next subfilter 
      if (sel_i == C_CHANNELS - 1)
        subfilter_number = (subfilter_number == C_POLYPHASE_FACTOR - 1) ? 0 : subfilter_number + 1;     
    end
          
    // All filters except Interpolated FIRs
    if     (   C_FILTER_TYPE == `c_single_rate_fir 
            || C_FILTER_TYPE == `c_half_band
            || C_FILTER_TYPE == `c_polyphase_decimating
            || C_FILTER_TYPE == `c_polyphase_interpolating
            || C_FILTER_TYPE == `c_interpolating_half_band
            || C_FILTER_TYPE == `c_decimating_half_band
            || C_FILTER_TYPE == `c_hilbert_transform) 
    begin
      // move data through only for the current sel_i channel
      for ( j = C_TAPS - 1 ; j > 0; j = j - 1)
      begin
        x_int_data[sel_i*C_TAPS + j]  = x_int_data[sel_i*C_TAPS + j - 1];   
        x_data_sign[sel_i*C_TAPS + j] = x_data_sign[sel_i*C_TAPS + j - 1];   
      end
    
      // For signed data that is negative, take the 2's complement of the data and set the sign bit high
      if ( C_DATA_TYPE == `c_signed && datain[C_DATA_WIDTH - 1] === 1'b1)
      begin
        x_int_data[sel_i*C_TAPS] = ~datain +1;
        x_data_sign[sel_i*C_TAPS] = 1;
      end     
      else if (C_DATA_TYPE == `c_nrz)
      begin
        if (datain == 1'b0)
          x_data_sign[sel_i*C_TAPS] = 0;
        else
          x_data_sign[sel_i*C_TAPS] = 1;
          
        x_int_data[sel_i*C_TAPS] = 1'b1;            
      end    
      // For unsigned data or positive, signed data, move the new data into memory 
      else
      begin
        x_int_data[sel_i*C_TAPS] = datain;            
        x_data_sign[sel_i*C_TAPS] = 0;
      end
    end
  
    else if (C_FILTER_TYPE == `c_interpolated_fir) 
    begin
       // move data through only for current sel_i channel
       for ( j = zpf_taps - 1 ; j > 0; j = j - 1)
       begin
          x_zpf_data[sel_i*zpf_taps+j] = x_zpf_data[sel_i*zpf_taps+j - 1];   
          x_zpf_data_sign[sel_i*zpf_taps+j] = x_zpf_data_sign[sel_i*zpf_taps+j - 1];   
       end

       // Save the new data as an absolute value and a sign
       if( C_DATA_TYPE == `c_signed && datain[C_DATA_WIDTH - 1] === 1'b1)
       begin
         x_zpf_data[sel_i*zpf_taps] = ~datain +1;            
         x_zpf_data_sign[sel_i*zpf_taps] = 1;            
       end
       else if (C_DATA_TYPE == `c_nrz)
       begin
         if (datain == 1'b0)
           x_zpf_data_sign[sel_i*zpf_taps] = 0;            
         else
           x_zpf_data_sign[sel_i*zpf_taps] = 1;            
         x_zpf_data[sel_i*zpf_taps] = 1'b1;            
       end
      else
      begin
         x_zpf_data[sel_i*zpf_taps] = datain;            
         x_zpf_data_sign[sel_i*zpf_taps] = 0;            
      end
    end
  end
  endtask   // shift_data

// cascading has not been updated for nrz or for reloading
// Note that new data is now shifted into position 0 - this task must be changed
  task shift_cascaded_data;
  input [C_DATA_WIDTH - 1:0] dataf, datar;
  integer midpoint;
  begin
    midpoint = C_TAPS/2;

    if (C_HAS_SIN_R)
    begin
      for (j=0; j<midpoint - 1; j=j+1)
        x_int_data[sel_i*C_TAPS + j] = x_int_data[sel_i*C_TAPS + j + 1];
      x_int_data[sel_i*C_TAPS + midpoint - 1] = datar;
      for (j=midpoint; j<C_TAPS - 1; j=j+1)
        x_int_data[sel_i*C_TAPS + j] = x_int_data[sel_i*C_TAPS + j + 1];
      x_int_data[sel_i*C_TAPS + C_TAPS - 1] = dataf;
    end
    else
    begin
      for (j=0; j<C_TAPS - 1; j=j+1)
        x_int_data[sel_i*C_TAPS + j] = x_int_data[sel_i*C_TAPS + j + 1];
      x_int_data[sel_i*C_TAPS + C_TAPS - 1] = dataf;
    end
  end
  endtask // shift_cascaded_data

  // compute the new result for the current sel_o channel.
  task compute_result;
  input [31:0] pipeline_length;
  reg [C_RESULT_WIDTH - 1 : 0] new_result;
  reg [C_RESULT_WIDTH - 1 : 0] tmp_result;
  reg [C_COEFF_WIDTH - 1 : 0] tmp_c_data;
  integer c_is_signed;
  integer x_is_signed;  
  begin
    // calculate DOUT for the previous sel_i channel
    new_result = 0;
    for ( j = 0 ; j <= C_TAPS - 1; j = j+1)
    begin
      if(C_FILTER_TYPE == `c_interpolated_fir)
      begin
        tmp_x_data  = x_zpf_data[compute_channel_select*zpf_taps+(j*C_ZPF)];
        x_is_signed = x_zpf_data_sign[compute_channel_select*zpf_taps+(j*C_ZPF)];
      end 
    
      // All filters except Interpolated FIRs
      else
      begin
        tmp_x_data  = x_int_data[compute_channel_select*C_TAPS+j];
        x_is_signed = x_data_sign[compute_channel_select*C_TAPS+j];
      end
    
      tmp_result = tmp_x_data*c_int_data[j];
      if ((x_is_signed == 1 && c_data_sign[j] == 1'b0) ||   
          (x_is_signed == 0 && c_data_sign[j] == 1'b1) )              
      begin
         tmp_result = ~tmp_result+1;  // Result is negative if ONE of the sign bits (data/coef) was set (data/coef was negative)
      end                   
      new_result = new_result + tmp_result;
    end  
  
    // Save the new result in the result array
    for (j=back_data_per_channel - 1; j>0; j= j - 1)
    begin
      tmpDOUT[(compute_channel_select*back_data_per_channel + j)]   = tmpDOUT[(compute_channel_select*back_data_per_channel + j - 1)];               
      x_hilbert[(compute_channel_select*back_data_per_channel + j)] = x_hilbert[(compute_channel_select*back_data_per_channel + j - 1)];
    end
    
    tmpDOUT[(compute_channel_select*back_data_per_channel)] = new_result;
  
    // This is only used by hilbert transform FIRs
    tmp_x_data  = x_int_data[compute_channel_select*C_TAPS - 1 + (C_TAPS+1)/2]; 
    x_is_signed = x_data_sign[compute_channel_select*C_TAPS - 1 + (C_TAPS+1)/2];
    if (x_is_signed == 1)
      x_hilbert[(compute_channel_select*back_data_per_channel)] = ~tmp_x_data + 1;
    else
      x_hilbert[(compute_channel_select*back_data_per_channel)] = tmp_x_data;

    // Save the number of cycles before the result is placed on the output
    count_rdy[(compute_channel_select*back_data_per_channel + (new_data[compute_channel_select]))] = pipeline_length;
    new_data[compute_channel_select] = new_data[compute_channel_select] + 1;
    
    // Update channel number that will begin the next computation 
      if (compute_channel_select < C_CHANNELS - 1)
        compute_channel_select = compute_channel_select + 1;
      else
        compute_channel_select = 0;
    
  end
  endtask // compute_result 
   
  // All initialization required at startup, and at reloading
  task do_initialize;
  begin
      // set the data array to zero
      for (i=0; i<= C_CHANNELS*C_TAPS - 1; i= i+1)
      begin
        if (C_DATA_TYPE === `c_nrz)
          x_int_data[i] = 1'b1;
        else 
          x_int_data[i] = 0;
        x_data_sign[i] = 0;
      end
      for (i=0; i<= C_CHANNELS*zpf_taps - 1; i= i+1)
      begin
        if (C_DATA_TYPE === `c_nrz)
          x_zpf_data[i] = 1'b1;
        else 
          x_zpf_data[i] = 0;
        x_zpf_data_sign[i] = 0;
      end  

      if (C_FILTER_TYPE != `c_hilbert_transform)
      begin
         if (C_REG_OUTPUT == 0)
           DOUT <= `allXs;
         else
           DOUT <= `all0s;
      end
      else
      begin         
         if (C_REG_OUTPUT == 0)
         begin
           DOUT_I <= {C_DATA_WIDTH{1'bx}};
           DOUT_Q <= `allXs;
         end
         else
         begin
           DOUT_I <= {C_DATA_WIDTH{1'b0}};
           DOUT_Q <= `all0s;
         end
      end           

      for (i=0;i<back_data;i=i+1)
      begin
        tmpDOUT[i] = 0;
        x_hilbert[i] = 0;
        count_rdy[i] = 0;
      end
        
      for (i=0;i<C_CHANNELS;i=i+1)
      begin
        new_data[i]  = 0;
        count_rfd[i] = 0;
      end
      
      for (i=0;i<C_POLYPHASE_FACTOR;i=i+1)
      begin
        subfilter_num_samples_buffer[i] = 0;
      end
      
      prevRDY = 0;
      RDY <= 0;
            
      if (C_HAS_SOUT_F)
      begin
         CAS_F_OUT <= 1'b0;
         cascade_data_f   = {C_DATA_WIDTH{1'b0}};
      end         
         
      if (C_HAS_SOUT_R && C_RESPONSE != `c_non_symmetric )
      begin
         CAS_R_OUT <= 1'b0;
         cascade_data_r   = {C_DATA_WIDTH{1'b0}};
      end         
      else
         CAS_R_OUT <= 1'bx;         

      subfilter_number = 0;
      load_counter = 0;
      data_output_channel = 0; 
      prev_sel_i = 0;  
      compute_channel_select = 0;    
      read_buffer_to_rfd_counter = 0;
      next_data_output_channel = 0;    
      subfilter_number_delayed = 0;     
      delay_first_read_flag = 0;     
      rdy_counter = 0;  
      data_output_rdy = 0;      
      do_compute_result = `false;        
      count_rfd_non_decimating = 0;
  end
  endtask    // do_initialize

//---------------------------------------------------------
// Supporting functions
//---------------------------------------------------------
    function defval;
    input i;
    input hassig;
    input val;
        begin
            if(hassig == 1)
                defval = i;
            else
                defval = val;
        end
    endfunction
//---------------------------------------------------------
// Compute rfd latency - the number of cycles after ND that RFD will be asserted again
//---------------------------------------------------------
   function integer compute_rfd_latency;
   input [31:0] filter_type;
   integer rfd_latency;
   begin
     if (C_BAAT == C_DATA_WIDTH)
       rfd_latency = 1;
     else if (C_BAAT == 1)
       if (C_RESPONSE == `c_non_symmetric || C_FILTER_TYPE == `c_polyphase_interpolating)
         rfd_latency = C_DATA_WIDTH;
       else
         rfd_latency = C_DATA_WIDTH + 1;
     else if (C_RESPONSE == `c_non_symmetric || C_FILTER_TYPE == `c_polyphase_interpolating)
       rfd_latency = (C_DATA_WIDTH + C_BAAT - 1)/C_BAAT;
     else
       rfd_latency = (C_DATA_WIDTH + 1 + C_BAAT - 1)/C_BAAT;

     if ((C_FILTER_TYPE == `c_polyphase_interpolating || C_FILTER_TYPE == `c_interpolating_half_band) && (rfd_latency < C_POLYPHASE_FACTOR)) 
       rfd_latency = C_POLYPHASE_FACTOR;
     if (C_FILTER_TYPE == `c_polyphase_decimating || C_FILTER_TYPE == `c_decimating_half_band)
       compute_rfd_latency = rfd_latency;
     else
       compute_rfd_latency = rfd_latency - 1;
   end
   endfunction

//---------------------------------------------------------
endmodule // end of dafir behavioural model
//---------------------------------------------------------
//---------------------------------------------------------

`undef true
`undef false
`undef TRUE 
`undef FALSE

`undef c_signed
`undef c_unsigned 
`undef c_nrz

`undef c_symmetric
`undef c_non_symmetric
`undef c_neg_symmetric

`undef c_single_rate_fir 
`undef c_polyphase_interpolating 
`undef c_polyphase_decimating 
`undef c_half_band 
`undef c_hilbert_transform 
`undef c_interpolated_fir
`undef c_interpolating_half_band
`undef c_decimating_half_band

`undef c_no_reload 
`undef c_stop_during_reload
