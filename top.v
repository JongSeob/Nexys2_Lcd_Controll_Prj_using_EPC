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
	

	// Signals of External Peripheral Controller. EPC�� MicroBlaze�� ����� �޾� �ܺ� ��ġ�� ����.
	wire	nCS;			// Chip Select. active low. EPC�� ���.			
	wire	[5:0] Addr;	// A5A4A3A2A1A0. EPC�� ���.
	wire	nRD;			// Read. active low. EPC�� ���.
	wire	nWR;			// Write. active low. EPC�� ���.
	wire 	[3:0] BE;		// Byte Enable. Active High. EPC�� ���. 4����Ʈ �� � ����Ʈ�� �׼��� �Ǵ��� �˸�. BE[0]�� MSB. 
	wire	[3:0] nBE;		// Byte Enable. Active Low. EPC�� ����� �޾� �ؼ��� �����Ͽ� ����ϱ�� �Ѵ�.
	
	assign	nBE = ~BE;
	assign	RDY = 1;

	
	reg	[31:0] RegisterDDO_0 = 32'h00000000;	// �����ġ. Dital Data Output Register
	reg	[31:0] RegisterDDO_1 = 32'h00000000;	// �����ġ. Dital Data Output Register
	reg	[31:0] RegisterDDO_2 = 32'h00000000;	// �����ġ. Dital Data Output Register
	reg	[31:0] RegisterDDO_3 = 32'h00000000;	// �����ġ. Dital Data Output Register
	reg	[31:0] RegisterDDO_4 = 32'h00000000;	// �����ġ. Dital Data Output Register
	reg	[31:0] RegisterDDO_5 = 32'h00000000;	// �����ġ. Dital Data Output Register
	reg	[31:0] RegisterDDO_6 = 32'h00000000;	// �����ġ. Dital Data Output Register
	reg	[31:0] RegisterDDO_7 = 32'h00000000;	// �� �������� 7�� �������ʹ� �����δ� ���� ����� ����.
		
	wire	[31:0] BlazeDataOut; 
	reg	[31:0] BlazeDataIn; 
	wire	[31:0] BusData;
	
	// Lcd Controller Signal. R/W, EN ��ȣ�� JB[5],JB[6]�� ���� ����.
	wire Data_T;	// Data_T == 0, Blaze -> LCD ������ ����.
						// Data_T == 1, LCD -> Blaze ������ ����.
	wire RS;			// RS == 1, LCD Data mode.	   Addr = 6'b1000_00
						// RS == 0, LCD Control mode  Addr = 6'b1001_00
	
	assign RS = (Addr[5:2] == 4'b1000) ? 1 :
					(Addr[5:2] == 4'b1001) ? 0 : 1'bx;
	
	assign JB[4] = RS;	
	assign JA = (Data_T == 0) ? BlazeDataOut[7:0] : 8'bz;

	
	// 7�� �������ʹ� �پ��� ��ȣ���� �����ϴ� �뵵�� ����� �� �ִ�. ���⼭�� ���� 16��Ʈ���� Led�� ����ġ ���¸� �е��� �Ͽ���.
	// * �ǽ� �������� �پ��� H/W ��ȣ�� �������� �б� ������ ���� ������ �� �ִ�.
	// �� : BE, ncs, �ּҽ�ȣ A0, A1, A2, A3 ���� ��ȣ�� �����϶�.
	assign	BusData = (nCS == 0 && Addr[5:2] == 4'b0111 && nRD==0)? {RegisterDDO_7[31:24], {Led[3:0],Addr[4:0]}, {nCS, nRD, nWR,nBE}, sw} : 32'hzzzzzzzz;		// register 7. 



/////////////////////////////////////////////////////////////////////////////////////
// �������� �б� ���ۿ� ����� ���� ���
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
// �������� ���� ���ۿ� ����� ���� ���
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
		 .xps_epc_0_PRH_CS_n_pin(nCS),					// 4����Ʈ �������� * 8�� = 32 ����Ʈ ����.
		 .xps_epc_0_PRH_Addr_pin(Addr),
		 .xps_epc_0_PRH_Rd_n_pin(nRD),
		 .xps_epc_0_PRH_Wr_n_pin(nWR),
		 .xps_epc_0_PRH_Rdy_pin(RDY),
		 .xps_epc_0_PRH_Data_I_pin(BlazeDataIn),		// �Է����� �����͹���
		 .xps_epc_0_PRH_Data_O_pin(BlazeDataOut),		// ��� ���� ������ ����
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

