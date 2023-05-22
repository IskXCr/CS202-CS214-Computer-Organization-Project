`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 21:44:51
// Design Name: 
// Module Name: tube_driver_test
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

module tube_driver_test;

    reg clk;
    reg rst;
    reg [31:0] in;
    wire [7:0] tubeout;
    wire [7:0] tube_en;

    tube_driver dut (
        .clk(clk),
        .rst(rst),
        .in(in),
        .tubeout(tubeout),
        .tube_en(tube_en)
    );

    initial begin
        clk = 0;
        rst = 1;
        in = 32'h12345678;

        #10 rst = 0; // Reset deasserted
        #20 in = 32'h98765432; // Change input value
        #200 in = 32'h38273625;
        #400 in = 32'h92736453;
        #400 in = 32'hddddaaaa;

        #10000 $finish; // End simulation
    end

    always begin
        #5 clk = ~clk; // Toggle clock every 5 time units
    end

    always @(posedge clk) begin
        $display("Input: %h", in);
        $display("Tube Output: %b", tubeout);
        $display("Tube Enable: %b", tube_en);
    end

endmodule
