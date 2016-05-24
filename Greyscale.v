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
	assign grey = (2989 * ired_input + 5870 * igreen_input + 1140 * iblue_input)/10000;

	assign odata_out1 = {grey[11:7],grey[11:2]};
	assign odata_out2 = {grey[6:2],grey[11:2]};
	
	always @(posedge iclk) begin
	
	 ogrey_checkd1<=grey;
	 oGVALd <= id_val;
	
	end
				
endmodule