`timescale 1ns/1ps

module mux3 #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    input  wire [WIDTH-1:0] d2,

    input  wire [1:0]       sel,

    output reg  [WIDTH-1:0] q
    );

    always_comb begin
        case (sel)
            3'b00: q = d0;
            3'b01: q = d1;
            3'b02: q = d2;
            default: q = d0;
        endcase
    end
endmodule