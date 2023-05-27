`timescale 1ns/1ps

module VGA_text_sim();

    reg rst = 0;
    reg fpga_clk = 0;
    
    initial begin
        #3600 rst = 1;
        #4000 rst = 0;
    end
    
    initial begin
        forever begin
            #5 fpga_clk = ~fpga_clk;
        end
    end
    
    reg data_clk = 0;

    initial begin
        forever begin
            #5 data_clk = ~data_clk;
        end
    end

    reg [31:0] addr, write_data, read_data;

    wire [3:0] red, green, blue;
    wire hsync, vsync;

    VGA_top VGA_sim_inst(.data_clk(data_clk),
                         .fpga_clk(fpga_clk),
                         .rst(rst),
                         .wen(1'b1),
                         .addr(addr),
                         .write_data(write_data),
                         .read_data(read_data),
                         .red(red),
                         .green(green),
                         .blue(blue),
                         .hsync(hsync),
                         .vsync(vsync));

    initial begin
         addr = 32'h0000_0000;
         write_data = 32'h2424_4B4A;
    end
    
endmodule