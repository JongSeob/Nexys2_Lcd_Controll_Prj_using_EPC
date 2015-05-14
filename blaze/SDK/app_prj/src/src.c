//*************************************************************************************
// EPC 모듈을 장착하여 GPIO 출력장치와 쓴 값을 읽어보는 입력장치를 테스트한다.
// 32비트의 Digital Data Output 장치들이 8비트 단위로 개별 동작하도록 설계되었다.
//*************************************************************************************

#define	BASEADDRESS_LEDS	0x81400000
#define	BASEADDRESS_SLIDESW	0x81420000
#define	BASEADDRESS_RS232	0x84000000
#define	BASEADDRESS_EPC		0x80800000
unsigned long *base_EPC;		// base_EPC = BASEADDRESS_EPC;

//--------------------------------------------------------------------------------------------------
// 실험 : I/O 장치를 심볼로 정의하여 액세스한다.
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

#define DDO_32 (*((volatile unsigned long *)(BASEADDRESS_EPC + 0x00 + OFFSET )))			// 32비트 장치
#define DDO_8 (*((volatile unsigned char *)(BASEADDRESS_EPC + 0x00 + 3 +OFFSET)))			// 8비트 장치
#define DDO_16 (*((volatile unsigned short *)(BASEADDRESS_EPC + 0x00 + 2+OFFSET)))		// 16비트 장치

