/* $Id: PIPELINE_V4_0.v,v 1.11 2008/09/08 20:05:46 akennedy Exp $
--
-- Filename - PIPELINE_V4_0.v
-- Author - Xilinx
-- Creation - 21 Oct 1998
--
-- Description - This file contains the Verilog behavior for the baseblocks utility PIPELINE module
*/


`define allXs {C_WIDTH{1'bx}}
`define all1s {C_WIDTH{1'b1}}

module PIPELINE_V4_0 (D, CLK, CE, ACLR, ASET, AINIT, SCLR, SSET, SINIT, Q);

	parameter C_AINIT_VAL     = "";
	parameter C_HAS_ACLR      = 0;
	parameter C_HAS_AINIT     = 0;
	parameter C_HAS_ASET      = 0;
	parameter C_HAS_CE        = 0;
	parameter C_HAS_SCLR      = 0;
	parameter C_HAS_SINIT     = 0;
	parameter C_HAS_SSET      = 0;
	parameter C_PIPE_STAGES   = 1;
	parameter C_SINIT_VAL     = "";
	parameter C_SYNC_ENABLE   = 0; // c_override
	parameter C_SYNC_PRIORITY = 1; // c_clear	
	parameter C_WIDTH         = 16; 		
	

	input [C_WIDTH-1 : 0] D;
	input CLK;
	input CE;
	input ACLR;
	input ASET;
	input AINIT;
	input SCLR;
	input SSET;
	input SINIT;
	output [C_WIDTH-1 : 0] Q;
	 
    reg [C_WIDTH-1 : 0] pipeliner [0 : C_PIPE_STAGES-1];
	reg [C_WIDTH-1 : 0] intQ;
	// Internal values to drive signals when input is missing
	wire intCE;
	wire intACLR;
	wire intASET;
	wire intAINIT;
	wire intSCLR;
	wire intSSET;
	wire intSINIT;
	 
	wire [C_WIDTH-1 : 0] #1 Q = intQ;

	// Sort out default values for missing ports
	
	assign intCE    = defval(CE,    C_HAS_CE,    1);
	assign intACLR  = defval(ACLR,  C_HAS_ACLR,  0);
	assign intASET  = defval(ASET,  C_HAS_ASET,  0);
	assign intAINIT = defval(AINIT, C_HAS_AINIT, 0);
	assign intSCLR  = defval(SCLR,  C_HAS_SCLR,  0);
	assign intSSET  = defval(SSET,  C_HAS_SSET,  0);
	assign intSINIT = defval(SINIT, C_HAS_SINIT, 0);
	
	reg lastCLK;
	reg lastintACLR;
	reg lastintASET;
	
	reg [C_WIDTH-1 : 0] AIV;
	reg [C_WIDTH-1 : 0] SIV;

    reg cetmp;
    reg set_or_clr;
	
	integer i;
	
	initial 
	begin
		lastCLK     = 1'b0;
		lastintACLR = 1'b0;
		lastintASET = 1'b0;
		AIV = to_bits(C_AINIT_VAL);
		SIV = to_bits(C_SINIT_VAL);
        set_or_clr = (C_SYNC_PRIORITY === 0)?1'b0:1'b1;
        for(i = 0; i < C_PIPE_STAGES; i = i + 1)
          pipeliner[i] = 'b0;
        if(C_PIPE_STAGES != 0)
        begin
		  if(C_HAS_ACLR === 1)
		  	  pipeliner[C_PIPE_STAGES-1] = 'b0;
		  else if(C_HAS_ASET === 1)
		  	  pipeliner[C_PIPE_STAGES-1] = `all1s;
		  else if(C_HAS_AINIT === 1)
		      pipeliner[C_PIPE_STAGES-1] = AIV;
		  else if(C_HAS_SCLR === 1)
			  pipeliner[C_PIPE_STAGES-1] = 'b0;
		  else if(C_HAS_SSET === 1)
			  pipeliner[C_PIPE_STAGES-1] = `all1s;
		  else if(C_HAS_SINIT === 1)
			  pipeliner[C_PIPE_STAGES-1] = SIV;
		  else
		      pipeliner[C_PIPE_STAGES-1] = AIV;			
          intQ = pipeliner[C_PIPE_STAGES-1];
        end
        else
         assign intQ = D;
	end
	
	always@(posedge CLK or intACLR or intASET or intAINIT)
	begin
	  // Do not do anything if there is no pipeline
	  if(C_PIPE_STAGES > 0)
      begin
        // deal with synchronous events first
        if (CLK !== lastCLK && CLK !== 1'bx && lastCLK !== 1'bx)
        begin
          // First the pipeline
          if(intCE === 1'bx)
            for(i = 0; i < C_PIPE_STAGES; i = i + 1)
              pipeliner[i] = `allXs;
          else if(intCE === 1'b1)
            for(i = C_PIPE_STAGES-1; i > 0; i = i - 1)
              pipeliner[i] = pipeliner[i-1];
              
          // Unqualified behaviour
          if(intCE === 1'b1)
            pipeliner[0] = D;
            
          // Synchronous controls
          if(C_SYNC_ENABLE === 0)
            cetmp = 1'b1;
          else
            cetmp = intCE;
          
          if(cetmp === 1'b1)
          begin
            if((set_or_clr === 1'b0 && intSSET === 1'bx) ||
               (set_or_clr === 1'b1 && intSCLR === 1'bx) ||
               intSINIT === 1'bx)
              pipeliner[0] = `allXs;
            else if(intSINIT === 1'b1)                                             //Synchronous init 
              pipeliner[0] = SIV;
            else if(intSCLR === 1'b1 && (set_or_clr === 1'b1 || intSSET === 1'b0)) //Synchronous clear
              pipeliner[0] = 'b0;
            else if(intSSET === 1'b1 && (set_or_clr === 1'b0 || intSCLR === 1'b0)) //Synchronous set 
              pipeliner[0] = `all1s;
          end
        end
        else if(CLK !== lastCLK && (CLK === 1'bx || lastCLK === 1'bx))
        begin
          if(intCE !== 1'b0)
            for(i = 0; i < C_PIPE_STAGES; i = i + 1)
              pipeliner[i] = `allXs;
          else if (C_SYNC_ENABLE === 0)
            pipeliner[0] = `allXs;
        end
        
        //Asynchronous Controls - over ride synchronous effects
        if(intACLR === 1'bx)
          pipeliner[C_PIPE_STAGES-1] = `allXs;
        else if(intACLR === 1'b1)
          pipeliner[C_PIPE_STAGES-1] = 'b0;
        else if(intACLR === 1'b0 && intASET === 1'bx)
          pipeliner[C_PIPE_STAGES-1] = `allXs;
        else if(intACLR === 1'b0 && intASET === 1'b1)
          pipeliner[C_PIPE_STAGES-1] = `all1s;
        else if(intAINIT === 1'bx)
          pipeliner[C_PIPE_STAGES-1] = `allXs;
        else if(intAINIT === 1'b1)
          pipeliner[C_PIPE_STAGES-1] = AIV;
          
        intQ <= pipeliner[C_PIPE_STAGES-1];
      end
	end
	
	always@(intACLR or intASET)
	begin
      lastintACLR <= intACLR;
      lastintASET <= intASET;
//      if($time != 0)
//	      if(intACLR === 1'b0 && intASET === 1'b0 && lastintACLR !== 1'b0 && lastintASET !== 1'b0) // RACE
//			pipeliner[C_PIPE_STAGES] = `allXs;
	end
	
	always@(CLK)
		lastCLK <= CLK;
	
	
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
	
	function [C_WIDTH - 1 : 0] to_bits;
	input [C_WIDTH*8 : 1] instring;
	integer i;
	integer non_null_string;
	begin
		non_null_string = 0;
		for(i = C_WIDTH; i > 0; i = i - 1)
		begin // Is the string empty?
			if(instring[(i*8)] == 0 && 
				instring[(i*8)-1] == 0 && 
				instring[(i*8)-2] == 0 && 
				instring[(i*8)-3] == 0 && 
				instring[(i*8)-4] == 0 && 
				instring[(i*8)-5] == 0 && 
				instring[(i*8)-6] == 0 && 
				instring[(i*8)-7] == 0 &&
				non_null_string == 0)
					non_null_string = 0; // Use the return value to flag a non-empty string
			else
					non_null_string = 1; // Non-null character!
		end
		if(non_null_string == 0) // String IS empty! Just return the value to be all '0's
		begin
			for(i = C_WIDTH; i > 0; i = i - 1)
				to_bits[i-1] = 0;
		end
		else
		begin
			for(i = C_WIDTH; i > 0; i = i - 1)
			begin // Is this character a '0'? (ASCII = 48 = 00110000)
				if(instring[(i*8)] == 0 && 
					instring[(i*8)-1] == 0 && 
					instring[(i*8)-2] == 1 && 
					instring[(i*8)-3] == 1 && 
					instring[(i*8)-4] == 0 && 
					instring[(i*8)-5] == 0 && 
					instring[(i*8)-6] == 0 && 
					instring[(i*8)-7] == 0)
						to_bits[i-1] = 0;
				  // Or is it a '1'? 
				else if(instring[(i*8)] == 0 && 
					instring[(i*8)-1] == 0 && 
					instring[(i*8)-2] == 1 && 
					instring[(i*8)-3] == 1 && 
					instring[(i*8)-4] == 0 && 
					instring[(i*8)-5] == 0 && 
					instring[(i*8)-6] == 0 && 
					instring[(i*8)-7] == 1)		
						to_bits[i-1] = 1;
				  // Or is it a ' '? (a null char - in which case insert a '0')
				else if(instring[(i*8)] == 0 && 
					instring[(i*8)-1] == 0 && 
					instring[(i*8)-2] == 0 && 
					instring[(i*8)-3] == 0 && 
					instring[(i*8)-4] == 0 && 
					instring[(i*8)-5] == 0 && 
					instring[(i*8)-6] == 0 && 
					instring[(i*8)-7] == 0)		
						to_bits[i-1] = 0;
				else
				begin
					$display("Error: non-binary digit in string \"%s\"\nExiting simulation...", instring);
					$finish;
				end
			end
		end 
	end
	endfunction
	
endmodule

`undef allXs

