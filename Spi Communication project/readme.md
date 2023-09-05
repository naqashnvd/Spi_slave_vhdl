# SPI Communcation

This repository contains the source code for a SPI (Serial Peripheral Interface) communication project, which involves an SPI Slave implemented in VHDL and an SPI Master on a Raspberry Pi. SPI is a widely used communication protocol for connecting devices in embedded systems and digital communication.

## Features

- **VHDL SPI Slave**:
  - Implemented in VHDL for FPGA-based systems.
  - Supports a configurable data width (`bW`).
  - Interfaces with an external SPI Master device.
  - Handles data transmission and reception.
  - Utilizes a state machine to manage communication.

- **Raspberry Pi SPI Master**:
  - Developed in C using the WiringPi library for GPIO access.
  - Enables communication with the VHDL SPI Slave via SPI.
  - Configurable chip select and SPI speed.
  - Demonstrates sending and receiving data.

- **Top-Level Design**:
  - Combines the VHDL SPI Slave and Raspberry Pi SPI Master for a complete SPI communication system.
    
## Contributing
Contributions to this project are welcome. If you have suggestions, improvements, or bug fixes, please feel free to submit a pull request or open an issue in this repository.