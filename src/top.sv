`timescale 1ns/1ps

module top (
    input  wire clk,
    input  wire rst
    );

    wire cpu_clk;
    wire cpu_en;
    
    wire uart_clk;
    
    wire mem_write;
    wire [31:0] instr_addr, instr, mem_addr, write_data;
    reg  [31:0] read_data;
    
    clk_wiz_0 clk_gen(.clk_in1(clk),
                      .clk_out1(cpu_clk),
                      .clk_out2(uart_clk));
//    assign CPU_clk = clk;
    assign CPU_en = 1;    // todo: switch between UART mode and other.
                          
    CPU CPU_inst(.clk(CPU_clk),
                 .rst(rst),
                 .en(CPU_en),
                 .instr_addr(instr_addr),
                 .instr(instr),
                 .mem_write(mem_write),
                 .mem_addr(mem_addr),
                 .write_data(write_data),
                 .read_data(read_data));
    
    // set instruction memory
    wire [31:0] true_instr_addr;
    
    assign true_instr_addr = $signed(instr_addr) - $signed(32'h0040_0000);
                 
    instr_mem instr_memory(.clka(cpu_clk),
                           .addra(true_instr_addr[15:2]),
                           .wea(0),
                           .dina(0),
                           .douta(instr));
    
    // set data memory
    wire is_in_data_seg;
    wire [31:0] data_addr;
    wire data_wea;
    wire [31:0] data_out;
    
    assign is_in_data_seg = (mem_addr >= 32'h1001_0000 && mem_addr < 32'h7000_0000);
    assign data_addr = is_in_data_seg ? ($signed(mem_addr) - $signed(32'h1001_0000)) : 32'h0000_0000;
    assign data_wea = is_in_data_seg && mem_write;
    
    data_mem data_memory(.clka(~cpu_clk),
                         .addra(data_addr[15:2]),
                         .dina(write_data),
                         .douta(data_out),
                         .wea(data_wea));
    
    // set stack memory
    wire is_in_stack_seg;
    wire [31:0] stack_addr;
    wire stack_wea;
    wire [31:0] stack_out;
    
    assign is_in_stack_seg = (mem_addr >= 32'h7000_0000 && mem_addr <= 32'h7fff_effc);
    assign stack_addr = is_in_stack_seg  ? (32'h7fff_effc - mem_addr) : 32'h0000_0000;
    assign stack_wea = is_in_stack_seg  && mem_write;
    
    stack_mem stack_memory(.clka(~cpu_clk),
                           .addra(stack_addr[15:2]),
                           .dina(write_data),
                           .douta(stack_out),
                           .wea(stack_wea));
    
    
    // set the source of read_data
    wire [1:0] data_dst;
    
    assign data_dst = {is_in_data_seg, is_in_stack_seg};
    
    // adjust read port
    always_comb begin
        casez (data_dst)
            2'b10: read_data = data_out;
            2'b01: read_data = stack_out;
            default: read_data = 32'h0000_0000;
        endcase
    end
    
endmodule
