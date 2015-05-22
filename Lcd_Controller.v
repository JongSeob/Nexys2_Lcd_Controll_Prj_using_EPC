`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ������ 
// 
// Create Date:    14:14:06 05/13/2015 
// Design Name: 
// Module Name:    Lcd_Controller 
// Project Name: 
// Target Devices: Nexys2
// Tool versions:  ISE Navigator 14.7
// Description:    �ܺηκ��� nCS, nWR, nRD, RS ��ȣ�� �޾Ƽ�
//						 RW, EN ��ȣ�� LCD Ÿ�ֿ̹� �°� �����ش�.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lcd_Controller#(
	parameter stIdle 			  = 3'b0000,
				 stRead			  = 3'b0001,
				 stWrite			  = 3'b0010,
				 stTwoDelay		  = 3'b0011,
				 stSetEn			  = 3'b0100,
				 stElevenDelay	  = 3'b0101,
				 stClearEn		  = 3'b0110
)
(
	input clk,
	input rst,
	
	input nCS,
	input nWR,
	input nRD,
	
	input      RS, // �ܺο��� Data mode, Control mode ���θ� �˷��ִ� ����
	output reg RW,
	output reg EN,
	
	output reg RDY
    );
	 
	
	reg [2:0] stCur  = stIdle;
	reg [2:0] stNext = stIdle;
	
	reg [5:0] count = 0;
	
	initial begin
		stCur  = stIdle;
		stNext = stIdle;
		
		count = 0;
		RDY = 1;
	end
		
	always @(posedge clk, posedge rst) begin
		if(rst == 1)
			stCur <= stIdle;
		else
			stCur <= stNext;		
	end
	
	always @(posedge clk) begin // 9���� ���� = 180ns
		case(stCur)
			stIdle 			 : begin	
			
										if(nCS == 0 && nWR == 0)	// LCD ���⵿��
										begin
											RDY <= 0;
											stNext <= stWrite;
										end
											
										if(nCS == 0 && nRD == 0)	// LCD �б⵿��
										begin
											RDY <= 0;
											stNext <= stRead;
										end
											
								  end
								  
			stRead			 : begin
										RW  <= 1;
										
										if(RS == 1)
											stNext <= stTwoDelay;
										else begin	// RS�� 0�϶��� Read ������ ����ð��� 0�̹Ƿ� �ٷ� EN ��ȣ�� 1�� �ø���.
											EN   <= 1;
											RDY  <= 1;
											stNext <= stIdle;
										end
								  end
								  
			stWrite 			 : begin 
										RW <= 0;
										stNext <= stTwoDelay; 
								  end 
								  
			stTwoDelay 		 : if(count == 2) 
										stNext <= stSetEn;
										
			stSetEn 			 : begin 
										EN <= 1; 
										stNext <= stElevenDelay; 	  		 
								  end
								  
			stElevenDelay 	 : if(count == 11) 
										stNext <= stClearEn;
										
			stClearEn 		 : begin 
										EN  <= 0;
										RDY <= 1;
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
