#include <6502.h>
#include <lynx.h>
#include <tgi.h>
#include <serial.h>
#include <stdlib.h>

#define true 1

char data, show, result, status_result;
unsigned char status;
char message[16];

void show_screen()
{
    char text[4];

	tgi_clear();

	tgi_setcolor(COLOR_WHITE);
	tgi_outtextxy(30, 48, "Serial demo");

    itoa(MIKEY.timer4.count, text, 10);
    tgi_outtextxy(10, 40, text);

    tgi_outtextxy(10, 0, message);
    itoa(show, text, 10);
    tgi_outtextxy(10, 10, text);
    itoa(status, text, 10);
    tgi_outtextxy(10, 20, text);
    itoa(status_result, text, 10);
    tgi_outtextxy(10, 30, text);

	tgi_updatedisplay();
}

void initialize()
{
	tgi_install(&tgi_static_stddrv);
    ser_install(&ser_static_stddrv);
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
    char count = 0;
    unsigned char index = 0;

    struct ser_params params = {
        SER_BAUD_62500,
        SER_BITS_8, // Only 8 bits are supported
        SER_STOP_1, // Must be 1 stop bit
        SER_PAR_EVEN, // SER_PAR_NONE is not allowed
        SER_HS_NONE // No handshake support
    };

    // SER_PAR_MARK => TXOPEN|PAREVEN
    // SER_PAR_SPACE => TXOPEN
    // SER_PAR_EVEN => PAREN|TXOPEN|PAREVEN
    // SER_PAR_ODD => PAREN|TXOPEN

    initialize();

    ser_open(&params);

    while (true)
    {
        result = ser_get(&message[index]);

        if (result != SER_ERR_NO_DATA)
        {
            show = data;
            status_result = ser_status(&status);
            ++index;
            if (index == 16)
            {
                index = 0;
            }
        }

        if (!tgi_busy())
        {
            //show = ser_put(++count);
            show_screen();
        }

    };

    ser_close();
}