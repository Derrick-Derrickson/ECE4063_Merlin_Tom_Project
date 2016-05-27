//This is the Historgram File
//This module generates and stores a hiso and cum histo for the input data


module Histo(
					iPclk,iY_Cont,iX_Cont,
					Dval,Fval,
					Grey,
					Gr_Out_His1,Gr_Out_His2,Gr_Out_Cum1,Gr_Out_Cum2,
					stateOut,
					threshOut,
					threshState);

					//define inputs and outputs
input iPclk, Dval, Fval;
input [15:0] iY_Cont, iX_Cont;
input [11:0] Grey;
input [1:0] threshState;

output [17:0] stateOut;
output reg [15:0] Gr_Out_His1, Gr_Out_His2;
output reg [15:0] Gr_Out_Cum1, Gr_Out_Cum2;

output [7:0] threshOut;

//define wires

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

wire [1:0] addVal;

//define registers

reg [19:0] holding;
reg [11:0] addrHolding;
reg [11:0] addrHolding2;
reg [11:0] addrHolding3;
reg [11:0] addrHolding4;
reg [11:0] addrHolding5;

reg [7:0] redVal;
reg redFound;

reg DvalHolding;
reg DvalHolding2;
reg DvalHolding3;

reg [2:0] state;
reg [8:0] PixCount;
reg [19:0] CumVal;
reg [19:0] PrevVal;


//initalise SRAM value storing

//Ram for storing the Temp histogram
SRAM HisRam(
	.clock(iPclk),
	.data(SRAM_D_In),
	.rdaddress(SRAM_R_Addr_In),
	.wraddress(SRAM_W_Addr_In),
	.wren(SRAM_Wen),
	.q(SRAM_Q_Out));
	
	//Ram for holding the standard histogram
SRAM DispRam(
	.clock(iPclk),
	.data(DISP_SRAM_D_In),
	.rdaddress(DISP_SRAM_R_Addr_In),
	.wraddress(DISP_SRAM_W_Addr_In),
	.wren(DISP_SRAM_Wen),
	.q(DISP_SRAM_Q_Out));
	
	//Ram for storing the CumHisogram
SRAM HDispRam(
	.clock(iPclk),
	.data(CUM_SRAM_D_In),
	.rdaddress(CUM_SRAM_R_Addr_In),
	.wraddress(CUM_SRAM_W_Addr_In),
	.wren(CUM_SRAM_Wen),
	.q(CUM_SRAM_Q_Out));

	
	//always loop to trigger on the edge of the input clock
