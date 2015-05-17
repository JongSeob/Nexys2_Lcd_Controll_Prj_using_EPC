`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:14:54 03/27/2015 
// Design Name: 
// Module Name:    SevenSegment 
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
module SevenSegment(
	input 		 i_clk,
	input [15:0] i_Digit,
	input  [3:0] i_Seg_DP_Switch,
	
	output reg [3:0] o_ControlLed,
	
	output o_SegA,
	output o_SegB,
	output o_SegC,	
	output o_SegD,
	output o_SegE,
	output o_SegF,	
	output o_SegG,	
	output o_Seg_DP 
   );
	
	wire DownClk;
	wire [6:0] Display;
	
	reg [1:0] TmpCnt = 2'b00;
	reg [3:0] Value = 4'h0;
	
	// DownClk가 1/4 분주 된다.
	always @(posedge DownClk)
	begin
		case(TmpCnt)
			0 :	begin o_ControlLed <= 4'b1110; 	TmpCnt <= TmpCnt + 1; Value <= i_Digit;  end
			1 :	begin o_ControlLed <= 4'b1101;	TmpCnt <= TmpCnt + 1; Value <= (i_Digit>>4) ; end
			2 :	begin o_ControlLed <= 4'b1011;	TmpCnt <= TmpCnt + 1; Value <= (i_Digit>>8) ; end
			3 :	begin o_ControlLed <= 4'b0111;	TmpCnt <= TmpCnt + 1; Value <= (i_Digit>>12); end
		endcase
	end
	
	// 7 세그먼트 디코더의 예시화. 4비트 입력을 받아 7 세그먼트에 출력할 값을 출력한다.
	SegmentDecoder SegmentDecoder(Display, Value);
	
	// 분주기
	CounterRefresh divide_Clk_50Mhz_To_240hz(DownClk, i_clk);	// input = 50MHz. output=60Hz*4
	
	// 디코딩된 결과 Display를 각 Seg에 보낸다.
	assign	o_SegA = Display[6];
	assign	o_SegB = Display[5];
	assign	o_SegC = Display[4];
	assign	o_SegD = Display[3];
	assign	o_SegE = Display[2];
	assign	o_SegF = Display[1];
	assign	o_SegG = Display[0];
	
	assign	o_Seg_DP = (TmpCnt == 0) ? i_Seg_DP_Switch[3] :
							  (TmpCnt == 1) ? i_Seg_DP_Switch[0] :
							  (TmpCnt == 2) ? i_Seg_DP_Switch[1] :
							  (TmpCnt == 3) ? i_Seg_DP_Switch[2] : 1;

endmodule

// 7세그먼트 디코더
// input : Data. 1개의 세그먼트 장치에 출력할 4비트 값
// output : Dsiplay. 입력된 4비트 값에 맞는 문자를 출력하기 위한 7 세그먼트의 각 LED를 구동하는 출력
module	SegmentDecoder(Display, Data );
	output	reg [6:0] Display;
	input		[3:0] Data;
	
	//								  abc defg	
	parameter	BLANK		= 7'b111_1111;
	parameter	ZERO		= 7'b000_0001;
	parameter	ONE		= 7'b100_1111;
	parameter	TWO		= 7'b001_0010;
	parameter	THREE		= 7'b000_0110;
	parameter	FOUR		= 7'b100_1100;
	parameter	FIVE		= 7'b010_0100;
	parameter	SIX		= 7'b010_0000;
	parameter	SEVEN		= 7'b000_1111;
	parameter	EIGHT		= 7'b000_0000;
	parameter	NINE		= 7'b000_0100;
	parameter	TEN 		= 7'b000_1000;
	parameter	ELEVEN	= 7'b110_0000;
	parameter	TWELVE	= 7'b011_0001;
	parameter	THIRTEEN	= 7'b100_0010;
	parameter	FOURTEEN	= 7'b011_0000;	
	parameter	FIFTEEN	= 7'b011_1000;	

	always @(Data)
		case (Data)
			0:	Display = ZERO;
			1:	Display = ONE;
			2:	Display = TWO;
			3:	Display = THREE;
			4: Display = FOUR;
			5:	Display = FIVE;
			6:	Display = SIX;
			7:	Display = SEVEN;
			8:	Display = EIGHT;
			9:	Display = NINE;
			10:Display = TEN;
			11:Display = ELEVEN;
			12:Display = TWELVE;
			13:Display = THIRTEEN;
			14:Display = FOURTEEN;
			15:Display = FIFTEEN;
			default:	Display = BLANK;	// use when you want to display just upto 9
		endcase		
endmodule

// FPGA에 유입되는 clk(50Mhz)의 입력을 받아 7 세그먼트의 애노드 전류 공급을 제어하는 클록(OutClk)을 만들어 낸다.
// 입력 : clk(50Mhz 고정)
// 출력 : OutClk. 7 세그먼트의 애노드 전류 공급을 제어한다. 탑 모듈에서 이를 기반으로 애노드 제어 신호를 생성한다.
//       (DESIRED_FREQ * 4) * 2 = 50 * 10^6 / x. =====> 4 digit를 순차적으로 점,소등해야 하므로 *4, 
//			본 설계는 정해진 수 만큼의 클록이 들어올 때까지는 출력을 변화시키지 않다가 일정한 수의 클록이 들어오면 출력의 상태를 토글링하는 방식으로 클럭을 분주한다. 
//			1개의 클록 주기는 2개의 정, 부 출력을 모아야 하므로 *2
module	CounterRefresh(OutClk, InClk );
	input		InClk;
	output	reg OutClk;
	reg	[19:0]	q;
	parameter DESIRED_FREQ = 60*4;	// 60Hz for each digit. 45Hz 이하이면 flickering 관찰된다고 함.
	initial	begin q <=0; OutClk<=0; end
	always @(posedge InClk)
		//if(q > ( 50*10^6 /(DESIRED_FREQ*2) ))	// *주의 : 동작안됨.  ^ 지수승 지원 안함. ^는 xor 연산자.
		// if(q > ( 50.0*10.0 * 1000.0 * 1000.0 /(DESIRED_FREQ*2) ))  // 너무 큰 수라서 연산이 안됨.
		 if(q > 20'h196e6) 	// =6104166=(50*10^6 /(DESIRED_FREQ*2)). DESIRED_FREQ=60*4; No Flickering.
		//if(q > 20'h2625a) 	// =156250=(50*10^6 /(DESIRED_FREQ*2)). DESIRED_FREQ=40*4; No Flickering.
		// if(q > 20'h32dcd) 	// =208333=(50*10^6 /(DESIRED_FREQ*2)). DESIRED_FREQ=30*4; Obvious Flickering.
		//if(q > 20'h98968) 	// =625000=(50*10^6 /(DESIRED_FREQ*2)). DESIRED_FREQ=10*4; Severe Flickering.
			begin	OutClk <= ~OutClk; q <= 20'h00000; end
		else
			begin q <= q +1; end
endmodule
