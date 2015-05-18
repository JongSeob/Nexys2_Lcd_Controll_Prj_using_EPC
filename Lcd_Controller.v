`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 윤종섭 
// 
// Create Date:    14:14:06 05/13/2015 
// Design Name: 
// Module Name:    Lcd_Controller 
// Project Name: 
// Target Devices: Nexys2
// Tool versions:  ISE Navigator 14.7
// Description:    외부로부터 nCS, nWR, nRD, RS 신호를 받아서
//						 RW, EN 신호를 LCD 타이밍에 맞게 보내준다.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lcd_Controller#(
	parameter stIdle 			  = 4'b0000,
				 stRead			  = 4'b0001,
				 stWrite			  = 4'b0010,
				 stTwoDelay		  = 4'b0011,
				 stSetEn			  = 4'b0100,
				 stElevenDelay	  = 4'b0101,
				 stClearEn		  = 4'b0110,
				 stCheckBusy	  = 4'b0111,
				 stWaitBusyClear = 4'b1000
)
(
	input clk,
	input rst,
	
	input nCS,
	input nWR,
	input nRD,
	
	input busy,	
	input  i_RS, // 외부에서 Data mode, Control mode 여부를 알려주는 역할
	output reg o_RS, // Busy Flag를 확인하기 위해서 LCD장치로 보내는 신호.
	output reg RW,
	output reg EN,
	
	output reg RDY
    );
	 
	
	reg [3:0] stCur  = stIdle;
	reg [3:0] stNext = stIdle;
	
	reg [5:0] count = 0;
		
	// FSM //
	always @(posedge clk, posedge rst) begin
		if(rst == 1)
			stCur <= stIdle;
		else
			stCur <= stNext;		
	end
	
	always @(posedge clk) begin // 9개의 상태 = 180ns
		case(stCur)
			stIdle 			 : begin	
										o_RS <= i_RS;
																				
										if(nCS == 0 && nWR == 0)	// LCD 쓰기동작
											stNext <= stWrite;
											
										if(nCS == 0 && nRD == 0)	// LCD 읽기동작
											stNext <= stRead;
											
								  end
								  
			stRead			 : begin
										RW  <= 1;
										
										if(i_RS == 1)
											stNext <= stTwoDelay;
										else begin	// RS가 0일때의 Read 동작은 실행시간이 0이므로 바로 EN 신호를 1로 올린다.
											EN   <= 1;
											stNext <= stIdle;
										end
								  end
								  
			stWrite 			 : begin 
										RW <= 0;
										stNext <= stTwoDelay; 
								  end 
								  
			stTwoDelay 		 : if(count == 1) 
										stNext <= stSetEn;
										
			stSetEn 			 : begin 
										EN <= 1; 
										stNext <= stElevenDelay; 	  		 
								  end
								  
			stElevenDelay 	 : if(count == 10) 
										stNext <= stClearEn;
										
			stClearEn 		 : begin 
										EN  <= 0;
										RDY <= 0;	// Busy Flag가 0으로 떨어지기 전까지 RDY신호를 0으로 떨어뜨려 EPC가 기다리게 만든다.
										stNext <= stCheckBusy;             		 
								  end
								  
			stCheckBusy     : begin
										EN   <= 1;
										o_RS <= 0;
										RW   <= 1;
										stNext <= stWaitBusyClear;
								  end
								  
			stWaitBusyClear : begin
										if(busy == 1)
											stNext <= stWaitBusyClear;
										else begin
											RDY <= 1;
											stNext <= stIdle;											
										end
								  end
								  
			default			: stNext <= stIdle;
			
		endcase	
	end
	
	always @(posedge clk, posedge rst) begin
		if(rst == 1)
			count <= 0;
		else begin
			if(stCur == stTwoDelay || stCur == stElevenDelay)
				count <= count + 1;
			else
				count <= 0;
		end
	end

endmodule
