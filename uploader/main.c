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
    asm("press:   lda $FCB0");
    asm("         beq press");
    asm("release: lda $FCB0");
    asm("         bne release");
}

void main(void)
{
    unsigned char data;

    initialize();
    tgi_clear();

    while (tgi_busy());
    wait_joystick();

    // Turn on serial timer to 1 MHz (1 microsecond source period)
    MIKEY.timer4.controla = ENABLE_RELOAD | ENABLE_COUNT | AUD_1; // %0001 1000

    // Set baud rate to 62500
    // Reload is after 1 + 1 = 2 periods, with clock speed of 1 MHz => rate = 1M / (2*8) = 62500
    MIKEY.timer4.backup = 1;
    MIKEY.serctl = PAREN | TXOPEN | PAREVEN | RESETERR; // %0001 1101

    // Clear receive buffer
    while ((MIKEY.serctl & RXRDY) != 0)
    {
        data = MIKEY.serdat; // Dummy read from receive buffer
    }

    MIKEY.serctl = RXINTEN | PAREN | RESETERR | TXOPEN | PAREVEN; // %0101 1101

    while (true)
    {
        show_screen();
    };
}