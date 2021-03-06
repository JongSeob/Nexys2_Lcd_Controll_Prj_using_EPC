//*************************************************************************************
// EPC 모듈을 장착하여 GPIO 출력장치와 쓴 값을 읽어보는 입력장치를 테스트한다.
// 32비트의 Digital Data Output 장치들이 8비트 단위로 개별 동작하도록 설계되었다.
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

#define DataUART    (*((volatile unsigned char *)(BASEADDRESS_EPC + 0x04))) // 0001_00
#define StatusUART  (*((volatile unsigned char *)(BASEADDRESS_EPC + 0x08))) // 0010_00

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
	// 실험결과 데이터를 입력받으면 상태 레지스터의 값이 04->05로 변하는 것을 확인하였다.
	// 따라서 비트 0이 1이면 Receiver Buffer Full, 0이면 Receiver Buffer Empty 임을 알 수 있다.
	do {
		Status = StatReg;		// Read in Status
	} while ( (Status & 0x1) == 0 );
	return(RxFifo);
}

void PutCh(unsigned char ch) {
	unsigned char	Status;
	Status = StatReg;		// Read in Status
	// Tx FIFO empty(비트2)가 1이면 empty. 따라서 1이 될 때까지 기다린다.
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

unsigned char	CheckBusy(void)
{
	unsigned char	iBusyStatus;

	iBusyStatus = StatusCMD;

	return(iBusyStatus & 0x80);		// bit7 =1 if busy
}

void	SendCmdToLcd(unsigned char cCode)
{
	while (CheckBusy() == BUSY);		// wait until busy clear

	StatusCMD = cCode;
}


void	SendCharToLcd(unsigned char cChar)
{
	while (CheckBusy() == BUSY);		// wait until busy clear

	DataLCD = cChar;
}

void	InitLcd(void)
{
	Printf("\nLCD Initialization : Data out mode");

	Printf("\nLCD Initialization Stage 1 : Sending 0x38");
	SendCmdToLcd(0x38);						// Function Set(40us)= 0x20 + 0x10(DL=8bit) + 0x08(2 lines) +0x00(5*8 dots)
	Printf("\nLCD Initialization Stage 2 : Sending 0x0f");
	SendCmdToLcd(0x0f);						// Display On/Off Control(40us)= 0x08 + 0x04(Display On) + 0x02(Cursor On) + 0x01(Blink On)
	Printf("\nLCD Initialization Stage 3 : Sending 0x01\n");
	SendCmdToLcd(0x01);						// Clear Display(1.64ms)
}

void	PutCharLcd(unsigned char cChar) // LCD print
{
	unsigned char DDRAM_addr;

	while (CheckBusy() == BUSY);

	DDRAM_addr = StatusCMD;

	if(DDRAM_addr == 0x10)
	{
		SendCmdToLcd(0xC0);  // Set DDRAM addres(40uS) = 0x80 | 0x40(second line)
		SendCharToLcd(' ');
	}
	else if(DDRAM_addr == 0x50)
	{
		SendCmdToLcd(0x80);  // Set DDRAM addres(40uS) = 0x80 | 0x00(first line)
		SendCharToLcd(' ');
	}

	SendCharToLcd(cChar);


}

void	PrintfLcd(char *String)
{
	int	i;
	for(i=0; String[i] != NULL; i++)
	{
		if ( String[i] == '\n' )
		{
				PutCharLcd('\n');
				PutCharLcd('\r');
		}
		else
			PutCharLcd(String[i]);

	}
}

int main()
{
	char ch;

	InitLcd();

	PrintfLcd("Lcd Printf Test");

	ch = StatusUART;
	Print8bits(ch); // 1100 1100
	while(1)
	{
	ch = DataUART;
	Print8bits(ch); // 1100 1100
	}

	while(1)
	{
		ch = GetCh();
		PutCharLcd(ch);
		Print8bits(ch);
	}

	return 0;
}
