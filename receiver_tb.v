`timescale 1ns / 1ps

module reciever_tb;
    reg clk = 0;
    reg rx = 1;          // idle high, this replaces your initial statement
    wire [7:0] led;

    reciever dut (.clk_25mhz(clk), .ftdi_txd(rx), .led(led));

    always #20 clk = ~clk;   // 25 MHz = 40 ns period

    // one bit period = 217 clocks = 8680 ns
    task send_byte(input [7:0] b);
        integer i;
        begin
            rx = 0; #8680;                     // start bit
            for (i = 0; i < 8; i = i + 1) begin
                rx = b[i]; #8680;              // LSB first, matches your right shift
            end
            rx = 1; #8680;                     // stop bit
        end
    endtask

    initial begin
        $dumpfile("reciever_tb.vcd");
        $dumpvars(0, reciever_tb);
        #1000;
        send_byte(8'hA5);
        #20000;
        if (led !== 8'hA5) $display("FAIL: led = %h", led);
        else $display("PASS: led = %h", led);
        $finish;
    end
endmodule
