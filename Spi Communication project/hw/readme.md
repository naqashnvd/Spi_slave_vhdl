# SPI Slave Module (spi_slave)

## Overview
The spi_slave module is a VHDL implementation of an SPI (Serial Peripheral Interface) slave device. It allows communication with an SPI master device using the SPI protocol. This README provides essential information about the module, its features, and how to use it in your projects.

## Table of Contents
- [Features](#features)
- [Module Ports](#module-ports)
- [Module Architecture](#module-architecture)
- [Usage](#usage)
- [Simulation](#simulation)

## Features
- Configurable data bus width (default: 16 bits).
- Synchronous operation with a clock signal.
- Support for active-low asynchronous reset.
- SPI transaction management with state machine.
- Data transfer on both rising and falling edges of the SPI clock.
- Full-duplex communication: sends and receives data.
- Easily interfaces with an SPI master device.
- Ready and valid signals for control interface.

## Module Ports
The spi_slave module has the following ports:

**Clock and Reset Signals:**
- `clk`: Input, clock signal.
- `aresetn`: Input, active-low asynchronous reset.

**Control Interface (Slave Interface):**
- `s_axis_tdata`: Input, data to be sent on the SPI bus (configurable width).
- `s_axis_tvalid`: Input, signal indicating valid data on `s_axis_tdata`.
- `s_axis_tready`: Output, signal indicating that the module is ready to accept data.

**Master Interface:**
- `m_axis_tdata`: Output, received data from the SPI bus (configurable width).
- `m_axis_tvalid`: Output, signal indicating that valid data is available.

**SPI Interface:**
- `spi_sclk`: Input, SPI clock signal.
- `spi_csn`: Input, SPI Chip Select (active-low) signal.
- `spi_mosi`: Input, SPI Master Out Slave In data signal.
- `spi_miso`: Output, SPI Master In Slave Out data signal.

## Module Architecture
The spi_slave module consists of the following components:

**SPI Transaction Handling:** A state machine manages SPI transactions. It waits for the Chip Select (`spi_csn`) signal to go low to start a transaction. It shifts out data on the rising edge of the SPI clock (`spi_sclk`) and receives data on the falling edge. The module counts bits transferred and transitions to `state_done` after completing a transaction.

**SPI Data Transfer:** Data is sent on `spi_miso` when in the `state_busy` state.

**Control Interface Handling:** Control interface signals (`s_axis_tdata`, `s_axis_tvalid`, and `s_axis_tready`) are used to send data to the SPI master. The module is ready to accept data (`s_axis_tready`) when in the `state_idle` state. Received data is transferred to `m_axis_tdata` when in the `state_done` state, and `m_axis_tvalid` is asserted.

## Usage
1. Instantiate the `spi_slave` module in your Verilog project, providing the necessary configuration parameters and connecting its ports to your system.

2. Configure the data bus width (`bW`) as needed. The default is 16 bits.

3. Connect the module to your clock signal (`clk`) and provide an active-low asynchronous reset signal (`aresetn`).

4. Interface the control interface ports (`s_axis_tdata`, `s_axis_tvalid`, and `s_axis_tready`) with your system for sending data to the SPI master.

5. Connect the SPI interface signals (`spi_sclk`, `spi_csn`, `spi_mosi`, and `spi_miso`) to your SPI master device.

6. Monitor the `m_axis_tdata` and `m_axis_tvalid` signals to receive data from the SPI master.

7. Use the `aresetn` signal for module reset as needed.

## Simulation
To test and simulate the `spi_slave` module, follow these steps:

1. Create a testbench that instantiates the `spi_slave` module.

2. Provide appropriate clock and reset signals (`clk` and `aresetn`) in your testbench.

3. Stimulate the module by toggling control interface signals (`s_axis_tdata`, `s_axis_tvalid`, and `s_axis_tready`) and monitoring SPI interface signals (`spi_sclk`, `spi_csn`, `spi_mosi`, and `spi_miso`).

4. Observe the behavior of the module and verify its functionality in simulation.

