#include <6502.h>
#include <lynx.h>
#include <tgi.h>
#include <joystick.h> 
#include <stdlib.h>

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

extern void upload();

void show_screen()
{
	char text[4];
	unsigned char joy = joy_read(JOY_1);

	tgi_clear();
	
	tgi_setcolor(COLOR_WHITE);

	tgi_outtextxy(30, 20, "Hello, World!#");

	itoa(MIKEY.timer4.count, text, 10);
	tgi_outtextxy(10, 40, text);
	joy = joy_read(JOY_1);
	itoa(joy, text, 10);
	tgi_outtextxy(10, 50, text);
	itoa(MIKEY.serctl, text, 16);
	tgi_outtextxy(10, 60, text);
	//upload();
	PEEK()
	tgi_updatedisplay();
}

void initialize()
{
	tgi_install(&tgi_static_stddrv);
	tgi_init();
	joy_install(&joy_static_stddrv); 
	CLI();
	
	while (tgi_busy());

	tgi_setbgcolor(COLOR_BLACK); 
	tgi_setpalette(tgi_getdefpalette());
	
	tgi_setcolor(COLOR_BLACK);
	tgi_clear();
}

void main(void) 
{	
	unsigned char data;

	initialize();

	MIKEY.timer4.reload = 12; // 1MHz/16/(divider+1) = 0x01;
	MIKEY.timer4.control = 0x18; // ENABLE_RELOAD | ENABLE_COUNT %00011000
	MIKEY.serctl = 0x10|0x04|0x01|0x08; // 8E1 TxParEnable | TxOpenColl | ParEven | ResetErr;

	// Clear receive buffer
	while ((MIKEY.serctl & RXRDY) == RXRDY)
	{
		data = MIKEY.serdat;
	}

	// Enable Rx-interrupt
	//MIKEY.serctl = 0x40 | 0x10 | 0x04 | 0x01 | 0x08; // RxIntEnable | TxParEnable | TxOpenColl | ParEven | ResetErr;
	
	while (true)
	{
		if (!tgi_busy())
		{
			show_screen();
		}
	};
}