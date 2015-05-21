/*
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
UART in VHDL ver. 2.0 
2015년 4월 15일. 서경대학교 김진헌.

1.기능 
	VHDL로 개발된 UART 모듈을 top 모듈에서 예시화하여 
	UART를 통해 전송된 데이터를 바로 echo back하여 전송하는 동작을 시행한다.
	전송된 문자는 7 세그먼트에 표시하고, UART 내부의 flag와 제어 신호의 상태를 LED로 표시한다.
	문자를 수신할 때 버퍼가 데이터가 들어왔는지를 rda로 점검하고 들어온 문자가 있으면 이를 데이터 버퍼에서 읽어내어 저장한 후 
	읽기 신호를 주어 읽었다는 신호를 UART에 송신 한 후 송신 동작에 들어간다.
	송신 버퍼에 쓰고 난 후 쓰기 신호를 발생하여 전송한다.
	
2. ver 1.0과 비교한 개선사항
	문자를 수신할 때 rdSig 신호를 발생후 rda 신호가 사라지는지 점검하였다. 이 동작을 수행하면서 혹 시간이 소요되는지 카운터에 저장하고 나중에 7 세그먼트에 출력할 수 있도록 하였다.
	문자를 송신할 때 tbe 신호를 점검하여 송신 버퍼가 비어 있는지 점검하였다.

3. 사용된 프로그램 모듈  
	1) RS232RefComp.vhd : UART를 구현한 모듈
	2) FourDigitsSevenSegmentDecoder.v : 7 segment 표시 장치를 구동하는 모듈
			
4. 작동법
	1) 터미널 에뮬레이터 설정 : 9600bps, 8 data bits, 1 stop bit, odd parity 
		// SPEC of VHDL module : 9600bps, 8 data bits, 1 stop bit, odd parity 

	2) 버튼 스위치 조작 
		button sw none : {1'b0,stNext} , {1'b0, stCur}, dbOutLatch }
					스위치를 누르지 않으면 7 세그먼트에는 {다음 상태 , 현재상태, 입력한 문자}를 출력한다.
		button sw 0 : reset
		button sw 1 : Overrun 오류가 발생한 회수를 7세그먼트에 표시
		button sw 2 : Parity 오류가 발생한 회수를 7세그먼트에 표시.
					터미널 에뮬레이터의 패리티 설정을 NONE으로 설정하고 회수를 살펴 볼 수 있다.
		button sw 3 : Frame 오류가 발생한 회수를 7세그먼트에 표시		
		button sw 3/2 : CounterReceived. 입력한 데이터의 개수를 7세그먼트에 표시
		button sw 2/1 : {CounterWait_rda, CounterWait_tbe}. 
					 UART의 상태를 나타내는 신호가 해제되고, 세트되는 동안 지연된 클록의 개수를 7세그먼트에 표시. 실제로는 0으로 출력되었다.
5. 특이사항	
	상태 머신의 클록을 posedge로 하면 데이터를 2번 수신한 것으로 오류가 나는 현상을 관찰하였다.
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/
module uart#(
	// 상태 머신 : 읽기 동작 3단계 + 쓰기 동작 3단계 
	parameter	RECEIVE_0 = 3'b000,
					RECEIVE_1 = 3'b001,
					RECEIVE_2 = 3'b010,
					RECEIVE_3 = 3'b011,
					RECEIVE_4 = 3'b100,

	parameter	SEND_0 = 3'b000,
					SEND_1 = 3'b001,
					SEND_2 = 3'b010,
					SEND_3 = 3'b011,
					SEND_4 = 3'b100
)
(
	input	       clk,				// 50 MHz input
	input  [3:0] iBtnSwitch,
	output [7:0] oLed,
	
	output TxD,
	input  RxD,
	
	input  nCS,
	input  nWR,
	input  nRD,
	
	// Blaze로부터 받아 전송시킬 데이터
	input  [7:0] SendData,
	
	output [7:0] Status,  // {rdaSig, tbeSig, stRcvCur, stSendCur} UART의 현재 상태를 반환.
	output [7:0] ReceivedData
   );
	
	assign	RST = iBtnSwitch[0];

	///////////////////////////////////////////////////////////////////////////////////////////////////
	// Implementation of UART function 
	///////////////////////////////////////////////////////////////////////////////////////////////////
	reg  [7:0] dbInSig = 8'h61;		// Data Bus in.  UART의 입력. Blaze에서 보낸 데이터.
	wire [7:0] dbOutSig;		// Data Bus out. UART의 출력. PC에서 보내온 데이터를 읽어내는 포트. 
	reg  [7:0] dbOutLatch;	// UART의 출력을 저장할 공간. LED에 연결되어 출력 결과를 육안으로 확인 가능.
	reg 	rdaSig;				// Read Data Available : 수신 버퍼에 데이터가 들어왔음을 의미.
	reg 	tbeSig;				// Transmit Buffer Empty
	reg 	rdSig=1;				// Read 신호
	reg 	wrSig=0;				// Write 신호
	wire 	peSig;				// Parity Error Flag
	wire 	feSig;				// Frame Error Flag
	wire 	oeSig;				// Overwrite Error Flag
	reg 	FlagPatityError;				// Parity Error Flag
	reg 	FlagFrameError;				// Frame Error Flag
	reg 	FlagOverrunError;				// Overwrite Error Flag
	reg	[15:0] CounterPE;				// Parity Error Counter
	reg 	[15:0] CounterFE;				// Frame Error Flag
	reg 	[15:0] CounterOE;				// Overwrite Error Flag
	reg	[15:0] CounterReceived;		// Number of data received	
	reg	[7:0]	CounterWait_rda;		// rda 신호가 없어지는데 걸린 시간	
	reg	[7:0]	CounterWait_tbe;		// tbe 신호가 설정되는데 걸린 시간	

	reg [2:0] stRcvCur , stRcvNext;
	reg [2:0] stSendCur, stSendNext;
	
	// Tx로 보낼 데이터 저장
	always @(posedge nWR) begin		
			dbInSig <= SendData;
	end

	// 수신문자의 개수를 세는 CounterReceived 카운터가 2개씩 증가하는 문제가 상태머신 negedge로 해결되었다.
	always @(negedge clk) begin		
		if(RST == 1) begin
			stRcvCur  <= RECEIVE_0;
			stSendCur <= SEND_0;
		end
		else begin
			stRcvCur  <= stRcvNext;
			stSendCur <= stSendNext;
		end
	end		

	always @(posedge clk) begin		
		if (RST == 1) begin
			CounterPE <= 16'h0000;				// Parity Error Counter
			CounterFE <= 16'h0000;				// Frame Error Flag
			CounterOE <= 16'h0000;				// Overwrite Error Flag
			CounterReceived <= 16'h0000;		// Number of data received
		end
		else begin
			case(stRcvCur)
				RECEIVE_0 : begin rdSig <= 0;	stRcvNext <= RECEIVE_1; end
				RECEIVE_1 : 
					begin 
						if (rdaSig == 1'b1) 
							begin		// Check if receive buffer is valid. Data is availabe if rdaSig=1. 
								dbOutLatch <= dbOutSig;	// Latch the read data
								FlagPatityError <= peSig;	
								FlagFrameError <= feSig;	
								FlagOverrunError <= oeSig;	
								
								if(nCS == 0 && nRD == 0)
									stRcvNext <= RECEIVE_2;
							end
						else
							stRcvNext <= RECEIVE_1;
					end	
				RECEIVE_2 :
					begin
						if(nRD == 1)
							stRcvNext <= RECEIVE_3;
						else
							stRcvNext <= RECEIVE_2;
					end
				RECEIVE_3 : 
					begin 					// Flush the receive Buffer.
						rdSig <= 1'b1;			// 이 신호를 UART로 보내도 VHDL UART가 rdaSig를 해제하는데 시간이 소요될 수 있다. 그래서 RECEIVE_3을 추가하였다.
						if ( FlagPatityError == 1 || FlagFrameError ==1 || FlagOverrunError) begin
							if (peSig == 1)	CounterPE <= CounterPE +1;
							if (feSig == 1)	CounterFE <= CounterFE +1;
							if (oeSig == 1)	CounterOE <= CounterOE +1;
						end
						else begin
							stRcvNext <= RECEIVE_4;
						end
					end
				RECEIVE_4 :		//wait until rdaSig is gone.
					begin
						if ( rdaSig == 1'b1)	
							begin
								CounterWait_rda <= CounterWait_rda +1;	
								stRcvNext <= RECEIVE_4; 
							end
						else	
							begin
								CounterReceived <= CounterReceived +1;		// 카운터가 2개씩 증가하는 문제가 상태머신 negedge로 해결되었다.									
								stRcvNext <= RECEIVE_0;
							end
					end	
			endcase

			case(stSendCur)
				SEND_0 : 
					begin
						if(nCS == 0 && nWR == 0)
							stSendNext <= SEND_1;
						else
							stSendNext <= SEND_0;
					end
				SEND_1 :
					begin
						if(nWR == 1)
							stSendNext <= SEND_2;
						else
							stSendNext <= SEND_1;
					end
				SEND_2 : 		// Echo back what has been received.
					begin 
						if(tbeSig == 1'b1) 		// Transmit Buffer Empty.
							stSendNext <= SEND_3;	
						else 	begin
							CounterWait_tbe <= CounterWait_tbe +1;
							stSendNext <= SEND_2;		// wait until transmit buffer empty
						end
					end
				SEND_3 : 
					begin 
						wrSig <= 1'b1; 	// Input data of UART will be latched in the module.
						stSendNext <= SEND_4; 
					end
				SEND_4 : 
					begin 
						wrSig <= 0; 	// "wrSig" will be maintained for 2 clocks by deleting this line
						
						stSendNext <= SEND_0; 
					end
				default : begin stSendNext <= SEND_0; end
			endcase
		end // else 의 end
	end // always 의 end


	// 오류 및 주요 제어 신호 상태 보이기
	assign	oLed[7] = FlagPatityError;				// Parity Error Flag
	assign	oLed[6] = FlagFrameError;				// Frame Error Flag
	assign	oLed[5] = FlagOverrunError;			// Overwrite Error Flag
	assign	oLed[4] = rdSig;
	assign	oLed[3] = wrSig;
	assign	oLed[2] = RxD;
	assign	oLed[1] = tbeSig;
	assign	oLed[0] = rdaSig;
	
	assign ReceivedData = dbOutLatch;
	assign Status = {rdaSig, tbeSig, stRcvCur, stSendCur};

	// VHDL 모듈을 예시화하여 구현한다.
	// SPEC of VHDL module : 9600bps, 8 data bits, 1 stop bit, odd parity 
	Rs232RefComp UART( 
							.RST(RST),					// Master Reset. Active High.  Input
							.CLK(clk),					// Master Clock. 50MHz. Input
							.TXD(TxD),					// Transmit Data. Output of UART
							.RXD(RxD),					// Receive Data. Input of UART
							// Dsta Input and Output
							.DBIN(dbInSig),			// Data Bus in.  Input
							.DBOUT(dbOutSig),			// Data Bus out. Output
							// Control pins for reading or writing 
							.RD(rdSig),					// Read Strobe.  Input. Active High. When it is high, receive buffer content is no longer valid.
							.WR(wrSig),					// Write Strobe.  Input. Active High.
							// Status bits
							.RDA(rdaSig),				// Read Data Available. Output. Active High.
							.TBE(tbeSig),				// Transmit Buffer Empty. Output. Active High. 
							// Error flags
							.PE(peSig),					// Parity Error Flag. Output. Active High.
							.FE(feSig),					// Frame Error Flag. Output. Active High. 
							.OE(oeSig));				// Overwrite Error Flag. Output. Active High.

endmodule
