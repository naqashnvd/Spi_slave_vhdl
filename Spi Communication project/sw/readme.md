# SPI Communication with WiringPi

## Overview
This C code demonstrates how to communicate with an SPI (Serial Peripheral Interface) device using the WiringPi library on a Raspberry Pi. The code initializes the SPI interface, sends data to the device, and receives data from it.

## Table of Contents
- [Requirements](#requirements)
- [Usage](#usage)
- [Code Explanation](#code-explanation)

## Requirements
To run this code, you'll need the WiringPi library installed on your Raspberry Pi. You can install it using the following command:

```bash
sudo apt install wiringpi
```
## Usage
Clone or download this repository to your Raspberry Pi.

Compile the code using a C compiler. For example:

```bash
gcc -o spi_communication spi_communication.c -lwiringPi
```
Run the compiled binary:
```bash
./spi_communication
```
The program will initialize the SPI interface, send and receive data in a loop, and display the results on the console.

## Code Explanation
- The code uses the WiringPi library to interact with the SPI interface.

- chip_sel specifies the chip select (CS/CE) channel. It's set to 0, indicating the first SPI device.

- spi_speed sets the SPI clock speed in Hz. It's configured to run at 500,000 Hz (0.5 MHz).

- The program initializes the SPI interface using wiringPiSPISetup.

- It then enters a loop to send and receive data to/from the SPI device.

- Data is sent using wiringPiSPIDataRW, where the first byte (buffer[0]) is the command byte, and the second byte (buffer[1]) is the data byte.

- Received data is displayed on the console.

