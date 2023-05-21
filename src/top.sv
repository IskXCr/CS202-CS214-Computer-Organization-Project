`timescale 1ns/1ps

module top (
    input  wire clk,
    input  wire rst
    );

    wire cpu_clk;
    
    wire mem_write;
    wire [31:0] instr_addr, instr, mem_addr, write_data, read_data;
    
//    clk_wiz_0 clk_gen(.clk_in1(clk),
//                      .clk_out1(cpu_clk));
    assign cpu_clk = clk;
                          
    CPU cpu_inst(.clk(cpu_clk),
                 .rst(rst),
                 .instr_addr(instr_addr),
                 .instr(instr),
                 .mem_write(mem_write),
                 .mem_addr(mem_addr),
                 .write_data(write_data),
                 .read_data(read_data));
    
    wire [31:0] true_instr_addr;
        
    assign true_instr_addr = $signed(instr_addr) - $signed(32'h0040_0000);
                 
    instr_mem instr_memory(.clka(cpu_clk),
                           .addra(true_instr_addr[15:2]),
                           .wea(0),
                           .dina(0),
                           .douta(instr));
    
    wire [31:0] true_mem_addr;
    
    assign true_mem_addr = $signed(mem_addr) - $signed(32'h1001_0000);
    
    data_mem data_memory(.clka(~cpu_clk),
                         .addra(true_mem_addr[15:2]),
                         .dina(write_data),
                         .douta(read_data),
                         .wea(mem_write));
    
endmodule