always@ (posedge iPclk) begin

	//this is part of State 0
	if(Fval) begin
	//ensure that state and PixCount are 0 when we transfer out of Fval code
	state <= 0;
	PixCount <= 0;
			addrHolding <= {4'b0000,Grey[11:4]};
	//This line looks back to see if any of the previous greyscale values are the same
	//if they are it adds one for each histo values it will miss when it reads the values out of SRAM
	//this ensures we do not miss any histo values
	holding <= SRAM_Q_Out+20'b00000000000000000001+((addrHolding2==addrHolding3)?1:0)+((addrHolding2==addrHolding4)?1:0)+((addrHolding2==addrHolding5)?1:0);
	DvalHolding <= Dval;
	end
	
	
	
	else begin
	
		case (state)
		
		0: begin // stay in state 0 for 3 more clock ticks
		PixCount <= PixCount + 1;
		if(PixCount >= 3) begin
		state <= 1;
		PixCount <= 0;
		end
		end
		
		1:	begin //Clear the Memory
				PixCount <= PixCount + 1;
				if(PixCount >= 300) begin
					state <= 2;
					PixCount <= 0;
					redFound <=0;
					redVal <=0;
				end
			end
		2: begin //Copy the DISPLAY HISTOGRAM and CALC the CUM
			
				PixCount <= PixCount + 1;
				CumVal = PrevVal+SRAM_Q_Out;
				PrevVal = CumVal;
				holding <= SRAM_Q_Out;
				addrHolding <= PixCount;
				
				//figure out if the value is our redVal
				if(CumVal > 192000 && ~redFound) begin
					redFound <=1;
					redVal <= PixCount;
				end
				//move to the next state when we are done (overflow into 0's (does not matter))
				if(PixCount >= 300) begin
					state <= 3;
					PixCount <= 0;
					CumVal = 0;
					PrevVal = 0;
			
				end
			end
		3: begin	//CLEAR THE NORMAL HISTOGRAM
				PixCount <= PixCount + 1;
			end
		default: state <= 0;
	endcase
	end
	
	//shift the address holding registers back one each
	addrHolding5 <= addrHolding4;
	addrHolding4 <= addrHolding3;
	addrHolding3 <= addrHolding2;
	addrHolding2 <= addrHolding;
	//shift the Dval holding registers one bac
	DvalHolding3 <= DvalHolding2;
	DvalHolding2 <= DvalHolding;

	
		//draw the red line on either hito screens
		if((iY_Cont[7:0] == redVal)&(iY_Cont< 256)) begin
			Gr_Out_His1 <= 16'b0;
			Gr_Out_His2 <= 16'b0000001111111111;
			Gr_Out_Cum1 <= 16'b0;
			Gr_Out_Cum2 <= 16'b0000001111111111;
		end
		
		else begin
		//decice if the pixel should be white, the graph is scaled down by 2^4 = 16
		if((DISP_SRAM_Q_Out>>4 > ((iX_Cont)))&(iY_Cont< 256)) begin 
		

		Gr_Out_His1 <= 16'b1111111111111111;
		Gr_Out_His2 <= 16'b1111111111111111;

		end
		else begin 
		Gr_Out_His1 <= 16'b0;
		Gr_Out_His2 <= 16'b0;
		end
		//decide if the pixel should be white, the graph is scaled down by a factor of 2^9 =512
		if((CUM_SRAM_Q_Out>>9 > (iX_Cont))&(iY_Cont<256)) begin 

		Gr_Out_Cum1 <= 16'b1111111111111111;//16'b1111111111111111;
		Gr_Out_Cum2 <= 16'b1111111111111111;
		end
		else begin 
		Gr_Out_Cum1 <= 16'b0;
		Gr_Out_Cum2 <= 16'b0;
		end
		end
	
end

//This section multiplexes the Read address, Write address, D in values, and Write enable lines for SRAM modules
assign SRAM_R_Addr_In[11:0] =				state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/PixCount[7:0] : 	/*0*/{4'b0000,Grey[11:4]});
assign SRAM_D_In[19:0] = 					state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/	0:holding[19:0]		 	/*0*/);
assign SRAM_W_Addr_In[11:0] = 			state[0]?(state[1]? /*3*/PixCount[7:0] : /*1*/0) 	:(state[1]? /*2*/ 0:		 		/*0*/addrHolding3);
assign SRAM_Wen = 							state[0]?(state[1]? /*3*/1 : /*1*/0) 			:(state[1]? /*2*/ 0:				/*0*/DvalHolding3);

assign DISP_SRAM_R_Addr_In[11:0] = 		state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/0:			 	/*0*/{4'b0000,iY_Cont[7:0]});
assign DISP_SRAM_D_In[19:0] = 			state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/holding[19:0]:  /*0*/0);
assign DISP_SRAM_W_Addr_In[11:0] = 		state[0]?(state[1]? /*3*/0 : /*1*/PixCount[7:0]) 	:(state[1]? /*2*/addrHolding3: 	/*0*/0);
assign DISP_SRAM_Wen = 						state[0]?(state[1]? /*3*/0 : /*1*/1) 			:(state[1]? /*2*/1: 				/*0*/0);


assign CUM_SRAM_R_Addr_In[11:0] = 		state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/0: 				/*0*/{4'b0000,iY_Cont[7:0]});
assign CUM_SRAM_D_In[19:0] = 				state[0]?(state[1]? /*3*/0 : /*1*/0) 			:(state[1]? /*2*/CumVal[19:0]: 		/*0*/0);
assign CUM_SRAM_W_Addr_In[11:0] = 		state[0]?(state[1]? /*3*/0 : /*1*/PixCount[7:0]) 	:(state[1]? /*2*/addrHolding3: 	/*0*/0);
assign CUM_SRAM_Wen = 						state[0]?(state[1]? /*3*/0 : /*1*/1) 			:(state[1]? /*2*/1: 				/*0*/0);

//debuging output
assign threshOut = redVal;
//debuging state output
assign stateOut = SRAM_Q_Out[19:2];

endmodule