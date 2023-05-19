`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2023 02:24:30 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input  wire        clk,

    input  wire [5:0]  ALU_op,    // ALU internal op code
    input  wire [4:0]  shamt,     // shift amount

    input  wire        ALU_src,   // if asserted, select the immediate as the second operand
    input  wire [31:0] op_src_1,
    input  wire [31:0] op_src_2,
    input  wire [31:0] immediate,
    
    output wire       zero,
    output reg [31:0] ALU_out
    );

    wire [31:0] op_1;
    wire [31:0] op_2;

    assign op_2 = (ALU_src == 1'b1) ? immediate : op_src_2;
    assign zero = (ALU_out == 32'b0000_0000_0000_0000) ? 1'b1 : 1'b0;

    always_comb begin
        case (ALU_op)
            5'b00001:
                ALU_out = op_1 + op_2; 
            default: 
                ALU_out = op_1 - op_2;
        endcase
    end

    always_ff @(posedge clk) begin
        
    end
endmodule
