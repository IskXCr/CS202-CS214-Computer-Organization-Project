`timescale 1ns/1ps

module CPU(
    input  wire clk,
    input  wire rst,

    output wire [31:0] instr_addr,
    input  wire [31:0] instr,

    output wire [31:0] mem_addr,
    output wire mem_write,
    output wire [31:0] write_data,
    input  wire [31:0] read_data

    );

endmodule