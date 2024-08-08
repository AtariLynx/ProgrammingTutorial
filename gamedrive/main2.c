#include <lynx.h>
#include <tgi.h>
#include <6502.h>
#include <joystick.h>
#include <string.h>
#include <stdio.h>
#include "LynxGD.h"

unsigned char saveBuf[128] = {0};
unsigned char tBuf[21] = {0};

void initialize(void)
{
	tgi_install(&tgi_static_stddrv);
    tgi_init();
    joy_install(&joy_static_stddrv);
    CLI();
	tgi_clear();
	tgi_updatedisplay();
	while (tgi_busy());
	LynxGD_Init();
}

void main(void)
{
    unsigned char count=0;
    unsigned char joy;
    unsigned char keypressed=0;
    initialize();

    while (1)
    {
		joy=joy_read(JOY_1);
		if(JOY_BTN_1(joy) && !keypressed)
		{
			saveBuf[0]=++count;
			if (LynxGD_OpenFile("/saves/game.sav") == FR_OK)
			{
				tgi_clear();
				LynxGD_WriteFile((void *)saveBuf, 128);
				LynxGD_CloseFile();
				tgi_outtextxy (0, 0, "SD Write OK");
				if (LynxGD_OpenFile("/saves/game.sav") == FR_OK)
				{
					LynxGD_ReadFile((void *)saveBuf, 128);
					LynxGD_CloseFile();
					tgi_clear();
					if(saveBuf[0]==count)
					{
						sprintf(tBuf,"SD Val %i",saveBuf[0]);
						tgi_outtextxy (0, 10, tBuf);
						tgi_outtextxy (0, 20, "Check OK");
						tgi_updatedisplay();
						while (tgi_busy());
					}
					else
					{
						sprintf(tBuf,"SD Val %i",saveBuf[0]);
						tgi_outtextxy (0, 10, tBuf);
						tgi_outtextxy (0, 20, "Check KO");
						tgi_updatedisplay();
						while (tgi_busy());
					}
				}
				else
				{
					tgi_clear();
					tgi_outtextxy (0, 10, "Open file 2 failed");
					tgi_updatedisplay();
					while (tgi_busy());
				}
			}
			else
			{
				tgi_clear();
				tgi_outtextxy (0, 0, "Open file 1 failed");
				tgi_updatedisplay();
				while (tgi_busy());
			}
			keypressed=1;
		}
		if(!joy)
			keypressed=0;
	}
}