// 정렬되지 않은(unaligned) 액세스 동작에서는 오동작한다. MB는 당초 이러한 비정렬동작에서는 exception을 발생하여 이를 교정하는 것으로 설계되어 있으나 현재 이 익셉션에 대비한 서비스 루틴이 마련되어 있지 않다.
// 아래의 포인터가 이런 오동작을 유발한다.
#define DDO_16_unaligned (*((volatile unsigned short *)(BASEADDRESS_EPC + 0x00 + 1 + OFFSET)))		// 비정렬된 16비트 포인터


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
		// volatile로 선언되지 않은 포인터를 이용하여 레지스터에 대해 W/R/C 동작을 수행한다.
		// - 잘못된 방법이지만 최적화 -O3를 설정하면 오류가 발견되지 않는다. 최적화 -None을 설정하면 오류가 검출될 수도 있다.
		// 문제 1 : 본 실험 방법(Test 1)에 어떤 문제가 있는지 설명하라. 즉, volatile로 선언되지 않은 포인터를 이용하면 어떤 오류가 발생할 수 있는가?
		//		답 :	실제로 메모리에 쓰고 읽는 동작을 수행하지 않을 수 있다. 컴파일러가 레지스에 쓰고 읽는 동작으로 최적화를 실행할 수 있다.
		//		   	쓰고 곧 바로 읽을 때는 주소가 틀려도 문제가 없는 것처럼 보일 수도 있다.
		//			그러나, 일단 써 놓은 후 읽어 보면 오류가 나는 모습을 관찰할 수 있다.
		//		증거 : 포인터 정의 법 2-1를 사용하면 주소가 틀렸는데도 이를 발견하지 못한다.
		// 문제 2 : 방법 2-1의 포인터 증가 방법의 잘못된 점을 설명하라.
		//		답 : long pointer를 +1 증가시키면 포인터는 주소 값은 +4가  증가한다.
		//			따라서 방법 2-2를 사용해야 한다.
		// 문제 3 : reg. 7이 쓴 값이 읽히지 않는 이유를 설명하라. hint-top.v를 검토할 것.
		//		답 : EPC_GPIO_no_3_state 모듈을 사용하면 reg. 7도 정상 작동한다.
		///////////////////////////////////////////////////////////////////////////////////////////////
		Printf("\n\n----- Test 1 : Register R/W test with memory pointer");
		Value = 0x12345678;
		for (reg_no=0; reg_no < 8; reg_no++) {

			// 포인터 선언 1 - 1과 2 중의 한가지 방법 선택
			//ptr32 = (unsigned long*)(BASEADDRESS_EPC + reg_no * 4);

			// 포인터 선언 2 - 1과 2 중의 한가지 방법 선택
			// 문제 2 : ptr32를 아래와 같이 long pointer를 이용하여 정의하였다. 어떤 문제가 있는지 설명하라.
			ptr32= base_EPC + reg_no * 4;			// 방법 2-1 -> 틀렸음!
			//ptr32= base_EPC + reg_no;				// 방법 2-2 -> 맞는 방법!

			// 쓰고 읽는 동작.
			*ptr32  = Value;		Value2 = *ptr32;		// 쓰기 & 읽기 동작

			// 확인
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Pointer="); Print32bits((unsigned long)ptr32);
			Printf(" Written="); Print32bits(Value);
			Printf(" Read="); Print32bits(Value2);
			Value = Value + 0x3c345789;
		}


		// 방법 2-1을 사용한 후에 모두 써 놓은 후에 하나씩 읽어보면 틀려진 것을 볼 수 있다.
		Printf("\nCheck if the registers really contain what were written");
		for (reg_no=0; reg_no < 8; reg_no++) {
			ptr32 = (unsigned long*)(BASEADDRESS_EPC + reg_no * 4);
			Value2 = *ptr32;		// 읽기 동작
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Pointer="); Print32bits((unsigned long)ptr32);
			Printf(" Read="); Print32bits(Value2);
		}


		///////////////////////////////////////////////////////////////////////////////////////////////
		// Test 2
		// 올바른 IO 장치 액세스 기법 - 각 레지스터에 대해 volatile로 선언된 포인터를 이용하여 W/R/C 동작을 실행한다.
		///////////////////////////////////////////////////////////////////////////////////////////////
		Printf("\n\n----- Test 2 : Register R/W test with volatile pointer");
		Value = 0x12345678;
		for (reg_no=0; reg_no < 8; reg_no++) {

			// 방법 1 올바른 포인터 설정
			//ptr32_volatile = (unsigned long*)(BASEADDRESS_EPC + reg_no * 4);

			// 방법 2 올바른 포인터 설정의 다른 방법
			ptr32_volatile = base_EPC + reg_no;

			*ptr32_volatile  = Value;		Value2 = *ptr32_volatile;		//쓰기 & 읽기 동작
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Pointer="); Print32bits((unsigned long)ptr32_volatile);
			Printf(" Written="); Print32bits(Value);
			Printf(" Read="); Print32bits(Value2);
			Value = Value + 0x3c345789;
		}


		Printf("\nCheck if the registers really contain what were written");
		for (reg_no=0; reg_no < 8; reg_no++) {
			ptr32_volatile = (unsigned long*)(BASEADDRESS_EPC + reg_no * 4);
			Value2 = *ptr32_volatile;		// 읽기 동작
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Pointer="); Print32bits((unsigned long)ptr32_volatile);
			Printf(" Read="); Print32bits(Value2);
		}

		///////////////////////////////////////////////////////////////////////////////////////////////
		// Test 3
		// short형 자료에 대한 pointer를 이용해 32비트 중 16비트를 액세스 하는 실험
		// 상하위 16비트는 올바르게 액세스하는 데 반해 중간 16비트에 대해서는 올바른 액세스가 이루어지지 않고 있다.
		// misaligned 된 데이터 액세스에 대해서는 MB에서는 내부에 exception을 발생하도록 하는 메카니즘이 준비되어 있다.
		// S/W handler에서 이 동작을 보완하도록 되어 있다. 현재는 이 익셉션이 허가되어 있지 않다.
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
		// 현재의 MicroBlaze에서는 중간 16비트를 올바르게 읽어내지 못하고 있다.
		for (reg_no=0; reg_no < 8; reg_no++) {
			ptr16v1 = (unsigned short*)(BASEADDRESS_EPC + reg_no * 4 + 1);			// middle 16 bits
			Val16L = *ptr16v1;		// Low 16 bit access
			Printf("\nReg. No."); Print8bits(reg_no);
			Printf(" Read(Middle)="); Print16bits(Val16L);
		}

		///////////////////////////////////////////////////////////////////////////////////////////////
		// Test 4
		// byte형 자료에 대한 pointer를 이용해 32비트 중 8비트를 액세스 하는 실험
		// 모든 바이트에 대해 올바른 동작을 실행한다.
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




//# EPC의 신호를 레지스터 읽기 동작을 통해 관찰해 보자.
//# 예 : BE, ncs, 주소신호 A0, A1, A2, A3 등의 신호를 관찰하라.


}


