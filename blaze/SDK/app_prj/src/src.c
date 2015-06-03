//*************************************************************************************
// EPC 모듈을 장착하여 GPIO 출력장치와 쓴 값을 읽어보는 입력장치를 테스트한다.
// 32비트의 Digital Data Output 장치들이 8비트 단위로 개별 동작하도록 설계되었다.
//*************************************************************************************

#define	BASEADDRESS_LEDS	0x81400000
#define	BASEADDRESS_SLIDESW	0x81420000
#define	BASEADDRESS_RS232	0x84000000
#define	BASEADDRESS_EPC_0	0x80800000
#define	BASEADDRESS_EPC_1	0x80800008

#define	LED   (*((volatile unsigned char *)(BASEADDRESS_LEDS + 0x03)))
#define SLIDE_SW (*((volatile unsigned char *)(BASEADDRESS_SLIDESW + 3)))

#define RxFifo (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0x0 +3 )) )
#define TxFifo (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0x4 +3 )) )
#define StatReg (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0x8 +3 )) )
#define CtrlReg (*((volatile unsigned char *)(BASEADDRESS_RS232 + 0xc +3 )) )

#define DataLCD		(*((volatile unsigned char *)(BASEADDRESS_EPC_0 + 0x00))) // 0000_00
#define StatusCMD	(*((volatile unsigned char *)(BASEADDRESS_EPC_0 + 0x04))) // 0001_00

#define DataUART    (*((volatile unsigned char *)(BASEADDRESS_EPC_1 + 0x00))) // 0010_00
#define StatusUART  (*((volatile unsigned char *)(BASEADDRESS_EPC_1 + 0x04))) // 0011_00

#define BUSY 0x80
#define NULL 0

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

void delay(unsigned int count)
{
	while(count != 0)
		count--;

	LED = LED + count&0;
}

void Printf(char String[]) {
	int	i;
	for(i=0; String[i] != 0; i++)
	{
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

unsigned char GetCh(void) {
	unsigned char Status;
	unsigned char ch;

	do {
		Status = StatusUART;
	} while ( (Status & 0x01) == 0 ); // rdaSig 가 1이 될 때까지 대기

	ch = DataUART;

	return ch;
}

void PutCh(unsigned char ch) {
	unsigned char	Status;
	static int flag = 0; // PutCh('\n');, PutCh('\r'); 실행시 무한루프를 방지하기위해 선언한 플래그.

	do {
			Status = StatusUART;
	} while ( (Status & 0x02) == 0 ); // tbeSig 가 1이 될 때까지 대기

	DataUART = ch;

	if(flag == 0)
	{
		flag = 1;

		if(ch == '\r')
			PutCh('\n');
		else if(ch == '\n')
			PutCh('\r');
	}

	flag = 0;
}
 // ****************** LCD Functions *************************** //

unsigned char	CheckBusy(void)
{
	unsigned char	iBusyStatus;

	iBusyStatus = StatusCMD;

	delay(200);	// Read Data Output Delay의 최대시간 120ns가 지날때까지 대기.

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

unsigned char GetPositionOfLcd()
{
	unsigned char position;

	position = StatusCMD;

	delay(200);	// Read Data Output Delay의 최대시간 120ns가 지날때까지 대기.

	position = StatusCMD;

	return (position & 0x7F); // BUSY플래그를 제거.
}

void PrintCurrentPositionOfLcd()
{
	unsigned char position;

	position = GetPositionOfLcd();

	Printf("Current Position = 0x"); Print8bits(position); PutCh('\n');
}

void	PutCharLcd(unsigned char cChar) // LCD print
{
	unsigned char DDRAM_addr;

	DDRAM_addr = GetPositionOfLcd();

	if(cChar == '\r' || cChar == '\n')
	{
		if(DDRAM_addr < 0x40)
			SendCmdToLcd(0x80 + DDRAM_addr + 0x40);
		else
			SendCmdToLcd(0x80 + DDRAM_addr - 0x40);
		return;
	}
	else if(DDRAM_addr == 0x10)
	{
		SendCmdToLcd(0xC0);  // Set DDRAM addres(40uS) = 0x80 | 0x40(second line)
	}
	else if(DDRAM_addr == 0x50)
	{
		SendCmdToLcd(0x80);  // Set DDRAM addres(40uS) = 0x80 | 0x00(first line)
	}


	SendCharToLcd(cChar);
}

void	PrintfLcd(char *String)
{
	int	i;

	for(i=0; String[i] != NULL; i++)
	{
		PutCharLcd(String[i]);
	}

}

void	InitLcd(void)
{
	Printf("LCD Initialization : Data out mode\n");

	Printf("LCD Initialization Stage 1 : Sending 0x38\n");
	SendCmdToLcd(0x38);						// Function Set(40us)= 0x20 + 0x10(DL=8bit) + 0x08(2 lines) +0x00(5*8 dots)

	Printf("LCD Initialization Stage 2 : Sending 0x0f\n");
	SendCmdToLcd(0x0f);						// Display On/Off Control(40us)= 0x08 + 0x04(Display On) + 0x02(Cursor On) + 0x01(Blink On)

	Printf("LCD Initialization Stage 3 : Sending 0x01\n");
	SendCmdToLcd(0x01);						// Clear Display(1.64ms)
}



int main()
{
	unsigned char ch;
	unsigned char position;

	InitLcd();

	PrintfLcd("Lcd Test Start");

	SendCmdToLcd(0xC0);

	PrintfLcd("Lcd Test End");

	// CGRAM 테스트

	position = GetPositionOfLcd();

	SendCmdToLcd(0x40);
	SendCharToLcd(0x0E);
	SendCharToLcd(0x11);
	SendCharToLcd(0x0E);
	SendCharToLcd(0x04);
	SendCharToLcd(0x1F);
	SendCharToLcd(0x04);
	SendCharToLcd(0x0A);
	SendCharToLcd(0x11);

	SendCmdToLcd(0x80 + position);

	PutCharLcd(0);

	while(1)
	{
	  ch = GetCh();
	  PutCh(ch);
	  PutCharLcd(ch);
	}

	return 0;
}
