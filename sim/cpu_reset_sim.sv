`timescale 1ns/1ps

module cpu_reset_sim();

    reg [4:0] buttons = 5'b00000;
    reg [23:0] switches = 24'h00_001A;
    wire [23:0] led;
    wire [7:0] tube_en, tube_seg;
    
    reg clk = 0;
    
    initial begin
        #500 buttons[4] = 1;
        #500 buttons[4] = 0;
        #6000 buttons[4] = 1;
        #6500 buttons[4] = 0;
    end
    
    initial begin
        forever begin
            #5 clk = ~clk;
        end
    end
    
    top top_inst(.fpga_clk(clk),
                 .buttons(buttons),
                 .switches(switches),
                 .upg_rx_i(1'b0),
                 .upg_tx_o(1'b0),
                 .led(led),
                 .tube_en(tube_en),
                 .tube_seg(tube_seg));
    
endmodule