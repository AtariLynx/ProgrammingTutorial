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

void show_screen()
{
	char text[4];
	unsigned char joy;

	tgi_clear();
	
	tgi_setcolor(COLOR_WHITE);
	tgi_setbgcolor(COLOR_TRANSPARENT);

	tgi_outtextxy(30, 20, "Hello, World!");

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

	MIKEY.timer4.control = 0x18; // ENABLE_RELOAD | ENABLE_COUNT; // %00011000
	MIKEY.timer4.reload = 1; // AUD_2;	
	MIKEY.serctl = 0x10 | 0x04 | 0x01 | 0x08; // PAREN | TXOPEN | PAREVEN | RESETERR;

	// Clear receive buffer
	while ((MIKEY.serctl & 0x40) > 0)
	{
		data = MIKEY.serdat;
	}

	MIKEY.serctl = 0x40 | 0x10 | 0x04 | 0x01 | 0x08; // PAREN | TXOPEN | PAREVEN | RESETERR | RXINTEN;

	while (true)
	{
		// if (!tgi_busy())
		// {
			show_screen();
		//}
	};
}