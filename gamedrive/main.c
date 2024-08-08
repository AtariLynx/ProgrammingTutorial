#include <6502.h>
#include <lynx.h>
#include <tgi.h>
#include <stdlib.h>

#include "LynxGD.h"

#define true 1

unsigned char buffer[512];
char text[4];

void wait_joystick()
{
    asm("press:   lda $FCB0");
    asm("         beq press");
    asm("release: lda $FCB0");
    asm("         bne release");
}

void show_screen(const char *message)
{
	tgi_clear();

	tgi_outtextxy(30, 48, message);

	tgi_updatedisplay();
}

void dump_buffer()
{
    unsigned char x, y, index, page = 0;
    index = 0;
    do
	{
		// Read 80 bytes for one page into buffer

		tgi_clear();

		// Draw all values
		for (y = 0; y < 8; y++)
		{
			for (x = 0; x < 8; x++)
			{
				itoa(buffer[index++], text, 16);
				tgi_outtextxy(x * 20, y * 10, text);
			}
		}
		tgi_updatedisplay();
		wait_joystick();
	}
	while (++page < 2);
}

void initialize()
{
	tgi_install(&tgi_static_stddrv);
	tgi_init();
	CLI();

	while (tgi_busy());

	tgi_setbgcolor(COLOR_BLACK);
	tgi_setpalette(tgi_getdefpalette());

	tgi_setcolor(COLOR_WHITE);
	tgi_clear();

    LynxGD_Init();
}

void main(void)
{
    FRESULT result;

	initialize();

    show_screen("Init done");
    wait_joystick();

    result = LynxGD_OpenFile("/circuitdude/level1.bin");
    if (result != FR_OK)
    {
        tgi_setcolor(COLOR_WHITE);
        tgi_outtextxy(10, 10, "Error opening file");
        itoa(result, text, 10);
        tgi_outtextxy(10, 20, text);
        tgi_updatedisplay();
        while (true);
    }
    else
    {
        show_screen("Open done");
        wait_joystick();
    }

    result = LynxGD_ReadFile(buffer, 128);
    if (result != FR_OK)
    {
        tgi_outtextxy(10, 10, "Error reading file");
        itoa(result, text, 10);
        tgi_outtextxy(10, 20, text);
        tgi_updatedisplay();
        while (true);
    }

    LynxGD_CloseFile();

	while (true)
	{
		if (!tgi_busy())
		{
			dump_buffer();
		}
	};
}