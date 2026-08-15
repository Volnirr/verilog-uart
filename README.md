# verilog-uart

UART transmitter and receiver in Verilog for the Lattice ECP5, developed and tested on the ULX3S. 8N1, 115200 baud from a 25 MHz clock. Made using Yosys, nextpnr, openFPGALoader and Icarus Verilog.

## Specifications

| Parameter | Value |
|---|---|
| Format | 8 data bits, no parity, 1 stop bit (8N1) |
| Baud rate | 114,679 baud (218 clocks/bit at 25 MHz, 0.45% error vs 115200) |
| Clock | 25 MHz onboard oscillator |
| RX input conditioning | 2-flop synchronizer |
| Noise handling | Start bit verified mid-bit, glitches under half a bit period rejected |
| Framing | Stop bit validated, output only updates on a valid frame |
| Target | Lattice ECP5 (ULX3S), no vendor primitives, portable to any FPGA |

Worst case accumulated drift at the stop bit sample is under 5% of a bit period.

Both testbenches are self-checking and print PASS/FAIL per case

## License

MIT
