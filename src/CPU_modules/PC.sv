`timescale 1ns/1ps

module PC #(parameter TEXT_BASE_ADDR = 32'h0040_0000) (
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire [31:0] d,
    output reg  [31:0] q
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