`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Seokyong University
// Engineer: Jin Heon Kim
// 
// Create Date: May. 5, 2015 
// Design Name: GPIO design using the EPC module
// Required IP : GPIO LED, GPIO switch, UART lite, and EPC
// 설계의 목적
//		Micro Blaze에 EPC를 장착하여 EPC(External Peripheral Controller)를 통해 FPGA 내부에 정의된 register 들에 대한 쓰기/읽기 동작을 확인한다.
//		EPC는 	Micro Blaze의 PLB 버스를 사용하기 편한 범용 버스로 변환해주는 일종의 bus bridge라고 할 수 있다.
// 설계의 내용
// ISE 내에서는 32비트*8개의 R/W 레지스터를 설계하였다.
// 쓰기 동작에서 32비트의 Digital Data Output 장치들이 32비트, 16비트, 8비트 단위로 개별 동작하도록 설계되었다.
// 읽을 때도 8/16/32 비트 단위로 읽어 내는 것이 가능하다.
//		- 단, 정렬되지 않은(unaligned) 액세스 동작에서는 오동작한다. MB는 당초 이러한 비정렬동작에서는 exception을 발생하여 이를 교정하는 것으로 설계되어 있으나 현재 이 익셉션에 대비한 서비스 루틴이 마련되어 있지 않다. 
//      SDK 예제. Test 3 참조.
// Data BUS interface buffer모듈을 설계하여 3상태를 지원하는 양방향 데이터 버스를 접속 가능하게 하였다.
// nCs 신호 발생의 정확성을 높이기 위해 4바이트 레지스터 * 8개 =32 바이트의 영역만 XPS에서 설정하였다.
//////////////////////////////////////////////////////////////////////////////////
// 아래는 실험과정의 오류 정정 역사를 기록한 것으로 단순 기록용이므로 무시하여도 됩니다.
// nWR 신호에 대한 데이터 holding time을 넉넉히 잡지 않으면 0번지의 일부 데이터에서 쓰기 동작 오류 발견. C_PRH0_DATA_TH를 20ns->40ns로 상향 조정하여 해결하였다.
// => 개발 초기에 있었던 위 nWR 신호 holding time 문제는 BlazeDataT를 활용함으로써 해결하였다.
// nWR을 이용해 DataBuffer의 데이터버스 방향을 통제하는 것은 충분한 데이터 홀드 타임을 지원할 수 없는 것으로 판단된다.
//////////////////////////////////////////////////////////////////////////////////
// 개선할 점 : 3상태버퍼 사용을 자제하여야 할 듯. =>이 버전에서 수정. 정상 작동함을 확인하였다.
// 현재 소스는 3상태 신호를 활용하였으나 FPAG에서는 최종 입출력단에서만 3상태 버퍼를 지원하겠다고 하였다.
// 현재 경고 오류를 보면 3상태 버퍼는 다음과 같이 pull-up을 이용한 open-collector로 설계된 것으로 추정된다.
// 32 internal tristates are replaced by logic (pull-up yes):
// BufInOut<0>, BufInOut<10>, BufInOut<11>, BufInOut<12>, BufInOut<13>, BufInOut<14>,
// BufInOut<15>, BufInOut<16>, BufInOut<17>, BufInOut<18>, BufInOut<19>, BufInOut<1>, 
// BufInOut<20>, BufInOut<21>, BufInOut<22>, BufInOut<23>, BufInOut<24>, BufInOut<25>, 
// BufInOut<26>, BufInOut<27>, BufInOut<28>, BufInOut<29>, BufInOut<2>, BufInOut<30>,
// BufInOut<31>, BufInOut<3>, BufInOut<4>, BufInOut<5>, BufInOut<6>, BufInOut<7>, BufInOut<8>, BufInOut<9>.
//////////////////////////////////////////////////////////////////////////////////
// 수정 사항 : 3상태 버퍼를 사용하지 않고 2개의 입출력 데이터 버스를 그대로 활용하였다.
// 설계는 오히려 간편한 장점이 있다.
//////////////////////////////////////////////////////////////////////////////////


module top(
	input			 clk,					// 50 MHz input
	input  [7:0] sw,					// Slide switch
	input  [0:0] btn,					// reset
	output [7:0] Led,					// LED
	output 		 TXD,					// RS232 out
	input 		 RXD,					// RS232 in
	inout  [7:0] JA,					// LCD Data
	output [6:4] JB					// JB[4] = RS, JB[5] = R/W#, JB[6] = EN
	);
	

	// Signals of External Peripheral Controller. EPC가 MicroBlaze의 출력을 받아 외부 장치에 전달.
	wire	nCS;			// Chip Select. active low. EPC의 출력.			
	wire	[5:0] Addr;	// A5A4A3A2A1A0. EPC의 출력.
	wire	nRD;			// Read. active low. EPC의 출력.
	wire	nWR;			// Write. active low. EPC의 출력.
	wire 	[3:0] BE;		// Byte Enable. Active High. EPC의 출력. 4바이트 중 어떤 바이트가 액세스 되는지 알림. BE[0]가 MSB. 
	wire	[3:0] nBE;		// Byte Enable. Active Low. EPC의 출력을 받아 극성을 반전하여 사용하기로 한다.
	
	assign	nBE = ~BE;
	assign	RDY = 1;

	
	reg	[31:0] RegisterDDO_0 = 32'h00000000;	// 출력장치. Dital Data Output Register
	reg	[31:0] RegisterDDO_1 = 32'h00000000;	// 출력장치. Dital Data Output Register
	reg	[31:0] RegisterDDO_2 = 32'h00000000;	// 출력장치. Dital Data Output Register
	reg	[31:0] RegisterDDO_3 = 32'h00000000;	// 출력장치. Dital Data Output Register
	reg	[31:0] RegisterDDO_4 = 32'h00000000;	// 출력장치. Dital Data Output Register
	reg	[31:0] RegisterDDO_5 = 32'h00000000;	// 출력장치. Dital Data Output Register
	reg	[31:0] RegisterDDO_6 = 32'h00000000;	// 출력장치. Dital Data Output Register
	reg	[31:0] RegisterDDO_7 = 32'h00000000;	// 본 예제에서 7번 레지스터는 실제로는 저장 기능이 없다.
		
	wire	[31:0] BlazeDataOut; 
	reg	[31:0] BlazeDataIn; 
	wire	[31:0] BusData;
	
	// Lcd Controller Signal. R/W, EN 신호는 JB[5],JB[6]에 직접 연결.
	wire Data_T;	// Data_T == 0, Blaze -> LCD 데이터 전달.
						// Data_T == 1, LCD -> Blaze 데이터 전달.
	wire RS;			// RS == 1, LCD Data mode.	   Addr = 6'b1000_00
						// RS == 0, LCD Control mode  Addr = 6'b1001_00
	
	assign RS = (Addr[5:2] == 4'b1000) ? 1 :
					(Addr[5:2] == 4'b1001) ? 0 : 1'bx;
	
	assign JB[4] = RS;	
	assign JA = (Data_T == 0) ? BlazeDataOut[7:0] : 8'bz;

	
	// 7번 레지스터는 다양한 신호선을 관찰하는 용도로 사용할 수 있다. 여기서는 하위 16비트에는 Led와 스위치 상태를 읽도록 하였다.
	// * 실습 차원에서 다양한 H/W 신호를 레지스터 읽기 동작을 통해 관찰할 수 있다.
	// 예 : BE, ncs, 주소신호 A0, A1, A2, A3 등의 신호를 관찰하라.
	assign	BusData = (nCS == 0 && Addr[5:2] == 4'b0111 && nRD==0)? {RegisterDDO_7[31:24], {Led[3:0],Addr[4:0]}, {nCS, nRD, nWR,nBE}, sw} : 32'hzzzzzzzz;		// register 7. 



/////////////////////////////////////////////////////////////////////////////////////
// 레지스터 읽기 동작에 대비한 동작 기술
/////////////////////////////////////////////////////////////////////////////////////

	always @(negedge nRD) begin
	
		if(nCS == 0 && nBE[3] == 0 ) begin	
			case(Addr[5:2])
			4'b0000 :
				BlazeDataIn[31:24] <= RegisterDDO_0[31:24];
			4'b0001 :
				BlazeDataIn[31:24] <= RegisterDDO_1[31:24];
			4'b0010 :
				BlazeDataIn[31:24] <= RegisterDDO_2[31:24];
			4'b0011 :
				BlazeDataIn[31:24] <= RegisterDDO_3[31:24];
			4'b0100 :
				BlazeDataIn[31:24] <= RegisterDDO_4[31:24];
			4'b0101 :
				BlazeDataIn[31:24] <= RegisterDDO_5[31:24];
			4'b0110 :
				BlazeDataIn[31:24] <= RegisterDDO_6[31:24];
			4'b0111 :
				BlazeDataIn[31:24] <= BusData[31:24];
			endcase	
		end	

		if(nCS == 0 && nBE[2] == 0 ) begin	
			case(Addr[5:2])
			4'b0000 :
				BlazeDataIn[23:16] <= RegisterDDO_0[23:16];
			4'b0001 :
				BlazeDataIn[23:16] <= RegisterDDO_1[23:16];
			4'b0010 :
				BlazeDataIn[23:16] <= RegisterDDO_2[23:16];
			4'b0011 :
				BlazeDataIn[23:16] <= RegisterDDO_3[23:16];
			4'b0100 :
				BlazeDataIn[23:16] <= RegisterDDO_4[23:16];
			4'b0101 :
				BlazeDataIn[23:16] <= RegisterDDO_5[23:16];
			4'b0110 :
				BlazeDataIn[23:16] <= RegisterDDO_6[23:16];
			4'b0111 :
				BlazeDataIn[23:16] <= BusData[23:16];
			endcase	
		end	

		if(nCS == 0 && nBE[1] == 0 ) begin	
			case(Addr[5:2])
			4'b0000 :
				BlazeDataIn[15:8] <= RegisterDDO_0[15:8];
			4'b0001 :
				BlazeDataIn[15:8] <= RegisterDDO_1[15:8];
			4'b0010 :
				BlazeDataIn[15:8] <= RegisterDDO_2[15:8];
			4'b0011 :
				BlazeDataIn[15:8] <= RegisterDDO_3[15:8];
			4'b0100 :
				BlazeDataIn[15:8] <= RegisterDDO_4[15:8];
			4'b0101 :
				BlazeDataIn[15:8] <= RegisterDDO_5[15:8];
			4'b0110 :
				BlazeDataIn[15:8] <= RegisterDDO_6[15:8];
			4'b0111 :
				BlazeDataIn[15:8] <= BusData[15:8];
			endcase	
		end	
		
		
		if(nCS == 0 && nBE[0] == 0 ) begin		
			case(Addr[5:2])
			4'b0000 :
				BlazeDataIn[7:0] <= RegisterDDO_0[7:0];
			4'b0001 :
				BlazeDataIn[7:0] <= RegisterDDO_1[7:0];
			4'b0010 :
				BlazeDataIn[7:0] <= RegisterDDO_2[7:0];
			4'b0011 :
				BlazeDataIn[7:0] <= RegisterDDO_3[7:0];
			4'b0100 :
				BlazeDataIn[7:0] <= RegisterDDO_4[7:0];
			4'b0101 :
				BlazeDataIn[7:0] <= RegisterDDO_5[7:0];
			4'b0110 :
				BlazeDataIn[7:0] <= RegisterDDO_6[7:0];
			4'b0111 :
				BlazeDataIn[7:0] <= BusData[7:0];
			4'b1000 : if(Data_T == 1)					//LCD Data Mode
							BlazeDataIn[7:0] <= JA;				
			4'b1001 : if(Data_T == 1)					//LCD Control Mode
							BlazeDataIn[7:0] <= JA;			
			endcase	
		end	

	end

/////////////////////////////////////////////////////////////////////////////////////
// 레지스터 쓰기 동작에 대비한 동작 기술
/////////////////////////////////////////////////////////////////////////////////////
	always @(posedge nWR) begin
	
		if(nCS == 0 && nBE[3] == 0 ) begin	
			case(Addr[5:2])
			4'b0000 :
				RegisterDDO_0[31:24] <= BlazeDataOut[31:24];
			4'b0001 :
				RegisterDDO_1[31:24] <= BlazeDataOut[31:24];	
			4'b0010 :
				RegisterDDO_2[31:24] <= BlazeDataOut[31:24];
			4'b0011 :
				RegisterDDO_3[31:24] <= BlazeDataOut[31:24];
			4'b0100 :
				RegisterDDO_4[31:24] <= BlazeDataOut[31:24];
			4'b0101 :
				RegisterDDO_5[31:24] <= BlazeDataOut[31:24];
			4'b0110 :
				RegisterDDO_6[31:24] <= BlazeDataOut[31:24];			
			4'b0111 :
				RegisterDDO_7[31:24] <= BlazeDataOut[31:24];
			endcase	
		end	

		if(nCS == 0 && nBE[2] == 0 ) begin	
			case(Addr[5:2])
			4'b0000 :
				RegisterDDO_0[23:16] <= BlazeDataOut[23:16];
			4'b0001 :
				RegisterDDO_1[23:16] <= BlazeDataOut[23:16];	
			4'b0010 :
				RegisterDDO_2[23:16] <= BlazeDataOut[23:16];
			4'b0011 :
				RegisterDDO_3[23:16] <= BlazeDataOut[23:16];
			4'b0100 :
				RegisterDDO_4[23:16] <= BlazeDataOut[23:16];
			4'b0101 :
				RegisterDDO_5[23:16] <= BlazeDataOut[23:16];
			4'b0110 :
				RegisterDDO_6[23:16] <= BlazeDataOut[23:16];			
			4'b0111 :
				RegisterDDO_7[23:16] <= BlazeDataOut[23:16];
			endcase	
		end	

		if(nCS == 0 && nBE[1] == 0 ) begin	
			case(Addr[5:2])
			4'b0000 :
				RegisterDDO_0[15:8] <= BlazeDataOut[15:8];
			4'b0001 :
				RegisterDDO_1[15:8] <= BlazeDataOut[15:8];	
			4'b0010 :
				RegisterDDO_2[15:8] <= BlazeDataOut[15:8];
			4'b0011 :
				RegisterDDO_3[15:8] <= BlazeDataOut[15:8];
			4'b0100 :
				RegisterDDO_4[15:8] <= BlazeDataOut[15:8];
			4'b0101 :
				RegisterDDO_5[15:8] <= BlazeDataOut[15:8];
			4'b0110 :
				RegisterDDO_6[15:8] <= BlazeDataOut[15:8];			
			4'b0111 :
				RegisterDDO_7[15:8] <= BlazeDataOut[15:8];
			endcase	
		end	
		
		
		if(nCS == 0 && nBE[0] == 0 ) begin	
			case(Addr[5:2])
			4'b0000 :
				RegisterDDO_0[7:0] <= BlazeDataOut[7:0];
			4'b0001 :
				RegisterDDO_1[7:0] <= BlazeDataOut[7:0];	
			4'b0010 :
				RegisterDDO_2[7:0] <= BlazeDataOut[7:0];
			4'b0011 :
				RegisterDDO_3[7:0] <= BlazeDataOut[7:0];
			4'b0100 :
				RegisterDDO_4[7:0] <= BlazeDataOut[7:0];
			4'b0101 :
				RegisterDDO_5[7:0] <= BlazeDataOut[7:0];
			4'b0110 :
				RegisterDDO_6[7:0] <= BlazeDataOut[7:0];			
			4'b0111 :
				RegisterDDO_7[7:0] <= BlazeDataOut[7:0];
			endcase	
		end	

	end

	// Instantiate the MicroBlaze & RS232 module
	(* BOX_TYPE = "user_black_box" *)
	blaze blaze (
		 .fpga_0_RS232_RX_pin(RXD), 
		 .fpga_0_RS232_TX_pin(TXD), 
		 .fpga_0_clk_1_sys_clk_pin(clk), 
		 .fpga_0_rst_1_sys_rst_pin(btn[0]),
		 .fpga_0_DIP_Switches_GPIO_IO_I_pin(sw),
		 .fpga_0_LEDS_GPIO_IO_O_pin(Led),
		 .xps_epc_0_PRH_CS_n_pin(nCS),					// 4바이트 레지스터 * 8개 = 32 바이트 영역.
		 .xps_epc_0_PRH_Addr_pin(Addr),
		 .xps_epc_0_PRH_Rd_n_pin(nRD),
		 .xps_epc_0_PRH_Wr_n_pin(nWR),
		 .xps_epc_0_PRH_Rdy_pin(RDY),
		 .xps_epc_0_PRH_Data_I_pin(BlazeDataIn),		// 입력전용 데이터버스
		 .xps_epc_0_PRH_Data_O_pin(BlazeDataOut),		// 출력 전용 데이터 버스
		 .xps_epc_0_PRH_BE_pin(BE)
		 );
		 
	
	
	Lcd_Controller Lcd_Controller(
		 .clk			(clk), 
		 .rst			(btn[0]), 
		 .nCS			(nCS), 
		 .nWR			(nWR), 
		 .nRD			(nRD), 
		 .Data_T		(Data_T), 
		 .RS			(RS), 
		 .RW			(JB[5]), 
		 .EN			(JB[6])
    );
	 
endmodule

