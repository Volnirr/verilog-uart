module transmitter (
	input clk_25mhz,
	input [6:0] btn,
	output reg [7:0] led,
	output reg ftdi_rxd // transmit
);
	initial led = 0;
	initial ftdi_rxd = 1;

	localparam IDLE = 2'b00;
	localparam START = 2'b01;
	localparam DATA = 2'b10;
	localparam STOP = 2'b11;

	reg [7:0] counter = 0;
	reg [1:0] state = 0;
	initial state = IDLE;


	localparam datastorage = 8'b01001000;
	reg [7:0] data =  datastorage;

	reg [2:0] bitcounter = 0; // keeps track of which bit in the byte of data is being moved

	// change signal based on state
	always @(posedge clk_25mhz) begin
		counter <= counter + 1;

		if (!btn[0] && state == IDLE) begin
			state <= START;
		end


		if (counter >= 217) begin
			case (state)
				IDLE: begin
					ftdi_rxd <= 1;
				end
				START: begin
					ftdi_rxd <= 0;
					state <= DATA;
					led[0] <= 1;
				end
				DATA: begin
					ftdi_rxd <= data[0];
					data <= data >> 1;
					bitcounter <= bitcounter + 1;
					if (bitcounter == 7) begin
						state <= STOP;
					end
				end
				STOP: begin
					data <= datastorage;
					bitcounter <= 0;
					ftdi_rxd <= 1;
					state <= IDLE;
					led[0] <= 0;
				end
			endcase

			counter <= 0;
		end
	end
endmodule
