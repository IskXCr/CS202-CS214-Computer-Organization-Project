`timescale 1ns/1ps

module mode_switch_sim();

    reg [4:0] buttons = 5'b00000;
    reg [23:0] switches = 24'h00_0000;
    wire [23:0] led;
    wire [7:0] tube_en, tube_seg;
    
    reg clk = 0;
    
    initial begin
        #500 buttons[4] = 1;
        #500 buttons[4] = 0;
        #3000 buttons[3] = 1;
        #3500 buttons[3] = 0;
        #4000 buttons[2] = 1;
        #4500 buttons[2] = 0;
    end
    
    initial begin
        forever begin
            #5 clk = ~clk;
        end
    end
    
    top top_inst(.clk(clk),
                 .buttons(buttons),
                 .switches(switches),
                 .led(led),
                 .tube_en(tube_en),
                 .tube_seg(tube_seg));
    
endmodule