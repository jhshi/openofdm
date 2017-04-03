// Copyright(C) 2004 by Xilinx, Inc. All rights reserved.
// This text contains proprietary, confidential
// information of Xilinx, Inc., is distributed
// under license from Xilinx, Inc., and may be used,
// copied and/or disclosed only pursuant to the terms
// of a valid license agreement with Xilinx, Inc. This copyright
// notice must be retained as part of this text at all times.

// $Revision: 1.10 $ $Date: 2008/09/08 16:51:32 $

`timescale 1ns/10ps

module TRIG_TABLE_V5_1(theta, sin_table, cos_table);
	
	parameter theta_width = 10;
	parameter output_width = 8;
	parameter minusSin = 0;
	parameter minusCos	= 0;
	parameter symmetric = 0;


	parameter tablesize = 1 << theta_width;
	parameter pi = 3.14159265358979323846;
	parameter scale = 1 << (output_width - symmetric - 1);
	parameter delta_angle = 2.0*pi/tablesize;
	
	input [theta_width-1 : 0] theta;
	output [output_width-1 : 0] sin_table;
	output [output_width-1 :0 ] cos_table;
	reg [output_width-1 : 0] sin_table;
	reg [output_width-1 :0 ] cos_table;
	real angle;
	reg [output_width-1 :0] sin_array[0:tablesize-1];
	reg [output_width-1 :0] cos_array[0:tablesize-1];
	integer i;
	integer sin_int, cos_int;
	real sincosTemp;
	real scaleReal;
	
	initial
		begin
			scaleReal = scale;
			if (output_width==32 && symmetric==0)
				scaleReal = -scaleReal;
			angle = 0.0;
			for (i=0; i<tablesize; i=i+1)
				begin 
					sincosTemp = scaleReal * sin($realtobits(angle));
					sin_int = sincosTemp;
					if (sincosTemp>=0)
						begin
							if (minusSin==0)
								begin
									if (output_width==32 && symmetric==0)
										begin
											if (sin_int<0)
												sin_int = scale-1;
										end
									else
										if (sin_int==scale && symmetric==0)
											sin_int = sin_int-1;
								end
							else
								sin_int = -sincosTemp;
						end
					else
						begin
							if (minusSin==1)
								begin
									sin_int = -sincosTemp;
									if (output_width==32 && symmetric==0)
										begin
											if (sin_int<0)
												sin_int = scale-1;
										end
									else
										if (sin_int==scale && symmetric==0)
											sin_int = sin_int-1;
								end
						end
					sin_array[i] = sin_int;
					
					sincosTemp = scaleReal * cos($realtobits(angle));
					cos_int = sincosTemp;
					if (sincosTemp>=0)
						begin
							if (minusCos==0)
								begin
									if (output_width==32 && symmetric==0)
										begin
											if (cos_int<0)
												cos_int = scale-1;
										end
									else
										if (cos_int==scale && symmetric==0)
											cos_int = cos_int-1;
								end
							else
								cos_int = -sincosTemp;
						end
					else
						begin
							if (minusCos==1)
								begin
									cos_int = -sincosTemp;
									if (output_width==32 && symmetric==0)
										begin
											if (cos_int<0)
												cos_int = scale-1;
										end
									else
										if (cos_int==scale && symmetric==0)
											cos_int = cos_int-1;
								end
						end
					cos_array[i] = cos_int;
					angle = angle + delta_angle;
				end
		end
	
	always @(theta)
		begin
			sin_table <= sin_array[theta];
			cos_table <= cos_array[theta];
		end
	
	
	// Functions ****************************************
	
	function real sin;
		input [63:0] vector;
		
		real term, sum, theta;
		integer n, loop;
		
		begin
			theta = $bitstoreal(vector);
			term = theta;
			sum = theta;
			n = 1;
			
			for (loop=0; loop < 100; loop = loop + 1)
				begin
					n = n + 2;
					term = -term*theta*theta/((n-1)*n);
					sum = sum + term;
				end
			sin = sum;
		end
	endfunction
	
	function real cos;
		input [63:0] vector;
		
		real term, sum, theta;
		integer n, loop;
		
		begin
			term = 1.0;
			sum = 1.0;
			n = 0;
			theta = $bitstoreal(vector);
			
			for (loop=0; loop < 100; loop = loop + 1)
				begin
					n = n + 2;
					term = (-term)*theta*theta/((n-1)*n);
					sum = sum + term;
				end
			cos = sum;
		end
	endfunction
	
endmodule
