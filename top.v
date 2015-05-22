`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Seokyong University
// Engineer: Jin Heon Kim
// 
// Create Date: May. 5, 2015 
// Design Name: GPIO design using the EPC module
// Required IP : GPIO LED, GPIO switch, UART lite, and EPC
// ������ ����
//		Micro Blaze�� EPC�� �����Ͽ� EPC(External Peripheral Controller)�� ���� FPGA ���ο� ���ǵ� register �鿡 ���� ����/�б� ������ Ȯ���Ѵ�.
//		EPC�� 	Micro Blaze�� PLB ������ ����ϱ� ���� ���� ������ ��ȯ���ִ� ������ bus bridge��� �� �� �ִ�.
// ������ ����
// ISE �������� 32��Ʈ*8���� R/W �������͸� �����Ͽ���.
// ���� ���ۿ��� 32��Ʈ�� Digital Data Output ��ġ���� 32��Ʈ, 16��Ʈ, 8��Ʈ ������ ���� �����ϵ��� ����Ǿ���.
// ���� ���� 8/16/32 ��Ʈ ������ �о� ���� ���� �����ϴ�.
//		- ��, ���ĵ��� ����(unaligned) �׼��� ���ۿ����� �������Ѵ�. MB�� ���� �̷��� �����ĵ��ۿ����� exception�� �߻��Ͽ� �̸� �����ϴ� ������ ����Ǿ� ������ ���� �� �ͼ��ǿ� ����� ���� ��ƾ�� ���õǾ� ���� �ʴ�. 
//      SDK ����. Test 3 ����.
// Data BUS interface buffer����� �����Ͽ� 3���¸� �����ϴ� ����� ������ ������ ���� �����ϰ� �Ͽ���.
// nCs ��ȣ �߻��� ��Ȯ���� ���̱� ���� 4����Ʈ �������� * 8�� =32 ����Ʈ�� ������ XPS���� �����Ͽ���.
//////////////////////////////////////////////////////////////////////////////////
// �Ʒ��� ��������� ���� ���� ���縦 ����� ������ �ܼ� ��Ͽ��̹Ƿ� �����Ͽ��� �˴ϴ�.
// nWR ��ȣ�� ���� ������ holding time�� �˳��� ���� ������ 0������ �Ϻ� �����Ϳ��� ���� ���� ���� �߰�. C_PRH0_DATA_TH�� 20ns->40ns�� ���� �����Ͽ� �ذ��Ͽ���.
// => ���� �ʱ⿡ �־��� �� nWR ��ȣ holding time ������ BlazeDataT�� Ȱ�������ν� �ذ��Ͽ���.
// nWR�� �̿��� DataBuffer�� �����͹��� ������ �����ϴ� ���� ����� ������ Ȧ�� Ÿ���� ������ �� ���� ������ �Ǵܵȴ�.
//////////////////////////////////////////////////////////////////////////////////
// ������ �� : 3���¹��� ����� �����Ͽ��� �� ��. =>�� �������� ����. ���� �۵����� Ȯ���Ͽ���.
// ���� �ҽ��� 3���� ��ȣ�� Ȱ���Ͽ����� FPAG������ ���� ����´ܿ����� 3���� ���۸� �����ϰڴٰ� �Ͽ���.
// ���� ��� ������ ���� 3���� ���۴� ������ ���� pull-up�� �̿��� open-collector�� ����� ������ �����ȴ�.
// 32 internal tristates are replaced by logic (pull-up yes):
// BufInOut<0>, BufInOut<10>, BufInOut<11>, BufInOut<12>, BufInOut<13>, BufInOut<14>,
// BufInOut<15>, BufInOut<16>, BufInOut<17>, BufInOut<18>, BufInOut<19>, BufInOut<1>, 
// BufInOut<20>, BufInOut<21>, BufInOut<22>, BufInOut<23>, BufInOut<24>, BufInOut<25>, 
// BufInOut<26>, BufInOut<27>, BufInOut<28>, BufInOut<29>, BufInOut<2>, BufInOut<30>,
// BufInOut<31>, BufInOut<3>, BufInOut<4>, BufInOut<5>, BufInOut<6>, BufInOut<7>, BufInOut<8>, BufInOut<9>.
//////////////////////////////////////////////////////////////////////////////////
// ���� ���� : 3���� ���۸� ������� �ʰ� 2���� ����� ������ ������ �״�� Ȱ���Ͽ���.
// ����� ������ ������ ������ �ִ�.
//////////////////////////////////////////////////////////////////////////////////


module top #(
	parameter LCD_DATA_ADDR		= 6'b100000, // 0x20
				 LCD_CONTROL_ADDR = 6'b100100, // 0x24
	
	parameter UART_DATA_ADDR   = 6'b000100, // 0x04
				 UART_STATUS_ADDR = 6'b001000  // 0x08
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
	
	reg [15:0] Digit = 16'hABCD;
	
	// ************** EPC ��ȣ *********************** //
	
	wire	EPC_nCS;		// EPC�� �����ϴ� CS��ȣ. Active Low
	wire	[5:0] Addr;	// A5A4A3A2A1A0. EPC�� ���.
	wire	nRD;			// Read. active low. EPC�� ���.
	wire	nWR;			// Write. active low. EPC�� ���.
	wire 	BE;			// Byte Enable. Active High. EPC�� ��� 1����Ʈ�̱� ������ ū �ǹ� ����.
	wire	nBE;			// Byte Enable. Active Low. EPC�� ����� �޾� �ؼ��� �����Ͽ� ����ϱ�� �Ѵ�.

	wire	[7:0] BlazeDataOut; 
	reg	[7:0] BlazeDataIn; 

	assign nBE = ~BE;
	
	
	// *********** Lcd Controller Signal. ******************* //
	
	reg  RS;			// RS == 1, LCD Data mode.	   Addr = 6'b1000_00
						// RS == 0, LCD Control mode  Addr = 6'b1001_00
	
	wire RW;			// RW == 1, Read mode
						// RW == 0, Write mode
	
	wire EN;			// EN��  1 -> 0 ���� �������� �� RS,RW,Data ���� Ȯ���ؼ� �Ѱ��� ������ �Ѵ�.
	
	wire LCD_nCS;  // LCD�� ������ Chip Select ��ȣ.
	wire LCD_RDY;	// LCD�� RDY ��ȣ.
	
	// ***************** UART Signal **********************//
	
	wire Uart_nCS;
	wire [7:0] Uart_Status;
	wire [7:0] ReceivedData;
	
	
	// Lcd Operation
	
	wire fallingRW = nWR & nRD;
	
	always @(posedge clk, negedge fallingRW) begin
		if(fallingRW == 0) begin
			if(Addr == LCD_DATA_ADDR)
				RS <= 1;
			else if(Addr == LCD_CONTROL_ADDR)
				RS <= 0;
		end
	end
	
	assign LCD_nCS = ( (EPC_nCS == 0) && ((Addr == LCD_DATA_ADDR) || (Addr == LCD_CONTROL_ADDR)) ) ? 0 : 1;

	assign JB[4] = RS;
	assign JB[5] = RW;
	assign JB[6] = EN;
	
	assign JA 			 = (nWR == 0) ? BlazeDataOut[7:0] : 8'bz; // Blaze_EPC -> LCD
	
	// Uart Operation
	
	assign Uart_nCS = ( (EPC_nCS == 0) && (Addr == UART_DATA_ADDR) ) ? 0 : 1;
	
	
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
	
	always @(negedge EN) begin // LCD�� Control�ϴ� ���
		if(Addr == LCD_CONTROL_ADDR && RW == 0)
		begin
			Digit[7:0] <= {BlazeDataOut};
		end
			
	end
								
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
		 .xps_epc_0_PRH_Rdy_pin						(LCD_RDY),
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
		 .oLed				(Led), 
		 .TxD					(TXD), 
		 .RxD					(RXD), 
		 .nCS					(Uart_nCS), 
		 .nWR					(nWR), 
		 .nRD					(nRD), 
		 .SendData			(BlazeDataOut), 
		 .Status				(Uart_Status),
		 .ReceivedData		(ReceivedData)
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

