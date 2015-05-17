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
	parameter stIdle 			 = 3'b000,
				 stRead			 = 3'b001,
				 stWrite			 = 3'b010,
				 stTwoDelay		 = 3'b011,
				 stSetEn			 = 3'b100,
				 stElevenDelay	 = 3'b101,
				 stClearEn		 = 3'b110
)
(
	input clk,
	input rst,
	
	input nCS,
	input nWR,
	input nRD,
	
	input  RS,
	output reg RW,
	output reg EN	
    );
	 
	
	reg [2:0] stCur  = stIdle;
	reg [2:0] stNext = stIdle;
	
	reg [5:0] count = 0;
		
	// FSM //
	always @(posedge clk, posedge rst) begin
		if(rst == 1)
			stCur <= stIdle;
		else
			stCur <= stNext;		
	end
	
	always @(posedge clk) begin
		case(stCur)
			stIdle 			: begin										
										if(nCS == 0 && nWR == 0)	// LCD 쓰기동작
											stNext <= stWrite;
										if(nCS == 0 && nRD == 0)	// LCD 읽기동작
											stNext <= stRead;
								  end
								  
			stRead			: begin
										RW 	 <= 1;
										
										if(RS == 1)
											stNext <= stTwoDelay;
										else begin	// RS가 0일때의 Read 동작은 실행시간이 0이므로 바로 EN 신호를 1로 올린다.
											EN <= 1;
											stNext <= stIdle;
										end
								  end
								  
			stWrite 			: begin 
										RW <= 0; 
										stNext <= stTwoDelay; 
								  end 
								  
			stTwoDelay 		: if(count == 1) 
										stNext <= stSetEn;
										
			stSetEn 			: begin 
										EN <= 1; 
										stNext <= stElevenDelay; 	  		 
								  end
								  
			stElevenDelay 	: if(count == 10) 
										stNext <= stClearEn;
										
			stClearEn 		: begin 
										EN <= 0; 
										stNext <= stIdle;             		 
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
