`timescale 1ns / 1ps

module LED_driver(
    clk, rst, in, led_addr, led_in, led_out, read_data
    );
    input clk;
    input rst;
    input in;
	input [1:0] led_addr;
	input [15:0] led_in;
	output reg[23:0] led_out;
	output reg[15:0] read_data;

    always @(posedge clk, posedge rst) begin
        if (rst) begin 
			led_out <= 24'h0;
			read_data <= 24'h0;
		end
		else if (in) begin
			if (led_addr == 2'b00) begin
				led_out[23] = led_in[0];
				read_data[15:0] <= {15'h0, led_in[0]};
			end
			else if (led_addr == 2'b01) begin
				led_out[15:0] <= led_in[15:0];
				read_data[15:0] <= led_in[15:0];
			end
			else if (led_addr == 2'b10) begin
				led_out[23:16] <= led_in[7:0];
				read_data[15:0] <= {8'h0, led_in[7:0]};
			end
			else begin
				led_out <= led_in;
				read_data[15:0] <= 16'h0;
			end
				
		end
		else begin
			led_out <= led_out;
		end
	end
endmodule
