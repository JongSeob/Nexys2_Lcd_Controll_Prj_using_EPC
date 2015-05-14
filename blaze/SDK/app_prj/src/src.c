//*************************************************************************************
// EPC ����� �����Ͽ� GPIO �����ġ�� �� ���� �о�� �Է���ġ�� �׽�Ʈ�Ѵ�.
// 32��Ʈ�� Digital Data Output ��ġ���� 8��Ʈ ������ ���� �����ϵ��� ����Ǿ���.
//*************************************************************************************

#define	BASEADDRESS_LEDS	0x81400000
#define	BASEADDRESS_SLIDESW	0x81420000
#define	BASEADDRESS_RS232	0x84000000
#define	BASEADDRESS_EPC		0x80800000
unsigned long *base_EPC;		// base_EPC = BASEADDRESS_EPC;

//--------------------------------------------------------------------------------------------------
// ���� : I/O ��ġ�� �ɺ��� �����Ͽ� �׼����Ѵ�.
//--------------------------------------------------------------------------------------------------
//*

#define	LED   (*((volatile unsigned char *)(BASEADDRESS_LEDS + 0x03)))
#define SLIDE_SW (*((volatile unsigned char *)(BASEADDRESS_SLIDESW + 3)))

#define OFFSET 0x0				// for DDO_0
//#define OFFSET 0x4				// for DDO_1
//#define OFFSET 0x8				// for DDO_2
//#define OFFSET 0xc				// for DDO_3
//#define OFFSET 0x10				// for DDO_4
//#define OFFSET 0x14				// for DDO_5
//#define OFFSET 0x18				// for DDO_6
//#define OFFSET 0x1c				// for DDO_7

#define DDO_32 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x00 + OFFSET )))			// 32��Ʈ ��ġ
#define DDO_8 (*((volatile unsigned char *)(BASEADDRESS_EPC + 0x00 + 3 +OFFSET)))			// 8��Ʈ ��ġ
#define DDO_16 (*((volatile unsigned short *)(BASEADDRESS_EPC + 0x00 + 2+OFFSET)))		// 16��Ʈ ��ġ

// ���ĵ��� ����(unaligned) �׼��� ���ۿ����� �������Ѵ�. MB�� ���� �̷��� �����ĵ��ۿ����� exception�� �߻��Ͽ� �̸� �����ϴ� ������ ����Ǿ� ������ ���� �� �ͼ��ǿ� ����� ���� ��ƾ�� ���õǾ� ���� �ʴ�.
// �Ʒ��� �����Ͱ� �̷� �������� �����Ѵ�.
#define DDO_16_unaligned (*((volatile unsigned short *)(BASEADDRESS_EPC + 0x00 + 1 + OFFSET)))		// �����ĵ� 16��Ʈ ������


#define DDO_0 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x00)))
#define DDO_1 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x04)))
#define DDO_2 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x08)))
#define DDO_3 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x0c)))
#define DDO_4 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x10)))
#define DDO_5 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x14)))
#define DDO_6 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x18)))
#define DDO_7 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x1c)))

#define DDO(reg_no) (*((volatile unsigned long *)(BASEADDRESS_EPC + reg_no*4)))

#define RxFifo (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0x0 +3 )) )
#define TxFifo (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0x4 +3 )) )
#define StatReg (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0x8 +3 )) )
#define CtrlReg (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0xc +3 )) )

#define DataLCD		(*((volatile unsigned long *)(BASEADDRESS_EPC + 3 + 0x20))) // 1000_00
#define StatusCMD	(*((volatile unsigned long *)(BASEADDRESS_EPC + 3 + 0x24))) // 1001_00

#define BUSY 0x80
#define NULL 0

#include <stdio.h>

unsigned short	Bin2ASCII(unsigned char BinData) {
	unsigned char Nibble, UpperAscii, LowerAscii;
	Nibble = BinData >> 4;
	if (Nibble <= 9) {
		UpperAscii = Nibble + '0';		// 0x30;
	}
	else
		UpperAscii = Nibble + 'A' - 10;		// 0x41;

	Nibble = BinData & 0x0f;
	if (Nibble <= 9) {
		LowerAscii = Nibble + '0';		// 0x30;
	}
	else
		LowerAscii = Nibble + 'A' - 10;		// 0x41;
	return(UpperAscii << 8 | LowerAscii );
}

