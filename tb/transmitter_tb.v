`timescale 1ns / 1ps

// uart_tx testbench
// send one byte, sample the line mid-bit, check it reads 0x48

module transmitter_tb;

    localparam CLK_PERIOD = 40;                       // 25mhz -> 40ns
    localparam BIT_CLOCKS = 218;                      // counter rolls over every 218 clocks = 1 bit
    localparam BIT_TIME   = BIT_CLOCKS * CLK_PERIOD;  // 8720ns
    localparam HALF_BIT   = BIT_TIME / 2;             // 4360ns
    localparam [7:0] EXPECTED = 8'h48;                // datastorage in the design = 'H'

    reg        clk = 0;                 // tb drives these
    reg  [6:0] btn = 7'b1111111;        // idle high, active low
    wire [7:0] led;                     // tb only reads these
    wire       ftdi_rxd;

    integer i;
    reg [7:0] received;                 // byte read back off the line

    transmitter dut (
        .clk_25mhz (clk),
        .btn       (btn),
        .led       (led),
        .ftdi_rxd  (ftdi_rxd)
    );

    always #(CLK_PERIOD/2) clk = ~clk;  // 25mhz clock

    initial begin
        $dumpfile("dump.vcd");          // waveform for gtkwave
        $dumpvars(0, transmitter_tb);

        #(BIT_TIME*2);                  // let the line settle high

        btn[0] = 0;                     // tap button 0, send one frame
        #(CLK_PERIOD*5);
        btn[0] = 1;

        @(negedge ftdi_rxd);            // start bit = first falling edge
        $display("[%0d ns] start bit detected", $time);

        // half a bit lands mid start-bit, one more bit lands mid data bit 0
        #(HALF_BIT + BIT_TIME);

        received = 0;
        for (i = 0; i < 8; i = i + 1) begin   // 8 data bits, lsb first
            received[i] = ftdi_rxd;
            $display("[%0d ns] data bit %0d = %b", $time, i, ftdi_rxd);
            #(BIT_TIME);
        end

        $display("[%0d ns] stop bit = %b (expected 1)", $time, ftdi_rxd);

        $display("--------------------------------------------------");
        $display("expected: 0x%02h  (%b)", EXPECTED, EXPECTED);
        $display("received: 0x%02h  (%b)", received, received);
        if (received === EXPECTED)      // === so an x reads as a fail not unknown
            $display("RESULT: PASS");
        else
            $display("RESULT: FAIL");
        $display("--------------------------------------------------");

        #(BIT_TIME*2);                  // tail for the waveform
        $finish;
    end

endmodule
