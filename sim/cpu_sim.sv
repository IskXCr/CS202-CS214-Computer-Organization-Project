`timescale 1ns/1ps

module cpu_sim();
    
    reg clk = 0;
    reg rst = 0;
    
    initial begin
        #50 rst = 1;
        #50 rst = 0;
        forever begin
            #50 clk = ~clk;
        end
    end
    
    top top_inst(.clk(clk),
                 .rst(rst));
    
endmodule