unsigned char GetCh(void) {
	unsigned char Status;
	Status = StatReg;		// Read in Status
	// ������ �����͸� �Է¹����� ���� ���������� ���� 04->05�� ���ϴ� ���� Ȯ���Ͽ���.
	// ���� ��Ʈ 0�� 1�̸� Receiver Buffer Full, 0�̸� Receiver Buffer Empty ���� �� �� �ִ�.
	do {
		Status = StatReg;		// Read in Status
	} while ( (Status & 0x1) == 0 );
	return(RxFifo);
}

void PutCh(unsigned char ch) {
	unsigned char	Status;
	Status = StatReg;		// Read in Status
	// Tx FIFO empty(��Ʈ2)�� 1�̸� empty. ���� 1�� �� ������ ��ٸ���.
	do {
		Status = StatReg;		// Read in Status
	} while ( (Status & 0x4) == 0 );
	TxFifo = ch;
}

void Printf(char String[]) {
	int	i;
	for(i=0; String[i] != 0; i++) {
		if(String[i] == '\n')
			PutCh(0x0d);			// Add carriage return
		PutCh(String[i]);
	}
}

void Print8bits(unsigned char ch) {
	unsigned char tmp;
	unsigned short	Hex16Value;
	Hex16Value=Bin2ASCII(ch);		// Convert 8 bit binary data to 16 bit ASCII code
	tmp = Hex16Value >> 8; 	PutCh(tmp); 		// *TxFifo = ch;	// Send ASCII of the 1st digit.
	tmp = Hex16Value & 0xff; PutCh(tmp); 		//*TxFifo = ch;	// Send ASCII of the 2nd digit.
}
void Print16bits(unsigned short ch) {
	unsigned char tmp;
	tmp = ch >> 8; 	Print8bits(tmp);
	tmp = (unsigned char) ch ; Print8bits(tmp);
}
void Print32bits(unsigned long ch) {
	unsigned short tmp;
	tmp = ch >> 16; 	Print16bits(tmp);
	tmp = (unsigned short) ch ; Print16bits(tmp);
}

void delay(unsigned int count)
{
	while(count != 0)
		count--;
}

 // ****************** LCD Functions *************************** //

unsigned char	WaitBusyClear(void) {
	unsigned char	BusyStatus = 0;

	do{
		BusyStatus = StatusCMD;
	}while( (BusyStatus & BUSY) == 1 );

}

void	SendCmdToLcd(unsigned char cCode) {
	StatusCMD = cCode;

	WaitBusyClear();
}



void	InitLcd(void) {
	Printf("\nLCD Initialization Start");

	Printf("\n1. Function Set");
	SendCmdToLcd(0x38); // Function Set(40us)= 0x20 + 0x10(DL=8bit) + 0x08(2 lines) +0x00(5*8 dots)

	Printf("\n2. Display On");
	SendCmdToLcd(0x0F); // Display On/Off Control(40us)= 0x08 + 0x04(Display On) + 0x02(Cursor On) + 0x01(Blink On)

	Printf("\n3. Clear display\n");
	SendCmdToLcd(0x01); // Clear Display(1.64ms)

}

void	PutCharLcd(unsigned char cChar) {			// LCD print
	DataLCD = cChar;

	WaitBusyClear();
}

void	PrintfLcd(char *String) {
	int	i;
	for(i=0; String[i] != NULL; i++) {
		if ( String[i] == '\n' ) {
				PutCharLcd('\r');
		}
		else
			PutCharLcd(String[i]);
	}
}

