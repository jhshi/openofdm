// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/trilogy/SPI_ACCESS.v,v 1.17 2009/08/27 18:57:33 robh Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2008 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Internal logic access to the Serial Peripheral Interface (SPI) PROM data
// /___/   /\     Filename : SPI_ACCESS.v
// \   \  /  \    Timestamp : Mon Oct 8 8:49:22 PDT 2007
//  \___\/\___\
//
//
// Revision:
//    10/08/07 - Initial version.
//    07/09/08 - CR476247 - shorten simulation delays.
//    08/10/09 - CR529331 - update write_data (1) to write_data (buffer_number)
// End Revision
///////////////////////////////////////////////////////////////////////////////

`timescale  1 ps / 1 ps

module SPI_ACCESS (
   MISO,
   CLK,
   CSB,
   MOSI
);

parameter SIM_DELAY_TYPE = "SCALED"; // ACCURATE means enforce spec timing delays
                                     // SCALED means shorted delays for faster sim
parameter SIM_DEVICE = "3S1400AN"; 
parameter SIM_FACTORY_ID = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;  // Security Register Bytes[64:127]
parameter SIM_USER_ID =    512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // Security Register Bytes[0:63]
parameter SIM_MEM_FILE = "NONE"; // Memory pre-load

/********************************************************************
Port Declaration:
********************************************************************/
output MISO;

input  CLK;
input  CSB;
input  MOSI;
    
reg MISO_out = 1'b1;
wire CLK_in,CSB_in,MOSI_in;

/*************************************************************************
Device localparam :
*************************************************************************/
localparam           BINARY_OPT = 1'b0;  // 1 means binary page size  
                                         // 0 means default
// these are left alone
real   tDIS     =  0; 
real   tV       =  0; 
real   tcs       = 50e3;  // spec for CSB high pulse width 50 ns
real   tSPICLKH = 68e2; 
real   tSPICLKL = 68e2; 
// scaled sim delays. not constant scale factors. reasonable numbers 
real   tCOMP  = (SIM_DELAY_TYPE != "SCALED") ? 400e6 :  500e3;  // spec tCOMP 400 us buffer to page compare k
real   tXFR   = (SIM_DELAY_TYPE != "SCALED") ? 400e6 :  500e3;  // spec tXFR 400 us buffer to page transfer k
real   tPEP   = (SIM_DELAY_TYPE != "SCALED") ?  40e9 : 2500e3;  // spec tPEP 40 ms page erase and program k
real   tP     = (SIM_DELAY_TYPE != "SCALED") ?   6e9 : 1000e3;  // spec tP 6 ms program k
real   tPE    = (SIM_DELAY_TYPE != "SCALED") ?  35e9 : 1000e3;  // spec tPE 32 ms page erase k
real   tSE    = (SIM_DELAY_TYPE != "SCALED") ? 500e9 : 4000e3;  // spec tSE 5s sector erase k
real   tVCSL  = (SIM_DELAY_TYPE != "SCALED") ?  50e3 :   50e3;  // spec tVCSL 50 us CS after Vcc > Vccmin  k
real   tPUW   = (SIM_DELAY_TYPE != "SCALED") ?  50e3:    50e3;  // spec tPUW 20 ms background op after Vcc k

localparam           Tper   = 15152;    
localparam           Tper33 = 30304;
localparam           name   = "SPI_ACCESS";

reg                  force_continue =1'b0;  // flag to force continue -- for model testing         
     
/*********** Status bits: ***********/
localparam STATUS2 = 1;
localparam STATUS3 =          (SIM_DEVICE == "3S50AN") ?  1 :     
                              (SIM_DEVICE == "3S200AN") ? 1 :     
                              (SIM_DEVICE == "3S400AN") ? 1 :     
                              (SIM_DEVICE == "3S700AN") ? 0 :     
                              (SIM_DEVICE == "3S1400AN")? 1 : 1;  
                                                                  
localparam STATUS4 =          (SIM_DEVICE == "3S50AN") ?  0 :     
                              (SIM_DEVICE == "3S200AN") ? 1 :     
                              (SIM_DEVICE == "3S400AN") ? 1 :     
                              (SIM_DEVICE == "3S700AN") ? 0 :     
                              (SIM_DEVICE == "3S1400AN")? 0 : 0;  
                                                                                 
localparam STATUS5 =          (SIM_DEVICE == "3S50AN") ?  0 :    
                              (SIM_DEVICE == "3S200AN") ? 0 :   
                              (SIM_DEVICE == "3S400AN") ? 0 :   
                              (SIM_DEVICE == "3S700AN") ? 1 :   
                              (SIM_DEVICE == "3S1400AN")? 1 :1;
                                                                        
/***********  no of pages: ***********/                                                            
localparam PAGES   =          (SIM_DEVICE == "3S50AN")  ? 512  :      
                              (SIM_DEVICE == "3S200AN") ? 2048 :     
                              (SIM_DEVICE == "3S400AN") ? 2048 :     
                              (SIM_DEVICE == "3S700AN") ? 4096 :     
                              (SIM_DEVICE == "3S1400AN")? 4096 : 4096; 

/***********  no of pages per sector: ***********/
localparam PAGE_PER_SECTOR =  (SIM_DEVICE == "3S50AN")  ? 128 :           
                              (SIM_DEVICE == "3S200AN") ? 256 :      
                              (SIM_DEVICE == "3S400AN") ? 256 :      
                              (SIM_DEVICE == "3S700AN") ? 256 :      
                              (SIM_DEVICE == "3S1400AN")? 256 : 256;

/***********  no of sectors: ***********/
localparam SECTORS =          (SIM_DEVICE == "3S50AN")  ? 4 :         
                              (SIM_DEVICE == "3S200AN") ? 8 :        
                              (SIM_DEVICE == "3S400AN") ? 8 :        
                              (SIM_DEVICE == "3S700AN") ? 16 :       
                              (SIM_DEVICE == "3S1400AN")? 16 : 16;   

/***********  no of bytes per page: ***********/
localparam PAGESIZE =         (SIM_DEVICE == "3S50AN")  ? (264 - (BINARY_OPT * 8)) :     
                              (SIM_DEVICE == "3S200AN") ? (264 - (BINARY_OPT * 8)) :    
                              (SIM_DEVICE == "3S400AN") ? (264 - (BINARY_OPT * 8)) :    
                              (SIM_DEVICE == "3S700AN") ? (264 - (BINARY_OPT * 8)) :    
                              (SIM_DEVICE == "3S1400AN")? (528 - (BINARY_OPT * 16)):   
                              (528 - (BINARY_OPT * 16));

/***********  no of bytes:  ***********/
localparam MEMSIZE = PAGESIZE * PAGES;

/***********  no of buffers:  ***********/
localparam BUFFERS =          (SIM_DEVICE == "3S50AN")  ? 1 :        
                              (SIM_DEVICE == "3S200AN") ? 2 :       
                              (SIM_DEVICE == "3S400AN") ? 2 :       
                              (SIM_DEVICE == "3S700AN") ? 2 :       
                              (SIM_DEVICE == "3S1400AN")? 2 : 2;    

/***********  no of bits needed to access a byte within a page:  ***********/
localparam BADDRESS =         (SIM_DEVICE == "3S50AN")  ? (9 - (BINARY_OPT * 1)) :  
                              (SIM_DEVICE == "3S200AN") ? (9 - (BINARY_OPT * 1)) : 
                              (SIM_DEVICE == "3S400AN") ? (9 - (BINARY_OPT * 1)) : 
                              (SIM_DEVICE == "3S700AN") ? (9 - (BINARY_OPT * 1)) : 
                              (SIM_DEVICE == "3S1400AN")? (10 - (BINARY_OPT * 1)): 
                                                         (10 - (BINARY_OPT * 1));
                              
/***********  no of bits needed to access a page:  ***********/
localparam PADDRESS =         (SIM_DEVICE == "3S50AN")  ? 9 :      
                              (SIM_DEVICE == "3S200AN") ? 11 :    
                              (SIM_DEVICE == "3S400AN") ? 11 :    
                              (SIM_DEVICE == "3S700AN") ? 12 :    
                              (SIM_DEVICE == "3S1400AN")? 12 : 12;
                              
/***********  no of bits needed to access a sector:  ***********/
localparam SADDRESS =         (SIM_DEVICE == "3S50AN")  ? 2 :       
                              (SIM_DEVICE == "3S200AN") ? 3 :      
                              (SIM_DEVICE == "3S400AN") ? 3 :      
                              (SIM_DEVICE == "3S700AN") ? 4 :      
                              (SIM_DEVICE == "3S1400AN")? 4 : 4;   

/***********  Manufacturer ID: ***********/
localparam [31:0] MAN_ID =    (SIM_DEVICE == "3S50AN")  ? 32'h1F_22_00_00 :     
                              (SIM_DEVICE == "3S200AN") ? 32'h1F_24_00_00 :     
                              (SIM_DEVICE == "3S400AN") ? 32'h1F_24_00_00 :     
                              (SIM_DEVICE == "3S700AN") ? 32'h1F_25_00_00 :     
                              (SIM_DEVICE == "3S1400AN")? 32'h1F_26_00_00 :     
                                32'h1F_26_00_00;


/**********************************************************************
Memory & Registers PreLoading Parameters:
============================= 
These parameters are related to Memory and Registers Preloading.
Memory, Sector Protection Register, Sector Lock-down Register and 
Security Register can be preloaded, in Hex format.

To pre-load Memory (in Hex format), define parameter 
SIM_MEM_FILE = <filename>, where <filename> is the name of 
the pre-load file. 
If SIM_MEM_FILE = "", the Memory is initialized to Erased state (all data = FF).
If the memory is initialized, the status of all pages will be Not-Erased.

To pre-load Security Register (only the User Programmable Bytes 0 to 63), 
define parameter SECURITY = <filename>, where <filename> is the name 
of the pre-load file. 
If SECURITY = "", the register is initialized to erased state (all data = FF).

The Factory Programmed Bytes 64 to 127 are always initialized by defining 
param FACTORY = "factory.txt". As the Factory Programmed Bytes are
accessible to the user for read, a sample of "factory.txt" file 
needs to be included in the Verilog Model directory.
**********************************************************************/

/********* Memory And Access Related Declarations *****************/
reg [7:0]           memory [MEMSIZE-1:0] ;
reg [7:0]           buffer1 [PAGESIZE-1:0] ; //Buffer 1
reg [7:0]           buffer2 [PAGESIZE-1:0] ; //Buffer 2
reg [SADDRESS-1:0]  sector; // sector address
reg [PADDRESS-1:0]  page ; // page address
reg [BADDRESS-1:0]  byte_add ; // byte address
reg [PAGES-1:0]     page_status;  // 0 means page-erased, otherwise not erased
reg [7:0]           status ; // status reg
reg [7:0]           factory_reg[63:0]; // factory programmed security register
reg [7:0]           security_reg[63:0]; // security register
reg                 security_flag; // 0 means that security register has not been programmed yet
reg                 soft_prot_enabled; // 1 means that software sectro protection is enabled

/********* Registers to track the current operation of the device ********/
reg                 status_read;
reg                 updating_buffer1;
reg                 updating_buffer2;
reg                 updating_memory;
reg                 comparing;
reg                 compare_value;
reg                 erasing_page;
reg                 erasing_sector;


/******** Other variables/registers/events ******************/
reg [7:0]           read_data; // temp. register in which data is read-in
reg [7:0]           temp_reg1; // temp. register to store temporary data
reg [7:0]           temp_reg2; // temp. register to store temporary data
reg [PADDRESS-1:0]  temp_page; // temp register to store page-address
reg                 SO_reg = 1'b1 ;
reg                 SO_on ; 
reg                 RDYBSY_reg;
reg                 mem_initialized;
reg                 binary_page;
reg                 foreground_op_enable;
reg                 background_op_enable;
reg                 per_flag=0;
reg                 test_33mhz = 1'b0;
reg                 skip; // reg to denote whether or no an extra clock needs to be skipped.
                          // This skipping is needed only for Inactive Clock Low. 
                          
reg [8*45:1]        cmd_name="        Initialize                      ";
reg [8*5:1]         cycle_mode="idle ";
                            
wire                RDY_BUSYB;
integer             i, j;
integer             page_boundary_low;
integer             page_boundary_high;
integer             current_address;
integer             mem_no; // this will keep track of the actual memory to be used.
integer             arr_rd_dummybyte;
integer             buff_rd_dummybyte;
integer             buffer_number;     // number of the buffer to operate on
integer             erase_flag;         // Flags whether is erase is selected
reg                 clk_err=0;
reg                 clk_err_h=0;
reg                 clk_err_l=0;
reg                 clk_err33=0;
reg                 csb_err=0;
reg                 backgnd_while_busy_err=0;
time                LastSignalRise = 0;
time                last_csb_rise=0;
time                LastSignalFall = 0;
time                clk_low = 0;

/********* Drive SO ***********************/
bufif1              (RDY_BUSYB, RDYBSY_reg, 1'b0); //RDYBUSYB will be driven only if RDYBSY_reg is High

/********* Events to trigger some task based on opcode ***********/   
event               MMCAR ;        // Continuous Array Read
event               MIR ;          // Manufacturer ID Read 
event               MMPTBT ;      // Main Memory Page To Buffer Transfer
event               MMPTBC ;      // Main Memory Page To Buffer 1 Compare
event               BW;           // Buffer 1 Write
event               BTMMPP;  // Buffer To Main Memory Page Prog with or without Built-In Erase 
event               PE ;           // Page Erase
event               SE ;           // Sector Erase
event               MMPPB ;        // Main Memory Page Prog. Through Buffer 1
event               SR ;           // Status Register Read
event               SRP ;          // Security Register Program
event               SRR ;          // Security Register Read

buf b_miso (MISO,MISO_out);
buf b_clk  (CLK_in,CLK);
buf b_csb  (CSB_in,CSB);
buf b_mosi (MOSI_in,MOSI);    

initial    // Check for attribute syntax
begin 
   #1
   if (SIM_DELAY_TYPE !="SCALED"&&SIM_DELAY_TYPE!="ACCURATE") begin
       $display ("Attribute Syntax Error : SIM_DELAY_TYPE in %s The legal values for this attribute are SCALED OR ACCURATE",name);
        if (!force_continue) $finish;
    end 
    if (SIM_DEVICE != "3S50AN" && SIM_DEVICE != "3S200AN" && SIM_DEVICE != "3S400AN" && SIM_DEVICE != "3S700AN" && SIM_DEVICE != "3S1400AN") begin
        $display ("Attribute Syntax Error : SIM_DEVICE in %s The legal values for this attribute are 3S50AN or 3S200AN or 3S400AN or 3S700AN or 3S1400AN",name);
        if (!force_continue) $finish;
    end
end     

/********* Initialize **********************/
initial
begin
    // start with erased state
    // Memory Initialization
    for (j=0; j<MEMSIZE; j=j+1)   // Pre-initiazliation to Erased
    begin                        // state is useful if a user wants to
        memory[j] = 8'hff;        // initialize just a few locations.
    end
    mem_initialized = 0;
    // Now preload, if needed
    if (SIM_MEM_FILE != "NONE") begin
       $readmemh (SIM_MEM_FILE, memory, 0, MEMSIZE-1);
       mem_initialized = 1'b1;
    end
    if (mem_initialized == 1'b1)
       for (j=0; j<PAGES; j=j+1)
          page_status[j] = 1'b1; // memory was initialized, so, Pages are Not Erased.
    else
       for (j=0; j<PAGES; j=j+1)
          page_status[j] = 1'b0;
    RDYBSY_reg = 1'b1;
    // Now initialize all registers
    status[7] = RDYBSY_reg;
    status[6] = 1'b0; // Compare bit is 0 at power up
    status[5] = STATUS5;
    status[4] = STATUS4;
    status[3] = STATUS3;
    status[2] = STATUS2;
    status[1] = 1'b0; // Protection enable is 0 at power up
    status[0] = BINARY_OPT;
    // Security Register Initialization
    security_flag = 1'b0; // not initialized, default contents = 0
    for (j=0; j<64; j=j+1) begin
       security_reg[j] = 8'h0;
       factory_reg[j] = 8'h0;
    end
    if (SIM_USER_ID != 512'h0) begin
       for (j=0; j<64; j=j+1) begin
          for (i=0; i<=7; i=i+1) begin
             temp_reg1[i] = SIM_USER_ID[8*j+i];
          end
          security_reg[j] = temp_reg1;
          if (temp_reg1 !== 8'hff) begin // allow programming if initialized to all ff
             security_flag = 1'b1; // initialized to something other than ff so can't program again
          end
       end
    end
    if (SIM_FACTORY_ID != 512'h0) begin
       for (j=0; j<64; j=j+1) begin
          for (i=0; i<=7; i=i+1) begin
             temp_reg1[i] = SIM_FACTORY_ID[8*j+i];
          end
          factory_reg[j] = temp_reg1;
       end
    end
    arr_rd_dummybyte = 0;
    buff_rd_dummybyte = 0;
    binary_page = BINARY_OPT;
    status_read = 1'b0;
    updating_buffer1 = 1'b0;
    updating_buffer2 = 1'b0;
    updating_memory = 1'b0;
    comparing = 1'b0;
    erasing_page = 1'b0;
    erasing_sector = 1'b0;

    // All o/ps are High-impedance
    SO_on = 1'b0;
    RDYBSY_reg = 1'b1;
    status[7] = RDYBSY_reg;

    // Power-up timing Restrictions
    foreground_op_enable = 1'b0;
    background_op_enable = 1'b0;
    #tVCSL;
    foreground_op_enable = 1'b1; // Enable foreground op_codes
    #tPUW;
    background_op_enable = 1'b1; // Enable background op_codes
end


/************************ TASKS / FUNCTIONS **************************/


/* Task to compute page address */

task comp_page_addr;
    begin
    page = 0; // zero out the redundant bits of 'page'
    case (PADDRESS)
        12 :begin
                if (MAN_ID == 32'h1F_26_00_00) // 16M
                   if (binary_page == 1)
                       page[PADDRESS-1:0] = {temp_reg1[4:0], read_data[7:1]};
                   else
                       page[PADDRESS-1:0] = {temp_reg1[5:0], read_data[7:2]};
                if (MAN_ID == 32'h1F_25_00_00) // 8M
                   if (binary_page == 1)
                       page[PADDRESS-1:0] = {temp_reg1[3:0], read_data[7:0]};
                   else
                       page[PADDRESS-1:0] = {temp_reg1[4:0], read_data[7:1]};
             end
        11 : if (binary_page == 1)
                 page[PADDRESS-1:0] = {temp_reg1[2:0], read_data[7:0]};
             else
                 page[PADDRESS-1:0] = {temp_reg1[3:0], read_data[7:1]};
        9 : if (binary_page == 1)
                 page[PADDRESS-1:0] = {temp_reg1[0], read_data[7:0]};
            else
                 page[PADDRESS-1:0] = {temp_reg1[1:0], read_data[7:1]};
    endcase
    sector[SADDRESS-1:0] = page[PADDRESS-1:PADDRESS-SADDRESS];
end
endtask  // comp_page_addr

/* Task to compute starting byte address */

task comp_byte_addr;
begin
    case (BADDRESS)
        11 : byte_add = {read_data[2:0], 8'h00} ;
        10 : byte_add = {read_data[1:0], 8'h00} ;
        9 : byte_add = {read_data[0], 8'h00} ;
        default: byte_add = 8'h00;
    endcase
end
endtask // comp_byte_addr


/* get_data is a task to get 8 bits of data. This data could be an opcode,
address, data or anything. It just obtains 8 bits of data obtained on MOSI_in*/

task get_data;

integer i;
begin
    for (i=7; i>=0; i = i-1)
    begin
        @(posedge CLK_in);
        read_data[i] = MOSI_in;
    end
end
endtask


/* compute_address is a task to compute the current address,
as well as obtain the page boundaries */

task compute_address;

integer i;
begin
    page_boundary_low = page * PAGESIZE;
    page_boundary_high = page_boundary_low + (PAGESIZE - 1);
    current_address = page_boundary_low + byte_add;
    mem_no = 10;
end
endtask


/* task read_out_array is to read from main Memory, either in
Continuous Mode, or, in Burst Mode */

task read_out_array ;

integer i;
integer temp_high;
integer temp_low;
integer temp_add;
begin
    temp_high = page_boundary_high;
    temp_low = page_boundary_low;
    temp_add = current_address;
    temp_reg1 = memory [temp_add];
    i = 7;
    while (CSB_in == 1'b0) // continue transmitting, while, CSB_in is Low
    begin : CONTINUE_READING
        @(negedge CLK_in) ;
        #tV SO_reg = temp_reg1[i];
        SO_on = 1'b1;
        if (i == 0)
        begin
            temp_add = temp_add + 1; // next byte
            i = 7;
            if (temp_add >= MEMSIZE)
            begin
                temp_add = 0; // Note that rollover occurs at end of memory,
                temp_high = PAGESIZE - 1; // and not at the end of the page
                temp_low = 0;
            end
            if (temp_add > temp_high) // going to next page
            begin
                temp_high = temp_high + PAGESIZE;
                temp_low = temp_low + PAGESIZE;
            end
            temp_reg1 = memory [temp_add];
        end
        else
        i = i - 1; // next bit
    end // reading over, because CSB_in has gone high
end
endtask


/* transfer_to_buffer will transfer data into a buffer from a page of
main memory */

task transfer_to_buffer ;
input buf_type;
input low;

integer buf_type;
integer low;
integer i,k;

begin
    // Intentionally written this way: i.e. the for loop is within all if.
    // Writing in alternative way would cause shorter code, but, significant
    // increase in simulation time.
    if (buf_type == 1)
        for (i=0 ; i < PAGESIZE; i = i+1)
            buffer1[i] = memory[low+i];
    else if (buf_type == 2)
        for (i=0 ; i < PAGESIZE; i = i+1)
            buffer2[i] = memory[low+i];
end
endtask


/* compare_with_buffer will compare data into a buffer against a page of
main memory */

task compare_with_buffer ;
input buf_type;
input low;
output status;

integer buf_type;
integer low;
integer i, k;
reg [7:0] tmp1, tmp2;
reg status;
begin
    status = 1'b0;
    if (buf_type == 1)
        for (i=0 ; i < PAGESIZE; i = i+1)
        begin : LOOP1
            tmp1 = memory[low+i];
            tmp2 = buffer1[i];
            for (k=0; k < 8; k = k+1)
                if (tmp1[k] !== tmp2[k])
                begin  // detected miscompare. No need for further comparison
                    status = 1'b1;
                    disable LOOP1;
                end
        end
    else if (buf_type == 2)
    for (i=0 ; i < PAGESIZE; i = i+1)
    begin : LOOP2
        tmp1 = memory[low+i];
        tmp2 = buffer2[i];
        for (k=0; k < 8; k = k+1)
            if (tmp1[k] !== tmp2[k])
            begin  // detected miscompare. No need for further comparison
                status = 1'b1;
                disable LOOP2;
            end
    end
end
endtask


/* write_data will gat data from MOSI_in, and, write into device */

task write_data ;

input buf_type;
integer buf_type;
integer i;
begin
    while (CSB_in == 1'b0)
    begin
        for (i=7; i>=0; i=i-1)
        begin
            @(posedge CLK_in);
            temp_reg1[i] = MOSI_in;
        end // Complete byte recvd. Now transfer the byte to memory/buffer
        if (buf_type == 1)  // Buffer 1
            buffer1[current_address] = temp_reg1;
        else 
            if (buf_type == 2) // Buffer 2
                 buffer2[current_address] = temp_reg1;
        current_address = current_address + 1;
        if (current_address > page_boundary_high)
            current_address = page_boundary_low;
    end // continue writing. Note that parts of a byte will not be written.
end
endtask


/* read_out_reg will read the output on SO pin. It can read contents of
protection, lock-down or security registers*/

task read_out_reg ;
input reg_type;
input add;
input high;

integer reg_type;
integer add;
integer high;
integer i;

begin
    if (reg_type == 23) // Security Register
        temp_reg1 = security_reg [add];
    i = 7;
    while (CSB_in == 1'b0) // continue transmitting, while, CSB_in is Low
    begin : CONTINUE_READING
        @(negedge CLK_in) ;
        #tV SO_reg = temp_reg1[i];
        SO_on = 1'b1;
        if (i == 0)
        begin
            add = add + 1; // next byte
            i = 7;
            if (add > high)
                temp_reg1 = 8'hxx;
            else
            if (reg_type == 23)
                if (add < 64)
                    temp_reg1 = security_reg [add];
                else
                    temp_reg1 = factory_reg [add-64];
        end
        else
            i = i - 1; // next bit
    end // reading over, because CSB_in has gone high
end
endtask


/* write_to_memory will transfer data from a buffer into a page of
main memory */

task write_to_memory ;
input buf_type;
input low;

integer buf_type;
integer low;

integer i;
begin
    if (buf_type == 1)
        for (i=0 ; i < PAGESIZE; i = i+1)
            memory[low+i] = buffer1[i];
    else if (buf_type == 2)
         for (i=0 ; i < PAGESIZE; i = i+1)
             memory[low+i] = buffer2[i];
    page_status[page] = 1'b1; // this page is now not erased
end
endtask


/* erase_page will erase a page of main memory */

task erase_page ;
input low;
integer low;
integer i;
begin
    for (i=0 ; i < PAGESIZE; i = i+1)
        memory[low+i] = 8'hff;
    page_status[page] = 1'b0; // this page is now erased
end
endtask

////////////////////////////////////////////////////////////////////////////////////
//////////////////////////  Main routine //////////////////////////////////////////
always @(negedge CSB_in)  // the device will now become active
begin : get_opcode
    if (CLK_in == 1'b0)
    begin
        skip = 1'b1;
        cycle_mode = "MODE0"; // CSB_in asserted while clock low, SPI terminology
                              // not supported by model
    end
    else
    begin
        skip = 1'b0;
        cycle_mode = "MODE3"; // CBS asserted while clock high, SPI terminology
        // If the opcode is related to SPI Mode 0/3, no skipping is needed. So, skip
        // will be reset to "0".
        // If opcode is related to Inactive Clock Low/high, skipping might or might
        // not be needed, depending on the value of CLK at negedge of CSB_in. So, in
        // such situations, skip will retain its value.
    end
    get_data;  // get opcode here
    if (foreground_op_enable == 1'b0) // No foreground or background opcode accepted
        $display ("DRC Error : In %s no opcode is allowed: %f delay is required before device can be selected", name, tVCSL);
    else if (cycle_mode != "MODE3") begin // wrong access mode
        $display ("DRC Error : In %s at time: %d must drive CSB_in LOW while CLK is HIGH.", name, $time);
        if (!force_continue) $finish;
    end
    else begin
       case (read_data)   // based on opcode, trigger an action
          8'h03 : begin
                     cmd_name="Main Memory Continuous Array Read";
                     if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        skip = 1'b0;
                        arr_rd_dummybyte = 0;
                        -> MMCAR ;  // Main Memory Continuous Array Read
                     end
                  end
          8'h0B : begin
                     cmd_name="Main Memory Continuous Array Read";
                     if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        skip = 1'b0;
                        arr_rd_dummybyte = 1;
                        -> MMCAR ;  // Main Memory Continuous Array Read
                     end
                  end
          8'h53 : begin
                     cmd_name="Main Memory Page To Buffer 1 Transfer";
                     if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        buffer_number=1;
                        -> MMPTBT ; // Main Memory Page To Buffer 1 Transfer
                     end
                  end
          8'h55 : begin
                     cmd_name="Main Memory Page To Buffer 2 Transfer";
                     if (BUFFERS == 1)
                        $display ("DRC Error : In %s opcode %h is not offered in device %s", name, read_data,SIM_DEVICE);
                     else if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        buffer_number=2;
                        -> MMPTBT ; // Main Memory Page To Buffer 2 Transfer
                     end
                  end
          8'h60 : begin
                     cmd_name="Main Memory Page To Buffer 1 Compare";
                     if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        buffer_number=1;
                        -> MMPTBC ;  // Main Memory Page To Buffer 1 Compare
                     end
                  end
          8'h61 : begin
                     cmd_name="Main Memory Page To Buffer 2 Compare";
                     if (BUFFERS == 1)
                        $display ("DRC Error : In %s opcode %h is not offered in device %s", name, read_data,SIM_DEVICE);
                     else if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        buffer_number=2;
                        -> MMPTBC ;  // Main Memory Page To Buffer 2 Compare
                     end
                  end
          8'h84 : begin
                     cmd_name="Buffer 1 Write";
                     buffer_number=1;
                     -> BW ;   // Buffer 1 Write
                  end
          8'h87 : begin
                     cmd_name="Buffer 2 Write";
                     if (BUFFERS == 1)
                        $display ("DRC Error : In %s opcode %h is not offered in device %s", name, read_data, SIM_DEVICE);
                     else begin
                        buffer_number=2;
                        -> BW ;   // Buffer 2 Write
                     end
                  end
          8'h83 : begin
                     cmd_name="Buffer 1 To Main Memory Page Prog With Erase";
                     if (background_op_enable == 1'b0)
                         $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        erase_flag=1;
                        buffer_number=1;
                        -> BTMMPP ;   // Buffer 1 To Main Memory Page Prog
                     end
                  end
          8'h86 : begin
                     cmd_name="Buffer 2 To Main Memory Page Prog With Erase";
                     if (BUFFERS == 1)
                        $display ("DRC Error : In %s opcode %h is not offered in device %s", name, read_data,SIM_DEVICE);
                     else if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        erase_flag=1;
                        buffer_number=2;
                        -> BTMMPP ;   // Buffer 2 To Main Memory Page Prog
                     end
                  end
          8'h88 : begin
                     cmd_name="Buffer 1 To Main Memory Page Prog";
                     if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        erase_flag=0;
                        buffer_number=1;
                        -> BTMMPP ;   // Buffer 1 To Main Memory Page Prog
                     end
                  end
          8'h89 : begin
                     cmd_name="Buffer 2 To Main Memory Page Prog";
                     if (BUFFERS == 1)
                        $display ("DRC Error : In %s opcode %h is not offered in device %s", name, read_data,SIM_DEVICE);
                     else if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        erase_flag=0;
                        buffer_number=2;
                        -> BTMMPP ;   // Buffer 2 To Main Memory Page Prog
                     end
                  end
          8'h81 : begin
                     cmd_name="Page Erase";
                     if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                         -> PE ;   // Page Erase
                     end
                  end
          8'h82 : begin
                     cmd_name="Main Memory Page Prog. Through Buffer 1";
                     if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        buffer_number=1;
                        -> MMPPB ;   // Main Memory Page Prog. Through Buffer 1
                     end
                  end
          8'h7C : begin
                     cmd_name="Sector Erase";
                     if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else
                        -> SE ;   // Sector Erase
                  end
          8'h85 : begin
                     cmd_name="Main Memory Page Prog. Through Buffer 2";
                     if (BUFFERS == 1)
                        $display ("DRC Error : In %s opcode %h is not offered in device %s", name, read_data,SIM_DEVICE);
                     else if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else begin
                        buffer_number=2;
                        -> MMPPB ;   // Main Memory Page Prog. Through Buffer 2
                     end
                  end
          8'hd7 : begin
                     cmd_name="Status Register Read";
                     skip = 1'b0;
                     -> SR ;   // Status Register Read
                  end
          8'h9F : begin
                     cmd_name="Manufacturer ID Read";
                     skip = 1'b0;
                     -> MIR ;   // Manufacturer ID Read
                  end
          8'h9B : begin
                     cmd_name="Security Register Program";
                     if (background_op_enable == 1'b0)
                        $display ("DRC Error : In %s write operations are not allowed before %f delay", name, tPUW);
                     else if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else
                         -> SRP ; // 4-byte command starting with 9B
                  end
          8'h77 : begin
                     cmd_name="Security Register Read";
                     if (RDYBSY_reg == 1'b0) begin // device is already busy
                        $display ("DRC Error : In %s at time: %d device is busy. Command is not allowed", name, $time);
                        backgnd_while_busy_err=1;
                        if (!force_continue) $finish;
                     end
                     else
                        -> SRR ;  // Security Register Read
                  end
          default : $display ("DRC Error : In %s unrecognized opcode %h", name, read_data);
       endcase
    end
end


/******* Main Memory Continuous Read ********************/

always @(MMCAR)
begin : MMCAR_
    if (arr_rd_dummybyte == 0)
       test_33mhz =1;
    // if it comes here, means, the above if was false.
    get_data;
    temp_reg1[7:0] = read_data [7:0];
    get_data;
    // Now that the two bytes have been obtained, distribute it
    // within PageAddress and byte-address, according to
    // the parameters.
    comp_page_addr;
    comp_byte_addr;

    // next 8 bits always contain byte-address[7:0], and, so is
    // not dependent on parameters
    get_data;
    byte_add[7:0] = read_data[7:0];
    for (j=0; j<arr_rd_dummybyte; j=j+1)
    begin
        get_data ;  // these arr_rd_dummybyte*8 bits are dont-care, and so have been discarded.
    end
    compute_address;
    if (skip == 1'b1)
        @(posedge CLK_in); // skip one CLK
     read_out_array ;
end


/******* Main Memory Page To Buffer Transfer *****************/

always @(MMPTBT)
begin : MMPTBT_
    test_33mhz =1;
    get_data;
    temp_reg1[7:0] = read_data [7:0];
    get_data;
    // Now that the two bytes have been obtained, distribute it
    // within PageAddress according to the parameters
    comp_page_addr;
    get_data; // This is dont_care
    compute_address; // even though, byte-address could be junk,
    // we are only interested in Low page-boundaries,
    // which can be obtained correctly
    @ (posedge CSB_in);
    RDYBSY_reg = 1'b0; // device is busy
    status[7] = 1'b0;
    transfer_to_buffer (buffer_number, page_boundary_low);
    if (buffer_number==1)
        updating_buffer1 = 1'b1;
    else
        updating_buffer2 = 1'b1;
    #tXFR RDYBSY_reg = 1'b1; // device is now ready
    status[7] = 1'b1;
    updating_buffer1 = 1'b0;
    updating_buffer2 = 1'b0;
end


/******* Main Memory Page To Buffer Compare *****************/

always @(MMPTBC)
begin : MMPTBC_
    get_data;
    temp_reg1[7:0] = read_data [7:0];
    get_data;

    // Now that the two bytes have been obtained, distribute it
    // within PageAddress according to the parameters
    comp_page_addr;

    get_data; // This is dont_care

    compute_address; // even though, byte-address could be junk,
    // we are only interested in Low page-boundaries,
    // which can be obtained correctly
    @ (posedge CSB_in);
    RDYBSY_reg = 1'b0; // device is busy
    status[7] = 1'b0;
    compare_with_buffer (buffer_number, page_boundary_low, compare_value);
    comparing = 1'b1;
    #tCOMP RDYBSY_reg = 1'b1; // device is now ready
    status[7] = 1'b1;
    status[6] = compare_value;
    comparing = 1'b0;
end


/*******    Buffer Write *****************/

always @(BW)
begin : BW_
    get_data; // dont care bits
    get_data;
    // got some address bits, depending on device parameters
    comp_byte_addr;
    get_data;
    byte_add[7:0] = read_data [7:0];
    page[PADDRESS-1:0] = 'h0; // buffer is equivalent to just one page
    compute_address;
    write_data (buffer_number);
end


/******* Buffer To Main Memory Page Prog With/Withou Built In Erase *******/

always @(BTMMPP)
begin : BTMMPP_
    get_data;
    temp_reg1[7:0] = read_data [7:0];
    get_data;
    // Now that the two bytes have been obtained, distribute it
    // within PageAddress according to the parameters
    comp_page_addr;
    get_data; // This is dont_care
    compute_address; // even though, byte-address could be junk,
    // we are only interested in Low page-boundaries,
    // which can be obtained correctly
    @ (posedge CSB_in);
    if (page_status[page] != 1'b0 && erase_flag ==0)
    $display ("DRC Error : In %s trying to write into Page %d which is not erased", name, page);
    else
    begin
        RDYBSY_reg = 1'b0; // device is busy
        status[7] = 1'b0;
        write_to_memory (buffer_number, page_boundary_low);
        updating_memory = 1'b1;
        if (erase_flag ==0) begin
           #tP RDYBSY_reg = 1'b1; // device is ready after tP delay (no erase case)
        end
        else begin
           #tPEP RDYBSY_reg = 1'b1; // device is ready after tPEP delay (erase case)
        end
        status[7] = 1'b1;
        updating_memory = 1'b0;
    end
end


//
//******* Main Memory Page Prog Through Buffer *******/
//
always @(MMPPB)
begin : MMPPB_
    get_data;
    temp_reg1[7:0] = read_data [7:0];
    get_data;
    // Now that the two bytes have been obtained, distribute it
    // within PageAddress/ByteAddress according to the parameters
    comp_page_addr;
    comp_byte_addr;
    temp_reg2[7:0] = read_data [7:0];
    get_data;
    byte_add[7:0] = read_data[7:0];
    temp_page = page; // page value has been stored for main memory page program
    page[PADDRESS-1:0] = 'h0; // Buffer is 0 pages
    compute_address; // this computes where to write in buffer
    write_data (buffer_number); // this will write to buffer
    // it will proceed to next step, when, posedge of CSB_in.
    // This is complicated, and, hence, explained here:
    // At posedge of CSB_in, the write_data will get disabled.
    // At this time, writing to buffer needs to stop, and,
    // writing into memory should start.

    page[PADDRESS-1:0] = temp_page[PADDRESS-1:0]; // page address in Main Memory to which
    // data needs to be written
    compute_address; // even if byte-address is junk, we only need Page_Low_Boundary
    RDYBSY_reg = 1'b0; // device is busy
    status[7] = 1'b0;
    write_to_memory (buffer_number, page_boundary_low);
    updating_memory = 1'b1;
    #tPEP RDYBSY_reg = 1'b1; // device is now ready
    status[7] = 1'b1;
    updating_memory = 1'b0;
end


/******* Page Erase *******/

always @(PE)
begin : PE_
    // if it comes here, means, the above if was false.
    get_data;
    temp_reg1[7:0] = read_data [7:0];
    get_data;
    // Now that the two bytes have been obtained, distribute it
    // within PageAddress according to the parameters
    comp_page_addr;
    get_data; // This is dont_care
    compute_address; // even though, byte-address could be junk,
    // we are only interested in Low page-boundaries,
    // which can be obtained correctly
    @ (posedge CSB_in);
    RDYBSY_reg = 1'b0; // device is busy
    status[7] = 1'b0;
    erase_page ( page_boundary_low);
    erasing_page = 1'b1;
    #tPE RDYBSY_reg = 1'b1; // device is now ready
    status[7] = 1'b1;
    erasing_page = 1'b0;
end


/******* Sector Erase *******/

always @(SE)
begin : SE_
    get_data;
    temp_reg1[7:0] = read_data [7:0];
    get_data;
    // Now that the two bytes have been obtained, distribute it
    // within PageAddress according to the parameters
    comp_page_addr;
    get_data; // This is dont_care
    compute_address; // even though, byte-address could be junk,
    // we are only interested in Low page-boundaries,
    // which can be obtained correctly
    @ (posedge CSB_in);
    erasing_sector = 1'b1; 
    RDYBSY_reg = 1'b0; // device is busy
    status[7] = 1'b0;
    if (page < 8)
    begin
        page_boundary_low = 0;
        for (j=page_boundary_low; j<(page_boundary_low+8*PAGESIZE); j=j+PAGESIZE)
            erase_page ( j ); // erase 8 pages, i.e. a block
        for (j=0; j<8; j=j+1) // erase_page will only change the status of one-page
            page_status[j] = 1'b0; // hence, changing the remaining ones explicitly
    end
    else if (page < PAGE_PER_SECTOR)
    begin
        page_boundary_low = 8*PAGESIZE;
        for (j=page_boundary_low; j<(page_boundary_low+((PAGE_PER_SECTOR-8)*PAGESIZE)); j=j+PAGESIZE)
            erase_page ( j ); // erase 248/120 pages, i.e. a block
        for (j=8; j<PAGE_PER_SECTOR; j=j+1) // erase_page will only change the status of one-page
            page_status[j] = 1'b0; // hence, changing the remaining ones explicitly
    end
    else
    begin
        page[(PADDRESS-SADDRESS)-1:0] = 0;
        page_boundary_low = page*PAGESIZE;
        for (j=page_boundary_low; j<(page_boundary_low+(PAGE_PER_SECTOR*PAGESIZE)); j=j+PAGESIZE)
            erase_page ( j ); // erase 256/128 pages, i.e. a block
        for (j=0; j<PAGE_PER_SECTOR; j=j+1) // erase_page will only change the status of one-page
            page_status[page+j] = 1'b0; // hence, changing the remaining ones explicitly
    end
    #tSE;
    RDYBSY_reg = 1'b1; // device is now ready
    status[7] = 1'b1;
    erasing_sector = 1'b0;
end

/********* Status Register Read ********************/

always @(SR)
begin: SR_
    status_read = 1'b1; // reading status_reg
    if (skip == 1'b1)
    @(posedge CLK_in); // skip one CLK
    j = 8;
    while (CSB_in == 1'b0)
    begin
        @(negedge CLK_in);
        #tV ;
        if (j > 0)
            j = j-1;
        else
            j = 7;
        SO_reg=status[j];
        SO_on = 1'b1;
        SO_reg = status[j];
    end // output next bit on next falling edge of CLK
    status_read = 1'b0; // status_reg read is over
end

always @(SO_on,SO_reg)
begin
   if (SO_on == 1)
     MISO_out = SO_reg;
   else 
     MISO_out  = 1;
end


/******* Security Register Program *******/

always @(SRP)
begin : SRP_
    cmd_name="Security Register Program"; 
    temp_reg1[7:0] = 8'h00;
    for (j=0;j<3; j=j+1)  // 4 byte command test for 3 00 bytes
    begin  
       get_data;
        if ( read_data != 'h00)
        begin
           $display ("DRC Error : In %s this 4 byte opcode starting 9B with is not offered ", name);              
           disable SRP_;
       end
   end
    current_address = 0;
    page_boundary_low = 0;
    page_boundary_high = 63;  //rm changed from 64 for wrap sooner
    write_data (1); // this will write to buffer
    // it will proceed to next step, when, posedge of CSB_in.
    // This is complicated, and, hence, explained here:
    // At posedge of CSB_in, the write_data will get disabled.
    // At this time, writing to buffer needs to stop, and,
    // writing into memory should start.

    RDYBSY_reg = 1'b0; // device is busy
    status[7] = 1'b0;
    // Program security_reg
    if (security_flag == 0) // Security Register has not been programmed before
    begin
        for (j=0 ; j < 64; j = j+1)
        security_reg[j] = buffer1[j];
        // Update security_flag;
        security_flag = 1'b1;
        #tP RDYBSY_reg = 1'b1; // device is now ready
        status[7] = 1'b1;
    end
    else
    begin
        $display ("DRC Error : In %s at time %d Security Register can only be programmed once", name, $time);
        if (!force_continue) $finish;
        RDYBSY_reg = 1'b1; // device is now ready
        status[7] = 1'b1;
    end
end


/********* Manufacturing ID Read ********************/

always @(MIR)
begin: MIR_
    j = 32;
    if (skip == 1'b1)
        @(posedge CLK_in); // skip one CLK
    while (CSB_in == 1'b0)
    begin
        @(negedge CLK_in);
        #tV ;
        if (j > 0)
        begin
            j = j-1;
            SO_reg=MAN_ID[j];
            SO_on = 1'b1;
            SO_reg = MAN_ID[j];
        end
        else if (j == 0)
        begin
            SO_on = 1'b1;
            SO_reg = 1'bx;
        end
    end // output next bit on next falling edge of CLK
end


/******* Security Register Read ********************/

always @(SRR)
begin : SRR_
    get_data; // these 24 bits are dont-care,
    get_data; // and so have been discarded.
    get_data;
    if (skip == 1'b1)
    @(posedge CLK_in); // skip one CLK
    read_out_reg (23, 0, 127);
end


/******** Posedge CSB_in. Stop all reading, recvng. commands/addresses etc. *********/

always @(posedge CSB_in)
begin
    backgnd_while_busy_err = 1'b0;
    disable MMCAR_; // MMCAR will stop, if CSB_in goes high
    disable BW_; // BW will stop, if CSB_in goes high
    disable SR_; // Status reading should stop.
    status_read = 1'b0;
    disable MIR_; // MIR will stop, if CSB_in goes high
    disable SRR_ ; // SRR will stop, if CSB_in goes high
    disable read_out_array;
    disable get_data; // Stop data retrieval
    disable write_data; // Stop writing to buffers, NOW
    test_33mhz =0;
    cycle_mode = "idle";
    #tDIS SO_on = 1'b0;  // SO is now in high-impedance
end

always @(posedge CSB_in or negedge CSB_in)
begin
    if ((($time - last_csb_rise) < tcs  ) && ($time > tcs) && !CSB_in) begin    // check CSB_in high violation on negedge
        $display("DRC Error : In %s CSB high violation at %t Minimum Width allowed : %3.1f ns ", name, $time, tcs/1000);
        csb_err <=1;
      end
   if (CSB_in) begin  // get the time for the start of a high pulse
       last_csb_rise <=$time;
       csb_err <=0;
      end
end

/******** Frequency Test *********/

always @(posedge CLK_in or negedge CLK_in)
  begin
    if ((($time - LastSignalRise) < tSPICLKH  ) && ($time > Tper) && !clk_err_h )  begin   // check clock high violation
        $display("DRC Error : In %s High violation at %t Minimum Width allowed : %3.1f ns ", name, $time, tSPICLKH/1000);
        clk_err_h <=1;
    end
    if (($time > Tper) && ($time - LastSignalFall < tSPICLKL)&& !clk_err_l)begin //check for clock low violation
        $display("DRC Error : In %s Low violation at %t Minimum Width allowed : %3.1f ns ", name, $time, tSPICLKL/1000);
        clk_err_l <=1;
    end
    if ((((CLK_in && $time -LastSignalRise < Tper) && $time > Tper))&& !clk_err) begin   // check for max frequency violation
        $display("DRC Error : Clock Frequency Exceeds Maximum in %s model at time %t.", name, $time);
        clk_err<=1;
    end
    if ((((CLK_in && $time -LastSignalRise < Tper33) && $time > Tper33)) && !clk_err33 && test_33mhz) begin   // check for 33 MHz frequency violation
        $display ("DRC Error : In %s at : %4.2f this op code is not allowed above 33 Mhz",name ,$time);
        clk_err33<=1;
    end
    if ((($time - LastSignalRise) > tSPICLKH  ) && !CLK_in  )   // check if clock high violation is gone
        clk_err_h <=0;
    if ((($time - LastSignalFall) > tSPICLKL  ) && CLK_in  )    // check if clock low violation is gone
      clk_err_l <=0;
    if (CLK_in && ($time -LastSignalRise > Tper))  // check if max frequency violation is gone
        clk_err <=0;
    if ((CLK_in && ($time -LastSignalRise > Tper33))||!test_33mhz)  // check if 33 MHz max frequency violation is gone
        clk_err33 <=0;
    if (CLK_in == 1 )                // save edge time for next iteration
        LastSignalRise <= $time;
    else
       LastSignalFall <= $time;
  end

    specify

        if (!CSB)(CLK => MISO) = (100:100:100, 100:100:100);
        if ( CSB)(CSB => MISO) = (0:0:0, 0:0:0);

        specparam PATHPULSE$ = 0;

    endspecify


    
endmodule
