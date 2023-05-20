`timescale 1ns/1ps
`include "constants.vh"

module PC #(parameter WIDTH = 32,
            parameter TEXT_BASE_ADDR = 32'h0000_0000) (
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire [WIDTH - 1:0] d,
    output reg  [WIDTH - 1:0] q
    );

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            q <= TEXT_BASE_ADDR;
        end
        else if (en) begin
            q <= d;
        end
    end
endmodule