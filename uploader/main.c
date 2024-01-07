#include <6502.h>
#include <lynx.h>
#include <tgi.h>

#define true 1

void show_screen()
{
	tgi_clear();
	
	tgi_setcolor(COLOR_WHITE);
	tgi_outtextxy(30, 48, "Hello, World!");

	tgi_updatedisplay();
}

void initialize()
{
	tgi_install(&tgi_static_stddrv);
	tgi_init();
	CLI();
	
	while (tgi_busy());

	tgi_setbgcolor(COLOR_BLACK); 
	tgi_setpalette(tgi_getdefpalette());
	
	tgi_setcolor(COLOR_BLACK);
	tgi_clear();
}

void main(void) 
{	
	initialize();

	while (true)
	{
		if (!tgi_busy())
		{
			show_screen();
		}
	};
}