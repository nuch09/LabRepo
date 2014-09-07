#include <stdio.h>
#include <system.h>
#include <altera_avalon_pio_regs.h>
extern void puttime(int* timeloc);
extern void puthex(int time);
extern void tick(int* timeloc);
extern void delay (int millisec);
extern int hexasc(int invalue);

#define TRUE 1

void test_hexasc() {
    // Test the hexasc function:
    int i;
    for(i = 0; i<=0xFF; i++) {
        putchar(hexasc(i));
    }
}

int bcd2seven(int inval) {
    inval &= 0xf;
    int translate[] = {
        0x40,   // 0
        ~(0x6), // 1
        0x24,   // 2
        0xb0,   // 3
        0x19,   // 4
        0x12,   // 5
        0x02,   // 6
        0x78,   // 7
        0x00,   // 8
        0x10,   // 9
        0x04,   // A
        0x03,   // B
        0x07,   // C
        0x21,   // D
        0x06,   // E
        0x0d,   // F
    };
    return translate[inval]&0x7f;
}

void puthex(int timeval) {
      int outval = bcd2seven(timeval >> 4*3 )<<7*3
                 | bcd2seven(timeval >> 4*2 )<<7*2
                 | bcd2seven(timeval >> 4*1 )<<7*1
                 | bcd2seven(timeval       );
  IOWR_ALTERA_AVALON_PIO_DATA(DE2_PIO_HEX_LOW28_BASE,outval ); /* First digit */
}
int timeloc = 0x5957; /* startvalue given in hexadecimal/BCD-code */



int main ()
{
    //test_hexasc();   
    // Run the clock
    while (TRUE)
    {
        delay(1000);
        tick(&timeloc);
        IOWR_ALTERA_AVALON_PIO_DATA(DE2_PIO_REDLED18_BASE, timeloc);
        puttime (&timeloc);
        puthex(timeloc);
    }
    
    return 0;
}
