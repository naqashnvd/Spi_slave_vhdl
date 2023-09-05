// Library required WiringPISPI
// sudo apt install wiringpi
#include <stdio.h>
#include <wiringPiSPI.h>

static const int chip_sel = 0;
static const int spi_speed = 500000; // in Hz

int main()
{
   int fd, result;
   unsigned char buffer[2];

   printf("Starting ...\n");

   fd = wiringPiSPISetup(chip_sel, spi_speed);

   printf("Init result: %d\n",fd);

   for(int i = 0; i < 10; i++)
   {
      buffer[0] = 0x12;
      buffer[1] = i;
      result = wiringPiSPIDataRW(chip_sel, buffer, 2);

      printf("Buff: %02x%02x \n",buffer[0],buffer[1]);

      buffer[0] = 0x34;
      buffer[1] = i + 1;
      result = wiringPiSPIDataRW(chip_sel, buffer, 2);

      printf("Buff: %02x%02x \n",buffer[0],buffer[1]);
   }
}