int main()
{
		InitLcd();

		PrintfLcd("abcdefghijklmn");


		///////////////// EPC RegisterDDO Test /////////////////////////////////////

		unsigned	long	Value, Value2;
		unsigned	long	*ptr32;
		volatile 	unsigned	long	*ptr32_volatile;
		//volatile 	unsigned	char	*ptr8v0, *ptr8v1, *ptr8v2, *ptr8v3;
		unsigned	short	Val16L, Val16H;
		unsigned 	long		reg_no=0;

		base_EPC = BASEADDRESS_EPC;

		LED = 0xaa;				// Output to LEDs
		Printf("\n\n\n\n**********************************");
		Printf("\n***** EPC GPIO Test **************");
		Printf("\n**********************************");

		///////////////////////////////////////////////////////////////////////////////////////////////
		// Test 1
		// volatile�� ������� ���� �����͸� �̿��Ͽ� �������Ϳ� ���� W/R/C ������ �����Ѵ�.
		// - �߸��� ��������� ����ȭ -O3�� �����ϸ� ������ �߰ߵ��� �ʴ´�. ����ȭ -None�� �����ϸ� ������ ����� ���� �ִ�.
		// ���� 1 : �� ���� ���(Test 1)�� � ������ �ִ��� �����϶�. ��, volatile�� ������� ���� �����͸� �̿��ϸ� � ������ �߻��� �� �ִ°�?
		//		�� :	������ �޸𸮿� ���� �д� ������ �������� ���� �� �ִ�. �����Ϸ��� �������� ���� �д� �������� ����ȭ�� ������ �� �ִ�.
		//		   	���� �� �ٷ� ���� ���� �ּҰ� Ʋ���� ������ ���� ��ó�� ���� ���� �ִ�.
		//			�׷���, �ϴ� �� ���� �� �о� ���� ������ ���� ����� ������ �� �ִ�.
		//		���� : ������ ���� �� 2-1�� ����ϸ� �ּҰ� Ʋ�ȴµ��� �̸� �߰����� ���Ѵ�.
		// ���� 2 : ��� 2-1�� ������ ���� ����� �߸��� ���� �����϶�.
		//		�� : long pointer�� +1 ������Ű�� �����ʹ� �ּ� ���� +4��  �����Ѵ�.
		//			���� ��� 2-2�� ����ؾ� �Ѵ�.
		// ���� 3 : reg. 7�� �� ���� ������ �ʴ� ������ �����϶�. hint-top.v�� ������ ��.
		//		�� : EPC_GPIO_no_3_state ����� ����ϸ� reg. 7�� ���� �۵��Ѵ�.
		///////////////////////////////////////////////////////////////////////////////////////////////
		Printf("\n\n----- Test 1 : Register R/W test with memory pointer");
		Value = 0x12345678;
		for (reg_no=0; reg_no < 8; reg_no++) {

			// ������ ���� 1 - 1�� 2 ���� �Ѱ��� ��� ����
			//ptr32 = (unsigned long*)(BASEADDRESS_EPC + reg_no * 4);

			// ������ ���� 2 - 1�� 2 ���� �Ѱ��� ��� ����
			// ���� 2 : ptr32�� �Ʒ��� ���� long pointer�� �̿��Ͽ� �����Ͽ���. � ������ �ִ��� �����϶�.
			ptr32= base_EPC + reg_no * 4;			// ��� 2-1 -> Ʋ����!
			//ptr32= base_EPC + reg_no;				// ��� 2-2 -> �´� ���!

			// ���� �д� ����.
			*ptr32  = Value;		Value2 = *ptr32;		// ���� & �б� ����

			// Ȯ��
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Pointer="); Print32bits((unsigned long)ptr32);
			Printf(" Written="); Print32bits(Value);
			Printf(" Read="); Print32bits(Value2);
			Value = Value + 0x3c345789;
		}


		// ��� 2-1�� ����� �Ŀ� ��� �� ���� �Ŀ� �ϳ��� �о�� Ʋ���� ���� �� �� �ִ�.
		Printf("\nCheck if the registers really contain what were written");
		for (reg_no=0; reg_no < 8; reg_no++) {
			ptr32 = (unsigned long*)(BASEADDRESS_EPC + reg_no * 4);
			Value2 = *ptr32;		// �б� ����
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Pointer="); Print32bits((unsigned long)ptr32);
			Printf(" Read="); Print32bits(Value2);
		}


		///////////////////////////////////////////////////////////////////////////////////////////////
		// Test 2
		// �ùٸ� IO ��ġ �׼��� ��� - �� �������Ϳ� ���� volatile�� ����� �����͸� �̿��Ͽ� W/R/C ������ �����Ѵ�.
		///////////////////////////////////////////////////////////////////////////////////////////////
		Printf("\n\n----- Test 2 : Register R/W test with volatile pointer");
		Value = 0x12345678;
		for (reg_no=0; reg_no < 8; reg_no++) {

			// ��� 1 �ùٸ� ������ ����
			//ptr32_volatile = (unsigned long*)(BASEADDRESS_EPC + reg_no * 4);

			// ��� 2 �ùٸ� ������ ������ �ٸ� ���
			ptr32_volatile = base_EPC + reg_no;

			*ptr32_volatile  = Value;		Value2 = *ptr32_volatile;		//���� & �б� ����
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Pointer="); Print32bits((unsigned long)ptr32_volatile);
			Printf(" Written="); Print32bits(Value);
			Printf(" Read="); Print32bits(Value2);
			Value = Value + 0x3c345789;
		}


		Printf("\nCheck if the registers really contain what were written");
		for (reg_no=0; reg_no < 8; reg_no++) {
			ptr32_volatile = (unsigned long*)(BASEADDRESS_EPC + reg_no * 4);
			Value2 = *ptr32_volatile;		// �б� ����
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Pointer="); Print32bits((unsigned long)ptr32_volatile);
			Printf(" Read="); Print32bits(Value2);
		}

		///////////////////////////////////////////////////////////////////////////////////////////////
		// Test 3
		// short�� �ڷῡ ���� pointer�� �̿��� 32��Ʈ �� 16��Ʈ�� �׼��� �ϴ� ����
		// ������ 16��Ʈ�� �ùٸ��� �׼����ϴ� �� ���� �߰� 16��Ʈ�� ���ؼ��� �ùٸ� �׼����� �̷������ �ʰ� �ִ�.
		// misaligned �� ������ �׼����� ���ؼ��� MB������ ���ο� exception�� �߻��ϵ��� �ϴ� ��ī������ �غ�Ǿ� �ִ�.
		// S/W handler���� �� ������ �����ϵ��� �Ǿ� �ִ�. ����� �� �ͼ����� �㰡�Ǿ� ���� �ʴ�.
		///////////////////////////////////////////////////////////////////////////////////////////////
		Printf("\n\n----- Test 3 : Short Access(READ only operation)");
		volatile 	unsigned	short	*ptr16v1, *ptr16v2 ;
		for (reg_no=0; reg_no < 8; reg_no++) {
			ptr16v1 = (unsigned short*)(BASEADDRESS_EPC + reg_no * 4 + 2);			// Low 16 bits
			ptr16v2 = (unsigned short*)(BASEADDRESS_EPC + reg_no * 4 + 0);			// High 16 bits
			Val16L = *ptr16v1;		// Low 16 bit access
			Val16H = *ptr16v2;		// High 16 bit access
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Read(High)="); Print16bits(Val16H);
			Printf(" Read(Low)="); Print16bits(Val16L);
		}
		// ������ MicroBlaze������ �߰� 16��Ʈ�� �ùٸ��� �о�� ���ϰ� �ִ�.
		for (reg_no=0; reg_no < 8; reg_no++) {
			ptr16v1 = (unsigned short*)(BASEADDRESS_EPC + reg_no * 4 + 1);			// middle 16 bits
			Val16L = *ptr16v1;		// Low 16 bit access
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Read(Middle)="); Print16bits(Val16L);
		}

		///////////////////////////////////////////////////////////////////////////////////////////////
		// Test 4
		// byte�� �ڷῡ ���� pointer�� �̿��� 32��Ʈ �� 8��Ʈ�� �׼��� �ϴ� ����
		// ��� ����Ʈ�� ���� �ùٸ� ������ �����Ѵ�.
		///////////////////////////////////////////////////////////////////////////////////////////////
		Printf("\n\n----- Test 4 : Byte Access(READ only operation)");
		volatile 	unsigned	char	*ptr8v0, *ptr8v1, *ptr8v2, *ptr8v3;
		for (reg_no=0; reg_no < 8; reg_no++) {
			ptr8v0 = (unsigned char*)(BASEADDRESS_EPC + reg_no * 4 + 0);			// Highest 8 bits
			ptr8v1 = (unsigned char*)(BASEADDRESS_EPC + reg_no * 4 + 1);			// middle high 8 bits
			ptr8v2 = (unsigned char*)(BASEADDRESS_EPC + reg_no * 4 + 2);			// middle low 8 bits
			ptr8v3 = (unsigned char*)(BASEADDRESS_EPC + reg_no * 4 + 3);			// Lowest 8 bits
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Read(H)="); Print8bits(*ptr8v0);
			Printf(" Read(MH)="); Print8bits(*ptr8v1);
			Printf(" Read(ML)="); Print8bits(*ptr8v2);
			Printf(" Read(L)="); Print8bits(*ptr8v3);
		}

		while(1);




//# EPC�� ��ȣ�� �������� �б� ������ ���� ������ ����.
//# �� : BE, ncs, �ּҽ�ȣ A0, A1, A2, A3 ���� ��ȣ�� �����϶�.


}


