`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/25 16:33:26
// Design Name: 
// Module Name: keyboard
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


module keyboard (
  input           clk,
  input           rst,
  input      [3:0] row,
  output reg [3:0] keyboard_val,
  output reg      press
);

  reg [19:0] cnt;
  wire       key_clk;
  reg  [2:0] col;

  always @(posedge clk or posedge rst) begin
    if (rst)
      cnt <= 0;
    else
      cnt <= cnt + 1'b1;
  end

  assign key_clk = cnt[19];

  always @(posedge key_clk or posedge rst) begin
    if (rst) begin
      col <= 3'b000;
      keyboard_val <= 4'b0000;
      press <= 0;
    end else begin
      case (col)
        3'b000: col <= 3'b001;
        3'b001: col <= 3'b010;
        3'b010: col <= 3'b011;
        3'b011: col <= 3'b100;
        3'b100: begin
                  col <= 3'b000;
                  if (row != 4'hF) begin
                    case ({col, row})
                      {3'b001, 4'b1110}: keyboard_val <= 4'b0001;
                      {3'b001, 4'b1101}: keyboard_val <= 4'b0100;
                      {3'b001, 4'b1011}: keyboard_val <= 4'b0111;
                      {3'b001, 4'b0111}: keyboard_val <= 4'b1110;

                      {3'b010, 4'b1110}: keyboard_val <= 4'b0010;
                      {3'b010, 4'b1101}: keyboard_val <= 4'b0101;
                      {3'b010, 4'b1011}: keyboard_val <= 4'b1000;
                      {3'b010, 4'b0111}: keyboard_val <= 4'b0000;

                      {3'b011, 4'b1110}: keyboard_val <= 4'b0011;
                      {3'b011, 4'b1101}: keyboard_val <= 4'b0110;
                      {3'b011, 4'b1011}: keyboard_val <= 4'b1001;
                      {3'b011, 4'b0111}: keyboard_val <= 4'b1111;

                      {3'b100, 4'b1110}: keyboard_val <= 4'b1010;
                      {3'b100, 4'b1101}: keyboard_val <= 4'b1011;
                      {3'b100, 4'b1011}: keyboard_val <= 4'b1100;
                      {3'b100, 4'b0111}: keyboard_val <= 4'b1101;
                    endcase
                    press <= 1;
                  end else begin
                    keyboard_val <= 4'b0000;
                    press <= 0;
                  end
                end
      endcase
    end
  end
endmodule

