//This is the Historgram File

//Inputs:
// Pixel Clock
// X and Y coords
// Dval
//	Fval
//	Grey

//Outputs:
//His_gry


module Histo(
input iPclk,
input [15:0] iY_cont,
input [15:0] iX_cont,
input	Dval,
input Fval,
input [7:0] Grey,
output reg [7:0] Gr_Out_His,
output reg [7:0] Gr_Out_Cum,
output [1:0] stateOut
);

wire [11:0] SRAM_W_Addr_In;
wire [19:0] SRAM_D_In;
wire [11:0] SRAM_R_Addr_In;
wire [19:0] SRAM_Q_Out;
wire SRAM_Wen;

wire [11:0] DISP_SRAM_W_Addr_In;
wire [19:0] DISP_SRAM_D_In;
wire [11:0] DISP_SRAM_R_Addr_In;
wire [19:0] DISP_SRAM_Q_Out;
wire DISP_SRAM_Wen;

wire [11:0] CUM_SRAM_W_Addr_In;
wire [19:0] CUM_SRAM_D_In;
wire [11:0] CUM_SRAM_R_Addr_In;
wire [19:0] CUM_SRAM_Q_Out;
wire CUM_SRAM_Wen;

reg [19:0] holding;
reg [11:0] addrHolding;
reg [2:0] state;
reg writeEnable;
reg [7:0] PixCount;
reg [19:0] CumVal;

SRAM HisRam(
	.clock(iPclk),
	.data(SRAM_D_In),
	.rdaddress(SRAM_R_Addr_In),
	.wraddress(SRAM_W_Addr_In),
	.wren(SRAM_Wen),
	.q(SRAM_Q_Out));
	
SRAM DispRam(
	.clock(iPclk),
	.data(DISP_SRAM_D_In),
	.rdaddress(DISP_SRAM_R_Addr_In),
	.wraddress(DISP_SRAM_W_Addr_In),
	.wren(DISP_SRAM_Wen),
	.q(DISP_SRAM_Q_Out));
	
SRAM HDispRam(
	.clock(iPclk),
	.data(CUM_SRAM_D_In),
	.rdaddress(CUM_SRAM_R_Addr_In),
	.wraddress(CUM_SRAM_W_Addr_In),
	.wren(CUM_SRAM_Wen),
	.q(CUM_SRAM_Q_Out));

	
always@ (posedge iPclk) begin

	if(Fval) begin
	state <= 0;
	PixCount <= 0;
	end
	else begin
	
		case (state)
		
		0: state <= 1;
		
		1:	begin //Clear the Memory
				PixCount <= PixCount + 1;
				if(PixCount >= 255) begin
					state <= 2;
					PixCount <= 0;
				end
			end
		2: begin //Copy the DISPLAY HISTOGRAM and CALC the CUM
				PixCount <= PixCount + 1;
				CumVal = SRAM_Q_Out + CumVal;
				if(PixCount >= 255) begin
					state <= 3;
					PixCount <= 0;
					CumVal <= 0;
				end
			end
		3: begin	//CLEAR THE NORMAL HISTOGRAM
				PixCount <= PixCount + 1;
			end
		default: state <= 3;
	endcase
	end
	
	
	addrHolding <= Grey;
	holding <= SRAM_Q_Out+1;
	
	
	Gr_Out_His <= (DISP_SRAM_Q_Out > iX_cont)?8'b11111111:8'b0;
	Gr_Out_Cum <= (CUM_SRAM_Q_Out > iX_cont)?8'b11111111:8'b0;
	
	
end
assign SRAM_R_Addr_In[11:0] =				state[0]?(state[1]? /*1*/0 : /*3*/0) 			:(state[1]? /*0*/ {4'b0000,Grey}: /*2*/PixCount);
assign SRAM_D_In[19:0] = 					state[0]?(state[1]? /*1*/0 : /*3*/0) 			:(state[1]? /*0*/holding :			 /*2*/0);
assign SRAM_W_Addr_In[11:0] = 			state[0]?(state[1]? /*1*/0 : /*3*/PixCount) 	:(state[1]? /*0*/addrHolding:		 /*2*/0);
assign SRAM_Wen = 							state[0]?(state[1]? /*1*/0 : /*3*/1) 			:(state[1]? /*0*/ 1:					 /*2*/0);

assign DISP_SRAM_R_Addr_In[11:0] = 		state[0]?(state[1]? /*1*/0 : /*3*/0) 			:(state[1]? /*0*/iY_cont[7:0]: /*2*/0);
assign DISP_SRAM_D_In[19:0] = 			state[0]?(state[1]? /*1*/0 : /*3*/0) 			:(state[1]? /*0*/0: /*2*/SRAM_Q_Out);
assign DISP_SRAM_W_Addr_In[11:0] = 		state[0]?(state[1]? /*1*/PixCount : /*3*/0) 	:(state[1]? /*0*/0: /*2*/PixCount);
assign DISP_SRAM_Wen = 						state[0]?(state[1]? /*1*/1 : /*3*/0) 			:(state[1]? /*0*/0: /*2*/1);


assign CUM_SRAM_R_Addr_In[11:0] = 		state[0]?(state[1]? /*1*/0 : /*3*/0) 			:(state[1]? /*0*/iY_cont[7:0]: /*2*/0);
assign CUM_SRAM_D_In[19:0] = 				state[0]?(state[1]? /*1*/0 : /*3*/0) 			:(state[1]? /*0*/0: /*2*/CumVal);
assign CUM_SRAM_W_Addr_In[11:0] = 		state[0]?(state[1]? /*1*/PixCount : /*3*/0) 	:(state[1]? /*0*/0: /*2*/PixCount);
assign CUM_SRAM_Wen = 						state[0]?(state[1]? /*1*/1 : /*3*/0) 			:(state[1]? /*0*/0: /*2*/1);


assign stateOut = state;

endmodule