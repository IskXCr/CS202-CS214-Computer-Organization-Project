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
    clk, rst, in, tube_seg, tube_en
    );
    input clk;
    input rst;
    input [31:0] in;
    output reg [7:0] tube_seg;
	output reg [7:0] tube_en;

	reg [3:0] cnt = 0;
	reg [7:0] tmp[15:0];
	reg [31:0] t = 0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin 
			tmp[0]  = 8'b00000011;   //  0
            tmp[1]  = 8'b10011111;   //  1
            tmp[2]  = 8'b00100101;   //  2
            tmp[3]  = 8'b00001101;   //  3
            tmp[4]  = 8'b10011001;   //  4
            tmp[5]  = 8'b01001001;   //  5
            tmp[6]  = 8'b01000001;   //  6
            tmp[7]  = 8'b00011111;   //  7
            tmp[8]  = 8'b00000001;   //  8
            tmp[9]  = 8'b00001001;   //  9
            tmp[10] = 8'b00010001;   //  A
            tmp[11] = 8'b11000001;   //  B
            tmp[12] = 8'b01100011;   //  C
            tmp[13] = 8'b10000101;   //  D
            tmp[14] = 8'b01100001;   //  E
            tmp[15] = 8'b01110001;   //  F
		end
    end    
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            t <= 0;
        end
        else begin
            t <= (t == 10_000) ? 0 : t + 1;
        end
    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt <= 4'd1;
        end
        else begin
            if (t == 0)
                cnt <= (cnt == 4'd8) ? (4'd1) : (cnt + 1);
            else
                cnt <= cnt;
        end
    end
    
	always @(posedge clk, posedge rst) begin
	   if (rst) begin
	       tube_en = 8'b11111111;
	       tube_seg = 8'b00000000;
	   end
	   else begin
            case (cnt)
                4'd1:
                begin
                    tube_en = 8'b01111111;
                    tube_seg = tmp[in[31:28]];
                end
                4'd2:
                begin
                    tube_en = 8'b10111111;
                    tube_seg = tmp[in[27:24]];
                end
                4'd3:
                begin
                    tube_en = 8'b11011111;
                    tube_seg = tmp[in[23:20]];
                end
                4'd4:
                begin
                    tube_en = 8'b11101111;
                    tube_seg = tmp[in[19:16]];
                end
                4'd5:
                begin
                    tube_en = 8'b11110111;
                    tube_seg = tmp[in[15:12]];
                end
                4'd6:
                begin
                    tube_en = 8'b11111011;
                    tube_seg = tmp[in[11:8]];
                end
                4'd7:
                begin
                    tube_en = 8'b11111101;
                    tube_seg = tmp[in[7:4]];
                end
                4'd8:
                begin
                    tube_en = 8'b11111110;
                    tube_seg = tmp[in[3:0]];
                end
                default:
                begin
                    tube_en = 8'b11111111;
                    tube_seg = tube_seg;
                end
            endcase
        end
	end
endmodule
