`timescale 1ns / 1ps

module top #(
	parameter LCD_DATA_ADDR		= 6'b0000_00, // 0x00
				 LCD_CONTROL_ADDR = 6'b0001_00, // 0x04
	
	parameter UART_DATA_ADDR   = 6'b0010_00, // 0x08
				 UART_STATUS_ADDR = 6'b0011_00  // 0x0C
)
(
	input			 clk,					// 50 MHz input
	input  [7:0] sw,					// Slide switch
	input  [0:0] btn,					// reset
	output [7:0] Led,			// LED
	output 		 TXD,					// RS232 out
	input 		 RXD,					// RS232 in
	inout  [7:0] JA,					// LCD Data
	output [6:4] JB,					// JB[4] = RS, JB[5] = R/W#, JB[6] = EN
	
	output [6:0] seg,
	output 		 dp,
	output [3:0] an
	);
	
	// Microblaze�� rx,tx�� �ƹ��͵� �������� ������ Implement Design �� ������ �߻��ؼ� �߰�
	wire dummy_rx;
	wire dummy_tx;
	
	// ************* 7-Segment  *************//
	
	reg [15:0] Digit = 16'hABCD; // 7-Segment ���� ���� ����
	
	reg [15:0] Digit_Data = 0;  // EPC�� ����� �����͸� ����.
	reg [15:0] Digit_Addr = 0;  // EPC���� ��µ� �ּҸ� ����.
	reg [15:0] Digit_Sig  = 0;  // LCD��Ʈ�ѿ� �̿�Ǵ� ��� ��ȣ�� ����.(nCS,nWR .... RS,RW)
	
	
	// ************** EPC ��ȣ *********************** //
	
	wire	EPC_nCS;		// EPC���� �����ϴ� CS��ȣ. Active Low
	wire	[5:0] Addr;	// A5A4A3A2A1A0. EPC�� ���.
	wire	nRD;			// Read.  active low. EPC�� ���.
	wire	nWR;			// Write. active low. EPC�� ���.
	wire 	BE;			// Byte Enable. Active High. EPC�� ����� 1����Ʈ�̱� ������ ū �ǹ� ����.
	wire	nBE;			// Byte Enable. Active Low. EPC�� ����� �޾� �ؼ��� �����Ͽ� ����ϱ�� �Ѵ�.
	wire  EPC_Rdy;

	wire	[7:0] BlazeDataOut; 
	reg	[7:0] BlazeDataIn; 

	assign nBE = ~BE;
	
	
	// *********** Lcd Controller Signal. ******************* //
	
	reg  RS;			// RS == 1, LCD Data mode.	   Addr = 6'b0000_00
						// RS == 0, LCD Control mode  Addr = 6'b0001_00
	
	wire RW;			// RW == 1, Read mode
						// RW == 0, Write mode
	
	wire EN;			// EN��  1 -> 0 ���� �������� �� RS,RW,Data ���� Ȯ���ؼ� �Ѱ��� ������ �Ѵ�.
	
	wire LCD_nCS;  // LCD�� ������ Chip Select ��ȣ.
	wire LCD_RDY;	// LCD�� RDY ��ȣ.
	
	// ***************** UART Signal **********************//
	
	wire Uart_nCS;
	wire UART_RDY;
	
	wire [7:0] Uart_Status;
	wire [7:0] ReceivedData;
	
	// Lcd Operation
	
	// nWR, nRD�� Falling Edge ������ ���� wire
	wire fallingRW = nWR & nRD;
	
	always @(negedge fallingRW) begin
		if(fallingRW == 0) begin
			if(Addr == LCD_DATA_ADDR)
				RS <= 1;
			else if(Addr == LCD_CONTROL_ADDR)
				RS <= 0;
		end
	end
	
	assign LCD_nCS = ( (EPC_nCS == 0) && ((Addr == LCD_DATA_ADDR) || (Addr == LCD_CONTROL_ADDR)) ) ? 0 : 1;

	
	// Uart Operation
	
	assign Uart_nCS = ( (EPC_nCS == 0) && (Addr == UART_DATA_ADDR) ) ? 0 : 1;
	
	
	// ******** ������, ��ȣ���� 7-Segment�� Ȯ���ϱ����� �ڵ�� *************** //
	
	always @(posedge nWR) begin
		Digit_Data[7:0] <= BlazeDataOut[7:0]; // Blaze�� Output
	end
	
	always @(posedge nRD) begin
		Digit_Data[15:8] <= JA[7:0]; // Blaze�� Input
	end
	
	always @(negedge fallingRW) begin
		Digit_Addr[15:0] <= {10'b0000000000, Addr[5:0]};  // Blaze�� ���� ���� �ּ� 6��Ʈ
	end
	
	always @(negedge EN) begin				
		Digit_Sig[15:0]  <= {7'b0000000, EPC_nCS, nWR, nRD, EPC_Rdy, 	  // LCD�� ���õ� ��� ��ȣ
									LCD_nCS, RS, RW, EN, LCD_RDY};				  		
	end
		
	always @(posedge clk) begin
		case(sw)
		8'b10000000 : Digit <= Digit_Data;
		8'b01000000 : Digit <= Digit_Addr;
		8'b00100000 : Digit <= Digit_Sig;		
		default     : Digit <= 16'hABCD;
		
		endcase
	end
	
	// ******************************************************************** //
	
	
	// Data from peripheral to Blaze Operation
	
	always @(posedge clk) begin
		if(EPC_nCS == 0)
			case(Addr)
				LCD_CONTROL_ADDR : BlazeDataIn <= JA[7:0];
				LCD_DATA_ADDR    : BlazeDataIn <= JA[7:0];
				UART_STATUS_ADDR : BlazeDataIn <= Uart_Status[7:0];
				UART_DATA_ADDR   : BlazeDataIn <= ReceivedData[7:0];
			endcase
	end
	
	// 3-state buffer among LCD and Blaze
	assign JA = (nWR == 0) ? BlazeDataOut[7:0] : 8'bz; // Blaze_EPC -> LCD
	
	assign JB[4] = RS;
	assign JB[5] = RW;
	assign JB[6] = EN;
	
	assign EPC_Rdy = LCD_RDY & UART_RDY; 
	
	// Instantiate the MicroBlaze & RS232 module
	(* BOX_TYPE = "user_black_box" *)
	blaze blaze (
		 .fpga_0_RS232_RX_pin						(dummy_rx), 
		 .fpga_0_RS232_TX_pin						(dummy_tx), 
		 .fpga_0_clk_1_sys_clk_pin					(clk), 
		 .fpga_0_rst_1_sys_rst_pin					(btn[0]),
		 .fpga_0_DIP_Switches_GPIO_IO_I_pin		(sw),
//		 .fpga_0_LEDS_GPIO_IO_O_pin				(Led),
		 .xps_epc_0_PRH_CS_n_pin					(EPC_nCS),					
		 .xps_epc_0_PRH_Addr_pin					(Addr),
		 .xps_epc_0_PRH_Rd_n_pin					(nRD),
		 .xps_epc_0_PRH_Wr_n_pin					(nWR),
		 .xps_epc_0_PRH_Rdy_pin						(EPC_Rdy),
		 .xps_epc_0_PRH_Data_I_pin					(BlazeDataIn),		// �Է����� �����͹���
		 .xps_epc_0_PRH_Data_O_pin					(BlazeDataOut),	// ��� ���� ������ ����
		 .xps_epc_0_PRH_BE_pin						(BE)
		 );
	
	Lcd_Controller Lcd_Controller(
		 .clk			(clk), 
		 .rst			(btn[0]), 
		 .nCS			(LCD_nCS), 
		 .nWR			(nWR), 
		 .nRD			(nRD), 
		 .RS			(RS), 
		 .RW			(RW), 
		 .EN			(EN),
		 .RDY			(LCD_RDY)
    );
	 
	uart uart (
		 .clk					(clk), 
		 .iBtnSwitch		(sw), 
		 .TxD					(TXD), 
		 .RxD					(RXD), 
		 .nCS					(Uart_nCS), 
		 .nWR					(nWR), 
		 .nRD					(nRD), 
		 .SendData			(BlazeDataOut), 
		 .ReceivedData		(ReceivedData),
		 .Status				(Uart_Status),
		 .RDY					(UART_RDY)
    );
	
	 SevenSegment SevenSegment (
		 .i_clk					(clk), 
		 .i_Digit				(Digit), 
		 .i_Seg_DP_Switch		(4'b1111), 
		 .o_ControlLed			(an), 
		 .o_SegA					(seg[0]), 
		 .o_SegB					(seg[1]), 
		 .o_SegC					(seg[2]), 
		 .o_SegD					(seg[3]), 
		 .o_SegE					(seg[4]), 
		 .o_SegF					(seg[5]), 
		 .o_SegG					(seg[6]), 
		 .o_Seg_DP				(dp)
    );
	
	 
	 

endmodule

