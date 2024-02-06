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
    ltoa(SUZY.divide.quotient, text, 10);
    tgi_outtextxy(10, 50, text);

    ltoa(SUZY.divide.remainder, text, 10);
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

    MIKEY.timer4.controla = ENABLE_RELOAD | ENABLE_COUNT; // %00011000
    MIKEY.timer4.backup = AUD_2;
    MIKEY.serctl = PAREN | TXOPEN | PAREVEN | RESETERR;

    // Clear receive buffer
    while ((MIKEY.serctl & 0x40) != 0)
    {
        data = MIKEY.serdat; // Dummy read from receive buffer
    }

    MIKEY.serctl = PAREN | TXOPEN | PAREVEN | RESETERR | RXINTEN;

    // SUZY.sprsys = ACCUMULATE | SIGNMATH;
    // SUZY.math_signed_multiply.accumulate = 0;
    // SUZY.math_signed_multiply.factor1 = -1234;
    // SUZY.math_signed_multiply.factor2 = 5678;

    // SUZY.math_divide.divisor = 0x3125;
    // SUZY.math_divide.dividend2 = 0x5679;
    // SUZY.math_divide.dividend1 = 0x1234;

    // while ((SUZY.sprsys & MATHWORKING) != 0) ;

    while (true)
    {
        // if (!tgi_busy())
        // {
            show_screen();
        //}
    };
}