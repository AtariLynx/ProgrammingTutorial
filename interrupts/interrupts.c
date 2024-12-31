#include <6502.h>
#include <lynx.h>
#include <tgi.h>
#include <stdlib.h>

#define true 1
#define IRQ_STACK_SIZE 128

unsigned char irq_stack [ IRQ_STACK_SIZE ];
volatile unsigned int irq_counter = 0;

unsigned char vbl(void)
{
	if ((MIKEY.intset & VERTICAL_INT) == 0)
	{
		return IRQ_NOT_HANDLED;
	}

	MIKEY.palette[1] = ++irq_counter;
	return IRQ_HANDLED;
}

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

	// Set up C-level interrupt
	set_irq (&vbl, irq_stack, IRQ_STACK_SIZE);
	
	// If no C calls are made from interrupt, no stack is needed.
	//set_irq (&vbl, NULL, 0);
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