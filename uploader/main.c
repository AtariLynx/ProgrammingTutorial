#include <6502.h>
#include <lynx.h>
#include <tgi.h>
#include <joystick.h> 
#include <stdlib.h>

extern unsigned char lynxtgi[];
extern unsigned char lynxjoy[];
extern unsigned char comlynx[];

extern int MAIN_FILENR;
extern int UPLOAD_FILENR;

#define true 1

#define TXINTEN  128 // %10000000
#define RXINTEN  64  // %01000000
#define PAREN    16  // %00010000
#define RESETERR 8   // %00001000
#define TXOPEN   4   // %00000100
#define TXBRK    2   // %00000010
#define PAREVEN  1   // %00000001
#define TXRDY    128 // %10000000
#define RXRDY    64  // %01000000
#define TXEMPTY  32  // %00100000
#define PARERR   16  // %00010000
#define OVERRUN  8   // %00001000
#define FRAMERR  4   // %00000100
#define RXBRK    2   // %00000010
#define PARBIT   1   // %00000001

void show_screen()
{
	char text[4];
	unsigned char joy;

	tgi_clear();
	
	tgi_setcolor(COLOR_WHITE);
	tgi_setbgcolor(COLOR_TRANSPARENT);

	tgi_outtextxy(30, 20, "Hello, World!!");

	itoa(MIKEY.timer4.count, text, 10);
	tgi_outtextxy(10, 40, text);
	
	joy = joy_read(JOY_1);
	itoa(joy, text, 10);
	tgi_outtextxy(10, 50, text);

	itoa(MIKEY.serctl, text, 16);
	tgi_outtextxy(10, 60, text);

	tgi_updatedisplay();
	while (tgi_busy());
}

void initialize()
{
	lynx_load((int)&UPLOAD_FILENR);

	tgi_install(&tgi_static_stddrv);
	joy_install(&joy_static_stddrv); 
	tgi_init();
	CLI();

	
	while (tgi_busy());
	
	tgi_setbgcolor(COLOR_TRANSPARENT);

	tgi_clear();
}

void wait_joystick()
{
	__asm__("press:		lda $FCB0");
	__asm__("					beq press");
	__asm__("release: lda $FCB0");
	__asm__("					bne release");
}

void main(void) 
{	
	unsigned char data;
	char joy;	
	char text[20];

	initialize();

	joy = joy_read(JOY_1);
	itoa(joy, text, 10);
	tgi_clear();
	tgi_outtextxy(10, 10, text);
	while (tgi_busy());
	wait_joystick();

	MIKEY.timer4.control = 0x18; // %00011000
	MIKEY.timer4.reload = 12; //0x01;
	
	MIKEY.serctl = 0x04|0x01;
	// Dummy read
	data = MIKEY.serdat;
	
	MIKEY.serctl = 0x10|0x04|0x01|0x08; // 0x40|
	//MIKEY.SERCTL = TxParEnable|TxOpenColl|ParEven|ResetErr; //	RxIntEnable|

	// Clear receive buffer
	while ((MIKEY.serctl & 0x40) == 0x40)
	{
		data = MIKEY.serdat;
	}

	MIKEY.serctl = 0x40 | 0x10 | 0x04 | 0x01 | 0x08;

	while (true)
	{
		// if (!tgi_busy())
		// {
			show_screen();
		//}
	};
}