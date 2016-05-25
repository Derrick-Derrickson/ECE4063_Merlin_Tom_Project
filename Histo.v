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
					iPclk,iY_Cont,iX_Cont,
					Dval,Fval,
					Grey,
					Gr_Out_His1,Gr_Out_His2,Gr_Out_Cum1,Gr_Out_Cum2,
					stateOut);

input iPclk, Dval, Fval;
input [15:0] iY_Cont, iX_Cont;
input [11:0] Grey;

output [1:0] stateOut;
output reg [15:0] Gr_Out_His1, Gr_Out_His2;
output reg [15:0] Gr_Out_Cum1, Gr_Out_Cum2;

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
reg [11:0] addrHolding2;
reg [11:0] addrHolding3;

reg DvalHolding;
reg DvalHolding2;
reg DvalHolding3;

reg [2:0] state;
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
		
		0: begin
		PixCount <= PixCount + 1;
		if(PixCount >= 3) begin
		state <= 1;
		PixCount <= 0;
		end
		end
		
		1:	begin //Clear the Memory
				PixCount <= PixCount + 1;
				if(PixCount >= 255) begin
					state <= 2;
					PixCount <= 0;
				end
			end
		2: begin //Copy the DISPLAY HISTOGRAM and CALC the CUM
			
				PixCount <= PixCount + 1;
				CumVal <= SRAM_Q_Out + CumVal;
				
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
	addrHolding3 <= addrHolding2;
	addrHolding2 <= addrHolding;
	addrHolding <= Grey;
	holding <= SRAM_Q_Out+1;
	
	DvalHolding3 <= DvalHolding2;
	DvalHolding2 <= DvalHolding;
	DvalHolding <= Dval;
	
	
	
	//if (iY_Cont < 255) begin
		if((DISP_SRAM_Q_Out >= (iX_Cont)) && (iY_Cont < 255) ) begin 
		Gr_Out_His1 <= 16'b1111111111111111;
		Gr_Out_His2 <= 16'b1111111111111111;
		end
		else begin 
		Gr_Out_His1 <= 16'b0;
		Gr_Out_His2 <= 16'b0;
		end
	
		if((CUM_SRAM_Q_Out >= iX_Cont)&& (iY_Cont < 255)) begin 
		Gr_Out_Cum1 <= 16'b1111111111111111;//16'b1111111111111111;
		Gr_Out_Cum2 <= 16'b1111111111111111;
		end
		else begin 
		Gr_Out_Cum1 <= 16'b0;
		Gr_Out_Cum2 <= 16'b0;
		end
//	end
//	else begin
//	Gr_Out_His1 <= 16'b0;
//	Gr_Out_His2 <= 16'b0;
//	Gr_Out_Cum1 <= 16'b0;
//	Gr_Out_Cum2 <= 16'b0;
//	end
	
end

assign SRAM_R_Addr_In[11:0] =				state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/PixCount : 	/*0*/Grey);
assign SRAM_D_In[19:0] = 					state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/	0:			 	/*0*/holding);
assign SRAM_W_Addr_In[11:0] = 			state[0]?(state[1]? /*3*/PixCount : /*1*/0) 	:(state[1]? /*2*/ 0:		 		/*0*/addrHolding3);
assign SRAM_Wen = 							state[0]?(state[1]? /*3*/1 : /*1*/0) 			:(state[1]? /*2*/ 0:				/*0*/DvalHolding3);

assign DISP_SRAM_R_Addr_In[11:0] = 		state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/0:			 	/*0*/{4'b0000,iY_Cont[7:0]});
assign DISP_SRAM_D_In[19:0] = 			state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/SRAM_Q_Out:  /*0*/0);
assign DISP_SRAM_W_Addr_In[11:0] = 		state[0]?(state[1]? /*3*/0 : /*1*/PixCount) 	:(state[1]? /*2*/PixCount: 	/*0*/0);
assign DISP_SRAM_Wen = 						state[0]?(state[1]? /*3*/0 : /*1*/1) 			:(state[1]? /*2*/1: 				/*0*/0);


assign CUM_SRAM_R_Addr_In[11:0] = 		state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/0: 				/*0*/{4'b0000,iY_Cont[7:0]});
assign CUM_SRAM_D_In[19:0] = 				state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/CumVal: 		/*0*/0);
assign CUM_SRAM_W_Addr_In[11:0] = 		state[0]?(state[1]? /*3*/0 : /*1*/PixCount) 	:(state[1]? /*2*/PixCount: 	/*0*/0);
assign CUM_SRAM_Wen = 						state[0]?(state[1]? /*3*/0 : /*1*/1) 			:(state[1]? /*2*/1: 				/*0*/0);


assign stateOut = state;

endmodule