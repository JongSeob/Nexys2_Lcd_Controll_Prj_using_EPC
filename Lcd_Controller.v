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
	input  i_RS, // �ܺο��� Data mode, Control mode ���θ� �˷��ִ� ����
	output reg o_RS, // Busy Flag�� Ȯ���ϱ� ���ؼ� LCD��ġ�� ������ ��ȣ.
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
	
	always @(posedge clk) begin // 9���� ���� = 180ns
		case(stCur)
			stIdle 			 : begin	
										o_RS <= i_RS;
																				
										if(nCS == 0 && nWR == 0)	// LCD ���⵿��
											stNext <= stWrite;
											
										if(nCS == 0 && nRD == 0)	// LCD �б⵿��
											stNext <= stRead;
											
								  end
								  
			stRead			 : begin
										RW  <= 1;
										
										if(i_RS == 1)
											stNext <= stTwoDelay;
										else begin	// RS�� 0�϶��� Read ������ ����ð��� 0�̹Ƿ� �ٷ� EN ��ȣ�� 1�� �ø���.
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
										RDY <= 0;	// Busy Flag�� 0���� �������� ������ RDY��ȣ�� 0���� ����߷� EPC�� ��ٸ��� �����.
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
