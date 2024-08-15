#include <stdlib.h>
#include <6502.h>
#include <lynx.h>
#include <tgi.h>
#include <peekpoke.h>
#include "math.h"

void wait_joystick()
{
	__asm__("press:		lda $FCB0");
	__asm__("					beq press");
	__asm__("release: lda $FCB0");
	__asm__("					bne release");
}

// Normal usage of the math functions
void sample_usage()
{
	char text[20];
	long a = divide(0x12345678, 0x1234);
	long b = multiply(0x1234, 0x5678);
	
	tgi_clear();

	ltoa(a, text, 16);
	tgi_outtextxy(10, 10, text);
	ltoa(b, text, 16);
	tgi_outtextxy(10, 20, text);

	a = divide(0x12345678, 0x00);
	if (MATHERROR)
	{
		tgi_outtextxy(10, 30, "Divide by zero");
	}
	else
	{
		ltoa(a, text, 16);
		tgi_outtextxy(10, 30, text);
	}
	while (tgi_busy());

	wait_joystick();
}

// Will read the initial values of the math registers
// and display these 
void math_initial()
{
	long a = PEEKL(MATHABCD);
	long e = PEEKL(MATHEFGH);
	long j = PEEKL(MATHJKLM);
	unsigned short n = PEEKW(MATHNP);
	char value[20];
	
	tgi_clear();
	tgi_outtextxy(0, 0, "ABCD:");
	ltoa(a, value, 16);
	tgi_outtextxy(0, 10, value);
	tgi_outtextxy(0, 20, "EFGH:");
	ltoa(e, value, 16);
	tgi_outtextxy(0, 30, value);
	tgi_outtextxy(0, 40, "JKLM:");
	ltoa(j, value, 16);
	tgi_outtextxy(0, 50, value);
	tgi_outtextxy(0, 60, "NP:");
	itoa(n, value, 16);
	tgi_outtextxy(0, 70, value);

	while (tgi_busy());

	wait_joystick();
}

// Shows the number of iterations through a waiting loop while math
// divide operation occurs for different significant zeros in the
// divisor. The zeros in the divisor determine the delay by the
// formula: delay = 176 + N*14 where N is number of zeros
void math_delay()
{
	int significant_zeros = 0;
	char x;
	char text[20];
	short div = 0x7FFF;
	short b1 = 0x1234;
	short b2 = 0x5678;
	long c;

	tgi_clear();
	tgi_outtextxy(0, 0, "Zeros:Iterations");

	while (significant_zeros < 16)
	{
		POKEW(MATHNP, div);
		POKEW(MATHGH, b2);
		POKEW(MATHEF, b1);
		WAITMATH;
		x = PEEK(0x77);
		c = PEEKL(MATHABCD);
		
		tgi_gotoxy((significant_zeros % 2) * 80, ((significant_zeros >> 1) + 1) * 10);
		
		itoa(div, text, 10);
		tgi_outtext(text);
		tgi_outtext(":");
		itoa(significant_zeros, text, 10);
		tgi_outtext(text);
		tgi_outtext(":");

		itoa(x, text, 10);
		tgi_outtext(text);

		// Set values for next loop
		div /= 2;
		significant_zeros++;
	}

	tgi_outtextxy(0, 90, "Done!");
	tgi_updatedisplay();
	while (tgi_busy());

	wait_joystick();
}

// Shows the values of the math register for a divide when reading 
// too soon. 
void prematuremath_read()
{
	char text[20];
	short div = 0x2;
	short b1 = 0x1234;
	short b2 = 0x5678;
	long c;

	tgi_clear();

	c = PEEKL(MATHABCD);
	ltoa(c, text, 16);
	tgi_gotoxy(10, 10);
	tgi_outtext("before:");
	tgi_outtext(text);

	POKEW(MATHNP, div);
	POKEW(MATHGH, b2);
	POKEW(MATHEF, b1);
		
	// Immediately look at ABCD
	c = PEEKL(MATHABCD);
		
	ltoa(c, text, 16);
	tgi_gotoxy(10, 20);
	tgi_outtext("early:");
	tgi_outtext(text);
	
	// Look again
	c = PEEKL(MATHABCD);		
	ltoa(c, text, 16);
	tgi_gotoxy(10, 30);
	tgi_outtext("early2:");
	tgi_outtext(text);

	// Wait for math operation to finish
	WAITMATH;
	c = PEEKL(MATHABCD);		
	ltoa(c, text, 16);
	tgi_gotoxy(10, 40);
	tgi_outtext("complete:");
	tgi_outtext(text);

	tgi_outtextxy(0, 90, "Done!");

	tgi_updatedisplay();
	while (tgi_busy());

	wait_joystick();
}

void initialize()
{
	tgi_install(&tgi_static_stddrv);
	tgi_init();
	CLI();
	
	while (tgi_busy()) 
	{ 
	};

	tgi_setpalette(tgi_getdefpalette());	
	tgi_setcolor(COLOR_WHITE);
	tgi_setbgcolor(COLOR_BLACK); 
	tgi_clear();
}

void main(void) 
{	
	initialize();

	while (1)
	{
		if (!tgi_busy())
		{
			math_initial();
			math_delay();
			sample_usage();
			prematuremath_read();
		}
	};
}