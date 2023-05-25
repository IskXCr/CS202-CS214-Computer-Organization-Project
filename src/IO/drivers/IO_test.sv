`timescale 1ns/1ps

module IO_test (
    input  wire clk,

    input  wire upg_rx_i,
    output wire upg_tx_o,

    input  wire [4:0]  buttons,
    input  wire [23:0] switches,
    output wire [23:0] led,
    output wire [7:0]  tube_en,
    output wire [7:0]  tube_seg
    // TODO: add other IO devices
    );

    wire [31:0] tube_test;
    assign tube_test = 32'h0123_9ABC;

    tube_driver tube_cont(.clk(clk),
                          .rst(buttons[4]),
                          .in(tube_test),
                          .tube_seg(tube_seg),
                          .tube_en(tube_en));
  
endmodule
