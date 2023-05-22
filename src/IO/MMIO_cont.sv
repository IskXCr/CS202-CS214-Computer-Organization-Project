`timescale 1ns/1ps

module MMIO_cont(
    input  wire cpu_clk,  // write data on posedge of this clk
    input  wire dri_clk,  // 100 MHz clk onboard.
    input  wire rst,      // clear writable memory

    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data, // for addr, return the data read on next posedge of this clk. addr starts from 0x00000000.
    input  wire wea,

    input  wire mode,
    input  wire overflow,
    input  wire [4:0]  buttons,
    input  wire [23:0] switches,
    output wire [23:0] led,
    output wire [7:0]  tube_en,
    output wire [7:0]  tube_seg
    );

    wire io_enable;
    wire led_enable;
    wire switch_enable;
    wire tube_enable;
    wire [15:0] switch_readdata;
    wire [15:0] led_readdata;
    wire [15:0] tube_readdata;
    
    assign io_enable = wea;
    assign led_enable = (io_enable && addr[7:4] == 4'h6);
    assign switch_enable = (io_enable && addr[7:4] == 4'h7);
    assign tube_enable = (io_enable && addr[7:4] == 4'h9);

    switch_driver t1(.clk(cpu_clk),
                     .rst(rst),
                     .switch_enable(switch_enable),
                     .w_data(switches),
                     .switch_data(switch_readdata)
                     );

    LED_driver t2(.clk(cpu_clk),
                  .rst(rst),
                  .in(led_enable),
                  .led_addr(addr[3:2]),
                  .led_in(write_data[15:0]),
                  .led_out(led),
                  .readdata(led_readdata)
                  );

    tube_driver t3(.clk(cpu_clk),
                   .rst(rst),
                   .in(write_data),
                   .tubeout(tube_seg),
                   .tube_en(tube_en));

    assign read_data = (switch_enable == 1) ? 
    {16'h0000,switch_readdata} : ((led_enable == 1) ? {16'h0000,led_readdata} : write_data[31:0]);

endmodule