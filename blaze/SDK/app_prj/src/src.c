//*************************************************************************************
// EPC ����� �����Ͽ� GPIO �����ġ�� �� ���� �о�� �Է���ġ�� �׽�Ʈ�Ѵ�.
// 32��Ʈ�� Digital Data Output ��ġ���� 8��Ʈ ������ ���� �����ϵ��� ����Ǿ���.
//*************************************************************************************

#define	BASEADDRESS_LEDS	0x81400000
#define	BASEADDRESS_SLIDESW	0x81420000
#define	BASEADDRESS_RS232	0x84000000
#define	BASEADDRESS_EPC		0x80800000

#define	LED   (*((volatile unsigned char *)(BASEADDRESS_LEDS + 0x03)))
#define SLIDE_SW (*((volatile unsigned char *)(BASEADDRESS_SLIDESW + 3)))

#define RxFifo (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0x0 +3 )) )
#define TxFifo (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0x4 +3 )) )
#define StatReg (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0x8 +3 )) )
#define CtrlReg (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0xc +3 )) )

#define DataLCD		(*((volatile unsigned char *)(BASEADDRESS_EPC + 0x20))) // 1000_00
#define StatusCMD	(*((volatile unsigned char *)(BASEADDRESS_EPC + 0x24))) // 1001_00

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

void	PrintfLcd(char *String) {
	int	i;
	for(i=0; String[i] != NULL; i++)
	{
		DataLCD = String[i];

		if (String[i] == '\n')
			DataLCD = '\r';
	}
}

void	InitLcd(void) {
	int i;

	Printf("\nLCD Initialization Start");

	Printf("\n1. Function Set");
	StatusCMD = 0x38; // Function Set(40us)= 0x20 + 0x10(DL=8bit) + 0x08(2 lines) +0x00(5*8 dots)

	Printf("\n2. Display On");
	StatusCMD = 0x0F; // Display On/Off Control(40us)= 0x08 + 0x04(Display On) + 0x02(Cursor On) + 0x01(Blink On)

	Printf("\n3. Clear display\n");
	StatusCMD = 0x01; // Clear Display(1.64ms)

}

int main()
{
	char ch;

	InitLcd();

	DataLCD = 'a';

	ch = DataLCD;

	DataLCD = 'a';

		ch = DataLCD;


		DataLCD = 'a';

			ch = DataLCD;


	Print8bits(ch);

	return 0;
}