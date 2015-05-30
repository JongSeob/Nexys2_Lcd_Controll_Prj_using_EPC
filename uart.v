


`timescale 1ns / 1ps

module uart#(
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
	
	output TxD,
	input  RxD,
	
	input  nCS,
	input  nWR,
	input  nRD,
	
	// Blaze로부터 받아 전송시킬 데이터
	input  [7:0] SendData,
	
	// Blaze로 전송시킬 데이터
	output [7:0] ReceivedData,
	
	output [7:0] Status,
	output reg RDY
   );
	
	initial 
		RDY = 1;
	
	assign	RST = iBtnSwitch[0];

	///////////////////////////////////////////////////////////////////////////////////////////////////
	// Implementation of UART function 
	///////////////////////////////////////////////////////////////////////////////////////////////////
	reg  [7:0] dbInSig;		// Data Bus in.  UART의 입력. Blaze에서 보낸 데이터.
	wire [7:0] dbOutSig;		// Data Bus out. UART의 출력. PC에서 보내온 데이터를 읽어내는 포트. 
	reg  [7:0] dbOutLatch;	// UART의 출력을 저장할 공간. LED에 연결되어 출력 결과를 육안으로 확인 가능.
	
	wire 	rdaSig;				// Read Data Available : 수신 버퍼에 데이터가 들어왔음을 의미.
	wire 	tbeSig;				// Transmit Buffer Empty
	reg 	rdSig = 1;			// Read 신호
	reg 	wrSig = 0;			// Write 신호
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
				RECEIVE_0 : 
					begin 
						rdSig <= 0;	
						RDY   <= 1;
						stRcvNext <= RECEIVE_1; 
					end
				RECEIVE_1 : 
					begin 
						if (rdaSig == 1'b1) 
							begin		// Check if receive buffer is valid. Data is availabe if rdaSig=1. 
								dbOutLatch <= dbOutSig;	// Latch the read data
								FlagPatityError <= peSig;	
								FlagFrameError <= feSig;	
								FlagOverrunError <= oeSig;	
							end
						
						if(nCS == 0 && nRD == 0)
							stRcvNext <= RECEIVE_2;
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
						rdSig <= 1'b1;
						RDY	<= 0;		// Receive Buffer가 Flush될 때까지 UART동작 정지.
						
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
				default   : stRcvNext <= RECEIVE_0;
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
						if(nWR == 1) begin // 전송할 데이터가(SendData) 레지스터에(dbInSig) 저장될 때 까지 대기.
							stSendNext <= SEND_2;
							RDY <= 0;
						end
						else
							stSendNext <= SEND_1;
					end
				SEND_2 : 
					begin 
						wrSig <= 1'b1; 	// Input data of UART will be latched in the module.
						stSendNext <= SEND_3; 
					end
				SEND_3 : 
					begin 
						wrSig <= 0; 	// "wrSig" will be maintained for 2 clocks by deleting this line
						RDY <= 1;
						
						stSendNext <= SEND_0; 
					end
				default : begin stSendNext <= SEND_0; end
			endcase
		end
	end
	
	assign	Status[7] = FlagPatityError;				// Parity Error Flag
	assign	Status[6] = FlagFrameError;				// Frame Error Flag
	assign	Status[5] = FlagOverrunError;			// Overwrite Error Flag
	assign	Status[4] = rdSig;
	assign	Status[3] = wrSig;
	assign	Status[2] = RxD;
	assign	Status[1] = tbeSig;
	assign	Status[0] = rdaSig;
	
	assign   ReceivedData = dbOutLatch;

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
