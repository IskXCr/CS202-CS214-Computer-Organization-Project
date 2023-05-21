`timescale 1ns/1ps

module mux2 #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,

    input  wire             sel,

    output wire [WIDTH-1:0] q
    );

    assign q = sel ? d1 : d0;
    
endmodule