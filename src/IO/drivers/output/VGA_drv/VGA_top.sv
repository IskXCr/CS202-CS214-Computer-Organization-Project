`timescale 1ns/1ps

module VGA_top(
    input  wire data_clk,
    input  wire dri_clk,

    input  wire wea,
    input  wire [11:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data,

    output wire [3:0]  red,
    output wire [3:0]  green,
    output wire [3:0]  blue,
    output wire        hsync,
    output wire        vsync
    );

    


endmodule