This is a simple custom UART receiver/transmitter module written in VHDL for the Zedboard programmable logic (FPGA). It runs at 19200 baud rate, with 1 stop bit and no parity bits. It uses the AXI4-Lite bus to interface with the Zedboard processing system (ARM CPU) as a memory mapped device.

The project also includes a Linux driver module and a wrapper file which redirects STDIN/STDOUT to /dev/myuart. There's also a game selection menu written in ncurses which executes a curated list of open source games from around the web.

This was tested on a VT510 hardware terminal (on VT100 emulation mode and 19200 baud rate).
