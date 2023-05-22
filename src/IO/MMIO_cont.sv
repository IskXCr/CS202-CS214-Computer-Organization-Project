`timescale 1ns/1ps

module MMIO_cont(
    input  wire clk,  // write data on posedge of this clk
    input  wire rst,  // clear writable memory

    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data, // for addr, return the data read on next posedge of this clk
    input  wire wea,

    input  wire [4:0]  buttons,
    input  wire [23:0] switches,
    output wire [23:0] led,
    output wire [7:0]  tube_en,
    output wire [7:0]  tube_seg
    // TODO: add other IO devices
    );

endmodule