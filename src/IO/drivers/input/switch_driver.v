`timescale 1ns / 1ps

module switch_driver(
    clk, rst,
    switch_addr,
    switch_enable,
    wdata,
    switch_data
    );
    input clk;
    input rst;
    input switch_enable;
    input [1:0] switch_addr;
    input [23:0] wdata;      //24 bit on board
    output reg [15:0] switch_data;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            switch_data <= 24'h0;
        end
        else if (switch_enable) begin
            if (switch_addr == 2'b00)
                switch_data[15:0] <= wdata[15:0];
            else if (switch_addr == 2'b10)
                switch_data[15:0] <= {8'h00, wdata[23:16]};
            else
                switch_data <= switch_data;
        end
        else begin
            switch_data <= switch_data;
        end
    end
endmodule
