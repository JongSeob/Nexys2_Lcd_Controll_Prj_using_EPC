`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 	
// Create Date:    17:13:43 05/26/2015 
// Design Name: 
// Module Name:    bcd_counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//		
// Dependencies: 
//		
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//		
//////////////////////////////////////////////////////////////////////////////////
module bcd_counter(
	input clk,
	input rst,
	input en,
	output [15:0] Digit	
    );
		
	reg [14:0] counter;
		
	wire clk_1mhz;
		
	reg counter_flag = 0;
		
	always @(en) begin
		if(en == 1)
			counter_flag = 1;
		else
			counter_flag = 0;
	end
		
		
	always @(posedge clk_1mhz, posedge rst) begin
		if(rst == 1)
			counter <= 0;
		else begin
			if(counter_flag == 1)
				count <= (count == 16'h5959) ? 0 : count + 1;
			else
				count <= count;
		end
	end
		
	always @(posedge clk) begin
		Digit[15:12] <= count / 1000; 
		Digit[11:8]  <= (  count - ((count / 1000)*1000)  ) / 100;
		Digit[7:4]	 <= (count - (  ((count - ((count / 1000)*1000)) / 100) * 100  )  ) / 10 ;
		Digit[3:0]	 <= (count - ((( count - (((count - ((count / 1000)*1000)) / 100)*100)  )  / 10)*10) ) ;
	end
		
	Frequency_Divider #(.TARGET_FREQUENCY(1000000)) Frequency_Divider (
		 .Inclk		(clk), 
		 .Outclk		(clk_1mhz)
    );
		
		
endmodule
