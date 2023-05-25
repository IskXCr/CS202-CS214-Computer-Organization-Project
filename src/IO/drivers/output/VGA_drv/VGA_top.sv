`timescale 1ns/1ps

// CAUTION: this module is tailored for 480p.
//          If you are to change this, you must also refactor other parts where suitness for 480p is explicitly stated.
module VGA_top(
    input  wire data_clk,
    input  wire fpga_clk, // this should be at 100 MHz
    input  wire rst,      // this will not cause the buffer to be reset

    input  wire wen,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data,

    output wire [3:0]  red,
    output wire [3:0]  green,
    output wire [3:0]  blue,
    output wire        hsync,
    output wire        vsync
    );
    

    ///////////////////////////////////////////////////
    // VGA driver clk generation
    wire dri_clk; // VGA driver clock at 25.175 MHz for 480p
    clk_wiz_1 clk_gen(.clk_in1(fpga_clk), .clk_out1(dri_clk), .reset(1'b0));


    ///////////////////////////////////////////////////
    // cpu buffer access

    wire [9:0] cpu_buf_addr;

    assign cpu_buf_addr = addr[11:2];


    ///////////////////////////////////////////////////
    // text controller buffer access
    wire [9:0] sgn_pos_x, sgn_pos_y; // data length for 480p
    wire [9:0]  cont_buf_addr;
    wire [31:0] cont_buf_data;
    wire [11:0] color_out;
    
    VGA_text_cont VGA_text_controller(.dri_clk(dri_clk),
                                      .rst(rst),
                                      .sgn_pos_x(sgn_pos_x),
                                      .sgn_pos_y(sgn_pos_y),
                                      .cont_buf_addr(cont_buf_addr),
                                      .cont_buf_data(cont_buf_data),
                                      .color_out(color_out));

    
    ///////////////////////////////////////////////////
    // VGA buffer memory
    // A port assigned to CPU
    // B port assigned to VGA text controller

    vga_buffer_mem VGA_buffer(.addra(cpu_buf_addr),
                              .clka(data_clk),
                              .dina(write_data),
                              .douta(read_data),
                              .wea(wen),

                              .addrb(cont_buf_addr),
                              .clkb(dri_clk),
                              .dinb(32'h0000_0000),
                              .doutb(cont_buf_data),
                              .web(1'b0));


    ///////////////////////////////////////////////////
    // VGA driver

    VGA_sig_drv VGA_driver(.clk(dri_clk),
                           .rst(rst),
                           .v_data(color_out),
                           .red(red),
                           .green(green),
                           .blue(blue),
                           .hsync(hsync),
                           .vsync(vsync),
                           .pos_x(sgn_pos_x),
                           .pos_y(sng_pos_y));

endmodule