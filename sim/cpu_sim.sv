`timescale 1ns/1ps

module CPU_sim();

    reg [4:0] buttons = 5'b00000;
    reg [23:0] switches = 24'hf0_fdff;
    wire [23:0] led;
    wire [7:0] tube_en, tube_seg;
    
    reg clk = 0;
    
    initial begin
        #500 buttons[4] = 1;
        #500 buttons[4] = 0;
    end
    
    initial begin
        forever begin
            #5 clk = ~clk;
        end
    end
    
    top top_inst(.fpga_clk(clk),
                 .buttons(buttons),
                 .switches(switches),
                 .led(led),
                 .tube_en(tube_en),
                 .tube_seg(tube_seg));
    
endmodule