#include <6502.h>
#include <lynx.h>
#include <tgi.h>
#include <joystick.h>
#include <stdlib.h>

extern unsigned char lynxtgi[];
extern unsigned char lynxjoy[];
extern unsigned char comlynx[];

extern turbo_upload();

#define true 1

void show_screen()
{
    char text[4];
    unsigned char joy;

    tgi_clear();

    tgi_setcolor(COLOR_WHITE);
    tgi_setbgcolor(COLOR_TRANSPARENT);

    tgi_outtextxy(0, 20, "Upload at 1Mbaud!");

    tgi_updatedisplay();
    while (tgi_busy());
}

void initialize()
{
    tgi_install(&tgi_static_stddrv);
    joy_install(&joy_static_stddrv);
    tgi_init();
    CLI();

    while (tgi_busy());

    tgi_setbgcolor(COLOR_TRANSPARENT);
    tgi_clear();
}

void main(void)
{
    unsigned char data;

    initialize();
    tgi_clear();

    while (tgi_busy());
    
    // Clear receive buffer
    while ((MIKEY.serctl & RXRDY) != 0)
    {
        data = MIKEY.serdat; // Dummy read from receive buffer
    }

    show_screen();
    
    // Switch on UARTturbo mode
    MIKEY.mtest0 = 0x10;
    turbo_upload();
}