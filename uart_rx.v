module reciever (
	input clk_25mhz,
	input ftdi_txd, // reciever
	output reg [7:0] led
);
	
	// synchronizer
	reg [1:0] rx_sync = 2'b11;
	always @(posedge clk_25mhz) rx_sync <= {rx_sync[0], ftdi_txd};
	wire rx = rx_sync[1];

	localparam IDLE = 2'b00;
	localparam START = 2'b01;
	localparam DATA = 2'b10;
	localparam STOP = 2'b11;

	reg [7:0] data = 0;

	reg [1:0] state = IDLE;

	reg [7:0] counter = 0;
	reg [2:0] bitcount = 0;


	always @(posedge clk_25mhz) begin
		if (state == IDLE && !rx) begin
			state <= START;
		end
		if (state != IDLE) begin
			counter <= counter + 1; 
			case (state)
				START: begin
					if (counter >= 108) begin
						counter <= 0;
						state <= rx ? IDLE : DATA; // verify bit is still low
					end
				end
				DATA: begin
					if (counter >= 217) begin
						data <= {rx, data[7:1]}; // shift LSB out
						bitcount <= bitcount + 1;
						if (bitcount == 7) begin
							state <= STOP;
						end
						counter <= 0;
					end
				end
				STOP: begin
					// verify the last bit is a 1
					if (counter >= 217) begin
						if (rx) led <= data;
						state <= IDLE;
						counter <= 0;
					end
				end
			endcase
		end
	end
endmodule
