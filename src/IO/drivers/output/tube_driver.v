`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/10 11:45:17
// Design Name: 
// Module Name: tube
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tube_driver(

    clk, rst, in, tubeout, tube_en
    );
    input clk;
    input rst;
    input[31:0] in;
    output reg[7:0] tubeout;
	output reg[7:0] tube_en;
	reg[3:0] cnt = 0;
	reg[7:0] tmp[15:0];

    always @(posedge clk, posedge rst) begin
        if (rst) begin 
			tmp[0]  = 8'b11000000;   //  0
            tmp[1]  = 8'b11111001;   //  1
            tmp[2]  = 8'b10100100;   //  2
            tmp[3]  = 8'b10110000;   //  3
            tmp[4]  = 8'b10011001;   //  4
            tmp[5]  = 8'b10010010;   //  5
            tmp[6]  = 8'b10000010;   //  6
            tmp[7]  = 8'b11111000;   //  7
            tmp[8]  = 8'b10000000;   //  8
            tmp[9]  = 8'b10010000;   //  9
            tmp[10] = 8'b10001000;   //  A
            tmp[11] = 8'b10000011;   //  B
            tmp[12] = 8'b11000110;   //  C
            tmp[13] = 8'b10100001;   //  D
            tmp[14] = 8'b10000110;   //  E
            tmp[15] = 8'b10001110;   //  F
		end
		else begin
			cnt <= (cnt == 4'd8) ? (4'd9) : (cnt + 1);
		end
    end    
	always @(posedge clk, posedge rst) begin
		case (cnt)
		4'd1:
		begin
			tube_en = 8'b01111111;
			tubeout = tmp[in[31:28]];
		end
		4'd2:
		begin
			tube_en = 8'b10111111;
			tubeout = tmp[in[27:24]];
		end
		4'd3:
		begin
			tube_en = 8'b11011111;
			tubeout = tmp[in[23:20]];
		end
		4'd4:
		begin
			tube_en = 8'b11101111;
			tubeout = tmp[in[19:16]];
		end
		4'd5:
		begin
			tube_en = 8'b11110111;
			tubeout = tmp[in[15:12]];
		end
		4'd6:
		begin
			tube_en = 8'b11111011;
			tubeout = tmp[in[11:8]];
		end
		4'd7:
		begin
			tube_en = 8'b11111101;
			tubeout = tmp[in[7:4]];
		end
		4'd8:
		begin
			tube_en = 8'b11111110;
			tubeout = tmp[in[3:0]];
		end
		default:
		tube_en = 8'b11111111;
	endcase
	end
endmodule
