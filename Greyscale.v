///this module converts RGB values into greyscale
//this module also syncs the output by storing it with a register, to meet timing requiremnts for our histogram file.
//Most of this file is taken from the testbench example.

//the only thing new is the way grey is calculated, and the delayed (Registered) values. 

module Greyscale (iclk, 
							ired_input, igreen_input, iblue_input, 
							ix_pos, iy_pos, 
							if_val, id_val,
							odata_out1, odata_out2,
							ogrey_checkd1, oGVALd);

	function integer clog2;
	  input integer value;
	  begin
		 value = value-1;
		 for (clog2=0; value>0; clog2=clog2+1)
			value = value>>1;
	  end
	endfunction
	
	//define default paramters
	parameter num_rows =32;
	parameter num_cols =32;
	parameter full_frame_rows =36;
	parameter full_frame_cols =36;
	parameter num_bits_rgb = 12;
	parameter output_width = 16;
	
	input iclk, if_val, id_val;
	input	[num_bits_rgb-1:0] ired_input, igreen_input, iblue_input;
	input	[clog2(num_rows)-1:0]  ix_pos;
	input	[clog2(num_cols)-1:0]  iy_pos;
	
	output [output_width-1:0] odata_out1, odata_out2;
	output reg [num_bits_rgb-1:0] ogrey_checkd1;
	output reg oGVALd;

	wire [num_bits_rgb-1:0] grey;
	//special maths to go wayyyy faster
	assign grey = ((3 * ired_input + 6 * igreen_input + 1 * iblue_input)*205)>>11;

	assign odata_out1 = {grey[11:7],grey[11:2]};
	assign odata_out2 = {grey[6:2],grey[11:2]};
	
	//sync the new grey values with the clock.
	always @(posedge iclk) begin
	
	 ogrey_checkd1<=grey;
	 oGVALd <= id_val;
	
	end
				
endmodule